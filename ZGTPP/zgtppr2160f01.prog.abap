*&---------------------------------------------------------------------*
*& Include          ZGTPPR2160F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INITIALIZATION.

  DATA: LV_PREV_DATE LIKE P0001-BEGDA.

  GR_CONV = NEW #( ).

  GET PARAMETER ID 'WRK' FIELD P_WERKS.
  GET PARAMETER ID 'LAG' FIELD P_LGORT.

  SSCRFIELDS-FUNCTXT_01 = TEXT-FC1.
  SSCRFIELDS-FUNCTXT_02 = TEXT-FC2.

  IF SY-TCODE EQ GC_TCODE-ZGTPPR2161.
    S_MTART[] = VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = ZGTPP_IF_CONST=>GC_MTART-MCHA )
                                                  ( LOW = ZGTPP_IF_CONST=>GC_MTART-HAWA ) ).
  ELSEIF SY-TCODE EQ GC_TCODE-ZGTPPR2169.
    CLEAR: P_WKORD.
    P_RESLT = 'X'.
  ENDIF.

  PERFORM GET_PARAMETER_DESCRIPTION.

  IF S_ERDAT[] IS INITIAL.  "판매오더 생성일자
    CLEAR: LV_PREV_DATE.
    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        DATE      = SY-DATUM
        DAYS      = '00'
        MONTHS    = '01'
        SIGNUM    = '-'
        YEARS     = '00'
      IMPORTING
        CALC_DATE = LV_PREV_DATE.

    S_ERDAT-SIGN = 'I'.
    S_ERDAT-OPTION = 'BT'.
    S_ERDAT-LOW = LV_PREV_DATE+0(6) && |01|.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN            = SY-DATUM
      IMPORTING
        LAST_DAY_OF_MONTH = S_ERDAT-HIGH
      EXCEPTIONS
        DAY_IN_NO_DATE    = 1
        OTHERS            = 2.

    APPEND S_ERDAT.
  ENDIF.

  IF S_CRDAT[] IS INITIAL.  "주문 할당 일자
    S_CRDAT-SIGN = 'I'.
    S_CRDAT-OPTION = 'BT'.
    S_CRDAT-LOW = SY-DATUM+0(6) && |01|.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN            = SY-DATUM
      IMPORTING
        LAST_DAY_OF_MONTH = S_CRDAT-HIGH
      EXCEPTIONS
        DAY_IN_NO_DATE    = 1
        OTHERS            = 2.

    APPEND S_CRDAT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form start_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM START_OF_SELECTION.

  PERFORM GET_MASTER_DATA.

  CASE ABAP_TRUE.
    WHEN P_WKORD. "// 주문 할당 및 작업 지시.
      PERFORM PROC_ORDER_ALLOC_WORK_ORDER.

    WHEN P_RESLT. "// 지시 결과 조회.
      PERFORM DISPLAY_PROCESSING_RESULTS.

    WHEN P_CNCEL. "// 지시 결과 취소.
      PERFORM DISPLAY_PROCESSING_CANCEL.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form end_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM END_OF_SELECTION .

  CASE ABAP_TRUE.
    WHEN P_WKORD. "// 주문 할당 및 작업 지시.
      IF GT_SLORD IS INITIAL.
        MESSAGE S033.
        LEAVE LIST-PROCESSING.
      ENDIF.

    WHEN P_RESLT. "// 지시 결과 조회.
      IF GT_CUTTING IS INITIAL AND GT_ALLOC IS INITIAL.
        MESSAGE S033.
        LEAVE LIST-PROCESSING.
      ENDIF.

    WHEN P_CNCEL. "// 지시 결과 취소.
      IF GT_CUTTING IS INITIAL AND GT_ALLOC IS INITIAL.
        MESSAGE S033.
        LEAVE LIST-PROCESSING.
      ENDIF.
  ENDCASE.

  PERFORM CALL_SCREEN_100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_exit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_EXIT .

  IF GR_DOCKING_CONTAINER IS BOUND.
    GR_DOCKING_CONTAINER->FREE( ).
    CLEAR GR_DOCKING_CONTAINER.
  ENDIF.

  IF GR_SLORD IS BOUND.
    GR_SLORD->FREE( ).
    CLEAR GR_SLORD.
  ENDIF.

  IF GR_STOCK IS BOUND.
    GR_STOCK->FREE( ).
    CLEAR GR_STOCK.
  ENDIF.

  IF GR_WKORD IS BOUND.
    GR_WKORD->FREE( ).
    CLEAR GR_WKORD.
  ENDIF.

  IF GR_CUTTING IS BOUND.
    GR_CUTTING->FREE( ).
    CLEAR GR_CUTTING.
  ENDIF.

  IF GR_ALLOC IS BOUND.
    GR_ALLOC->FREE( ).
    CLEAR GR_ALLOC.
  ENDIF.

  IF GR_TABMT IS BOUND.
    GR_TABMT->FREE( ).
    CLEAR GR_TABMT.

    PERFORM DEQUEUE_TABLE.
  ENDIF.

  LEAVE TO SCREEN 0.

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

  IF PR_SENDER EQ GR_SLORD.
    PERFORM MODIFY_FCAT_IN_SLORD.
  ENDIF.

  IF PR_SENDER EQ GR_STOCK.
    PERFORM MODIFY_FCAT_IN_STOCK.
  ENDIF.

  IF PR_SENDER EQ GR_WKORD.
    PERFORM MODIFY_FCAT_IN_WKORD.
  ENDIF.

  IF PR_SENDER EQ GR_CUTTING.
    PERFORM MODIFY_FCAT_IN_CUTTING.
  ENDIF.

  IF PR_SENDER EQ GR_ALLOC.
    PERFORM MODIFY_FCAT_IN_ALLOC.
  ENDIF.

  IF PR_SENDER EQ GR_TABMT.
    PERFORM MODIFY_FCAT_IN_TABMT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_LAYOUT USING PR_SENDER.

  IF PR_SENDER EQ GR_SLORD.
    PERFORM SET_LAYOUT_IN_SLORD.
  ENDIF.

  IF PR_SENDER EQ GR_STOCK.
    PERFORM SET_LAYOUT_IN_STOCK.
  ENDIF.

  IF PR_SENDER EQ GR_WKORD.
    PERFORM SET_LAYOUT_IN_WKORD.
  ENDIF.

  IF PR_SENDER EQ GR_CUTTING.
    PERFORM SET_LAYOUT_IN_CUTTING.
  ENDIF.

  IF PR_SENDER EQ GR_ALLOC.
    PERFORM SET_LAYOUT_IN_ALLOC.
  ENDIF.

  IF PR_SENDER EQ GR_TABMT.
    PERFORM SET_LAYOUT_IN_TABMT.
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

  IF GR_SLORD IS BOUND AND PR_SENDER EQ GR_SLORD->MR_GRID.
    PERFORM DOUBLE_CLICK_IN_SLORD USING PS_ROW PS_COLUMN.
  ENDIF.

  IF GR_STOCK IS BOUND AND PR_SENDER EQ GR_STOCK->MR_GRID.
    PERFORM DOUBLE_CLICK_IN_STOCK USING PS_ROW PS_COLUMN.
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
      WHEN 'WK1'.
        IF P_WKORD EQ ABAP_FALSE.
          LS_SCREEN-ACTIVE = 0.
          MODIFY SCREEN FROM LS_SCREEN.
        ENDIF.

      WHEN 'WK2'.
        IF P_WKORD EQ ABAP_FALSE.
          LS_SCREEN-ACTIVE = 0.
          MODIFY SCREEN FROM LS_SCREEN.
        ELSE.
          LS_SCREEN-INPUT = 0.
          MODIFY SCREEN FROM LS_SCREEN.
        ENDIF.

      WHEN 'RST'.
        IF P_RESLT EQ ABAP_FALSE.
          LS_SCREEN-ACTIVE = 0.
          MODIFY SCREEN FROM LS_SCREEN.
        ENDIF.

      WHEN 'HAW'.
        IF SY-TCODE EQ GC_TCODE-ZGTPPR2161.
          LS_SCREEN-INPUT = 0.
          MODIFY SCREEN FROM LS_SCREEN.
        ENDIF.

        IF P_CNCEL EQ ABAP_TRUE.
          LS_SCREEN-ACTIVE = 0.
          MODIFY SCREEN FROM LS_SCREEN.
        ENDIF.

      WHEN 'CNL'.
        IF P_CNCEL EQ ABAP_FALSE.
          LS_SCREEN-ACTIVE = 0.
          MODIFY SCREEN FROM LS_SCREEN.
        ENDIF.

      WHEN 'STD'.
        IF P_CNCEL EQ ABAP_TRUE.
          LS_SCREEN-ACTIVE = 0.
          MODIFY SCREEN FROM LS_SCREEN.
        ENDIF.
    ENDCASE.

    IF LS_SCREEN-NAME EQ 'P_NAME1' OR LS_SCREEN-NAME EQ 'P_LGOBE'.
      LS_SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN FROM LS_SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form at_selection_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM AT_SELECTION_SCREEN .

  CASE SSCRFIELDS-UCOMM.
    WHEN GC_FCODE-FC01. "// (군포) 합판드럼 지정 규칙.
      PERFORM USER_COMMAND_FC01.

    WHEN GC_FCODE-FC02. "// (전주) 목드럼 지정 규칙.
      PERFORM USER_COMMAND_FC02.

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
  PERFORM CHECK_PLANT_CODE.

*// 저장위치.
  PERFORM CHECK_STORAGE_LOCATION.

*// 배치번호(계획)
  PERFORM CHECK_FCHARG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_screen_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_100 .

  GV_TPAR1 = COND #( WHEN P_WKORD IS NOT INITIAL THEN |{ TEXT-C11 }|
                     WHEN P_RESLT IS NOT INITIAL THEN TEXT-C12
                     WHEN P_CNCEL IS NOT INITIAL THEN TEXT-C21 ).

  IF P_WKORD IS NOT INITIAL.
    GV_TPAR2 = COND #( WHEN P_CUT   IS NOT INITIAL THEN | - { TEXT-C13 }|
                       WHEN P_LANBX IS NOT INITIAL THEN | - { TEXT-C14 }|
                       WHEN P_OPTIC IS NOT INITIAL THEN | - { TEXT-C15 }|
                       WHEN P_EA    IS NOT INITIAL THEN | - { TEXT-C17 }|
                       WHEN P_AD    IS NOT INITIAL THEN | - { TEXT-C22 }| ).
  ENDIF.

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form proc_order_alloc_work_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM PROC_ORDER_ALLOC_WORK_ORDER .

  PERFORM GET_SALES_ORDER.
  PERFORM GET_MATERIAL_STOCK.
  PERFORM READ_SO_CONFIGURATION.

  SORT GT_SLORD BY DRDAT ERDAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_processing_results
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DISPLAY_PROCESSING_RESULTS .

*// 절단 작업 지시.
  PERFORM GET_CUTTING_RESULT.

*// 주문 할당.
  PERFORM GET_ALLOCTION_RESULT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_sales_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_SALES_ORDER .

  DATA LV_DYN(50).
  DATA LV_FIXMG(50).

  CLEAR: LV_DYN.
  IF P_G1 EQ SPACE.
    LV_DYN = |VBEP~LIFSP EQ 'G1'|.
  ELSE.
    LV_DYN = |VBEP~LIFSP NE 'G1'|.
  ENDIF.

  "난척발생분 조건
  CLEAR: LV_FIXMG.
  IF P_AD EQ 'X'.
    LV_FIXMG = |VBAP~FIXMG EQ 'X'|.
  ENDIF.

  SELECT DISTINCT
         VBAK~VKBUR, VBAK~KUNNR, VBAK~VKORG, VBAK~VTWEG, VBAK~SPART,
         VBAK~VKGRP, VBAK~ERDAT,
         VBAP~VBELN, VBAP~POSNR, VBAP~CUOBJ, VBAP~WERKS, VBAP~MATNR,
         VBEP~ETENR, VBEP~EDATU, VBEP~LIFSP, VBEP~VRKME, VBEP~WMENG AS WEMENG,
         MARC~FEVOR, MARC~XCHAR, MARC~DPCBT,
         MARA~MTART, MARA~MATKL, MARA~MEINS, MARA~CUOBF, MARA~ZZSPEC_NO,
         MAKT~MAKTX,
         KNA1~NAME1,
*         AUFK~KDAUF, AUFK~KDPOS, AUFK~ZZKDAUF, AUFK~ZZCUT_REQ,
         @P_LGORT AS LGORT
    FROM VBAK
    JOIN VBAP
      ON VBAK~VBELN EQ VBAP~VBELN
    JOIN VBEP
      ON VBAP~VBELN EQ VBEP~VBELN
     AND VBAP~POSNR EQ VBEP~POSNR
     AND VBEP~ETENR EQ '0001'
    JOIN MARC
      ON VBAP~MATNR EQ MARC~MATNR
     AND VBAP~WERKS EQ MARC~WERKS
    JOIN MARA
      ON VBAP~MATNR EQ MARA~MATNR
*    LEFT JOIN AUFK
*      ON VBAP~VBELN EQ AUFK~KDAUF
*     AND VBAP~POSNR EQ AUFK~KDPOS
*     AND AUFK~LOEKZ EQ @SPACE
    LEFT JOIN MAKT
      ON VBAP~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
    LEFT JOIN KNA1
      ON VBAK~KUNNR EQ KNA1~KUNNR
   WHERE VBAP~WERKS EQ @P_WERKS
     AND VBAP~VBELN IN @S_VBELN
     AND VBAP~POSNR IN @S_POSNR
     AND VBAK~VKBUR IN @S_VKBUR
     AND VBAK~KUNNR IN @S_KUNNR
     AND VBAK~ERDAT IN @S_ERDAT
     AND VBEP~EDATU IN @S_EDATU
     AND VBAP~MATNR IN @S_MATNR
     AND VBAP~ABGRU EQ @SPACE
     AND MARC~FEVOR IN @S_FEVOR
     AND MARA~MTART IN @S_MTART
     AND MARA~MATKL IN @S_MATKL
     AND (LV_DYN)
     AND (LV_FIXMG)
*     AND VBEP~LIFSP IN @S_LIFSP
   ORDER BY VBAP~VBELN, VBAP~POSNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_SLORD.

*// 특별사유 절단요청 추출.
*  DELETE GT_SLORD WHERE ZZKDAUF   IS NOT INITIAL
*                    AND ZZCUT_REQ IS INITIAL.

  IF GT_SLORD IS INITIAL.
    MESSAGE S033.
    LEAVE LIST-PROCESSING.
  ENDIF.

  SELECT 'I'     AS SIGN,
         'EQ'    AS OPTION,
         A~MATNR AS LOW
    FROM @GT_SLORD AS A
   GROUP BY A~MATNR
    INTO TABLE @GT_MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_so_configuration
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM READ_SO_CONFIGURATION .
  DATA LV_LABST TYPE MARD-LABST.
  DATA LV_STOCK_WECNT TYPE I.
  DATA LV_STAND_WECNT TYPE I.

  SELECT VBELN, POSNR, SUM( CAST( A~WELENG AS QUAN ) * CAST( A~ZCUT_CNT AS INT4 ) ) AS MENGE
    FROM @GT_LINK_DETAIL AS A
   WHERE ZEXCLUDE EQ @ABAP_FALSE
   GROUP BY VBELN, POSNR
   ORDER BY VBELN, POSNR
    INTO TABLE @DATA(LT_ALLOC).

  SELECT A~*
    FROM @GT_LINK_STOCK AS A
   WHERE STOCK_TABLE EQ @ZGTPP_IF_CONST=>GC_STOCK_TABLE-MCHB
   ORDER BY A~WERKS, A~LGORT, A~MATNR
    INTO TABLE @DATA(LT_MCHB).

  SELECT A~*
    FROM @GT_LINK_STOCK AS A
   WHERE STOCK_TABLE EQ @ZGTPP_IF_CONST=>GC_STOCK_TABLE-MSKA
   ORDER BY A~VBELN, A~POSNR, A~MATNR
    INTO TABLE @DATA(LT_MSKA).

  LOOP AT GT_SLORD REFERENCE INTO DATA(LR_SLORD).
    PERFORM GET_VALUE_FROM_CONFIG USING LR_SLORD->*.

*// 납품단위와 기본단위가 다를 경우 단위 변환.
    IF LR_SLORD->MEINS NE LR_SLORD->VRKME.
      PERFORM CONVERT_MATERIAL_UNIT USING LR_SLORD->MATNR LR_SLORD->WEMENG
                                          LR_SLORD->VRKME LR_SLORD->MEINS.
      LR_SLORD->VRKME = LR_SLORD->MEINS.
    ENDIF.

*// 기할당 수량.
    IF P_AD NE 'X'.
      READ TABLE LT_ALLOC INTO DATA(LS_ALLOC) WITH KEY VBELN = LR_SLORD->VBELN
                                                       POSNR = LR_SLORD->POSNR BINARY SEARCH.
      IF SY-SUBRC IS INITIAL.
        LR_SLORD->ALCMN = LS_ALLOC-MENGE.
      ENDIF.
    ENDIF.

*// 기할당 조장 수.
    IF LR_SLORD->WELENG IS NOT INITIAL.
      LR_SLORD->ALCNT = ROUND( VAL  = ( LR_SLORD->ALCMN / LR_SLORD->WELENG )
                               DEC  = 0
                               MODE = CL_ABAP_MATH=>ROUND_UP ).
    ENDIF.

*// 판매오더 재고.
    READ TABLE LT_MSKA INTO DATA(LS_MSKA) WITH KEY VBELN = LR_SLORD->VBELN
                                                   POSNR = LR_SLORD->POSNR
                                                   MATNR = LR_SLORD->MATNR BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      LR_SLORD->KALAB = LS_MSKA-LABST1.
    ENDIF.

    CLEAR: LV_STAND_WECNT, LV_STOCK_WECNT.

    IF LR_SLORD->WELENG IS NOT INITIAL.
      READ TABLE LT_MCHB TRANSPORTING NO FIELDS WITH KEY WERKS = LR_SLORD->WERKS
                                                         LGORT = LR_SLORD->LGORT
                                                         MATNR = LR_SLORD->MATNR BINARY SEARCH.
      IF SY-SUBRC IS INITIAL.
        LOOP AT LT_MCHB INTO DATA(LS_MCHB)
                        FROM SY-TABIX.
          IF LS_MCHB-WERKS NE LR_SLORD->WERKS OR LS_MCHB-LGORT NE LR_SLORD->LGORT OR
             LS_MCHB-MATNR NE LR_SLORD->MATNR.
            EXIT.
          ENDIF.

          IF LR_SLORD->WELENG IS NOT INITIAL.
            IF LS_MCHB-LABST3 > 0.
              LV_STOCK_WECNT = LV_STOCK_WECNT + ROUND( VAL  = ( LS_MCHB-LABST3 / LR_SLORD->WELENG )
                                                       DEC  = 0
                                                       MODE = CL_ABAP_MATH=>ROUND_DOWN ).
            ENDIF.
          ENDIF.

          IF P_CUT EQ ABAP_TRUE.
            IF LS_MCHB-LABST3 EQ LR_SLORD->WELENG.
              LV_STAND_WECNT += 1.
            ENDIF.
          ELSE.
            IF LS_MCHB-WELENG IS NOT INITIAL.
              IF LS_MCHB-LABST3 > 0.
                LV_STAND_WECNT = LV_STAND_WECNT + ROUND( VAL  = ( LS_MCHB-LABST3 / LS_MCHB-WELENG )
                                                         DEC  = 0
                                                         MODE = CL_ABAP_MATH=>ROUND_UP ).
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

*// 재고부족 : 플랜트 6581, 배치관리 안하는 자재
    IF LR_SLORD->WERKS EQ '6581' AND LR_SLORD->XCHAR EQ SPACE.
      READ TABLE GT_LINK_STOCK INTO DATA(LS_LINK_STOCK) WITH KEY WERKS = LR_SLORD->WERKS
                                                                 LGORT = LR_SLORD->LGORT
                                                                 MATNR = LR_SLORD->MATNR.
      IF LR_SLORD->WEMENG LE LS_LINK_STOCK-LABST3.
        LR_SLORD->SHORTAGE = ICON_LED_GREEN.
      ELSE.
        LR_SLORD->SHORTAGE = ICON_LED_RED.
      ENDIF.
    ELSE.
*// 재고부족 : ( 납품조장수 - 기할당 조장수 ) > 재고 조장수.
      IF ( LR_SLORD->WECNT - LR_SLORD->ALCMN ) GT LV_STOCK_WECNT.
        LR_SLORD->SHORTAGE = ICON_LED_RED.
      ELSE.
        LR_SLORD->SHORTAGE = ICON_LED_GREEN.
      ENDIF.
    ENDIF.

*// 정조장 대응 가능.
    IF LR_SLORD->DPCBT EQ 'A'.
      LR_SLORD->STDLN = LR_SLORD->SHORTAGE.
    ELSE.
      IF LV_STAND_WECNT GE LR_SLORD->WECNT.
        LR_SLORD->STDLN = ICON_LED_GREEN.
      ELSE.
        LR_SLORD->STDLN = ICON_LED_RED.
      ENDIF.
    ENDIF.

  ENDLOOP.

  DELETE GT_SLORD WHERE ZASSIGN_TYPE IN VALUE TY_T_ZASSIGN_TYPE( SIGN = 'I' OPTION = 'NE' ( LOW = COND #( WHEN P_CUT   EQ ABAP_TRUE THEN ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-CT
                                                                                                          WHEN P_LANBX EQ ABAP_TRUE THEN ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-RW
                                                                                                          WHEN P_OPTIC EQ ABAP_TRUE THEN ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-OI
                                                                                                          WHEN P_EA    EQ ABAP_TRUE THEN ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-EA
                                                                                                          WHEN P_AD    EQ ABAP_TRUE THEN ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-AD ) ) ).

  IF P_G1 EQ 'X'.
    IF P_AD NE 'X'.
      LOOP AT GT_SLORD ASSIGNING FIELD-SYMBOL(<FS_S>).
        "413처리 수량을 기할당 수량에 추가
        SELECT SINGLE SUM( MENGE ) AS MENGE
          FROM MATDOC
         WHERE KDAUF EQ @<FS_S>-VBELN
           AND KDPOS EQ @<FS_S>-POSNR
           AND CANCELLED EQ @SPACE
           AND BWART EQ '413'
          INTO @DATA(LV_MENGE).

        <FS_S>-ALCMN = <FS_S>-ALCMN + LV_MENGE.

        "기할당 조장 수.
        IF <FS_S>-WELENG IS NOT INITIAL.
          <FS_S>-ALCNT = ROUND( VAL  = ( <FS_S>-ALCMN / <FS_S>-WELENG )
                                DEC  = 0
                                MODE = CL_ABAP_MATH=>ROUND_UP ).
        ENDIF.

        CLEAR: LV_MENGE.
        "납품수량 =< 기할당 재고가 큰 레코드 제외
        IF <FS_S>-WEMENG <= <FS_S>-ALCMN.
          <FS_S>-SEL = 'X'.
        ENDIF.
        "기할당 재고가 0인 레코드는 제외
        IF <FS_S>-ALCMN EQ 0.
          <FS_S>-SEL = 'X'.
        ENDIF.
      ENDLOOP.
      DELETE GT_SLORD WHERE SEL = 'X'.
    ENDIF.
  ENDIF.

  "출하요청일자
  SELECT A~VBELN, A~POSNR, B~DRDAT
    FROM ZLET0401 AS A
    JOIN ZLET0400 AS B ON B~DLVRQ EQ A~DLVRQ
     FOR ALL ENTRIES IN @GT_SLORD
   WHERE A~VBELN EQ @GT_SLORD-VBELN
     AND A~POSNR EQ @GT_SLORD-POSNR
     AND A~LVORM EQ @SPACE
    INTO TABLE @DATA(LT_ZLET0401).

  SORT LT_ZLET0401 BY VBELN POSNR.

  UNASSIGN <FS_S>.
  LOOP AT GT_SLORD ASSIGNING <FS_S>.
    READ TABLE LT_ZLET0401 INTO DATA(LS_0401) WITH KEY VBELN = <FS_S>-VBELN
                                                       POSNR = <FS_S>-POSNR.
    IF SY-SUBRC EQ 0.
      <FS_S>-DRDAT = LS_0401-DRDAT.
    ENDIF.

    "영업소
    IF <FS_S>-VKORG IS NOT INITIAL AND <FS_S>-VKGRP IS NOT INITIAL.
      CALL FUNCTION 'ZGTSD_GET_ZZYUSCD'
        EXPORTING
          I_VKORG   = <FS_S>-VKORG
          I_VKGRP   = <FS_S>-VKGRP
          I_KDKG4   = '00'
        IMPORTING
          E_ZZYUSCD = <FS_S>-ZZYUSCD.
    ENDIF.

    CLEAR: LS_0401.
  ENDLOOP.

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

      GR_SPLITTER_CONTAINER->SET_ROW_HEIGHT( ID = 1 HEIGHT = 50 ).

      GR_SPLITTER_CONTAINER->SET_ROW_SASH( ID    = 1
                                           TYPE  = CL_GUI_SPLITTER_CONTAINER=>TYPE_SASHVISIBLE
                                           VALUE = CL_GUI_SPLITTER_CONTAINER=>TRUE ).

      GR_SPLITTER_CONTAINER->SET_ROW_SASH( ID    = 1
                                           TYPE  = CL_GUI_SPLITTER_CONTAINER=>TYPE_MOVABLE
                                           VALUE = CL_GUI_SPLITTER_CONTAINER=>TRUE ).

      GR_TOP_CONTAINER = GR_SPLITTER_CONTAINER->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
      GR_BOTTOM_CONTAINER = GR_SPLITTER_CONTAINER->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

      IF P_WKORD EQ ABAP_TRUE.
        GR_SPLITTER_CONTAINER = NEW #( PARENT  = GR_BOTTOM_CONTAINER
                                       ROWS    = 1
                                       COLUMNS = 2 ).
        GR_SPLITTER_CONTAINER->SET_COLUMN_WIDTH( ID = 1 WIDTH = 50 ).
        GR_LEFT_CONTAINER  = GR_SPLITTER_CONTAINER->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
        GR_RIGHT_CONTAINER = GR_SPLITTER_CONTAINER->GET_CONTAINER( ROW = 1 COLUMN = 2 ).
      ENDIF.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      MESSAGE LR_ROOT->GET_TEXT( ) TYPE 'E'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_slord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_SLORD .

  LOOP AT GR_SLORD->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'SEL'.
        LR_FCAT->COLTEXT    = TEXT-F00.
        LR_FCAT->JUST       = 'C'.

      WHEN 'VBELN'.
        LR_FCAT->COLTEXT    = TEXT-F01.
        LR_FCAT->EMPHASIZE  = 'C110'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'POSNR'.
        LR_FCAT->COLTEXT    = TEXT-F02.
        LR_FCAT->EMPHASIZE  = 'C110'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F03.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F04.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'ZZSPEC_NO'.
        LR_FCAT->COLTEXT    = TEXT-F30.

      WHEN 'COLOR'.
        LR_FCAT->COLTEXT    = TEXT-F05.
        LR_FCAT->JUST       = 'C'.

      WHEN 'COLOR_DETAIL'.
        LR_FCAT->COLTEXT    = TEXT-FC3.
        LR_FCAT->JUST       = 'C'.

      WHEN 'COLOR_STRIPE'.
        LR_FCAT->COLTEXT    = TEXT-FC4.
        LR_FCAT->JUST       = 'C'.

      WHEN 'COLOR_STR_NO'.
        LR_FCAT->COLTEXT    = TEXT-FC5.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MTART'.
        LR_FCAT->COLTEXT    = TEXT-F24.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MATKL'.
        LR_FCAT->COLTEXT    = TEXT-F46.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ERDAT'.
        LR_FCAT->COLTEXT    = TEXT-F94.
        LR_FCAT->JUST       = 'C'.

      WHEN 'EDATU'.
        LR_FCAT->COLTEXT    = TEXT-F06.
        LR_FCAT->JUST       = 'C'.

      WHEN 'DRDAT'.
        LR_FCAT->COLTEXT    = TEXT-FD3.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ETENR'.
        LR_FCAT->COLTEXT    = TEXT-F07.
        LR_FCAT->JUST       = 'C'.

      WHEN 'SHORTAGE'.
        LR_FCAT->COLTEXT    = TEXT-F95.
        LR_FCAT->JUST       = 'C'.

      WHEN 'STDLN'.
        LR_FCAT->COLTEXT    = TEXT-F62.
        LR_FCAT->JUST       = 'C'.
        IF P_CUT NE 'X'.
          LR_FCAT->NO_OUT = 'X'.
        ENDIF.

      WHEN 'WEMENG'.
        LR_FCAT->COLTEXT    = TEXT-F08.
        LR_FCAT->EMPHASIZE  = 'C500'.
        IF P_AD EQ 'X'.
          LR_FCAT->EDIT       = ABAP_TRUE.
          CLEAR: LR_FCAT->EMPHASIZE.
        ENDIF.

      WHEN 'VRKME'.
        LR_FCAT->COLTEXT    = TEXT-F09.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'WELENG'.
        LR_FCAT->COLTEXT    = TEXT-F10.
        LR_FCAT->EMPHASIZE  = 'C500'.
        IF P_AD EQ 'X'.
          LR_FCAT->EDIT       = ABAP_TRUE.
          CLEAR: LR_FCAT->EMPHASIZE.
        ENDIF.

      WHEN 'WECNT'.
        LR_FCAT->COLTEXT    = TEXT-F11.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->JUST       = 'C'.
        IF P_AD EQ 'X'.
          LR_FCAT->EDIT       = ABAP_TRUE.
          CLEAR: LR_FCAT->EMPHASIZE.
        ENDIF.

      WHEN 'ALCMN'.
        LR_FCAT->COLTEXT    = TEXT-F12.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'ALCNT'.
        LR_FCAT->COLTEXT    = TEXT-F96.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'KALAB'.
        LR_FCAT->COLTEXT    = TEXT-F58.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'ZZCUT_REQ'.
        LR_FCAT->COLTEXT    = TEXT-F23.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->CHECKBOX   = ABAP_TRUE.

      WHEN 'KUNNR'.
        LR_FCAT->COLTEXT    = TEXT-F13.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'NAME1'.
        LR_FCAT->COLTEXT    = TEXT-F14.
        LR_FCAT->EMPHASIZE  = 'C700'.

*      WHEN 'VKORG'.
*        lr_fcat->coltext    = TEXT-f15.
*        lr_fcat->just       = 'C'.
*        lr_fcat->emphasize  = 'C700'.

      WHEN 'ZZYUSCD'.
        LR_FCAT->COLTEXT    = TEXT-FD7.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'VTWEG'.
        LR_FCAT->COLTEXT    = TEXT-F16.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'SPART'.
        LR_FCAT->COLTEXT    = TEXT-F17.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'VKGRP'.
        LR_FCAT->COLTEXT    = TEXT-F18.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'VKBUR'.
        LR_FCAT->COLTEXT    = TEXT-F19.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'SKID_YN'.
        LR_FCAT->COLTEXT    = TEXT-F36.

      WHEN 'DRUM_GUBUN'.
        LR_FCAT->COLTEXT    = TEXT-F37.

      WHEN 'PACKAGE'.
        LR_FCAT->COLTEXT    = TEXT-F38.

      WHEN 'FLANGE_PROT'.
        LR_FCAT->COLTEXT    = TEXT-F39.

      WHEN 'PRINT'.
        LR_FCAT->COLTEXT    = TEXT-F40.

      WHEN 'NEW_DRUM'.
        LR_FCAT->COLTEXT    = TEXT-F97.
        LR_FCAT->JUST       = 'C'.

      WHEN 'WRAP_PACKING'.
        LR_FCAT->COLTEXT    = TEXT-F98.
        LR_FCAT->JUST       = 'C'.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_STOCK .

  LOOP AT GR_STOCK->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-F20.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->HOTSPOT    = ABAP_TRUE.

      WHEN 'LGORT'.
        LR_FCAT->COLTEXT    = TEXT-F21.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'LGOBE'.
        LR_FCAT->COLTEXT    = TEXT-F22.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F03.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F04.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'CHARG'.
        LR_FCAT->COLTEXT    = TEXT-F25.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'LWEDT'.
        LR_FCAT->COLTEXT    = TEXT-F61.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'LABST1'.
        LR_FCAT->COLTEXT    = TEXT-F26.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->DO_SUM     = ABAP_TRUE.

      WHEN 'LABST2'.
        LR_FCAT->COLTEXT    = TEXT-F27.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->DO_SUM     = ABAP_TRUE.

      WHEN 'LABST3'.
        LR_FCAT->COLTEXT    = TEXT-F28.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->DO_SUM     = ABAP_TRUE.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F29.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'WELENG'.
        LR_FCAT->COLTEXT    = TEXT-F35.

      WHEN 'WECNT'.
        LR_FCAT->COLTEXT    = TEXT-F11.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'ZCUT_YN'.
        LR_FCAT->COLTEXT    = TEXT-F31.
        LR_FCAT->EDIT       = ABAP_TRUE.    "2026.07.04  임시 추가 PYS
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZCUT_CNT'.
        LR_FCAT->COLTEXT    = TEXT-F32.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'ZREW_YN'.
        LR_FCAT->COLTEXT    = TEXT-F33.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->JUST       = 'C'.

*      WHEN 'ZEXCLUDE'.
*        LR_FCAT->COLTEXT    = TEXT-F34.
*        LR_FCAT->EDIT       = ABAP_TRUE.
*        LR_FCAT->CHECKBOX   = ABAP_TRUE.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_wkord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_WKORD .

  LOOP AT GR_WKORD->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-F20.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->HOTSPOT    = ABAP_TRUE.

      WHEN 'ZCUT_ORD_NO'.
        LR_FCAT->COLTEXT    = TEXT-F43.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZCUT_ORD_ITEM'.
        LR_FCAT->COLTEXT    = TEXT-F44.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZORD_TYPE_TXT'.
        LR_FCAT->COLTEXT    = TEXT-F45.

      WHEN 'ZCUT_STATUS'.
        LR_FCAT->COLTEXT    = TEXT-F41.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->HOTSPOT    = ABAP_TRUE.

      WHEN 'MESSAGE'.
        LR_FCAT->COLTEXT    = TEXT-F42.

      WHEN 'VBELN'.
        LR_FCAT->COLTEXT    = TEXT-F01.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'POSNR'.
        LR_FCAT->COLTEXT    = TEXT-F02.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F48.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F49.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'F_CHARG'.
        LR_FCAT->COLTEXT    = TEXT-F50.

      WHEN 'LABST3'.
        LR_FCAT->COLTEXT    = TEXT-F51.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'ZCUT_LEN'.
        LR_FCAT->COLTEXT    = TEXT-F52.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F53.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZCUT_YN'.
        LR_FCAT->COLTEXT    = TEXT-F54.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZREW_YN'.
        LR_FCAT->COLTEXT    = TEXT-F55.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZEXCLUDE'.
        LR_FCAT->COLTEXT    = TEXT-F56.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->CHECKBOX   = ABAP_TRUE.

*      WHEN 'T_CHARG'.
*        LR_FCAT->COLTEXT    = TEXT-F57.
*        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'ZCUT_CNT'.
        LR_FCAT->COLTEXT    = TEXT-F32.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'DRMAT'.
        LR_FCAT->COLTEXT    = TEXT-F59.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->F4AVAILABL = ABAP_TRUE.
        LR_FCAT->REF_FIELD  = SPACE.
        LR_FCAT->REF_TABLE  = SPACE.

      WHEN 'DRTXT'.
        LR_FCAT->COLTEXT    = TEXT-F60.

      WHEN 'LGORT'.
        LR_FCAT->COLTEXT    = TEXT-F21.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->CHECKTABLE = SPACE.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MULTI_YN'.
        LR_FCAT->COLTEXT    = TEXT-FD2.
        LR_FCAT->JUST       = 'C'.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_slord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_IN_SLORD .

  TRY.
      GR_SLORD->MS_LAYOUT-GRID_TITLE = |{ TEXT-T02 }: { GV_TPAR2+3 }   { TEXT-F99 }: { GS_T001W-WERKS } { GS_T001W-NAME1 }   { TEXT-002 }: { GS_T001L-LGORT } { GS_T001L-LGOBE }|.
      GR_SLORD->MS_LAYOUT-COL_OPT = ABAP_FALSE.

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_IN_STOCK .

  TRY.
      GR_STOCK->MS_LAYOUT-NO_ROWINS  = ABAP_TRUE.
      GR_STOCK->MS_LAYOUT-TOTALS_BEF = ABAP_TRUE.
      GR_STOCK->MS_LAYOUT-GRID_TITLE = CL_ABAP_CONV_IN_CE=>UCCP( '00A0' ).

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_wkord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_IN_WKORD .

  TRY.
      GR_WKORD->MS_LAYOUT-NO_ROWINS  = ABAP_TRUE.
      GR_WKORD->MS_LAYOUT-GRID_TITLE = CL_ABAP_CONV_IN_CE=>UCCP( '00A0' ).

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click_in_slord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK_IN_SLORD USING PS_ROW    TYPE LVC_S_ROID
                                 PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LR_SLORD) = REF #( GT_SLORD[ PS_ROW-ROW_ID ] OPTIONAL ).

      IF LR_SLORD IS INITIAL.
        RETURN.
      ENDIF.

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  PERFORM FIELD_SEL_HOTSPOT_CLICK USING LR_SLORD->*.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_material_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MATERIAL_STOCK .

  CLEAR: GT_LINK_DETAIL, GT_LINK_STOCK.

  CALL FUNCTION 'ZGTPP_GET_STOCK_LINK_INFO'
    EXPORTING
      I_WERKS        = P_WERKS
      I_LGORT        = P_LGORT
      IT_MATNR       = GT_MATNR
    TABLES
      OT_LINK_DETAIL = GT_LINK_DETAIL
      OT_LINK_STOCK  = GT_LINK_STOCK.

  SORT GT_LINK_STOCK BY STOCK_TABLE WERKS LGORT MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING PR_SENDER
                                 PS_ROW    TYPE LVC_S_ROID
                                 PS_COLUMN TYPE LVC_S_COL.

  IF GR_SLORD IS BOUND AND PR_SENDER EQ GR_SLORD->MR_GRID.
    PERFORM HOTSPOT_CLICK_IN_SLORD USING PS_ROW PS_COLUMN.
  ENDIF.

  IF GR_STOCK IS BOUND AND PR_SENDER EQ GR_STOCK->MR_GRID.
    PERFORM HOTSPOT_CLICK_IN_STOCK USING PS_ROW PS_COLUMN.
  ENDIF.

  IF GR_WKORD IS BOUND AND PR_SENDER EQ GR_WKORD->MR_GRID.
    PERFORM HOTSPOT_CLICK_IN_WKORD USING PS_ROW PS_COLUMN.
  ENDIF.

  IF GR_CUTTING IS BOUND AND PR_SENDER EQ GR_CUTTING->MR_GRID.
    PERFORM HOTSPOT_CLICK_IN_CUTTTING USING PS_ROW PS_COLUMN.
  ENDIF.

  IF GR_ALLOC IS BOUND AND PR_SENDER EQ GR_ALLOC->MR_GRID.
    PERFORM HOTSPOT_CLICK_IN_ALLOC USING PS_ROW PS_COLUMN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click_in_slord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK_IN_SLORD  USING PS_ROW    TYPE LVC_S_ROID
                                   PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LR_SLORD) = REF #( GT_SLORD[ PS_ROW-ROW_ID ] OPTIONAL ).

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'SEL'. "// 선택.
      PERFORM FIELD_SEL_HOTSPOT_CLICK USING LR_SLORD->*.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_stock_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BUILD_STOCK_LIST  USING PS_SLORD TYPE TY_S_SLORD.

  DATA: LV_INDEX TYPE I.
  DATA: LV_TABIX1 TYPE SY-TABIX.

  MODIFY GT_SLORD FROM VALUE #( SEL = SPACE ) TRANSPORTING SEL
                  WHERE SEL NE SPACE.

  PS_SLORD-SEL = ICON_LED_GREEN.

  GT_MATNR = VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = PS_SLORD-MATNR ) ).

  PERFORM GET_MATERIAL_STOCK.
  PERFORM GET_MAT_BATCH_CLASS USING PS_SLORD.

  CLEAR GT_STOCK.

  SORT GT_LINK_STOCK BY WERKS LGORT MATNR.

  READ TABLE GT_LINK_STOCK TRANSPORTING NO FIELDS WITH KEY WERKS = PS_SLORD-WERKS
                                                           LGORT = PS_SLORD-LGORT
                                                           MATNR = PS_SLORD-MATNR BINARY SEARCH.
  IF SY-SUBRC IS INITIAL.
    DATA(LV_TABIX) = SY-TABIX.
    DATA(LV_STOCK_GUID) = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC( ).

    LOOP AT GT_LINK_STOCK INTO DATA(LS_LINK_STOCK)
                          FROM LV_TABIX.
      IF LS_LINK_STOCK-WERKS NE PS_SLORD-WERKS OR
         LS_LINK_STOCK-LGORT NE PS_SLORD-LGORT OR
         LS_LINK_STOCK-MATNR NE PS_SLORD-MATNR.
        EXIT.
      ENDIF.

*// 재고리스트에서 제외로 처리.
      IF ( LS_LINK_STOCK-STOCK_TABLE EQ ZGTPP_IF_CONST=>GC_STOCK_TABLE-MSKA ) OR "// 1) 재고유형 = MSKA.
         ( LS_LINK_STOCK-LABST3 LE 0 )                                        OR "// 2) 미할당수량 <= 0 .
         ( LS_LINK_STOCK-LABST3 LT PS_SLORD-WELENG ).                            "// 3) 미할당수량 < 오더 조장 .
        CONTINUE.
      ENDIF.

*// 랜 박스류 OR 광 옥내 인 경우 상단 ALV의 "조장"과 하단 좌측 ALV의 "조장"이 서로 같은 레코드만 화면 출력.
      IF ( P_LANBX EQ ABAP_TRUE OR P_OPTIC EQ ABAP_TRUE OR ( P_CUT EQ ABAP_TRUE AND PS_SLORD-DPCBT EQ 'A' ) )
     AND ( LS_LINK_STOCK-WELENG NE PS_SLORD-WELENG ).
        CONTINUE.
      ENDIF.

*// DPCBP = 'C' 인 경우, 추출한 배치번호 기준으로 절단지시여부를 확인 후
*// 절단 자재문서가 있으면서 절단 자재문서가 없는 건이 있다면 해당 배치는 제외
      IF PS_SLORD-DPCBT EQ 'C'.
        "배치번호(계획) 기준으로 점검
        SELECT DISTINCT
*               A~ZASSIGN_NO, B~ZASSIGN_ITEM, A~WERKS, A~MATNR,
*               B~LGORT,
               B~F_CHARG,
               C~ZCUT_ORD_NO, C~ZCUT_ORD_ITEM, C~ZCUT_MBLNR, C~ZCUT_MJAHR
          FROM ZGTPPT2170 AS A
          JOIN ZGTPPT2180 AS B ON B~ZASSIGN_NO EQ A~ZASSIGN_NO
          JOIN ZGTPPT2190 AS C ON C~ZASSIGN_NO EQ B~ZASSIGN_NO
                              AND C~ZASSIGN_ITEM EQ B~ZASSIGN_ITEM
         WHERE B~F_CHARG EQ @LS_LINK_STOCK-CHARG
           AND C~LOEKZ EQ @SPACE
           AND C~SOBKZ EQ 'E'
*           AND A~LOEKZ EQ @SPACE
          INTO TABLE @DATA(LT_CUT_MBLNR).

        "추출한 데이터 모두 절단자재문서 존재하는지 체크
        IF LINE_EXISTS( LT_CUT_MBLNR[ ZCUT_MBLNR = SPACE ] ).
          DATA(LV_MBLNR_CHK) = 'X'.
        ENDIF.

        IF LV_MBLNR_CHK IS INITIAL.
          "절단자재문서가 있는 레코드는 실제 절단된 배치번호 추출
          LOOP AT LT_CUT_MBLNR INTO DATA(LS_M).
            CLEAR: LV_TABIX1.
            LV_TABIX1 = SY-TABIX.

            SELECT SINGLE CHARG
              FROM MATDOC
             WHERE MBLNR EQ @LS_M-ZCUT_MBLNR
               AND MJAHR EQ @LS_M-ZCUT_MJAHR
               AND SHKZG EQ 'H'
              INTO @DATA(LV_CHARG).

            IF LV_CHARG NE LS_M-F_CHARG.
              DELETE LT_CUT_MBLNR INDEX LV_TABIX1.
            ENDIF.
            CLEAR: LV_CHARG.
          ENDLOOP.

          CLEAR: LV_INDEX.
          LV_INDEX = LINES( LT_CUT_MBLNR ) .

          IF LV_INDEX > 1.
            SORT LT_CUT_MBLNR BY ZCUT_MBLNR.
            "절단 자재문서가 1건이라도 있는지 체크
            LOOP AT LT_CUT_MBLNR INTO DATA(LS_CMBLNR) WHERE ZCUT_MBLNR NE SPACE.
              DATA(LV_C) = 'X'.
              EXIT.
            ENDLOOP.

            IF LV_C EQ 'X'.
              CLEAR: LS_CMBLNR.
              "절단 자재문서가 1건이라도 없는지 체크
              READ TABLE LT_CUT_MBLNR INTO LS_CMBLNR WITH KEY ZCUT_MBLNR = SPACE.
              IF SY-SUBRC EQ 0.
                DATA(LV_CHK) = 'X'.
              ENDIF.
              CLEAR: LV_C.
            ENDIF.
          ENDIF.

          IF LV_CHK EQ 'X'.
            CLEAR: LV_CHK.
            CONTINUE.
          ENDIF.
        ENDIF.

        CLEAR: LV_MBLNR_CHK.
      ENDIF.

      APPEND INITIAL LINE TO GT_STOCK REFERENCE INTO DATA(LR_STOCK).

      LR_STOCK->* = VALUE #( BASE CORRESPONDING #( LS_LINK_STOCK ) MAKTX       = PS_SLORD-MAKTX
                                                                   LGOBE       = GS_T001L-LGOBE
                                                                   LABST2_ORGN = LR_STOCK->LABST2
                                                                   LABST3      = ( LR_STOCK->LABST1 - LR_STOCK->LABST2 ) "// 미할당 수량.
                                                                   ZCUT_YN     = COND #( WHEN P_CUT EQ ABAP_TRUE AND LR_STOCK->LABST3 > PS_SLORD-WELENG THEN ZGTPP_IF_CONST=>GC_YN-YES
                                                                                         WHEN P_AD  EQ ABAP_TRUE AND LR_STOCK->LABST3 > PS_SLORD-WELENG THEN ZGTPP_IF_CONST=>GC_YN-YES
                                                                                                                                                        ELSE SPACE )
                                                                   ZREW_YN     = COND #( WHEN PS_SLORD-WERKS EQ GC_WERKS-6500 THEN LR_STOCK->ZCUT_YN
                                                                                                                              ELSE SPACE )
                                                                   STOCK_GUID = LV_STOCK_GUID ).
      IF P_CUT EQ ABAP_TRUE OR P_AD EQ ABAP_TRUE.
        IF PS_SLORD-DPCBT EQ 'A'.
          LR_STOCK->ZCUT_YN = SPACE.
          LR_STOCK->ZREW_YN = SPACE.
        ENDIF.
      ENDIF.

      PERFORM SET_ORDER_ATTRIBUTE USING LR_STOCK->*.

      IF LR_STOCK->ZORD_TYPE EQ ZGTPP_IF_CONST=>GC_ZORD_TYPE-C5. "// EA단위 품목.
        LR_STOCK->WELENG = LR_STOCK->LABST1.
        LR_STOCK->WECNT  = 1.
      ELSE.
        IF LR_STOCK->WELENG IS NOT INITIAL.
          LR_STOCK->WECNT = ROUND( VAL  = ( LR_STOCK->LABST3 / LR_STOCK->WELENG )
                                   DEC  = 0
                                   MODE = CL_ABAP_MATH=>ROUND_UP ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT GT_STOCK BY LGORT MATNR LWEDT CHARG.

  GS_SLORD = PS_SLORD.

  GR_STOCK->MS_LAYOUT-GRID_TITLE = |{ TEXT-F10 }: { GS_SLORD-WELENG } { GS_SLORD-VRKME }, { TEXT-F11 }: { GS_SLORD-WECNT - GS_SLORD-ALCNT }|.
  GR_STOCK->MR_GRID->SET_FRONTEND_LAYOUT( GR_STOCK->MS_LAYOUT ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mat_batch_attr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MAT_BATCH_ATTR  USING  PS_STOCK TYPE TY_S_STOCK.
  DATA LT_ALLOCVALUESNUM  TYPE TABLE OF BAPI1003_ALLOC_VALUES_NUM.
  DATA LT_ALLOCVALUESCHAR	TYPE TABLE OF	BAPI1003_ALLOC_VALUES_CHAR.
  DATA LT_ALLOCVALUESCURR	TYPE TABLE OF	BAPI1003_ALLOC_VALUES_CURR.
  DATA LT_RETURN          TYPE TABLE OF BAPIRET2.
  DATA LV_VALUE TYPE CHA_CLASS_VIEW-SOLLWERT .

  CLEAR: PS_STOCK-WELENG, PS_STOCK-WECNT.

  READ TABLE GT_KLAH INTO DATA(LS_KLAH) WITH KEY MATNR = PS_STOCK-MATNR
                                                 CHARG = PS_STOCK-CHARG BINARY SEARCH.

  CHECK SY-SUBRC IS INITIAL.

  CALL FUNCTION 'BAPI_OBJCL_GETDETAIL'
    EXPORTING
      OBJECTKEY       = CONV OBJNUM( PS_STOCK-MATNR && PS_STOCK-CHARG )
      OBJECTTABLE     = 'MCH1'
      CLASSNUM        = LS_KLAH-CLASS
      CLASSTYPE       = '023'
    TABLES
      ALLOCVALUESNUM  = LT_ALLOCVALUESNUM
      ALLOCVALUESCHAR = LT_ALLOCVALUESCHAR
      ALLOCVALUESCURR = LT_ALLOCVALUESCURR
      RETURN          = LT_RETURN.

  DATA(LS_ALLOCVALUESNUM) = VALUE #( LT_ALLOCVALUESNUM[ CHARACT = ZGTPP_IF_CONST=>GC_ATNAM-SAP_MILLCA_LENGTH ] OPTIONAL ).

  CALL FUNCTION 'QSS0_FLTP_TO_CHAR_CONVERSION'
    EXPORTING
      I_NUMBER_OF_DIGITS = 10
      I_FLTP_VALUE       = LS_ALLOCVALUESNUM-VALUE_FROM
    IMPORTING
      E_CHAR_FIELD       = LV_VALUE.

  PS_STOCK-WELENG = LV_VALUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAT_BATCH_CLASS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MAT_BATCH_CLASS USING PS_SLORD TYPE TY_S_SLORD.

  SELECT MCH1~MATNR, MCH1~CHARG, KLAH~CLASS
    FROM @GT_LINK_STOCK AS A
    JOIN MCH1
      ON A~MATNR EQ MCH1~MATNR
     AND A~CHARG EQ MCH1~CHARG
    JOIN KSSK
      ON MCH1~CUOBJ_BM EQ KSSK~OBJEK
    JOIN KLAH
      ON KSSK~CLINT EQ KLAH~CLINT
   WHERE A~WERKS EQ @PS_SLORD-WERKS
     AND A~LGORT EQ @PS_SLORD-LGORT
     AND A~MATNR EQ @PS_SLORD-MATNR
   ORDER BY MCH1~MATNR, MCH1~CHARG
    INTO TABLE @GT_KLAH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR  USING PR_SENDER
                           PR_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  IF GR_SLORD IS BOUND AND PR_SENDER EQ GR_SLORD->MR_GRID.
    PERFORM SET_TOOLBAR_IN_SLORD USING PR_OBJECT.
  ENDIF.

  IF GR_STOCK IS BOUND AND PR_SENDER EQ GR_STOCK->MR_GRID.
    PERFORM SET_TOOLBAR_IN_STOCK USING PR_OBJECT.
  ENDIF.

  IF GR_WKORD IS BOUND AND PR_SENDER EQ GR_WKORD->MR_GRID.
    PERFORM SET_TOOLBAR_IN_WKORD USING PR_OBJECT.
  ENDIF.

  IF GR_CUTTING IS BOUND AND PR_SENDER EQ GR_CUTTING->MR_GRID.
    PERFORM SET_TOOLBAR_IN_CUTTING USING PR_OBJECT.
  ENDIF.

  IF GR_ALLOC IS BOUND AND PR_SENDER EQ GR_ALLOC->MR_GRID.
    PERFORM SET_TOOLBAR_IN_ALLOC USING PR_OBJECT.
  ENDIF.

  IF GR_TABMT IS BOUND AND PR_SENDER EQ GR_TABMT->MR_GRID.
    PERFORM SET_TOOLBAR_IN_TABMT USING PR_OBJECT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar_in_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR_IN_STOCK  USING PR_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.
  DATA LV_DISABLED TYPE ABAP_BOOL.

  IF GT_STOCK IS INITIAL.
    LV_DISABLED = ABAP_TRUE .
  ELSE.
    READ TABLE GT_WKORD TRANSPORTING NO FIELDS WITH TABLE KEY SKEY2
                                                   COMPONENTS STOCK_GUID = VALUE #( GT_STOCK[ 1 ]-STOCK_GUID OPTIONAL ).
    IF SY-SUBRC IS INITIAL.
      LV_DISABLED = ABAP_TRUE .
    ENDIF.
  ENDIF.

  DATA(LV_NBSP) = CL_ABAP_CONV_IN_CE=>UCCP( '00A0' ).

  IF P_CUT EQ 'X'.
    PR_OBJECT->MT_TOOLBAR = VALUE #( BASE PR_OBJECT->MT_TOOLBAR
                                    ( BUTN_TYPE = 3 )
                                    ( FUNCTION  = GC_FCODE-SEL_STOCK
                                      ICON      = ICON_DISPLAY_MORE
                                      DISABLED  = LV_DISABLED
                                      TEXT      = |{ TEXT-B01 } { LV_NBSP } { LV_NBSP }|
                                      QUICKINFO = |{ TEXT-B01 } { LV_NBSP } { LV_NBSP }| )
                                    ( FUNCTION  = GC_FCODE-SEL_STD_LEN
                                      ICON      = ICON_DISPLAY_MORE
                                      DISABLED  = LV_DISABLED
                                      TEXT      = |{ TEXT-B07 } { LV_NBSP } { LV_NBSP }|
                                      QUICKINFO = |{ TEXT-B07 } { LV_NBSP } { LV_NBSP }| ) ).
  ELSE.
    PR_OBJECT->MT_TOOLBAR = VALUE #( BASE PR_OBJECT->MT_TOOLBAR
                                    ( BUTN_TYPE = 3 )
                                    ( FUNCTION  = GC_FCODE-SEL_STOCK
                                      ICON      = ICON_DISPLAY_MORE
                                      DISABLED  = LV_DISABLED
                                      TEXT      = |{ TEXT-B01 } { LV_NBSP } { LV_NBSP }|
                                      QUICKINFO = |{ TEXT-B01 } { LV_NBSP } { LV_NBSP }| ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND  USING PR_SENDER PV_UCOMM.

  IF GR_SLORD IS BOUND AND PR_SENDER EQ GR_SLORD->MR_GRID.
    PERFORM USER_COMMAND_IN_SLORD USING PV_UCOMM.
  ENDIF.

  IF GR_STOCK IS BOUND AND PR_SENDER EQ GR_STOCK->MR_GRID.
    PERFORM USER_COMMAND_IN_STOCK USING PV_UCOMM.
  ENDIF.

  IF GR_WKORD IS BOUND AND PR_SENDER EQ GR_WKORD->MR_GRID.
    PERFORM USER_COMMAND_IN_WKORD USING PV_UCOMM.
  ENDIF.

  IF GR_CUTTING IS BOUND AND PR_SENDER EQ GR_CUTTING->MR_GRID.
    PERFORM USER_COMMAND_IN_CUTTING USING PV_UCOMM.
  ENDIF.

  IF GR_ALLOC IS BOUND AND PR_SENDER EQ GR_ALLOC->MR_GRID.
    PERFORM USER_COMMAND_IN_ALLOC USING PV_UCOMM.
  ENDIF.

  IF GR_TABMT IS BOUND AND PR_SENDER EQ GR_TABMT->MR_GRID.
    PERFORM USER_COMMAND_IN_TABMT USING PV_UCOMM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_IN_STOCK  USING  PV_UCOMM.

  CASE PV_UCOMM.
    WHEN GC_FCODE-SEL_STOCK.   "// 재고 선택.
      PERFORM USER_COMMAND_SEL_STOCK.

    WHEN GC_FCODE-SEL_STD_LEN. "// 재고 자동 선택(정조장).
      PERFORM USER_COMMAND_SEL_STD_LEN.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_sel_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_SEL_STOCK .

  CHECK GT_STOCK[] IS NOT INITIAL.

  TRY.
      PERFORM CHECK_BEFORE_SEL_STOCK. "// 사전점검.
      PERFORM RUN_SELECT_STOCK.       "// 재고 선택.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_sel_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_SEL_STOCK RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  GR_STOCK->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  IF LINE_EXISTS( GT_STOCK[ STATUS = ICON_LED_RED ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E23.
  ENDIF.

  SELECT SUM( A~ZCUT_CNT ) FROM @GT_STOCK AS A INTO @DATA(LV_SUM).

  IF LV_SUM IS INITIAL OR LV_SUM GT ( GS_SLORD-WECNT - GS_SLORD-ALCNT ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E22.
  ENDIF.

  DATA(LT_STOCK) = GT_STOCK.
  DELETE LT_STOCK WHERE ZCUT_CNT IS INITIAL.

  IF LINE_EXISTS( LT_STOCK[ ZEXCLUDE = ABAP_TRUE  ] ) AND
     LINE_EXISTS( LT_STOCK[ ZEXCLUDE = ABAP_FALSE ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E27.
  ENDIF.

  READ TABLE GT_WKORD INTO DATA(LS_WKORD) WITH KEY ZCUT_STATUS = ICON_LED_INACTIVE.
  IF SY-SUBRC EQ 0.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E33.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C03 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form run_select_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM RUN_SELECT_STOCK .
  DATA LT_CONFG TYPE TY_T_CONFG.

  DATA(LR_SLORD) = REF #( GT_SLORD[ KEY SKEY1 VBELN = GS_SLORD-VBELN
                                              POSNR = GS_SLORD-POSNR ] OPTIONAL ).

  LOOP AT GT_STOCK REFERENCE INTO DATA(LR_STOCK)
                   WHERE ZCUT_CNT GT 0
                     AND STATUS   NE ICON_LED_RED.
    LR_STOCK->GUID = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC( ).

*    PERFORM GET_VC_CONFIGURATION USING LR_SLORD->CUOBF LT_CONFG.
    PERFORM GET_CLASSIFICATION USING LR_SLORD->MATNR.

    DO LR_STOCK->ZCUT_CNT TIMES.
      APPEND INITIAL LINE TO GT_WKORD REFERENCE INTO DATA(LR_WKORD).
      LR_WKORD->* = VALUE #( BASE CORRESPONDING #( LR_STOCK->* )  ZCUT_STATUS = ICON_LED_INACTIVE
                                                                  VBELN       = COND #( WHEN LR_STOCK->ZEXCLUDE EQ ABAP_FALSE THEN LR_SLORD->VBELN )
                                                                  POSNR       = COND #( WHEN LR_STOCK->ZEXCLUDE EQ ABAP_FALSE THEN LR_SLORD->POSNR )
                                                                  REF_VBELN   = LR_SLORD->VBELN
                                                                  REF_POSNR   = LR_SLORD->POSNR
                                                                  F_CHARG     = LR_STOCK->CHARG
                                                                  ZCUT_LEN    = LR_SLORD->WELENG
                                                                  ZCUT_CNT    = 1
                                                                  LGORT       = SPACE ).

      PERFORM SET_DRUM_DEFAULT_VALUE USING LR_SLORD->* LR_WKORD->* LT_CONFG.
      PERFORM FIELD_VALID_CHECK_IN_WKORD USING LR_WKORD->*.

*// 기할당 수량.
      LR_SLORD->ALCMN += ( LR_WKORD->ZCUT_LEN * LR_WKORD->ZCUT_CNT ).
      LR_SLORD->ALCNT += LR_WKORD->ZCUT_CNT.

      "다중할당여부
      SELECT SINGLE B~MANDT
        FROM ZGTPPT2170 AS A
        JOIN ZGTPPT2180 AS B ON B~ZASSIGN_NO = A~ZASSIGN_NO
       WHERE B~F_CHARG EQ @LR_STOCK->CHARG
         AND A~LOEKZ NE 'X'
        INTO @DATA(LV_MANDT).

      IF SY-SUBRC EQ 0.
        LR_WKORD->MULTI_YN = 'Y'.
      ENDIF.
    ENDDO.

    IF LR_STOCK->LABST3 IS NOT INITIAL.
      APPEND INITIAL LINE TO GT_WKORD REFERENCE INTO LR_WKORD.
      LR_WKORD->* = VALUE #( BASE CORRESPONDING #( LR_STOCK->* )  ZCUT_STATUS = ICON_LED_INACTIVE
                                                                  VBELN       = SPACE
                                                                  POSNR       = SPACE
                                                                  REF_VBELN   = LR_SLORD->VBELN
                                                                  REF_POSNR   = LR_SLORD->POSNR
                                                                  F_CHARG     = LR_STOCK->CHARG
                                                                  ZCUT_LEN    = LR_STOCK->LABST3
                                                                  ZCUT_CNT    = 1
                                                                  LGORT       = SPACE ).

      "재권취 제어 : 절단 & 판매오더 없음
      IF LR_WKORD->ZORD_TYPE EQ 'C1' AND LR_WKORD->VBELN IS INITIAL.
        CLEAR: LR_WKORD->ZREW_YN.
      ENDIF.

      PERFORM SET_DRUM_DEFAULT_VALUE USING LR_SLORD->* LR_WKORD->* LT_CONFG.
      PERFORM FIELD_VALID_CHECK_IN_WKORD USING LR_WKORD->*.

      "다중할당여부
      CLEAR: LV_MANDT.
      SELECT SINGLE B~MANDT
        FROM ZGTPPT2170 AS A
        JOIN ZGTPPT2180 AS B ON B~ZASSIGN_NO = A~ZASSIGN_NO
       WHERE B~F_CHARG EQ @LR_STOCK->CHARG
         AND A~LOEKZ NE 'X'
        INTO @LV_MANDT.

      IF SY-SUBRC EQ 0.
        LR_WKORD->MULTI_YN = 'Y'.
      ENDIF.
    ENDIF.

    APPEND LR_STOCK->* TO LR_SLORD->STOCK.

  ENDLOOP.

  "배치별 순번 지정
  DATA: LV_CHARG     TYPE CHARG_D,
        LV_BATCH_IDX TYPE I.

  CLEAR: GT_ORG_LEN.
  LOOP AT GT_WKORD ASSIGNING FIELD-SYMBOL(<FS_W>).
    IF <FS_W>-F_CHARG IS NOT INITIAL.
      IF LV_CHARG NE <FS_W>-F_CHARG.
        LV_BATCH_IDX = '1'.
        <FS_W>-BATCH_IDX = LV_BATCH_IDX.
        LV_CHARG = <FS_W>-F_CHARG.
      ELSE.
        LV_BATCH_IDX += 1.
        <FS_W>-BATCH_IDX = LV_BATCH_IDX.
      ENDIF.

      GS_ORG_LEN-F_CHARG = <FS_W>-F_CHARG.
      COLLECT GS_ORG_LEN INTO GT_ORG_LEN.
    ENDIF.
    CLEAR: GS_ORG_LEN.
  ENDLOOP.

  "배치별 원조장 초기값 추출
  SORT GT_ORG_LEN BY F_CHARG.
  LOOP AT GT_ORG_LEN ASSIGNING FIELD-SYMBOL(<FS_O>).
    "배치번호 기준 기존 절단지시 정보 추출
    SELECT C~ZCUT_ORD_NO, C~ZCUT_ORD_ITEM, C~ZASSIGN_NO, C~ZASSIGN_ITEM,
           C~ZCUT_LEN, C~ZCUT_CNT, C~ZCUT_YN, C~SOBKZ, C~ORG_LENGTH,
           B~LABST1
      FROM ZGTPPT2170 AS A
      JOIN ZGTPPT2180 AS B ON B~ZASSIGN_NO EQ A~ZASSIGN_NO
      JOIN ZGTPPT2190 AS C ON C~ZASSIGN_NO EQ B~ZASSIGN_NO
                          AND C~ZASSIGN_ITEM EQ B~ZASSIGN_ITEM
     WHERE B~F_CHARG EQ @<FS_O>-F_CHARG
       AND A~LOEKZ EQ @SPACE
       AND C~LOEKZ NE 'X'
       AND C~SOBKZ EQ 'E'
      INTO TABLE @DATA(LT_W_JOJANG).

    SORT LT_W_JOJANG BY ORG_LENGTH.
    DELETE LT_W_JOJANG WHERE ORG_LENGTH = 0.

    READ TABLE GT_WKORD INTO DATA(LS_W) WITH KEY F_CHARG = <FS_O>-F_CHARG.
    READ TABLE GT_STOCK INTO DATA(LS_S) WITH KEY GUID = LS_W-GUID.

    IF LT_W_JOJANG[] IS INITIAL.
      <FS_O>-ORG_LENGTH = LS_S-LABST1.
    ELSE.
      READ TABLE LT_W_JOJANG INTO DATA(LS_J) INDEX 1.
      IF LS_J-ORG_LENGTH EQ SPACE.
        <FS_O>-ORG_LENGTH = LS_S-LABST1.
      ELSE.
        <FS_O>-ORG_LENGTH = LS_J-ORG_LENGTH - LS_J-ZCUT_LEN.
        <FS_O>-DB_CHK = 'X'.
      ENDIF.
    ENDIF.

    CLEAR: LS_W, LS_S, LS_J.
  ENDLOOP.

  GR_WKORD->MR_GRID->GET_FRONTEND_FIELDCATALOG( IMPORTING ET_FIELDCATALOG = DATA(LT_FCAT) ).

  SELECT SINGLE @ABAP_TRUE
    FROM @GT_WKORD AS ZT01
   WHERE ZORD_TYPE IN ( @ZGTPP_IF_CONST=>GC_ZORD_TYPE-C2,  "// 랜 박스류.
                        @ZGTPP_IF_CONST=>GC_ZORD_TYPE-C3,  "// 광 옥내.
                        @ZGTPP_IF_CONST=>GC_ZORD_TYPE-C5,  "// EA단위 품목.
                        @ZGTPP_IF_CONST=>GC_ZORD_TYPE-C9 ) "// 재고 비활성.
    INTO @DATA(LV_TECH).

  MODIFY LT_FCAT FROM VALUE #( TECH = LV_TECH )
                 TRANSPORTING TECH
                 WHERE FIELDNAME EQ 'DRMAT'
                    OR FIELDNAME EQ 'DRTXT'
                    OR FIELDNAME EQ 'LGORT'.

  GR_WKORD->MR_GRID->SET_FRONTEND_FIELDCATALOG( LT_FCAT ).

  GR_SLORD->REFRESH( ).
  GR_STOCK->REFRESH( ).
  GR_WKORD->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar_in_WKORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR_IN_WKORD  USING PR_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  DATA(LV_DISABLED) = COND #( WHEN GT_WKORD IS INITIAL THEN ABAP_TRUE ).

  DATA(LV_NBSP) = CL_ABAP_CONV_IN_CE=>UCCP( '00A0' ).

  PR_OBJECT->MT_TOOLBAR = VALUE #( BASE PR_OBJECT->MT_TOOLBAR
                                    ( BUTN_TYPE = 3 )
                                    ( FUNCTION  = GC_FCODE-WKORD
                                      ICON      = ICON_BUSINAV_PROCESSMATRIX
                                      DISABLED  = LV_DISABLED
                                      TEXT      = |{ TEXT-B02 } { LV_NBSP } { LV_NBSP } { LV_NBSP }|
                                      QUICKINFO = |{ TEXT-B02 } { LV_NBSP } { LV_NBSP } { LV_NBSP }| )
                                    ( FUNCTION  = GC_FCODE-SEL_STOCK_CNC
                                      ICON      = ICON_SYSTEM_DESELECT
                                      DISABLED  = LV_DISABLED
                                      TEXT      = |{ TEXT-B06 } { LV_NBSP } { LV_NBSP } { LV_NBSP }|
                                      QUICKINFO = |{ TEXT-B06 } { LV_NBSP } { LV_NBSP } { LV_NBSP }| ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_wkord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_IN_WKORD  USING  PV_UCOMM.

  CASE PV_UCOMM.
    WHEN GC_FCODE-WKORD.          "// 주문 할당 & 절단 지시.
      PERFORM USER_COMMAND_WKORD.

    WHEN GC_FCODE-SEL_STOCK_CNC.  "// 재고 선택 취소.
      PERFORM USER_COMMAND_SEL_STOCK_CNC.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_WKORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_WKORD .

  TRY.
      PERFORM CHECK_BEFORE_WORK_ORDER. "// 사전점검.
      PERFORM RUN_WORK_ORDER.          "// 주문 할당 및 절단 지시

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_work_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_WORK_ORDER RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.
  DATA LV_STIME TYPE TIMESTAMP.

  CLEAR GS_RESULT.

  GR_WKORD->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  IF LINE_EXISTS( GT_WKORD[ STATUS = ICON_LED_RED ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E23.
  ENDIF.

  IF NOT LINE_EXISTS( GT_WKORD[ ZASSIGN_NO = SPACE ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E26.
  ENDIF.

  IF LINE_EXISTS( GT_WKORD[ ZEXCLUDE = ABAP_TRUE  ] ) AND
     LINE_EXISTS( GT_WKORD[ ZEXCLUDE = ABAP_FALSE ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E27.
  ENDIF.

  LOOP AT GT_WKORD INTO DATA(LS_WK) WHERE ZCUT_STATUS EQ ICON_LED_INACTIVE.
    SELECT SINGLE F_CHARG, CRDAT, CRTIM, CRNAM
      FROM ZGTPPT2180
     WHERE F_CHARG EQ @LS_WK-F_CHARG
      INTO @DATA(LS_2180).

    CLEAR: LV_STIME.
    LV_STIME = LS_2180-CRDAT && LS_2180-CRTIM.

    "프로그램 실행 시간보다 이후에 데이터가 있으면 오류
    IF SY-UNAME NE LS_2180-CRNAM.
      IF LV_STIME > GV_STIME.
        RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E34.
      ENDIF.
    ENDIF.

    "지시유형이 C1(절단)인 경우
    IF LS_WK-ZORD_TYPE EQ 'C1'.
      "해당 배치로 정조장 주문할당 존재 여부 체크
      SELECT SINGLE A~ZASSIGN_NO
        FROM ZGTPPT2170 AS A
        JOIN ZGTPPT2180 AS B ON B~ZASSIGN_NO EQ A~ZASSIGN_NO
       WHERE A~LOEKZ EQ @SPACE
         AND B~F_CHARG EQ @LS_WK-F_CHARG
         AND B~ZORD_TYPE EQ 'C0'
        INTO @DATA(LV_ZASSIGN_NO).

      "해당 배치(F_CHARG)로 지시유형 C0(정조장)의 주문할당이 존재하면 오류
      IF LV_ZASSIGN_NO IS NOT INITIAL.
        "배치번호(&1)에 `정조장` 주문할당이 존재하여 지시가 불가합니다.
        RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E045 WITH LS_WK-F_CHARG.
      ENDIF.
    ENDIF.
  ENDLOOP.

  PERFORM CONFIRMATION_POPUP USING TEXT-C04 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form run_work_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM RUN_WORK_ORDER RAISING LCX_EXCEPTION.
  DATA LT_ZGTPPT2170 TYPE TABLE OF ZGTPPT2170.
  DATA LT_ZGTPPT2180 TYPE TABLE OF ZGTPPT2180.
  DATA LT_ZGTPPT2190 TYPE TABLE OF ZGTPPT2190.
  DATA LT_ZGTPPT2191 TYPE TABLE OF ZGTPPT2191.

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

*// 주문 할당 및 절단 지시
  PERFORM SAVE_ALLOCATION_CUTTING_ORDER TABLES LT_ZGTPPT2170 LT_ZGTPPT2180
                                               LT_ZGTPPT2190 LT_ZGTPPT2191.

*// 정조장 생산오더 전송.
  PERFORM SUBMIT_ZGTPPI2010.

*// 절단오더 정보 송신.
  "난척발생분추가 전송
  IF P_AD EQ 'X'.
    PERFORM SUBMIT_ZGTPPI2030 TABLES LT_ZGTPPT2170.
  ELSE.
    "군포공장(65*)은 절단오더 정보 송신을 "자동"이 아닌 T-CODE: ZGTPPI2030를 통해 "수동"으로 진행함
    IF P_WERKS+0(2) NE '65'.
      PERFORM SUBMIT_ZGTPPI2030 TABLES LT_ZGTPPT2170.
    ENDIF.
  ENDIF.

  GR_STOCK->MS_LAYOUT-GRID_TITLE = |{ TEXT-F10 }: { GS_SLORD-WELENG } { GS_SLORD-VRKME }, { TEXT-F11 }: { GS_SLORD-WECNT - GS_SLORD-ALCNT }|.
  GR_STOCK->MR_GRID->SET_FRONTEND_LAYOUT( GR_STOCK->MS_LAYOUT ).

  GR_SLORD->REFRESH( ).
  GR_STOCK->REFRESH( ).
  GR_WKORD->REFRESH( ).

  MESSAGE S009 WITH GS_RESULT-TOTAL GS_RESULT-SUCCESS GS_RESULT-ERROR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_master_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MASTER_DATA .

  SELECT SINGLE WERKS, NAME1
    INTO CORRESPONDING FIELDS OF @GS_T001W
    FROM T001W
   WHERE WERKS EQ @P_WERKS.

  SELECT WERKS, LGORT, LGOBE
    INTO CORRESPONDING FIELDS OF TABLE @GT_T001L
    FROM T001L
   WHERE WERKS EQ @P_WERKS.

  READ TABLE GT_T001L INTO GS_T001L WITH TABLE KEY WERKS = P_WERKS
                                                   LGORT = P_LGORT.

  SELECT WERKS, FROM_DRUM, TO_DRUM
    FROM ZGTPPT2420
    INTO CORRESPONDING FIELDS OF TABLE @GT_ZGTPPT2420
   WHERE WERKS EQ @P_WERKS
   ORDER BY WERKS, FROM_DRUM, TO_DRUM.

  SELECT WERKS, MATNR, F_LENGTH, T_LENGTH, DRUMNR
    FROM ZGTPPT2430
    INTO CORRESPONDING FIELDS OF TABLE @GT_ZGTPPT2430
   WHERE WERKS EQ @P_WERKS
   ORDER BY WERKS, MATNR, F_LENGTH, T_LENGTH, DRUMNR.

  CALL FUNCTION 'DDIF_DOMA_GET'
    EXPORTING
      NAME          = 'ZGTDZORD_TYPE'
      LANGU         = SY-LANGU
    TABLES
      DD07V_TAB     = GT_DD07V
    EXCEPTIONS
      ILLEGAL_INPUT = 1
      OTHERS        = 2.

  CLEAR: GV_STIME.
  GV_STIME = SY-DATLO && SY-TIMLO.

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

  DATA: LV_NR TYPE INRI-NRRANGENR.

  CLEAR: LV_NR.
  IF P_AD EQ 'X'.
    LV_NR = '02'.
  ELSE.
    LV_NR = '01'.
  ENDIF.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = LV_NR
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form Save_Allocation_Cutting_Order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_ALLOCATION_CUTTING_ORDER  TABLES PT_ZGTPPT2170 STRUCTURE ZGTPPT2170
                                           PT_ZGTPPT2180 STRUCTURE ZGTPPT2180
                                           PT_ZGTPPT2190 STRUCTURE ZGTPPT2190
                                           PT_ZGTPPT2191 STRUCTURE ZGTPPT2191.
  DATA LV_ZCUT_ORD_NO   TYPE ZGTPPT2190-ZCUT_ORD_NO.
  DATA LV_ZCUT_ORD_ITEM TYPE ZGTPPT2190-ZCUT_ORD_ITEM.
  DATA LV_POSNR TYPE ZGTPPT2191-POSNR.

  CLEAR GT_FXLEN.

  LOOP AT GT_WKORD  INTO DATA(LS_KEY)
                   WHERE ZASSIGN_NO EQ SPACE
                   GROUP BY ( REF_VBELN = LS_KEY-REF_VBELN
                              REF_POSNR = LS_KEY-REF_POSNR )
                   INTO DATA(LT_GROUP).
    GS_RESULT-TOTAL += 1.

    DATA(LR_SLORD) = REF #( GT_SLORD[ KEY SKEY1 VBELN = LT_GROUP-REF_VBELN
                                                POSNR = LT_GROUP-REF_POSNR ] OPTIONAL ).

**// 판매오더품목 납품보류 업데이트.
*    IF P_AD NE 'X'.
*      PERFORM UNSET_SALES_ORDER_DLV_BLOCK USING LR_SLORD->*.
*    ENDIF.

*    IF LR_SLORD->ZUPT_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    CLEAR: LV_ZCUT_ORD_NO, LV_ZCUT_ORD_ITEM, LV_POSNR.

*// 주문할당.
    PERFORM SET_ALLC_HEADER_DETAIL TABLES PT_ZGTPPT2170 PT_ZGTPPT2180
                                    USING LR_SLORD->*.

*// 절단지시.
    CLEAR: GV_CUT_ITEM, GV_ASS_ITEM.
    LOOP AT GROUP LT_GROUP REFERENCE INTO DATA(LR_WKORD).
      PERFORM SET_CUTTING_DATA  TABLES PT_ZGTPPT2190 PT_ZGTPPT2191
                                 USING LR_SLORD->*   LR_WKORD->* LV_ZCUT_ORD_NO LV_ZCUT_ORD_ITEM LV_POSNR.
    ENDLOOP.

    GS_RESULT-SUCCESS += 1.


*// 판매오더품목 납품보류 업데이트.
    IF P_AD NE 'X'.
      PERFORM UNSET_SALES_ORDER_DLV_BLOCK TABLES PT_ZGTPPT2170
                                          USING LR_SLORD->*.
    ELSE.
      LR_SLORD->ZUPT_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
      LR_SLORD->ZUPT_MSG  = '성공'. "LV_MESSAGE.

      LOOP AT PT_ZGTPPT2170 REFERENCE INTO DATA(LR_ZGTPPT2170) WHERE VBELN EQ LR_SLORD->VBELN
                                                                 AND POSNR EQ LR_SLORD->POSNR.

        LR_ZGTPPT2170->* = VALUE #( BASE LR_ZGTPPT2170->*  ZUPT_STAT = LR_SLORD->ZUPT_STAT
                                                           ZUPT_MSG  = LR_SLORD->ZUPT_MSG ).

      ENDLOOP.
    ENDIF.

*    ELSE.
*      GS_RESULT-ERROR += 1.
*    ENDIF.
  ENDLOOP.

  IF PT_ZGTPPT2170[] IS NOT INITIAL.
    MODIFY ZGTPPT2170 FROM TABLE PT_ZGTPPT2170[].
    MODIFY ZGTPPT2180 FROM TABLE PT_ZGTPPT2180[].

    IF PT_ZGTPPT2190[] IS NOT INITIAL.
      MODIFY ZGTPPT2190 FROM TABLE PT_ZGTPPT2190[].
    ENDIF.

    IF PT_ZGTPPT2191[] IS NOT INITIAL.
      MODIFY ZGTPPT2191 FROM TABLE PT_ZGTPPT2191[].
    ENDIF.

    COMMIT WORK AND WAIT.
  ENDIF.

  IF GS_RESULT-SUCCESS > 0.
    PERFORM BUILD_STOCK_LIST USING LR_SLORD->*.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form submit_zgtppi2030
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SUBMIT_ZGTPPI2030  TABLES PT_ZGTPPT2170 STRUCTURE ZGTPPT2170.

  ZGTPP_CL_COMMON=>SUBMIT_ZGTPPI2030( IV_WERKS      = P_WERKS
                                      IT_ZASSIGN_NO = VALUE #( FOR LS_ZGTPPT2170 IN PT_ZGTPPT2170[] WHERE ( ZUPT_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS )
                                                               ( SIGN = 'I' OPTION = 'EQ' LOW = LS_ZGTPPT2170-ZASSIGN_NO ) ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form unset_sales_order_dlv_block
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UNSET_SALES_ORDER_DLV_BLOCK TABLES PT_ZGTPPT2170 STRUCTURE ZGTPPT2170
                                  USING PS_SLORD TYPE TY_S_SLORD.
  DATA: BEGIN OF LS_WKORD,
          VBELN     LIKE ZGTPPT2170-VBELN,
          POSNR     LIKE ZGTPPT2170-POSNR,
          ZORD_TYPE LIKE ZGTPPT2180-ZORD_TYPE,
        END OF LS_WKORD.
  DATA: LT_WKORD LIKE TABLE OF LS_WKORD.

  DATA: LS_SELTAB TYPE RSPARAMS,
        LT_SELTAB TYPE TABLE OF RSPARAMS.

  DATA : LV_JOBNAME  LIKE TBTCJOB-JOBNAME VALUE 'ZGTPPR2160_SUBMIT_ZGTPPR2360',
         LV_JOBCOUNT LIKE TBTCJOB-JOBCOUNT,
         LV_RELEASED LIKE BTCH0000-CHAR1.

  DATA LV_TYPE    TYPE BAPI_MTYPE.
  DATA LV_MESSAGE TYPE BAPI_MSG.
  DATA LV_MVGR3   TYPE MVGR3.
  DATA: LV_C0(1), LV_NC0(1).

  IF LINE_EXISTS( GT_WKORD[ REF_VBELN = PS_SLORD-VBELN
                            REF_POSNR = PS_SLORD-POSNR
                            ZEXCLUDE  = ABAP_TRUE ] ).
    PS_SLORD-ZUPT_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    RETURN.
  ENDIF.

*// 납품일정라인.
  SELECT SINGLE LIFSP
    INTO @DATA(LV_LIFSP)
    FROM VBEP
   WHERE VBELN EQ @PS_SLORD-VBELN
     AND POSNR EQ @PS_SLORD-POSNR
     AND ETENR EQ @PS_SLORD-ETENR.

*  IF LV_LIFSP EQ SPACE.
*    PS_SLORD-ZUPT_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
*    PS_SLORD-ZUPT_MSG  = TEXT-S03.
*
*    LOOP AT PT_ZGTPPT2170 REFERENCE INTO DATA(LR_ZGTPPT2170) WHERE VBELN EQ PS_SLORD-VBELN
*                                                               AND POSNR EQ PS_SLORD-POSNR.
*
*      LR_ZGTPPT2170->* = VALUE #( BASE LR_ZGTPPT2170->*  ZUPT_STAT = PS_SLORD-ZUPT_STAT
*                                                         ZUPT_MSG  = PS_SLORD-ZUPT_MSG ).
*
*    ENDLOOP.
*  ELSE.
*    IF PS_SLORD-WEMENG <= PS_SLORD-ALCMN.
  "지시유형에 따른 자재가격결정그룹 지정
  "DB에 저장된 데이터 추출
  CLEAR: LT_WKORD.
  SELECT A~VBELN, A~POSNR,
         B~ZORD_TYPE
    FROM ZGTPPT2170 AS A
    JOIN ZGTPPT2180 AS B ON B~ZASSIGN_NO EQ A~ZASSIGN_NO
   WHERE A~VBELN EQ @PS_SLORD-VBELN
     AND A~POSNR EQ @PS_SLORD-POSNR
     AND A~LOEKZ NE 'X'
    INTO CORRESPONDING FIELDS OF TABLE @LT_WKORD.

  "ALV 데이터를 합침
  LOOP AT GT_WKORD INTO DATA(LS_WKORD1) WHERE REF_VBELN EQ PS_SLORD-VBELN
                                          AND REF_POSNR EQ PS_SLORD-POSNR.
    MOVE: LS_WKORD1-REF_VBELN TO LS_WKORD-VBELN,
          LS_WKORD1-REF_POSNR TO LS_WKORD-POSNR,
          LS_WKORD1-ZORD_TYPE TO LS_WKORD-ZORD_TYPE.

    APPEND LS_WKORD TO LT_WKORD.
    CLEAR: LS_WKORD.
  ENDLOOP.

  SORT LT_WKORD BY VBELN POSNR.

  "모두 정조장 = 'X' / 부분 정조장 = 'Y' / 그외 SPACE
  CLEAR: LV_C0, LV_NC0, LS_WKORD.
  LOOP AT LT_WKORD INTO LS_WKORD WHERE VBELN EQ PS_SLORD-VBELN
                                   AND POSNR EQ PS_SLORD-POSNR.
    IF LS_WKORD-ZORD_TYPE EQ ZGTPP_IF_CONST=>GC_ZORD_TYPE-C0.
      LV_C0 = 'X'.
    ELSE.
      LV_NC0 = 'X'.
    ENDIF.
  ENDLOOP.

  CLEAR: LV_MVGR3.
  IF LV_C0 EQ 'X'.
    IF LV_NC0 EQ 'X'.
      LV_MVGR3 = 'Y'.
    ELSE.
      LV_MVGR3 = 'X'.
    ENDIF.
  ENDIF.

  "FIXMG 설정값 추출
  SELECT SINGLE FIXMG
    FROM VBAP
   WHERE VBELN EQ @PS_SLORD-VBELN
     AND POSNR EQ @PS_SLORD-POSNR
    INTO @DATA(LV_FIXMG).

*    CALL FUNCTION 'ZGTSD_RECEIVE_STOCK_LINK_INFO'
*      EXPORTING
*        I_VBELN = PS_SLORD-VBELN
*        I_POSNR = PS_SLORD-POSNR
**       I_MVGR3 = COND MVGR3( WHEN LINE_EXISTS( GT_WKORD[ ZORD_TYPE = ZGTPP_IF_CONST=>GC_ZORD_TYPE-C0 ] ) THEN ABAP_TRUE
**                                                                                                            ELSE ABAP_FALSE )
*        I_MVGR3 = LV_MVGR3
*        I_LIFSP = CONV LIFSP( ABAP_FALSE )
*        I_FIXMG = 'X' "LV_FIXMG      "SM구분자
*      IMPORTING
*        E_TYPE  = LV_TYPE
*        E_MSG   = LV_MESSAGE.

  CLEAR: LV_JOBCOUNT.
  DO.
    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        JOBNAME          = LV_JOBNAME
      IMPORTING
        JOBCOUNT         = LV_JOBCOUNT
      EXCEPTIONS
        CANT_CREATE_JOB  = 1
        INVALID_JOB_DATA = 2
        JOBNAME_MISSING  = 3
        OTHERS           = 4.
    IF SY-SUBRC EQ 0.
      EXIT.
    ENDIF.
  ENDDO.

  READ TABLE PS_SLORD-STOCK REFERENCE INTO DATA(LR_STOCK) INDEX 1.

  CLEAR: LT_SELTAB.
  LT_SELTAB = VALUE #(
  ( SELNAME = 'P_ONLINE' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = SPACE )
  ( SELNAME = 'P_BATCH'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = 'X' )
  ( SELNAME = 'P_PROC'   KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = 'X' )
  ( SELNAME = 'P_WERKS'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = P_WERKS )
  ( SELNAME = 'P_ASSIGN' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = LR_STOCK->ZASSIGN_NO )
  ( SELNAME = 'P_VBELN'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = PS_SLORD-VBELN )
  ( SELNAME = 'P_POSNR'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = PS_SLORD-POSNR )
  ( SELNAME = 'P_MVGR3'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = LV_MVGR3 )
  ( SELNAME = 'P_LIFSP'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = SPACE )
  ( SELNAME = 'P_FIXMG'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = 'X' ) ).

  SUBMIT ZGTPPR2360 VIA JOB LV_JOBNAME
                    NUMBER LV_JOBCOUNT
                    WITH SELECTION-TABLE LT_SELTAB
                    AND RETURN.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      JOBCOUNT             = LV_JOBCOUNT
      JOBNAME              = LV_JOBNAME
      STRTIMMED            = 'X'  "즉시 기동
    IMPORTING
      JOB_WAS_RELEASED     = LV_RELEASED
    EXCEPTIONS
      CANT_START_IMMEDIATE = 1
      INVALID_STARTDATE    = 2
      JOBNAME_MISSING      = 3
      JOB_CLOSE_FAILED     = 4
      JOB_NOSTEPS          = 5
      JOB_NOTEX            = 6
      LOCK_FAILED          = 7
      OTHERS               = 8.

*    ELSE.
*      LV_TYPE = 'S'.
*      LV_MESSAGE = '성공'.
*    ENDIF.

*    IF LV_TYPE NE ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
*      MODIFY GT_WKORD FROM VALUE #( ZCUT_STATUS = ICON_LED_RED
*                                    RETURN      = VALUE #( ( TYPE = 'E' FIELD = TEXT-F01 MESSAGE = LV_MESSAGE ) ) )
*                      USING KEY SKEY1
*                      TRANSPORTING ZCUT_STATUS RETURN
*                      WHERE REF_VBELN EQ PS_SLORD-VBELN
*                        AND REF_POSNR EQ PS_SLORD-POSNR.
*    ELSE.
  PS_SLORD-ZUPT_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
  PS_SLORD-ZUPT_MSG  = '성공'. "LV_MESSAGE.

  LOOP AT PT_ZGTPPT2170 REFERENCE INTO DATA(LR_ZGTPPT2170) WHERE VBELN EQ PS_SLORD-VBELN
                                                             AND POSNR EQ PS_SLORD-POSNR.

    LR_ZGTPPT2170->* = VALUE #( BASE LR_ZGTPPT2170->*  ZUPT_STAT = PS_SLORD-ZUPT_STAT
                                                       ZUPT_MSG  = PS_SLORD-ZUPT_MSG ).

  ENDLOOP.
*    ENDIF.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_cutting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_CUTTING.

  LOOP AT GR_CUTTING->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-F20.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->HOTSPOT    = ABAP_TRUE.

      WHEN 'ZCUT_ORD_NO'.
        LR_FCAT->COLTEXT    = TEXT-F43.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'ZCUT_ORD_ITEM'.
        LR_FCAT->COLTEXT    = TEXT-F44.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

*      WHEN 'ZORD_TYPE_TXT'.
*        LR_FCAT->COLTEXT    = TEXT-F63.
*        LR_FCAT->JUST       = 'C'.

      WHEN 'LOEKZ'.
        LR_FCAT->COLTEXT    = TEXT-FC9.
        LR_FCAT->JUST       = 'C'.

      WHEN 'PRINT_STAT_TXT'.
        LR_FCAT->COLTEXT    = TEXT-FC8.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZGR_STAT'.
        LR_FCAT->COLTEXT    = TEXT-F64.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZASSIGN_NO'.
        LR_FCAT->COLTEXT    = TEXT-F65.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C300'.

      WHEN 'ZASSIGN_ITEM'.
        LR_FCAT->COLTEXT    = TEXT-F66.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C300'.

      WHEN 'VBELN'.
        LR_FCAT->COLTEXT    = TEXT-F67.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'POSNR'.
        LR_FCAT->COLTEXT    = TEXT-F68.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'SHREQ'.
        LR_FCAT->COLTEXT    = TEXT-FA9.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F69.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F70.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'F_CHARG'.
        LR_FCAT->COLTEXT    = TEXT-F50.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'LABST1'.
        LR_FCAT->COLTEXT    = TEXT-F72.

      WHEN 'LABST2'.
        LR_FCAT->COLTEXT    = TEXT-F73.

      WHEN 'LABST3'.
        LR_FCAT->COLTEXT    = TEXT-F74.

      WHEN 'ZCUT_LEN'.
        LR_FCAT->COLTEXT    = TEXT-F75.

      WHEN 'VRKME'.
        LR_FCAT->COLTEXT    = TEXT-F76.
        LR_FCAT->JUST       = 'C'.

*      WHEN 'T_CHARG'.
*        LR_FCAT->COLTEXT    = TEXT-F77.

      WHEN 'ZCUT_CNT'.
        LR_FCAT->COLTEXT    = TEXT-F78.

      WHEN 'ZCUT_MBLNR'.
        LR_FCAT->COLTEXT    = TEXT-F79.

      WHEN 'A_CHARG'.
        LR_FCAT->COLTEXT    = TEXT-FD5.

      WHEN 'ZCUT_BUDAT'.
        LR_FCAT->COLTEXT    = TEXT-FD6.

      WHEN 'ZCUT_RLEN'.
        LR_FCAT->COLTEXT    = TEXT-FC6.

      WHEN 'ZCUT_SCRAP'.
        LR_FCAT->COLTEXT    = TEXT-FD1.

      WHEN 'ZCUT_LEN_STAT'.
        LR_FCAT->COLTEXT    = TEXT-FC7.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ORG_LENGTH'.
        LR_FCAT->COLTEXT    = TEXT-FD4.

      WHEN 'ZDR_MATN'.
        LR_FCAT->COLTEXT    = TEXT-F80.

      WHEN 'ZDR_MAKX'.
        LR_FCAT->COLTEXT    = TEXT-F81.

      WHEN 'ZDR_MBLNR'.
        LR_FCAT->COLTEXT    = TEXT-F82.

      WHEN 'ZDR_MBLNR'.
        LR_FCAT->COLTEXT    = TEXT-F82.

      WHEN 'SOBKZ'.
        LR_FCAT->COLTEXT    = TEXT-F90.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'MULTI_YN'.
        LR_FCAT->COLTEXT    = TEXT-FD2.
        LR_FCAT->JUST       = 'C'.

      WHEN 'CRDAT'.
        LR_FCAT->COLTEXT    = TEXT-F83.
        LR_FCAT->JUST       = 'C'.

      WHEN 'CRTIM'.
        LR_FCAT->COLTEXT    = TEXT-F84.
        LR_FCAT->JUST       = 'C'.

      WHEN 'CRNAM'.
        LR_FCAT->COLTEXT    = TEXT-F85.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZSTAT'.
        LR_FCAT->COLTEXT    = TEXT-F86.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZMESSAGE'.
        LR_FCAT->COLTEXT    = TEXT-F87.

      WHEN 'ZUPT_STAT'.
        LR_FCAT->COLTEXT    = TEXT-F88.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZUPT_MSG'.
        LR_FCAT->COLTEXT    = TEXT-F89.

      WHEN 'F_CHARG_ORG'.
        LR_FCAT->COLTEXT    = TEXT-FD8.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_alloc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_ALLOC .

  LOOP AT GR_ALLOC->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-F20.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->HOTSPOT    = ABAP_TRUE.

      WHEN 'ZSTAT'.
        LR_FCAT->COLTEXT    = TEXT-F91.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZASSIGN_TYPE'.
        LR_FCAT->COLTEXT    = TEXT-F92.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZTYPE_DESC'.
        LR_FCAT->COLTEXT    = TEXT-F93.

      WHEN 'ZASSIGN_NO'.
        LR_FCAT->COLTEXT    = TEXT-F65.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C300'.

      WHEN 'ZASSIGN_ITEM'.
        LR_FCAT->COLTEXT    = TEXT-F66.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C300'.

      WHEN 'LOEKZ'.
        LR_FCAT->COLTEXT    = TEXT-FC9.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZORD_TYPE_TXT'.
        LR_FCAT->COLTEXT    = TEXT-F63.
        LR_FCAT->JUST       = 'C'.

      WHEN 'VBELN'.
        LR_FCAT->COLTEXT    = TEXT-F01.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'POSNR'.
        LR_FCAT->COLTEXT    = TEXT-F02.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C110'.

*      WHEN 'ETENR'.
*        LR_FCAT->COLTEXT    = TEXT-F07.
*        LR_FCAT->JUST       = 'C'.
*        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'SHREQ'.
        LR_FCAT->COLTEXT    = TEXT-FA9.
        LR_FCAT->JUST       = 'C'.
*        lr_fcat->emphasize  = 'C110'.

      WHEN 'EDATU'.
        LR_FCAT->COLTEXT    = TEXT-F06.
        LR_FCAT->JUST       = 'C'.

      WHEN 'DRDAT'.
        LR_FCAT->COLTEXT    = TEXT-FD3.
        LR_FCAT->JUST       = 'C'.

      WHEN 'WEMENG'.
        LR_FCAT->COLTEXT    = TEXT-F08.

      WHEN 'VRKME'.
        LR_FCAT->COLTEXT    = TEXT-F09.
        LR_FCAT->JUST       = 'C'.

      WHEN 'WELENG'.
        LR_FCAT->COLTEXT    = TEXT-F10.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'WECNT'.
        LR_FCAT->COLTEXT    = TEXT-F11.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F03.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F04.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'ZZSPEC_NO'.
        LR_FCAT->COLTEXT    = TEXT-F30.

      WHEN 'LGORT'.
        LR_FCAT->COLTEXT    = TEXT-F21.

      WHEN 'LGOBE'.
        LR_FCAT->COLTEXT    = TEXT-F22.

      WHEN 'F_CHARG'.
        LR_FCAT->COLTEXT    = TEXT-F50.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'LABST3'.
        LR_FCAT->COLTEXT    = TEXT-F28.
        LR_FCAT->TECH       = ABAP_TRUE.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F29.
        LR_FCAT->JUST       = 'C'.

      WHEN 'WECNT'.
        LR_FCAT->COLTEXT    = TEXT-F11.

      WHEN 'ZCUT_YN'.
        LR_FCAT->COLTEXT    = TEXT-F31.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZCUT_CNT'.
        LR_FCAT->COLTEXT    = TEXT-F32.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'ZREW_YN'.
        LR_FCAT->COLTEXT    = TEXT-F33.
        LR_FCAT->JUST       = 'C'.

*      WHEN 'ZEXCLUDE'.
*        LR_FCAT->COLTEXT    = TEXT-F34.
*        LR_FCAT->CHECKBOX   = ABAP_TRUE.

*      WHEN 'Z413'.
*        LR_FCAT->COLTEXT    = TEXT-F47.
*        LR_FCAT->JUST       = 'C'.

      WHEN 'F_CHARG_ORG'.
        LR_FCAT->COLTEXT    = TEXT-FD8.

      WHEN 'CRDAT'.
        LR_FCAT->COLTEXT    = TEXT-F83.
        LR_FCAT->JUST       = 'C'.

      WHEN 'CRTIM'.
        LR_FCAT->COLTEXT    = TEXT-F84.
        LR_FCAT->JUST       = 'C'.

      WHEN 'CRNAM'.
        LR_FCAT->COLTEXT    = TEXT-F85.
        LR_FCAT->JUST       = 'C'.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar_in_cutting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR_IN_CUTTING  USING PR_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  DATA(LV_DISABLED) = COND #( WHEN GT_CUTTING IS INITIAL THEN ABAP_TRUE ).

  DATA(LV_NBSP) = CL_ABAP_CONV_IN_CE=>UCCP( '00A0' ).

  IF P_CNCEL EQ 'X'.
    PR_OBJECT->MT_TOOLBAR = VALUE #( BASE PR_OBJECT->MT_TOOLBAR
                                    ( BUTN_TYPE = 3 )
                                    ( FUNCTION  = GC_FCODE-UNDO
                                      ICON      = ICON_SYSTEM_UNDO
                                      DISABLED  = LV_DISABLED
                                      TEXT      = |{ TEXT-B03 } { LV_NBSP } { LV_NBSP } { LV_NBSP }|
                                      QUICKINFO = |{ TEXT-B03 } { LV_NBSP } { LV_NBSP } { LV_NBSP }| )
                                    ( FUNCTION  = GC_FCODE-RESEND
                                      ICON      = ICON_TRANSFER
                                      DISABLED  = LV_DISABLED
                                      TEXT      = |{ TEXT-B04 } { LV_NBSP } { LV_NBSP } { LV_NBSP }|
                                      QUICKINFO = |{ TEXT-B04 } { LV_NBSP } { LV_NBSP } { LV_NBSP }| ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_cutting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_IN_CUTTING.

  TRY.
      GR_CUTTING->MS_LAYOUT-GRID_TITLE = |{ TEXT-F99 }: { GS_T001W-WERKS } { GS_T001W-NAME1 }|.
      GR_CUTTING->MS_LAYOUT-NO_ROWINS = ABAP_TRUE.

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_alloc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_IN_ALLOC .

  TRY.
      GR_ALLOC->MS_LAYOUT-GRID_TITLE = |{ TEXT-F99 }: { GS_T001W-WERKS } { GS_T001W-NAME1 }|.
      GR_ALLOC->MS_LAYOUT-NO_ROWINS = ABAP_TRUE.

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar_in_alloc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR_IN_ALLOC  USING PR_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  DATA(LV_DISABLED) = COND #( WHEN GT_ALLOC IS INITIAL THEN ABAP_TRUE ).
  DATA(LV_NBSP) = CL_ABAP_CONV_IN_CE=>UCCP( '00A0' ).

  IF P_CNCEL EQ 'X'.
    PR_OBJECT->MT_TOOLBAR = VALUE #( BASE PR_OBJECT->MT_TOOLBAR
                                    ( BUTN_TYPE = 3 )
                                    ( FUNCTION  = GC_FCODE-CANCEL_ALLOC
                                      ICON      = ICON_SYSTEM_UNDO
                                      DISABLED  = LV_DISABLED
                                      TEXT      = |{ TEXT-B05 } { LV_NBSP } { LV_NBSP } { LV_NBSP }|
                                      QUICKINFO = |{ TEXT-B05 } { LV_NBSP } { LV_NBSP } { LV_NBSP }| ) ).
  ENDIF.

  IF SY-TCODE EQ GC_TCODE-ZGTPPR2169.
    IF P_RESLT EQ 'X'.
      PR_OBJECT->MT_TOOLBAR = VALUE #( BASE PR_OBJECT->MT_TOOLBAR
                                      ( BUTN_TYPE = 3 )
                                      ( FUNCTION  = GC_FCODE-XC_UPD
                                        ICON      = ICON_MODIFIED_OBJECT
                                        DISABLED  = LV_DISABLED
                                        TEXT      = |{ '삭제/완료 업데이트' } { LV_NBSP } { LV_NBSP } { LV_NBSP }|
                                        QUICKINFO = |{ '삭제/완료 업데이트' } { LV_NBSP } { LV_NBSP } { LV_NBSP }| ) ).
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_cutting_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_CUTTING_RESULT .

  DATA LT_CUTTING TYPE TABLE OF TY_S_CUTTING.
  DATA LV_ORD_ITEM(4).

  SELECT ZT01~ZCUT_ORD_NO,  ZT01~ZCUT_ORD_ITEM, ZT01~LOEKZ,
         ZT01~T_CHARG,      ZT01~ZCUT_LEN,      ZT01~ZCUT_CNT,   ZT01~MULTI_YN, ZT01~ORG_LENGTH,
         ZT01~ZCUT_MBLNR,   ZT01~ZCUT_MJAHR,    ZT01~ZCUT_ZEILE, ZT01~SOBKZ,  ZT01~PRINT_STAT,
         ZT02~ZASSIGN_NO,   ZT02~ZASSIGN_TYPE,  ZT02~WERKS,      ZT02~VBELN,  ZT02~POSNR,
         ZT02~ETENR,        ZT02~EDATU,         ZT02~WEMENG,     ZT02~VRKME,  ZT02~WELENG,
         ZT02~WECNT,        ZT02~MATNR,         ZT02~ZUPT_STAT,  ZT02~ZUPT_MSG,
         ZT02~CRDAT,        ZT02~CRTIM,         ZT02~CRNAM,
         ZT03~ZASSIGN_ITEM, ZT03~LGORT,         ZT03~F_CHARG,    ZT03~F_CHARG_ORG,
         ZT03~LABST1,       ZT03~LABST2,        ZT03~LABST3,     ZT03~ZORD_TYPE,
         ZT04~ZDR_MBLNR,    ZT04~ZDR_MJAHR,     ZT04~ZDR_ZEILE,
         MAKT~MAKTX,
         DD07T~DDTEXT AS ZORD_TYPE_TXT,
         CASE WHEN ZT01~ZCUT_MBLNR IS NOT INITIAL AND ZT04~ZDR_MBLNR IS NOT INITIAL THEN @ICON_LED_GREEN
              WHEN ZT01~ZCUT_MBLNR IS NOT INITIAL OR  ZT04~ZDR_MBLNR IS NOT INITIAL THEN @ICON_LED_YELLOW
              ELSE @SPACE
         END AS ZGR_STAT
    FROM ZGTPPT2190 AS ZT01
    JOIN ZGTPPT2170 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
    JOIN ZGTPPT2180 AS ZT03
      ON ZT01~ZASSIGN_NO   EQ ZT03~ZASSIGN_NO
     AND ZT01~ZASSIGN_ITEM EQ ZT03~ZASSIGN_ITEM
    LEFT JOIN ZGTPPT2191 AS ZT04
      ON ZT01~ZCUT_ORD_NO   EQ ZT04~ZCUT_ORD_NO
     AND ZT01~ZCUT_ORD_ITEM EQ ZT04~ZCUT_ORD_ITEM
    JOIN MARC
      ON ZT02~MATNR EQ MARC~MATNR
     AND ZT02~WERKS EQ MARC~WERKS
    JOIN MARA
      ON MARC~MATNR EQ MARA~MATNR
    LEFT JOIN MAKT
      ON MARA~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
    LEFT JOIN DD07L
      ON DD07L~DOMNAME  EQ 'ZGTDZORD_TYPE'
     AND DD07L~AS4LOCAL EQ 'A'
     AND ZT03~ZORD_TYPE EQ DD07L~DOMVALUE_L
    LEFT JOIN DD07T
      ON DD07L~DOMNAME    EQ DD07T~DOMNAME
     AND DD07L~VALPOS     EQ DD07T~VALPOS
     AND DD07L~AS4LOCAL   EQ DD07T~AS4LOCAL
     AND DD07T~DDLANGUAGE EQ @SY-LANGU
   WHERE ZT01~WERKS        EQ @P_WERKS
     AND ZT01~ZCUT_ORD_NO  IN @S_ZCUTNO
     AND ZT02~ZASSIGN_NO   IN @S_ZASGNO
     AND ZT02~ZASSIGN_TYPE IN @S_ZASGTP
     AND ZT02~VBELN        IN @S_VBELN
     AND ZT02~POSNR        IN @S_POSNR
     AND ZT02~VKBUR        IN @S_VKBUR
     AND ZT02~KUNNR        IN @S_KUNNR
     AND ZT02~EDATU        IN @S_EDATU
     AND ZT02~CRDAT        IN @S_CRDAT
     AND ZT02~MATNR        IN @S_MATNR
     AND MARA~MTART        IN @S_MTART
     AND MARA~MATKL        IN @S_MATKL
     AND MARC~FEVOR        IN @S_FEVOR
     AND ZT03~F_CHARG      IN @S_FCHARG
     AND ZT02~LOEKZ        IN @S_LOEKZ
   ORDER BY ZT01~ZCUT_ORD_NO, ZT01~ZCUT_ORD_ITEM
    INTO CORRESPONDING FIELDS OF TABLE @GT_CUTTING.

  IF GT_CUTTING IS NOT INITIAL.
    SELECT DISTINCT ZT01~VBELN, ZT01~POSNR
      INTO TABLE @DATA(LT_ZLET0401)
      FROM ZLET0401 AS ZT01
       FOR ALL ENTRIES IN @GT_CUTTING
     WHERE VBELN EQ @GT_CUTTING-VBELN
       AND POSNR EQ @GT_CUTTING-POSNR
       AND LVORM EQ @SPACE.

    SORT LT_ZLET0401 BY VBELN POSNR.
  ENDIF.

  LOOP AT GT_CUTTING REFERENCE INTO DATA(LR_CUTTING).
    "출하요청
    READ TABLE LT_ZLET0401 TRANSPORTING NO FIELDS WITH KEY VBELN = LR_CUTTING->VBELN
                                                           POSNR = LR_CUTTING->POSNR BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      LR_CUTTING->SHREQ = ICON_LED_GREEN.
    ENDIF.

    IF LR_CUTTING->ZUPT_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      LR_CUTTING->STATUS = ICON_LED_RED.
      LR_CUTTING->RETURN = VALUE #( ( TYPE = 'E' FIELD = TEXT-F01 MESSAGE = LR_CUTTING->ZUPT_MSG )  ).
    ENDIF.

    "배치번호(실제), 절단전기일자
    SELECT SINGLE CHARG, BUDAT
      FROM MATDOC
     WHERE MBLNR EQ @LR_CUTTING->ZCUT_MBLNR
       AND MJAHR EQ @LR_CUTTING->ZCUT_MJAHR
       AND SHKZG EQ 'H'
      INTO (@LR_CUTTING->A_CHARG, @LR_CUTTING->ZCUT_BUDAT).

    "절단실제조장
    SELECT SINGLE ERFMG
      FROM MATDOC
     WHERE MBLNR EQ @LR_CUTTING->ZCUT_MBLNR
       AND MJAHR EQ @LR_CUTTING->ZCUT_MJAHR
      INTO @LR_CUTTING->ZCUT_RLEN.

    IF LR_CUTTING->ZCUT_RLEN NE 0.
      IF LR_CUTTING->ZCUT_LEN EQ LR_CUTTING->ZCUT_RLEN.
        LR_CUTTING->ZCUT_LEN_STAT = ICON_EQUAL_GREEN.
      ELSE.
        LR_CUTTING->ZCUT_LEN_STAT = ICON_NOT_EQUAL_RED.
      ENDIF.
    ENDIF.

    "라벨발행
    IF LR_CUTTING->PRINT_STAT EQ 'Y'.
      LR_CUTTING->PRINT_STAT_TXT = ICON_LED_RED.
    ENDIF.

    "절단 스크랩
    CLEAR: LV_ORD_ITEM.
    LV_ORD_ITEM = LR_CUTTING->ZCUT_ORD_ITEM.

    SELECT ZMODE, WERKS, MATNR, CHARG, MENGE, MEINS, ZSTAT
      FROM ZGTPPT3450
     WHERE AUFNR EQ @LR_CUTTING->ZCUT_ORD_NO
       AND ZCUT_ORD_ITEM EQ @LV_ORD_ITEM
       AND ZERP_STAT EQ 'S'
      INTO TABLE @DATA(LT_3450).

    LOOP AT LT_3450 INTO DATA(LS_3450).
      IF LS_3450-ZMODE EQ 'TC'.
        LS_3450-MENGE = LS_3450-MENGE * ( -1 ).
      ENDIF.

      LR_CUTTING->ZCUT_SCRAP = LR_CUTTING->ZCUT_SCRAP + LS_3450-MENGE.
      CLEAR: LS_3450.
    ENDLOOP.

    "실적등록 체크 추가
    IF LR_CUTTING->ZGR_STAT EQ SPACE AND LR_CUTTING->ZCUT_SCRAP GT 0.
      LR_CUTTING->ZGR_STAT = ICON_LED_GREEN.
    ENDIF.

  ENDLOOP.

  IF S_ACHARG[] IS NOT INITIAL.
    DELETE GT_CUTTING WHERE A_CHARG NOT IN S_ACHARG.
  ENDIF.

  "취소할 절단지시번호 외 다른 품목에 절단자재문서가 존재하는 경우 체크
  CLEAR: LT_CUTTING.
  APPEND LINES OF GT_CUTTING TO LT_CUTTING.
  DELETE LT_CUTTING WHERE ZCUT_MBLNR EQ SPACE.
  SORT LT_CUTTING BY ZCUT_ORD_NO.
  "절단지시번호 기준으로 절단전표번호가 있는 건만 추출
  DELETE ADJACENT DUPLICATES FROM LT_CUTTING COMPARING ZCUT_ORD_NO.

  LOOP AT GT_CUTTING ASSIGNING FIELD-SYMBOL(<FS_CT>).
    READ TABLE LT_CUTTING INTO DATA(LS_CT) WITH KEY ZCUT_ORD_NO = <FS_CT>-ZCUT_ORD_NO.
    IF SY-SUBRC EQ 0.
      <FS_CT>-CHK_CUTMBLNR = 'X'.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_ALLOCTION_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ALLOCTION_RESULT .
  DATA LT_ZASSIGN_NO TYPE RANGE OF ZGTPPT2170-ZASSIGN_NO.

  CLEAR GT_ALLOC.

  DATA(LT_CUTTING) = GT_CUTTING.
  SORT LT_CUTTING BY ZASSIGN_NO.
  DELETE ADJACENT DUPLICATES FROM LT_CUTTING COMPARING ZASSIGN_NO.

  IF S_ZASGNO[] IS NOT INITIAL OR S_ZCUTNO[] IS NOT INITIAL.
    LT_ZASSIGN_NO = S_ZASGNO[].

    IF GT_CUTTING[] IS NOT INITIAL.
      SELECT 'I' AS SIGN, 'EQ' AS OPTION , A~ZASSIGN_NO AS LOW
        FROM @GT_CUTTING AS A
       GROUP BY A~ZASSIGN_NO
   APPENDING CORRESPONDING FIELDS OF TABLE @LT_ZASSIGN_NO.
    ENDIF.

    IF LT_ZASSIGN_NO IS INITIAL.
      RETURN.
    ENDIF.
  ENDIF.

  SELECT ZT01~ZASSIGN_NO,   ZT01~ZASSIGN_TYPE, ZT01~WERKS,   ZT01~VBELN,  ZT01~POSNR,
         ZT01~ETENR,        ZT01~EDATU,        ZT01~WEMENG,  ZT01~VRKME,  ZT01~WELENG,
         ZT01~WECNT,        ZT01~MATNR,        ZT01~CRDAT,   ZT01~CRTIM,  ZT01~CRNAM,
         ZT01~ZUPT_STAT,    ZT01~ZUPT_MSG,     ZT01~LOEKZ,   ZT01~DRDAT,
         ZT02~ZASSIGN_ITEM, ZT02~LGORT,        ZT02~F_CHARG, ZT02~LABST3, ZT02~MEINS,
         ZT02~ZCUT_YN,      ZT02~ZCUT_CNT,     ZT02~ZREW_YN, ZT02~ZEXCLUDE,
         ZT02~ZORD_TYPE,    ZT02~F_CHARG_ORG,
         MARA~ZZSPEC_NO, MAKT~MAKTX,
         T001L~LGOBE,
         DD07T~DDTEXT  AS ZTYPE_DESC,
         DD07T2~DDTEXT AS ZORD_TYPE_TXT,
         CASE WHEN ZT03~ZCUT_ORD_NO IS NOT INITIAL THEN @ICON_LED_GREEN
         END AS ZSTAT
    FROM ZGTPPT2170 AS ZT01
    JOIN ZGTPPT2180 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
    JOIN MARC
      ON ZT01~MATNR EQ MARC~MATNR
     AND ZT01~WERKS EQ MARC~WERKS
    JOIN MARA
      ON MARC~MATNR EQ MARA~MATNR
    LEFT JOIN @LT_CUTTING AS ZT03
      ON ZT01~ZASSIGN_NO EQ ZT03~ZASSIGN_NO
    LEFT JOIN T001L
      ON ZT01~WERKS EQ T001L~WERKS
     AND ZT02~LGORT EQ T001L~LGORT
    LEFT JOIN MAKT
      ON ZT01~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
    LEFT JOIN DD07L
      ON DD07L~DOMNAME     EQ 'ZGTDZASSIGN_TYPE'
     AND DD07L~AS4LOCAL    EQ 'A'
     AND ZT01~ZASSIGN_TYPE EQ DD07L~DOMVALUE_L
    LEFT JOIN DD07T
      ON DD07L~DOMNAME    EQ DD07T~DOMNAME
     AND DD07L~VALPOS     EQ DD07T~VALPOS
     AND DD07L~AS4LOCAL   EQ DD07T~AS4LOCAL
     AND DD07T~DDLANGUAGE EQ @SY-LANGU
    LEFT JOIN DD07L AS DD07L2
      ON DD07L2~DOMNAME  EQ 'ZGTDZORD_TYPE'
     AND DD07L2~AS4LOCAL EQ 'A'
     AND ZT02~ZORD_TYPE  EQ DD07L2~DOMVALUE_L
    LEFT JOIN DD07T AS DD07T2
      ON DD07L2~DOMNAME    EQ DD07T2~DOMNAME
     AND DD07L2~VALPOS     EQ DD07T2~VALPOS
     AND DD07L2~AS4LOCAL   EQ DD07T2~AS4LOCAL
     AND DD07T2~DDLANGUAGE EQ @SY-LANGU
   WHERE ZT01~WERKS      EQ @P_WERKS
     AND ZT01~VBELN      IN @S_VBELN
     AND ZT01~POSNR      IN @S_POSNR
     AND ZT01~ZASSIGN_NO IN @LT_ZASSIGN_NO
     AND ZT01~VKBUR      IN @S_VKBUR
     AND ZT01~KUNNR      IN @S_KUNNR
     AND ZT01~EDATU      IN @S_EDATU
     AND ZT01~CRDAT      IN @S_CRDAT
     AND ZT01~MATNR      IN @S_MATNR
     AND MARA~MTART      IN @S_MTART
     AND MARA~MATKL      IN @S_MATKL
     AND MARC~FEVOR      IN @S_FEVOR
     AND ZT02~F_CHARG    IN @S_FCHARG
     AND ZT01~LOEKZ      IN @S_LOEKZ
   ORDER BY ZT01~ZASSIGN_NO, ZT02~ZASSIGN_ITEM, ZT01~VBELN, ZT01~POSNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_ALLOC.

  "배치번호(실제)
  IF S_ACHARG[] IS NOT INITIAL.
    LOOP AT GT_ALLOC ASSIGNING FIELD-SYMBOL(<FS_AL>).
      READ TABLE LT_CUTTING INTO DATA(LS_CT) WITH KEY ZASSIGN_NO = <FS_AL>-ZASSIGN_NO.
      IF SY-SUBRC NE 0.
        <FS_AL>-SEL = 'X'.
      ENDIF.
    ENDLOOP.

    DELETE GT_ALLOC WHERE SEL EQ 'X'.
  ENDIF.

  SELECT DISTINCT MATDOC~MAT_KDAUF, MATDOC~MAT_KDPOS
    FROM @GT_ALLOC AS ZT01
    JOIN MATDOC
      ON ZT01~VBELN EQ MATDOC~MAT_KDAUF
     AND ZT01~POSNR EQ MATDOC~MAT_KDPOS
     AND MATDOC~BWART EQ '413'
     AND CANCELLED    EQ @SPACE
     AND SHKZG        EQ 'H'
   ORDER BY MATDOC~MAT_KDAUF, MATDOC~MAT_KDPOS
    INTO TABLE @DATA(LT_MATDOC).

  IF GT_ALLOC IS NOT INITIAL.
    SELECT DISTINCT ZT01~VBELN, ZT01~POSNR, ZT02~DRDAT
      INTO TABLE @DATA(LT_ZLET0401)
      FROM ZLET0401 AS ZT01
      JOIN ZLET0400 AS ZT02 ON ZT02~DLVRQ EQ ZT01~DLVRQ
       FOR ALL ENTRIES IN @GT_ALLOC
     WHERE ZT01~VBELN EQ @GT_ALLOC-VBELN
       AND ZT01~POSNR EQ @GT_ALLOC-POSNR
       AND ZT01~LVORM EQ @SPACE.

    SORT LT_ZLET0401 BY VBELN POSNR.
  ENDIF.

  LOOP AT GT_ALLOC REFERENCE INTO DATA(LR_ALLOC).
    IF LR_ALLOC->VBELN IS NOT INITIAL.
      READ TABLE LT_MATDOC INTO DATA(LS_MATDOC) WITH KEY MAT_KDAUF = LR_ALLOC->VBELN
                                                         MAT_KDPOS = LR_ALLOC->POSNR BINARY SEARCH.
      IF SY-SUBRC IS INITIAL.
        LR_ALLOC->Z413 = ICON_LED_GREEN. "// 고객전용.
      ENDIF.
    ENDIF.

    IF LR_ALLOC->ZUPT_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      LR_ALLOC->STATUS = ICON_LED_RED.
      LR_ALLOC->RETURN = VALUE #( ( TYPE = 'E' FIELD = TEXT-F01 MESSAGE = LR_ALLOC->ZUPT_MSG ) ).
    ENDIF.

    "출하요청
    READ TABLE LT_ZLET0401 INTO DATA(LS_ZLET0401) WITH KEY VBELN = LR_ALLOC->VBELN
                                                           POSNR = LR_ALLOC->POSNR BINARY SEARCH.

    IF SY-SUBRC IS INITIAL.
      LR_ALLOC->SHREQ = ICON_LED_GREEN.
      LR_ALLOC->DRDAT = LS_ZLET0401-DRDAT.
    ENDIF.

    CLEAR: LS_ZLET0401.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_sel_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM FIELD_SEL_HOTSPOT_CLICK  USING PS_SLORD TYPE TY_S_SLORD.

  TRY.
      PERFORM CHECK_BEFORE_STOCK_LIST_BUILD USING PS_SLORD. "// 사전점검.
      PERFORM BUILD_STOCK_LIST USING PS_SLORD.              "// 재고 리스트.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

  GR_SLORD->REFRESH( ).
  GR_STOCK->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_stock_list_build
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_STOCK_LIST_BUILD USING PS_SLORD TYPE TY_S_SLORD
                                 RAISING LCX_EXCEPTION.

  IF PS_SLORD-ALCMN GE PS_SLORD-WEMENG."// 기할당 수량 >= 납품수량.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E01.
  ENDIF.

  IF PS_SLORD-VBELN EQ GS_SLORD-VBELN AND PS_SLORD-POSNR EQ GS_SLORD-POSNR.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E02.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZGT_ZGTPPR2160'
    EXPORTING
      WERKS          = P_WERKS
      LGORT          = P_LGORT
      VBELN          = PS_SLORD-VBELN
      POSNR          = PS_SLORD-POSNR
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

  IF SY-SUBRC <> 0.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E040 WITH SY-UNAME PS_SLORD-VBELN PS_SLORD-POSNR.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED  USING PR_SENDER
                                PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                PV_UCOMM TYPE SY-UCOMM.

  IF GR_STOCK IS BOUND AND PR_SENDER EQ GR_STOCK->MR_GRID.
    PERFORM DATA_CHANGED_IN_STOCK USING PR_DATA_CHANGED PV_UCOMM.
  ENDIF.

  IF GR_WKORD IS BOUND AND PR_SENDER EQ GR_WKORD->MR_GRID.
    PERFORM DATA_CHANGED_IN_WKORD USING PR_DATA_CHANGED PV_UCOMM.
  ENDIF.

  IF GR_TABMT IS BOUND AND PR_SENDER EQ GR_TABMT->MR_GRID.
    PERFORM DATA_CHANGED_IN_TABMT USING PR_DATA_CHANGED PV_UCOMM.
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

  IF GR_STOCK IS BOUND AND PR_SENDER EQ GR_STOCK->MR_GRID.
    PERFORM DATA_CHANGED_FINI_IN_STOCK USING PT_GOOD_CELLS PV_MODIFIED.
  ENDIF.

  IF GR_TABMT IS BOUND AND PR_SENDER EQ GR_TABMT->MR_GRID.
    PERFORM DATA_CHANGED_FINI_IN_TABMT USING PT_GOOD_CELLS PV_MODIFIED.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_IN_STOCK  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                  PV_UCOMM TYPE SY-UCOMM.
  DATA LR_STOCK TYPE REF TO TY_S_STOCK.

  LOOP AT PR_DATA_CHANGED->MP_MOD_ROWS->* REFERENCE INTO LR_STOCK.
    READ TABLE PR_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_CELL)
                                             WITH KEY TABIX = SY-TABIX.
    PERFORM FIELD_VALID_CHECK_IN_STOCK USING LR_STOCK->*.
    PERFORM MODIFY_CELL_IN_STOCK       USING PR_DATA_CHANGED LS_CELL LR_STOCK->*.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_CELL_IN_STOCK  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                 PS_CELL  TYPE LVC_S_MODI
                                 PS_STOCK TYPE TY_S_STOCK.

  PR_DATA_CHANGED->MODIFY_CELL( I_ROW_ID    = PS_CELL-ROW_ID :
                                I_FIELDNAME = 'ZORD_TYPE'     I_VALUE = PS_STOCK-ZORD_TYPE ),
                                I_FIELDNAME = 'ZORD_TYPE_TXT' I_VALUE = PS_STOCK-ZORD_TYPE_TXT ),
                                I_FIELDNAME = 'LABST2'        I_VALUE = PS_STOCK-LABST2 ),
                                I_FIELDNAME = 'LABST3'        I_VALUE = PS_STOCK-LABST3 ),
                                I_FIELDNAME = 'STATUS'        I_VALUE = PS_STOCK-STATUS ),
                                I_FIELDNAME = 'ZCUT_YN'       I_VALUE = PS_STOCK-ZCUT_YN ),
                                I_FIELDNAME = 'ZREW_YN'       I_VALUE = PS_STOCK-ZREW_YN ),
                                I_FIELDNAME = 'RETURN'        I_VALUE = PS_STOCK-RETURN ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM FIELD_VALID_CHECK_IN_STOCK  USING PS_STOCK TYPE TY_S_STOCK.

  CLEAR: PS_STOCK-STATUS, PS_STOCK-RETURN.

  PERFORM CHECK_INPUT_VALUE_IN_STOCK USING PS_STOCK.
  PERFORM CHECK_MANDT_FIELD_IN_STOCK USING PS_STOCK.

  IF PS_STOCK-RETURN IS NOT INITIAL.
    PS_STOCK-STATUS = ICON_LED_RED.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE_IN_STOCK  USING PS_STOCK TYPE TY_S_STOCK.

  IF ( GS_SLORD-WELENG * PS_STOCK-ZCUT_CNT ) GT PS_STOCK-LABST3.
    PS_STOCK-RETURN = VALUE #( BASE PS_STOCK-RETURN ( TYPE = 'E' FIELD = TEXT-F32 MESSAGE = TEXT-E21 ) ).
  ENDIF.

*// 재고 비활성 선택.
  IF PS_STOCK-ZEXCLUDE EQ ABAP_TRUE.
    CLEAR: PS_STOCK-ZCUT_YN, PS_STOCK-ZREW_YN.
  ELSE.
***  2026.07.04 임시 수정 PYS
*    PS_STOCK-ZCUT_YN = COND #( WHEN P_CUT EQ ABAP_TRUE AND PS_STOCK-LABST3 GT GS_SLORD-WELENG THEN ZGTPP_IF_CONST=>GC_YN-YES
*                                                                                              ELSE SPACE ).
*    PS_STOCK-ZREW_YN = COND #( WHEN GS_SLORD-WERKS EQ GC_WERKS-6500 THEN PS_STOCK-ZCUT_YN
*                                                                    ELSE SPACE ).
  ENDIF.

  PERFORM SET_ORDER_ATTRIBUTE USING PS_STOCK.

*// 기할당 수량 = 기할당 수량 오리진 + ( 절단 조장수 * 조장 ).
  PS_STOCK-LABST2 = PS_STOCK-LABST2_ORGN + ( GS_SLORD-WELENG * PS_STOCK-ZCUT_CNT ).

*// 미할당 수량 = 재고수량 - 기할당 수량.
  PS_STOCK-LABST3 = PS_STOCK-LABST1 - PS_STOCK-LABST2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_MANDT_FIELD_IN_STOCK  USING PS_STOCK TYPE TY_S_STOCK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_fini_in_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_FINI_IN_STOCK  USING PT_GOOD_CELLS TYPE LVC_T_MODI
                                       PV_MODIFIED.

  CHECK PT_GOOD_CELLS IS NOT INITIAL.

  GR_STOCK->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click_in_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK_IN_STOCK  USING PS_ROW    TYPE LVC_S_ROID
                                   PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LR_STOCK) = REF #( GT_STOCK[ PS_ROW-ROW_ID ] OPTIONAL ).

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'STATUS'. "// 선택.
      IF LR_STOCK->RETURN IS NOT INITIAL.
        GR_STOCK->DISPLAY_MESSAGE( LR_STOCK->RETURN ).
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_F4  USING PR_SENDER.

  IF PR_SENDER EQ GR_WKORD.
    GR_WKORD->MT_F4 = VALUE #( REGISTER = ABAP_TRUE CHNGEAFTER = ABAP_TRUE ( FIELDNAME = 'DRMAT' ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_on_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_ON_F4  USING PR_SENDER
                         PV_FIELDNAME
                         PV_FIELDVALUE
                         PS_ROW_NO     TYPE LVC_S_ROID
                         PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                         PT_BAD_CELLS  TYPE LVC_T_MODI
                         PV_DISPLAY.


  CASE PV_FIELDNAME.
    WHEN 'DRMAT'.
      PERFORM F4_DRMAT USING PV_FIELDNAME  PV_FIELDVALUE PS_ROW_NO
                             PR_EVENT_DATA PT_BAD_CELLS  PV_DISPLAY.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_drmat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM F4_DRMAT  USING PV_FIELDNAME
                     PV_FIELDVALUE
                     PS_ROW_NO     TYPE LVC_S_ROID
                     PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                     PT_BAD_CELLS  TYPE LVC_T_MODI
                     PV_DISPLAY.
  DATA LV_USER_RESET TYPE C.
  DATA LT_RETURN TYPE TABLE OF DDSHRETVAL.

  SELECT MARA~MATNR,MAKT~MAKTX
    FROM MARA
    JOIN MARC
      ON MARA~MATNR EQ MARC~MATNR
    LEFT JOIN MAKT
      ON MARA~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS  EQ @SY-LANGU
   WHERE MARA~MTART EQ @ZGTPP_IF_CONST=>GC_MTART-MRM1
     AND MARC~WERKS EQ @P_WERKS
    INTO TABLE @DATA(LT_MATERIAL).

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'MATNR'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = TEXT-T31
      VALUE_ORG       = 'S'
    IMPORTING
      USER_RESET      = LV_USER_RESET
    TABLES
      VALUE_TAB       = LT_MATERIAL[]
      RETURN_TAB      = LT_RETURN[]
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  CHECK SY-SUBRC IS INITIAL.

  PR_EVENT_DATA->M_EVENT_HANDLED = ABAP_TRUE.

  CHECK PV_DISPLAY IS INITIAL AND LT_RETURN[] IS NOT INITIAL.

  PR_EVENT_DATA->M_DATA->* = VALUE LVC_T_MODI( BASE PR_EVENT_DATA->M_DATA->* ( ROW_ID    = PS_ROW_NO-ROW_ID
                                                                               FIELDNAME = PV_FIELDNAME
                                                                               VALUE     = VALUE #( LT_RETURN[ 1 ]-FIELDVAL OPTIONAL ) ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_WKORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_IN_WKORD  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                  PV_UCOMM TYPE SY-UCOMM.
  DATA LR_WKORD TYPE REF TO TY_S_WKORD.

  LOOP AT PR_DATA_CHANGED->MP_MOD_ROWS->* REFERENCE INTO LR_WKORD.
    READ TABLE PR_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_CELL)
                                             WITH KEY TABIX = SY-TABIX.
    PERFORM FIELD_VALID_CHECK_IN_WKORD USING LR_WKORD->*.
    PERFORM MODIFY_CELL_IN_WKORD       USING PR_DATA_CHANGED LS_CELL LR_WKORD->*.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_wkord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM FIELD_VALID_CHECK_IN_WKORD  USING  PS_WKORD TYPE TY_S_WKORD.

  CLEAR: PS_WKORD-STATUS, PS_WKORD-RETURN.

  PERFORM CHECK_INPUT_VALUE_IN_WKORD USING PS_WKORD.
  PERFORM CHECK_MANDT_FIELD_IN_WKORD USING PS_WKORD.

  IF PS_WKORD-RETURN IS NOT INITIAL.
    PS_WKORD-STATUS = ICON_LED_RED.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_wkord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_CELL_IN_WKORD  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                 PS_CELL  TYPE LVC_S_MODI
                                 PS_STOCK TYPE TY_S_WKORD.

  PR_DATA_CHANGED->MODIFY_CELL( I_ROW_ID    = PS_CELL-ROW_ID :
                                I_FIELDNAME = 'STATUS'  I_VALUE = PS_STOCK-STATUS ),
                                I_FIELDNAME = 'DRTXT'   I_VALUE = PS_STOCK-DRTXT ),
                                I_FIELDNAME = 'DRMEI'   I_VALUE = PS_STOCK-DRMEI ),
                                I_FIELDNAME = 'LGORT'   I_VALUE = PS_STOCK-LGORT ),
                                I_FIELDNAME = 'RETURN'  I_VALUE = PS_STOCK-RETURN ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_wkord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE_IN_WKORD  USING  PS_WKORD TYPE TY_S_WKORD.

*// 목드럼.
  IF PS_WKORD-DRMAT IS NOT INITIAL.
    SELECT SINGLE MARA~MATNR,MARA~MTART,MARA~MEINS, MAKT~MAKTX, MARC~LGPRO
      FROM MARA
      JOIN MARC
        ON MARA~MATNR EQ MARC~MATNR
       AND MARC~WERKS EQ @P_WERKS
      LEFT JOIN MAKT
        ON MARA~MATNR EQ MAKT~MATNR
       AND MAKT~SPRAS EQ @SY-LANGU
     WHERE MARA~MATNR EQ @PS_WKORD-DRMAT
      INTO @DATA(LS_MATERIAL).

    IF SY-SUBRC IS NOT INITIAL OR LS_MATERIAL-MTART NE ZGTPP_IF_CONST=>GC_MTART-MRM1.
      PS_WKORD-RETURN = VALUE #( BASE PS_WKORD-RETURN ( TYPE = 'E' FIELD = TEXT-F32 MESSAGE = TEXT-E24 ) ).
    ENDIF.
  ENDIF.

  PS_WKORD-DRTXT = LS_MATERIAL-MAKTX.
  PS_WKORD-DRMEI = LS_MATERIAL-MEINS.
  PS_WKORD-LGORT = LS_MATERIAL-LGPRO.

*// 저장위치.
  IF PS_WKORD-LGORT IS NOT INITIAL.
    READ TABLE GT_T001L TRANSPORTING NO FIELDS  WITH TABLE KEY WERKS = P_WERKS
                                                               LGORT = PS_WKORD-LGORT.
    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E103(M3) WITH PS_WKORD-LGORT P_WERKS INTO DATA(LV_MESSAGE).
      PS_WKORD-RETURN = VALUE #( BASE PS_WKORD-RETURN ( TYPE = 'E' FIELD = TEXT-F21 MESSAGE = LV_MESSAGE ) ).
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_wkord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_MANDT_FIELD_IN_WKORD  USING  PS_WKORD TYPE TY_S_WKORD.

*// 드럼.
  IF PS_WKORD-DRMAT IS INITIAL AND PS_WKORD-ZREW_YN EQ ZGTPP_IF_CONST=>GC_YN-YES.
    PS_WKORD-RETURN = VALUE #( BASE PS_WKORD-RETURN ( TYPE = 'E' FIELD = TEXT-F32 MESSAGE = TEXT-E25 ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_order_attribute
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_ORDER_ATTRIBUTE  USING PS_STOCK TYPE TY_S_STOCK.

*// 지시 유형.
  CASE ABAP_TRUE.
    WHEN P_CUT OR P_AD.   "// 절단 OR 난척발생분추가.
      PS_STOCK-ZORD_TYPE = COND #( WHEN PS_STOCK-ZCUT_YN  EQ ZGTPP_IF_CONST=>GC_YN-YES            THEN ZGTPP_IF_CONST=>GC_ZORD_TYPE-C1    "// 절단.
                                   WHEN PS_STOCK-ZCUT_YN  EQ SPACE AND PS_STOCK-ZEXCLUDE EQ SPACE THEN ZGTPP_IF_CONST=>GC_ZORD_TYPE-C0    "// 정조장.
                                   WHEN PS_STOCK-ZEXCLUDE NE SPACE                                THEN ZGTPP_IF_CONST=>GC_ZORD_TYPE-C9 ). "// 재고 비활성.

    WHEN P_LANBX. "// 랜 박스류.
      PS_STOCK-ZORD_TYPE = ZGTPP_IF_CONST=>GC_ZORD_TYPE-C2. "// 랜 박스류.

    WHEN P_OPTIC. "// 광 옥내.
      PS_STOCK-ZORD_TYPE = ZGTPP_IF_CONST=>GC_ZORD_TYPE-C3. "// 광 옥내.

    WHEN P_EA.    "// EA단위 품목.
      PS_STOCK-ZORD_TYPE = ZGTPP_IF_CONST=>GC_ZORD_TYPE-C5. "// EA단위 품목.
  ENDCASE.

  CLEAR PS_STOCK-ZORD_TYPE_TXT .

  READ TABLE GT_DD07V INTO DATA(LS_DD07V) WITH KEY DOMVALUE_L = PS_STOCK-ZORD_TYPE.
  IF SY-SUBRC IS INITIAL.
    PS_STOCK-ZORD_TYPE_TXT = LS_DD07V-DDTEXT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click_in_wkord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK_IN_WKORD  USING PS_ROW    TYPE LVC_S_ROID
                                   PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LR_WKORD) = REF #( GT_WKORD[ PS_ROW-ROW_ID ] OPTIONAL ).

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'STATUS' OR 'ZCUT_STATUS'.
      CHECK LR_WKORD->(PS_COLUMN-FIELDNAME) IS NOT INITIAL.

      IF LR_WKORD->RETURN IS NOT INITIAL.
        GR_WKORD->DISPLAY_MESSAGE( LR_WKORD->RETURN ).
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_cutting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_IN_CUTTING  USING  PV_UCOMM.

  CASE PV_UCOMM.
    WHEN GC_FCODE-UNDO.   "// 주문 할당&절단 지시 취소.
      PERFORM USER_COMMAND_UNDO.

    WHEN GC_FCODE-RESEND. "// 절단지시 재전송.
      PERFORM USER_COMMAND_RESEND.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_alloc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_IN_ALLOC  USING  PV_UCOMM.

  CASE PV_UCOMM.
    WHEN GC_FCODE-CANCEL_ALLOC. "// 주문 할당 취소.
      PERFORM USER_COMMAND_CANCEL_ALLOC.

    WHEN GC_FCODE-XC_UPD. "// 삭제/완료 업데이트
      PERFORM USER_COMMAND_XC_UPDATE_ALLOC.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_undo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_UNDO .

  TRY.
      CLEAR: GT_XMSG.
      PERFORM CHECK_BEFORE_UNDO.     "// 사전점검.
      PERFORM UNDO_ALLOC_WORK_ORDER. "// 주문 할당&절단 지시 취소.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_resend
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_RESEND .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_cancel_alloc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_CANCEL_ALLOC .

  TRY.
      CLEAR: GT_XMSG.
      PERFORM CHECK_BEFORE_CANCEL_ALLOC.     "// 사전점검.
      PERFORM CANCEL_SALES_ORDER_ALLOCATION. "// 주문 할당&절단 지시 취소.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_undo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_UNDO RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  "동일 배치번호(계획)로 주문할당에 정조장이 포함되어 있고 삭제/완료가 비어 있는 경우
  IF LINE_EXISTS( GT_ALLOC[ ZORD_TYPE = ZGTPP_IF_CONST=>GC_ZORD_TYPE-C0
                            LOEKZ = SPACE ] ).
    "해당 배치번호에 `정조장` 할당이 존재합니다. 하단의 정조장 할당부터 취소하세요.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-M02.
  ENDIF.

  PERFORM GET_ROWS_SELECTED_FOR_UNDO.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
  ENDIF.

*  IF GS_RESULT-INVALID IS NOT INITIAL.
*    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH GS_RESULT-MESSAGE.
*  ENDIF.

*  IF GS_RESULT-TOTAL IS INITIAL.
*    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
*  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C05 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_for_undo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_FOR_UNDO.
  DATA LV_ANSWER TYPE C.

  CLEAR GS_RESULT.

  MODIFY GT_CUTTING FROM VALUE #( SEL = ABAP_FALSE )
                    TRANSPORTING SEL
                    WHERE SEL EQ ABAP_TRUE.

  GR_CUTTING->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

*// 선택된 데이터 유효성 점검.
  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_CUTTING REFERENCE INTO DATA(LR_CUTTING) INDEX LS_ROW-INDEX.

    CHECK SY-SUBRC IS INITIAL.

    CLEAR: GV_MSGV.
    GV_MSGV = LR_CUTTING->ZCUT_ORD_NO && '/' && LR_CUTTING->ZCUT_ORD_ITEM.

    GS_RESULT-SEL += 1.

    IF LR_CUTTING->ZCUT_MBLNR NE SPACE.
*      GS_RESULT-INVALID = ABAP_TRUE.
*      GS_RESULT-MESSAGE = TEXT-E12.
*      RETURN.

      PERFORM APPEND_XMSG USING 'ZGTPP00' 'E' '000' GV_MSGV '-' TEXT-E12 ''.
      CONTINUE.
    ENDIF.

*// 취소할 절단지시번호 외 다른 품목에 절단자재문서가 존재하는 경우 취소 불가
    IF LR_CUTTING->CHK_CUTMBLNR EQ 'X'.
*      GS_RESULT-INVALID = ABAP_TRUE.
*      GS_RESULT-MESSAGE = TEXT-E12.
*      RETURN.

      PERFORM APPEND_XMSG USING 'ZGTPP00' 'E' '000' GV_MSGV '-' TEXT-E12 ''.
      CONTINUE.
    ENDIF.

    IF LR_CUTTING->SHREQ EQ ICON_LED_GREEN.
*      GS_RESULT-INVALID = ABAP_TRUE.
*      GS_RESULT-MESSAGE = TEXT-E29.
*      RETURN.

      PERFORM APPEND_XMSG USING 'ZGTPP00' 'E' '000' GV_MSGV '-' TEXT-E29 ''.
      CONTINUE.
    ENDIF.

*// 임시저장 절단 실적이 존재 하는 경우 오류
    SELECT SINGLE *
      FROM ZGTPPT3380
     WHERE ZCUT_ORD_NO EQ @LR_CUTTING->ZCUT_ORD_NO
       AND ZMODE EQ 'T'     "임시저장
      INTO @DATA(LS_3380).

    IF LS_3380 IS NOT INITIAL.
*      GS_RESULT-INVALID = ABAP_TRUE.
*      GS_RESULT-MESSAGE = TEXT-E35.  "MES에 임시 저장된 절단 실적이 존재하여 취소가 불가합니다.
*      CLEAR: LS_3380.
*      RETURN.

*      "MES에 임시 저장된 절단 실적이 존재하여 취소가 불가합니다.
*      PERFORM APPEND_XMSG USING 'ZGTPP00' 'E' '000' GV_MSGV '-' TEXT-E35 ''.
*      CLEAR: LS_3380.
*      CONTINUE.
    ENDIF.

**// 배치번호 기준으로 2건 이상의 주문 할당 건이 존재 하는 경우
*    SELECT A~*
*      FROM ZGTPPT2170 AS A
*      JOIN ZGTPPT2180 AS B ON B~ZASSIGN_NO EQ A~ZASSIGN_NO
*     WHERE A~LOEKZ EQ @SPACE
*       AND B~F_CHARG EQ @LR_CUTTING->F_CHARG
*      INTO TABLE @DATA(LT_CUT).
*
*    DATA(LV_LINES) = LINES( LT_CUT ).
*
*    CLEAR: LV_ANSWER.
*    IF LV_LINES > 1.
*      PERFORM CONFIRMATION_POPUP USING TEXT-C20 LV_ANSWER.
*    ELSEIF LV_LINES = 1.
*      LV_ANSWER = '1'.
*    ENDIF.
*
*    IF LV_ANSWER EQ '1'.
    GS_RESULT-TOTAL += 1.

    LR_CUTTING->SEL = ABAP_TRUE.

*    ELSE.
*      LR_CUTTING->SEL = ABAP_FALSE.
*    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form undo_alloc_work_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UNDO_ALLOC_WORK_ORDER.
  DATA LT_ZGTPPT2170 TYPE TY_T_ZGTPPT2170.

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

  CLEAR: GS_RESULT, GT_FXLEN.

  LOOP AT GT_CUTTING INTO DATA(LS_CUTTING)
                    WHERE SEL EQ ABAP_TRUE.
*                    GROUP BY LS_CUTTING-ZCUT_ORD_NO.
    CLEAR: LS_CUTTING-STATUS, LS_CUTTING-RETURN, GV_MSGV.

    GV_MSGV = LS_CUTTING-ZCUT_ORD_NO && '/' && LS_CUTTING-ZCUT_ORD_ITEM.

    PERFORM REMOVE_SALES_ORDER_DLV_BLOCK  USING LS_CUTTING.
    PERFORM CANCEL_CUTTING_WORK_ORDER     USING LS_CUTTING LT_ZGTPPT2170.
  ENDLOOP.

*// 정조장 생산오더 전송.
  PERFORM SUBMIT_ZGTPPI2010.

*// 절단오더 정보 송신.
  IF LT_ZGTPPT2170[] IS NOT INITIAL.
    PERFORM SUBMIT_ZGTPPI2030 TABLES LT_ZGTPPT2170.
  ENDIF.

*  PERFORM DISPLAY_PROCESSING_RESULTS.
  PERFORM DISPLAY_PROCESSING_CANCEL.

  GR_CUTTING->REFRESH( ).
  GR_ALLOC->REFRESH( ).

  IF NOT GT_XMSG IS INITIAL.
    CALL FUNCTION 'SCDT_MAPPING_DISPLAY_MESSAGES'
      TABLES
        MESSAGELIST = GT_XMSG[].
  ENDIF.

*  MESSAGE S009 WITH GS_RESULT-TOTAL GS_RESULT-SUCCESS GS_RESULT-ERROR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form remove_sales_order_dlv_block
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM REMOVE_SALES_ORDER_DLV_BLOCK USING PS_CUTTING TYPE TY_S_CUTTING.
  DATA LV_TYPE    TYPE BAPI_MTYPE.
  DATA LV_MESSAGE TYPE BAPI_MSG.
  DATA LS_MATNR TYPE RANGE_S_MATNR.
  DATA LT_MATNR LIKE TABLE OF LS_MATNR.

  SELECT SINGLE LIFSP
    INTO @DATA(LV_LIFSP)
    FROM VBEP
   WHERE VBELN EQ @PS_CUTTING-VBELN
     AND POSNR EQ @PS_CUTTING-POSNR
     AND ETENR EQ @PS_CUTTING-ETENR.

  IF LV_LIFSP EQ 'G1'.
    PS_CUTTING-ZUPT_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    PS_CUTTING-ZUPT_MSG  = TEXT-S04.
  ELSE.
    "해당 판매오더로 413 처리 건이 1건이라도 있는 경우 G1 업데이트를 수행하지 않음
    SELECT SINGLE MBLNR
      FROM MATDOC
     WHERE BWART EQ '413'
       AND CANCELLED EQ @SPACE
       AND MAT_KDAUF EQ @PS_CUTTING-VBELN
       AND MAT_KDPOS EQ @PS_CUTTING-POSNR
      INTO @DATA(LS_413).

    CHECK LS_413 IS INITIAL.

    CLEAR: GT_LINK_DETAIL, GT_LINK_STOCK, LT_MATNR, LS_MATNR.
    LS_MATNR-SIGN = 'I'.
    LS_MATNR-OPTION = 'EQ'.
    LS_MATNR-LOW = PS_CUTTING-MATNR.
    APPEND LS_MATNR TO LT_MATNR.

    CALL FUNCTION 'ZGTPP_GET_STOCK_LINK_INFO'
      EXPORTING
        I_WERKS        = PS_CUTTING-WERKS
        I_LGORT        = PS_CUTTING-LGORT
        IT_MATNR       = LT_MATNR
        I_VBELN        = PS_CUTTING-VBELN
        I_POSNR        = PS_CUTTING-POSNR
      TABLES
        OT_LINK_DETAIL = GT_LINK_DETAIL
        OT_LINK_STOCK  = GT_LINK_STOCK.

    SORT GT_LINK_DETAIL BY ZASSIGN_NO.
    DELETE GT_LINK_DETAIL WHERE ZASSIGN_NO EQ PS_CUTTING-ZASSIGN_NO.

    IF GT_LINK_DETAIL[] IS INITIAL.
      "FIXMG 설정값 추출
      SELECT SINGLE FIXMG
        FROM VBAP
       WHERE VBELN EQ @PS_CUTTING-VBELN
         AND POSNR EQ @PS_CUTTING-POSNR
        INTO @DATA(LV_FIXMG).

      CALL FUNCTION 'ZGTSD_RECEIVE_STOCK_LINK_INFO'
        EXPORTING
          I_VBELN = PS_CUTTING-VBELN
          I_POSNR = PS_CUTTING-POSNR
          I_MVGR3 = COND MVGR3( WHEN PS_CUTTING-ZORD_TYPE EQ ZGTPP_IF_CONST=>GC_ZORD_TYPE-C0 THEN ABAP_TRUE
                                ELSE ABAP_FALSE )
          I_LIFSP = 'G1'
          I_FIXMG = LV_FIXMG  "OM/SM 구분자
        IMPORTING
          E_TYPE  = LV_TYPE
          E_MSG   = LV_MESSAGE.

      IF LV_TYPE NE ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
        PS_CUTTING-ZUPT_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
        PS_CUTTING-ZUPT_MSG  = LV_MESSAGE.
      ELSE.
        PS_CUTTING-ZUPT_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
        PS_CUTTING-ZUPT_MSG  = LV_MESSAGE.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form cancel_cutting_work_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CANCEL_CUTTING_WORK_ORDER  USING PS_CUTTING TYPE TY_S_CUTTING
                                      PT_ZGTPPT2170 TYPE TY_T_ZGTPPT2170.

  DATA(LV_LOEKZ) = COND #( WHEN PS_CUTTING-ZUPT_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS THEN ABAP_TRUE
                                                                                          ELSE ABAP_FALSE ).

  UPDATE ZGTPPT2170 SET LOEKZ     = LV_LOEKZ
                        ZUPT_STAT = PS_CUTTING-ZUPT_STAT
                        ZUPT_MSG  = PS_CUTTING-ZUPT_MSG
                        CHDAT     = GS_ZGTPPS1001-CHDAT
                        CHTIM     = GS_ZGTPPS1001-CHTIM
                        CHNAM     = GS_ZGTPPS1001-CHNAM
                  WHERE ZASSIGN_NO EQ PS_CUTTING-ZASSIGN_NO.

  IF PS_CUTTING-ZUPT_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    UPDATE ZGTPPT2190 SET LOEKZ = ABAP_TRUE
                          CHDAT = GS_ZGTPPS1001-CHDAT
                          CHTIM = GS_ZGTPPS1001-CHTIM
                          CHNAM = GS_ZGTPPS1001-CHNAM
*                    WHERE ZCUT_ORD_NO EQ PS_CUTTING-ZCUT_ORD_NO.
                    WHERE ZCUT_ORD_NO EQ PS_CUTTING-ZCUT_ORD_NO
                      AND ZCUT_ORD_ITEM EQ PS_CUTTING-ZCUT_ORD_ITEM.

    APPEND INITIAL LINE TO PT_ZGTPPT2170 REFERENCE INTO DATA(LR_ZGTPPT2170).
    LR_ZGTPPT2170->ZASSIGN_NO = PS_CUTTING-ZASSIGN_NO.
    LR_ZGTPPT2170->ZUPT_STAT  = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.

    "주문 할당 및 절단 지시 취소를 처리하였습니다.
    PERFORM APPEND_XMSG USING 'ZGTPP00' 'S' '000' GV_MSGV '-' TEXT-S08 ''.

    GS_RESULT-SUCCESS += 1.
  ELSE.
    GS_RESULT-ERROR += 1.
  ENDIF.

  COMMIT WORK AND WAIT.

  GS_RESULT-TOTAL += 1.

  IF PS_CUTTING-ZORD_TYPE EQ ZGTPP_IF_CONST=>GC_ZORD_TYPE-C0. "// 정조장.
    APPEND VALUE #( WERKS = PS_CUTTING-WERKS
                    MATNR = PS_CUTTING-MATNR
                    CHARG = PS_CUTTING-F_CHARG ) TO GT_FXLEN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_cancel_alloc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_CANCEL_ALLOC  RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  PERFORM GET_ROWS_SELECTED_4_CNCL_ALLOC.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
  ENDIF.

*  IF GS_RESULT-INVALID IS NOT INITIAL.
*    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH GS_RESULT-MESSAGE.
*  ENDIF.

*  IF GS_RESULT-TOTAL IS INITIAL.
*    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
*  ENDIF.

  DATA(LV_QUESTION) = COND CHAR30( WHEN GS_RESULT-Z413 EQ ABAP_TRUE THEN TEXT-C16
                                                                    ELSE TEXT-C06 ).

  PERFORM CONFIRMATION_POPUP USING LV_QUESTION LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_4_cncl_alloc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_4_CNCL_ALLOC .
  DATA LV_ANSWER TYPE C.

  CLEAR GS_RESULT.

  MODIFY GT_ALLOC FROM VALUE #( SEL = ABAP_FALSE )
                  TRANSPORTING SEL
                  WHERE SEL EQ ABAP_TRUE.

  GR_ALLOC->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

*// 선택된 데이터 유효성 점검.
  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_ALLOC REFERENCE INTO DATA(LR_ALLOC) INDEX LS_ROW-INDEX.

    CHECK SY-SUBRC IS INITIAL.

    CLEAR: GV_MSGV.
    GV_MSGV = LR_ALLOC->ZASSIGN_NO && '/' && LR_ALLOC->ZASSIGN_ITEM.

    GS_RESULT-SEL += 1.

*// 삭제/완료 필드 값이 X 또는 C 인 경우.
    IF LR_ALLOC->LOEKZ EQ 'X' OR LR_ALLOC->LOEKZ EQ 'C'.
      IF LR_ALLOC->LOEKZ EQ 'X'.
        "이미 주문 할당이 취소된 데이터입니다.
        PERFORM APPEND_XMSG USING 'ZGTPP00' 'E' '000' GV_MSGV '-' TEXT-E36 ''.
        CONTINUE.
      ELSEIF LR_ALLOC->LOEKZ EQ 'C'.
        "이미 주문 할당이 완료된 데이터입니다.
        PERFORM APPEND_XMSG USING 'ZGTPP00' 'E' '000' GV_MSGV '-' TEXT-E37 ''.
        CONTINUE.
      ENDIF.
    ENDIF.

*// 절단 작업지시여부" 필드 값이 SPACE가 아니고, "고객 전용" 필드값이 SPACE인 경우.
    IF LR_ALLOC->ZSTAT NE SPACE.
      IF LR_ALLOC->Z413 EQ SPACE.
        GS_RESULT-INVALID = ABAP_TRUE.
*        GS_RESULT-MESSAGE = TEXT-E14.

        PERFORM APPEND_XMSG USING 'ZGTPP00' 'E' '000' GV_MSGV '-' TEXT-E14 ''.
        CONTINUE.
      ENDIF.

*// 절단 작업지시여부" 필드 값이 SPACE가 아니고, "고객 전용" 필드값이 ICON_LED_GREEN인 경우.
      IF LR_ALLOC->Z413 EQ ICON_LED_GREEN.
        GS_RESULT-Z413 = ABAP_TRUE.
      ENDIF.
    ENDIF.

**// 배치번호 기준으로 2건 이상의 주문 할당 건이 존재 하는 경우
*    SELECT A~*
*      FROM ZGTPPT2170 AS A
*      JOIN ZGTPPT2180 AS B ON B~ZASSIGN_NO EQ A~ZASSIGN_NO
*     WHERE A~LOEKZ EQ @SPACE
*       AND B~F_CHARG EQ @LR_ALLOC->F_CHARG
*      INTO TABLE @DATA(LT_CUT).
*
*    DATA(LV_LINES) = LINES( LT_CUT ).
*
*    CLEAR: LV_ANSWER.
*    IF LV_LINES > 1.
*      PERFORM CONFIRMATION_POPUP USING TEXT-C20 LV_ANSWER.
*    ELSEIF LV_LINES = 1.
*      LV_ANSWER = '1'.
*    ENDIF.
*
*    IF LV_ANSWER EQ '1'.
    GS_RESULT-TOTAL += 1.

    LR_ALLOC->SEL = ABAP_TRUE.

*    ELSE.
*      LR_ALLOC->SEL = ABAP_FALSE.
*    ENDIF.
  ENDLOOP.

  IF GS_RESULT-INVALID EQ ABAP_TRUE.
    CLEAR GS_RESULT-Z413.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form cancel_sales_order_allocation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CANCEL_SALES_ORDER_ALLOCATION .
  DATA LT_ZGTPPT2170 TYPE TY_T_ZGTPPT2170.

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

  PERFORM MODIFY_SALES_ORDER_ALLOCATION USING LT_ZGTPPT2170.

*// 정조장 생산오더 전송.
  PERFORM SUBMIT_ZGTPPI2010.

*// 절단오더 정보 송신.
  IF LT_ZGTPPT2170[] IS NOT INITIAL.
    PERFORM SUBMIT_ZGTPPI2030 TABLES LT_ZGTPPT2170.
  ENDIF.

*  PERFORM DISPLAY_PROCESSING_RESULTS.
  PERFORM DISPLAY_PROCESSING_CANCEL.

  GR_CUTTING->REFRESH( ).
  GR_ALLOC->REFRESH( ).

  IF NOT GT_XMSG IS INITIAL.
    CALL FUNCTION 'SCDT_MAPPING_DISPLAY_MESSAGES'
      TABLES
        MESSAGELIST = GT_XMSG[].
  ENDIF.

*  MESSAGE S009 WITH GS_RESULT-TOTAL GS_RESULT-SUCCESS GS_RESULT-ERROR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click_in_cuttting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK_IN_CUTTTING  USING PS_ROW    TYPE LVC_S_ROID
                                      PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LR_CUTTING) = REF #( GT_CUTTING[ PS_ROW-ROW_ID ] OPTIONAL ).

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'STATUS'. "// 선택.
      IF LR_CUTTING->RETURN IS NOT INITIAL.
        GR_CUTTING->DISPLAY_MESSAGE( LR_CUTTING->RETURN ).
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click_in_alloc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK_IN_ALLOC  USING PS_ROW    TYPE LVC_S_ROID
                                   PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LR_ALLOC) = REF #( GT_ALLOC[ PS_ROW-ROW_ID ] OPTIONAL ).

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'STATUS'. "// 선택.
      IF LR_ALLOC->RETURN IS NOT INITIAL.
        GR_ALLOC->DISPLAY_MESSAGE( LR_ALLOC->RETURN ).
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_sel_stock_cnc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_SEL_STOCK_CNC .

  TRY.
      PERFORM CHECK_BEFORE_SEL_STOCK_CNC. "// 사전점검.
      PERFORM CANCEL_STOCK_SELECTION.     "// 재고선택 취소.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_sel_stock_cnc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_SEL_STOCK_CNC RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  GR_WKORD->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  PERFORM GET_ROWS_SELECTED_4_CNC_SEL_ST.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
  ENDIF.

  IF GS_RESULT-INVALID IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH GS_RESULT-MESSAGE.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C07 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form cancel_stock_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CANCEL_STOCK_SELECTION .

*// 취소 절단 수량.
  SELECT VBELN, POSNR,MATNR, F_CHARG, SUM( ZCUT_LEN ) AS ZCUT_LEN, SUM( ZCUT_CNT ) AS ZCUT_CNT
    FROM @GT_WKORD AS A
   WHERE SEL   EQ @ABAP_TRUE
     AND VBELN NE @SPACE
   GROUP BY VBELN, POSNR, MATNR, F_CHARG
   ORDER BY VBELN, POSNR
    INTO TABLE @DATA(LT_WKORD).

  LOOP AT LT_WKORD INTO DATA(LS_WKORD).
    READ TABLE GT_SLORD REFERENCE INTO DATA(LR_SLORD) WITH TABLE KEY SKEY1
                                                          COMPONENTS VBELN = LS_WKORD-VBELN
                                                                     POSNR = LS_WKORD-POSNR.
    IF SY-SUBRC IS INITIAL.
*// 기할당 수량.
      LR_SLORD->ALCMN = LR_SLORD->ALCMN - LS_WKORD-ZCUT_LEN.
*// 기할당 조장수.
      LR_SLORD->ALCNT = LR_SLORD->ALCNT - LS_WKORD-ZCUT_CNT.

      DELETE LR_SLORD->STOCK WHERE MATNR EQ LS_WKORD-MATNR
                               AND CHARG EQ LS_WKORD-F_CHARG.
    ENDIF.
  ENDLOOP.

  DELETE GT_WKORD WHERE SEL EQ ABAP_TRUE.

  GR_SLORD->REFRESH( ).
  GR_STOCK->REFRESH( ).
  GR_WKORD->REFRESH( ).

  MESSAGE S000 WITH TEXT-S04.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_4_cnc_sel_st
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_4_CNC_SEL_ST .
  CLEAR GS_RESULT.

  MODIFY GT_WKORD FROM VALUE #( SEL = ABAP_FALSE )
                    TRANSPORTING SEL
                    WHERE SEL EQ ABAP_TRUE.

  GR_WKORD->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_WKORD INTO DATA(LS_WKORD) INDEX LS_ROW-INDEX.

    CHECK SY-SUBRC IS INITIAL.

    GS_RESULT-SEL += 1.

    IF LS_WKORD-ZCUT_ORD_NO IS NOT INITIAL OR
       LS_WKORD-ZASSIGN_NO  IS NOT INITIAL.
      GS_RESULT-INVALID = ABAP_TRUE.
      GS_RESULT-MESSAGE = TEXT-E15.
      RETURN.
    ENDIF.

    GS_RESULT-TOTAL += 1.

    MODIFY GT_WKORD  FROM VALUE #( SEL = ABAP_TRUE ) TRANSPORTING SEL
                    WHERE WERKS   EQ LS_WKORD-WERKS
                      AND MATNR   EQ LS_WKORD-MATNR
                      AND F_CHARG EQ LS_WKORD-F_CHARG
                      AND ( ZCUT_ORD_NO IS INITIAL OR ZASSIGN_NO IS INITIAL ).
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_allc_header_detail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_ALLC_HEADER_DETAIL TABLES PT_ZGTPPT2170 STRUCTURE ZGTPPT2170
                                   PT_ZGTPPT2180 STRUCTURE ZGTPPT2180
                             USING PS_SLORD TYPE TY_S_SLORD.

  DATA LV_ZASSIGN_ITEM TYPE ZGTPPT2180-ZASSIGN_ITEM.
  DATA LV_ZORD_TYPE TYPE ZGTPPT2180-ZORD_TYPE.     "// 지시 유형.

**// 주문 할당 - Header.
*  APPEND INITIAL LINE TO PT_ZGTPPT2170 REFERENCE INTO DATA(LR_ZGTPPT2170).
*  LR_ZGTPPT2170->* = CORRESPONDING #( PS_SLORD ).
*  LR_ZGTPPT2170->* = CORRESPONDING #( BASE ( LR_ZGTPPT2170->* ) GS_ZGTPPS1001 ).
*  LR_ZGTPPT2170->* = VALUE #( BASE LR_ZGTPPT2170->*  ZUPT_STAT = PS_SLORD-ZUPT_STAT
*                                                     ZUPT_MSG  = PS_SLORD-ZUPT_MSG ).

*  PERFORM GET_NEXT_NUMBER USING 'ZPP_ASSIGN' LR_ZGTPPT2170->ZASSIGN_NO.

  CLEAR: LV_ZORD_TYPE.
*// 주문 할당 - Detail.
  LOOP AT PS_SLORD-STOCK REFERENCE INTO DATA(LR_STOCK)
                         WHERE STATUS     NE ICON_LED_RED
                           AND ZASSIGN_NO EQ SPACE
                           AND ZCUT_CNT GT 0.

*    "지시유형이 다르면 주문할당번호 새로 채번
*    IF LR_STOCK->ZORD_TYPE NE LV_ZORD_TYPE
*// 주문 할당 - Header.
    APPEND INITIAL LINE TO PT_ZGTPPT2170 REFERENCE INTO DATA(LR_ZGTPPT2170).
    LR_ZGTPPT2170->* = CORRESPONDING #( PS_SLORD ).
    LR_ZGTPPT2170->* = CORRESPONDING #( BASE ( LR_ZGTPPT2170->* ) GS_ZGTPPS1001 ).
    LR_ZGTPPT2170->* = VALUE #( BASE LR_ZGTPPT2170->*  ZUPT_STAT = PS_SLORD-ZUPT_STAT
                                                       ZUPT_MSG  = PS_SLORD-ZUPT_MSG ).

    PERFORM GET_NEXT_NUMBER USING 'ZPP_ASSIGN' LR_ZGTPPT2170->ZASSIGN_NO.

*    LV_ZORD_TYPE = LR_STOCK->ZORD_TYPE.
*      CLEAR: LV_ZASSIGN_ITEM.
*    ENDIF.

*    LV_ZASSIGN_ITEM += 1.
    LV_ZASSIGN_ITEM = 1.

    LR_STOCK->ZASSIGN_NO   = LR_ZGTPPT2170->ZASSIGN_NO.
    LR_STOCK->ZASSIGN_ITEM = LV_ZASSIGN_ITEM.

    APPEND INITIAL LINE TO PT_ZGTPPT2180 REFERENCE INTO DATA(LR_ZGTPPT2180).
    LR_ZGTPPT2180->* = CORRESPONDING #( LR_STOCK->* ).
    LR_ZGTPPT2180->* = CORRESPONDING #( BASE ( LR_ZGTPPT2180->* ) GS_ZGTPPS1001 ).
    LR_ZGTPPT2180->* = VALUE #( BASE LR_ZGTPPT2180->*  LGORT   = PS_SLORD-LGORT
                                                       F_CHARG = LR_STOCK->CHARG
                                                       F_CHARG_ORG = LR_STOCK->CHARG ).

*// 기할당 조장 수.
*    PS_SLORD-ALCNT = PS_SLORD-ALCNT + LR_STOCK->ZCUT_CNT.
  ENDLOOP.

*// 기할당 수량.
*  PS_SLORD-ALCMN = PS_SLORD-WELENG * PS_SLORD-ALCNT.

  IF PS_SLORD-VBELN EQ GS_SLORD-VBELN AND PS_SLORD-POSNR EQ GS_SLORD-POSNR.
    GS_SLORD-ALCMN = PS_SLORD-ALCMN.
    GS_SLORD-ALCNT = PS_SLORD-ALCNT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cutting_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_CUTTING_DATA   TABLES PT_ZGTPPT2190 STRUCTURE ZGTPPT2190
                               PT_ZGTPPT2191 STRUCTURE ZGTPPT2191
                         USING PS_SLORD TYPE TY_S_SLORD
                               PS_WKORD TYPE TY_S_WKORD
                               PV_ZCUT_ORD_NO PV_ZCUT_ORD_ITEM PV_POSNR.

  READ TABLE PS_SLORD-STOCK INTO DATA(LS_STOCK) WITH TABLE KEY SKEY1
                                                    COMPONENTS GUID = PS_WKORD-GUID.

  PS_WKORD-ZASSIGN_NO   = LS_STOCK-ZASSIGN_NO.
  PS_WKORD-ZASSIGN_ITEM = LS_STOCK-ZASSIGN_ITEM.
  PS_WKORD-ZCUT_STATUS  = ICON_LED_GREEN.
  PS_WKORD-STATUS       = SPACE.

  IF ( PS_WKORD-ZORD_TYPE EQ ZGTPP_IF_CONST=>GC_ZORD_TYPE-C1 ) OR                                                  "// 절단
     ( PS_WKORD-ZORD_TYPE EQ ZGTPP_IF_CONST=>GC_ZORD_TYPE-C0 AND PS_WKORD-ZREW_YN EQ ZGTPP_IF_CONST=>GC_YN-YES ).  "// 정조장 & 재권취 필요.
    IF PV_ZCUT_ORD_NO IS INITIAL.
      PERFORM GET_NEXT_NUMBER USING 'ZPP_CUTORD' PV_ZCUT_ORD_NO.
    ENDIF.

*// 절단/권취 작업 지시 관리.
    PV_ZCUT_ORD_ITEM += 1.

    PS_WKORD-ZCUT_ORD_NO   = PV_ZCUT_ORD_NO.
    PS_WKORD-ZCUT_ORD_ITEM = PV_ZCUT_ORD_ITEM.

    IF GV_ASS_ITEM NE LS_STOCK-ZASSIGN_ITEM.
      GV_CUT_ITEM = 1.
    ELSE.
      GV_CUT_ITEM = PV_ZCUT_ORD_ITEM.
    ENDIF.

    GV_ASS_ITEM = LS_STOCK-ZASSIGN_ITEM.

    APPEND INITIAL LINE TO PT_ZGTPPT2190 REFERENCE INTO DATA(LR_ZGTPPT2190).
    LR_ZGTPPT2190->* = CORRESPONDING #( PS_WKORD ).
    LR_ZGTPPT2190->* = CORRESPONDING #( BASE ( LR_ZGTPPT2190->* ) GS_ZGTPPS1001 ).
    LR_ZGTPPT2190->* = VALUE #( BASE LR_ZGTPPT2190->*  SOBKZ        = COND #( WHEN PS_WKORD-VBELN IS NOT INITIAL THEN 'E' )
                                                       ZZCUT_REQ    = PS_SLORD-ZZCUT_REQ
                                                       ZASSIGN_NO   = LS_STOCK-ZASSIGN_NO
                                                       ZASSIGN_ITEM = LS_STOCK-ZASSIGN_ITEM ).

*// 원조장
    IF LR_ZGTPPT2190->SOBKZ EQ 'E'.
      READ TABLE GT_ORG_LEN ASSIGNING FIELD-SYMBOL(<FS_ORG>) WITH KEY F_CHARG = PS_WKORD-F_CHARG.

      IF <FS_ORG>-DB_CHK EQ 'X'.
        LR_ZGTPPT2190->ORG_LENGTH = <FS_ORG>-ORG_LENGTH.
      ELSE.
        LR_ZGTPPT2190->ORG_LENGTH = <FS_ORG>-ORG_LENGTH.
      ENDIF.

      "원조장 초기값 차감
      <FS_ORG>-ORG_LENGTH = <FS_ORG>-ORG_LENGTH - LR_ZGTPPT2190->ZCUT_LEN.

      IF LR_ZGTPPT2190->ORG_LENGTH < 0.
        LR_ZGTPPT2190->ORG_LENGTH = 0.
      ENDIF.
    ENDIF.

*// 절단/권취 작업 지시 관리 - BOM.
    IF PS_WKORD-DRMAT IS NOT INITIAL.
      PV_POSNR += 10.

      APPEND INITIAL LINE TO PT_ZGTPPT2191 REFERENCE INTO DATA(LR_ZGTPPT2191).
      LR_ZGTPPT2191->* = CORRESPONDING #( PS_WKORD ).
      LR_ZGTPPT2191->* = CORRESPONDING #( BASE ( LR_ZGTPPT2191->* ) GS_ZGTPPS1001 ).
      LR_ZGTPPT2191->* = VALUE #( BASE LR_ZGTPPT2191->*  POSNR = PV_POSNR
                                                         MATNR = PS_WKORD-DRMAT
                                                         BDMNG = 1
                                                         MEINS = PS_WKORD-DRMEI ).
    ENDIF.

    PS_WKORD-RETURN = VALUE #( ( TYPE = 'S' FIELD = TEXT-F01 MESSAGE = TEXT-S05 ) ).
  ELSE.
    PS_WKORD-RETURN = VALUE #( ( TYPE = 'S' FIELD = TEXT-F01 MESSAGE = TEXT-S06 ) ).
  ENDIF.

  IF PS_WKORD-ZORD_TYPE EQ ZGTPP_IF_CONST=>GC_ZORD_TYPE-C0. "// 정조장.
    APPEND VALUE #( WERKS = PS_WKORD-WERKS
                    MATNR = PS_WKORD-MATNR
                    CHARG = PS_WKORD-F_CHARG
                    VBELN = PS_WKORD-REF_VBELN
                    POSNR = PS_WKORD-REF_POSNR ) TO GT_FXLEN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form submit_zgtppi2010
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SUBMIT_ZGTPPI2010 .
  DATA LV_JOBNAME  TYPE TBTCJOB-JOBNAME VALUE 'ZGTPPR2160_SUBMIT_ZGTPPI2010'.
  DATA LV_JOBCOUNT TYPE TBTCJOB-JOBCOUNT.
  DATA LT_SELTAB   TYPE TABLE OF RSPARAMS.

  CHECK GT_FXLEN IS NOT INITIAL.

  PERFORM SET_CONDITION_FOR_ZGTPPI2010 USING LT_SELTAB.

  CHECK LT_SELTAB IS NOT INITIAL.

  PERFORM BATCH_JOB_OPEN USING LV_JOBNAME LV_JOBCOUNT.

  CHECK LV_JOBCOUNT IS NOT INITIAL.

  SUBMIT ZGTPPI2010 VIA JOB LV_JOBNAME NUMBER LV_JOBCOUNT
                    WITH SELECTION-TABLE LT_SELTAB
                    AND RETURN.

  PERFORM BATCH_JOB_CLOSE USING LV_JOBNAME LV_JOBCOUNT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_condition_for_zgtppi2010
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_CONDITION_FOR_ZGTPPI2010  USING PT_SELTAB TYPE RSPARAMS_TT.

  SELECT DISTINCT MATDOC~AUFNR, ZT01~VBELN, ZT01~POSNR
    FROM @GT_FXLEN AS ZT01
    JOIN MATDOC
      ON ZT01~WERKS EQ MATDOC~WERKS
     AND ZT01~MATNR EQ MATDOC~MATNR
     AND ZT01~CHARG EQ MATDOC~CHARG
   WHERE MATDOC~BWART EQ '101'
     AND MATDOC~AUFNR NE @SPACE
     AND CANCELLED    EQ @SPACE
    INTO TABLE @DATA(LT_FXLEN).

  CHECK LT_FXLEN[] IS NOT INITIAL.

  LOOP AT LT_FXLEN INTO DATA(LS_FXLEN).
    UPDATE AUFK   SET ZZKDAUF = LS_FXLEN-VBELN
                      ZZKDPOS = LS_FXLEN-POSNR
                WHERE AUFNR EQ LS_FXLEN-AUFNR.

    APPEND VALUE #( SELNAME = 'S_AUFNR' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_FXLEN-AUFNR ) TO PT_SELTAB.
  ENDLOOP.

  PT_SELTAB = VALUE #( BASE PT_SELTAB ( SELNAME = 'S_ERDAT' KIND = 'S' SIGN = 'I' OPTION = 'BT' LOW = ( SY-DATUM - 365 ) HIGH = SY-DATUM )
                                      ( SELNAME = 'P_R1'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_TRUE  )    "// 처리모드
                                      ( SELNAME = 'P_R2'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_FALSE )
                                      ( SELNAME = 'P_R3'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_FALSE )    "// 대상시스템.
                                      ( SELNAME = 'P_R4'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_FALSE )
                                      ( SELNAME = 'P_R9'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_FALSE )
                                      ( SELNAME = 'P_R10'   KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = COND #( WHEN P_WERKS EQ GC_WERKS-6500 THEN ABAP_TRUE ) )
                                      ( SELNAME = 'P_R11'   KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = COND #( WHEN P_WERKS EQ GC_WERKS-6600 THEN ABAP_TRUE ) )
                                      ( SELNAME = 'P_R8'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_TRUE   ) ). "// 배치처리.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BATCH_JOB_OPEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BATCH_JOB_OPEN  USING PV_JOBNAME PV_JOBCOUNT.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      JOBNAME          = PV_JOBNAME
    IMPORTING
      JOBCOUNT         = PV_JOBCOUNT
    EXCEPTIONS
      CANT_CREATE_JOB  = 1
      INVALID_JOB_DATA = 2
      JOBNAME_MISSING  = 3
      OTHERS           = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form batch_job_CLOSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BATCH_JOB_CLOSE  USING PV_JOBNAME PV_JOBCOUNT.
  DATA LV_RELEASED TYPE BTCH0000-CHAR1.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      JOBCOUNT             = PV_JOBCOUNT
      JOBNAME              = PV_JOBNAME
      STRTIMMED            = ABAP_TRUE
    IMPORTING
      JOB_WAS_RELEASED     = LV_RELEASED
    EXCEPTIONS
      CANT_START_IMMEDIATE = 1
      INVALID_STARTDATE    = 2
      JOBNAME_MISSING      = 3
      JOB_CLOSE_FAILED     = 4
      JOB_NOSTEPS          = 5
      JOB_NOTEX            = 6
      LOCK_FAILED          = 7
      OTHERS               = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sales_order_dlv_block
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_SALES_ORDER_DLV_BLOCK  USING  PS_ALLOC TYPE TY_S_ALLOC.
  DATA LV_TYPE    TYPE BAPI_MTYPE.
  DATA LV_MESSAGE TYPE BAPI_MSG.
  DATA LS_MATNR TYPE RANGE_S_MATNR.
  DATA LT_MATNR LIKE TABLE OF LS_MATNR.

  IF PS_ALLOC-ZEXCLUDE EQ ABAP_TRUE.
    PS_ALLOC-ZUPT_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    CLEAR: PS_ALLOC-ZUPT_MSG, PS_ALLOC-RETURN.
  ELSE.
*// 납품일정라인.
    SELECT SINGLE LIFSP
      INTO @DATA(LV_LIFSP)
      FROM VBEP
     WHERE VBELN EQ @PS_ALLOC-VBELN
       AND POSNR EQ @PS_ALLOC-POSNR
       AND ETENR EQ @PS_ALLOC-ETENR.

    IF LV_LIFSP EQ 'G1'.
      PS_ALLOC-ZUPT_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
      PS_ALLOC-ZUPT_MSG  = TEXT-S03.
      PS_ALLOC-RETURN    = VALUE #( ( TYPE = 'S' FIELD = TEXT-F01 MESSAGE = PS_ALLOC-ZUPT_MSG ) ).
    ELSE.
      "해당 판매오더로 413 처리 건이 1건이라도 있는 경우 G1 업데이트를 수행하지 않음
      SELECT SINGLE MBLNR
        FROM MATDOC
       WHERE BWART EQ '413'
         AND CANCELLED EQ @SPACE
         AND MAT_KDAUF EQ @PS_ALLOC-VBELN
         AND MAT_KDPOS EQ @PS_ALLOC-POSNR
        INTO @DATA(LS_413).

      CHECK LS_413 IS INITIAL.

      CLEAR: GT_LINK_DETAIL, GT_LINK_STOCK, LT_MATNR, LS_MATNR.
      LS_MATNR-SIGN = 'I'.
      LS_MATNR-OPTION = 'EQ'.
      LS_MATNR-LOW = PS_ALLOC-MATNR.
      APPEND LS_MATNR TO LT_MATNR.

      CALL FUNCTION 'ZGTPP_GET_STOCK_LINK_INFO'
        EXPORTING
          I_WERKS        = PS_ALLOC-WERKS
          I_LGORT        = PS_ALLOC-LGORT
          IT_MATNR       = LT_MATNR
          I_VBELN        = PS_ALLOC-VBELN
          I_POSNR        = PS_ALLOC-POSNR
        TABLES
          OT_LINK_DETAIL = GT_LINK_DETAIL
          OT_LINK_STOCK  = GT_LINK_STOCK.

      SORT GT_LINK_DETAIL BY ZASSIGN_NO.
      DELETE GT_LINK_DETAIL WHERE ZASSIGN_NO EQ PS_ALLOC-ZASSIGN_NO.

      IF GT_LINK_DETAIL[] IS INITIAL.
        "FIXMG 설정값 추출
        SELECT SINGLE FIXMG
          FROM VBAP
         WHERE VBELN EQ @PS_ALLOC-VBELN
           AND POSNR EQ @PS_ALLOC-POSNR
          INTO @DATA(LV_FIXMG).

        CALL FUNCTION 'ZGTSD_RECEIVE_STOCK_LINK_INFO'
          EXPORTING
            I_VBELN = PS_ALLOC-VBELN
            I_POSNR = PS_ALLOC-POSNR
*           I_MVGR3 = COND MVGR3( WHEN PS_ALLOC-ZORD_TYPE EQ ZGTPP_IF_CONST=>GC_ZORD_TYPE-C0 THEN ABAP_TRUE
*                                ELSE ABAP_FALSE )
            I_MVGR3 = SPACE
            I_LIFSP = 'G1'
            I_FIXMG = LV_FIXMG  "OM/SM 구분자
          IMPORTING
            E_TYPE  = LV_TYPE
            E_MSG   = LV_MESSAGE.

        IF LV_TYPE NE ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
          PS_ALLOC-ZUPT_STAT = ZGTPP_IF_CONST=>GC_RESULT-ERROR.
          PS_ALLOC-ZUPT_MSG  = LV_MESSAGE.
          PS_ALLOC-RETURN    = VALUE #( ( TYPE = 'E' FIELD = TEXT-F01 MESSAGE = PS_ALLOC-ZUPT_MSG ) ).
        ELSE.
          PS_ALLOC-ZUPT_STAT = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
          PS_ALLOC-ZUPT_MSG  = LV_MESSAGE.
          PS_ALLOC-RETURN    = VALUE #( ( TYPE = 'S' FIELD = TEXT-F01 MESSAGE = PS_ALLOC-ZUPT_MSG ) ).
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.

  MODIFY GT_ALLOC FROM VALUE #( ZUPT_STAT = PS_ALLOC-ZUPT_STAT
                                ZUPT_MSG  = PS_ALLOC-ZUPT_MSG
                                RETURN    = PS_ALLOC-RETURN )
                  TRANSPORTING ZUPT_STAT ZUPT_MSG RETURN
                  WHERE ZASSIGN_NO EQ PS_ALLOC-ZASSIGN_NO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_value_from_config
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_VALUE_FROM_CONFIG  USING PS_SLORD TYPE TY_S_SLORD.

  IF PS_SLORD-CUOBJ IS NOT INITIAL.
    PERFORM GET_VC_CONFIGURATION USING PS_SLORD-CUOBJ PS_SLORD-CONFG.
  ENDIF.

*// 공정코드.
  DATA(LV_PROC_NAME) = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_CA_PROC_NAME ]-ATWRT OPTIONAL ).

*// 할당 유형.
  PS_SLORD-ZASSIGN_TYPE = COND #( WHEN LV_PROC_NAME   EQ ZGTPP_IF_CONST=>GC_PD_CA_PROC-REW THEN ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-RW    "// 랜 박스류.
                                  WHEN LV_PROC_NAME   EQ ZGTPP_IF_CONST=>GC_PD_CA_PROC-ISH THEN ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-OI    "// 광 옥내.
                                  WHEN PS_SLORD-MEINS EQ ZGTPP_IF_CONST=>GC_MEINS-EA       THEN ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-EA    "// EA단위 품목.
                                                                                           ELSE ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-CT ). "// 절단.

  "처리유형이 난척 발생 분 추가인 경우 - 일반(절단)의 할당유형을 변경
  IF P_AD EQ 'X'.
    IF PS_SLORD-ZASSIGN_TYPE EQ ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-CT.
      PS_SLORD-ZASSIGN_TYPE = ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-AD.
    ENDIF.
  ENDIF.

*// 조장.
  IF PS_SLORD-ZASSIGN_TYPE EQ ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-EA.
    PS_SLORD-WELENG = PS_SLORD-WEMENG.
  ELSE.
    GR_CONV->CONVERT_STRING_TO_QTY( EXPORTING IV_INPUT  = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-SAP_MILLCA_LENGTH ]-ATWRT OPTIONAL )
                                    IMPORTING EV_OUTPUT = PS_SLORD-WELENG ).
  ENDIF.

*// 조장 수.
  IF PS_SLORD-ZASSIGN_TYPE EQ ZGTPP_IF_CONST=>GC_ZASSIGN_TYPE-EA.
    IF PS_SLORD-WELENG IS NOT INITIAL.
      PS_SLORD-WECNT = PS_SLORD-WEMENG / PS_SLORD-WELENG.
    ENDIF.
  ELSE.
    GR_CONV->CONVERT_STRING_TO_QTY( EXPORTING IV_INPUT  = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-SAP_MILLCA_FACTOR ]-ATWRT OPTIONAL )
                                    IMPORTING EV_OUTPUT = PS_SLORD-WECNT ).
  ENDIF.

  CHECK PS_SLORD-CONFG IS NOT INITIAL.

*// 색상.
  PS_SLORD-COLOR = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_CA_COLOR_BASE ]-ATWRT OPTIONAL ).

*// SKIP유무.
  PS_SLORD-SKID_YN = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_CA_SKID_YN ]-ATWRT OPTIONAL ).

*// 드럼구분.
  PS_SLORD-DRUM_GUBUN = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_GA_DRUM_GUBUN ]-ATWRT OPTIONAL ).

*// 포장구분.
  PS_SLORD-PACKAGE = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_GA_PACKAGE_METHOD ]-ATWRT OPTIONAL ).

*// 악판골판지.
  PS_SLORD-FLANGE_PROT = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_GA_FLANGE_PROT_YN ]-ATWRT OPTIONAL ).

*// 프린트.
  PS_SLORD-PRINT = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_GA_PRINT_METHOD ]-ATWRT OPTIONAL ).

*// 신드럼사용.
  PS_SLORD-NEW_DRUM = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_GA_NEW_DRUM_YN ]-ATWRT OPTIONAL ).

*// 랩포장.
  PS_SLORD-WRAP_PACKING = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_GA_WRAP_PACKING_YN ]-ATWRT OPTIONAL ).

*// 색상(상세)
  PS_SLORD-COLOR_DETAIL = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = 'PD_CA_COLOR_DETAIL' ]-ATWRT OPTIONAL ).

*// 색상(Sttipe)
  PS_SLORD-COLOR_STRIPE = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = 'PD_CA_COLOR_STRIPE' ]-ATWRT OPTIONAL ).

*// 색상(Stripe)수
  PS_SLORD-COLOR_STR_NO = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = 'PD_CA_COLOR_STRIPE_NO' ]-ATWRT OPTIONAL ).

*// 드럼코드
  PS_SLORD-PK_DRUM = VALUE #( PS_SLORD-CONFG[ KEY SKEY1 ATNAM = 'PD_CA_PACKING_DM' ]-ATWRT OPTIONAL ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form convert_material_unit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONVERT_MATERIAL_UNIT  USING PV_MATNR PV_MENGE PV_IN PV_OUT.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      I_MATNR              = PV_MATNR
      I_IN_ME              = PV_IN
      I_OUT_ME             = PV_OUT
      I_MENGE              = PV_MENGE
    IMPORTING
      E_MENGE              = PV_MENGE
    EXCEPTIONS
      ERROR_IN_APPLICATION = 1
      ERROR                = 2
      OTHERS               = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click_in_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK_IN_STOCK  USING PS_ROW    TYPE LVC_S_ROID
                                  PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LR_STOCK) = REF #( GT_STOCK[ PS_ROW-ROW_ID ] OPTIONAL ).

      IF LR_STOCK IS INITIAL.
        RETURN.
      ENDIF.

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CHECK LR_STOCK->ZCUT_CNT IS INITIAL.

  SELECT SUM( ZCUT_CNT ) FROM @GT_STOCK AS A INTO @DATA(LV_SUM).

  IF GS_SLORD-WELENG IS NOT INITIAL.
    DATA(LV_WECNT) = TRUNC( LR_STOCK->LABST3 / GS_SLORD-WELENG ).
  ENDIF.

  DATA(LV_ZCUT_CNT) = GS_SLORD-WECNT - GS_SLORD-ALCNT - LV_SUM.

  IF LV_ZCUT_CNT GE LV_WECNT.
    LR_STOCK->ZCUT_CNT = LV_WECNT.
  ELSE.
    LR_STOCK->ZCUT_CNT = LV_ZCUT_CNT.
  ENDIF.

*// 기할당 수량 = 기할당 수량 오리진 + ( 절단 조장수 * 조장 ).
  LR_STOCK->LABST2 = LR_STOCK->LABST2_ORGN + ( GS_SLORD-WELENG * LR_STOCK->ZCUT_CNT ).

*// 미할당 수량 = 재고수량 - 기할당 수량.
  LR_STOCK->LABST3 = LR_STOCK->LABST1 - LR_STOCK->LABST2.

  GR_STOCK->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_sel_std_len
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_SEL_STD_LEN .

  CHECK GT_STOCK[] IS NOT INITIAL.

  TRY.
      PERFORM CHECK_BEFORE_SEL_STD_LEN.   "// 사전점검.
      PERFORM RUN_SELECT_STANDARD_LENGTH. "// 재고선택.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_sel_std_len
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_SEL_STD_LEN  RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  GR_STOCK->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

*  IF NOT line_exists( gt_stock[ weleng = gs_slord-weleng ] ).
  IF NOT LINE_EXISTS( GT_STOCK[ LABST3 = GS_SLORD-WELENG ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E28.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C08 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form run_select_standard_length
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM RUN_SELECT_STANDARD_LENGTH .

*// 조장수 = 조장수 - 기할당 조장수.
  DATA(LV_WECNT) = GS_SLORD-WECNT - GS_SLORD-ALCNT.

  SORT GT_STOCK BY LGORT MATNR LWEDT CHARG.

  LOOP AT GT_STOCK REFERENCE INTO DATA(LR_STOCK).
    CLEAR LR_STOCK->ZCUT_CNT.

*// 절단 조장수.
    IF LR_STOCK->WELENG EQ GS_SLORD-WELENG AND LV_WECNT GE 0.
      IF LV_WECNT GE LR_STOCK->WECNT.
        LR_STOCK->ZCUT_CNT = LR_STOCK->WECNT.
      ELSE.
        LR_STOCK->ZCUT_CNT = LV_WECNT.
      ENDIF.

      LV_WECNT = LV_WECNT - LR_STOCK->WECNT.
    ENDIF.

    PERFORM FIELD_VALID_CHECK_IN_STOCK USING LR_STOCK->*.
  ENDLOOP.

  GR_STOCK->REFRESH( ).

  MESSAGE S000 WITH TEXT-S07.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_fixed_col
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_FIXED_COL .

  IF GR_SLORD IS BOUND.
    GR_SLORD->MR_GRID->GET_FRONTEND_FIELDCATALOG( IMPORTING ET_FIELDCATALOG = DATA(LT_FCAT) ).

    MODIFY LT_FCAT FROM VALUE #( FIX_COLUMN = ABAP_TRUE )
                   TRANSPORTING FIX_COLUMN
                   WHERE FIELDNAME EQ 'SEL'
                      OR FIELDNAME EQ 'VBELN'
                      OR FIELDNAME EQ 'POSNR'
                      OR FIELDNAME EQ 'MATNR'
                      OR FIELDNAME EQ 'MAKTX'.

    GR_SLORD->MR_GRID->SET_FRONTEND_FIELDCATALOG( LT_FCAT ).
    GR_SLORD->REFRESH( ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_parameter_description
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_PARAMETER_DESCRIPTION .

  CLEAR: P_NAME1, P_LGOBE.

  IF P_WERKS IS NOT INITIAL.
    SELECT SINGLE NAME1
      INTO @P_NAME1
      FROM T001W
     WHERE WERKS EQ @P_WERKS.
  ENDIF.

  IF P_WERKS IS NOT INITIAL AND P_LGORT IS NOT INITIAL.
    SELECT SINGLE LGOBE
      INTO @P_LGOBE
      FROM T001L
     WHERE WERKS EQ @P_WERKS
       AND LGORT EQ @P_LGORT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_fc01
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_FC01 .

  GR_DATA  = REF #( GT_T2420 ).
  GV_TABMT = GC_TABLE-ZGTPPT2420.
  GV_TPAR1 = TEXT-T41.
  GT_STYLE = VALUE #( STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED  ( FIELDNAME = 'FROM_DRUM' )
                                                                  ( FIELDNAME = 'TO_DRUM' ) ).

  PERFORM CHECK_PLANT_CODE.
  PERFORM ENQUEUE_TABLE.
  PERFORM RETRIEVE_DATA_FROM_ZGTPPT2420.

  CALL SCREEN 200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_fc02
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_FC02 .

  GV_TABMT = GC_TABLE-ZGTPPT2430.
  GR_DATA  = REF #( GT_T2430 ).
  GV_TPAR1 = TEXT-T42.
  GT_STYLE = VALUE #( STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED  ( FIELDNAME = 'MATNR' )
                                                                  ( FIELDNAME = 'F_LENGTH' )
                                                                  ( FIELDNAME = 'T_LENGTH' )
                                                                  ( FIELDNAME = 'DRUMNR' ) ).

  PERFORM CHECK_PLANT_CODE.
  PERFORM ENQUEUE_TABLE.
  PERFORM RETRIEVE_DATA_FROM_ZGTPPT2430.

  CALL SCREEN 200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_tabmt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_TABMT.

  IF GV_TABMT EQ GC_TABLE-ZGTPPT2420.
    PERFORM MODIFY_FCAT_IN_T2420.  "// (군포) 합판드럼 지정 규칙.
  ELSE.
    PERFORM MODIFY_FCAT_IN_T2430.  "// (전주) 목드럼 지정 규칙.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_T2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_T2420 .

  LOOP AT GR_TABMT->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-FA1.
        LR_FCAT->EMPHASIZE  = 'C110'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'NAME1'.
        LR_FCAT->COLTEXT    = TEXT-FA2.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'FROM_DRUM'.
        LR_FCAT->COLTEXT    = TEXT-FA3.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->MARK       = ABAP_TRUE.

      WHEN 'FROM_MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-FA4.

      WHEN 'TO_DRUM'.
        LR_FCAT->COLTEXT    = TEXT-FA5.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->MARK       = ABAP_TRUE.

      WHEN 'TO_MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-FA6.

      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-FA7.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MESSAGE'.
        LR_FCAT->COLTEXT    = TEXT-FA8.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_T2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_T2430 .

  LOOP AT GR_TABMT->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-FB1.
        LR_FCAT->EMPHASIZE  = 'C110'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'NAME1'.
        LR_FCAT->COLTEXT    = TEXT-FB2.
        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-FB3.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->MARK       = ABAP_TRUE.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-FB4.

      WHEN 'F_LENGTH'.
        LR_FCAT->COLTEXT    = TEXT-FB5.
        LR_FCAT->EDIT       = ABAP_TRUE.
*        lr_fcat->mark       = abap_true.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'T_LENGTH'.
        LR_FCAT->COLTEXT    = TEXT-FB6.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->MARK       = ABAP_TRUE.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'DRUMNR'.
        LR_FCAT->COLTEXT    = TEXT-FB7.
        LR_FCAT->EDIT       = ABAP_TRUE.

      WHEN 'DAKTX'.
        LR_FCAT->COLTEXT    = TEXT-FB8.

      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-FA7.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MESSAGE'.
        LR_FCAT->COLTEXT    = TEXT-FA8.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form retrieve_data_from_zgtppt2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM RETRIEVE_DATA_FROM_ZGTPPT2420 .

  SELECT ZT01~*,
         T001W~NAME1,
         MAKT1~MAKTX AS FROM_MAKTX,
         MAKT2~MAKTX AS TO_MAKTX
    FROM ZGTPPT2420 AS ZT01
    JOIN T001W
      ON ZT01~WERKS EQ T001W~WERKS
    LEFT JOIN MAKT AS MAKT1
      ON ZT01~FROM_DRUM EQ MAKT1~MATNR
     AND MAKT1~SPRAS    EQ @SY-LANGU
    LEFT JOIN MAKT AS MAKT2
      ON ZT01~TO_DRUM EQ MAKT2~MATNR
     AND MAKT2~SPRAS  EQ @SY-LANGU
   WHERE ZT01~WERKS EQ @P_WERKS
   ORDER BY ZT01~WERKS, ZT01~FROM_DRUM, ZT01~TO_DRUM
    INTO CORRESPONDING FIELDS OF TABLE @GT_T2420.

  IF SY-SUBRC IS INITIAL.
    MODIFY GT_T2420 FROM VALUE #( STYLE = GT_STYLE ) TRANSPORTING STYLE
                    WHERE WERKS EQ P_WERKS.
  ELSE.
    PERFORM SET_INIT_DATA_IN_T2420.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form retrieve_data_from_zgtppt2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM RETRIEVE_DATA_FROM_ZGTPPT2430 .

  SELECT ZT01~*,
         T001W~NAME1,
         MAKT1~MAKTX,
         MAKT2~MAKTX AS DAKTX
    FROM ZGTPPT2430 AS ZT01
    JOIN T001W
      ON ZT01~WERKS EQ T001W~WERKS
    LEFT JOIN MAKT AS MAKT1
      ON ZT01~MATNR  EQ MAKT1~MATNR
     AND MAKT1~SPRAS EQ @SY-LANGU
    LEFT JOIN MAKT AS MAKT2
      ON ZT01~DRUMNR EQ MAKT2~MATNR
     AND MAKT2~SPRAS EQ @SY-LANGU
   WHERE ZT01~WERKS EQ @P_WERKS
   ORDER BY ZT01~WERKS, ZT01~MATNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_T2430.

  IF SY-SUBRC IS INITIAL.
    MODIFY GT_T2430 FROM VALUE #( STYLE = GT_STYLE ) TRANSPORTING STYLE
                    WHERE WERKS EQ P_WERKS.
  ELSE.
    PERFORM SET_INIT_DATA_IN_T2430.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_data_in_t2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_INIT_DATA_IN_T2420 .

  DO 10 TIMES.
    APPEND INITIAL LINE TO GT_T2420 REFERENCE INTO DATA(LR_T2420).
    PERFORM SET_DEFALUT_VALUE_OF_T2420 USING LR_T2420->*.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_data_in_t2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_INIT_DATA_IN_T2430 .

  DO 10 TIMES.
    APPEND INITIAL LINE TO GT_T2430 REFERENCE INTO DATA(LR_T2430).
    PERFORM SET_DEFALUT_VALUE_OF_T2430 USING LR_T2430->*.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_tabmt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_IN_TABMT .

  TRY.
      GR_TABMT->MS_LAYOUT = VALUE #( BASE GR_TABMT->MS_LAYOUT  STYLEFNAME = 'STYLE' ).

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_defalut_value_of_t2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_DEFALUT_VALUE_OF_T2420  USING PS_T2420 TYPE TY_S_T2420.

  PS_T2420 = VALUE #( WERKS = P_WERKS
                      NAME1 = P_NAME1
                      INIT  = ABAP_TRUE ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_defalut_value_of_t2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_DEFALUT_VALUE_OF_T2430  USING PS_T2430 TYPE TY_S_T2430.

  PS_T2430 = VALUE #( WERKS = P_WERKS
                      NAME1 = P_NAME1
                      INIT  = ABAP_TRUE ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_plant_code
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_PLANT_CODE .

  CLEAR P_NAME1.

  IF P_WERKS IS INITIAL.
    MESSAGE E164(M3) DISPLAY LIKE 'S'.
  ELSE.
    SELECT SINGLE NAME1
      INTO @P_NAME1
      FROM T001W
     WHERE WERKS EQ @P_WERKS.

    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E011(VF) WITH P_WERKS DISPLAY LIKE 'S'.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_Storage_Location
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_STORAGE_LOCATION.

  IF P_WKORD IS NOT INITIAL.
    IF P_LGORT IS INITIAL.
      MESSAGE E838(O8) DISPLAY LIKE 'S'.
    ELSE.
      SELECT SINGLE @ABAP_TRUE
        INTO @DATA(LV_CHECK)
        FROM T001L
       WHERE WERKS EQ @P_WERKS
         AND LGORT EQ @P_LGORT.

      IF SY-SUBRC IS NOT INITIAL.
        MESSAGE E103(M3) WITH P_LGORT P_WERKS DISPLAY LIKE 'S'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form enqueue_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ENQUEUE_TABLE .

  CALL FUNCTION 'ENQUEUE_E_TABLE'
    EXPORTING
      TABNAME        = COND #( WHEN GV_TABMT EQ GC_TABLE-ZGTPPT2420 THEN GC_TABLE-ZGTPPT2420
                                                                    ELSE GC_TABLE-ZGTPPT2430 )
      VARKEY         = CONV VIM_ENQKEY( |{ P_WERKS }| )
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
      TABNAME = COND #( WHEN GV_TABMT EQ GC_TABLE-ZGTPPT2420 THEN GC_TABLE-ZGTPPT2420
                                                             ELSE GC_TABLE-ZGTPPT2430 )
      VARKEY  = CONV VIM_ENQKEY( |{ P_WERKS }| ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_SAVE .

  TRY.
*// 사전점검.
      PERFORM CHECK_BEFORE_SAVE_CBO_TABLE.

*// 저장.
      PERFORM SAVE_CBO_TABLE.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        GR_TABMT->REFRESH( ).
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_save_cbo_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_SAVE_CBO_TABLE RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  GR_TABMT->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  PERFORM SAVED_DATA_EXTRACTION.

  IF GS_RESULT-INVALID IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E03.
  ENDIF.

*  IF gs_result-total IS INITIAL.
*    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e04.
*  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C02 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_cbo_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_CBO_TABLE .

  IF GV_TABMT EQ GC_TABLE-ZGTPPT2420.
    PERFORM SAVE_ZGTPPT2420.
  ELSE.
    PERFORM SAVE_ZGTPPT2430.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form saved_data_extraction
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVED_DATA_EXTRACTION .

  CLEAR GS_RESULT.

  IF GV_TABMT EQ GC_TABLE-ZGTPPT2420.
    MODIFY GT_T2420 FROM VALUE #( SEL = SPACE )
                    TRANSPORTING SEL
                    WHERE SEL EQ ABAP_TRUE.

    LOOP AT GT_T2420 REFERENCE INTO DATA(LR_T2420)
                     WHERE INIT EQ ABAP_FALSE.
      IF LR_T2420->STATUS EQ ICON_LED_RED.
        GS_RESULT-INVALID = ABAP_TRUE.
        CONTINUE.
      ENDIF.

      GS_RESULT-SEL   += 1.
      GS_RESULT-TOTAL += 1.

      LR_T2420->SEL = ABAP_TRUE.
    ENDLOOP.
  ELSE.
    MODIFY GT_T2430 FROM VALUE #( SEL = SPACE )
                    TRANSPORTING SEL
                    WHERE SEL EQ ABAP_TRUE.

    LOOP AT GT_T2430 REFERENCE INTO DATA(LR_T2430)
                     WHERE INIT EQ ABAP_FALSE.
      IF LR_T2430->STATUS EQ ICON_LED_RED.
        GS_RESULT-INVALID = ABAP_TRUE.
        CONTINUE.
      ENDIF.

      GS_RESULT-SEL   += 1.
      GS_RESULT-TOTAL += 1.

      LR_T2430->SEL = ABAP_TRUE.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_zgtppt2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_ZGTPPT2420 .
  DATA LT_ZGTPPT2420 TYPE TABLE OF ZGTPPT2420.

  SELECT MANDT, WERKS, FROM_DRUM, TO_DRUM,
         CRDAT, CRTIM, CRNAM, CHDAT, CHTIM, CHNAM,
         @ABAP_FALSE AS DEL
    FROM ZGTPPT2420 AS ZT01
   WHERE WERKS EQ @P_WERKS
   ORDER BY WERKS, FROM_DRUM, TO_DRUM
    INTO TABLE @DATA(LT_ZGTPPT2420_DB).

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

  LOOP AT GT_T2420 REFERENCE INTO DATA(LR_T2420)
                   WHERE SEL EQ ABAP_TRUE.
    APPEND INITIAL LINE TO LT_ZGTPPT2420 REFERENCE INTO DATA(LR_ZGTPPT2420).
    LR_ZGTPPT2420->* = CORRESPONDING #( LR_T2420->* ).

    READ TABLE LT_ZGTPPT2420_DB REFERENCE INTO DATA(LR_ZGTPPT2420_DB) WITH KEY WERKS     = LR_T2420->WERKS
                                                                               FROM_DRUM = LR_T2420->FROM_DRUM
                                                                               TO_DRUM   = LR_T2420->TO_DRUM BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      LR_ZGTPPT2420->* = VALUE #( BASE LR_ZGTPPT2420->*  CHDAT = GS_ZGTPPS1001-CHDAT
                                                         CHTIM = GS_ZGTPPS1001-CHTIM
                                                         CHNAM = GS_ZGTPPS1001-CHNAM ).
      LR_T2420->* = VALUE #( BASE LR_T2420->*  CHDAT = GS_ZGTPPS1001-CHDAT
                                               CHTIM = GS_ZGTPPS1001-CHTIM
                                               CHNAM = GS_ZGTPPS1001-CHNAM ).
      LR_ZGTPPT2420_DB->DEL = ABAP_TRUE.
    ELSE.
      LR_ZGTPPT2420->* = CORRESPONDING #( BASE ( LR_ZGTPPT2420->* ) GS_ZGTPPS1001 ).
      LR_T2420->* = CORRESPONDING #( BASE ( LR_T2420->* ) GS_ZGTPPS1001 ).
    ENDIF.

    LR_T2420->STYLE = GT_STYLE.
  ENDLOOP.

  DELETE LT_ZGTPPT2420_DB WHERE DEL EQ ABAP_TRUE.

  TRY.
      IF LT_ZGTPPT2420_DB IS NOT INITIAL.
        DELETE ZGTPPT2420 FROM TABLE LT_ZGTPPT2420_DB.
      ENDIF.

      MODIFY ZGTPPT2420 FROM TABLE LT_ZGTPPT2420.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E16.
  ENDTRY.

  COMMIT WORK AND WAIT.

  DELETE GT_T2420 WHERE INIT EQ ABAP_TRUE.

  GR_TABMT->REFRESH( ).

  MESSAGE S500(MI).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_zgtppt2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_ZGTPPT2430 .
  DATA LT_ZGTPPT2430 TYPE TABLE OF ZGTPPT2430.

  SELECT MANDT, WERKS, MATNR, F_LENGTH, T_LENGTH, DRUMNR,
         CRDAT, CRTIM, CRNAM, CHDAT, CHTIM, CHNAM,
         @ABAP_FALSE AS DEL
    FROM ZGTPPT2430 AS ZT01
   WHERE WERKS EQ @P_WERKS
   ORDER BY WERKS, MATNR, F_LENGTH, T_LENGTH, DRUMNR
    INTO TABLE @DATA(LT_ZGTPPT2430_DB).

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

  LOOP AT GT_T2430 REFERENCE INTO DATA(LR_T2430)
                   WHERE SEL EQ ABAP_TRUE.
    APPEND INITIAL LINE TO LT_ZGTPPT2430 REFERENCE INTO DATA(LR_ZGTPPT2430).
    LR_ZGTPPT2430->* = CORRESPONDING #( LR_T2430->* ).

    READ TABLE LT_ZGTPPT2430_DB REFERENCE INTO DATA(LR_ZGTPPT2430_DB) WITH KEY WERKS    = LR_T2430->WERKS
                                                                               MATNR    = LR_T2430->MATNR
                                                                               F_LENGTH = LR_T2430->F_LENGTH
                                                                               T_LENGTH = LR_T2430->T_LENGTH
                                                                               DRUMNR   = LR_T2430->DRUMNR BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      LR_ZGTPPT2430->* = VALUE #( BASE LR_ZGTPPT2430->*  CHDAT = GS_ZGTPPS1001-CHDAT
                                                         CHTIM = GS_ZGTPPS1001-CHTIM
                                                         CHNAM = GS_ZGTPPS1001-CHNAM ).
      LR_T2430->* = VALUE #( BASE LR_T2430->*  CHDAT = GS_ZGTPPS1001-CHDAT
                                               CHTIM = GS_ZGTPPS1001-CHTIM
                                               CHNAM = GS_ZGTPPS1001-CHNAM ).
      LR_ZGTPPT2430_DB->DEL = ABAP_TRUE.
    ELSE.
      LR_ZGTPPT2430->* = CORRESPONDING #( BASE ( LR_ZGTPPT2430->* ) GS_ZGTPPS1001 ).
      LR_T2430->* = CORRESPONDING #( BASE ( LR_T2430->* ) GS_ZGTPPS1001 ).
    ENDIF.

    LR_T2430->STYLE = GT_STYLE.
  ENDLOOP.

  DELETE LT_ZGTPPT2430_DB WHERE DEL EQ ABAP_TRUE.

  TRY.
      IF LT_ZGTPPT2430_DB IS NOT INITIAL.
        DELETE ZGTPPT2430 FROM TABLE LT_ZGTPPT2430_DB.
      ENDIF.

      MODIFY ZGTPPT2430 FROM TABLE LT_ZGTPPT2430.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E16.
  ENDTRY.

  COMMIT WORK AND WAIT.

  DELETE GT_T2430 WHERE INIT EQ ABAP_TRUE.

  GR_TABMT->REFRESH( ).

  MESSAGE S500(MI).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_tabmt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_IN_TABMT  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                  PV_UCOMM TYPE SY-UCOMM.

  IF GV_TABMT EQ GC_TABLE-ZGTPPT2420.
    PERFORM DATA_CHANGED_IN_T2420 USING PR_DATA_CHANGED PV_UCOMM.
  ELSE.
    PERFORM DATA_CHANGED_IN_T2430 USING PR_DATA_CHANGED PV_UCOMM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_t2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_IN_T2420  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                  PV_UCOMM TYPE SY-UCOMM.

  DATA LR_T2420 TYPE REF TO TY_S_T2420.
  DATA LS_T2420 TYPE TY_S_T2420.

  PERFORM SET_DEFALUT_VALUE_OF_T2420  USING LS_T2420 .

  LOOP AT PR_DATA_CHANGED->MT_INSERTED_ROWS INTO DATA(LS_INSERT_ROW).
    PR_DATA_CHANGED->MODIFY_CELL( I_ROW_ID = LS_INSERT_ROW-ROW_ID: I_FIELDNAME = 'WERKS'  I_VALUE = LS_T2420-WERKS ),
                                                                   I_FIELDNAME = 'NAME1'  I_VALUE = LS_T2420-NAME1 ),
                                                                   I_FIELDNAME = 'INIT'   I_VALUE = LS_T2420-INIT ).
  ENDLOOP.

  LOOP AT PR_DATA_CHANGED->MP_MOD_ROWS->* REFERENCE INTO LR_T2420 .
    READ TABLE PR_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_CELL)
                                             WITH KEY TABIX = SY-TABIX.

    PERFORM FIELD_VALID_CHECK_IN_T2420  USING LR_T2420->*.
    PERFORM MODIFY_CELL_IN_T2420        USING PR_DATA_CHANGED LS_CELL LR_T2420->*.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_t2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM FIELD_VALID_CHECK_IN_T2420  USING PS_T2420 TYPE TY_S_T2420.

  CLEAR: PS_T2420-STATUS, PS_T2420-MESSAGE, PS_T2420-RETURN.

  PERFORM CHECK_INPUT_VALUE_IN_T2420 USING PS_T2420.
  PERFORM CHECK_MANDT_FIELD_IN_T2420 USING PS_T2420.

  IF PS_T2420-RETURN IS NOT INITIAL.
    PS_T2420-STATUS  = ICON_LED_RED.
    PS_T2420-MESSAGE = VALUE #( PS_T2420-RETURN[ 1 ]-MESSAGE OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_t2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE_IN_T2420  USING PS_T2420 TYPE TY_S_T2420.

  CLEAR: PS_T2420-INIT, PS_T2420-FROM_MAKTX, PS_T2420-TO_MAKTX.

*// 전환 전 드럼코드.
  IF PS_T2420-FROM_DRUM IS NOT INITIAL.
    PERFORM GET_MATERIAL_DESC USING PS_T2420-FROM_DRUM PS_T2420-FROM_MAKTX.

    SELECT SINGLE @ABAP_TRUE
      INTO @DATA(LV_CHECK)
      FROM MARC
     WHERE MARC~MATNR EQ @PS_T2420-FROM_DRUM
       AND MARC~WERKS EQ @PS_T2420-WERKS.

    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E200(M3) WITH PS_T2420-FROM_DRUM PS_T2420-WERKS INTO DATA(LV_MESSAGE).
      PS_T2420-RETURN = VALUE #( BASE PS_T2420-RETURN ( TYPE = 'E'  FIELD = TEXT-FA3  MESSAGE = LV_MESSAGE ) ).
    ENDIF.
  ENDIF.

*// 전환 후 드럼코드.
  IF PS_T2420-TO_DRUM IS NOT INITIAL.
    PERFORM GET_MATERIAL_DESC USING PS_T2420-TO_DRUM PS_T2420-TO_MAKTX.

    SELECT SINGLE @ABAP_TRUE
      INTO @LV_CHECK
      FROM MARC
     WHERE MARC~MATNR EQ @PS_T2420-TO_DRUM
       AND MARC~WERKS EQ @PS_T2420-WERKS.

    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E200(M3) WITH PS_T2420-TO_DRUM PS_T2420-WERKS INTO LV_MESSAGE.
      PS_T2420-RETURN = VALUE #( BASE PS_T2420-RETURN ( TYPE = 'E'  FIELD = TEXT-FA5  MESSAGE = LV_MESSAGE ) ).
    ENDIF.
  ENDIF.

  IF PS_T2420-FROM_DRUM IS NOT INITIAL AND PS_T2420-FROM_DRUM EQ PS_T2420-TO_DRUM.
    PS_T2420-RETURN = VALUE #( BASE PS_T2420-RETURN ( TYPE = 'E'  FIELD = TEXT-FA3  MESSAGE = TEXT-E17 ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_material_desc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MATERIAL_DESC  USING PV_MATNR PV_MAKTX.

  SELECT SINGLE MAKTX
    INTO @PV_MAKTX
    FROM MAKT
   WHERE MATNR EQ @PV_MATNR
     AND SPRAS EQ @SY-LANGU.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_t2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_MANDT_FIELD_IN_T2420  USING PS_T2420 TYPE TY_S_T2420.

  DATA(LR_T2420) = REF #( PS_T2420 ).

  LOOP AT GR_TABMT->MT_FCAT INTO DATA(LS_FCAT)
                           WHERE MARK EQ ABAP_TRUE
                             AND TECH EQ ABAP_FALSE.
    PERFORM APPEND_MANDT_FIELD_TO_RETURN USING LR_T2420->(LS_FCAT-FIELDNAME) LS_FCAT-COLTEXT LR_T2420->RETURN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_mandt_field_to_return
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM APPEND_MANDT_FIELD_TO_RETURN  USING PV_FIELD PV_FNAME
                                         PT_RETURN TYPE BAPIRET2_TAB.

  CHECK PV_FIELD IS INITIAL.

  MESSAGE E026 WITH PV_FNAME INTO DATA(LV_MESSAGE).

  PT_RETURN = VALUE #( BASE PT_RETURN ( TYPE = 'E' FIELD = PV_FNAME MESSAGE = LV_MESSAGE ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_t2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_IN_T2430  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                  PV_UCOMM TYPE SY-UCOMM.

  DATA LR_T2430 TYPE REF TO TY_S_T2430.
  DATA LS_T2430 TYPE TY_S_T2430.

  PERFORM SET_DEFALUT_VALUE_OF_T2430  USING LS_T2430 .

  LOOP AT PR_DATA_CHANGED->MT_INSERTED_ROWS INTO DATA(LS_INSERT_ROW).
    PR_DATA_CHANGED->MODIFY_CELL( I_ROW_ID = LS_INSERT_ROW-ROW_ID: I_FIELDNAME = 'WERKS'  I_VALUE = LS_T2430-WERKS ),
                                                                   I_FIELDNAME = 'NAME1'  I_VALUE = LS_T2430-NAME1 ),
                                                                   I_FIELDNAME = 'INIT'   I_VALUE = LS_T2430-INIT ).
  ENDLOOP.

  LOOP AT PR_DATA_CHANGED->MP_MOD_ROWS->* REFERENCE INTO LR_T2430 .
    READ TABLE PR_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_CELL)
                                             WITH KEY TABIX = SY-TABIX.

    PERFORM FIELD_VALID_CHECK_IN_T2430  USING LR_T2430->*.
    PERFORM MODIFY_CELL_IN_T2430        USING PR_DATA_CHANGED LS_CELL LR_T2430->*.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_t2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM FIELD_VALID_CHECK_IN_T2430  USING PS_T2430 TYPE TY_S_T2430.

  CLEAR: PS_T2430-STATUS, PS_T2430-MESSAGE, PS_T2430-RETURN.

  PERFORM CHECK_INPUT_VALUE_IN_T2430 USING PS_T2430.
  PERFORM CHECK_MANDT_FIELD_IN_T2430 USING PS_T2430.

  IF PS_T2430-RETURN IS NOT INITIAL.
    PS_T2430-STATUS  = ICON_LED_RED.
    PS_T2430-MESSAGE = VALUE #( PS_T2430-RETURN[ 1 ]-MESSAGE OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_t2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE_IN_T2430  USING PS_T2430 TYPE TY_S_T2430.

  CLEAR: PS_T2430-INIT, PS_T2430-MAKTX, PS_T2430-DAKTX.

*// 품목코드.
  IF PS_T2430-MATNR IS NOT INITIAL.
    PERFORM GET_MATERIAL_DESC USING PS_T2430-MATNR PS_T2430-MAKTX.

    SELECT SINGLE @ABAP_TRUE
      INTO @DATA(LV_CHECK)
      FROM MARC
     WHERE MARC~MATNR EQ @PS_T2430-MATNR
       AND MARC~WERKS EQ @PS_T2430-WERKS.

    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E200(M3) WITH PS_T2430-MATNR PS_T2430-WERKS INTO DATA(LV_MESSAGE).
      PS_T2430-RETURN = VALUE #( BASE PS_T2430-RETURN ( TYPE = 'E'  FIELD = TEXT-FB3  MESSAGE = LV_MESSAGE ) ).
    ENDIF.
  ENDIF.

*// 드럼코드.
  IF PS_T2430-DRUMNR IS NOT INITIAL.
    PERFORM GET_MATERIAL_DESC USING PS_T2430-DRUMNR PS_T2430-DAKTX.

    SELECT SINGLE @ABAP_TRUE
      INTO @LV_CHECK
      FROM MARC
     WHERE MARC~MATNR EQ @PS_T2430-DRUMNR
       AND MARC~WERKS EQ @PS_T2430-WERKS.

    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E200(M3) WITH PS_T2430-DRUMNR PS_T2430-WERKS INTO LV_MESSAGE.
      PS_T2430-RETURN = VALUE #( BASE PS_T2430-RETURN ( TYPE = 'E'  FIELD = TEXT-FB7  MESSAGE = LV_MESSAGE ) ).
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_t2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_MANDT_FIELD_IN_T2430  USING PS_T2430 TYPE TY_S_T2430.

  DATA(LR_T2430) = REF #( PS_T2430 ).

  LOOP AT GR_TABMT->MT_FCAT INTO DATA(LS_FCAT)
                           WHERE MARK EQ ABAP_TRUE
                             AND TECH EQ ABAP_FALSE.
    PERFORM APPEND_MANDT_FIELD_TO_RETURN USING LR_T2430->(LS_FCAT-FIELDNAME) LS_FCAT-COLTEXT LR_T2430->RETURN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_t2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_CELL_IN_T2420  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                 PS_CELL  TYPE LVC_S_MODI
                                 PS_T2420 TYPE TY_S_T2420.

  PR_DATA_CHANGED->MODIFY_CELL( I_ROW_ID = PS_CELL-ROW_ID:  I_FIELDNAME = 'INIT'       I_VALUE = PS_T2420-INIT ),
                                                            I_FIELDNAME = 'FROM_MAKTX' I_VALUE = PS_T2420-FROM_MAKTX ),
                                                            I_FIELDNAME = 'TO_MAKTX'   I_VALUE = PS_T2420-TO_MAKTX ),
                                                            I_FIELDNAME = 'STATUS'     I_VALUE = PS_T2420-STATUS ),
                                                            I_FIELDNAME = 'MESSAGE'    I_VALUE = PS_T2420-MESSAGE ),
                                                            I_FIELDNAME = 'RETURN'     I_VALUE = PS_T2420-RETURN ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_t2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_CELL_IN_T2430  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                 PS_CELL  TYPE LVC_S_MODI
                                 PS_T2430 TYPE TY_S_T2430.

  PR_DATA_CHANGED->MODIFY_CELL( I_ROW_ID = PS_CELL-ROW_ID:  I_FIELDNAME = 'INIT'    I_VALUE = PS_T2430-INIT ),
                                                            I_FIELDNAME = 'MAKTX'   I_VALUE = PS_T2430-MAKTX ),
                                                            I_FIELDNAME = 'DAKTX'   I_VALUE = PS_T2430-DAKTX ),
                                                            I_FIELDNAME = 'STATUS'  I_VALUE = PS_T2430-STATUS ),
                                                            I_FIELDNAME = 'MESSAGE' I_VALUE = PS_T2430-MESSAGE ),
                                                            I_FIELDNAME = 'RETURN'  I_VALUE = PS_T2430-RETURN ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar_in_tabmt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR_IN_TABMT  USING PR_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  DATA(LV_NBSP) = CL_ABAP_CONV_IN_CE=>UCCP( '00A0' ).

  PR_OBJECT->MT_TOOLBAR = VALUE #( BASE PR_OBJECT->MT_TOOLBAR
                                  ( BUTN_TYPE = 3 )
                                  ( FUNCTION  = GC_FCODE-INSERT_ROW
                                    ICON      = ICON_INSERT_ROW
                                    TEXT      = |{ TEXT-B08 }{ LV_NBSP }{ LV_NBSP }{ LV_NBSP }{ LV_NBSP }|
                                    QUICKINFO = TEXT-B08 )
                                  ( FUNCTION  = GC_FCODE-DELETE_ROW
                                    ICON      = ICON_DELETE_ROW
                                    TEXT      = |{ TEXT-B09 }{ LV_NBSP }{ LV_NBSP }{ LV_NBSP }{ LV_NBSP }|
                                    QUICKINFO = TEXT-B09 ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_tabmt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_IN_TABMT  USING  PV_UCOMM.

  IF GV_TABMT EQ GC_TABLE-ZGTPPT2420.
    PERFORM USER_COMMAND_IN_T2420 USING PV_UCOMM.
  ELSE.
    PERFORM USER_COMMAND_IN_T2430 USING PV_UCOMM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_t2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_IN_T2420  USING PV_UCOMM.

  CASE PV_UCOMM.
    WHEN GC_FCODE-INSERT_ROW. "// 행 추가.
      PERFORM INSERT_ROW_IN_T2420.

    WHEN GC_FCODE-DELETE_ROW. "// 행 삭제.
      PERFORM DELETE_ROW_IN_T2420.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_t2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_IN_T2430  USING PV_UCOMM.

  CASE PV_UCOMM.
    WHEN GC_FCODE-INSERT_ROW. "// 행 추가.
      PERFORM INSERT_ROW_IN_T2430.

    WHEN GC_FCODE-DELETE_ROW. "// 행 삭제.
      PERFORM DELETE_ROW_IN_T2430.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_row_in_t2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INSERT_ROW_IN_T2420 .

  IF GT_T2420 IS INITIAL.
    PERFORM SET_INIT_DATA_IN_T2420.
  ELSE.
    GR_TABMT->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).

    IF LT_ROWS IS NOT INITIAL.
      DATA(LS_ROW) = VALUE #( LT_ROWS[ 1 ] OPTIONAL ).

      DO LINES( LT_ROWS ) TIMES.
        INSERT INITIAL LINE INTO GT_T2420 REFERENCE INTO DATA(LR_T2420) INDEX LS_ROW-INDEX.
        PERFORM SET_DEFALUT_VALUE_OF_T2420 USING LR_T2420->*.
      ENDDO.
    ELSE.
      APPEND INITIAL LINE TO GT_T2420 REFERENCE INTO LR_T2420.
      PERFORM SET_DEFALUT_VALUE_OF_T2420 USING LR_T2420->*.
    ENDIF.
  ENDIF.

  GR_TABMT->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_row_in_t2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DELETE_ROW_IN_T2420 .
  DATA LV_ANSWER TYPE C.

  GR_TABMT->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    MESSAGE I000 WITH TEXT-E06 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C09 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_T2420 REFERENCE INTO DATA(LR_T2420) INDEX LS_ROW-INDEX.
    IF SY-SUBRC IS INITIAL.
      LR_T2420->SEL = ABAP_TRUE.
    ENDIF.
  ENDLOOP.

  DELETE GT_T2420 WHERE SEL EQ ABAP_TRUE.
  PERFORM CHECK_DUPLICATION_IN_T2420.

  GR_TABMT->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_row_in_t2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INSERT_ROW_IN_T2430 .

  IF GT_T2430 IS INITIAL.
    PERFORM SET_INIT_DATA_IN_T2430.
  ELSE.
    GR_TABMT->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).

    IF LT_ROWS IS NOT INITIAL.
      DATA(LS_ROW) = VALUE #( LT_ROWS[ 1 ] OPTIONAL ).

      DO LINES( LT_ROWS ) TIMES.
        INSERT INITIAL LINE INTO GT_T2430 REFERENCE INTO DATA(LR_T2430) INDEX LS_ROW-INDEX.
        PERFORM SET_DEFALUT_VALUE_OF_T2430 USING LR_T2430->*.
      ENDDO.
    ELSE.
      APPEND INITIAL LINE TO GT_T2430 REFERENCE INTO LR_T2430.
      PERFORM SET_DEFALUT_VALUE_OF_T2430 USING LR_T2430->*.
    ENDIF.
  ENDIF.

  GR_TABMT->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_row_in_t2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DELETE_ROW_IN_T2430.
  DATA LV_ANSWER TYPE C.

  GR_TABMT->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    MESSAGE I000 WITH TEXT-E06 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C09 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_T2430 REFERENCE INTO DATA(LR_T2430) INDEX LS_ROW-INDEX.
    IF SY-SUBRC IS INITIAL.
      LR_T2430->SEL = ABAP_TRUE.
    ENDIF.
  ENDLOOP.

  DELETE GT_T2430 WHERE SEL EQ ABAP_TRUE.
  PERFORM CHECK_DUPLICATION_IN_T2430.

  GR_TABMT->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_fini_in_tabmt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DATA_CHANGED_FINI_IN_TABMT  USING PT_GOOD_CELLS TYPE LVC_T_MODI
                                       PV_MODIFIED.

  CHECK PT_GOOD_CELLS IS NOT INITIAL.

  IF GV_TABMT EQ GC_TABLE-ZGTPPT2420.
    PERFORM CHECK_DUPLICATION_IN_T2420.
  ELSE.
    PERFORM CHECK_DUPLICATION_IN_T2430.
  ENDIF.

  GR_TABMT->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_duplication_in_tabmt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_DUPLICATION_IN_TABMT .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_duplication_in_t2420
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_DUPLICATION_IN_T2420 .

*// 자재 중복 여부.
  SELECT WERKS, FROM_DRUM, TO_DRUM
    FROM @GT_T2420 AS A
   WHERE FROM_DRUM NE @SPACE
     AND TO_DRUM   NE @SPACE
   GROUP BY WERKS, FROM_DRUM, TO_DRUM
  HAVING COUNT( * ) GT 1
    INTO TABLE @DATA(LT_T2420).

*// 기존 데이터 중복 해지.
  LOOP AT GT_T2420 REFERENCE INTO DATA(LR_T2420)
                   WHERE DUPLI EQ ABAP_TRUE.
    LR_T2420->DUPLI = ABAP_FALSE.
    DELETE LR_T2420->RETURN WHERE FIELD EQ GC_DUPLICATION.

    IF LR_T2420->RETURN IS INITIAL.
      CLEAR: LR_T2420->STATUS, LR_T2420->MESSAGE.
    ENDIF.
  ENDLOOP.

*// 중복 데이터 설정.
  LOOP AT LT_T2420 INTO DATA(LS_T2420).
    LOOP AT GT_T2420 REFERENCE INTO LR_T2420
                     WHERE FROM_DRUM EQ LS_T2420-FROM_DRUM
                       AND TO_DRUM   EQ LS_T2420-TO_DRUM.
      LR_T2420->DUPLI  = ABAP_TRUE.
      LR_T2420->RETURN = VALUE #( BASE LR_T2420->RETURN ( TYPE = 'E' FIELD = GC_DUPLICATION MESSAGE = TEXT-E18 ) ).
      IF LINES( LR_T2420->RETURN ) EQ 1.
        LR_T2420->STATUS  = ICON_LED_RED.
        LR_T2420->MESSAGE = LR_T2420->RETURN[ 1 ]-MESSAGE.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_duplication_in_t2430
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_DUPLICATION_IN_T2430 .

*// 자재 중복 여부.
  SELECT WERKS, MATNR, F_LENGTH, T_LENGTH, DRUMNR
    FROM @GT_T2430 AS A
   WHERE MATNR  NE @SPACE
     AND DRUMNR NE @SPACE
   GROUP BY WERKS, MATNR, F_LENGTH, T_LENGTH, DRUMNR
  HAVING COUNT( * ) GT 1
    INTO TABLE @DATA(LT_T2430).

*// 기존 데이터 중복 해지.
  LOOP AT GT_T2430 REFERENCE INTO DATA(LR_T2430)
                   WHERE DUPLI EQ ABAP_TRUE.
    LR_T2430->DUPLI = ABAP_FALSE.
    DELETE LR_T2430->RETURN WHERE FIELD EQ GC_DUPLICATION.

    IF LR_T2430->RETURN IS INITIAL.
      CLEAR: LR_T2430->STATUS, LR_T2430->MESSAGE.
    ENDIF.
  ENDLOOP.

*// 중복 데이터 설정.
  LOOP AT LT_T2430 INTO DATA(LS_T2430).
    LOOP AT GT_T2430 REFERENCE INTO LR_T2430
                     WHERE MATNR    EQ LS_T2430-MATNR
                       AND F_LENGTH EQ LS_T2430-F_LENGTH
                       AND T_LENGTH EQ LS_T2430-T_LENGTH
                       AND DRUMNR   EQ LS_T2430-DRUMNR.
      LR_T2430->DUPLI  = ABAP_TRUE.
      LR_T2430->RETURN = VALUE #( BASE LR_T2430->RETURN ( TYPE = 'E' FIELD = GC_DUPLICATION MESSAGE = TEXT-E18 ) ).
      IF LINES( LR_T2430->RETURN ) EQ 1.
        LR_T2430->STATUS  = ICON_LED_RED.
        LR_T2430->MESSAGE = LR_T2430->RETURN[ 1 ]-MESSAGE.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar_in_slord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR_IN_SLORD  USING PR_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  DATA(LV_NBSP) = CL_ABAP_CONV_IN_CE=>UCCP( '00A0' ).

*  PR_OBJECT->MT_TOOLBAR = VALUE #( BASE PR_OBJECT->MT_TOOLBAR
*                                  ( BUTN_TYPE = 3 )
*                                  ( FUNCTION  = GC_FCODE-NO_ALLOC
*                                    ICON      = ICON_DEFECT
*                                    TEXT      = |{ TEXT-B10 } { LV_NBSP } { LV_NBSP }|
*                                    QUICKINFO = |{ TEXT-B10 } { LV_NBSP } { LV_NBSP }| ) ).
*                                  ( FUNCTION  = GC_FCODE-OM_ASSIGN
*                                    ICON      = ICON_COMPLETE
*                                    TEXT      = |{ TEXT-B11 } { LV_NBSP } { LV_NBSP }|
*                                    QUICKINFO = |{ TEXT-B11 } { LV_NBSP } { LV_NBSP }| ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_slord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM USER_COMMAND_IN_SLORD  USING  PV_UCOMM.

  CASE PV_UCOMM.
    WHEN GC_FCODE-NO_ALLOC.    "// 주문 할당 불가.
      PERFORM USER_COMMAND_NO_ALLOC.

    WHEN GC_FCODE-OM_ASSIGN.   "// (OM) 할당 완료.
      PERFORM USER_COMMAND_OM_ASSIGN.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_no_alloc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_NO_ALLOC .

  TRY.
      PERFORM CHECK_BEFORE_NO_ALLOC. "// 사전점검.
      PERFORM RUN_NO_ALLOC.          "// 주문 할당 불가.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_no_alloc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_NO_ALLOC RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  GR_SLORD->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  DATA(LV_LINES) = LINES( LT_ROWS ).

  IF LV_LINES IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E19.
  ELSEIF LV_LINES NE 1.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E20.
  ELSE.
    DATA(LS_ROW) = LT_ROWS[ 1 ].
    DATA(LR_SLORD) = REF #( GT_SLORD[ LS_ROW-INDEX ] OPTIONAL ).
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C10 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  MODIFY GT_SLORD FROM VALUE #( SEL = ABAP_FALSE )
                 TRANSPORTING SEL
                 WHERE SEL EQ ABAP_TRUE.

  LR_SLORD->SEL = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form run_no_alloc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM RUN_NO_ALLOC .
  DATA LV_TYPE    TYPE BAPI_MTYPE.
  DATA LV_MESSAGE TYPE BAPI_MSG.

  DATA(LR_SLORD) = REF #( GT_SLORD[ SEL = ABAP_TRUE ] OPTIONAL ).

  "FIXMG 설정값 추출
  SELECT SINGLE FIXMG
    FROM VBAP
   WHERE VBELN EQ @LR_SLORD->VBELN
     AND POSNR EQ @LR_SLORD->POSNR
    INTO @DATA(LV_FIXMG).

  CALL FUNCTION 'ZGTSD_RECEIVE_STOCK_LINK_INFO'
    EXPORTING
      I_VBELN = LR_SLORD->VBELN
      I_POSNR = LR_SLORD->POSNR
      I_MVGR3 = SPACE
      I_LIFSP = 'G2'
      I_FIXMG = LV_FIXMG  "OM/SM 구분자
    IMPORTING
      E_TYPE  = LV_TYPE
      E_MSG   = LV_MESSAGE.

  IF LV_TYPE EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
    DELETE GT_SLORD WHERE SEL EQ ABAP_TRUE.
    GR_SLORD->REFRESH( ).
  ENDIF.

  MESSAGE S000 WITH LV_MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_drum_default_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_DRUM_DEFAULT_VALUE  USING PS_SLORD TYPE TY_S_SLORD
                                   PS_WKORD TYPE TY_S_WKORD
                                   PT_CONFG TYPE TY_T_CONFG.

  CASE P_WERKS.
    WHEN GC_WERKS-6500.
      PERFORM SET_DRUM_DEFAULT_VALUE_6500 USING PS_SLORD PS_WKORD PT_CONFG.

    WHEN GC_WERKS-6600.
      PERFORM SET_DRUM_DEFAULT_VALUE_6600 USING PS_SLORD PS_WKORD PT_CONFG.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_vc_configuration
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_VC_CONFIGURATION  USING PV_INSTANCE TYPE INOB-CUOBJ
                                 PT_CONFG    TYPE TY_T_CONFG.

  CLEAR PT_CONFG.

  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      INSTANCE            = PV_INSTANCE
    TABLES
      CONFIGURATION       = PT_CONFG
    EXCEPTIONS
      INSTANCE_NOT_FOUND  = 1
      INTERNAL_ERROR      = 2
      NO_CLASS_ALLOCATION = 3
      INSTANCE_NOT_VALID  = 4
      OTHERS              = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_drum_code_pp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_DRUM_CODE_PP TABLES PT_RETURN STRUCTURE ZGTEDSIF0038
                       USING PS_DRUM_CODE TYPE TY_S_DRUM_CODE.

  CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
    EXPORTING
      IV_SUL_NO    = PS_DRUM_CODE-SUL_NO
      IV_REV_SEQ   = PS_DRUM_CODE-REVNO
      IV_JAKNO     = CONV KDKG4( PS_DRUM_CODE-ZZYUSCD )
      IV_JOJANG    = CONV CHAR6( PS_DRUM_CODE-JOJANG )
      IV_DRUM_CODE = PS_DRUM_CODE-DRUM_CODE
      IV_FLAG_PP   = ABAP_TRUE
    TABLES
      OT_RETURN    = PT_RETURN[].

  DELETE PT_RETURN WHERE DRUM_CODE EQ ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_drum_default_value_6500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_DRUM_DEFAULT_VALUE_6500  USING PS_SLORD TYPE TY_S_SLORD
                                        PS_WKORD TYPE TY_S_WKORD
                                        PT_CONFG TYPE TY_T_CONFG.

  DATA LS_DRUM_CODE TYPE TY_S_DRUM_CODE.
  DATA LT_RETURN TYPE TABLE OF ZGTEDSIF0038.
  DATA LS_RET TYPE ZGTEDSIF0038.

  CHECK PS_WKORD-ZORD_TYPE EQ ZGTPP_IF_CONST=>GC_ZORD_TYPE-C1.
*  CHECK PS_SLORD-CUOBF IS NOT INITIAL.

*  LS_DRUM_CODE-SUL_NO = VALUE #( PT_CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_CA_DESIGN_NO ]-ATWRT OPTIONAL ).
  LS_DRUM_CODE-SUL_NO = VALUE #( GT_CLOBJDAT[ ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_CA_DESIGN_NO ]-AUSP1 OPTIONAL ).

  CHECK LS_DRUM_CODE-SUL_NO IS NOT INITIAL.

*  LS_DRUM_CODE-REVNO = VALUE #( PT_CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_CA_DESIGN_REV_NO ]-ATWRT OPTIONAL ).
  LS_DRUM_CODE-REVNO = VALUE #( GT_CLOBJDAT[ ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_CA_DESIGN_REV_NO ]-AUSP1 OPTIONAL ).

  CALL FUNCTION 'ZGTSD_GET_ZZYUSCD'
    EXPORTING
      I_VKORG   = PS_SLORD-VKORG
      I_VKGRP   = PS_SLORD-VKGRP
      I_KDKG4   = '00'
    IMPORTING
      E_ZZYUSCD = LS_DRUM_CODE-ZZYUSCD.

  LS_DRUM_CODE-JOJANG = TRUNC( PS_WKORD-ZCUT_LEN ).

*  NEW zgtpp_cl_conv( )->convert_string_to_qty( EXPORTING iv_input  = CONV #( VALUE #( ps_slord-confg[ KEY skey1 atnam = zgtpp_if_const=>gc_atnam-sap_millca_length ]-atwrt OPTIONAL ) )
*                                               IMPORTING ev_output = ls_drum_code-jojang ).

  IF PS_SLORD-DRUM_GUBUN EQ 'PL'.
    CLEAR: LS_RET.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT        = PS_SLORD-PK_DRUM
      IMPORTING
        OUTPUT       = LS_RET-DRUM_MATNR
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.

    APPEND LS_RET TO LT_RETURN.
  ENDIF.

  IF LT_RETURN IS INITIAL.
    LS_DRUM_CODE-DRUM_CODE = 'D'.
    PERFORM GET_DRUM_CODE_PP TABLES LT_RETURN USING LS_DRUM_CODE.
  ENDIF.

  IF LT_RETURN IS INITIAL.
    LS_DRUM_CODE-DRUM_CODE = 'H'.
    PERFORM GET_DRUM_CODE_PP TABLES LT_RETURN USING LS_DRUM_CODE.
  ENDIF.

  DATA(LS_RETURN) = VALUE #( LT_RETURN[ 1 ] OPTIONAL ).

  CHECK LS_RETURN-DRUM_MATNR IS NOT INITIAL.

  PS_WKORD-DRMAT = LS_RETURN-DRUM_MATNR.

  READ TABLE GT_ZGTPPT2420 INTO DATA(LS_ZGTPPT2420) WITH KEY WERKS     = P_WERKS
                                                             FROM_DRUM = PS_WKORD-DRMAT BINARY SEARCH.
  IF SY-SUBRC IS INITIAL.
    PS_WKORD-DRMAT = LS_ZGTPPT2420-TO_DRUM.
  ENDIF.

  SELECT SINGLE MAKT~MAKTX, MARA~MEINS, MARC~LGPRO
    INTO (@PS_WKORD-DRTXT,@PS_WKORD-DRMEI,@PS_WKORD-LGORT)
    FROM MARA
    JOIN MARC
      ON MARA~MATNR EQ MARC~MATNR
     AND MARC~WERKS EQ @P_WERKS
    JOIN MAKT
      ON MARA~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   WHERE MARA~MATNR EQ @PS_WKORD-DRMAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_drum_default_value_6600
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_DRUM_DEFAULT_VALUE_6600  USING PS_SLORD TYPE TY_S_SLORD
                                        PS_WKORD TYPE TY_S_WKORD
                                        PT_CONFG TYPE TY_T_CONFG.

  DATA LS_DRUM_CODE TYPE TY_S_DRUM_CODE.
  DATA LT_RETURN TYPE TABLE OF ZGTEDSIF0038.

  CHECK PS_WKORD-ZORD_TYPE EQ ZGTPP_IF_CONST=>GC_ZORD_TYPE-C1.
*  CHECK PS_SLORD-CUOBF IS NOT INITIAL.

*  LS_DRUM_CODE-SUL_NO = VALUE #( PT_CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_CA_DESIGN_NO ]-ATWRT OPTIONAL ).
  LS_DRUM_CODE-SUL_NO = VALUE #( GT_CLOBJDAT[ ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_CA_DESIGN_NO ]-AUSP1 OPTIONAL ).

  CHECK LS_DRUM_CODE-SUL_NO IS NOT INITIAL.

*  LS_DRUM_CODE-REVNO = VALUE #( PT_CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_CA_DESIGN_REV_NO ]-ATWRT OPTIONAL ).
  LS_DRUM_CODE-REVNO = VALUE #( GT_CLOBJDAT[ ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-PD_CA_DESIGN_REV_NO ]-AUSP1 OPTIONAL ).

  CALL FUNCTION 'ZGTSD_GET_ZZYUSCD'
    EXPORTING
      I_VKORG   = PS_SLORD-VKORG
      I_VKGRP   = PS_SLORD-VKGRP
      I_KDKG4   = '00'
    IMPORTING
      E_ZZYUSCD = LS_DRUM_CODE-ZZYUSCD.

  LS_DRUM_CODE-JOJANG = TRUNC( PS_WKORD-ZCUT_LEN ).

*  NEW zgtpp_cl_conv( )->convert_string_to_qty( EXPORTING iv_input  = CONV #( VALUE #( ps_slord-confg[ KEY skey1 atnam = zgtpp_if_const=>gc_atnam-sap_millca_length ]-atwrt OPTIONAL ) )
*                                               IMPORTING ev_output = ls_drum_code-jojang ).

  LS_DRUM_CODE-DRUM_CODE = 'D'.
  PERFORM GET_DRUM_CODE_PP TABLES LT_RETURN USING LS_DRUM_CODE.

  DATA(LS_RETURN) = VALUE #( LT_RETURN[ 1 ] OPTIONAL ).

  CHECK LS_RETURN-DRUM_MATNR IS NOT INITIAL.

  PS_WKORD-DRMAT = LS_RETURN-DRUM_MATNR.

  IF LS_DRUM_CODE-JOJANG LE '5000'.
    LOOP AT GT_ZGTPPT2430 INTO DATA(LS_ZGTPPT2430)
                          WHERE WERKS    EQ P_WERKS
                            AND MATNR    EQ PS_SLORD-MATNR
                            AND F_LENGTH LE LS_DRUM_CODE-JOJANG
                            AND T_LENGTH GE LS_DRUM_CODE-JOJANG.
      IF LS_ZGTPPT2430-DRUMNR IS NOT INITIAL.
        PS_WKORD-DRMAT = LS_ZGTPPT2430-DRUMNR.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SELECT SINGLE MAKT~MAKTX, MARA~MEINS, MARC~LGPRO
    INTO (@PS_WKORD-DRTXT,@PS_WKORD-DRMEI,@PS_WKORD-LGORT)
    FROM MARA
    JOIN MARC
      ON MARA~MATNR EQ MARC~MATNR
     AND MARC~WERKS EQ @P_WERKS
    JOIN MAKT
      ON MARA~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   WHERE MARA~MATNR EQ @PS_WKORD-DRMAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_sales_order_allocation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_SALES_ORDER_ALLOCATION USING PT_ZGTPPT2170 TYPE TY_T_ZGTPPT2170.

  CLEAR: GS_RESULT, GT_FXLEN.

  SELECT DISTINCT ZT02~*
    FROM @GT_ALLOC  AS ZT01
    JOIN ZGTPPT2170 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
   WHERE ZT01~SEL EQ @ABAP_TRUE
    INTO CORRESPONDING FIELDS OF TABLE @PT_ZGTPPT2170.

  LOOP AT GT_ALLOC INTO DATA(LS_ALLOC)
                  WHERE SEL EQ ABAP_TRUE
                  GROUP BY LS_ALLOC-ZASSIGN_NO.
    GS_RESULT-TOTAL += 1.

*// 판매오더품목 납품보류 업데이트.
    PERFORM SET_SALES_ORDER_DLV_BLOCK USING LS_ALLOC.

    IF LS_ALLOC-ZUPT_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
      MODIFY PT_ZGTPPT2170 FROM VALUE #( LOEKZ     = ABAP_TRUE
                                         ZUPT_STAT = LS_ALLOC-ZUPT_STAT
                                         ZUPT_MSG  = LS_ALLOC-ZUPT_MSG
                                         CHDAT     = GS_ZGTPPS1001-CHDAT
                                         CHTIM     = GS_ZGTPPS1001-CHTIM
                                         CHNAM     = GS_ZGTPPS1001-CHNAM )
                           USING KEY SKEY1
                           TRANSPORTING LOEKZ ZUPT_STAT ZUPT_MSG CHDAT CHTIM CHNAM
                           WHERE ZASSIGN_NO EQ LS_ALLOC-ZASSIGN_NO.
      GS_RESULT-SUCCESS += 1.

      IF LS_ALLOC-ZORD_TYPE EQ ZGTPP_IF_CONST=>GC_ZORD_TYPE-C0. "// 정조장.
        APPEND VALUE #( WERKS = LS_ALLOC-WERKS
                        MATNR = LS_ALLOC-MATNR
                        CHARG = LS_ALLOC-F_CHARG ) TO GT_FXLEN.
      ENDIF.
    ELSE.
      GS_RESULT-ERROR += 1.
    ENDIF.
  ENDLOOP.

  MODIFY ZGTPPT2170 FROM TABLE PT_ZGTPPT2170.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_OM_ASSIGN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_OM_ASSIGN .

  TRY.
      PERFORM CHECK_BEFORE_OM_ASSIGN. "// 사전점검.
      PERFORM RUN_OM_ASSING.          "// 주문 할당.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BEFORE_OM_ASSIGN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_OM_ASSIGN RAISING LCX_EXCEPTION.

  DATA LV_ANSWER TYPE C.

  GR_SLORD->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  DATA(LV_LINES) = LINES( LT_ROWS ).

  IF LV_LINES IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E19.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_SLORD REFERENCE INTO DATA(LR_SLORD) INDEX LS_ROW-INDEX.

    CHECK SY-SUBRC IS INITIAL.

    IF LR_SLORD->KALAB < LR_SLORD->WEMENG.
      "판매오더 재고가 납품수량만큼 할당된 경우에만 주문 할당 완료 처리 가능합니다.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E30.
    ENDIF.

    LR_SLORD->SEL = ABAP_TRUE.
  ENDLOOP.

  PERFORM CONFIRMATION_POPUP USING TEXT-C18 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_OM_ASSING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RUN_OM_ASSING .

  DATA LV_TYPE    TYPE BAPI_MTYPE.
  DATA LV_MESSAGE TYPE BAPI_MSG.

  LOOP AT GT_SLORD REFERENCE INTO DATA(LR_SLORD)
                   WHERE SEL EQ ABAP_TRUE.

    "FIXMG 설정값 추출
    SELECT SINGLE FIXMG
      FROM VBAP
     WHERE VBELN EQ @LR_SLORD->VBELN
       AND POSNR EQ @LR_SLORD->POSNR
      INTO @DATA(LV_FIXMG).

    CLEAR: LV_TYPE, LV_MESSAGE.
    CALL FUNCTION 'ZGTSD_RECEIVE_STOCK_LINK_INFO'
      EXPORTING
        I_VBELN = LR_SLORD->VBELN
        I_POSNR = LR_SLORD->POSNR
        I_MVGR3 = SPACE
        I_LIFSP = LV_FIXMG
      IMPORTING
        E_TYPE  = LV_TYPE
        E_MSG   = LV_MESSAGE.

    IF LV_TYPE EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS.
      CLEAR: LR_SLORD->SEL.
    ENDIF.

  ENDLOOP.

  GR_SLORD->REFRESH( ).

  DATA(LV_CHK) = VALUE #( GT_SLORD[ SEL = ABAP_TRUE ]-SEL OPTIONAL ).

  IF LV_CHK IS INITIAL.
    MESSAGE S000 WITH '성공'.
  ELSE.
    MESSAGE S000 WITH LV_MESSAGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CLASSIFICATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LR_SLORD_>MATNR
*&      --> LT_CONFG
*&---------------------------------------------------------------------*
FORM GET_CLASSIFICATION  USING    PV_MATNR TYPE MATNR.

  CLEAR: GV_OBJECT.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = PV_MATNR
    IMPORTING
      OUTPUT       = GV_OBJECT
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.

  "자재에 할당된 CLASS의 특성값 추출
  CLEAR: GT_SCLASS, GT_CLOBJDAT.
  CALL FUNCTION 'CLAF_CLASSIFICATION_OF_OBJECTS'
    EXPORTING
      CLASSTYPE          = '001'     "-. Class Type
      OBJECT             = GV_OBJECT "-. 자재
      INITIAL_CHARACT    = SPACE     "-. space
      NO_VALUE_DESCRIPT  = 'X'       "-. 'X'
    TABLES
      T_CLASS            = GT_SCLASS
      T_OBJECTDATA       = GT_CLOBJDAT
    EXCEPTIONS
      NO_CLASSIFICATION  = 1
      NO_CLASSTYPES      = 2
      INVALID_CLASS_TYPE = 3
      OTHERS             = 4.

  SORT GT_CLOBJDAT BY ATNAM.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_XC_UPDATE_ALLOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_XC_UPDATE_ALLOC .

  TRY.
      PERFORM CHECK_BEFORE_XC_UPDATE_ALLOC.  "// 사전점검.
      PERFORM XC_UPDATE_ALLOCATION.          "// 삭제/완료 업데이트.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BEFORE_XC_UPDATE_ALLOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_XC_UPDATE_ALLOC RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  PERFORM GET_ROWS_SELECTED_XC_UPD_ALLOC.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E31.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
  ENDIF.

  CLEAR: GV_XC.
  CALL SCREEN '0300' STARTING AT 20 10 ENDING AT 50 10.

  PERFORM CONFIRMATION_POPUP USING TEXT-C19 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ROWS_SELECTED_XC_UPD_ALLOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_XC_UPD_ALLOC .

  CLEAR GS_RESULT.

  MODIFY GT_ALLOC FROM VALUE #( SEL = ABAP_FALSE )
                  TRANSPORTING SEL
                  WHERE SEL EQ ABAP_TRUE.

  GR_ALLOC->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

*// 선택된 데이터 유효성 점검.
  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_ALLOC REFERENCE INTO DATA(LR_ALLOC) INDEX LS_ROW-INDEX.

    CHECK SY-SUBRC IS INITIAL.

    GS_RESULT-SEL += 1.
    GS_RESULT-TOTAL += 1.

    LR_ALLOC->SEL = ABAP_TRUE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form XC_UPDATE_ALLOCATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM XC_UPDATE_ALLOCATION .

  CLEAR: GS_RESULT.

  LOOP AT GT_ALLOC REFERENCE INTO DATA(LR_ALLOC)
                   WHERE SEL EQ ABAP_TRUE
                   GROUP BY LR_ALLOC->ZASSIGN_NO.
    GS_RESULT-TOTAL += 1.

    UPDATE ZGTPPT2170 SET LOEKZ = GV_XC
                    WHERE ZASSIGN_NO = LR_ALLOC->ZASSIGN_NO.

    IF SY-SUBRC EQ 0.
      GS_RESULT-SUCCESS += 1.

      MODIFY GT_ALLOC FROM VALUE #( LOEKZ = GV_XC )
                      TRANSPORTING LOEKZ
                      WHERE ZASSIGN_NO EQ LR_ALLOC->ZASSIGN_NO.

    ELSE.
      GS_RESULT-ERROR += 1.
    ENDIF.
  ENDLOOP.

  GR_ALLOC->REFRESH( ).

  MESSAGE S009 WITH GS_RESULT-TOTAL GS_RESULT-SUCCESS GS_RESULT-ERROR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_SESSION_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM USER_SESSION_CHECK .
  DATA: LT_USER_INFO TYPE TABLE OF UINFO2,
        LV_MSG       TYPE STRING.

  "USER가 여러 SESSION으로 작업 방지
  CLEAR: LT_USER_INFO.
  CALL FUNCTION 'TH_LONG_USR_INFO'
    EXPORTING
      USER      = SY-UNAME
    TABLES
      USER_INFO = LT_USER_INFO.

  DATA(LV_CNT) = REDUCE I(
                 INIT SUM = 0 FOR LS_CNT IN LT_USER_INFO
                 WHERE ( TCODE = 'ZGTPPR2160' )
                 NEXT SUM = SUM + 1 ).

  IF LV_CNT > 1.
    CLEAR: LV_MSG.
    CONCATENATE SY-UNAME TEXT-T43 INTO LV_MSG SEPARATED BY SPACE.
    MESSAGE S005 DISPLAY LIKE 'E' WITH LV_MSG.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_PROCESSING_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_PROCESSING_CANCEL .

*// 절단 작업 지시.
  PERFORM GET_CUTTING_CANCEL.

*// 주문 할당.
  PERFORM GET_ALLOCTION_CANCEL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CUTTING_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CUTTING_CANCEL .

  DATA LT_CUTTING TYPE TABLE OF TY_S_CUTTING.
  DATA LV_ORD_ITEM(4).

  SELECT ZT01~ZCUT_ORD_NO,  ZT01~ZCUT_ORD_ITEM, ZT01~LOEKZ,
         ZT01~T_CHARG,      ZT01~ZCUT_LEN,      ZT01~ZCUT_CNT,   ZT01~MULTI_YN, ZT01~ORG_LENGTH,
         ZT01~ZCUT_MBLNR,   ZT01~ZCUT_MJAHR,    ZT01~ZCUT_ZEILE, ZT01~SOBKZ,  ZT01~PRINT_STAT,
         ZT02~ZASSIGN_NO,   ZT02~ZASSIGN_TYPE,  ZT02~WERKS,      ZT02~VBELN,  ZT02~POSNR,
         ZT02~ETENR,        ZT02~EDATU,         ZT02~WEMENG,     ZT02~VRKME,  ZT02~WELENG,
         ZT02~WECNT,        ZT02~MATNR,         ZT02~ZUPT_STAT,  ZT02~ZUPT_MSG,
         ZT02~CRDAT,        ZT02~CRTIM,         ZT02~CRNAM,
         ZT03~ZASSIGN_ITEM, ZT03~LGORT,         ZT03~F_CHARG,    ZT03~F_CHARG_ORG,
         ZT03~LABST1,       ZT03~LABST2,        ZT03~LABST3,     ZT03~ZORD_TYPE,
         ZT04~ZDR_MBLNR,    ZT04~ZDR_MJAHR,     ZT04~ZDR_ZEILE,
         MAKT~MAKTX,
         DD07T~DDTEXT AS ZORD_TYPE_TXT,
         CASE WHEN ZT01~ZCUT_MBLNR IS NOT INITIAL AND ZT04~ZDR_MBLNR IS NOT INITIAL THEN @ICON_LED_GREEN
              WHEN ZT01~ZCUT_MBLNR IS NOT INITIAL OR  ZT04~ZDR_MBLNR IS NOT INITIAL THEN @ICON_LED_YELLOW
              ELSE @SPACE
         END AS ZGR_STAT
    FROM ZGTPPT2190 AS ZT01
    JOIN ZGTPPT2170 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
    JOIN ZGTPPT2180 AS ZT03
      ON ZT01~ZASSIGN_NO   EQ ZT03~ZASSIGN_NO
     AND ZT01~ZASSIGN_ITEM EQ ZT03~ZASSIGN_ITEM
    LEFT JOIN ZGTPPT2191 AS ZT04
      ON ZT01~ZCUT_ORD_NO   EQ ZT04~ZCUT_ORD_NO
     AND ZT01~ZCUT_ORD_ITEM EQ ZT04~ZCUT_ORD_ITEM
    JOIN MARC
      ON ZT02~MATNR EQ MARC~MATNR
     AND ZT02~WERKS EQ MARC~WERKS
    JOIN MARA
      ON MARC~MATNR EQ MARA~MATNR
    LEFT JOIN MAKT
      ON MARA~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
    LEFT JOIN DD07L
      ON DD07L~DOMNAME  EQ 'ZGTDZORD_TYPE'
     AND DD07L~AS4LOCAL EQ 'A'
     AND ZT03~ZORD_TYPE EQ DD07L~DOMVALUE_L
    LEFT JOIN DD07T
      ON DD07L~DOMNAME    EQ DD07T~DOMNAME
     AND DD07L~VALPOS     EQ DD07T~VALPOS
     AND DD07L~AS4LOCAL   EQ DD07T~AS4LOCAL
     AND DD07T~DDLANGUAGE EQ @SY-LANGU
   WHERE ZT01~WERKS   EQ @P_WERKS
     AND ZT03~F_CHARG EQ @P_FCHARG
   ORDER BY ZT01~ZCUT_ORD_NO, ZT01~ZCUT_ORD_ITEM
    INTO CORRESPONDING FIELDS OF TABLE @GT_CUTTING.

  IF GT_CUTTING IS NOT INITIAL.
    SELECT DISTINCT ZT01~VBELN, ZT01~POSNR
      INTO TABLE @DATA(LT_ZLET0401)
      FROM ZLET0401 AS ZT01
       FOR ALL ENTRIES IN @GT_CUTTING
     WHERE VBELN EQ @GT_CUTTING-VBELN
       AND POSNR EQ @GT_CUTTING-POSNR
       AND LVORM EQ @SPACE.

    SORT LT_ZLET0401 BY VBELN POSNR.
  ENDIF.

  LOOP AT GT_CUTTING REFERENCE INTO DATA(LR_CUTTING).
    "출하요청
    READ TABLE LT_ZLET0401 TRANSPORTING NO FIELDS WITH KEY VBELN = LR_CUTTING->VBELN
                                                           POSNR = LR_CUTTING->POSNR BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      LR_CUTTING->SHREQ = ICON_LED_GREEN.
    ENDIF.

    IF LR_CUTTING->ZUPT_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      LR_CUTTING->STATUS = ICON_LED_RED.
      LR_CUTTING->RETURN = VALUE #( ( TYPE = 'E' FIELD = TEXT-F01 MESSAGE = LR_CUTTING->ZUPT_MSG )  ).
    ENDIF.

    "배치번호(실제), 절단전기일자
    SELECT SINGLE CHARG, BUDAT
      FROM MATDOC
     WHERE MBLNR EQ @LR_CUTTING->ZCUT_MBLNR
       AND MJAHR EQ @LR_CUTTING->ZCUT_MJAHR
       AND SHKZG EQ 'H'
      INTO (@LR_CUTTING->A_CHARG, @LR_CUTTING->ZCUT_BUDAT).

    "절단실제조장
    SELECT SINGLE ERFMG
      FROM MATDOC
     WHERE MBLNR EQ @LR_CUTTING->ZCUT_MBLNR
       AND MJAHR EQ @LR_CUTTING->ZCUT_MJAHR
      INTO @LR_CUTTING->ZCUT_RLEN.

    IF LR_CUTTING->ZCUT_RLEN NE 0.
      IF LR_CUTTING->ZCUT_LEN EQ LR_CUTTING->ZCUT_RLEN.
        LR_CUTTING->ZCUT_LEN_STAT = ICON_EQUAL_GREEN.
      ELSE.
        LR_CUTTING->ZCUT_LEN_STAT = ICON_NOT_EQUAL_RED.
      ENDIF.
    ENDIF.

    "라벨발행
    IF LR_CUTTING->PRINT_STAT EQ 'Y'.
      LR_CUTTING->PRINT_STAT_TXT = ICON_LED_RED.
    ENDIF.

    "절단 스크랩
    CLEAR: LV_ORD_ITEM.
    LV_ORD_ITEM = LR_CUTTING->ZCUT_ORD_ITEM.

    SELECT ZMODE, WERKS, MATNR, CHARG, MENGE, MEINS, ZSTAT
      FROM ZGTPPT3450
     WHERE AUFNR EQ @LR_CUTTING->ZCUT_ORD_NO
       AND ZCUT_ORD_ITEM EQ @LV_ORD_ITEM
       AND ZERP_STAT EQ 'S'
      INTO TABLE @DATA(LT_3450).

    LOOP AT LT_3450 INTO DATA(LS_3450).
      IF LS_3450-ZMODE EQ 'TC'.
        LS_3450-MENGE = LS_3450-MENGE * ( -1 ).
      ENDIF.

      LR_CUTTING->ZCUT_SCRAP = LR_CUTTING->ZCUT_SCRAP + LS_3450-MENGE.
      CLEAR: LS_3450.
    ENDLOOP.

    "실적등록 체크 추가
    IF LR_CUTTING->ZGR_STAT EQ SPACE AND LR_CUTTING->ZCUT_SCRAP GT 0.
      LR_CUTTING->ZGR_STAT = ICON_LED_GREEN.
    ENDIF.

  ENDLOOP.

  "취소할 절단지시번호 외 다른 품목에 절단자재문서가 존재하는 경우 체크
  CLEAR: LT_CUTTING.
  APPEND LINES OF GT_CUTTING TO LT_CUTTING.
  DELETE LT_CUTTING WHERE ZCUT_MBLNR EQ SPACE.
  SORT LT_CUTTING BY ZCUT_ORD_NO.
  "절단지시번호 기준으로 절단전표번호가 있는 건만 추출
  DELETE ADJACENT DUPLICATES FROM LT_CUTTING COMPARING ZCUT_ORD_NO.

  LOOP AT GT_CUTTING ASSIGNING FIELD-SYMBOL(<FS_CT>).
    READ TABLE LT_CUTTING INTO DATA(LS_CT) WITH KEY ZCUT_ORD_NO = <FS_CT>-ZCUT_ORD_NO.
    IF SY-SUBRC EQ 0.
      <FS_CT>-CHK_CUTMBLNR = 'X'.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ALLOCTION_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ALLOCTION_CANCEL .

  DATA LT_ZASSIGN_NO TYPE RANGE OF ZGTPPT2170-ZASSIGN_NO.

  CLEAR GT_ALLOC.

  DATA(LT_CUTTING) = GT_CUTTING.
  SORT LT_CUTTING BY ZASSIGN_NO.
  DELETE ADJACENT DUPLICATES FROM LT_CUTTING COMPARING ZASSIGN_NO.

  IF S_ZASGNO[] IS NOT INITIAL OR S_ZCUTNO[] IS NOT INITIAL.
    LT_ZASSIGN_NO = S_ZASGNO[].

    IF GT_CUTTING[] IS NOT INITIAL.
      SELECT 'I' AS SIGN, 'EQ' AS OPTION , A~ZASSIGN_NO AS LOW
        FROM @GT_CUTTING AS A
       GROUP BY A~ZASSIGN_NO
   APPENDING CORRESPONDING FIELDS OF TABLE @LT_ZASSIGN_NO.
    ENDIF.

    IF LT_ZASSIGN_NO IS INITIAL.
      RETURN.
    ENDIF.
  ENDIF.

  SELECT ZT01~ZASSIGN_NO,   ZT01~ZASSIGN_TYPE, ZT01~WERKS,   ZT01~VBELN,  ZT01~POSNR,
         ZT01~ETENR,        ZT01~EDATU,        ZT01~WEMENG,  ZT01~VRKME,  ZT01~WELENG,
         ZT01~WECNT,        ZT01~MATNR,        ZT01~CRDAT,   ZT01~CRTIM,  ZT01~CRNAM,
         ZT01~ZUPT_STAT,    ZT01~ZUPT_MSG,     ZT01~LOEKZ,   ZT01~DRDAT,
         ZT02~ZASSIGN_ITEM, ZT02~LGORT,        ZT02~F_CHARG, ZT02~LABST3, ZT02~MEINS,
         ZT02~ZCUT_YN,      ZT02~ZCUT_CNT,     ZT02~ZREW_YN, ZT02~ZEXCLUDE,
         ZT02~ZORD_TYPE,    ZT02~F_CHARG_ORG,
         MARA~ZZSPEC_NO, MAKT~MAKTX,
         T001L~LGOBE,
         DD07T~DDTEXT  AS ZTYPE_DESC,
         DD07T2~DDTEXT AS ZORD_TYPE_TXT,
         CASE WHEN ZT03~ZCUT_ORD_NO IS NOT INITIAL THEN @ICON_LED_GREEN
         END AS ZSTAT
    FROM ZGTPPT2170 AS ZT01
    JOIN ZGTPPT2180 AS ZT02
      ON ZT01~ZASSIGN_NO EQ ZT02~ZASSIGN_NO
    JOIN MARC
      ON ZT01~MATNR EQ MARC~MATNR
     AND ZT01~WERKS EQ MARC~WERKS
    JOIN MARA
      ON MARC~MATNR EQ MARA~MATNR
    LEFT JOIN @LT_CUTTING AS ZT03
      ON ZT01~ZASSIGN_NO EQ ZT03~ZASSIGN_NO
    LEFT JOIN T001L
      ON ZT01~WERKS EQ T001L~WERKS
     AND ZT02~LGORT EQ T001L~LGORT
    LEFT JOIN MAKT
      ON ZT01~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
    LEFT JOIN DD07L
      ON DD07L~DOMNAME     EQ 'ZGTDZASSIGN_TYPE'
     AND DD07L~AS4LOCAL    EQ 'A'
     AND ZT01~ZASSIGN_TYPE EQ DD07L~DOMVALUE_L
    LEFT JOIN DD07T
      ON DD07L~DOMNAME    EQ DD07T~DOMNAME
     AND DD07L~VALPOS     EQ DD07T~VALPOS
     AND DD07L~AS4LOCAL   EQ DD07T~AS4LOCAL
     AND DD07T~DDLANGUAGE EQ @SY-LANGU
    LEFT JOIN DD07L AS DD07L2
      ON DD07L2~DOMNAME  EQ 'ZGTDZORD_TYPE'
     AND DD07L2~AS4LOCAL EQ 'A'
     AND ZT02~ZORD_TYPE  EQ DD07L2~DOMVALUE_L
    LEFT JOIN DD07T AS DD07T2
      ON DD07L2~DOMNAME    EQ DD07T2~DOMNAME
     AND DD07L2~VALPOS     EQ DD07T2~VALPOS
     AND DD07L2~AS4LOCAL   EQ DD07T2~AS4LOCAL
     AND DD07T2~DDLANGUAGE EQ @SY-LANGU
   WHERE ZT01~WERKS      EQ @P_WERKS
     AND ZT02~F_CHARG    EQ @P_FCHARG
   ORDER BY ZT01~ZASSIGN_NO, ZT02~ZASSIGN_ITEM, ZT01~VBELN, ZT01~POSNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_ALLOC.

  SELECT DISTINCT MATDOC~MAT_KDAUF, MATDOC~MAT_KDPOS
    FROM @GT_ALLOC AS ZT01
    JOIN MATDOC
      ON ZT01~VBELN EQ MATDOC~MAT_KDAUF
     AND ZT01~POSNR EQ MATDOC~MAT_KDPOS
     AND MATDOC~BWART EQ '413'
     AND CANCELLED    EQ @SPACE
     AND SHKZG        EQ 'H'
   ORDER BY MATDOC~MAT_KDAUF, MATDOC~MAT_KDPOS
    INTO TABLE @DATA(LT_MATDOC).

  IF GT_ALLOC IS NOT INITIAL.
    SELECT DISTINCT ZT01~VBELN, ZT01~POSNR, ZT02~DRDAT
      INTO TABLE @DATA(LT_ZLET0401)
      FROM ZLET0401 AS ZT01
      JOIN ZLET0400 AS ZT02 ON ZT02~DLVRQ EQ ZT01~DLVRQ
       FOR ALL ENTRIES IN @GT_ALLOC
     WHERE ZT01~VBELN EQ @GT_ALLOC-VBELN
       AND ZT01~POSNR EQ @GT_ALLOC-POSNR
       AND ZT01~LVORM EQ @SPACE.

    SORT LT_ZLET0401 BY VBELN POSNR.
  ENDIF.

  LOOP AT GT_ALLOC REFERENCE INTO DATA(LR_ALLOC).
    IF LR_ALLOC->VBELN IS NOT INITIAL.
      READ TABLE LT_MATDOC INTO DATA(LS_MATDOC) WITH KEY MAT_KDAUF = LR_ALLOC->VBELN
                                                         MAT_KDPOS = LR_ALLOC->POSNR BINARY SEARCH.
      IF SY-SUBRC IS INITIAL.
        LR_ALLOC->Z413 = ICON_LED_GREEN. "// 고객전용.
      ENDIF.
    ENDIF.

    IF LR_ALLOC->ZUPT_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      LR_ALLOC->STATUS = ICON_LED_RED.
      LR_ALLOC->RETURN = VALUE #( ( TYPE = 'E' FIELD = TEXT-F01 MESSAGE = LR_ALLOC->ZUPT_MSG ) ).
    ENDIF.

    "출하요청
    READ TABLE LT_ZLET0401 INTO DATA(LS_ZLET0401) WITH KEY VBELN = LR_ALLOC->VBELN
                                                           POSNR = LR_ALLOC->POSNR BINARY SEARCH.

    IF SY-SUBRC IS INITIAL.
      LR_ALLOC->SHREQ = ICON_LED_GREEN.
      LR_ALLOC->DRDAT = LS_ZLET0401-DRDAT.
    ENDIF.

    CLEAR: LS_ZLET0401.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_FCHARG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_FCHARG .

  IF P_CNCEL IS NOT INITIAL.
    IF P_FCHARG IS INITIAL.
      MESSAGE E003 DISPLAY LIKE 'S' WITH TEXT-M01.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_XMSG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> LV_MSGV
*&      --> P_
*&      --> TEXT_E12
*&      --> P_
*&---------------------------------------------------------------------*
FORM APPEND_XMSG  USING   P_MSGID    " LIKE sy-msgid
                          P_MSGTY    " LIKE sy-msgty
                          P_MSGNO    " LIKE sy-msgno
                          P_MSGV1    " LIKE sy-msgv1
                          P_MSGV2    " LIKE sy-msgv2
                          P_MSGV3    " LIKE sy-msgv3
                          P_MSGV4.   " LIKE sy-msgv4.
  CLEAR: WA_XMSG.

  WA_XMSG-MSGID = P_MSGID.
  WA_XMSG-MSGTY = P_MSGTY.
  WA_XMSG-MSGNO = P_MSGNO.
  WA_XMSG-MSGV1 = P_MSGV1.
  WA_XMSG-MSGV2 = P_MSGV2.
  WA_XMSG-MSGV3 = P_MSGV3.
  WA_XMSG-MSGV4 = P_MSGV4.
  APPEND WA_XMSG TO GT_XMSG.

ENDFORM.
