*&---------------------------------------------------------------------*
*& Include          ZGTPPR2200F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INITIALIZATION.

  GET PARAMETER ID 'WRK'  FIELD P_WERKS.
  GET PARAMETER ID 'ZSPG' FIELD P_SPGCD.

  PERFORM GET_PARAMETER_DESCRIPTION.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form start_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM START_OF_SELECTION.

  PERFORM GET_MASTER_DATA.

  GT_ZMANUAL_TYPE = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = ZGTPP_IF_CONST=>GC_ZMANUAL_TYPE-M1 ) )
                                                       ELSE VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = ZGTPP_IF_CONST=>GC_ZMANUAL_TYPE-S1 )
                                                                                              ( LOW = ZGTPP_IF_CONST=>GC_ZMANUAL_TYPE-S2 ) ) ).

  SELECT ZT01~*,
         CASE ZT01~ZMANUAL_TYPE WHEN @ZGTPP_IF_CONST=>GC_ZMANUAL_TYPE-S1 THEN @ICON_WD_RADIO_BUTTON
                                                                         ELSE @ICON_WD_RADIO_BUTTON_EMPTY
         END AS ZEXCLUDE,
         CASE ZT01~ZMANUAL_TYPE WHEN @ZGTPP_IF_CONST=>GC_ZMANUAL_TYPE-S2 THEN @ICON_WD_RADIO_BUTTON
                                                                         ELSE @ICON_WD_RADIO_BUTTON_EMPTY
         END AS ZINCLUDE,
         MAKT~MAKTX,
         KNA1~KUNNR, KNA1~NAME1
    FROM ZGTPPT2300 AS ZT01
    LEFT JOIN VBAP
      ON ZT01~VBELN EQ VBAP~VBELN
     AND ZT01~POSNR EQ VBAP~POSNR
    LEFT JOIN VBAK
      ON VBAP~VBELN EQ VBAK~VBELN
    LEFT JOIN KNA1
      ON VBAK~KUNNR EQ KNA1~KUNNR
    LEFT JOIN MAKT
      ON ZT01~MATNR EQ MAKT~MATNR
     AND MAKT~SPRAS EQ @SY-LANGU
   WHERE ZT01~WERKS EQ @P_WERKS
     AND ZT01~SPGCD EQ @P_SPGCD
     AND ZT01~ZMANUAL_TYPE IN @GT_ZMANUAL_TYPE
   ORDER BY ZT01~WERKS, ZT01~SPGCD, ZT01~MATNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

  IF SY-SUBRC IS NOT INITIAL.
    PERFORM SET_INIT_DATA_IN_LIST.
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

  PERFORM DEQUEUE_TABLE.

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

  LOOP AT GR_LIST->MT_FCAT REFERENCE INTO DATA(LR_FCAT).

    CASE LR_FCAT->FIELDNAME.
      WHEN 'ZMANUAL_NO'.
        LR_FCAT->COLTEXT    = TEXT-F01.
        LR_FCAT->OUTPUTLEN  = 10.
        LR_FCAT->JUST       = 'C'.

      WHEN 'ZEXCLUDE'.
        LR_FCAT->COLTEXT    = TEXT-F02.
        LR_FCAT->OUTPUTLEN  = 6.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->HOTSPOT    = ABAP_TRUE.
        LR_FCAT->TECH       = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'ZINCLUDE'.
        LR_FCAT->COLTEXT    = TEXT-F03.
        LR_FCAT->OUTPUTLEN  = 6.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->HOTSPOT    = ABAP_TRUE.
        LR_FCAT->TECH       = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'VBELN'.
        LR_FCAT->COLTEXT    = TEXT-F04.
        LR_FCAT->OUTPUTLEN  = 10.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EDIT       = COND #( WHEN P_SLSREF EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->MARK       = COND #( WHEN P_SLSREF EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->TECH       = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'POSNR'.
        LR_FCAT->COLTEXT    = TEXT-F05.
        LR_FCAT->OUTPUTLEN  = 8.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EDIT       = COND #( WHEN P_SLSREF EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->MARK       = COND #( WHEN P_SLSREF EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->TECH       = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F06.
        LR_FCAT->OUTPUTLEN  = 12.
        LR_FCAT->EDIT       = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->MARK       = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F07.
        LR_FCAT->OUTPUTLEN  = 20.

      WHEN 'MENGE'.
        LR_FCAT->COLTEXT    = TEXT-F08.
        LR_FCAT->OUTPUTLEN  = 12.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->EDIT       = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->MARK       = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F09.
        LR_FCAT->OUTPUTLEN  = 6.
        LR_FCAT->JUST       = 'C'.

      WHEN 'VDATU'.
        LR_FCAT->COLTEXT    = TEXT-F10.
        LR_FCAT->OUTPUTLEN  = 10.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EDIT       = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN ABAP_TRUE ).
        LR_FCAT->MARK       = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'KUNNR'.
        LR_FCAT->COLTEXT    = TEXT-F11.
        LR_FCAT->OUTPUTLEN  = 10.
        LR_FCAT->TECH       = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'NAME1'.
        LR_FCAT->COLTEXT    = TEXT-F12.
        LR_FCAT->OUTPUTLEN  = 20.
        LR_FCAT->TECH       = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN ABAP_TRUE ).

      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-F13.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->OUTPUTLEN  = 7.

      WHEN 'MESSAGE'.
        LR_FCAT->COLTEXT    = TEXT-F14.
        LR_FCAT->OUTPUTLEN  = 30.

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
FORM HANDLE_LAYOUT USING PR_SENDER.

  TRY.
      GR_LIST->MS_LAYOUT = VALUE #( BASE GR_LIST->MS_LAYOUT  CWIDTH_OPT = ABAP_FALSE ).

    CATCH CX_ROOT.

  ENDTRY.

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

*// SPG코드.
  IF P_SPGCD IS INITIAL.
    MESSAGE E031 WITH TEXT-002 DISPLAY LIKE 'S'.
  ELSE.
    SELECT SINGLE DESCR
      INTO @P_DESCR
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

  GV_TPAR1 = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN TEXT-C11
                                                ELSE TEXT-C12 ).

  GV_TPAR2 = |{ P_WERKS } { P_NAME1 } / { P_SPGCD } { P_DESCR }|.

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR  USING PR_SENDER
                           PR_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  PR_OBJECT->MT_TOOLBAR = VALUE #( BASE PR_OBJECT->MT_TOOLBAR
                                  ( BUTN_TYPE = 3 )
                                  ( FUNCTION  = GC_FCODE-INSERT_ROW
                                    ICON      = ICON_INSERT_ROW
                                    QUICKINFO = TEXT-B01 )
                                  ( FUNCTION  = GC_FCODE-DELETE_ROW
                                    ICON      = ICON_DELETE_ROW
                                    QUICKINFO = TEXT-B02 ) ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND  USING PR_SENDER PV_UCOMM.

  CASE PV_UCOMM.
    WHEN GC_FCODE-INSERT_ROW. "// 행 추가.
      PERFORM INSERT_ROW_IN_LIST.

    WHEN GC_FCODE-DELETE_ROW. "// 행 삭제.
      PERFORM DELETE_ROW_IN_LIST.
  ENDCASE.

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
*& Form enqueue_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ENQUEUE_TABLE .

  CALL FUNCTION 'ENQUEUE_E_TABLE'
    EXPORTING
      TABNAME        = GC_TABLE-ZGTPPT2300
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
      TABNAME = GC_TABLE-ZGTPPT2300
      VARKEY  = CONV VIM_ENQKEY( |{ P_WERKS }{ P_SPGCD }| ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED  USING PR_SENDER
                                PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                PV_UCOMM TYPE SY-UCOMM.

  DATA LR_LIST TYPE REF TO TY_S_LIST.
  DATA LS_LIST TYPE TY_S_LIST.

  PERFORM SET_DEFALUT_VALUE USING LS_LIST.

  LOOP AT PR_DATA_CHANGED->MT_INSERTED_ROWS INTO DATA(LS_INSERT_ROW).
    PR_DATA_CHANGED->MODIFY_CELL( I_ROW_ID = LS_INSERT_ROW-ROW_ID: I_FIELDNAME = 'WERKS'    I_VALUE = LS_LIST-WERKS ),
                                                                   I_FIELDNAME = 'SPGCD'    I_VALUE = LS_LIST-SPGCD ),
                                                                   I_FIELDNAME = 'ZEXCLUDE' I_VALUE = LS_LIST-ZEXCLUDE ),
                                                                   I_FIELDNAME = 'ZINCLUDE' I_VALUE = LS_LIST-ZINCLUDE ),
                                                                   I_FIELDNAME = 'INIT'     I_VALUE = LS_LIST-INIT ).
  ENDLOOP.

  LOOP AT PR_DATA_CHANGED->MP_MOD_ROWS->* REFERENCE INTO LR_LIST.
    READ TABLE PR_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_CELL)
                                             WITH KEY TABIX = SY-TABIX.

    PERFORM FIELD_VALID_CHECK_IN_LIST USING LR_LIST->*.
    PERFORM MODIFY_CELL_IN_LIST       USING PR_DATA_CHANGED LS_CELL LR_LIST->*.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM FIELD_VALID_CHECK_IN_LIST  USING PS_LIST TYPE TY_S_LIST.

  CLEAR: PS_LIST-STATUS, PS_LIST-MESSAGE, PS_LIST-RETURN.

  PERFORM CHECK_INPUT_VALUE_IN_LIST USING PS_LIST.
  PERFORM CHECK_MANDT_FIELD_IN_LIST USING PS_LIST.

  IF PS_LIST-RETURN IS NOT INITIAL.
    PS_LIST-STATUS  = ICON_LED_RED.
    PS_LIST-MESSAGE = VALUE #( PS_LIST-RETURN[ 1 ]-MESSAGE OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE_IN_LIST  USING PS_LIST TYPE TY_S_LIST.

  IF P_MANADD EQ ABAP_TRUE. "// 수기 물량추가.
    PERFORM CHECK_INPUT_VALUE_FOR_P_MANADD USING PS_LIST.
  ELSE.                     "// 판매주문 추가/제외.
    PERFORM CHECK_INPUT_VALUE_FOR_P_SLSREF USING PS_LIST.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_MANDT_FIELD_IN_LIST USING PS_LIST TYPE TY_S_LIST.

  DATA(LR_LIST) = REF #( PS_LIST ).

  LOOP AT GR_LIST->MT_FCAT INTO DATA(LS_FCAT)
                          WHERE MARK EQ ABAP_TRUE
                            AND TECH EQ ABAP_FALSE.
    PERFORM APPEND_MANDT_FIELD_TO_RETURN USING LR_LIST->(LS_FCAT-FIELDNAME) LS_FCAT-COLTEXT LR_LIST->RETURN.
  ENDLOOP.

  IF P_SLSREF EQ ABAP_TRUE AND
     PS_LIST-ZEXCLUDE EQ ICON_WD_RADIO_BUTTON_EMPTY AND
     PS_LIST-ZINCLUDE EQ ICON_WD_RADIO_BUTTON_EMPTY.
    PS_LIST-RETURN = VALUE #( BASE PS_LIST-RETURN ( TYPE = 'E' FIELD = TEXT-F02 MESSAGE = TEXT-E08 ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_CELL_IN_LIST  USING PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                PS_CELL TYPE LVC_S_MODI
                                PS_LIST TYPE TY_S_LIST.

  PR_DATA_CHANGED->MODIFY_CELL( I_ROW_ID = PS_CELL-ROW_ID:  I_FIELDNAME = 'INIT'     I_VALUE = PS_LIST-INIT ),
                                                            I_FIELDNAME = 'ZEXCLUDE' I_VALUE = PS_LIST-ZEXCLUDE ),
                                                            I_FIELDNAME = 'ZINCLUDE' I_VALUE = PS_LIST-ZINCLUDE ),
                                                            I_FIELDNAME = 'MATNR'    I_VALUE = PS_LIST-MATNR ),
                                                            I_FIELDNAME = 'MAKTX'    I_VALUE = PS_LIST-MAKTX ),
                                                            I_FIELDNAME = 'MENGE'    I_VALUE = PS_LIST-MENGE ),
                                                            I_FIELDNAME = 'MEINS'    I_VALUE = PS_LIST-MEINS ),
                                                            I_FIELDNAME = 'KUNNR'    I_VALUE = PS_LIST-KUNNR ),
                                                            I_FIELDNAME = 'NAME1'    I_VALUE = PS_LIST-NAME1 ),
                                                            I_FIELDNAME = 'VDATU'    I_VALUE = PS_LIST-VDATU ),
                                                            I_FIELDNAME = 'STATUS'   I_VALUE = PS_LIST-STATUS ),
                                                            I_FIELDNAME = 'MESSAGE'  I_VALUE = PS_LIST-MESSAGE ),
                                                            I_FIELDNAME = 'RETURN'   I_VALUE = PS_LIST-RETURN ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_defalut_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_DEFALUT_VALUE  USING PS_LIST TYPE TY_S_LIST.

  PS_LIST = VALUE #( WERKS    = P_WERKS
                     SPGCD    = P_SPGCD
                     ZEXCLUDE = COND #( WHEN P_SLSREF EQ ABAP_TRUE THEN ICON_WD_RADIO_BUTTON_EMPTY )
                     ZINCLUDE = COND #( WHEN P_SLSREF EQ ABAP_TRUE THEN ICON_WD_RADIO_BUTTON_EMPTY )
                     INIT     = ABAP_TRUE ).

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
*& Form user_command_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_SAVE .

  TRY.
*// 사전점검.
      PERFORM CHECK_BEFORE_SAVE.

*// 저장.
      PERFORM SAVE_ZGTPPT2300.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        GR_LIST->REFRESH( ).
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_before_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_SAVE RAISING LCX_EXCEPTION.
  DATA LV_ANSWER TYPE C.

  GR_LIST->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  PERFORM GET_SAVE_DATA.

  IF GS_RESULT-INVALID IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E03.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E04.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C02 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

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
*& Form get_master_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MASTER_DATA .

*  SELECT werks, name1
*    INTO CORRESPONDING FIELDS OF TABLE @gt_t001w
*    FROM t001w.
*
*  SELECT werks, lgort, lgobe
*    INTO CORRESPONDING FIELDS OF TABLE @gt_t001l
*    FROM t001l.
*
*  SELECT spras, matkl, wgbez
*    INTO CORRESPONDING FIELDS OF TABLE @gt_t023t
*    FROM t023t
*   WHERE spras EQ @sy-langu.
*
*  INSERT VALUE t023t( spras = sy-langu
*                      matkl = 'DUMMY'
*                      wgbez = 'DUMMY' ) INTO TABLE gt_t023t.
*
*  gt_zgtppt1010 = zgtpp_cl_common=>get_code_value( iv_codegrp = gc_codegrp-4070 ).
*  SORT gt_zgtppt1010 BY codegrp fld_01 fld_02.
*
*  CASE abap_true.
*    WHEN p_prdscr. "// 생산 스크랩코드 관리.
*      gt_style = VALUE #( style = cl_gui_alv_grid=>mc_style_disabled  ( fieldname = 'MATKL' )
*                                                                      ( fieldname = 'MATNR' ) ).
*
*    WHEN p_conrat. "// 생산/물자 스크랩 코드 및 환산율 관리.
*      gt_style = VALUE #( style = cl_gui_alv_grid=>mc_style_disabled  ( fieldname = 'LGORT' )
*                                                                      ( fieldname = 'SCGRP' ) ).
*
*      gt_style2 = VALUE #( style = cl_gui_alv_grid=>mc_style_disabled  ( fieldname = 'MATNR_T' ) ).
*  ENDCASE.

  GT_ZMANUAL_TYPE = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = ZGTPP_IF_CONST=>GC_ZMANUAL_TYPE-M1 ) )
                                                       ELSE VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = ZGTPP_IF_CONST=>GC_ZMANUAL_TYPE-S1 )
                                                                                              ( LOW = ZGTPP_IF_CONST=>GC_ZMANUAL_TYPE-S2 ) ) ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed_fini
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED_FINI  USING PR_SENDER
                                     PT_GOOD_CELLS TYPE LVC_T_MODI
                                     PV_MODIFIED.

  CHECK PT_GOOD_CELLS IS NOT INITIAL.

*  PERFORM check_duplication_in_list.
*
*  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_duplication_in_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_DUPLICATION_IN_LIST .

**// 자재 중복 여부.
*  SELECT werks, spgcd, lgort, scgrp
*    FROM @gt_t1120 AS a
*   WHERE scgrp NE @space
*   GROUP BY werks, spgcd, lgort, scgrp
*  HAVING COUNT( * ) GT 1
*    INTO TABLE @DATA(lt_t1120).
*
**// 기존 데이터 중복 해지.
*  LOOP AT gt_t1120 REFERENCE INTO DATA(lr_t1120)
*                   WHERE dupli EQ abap_true.
*    lr_t1120->dupli = abap_false.
*    DELETE lr_t1120->return WHERE field EQ gc_duplication.
*
*    IF lr_t1120->return IS INITIAL.
*      CLEAR: lr_t1120->status, lr_t1120->message.
*    ENDIF.
*  ENDLOOP.
*
**// 중복 데이터 설정.
*  LOOP AT lt_t1120 INTO DATA(ls_t1120).
*    LOOP AT gt_t1120 REFERENCE INTO lr_t1120
*                     WHERE werks EQ ls_t1120-werks
*                       AND spgcd EQ ls_t1120-spgcd
*                       AND lgort EQ ls_t1120-lgort
*                       AND scgrp EQ ls_t1120-scgrp.
*      lr_t1120->dupli  = abap_true.
*      lr_t1120->return = VALUE #( BASE lr_t1120->return ( type = 'E' field = gc_duplication message = TEXT-e11 ) ).
*      IF lines( lr_t1120->return ) EQ 1.
*        lr_t1120->status  = icon_led_red.
*        lr_t1120->message = lr_t1120->return[ 1 ]-message.
*      ENDIF.
*    ENDLOOP.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_data_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_INIT_DATA_IN_LIST .

  DO 10 TIMES.
    APPEND INITIAL LINE TO GT_LIST REFERENCE INTO DATA(LR_LIST).
    PERFORM SET_DEFALUT_VALUE USING LR_LIST->*.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_row_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INSERT_ROW_IN_LIST .

  IF GT_LIST IS INITIAL.
    PERFORM SET_INIT_DATA_IN_LIST.
  ELSE.
    GR_LIST->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).

    IF LT_ROWS IS NOT INITIAL.
      DATA(LS_ROW) = VALUE #( LT_ROWS[ 1 ] OPTIONAL ).

      DO LINES( LT_ROWS ) TIMES.
        INSERT INITIAL LINE INTO GT_LIST REFERENCE INTO DATA(LR_LIST) INDEX LS_ROW-INDEX.
        PERFORM SET_DEFALUT_VALUE USING LR_LIST->*.
      ENDDO.
    ELSE.
      APPEND INITIAL LINE TO GT_LIST REFERENCE INTO LR_LIST.
      PERFORM SET_DEFALUT_VALUE USING LR_LIST->*.
    ENDIF.
  ENDIF.

  GR_LIST->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_row_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DELETE_ROW_IN_LIST .

  MODIFY GT_LIST FROM VALUE #( SEL = SPACE )
                 TRANSPORTING SEL
                 WHERE SEL EQ ABAP_TRUE.

  GR_LIST->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    MESSAGE I000 WITH TEXT-E06 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_LIST REFERENCE INTO DATA(LR_LIST) INDEX LS_ROW-INDEX.
    IF SY-SUBRC IS INITIAL.
      LR_LIST->SEL = ABAP_TRUE.
    ENDIF.
  ENDLOOP.

  DELETE GT_LIST WHERE SEL EQ ABAP_TRUE.
  PERFORM CHECK_DUPLICATION_IN_LIST.

  GR_LIST->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_zgtppt2300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_ZGTPPT2300 .
  DATA LT_ZGTPPT2300 TYPE TABLE OF ZGTPPT2300.

  SELECT MANDT, WERKS, SPGCD, ZMANUAL_NO, ZMANUAL_TYPE, MATNR, VDATU, MENGE, MEINS, VBELN, POSNR,
         CRDAT, CRTIM, CRNAM, CHDAT, CHTIM, CHNAM,
         @ABAP_FALSE AS DEL
    FROM ZGTPPT2300 AS ZT01
   WHERE WERKS        EQ @P_WERKS
     AND SPGCD        EQ @P_SPGCD
     AND ZMANUAL_TYPE IN @GT_ZMANUAL_TYPE
   ORDER BY WERKS, SPGCD, ZMANUAL_NO
    INTO TABLE @DATA(LT_ZGTPPT2300_DB).

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST)
                  WHERE SEL EQ ABAP_TRUE.
    APPEND INITIAL LINE TO LT_ZGTPPT2300 REFERENCE INTO DATA(LR_ZGTPPT2300).
    LR_ZGTPPT2300->* = CORRESPONDING #( LR_LIST->* ).

    LR_ZGTPPT2300->ZMANUAL_TYPE = COND #( WHEN P_MANADD EQ ABAP_TRUE THEN ZGTPP_IF_CONST=>GC_ZMANUAL_TYPE-M1
                                          WHEN P_SLSREF EQ ABAP_TRUE THEN COND #( WHEN LR_LIST->ZEXCLUDE EQ ICON_WD_RADIO_BUTTON THEN ZGTPP_IF_CONST=>GC_ZMANUAL_TYPE-S1
                                                                                  WHEN LR_LIST->ZINCLUDE EQ ICON_WD_RADIO_BUTTON THEN ZGTPP_IF_CONST=>GC_ZMANUAL_TYPE-S2 ) ).
    IF LR_LIST->ZMANUAL_NO IS INITIAL.
      PERFORM GET_NEXT_NUMBER USING LR_LIST->ZMANUAL_NO.
      LR_ZGTPPT2300->ZMANUAL_NO = LR_LIST->ZMANUAL_NO.
      LR_ZGTPPT2300->* = CORRESPONDING #( BASE ( LR_ZGTPPT2300->* ) GS_ZGTPPS1001 ).
      LR_LIST->* = CORRESPONDING #( BASE ( LR_LIST->* ) GS_ZGTPPS1001 ).
    ELSE.
      READ TABLE LT_ZGTPPT2300_DB REFERENCE INTO DATA(LR_ZGTPPT2300_DB) WITH KEY WERKS      = LR_LIST->WERKS
                                                                                 SPGCD      = LR_LIST->SPGCD
                                                                                 ZMANUAL_NO = LR_LIST->ZMANUAL_NO BINARY SEARCH.
      IF SY-SUBRC IS INITIAL.
        LR_ZGTPPT2300->* = VALUE #( BASE LR_ZGTPPT2300->*  CHDAT = GS_ZGTPPS1001-CHDAT
                                                           CHTIM = GS_ZGTPPS1001-CHTIM
                                                           CHNAM = GS_ZGTPPS1001-CHNAM ).
        LR_LIST->* = VALUE #( BASE LR_LIST->*  CHDAT = GS_ZGTPPS1001-CHDAT
                                               CHTIM = GS_ZGTPPS1001-CHTIM
                                               CHNAM = GS_ZGTPPS1001-CHNAM ).
        LR_ZGTPPT2300_DB->DEL = ABAP_TRUE.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DELETE LT_ZGTPPT2300_DB WHERE DEL EQ ABAP_TRUE.

  TRY.
      IF LT_ZGTPPT2300_DB IS NOT INITIAL.
        DELETE ZGTPPT2300 FROM TABLE LT_ZGTPPT2300_DB.
      ENDIF.

      MODIFY ZGTPPT2300 FROM TABLE LT_ZGTPPT2300.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E01.
  ENDTRY.

  COMMIT WORK AND WAIT.

  DELETE GT_LIST WHERE INIT EQ ABAP_TRUE.

  GR_LIST->REFRESH( ).

  MESSAGE S500(MI).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_save_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_SAVE_DATA .

  CLEAR GS_RESULT.

  MODIFY GT_LIST FROM VALUE #( SEL = SPACE )
                 TRANSPORTING SEL
                 WHERE SEL EQ ABAP_TRUE.

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST)
                   WHERE INIT EQ ABAP_FALSE.
    IF LR_LIST->STATUS EQ ICON_LED_RED.
      GS_RESULT-INVALID = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    GS_RESULT-SEL += 1.

    LR_LIST->SEL = ABAP_TRUE.
    GS_RESULT-TOTAL += 1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_next_number
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_NEXT_NUMBER  USING PV_NUMBER.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '01'
      OBJECT                  = 'ZPP_MANUNO'
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
*& Form check_input_value_for_p_manadd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE_FOR_P_MANADD  USING PS_LIST TYPE TY_S_LIST.

  CLEAR: PS_LIST-INIT, PS_LIST-MAKTX, PS_LIST-MEINS.

  IF PS_LIST-MATNR IS NOT INITIAL.
    SELECT SINGLE MARA~MEINS, MAKT~MAKTX
      INTO (@PS_LIST-MEINS,@PS_LIST-MAKTX)
      FROM MARA
      JOIN MAKT
        ON MARA~MATNR EQ MAKT~MATNR
       AND MAKT~SPRAS EQ @SY-LANGU
     WHERE MARA~MATNR EQ @PS_LIST-MATNR.

    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E305(M3) WITH PS_LIST-MATNR INTO DATA(LV_MESSAGE).
      PS_LIST-RETURN = VALUE #( BASE PS_LIST-RETURN ( TYPE = 'E'  FIELD = TEXT-F06  MESSAGE = LV_MESSAGE ) ).
    ELSE.
      SELECT SINGLE @ABAP_TRUE
        INTO @DATA(LV_CHECK)
        FROM MARC
       WHERE MARC~MATNR EQ @PS_LIST-MATNR
         AND MARC~WERKS EQ @PS_LIST-WERKS.

      IF SY-SUBRC IS NOT INITIAL.
        MESSAGE E200(M3) WITH PS_LIST-MATNR PS_LIST-WERKS INTO LV_MESSAGE.
        PS_LIST-RETURN = VALUE #( BASE PS_LIST-RETURN ( TYPE = 'E'  FIELD = TEXT-F06  MESSAGE = LV_MESSAGE ) ).
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_for_p_slsref
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE_FOR_P_SLSREF  USING PS_LIST TYPE TY_S_LIST.

  CLEAR: PS_LIST-INIT,
         PS_LIST-VDATU,
         PS_LIST-KUNNR, PS_LIST-NAME1,
         PS_LIST-MATNR, PS_LIST-MAKTX,
         PS_LIST-MENGE, PS_LIST-MEINS.

  IF PS_LIST-VBELN IS NOT INITIAL AND PS_LIST-POSNR IS NOT INITIAL.
    SELECT SINGLE VBAK~VDATU,
                  VBAK~KUNNR, KNA1~NAME1,
                  VBAP~MATNR, MAKT~MAKTX,
                  VBAP~KWMENG AS MENGE, VBAP~MEINS
      INTO CORRESPONDING FIELDS OF @PS_LIST
      FROM VBAP
      JOIN VBAK
        ON VBAP~VBELN EQ VBAK~VBELN
      LEFT JOIN KNA1
        ON VBAK~KUNNR EQ KNA1~KUNNR
      LEFT JOIN MAKT
        ON VBAP~MATNR EQ MAKT~MATNR
       AND MAKT~SPRAS EQ @SY-LANGU
     WHERE VBAP~VBELN EQ @PS_LIST-VBELN
       AND VBAP~POSNR EQ @PS_LIST-POSNR.

    IF SY-SUBRC IS NOT INITIAL.
      PS_LIST-RETURN = VALUE #( BASE PS_LIST-RETURN ( TYPE = 'E'  FIELD = TEXT-F04  MESSAGE = TEXT-E15 ) ).
    ENDIF.
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

  TRY.
      DATA(LR_LIST) = REF #( GT_LIST[ PS_ROW-ROW_ID ] OPTIONAL ).

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'ZEXCLUDE'.
      LR_LIST->ZEXCLUDE = ICON_WD_RADIO_BUTTON.
      LR_LIST->ZINCLUDE = ICON_WD_RADIO_BUTTON_EMPTY.

    WHEN 'ZINCLUDE'.
      LR_LIST->ZEXCLUDE = ICON_WD_RADIO_BUTTON_EMPTY.
      LR_LIST->ZINCLUDE = ICON_WD_RADIO_BUTTON.
  ENDCASE.

  PERFORM FIELD_VALID_CHECK_IN_LIST USING LR_LIST->*.

  GR_LIST->REFRESH( ).

ENDFORM.
