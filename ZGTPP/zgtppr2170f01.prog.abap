*&---------------------------------------------------------------------*
*& Include          ZGTPPR2170F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INITIALIZATION.

  GR_CONV = NEW #( ).

  GET PARAMETER ID 'WRK' FIELD P_WERKS.

  PERFORM GET_PARAMETER_DESCRIPTION.

  IF S_CRDAT[] IS INITIAL.  "주문할당일자
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
  PERFORM DISPLAY_PROCESSING_RESULTS. "// 지시 결과 조회/취소.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form end_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM END_OF_SELECTION .

  IF GT_CUTTING IS INITIAL AND GT_ALLOC IS INITIAL.
    MESSAGE S033.
    LEAVE LIST-PROCESSING.
  ENDIF.

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

  IF GR_CUTTING IS BOUND.
    GR_CUTTING->FREE( ).
    CLEAR GR_CUTTING.
  ENDIF.

  IF GR_ALLOC IS BOUND.
    GR_ALLOC->FREE( ).
    CLEAR GR_ALLOC.
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

  IF PR_SENDER EQ GR_CUTTING.
    PERFORM MODIFY_FCAT_IN_CUTTING.
  ENDIF.

  IF PR_SENDER EQ GR_ALLOC.
    PERFORM MODIFY_FCAT_IN_ALLOC.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_LAYOUT USING PR_SENDER.

  IF PR_SENDER EQ GR_CUTTING.
    PERFORM SET_LAYOUT_IN_CUTTING.
  ENDIF.

  IF PR_SENDER EQ GR_ALLOC.
    PERFORM SET_LAYOUT_IN_ALLOC.
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
        MODIFY SCREEN FROM LS_SCREEN.
    ENDCASE.
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
  PERFORM CHECK_PLANT_CODE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_screen_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_100 .

  GV_TPAR1 = TEXT-C12.

  CALL SCREEN 100.

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
      MESSAGE LR_ROOT->GET_TEXT( ) TYPE 'E'.
  ENDTRY.

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

  CALL FUNCTION 'DDIF_DOMA_GET'
    EXPORTING
      NAME          = 'ZGTDZORD_TYPE'
      LANGU         = SY-LANGU
    TABLES
      DD07V_TAB     = GT_DD07V
    EXCEPTIONS
      ILLEGAL_INPUT = 1
      OTHERS        = 2.

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
        LR_FCAT->COLTEXT    = TEXT-FC6.
        LR_FCAT->JUST       = 'C'.

      WHEN 'PRINT_STAT_TXT'.
        LR_FCAT->COLTEXT    = TEXT-FC5.
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
        LR_FCAT->COLTEXT    = TEXT-FC8.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F69.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F70.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'F_CHARG'.
        LR_FCAT->COLTEXT    = TEXT-F71.
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
        LR_FCAT->COLTEXT    = TEXT-FD3.

      WHEN 'ZCUT_BUDAT'.
        LR_FCAT->COLTEXT    = TEXT-FD4.

      WHEN 'ZCUT_RLEN'.
        LR_FCAT->COLTEXT    = TEXT-FC3.

      WHEN 'ZCUT_SCRAP'.
        LR_FCAT->COLTEXT    = TEXT-FC7.

      WHEN 'ZCUT_LEN_STAT'.
        LR_FCAT->COLTEXT    = TEXT-FC4.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ORG_LENGTH'.
        LR_FCAT->COLTEXT    = TEXT-FC9.

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

      WHEN 'F_CHARG_ORG'.
        LR_FCAT->COLTEXT    = TEXT-FD6.

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
        LR_FCAT->COLTEXT    = TEXT-FC6.
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
        LR_FCAT->COLTEXT    = TEXT-FC8.
        LR_FCAT->JUST       = 'C'.
*        LR_FCAT->EMPHASIZE  = 'C110'.

      WHEN 'EDATU'.
        LR_FCAT->COLTEXT    = TEXT-F06.
        LR_FCAT->JUST       = 'C'.

      WHEN 'DRDAT'.
        LR_FCAT->COLTEXT    = TEXT-FD1.
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

      WHEN 'F_CHARG_ORG'.
        LR_FCAT->COLTEXT    = TEXT-FD6.

*      WHEN 'ZEXCLUDE'.
*        LR_FCAT->COLTEXT    = TEXT-F34.
*        LR_FCAT->CHECKBOX   = ABAP_TRUE.

      WHEN 'MENGE413'.
        LR_FCAT->COLTEXT    = TEXT-FD5.

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
*& Form get_cutting_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_CUTTING_RESULT .

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

    "배치번호(실제), 절단 전기일자
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

  "배치번호(실제)
  IF S_ACHARG[] IS NOT INITIAL.
    DELETE GT_CUTTING WHERE A_CHARG NOT IN S_ACHARG.
  ENDIF.

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
    IF LR_ALLOC->ZUPT_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR.
      LR_ALLOC->STATUS = ICON_LED_RED.
      LR_ALLOC->RETURN = VALUE #( ( TYPE = 'E' FIELD = TEXT-F01 MESSAGE = LR_ALLOC->ZUPT_MSG )  ).
    ENDIF.

    "출하요청
    READ TABLE LT_ZLET0401 INTO DATA(LS_ZLET0401) WITH KEY VBELN = LR_ALLOC->VBELN
                                                           POSNR = LR_ALLOC->POSNR BINARY SEARCH.

    IF SY-SUBRC IS INITIAL.
      LR_ALLOC->SHREQ = ICON_LED_GREEN.
      LR_ALLOC->DRDAT = LS_ZLET0401-DRDAT.
    ENDIF.

    "413처리 수량
    SELECT SINGLE SUM( MENGE ) AS MENGE
      FROM MATDOC
     WHERE KDAUF EQ @LR_ALLOC->VBELN
       AND KDPOS EQ @LR_ALLOC->POSNR
       AND CANCELLED EQ @SPACE
       AND BWART EQ '413'
      INTO @LR_ALLOC->MENGE413.

    CLEAR: LS_ZLET0401.
  ENDLOOP.

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
*& Form get_parameter_description
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_PARAMETER_DESCRIPTION .

  CLEAR P_NAME1.

  IF P_WERKS IS NOT INITIAL.
    SELECT SINGLE NAME1
      INTO @P_NAME1
      FROM T001W
     WHERE WERKS EQ @P_WERKS.
  ENDIF.

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
