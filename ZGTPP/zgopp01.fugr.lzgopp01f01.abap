*----------------------------------------------------------------------*
***INCLUDE LZGOPP01F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form check_para_cut_prod_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_PARA_CUT_PROD_RESULT  USING PT_CUT_ITEM   TYPE TY_T_CUT_ITEM
                                       PT_CUT_RESULT TYPE TY_T_CUT_RESULT
                                       PS_CUT_HEADER TYPE ZGTPPSIF0046
                                       PV_MODE   PV_SYSTEM_ID
                                       PV_RESULT PV_MESSAGE
                               RAISING LCX_EXCEPTION.

  PV_RESULT  = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-SUCCESS.
  PV_MESSAGE = TEXT-S01.

  CLEAR GT_ZGTPPT2190.

  PERFORM CHECK_HEADER_CUT_PROD_RESULT USING PV_MODE PV_SYSTEM_ID PS_CUT_HEADER.

  IF PT_CUT_ITEM IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F13.
  ENDIF.

  IF PT_CUT_ITEM IS NOT INITIAL.
    SELECT DISTINCT ZT01~ZCUT_ORD_NO, ZT01~ZCUT_ORD_ITEM, ZT01~ZASSIGN_NO,
                    ZT01~ZCUT_MBLNR,  ZT01~ZCUT_MJAHR, ZT01~ZTR_MBLNR, ZT01~ZTR_MJAHR
      FROM ZGTPPT2190   AS ZT01
      JOIN @PT_CUT_ITEM AS ZT02
        ON ZT01~ZCUT_ORD_NO EQ ZT02~ZCUT_ORD_NO
     ORDER BY ZT01~ZCUT_ORD_NO, ZT01~ZCUT_ORD_ITEM
      INTO CORRESPONDING FIELDS OF TABLE @GT_ZGTPPT2190.

    SELECT DISTINCT ZT01~ZCUT_ORD_NO, ZT01~ZCUT_ORD_ITEM, ZT02~ZASSIGN_NO, ZT02~MATNR, ZT02~WERKS
      FROM @GT_ZGTPPT2190 AS ZT01
      JOIN ZGTPPT2170     AS ZT02
        ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
     ORDER BY ZT01~ZCUT_ORD_NO, ZT01~ZCUT_ORD_ITEM
     INTO TABLE @DATA(LT_ZGTPPT2170).

    SELECT MCHB~MATNR, MCHB~WERKS, MCHB~CHARG, SUM( MCHB~CLABS ) AS CLABS
      FROM @LT_ZGTPPT2170 AS ZT01
      JOIN MCHB
        ON ZT01~MATNR EQ MCHB~MATNR
       AND ZT01~WERKS EQ MCHB~WERKS
     GROUP BY MCHB~MATNR, MCHB~WERKS, MCHB~CHARG
     ORDER BY MCHB~MATNR, MCHB~WERKS, MCHB~CHARG
     INTO TABLE @DATA(LT_MCHB).
  ENDIF.

  PT_CUT_RESULT = VALUE #( FOR LS_ITEM IN PT_CUT_ITEM[]
                         ( VALUE #( BASE CORRESPONDING #( LS_ITEM )  ZSERNO = PS_CUT_HEADER-ZSERNO ) ) ).

  SORT PT_CUT_RESULT BY ZSERNO ZCUT_ORD_NO ZCUT_ORD_ITEM.

  LOOP AT PT_CUT_ITEM INTO DATA(LS_CUT_ITEM).
    READ TABLE PT_CUT_RESULT REFERENCE INTO DATA(LR_CUT_RESULT) WITH KEY ZSERNO        = PS_CUT_HEADER-ZSERNO
                                                                         ZCUT_ORD_NO   = LS_CUT_ITEM-ZCUT_ORD_NO
                                                                         ZCUT_ORD_ITEM = LS_CUT_ITEM-ZCUT_ORD_ITEM BINARY SEARCH.

    READ TABLE LT_ZGTPPT2170 INTO DATA(LS_ZGTPPT2170) WITH KEY ZCUT_ORD_NO   = LS_CUT_ITEM-ZCUT_ORD_NO
                                                               ZCUT_ORD_ITEM = LS_CUT_ITEM-ZCUT_ORD_ITEM BINARY SEARCH.

*// 절단지시번호.
    IF LS_CUT_ITEM-ZCUT_ORD_NO IS INITIAL.
      LR_CUT_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      MESSAGE E031 WITH TEXT-F14 INTO LR_CUT_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ELSE.
      IF LS_CUT_ITEM-ZCUT_ORD_NO EQ PS_CUT_HEADER-ZCUT_ORD_NO.
        READ TABLE GT_ZGTPPT2190 TRANSPORTING NO FIELDS WITH KEY ZCUT_ORD_NO = LS_CUT_ITEM-ZCUT_ORD_NO BINARY SEARCH.
        IF SY-SUBRC IS NOT INITIAL.
          LR_CUT_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
          LR_CUT_RESULT->ZERP_MESSAGE = TEXT-E02.
          CONTINUE.
        ENDIF.
      ELSE.
        LR_CUT_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
        LR_CUT_RESULT->ZERP_MESSAGE = TEXT-E07.
        CONTINUE.
      ENDIF.
    ENDIF.

*// 절단지시항번.
    IF LS_CUT_ITEM-ZCUT_ORD_ITEM IS INITIAL.
      LR_CUT_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      MESSAGE E031 WITH TEXT-F15 INTO LR_CUT_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ELSE.
      READ TABLE GT_ZGTPPT2190 TRANSPORTING NO FIELDS WITH KEY ZCUT_ORD_NO   = LS_CUT_ITEM-ZCUT_ORD_NO
                                                               ZCUT_ORD_ITEM = LS_CUT_ITEM-ZCUT_ORD_ITEM BINARY SEARCH.
      IF SY-SUBRC IS NOT INITIAL.
        LR_CUT_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
        LR_CUT_RESULT->ZERP_MESSAGE = TEXT-E03.
        CONTINUE.
      ENDIF.
    ENDIF.

*// 절단 조장.
    IF LS_CUT_ITEM-ZCUT_LEN IS INITIAL.
      LR_CUT_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      MESSAGE E031 WITH TEXT-F09 INTO LR_CUT_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// 절단 조장 수.
    IF LS_CUT_ITEM-ZCUT_CNT IS INITIAL.
      LR_CUT_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      MESSAGE E031 WITH TEXT-F10 INTO LR_CUT_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ELSEIF LS_CUT_ITEM-ZCUT_CNT NE '1'.
      LR_CUT_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      LR_CUT_RESULT->ZERP_MESSAGE = TEXT-E08.
      CONTINUE.
    ENDIF.

*// 배치번호.
    IF LS_CUT_ITEM-T_CHARG IS INITIAL.
      LR_CUT_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      MESSAGE E031 WITH TEXT-F16 INTO LR_CUT_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ELSE.
      IF PV_MODE EQ 'P'. "// 절단실적처리.
        READ TABLE LT_MCHB INTO DATA(LS_MCHB) WITH KEY MATNR = LS_ZGTPPT2170-MATNR
                                                       WERKS = LS_ZGTPPT2170-WERKS
                                                       CHARG = LS_CUT_ITEM-T_CHARG BINARY SEARCH.
        IF SY-SUBRC IS INITIAL AND LS_MCHB-CLABS GT 0.
          LR_CUT_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
          LR_CUT_RESULT->ZERP_MESSAGE = TEXT-E09.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

*// 꼬리표번호.
    IF LS_CUT_ITEM-TAGNR IS INITIAL.
      LR_CUT_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      MESSAGE E031 WITH TEXT-F17 INTO LR_CUT_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

    IF PV_MODE EQ 'C'. "// 절단실적취소.
      IF LS_CUT_ITEM-C_MBLNR IS INITIAL.
        LR_CUT_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
        MESSAGE E031 WITH TEXT-F18 INTO LR_CUT_RESULT->ZERP_MESSAGE.
        CONTINUE.
      ENDIF.

      IF LS_CUT_ITEM-C_MJAHR IS INITIAL.
        LR_CUT_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
        MESSAGE E031 WITH TEXT-F19 INTO LR_CUT_RESULT->ZERP_MESSAGE.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF LINE_EXISTS( PT_CUT_RESULT[ ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E04.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_cut_prod_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_CUT_PROD_RESULT   USING PS_ZGTPPT3380 TYPE ZGTPPT3380
                                  PT_CUT_ITEM   TYPE TY_T_CUT_ITEM
                                  PS_CUT_HEADER TYPE ZGTPPSIF0046
                                  PV_MODE PV_SYSTEM_ID
                                  PV_RESULT PV_MESSAGE
                          RAISING LCX_EXCEPTION.
  DATA LT_ZGTPPT3390 TYPE TABLE OF ZGTPPT3390.

  GET TIME STAMP FIELD DATA(LV_ZIFKEY).

  PS_ZGTPPT3380 = VALUE #( BASE CORRESPONDING #( PS_CUT_HEADER ) ZIFKEY     = LV_ZIFKEY
                                                                 ZMODE      = PV_MODE
                                                                 ZSYSTEM_ID = PV_SYSTEM_ID
                                                                 ZSTAT      = PV_RESULT
                                                                 ZMESSAGE   = PV_MESSAGE
                                                                 IFDAT      = SY-DATUM
                                                                 IFTIM      = SY-UZEIT
                                                                 IFNAM      = SY-UNAME ).

  LT_ZGTPPT3390 = VALUE #( FOR LS_CUT_ITEM IN PT_CUT_ITEM[]
                         ( VALUE #( BASE CORRESPONDING #( LS_CUT_ITEM )  ZIFKEY     = PS_ZGTPPT3380-ZIFKEY
                                                                         ZSYSTEM_ID = PS_ZGTPPT3380-ZSYSTEM_ID
                                                                         ZSERNO     = PS_ZGTPPT3380-ZSERNO ) ) ).

  TRY.
      MODIFY ZGTPPT3380 FROM PS_ZGTPPT3380.
      MODIFY ZGTPPT3390 FROM TABLE LT_ZGTPPT3390.

      COMMIT WORK AND WAIT.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E05.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form processing_cutting_results
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM PROCESSING_CUTTING_RESULTS USING PS_ZGTPPT3380 TYPE ZGTPPT3380
                                      PT_CUT_ITEM   TYPE TY_T_CUT_ITEM
                                      PT_CUT_RESULT TYPE TY_T_CUT_RESULT.
  DATA LT_LINK_ITEM TYPE TY_T_LINK_ITEM.
  DATA LT_RESULT TYPE TABLE OF ZGTPPSIF0045.
  DATA LT_ITEM   TYPE TABLE OF ZGTPPS1010.
  DATA LT_RETURN TYPE TY_T_RETURN.
  DATA LV_MATNR  TYPE MARA-MATNR.

  PERFORM GET_SALES_ORDER_MATERIAL USING PS_ZGTPPT3380-VBELN PS_ZGTPPT3380-POSNR LV_MATNR.

  LT_ITEM = CORRESPONDING #( PT_CUT_ITEM ).
  DATA(LS_HEADER) = VALUE ZGTPPS1012( BASE CORRESPONDING #( PS_ZGTPPT3380 )  MATNR = LV_MATNR
                                                                             CHARG = PS_ZGTPPT3380-F_CHARG
                                                                             MENGE = PS_ZGTPPT3380-LABST3 ).

*// 절단실적처리 함수 호출.
  CALL FUNCTION 'ZGTPP_MILL_CUT_PROC'
    EXPORTING
      IS_HEADER = LS_HEADER
    TABLES
      IT_ITEM   = LT_ITEM
      OT_RETURN = LT_RETURN.

*// 처리결과 업데이트.
  PERFORM UPDATE_MILL_CUT_RESULT USING PS_ZGTPPT3380 LT_RETURN LT_LINK_ITEM PT_CUT_ITEM PT_CUT_RESULT.

*// Link 정보 Update.
  CHECK LT_LINK_ITEM IS NOT INITIAL.

  CALL FUNCTION 'ZGTPP_LINK_INFO_UPDATE'
    EXPORTING
      I_WERKS    = PS_ZGTPPT3380-WERKS
      I_UPD_TYPE = ZGTPP_IF_CONST=>GC_UPD_TYPE-U1
    TABLES
      IT_ITEM    = LT_LINK_ITEM
      OT_RETURN  = LT_RESULT.

*// 절단 전 LOT번호로 주문 할당된 정보가 남아있는 경우 절단 후 LOT번호로 업데이트
  PERFORM UPDATE_ZGTPPT2180_F_CHARG TABLES LT_RESULT USING PS_ZGTPPT3380-ZMODE PT_CUT_ITEM .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form canceling_cutting_results
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CANCELING_CUTTING_RESULTS USING PS_ZGTPPT3380 TYPE ZGTPPT3380
                                     PT_CUT_ITEM   TYPE TY_T_CUT_ITEM
                                     PT_CUT_RESULT TYPE TY_T_CUT_RESULT.

  DATA LT_LINK_ITEM TYPE TY_T_LINK_ITEM.
  DATA LT_RESULT    TYPE TABLE OF ZGTPPSIF0045.

  LOOP AT PT_CUT_ITEM INTO DATA(LS_CUT_ITEM).
    TRY.
        PERFORM CANCEL_TRANSFER_POSTING USING LS_CUT_ITEM PS_ZGTPPT3380 PT_CUT_RESULT.

        PERFORM CANCEL_MILL_CUT USING LS_CUT_ITEM PS_ZGTPPT3380 PT_CUT_RESULT LT_LINK_ITEM.

      CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).

    ENDTRY.
  ENDLOOP.

*// Link 정보 Update

  CHECK LT_LINK_ITEM IS NOT INITIAL.

  CALL FUNCTION 'ZGTPP_LINK_INFO_UPDATE'
    EXPORTING
      I_WERKS    = PS_ZGTPPT3380-WERKS
      I_UPD_TYPE = ZGTPP_IF_CONST=>GC_UPD_TYPE-Z1
    TABLES
      IT_ITEM    = LT_LINK_ITEM
      OT_RETURN  = LT_RESULT.

**// 절단 전 LOT번호로 주문 할당된 정보가 남아있는 경우 절단 후 LOT번호로 업데이트
*  PERFORM UPDATE_ZGTPPT2180_F_CHARG TABLES LT_RESULT USING PS_ZGTPPT3380-ZMODE PT_CUT_ITEM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_header_cut_prod_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_HEADER_CUT_PROD_RESULT USING PV_MODE
                                        PV_SYSTEM_ID
                                        PS_CUT_HEADER TYPE ZGTPPSIF0046
                                RAISING LCX_EXCEPTION.

*// 처리 모드.
  IF PV_MODE IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F01.
  ELSEIF NOT CONTAINS( VAL = PV_MODE  REGEX = '[P,C,T]' ) ##regex_posix.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E01.
  ENDIF.

*// 송신 시스템.
  IF PV_SYSTEM_ID IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F02.
  ENDIF.

*// MES 전송 일련번호.
  IF PS_CUT_HEADER-ZSERNO IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F03.
  ENDIF.

*// 플랜트.
  IF PS_CUT_HEADER-WERKS IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F04.
  ELSE.
    SELECT SINGLE @ABAP_TRUE INTO @DATA(LV_CHECK) FROM T001W WHERE WERKS EQ @PS_CUT_HEADER-WERKS.
    IF SY-SUBRC IS NOT INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E011(VF) WITH PS_CUT_HEADER-WERKS.
    ENDIF.
  ENDIF.

*// 절단지시번호.
  IF PS_CUT_HEADER-ZCUT_ORD_NO IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F04.
  ELSE.
    SELECT SINGLE @ABAP_TRUE
      INTO @LV_CHECK
      FROM ZGTPPT2190
     WHERE ZCUT_ORD_NO EQ @PS_CUT_HEADER-ZCUT_ORD_NO
       AND LOEKZ       EQ @SPACE.
    IF SY-SUBRC IS NOT INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E02.
    ENDIF.
  ENDIF.

*// 절단일자
  IF PS_CUT_HEADER-BUDAT IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F12.
  ENDIF.

*// 판매오더번호
  IF PS_CUT_HEADER-VBELN IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F05.
  ENDIF.

*// 판매오더품목
  IF PS_CUT_HEADER-POSNR IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F06.
  ENDIF.

*// 저장위치
  IF PS_CUT_HEADER-LGORT IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F07.
  ELSE.
    SELECT SINGLE @ABAP_TRUE
      INTO @LV_CHECK
      FROM T001L
     WHERE WERKS EQ @PS_CUT_HEADER-WERKS
       AND LGORT EQ @PS_CUT_HEADER-LGORT.
    IF SY-SUBRC IS NOT INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E366(V1) WITH PS_CUT_HEADER-LGORT PS_CUT_HEADER-WERKS.
    ENDIF.
  ENDIF.

*// 절단 전 배치번호
  IF PS_CUT_HEADER-F_CHARG IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F08.
  ENDIF.

*// 절단 조장
  IF PS_CUT_HEADER-LABST3 IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F09.
  ENDIF.

*// 절단 조장 수
  IF PS_CUT_HEADER-ZCUT_CNT IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F10.
  ENDIF.

*// 단위
  IF PS_CUT_HEADER-MEINS IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F11.
  ELSE.
    SELECT SINGLE @ABAP_TRUE
      INTO @LV_CHECK
      FROM T006
     WHERE MSEHI EQ @PS_CUT_HEADER-MEINS.
    IF SY-SUBRC IS NOT INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E177(29) WITH PS_CUT_HEADER-LGORT PS_CUT_HEADER-WERKS.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_sales_order_material
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_SALES_ORDER_MATERIAL  USING  PV_VBELN PV_POSNR PV_MATNR.

  SELECT SINGLE MATNR
    INTO @PV_MATNR
    FROM VBAP
   WHERE VBELN EQ @PV_VBELN
     AND POSNR EQ @PV_POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_zppt0001
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_ZPPT0001  USING PS_ZGTPPT3380 TYPE ZGTPPT3380
                            PS_CUT_ITEM   TYPE ZGTPPSIF0047
                            PS_RETURN     TYPE ZGTPPS1011.
  DATA LV_MATNR TYPE MARA-MATNR.

  PERFORM GET_SALES_ORDER_MATERIAL USING PS_ZGTPPT3380-VBELN PS_ZGTPPT3380-POSNR LV_MATNR.

  SELECT SINGLE MARA~MATNR, MARA~MATKL, MARC~DISPO
    INTO @DATA(LS_ZMAT)
    FROM MARA
    JOIN MARC
      ON MARA~MATNR EQ MARC~MATNR
     AND MARC~WERKS EQ @PS_ZGTPPT3380-WERKS
   WHERE MARA~MATNR EQ @LV_MATNR.

  DATA(LS_ZPPT0001) = VALUE ZPPT0001( WERKS   = PS_ZGTPPT3380-WERKS
                                      TAGNR   = PS_CUT_ITEM-TAGNR
                                      CHARG   = PS_CUT_ITEM-T_CHARG
                                      MBLNR   = PS_RETURN-ZCUT_MBLNR
                                      MATNR   = LV_MATNR
                                      SPGCD   = LS_ZMAT-DISPO(2)
                                      PROCD   = LS_ZMAT-MATKL+4(3)
                                      MGVRG   = PS_CUT_ITEM-ZCUT_LEN
                                      FOSTCNT = PS_CUT_ITEM-ZCUT_CNT
                                      REMAIN  = ( PS_CUT_ITEM-ZCUT_LEN * PS_CUT_ITEM-ZCUT_CNT )
                                      MEINS   = PS_ZGTPPT3380-MEINS
                                      GIFLG   = 'N'
                                      GRFLG   = 'Y'
                                      INSPFLG = 'OK'
                                      LGORT   = PS_ZGTPPT3380-LGORT
                                      WKDAT   = SY-DATUM
                                      WKINDAT = SY-DATUM
                                      WKINTIM = SY-UZEIT
                                      WKINNAM = SY-UNAME
                                      GRINDAT = SY-DATUM
                                      GRINTIM = SY-UZEIT
                                      GRINNAM = SY-UNAME
                                      BKTXT   = |{ PS_CUT_ITEM-ZCUT_ORD_NO }{ PS_CUT_ITEM-ZCUT_ORD_ITEM }| ).

  MODIFY ZPPT0001 FROM LS_ZPPT0001.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_para_prod_gi_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_PARA_PROD_GI_RESULT  USING PV_MODE PV_SYSTEM_ID PV_RESULT PV_MESSAGE
                                      PT_ISSUE  TYPE TY_T_ISSUE
                                      PT_RESULT TYPE TY_T_RESULT
                              RAISING LCX_EXCEPTION.

  PV_RESULT  = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-SUCCESS.
  PV_MESSAGE = TEXT-S01.

  GS_PROD_GI = VALUE #( MODE       = PV_MODE
                        ZSYSTEM_ID = PV_SYSTEM_ID
                        ZRESULT    = PV_RESULT
                        ZMESSAGE   = PV_MESSAGE ).

*// 처리 모드.
  IF PV_MODE IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F01.
  ELSEIF NOT CONTAINS( VAL = PV_MODE  REGEX = '[P,C]' ) ##regex_posix.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E01.
  ENDIF.

*// 송신 시스템.
  IF PV_SYSTEM_ID IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F02.
  ENDIF.

  IF PT_ISSUE IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F20.
  ENDIF.

  PT_RESULT = CORRESPONDING #( PT_ISSUE[] ).
  SORT PT_RESULT BY ZSERNO.

  LOOP AT PT_ISSUE INTO DATA(LS_ISSUE).
    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LS_ISSUE-ZSERNO BINARY SEARCH.

    LR_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.

*// 플랜트.
    IF LS_ISSUE-WERKS IS INITIAL.
      MESSAGE E031 WITH TEXT-F04 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// SPG코드.
    IF LS_ISSUE-SPGCD IS INITIAL.
      MESSAGE E031 WITH TEXT-F21 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// 전기일자.
    IF LS_ISSUE-BUDAT IS INITIAL.
      MESSAGE E031 WITH TEXT-F22 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// 판매오더번호.
    IF LS_ISSUE-KDAUF IS INITIAL.
      MESSAGE E031 WITH TEXT-F05 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// 판매오더품목.
    IF LS_ISSUE-KDPOS IS INITIAL.
      MESSAGE E031 WITH TEXT-F06 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// 출고자재코드.
    IF LS_ISSUE-MATNR IS INITIAL.
      MESSAGE E031 WITH TEXT-F23 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ELSE.
      PERFORM CONVERSION_EXIT_MATN1_INPUT USING LS_ISSUE-MATNR.
    ENDIF.

*// 이동유형.
    IF LS_ISSUE-BWART IS INITIAL.
      MESSAGE E031 WITH TEXT-F24 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// 출고수량.
    IF LS_ISSUE-MENGE IS INITIAL.
      MESSAGE E031 WITH TEXT-F25 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// 출고단위.
    IF LS_ISSUE-MEINS IS INITIAL.
      MESSAGE E031 WITH TEXT-F26 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// 출고저장위치.
    IF LS_ISSUE-LGORT IS INITIAL.
      MESSAGE E031 WITH TEXT-F27 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

    IF PV_MODE EQ 'C'. "// 투입취소.
      IF LS_ISSUE-C_MBLNR IS INITIAL.
        MESSAGE E031 WITH TEXT-F29 INTO LR_RESULT->ZERP_MESSAGE.
        CONTINUE.
      ENDIF.

      IF LS_ISSUE-C_MJAHR IS INITIAL.
        MESSAGE E031 WITH TEXT-F28 INTO LR_RESULT->ZERP_MESSAGE.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF LR_RESULT->ZERP_MESSAGE IS INITIAL.
      LR_RESULT->ZERP_STAT = SPACE.
    ENDIF.

    APPEND LS_ISSUE TO GS_PROD_GI-ISSUE.
  ENDLOOP.

  IF LINE_EXISTS( PT_RESULT[ ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E04.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_prod_gi_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_PROD_GI_RESULT RAISING LCX_EXCEPTION.

  DATA LT_ZGTPPT3400 TYPE TABLE OF ZGTPPT3400.

  PERFORM GET_DATE_TIME.

  GET TIME STAMP FIELD GS_PROD_GI-ZIFKEY.

  LT_ZGTPPT3400 = VALUE #( FOR LS_ISSUE IN GS_PROD_GI-ISSUE
                         ( VALUE #( BASE CORRESPONDING #( LS_ISSUE )  ZIFKEY     = GS_PROD_GI-ZIFKEY
                                                                      ZSYSTEM_ID = GS_PROD_GI-ZSYSTEM_ID
                                                                      ZSTAT      = GS_PROD_GI-ZRESULT
                                                                      ZMESSAGE   = GS_PROD_GI-ZMESSAGE
                                                                      IFDAT      = GS_ZGTPPS1001-CRDAT
                                                                      IFTIM      = GS_ZGTPPS1001-CRTIM
                                                                      IFNAM      = GS_ZGTPPS1001-CRNAM ) ) ).

  TRY.
      MODIFY ZGTPPT3400 FROM TABLE LT_ZGTPPT3400.

      COMMIT WORK AND WAIT.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E05.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form processing_prod_gi_results
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM PROCESSING_PROD_GI_RESULTS USING PT_RESULT TYPE TY_T_RESULT.
  DATA LT_ITEM TYPE GM_ITEMS_T.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA LT_ZCUT_ORD_ITEM TYPE RANGE OF ZGTPPT3400-ZCUT_ORD_ITEM.
  DATA LV_STRING TYPE STRING.

  DATA(LT_ZGTPPT1010) = ZGTPP_CL_COMMON=>GET_CODE_VALUE( IV_CODEGRP = '3080' ).
  SORT LT_ZGTPPT1010 BY FLD_01 FLD_02.

  LOOP AT GS_PROD_GI-ISSUE INTO DATA(LS_KEY)
                           GROUP BY ( ZSERNO      = LS_KEY-ZSERNO
                                      ZCUT_ORD_NO = LS_KEY-ZCUT_ORD_NO
                                      BUDAT       = LS_KEY-BUDAT )
                           INTO DATA(LT_GROUP).

    CLEAR: LT_ITEM, LT_ZCUT_ORD_ITEM.

    LOOP AT GROUP LT_GROUP INTO DATA(LS_ISSUE).
      PERFORM SET_ITEM_PARA USING LT_ITEM LS_ISSUE LT_ZGTPPT1010.
      APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LS_ISSUE-ZCUT_ORD_ITEM ) TO LT_ZCUT_ORD_ITEM.
    ENDLOOP.

    CLEAR: LS_HEADRET, LT_RETURN, LV_STRING.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = VALUE BAPI2017_GM_HEAD_01( PSTNG_DATE = LT_GROUP-BUDAT
                                                      DOC_DATE   = LT_GROUP-BUDAT
                                                      HEADER_TXT = LT_GROUP-ZSERNO )
        GOODSMVT_CODE    = ZGTPP_IF_CONST=>GC_GM_CODE-GI_FOR_ORDER
      IMPORTING
        GOODSMVT_HEADRET = LS_HEADRET
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.

    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LT_GROUP-ZSERNO.

    IF LS_HEADRET IS NOT INITIAL.
      LR_RESULT->ZERP_STAT  = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
      LR_RESULT->ZERP_MESSAGE = TEXT-S02.
      LR_RESULT->MBLNR = LS_HEADRET-MAT_DOC.
      LR_RESULT->MJAHR = LS_HEADRET-DOC_YEAR.
      LV_STRING = |mblnr = @lr_result->mblnr, mjahr = @lr_result->mjahr|.

      UPDATE ZGTPPT2191
         SET ZDR_MBLNR = @LR_RESULT->MBLNR,
             ZDR_MJAHR = @LR_RESULT->MJAHR,
             CHDAT     = @GS_ZGTPPS1001-CHDAT,
             CHTIM     = @GS_ZGTPPS1001-CHTIM,
             CHNAM     = @GS_ZGTPPS1001-CHNAM
       WHERE ZCUT_ORD_NO   EQ @LT_GROUP-ZCUT_ORD_NO
         AND ZCUT_ORD_ITEM IN @LT_ZCUT_ORD_ITEM.
    ELSE.
      LR_RESULT->ZERP_STAT  = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      LR_RESULT->ZERP_MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
    ENDIF.

    UPDATE ZGTPPT3400
       SET ZERP_STAT    = @LR_RESULT->ZERP_STAT,
           ZERP_MESSAGE = @LR_RESULT->ZERP_MESSAGE,
           (LV_STRING)
     WHERE ZIFKEY     EQ @GS_PROD_GI-ZIFKEY
       AND ZSYSTEM_ID EQ @GS_PROD_GI-ZSYSTEM_ID
       AND ZSERNO     EQ @LT_GROUP-ZSERNO.

    COMMIT WORK AND WAIT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form canceling_prod_gi_results
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CANCELING_PROD_GI_RESULTS  USING PT_RESULT TYPE TY_T_RESULT.

  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LT_ZCUT_ORD_ITEM TYPE RANGE OF ZGTPPT3400-ZCUT_ORD_ITEM.

  LOOP AT GS_PROD_GI-ISSUE INTO DATA(LS_KEY)
                           GROUP BY ( ZSERNO      = LS_KEY-ZSERNO
                                      ZCUT_ORD_NO = LS_KEY-ZCUT_ORD_NO
                                      BUDAT       = LS_KEY-BUDAT
                                      C_MBLNR     = LS_KEY-C_MBLNR
                                      C_MJAHR     = LS_KEY-C_MJAHR )
                           INTO DATA(LT_GROUP).

    CLEAR: LS_HEADRET, LT_RETURN, LT_ZCUT_ORD_ITEM.

    LOOP AT GROUP LT_GROUP INTO DATA(LS_ISSUE).
      APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LS_ISSUE-ZCUT_ORD_ITEM ) TO LT_ZCUT_ORD_ITEM.
    ENDLOOP.

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = LT_GROUP-C_MBLNR
        MATDOCUMENTYEAR     = LT_GROUP-C_MJAHR
        GOODSMVT_PSTNG_DATE = LT_GROUP-BUDAT
      IMPORTING
        GOODSMVT_HEADRET    = LS_HEADRET
      TABLES
        RETURN              = LT_RETURN.

    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LT_GROUP-ZSERNO.

    IF LS_HEADRET IS NOT INITIAL.
      LR_RESULT->ZERP_STAT    = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
      LR_RESULT->ZERP_MESSAGE = TEXT-S03.
      LR_RESULT->MBLNR = LS_HEADRET-MAT_DOC.
      LR_RESULT->MJAHR = LS_HEADRET-DOC_YEAR.

      UPDATE ZGTPPT2191
         SET ZDR_MBLNR = @SPACE,
             ZDR_MJAHR = @SPACE,
             CHDAT     = @GS_ZGTPPS1001-CHDAT,
             CHTIM     = @GS_ZGTPPS1001-CHTIM,
             CHNAM     = @GS_ZGTPPS1001-CHNAM
       WHERE ZCUT_ORD_NO   EQ @LT_GROUP-ZCUT_ORD_NO
         AND ZCUT_ORD_ITEM IN @LT_ZCUT_ORD_ITEM.
    ELSE.
      LR_RESULT->ZERP_STAT    = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      LR_RESULT->ZERP_MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
    ENDIF.

    UPDATE ZGTPPT3400
       SET MBLNR        = @LR_RESULT->MBLNR,
           MJAHR        = @LR_RESULT->MJAHR,
           ZERP_STAT    = @LR_RESULT->ZERP_STAT,
           ZERP_MESSAGE = @LR_RESULT->ZERP_MESSAGE
    WHERE ZIFKEY     EQ @GS_PROD_GI-ZIFKEY
      AND ZSYSTEM_ID EQ @GS_PROD_GI-ZSYSTEM_ID
      AND ZSERNO     EQ @LT_GROUP-ZSERNO.

    COMMIT WORK AND WAIT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_profit_segm_no
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_PROFIT_SEGM_NO  USING PS_ISSUE TYPE ZGTPPSIF0049
                               PS_COBL  TYPE COBL
                               PS_ZGTPPT1010 TYPE ZGTPPT1010.

  DATA LT_COPADATA TYPE TABLE OF COPADATA.

  CLEAR PS_COBL.

  SELECT SINGLE BUKRS
    INTO @DATA(LV_BUKRS)
    FROM T001K
    JOIN T001W
      ON T001K~BWKEY EQ T001W~BWKEY
   WHERE T001W~WERKS EQ @PS_ISSUE-WERKS.

  DATA(LS_COBL) = VALUE COBL( MAT_KDAUF = PS_ISSUE-KDAUF
                              MAT_KDPOS = PS_ISSUE-KDPOS
                              BUKRS     = LV_BUKRS
                              WERKS     = PS_ISSUE-WERKS
                              KZBEW     = 'X'
                              XPSEG_DER = 'X' ).

  LT_COPADATA = VALUE #( ( FNAM = 'KAUFN' FVAL = PS_ISSUE-KDAUF )
                         ( FNAM = 'KDPOS' FVAL = PS_ISSUE-KDPOS )
                         ( FNAM = 'ARTNR' FVAL = PS_ISSUE-MATNR ) ).

  SELECT SINGLE TKA02~KOKRS
    FROM T001K
    JOIN TKA02 ON TKA02~BUKRS EQ T001K~BUKRS
   WHERE T001K~BWKEY EQ @PS_ISSUE-WERKS
    INTO @DATA(LV_KOKRS).

  CALL FUNCTION 'COPA_PROFITABILITY_SEGMENT'
    EXPORTING
      ANZEIGE             = SPACE
      DIALOG              = SPACE
      I_COBL              = LS_COBL
      I_ERKRS             = LV_KOKRS
      I_MODE              = 'T'
    IMPORTING
      E_COBL              = PS_COBL
    TABLES
      T_COPADATA          = LT_COPADATA
    EXCEPTIONS
      ABNORMAL_LEAVE      = 1
      BTRANS_NOT_RELEVANT = 2
      ERROR_COPA          = 3
      OTHERS              = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_item_para
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_ITEM_PARA  USING PT_ITEM  TYPE GM_ITEMS_T
                          PS_ISSUE TYPE ZGTPPSIF0049
                          PT_ZGTPPT1010 LIKE ZGTPP_CL_COMMON=>GTY_T_ZGTPPT1010.
  DATA LS_COBL TYPE COBL.

  READ TABLE PT_ZGTPPT1010 INTO DATA(LS_ZGTPPT1010) WITH KEY FLD_01 = PS_ISSUE-WERKS
                                                             FLD_02 = PS_ISSUE-SPGCD BINARY SEARCH.

  PERFORM GET_PROFIT_SEGM_NO USING PS_ISSUE LS_COBL LS_ZGTPPT1010.

  PT_ITEM =  VALUE #( BASE PT_ITEM  ( MATERIAL       = CONV MATNR18( PS_ISSUE-MATNR )
                                      PLANT          = PS_ISSUE-WERKS
                                      STGE_LOC       = PS_ISSUE-LGORT
                                      BATCH          = PS_ISSUE-CHARG
                                      MOVE_TYPE      = PS_ISSUE-BWART
                                      STCK_TYPE      = 'F'
                                      ENTRY_QNT      = PS_ISSUE-MENGE
                                      ENTRY_UOM      = PS_ISSUE-MEINS
                                      SALES_ORD      = PS_ISSUE-KDAUF
                                      S_ORD_ITEM     = PS_ISSUE-KDPOS
                                      GL_ACCOUNT     = LS_ZGTPPT1010-FLD_03
                                      PROFIT_SEGM_NO = LS_COBL-PAOBJNR ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conversion_exit_matn1_input
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_MATN1_INPUT  USING PV_MATNR.

  CHECK PV_MATNR IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = PV_MATNR
    IMPORTING
      OUTPUT       = PV_MATNR
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_date_time
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_DATE_TIME .

  GS_ZGTPPS1001-CRDAT = SY-DATUM.
  GS_ZGTPPS1001-CRTIM = SY-UZEIT.
  GS_ZGTPPS1001-CRNAM = SY-UNAME.
  GS_ZGTPPS1001-CHDAT = SY-DATUM.
  GS_ZGTPPS1001-CHTIM = SY-UZEIT.
  GS_ZGTPPS1001-CHNAM = SY-UNAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_para_mat_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_PARA_MAT_REQ  USING PV_SYSTEM_ID
                               PS_HEADER TYPE ZGTPPSIF0051
                               PV_RESULT
                               PV_MESSAGE
                               PT_ITEM   TYPE TY_T_ITEM
                       RAISING LCX_EXCEPTION.

  PV_RESULT  = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-SUCCESS.
  PV_MESSAGE = TEXT-S01.

  GS_MAT_REQ = VALUE #( ZSYSTEM_ID = PV_SYSTEM_ID
                        HEADER     = PS_HEADER
                        ITEM       = PT_ITEM
                        ZRESULT    = PV_RESULT
                        ZMESSAGE   = PV_MESSAGE ).

  PERFORM CHECK_HEADER_MAT_REQ USING PV_SYSTEM_ID PS_HEADER.

  IF PT_ITEM IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F30.
  ENDIF.

  LOOP AT GS_MAT_REQ-ITEM REFERENCE INTO DATA(LR_ITEM).
*// 자재요청번호.
    IF LR_ITEM->ZREQ_NO IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F31.
    ENDIF.

*// 자재요청항번.
    IF LR_ITEM->ZREQ_ITEM IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F36.
    ENDIF.

*// 자재코드.
    IF LR_ITEM->MATNR IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F37.
    ELSE.
      PERFORM CONVERSION_EXIT_MATN1_INPUT USING LR_ITEM->MATNR.
    ENDIF.

*// 요청수량.
    IF LR_ITEM->REQ_QTY IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F38.
    ENDIF.

*// 단위.
    IF LR_ITEM->MEINS IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F39.
    ENDIF.

*// 단위.
    IF LR_ITEM->F_LGORT IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F40.
    ENDIF.

*// 입고 요청일자.
    IF LR_ITEM->REQ_DATE IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F41.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_mat_req_from_prod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_MAT_REQ_FROM_PROD  RAISING LCX_EXCEPTION.

  DATA LT_ZGTPPT3350 TYPE TABLE OF ZGTPPT3350.

  GET TIME STAMP FIELD GS_MAT_REQ-ZIFKEY.

  DATA(LS_ZGTPPT3340) = VALUE ZGTPPT3340( BASE CORRESPONDING #( GS_MAT_REQ-HEADER )  ZIFKEY     = GS_MAT_REQ-ZIFKEY
                                                                                     ZSYSTEM_ID = GS_MAT_REQ-ZSYSTEM_ID
                                                                                     ZSTAT      = GS_MAT_REQ-ZRESULT
                                                                                     ZMESSAGE   = GS_MAT_REQ-ZMESSAGE
                                                                                     IFDAT      = SY-DATUM
                                                                                     IFTIM      = SY-UZEIT
                                                                                     IFNAM      = SY-UNAME ).

  LT_ZGTPPT3350 = VALUE #( FOR LS_ITEM IN GS_MAT_REQ-ITEM
                         ( VALUE #( BASE CORRESPONDING #( LS_ITEM )  ZIFKEY     = LS_ZGTPPT3340-ZIFKEY
                                                                     ZSYSTEM_ID = LS_ZGTPPT3340-ZSYSTEM_ID
                                                                     ZSERNO     = LS_ZGTPPT3340-ZSERNO  ) ) ).

  TRY.
      MODIFY ZGTPPT3340 FROM LS_ZGTPPT3340.
      MODIFY ZGTPPT3350 FROM TABLE LT_ZGTPPT3350.

      COMMIT WORK AND WAIT.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E05.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_header_mat_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_HEADER_MAT_REQ  USING PV_SYSTEM_ID
                                 PS_HEADER TYPE ZGTPPSIF0051
                                RAISING LCX_EXCEPTION.
  DATA LV_RSNUM TYPE RESB-RSNUM.

*// 송신 시스템.
  IF PV_SYSTEM_ID IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F02.
  ENDIF.

*// MES 전송 일련번호.
  IF PS_HEADER-ZSERNO IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F03.
  ENDIF.

*// 자재요청번호.
  IF PS_HEADER-ZREQ_NO IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F31.
  ELSE.
    IF PS_HEADER-ZREQ_MODE EQ 'C' OR PS_HEADER-ZREQ_MODE EQ 'D'.
      SELECT MAX( RSNUM ) AS RSNUM
        INTO @GS_MAT_REQ-RSNUM
        FROM ZGTPPT3340
       WHERE ZSYSTEM_ID EQ @GS_MAT_REQ-ZSYSTEM_ID
         AND ZREQ_NO    EQ @GS_MAT_REQ-HEADER-ZREQ_NO
         AND RSNUM      NE @LV_RSNUM.

      IF GS_MAT_REQ-RSNUM IS INITIAL.
        RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E003 WITH TEXT-E06.
      ENDIF.
    ENDIF.
  ENDIF.

*// 요청 유형.
  IF PS_HEADER-ZREQ_TYPE IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F32.
  ENDIF.

*// 처리 모드
  IF PS_HEADER-ZREQ_MODE IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F33.
  ENDIF.

*// 플랜트.
  IF PS_HEADER-WERKS IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F04.
  ELSE.
    SELECT SINGLE @ABAP_TRUE INTO @DATA(LV_CHECK) FROM T001W WHERE WERKS EQ @PS_HEADER-WERKS.
    IF SY-SUBRC IS NOT INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E011(VF) WITH PS_HEADER-WERKS.
    ENDIF.
  ENDIF.

*// 입고 저장위치
  IF PS_HEADER-T_LGORT IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F34.
  ENDIF.

*// 생성일
  IF PS_HEADER-CRDAT IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F35.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_reservation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CREATE_RESERVATION  TABLES PT_RESULT STRUCTURE ZGTPPSIF0053.

  DATA LS_HEADER TYPE BAPIRKPFC.
  DATA LT_ITEM   TYPE TY_T_RESB.

  APPEND INITIAL LINE TO PT_RESULT[] REFERENCE INTO DATA(LR_RESULT).

  PERFORM SET_RESERVATION_PARA    USING LS_HEADER LT_ITEM.
  PERFORM BAPI_RESERVATION_CREATE USING LS_HEADER LT_ITEM LR_RESULT->*.
  PERFORM UPDATE_MAT_REQ_LOG      USING LR_RESULT->*.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_reservation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHANGE_RESERVATION  TABLES PT_RESULT STRUCTURE ZGTPPSIF0053.

  DATA LS_HEADER TYPE BAPIRKPFC.
  DATA LT_ITEM   TYPE TY_T_RESB.

  PERFORM DELETE_RESERVATION TABLES PT_RESULT[].

  IF LINE_EXISTS( PT_RESULT[ ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR ] ).
    RETURN.
  ENDIF.

  CLEAR PT_RESULT[].
  APPEND INITIAL LINE TO PT_RESULT[] REFERENCE INTO DATA(LR_RESULT).

  PERFORM SET_RESERVATION_PARA    USING LS_HEADER LT_ITEM.
  PERFORM BAPI_RESERVATION_CREATE USING LS_HEADER LT_ITEM LR_RESULT->*.
  PERFORM UPDATE_MAT_REQ_LOG      USING LR_RESULT->*.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_reservation_para
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_RESERVATION_PARA USING PS_HEADER TYPE BAPIRKPFC
                                PT_ITEM   TYPE TY_T_RESB.

  PS_HEADER = VALUE BAPIRKPFC( PLANT      = GS_MAT_REQ-HEADER-WERKS
                               RES_DATE	  = SY-DATUM
                               MOVE_TYPE  = COND #( WHEN GS_MAT_REQ-HEADER-ZREQ_TYPE EQ 'A' OR GS_MAT_REQ-HEADER-ZREQ_TYPE EQ 'B' THEN '311' )
                               MOVE_PLANT = GS_MAT_REQ-HEADER-WERKS
                               MOVE_STLOC = GS_MAT_REQ-HEADER-T_LGORT ).

  PT_ITEM = VALUE #( FOR LS_ITEM IN GS_MAT_REQ-ITEM
                    ( MATERIAL   = CONV #( LS_ITEM-MATNR )
                      PLANT      = GS_MAT_REQ-HEADER-WERKS
                      STORE_LOC  = LS_ITEM-F_LGORT
                      BATCH      = SPACE
                      QUANTITY   = LS_ITEM-REQ_QTY
                      UNIT       = LS_ITEM-MEINS
                      REQ_DATE   = LS_ITEM-REQ_DATE
                      SHORT_TEXT = LS_ITEM-REMARKS
                      UNLOAD_PT  = LS_ITEM-LOCATION
                      MOVEMENT   = ABAP_TRUE ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_reservation_create
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BAPI_RESERVATION_CREATE  USING PS_HEADER TYPE BAPIRKPFC
                                    PT_ITEM   TYPE TY_T_RESB
                                    PS_RESULT TYPE ZGTPPSIF0053.

  DATA LT_RETURN TYPE TABLE OF BAPIRETURN.
  DATA LV_RSNUM  TYPE BAPIRKPFC-RES_NO.

  CALL FUNCTION 'BAPI_RESERVATION_CREATE'
    EXPORTING
      RESERVATION_HEADER = PS_HEADER
    IMPORTING
      RESERVATION        = LV_RSNUM
    TABLES
      RESERVATION_ITEMS  = PT_ITEM
      RETURN             = LT_RETURN.

  PS_RESULT = VALUE #( ZSERNO        = GS_MAT_REQ-HEADER-ZSERNO
                       RSNUM         = LV_RSNUM
                       ZERP_STAT     = COND #( WHEN LV_RSNUM IS NOT INITIAL THEN ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                                                            ELSE ZGTPP_IF_CONST=>GC_RESULT-ERROR )
                       ZERP_MESSAGE  = VALUE #( LT_RETURN[ TYPE = PS_RESULT-ZERP_STAT ]-MESSAGE OPTIONAL ) ).

  IF LV_RSNUM IS NOT INITIAL AND PS_RESULT-ZERP_MESSAGE IS INITIAL.
    MESSAGE S060(M7) WITH LV_RSNUM INTO PS_RESULT-ZERP_MESSAGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_mat_req_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_MAT_REQ_LOG  USING PS_RESULT TYPE ZGTPPSIF0053.

  UPDATE ZGTPPT3340
     SET RSNUM        = PS_RESULT-RSNUM
         ZSTAT        = GS_MAT_REQ-ZRESULT
         ZMESSAGE     = GS_MAT_REQ-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY      EQ GS_MAT_REQ-ZIFKEY
     AND ZSYSTEM_ID  EQ GS_MAT_REQ-ZSYSTEM_ID
     AND ZSERNO      EQ GS_MAT_REQ-HEADER-ZSERNO
     AND ZREQ_NO     EQ GS_MAT_REQ-HEADER-ZREQ_NO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_mill_cut_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_MILL_CUT_RESULT  USING  PS_ZGTPPT3380 TYPE ZGTPPT3380
                                    PT_RETURN     TYPE TY_T_RETURN
                                    PT_LINK_ITEM  TYPE TY_T_LINK_ITEM
                                    PT_CUT_ITEM   TYPE TY_T_CUT_ITEM
                                    PT_CUT_RESULT TYPE TY_T_CUT_RESULT.

  DATA LV_SEQNO TYPE ZGTPPSIF0044-SEQNO.

  LOOP AT PT_RETURN INTO DATA(LS_RETURN).
    MODIFY PT_CUT_RESULT FROM VALUE #( MBLNR        = LS_RETURN-ZCUT_MBLNR
                                       MJAHR        = LS_RETURN-ZCUT_MJAHR
                                       ZERP_STAT    = LS_RETURN-ZERP_STAT
                                       ZERP_MESSAGE = LS_RETURN-ZERP_MESSAGE )
                         TRANSPORTING MBLNR MJAHR ZERP_STAT ZERP_MESSAGE
                         WHERE ZSERNO        EQ PS_ZGTPPT3380-ZSERNO
                           AND ZCUT_ORD_NO   EQ LS_RETURN-ZCUT_ORD_NO
                           AND ZCUT_ORD_ITEM EQ LS_RETURN-ZCUT_ORD_ITEM.

*// 절단 실적 수신 이력 Update.
    UPDATE ZGTPPT3390    SET ZCUT_MBLNR   = LS_RETURN-ZCUT_MBLNR
                             ZCUT_MJAHR   = LS_RETURN-ZCUT_MJAHR
                             ZERP_STAT    = LS_RETURN-ZERP_STAT
                             ZERP_MESSAGE = LS_RETURN-ZERP_MESSAGE
                       WHERE ZIFKEY        EQ PS_ZGTPPT3380-ZIFKEY
                         AND ZSYSTEM_ID    EQ PS_ZGTPPT3380-ZSYSTEM_ID
                         AND ZSERNO        EQ PS_ZGTPPT3380-ZSERNO
                         AND ZCUT_ORD_NO   EQ LS_RETURN-ZCUT_ORD_NO
                         AND ZCUT_ORD_ITEM EQ LS_RETURN-ZCUT_ORD_ITEM.

    IF LS_RETURN-ZERP_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
      READ TABLE PT_CUT_ITEM INTO DATA(LS_CUT_ITEM) WITH KEY ZCUT_ORD_NO   = LS_RETURN-ZCUT_ORD_NO
                                                             ZCUT_ORD_ITEM = LS_RETURN-ZCUT_ORD_ITEM.

      PERFORM MODIFY_ZPPT0001 USING PS_ZGTPPT3380 LS_CUT_ITEM LS_RETURN.

*// 절단 작업 지시.
      UPDATE ZGTPPT2190 SET ZCUT_MBLNR = LS_RETURN-ZCUT_MBLNR
                            ZCUT_MJAHR = LS_RETURN-ZCUT_MJAHR
                            ZTR_MBLNR  = LS_RETURN-ZTR_MBLNR
                            ZTR_MJAHR  = LS_RETURN-ZTR_MJAHR
                      WHERE ZCUT_ORD_NO   EQ LS_RETURN-ZCUT_ORD_NO
                        AND ZCUT_ORD_ITEM EQ LS_RETURN-ZCUT_ORD_ITEM.

      LV_SEQNO += 1.

      PT_LINK_ITEM = VALUE #( BASE PT_LINK_ITEM  ( SEQNO         = LV_SEQNO
                                                   TAGNR         = LS_CUT_ITEM-TAGNR
                                                   ZCUT_ORD_NO   = LS_CUT_ITEM-ZCUT_ORD_NO
                                                   ZCUT_ORD_ITEM = LS_CUT_ITEM-ZCUT_ORD_ITEM ) ).
    ENDIF.
  ENDLOOP.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form cancel_transfer_posting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CANCEL_TRANSFER_POSTING  USING PS_CUT_ITEM   TYPE ZGTPPSIF0047
                                    PS_ZGTPPT3380 TYPE ZGTPPT3380
                                    PT_CUT_RESULT TYPE TY_T_CUT_RESULT
                            RAISING LCX_EXCEPTION.

  DATA LS_HEAD_RET TYPE BAPI2017_GM_HEAD_RET.
  DATA LT_RETURN   TYPE TABLE OF BAPIRET2.

  READ TABLE GT_ZGTPPT2190 INTO DATA(LS_ZGTPPT2190) WITH KEY ZCUT_ORD_NO   = PS_CUT_ITEM-ZCUT_ORD_NO
                                                             ZCUT_ORD_ITEM = PS_CUT_ITEM-ZCUT_ORD_ITEM BINARY SEARCH.

  CHECK LS_ZGTPPT2190-ZTR_MBLNR IS NOT INITIAL.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = LS_ZGTPPT2190-ZTR_MBLNR
      MATDOCUMENTYEAR     = LS_ZGTPPT2190-ZTR_MJAHR
      GOODSMVT_PSTNG_DATE = PS_ZGTPPT3380-BUDAT
    IMPORTING
      GOODSMVT_HEADRET    = LS_HEAD_RET
    TABLES
      RETURN              = LT_RETURN.

  DATA(LS_CUT_RESULT) = COND ZGTPPSIF0048( WHEN LS_HEAD_RET IS INITIAL THEN VALUE #( ZERP_STAT    = ZGTPP_IF_CONST=>GC_RESULT-ERROR
                                                                                     ZERP_MESSAGE = VALUE #( LT_RETURN[ TYPE = ZGTPP_IF_CONST=>GC_RESULT-ERROR ]-MESSAGE OPTIONAL )  )
                                           ELSE VALUE #( ZERP_STAT    = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                                         ZERP_MESSAGE = VALUE #( LT_RETURN[ TYPE = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS ]-MESSAGE OPTIONAL ) ) ).

  MODIFY PT_CUT_RESULT FROM VALUE #( ZERP_STAT    = LS_CUT_RESULT-ZERP_STAT
                                     ZERP_MESSAGE = LS_CUT_RESULT-ZERP_MESSAGE )
                       TRANSPORTING MBLNR MJAHR ZERP_STAT ZERP_MESSAGE
                       WHERE ZSERNO        EQ PS_ZGTPPT3380-ZSERNO
                         AND ZCUT_ORD_NO   EQ PS_CUT_ITEM-ZCUT_ORD_NO
                         AND ZCUT_ORD_ITEM EQ PS_CUT_ITEM-ZCUT_ORD_ITEM.

  UPDATE ZGTPPT3390    SET ZERP_STAT    = LS_CUT_RESULT-ZERP_STAT
                           ZERP_MESSAGE = LS_CUT_RESULT-ZERP_MESSAGE
                     WHERE ZIFKEY        EQ PS_ZGTPPT3380-ZIFKEY
                       AND ZSYSTEM_ID    EQ PS_ZGTPPT3380-ZSYSTEM_ID
                       AND ZSERNO        EQ PS_ZGTPPT3380-ZSERNO
                       AND ZCUT_ORD_NO   EQ PS_CUT_ITEM-ZCUT_ORD_NO
                       AND ZCUT_ORD_ITEM EQ PS_CUT_ITEM-ZCUT_ORD_ITEM.

  IF LS_CUT_RESULT-ZERP_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    UPDATE ZGTPPT2190 SET ZTR_MBLNR  = SPACE
                          ZTR_MJAHR  = SPACE
                    WHERE ZCUT_ORD_NO   EQ PS_CUT_ITEM-ZCUT_ORD_NO
                      AND ZCUT_ORD_ITEM EQ PS_CUT_ITEM-ZCUT_ORD_ITEM.
  ENDIF.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = ABAP_TRUE.

  CHECK LS_CUT_RESULT-ZERP_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR.

  RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH LS_CUT_RESULT-ZERP_MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form cancel_mill_cut
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CANCEL_MILL_CUT  USING  PS_CUT_ITEM TYPE ZGTPPSIF0047
                             PS_ZGTPPT3380 TYPE ZGTPPT3380
                             PT_CUT_RESULT TYPE TY_T_CUT_RESULT
                             PT_LINK_ITEM  TYPE TY_T_LINK_ITEM.

  DATA LS_HEAD_RET TYPE BAPI2017_GM_HEAD_RET.
  DATA LT_RETURN   TYPE TABLE OF BAPIRET2.
  DATA LV_MATNR    TYPE MARA-MATNR.
  DATA LV_SEQNO    TYPE ZGTPPSIF0044-SEQNO.

*// 절단 실적 취소.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = PS_CUT_ITEM-C_MBLNR
      MATDOCUMENTYEAR     = PS_CUT_ITEM-C_MJAHR
      GOODSMVT_PSTNG_DATE = PS_ZGTPPT3380-BUDAT
    IMPORTING
      GOODSMVT_HEADRET    = LS_HEAD_RET
    TABLES
      RETURN              = LT_RETURN.

  DATA(LS_CUT_RESULT) = COND ZGTPPSIF0048( WHEN LS_HEAD_RET IS INITIAL THEN VALUE #( ZERP_STAT    = ZGTPP_IF_CONST=>GC_RESULT-ERROR
                                                                                     ZERP_MESSAGE = VALUE #( LT_RETURN[ TYPE = ZGTPP_IF_CONST=>GC_RESULT-ERROR ]-MESSAGE OPTIONAL )  )
                                           ELSE VALUE #( MBLNR        = LS_HEAD_RET-MAT_DOC
                                                         MJAHR        = LS_HEAD_RET-DOC_YEAR
                                                         ZERP_STAT    = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                                         ZERP_MESSAGE = VALUE #( LT_RETURN[ TYPE = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS ]-MESSAGE OPTIONAL ) ) ).

  MODIFY PT_CUT_RESULT FROM VALUE #( MBLNR        = LS_CUT_RESULT-MBLNR
                                     MJAHR        = LS_CUT_RESULT-MJAHR
                                     ZERP_STAT    = LS_CUT_RESULT-ZERP_STAT
                                     ZERP_MESSAGE = LS_CUT_RESULT-ZERP_MESSAGE )
                       TRANSPORTING MBLNR MJAHR ZERP_STAT ZERP_MESSAGE
                       WHERE ZSERNO        EQ PS_ZGTPPT3380-ZSERNO
                         AND ZCUT_ORD_NO   EQ PS_CUT_ITEM-ZCUT_ORD_NO
                         AND ZCUT_ORD_ITEM EQ PS_CUT_ITEM-ZCUT_ORD_ITEM.

*// 절단 실적 수신 이력 Update.
  UPDATE ZGTPPT3390 SET ZCUT_MBLNR   = LS_CUT_RESULT-MBLNR
                        ZCUT_MJAHR   = LS_CUT_RESULT-MJAHR
                        ZERP_STAT    = LS_CUT_RESULT-ZERP_STAT
                        ZERP_MESSAGE = LS_CUT_RESULT-ZERP_MESSAGE
                  WHERE ZIFKEY        EQ PS_ZGTPPT3380-ZIFKEY
                    AND ZSYSTEM_ID    EQ PS_ZGTPPT3380-ZSYSTEM_ID
                    AND ZSERNO        EQ PS_ZGTPPT3380-ZSERNO
                    AND ZCUT_ORD_NO   EQ PS_CUT_ITEM-ZCUT_ORD_NO
                    AND ZCUT_ORD_ITEM EQ PS_CUT_ITEM-ZCUT_ORD_ITEM.

  IF LS_CUT_RESULT-ZERP_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
*// 꼬리표 테이블 삭제 처리.
    PERFORM GET_SALES_ORDER_MATERIAL USING PS_ZGTPPT3380-VBELN PS_ZGTPPT3380-POSNR LV_MATNR.

    DELETE FROM ZPPT0001 WHERE WERKS EQ PS_ZGTPPT3380-WERKS
                           AND AUFNR EQ SPACE
                           AND TAGNR EQ PS_CUT_ITEM-TAGNR
                           AND CHARG EQ PS_CUT_ITEM-T_CHARG
                           AND MATNR EQ LV_MATNR.

*// 절단 작업 지시.
    UPDATE ZGTPPT2190 SET ZCUT_MBLNR = SPACE
                          ZCUT_MJAHR = SPACE
                    WHERE ZCUT_ORD_NO   EQ PS_CUT_ITEM-ZCUT_ORD_NO
                      AND ZCUT_ORD_ITEM EQ PS_CUT_ITEM-ZCUT_ORD_ITEM.

    LV_SEQNO = LINES( PT_LINK_ITEM ) + 1.

    PT_LINK_ITEM = VALUE #( BASE PT_LINK_ITEM  ( SEQNO         = LV_SEQNO
                                                 TAGNR         = PS_CUT_ITEM-TAGNR
                                                 ZCUT_ORD_NO   = PS_CUT_ITEM-ZCUT_ORD_NO
                                                 ZCUT_ORD_ITEM = PS_CUT_ITEM-ZCUT_ORD_ITEM ) ).
  ENDIF.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_para_stock_transfer
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_PARA_STOCK_TRANSFER  USING PV_MODE PV_SYSTEM_ID PV_RESULT PV_MESSAGE
                                      PT_TR     TYPE TY_T_TR
                                      PT_RESULT TYPE TY_T_TR_RESULT
                              RAISING LCX_EXCEPTION.

  PV_RESULT  = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-SUCCESS.
  PV_MESSAGE = TEXT-S01.

  GS_STOCK_TRANSFER = VALUE #( MODE       = PV_MODE
                               ZSYSTEM_ID = PV_SYSTEM_ID
                               ZRESULT    = PV_RESULT
                               ZMESSAGE   = PV_MESSAGE ).

*// 처리 모드.
  IF PV_MODE IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F01.
  ELSEIF NOT CONTAINS( VAL = PV_MODE  REGEX = '[P,C]' ) ##regex_posix.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E01.
  ENDIF.

*// 송신 시스템.
  IF PV_SYSTEM_ID IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F02.
  ENDIF.

  IF PT_TR IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F43.
  ENDIF.

  PT_RESULT = CORRESPONDING #( PT_TR[] ).
  SORT PT_RESULT BY ZSERNO.

  LOOP AT PT_TR INTO DATA(LS_TR).
    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LS_TR-ZSERNO BINARY SEARCH.

    LR_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.

*// 플랜트.
    IF LS_TR-WERKS IS INITIAL.
      MESSAGE E031 WITH TEXT-F04 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ELSE.

    ENDIF.

*// 전기일자.
    IF LS_TR-BUDAT IS INITIAL.
      MESSAGE E031 WITH TEXT-F22 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// 일련번호.
    IF LS_TR-ZSERNO IS INITIAL.
      MESSAGE E031 WITH TEXT-F44 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// 이동유형.
    IF LS_TR-BWART IS INITIAL.
      MESSAGE E031 WITH TEXT-F24 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*//자재코드.
    IF LS_TR-MATNR IS INITIAL.
      MESSAGE E031 WITH TEXT-F45 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ELSE.
      PERFORM CONVERSION_EXIT_MATN1_INPUT USING LS_TR-MATNR.
    ENDIF.

*// 이전전기 수량.
    IF LS_TR-MENGE IS INITIAL.
      MESSAGE E031 WITH TEXT-F46 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// 수량 단위.
    IF LS_TR-MEINS IS INITIAL.
      MESSAGE E031 WITH TEXT-F47 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// (FROM) 저장위치.
    IF LS_TR-F_LGORT IS INITIAL.
      MESSAGE E031 WITH TEXT-F48 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

*// (TO) 저장위치.
    IF LS_TR-T_LGORT IS INITIAL.
      MESSAGE E031 WITH TEXT-F49 INTO LR_RESULT->ZERP_MESSAGE.
      CONTINUE.
    ENDIF.

    IF PV_MODE EQ 'C'. "// 투입취소.
      IF LS_TR-C_MBLNR IS INITIAL.
        MESSAGE E031 WITH TEXT-F29 INTO LR_RESULT->ZERP_MESSAGE.
        CONTINUE.
      ENDIF.

      IF LS_TR-C_MJAHR IS INITIAL.
        MESSAGE E031 WITH TEXT-F28 INTO LR_RESULT->ZERP_MESSAGE.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF LR_RESULT->ZERP_MESSAGE IS INITIAL.
      LR_RESULT->ZERP_STAT = SPACE.
    ENDIF.

    APPEND LS_TR TO GS_STOCK_TRANSFER-TR.
  ENDLOOP.

  IF LINE_EXISTS( PT_RESULT[ ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E04.
  ENDIF.

  IF GS_STOCK_TRANSFER-TR IS NOT INITIAL.
    SELECT *
      INTO TABLE @GS_STOCK_TRANSFER-ZPPT0001
      FROM ZPPT0001
       FOR ALL ENTRIES IN @GS_STOCK_TRANSFER-TR
     WHERE WERKS EQ @GS_STOCK_TRANSFER-TR-WERKS
       AND TAGNR EQ @GS_STOCK_TRANSFER-TR-F_TAGNR
       AND CHARG EQ @GS_STOCK_TRANSFER-TR-F_CHARG.

    SORT GS_STOCK_TRANSFER-ZPPT0001 BY WERKS TAGNR CHARG.

    SELECT MARC~WERKS, MARC~DISPO,
           MARA~MATNR, MARA~MTART, MARA~MATKL
      INTO TABLE @GS_STOCK_TRANSFER-MAT_INFO
      FROM MARC
      JOIN MARA
        ON MARC~MATNR EQ MARA~MATNR
       FOR ALL ENTRIES IN @GS_STOCK_TRANSFER-TR
     WHERE MARC~WERKS EQ @GS_STOCK_TRANSFER-TR-WERKS
       AND MARC~MATNR EQ @GS_STOCK_TRANSFER-TR-MATNR.

    SORT GS_STOCK_TRANSFER-MAT_INFO BY WERKS MATNR.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_stock_transfer
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_STOCK_TRANSFER RAISING LCX_EXCEPTION.

  DATA LT_ZGTPPT3410 TYPE TABLE OF ZGTPPT3410.

  PERFORM GET_DATE_TIME.

  GET TIME STAMP FIELD GS_STOCK_TRANSFER-ZIFKEY.

  LT_ZGTPPT3410 = VALUE #( FOR LS_TR IN GS_STOCK_TRANSFER-TR
                         ( VALUE #( BASE CORRESPONDING #( LS_TR )  ZIFKEY     = GS_STOCK_TRANSFER-ZIFKEY
                                                                   ZSYSTEM_ID = GS_STOCK_TRANSFER-ZSYSTEM_ID
                                                                   ZSTAT      = GS_STOCK_TRANSFER-ZRESULT
                                                                   ZMESSAGE   = GS_STOCK_TRANSFER-ZMESSAGE
                                                                   IFDAT      = GS_ZGTPPS1001-CRDAT
                                                                   IFTIM      = GS_ZGTPPS1001-CRTIM
                                                                   IFNAM      = GS_ZGTPPS1001-CRNAM ) ) ).

  TRY.
      MODIFY ZGTPPT3410 FROM TABLE LT_ZGTPPT3410.

      COMMIT WORK AND WAIT.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E05.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form processing_stock_transfer
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM PROCESSING_STOCK_TRANSFER  USING PT_RESULT TYPE TY_T_TR_RESULT.
  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.

  LOOP AT GS_STOCK_TRANSFER-TR INTO DATA(LS_TR).
*** 2026.08.28 Start S/O Stock 관련 추가
    SELECT SINGLE VBELN, POSNR
      FROM MSKA
     WHERE MATNR = @LS_TR-MATNR
       AND WERKS = @LS_TR-WERKS
       AND LGORT = @LS_TR-F_LGORT
       AND CHARG = @LS_TR-F_CHARG
       AND KALAB GT 0
      INTO @DATA(LS_MSKA).

    IF SY-SUBRC = 0.  "판매오더 재고
      DATA(LT_ITEM) = VALUE GM_ITEMS_T( ( MATERIAL   = CONV MATNR18( LS_TR-MATNR )
                                          PLANT      = LS_TR-WERKS
                                          STGE_LOC   = LS_TR-F_LGORT
                                          BATCH      = LS_TR-F_CHARG
                                          MOVE_TYPE  = GC_BWART-311
                                          SPEC_STOCK     = 'E'          "특별재고지시자
                                          SALES_ORD      = LS_MSKA-VBELN  "판매오더
                                          S_ORD_ITEM     = LS_MSKA-POSNR  "판매오더 항번
                                          VAL_SALES_ORD  = LS_MSKA-VBELN  "판매오더
                                          VAL_S_ORD_ITEM = LS_MSKA-POSNR  "판매오더 항번
                                          MOVE_PLANT = LS_TR-WERKS
                                          MOVE_STLOC = LS_TR-T_LGORT
                                          MOVE_BATCH = LS_TR-T_CHARG
                                          STCK_TYPE  = SPACE
                                          ENTRY_UOM  = LS_TR-MEINS
                                          ENTRY_QNT  = LS_TR-MENGE ) ).
    ELSE.   "배치 재고
      LT_ITEM = VALUE GM_ITEMS_T( ( MATERIAL   = CONV MATNR18( LS_TR-MATNR )
                                          PLANT      = LS_TR-WERKS
                                          STGE_LOC   = LS_TR-F_LGORT
                                          BATCH      = LS_TR-F_CHARG
                                          MOVE_TYPE  = GC_BWART-311
                                          SPEC_STOCK = SPACE
                                          MOVE_PLANT = LS_TR-WERKS
                                          MOVE_STLOC = LS_TR-T_LGORT
                                          MOVE_BATCH = LS_TR-T_CHARG
                                          STCK_TYPE  = SPACE
                                          ENTRY_UOM  = LS_TR-MEINS
                                          ENTRY_QNT  = LS_TR-MENGE ) ).
    ENDIF.

    CLEAR: LS_HEADRET, LT_RETURN, LS_MSKA.
*** 2026.08.28 End S/O Stock 관련 추가

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = VALUE BAPI2017_GM_HEAD_01( PSTNG_DATE = LS_TR-BUDAT
                                                      DOC_DATE   = LS_TR-BUDAT
                                                      HEADER_TXT = LS_TR-ZSERNO )
        GOODSMVT_CODE    = ZGTPP_IF_CONST=>GC_GM_CODE-TRANSFER_POSTING
      IMPORTING
        GOODSMVT_HEADRET = LS_HEADRET
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.

    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LS_TR-ZSERNO BINARY SEARCH.

    PERFORM UPDATE_STOCK_TRANSFER_LOG USING LS_TR LR_RESULT->* LS_HEADRET LT_RETURN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form canceling_stock_transfer
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CANCELING_STOCK_TRANSFER  USING PT_RESULT TYPE TY_T_TR_RESULT.
  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.

  LOOP AT GS_STOCK_TRANSFER-TR INTO DATA(LS_TR).
    CLEAR: LS_HEADRET, LT_RETURN.

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = LS_TR-C_MBLNR
        MATDOCUMENTYEAR     = LS_TR-C_MJAHR
        GOODSMVT_PSTNG_DATE = LS_TR-BUDAT
      IMPORTING
        GOODSMVT_HEADRET    = LS_HEADRET
      TABLES
        RETURN              = LT_RETURN.

    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LS_TR-ZSERNO BINARY SEARCH.

    PERFORM UPDATE_STOCK_TRANSFER_LOG USING LS_TR LR_RESULT->* LS_HEADRET LT_RETURN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_stock_transfer_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_STOCK_TRANSFER_LOG  USING PS_TR      TYPE ZGTPPSIF0056
                                      PS_RESULT  TYPE ZGTPPSIF0057
                                      PS_HEADRET TYPE BAPI2017_GM_HEAD_RET
                                      PT_RETURN  TYPE TT_BAPIRET2.

  PS_RESULT = VALUE #( BASE PS_RESULT  MBLNR        = PS_HEADRET-MAT_DOC
                                       MJAHR        = PS_HEADRET-DOC_YEAR
                                       ZERP_STAT    = COND #( WHEN PS_HEADRET-MAT_DOC IS NOT INITIAL THEN ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                                              ELSE ZGTPP_IF_CONST=>GC_RESULT-ERROR )
                                       ZERP_MESSAGE = COND #( WHEN PS_HEADRET-MAT_DOC IS NOT INITIAL THEN COND #( WHEN GS_STOCK_TRANSFER-MODE EQ 'P' THEN TEXT-S05
                                                                                                                  ELSE TEXT-S06 )
                                                              ELSE VALUE #( PT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ) ) ).
*// 1. 재고 이전전기 수신 이력.
  UPDATE ZGTPPT3410
     SET MBLNR        = PS_RESULT-MBLNR
         MJAHR        = PS_RESULT-MJAHR
         ZSTAT        = GS_STOCK_TRANSFER-ZRESULT
         ZMESSAGE     = GS_STOCK_TRANSFER-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
  WHERE ZIFKEY     EQ GS_STOCK_TRANSFER-ZIFKEY
    AND ZSYSTEM_ID EQ GS_STOCK_TRANSFER-ZSYSTEM_ID
    AND ZSERNO     EQ PS_TR-ZSERNO.

*// 2. 꼬리표 테이블 Update.
*// 2-1. From 꼬리표 Update.
  READ TABLE GS_STOCK_TRANSFER-ZPPT0001 REFERENCE INTO DATA(LR_ZPPT0001) WITH KEY WERKS = PS_TR-WERKS
                                                                                  TAGNR = PS_TR-F_TAGNR
                                                                                  CHARG = PS_TR-F_CHARG BINARY SEARCH.
  IF SY-SUBRC IS INITIAL.
    LR_ZPPT0001->REMAIN = COND #( WHEN GS_STOCK_TRANSFER-MODE EQ 'P' THEN ( LR_ZPPT0001->REMAIN - PS_TR-MENGE )
                                  WHEN GS_STOCK_TRANSFER-MODE EQ 'C' THEN ( LR_ZPPT0001->REMAIN + PS_TR-MENGE ) ).

    UPDATE ZPPT0001
       SET REMAIN = LR_ZPPT0001->REMAIN
    WHERE WERKS EQ PS_TR-WERKS
      AND TAGNR EQ PS_TR-F_TAGNR
      AND CHARG EQ PS_TR-F_CHARG.
  ENDIF.

*// 2-2. To 꼬리표 Update.
  IF GS_STOCK_TRANSFER-MODE EQ 'P'. "// 이전전기처리.
*** 101과 중복으로 311 꼬리표가 한건 더 생성됨. 주석 처리
*    READ TABLE GS_STOCK_TRANSFER-MAT_INFO INTO DATA(LS_MAT_INFO) WITH KEY WERKS = PS_TR-WERKS
*                                                                          MATNR = PS_TR-MATNR BINARY SEARCH.
*
*    MODIFY ZPPT0001 FROM @( VALUE #( WERKS   = PS_TR-WERKS
*                                     TAGNR   = PS_TR-T_TAGNR
*                                     CHARG   = PS_TR-T_CHARG
*                                     MBLNR   = PS_RESULT-MBLNR
*                                     MATNR   = PS_TR-MATNR
*                                     SPGCD   = LS_MAT_INFO-DISPO(2)
*                                     PROCD   = LS_MAT_INFO-MATKL+4(3)
*                                     MGVRG   = PS_TR-MENGE
*                                     FOSTCNT = '1'
*                                     REMAIN  = PS_TR-MENGE
*                                     MEINS   = PS_TR-MEINS
*                                     GIFLG   = 'N'
*                                     GRFLG   = 'Y'
*                                     INSPFLG = 'OK'
*                                     LGORT   = PS_TR-T_LGORT
*                                     WKDAT   = GS_ZGTPPS1001-CRDAT
*                                     WKINDAT = GS_ZGTPPS1001-CRDAT
*                                     WKINTIM = GS_ZGTPPS1001-CRTIM
*                                     WKINNAM = GS_ZGTPPS1001-CRNAM
*                                     GRINDAT = GS_ZGTPPS1001-CRDAT
*                                     GRINTIM = GS_ZGTPPS1001-CRTIM
*                                     GRINNAM = GS_ZGTPPS1001-CRNAM ) ).
  ELSE.
*** 311을 취소하더라도, 101 입고된 꼬리표를 삭제하면 안됨
*    DELETE FROM ZPPT0001 WHERE WERKS EQ PS_TR-WERKS
*                           AND TAGNR EQ PS_TR-F_TAGNR
*                           AND CHARG EQ PS_TR-F_CHARG.
  ENDIF.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_para_phy_inv_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_PARA_PHY_INV_RESULT  TABLES PT_RESULT STRUCTURE ZGTPPSIF0060
                                 USING PV_SYSTEM_ID PV_RESULT PV_MESSAGE
                               RAISING LCX_EXCEPTION.

*// 송신 시스템.
  IF PV_SYSTEM_ID IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F02.
  ENDIF.

  IF PT_RESULT[] IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F52.
  ENDIF.

  PV_RESULT  = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-SUCCESS.
  PV_MESSAGE = TEXT-S01.

  GS_PHY_INV = VALUE #( ZSYSTEM_ID = PV_SYSTEM_ID
                        ZRESULT    = PV_RESULT
                        ZMESSAGE   = PV_MESSAGE ).

  PERFORM CONV_PARA_PHY_INV_RESULT TABLES PT_RESULT.

  PERFORM CHECK_PARA_VALIDATION_PHY_INV.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_phy_inv_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_PHY_INV_RESULT RAISING LCX_EXCEPTION.

  TRY.
      MODIFY ZPPT0600 FROM TABLE GS_PHY_INV-ZPPT0600.

      COMMIT WORK AND WAIT.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E05.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conv_para_phy_inv_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONV_PARA_PHY_INV_RESULT  TABLES PT_RESULT STRUCTURE ZGTPPSIF0060.

  DATA(LV_DATUM) = SY-DATUM.
  DATA(LV_UZEIT) = SY-UZEIT.

  LOOP AT PT_RESULT INTO DATA(LS_RESULT).
    APPEND INITIAL LINE TO GS_PHY_INV-ZPPT0600 REFERENCE INTO DATA(LR_ZPPT0600).

    LR_ZPPT0600->* = VALUE #( BASE CORRESPONDING #( LS_RESULT )  INVDA = LV_DATUM
                                                                 INVTM = LV_UZEIT ).

    PERFORM CONVERSION_EXIT_MATN1_INPUT USING LR_ZPPT0600->MATNR.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_para_validation_phy_inv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_PARA_VALIDATION_PHY_INV RAISING LCX_EXCEPTION.

  DATA LT_ZGTPPT1010 TYPE SORTED TABLE OF ZGTPPT1010 WITH NON-UNIQUE KEY FLD_01 FLD_03.
  DATA LT_T001W TYPE SORTED TABLE OF T001W WITH NON-UNIQUE KEY WERKS.
  DATA LT_T001L TYPE SORTED TABLE OF T001L WITH NON-UNIQUE KEY WERKS LGORT.

  LT_ZGTPPT1010 = ZGTPP_CL_COMMON=>GET_CODE_VALUE( IV_CODEGRP = '0010' ).

  SELECT WERKS INTO CORRESPONDING FIELDS OF TABLE @LT_T001W FROM T001W.

  SELECT WERKS, LGORT INTO CORRESPONDING FIELDS OF TABLE @LT_T001L FROM T001L.

  SELECT MARC~MATNR, MARC~WERKS
    FROM @GS_PHY_INV-ZPPT0600 AS ZT01
    JOIN MARC
      ON ZT01~MATNR EQ MARC~MATNR
     AND ZT01~WERKS EQ MARC~WERKS
   ORDER BY MARC~MATNR, MARC~WERKS
    INTO TABLE @DATA(LT_MARC).

  LOOP AT GS_PHY_INV-ZPPT0600 INTO DATA(LS_ZPPT0600).
*// 재고실사년월.
    IF LS_ZPPT0600-INSMM IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F50.
    ENDIF.

*// 플랜트.
    IF LS_ZPPT0600-WERKS IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F04.
    ELSEIF NOT LINE_EXISTS( LT_T001W[ WERKS = LS_ZPPT0600-WERKS ] ).
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E011(VF) WITH LS_ZPPT0600-WERKS.
    ENDIF.

*// 저장위치.
    IF LS_ZPPT0600-LGORT IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F07.
    ELSEIF NOT LINE_EXISTS( LT_T001L[ WERKS = LS_ZPPT0600-WERKS
                                      LGORT = LS_ZPPT0600-LGORT ] ).
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E103(M3) WITH LS_ZPPT0600-LGORT LS_ZPPT0600-WERKS.
    ENDIF.

*//자재번호.
    IF LS_ZPPT0600-MATNR IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F51.
    ELSE.
      READ TABLE LT_MARC TRANSPORTING NO FIELDS WITH KEY MATNR = LS_ZPPT0600-MATNR
                                                         WERKS = LS_ZPPT0600-WERKS BINARY SEARCH.
      IF SY-SUBRC IS NOT INITIAL.
        RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E200(M3) WITH LS_ZPPT0600-MATNR LS_ZPPT0600-WERKS.
      ENDIF.
    ENDIF.

*//재고차이 조정 진행여부 점검 - 1건이라도 진행된 경우 재수신 불가
    SELECT SINGLE IBLNR, MBLNR
      FROM ZPPT0600
     WHERE INSMM EQ @LS_ZPPT0600-INSMM
       AND WERKS EQ @LS_ZPPT0600-WERKS
       AND LGORT EQ @LS_ZPPT0600-LGORT
       AND IBLNR NE @SPACE
       AND MBLNR NE @SPACE
      INTO (@DATA(LV_IBLNR), @DATA(LV_MBLNR)).

    IF SY-SUBRC EQ 0.
      "이미 재고실사 차이 조정이 발생하여 결과 수신이 불가합니다.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E036.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CHECK_PARA_QC_USAGE_DECSION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_MODE
*&      --> I_SYSTEM_ID
*&      --> ZO_RESULT
*&      --> ZO_MESSAGE
*&      --> IT_ITEM[]
*&      --> OT_RESULT[]
*&---------------------------------------------------------------------*
FORM CHECK_PARA_QC_USAGE_DECSION  USING PV_MODE
                                        PV_SYSTEM_ID
                                        PV_RESULT
                                        PV_MESSAGE
                                        PT_ITEM TYPE TY_T_QC
                                        PT_RESULT TYPE TY_T_QC_RESULT
                                RAISING LCX_EXCEPTION.

  DATA: LT_CHAR LIKE TABLE OF API_VALI WITH HEADER LINE.
  DATA: LV_MATKL TYPE MATKL.

  PV_RESULT  = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-SUCCESS.
  PV_MESSAGE = TEXT-S01.

  GS_QC_USAGE_DECSION = VALUE #( ZMODE      = PV_MODE
                                 ZSYSTEM_ID = PV_SYSTEM_ID
                                 ZRESULT    = PV_RESULT
                                 ZMESSAGE   = PV_MESSAGE ).

*// 처리 모드.
  IF PV_MODE IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F01.
  ELSEIF NOT CONTAINS( VAL = PV_MODE  REGEX = '[P,R,N,C]' ) ##regex_posix.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E01.
  ENDIF.

*// 송신 시스템.
  IF PV_SYSTEM_ID IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F02.
  ENDIF.

  IF PT_ITEM IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F52.
  ENDIF.

  PT_RESULT = CORRESPONDING #( PT_ITEM[] ).
  SORT PT_RESULT BY ZSERNO.

  LOOP AT PT_ITEM INTO DATA(LS_ITEM).
    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT)
                         WITH KEY ZSERNO = LS_ITEM-ZSERNO BINARY SEARCH.

    LR_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.

*// 일련번호.
    IF LS_ITEM-ZSERNO IS INITIAL.
      MESSAGE E031 WITH TEXT-F44 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
      CONTINUE.
    ENDIF.

*//자재코드.
    IF LS_ITEM-MATNR IS INITIAL.
      MESSAGE E031 WITH TEXT-F45 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
      CONTINUE.
    ELSE.
      PERFORM CONVERSION_EXIT_MATN1_INPUT USING LS_ITEM-MATNR.
    ENDIF.

*// 플랜트.
    IF LS_ITEM-WERKS IS INITIAL.
      MESSAGE E031 WITH TEXT-F04 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
      CONTINUE.
    ENDIF.

*// SPG코드.
    IF LS_ITEM-SPGCD IS INITIAL.
      MESSAGE E031 WITH TEXT-F21 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
      CONTINUE.
    ENDIF.

*// 전기일자.
    IF LS_ITEM-BUDAT IS INITIAL.
      MESSAGE E031 WITH TEXT-F22 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
      CONTINUE.
    ENDIF.

*// (FROM) 저장위치.
    IF LS_ITEM-LGORT_F IS INITIAL.
      MESSAGE E031 WITH TEXT-F48 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
      CONTINUE.
    ENDIF.

*// (TO) 저장위치.
    IF LS_ITEM-LGORT IS INITIAL.
      MESSAGE E031 WITH TEXT-F49 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
      CONTINUE.
    ENDIF.

*// 합부판정
    IF LS_ITEM-DECISION IS INITIAL.
      MESSAGE E031 WITH TEXT-F53 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
      CONTINUE.
    ENDIF.

*// 수량.
    IF LS_ITEM-MENGE IS INITIAL.
      MESSAGE E031 WITH TEXT-F54 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
      CONTINUE.
    ENDIF.

*// 단위.
    IF LS_ITEM-MEINS IS INITIAL.
      MESSAGE E031 WITH TEXT-F39 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
      CONTINUE.
    ENDIF.

*// 배치.
    IF LS_ITEM-CHARG IS INITIAL.
      MESSAGE E031 WITH TEXT-F16 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
      CONTINUE.
    ENDIF.

    IF PV_MODE EQ 'C'. "// 투입취소.
      IF LS_ITEM-C_MBLNR IS INITIAL.
        MESSAGE E031 WITH TEXT-F29 INTO LR_RESULT->ZERP_MESSAGE.
        APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
        CONTINUE.
      ENDIF.

      IF LS_ITEM-C_MJAHR IS INITIAL.
        MESSAGE E031 WITH TEXT-F28 INTO LR_RESULT->ZERP_MESSAGE.
        APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF PV_MODE NE 'C'.
*// 합부판정 수량, 단위
      CLEAR: GV_QCQTY, GV_QCMEINS.
      IF LS_ITEM-MEINS EQ 'ST'.
        "수량 변환 : 조장(SAP_MILLCA_LENGTH) * I/F 수량
        CLEAR: LT_CHAR, LT_CHAR[].
        CALL FUNCTION 'ZQC01_BATCH_VALUES_READ'
          EXPORTING
            I_VAL_MATNR                  = LS_ITEM-MATNR
            I_VAL_WERKS                  = LS_ITEM-WERKS
            I_VAL_CHARGE                 = LS_ITEM-CHARG
          TABLES
            T_VAL_TAB                    = LT_CHAR
          EXCEPTIONS
            INSTANCE_NOT_FOUND           = 1
            INSTANCE_IS_A_CLASSIFICATION = 2
            INVALID_DATA                 = 3
            OTHERS                       = 4.

        SORT LT_CHAR BY ATNAM.
        READ TABLE LT_CHAR INTO DATA(LS_CHAR) WITH KEY ATNAM = 'SAP_MILLCA_LENGTH'.
        IF SY-SUBRC EQ 0.
*          GV_QCQTY = LS_CHAR-ATWRT * LS_ITEM-MENGE.
          GV_QCQTY = LS_CHAR-ATFLV * LS_ITEM-MENGE.
          GV_QCMEINS = 'M'.
        ENDIF.
      ELSE.
        GV_QCQTY = LS_ITEM-MENGE.
        GV_QCMEINS = LS_ITEM-MEINS.
      ENDIF.

*** Start 2026.08.04 판매오더 재고 추출 변경
      IF LS_ITEM-VBELN IS INITIAL.
        "배치재고
        SELECT SINGLE
               A~MATNR, A~CLABS, A~CINSM,
               B~MEINS
          FROM MCHB AS A
         INNER JOIN MARA AS B ON B~MATNR EQ A~MATNR
         WHERE A~MATNR EQ @LS_ITEM-MATNR
           AND A~WERKS EQ @LS_ITEM-WERKS
           AND A~LGORT EQ @LS_ITEM-LGORT_F
           AND A~CHARG EQ @LS_ITEM-CHARG
           AND ( A~CLABS GT 0 OR A~CINSM GT 0 )
          INTO @DATA(LS_MCHB).
      ELSE.
        "판매오더 재고 추출
        SELECT SINGLE
               A~MATNR, A~KALAB AS CLABS, A~KAINS AS CINSM,
               B~MEINS
          FROM MSKA AS A
         INNER JOIN MARA AS B ON B~MATNR EQ A~MATNR
         WHERE A~MATNR = @LS_ITEM-MATNR
           AND A~WERKS = @LS_ITEM-WERKS
           AND A~LGORT = @LS_ITEM-LGORT_F
           AND A~CHARG = @LS_ITEM-CHARG
           AND A~VBELN = @LS_ITEM-VBELN
           AND A~POSNR = @LS_ITEM-POSNR
           AND ( A~KALAB GT 0 OR A~KAINS GT 0 )
          INTO @LS_MCHB.
      ENDIF.
*** End 2026.08.04 판매오더 재고 추출 변경

*// 합부판정 재고 존재 여부 확인
      CASE PV_MODE.
        WHEN 'P'.  "품질검사 대기재고 확인
          IF LS_MCHB-CINSM EQ 0 OR LS_MCHB-CINSM LT GV_QCQTY.
            MESSAGE E000 WITH TEXT-E10 INTO LR_RESULT->ZERP_MESSAGE.
          ENDIF.
        WHEN 'R' OR 'N'.  "가용재고 확인
          IF LS_MCHB-CLABS EQ 0 OR LS_MCHB-CLABS LT GV_QCQTY.
            MESSAGE E000 WITH TEXT-E11 INTO LR_RESULT->ZERP_MESSAGE.
          ENDIF.
      ENDCASE.

*// ZGTPPT1140 스크랩 코드 체크
      IF LS_ITEM-SPGCD NE 'GO'.
        CLEAR: LV_MATKL.

        " Dummy 스크랩 자재코드 추출
        SELECT SINGLE WERKS, MATNR
          FROM ZGTPPT1140
         WHERE WERKS = @LS_ITEM-WERKS
           AND SPGCD = @LS_ITEM-SPGCD
           AND MATKL = 'DUMMY'
          INTO (@DATA(LV_SC_WERKS), @DATA(LV_SC_MATNR)).

        IF SY-SUBRC NE 0.
          LV_MATKL = 'DUMMY'.
          MESSAGE E041 WITH LS_ITEM-SPGCD LV_MATKL INTO LR_RESULT->ZERP_MESSAGE.
          APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
          CONTINUE.
        ENDIF.

        "대상 자재의 공정그룹(자재그룹) 추출
        SELECT SINGLE MATKL
          FROM MARA
         WHERE MATNR = @LS_ITEM-MATNR
          INTO @LV_MATKL.

        "생산스크랩 자재코드 추출
        SELECT SINGLE WERKS, MATNR
          FROM ZGTPPT1140
         WHERE WERKS = @LS_ITEM-WERKS
           AND SPGCD = @LS_ITEM-SPGCD
           AND MATKL = @LV_MATKL
          INTO (@DATA(LV_SC_WERKS_I), @DATA(LV_SC_MATNR_I)).

        IF SY-SUBRC NE 0.
          MESSAGE E041 WITH LS_ITEM-SPGCD LV_MATKL INTO LR_RESULT->ZERP_MESSAGE.
          APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
          CONTINUE.
        ENDIF.
      ENDIF.

*// 판매오더 조장 길이 점검 비교
      IF LS_ITEM-VBELN IS NOT INITIAL.
        "합부 판정 대상 배치번호의 생산오더 품목 정보 확인

        SELECT SINGLE AUFNR, AUFPS
          FROM MATDOC
         WHERE WERKS = @LS_ITEM-WERKS
           AND MATNR = @LS_ITEM-MATNR
           AND CHARG = @LS_ITEM-CHARG
           AND CANCELLED NE 'X'
           AND BWART = '101'
          INTO (@DATA(LV_AUFNR), @DATA(LV_AUFPS)).

        "생산 오더의 검사 여장+시료 여장 정보 존재 유무 확인
        CLEAR: GV_SCQTY.
        SELECT SINGLE PSAMG, PSMNG
          FROM ZPPTC002
         WHERE AUFNR EQ @LV_AUFNR
           AND POSNR EQ @LV_AUFPS
          INTO (@DATA(LV_PSAMG), @DATA(LV_PSMNG)).

        GV_SCQTY = LV_PSAMG + LV_PSMNG.

        "판매오더 개별 조장 길이 추출
        SELECT SINGLE MILL_LENGTH
          FROM ZGTSD_CV_GET_VCOFSO
         WHERE VBELN EQ @LS_ITEM-VBELN
           AND POSNR EQ @LS_ITEM-POSNR
          INTO @DATA(LV_LENGTH).

        "I/F 받은 M 단위의 수량 - 여장 수량 총길이 < 판매오더 개별 조장 길이
        IF GV_QCQTY - GV_SCQTY < LV_LENGTH.
          MESSAGE E042 INTO LR_RESULT->ZERP_MESSAGE.
          APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
          CLEAR: LV_AUFNR, LV_AUFPS, LV_PSAMG, LV_PSMNG, LV_LENGTH.
          CONTINUE.
        ENDIF.
        CLEAR: LV_AUFNR, LV_AUFPS, LV_PSAMG, LV_PSMNG, LV_LENGTH.
      ENDIF.

    ENDIF.

    IF LR_RESULT->ZERP_MESSAGE IS INITIAL.
      LR_RESULT->ZERP_STAT = SPACE.
    ENDIF.

    APPEND LS_ITEM TO GS_QC_USAGE_DECSION-QC.
  ENDLOOP.

  PERFORM SAVE_QC_USAGE_DECSION USING PT_RESULT.

  IF LINE_EXISTS( PT_RESULT[ ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E04.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_QC_USAGE_DECSION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_QC_USAGE_DECSION USING PT_RESULT TYPE TY_T_QC_RESULT
                           RAISING LCX_EXCEPTION.

  DATA LT_ZGTPPT3440 TYPE TABLE OF ZGTPPT3440.

  PERFORM GET_DATE_TIME.

  GET TIME STAMP FIELD GS_QC_USAGE_DECSION-ZIFKEY.

  LT_ZGTPPT3440 = VALUE #( FOR LS_QC IN GS_QC_USAGE_DECSION-QC
                         ( VALUE #( BASE CORRESPONDING #( LS_QC ) ZIFKEY     = GS_QC_USAGE_DECSION-ZIFKEY
                                                                  ZSYSTEM_ID = GS_QC_USAGE_DECSION-ZSYSTEM_ID
                                                                  ZMODE      = GS_QC_USAGE_DECSION-ZMODE
                                                                  ZSTAT      = GS_QC_USAGE_DECSION-ZRESULT
                                                                  ZMESSAGE   = GS_QC_USAGE_DECSION-ZMESSAGE
                                                                  IFDAT      = GS_ZGTPPS1001-CRDAT
                                                                  IFTIM      = GS_ZGTPPS1001-CRTIM
                                                                  IFNAM      = GS_ZGTPPS1001-CRNAM ) ) ).

  LOOP AT LT_ZGTPPT3440 ASSIGNING FIELD-SYMBOL(<FS_S>).
    READ TABLE PT_RESULT INTO DATA(LS_RESULT) WITH KEY ZSERNO = <FS_S>-ZSERNO.

    IF SY-SUBRC EQ 0.
      <FS_S>-ZERP_STAT = LS_RESULT-ZERP_STAT.
      <FS_S>-ZERP_MESSAGE = LS_RESULT-ZERP_MESSAGE.
    ENDIF.
  ENDLOOP.

  TRY.
      MODIFY ZGTPPT3440 FROM TABLE LT_ZGTPPT3440.

      COMMIT WORK AND WAIT.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E05.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form processing_qc_usage_decsion
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> OT_RESULT[]
*&---------------------------------------------------------------------*
FORM PROCESSING_QC_USAGE_DECSION  USING PV_MODE
                                        PT_RESULT TYPE TY_T_QC_RESULT.

  LOOP AT GS_QC_USAGE_DECSION-QC INTO DATA(LS_QC).

    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LS_QC-ZSERNO BINARY SEARCH.

*// 1. 품질 검사 합부 판정 재고 이동
    CLEAR: GV_MBLNR, GV_MESSAGE_M, GV_MJAHR.
    PERFORM PROC_QC_MOVE USING LS_QC PV_MODE.

    IF GV_MBLNR IS INITIAL.
      "합부판정 회신 및 이력 저장
      PERFORM UPDATE_QC_MOVE_LOG USING LS_QC LR_RESULT->*.
    ENDIF.

    CHECK GV_MBLNR IS NOT INITIAL.

* FACTOR 배치 특성값 업데이트
    CLEAR: GV_MESSAGE_FB.
    PERFORM UPDATE_FACTOR_BATCH USING LS_QC LR_RESULT->*.

    "합부판정 회신 및 이력 저장
    PERFORM UPDATE_QC_MOVE_LOG USING LS_QC LR_RESULT->*.

    CHECK GV_MBLNR IS NOT INITIAL.

    IF LS_QC-SPGCD EQ 'GO'.
*// 기존에 937 처리 이력이 있는지 CHECK
      SELECT SINGLE MBLNR
        FROM MATDOC
       WHERE WERKS = @LS_QC-WERKS
         AND MATNR = @LS_QC-MATNR
         AND CHARG = @LS_QC-CHARG
         AND CANCELLED NE 'X'
         AND BWART = '937'
        INTO @DATA(LV_MBLNR_937).

      CHECK LV_MBLNR_937 IS INITIAL.

*// 2. 생산 오더의 검사 여장+시료 여장 길이 스크랩 처리
      "합부 판정 대상 배치번호의 생산오더 품목 정보 확인
      SELECT SINGLE AUFNR, AUFPS
        FROM MATDOC
       WHERE WERKS = @LS_QC-WERKS
         AND MATNR = @LS_QC-MATNR
         AND CHARG = @LS_QC-CHARG
         AND CANCELLED NE 'X'
         AND BWART = '101'
        INTO (@DATA(LV_AUFNR), @DATA(LV_AUFPS)).

      "생산 오더의 검사 여장+시료 여장 정보 존재 유무 확인
      CLEAR: GV_SCQTY.
      SELECT SINGLE PSAMG, PSMNG
        FROM ZPPTC002
       WHERE AUFNR EQ @LV_AUFNR
         AND POSNR EQ @LV_AUFPS
        INTO (@DATA(LV_PSAMG), @DATA(LV_PSMNG)).

      GV_SCQTY = LV_PSAMG + LV_PSMNG.

      CHECK GV_SCQTY NE 0.

*// 2.2 스크랩 대상 자재의 폐기처리(937)
      CLEAR: GV_MBLNR_O, GV_MESSAGE_MO.
      PERFORM PROC_MBLNR_O USING LS_QC
                                 '937'
                                 GV_SCQTY
                                 ''
                        CHANGING GV_MBLNR_O
                                 GV_MESSAGE_MO.

      PERFORM UPDATE_MBLNR_O_LOG_937 USING LS_QC LR_RESULT->*.

    ELSE.
*// 여장 스크랩 중복 처리 방지
*// 여장 기존에 출고 이력이 있는 경우 하위 프로세트 skip.
      SELECT SINGLE MBLNR
        FROM MATDOC
       WHERE WERKS = @LS_QC-WERKS
         AND MATNR = @LS_QC-MATNR
         AND CHARG = @LS_QC-CHARG
         AND CANCELLED NE 'X'
         AND BWART = '957'
        INTO @DATA(LV_MBLNR_957).

      CHECK LV_MBLNR_957 IS INITIAL.

*// 2. 생산 오더의 검사 여장+시료 여장 길이 스크랩 처리
      "합부 판정 대상 배치번호의 생산오더 품목 정보 확인
      CLEAR: LV_AUFNR, LV_AUFPS.
      SELECT SINGLE AUFNR, AUFPS
        FROM MATDOC
       WHERE WERKS = @LS_QC-WERKS
         AND MATNR = @LS_QC-MATNR
         AND CHARG = @LS_QC-CHARG
         AND CANCELLED NE 'X'
         AND BWART = '101'
        INTO (@LV_AUFNR, @LV_AUFPS).

      "생산 오더의 검사 여장+시료 여장 정보 존재 유무 확인
      CLEAR: GV_SCQTY, LV_PSAMG, LV_PSMNG.
      SELECT SINGLE PSAMG, PSMNG
        FROM ZPPTC002
       WHERE AUFNR EQ @LV_AUFNR
         AND POSNR EQ @LV_AUFPS
        INTO (@LV_PSAMG, @LV_PSMNG).

      GV_SCQTY = LV_PSAMG + LV_PSMNG.

      CHECK GV_SCQTY NE 0.

*// 2.1 검사여장 정보 스크랩 처리할 CO 생산오더 생성
      "사업영역 추출
      SELECT SINGLE GSBER
        FROM T134G
       WHERE WERKS = @LS_QC-WERKS
        INTO @DATA(LV_GSBER).

      "dummy 스크랩 자재코드 추출
      SELECT SINGLE WERKS, MATNR
        FROM ZGTPPT1140
       WHERE WERKS = @LS_QC-WERKS
         AND SPGCD = @LS_QC-SPGCD
         AND MATKL = 'DUMMY'
        INTO (@DATA(LV_SC_WERKS), @DATA(LV_SC_MATNR)).

      CLEAR: GV_CO_ORDER, GV_MESSAGE_CO.
      PERFORM PROC_KKF1 USING LV_SC_MATNR     "스크랩자재코드
                              LV_SC_WERKS     "플랜트
                              LV_GSBER        "사업영역
                     CHANGING GV_CO_ORDER     "CO생산오더
                              GV_MESSAGE_CO.  "메시지

      PERFORM UPDATE_KKF1_LOG USING LS_QC LR_RESULT->*.

      CHECK GV_CO_ORDER IS NOT INITIAL.

*// 2.2 스크랩 대상 자재의 중량 CO 생산오더 투입(957)
      "CO 오더에 투입
      CLEAR: GV_MBLNR_O, GV_MESSAGE_MO.
      PERFORM PROC_MBLNR_O USING LS_QC
                                 '957'
                                 GV_SCQTY
                                 GV_CO_ORDER
                        CHANGING GV_MBLNR_O
                                 GV_MESSAGE_MO.

      PERFORM UPDATE_MBLNR_O_LOG USING LS_QC LR_RESULT->*.

      CHECK GV_MBLNR_O IS NOT INITIAL.

*// 2.3 스크랩 대상 자재의 수량 CO 생산오더 입고(977)
      "해당 자재의 스크랩 환산 단위 CONVERSION
      CLEAR: GV_CONVQTY.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          I_MATNR              = LS_QC-MATNR
          I_IN_ME              = GV_QCMEINS
          I_OUT_ME             = 'KG'
          I_MENGE              = GV_SCQTY
        IMPORTING
          E_MENGE              = GV_CONVQTY
        EXCEPTIONS
          ERROR_IN_APPLICATION = 1
          ERROR                = 2
          OTHERS               = 3.

***  2026.06.25 ksw ***
      IF SY-SUBRC NE 0.
        SELECT SINGLE MATNR_N, NTGEW, GEWEI
          FROM ZEDT1050
         WHERE MATNR_N = @LS_QC-MATNR
          INTO @DATA(LS_WEIGHT).

        IF SY-SUBRC = 0.
          GV_CONVQTY = GV_SCQTY * LS_WEIGHT-NTGEW / 1000.
          "스크랩 처리 중량 = 스크랩 처리 길이 * 설계서 순 중량 / 1000(설계서 기본단위)
        ELSE.
*  설계서 중량 정보 없으면, 자재마스터 순중량 대입
          SELECT SINGLE MATNR, NTGEW, GEWEI, MTART, SPART
            FROM MARA
           WHERE MATNR = @LS_QC-MATNR
            INTO @DATA(LS_MARA).
          IF SY-SUBRC = 0.
            IF LS_MARA-MTART = 'MCHA' OR LS_MARA-MTART = 'MCHF'.  "순수상품은 M/중량단위 = 환산량
              IF LS_MARA-GEWEI = 'G'.
                GV_CONVQTY = GV_SCQTY * LS_MARA-NTGEW.        "NTGEW = M/G
              ELSEIF LS_MARA-GEWEI = 'KG'.
                GV_CONVQTY = GV_SCQTY * LS_MARA-NTGEW / 1000. "NTGEW = M/KG으로, NTGEW / 1000 = M/G은 총 스크랩 중량
              ENDIF.
            ELSEIF LS_MARA-MTART = 'MCFE' AND LS_MARA-SPART = '23'.
              GV_CONVQTY = GV_SCQTY * LS_MARA-NTGEW / 1000. "NTGEW = M/KG으로, CONVQTY = M * KG은 총 스크랩 중량
            ELSE.
              GV_CONVQTY = GV_SCQTY * LS_MARA-NTGEW.        "NTGEW = M/G
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
***  2026.06.25 ksw ***

      "대상 자재의 공정그룹(자재그룹) 추출
      SELECT SINGLE MATKL
        FROM MARA
       WHERE MATNR = @LS_QC-MATNR
        INTO @DATA(LV_MATKL).

      "반제품의 자재그룹(공정그룹) 기준의 생산스크랩 자재코드 추출
      SELECT SINGLE WERKS, MATNR
        FROM ZGTPPT1140
       WHERE WERKS = @LS_QC-WERKS
         AND SPGCD = @LS_QC-SPGCD
         AND MATKL = @LV_MATKL
        INTO (@DATA(LV_SC_WERKS_I), @DATA(LV_SC_MATNR_I)).

      SELECT SINGLE LGORT
        FROM ZGTPPT1120
       WHERE WERKS = @LS_QC-WERKS
         AND SPGCD = @LS_QC-SPGCD
        INTO @DATA(LV_SC_LGORT_I).

      "CO 오더에 입고
      CLEAR: GV_MBLNR_I, GV_MESSAGE_MI.
      PERFORM PROC_MBLNR_I USING LS_QC
                                 '977'
                                 LV_SC_MATNR_I  "스크랩 입고 자재
                                 LV_SC_WERKS_I  "스크랩 입고 플랜트
                                 LV_SC_LGORT_I  "스크랩 입고 저장위치
                                 GV_CONVQTY
                                 GV_CO_ORDER
                        CHANGING GV_MBLNR_I
                                 GV_MESSAGE_MI.

      PERFORM UPDATE_MBLNR_I_LOG USING LS_QC LR_RESULT->*.

      CHECK GV_MBLNR_I IS NOT INITIAL.

      "0입고 저장위치 추출
      SELECT SINGLE LGORT
        FROM ZGTPPT1120
       WHERE WERKS EQ @LS_QC-WERKS
         AND SPGCD EQ @LS_QC-SPGCD
        INTO @DATA(LV_LGORT_Z).

      "매출원가 대체용 SCRAP 0 입고 처리
      CLEAR: GV_MBLNR_Z, GV_MESSAGE_MZ.
      PERFORM PROC_MBLNR_Z USING LS_QC
                                 '101'
                                 LV_SC_MATNR "dummy 스크랩 자재
                                 LV_SC_WERKS "dummy 스크랩 플랜트
                                 LV_LGORT_Z
                                 GV_CO_ORDER
                        CHANGING GV_MBLNR_Z
                                 GV_MESSAGE_MZ.

      PERFORM UPDATE_MBLNR_Z_LOG USING LS_QC LR_RESULT->*.

*// 957, 977, 0입고 모두 처리 성공 시
*// 공정 외 스크랩 처리 내역 INSERT(ZGTCOT4370)
      CHECK GV_MBLNR_O IS NOT INITIAL.
      CHECK GV_MBLNR_I IS NOT INITIAL.
      CHECK GV_MBLNR_Z IS NOT INITIAL.

      PERFORM SAVE_ZGTCOT4370 USING LS_QC
                                    GV_CO_ORDER     "CO오더
                                    LV_SC_MATNR_I   "스크랩입고자재
                                    LV_SC_LGORT_I   "스크랩입고저장위치
                                    GV_CONVQTY      "스크랩입고수량
                                    GV_SCQTY        "스크랩투입수량
                                    LV_AUFNR        "합부판정대상배치의 오더
                                    PV_MODE.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_qc_move_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&      --> LS_HEADRET
*&      --> LT_RETURN
*&---------------------------------------------------------------------*
FORM UPDATE_QC_MOVE_LOG  USING PS_QC TYPE ZGTPPSIF0061
                               PS_RESULT TYPE ZGTPPSIF0062.

  PS_RESULT = VALUE #( BASE PS_RESULT  MBLNR        = GV_MBLNR
                                       MJAHR        = GV_MJAHR
                                       ZERP_STAT    = COND #( WHEN GV_MBLNR IS NOT INITIAL THEN ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                                              ELSE ZGTPP_IF_CONST=>GC_RESULT-ERROR )
                                       ZERP_MESSAGE = COND #( WHEN GV_MBLNR IS NOT INITIAL THEN COND #( WHEN GS_QC_USAGE_DECSION-ZMODE EQ 'P' THEN TEXT-S07
                                                                                                        WHEN GS_QC_USAGE_DECSION-ZMODE EQ 'R' THEN TEXT-S07
                                                                                                        WHEN GS_QC_USAGE_DECSION-ZMODE EQ 'N' THEN TEXT-S07
                                                                                                        ELSE TEXT-S08 )
                                                              ELSE GV_MESSAGE_M ) ).

*// 품질검사 합부판정 이동 처리 이력 저장.
  UPDATE ZGTPPT3440
     SET MBLNR        = PS_RESULT-MBLNR
         MJAHR        = PS_RESULT-MJAHR
         ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
         ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
     AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
     AND ZSERNO     EQ PS_QC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_kkf1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_1120_MATNR_M
*&      --> LS_QC_WERKS
*&      --> LV_GSBER
*&      <-- GV_CO_ORDER
*&      <-- GV_MESSAGE_CO
*&---------------------------------------------------------------------*
FORM PROC_KKF1  USING    PV_SC_MATNR TYPE MATNR
                         PV_SC_WERKS TYPE WERKS_D
                         PV_GSBER TYPE GSBER
                CHANGING PV_CO_ORDER TYPE AUFNR
                         PV_MESSAGE_CO TYPE BAPI_MSG.

  DATA : LV_SUBRC TYPE SYSUBRC.

*플랜트에 따라 관리회계영역 설정.
*타모듈의 사용 때문.
  PERFORM GET_KOKRS USING PV_SC_WERKS.

  SET PARAMETER ID 'CAC' FIELD GV_KOKRS.
  PERFORM NUMBER_GET_NEXT CHANGING GV_CO_ORDER_TEMP.
  PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0010'.
  PERFORM BDC_FIELD   USING : 'COAS-AUART' 'C001',
                              'AFPO-MATNR' PV_SC_MATNR,
                              'AUFK-WERKS' PV_SC_WERKS,
                              'BDC_OKCODE'  '/00'.

  PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
  PERFORM BDC_FIELD   USING : 'COAS-AUFNR' GV_CO_ORDER_TEMP,
                              'COAS-GSBER' PV_GSBER,
                              'BDC_OKCODE'  '=SICH'.

  PERFORM BDC_TRANSACTION USING    'KKF1'
                          CHANGING LV_SUBRC.

  PERFORM MESSAGE_KKF1 CHANGING PV_CO_ORDER
                                PV_MESSAGE_CO.

  CLEAR GV_CO_ORDER_TEMP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_kokrs
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_SC_WERKS
*&---------------------------------------------------------------------*
FORM GET_KOKRS  USING LV_WERKS TYPE WERKS_D.

  CLEAR: GV_KOKRS.
  IF LV_WERKS IS NOT INITIAL.
    SELECT SINGLE K~KOKRS
      INTO GV_KOKRS
      FROM T001K AS T JOIN TKA02 AS K
        ON T~BUKRS = K~BUKRS
     WHERE T~BWKEY = LV_WERKS.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form number_get_next
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*       C001 오더 타입에 대한 오더 번호 채번하기
*&---------------------------------------------------------------------*
FORM NUMBER_GET_NEXT  CHANGING LV_SCRAP_ORDER_NO TYPE AUFNR.

  CHECK LV_SCRAP_ORDER_NO IS INITIAL.

  DATA : LV_ORDER_NO(11) TYPE C.
  CLEAR : LV_SCRAP_ORDER_NO.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '01'
      OBJECT                  = 'ZCO_SCRAP'
    IMPORTING
      NUMBER                  = LV_ORDER_NO
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.
  IF SY-SUBRC EQ 0.
    CONCATENATE 'A' LV_ORDER_NO INTO LV_SCRAP_ORDER_NO.
  ELSE.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bdc_dynpro
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM BDC_DYNPRO  USING PROGRAM DYNPRO.
  CLEAR GT_BDCDATA.
  GT_BDCDATA-PROGRAM  = PROGRAM.
  GT_BDCDATA-DYNPRO   = DYNPRO.
  GT_BDCDATA-DYNBEGIN = 'X'.
  APPEND GT_BDCDATA.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form bdc_field
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LV_SCRAP_TYPE
*&---------------------------------------------------------------------*
FORM BDC_FIELD  USING FNAM FVAL.
*  if fval <> nodata.
  CLEAR GT_BDCDATA.
  GT_BDCDATA-FNAM = FNAM.
  GT_BDCDATA-FVAL = FVAL.
  APPEND GT_BDCDATA.
*  endif.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form bdc_transaction
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- LV_SUBRC
*&---------------------------------------------------------------------*
FORM BDC_TRANSACTION  USING    GV_TCODE
                      CHANGING LV_SUBRC.

  IF GV_TCODE(2) = 'MB'.

    IF GT_BDCDATA[] IS NOT INITIAL.
      CLEAR: GS_HEADER, GS_CODE, GV_MATDOC, GV_DOCYEAR,
             GT_ITEM, GT_ITEM[], GT_RETURN, GT_RETURN[].

      CASE GV_TCODE.
        WHEN 'MB31'.
          GS_CODE-GM_CODE = '02'.
        WHEN 'MB1A'.
          GS_CODE-GM_CODE = '03'.
        WHEN 'MB1B'.
          GS_CODE-GM_CODE = '04'.
        WHEN 'MB1C'.
          GS_CODE-GM_CODE = '05'.
      ENDCASE.

      GS_HEADER-PSTNG_DATE = REPLACE( VAL = VALUE #( GT_BDCDATA[ FNAM = 'MKPF-BUDAT' ]-FVAL OPTIONAL ) SUB = '.' WITH = ' ' OCC = 0 ).   " 전표 전기일
      GS_HEADER-DOC_DATE   = REPLACE( VAL = VALUE #( GT_BDCDATA[ FNAM = 'MKPF-BLDAT' ]-FVAL OPTIONAL ) SUB = '.' WITH = ' ' OCC = 0 )..   " 전표 증빙일

      GT_ITEM-MATERIAL   = VALUE #( GT_BDCDATA[ FNAM = 'MSEG-MATNR(01)' ]-FVAL OPTIONAL ). " 자재번호
      GT_ITEM-PLANT      = VALUE #( GT_BDCDATA[ FNAM = 'RM07M-WERKS' ]-FVAL OPTIONAL ).    " 플랜트
      GT_ITEM-STGE_LOC   = VALUE #( GT_BDCDATA[ FNAM = 'RM07M-LGORT' ]-FVAL OPTIONAL ).    " 저장위치
      GT_ITEM-BATCH      = VALUE #( GT_BDCDATA[ FNAM = 'MSEG-CHARG(01)' ]-FVAL OPTIONAL ). " 배치
      GT_ITEM-MOVE_TYPE  = VALUE #( GT_BDCDATA[ FNAM = 'RM07M-BWARTWA' ]-FVAL OPTIONAL ).  " 이동유형
      GT_ITEM-SPEC_STOCK = VALUE #( GT_BDCDATA[ FNAM = 'RM07M-SOBKZ' ]-FVAL OPTIONAL ).    " 특별재고지시자
      GT_ITEM-ENTRY_QNT  = VALUE #( GT_BDCDATA[ FNAM = 'MSEG-ERFMG(01)' ]-FVAL OPTIONAL ). " 소요량
      GT_ITEM-ORDERID    = VALUE #( GT_BDCDATA[ FNAM = 'COBL-AUFNR' ]-FVAL OPTIONAL ).     " 오더
*      GT_ITEM-SALES_ORD  = VALUE #( GT_BDCDATA[ FNAM = 'MSEGK-MAT_KDAUF' ]-FVAL OPTIONAL )." 판매오더번호
*      GT_ITEM-S_ORD_ITEM = VALUE #( GT_BDCDATA[ FNAM = 'MSEGK-MAT_KDPOS' ]-FVAL OPTIONAL )." 판매오더 품목번호
      GT_ITEM-VAL_SALES_ORD  = VALUE #( GT_BDCDATA[ FNAM = 'MSEGK-MAT_KDAUF' ]-FVAL OPTIONAL )." 판매오더번호
      GT_ITEM-VAL_S_ORD_ITEM = VALUE #( GT_BDCDATA[ FNAM = 'MSEGK-MAT_KDPOS' ]-FVAL OPTIONAL )." 판매오더 품목번호
      APPEND GT_ITEM.
    ENDIF.

    CLEAR : GT_BDCDATA, GT_BDCDATA[].

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = GS_HEADER
        GOODSMVT_CODE    = GS_CODE
      IMPORTING
        MATERIALDOCUMENT = GV_MATDOC
        MATDOCUMENTYEAR  = GV_DOCYEAR
      TABLES
        GOODSMVT_ITEM    = GT_ITEM
        RETURN           = GT_RETURN.

    IF GV_MATDOC IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.

  ELSE.

    DATA  LS_OPT LIKE CTU_PARAMS.
    LS_OPT-DISMODE  = 'N'.
    LS_OPT-UPDMODE  = 'S'.
    LS_OPT-CATTMODE = ''.
    LS_OPT-DEFSIZE  = 'X'.    "화면 Default Size 사용
    LS_OPT-RACOMMIT = 'X'.
    LS_OPT-NOBINPT  = 'X'.
    LS_OPT-NOBIEND  = 'X'.
    CLEAR  : GT_MESSTAB, LV_SUBRC.
    REFRESH  GT_MESSTAB.
    CALL TRANSACTION GV_TCODE USING  GT_BDCDATA
                              OPTIONS FROM LS_OPT
                              MESSAGES INTO GT_MESSTAB.
    LV_SUBRC = SY-SUBRC.
    REFRESH GT_BDCDATA.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form message_kkf1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CO_ORDER
*&      <-- LV_MESSAGE_CO
*&---------------------------------------------------------------------*
FORM MESSAGE_KKF1  CHANGING LV_CO_ORDER TYPE AUFNR
                            LV_MESSAGE_CO TYPE BAPI_MSG.

  DATA  LV_LINES TYPE I.

  CLEAR GT_MESSTAB.
  READ TABLE GT_MESSTAB WITH KEY MSGID = 'KO'
                                 MSGNR = '107'.
  IF SY-SUBRC = 0.
    LV_CO_ORDER = GT_MESSTAB-MSGV1.
  ELSE.
*   마지막 에러 메시지만 보여주기
    CLEAR : LV_LINES, GT_MESSTAB.
    DESCRIBE TABLE GT_MESSTAB LINES LV_LINES.
    READ TABLE GT_MESSTAB INDEX LV_LINES.
  ENDIF.

  PERFORM BUILD_MESSAGE_TEXT(ZCOF0030)
             USING GT_MESSTAB-MSGID GT_MESSTAB-MSGNR
                   GT_MESSTAB-MSGV1 GT_MESSTAB-MSGV2
                   GT_MESSTAB-MSGV3 GT_MESSTAB-MSGV4
             CHANGING LV_MESSAGE_CO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_kkf1_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_KKF1_LOG  USING    PS_QC TYPE ZGTPPSIF0061
                               PS_RESULT TYPE ZGTPPSIF0062.

  DATA LV_HEADTEXT TYPE BKTXT.

  IF GV_CO_ORDER IS NOT INITIAL.
    UPDATE ZGTPPT3440
       SET CO_ORDER = GV_CO_ORDER
     WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
       AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
       AND ZSERNO     EQ PS_QC-ZSERNO.

    "CO 오더 생성 실패시 합부판정 자재문서 취소
  ELSE.
    "합부판정 자재문서 취소
    CLEAR: GS_HEADRET1, GT_RETURN1, LV_HEADTEXT.
    LV_HEADTEXT = PS_QC-ZSERNO.

    CALL FUNCTION 'ZGTPP_BAPI_GOODSMVT_CANCEL' STARTING NEW TASK 'MBLNR'
      PERFORMING GET_QC_MOVE_CANCEL ON END OF TASK
      EXPORTING
        MATERIALDOCUMENT    = GV_MBLNR
        MATDOCUMENTYEAR     = GV_MJAHR
        GOODSMVT_PSTNG_DATE = PS_QC-BUDAT
        GOODSMVT_PR_UNAME   = SY-UNAME
        DOCUMENTHEADER_TEXT = LV_HEADTEXT.

    WAIT UNTIL GV_JOBS = '1'.

    IF GS_HEADRET1-MAT_DOC IS NOT INITIAL.

      CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
      PS_RESULT-ZERP_STAT = 'E'.
      PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_CO.

      UPDATE ZGTPPT3440
         SET MBLNR        = ''
             MJAHR        = ''
             ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
             ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
             ZERP_STAT    = PS_RESULT-ZERP_STAT
             ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
       WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
         AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
         AND ZSERNO     EQ PS_QC-ZSERNO.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      PS_RESULT-ZERP_STAT = 'E'.
      PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_CO.

      UPDATE ZGTPPT3440
         SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
             ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
             ZERP_STAT    = PS_RESULT-ZERP_STAT
             ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
       WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
         AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
         AND ZSERNO     EQ PS_QC-ZSERNO.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_mblnr_o
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC_BUDAT
*&      --> P_
*&      --> LS_QC_WERKS
*&      --> LS_QC_LGORT
*&      --> LS_MSKA_SOBKZ
*&      --> LS_QC_MATNR
*&      --> LS_QC_CHARG
*&      --> GV_SCQTY
*&      --> GV_CO_ORDER
*&      --> LS_MSKA_VBELN
*&      --> LS_MSKA_POSNR
*&---------------------------------------------------------------------*
FORM PROC_MBLNR_O  USING  PS_QC TYPE ZGTPPSIF0061
                          P_BWART TYPE BWART
                          P_SCQTY TYPE MENGE_D
                          P_CO_ORDER TYPE AUFNR
                 CHANGING P_MBLNR_O
                          P_MESSAGE_MO.

  DATA: LS_COBL    TYPE COBL,
        LS_HEADER  TYPE BAPI2017_GM_HEAD_01,
        LS_GMCODE  TYPE BAPI2017_GM_CODE,
        LS_HEADRET TYPE BAPI2017_GM_HEAD_RET,
        LV_MATDOC  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_DOCYER  TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_ITEM    TYPE BAPI2017_GM_ITEM_CREATE,
        LT_ITEM    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_EXT     TYPE STANDARD TABLE OF BAPIPAREX,
        LS_EXT     TYPE BAPIPAREX,
        LT_RETURN  TYPE TABLE OF BAPIRET2.

  "GM_CODE
  LS_GMCODE-GM_CODE = '03'. "출고전기

  "Header
  LS_HEADER-PSTNG_DATE = PS_QC-BUDAT.
  LS_HEADER-DOC_DATE   = PS_QC-BUDAT.
  LS_HEADER-PR_UNAME   = SY-UNAME.
  LS_HEADER-HEADER_TXT = PS_QC-ZSERNO.

  "Item
  LS_ITEM-MATERIAL  = PS_QC-MATNR.
  LS_ITEM-PLANT     = PS_QC-WERKS.
  LS_ITEM-STGE_LOC  = PS_QC-LGORT.
  LS_ITEM-BATCH     = PS_QC-CHARG.
  LS_ITEM-ENTRY_QNT = P_SCQTY.
  LS_ITEM-MOVE_TYPE = P_BWART.     "GP->957 / GO->937

  LS_ITEM-ORDERID   = P_CO_ORDER.

  IF PS_QC-VBELN IS NOT INITIAL.
    LS_ITEM-SPEC_STOCK = 'E'.
    LS_ITEM-SALES_ORD  = PS_QC-VBELN.
    LS_ITEM-S_ORD_ITEM = PS_QC-POSNR.
    LS_ITEM-MOVE_BATCH = PS_QC-CHARG.
    LS_ITEM-VAL_SALES_ORD  = PS_QC-VBELN.
    LS_ITEM-VAL_S_ORD_ITEM = PS_QC-POSNR.
  ENDIF.

  APPEND LS_ITEM TO LT_ITEM.

*  "추가필드
*  ls_cobl-aufnr = p_co_order.
*  ls_ext-structure = 'COBL'.
*  MOVE ls_cobl TO ls_ext-valuepart1.
*  APPEND ls_ext TO lt_ext.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LS_GMCODE
    IMPORTING
      GOODSMVT_HEADRET = LS_HEADRET
      MATERIALDOCUMENT = LV_MATDOC
      MATDOCUMENTYEAR  = LV_DOCYER
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
*     extensionin      = lt_ext
      RETURN           = LT_RETURN.

  IF LV_MATDOC IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    P_MBLNR_O = LV_MATDOC. "전표번호

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_MESSAGE_MO = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_qc_move
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&---------------------------------------------------------------------*
FORM PROC_QC_MOVE  USING    PS_QC TYPE ZGTPPSIF0061
                            PV_MODE.

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LV_BWART TYPE BWART.

  CLEAR: LV_BWART.
  CASE PV_MODE.
    WHEN 'P'.
      LV_BWART = '321'.
    WHEN 'R' OR 'N'.
      LV_BWART = '311'.
  ENDCASE.

  IF PS_QC-VBELN IS INITIAL.
    DATA(LT_ITEM) = VALUE GM_ITEMS_T( ( MATERIAL   = CONV MATNR18( PS_QC-MATNR )
                                        PLANT      = PS_QC-WERKS
                                        STGE_LOC   = PS_QC-LGORT_F
                                        BATCH      = PS_QC-CHARG
                                        MOVE_TYPE  = LV_BWART
                                        MOVE_PLANT = PS_QC-WERKS
                                        MOVE_STLOC = PS_QC-LGORT
                                        STCK_TYPE  = 'F'
                                        ENTRY_UOM  = GV_QCMEINS
                                        ENTRY_QNT  = GV_QCQTY ) ).

  ELSE.
    LT_ITEM = VALUE GM_ITEMS_T( ( MATERIAL       = CONV MATNR18( PS_QC-MATNR )
                                  PLANT          = PS_QC-WERKS
                                  STGE_LOC       = PS_QC-LGORT_F
                                  BATCH          = PS_QC-CHARG
                                  MOVE_TYPE      = LV_BWART
                                  MOVE_PLANT     = PS_QC-WERKS
                                  MOVE_STLOC     = PS_QC-LGORT
                                  MOVE_BATCH     = PS_QC-CHARG
                                  STCK_TYPE      = 'F'
                                  SPEC_STOCK     = 'E'
                                  SALES_ORD      = PS_QC-VBELN
                                  S_ORD_ITEM     = PS_QC-POSNR
                                  VAL_SALES_ORD  = PS_QC-VBELN
                                  VAL_S_ORD_ITEM = PS_QC-POSNR
                                  ENTRY_UOM      = GV_QCMEINS
                                  ENTRY_QNT      = GV_QCQTY ) ).
  ENDIF.

  CLEAR: LS_HEADRET, LT_RETURN.
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = VALUE BAPI2017_GM_HEAD_01( PSTNG_DATE = PS_QC-BUDAT
                                                    DOC_DATE   = PS_QC-BUDAT
                                                    HEADER_TXT = PS_QC-ZSERNO )
      GOODSMVT_CODE    = ZGTPP_IF_CONST=>GC_GM_CODE-TRANSFER_POSTING
    IMPORTING
      GOODSMVT_HEADRET = LS_HEADRET
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = LT_RETURN.

  IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    GV_MBLNR = LS_HEADRET-MAT_DOC.
    GV_MJAHR = LS_HEADRET-DOC_YEAR.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    GV_MESSAGE_M = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_mblnr_o_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_O_LOG  USING   PS_QC TYPE ZGTPPSIF0061
                                 PS_RESULT TYPE ZGTPPSIF0062.

  DATA LV_SUBRC TYPE SYSUBRC.
  DATA LV_HEADTEXT TYPE BKTXT.

  IF GV_MBLNR_O IS NOT INITIAL.
    UPDATE ZGTPPT3440
       SET MBLNR_O = GV_MBLNR_O
     WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
       AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
       AND ZSERNO     EQ PS_QC-ZSERNO.

    "투입 실패 시 CO오더 TECO->합부판정 자재문서 취소
  ELSE.
    "CO 오더 teco 처리
    CLEAR: GT_BDCDATA, GT_BDCDATA[].
    PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0110'.
    PERFORM BDC_FIELD   USING : 'COAS-AUFNR' GV_CO_ORDER,
                                'BDC_OKCODE'  '/00'.

    PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
    PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=PHS2'.

    PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
    PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=SICH'.

    PERFORM BDC_TRANSACTION USING    'KKF2'
                            CHANGING LV_SUBRC.

    CLEAR: GT_MESSTAB.
    READ TABLE GT_MESSTAB WITH KEY MSGID = 'KO'
                                   MSGNR = '109'
                                   MSGTYP = 'S'.

    IF SY-SUBRC EQ 0.
      "합부판정 자재문서 취소
      CLEAR: GS_HEADRET1, GT_RETURN1, LV_HEADTEXT.
      LV_HEADTEXT = PS_QC-ZSERNO.

      CALL FUNCTION 'ZGTPP_BAPI_GOODSMVT_CANCEL' STARTING NEW TASK 'MBLNR'
        PERFORMING GET_QC_MOVE_CANCEL ON END OF TASK
        EXPORTING
          MATERIALDOCUMENT    = GV_MBLNR
          MATDOCUMENTYEAR     = GV_MJAHR
          GOODSMVT_PSTNG_DATE = PS_QC-BUDAT
          GOODSMVT_PR_UNAME   = SY-UNAME
          DOCUMENTHEADER_TEXT = LV_HEADTEXT.

      WAIT UNTIL GV_JOBS = '1'.

      IF GS_HEADRET1-MAT_DOC IS NOT INITIAL.

        CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
        PS_RESULT-ZERP_STAT = 'E'.
        PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MO.

        UPDATE ZGTPPT3440
           SET MBLNR        = ''
               MJAHR        = ''
               CO_ORDER     = ''
               ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
               ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
               ZERP_STAT    = PS_RESULT-ZERP_STAT
               ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
         WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
           AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
           AND ZSERNO     EQ PS_QC-ZSERNO.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        PS_RESULT-ZERP_STAT = 'E'.
        PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MO.

        UPDATE ZGTPPT3440
           SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
               ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
               ZERP_STAT    = PS_RESULT-ZERP_STAT
               ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
         WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
           AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
           AND ZSERNO     EQ PS_QC-ZSERNO.

      ENDIF.

    ELSE.
      PS_RESULT-ZERP_STAT = 'E'.
      PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MO.

      UPDATE ZGTPPT3440
         SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
             ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
             ZERP_STAT    = PS_RESULT-ZERP_STAT
             ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
       WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
         AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
         AND ZSERNO     EQ PS_QC-ZSERNO.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MBLNR_I
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> P_
*&      --> GV_CONVQTY
*&      --> GV_CO_ORDER
*&      <-- GV_MBLNR_I
*&      <-- GV_MESSAGE_MI
*&---------------------------------------------------------------------*
FORM PROC_MBLNR_I  USING  PS_QC TYPE ZGTPPSIF0061
                          P_BWART TYPE BWART
                          P_SCMATNR TYPE MATNR
                          P_SCWERKS TYPE WERKS_D
                          P_SCLGORT TYPE LGORT_D
                          P_CONVQTY TYPE MENGE_D
                          P_CO_ORDER TYPE AUFNR
                 CHANGING P_MBLNR_I
                          P_MESSAGE_MI.

  DATA: LS_COBL    TYPE COBL,
        LS_HEADER  TYPE BAPI2017_GM_HEAD_01,
        LS_GMCODE  TYPE BAPI2017_GM_CODE,
        LS_HEADRET TYPE BAPI2017_GM_HEAD_RET,
        LV_MATDOC  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_DOCYER  TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_ITEM    TYPE BAPI2017_GM_ITEM_CREATE,
        LT_ITEM    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_EXT     TYPE STANDARD TABLE OF BAPIPAREX,
        LS_EXT     TYPE BAPIPAREX,
        LT_RETURN  TYPE TABLE OF BAPIRET2.

  "GM_CODE
  LS_GMCODE-GM_CODE = '05'. "입고전기

  "Header
  LS_HEADER-PSTNG_DATE      = PS_QC-BUDAT.
  LS_HEADER-DOC_DATE        = PS_QC-BUDAT.
  LS_HEADER-PR_UNAME        = SY-UNAME.
  LS_HEADER-VER_GR_GI_SLIP  = '2'.
  LS_HEADER-VER_GR_GI_SLIPX = 'X'.
  LS_HEADER-HEADER_TXT      = PS_QC-ZSERNO.

  "Item
  LS_ITEM-MATERIAL  = P_SCMATNR.
  LS_ITEM-PLANT     = P_SCWERKS.
  LS_ITEM-STGE_LOC  = P_SCLGORT.
  LS_ITEM-ENTRY_QNT = P_CONVQTY.
  LS_ITEM-MOVE_TYPE = P_BWART.     "977

  LS_ITEM-ORDERID   = P_CO_ORDER.
*  ls_item-no_more_gr = 'X'.
  APPEND LS_ITEM TO LT_ITEM.

*  "추가필드
*  ls_cobl-aufnr = p_co_order.
*  ls_ext-structure = 'COBL'.
*  MOVE ls_cobl TO ls_ext-valuepart1.
*  APPEND ls_ext TO lt_ext.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LS_GMCODE
    IMPORTING
      GOODSMVT_HEADRET = LS_HEADRET
      MATERIALDOCUMENT = LV_MATDOC
      MATDOCUMENTYEAR  = LV_DOCYER
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
*     extensionin      = lt_ext
      RETURN           = LT_RETURN.

  IF LV_MATDOC IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    P_MBLNR_I = LV_MATDOC. "전표번호

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_MESSAGE_MI = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_mblnr_i_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_I_LOG  USING   PS_QC TYPE ZGTPPSIF0061
                                 PS_RESULT TYPE ZGTPPSIF0062.

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LV_SUBRC TYPE SYSUBRC.
  DATA LV_HEADTEXT TYPE BKTXT.

  IF GV_MBLNR_I IS NOT INITIAL.
    UPDATE ZGTPPT3440
       SET MBLNR_I = GV_MBLNR_I
     WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
       AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
       AND ZSERNO     EQ PS_QC-ZSERNO.

    "입고 실패 시 투입 취소->CO오더 TECO->합부판정 자재문서 취소
  ELSE.
    "CO 오더 투입 자재문서 취소
    CLEAR: LS_HEADRET, LT_RETURN, LV_HEADTEXT.
    LV_HEADTEXT = PS_QC-ZSERNO.

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = GV_MBLNR_O
        MATDOCUMENTYEAR     = GV_MJAHR
        GOODSMVT_PSTNG_DATE = PS_QC-BUDAT
        GOODSMVT_PR_UNAME   = SY-UNAME
        DOCUMENTHEADER_TEXT = LV_HEADTEXT
      IMPORTING
        GOODSMVT_HEADRET    = LS_HEADRET
      TABLES
        RETURN              = LT_RETURN.

    IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      "CO 오더 teco 처리
      PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0110'.
      PERFORM BDC_FIELD   USING : 'COAS-AUFNR' GV_CO_ORDER,
                                  'BDC_OKCODE'  '/00'.

      PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
      PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=PHS2'.

      PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
      PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=SICH'.

      PERFORM BDC_TRANSACTION USING    'KKF2'
                              CHANGING LV_SUBRC.

      IF LV_SUBRC EQ 0.
        "합부판정 자재문서 취소
        CLEAR: GS_HEADRET1, GT_RETURN1, LV_HEADTEXT.
        LV_HEADTEXT = PS_QC-ZSERNO.

        CALL FUNCTION 'ZGTPP_BAPI_GOODSMVT_CANCEL' STARTING NEW TASK 'MBLNR'
          PERFORMING GET_QC_MOVE_CANCEL ON END OF TASK
          EXPORTING
            MATERIALDOCUMENT    = GV_MBLNR
            MATDOCUMENTYEAR     = GV_MJAHR
            GOODSMVT_PSTNG_DATE = PS_QC-BUDAT
            GOODSMVT_PR_UNAME   = SY-UNAME
            DOCUMENTHEADER_TEXT = LV_HEADTEXT.

        WAIT UNTIL GV_JOBS = '1'.

        IF GS_HEADRET1-MAT_DOC IS NOT INITIAL.

          CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
          PS_RESULT-ZERP_STAT = 'E'.
          PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MI.

          UPDATE ZGTPPT3440
             SET MBLNR        = ''
                 MJAHR        = ''
                 CO_ORDER     = ''
                 MBLNR_O      = ''
                 ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
                 ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
                 ZERP_STAT    = PS_RESULT-ZERP_STAT
                 ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
           WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
             AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
             AND ZSERNO     EQ PS_QC-ZSERNO.

        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          PS_RESULT-ZERP_STAT = 'E'.
          PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MI.

          UPDATE ZGTPPT3440
             SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
                 ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
                 ZERP_STAT    = PS_RESULT-ZERP_STAT
                 ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
           WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
             AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
             AND ZSERNO     EQ PS_QC-ZSERNO.

        ENDIF.

      ELSE.

        PS_RESULT-ZERP_STAT = 'E'.
        PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MI.

        UPDATE ZGTPPT3440
           SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
               ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
               ZERP_STAT    = PS_RESULT-ZERP_STAT
               ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
         WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
           AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
           AND ZSERNO     EQ PS_QC-ZSERNO.

      ENDIF.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      PS_RESULT-ZERP_STAT = 'E'.
      PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MI.

      UPDATE ZGTPPT3440
         SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
             ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
             ZERP_STAT    = PS_RESULT-ZERP_STAT
             ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
       WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
         AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
         AND ZSERNO     EQ PS_QC-ZSERNO.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form canceling_qc_usage_decsion
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> OT_RESULT[]
*&---------------------------------------------------------------------*
FORM  CANCELING_QC_USAGE_DECSION  USING  PV_MODE
                                        PT_RESULT TYPE TY_T_QC_RESULT.

  LOOP AT GS_QC_USAGE_DECSION-QC INTO DATA(LS_QC).

    "취소 대상 자재문서 확인
    SELECT SINGLE MBLNR, MJAHR
      FROM MATDOC
     WHERE MBLNR EQ @LS_QC-C_MBLNR
       AND MJAHR EQ @LS_QC-C_MJAHR
       AND CANCELLED NE 'X'
       AND ( BWART EQ '321' OR BWART EQ '311' )
      INTO (@DATA(LV_MBLNR), @DATA(LV_MJAHR)).

    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LS_QC-ZSERNO BINARY SEARCH.

    IF LV_MBLNR IS INITIAL.
      PERFORM UPDATE_QC_CHECK_LOG USING LS_QC LR_RESULT->*.

    ELSE.
      "취소 대상 자재문서 기준의 IF LOG 추출
      CLEAR: GS_MATDOC.
      PERFORM GET_ZGTPPT3440 USING LS_QC.

      CLEAR: GV_CHECK.

      "CO 오더가 없는 경우
      IF GS_MATDOC-CO_ORDER IS INITIAL.
        "SPGCD 가 GO 인 경우
        "폐기 취소->합부판정 취소
        IF LS_QC-SPGCD EQ 'GO'.
          "폐기 취소
          CLEAR: GV_MBLNR_O, GV_MESSAGE_MO.
          PERFORM PROC_MBLNR_O_CANCEL USING LS_QC.

          IF GV_CHECK EQ 'E' AND GV_MBLNR_O IS INITIAL.
            PERFORM UPDATE_MBLNR_O_LOG_CANCEL USING LS_QC LR_RESULT->*.

          ELSE.
            "FACTOR 배치 특성값 업데이트
            CLEAR: GV_MESSAGE_FB.
            PERFORM UPDATE_FACTOR_BATCH_CANCEL USING LS_QC LR_RESULT->*.

            IF GV_CHECK EQ 'E'.
              PERFORM UPDATE_FACTOR_BATCH_LOG_CANCEL USING LS_QC LR_RESULT->*.

            ELSE.
              "합부판정 이동 취소
              CLEAR: GV_MBLNR, GV_MESSAGE_M, GV_MJAHR.
              PERFORM PROC_QC_MOVE_CANCEL.

              IF GV_CHECK IS INITIAL.
                "FACTOR 배치 특성값 업데이트
                CLEAR: GV_MESSAGE_FB.
                PERFORM UPDATE_FACTOR_BATCH_CANCEL USING LS_QC LR_RESULT->*.
              ENDIF.

              PERFORM UPDATE_QC_MOVE_LOG USING LS_QC LR_RESULT->*.

            ENDIF.
          ENDIF.

        ELSE.
          "FACTOR 배치 특성값 업데이트
          CLEAR: GV_MESSAGE_FB.
          PERFORM UPDATE_FACTOR_BATCH_CANCEL USING LS_QC LR_RESULT->*.

          IF GV_CHECK EQ 'E'.
            PERFORM UPDATE_FACTOR_BATCH_LOG_CANCEL USING LS_QC LR_RESULT->*.

          ELSE.
            "합부판정 이동 취소
            CLEAR: GV_MBLNR, GV_MESSAGE_M, GV_MJAHR.
            PERFORM PROC_QC_MOVE_CANCEL.

            IF GV_CHECK IS INITIAL.
              "FACTOR 배치 특성값 업데이트
              CLEAR: GV_MESSAGE_FB.
              PERFORM UPDATE_FACTOR_BATCH_CANCEL USING LS_QC LR_RESULT->*.
            ENDIF.

            PERFORM UPDATE_QC_MOVE_LOG USING LS_QC LR_RESULT->*.

          ENDIF.
        ENDIF.

        "CO 오더가 있는 경우
        "0입고 취소->입고취소->투입취소->CO 오더 TECO->합부판정 취소
      ELSE.
        "CO 오더 0 입고 취소
        CLEAR: GV_MBLNR_Z, GV_MESSAGE_MZ.
        PERFORM PROC_MBLNR_Z_CANCEL.

        IF GV_CHECK EQ 'E' AND GV_MBLNR_Z IS INITIAL.
          PERFORM UPDATE_MBLNR_Z_LOG_CANCEL USING LS_QC LR_RESULT->*.

        ELSE.
          "CO 오더 입고 취소
          CLEAR: GV_MBLNR_I, GV_MESSAGE_MI.
          PERFORM PROC_MBLNR_I_CANCEL.

          IF GV_CHECK EQ 'E' AND GV_MBLNR_I IS INITIAL.
            PERFORM UPDATE_MBLNR_I_LOG_CANCEL USING LS_QC LR_RESULT->*.

          ELSE.
            "CO 오더 투입 취소
            CLEAR: GV_MBLNR_O, GV_MESSAGE_MO.
            PERFORM PROC_MBLNR_O_CANCEL USING LS_QC.

            IF GV_CHECK EQ 'E' AND GV_MBLNR_O IS INITIAL.
              PERFORM UPDATE_MBLNR_O_LOG_CANCEL USING LS_QC LR_RESULT->*.

            ELSE.
              "CO 오더 TECO 처리
              CLEAR : GV_MESSAGE_CO.
              PERFORM PROC_KKF1_CANCEL.

              IF GV_CHECK EQ 'E'.
                PERFORM UPDATE_KKF1_LOG_CANCEL USING LS_QC LR_RESULT->*.

              ELSE.
                "FACTOR 배치 특성값 업데이트
                CLEAR: GV_MESSAGE_FB.
                PERFORM UPDATE_FACTOR_BATCH_CANCEL USING LS_QC LR_RESULT->*.

                IF GV_CHECK EQ 'E'.
                  PERFORM UPDATE_FACTOR_BATCH_LOG_CANCEL USING LS_QC LR_RESULT->*.

                ELSE.
                  "합부판정 이동 취소
                  CLEAR: GV_MBLNR, GV_MESSAGE_M, GV_MJAHR.
                  PERFORM PROC_QC_MOVE_CANCEL.

                  IF GV_CHECK IS INITIAL.
                    "FACTOR 배치 특성값 업데이트
                    CLEAR: GV_MESSAGE_FB.
                    PERFORM UPDATE_FACTOR_BATCH_CANCEL USING LS_QC LR_RESULT->*.
                  ENDIF.

                  PERFORM UPDATE_QC_MOVE_LOG USING LS_QC LR_RESULT->*.

*// 957, 977, 0입고 모두 취소 처리 성공 시 - SPGCD NE GO
*// 공정 외 스크랩 처리 내역 UPDATE(ZGTCOT4370)
                  CHECK GV_MBLNR_Z IS NOT INITIAL.
                  CHECK GV_MBLNR_I IS NOT INITIAL.
                  CHECK GV_MBLNR_O IS NOT INITIAL.

                  PERFORM SAVE_ZGTCOT4370 USING LS_QC
                                                GS_MATDOC-CO_ORDER     "CO오더
                                                '' "스크랩입고자재
                                                '' "스크랩입고저장위치
                                                '' "스크랩입고수량
                                                '' "스크랩투입수량
                                                '' "합부판정대상배치의 오더
                                                PV_MODE.

                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_QC_CHECK_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_QC_CHECK_LOG  USING PS_QC TYPE ZGTPPSIF0061
                                PS_RESULT TYPE ZGTPPSIF0062.


  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = TEXT-E12.

  UPDATE ZGTPPT3440
     SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
         ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
     AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
     AND ZSERNO     EQ PS_QC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ZGTPPT3440
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&---------------------------------------------------------------------*
FORM GET_ZGTPPT3440  USING  PS_QC TYPE ZGTPPSIF0061.

  SELECT SINGLE MBLNR, MJAHR, CO_ORDER, MBLNR_O, MBLNR_I, MBLNR_Z
    FROM ZGTPPT3440
   WHERE MBLNR EQ @PS_QC-C_MBLNR
     AND MJAHR EQ @PS_QC-C_MJAHR
    INTO CORRESPONDING FIELDS OF @GS_MATDOC.

  SELECT SINGLE BUDAT
    FROM MATDOC
   WHERE MBLNR EQ @GS_MATDOC-MBLNR
     AND MJAHR EQ @GS_MATDOC-MJAHR
    INTO @GS_MATDOC-BUDAT.

  SELECT SINGLE BUDAT
    FROM MATDOC
   WHERE MBLNR EQ @GS_MATDOC-MBLNR_O
     AND MJAHR EQ @GS_MATDOC-MJAHR
    INTO @GS_MATDOC-BUDAT_O.

  SELECT SINGLE BUDAT
    FROM MATDOC
   WHERE MBLNR EQ @GS_MATDOC-MBLNR_I
     AND MJAHR EQ @GS_MATDOC-MJAHR
    INTO @GS_MATDOC-BUDAT_I.

  SELECT SINGLE BUDAT
    FROM MATDOC
   WHERE MBLNR EQ @GS_MATDOC-MBLNR_Z
     AND MJAHR EQ @GS_MATDOC-MJAHR
    INTO @GS_MATDOC-BUDAT_Z.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_qc_move_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_CHECK
*&---------------------------------------------------------------------*
FORM PROC_QC_MOVE_CANCEL.

  DATA LV_SUBRC TYPE SYSUBRC.
  DATA LV_HEADTEXT TYPE BKTXT.

  "취소 문서의 취소 처리 결과 체크
  SELECT SINGLE MANDT
    FROM MATDOC
   WHERE MBLNR EQ @GS_MATDOC-MBLNR
     AND MJAHR EQ @GS_MATDOC-MJAHR
     AND CANCELLED EQ 'X'
    INTO @DATA(LV_MANDT).

  "취소 문서가 취소 전이면 진행
  CHECK SY-SUBRC NE 0.

  "합부판정 자재문서 취소
  CLEAR: GS_HEADRET1, GT_RETURN1, LV_HEADTEXT.
  LV_HEADTEXT = TEXT-M01.

  CALL FUNCTION 'ZGTPP_BAPI_GOODSMVT_CANCEL' STARTING NEW TASK 'MBLNR'
    PERFORMING GET_QC_MOVE_CANCEL ON END OF TASK
    EXPORTING
      MATERIALDOCUMENT    = GS_MATDOC-MBLNR
      MATDOCUMENTYEAR     = GS_MATDOC-MJAHR
      GOODSMVT_PSTNG_DATE = GS_MATDOC-BUDAT
      GOODSMVT_PR_UNAME   = SY-UNAME
      DOCUMENTHEADER_TEXT = LV_HEADTEXT.

  WAIT UNTIL GV_JOBS = '1'.

  IF GS_HEADRET1-MAT_DOC IS NOT INITIAL.
    "성공
    GV_MBLNR = GS_HEADRET1-MAT_DOC.
    GV_MJAHR = GS_HEADRET1-DOC_YEAR.

  ELSE.
    "오류
    GV_MESSAGE_M = VALUE #( GT_RETURN1[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

    IF GS_MATDOC-CO_ORDER IS NOT INITIAL.
      "CO 오더 TECO -> REL
      CLEAR: GT_BDCDATA, GT_BDCDATA[].
      PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0110'.
      PERFORM BDC_FIELD   USING : 'COAS-AUFNR' GS_MATDOC-CO_ORDER,
                                  'BDC_OKCODE'  '/00'.

      PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
      PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=PHS1'.

      PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
      PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=SICH'.

      PERFORM BDC_TRANSACTION USING    'KKF2'
                              CHANGING LV_SUBRC.
    ENDIF.

    GV_CHECK = 'E'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MBLNR_I_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_CHECK
*&---------------------------------------------------------------------*
FORM PROC_MBLNR_I_CANCEL.

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LV_HEADTEXT TYPE BKTXT.

  CHECK GS_MATDOC-MBLNR_I IS NOT INITIAL.

  "취소 문서의 취소 처리 결과 체크
  SELECT SINGLE MANDT
    FROM MATDOC
   WHERE MBLNR EQ @GS_MATDOC-MBLNR_I
     AND MJAHR EQ @GS_MATDOC-MJAHR
     AND CANCELLED EQ 'X'
    INTO @DATA(LV_MANDT).

  "취소 문서가 취소 전이면 진행
  CHECK SY-SUBRC NE 0.

  "MES 합부판정, CO입고 취소
  CLEAR: LS_HEADRET, LT_RETURN, LV_HEADTEXT.
  LV_HEADTEXT = TEXT-M02.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GS_MATDOC-MBLNR_I
      MATDOCUMENTYEAR     = GS_MATDOC-MJAHR
      GOODSMVT_PSTNG_DATE = GS_MATDOC-BUDAT_I
      GOODSMVT_PR_UNAME   = SY-UNAME
      DOCUMENTHEADER_TEXT = LV_HEADTEXT
    IMPORTING
      GOODSMVT_HEADRET    = LS_HEADRET
    TABLES
      RETURN              = LT_RETURN.

  IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
    "성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    DO 10 TIMES.
      SELECT SINGLE @ABAP_TRUE
        INTO @DATA(LV_CHECK)
        FROM MKPF
       WHERE MBLNR EQ @LS_HEADRET-MAT_DOC
         AND MJAHR EQ @LS_HEADRET-DOC_YEAR.

      IF SY-SUBRC IS INITIAL.
        GV_MBLNR_I = LS_HEADRET-MAT_DOC.
        EXIT.
      ENDIF.

      WAIT UP TO '1' SECONDS.
    ENDDO.

  ELSE.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    GV_MESSAGE_MI = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

    GV_CHECK = 'E'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_mblnr_i_log_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_I_LOG_CANCEL  USING   PS_QC TYPE ZGTPPSIF0061
                                        PS_RESULT TYPE ZGTPPSIF0062.

  CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MI.

  UPDATE ZGTPPT3440
     SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
         ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
     AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
     AND ZSERNO     EQ PS_QC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_mblnr_o_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_MBLNR_O_CANCEL USING  PS_QC TYPE ZGTPPSIF0061.

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LV_HEADTEXT TYPE BKTXT.

  CHECK GS_MATDOC-MBLNR_O IS NOT INITIAL.

  "취소 문서의 취소 처리 결과 체크
  SELECT SINGLE MANDT
    FROM MATDOC
   WHERE MBLNR EQ @GS_MATDOC-MBLNR_O
     AND MJAHR EQ @GS_MATDOC-MJAHR
     AND CANCELLED EQ 'X'
    INTO @DATA(LV_MANDT).

  "취소 문서가 취소 전이면 진행
  CHECK SY-SUBRC NE 0.

  "MES 합부판정, CO투입 취소
  CLEAR: LS_HEADRET, LT_RETURN, LV_HEADTEXT.
  IF PS_QC-SPGCD EQ 'GO'.
    LV_HEADTEXT = TEXT-M10.
  ELSE.
    LV_HEADTEXT = TEXT-M03.
  ENDIF.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GS_MATDOC-MBLNR_O
      MATDOCUMENTYEAR     = GS_MATDOC-MJAHR
      GOODSMVT_PSTNG_DATE = GS_MATDOC-BUDAT_O
      GOODSMVT_PR_UNAME   = SY-UNAME
      DOCUMENTHEADER_TEXT = LV_HEADTEXT
    IMPORTING
      GOODSMVT_HEADRET    = LS_HEADRET
    TABLES
      RETURN              = LT_RETURN.

  IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
    "성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    DO 10 TIMES.
      SELECT SINGLE @ABAP_TRUE
        INTO @DATA(LV_CHECK)
        FROM MKPF
       WHERE MBLNR EQ @LS_HEADRET-MAT_DOC
         AND MJAHR EQ @LS_HEADRET-DOC_YEAR.

      IF SY-SUBRC IS INITIAL.
        GV_MBLNR_O = LS_HEADRET-MAT_DOC.
        EXIT.
      ENDIF.

      WAIT UP TO '1' SECONDS.
    ENDDO.

  ELSE.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    GV_MESSAGE_MO = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

    GV_CHECK = 'E'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_mblnr_o_log_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_O_LOG_CANCEL  USING   PS_QC TYPE ZGTPPSIF0061
                                        PS_RESULT TYPE ZGTPPSIF0062.

  CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MO.

  UPDATE ZGTPPT3440
     SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
         ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
     AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
     AND ZSERNO     EQ PS_QC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_KKF1_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_KKF1_CANCEL .

  DATA: LV_SUBRC TYPE SYSUBRC,
        LV_LINES TYPE I.

  CLEAR: GT_BDCDATA, GT_BDCDATA[].
  PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0110'.
  PERFORM BDC_FIELD   USING : 'COAS-AUFNR' GS_MATDOC-CO_ORDER,
                              'BDC_OKCODE'  '/00'.

  PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
  PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=PHS2'.

  PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
  PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=SICH'.

  PERFORM BDC_TRANSACTION USING    'KKF2'
                          CHANGING LV_SUBRC.

  CLEAR: GT_MESSTAB.
  READ TABLE GT_MESSTAB WITH KEY MSGID = 'KO'
                                 MSGNR = '109'
                                 MSGTYP = 'S'.

  IF SY-SUBRC EQ 0.
    "성공
    WAIT UP TO '1' SECONDS.

  ELSE.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    "CO 오더 TECO -> REL
    CLEAR: GT_BDCDATA, GT_BDCDATA[].
    PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0110'.
    PERFORM BDC_FIELD   USING : 'COAS-AUFNR' GS_MATDOC-CO_ORDER,
                                'BDC_OKCODE'  '/00'.

    PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
    PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=PHS1'.

    PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
    PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=SICH'.

    PERFORM BDC_TRANSACTION USING    'KKF2'
                            CHANGING LV_SUBRC.

*   마지막 에러 메시지만 보여주기
    CLEAR : LV_LINES, GT_MESSTAB.
    DESCRIBE TABLE GT_MESSTAB LINES LV_LINES.
    READ TABLE GT_MESSTAB INDEX LV_LINES.

    PERFORM BUILD_MESSAGE_TEXT(ZCOF0030)
               USING GT_MESSTAB-MSGID GT_MESSTAB-MSGNR
                     GT_MESSTAB-MSGV1 GT_MESSTAB-MSGV2
                     GT_MESSTAB-MSGV3 GT_MESSTAB-MSGV4
            CHANGING GV_MESSAGE_CO.

    IF GV_MESSAGE_CO IS INITIAL.
      GV_MESSAGE_CO = 'CO 오더 취소 도중 오류가 발생하였습니다.'.
    ENDIF.

    GV_CHECK = 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_kkf1_log_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_KKF1_LOG_CANCEL  USING PS_QC TYPE ZGTPPSIF0061
                                   PS_RESULT TYPE ZGTPPSIF0062.

  CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_CO.

  UPDATE ZGTPPT3440
     SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
         ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
     AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
     AND ZSERNO     EQ PS_QC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_reservation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DELETE_RESERVATION  TABLES PT_RESULT STRUCTURE ZGTPPSIF0053.
  DATA LT_RETURN TYPE TABLE OF BAPIRET2.

  CALL FUNCTION 'BAPI_RESERVATION_DELETE'
    EXPORTING
      RESERVATION = GS_MAT_REQ-RSNUM
    TABLES
      RETURN      = LT_RETURN.

  APPEND INITIAL LINE TO PT_RESULT[] REFERENCE INTO DATA(LR_RESULT).

  LR_RESULT->* = VALUE #( ZSERNO       = GS_MAT_REQ-HEADER-ZSERNO
                          RSNUM        = GS_MAT_REQ-RSNUM
                          ZERP_STAT    = COND #( WHEN LINE_EXISTS( LT_RETURN[ TYPE   = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                                                              ID     = 'M7'
                                                                              NUMBER = '510' ] ) THEN ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                                                                                 ELSE ZGTPP_IF_CONST=>GC_RESULT-ERROR )
                          ZERP_MESSAGE = VALUE #( LT_RETURN[ TYPE = LR_RESULT->ZERP_STAT ]-MESSAGE OPTIONAL ) ).

  CHECK NOT ( GS_MAT_REQ-HEADER-ZREQ_MODE EQ 'C' AND LR_RESULT->ZERP_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS ). "// 처리모드 변경인 경우 기존 자재예약 삭제가 성공일 경우 메시지

  PERFORM UPDATE_MAT_REQ_LOG USING LR_RESULT->*.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_QC_MOVE_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_QC_MOVE_CANCEL  USING P_TASKNAME.

  RECEIVE RESULTS FROM FUNCTION 'ZGTPP_BAPI_GOODSMVT_CANCEL'
     IMPORTING
       GOODSMVT_HEADRET    = GS_HEADRET1
     TABLES
       RETURN              = GT_RETURN1.

  GV_JOBS = '1'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_para_ncr_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_PARA_NCR_RESULT  USING PV_SYSTEM_ID PV_RESULT PV_MESSAGE
                                  PT_QM_NCR TYPE TY_T_NCR_RESULT
                          RAISING LCX_EXCEPTION.

  PV_RESULT  = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-SUCCESS.
  PV_MESSAGE = TEXT-S01.

  GS_NCR_RESULT = VALUE #( ZSYSTEM_ID = PV_SYSTEM_ID
                           NCR_RESULT = PT_QM_NCR
                           ZRESULT    = PV_RESULT
                           ZMESSAGE   = PV_MESSAGE ).

*// 송신 시스템.
  IF PV_SYSTEM_ID IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F02.
  ENDIF.

  IF PT_QM_NCR IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F43.
  ENDIF.

  LOOP AT PT_QM_NCR INTO DATA(LS_QM_NCR).
*// MES 전송 일련번호.
    IF LS_QM_NCR-ZSERNO IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F03.
    ENDIF.

*// NCR 번호.
    IF LS_QM_NCR-NCRNO IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F55.
    ENDIF.

*// NCR 대상 LOT.
    IF LS_QM_NCR-NCRLOTID IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F56.
    ENDIF.

*// 플랜트.
    IF LS_QM_NCR-SITEID IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F04.
    ENDIF.

*// 건명.
    IF LS_QM_NCR-NCRTITLE IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F57.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_ncr_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_NCR_RESULT RAISING LCX_EXCEPTION.

  DATA LT_ZGTPPT3370 TYPE TABLE OF ZGTPPT3370.

  PERFORM GET_DATE_TIME.

  GET TIME STAMP FIELD GS_NCR_RESULT-ZIFKEY.

  LT_ZGTPPT3370 = VALUE #( FOR LS_NCR_RESULT IN GS_NCR_RESULT-NCR_RESULT
                         ( VALUE #( BASE CORRESPONDING #( LS_NCR_RESULT  MAPPING ZSIZE = SIZE )  ZIFKEY     = GS_NCR_RESULT-ZIFKEY
                                                                                                 ZSYSTEM_ID = GS_NCR_RESULT-ZSYSTEM_ID
                                                                                                 ZSTAT      = GS_NCR_RESULT-ZRESULT
                                                                                                 ZMESSAGE   = GS_NCR_RESULT-ZMESSAGE
                                                                                                 IFDAT      = GS_ZGTPPS1001-CRDAT
                                                                                                 IFTIM      = GS_ZGTPPS1001-CRTIM
                                                                                                 IFNAM      = GS_ZGTPPS1001-CRNAM ) ) ).

  TRY.
      MODIFY ZGTPPT3370 FROM TABLE LT_ZGTPPT3370.

      COMMIT WORK AND WAIT.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E05.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_para_scrap
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_MODE
*&      --> I_SYSTEM_ID
*&      --> ZO_RESULT
*&      --> ZO_MESSAGE
*&      --> IT_ITEM[]
*&      --> OT_RESULT[]
*&---------------------------------------------------------------------*
FORM CHECK_PARA_SCRAP  USING    PV_MODE
                                PV_SYSTEM_ID
                                PV_RESULT
                                PV_MESSAGE
                                PT_ITEM TYPE TY_T_SCRAP
                                PT_RESULT TYPE TY_T_SCRAP_RESULT
                        RAISING LCX_EXCEPTION.

  PV_RESULT  = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-SUCCESS.
  PV_MESSAGE = TEXT-S01.

  GS_SCRAP = VALUE #( ZMODE      = PV_MODE
                      ZSYSTEM_ID = PV_SYSTEM_ID
                      ZRESULT    = PV_RESULT
                      ZMESSAGE   = PV_MESSAGE ).

*// 처리 모드.
  IF PV_MODE IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F01.
  ELSEIF NOT CONTAINS( VAL = PV_MODE  REGEX = '[P,R,A,T,S,C,AC,TC,SC]' ) ##regex_posix.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E01.
  ENDIF.

*// 송신 시스템.
  IF PV_SYSTEM_ID IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F02.
  ENDIF.

  IF PT_ITEM IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F52.
  ENDIF.

  PT_RESULT = CORRESPONDING #( PT_ITEM[] ).
  SORT PT_RESULT BY ZSERNO.

  LOOP AT PT_ITEM INTO DATA(LS_ITEM).
    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT)
                         WITH KEY ZSERNO = LS_ITEM-ZSERNO BINARY SEARCH.

    LR_RESULT->ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.

*// 일련번호.
    IF LS_ITEM-ZSERNO IS INITIAL.
      MESSAGE E031 WITH TEXT-F44 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_SCRAP-SCRAP.
      CONTINUE.
    ENDIF.

*// 플랜트.
    IF LS_ITEM-WERKS IS INITIAL.
      MESSAGE E031 WITH TEXT-F04 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_SCRAP-SCRAP.
      CONTINUE.
    ENDIF.

*// SPG코드.
    IF PV_MODE EQ 'P' OR PV_MODE EQ 'R' OR
       PV_MODE EQ 'T' OR PV_MODE EQ 'A' OR PV_MODE EQ 'S'.
      IF LS_ITEM-SPGCD IS INITIAL.
        MESSAGE E031 WITH TEXT-F21 INTO LR_RESULT->ZERP_MESSAGE.
        APPEND LS_ITEM TO GS_SCRAP-SCRAP.
        CONTINUE.
      ENDIF.
    ENDIF.

*//자재코드.
    IF LS_ITEM-MATNR IS INITIAL.
      MESSAGE E031 WITH TEXT-F45 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_SCRAP-SCRAP.
      CONTINUE.
    ELSE.
      PERFORM CONVERSION_EXIT_MATN1_INPUT USING LS_ITEM-MATNR.
    ENDIF.

*// 저장위치.
    IF LS_ITEM-LGORT IS INITIAL.
      MESSAGE E031 WITH TEXT-F07 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_SCRAP-SCRAP.
      CONTINUE.
    ENDIF.

*// 생산오더번호.
    IF LS_ITEM-AUFNR IS NOT INITIAL.
      PERFORM CONVERSION_EXIT_ALPHA_INPUT USING LS_ITEM-AUFNR.
    ENDIF.
    IF PV_MODE EQ 'P' OR PV_MODE EQ 'T' OR PV_MODE EQ 'S'.
      IF LS_ITEM-AUFNR IS INITIAL.
        MESSAGE E031 WITH TEXT-F58 INTO LR_RESULT->ZERP_MESSAGE.
        APPEND LS_ITEM TO GS_SCRAP-SCRAP.
        CONTINUE.
      ELSE.
        PERFORM CONVERSION_EXIT_ALPHA_INPUT USING LS_ITEM-AUFNR.
      ENDIF.
    ENDIF.

*// 스크랩처리수량.
    IF PV_MODE EQ 'P' OR PV_MODE EQ 'R' OR
       PV_MODE EQ 'T' OR PV_MODE EQ 'A' OR PV_MODE EQ 'S'.
      IF LS_ITEM-MENGE IS INITIAL.
        MESSAGE E031 WITH TEXT-F59 INTO LR_RESULT->ZERP_MESSAGE.
        APPEND LS_ITEM TO GS_SCRAP-SCRAP.
        CONTINUE.
      ENDIF.
    ENDIF.

*// 단위.
    IF PV_MODE EQ 'P' OR PV_MODE EQ 'R' OR
       PV_MODE EQ 'T' OR PV_MODE EQ 'A' OR PV_MODE EQ 'S'.
      IF LS_ITEM-MEINS IS INITIAL.
        MESSAGE E031 WITH TEXT-F39 INTO LR_RESULT->ZERP_MESSAGE.
        APPEND LS_ITEM TO GS_SCRAP-SCRAP.
        CONTINUE.
      ENDIF.
    ENDIF.

*// 전기일자.
    IF LS_ITEM-BUDAT IS INITIAL.
      MESSAGE E031 WITH TEXT-F22 INTO LR_RESULT->ZERP_MESSAGE.
      APPEND LS_ITEM TO GS_SCRAP-SCRAP.
      CONTINUE.
    ENDIF.

*// 취소.
    IF PV_MODE EQ 'C' OR PV_MODE EQ 'TC' OR PV_MODE EQ 'AC' OR PV_MODE EQ 'SC'.
      IF LS_ITEM-C_MBLNR IS INITIAL.
        MESSAGE E031 WITH TEXT-F29 INTO LR_RESULT->ZERP_MESSAGE.
        APPEND LS_ITEM TO GS_SCRAP-SCRAP.
        CONTINUE.
      ENDIF.

      IF LS_ITEM-C_MJAHR IS INITIAL.
        MESSAGE E031 WITH TEXT-F28 INTO LR_RESULT->ZERP_MESSAGE.
        APPEND LS_ITEM TO GS_SCRAP-SCRAP.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF PV_MODE EQ 'P' OR PV_MODE EQ 'R' OR
       PV_MODE EQ 'T' OR PV_MODE EQ 'A' OR PV_MODE EQ 'S'.
      "배치재고
      CLEAR: GS_MCHB.
      SELECT SINGLE
             A~MATNR, A~WERKS, A~LGORT, A~CHARG, A~CLABS,
             B~MEINS
        FROM MCHB AS A
       INNER JOIN MARA AS B ON B~MATNR EQ A~MATNR
       WHERE A~MATNR EQ @LS_ITEM-MATNR
         AND A~WERKS EQ @LS_ITEM-WERKS
         AND A~LGORT EQ @LS_ITEM-LGORT
         AND A~CHARG EQ @LS_ITEM-CHARG
         AND A~CLABS GT 0
        INTO CORRESPONDING FIELDS OF @GS_MCHB.

      IF PV_MODE EQ 'T' OR PV_MODE EQ 'S'.
        IF GS_MCHB IS INITIAL.
          "판매오더 재고 추출
          SELECT SINGLE
                 A~MATNR, A~WERKS, A~LGORT, A~CHARG, A~KALAB AS CLABS,
                 A~SOBKZ, A~VBELN, A~POSNR,
                 B~MEINS
            FROM MSKA AS A
           INNER JOIN MARA AS B ON B~MATNR EQ A~MATNR
           WHERE A~MATNR = @LS_ITEM-MATNR
             AND A~WERKS = @LS_ITEM-WERKS
             AND A~LGORT = @LS_ITEM-LGORT
             AND A~CHARG = @LS_ITEM-CHARG
             AND A~KALAB GT 0
            INTO CORRESPONDING FIELDS OF @GS_MCHB.
        ENDIF.
      ENDIF.

*// 재고 존재 여부 확인
      CASE PV_MODE.
        WHEN 'P' OR 'R' OR 'T' OR 'A' OR 'S'.  "가용재고 확인
          IF GS_MCHB-CLABS EQ 0 OR GS_MCHB-CLABS LT LS_ITEM-MENGE.
            MESSAGE E000 WITH TEXT-E11 INTO LR_RESULT->ZERP_MESSAGE.
          ENDIF.
      ENDCASE.
    ENDIF.

    IF LR_RESULT->ZERP_MESSAGE IS INITIAL.
      LR_RESULT->ZERP_STAT = SPACE.
    ENDIF.

    APPEND LS_ITEM TO GS_SCRAP-SCRAP.
  ENDLOOP.

  PERFORM SAVE_SCRAP USING PT_RESULT.

  IF LINE_EXISTS( PT_RESULT[ ZERP_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E04.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_scrap
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_RESULT
*&---------------------------------------------------------------------*
FORM SAVE_SCRAP  USING PT_RESULT TYPE TY_T_SCRAP_RESULT
                 RAISING LCX_EXCEPTION.

  DATA LT_ZGTPPT3450 TYPE TABLE OF ZGTPPT3450.

  PERFORM GET_DATE_TIME.

  GET TIME STAMP FIELD GS_SCRAP-ZIFKEY.

  LT_ZGTPPT3450 = VALUE #( FOR LS_SC IN GS_SCRAP-SCRAP
                         ( VALUE #( BASE CORRESPONDING #( LS_SC ) ZIFKEY     = GS_SCRAP-ZIFKEY
                                                                  ZSYSTEM_ID = GS_SCRAP-ZSYSTEM_ID
                                                                  ZMODE      = GS_SCRAP-ZMODE
                                                                  ZSTAT      = GS_SCRAP-ZRESULT
                                                                  ZMESSAGE   = GS_SCRAP-ZMESSAGE
                                                                  IFDAT      = GS_ZGTPPS1001-CRDAT
                                                                  IFTIM      = GS_ZGTPPS1001-CRTIM
                                                                  IFNAM      = GS_ZGTPPS1001-CRNAM ) ) ).

  LOOP AT LT_ZGTPPT3450 ASSIGNING FIELD-SYMBOL(<FS_S>).
    READ TABLE PT_RESULT INTO DATA(LS_RESULT) WITH KEY ZSERNO = <FS_S>-ZSERNO.

    IF SY-SUBRC EQ 0.
      <FS_S>-ZERP_STAT = LS_RESULT-ZERP_STAT.
      <FS_S>-ZERP_MESSAGE = LS_RESULT-ZERP_MESSAGE.
    ENDIF.
  ENDLOOP.

  TRY.
      MODIFY ZGTPPT3450 FROM TABLE LT_ZGTPPT3450.

      COMMIT WORK AND WAIT.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E05.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form canceling_scrap
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> OT_RESULT[]
*&---------------------------------------------------------------------*
FORM CANCELING_SCRAP  USING PV_MODE
                            PT_RESULT TYPE TY_T_SCRAP_RESULT.

  LOOP AT GS_SCRAP-SCRAP INTO DATA(LS_SC).

    "취소 대상 자재문서 확인
    SELECT SINGLE MBLNR, MJAHR
      FROM MATDOC
     WHERE MBLNR EQ @LS_SC-C_MBLNR
       AND MJAHR EQ @LS_SC-C_MJAHR
       AND CANCELLED NE 'X'
       AND BWART EQ '261'
      INTO (@DATA(LV_MBLNR), @DATA(LV_MJAHR)).

    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LS_SC-ZSERNO BINARY SEARCH.

    IF LV_MBLNR IS INITIAL.
      PERFORM UPDATE_SCRAP_CHECK_LOG USING LS_SC LR_RESULT->*.

    ELSE.
*      취소 대상 자재문서 IF LOG에서 추출
      CLEAR: GS_3450_C.
      PERFORM GET_ZGTPPT3450 USING LS_SC PV_MODE.

* 531 입고 취소->261 투입 취소->꼬리표 잔량 UPDATE
      CLEAR: GV_CHECK.

* 531 입고 취소
      CLEAR: GV_MBLNR_I, GV_MESSAGE_MI.
      PERFORM PROC_531_I_CANCEL.

      IF GV_CHECK EQ 'E'.
        PERFORM UPDATE_531_I_LOG_CANCEL USING LS_SC LR_RESULT->*.

      ELSE.
        IF GS_3450_C-MBLNR_O IS INITIAL.
          GS_3450_C-MBLNR_O = LS_SC-C_MBLNR.
          GS_3450_C-MJAHR = LS_SC-C_MJAHR.
        ENDIF.

* 261 투입 취소
        CLEAR: GV_MBLNR_O, GV_MESSAGE_MO, GV_MJAHR.
        PERFORM PROC_261_O_CANCEL.

        IF GV_CHECK EQ 'E'.
          PERFORM UPDATE_261_O_LOG_CANCEL USING LS_SC LR_RESULT->*.

        ELSE.
* 꼬리표 잔량 UPDATE
          PERFORM UPDATE_ZPPT0001_CANCEL USING LS_SC.

          IF GV_CHECK EQ 'E'.
            PERFORM UPDATE_ZPPT0001_LOG_CANCEL USING LS_SC LR_RESULT->*.

          ELSE.
            PERFORM UPDATE_SCRAP_LOG USING LS_SC LR_RESULT->*.

*// 261, 531 모두 취소 처리 성공 시
*// 공정 외 스크랩 처리 내역 INSERT(ZGTCOT4370)
            CHECK GV_CHECK EQ SPACE.

            PERFORM SAVE_ZGTCOT4370_SC USING LS_SC
                                             PV_MODE.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_scrap_check_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_SCRAP_CHECK_LOG  USING PS_SC TYPE ZGTPPSIF0067
                                   PS_RESULT TYPE ZGTPPSIF0068.


  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = TEXT-E12. "취소할 대상의 자재문서가 잘못된 번호입니다.

  UPDATE ZGTPPT3450
     SET ZSTAT        = GS_SCRAP-ZRESULT
         ZMESSAGE     = GS_SCRAP-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
     AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
     AND ZSERNO     EQ PS_SC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_zgtppt3450
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&---------------------------------------------------------------------*
FORM GET_ZGTPPT3450  USING    PS_SC TYPE ZGTPPSIF0067
                              PV_MODE.

  CASE PV_MODE.
    WHEN 'C' OR 'AC'.
      SELECT SINGLE
             A~MBLNR_O, A~MBLNR_I, A~MJAHR, B~BUDAT
        FROM ZGTPPT3450 AS A
        JOIN MKPF AS B ON B~MBLNR EQ A~MBLNR_O
                      AND B~MJAHR EQ A~MJAHR
       WHERE A~MBLNR_O EQ @PS_SC-C_MBLNR
         AND A~MJAHR   EQ @PS_SC-C_MJAHR
        INTO CORRESPONDING FIELDS OF @GS_3450_C.

    WHEN 'TC' OR 'SC'.
      SELECT SINGLE
             A~MBLNR_O, A~MBLNR_I, A~MBLNR_Z, A~MJAHR, A~CO_ORDER
        FROM ZGTPPT3450 AS A
        JOIN MKPF AS B ON B~MBLNR EQ A~MBLNR_O
                      AND B~MJAHR EQ A~MJAHR
       WHERE A~MBLNR_O EQ @PS_SC-C_MBLNR
         AND A~MJAHR   EQ @PS_SC-C_MJAHR
        INTO CORRESPONDING FIELDS OF @GS_3450_TC.

      SELECT SINGLE BUDAT
        FROM MATDOC
       WHERE MBLNR EQ @GS_3450_TC-MBLNR_O
         AND MJAHR EQ @GS_3450_TC-MJAHR
        INTO @GS_3450_TC-BUDAT_O.

      SELECT SINGLE BUDAT
        FROM MATDOC
       WHERE MBLNR EQ @GS_3450_TC-MBLNR_I
         AND MJAHR EQ @GS_3450_TC-MJAHR
        INTO @GS_3450_TC-BUDAT_I.

      SELECT SINGLE BUDAT
        FROM MATDOC
       WHERE MBLNR EQ @GS_3450_TC-MBLNR_Z
         AND MJAHR EQ @GS_3450_TC-MJAHR
        INTO @GS_3450_TC-BUDAT_Z.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_531_i_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_531_I_CANCEL .

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LT_ITEM TYPE TABLE OF BAPI2017_GM_ITEM_04.
  DATA LS_ITEM TYPE BAPI2017_GM_ITEM_04.
  DATA LT_ZEILE TYPE TABLE OF BAPI2017_GM_ITEM_04.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LV_HEADTEXT TYPE BKTXT.

  CHECK GS_3450_C-MBLNR_I IS NOT INITIAL.

  "취소 문서의 품목번호별 추출
  CLEAR: LT_ZEILE.
  SELECT ZEILE
    FROM MATDOC
   WHERE MBLNR EQ @GS_3450_C-MBLNR_I
     AND MJAHR EQ @GS_3450_C-MJAHR
     AND CANCELLED NE 'X'
    INTO TABLE @LT_ZEILE.

  CHECK LT_ZEILE[] IS NOT INITIAL.

  "품목번호별로 취소
  LOOP AT LT_ZEILE INTO DATA(LS_ZEILE).

    CLEAR: LT_ITEM[].
    LS_ITEM-MATDOC_ITEM = LS_ZEILE-MATDOC_ITEM.
    APPEND LS_ITEM TO LT_ITEM.

    "531 입고 취소
    CLEAR: LS_HEADRET, LT_RETURN, LV_HEADTEXT.
    LV_HEADTEXT = TEXT-M08. "MES 스크랩 입고 취소 I/F

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = GS_3450_C-MBLNR_I
        MATDOCUMENTYEAR     = GS_3450_C-MJAHR
        GOODSMVT_PSTNG_DATE = GS_3450_C-BUDAT
        GOODSMVT_PR_UNAME   = SY-UNAME
        DOCUMENTHEADER_TEXT = LV_HEADTEXT
      IMPORTING
        GOODSMVT_HEADRET    = LS_HEADRET
      TABLES
        RETURN              = LT_RETURN
        GOODSMVT_MATDOCITEM = LT_ITEM.

    IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
      "성공
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      DO 10 TIMES.
        SELECT SINGLE @ABAP_TRUE
          INTO @DATA(LV_CHECK)
          FROM MKPF
         WHERE MBLNR EQ @LS_HEADRET-MAT_DOC
           AND MJAHR EQ @LS_HEADRET-DOC_YEAR.

        IF SY-SUBRC IS INITIAL.
          GV_MBLNR_I = LS_HEADRET-MAT_DOC.
          EXIT.
        ENDIF.

        WAIT UP TO '1' SECONDS.
      ENDDO.

    ELSE.
      "오류
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      GV_MESSAGE_MI = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

      GV_CHECK = 'E'.

    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_531_i_log_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_531_I_LOG_CANCEL  USING    PS_SC TYPE ZGTPPSIF0067
                                       PS_RESULT TYPE ZGTPPSIF0068.

  CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MI.

  UPDATE ZGTPPT3450
     SET ZSTAT        = GS_SCRAP-ZRESULT
         ZMESSAGE     = GS_SCRAP-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
     AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
     AND ZSERNO     EQ PS_SC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_261_o_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_261_O_CANCEL .

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LT_ITEM TYPE TABLE OF BAPI2017_GM_ITEM_04.
  DATA LS_ITEM TYPE BAPI2017_GM_ITEM_04.
  DATA LT_ZEILE TYPE TABLE OF BAPI2017_GM_ITEM_04.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LV_HEADTEXT TYPE BKTXT.

  CHECK GS_3450_C-MBLNR_O IS NOT INITIAL.

  "취소 문서의 품목번호별 추출
  CLEAR: LT_ZEILE.
  SELECT ZEILE
    FROM MATDOC
   WHERE MBLNR EQ @GS_3450_C-MBLNR_O
     AND MJAHR EQ @GS_3450_C-MJAHR
     AND CANCELLED NE 'X'
    INTO TABLE @LT_ZEILE.

  CHECK LT_ZEILE[] IS NOT INITIAL.

  "품목번호별로 취소
  LOOP AT LT_ZEILE INTO DATA(LS_ZEILE).

    CLEAR: LT_ITEM[].
    LS_ITEM-MATDOC_ITEM = LS_ZEILE-MATDOC_ITEM.
    APPEND LS_ITEM TO LT_ITEM.

    "261 투입 취소
    CLEAR: LS_HEADRET, LT_RETURN, LV_HEADTEXT.
    LV_HEADTEXT = TEXT-M09. "MES 스크랩 출고 취소 I/F

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = GS_3450_C-MBLNR_O
        MATDOCUMENTYEAR     = GS_3450_C-MJAHR
        GOODSMVT_PSTNG_DATE = GS_3450_C-BUDAT
        GOODSMVT_PR_UNAME   = SY-UNAME
        DOCUMENTHEADER_TEXT = LV_HEADTEXT
      IMPORTING
        GOODSMVT_HEADRET    = LS_HEADRET
      TABLES
        RETURN              = LT_RETURN
        GOODSMVT_MATDOCITEM = LT_ITEM.

    IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
      "성공
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      DO 10 TIMES.
        SELECT SINGLE @ABAP_TRUE
          INTO @DATA(LV_CHECK)
          FROM MKPF
         WHERE MBLNR EQ @LS_HEADRET-MAT_DOC
           AND MJAHR EQ @LS_HEADRET-DOC_YEAR.

        IF SY-SUBRC IS INITIAL.
          GV_MBLNR_O = LS_HEADRET-MAT_DOC.
          GV_MJAHR   = LS_HEADRET-DOC_YEAR.
          EXIT.
        ENDIF.

        WAIT UP TO '1' SECONDS.
      ENDDO.

    ELSE.
      "오류
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      GV_MESSAGE_MO = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

      GV_CHECK = 'E'.

    ENDIF.

    CLEAR: LS_ZEILE, LS_ITEM.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_261_o_log_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_261_O_LOG_CANCEL  USING    PS_SC TYPE ZGTPPSIF0067
                                       PS_RESULT TYPE ZGTPPSIF0068.

  CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MO.

  UPDATE ZGTPPT3450
     SET ZSTAT        = GS_SCRAP-ZRESULT
         ZMESSAGE     = GS_SCRAP-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
     AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
     AND ZSERNO     EQ PS_SC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_zppt0001_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM UPDATE_ZPPT0001_CANCEL  USING    PS_SC TYPE ZGTPPSIF0067.

  DATA: LV_O_MENGE TYPE BSTMG.
  DATA: LV_REMAIN LIKE ZPPT0001-REMAIN.

  SELECT SINGLE *
    FROM ZPPT0001
   WHERE WERKS EQ @PS_SC-WERKS
     AND TAGNR EQ @PS_SC-TAGNR
     AND CHARG EQ @PS_SC-CHARG
     AND MATNR EQ @PS_SC-MATNR
    INTO @DATA(LS_0001).

  CHECK LS_0001 IS NOT INITIAL.

  SELECT SINGLE MENGE, MEINS
    FROM ZGTPPT3450
   WHERE MBLNR_O EQ @PS_SC-C_MBLNR
     AND MJAHR   EQ @PS_SC-C_MJAHR
    INTO ( @DATA(LV_MENGE), @DATA(LV_MEINS) ).

  IF LV_MEINS NE LS_0001-MEINS.
    CLEAR: LV_O_MENGE.
    CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
      EXPORTING
        I_MATNR              = PS_SC-MATNR
        I_IN_ME              = LV_MEINS
        I_OUT_ME             = LS_0001-MEINS
        I_MENGE              = LV_MENGE
      IMPORTING
        E_MENGE              = LV_O_MENGE
      EXCEPTIONS
        ERROR_IN_APPLICATION = 1
        ERROR                = 2
        OTHERS               = 3.
  ELSE.
    LV_O_MENGE = LV_MENGE.
  ENDIF.

  CLEAR: LV_REMAIN.
  LV_REMAIN = LS_0001-REMAIN + LV_O_MENGE.

  UPDATE ZPPT0001
     SET REMAIN = LV_REMAIN
         GIFLG  = 'N'
   WHERE WERKS = PS_SC-WERKS
     AND TAGNR = PS_SC-TAGNR
     AND CHARG = PS_SC-CHARG
     AND MATNR = PS_SC-MATNR.

  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    GV_CHECK = 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_zppt0001_log_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_ZPPT0001_LOG_CANCEL  USING    PS_SC TYPE ZGTPPSIF0067
                                          PS_RESULT TYPE ZGTPPSIF0068.

  CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = TEXT-E13. "꼬리표 저장 중 오류가 발생하였습니다.

  UPDATE ZGTPPT3450
     SET ZSTAT        = GS_SCRAP-ZRESULT
         ZMESSAGE     = GS_SCRAP-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
     AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
     AND ZSERNO     EQ PS_SC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_scrap_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_SCRAP_LOG  USING    PS_SC TYPE ZGTPPSIF0067
                                PS_RESULT TYPE ZGTPPSIF0068.

  PS_RESULT = VALUE #( BASE PS_RESULT  MBLNR        = GV_MBLNR_O
                                       MJAHR        = GV_MJAHR
                                       ZERP_STAT    = COND #( WHEN GV_MBLNR_O IS NOT INITIAL THEN ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                                              ELSE ZGTPP_IF_CONST=>GC_RESULT-ERROR )
                                       ZERP_MESSAGE = COND #( WHEN GV_MBLNR_O IS NOT INITIAL THEN COND #( WHEN GS_SCRAP-ZMODE EQ 'P' THEN TEXT-S09
                                                                                                          WHEN GS_SCRAP-ZMODE EQ 'R' THEN TEXT-S09
                                                                                                          WHEN GS_SCRAP-ZMODE EQ 'A' THEN TEXT-S09
                                                                                                          ELSE TEXT-S10 )
                                                              ELSE GV_MESSAGE_MO ) ).

  IF GS_SCRAP-ZMODE EQ 'P' OR GS_SCRAP-ZMODE EQ 'R' OR GS_SCRAP-ZMODE EQ 'A'.
    UPDATE ZGTPPT3450
       SET MBLNR_O      = GV_MBLNR_O
           MBLNR_I      = GV_MBLNR_I
           MJAHR        = GV_MJAHR
           ZSTAT        = GS_SCRAP-ZRESULT
           ZMESSAGE     = GS_SCRAP-ZMESSAGE
           ZERP_STAT    = PS_RESULT-ZERP_STAT
           ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
     WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
       AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
       AND ZSERNO     EQ PS_SC-ZSERNO.

  ELSEIF GS_SCRAP-ZMODE EQ 'C' OR GS_SCRAP-ZMODE EQ 'AC'.
    UPDATE ZGTPPT3450
       SET ZSTAT        = GS_SCRAP-ZRESULT
           ZMESSAGE     = GS_SCRAP-ZMESSAGE
           ZERP_STAT    = PS_RESULT-ZERP_STAT
           ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
     WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
       AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
       AND ZSERNO     EQ PS_SC-ZSERNO.

  ENDIF.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_add_qty
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&---------------------------------------------------------------------*
FORM GET_ADD_QTY  USING   PS_SC TYPE ZGTPPSIF0067
                          PV_MODE.

  DATA: LT_261     LIKE TABLE OF GS_ADD_QTY,
        LT_101     LIKE TABLE OF GS_ADD_QTY,
        LT_ADD_QTY LIKE TABLE OF GS_ADD_QTY.

  DATA: BEGIN OF LS_AUFNR,
          AUFNR  TYPE AUFNR,
          DEL(1),
        END OF LS_AUFNR.
  DATA: LT_AUFNR  LIKE TABLE OF LS_AUFNR,
        LT_OAUFNR LIKE TABLE OF LS_AUFNR.

  DATA: LV_SUM_REM TYPE MENGE_D,  "잔량sum(기존+잔량)
        LV_SUM_PRD TYPE MENGE_D.  "생산량sum

  DATA: LV_REMAIN      TYPE MENGE_D,
        LV_SUM_PLN_INP TYPE MENGE_D.

  DATA: LV_YYYYMM LIKE ZPPT0600-INSMM.

  RANGES: LR_BUDAT FOR MATDOC-BUDAT.

  "대상년월 추출
  CLEAR: LV_YYYYMM.
  IF PV_MODE EQ 'A'.
    "재고실사결과테이블의 플랜트별 재고실사년월의 최근 년월이 대상
    SELECT SINGLE MAX( INSMM )
      FROM ZPPT0600
     WHERE WERKS EQ @PS_SC-WERKS
      INTO @LV_YYYYMM.
  ELSEIF PV_MODE EQ 'R'.
    "I/F 전기일의 년월이 대상
    LV_YYYYMM = PS_SC-BUDAT+0(6).
  ENDIF.

  IF LV_YYYYMM IS NOT INITIAL.
    "대상기간 구성
    CLEAR: LR_BUDAT[], LR_BUDAT.
    LR_BUDAT-SIGN = 'I'.
    LR_BUDAT-OPTION = 'BT'.

    LR_BUDAT-LOW = LV_YYYYMM && |01|.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN            = LR_BUDAT-LOW
      IMPORTING
        LAST_DAY_OF_MONTH = LR_BUDAT-HIGH
      EXCEPTIONS
        DAY_IN_NO_DATE    = 1
        OTHERS            = 2.

    APPEND LR_BUDAT.
  ENDIF.

  CHECK LR_BUDAT[] IS NOT INITIAL.

  "대상 생산오더 추출
  CLEAR: LT_AUFNR.
  SELECT AUFNR
    FROM MATDOC
   WHERE MATNR EQ @PS_SC-MATNR
     AND WERKS EQ @PS_SC-WERKS
     AND LGORT EQ @PS_SC-LGORT
     AND BUDAT IN @LR_BUDAT
     AND BWART EQ '261'
     AND CANCELLED NE 'X'
     AND REVERSAL_MOVEMENT NE 'X'
    INTO CORRESPONDING FIELDS OF TABLE @LT_AUFNR.

  SORT LT_AUFNR BY AUFNR.
  DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING AUFNR.

  "대상 생산오더의 다른 전기일에 해당되면 제외
  IF LT_AUFNR[] IS NOT INITIAL.
    CLEAR: LT_OAUFNR.
    SELECT AUFNR
      FROM MATDOC
       FOR ALL ENTRIES IN @LT_AUFNR
     WHERE AUFNR EQ @LT_AUFNR-AUFNR
       AND BUDAT NOT IN @LR_BUDAT
      INTO CORRESPONDING FIELDS OF TABLE @LT_OAUFNR.

    SORT LT_OAUFNR BY AUFNR.
    DELETE ADJACENT DUPLICATES FROM LT_OAUFNR COMPARING AUFNR.
  ENDIF.

  LOOP AT LT_AUFNR ASSIGNING FIELD-SYMBOL(<FS_A>).
    READ TABLE LT_OAUFNR INTO DATA(LS_OA) WITH KEY AUFNR = <FS_A>-AUFNR.
    IF SY-SUBRC EQ 0.
      <FS_A>-DEL = 'X'.
    ENDIF.
  ENDLOOP.

  DELETE LT_AUFNR WHERE DEL EQ 'X'.

  SORT LT_AUFNR BY AUFNR.

  CHECK LT_AUFNR IS NOT INITIAL.

  "생산오더별 I/F 자재 투입량 추출
  CLEAR: LT_261, LS_AUFNR.
  LOOP AT LT_AUFNR INTO LS_AUFNR.
    SELECT AUFNR, MENGE AS INP_QTY, MEINS
      FROM MATDOC
     WHERE AUFNR EQ @LS_AUFNR-AUFNR
       AND MATNR EQ @PS_SC-MATNR
       AND WERKS EQ @PS_SC-WERKS
       AND LGORT EQ @PS_SC-LGORT
       AND BWART EQ '261'
       AND CANCELLED NE 'X'
       AND REVERSAL_MOVEMENT NE 'X'
      APPENDING CORRESPONDING FIELDS OF TABLE @LT_261.
  ENDLOOP.

  CLEAR: GT_ADD_QTY, LV_SUM_REM.
  LOOP AT LT_261 INTO DATA(LS_261).
    MOVE-CORRESPONDING LS_261 TO GS_ADD_QTY.  "기존투입량/투입단위

    LV_SUM_REM = LV_SUM_REM + GS_ADD_QTY-INP_QTY.

    COLLECT GS_ADD_QTY INTO GT_ADD_QTY.

    CLEAR: LS_261, GS_ADD_QTY.
  ENDLOOP.

  CHECK GT_ADD_QTY IS NOT INITIAL.

  "잔량sum = 기존투입량+I/F잔량
  LV_SUM_REM = LV_SUM_REM + PS_SC-MENGE.

  SORT: GT_ADD_QTY BY AUFNR.

  "생산오더별 생산량 추출
  CLEAR: LT_101, GS_ADD_QTY.
  LOOP AT GT_ADD_QTY INTO GS_ADD_QTY.
    SELECT AUFNR, MENGE AS PRD_QTY, MEINS AS PMEINS
      FROM MATDOC
     WHERE AUFNR EQ @GS_ADD_QTY-AUFNR
       AND BWART EQ '101'
       AND CANCELLED NE 'X'
       AND REVERSAL_MOVEMENT NE 'X'
      APPENDING CORRESPONDING FIELDS OF TABLE @LT_101.
  ENDLOOP.

  CLEAR: LT_ADD_QTY, LV_SUM_PRD.
  LOOP AT LT_101 INTO DATA(LS_101).
    MOVE-CORRESPONDING LS_101 TO GS_ADD_QTY.

    LV_SUM_PRD = LV_SUM_PRD + GS_ADD_QTY-PRD_QTY.  "생산량sum

    COLLECT GS_ADD_QTY INTO LT_ADD_QTY.

    CLEAR: LS_101, GS_ADD_QTY.
  ENDLOOP.

  SORT: LT_ADD_QTY BY AUFNR.

  CLEAR: LV_SUM_PLN_INP.
  LOOP AT GT_ADD_QTY ASSIGNING FIELD-SYMBOL(<FS_ADD>).
    READ TABLE LT_ADD_QTY INTO DATA(LS_ADD) WITH KEY AUFNR = <FS_ADD>-AUFNR.

    IF SY-SUBRC EQ 0.
      <FS_ADD>-PRD_QTY = LS_ADD-PRD_QTY.  "생산량
      <FS_ADD>-PMEINS  = LS_ADD-PMEINS.   "생산단위
    ENDIF.

    "목표투입량 = 잔량sum(기존투입량+잔량) * 생산량 / 생산량sum
    <FS_ADD>-PLN_QTY = LV_SUM_REM * <FS_ADD>-PRD_QTY / LV_SUM_PRD.

    "목표-기존 투입량
    <FS_ADD>-PLN_INP = <FS_ADD>-PLN_QTY - <FS_ADD>-INP_QTY.

    "목표-기존 투입량 SUM
    IF <FS_ADD>-PLN_INP > 0.
      LV_SUM_PLN_INP = LV_SUM_PLN_INP + <FS_ADD>-PLN_INP.
    ENDIF.

    "기존투입량>=목표투입량 추가 투입 제외
    IF <FS_ADD>-PLN_INP LE 0.
      <FS_ADD>-DEL = 'X'.
    ENDIF.
  ENDLOOP.

  DELETE GT_ADD_QTY WHERE DEL = 'X'.

  CLEAR: LV_REMAIN.
  LV_REMAIN = PS_SC-MENGE.  "I/F 잔량

  "목표-기준 투입량이 큰 순으로 추가 투입
  SORT GT_ADD_QTY BY PLN_INP DESCENDING.

  "추가투입 계산
  UNASSIGN <FS_ADD>.
  LOOP AT GT_ADD_QTY ASSIGNING <FS_ADD>.

    "I/F 잔량이 목표-기존 투입량 보다 작거나 같으면 모두 투입함
*    IF LV_REMAIN <= <FS_ADD>-PLN_INP.
*      <FS_ADD>-ADD_QTY = LV_REMAIN.
*      EXIT.
*    ENDIF.

    "추가 투입량 = I/F잔량 * ( 목표-기존 투입량 / 목표-기존 투입량 SUM )
    <FS_ADD>-ADD_QTY = PS_SC-MENGE * ( <FS_ADD>-PLN_INP / LV_SUM_PLN_INP ).

    "I/F 잔량에서 추가 투입량 만큼 빼기
    LV_REMAIN = LV_REMAIN - <FS_ADD>-ADD_QTY.

    IF LV_REMAIN <= 0.
      EXIT.
    ENDIF.
  ENDLOOP.

* I/F 잔량이 남으면 추가 투입량이 제일 큰 오더에 투입
  IF LV_REMAIN NE 0.
    SORT GT_ADD_QTY BY ADD_QTY DESCENDING.
    UNASSIGN <FS_ADD>.
    READ TABLE GT_ADD_QTY ASSIGNING <FS_ADD> INDEX 1.
    <FS_ADD>-ADD_QTY = <FS_ADD>-ADD_QTY + LV_REMAIN.
  ENDIF.

  "추가 투입량이 없는 것은 제외
  DELETE GT_ADD_QTY WHERE ADD_QTY = 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form processing_scrap
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_MODE
*&      --> OT_RESULT[]
*&---------------------------------------------------------------------*
FORM PROCESSING_SCRAP  USING PV_MODE
                             PT_RESULT TYPE TY_T_SCRAP_RESULT.

  LOOP AT GS_SCRAP-SCRAP INTO DATA(LS_SC).

    IF PV_MODE EQ 'R'.
      PERFORM GET_ADD_QTY USING LS_SC PV_MODE.
    ENDIF.

    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LS_SC-ZSERNO BINARY SEARCH.

    CLEAR: GV_CHECK.
    IF PV_MODE EQ 'R'.
      IF GT_ADD_QTY IS INITIAL.
        PERFORM UPDATE_ADD_QTY_LOG USING LS_SC LR_RESULT->* PV_MODE.
        GV_CHECK = 'X'.
      ENDIF.
    ENDIF.

    CHECK GV_CHECK IS INITIAL.

* 261 투입 처리
    CLEAR: GV_MBLNR_O, GV_MESSAGE_MO, GV_MJAHR.
    PERFORM PROC_261_O USING LS_SC PV_MODE.

    PERFORM UPDATE_261_O_LOG USING LS_SC LR_RESULT->*.

    CHECK GV_MBLNR_O IS NOT INITIAL.

* 꼬리표 잔량 UPDATE
    CLEAR: GV_CHECK.
    PERFORM UPDATE_ZPPT0001 USING LS_SC.

    CHECK GV_CHECK IS INITIAL.

*531 입고 처리
    CLEAR: GV_MBLNR_I, GV_MESSAGE_MI.
    PERFORM PROC_531_I USING LS_SC PV_MODE.

    PERFORM UPDATE_531_I_LOG USING LS_SC LR_RESULT->*.

    CHECK GV_MBLNR_I IS NOT INITIAL.

    PERFORM UPDATE_SCRAP_LOG USING LS_SC LR_RESULT->*.

*// 261, 531 모두 처리 성공 시
*// 공정 외 스크랩 처리 내역 INSERT(ZGTCOT4370)
    CHECK GV_MBLNR_O IS NOT INITIAL.
    CHECK GV_MBLNR_I IS NOT INITIAL.

    PERFORM SAVE_ZGTCOT4370_SC USING LS_SC
                                     PV_MODE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_261_o
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&---------------------------------------------------------------------*
FORM PROC_261_O  USING    PS_SC TYPE ZGTPPSIF0067
                          PV_MODE.

  DATA: LS_COBL    TYPE COBL,
        LS_HEADER  TYPE BAPI2017_GM_HEAD_01,
        LS_GMCODE  TYPE BAPI2017_GM_CODE,
        LS_HEADRET TYPE BAPI2017_GM_HEAD_RET,
        LV_MATDOC  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_DOCYER  TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_ITEM    TYPE BAPI2017_GM_ITEM_CREATE,
        LT_ITEM    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_EXT     TYPE STANDARD TABLE OF BAPIPAREX,
        LS_EXT     TYPE BAPIPAREX,
        LT_RETURN  TYPE TABLE OF BAPIRET2.

  "GM_CODE
  LS_GMCODE-GM_CODE = '03'. "출고전기

  "Header
  LS_HEADER-PSTNG_DATE = PS_SC-BUDAT.
  LS_HEADER-DOC_DATE   = PS_SC-BUDAT.
  LS_HEADER-PR_UNAME   = SY-UNAME.
  LS_HEADER-HEADER_TXT = TEXT-M06. "MES 스크랩 출고 I/F

  "Item
  IF PV_MODE = 'R' OR PV_MODE = 'A'.
    LOOP AT GT_ADD_QTY INTO DATA(LS_ADD).
      LS_ITEM-MATERIAL  = PS_SC-MATNR.
      LS_ITEM-PLANT     = PS_SC-WERKS.
      LS_ITEM-STGE_LOC  = PS_SC-LGORT.
      LS_ITEM-BATCH     = PS_SC-CHARG.
      LS_ITEM-MOVE_TYPE = '261'.
      LS_ITEM-STCK_TYPE = 'F'.

      LS_ITEM-ENTRY_QNT = LS_ADD-ADD_QTY.
      LS_ITEM-ENTRY_UOM = LS_ADD-MEINS.
      LS_ITEM-ORDERID   = LS_ADD-AUFNR.
      LS_ITEM-GR_RCPT   = TEXT-T01.      "수령인 = 스크랩처리로 구분

      APPEND LS_ITEM TO LT_ITEM.
      CLEAR: LS_ITEM, LS_ADD.
    ENDLOOP.

  ELSEIF PV_MODE = 'P'.
    LS_ITEM-MATERIAL  = PS_SC-MATNR.
    LS_ITEM-PLANT     = PS_SC-WERKS.
    LS_ITEM-STGE_LOC  = PS_SC-LGORT.
    LS_ITEM-BATCH     = PS_SC-CHARG.
    LS_ITEM-MOVE_TYPE = '261'.
    LS_ITEM-STCK_TYPE = 'F'.

    LS_ITEM-ENTRY_QNT = PS_SC-MENGE.
    LS_ITEM-ENTRY_UOM = PS_SC-MEINS.
    LS_ITEM-ORDERID   = PS_SC-AUFNR.

    APPEND LS_ITEM TO LT_ITEM.
  ENDIF.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LS_GMCODE
    IMPORTING
      GOODSMVT_HEADRET = LS_HEADRET
      MATERIALDOCUMENT = LV_MATDOC
      MATDOCUMENTYEAR  = LV_DOCYER
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = LT_RETURN.

  IF LV_MATDOC IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    GV_MBLNR_O = LV_MATDOC. "전표번호
    GV_MJAHR   = LV_DOCYER. "전표년도

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    GV_MESSAGE_MO = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_261_o_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_261_O_LOG  USING    PS_SC TYPE ZGTPPSIF0067
                                PS_RESULT TYPE ZGTPPSIF0068.

  IF GV_MBLNR_O IS INITIAL.
    PS_RESULT-ZERP_STAT = 'E'.
    PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MO.

    UPDATE ZGTPPT3450
       SET ZSTAT        = GS_SCRAP-ZRESULT
           ZMESSAGE     = GS_SCRAP-ZMESSAGE
           ZERP_STAT    = PS_RESULT-ZERP_STAT
           ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
     WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
       AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
       AND ZSERNO     EQ PS_SC-ZSERNO.

  ENDIF.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_zppt0001
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&---------------------------------------------------------------------*
FORM UPDATE_ZPPT0001  USING    PS_SC TYPE ZGTPPSIF0067.

  DATA: LV_O_MENGE TYPE BSTMG.
  DATA: LV_REMAIN LIKE ZPPT0001-REMAIN.
  DATA: LV_GIFLG LIKE ZPPT0001-GIFLG.

  SELECT SINGLE *
    FROM ZPPT0001
   WHERE WERKS EQ @PS_SC-WERKS
     AND TAGNR EQ @PS_SC-TAGNR
     AND CHARG EQ @PS_SC-CHARG
     AND MATNR EQ @PS_SC-MATNR
    INTO @DATA(LS_0001).

  CHECK LS_0001 IS NOT INITIAL.

  IF PS_SC-MEINS NE LS_0001-MEINS.
    CLEAR: LV_O_MENGE.
    CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
      EXPORTING
        I_MATNR              = PS_SC-MATNR
        I_IN_ME              = PS_SC-MEINS
        I_OUT_ME             = LS_0001-MEINS
        I_MENGE              = PS_SC-MENGE
      IMPORTING
        E_MENGE              = LV_O_MENGE
      EXCEPTIONS
        ERROR_IN_APPLICATION = 1
        ERROR                = 2
        OTHERS               = 3.
  ELSE.
    LV_O_MENGE = PS_SC-MENGE.
  ENDIF.

  CLEAR: LV_REMAIN.
  LV_REMAIN = LS_0001-REMAIN - LV_O_MENGE.

  CLEAR: LV_GIFLG.
  IF LV_REMAIN = 0.
    LV_GIFLG = 'Y'.
  ELSE.
    LV_GIFLG = LS_0001-GIFLG.
  ENDIF.

  UPDATE ZPPT0001
     SET REMAIN = LV_REMAIN
         GIFLG  = LV_GIFLG
   WHERE WERKS = PS_SC-WERKS
     AND TAGNR = PS_SC-TAGNR
     AND CHARG = PS_SC-CHARG
     AND MATNR = PS_SC-MATNR.

  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    GV_CHECK = 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_531_i
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&---------------------------------------------------------------------*
FORM PROC_531_I USING PS_SC TYPE ZGTPPSIF0067
                      PV_MODE.

  DATA: LS_COBL    TYPE COBL,
        LS_HEADER  TYPE BAPI2017_GM_HEAD_01,
        LS_GMCODE  TYPE BAPI2017_GM_CODE,
        LS_HEADRET TYPE BAPI2017_GM_HEAD_RET,
        LV_MATDOC  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_DOCYER  TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_ITEM    TYPE BAPI2017_GM_ITEM_CREATE,
        LT_ITEM    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_EXT     TYPE STANDARD TABLE OF BAPIPAREX,
        LS_EXT     TYPE BAPIPAREX,
        LT_RETURN  TYPE TABLE OF BAPIRET2.

  "대상 자재의 공정그룹(자재그룹) 추출
  SELECT SINGLE MATKL
    FROM MARA
   WHERE MATNR = @PS_SC-MATNR
    INTO @DATA(LV_MATKL).

  "반제품의 자재그룹(공정그룹) 기준의 스크랩 자재코드 추출
  SELECT SINGLE WERKS, SPGCD, MATNR AS SCMATNR
    FROM ZGTPPT1140
   WHERE WERKS = @PS_SC-WERKS
     AND SPGCD = @PS_SC-SPGCD
     AND MATKL = @LV_MATKL
    INTO @DATA(LS_1140).

  CHECK SY-SUBRC = 0.   "스크랩 자재코드 없는 경우 531 방지, 261만 처리

  "GM_CODE
  LS_GMCODE-GM_CODE = '05'. "입고전기

  "Header
  LS_HEADER-PSTNG_DATE      = PS_SC-BUDAT.
  LS_HEADER-DOC_DATE        = PS_SC-BUDAT.
  LS_HEADER-PR_UNAME        = SY-UNAME.
  LS_HEADER-VER_GR_GI_SLIP  = '2'.
  LS_HEADER-VER_GR_GI_SLIPX = 'X'.
  LS_HEADER-HEADER_TXT      = TEXT-M07. "MES 스크랩 입고 I/F

  "Item
  IF PV_MODE = 'R' OR PV_MODE = 'A'.
    LOOP AT GT_ADD_QTY INTO DATA(LS_ADD).
      CLEAR: GV_CONVQTY.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          I_MATNR              = PS_SC-MATNR
          I_IN_ME              = PS_SC-MEINS
          I_OUT_ME             = 'KG'
          I_MENGE              = LS_ADD-ADD_QTY
        IMPORTING
          E_MENGE              = GV_CONVQTY
        EXCEPTIONS
          ERROR_IN_APPLICATION = 1
          ERROR                = 2
          OTHERS               = 3.

***  2026.06.25 ksw ***
      IF SY-SUBRC NE 0.
        SELECT SINGLE MATNR_N, NTGEW, GEWEI
          FROM ZEDT1050
         WHERE MATNR_N = @PS_SC-MATNR
          INTO @DATA(LS_WEIGHT).

        IF SY-SUBRC = 0.
          GV_CONVQTY = LS_ADD-ADD_QTY * LS_WEIGHT-NTGEW / 1000.
          "스크랩 처리 중량 = 스크랩 처리 길이 * 설계서 순 중량 / 1000(설계서 기본단위)
        ELSE.
*  설계서 중량 정보 없으면, 자재마스터 순중량 대입
          SELECT SINGLE MATNR, NTGEW, GEWEI, MTART, SPART
            FROM MARA
           WHERE MATNR = @PS_SC-MATNR
            INTO @DATA(LS_MARA).
          IF SY-SUBRC = 0.
            IF LS_MARA-MTART = 'MCHA' OR LS_MARA-MTART = 'MCHF'.  "순수상품은 M/중량단위 = 환산량
              IF LS_MARA-GEWEI = 'G'.
                GV_CONVQTY = LS_ADD-ADD_QTY * LS_MARA-NTGEW.        "NTGEW = M/G
              ELSEIF LS_MARA-GEWEI = 'KG'.
                GV_CONVQTY = LS_ADD-ADD_QTY * LS_MARA-NTGEW / 1000. "NTGEW = M/KG으로, NTGEW / 1000 = M/G은 총 스크랩 중량
              ENDIF.
            ELSEIF LS_MARA-MTART = 'MCFE' AND LS_MARA-SPART = '23'.
              GV_CONVQTY = LS_ADD-ADD_QTY * LS_MARA-NTGEW / 1000. "NTGEW = M/KG으로, CONVQTY = M * KG은 총 스크랩 중량
            ELSE.
              GV_CONVQTY = LS_ADD-ADD_QTY * LS_MARA-NTGEW.        "NTGEW = M/G
            ENDIF.
          ENDIF.
*          SELECT SINGLE MATNR, NTGEW, GEWEI
*            FROM MARA
*           WHERE MATNR = @PS_SC-MATNR
*            INTO @LS_WEIGHT.
*          IF SY-SUBRC = 0.
*            GV_CONVQTY = LS_ADD-ADD_QTY * LS_WEIGHT-NTGEW / 1000. "NTGEW = KM/KG으로, KM * KG은 총 스크랩 중량
*          ENDIF.
        ENDIF.
      ENDIF.

      IF GV_CONVQTY <= 0.
        GV_531_SKIP = 'X'.
      ENDIF.
***  2026.06.25 ksw ***

      LS_ITEM-MATERIAL  = LS_1140-SCMATNR.
      LS_ITEM-PLANT     = PS_SC-WERKS.

      IF PS_SC-WERKS EQ '6500'.
        LS_ITEM-STGE_LOC  = '2190'.
      ELSEIF PS_SC-WERKS EQ '6600'.
        IF PS_SC-SPGCD EQ 'GO'.
          LS_ITEM-STGE_LOC  = '2190'.
        ELSEIF PS_SC-SPGCD EQ 'GL'.
          LS_ITEM-STGE_LOC  = '2390'.
        ENDIF.
      ENDIF.

      LS_ITEM-MOVE_TYPE = '531'.
      LS_ITEM-STCK_TYPE = 'F'.

      LS_ITEM-ENTRY_QNT = GV_CONVQTY.
      LS_ITEM-ENTRY_UOM = 'KG'.
      LS_ITEM-ORDERID   = LS_ADD-AUFNR.

      APPEND LS_ITEM TO LT_ITEM.
      CLEAR: LS_ITEM, LS_ADD.
    ENDLOOP.

  ELSEIF PV_MODE = 'P'.
    CLEAR: GV_CONVQTY.
    CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
      EXPORTING
        I_MATNR              = PS_SC-MATNR
        I_IN_ME              = PS_SC-MEINS
        I_OUT_ME             = 'KG'
        I_MENGE              = PS_SC-MENGE
      IMPORTING
        E_MENGE              = GV_CONVQTY
      EXCEPTIONS
        ERROR_IN_APPLICATION = 1
        ERROR                = 2
        OTHERS               = 3.

***  2026.06.25 ksw ***
    IF SY-SUBRC NE 0.
      SELECT SINGLE MATNR_N, NTGEW, GEWEI
        FROM ZEDT1050
       WHERE MATNR_N = @PS_SC-MATNR
        INTO CORRESPONDING FIELDS OF @LS_WEIGHT.

      IF SY-SUBRC = 0.
        GV_CONVQTY = PS_SC-MENGE * LS_WEIGHT-NTGEW / 1000.
        "스크랩 처리 중량 = 스크랩 처리 길이 * 설계서 순 중량 / 1000(설계서 기본단위)
      ELSE.
*  설계서 중량 정보 없으면, 자재마스터 순중량 대입
        SELECT SINGLE MATNR, NTGEW, GEWEI, MTART, SPART
          FROM MARA
         WHERE MATNR = @PS_SC-MATNR
          INTO @LS_MARA.
        IF SY-SUBRC = 0.
          IF LS_MARA-MTART = 'MCHA' OR LS_MARA-MTART = 'MCHF'.  "순수상품은 M/중량단위 = 환산량
            IF LS_MARA-GEWEI = 'G'.
              GV_CONVQTY = PS_SC-MENGE * LS_MARA-NTGEW.        "NTGEW = M/G
            ELSEIF LS_MARA-GEWEI = 'KG'.
              GV_CONVQTY = PS_SC-MENGE * LS_MARA-NTGEW / 1000. "NTGEW = M/KG으로, NTGEW / 1000 = M/G은 총 스크랩 중량
            ENDIF.
          ELSEIF LS_MARA-MTART = 'MCFE' AND LS_MARA-SPART = '23'.
            GV_CONVQTY = PS_SC-MENGE * LS_MARA-NTGEW / 1000. "NTGEW = M/KG으로, CONVQTY = M * KG은 총 스크랩 중량
          ELSE.
            GV_CONVQTY = PS_SC-MENGE * LS_MARA-NTGEW.        "NTGEW = M/G
          ENDIF.
        ENDIF.
*        SELECT SINGLE MATNR, NTGEW, GEWEI
*          FROM MARA
*         WHERE MATNR = @PS_SC-MATNR
*          INTO @LS_WEIGHT.
*        IF SY-SUBRC = 0.
*          GV_CONVQTY = PS_SC-MENGE * LS_WEIGHT-NTGEW / 1000. "NTGEW = KM/KG으로, KM * KG은 총 스크랩 중량
*        ENDIF.
      ENDIF.
    ENDIF.

    IF GV_CONVQTY <= 0.
      GV_531_SKIP = 'X'.
    ENDIF.
***  2026.06.25 ksw ***


    LS_ITEM-MATERIAL  = LS_1140-SCMATNR.
    LS_ITEM-PLANT     = PS_SC-WERKS.

    IF PS_SC-WERKS EQ '6500'.
      LS_ITEM-STGE_LOC  = '2190'.
    ELSEIF PS_SC-WERKS EQ '6600'.
      IF PS_SC-SPGCD EQ 'GO'.
        LS_ITEM-STGE_LOC  = '2190'.
      ELSEIF PS_SC-SPGCD EQ 'GL'.
        LS_ITEM-STGE_LOC  = '2390'.
      ENDIF.
    ENDIF.

    LS_ITEM-MOVE_TYPE = '531'.
    LS_ITEM-STCK_TYPE = 'F'.

    LS_ITEM-ENTRY_QNT = GV_CONVQTY.
    LS_ITEM-ENTRY_UOM = 'KG'.
    LS_ITEM-ORDERID   = PS_SC-AUFNR.

    APPEND LS_ITEM TO LT_ITEM.

  ENDIF.

*** 2026.08.28 Start 추가 ZGISPP03
  IF GV_531_SKIP = 'X'.   "부산물 수량 0보다 작거나 같으므로 SKIP

  ELSE.
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = LS_HEADER
        GOODSMVT_CODE    = LS_GMCODE
      IMPORTING
        GOODSMVT_HEADRET = LS_HEADRET
        MATERIALDOCUMENT = LV_MATDOC
        MATDOCUMENTYEAR  = LV_DOCYER
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.

    IF LV_MATDOC IS NOT INITIAL.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      GV_MBLNR_I = LV_MATDOC. "전표번호

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      GV_MESSAGE_MI = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
    ENDIF.

  ENDIF.
*** 2026.08.28 End 추가 ZGISPP03

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_531_i_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_531_I_LOG  USING    PS_SC TYPE ZGTPPSIF0067
                                PS_RESULT TYPE ZGTPPSIF0068.

  IF GV_MBLNR_I IS INITIAL.
    IF PS_SC-SPGCD EQ 'GO'.  "가온광케이블 품목은 531 처리하지 않음
      PS_RESULT-ZERP_STAT = 'S'.
      PS_RESULT-ZERP_MESSAGE = TEXT-S09.
      PS_RESULT-MBLNR = GV_MBLNR_O.
      PS_RESULT-MJAHR = SY-DATUM+0(4).
    ELSE.
*** 2026.08.28 Start 추가 ZGISPP03
      IF GV_531_SKIP = 'X'.
        PS_RESULT-ZERP_STAT = 'S'.
        PS_RESULT-ZERP_MESSAGE = TEXT-S09.
        PS_RESULT-MBLNR = GV_MBLNR_O.
        PS_RESULT-MJAHR = SY-DATUM+0(4).
      ELSE.
        PS_RESULT-ZERP_STAT = 'E'.
        PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MI.
      ENDIF.
*** 2026.08.28 End 추가 ZGISPP03
    ENDIF.

    UPDATE ZGTPPT3450
       SET ZSTAT        = GS_SCRAP-ZRESULT
           ZMESSAGE     = GS_SCRAP-ZMESSAGE
           MBLNR_O      = PS_RESULT-MBLNR
           MJAHR        = PS_RESULT-MJAHR
           ZERP_STAT    = PS_RESULT-ZERP_STAT
           ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
     WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
       AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
       AND ZSERNO     EQ PS_SC-ZSERNO.

  ENDIF.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conversion_exit_alpha_input
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ITEM_AUFNR
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_ALPHA_INPUT  USING    PV_VALUE.

  CHECK PV_VALUE IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PV_VALUE
    IMPORTING
      OUTPUT = PV_VALUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTCOT4370
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> GV_CO_ORDER
*&      --> LS_1140_I_MATNR
*&      --> LV_LGORT
*&      --> GV_CONVQTY
*&      --> LV_AUFNR
*&---------------------------------------------------------------------*
FORM SAVE_ZGTCOT4370  USING    PS_QC TYPE ZGTPPSIF0061
                               P_CO_ORDER TYPE AUFNR    "CO오더
                               P_SC_MATNR TYPE MATNR    "스크랩입고자재
                               P_SC_LGORT TYPE LGORT_D  "스크랩입고저장위치
                               P_CONVQTY TYPE MENGE_D   "스크랩입고수량
                               P_SCQTY TYPE MENGE_D     "스크랩투입수량
                               P_AUFNR TYPE AUFNR       "합부판정대상배치의 오더
                               P_MODE.

  DATA: LS_CO4370_I LIKE ZGTCOT4370.

  IF P_MODE EQ 'C'.
    UPDATE ZGTCOT4370
       SET MBLNR_OC    = GV_MBLNR_O
           MBLNR_IC    = GV_MBLNR_I
           MBLNR_ZC    = GV_MBLNR_Z
           USNAM_C     = SY-UNAME
           DEL_MARK    = 'X'
           CHANGE_DATE = SY-DATUM
           AEDAT       = SY-DATUM
           AETIM       = SY-UZEIT
           AEDATLO     = SY-DATLO
           AETIMLO     = SY-TIMLO
           AENAM       = SY-UNAME
     WHERE CO_ORDER = P_CO_ORDER
       AND SEQ = '001'.

  ELSE.
    "손익센터
    SELECT SINGLE PRCTR
      FROM AUFK
     WHERE AUFNR EQ @P_AUFNR
      INTO @DATA(LV_PRCTR).

    "작업장, 코스트센터
    SELECT SINGLE C~ARBPL, D~KOSTL
      FROM AFKO AS A
      JOIN AFVC AS B ON B~AUFPL = A~AUFPL
                    AND B~APLFL = '000000'
      JOIN CRHD AS C ON C~OBJID = B~ARBID
                    AND C~OBJTY = 'A'
      JOIN CRCO AS D ON D~OBJTY = C~OBJTY
                    AND D~OBJID = C~OBJID
     WHERE A~AUFNR EQ @P_AUFNR
       AND D~LSTAR EQ 'AT102'
      INTO (@DATA(LV_ARBPL), @DATA(LV_KOSTL)).

    "DUMMY 스크랩코드
    SELECT SINGLE MATNR
      FROM ZGTPPT1140
     WHERE WERKS EQ @PS_QC-WERKS
       AND SPGCD EQ @PS_QC-SPGCD
       AND MATKL EQ 'DUMMY'
      INTO @DATA(LV_SP_MATNR).

    "공정그룹
    SELECT SINGLE MATKL
      FROM MARA
     WHERE MATNR EQ @PS_QC-MATNR
      INTO @DATA(LV_MATKL).

    CLEAR: LS_CO4370_I.
    LS_CO4370_I-KOKRS     = '6000'.
    LS_CO4370_I-CO_ORDER  = P_CO_ORDER.
    LS_CO4370_I-SEQ       = '001'.
    LS_CO4370_I-SPGCD     = PS_QC-SPGCD.
    LS_CO4370_I-KOSTL     = LV_KOSTL.
    LS_CO4370_I-SC_REASON = '4'.         "검사시료
    LS_CO4370_I-BUDAT     = PS_QC-BUDAT.
    LS_CO4370_I-MATNR     = PS_QC-MATNR.
    LS_CO4370_I-WERKS     = PS_QC-WERKS.
    LS_CO4370_I-PRCTR     = LV_PRCTR.
    LS_CO4370_I-SP_MATNR  = LV_SP_MATNR.
    LS_CO4370_I-OPGRP     = LV_MATKL.
    LS_CO4370_I-ARBPL     = LV_ARBPL.
    LS_CO4370_I-AUFNR     = P_AUFNR.
    LS_CO4370_I-LGORT     = PS_QC-LGORT.
    LS_CO4370_I-CHARG     = PS_QC-CHARG.
    LS_CO4370_I-QTY       = P_SCQTY.    "PS_QC-MENGE.
    LS_CO4370_I-MEINS     = PS_QC-MEINS.
    LS_CO4370_I-SC_MATNR  = P_SC_MATNR.
    LS_CO4370_I-SC_LGORT  = P_SC_LGORT.
    LS_CO4370_I-SC_QTY    = P_CONVQTY.
    LS_CO4370_I-SC_MEINS  = 'KG'.
    LS_CO4370_I-MBLNR_O   = GV_MBLNR_O.
    LS_CO4370_I-MBLNR_I   = GV_MBLNR_I.
    LS_CO4370_I-MBLNR_Z   = GV_MBLNR_Z.
    LS_CO4370_I-USNAM     = SY-UNAME.
    LS_CO4370_I-ERDAT     = SY-DATUM.
    LS_CO4370_I-ERTIM     = SY-UZEIT.
    LS_CO4370_I-ERDATLO   = SY-DATLO.
    LS_CO4370_I-ERTIMLO   = SY-TIMLO.
    LS_CO4370_I-ERNAM     = SY-UNAME.

    MODIFY ZGTCOT4370 FROM LS_CO4370_I.
  ENDIF.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_mblnr_z
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> P_
*&      --> LV_MATNR_M
*&      --> LS_1140_I_WERKS
*&      --> LV_LGORT
*&      --> P_0
*&      --> GV_CO_ORDER
*&      <-- GV_MBLNR_Z
*&      <-- GV_MESSAGE_MZ
*&---------------------------------------------------------------------*
FORM PROC_MBLNR_Z  USING  PS_QC TYPE ZGTPPSIF0061
                          P_BWART TYPE BWART
                          P_SCMATNR TYPE MATNR
                          P_SCWERKS TYPE WERKS_D
                          P_SCLGORT TYPE LGORT_D
                          P_CO_ORDER TYPE AUFNR
                 CHANGING P_MBLNR_Z
                          P_MESSAGE_MZ.

  DATA: LS_COBL    TYPE COBL,
        LS_HEADER  TYPE BAPI2017_GM_HEAD_01,
        LS_GMCODE  TYPE BAPI2017_GM_CODE,
        LS_HEADRET TYPE BAPI2017_GM_HEAD_RET,
        LV_MATDOC  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_DOCYER  TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_ITEM    TYPE BAPI2017_GM_ITEM_CREATE,
        LT_ITEM    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_EXT     TYPE STANDARD TABLE OF BAPIPAREX,
        LS_EXT     TYPE BAPIPAREX,
        LT_RETURN  TYPE TABLE OF BAPIRET2.

  "GM_CODE
  LS_GMCODE-GM_CODE = '02'. "오더입고전기

  "Header
  LS_HEADER-PSTNG_DATE      = PS_QC-BUDAT.
  LS_HEADER-DOC_DATE        = PS_QC-BUDAT.
  LS_HEADER-PR_UNAME        = SY-UNAME.
  LS_HEADER-VER_GR_GI_SLIP  = '2'.
  LS_HEADER-VER_GR_GI_SLIPX = 'X'.
  LS_HEADER-HEADER_TXT      = PS_QC-ZSERNO.

  "Item
  LS_ITEM-MATERIAL   = P_SCMATNR.
  LS_ITEM-PLANT      = P_SCWERKS.
  LS_ITEM-STGE_LOC   = P_SCLGORT.
  LS_ITEM-MVT_IND    = 'F'.
  LS_ITEM-MOVE_TYPE  = P_BWART.     "101
  LS_ITEM-ENTRY_QNT  = '0'.
  LS_ITEM-ORDERID    = P_CO_ORDER.
  LS_ITEM-NO_MORE_GR = 'X'.
  LS_ITEM-STCK_TYPE  = '3'.
  APPEND LS_ITEM TO LT_ITEM.

*  "추가필드
*  ls_cobl-aufnr = p_co_order.
*  ls_ext-structure = 'COBL'.
*  MOVE ls_cobl TO ls_ext-valuepart1.
*  APPEND ls_ext TO lt_ext.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LS_GMCODE
    IMPORTING
      GOODSMVT_HEADRET = LS_HEADRET
      MATERIALDOCUMENT = LV_MATDOC
      MATDOCUMENTYEAR  = LV_DOCYER
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
*     extensionin      = lt_ext
      RETURN           = LT_RETURN.

  IF LV_MATDOC IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    P_MBLNR_Z = LV_MATDOC. "전표번호

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_MESSAGE_MZ = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_mblnr_z_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_Z_LOG  USING   PS_QC TYPE ZGTPPSIF0061
                                 PS_RESULT TYPE ZGTPPSIF0062.

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LS_HEADRET1 TYPE BAPI2017_GM_HEAD_RET.
  DATA LV_SUBRC TYPE SYSUBRC.
  DATA LV_HEADTEXT TYPE BKTXT.

  IF GV_MBLNR_Z IS NOT INITIAL.
    UPDATE ZGTPPT3440
       SET MBLNR_Z = GV_MBLNR_Z
     WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
       AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
       AND ZSERNO     EQ PS_QC-ZSERNO.

    "0 입고 실패 시 입고 취소->투입 취소->CO오더 TECO->합부판정 자재문서 취소
  ELSE.
    "CO 오더 입고 자재문서 취소
    CLEAR: LS_HEADRET, LT_RETURN, LV_HEADTEXT.
    LV_HEADTEXT = PS_QC-ZSERNO.

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = GV_MBLNR_I
        MATDOCUMENTYEAR     = GV_MJAHR
        GOODSMVT_PSTNG_DATE = PS_QC-BUDAT
        GOODSMVT_PR_UNAME   = SY-UNAME
        DOCUMENTHEADER_TEXT = LV_HEADTEXT
      IMPORTING
        GOODSMVT_HEADRET    = LS_HEADRET
      TABLES
        RETURN              = LT_RETURN.

    IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      "CO 오더 투입 자재문서 취소
      CLEAR: LS_HEADRET1, LT_RETURN, LV_HEADTEXT.
      LV_HEADTEXT = PS_QC-ZSERNO.

      CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
        EXPORTING
          MATERIALDOCUMENT    = GV_MBLNR_O
          MATDOCUMENTYEAR     = GV_MJAHR
          GOODSMVT_PSTNG_DATE = PS_QC-BUDAT
          GOODSMVT_PR_UNAME   = SY-UNAME
          DOCUMENTHEADER_TEXT = LV_HEADTEXT
        IMPORTING
          GOODSMVT_HEADRET    = LS_HEADRET1
        TABLES
          RETURN              = LT_RETURN.

      IF LS_HEADRET1-MAT_DOC IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        "CO 오더 teco 처리
        PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0110'.
        PERFORM BDC_FIELD   USING : 'COAS-AUFNR' GV_CO_ORDER,
                                    'BDC_OKCODE'  '/00'.

        PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
        PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=PHS2'.

        PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
        PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=SICH'.

        PERFORM BDC_TRANSACTION USING    'KKF2'
                                CHANGING LV_SUBRC.

        IF LV_SUBRC EQ 0.
          "합부판정 자재문서 취소
          CLEAR: GS_HEADRET1, GT_RETURN1, LV_HEADTEXT.
          LV_HEADTEXT = PS_QC-ZSERNO.

          CALL FUNCTION 'ZGTPP_BAPI_GOODSMVT_CANCEL' STARTING NEW TASK 'MBLNR'
            PERFORMING GET_QC_MOVE_CANCEL ON END OF TASK
            EXPORTING
              MATERIALDOCUMENT    = GV_MBLNR
              MATDOCUMENTYEAR     = GV_MJAHR
              GOODSMVT_PSTNG_DATE = PS_QC-BUDAT
              GOODSMVT_PR_UNAME   = SY-UNAME
              DOCUMENTHEADER_TEXT = LV_HEADTEXT.

          WAIT UNTIL GV_JOBS = '1'.

          IF GS_HEADRET1-MAT_DOC IS NOT INITIAL.

            CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
            PS_RESULT-ZERP_STAT = 'E'.
            PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MZ.

            UPDATE ZGTPPT3440
               SET MBLNR        = ''
                   MJAHR        = ''
                   CO_ORDER     = ''
                   MBLNR_O      = ''
                   MBLNR_I      = ''
                   ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
                   ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
                   ZERP_STAT    = PS_RESULT-ZERP_STAT
                   ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
             WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
               AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
               AND ZSERNO     EQ PS_QC-ZSERNO.

          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

            PS_RESULT-ZERP_STAT = 'E'.
            PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MZ.

            UPDATE ZGTPPT3440
               SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
                   ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
                   ZERP_STAT    = PS_RESULT-ZERP_STAT
                   ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
             WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
               AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
               AND ZSERNO     EQ PS_QC-ZSERNO.

          ENDIF.

        ELSE.

          PS_RESULT-ZERP_STAT = 'E'.
          PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MZ.

          UPDATE ZGTPPT3440
             SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
                 ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
                 ZERP_STAT    = PS_RESULT-ZERP_STAT
                 ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
           WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
             AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
             AND ZSERNO     EQ PS_QC-ZSERNO.

        ENDIF.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        PS_RESULT-ZERP_STAT = 'E'.
        PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MZ.

        UPDATE ZGTPPT3440
           SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
               ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
               ZERP_STAT    = PS_RESULT-ZERP_STAT
               ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
         WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
           AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
           AND ZSERNO     EQ PS_QC-ZSERNO.

      ENDIF.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      PS_RESULT-ZERP_STAT = 'E'.
      PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MZ.

      UPDATE ZGTPPT3440
         SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
             ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
             ZERP_STAT    = PS_RESULT-ZERP_STAT
             ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
       WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
         AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
         AND ZSERNO     EQ PS_QC-ZSERNO.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_mblnr_z_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_MBLNR_Z_CANCEL .

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LV_HEADTEXT TYPE BKTXT.

  CHECK GS_MATDOC-MBLNR_Z IS NOT INITIAL.

  "취소 문서의 취소 처리 결과 체크
  SELECT SINGLE MANDT
    FROM MATDOC
   WHERE MBLNR EQ @GS_MATDOC-MBLNR_Z
     AND MJAHR EQ @GS_MATDOC-MJAHR
     AND CANCELLED EQ 'X'
    INTO @DATA(LV_MANDT).

  "취소 문서가 취소 전이면 진행
  CHECK SY-SUBRC NE 0.

  "MES 합부판정, CO 0입고 취소
  CLEAR: LS_HEADRET, LT_RETURN, LV_HEADTEXT.
  LV_HEADTEXT = TEXT-M04.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GS_MATDOC-MBLNR_Z
      MATDOCUMENTYEAR     = GS_MATDOC-MJAHR
      GOODSMVT_PSTNG_DATE = GS_MATDOC-BUDAT_Z
      GOODSMVT_PR_UNAME   = SY-UNAME
      DOCUMENTHEADER_TEXT = LV_HEADTEXT
    IMPORTING
      GOODSMVT_HEADRET    = LS_HEADRET
    TABLES
      RETURN              = LT_RETURN.

  IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
    "성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    DO 10 TIMES.
      SELECT SINGLE @ABAP_TRUE
        INTO @DATA(LV_CHECK)
        FROM MKPF
       WHERE MBLNR EQ @LS_HEADRET-MAT_DOC
         AND MJAHR EQ @LS_HEADRET-DOC_YEAR.

      IF SY-SUBRC IS INITIAL.
        GV_MBLNR_Z = LS_HEADRET-MAT_DOC.
        EXIT.
      ENDIF.

      WAIT UP TO '1' SECONDS.
    ENDDO.

  ELSE.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    GV_MESSAGE_MZ = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

    GV_CHECK = 'E'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_mblnr_z_log_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_Z_LOG_CANCEL  USING   PS_QC TYPE ZGTPPSIF0061
                                        PS_RESULT TYPE ZGTPPSIF0062.

  CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MZ.

  UPDATE ZGTPPT3440
     SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
         ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
     AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
     AND ZSERNO     EQ PS_QC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_zgtcot4370_sc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> GT_ADD_QTY[]
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM SAVE_ZGTCOT4370_SC USING    PS_SC TYPE ZGTPPSIF0067
                                 P_MODE.

  DATA: BEGIN OF LS_MBLNR_C,
          AUFNR LIKE MATDOC-AUFNR,
          SMBLN LIKE MATDOC-SMBLN,
          SMBLP LIKE MATDOC-SMBLP,
          MBLNR LIKE MATDOC-MBLNR,
        END OF LS_MBLNR_C.
  DATA: LT_MBLNR_OC LIKE TABLE OF LS_MBLNR_C,
        LT_MBLNR_IC LIKE TABLE OF LS_MBLNR_C.

  DATA: LT_CO4370_I LIKE TABLE OF ZGTCOT4370,
        LS_CO4370_I LIKE ZGTCOT4370.

  DATA: LV_CONVQTY  TYPE MENGE_D,
        LV_SC_LGORT TYPE LGORT_D.

  DATA: LV_SEQ LIKE ZGTCOT4370-SEQ.

  IF P_MODE EQ 'C' OR P_MODE EQ 'AC'.
    CLEAR: LT_MBLNR_OC.
    SELECT AUFNR, SMBLN, SMBLP, MBLNR
      FROM MATDOC
     WHERE SMBLN EQ @GS_3450_C-MBLNR_O
      INTO TABLE @LT_MBLNR_OC.

    CLEAR: LT_MBLNR_IC.
    SELECT AUFNR, SMBLN, SMBLP, MBLNR
      FROM MATDOC
     WHERE SMBLN EQ @GS_3450_C-MBLNR_I
      INTO TABLE @LT_MBLNR_IC.

    LOOP AT LT_MBLNR_OC INTO DATA(LS_OC).
      READ TABLE LT_MBLNR_IC INTO DATA(LS_IC) WITH KEY AUFNR = LS_OC-AUFNR.

      "SEQ MAX
      CLEAR: LV_SEQ.
      SELECT SINGLE SEQ
        FROM ZGTCOT4370
       WHERE CO_ORDER EQ @LS_OC-AUFNR
         AND MBLNR_O  EQ @LS_OC-SMBLN
        INTO @LV_SEQ.

      UPDATE ZGTCOT4370
         SET MBLNR_OC    = LS_OC-MBLNR
             MBLNR_IC    = LS_IC-MBLNR
             USNAM_C     = SY-UNAME
             DEL_MARK    = 'X'
             CHANGE_DATE = SY-DATUM
             AEDAT       = SY-DATUM
             AETIM       = SY-UZEIT
             AEDATLO     = SY-DATLO
             AETIMLO     = SY-TIMLO
             AENAM       = SY-UNAME
       WHERE CO_ORDER = LS_OC-AUFNR
         AND SEQ      = LV_SEQ.

      COMMIT WORK AND WAIT.
    ENDLOOP.

  ELSE.
    "대상 자재의 공정그룹(자재그룹) 추출
    SELECT SINGLE MATKL
      FROM MARA
     WHERE MATNR = @PS_SC-MATNR
      INTO @DATA(LV_MATKL).

    "반제품의 자재그룹(공정그룹) 기준의 스크랩 자재코드 추출
    SELECT SINGLE MATNR
      FROM ZGTPPT1140
     WHERE WERKS = @PS_SC-WERKS
       AND SPGCD = @PS_SC-SPGCD
       AND MATKL = @LV_MATKL
      INTO @DATA(LV_SC_MATNR).

    "DUMMY 스크랩코드
    SELECT SINGLE MATNR
      FROM ZGTPPT1140
     WHERE WERKS EQ @PS_SC-WERKS
       AND SPGCD EQ @PS_SC-SPGCD
       AND MATKL EQ 'DUMMY'
      INTO @DATA(LV_SP_MATNR).

    IF P_MODE EQ 'R' OR P_MODE EQ 'A'. "잔량, 재고실사
      CLEAR: LT_CO4370_I.
      LOOP AT GT_ADD_QTY INTO DATA(LS_ADD).
        "손익센터
        SELECT SINGLE PRCTR
          FROM AUFK
         WHERE AUFNR EQ @LS_ADD-AUFNR
          INTO @DATA(LV_PRCTR).

        "작업장, 코스트센터
        SELECT SINGLE C~ARBPL, D~KOSTL
          FROM AFKO AS A
          JOIN AFVC AS B ON B~AUFPL = A~AUFPL
                        AND B~APLFL = '000000'
          JOIN CRHD AS C ON C~OBJID = B~ARBID
                        AND C~OBJTY = 'A'
          JOIN CRCO AS D ON D~OBJTY = C~OBJTY
                        AND D~OBJID = C~OBJID
         WHERE A~AUFNR EQ @LS_ADD-AUFNR
           AND D~LSTAR EQ 'AT102'
          INTO (@DATA(LV_ARBPL), @DATA(LV_KOSTL)).

        "환산수량
        CLEAR: LV_CONVQTY.
        CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
          EXPORTING
            I_MATNR              = PS_SC-MATNR
            I_IN_ME              = PS_SC-MEINS
            I_OUT_ME             = 'KG'
            I_MENGE              = LS_ADD-ADD_QTY
          IMPORTING
            E_MENGE              = LV_CONVQTY
          EXCEPTIONS
            ERROR_IN_APPLICATION = 1
            ERROR                = 2
            OTHERS               = 3.

***  2026.06.25 ksw ***
        IF SY-SUBRC NE 0.
          SELECT SINGLE MATNR_N, NTGEW, GEWEI
            FROM ZEDT1050
           WHERE MATNR_N = @PS_SC-MATNR
            INTO @DATA(LS_WEIGHT).

          IF SY-SUBRC = 0.
            LV_CONVQTY = LS_ADD-ADD_QTY * LS_WEIGHT-NTGEW / 1000.
            "스크랩 처리 중량 = 스크랩 처리 길이 * 설계서 순 중량 / 1000(설계서 기본단위)
          ELSE.
*  설계서 중량 정보 없으면, 자재마스터 순중량 대입
            SELECT SINGLE MATNR, NTGEW, GEWEI, MTART, SPART
              FROM MARA
             WHERE MATNR = @PS_SC-MATNR
              INTO @DATA(LS_MARA).
            IF SY-SUBRC = 0.
              IF LS_MARA-MTART = 'MCHA' OR LS_MARA-MTART = 'MCHF'.  "순수상품은 M/중량단위 = 환산량
                IF LS_MARA-GEWEI = 'G'.
                  GV_CONVQTY = LS_ADD-ADD_QTY * LS_MARA-NTGEW.        "NTGEW = M/G
                ELSEIF LS_MARA-GEWEI = 'KG'.
                  GV_CONVQTY = LS_ADD-ADD_QTY * LS_MARA-NTGEW / 1000. "NTGEW = M/KG으로, NTGEW / 1000 = M/G은 총 스크랩 중량
                ENDIF.
              ELSEIF LS_MARA-MTART = 'MCFE' AND LS_MARA-SPART = '23'.
                GV_CONVQTY = LS_ADD-ADD_QTY * LS_MARA-NTGEW / 1000. "NTGEW = M/KG으로, CONVQTY = M * KG은 총 스크랩 중량
              ELSE.
                GV_CONVQTY = LS_ADD-ADD_QTY * LS_MARA-NTGEW.        "NTGEW = M/G
              ENDIF.
            ENDIF.

*            SELECT SINGLE MATNR, NTGEW, GEWEI
*              FROM MARA
*             WHERE MATNR = @PS_SC-MATNR
*              INTO @LS_WEIGHT.
*            IF SY-SUBRC = 0.
*              LV_CONVQTY = LS_ADD-ADD_QTY * LS_WEIGHT-NTGEW / 1000. "NTGEW = KM/KG으로, KM * KG은 총 스크랩 중량
*            ENDIF.
          ENDIF.
        ENDIF.
***  2026.06.25 ksw ***

        "저장위치
        CLEAR: LV_SC_LGORT.
        IF PS_SC-WERKS EQ '6500'.
          LV_SC_LGORT = '2190'.
        ELSEIF PS_SC-WERKS EQ '6600'.
          IF PS_SC-SPGCD EQ 'GO'.
            LV_SC_LGORT = '2190'.
          ELSEIF PS_SC-SPGCD EQ 'GL'.
            LV_SC_LGORT = '2390'.
          ENDIF.
        ENDIF.

        "SEQ MAX
        CLEAR: LV_SEQ.
        SELECT MAX( SEQ )
          FROM ZGTCOT4370
         WHERE CO_ORDER EQ @LS_ADD-AUFNR
          INTO @LV_SEQ.

        IF LV_SEQ IS INITIAL OR LV_SEQ = '000'.
          LV_SEQ = '001'.
        ELSE.
          LV_SEQ = LV_SEQ + 1.
        ENDIF.

        CLEAR: LS_CO4370_I.
        LS_CO4370_I-KOKRS     = '6000'.
        LS_CO4370_I-CO_ORDER  = LS_ADD-AUFNR.
        LS_CO4370_I-SEQ       = LV_SEQ.
        LS_CO4370_I-SPGCD     = PS_SC-SPGCD.
        LS_CO4370_I-KOSTL     = LV_KOSTL.
        LS_CO4370_I-SC_REASON = '2'.         "생산잔량
        LS_CO4370_I-BUDAT     = PS_SC-BUDAT.
        LS_CO4370_I-MATNR     = PS_SC-MATNR.
        LS_CO4370_I-WERKS     = PS_SC-WERKS.
        LS_CO4370_I-PRCTR     = LV_PRCTR.
        LS_CO4370_I-SP_MATNR  = LV_SP_MATNR.
        LS_CO4370_I-OPGRP     = LV_MATKL.
        LS_CO4370_I-ARBPL     = LV_ARBPL.
        LS_CO4370_I-AUFNR     = LS_ADD-AUFNR.
        LS_CO4370_I-LGORT     = PS_SC-LGORT.
        LS_CO4370_I-CHARG     = PS_SC-CHARG.
        LS_CO4370_I-QTY       = PS_SC-MENGE.
        LS_CO4370_I-MEINS     = PS_SC-MEINS.
        LS_CO4370_I-SC_MATNR  = LV_SC_MATNR.
        LS_CO4370_I-SC_LGORT  = LV_SC_LGORT.
        LS_CO4370_I-SC_QTY    = LV_CONVQTY.
        LS_CO4370_I-SC_MEINS  = 'KG'.
        LS_CO4370_I-MBLNR_O   = GV_MBLNR_O.
        LS_CO4370_I-MBLNR_I   = GV_MBLNR_I.
        LS_CO4370_I-USNAM     = SY-UNAME.
        LS_CO4370_I-ERDAT     = SY-DATUM.
        LS_CO4370_I-ERTIM     = SY-UZEIT.
        LS_CO4370_I-ERDATLO   = SY-DATLO.
        LS_CO4370_I-ERTIMLO   = SY-TIMLO.
        LS_CO4370_I-ERNAM     = SY-UNAME.

        APPEND LS_CO4370_I TO LT_CO4370_I.

      ENDLOOP.

      MODIFY ZGTCOT4370 FROM TABLE LT_CO4370_I.

    ELSEIF P_MODE EQ 'P'. "예압
      "손익센터
      CLEAR: LV_PRCTR.
      SELECT SINGLE PRCTR
        FROM AUFK
       WHERE AUFNR EQ @PS_SC-AUFNR
        INTO @LV_PRCTR.

      "작업장, 코스트센터
      CLEAR: LV_ARBPL, LV_KOSTL.
      SELECT SINGLE C~ARBPL, D~KOSTL
        FROM AFKO AS A
        JOIN AFVC AS B ON B~AUFPL = A~AUFPL
                      AND B~APLFL = '000000'
        JOIN CRHD AS C ON C~OBJID = B~ARBID
                      AND C~OBJTY = 'A'
        JOIN CRCO AS D ON D~OBJTY = C~OBJTY
                      AND D~OBJID = C~OBJID
       WHERE A~AUFNR EQ @PS_SC-AUFNR
         AND D~LSTAR EQ 'AT102'
        INTO (@LV_ARBPL, @LV_KOSTL).

      "환산수량
      CLEAR: LV_CONVQTY.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          I_MATNR              = PS_SC-MATNR
          I_IN_ME              = PS_SC-MEINS
          I_OUT_ME             = 'KG'
          I_MENGE              = PS_SC-MENGE
        IMPORTING
          E_MENGE              = LV_CONVQTY
        EXCEPTIONS
          ERROR_IN_APPLICATION = 1
          ERROR                = 2
          OTHERS               = 3.

***  2026.06.25 ksw ***
      IF SY-SUBRC NE 0.
        SELECT SINGLE MATNR_N, NTGEW, GEWEI
          FROM ZEDT1050
         WHERE MATNR_N = @PS_SC-MATNR
          INTO @LS_WEIGHT.

        IF SY-SUBRC = 0.
          LV_CONVQTY = PS_SC-MENGE * LS_WEIGHT-NTGEW / 1000.
          "스크랩 처리 중량 = 스크랩 처리 길이 * 설계서 순 중량 / 1000(설계서 기본단위)
        ELSE.
*  설계서 중량 정보 없으면, 자재마스터 순중량 대입
          SELECT SINGLE MATNR, NTGEW, GEWEI, MTART, SPART
            FROM MARA
           WHERE MATNR = @PS_SC-MATNR
            INTO @LS_MARA.
          IF SY-SUBRC = 0.
            IF LS_MARA-MTART = 'MCHA' OR LS_MARA-MTART = 'MCHF'.  "순수상품은 M/중량단위 = 환산량
              IF LS_MARA-GEWEI = 'G'.
                GV_CONVQTY = PS_SC-MENGE * LS_MARA-NTGEW.        "NTGEW = M/G
              ELSEIF LS_MARA-GEWEI = 'KG'.
                GV_CONVQTY = PS_SC-MENGE * LS_MARA-NTGEW / 1000. "NTGEW = M/KG으로, NTGEW / 1000 = M/G은 총 스크랩 중량
              ENDIF.
            ELSEIF LS_MARA-MTART = 'MCFE' AND LS_MARA-SPART = '23'.
              GV_CONVQTY = PS_SC-MENGE * LS_MARA-NTGEW / 1000. "NTGEW = M/KG으로, CONVQTY = M * KG은 총 스크랩 중량
            ELSE.
              GV_CONVQTY = PS_SC-MENGE * LS_MARA-NTGEW.        "NTGEW = M/G
            ENDIF.
          ENDIF.
**  설계서 중량 정보 없으면, 자재마스터 순중량 대입
*          SELECT SINGLE MATNR, NTGEW, GEWEI
*             FROM MARA
*           WHERE MATNR = @PS_SC-MATNR
*               INTO @LS_WEIGHT.
*          IF SY-SUBRC = 0.
*            LV_CONVQTY = PS_SC-MENGE * LS_WEIGHT-NTGEW / 1000. "NTGEW = KM/KG으로, KM * KG은 총 스크랩 중량
*          ENDIF.
        ENDIF.
      ENDIF.
***  2026.06.25 ksw ***

      "저장위치
      CLEAR: LV_SC_LGORT.
      IF PS_SC-WERKS EQ '6500'.
        LV_SC_LGORT = '2190'.
      ELSEIF PS_SC-WERKS EQ '6600'.
        IF PS_SC-SPGCD EQ 'GO'.
          LV_SC_LGORT = '2190'.
        ELSEIF PS_SC-SPGCD EQ 'GL'.
          LV_SC_LGORT = '2390'.
        ENDIF.
      ENDIF.

      "SEQ MAX
      CLEAR: LV_SEQ.
      SELECT MAX( SEQ )
        FROM ZGTCOT4370
       WHERE CO_ORDER EQ @PS_SC-AUFNR
        INTO @LV_SEQ.

      IF LV_SEQ IS INITIAL OR LV_SEQ = '000'.
        LV_SEQ = '001'.
      ELSE.
        LV_SEQ = LV_SEQ + 1.
      ENDIF.

      CLEAR: LS_CO4370_I.
      LS_CO4370_I-KOKRS     = '6000'.
      LS_CO4370_I-CO_ORDER  = PS_SC-AUFNR.
      LS_CO4370_I-SEQ       = LV_SEQ.
      LS_CO4370_I-SPGCD     = PS_SC-SPGCD.
      LS_CO4370_I-KOSTL     = LV_KOSTL.
      LS_CO4370_I-SC_REASON = '7'.         "외부요인
      LS_CO4370_I-BUDAT     = PS_SC-BUDAT.
      LS_CO4370_I-MATNR     = PS_SC-MATNR.
      LS_CO4370_I-WERKS     = PS_SC-WERKS.
      LS_CO4370_I-PRCTR     = LV_PRCTR.
      LS_CO4370_I-SP_MATNR  = LV_SP_MATNR.
      LS_CO4370_I-OPGRP     = LV_MATKL.
      LS_CO4370_I-ARBPL     = LV_ARBPL.
      LS_CO4370_I-AUFNR     = PS_SC-AUFNR.
      LS_CO4370_I-LGORT     = PS_SC-LGORT.
      LS_CO4370_I-CHARG     = PS_SC-CHARG.
      LS_CO4370_I-QTY       = PS_SC-MENGE.
      LS_CO4370_I-MEINS     = PS_SC-MEINS.
      LS_CO4370_I-SC_MATNR  = LV_SC_MATNR.
      LS_CO4370_I-SC_LGORT  = LV_SC_LGORT.
      LS_CO4370_I-SC_QTY    = LV_CONVQTY.
      LS_CO4370_I-SC_MEINS  = 'KG'.
      LS_CO4370_I-MBLNR_O   = GV_MBLNR_O.
      LS_CO4370_I-MBLNR_I   = GV_MBLNR_I.
      LS_CO4370_I-USNAM     = SY-UNAME.
      LS_CO4370_I-ERDAT     = SY-DATUM.
      LS_CO4370_I-ERTIM     = SY-UZEIT.
      LS_CO4370_I-ERDATLO   = SY-DATLO.
      LS_CO4370_I-ERTIMLO   = SY-TIMLO.
      LS_CO4370_I-ERNAM     = SY-UNAME.

      MODIFY ZGTCOT4370 FROM LS_CO4370_I.

    ENDIF.
  ENDIF.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESSING_SCRAP_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_MODE
*&      --> OT_RESULT[]
*&---------------------------------------------------------------------*
FORM PROCESSING_SCRAP_T  USING PV_MODE
                               PT_RESULT TYPE TY_T_SCRAP_RESULT.

  LOOP AT GS_SCRAP-SCRAP INTO DATA(LS_SC).
    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LS_SC-ZSERNO BINARY SEARCH.

    IF LS_SC-SPGCD EQ 'GO'.
*// 절단 스크랩 대상 자재의 중량 폐기(931)
      CLEAR: GV_MBLNR_O, GV_MESSAGE_MO, GV_MJAHR.
      PERFORM PROC_MBLNR_O_T USING LS_SC
                                   '931'
                                   ''
                          CHANGING GV_MBLNR_O
                                   GV_MESSAGE_MO.

      PERFORM UPDATE_MBLNR_O_LOG_T_937 USING LS_SC LR_RESULT->*.

      CHECK GV_MBLNR_O IS NOT INITIAL.

      PERFORM UPDATE_SCRAP_LOG_T USING LS_SC LR_RESULT->*.

    ELSE.
*// 절단 스크랩 처리할 CO 생산오더 생성
      "사업영역 추출
      SELECT SINGLE GSBER
        FROM T134G
       WHERE WERKS = @LS_SC-WERKS
        INTO @DATA(LV_GSBER).

      "dummy 스크랩 자재코드 추출
      SELECT SINGLE WERKS, MATNR
        FROM ZGTPPT1140
       WHERE WERKS = @LS_SC-WERKS
         AND SPGCD = @LS_SC-SPGCD
         AND MATKL = 'DUMMY'
        INTO (@DATA(LV_SC_WERKS), @DATA(LV_SC_MATNR)).

      CLEAR: GV_CO_ORDER, GV_MESSAGE_CO.
      PERFORM PROC_KKF1 USING LV_SC_MATNR     "스크랩자재코드
                              LV_SC_WERKS     "플랜트
                              LV_GSBER        "사업영역
                     CHANGING GV_CO_ORDER     "CO생산오더
                              GV_MESSAGE_CO.  "메시지

      PERFORM UPDATE_KKF1_LOG_T USING LS_SC LR_RESULT->*.

      CHECK GV_CO_ORDER IS NOT INITIAL.

*// 절단 스크랩 대상 자재의 중량 CO 생산오더 투입(951)
      "CO 오더에 투입
      CLEAR: GV_MBLNR_O, GV_MESSAGE_MO, GV_MJAHR.
      PERFORM PROC_MBLNR_O_T USING LS_SC
                                   '951'
                                   GV_CO_ORDER
                          CHANGING GV_MBLNR_O
                                   GV_MESSAGE_MO.

      PERFORM UPDATE_MBLNR_O_LOG_T USING LS_SC LR_RESULT->*.

      CHECK GV_MBLNR_O IS NOT INITIAL.

*// 스크랩 대상 자재의 수량 CO 생산오더 입고(971)
      "해당 자재의 스크랩 환산 단위 CONVERSION
      CLEAR: GV_CONVQTY.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          I_MATNR              = LS_SC-MATNR
          I_IN_ME              = LS_SC-MEINS
          I_OUT_ME             = 'KG'
          I_MENGE              = LS_SC-MENGE
        IMPORTING
          E_MENGE              = GV_CONVQTY
        EXCEPTIONS
          ERROR_IN_APPLICATION = 1
          ERROR                = 2
          OTHERS               = 3.

***  2026.06.25 ksw ***
      IF SY-SUBRC NE 0.
        SELECT SINGLE MATNR_N, NTGEW, GEWEI
          FROM ZEDT1050
         WHERE MATNR_N = @LS_SC-MATNR
          INTO @DATA(LS_WEIGHT).

        IF SY-SUBRC = 0.
          GV_CONVQTY = LS_SC-MENGE * LS_WEIGHT-NTGEW / 1000.
          "스크랩 처리 중량 = 스크랩 처리 길이 * 설계서 순 중량 / 1000(설계서 기본단위)
        ELSE.
*  설계서 중량 정보 없으면, 자재마스터 순중량 대입
          SELECT SINGLE MATNR, NTGEW, GEWEI, MTART, SPART
            FROM MARA
           WHERE MATNR = @LS_SC-MATNR
            INTO @DATA(LS_MARA).
          IF SY-SUBRC = 0.
            IF LS_MARA-MTART = 'MCHA' OR LS_MARA-MTART = 'MCHF'.  "순수상품은 M/중량단위 = 환산량
              IF LS_MARA-GEWEI = 'G'.
                GV_CONVQTY = LS_SC-MENGE * LS_MARA-NTGEW.        "NTGEW = M/G
              ELSEIF LS_MARA-GEWEI = 'KG'.
                GV_CONVQTY = LS_SC-MENGE * LS_MARA-NTGEW / 1000. "NTGEW = M/KG으로, NTGEW / 1000 = M/G은 총 스크랩 중량
              ENDIF.
            ELSEIF LS_MARA-MTART = 'MCFE' AND LS_MARA-SPART = '23'.
              GV_CONVQTY = LS_SC-MENGE * LS_MARA-NTGEW / 1000. "NTGEW = M/KG으로, CONVQTY = M * KG은 총 스크랩 중량
            ELSE.
              GV_CONVQTY = LS_SC-MENGE * LS_MARA-NTGEW.        "NTGEW = kM/kG 이라 환산율 무시해도됨
            ENDIF.
          ENDIF.
**  설계서 중량 정보 없으면, 자재마스터 순중량 대입
*          SELECT SINGLE MATNR, NTGEW, GEWEI
*            FROM MARA
*           WHERE MATNR = @LS_SC-MATNR
*            INTO @LS_WEIGHT.
*          IF SY-SUBRC = 0.
*            GV_CONVQTY = LS_SC-MENGE * LS_WEIGHT-NTGEW / 1000. "NTGEW = KM/KG으로, M * KG은 총 스크랩 중량
*          ENDIF.
        ENDIF.
      ENDIF.
***  2026.06.25 ksw ***

      "대상 자재의 공정그룹(자재그룹) 추출
      SELECT SINGLE MATKL
        FROM MARA
       WHERE MATNR = @LS_SC-MATNR
        INTO @DATA(LV_MATKL).

      "반제품의 자재그룹(공정그룹) 기준의 생산스크랩 자재코드 추출
      SELECT SINGLE WERKS, MATNR
        FROM ZGTPPT1140
       WHERE WERKS = @LS_SC-WERKS
         AND SPGCD = @LS_SC-SPGCD
         AND MATKL = @LV_MATKL
        INTO (@DATA(LV_SC_WERKS_I), @DATA(LV_SC_MATNR_I)).

      SELECT SINGLE LGORT
        FROM ZGTPPT1120
       WHERE WERKS = @LS_SC-WERKS
         AND SPGCD = @LS_SC-SPGCD
        INTO @DATA(LV_SC_LGORT_I).

      "CO 오더에 입고
      CLEAR: GV_MBLNR_I, GV_MESSAGE_MI.
      PERFORM PROC_MBLNR_I_T USING LS_SC
                                   '971'
                                   LV_SC_MATNR_I  "스크랩 입고 자재
                                   LV_SC_WERKS_I  "스크랩 입고 플랜트
                                   LV_SC_LGORT_I  "스크랩 입고 저장위치
                                   GV_CONVQTY
                                   GV_CO_ORDER
                          CHANGING GV_MBLNR_I
                                   GV_MESSAGE_MI.

      PERFORM UPDATE_MBLNR_I_LOG_T USING LS_SC LR_RESULT->*.

      CHECK GV_MBLNR_I IS NOT INITIAL.

*// CO오더에 0 입고(DLV)
      "0입고 저장위치 추출
      SELECT SINGLE LGORT
        FROM ZGTPPT1120
       WHERE WERKS EQ @LS_SC-WERKS
         AND SPGCD EQ @LS_SC-SPGCD
        INTO @DATA(LV_LGORT_Z).

      "매출원가 대체용 SCRAP 0 입고 처리
      CLEAR: GV_MBLNR_Z, GV_MESSAGE_MZ.
      PERFORM PROC_MBLNR_Z_T USING LS_SC
                                   '101'
                                   LV_SC_MATNR "dummy 스크랩 자재
                                   LV_SC_WERKS "dummy 스크랩 플랜트
                                   LV_LGORT_Z
                                   GV_CO_ORDER
                          CHANGING GV_MBLNR_Z
                                   GV_MESSAGE_MZ.

      PERFORM UPDATE_MBLNR_Z_LOG_T USING LS_SC LR_RESULT->*.

      CHECK GV_MBLNR_Z IS NOT INITIAL.

      PERFORM UPDATE_SCRAP_LOG_T USING LS_SC LR_RESULT->*.

*// 951, 971, 0입고 모두 처리 성공 시
*// 공정 외 스크랩 처리 내역 INSERT(ZGTCOT4370)
      CHECK GV_MBLNR_O IS NOT INITIAL.
      CHECK GV_MBLNR_I IS NOT INITIAL.
      CHECK GV_MBLNR_Z IS NOT INITIAL.

      PERFORM SAVE_ZGTCOT4370_T USING LS_SC
                                      GV_CO_ORDER     "CO오더
                                      LV_SC_MATNR_I   "스크랩입고자재
                                      LV_SC_LGORT_I   "스크랩입고저장위치
                                      GV_CONVQTY      "스크랩입고수량
                                      PV_MODE.

    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_KKF1_LOG_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_KKF1_LOG_T  USING   PS_SC TYPE ZGTPPSIF0067
                                PS_RESULT TYPE ZGTPPSIF0068.

  IF GV_CO_ORDER IS NOT INITIAL.
    UPDATE ZGTPPT3450
       SET CO_ORDER = GV_CO_ORDER
     WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
       AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
       AND ZSERNO     EQ PS_SC-ZSERNO.

  ELSE.
    PS_RESULT-ZERP_STAT = 'E'.
    PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_CO.

    UPDATE ZGTPPT3450
       SET ZSTAT        = GS_SCRAP-ZRESULT
           ZMESSAGE     = GS_SCRAP-ZMESSAGE
           ZERP_STAT    = PS_RESULT-ZERP_STAT
           ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
     WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
       AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
       AND ZSERNO     EQ PS_SC-ZSERNO.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MBLNR_O_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> P_
*&      --> GV_CO_ORDER
*&      <-- GV_MBLNR_O
*&      <-- GV_MESSAGE_MO
*&---------------------------------------------------------------------*
FORM PROC_MBLNR_O_T  USING    PS_SC TYPE ZGTPPSIF0067
                              P_BWART TYPE BWART
                              P_CO_ORDER TYPE AUFNR
                     CHANGING P_MBLNR_O
                              P_MESSAGE_MO.

  DATA: LS_COBL    TYPE COBL,
        LS_HEADER  TYPE BAPI2017_GM_HEAD_01,
        LS_GMCODE  TYPE BAPI2017_GM_CODE,
        LS_HEADRET TYPE BAPI2017_GM_HEAD_RET,
        LV_MATDOC  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_DOCYER  TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_ITEM    TYPE BAPI2017_GM_ITEM_CREATE,
        LT_ITEM    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_EXT     TYPE STANDARD TABLE OF BAPIPAREX,
        LS_EXT     TYPE BAPIPAREX,
        LT_RETURN  TYPE TABLE OF BAPIRET2.

  "GM_CODE
  LS_GMCODE-GM_CODE = '03'. "출고전기

  "Header
  LS_HEADER-PSTNG_DATE = PS_SC-BUDAT.
  LS_HEADER-DOC_DATE   = PS_SC-BUDAT.
  LS_HEADER-PR_UNAME   = SY-UNAME.
  LS_HEADER-HEADER_TXT = PS_SC-ZSERNO.
  LS_HEADER-VER_GR_GI_SLIP  = '2'.
  LS_HEADER-VER_GR_GI_SLIPX = 'X'.

  "Item
  LS_ITEM-MATERIAL  = PS_SC-MATNR.
  LS_ITEM-PLANT     = PS_SC-WERKS.
  LS_ITEM-STGE_LOC  = PS_SC-LGORT.
  LS_ITEM-BATCH     = PS_SC-CHARG.
  LS_ITEM-ENTRY_QNT = PS_SC-MENGE.
  LS_ITEM-MOVE_TYPE = P_BWART.      "GP->951 / GO->931

  LS_ITEM-ORDERID   = P_CO_ORDER.

  IF GS_MCHB-VBELN IS NOT INITIAL.
    LS_ITEM-SPEC_STOCK = GS_MCHB-SOBKZ.
    LS_ITEM-SALES_ORD  = GS_MCHB-VBELN.
    LS_ITEM-S_ORD_ITEM = GS_MCHB-POSNR.
    LS_ITEM-MOVE_BATCH = PS_SC-CHARG.
    LS_ITEM-VAL_SALES_ORD  = GS_MCHB-VBELN.
    LS_ITEM-VAL_S_ORD_ITEM = GS_MCHB-POSNR.
  ENDIF.

  APPEND LS_ITEM TO LT_ITEM.

*  "추가필드
*  ls_cobl-aufnr = p_co_order.
*  ls_ext-structure = 'COBL'.
*  MOVE ls_cobl TO ls_ext-valuepart1.
*  APPEND ls_ext TO lt_ext.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LS_GMCODE
    IMPORTING
      GOODSMVT_HEADRET = LS_HEADRET
      MATERIALDOCUMENT = LV_MATDOC
      MATDOCUMENTYEAR  = LV_DOCYER
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
*     extensionin      = lt_ext
      RETURN           = LT_RETURN.

  IF LV_MATDOC IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    P_MBLNR_O = LV_MATDOC. "전표번호
    GV_MJAHR  = LV_DOCYER.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_MESSAGE_MO = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_MBLNR_O_LOG_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_O_LOG_T  USING   PS_SC TYPE ZGTPPSIF0067
                                   PS_RESULT TYPE ZGTPPSIF0068.

  DATA LV_SUBRC TYPE SYSUBRC.
  DATA LV_HEADTEXT TYPE BKTXT.

  IF GV_MBLNR_O IS NOT INITIAL.
    UPDATE ZGTPPT3450
       SET MBLNR_O = GV_MBLNR_O
           MJAHR   = GV_MJAHR
     WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
       AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
       AND ZSERNO     EQ PS_SC-ZSERNO.

    "투입 실패 시 CO오더 TECO
  ELSE.
    "CO 오더 teco 처리
    CLEAR: GT_BDCDATA, GT_BDCDATA[].
    PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0110'.
    PERFORM BDC_FIELD   USING : 'COAS-AUFNR' GV_CO_ORDER,
                                'BDC_OKCODE'  '/00'.

    PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
    PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=PHS2'.

    PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
    PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=SICH'.

    PERFORM BDC_TRANSACTION USING    'KKF2'
                            CHANGING LV_SUBRC.

    CLEAR: GT_MESSTAB.
    READ TABLE GT_MESSTAB WITH KEY MSGID = 'KO'
                                   MSGNR = '109'
                                   MSGTYP = 'S'.

    IF SY-SUBRC EQ 0.
      CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
      PS_RESULT-ZERP_STAT = 'E'.
      PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MO.

      UPDATE ZGTPPT3450
         SET CO_ORDER     = ''
             ZSTAT        = GS_SCRAP-ZRESULT
             ZMESSAGE     = GS_SCRAP-ZMESSAGE
             ZERP_STAT    = PS_RESULT-ZERP_STAT
             ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
       WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
         AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
         AND ZSERNO     EQ PS_SC-ZSERNO.

    ELSE.
      PS_RESULT-ZERP_STAT = 'E'.
      PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MO.

      UPDATE ZGTPPT3450
         SET ZSTAT        = GS_SCRAP-ZRESULT
             ZMESSAGE     = GS_SCRAP-ZMESSAGE
             ZERP_STAT    = PS_RESULT-ZERP_STAT
             ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
       WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
         AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
         AND ZSERNO     EQ PS_SC-ZSERNO.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MBLNR_I_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> P_
*&      --> LV_SC_MATNR_I
*&      --> LV_SC_WERKS_I
*&      --> LV_SC_LGORT_I
*&      --> GV_CONVQTY
*&      --> GV_CO_ORDER
*&      <-- GV_MBLNR_I
*&      <-- GV_MESSAGE_MI
*&---------------------------------------------------------------------*
FORM PROC_MBLNR_I_T  USING    PS_SC TYPE ZGTPPSIF0067
                              P_BWART TYPE BWART
                              P_SCMATNR TYPE MATNR
                              P_SCWERKS TYPE WERKS_D
                              P_SCLGORT TYPE LGORT_D
                              P_CONVQTY TYPE MENGE_D
                              P_CO_ORDER TYPE AUFNR
                     CHANGING P_MBLNR_I
                              P_MESSAGE_MI.

  DATA: LS_COBL    TYPE COBL,
        LS_HEADER  TYPE BAPI2017_GM_HEAD_01,
        LS_GMCODE  TYPE BAPI2017_GM_CODE,
        LS_HEADRET TYPE BAPI2017_GM_HEAD_RET,
        LV_MATDOC  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_DOCYER  TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_ITEM    TYPE BAPI2017_GM_ITEM_CREATE,
        LT_ITEM    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_EXT     TYPE STANDARD TABLE OF BAPIPAREX,
        LS_EXT     TYPE BAPIPAREX,
        LT_RETURN  TYPE TABLE OF BAPIRET2.

  "GM_CODE
  LS_GMCODE-GM_CODE = '05'. "입고전기

  "Header
  LS_HEADER-PSTNG_DATE      = PS_SC-BUDAT.
  LS_HEADER-DOC_DATE        = PS_SC-BUDAT.
  LS_HEADER-PR_UNAME        = SY-UNAME.
  LS_HEADER-VER_GR_GI_SLIP  = '2'.
  LS_HEADER-VER_GR_GI_SLIPX = 'X'.
  LS_HEADER-HEADER_TXT      = PS_SC-ZSERNO.

  "Item
  LS_ITEM-MATERIAL  = P_SCMATNR.
  LS_ITEM-PLANT     = P_SCWERKS.
  LS_ITEM-STGE_LOC  = P_SCLGORT.
  LS_ITEM-ENTRY_QNT = P_CONVQTY.
  LS_ITEM-MOVE_TYPE = P_BWART.     "971

  LS_ITEM-ORDERID   = P_CO_ORDER.
*  ls_item-no_more_gr = 'X'.
  APPEND LS_ITEM TO LT_ITEM.

*  "추가필드
*  ls_cobl-aufnr = p_co_order.
*  ls_ext-structure = 'COBL'.
*  MOVE ls_cobl TO ls_ext-valuepart1.
*  APPEND ls_ext TO lt_ext.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LS_GMCODE
    IMPORTING
      GOODSMVT_HEADRET = LS_HEADRET
      MATERIALDOCUMENT = LV_MATDOC
      MATDOCUMENTYEAR  = LV_DOCYER
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
*     extensionin      = lt_ext
      RETURN           = LT_RETURN.

  IF LV_MATDOC IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    P_MBLNR_I = LV_MATDOC. "전표번호

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_MESSAGE_MI = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_MBLNR_I_LOG_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_I_LOG_T  USING    PS_SC TYPE ZGTPPSIF0067
                                    PS_RESULT TYPE ZGTPPSIF0068.

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LV_SUBRC TYPE SYSUBRC.
  DATA LV_HEADTEXT TYPE BKTXT.

  IF GV_MBLNR_I IS NOT INITIAL.
    UPDATE ZGTPPT3450
       SET MBLNR_I = GV_MBLNR_I
     WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
       AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
       AND ZSERNO     EQ PS_SC-ZSERNO.

    "입고 실패 시 투입 취소->CO오더 TECO
  ELSE.
    "CO 오더 투입 자재문서 취소
    CLEAR: LS_HEADRET, LT_RETURN, LV_HEADTEXT.
    LV_HEADTEXT = PS_SC-ZSERNO.

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = GV_MBLNR_O
        MATDOCUMENTYEAR     = GV_MJAHR
        GOODSMVT_PSTNG_DATE = PS_SC-BUDAT
        GOODSMVT_PR_UNAME   = SY-UNAME
        DOCUMENTHEADER_TEXT = LV_HEADTEXT
      IMPORTING
        GOODSMVT_HEADRET    = LS_HEADRET
      TABLES
        RETURN              = LT_RETURN.

    IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      "CO 오더 teco 처리
      PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0110'.
      PERFORM BDC_FIELD   USING : 'COAS-AUFNR' GV_CO_ORDER,
                                  'BDC_OKCODE'  '/00'.

      PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
      PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=PHS2'.

      PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
      PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=SICH'.

      PERFORM BDC_TRANSACTION USING    'KKF2'
                              CHANGING LV_SUBRC.

      CLEAR: GT_MESSTAB.
      READ TABLE GT_MESSTAB WITH KEY MSGID = 'KO'
                                     MSGNR = '109'
                                     MSGTYP = 'S'.

      IF LV_SUBRC EQ 0.
        CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
        PS_RESULT-ZERP_STAT = 'E'.
        PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MI.

        UPDATE ZGTPPT3450
           SET MBLNR_O      = ''
               MJAHR        = ''
               CO_ORDER     = ''
               ZSTAT        = GS_SCRAP-ZRESULT
               ZMESSAGE     = GS_SCRAP-ZMESSAGE
               ZERP_STAT    = PS_RESULT-ZERP_STAT
               ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
         WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
           AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
           AND ZSERNO     EQ PS_SC-ZSERNO.

      ELSE.

        PS_RESULT-ZERP_STAT = 'E'.
        PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MI.

        UPDATE ZGTPPT3450
           SET ZSTAT        = GS_SCRAP-ZRESULT
               ZMESSAGE     = GS_SCRAP-ZMESSAGE
               ZERP_STAT    = PS_RESULT-ZERP_STAT
               ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
         WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
           AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
           AND ZSERNO     EQ PS_SC-ZSERNO.

      ENDIF.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      PS_RESULT-ZERP_STAT = 'E'.
      PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MI.

      UPDATE ZGTPPT3450
         SET ZSTAT        = GS_SCRAP-ZRESULT
             ZMESSAGE     = GS_SCRAP-ZMESSAGE
             ZERP_STAT    = PS_RESULT-ZERP_STAT
             ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
       WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
         AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
         AND ZSERNO     EQ PS_SC-ZSERNO.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MBLNR_Z_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> P_
*&      --> LV_SC_MATNR
*&      --> LV_SC_WERKS
*&      --> LV_LGORT_Z
*&      --> GV_CO_ORDER
*&      <-- GV_MBLNR_Z
*&      <-- GV_MESSAGE_MZ
*&---------------------------------------------------------------------*
FORM PROC_MBLNR_Z_T  USING    PS_SC TYPE ZGTPPSIF0067
                              P_BWART TYPE BWART
                              P_SCMATNR TYPE MATNR
                              P_SCWERKS TYPE WERKS_D
                              P_SCLGORT TYPE LGORT_D
                              P_CO_ORDER TYPE AUFNR
                     CHANGING P_MBLNR_Z
                              P_MESSAGE_MZ.

  DATA: LS_COBL    TYPE COBL,
        LS_HEADER  TYPE BAPI2017_GM_HEAD_01,
        LS_GMCODE  TYPE BAPI2017_GM_CODE,
        LS_HEADRET TYPE BAPI2017_GM_HEAD_RET,
        LV_MATDOC  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_DOCYER  TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_ITEM    TYPE BAPI2017_GM_ITEM_CREATE,
        LT_ITEM    TYPE STANDARD TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_EXT     TYPE STANDARD TABLE OF BAPIPAREX,
        LS_EXT     TYPE BAPIPAREX,
        LT_RETURN  TYPE TABLE OF BAPIRET2.

  "GM_CODE
  LS_GMCODE-GM_CODE = '02'. "오더입고전기

  "Header
  LS_HEADER-PSTNG_DATE      = PS_SC-BUDAT.
  LS_HEADER-DOC_DATE        = PS_SC-BUDAT.
  LS_HEADER-PR_UNAME        = SY-UNAME.
  LS_HEADER-VER_GR_GI_SLIP  = '2'.
  LS_HEADER-VER_GR_GI_SLIPX = 'X'.
  LS_HEADER-HEADER_TXT      = PS_SC-ZSERNO.

  "Item
  LS_ITEM-MATERIAL   = P_SCMATNR.
  LS_ITEM-PLANT      = P_SCWERKS.
  LS_ITEM-STGE_LOC   = P_SCLGORT.
  LS_ITEM-MVT_IND    = 'F'.
  LS_ITEM-MOVE_TYPE  = P_BWART.     "101
  LS_ITEM-ENTRY_QNT  = '0'.
  LS_ITEM-ORDERID    = P_CO_ORDER.
  LS_ITEM-NO_MORE_GR = 'X'.
  LS_ITEM-STCK_TYPE  = '3'.
  APPEND LS_ITEM TO LT_ITEM.

*  "추가필드
*  ls_cobl-aufnr = p_co_order.
*  ls_ext-structure = 'COBL'.
*  MOVE ls_cobl TO ls_ext-valuepart1.
*  APPEND ls_ext TO lt_ext.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LS_GMCODE
    IMPORTING
      GOODSMVT_HEADRET = LS_HEADRET
      MATERIALDOCUMENT = LV_MATDOC
      MATDOCUMENTYEAR  = LV_DOCYER
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
*     extensionin      = lt_ext
      RETURN           = LT_RETURN.

  IF LV_MATDOC IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = ABAP_TRUE.

    P_MBLNR_Z = LV_MATDOC. "전표번호

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    P_MESSAGE_MZ = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_MBLNR_Z_LOG_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_Z_LOG_T  USING    PS_SC TYPE ZGTPPSIF0067
                                    PS_RESULT TYPE ZGTPPSIF0068.

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LS_HEADRET1 TYPE BAPI2017_GM_HEAD_RET.
  DATA LV_SUBRC TYPE SYSUBRC.
  DATA LV_HEADTEXT TYPE BKTXT.

  IF GV_MBLNR_Z IS NOT INITIAL.
    UPDATE ZGTPPT3450
       SET MBLNR_Z = GV_MBLNR_Z
     WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
       AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
       AND ZSERNO     EQ PS_SC-ZSERNO.

    "0 입고 실패 시 입고 취소->투입 취소->CO오더 TECO
  ELSE.
    "CO 오더 입고 자재문서 취소
    CLEAR: LS_HEADRET, LT_RETURN, LV_HEADTEXT.
    LV_HEADTEXT = PS_SC-ZSERNO.

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = GV_MBLNR_I
        MATDOCUMENTYEAR     = GV_MJAHR
        GOODSMVT_PSTNG_DATE = PS_SC-BUDAT
        GOODSMVT_PR_UNAME   = SY-UNAME
        DOCUMENTHEADER_TEXT = LV_HEADTEXT
      IMPORTING
        GOODSMVT_HEADRET    = LS_HEADRET
      TABLES
        RETURN              = LT_RETURN.

    IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

      "CO 오더 투입 자재문서 취소
      CLEAR: LS_HEADRET1, LT_RETURN, LV_HEADTEXT.
      LV_HEADTEXT = PS_SC-ZSERNO.

      CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
        EXPORTING
          MATERIALDOCUMENT    = GV_MBLNR_O
          MATDOCUMENTYEAR     = GV_MJAHR
          GOODSMVT_PSTNG_DATE = PS_SC-BUDAT
          GOODSMVT_PR_UNAME   = SY-UNAME
          DOCUMENTHEADER_TEXT = LV_HEADTEXT
        IMPORTING
          GOODSMVT_HEADRET    = LS_HEADRET1
        TABLES
          RETURN              = LT_RETURN.

      IF LS_HEADRET1-MAT_DOC IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        "CO 오더 teco 처리
        PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0110'.
        PERFORM BDC_FIELD   USING : 'COAS-AUFNR' GV_CO_ORDER,
                                    'BDC_OKCODE'  '/00'.

        PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
        PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=PHS2'.

        PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
        PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=SICH'.

        PERFORM BDC_TRANSACTION USING    'KKF2'
                                CHANGING LV_SUBRC.

        IF LV_SUBRC EQ 0.
          CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
          PS_RESULT-ZERP_STAT = 'E'.
          PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MZ.

          UPDATE ZGTPPT3450
             SET CO_ORDER     = ''
                 MBLNR_O      = ''
                 MBLNR_I      = ''
                 MJAHR        = ''
                 ZSTAT        = GS_SCRAP-ZRESULT
                 ZMESSAGE     = GS_SCRAP-ZMESSAGE
                 ZERP_STAT    = PS_RESULT-ZERP_STAT
                 ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
           WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
             AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
             AND ZSERNO     EQ PS_SC-ZSERNO.

        ELSE.

          PS_RESULT-ZERP_STAT = 'E'.
          PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MZ.

          UPDATE ZGTPPT3450
             SET ZSTAT        = GS_SCRAP-ZRESULT
                 ZMESSAGE     = GS_SCRAP-ZMESSAGE
                 ZERP_STAT    = PS_RESULT-ZERP_STAT
                 ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
           WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
             AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
             AND ZSERNO     EQ PS_SC-ZSERNO.

        ENDIF.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        PS_RESULT-ZERP_STAT = 'E'.
        PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MZ.

        UPDATE ZGTPPT3450
           SET ZSTAT        = GS_SCRAP-ZRESULT
               ZMESSAGE     = GS_SCRAP-ZMESSAGE
               ZERP_STAT    = PS_RESULT-ZERP_STAT
               ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
         WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
           AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
           AND ZSERNO     EQ PS_SC-ZSERNO.

      ENDIF.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      PS_RESULT-ZERP_STAT = 'E'.
      PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MZ.

      UPDATE ZGTPPT3450
         SET ZSTAT        = GS_SCRAP-ZRESULT
             ZMESSAGE     = GS_SCRAP-ZMESSAGE
             ZERP_STAT    = PS_RESULT-ZERP_STAT
             ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
       WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
         AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
         AND ZSERNO     EQ PS_SC-ZSERNO.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTCOT4370_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> GV_CO_ORDER
*&      --> LV_SC_MATNR_I
*&      --> LV_SC_LGORT_I
*&      --> GV_CONVQTY
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM SAVE_ZGTCOT4370_T  USING    PS_SC TYPE ZGTPPSIF0067
                                 P_CO_ORDER TYPE AUFNR    "CO오더
                                 P_SC_MATNR TYPE MATNR    "스크랩입고자재
                                 P_SC_LGORT TYPE LGORT_D  "스크랩입고저장위치
                                 P_CONVQTY TYPE MENGE_D   "스크랩입고수량
                                 P_MODE.

  DATA: LS_CO4370_I LIKE ZGTCOT4370.

  IF P_MODE EQ 'TC' OR P_MODE EQ 'SC'.
    UPDATE ZGTCOT4370
       SET MBLNR_OC    = GV_MBLNR_O
           MBLNR_IC    = GV_MBLNR_I
           MBLNR_ZC    = GV_MBLNR_Z
           USNAM_C     = SY-UNAME
           DEL_MARK    = 'X'
           CHANGE_DATE = SY-DATUM
           AEDAT       = SY-DATUM
           AETIM       = SY-UZEIT
           AEDATLO     = SY-DATLO
           AETIMLO     = SY-TIMLO
           AENAM       = SY-UNAME
     WHERE CO_ORDER = P_CO_ORDER
       AND SEQ = '001'.

  ELSE.
    "오더 추출
*    SELECT SINGLE AUFNR
*      FROM MATDOC
*     WHERE WERKS EQ @PS_SC-WERKS
*       AND MATNR EQ @PS_SC-MATNR
*       AND CHARG EQ @PS_SC-CHARG
*       AND BWART EQ '101'
*      INTO @DATA(LV_AUFNR).

    "손익센터
    SELECT SINGLE PRCTR
      FROM MARC
     WHERE WERKS EQ @PS_SC-WERKS
       AND MATNR EQ @PS_SC-MATNR
      INTO @DATA(LV_PRCTR).

*    SELECT SINGLE PRCTR
*      FROM AUFK
*     WHERE AUFNR EQ @LV_AUFNR
*      INTO @DATA(LV_PRCTR).

    "작업장, 코스트센터
*    SELECT SINGLE C~ARBPL, D~KOSTL
*      FROM AFKO AS A
*      JOIN AFVC AS B ON B~AUFPL = A~AUFPL
*                    AND B~APLFL = '000000'
*      JOIN CRHD AS C ON C~OBJID = B~ARBID
*                    AND C~OBJTY = 'A'
*      JOIN CRCO AS D ON D~OBJTY = C~OBJTY
*                    AND D~OBJID = C~OBJID
*     WHERE A~AUFNR EQ @LV_AUFNR
*       AND D~LSTAR EQ 'AT102'
*      INTO (@DATA(LV_ARBPL), @DATA(LV_KOSTL)).

    "DUMMY 스크랩코드
    SELECT SINGLE MATNR
      FROM ZGTPPT1140
     WHERE WERKS EQ @PS_SC-WERKS
       AND SPGCD EQ @PS_SC-SPGCD
       AND MATKL EQ 'DUMMY'
      INTO @DATA(LV_SP_MATNR).

    "공정그룹
    SELECT SINGLE MATKL
      FROM MARA
     WHERE MATNR EQ @PS_SC-MATNR
      INTO @DATA(LV_MATKL).

    CLEAR: LS_CO4370_I.
    LS_CO4370_I-KOKRS     = '6000'.
    LS_CO4370_I-CO_ORDER  = P_CO_ORDER.
    LS_CO4370_I-SEQ       = '001'.
    LS_CO4370_I-SPGCD     = PS_SC-SPGCD.
*    LS_CO4370_I-KOSTL     = LV_KOSTL.
    LS_CO4370_I-SC_REASON = '1'.         "불량
    LS_CO4370_I-BUDAT     = PS_SC-BUDAT.
    LS_CO4370_I-MATNR     = PS_SC-MATNR.
    LS_CO4370_I-WERKS     = PS_SC-WERKS.
    LS_CO4370_I-PRCTR     = LV_PRCTR.
    LS_CO4370_I-SP_MATNR  = LV_SP_MATNR.
    LS_CO4370_I-OPGRP     = LV_MATKL.
*    LS_CO4370_I-ARBPL     = LV_ARBPL.
    LS_CO4370_I-AUFNR     = PS_SC-AUFNR.
    LS_CO4370_I-LGORT     = PS_SC-LGORT.
    LS_CO4370_I-CHARG     = PS_SC-CHARG.
    LS_CO4370_I-QTY       = PS_SC-MENGE.
    LS_CO4370_I-MEINS     = PS_SC-MEINS.
    LS_CO4370_I-SC_MATNR  = P_SC_MATNR.
    LS_CO4370_I-SC_LGORT  = P_SC_LGORT.
    LS_CO4370_I-SC_QTY    = P_CONVQTY.
    LS_CO4370_I-SC_MEINS  = 'KG'.
    LS_CO4370_I-MBLNR_O   = GV_MBLNR_O.
    LS_CO4370_I-MBLNR_I   = GV_MBLNR_I.
    LS_CO4370_I-MBLNR_Z   = GV_MBLNR_Z.
    LS_CO4370_I-USNAM     = SY-UNAME.
    LS_CO4370_I-ERDAT     = SY-DATUM.
    LS_CO4370_I-ERTIM     = SY-UZEIT.
    LS_CO4370_I-ERDATLO   = SY-DATLO.
    LS_CO4370_I-ERTIMLO   = SY-TIMLO.
    LS_CO4370_I-ERNAM     = SY-UNAME.

    MODIFY ZGTCOT4370 FROM LS_CO4370_I.
  ENDIF.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CANCELING_SCRAP_TC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_MODE
*&      --> OT_RESULT[]
*&---------------------------------------------------------------------*
FORM CANCELING_SCRAP_TC  USING PV_MODE
                               PT_RESULT TYPE TY_T_SCRAP_RESULT.

  LOOP AT GS_SCRAP-SCRAP INTO DATA(LS_SC).

    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LS_SC-ZSERNO BINARY SEARCH.

    IF LS_SC-SPGCD EQ 'GO'.
      "취소 대상 자재문서 확인
      SELECT SINGLE MBLNR, MJAHR
        FROM MATDOC
       WHERE MBLNR EQ @LS_SC-C_MBLNR
         AND MJAHR EQ @LS_SC-C_MJAHR
         AND CANCELLED NE 'X'
         AND BWART EQ '937'
        INTO (@DATA(LV_MBLNR), @DATA(LV_MJAHR)).

      IF LV_MBLNR IS INITIAL.
        PERFORM UPDATE_SCRAP_CHECK_LOG USING LS_SC LR_RESULT->*.

      ELSE.
*      취소 대상 자재문서 IF LOG에서 추출
        CLEAR: GS_3450_TC.
        PERFORM GET_ZGTPPT3450 USING LS_SC PV_MODE.

        CLEAR: GV_CHECK.

        "스크랩 취소
        CLEAR: GV_MBLNR_O, GV_MESSAGE_MO.
        PERFORM PROC_MBLNR_O_CANCEL_T.

        IF GV_CHECK EQ 'E' AND GV_MBLNR_O IS INITIAL.
          PERFORM UPDATE_MBLNR_O_LOG_CANCEL_T USING LS_SC LR_RESULT->*.

        ELSE.
          PERFORM UPDATE_SCRAP_LOG_T USING LS_SC LR_RESULT->*.

        ENDIF.
      ENDIF.

    ELSE.
      "취소 대상 자재문서 확인
      CLEAR: LV_MBLNR, LV_MJAHR.
      SELECT SINGLE MBLNR, MJAHR
        FROM MATDOC
       WHERE MBLNR EQ @LS_SC-C_MBLNR
         AND MJAHR EQ @LS_SC-C_MJAHR
         AND CANCELLED NE 'X'
         AND BWART EQ '951'
        INTO (@LV_MBLNR, @LV_MJAHR).

      IF LV_MBLNR IS INITIAL.
        PERFORM UPDATE_SCRAP_CHECK_LOG USING LS_SC LR_RESULT->*.

      ELSE.
*      취소 대상 자재문서 IF LOG에서 추출
        CLEAR: GS_3450_TC.
        PERFORM GET_ZGTPPT3450 USING LS_SC PV_MODE.

        "0입고 취소->입고취소->투입취소->CO 오더 TECO
        CLEAR: GV_CHECK.

        "CO 오더 0 입고 취소
        CLEAR: GV_MBLNR_Z, GV_MESSAGE_MZ.
        PERFORM PROC_MBLNR_Z_CANCEL_T.

        IF GV_CHECK EQ 'E' AND GV_MBLNR_Z IS INITIAL.
          PERFORM UPDATE_MBLNR_Z_LOG_CANCEL_T USING LS_SC LR_RESULT->*.

        ELSE.
          "CO 오더 입고 취소
          CLEAR: GV_MBLNR_I, GV_MESSAGE_MI.
          PERFORM PROC_MBLNR_I_CANCEL_T.

          IF GV_CHECK EQ 'E' AND GV_MBLNR_I IS INITIAL.
            PERFORM UPDATE_MBLNR_I_LOG_CANCEL_T USING LS_SC LR_RESULT->*.

          ELSE.
            "CO 오더 투입 취소
            CLEAR: GV_MBLNR_O, GV_MESSAGE_MO.
            PERFORM PROC_MBLNR_O_CANCEL_T.

            IF GV_CHECK EQ 'E' AND GV_MBLNR_O IS INITIAL.
              PERFORM UPDATE_MBLNR_O_LOG_CANCEL_T USING LS_SC LR_RESULT->*.

            ELSE.
              "CO 오더 TECO 처리
              CLEAR : GV_MESSAGE_CO.
              PERFORM PROC_KKF1_CANCEL_T.

              IF GV_CHECK EQ 'E'.
                PERFORM UPDATE_KKF1_LOG_CANCEL_T USING LS_SC LR_RESULT->*.

              ELSE.

                PERFORM UPDATE_SCRAP_LOG_T USING LS_SC LR_RESULT->*.

*// 951, 971, 0입고 모두 취소 처리 성공 시
*// 공정 외 스크랩 처리 내역 UPDATE(ZGTCOT4370)
                CHECK GV_MBLNR_Z IS NOT INITIAL.
                CHECK GV_MBLNR_I IS NOT INITIAL.
                CHECK GV_MBLNR_O IS NOT INITIAL.

                PERFORM SAVE_ZGTCOT4370_T USING LS_SC
                                                GS_3450_TC-CO_ORDER     "CO오더
                                                '' "스크랩입고자재
                                                '' "스크랩입고저장위치
                                                '' "스크랩입고수량
                                                PV_MODE.

              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MBLNR_Z_CANCEL_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_MBLNR_Z_CANCEL_T .

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LV_HEADTEXT TYPE BKTXT.

  CHECK GS_3450_TC-MBLNR_Z IS NOT INITIAL.

  "취소 문서의 취소 처리 결과 체크
  SELECT SINGLE MANDT
    FROM MATDOC
   WHERE MBLNR EQ @GS_3450_TC-MBLNR_Z
     AND MJAHR EQ @GS_3450_TC-MJAHR
     AND CANCELLED EQ 'X'
    INTO @DATA(LV_MANDT).

  "취소 문서가 취소 전이면 진행
  CHECK SY-SUBRC NE 0.

  "CO 0입고 취소
  CLEAR: LS_HEADRET, LT_RETURN, LV_HEADTEXT.
  LV_HEADTEXT = TEXT-M05. "MES 절단 스크랩 취소

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GS_3450_TC-MBLNR_Z
      MATDOCUMENTYEAR     = GS_3450_TC-MJAHR
      GOODSMVT_PSTNG_DATE = GS_3450_TC-BUDAT_Z
      GOODSMVT_PR_UNAME   = SY-UNAME
      DOCUMENTHEADER_TEXT = LV_HEADTEXT
    IMPORTING
      GOODSMVT_HEADRET    = LS_HEADRET
    TABLES
      RETURN              = LT_RETURN.

  IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
    "성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    DO 10 TIMES.
      SELECT SINGLE @ABAP_TRUE
        INTO @DATA(LV_CHECK)
        FROM MKPF
       WHERE MBLNR EQ @LS_HEADRET-MAT_DOC
         AND MJAHR EQ @LS_HEADRET-DOC_YEAR.

      IF SY-SUBRC IS INITIAL.
        GV_MBLNR_Z = LS_HEADRET-MAT_DOC.
        EXIT.
      ENDIF.

      WAIT UP TO '1' SECONDS.
    ENDDO.

  ELSE.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    GV_MESSAGE_MZ = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

    GV_CHECK = 'E'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_MBLNR_Z_LOG_CANCEL_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_Z_LOG_CANCEL_T  USING    PS_SC TYPE ZGTPPSIF0067
                                       PS_RESULT TYPE ZGTPPSIF0068.

  CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MZ.

  UPDATE ZGTPPT3450
     SET ZSTAT        = GS_SCRAP-ZRESULT
         ZMESSAGE     = GS_SCRAP-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
     AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
     AND ZSERNO     EQ PS_SC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MBLNR_I_CANCEL_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_MBLNR_I_CANCEL_T .

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LV_HEADTEXT TYPE BKTXT.

  CHECK GS_3450_TC-MBLNR_I IS NOT INITIAL.

  "취소 문서의 취소 처리 결과 체크
  SELECT SINGLE MANDT
    FROM MATDOC
   WHERE MBLNR EQ @GS_3450_TC-MBLNR_I
     AND MJAHR EQ @GS_3450_TC-MJAHR
     AND CANCELLED EQ 'X'
    INTO @DATA(LV_MANDT).

  "취소 문서가 취소 전이면 진행
  CHECK SY-SUBRC NE 0.

  "CO입고 취소
  CLEAR: LS_HEADRET, LT_RETURN, LV_HEADTEXT.
  LV_HEADTEXT = TEXT-M05.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GS_3450_TC-MBLNR_I
      MATDOCUMENTYEAR     = GS_3450_TC-MJAHR
      GOODSMVT_PSTNG_DATE = GS_3450_TC-BUDAT_I
      GOODSMVT_PR_UNAME   = SY-UNAME
      DOCUMENTHEADER_TEXT = LV_HEADTEXT
    IMPORTING
      GOODSMVT_HEADRET    = LS_HEADRET
    TABLES
      RETURN              = LT_RETURN.

  IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
    "성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    DO 10 TIMES.
      SELECT SINGLE @ABAP_TRUE
        INTO @DATA(LV_CHECK)
        FROM MKPF
       WHERE MBLNR EQ @LS_HEADRET-MAT_DOC
         AND MJAHR EQ @LS_HEADRET-DOC_YEAR.

      IF SY-SUBRC IS INITIAL.
        GV_MBLNR_I = LS_HEADRET-MAT_DOC.
        EXIT.
      ENDIF.

      WAIT UP TO '1' SECONDS.
    ENDDO.

  ELSE.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    GV_MESSAGE_MI = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

    GV_CHECK = 'E'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_MBLNR_I_LOG_CANCEL_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_I_LOG_CANCEL_T  USING    PS_SC TYPE ZGTPPSIF0067
                                           PS_RESULT TYPE ZGTPPSIF0068.

  CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MI.

  UPDATE ZGTPPT3450
     SET ZSTAT        = GS_SCRAP-ZRESULT
         ZMESSAGE     = GS_SCRAP-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
     AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
     AND ZSERNO     EQ PS_SC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MBLNR_O_CANCEL_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_MBLNR_O_CANCEL_T .

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LV_HEADTEXT TYPE BKTXT.

  CHECK GS_3450_TC-MBLNR_O IS NOT INITIAL.

  "취소 문서의 취소 처리 결과 체크
  SELECT SINGLE MANDT
    FROM MATDOC
   WHERE MBLNR EQ @GS_3450_TC-MBLNR_O
     AND MJAHR EQ @GS_3450_TC-MJAHR
     AND CANCELLED EQ 'X'
    INTO @DATA(LV_MANDT).

  "취소 문서가 취소 전이면 진행
  CHECK SY-SUBRC NE 0.

  "CO투입 취소
  CLEAR: LS_HEADRET, LT_RETURN, LV_HEADTEXT.
  LV_HEADTEXT = TEXT-M05.  "MES 절단 스크랩 취소

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GS_3450_TC-MBLNR_O
      MATDOCUMENTYEAR     = GS_3450_TC-MJAHR
      GOODSMVT_PSTNG_DATE = GS_3450_TC-BUDAT_O
      GOODSMVT_PR_UNAME   = SY-UNAME
      DOCUMENTHEADER_TEXT = LV_HEADTEXT
    IMPORTING
      GOODSMVT_HEADRET    = LS_HEADRET
    TABLES
      RETURN              = LT_RETURN.

  IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
    "성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    DO 10 TIMES.
      SELECT SINGLE @ABAP_TRUE
        INTO @DATA(LV_CHECK)
        FROM MKPF
       WHERE MBLNR EQ @LS_HEADRET-MAT_DOC
         AND MJAHR EQ @LS_HEADRET-DOC_YEAR.

      IF SY-SUBRC IS INITIAL.
        GV_MBLNR_O = LS_HEADRET-MAT_DOC.
        EXIT.
      ENDIF.

      WAIT UP TO '1' SECONDS.
    ENDDO.

  ELSE.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    GV_MESSAGE_MO = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

    GV_CHECK = 'E'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_MBLNR_O_LOG_CANCEL_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_O_LOG_CANCEL_T  USING    PS_SC TYPE ZGTPPSIF0067
                                           PS_RESULT TYPE ZGTPPSIF0068.

  CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MO.

  UPDATE ZGTPPT3450
     SET ZSTAT        = GS_SCRAP-ZRESULT
         ZMESSAGE     = GS_SCRAP-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
     AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
     AND ZSERNO     EQ PS_SC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_KKF1_CANCEL_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_KKF1_CANCEL_T .

  DATA: LV_SUBRC TYPE SYSUBRC,
        LV_LINES TYPE I.

  CLEAR: GT_BDCDATA, GT_BDCDATA[].
  PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0110'.
  PERFORM BDC_FIELD   USING : 'COAS-AUFNR' GS_3450_TC-CO_ORDER,
                              'BDC_OKCODE'  '/00'.

  PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
  PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=PHS2'.

  PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
  PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=SICH'.

  PERFORM BDC_TRANSACTION USING    'KKF2'
                          CHANGING LV_SUBRC.

  CLEAR: GT_MESSTAB.
  READ TABLE GT_MESSTAB WITH KEY MSGID = 'KO'
                                 MSGNR = '109'
                                 MSGTYP = 'S'.

  IF SY-SUBRC EQ 0.
    "성공
    WAIT UP TO '1' SECONDS.

  ELSE.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    "CO 오더 TECO -> REL
    CLEAR: GT_BDCDATA, GT_BDCDATA[].
    PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0110'.
    PERFORM BDC_FIELD   USING : 'COAS-AUFNR' GS_3450_TC-CO_ORDER,
                                'BDC_OKCODE'  '/00'.

    PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
    PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=PHS1'.

    PERFORM BDC_DYNPRO  USING 'SAPMKAUF' '0600'.
    PERFORM BDC_FIELD   USING : 'BDC_OKCODE'  '=SICH'.

    PERFORM BDC_TRANSACTION USING    'KKF2'
                            CHANGING LV_SUBRC.

*   마지막 에러 메시지만 보여주기
    CLEAR : LV_LINES, GT_MESSTAB.
    DESCRIBE TABLE GT_MESSTAB LINES LV_LINES.
    READ TABLE GT_MESSTAB INDEX LV_LINES.

    PERFORM BUILD_MESSAGE_TEXT(ZCOF0030)
               USING GT_MESSTAB-MSGID GT_MESSTAB-MSGNR
                     GT_MESSTAB-MSGV1 GT_MESSTAB-MSGV2
                     GT_MESSTAB-MSGV3 GT_MESSTAB-MSGV4
            CHANGING GV_MESSAGE_CO.

    IF GV_MESSAGE_CO IS INITIAL.
      GV_MESSAGE_CO = 'CO 오더 취소 도중 오류가 발생하였습니다.'.
    ENDIF.

    GV_CHECK = 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_KKF1_LOG_CANCEL_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_KKF1_LOG_CANCEL_T  USING    PS_SC TYPE ZGTPPSIF0067
                                        PS_RESULT TYPE ZGTPPSIF0068.

  CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_CO.

  UPDATE ZGTPPT3450
     SET ZSTAT        = GS_SCRAP-ZRESULT
         ZMESSAGE     = GS_SCRAP-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
     AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
     AND ZSERNO     EQ PS_SC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_SCRAP_LOG_T
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_SCRAP_LOG_T  USING    PS_SC TYPE ZGTPPSIF0067
                                  PS_RESULT TYPE ZGTPPSIF0068.

  PS_RESULT = VALUE #( BASE PS_RESULT  MBLNR        = GV_MBLNR_O
                                       MJAHR        = GV_MJAHR
                                       ZERP_STAT    = COND #( WHEN GV_MBLNR_O IS NOT INITIAL THEN ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                                              ELSE ZGTPP_IF_CONST=>GC_RESULT-ERROR )
                                       ZERP_MESSAGE = COND #( WHEN GV_MBLNR_O IS NOT INITIAL THEN COND #( WHEN GS_SCRAP-ZMODE EQ 'T' THEN TEXT-S09
                                                                                                          WHEN GS_SCRAP-ZMODE EQ 'S' THEN TEXT-S09
                                                                                                          ELSE TEXT-S10 )
                                                              ELSE GV_MESSAGE_MO ) ).

  UPDATE ZGTPPT3450
     SET ZSTAT        = GS_SCRAP-ZRESULT
         ZMESSAGE     = GS_SCRAP-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
     AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
     AND ZSERNO     EQ PS_SC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_zgtppt2180_f_charg
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_ZGTPPT2180_F_CHARG  TABLES PT_RESULT   STRUCTURE ZGTPPSIF0045
                                 USING PV_MODE     TYPE ZGTEZMODE
                                       PT_CUT_ITEM TYPE TY_T_CUT_ITEM.

  DATA: BEGIN OF LS_F_CHARG,
          F_CHARG    LIKE ZGTPPT2180-F_CHARG,    "계획절단배치
          ZCUT_MBLNR LIKE ZGTPPT2190-ZCUT_MBLNR,
          ZCUT_MJAHR LIKE ZGTPPT2190-ZCUT_MJAHR,
          SOBKZ      LIKE ZGTPPT2190-SOBKZ,
          R_CHARG_H  LIKE MATDOC-CHARG,          "실제절단배치
          R_CHARG_S  LIKE MATDOC-CHARG,          "실제절단후배치
        END OF LS_F_CHARG.
  DATA: LT_F_CHARG LIKE TABLE OF LS_F_CHARG.

  DATA: LT_2180_F_CHARG_ORG LIKE TABLE OF ZGTPPT2180,
        LT_2180_R_CHARG_ORG LIKE TABLE OF ZGTPPT2180.

  DATA: LS_F_ORG LIKE ZGTPPT2180,
        LS_R_ORG LIKE ZGTPPT2180.

  DATA: LV_CNT TYPE SY-TABIX.

  CHECK PV_MODE EQ 'P'.

  "절단 실적 등록된 절단 지시의 계획 배치번호의 정보 추출
  CLEAR: LT_F_CHARG.
  SELECT DISTINCT ZT03~F_CHARG, ZT02~ZCUT_MBLNR, ZT02~ZCUT_MJAHR, ZT02~SOBKZ
    FROM @PT_CUT_ITEM AS ZT01
    JOIN ZGTPPT2190 AS ZT02 ON ZT02~ZCUT_ORD_NO   EQ ZT01~ZCUT_ORD_NO
                           AND ZT02~ZCUT_ORD_ITEM EQ ZT01~ZCUT_ORD_ITEM
    JOIN ZGTPPT2180 AS ZT03 ON ZT03~ZASSIGN_NO   EQ ZT02~ZASSIGN_NO
                           AND ZT03~ZASSIGN_ITEM EQ ZT02~ZASSIGN_ITEM
   WHERE ZT02~ZCUT_MBLNR IS NOT INITIAL
    INTO TABLE @LT_F_CHARG.

  "실제 절단 처리 배치 및 잔량 배치 번호 추출
  LOOP AT LT_F_CHARG ASSIGNING FIELD-SYMBOL(<FS_F_CHARG>).
    IF <FS_F_CHARG>-SOBKZ EQ 'E'.
      "실제절단배치
      SELECT SINGLE CHARG
        FROM MATDOC
       WHERE MBLNR EQ @<FS_F_CHARG>-ZCUT_MBLNR
         AND MJAHR EQ @<FS_F_CHARG>-ZCUT_MJAHR
         AND SHKZG EQ 'H'
        INTO @<FS_F_CHARG>-R_CHARG_H.

      "실제절단후배치
      SELECT SINGLE CHARG
        FROM MATDOC
       WHERE MBLNR EQ @<FS_F_CHARG>-ZCUT_MBLNR
         AND MJAHR EQ @<FS_F_CHARG>-ZCUT_MJAHR
         AND SHKZG EQ 'S'
        INTO @<FS_F_CHARG>-R_CHARG_S.

    ELSEIF <FS_F_CHARG>-SOBKZ EQ SPACE.
      "실제절단배치
      SELECT SINGLE CHARG
        FROM MATDOC
       WHERE MBLNR EQ @<FS_F_CHARG>-ZCUT_MBLNR
         AND MJAHR EQ @<FS_F_CHARG>-ZCUT_MJAHR
         AND SHKZG EQ 'H'
        INTO @<FS_F_CHARG>-R_CHARG_H.

      "실제절단후배치
      SELECT SINGLE CHARG
        FROM MATDOC
       WHERE MBLNR EQ @<FS_F_CHARG>-ZCUT_MBLNR
         AND MJAHR EQ @<FS_F_CHARG>-ZCUT_MJAHR
         AND SHKZG EQ 'S'
        INTO @<FS_F_CHARG>-R_CHARG_S.

    ENDIF.

  ENDLOOP.

  CLEAR: LT_2180_F_CHARG_ORG[],
         LT_2180_R_CHARG_ORG[].

  LOOP AT LT_F_CHARG INTO LS_F_CHARG.
    "계획 배치번호 기준의 변경할 주문할당 추출
    SELECT *
      FROM ZGTPPT2180
     WHERE F_CHARG EQ @LS_F_CHARG-F_CHARG
      APPENDING TABLE @LT_2180_F_CHARG_ORG.

    "실제 배치번호 기준의 변경할 주문할당 추출
    SELECT *
      FROM ZGTPPT2180
     WHERE F_CHARG EQ @LS_F_CHARG-R_CHARG_H
      APPENDING TABLE @LT_2180_R_CHARG_ORG.

    CLEAR: LS_F_CHARG.
  ENDLOOP.

  SORT: LT_2180_F_CHARG_ORG BY ZASSIGN_NO ZASSIGN_ITEM,
        LT_2180_R_CHARG_ORG BY ZASSIGN_NO ZASSIGN_ITEM.

  DELETE ADJACENT DUPLICATES FROM LT_2180_F_CHARG_ORG COMPARING ZASSIGN_NO ZASSIGN_ITEM.
  DELETE ADJACENT DUPLICATES FROM LT_2180_R_CHARG_ORG COMPARING ZASSIGN_NO ZASSIGN_ITEM.

  SORT LT_F_CHARG BY ZCUT_MBLNR.

  CLEAR: LV_CNT.
  LV_CNT = LINES( LT_F_CHARG ).
  READ TABLE LT_F_CHARG INTO LS_F_CHARG INDEX LV_CNT. "마지막 실적

  CHECK LS_F_CHARG-F_CHARG IS NOT INITIAL.
  CHECK LS_F_CHARG-R_CHARG_H IS NOT INITIAL.

  IF LS_F_CHARG-SOBKZ EQ 'E'.

    IF LS_F_CHARG-F_CHARG NE LS_F_CHARG-R_CHARG_H.

      IF LT_2180_F_CHARG_ORG[] IS NOT INITIAL.
        LOOP AT LT_2180_F_CHARG_ORG INTO LS_F_ORG.
          "계획 배치번호 기준의 주문할당된 대상을 계획 배치번호를 실제 배치번호로 업데이트
          UPDATE ZGTPPT2180 SET F_CHARG = LS_F_CHARG-R_CHARG_H
                          WHERE ZASSIGN_NO   = LS_F_ORG-ZASSIGN_NO
                            AND ZASSIGN_ITEM = LS_F_ORG-ZASSIGN_ITEM.

          CLEAR: LS_F_ORG.
        ENDLOOP.
      ENDIF.

      IF LT_2180_R_CHARG_ORG[] IS NOT INITIAL.
        LOOP AT LT_2180_R_CHARG_ORG INTO LS_R_ORG.
          "실제 배치번호 기준의 주문할당된 대상을 계획 배치번호를 계획 배치번호로 업데이트
          UPDATE ZGTPPT2180 SET F_CHARG = LS_F_CHARG-F_CHARG
                          WHERE ZASSIGN_NO   = LS_R_ORG-ZASSIGN_NO
                            AND ZASSIGN_ITEM = LS_R_ORG-ZASSIGN_ITEM.

          CLEAR: LS_R_ORG.
        ENDLOOP.
      ENDIF.

    ENDIF.

  ELSE.
    CHECK LS_F_CHARG-R_CHARG_S IS NOT INITIAL.

    IF LS_F_CHARG-F_CHARG NE LS_F_CHARG-R_CHARG_H.
      IF LT_2180_F_CHARG_ORG[] IS NOT INITIAL.
        LOOP AT LT_2180_F_CHARG_ORG INTO LS_F_ORG.
          "계획 배치번호 기준의 주문할당된 대상을 계획 배치번호를 실제 배치번호로 업데이트
          UPDATE ZGTPPT2180 SET F_CHARG = LS_F_CHARG-R_CHARG_S
                          WHERE ZASSIGN_NO   = LS_F_ORG-ZASSIGN_NO
                            AND ZASSIGN_ITEM = LS_F_ORG-ZASSIGN_ITEM.

          CLEAR: LS_F_ORG.
        ENDLOOP.
      ENDIF.

    ELSE.
      "계획배치 기준의 처리되지 않은 절단지시의 주문할당 추출
      SELECT DISTINCT
             ZT01~ZASSIGN_NO, ZT01~ZASSIGN_ITEM
        FROM ZGTPPT2180 AS ZT01
        JOIN ZGTPPT2190 AS ZT02 ON ZT02~ZASSIGN_NO EQ ZT01~ZASSIGN_NO
                               AND ZT02~ZASSIGN_ITEM EQ ZT01~ZASSIGN_ITEM
       WHERE ZT01~F_CHARG EQ @LS_F_CHARG-F_CHARG
         AND ZT02~ZCUT_MBLNR IS INITIAL
        INTO TABLE @DATA(LT_2180_F_CHARG_ORG_1).

      IF LT_2180_F_CHARG_ORG_1[] IS NOT INITIAL.
        LOOP AT LT_2180_F_CHARG_ORG_1 INTO DATA(LS_F_ORG_1).
          "계획 배치번호 기준의 주문할당된 대상을 계획 배치번호를 실제 배치번호로 업데이트
          UPDATE ZGTPPT2180 SET F_CHARG = LS_F_CHARG-R_CHARG_S
                          WHERE ZASSIGN_NO   = LS_F_ORG_1-ZASSIGN_NO
                            AND ZASSIGN_ITEM = LS_F_ORG_1-ZASSIGN_ITEM.

          CLEAR: LS_F_ORG.
        ENDLOOP.
      ENDIF.

    ENDIF.
  ENDIF.

  CLEAR: LS_F_CHARG.


**  IF LS_F_CHARG-F_CHARG NE LS_F_CHARG-R_CHARG.  "계획배치와 실제배치가 다른 경우
**
**    IF LS_F_CHARG-SOBKZ EQ 'E'.
**
**      IF LT_2180_F_CHARG_ORG[] IS NOT INITIAL.
**        LOOP AT LT_2180_F_CHARG_ORG INTO LS_F_ORG.
**          "계획 배치번호 기준의 주문할당된 대상을 계획 배치번호를 실제 배치번호로 업데이트
**          UPDATE ZGTPPT2180 SET F_CHARG = LS_F_CHARG-R_CHARG
**                          WHERE ZASSIGN_NO   = LS_F_ORG-ZASSIGN_NO
**                            AND ZASSIGN_ITEM = LS_F_ORG-ZASSIGN_ITEM.
**
**          CLEAR: LS_F_ORG.
**        ENDLOOP.
**      ENDIF.
**
**      IF LT_2180_R_CHARG_ORG[] IS NOT INITIAL.
**        LOOP AT LT_2180_R_CHARG_ORG INTO LS_R_ORG.
**          "실제 배치번호 기준의 주문할당된 대상을 계획 배치번호를 계획 배치번호로 업데이트
**          UPDATE ZGTPPT2180 SET F_CHARG = LS_F_CHARG-F_CHARG
**                          WHERE ZASSIGN_NO   = LS_R_ORG-ZASSIGN_NO
**                            AND ZASSIGN_ITEM = LS_R_ORG-ZASSIGN_ITEM.
**
**          CLEAR: LS_R_ORG.
**        ENDLOOP.
**      ENDIF.
**
**    ELSEIF LS_F_CHARG-SOBKZ EQ SPACE.
**      IF LT_2180_F_CHARG_ORG[] IS NOT INITIAL.
**        LOOP AT LT_2180_F_CHARG_ORG INTO LS_F_ORG.
**          "계획 배치번호 기준의 주문할당된 대상을 계획 배치번호를 실제 배치번호로 업데이트
**          UPDATE ZGTPPT2180 SET F_CHARG = LS_F_CHARG-R_CHARG
**                          WHERE ZASSIGN_NO   = LS_F_ORG-ZASSIGN_NO
**                            AND ZASSIGN_ITEM = LS_F_ORG-ZASSIGN_ITEM.
**
**          CLEAR: LS_F_ORG.
**        ENDLOOP.
**      ENDIF.
**
**    ENDIF.
**
**  ELSE. "계획배치와 실제배치가 같은 경우
**    "실적의 마지막이 생성된 잔량 배치인 경우 주문 할당의 실적처리 되지 않는 계획 배치에 업데이트
**    IF LS_F_CHARG-SOBKZ EQ SPACE.
**      "계획배치 기준의 처리되지 않은 절단지시의 주문할당 추출
**      SELECT ZT01~ZASSIGN_NO, ZT01~ZASSIGN_ITEM
**        FROM ZGTPPT2180 AS ZT01
**        JOIN ZGTPPT2190 AS ZT02 ON ZT02~ZASSIGN_NO EQ ZT01~ZASSIGN_NO
**                               AND ZT02~ZASSIGN_ITEM EQ ZT01~ZASSIGN_ITEM
**       WHERE ZT01~F_CHARG EQ @LS_F_CHARG-F_CHARG
**         AND ZT02~ZCUT_MBLNR IS INITIAL
**        INTO TABLE @DATA(LT_2180_F_CHARG_ORG_1).
**
**      IF LT_2180_F_CHARG_ORG_1[] IS NOT INITIAL.
**        LOOP AT LT_2180_F_CHARG_ORG_1 INTO DATA(LS_F_ORG_1).
**          "계획 배치번호 기준의 주문할당된 대상을 계획 배치번호를 실제 배치번호로 업데이트
**          UPDATE ZGTPPT2180 SET F_CHARG = LS_F_CHARG-R_CHARG
**                          WHERE ZASSIGN_NO   = LS_F_ORG_1-ZASSIGN_NO
**                            AND ZASSIGN_ITEM = LS_F_ORG_1-ZASSIGN_ITEM.
**
**          CLEAR: LS_F_ORG.
**        ENDLOOP.
**      ENDIF.
**
**    ENDIF.
**
**  ENDIF.
**
**  CLEAR: LS_F_CHARG.


*  DATA LT_ZGTPPT2180 TYPE TABLE OF ZGTPPT2180.
*
*  LOOP AT PT_RESULT[] INTO DATA(LS_RESULT)
*                     WHERE TR_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR
*                        OR AL_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR
*                        OR CHK_MSG EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR.
*    RETURN.
*  ENDLOOP.
*
*  WITH +T2190 AS ( SELECT DISTINCT ZT02~ZASSIGN_NO,  ZT02~ZASSIGN_ITEM,
*                                   ZT02~ZCUT_ORD_NO, ZT02~ZCUT_ORD_ITEM, ZT03~F_CHARG, ZT01~T_CHARG
*                     FROM @PT_CUT_ITEM AS ZT01
*                     JOIN ZGTPPT2190   AS ZT02
*                       ON ZT01~ZCUT_ORD_NO   EQ ZT02~ZCUT_ORD_NO
*                      AND ZT01~ZCUT_ORD_ITEM EQ ZT02~ZCUT_ORD_ITEM
*                      AND ZT02~LOEKZ         EQ @SPACE
*                      AND ZT02~SOBKZ         EQ @SPACE
*                     JOIN ZGTPPT2180 AS ZT03
*                       ON ZT02~ZASSIGN_NO   EQ ZT03~ZASSIGN_NO
*                      AND ZT02~ZASSIGN_ITEM EQ ZT03~ZASSIGN_ITEM )
*
*  SELECT ZT01~ZASSIGN_NO, ZT01~ZASSIGN_ITEM, ZT01~LGORT, ZT01~LABST1, ZT01~LABST2, ZT01~LABST3,
*         ZT01~ZCUT_YN, ZT01~ZCUT_CNT, ZT01~ZREW_YN, ZT01~ZEXCLUDE, ZT01~MEINS, ZT01~ZORD_TYPE,
*         ZT01~CRDAT,ZT01~CRTIM,ZT01~CRNAM,
*         @SY-DATUM AS CHDAT,
*         @SY-UZEIT AS CHTIM,
*         @SY-UNAME AS CHNAM,
*         CASE @PV_MODE WHEN 'P' THEN ZT01~F_CHARG
*                       WHEN 'C' THEN @SPACE
*         END AS F_CHARG_ORG,
*         CASE @PV_MODE WHEN 'P' THEN ZT02~T_CHARG
*                       WHEN 'C' THEN ZT01~F_CHARG_ORG
*         END AS F_CHARG
*    FROM ZGTPPT2180 AS ZT01
*    JOIN +T2190     AS ZT02
*      ON ZT01~F_CHARG EQ ZT02~F_CHARG
*   WHERE NOT EXISTS ( SELECT ZT03~ZASSIGN_NO
*                        FROM +T2190 AS ZT03
*                       WHERE ZT01~ZASSIGN_NO   EQ ZT03~ZASSIGN_NO
*                         AND ZT01~ZASSIGN_ITEM EQ ZT03~ZASSIGN_ITEM  )
*    INTO CORRESPONDING FIELDS OF TABLE @LT_ZGTPPT2180.
*
*  CHECK LT_ZGTPPT2180 IS NOT INITIAL.
*
*  MODIFY ZGTPPT2180 FROM TABLE LT_ZGTPPT2180.
*
*  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_MBLNR_O_LOG_937
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_O_LOG_937  USING   PS_QC TYPE ZGTPPSIF0061
                                 PS_RESULT TYPE ZGTPPSIF0062.

  DATA LV_SUBRC TYPE SYSUBRC.
  DATA LV_HEADTEXT TYPE BKTXT.

  IF GV_MBLNR_O IS NOT INITIAL.
    UPDATE ZGTPPT3440
       SET MBLNR_O = GV_MBLNR_O
     WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
       AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
       AND ZSERNO     EQ PS_QC-ZSERNO.

    "폐기 실패 시 합부판정 자재문서 취소
  ELSE.
    CLEAR: GS_HEADRET1, GT_RETURN1, LV_HEADTEXT.
    LV_HEADTEXT = PS_QC-ZSERNO.

    CALL FUNCTION 'ZGTPP_BAPI_GOODSMVT_CANCEL' STARTING NEW TASK 'MBLNR'
      PERFORMING GET_QC_MOVE_CANCEL ON END OF TASK
      EXPORTING
        MATERIALDOCUMENT    = GV_MBLNR
        MATDOCUMENTYEAR     = GV_MJAHR
        GOODSMVT_PSTNG_DATE = PS_QC-BUDAT
        GOODSMVT_PR_UNAME   = SY-UNAME
        DOCUMENTHEADER_TEXT = LV_HEADTEXT.

    WAIT UNTIL GV_JOBS = '1'.

    IF GS_HEADRET1-MAT_DOC IS NOT INITIAL.

      CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
      PS_RESULT-ZERP_STAT = 'E'.
      PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MO.

      UPDATE ZGTPPT3440
         SET MBLNR        = ''
             MJAHR        = ''
             ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
             ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
             ZERP_STAT    = PS_RESULT-ZERP_STAT
             ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
       WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
         AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
         AND ZSERNO     EQ PS_QC-ZSERNO.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      PS_RESULT-ZERP_STAT = 'E'.
      PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MO.

      UPDATE ZGTPPT3440
         SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
             ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
             ZERP_STAT    = PS_RESULT-ZERP_STAT
             ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
       WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
         AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
         AND ZSERNO     EQ PS_QC-ZSERNO.

    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_MBLNR_O_LOG_T_937
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_MBLNR_O_LOG_T_937  USING   PS_SC TYPE ZGTPPSIF0067
                                   PS_RESULT TYPE ZGTPPSIF0068.

  IF GV_MBLNR_O IS NOT INITIAL.
    UPDATE ZGTPPT3450
       SET MBLNR_O = GV_MBLNR_O
           MJAHR   = GV_MJAHR
     WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
       AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
       AND ZSERNO     EQ PS_SC-ZSERNO.

  ELSE.
    PS_RESULT-ZERP_STAT = 'E'.
    PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_MO.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_FACTOR_BATCH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_QC
*&      --> LS_HEADRET
*&---------------------------------------------------------------------*
FORM UPDATE_FACTOR_BATCH  USING    PS_QC TYPE ZGTPPSIF0061
                                   PS_RESULT TYPE ZGTPPSIF0062.

  DATA: LT_RETURN  TYPE TABLE OF BAPIRET2,
        LV_CLASS   TYPE KLAH-CLASS,
        LT_VALNUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
        LS_VALNUM  TYPE BAPI1003_ALLOC_VALUES_NUM,
        LT_VALCHAR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
        LS_VALCHAR TYPE BAPI1003_ALLOC_VALUES_CHAR,
        LT_VALCURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
        LV_STATUS  TYPE BAPI1003_KEY-STATUS.
  DATA: LV_DPCBT LIKE MARC-DPCBT.
  DATA: LV_HEADTEXT TYPE BKTXT.

  "단일 단위 배치 기본값
  CLEAR: LV_DPCBT.
  SELECT SINGLE DPCBT
    FROM MARC
   WHERE MATNR = @PS_QC-MATNR
     AND WERKS = @PS_QC-WERKS
    INTO @LV_DPCBT.

  IF LV_DPCBT EQ 'A'.
    CLEAR: LT_VALNUM, LT_VALCHAR, LT_VALCURR.

* CLASS번호
    CLEAR: LV_CLASS.
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        MATERIAL           = PS_QC-MATNR "입고자재
        PLANT              = PS_QC-WERKS "플랜트
        CLASSTYPE          = '023'       "클래스유형(배치)
      IMPORTING
        CLASS              = LV_CLASS
      EXCEPTIONS
        NO_CLASS_FOUND     = 1
        NO_CLASSTYPE_FOUND = 2
        OTHERS             = 3.

    CHECK LV_CLASS IS NOT INITIAL.

    CLEAR: LS_VALNUM.
    LS_VALNUM-CHARACT = 'SAP_MILLCA_LENGTH_SUB'.
    LS_VALNUM-VALUE_FROM = '0'.
    APPEND LS_VALNUM TO LT_VALNUM.

    CLEAR: LS_VALNUM.
    LS_VALNUM-CHARACT = 'SAP_MILLCA_LENGTH'.
    LS_VALNUM-VALUE_FROM = PS_QC-CHARG.
    APPEND LS_VALNUM TO LT_VALNUM.

*- 배치 특성 업데이트(펑션 호출)
    SELECT SINGLE CUOBJ_BM
      INTO @DATA(LV_OBJKEY)
      FROM MCH1
     WHERE MATNR = @PS_QC-MATNR
       AND CHARG = @PS_QC-CHARG.

    CLEAR : LT_RETURN.
    CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
      EXPORTING
        CLOBJECTKEY         = LV_OBJKEY
        CLASSNUM            = LV_CLASS
      IMPORTING
        CLASSIF_STATUS      = LV_STATUS
      TABLES
        ALLOCVALUESNUM_NEW  = LT_VALNUM
        ALLOCVALUESCHAR_NEW = LT_VALCHAR
        ALLOCVALUESCURR_NEW = LT_VALCURR
        RETURN              = LT_RETURN.

    IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      GV_MESSAGE_FB = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

      "합부판정 자재문서 취소
      CLEAR: GS_HEADRET1, GT_RETURN1, LV_HEADTEXT.
      LV_HEADTEXT = PS_QC-ZSERNO.

      CALL FUNCTION 'ZGTPP_BAPI_GOODSMVT_CANCEL' STARTING NEW TASK 'MBLNR'
        PERFORMING GET_QC_MOVE_CANCEL ON END OF TASK
        EXPORTING
          MATERIALDOCUMENT    = GV_MBLNR
          MATDOCUMENTYEAR     = GV_MJAHR
          GOODSMVT_PSTNG_DATE = PS_QC-BUDAT
          GOODSMVT_PR_UNAME   = SY-UNAME
          DOCUMENTHEADER_TEXT = LV_HEADTEXT.

      WAIT UNTIL GV_JOBS = '1'.

      CLEAR: GV_MBLNR, GV_MJAHR, GV_MESSAGE_M.
      GV_MESSAGE_M = GV_MESSAGE_FB.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_FACTOR_BATCH_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_FACTOR_BATCH_CANCEL  USING   PS_QC TYPE ZGTPPSIF0061
                                         PS_RESULT TYPE ZGTPPSIF0062.
  DATA: LT_RETURN  TYPE TABLE OF BAPIRET2,
        LV_CLASS   TYPE KLAH-CLASS,
        LT_VALNUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM,
        LS_VALNUM  TYPE BAPI1003_ALLOC_VALUES_NUM,
        LT_VALCHAR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CHAR,
        LS_VALCHAR TYPE BAPI1003_ALLOC_VALUES_CHAR,
        LT_VALCURR TYPE TABLE OF BAPI1003_ALLOC_VALUES_CURR,
        LV_STATUS  TYPE BAPI1003_KEY-STATUS.
  DATA: LV_DPCBT LIKE MARC-DPCBT.
  DATA: LV_HEADTEXT TYPE BKTXT.

  "단일 단위 배치 기본값
  CLEAR: LV_DPCBT.
  SELECT SINGLE DPCBT
    FROM MARC
   WHERE MATNR = @PS_QC-MATNR
     AND WERKS = @PS_QC-WERKS
    INTO @LV_DPCBT.

  IF LV_DPCBT EQ 'A'.
    CLEAR: LT_VALNUM, LT_VALCHAR, LT_VALCURR.

* CLASS번호
    CLEAR: LV_CLASS.
    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        MATERIAL           = PS_QC-MATNR "입고자재
        PLANT              = PS_QC-WERKS "플랜트
        CLASSTYPE          = '023'       "클래스유형(배치)
      IMPORTING
        CLASS              = LV_CLASS
      EXCEPTIONS
        NO_CLASS_FOUND     = 1
        NO_CLASSTYPE_FOUND = 2
        OTHERS             = 3.

    CHECK LV_CLASS IS NOT INITIAL.

    CLEAR: LS_VALNUM.
    LS_VALNUM-CHARACT = 'SAP_MILLCA_LENGTH_SUB'.
    LS_VALNUM-VALUE_FROM = ''.
    APPEND LS_VALNUM TO LT_VALNUM.

    CLEAR: LS_VALNUM.
    LS_VALNUM-CHARACT = 'SAP_MILLCA_LENGTH'.
    LS_VALNUM-VALUE_FROM = PS_QC-CHARG.
    APPEND LS_VALNUM TO LT_VALNUM.

*- 배치 특성 업데이트(펑션 호출)
    SELECT SINGLE CUOBJ_BM
      INTO @DATA(LV_OBJKEY)
      FROM MCH1
     WHERE MATNR = @PS_QC-MATNR
       AND CHARG = @PS_QC-CHARG.

    CLEAR : LT_RETURN.
    CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
      EXPORTING
        CLOBJECTKEY         = LV_OBJKEY
        CLASSNUM            = LV_CLASS
      IMPORTING
        CLASSIF_STATUS      = LV_STATUS
      TABLES
        ALLOCVALUESNUM_NEW  = LT_VALNUM
        ALLOCVALUESCHAR_NEW = LT_VALCHAR
        ALLOCVALUESCURR_NEW = LT_VALCURR
        RETURN              = LT_RETURN.

    IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      GV_MESSAGE_FB = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).

      GV_CHECK = 'E'.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.

    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_FACTOR_BATCH_LOG_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_QC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_FACTOR_BATCH_LOG_CANCEL  USING   PS_QC TYPE ZGTPPSIF0061
                                             PS_RESULT TYPE ZGTPPSIF0062.

  CLEAR: PS_RESULT-MBLNR, PS_RESULT-MJAHR.
  PS_RESULT-ZERP_STAT = 'E'.
  PS_RESULT-ZERP_MESSAGE = GV_MESSAGE_FB.

  UPDATE ZGTPPT3440
     SET ZSTAT        = GS_QC_USAGE_DECSION-ZRESULT
         ZMESSAGE     = GS_QC_USAGE_DECSION-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_QC_USAGE_DECSION-ZIFKEY
     AND ZSYSTEM_ID EQ GS_QC_USAGE_DECSION-ZSYSTEM_ID
     AND ZSERNO     EQ PS_QC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESSING_SCRAP_A
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_MODE
*&      --> OT_RESULT[]
*&---------------------------------------------------------------------*
FORM PROCESSING_SCRAP_A  USING PV_MODE
                               PT_RESULT TYPE TY_T_SCRAP_RESULT.

  LOOP AT GS_SCRAP-SCRAP INTO DATA(LS_SC).

    IF PV_MODE EQ 'A'.
      PERFORM GET_ADD_QTY USING LS_SC PV_MODE.
    ENDIF.

    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LS_SC-ZSERNO BINARY SEARCH.

    CLEAR: GV_CHECK.
    IF GT_ADD_QTY IS INITIAL.
      PERFORM UPDATE_ADD_QTY_LOG USING LS_SC LR_RESULT->* PV_MODE.
      GV_CHECK = 'X'.
    ENDIF.

    CHECK GV_CHECK IS INITIAL.

* 261 투입 처리
    CLEAR: GV_MBLNR_O, GV_MESSAGE_MO, GV_MJAHR.
    PERFORM PROC_261_O USING LS_SC PV_MODE.

    PERFORM UPDATE_261_O_LOG USING LS_SC LR_RESULT->*.

    CHECK GV_MBLNR_O IS NOT INITIAL.

* 꼬리표 잔량 UPDATE
    CLEAR: GV_CHECK.
    PERFORM UPDATE_ZPPT0001 USING LS_SC.

    CHECK GV_CHECK IS INITIAL.

*531 입고 처리
    CLEAR: GV_MBLNR_I, GV_MESSAGE_MI.
    PERFORM PROC_531_I USING LS_SC PV_MODE.

    PERFORM UPDATE_531_I_LOG USING LS_SC LR_RESULT->*.

    CHECK GV_MBLNR_I IS NOT INITIAL.

    PERFORM UPDATE_SCRAP_LOG USING LS_SC LR_RESULT->*.

*// 261, 531 모두 처리 성공 시
*// 공정 외 스크랩 처리 내역 INSERT(ZGTCOT4370)
    CHECK GV_MBLNR_O IS NOT INITIAL.
    CHECK GV_MBLNR_I IS NOT INITIAL.

    PERFORM SAVE_ZGTCOT4370_SC USING LS_SC
                                     PV_MODE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CANCELING_SCRAP_AC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_MODE
*&      --> OT_RESULT[]
*&---------------------------------------------------------------------*
FORM CANCELING_SCRAP_AC  USING PV_MODE
                               PT_RESULT TYPE TY_T_SCRAP_RESULT.

  LOOP AT GS_SCRAP-SCRAP INTO DATA(LS_SC).

    "취소 대상 자재문서 확인
    SELECT SINGLE MBLNR, MJAHR
      FROM MATDOC
     WHERE MBLNR EQ @LS_SC-C_MBLNR
       AND MJAHR EQ @LS_SC-C_MJAHR
       AND CANCELLED NE 'X'
       AND BWART EQ '261'
      INTO (@DATA(LV_MBLNR), @DATA(LV_MJAHR)).

    READ TABLE PT_RESULT REFERENCE INTO DATA(LR_RESULT) WITH KEY ZSERNO = LS_SC-ZSERNO BINARY SEARCH.

    IF LV_MBLNR IS INITIAL.
      PERFORM UPDATE_SCRAP_CHECK_LOG USING LS_SC LR_RESULT->*.

    ELSE.
*      취소 대상 자재문서 IF LOG에서 추출
      CLEAR: GS_3450_C.
      PERFORM GET_ZGTPPT3450 USING LS_SC PV_MODE.

* 531 입고 취소->261 투입 취소->꼬리표 잔량 UPDATE
      CLEAR: GV_CHECK.

* 531 입고 취소
      CLEAR: GV_MBLNR_I, GV_MESSAGE_MI.
      PERFORM PROC_531_I_CANCEL.

      IF GV_CHECK EQ 'E'.
        PERFORM UPDATE_531_I_LOG_CANCEL USING LS_SC LR_RESULT->*.

      ELSE.
        IF GS_3450_C-MBLNR_O IS INITIAL.
          GS_3450_C-MBLNR_O = LS_SC-C_MBLNR.
          GS_3450_C-MJAHR = LS_SC-C_MJAHR.
        ENDIF.

* 261 투입 취소
        CLEAR: GV_MBLNR_O, GV_MESSAGE_MO, GV_MJAHR.
        PERFORM PROC_261_O_CANCEL.

        IF GV_CHECK EQ 'E'.
          PERFORM UPDATE_261_O_LOG_CANCEL USING LS_SC LR_RESULT->*.

        ELSE.
* 꼬리표 잔량 UPDATE
          PERFORM UPDATE_ZPPT0001_CANCEL USING LS_SC.

          IF GV_CHECK EQ 'E'.
            PERFORM UPDATE_ZPPT0001_LOG_CANCEL USING LS_SC LR_RESULT->*.

          ELSE.
            PERFORM UPDATE_SCRAP_LOG USING LS_SC LR_RESULT->*.

*// 261, 531 모두 취소 처리 성공 시
*// 공정 외 스크랩 처리 내역 INSERT(ZGTCOT4370)
            CHECK GV_CHECK EQ SPACE.

            PERFORM SAVE_ZGTCOT4370_SC USING LS_SC
                                             PV_MODE.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ADD_QTY_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SC
*&      --> LR_RESULT_>*
*&---------------------------------------------------------------------*
FORM UPDATE_ADD_QTY_LOG  USING    PS_SC TYPE ZGTPPSIF0067
                                  PS_RESULT TYPE ZGTPPSIF0068
                                  PV_MODE.

  PS_RESULT-ZERP_STAT = 'E'.

  IF PV_MODE EQ 'A'.
    PS_RESULT-ZERP_MESSAGE = TEXT-E14. "스크랩 배부할 당월 생산오더 투입 건이 없습니다.
  ELSE.
    PS_RESULT-ZERP_MESSAGE = TEXT-E15. "잔량 배부할 당월 생산오더 투입 건이 없습니다.
  ENDIF.

  UPDATE ZGTPPT3450
     SET ZSTAT        = GS_SCRAP-ZRESULT
         ZMESSAGE     = GS_SCRAP-ZMESSAGE
         ZERP_STAT    = PS_RESULT-ZERP_STAT
         ZERP_MESSAGE = PS_RESULT-ZERP_MESSAGE
   WHERE ZIFKEY     EQ GS_SCRAP-ZIFKEY
     AND ZSYSTEM_ID EQ GS_SCRAP-ZSYSTEM_ID
     AND ZSERNO     EQ PS_SC-ZSERNO.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_CUTTING_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ZGTPPT3380
*&      --> IT_CUT_ITEM[]
*&      --> OT_CUT_RESULT[]
*&---------------------------------------------------------------------*
FORM SAVE_CUTTING_DATA  USING PS_ZGTPPT3380 TYPE ZGTPPT3380
                              PT_CUT_ITEM   TYPE TY_T_CUT_ITEM
                              PT_CUT_RESULT TYPE TY_T_CUT_RESULT.

  LOOP AT PT_CUT_RESULT ASSIGNING FIELD-SYMBOL(<FS_R>).
    <FS_R>-ZERP_STAT = 'S'.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_PARA_PHY_INV_SCAN_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_SCAN[]
*&      --> I_SYSTEM_ID
*&      --> ZO_RESULT
*&      --> ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM CHECK_PARA_PHY_INV_SCAN_LOG  TABLES PT_SCAN STRUCTURE ZGTPPSIF0073
                                   USING PV_SYSTEM_ID PV_RESULT PV_MESSAGE
                                 RAISING LCX_EXCEPTION.

*// 송신 시스템.
  IF PV_SYSTEM_ID IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F02.
  ENDIF.

  IF PT_SCAN[] IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F60.
  ENDIF.

  PV_RESULT  = ZGTPP_IF_CONST=>GC_IF_REC_RESULT-SUCCESS.
  PV_MESSAGE = TEXT-S01.

  GS_PHY_INV_SCAN_LOG = VALUE #( ZSYSTEM_ID = PV_SYSTEM_ID
                                 ZRESULT    = PV_RESULT
                                 ZMESSAGE   = PV_MESSAGE ).

  PERFORM CONV_PARA_PHY_INV_SCAN_LOG TABLES PT_SCAN.

  PERFORM CHK_PARA_VALI_PHY_INV_SCAN_LOG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_PARA_PHY_INV_SCAN_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SCAN
*&---------------------------------------------------------------------*
FORM CONV_PARA_PHY_INV_SCAN_LOG  TABLES   PT_SCAN STRUCTURE ZGTPPSIF0073.

  LOOP AT PT_SCAN INTO DATA(LS_SCAN).
    APPEND INITIAL LINE TO GS_PHY_INV_SCAN_LOG-ZGTPPT4160 REFERENCE INTO DATA(LR_ZGTPPT4160).

    LR_ZGTPPT4160->* = CORRESPONDING #( LS_SCAN ).

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_PARA_VALI_PHY_INV_SCAN_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_PARA_VALI_PHY_INV_SCAN_LOG RAISING LCX_EXCEPTION.

  DATA LT_T001W TYPE SORTED TABLE OF T001W WITH NON-UNIQUE KEY WERKS.
  DATA LT_T001L TYPE SORTED TABLE OF T001L WITH NON-UNIQUE KEY WERKS LGORT.

  SELECT WERKS INTO CORRESPONDING FIELDS OF TABLE @LT_T001W FROM T001W.

  SELECT WERKS, LGORT INTO CORRESPONDING FIELDS OF TABLE @LT_T001L FROM T001L.

  LOOP AT GS_PHY_INV_SCAN_LOG-ZGTPPT4160 INTO DATA(LS_ZGTPPT4160).
*// 재고실사년월.
    IF LS_ZGTPPT4160-INSMM IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F50.
    ENDIF.

*// 플랜트.
    IF LS_ZGTPPT4160-WERKS IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F04.
    ELSEIF NOT LINE_EXISTS( LT_T001W[ WERKS = LS_ZGTPPT4160-WERKS ] ).
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E011(VF) WITH LS_ZGTPPT4160-WERKS.
    ENDIF.

*// 저장위치.
    IF LS_ZGTPPT4160-LGORT IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F07.
    ELSEIF NOT LINE_EXISTS( LT_T001L[ WERKS = LS_ZGTPPT4160-WERKS
                                      LGORT = LS_ZGTPPT4160-LGORT ] ).
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E103(M3) WITH LS_ZGTPPT4160-LGORT LS_ZGTPPT4160-WERKS.
    ENDIF.

*//순번.
    IF LS_ZGTPPT4160-SEQ_ITEM IS INITIAL.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E031 WITH TEXT-F61.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_PHY_INV_SCAN_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_PHY_INV_SCAN_LOG RAISING LCX_EXCEPTION.

  TRY.
      MODIFY ZGTPPT4160 FROM TABLE GS_PHY_INV_SCAN_LOG-ZGTPPT4160.

      COMMIT WORK AND WAIT.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E05.
  ENDTRY.

ENDFORM.
