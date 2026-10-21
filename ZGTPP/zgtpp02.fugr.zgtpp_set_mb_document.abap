FUNCTION ZGTPP_SET_MB_DOCUMENT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      IT_MSEG TYPE  TY_T_MSEG OPTIONAL
*"----------------------------------------------------------------------

  DATA : BEGIN OF LS_CHK_AFPO,
           AUFNR TYPE AFPO-AUFNR,
           POSNR TYPE AFPO-POSNR,
         END OF LS_CHK_AFPO.
  DATA : LT_CHK_AFPO LIKE TABLE OF LS_CHK_AFPO.

  DATA : BEGIN OF LS_RESULT,
           WERKS        TYPE ZGTPPT2330-WERKS,
           RQMON        TYPE ZGTPPT2330-RQMON,
           ZWKREQ       TYPE ZGTPPT2330-ZWKREQ,
           MATNR        TYPE ZGTPPT2330-MATNR,
           PLNUM        TYPE ZGTPPT2330-PLNUM,
           GSMNG_O      TYPE ZGTPPT2330-GSMNG,
           GSMNG_RESULT TYPE ZGTPPT2330-GSMNG,
           GSMNG        TYPE ZGTPPT2330-GSMNG,
           ZADDMNG      TYPE ZGTPPT2330-ZADDMNG,
         END OF LS_RESULT.
  DATA : LT_RESULT LIKE TABLE OF LS_RESULT.
  DATA : LV_MENGE     TYPE MENGE_D. "조장계산 오더의 총수량
  DATA : LV_MENGE01 TYPE MENGE_D. "오더의 총 마감수량
  DATA : LV_MENGE02 TYPE MENGE_D. " Tolerance 계산비율
  DATA : LV_MENGE03 TYPE MENGE_D. " 필요조장수
  DATA : LT_MSEG TYPE TY_T_MSEG.
  DATA : LT_MODI_2340 TYPE TABLE OF ZGTPPT2340.


  LT_CHK_AFPO  = VALUE #( FOR LW_MSEG IN IT_MSEG WHERE ( BWART = '101'
                                                                            AND   ELIKZ = 'X' )
                                    ( AUFNR = LW_MSEG-AUFNR POSNR = LW_MSEG-AUFPS ) ).
* 완료 입고 대상이 있어야 계획지시 가능
  IF LT_CHK_AFPO IS NOT INITIAL.
    SORT LT_CHK_AFPO BY AUFNR POSNR.
    DELETE ADJACENT DUPLICATES FROM LT_CHK_AFPO COMPARING AUFNR POSNR.

    SELECT DISTINCT B~*
      FROM @LT_CHK_AFPO AS A
      INNER JOIN AFPO AS B ON B~AUFNR = A~AUFNR
                                  AND B~POSNR = A~POSNR
      INTO TABLE @DATA(LT_AFPO).

    SELECT DISTINCT B~*
      FROM @LT_CHK_AFPO AS A
      INNER JOIN ZGTPPT2340 AS B ON B~ORDNR = A~AUFNR
                                          AND B~POSNR = CONCAT( '00', A~POSNR )
                                          AND B~ORDTY = 'PRD'
      INTO TABLE @DATA(LT_2340).

    IF LT_2340[] IS NOT INITIAL.
      SELECT DISTINCT B~*
        FROM @LT_2340 AS A
        INNER JOIN ZGTPPT2330 AS B ON B~RQMON = A~RQMON
                                          AND B~ZWKREQ = A~ZWKREQ
                                          AND B~MATNR = A~MATNR
        WHERE B~DMORD IS INITIAL
        INTO TABLE @DATA(LT_2330).
    ENDIF.

* 생산계획량 변경 확인을 위한 기본 데이터 세팅
    LOOP AT LT_2330 INTO DATA(LS_2330).
      CLEAR LS_RESULT.
      MOVE-CORRESPONDING LS_2330 TO LS_RESULT.
      IF LS_2330-PLNUM IS NOT INITIAL.
        SELECT SINGLE GSMNG FROM PLAF
          INTO LS_RESULT-GSMNG_O
         WHERE PLNUM = LS_2330-PLNUM.
        IF SY-SUBRC EQ 0.
          LS_RESULT-GSMNG_RESULT = LS_RESULT-GSMNG_O.
        ENDIF.
      ENDIF.

      APPEND LS_RESULT TO LT_RESULT.
    ENDLOOP.

* 완료된 생산오더의 총 입고 수량 확인하여 부족량 존재하는지 확인
    LOOP AT LT_AFPO INTO DATA(LS_AFPO).
      READ TABLE LT_2340 INTO DATA(LS_2340) WITH KEY ORDNR = LS_AFPO-AUFNR
                                                                     POSNR+2(4) = LS_AFPO-POSNR.
      IF SY-SUBRC EQ 0.
        IF LS_2340-INLENGTH = 0. " 표준조장이 존재하지 않는다면 컨트롤 없음.
          CONTINUE.
        ENDIF.
* 조장계산 오더의 총 수량
        LV_MENGE = LS_2340-INLENGTH * LS_2340-INFACTOR.
        IF LV_MENGE = 0. "총수량 계산이 안되면 건너 띄어준다.
          CONTINUE.
        ENDIF.

* 오더의 총 마감수량
        LV_MENGE01 = LS_AFPO-WEMNG.

        REFRESH LT_MSEG.
        LT_MSEG = VALUE #( FOR LW_MSEG IN IT_MSEG WHERE ( AUFNR = LS_AFPO-AUFNR
                                                                        AND   AUFPS = LS_AFPO-POSNR )
                                   ( CORRESPONDING #( LW_MSEG ) ) ).

        LOOP AT LT_MSEG INTO DATA(LS_MOSU).
          CASE LS_MOSU-BWART.
            WHEN '101'.
              LV_MENGE01 = LV_MENGE01 + LS_MOSU-MENGE.
            WHEN '102'.
              LV_MENGE01 = LV_MENGE01 - LS_MOSU-MENGE.
          ENDCASE.
          IF LS_MOSU-ELIKZ = ABAP_TRUE.
            EXIT.
          ENDIF.
        ENDLOOP.

        CLEAR LV_MENGE02.
        LV_MENGE02 = ( 1 - ( LV_MENGE01 / LV_MENGE ) ) * 100.
*      Tolerance 계산비용이 5보다 크다면 계획지시량 추가
        IF LV_MENGE02 > 5.
          LS_2340-ZUNDER = ABAP_TRUE.
          APPEND LS_2340 TO LT_MODI_2340.
          CLEAR LV_MENGE03.
* 조장수만큼 계획량 추가하여
          DO.
            ADD 1 TO LV_MENGE03.
            LV_MENGE01 = LV_MENGE01 + LS_2340-INLENGTH.

            CLEAR LV_MENGE02.
            LV_MENGE02 = ( 1 - ( LV_MENGE01 / LV_MENGE ) ) * 100.

            IF LV_MENGE02 <= 5.
              READ TABLE LT_RESULT ASSIGNING FIELD-SYMBOL(<LS_RESULT>) WITH KEY RQMON = LS_2340-RQMON
                                                                                                        ZWKREQ = LS_2340-ZWKREQ
                                                                                                        MATNR = LS_2340-MATNR.
              IF SY-SUBRC EQ 0.
                <LS_RESULT>-GSMNG_RESULT = <LS_RESULT>-GSMNG_RESULT + ( LS_2340-INLENGTH * LV_MENGE03 ).
                <LS_RESULT>-GSMNG = <LS_RESULT>-GSMNG + ( LS_2340-INLENGTH * LV_MENGE03 ).
                <LS_RESULT>-ZADDMNG = <LS_RESULT>-ZADDMNG + ( LS_2340-INLENGTH * LV_MENGE03 ).
              ENDIF.

              EXIT.
            ENDIF.
          ENDDO.
        ENDIF.
      ENDIF.
    ENDLOOP.

*  확인후 수량 변경건 존재한다면 계획오더 생성 및 변경한다.
    DATA : LT_MODI_2330 TYPE TABLE OF ZGTPPT2330.
    DATA : LS_HEADERDATA TYPE BAPIPLAF_I1.
    DATA : LV_PLANNEDORDER TYPE BAPI_PLDORD-PLDORD_NUM.
    DATA : LS_RETURN TYPE BAPIRETURN1.
    DATA : LS_CHG_HEADER TYPE BAPIPLAF_I2.
    DATA : LS_CHG_HEADERX TYPE BAPIPLAF_I2X.


    LOOP AT LT_RESULT INTO LS_RESULT.
* 작업 지시수량 변동건이 있다면 계획오더 생성 및 변경
      IF LS_RESULT-GSMNG_O = LS_RESULT-GSMNG_RESULT.
        CONTINUE.
      ENDIF.

      CLEAR LS_2330.
      READ TABLE LT_2330 INTO LS_2330 WITH KEY RQMON = LS_RESULT-RQMON
                                                            ZWKREQ = LS_RESULT-ZWKREQ
                                                            MATNR = LS_RESULT-MATNR.

      APPEND INITIAL LINE TO LT_MODI_2330 ASSIGNING FIELD-SYMBOL(<LS_MODI_2330>).
      MOVE-CORRESPONDING LS_2330 TO <LS_MODI_2330>.
      <LS_MODI_2330>-GSMNG = LS_RESULT-GSMNG.
      <LS_MODI_2330>-ZADDMNG = LS_RESULT-ZADDMNG.

      IF LS_RESULT-PLNUM IS INITIAL. " 계획오더 신규 생성
        CLEAR LS_HEADERDATA.
        CLEAR LV_PLANNEDORDER.
        CLEAR LS_RETURN.

        LS_HEADERDATA-PLDORD_PROFILE  = 'LA'.
        LS_HEADERDATA-ORDER_START_DATE = LS_2330-PSTTR.
        LS_HEADERDATA-ORDER_FIN_DATE = LS_2330-PEDTR.
        LS_HEADERDATA-MATERIAL = LS_2330-MATNR.
        LS_HEADERDATA-PLAN_PLANT = LS_2330-WERKS.
        LS_HEADERDATA-PROD_PLANT = LS_2330-WERKS.
        LS_HEADERDATA-FIRMING_IND = 'X'.
        LS_HEADERDATA-TOTAL_PLORD_QTY = LS_RESULT-GSMNG_RESULT.

        CLEAR : LV_PLANNEDORDER, LS_RETURN.
        CALL FUNCTION 'BAPI_PLANNEDORDER_CREATE'
          EXPORTING
            HEADERDATA   = LS_HEADERDATA
          IMPORTING
            RETURN       = LS_RETURN
            PLANNEDORDER = LV_PLANNEDORDER.

        IF LS_RETURN-TYPE NE 'S'. "성공건에 대해 후행 로직 진행
* 오류 발생으로 테이블 저장 실패
          DELETE TABLE LT_MODI_2330 FROM <LS_MODI_2330>.
          CONTINUE.

        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = ABAP_TRUE.

          <LS_MODI_2330>-PLNUM = LV_PLANNEDORDER.
        ENDIF.
      ELSE. " 계획오더 변경

        CLEAR LV_PLANNEDORDER.
        CLEAR LS_RETURN.
        CLEAR LS_CHG_HEADER.
        CLEAR LS_CHG_HEADERX.

        LV_PLANNEDORDER = LS_2330-PLNUM.
        LS_CHG_HEADER-TOTAL_PLORD_QTY = LS_RESULT-GSMNG_RESULT.
        LS_CHG_HEADERX-TOTAL_PLORD_QTY = ABAP_TRUE.

        CALL FUNCTION 'BAPI_PLANNEDORDER_CHANGE'
          EXPORTING
            PLANNEDORDER = LV_PLANNEDORDER
            HEADERDATA   = LS_CHG_HEADER
            HEADERDATAX  = LS_CHG_HEADERX
          IMPORTING
            RETURN       = LS_RETURN.

        IF LS_RETURN-TYPE NE 'S'. "성공건에 대해 후행 로직 진행
          DELETE TABLE LT_MODI_2330 FROM <LS_MODI_2330>.
          CONTINUE.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = ABAP_TRUE.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF LT_MODI_2330[] IS NOT INITIAL.
      MODIFY ZGTPPT2330 FROM TABLE LT_MODI_2330.
      COMMIT WORK AND WAIT.
    ENDIF.

    IF LT_MODI_2340[] IS NOT INITIAL.
      MODIFY ZGTPPT2340 FROM TABLE LT_MODI_2340.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDIF.

ENDFUNCTION.
