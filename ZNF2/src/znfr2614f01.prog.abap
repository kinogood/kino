*&---------------------------------------------------------------------*
*&  Include           ZNFR2613F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_DEFAULT_PARAMETER
*&---------------------------------------------------------------------*
FORM SET_DEFAULT_PARAMETER .

  GV_REPID = SY-REPID.

  P_ENDMM  = SY-DATLO(6).

ENDFORM.                    " SET_DEFAULT_PARAMETER
*&---------------------------------------------------------------------*
*&      Form  F4HELP_MONTH
*&---------------------------------------------------------------------*
FORM F4HELP_MONTH  USING    PV_MONTH.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH   = SY-DATLO(6)
    IMPORTING
      SELECTED_MONTH = PV_MONTH.

ENDFORM.                    " F4HELP_MONTH
*&---------------------------------------------------------------------*
*&      Form  CHECK_ENDMM
*&---------------------------------------------------------------------*
FORM CHECK_ENDMM .

  IF P_ENDMM IS NOT INITIAL AND
     ( P_ENDMM+4(2) < '01' OR P_ENDMM+4(2) > '12' ).
    MESSAGE E003 WITH '만기월을 점검하십시오.'.
  ENDIF.

ENDFORM.                    " CHECK_ENDMM

*&---------------------------------------------------------------------*
*&      Form  DATA_SELECT
*&---------------------------------------------------------------------*
*       1. 만기월 판매 선물(만기이동으로 생성된 선물) 조회
*       2. 판매수량 = 총수량 - 만기이동수량
*       3. OLDFT 이력을 따라 OUT전표가 있는 상위 OUT 대상 수집
*       4. OUT 대상별 IN전표 금액 계산
*----------------------------------------------------------------------*
FORM DATA_SELECT .

  CLEAR   : GT_OUTTAB, GT_LEAF, GT_TARGET, GT_1051O,
            GT_OLDFT, GT_SHFQ, GT_OUTN, GT_ROWS, GT_TLEAF.
  REFRESH : GT_OUTTAB, GT_LEAF, GT_TARGET, GT_1051O,
            GT_OLDFT, GT_SHFQ, GT_OUTN, GT_ROWS, GT_TLEAF.

*___만기일 From ~ To
  GV_FRDAT(6)   = P_ENDMM.
  GV_FRDAT+6(2) = '01'.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = GV_FRDAT
    IMPORTING
      LAST_DAY_OF_MONTH = GV_TODAT
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.

*___1,2. 만기월 판매 선물 / 판매수량
  PERFORM GET_LEAF_DATA.

  CHECK GT_LEAF[] IS NOT INITIAL.

*___3. 상위 OUT 대상 수집
  PERFORM GET_TARGET_DATA.

  CHECK GT_TARGET[] IS NOT INITIAL.

*___4. ALV 데이터 / IN전표 금액 계산
  PERFORM MAKE_OUTTAB.

ENDFORM.                    " DATA_SELECT
*&---------------------------------------------------------------------*
*&      Form  GET_LEAF_DATA
*&---------------------------------------------------------------------*
*       만기월에 만기가 도래한 선물 중 만기이동으로 생성된 선물
*       (OLDFT 존재) 의 판매수량 계산
*----------------------------------------------------------------------*
FORM GET_LEAF_DATA .

  DATA: LV_TABIX TYPE SY-TABIX.

  SELECT A~NFUTN
         A~BUKRS
         A~REQNO
         A~H_NO1
         A~NFKEY
         A~FCM
         A~ENDAT
         A~EMENG
         A~MEINS
         A~OLDFT
         A~MCTYP
         A~YNFIN
         B~CONNO
    INTO CORRESPONDING FIELDS OF TABLE GT_LEAF
    FROM ZNFT1020 AS A
   INNER JOIN ZNFT1011 AS B
      ON B~REQNO = A~REQNO
     AND B~H_NO1 = A~H_NO1
   INNER JOIN ZNFT1000 AS C
      ON C~CONNO = B~CONNO
   WHERE A~BUKRS EQ P_BUKRS
     AND A~ENDAT BETWEEN GV_FRDAT AND GV_TODAT
     AND A~CONFM IN ('3', '7')        "승인/수정승인
     AND A~YNCAN EQ SPACE
     AND A~OLDFT NE SPACE             "만기이동으로 생성된 선물
     AND A~MCTYP NE 'M'               "Market Carry 중간 채번 제외
     AND A~NFKEY IN S_NFKEY
     AND A~FCM   IN S_FCM
     AND B~CONNO IN S_CONNO
     AND A~REQNO IN S_REQNO
     AND C~PRCTR IN S_PRCTR
     AND C~VKGRP IN S_VKGRP
     AND C~KUNNR IN S_KUNNR
     AND C~NFCTR IN S_NFCTR.

  CHECK SY-SUBRC EQ 0.

  LOOP AT GT_LEAF INTO GS_LEAF.
    LV_TABIX = SY-TABIX.

*   만기이동 수량 (하위 선물 : OLDFT = 해당 선물)
    PERFORM GET_SHIFT_QTY USING    GS_LEAF-NFUTN
                          CHANGING GS_LEAF-SMENG.

*   판매수량 = 만기월 총수량 - 만기이동 수량
    GS_LEAF-SOLDQ = GS_LEAF-EMENG - GS_LEAF-SMENG.

    IF GS_LEAF-SOLDQ LE 0.
      DELETE GT_LEAF INDEX LV_TABIX.
      CONTINUE.
    ENDIF.

    MODIFY GT_LEAF FROM GS_LEAF INDEX LV_TABIX.
  ENDLOOP.

ENDFORM.                    " GET_LEAF_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_SHIFT_QTY
*&---------------------------------------------------------------------*
*       선물의 만기이동 수량 (OLDFT 로 연결된 하위 선물 수량 합계)
*       - 유효한 하위 선물 (YNCAN = ' ')
*       - 이후 다시 만기이동/분할되어 취소된 하위 선물도 포함
*         (WHYCN '1' 만기이동, '2' 분할 : 수량은 그대로 이어짐)
*       - 사용자 취소 등 기타 사유로 취소된 하위 선물은 제외
*----------------------------------------------------------------------*
FORM GET_SHIFT_QTY  USING    PV_NFUTN
                    CHANGING PV_MENG.

  CLEAR : PV_MENG.

  READ TABLE GT_SHFQ INTO GS_SHFQ WITH TABLE KEY NFUTN = PV_NFUTN.

  IF SY-SUBRC NE 0.
    CLEAR : GS_SHFQ.
    GS_SHFQ-NFUTN = PV_NFUTN.

    SELECT SUM( EMENG )
      INTO GS_SHFQ-EMENG
      FROM ZNFT1020
     WHERE BUKRS EQ P_BUKRS
       AND OLDFT EQ PV_NFUTN
       AND ( YNCAN EQ SPACE OR
           ( YNCAN EQ 'X' AND WHYCN IN ('1', '2') ) ).

    INSERT GS_SHFQ INTO TABLE GT_SHFQ.
  ENDIF.

  PV_MENG = GS_SHFQ-EMENG.

ENDFORM.                    " GET_SHIFT_QTY
*&---------------------------------------------------------------------*
*&      Form  GET_OLDFT
*&---------------------------------------------------------------------*
*       상위 선물집행번호(이력번호)
*----------------------------------------------------------------------*
FORM GET_OLDFT  USING    PV_NFUTN
                CHANGING PV_OLDFT.

  CLEAR : PV_OLDFT.

  READ TABLE GT_OLDFT INTO GS_OLDFT WITH TABLE KEY NFUTN = PV_NFUTN.

  IF SY-SUBRC NE 0.
    CLEAR : GS_OLDFT.
    GS_OLDFT-NFUTN = PV_NFUTN.

    SELECT SINGLE OLDFT
      INTO GS_OLDFT-OLDFT
      FROM ZNFT1020
     WHERE NFUTN EQ PV_NFUTN.

    INSERT GS_OLDFT INTO TABLE GT_OLDFT.
  ENDIF.

  PV_OLDFT = GS_OLDFT-OLDFT.

ENDFORM.                    " GET_OLDFT
*&---------------------------------------------------------------------*
*&      Form  GET_OUT_DOC
*&---------------------------------------------------------------------*
*       OUT 대상 신규집행의 OUT전표 생성분 (ZNFT1051-ZBELNR) 조회 - Cache
*----------------------------------------------------------------------*
FORM GET_OUT_DOC  USING    PV_NFUTN.

  DATA: LT_1051 TYPE TABLE OF ZNFT1051,
        LS_1051 TYPE ZNFT1051.

  READ TABLE GT_OUTN TRANSPORTING NO FIELDS
                     WITH TABLE KEY NFUTN = PV_NFUTN.
  CHECK SY-SUBRC NE 0.

  CLEAR : GS_OUTN.
  GS_OUTN-NFUTN = PV_NFUTN.

  SELECT *
    INTO TABLE LT_1051
    FROM ZNFT1051
   WHERE BUKRS  EQ P_BUKRS
     AND NFUTN  EQ PV_NFUTN
     AND ZBELNR NE SPACE.

  LOOP AT LT_1051 INTO LS_1051.
    GS_OUTN-EMENG = GS_OUTN-EMENG + LS_1051-EMENG.
    INSERT LS_1051 INTO TABLE GT_1051O.
  ENDLOOP.

* OUT 대상의 만기이동 수량 (OUT전표 수량 검증용)
  IF LT_1051[] IS NOT INITIAL.
    PERFORM GET_SHIFT_QTY USING    PV_NFUTN
                          CHANGING GS_OUTN-SMENG.
  ENDIF.

  INSERT GS_OUTN INTO TABLE GT_OUTN.

ENDFORM.                    " GET_OUT_DOC
*&---------------------------------------------------------------------*
*&      Form  GET_TARGET_DATA
*&---------------------------------------------------------------------*
*       판매 선물의 상위 이력(OLDFT)을 따라가며 OUT전표가 있는 OUT 대상을
*       IN전표 대상으로 집계 (동일 OUT 대상은 판매수량 합산)
*----------------------------------------------------------------------*
FORM GET_TARGET_DATA .

  DATA: LT_ANC     LIKE TABLE OF ZNFT1020-NFUTN,
        LV_NODE    LIKE ZNFT1020-NFUTN,
        LV_NEXT    LIKE ZNFT1020-NFUTN,
        LV_SUPREME LIKE ZNFT1020-NFUTN,
        LS_1051    TYPE ZNFT1051.

  FIELD-SYMBOLS: <LS_TARGET> LIKE GS_TARGET.

  LOOP AT GT_LEAF INTO GS_LEAF.

*___상위 이력 수집 (판매 선물 자신은 제외)
    CLEAR   : LT_ANC, LV_SUPREME.
    REFRESH : LT_ANC.

    LV_SUPREME = GS_LEAF-NFUTN.
    LV_NODE    = GS_LEAF-OLDFT.

    DO 99 TIMES.
      IF LV_NODE IS INITIAL.
        EXIT.
      ENDIF.

*     순환참조 방지
      READ TABLE LT_ANC TRANSPORTING NO FIELDS
                        WITH KEY TABLE_LINE = LV_NODE.
      IF SY-SUBRC EQ 0.
        EXIT.
      ENDIF.

      APPEND LV_NODE TO LT_ANC.
      LV_SUPREME = LV_NODE.

      PERFORM GET_OLDFT USING    LV_NODE
                        CHANGING LV_NEXT.
      LV_NODE = LV_NEXT.
    ENDDO.

*___OUT 대상별 → IN전표 대상
    LOOP AT LT_ANC INTO LV_NODE.

      PERFORM GET_OUT_DOC USING LV_NODE.

      LOOP AT GT_1051O INTO LS_1051 WHERE NFUTN = LV_NODE.

        READ TABLE GT_TARGET ASSIGNING <LS_TARGET>
                             WITH TABLE KEY NFUTN = LS_1051-NFUTN
                                            CFUTN = LS_1051-CFUTN.
        IF SY-SUBRC NE 0.
          CLEAR : GS_TARGET.
          GS_TARGET-NFUTN = LS_1051-NFUTN.
          GS_TARGET-CFUTN = LS_1051-CFUTN.
          INSERT GS_TARGET INTO TABLE GT_TARGET ASSIGNING <LS_TARGET>.
        ENDIF.

        <LS_TARGET>-SUPREME = LV_SUPREME.
        <LS_TARGET>-SOLDQ   = <LS_TARGET>-SOLDQ   + GS_LEAF-SOLDQ.
        <LS_TARGET>-L_EMENG = <LS_TARGET>-L_EMENG + GS_LEAF-EMENG.
        <LS_TARGET>-L_SMENG = <LS_TARGET>-L_SMENG + GS_LEAF-SMENG.
        <LS_TARGET>-L_CNT   = <LS_TARGET>-L_CNT   + 1.

        IF <LS_TARGET>-L_NFUTN IS INITIAL.
          <LS_TARGET>-L_NFUTN = GS_LEAF-NFUTN.
          <LS_TARGET>-L_ENDAT = GS_LEAF-ENDAT.
          <LS_TARGET>-L_YNFIN = GS_LEAF-YNFIN.
        ENDIF.

*       판매 선물 목록 (판매선물 건수 더블클릭 팝업용)
        CLEAR : GS_TLEAF.
        GS_TLEAF-NFUTN   = LS_1051-NFUTN.
        GS_TLEAF-CFUTN   = LS_1051-CFUTN.
        GS_TLEAF-L_NFUTN = GS_LEAF-NFUTN.
        GS_TLEAF-L_ENDAT = GS_LEAF-ENDAT.
        GS_TLEAF-L_YNFIN = GS_LEAF-YNFIN.
        GS_TLEAF-L_EMENG = GS_LEAF-EMENG.
        GS_TLEAF-L_SMENG = GS_LEAF-SMENG.
        GS_TLEAF-SOLDQ   = GS_LEAF-SOLDQ.
        GS_TLEAF-MEINS   = GS_LEAF-MEINS.
        APPEND GS_TLEAF TO GT_TLEAF.

      ENDLOOP.
    ENDLOOP.

  ENDLOOP.

ENDFORM.                    " GET_TARGET_DATA
*&---------------------------------------------------------------------*
*&      Form  MAKE_OUTTAB
*&---------------------------------------------------------------------*
FORM MAKE_OUTTAB .

  DATA: LS_1051 TYPE ZNFT1051.

  LOOP AT GT_TARGET INTO GS_TARGET.

    CLEAR : GS_OUTTAB, LS_1051, GS_OUTN.

    READ TABLE GT_1051O INTO LS_1051
                        WITH TABLE KEY NFUTN = GS_TARGET-NFUTN
                                       CFUTN = GS_TARGET-CFUTN.
    CHECK SY-SUBRC EQ 0.

    READ TABLE GT_OUTN INTO GS_OUTN
                       WITH TABLE KEY NFUTN = GS_TARGET-NFUTN.

*___OUT 대상 정보
    GS_OUTTAB-BUKRS   = LS_1051-BUKRS.
    GS_OUTTAB-BUKRS_NM = GV_BUTXT.
    GS_OUTTAB-PRCTR   = LS_1051-PRCTR.
    GS_OUTTAB-VKGRP   = LS_1051-VKGRP.
    GS_OUTTAB-KUNNR   = LS_1051-KUNNR.
    GS_OUTTAB-CONNO   = LS_1051-CONNO.
    GS_OUTTAB-REQNO   = LS_1051-REQNO.
    GS_OUTTAB-H_NO1   = LS_1051-H_NO1.
    GS_OUTTAB-NFKEY   = LS_1051-NFKEY.
    GS_OUTTAB-FCM     = LS_1051-FCM.
    GS_OUTTAB-NFUTN   = LS_1051-NFUTN.
    GS_OUTTAB-CFUTN   = LS_1051-CFUTN.
    GS_OUTTAB-ENDAT   = LS_1051-ENDAT.
    GS_OUTTAB-EMENG   = LS_1051-EMENG.
    GS_OUTTAB-MEINS   = LS_1051-MEINS.
    GS_OUTTAB-KPRLO   = LS_1051-KPRLO.
    GS_OUTTAB-KAERS   = LS_1051-KAERS.
    GS_OUTTAB-ZBELNR  = LS_1051-ZBELNR.
    GS_OUTTAB-ZGJAHR  = LS_1051-ZGJAHR.
    GS_OUTTAB-N_EMENG = GS_OUTN-EMENG.
    GS_OUTTAB-N_SMENG = GS_OUTN-SMENG.
    GS_OUTTAB-NBY_SL  = LS_1051-NBY_SL.
    GS_OUTTAB-UPRLO   = LS_1051-UPRLO.
    GS_OUTTAB-UAERS   = LS_1051-UAERS.
    GS_OUTTAB-KURSF   = LS_1051-KURSF.
    GS_OUTTAB-NMISPD  = LS_1051-NMISPD.
    GS_OUTTAB-NPRICE  = LS_1051-NPRICE.
    GS_OUTTAB-N_FEE   = LS_1051-N_FEE.
    GS_OUTTAB-CMISPD  = LS_1051-CMISPD.
    GS_OUTTAB-CPRICE  = LS_1051-CPRICE.
    GS_OUTTAB-C_FEE   = LS_1051-C_FEE.
    GS_OUTTAB-WAERS   = LS_1051-WAERS.

    IF GS_OUTTAB-KAERS IS INITIAL.
      GS_OUTTAB-KAERS = 'KRW'.
    ENDIF.

*___판매 선물 정보
    GS_OUTTAB-SUPREME = GS_TARGET-SUPREME.

*___집행일 (최상위 / OUT 대상 신규·청산)
    SELECT SINGLE RUDAT
      INTO GS_OUTTAB-SUP_RUDAT
      FROM ZNFT1020
     WHERE NFUTN EQ GS_OUTTAB-SUPREME.

    SELECT SINGLE RUDAT
      INTO GS_OUTTAB-N_RUDAT
      FROM ZNFT1020
     WHERE NFUTN EQ GS_OUTTAB-NFUTN.

    SELECT SINGLE RUDAT
      INTO GS_OUTTAB-C_RUDAT
      FROM ZNFT1030
     WHERE CFUTN EQ GS_OUTTAB-CFUTN.

*___Buy / Sell 구분 (ZNFR2612 동일)
    PERFORM SET_BUY_SELL.

*___선물요청유형
    SELECT SINGLE RQTYP
      INTO GS_OUTTAB-RQTYP
      FROM ZNFT1010
     WHERE REQNO EQ GS_OUTTAB-REQNO.

    PERFORM DOMAIN_VALUE_GET USING 'ZRQTYP_1'
                                   GS_OUTTAB-RQTYP
                                   GS_OUTTAB-RQTYP_NM.
    GS_OUTTAB-L_NFUTN = GS_TARGET-L_NFUTN.
    GS_OUTTAB-L_CNT   = GS_TARGET-L_CNT.
    GS_OUTTAB-L_ENDAT = GS_TARGET-L_ENDAT.
    GS_OUTTAB-L_YNFIN = GS_TARGET-L_YNFIN.
    GS_OUTTAB-L_EMENG = GS_TARGET-L_EMENG.
    GS_OUTTAB-L_SMENG = GS_TARGET-L_SMENG.
    GS_OUTTAB-S_EMENG = GS_TARGET-SOLDQ.

*___계약 정보
    SELECT SINGLE NFCTR NCUST COTXT SALER
      INTO (GS_OUTTAB-NFCTR, GS_OUTTAB-NCUST,
            GS_OUTTAB-COTXT, GS_OUTTAB-SALER)
      FROM ZNFT1000
     WHERE CONNO EQ GS_OUTTAB-CONNO.

*   사업부
    PERFORM GET_NFCTR_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-NFCTR
                                 GS_OUTTAB-NFCTR_NM.

*   손익센터
    PERFORM GET_PRCTR_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-PRCTR
                                 GS_OUTTAB-PRCTR_NM.

*   영업그룹
    PERFORM GET_VKGRP_DESC USING GS_OUTTAB-BUKRS
                                 GS_OUTTAB-VKGRP
                                 GS_OUTTAB-VKGRP_NM.

*   고객
    IF GS_OUTTAB-NCUST IS INITIAL.
      PERFORM GET_KUNNR_DESC USING GS_OUTTAB-KUNNR
                                   GS_OUTTAB-NCUST.
    ENDIF.

*   FCM
    PERFORM GET_LIFNR_DESC USING GS_OUTTAB-FCM
                                 GS_OUTTAB-FCM_NM.

*___IN전표 금액 계산
    PERFORM CALC_IN_AMOUNT.

*___처리구분
    IF P_R01 EQ 'X' AND GS_OUTTAB-YBELNR IS NOT INITIAL.
      CONTINUE.
    ELSEIF P_R02 EQ 'X' AND GS_OUTTAB-YBELNR IS INITIAL.
      CONTINUE.
    ENDIF.

    APPEND GS_OUTTAB TO GT_OUTTAB.
  ENDLOOP.

  SORT GT_OUTTAB BY NFCTR PRCTR VKGRP SUPREME NFUTN CFUTN.

* 오류 라인 색상
  PERFORM SET_CELL_ATTRIBUTE.

ENDFORM.                    " MAKE_OUTTAB
*&---------------------------------------------------------------------*
*&      Form  SET_BUY_SELL
*&---------------------------------------------------------------------*
*       신규집행 Buy/Sell 에 따라 Buy/Sell 집행번호·단가·금액 (ZNFR2612 동일)
*----------------------------------------------------------------------*
FORM SET_BUY_SELL .

  CASE GS_OUTTAB-NBY_SL.
    WHEN 'B'.
*     ### BUY ###
      GS_OUTTAB-B_NFUTN  = GS_OUTTAB-NFUTN.      " Buy  집행번호
      GS_OUTTAB-B_RUDAT  = GS_OUTTAB-N_RUDAT.    " Buy  집행일
      GS_OUTTAB-B_MISPD  = GS_OUTTAB-NMISPD.
      GS_OUTTAB-B_PRICE  = GS_OUTTAB-NPRICE.
      GS_OUTTAB-BUY_AMT  = GS_OUTTAB-EMENG *
                         ( GS_OUTTAB-NPRICE + GS_OUTTAB-NMISPD ).
      GS_OUTTAB-B_FEE    = GS_OUTTAB-N_FEE.
*     ### SELL ###
      GS_OUTTAB-S_NFUTN  = GS_OUTTAB-CFUTN.      " Sell 집행번호
      GS_OUTTAB-S_RUDAT  = GS_OUTTAB-C_RUDAT.    " Sell 집행일
      GS_OUTTAB-S_MISPD  = GS_OUTTAB-CMISPD.
      GS_OUTTAB-S_PRICE  = GS_OUTTAB-CPRICE.
      GS_OUTTAB-SELL_AMT = GS_OUTTAB-EMENG *
                         ( GS_OUTTAB-CPRICE + GS_OUTTAB-CMISPD ).
      GS_OUTTAB-S_FEE    = GS_OUTTAB-C_FEE.
    WHEN 'S'.
*     ### BUY ###
      GS_OUTTAB-B_NFUTN  = GS_OUTTAB-CFUTN.      " Buy  집행번호
      GS_OUTTAB-B_RUDAT  = GS_OUTTAB-C_RUDAT.    " Buy  집행일
      GS_OUTTAB-B_MISPD  = GS_OUTTAB-CMISPD.
      GS_OUTTAB-B_PRICE  = GS_OUTTAB-CPRICE.
      GS_OUTTAB-BUY_AMT  = GS_OUTTAB-EMENG *
                         ( GS_OUTTAB-CPRICE + GS_OUTTAB-CMISPD ).
      GS_OUTTAB-B_FEE    = GS_OUTTAB-C_FEE.
*     ### SELL ###
      GS_OUTTAB-S_NFUTN  = GS_OUTTAB-NFUTN.      " Sell 집행번호
      GS_OUTTAB-S_RUDAT  = GS_OUTTAB-N_RUDAT.    " Sell 집행일
      GS_OUTTAB-S_MISPD  = GS_OUTTAB-NMISPD.
      GS_OUTTAB-S_PRICE  = GS_OUTTAB-NPRICE.
      GS_OUTTAB-SELL_AMT = GS_OUTTAB-EMENG *
                         ( GS_OUTTAB-NPRICE + GS_OUTTAB-NMISPD ).
      GS_OUTTAB-S_FEE    = GS_OUTTAB-N_FEE.
  ENDCASE.

ENDFORM.                    " SET_BUY_SELL
*&---------------------------------------------------------------------*
*&      Form  CALC_IN_AMOUNT
*&---------------------------------------------------------------------*
*       IN금액 = OUT손익 * 판매수량 / OUT 대상 OUT전표 수량
*       - 기존 IN전표(ZNFT1055, 타월) 누계/누적비율 차감
*       - 누적비율 100% 도달 시 잔액 전액 반영 (단수차이)
*       - 당월 IN전표가 이미 있으면 생성완료로 표시
*----------------------------------------------------------------------*
FORM CALC_IN_AMOUNT .

  DATA: LT_1055 TYPE TABLE OF ZNFT1055,
        LS_1055 TYPE ZNFT1055,
        LV_CALC TYPE P LENGTH 16 DECIMALS 6,
        LV_RATE TYPE P LENGTH 16 DECIMALS 6,
        LV_ABS1 LIKE ZNFT1055-KPRLO,
        LV_ABS2 LIKE ZNFT1055-KPRLO.

  CLEAR : GS_OUTTAB-TKPRLO, GS_OUTTAB-TKRATE,
          GS_OUTTAB-P_KPRLO, GS_OUTTAB-KRATE,
          GS_OUTTAB-YBELNR, GS_OUTTAB-YGJAHR,
          GS_OUTTAB-I_HNO1,  GS_OUTTAB-BUDAT,
          GS_OUTTAB-REMON,   GS_OUTTAB-MSG.

*___기존 IN전표 (OUT전표 기준)
  SELECT *
    INTO TABLE LT_1055
    FROM ZNFT1055
   WHERE NFUTN  EQ GS_OUTTAB-NFUTN
     AND CFUTN  EQ GS_OUTTAB-CFUTN
     AND ZBELNR EQ GS_OUTTAB-ZBELNR
     AND ZGJAHR EQ GS_OUTTAB-ZGJAHR
     AND YBELNR NE SPACE.

  SORT LT_1055 BY H_NO1.

  LOOP AT LT_1055 INTO LS_1055.
    IF LS_1055-REMON EQ P_ENDMM.
*     당월 IN전표 (생성완료)
      GS_OUTTAB-P_KPRLO = GS_OUTTAB-P_KPRLO + LS_1055-KPRLO.
      GS_OUTTAB-KRATE   = GS_OUTTAB-KRATE   + LS_1055-KRATE.
      GS_OUTTAB-I_HNO1  = LS_1055-H_NO1.
      GS_OUTTAB-YBELNR = LS_1055-YBELNR.
      GS_OUTTAB-YGJAHR = LS_1055-YGJAHR.
      GS_OUTTAB-BUDAT   = LS_1055-BUDAT.
      GS_OUTTAB-REMON   = LS_1055-REMON.
    ELSE.
*     타월 IN전표 누계
      GS_OUTTAB-TKPRLO = GS_OUTTAB-TKPRLO + LS_1055-KPRLO.
      GS_OUTTAB-TKRATE = GS_OUTTAB-TKRATE + LS_1055-KRATE.
    ENDIF.
  ENDLOOP.

*___생성완료
  IF GS_OUTTAB-YBELNR IS NOT INITIAL.
    GS_OUTTAB-T_KRATE = GS_OUTTAB-TKRATE + GS_OUTTAB-KRATE.
    GS_OUTTAB-R_KPRLO = GS_OUTTAB-KPRLO - GS_OUTTAB-TKPRLO
                                        - GS_OUTTAB-P_KPRLO.
    GS_OUTTAB-ICON    = GC_ICON_GREEN.
    GS_OUTTAB-STATUS  = '생성완료'.
    EXIT.
  ENDIF.

*___생성대상 : 금액 계산
  GS_OUTTAB-ICON   = GC_ICON_YELLOW.
  GS_OUTTAB-STATUS = '생성대상'.

  IF GS_OUTTAB-N_EMENG LE 0.
    GS_OUTTAB-ICON   = GC_ICON_RED.
    GS_OUTTAB-STATUS = '오류'.
    GS_OUTTAB-MSG    = 'OUT전표 수량이 없습니다.'.
    EXIT.
  ENDIF.

* 금회 비율(%)
  LV_RATE = GS_OUTTAB-S_EMENG * 100 / GS_OUTTAB-N_EMENG.
  GS_OUTTAB-KRATE   = LV_RATE.
  GS_OUTTAB-T_KRATE = GS_OUTTAB-TKRATE + GS_OUTTAB-KRATE.

* 금회 IN 금액
  LV_CALC = GS_OUTTAB-KPRLO * GS_OUTTAB-S_EMENG / GS_OUTTAB-N_EMENG.
  GS_OUTTAB-P_KPRLO = LV_CALC.

* 누적비율 100% 도달 → 잔액 전액 반영 (단수차이 정리)
  IF GS_OUTTAB-T_KRATE GE GC_FULL_RATE.
    GS_OUTTAB-P_KPRLO = GS_OUTTAB-KPRLO - GS_OUTTAB-TKPRLO.
    IF GS_OUTTAB-T_KRATE LE 100.
      GS_OUTTAB-KRATE   = 100 - GS_OUTTAB-TKRATE.
      GS_OUTTAB-T_KRATE = 100.
    ENDIF.
  ENDIF.

  GS_OUTTAB-R_KPRLO = GS_OUTTAB-KPRLO - GS_OUTTAB-TKPRLO
                                      - GS_OUTTAB-P_KPRLO.

*___검증
* OUT 대상의 만기이동 수량과 OUT전표 수량 불일치 (OUT전표 미생성분 존재)
  IF GS_OUTTAB-N_SMENG NE GS_OUTTAB-N_EMENG.
    GS_OUTTAB-ICON   = GC_ICON_RED.
    GS_OUTTAB-STATUS = '오류'.
    GS_OUTTAB-MSG    = '만기이동수량과 OUT전표수량이 다릅니다(ZNFR2611 확인)'.
    EXIT.
  ENDIF.

* 누적비율 100% 초과
  IF GS_OUTTAB-T_KRATE GT 100.
    GS_OUTTAB-ICON   = GC_ICON_RED.
    GS_OUTTAB-STATUS = '오류'.
    GS_OUTTAB-MSG    = '누적비율이 100%를 초과합니다.'.
    EXIT.
  ENDIF.

* 금액 초과 (기존 IN + 금회 IN > OUT 손익)
  LV_ABS1 = ABS( GS_OUTTAB-TKPRLO + GS_OUTTAB-P_KPRLO ).
  LV_ABS2 = ABS( GS_OUTTAB-KPRLO ).
  IF LV_ABS1 GT LV_ABS2.
    GS_OUTTAB-ICON   = GC_ICON_RED.
    GS_OUTTAB-STATUS = '오류'.
    GS_OUTTAB-MSG    = 'IN전표 누계가 OUT손익을 초과합니다.'.
    EXIT.
  ENDIF.

* 전표금액 0
  IF GS_OUTTAB-P_KPRLO EQ 0.
    GS_OUTTAB-ICON   = GC_ICON_RED.
    GS_OUTTAB-STATUS = '오류'.
    GS_OUTTAB-MSG    = 'IN전표 금액이 0 입니다.'.
    EXIT.
  ENDIF.

ENDFORM.                    " CALC_IN_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .

* Create Object : GRF_CONTAINER (Docking - 화면 1100 전체)
  CREATE OBJECT GRF_CONTAINER
    EXPORTING
      REPID     = GV_REPID
      DYNNR     = '1100'
      SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
      EXTENSION = 3000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.

* Create Object : GRF_GRID
  CREATE OBJECT GRF_GRID
    EXPORTING
      I_PARENT      = GRF_CONTAINER
      I_APPL_EVENTS = 'X'.

ENDFORM.                    " CREATE_OBJECT
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA : LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
FORM SET_GRID_LAYOUT .

  GS_LAYOUT-SEL_MODE   = 'A'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT-CTAB_FNAME = 'COLINFO'.
  GS_LAYOUT-NO_ROWINS  = 'X'.

ENDFORM.                    " SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_SORT
*&---------------------------------------------------------------------*
FORM SET_GRID_SORT .

  CLEAR : GS_SORT, GT_SORT.
  REFRESH GT_SORT.

  PERFORM APPEND_SORT USING : '1' 'NFCTR'    'X',
                              '2' 'NFCTR_NM' 'X',
                              '3' 'PRCTR'    'X',
                              '4' 'PRCTR_NM' 'X',
                              '5' 'VKGRP'    'X',
                              '6' 'VKGRP_NM' 'X'.

ENDFORM.                    " SET_GRID_SORT
*&---------------------------------------------------------------------*
*&      Form  APPEND_SORT
*&---------------------------------------------------------------------*
FORM APPEND_SORT  USING PV_SPOS
                        PV_FIELDNAME
                        PV_SUBTOT.

  CLEAR : GS_SORT.

  GS_SORT-SPOS      = PV_SPOS.
  GS_SORT-FIELDNAME = PV_FIELDNAME.
  GS_SORT-UP        = 'X'.
  GS_SORT-SUBTOT    = PV_SUBTOT.
  APPEND GS_SORT TO GT_SORT.

ENDFORM.                    " APPEND_SORT
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
FORM SET_GRID_FIELDCATALOG .

  CLEAR   : GT_FIELDCAT.
  REFRESH : GT_FIELDCAT.

  PERFORM SET_FIELDCAT USING:
    'ICON'      ''                   '4'   'C'  ' '     ,
    'STATUS'    '처리상태'           '8'   'C'  ' '     ,
    'MSG'       '메시지'             '30'  'L'  ' '     ,
    'BUKRS'     '회사코드'           '10'  'C'  ' '     ,
    'BUKRS_NM'  '회사명'             '10'  'L'  ' '     ,
    'NFCTR'     '사업부'             '10'  'C'  'ALPHA' ,
    'NFCTR_NM'  '사업부명'           '10'  'L'  ' '     ,
    'PRCTR'     '손익센터'           '10'  'C'  'ALPHA' ,
    'PRCTR_NM'  '손익센터명'         '10'  'L'  ' '     ,
    'VKGRP'     '영업그룹'           '10'  'C'  'ALPHA' ,
    'VKGRP_NM'  '영업그룹명'         '10'  'L'  ' '     ,
    'KUNNR'     '고  객'             '10'  'C'  'ALPHA' ,
    'NCUST'     '고객명'             '20'  'L'  ' '     ,
    'REQNO'     '요청번호'           '10'  'L'  ' '     ,
    'H_NO1'     '항번'               '10'  'C'  ' '     ,
    'CONNO'     '계약번호'           '10'  'L'  ' '     ,
    'COTXT'     '계약명'             '20'  'L'  ' '     ,
    'RQTYP'     '선물요청유형'       '10'  'C'  ' '     ,
    'RQTYP_NM'  '선물요청유형'       '10'  'C'  ' '     ,
    'SUPREME'   '최상위 집행번호'    '12'  'L'  ' '     ,
    'SUP_RUDAT' '최상위 집행일'      '10'  'C'  ' '     ,
    'NFUTN'     'OUT 대상 신규집행'  '12'  'L'  ' '     ,
    'N_RUDAT'   'OUT 대상 신규집행일' '10' 'C'  ' '     ,
    'CFUTN'     'OUT 대상 청산집행'  '12'  'L'  ' '     ,
    'C_RUDAT'   'OUT 대상 청산집행일' '10' 'C'  ' '     ,
    'NBY_SL'    '신규 Buy/Sell'      '4'   'C'  ' '     ,
    'B_NFUTN'   'Buy 집행번호'       '12'  'L'  ' '     ,
    'B_RUDAT'   'Buy 집행일'         '10'  'C'  ' '     ,
    'S_NFUTN'   'Sell 집행번호'      '12'  'L'  ' '     ,
    'S_RUDAT'   'Sell 집행일'        '10'  'C'  ' '     ,
    'FCM'       'FCM'                '5'   'C'  'ALPHA' ,
    'FCM_NM'    'FCM명'              '20'  'L'  ' '     ,
    'ENDAT'     '만기일'             '10'  'C'  ' '     ,
    'EMENG'     '집행량'             '10'  'R'  ' '     ,
    'N_EMENG'   'OUT 대상 수량 계'   '12'  'R'  ' '     ,
    'N_SMENG'   'OUT 대상 이동수량'  '12'  'R'  ' '     ,
    'MEINS'     '단위'               '10'  'C'  ' '     ,
    'NFKEY'     '비철구분'           '10'  'C'  ' '     ,
    'KPRLO'     '선물손익(원화)'     '15'  'R'  ' '     ,
    'KAERS'     '통화'               '5'   'C'  ' '     ,
    'UPRLO'     '선물손익(외화)'     '15'  'R'  ' '     ,
    'UAERS'     '통화'               '5'   'C'  ' '     ,
    'KURSF'     '적용환율'           '12'  'R'  ' '     ,
    'ZBELNR'    'MC회계전표'         '12'  'R'  ' '     ,
    'ZGJAHR'    'MC회계년도'         '12'  'R'  ' '     ,
*   ### 판매 선물 ###
    'L_NFUTN'   '판매 선물집행번호'  '12'  'L'  ' '     ,
    'L_CNT'     '판매선물 건수'      '5'   'R'  ' '     ,
    'L_ENDAT'   '판매 만기일'        '10'  'C'  ' '     ,
    'L_YNFIN'   '정산여부'           '4'   'C'  ' '     ,
    'L_EMENG'   '만기월 총수량'      '12'  'R'  ' '     ,
    'L_SMENG'   '만기이동 수량'      '12'  'R'  ' '     ,
    'S_EMENG'   '판매수량(IN대상)'   '12'  'R'  ' '     ,
*   ### IN전표 (ZNFR2612 명칭) ###
    'YBELNR'    '귀속회계전표'       '12'  'R'  ' '     ,
    'YGJAHR'    '귀속회계년도'       '12'  'R'  ' '     ,
    'REMON'     '귀속년월'           '6'   'C'  ' '     ,
    'BUDAT'     '전기일'             '10'  'C'  ' '     ,
    'P_KPRLO'   '귀속 선물손익(원화)' '15' 'R'  ' '     ,
    'KRATE'     '비율(%)'            '3'   'R'  ' '     ,
    'TKRATE'    '전체비율(%)'        '3'   'R'  ' '     ,
    'T_KRATE'   '반영후누적비율(%)'  '8'   'R'  ' '     ,
    'TKPRLO'    '전체 IN금액'        '15'  'R'  ' '     ,
    'R_KPRLO'   '반영후 잔액'        '15'  'R'  ' '     ,
*   ### Buy / Sell 상세 (ZNFR2612 동일) ###
    'B_MISPD'   'Buy Spread'         '12'  'R'  ' '     ,
    'B_PRICE'   'Buy 단가'           '10'  'R'  ' '     ,
    'BUY_AMT'   'Buy 금액'           '12'  'R'  ' '     ,
    'B_FEE'     'Buy 수수료'         '10'  'R'  ' '     ,
    'S_MISPD'   'Sell Spread'        '12'  'R'  ' '     ,
    'S_PRICE'   'Sell 단가'          '10'  'R'  ' '     ,
    'SELL_AMT'  'Sell 금액'          '12'  'R'  ' '     ,
    'S_FEE'     'Sell 수수료'        '10'  'R'  ' '     ,
    'WAERS'     '통화'               '5'   'C'  ' '     ,
    'SALER'     '영업담당자'         '10'  'C'  ' '     .

ENDFORM.                    " SET_GRID_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT  USING  P_FIELDNAME
                          P_COLTEXT
                          P_OUTPUTLEN
                          P_JUST
                          P_CONVEXIT.

  CLEAR GS_FIELDCAT.

  GS_FIELDCAT-FIELDNAME  = P_FIELDNAME .
  GS_FIELDCAT-COLTEXT    = P_COLTEXT   .
  GS_FIELDCAT-OUTPUTLEN  = P_OUTPUTLEN .
  GS_FIELDCAT-JUST       = P_JUST      .
  GS_FIELDCAT-CONVEXIT   = P_CONVEXIT  .

  CASE P_FIELDNAME.
    WHEN 'ICON'.
      GS_FIELDCAT-ICON       = 'X'.
      GS_FIELDCAT-KEY        = 'X'.
    WHEN 'BUKRS' OR 'BUKRS_NM' OR 'RQTYP' OR 'SALER'.  "ZNFR2612 동일
      GS_FIELDCAT-NO_OUT     = 'X'.
    WHEN 'NFUTN' OR 'N_RUDAT' OR 'CFUTN' OR 'C_RUDAT' OR 'NBY_SL'.
      GS_FIELDCAT-TECH       = 'X'.           "Buy/Sell 집행번호로 표시
    WHEN 'B_MISPD' OR 'B_PRICE' OR 'B_FEE' OR
         'S_MISPD' OR 'S_PRICE' OR 'S_FEE' OR
         'BUY_AMT' OR 'SELL_AMT'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
    WHEN 'KPRLO'.
      GS_FIELDCAT-CFIELDNAME = 'KAERS'.
    WHEN 'UPRLO'.
      GS_FIELDCAT-CFIELDNAME = 'UAERS'.
    WHEN 'KURSF'.
      GS_FIELDCAT-DECIMALS   = 2.
      GS_FIELDCAT-DECIMALS_O = 2.
    WHEN 'TKPRLO' OR 'P_KPRLO' OR 'R_KPRLO'.
      GS_FIELDCAT-CFIELDNAME = 'KAERS'.
      GS_FIELDCAT-DO_SUM     = 'X'.
      GS_FIELDCAT-EMPHASIZE  = 'C300'.
    WHEN 'EMENG' OR 'L_EMENG' OR 'L_SMENG'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS'.
    WHEN 'L_NFUTN' OR 'L_ENDAT' OR 'L_YNFIN'. "판매선물 건수 더블클릭으로 조회
      GS_FIELDCAT-TECH       = 'X'.
    WHEN 'N_EMENG' OR 'N_SMENG'.          "내부 계산·검증용 (화면 비표시)
      GS_FIELDCAT-QFIELDNAME = 'MEINS'.
      GS_FIELDCAT-TECH       = 'X'.
    WHEN 'S_EMENG'.
      GS_FIELDCAT-QFIELDNAME = 'MEINS'.
      GS_FIELDCAT-EMPHASIZE  = 'C300'.
  ENDCASE.

  APPEND GS_FIELDCAT TO GT_FIELDCAT.

ENDFORM.                    " SET_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE .

* 오류 라인 색상 표시
  DATA : LS_COLOR TYPE LVC_S_SCOL,
         L_INDEX  TYPE I.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    L_INDEX = SY-TABIX.

    CLEAR : GS_OUTTAB-COLINFO.

    IF GS_OUTTAB-ICON EQ GC_ICON_RED.
      CLEAR LS_COLOR.
      LS_COLOR-FNAME     = 'MSG'.
      LS_COLOR-COLOR-COL = 6.
      LS_COLOR-COLOR-INT = 0.
      INSERT LS_COLOR INTO TABLE GS_OUTTAB-COLINFO.
    ENDIF.

    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX L_INDEX
                     TRANSPORTING COLINFO.
  ENDLOOP.

ENDFORM.                    " SET_CELL_ATTRIBUTE
*&---------------------------------------------------------------------*
*&      Form  SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
FORM SET_EVENT_HANDLER .

  CREATE OBJECT GRF_EVENT_HANDLER.

  SET HANDLER :
    GRF_EVENT_HANDLER->HANDLE_DOUBLE_CLICK FOR GRF_GRID.

ENDFORM.                    " SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
FORM SET_TABLE_FOR_FIRST_DISPLAY .

  GS_VARIANT-HANDLE = '0001'.
  GS_VARIANT-REPORT = SY-REPID.

  CALL METHOD GRF_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT                    = GS_VARIANT
      IS_LAYOUT                     = GS_LAYOUT
      I_SAVE                        = 'A'
      I_DEFAULT                     = 'X'
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG               = GT_FIELDCAT
      IT_SORT                       = GT_SORT
      IT_OUTTAB                     = GT_OUTTAB
      IT_FILTER                     = GT_FILTER
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

ENDFORM.                    " SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING PS_ROW    TYPE LVC_S_ROW
                         PS_COLUMN TYPE LVC_S_COL.

  READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX PS_ROW-INDEX.
  CHECK SY-SUBRC EQ 0.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'REQNO'.
      IF NOT GS_OUTTAB-REQNO IS INITIAL.
        SET PARAMETER: ID 'ZNFREQ' FIELD GS_OUTTAB-REQNO.
        CALL TRANSACTION 'ZNF2M2103' AND SKIP FIRST SCREEN.
      ENDIF.

    WHEN 'B_NFUTN'.
      PERFORM DISPLAY_FUTRUES_HISTORY USING GS_OUTTAB-B_NFUTN.

    WHEN 'S_NFUTN'.
      PERFORM DISPLAY_FUTRUES_HISTORY USING GS_OUTTAB-S_NFUTN.

    WHEN 'SUPREME'.
      PERFORM DISPLAY_FUTRUES_HISTORY USING GS_OUTTAB-SUPREME.

    WHEN 'L_CNT'.
      PERFORM DISPLAY_SALES_FUTURES USING GS_OUTTAB-NFUTN
                                          GS_OUTTAB-CFUTN.

    WHEN 'ZBELNR'.
      PERFORM DISPLAY_FI_DOC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-ZBELNR
                                   GS_OUTTAB-ZGJAHR.
    WHEN 'YBELNR'.
      PERFORM DISPLAY_FI_DOC USING GS_OUTTAB-BUKRS
                                   GS_OUTTAB-YBELNR
                                   GS_OUTTAB-YGJAHR.
  ENDCASE.

ENDFORM.                    " DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FUTRUES_HISTORY
*&---------------------------------------------------------------------*
FORM DISPLAY_FUTRUES_HISTORY USING PV_NFUTN.
  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE.

  CHECK PV_NFUTN IS NOT INITIAL.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' ',
                 LT_RSPAR 'S_NFUTN' 'S' 'I' 'EQ' PV_NFUTN      ' ',
                 LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R01'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R02'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R03'   'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_R11'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R12'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R13'   'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_R21'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R22'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R23'   'P' ' ' ' '  'X'           ' '.

  SUBMIT ZNFR2600 WITH SELECTION-TABLE LT_RSPAR
                   AND RETURN.

ENDFORM.                    " DISPLAY_FUTRUES_HISTORY
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_SALES_FUTURES
*&---------------------------------------------------------------------*
*       판매선물 건수 더블클릭 : 판매 선물 전체를 선물집행 변경이력 조회
*----------------------------------------------------------------------*
FORM DISPLAY_SALES_FUTURES  USING PV_NFUTN
                                  PV_CFUTN.

  DATA: LT_RSPAR LIKE RSPARAMS OCCURS 0 WITH HEADER LINE,
        LT_TLEAF LIKE GT_TLEAF.

  LOOP AT GT_TLEAF INTO GS_TLEAF WHERE NFUTN = PV_NFUTN
                                   AND CFUTN = PV_CFUTN.
    APPEND GS_TLEAF TO LT_TLEAF.
  ENDLOOP.

  SORT LT_TLEAF BY L_NFUTN.
  DELETE ADJACENT DUPLICATES FROM LT_TLEAF COMPARING L_NFUTN.
  DELETE LT_TLEAF WHERE L_NFUTN IS INITIAL.

  IF LT_TLEAF[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '판매 선물 정보가 없습니다.'.
    EXIT.
  ENDIF.

  CLEAR   : LT_RSPAR.
  REFRESH : LT_RSPAR.

  APPEND_PARAM : LT_RSPAR 'P_BUKRS' 'P' ' ' ' '  P_BUKRS       ' '.

* 판매 선물집행번호 전체를 S_NFUTN 에 담아서 한번에 조회
  LOOP AT LT_TLEAF INTO GS_TLEAF.
    APPEND_PARAM : LT_RSPAR 'S_NFUTN' 'S' 'I' 'EQ' GS_TLEAF-L_NFUTN ' '.
  ENDLOOP.

  APPEND_PARAM : LT_RSPAR 'P_CHK11' 'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_CHK12' 'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R01'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R02'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R03'   'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_R11'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R12'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R13'   'P' ' ' ' '  'X'           ' ',
                 LT_RSPAR 'P_R21'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R22'   'P' ' ' ' '  ' '           ' ',
                 LT_RSPAR 'P_R23'   'P' ' ' ' '  'X'           ' '.

  SUBMIT ZNFR2600 WITH SELECTION-TABLE LT_RSPAR
                   AND RETURN.

ENDFORM.                    " DISPLAY_SALES_FUTURES
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FI_DOC
*&---------------------------------------------------------------------*
FORM DISPLAY_FI_DOC  USING PV_BUKRS
                           PV_BELNR
                           PV_GJAHR.

  CHECK PV_BELNR IS NOT INITIAL.

  SET PARAMETER ID 'BUK' FIELD PV_BUKRS.
  SET PARAMETER ID 'BLN' FIELD PV_BELNR.
  SET PARAMETER ID 'GJR' FIELD PV_GJAHR.

  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

ENDFORM.                    " DISPLAY_FI_DOC
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*       POST : 선택 라인 없으면 생성대상 전체를 일괄 처리
*       CANE : 선택 라인 필수
*----------------------------------------------------------------------*
FORM GET_SELECTED_ROWS USING PV_UCOMM.

  DATA: LV_CNT  TYPE I,
        LV_TEXT TYPE CHAR100.

  CLEAR : GV_ERROR.

  CALL METHOD GRF_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = GT_ROWS.

  CLEAR : GS_OUTTAB-CHECK.
  MODIFY GT_OUTTAB FROM GS_OUTTAB TRANSPORTING CHECK
                 WHERE BUKRS IS NOT INITIAL.

  IF GT_ROWS[] IS INITIAL.
    IF PV_UCOMM EQ 'POST'.
*     선택 없으면 생성대상 전체
      LOOP AT GT_OUTTAB TRANSPORTING NO FIELDS
                        WHERE ICON    EQ GC_ICON_YELLOW
                          AND YBELNR IS INITIAL.
        LV_CNT = LV_CNT + 1.
      ENDLOOP.

      IF LV_CNT EQ 0.
        GV_ERROR = 'X'.
        MESSAGE S003 DISPLAY LIKE 'E'
           WITH '생성 가능한 대상이 없습니다.'.
        EXIT.
      ENDIF.

      LV_TEXT = |선택된 라인이 없습니다. 생성대상 전체 { LV_CNT }건을 처리하시겠습니까?|.

      PERFORM POPUP_TO_CONFIRM USING '확인'
                                     LV_TEXT
                                     '1'
                                     GV_ANSWER.
      IF GV_ANSWER NE '1'.
        GV_ERROR = 'X'.
        EXIT.
      ENDIF.

      GS_OUTTAB-CHECK = 'X'.
      MODIFY GT_OUTTAB FROM GS_OUTTAB TRANSPORTING CHECK
                       WHERE ICON    EQ GC_ICON_YELLOW
                         AND YBELNR IS INITIAL.
    ELSE.
      GV_ERROR = 'X'.
      MESSAGE S003 DISPLAY LIKE 'E'
         WITH '선택된 라인이 없습니다.'.
    ENDIF.
    EXIT.
  ENDIF.

  LOOP AT GT_ROWS INTO GS_ROWS.
    READ TABLE GT_OUTTAB INTO GS_OUTTAB INDEX GS_ROWS-INDEX.
    IF SY-SUBRC = 0.
      GS_OUTTAB-CHECK = 'X'.
      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX GS_ROWS-INDEX
                       TRANSPORTING CHECK.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_0300  (전표생성 팝업)
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_0300.

  CHECK GV_ERROR IS INITIAL.

  CLEAR : GV_POST_CNT, GV_POST_AMT, GV_POST_WAERS.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB
                    WHERE CHECK   EQ 'X'
                      AND ICON    EQ GC_ICON_YELLOW
                      AND YBELNR IS INITIAL.
    GV_POST_CNT   = GV_POST_CNT + 1.
    GV_POST_AMT   = GV_POST_AMT + GS_OUTTAB-P_KPRLO.
    GV_POST_WAERS = GS_OUTTAB-KAERS.
  ENDLOOP.

  IF GV_POST_CNT EQ 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택한 라인 중 생성대상(노란색)이 없습니다.'.
    EXIT.
  ENDIF.

  CLEAR : CTU_PARAMS.
  CTU_PARAMS-DISMODE  =  'N'.     "일괄처리 : 백그라운드
  CTU_PARAMS-UPDMODE  =  'S'.
  CTU_PARAMS-RACOMMIT =  'X'.

* 전기일 기본값 : 당월이면 오늘, 아니면 해당월 말일
  IF SY-DATLO(6) EQ P_ENDMM.
    GV_BUDAT = SY-DATLO.
  ELSE.
    GV_BUDAT = GV_TODAT.
  ENDIF.
  GV_BLDAT = GV_BUDAT.

  CALL SCREEN 0300 STARTING AT 20 5.

ENDFORM.                    " CALL_SCREEN_0300
*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_0200  (역분개 팝업)
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_0200.

  CHECK GV_ERROR IS INITIAL.

  LOOP AT GT_OUTTAB TRANSPORTING NO FIELDS
                    WHERE CHECK   EQ 'X'
                      AND YBELNR IS NOT INITIAL.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC NE 0.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '선택한 라인 중 IN전표가 생성된 건이 없습니다.'.
    EXIT.
  ENDIF.

  PERFORM POPUP_TO_CONFIRM USING '확인'
                                 'IN전표를 역분개 하시겠습니까?'
                                 '1'
                                 GV_ANSWER.
  CHECK GV_ANSWER = '1'.

  GV_BUDAT = SY-DATLO.

  CALL SCREEN 0200 STARTING AT 20 5.

ENDFORM.                    " CALL_SCREEN_0200
*&---------------------------------------------------------------------*
*&      Form  CREATE_FI_DOC
*&---------------------------------------------------------------------*
*       선택(또는 전체) 생성대상 IN전표 일괄 생성
*----------------------------------------------------------------------*
FORM CREATE_FI_DOC .

  DATA: LT_COTA031 TYPE SORTED TABLE OF ZCOTA031
                   WITH UNIQUE KEY GJAHR KOKRS VKGRP PRCTR,
        LS_COTA031 TYPE ZCOTA031,
        LV_GSBER   TYPE GSBER,
        LV_BELNR   TYPE BELNR_D,
        LV_MSG(100),
        LV_TABIX   TYPE SY-TABIX,
        LV_EXIST   TYPE I,
        LV_SUCC    TYPE I,
        LV_FAIL    TYPE I,
        LV_SAVED   TYPE CHAR01,
        LV_GJAHR   TYPE GJAHR.

* 사업영역 Mapping (ZNFR2611 과 동일 : CHM2604-00280)
  LV_GJAHR = GV_BUDAT(4).

  SELECT *
    FROM ZCOTA031
    INTO CORRESPONDING FIELDS OF TABLE LT_COTA031
   WHERE KOKRS EQ P_BUKRS
     AND GJAHR EQ LV_GJAHR.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK EQ 'X'.
    LV_TABIX = SY-TABIX.

    CHECK GS_OUTTAB-ICON    EQ GC_ICON_YELLOW
      AND GS_OUTTAB-YBELNR IS INITIAL.

*___중복생성 방지 : 당월 IN전표 재확인
    CLEAR : LV_EXIST.
    SELECT COUNT(*)
      INTO LV_EXIST
      FROM ZNFT1055
     WHERE NFUTN  EQ GS_OUTTAB-NFUTN
       AND CFUTN  EQ GS_OUTTAB-CFUTN
       AND ZBELNR EQ GS_OUTTAB-ZBELNR
       AND ZGJAHR EQ GS_OUTTAB-ZGJAHR
       AND REMON  EQ P_ENDMM
       AND YBELNR NE SPACE.
    IF LV_EXIST GT 0.
      GS_OUTTAB-ICON   = GC_ICON_RED.
      GS_OUTTAB-STATUS = '오류'.
      GS_OUTTAB-MSG    = '당월 IN전표가 이미 존재합니다.(재조회 필요)'.
      MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.
      LV_FAIL = LV_FAIL + 1.
      CONTINUE.
    ENDIF.

*___사업영역 : 1000 = Mapping / 2000 = 2900 고정
    CLEAR : LS_COTA031, LV_GSBER.
    READ TABLE LT_COTA031 INTO LS_COTA031
                          WITH KEY KOKRS = GS_OUTTAB-BUKRS
                                   VKGRP = GS_OUTTAB-VKGRP
                                   PRCTR = GS_OUTTAB-PRCTR.

    IF P_BUKRS EQ '1000'.
      IF LS_COTA031 IS INITIAL.
        GS_OUTTAB-ICON   = GC_ICON_RED.
        GS_OUTTAB-STATUS = '오류'.
        GS_OUTTAB-MSG    = '사업영역 Mapping(ZCOTA031)을 확인하세요.'.
        MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.
        LV_FAIL = LV_FAIL + 1.
        CONTINUE.
      ENDIF.
      LV_GSBER = LS_COTA031-GSBER.
    ELSEIF P_BUKRS EQ '2000'.
      LV_GSBER = '2900'.
    ENDIF.

*___전표생성
    CLEAR : LV_BELNR, LV_MSG.
    PERFORM POST_IN_DOC USING    LV_GSBER
                        CHANGING LV_BELNR
                                 LV_MSG.

    IF LV_BELNR IS NOT INITIAL.
      GS_OUTTAB-YBELNR = LV_BELNR.
      GS_OUTTAB-YGJAHR = GV_BUDAT(4).
      GS_OUTTAB-BUDAT   = GV_BUDAT.
      GS_OUTTAB-REMON   = P_ENDMM.

*     ZNFT1055 저장
      PERFORM SAVE_ZNFT1055 USING    LV_BELNR
                            CHANGING LV_SAVED.

      IF LV_SAVED EQ 'X'.
        GS_OUTTAB-ICON   = GC_ICON_GREEN.
        GS_OUTTAB-STATUS = '생성완료'.
        GS_OUTTAB-MSG    = 'IN전표가 생성되었습니다.'.
        LV_SUCC = LV_SUCC + 1.
      ELSE.
        GS_OUTTAB-ICON   = GC_ICON_RED.
        GS_OUTTAB-STATUS = '오류'.
        CONCATENATE '전표' LV_BELNR '생성 후 ZNFT1055 저장 실패(확인 필요)'
               INTO GS_OUTTAB-MSG SEPARATED BY SPACE.
        LV_FAIL = LV_FAIL + 1.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
      GS_OUTTAB-ICON    = GC_ICON_RED.
      GS_OUTTAB-STATUS  = '오류'.
      GS_OUTTAB-MSG     = LV_MSG.
      LV_FAIL = LV_FAIL + 1.
    ENDIF.

    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_TABIX.
  ENDLOOP.

  PERFORM SET_CELL_ATTRIBUTE.

  MESSAGE S003 WITH 'IN전표 생성 성공' LV_SUCC '건 / 실패' LV_FAIL.

  LEAVE TO SCREEN 0.

ENDFORM.                    " CREATE_FI_DOC
*&---------------------------------------------------------------------*
*&      Form  POST_IN_DOC
*&---------------------------------------------------------------------*
*       IN전표 : 자산화(OUT) 했던 손익을 손익계정으로 반영
*       (+) 50 4140403 기타매출:PJT파생조정 / 40 2260202 확정계약대
*       (-) 50 1240202 확정계약차           / 40 4140403 기타매출
*----------------------------------------------------------------------*
FORM POST_IN_DOC  USING    PV_GSBER
                  CHANGING PV_BELNR
                           PV_MSG.

  DATA: LT_BBKPF LIKE STANDARD TABLE OF BBKPF WITH HEADER LINE,
        LT_BBSEG LIKE STANDARD TABLE OF BBSEG WITH HEADER LINE.
  DATA: LV_MODE  TYPE CTU_PARAMS-DISMODE,
        LV_KPRLO(20),
        LV_SGTXT LIKE BBSEG-SGTXT.

  CLEAR : PV_BELNR, PV_MSG.
  CLEAR : LT_BBKPF[], LT_BBKPF, LT_BBSEG[], LT_BBSEG.

* 금액 (KRW)
  WRITE : GS_OUTTAB-P_KPRLO TO LV_KPRLO CURRENCY GS_OUTTAB-KAERS
                                      NO-GROUPING.
  LV_KPRLO = ABS( LV_KPRLO ).
  CONDENSE : LV_KPRLO.

* 적요
  CONCATENATE 'IN' P_ENDMM GS_OUTTAB-NFUTN GS_OUTTAB-CFUTN
         INTO LV_SGTXT SEPARATED BY SPACE.

*___헤더
  LT_BBKPF-TCODE = 'FB01'.
  LT_BBKPF-BLDAT = GV_BLDAT       .  "증빙일
  LT_BBKPF-BLART = 'SA'           .  "전표유형
  LT_BBKPF-BUKRS = GS_OUTTAB-BUKRS.  "회사코드
  LT_BBKPF-BUDAT = GV_BUDAT       .  "전기일
  LT_BBKPF-MONAT = GV_BUDAT+4(2)  .  "전기기간
  LT_BBKPF-WAERS = 'KRW'          .  "통화
  APPEND LT_BBKPF.

  IF GS_OUTTAB-P_KPRLO > 0.

    LT_BBSEG-NEWBS = '50'.          "전기키
    LT_BBSEG-NEWKO = '0004140403'.  "계정-기타매출:PJT파생조정
    LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
    LT_BBSEG-GSBER = PV_GSBER.      "사업영역
    LT_BBSEG-PRCTR = GS_OUTTAB-PRCTR.  "손익센터
    LT_BBSEG-SGTXT = LV_SGTXT.
*___수익성세그멘트
    LT_BBSEG-RKE_BUKRS  = GS_OUTTAB-BUKRS.
    LT_BBSEG-RKE_KNDNR  = GS_OUTTAB-KUNNR.  "고객
    LT_BBSEG-RKE_PRCTR  = GS_OUTTAB-PRCTR.  "손익센터
    LT_BBSEG-RKE_KMVKGR = GS_OUTTAB-VKGRP.  "영업그룹
    APPEND LT_BBSEG. CLEAR LT_BBSEG.

    LT_BBSEG-NEWBS = '40'.          "전기키
    LT_BBSEG-NEWKO = '0002260202'.  "계정-확정계약대:비철선물
    LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
    LT_BBSEG-GSBER = PV_GSBER.      "사업영역
    LT_BBSEG-SGTXT = LV_SGTXT.
    APPEND LT_BBSEG. CLEAR LT_BBSEG.

  ELSE.

    LT_BBSEG-NEWBS = '50'.          "전기키
    LT_BBSEG-NEWKO = '0001240202'.  "계정-확정계약차:비철선물
    LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
    LT_BBSEG-GSBER = PV_GSBER.      "사업영역
    LT_BBSEG-SGTXT = LV_SGTXT.
    APPEND LT_BBSEG. CLEAR LT_BBSEG.

    LT_BBSEG-NEWBS = '40'.          "전기키
    LT_BBSEG-NEWKO = '0004140403'.  "계정-기타매출:PJT파생조정
    LT_BBSEG-WRBTR = LV_KPRLO.      "현지통화금액(KRW)
    LT_BBSEG-GSBER = PV_GSBER.      "사업영역
    LT_BBSEG-PRCTR = GS_OUTTAB-PRCTR.  "손익센터
    LT_BBSEG-SGTXT = LV_SGTXT.
*___수익성세그멘트
    LT_BBSEG-RKE_BUKRS  = GS_OUTTAB-BUKRS.
    LT_BBSEG-RKE_KNDNR  = GS_OUTTAB-KUNNR.  "고객
    LT_BBSEG-RKE_PRCTR  = GS_OUTTAB-PRCTR.  "손익센터
    LT_BBSEG-RKE_KMVKGR = GS_OUTTAB-VKGRP.  "영업그룹
    APPEND LT_BBSEG. CLEAR LT_BBSEG.

  ENDIF.

* 전표생성 펑션 Call
  LV_MODE = CTU_PARAMS-DISMODE.

  CALL FUNCTION 'ZFI_DOCUMENT_POSTING'
    EXPORTING
      I_BDC_MODE  = LV_MODE
      I_MESSAGE   = ''
    IMPORTING
      E_BELNR     = PV_BELNR
      E_RESULTMSG = PV_MSG
    TABLES
      T_BBKPF     = LT_BBKPF
      T_BBSEG     = LT_BBSEG.

  IF PV_BELNR IS INITIAL AND PV_MSG IS INITIAL.
    PV_MSG = '전표생성에 실패했습니다.'.
  ENDIF.

ENDFORM.                    " POST_IN_DOC
*&---------------------------------------------------------------------*
*&      Form  SAVE_ZNFT1055
*&---------------------------------------------------------------------*
FORM SAVE_ZNFT1055  USING    PV_BELNR
                    CHANGING PV_SAVED.

  DATA: LV_H_NO1 LIKE ZNFT1055-H_NO1.

  CLEAR : LV_H_NO1, ZNFT1055, PV_SAVED.

* 회계전표 라인 추가 (ZNFR2612 와 동일 채번)
  SELECT SINGLE MAX( H_NO1 )
    INTO LV_H_NO1
    FROM ZNFT1055
   WHERE NFUTN EQ GS_OUTTAB-NFUTN.

  LV_H_NO1 = LV_H_NO1 + 1.

  ZNFT1055-NFUTN  = GS_OUTTAB-NFUTN.
  ZNFT1055-CFUTN  = GS_OUTTAB-CFUTN.
  ZNFT1055-H_NO1  = LV_H_NO1.
  ZNFT1055-BUKRS  = GS_OUTTAB-BUKRS.
  ZNFT1055-REQNO  = GS_OUTTAB-REQNO.
  ZNFT1055-CONNO  = GS_OUTTAB-CONNO.
  ZNFT1055-KPRLO  = GS_OUTTAB-P_KPRLO.
  ZNFT1055-KONWA  = GS_OUTTAB-KAERS.
  ZNFT1055-KRATE  = GS_OUTTAB-KRATE.
  ZNFT1055-ZBELNR = GS_OUTTAB-ZBELNR.
  ZNFT1055-ZGJAHR = GS_OUTTAB-ZGJAHR.
  ZNFT1055-YBELNR = PV_BELNR.
  ZNFT1055-YGJAHR = GV_BUDAT(4).
  ZNFT1055-REMON  = P_ENDMM.
  ZNFT1055-BUDAT  = GV_BUDAT.
  ZNFT1055-ERNAM  = SY-UNAME.
  ZNFT1055-ERDAT  = SY-DATLO.
  ZNFT1055-ERZET  = SY-TIMLO.

  INSERT ZNFT1055 FROM ZNFT1055.

  IF SY-SUBRC = 0.
    COMMIT WORK.
    GS_OUTTAB-I_HNO1 = LV_H_NO1.
    PV_SAVED = 'X'.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.                    " SAVE_ZNFT1055
*&---------------------------------------------------------------------*
*&      Form  REVERSE_FI_DOC
*&---------------------------------------------------------------------*
FORM REVERSE_FI_DOC.

  DATA: LV_SUCC TYPE I,
        LV_FAIL TYPE I.

  PERFORM CANCEL_FI_DOC CHANGING LV_SUCC LV_FAIL.

  PERFORM DATA_SELECT.

  MESSAGE S003 WITH 'IN전표 역분개 성공' LV_SUCC '건 / 실패' LV_FAIL.

  LEAVE TO SCREEN 0.

ENDFORM.                    " REVERSE_FI_DOC
*&---------------------------------------------------------------------*
*&      Form  CANCEL_FI_DOC
*&---------------------------------------------------------------------*
FORM CANCEL_FI_DOC CHANGING PV_SUCC
                           PV_FAIL.

  CLEAR : PV_SUCC, PV_FAIL.

  LOOP AT GT_OUTTAB INTO GS_OUTTAB WHERE CHECK   EQ 'X'
                                     AND YBELNR IS NOT INITIAL.

    CLEAR   : GT_BDCTAB, GT_RETMSG, GV_BELNR.
    REFRESH : GT_BDCTAB, GT_RETMSG.

    PERFORM DYNPRO USING :
                   'X' 'SAPMF05A'          '0105',
                   ' ' 'BDC_OKCODE'        '=BU',
                   ' ' 'RF05A-BELNS'       GS_OUTTAB-YBELNR,
                   ' ' 'BKPF-BUKRS'        GS_OUTTAB-BUKRS,
                   ' ' 'RF05A-GJAHS'       GS_OUTTAB-YGJAHR,
                   ' ' 'BSIS-BUDAT'        GV_BUDAT,
                   ' ' 'BSIS-MONAT'        GV_BUDAT+4(2),
                   ' ' 'UF05A-STGRD'       '01'.

    CLEAR : CTU_PARAMS.
    CTU_PARAMS-DISMODE  =  'N'.
    CTU_PARAMS-UPDMODE  =  'S'.
    CTU_PARAMS-RACOMMIT =  'X'.

    CALL TRANSACTION 'FB08' USING         GT_BDCTAB
                            OPTIONS  FROM CTU_PARAMS
                            MESSAGES INTO GT_RETMSG.

    READ TABLE GT_RETMSG WITH KEY MSGTYP = 'S'
                                  MSGID  = 'F5'
                                  MSGNR  = '312'.
    IF SY-SUBRC = 0.
      GV_BELNR = GT_RETMSG-MSGV1.
    ENDIF.

    IF GV_BELNR IS INITIAL.
      PV_FAIL = PV_FAIL + 1.
      PERFORM DISPLAY_BDC_MESSAGE.
      CONTINUE.
    ENDIF.

*   역분개 성공시에만 ZNFT1055 초기화 (ZNFR2612 와 동일 방식)
    UPDATE ZNFT1055 SET YBELNR = ''
                        YGJAHR = ''
                        KPRLO  = 0
                        KRATE  = 0
                        KONWA  = ''
                        ERNAM  = SY-UNAME
                        ERDAT  = SY-DATLO
                        ERZET  = SY-TIMLO
                  WHERE NFUTN  = GS_OUTTAB-NFUTN
                    AND CFUTN  = GS_OUTTAB-CFUTN
                    AND H_NO1  = GS_OUTTAB-I_HNO1.

    IF SY-SUBRC = 0.
      COMMIT WORK.
      PV_SUCC = PV_SUCC + 1.
    ELSE.
      ROLLBACK WORK.
      PV_FAIL = PV_FAIL + 1.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " CANCEL_FI_DOC
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_BDC_MESSAGE
*&---------------------------------------------------------------------*
FORM DISPLAY_BDC_MESSAGE .

  READ TABLE GT_RETMSG WITH KEY MSGTYP = 'A'.
  IF SY-SUBRC <> 0.
    READ TABLE GT_RETMSG WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC <> 0.
      READ TABLE GT_RETMSG WITH KEY MSGTYP = 'W'.
      IF SY-SUBRC <> 0.
        READ TABLE GT_RETMSG WITH KEY MSGTYP = 'I'.
        IF SY-SUBRC <> 0.
          READ TABLE GT_RETMSG INDEX 1.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF SY-SUBRC = 0.
    MESSAGE ID     GT_RETMSG-MSGID
            TYPE   'S'
            NUMBER GT_RETMSG-MSGNR
            WITH   GT_RETMSG-MSGV1
                   GT_RETMSG-MSGV2
                   GT_RETMSG-MSGV3
                   GT_RETMSG-MSGV4
            DISPLAY LIKE GT_RETMSG-MSGTYP.
  ENDIF.

ENDFORM.                    " DISPLAY_BDC_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  DYNPRO
*&---------------------------------------------------------------------*
FORM DYNPRO  USING  PV_DYNBEGIN
                    PV_FNAM
                    PV_FVAL.

  CLEAR : GT_BDCTAB.

  IF  PV_DYNBEGIN =  'X'.
    GT_BDCTAB-DYNBEGIN  =  'X'.
    GT_BDCTAB-PROGRAM   =  PV_FNAM.
    GT_BDCTAB-DYNPRO    =  PV_FVAL.
    APPEND GT_BDCTAB.
  ELSE.
    GT_BDCTAB-FNAM      =  PV_FNAM.
    GT_BDCTAB-FVAL      =  PV_FVAL.
    APPEND GT_BDCTAB.
  ENDIF.

ENDFORM.                    " DYNPRO
