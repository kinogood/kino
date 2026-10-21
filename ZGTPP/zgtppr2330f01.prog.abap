*&---------------------------------------------------------------------*
*& Include          ZGTPPR2330F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INITIALIZATION.

  GT_ZGTPPT1010 = ZGTPP_CL_COMMON=>GET_CODE_VALUE( IV_CODEGRP = '2140' ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form start_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM START_OF_SELECTION.

  CASE ABAP_TRUE.
    WHEN P_PURORD.
*      PERFORM MAKE_DISP_DATA_PURORD.
      PERFORM MAKE_DISP_DATA_PURORD2.

    WHEN P_PR.
      PERFORM MAKE_DISP_DATA_PR.

    WHEN OTHERS.
      PERFORM MAKE_DISP_DATA_PRDORD.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form end_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM END_OF_SELECTION .

*  CASE ABAP_TRUE.
*    WHEN P_PURORD.
*
*      IF GT_LIST IS NOT INITIAL.
*        PERFORM CALL_SCREEN_100.
*      ELSE.
*        MESSAGE S033.
*        LEAVE LIST-PROCESSING.
*      ENDIF.
*    WHEN OTHERS.
  IF GT_MAIN_DISP_200 IS NOT INITIAL.
* 생산오더 선택에 자동지정 선택시 자동지정 적용하여 화면 디스플레이
    IF P_AUTO = ABAP_TRUE.
      CASE ABAP_TRUE.
        WHEN P_PRDORD.
          PERFORM PROC_AUTO_PRD.
        WHEN P_PURORD.
          PERFORM PROC_AUTO_PO.
        WHEN P_PR.
          PERFORM PROC_AUTO_PR.
      ENDCASE.
* 생산오더 배치모드 'O', 자동지정 'X'  실행시 조장구성테이블 기준으로 드럼재배치 - 20261007
    ELSEIF P_AUTO = ABAP_FALSE AND P_BATCH = ABAP_TRUE AND P_PRDORD = ABAP_TRUE.
      PERFORM PROC_BATCH_PRD.

    ENDIF.

    IF P_BATCH = ABAP_TRUE.
      MESSAGE S006 WITH '드럼 자동지정 되었습니다.'.
    ELSE.
      PERFORM CALL_SCREEN_200.
    ENDIF.
  ELSE.
    MESSAGE S033.
    LEAVE LIST-PROCESSING.
  ENDIF.


*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_exit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_EXIT .

  IF GR_ORDER IS BOUND.
    GR_LIST->FREE( ).
    CLEAR GR_ORDER.
  ENDIF.

  IF GR_LIST IS BOUND.
    GR_LIST->FREE( ).
    CLEAR GR_LIST.
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

  IF PR_SENDER EQ GR_ORDER.
    PERFORM MODIFY_FCAT_IN_ORDER.
  ENDIF.

  IF PR_SENDER EQ GR_LIST.
    PERFORM MODIFY_FCAT_IN_LIST.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_LAYOUT USING PR_SENDER.

  IF PR_SENDER EQ GR_ORDER.
    PERFORM SET_LAYOUT_IN_ORDER.
  ENDIF.

  IF PR_SENDER EQ GR_LIST.
    PERFORM SET_LAYOUT_IN_LIST.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form at_selection_screen_output
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM AT_SELECTION_SCREEN_OUTPUT .

  LOOP AT SCREEN INTO DATA(LS_SCREEN).
    CASE LS_SCREEN-GROUP1.
      WHEN 'SLS'.
        LS_SCREEN-ACTIVE = COND #( WHEN P_SLSORD EQ ABAP_TRUE THEN 1 ELSE 0 ).

      WHEN 'PRD'.
        LS_SCREEN-ACTIVE = COND #( WHEN P_PRDORD EQ ABAP_TRUE THEN 1 ELSE 0 ).

      WHEN 'PR'.
        LS_SCREEN-ACTIVE = COND #( WHEN P_PR EQ ABAP_TRUE THEN 1 ELSE 0 ).

      WHEN 'PUR'.
        LS_SCREEN-ACTIVE = COND #( WHEN P_PURORD EQ ABAP_TRUE THEN 1 ELSE 0 ).

      WHEN 'ATO'.
        LS_SCREEN-ACTIVE = COND #( WHEN P_SLSORD EQ ABAP_TRUE THEN 0 ELSE 1 ).

      WHEN 'TXT'.
        LS_SCREEN-INPUT = 0.
        LS_SCREEN-ACTIVE = COND #( WHEN P_SLSORD EQ ABAP_TRUE THEN 1 ELSE 0 ).
      WHEN 'S01'.
*        LS_SCREEN-ACTIVE = COND #( WHEN P_PRDORD EQ ABAP_TRUE OR P_PR EQ ABAP_TRUE THEN 0 ELSE 1 ).
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

  CASE ABAP_TRUE.
    WHEN P_SLSORD. "// 판매주문 기반.
      PERFORM GET_DATA_BASED_ON_SALES_ORDER.

    WHEN P_PRDORD. "// 생산오더 기반.
      PERFORM GET_DATA_BASED_ON_PROD_ORDER.

    WHEN P_PR. "// 생산오더 기반.
      PERFORM GET_DATA_BASED_ON_PR.

    WHEN P_PURORD. "// 구매오더 기반.
*      PERFORM GET_DATA_BASED_ON_PURCH_ORDER.
      PERFORM GET_DATA_BASED_ON_PURCH_ORDER2.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_screen_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_100 .

  GV_TPAR1 = COND #( WHEN P_SLSORD IS NOT INITIAL THEN TEXT-C11
                     WHEN P_PRDORD IS NOT INITIAL THEN TEXT-C12
                     WHEN P_PURORD IS NOT INITIAL THEN TEXT-C13 ).

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_based_on_sales_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_DATA_BASED_ON_SALES_ORDER .
  DATA LT_CLOBJDAT TYPE TT_CLOBJDAT.
  DATA LT_CONF TYPE TT_CONF_OUT.
  DATA LV_ZZYUSCD TYPE ZGTEYUSCD.
  DATA LV_ORDTP TYPE CHAR10.

  CLEAR: P_MATNR, P_DSGNO, P_REVNO, P_YUSCD, P_MILEN.

  IF P_VBELN IS INITIAL OR P_POSNR IS INITIAL.
    IF SSCRFIELDS-UCOMM EQ GC_FCODE-ONLI.
      MESSAGE E026 WITH TEXT-F20 DISPLAY LIKE 'S'.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

  IF P_DRUM IS INITIAL.
    IF SSCRFIELDS-UCOMM EQ GC_FCODE-ONLI.
      MESSAGE E026 WITH TEXT-F33 DISPLAY LIKE 'S'.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

  SELECT SINGLE VBAP~MATNR, VBAP~CUOBJ, VBAK~VKORG, VBAK~VKGRP, VBAP~WERKS
    INTO @DATA(LS_SALES)
    FROM VBAP
    JOIN VBAK
      ON VBAP~VBELN EQ VBAK~VBELN
   WHERE VBAP~VBELN EQ @P_VBELN
     AND VBAP~POSNR EQ @P_POSNR.

  IF SY-SUBRC IS NOT INITIAL AND SSCRFIELDS-UCOMM EQ GC_FCODE-ONLI.
    MESSAGE E000 WITH TEXT-E01 DISPLAY LIKE 'S'.
  ENDIF.

  READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS WITH KEY FLD_01 = LS_SALES-WERKS
                                                           FLD_02 = P_DRUM.
  IF SY-SUBRC IS NOT INITIAL.
    MESSAGE E000 WITH TEXT-E06 DISPLAY LIKE 'S'.
  ENDIF.

  P_MATNR = LS_SALES-MATNR.

  PERFORM GET_CLASSIFICATION USING LS_SALES-MATNR LT_CLOBJDAT.

  P_DSGNO = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_DESIGN_NO' ]-AUSP1 OPTIONAL ).
  P_REVNO = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_DESIGN_REV_NO' ]-AUSP1 OPTIONAL ).

  PERFORM GET_CONFIGURATION USING LS_SALES-CUOBJ LT_CONF.

  P_MILEN = VALUE #( LT_CONF[ ATNAM = 'SAP_MILLCA_LENGTH' ]-ATWRT OPTIONAL ).

  PERFORM GET_ZZYUSCD USING LS_SALES-VKORG LS_SALES-VKGRP LV_ZZYUSCD.

  P_YUSCD = LV_ZZYUSCD.

  CLEAR GS_HEADER_201.
  GS_HEADER_201-SUL_NO = P_DSGNO.
  GS_HEADER_201-REV_SEQ = P_REVNO.
  GS_HEADER_201-JAKNO = LV_ZZYUSCD.

  NEW ZGTPP_CL_CONV( )->CONVERT_STRING_TO_QTY( EXPORTING IV_INPUT  = CONV #( P_MILEN )
                                             IMPORTING EV_OUTPUT = GS_HEADER_201-JOJANG ).

  GS_HEADER_201-DRUM_CODE = P_DRUM.

  SELECT DISTINCT AUFNR, POSNR
    INTO TABLE @GT_AFPO
    FROM AFPO
   WHERE MATNR EQ @P_MATNR
     AND KDAUF EQ @P_VBELN
     AND KDPOS EQ @P_POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_based_on_prod_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_DATA_BASED_ON_PROD_ORDER .
  DATA LT_CLOBJDAT TYPE TT_CLOBJDAT.
  DATA LT_CONF TYPE TT_CONF_OUT.
  DATA LV_ZZYUSCD TYPE ZGTEYUSCD.
  DATA LV_ORDTP TYPE CHAR10.

  CLEAR: P_MATNR, P_DSGNO, P_REVNO, P_YUSCD, P_MILEN.

  IF S_AUFNR IS INITIAL.
    IF SSCRFIELDS-UCOMM EQ GC_FCODE-ONLI.
      MESSAGE E026 WITH TEXT-F31 DISPLAY LIKE 'S'.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

*  IF P_DRUM IS INITIAL.
*    IF SSCRFIELDS-UCOMM EQ GC_FCODE-ONLI.
*      MESSAGE E026 WITH TEXT-F33 DISPLAY LIKE 'S'.
*    ELSE.
*      RETURN.
*    ENDIF.
*  ENDIF.

  LV_ORDTP = TEXT-T20.

  SELECT DISTINCT AUFNR, POSNR
    INTO TABLE @GT_AFPO
    FROM AFPO
   WHERE AUFNR IN @S_AUFNR.

*  READ TABLE GT_MAIN_DISP_200 INTO DATA(LS_ORDER) INDEX 1.
*
*  READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS WITH KEY FLD_01 = LS_ORDER-WERKS
*                                                           FLD_02 = P_DRUM.
*  IF SY-SUBRC IS NOT INITIAL.
*    MESSAGE E000 WITH TEXT-E06 DISPLAY LIKE 'S'.
*  ENDIF.
*
*  P_MATNR = LS_ORDER-MATNR.
*
*  PERFORM GET_CLASSIFICATION USING LS_ORDER-MATNR LT_CLOBJDAT.
*
*  P_DSGNO = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_DESIGN_NO' ]-AUSP1 OPTIONAL ).
*  P_REVNO = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_DESIGN_REV_NO' ]-AUSP1 OPTIONAL ).
*
*  PERFORM GET_CONFIGURATION USING LS_ORDER-CUOBJ LT_CONF.
*
*  P_MILEN = VALUE #( LT_CONF[ ATNAM = 'SAP_MILLCA_LENGTH' ]-ATWRT OPTIONAL ).
*
*  PERFORM GET_ZZYUSCD USING LS_ORDER-VKORG LS_ORDER-VKGRP LV_ZZYUSCD.
*
*  P_YUSCD = LV_ZZYUSCD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_change
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_CHANGE .

  TRY.
      PERFORM CHECK_BEFORE_CHANGE_DRUM. "// 사전점검.
      PERFORM CHANGE_DRUM_ASSIGNMENT.   "// 드럼지정변경.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

  GR_ORDER->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_configuration
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_CONFIGURATION  USING PV_INSTANCE
                              PT_CONF TYPE TT_CONF_OUT.

  CLEAR PT_CONF.

  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      INSTANCE            = PV_INSTANCE
    TABLES
      CONFIGURATION       = PT_CONF
    EXCEPTIONS
      INSTANCE_NOT_FOUND  = 1
      INTERNAL_ERROR      = 2
      NO_CLASS_ALLOCATION = 3
      INSTANCE_NOT_VALID  = 4
      OTHERS              = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_zzyuscd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ZZYUSCD  USING PV_VKORG PV_VKGRP PV_ZZYUSCD.

  CALL FUNCTION 'ZGTSD_GET_ZZYUSCD'
    EXPORTING
      I_VKORG   = PV_VKORG
      I_VKGRP   = PV_VKGRP
      I_KDKG4   = '00'
    IMPORTING
      E_ZZYUSCD = PV_ZZYUSCD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_drum_assignment
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHANGE_DRUM_ASSIGNMENT .
  DATA LV_SYSTEM_ID TYPE CHAR4.

  DATA(LR_LIST) = REF #( GT_LIST[ CHECKED = ABAP_TRUE ] OPTIONAL ).

  DATA(LT_ZGTPPT1010) = ZGTPP_CL_COMMON=>GET_CODE_VALUE( IV_CODEGRP = '0010' ).

  READ TABLE LT_ZGTPPT1010 INTO DATA(LS_ZGTPPT1010) WITH KEY FLD_03 = LR_LIST->WERKS.
  IF SY-SUBRC IS INITIAL.
    LV_SYSTEM_ID = LS_ZGTPPT1010-FLD_01.
  ENDIF.

  LOOP AT GT_ORDER REFERENCE INTO DATA(LR_ORDER)
                   WHERE CHECKED EQ ABAP_TRUE.

    IF P_PURORD EQ ABAP_TRUE. "// 구매오더 기반.
      PERFORM CHANGE_PURCHASE_ORDER USING LR_ORDER->* LR_LIST->*.
    ELSE.
      PERFORM CALL_IF_I_GAON_PROD_BOM_CH USING LR_ORDER->* LR_LIST->* LV_SYSTEM_ID.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_change_drum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_CHANGE_DRUM  RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.
  DATA LV_MENGE  TYPE MARD-LABST.

  IF P_PURORD EQ ABAP_TRUE.
    GR_LIST->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

    IF LV_VALID NE ABAP_TRUE.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
    ENDIF.
  ENDIF.

  IF NOT LINE_EXISTS( GT_ORDER[ CHECKED = ABAP_TRUE ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E03.
  ENDIF.

  IF NOT LINE_EXISTS( GT_LIST[ CHECKED = ABAP_TRUE ] ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E03.
  ENDIF.


*  IF line_exists( gt_list[ checked = abap_true
*                            menge  = lv_menge ] ).
*    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e07.
*  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C02 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING PR_SENDER
                                 PS_ROW    TYPE LVC_S_ROID
                                 PS_COLUMN TYPE LVC_S_COL.

  IF PR_SENDER EQ GR_ORDER->MR_GRID.
    PERFORM HOTSPOT_CLICK_IN_ORDER USING PS_ROW PS_COLUMN.
  ENDIF.

  IF PR_SENDER EQ GR_LIST->MR_GRID.
    PERFORM HOTSPOT_CLICK_IN_LIST USING PS_ROW PS_COLUMN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_classification
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM GET_CLASSIFICATION  USING  PV_MATNR
                                PT_CLOBJDAT TYPE TT_CLOBJDAT.

  DATA LT_CLASS TYPE TABLE OF SCLASS.

  CALL FUNCTION 'CLAF_CLASSIFICATION_OF_OBJECTS'
    EXPORTING
      CLASSTYPE          = '001'
      OBJECT             = CONV CUOBN( PV_MATNR )
    TABLES
      T_CLASS            = LT_CLASS
      T_OBJECTDATA       = PT_CLOBJDAT
    EXCEPTIONS
      NO_CLASSIFICATION  = 1
      NO_CLASSTYPES      = 2
      INVALID_CLASS_TYPE = 3
      OTHERS             = 4.

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

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      MESSAGE LR_ROOT->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_ORDER .

  LOOP AT GR_ORDER->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'CHECKED'.
        LR_FCAT->COLTEXT    = TEXT-F51.
        LR_FCAT->HOTSPOT    = ABAP_TRUE.
        LR_FCAT->CHECKBOX   = ABAP_TRUE.

      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-F52.
        LR_FCAT->KEY        = ABAP_TRUE.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ORDTP'.
        LR_FCAT->COLTEXT    = TEXT-F62.
        LR_FCAT->KEY        = ABAP_TRUE.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ORDNR'.
        LR_FCAT->COLTEXT    = TEXT-F53.
        LR_FCAT->KEY        = ABAP_TRUE.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ITMNO'.
        LR_FCAT->COLTEXT    = TEXT-F63.
        LR_FCAT->KEY        = ABAP_TRUE.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F54.
        LR_FCAT->KEY        = ABAP_TRUE.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F55.
        LR_FCAT->KEY        = ABAP_TRUE.

      WHEN 'PSMNG'.
        LR_FCAT->COLTEXT    = TEXT-F56.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F57.

      WHEN 'IDNRK'.
        LR_FCAT->COLTEXT    = TEXT-F60.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'IDNTX'.
        LR_FCAT->COLTEXT    = TEXT-F61.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-F58.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ERFMG'.
        LR_FCAT->COLTEXT    = TEXT-F64.
        LR_FCAT->JUST       = 'R'.
        LR_FCAT->EDIT       = COND #( WHEN P_PURORD NE ABAP_TRUE  THEN ABAP_TRUE ).
        LR_FCAT->NO_OUT   = COND #( WHEN P_PURORD EQ ABAP_TRUE  THEN ABAP_TRUE ).

      WHEN 'ERFME'.
        LR_FCAT->COLTEXT    = TEXT-F65.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->NO_OUT   = COND #( WHEN P_PURORD EQ ABAP_TRUE  THEN ABAP_TRUE ).

      WHEN 'MESSAGE'.
        LR_FCAT->COLTEXT    = TEXT-F59.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

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
      WHEN 'CHECKED'.
        LR_FCAT->COLTEXT    = TEXT-F01.
        LR_FCAT->HOTSPOT    = ABAP_TRUE.
        LR_FCAT->CHECKBOX   = ABAP_TRUE.

      WHEN 'DRUM_CODE'.
        LR_FCAT->COLTEXT    = TEXT-F02.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F03.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'FLANG'.
        LR_FCAT->COLTEXT    = TEXT-F04.
        LR_FCAT->JUST       = 'C'.

      WHEN 'DONG'.
        LR_FCAT->COLTEXT    = TEXT-F05.
        LR_FCAT->JUST       = 'C'.

      WHEN 'NAEP'.
        LR_FCAT->COLTEXT    = TEXT-F06.
        LR_FCAT->JUST       = 'C'.

      WHEN 'SIDANGU'.
        LR_FCAT->COLTEXT    = TEXT-F07.
        LR_FCAT->JUST       = 'C'.

      WHEN 'DRUM_MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F08.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->EDIT       = 'X'.

      WHEN 'DRUM_TXT'.
        LR_FCAT->COLTEXT    = TEXT-F09.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'LABST'.
        LR_FCAT->COLTEXT    = TEXT-F10.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'MENGE'.
        LR_FCAT->COLTEXT    = TEXT-F15.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->EDIT       = COND #( WHEN P_PURORD EQ ABAP_TRUE  THEN ABAP_TRUE ).
        LR_FCAT->TECH       = COND #( WHEN P_PURORD EQ ABAP_FALSE THEN ABAP_TRUE ).

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F11.
        LR_FCAT->JUST       = 'C'.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_IN_LIST .

  TRY.
      GR_LIST->MS_LAYOUT = VALUE #( BASE GR_LIST->MS_LAYOUT  NO_ROWMARK = ABAP_TRUE ).

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_IN_ORDER .

  TRY.
      GR_ORDER->MS_LAYOUT = VALUE #( BASE GR_ORDER->MS_LAYOUT  NO_ROWMARK = ABAP_TRUE ).

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK_IN_LIST USING PS_ROW    TYPE LVC_S_ROID
                                 PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LR_LIST) = REF #( GT_LIST[ PS_ROW-ROW_ID ] OPTIONAL ).

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CHECK LR_LIST->CHECKED EQ ABAP_FALSE.

  MODIFY GT_LIST FROM VALUE #( CHECKED = SPACE )
                 TRANSPORTING CHECKED
                 WHERE CHECKED EQ ABAP_TRUE.

  LR_LIST->CHECKED = ABAP_TRUE.
  GR_LIST->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hotspot_click_in_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK_IN_ORDER  USING PS_ROW    TYPE LVC_S_ROID
                                 PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LR_ORDER) = REF #( GT_ORDER[ PS_ROW-ROW_ID ] OPTIONAL ).

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  LR_ORDER->CHECKED = COND #( WHEN LR_ORDER->CHECKED EQ ABAP_TRUE THEN ABAP_FALSE
                                                                ELSE ABAP_TRUE ).
  GR_ORDER->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_based_on_PURCH_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_DATA_BASED_ON_PURCH_ORDER .
  DATA LT_CLOBJDAT TYPE TT_CLOBJDAT.
  DATA LT_CONF TYPE TT_CONF_OUT.
  DATA LV_ZZYUSCD TYPE ZGTEYUSCD.
  DATA LV_ORDTP TYPE CHAR10.

  CLEAR: P_MATNR, P_DSGNO, P_REVNO, P_YUSCD, P_MILEN.

  IF S_EBELN IS INITIAL OR S_EBELP IS INITIAL.
    IF SSCRFIELDS-UCOMM EQ GC_FCODE-ONLI.
      MESSAGE E026 WITH TEXT-F34 DISPLAY LIKE 'S'.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

  IF P_DRUM IS INITIAL.
    IF SSCRFIELDS-UCOMM EQ GC_FCODE-ONLI.
      MESSAGE E026 WITH TEXT-F33 DISPLAY LIKE 'S'.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

  LV_ORDTP = TEXT-T21.

  SELECT EKPO~EBELN AS ORDNR,
         EKPO~EBELP AS ITMNO,
         EKPO~WERKS, EKPO~MATNR, EKPO~MENGE AS PSMNG, EKPO~MEINS, MKT1~MAKTX,
         EKPO~CUOBJ,
         RESB~RSNUM, RESB~RSPOS, RESB~MATNR AS IDNRK, MKT2~MAKTX AS IDNTX,
         @LV_ORDTP AS ORDTP
    INTO CORRESPONDING FIELDS OF TABLE @GT_ORDER
    FROM EKPO
    JOIN RESB
      ON EKPO~EBELN EQ RESB~EBELN
     AND EKPO~EBELP EQ RESB~EBELP
    JOIN MARA
      ON RESB~MATNR EQ MARA~MATNR
    JOIN MAKT AS MKT1
      ON EKPO~MATNR EQ MKT1~MATNR
     AND MKT1~SPRAS EQ @SY-LANGU
    JOIN MAKT AS MKT2
      ON RESB~MATNR EQ MKT2~MATNR
     AND MKT2~SPRAS EQ @SY-LANGU
   WHERE RESB~EBELN IN @S_EBELN
     AND RESB~EBELP IN @S_EBELP
     AND ( MARA~MTART IN ( @ZGTPP_IF_CONST=>GC_MTART-MRM1,
                           @ZGTPP_IF_CONST=>GC_MTART-MRM2 )
        OR MARA~MATKL EQ 'RW600406' )
   ORDER BY RESB~WERKS, RESB~MATNR.

  IF SY-SUBRC IS NOT INITIAL AND SSCRFIELDS-UCOMM EQ GC_FCODE-ONLI.
    MESSAGE E000 WITH TEXT-E05 DISPLAY LIKE 'S'.
  ENDIF.

  CHECK GT_ORDER IS NOT INITIAL.

  DATA(LS_ORDER) = VALUE #( GT_ORDER[ 1 ] OPTIONAL ).

  READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS WITH KEY FLD_01 = LS_ORDER-WERKS
                                                           FLD_02 = P_DRUM.
  IF SY-SUBRC IS NOT INITIAL.
    MESSAGE E000 WITH TEXT-E06 DISPLAY LIKE 'S'.
  ENDIF.

  P_MATNR = LS_ORDER-MATNR.

  PERFORM GET_CLASSIFICATION USING LS_ORDER-MATNR LT_CLOBJDAT.

  P_DSGNO = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_DESIGN_NO' ]-AUSP1 OPTIONAL ).
  P_REVNO = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_DESIGN_REV_NO' ]-AUSP1 OPTIONAL ).

  PERFORM GET_CONFIGURATION USING LS_ORDER-CUOBJ LT_CONF.

  P_MILEN = VALUE #( LT_CONF[ ATNAM = 'SAP_MILLCA_LENGTH' ]-ATWRT OPTIONAL ).

  P_YUSCD = COND #( WHEN LS_ORDER-WERKS EQ GC_WERKS-6500 THEN 'FG'
                    WHEN LS_ORDER-WERKS EQ GC_WERKS-6600 THEN 'FJ' ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_if_i_gaon_prod_bom_ch
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_IF_I_GAON_PROD_BOM_CH  USING PS_ORDER TYPE TY_S_ORDER
                                       PS_LIST  TYPE TY_S_LIST
                                       PV_SYSTEM_ID.
  DATA LV_RESULT  TYPE ZO_RESULT.
  DATA LV_MESSAGE TYPE ZO_MESSAGE.
  DATA LT_ORDER_BOM TYPE TABLE OF ZGTPPS1017.
  DATA LT_RESULT TYPE TABLE OF ZGTPPSIF0034.

  CLEAR: LT_ORDER_BOM, LT_RESULT, LV_RESULT, LV_MESSAGE.

  APPEND INITIAL LINE TO LT_ORDER_BOM REFERENCE INTO DATA(LR_ORDER_BOM).
  LR_ORDER_BOM->* = VALUE #( WERKS      = PS_ORDER-WERKS
                             ZSERNO     = |{ SY-DATUM }9999|
                             AUFNR      = PS_ORDER-ORDNR
                             RSNUM      = PS_ORDER-RSNUM
                             RSPOS      = PS_ORDER-RSPOS
                             MATNR_FROM = PS_ORDER-IDNRK
                             MATNR_TO   = PS_LIST-DRUM_MATNR
                             ERFMG   = PS_ORDER-ERFMG ).

  CALL FUNCTION 'ZGTPP_GAON_PROD_BOM_CH'
    TABLES
      IT_ORDER_BOM = LT_ORDER_BOM
      OT_RESULT    = LT_RESULT.

  DATA(LS_RESULT) = VALUE #( LT_RESULT[ 1 ] ).

  IF LS_RESULT-ZERP_STAT NE ZGTPP_IF_CONST=>GC_RESULT-ERROR.
    PS_ORDER-STATUS = ICON_LED_GREEN.
    GV_CHANGED = ABAP_TRUE.

    PS_ORDER-IDNRK = PS_LIST-DRUM_MATNR.
    PS_ORDER-IDNTX = PS_LIST-DRUM_TXT.
  ELSE.
    PS_ORDER-STATUS = ICON_LED_RED.
  ENDIF.

  PS_ORDER-MESSAGE = LS_RESULT-ZERP_MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_purchase_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHANGE_PURCHASE_ORDER  USING PS_ORDER TYPE TY_S_ORDER
                                  PS_LIST  TYPE TY_S_LIST.
  DATA LT_MESSTAB TYPE TABLE OF BDCMSGCOLL.

  PERFORM BUILD_BDC_DATA USING PS_ORDER PS_LIST.

  DATA(LS_OPTION) = VALUE CTU_PARAMS( DISMODE = 'N'
                                      UPDMODE = 'S' ).

  CALL TRANSACTION 'ME22' USING GT_BDCDATA OPTIONS  FROM LS_OPTION
                                           MESSAGES INTO LT_MESSTAB.

  READ TABLE LT_MESSTAB INTO DATA(LS_MESSTAB) WITH KEY MSGTYP = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                                       MSGID  = '06'
                                                       MSGNR  = '023'.
  IF SY-SUBRC IS INITIAL.
    GV_CHANGED = ABAP_TRUE.
    PS_ORDER-STATUS = ICON_LED_GREEN.
    PS_ORDER-IDNRK  = PS_LIST-DRUM_MATNR.
    PS_ORDER-IDNTX  = PS_LIST-DRUM_TXT.
  ELSE.
    PS_ORDER-STATUS = ICON_LED_RED.
    LS_MESSTAB = VALUE #( LT_MESSTAB[ MSGTYP = ZGTPP_IF_CONST=>GC_RESULT-ERROR ] OPTIONAL ).
  ENDIF.

  MESSAGE ID LS_MESSTAB-MSGID TYPE LS_MESSTAB-MSGTYP NUMBER LS_MESSTAB-MSGNR WITH LS_MESSTAB-MSGV1 LS_MESSTAB-MSGV2 LS_MESSTAB-MSGV3 LS_MESSTAB-MSGV4
     INTO PS_ORDER-MESSAGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_bdc_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BUILD_BDC_DATA  USING PS_ORDER TYPE TY_S_ORDER
                           PS_LIST  TYPE TY_S_LIST.
  DATA LV_MENGE TYPE CHAR18.

  WRITE PS_LIST-MENGE UNIT PS_LIST-MEINS TO LV_MENGE LEFT-JUSTIFIED.

  GT_BDCDATA = VALUE #( ( DYNBEGIN = 'X'  PROGRAM = 'SAPMM06E'               DYNPRO = '0105' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '/00' )
                        ( DYNBEGIN = ' '  FNAM    = 'RM06E-BSTNR'            FVAL   = PS_ORDER-ORDNR )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPMM06E'               DYNPRO = '0120' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '/00' )
                        ( DYNBEGIN = ' '  FNAM    = 'RM06E-EBELP'            FVAL   = PS_ORDER-ITMNO )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPMM06E'               DYNPRO = '0120' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=LB' )
                        ( DYNBEGIN = ' '  FNAM    = 'RM06E-TCSELFLAG(01)'    FVAL   = 'X' )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLM61Q'               DYNPRO = '0115' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=SUCH' )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLM61Q'               DYNPRO = '0300' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '/00' )
                        ( DYNBEGIN = ' '  FNAM    = 'SUCHL-MATNR'            FVAL   = PS_ORDER-IDNRK )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLM61Q'               DYNPRO = '0115' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '/00' )
                        ( DYNBEGIN = ' '  FNAM    = 'MDPM-MATNR(01)'         FVAL   = PS_LIST-DRUM_MATNR )
                        ( DYNBEGIN = ' '  FNAM    = 'MDPM-ERFMG(01)'         FVAL   = LV_MENGE )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLM61Q'               DYNPRO = '0115' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=BACK' )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPMM06E'               DYNPRO = '0120' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=BU' ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form value_request_drum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM VALUE_REQUEST_DRUM .
  DATA LV_USER_RESET TYPE C.
  DATA LT_RETURN TYPE TABLE OF DDSHRETVAL.
  DATA LT_GRUM TYPE TY_T_DRUM.

  LT_GRUM = CORRESPONDING TY_T_DRUM( GT_ZGTPPT1010 MAPPING WERKS = FLD_01
                                                           VALUE = FLD_02
                                                           TEXT  = FLD_03 ).

  SORT LT_GRUM.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      DDIC_STRUCTURE  = 'ZGTPPS1016'
      RETFIELD        = 'VALUE'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = TEXT-T23
      VALUE_ORG       = 'S'
    IMPORTING
      USER_RESET      = LV_USER_RESET
    TABLES
      VALUE_TAB       = LT_GRUM[]
      RETURN_TAB      = LT_RETURN[]
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  CHECK SY-SUBRC IS INITIAL AND LT_RETURN[] IS NOT INITIAL.

  P_DRUM = VALUE #( LT_RETURN[ 1 ]-FIELDVAL OPTIONAL ) .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> ER_DATA_CHANGED
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED  USING PR_SENDER
                                PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                PV_UCOMM TYPE SY-UCOMM.

  IF GR_LIST IS BOUND AND PR_SENDER EQ GR_LIST->MR_GRID.
    PERFORM DATA_CHANGED_IN_LIST USING PR_DATA_CHANGED PV_UCOMM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED_IN_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PR_DATA_CHANGED
*&      --> PV_UCOMM
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
*& Form FIELD_VALID_CHECK_IN_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LR_LIST_>*
*&---------------------------------------------------------------------*
FORM FIELD_VALID_CHECK_IN_LIST  USING    PS_LIST TYPE TY_S_LIST.

  DATA LT_RETURN TYPE TABLE OF ZGTEDSIF0038.
  DATA LV_JOJANG TYPE CHAR6.

  IF PS_LIST-DRUM_CODE IS INITIAL.
    DELETE ADJACENT DUPLICATES FROM GT_ORDER COMPARING WERKS ORDNR IDNRK.
    DATA(LS_ORDER) = GT_ORDER[ 1 ].

    NEW ZGTPP_CL_CONV( )->CONVERT_STRING_TO_QTY( EXPORTING IV_INPUT  = CONV #( P_MILEN )
                                                 IMPORTING EV_OUTPUT = LV_JOJANG ).

    CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
      EXPORTING
        IV_SUL_NO    = CONV ZESUL_NO( P_DSGNO )
        IV_REV_SEQ   = CONV ZEREV_SEQ( P_REVNO )
        IV_JAKNO     = CONV KDKG4( P_YUSCD )
        IV_JOJANG    = LV_JOJANG
        IV_DRUM_CODE = CONV CHAR6( P_DRUM )
        IV_FLAG_PP   = ABAP_TRUE
      TABLES
        OT_RETURN    = LT_RETURN.

    SELECT MARA~MATNR,MARD~WERKS, MARA~MEINS,
           MAKT~MAKTX, SUM( MARD~LABST ) AS LABST
      FROM @LT_RETURN AS ZT01
      JOIN MARA
        ON ZT01~DRUM_MATNR EQ MARA~MATNR
      LEFT JOIN MARD
        ON ZT01~DRUM_MATNR EQ MARD~MATNR
       AND MARD~WERKS      EQ @LS_ORDER-WERKS
      LEFT JOIN MAKT
        ON ZT01~DRUM_MATNR EQ MAKT~MATNR
       AND MAKT~SPRAS EQ @SY-LANGU
     GROUP BY MARA~MATNR, MARD~WERKS, MARA~MEINS, MAKT~MAKTX
     ORDER BY MARA~MATNR
      INTO TABLE @DATA(LT_MATERIAL).

    READ TABLE LT_MATERIAL INTO DATA(LS_MATERIAL) WITH KEY MATNR = PS_LIST-DRUM_MATNR BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      PS_LIST-DRUM_MATNR = LS_MATERIAL-MATNR.
      PS_LIST-DRUM_TXT   = LS_MATERIAL-MAKTX.
      PS_LIST-LABST      = LS_MATERIAL-LABST.
      PS_LIST-MEINS      = LS_MATERIAL-MEINS.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_CELL_IN_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PR_DATA_CHANGED
*&      --> LS_CELL
*&      --> LR_LIST_>*
*&---------------------------------------------------------------------*
FORM MODIFY_CELL_IN_LIST  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                PS_CELL  TYPE LVC_S_MODI
                                PS_LIST TYPE TY_S_LIST.

  IF PS_LIST-DRUM_CODE IS INITIAL.
    PR_DATA_CHANGED->MODIFY_CELL( I_ROW_ID    = PS_CELL-ROW_ID :
                                  I_FIELDNAME = 'DRUM_TXT' I_VALUE = PS_LIST-DRUM_TXT ),
                                  I_FIELDNAME = 'LABST'    I_VALUE = PS_LIST-LABST ),
                                  I_FIELDNAME = 'MEINS'    I_VALUE = PS_LIST-MEINS ).
  ELSE.
    READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX PS_CELL-ROW_ID.

    PR_DATA_CHANGED->MODIFY_CELL( I_ROW_ID    = PS_CELL-ROW_ID :
                                  I_FIELDNAME = 'DRUM_MATNR' I_VALUE = LS_LIST-DRUM_MATNR ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DISP_DATA_PURORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_DISP_DATA_PURORD .

  DATA LT_RETURN TYPE TABLE OF ZGTEDSIF0038.
  DATA LV_JOJANG TYPE CHAR6.

  IF GT_ORDER IS INITIAL.
    MESSAGE S000 WITH TEXT-E04 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  DELETE ADJACENT DUPLICATES FROM GT_ORDER COMPARING WERKS ORDNR IDNRK.
  DATA(LS_ORDER) = GT_ORDER[ 1 ].

  NEW ZGTPP_CL_CONV( )->CONVERT_STRING_TO_QTY( EXPORTING IV_INPUT  = CONV #( P_MILEN )
                                               IMPORTING EV_OUTPUT = LV_JOJANG ).

  CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
    EXPORTING
      IV_SUL_NO    = CONV ZESUL_NO( P_DSGNO )
      IV_REV_SEQ   = CONV ZEREV_SEQ( P_REVNO )
      IV_JAKNO     = CONV KDKG4( P_YUSCD )
      IV_JOJANG    = LV_JOJANG
      IV_DRUM_CODE = CONV CHAR6( P_DRUM )
      IV_FLAG_PP   = ABAP_TRUE
    TABLES
      OT_RETURN    = LT_RETURN.

  SELECT MARA~MATNR,MARD~WERKS, MARA~MEINS,
         MAKT~MAKTX, SUM( MARD~LABST ) AS LABST
    FROM @LT_RETURN AS ZT01
    JOIN MARA
      ON ZT01~DRUM_MATNR EQ MARA~MATNR
    LEFT JOIN MARD
      ON ZT01~DRUM_MATNR EQ MARD~MATNR
     AND MARD~WERKS      EQ @LS_ORDER-WERKS
    LEFT JOIN MAKT
      ON ZT01~DRUM_MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   GROUP BY MARA~MATNR, MARD~WERKS, MARA~MEINS, MAKT~MAKTX
   ORDER BY MARA~MATNR
    INTO TABLE @DATA(LT_MATERIAL).

  LOOP AT LT_RETURN  INTO DATA(LS_RETURN).
    APPEND INITIAL LINE TO GT_LIST REFERENCE INTO DATA(LR_LIST).
    LR_LIST->* = CORRESPONDING #( LS_RETURN ).

    READ TABLE LT_MATERIAL INTO DATA(LS_MATERIAL) WITH KEY MATNR = LR_LIST->DRUM_MATNR BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      LR_LIST->DRUM_MATNR = LS_MATERIAL-MATNR.
      LR_LIST->DRUM_TXT   = LS_MATERIAL-MAKTX.
      LR_LIST->LABST      = LS_MATERIAL-LABST.
      LR_LIST->MEINS      = LS_MATERIAL-MEINS.
    ENDIF.
  ENDLOOP.

  SORT GT_ORDER BY WERKS ORDNR ITMNO.
  SORT GT_LIST BY DRUM_CODE DRUM_MATNR.

  FIELD-SYMBOLS: <FS_LIST> LIKE LINE OF GT_LIST.
  INSERT INITIAL LINE INTO GT_LIST INDEX 1 ASSIGNING <FS_LIST>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DISP_DATA_PRDORD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_DISP_DATA_PRDORD .

  DATA : LV_VBELN TYPE VBAP-VBELN.
  DATA : LV_POSNR TYPE VBAP-POSNR.
  DATA : LV_PACK_YN TYPE CHAR10.
  DATA : LV_PACK_DM TYPE MATNR.

  IF GT_AFPO IS INITIAL.
    MESSAGE S000 WITH TEXT-E04 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF GT_AFPO[] IS NOT INITIAL.
    SORT GT_AFPO BY AUFNR POSNR.
    DELETE ADJACENT DUPLICATES FROM GT_AFPO COMPARING AUFNR POSNR.

    SELECT WERKS AUFNR POSNR MATNR MAKTX PSMNG MEINS MILLCALENGTH MILLCAFACTOR
      FROM ZGTCVORDSYVAL
      INTO CORRESPONDING FIELDS OF TABLE GT_MAIN_DISP_200
       FOR ALL ENTRIES IN GT_AFPO
    WHERE AUFNR = GT_AFPO-AUFNR
       AND POSNR = GT_AFPO-POSNR
       AND DLFL = ''
       AND LKD = ''
       AND CLSD = ''
       AND TECO = ''.

    SELECT DISTINCT B~*
      FROM @GT_MAIN_DISP_200 AS A
      INNER JOIN ZGTPPT2010 AS B ON B~ORDNR = A~AUFNR
                                       AND B~ORDTY = 'PRD'
      INTO TABLE @GT_2010.
  ENDIF.
* 화면 구성 테이블 생성
  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN_200>).
    <LS_MAIN_200>-ORDTP = TEXT-T20.
    READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = <LS_MAIN_200>-AUFNR
                                                   POSNR+2(4) = <LS_MAIN_200>-POSNR
                                                   ORDTY = 'PRD'.
    IF SY-SUBRC EQ 0.
      <LS_MAIN_200>-INLENGTH = LS_2010-INLENGTH.
      IF LS_2010-MATNR_DM IS NOT INITIAL.
        <LS_MAIN_200>-IDNRK = LS_2010-MATNR_DM.
        <LS_MAIN_200>-IDNTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2010-MATNR_DM ).
      ENDIF.

* 팩터배치건 복조장일지 포장재 수량 오더수만큼 적용
      IF LS_2010-MULTY_REF = ABAP_TRUE.
        SELECT SINGLE COUNT( POSNR )
          FROM ZGTPPT2010
         WHERE GRPNR = @LS_2010-GRPNR
           AND ORDNR = @LS_2010-ORDNR
          INTO @<LS_MAIN_200>-ERFMG.

      ELSE. " 일반 생산오더 품목의 경우 1 세팅
        <LS_MAIN_200>-ERFMG = 1.
      ENDIF.
* 드럼 단위 = 'EA' 고정
      <LS_MAIN_200>-ERFME = 'EA'.

* 생산오더 정보입력
      IF LS_2010-DMORDTY = 'SO'.
        <LS_MAIN_200>-VBELN = LS_2010-DMORD.
        <LS_MAIN_200>-POSNR_SO = LS_2010-DMLINE.

        IF P_AUTO IS INITIAL AND P_PRDORD = ABAP_TRUE.
          LV_VBELN = LS_2010-DMORD.
          LV_POSNR = LS_2010-DMLINE.

          ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
            EXPORTING
              IV_VBELN      =  LV_VBELN                " 판매 관리 문서 번호
              IV_POSNR      = LV_POSNR                 " SD 문서의 품목 번호
            IMPORTING
              EV_PACK_YN    = LV_PACK_YN
              EV_PACK_DM  = LV_PACK_DM ).

          IF LV_PACK_YN = 'CM' AND LV_PACK_DM IS NOT INITIAL. " 포장재 지정상태와 드럼유형만 대상
            CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
              EXPORTING
                INPUT        = LV_PACK_DM
              IMPORTING
                OUTPUT       = LV_PACK_DM
              EXCEPTIONS
                LENGTH_ERROR = 1
                OTHERS       = 2.

            <LS_MAIN_200>-IDNRK2 = LV_PACK_DM.
            <LS_MAIN_200>-IDNTX2 = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LV_PACK_DM ).

            IF P_BATCH = 'X'.
              CLEAR : <LS_MAIN_200>-IDNRK, <LS_MAIN_200>-IDNTX.
            ENDIF.

          ENDIF.
        ENDIF.

      ENDIF.

    ELSE. " 조장에 등록 되지 않은 생산오더의 경우
      <LS_MAIN_200>-CHK_CBO = ABAP_TRUE.
      <LS_MAIN_200>-INLENGTH = <LS_MAIN_200>-MILLCALENGTH + 0.
* 드럼수는 등록된 조장수
      <LS_MAIN_200>-ERFMG = <LS_MAIN_200>-MILLCAFACTOR + 0.
* 드럼 단위 = 'EA' 고정
      <LS_MAIN_200>-ERFME = 'EA'.
    ENDIF.

  ENDLOOP.

* 판매오더 실행시 입력된 드럼 코드 기준으로 하위 화면 보여준다.
  IF P_SLSORD = ABAP_TRUE.

    PERFORM SET_LIST_DATA.

  ENDIF.

  SORT GT_MAIN_DISP_200 BY WERKS AUFNR POSNR.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING    P_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                  PO_DATA_CHANGED TYPE REF TO
                                            CL_ALV_CHANGED_DATA_PROTOCOL
                                  PE_ONF4
                                  PE_UCOMM.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA : LV_CHK_ERR.
  DATA : LV_CALL_FUNC.
  DATA : LV_CALL_FUNC_201.
  DATA : LV_MENGE TYPE MENGE_D.
  DATA : LV_MAKTX TYPE MAKT-MAKTX.

  DEFINE __SET_ERR_MSG.
    po_data_changed->add_protocol_entry(
        i_msgid     = 'ZGTPP00'                 " Message ID
        i_msgty     = 'E'                 " Message Type
        i_msgno     =  '03'                " Message No.
        i_msgv1     =  &1                " Message Variable1
        i_fieldname =  &2                " Field Name
        i_row_id    =  ls_mod_cells-row_id ).                " RowID
  END-OF-DEFINITION.

  DEFINE __MODI_CELL.
    po_data_changed->modify_cell(
      i_row_id     = &1                 " Row ID
      i_fieldname = &2                 " Field Name
      i_value       = &3 ).               " Value
  END-OF-DEFINITION.

  CASE P_SENDER.
    WHEN GO_GRID_0200.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'CHECKED'.
        ENDCASE.
      ENDLOOP.
    WHEN GO_GRID_0201 .
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'CHECKED'.
            CLEAR : GV_SELECTED_LINE, GV_SELECTED_VALUE.

            LV_CALL_FUNC_201 = ABAP_TRUE.
            GV_SELECTED_LINE = LS_MOD_CELLS-ROW_ID.
            GV_SELECTED_VALUE = LS_MOD_CELLS-VALUE.
          WHEN 'DRUM_MATNR'.
            CLEAR LV_MAKTX.
            IF LS_MOD_CELLS-VALUE IS INITIAL.
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'DRUM_TXT' LV_MAKTX.
            ELSE.
              PERFORM CHEK_DRUM USING LS_MOD_CELLS-VALUE CHANGING LV_MAKTX LV_CHK_ERR.
              IF LV_CHK_ERR IS NOT INITIAL.
                __SET_ERR_MSG '유효하지 않은 드럼자재가 입력되었습니다.' LS_MOD_CELLS-FIELDNAME.
              ELSE.
                __MODI_CELL LS_MOD_CELLS-ROW_ID 'DRUM_TXT' LV_MAKTX.
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDLOOP.
  ENDCASE.


  IF LV_CHK_ERR IS NOT INITIAL.
    PO_DATA_CHANGED->DISPLAY_PROTOCOL( ).
  ELSE.
    IF LV_CALL_FUNC_201 IS NOT INITIAL.
      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          FUNCTIONCODE           = 'CECHK201'              " Function code
        EXCEPTIONS
          FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
          OTHERS                 = 2.
      IF SY-SUBRC <> 0.
      ENDIF.

    ENDIF.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                            P_ROW TYPE LVC_S_ROW
                            P_COLUMN TYPE LVC_S_COL.

  IF P_ROW-INDEX = 0.
    RETURN.
  ENDIF.

  CASE P_SENDER.
    WHEN GO_GRID_0200.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'AUFNR' OR 'POSNR'.
          READ TABLE GT_MAIN_DISP_200 INTO GS_MAIN_DISP_200 INDEX P_ROW-INDEX.
          SET PARAMETER ID 'ANR' FIELD GS_MAIN_DISP_200-AUFNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONTEXT_MENU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM CONTEXT_MENU  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                         P_OBJECT TYPE REF TO CL_CTMENU.

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA: LT_STD_FCODES TYPE UI_FUNCTIONS,
        LT_OWN_FCODES TYPE UI_FUNCTIONS.
  DATA : LV_TEXT TYPE GUI_TEXT.
  DATA : LV_CHK_EXIST.

  CASE P_SENDER.
    WHEN GO_GRID_0200.

      GO_GRID_0200->GET_SELECTED_CELLS_ID(
        IMPORTING
         ET_CELLS = LT_CELLS ).                " Cell IDs

      IF LT_CELLS[] IS INITIAL.
        RETURN.
      ENDIF.

      P_OBJECT->CLEAR( ).

      LOOP AT LT_CELLS INTO DATA(LS_CELLS).
        READ TABLE GT_MAIN_DISP_200 INTO DATA(LS_MAIN) INDEX LS_CELLS-ROW_ID.
        IF LS_MAIN-CHECKED = ABAP_TRUE.
          LV_CHK_EXIST = ABAP_TRUE.
        ENDIF.

      ENDLOOP.

      IF LV_CHK_EXIST = ABAP_TRUE.
        LV_TEXT = '선택해제'.
        CALL METHOD P_OBJECT->ADD_FUNCTION
          EXPORTING
            FCODE = 'DECHECK_LINE'
            TEXT  = LV_TEXT.
      ELSE.
        LV_TEXT = '선택'.
        CALL METHOD P_OBJECT->ADD_FUNCTION
          EXPORTING
            FCODE = 'CHECK_LINE'
            TEXT  = LV_TEXT.
      ENDIF.
      CALL METHOD P_OBJECT->SHOW_FUNCTIONS
        EXPORTING
          FCODES = LT_OWN_FCODES.

      CALL METHOD CL_GUI_CFW=>FLUSH.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                 PV_UCOMM.

  DATA : LV_UCOMM TYPE SY-UCOMM.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_VALUE(10).



  CASE PO_SENDER.
    WHEN GO_GRID_0200.
      CASE PV_UCOMM.
        WHEN 'CHECK_LINE'.
          PERFORM PROCESS_CHECK_LINE_0200.
        WHEN 'DECHECK_LINE'.
          PERFORM PROCESS_DECHECK_LINE_0200.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_SCREEN_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_200 .

  GV_TPAR1 = COND #( WHEN P_SLSORD IS NOT INITIAL THEN TEXT-C11
                     WHEN P_PRDORD IS NOT INITIAL THEN TEXT-C12
                     WHEN P_PR IS NOT INITIAL THEN TEXT-C14
                     WHEN P_PURORD IS NOT INITIAL THEN TEXT-C13 ).

  CALL SCREEN 200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
*  REFRESH GT_EXCLUDE.
*  GT_EXCLUDE = COND #( WHEN P_SLSORD EQ ABAP_TRUE THEN VALUE #( ( 'ALL_DRUM' ) ( 'CHK_DRUM' ) ) ).

  SET PF-STATUS '0200'.
  SET TITLEBAR '0200'  WITH GV_TPAR1.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0200 .

  CREATE OBJECT GO_DOCKING_0200
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

*화면 분할
  CREATE OBJECT GO_SPLITTER_0200
    EXPORTING
      PARENT  = GO_DOCKING_0200
      ROWS    = 2
      COLUMNS = 1.

  PERFORM SET_CONTROL_HEIGHT.

  CALL METHOD GO_SPLITTER_0200->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0200.

  CALL METHOD GO_SPLITTER_0200->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0201.

* 그리드 적용
  CREATE OBJECT GO_GRID_0200
    EXPORTING
      I_PARENT      = GO_CONTAIN_0200
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CONTROL_HEIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CONTROL_HEIGHT .

  IF GV_USE_LIST IS INITIAL.
    GO_SPLITTER_0200->SET_ROW_HEIGHT(
      EXPORTING
        ID                =    1              " Row ID
        HEIGHT            =    100 ).             " Height
  ELSE.
    GO_SPLITTER_0200->SET_ROW_HEIGHT(
      EXPORTING
        ID                =    1              " Row ID
        HEIGHT            =    45 ).             " Height
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0200.
*// Event Handler ##
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_CONTEXT_MENU          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_ON_F4        FOR PO_GRID.
    WHEN GO_GRID_0201.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0200 .

  CLEAR GS_LAYOUT_0200.
  GS_LAYOUT_0200-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0200-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0200-NO_ROWMARK = ABAP_TRUE.
  GS_LAYOUT_0200-SEL_MODE   = 'D'.
  GS_LAYOUT_0200-STYLEFNAME = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0200 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2330TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_200'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0200.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0200[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_200
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'CHECKED'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHECKED'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　'.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
    <LS_FCAT>-EDIT = ABAP_TRUE.
    <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0200 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'ORDTP'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORDTP'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더범주'(f62).
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0200 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'DRUM_TY'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'DRUM_TY'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼타입'(f70).
    <LS_FCAT>-COL_POS = 13.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '2'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  LOOP AT GT_FIELDCAT_0200 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'ERFME' OR 'VBELN' OR 'POSNR_SO' OR 'MILLCALENGTH' OR 'MILLCAFACTOR' OR
        'CHK_CBO' OR 'CHK_SAVE'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(f52).
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ORDTP'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'(f53).
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = COND #( WHEN P_PR EQ ABAP_TRUE THEN 'X' ELSE '' ).
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더품목'(f70).
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = COND #( WHEN P_PR EQ ABAP_TRUE THEN 'X' ELSE '' ).
      WHEN 'BANFN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'(f53).
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = COND #( WHEN P_PR EQ ABAP_TRUE THEN '' ELSE 'X' ).
      WHEN 'BNFPO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더품목'(f70).
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = COND #( WHEN P_PR EQ ABAP_TRUE THEN '' ELSE 'X' ).
      WHEN 'EBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'(f53).
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = COND #( WHEN P_PURORD EQ ABAP_TRUE THEN '' ELSE 'X' ).
      WHEN 'EBELP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더품목'(f70).
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = COND #( WHEN P_PURORD EQ ABAP_TRUE THEN '' ELSE 'X' ).

      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목코드'(f54).
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '품목내역'(f55).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'PSMNG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더수량'(f56).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(f71).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(f57).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DRUM_TY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼구분'(t23).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
      WHEN 'IDNRK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼자재(이전)'(f72).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'IDNTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼명(이전)'(f73).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'IDNRK2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼자재(변경)'(f74).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'IDNTX2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼명(변경)'(f75).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'ERFMG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소요량'(f76).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'ERFME'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리상태'(f58).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-ICON = ABAP_TRUE.
      WHEN 'MESSAGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '처리 메시지'(f59).
        <LS_FCAT>-JUST = 'L'.

    ENDCASE.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0200 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR ls_celltab.
    ls_celltab-fieldname = &1.
    ls_celltab-style = &2.
    INSERT ls_celltab INTO TABLE lt_celltab.
  END-OF-DEFINITION.

  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLTAB.
    IF <LS_MAIN>-CHK_SAVE = ABAP_TRUE.
      __SET_CELL_ATTRIBUTE : 'CHECKED' ALV_STYLE_DISABLED,
                             'DRUM_TY' ALV_STYLE_DISABLED.
    ELSE.
      __SET_CELL_ATTRIBUTE : 'CHECKED' ALV_STYLE_ENABLED,
                             'DRUM_TY' ALV_STYLE_ENABLED.
    ENDIF.


    IF LT_CELLTAB IS NOT INITIAL.
      MOVE-CORRESPONDING LT_CELLTAB TO <LS_MAIN>-CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0200 .

  REFRESH GT_EXCLUDE_0200.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0200
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
*& Form CALL_GRID_0200_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0200_DISPLAY .

  CALL METHOD GO_GRID_0200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0200
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0200
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_200
*     IT_SORT              = GT_SORT_0200
      IT_FIELDCATALOG      = GT_FIELDCAT_0200.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0200->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0200->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0201 .

* 그리드 적용
  CREATE OBJECT GO_GRID_0201
    EXPORTING
      I_PARENT      = GO_CONTAIN_0201
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0201 .

  CLEAR GS_LAYOUT_0201.
  GS_LAYOUT_0201-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0201-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0201-NO_ROWMARK = ABAP_TRUE.
  GS_LAYOUT_0201-SEL_MODE   = 'D'.
  GS_LAYOUT_0201-NO_TOOLBAR   = ABAP_TRUE.
  GS_LAYOUT_0201-STYLEFNAME = 'CELLTAB'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0201 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2330TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_201'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0201.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0201[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_201
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0201 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'CHECKED'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0201 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHECKED'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '선택'(f01).
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
    <LS_FCAT>-EDIT = ABAP_TRUE.
    <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
  ENDIF.

  LOOP AT GT_FIELDCAT_0201 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'DRUM_CODE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼코드'(f02).
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼 내역'(f03).
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'L'.
      WHEN 'FLANG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '약경'(f04).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DONG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '동경'(f05).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'NAEP'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '내폭'(f06).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SIDANGU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '시단구'(f07).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DRUM_MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼 자재코드'(f08).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DRUM_TXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '드럼 자재내역'(f09).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'LABST'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '재고수량'(f10).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '재고단위'(f11).
        <LS_FCAT>-JUST = 'L'.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0201 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  DATA : LV_TABIX TYPE I.

* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR ls_celltab.
    ls_celltab-fieldname = &1.
    ls_celltab-style = &2.
    INSERT ls_celltab INTO TABLE lt_celltab.
  END-OF-DEFINITION.

  LOOP AT GT_MAIN_DISP_201 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    REFRESH LT_CELLTAB.
    ADD 1 TO LV_TABIX.

    __SET_CELL_ATTRIBUTE : 'DRUM_CODE' ALV_STYLE_COLOR_INT_KEY.
    __SET_CELL_ATTRIBUTE : 'MAKTX' ALV_STYLE_COLOR_INT_KEY.

    IF LV_TABIX = 1.
      __SET_CELL_ATTRIBUTE : 'DRUM_MATNR' ALV_STYLE_ENABLED.
    ELSE.
      __SET_CELL_ATTRIBUTE : 'DRUM_MATNR' ALV_STYLE_DISABLED.
    ENDIF.

    IF LT_CELLTAB IS NOT INITIAL.
      MOVE-CORRESPONDING LT_CELLTAB TO <LS_MAIN>-CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0201_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0201_DISPLAY .

  CALL METHOD GO_GRID_0201->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0201
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0201
      I_BYPASSING_BUFFER   = ABAP_TRUE
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_201
*     IT_SORT              = GT_SORT_0200
      IT_FIELDCATALOG      = GT_FIELDCAT_0201.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0201->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0201->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_FIELD_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_F4_FIELD_GRID_0200 .

  DATA : LT_F4 TYPE LVC_T_F4,
         LS_F4 TYPE LVC_S_F4.

  CLEAR : LT_F4.

  LS_F4-FIELDNAME = 'DRUM_TY'.  "F4적용 필드
  LS_F4-REGISTER  = 'X'.        "이 부분을 X해줘야 사용할 수 있음
  LS_F4-GETBEFORE = ''.         "F4하기 전에 데이터 체인지 이벤트를 먼저 탐
  LS_F4-CHNGEAFTER = ''.         "F4에서 값 선택 후 데이터 체인지 이벤트 탐

  APPEND LS_F4 TO LT_F4.

  CALL METHOD GO_GRID_0200->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_ONF4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_FIELDNAME
*&      --> E_FIELDVALUE
*&      --> ES_ROW_NO
*&      --> ER_EVENT_DATA
*&      --> ET_BAD_CELLS
*&      --> E_DISPLAY
*&---------------------------------------------------------------------*
FORM ALV_ONF4  USING    PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                        PV_FIELDNAME TYPE LVC_FNAME
                        PV_FIELDVALUE TYPE LVC_VALUE
                        PS_ROW_NO  TYPE LVC_S_ROID
                        PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                        PT_BAD_CELLS TYPE LVC_T_MODI
                        PV_DISPLAY TYPE CHAR01.

  FIELD-SYMBOLS : <LT_DATA> TYPE TABLE.
  FIELD-SYMBOLS : <LV_VALUE> TYPE ANY.


  CASE PO_SENDER.
    WHEN GO_GRID_0200.
      CASE PV_FIELDNAME.
        WHEN 'DRUM_TY'.
          PERFORM F4_DRUM_TY USING PV_FIELDNAME PS_ROW_NO
                                   CHANGING PV_FIELDVALUE.

          PR_EVENT_DATA->M_EVENT_HANDLED = 'X'.   "스탠다드 F4는 무시
          IF PV_FIELDVALUE IS INITIAL.
            RETURN.
          ENDIF.

          ASSIGN PR_EVENT_DATA->M_DATA->* TO <LT_DATA>.
          APPEND INITIAL LINE TO <LT_DATA> ASSIGNING FIELD-SYMBOL(<FS_F4>).
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'ROW_ID' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PS_ROW_NO-ROW_ID.
          ENDIF.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PV_FIELDNAME.
          ENDIF.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'VALUE' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PV_FIELDVALUE.
          ENDIF.

      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_DRUM_TY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_FIELDNAME
*&      --> PS_ROW_NO
*&      <-- PV_FIELDVALUE
*&---------------------------------------------------------------------*
FORM F4_DRUM_TY  USING    PV_FIELDNAME TYPE LVC_FNAME
                             PS_ROW_NO  TYPE LVC_S_ROID
               CHANGING PV_FIELDVALUE TYPE LVC_VALUE.

  DATA LV_USER_RESET TYPE C.
  DATA LT_RETURN TYPE TABLE OF DDSHRETVAL.
  DATA LT_GRUM TYPE TY_T_DRUM.

  READ TABLE GT_MAIN_DISP_200 INTO DATA(LS_MAIN) INDEX   PS_ROW_NO-ROW_ID.

  LT_GRUM = CORRESPONDING TY_T_DRUM( GT_ZGTPPT1010 MAPPING WERKS = FLD_01
                                                           VALUE = FLD_02
                                                           TEXT  = FLD_03 ).

  DELETE LT_GRUM WHERE WERKS NE LS_MAIN-WERKS.

  SORT LT_GRUM.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      DDIC_STRUCTURE  = 'ZGTPPS1016'
      RETFIELD        = 'VALUE'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = TEXT-T23
      VALUE_ORG       = 'S'
    IMPORTING
      USER_RESET      = LV_USER_RESET
    TABLES
      VALUE_TAB       = LT_GRUM[]
      RETURN_TAB      = LT_RETURN[]
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  CHECK SY-SUBRC IS INITIAL AND LT_RETURN[] IS NOT INITIAL.
  PV_FIELDVALUE = VALUE #( LT_RETURN[ 1 ]-FIELDVAL OPTIONAL ) .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALL_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ALL_DRUM .

  DATA LV_USER_RESET TYPE C.
  DATA LT_RETURN TYPE TABLE OF DDSHRETVAL.
  DATA LT_GRUM TYPE TY_T_DRUM.
  DATA : LV_DRUM TYPE CHAR02.
  DATA : LV_WERKS TYPE WERKS_D.

  IF NOT LINE_EXISTS( GT_MAIN_DISP_200[ CHECKED = ABAP_TRUE ] ).
    MESSAGE S006 DISPLAY LIKE 'E' WITH '드럼구분일괄변경을 위해 오더를 선택해 주세요.'(e20).
    RETURN.
  ENDIF.

  DATA(LT_CHK_WERKS) = GT_MAIN_DISP_200.
  SORT LT_CHK_WERKS BY WERKS.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_WERKS COMPARING WERKS.

  IF LINES( LT_CHK_WERKS ) > 1.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '플랜트가 다른 생산오더들이 존재하여 드럼구분일괄변경 할 수 없습니다.'(e08).
    RETURN.
  ENDIF.

  READ TABLE LT_CHK_WERKS INTO DATA(LS_CHK_WERKS) INDEX 1.

  LT_GRUM = CORRESPONDING TY_T_DRUM( GT_ZGTPPT1010 MAPPING WERKS = FLD_01
                                                           VALUE = FLD_02
                                                           TEXT  = FLD_03 ).

  DELETE LT_GRUM WHERE WERKS NE LS_CHK_WERKS-WERKS.

  SORT LT_GRUM.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      DDIC_STRUCTURE  = 'ZGTPPS1016'
      RETFIELD        = 'VALUE'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = TEXT-T23
      VALUE_ORG       = 'S'
    IMPORTING
      USER_RESET      = LV_USER_RESET
    TABLES
      VALUE_TAB       = LT_GRUM[]
      RETURN_TAB      = LT_RETURN[]
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  CHECK SY-SUBRC IS INITIAL AND LT_RETURN[] IS NOT INITIAL.
  LV_DRUM = VALUE #( LT_RETURN[ 1 ]-FIELDVAL OPTIONAL ) .

  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WHERE CHECKED = ABAP_TRUE.
    IF <LS_MAIN>-CHK_SAVE IS INITIAL.
      <LS_MAIN>-DRUM_TY = LV_DRUM.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0200.
      GO_GRID_0200->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0200 ).
      PERFORM SET_CELL_ATTRIBUTE_GRID_0200.
    WHEN GO_GRID_0201.
      GO_GRID_0201->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0201 ).
      PERFORM SET_CELL_ATTRIBUTE_GRID_0201.
  ENDCASE.

  PERFORM SET_CONTROL_HEIGHT.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_AUTO_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_AUTO_DRUM .

  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LS_CHK_INFOR LIKE GS_HEADER_201.
  DATA : LT_RETURN TYPE TABLE OF ZGTEDSIF0038.

  IF NOT LINE_EXISTS( GT_MAIN_DISP_200[ CHECKED = ABAP_TRUE ] ).
    MESSAGE S006 DISPLAY LIKE 'E' WITH '드럼 자동지정을 위해 오더를 선택해 주세요.'(e22).
    RETURN.
  ENDIF.

  LT_MATNR = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_200 WHERE ( MATNR IS NOT INITIAL )
                    ( SIGN = 'I' OPTION ='EQ' LOW = LW_MAIN-MATNR ) ).

  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

  SELECT * FROM ZGTCVMSTVAL
     INTO TABLE @DATA(LT_CVMVAL)
    WHERE WERKS IN ( '6500', '6600' )
       AND MATNR IN @LT_MATNR.

  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WHERE CHECKED = ABAP_TRUE.
* 드럼정보 찾아오기 위한 데이터 구성
    LS_CHK_INFOR-WERKS = <LS_MAIN>-WERKS.
* 설계번호
    READ TABLE LT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY WERKS = <LS_MAIN>-WERKS
                                                      MATNR = <LS_MAIN>-MATNR.

    LS_CHK_INFOR-SUL_NO = LS_CVMVAL-PDCADESIGNNO.
    LS_CHK_INFOR-REV_SEQ = LS_CVMVAL-PDCADESIGNREVNO.
*  영업소 코드정보
    IF <LS_MAIN>-VBELN IS NOT INITIAL.
      SELECT SINGLE VBAP~MATNR, VBAP~CUOBJ, VBAK~VKORG, VBAK~VKGRP, VBAP~WERKS
       INTO @DATA(LS_SALES)
       FROM VBAP
       JOIN VBAK
         ON VBAP~VBELN EQ VBAK~VBELN
      WHERE VBAP~VBELN EQ @<LS_MAIN>-VBELN
        AND VBAP~POSNR EQ @<LS_MAIN>-POSNR.

      PERFORM GET_ZZYUSCD USING LS_SALES-VKORG LS_SALES-VKGRP LS_CHK_INFOR-JAKNO.
    ENDIF.

    IF LS_CHK_INFOR-JAKNO IS INITIAL.
      CASE <LS_MAIN>-WERKS.
        WHEN '6500'.
          LS_CHK_INFOR-JAKNO = 'FG'.
        WHEN '6600'.
          LS_CHK_INFOR-JAKNO = 'FJ'.
      ENDCASE.
    ENDIF.

    LS_CHK_INFOR-JOJANG = <LS_MAIN>-INLENGTH + 0.
    CONDENSE LS_CHK_INFOR-JOJANG.


    LS_CHK_INFOR-DRUM_CODE = <LS_MAIN>-DRUM_TY.
    IF <LS_MAIN>-DRUM_TY IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '드럼구분을 확인하십시오.'(E06).
      CONTINUE.
    ENDIF.


    REFRESH LT_RETURN.
    CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
      EXPORTING
        IV_SUL_NO    = LS_CHK_INFOR-SUL_NO
        IV_REV_SEQ   = LS_CHK_INFOR-REV_SEQ
        IV_JAKNO     = LS_CHK_INFOR-JAKNO
        IV_JOJANG    = LS_CHK_INFOR-JOJANG
        IV_DRUM_CODE = LS_CHK_INFOR-DRUM_CODE
        IV_FLAG_PP   = ABAP_TRUE
      TABLES
        OT_RETURN    = LT_RETURN.

    LOOP AT LT_RETURN INTO DATA(LS_RETURN).

      SELECT SINGLE A~MATNR, C~MAKTX
        FROM MARA AS A
        INNER JOIN MARC AS B ON B~MATNR = A~MATNR
        INNER JOIN MAKT AS C ON C~MATNR = A~MATNR
       WHERE A~MATNR = @LS_RETURN-DRUM_MATNR
         AND A~LVORM = ''
         AND B~WERKS = @LS_CHK_INFOR-WERKS
         AND B~MMSTA = ''
         AND B~LVORM = ''
         AND C~SPRAS = @SY-LANGU
        INTO ( @<LS_MAIN>-IDNRK2, @<LS_MAIN>-IDNTX2 ).
      IF SY-SUBRC EQ 0 AND <LS_MAIN>-IDNRK2 IS NOT INITIAL.
        <LS_MAIN>-STATUS = ICON_LED_GREEN.
        <LS_MAIN>-MESSAGE = '드럼 자동지정 성공.'(E09).
        EXIT.
      ENDIF.
    ENDLOOP.

    IF <LS_MAIN>-IDNRK2 IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '드럼 자동지정 대상이 없습니다.'(E10).
    ENDIF.

  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0200.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LIST_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LIST_DATA .

  DATA LT_RETURN TYPE TABLE OF ZGTEDSIF0038.

  GV_USE_LIST = ABAP_TRUE.

  CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
    EXPORTING
      IV_SUL_NO    = GS_HEADER_201-SUL_NO
      IV_REV_SEQ   = GS_HEADER_201-REV_SEQ
      IV_JAKNO     = GS_HEADER_201-JAKNO
      IV_JOJANG    = GS_HEADER_201-JOJANG
      IV_DRUM_CODE = GS_HEADER_201-DRUM_CODE
      IV_FLAG_PP   = ABAP_TRUE
    TABLES
      OT_RETURN    = LT_RETURN.

  SELECT MARA~MATNR,MARD~WERKS, MARA~MEINS,
         MAKT~MAKTX, SUM( MARD~LABST ) AS LABST
    FROM @LT_RETURN AS ZT01
    JOIN MARA
      ON ZT01~DRUM_MATNR EQ MARA~MATNR
    LEFT JOIN MARD
      ON ZT01~DRUM_MATNR EQ MARD~MATNR
     AND MARD~WERKS      EQ @GS_HEADER_201-WERKS
    LEFT JOIN MAKT
      ON ZT01~DRUM_MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   GROUP BY MARA~MATNR, MARD~WERKS, MARA~MEINS, MAKT~MAKTX
   ORDER BY MARA~MATNR
    INTO TABLE @DATA(LT_MATERIAL).

  REFRESH GT_MAIN_DISP_201.
  LOOP AT LT_RETURN  INTO DATA(LS_RETURN).
    APPEND INITIAL LINE TO GT_MAIN_DISP_201 ASSIGNING FIELD-SYMBOL(<LS_MAIN_201>).
    MOVE-CORRESPONDING LS_RETURN TO <LS_MAIN_201>.

    READ TABLE LT_MATERIAL INTO DATA(LS_MATERIAL) WITH KEY MATNR = LS_RETURN-DRUM_MATNR BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      <LS_MAIN_201>-DRUM_MATNR = LS_MATERIAL-MATNR.
      <LS_MAIN_201>-DRUM_TXT   = LS_MATERIAL-MAKTX.
      <LS_MAIN_201>-LABST      = LS_MATERIAL-LABST.
      <LS_MAIN_201>-MEINS      = LS_MATERIAL-MEINS.
    ENDIF.
  ENDLOOP.

  SORT GT_MAIN_DISP_201 BY DRUM_CODE DRUM_MATNR.
  INSERT INITIAL LINE INTO GT_MAIN_DISP_201 INDEX 1 ASSIGNING <LS_MAIN_201>.
  <LS_MAIN_201>-DRUM_CODE = '자율지정'.
  <LS_MAIN_201>-MAKTX = '드럼 자재코드를 입력하세요.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_CHECK_LINE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_CHECK_LINE_0200 .

  DATA : LT_CELLS TYPE LVC_T_CENO.

  GO_GRID_0200->GET_SELECTED_CELLS_ID(
    IMPORTING
     ET_CELLS = LT_CELLS ).                " Cell IDs

  SORT LT_CELLS BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0 AND <LS_MAIN>-CHK_SAVE IS INITIAL.
      <LS_MAIN>-CHECKED = ABAP_TRUE.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DECHECK_LINE_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DECHECK_LINE_0200 .

  DATA : LT_CELLS TYPE LVC_T_CENO.

  GO_GRID_0200->GET_SELECTED_CELLS_ID(
    IMPORTING
     ET_CELLS = LT_CELLS ).                " Cell IDs

  SORT LT_CELLS BY ROW_ID.
  DELETE ADJACENT DUPLICATES FROM LT_CELLS COMPARING ROW_ID.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
    IF SY-SUBRC EQ 0 AND <LS_MAIN>-CHK_SAVE IS INITIAL.
      CLEAR <LS_MAIN>-CHECKED.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_CHK_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISP_CHK_DRUM .

  IF LINE_EXISTS( GT_MAIN_DISP_200[ CHECKED = ABAP_TRUE ] ).
    DATA(LT_LINE_CHK) = GT_MAIN_DISP_200.
    DELETE LT_LINE_CHK WHERE CHECKED NE ABAP_TRUE.
    IF LINES( LT_LINE_CHK ) > 1.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '한건씩 확인해 주세요'(e12).
      RETURN.
    ENDIF.

    READ TABLE GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WITH KEY CHECKED = ABAP_TRUE.

    SELECT SINGLE * FROM ZGTCVMSTVAL
       INTO @DATA(LS_CVMVAL)
      WHERE WERKS = @<LS_MAIN>-WERKS
         AND MATNR = @<LS_MAIN>-MATNR.

    CLEAR GS_HEADER_201.

* 드럼정보 찾아오기 위한 데이터 구성
    GS_HEADER_201-WERKS = <LS_MAIN>-WERKS.

    GS_HEADER_201-SUL_NO = LS_CVMVAL-PDCADESIGNNO.
    GS_HEADER_201-REV_SEQ = LS_CVMVAL-PDCADESIGNREVNO.
*  영업소 코드정보
    IF <LS_MAIN>-VBELN IS NOT INITIAL.
      SELECT SINGLE VBAP~MATNR, VBAP~CUOBJ, VBAK~VKORG, VBAK~VKGRP, VBAP~WERKS
       INTO @DATA(LS_SALES)
       FROM VBAP
       JOIN VBAK
         ON VBAP~VBELN EQ VBAK~VBELN
      WHERE VBAP~VBELN EQ @<LS_MAIN>-VBELN
        AND VBAP~POSNR EQ @<LS_MAIN>-POSNR.

      PERFORM GET_ZZYUSCD USING LS_SALES-VKORG LS_SALES-VKGRP GS_HEADER_201-JAKNO.
    ENDIF.

    IF GS_HEADER_201-JAKNO IS INITIAL.
      CASE <LS_MAIN>-WERKS.
        WHEN '6500'.
          GS_HEADER_201-JAKNO = 'FG'.
        WHEN '6600'.
          GS_HEADER_201-JAKNO = 'FJ'.
      ENDCASE.
    ENDIF.

    GS_HEADER_201-JOJANG = <LS_MAIN>-INLENGTH + 0.
    CONDENSE GS_HEADER_201-JOJANG.

    GS_HEADER_201-DRUM_CODE = <LS_MAIN>-DRUM_TY.
    IF <LS_MAIN>-DRUM_TY IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '드럼구분을 확인하십시오.'(E06).
      RETURN.
    ENDIF.

    PERFORM SET_LIST_DATA.

    PERFORM REFRESH_GRID USING GO_GRID_0200.
    PERFORM REFRESH_GRID USING GO_GRID_0201.


  ELSE.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '가능 드럼을 확인할 오더를 선택해 주세요.'(e11).
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SET_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SET_DRUM .

  IF GT_MAIN_DISP_201 IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '가능드럼 리스트가 없습니다.'(e14).
    RETURN.
  ENDIF.

  IF LINE_EXISTS( GT_MAIN_DISP_201[ CHECKED = ABAP_TRUE ] ).
    READ TABLE GT_MAIN_DISP_201 INTO DATA(LS_MAIN_201) WITH KEY CHECKED = ABAP_TRUE.
  ELSE.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '지정할 드럼자재를 선택해 주세요.'(e13).
    RETURN.
  ENDIF.

  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WHERE CHECKED = ABAP_TRUE.
    IF GS_HEADER_201-WERKS NE <LS_MAIN>-WERKS.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '체크된 드럼자재와 플랜트가 다릅니다.'(E15).
      CONTINUE.
    ENDIF.

    IF GS_HEADER_201-DRUM_CODE NE <LS_MAIN>-DRUM_TY.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '체크된 드럼자재와 드럼 구분이 다릅니다.'(E16).
      CONTINUE.
    ENDIF.

    <LS_MAIN>-IDNRK2 = LS_MAIN_201-DRUM_MATNR.
    <LS_MAIN>-IDNTX2 = LS_MAIN_201-DRUM_TXT.
    IF <LS_MAIN>-ERFMG = 0.
      <LS_MAIN>-ERFMG = 1.
    ENDIF.
    <LS_MAIN>-STATUS = ICON_LED_GREEN.
    <LS_MAIN>-MESSAGE = '선택된 드럼자재로 변경되었습니다.'(e21).
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SAVE .

  DATA : LT_CHECKD_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_SINGLE_AUFNR LIKE TABLE OF GS_MAIN_DISP_200.
  DATA : LT_MOSU LIKE TABLE OF GS_MAIN_DISP_200.
  DATA : LT_SORTED_MOSU LIKE TABLE OF GS_MAIN_DISP_200.
  DATA : LV_CHK_ERR.
  DATA : LV_MESSAGE TYPE BAPI_ORDER_RETURN-MESSAGE.

  IF NOT LINE_EXISTS( GT_MAIN_DISP_200[ CHECKED = ABAP_TRUE ] ).
    MESSAGE S006 DISPLAY LIKE 'E' WITH '변경사항등록을 위해 오더를 선택해 주세요.'(e19).
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '변경사항이 반영됩니다. 계속 진행 하시겠습니까?'
    '저장확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WHERE CHECKED = ABAP_TRUE.
    IF <LS_MAIN>-IDNRK2 IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '드럼자재(변경)에 설정된 드럼이 없습니다.'(E17).
      CONTINUE.
    ENDIF.

    IF <LS_MAIN>-IDNRK2 = <LS_MAIN>-IDNRK.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '변경할 내용이 없습니다.'(E18).
      CONTINUE.
    ENDIF.

* 오더 상태 점검.
    CLEAR LV_CHK_ERR.
    PERFORM ORDER_STATUS_CHECK USING  <LS_MAIN> CHANGING LV_CHK_ERR LV_MESSAGE.
    IF LV_CHK_ERR IS NOT INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = LV_MESSAGE.
      CONTINUE.
    ENDIF.

    APPEND <LS_MAIN> TO LT_MOSU.

    READ TABLE LT_CHECKD_2010 ASSIGNING FIELD-SYMBOL(<LS_CHECKED_2010>) WITH KEY ORDNR = <LS_MAIN>-AUFNR
                                                                                 POSNR+2(4) = <LS_MAIN>-POSNR.
    IF SY-SUBRC EQ 0.
      <LS_CHECKED_2010>-MATNR_DM = <LS_MAIN>-IDNRK2.
    ELSE.
      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = <LS_MAIN>-AUFNR
                                                     POSNR+2(4) = <LS_MAIN>-POSNR.
      IF SY-SUBRC EQ 0.
        REFRESH LT_2010.
        LT_2010 = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( GRPNR = LS_2010-GRPNR
                                                    AND   ORDNR = LS_2010-ORDNR )
                         ( CORRESPONDING #( LW_2010 ) ) ).
        APPEND LINES OF LT_2010 TO LT_CHECKD_2010.

        READ TABLE LT_CHECKD_2010 ASSIGNING <LS_CHECKED_2010> WITH KEY ORDNR = <LS_MAIN>-AUFNR
                                                                       POSNR+2(4) = <LS_MAIN>-POSNR.
        IF SY-SUBRC EQ 0.
          <LS_CHECKED_2010>-MATNR_DM = <LS_MAIN>-IDNRK2.
        ENDIF.
      ELSE. " 조장 대상이 아닌경우 싱글 변경대상
        APPEND <LS_MAIN> TO LT_SINGLE_AUFNR.
      ENDIF.
    ENDIF.
  ENDLOOP.

* 포장재는 오더 단위로 저장이 되므로 오더 단위로 반영진행
  LT_SORTED_MOSU = LT_MOSU.
  SORT LT_SORTED_MOSU BY AUFNR.
  DELETE ADJACENT DUPLICATES FROM LT_SORTED_MOSU COMPARING AUFNR.

  LOOP AT LT_SORTED_MOSU INTO DATA(LS_SORTED_MOSU).
    CLEAR : LV_CHK_ERR, LV_MESSAGE.

* 반영대상
    READ TABLE LT_SINGLE_AUFNR INTO DATA(LS_SINGLE) WITH KEY AUFNR = LS_SORTED_MOSU-AUFNR
                                                                     POSNR = LS_SORTED_MOSU-POSNR.
    IF SY-SUBRC EQ 0.
* 조장대상이 아닌 오더의 포장재 변경
      PERFORM CHG_ORDER_SUGI USING LS_SINGLE CHANGING LV_CHK_ERR LV_MESSAGE.
    ELSE.
* 조장대상은 오더 이관처리를 위해 조장먼저 선반영후 에러시 원복 처리
      REFRESH LT_2010.
      LT_2010 = VALUE #( FOR LW_2010 IN LT_CHECKD_2010 WHERE ( ORDNR = LS_SORTED_MOSU-AUFNR )
                         ( CORRESPONDING #( LW_2010 ) ) ).
      MODIFY ZGTPPT2010 FROM TABLE LT_2010.
      COMMIT WORK AND WAIT.


      PERFORM CHG_ORDER_JOJANGE TABLES LT_2010
                                 USING LS_SORTED_MOSU
                              CHANGING LV_CHK_ERR LV_MESSAGE.

      IF LV_CHK_ERR = 'E'.
        REFRESH LT_2010.
        LT_2010 = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( GRPNR = LS_2010-GRPNR
                                                      AND   ORDNR = LS_2010-ORDNR )
                           ( CORRESPONDING #( LW_2010 ) ) ).

        MODIFY ZGTPPT2010 FROM TABLE LT_2010.
        COMMIT WORK AND WAIT.

      ENDIF.

    ENDIF.

    LOOP AT LT_MOSU INTO DATA(LS_MOSU) WHERE AUFNR = LS_SORTED_MOSU-AUFNR.
      READ TABLE GT_MAIN_DISP_200 ASSIGNING <LS_MAIN> WITH KEY AUFNR = LS_MOSU-AUFNR
                                                               POSNR = LS_MOSU-POSNR.
      IF SY-SUBRC EQ 0.
        IF LV_CHK_ERR = 'E'.
          <LS_MAIN>-STATUS = ICON_LED_RED.
          <LS_MAIN>-MESSAGE = LV_MESSAGE.
        ELSE.
          <LS_MAIN>-STATUS = ICON_LED_GREEN.
          <LS_MAIN>-MESSAGE = LV_MESSAGE.
          <LS_MAIN>-CHK_SAVE = ABAP_TRUE.
        ENDIF.
      ENDIF.
    ENDLOOP.

*  오더정보 송신 추가 - 2026.10.06
    IF LV_CHK_ERR NE 'E'.
      PERFORM SEND_ORD_STST USING LS_SORTED_MOSU.
    ENDIF.

  ENDLOOP.

  LOOP AT GT_MAIN_DISP_200 ASSIGNING <LS_MAIN> WHERE CHECKED = ABAP_TRUE.
    CLEAR <LS_MAIN>-CHECKED.
  ENDLOOP.


  PERFORM REFRESH_GRID USING GO_GRID_0200.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm_step
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP  USING LP_OPT
                                  LP_TEXT1
                                  LP_TEXT2
                                  LP_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = LP_OPT
      TEXTLINE1      = LP_TEXT1
      TEXTLINE2      = LP_TEXT2
      TITEL          = LP_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHG_ORDER_SUGI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SINGLE
*&      <-- LV_CHK_ERR
*&      <-- LV_MESSAGE
*&      <-- ELSE
*&---------------------------------------------------------------------*
FORM CHG_ORDER_SUGI  USING    PS_SINGLE LIKE GS_MAIN_DISP_200
                     CHANGING PV_CHK_ERR
                              PV_MESSAGE.

  DATA : LT_RESB TYPE TABLE OF RESB.
* 바피 object
  DATA : LS_RETURN TYPE COXT_BAPIRETURN.
  DATA : LT_RESBKEYS TYPE COXT_T_RESBDEL,
         LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
         LV_ERROR    TYPE FLAG.

  DATA : LS_REQU_QUAN TYPE COXT_S_QUANTITY.
  DATA : LV_STORAGE_LOCATION TYPE COXT_S_STORAGE_LOCATION.
  DATA : LV_STORAGE_LOCATIONX TYPE COXT_S_STORAGE_LOCATIONX.
  DATA : LV_POSNO TYPE CIF_R3RES-POSITIONNO.


* 기존 등록된 포장재 수량 확인.
  SELECT B~*
     FROM AFKO AS A
     INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
    INNER JOIN MARA AS C ON C~MATNR = B~MATNR
    WHERE A~AUFNR = @PS_SINGLE-AUFNR
      AND B~XLOEK = ''
      AND C~MTART LIKE 'MRM%'
      INTO TABLE @LT_RESB.

  IF SY-SUBRC EQ 0.
* 한건의 자재가 존재한다면 현재 변경 설정된 자재로 교체
    IF LINES( LT_RESB ) = 1.
      LOOP AT LT_RESB INTO DATA(LS_RESB).

        LS_RESB-MATNR = PS_SINGLE-IDNRK2.
        LS_RESB-BDMNG = PS_SINGLE-ERFMG.
        LS_RESB-ERFMG = PS_SINGLE-ERFMG.
        LS_RESB-SORTF = 1.

        UPDATE RESB SET MATNR = LS_RESB-MATNR
                        BDMNG = LS_RESB-BDMNG
                        ERFMG = LS_RESB-ERFMG
                        SORTF = LS_RESB-SORTF
        WHERE  RSNUM = LS_RESB-RSNUM
           AND  RSPOS = LS_RESB-RSPOS.
        IF SY-SUBRC NE 0.
          PV_CHK_ERR = 'E'.
          ROLLBACK WORK.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF PV_CHK_ERR = 'E'.
        PV_MESSAGE = '변경사항등록 중 오류발생.'.
      ELSE.
        COMMIT WORK AND WAIT.
        PV_CHK_ERR = 'S'.
        PV_MESSAGE = '변경사항등록 완료.'.
      ENDIF.

      RETURN.
    ELSE. " 변경사항 반영을 위해 드럼 자재들 삭제 후 진행
      REFRESH LT_RESB.
      SELECT B~RSNUM, B~RSPOS
         FROM AFKO AS A
         INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
        INNER JOIN MARA AS C ON C~MATNR = B~MATNR
        WHERE A~AUFNR = @PS_SINGLE-AUFNR
          AND B~XLOEK = ''
          AND C~MTART LIKE 'MRM%'
          INTO CORRESPONDING FIELDS OF TABLE @LT_RESB.
      IF SY-SUBRC EQ 0.

        REFRESH : LT_RESBKEYS, LT_RETURN.
        CLEAR : LV_ERROR, LS_RETURN.

        IF SY-SUBRC EQ 0.
          LT_RESBKEYS = CORRESPONDING #( LT_RESB ).
        ENDIF.

* BAPI to delete the components of Production Order
        CALL FUNCTION 'CO_XT_COMPONENTS_DELETE'
          EXPORTING
            IT_RESBKEYS_TO_DELETE = LT_RESBKEYS
          IMPORTING
            E_ERROR_OCCURRED      = LV_ERROR
          TABLES
            CT_BAPIRETURN         = LT_RETURN
          EXCEPTIONS
            DELETE_FAILED         = 1
            OTHERS                = 2.

        PERFORM CHANGE_FLAG_SET(SAPLCOZV).

        CALL FUNCTION 'CO_IT_SET_FLG_ITAB_NEW'.
        IF LV_ERROR = SPACE.
          CALL FUNCTION 'CO_XT_ORDER_PREPARE_COMMIT'
            IMPORTING
              ES_BAPIRETURN    = LS_RETURN
              E_ERROR_OCCURRED = LV_ERROR.
          IF ( LS_RETURN-TYPE = 'S' OR
               LS_RETURN-TYPE = 'W' OR
               LS_RETURN-TYPE = 'I' ) OR
               LS_RETURN IS INITIAL.

            COMMIT WORK AND WAIT.
            WAIT UP TO '0.5' SECONDS.

            CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.
          ELSE.

            PV_CHK_ERR = 'E'.
            IF LS_RETURN-MESSAGE IS NOT INITIAL.
              PV_MESSAGE = LS_RETURN-MESSAGE.
            ELSE.
              MESSAGE ID LS_RETURN-ID TYPE 'S' NUMBER LS_RETURN-NUMBER WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2 LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4
                 INTO PV_MESSAGE.
            ENDIF.
            IF PV_MESSAGE IS INITIAL.
              PV_MESSAGE = '변경사항등록 중 오류발생.'.
            ENDIF.

            CLEAR: LV_ERROR,
                   LS_RETURN.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            RETURN.
          ENDIF.
        ELSE.
          PV_CHK_ERR = 'E'.
          READ TABLE LT_RETURN INTO DATA(LS_ERR) WITH KEY TYPE = 'E'.
          IF SY-SUBRC EQ 0.
            IF LS_ERR-MESSAGE IS NOT INITIAL.
              PV_MESSAGE = LS_ERR-MESSAGE.
            ELSE.
              MESSAGE ID LS_ERR-ID TYPE 'S' NUMBER LS_ERR-NUMBER WITH LS_ERR-MESSAGE_V1 LS_ERR-MESSAGE_V2 LS_ERR-MESSAGE_V3 LS_ERR-MESSAGE_V4
                 INTO PV_MESSAGE.
            ENDIF.
          ELSE.
            PV_MESSAGE = '변경사항등록 중 오류발생.'.
          ENDIF.
          CLEAR LV_ERROR.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          RETURN.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.

* 드럼추가

  SELECT SINGLE B~APLZL, B~PLNFL
    INTO ( @DATA(LV_OPERATION), @DATA(LV_SEQUENCE) )
    FROM AFKO AS A
   INNER JOIN AFVC AS B ON B~AUFPL EQ A~AUFPL
   WHERE A~AUFNR EQ @PS_SINGLE-AUFNR
      AND B~APLFL = '000000'
      AND B~RUECK NE ''.

  CLEAR : LS_REQU_QUAN, LV_STORAGE_LOCATION, LV_STORAGE_LOCATIONX, LV_POSNO, LS_RETURN, LV_ERROR.

  SELECT SINGLE MEINS FROM MARA
    INTO @DATA(LV_MEINS)
   WHERE MATNR = @PS_SINGLE-IDNRK2.


  LS_REQU_QUAN-QUANTITY = PS_SINGLE-ERFMG.
  LS_REQU_QUAN-UOM = LV_MEINS.

  LV_STORAGE_LOCATION-WERKS = PS_SINGLE-WERKS.
  LV_STORAGE_LOCATIONX-WERKS = ABAP_TRUE.

  SELECT SINGLE MAX( B~POSNR ) AS POSNR
    FROM AFKO AS A
    INNER JOIN RESB AS B
                           ON B~RSNUM = A~RSNUM
   WHERE A~AUFNR = @PS_SINGLE-AUFNR
     GROUP BY B~RSNUM
     INTO @DATA(LV_RESBPOSNR).

  LV_RESBPOSNR = LV_RESBPOSNR + 10.

  CALL FUNCTION 'CONVERSION_EXIT_NUMCV_INPUT'
    EXPORTING
      INPUT  = LV_RESBPOSNR
    IMPORTING
      OUTPUT = LV_RESBPOSNR.
  LV_POSNO = LV_RESBPOSNR.

  CALL FUNCTION 'CO_XT_COMPONENT_ADD'
    EXPORTING
      IS_ORDER_KEY         = PS_SINGLE-AUFNR
      I_MATERIAL           = PS_SINGLE-IDNRK2
      IS_REQU_QUAN         = LS_REQU_QUAN
      I_OPERATION          = LV_OPERATION
      I_SEQUENCE           = LV_SEQUENCE
      IS_STORAGE_LOCATION  = LV_STORAGE_LOCATION
      IS_STORAGE_LOCATIONX = LV_STORAGE_LOCATIONX
      I_POSTP              = 'L'
      I_POSNO              = LV_POSNO
    IMPORTING
      ES_BAPIRETURN        = LS_RETURN
      E_ERROR_OCCURRED     = LV_ERROR.
  IF LV_ERROR = SPACE.

    ASSIGN ('(SAPLCOBC)RESB_BT[]') TO FIELD-SYMBOL(<FT_RESB_BT>).
    LOOP AT <FT_RESB_BT> ASSIGNING FIELD-SYMBOL(<FS_RESB_BT>).

      ASSIGN COMPONENT 'MATNR' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_MATNR>).
      IF <LV_MATNR> = PS_SINGLE-IDNRK2.

        ASSIGN COMPONENT 'POSNR' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_POSNR>).
        <LV_POSNR> = LV_POSNO.
*          ASSIGN COMPONENT 'RGEKZ' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_RGEKZ>).
*          <LV_RGEKZ> = ABAP_TRUE.
        ASSIGN COMPONENT 'SORTF' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_SORTF>).
        <LV_SORTF> = 1.
      ENDIF.
    ENDLOOP.


    CALL FUNCTION 'CO_XT_ORDER_PREPARE_COMMIT'
      IMPORTING
        ES_BAPIRETURN    = LS_RETURN
        E_ERROR_OCCURRED = LV_ERROR.
    IF ( LS_RETURN-TYPE = 'S' OR
         LS_RETURN-TYPE = 'W' OR
         LS_RETURN-TYPE = 'I' ) OR
         LS_RETURN IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = ABAP_TRUE.

      CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.

      PV_CHK_ERR = 'S'.
      PV_MESSAGE = '변경사항등록 완료.'.

    ELSE.

      PV_CHK_ERR = 'E'.
      IF LS_RETURN-MESSAGE IS NOT INITIAL.
        PV_MESSAGE = LS_RETURN-MESSAGE.
      ELSE.
        MESSAGE ID LS_RETURN-ID TYPE 'S' NUMBER LS_RETURN-NUMBER WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2 LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4
           INTO PV_MESSAGE.
      ENDIF.
      IF PV_MESSAGE IS INITIAL.
        PV_MESSAGE = '변경사항등록 중 오류발생.'.
      ENDIF.

      CLEAR: LV_ERROR,
             LS_RETURN.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.
  ELSE.
    PV_CHK_ERR = 'E'.
    IF LS_RETURN-MESSAGE IS NOT INITIAL.
      PV_MESSAGE = LS_RETURN-MESSAGE.
    ELSE.
      MESSAGE ID LS_RETURN-ID TYPE 'S' NUMBER LS_RETURN-NUMBER WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2 LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4
         INTO PV_MESSAGE.
    ENDIF.
    IF PV_MESSAGE IS INITIAL.
      PV_MESSAGE = '변경사항등록 중 오류발생.'.
    ENDIF.

    CLEAR LV_ERROR.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHG_ORDER_JOJANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2010
*&      <-- LV_CHK_ERR
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM CHG_ORDER_JOJANGE  TABLES   PT_2010 STRUCTURE ZGTPPT2010
                           USING  PS_SINGLE LIKE GS_MAIN_DISP_200
                        CHANGING PV_CHK_ERR
                                 PV_MESSAGE.

  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_2010_SORT_ORD TYPE TABLE OF ZGTPPT2010.

  DATA : LV_AUFNR TYPE AFKO-AUFNR.
  DATA : LT_RESB TYPE TABLE OF RESB.
  DATA : LV_TABIX TYPE I.
  DATA : LV_CHK_ERR.

* 바피 object
  DATA : LS_RETURN TYPE COXT_BAPIRETURN.
  DATA : LT_RESBKEYS TYPE COXT_T_RESBDEL,
         LT_RETURN   TYPE STANDARD TABLE OF BAPIRET2,
         LV_ERROR    TYPE FLAG.

  DATA : LS_REQU_QUAN TYPE COXT_S_QUANTITY.
  DATA : LV_STORAGE_LOCATION TYPE COXT_S_STORAGE_LOCATION.
  DATA : LV_STORAGE_LOCATIONX TYPE COXT_S_STORAGE_LOCATIONX.
  DATA : LV_POSNO TYPE CIF_R3RES-POSITIONNO.

  LT_2010[] = PT_2010[].

  DATA : BEGIN OF LS_POJANG_SET,
           MATNR TYPE MATNR,
           MENGE TYPE MENGE_D,
         END OF LS_POJANG_SET.
  DATA : LT_POJANG_SET LIKE TABLE OF LS_POJANG_SET.

  LT_2010_SORT_ORD = LT_2010.
  SORT LT_2010_SORT_ORD BY ORDNR POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_2010_SORT_ORD COMPARING ORDNR.

  READ TABLE LT_2010_SORT_ORD INTO DATA(LS_SORT) INDEX 1.

  REFRESH LT_POJANG_SET.

  LV_AUFNR = LS_SORT-ORDNR.

  IF LS_SORT-MULTY_REF = ABAP_TRUE. " 팩터배치건 복조장일시 포장재 한건에 수량만 오더수만큼 적용.
    SELECT * FROM ZGTPPT2010
      INTO TABLE @DATA(LT_CHK_MULTY)
      WHERE GRPNR = @LS_SORT-GRPNR
        AND ORDNR = @LS_SORT-ORDNR.
    CLEAR LS_POJANG_SET.
    LS_POJANG_SET-MATNR = LS_SORT-MATNR_DM.
    LS_POJANG_SET-MENGE = LINES( LT_CHK_MULTY ).
    APPEND LS_POJANG_SET TO LT_POJANG_SET.
  ELSE.

    IF LINES( LT_2010 ) > 1. " 복조장
      LOOP AT LT_2010 INTO DATA(LS_2010).
        IF LS_2010-MATNR_DM IS NOT INITIAL.
          CLEAR LS_POJANG_SET.
          LS_POJANG_SET-MATNR = LS_2010-MATNR_DM.
          LS_POJANG_SET-MENGE = 1.
          COLLECT LS_POJANG_SET INTO LT_POJANG_SET.
        ENDIF.
      ENDLOOP.

    ELSE.
      CLEAR LS_POJANG_SET.
      LS_POJANG_SET-MATNR = LS_SORT-MATNR_DM.
      LS_POJANG_SET-MENGE = 1.
      APPEND LS_POJANG_SET TO LT_POJANG_SET.
    ENDIF.
  ENDIF.

* 기존 등록된 포장재 수량 확인.
  SELECT B~*
     FROM AFKO AS A
     INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
    INNER JOIN MARA AS C ON C~MATNR = B~MATNR
    WHERE A~AUFNR = @LV_AUFNR
      AND B~XLOEK = ''
      AND C~MTART LIKE 'MRM%'
      INTO TABLE @LT_RESB.

  DATA(LT_RESB_CHK) = LT_RESB.
  CLEAR LV_CHK_ERR.

  LOOP AT LT_POJANG_SET INTO LS_POJANG_SET.
    READ TABLE LT_RESB_CHK INTO DATA(LS_RESB_CHK) WITH KEY MATNR = LS_POJANG_SET-MATNR.
    IF SY-SUBRC EQ 0.
      LV_TABIX = SY-TABIX.
      IF LS_RESB_CHK-BDMNG = LS_POJANG_SET-MENGE.
        DELETE LT_RESB_CHK INDEX LV_TABIX.
      ENDIF.
    ELSE.
      LV_CHK_ERR = ABAP_TRUE..
    ENDIF.
  ENDLOOP.

  IF LT_RESB IS NOT INITIAL AND LT_RESB_CHK IS INITIAL AND LV_CHK_ERR IS INITIAL. " 변경할 내용 없음 종료

    LOOP AT  LT_RESB INTO DATA(LS_CHK_RESB).
      UPDATE RESB SET SORTF = 1
       WHERE RSNUM = LS_CHK_RESB-RSNUM
         AND RSPOS = LS_CHK_RESB-RSPOS.
      COMMIT WORK AND WAIT.
    ENDLOOP.



    PV_CHK_ERR = 'S'.
    PV_MESSAGE = '변경사항등록 완료.'.
    RETURN.
  ENDIF.


* 기존 포장재 삭제 작업
  SELECT B~RSNUM, B~RSPOS
     FROM AFKO AS A
     INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
    INNER JOIN MARA AS C ON C~MATNR = B~MATNR
    WHERE A~AUFNR = @LV_AUFNR
      AND B~XLOEK = ''
      AND C~MTART LIKE 'MRM%'
      INTO CORRESPONDING FIELDS OF TABLE @LT_RESB.
  IF SY-SUBRC EQ 0.

    REFRESH : LT_RESBKEYS, LT_RETURN.
    CLEAR : LV_ERROR, LS_RETURN.

    IF SY-SUBRC EQ 0.
      LT_RESBKEYS = CORRESPONDING #( LT_RESB ).
    ENDIF.

    CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.

* BAPI to delete the components of Production Order
    CALL FUNCTION 'CO_XT_COMPONENTS_DELETE'
      EXPORTING
        IT_RESBKEYS_TO_DELETE = LT_RESBKEYS
      IMPORTING
        E_ERROR_OCCURRED      = LV_ERROR
      TABLES
        CT_BAPIRETURN         = LT_RETURN
      EXCEPTIONS
        DELETE_FAILED         = 1
        OTHERS                = 2.

    PERFORM CHANGE_FLAG_SET(SAPLCOZV).

    CALL FUNCTION 'CO_IT_SET_FLG_ITAB_NEW'.
    IF LV_ERROR = SPACE.

      CALL FUNCTION 'CO_XT_ORDER_PREPARE_COMMIT'
        IMPORTING
          ES_BAPIRETURN    = LS_RETURN
          E_ERROR_OCCURRED = LV_ERROR.
      IF ( LS_RETURN-TYPE = 'S' OR
           LS_RETURN-TYPE = 'W' OR
           LS_RETURN-TYPE = 'I' ) OR
           LS_RETURN IS INITIAL.

        COMMIT WORK AND WAIT.
        WAIT UP TO '0.5' SECONDS.

        CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.
      ELSE.

        PV_CHK_ERR = 'E'.
        IF LS_RETURN-MESSAGE IS NOT INITIAL.
          PV_MESSAGE = LS_RETURN-MESSAGE.
        ELSE.
          MESSAGE ID LS_RETURN-ID TYPE 'S' NUMBER LS_RETURN-NUMBER WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2 LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4
             INTO PV_MESSAGE.
        ENDIF.
        IF PV_MESSAGE IS INITIAL.
          PV_MESSAGE = '변경사항등록 중 오류발생.'.
        ENDIF.

        CLEAR: LV_ERROR,
               LS_RETURN.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        RETURN.

      ENDIF.
    ELSE.

      PV_CHK_ERR = 'E'.
      READ TABLE LT_RETURN INTO DATA(LS_ERR) WITH KEY TYPE = 'E'.
      IF SY-SUBRC EQ 0.
        IF LS_ERR-MESSAGE IS NOT INITIAL.
          PV_MESSAGE = LS_ERR-MESSAGE.
        ELSE.
          MESSAGE ID LS_ERR-ID TYPE 'S' NUMBER LS_ERR-NUMBER WITH LS_ERR-MESSAGE_V1 LS_ERR-MESSAGE_V2 LS_ERR-MESSAGE_V3 LS_ERR-MESSAGE_V4
             INTO PV_MESSAGE.
        ENDIF.
      ELSE.
        PV_MESSAGE = '변경사항등록 중 오류발생.'.
      ENDIF.

      CLEAR LV_ERROR.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      RETURN.
    ENDIF.
  ENDIF.

* 드럼추가

  SELECT SINGLE B~APLZL, B~PLNFL
    INTO ( @DATA(LV_OPERATION), @DATA(LV_SEQUENCE) )
    FROM AFKO AS A
   INNER JOIN AFVC AS B ON B~AUFPL EQ A~AUFPL
   WHERE A~AUFNR EQ @LV_AUFNR
      AND B~APLFL = '000000'
      AND B~RUECK NE ''.

  LOOP AT LT_POJANG_SET INTO LS_POJANG_SET.

    CLEAR : LS_REQU_QUAN, LV_STORAGE_LOCATION, LV_STORAGE_LOCATIONX, LV_POSNO, LS_RETURN, LV_ERROR.

    SELECT SINGLE MEINS FROM MARA
      INTO @DATA(LV_MEINS)
     WHERE MATNR = @LS_POJANG_SET-MATNR.


    LS_REQU_QUAN-QUANTITY = LS_POJANG_SET-MENGE.
    LS_REQU_QUAN-UOM = LV_MEINS.

    LV_STORAGE_LOCATION-WERKS = PS_SINGLE-WERKS.
    LV_STORAGE_LOCATIONX-WERKS = ABAP_TRUE.

    SELECT SINGLE MAX( B~POSNR ) AS POSNR
      FROM AFKO AS A
      INNER JOIN RESB AS B
                             ON B~RSNUM = A~RSNUM
     WHERE A~AUFNR = @LV_AUFNR
       GROUP BY B~RSNUM
       INTO @DATA(LV_RESBPOSNR).

    LV_RESBPOSNR = LV_RESBPOSNR + 10.

    CALL FUNCTION 'CONVERSION_EXIT_NUMCV_INPUT'
      EXPORTING
        INPUT  = LV_RESBPOSNR
      IMPORTING
        OUTPUT = LV_RESBPOSNR.
    LV_POSNO = LV_RESBPOSNR.

    CALL FUNCTION 'CO_XT_COMPONENT_ADD'
      EXPORTING
        IS_ORDER_KEY         = LV_AUFNR
        I_MATERIAL           = LS_POJANG_SET-MATNR
        IS_REQU_QUAN         = LS_REQU_QUAN
        I_OPERATION          = LV_OPERATION
        I_SEQUENCE           = LV_SEQUENCE
        IS_STORAGE_LOCATION  = LV_STORAGE_LOCATION
        IS_STORAGE_LOCATIONX = LV_STORAGE_LOCATIONX
        I_POSTP              = 'L'
        I_POSNO              = LV_POSNO
      IMPORTING
        ES_BAPIRETURN        = LS_RETURN
        E_ERROR_OCCURRED     = LV_ERROR.
    IF LV_ERROR = SPACE.

      ASSIGN ('(SAPLCOBC)RESB_BT[]') TO FIELD-SYMBOL(<FT_RESB_BT>).
      LOOP AT <FT_RESB_BT> ASSIGNING FIELD-SYMBOL(<FS_RESB_BT>).

        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_MATNR>).
        IF <LV_MATNR> = LS_POJANG_SET-MATNR.

          ASSIGN COMPONENT 'POSNR' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_POSNR>).
          <LV_POSNR> = LV_POSNO.
*          ASSIGN COMPONENT 'RGEKZ' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_RGEKZ>).
*          <LV_RGEKZ> = ABAP_TRUE.
          ASSIGN COMPONENT 'SORTF' OF STRUCTURE <FS_RESB_BT> TO FIELD-SYMBOL(<LV_SORTF>).
          <LV_SORTF> = 1.

        ENDIF.
      ENDLOOP.

      CALL FUNCTION 'CO_XT_ORDER_PREPARE_COMMIT'
        IMPORTING
          ES_BAPIRETURN    = LS_RETURN
          E_ERROR_OCCURRED = LV_ERROR.
      IF ( LS_RETURN-TYPE = 'S' OR
           LS_RETURN-TYPE = 'W' OR
           LS_RETURN-TYPE = 'I' ) OR
           LS_RETURN IS INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = ABAP_TRUE.

        WAIT UP TO '0.5' SECONDS.

        CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.

        PV_CHK_ERR = 'S'.
        PV_MESSAGE = '변경사항등록 완료.'.

        CLEAR LS_CHK_RESB.
        SELECT SINGLE B~RSNUM, B~RSPOS
           FROM AFKO AS A
           INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
          WHERE A~AUFNR = @LV_AUFNR
            AND B~XLOEK = ''
            AND B~MATNR = @LS_POJANG_SET-MATNR
            INTO @LS_CHK_RESB.
        IF SY-SUBRC EQ 0.
          UPDATE RESB SET SORTF = 1
           WHERE RSNUM = LS_CHK_RESB-RSNUM
             AND RSPOS = LS_CHK_RESB-RSPOS.
          COMMIT WORK AND WAIT.
        ENDIF.

      ELSE.
        PV_CHK_ERR = 'E'.
        IF LS_RETURN-MESSAGE IS NOT INITIAL.
          PV_MESSAGE = LS_RETURN-MESSAGE.
        ELSE.
          MESSAGE ID LS_RETURN-ID TYPE 'S' NUMBER LS_RETURN-NUMBER WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2 LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4
             INTO PV_MESSAGE.
        ENDIF.
        IF PV_MESSAGE IS INITIAL.
          PV_MESSAGE = '변경사항등록 중 오류발생.'.
        ENDIF.

        CLEAR: LV_ERROR,
               LS_RETURN.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        RETURN.
      ENDIF.
    ELSE.

      PV_CHK_ERR = 'E'.
      IF LS_RETURN-MESSAGE IS NOT INITIAL.
        PV_MESSAGE = LS_RETURN-MESSAGE.
      ELSE.
        MESSAGE ID LS_RETURN-ID TYPE 'S' NUMBER LS_RETURN-NUMBER WITH LS_RETURN-MESSAGE_V1 LS_RETURN-MESSAGE_V2 LS_RETURN-MESSAGE_V3 LS_RETURN-MESSAGE_V4
           INTO PV_MESSAGE.
      ENDIF.
      IF PV_MESSAGE IS INITIAL.
        PV_MESSAGE = '변경사항등록 중 오류발생.'.
      ENDIF.

      CLEAR LV_ERROR.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      RETURN.

    ENDIF.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHEK_DRUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MOD_CELLS_VALUE
*&      <-- LV_MAKTX
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHEK_DRUM  USING    PV_VALUE
                CHANGING PV_MAKTX TYPE MAKT-MAKTX
                         PV_CHK_ERR.

  DATA : LV_MATNR TYPE MATNR.
  DATA : LV_MATNR_RETURN TYPE MATNR.

  CLEAR : PV_CHK_ERR, PV_MAKTX.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT        = PV_VALUE
    IMPORTING
      OUTPUT       = LV_MATNR
    EXCEPTIONS
      LENGTH_ERROR = 1
      OTHERS       = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  SELECT SINGLE A~MATNR, C~MAKTX
    FROM MARA AS A
    INNER JOIN MARC AS B ON B~MATNR = A~MATNR
    INNER JOIN MAKT AS C ON C~MATNR = A~MATNR
   WHERE A~MATNR = @LV_MATNR
     AND A~LVORM = ''
     AND A~MTART LIKE 'MRM%'
     AND B~WERKS = @GS_HEADER_201-WERKS
     AND B~MMSTA = ''
     AND B~LVORM = ''
     AND C~SPRAS = @SY-LANGU
    INTO ( @LV_MATNR_RETURN, @PV_MAKTX ).

  IF LV_MATNR_RETURN IS INITIAL.
    PV_CHK_ERR = ABAP_TRUE.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHECK_SCREEN_201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CHECK_SCREEN_201 .

  CHECK GV_SELECTED_VALUE IS NOT INITIAL.

  LOOP AT GT_MAIN_DISP_201 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR <LS_MAIN>-CHECKED.
  ENDLOOP.

  READ TABLE GT_MAIN_DISP_201 ASSIGNING <LS_MAIN> INDEX GV_SELECTED_LINE.
  IF SY-SUBRC EQ 0.
    <LS_MAIN>-CHECKED = GV_SELECTED_VALUE.
  ENDIF.

  PERFORM REFRESH_GRID USING GO_GRID_0201.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ORDER_STATUS_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>
*&      <-- LV_CHK_ERR
*&      <-- LV_MESSAGE
*&      <-- IF
*&      <-- LV_CHK_ERR
*&      <-- IS
*&      <-- NOT
*&      <-- INITIAL
*&---------------------------------------------------------------------*
FORM ORDER_STATUS_CHECK  USING    PS_LS_MAIN LIKE GS_MAIN_DISP_200
                         CHANGING PV_ERROR
                                  PV_MESSAGE.

  SELECT AUFNR, CRTD, REL,  DEL,  DLFL,
         LKD,   TECO, CLSD, PCNF, CNF,
         PDLV,  DLV,  PAYO, GISTART
    INTO TABLE @DATA(LT_STAT)
    FROM ZGTPP_CV_ORD_STAT
   WHERE AUFNR = @PS_LS_MAIN-AUFNR
     AND WERKS = @PS_LS_MAIN-WERKS.
  SORT LT_STAT BY AUFNR .

  IF SY-SUBRC = 0.
    READ TABLE LT_STAT INTO DATA(LS_STAT)
                       WITH KEY AUFNR = PS_LS_MAIN-AUFNR
                       BINARY SEARCH.
    IF SY-SUBRC = 0.

      IF ( LS_STAT-DEL = 'X' OR LS_STAT-DLFL = 'X').
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M15.
        EXIT.
      ELSEIF  LS_STAT-LKD  = 'X'.
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M16.
        EXIT.
      ELSEIF  LS_STAT-TECO  = 'X'.
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M17.
        EXIT.
      ELSEIF  LS_STAT-CLSD  = 'X'.
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M18.
        EXIT.
*      ELSEIF  LS_STAT-PCNF  = 'X'.
*        PV_ERROR = 'X'.
*        PV_MESSAGE = TEXT-M19.
*        EXIT.
      ELSEIF  LS_STAT-CNF  = 'X'.
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M20.
        EXIT.
*      ELSEIF  LS_STAT-PDLV  = 'X'.
*        PV_ERROR = 'X'.
*        PV_MESSAGE = TEXT-M21.
*        EXIT.
      ELSEIF  LS_STAT-DLV  = 'X'.
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M22.
        EXIT.
      ENDIF.

    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CHK .

  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WHERE CHK_SAVE IS INITIAL.
    <LS_MAIN>-CHECKED = ABAP_TRUE.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_AUTO_PRD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_AUTO_PRD .

  DATA : LS_CHK_INFOR LIKE GS_HEADER_201.
  DATA : LT_RETURN TYPE TABLE OF ZGTEDSIF0038.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LV_PACK_YN TYPE CHAR10.
  DATA : LV_PACK_DM TYPE MATNR.

  LT_MATNR = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_200 WHERE ( MATNR IS NOT INITIAL )
                    ( SIGN = 'I' OPTION ='EQ' LOW = LW_MAIN-MATNR ) ).

  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

  SELECT * FROM ZGTCVMSTVAL
     INTO TABLE @DATA(LT_CVMVAL)
    WHERE WERKS IN ( '6500', '6600' )
       AND MATNR IN @LT_MATNR.

* 드럼코드 'H' 로 지정(6500 플랜트만 해당)후 드럼자재 코드 입력
  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

    IF <LS_MAIN>-VBELN IS NOT INITIAL. " 판매오더에 연결된 오더는 판매오더포장재 참고하여 세팅
      CLEAR : LV_PACK_YN, LV_PACK_DM.
      ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
        EXPORTING
          IV_VBELN      =  <LS_MAIN>-VBELN                " 판매 관리 문서 번호
          IV_POSNR      = <LS_MAIN>-POSNR_SO                 " SD 문서의 품목 번호
        IMPORTING
          EV_PACK_YN    = LV_PACK_YN
          EV_PACK_DM  = LV_PACK_DM ).

      IF LV_PACK_DM IS NOT INITIAL. " 포장재 지정상태와 드럼유형만 대상
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            INPUT        = LV_PACK_DM
          IMPORTING
            OUTPUT       = LV_PACK_DM
          EXCEPTIONS
            LENGTH_ERROR = 1
            OTHERS       = 2.

        <LS_MAIN>-IDNRK2 = LV_PACK_DM.
        <LS_MAIN>-IDNTX2 = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LV_PACK_DM ).
        <LS_MAIN>-STATUS = ICON_LED_GREEN.
        <LS_MAIN>-MESSAGE = '드럼 자동지정 성공.'(E09).
        CONTINUE.
      ENDIF.
    ENDIF.


    CLEAR LS_CHK_INFOR.
    <LS_MAIN>-DRUM_TY = P_DRUM.
* 드럼정보 찾아오기 위한 데이터 구성
    LS_CHK_INFOR-WERKS = <LS_MAIN>-WERKS.
* 설계번호
    READ TABLE LT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY WERKS = <LS_MAIN>-WERKS
                                                      MATNR = <LS_MAIN>-MATNR.

    LS_CHK_INFOR-SUL_NO = LS_CVMVAL-PDCADESIGNNO.
    LS_CHK_INFOR-REV_SEQ = LS_CVMVAL-PDCADESIGNREVNO.
*  영업소 코드정보
    IF <LS_MAIN>-VBELN IS NOT INITIAL.
      SELECT SINGLE VBAP~MATNR, VBAP~CUOBJ, VBAK~VKORG, VBAK~VKGRP, VBAP~WERKS
       INTO @DATA(LS_SALES)
       FROM VBAP
       JOIN VBAK
         ON VBAP~VBELN EQ VBAK~VBELN
      WHERE VBAP~VBELN EQ @<LS_MAIN>-VBELN
        AND VBAP~POSNR EQ @<LS_MAIN>-POSNR.

      PERFORM GET_ZZYUSCD USING LS_SALES-VKORG LS_SALES-VKGRP LS_CHK_INFOR-JAKNO.
    ENDIF.

    IF LS_CHK_INFOR-JAKNO IS INITIAL.
      CASE <LS_MAIN>-WERKS.
        WHEN '6500'.
          LS_CHK_INFOR-JAKNO = 'FG'.
        WHEN '6600'.
          LS_CHK_INFOR-JAKNO = 'FJ'.
      ENDCASE.
    ENDIF.

    LS_CHK_INFOR-DRUM_CODE = <LS_MAIN>-DRUM_TY.
    LS_CHK_INFOR-JOJANG = <LS_MAIN>-INLENGTH + 0.
    CONDENSE LS_CHK_INFOR-JOJANG.

    REFRESH LT_RETURN.
    CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
      EXPORTING
        IV_SUL_NO    = LS_CHK_INFOR-SUL_NO
        IV_REV_SEQ   = LS_CHK_INFOR-REV_SEQ
        IV_JAKNO     = LS_CHK_INFOR-JAKNO
        IV_JOJANG    = LS_CHK_INFOR-JOJANG
        IV_DRUM_CODE = LS_CHK_INFOR-DRUM_CODE
        IV_FLAG_PP   = ABAP_TRUE
      TABLES
        OT_RETURN    = LT_RETURN.

    LOOP AT LT_RETURN INTO DATA(LS_RETURN).

      SELECT SINGLE A~MATNR, C~MAKTX
        FROM MARA AS A
        INNER JOIN MARC AS B ON B~MATNR = A~MATNR
        INNER JOIN MAKT AS C ON C~MATNR = A~MATNR
       WHERE A~MATNR = @LS_RETURN-DRUM_MATNR
         AND A~LVORM = ''
         AND B~WERKS = @LS_CHK_INFOR-WERKS
         AND B~MMSTA = ''
         AND B~LVORM = ''
         AND C~SPRAS = @SY-LANGU
        INTO ( @<LS_MAIN>-IDNRK2, @<LS_MAIN>-IDNTX2 ).
      IF SY-SUBRC EQ 0 AND <LS_MAIN>-IDNRK2 IS NOT INITIAL.
        <LS_MAIN>-STATUS = ICON_LED_GREEN.
        <LS_MAIN>-MESSAGE = '드럼 자동지정 성공.'(E09).
        EXIT.
      ENDIF.
    ENDLOOP.

    IF <LS_MAIN>-IDNRK2 IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '드럼 자동지정 대상이 없습니다.'(E10).
    ENDIF.

  ENDLOOP.

* 드럼 변경사항 저장
  DATA : LT_CHECKD_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_SINGLE_AUFNR LIKE TABLE OF GS_MAIN_DISP_200.
  DATA : LT_MOSU LIKE TABLE OF GS_MAIN_DISP_200.
  DATA : LT_SORTED_MOSU LIKE TABLE OF GS_MAIN_DISP_200.
  DATA : LV_CHK_ERR.
  DATA : LV_MESSAGE TYPE BAPI_ORDER_RETURN-MESSAGE.

  LOOP AT GT_MAIN_DISP_200 ASSIGNING <LS_MAIN> WHERE WERKS = '6500'.
    IF <LS_MAIN>-IDNRK2 IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '드럼자재(변경)에 설정된 드럼이 없습니다.'(E17).
      CONTINUE.
    ENDIF.

*    IF <LS_MAIN>-IDNRK2 = <LS_MAIN>-IDNRK.
*      <LS_MAIN>-STATUS = ICON_LED_RED.
*      <LS_MAIN>-MESSAGE = '변경할 내용이 없습니다.'(E18).
*      CONTINUE.
*    ENDIF.

* 오더 상태 점검.
    CLEAR LV_CHK_ERR.
    PERFORM ORDER_STATUS_CHECK USING  <LS_MAIN> CHANGING LV_CHK_ERR LV_MESSAGE.
    IF LV_CHK_ERR IS NOT INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = LV_MESSAGE.
      CONTINUE.
    ENDIF.

* 드럼자재 투입여부 확인
    CLEAR LV_CHK_ERR.
    PERFORM RESB_INPUT_CHECK USING  <LS_MAIN> CHANGING LV_CHK_ERR LV_MESSAGE.
    IF LV_CHK_ERR IS NOT INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = LV_MESSAGE.
      CONTINUE.
    ENDIF.

    APPEND <LS_MAIN> TO LT_MOSU.
    READ TABLE LT_CHECKD_2010 ASSIGNING FIELD-SYMBOL(<LS_CHECKED_2010>) WITH KEY ORDNR = <LS_MAIN>-AUFNR
                                                                                 POSNR+2(4) = <LS_MAIN>-POSNR.
    IF SY-SUBRC EQ 0.
      <LS_CHECKED_2010>-MATNR_DM = <LS_MAIN>-IDNRK2.
    ELSE.
      READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = <LS_MAIN>-AUFNR
                                                     POSNR+2(4) = <LS_MAIN>-POSNR.
      IF SY-SUBRC EQ 0.
        REFRESH LT_2010.
        LT_2010 = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( GRPNR = LS_2010-GRPNR
                                                    AND   ORDNR = LS_2010-ORDNR )
                         ( CORRESPONDING #( LW_2010 ) ) ).
        APPEND LINES OF LT_2010 TO LT_CHECKD_2010.

        READ TABLE LT_CHECKD_2010 ASSIGNING <LS_CHECKED_2010> WITH KEY ORDNR = <LS_MAIN>-AUFNR
                                                                       POSNR+2(4) = <LS_MAIN>-POSNR.
        IF SY-SUBRC EQ 0.
          <LS_CHECKED_2010>-MATNR_DM = <LS_MAIN>-IDNRK2.
        ENDIF.
      ELSE. " 조장 대상이 아닌경우 싱글 변경대상
        APPEND <LS_MAIN> TO LT_SINGLE_AUFNR.
      ENDIF.
    ENDIF.
  ENDLOOP.

* 포장재는 오더 단위로 저장이 되므로 오더 단위로 반영진행
  LT_SORTED_MOSU = LT_MOSU.
  SORT LT_SORTED_MOSU BY AUFNR.
  DELETE ADJACENT DUPLICATES FROM LT_SORTED_MOSU COMPARING AUFNR.

  LOOP AT LT_SORTED_MOSU INTO DATA(LS_SORTED_MOSU).
    CLEAR : LV_CHK_ERR, LV_MESSAGE.

* 반영대상
    READ TABLE LT_SINGLE_AUFNR INTO DATA(LS_SINGLE) WITH KEY AUFNR = LS_SORTED_MOSU-AUFNR
                                                                     POSNR = LS_SORTED_MOSU-POSNR.
    IF SY-SUBRC EQ 0.
* 조장대상이 아닌 오더의 포장재 변경
      PERFORM CHG_ORDER_SUGI USING LS_SINGLE CHANGING LV_CHK_ERR LV_MESSAGE.
    ELSE.
* 조장대상은 오더 이관처리를 위해 조장먼저 선반영후 에러시 원복 처리
      REFRESH LT_2010.
      LT_2010 = VALUE #( FOR LW_2010 IN LT_CHECKD_2010 WHERE ( ORDNR = LS_SORTED_MOSU-AUFNR )
                         ( CORRESPONDING #( LW_2010 ) ) ).
      MODIFY ZGTPPT2010 FROM TABLE LT_2010.
      COMMIT WORK AND WAIT.

      PERFORM CHG_ORDER_JOJANGE TABLES LT_2010
                                 USING LS_SORTED_MOSU
                              CHANGING LV_CHK_ERR LV_MESSAGE.

      IF LV_CHK_ERR = 'E'.
        REFRESH LT_2010.
        LT_2010 = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( GRPNR = LS_2010-GRPNR
                                                      AND   ORDNR = LS_2010-ORDNR )
                           ( CORRESPONDING #( LW_2010 ) ) ).

        MODIFY ZGTPPT2010 FROM TABLE LT_2010.
        COMMIT WORK AND WAIT.

      ENDIF.

    ENDIF.

    LOOP AT LT_MOSU INTO DATA(LS_MOSU) WHERE AUFNR = LS_SORTED_MOSU-AUFNR.
      READ TABLE GT_MAIN_DISP_200 ASSIGNING <LS_MAIN> WITH KEY AUFNR = LS_MOSU-AUFNR
                                                               POSNR = LS_MOSU-POSNR.
      IF SY-SUBRC EQ 0.
        IF LV_CHK_ERR = 'E'.
          <LS_MAIN>-STATUS = ICON_LED_RED.
          <LS_MAIN>-MESSAGE = LV_MESSAGE.
        ELSE.
          <LS_MAIN>-STATUS = ICON_LED_GREEN.
          <LS_MAIN>-MESSAGE = LV_MESSAGE.
          <LS_MAIN>-CHK_SAVE = ABAP_TRUE.
        ENDIF.
      ENDIF.
    ENDLOOP.

*  오더정보 송신 추가 - 2026.10.06
    IF LV_CHK_ERR NE 'E'.
      PERFORM SEND_ORD_STST USING LS_SORTED_MOSU.
    ENDIF.

  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_BASED_ON_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_BASED_ON_PR .

  DATA : BEGIN OF LS_CHK_VBELN,
           VBELN TYPE VBAP-VBELN,
           VBELP TYPE VBAP-POSNR,
           MATNR TYPE VBAP-MATNR,
         END OF LS_CHK_VBELN.
  DATA : LT_CHK_VBELN LIKE TABLE OF LS_CHK_VBELN.

  DATA LT_CLOBJDAT TYPE TT_CLOBJDAT.
  DATA LT_CONF TYPE TT_CONF_OUT.
  DATA LV_ZZYUSCD TYPE ZGTEYUSCD.
  DATA LV_ORDTP TYPE CHAR10.
  DATA : LT_MATNR TYPE RANGE OF MATNR.

  IF S_BANFN IS INITIAL.
    IF SSCRFIELDS-UCOMM EQ GC_FCODE-ONLI.
      MESSAGE E026 WITH TEXT-T05 DISPLAY LIKE 'S'.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

*  IF P_DRUM IS INITIAL.
*    IF SSCRFIELDS-UCOMM EQ GC_FCODE-ONLI.
*      MESSAGE E026 WITH TEXT-F33 DISPLAY LIKE 'S'.
*    ELSE.
*      RETURN.
*    ENDIF.
*  ENDIF.

  REFRESH GT_MAIN_DISP_200.

* 판매오더 참조 PR이 아님, EBKN Join 주석
*  SELECT DISTINCT A~BANFN, A~BNFPO, A~WERKS, A~MENGE, A~MEINS,
*                  B~VBELN, B~VBELP, A~MATNR
*    FROM EBAN AS A
*    INNER JOIN EBKN AS B ON B~BANFN = A~BANFN
*                              AND B~BNFPO = A~BNFPO
*   WHERE A~BANFN IN  @S_BANFN
*      AND A~BNFPO IN  @S_BNFPO
*      AND A~BSTYP = 'B'
*      AND A~LOEKZ = ''
*    INTO TABLE @DATA(LT_EBAN).

  SELECT DISTINCT BANFN, BNFPO, WERKS, MENGE, MEINS,
                  ' ' AS VBELN, ' ' AS VBELP, MATNR
    FROM EBAN
   WHERE BANFN IN  @S_BANFN
      AND BNFPO IN  @S_BNFPO
      AND BSTYP = 'B'
      AND LOEKZ = ''
    INTO TABLE @DATA(LT_EBAN).

  IF LT_EBAN[] IS NOT INITIAL. " 구매요청 생성건은 제외대상
    SELECT A~BANFN, A~BNFPO, B~VBELN, B~VBELP
      FROM @LT_EBAN AS A
      INNER JOIN EBKN AS B ON B~BANFN = A~BANFN
                           AND B~BNFPO = A~BNFPO
     WHERE B~LOEKZ = ''
      INTO TABLE @DATA(LT_EBKN).


    SELECT DISTINCT A~EBELN, A~EBELP, B~BANFN, B~BNFPO
      FROM EKPO AS A
      INNER JOIN @LT_EBAN AS B ON B~BANFN = A~BANFN
                                         AND B~BNFPO = A~BNFPO
     WHERE A~LOEKZ = ''
      INTO TABLE @DATA(LT_EKKO).

    IF LT_EKKO[] IS NOT INITIAL.
      LOOP AT LT_EKKO INTO DATA(LS_EKKO).
        DELETE LT_EBAN WHERE BANFN = LS_EKKO-BANFN
                         AND BNFPO = LS_EKKO-BNFPO.

      ENDLOOP.
    ENDIF.
  ENDIF.

* 완제품 대상이 아닐시 제외
  LT_MATNR = VALUE #( FOR LW_MAIN IN LT_EBAN WHERE ( MATNR IS NOT INITIAL )
                    ( SIGN = 'I' OPTION ='EQ' LOW = LW_MAIN-MATNR ) ).

  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

  SELECT * FROM ZGTCVMSTVAL
     INTO TABLE @DATA(LT_CVMVAL)
    WHERE WERKS IN ( '6500', '6600' )
      AND MATNR IN @LT_MATNR.

*  DELETE LT_CVMVAL WHERE PDCADESIGNNO IS INITIAL.

  IF LT_MATNR[] IS INITIAL.
    REFRESH LT_EBAN.
    RETURN.
  ELSE.
    LOOP AT LT_EBAN INTO DATA(LS_EBAN).
      READ TABLE LT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY WERKS = LS_EBAN-WERKS
                                                         MATNR = LS_EBAN-MATNR.
      IF SY-SUBRC NE 0.
        CONTINUE.
      ENDIF.

      CLEAR GS_MAIN_DISP_200.
      GS_MAIN_DISP_200-WERKS = LS_EBAN-WERKS.
      GS_MAIN_DISP_200-ORDTP = '구매요청'.
      GS_MAIN_DISP_200-BANFN = LS_EBAN-BANFN.
      GS_MAIN_DISP_200-BNFPO = LS_EBAN-BNFPO.
      GS_MAIN_DISP_200-MATNR  = LS_EBAN-MATNR.
      GS_MAIN_DISP_200-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_EBAN-MATNR ).
      GS_MAIN_DISP_200-PSMNG = LS_EBAN-MENGE.
      GS_MAIN_DISP_200-INLENGTH = LS_EBAN-MENGE.
      GS_MAIN_DISP_200-ERFMG = 1.
      GS_MAIN_DISP_200-MEINS = LS_EBAN-MEINS.
      READ TABLE LT_EBKN INTO DATA(LS_EBKN) WITH KEY BANFN = LS_EBAN-BANFN
                                                     BNFPO = LS_EBAN-BNFPO.
      IF SY-SUBRC EQ 0.
        GS_MAIN_DISP_200-VBELN = LS_EBKN-VBELN.
        GS_MAIN_DISP_200-POSNR_SO = LS_EBKN-VBELP.
      ENDIF.
      APPEND GS_MAIN_DISP_200 TO GT_MAIN_DISP_200.

    ENDLOOP.

  ENDIF.

  REFRESH LT_CHK_VBELN.
  LT_CHK_VBELN = VALUE #( FOR LW_EBAN IN GT_MAIN_DISP_200 WHERE ( VBELN IS NOT INITIAL )
                        ( CORRESPONDING #( LW_EBAN ) ) ).

  IF LT_CHK_VBELN[] IS NOT INITIAL.
    SORT LT_CHK_VBELN BY VBELN VBELP.

    SELECT DISTINCT VBAP~MATNR, VBAP~CUOBJ, VBAK~VKORG, VBAK~VKGRP, VBAP~WERKS
      INTO TABLE @DATA(LT_SALES)
      FROM VBAP
      JOIN VBAK
        ON VBAP~VBELN EQ VBAK~VBELN
       FOR ALL ENTRIES IN @LT_CHK_VBELN
     WHERE VBAP~VBELN EQ @LT_CHK_VBELN-VBELN
       AND VBAP~POSNR EQ @LT_CHK_VBELN-VBELP
       AND VBAP~MATNR EQ @LT_CHK_VBELN-MATNR.

  ENDIF.

* 셀렉션 스크린 구성
*  IF LT_SALES[] IS NOT INITIAL.
*    READ TABLE LT_SALES INTO DATA(LS_SALES) INDEX 1.
*    P_MATNR = LS_SALES-MATNR.
*
*    PERFORM GET_CLASSIFICATION USING LS_SALES-MATNR LT_CLOBJDAT.
*
*    P_DSGNO = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_DESIGN_NO' ]-AUSP1 OPTIONAL ).
*    P_REVNO = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_DESIGN_REV_NO' ]-AUSP1 OPTIONAL ).
*
*    PERFORM GET_CONFIGURATION USING LS_SALES-CUOBJ LT_CONF.
*
*    P_MILEN = VALUE #( LT_CONF[ ATNAM = 'SAP_MILLCA_LENGTH' ]-ATWRT OPTIONAL ).
*
*    PERFORM GET_ZZYUSCD USING LS_SALES-VKORG LS_SALES-VKGRP LV_ZZYUSCD.
*
*    P_YUSCD = LV_ZZYUSCD.
*
*    P_MATNR = LS_SALES-MATNR.
*
*    PERFORM GET_CLASSIFICATION USING LS_SALES-MATNR LT_CLOBJDAT.
*
*    P_DSGNO = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_DESIGN_NO' ]-AUSP1 OPTIONAL ).
*    P_REVNO = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_DESIGN_REV_NO' ]-AUSP1 OPTIONAL ).
*
*    PERFORM GET_CONFIGURATION USING LS_SALES-CUOBJ LT_CONF.
*
*    P_MILEN = VALUE #( LT_CONF[ ATNAM = 'SAP_MILLCA_LENGTH' ]-ATWRT OPTIONAL ).
*
*    PERFORM GET_ZZYUSCD USING LS_SALES-VKORG LS_SALES-VKGRP LV_ZZYUSCD.
*
*    P_YUSCD = LV_ZZYUSCD.
*
*    CLEAR GS_HEADER_201.
*    GS_HEADER_201-SUL_NO = P_DSGNO.
*    GS_HEADER_201-REV_SEQ = P_REVNO.
*    GS_HEADER_201-JAKNO = LV_ZZYUSCD.
*    NEW ZGTPP_CL_CONV( )->CONVERT_STRING_TO_QTY( EXPORTING IV_INPUT  = CONV #( P_MILEN )
*                                           IMPORTING EV_OUTPUT = GS_HEADER_201-JOJANG ).
*    GS_HEADER_201-DRUM_CODE = P_DRUM.
*
*  ELSE.
*    READ TABLE GT_MAIN_DISP_200 INTO DATA(LS_TEMP) INDEX 1.
*
*    READ TABLE LT_CVMVAL INTO LS_CVMVAL WITH KEY MATNR = LS_TEMP-MATNR.
*    P_DSGNO = LS_CVMVAL-PDCADESIGNNO.
*    P_REVNO = LS_CVMVAL-PDCADESIGNREVNO.
*    P_MILEN = LS_TEMP-INLENGTH.
*
*    CASE LS_CVMVAL-WERKS.
*      WHEN '6500'.
*        P_YUSCD = 'FG'.
*      WHEN '6600'.
*        P_YUSCD = 'FJ'.
*    ENDCASE.
*
*    CLEAR GS_HEADER_201.
*    GS_HEADER_201-SUL_NO = P_DSGNO.
*    GS_HEADER_201-REV_SEQ = P_REVNO.
*    GS_HEADER_201-JAKNO = LV_ZZYUSCD.
*    NEW ZGTPP_CL_CONV( )->CONVERT_STRING_TO_QTY( EXPORTING IV_INPUT  = CONV #( P_MILEN )
*                                           IMPORTING EV_OUTPUT = GS_HEADER_201-JOJANG ).
*    CONDENSE GS_HEADER_201-JOJANG.
*    GS_HEADER_201-DRUM_CODE = P_DRUM.
*
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DISP_DATA_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_DISP_DATA_PR .

  CHECK GT_MAIN_DISP_200 IS NOT INITIAL.

  SELECT B~*
    FROM @GT_MAIN_DISP_200 AS A
    INNER JOIN ZGTPPT2450 AS B ON B~BANFN = A~BANFN
                              AND B~BNFPO = A~BNFPO
    INTO TABLE @GT_2450.

  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

    READ TABLE GT_2450 INTO DATA(LS_2450) WITH KEY BANFN = <LS_MAIN>-BANFN
                                                   BNFPO = <LS_MAIN>-BNFPO.
    IF SY-SUBRC EQ 0.
      <LS_MAIN>-IDNRK = LS_2450-MATNR_DM.
      <LS_MAIN>-IDNTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2450-MATNR_DM ).
    ENDIF.

  ENDLOOP.

*  PERFORM SET_LIST_DATA.

  SORT GT_MAIN_DISP_200 BY WERKS BANFN BNFPO.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SAVE_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SAVE_PR .

  DATA : LT_CHG_2450 TYPE TABLE OF ZGTPPT2450.
  DATA : LV_CHK_ERR.
  DATA : LV_MESSAGE TYPE BAPI_ORDER_RETURN-MESSAGE.

  IF NOT LINE_EXISTS( GT_MAIN_DISP_200[ CHECKED = ABAP_TRUE ] ).
    MESSAGE S006 DISPLAY LIKE 'E' WITH '변경사항등록을 위해 오더를 선택해 주세요.'(e19).
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '변경사항이 반영됩니다. 계속 진행 하시겠습니까?'
    '저장확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WHERE CHECKED = ABAP_TRUE.
    IF <LS_MAIN>-IDNRK2 IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '드럼자재(변경)에 설정된 드럼이 없습니다.'(E17).
      CONTINUE.
    ENDIF.

    IF <LS_MAIN>-IDNRK2 = <LS_MAIN>-IDNRK.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '변경할 내용이 없습니다.'(E18).
      CONTINUE.
    ENDIF.

    APPEND INITIAL LINE TO LT_CHG_2450 ASSIGNING FIELD-SYMBOL(<LS_2450>).
    <LS_2450>-BANFN = <LS_MAIN>-BANFN.
    <LS_2450>-BNFPO = <LS_MAIN>-BNFPO.
    <LS_2450>-MATNR_DM = <LS_MAIN>-IDNRK2.

    <LS_MAIN>-STATUS = ICON_LED_GREEN.
    <LS_MAIN>-MESSAGE = '변경사항등록 완료'.

  ENDLOOP.

  IF LT_CHG_2450[] IS NOT INITIAL.
    MODIFY ZGTPPT2450 FROM TABLE LT_CHG_2450.
    COMMIT WORK AND WAIT.

    REFRESH GT_2450.
    SELECT B~*
        FROM @GT_MAIN_DISP_200 AS A
        INNER JOIN ZGTPPT2450 AS B ON B~BANFN = A~BANFN
                                  AND B~BNFPO = A~BNFPO
        INTO TABLE @GT_2450.

  ENDIF.

  LOOP AT GT_MAIN_DISP_200 ASSIGNING <LS_MAIN> WHERE CHECKED = ABAP_TRUE.
    CLEAR <LS_MAIN>-CHECKED.
  ENDLOOP.


  PERFORM REFRESH_GRID USING GO_GRID_0200.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_AUTO_PR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_AUTO_PR .

  DATA : LS_CHK_INFOR LIKE GS_HEADER_201.
  DATA : LT_RETURN TYPE TABLE OF ZGTEDSIF0038.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LV_PACK_YN TYPE CHAR10.
  DATA : LV_PACK_DM TYPE MATNR.

  LT_MATNR = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_200 WHERE ( MATNR IS NOT INITIAL )
                    ( SIGN = 'I' OPTION ='EQ' LOW = LW_MAIN-MATNR ) ).

  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

  SELECT * FROM ZGTCVMSTVAL
     INTO TABLE @DATA(LT_CVMVAL)
    WHERE WERKS IN ( '6500', '6600' )
       AND MATNR IN @LT_MATNR.

* 드럼코드 'H' 로 지정(6500 플랜트만 해당)후 드럼자재 코드 입력
  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

    IF <LS_MAIN>-VBELN IS NOT INITIAL. " 판매오더에 연결된 오더는 판매오더포장재 참고하여 세팅
      CLEAR : LV_PACK_YN, LV_PACK_DM.
      ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
        EXPORTING
          IV_VBELN      =  <LS_MAIN>-VBELN                " 판매 관리 문서 번호
          IV_POSNR      = <LS_MAIN>-POSNR_SO                 " SD 문서의 품목 번호
        IMPORTING
          EV_PACK_YN    = LV_PACK_YN
          EV_PACK_DM  = LV_PACK_DM ).

      IF LV_PACK_DM IS NOT INITIAL. " 포장재 지정상태와 드럼유형만 대상
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            INPUT        = LV_PACK_DM
          IMPORTING
            OUTPUT       = LV_PACK_DM
          EXCEPTIONS
            LENGTH_ERROR = 1
            OTHERS       = 2.

        <LS_MAIN>-IDNRK2 = LV_PACK_DM.
        <LS_MAIN>-IDNTX2 = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LV_PACK_DM ).
        <LS_MAIN>-STATUS = ICON_LED_GREEN.
        <LS_MAIN>-MESSAGE = '드럼 자동지정 성공.'(E09).
        CONTINUE.
      ENDIF.
    ENDIF.

    CLEAR LS_CHK_INFOR.
    <LS_MAIN>-DRUM_TY = P_DRUM.
* 드럼정보 찾아오기 위한 데이터 구성
    LS_CHK_INFOR-WERKS = <LS_MAIN>-WERKS.
* 설계번호
    READ TABLE LT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY WERKS = <LS_MAIN>-WERKS
                                                      MATNR = <LS_MAIN>-MATNR.

    LS_CHK_INFOR-SUL_NO = LS_CVMVAL-PDCADESIGNNO.
    LS_CHK_INFOR-REV_SEQ = LS_CVMVAL-PDCADESIGNREVNO.
*  영업소 코드정보
    IF <LS_MAIN>-VBELN IS NOT INITIAL.
      SELECT SINGLE VBAP~MATNR, VBAP~CUOBJ, VBAK~VKORG, VBAK~VKGRP, VBAP~WERKS
       INTO @DATA(LS_SALES)
       FROM VBAP
       JOIN VBAK
         ON VBAP~VBELN EQ VBAK~VBELN
      WHERE VBAP~VBELN EQ @<LS_MAIN>-VBELN
        AND VBAP~POSNR EQ @<LS_MAIN>-POSNR.

      PERFORM GET_ZZYUSCD USING LS_SALES-VKORG LS_SALES-VKGRP LS_CHK_INFOR-JAKNO.
    ENDIF.

    IF LS_CHK_INFOR-JAKNO IS INITIAL.
      CASE <LS_MAIN>-WERKS.
        WHEN '6500'.
          LS_CHK_INFOR-JAKNO = 'FG'.
        WHEN '6600'.
          LS_CHK_INFOR-JAKNO = 'FJ'.
      ENDCASE.
    ENDIF.

    LS_CHK_INFOR-DRUM_CODE = <LS_MAIN>-DRUM_TY.
    LS_CHK_INFOR-JOJANG = <LS_MAIN>-INLENGTH + 0.
    CONDENSE LS_CHK_INFOR-JOJANG.

    REFRESH LT_RETURN.
    CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
      EXPORTING
        IV_SUL_NO    = LS_CHK_INFOR-SUL_NO
        IV_REV_SEQ   = LS_CHK_INFOR-REV_SEQ
        IV_JAKNO     = LS_CHK_INFOR-JAKNO
        IV_JOJANG    = LS_CHK_INFOR-JOJANG
        IV_DRUM_CODE = LS_CHK_INFOR-DRUM_CODE
        IV_FLAG_PP   = ABAP_TRUE
      TABLES
        OT_RETURN    = LT_RETURN.

    LOOP AT LT_RETURN INTO DATA(LS_RETURN).

      SELECT SINGLE A~MATNR, C~MAKTX
        FROM MARA AS A
        INNER JOIN MARC AS B ON B~MATNR = A~MATNR
        INNER JOIN MAKT AS C ON C~MATNR = A~MATNR
       WHERE A~MATNR = @LS_RETURN-DRUM_MATNR
         AND A~LVORM = ''
         AND B~WERKS = @LS_CHK_INFOR-WERKS
         AND B~MMSTA = ''
         AND B~LVORM = ''
         AND C~SPRAS = @SY-LANGU
        INTO ( @<LS_MAIN>-IDNRK2, @<LS_MAIN>-IDNTX2 ).
      IF SY-SUBRC EQ 0 AND <LS_MAIN>-IDNRK2 IS NOT INITIAL.
        <LS_MAIN>-STATUS = ICON_LED_GREEN.
        <LS_MAIN>-MESSAGE = '드럼 자동지정 성공.'(E09).
        EXIT.
      ENDIF.
    ENDLOOP.

    IF <LS_MAIN>-IDNRK2 IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '드럼 자동지정 대상이 없습니다.'(E10).
    ENDIF.

  ENDLOOP.


  DATA : LT_CHG_2450 TYPE TABLE OF ZGTPPT2450.
  DATA : LV_CHK_ERR.

  LOOP AT GT_MAIN_DISP_200 ASSIGNING <LS_MAIN> WHERE WERKS = '6500'.
    IF <LS_MAIN>-IDNRK2 IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '드럼자재(변경)에 설정된 드럼이 없습니다.'(E17).
      CONTINUE.
    ENDIF.

*    IF <LS_MAIN>-IDNRK2 = <LS_MAIN>-IDNRK.
*      <LS_MAIN>-STATUS = ICON_LED_RED.
*      <LS_MAIN>-MESSAGE = '변경할 내용이 없습니다.'(E18).
*      CONTINUE.
*    ENDIF.

    APPEND INITIAL LINE TO LT_CHG_2450 ASSIGNING FIELD-SYMBOL(<LS_2450>).
    <LS_2450>-BANFN = <LS_MAIN>-BANFN.
    <LS_2450>-BNFPO = <LS_MAIN>-BNFPO.
    <LS_2450>-MATNR_DM = <LS_MAIN>-IDNRK2.

    <LS_MAIN>-STATUS = ICON_LED_GREEN.
    <LS_MAIN>-MESSAGE = '변경사항등록 완료'.

  ENDLOOP.

  IF LT_CHG_2450[] IS NOT INITIAL.
    MODIFY ZGTPPT2450 FROM TABLE LT_CHG_2450.
    COMMIT WORK AND WAIT.

    REFRESH GT_2450.
    SELECT B~*
        FROM @GT_MAIN_DISP_200 AS A
        INNER JOIN ZGTPPT2450 AS B ON B~BANFN = A~BANFN
                                  AND B~BNFPO = A~BNFPO
        INTO TABLE @GT_2450.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_BASED_ON_PURCH_ORDER2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_BASED_ON_PURCH_ORDER2 .

  DATA LT_CLOBJDAT TYPE TT_CLOBJDAT.
  DATA LT_CONF TYPE TT_CONF_OUT.
  DATA LV_ZZYUSCD TYPE ZGTEYUSCD.
  DATA LV_ORDTP TYPE CHAR10.
  DATA : LV_INLENGTH TYPE ZGTPPT2000-INLENGTH.

  CLEAR: P_MATNR, P_DSGNO, P_REVNO, P_YUSCD, P_MILEN.

  IF S_EBELN IS INITIAL OR S_EBELP IS INITIAL.
    IF SSCRFIELDS-UCOMM EQ GC_FCODE-ONLI.
      MESSAGE E026 WITH TEXT-F34 DISPLAY LIKE 'S'.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

*  IF P_DRUM IS INITIAL.
*    IF SSCRFIELDS-UCOMM EQ GC_FCODE-ONLI.
*      MESSAGE E026 WITH TEXT-F33 DISPLAY LIKE 'S'.
*    ELSE.
*      RETURN.
*    ENDIF.
*  ENDIF.

  LV_ORDTP = TEXT-T21.

  SELECT DISTINCT EKPO~EBELN,  EKPO~EBELP,
         EKPO~WERKS, EKPO~MATNR, EKPO~MENGE AS PSMNG, EKPO~MEINS, MKT1~MAKTX,
         EKPO~CUOBJ, RESB~MATNR AS IDNRK, MKT2~MAKTX AS IDNTX, RESB~BDMNG AS ERFMG,
         RESB~MEINS AS ERFME, @LV_ORDTP AS ORDTP
    INTO TABLE @DATA(LT_EKPO)
    FROM EKPO
    JOIN RESB
      ON EKPO~EBELN EQ RESB~EBELN
     AND EKPO~EBELP EQ RESB~EBELP
    JOIN MARA
      ON RESB~MATNR EQ MARA~MATNR
    JOIN MAKT AS MKT1
      ON EKPO~MATNR EQ MKT1~MATNR
     AND MKT1~SPRAS EQ @SY-LANGU
    JOIN MAKT AS MKT2
      ON RESB~MATNR EQ MKT2~MATNR
     AND MKT2~SPRAS EQ @SY-LANGU
   WHERE RESB~EBELN IN @S_EBELN
     AND RESB~EBELP IN @S_EBELP
     AND EKPO~LOEKZ = ' '
     AND ( MARA~MTART IN ( @ZGTPP_IF_CONST=>GC_MTART-MRM1,
                           @ZGTPP_IF_CONST=>GC_MTART-MRM2 )
        OR MARA~MATKL EQ 'RW600406' ).

  IF SY-SUBRC IS NOT INITIAL AND SSCRFIELDS-UCOMM EQ GC_FCODE-ONLI.
    MESSAGE E000 WITH TEXT-E05 DISPLAY LIKE 'S'.
  ENDIF.

  IF LT_EKPO[] IS NOT INITIAL.
    SELECT DISTINCT A~EBELN , A~EBELP, B~VBELN, B~VBELP
      FROM @LT_EKPO AS A
      INNER JOIN EKKN AS B ON B~EBELN = A~EBELN
                          AND B~EBELP = A~EBELP
      INTO TABLE @DATA(LT_EKKN).
  ENDIF.

  REFRESH GT_MAIN_DISP_200.

  LOOP AT LT_EKPO INTO DATA(LS_EKPO).
    CLEAR GS_MAIN_DISP_200.
    MOVE-CORRESPONDING LS_EKPO TO GS_MAIN_DISP_200.
* 판매오더정보
    READ TABLE LT_EKKN INTO DATA(LS_EKKN) WITH KEY EBELN = LS_EKPO-EBELN
                                                   EBELP = LS_EKPO-EBELP.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_200-VBELN = LS_EKKN-VBELN.
      GS_MAIN_DISP_200-POSNR_SO = LS_EKKN-VBELP.
    ENDIF.

*조장(기본단위)
*조장수
    CLEAR LV_INLENGTH.
    ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
      EXPORTING
        IV_CUOBJ      = LS_EKPO-CUOBJ                 " 구성
      IMPORTING
        EV_ZGTEINDLEN = LV_INLENGTH ).

    IF LV_INLENGTH NE 0.
      GS_MAIN_DISP_200-INLENGTH = LV_INLENGTH.
    ELSE.
      GS_MAIN_DISP_200-INLENGTH = GS_MAIN_DISP_200-PSMNG.
    ENDIF.

    APPEND GS_MAIN_DISP_200 TO GT_MAIN_DISP_200.

  ENDLOOP.

*  CHECK GT_MAIN_DISP_200 IS NOT INITIAL.
*
*  DATA(LS_ORDER) = VALUE #( GT_MAIN_DISP_200[ 1 ] OPTIONAL ).
*
*  READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS WITH KEY FLD_01 = LS_ORDER-WERKS
*                                                           FLD_02 = P_DRUM.
*  IF SY-SUBRC IS NOT INITIAL.
*    MESSAGE E000 WITH TEXT-E06 DISPLAY LIKE 'S'.
*  ENDIF.
*
*  P_MATNR = LS_ORDER-MATNR.
*
*  PERFORM GET_CLASSIFICATION USING LS_ORDER-MATNR LT_CLOBJDAT.
*
*  P_DSGNO = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_DESIGN_NO' ]-AUSP1 OPTIONAL ).
*  P_REVNO = VALUE #( LT_CLOBJDAT[ ATNAM = 'PD_CA_DESIGN_REV_NO' ]-AUSP1 OPTIONAL ).
*
*  P_MILEN = LS_ORDER-INLENGTH.
*
*  P_YUSCD = COND #( WHEN LS_ORDER-WERKS EQ GC_WERKS-6500 THEN 'FG'
*                    WHEN LS_ORDER-WERKS EQ GC_WERKS-6600 THEN 'FJ' ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DISP_DATA_PURORD2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_DISP_DATA_PURORD2 .

* 판매오더 실행시 입력된 드럼 코드 기준으로 하위 화면 보여준다.
*  IF P_SLSORD = ABAP_TRUE.
*
*    PERFORM SET_LIST_DATA.
*
*  ENDIF.

  SORT GT_MAIN_DISP_200 BY WERKS EBELN EBELP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SAVE_Po
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_SAVE_PO .

  DATA : LV_CHK_ERR.
  DATA : LV_MESSAGE TYPE BAPI_ORDER_RETURN-MESSAGE.
  DATA : LT_MESSTAB TYPE TABLE OF BDCMSGCOLL.
  DATA : LS_OPTION TYPE CTU_PARAMS.
  LS_OPTION-DISMODE = 'N'.
  LS_OPTION-UPDMODE = 'S'.


  IF NOT LINE_EXISTS( GT_MAIN_DISP_200[ CHECKED = ABAP_TRUE ] ).
    MESSAGE S006 DISPLAY LIKE 'E' WITH '변경사항등록을 위해 오더를 선택해 주세요.'(e19).
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '변경사항이 반영됩니다. 계속 진행 하시겠습니까?'
    '저장확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WHERE CHECKED = ABAP_TRUE.
    IF <LS_MAIN>-IDNRK2 IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '드럼자재(변경)에 설정된 드럼이 없습니다.'(E17).
      CONTINUE.
    ENDIF.

    IF <LS_MAIN>-IDNRK2 = <LS_MAIN>-IDNRK.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '변경할 내용이 없습니다.'(E18).
      CONTINUE.
    ENDIF.

*  구매오더 변경 BDC수행
    REFRESH LT_MESSTAB.
    PERFORM BUILD_BDC_DATA2 USING <LS_MAIN>.

    CALL TRANSACTION 'ME22' USING GT_BDCDATA OPTIONS  FROM LS_OPTION
                                             MESSAGES INTO LT_MESSTAB.

    READ TABLE LT_MESSTAB INTO DATA(LS_MESSTAB) WITH KEY MSGTYP = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                                         MSGID  = '06'
                                                         MSGNR  = '023'.
    IF SY-SUBRC IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_GREEN.
      <LS_MAIN>-MESSAGE = '변경사항등록 완료'.
    ELSE.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      LS_MESSTAB = VALUE #( LT_MESSTAB[ MSGTYP = ZGTPP_IF_CONST=>GC_RESULT-ERROR ] OPTIONAL ).
      MESSAGE ID LS_MESSTAB-MSGID TYPE LS_MESSTAB-MSGTYP NUMBER LS_MESSTAB-MSGNR WITH LS_MESSTAB-MSGV1 LS_MESSTAB-MSGV2 LS_MESSTAB-MSGV3 LS_MESSTAB-MSGV4
     INTO <LS_MAIN>-MESSAGE.
    ENDIF.

  ENDLOOP.


  LOOP AT GT_MAIN_DISP_200 ASSIGNING <LS_MAIN> WHERE CHECKED = ABAP_TRUE.
    CLEAR <LS_MAIN>-CHECKED.
  ENDLOOP.


  PERFORM REFRESH_GRID USING GO_GRID_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUILD_BDC_DATA2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>
*&---------------------------------------------------------------------*
FORM BUILD_BDC_DATA2  USING    PS_MAIN LIKE GS_MAIN_DISP_200.

  DATA LV_MENGE TYPE CHAR18.

  WRITE PS_MAIN-ERFMG UNIT PS_MAIN-ERFME TO LV_MENGE LEFT-JUSTIFIED.

  GT_BDCDATA = VALUE #( ( DYNBEGIN = 'X'  PROGRAM = 'SAPMM06E'               DYNPRO = '0105' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '/00' )
                        ( DYNBEGIN = ' '  FNAM    = 'RM06E-BSTNR'            FVAL   = PS_MAIN-EBELN )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPMM06E'               DYNPRO = '0120' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '/00' )
                        ( DYNBEGIN = ' '  FNAM    = 'RM06E-EBELP'            FVAL   = PS_MAIN-EBELP )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPMM06E'               DYNPRO = '0120' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=LB' )
                        ( DYNBEGIN = ' '  FNAM    = 'RM06E-TCSELFLAG(01)'    FVAL   = 'X' )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLM61Q'               DYNPRO = '0115' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=SUCH' )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLM61Q'               DYNPRO = '0300' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '/00' )
                        ( DYNBEGIN = ' '  FNAM    = 'SUCHL-MATNR'            FVAL   = PS_MAIN-IDNRK )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLM61Q'               DYNPRO = '0115' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '/00' )
                        ( DYNBEGIN = ' '  FNAM    = 'MDPM-MATNR(01)'         FVAL   = PS_MAIN-IDNRK2 )
                        ( DYNBEGIN = ' '  FNAM    = 'MDPM-ERFMG(01)'         FVAL   = LV_MENGE )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPLM61Q'               DYNPRO = '0115' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=BACK' )

                        ( DYNBEGIN = 'X'  PROGRAM = 'SAPMM06E'               DYNPRO = '0120' )
                        ( DYNBEGIN = ' '  FNAM    = 'BDC_OKCODE'             FVAL   = '=BU' ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_AUTO_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_AUTO_PO .

  DATA : LS_CHK_INFOR LIKE GS_HEADER_201.
  DATA : LT_RETURN TYPE TABLE OF ZGTEDSIF0038.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LV_PACK_YN TYPE CHAR10.
  DATA : LV_PACK_DM TYPE MATNR.
  DATA : LV_CHK_ERR.
  DATA : LV_MESSAGE TYPE BAPI_ORDER_RETURN-MESSAGE.
  DATA : LT_MESSTAB TYPE TABLE OF BDCMSGCOLL.
  DATA : LS_OPTION TYPE CTU_PARAMS.
  LS_OPTION-DISMODE = 'N'.
  LS_OPTION-UPDMODE = 'S'.

  LT_MATNR = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_200 WHERE ( MATNR IS NOT INITIAL )
                    ( SIGN = 'I' OPTION ='EQ' LOW = LW_MAIN-MATNR ) ).

  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

  SELECT * FROM ZGTCVMSTVAL
     INTO TABLE @DATA(LT_CVMVAL)
    WHERE WERKS IN ( '6500', '6600' )
       AND MATNR IN @LT_MATNR.

* 드럼코드 'H' 로 지정(6500 플랜트만 해당)후 드럼자재 코드 입력
  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

    IF <LS_MAIN>-VBELN IS NOT INITIAL. " 판매오더에 연결된 오더는 판매오더포장재 참고하여 세팅
      CLEAR : LV_PACK_YN, LV_PACK_DM.
      ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
        EXPORTING
          IV_VBELN      =  <LS_MAIN>-VBELN                " 판매 관리 문서 번호
          IV_POSNR      = <LS_MAIN>-POSNR_SO                 " SD 문서의 품목 번호
        IMPORTING
          EV_PACK_YN    = LV_PACK_YN
          EV_PACK_DM  = LV_PACK_DM ).

      IF LV_PACK_DM IS NOT INITIAL. " 포장재 지정상태와 드럼유형만 대상
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            INPUT        = LV_PACK_DM
          IMPORTING
            OUTPUT       = LV_PACK_DM
          EXCEPTIONS
            LENGTH_ERROR = 1
            OTHERS       = 2.

        <LS_MAIN>-IDNRK2 = LV_PACK_DM.
        <LS_MAIN>-IDNTX2 = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LV_PACK_DM ).
        <LS_MAIN>-STATUS = ICON_LED_GREEN.
        <LS_MAIN>-MESSAGE = '드럼 자동지정 성공.'(E09).
        CONTINUE.
      ENDIF.
    ENDIF.

    CLEAR LS_CHK_INFOR.
    <LS_MAIN>-DRUM_TY = P_DRUM.
* 드럼정보 찾아오기 위한 데이터 구성
    LS_CHK_INFOR-WERKS = <LS_MAIN>-WERKS.
* 설계번호
    READ TABLE LT_CVMVAL INTO DATA(LS_CVMVAL) WITH KEY WERKS = <LS_MAIN>-WERKS
                                                      MATNR = <LS_MAIN>-MATNR.

    LS_CHK_INFOR-SUL_NO = LS_CVMVAL-PDCADESIGNNO.
    LS_CHK_INFOR-REV_SEQ = LS_CVMVAL-PDCADESIGNREVNO.
*  영업소 코드정보
    IF <LS_MAIN>-VBELN IS NOT INITIAL.
      SELECT SINGLE VBAP~MATNR, VBAP~CUOBJ, VBAK~VKORG, VBAK~VKGRP, VBAP~WERKS
       INTO @DATA(LS_SALES)
       FROM VBAP
       JOIN VBAK
         ON VBAP~VBELN EQ VBAK~VBELN
      WHERE VBAP~VBELN EQ @<LS_MAIN>-VBELN
        AND VBAP~POSNR EQ @<LS_MAIN>-POSNR.

      PERFORM GET_ZZYUSCD USING LS_SALES-VKORG LS_SALES-VKGRP LS_CHK_INFOR-JAKNO.
    ENDIF.

    IF LS_CHK_INFOR-JAKNO IS INITIAL.
      CASE <LS_MAIN>-WERKS.
        WHEN '6500'.
          LS_CHK_INFOR-JAKNO = 'FG'.
        WHEN '6600'.
          LS_CHK_INFOR-JAKNO = 'FJ'.
      ENDCASE.
    ENDIF.

    LS_CHK_INFOR-DRUM_CODE = <LS_MAIN>-DRUM_TY.
    LS_CHK_INFOR-JOJANG = <LS_MAIN>-INLENGTH + 0.
    CONDENSE LS_CHK_INFOR-JOJANG.

    REFRESH LT_RETURN.
    CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
      EXPORTING
        IV_SUL_NO    = LS_CHK_INFOR-SUL_NO
        IV_REV_SEQ   = LS_CHK_INFOR-REV_SEQ
        IV_JAKNO     = LS_CHK_INFOR-JAKNO
        IV_JOJANG    = LS_CHK_INFOR-JOJANG
        IV_DRUM_CODE = LS_CHK_INFOR-DRUM_CODE
        IV_FLAG_PP   = ABAP_TRUE
      TABLES
        OT_RETURN    = LT_RETURN.

    LOOP AT LT_RETURN INTO DATA(LS_RETURN).

      SELECT SINGLE A~MATNR, C~MAKTX
        FROM MARA AS A
        INNER JOIN MARC AS B ON B~MATNR = A~MATNR
        INNER JOIN MAKT AS C ON C~MATNR = A~MATNR
       WHERE A~MATNR = @LS_RETURN-DRUM_MATNR
         AND A~LVORM = ''
         AND B~WERKS = @LS_CHK_INFOR-WERKS
         AND B~MMSTA = ''
         AND B~LVORM = ''
         AND C~SPRAS = @SY-LANGU
        INTO ( @<LS_MAIN>-IDNRK2, @<LS_MAIN>-IDNTX2 ).
      IF SY-SUBRC EQ 0 AND <LS_MAIN>-IDNRK2 IS NOT INITIAL.
        <LS_MAIN>-STATUS = ICON_LED_GREEN.
        <LS_MAIN>-MESSAGE = '드럼 자동지정 성공.'(E09).
        EXIT.
      ENDIF.
    ENDLOOP.

    IF <LS_MAIN>-IDNRK2 IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '드럼 자동지정 대상이 없습니다.'(E10).
    ENDIF.

  ENDLOOP.


  LOOP AT GT_MAIN_DISP_200 ASSIGNING <LS_MAIN> WHERE WERKS = '6500'.
    IF <LS_MAIN>-IDNRK2 IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      <LS_MAIN>-MESSAGE = '드럼자재(변경)에 설정된 드럼이 없습니다.'(E17).
      CONTINUE.
    ENDIF.

*    IF <LS_MAIN>-IDNRK2 = <LS_MAIN>-IDNRK.
*      <LS_MAIN>-STATUS = ICON_LED_RED.
*      <LS_MAIN>-MESSAGE = '변경할 내용이 없습니다.'(E18).
*      CONTINUE.
*    ENDIF.

*  구매오더 변경 BDC수행
    REFRESH LT_MESSTAB.
    PERFORM BUILD_BDC_DATA2 USING <LS_MAIN>.

    CALL TRANSACTION 'ME22' USING GT_BDCDATA OPTIONS  FROM LS_OPTION
                                             MESSAGES INTO LT_MESSTAB.

    READ TABLE LT_MESSTAB INTO DATA(LS_MESSTAB) WITH KEY MSGTYP = ZGTPP_IF_CONST=>GC_RESULT-SUCCESS
                                                         MSGID  = '06'
                                                         MSGNR  = '023'.
    IF SY-SUBRC IS INITIAL.
      <LS_MAIN>-STATUS = ICON_LED_GREEN.
      <LS_MAIN>-MESSAGE = '변경사항등록 완료'.
    ELSE.
      <LS_MAIN>-STATUS = ICON_LED_RED.
      LS_MESSTAB = VALUE #( LT_MESSTAB[ MSGTYP = ZGTPP_IF_CONST=>GC_RESULT-ERROR ] OPTIONAL ).
      MESSAGE ID LS_MESSTAB-MSGID TYPE LS_MESSTAB-MSGTYP NUMBER LS_MESSTAB-MSGNR WITH LS_MESSTAB-MSGV1 LS_MESSTAB-MSGV2 LS_MESSTAB-MSGV3 LS_MESSTAB-MSGV4
     INTO <LS_MAIN>-MESSAGE.
    ENDIF.

  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESB_INPUT_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>
*&      <-- LV_CHK_ERR
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM RESB_INPUT_CHECK  USING    PS_MAIN LIKE GS_MAIN_DISP_200
                         CHANGING PV_ERROR
                                  PV_MESSAGE.

  SELECT B~AUFNR, B~MBLNR
    FROM RESB AS A
    INNER JOIN MATDOC AS B ON B~AUFNR = A~AUFNR
                          AND B~WERKS = A~WERKS
                          AND B~RSNUM = A~RSNUM
                          AND B~RSPOS = A~RSPOS
    INNER JOIN MARA AS C ON C~MATNR = A~MATNR
    INTO TABLE @DATA(LT_MATDOC)
   WHERE A~AUFNR = @PS_MAIN-AUFNR
     AND A~MATNR = @PS_MAIN-MATNR
     AND ( C~MTART IN ( @ZGTPP_IF_CONST=>GC_MTART-MRM1,
                           @ZGTPP_IF_CONST=>GC_MTART-MRM2 )
      OR C~MATKL EQ 'RW600406' )
     AND B~BWART = '261'
     AND CANCELLED = ' '.
  IF SY-SUBRC EQ 0.
    PV_ERROR = ABAP_TRUE.
    PV_MESSAGE = '오더의 드럼자재 투입처리된 내역이 있어 드럼 변경할 수 없습니다.'(e23).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_ORD_STST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_ORD_STST USING PS_MOSU LIKE GS_MAIN_DISP_200.

*  갱신된 생산오더정보 MES 전송
  DATA : LV_JOBNAME  TYPE TBTCJOB-JOBNAME VALUE 'SUBMIT_ZGTPPI2010_'.
  DATA : LV_JOBNAME01  TYPE TBTCJOB-JOBNAME.
  DATA : LV_JOBCOUNT TYPE TBTCJOB-JOBCOUNT.
  DATA : LT_SELTAB   TYPE TABLE OF RSPARAMS.
  STATICS : LV_GUBUN(10) TYPE N.

  WAIT UP TO '0.3' SECONDS.

  ADD 1 TO LV_GUBUN.
  CLEAR LV_JOBNAME01.
  LV_JOBNAME01 = LV_JOBNAME && LV_GUBUN.

  REFRESH LT_SELTAB.
  APPEND VALUE #( SELNAME = 'S_AUFNR' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = PS_MOSU-AUFNR ) TO LT_SELTAB.
  LT_SELTAB = VALUE #( BASE LT_SELTAB ( SELNAME = 'S_ERDAT' KIND = 'S' SIGN = 'I' OPTION = 'BT' LOW = ( SY-DATUM - 365 ) HIGH = SY-DATUM )
                                      ( SELNAME = 'P_R1'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_TRUE  )    "// 처리모드
                                      ( SELNAME = 'P_R2'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_FALSE )
                                      ( SELNAME = 'P_R3'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_FALSE )    "// 대상시스템.
                                      ( SELNAME = 'P_R4'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_FALSE )
                                      ( SELNAME = 'P_R9'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_FALSE )
                                      ( SELNAME = 'P_R10'   KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = COND #( WHEN PS_MOSU-WERKS EQ '6500' THEN ABAP_TRUE ) )
                                      ( SELNAME = 'P_R11'   KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = COND #( WHEN PS_MOSU-WERKS EQ '6600' THEN ABAP_TRUE ) )
                                      ( SELNAME = 'P_R8'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = ABAP_TRUE   ) ). "// 배치처리.

  PERFORM BATCH_JOB_OPEN USING LV_JOBNAME01 LV_JOBCOUNT.

  CHECK LV_JOBCOUNT IS NOT INITIAL.

  SUBMIT ZGTPPI2010 VIA JOB LV_JOBNAME01 NUMBER LV_JOBCOUNT
                    WITH SELECTION-TABLE LT_SELTAB
                    AND RETURN.

  PERFORM BATCH_JOB_CLOSE USING LV_JOBNAME01 LV_JOBCOUNT.

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
*& Form PROC_BATCH_PRD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_BATCH_PRD .

* 드럼 변경사항 저장
  DATA : LT_CHECKD_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_MOSU LIKE TABLE OF GS_MAIN_DISP_200.
  DATA : LT_SORTED_MOSU LIKE TABLE OF GS_MAIN_DISP_200.
  DATA : LV_CHK_ERR.
  DATA : LV_MESSAGE TYPE BAPI_ORDER_RETURN-MESSAGE.

  LOOP AT GT_MAIN_DISP_200 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = <LS_MAIN>-AUFNR
                                                   POSNR+2(4) = <LS_MAIN>-POSNR
                                                   ORDTY = 'PRD'.
    IF SY-SUBRC EQ 0 AND LS_2010-MATNR_DM IS NOT INITIAL.
      APPEND <LS_MAIN> TO LT_MOSU.

      READ TABLE LT_CHECKD_2010 ASSIGNING FIELD-SYMBOL(<LS_CHECKED_2010>) WITH KEY ORDNR = <LS_MAIN>-AUFNR
                                                                                   POSNR+2(4) = <LS_MAIN>-POSNR.
      IF SY-SUBRC NE 0.
        REFRESH LT_2010.
        LT_2010 = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( GRPNR = LS_2010-GRPNR
                                                    AND   ORDNR = LS_2010-ORDNR )
                         ( CORRESPONDING #( LW_2010 ) ) ).
        APPEND LINES OF LT_2010 TO LT_CHECKD_2010.
      ENDIF.
    ENDIF.
  ENDLOOP.

* 포장재는 오더 단위로 저장이 되므로 오더 단위로 반영진행
  LT_SORTED_MOSU = LT_MOSU.
  SORT LT_SORTED_MOSU BY AUFNR.
  DELETE ADJACENT DUPLICATES FROM LT_SORTED_MOSU COMPARING AUFNR.

  LOOP AT LT_SORTED_MOSU INTO DATA(LS_SORTED_MOSU).
    CLEAR : LV_CHK_ERR, LV_MESSAGE.

    PERFORM CHG_ORDER_JOJANGE TABLES LT_2010
                               USING LS_SORTED_MOSU
                            CHANGING LV_CHK_ERR LV_MESSAGE.

    IF LV_CHK_ERR = 'E'.
* 드럼반영 실패시 조장내 드럼정보 초기화
      REFRESH LT_2010.
      LT_2010 = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( GRPNR = LS_2010-GRPNR
                                                    AND   ORDNR = LS_2010-ORDNR )
                         ( CORRESPONDING #( LW_2010 ) ) ).

      LOOP AT LT_2010 ASSIGNING FIELD-SYMBOL(<LS_2010_DM_DEL>).
        CLEAR <LS_2010_DM_DEL>-MATNR_DM.
      ENDLOOP.

      MODIFY ZGTPPT2010 FROM TABLE LT_2010.
      COMMIT WORK AND WAIT.
    ENDIF.

*  드럼정보 변경 실패시 드럼정보 초기화 되므로 업데이트 진행해준다.
    IF LV_CHK_ERR EQ 'E'.
      PERFORM SEND_ORD_STST USING LS_SORTED_MOSU.
    ENDIF.

  ENDLOOP.


ENDFORM.
