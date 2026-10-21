*&---------------------------------------------------------------------*
*& Include          ZGTPPR3180F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INITIALIZATION.

  GET PARAMETER ID 'WRK'  FIELD P_WERKS.
  GET PARAMETER ID 'ZSPG' FIELD P_SPGCD.

  DATA(LV_TO) = CL_RECA_DATE=>ADD_MONTHS_TO_DATE( ID_MONTHS = 1
                                                  ID_DATE   = SY-DATUM ).

  S_GSTRS[] = VALUE #( SIGN = 'I' OPTION = 'BT' ( LOW = SY-DATUM HIGH = LV_TO ) ) .
  S_EDATU[] = VALUE #( SIGN = 'I' OPTION = 'BT' ( LOW = SY-DATUM HIGH = LV_TO ) ) .

  PERFORM GET_PARAMETER_DESCRIPTION.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form start_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM START_OF_SELECTION.

  PERFORM GET_MASTER_DATA.

  IF P_REQUI EQ ABAP_TRUE.   "// 청구 생성.
    IF P_GNMAT EQ ABAP_TRUE. "// 일반자재.
      PERFORM GET_MAT_REQ_FROM_PRD_ORDER.
    ELSE.                    "// 포장자재.
      PERFORM GET_MAT_REQ_FROM_SALES_ORDER.
    ENDIF.
  ELSE.                      "// 청구 조회/변경.
    PERFORM GET_MAT_REQ_RESULT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form end_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM END_OF_SELECTION .

  PERFORM CALL_SCREEN_100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_exit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_EXIT .

  CASE SY-DYNNR.
    WHEN 100.
      PERFORM DEQUEUE_TABLE.

      IF GR_MREQ IS BOUND.
        GR_MREQ->FREE( ).
        CLEAR GR_MREQ.
      ENDIF.

      IF GR_LIST IS BOUND.
        GR_LIST->FREE( ).
        CLEAR GR_LIST.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN 200.
      LEAVE TO SCREEN 0.

    WHEN 300.
      LEAVE TO SCREEN 0.

    WHEN 400.
      IF GR_COMP IS BOUND.
        GR_COMP->FREE( ).
        CLEAR GR_COMP.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN 500.
      IF GR_SMRY IS BOUND.
        GR_SMRY->FREE( ).
        CLEAR GR_SMRY.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN 600.
      IF GR_SMRY IS BOUND.
        GR_SMRY->FREE( ).
        CLEAR GR_SMRY.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN 800.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirmation_popup
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONFIRMATION_POPUP USING PV_QUESTION PV_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR       = TEXT-C01
      TEXT_QUESTION  = PV_QUESTION
    IMPORTING
      ANSWER         = PV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_FIELD_CATALOG USING PR_SENDER.

  IF PR_SENDER EQ GR_MREQ.
    PERFORM MODIFY_FCAT_IN_MREQ.
  ENDIF.

  IF PR_SENDER EQ GR_LIST.
    PERFORM MODIFY_FCAT_IN_LIST.
  ENDIF.

  IF PR_SENDER EQ GR_COMP.
    PERFORM MODIFY_FCAT_IN_COMP.
  ENDIF.

  IF PR_SENDER EQ GR_SMRY.
    PERFORM MODIFY_FCAT_IN_SMRY.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_LAYOUT USING PR_SENDER.

  IF PR_SENDER EQ GR_MREQ.
    PERFORM SET_LAYOUT_IN_MREQ.
  ENDIF.

  IF PR_SENDER EQ GR_LIST.
    PERFORM SET_LAYOUT_IN_LIST.
  ENDIF.

  IF PR_SENDER EQ GR_SMRY.
    PERFORM SET_LAYOUT_IN_SMRY.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK USING PR_SENDER
                               PS_ROW    TYPE LVC_S_ROID
                               PS_COLUMN TYPE LVC_S_COL.

  IF GR_MREQ IS BOUND AND PR_SENDER EQ GR_MREQ->MR_GRID.
    PERFORM DOUBLE_CLICK_IN_MREQ USING PS_ROW PS_COLUMN.
  ENDIF.

  IF GR_LIST IS BOUND AND PR_SENDER EQ GR_LIST->MR_GRID.
    PERFORM DOUBLE_CLICK_IN_LIST USING PS_ROW PS_COLUMN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form at_selection_screen_output
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM AT_SELECTION_SCREEN_OUTPUT .

  PERFORM GET_PARAMETER_DESCRIPTION.

  LOOP AT SCREEN INTO DATA(LS_SCREEN).
    CASE LS_SCREEN-GROUP1.
      WHEN 'TXT'.
        LS_SCREEN-INTENSIFIED = 1.

      WHEN 'GR1'.
        IF NOT ( P_REQUI EQ ABAP_TRUE AND P_GNMAT EQ ABAP_TRUE ).
          LS_SCREEN-ACTIVE = 0.
        ENDIF.

      WHEN 'GR2'.
        IF NOT ( P_REQUI EQ ABAP_TRUE AND P_DRMAT EQ ABAP_TRUE ).
          LS_SCREEN-ACTIVE = 0.
        ENDIF.

      WHEN 'GR3'.
        IF NOT ( P_CHANGE EQ ABAP_TRUE ).
          LS_SCREEN-ACTIVE = 0.
        ENDIF.

      WHEN 'GR4'.
        IF P_CHANGE EQ ABAP_TRUE.
          LS_SCREEN-ACTIVE = 0.
        ENDIF.
    ENDCASE.

    MODIFY SCREEN FROM LS_SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form at_selection_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM AT_SELECTION_SCREEN .

  CASE SSCRFIELDS-UCOMM.
    WHEN GC_FCODE-ONLI. "// 실행.
      PERFORM CHECK_SEL_SCREEN_INPUT_VALUE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_sel_screen_input_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_SEL_SCREEN_INPUT_VALUE.

*// 플랜트.
  IF P_WERKS IS INITIAL.
    MESSAGE E164(M3) DISPLAY LIKE 'S'.
  ELSE.
    SELECT SINGLE @ABAP_TRUE
      INTO @DATA(LV_CHECK)
      FROM T001W
     WHERE WERKS EQ @P_WERKS.

    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E011(VF) WITH P_WERKS DISPLAY LIKE 'S'.
    ENDIF.
  ENDIF.

  IF P_SPGCD IS INITIAL.
    MESSAGE E031 WITH TEXT-F03 DISPLAY LIKE 'S'.
  ELSE.
    SELECT SINGLE @ABAP_TRUE
      INTO @LV_CHECK
      FROM ZPPT0107
     WHERE WERKS EQ @P_WERKS
       AND SPGCD EQ @P_SPGCD.

    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E000 WITH TEXT-E05 DISPLAY LIKE 'S'.
    ENDIF.
  ENDIF.

  PERFORM ENQUEUE_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_screen_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_100 .
  DATA LV_TITLE TYPE STRING.

  IF P_REQUI EQ ABAP_TRUE.
    LV_TITLE = TEXT-C11.

    IF P_GNMAT EQ ABAP_TRUE.
      LV_TITLE = |{ LV_TITLE }/{ TEXT-C15 }|.
    ELSE.
      LV_TITLE = |{ LV_TITLE }/{ TEXT-C16 }|.
    ENDIF.
  ELSE.
    LV_TITLE = TEXT-C12.
  ENDIF.

  GV_TPAR1 = |{ LV_TITLE }|.

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK USING PR_SENDER
                                PS_ROW    TYPE LVC_S_ROID
                                PS_COLUMN TYPE LVC_S_COL.

  IF GR_MREQ IS BOUND AND PR_SENDER EQ GR_MREQ->MR_GRID.
    PERFORM HOTSPOT_CLICK_IN_MREQ USING PS_ROW PS_COLUMN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mat_req_from_prd_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MAT_REQ_FROM_PRD_ORDER .

  PERFORM SELECT_MAT_REQ_FROM_PRD_ORDER.
  PERFORM ADJUST_MAT_REQ_BASED_PRD_ORDER.
  PERFORM GET_MAT_REQ_RESULT_FROM_PRD.

  SORT GT_PROD BY WERKS SPGCD ORDNO ORDPO GRPNR.

  GR_DATA = REF #( GT_PROD ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_mat_req_from_prd_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SELECT_MAT_REQ_FROM_PRD_ORDER .
  DATA LT_DISPO TYPE RANGE OF MARC-DISPO.
  DATA : LT_PLNUM TYPE RANGE OF PLNUM.

  IF P_SPGCD IS NOT INITIAL.
    LT_DISPO = VALUE #( ( SIGN = 'I' OPTION = 'CP' LOW = |{ P_SPGCD+(2) }*| ) ).
  ENDIF.

*// 생산오더 자재 예약.
  IF S_AUFNR[] IS NOT INITIAL OR ( S_AUFNR[] IS INITIAL AND S_PLNUM[] IS INITIAL ).
    IF P_SPGCD NE 'GL'.
      SELECT AFKO~AUFNR  AS ORDNR,
             AFKO~PLNBEZ AS MATNR, MAKT~MAKTX, AFKO~DISPO,
             AFKO~GSTRS  AS PLDAT,
             AUFK~ZZKDAUF, AUFK~ZZKDPOS,
             RESB~WERKS, RESB~RSNUM, RESB~RSPOS, RESB~MATNR AS IDNRK,
             RESB~BDMNG, RESB~MEINS, RESB~BDTER, RESB~AUSCH,
             MARC~LGFSB,
             MAKT2~MAKTX AS IDNTX,
             SUBSTRING( AFKO~DISPO,1, 2 ) AS SPGCD,
             @GC_ORDTY-PRD AS ORDTY
        FROM AFKO
        JOIN AUFK
          ON AFKO~AUFNR EQ AUFK~AUFNR
        JOIN ZGTPPT2010                               "2026.06.26 KSW 추가
          ON AUFK~AUFNR EQ ZGTPPT2010~ORDNR  "2026.06.26 KSW 추가
        JOIN RESB
          ON AFKO~AUFNR EQ RESB~AUFNR
        JOIN MARA
          ON RESB~MATNR EQ MARA~MATNR
        JOIN MARC
          ON RESB~MATNR EQ MARC~MATNR
         AND RESB~WERKS EQ MARC~WERKS
        LEFT JOIN MAKT
          ON AFKO~PLNBEZ EQ MAKT~MATNR
         AND MAKT~SPRAS  EQ @SY-LANGU
        LEFT JOIN MAKT AS MAKT2
          ON RESB~MATNR  EQ MAKT2~MATNR
         AND MAKT2~SPRAS EQ @SY-LANGU
       WHERE RESB~WERKS EQ @P_WERKS
         AND RESB~KZKUP NE @ABAP_TRUE   "// 연산품
         AND RESB~SCHGT NE @ABAP_TRUE   "// Bulk자재
         AND RESB~DUMPS NE @ABAP_TRUE   "// 가상품목
         AND AFKO~DISPO IN @LT_DISPO
         AND AFKO~GSTRS IN @S_GSTRS
         AND AFKO~AUFNR IN @S_AUFNR
         AND MARA~MTART NOT IN @GT_MTART
         AND ZGTPPT2010~GRPNR IN @S_GRPNR     "2026.06.26 KSW 추가
        INTO CORRESPONDING FIELDS OF TABLE @GT_PROD.
    ELSE.
      SELECT AFKO~AUFNR  AS ORDNR,
             AFKO~PLNBEZ AS MATNR, MAKT~MAKTX, AFKO~DISPO,
             AFKO~GSTRS  AS PLDAT,
             AUFK~ZZKDAUF, AUFK~ZZKDPOS,
             RESB~WERKS, RESB~RSNUM, RESB~RSPOS, RESB~MATNR AS IDNRK,
             RESB~BDMNG, RESB~MEINS, RESB~BDTER, RESB~AUSCH,
             MARC~LGFSB,
             MAKT2~MAKTX AS IDNTX,
             SUBSTRING( AFKO~DISPO,1, 2 ) AS SPGCD,
             @GC_ORDTY-PRD AS ORDTY
        FROM AFKO
        JOIN AUFK
          ON AFKO~AUFNR EQ AUFK~AUFNR
*        JOIN ZGTPPT2010                               "2026.06.26 KSW 추가
*          ON AUFK~AUFNR EQ ZGTPPT2010~ORDNR  "2026.06.26 KSW 추가
        JOIN RESB
          ON AFKO~AUFNR EQ RESB~AUFNR
        JOIN MARA
          ON RESB~MATNR EQ MARA~MATNR
        JOIN MARC
          ON RESB~MATNR EQ MARC~MATNR
         AND RESB~WERKS EQ MARC~WERKS
        LEFT JOIN MAKT
          ON AFKO~PLNBEZ EQ MAKT~MATNR
         AND MAKT~SPRAS  EQ @SY-LANGU
        LEFT JOIN MAKT AS MAKT2
          ON RESB~MATNR  EQ MAKT2~MATNR
         AND MAKT2~SPRAS EQ @SY-LANGU
       WHERE RESB~WERKS EQ @P_WERKS
         AND RESB~KZKUP NE @ABAP_TRUE   "// 연산품
         AND RESB~SCHGT NE @ABAP_TRUE   "// Bulk자재
         AND RESB~DUMPS NE @ABAP_TRUE   "// 가상품목
         AND AFKO~DISPO IN @LT_DISPO
         AND AFKO~GSTRS IN @S_GSTRS
         AND AFKO~AUFNR IN @S_AUFNR
         AND MARA~MTART NOT IN @GT_MTART
        INTO CORRESPONDING FIELDS OF TABLE @GT_PROD.
    ENDIF.
  ENDIF.

*// 계획오더 자재 예약.
  IF S_PLNUM[] IS NOT INITIAL OR ( S_AUFNR[] IS INITIAL AND S_PLNUM[] IS INITIAL ).
    IF P_SPGCD NE 'GL'.
      SELECT PLAF~PLNUM AS ORDNR,
             PLAF~MATNR, MAKT~MAKTX, PLAF~DISPO,
             PLAF~PSTTR AS PLDAT,
             RESB~WERKS, RESB~RSNUM, RESB~RSPOS, RESB~MATNR AS IDNRK,
             RESB~BDMNG, RESB~MEINS, RESB~BDTER, RESB~AUSCH,
             MARC~LGFSB,
             MAKT2~MAKTX AS IDNTX,
             SUBSTRING( PLAF~DISPO,1, 2 ) AS SPGCD,
             @GC_ORDTY-PLN AS ORDTY,
             '계획오더' AS GUBUN
        FROM PLAF
        JOIN ZGTPPT2010                               "2026.06.26 KSW 추가
          ON PLAF~PLNUM EQ ZGTPPT2010~ORDNR  "2026.06.26 KSW 추가
        JOIN RESB
          ON PLAF~PLNUM EQ RESB~PLNUM
        JOIN MARA
          ON RESB~MATNR EQ MARA~MATNR
        JOIN MARC
          ON RESB~MATNR EQ MARC~MATNR
         AND RESB~WERKS EQ MARC~WERKS
        LEFT JOIN MAKT
          ON PLAF~MATNR EQ MAKT~MATNR
         AND MAKT~SPRAS EQ @SY-LANGU
        LEFT JOIN MAKT AS MAKT2
          ON RESB~MATNR  EQ MAKT2~MATNR
         AND MAKT2~SPRAS EQ @SY-LANGU
       WHERE RESB~WERKS EQ @P_WERKS
         AND RESB~KZKUP NE @ABAP_TRUE   "// 연산품
         AND RESB~SCHGT NE @ABAP_TRUE   "// Bulk자재
         AND RESB~DUMPS NE @ABAP_TRUE   "// 가상품목
         AND PLAF~DISPO IN @LT_DISPO
         AND PLAF~PSTTR IN @S_GSTRS
         AND PLAF~PLNUM IN @S_PLNUM
         AND MARA~MTART NOT IN @GT_MTART
         AND ZGTPPT2010~GRPNR IN @S_GRPNR     "2026.06.26 KSW 추가
        APPENDING CORRESPONDING FIELDS OF TABLE @GT_PROD.
    ENDIF.
    IF P_SPGCD EQ 'GL' OR P_SPGCD EQ 'GO'.
* 반제품 계획건 대상으로
      PERFORM GET_PLAN_2330.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form adjust_mat_req_based_prd_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ADJUST_MAT_REQ_BASED_PRD_ORDER .
  DATA LT_ZGTPPT3421 TYPE TY_T_ZGTPPT3421.
  DATA LT_ZGTPPT2010 TYPE TY_T_ZGTPPT2010.
  DATA LT_ZGTPPT2340 TYPE TY_T_ZGTPPT2340.
  DATA LT_ORDSYVAL   TYPE TY_T_ORDSYVAL.
  DATA LT_VBEP TYPE TY_T_VBEP.

  PERFORM GET_DATA_REF_PRD_ORDER USING LT_ZGTPPT3421 LT_VBEP LT_ORDSYVAL
                                       LT_ZGTPPT2010 LT_ZGTPPT2340.

* 기존 청구된 자재를 조장, 자재 단위로 가져와 기청구된 내용인지 확인
  PERFORM GET_REQ_RESULT.

  LOOP AT GT_PROD REFERENCE INTO DATA(LR_PROD).
    IF LR_PROD->ORDTY = 'PRD'.
      READ TABLE LT_ORDSYVAL INTO DATA(LS_ORDSYVAL) WITH KEY AUFNR = LR_PROD->ORDNR BINARY SEARCH.
      IF SY-SUBRC NE 0.
        DELETE GT_PROD.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF LR_PROD->MEINS EQ ZGTPP_IF_CONST=>GC_MEINS-G.
      LR_PROD->BDMNG = ROUND( VAL  = ( LR_PROD->BDMNG / 1000 )
                              PREC = 3
                              MODE = CL_ABAP_MATH=>ROUND_HALF_UP ).
      LR_PROD->MEINS = ZGTPP_IF_CONST=>GC_MEINS-G.
    ENDIF.

    IF LR_PROD->AUSCH IS NOT INITIAL.
      LR_PROD->REQMN = LR_PROD->BDMNG / ( 1 + LR_PROD->AUSCH / 100 ).
    ELSE.
      LR_PROD->REQMN = LR_PROD->BDMNG.
    ENDIF.

*// 계획오더 -> 생산오더 전환된 오더 중에서 계획오더에서 생성한 자재청구 제외.
    IF LR_PROD->ORDTY EQ GC_ORDTY-PRD.
      READ TABLE GT_2340 TRANSPORTING NO FIELDS WITH KEY WERKS = LR_PROD->WERKS
                                                               SPGCD = LR_PROD->SPGCD
                                                               ORDNR = LR_PROD->ORDNR
                                                               MATNR = LR_PROD->MATNR.
      IF SY-SUBRC IS INITIAL.
        DELETE GT_PROD.
        CONTINUE.
      ENDIF.
    ENDIF.

    LR_PROD->STATUS = ICON_LIGHT_OUT.

    READ TABLE LT_ZGTPPT2010 INTO DATA(LS_ZGTPPT2010) WITH KEY ORDNR = LR_PROD->ORDNR BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      LR_PROD->GRPNR = LS_ZGTPPT2010-GRPNR.
      LR_PROD->ORDNO = LS_ZGTPPT2010-ORDNO.
      LR_PROD->ORDPO = LS_ZGTPPT2010-POSNR.
      LR_PROD->KUNNR = LS_ZGTPPT2010-KUNNR.
      LR_PROD->NAME1 = LS_ZGTPPT2010-NAME1.

      LR_PROD->GUBUN = COND #( WHEN LS_ZGTPPT2010-GCATG IS NOT INITIAL THEN LS_ZGTPPT2010-GCATG
                               WHEN LS_ZGTPPT2010-GCATG IS INITIAL AND LR_PROD->ORDTY EQ GC_ORDTY-PRD THEN GC_GCATG-PLANED_ORDER ).

      READ TABLE LT_VBEP INTO DATA(LS_VBEP) WITH KEY VBELN = LR_PROD->ORDNO
                                                     POSNR = LR_PROD->ORDPO BINARY SEARCH.

      IF SY-SUBRC IS INITIAL.
        LR_PROD->EDATU = LS_VBEP-EDATU.
      ENDIF.
    ELSE.
      IF LR_PROD->GUBUN IS INITIAL.
        LR_PROD->GUBUN = GC_GCATG-MANUAL_ORDER.
      ENDIF.

      IF LR_PROD->ORDTY EQ GC_ORDTY-PRD AND LR_PROD->ORDNO IS INITIAL.
        LR_PROD->ORDNO = LR_PROD->ZZKDAUF.
        LR_PROD->ORDPO = LR_PROD->ZZKDPOS.
      ENDIF.
    ENDIF.

    IF LR_PROD->ORDTY EQ GC_ORDTY-PRD.
      READ TABLE LT_ORDSYVAL INTO LS_ORDSYVAL WITH KEY AUFNR = LR_PROD->ORDNR BINARY SEARCH.
      IF SY-SUBRC IS INITIAL.
        LR_PROD->PDCAPROCCODE = LS_ORDSYVAL-PDCAPROCCODE.
      ENDIF.
    ENDIF.

    READ TABLE LT_ZGTPPT3421 INTO DATA(LS_ZGTPPT3421) WITH KEY RSNUM = LR_PROD->RSNUM
                                                               RSPOS = LR_PROD->RSPOS BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      LR_PROD->REQNO  = LS_ZGTPPT3421-REQNO.
      LR_PROD->POSNR  = LS_ZGTPPT3421-POSNR.
      LR_PROD->REQDAT = LS_ZGTPPT3421-BDTER.
      LR_PROD->STATUS = ICON_GREEN_LIGHT.
      LR_PROD->STYLE  = GT_STYLE.
    ENDIF.

* 기존 청구된 이력 찾는 로직 추가
    IF NOT ( P_WERKS = '6600' AND P_SPGCD = 'GL' ) AND LR_PROD->STATUS NE ICON_GREEN_LIGHT AND
      LR_PROD->GRPNR IS NOT INITIAL.

      READ TABLE GT_3421 INTO DATA(LS_3421) WITH KEY MATNR = LR_PROD->IDNRK
                                                     GRPNR = LR_PROD->GRPNR.
      IF SY-SUBRC EQ 0.
        LR_PROD->REQNO  = LS_3421-REQNO.
        LR_PROD->POSNR  = LS_3421-POSNR.
        LR_PROD->REQDAT = LS_3421-BDTER.
        LR_PROD->STATUS = ICON_GREEN_LIGHT.
        LR_PROD->STYLE  = GT_STYLE.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF GT_PROD3[] IS NOT INITIAL.
    APPEND LINES OF GT_PROD3 TO GT_PROD.
  ENDIF.

  IF P_UNREQ EQ ABAP_TRUE. "// 미청구건 조회.
    DELETE GT_PROD WHERE EXCEPT EQ ABAP_TRUE
                      OR STATUS EQ ICON_GREEN_LIGHT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mat_req_from_sales_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MAT_REQ_FROM_SALES_ORDER .

  PERFORM GET_TARGET_SALES_ORDER.
  IF P_SPGCD = 'GL'.
    PERFORM GET_SO_CHARACTERISTIC_GL.
  ELSE.
    PERFORM GET_SALES_ORDER_CHARACTERISTIC.
  ENDIF.
  PERFORM GET_MAT_REQ_RESULT_FROM_SLS.

  SORT GT_SALES BY WERKS SPGCD VBELN VBELP PACK_MAT.
  GR_DATA = REF #( GT_SALES ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_fcat_for_prod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BUILD_FCAT_FOR_PROD .

  LOOP AT GR_MREQ->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'SEL'.
        LR_FCAT->COLTEXT    = TEXT-F31.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->CHECKBOX   = ABAP_TRUE.
        LR_FCAT->HOTSPOT    = ABAP_TRUE.
        LR_FCAT->FIX_COLUMN = ABAP_TRUE.

      WHEN 'EXREQ'.
        LR_FCAT->COLTEXT    = TEXT-F26.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->CHECKBOX   = ABAP_TRUE.
        LR_FCAT->HOTSPOT    = ABAP_TRUE.
        LR_FCAT->FIX_COLUMN = ABAP_TRUE.

      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-F01.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->FIX_COLUMN = ABAP_TRUE.

      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-F02.
        LR_FCAT->CHECKTABLE = SPACE.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'SPGCD'.
        LR_FCAT->COLTEXT    = TEXT-F03.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'ORDNO'.
        LR_FCAT->COLTEXT    = TEXT-F04.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'KUNNR'.
        LR_FCAT->COLTEXT    = TEXT-F05.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'NAME1'.
        LR_FCAT->COLTEXT    = TEXT-F06.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F07.
        LR_FCAT->FIX_COLUMN = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F08.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'EDATU'.
        LR_FCAT->COLTEXT    = TEXT-F09.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ORDNR'.
        LR_FCAT->COLTEXT    = TEXT-F10.
        LR_FCAT->CONVEXIT   = 'ALPHA'.
        LR_FCAT->EMPHASIZE  = 'C300'.

      WHEN 'PDCAPROCCODE'.
        LR_FCAT->COLTEXT    = TEXT-F11.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C300'.

      WHEN 'GUBUN'.
        LR_FCAT->COLTEXT    = TEXT-F12.
        LR_FCAT->EMPHASIZE  = 'C300'.

      WHEN 'PLDAT'.
        LR_FCAT->COLTEXT    = TEXT-F13.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C300'.

      WHEN 'GRPNR'.
        LR_FCAT->COLTEXT    = TEXT-F14.
        LR_FCAT->EMPHASIZE  = 'C300'.

      WHEN 'RSNUM'.
        LR_FCAT->COLTEXT    = TEXT-F15.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'RSPOS'.
        LR_FCAT->COLTEXT    = TEXT-F16.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'BDTER'.
        LR_FCAT->COLTEXT    = TEXT-F81.
        LR_FCAT->EMPHASIZE  = 'C700'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'IDNRK'.
        LR_FCAT->COLTEXT    = TEXT-F17.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'IDNTX'.
        LR_FCAT->COLTEXT    = TEXT-F18.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'BDMNG'.
        LR_FCAT->COLTEXT    = TEXT-F19.
        LR_FCAT->EDIT       = ABAP_TRUE.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F20.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->JUST       = 'C'.

      WHEN 'AUSCH'.
        LR_FCAT->COLTEXT    = TEXT-F29.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

*      WHEN 'REQDAT'.
*        lr_fcat->coltext    = TEXT-f21.
*        lr_fcat->edit       = abap_true.
*        lr_fcat->just       = 'C'.
*
*      WHEN 'LGORT'.
*        lr_fcat->coltext    = TEXT-f22.
*        lr_fcat->edit       = abap_true.
*        lr_fcat->checktable = space.
*        lr_fcat->just       = 'C'.

      WHEN 'MESSAGE'.
        LR_FCAT->COLTEXT    = TEXT-F23.

      WHEN 'REQNO'.
        LR_FCAT->COLTEXT    = TEXT-F24.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'POSNR'.
        LR_FCAT->COLTEXT    = TEXT-F25.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'RQMON'.
        LR_FCAT->COLTEXT    = TEXT-F27.
        LR_FCAT->JUST       = 'C'.
        CASE P_SPGCD.
          WHEN 'GL' OR 'GO'.
          WHEN OTHERS.
            LR_FCAT->TECH = ABAP_TRUE.
        ENDCASE.

      WHEN 'ZWKREQ'.
        LR_FCAT->COLTEXT    = TEXT-F28.
        LR_FCAT->JUST       = 'C'.
        CASE P_SPGCD.
          WHEN 'GL' OR 'GO'.
          WHEN OTHERS.
            LR_FCAT->TECH = ABAP_TRUE.
        ENDCASE.

      WHEN 'ORDNR_I'.
        LR_FCAT->COLTEXT    = TEXT-F93.
        LR_FCAT->JUST       = 'C'.
        CASE P_SPGCD.
          WHEN 'GL' OR 'GO'.
          WHEN OTHERS.
            LR_FCAT->TECH = ABAP_TRUE.
        ENDCASE.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_fcat_for_SALES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BUILD_FCAT_FOR_SALES .

  LOOP AT GR_MREQ->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'SEL'.
        LR_FCAT->COLTEXT    = TEXT-F31.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->CHECKBOX   = ABAP_TRUE.
        LR_FCAT->HOTSPOT    = ABAP_TRUE.
        LR_FCAT->FIX_COLUMN = ABAP_TRUE.

      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-F32.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->FIX_COLUMN = ABAP_TRUE.

      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-F33.
        LR_FCAT->CHECKTABLE = SPACE.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'SPGCD'.
        LR_FCAT->COLTEXT    = TEXT-F34.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'VBELN'.
        LR_FCAT->COLTEXT    = TEXT-F35.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'VBELP'.
        LR_FCAT->COLTEXT    = TEXT-F36.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'KUNNR'.
        LR_FCAT->COLTEXT    = TEXT-F37.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'NAME1'.
        LR_FCAT->COLTEXT    = TEXT-F38.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F07.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F08.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'EDATU'.
        LR_FCAT->COLTEXT    = TEXT-F41.
        LR_FCAT->JUST       = 'C'.

      WHEN 'PACK_MAT'.
        LR_FCAT->COLTEXT    = TEXT-F42.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'PACK_MAT_TXT'.
        LR_FCAT->COLTEXT    = TEXT-F43.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'NEWDRUM'.
        LR_FCAT->COLTEXT    = TEXT-F44.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'IRONDRUM'.
        LR_FCAT->COLTEXT    = TEXT-F45.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'DRUMTITLEMARK'.
        LR_FCAT->COLTEXT    = TEXT-F46.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'FLANGE_PROT'.
        LR_FCAT->COLTEXT    = TEXT-F47.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'HANJEON'.
        LR_FCAT->COLTEXT    = TEXT-F48.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'PACK_METHOD'.
        LR_FCAT->COLTEXT    = TEXT-F71.
        LR_FCAT->JUST       = 'C'.

      WHEN 'PACK_TXT'.
        LR_FCAT->COLTEXT    = TEXT-F72.

      WHEN 'DRUM_CNT'.
        LR_FCAT->COLTEXT    = TEXT-F49.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F50.
        LR_FCAT->JUST       = 'C'.

      WHEN 'SKID_YN'.
        LR_FCAT->COLTEXT    = TEXT-F73.

      WHEN 'PW_FACTOR'.
        LR_FCAT->COLTEXT    = TEXT-F74.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'DRUM_GUBUN'.
        LR_FCAT->COLTEXT    = TEXT-F75.

      WHEN 'HAWA_GUBUN'.
        LR_FCAT->COLTEXT    = TEXT-F76.

      WHEN 'PRINT_METHOD'.
        LR_FCAT->COLTEXT    = TEXT-F77.

      WHEN 'REQDAT'.
        LR_FCAT->COLTEXT    = TEXT-F51.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EDIT       = ABAP_TRUE.

      WHEN 'LGPRO'.
        LR_FCAT->COLTEXT    = TEXT-F52.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EDIT       = ABAP_TRUE.

      WHEN 'MESSAGE'.
        LR_FCAT->COLTEXT    = TEXT-F53.

      WHEN 'REQNO'.
        LR_FCAT->COLTEXT    = TEXT-F54.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'POSNR'.
        LR_FCAT->COLTEXT    = TEXT-F55.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'BANFN'.
        LR_FCAT->COLTEXT    = TEXT-F56.
        LR_FCAT->JUST       = 'C'.

      WHEN 'BNFPO'.
        LR_FCAT->COLTEXT    = TEXT-F57.
        LR_FCAT->JUST       = 'C'.

      WHEN 'GRPNR'.
        LR_FCAT->COLTEXT    = TEXT-F82.
        LR_FCAT->JUST       = 'L'.
        IF P_REQUI = ABAP_TRUE AND P_DRMAT = ABAP_TRUE AND P_SPGCD NE 'GL'.
        ELSE.
          LR_FCAT->TECH = ABAP_TRUE.
        ENDIF.

      WHEN 'INFACTOR'.
        LR_FCAT->COLTEXT    = TEXT-F83.
        LR_FCAT->JUST       = 'R'.
        IF P_REQUI = ABAP_TRUE AND P_DRMAT = ABAP_TRUE AND P_SPGCD NE 'GL'.
        ELSE.
          LR_FCAT->TECH = ABAP_TRUE.
        ENDIF.

      WHEN 'ICON_ORDER'.
        LR_FCAT->COLTEXT    = TEXT-F84.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->ICON       = ABAP_TRUE.
        IF P_REQUI = ABAP_TRUE AND P_DRMAT = ABAP_TRUE AND P_SPGCD NE 'GL'.
        ELSE.
          LR_FCAT->TECH = ABAP_TRUE.
        ENDIF.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_target_sales_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_TARGET_SALES_ORDER .
  DATA LT_DISPO TYPE RANGE OF MARC-DISPO.
*  구매조직 관련 스트럭처
  DATA : BEGIN OF LS_EKORG,
           WEREKS TYPE WERKS_D,
           EKORG  TYPE EKORG,
           EKGRP  TYPE EKGRP,
         END OF LS_EKORG.
  DATA : LV_CHK_EXISTS.

  CLEAR GT_PACK_MAT.

  IF P_SPGCD IS NOT INITIAL.
    LT_DISPO = VALUE #( ( SIGN = 'I' OPTION = 'CP' LOW = |{ P_SPGCD+(2) }*| ) ).
  ENDIF.

  SELECT VBAP~WERKS, VBAP~MATNR, VBAP~VBELN, VBAP~POSNR AS VBELP,
         VBEP~EDATU, VBPA~KUNNR, KNA1~NAME1,
         SUBSTRING( MARC~DISPO,1, 2 ) AS SPGCD,
         CASE WHEN KNA1~KDKG4 EQ '30A' OR KNA1~KDKG4 EQ '31A' OR KNA1~KDKG4 EQ '32A' OR KNA1~KDKG4 EQ '33A' OR
                   KNA1~KDKG4 EQ '34A' OR KNA1~KDKG4 EQ '35A' OR KNA1~KDKG4 EQ '36A' THEN 'Y'
              ELSE 'N'
         END AS HANJEON,
         MAKT~MAKTX
    FROM VBAK
    JOIN VBAP
      ON VBAK~VBELN EQ VBAP~VBELN
    JOIN VBEP
      ON VBAP~VBELN EQ VBEP~VBELN
     AND VBAP~POSNR EQ VBEP~POSNR
    JOIN VBPA
      ON VBAK~VBELN EQ VBPA~VBELN
     AND VBPA~POSNR EQ '000000'
     AND VBPA~PARVW EQ 'WE'
    JOIN MARC
      ON VBAP~MATNR EQ MARC~MATNR
     AND VBAP~WERKS EQ MARC~WERKS
    LEFT JOIN KNA1
      ON VBPA~KUNNR EQ KNA1~KUNNR
    LEFT JOIN MAKT
      ON VBAP~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   WHERE VBAK~VBELN IN @S_VBELN
     AND VBAP~WERKS EQ @P_WERKS
     AND VBEP~EDATU IN @S_EDATU
     AND VBPA~KUNNR IN @S_KUNNR
     AND MARC~DISPO IN @LT_DISPO
   ORDER BY VBAP~WERKS, VBAP~MATNR, VBAP~VBELN, VBAP~POSNR, VBEP~EDATU DESCENDING
    INTO CORRESPONDING FIELDS OF TABLE @GT_SALES.

* OEM대상 제외로직 추가
  DATA(LT_SALES) = GT_SALES[].
  SORT LT_SALES BY VBELN VBELP.
  DELETE ADJACENT DUPLICATES FROM LT_SALES COMPARING VBELN VBELP.

  IF LT_SALES[] IS NOT INITIAL.
    SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
      FROM ZGTPPT1010
      INTO @LS_EKORG
     WHERE MODULE_KIND = 'PP'
       AND CODEGRP = '2090'
       AND FLD_01 = ' '
       AND FLD_02 = @P_WERKS.

* 범주 판매오더의 OEM 구매요청 확인
    SELECT A~BANFN, A~BNFPO, A~LFDAT, A~STATU, B~VBELN, B~VBELP, A~LIFNR, C~NAME1
      FROM EBAN AS A
      INNER JOIN EBKN AS B ON B~BANFN = A~BANFN
                                AND B~BNFPO = A~BNFPO
      LEFT JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
      FOR ALL ENTRIES IN @LT_SALES
     WHERE B~VBELN =  @LT_SALES-VBELN
        AND B~VBELP =  @LT_SALES-VBELP
        AND A~MATNR =  @LT_SALES-MATNR
        AND A~WERKS =  @P_WERKS
        AND A~BSTYP = 'B'
        AND A~EKORG = @LS_EKORG-EKORG
        AND A~EKGRP = @LS_EKORG-EKGRP
        AND A~LOEKZ = ''
      INTO TABLE @DATA(LT_EBAN).

    SELECT DISTINCT A~VBELN, A~VBELP, C~LIFNR, A~EBELN, A~EBELP, B~BANFN, B~BNFPO, D~NAME1
      FROM EKKN AS A
      INNER JOIN EKPO AS B ON B~EBELN = A~EBELN
                          AND B~EBELP = A~EBELP
      INNER JOIN EKKO AS C ON C~EBELN = A~EBELN
      INNER JOIN LFA1 AS D ON D~LIFNR = C~LIFNR
      INNER JOIN @LT_SALES AS E ON E~VBELN = A~VBELN
                                         AND E~VBELP = A~VBELP
                                         AND E~MATNR = B~MATNR
     WHERE B~LOEKZ = ''
      INTO TABLE @DATA(LT_EKKO).

    SORT LT_EBAN BY VBELN VBELP.
    SORT LT_EKKO BY VBELN VBELP.

    LOOP AT GT_SALES ASSIGNING FIELD-SYMBOL(<LS_DEL_CHK>).
      READ TABLE  LT_EBAN INTO DATA(LS_EBAN) WITH KEY VBELN = <LS_DEL_CHK>-VBELN
                                                                   VBELP = <LS_DEL_CHK>-VBELP
                                                                   BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        DELETE GT_SALES.
        CONTINUE.
      ENDIF.

*      READ TABLE LT_EKKO INTO DATA(LS_EKKO) WITH KEY VBELN = <LS_DEL_CHK>-VBELN
*                                                                            VBELP = <LS_DEL_CHK>-VBELP
*                                                                            BINARY SEARCH.
*      IF SY-SUBRC EQ 0.
*        DELETE GT_SALES.
*        CONTINUE.
*      ENDIF.
    ENDLOOP.
  ENDIF.


  CASE P_SPGCD.
    WHEN 'GL'.
    WHEN OTHERS.
      SORT GT_SALES BY VBELN VBELP.

      IF GT_SALES[] IS NOT INITIAL.
        SELECT DISTINCT B~*
          FROM @GT_SALES AS A
          INNER JOIN ZGTPPT2000 AS B ON B~ORDNO = A~VBELN
                                    AND B~POSNR = A~VBELP
          WHERE B~GCATG NE '생산오더'
              AND B~ZSTATUS NE 'D'
            INTO TABLE @GT_2000_FUL.

        SORT GT_2000_FUL BY ORDNO POSNR.

        SELECT DISTINCT B~*
          FROM @GT_SALES AS A
          INNER JOIN ZGTPPT2010 AS B ON B~DMORD = A~VBELN
                                    AND B~DMLINE = A~VBELP
          WHERE B~DMORDTY NE '생산오더'
            INTO TABLE @GT_2010.

        SORT GT_2010 BY DMORD DMLINE.

        LOOP AT GT_SALES ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
          LOOP AT GT_2000_FUL INTO DATA(LS_2000) WHERE ORDNO = <LS_MAIN>-VBELN
                                               AND POSNR = <LS_MAIN>-VBELP.
            IF <LS_MAIN>-GRPNR IS INITIAL.
              <LS_MAIN>-GRPNR = LS_2000-GRPNR.
            ELSE.
              <LS_MAIN>-GRPNR = <LS_MAIN>-GRPNR && ',' && LS_2000-GRPNR.
            ENDIF.

            ADD LS_2000-INFACTOR TO <LS_MAIN>-INFACTOR.
          ENDLOOP.

        ENDLOOP.

        IF S_GRPNR2[] IS NOT INITIAL.
          SELECT * FROM ZGTPPT2000
            WHERE GRPNR IN @S_GRPNR2
              AND GCATG NE '생산오더'
              AND ZSTATUS NE 'D'
            INTO TABLE @GT_2000.
          LOOP AT GT_SALES ASSIGNING <LS_MAIN>.
            CLEAR LV_CHK_EXISTS.
            LOOP AT GT_2000 INTO LS_2000 WHERE ORDNO = <LS_MAIN>-VBELN
                                           AND POSNR = <LS_MAIN>-VBELP.
              IF LV_CHK_EXISTS IS INITIAL.
                LV_CHK_EXISTS = ABAP_TRUE.
                EXIT.
              ENDIF.
            ENDLOOP.

            IF LV_CHK_EXISTS IS INITIAL.
              DELETE GT_SALES.
              CONTINUE.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
  ENDCASE.

  DELETE ADJACENT DUPLICATES FROM GT_SALES COMPARING WERKS MATNR VBELN VBELP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_sales_order_characteristic
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_SALES_ORDER_CHARACTERISTIC.
  DATA LT_CHAR TYPE TY_T_CHAR.
  DATA LT_PACKING_MAT TYPE TY_T_PACKING_MAT.
  DATA LT_ZGTPPT3422 TYPE TY_T_ZGTPPT3422.
  DATA : LT_MAIN LIKE GT_SALES.
  DATA : LV_IDX TYPE I.
  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : BEGIN OF LS_CHK_MATNR_DM,
           MATNR_DM TYPE MATNR,
           MENGE    TYPE MENGE_D,
         END OF LS_CHK_MATNR_DM.
  DATA : LT_CHK_MATNR_DM LIKE TABLE OF LS_CHK_MATNR_DM.

  PERFORM GET_DATA_REF_SALES USING LT_CHAR LT_PACKING_MAT LT_ZGTPPT3422.

  LOOP AT GT_SALES REFERENCE INTO DATA(LR_SALES).
    LR_SALES->* = VALUE #( BASE LR_SALES->*  STATUS = ICON_LIGHT_OUT
                                             EXCEPT = ABAP_TRUE ).
*// 포장 자재 속성.
    PERFORM SET_PACKAGING_MAT_CHAR USING LR_SALES->* LT_CHAR LT_PACKING_MAT.
  ENDLOOP.

  LT_MAIN = GT_SALES.
  SORT LT_MAIN BY VBELN VBELP.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN COMPARING VBELN VBELP.

  REFRESH GT_SALES.

  LOOP AT LT_MAIN INTO DATA(LS_MAIN).
    REFRESH LT_2010.
    REFRESH LT_CHK_MATNR_DM.

    LT_2010 = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( DMORD = LS_MAIN-VBELN
                                                AND   DMLINE = LS_MAIN-VBELP )
                     ( CORRESPONDING #( LW_2010 ) ) ).

    IF LT_2010 IS INITIAL.
      APPEND LS_MAIN TO GT_SALES.
    ELSE.
      LOOP AT LT_2010 INTO DATA(LS_2010).
        IF LS_2010-MATNR_DM IS NOT INITIAL.
          CLEAR LS_CHK_MATNR_DM.
          LS_CHK_MATNR_DM-MATNR_DM = LS_2010-MATNR_DM.
          LS_CHK_MATNR_DM-MENGE = 1.
          COLLECT LS_CHK_MATNR_DM INTO LT_CHK_MATNR_DM.

          CLEAR LS_CHK_MATNR_DM.
          LS_CHK_MATNR_DM-MATNR_DM = 'TOTAL'.
          LS_CHK_MATNR_DM-MENGE = 1.
          COLLECT LS_CHK_MATNR_DM INTO LT_CHK_MATNR_DM.
        ENDIF.
      ENDLOOP.

* 최초라인은 판매오더 드럼정보 확인하여 생산오더 존재시 등록된 드럼수가 있다면 수량 추가
*  1) 판매오더 베이스 생산오더 미존재시 판매오더 드럼으로 청구작성
*  2) 생산오더존재시 등록된 각각의 드럼정보 확인하여 수량 세팅
*
      CLEAR LS_CHK_MATNR_DM.
      READ TABLE LT_CHK_MATNR_DM INTO LS_CHK_MATNR_DM WITH KEY MATNR_DM = 'TOTAL'.
      IF SY-SUBRC EQ 0.
        LS_MAIN-DRUM_CNT = LS_MAIN-DRUM_CNT - LS_CHK_MATNR_DM-MENGE.
        READ TABLE LT_CHK_MATNR_DM INTO DATA(LS_PACK_MAT) WITH KEY MATNR_DM = LS_MAIN-PACK_MAT.
        IF SY-SUBRC EQ 0.
          LS_MAIN-ICON_ORDER = ICON_SELECT_DETAIL.
          LS_MAIN-DRUM_CNT = LS_MAIN-DRUM_CNT + LS_PACK_MAT-MENGE.
        ENDIF.

        IF LS_MAIN-DRUM_CNT NE 0.
          APPEND LS_MAIN TO GT_SALES.
        ENDIF.

        LOOP AT LT_CHK_MATNR_DM INTO DATA(LS_OTHER_DRUMS) WHERE MATNR_DM NE 'TOTAL'.
          IF LS_OTHER_DRUMS-MATNR_DM = LS_MAIN-PACK_MAT.
            CONTINUE.
          ENDIF.

          LS_MAIN-PACK_MAT = LS_OTHER_DRUMS-MATNR_DM.
          LS_MAIN-PACK_MAT_TXT = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_OTHER_DRUMS-MATNR_DM ).
          LS_MAIN-ICON_ORDER = ICON_SELECT_DETAIL.
          LS_MAIN-DRUM_CNT = LS_MAIN-DRUM_CNT + LS_OTHER_DRUMS-MENGE.
          APPEND LS_MAIN TO GT_SALES.
        ENDLOOP.
      ELSE.

        APPEND LS_MAIN TO GT_SALES.
      ENDIF.
    ENDIF.

  ENDLOOP.

  LOOP AT GT_SALES REFERENCE INTO LR_SALES.
    LR_SALES->* = VALUE #( BASE LR_SALES->*  STATUS = ICON_LIGHT_OUT ).

    READ TABLE LT_ZGTPPT3422 INTO DATA(LS_ZGTPPT3422) WITH KEY VBELN = LR_SALES->VBELN
                                                               VBELP = LR_SALES->VBELP
                                                               MATNR = LR_SALES->PACK_MAT.
    IF SY-SUBRC IS INITIAL.
      LR_SALES->REQNO  = LS_ZGTPPT3422-REQNO.
      LR_SALES->POSNR  = LS_ZGTPPT3422-POSNR.
      LR_SALES->REQDAT = LS_ZGTPPT3422-BDTER.
      LR_SALES->STATUS = ICON_GREEN_LIGHT.
      LR_SALES->STYLE  = GT_STYLE.
    ENDIF.

*// 입고 요청일.
    IF LR_SALES->STATUS EQ ICON_LIGHT_OUT.
      LR_SALES->REQDAT = P_REQDT.
    ENDIF.

  ENDLOOP.

  APPEND LINES OF GT_PACK_MAT TO GT_SALES.

  DELETE GT_SALES WHERE EXCEPT EQ ABAP_TRUE
                     OR PACK_MAT IS INITIAL.

  IF P_UNREQ EQ ABAP_TRUE. "// 미청구건 조회.
    DELETE GT_SALES WHERE STATUS EQ ICON_GREEN_LIGHT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_create
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_CREATE.

  IF P_GNMAT EQ ABAP_TRUE.
    PERFORM CALL_SUMMARY_POPUP_WINDOW.     "// 일반 자재.
  ELSE.
    IF P_SPGCD = 'GL'.
      PERFORM CALL_SUMMARY_POPUP_WINDOW_GL. "// 포장 자재.
    ELSE.
      PERFORM CREATE_MAT_REQ_FROM_SLS_ORDER. "// 포장 자재.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_mat_req_from_prd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_MAT_REQ_FROM_PRD  RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  GR_MREQ->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  PERFORM GET_ROWS_SELECTED_IN_PROD.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
  ENDIF.

  IF GS_RESULT-INVALID IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E12.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_mat_req_from_smry
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CREATE_MAT_REQ_FROM_SMRY .
  DATA LT_ZGTPPT3420 TYPE TABLE OF ZGTPPT3420.
  DATA LT_ZGTPPT3421 TYPE TABLE OF ZGTPPT3421.
  DATA LV_REQNO TYPE CHAR12.
  DATA LV_POSNR TYPE ZGTPPT3420-POSNR.

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

*// 청구번호.
  PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' LV_REQNO.

  LOOP AT GT_SMRY INTO DATA(LS_SMRY)
                  WHERE LFIMG GT 0.
    LV_POSNR += 1.

    APPEND INITIAL LINE TO LT_ZGTPPT3420 REFERENCE INTO DATA(LR_ZGTPPT3420).
    LR_ZGTPPT3420->* = CORRESPONDING #( LS_SMRY ).
    LR_ZGTPPT3420->* = CORRESPONDING #( BASE ( LR_ZGTPPT3420->* ) GS_ZGTPPS1001 ).
    LR_ZGTPPT3420->* = VALUE #( BASE LR_ZGTPPT3420->*  REQNO   = LV_REQNO+2
                                                       REQDAT  = GS_SUMMARY-REQDAT
                                                       LGORT_T = GS_SUMMARY-LGORT
                                                       POSNR   = LV_POSNR ).

    LOOP AT GT_PROD REFERENCE INTO DATA(LR_PROD)
                    WHERE SEL    EQ ABAP_TRUE
                      AND EXREQ  EQ ABAP_FALSE
                      AND STATUS NE ICON_GREEN_LIGHT
                      AND WERKS  EQ LS_SMRY-WERKS
                      AND IDNRK  EQ LS_SMRY-MATNR.
      APPEND INITIAL LINE TO LT_ZGTPPT3421 REFERENCE INTO DATA(LR_ZGTPPT3421).
      LR_ZGTPPT3421->* = CORRESPONDING #( LR_ZGTPPT3420->* ).
      LR_ZGTPPT3421->* = VALUE #( BASE LR_ZGTPPT3421->*  RSNUM = LR_PROD->RSNUM
                                                         RSPOS = LR_PROD->RSPOS
                                                         PLNUM = COND #( WHEN LR_PROD->ORDTY EQ GC_ORDTY-PLN THEN LR_PROD->ORDNR )
                                                         AUFNR = COND #( WHEN LR_PROD->ORDTY EQ GC_ORDTY-PRD THEN LR_PROD->ORDNR )
                                                         VBELN = LR_PROD->ORDNO
                                                         VBELP = LR_PROD->ORDPO
                                                         GUBUN = LR_PROD->GUBUN
                                                         BDTER = LR_PROD->BDTER
                                                         BDMNG = LR_PROD->BDMNG
                                                         AUSCH = LR_PROD->AUSCH
                                                         MEINS = LR_PROD->MEINS
                                                         RQMON = LR_PROD->RQMON
                                                         ZWKREQ = LR_PROD->ZWKREQ
                                                         GRPNR = LR_PROD->GRPNR ).
      LR_PROD->REQNO   = LV_REQNO+2.
      LR_PROD->POSNR   = LV_POSNR.
      LR_PROD->STATUS  = ICON_GREEN_LIGHT.
      LR_PROD->MESSAGE = TEXT-S01.
      LR_PROD->STYLE   = GT_STYLE.
    ENDLOOP.
  ENDLOOP.

  TRY.
      MODIFY ZGTPPT3420 FROM TABLE LT_ZGTPPT3420.
      MODIFY ZGTPPT3421 FROM TABLE LT_ZGTPPT3421.

      COMMIT WORK AND WAIT.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      MESSAGE E000 WITH LR_ROOT->GET_TEXT( ).
  ENDTRY.

  PERFORM GET_MAT_REQ_RESULT_FROM_PRD.

  GR_MREQ->REFRESH( ).
  GR_LIST->REFRESH( ).

  MESSAGE S000 WITH TEXT-S11.

  PERFORM USER_COMMAND_EXIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_in_prod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_IN_PROD.

  CLEAR GS_RESULT.

  LOOP AT GT_PROD  INTO DATA(LS_PROD)
                  WHERE SEL EQ ABAP_TRUE.
    GS_RESULT-SEL += 1.

    IF LS_PROD-RETURN IS NOT INITIAL.
      GS_RESULT-INVALID = ABAP_TRUE.
    ENDIF.

    CHECK LS_PROD-STATUS NE ICON_GREEN_LIGHT AND
          LS_PROD-RETURN IS INITIAL AND
          LS_PROD-EXREQ EQ ABAP_FALSE.

    GS_RESULT-TOTAL += 1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_date_time
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_DATE_TIME  USING PS_ZGTPPS1001 TYPE ZGTPPS1001.

  PS_ZGTPPS1001-CRDAT = SY-DATUM.
  PS_ZGTPPS1001-CRTIM = SY-UZEIT.
  PS_ZGTPPS1001-CRNAM = SY-UNAME.
  PS_ZGTPPS1001-CHDAT = SY-DATUM.
  PS_ZGTPPS1001-CHTIM = SY-UZEIT.
  PS_ZGTPPS1001-CHNAM = SY-UNAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_next_number
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_NEXT_NUMBER  USING  PV_OBJECT TYPE INRI-OBJECT
                             PV_NUMBER.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '04'
      OBJECT                  = PV_OBJECT
    IMPORTING
      NUMBER                  = PV_NUMBER
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED  USING PR_SENDER
                                PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                PV_UCOMM TYPE SY-UCOMM.

  IF GR_MREQ IS BOUND AND PR_SENDER EQ GR_MREQ->MR_GRID.
    PERFORM DATA_CHANGED_IN_MREQ USING PR_DATA_CHANGED PV_UCOMM.
  ENDIF.

  IF GR_LIST IS BOUND AND PR_SENDER EQ GR_LIST->MR_GRID.
    PERFORM DATA_CHANGED_IN_LIST USING PR_DATA_CHANGED PV_UCOMM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed_fini
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED_FINI  USING PR_SENDER
                                     PT_GOOD_CELLS TYPE LVC_T_MODI
                                     PV_MODIFIED.

  IF GR_MREQ IS BOUND AND PR_SENDER EQ GR_MREQ->MR_GRID.
    PERFORM DATA_CHANGED_FINI_IN_MREQ USING PT_GOOD_CELLS PV_MODIFIED.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form split_screen_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SPLIT_SCREEN_LAYOUT .

  TRY.
      GR_DOCKING_CONTAINER = NEW #( PARENT    = CL_GUI_CONTAINER=>SCREEN0
                                    SIDE      = 2
                                    EXTENSION = 2000 ).

      GR_SPLITTER_CONTAINER = NEW #( PARENT  = GR_DOCKING_CONTAINER
                                     ROWS    = 2
                                     COLUMNS = 1 ).

      GR_SPLITTER_CONTAINER->SET_ROW_HEIGHT( ID = 1 HEIGHT = 70 ).

      GR_SPLITTER_CONTAINER->SET_ROW_SASH( ID    = 1
                                           TYPE  = CL_GUI_SPLITTER_CONTAINER=>TYPE_SASHVISIBLE
                                           VALUE = CL_GUI_SPLITTER_CONTAINER=>TRUE ).

      GR_SPLITTER_CONTAINER->SET_ROW_SASH( ID    = 1
                                           TYPE  = CL_GUI_SPLITTER_CONTAINER=>TYPE_MOVABLE
                                           VALUE = CL_GUI_SPLITTER_CONTAINER=>TRUE ).

      GR_TOP_CONTAINER = GR_SPLITTER_CONTAINER->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
      GR_BOTTOM_CONTAINER = GR_SPLITTER_CONTAINER->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      MESSAGE LR_ROOT->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_LIST .

  LOOP AT GR_LIST->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-F01.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_REQUI EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-F02.
        LR_FCAT->CHECKTABLE = SPACE.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'SPGCD'.
        LR_FCAT->COLTEXT    = TEXT-F03.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'REQNO'.
        LR_FCAT->COLTEXT    = TEXT-F24.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'POSNR'.
        LR_FCAT->COLTEXT    = TEXT-F25.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'GRPNR'.
        LR_FCAT->COLTEXT    = TEXT-F14.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

*      WHEN 'GUBUN'.
*        lr_fcat->coltext    = TEXT-f12.
*        lr_fcat->just       = 'C'.
*        lr_fcat->emphasize  = 'C100'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F17.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F18.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'LFIMG'.
        LR_FCAT->COLTEXT    = TEXT-F60.
        LR_FCAT->EDIT       = COND #( WHEN P_CHANGE EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'ERFME'.
        LR_FCAT->COLTEXT    = TEXT-F61.
        LR_FCAT->EDIT       = COND #( WHEN P_CHANGE EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->JUST       = 'C'.

      WHEN 'REQDAT'.
        LR_FCAT->COLTEXT    = TEXT-F21.
        LR_FCAT->EDIT       = COND #( WHEN P_CHANGE EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->JUST       = 'C'.

      WHEN 'LGORT_T'.
        LR_FCAT->COLTEXT    = TEXT-F22.
        LR_FCAT->EDIT       = COND #( WHEN P_CHANGE EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->CHECKTABLE = SPACE.
        LR_FCAT->JUST       = 'C'.

      WHEN 'DRUMFLAG'.
        LR_FCAT->COLTEXT    = TEXT-F62.
        LR_FCAT->CHECKBOX   = ABAP_TRUE.

      WHEN 'BANFN'.
        LR_FCAT->COLTEXT    = TEXT-F56.

      WHEN 'BNFPO'.
        LR_FCAT->COLTEXT    = TEXT-F57.

      WHEN 'EBELN'.
        LR_FCAT->COLTEXT    = TEXT-F63.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->TECH       = COND #( WHEN P_REQUI EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'EBELP'.
        LR_FCAT->COLTEXT    = TEXT-F64.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->TECH       = COND #( WHEN P_REQUI EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'LABST'.
        LR_FCAT->COLTEXT    = TEXT-F69.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->TECH       = COND #( WHEN P_CHANGE EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'MESSAGE'.
        LR_FCAT->COLTEXT    = TEXT-F53.
        LR_FCAT->TECH       = COND #( WHEN P_REQUI EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_mreq
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_MREQ .

  IF P_GNMAT EQ ABAP_TRUE.
    PERFORM BUILD_FCAT_FOR_PROD.  "// 일반 자재.
  ELSE.
    PERFORM BUILD_FCAT_FOR_SALES. "// 포장 자재.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_mreq
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_IN_MREQ .

  TRY.
      GR_MREQ->MS_LAYOUT = VALUE #( BASE GR_MREQ->MS_LAYOUT  STYLEFNAME = 'STYLE'
                                                             SEL_MODE   = 'D'
                                                             NO_ROWMARK = ABAP_TRUE ).

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_IN_LIST .

  TRY.
      GR_LIST->MS_LAYOUT = VALUE #( BASE GR_LIST->MS_LAYOUT NO_ROWMARK = COND #( WHEN P_REQUI EQ ABAP_TRUE THEN ABAP_TRUE ) ).

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mat_req_result_from_prd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MAT_REQ_RESULT_FROM_PRD .

  CLEAR GT_LIST.

  CHECK GT_PROD IS NOT INITIAL.

  DATA(LT_PROD) = GT_PROD.
  SORT LT_PROD BY WERKS SPGCD REQNO POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_PROD COMPARING WERKS SPGCD REQNO POSNR.

  SELECT ZT02~WERKS, ZT02~SPGCD, ZT02~REQNO, ZT02~POSNR,
         ZT02~MATNR, ZT02~LFIMG,
         ZT02~ERFME, ZT02~REQDAT, ZT02~LGORT_T, ZT02~BANFN,
         ZT02~BNFPO, ZT02~EBELN,  ZT02~EBELP, ZT02~DRUMFLAG,
         MARD~LABST,
         MAKT~MAKTX
    FROM @LT_PROD   AS ZT01
    JOIN ZGTPPT3420 AS ZT02
      ON ZT01~WERKS   EQ ZT02~WERKS
     AND ZT01~SPGCD   EQ ZT02~SPGCD
     AND ZT01~REQNO   EQ ZT02~REQNO
     AND ZT01~POSNR   EQ ZT02~POSNR
     AND ZT02~ZSTATUS EQ @SPACE
    LEFT JOIN MARD
      ON ZT02~MATNR   EQ MARD~MATNR
     AND ZT02~WERKS   EQ MARD~WERKS
     AND ZT02~LGORT_T EQ MARD~LGORT
    LEFT JOIN MAKT
      ON ZT02~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   ORDER BY ZT02~WERKS, ZT02~SPGCD,ZT02~REQNO, ZT02~POSNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click_in_mreq
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK_IN_MREQ  USING PS_ROW    TYPE LVC_S_ROID
                                  PS_COLUMN TYPE LVC_S_COL.

  IF P_GNMAT EQ ABAP_TRUE. "// 일반 자재.
    PERFORM HOTSPOT_CLICK_FOR_PROD USING PS_ROW PS_COLUMN.
  ELSE.                    "// 포장 자재.
    PERFORM HOTSPOT_CLICK_FOR_SALES USING PS_ROW PS_COLUMN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click_for_prod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK_FOR_PROD  USING PS_ROW    TYPE LVC_S_ROID
                                   PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LR_PROD) = REF #( GT_PROD[ PS_ROW-ROW_ID ] ).

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'SEL'.    "// 선택.
      LR_PROD->SEL = COND #( WHEN LR_PROD->SEL EQ ABAP_TRUE THEN ABAP_FALSE
                                                            ELSE ABAP_TRUE ).

      LR_PROD->EXREQ = COND #( WHEN LR_PROD->SEL EQ ABAP_FALSE THEN ABAP_FALSE
                                                               ELSE LR_PROD->EXREQ ).

      IF LR_PROD->ORDNO IS NOT INITIAL.
        MODIFY GT_PROD FROM VALUE #( SEL   = LR_PROD->SEL
                                     EXREQ = LR_PROD->EXREQ )
                       TRANSPORTING SEL EXREQ
                       WHERE ORDNO EQ LR_PROD->ORDNO.
      ENDIF.

      GR_MREQ->REFRESH( ).

    WHEN 'EXREQ'. "// 청구 제외.
      IF LR_PROD->ORDNO IS INITIAL OR LR_PROD->SEL EQ ABAP_FALSE.
        CASE P_SPGCD.
          WHEN 'GL' OR 'GO'.
            IF LR_PROD->SEL EQ ABAP_TRUE.
              LR_PROD->EXREQ = COND #( WHEN LR_PROD->EXREQ EQ ABAP_TRUE THEN ABAP_FALSE
                                                                                      ELSE ABAP_TRUE ) .

              GR_MREQ->REFRESH( ).
            ENDIF.
        ENDCASE.
        RETURN.
      ENDIF.

      MODIFY GT_PROD FROM VALUE #( EXREQ = COND #( WHEN LR_PROD->EXREQ EQ ABAP_TRUE THEN ABAP_FALSE
                                                                                    ELSE ABAP_TRUE ) )
                     TRANSPORTING EXREQ
                     WHERE ORDNO EQ LR_PROD->ORDNO
                       AND IDNRK EQ LR_PROD->IDNRK.

      GR_MREQ->REFRESH( ).
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click_for_sales
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK_FOR_SALES  USING PS_ROW    TYPE LVC_S_ROID
                                    PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LR_SALES) = REF #( GT_SALES[ PS_ROW-ROW_ID ] ).

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'SEL'. "// 선택.
      IF LR_SALES->SEL IS NOT INITIAL.
        CLEAR LR_SALES->SEL.
      ELSE.
        LR_SALES->SEL = ABAP_TRUE.
      ENDIF.

      GR_MREQ->REFRESH( ).
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& form create_mat_req_from_sls_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CREATE_MAT_REQ_FROM_SLS_ORDER .

  TRY.
      PERFORM CHECK_BEFORE_MAT_REQ_FROM_SLS USING ''. "// 사전점검.
      PERFORM CREATE_MAT_REQ_FROM_SLS.       "// 자재청구.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        GR_MREQ->REFRESH( ).
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_mat_req_from_sls
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_MAT_REQ_FROM_SLS USING P_GUBUM
                                   RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  GR_MREQ->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  PERFORM GET_ROWS_SELECTED_IN_SALES.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
  ENDIF.

  IF GS_RESULT-INVALID IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH GS_RESULT-MESSAGE.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E14.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C02 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  IF P_GUBUM = 'MTO' AND LINE_EXISTS( GT_SALES[ VBELN = '' ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH 'MTO 청구 생성할 판매오더가 없습니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_mat_req_from_sls
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CREATE_MAT_REQ_FROM_SLS .
  DATA LT_ZGTPPT3420 TYPE TABLE OF ZGTPPT3420.
  DATA LT_ZGTPPT3422 TYPE TABLE OF ZGTPPT3422.
  DATA LT_PRITEM     TYPE TY_BAPIMEREQITEMIMP.
  DATA LT_PRITEMX    TYPE TY_BAPIMEREQITEMX.
  DATA LT_PRACCOUNT  TYPE TY_BAPIMEREQACCOUNT.
  DATA LT_PRACCOUNTX TYPE TY_BAPIMEREQACCOUNTX.
  DATA LS_SALES TYPE TY_S_SALES.
  DATA LV_REQNO TYPE CHAR12.
  DATA LV_POSNR TYPE ZGTPPT3420-POSNR.
  DATA LV_BNFPO TYPE ZGTPPT3420-BNFPO.
  DATA : LV_CHK_EXIST.
  DATA : LT_MOSU LIKE GT_SALES.

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

  LOOP AT GT_SALES INTO DATA(LS_KEY)
                  WHERE SEL    EQ ABAP_TRUE
                    AND STATUS NE ICON_GREEN_LIGHT
                  GROUP BY ( NEWDRUM       = LS_KEY-NEWDRUM       "// 신드럼
                             IRONDRUM      = LS_KEY-IRONDRUM      "// 철드럼
                             DRUMTITLEMARK = LS_KEY-DRUMTITLEMARK "// 드럼자판 인쇄유무
                             FLANGE_PROT   = LS_KEY-FLANGE_PROT   "// 악판 골판지 유무
                             HANJEON       = LS_KEY-HANJEON )     "// 한전유무
                   INTO DATA(LT_SALES).

*// 청구번호.
    PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' LV_REQNO.

    CLEAR: LS_SALES, LV_POSNR, LT_PRITEM, LT_PRITEMX, LT_PRACCOUNT, LT_PRACCOUNTX, LV_BNFPO.

    LOOP AT GROUP LT_SALES REFERENCE INTO DATA(LR_SALES).

      CLEAR GV_INCLUDE_SO.
      CASE 'Y'.
        WHEN LR_SALES->NEWDRUM OR LR_SALES->IRONDRUM OR
          LR_SALES->FLANGE_PROT OR LR_SALES->HANJEON.
          GV_INCLUDE_SO = ABAP_TRUE.
        WHEN OTHERS.
          CASE LR_SALES->DRUM_GUBUN.
            WHEN 'E' OR 'HT-E' OR 'PL'.
              GV_INCLUDE_SO = ABAP_TRUE.
          ENDCASE.

      ENDCASE.
* 해당 조건들만 개별로 판매오더 참조 pr생성
      IF GV_INCLUDE_SO IS NOT INITIAL.

        LV_POSNR += 1.
        LV_BNFPO += 10.

        APPEND INITIAL LINE TO LT_ZGTPPT3420 REFERENCE INTO DATA(LR_ZGTPPT3420).
        LR_ZGTPPT3420->* = CORRESPONDING #( LR_SALES->* MAPPING MATNR   = PACK_MAT
                                                                LFIMG   = DRUM_CNT
                                                                ERFME   = MEINS
                                                                LGORT_T = LGPRO ).
        LR_ZGTPPT3420->* = CORRESPONDING #( BASE ( LR_ZGTPPT3420->* ) GS_ZGTPPS1001 ).
        LR_ZGTPPT3420->* = VALUE #( BASE LR_ZGTPPT3420->*  REQNO    = LV_REQNO+2
                                                           POSNR    = LV_POSNR
                                                           DRUMFLAG = ABAP_TRUE
                                                           BNFPO    = LV_BNFPO ).

        APPEND INITIAL LINE TO LT_ZGTPPT3422 REFERENCE INTO DATA(LR_ZGTPPT3422).
        LR_ZGTPPT3422->* = CORRESPONDING #( LR_SALES->* MAPPING MATNR = PACK_MAT
                                                                BDMNG = DRUM_CNT
                                                                BDTER = REQDAT ).
        LR_ZGTPPT3422->* = VALUE #( BASE LR_ZGTPPT3422->*  REQNO      = LR_ZGTPPT3420->REQNO
                                                           POSNR      = LR_ZGTPPT3420->POSNR
                                                           PACK_GUBUN = LR_SALES->PACK_METHOD
                                                           PACK_TEXT  = LR_SALES->PACK_TXT
                                                           PKWOOD     = LR_SALES->PW_FACTOR
                                                           GUBUN      = GC_GCATG-MTO ).
        LR_ZGTPPT3422->SO_REF = ABAP_TRUE.

        LR_SALES->REQNO = LV_REQNO+2.
        LR_SALES->POSNR = LV_POSNR.
        LR_SALES->BNFPO = LV_BNFPO.
        LS_SALES-WERKS  = LR_SALES->WERKS.
        LS_SALES-REQNO  = LR_SALES->REQNO.
        LS_SALES-POSNR  = LR_SALES->POSNR.

        PERFORM SET_PARA_CREATE_REQ_BAPI USING LR_ZGTPPT3420->* LT_PRITEM LT_PRITEMX LT_PRACCOUNT LT_PRACCOUNTX.
      ELSE. "자재별 처리할 모수로 모아둔다.
        APPEND LR_SALES->* TO LT_MOSU.
      ENDIF.
    ENDLOOP.

*// 구매요청 생성.
    PERFORM CREATE_PURCHASE_REQUISITION USING LS_SALES LT_PRITEM LT_PRITEMX LT_PRACCOUNT LT_PRACCOUNTX.

*// 처리결과 반영.
    PERFORM UPDATE_RESULT_CRT_MAT_REQ TABLES LT_ZGTPPT3420 LT_ZGTPPT3422
                                       USING LS_SALES.

  ENDLOOP.

  CLEAR GV_INCLUDE_SO.
  IF LT_MOSU IS NOT INITIAL.

*// 청구번호.
    PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' LV_REQNO.
    CLEAR: LS_SALES, LV_POSNR, LT_PRITEM, LT_PRITEMX, LT_PRACCOUNT, LT_PRACCOUNTX, LV_BNFPO.

    LOOP AT GT_SALES REFERENCE INTO LR_SALES WHERE SEL EQ ABAP_TRUE
                                               AND STATUS NE ICON_GREEN_LIGHT.
      READ TABLE LT_MOSU INTO DATA(LS_MOSU) WITH KEY VBELN = LR_SALES->VBELN
                                               VBELP = LR_SALES->VBELP
                                               PACK_MAT = LR_SALES->PACK_MAT
                                               DRUM_CNT = LR_SALES->DRUM_CNT.
      IF SY-SUBRC EQ 0.
        READ TABLE LT_ZGTPPT3420 ASSIGNING FIELD-SYMBOL(<LS_3420>) WITH KEY REQNO    = LV_REQNO+2
                                                                   MATNR    = LR_SALES->PACK_MAT.
        IF SY-SUBRC EQ 0. "
          ADD LR_SALES->DRUM_CNT TO <LS_3420>-LFIMG.

          APPEND INITIAL LINE TO LT_ZGTPPT3422 REFERENCE INTO LR_ZGTPPT3422.
          LR_ZGTPPT3422->* = CORRESPONDING #( LR_SALES->* MAPPING MATNR = PACK_MAT
                                                                  BDMNG = DRUM_CNT
                                                                  BDTER = REQDAT ).
          LR_ZGTPPT3422->* = VALUE #( BASE LR_ZGTPPT3422->*  REQNO      = <LS_3420>-REQNO
                                                             POSNR      = <LS_3420>-POSNR
                                                             PACK_GUBUN = LR_SALES->PACK_METHOD
                                                             PACK_TEXT  = LR_SALES->PACK_TXT
                                                             PKWOOD     = LR_SALES->PW_FACTOR
                                                             GUBUN      = GC_GCATG-MTO ).

          READ TABLE LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>) WITH KEY PREQ_ITEM = <LS_3420>-BNFPO
                                                                            MATERIAL = <LS_3420>-MATNR.
          IF SY-SUBRC EQ 0.
            ADD LR_SALES->DRUM_CNT TO <LS_PRITEM>-QUANTITY.
          ENDIF.

          LR_SALES->REQNO = <LS_3420>-REQNO.
          LR_SALES->POSNR = <LS_3420>-POSNR.
          LR_SALES->BNFPO = <LS_3420>-BNFPO.

        ELSE.

          LV_POSNR += 1.
          LV_BNFPO += 10.

          APPEND INITIAL LINE TO LT_ZGTPPT3420 REFERENCE INTO LR_ZGTPPT3420.
          LR_ZGTPPT3420->* = CORRESPONDING #( BASE ( LR_ZGTPPT3420->* ) GS_ZGTPPS1001 ).
          LR_ZGTPPT3420->WERKS = LR_SALES->WERKS.
          LR_ZGTPPT3420->SPGCD = LR_SALES->SPGCD.
          LR_ZGTPPT3420->REQNO = LV_REQNO+2.
          LR_ZGTPPT3420->POSNR = LV_POSNR.
          LR_ZGTPPT3420->REQDAT = LR_SALES->REQDAT.
          LR_ZGTPPT3420->BNFPO = LV_BNFPO.
          LR_ZGTPPT3420->MATNR = LR_SALES->PACK_MAT.
          LR_ZGTPPT3420->LFIMG = LR_SALES->DRUM_CNT.
          LR_ZGTPPT3420->ERFME = LR_SALES->MEINS.
          LR_ZGTPPT3420->LGORT_T = LR_SALES->LGPRO.
          LR_ZGTPPT3420->DRUMFLAG = ABAP_TRUE.

          APPEND INITIAL LINE TO LT_ZGTPPT3422 REFERENCE INTO LR_ZGTPPT3422.
          LR_ZGTPPT3422->* = CORRESPONDING #( LR_SALES->* MAPPING MATNR = PACK_MAT
                                                                  BDMNG = DRUM_CNT
                                                                  BDTER = REQDAT ).
          LR_ZGTPPT3422->* = VALUE #( BASE LR_ZGTPPT3422->*  REQNO      = LR_ZGTPPT3420->REQNO
                                                             POSNR      = LR_ZGTPPT3420->POSNR
                                                             PACK_GUBUN = LR_SALES->PACK_METHOD
                                                             PACK_TEXT  = LR_SALES->PACK_TXT
                                                             PKWOOD     = LR_SALES->PW_FACTOR
                                                             GUBUN      = GC_GCATG-MTO ).

          LR_SALES->REQNO = LV_REQNO+2.
          LR_SALES->POSNR = LV_POSNR.
          LR_SALES->BNFPO = LV_BNFPO.

          PERFORM SET_PARA_CREATE_REQ_BAPI USING LR_ZGTPPT3420->* LT_PRITEM LT_PRITEMX LT_PRACCOUNT LT_PRACCOUNTX.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CLEAR LS_SALES.
*// 구매요청 생성.
    PERFORM CREATE_PURCHASE_REQUISITION USING LS_SALES LT_PRITEM LT_PRITEMX LT_PRACCOUNT LT_PRACCOUNTX.

*// 처리결과 반영.
    IF LS_SALES-BANFN IS NOT INITIAL.
      MODIFY LT_ZGTPPT3420 FROM VALUE #( BANFN = LS_SALES-BANFN ) TRANSPORTING BANFN
       WHERE BANFN IS INITIAL.
      .

      MODIFY ZGTPPT3420 FROM TABLE LT_ZGTPPT3420.
      MODIFY ZGTPPT3422 FROM TABLE LT_ZGTPPT3422.

      COMMIT WORK AND WAIT.
    ENDIF.

    LOOP AT GT_SALES REFERENCE INTO LR_SALES WHERE SEL EQ ABAP_TRUE
                                         AND STATUS NE ICON_GREEN_LIGHT.
      READ TABLE LT_MOSU INTO LS_MOSU WITH KEY VBELN = LR_SALES->VBELN
                                               VBELP = LR_SALES->VBELP
                                               PACK_MAT = LR_SALES->PACK_MAT
                                               DRUM_CNT = LR_SALES->DRUM_CNT.
      IF SY-SUBRC EQ 0.
        IF LS_SALES-BANFN IS NOT INITIAL.
          LR_SALES->STATUS = ICON_GREEN_LIGHT.
          LR_SALES->MESSAGE = TEXT-S01.
          LR_SALES->BANFN = LS_SALES-BANFN.
          LR_SALES->STYLE = GT_STYLE.
        ELSE.
          LR_SALES->STATUS = ICON_RED_LIGHT.
          LR_SALES->MESSAGE = LS_SALES-MESSAGE.
          CLEAR : LR_SALES->BNFPO, LR_SALES->REQNO, LR_SALES->POSNR.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.

  PERFORM GET_MAT_REQ_RESULT_FROM_SLS.

  GR_MREQ->REFRESH( ).
  GR_LIST->REFRESH( ).

  MESSAGE S000 WITH TEXT-S11.



*  DATA lt_zgtppt3420 TYPE TABLE OF zgtppt3420.
*  DATA lt_zgtppt3422 TYPE TABLE OF zgtppt3422.
*  DATA lt_pritem     TYPE ty_bapimereqitemimp.
*  DATA lt_pritemx    TYPE ty_bapimereqitemx.
*  DATA lt_praccount  TYPE ty_bapimereqaccount.
*  DATA lt_praccountx TYPE ty_bapimereqaccountx.
*  DATA ls_sales TYPE ty_s_sales.
*  DATA lv_reqno TYPE char12.
*  DATA lv_posnr TYPE zgtppt3420-posnr.
*  DATA lv_bnfpo TYPE zgtppt3420-bnfpo.
*
**// 처리일자 및 시간.
*  PERFORM get_date_time USING gs_zgtpps1001.
*
*  LOOP AT gt_sales INTO DATA(ls_key)
*                  WHERE sel    EQ abap_true
*                    AND status NE icon_green_light
*                  GROUP BY ( newdrum       = ls_key-newdrum       "// 신드럼
*                             irondrum      = ls_key-irondrum      "// 철드럼
*                             drumtitlemark = ls_key-drumtitlemark "// 드럼자판 인쇄유무
*                             flange_prot   = ls_key-flange_prot   "// 악판 골판지 유무
*                             hanjeon       = ls_key-hanjeon )     "// 한전유무
*                   INTO DATA(lt_sales).
**// 청구번호.
*    PERFORM get_next_number USING 'ZGTPP_GORD' lv_reqno.
*
*    CLEAR: ls_sales, lv_posnr, lt_pritem, lt_pritemx, lt_praccount, lt_praccountx, lv_bnfpo.
*
*    APPEND INITIAL LINE TO lt_zgtppt3420 REFERENCE INTO DATA(lr_zgtppt3420).
*
*    LOOP AT GROUP lt_sales REFERENCE INTO DATA(lr_sales).
*      lv_posnr += 1.
*      lv_bnfpo += 10.
*
*      IF lr_zgtppt3420->* IS INITIAL.
*        lr_zgtppt3420->* = CORRESPONDING #( lr_sales->* MAPPING matnr   = pack_mat
*                                                                erfme   = meins
*                                                                lgort_t = lgpro ).
*
*        lr_zgtppt3420->* = CORRESPONDING #( BASE ( lr_zgtppt3420->* ) gs_zgtpps1001 ).
*        lr_zgtppt3420->* = VALUE #( BASE lr_zgtppt3420->*  reqno    = lv_reqno+2
*                                                           posnr    = lv_posnr
*                                                           drumflag = abap_true
*                                                           bnfpo    = lv_bnfpo ).
*      ENDIF.
*
*      APPEND INITIAL LINE TO lt_zgtppt3422 REFERENCE INTO DATA(lr_zgtppt3422).
*      lr_zgtppt3422->* = CORRESPONDING #( lr_sales->* MAPPING matnr = pack_mat
*                                                              bdmng = drum_cnt
*                                                              bdter = reqdat ).
*
*      lr_zgtppt3422->* = VALUE #( BASE lr_zgtppt3422->*  reqno      = lr_zgtppt3420->reqno
*                                                         posnr      = lr_zgtppt3420->posnr
*                                                         pack_gubun = lr_sales->pack_method
*                                                         pack_text  = lr_sales->pack_txt
*                                                         pkwood     = lr_sales->pw_factor
*                                                         gubun      = gc_gcatg-mto ).
*
*      lr_zgtppt3420->lfimg += lr_zgtppt3422->bdmng.
*
*      lr_sales->reqno = lv_reqno+2.
*      lr_sales->posnr = lv_posnr.
*      lr_sales->bnfpo = lv_bnfpo.
*      ls_sales-werks  = lr_sales->werks.
*      ls_sales-reqno  = lr_sales->reqno.
*      ls_sales-posnr  = lr_sales->posnr.
*
*      PERFORM set_para_create_req_bapi USING lr_zgtppt3420->* lv_bnfpo
*                                             lt_pritem lt_pritemx lt_praccount lt_praccountx.
*    ENDLOOP.
*
**// 구매요청 생성.
*    PERFORM create_purchase_requisition USING ls_sales lt_pritem lt_pritemx lt_praccount lt_praccountx.
*
**// 처리결과 반영.
*    PERFORM update_result_crt_mat_req TABLES lt_zgtppt3420 lt_zgtppt3422
*                                       USING ls_sales.
*  ENDLOOP.
*
*  PERFORM get_mat_req_result_from_sls.
*
*  gr_mreq->refresh( ).
*  gr_list->refresh( ).
*
*  MESSAGE s000 WITH TEXT-s11.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mat_req_result_from_sls
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MAT_REQ_RESULT_FROM_SLS .

  CLEAR GT_LIST.

  CHECK GT_SALES IS NOT INITIAL.

  DATA(LT_SALES) = GT_SALES.
  SORT LT_SALES BY WERKS SPGCD REQNO POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_SALES COMPARING WERKS SPGCD REQNO POSNR.

  SELECT ZT02~WERKS, ZT02~SPGCD, ZT02~REQNO, ZT02~POSNR,
         ZT02~MATNR, ZT02~LFIMG, ZT02~ERFME, ZT02~REQDAT,
         ZT02~LGORT_T, ZT02~BANFN,
         ZT02~BNFPO, ZT02~EBELN, ZT02~EBELP, ZT02~DRUMFLAG,
         MARD~LABST,
         MAKT~MAKTX
    FROM @LT_SALES  AS ZT01
    JOIN ZGTPPT3420 AS ZT02
      ON ZT01~WERKS   EQ ZT02~WERKS
     AND ZT01~SPGCD   EQ ZT02~SPGCD
     AND ZT01~REQNO   EQ ZT02~REQNO
     AND ZT01~POSNR   EQ ZT02~POSNR
     AND ZT02~ZSTATUS EQ @SPACE
    LEFT JOIN MARD
      ON ZT02~MATNR   EQ MARD~MATNR
     AND ZT02~WERKS   EQ MARD~WERKS
     AND ZT02~LGORT_T EQ MARD~LGORT
    LEFT JOIN MAKT
      ON ZT02~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   ORDER BY ZT02~WERKS, ZT02~SPGCD,ZT02~REQNO, ZT02~POSNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_in_sales
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_IN_SALES .

  CLEAR GS_RESULT.

  LOOP AT GT_SALES  INTO DATA(LS_SALES)
                   WHERE SEL EQ ABAP_TRUE.
    GS_RESULT-SEL += 1.

    IF LS_SALES-RETURN IS NOT INITIAL.
      GS_RESULT-INVALID = ABAP_TRUE.
    ENDIF.

    CHECK LS_SALES-STATUS NE ICON_GREEN_LIGHT AND
          LS_SALES-RETURN IS INITIAL.

    GS_RESULT-TOTAL += 1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_purchase_requisition
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CREATE_PURCHASE_REQUISITION USING PS_SALES      TYPE TY_S_SALES
                                       PT_PRITEM     TYPE TY_BAPIMEREQITEMIMP
                                       PT_PRITEMX    TYPE TY_BAPIMEREQITEMX
                                       PT_PRACCOUNT  TYPE TY_BAPIMEREQACCOUNT
                                       PT_PRACCOUNTX TYPE TY_BAPIMEREQACCOUNTX.

  DATA LV_NUMBER      TYPE BAPIMEREQHEADER-PREQ_NO.
  DATA LS_PRHEADEREXP TYPE BAPIMEREQHEADER.
  DATA LT_RETURN      TYPE TABLE OF BAPIRET2.

  DATA(LS_PRHEADER)  = VALUE BAPIMEREQHEADER( PR_TYPE = 'NB' ).
  DATA(LS_PRHEADERX) = VALUE BAPIMEREQHEADERX( PR_TYPE = ABAP_TRUE ).

  CALL FUNCTION 'BAPI_PR_CREATE'
    EXPORTING
      PRHEADER    = LS_PRHEADER
      PRHEADERX   = LS_PRHEADERX
    IMPORTING
      NUMBER      = LV_NUMBER
      PRHEADEREXP = LS_PRHEADEREXP
    TABLES
      PRITEM      = PT_PRITEM
      PRITEMX     = PT_PRITEMX
      PRACCOUNT   = PT_PRACCOUNT
      PRACCOUNTX  = PT_PRACCOUNTX
      RETURN      = LT_RETURN.

  IF NOT LINE_EXISTS( LT_RETURN[ TYPE = ZGTPP_IF_CONST=>GC_RESULT-ERROR ] ).
    PS_SALES-STATUS = ICON_GREEN_LIGHT.
    PS_SALES-BANFN  = LV_NUMBER.
  ELSE.
    PS_SALES-STATUS  = ICON_RED_LIGHT.
    PS_SALES-MESSAGE = VALUE #( LT_RETURN[ TYPE = ZGTPP_IF_CONST=>GC_RESULT-ERROR ]-MESSAGE OPTIONAL ).
    CLEAR: PS_SALES-BANFN, PS_SALES-BNFPO.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mat_req_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MAT_REQ_RESULT .

  DATA : BEGIN OF LS_CHK_GRPNR,
           GRPNR TYPE ZGTPPT2010-GRPNR,
         END OF LS_CHK_GRPNR.
  DATA : LT_CHK_GRPNR LIKE TABLE OF LS_CHK_GRPNR.

  DATA : LV_TAB_CNT TYPE I.
  DATA : LV_TAB_CNT_C(10) TYPE C.

  SELECT ZT01~WERKS,
         ZT01~SPGCD,
         ZT01~REQNO,
         ZT01~POSNR,
         ZT01~DRUMFLAG,
         ZT01~MATNR,
         ZT01~LFIMG,
         ZT01~ERFME,
         ZT01~REQDAT,
         ZT01~LGORT_T,
         ZT01~BANFN,
         ZT01~BNFPO,
         EKPO~EBELN,
         EKPO~EBELP,
*         zt01~zstatus,
         MAKT~MAKTX
    FROM ZGTPPT3420 AS ZT01
    LEFT JOIN EKPO
      ON ZT01~WERKS EQ EKPO~WERKS
     AND ZT01~REQNO EQ EKPO~BEDNR
     AND ZT01~POSNR EQ EKPO~AFNAM
     AND EKPO~LOEKZ EQ @SPACE
    LEFT JOIN MAKT
      ON ZT01~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   WHERE ZT01~WERKS   EQ @P_WERKS
     AND ZT01~SPGCD   EQ @P_SPGCD
     AND ZT01~REQDAT  IN @S_REQDAT
     AND ZT01~REQNO   IN @S_REQNO
     AND ZT01~MATNR   IN @S_MATNR
     AND ZT01~ZSTATUS EQ @SPACE
   ORDER BY ZT01~WERKS, ZT01~SPGCD,ZT01~REQNO, ZT01~POSNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

* 조회조건 조장구성표 번호 추가
  IF S_GRPNR3[] IS NOT INITIAL AND NOT ( P_WERKS = '6600' AND P_SPGCD = 'GL' ).
    PERFORM GET_JOJANG_LIST.
    LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
      READ TABLE GT_CHK_REQNO TRANSPORTING NO FIELDS WITH KEY REQNO = <LS_LIST>-REQNO
                                                              POSNR = <LS_LIST>-POSNR
                                                              BINARY SEARCH.
      IF SY-SUBRC NE 0.
        DELETE GT_LIST.
      ENDIF.
    ENDLOOP.

  ENDIF.

  REFRESH : GT_3421, GT_3422.

  IF NOT ( P_WERKS = '6600' AND P_SPGCD = 'GL' ).
    REFRESH GT_CHK_REQNO.
    LOOP AT GT_LIST ASSIGNING <LS_LIST>.
      CLEAR GS_CHK_REQNO.
      MOVE-CORRESPONDING <LS_LIST> TO GS_CHK_REQNO.
      APPEND GS_CHK_REQNO TO GT_CHK_REQNO.
    ENDLOOP.

    IF GT_CHK_REQNO[] IS NOT INITIAL.
      PERFORM GET_GRPNR_FROM_REQNO.
    ENDIF.

    LOOP AT GT_LIST ASSIGNING <LS_LIST>.
      REFRESH LT_CHK_GRPNR.

      LOOP AT GT_3421 INTO DATA(LS_3421) WHERE REQNO = <LS_LIST>-REQNO
                                           AND POSNR = <LS_LIST>-POSNR.
        CLEAR LS_CHK_GRPNR.
        IF LS_3421-GRPNR IS NOT INITIAL.
          LS_CHK_GRPNR-GRPNR = LS_3421-GRPNR.
          COLLECT LS_CHK_GRPNR INTO LT_CHK_GRPNR.
        ENDIF.

      ENDLOOP.

      LOOP AT GT_3422 INTO DATA(LS_3422) WHERE REQNO = <LS_LIST>-REQNO
                                           AND POSNR = <LS_LIST>-POSNR.
        CLEAR LS_CHK_GRPNR.
        IF LS_3422-GRPNR IS NOT INITIAL.
          LS_CHK_GRPNR-GRPNR = LS_3422-GRPNR.
          COLLECT LS_CHK_GRPNR INTO LT_CHK_GRPNR.
        ENDIF.

      ENDLOOP.

      IF LT_CHK_GRPNR[] IS NOT INITIAL.
        SORT LT_CHK_GRPNR BY GRPNR.
        LV_TAB_CNT = LINES( LT_CHK_GRPNR ).
        LV_TAB_CNT = LV_TAB_CNT - 1.

        READ TABLE LT_CHK_GRPNR INTO LS_CHK_GRPNR INDEX 1.

        <LS_LIST>-GRPNR = LS_CHK_GRPNR-GRPNR.

        IF LV_TAB_CNT NE 0.
          LV_TAB_CNT_C = LV_TAB_CNT.
          CONDENSE LV_TAB_CNT_C.

          CONCATENATE <LS_LIST>-GRPNR '외' LV_TAB_CNT_C '건' INTO <LS_LIST>-GRPNR SEPARATED BY SPACE.
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_change
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_CHANGE .

  TRY.
      PERFORM CHECK_BEFORE_CHANGE_MAT_REQ. "// 사전점검.
      PERFORM CHANGE_MATERIAL_REQUISITION. "// 청구변경.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        GR_LIST->REFRESH( ).
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_delete
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_DELETE .

  TRY.
      PERFORM CHECK_BEFORE_DELETE_MAT_REQ. "// 사전점검.
      PERFORM DELETE_MATERIAL_REQUISITION. "// 청구삭제.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        GR_LIST->REFRESH( ).
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_req_comp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_REQ_COMP .

  GS_INDV_REQ = VALUE #( REQDAT = COND #( WHEN P_REQDT IS NOT INITIAL THEN P_REQDT
                                                                      ELSE SY-DATUM ) ).

  CALL SCREEN 200 STARTING AT 050 04
                  ENDING   AT 110 08.

  IF GV_SAVED EQ ABAP_TRUE.
    CLEAR GV_SAVED.
    GR_LIST->REFRESH( ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_req_bas_ft
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_REQ_BAS_FT .

  GS_FERT_REQ = VALUE #( REQDAT = COND #( WHEN P_REQDT IS NOT INITIAL THEN P_REQDT
                                          ELSE SY-DATUM ) ).

  CALL SCREEN 300 STARTING AT 050 04
                  ENDING   AT 110 08.

  IF GV_SAVED EQ ABAP_TRUE.
    CLEAR GV_SAVED.
    GR_LIST->REFRESH( ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_change_mat_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_CHANGE_MAT_REQ RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  GR_LIST->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  PERFORM GET_ROWS_SELECTED_CHG_MAT_REQ.

  IF GS_RESULT-INVALID IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
  ENDIF.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E12.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C03 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_chg_mat_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_CHG_MAT_REQ .

  CLEAR GS_RESULT.

  MODIFY GT_LIST FROM VALUE #( SEL = ABAP_FALSE
                               DEL = ABAP_FALSE )
                 TRANSPORTING SEL
                 WHERE SEL EQ ABAP_TRUE
                    OR DEL EQ ABAP_TRUE.

  GR_LIST->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_LIST REFERENCE INTO DATA(LR_LIST) INDEX LS_ROW-INDEX.

    CHECK SY-SUBRC IS INITIAL.

    GS_RESULT-SEL += 1.

    IF LR_LIST->ERROR IS NOT INITIAL.
      GS_RESULT-INVALID = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    IF LR_LIST->EBELN IS NOT INITIAL.
      GS_RESULT-INVALID = ABAP_TRUE.
      LR_LIST->MESSAGE  = TEXT-E01.
      CONTINUE.
    ENDIF.

    LR_LIST->SEL = ABAP_TRUE.
    GS_RESULT-TOTAL += 1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_material_requisition
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHANGE_MATERIAL_REQUISITION .
  DATA LT_ZGTPPT3420 TYPE TABLE OF ZGTPPT3420.
  DATA LT_ZGTPPT3422 TYPE TABLE OF ZGTPPT3422.

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

  PERFORM SELECT_ZGTPPT3420_FROM_LIST TABLES LT_ZGTPPT3420 LT_ZGTPPT3422.

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST)
                  WHERE SEL EQ ABAP_TRUE.
    READ TABLE LT_ZGTPPT3420 REFERENCE INTO DATA(LR_ZGTPPT3420) WITH KEY WERKS = LR_LIST->WERKS
                                                                         SPGCD = LR_LIST->SPGCD
                                                                         REQNO = LR_LIST->REQNO
                                                                         POSNR = LR_LIST->POSNR BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      IF LR_LIST->DRUMFLAG EQ ABAP_TRUE.
        PERFORM CHANGE_PURCHASE_REQUISITION TABLES LT_ZGTPPT3422 USING LR_LIST->* LR_ZGTPPT3420->*.
      ELSE.
        CLEAR LR_LIST->MESSAGE.
        LR_LIST->STATUS  = ICON_GREEN_LIGHT.
      ENDIF.

      PERFORM UPDATE_RESULT_CHG_MAT_REQ USING LR_ZGTPPT3420->* LR_LIST->*.
    ENDIF.
  ENDLOOP.

  GR_LIST->REFRESH( ).

  MESSAGE S000 WITH TEXT-S12.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_zgtppt3420_from_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SELECT_ZGTPPT3420_FROM_LIST  TABLES PT_ZGTPPT3420 STRUCTURE ZGTPPT3420
                                         PT_ZGTPPT3422 STRUCTURE ZGTPPT3422.

  SELECT ZT02~*
    FROM @GT_LIST   AS ZT01
    JOIN ZGTPPT3420 AS ZT02
      ON ZT01~WERKS EQ ZT02~WERKS
     AND ZT01~SPGCD EQ ZT02~SPGCD
     AND ZT01~REQNO EQ ZT02~REQNO
     AND ZT01~POSNR EQ ZT02~POSNR
   WHERE ZT01~SEL     EQ @ABAP_TRUE
     AND ZT02~ZSTATUS EQ @SPACE
   ORDER BY ZT02~WERKS, ZT02~SPGCD, ZT02~REQNO, ZT02~POSNR
    INTO TABLE @PT_ZGTPPT3420.

  SELECT ZT02~*
    FROM @GT_LIST   AS ZT01
    JOIN ZGTPPT3422 AS ZT02
      ON ZT01~WERKS EQ ZT02~WERKS
     AND ZT01~SPGCD EQ ZT02~SPGCD
     AND ZT01~REQNO EQ ZT02~REQNO
     AND ZT01~POSNR EQ ZT02~POSNR
   WHERE ZT01~SEL     EQ @ABAP_TRUE
     AND ZT02~ZSTATUS EQ @SPACE
   ORDER BY ZT02~WERKS, ZT02~SPGCD, ZT02~REQNO, ZT02~POSNR
    INTO TABLE @PT_ZGTPPT3422.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_delete_mat_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_DELETE_MAT_REQ RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  GR_LIST->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  PERFORM GET_ROWS_SELECTED_DEL_MAT_REQ.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
  ENDIF.

  IF GS_RESULT-INVALID IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E12.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C04 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_material_requisition
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DELETE_MATERIAL_REQUISITION .
  DATA LT_ZGTPPT3420 TYPE TABLE OF ZGTPPT3420.
  DATA LT_ZGTPPT3422 TYPE TABLE OF ZGTPPT3422.

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

  PERFORM SELECT_ZGTPPT3420_FROM_LIST TABLES LT_ZGTPPT3420 LT_ZGTPPT3422.

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST)
                  WHERE SEL EQ ABAP_TRUE.
    READ TABLE LT_ZGTPPT3420 REFERENCE INTO DATA(LR_ZGTPPT3420) WITH KEY WERKS = LR_LIST->WERKS
                                                                         SPGCD = LR_LIST->SPGCD
                                                                         REQNO = LR_LIST->REQNO
                                                                         POSNR = LR_LIST->POSNR BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      IF LR_LIST->DRUMFLAG EQ ABAP_TRUE.
        PERFORM DELETE_PURCHASE_REQUISITION USING LR_LIST->*.
      ELSE.
        LR_LIST->STATUS = ICON_GREEN_LIGHT.
        LR_LIST->DEL = ABAP_TRUE.
      ENDIF.

      PERFORM UPDATE_RESULT_DEL_MAT_REQ USING LR_ZGTPPT3420->* LR_LIST->*.
    ENDIF.
  ENDLOOP.

  DELETE GT_LIST WHERE DEL EQ ABAP_TRUE.

  GR_LIST->REFRESH( ).

  MESSAGE S000 WITH TEXT-S13.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_del_mat_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_DEL_MAT_REQ .

  CLEAR GS_RESULT.

  MODIFY GT_LIST FROM VALUE #( SEL = ABAP_FALSE
                               DEL = ABAP_FALSE )
                 TRANSPORTING SEL
                 WHERE SEL EQ ABAP_TRUE
                    OR DEL EQ ABAP_TRUE.

  GR_LIST->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_LIST REFERENCE INTO DATA(LR_LIST) INDEX LS_ROW-INDEX.

    CHECK SY-SUBRC IS INITIAL.

    GS_RESULT-SEL += 1.

    IF LR_LIST->EBELN IS NOT INITIAL.
      GS_RESULT-INVALID = ABAP_TRUE.
      LR_LIST->MESSAGE  = TEXT-E01.
      LR_LIST->STATUS   = ICON_RED_LIGHT.
      CONTINUE.
    ENDIF.

    LR_LIST->SEL = ABAP_TRUE.
    GS_RESULT-TOTAL += 1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_purchase_requisition
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DELETE_PURCHASE_REQUISITION  USING PS_LIST TYPE TY_S_LIST.

  DATA LS_PRHEADEREXP TYPE BAPIMEREQHEADER.
  DATA LT_RETURN TYPE TABLE OF BAPIRET2.

  DATA(LT_PRITEM)  = VALUE TY_BAPIMEREQITEMIMP( ( PREQ_ITEM  = PS_LIST-BNFPO
                                                  DELETE_IND = ABAP_TRUE  ) ).

  DATA(LT_PRITEMX) = VALUE TY_BAPIMEREQITEMX( ( PREQ_ITEM   = PS_LIST-BNFPO
                                                PREQ_ITEMX  = ABAP_TRUE
                                                DELETE_IND  = ABAP_TRUE ) ).

  CALL FUNCTION 'BAPI_PR_CHANGE'
    EXPORTING
      NUMBER      = PS_LIST-BANFN
    IMPORTING
      PRHEADEREXP = LS_PRHEADEREXP
    TABLES
      RETURN      = LT_RETURN
      PRITEM      = LT_PRITEM
      PRITEMX     = LT_PRITEMX.

  IF NOT LINE_EXISTS( LT_RETURN[ TYPE = ZGTPP_IF_CONST=>GC_RESULT-ERROR ] ).
    PS_LIST-STATUS  = ICON_GREEN_LIGHT.
    PS_LIST-DEL = ABAP_TRUE.
  ELSE.
    PS_LIST-STATUS  = ICON_RED_LIGHT.
    PS_LIST-MESSAGE = VALUE #( LT_RETURN[ TYPE = ZGTPP_IF_CONST=>GC_RESULT-ERROR ]-MESSAGE OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_purchase_requisition
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHANGE_PURCHASE_REQUISITION  TABLES PT_3422 STRUCTURE ZGTPPT3422
                                        USING PS_LIST TYPE TY_S_LIST
                                        PS_ZGTPPT3420 TYPE ZGTPPT3420.
  DATA LT_PRITEM     TYPE TY_BAPIMEREQITEMIMP.
  DATA LT_PRITEMX    TYPE TY_BAPIMEREQITEMX.
  DATA LT_PRACCOUNT  TYPE TY_BAPIMEREQACCOUNT.
  DATA LT_PRACCOUNTX TYPE TY_BAPIMEREQACCOUNTX.
  DATA LS_SALES TYPE TY_S_SALES.

  PERFORM DELETE_PURCHASE_REQUISITION USING PS_LIST.

  CHECK PS_LIST-DEL EQ ABAP_TRUE.

  LS_SALES-BNFPO = 10.
  LS_SALES = CORRESPONDING #( PS_ZGTPPT3420 ).

  DATA(LR_LIST) = REF #( PS_LIST ).
  DATA(LR_ZGTPPT3420) = REF #( PS_ZGTPPT3420 ).

  LOOP AT GR_LIST->MT_FCAT INTO DATA(LS_FCAT)
                           WHERE EDIT EQ ABAP_TRUE.
    LR_ZGTPPT3420->(LS_FCAT-FIELDNAME) = LR_LIST->(LS_FCAT-FIELDNAME).
  ENDLOOP.

  CLEAR GV_INCLUDE_SO.
  READ TABLE PT_3422 INTO DATA(LS_3422) WITH KEY REQNO = PS_ZGTPPT3420-REQNO
                                                 POSNR = PS_ZGTPPT3420-POSNR.
  IF SY-SUBRC EQ 0 AND LS_3422-SO_REF = ABAP_TRUE.
    GV_INCLUDE_SO = ABAP_TRUE.
  ENDIF.

  PERFORM SET_PARA_CREATE_REQ_BAPI USING PS_ZGTPPT3420 LT_PRITEM LT_PRITEMX LT_PRACCOUNT LT_PRACCOUNTX.

  PERFORM CREATE_PURCHASE_REQUISITION USING LS_SALES LT_PRITEM LT_PRITEMX LT_PRACCOUNT LT_PRACCOUNTX.

  PS_LIST-STATUS  = LS_SALES-STATUS.
  PS_LIST-MESSAGE = LS_SALES-MESSAGE.
  PS_LIST-BANFN   = LS_SALES-BANFN.
  PS_LIST-BNFPO   = LS_SALES-BNFPO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_RESULT_CHG_MAT_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_RESULT_CHG_MAT_REQ  USING PS_ZGTPPT3420 TYPE ZGTPPT3420
                                      PS_LIST       TYPE TY_S_LIST.

  PS_ZGTPPT3420 = VALUE #( BASE PS_ZGTPPT3420  LFIMG   = PS_LIST-LFIMG
                                               ERFME   = PS_LIST-ERFME
                                               REQDAT  = PS_LIST-REQDAT
                                               LGORT_T = PS_LIST-LGORT_T
                                               BANFN   = PS_LIST-BANFN
                                               BNFPO   = PS_LIST-BNFPO
                                               CHDAT   = GS_ZGTPPS1001-CHDAT
                                               CHTIM   = GS_ZGTPPS1001-CHTIM
                                               CHNAM   = GS_ZGTPPS1001-CHNAM ).

  IF PS_LIST-STATUS NE ICON_RED_LIGHT.
    MODIFY ZGTPPT3420 FROM PS_ZGTPPT3420.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_result_del_mat_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_RESULT_DEL_MAT_REQ  USING PS_ZGTPPT3420 TYPE ZGTPPT3420
                                      PS_LIST       TYPE TY_S_LIST.

  PS_ZGTPPT3420 = VALUE #( BASE PS_ZGTPPT3420  ZSTATUS = 'D'
                                               CHDAT   = GS_ZGTPPS1001-CHDAT
                                               CHTIM   = GS_ZGTPPS1001-CHTIM
                                               CHNAM   = GS_ZGTPPS1001-CHNAM ).

  CHECK PS_LIST-DEL EQ ABAP_TRUE.

  MODIFY ZGTPPT3420 FROM PS_ZGTPPT3420.

  IF PS_LIST-DRUMFLAG EQ ABAP_TRUE.
    UPDATE ZGTPPT3422
       SET ZSTATUS = 'D'
     WHERE WERKS EQ PS_LIST-WERKS
       AND SPGCD EQ PS_LIST-SPGCD
       AND REQNO EQ PS_LIST-REQNO
       AND POSNR EQ PS_LIST-POSNR.
  ELSE.
    UPDATE ZGTPPT3421
       SET ZSTATUS = 'D'
     WHERE WERKS EQ PS_LIST-WERKS
       AND SPGCD EQ PS_LIST-SPGCD
       AND REQNO EQ PS_LIST-REQNO
       AND POSNR EQ PS_LIST-POSNR.
  ENDIF.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_para_create_req_bapi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_PARA_CREATE_REQ_BAPI  USING  PS_ZGTPPT3420 TYPE ZGTPPT3420
                                      PT_PRITEM     TYPE TY_BAPIMEREQITEMIMP
                                      PT_PRITEMX    TYPE TY_BAPIMEREQITEMX
                                      PT_PRACCOUNT  TYPE TY_BAPIMEREQACCOUNT
                                      PT_PRACCOUNTX TYPE TY_BAPIMEREQACCOUNTX.

  DATA : LV_CHK_MATNR TYPE MATNR.
  CLEAR LV_CHK_MATNR.

* 사급 자재 확인
  SELECT SINGLE MATNR FROM MARC
    INTO LV_CHK_MATNR
    WHERE WERKS = PS_ZGTPPT3420-WERKS
      AND MATNR = PS_ZGTPPT3420-MATNR
      AND BESKZ = 'F'
      AND SOBSL = '30'.

  PT_PRITEM = VALUE #( BASE PT_PRITEM  ( PREQ_ITEM  = PS_ZGTPPT3420-BNFPO
                                         PUR_GROUP  = 'Z31'
                                         MATERIAL   = PS_ZGTPPT3420-MATNR
                                         PLANT      = PS_ZGTPPT3420-WERKS
                                         QUANTITY   = PS_ZGTPPT3420-LFIMG
                                         UNIT       = PS_ZGTPPT3420-ERFME
                                         DELIV_DATE = PS_ZGTPPT3420-REQDAT
                                         PREQ_NAME  = SY-UNAME
                                         ITEM_CAT   = COND #( WHEN LV_CHK_MATNR IS NOT INITIAL THEN 'L' ELSE '' )
                                         ACCTASSCAT = COND #( WHEN GV_INCLUDE_SO IS NOT INITIAL THEN 'M' ELSE '' )
                                         PURCH_ORG  = '1400' ) ).

  PT_PRITEMX = VALUE #( BASE PT_PRITEMX ( PREQ_ITEM  = PS_ZGTPPT3420-BNFPO
                                          PUR_GROUP  = ABAP_TRUE
                                          MATERIAL   = ABAP_TRUE
                                          PLANT      = ABAP_TRUE
                                          QUANTITY   = ABAP_TRUE
                                          UNIT       = ABAP_TRUE
                                          DELIV_DATE = ABAP_TRUE
                                          PREQ_NAME   = ABAP_TRUE
                                          ITEM_CAT   = ABAP_TRUE
                                          ACCTASSCAT = COND #( WHEN GV_INCLUDE_SO IS NOT INITIAL THEN ABAP_TRUE ELSE '' )
                                          PURCH_ORG  = ABAP_TRUE ) ).


  IF GV_INCLUDE_SO IS NOT INITIAL.
    PT_PRACCOUNT = VALUE #( BASE PT_PRACCOUNT ( PREQ_ITEM  = PS_ZGTPPT3420-BNFPO
                                                SERIAL_NO  = '01'
                                                SD_DOC     = PS_ZGTPPT3420-VBELN
                                                ITM_NUMBER = PS_ZGTPPT3420-VBELP ) ).

    PT_PRACCOUNTX = VALUE #( BASE PT_PRACCOUNTX ( PREQ_ITEM  = PS_ZGTPPT3420-BNFPO
                                                  SERIAL_NO  = '01'
                                                  PREQ_ITEMX = ABAP_TRUE
                                                  SERIAL_NOX = ABAP_TRUE
                                                  SD_DOC     = ABAP_TRUE
                                                  ITM_NUMBER = ABAP_TRUE ) ).

  ELSE.

*    IF PS_ZGTPPT3420-VBELN IS NOT INITIAL.
*      PT_PRACCOUNT = VALUE #( BASE PT_PRACCOUNT ( PREQ_ITEM  = PS_ZGTPPT3420-BNFPO
*                                                  SERIAL_NO  = '01'
*                                                  SD_DOC     = PS_ZGTPPT3420-VBELN
*                                                  ITM_NUMBER = PS_ZGTPPT3420-VBELP ) ).
*
*      PT_PRACCOUNTX = VALUE #( BASE PT_PRACCOUNTX ( PREQ_ITEM  = PS_ZGTPPT3420-BNFPO
*                                                    SERIAL_NO  = '01'
*                                                    PREQ_ITEMX = ABAP_TRUE
*                                                    SERIAL_NOX = ABAP_TRUE
*                                                    SD_DOC     = ABAP_TRUE
*                                                    ITM_NUMBER = ABAP_TRUE ) ).
*    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_result_crt_mat_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_RESULT_CRT_MAT_REQ  TABLES PT_ZGTPPT3420 STRUCTURE ZGTPPT3420
                                       PT_ZGTPPT3422 STRUCTURE ZGTPPT3422
                                 USING PS_SALES TYPE TY_S_SALES.

  IF PS_SALES-STATUS EQ ICON_GREEN_LIGHT.
    MODIFY GT_SALES FROM VALUE #( STATUS  = ICON_GREEN_LIGHT
                                  MESSAGE = TEXT-S01
                                  BANFN   = PS_SALES-BANFN
                                  STYLE   = GT_STYLE )
                    TRANSPORTING STATUS MESSAGE BANFN
                    WHERE WERKS  EQ PS_SALES-WERKS
                      AND REQNO  EQ PS_SALES-REQNO
                      AND STATUS NE ICON_GREEN_LIGHT
                      AND SEL    EQ ABAP_TRUE.

    MODIFY PT_ZGTPPT3420 FROM VALUE #( BANFN = PS_SALES-BANFN )
                         TRANSPORTING BANFN
                         WHERE WERKS EQ PS_SALES-WERKS
                           AND REQNO EQ PS_SALES-REQNO.

    TRY.
        MODIFY ZGTPPT3420 FROM TABLE PT_ZGTPPT3420.
        MODIFY ZGTPPT3422 FROM TABLE PT_ZGTPPT3422.

        COMMIT WORK AND WAIT.

      CATCH CX_ROOT INTO DATA(LR_ROOT).
        ROLLBACK WORK.
    ENDTRY.
  ELSE.
    MODIFY GT_SALES FROM VALUE #( STATUS  = ICON_RED_LIGHT
                                  MESSAGE = PS_SALES-MESSAGE
                                  BNFPO   = SPACE
                                  REQNO   = SPACE
                                  POSNR   = SPACE )
                    TRANSPORTING STATUS MESSAGE BNFPO REQNO POSNR
                    WHERE WERKS  EQ PS_SALES-WERKS
                      AND REQNO  EQ PS_SALES-REQNO
                      AND STATUS NE ICON_GREEN_LIGHT
                      AND SEL    EQ ABAP_TRUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_indv_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_INDV_REQ .
  DATA LV_ANSWER TYPE C.

  PERFORM CONFIRMATION_POPUP USING TEXT-C05 LV_ANSWER.

  CHECK LV_ANSWER EQ '1'.

  PERFORM CREATE_INDV_MAT_REQ.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_comp_chk
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_COMP_CHK .

  CLEAR GT_COMP.

  PERFORM MATERIAL_BOM_EXPL.

  CALL SCREEN 400 STARTING AT 010 02
                  ENDING   AT 120 16.

  IF GV_SAVED EQ ABAP_TRUE.
    LEAVE TO SCREEN 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  CHECK_FERT_REQ_BMENG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_FERT_REQ_BMENG INPUT.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_INDV_REQ_LFIMG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INDV_REQ_LFIMG INPUT.

  IF GS_INDV_REQ-LFIMG IS INITIAL.
    MESSAGE E031 WITH TEXT-F60 DISPLAY LIKE 'S'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form create_indv_mat_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CREATE_INDV_MAT_REQ .
  DATA LT_ZGTPPT3420 TYPE TABLE OF ZGTPPT3420.
  DATA LT_ZGTPPT3421 TYPE TABLE OF ZGTPPT3421.
  DATA LV_REQNO TYPE CHAR12.
  DATA LV_POSNR TYPE ZGTPPT3420-POSNR.

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

  PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' LV_REQNO.

  APPEND INITIAL LINE TO LT_ZGTPPT3420 REFERENCE INTO DATA(LR_ZGTPPT3420).

  LV_POSNR += 1.

  LR_ZGTPPT3420->* = CORRESPONDING #( GS_INDV_REQ ).
  LR_ZGTPPT3420->* = CORRESPONDING #( BASE ( LR_ZGTPPT3420->* ) GS_ZGTPPS1001 ).
  LR_ZGTPPT3420->* = VALUE #( BASE LR_ZGTPPT3420->*  REQNO = LV_REQNO+2
                                                     POSNR = LV_POSNR
                                                     WERKS = P_WERKS
                                                     SPGCD = P_SPGCD ).

  APPEND INITIAL LINE TO LT_ZGTPPT3421 REFERENCE INTO DATA(LR_ZGTPPT3421).
  LR_ZGTPPT3421->* = CORRESPONDING #( LR_ZGTPPT3420->* ).
  LR_ZGTPPT3421->* = VALUE #( BASE LR_ZGTPPT3421->*  REQNO = LR_ZGTPPT3420->REQNO
                                                     POSNR = LR_ZGTPPT3420->POSNR
                                                     BDMNG = LR_ZGTPPT3420->LFIMG
                                                     BDTER = LR_ZGTPPT3420->REQDAT
                                                     GUBUN = GC_GCATG-MANUAL_WORK ).

  APPEND INITIAL LINE TO GT_LIST REFERENCE INTO DATA(LR_LIST).
  LR_LIST->* = CORRESPONDING #( LR_ZGTPPT3420->* ).
  LR_LIST->* = VALUE #( BASE LR_LIST->*  MAKTX   = GS_INDV_REQ-MAKTX
                                         STATUS  = ICON_GREEN_LIGHT
                                         MESSAGE = TEXT-S01 ).

  TRY.
      MODIFY ZGTPPT3420 FROM TABLE LT_ZGTPPT3420.
      MODIFY ZGTPPT3421 FROM TABLE LT_ZGTPPT3421.

      COMMIT WORK AND WAIT.

      GV_SAVED = ABAP_TRUE.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.

  CASE GV_OKCODE.
    WHEN GC_FCODE-FERT_REQ.
      PERFORM USER_COMMAND_FERT_REQ.     "// 완제품 기준 청구.
  ENDCASE.

  CLEAR GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form user_command_fert_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_FERT_REQ .

  TRY.
*// 사전점검.
      PERFORM CHECK_BEFORE_FERT_REQ.

      PERFORM CREATE_FERT_BASED_MAT_REQ.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
      RETURN.
  ENDTRY.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_COMP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_COMP .

  LOOP AT GR_COMP->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'STUFE'.
        LR_FCAT->COLTEXT    = TEXT-F66.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'PDCAPROCCODE'.
        LR_FCAT->COLTEXT    = TEXT-F67.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'IDNRK'.
        LR_FCAT->COLTEXT    = TEXT-F68.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F18.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'MENGE'.
        LR_FCAT->COLTEXT    = TEXT-F79.

      WHEN 'LFIMG'.
        LR_FCAT->COLTEXT    = TEXT-F78.
        LR_FCAT->EDIT       = ABAP_TRUE.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F70.
        LR_FCAT->JUST       = 'C'.

      WHEN 'REQDAT'.
        LR_FCAT->COLTEXT    = TEXT-F21.
        LR_FCAT->JUST       = 'C'.

      WHEN 'LGFSB'.
        LR_FCAT->COLTEXT    = TEXT-F52.
        LR_FCAT->JUST       = 'C'.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MATERIAL_BOM_EXPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MATERIAL_BOM_EXPL .
  DATA LT_STPOX  TYPE TABLE OF STPOX.
  DATA LT_MATCAT TYPE TABLE OF CSCMAT.
  DATA LS_TOPMAT TYPE CSTMAT.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      CAPID                 = ZGTPP_IF_CONST=>GC_CAPID
      DATUV                 = GS_FERT_REQ-REQDAT
      MEHRS                 = ABAP_TRUE
      MTNRV                 = GS_FERT_REQ-MATNR
      WERKS                 = P_WERKS
      STLAN                 = GS_FERT_REQ-STLAN
      STLAL                 = GS_FERT_REQ-STLAL
      EMENG                 = GS_FERT_REQ-BMENG
    IMPORTING
      TOPMAT                = LS_TOPMAT
    TABLES
      STB                   = LT_STPOX
      MATCAT                = LT_MATCAT
    EXCEPTIONS
      ALT_NOT_FOUND         = 1
      CALL_INVALID          = 2
      MATERIAL_NOT_FOUND    = 3
      MISSING_AUTHORIZATION = 4
      NO_BOM_FOUND          = 5
      NO_PLANT_DATA         = 6
      NO_SUITABLE_BOM_FOUND = 7
      CONVERSION_ERROR      = 8
      OTHERS                = 9.

  SELECT DISTINCT MARC~MATNR, MARC~WERKS, MARC~EKGRP, MARC~LGFSB
    FROM @LT_STPOX AS ZT01
    JOIN MARC
      ON ZT01~IDNRK EQ MARC~MATNR
     AND ZT01~WERKS EQ MARC~WERKS
   ORDER BY MARC~MATNR, MARC~WERKS
    INTO TABLE @DATA(LT_MARC).

  SELECT ZT02~MATNR, ZT02~PDCAPROCCODE
    FROM @LT_MATCAT   AS ZT01
    JOIN ZGTPP_CV_MASTVAL AS ZT02
      ON ZT01~MATNR EQ ZT02~MATNR
     AND ZT02~WERKS EQ @P_WERKS
   ORDER BY ZT02~MATNR
    INTO TABLE @DATA(LT_MASTVAL).

  LOOP AT LT_STPOX INTO DATA(LS_STPOX)
                   WHERE MTART NOT IN GT_MTART.
    READ TABLE LT_MARC INTO DATA(LS_MARC) WITH KEY MATNR = LS_STPOX-IDNRK
                                                   WERKS = LS_STPOX-WERKS BINARY SEARCH.

    CHECK LS_MARC-EKGRP NE 'Z30'.

    READ TABLE LT_MATCAT  INTO DATA(LS_MATCAT)  WITH KEY INDEX = LS_STPOX-TTIDX.
    READ TABLE LT_MASTVAL INTO DATA(LS_MASTVAL) WITH KEY MATNR = LS_MATCAT-MATNR BINARY SEARCH.

    READ TABLE GT_COMP REFERENCE INTO DATA(LR_COMP) WITH KEY STUFE        = LS_STPOX-STUFE
                                                             PDCAPROCCODE = LS_MASTVAL-PDCAPROCCODE
                                                             IDNRK        = LS_STPOX-IDNRK.
    IF SY-SUBRC IS NOT INITIAL.
      APPEND INITIAL LINE TO GT_COMP REFERENCE INTO LR_COMP.
      LR_COMP->* = VALUE #( STUFE        = LS_STPOX-STUFE
                            PDCAPROCCODE = LS_MASTVAL-PDCAPROCCODE
                            IDNRK        = LS_STPOX-IDNRK
                            MAKTX        = LS_STPOX-OJTXP
                            MENGE        = LS_STPOX-MNGKO
                            LFIMG        = LS_STPOX-MNGKO
                            MEINS        = LS_STPOX-MEINS
                            REQDAT       = GS_FERT_REQ-REQDAT
                            LGFSB        = LS_MARC-LGFSB ).
    ELSE.
      LR_COMP->MENGE = LR_COMP->MENGE + LS_STPOX-MNGKO.
      LR_COMP->LFIMG = LR_COMP->MENGE.
    ENDIF.

    CLEAR: LS_MARC, LS_MASTVAL, LS_MATCAT.
  ENDLOOP.

  SORT GT_COMP BY STUFE PDCAPROCCODE IDNRK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_fert_based_mat_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CREATE_FERT_BASED_MAT_REQ .
  DATA LT_ZGTPPT3420 TYPE TABLE OF ZGTPPT3420.
  DATA LT_ZGTPPT3421 TYPE TABLE OF ZGTPPT3421.
  DATA LV_REQNO TYPE CHAR12.
  DATA LV_POSNR TYPE ZGTPPT3420-POSNR.

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

  PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' LV_REQNO.

  LOOP AT GT_COMP  INTO DATA(LS_KEY)
                  WHERE IDNRK NE SPACE
                    AND SEL   EQ ABAP_TRUE
                  GROUP BY ( IDNRK = LS_KEY-IDNRK )
                   INTO DATA(LT_GROUP).
    APPEND INITIAL LINE TO LT_ZGTPPT3420 REFERENCE INTO DATA(LR_ZGTPPT3420).

    LV_POSNR += 1.

    LOOP AT GROUP LT_GROUP INTO DATA(LS_COMP).
      IF LR_ZGTPPT3420->* IS INITIAL.
        LR_ZGTPPT3420->* = CORRESPONDING #( LS_COMP MAPPING MATNR   = IDNRK
                                                            ERFME   = MEINS
                                                            LGORT_T = LGFSB
                                                     EXCEPT LFIMG ).
        LR_ZGTPPT3420->* = CORRESPONDING #( BASE ( LR_ZGTPPT3420->* ) GS_ZGTPPS1001 ).
        LR_ZGTPPT3420->* = VALUE #( BASE LR_ZGTPPT3420->*  REQNO = LV_REQNO+2
                                                           POSNR = LV_POSNR
                                                           WERKS = P_WERKS
                                                           SPGCD = P_SPGCD ).
      ENDIF.

      APPEND INITIAL LINE TO LT_ZGTPPT3421 REFERENCE INTO DATA(LR_ZGTPPT3421).
      LR_ZGTPPT3421->* = CORRESPONDING #( LR_ZGTPPT3420->* ).
      LR_ZGTPPT3421->* = VALUE #( BASE LR_ZGTPPT3421->*  BDMNG = LS_COMP-LFIMG
                                                         MEINS = LS_COMP-MEINS
                                                         BDTER = LS_COMP-REQDAT
                                                         GUBUN = GC_GCATG-MANUAL_WORK ).

      LR_ZGTPPT3420->LFIMG += LR_ZGTPPT3421->BDMNG.
    ENDLOOP.

    APPEND INITIAL LINE TO GT_LIST REFERENCE INTO DATA(LR_LIST).
    LR_LIST->* = CORRESPONDING #( LR_ZGTPPT3420->* ).
    LR_LIST->* = VALUE #( BASE LR_LIST->*  MAKTX   = LS_COMP-MAKTX
                                           STATUS  = ICON_GREEN_LIGHT
                                           MESSAGE = TEXT-S01 ).
  ENDLOOP.

  TRY.
      MODIFY ZGTPPT3420 FROM TABLE LT_ZGTPPT3420.
      MODIFY ZGTPPT3421 FROM TABLE LT_ZGTPPT3421.

      COMMIT WORK AND WAIT.

      GV_SAVED = ABAP_TRUE.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_master_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MASTER_DATA .

  SELECT WERKS, LGORT, LGOBE
    INTO CORRESPONDING FIELDS OF TABLE @GT_T001L
    FROM T001L.

  SELECT MSEHI
    INTO CORRESPONDING FIELDS OF TABLE @GT_T006
    FROM T006.

  GT_MTART = VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = ZGTPP_IF_CONST=>GC_MTART-MCHF ) "). "0619 KSW
                                               ( LOW = ZGTPP_IF_CONST=>GC_MTART-MRM1 )
                                               ( LOW = ZGTPP_IF_CONST=>GC_MTART-MRM2 )
                                               ( LOW = ZGTPP_IF_CONST=>GC_MTART-MRM3 ) ).
*// 일반 자재.
  IF P_GNMAT EQ ABAP_TRUE.
    GT_STYLE = VALUE #( STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED  ( FIELDNAME = 'BDMNG' )
                                                                    ( FIELDNAME = 'AUSCH' )
                                                                    ( FIELDNAME = 'MEINS' )
                                                                    ( FIELDNAME = 'LGORT' )
                                                                    ( FIELDNAME = 'REQDAT' ) ).

  ELSE.
*// 포장 자재.
    GT_STYLE = VALUE #( STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED  ( FIELDNAME = 'DRUM_CNT' )
                                                                    ( FIELDNAME = 'REQDAT' )
                                                                    ( FIELDNAME = 'LGPRO' ) ).
  ENDIF.

  APPEND INITIAL LINE TO GT_CHAR_DETIAL REFERENCE INTO DATA(LR_CHAR_DETIAL).

  PERFORM BAPI_CHARACT_GETDETAIL USING LR_CHAR_DETIAL->* 'PD_GA_PACKAGE_METHOD'.

  SORT GT_CHAR_DETIAL BY ATNAM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_mreq
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_IN_MREQ  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                 PV_UCOMM TYPE SY-UCOMM.

  DATA LR_PROD  TYPE REF TO TY_S_PROD.
  DATA LR_SALES TYPE REF TO TY_S_SALES.

  IF P_GNMAT EQ ABAP_TRUE.
    LOOP AT PR_DATA_CHANGED->MP_MOD_ROWS->* REFERENCE INTO LR_PROD.
      READ TABLE PR_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_CELL)
                                               WITH KEY TABIX = SY-TABIX.

      PERFORM FIELD_VALID_CHECK_IN_PROD USING PR_DATA_CHANGED LS_CELL LR_PROD->*.
      PERFORM MODIFY_CELL_IN_PROD       USING PR_DATA_CHANGED LS_CELL LR_PROD->*.
    ENDLOOP.
  ELSE.
    LOOP AT PR_DATA_CHANGED->MP_MOD_ROWS->* REFERENCE INTO LR_SALES.
      READ TABLE PR_DATA_CHANGED->MT_MOD_CELLS INTO LS_CELL
                                               WITH KEY TABIX = SY-TABIX.

      PERFORM FIELD_VALID_CHECK_IN_SALES USING LR_SALES->*.
      PERFORM MODIFY_CELL_IN_SALES       USING PR_DATA_CHANGED LS_CELL LR_SALES->*.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_IN_LIST  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                 PV_UCOMM TYPE SY-UCOMM.

  DATA LR_LIST TYPE REF TO TY_S_LIST.

  LOOP AT PR_DATA_CHANGED->MP_MOD_ROWS->* REFERENCE INTO LR_LIST.
    READ TABLE PR_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_CELL)
                                             WITH KEY TABIX = SY-TABIX.

    PERFORM FIELD_VALID_CHECK_IN_LIST USING LR_LIST->*.
    PERFORM MODIFY_CELL_IN_LIST       USING PR_DATA_CHANGED LS_CELL LR_LIST->*.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_prod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM FIELD_VALID_CHECK_IN_PROD  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                      PS_CELL TYPE LVC_S_MODI
                                      PS_PROD TYPE TY_S_PROD.

  CLEAR: PS_PROD-MESSAGE, PS_PROD-RETURN.

  PERFORM CHECK_INPUT_VALUE_IN_PROD USING PR_DATA_CHANGED PS_CELL PS_PROD.
  PERFORM CHECK_MANDT_FIELD_IN_PROD USING PS_PROD.

  IF PS_PROD-RETURN IS NOT INITIAL.
    PS_PROD-MESSAGE = VALUE #( PS_PROD-RETURN[ 1 ]-MESSAGE OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_prod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE_IN_PROD  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                      PS_CELL TYPE LVC_S_MODI
                                      PS_PROD TYPE TY_S_PROD.
*// 현장저장위치.
  IF PS_PROD-LGORT IS NOT INITIAL.
    READ TABLE GT_T001L TRANSPORTING NO FIELDS WITH TABLE KEY WERKS = PS_PROD-WERKS
                                                              LGORT = PS_PROD-LGORT.
    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E366(VL) WITH PS_PROD-LGORT PS_PROD-WERKS INTO DATA(LV_MESSAGE).
      PS_PROD-RETURN = VALUE #( BASE PS_PROD-RETURN ( TYPE = 'E' FIELD = TEXT-F22 MESSAGE = LV_MESSAGE ) ).
    ENDIF.
  ENDIF.

*// 총 소요 수량.
  DATA(LV_CHG_BDMNG) = XSDBOOL( LINE_EXISTS( PR_DATA_CHANGED->MT_MOD_CELLS[ TABIX = PS_CELL-TABIX FIELDNAME = 'BDMNG' ] ) ).
  DATA(LV_CHG_AUSCH) = XSDBOOL( LINE_EXISTS( PR_DATA_CHANGED->MT_MOD_CELLS[ TABIX = PS_CELL-TABIX FIELDNAME = 'AUSCH' ] ) ).

  IF LV_CHG_AUSCH EQ ABAP_TRUE AND PS_PROD-ORDNO IS NOT INITIAL.
    APPEND INITIAL LINE TO GT_COMP_SCRAP REFERENCE INTO DATA(LR_COMP_SCRAP).
    LR_COMP_SCRAP->* = CORRESPONDING #( PS_PROD ).
    LR_COMP_SCRAP->TABIX = PS_CELL-ROW_ID.
  ENDIF.

  IF LV_CHG_BDMNG EQ ABAP_FALSE AND LV_CHG_AUSCH EQ ABAP_TRUE.
    PS_PROD-BDMNG = PS_PROD-REQMN + ( PS_PROD-REQMN * PS_PROD-AUSCH / 100 ).
  ENDIF.

*// 소요 단위.
  IF PS_PROD-MEINS IS NOT INITIAL.
    READ TABLE GT_T006 TRANSPORTING NO FIELDS WITH TABLE KEY MSEHI = PS_PROD-MEINS.
    IF SY-SUBRC IS NOT INITIAL.
      PS_PROD-RETURN = VALUE #( BASE PS_PROD-RETURN ( TYPE = 'E' FIELD = TEXT-F20 MESSAGE = TEXT-E21 ) ).
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_prod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_MANDT_FIELD_IN_PROD  USING PS_PROD TYPE TY_S_PROD.

*//  총 소요 수량.
  IF PS_PROD-BDMNG IS INITIAL.
    MESSAGE E026 WITH TEXT-F19 INTO DATA(LV_MESSAGE).
    PS_PROD-RETURN = VALUE #( BASE PS_PROD-RETURN ( TYPE = 'E' FIELD = TEXT-F19 MESSAGE = LV_MESSAGE ) ).
  ENDIF.

*// 소요 단위.
  IF PS_PROD-MEINS IS INITIAL.
    MESSAGE E026 WITH TEXT-F20 INTO LV_MESSAGE.
    PS_PROD-RETURN = VALUE #( BASE PS_PROD-RETURN ( TYPE = 'E' FIELD = TEXT-F20 MESSAGE = LV_MESSAGE ) ).
  ENDIF.

*// 입고 요청일.
  IF PS_PROD-REQDAT IS INITIAL.
    MESSAGE E026 WITH TEXT-F21 INTO LV_MESSAGE.
    PS_PROD-RETURN = VALUE #( BASE PS_PROD-RETURN ( TYPE = 'E' FIELD = TEXT-F21 MESSAGE = LV_MESSAGE ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_prod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_CELL_IN_PROD  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                PS_CELL TYPE LVC_S_MODI
                                PS_PROD TYPE TY_S_PROD.

  PR_DATA_CHANGED->MODIFY_CELL( I_ROW_ID = PS_CELL-ROW_ID :
                                I_FIELDNAME = 'BDMNG'   I_VALUE = PS_PROD-BDMNG ),
                                I_FIELDNAME = 'MESSAGE' I_VALUE = PS_PROD-MESSAGE ),
                                I_FIELDNAME = 'RETURN'  I_VALUE = PS_PROD-RETURN ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_sales
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM FIELD_VALID_CHECK_IN_SALES  USING PS_SALES TYPE TY_S_SALES.

  CLEAR: PS_SALES-MESSAGE, PS_SALES-RETURN.

  PERFORM CHECK_INPUT_VALUE_IN_SALES USING PS_SALES.
  PERFORM CHECK_MANDT_FIELD_IN_SALES USING PS_SALES.

  IF PS_SALES-RETURN IS NOT INITIAL.
    PS_SALES-MESSAGE = VALUE #( PS_SALES-RETURN[ 1 ]-MESSAGE OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_sales
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE_IN_SALES USING PS_SALES TYPE TY_S_SALES.

*// 현장저장위치.
  IF PS_SALES-LGPRO IS NOT INITIAL.
    READ TABLE GT_T001L TRANSPORTING NO FIELDS WITH TABLE KEY WERKS = PS_SALES-WERKS
                                                              LGORT = PS_SALES-LGPRO.
    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E366(VL) WITH PS_SALES-LGPRO PS_SALES-WERKS INTO DATA(LV_MESSAGE).
      PS_SALES-RETURN = VALUE #( BASE PS_SALES-RETURN ( TYPE = 'E' FIELD = TEXT-F22 MESSAGE = LV_MESSAGE ) ).
    ENDIF.
  ENDIF.

  IF PS_SALES-DRUM_CNT LE 0.
    PS_SALES-RETURN = VALUE #( BASE PS_SALES-RETURN ( TYPE = 'E' FIELD = TEXT-F49 MESSAGE = TEXT-E06 ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_sales
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_MANDT_FIELD_IN_SALES  USING PS_SALES TYPE TY_S_SALES.

*// 입고 요청일.
  IF PS_SALES-REQDAT IS INITIAL.
    MESSAGE E026 WITH TEXT-F20 INTO DATA(LV_MESSAGE).
    PS_SALES-RETURN = VALUE #( BASE PS_SALES-RETURN ( TYPE = 'E' FIELD = TEXT-F21 MESSAGE = LV_MESSAGE ) ).
  ENDIF.

*// 현장저장위치.
  IF PS_SALES-LGPRO IS INITIAL.
    MESSAGE E026 WITH TEXT-F22 INTO LV_MESSAGE.
    PS_SALES-RETURN = VALUE #( BASE PS_SALES-RETURN ( TYPE = 'E' FIELD = TEXT-F22 MESSAGE = LV_MESSAGE ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_sales
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_CELL_IN_SALES  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                 PS_CELL  TYPE LVC_S_MODI
                                 PS_SALES TYPE TY_S_SALES.

  PR_DATA_CHANGED->MODIFY_CELL( I_ROW_ID    = PS_CELL-ROW_ID :
                                I_FIELDNAME = 'MESSAGE'  I_VALUE = PS_SALES-MESSAGE ),
                                I_FIELDNAME = 'RETURN'   I_VALUE = PS_SALES-RETURN ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM FIELD_VALID_CHECK_IN_LIST  USING PS_LIST TYPE TY_S_LIST.

  CLEAR: PS_LIST-ERROR, PS_LIST-MESSAGE, PS_LIST-RETURN.

  PERFORM CHECK_INPUT_VALUE_IN_LIST USING PS_LIST.
  PERFORM CHECK_MANDT_FIELD_IN_LIST USING PS_LIST.

  IF PS_LIST-RETURN IS NOT INITIAL.
    PS_LIST-ERROR  = ABAP_TRUE.
    PS_LIST-MESSAGE = VALUE #( PS_LIST-RETURN[ 1 ]-MESSAGE OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_CELL_IN_LIST  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                PS_CELL TYPE LVC_S_MODI
                                PS_LIST TYPE TY_S_LIST.

  PR_DATA_CHANGED->MODIFY_CELL( I_ROW_ID    = PS_CELL-ROW_ID :
                                I_FIELDNAME = 'ERROR'   I_VALUE = PS_LIST-ERROR ),
                                I_FIELDNAME = 'MESSAGE' I_VALUE = PS_LIST-MESSAGE ),
                                I_FIELDNAME = 'RETURN'  I_VALUE = PS_LIST-RETURN ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE_IN_LIST  USING  PS_LIST TYPE TY_S_LIST.

*// 현장저장위치.
  IF PS_LIST-LGORT_T IS NOT INITIAL.
    READ TABLE GT_T001L TRANSPORTING NO FIELDS WITH TABLE KEY WERKS = PS_LIST-WERKS
                                                              LGORT = PS_LIST-LGORT_T.
    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E366(VL) WITH PS_LIST-LGORT_T PS_LIST-WERKS INTO DATA(LV_MESSAGE).
      PS_LIST-RETURN = VALUE #( BASE PS_LIST-RETURN ( TYPE = 'E' FIELD = TEXT-F22 MESSAGE = LV_MESSAGE ) ).
    ENDIF.
  ENDIF.

*// 청구 단위.
  IF PS_LIST-ERFME IS NOT INITIAL.
    READ TABLE GT_T006 TRANSPORTING NO FIELDS WITH TABLE KEY MSEHI = PS_LIST-ERFME.
    IF SY-SUBRC IS NOT INITIAL.
      PS_LIST-RETURN = VALUE #( BASE PS_LIST-RETURN ( TYPE = 'E' FIELD = TEXT-F61 MESSAGE = TEXT-E22 ) ).
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_MANDT_FIELD_IN_LIST  USING PS_LIST TYPE TY_S_LIST.

*//  청구 수량.
  IF PS_LIST-LFIMG IS INITIAL.
    MESSAGE E026 WITH TEXT-F60 INTO DATA(LV_MESSAGE).
    PS_LIST-RETURN = VALUE #( BASE PS_LIST-RETURN ( TYPE = 'E' FIELD = TEXT-F60 MESSAGE = LV_MESSAGE ) ).
  ENDIF.

*// 청구 단위.
  IF PS_LIST-ERFME IS INITIAL.
    MESSAGE E026 WITH TEXT-F61 INTO LV_MESSAGE.
    PS_LIST-RETURN = VALUE #( BASE PS_LIST-RETURN ( TYPE = 'E' FIELD = TEXT-F61 MESSAGE = LV_MESSAGE ) ).
  ENDIF.

*// 입고 요청일.
  IF PS_LIST-REQDAT IS INITIAL.
    MESSAGE E026 WITH TEXT-F21 INTO LV_MESSAGE.
    PS_LIST-RETURN = VALUE #( BASE PS_LIST-RETURN ( TYPE = 'E' FIELD = TEXT-F21 MESSAGE = LV_MESSAGE ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click_in_mreq
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK_IN_MREQ  USING PS_ROW    TYPE LVC_S_ROID
                                 PS_COLUMN TYPE LVC_S_COL.

*// 청구,오더 기반,일반 자재.
  IF P_GNMAT EQ ABAP_TRUE.
    PERFORM DOUBLE_CLICK_FOR_PROD USING PS_ROW PS_COLUMN.
  ELSE.
*// 청구,오더 기반,드럼 자재.
    PERFORM DOUBLE_CLICK_FOR_SALES USING PS_ROW PS_COLUMN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK_IN_LIST  USING PS_ROW    TYPE LVC_S_ROID
                                 PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LS_LIST) = GT_LIST[ PS_ROW-ROW_ID ].

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'BANFN' OR 'BNFPO'. "// 구매요청 조회.
      PERFORM CALL_TRANSACTION_ME53 USING LS_LIST-BANFN LS_LIST-BNFPO.

    WHEN 'EBELN' OR 'EBELP'. "// 구매오더 조회.
      PERFORM CALL_TRANSACTION_ME23 USING LS_LIST-EBELN LS_LIST-EBELP.

    WHEN 'GRPNR'.
      CHECK LS_LIST-GRPNR IS NOT INITIAL.
      PERFORM CALL_TRANSACTION_ZGTPPR2350 USING LS_LIST-REQNO LS_LIST-POSNR.




  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click_for_prod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK_FOR_PROD  USING PS_ROW    TYPE LVC_S_ROID
                                  PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LS_PROD) = GT_PROD[ PS_ROW-ROW_ID ].

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'ORDNR'. "
      CASE LS_PROD-ORDTY.
        WHEN GC_ORDTY-PRD.   "// 생산오더 조회.
          PERFORM CALL_TRANSACTION_CO03 USING LS_PROD-ORDNR.

        WHEN GC_ORDTY-PLN.   "// 계획오더 조회.
          PERFORM CALL_TRANSACTION_MD13 USING LS_PROD-ORDNR.
      ENDCASE.

    WHEN 'RSNUM' OR 'RSPOS'. "// 자재예약 조회.
      PERFORM CALL_TRANSACTION_MB23 USING LS_PROD-RSNUM.

*** 2026.06.25 ksw ***
    WHEN 'ORDNO'. "// 판매 오더.
      PERFORM CALL_TRANSACTION_VA03_01 USING LS_PROD-ORDNO.
    WHEN 'ORDNR_I'. "// 상세오더조회.
      IF LS_PROD-ORDNR_I IS NOT INITIAL.
        PERFORM DISP_POPUP_ORDERS USING LS_PROD.
      ENDIF.
*** 2026.06.25 ksw ***

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click_for_sales
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK_FOR_SALES  USING PS_ROW    TYPE LVC_S_ROID
                                   PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LS_SALES) = GT_SALES[ PS_ROW-ROW_ID ].

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'VBELN' OR 'VBELP'. "// 영업문서 조회.
      PERFORM CALL_TRANSACTION_VA03 USING LS_SALES-VBELN LS_SALES-VBELP.

    WHEN 'BANFN' OR 'BNFPO'. "// 구매요청 조회.
      PERFORM CALL_TRANSACTION_ME53 USING LS_SALES-BANFN LS_SALES-BNFPO.

    WHEN 'ICON_ORDER'. "// 생산오더 정보 조회
      IF LS_SALES-ICON_ORDER IS NOT INITIAL.
        PERFORM DISP_PRD_ORDER USING LS_SALES.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_TRANSACTION_CO03
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_CO03  USING PV_AUFNR.

  CHECK PV_AUFNR IS NOT INITIAL.

  SET PARAMETER ID 'ANR' FIELD PV_AUFNR.

  TRY.
      CALL TRANSACTION 'CO03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.

    CATCH CX_SY_AUTHORIZATION_ERROR.
      MESSAGE E077(S#) WITH 'CO03' DISPLAY LIKE 'S'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_transaction_MD13
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_MD13  USING PV_PLNUM.

  CHECK PV_PLNUM IS NOT INITIAL.

  SET PARAMETER ID 'PAF' FIELD PV_PLNUM.

  TRY.
      CALL TRANSACTION 'MD13' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.

    CATCH CX_SY_AUTHORIZATION_ERROR.
      MESSAGE E077(S#) WITH 'MD13' DISPLAY LIKE 'S'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_transaction_MB23
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_MB23  USING  PV_RSNUM.

  CHECK PV_RSNUM IS NOT INITIAL.

  SET PARAMETER ID 'RES' FIELD PV_RSNUM.

  TRY.
      CALL TRANSACTION 'MB23' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.

    CATCH CX_SY_AUTHORIZATION_ERROR.
      MESSAGE E077(S#) WITH 'MB23' DISPLAY LIKE 'S'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_packaging_mat_char
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_PACKAGING_MAT_CHAR  USING PS_SALES TYPE TY_S_SALES
                                   PT_CHAR  TYPE TY_T_CHAR
                                   PT_PACKING_MAT TYPE TY_T_PACKING_MAT.

  DATA LT_PACK_MAT TYPE TABLE OF TY_S_PACKING_MAT.
  DATA LS_PACK_MAT TYPE TY_S_PACKING_MAT.
  DATA LV_DRUM_MAT TYPE MARA-MATNR.
  DATA LV_VALUE TYPE CHA_CLASS_VIEW-SOLLWERT .

  READ TABLE PT_CHAR TRANSPORTING NO FIELDS WITH KEY VBELN = PS_SALES-VBELN
                                                     POSNR = PS_SALES-VBELP BINARY SEARCH.
  CHECK SY-SUBRC IS INITIAL.

  DATA(LV_TABIX) = SY-TABIX.

  PS_SALES-NEWDRUM       = ZGTPP_IF_CONST=>GC_YN-NO.  "// 신드럼
  PS_SALES-IRONDRUM      = ZGTPP_IF_CONST=>GC_YN-NO.  "// 철드럼
  PS_SALES-DRUMTITLEMARK = ZGTPP_IF_CONST=>GC_YN-NO.  "// 드럼자판 인쇄유무
  PS_SALES-FLANGE_PROT   = ZGTPP_IF_CONST=>GC_YN-NO.  "// 약판 골판지 유무

  LOOP AT PT_CHAR INTO DATA(LS_CHAR)
                  FROM LV_TABIX.
    IF LS_CHAR-VBELN NE PS_SALES-VBELN OR LS_CHAR-POSNR NE PS_SALES-VBELP.
      EXIT.
    ENDIF.

    CASE LS_CHAR-ATNAM.
      WHEN 'SAP_MILLCA_PACKAGING_CAT'. "// 포장재 유형.
        IF LS_CHAR-ATWRT EQ 'DM'.
          DATA(LV_DM) = ABAP_TRUE.
        ENDIF.

      WHEN 'PD_CA_PACKMARK_STATUS'.    "// 포장재/마킹지정 상태.
        IF LS_CHAR-ATWRT EQ 'CM'.
          DATA(LV_CM) = ABAP_TRUE.
        ENDIF.

      WHEN 'PD_GA_DRUM_GUBUN'.         "// 드럼 구분.
        PS_SALES-DRUM_GUBUN = LS_CHAR-ATWRT.

        IF LS_CHAR-ATWRT CP 'E' OR LS_CHAR-ATWRT EQ 'SF'.
          DATA(LV_DRUM_GUBUN) = ABAP_TRUE.
        ENDIF.

        IF LS_CHAR-ATWRT EQ 'SF'.
          PS_SALES-IRONDRUM = ZGTPP_IF_CONST=>GC_YN-YES. "// 철드럼
        ENDIF.

      WHEN 'SAP_MILLCA_FACTOR'.        "// 조장수
        PS_SALES-DRUM_CNT = LS_CHAR-ATFLV.

      WHEN 'PD_GA_NEW_DRUM_YN'.        "// 신드럼 사용여부
        IF LS_CHAR-ATWRT EQ ZGTPP_IF_CONST=>GC_YN-YES.
          PS_SALES-NEWDRUM = ZGTPP_IF_CONST=>GC_YN-YES.
        ENDIF.

      WHEN 'MS-DRUMTITLEMARK'.        "// 드럼 자판 인쇄여부
        IF LS_CHAR-ATWRT EQ ZGTPP_IF_CONST=>GC_YN-YES.
          PS_SALES-DRUMTITLEMARK = ZGTPP_IF_CONST=>GC_YN-YES.
        ENDIF.

      WHEN 'PD_GA_FLANGE_PROT_YN'.    "// 약판골판지 사용우무
        IF LS_CHAR-ATWRT EQ ZGTPP_IF_CONST=>GC_YN-YES.
          PS_SALES-FLANGE_PROT = ZGTPP_IF_CONST=>GC_YN-YES.
        ENDIF.

      WHEN 'PD_GA_PACKAGE_METHOD'.    "// 포장구분.
        PS_SALES-PACK_METHOD = LS_CHAR-ATWRT.

        READ TABLE GT_CHAR_DETIAL INTO DATA(LS_CHAR_DETIAL) WITH KEY ATNAM = LS_CHAR-ATNAM BINARY SEARCH.
        IF SY-SUBRC IS INITIAL.
          READ TABLE LS_CHAR_DETIAL-VAL_DESC INTO DATA(LS_VAL_DESC) WITH KEY VALUE_CHAR = LS_CHAR-ATWRT.
          IF SY-SUBRC IS INITIAL.
            PS_SALES-PACK_TXT = LS_VAL_DESC-DESCRIPTION.
          ENDIF.
        ENDIF.

      WHEN 'PD_CA_PACKING_DM' OR 'PD_CA_PACKING_BX' OR 'PD_CA_PACKING_PA' OR 'PD_CA_PACKING_SK' OR 'PD_CA_PACKING_PW'.
        IF LS_CHAR-ATWRT IS NOT INITIAL.
          LS_PACK_MAT = VALUE #( MATNR = LS_CHAR-ATWRT ).
          PERFORM CONV_EXIT_MATN1_INPUT USING LS_PACK_MAT-MATNR.

          READ TABLE PT_PACKING_MAT INTO DATA(LS_PACKING_MAT) WITH KEY MATNR = LS_PACK_MAT-MATNR BINARY SEARCH.
          IF SY-SUBRC IS INITIAL.
            IF PS_SALES-PACK_MAT IS INITIAL.
              PS_SALES = VALUE #( BASE PS_SALES  PACK_MAT     = LS_PACKING_MAT-MATNR
                                                 PACK_MAT_TXT = LS_PACKING_MAT-MAKTX
                                                 LGPRO        = LS_PACKING_MAT-LGPRO
                                                 MEINS        = LS_PACKING_MAT-MEINS
                                                 IS_DRUM      = COND #( WHEN LS_CHAR-ATNAM EQ 'PD_CA_PACKING_DM' THEN ABAP_TRUE ) ).
            ELSE.
              APPEND VALUE #( MATNR   = LS_PACKING_MAT-MATNR
                              MAKTX   = LS_PACKING_MAT-MAKTX
                              LGPRO   = LS_PACKING_MAT-LGPRO
                              MEINS   = LS_PACKING_MAT-MEINS
                              IS_DRUM = COND #( WHEN LS_CHAR-ATNAM EQ 'PD_CA_PACKING_DM' THEN ABAP_TRUE ) ) TO LT_PACK_MAT.
            ENDIF.

            IF LS_CHAR-ATNAM EQ 'PD_CA_PACKING_DM'.         "// 포장재(드럼).
              LV_DRUM_MAT = PS_SALES-PACK_MAT.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN 'PD_CA_SKID_YN'.    "// SKID 사용유무.
        PS_SALES-SKID_YN = LS_CHAR-ATWRT.

      WHEN 'PD_CA_PW_FACTOR'.    "// 포장목 개수.
        PS_SALES-PW_FACTOR = LS_CHAR-ATFLV.

      WHEN 'PD_GA_HAWA_GUBUN'.    "// 상품 구분.
        PS_SALES-HAWA_GUBUN = LS_CHAR-ATWRT.

      WHEN 'PD_GA_PRINT_METHOD'.    "// 프린트 방법.
        PS_SALES-PRINT_METHOD = LS_CHAR-ATWRT.
    ENDCASE.
  ENDLOOP.

  IF PS_SALES-PACK_MAT IS INITIAL.
    CLEAR: PS_SALES-NEWDRUM, PS_SALES-IRONDRUM, PS_SALES-DRUMTITLEMARK, PS_SALES-FLANGE_PROT.
  ENDIF.

  IF LV_CM EQ ABAP_TRUE. "// 확정상태.
    CLEAR PS_SALES-EXCEPT.
  ELSEIF PS_SALES-IS_DRUM IS NOT INITIAL.
    IF LV_DM EQ ABAP_TRUE AND LV_DRUM_GUBUN EQ ABAP_TRUE.
      CLEAR PS_SALES-EXCEPT.
    ENDIF.
  ENDIF.

  LOOP AT LT_PACK_MAT INTO LS_PACK_MAT.
    APPEND INITIAL LINE TO GT_PACK_MAT REFERENCE INTO DATA(LR_PACK_MAT).
    LR_PACK_MAT->* = VALUE #( BASE PS_SALES  PACK_MAT     = LS_PACK_MAT-MATNR
                                             PACK_MAT_TXT = LS_PACK_MAT-MAKTX
                                             LGPRO        = LS_PACK_MAT-LGPRO
                                             MEINS        = LS_PACK_MAT-MEINS
                                             IS_DRUM      = LS_PACK_MAT-IS_DRUM
                                             EXCEPT       = ABAP_TRUE ).

    IF LV_CM EQ ABAP_TRUE. "// 확정상태.
      CLEAR LR_PACK_MAT->EXCEPT.
    ELSEIF LR_PACK_MAT->IS_DRUM IS NOT INITIAL.
      IF LV_DM EQ ABAP_TRUE AND LV_DRUM_GUBUN EQ ABAP_TRUE.
        CLEAR LR_PACK_MAT->EXCEPT.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_ref_sales
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_DATA_REF_SALES  USING PT_CHAR TYPE TY_T_CHAR
                               PT_PACKING_MAT TYPE TY_T_PACKING_MAT
                               PT_ZGTPPT3422  TYPE TY_T_ZGTPPT3422.

  SELECT DISTINCT ZT02~VBELN, ZT02~POSNR, ZT02~ATNAM, ZT02~ATWRT, ZT02~ATFLV
    FROM @GT_SALES AS ZT01
    JOIN ZGTMM_CV_BD_GET_VCOFSO AS ZT02
      ON ZT01~VBELN EQ ZT02~VBELN
     AND ZT01~VBELP EQ ZT02~POSNR
   ORDER BY ZT02~VBELN, ZT02~POSNR,ZT02~ATNAM
    INTO CORRESPONDING FIELDS OF TABLE @PT_CHAR.

  SELECT MARA~MATNR, MARA~MEINS, MAKT~MAKTX, MARC~LGPRO
    FROM MARA
    LEFT JOIN MARC
      ON MARA~MATNR EQ MARC~MATNR
     AND MARC~WERKS EQ @P_WERKS
    LEFT JOIN MAKT
      ON MARA~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   WHERE MARA~MTART LIKE 'MRM%'
   ORDER BY MARA~MATNR
    INTO CORRESPONDING FIELDS OF TABLE @PT_PACKING_MAT.

  SELECT ZT02~WERKS, ZT02~SPGCD, ZT02~REQNO, ZT02~POSNR,
         ZT02~VBELN, ZT02~VBELP, ZT02~MATNR, ZT02~BDTER
    FROM @GT_SALES  AS ZT01
    JOIN ZGTPPT3422 AS ZT02
      ON ZT01~WERKS   EQ ZT02~WERKS
     AND ZT01~SPGCD   EQ ZT02~SPGCD
     AND ZT01~VBELN   EQ ZT02~VBELN
     AND ZT01~VBELP   EQ ZT02~VBELP
     AND ZT02~ZSTATUS EQ @SPACE
   ORDER BY ZT02~VBELN, ZT02~VBELP
    INTO CORRESPONDING FIELDS OF TABLE @PT_ZGTPPT3422.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form enqueue_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ENQUEUE_TABLE .

  CALL FUNCTION 'ENQUEUE_E_TABLE'
    EXPORTING
      TABNAME        = GC_TABLE
      VARKEY         = CONV VIM_ENQKEY( |{ P_WERKS }{ P_SPGCD }| )
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

  IF SY-SUBRC IS NOT INITIAL.
    MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
                                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 DISPLAY LIKE 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form dequeue_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DEQUEUE_TABLE .

  CALL FUNCTION 'DEQUEUE_E_TABLE'
    EXPORTING
      TABNAME = GC_TABLE
      VARKEY  = CONV VIM_ENQKEY( |{ P_WERKS }{ P_SPGCD }| ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_ref_prd_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_DATA_REF_PRD_ORDER  USING PT_ZGTPPT3421 TYPE TY_T_ZGTPPT3421
                                   PT_VBEP       TYPE TY_T_VBEP
                                   PT_ORDSYVAL   TYPE TY_T_ORDSYVAL
                                   PT_ZGTPPT2010 TYPE TY_T_ZGTPPT2010
                                   PT_ZGTPPT2340 TYPE TY_T_ZGTPPT2340.

  SELECT ZT02~WERKS, ZT02~SPGCD, ZT02~REQNO, ZT02~POSNR,
         ZT02~PLNUM, ZT02~AUFNR, ZT02~RSNUM, ZT02~RSPOS, ZT02~MATNR, ZT02~BDTER
    FROM @GT_PROD   AS ZT01
    JOIN ZGTPPT3421 AS ZT02
      ON ZT01~WERKS   EQ ZT02~WERKS
     AND ZT01~SPGCD   EQ ZT02~SPGCD
     AND ZT01~RSNUM   EQ ZT02~RSNUM
     AND ZT01~RSPOS   EQ ZT02~RSPOS
     AND ZT02~ZSTATUS EQ @SPACE
   ORDER BY ZT02~RSNUM, ZT02~RSPOS
    INTO CORRESPONDING FIELDS OF TABLE @PT_ZGTPPT3421.

  SELECT ZT01~GRPNR, ZT01~ORDNR,
         ZT02~ORDNO, ZT02~POSNR, ZT02~KUNNR, ZT02~WERKS, ZT02~SPGCD,
         ZT02~MATNR, ZT02~MAKTX, ZT02~GCATG,
         KNA1~NAME1
    FROM ZGTPPT2010 AS ZT01
    JOIN ZGTPPT2000 AS ZT02
      ON ZT01~GRPNR EQ ZT02~GRPNR
    LEFT JOIN KNA1
      ON ZT02~KUNNR EQ KNA1~KUNNR
     FOR ALL ENTRIES IN @GT_PROD
   WHERE ZT01~ORDNR   EQ @GT_PROD-ORDNR
*     AND zt02~gcatg   IN ( @gc_gcatg-sales_order, @gc_gcatg-production_order  )
     AND ZT02~ZSTATUS NE 'D'
    INTO CORRESPONDING FIELDS OF TABLE @PT_ZGTPPT2010.

  SORT PT_ZGTPPT2010 BY ORDNR.

  IF PT_ZGTPPT2010 IS NOT INITIAL.
    SELECT VBEP~VBELN, VBEP~POSNR, VBEP~EDATU
      FROM VBEP
       FOR ALL ENTRIES IN @PT_ZGTPPT2010
     WHERE VBEP~VBELN EQ @PT_ZGTPPT2010-ORDNO+(10)
       AND VBEP~POSNR EQ @PT_ZGTPPT2010-POSNR
       AND VBEP~ETENR EQ '0001'
      INTO CORRESPONDING FIELDS OF TABLE @PT_VBEP.

    SORT PT_VBEP BY VBELN POSNR.

  ENDIF.

  SELECT ZT02~AUFNR, ZT02~PDCAPROCCODE
    FROM @GT_PROD AS ZT01
    JOIN ZGTPP_CV_ORDSYVAL AS ZT02
      ON ZT01~ORDNR EQ ZT02~AUFNR
   WHERE ZT01~ORDTY EQ @GC_ORDTY-PRD
     AND ZT02~DLFL = ''
     AND ZT02~LKD = ''
     AND ZT02~CLSD = ''
     AND ZT02~TECO = ''
   ORDER BY ZT02~AUFNR
    INTO CORRESPONDING FIELDS OF TABLE @PT_ORDSYVAL.

**// 계획오더에서 생산오더로 전환된 오더 중에서 계획오더 단계에서 생성한 자재 청구
*  SELECT ZT02~WERKS, ZT02~SPGCD, ZT02~RQMON, ZT02~ZWKREQ, ZT02~ORDNR, ZT03~PLNUM, ZT04~MATNR
*    FROM @GT_PROD   AS ZT01
*    JOIN ZGTPPT2340 AS ZT02
*      ON ZT01~ORDNR EQ ZT02~ORDNR
*    JOIN ZGTPPT2330 AS ZT03
*      ON ZT02~WERKS  EQ ZT03~WERKS
*     AND ZT02~SPGCD  EQ ZT03~SPGCD
*     AND ZT02~RQMON EQ ZT03~RQMON
*     AND ZT02~ZWKREQ EQ ZT03~ZWKREQ
*    JOIN ZGTPPT3421 AS ZT04
*      ON ZT03~WERKS EQ ZT04~WERKS
*     AND ZT03~SPGCD EQ ZT04~SPGCD
*     AND ZT03~RQMON EQ ZT04~RQMON
*     AND ZT03~ZWKREQ EQ ZT04~ZWKREQ
*     AND ZT01~IDNRK EQ ZT04~MATNR
*   WHERE ZT01~ORDTY   EQ @GC_ORDTY-PRD
*     AND ZT03~DMORD   IS INITIAL
*     AND ZT04~ZSTATUS NE 'D'
*   ORDER BY ZT02~WERKS, ZT02~SPGCD, ZT02~ORDNR, ZT04~MATNR
*  INTO CORRESPONDING FIELDS OF TABLE @PT_ZGTPPT2340.

**  SELECT ZT02~WERKS, ZT02~SPGCD, ZT02~ZWKREQ, ZT02~ORDNR, ZT03~PLNUM, ZT04~MATNR
**    FROM @GT_PROD   AS ZT01
**    JOIN ZGTPPT2340 AS ZT02
**      ON ZT01~ORDNR EQ ZT02~ORDNR
**    JOIN ZGTPPT2330 AS ZT03
**      ON ZT02~WERKS  EQ ZT03~WERKS
**     AND ZT02~SPGCD  EQ ZT03~SPGCD
**     AND ZT02~ZWKREQ EQ ZT03~ZWKREQ
**    JOIN ZGTPPT3421 AS ZT04
**      ON ZT03~WERKS EQ ZT04~WERKS
**     AND ZT03~SPGCD EQ ZT04~SPGCD
**     AND ZT03~PLNUM EQ ZT04~PLNUM
**   WHERE ZT01~ORDTY   EQ @GC_ORDTY-PRD
**     AND ZT03~PLNUM   NE @SPACE
**     AND ZT04~ZSTATUS NE 'D'
**   ORDER BY ZT02~WERKS, ZT02~SPGCD, ZT02~ORDNR, ZT04~MATNR
**  INTO CORRESPONDING FIELDS OF TABLE @PT_ZGTPPT2340.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_transaction_ME23
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_ME23  USING PV_EBELN PV_EBELP.

  CHECK PV_EBELN IS NOT INITIAL.

  CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
    EXPORTING
      I_EBELN              = PV_EBELN
      I_EBELP              = PV_EBELP
    EXCEPTIONS
      NOT_FOUND            = 1
      NO_AUTHORITY         = 2
      INVALID_CALL         = 3
      PREVIEW_NOT_POSSIBLE = 4
      OTHERS               = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_transaction_me53
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_ME53  USING PV_BANFN PV_BNFPO.

  CHECK PV_BANFN IS NOT INITIAL.

  CALL FUNCTION 'MMPUR_REQUISITION_DISPLAY'
    EXPORTING
      IM_BANFN        = PV_BANFN
      IM_BNFPO        = PV_BNFPO
      IM_DISPLAY_ONLY = ABAP_TRUE
    EXCEPTIONS
      NO_AUTHORITY    = 1
      OTHERS          = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_transaction_VA03
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_VA03  USING PV_VBELN PV_VBELP.

  CHECK PV_VBELN IS NOT INITIAL.

  SET PARAMETER ID 'AUN' FIELD PV_VBELN.

  TRY.
      CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.

    CATCH CX_SY_AUTHORIZATION_ERROR.
      MESSAGE E077(S#) WITH 'VA03' DISPLAY LIKE 'S'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_fert_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_FERT_REQ RAISING LCX_EXCEPTION.

  DATA LV_ANSWER TYPE C.

  GR_COMP->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  PERFORM GET_ROWS_SELECTED_FERT_REQ.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C05 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_fert_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_FERT_REQ .

  CLEAR GS_RESULT.

  MODIFY GT_COMP FROM VALUE #( SEL = ABAP_FALSE )
                    TRANSPORTING SEL
                    WHERE SEL EQ ABAP_TRUE.

  GR_COMP->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

*// 선택된 데이터 유효성 점검.
  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_COMP REFERENCE INTO DATA(LR_COMP) INDEX LS_ROW-INDEX.

    CHECK SY-SUBRC IS INITIAL.

    GS_RESULT-SEL += 1.
    GS_RESULT-TOTAL += 1.

    LR_COMP->SEL = ABAP_TRUE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_charact_getdetail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BAPI_CHARACT_GETDETAIL  USING PS_CHAR_DETIAL TYPE TY_S_CHAR_DETAIL
                                   PV_CHARACTNAME.

  DATA LS_CHARACTDETAIL TYPE BAPICHARACTDETAIL.
  DATA LT_RETURN TYPE TABLE OF BAPIRET2.

  PS_CHAR_DETIAL-ATNAM = PV_CHARACTNAME.

  CALL FUNCTION 'BAPI_CHARACT_GETDETAIL'
    EXPORTING
      CHARACTNAME        = PS_CHAR_DETIAL-ATNAM
      LANGUAGE           = SY-LANGU
    IMPORTING
      CHARACTDETAIL      = LS_CHARACTDETAIL
    TABLES
      CHARACTVALUESDESCR = PS_CHAR_DETIAL-VAL_DESC[]
      RETURN             = LT_RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_EXIT_MATN1_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONV_EXIT_MATN1_INPUT  USING  PV_MATNR.

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
*& Form user_command_select
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_SELECT USING PV_SELECT.

  GR_MREQ->MR_GRID->GET_SELECTED_CELLS( IMPORTING ET_CELL = DATA(LT_CELLS) ).

  CHECK LT_CELLS IS NOT INITIAL.

  SORT LT_CELLS BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.

  IF P_GNMAT EQ ABAP_TRUE. "// 일반 자재.
    LOOP AT LT_CELLS INTO DATA(LS_CELL).
      DATA(LR_PROD) = REF #( GT_PROD[ LS_CELL-ROW_ID ] ).

      LR_PROD->SEL   = PV_SELECT.
      LR_PROD->EXREQ = ABAP_FALSE.

      IF LR_PROD->ORDNO IS NOT INITIAL.
        MODIFY GT_PROD FROM VALUE #( SEL   = LR_PROD->SEL
                                     EXREQ = LR_PROD->EXREQ )
                       TRANSPORTING SEL EXREQ
                       WHERE ORDNO EQ LR_PROD->ORDNO
                          AND MATNR EQ LR_PROD->MATNR.
      ENDIF.
    ENDLOOP.
  ELSE.                    "// 포장 자재.
    LOOP AT LT_CELLS INTO LS_CELL.
      DATA(LR_SALES) = REF #( GT_SALES[ LS_CELL-ROW_ID ] ).
      LR_SALES->SEL = PV_SELECT.
    ENDLOOP.
  ENDIF.

  GR_MREQ->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_parameter_description
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_PARAMETER_DESCRIPTION .

  CLEAR: P_NAME1, P_DESCR.

  IF P_WERKS IS NOT INITIAL.
    SELECT SINGLE NAME1
      INTO @P_NAME1
      FROM T001W
     WHERE WERKS EQ @P_WERKS.
  ENDIF.

  IF P_WERKS IS NOT INITIAL AND P_SPGCD IS NOT INITIAL.
    SELECT SINGLE DESCR
      INTO @P_DESCR
      FROM ZPPT0107
     WHERE WERKS EQ @P_WERKS
       AND SPGCD EQ @P_SPGCD.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_fini_in_mreq
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_FINI_IN_MREQ  USING PT_GOOD_CELLS TYPE LVC_T_MODI
                                      PV_MODIFIED.

  IF P_GNMAT EQ ABAP_TRUE.
    IF GT_COMP_SCRAP IS NOT INITIAL.
      LOOP AT GT_COMP_SCRAP INTO DATA(LS_COMP_SCRAP).
        LOOP AT GT_PROD REFERENCE INTO DATA(LR_PROD)
                        WHERE ORDNO  EQ LS_COMP_SCRAP-ORDNO
                          AND IDNRK  EQ LS_COMP_SCRAP-IDNRK
                          AND STATUS NE ICON_LED_GREEN.
          CHECK SY-TABIX NE LS_COMP_SCRAP-TABIX.
          LR_PROD->AUSCH = LS_COMP_SCRAP-AUSCH.
          LR_PROD->BDMNG = LR_PROD->REQMN + LR_PROD->REQMN * LR_PROD->AUSCH / 100.
          DATA(LV_CHANGED) = ABAP_TRUE.
        ENDLOOP.
      ENDLOOP.

      CLEAR GT_COMP_SCRAP.

      IF LV_CHANGED EQ ABAP_TRUE.
        GR_MREQ->REFRESH( ).
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_SMRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_SMRY .

  LOOP AT GR_SMRY->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-F02.
        LR_FCAT->CHECKTABLE = SPACE.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'SPGCD'.
        LR_FCAT->COLTEXT    = TEXT-F03.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F80.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F18.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'NEWDRUM'.
        LR_FCAT->COLTEXT    = TEXT-F44.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.
        LR_FCAT->TECH       = COND #( WHEN P_GNMAT IS NOT INITIAL THEN ABAP_TRUE ).

      WHEN 'IRONDRUM'.
        LR_FCAT->COLTEXT    = TEXT-F45.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.
        LR_FCAT->TECH       = COND #( WHEN P_GNMAT IS NOT INITIAL THEN ABAP_TRUE ).

      WHEN 'DRUMTITLEMARK'.
        LR_FCAT->COLTEXT    = TEXT-F46.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.
        LR_FCAT->TECH       = COND #( WHEN P_GNMAT IS NOT INITIAL THEN ABAP_TRUE ).

      WHEN 'FLANGE_PROT'.
        LR_FCAT->COLTEXT    = TEXT-F47.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.
        LR_FCAT->TECH       = COND #( WHEN P_GNMAT IS NOT INITIAL THEN ABAP_TRUE ).

      WHEN 'HANJEON'.
        LR_FCAT->COLTEXT    = TEXT-F48.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.
        LR_FCAT->TECH       = COND #( WHEN P_GNMAT IS NOT INITIAL THEN ABAP_TRUE ).

      WHEN 'LFIMG'.
        LR_FCAT->COLTEXT    = TEXT-F60.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'ERFME'.
        LR_FCAT->COLTEXT    = TEXT-F61.
        LR_FCAT->JUST       = 'C'.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_summary_from_prd_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_SUMMARY_FROM_PRD_ORDER  RAISING LCX_EXCEPTION.

  GS_SUMMARY = VALUE #( WERKS  = P_WERKS
                        REQDAT = P_REQDT ).

  CLEAR GT_SMRY.

  PERFORM CHECK_BEFORE_MAT_REQ_FROM_PRD. "// 사전점검.

  LOOP AT GT_PROD  INTO DATA(LS_KEY)
                  WHERE SEL    EQ ABAP_TRUE
                    AND EXREQ  EQ ABAP_FALSE
                    AND STATUS NE ICON_GREEN_LIGHT
                  GROUP BY ( WERKS = LS_KEY-WERKS
                             IDNRK = LS_KEY-IDNRK )
                   INTO DATA(LT_GROUP).
    APPEND INITIAL LINE TO GT_SMRY REFERENCE INTO DATA(LR_SMRY).

    LOOP AT GROUP LT_GROUP INTO DATA(LS_PROD).
      IF LR_SMRY->* IS INITIAL.
        LR_SMRY->* = CORRESPONDING #( LS_PROD MAPPING MATNR = IDNRK
                                                      MAKTX = IDNTX
                                                      ERFME = MEINS ).
      ENDIF.

      LR_SMRY->LFIMG += LS_PROD-BDMNG.

      IF GS_SUMMARY-LGORT IS INITIAL.
        GS_SUMMARY-LGORT = LS_PROD-LGFSB.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  READ TABLE GT_T001L INTO DATA(LS_T001L) WITH TABLE KEY WERKS = GS_SUMMARY-WERKS
                                                         LGORT = GS_SUMMARY-LGORT.
  IF SY-SUBRC IS INITIAL.
    GS_SUMMARY-LGOBE = LS_T001L-LGOBE.
  ENDIF.

  SORT GT_SMRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_mat_req
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_MAT_REQ .

  TRY.
      PERFORM CHECK_BEFORE_MAT_REQ_FROM_SMRY. "// 사전점검.
      PERFORM CREATE_MAT_REQ_FROM_SMRY.       "// 자재청구.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_SMRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_IN_SMRY .

  TRY.
      GR_SMRY->MS_LAYOUT = VALUE #( BASE GR_SMRY->MS_LAYOUT NO_ROWMARK = ABAP_TRUE ).

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_summary_popup_window
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_SUMMARY_POPUP_WINDOW .

  TRY.
      PERFORM GET_SUMMARY_FROM_PRD_ORDER. "// 일반 자재.

      CALL SCREEN 500 STARTING AT 20 3.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_mat_req_from_smry
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_MAT_REQ_FROM_SMRY RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  GR_SMRY->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  SELECT SINGLE @ABAP_TRUE
    FROM @GT_SMRY AS ZT01
   WHERE ZT01~LFIMG GT 0
    INTO @DATA(LV_CHECK).

  IF SY-SUBRC IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E07.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C02 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_transaction_va03_01
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_PROD_ORDNO
*&---------------------------------------------------------------------*
*** 2026.06.25 ksw ***
FORM CALL_TRANSACTION_VA03_01  USING    PV_VBELN.

  CHECK PV_VBELN IS NOT INITIAL.

  SET PARAMETER ID 'AUN' FIELD PV_VBELN.

  TRY.
      CALL TRANSACTION 'VA03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.

    CATCH CX_SY_AUTHORIZATION_ERROR.
      MESSAGE E077(S#) WITH 'VA03' DISPLAY LIKE 'S'.
  ENDTRY.

ENDFORM.
*** 2026.06.25 ksw ***
*&---------------------------------------------------------------------*
*& Form user_command_mto_create
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_MTO_CREATE .

  PERFORM CREATE_MTO_REQ_FROM_SLS_ORDER. "// MTO  청구 생성 .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_MTO_REQ_FROM_SLS_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_MTO_REQ_FROM_SLS_ORDER .

*  TRY.
*      PERFORM CHECK_BEFORE_MAT_REQ_FROM_SLS USING 'MTO'. "// 사전점검.
  PERFORM CREATE_MTO_REQ_FROM_SLS.       "// 자재청구.

*    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
*      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
*        GR_MREQ->REFRESH( ).
*        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
*      ENDIF.
*  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_MTO_REQ_FROM_SLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_MTO_REQ_FROM_SLS .

  CLEAR GS_HEADER_800.
  GS_HEADER_800 = VALUE #( REQDAT = COND #( WHEN P_REQDT IS NOT INITIAL THEN P_REQDT
                                                                      ELSE SY-DATUM ) ).

  CALL SCREEN 800 STARTING AT 050 04
                  ENDING   AT 110 10.

  IF GV_SAVED EQ ABAP_TRUE.
    CLEAR GV_SAVED.
    GR_LIST->REFRESH( ).
    MESSAGE S006 WITH '청구번호 생성 완료.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SO_CHARACTERISTIC_GL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SO_CHARACTERISTIC_GL .
  DATA : LT_CHAR TYPE TY_T_CHAR.
  DATA : LT_CHAR_MOSU TYPE TY_T_CHAR.
  DATA : LT_PACKING_MAT TYPE TY_T_PACKING_MAT.
  DATA : LT_ZGTPPT3422 TYPE TY_T_ZGTPPT3422.
  DATA : LT_MAIN LIKE GT_SALES.
  DATA : LV_PALET_MATNR TYPE MATNR.
  DATA : LV_PALET_CNT TYPE MENGE_D.
  DATA : LV_TAIL TYPE CHAR10.
  DATA : LV_IDX TYPE I.


  SELECT DISTINCT ZT02~VBELN, ZT02~POSNR, ZT02~ATNAM, ZT02~ATWRT, ZT02~ATFLV
    FROM @GT_SALES AS ZT01
    JOIN ZGTMM_CV_BD_GET_VCOFSO AS ZT02
      ON ZT01~VBELN EQ ZT02~VBELN
     AND ZT01~VBELP EQ ZT02~POSNR
   ORDER BY ZT02~VBELN, ZT02~POSNR,ZT02~ATNAM
    INTO CORRESPONDING FIELDS OF TABLE @LT_CHAR.

  SELECT ZT02~WERKS, ZT02~SPGCD, ZT02~REQNO, ZT02~POSNR,
         ZT02~VBELN, ZT02~VBELP, ZT02~MATNR, ZT02~BDTER
    FROM @GT_SALES  AS ZT01
    JOIN ZGTPPT3422 AS ZT02
      ON ZT01~WERKS   EQ ZT02~WERKS
     AND ZT01~SPGCD   EQ ZT02~SPGCD
     AND ZT01~VBELN   EQ ZT02~VBELN
     AND ZT01~VBELP   EQ ZT02~VBELP
     AND ZT02~ZSTATUS EQ @SPACE
   ORDER BY ZT02~VBELN, ZT02~VBELP
    INTO CORRESPONDING FIELDS OF TABLE @LT_ZGTPPT3422.

  LT_MAIN = GT_SALES.
  SORT LT_MAIN BY VBELN VBELP.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN COMPARING VBELN VBELP.

  REFRESH GT_SALES.

  LOOP AT LT_MAIN INTO DATA(LS_MAIN).

    REFRESH LT_CHAR_MOSU.
    LT_CHAR_MOSU = VALUE #( FOR LW_CHAR IN LT_CHAR WHERE ( VBELN = LS_MAIN-VBELN
                                                     AND   POSNR = LS_MAIN-VBELP )
                          ( CORRESPONDING #( LW_CHAR ) ) ).


    LOOP AT LT_CHAR_MOSU INTO DATA(LS_CHAR).
      CASE LS_CHAR-ATNAM.
        WHEN 'PD_CA_PACKMARK_STATUS'.    "// 포장재/마킹지정 상태.
          IF LS_CHAR-ATWRT EQ 'CM'.
          ELSE.
            LS_MAIN-EXCEPT = ABAP_TRUE.
          ENDIF.
        WHEN 'PD_GA_PRINT_METHOD'.    "// 프린트 방법.
          LS_MAIN-PRINT_METHOD = LS_CHAR-ATWRT.
        WHEN 'PD_GA_PACKAGE_METHOD'.    "// 포장구분.
          LS_MAIN-PACK_METHOD = LS_CHAR-ATWRT.

          READ TABLE GT_CHAR_DETIAL INTO DATA(LS_CHAR_DETIAL) WITH KEY ATNAM = LS_CHAR-ATNAM BINARY SEARCH.
          IF SY-SUBRC IS INITIAL.
            READ TABLE LS_CHAR_DETIAL-VAL_DESC INTO DATA(LS_VAL_DESC) WITH KEY VALUE_CHAR = LS_CHAR-ATWRT.
            IF SY-SUBRC IS INITIAL.
              LS_MAIN-PACK_TXT = LS_VAL_DESC-DESCRIPTION.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    IF LS_MAIN-EXCEPT = ABAP_TRUE.
      CONTINUE.
    ENDIF.
    CLEAR LV_IDX.

    DO 4 TIMES.
      ADD 1 TO LV_IDX.
      CASE LV_IDX.
        WHEN 1.
          LV_TAIL = '1ST'.
        WHEN 2.
          LV_TAIL = '2ND'.
        WHEN 3.
          LV_TAIL = '3RD'.
        WHEN 4.
          LV_TAIL = '4TH'.
      ENDCASE.

      CLEAR : LV_PALET_MATNR, LV_PALET_CNT.
      PERFORM GET_CHART_VALUE_BOX TABLES LT_CHAR_MOSU
                                   USING LV_TAIL
                                CHANGING LV_PALET_MATNR LV_PALET_CNT.
      IF LV_PALET_MATNR IS NOT INITIAL.
        READ TABLE GT_SALES ASSIGNING FIELD-SYMBOL(<LS_ADD>) WITH KEY VBELN = LS_MAIN-VBELN
                                                                      VBELP = LS_MAIN-VBELP
                                                                      PACK_MAT = LV_PALET_MATNR.
        IF SY-SUBRC EQ 0.
          ADD LV_PALET_CNT TO <LS_ADD>-DRUM_CNT.
        ELSE.
          APPEND INITIAL LINE TO GT_SALES ASSIGNING FIELD-SYMBOL(<LS_SALES>).
          MOVE-CORRESPONDING LS_MAIN TO <LS_SALES>.
          <LS_SALES>-PACK_MAT = LV_PALET_MATNR.
          <LS_SALES>-PACK_MAT_TXT = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LV_PALET_MATNR ).
          <LS_SALES>-DRUM_CNT = LV_PALET_CNT.
          <LS_SALES>-MEINS = 'EA'.

          <LS_SALES>-NEWDRUM       = ZGTPP_IF_CONST=>GC_YN-NO.  "// 신드럼
          <LS_SALES>-IRONDRUM      = ZGTPP_IF_CONST=>GC_YN-NO.  "// 철드럼
          <LS_SALES>-DRUMTITLEMARK = ZGTPP_IF_CONST=>GC_YN-NO.  "// 드럼자판 인쇄유무
          <LS_SALES>-FLANGE_PROT   = ZGTPP_IF_CONST=>GC_YN-NO.  "// 약판 골판지 유무
        ENDIF.
      ENDIF.
    ENDDO.

  ENDLOOP.



  LOOP AT GT_SALES REFERENCE INTO DATA(LR_SALES).
    LR_SALES->* = VALUE #( BASE LR_SALES->*  STATUS = ICON_LIGHT_OUT ).

    READ TABLE LT_ZGTPPT3422 INTO DATA(LS_ZGTPPT3422) WITH KEY VBELN = LR_SALES->VBELN
                                                               VBELP = LR_SALES->VBELP
                                                               MATNR = LR_SALES->PACK_MAT.
    IF SY-SUBRC IS INITIAL.
      LR_SALES->REQNO  = LS_ZGTPPT3422-REQNO.
      LR_SALES->POSNR  = LS_ZGTPPT3422-POSNR.
      LR_SALES->REQDAT = LS_ZGTPPT3422-BDTER.
      LR_SALES->STATUS = ICON_GREEN_LIGHT.
      LR_SALES->STYLE  = GT_STYLE.
    ENDIF.

*// 입고 요청일.
    IF LR_SALES->STATUS EQ ICON_LIGHT_OUT.
      LR_SALES->REQDAT = P_REQDT.
    ENDIF.

  ENDLOOP.

  DELETE GT_SALES WHERE EXCEPT EQ ABAP_TRUE
                     OR PACK_MAT IS INITIAL.

  IF P_UNREQ EQ ABAP_TRUE. "// 미청구건 조회.
    DELETE GT_SALES WHERE STATUS EQ ICON_GREEN_LIGHT.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CHART_VALUE_BOX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CHAR
*&      --> LV_TAIL
*&      <-- LV_PALET_MATNR
*&      <-- LV_PALET_CNT
*&---------------------------------------------------------------------*
FORM GET_CHART_VALUE_BOX  TABLES   PT_CHAR TYPE TY_T_CHAR
                          USING    PV_TAIL
                          CHANGING PV_PALET_MATNR TYPE MATNR
                                   PV_PALET_CNT TYPE MENGE_D.

  DATA : LV_ATNAM(30).
  DATA : LV_VALUE TYPE CHAR20.
  CONSTANTS : LC_PA(30)     VALUE 'PD_GL_PACKING_PA_',
              LC_PA_CNT(30) VALUE 'PD_GL_PACKING_PA_CNT_'.

* 포장재 palet 자재정보
  CLEAR LV_ATNAM.
  LV_ATNAM = LC_PA && PV_TAIL.
  READ TABLE PT_CHAR INTO DATA(LS_CHAR) WITH KEY ATNAM = LV_ATNAM.
  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT        = LS_CHAR-ATWRT
      IMPORTING
        OUTPUT       = PV_PALET_MATNR
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.
  ENDIF.

* 포장재 palet 수량
  CLEAR LV_ATNAM.
  LV_ATNAM = LC_PA_CNT && PV_TAIL.
  READ TABLE PT_CHAR INTO LS_CHAR WITH KEY ATNAM = LV_ATNAM.
  IF SY-SUBRC EQ 0.
    CLEAR LV_VALUE.
    CALL FUNCTION 'FLTP_CHAR_CONVERSION'
      EXPORTING
        DECIM = 3
        INPUT = LS_CHAR-ATFLV
      IMPORTING
        FLSTR = LV_VALUE.
    PV_PALET_CNT = LV_VALUE + 0.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_SUMMARY_POPUP_WINDOW_GL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_SUMMARY_POPUP_WINDOW_GL .


  TRY.
      PERFORM GET_SUMMARY_FROM_GL_MAT. "// 랜 포장재

      CALL SCREEN 600 STARTING AT 20 3.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SUMMARY_FROM_GL_MAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SUMMARY_FROM_GL_MAT RAISING LCX_EXCEPTION.

  GS_SUMMARY = VALUE #( WERKS  = P_WERKS
                        REQDAT = P_REQDT ).

  CLEAR GT_SMRY.

  PERFORM CHECK_BEFORE_MAT_REQ_GL_MAT. "// 사전점검.

  LOOP AT GT_SALES  INTO DATA(LS_KEY)
                  WHERE SEL    EQ ABAP_TRUE
                    AND STATUS NE ICON_GREEN_LIGHT
                  GROUP BY ( WERKS = LS_KEY-WERKS
                             PACK_MAT = LS_KEY-PACK_MAT )
                   INTO DATA(LT_GROUP).
    APPEND INITIAL LINE TO GT_SMRY REFERENCE INTO DATA(LR_SMRY).

    LOOP AT GROUP LT_GROUP INTO DATA(LS_PROD).
      IF LR_SMRY->* IS INITIAL.
        LR_SMRY->* = CORRESPONDING #( LS_PROD MAPPING MATNR = PACK_MAT
                                                      MAKTX = PACK_MAT_TXT
                                                      ERFME = MEINS ).
      ENDIF.

      LR_SMRY->LFIMG += LS_PROD-DRUM_CNT.

      IF GS_SUMMARY-LGORT IS INITIAL.
        GS_SUMMARY-LGORT = LS_PROD-LGPRO.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  READ TABLE GT_T001L INTO DATA(LS_T001L) WITH TABLE KEY WERKS = GS_SUMMARY-WERKS
                                                         LGORT = GS_SUMMARY-LGORT.
  IF SY-SUBRC IS INITIAL.
    GS_SUMMARY-LGOBE = LS_T001L-LGOBE.
  ENDIF.

  SORT GT_SMRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BEFORE_MAT_REQ_GL_MAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_MAT_REQ_GL_MAT RAISING LCX_EXCEPTION.

  DATA LV_ANSWER TYPE C.

  GR_MREQ->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  PERFORM GET_ROWS_SELECTED_IN_SALES.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
  ENDIF.

  IF GS_RESULT-INVALID IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH GS_RESULT-MESSAGE.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E14.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_600 INPUT.

  CASE GV_OKCODE.
    WHEN GC_FCODE-MAT_REQ.
      PERFORM USER_COMMAND_MAT_REQ_LC.     "// 자재 청구.
  ENDCASE.

  CLEAR GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_MAT_REQ_LC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_MAT_REQ_LC .

  TRY.
      PERFORM CHECK_BEFORE_MAT_REQ_FROM_SMRY. "// 사전점검.
      PERFORM CREATE_MAT_REQ_FROM_SMRY_LC.       "// 자재청구.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_MAT_REQ_FROM_SMRY_LC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_MAT_REQ_FROM_SMRY_LC .

  DATA LT_ZGTPPT3420 TYPE TABLE OF ZGTPPT3420.
  DATA LT_ZGTPPT3422 TYPE TABLE OF ZGTPPT3422.
  DATA LV_REQNO TYPE CHAR12.
  DATA LV_POSNR TYPE ZGTPPT3420-POSNR.

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

*// 청구번호.
  PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' LV_REQNO.

  LOOP AT GT_SMRY INTO DATA(LS_SMRY)
                  WHERE LFIMG GT 0.
    LV_POSNR += 1.

    APPEND INITIAL LINE TO LT_ZGTPPT3420 REFERENCE INTO DATA(LR_ZGTPPT3420).
    LR_ZGTPPT3420->* = CORRESPONDING #( LS_SMRY ).
    LR_ZGTPPT3420->* = CORRESPONDING #( BASE ( LR_ZGTPPT3420->* ) GS_ZGTPPS1001 ).
    LR_ZGTPPT3420->* = VALUE #( BASE LR_ZGTPPT3420->*  REQNO   = LV_REQNO+2
                                                       REQDAT  = GS_SUMMARY-REQDAT
                                                       LGORT_T = GS_SUMMARY-LGORT
                                                       POSNR   = LV_POSNR
                                                       DRUMFLAG = ABAP_TRUE ).

    LOOP AT GT_SALES REFERENCE INTO DATA(LR_SALES)
                    WHERE SEL    EQ ABAP_TRUE
                      AND STATUS NE ICON_GREEN_LIGHT
                      AND WERKS  EQ LS_SMRY-WERKS
                      AND PACK_MAT  EQ LS_SMRY-MATNR.

      APPEND INITIAL LINE TO LT_ZGTPPT3422 REFERENCE INTO DATA(LR_ZGTPPT3422).
      LR_ZGTPPT3422->* = CORRESPONDING #( LR_SALES->* MAPPING MATNR = PACK_MAT
                                                              BDMNG = DRUM_CNT
                                                              BDTER = REQDAT ).
      LR_ZGTPPT3422->* = VALUE #( BASE LR_ZGTPPT3422->*  REQNO      = LR_ZGTPPT3420->REQNO
                                                         POSNR      = LR_ZGTPPT3420->POSNR
                                                         PACK_GUBUN = LR_SALES->PACK_METHOD
                                                         PACK_TEXT  = LR_SALES->PACK_TXT
                                                         PKWOOD     = LR_SALES->PW_FACTOR
                                                         GUBUN      = GC_GCATG-MTO ).

      LR_SALES->REQNO = LV_REQNO+2.
      LR_SALES->POSNR = LV_POSNR.
      LR_SALES->STATUS  = ICON_GREEN_LIGHT.
      LR_SALES->MESSAGE = TEXT-S01.
      LR_SALES->STYLE   = GT_STYLE.
    ENDLOOP.
  ENDLOOP.

  TRY.
      MODIFY ZGTPPT3420 FROM TABLE LT_ZGTPPT3420.
      MODIFY ZGTPPT3422 FROM TABLE LT_ZGTPPT3422.

      COMMIT WORK AND WAIT.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      MESSAGE E000 WITH LR_ROOT->GET_TEXT( ).
  ENDTRY.

  PERFORM GET_MAT_REQ_RESULT_FROM_SLS.

  GR_MREQ->REFRESH( ).
  GR_LIST->REFRESH( ).

  MESSAGE S000 WITH TEXT-S11.

  PERFORM USER_COMMAND_EXIT.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_PRD_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SALES_>*
*&---------------------------------------------------------------------*
FORM DISP_PRD_ORDER  USING    PS_SALES TYPE TY_S_SALES.

  REFRESH GT_DISP_700.

  LOOP AT GT_2010 INTO DATA(LS_2010) WHERE DMORD = PS_SALES-VBELN
                                       AND DMLINE = PS_SALES-VBELP
                                       AND MATNR_DM = PS_SALES-PACK_MAT.
    CLEAR GS_DISP_700.
    MOVE-CORRESPONDING LS_2010 TO GS_DISP_700.
    GS_DISP_700-MAKTX_DM = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2010-MATNR_DM ).
    GS_DISP_700-MENGE = 1.
    GS_DISP_700-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2010-MATNR ).
    APPEND GS_DISP_700 TO GT_DISP_700.
  ENDLOOP.

  IF GT_DISP_700 IS NOT INITIAL.
    CALL SCREEN '0700' STARTING AT 10 5 ENDING AT 100 12.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0700 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0700 OUTPUT.
  IF GO_GRID_0700 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0700.
    PERFORM SET_LAYOUT_GRID_0700.
    PERFORM SET_FIELDCAT_GRID_0700.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0700.
    PERFORM CALL_GRID_0700_DISPLAY.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0700
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0700 .

  CREATE OBJECT GO_CONTAIN_0700
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT GO_GRID_0700
    EXPORTING
      I_PARENT      = GO_CONTAIN_0700
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0700
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0700 .

  CLEAR GS_LAYOUT_0700.
  GS_LAYOUT_0700-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0700-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0700-SEL_MODE   = 'D'.
  GS_LAYOUT_0700-NO_ROWMARK   = ABAP_TRUE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0700
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0700 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3180TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP_700'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0700.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0700[]
    TABLES
      IT_DATA         = GT_DISP_700
    EXCEPTIONS
      OTHERS          = 1.


  LOOP AT GT_FIELDCAT_0700 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'GRPNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장구성표 번호'(F85).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'ORDNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더'(F86).
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산오더 품목'(F87).
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR_DM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼자재'(F88).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX_DM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼자재명'(F89).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼수'(F90).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산자재'(F91).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생산자재명'(F92).
        <LS_FCAT>-JUST = 'L'.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0700
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0700 .

  REFRESH GT_EXCLUDE_0700.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0700
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.
ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0700_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0700_DISPLAY .

  CALL METHOD GO_GRID_0700->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0700
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0700
    CHANGING
      IT_OUTTAB            = GT_DISP_700
      IT_FIELDCATALOG      = GT_FIELDCAT_0700.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_INDV_REQ_800
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_INDV_REQ_800 .

  DATA LV_ANSWER TYPE C.

  PERFORM CONFIRMATION_POPUP USING TEXT-C05 LV_ANSWER.

  CHECK LV_ANSWER EQ '1'.

  PERFORM CREATE_DRUM_MAT_REQ.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_DRUM_MAT_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_DRUM_MAT_REQ .

  DATA LT_ZGTPPT3420 TYPE TABLE OF ZGTPPT3420.
  DATA LT_ZGTPPT3422 TYPE TABLE OF ZGTPPT3422.
  DATA LT_PRITEM     TYPE TY_BAPIMEREQITEMIMP.
  DATA LT_PRITEMX    TYPE TY_BAPIMEREQITEMX.
  DATA LT_PRACCOUNT  TYPE TY_BAPIMEREQACCOUNT.
  DATA LT_PRACCOUNTX TYPE TY_BAPIMEREQACCOUNTX.
  DATA LV_REQNO TYPE CHAR12.
  DATA LV_POSNR TYPE ZGTPPT3420-POSNR.
  DATA LV_BNFPO TYPE ZGTPPT3420-BNFPO.
  DATA LS_SALES TYPE TY_S_SALES.

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

  PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' LV_REQNO.

  APPEND INITIAL LINE TO LT_ZGTPPT3420 REFERENCE INTO DATA(LR_ZGTPPT3420).

  LV_POSNR += 1.
  LV_BNFPO += 10.

  LR_ZGTPPT3420->* = CORRESPONDING #( GS_HEADER_800 ).
  LR_ZGTPPT3420->* = CORRESPONDING #( BASE ( LR_ZGTPPT3420->* ) GS_ZGTPPS1001 ).
  LR_ZGTPPT3420->* = VALUE #( BASE LR_ZGTPPT3420->*  REQNO = LV_REQNO+2
                                                     POSNR = LV_POSNR
                                                     WERKS = P_WERKS
                                                     SPGCD = P_SPGCD
                                                     DRUMFLAG = ABAP_TRUE
                                                     BNFPO    = LV_BNFPO ).

  APPEND INITIAL LINE TO LT_ZGTPPT3422 REFERENCE INTO DATA(LR_ZGTPPT3422).
  LR_ZGTPPT3422->* = VALUE #( BASE LR_ZGTPPT3422->*  REQNO      = LR_ZGTPPT3420->REQNO
                                                     POSNR      = LR_ZGTPPT3420->POSNR
                                                     WERKS      = P_WERKS
                                                     SPGCD       = P_SPGCD
                                                     VBELN       = GS_HEADER_800-VBELN
                                                     VBELP       = GS_HEADER_800-VBELP
                                                     MATNR       = GS_HEADER_800-MATNR
                                                     BDMNG       = GS_HEADER_800-LFIMG
                                                     MEINS        = GS_HEADER_800-ERFME ).

  LR_ZGTPPT3422->SO_REF = ABAP_TRUE.
  IF GS_HEADER_800-VBELN IS NOT INITIAL.
    GV_INCLUDE_SO = ABAP_TRUE.
  ENDIF.

  PERFORM SET_PARA_CREATE_REQ_BAPI USING LR_ZGTPPT3420->* LT_PRITEM LT_PRITEMX LT_PRACCOUNT LT_PRACCOUNTX.

  CLEAR GV_INCLUDE_SO.

*// 구매요청 생성.
  PERFORM CREATE_PURCHASE_REQUISITION USING LS_SALES LT_PRITEM LT_PRITEMX LT_PRACCOUNT LT_PRACCOUNTX.

  IF LS_SALES-BANFN IS NOT INITIAL.
    LR_ZGTPPT3420->BANFN = LS_SALES-BANFN.
  ELSE.
    MESSAGE S006 DISPLAY LIKE 'E' WITH LS_SALES-MESSAGE.
    RETURN.
  ENDIF.

  APPEND INITIAL LINE TO GT_LIST REFERENCE INTO DATA(LR_LIST).
  LR_LIST->* = CORRESPONDING #( LR_ZGTPPT3420->* ).
  LR_LIST->* = VALUE #( BASE LR_LIST->*  MAKTX   = GS_HEADER_800-MAKTX
                                         STATUS  = ICON_GREEN_LIGHT
                                         MESSAGE = TEXT-S01 ).

  TRY.
      MODIFY ZGTPPT3420 FROM TABLE LT_ZGTPPT3420.
      MODIFY ZGTPPT3422 FROM TABLE LT_ZGTPPT3422.

      COMMIT WORK AND WAIT.

      GV_SAVED = ABAP_TRUE.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PLAN_2330
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PLAN_2330 .

  DATA : LT_SPMON TYPE RANGE OF SPMON.
  DATA : LS_SPMON LIKE LINE OF LT_SPMON.
  DATA : LV_CHK_DATE TYPE SY-DATUM.
  DATA : LT_PLNUM TYPE RANGE OF PLNUM.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LT_AUFNR2 TYPE RANGE OF AUFNR.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LS_MATNR LIKE LINE OF LT_MATNR.
  DATA : BEGIN OF LS_EKKO,
           EBELN TYPE EKPO-EBELN,
           EBELP TYPE EKPO-EBELP,
         END OF LS_EKKO.
  DATA : LT_EKKO LIKE TABLE OF LS_EKKO.
  DATA : LT_EKKO2 LIKE TABLE OF LS_EKKO.
  DATA : LT_PROD LIKE GT_PROD.
  DATA : LT_CHK_PROD LIKE GT_PROD.
  DATA : LS_PROD LIKE LINE OF  GT_PROD.
  DATA : LV_TABIX TYPE I.
  DATA : LV_REQMN TYPE RESB-BDMNG.

* 랜, 광의 반제품 생산계획 정보를 들고 오기 위해 대상 기간 설정
  IF       S_GSTRS-HIGH IS NOT INITIAL.
    LV_CHK_DATE = S_GSTRS-LOW.
    DO.
      CLEAR LS_SPMON.
      LS_SPMON-SIGN = 'I'.
      LS_SPMON-OPTION = 'EQ'.
      LS_SPMON-LOW = LV_CHK_DATE+0(6).
      COLLECT LS_SPMON INTO LT_SPMON.

      ADD 1 TO LV_CHK_DATE.

      IF LV_CHK_DATE > S_GSTRS-HIGH.
        EXIT.
      ENDIF.
    ENDDO.
    .
  ELSE.
    LV_CHK_DATE = S_GSTRS-LOW.

    CLEAR LS_SPMON.
    LS_SPMON-SIGN = 'I'.
    LS_SPMON-OPTION = 'EQ'.
    LS_SPMON-LOW = LV_CHK_DATE+0(6).
    COLLECT LS_SPMON INTO LT_SPMON.
  ENDIF.

  SELECT * FROM ZGTPPT2330
    INTO TABLE GT_2330
   WHERE WERKS = P_WERKS
     AND SPGCD = P_SPGCD
     AND RQMON IN LT_SPMON
     AND MATNR IN S_MATNR
     AND DMORD = ''.

  IF GT_2330[] IS NOT INITIAL.
    SELECT B~*
      FROM @GT_2330 AS A
      INNER JOIN ZGTPPT2340 AS B ON B~WERKS = A~WERKS
                                AND B~SPGCD = A~SPGCD
                                AND B~RQMON = A~RQMON
                                AND B~ZWKREQ = A~ZWKREQ
     WHERE B~ORDTY NE 'PR'
       INTO TABLE @GT_2340.

    SELECT DISTINCT B~*
      FROM @GT_2330   AS A
      INNER JOIN ZGTPPT3421 AS B
        ON B~WERKS EQ A~WERKS
       AND B~SPGCD EQ A~SPGCD
       AND B~RQMON EQ A~RQMON
       AND B~ZWKREQ EQ A~ZWKREQ
      WHERE B~ZSTATUS NE 'D'
       INTO TABLE @DATA(LT_3421).
  ENDIF.

  LT_PLNUM = VALUE #( FOR LW_2330 IN GT_2330 WHERE ( PLNUM IS NOT INITIAL )
                    ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2330-PLNUM ) ).

  LT_AUFNR = VALUE #( FOR LW_2340 IN GT_2340 WHERE ( ORDNR IS NOT INITIAL
                                               AND   ORDTY = 'PRD'  )
                    ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2340-ORDNR ) ).

  LT_EKKO = VALUE #( FOR LW_2340 IN GT_2340 WHERE ( ORDNR IS NOT INITIAL
                                               AND   ORDTY = 'PO'  )
                    ( EBELN = LW_2340-ORDNR EBELP = LW_2340-POSNR+1(5) ) ).

* 계획오더 기준
  IF LT_PLNUM[] IS NOT INITIAL.
    SELECT PLAF~PLNUM AS ORDNR,
           PLAF~MATNR, MAKT~MAKTX, PLAF~DISPO,
           PLAF~PSTTR AS PLDAT,
           RESB~WERKS, RESB~RSNUM, RESB~RSPOS, RESB~MATNR AS IDNRK,
           RESB~BDMNG, RESB~MEINS, RESB~BDTER, RESB~AUSCH,
           MARC~LGFSB,
           MAKT2~MAKTX AS IDNTX,
           SUBSTRING( PLAF~DISPO,1, 2 ) AS SPGCD,
           @GC_ORDTY-PLN AS ORDTY,
           '계획오더' AS GUBUN
      FROM PLAF
      JOIN RESB
        ON PLAF~PLNUM EQ RESB~PLNUM
      JOIN MARA
        ON RESB~MATNR EQ MARA~MATNR
      JOIN MARC
        ON RESB~MATNR EQ MARC~MATNR
       AND RESB~WERKS EQ MARC~WERKS
      LEFT JOIN MAKT
        ON PLAF~MATNR EQ MAKT~MATNR
       AND MAKT~SPRAS EQ @SY-LANGU
      LEFT JOIN MAKT AS MAKT2
        ON RESB~MATNR  EQ MAKT2~MATNR
       AND MAKT2~SPRAS EQ @SY-LANGU
     WHERE RESB~WERKS EQ @P_WERKS
       AND RESB~KZKUP NE @ABAP_TRUE   "// 연산품
       AND RESB~SCHGT NE @ABAP_TRUE   "// Bulk자재
       AND RESB~DUMPS NE @ABAP_TRUE   "// 가상품목
       AND PLAF~PLNUM IN @S_PLNUM
       AND MARA~MTART NOT IN @GT_MTART
      APPENDING CORRESPONDING FIELDS OF TABLE @GT_PROD2.
  ENDIF.

  IF LT_AUFNR[] IS NOT INITIAL.
    SELECT AFKO~AUFNR  AS ORDNR,
           AFKO~PLNBEZ AS MATNR, MAKT~MAKTX, AFKO~DISPO,
           AFKO~GSTRS  AS PLDAT,
           AUFK~ZZKDAUF, AUFK~ZZKDPOS,
           RESB~WERKS, RESB~RSNUM, RESB~RSPOS, RESB~MATNR AS IDNRK,
           RESB~BDMNG, RESB~MEINS, RESB~BDTER, RESB~AUSCH,
           MARC~LGFSB,
           MAKT2~MAKTX AS IDNTX,
           SUBSTRING( AFKO~DISPO,1, 2 ) AS SPGCD,
           @GC_ORDTY-PRD AS ORDTY
      FROM AFKO
      JOIN AUFK
        ON AFKO~AUFNR EQ AUFK~AUFNR
      JOIN RESB
        ON AFKO~AUFNR EQ RESB~AUFNR
      JOIN MARA
        ON RESB~MATNR EQ MARA~MATNR
      JOIN MARC
        ON RESB~MATNR EQ MARC~MATNR
       AND RESB~WERKS EQ MARC~WERKS
      LEFT JOIN MAKT
        ON AFKO~PLNBEZ EQ MAKT~MATNR
       AND MAKT~SPRAS  EQ @SY-LANGU
      LEFT JOIN MAKT AS MAKT2
        ON RESB~MATNR  EQ MAKT2~MATNR
       AND MAKT2~SPRAS EQ @SY-LANGU
     WHERE RESB~WERKS EQ @P_WERKS
       AND RESB~KZKUP NE @ABAP_TRUE   "// 연산품
       AND RESB~SCHGT NE @ABAP_TRUE   "// Bulk자재
       AND RESB~DUMPS NE @ABAP_TRUE   "// 가상품목
       AND AFKO~AUFNR IN @LT_AUFNR
       AND MARA~MTART NOT IN @GT_MTART
      APPENDING CORRESPONDING FIELDS OF TABLE @GT_PROD2.

  ENDIF.

  IF LT_EKKO[] IS NOT INITIAL.
    SELECT EKPO~EBELN, EKPO~EBELP,
           EKPO~MATNR AS MATNR, MAKT~MAKTX, B~DISPO,
           RESB~BDTER  AS PLDAT,
           RESB~WERKS, RESB~RSNUM, RESB~RSPOS, RESB~MATNR AS IDNRK,
           RESB~BDMNG, RESB~MEINS, RESB~BDTER, RESB~AUSCH,
           MARC~LGFSB,
           MAKT2~MAKTX AS IDNTX,
           SUBSTRING( B~DISPO,1, 2 ) AS SPGCD,
           'PO' AS ORDTY
      FROM @LT_EKKO AS A
      JOIN EKPO
       ON A~EBELN = EKPO~EBELN
      AND A~EBELP = EKPO~EBELP
      JOIN MARC AS B
       ON B~WERKS = EKPO~WERKS
      AND B~MATNR = EKPO~MATNR
      JOIN RESB
        ON EKPO~EBELN EQ RESB~EBELN
       AND EKPO~EBELP EQ RESB~EBELP
      JOIN MARA
        ON RESB~MATNR EQ MARA~MATNR
      JOIN MARC
        ON RESB~MATNR EQ MARC~MATNR
       AND RESB~WERKS EQ MARC~WERKS
      LEFT JOIN MAKT
        ON EKPO~MATNR EQ MAKT~MATNR
       AND MAKT~SPRAS  EQ @SY-LANGU
      LEFT JOIN MAKT AS MAKT2
        ON RESB~MATNR  EQ MAKT2~MATNR
       AND MAKT2~SPRAS EQ @SY-LANGU
     WHERE RESB~WERKS EQ @P_WERKS
       AND RESB~KZKUP NE @ABAP_TRUE   "// 연산품
       AND RESB~SCHGT NE @ABAP_TRUE   "// Bulk자재
       AND RESB~DUMPS NE @ABAP_TRUE   "// 가상품목
       AND MARA~MTART NOT IN @GT_MTART
      APPENDING CORRESPONDING FIELDS OF TABLE @GT_PROD2.

  ENDIF.


  LOOP AT GT_2330 INTO DATA(LS_2330).
* 계획오더 기준 청구수량 추출
    IF LS_2330-PLNUM IS NOT INITIAL.
      LOOP AT GT_PROD2 INTO DATA(LS_PLN) WHERE ORDNR = LS_2330-PLNUM
                                            AND ORDTY = 'PLN'.

        CLEAR LS_PROD.
        MOVE-CORRESPONDING LS_PLN TO LS_PROD.

        IF LS_PROD-MEINS EQ ZGTPP_IF_CONST=>GC_MEINS-G.
          LS_PROD-BDMNG = ROUND( VAL  = ( LS_PROD-BDMNG / 1000 )
                                  PREC = 3
                                  MODE = CL_ABAP_MATH=>ROUND_HALF_UP ).
          LS_PROD-MEINS = ZGTPP_IF_CONST=>GC_MEINS-G.
        ENDIF.

        IF LS_PROD-AUSCH IS NOT INITIAL.
          LS_PROD-REQMN = LS_PROD-BDMNG / ( 1 + LS_PROD-AUSCH / 100 ).
        ELSE.
          LS_PROD-REQMN = LS_PROD-BDMNG.
        ENDIF.

        LS_PROD-GUBUN = '반제품 계획'.
        LS_PROD-PDCAPROCCODE = LS_2330-GONG_CD.
        LS_PROD-RQMON = LS_2330-RQMON.
        LS_PROD-ZWKREQ = LS_2330-ZWKREQ.
        LS_PROD-ORDNR_I = ICON_DETAIL.

        LOOP AT GT_2340 INTO DATA(LS_2340) WHERE RQMON = LS_2330-RQMON
                                             AND ZWKREQ = LS_2330-ZWKREQ.

          IF LS_2340-ORDTY = 'PRD'.
* 생산오더 구성부품 수량 섬
            LOOP AT GT_PROD2 INTO DATA(LS_PRD) WHERE ORDTY = 'PRD'
                                                 AND ORDNR = LS_2340-ORDNR
                                                 AND IDNRK = LS_PROD-IDNRK.

              IF LS_PRD-MEINS EQ ZGTPP_IF_CONST=>GC_MEINS-G.
                LS_PRD-BDMNG = ROUND( VAL  = ( LS_PRD-BDMNG / 1000 )
                                        PREC = 3
                                        MODE = CL_ABAP_MATH=>ROUND_HALF_UP ).
              ENDIF.

              LS_PROD-BDMNG = LS_PROD-BDMNG + LS_PRD-BDMNG.

              IF LS_PRD-AUSCH IS NOT INITIAL.
                LS_PRD-REQMN = LS_PRD-BDMNG / ( 1 + LS_PRD-AUSCH / 100 ).
              ELSE.
                LS_PRD-REQMN = LS_PRD-BDMNG.
              ENDIF.

              LS_PROD-REQMN = LS_PROD-REQMN + LS_PRD-REQMN.

            ENDLOOP.
          ENDIF.

          IF LS_2340-ORDTY = 'PO'.
* 구매오더 구성부품 수량 섬
            LOOP AT GT_PROD2 INTO DATA(LS_EKPO) WHERE EBELN = LS_2340-ORDNR
                                                 AND EBELP = LS_2340-POSNR+1(5)
                                                 AND IDNRK = LS_PROD-IDNRK.

              IF LS_EKPO-MEINS EQ ZGTPP_IF_CONST=>GC_MEINS-G.
                LS_EKPO-BDMNG = ROUND( VAL  = ( LS_EKPO-BDMNG / 1000 )
                                        PREC = 3
                                        MODE = CL_ABAP_MATH=>ROUND_HALF_UP ).
              ENDIF.

              LS_PROD-BDMNG = LS_PROD-BDMNG + LS_EKPO-BDMNG.

              CLEAR LV_REQMN.
              IF LS_EKPO-AUSCH IS NOT INITIAL.
                LV_REQMN = LS_EKPO-BDMNG / ( 1 + LS_EKPO-AUSCH / 100 ).
              ELSE.
                LV_REQMN = LS_EKPO-BDMNG.
              ENDIF.

              LS_PROD-REQMN = LS_PROD-REQMN + LV_REQMN.

            ENDLOOP.
          ENDIF.

        ENDLOOP.

        READ TABLE LT_3421 INTO DATA(LS_3421) WITH KEY RQMON = LS_2330-RQMON
                                                        ZWKREQ = LS_2330-ZWKREQ
                                                        MATNR = LS_PROD-IDNRK.
        IF SY-SUBRC EQ 0.
          LS_PROD-REQNO  = LS_3421-REQNO.
          LS_PROD-POSNR  = LS_3421-POSNR.
          LS_PROD-REQDAT = LS_3421-BDTER.
          LS_PROD-STATUS = ICON_GREEN_LIGHT.
          LS_PROD-STYLE  = GT_STYLE.
        ENDIF.

        APPEND LS_PROD TO LT_PROD.
      ENDLOOP.
    ELSE.
      CLEAR LV_TABIX.
      CLEAR LS_PROD.
      REFRESH LT_AUFNR2.
      LT_AUFNR2 = VALUE #( FOR LW_2340 IN GT_2340 WHERE ( RQMON = LS_2330-RQMON
                                                    AND ZWKREQ = LS_2330-ZWKREQ
                                                    AND ORDTY = 'PRD' )
                         ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2340-ORDNR ) ).

      IF LT_AUFNR2 IS NOT INITIAL.
        REFRESH LT_MATNR.
        LT_MATNR = VALUE #( FOR LW_PRD IN GT_PROD2 WHERE ( ORDTY = 'PRD'
                                                     AND ORDNR IN LT_AUFNR2 )
                          ( LOW = LW_PRD-IDNRK ) ).
      ENDIF.
      IF LT_MATNR IS INITIAL.
        REFRESH LT_EKKO2.
        LT_EKKO2 = VALUE #( FOR LW_2340 IN GT_2340 WHERE ( RQMON = LS_2330-RQMON
                                                            AND ZWKREQ = LS_2330-ZWKREQ
                                                            AND ORDTY = 'PO' )
                                 ( EBELN = LW_2340-ORDNR EBELP = LW_2340-POSNR+1(5) ) ).

        LOOP AT GT_PROD2 INTO LS_EKPO WHERE ORDTY = 'PO'.
          READ TABLE LT_EKKO2 TRANSPORTING NO FIELDS WITH KEY EBELN = LS_EKPO-EBELN
                                                              EBELP = LS_EKPO-EBELP.
          IF SY-SUBRC EQ 0.
            CLEAR LS_MATNR.
            LS_MATNR-LOW = LS_EKPO-IDNRK.
            COLLECT LS_MATNR INTO LT_MATNR.
          ENDIF.
        ENDLOOP.
      ENDIF.

      SORT LT_MATNR BY LOW.
      DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

      LOOP AT LT_MATNR INTO LS_MATNR.

        CLEAR LV_TABIX.
        LOOP AT GT_2340 INTO LS_2340 WHERE RQMON = LS_2330-RQMON
                                       AND ZWKREQ = LS_2330-ZWKREQ.

          IF LS_2340-ORDTY = 'PRD'.
            LOOP AT GT_PROD2 INTO LS_PRD WHERE ORDTY = 'PRD'
                                           AND ORDNR = LS_2340-ORDNR
                                           AND IDNRK = LS_MATNR-LOW.
              ADD 1 TO LV_TABIX.
              IF LV_TABIX = 1.
                CLEAR LS_PROD.
                MOVE-CORRESPONDING LS_PRD TO LS_PROD.

*                LS_PROD-ORDNR = LS_2330-ZWKREQ.
                LS_PROD-ORDTY = 'PLN'.
                LS_PROD-GUBUN = '반제품 계획'.
                LS_PROD-ORDNR_I = ICON_DETAIL.

                IF LS_PROD-MEINS EQ ZGTPP_IF_CONST=>GC_MEINS-G.
                  LS_PROD-BDMNG = ROUND( VAL  = ( LS_PROD-BDMNG / 1000 )
                                          PREC = 3
                                          MODE = CL_ABAP_MATH=>ROUND_HALF_UP ).
                  LS_PROD-MEINS = ZGTPP_IF_CONST=>GC_MEINS-G.
                ENDIF.

                IF LS_PROD-AUSCH IS NOT INITIAL.
                  LS_PROD-REQMN = LS_PROD-BDMNG / ( 1 + LS_PROD-AUSCH / 100 ).
                ELSE.
                  LS_PROD-REQMN = LS_PROD-BDMNG.
                ENDIF.

                LS_PROD-PDCAPROCCODE = LS_2330-GONG_CD.
                LS_PROD-RQMON = LS_2330-RQMON.
                LS_PROD-ZWKREQ = LS_2330-ZWKREQ.

              ELSE.
                IF LS_PRD-MEINS EQ ZGTPP_IF_CONST=>GC_MEINS-G.
                  LS_PRD-BDMNG = ROUND( VAL  = ( LS_PRD-BDMNG / 1000 )
                                          PREC = 3
                                          MODE = CL_ABAP_MATH=>ROUND_HALF_UP ).
                ENDIF.

                LS_PROD-BDMNG = LS_PROD-BDMNG + LS_PRD-BDMNG.

                IF LS_PRD-AUSCH IS NOT INITIAL.
                  LS_PRD-REQMN = LS_PRD-BDMNG / ( 1 + LS_PRD-AUSCH / 100 ).
                ELSE.
                  LS_PRD-REQMN = LS_PRD-BDMNG.
                ENDIF.

                LS_PROD-REQMN = LS_PROD-REQMN + LS_PRD-REQMN.
              ENDIF.
            ENDLOOP.
          ENDIF.

          IF LS_2340-ORDTY = 'PO'.
            LOOP AT GT_PROD2 INTO LS_EKPO WHERE EBELN = LS_2340-ORDNR
                                           AND EBELP = LS_2340-POSNR+1(5)
                                           AND IDNRK = LS_MATNR-LOW.

              ADD 1 TO LV_TABIX.
              IF LV_TABIX = 1.
                CLEAR LS_PROD.
                MOVE-CORRESPONDING LS_EKPO TO LS_PROD.

*                LS_PROD-ORDNR = LS_2330-ZWKREQ.
                LS_PROD-ORDTY = 'PLN'.
                LS_PROD-GUBUN = '반제품 계획'.
                LS_PROD-ORDNR_I = ICON_DETAIL.

                IF LS_PROD-MEINS EQ ZGTPP_IF_CONST=>GC_MEINS-G.
                  LS_PROD-BDMNG = ROUND( VAL  = ( LS_PROD-BDMNG / 1000 )
                                          PREC = 3
                                          MODE = CL_ABAP_MATH=>ROUND_HALF_UP ).
                  LS_PROD-MEINS = ZGTPP_IF_CONST=>GC_MEINS-G.
                ENDIF.

                IF LS_PROD-AUSCH IS NOT INITIAL.
                  LS_PROD-REQMN = LS_PROD-BDMNG / ( 1 + LS_PROD-AUSCH / 100 ).
                ELSE.
                  LS_PROD-REQMN = LS_PROD-BDMNG.
                ENDIF.

                LS_PROD-PDCAPROCCODE = LS_2330-GONG_CD.
                LS_PROD-RQMON = LS_2330-RQMON.
                LS_PROD-ZWKREQ = LS_2330-ZWKREQ.

              ELSE.
                IF LS_EKPO-MEINS EQ ZGTPP_IF_CONST=>GC_MEINS-G.
                  LS_EKPO-BDMNG = ROUND( VAL  = ( LS_EKPO-BDMNG / 1000 )
                                          PREC = 3
                                          MODE = CL_ABAP_MATH=>ROUND_HALF_UP ).
                ENDIF.

                LS_PROD-BDMNG = LS_PROD-BDMNG + LS_EKPO-BDMNG.

                CLEAR LV_REQMN.
                IF LS_EKPO-AUSCH IS NOT INITIAL.
                  LV_REQMN = LS_EKPO-BDMNG / ( 1 + LS_EKPO-AUSCH / 100 ).
                ELSE.
                  LV_REQMN = LS_EKPO-BDMNG.
                ENDIF.

                LS_PROD-REQMN = LS_PROD-REQMN + LV_REQMN.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDLOOP.

        READ TABLE LT_3421 INTO LS_3421 WITH KEY RQMON = LS_2330-RQMON
                                                 ZWKREQ = LS_2330-ZWKREQ
                                                 MATNR = LS_PROD-IDNRK.
        IF SY-SUBRC EQ 0.
          LS_PROD-REQNO  = LS_3421-REQNO.
          LS_PROD-POSNR  = LS_3421-POSNR.
          LS_PROD-REQDAT = LS_3421-BDTER.
          LS_PROD-STATUS = ICON_GREEN_LIGHT.
          LS_PROD-STYLE  = GT_STYLE.
        ENDIF.
        APPEND LS_PROD TO LT_PROD.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

  REFRESH GT_PROD3.
  IF LT_PROD[] IS NOT INITIAL.
    GT_PROD3 = LT_PROD.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_POPUP_ORDERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_PROD_RQMON
*&      --> LS_PROD_ZWKREQ
*&---------------------------------------------------------------------*
FORM DISP_POPUP_ORDERS  USING    PS_PROD TYPE TY_S_PROD.

  DATA : LS_DISP_800 LIKE GS_DISP_800.
  REFRESH GT_DISP_800.


  READ TABLE GT_2330 INTO DATA(LS_2330) WITH KEY RQMON = PS_PROD-RQMON
                                                 ZWKREQ = PS_PROD-ZWKREQ.
  IF SY-SUBRC EQ 0.
    IF LS_2330-PLNUM IS NOT INITIAL.
      LOOP AT GT_PROD2 INTO DATA(LS_PROD) WHERE ORDTY = 'PLN'
                                            AND ORDNR = LS_2330-PLNUM
                                            AND IDNRK = PS_PROD-IDNRK.
        CLEAR LS_DISP_800.
        MOVE-CORRESPONDING LS_PROD TO LS_DISP_800.
        LS_DISP_800-RQMON = PS_PROD-RQMON.
        LS_DISP_800-ZWKREQ = PS_PROD-ZWKREQ.
        LS_DISP_800-ORDNO = LS_2330-PLNUM.

        APPEND LS_DISP_800 TO GT_DISP_800.
      ENDLOOP.

    ENDIF.

    LOOP AT GT_2340 INTO DATA(LS_2340) WHERE RQMON = PS_PROD-RQMON
                                         AND ZWKREQ = PS_PROD-ZWKREQ.

      CASE LS_2340-ORDTY.
        WHEN 'PRD'.
          READ TABLE GT_PROD2 INTO LS_PROD WITH KEY ORDTY = 'PRD'
                                           ORDNR = LS_2340-ORDNR
                                           IDNRK = PS_PROD-IDNRK.
          IF SY-SUBRC EQ 0.
            CLEAR LS_DISP_800.
            MOVE-CORRESPONDING LS_PROD TO LS_DISP_800.
            LS_DISP_800-RQMON = PS_PROD-RQMON.
            LS_DISP_800-ZWKREQ = PS_PROD-ZWKREQ.
            LS_DISP_800-ORDNO = LS_2340-ORDNR.
            APPEND LS_DISP_800 TO GT_DISP_800.
          ENDIF.
        WHEN 'PO'.
          READ TABLE GT_PROD2 INTO LS_PROD WITH KEY ORDTY = 'PO'
                                           EBELN = LS_2340-ORDNR
                                           EBELP = LS_2340-POSNR+1(5)
                                           IDNRK = PS_PROD-IDNRK.
          IF SY-SUBRC EQ 0.
            CLEAR LS_DISP_800.
            MOVE-CORRESPONDING LS_PROD TO LS_DISP_800.
            LS_DISP_800-RQMON = PS_PROD-RQMON.
            LS_DISP_800-ZWKREQ = PS_PROD-ZWKREQ.
            LS_DISP_800-ORDNO = LS_2340-ORDNR.
            LS_DISP_800-ORDPO = LS_2340-POSNR.
            APPEND LS_DISP_800 TO GT_DISP_800.
          ENDIF.

      ENDCASE.
    ENDLOOP.

    IF GT_DISP_800[] IS NOT   INITIAL.
      CALL SCREEN '0900' STARTING AT 5 5 ENDING AT 125 11.
    ENDIF.


  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0900 .

  CREATE OBJECT GO_CONTAIN_0900
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 3000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

* 그리드 적용
  CREATE OBJECT GO_GRID_0900
    EXPORTING
      I_PARENT      = GO_CONTAIN_0900
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0900 .

  CLEAR GS_LAYOUT_0900.
  GS_LAYOUT_0900-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0900-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0900-NO_ROWMARK = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0900 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3180TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP_800'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0900.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0900[]
    TABLES
      IT_DATA         = GT_DISP_800
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0900 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'RQMON'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE  = 'C100'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZWKREQ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EMPHASIZE  = 'C100'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'IDNRK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'IDNTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'BDMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'REQMN'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'AUSCH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29.
        <LS_FCAT>-JUST = 'R'.
      WHEN 'REQDAT'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'LGORT'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'LGFSB'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'ORDNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F94.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ORDPO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F95.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ORDTY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F96.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'RSNUM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'RSPOS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'BDTER'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F81.
        <LS_FCAT>-JUST = 'C'.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0900 .

  REFRESH GT_SORT_0900.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0900
                            USING : 1 'RQMON' 'X' '' '',
                                  2 'ZWKREQ' 'X' '' 'X',
                                  3 'MATNR' 'X' '' '',
                                  4 'MAKTX' 'X' '' '',
                                  5 'MAKTX' 'X' '' '',
                                  6 'IDNRK' 'X' '' '',
                                  7 'IDNTX' 'X' '' '',
                                  8 'ORDNO' 'X' '' '',
                                  9 'ORDPO' 'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_TAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_SORT_TAB  TABLES   PT_SORTTAB STRUCTURE LVC_S_SORT
                   USING    PV_POS
                               PV_FIELDNAME
                               PV_UP
                               PV_DOWN
                               PV_SUBTOT.

  DATA : LS_SORT TYPE LVC_S_SORT.
  LS_SORT-SPOS = PV_POS.
  LS_SORT-FIELDNAME = PV_FIELDNAME.
  LS_SORT-UP = PV_UP.
  LS_SORT-DOWN = PV_DOWN.
  LS_SORT-SUBTOT =  PV_SUBTOT.
  APPEND LS_SORT TO PT_SORTTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0900
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0900 .

  REFRESH GT_EXCLUDE_0900.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0900
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0900_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0900_DISPLAY .

  CALL METHOD GO_GRID_0900->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0900
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0900
    CHANGING
      IT_OUTTAB            = GT_DISP_800
      IT_SORT              = GT_SORT_0900
      IT_FIELDCATALOG      = GT_FIELDCAT_0900.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0900 INPUT.

  CLEAR GV_OKCODE3.
  GV_OKCODE3 = SY-UCOMM.

  CASE GV_OKCODE3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CONFIRM'.
      CALL METHOD GO_CONTAIN_0900->FREE.
      FREE : GO_CONTAIN_0900, GO_GRID_0900.
      FREE : GT_SORT_0900, GT_EXCLUDE_0900, GT_FIELDCAT_0900.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_JOJANG_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_JOJANG_LIST .

  REFRESH GT_CHK_REQNO.

  SELECT * FROM ZGTPPT2000
    INTO TABLE @DATA(LT_2000)
   WHERE WERKS = @P_WERKS
     AND SPGCD = @P_SPGCD
     AND GRPNR IN @S_GRPNR3.

  IF LT_2000[] IS NOT INITIAL.
    SORT LT_2000 BY ORDNO POSNR.
    DELETE ADJACENT DUPLICATES FROM LT_2000 COMPARING ORDNO POSNR.

    SELECT DISTINCT B~REQNO, B~POSNR
      FROM @LT_2000 AS A
      INNER JOIN ZGTPPT3422 AS B
                            ON B~VBELN = A~ORDNO
                           AND B~VBELP = A~POSNR
     WHERE B~ZSTATUS = @ABAP_FALSE
      INTO CORRESPONDING FIELDS OF   TABLE @GT_CHK_REQNO.
  ENDIF.


  SELECT * FROM ZGTPPT2010
    INTO TABLE @DATA(LT_2010)
   WHERE GRPNR IN @S_GRPNR3
     AND ORDTY IN ( 'PRD', 'PLN' ).

  IF LT_2010[] IS NOT INITIAL.
    SORT LT_2010 BY ORDNR POSNR.
    DELETE ADJACENT DUPLICATES FROM LT_2010 COMPARING ORDNR POSNR.

    SELECT DISTINCT B~REQNO, B~POSNR
      FROM @LT_2010 AS A
      INNER JOIN ZGTPPT3421 AS B
                            ON B~AUFNR = A~ORDNR
     WHERE B~ZSTATUS = @ABAP_FALSE
      APPENDING CORRESPONDING FIELDS OF TABLE @GT_CHK_REQNO.

    SELECT DISTINCT B~REQNO, B~POSNR
      FROM @LT_2010 AS A
      INNER JOIN ZGTPPT3421 AS B
                            ON B~PLNUM = A~ORDNR
     WHERE B~ZSTATUS = @ABAP_FALSE
      APPENDING CORRESPONDING FIELDS OF TABLE @GT_CHK_REQNO.

  ENDIF.

  SELECT DISTINCT REQNO, POSNR
    FROM ZGTPPT3421
   WHERE WERKS = @P_WERKS
     AND SPGCD = @P_SPGCD
     AND ZSTATUS = @ABAP_FALSE
     AND GRPNR IN @S_GRPNR3
    APPENDING CORRESPONDING FIELDS OF TABLE @GT_CHK_REQNO.

  SELECT DISTINCT REQNO, POSNR
    FROM ZGTPPT3422
   WHERE WERKS = @P_WERKS
     AND SPGCD = @P_SPGCD
     AND ZSTATUS = @ABAP_FALSE
     AND GRPNR IN @S_GRPNR3
    APPENDING CORRESPONDING FIELDS OF TABLE @GT_CHK_REQNO.

  SORT GT_CHK_REQNO BY REQNO POSNR.
  DELETE ADJACENT DUPLICATES FROM GT_CHK_REQNO COMPARING REQNO POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_GRPNR_FROM_REQNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_GRPNR_FROM_REQNO .

  SELECT DISTINCT * FROM ZGTPPT3421
    INTO TABLE GT_3421
    FOR ALL ENTRIES IN GT_CHK_REQNO
   WHERE REQNO = GT_CHK_REQNO-REQNO
     AND POSNR = GT_CHK_REQNO-POSNR
     AND ZSTATUS = ABAP_FALSE.

  SELECT DISTINCT * FROM ZGTPPT3422
    INTO TABLE GT_3422
    FOR ALL ENTRIES IN GT_CHK_REQNO
   WHERE REQNO = GT_CHK_REQNO-REQNO
     AND POSNR = GT_CHK_REQNO-POSNR
     AND ZSTATUS = ABAP_FALSE.

  IF GT_3421[] IS NOT INITIAL.
    SELECT B~*
      FROM @GT_3421 AS A
      INNER JOIN ZGTPPT2010 AS B ON B~ORDNR = A~AUFNR
                                AND B~ORDTY = 'PRD'
      INTO TABLE @DATA(LT_2010).

    SELECT B~*
      FROM @GT_3421 AS A
      INNER JOIN ZGTPPT2010 AS B ON B~ORDNR = A~PLNUM
                                AND B~ORDTY = 'PLN'
      APPENDING TABLE @LT_2010.

    LOOP AT GT_3421 ASSIGNING FIELD-SYMBOL(<LS_3421>).
      IF <LS_3421>-GRPNR IS INITIAL.
        READ TABLE LT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = <LS_3421>-AUFNR.
        IF SY-SUBRC EQ 0.
          <LS_3421>-GRPNR = LS_2010-GRPNR.
        ELSE.
          IF <LS_3421>-PLNUM IS NOT INITIAL.
            READ TABLE LT_2010 INTO LS_2010 WITH KEY ORDNR = <LS_3421>-PLNUM.
            IF SY-SUBRC EQ 0.
              <LS_3421>-GRPNR = LS_2010-GRPNR.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDIF.

  IF GT_3422[] IS NOT INITIAL.
    SELECT B~*
      FROM @GT_3422 AS A
      INNER JOIN ZGTPPT2000 AS B ON B~ORDNO = A~VBELN
                                AND B~POSNR = A~VBELP
      INTO TABLE @DATA(LT_2000).

    LOOP AT GT_3422 ASSIGNING FIELD-SYMBOL(<LS_3422>).
      IF <LS_3422>-GRPNR IS INITIAL.
        READ TABLE LT_2000 INTO DATA(LS_2000) WITH KEY ORDNO = <LS_3422>-VBELN
                                                       POSNR = <LS_3422>-VBELP.
        IF SY-SUBRC EQ 0.
          <LS_3422>-GRPNR = LS_2000-GRPNR.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_TRANSACTION_ZGTPPR2350
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LIST_REQNO
*&      --> LS_LIST_POSNR
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_ZGTPPR2350  USING    PV_REQNO TYPE ZGTPPT3420-REQNO
                                           PV_POSNR  TYPE ZGTPPT3420-POSNR.

  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2010-GRPNR.
  DATA : LS_GRPNR LIKE LINE OF LT_GRPNR.
  DATA : LV_FIELDNAME TYPE BDCDATA-FNAM.
  DATA : LV_NUM(2) TYPE N.


  REFRESH LT_GRPNR.

  LOOP AT GT_3421 INTO DATA(LS_3421) WHERE REQNO = PV_REQNO
                                       AND POSNR = PV_POSNR.
    CLEAR LS_GRPNR.
    IF LS_3421-GRPNR IS NOT INITIAL.
      LS_GRPNR-SIGN = 'I'.
      LS_GRPNR-OPTION = 'I'.
      LS_GRPNR-LOW = LS_3421-GRPNR.
      COLLECT LS_GRPNR INTO LT_GRPNR.
    ENDIF.

  ENDLOOP.

  LOOP AT GT_3422 INTO DATA(LS_3422) WHERE REQNO = PV_REQNO
                                       AND POSNR = PV_POSNR.
    CLEAR LS_GRPNR.
    IF LS_3422-GRPNR IS NOT INITIAL.
      LS_GRPNR-SIGN = 'I'.
      LS_GRPNR-OPTION = 'I'.
      LS_GRPNR-LOW = LS_3422-GRPNR.
      COLLECT LS_GRPNR INTO LT_GRPNR.
    ENDIF.

  ENDLOOP.


  REFRESH : GT_BDCDATA, GT_MESSTAB.
  __SETTING_BDC_PARAMS.

  __BDC_DYNPRO 'ZGTPPR2140' '1000'.
  __BDC_FIELD : 'BDC_CURSOR' 'S_GRPNR-LOW',
                      'BDC_OKCODE'  '=%019',
                      'P_WERKS' P_WERKS,
                      'P_SPGCD' P_SPGCD.

  __BDC_DYNPRO 'SAPLALDB' '3000'.
  __BDC_FIELD : 'BDC_OKCODE' '=ACPT'.

  LOOP AT LT_GRPNR INTO LS_GRPNR.
    ADD 1 TO LV_NUM.
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |RSCSEL_255-SLOW_I({ LV_NUM })|.

    __BDC_FIELD : LV_FIELDNAME LS_GRPNR-LOW.
  ENDLOOP.

  __BDC_TRANSACTION 'ZGTPPR2350'.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_REQ_RESULT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_REQ_RESULT .

  IF NOT ( P_WERKS = '6600' AND P_SPGCD = 'GL' ).

    REFRESH GT_LIST.

    SELECT ZT01~WERKS,
         ZT01~SPGCD,
         ZT01~REQNO,
         ZT01~POSNR,
         ZT01~DRUMFLAG,
         ZT01~MATNR,
         ZT01~LFIMG,
         ZT01~ERFME,
         ZT01~REQDAT,
         ZT01~LGORT_T,
         ZT01~BANFN,
         ZT01~BNFPO,
         EKPO~EBELN,
         EKPO~EBELP,
*         zt01~zstatus,
         MAKT~MAKTX
    FROM ZGTPPT3420 AS ZT01
    LEFT JOIN EKPO
      ON ZT01~WERKS EQ EKPO~WERKS
     AND ZT01~REQNO EQ EKPO~BEDNR
     AND ZT01~POSNR EQ EKPO~AFNAM
     AND EKPO~LOEKZ EQ @SPACE
    LEFT JOIN MAKT
      ON ZT01~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   WHERE ZT01~WERKS   EQ @P_WERKS
     AND ZT01~SPGCD   EQ @P_SPGCD
     AND ZT01~ZSTATUS EQ @SPACE
   ORDER BY ZT01~WERKS, ZT01~SPGCD,ZT01~REQNO, ZT01~POSNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

    REFRESH GT_CHK_REQNO.
    LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
      CLEAR GS_CHK_REQNO.
      MOVE-CORRESPONDING <LS_LIST> TO GS_CHK_REQNO.
      APPEND GS_CHK_REQNO TO GT_CHK_REQNO.
    ENDLOOP.

    IF GT_CHK_REQNO[] IS NOT INITIAL.
      PERFORM GET_GRPNR_FROM_REQNO.
    ENDIF.
  ENDIF.

ENDFORM.
