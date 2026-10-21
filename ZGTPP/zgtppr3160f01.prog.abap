*&---------------------------------------------------------------------*
*& Include          ZGTPPR3160F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INITIALIZATION.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form start_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM START_OF_SELECTION.

  PERFORM SET_CONDITION.
  PERFORM SELECT_ZGTPPT3360.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form end_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM END_OF_SELECTION .

  IF GT_LIST IS NOT INITIAL.
    IF P_BATCH IS INITIAL.
      PERFORM CALL_SCREEN_100.
    ELSE.
      PERFORM USER_COMMAND_REWORK.
    ENDIF.
  ELSE.
    MESSAGE S033.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_exit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_EXIT .

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
FORM HANDLE_FIELD_CATALOG .

  LOOP AT GR_LIST->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'AL_STAT_ICON'.
        LR_FCAT->COLTEXT    = TEXT-F01.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'TR_STAT_ICON'.
        LR_FCAT->COLTEXT    = TEXT-F02.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.
        IF P_CUT_SC EQ 'X'.
          LR_FCAT->NO_OUT = 'X'.
        ENDIF.

      WHEN 'CHK_STAT_ICON'.
        LR_FCAT->COLTEXT    = TEXT-F24.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'TR_MBLNR'.
        LR_FCAT->COLTEXT    = TEXT-F03.
        LR_FCAT->JUST       = 'C'.
        IF P_CUT_SC EQ 'X'.
          LR_FCAT->NO_OUT = 'X'.
        ENDIF.

      WHEN 'STAT_MSG'.
        LR_FCAT->COLTEXT    = TEXT-F04.
        IF P_CUT_SC EQ 'X'.
          LR_FCAT->NO_OUT = 'X'.
        ENDIF.

      WHEN 'CHK_MSG'.
        LR_FCAT->COLTEXT    = TEXT-F25.

      WHEN 'UPDRQ'.
        LR_FCAT->COLTEXT    = TEXT-F05.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'UPD_TYPE'.
        LR_FCAT->COLTEXT    = TEXT-F06.
        LR_FCAT->JUST       = 'C'.

      WHEN 'UPD_TYPE_TXT'.
        LR_FCAT->COLTEXT    = TEXT-F07.

      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-F08.
        LR_FCAT->JUST       = 'C'.

      WHEN 'NAME1'.
        LR_FCAT->COLTEXT    = TEXT-F09.

      WHEN 'TAGNR'.
        LR_FCAT->COLTEXT    = TEXT-F10.
        LR_FCAT->JUST       = 'C'.
        IF P_SHP EQ 'X'.
          LR_FCAT->NO_OUT = 'X'.
        ENDIF.

      WHEN 'ZCUT_ORD_NO'.
        LR_FCAT->COLTEXT    = TEXT-F11.
        LR_FCAT->JUST       = 'C'.
        IF P_SHP EQ 'X' OR P_SHP_SC EQ 'X'.
          LR_FCAT->NO_OUT = 'X'.
        ENDIF.

      WHEN 'ZCUT_ORD_ITEM'.
        LR_FCAT->COLTEXT    = TEXT-F12.
        LR_FCAT->JUST       = 'C'.
        IF P_SHP EQ 'X' OR P_SHP_SC EQ 'X'.
          LR_FCAT->NO_OUT = 'X'.
        ENDIF.

      WHEN 'DLVRQ'.
        LR_FCAT->COLTEXT    = TEXT-F13.
        LR_FCAT->JUST       = 'C'.
        IF P_CUT_SC EQ 'X' OR P_SHP_SC EQ 'X'.
          LR_FCAT->NO_OUT = 'X'.
        ENDIF.

      WHEN 'VBELN'.
        LR_FCAT->COLTEXT    = TEXT-F14.
        LR_FCAT->JUST       = 'C'.
        IF P_CUT_SC EQ 'X'.
          LR_FCAT->NO_OUT = 'X'.
        ENDIF.

      WHEN 'POSNR'.
        LR_FCAT->COLTEXT    = TEXT-F15.
        LR_FCAT->JUST       = 'C'.
        IF P_CUT_SC EQ 'X'.
          LR_FCAT->NO_OUT = 'X'.
        ENDIF.

      WHEN 'KWMENG'.
        LR_FCAT->COLTEXT    = TEXT-F16.
        IF P_CUT_SC EQ 'X' OR P_SHP_SC EQ 'X'.
          LR_FCAT->NO_OUT = 'X'.
        ENDIF.

      WHEN 'VRKME'.
        LR_FCAT->COLTEXT    = TEXT-F17.
        LR_FCAT->JUST       = 'C'.
        IF P_CUT_SC EQ 'X' OR P_SHP_SC EQ 'X'.
          LR_FCAT->NO_OUT = 'X'.
        ENDIF.

      WHEN 'CRDAT'.
        LR_FCAT->COLTEXT    = TEXT-F18.
        LR_FCAT->JUST       = 'C'.

      WHEN 'CRTIM'.
        LR_FCAT->COLTEXT    = TEXT-F19.
        LR_FCAT->JUST       = 'C'.

      WHEN 'CRNAM'.
        LR_FCAT->COLTEXT    = TEXT-F20.
        LR_FCAT->JUST       = 'C'.

      WHEN 'CHDAT'.
        LR_FCAT->COLTEXT    = TEXT-F21.
        LR_FCAT->JUST       = 'C'.

      WHEN 'CHTIM'.
        LR_FCAT->COLTEXT    = TEXT-F22.
        LR_FCAT->JUST       = 'C'.

      WHEN 'CHNAM'.
        LR_FCAT->COLTEXT    = TEXT-F23.
        LR_FCAT->JUST       = 'C'.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_LAYOUT .

  TRY.
*      gr_list->ms_layout-cwidth_opt = abap_false.

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form at_selection_screen_output
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM AT_SELECTION_SCREEN_OUTPUT .

  LOOP AT SCREEN INTO DATA(LS_SCREEN).
    CASE LS_SCREEN-GROUP1.
      WHEN 'REW'.
        IF P_REWORK EQ ABAP_FALSE.
          LS_SCREEN-ACTIVE = 0.
          MODIFY SCREEN FROM LS_SCREEN.
        ENDIF.

      WHEN OTHERS.
        CASE ABAP_TRUE.
          WHEN P_CUT_SC.
            IF LS_SCREEN-GROUP1+0(1) EQ '0'.
              LS_SCREEN-ACTIVE = 0.
              MODIFY SCREEN FROM LS_SCREEN.
            ENDIF.

          WHEN P_SHP.
            IF LS_SCREEN-GROUP1+1(1) EQ '0'.
              LS_SCREEN-ACTIVE = 0.
              MODIFY SCREEN FROM LS_SCREEN.
            ENDIF.

          WHEN P_SHP_SC.
            IF LS_SCREEN-GROUP1+2(1) EQ '0'.
              LS_SCREEN-ACTIVE = 0.
              MODIFY SCREEN FROM LS_SCREEN.
            ENDIF.
        ENDCASE.
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
*// 실행.
    WHEN GC_FCODE-ONLI.
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_screen_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_100 .

  GV_TPAR1 = COND #( WHEN P_CUT_SC EQ ABAP_TRUE THEN TEXT-C13
                     WHEN P_SHP    EQ ABAP_TRUE THEN TEXT-C14
                     WHEN P_SHP_SC EQ ABAP_TRUE THEN TEXT-C15 ).

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_zgtppt3360
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SELECT_ZGTPPT3360 .

  SELECT ZT01~*,
         T001W~NAME1,
         DD07T~DDTEXT AS UPD_TYPE_TXT,
         CASE WHEN ZT01~AL_STAT EQ @ZGTPP_IF_CONST=>GC_RESULT-SUCCESS THEN @ICON_LED_GREEN
              WHEN ZT01~AL_STAT EQ @ZGTPP_IF_CONST=>GC_RESULT-ERROR   THEN @ICON_LED_RED
              ELSE @ICON_LED_INACTIVE
         END AS AL_STAT_ICON,
         CASE WHEN ZT01~TR_STAT EQ @ZGTPP_IF_CONST=>GC_RESULT-SUCCESS THEN @ICON_LED_GREEN
              WHEN ZT01~TR_STAT EQ @ZGTPP_IF_CONST=>GC_RESULT-ERROR   THEN @ICON_LED_RED
              ELSE @ICON_LED_INACTIVE
         END AS TR_STAT_ICON,
         CASE WHEN ZT01~CHK_STAT EQ @ZGTPP_IF_CONST=>GC_RESULT-SUCCESS THEN @ICON_LED_GREEN
              WHEN ZT01~CHK_STAT EQ @ZGTPP_IF_CONST=>GC_RESULT-ERROR   THEN @ICON_LED_RED
              ELSE @ICON_LED_INACTIVE
         END AS CHK_STAT_ICON
    FROM ZGTPPT3360 AS ZT01
    JOIN T001W
      ON ZT01~WERKS EQ T001W~WERKS
    LEFT JOIN DD07L
      ON DD07L~DOMNAME  EQ 'ZGTDUPD_TYPE'
     AND DD07L~AS4LOCAL EQ 'A'
     AND ZT01~UPD_TYPE  EQ DD07L~DOMVALUE_L
    LEFT JOIN DD07T
      ON DD07L~DOMNAME    EQ DD07T~DOMNAME
     AND DD07L~VALPOS     EQ DD07T~VALPOS
     AND DD07L~AS4LOCAL   EQ DD07T~AS4LOCAL
     AND DD07T~DDLANGUAGE EQ @SY-LANGU
   WHERE ZT01~WERKS         EQ @P_WERKS
     AND ZT01~UPD_TYPE      IN @GT_UPD_TYPE
     AND ZT01~UPDRQ         IN @S_UPDRQ
     AND ZT01~TAGNR         IN @S_TAGNR
     AND ZT01~ZCUT_ORD_NO   IN @S_CUT_NO
     AND ZT01~ZCUT_ORD_ITEM IN @S_CUT_IT
     AND ZT01~DLVRQ         IN @S_DLVRQ
     AND ZT01~VBELN         IN @S_VBELN
     AND ZT01~POSNR         IN @S_POSNR
     AND ZT01~CRDAT         IN @S_CRDAT
     AND (GV_WHERE)
   ORDER BY ZT01~UPDRQ
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CONDITION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_CONDITION .

  GT_UPD_TYPE = COND #( WHEN P_CUT_SC EQ ABAP_TRUE THEN VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = ZGTPP_IF_CONST=>GC_UPD_TYPE-U1 )
                                                                                          ( LOW = ZGTPP_IF_CONST=>GC_UPD_TYPE-Z1 ) )
                        WHEN P_SHP    EQ ABAP_TRUE THEN VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = ZGTPP_IF_CONST=>GC_UPD_TYPE-U2 )
                                                                                          ( LOW = ZGTPP_IF_CONST=>GC_UPD_TYPE-Z2 ) )
                        WHEN P_SHP_SC EQ ABAP_TRUE THEN VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = ZGTPP_IF_CONST=>GC_UPD_TYPE-U3 )
                                                                                          ( LOW = ZGTPP_IF_CONST=>GC_UPD_TYPE-Z3 ) ) ).
  IF P_REWORK EQ ABAP_TRUE.
    GV_WHERE = |( zt01~al_stat NE @zgtpp_if_const=>gc_result-success OR | &&
               |  zt01~tr_stat EQ @zgtpp_if_const=>gc_result-error )|.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_print_top_of_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_PRINT_TOP_OF_LIST .

  WRITE:/(sy-linsz) TEXT-H00 CENTERED.

  FORMAT COLOR COL_HEADING.

  ULINE.

  WRITE:/(sy-linsz) |{ ICON_LIST }{ TEXT-H01 } { GS_RESULT-TOTAL   WIDTH = 10 ALIGN = RIGHT NUMBER = USER } { TEXT-H99 }|,
        /(sy-linsz) |{ ICON_LED_GREEN }{ TEXT-H02 } { GS_RESULT-SUCCESS WIDTH = 10 ALIGN = RIGHT NUMBER = USER } { TEXT-H99 }|,
        /(sy-linsz) |{ ICON_LED_RED }{ TEXT-H03 } { GS_RESULT-ERROR   WIDTH = 10 ALIGN = RIGHT NUMBER = USER } { TEXT-H99 }|.

  ULINE.

  FORMAT COLOR OFF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_rework
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_REWORK .

  TRY.
      PERFORM CHECK_BEFORE_REWORK. "// 사전점검.
      PERFORM RUN_REWORK.          "// 재처리.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        IF SY-BATCH IS NOT INITIAL.
          PERFORM HANDLE_PRINT_TOP_OF_LIST.
          WRITE:/ LR_EXCEPTION->GET_TEXT( ).
        ELSE.
          MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_rework
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_REWORK RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  PERFORM GET_ROWS_SELECTED_FOR_REWORK.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E11.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E13.
  ENDIF.

  IF P_BATCH IS INITIAL.
    PERFORM CONFIRMATION_POPUP USING TEXT-C04 LV_ANSWER.

    IF LV_ANSWER NE '1'.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_for_REWORK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_FOR_REWORK .

  CLEAR GS_RESULT.

  IF P_BATCH IS NOT INITIAL.
    MODIFY GT_LIST FROM VALUE #( SEL = ABAP_TRUE )
                   TRANSPORTING SEL
                   WHERE SEL EQ ABAP_FALSE.
    GS_RESULT-TOTAL = LINES( GT_LIST ).
    GS_RESULT-SEL = GS_RESULT-TOTAL.
    RETURN.
  ENDIF.

  MODIFY GT_LIST FROM VALUE #( SEL = ABAP_FALSE )
                 TRANSPORTING SEL
                 WHERE SEL EQ ABAP_TRUE.

  GR_LIST->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    GS_RESULT-SEL += 1.

    READ TABLE GT_LIST REFERENCE INTO DATA(LR_LIST) INDEX LS_ROW-INDEX.
    CHECK SY-SUBRC IS INITIAL.

    CHECK LR_LIST->AL_STAT_ICON NE ICON_LED_GREEN AND
          LR_LIST->TR_STAT_ICON NE ICON_LED_GREEN.

    GS_RESULT-TOTAL += 1.

    LR_LIST->SEL = ABAP_TRUE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form run_rework
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM RUN_REWORK .
  DATA LT_ITEM   TYPE TABLE OF ZGTPPSIF0044.
  DATA LT_RETURN TYPE TABLE OF ZGTPPSIF0045.

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST)
                  WHERE SEL EQ ABAP_TRUE.
    CLEAR: LT_ITEM, LT_RETURN.

    APPEND INITIAL LINE TO LT_ITEM REFERENCE INTO DATA(LR_ITEM).
    LR_ITEM->* = CORRESPONDING #( LR_LIST->* ).
    LR_ITEM->SEQNO = 1.
    LR_ITEM->BUDAT = LR_LIST->CHDAT.

    CALL FUNCTION 'ZGTPP_LINK_INFO_UPDATE'
      EXPORTING
        I_WERKS    = LR_LIST->WERKS
        I_UPD_TYPE = LR_LIST->UPD_TYPE
        I_UPDRQ    = LR_LIST->UPDRQ
      TABLES
        IT_ITEM    = LT_ITEM
        OT_RETURN  = LT_RETURN.

    PERFORM UPDATE_PROCESSING_RESULT TABLES LT_ITEM LT_RETURN USING LR_LIST->*.
  ENDLOOP.

  IF P_BATCH IS INITIAL.
    IF GR_LIST IS BOUND.
      GR_LIST->REFRESH( ).
    ENDIF.
  ELSE.
    GR_LIST = NEW #( ).
    GR_LIST->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                IR_CONTAINER = CL_GUI_CONTAINER=>SCREEN0
                      CHANGING CT_DATA       = GT_LIST ).
    WRITE SPACE.
  ENDIF.

  MESSAGE S009 WITH GS_RESULT-TOTAL GS_RESULT-SUCCESS GS_RESULT-ERROR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_processing_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_PROCESSING_RESULT  TABLES PT_ITEM   STRUCTURE ZGTPPSIF0044
                                      PT_RETURN STRUCTURE ZGTPPSIF0045
                                USING PS_LIST TYPE TY_S_LIST.

  DATA(LS_RETURN) = VALUE #( PT_RETURN[ 1 ] OPTIONAL ).

  IF LS_RETURN-AL_STAT  EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR OR
     LS_RETURN-TR_STAT  EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR OR
     LS_RETURN-CHK_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR.
    GS_RESULT-ERROR += 1.
  ELSE.
    GS_RESULT-SUCCESS += 1.
  ENDIF.

  PS_LIST = VALUE #( BASE PS_LIST  AL_STAT      = COND #( WHEN LS_RETURN-CHK_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR THEN PS_LIST-AL_STAT
                                                          ELSE LS_RETURN-AL_STAT )
                                   TR_STAT      = COND #( WHEN LS_RETURN-CHK_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR THEN PS_LIST-TR_STAT
                                                          ELSE LS_RETURN-TR_STAT )
                                   CHK_STAT     = LS_RETURN-CHK_STAT
                                   STAT_MSG     = COND #( WHEN LS_RETURN-CHK_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR THEN PS_LIST-STAT_MSG
                                                          ELSE LS_RETURN-STAT_MSG )
                                   CHK_MSG      = LS_RETURN-CHK_MSG
                                   AL_STAT_ICON = COND #( WHEN PS_LIST-AL_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS THEN ICON_LED_GREEN
                                                          WHEN PS_LIST-AL_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR   THEN ICON_LED_RED
                                                          ELSE ICON_LED_INACTIVE )
                                   TR_STAT_ICON = COND #( WHEN PS_LIST-TR_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS THEN ICON_LED_GREEN
                                                          WHEN PS_LIST-TR_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR   THEN ICON_LED_RED
                                                          ELSE ICON_LED_INACTIVE )
                                  CHK_STAT_ICON = COND #( WHEN PS_LIST-CHK_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-SUCCESS THEN ICON_LED_GREEN
                                                          WHEN PS_LIST-CHK_STAT EQ ZGTPP_IF_CONST=>GC_RESULT-ERROR   THEN ICON_LED_RED
                                                          ELSE ICON_LED_INACTIVE ) ).

ENDFORM.
