*&---------------------------------------------------------------------*
*& Include          ZGTPPR4090F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM INITIALIZATION.

  GET PARAMETER ID 'WRK'  FIELD P_WERKS.
  GET PARAMETER ID 'ZSPG' FIELD P_SPGCD.

  S_SCPDAT[] = VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = SY-DATUM HIGH = SY-DATUM ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form start_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM START_OF_SELECTION.

  PERFORM GET_MASTER_DATA.

  SELECT ZT01~*
    FROM ZGTPPT4110 AS ZT01
   WHERE ZT01~WERKS     EQ @P_WERKS
     AND ZT01~SPGCD     EQ @P_SPGCD
     AND ZT01~MATNR     IN @S_MATNR
     AND ZT01~SCPNR     IN @S_SCPNR
     AND ZT01~SCPDAT    IN @S_SCPDAT
     AND ZT01~INDEPT    IN @S_INDEPT
     AND ZT01~CS_ARBPL  IN @S_CSARB
     AND ZT01~OPCOD     IN @S_OPCOD
     AND ZT01~SCPREASON IN @S_SCRSN
     AND ZT01~LKENZ     EQ @SPACE
   ORDER BY ZT01~SCPNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.

  IF GT_LIST IS INITIAL.
    PERFORM APPEND_INIT_DATA.
  ELSE.
    LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST).
      LR_LIST->INDEPT_DDLB = |{ LR_LIST->INDEPT } { LR_LIST->DEPTXT }|.
      LR_LIST->SCGRP_DDLB  = |{ LR_LIST->SCGRP  } { LR_LIST->SCTXT }|.

*// 스크랩사유.
      READ TABLE GT_ZGTPPT1010 INTO DATA(LS_ZGTPPT1010) WITH KEY CODEGRP = GC_CODEGRP-4060
                                                                 FLD_01  = LR_LIST->WERKS
                                                                 FLD_02  = LR_LIST->SCPREASON.
      IF SY-SUBRC IS INITIAL.
        LR_LIST->SCPREASON_DDLB = |{ LR_LIST->SCPREASON } { LS_ZGTPPT1010-FLD_03 }|.
      ENDIF.

      LR_LIST->STYLE = COND #( WHEN LR_LIST->SCPNR IS NOT INITIAL THEN GT_STYLE ).
    ENDLOOP.

    PERFORM GET_WEIGHING_OF_SELECTED_SCPNR USING GC_DISPLAY-SINGLE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form end_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM END_OF_SELECTION .

  IF GT_LIST IS NOT INITIAL.
    PERFORM CALL_SCREEN_100.
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

  PERFORM DEQUEUE_TABLE.

  IF GR_LIST IS BOUND.
    GR_LIST->FREE( ).
    CLEAR GR_LIST.
  ENDIF.

  IF GR_WEIGHING IS BOUND.
    GR_WEIGHING->FREE( ).
    CLEAR GR_WEIGHING.
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

  IF PR_SENDER EQ GR_LIST.
    PERFORM MODIFY_FCAT_IN_LIST.
  ENDIF.

  IF PR_SENDER EQ GR_WEIGHING.
    PERFORM MODIFY_FCAT_IN_WEIGHING.
  ENDIF.

  IF PR_SENDER EQ GR_DETAIL.
    PERFORM MODIFY_FCAT_IN_DETAIL.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_LAYOUT  USING PR_SENDER.

  IF PR_SENDER EQ GR_LIST.
    PERFORM SET_LAYOUT_IN_LIST.
  ENDIF.

  IF PR_SENDER EQ GR_WEIGHING.
    PERFORM SET_LAYOUT_IN_WEIGHING.
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

  SSCRFIELDS-FUNCTXT_01 = TEXT-FC1.

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
    WHEN GC_FCODE-FC01.
      PERFORM USER_COMMAND_FC01.            "// 설비 & 작업장 Mapping.

    WHEN GC_FCODE-ONLI.
      PERFORM CHECK_SEL_SCREEN_INPUT_VALUE. "// 실행.
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

  GV_TPAR1 = |{ P_WERKS } { P_NAME1 } / { P_SPGCD } { P_DESCR }|.

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR  USING PR_SENDER
                           PR_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  IF GR_LIST IS BOUND AND PR_SENDER EQ GR_LIST->MR_GRID.
    PERFORM SET_TOOLBAR_IN_LIST USING PR_OBJECT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND USING PR_SENDER PV_UCOMM.

  IF GR_LIST IS BOUND AND PR_SENDER EQ GR_LIST->MR_GRID.
    PERFORM USER_COMMAND_IN_LIST USING PV_UCOMM.
  ENDIF.

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

*// 공통 코드 관리
  SELECT *
    FROM ZGTPPT1010
    INTO TABLE @GT_ZGTPPT1010
   WHERE MODULE_KIND EQ 'PP'
     AND CODEGRP IN (@GC_CODEGRP-4050,@GC_CODEGRP-4060,@GC_CODEGRP-4070,@GC_CODEGRP-4080, @GC_CODEGRP-4090)
     AND FLD_01  EQ @P_WERKS
   ORDER BY CODEGRP, FLD_01, FLD_02, FLD_03.

  LOOP AT GT_ZGTPPT1010 INTO DATA(LS_ZGTPPT1010)
                        WHERE FLD_01 EQ P_WERKS.
    CASE LS_ZGTPPT1010-CODEGRP.
      WHEN GC_CODEGRP-4050. "// 발생부서.
        APPEND INITIAL LINE TO GT_INDEPT REFERENCE INTO DATA(LR_INDEPT).
        LR_INDEPT->* = VALUE #( VALUE = LS_ZGTPPT1010-FLD_02
                                TEXT  = LS_ZGTPPT1010-FLD_03 ).

      WHEN GC_CODEGRP-4060. "// 스크랩사유.
        APPEND INITIAL LINE TO GT_SCPREASON REFERENCE INTO DATA(LR_SCPREASON).
        LR_SCPREASON->* = VALUE #( VALUE = LS_ZGTPPT1010-FLD_02
                                   TEXT  = LS_ZGTPPT1010-FLD_03 ).

      WHEN GC_CODEGRP-4090. "// 발생공정.
        APPEND INITIAL LINE TO GT_OPCOD REFERENCE INTO DATA(LR_OPCOD).
        LR_OPCOD->* = VALUE #( VALUE = LS_ZGTPPT1010-FLD_02
                               TEXT  = LS_ZGTPPT1010-FLD_03 ).
    ENDCASE.
  ENDLOOP.

  SELECT WERKS, ARBPL, KTEXT
    INTO CORRESPONDING FIELDS OF TABLE @GT_CRHD
    FROM M_CRAMN
   WHERE WERKS EQ @P_WERKS
     AND SPRAS EQ @SY-LANGU.

  CASE P_WERKS.
    WHEN GC_WERKS-6500.
      APPEND VALUE #( WERKS = P_WERKS ARBPL = 'DCM' KTEXT = TEXT-T41 ) TO GT_CRHD.

    WHEN GC_WERKS-6600.
      APPEND VALUE #( WERKS = P_WERKS ARBPL = 'PIR' KTEXT = TEXT-T42 ) TO GT_CRHD.
  ENDCASE.

  SORT GT_CRHD BY WERKS ARBPL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_LIST .

  PERFORM SET_DROP_DOWN_TABLE.

  LOOP AT GR_LIST->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'SCPNR'.
        LR_FCAT->COLTEXT    = TEXT-F16.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-F01.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'SPGCD'.
        LR_FCAT->COLTEXT    = TEXT-F02.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'LGORT'.
        LR_FCAT->COLTEXT    = TEXT-F23.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->MARK       = ABAP_TRUE.

      WHEN 'INDEPT_DDLB'.
        LR_FCAT->COLTEXT    = TEXT-F03.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->DRDN_HNDL  = '1'.
        LR_FCAT->MARK       = COND #( WHEN P_WERKS NE GC_WERKS-6600 THEN ABAP_TRUE ).
        LR_FCAT->TECH       = COND #( WHEN P_WERKS EQ GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'DEPTXT'.
        LR_FCAT->COLTEXT    = TEXT-F04.
        LR_FCAT->EDIT       = COND #( WHEN P_WERKS EQ GC_WERKS-6600 THEN ABAP_TRUE ).
        LR_FCAT->COL_OPT    = COND #( WHEN P_WERKS EQ GC_WERKS-6600 THEN SPACE ).
        LR_FCAT->OUTPUTLEN  = COND #( WHEN P_WERKS EQ GC_WERKS-6600 THEN 15 ).
        LR_FCAT->MARK       = COND #( WHEN P_WERKS EQ GC_WERKS-6600 THEN ABAP_TRUE ).
        LR_FCAT->TECH       = COND #( WHEN P_WERKS NE GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'CS_ARBPL'.
        LR_FCAT->COLTEXT    = TEXT-F05.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->F4AVAILABL = ABAP_TRUE.
        LR_FCAT->COL_OPT    = SPACE.
        LR_FCAT->OUTPUTLEN  = 10.
        LR_FCAT->MARK       = COND #( WHEN P_WERKS EQ GC_WERKS-6500 THEN ABAP_TRUE ).
        LR_FCAT->TECH       = COND #( WHEN P_WERKS EQ GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'OPCOD'.
        LR_FCAT->COLTEXT    = TEXT-F06.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->F4AVAILABL = ABAP_TRUE.
        LR_FCAT->MARK       = COND #( WHEN P_WERKS EQ GC_WERKS-6600 THEN ABAP_TRUE ).
        LR_FCAT->TECH       = COND #( WHEN P_WERKS NE GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'SCGRP_DDLB'.
        LR_FCAT->COLTEXT    = TEXT-F07.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->DRDN_HNDL  = '3'.
        LR_FCAT->MARK       = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C100'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F14.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->MARK       = COND #( WHEN P_WERKS NE GC_WERKS-6600 THEN ABAP_TRUE ).
        LR_FCAT->TECH       = COND #( WHEN P_WERKS NE GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F15.
        LR_FCAT->TECH       = COND #( WHEN P_WERKS NE GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'SCPQT'.
        LR_FCAT->COLTEXT    = TEXT-F11.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->MARK       = ABAP_TRUE.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F25.
        LR_FCAT->JUST       = 'C'.

      WHEN 'SCPREASON_DDLB'.
        LR_FCAT->COLTEXT    = TEXT-F12.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->MARK       = ABAP_TRUE.
        LR_FCAT->DRDN_HNDL  = '2'.

      WHEN 'SCPDAT'.
        LR_FCAT->COLTEXT    = TEXT-F13.
        LR_FCAT->EDIT       = ABAP_TRUE.
        LR_FCAT->MARK       = ABAP_TRUE.
        LR_FCAT->JUST       = 'C'.

      WHEN 'WERKS_M'.
        LR_FCAT->COLTEXT    = TEXT-F21.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_WERKS NE GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'LGORT_M'.
        LR_FCAT->COLTEXT    = TEXT-F22.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_WERKS NE GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'MATNR_M'.
        LR_FCAT->COLTEXT    = TEXT-F09.
        LR_FCAT->MARK       = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_WERKS NE GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'MAKTX_M'.
        LR_FCAT->COLTEXT    = TEXT-F10.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->TECH       = COND #( WHEN P_WERKS NE GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'STATUS'.
        LR_FCAT->COLTEXT    = TEXT-F24.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MESSAGE'.
        LR_FCAT->COLTEXT    = TEXT-F20.

      WHEN 'MBLNR_309'.
        LR_FCAT->COLTEXT    = TEXT-F44.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'MBLNR_Z31'.
        LR_FCAT->COLTEXT    = TEXT-F45.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'MBLNR_Z41'.
        LR_FCAT->COLTEXT    = TEXT-F46.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'CRDAT'.
        LR_FCAT->COLTEXT    = TEXT-F17.
        LR_FCAT->JUST       = 'C'.

      WHEN 'CRTIM'.
        LR_FCAT->COLTEXT    = TEXT-F18.
        LR_FCAT->JUST       = 'C'.

      WHEN 'CRNAM'.
        LR_FCAT->COLTEXT    = TEXT-F19.
        LR_FCAT->JUST       = 'C'.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_weighing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_WEIGHING .

  LOOP AT GR_WEIGHING->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'SCPNR'.
        LR_FCAT->COLTEXT    = TEXT-F30.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'INDEPT_DDLB'.
        LR_FCAT->COLTEXT    = TEXT-F03.
        LR_FCAT->EMPHASIZE  = 'C500'.
        LR_FCAT->TECH       = COND #( WHEN P_WERKS EQ GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'CS_ARBPL'.
        LR_FCAT->COLTEXT    = TEXT-F05.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'SCGRP_DDLB'.
        LR_FCAT->COLTEXT    = TEXT-F07.
        LR_FCAT->EMPHASIZE  = 'C500'.

*      WHEN 'MATNR_M'.
*        lr_fcat->coltext    = TEXT-f31.
*        lr_fcat->just       = 'C'.
*        lr_fcat->emphasize  = 'C500'.
*
*      WHEN 'MAKTX_M'.
*        lr_fcat->coltext    = TEXT-f32.
*        lr_fcat->emphasize  = 'C500'.

      WHEN 'MATNR_T1'.
        LR_FCAT->COLTEXT    = TEXT-F33.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'MAKTX1'.
        LR_FCAT->COLTEXT    = TEXT-F43.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'SCRAT1'.
        LR_FCAT->COLTEXT    = TEXT-F34.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'MENGE1'.
        LR_FCAT->COLTEXT    = TEXT-F35.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'MATNR_T2'.
        LR_FCAT->COLTEXT    = TEXT-F36.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C400'.

      WHEN 'MAKTX2'.
        LR_FCAT->COLTEXT    = TEXT-F47.
        LR_FCAT->EMPHASIZE  = 'C400'.

      WHEN 'SCRAT2'.
        LR_FCAT->COLTEXT    = TEXT-F37.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C400'.

      WHEN 'MENGE2'.
        LR_FCAT->COLTEXT    = TEXT-F38.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C400'.

      WHEN 'MATNR_T3'.
        LR_FCAT->COLTEXT    = TEXT-F39.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C300'.

      WHEN 'MAKTX3'.
        LR_FCAT->COLTEXT    = TEXT-F48.
        LR_FCAT->EMPHASIZE  = 'C300'.

      WHEN 'SCRAT3'.
        LR_FCAT->COLTEXT    = TEXT-F40.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C300'.

      WHEN 'MENGE3'.
        LR_FCAT->COLTEXT    = TEXT-F41.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C300'.

      WHEN 'MATNR_T4'.
        LR_FCAT->COLTEXT    = TEXT-F61.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'MAKTX4'.
        LR_FCAT->COLTEXT    = TEXT-F62.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'SCRAT4'.
        LR_FCAT->COLTEXT    = TEXT-F63.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'MENGE4'.
        LR_FCAT->COLTEXT    = TEXT-F64.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C700'.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F42.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->JUST       = 'C'.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_weighing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_IN_WEIGHING .

  TRY.
      GR_WEIGHING->MS_LAYOUT = VALUE #( BASE GR_WEIGHING->MS_LAYOUT  GRID_TITLE = TEXT-T32 ).

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
      GR_LIST->MS_LAYOUT = VALUE #( BASE GR_LIST->MS_LAYOUT  STYLEFNAME = 'STYLE'
                                                             GRID_TITLE = TEXT-T31
                                                             COL_OPT    = ABAP_FALSE ).

    CATCH CX_ROOT.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED  USING PR_SENDER
                                PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                                PV_UCOMM TYPE SY-UCOMM.

  IF GR_LIST IS BOUND AND PR_SENDER EQ GR_LIST->MR_GRID.
    PERFORM DATA_CHANGED_IN_LIST USING PR_DATA_CHANGED PV_UCOMM.
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
*& Form field_valid_check_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM FIELD_VALID_CHECK_IN_LIST  USING PS_LIST TYPE TY_S_LIST.

  CLEAR: PS_LIST-STATUS, PS_LIST-MESSAGE, PS_LIST-RETURN.

  PERFORM CHECK_INPUT_VALUE_IN_LIST USING PS_LIST.
  PERFORM CHECK_MANDT_FIELD_IN_LIST USING PS_LIST.

  IF PS_LIST-RETURN IS NOT INITIAL.
    PS_LIST-STATUS = ICON_LED_RED.
    PS_LIST-MESSAGE = VALUE #( PS_LIST-RETURN[ 1 ]-MESSAGE OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE_IN_LIST  USING  PS_LIST TYPE TY_S_LIST.

  CLEAR PS_LIST-INIT.

*// 저장위치.
  IF PS_LIST-LGORT IS NOT INITIAL.
    READ TABLE GT_T001L TRANSPORTING NO FIELDS WITH TABLE KEY WERKS = PS_LIST-WERKS
                                                              LGORT = PS_LIST-LGORT.
    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E366(VL) WITH PS_LIST-LGORT PS_LIST-WERKS INTO DATA(LV_MESSAGE).
      PS_LIST-RETURN = VALUE #( BASE PS_LIST-RETURN ( TYPE = 'E' FIELD = TEXT-F23 MESSAGE = LV_MESSAGE ) ).
    ENDIF.
  ENDIF.

*// 발생부서.
  IF P_WERKS NE GC_WERKS-6600.
    CLEAR: PS_LIST-INDEPT, PS_LIST-DEPTXT.

    READ TABLE GT_DROP INTO DATA(LS_DROP) WITH KEY HANDLE = '1'
                                                   VALUE  = PS_LIST-INDEPT_DDLB.
    IF SY-SUBRC IS INITIAL.
      PS_LIST-INDEPT  = LS_DROP-INT_VALUE.
      DATA(LV_STRLEN) = STRLEN( LS_DROP-INT_VALUE ) + 1.
      PS_LIST-DEPTXT  = LS_DROP-VALUE+LV_STRLEN.
    ENDIF.
  ENDIF.

*// CS 설비코드.
  IF PS_LIST-CS_ARBPL IS NOT INITIAL.
    READ TABLE GT_ZGTPPT4141 TRANSPORTING NO FIELDS WITH TABLE KEY WERKS    = PS_LIST-WERKS
                                                                   CS_ARBPL = PS_LIST-CS_ARBPL.
    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE E028 WITH PS_LIST-CS_ARBPL PS_LIST-WERKS INTO LV_MESSAGE.
      PS_LIST-RETURN = VALUE #( BASE PS_LIST-RETURN ( TYPE = 'E' FIELD = TEXT-F05 MESSAGE = LV_MESSAGE ) ).
    ENDIF.


  ENDIF.

*// 스크랩분류 코드.
  CLEAR: PS_LIST-SCGRP, PS_LIST-SCTXT, PS_LIST-CNMAT.

  READ TABLE GT_DROP INTO LS_DROP WITH KEY HANDLE = '3'
                                           VALUE  = PS_LIST-SCGRP_DDLB.
  IF SY-SUBRC IS INITIAL.
    PS_LIST-SCGRP   = LS_DROP-INT_VALUE.
    LV_STRLEN = STRLEN( LS_DROP-INT_VALUE ) + 1.
    PS_LIST-SCTXT   = LS_DROP-VALUE+LV_STRLEN.

    READ TABLE GT_ZGTPPT1010 INTO DATA(LS_ZGTPPT1010) WITH KEY CODEGRP = GC_CODEGRP-4070
                                                               FLD_01  = PS_LIST-WERKS
                                                               FLD_02  = PS_LIST-SCGRP  BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      PS_LIST-CNMAT = LS_ZGTPPT1010-FLD_04.
    ENDIF.
  ENDIF.

*// SCRAP 사유.
  CLEAR PS_LIST-SCPREASON.

  READ TABLE GT_DROP INTO LS_DROP WITH KEY HANDLE = '2'
                                           VALUE  = PS_LIST-SCPREASON_DDLB.
  IF SY-SUBRC IS INITIAL.
    PS_LIST-SCPREASON = LS_DROP-INT_VALUE.
  ENDIF.

  CLEAR: PS_LIST-MATNR, PS_LIST-MAKTX,
         PS_LIST-WERKS_M, PS_LIST-LGORT_M, PS_LIST-MATNR_M, PS_LIST-MAKTX_M.

  IF PS_LIST-WERKS EQ GC_WERKS-6600. "// 전주공장일 경우.
    IF PS_LIST-SCGRP IS NOT INITIAL.
      READ TABLE GT_ZGTPPT1120 INTO DATA(LS_ZGTPPT1120) WITH KEY WERKS = PS_LIST-WERKS
                                                                 SPGCD = PS_LIST-SPGCD
                                                                 LGORT = PS_LIST-LGORT
                                                                 SCGRP = PS_LIST-SCGRP BINARY SEARCH.
      IF SY-SUBRC IS INITIAL.
        PS_LIST-MATNR   = LS_ZGTPPT1120-MATNR.
        PS_LIST-WERKS_M = LS_ZGTPPT1120-WERKS_M.
        PS_LIST-LGORT_M = LS_ZGTPPT1120-LGORT_M.
        PS_LIST-MATNR_M = LS_ZGTPPT1120-MATNR_M.

        PERFORM GET_MATERIAL_DESC USING PS_LIST-MATNR   PS_LIST-MAKTX.
        PERFORM GET_MATERIAL_DESC USING PS_LIST-MATNR_M PS_LIST-MAKTX_M.
      ENDIF.
    ENDIF.
  ENDIF.

*// 발생공정.
  IF PS_LIST-OPCOD IS NOT INITIAL.
    READ TABLE GT_ZGTPPT4140 TRANSPORTING NO FIELDS WITH KEY WERKS   = PS_LIST-WERKS
                                                             GONG_CD = PS_LIST-OPCOD BINARY SEARCH.
    IF SY-SUBRC IS NOT INITIAL.
      PS_LIST-RETURN = VALUE #( BASE PS_LIST-RETURN ( TYPE = 'E' FIELD = TEXT-F06 MESSAGE = TEXT-E20 ) ).
    ENDIF.

*    READ TABLE gt_zgtppt1010 INTO DATA(ls_zgtppt1010) WITH KEY codegrp = gc_codegrp-4090
*                                                               fld_01  = ps_list-werks
*                                                               fld_02  = ps_list-opcod BINARY SEARCH.
*    IF sy-subrc IS NOT INITIAL.
*      ps_list-return = VALUE #( BASE ps_list-return ( type = 'E' field = TEXT-f06 message = TEXT-e20 ) ).
*    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_MANDT_FIELD_IN_LIST  USING PS_LIST TYPE TY_S_LIST.

  DATA(LR_LIST) = REF #( PS_LIST ).

  LOOP AT GR_LIST->MT_FCAT INTO DATA(LS_FCAT)
                          WHERE MARK EQ ABAP_TRUE
                            AND TECH EQ ABAP_FALSE.
    PERFORM APPEND_MANDT_FIELD_TO_RETURN USING LR_LIST->(LS_FCAT-FIELDNAME) LS_FCAT-COLTEXT PS_LIST-RETURN.
  ENDLOOP.

  IF PS_LIST-CS_ARBPL IS INITIAL AND PS_LIST-OPCOD IS INITIAL.
    PS_LIST-RETURN = VALUE #( BASE PS_LIST-RETURN ( TYPE = 'E' FIELD = TEXT-F05 MESSAGE = TEXT-E09 ) ).
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
                                I_FIELDNAME = 'INDEPT'    I_VALUE = PS_LIST-INDEPT ),
                                I_FIELDNAME = 'DEPTXT'    I_VALUE = PS_LIST-DEPTXT ),
                                I_FIELDNAME = 'SCGRP'     I_VALUE = PS_LIST-SCGRP ),
                                I_FIELDNAME = 'SCTXT'     I_VALUE = PS_LIST-SCTXT ),
                                I_FIELDNAME = 'CNMAT'     I_VALUE = PS_LIST-CNMAT ),
                                I_FIELDNAME = 'SCPREASON' I_VALUE = PS_LIST-SCPREASON ),
                                I_FIELDNAME = 'MATNR'     I_VALUE = PS_LIST-MATNR ),
                                I_FIELDNAME = 'MAKTX'     I_VALUE = PS_LIST-MAKTX ),
                                I_FIELDNAME = 'WERKS_M'   I_VALUE = PS_LIST-WERKS_M ),
                                I_FIELDNAME = 'LGORT_M'   I_VALUE = PS_LIST-LGORT_M ),
                                I_FIELDNAME = 'MATNR_M'   I_VALUE = PS_LIST-MATNR_M ),
                                I_FIELDNAME = 'MAKTX_M'   I_VALUE = PS_LIST-MAKTX_M ),
                                I_FIELDNAME = 'INIT'      I_VALUE = PS_LIST-INIT ),
                                I_FIELDNAME = 'STATUS'    I_VALUE = PS_LIST-STATUS ),
                                I_FIELDNAME = 'MESSAGE'   I_VALUE = PS_LIST-MESSAGE ),
                                I_FIELDNAME = 'RETURN'    I_VALUE = PS_LIST-RETURN ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed_fini
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED_FINI   USING PR_SENDER
                                      PT_GOOD_CELLS TYPE LVC_T_MODI
                                      PV_MODIFIED.

*  IF gr_list IS BOUND AND pr_sender EQ gr_list->mr_grid.
*    PERFORM data_changed_fini_in_LIST USING po_data_changed pv_ucomm.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form split_screen_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SPLIT_SCREEN_LAYOUT .

  CHECK P_WERKS NE GC_WERKS-6600.

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
*& Form set_toolbar_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR_IN_LIST  USING PR_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

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
*& Form user_command_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_IN_LIST  USING  PV_UCOMM.

  CASE PV_UCOMM.
    WHEN GC_FCODE-INSERT_ROW. "// 행 추가.
      PERFORM USER_COMMAND_INSERT_ROW.

    WHEN GC_FCODE-DELETE_ROW. "// 행 삭제.
      PERFORM USER_COMMAND_DELETE_ROW.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_insert_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_INSERT_ROW .

  IF GT_LIST IS INITIAL.
    PERFORM APPEND_INIT_DATA.
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
*& Form user_command_delete_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_DELETE_ROW .

  MODIFY GT_LIST FROM VALUE #( SEL = SPACE )
                 TRANSPORTING SEL
                 WHERE SEL EQ ABAP_TRUE.

  GR_LIST->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    MESSAGE I000 WITH TEXT-E06 DISPLAY LIKE 'E'.
  ENDIF.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_LIST REFERENCE INTO DATA(LR_LIST) INDEX LS_ROW-INDEX.

    CHECK SY-SUBRC IS INITIAL AND LR_LIST->SCPNR IS INITIAL.

    LR_LIST->SEL = ABAP_TRUE.
  ENDLOOP.

  IF NOT LINE_EXISTS( GT_LIST[ SEL = ABAP_TRUE ] ).
    MESSAGE I000 WITH TEXT-E07 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  DELETE GT_LIST WHERE SEL EQ ABAP_TRUE.

  GR_LIST->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_SAVE .

  TRY.
      PERFORM CHECK_BEFORE_SAVE. "// 사전점검.
      PERFORM SAVE_WEIGHING.     "// 계근실적 저장

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        GR_LIST->REFRESH( ).
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_DISP_SCRAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_DISP_SCRAT .

  TRY.
      SUBMIT ZGTPPR1150 WITH P_WERKS  EQ P_WERKS
                        WITH P_SPGCD  EQ P_SPGCD
                        WITH P_PRDSCR EQ ABAP_FALSE
                        WITH P_CONRAT EQ ABAP_TRUE
                        WITH P_T1140  EQ ABAP_FALSE
                        WITH P_T1120  EQ ABAP_FALSE
                        WITH P_T1130  EQ ABAP_TRUE
                        AND RETURN.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      MESSAGE E000 WITH LR_ROOT->GET_TEXT( ) DISPLAY LIKE 'S'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_drop_down_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_DROP_DOWN_TABLE .

  CLEAR GT_DROP.

  LOOP AT GT_ZGTPPT1010 INTO DATA(LS_ZGTPPT1010)
                        WHERE FLD_01 EQ P_WERKS.
    CASE LS_ZGTPPT1010-CODEGRP.
      WHEN GC_CODEGRP-4050. "// 발생부서.
        APPEND INITIAL LINE TO GT_DROP REFERENCE INTO DATA(LR_DROP).
        LR_DROP->* = VALUE #( HANDLE    = '1'
                              VALUE     = |{ LS_ZGTPPT1010-FLD_02 } { LS_ZGTPPT1010-FLD_03 }|
                              INT_VALUE = LS_ZGTPPT1010-FLD_02 ).

      WHEN GC_CODEGRP-4060. "// 스크랩사유.
        APPEND INITIAL LINE TO GT_DROP REFERENCE INTO LR_DROP.
        LR_DROP->* = VALUE #( HANDLE    = '2'
                              VALUE     = |{ LS_ZGTPPT1010-FLD_02 } { LS_ZGTPPT1010-FLD_03 }|
                              INT_VALUE = LS_ZGTPPT1010-FLD_02 ).

      WHEN GC_CODEGRP-4070. "// 스크랩코드.
        APPEND INITIAL LINE TO GT_DROP REFERENCE INTO LR_DROP.
        LR_DROP->* = VALUE #( HANDLE    = '3'
                              VALUE     = |{ LS_ZGTPPT1010-FLD_02 } { LS_ZGTPPT1010-FLD_03 }|
                              INT_VALUE = LS_ZGTPPT1010-FLD_02 ).
    ENDCASE.
  ENDLOOP.

  SORT GT_DROP BY HANDLE VALUE.

  GR_LIST->MR_GRID->SET_DROP_DOWN_TABLE( IT_DROP_DOWN_ALIAS = GT_DROP ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_defalut_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_DEFALUT_VALUE  USING  PS_LIST TYPE TY_S_LIST.

  PS_LIST = VALUE #( WERKS  = P_WERKS
                     SPGCD  = P_SPGCD
                     LGORT  = COND #( WHEN P_WERKS EQ GC_WERKS-6500 AND P_SPGCD EQ 'GP' THEN GC_LGORT-2190
                                      WHEN P_WERKS EQ GC_WERKS-6500 AND P_SPGCD EQ 'GA' THEN GC_LGORT-2190
                                      WHEN P_WERKS EQ GC_WERKS-6600 AND P_SPGCD EQ 'GL' THEN GC_LGORT-2390
                                      WHEN P_WERKS EQ GC_WERKS-6600 AND P_SPGCD EQ 'GO' THEN GC_LGORT-2190 )
                     SCPDAT = SY-DATUM
                     MEINS  = ZGTPP_IF_CONST=>GC_MEINS-KG
                     INIT   = ABAP_TRUE ).

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

  PERFORM GET_ROWS_SELECTED_FOR_SAVE.

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
*& Form save_weighing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_WEIGHING RAISING LCX_EXCEPTION.
  DATA LT_ZGTPPT4130 TYPE TY_T_ZGTPPT4130.
  DATA LT_SCRAP TYPE TY_T_SCRAP.
  DATA LV_SCPNR TYPE CHAR12.

*// 처리일자.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

*// 작업장별 생산실적.
  PERFORM SUMMARY_CONF_PROD_QTY_BY_WC.

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST)
                  WHERE SEL EQ ABAP_TRUE.


    IF LR_LIST->SCPNR IS INITIAL.
      PERFORM GET_NEXT_NUMBER USING 'ZGTPP_GORD' LV_SCPNR.  "// 계근번호.
      LR_LIST->* = VALUE #( BASE LR_LIST->* SCPNR = LV_SCPNR+2(10) ).
      LR_LIST->* = CORRESPONDING #( BASE ( LR_LIST->* ) GS_ZGTPPS1001 ).
    ELSE.
      LR_LIST->* = VALUE #( BASE LR_LIST->* CHDAT = GS_ZGTPPS1001-CHDAT
                                            CHTIM = GS_ZGTPPS1001-CHTIM
                                            CHNAM = GS_ZGTPPS1001-CHNAM ).
    ENDIF.

* 스크랩 분류에 다른 스크랩처리 변경
* 비수불스크랩 대상
* //
    READ TABLE GT_ZGTPPT1010 TRANSPORTING NO FIELDS WITH KEY CODEGRP = '4070'
                                                             FLD_01 = P_WERKS
                                                             FLD_02 = LR_LIST->SCGRP
                                                             FLD_05 = ABAP_TRUE..
    IF SY-SUBRC EQ 0.
      TRY.
          PERFORM NPP_GOODS_RECEIPT CHANGING LR_LIST->*.

          LR_LIST->STATUS  = ICON_LED_GREEN.
          LR_LIST->MESSAGE = TEXT-S01.
          LR_LIST->STYLE   = GT_STYLE.
          GS_RESULT-SUCCESS += 1.

        CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
          PERFORM REVERSE_GOODS_MOVEMENTS USING LR_LIST.
          PERFORM UPDATE_UNDO_RESULT USING LR_LIST.

          CONTINUE.
      ENDTRY.

    ELSE.
* //
      PERFORM BUILD_SCRAP_DATA USING LR_LIST->* LT_SCRAP LT_ZGTPPT4130.

      TRY.
          PERFORM TRANSFER_POSTING USING LR_LIST->* LT_SCRAP.      "// Step 1: 스크랩 대체.

          IF P_WERKS EQ GC_WERKS-6500.
            PERFORM MATERIAL_ISSUE      USING LR_LIST->* LT_SCRAP. "// Step 2: 탈피 전 자재(물자) 출고.
            PERFORM OTHER_GOODS_RECEIPT USING LR_LIST->* LT_SCRAP. "// Step 3: 탈피 후 자재(물자) 입고.
          ENDIF.

          LR_LIST->STATUS  = ICON_LED_GREEN.
          LR_LIST->MESSAGE = TEXT-S01.
          LR_LIST->STYLE   = GT_STYLE.
          GS_RESULT-SUCCESS += 1.

          PERFORM UPDATE_ZGTPPT4130 USING LT_ZGTPPT4130. "// 스크랩 계근 실적 상세.

        CATCH LCX_EXCEPTION INTO LR_EXCEPTION.
          PERFORM REVERSE_GOODS_MOVEMENTS USING LR_LIST.
          PERFORM UPDATE_UNDO_RESULT USING LR_LIST.

          CONTINUE.
      ENDTRY.
    ENDIF.
  ENDLOOP.

  DELETE GT_LIST WHERE INIT EQ ABAP_TRUE.

  GR_LIST->REFRESH( ).

  IF GR_WEIGHING IS BOUND.
    PERFORM GET_WEIGHING_OF_SELECTED_SCPNR USING GC_DISPLAY-SINGLE.
    GR_WEIGHING->REFRESH( ).
  ENDIF.

  MESSAGE S009 WITH GS_RESULT-TOTAL GS_RESULT-SUCCESS GS_RESULT-ERROR.

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
*& Form get_rows_selected_for_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_FOR_SAVE .

  CLEAR GS_RESULT.

  MODIFY GT_LIST FROM VALUE #( SEL = SPACE )
                 TRANSPORTING SEL
                 WHERE SEL EQ ABAP_TRUE.

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST)
                  WHERE INIT EQ ABAP_FALSE.
    IF LR_LIST->RETURN IS NOT INITIAL.
      GS_RESULT-INVALID = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    GS_RESULT-SEL += 1.

    CHECK LR_LIST->SCPNR IS INITIAL.

    LR_LIST->SEL = ABAP_TRUE.
    GS_RESULT-TOTAL += 1.
  ENDLOOP.

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
      NR_RANGE_NR             = '05'
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

*  COMMIT WORK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_master_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_MASTER_DATA .

*// 공통 코드 관리
  SELECT *
    FROM ZGTPPT1010
    INTO TABLE @GT_ZGTPPT1010
   WHERE MODULE_KIND EQ 'PP'
     AND CODEGRP IN (@GC_CODEGRP-4050,@GC_CODEGRP-4060,@GC_CODEGRP-4070,@GC_CODEGRP-4080, @GC_CODEGRP-4090)
     AND FLD_01  EQ @P_WERKS
   ORDER BY CODEGRP, FLD_01, FLD_02, FLD_03.

*// 공정 및 물자 스크랩 코드 관리(GAON)
  SELECT *
    FROM ZGTPPT1120
    INTO TABLE @GT_ZGTPPT1120
   WHERE WERKS EQ @P_WERKS
     AND SPGCD EQ @P_SPGCD
   ORDER BY WERKS, SPGCD, LGORT, SCGRP.

  SELECT *
    FROM ZGTPPT1140
    INTO TABLE @GT_ZGTPPT1140
   WHERE WERKS EQ @P_WERKS
     AND SPGCD EQ @P_SPGCD
   ORDER BY WERKS, SPGCD, MATKL, MATNR.

  SELECT WERKS, LGORT, LGOBE
    INTO CORRESPONDING FIELDS OF TABLE @GT_T001L
    FROM T001L.

  SELECT *
    FROM ZGTPPT4140
    INTO TABLE @GT_ZGTPPT4140
   WHERE WERKS EQ @P_WERKS
    ORDER BY WERKS, GONG_CD, CS_ARBPL, ARBPL.

  SELECT *
    FROM ZGTPPT4141
    INTO TABLE @GT_ZGTPPT4141
   WHERE WERKS EQ @P_WERKS.

*// 탈피 후 스크랩 자재 관리(GAON).
  SELECT *
    FROM ZGTPPT1130
    INTO TABLE @GT_ZGTPPT1130
   WHERE USEYN EQ @ABAP_TRUE
   ORDER BY WERKS, SPGCD, LGORT, SCGRP, MATNR_T.

  GT_STYLE = VALUE #( STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED  ( FIELDNAME = 'LGORT' )
                                                                  ( FIELDNAME = 'INDEPT_DDLB' )
                                                                  ( FIELDNAME = 'DEPTXT' )
                                                                  ( FIELDNAME = 'CS_ARBPL' )
                                                                  ( FIELDNAME = 'OPCOD' )
                                                                  ( FIELDNAME = 'SCGRP_DDLB' )
                                                                  ( FIELDNAME = 'SCPQT' )
                                                                  ( FIELDNAME = 'SCPREASON_DDLB' )
                                                                  ( FIELDNAME = 'SCPDAT' ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_F4  USING PR_SENDER.

  IF PR_SENDER EQ GR_LIST.
    GR_LIST->MT_F4 = VALUE #( REGISTER = ABAP_TRUE CHNGEAFTER = ABAP_TRUE ( FIELDNAME = 'OPCOD' ) ).
  ENDIF.

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
*& Form transfer_posting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM TRANSFER_POSTING  USING PS_LIST TYPE TY_S_LIST
                             PT_SCRAP TYPE TY_T_SCRAP
                     RAISING LCX_EXCEPTION.

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LT_ITEM    TYPE GM_ITEMS_T.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LS_ZGTPPT4120 TYPE ZGTPPT4120.

  LOOP AT PT_SCRAP INTO DATA(LS_SCRAP).
    CHECK LS_SCRAP-MENGE IS NOT INITIAL.

    APPEND INITIAL LINE TO LT_ITEM REFERENCE INTO DATA(LR_ITEM).
    LR_ITEM->* = VALUE #( MATERIAL   = CONV MATNR18( LS_SCRAP-MATNR )
                          PLANT      = PS_LIST-WERKS
                          STGE_LOC   = PS_LIST-LGORT
                          MOVE_TYPE  = GC_BWART-309
                          MOVE_PLANT = LS_SCRAP-WERKS_M
                          MOVE_MAT   = CONV MATNR18( LS_SCRAP-MATNR_M )
                          MOVE_STLOC = LS_SCRAP-LGORT_M
                          ENTRY_UOM  = LS_SCRAP-MEINS
                          ENTRY_QNT  = LS_SCRAP-MENGE ).
  ENDLOOP.

*처리 실적이 없는 경우 validation
  IF LT_ITEM[] IS NOT INITIAL.
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = VALUE BAPI2017_GM_HEAD_01( PSTNG_DATE = PS_LIST-SCPDAT
                                                      DOC_DATE   = PS_LIST-SCPDAT
                                                      HEADER_TXT = |{ TEXT-011 } { PS_LIST-SCPNR }| )
        GOODSMVT_CODE    = ZGTPP_IF_CONST=>GC_GM_CODE-TRANSFER_POSTING
      IMPORTING
        GOODSMVT_HEADRET = LS_HEADRET
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.

    IF LS_HEADRET IS NOT INITIAL.
      PS_LIST-MBLNR_309 = LS_HEADRET-MAT_DOC.
      PS_LIST-MJAHR     = LS_HEADRET-DOC_YEAR.

      INSERT INITIAL LINE INTO PS_LIST-MATDOC INDEX 1 REFERENCE INTO DATA(LR_MATDOC).
      LR_MATDOC->* = VALUE #( BASE CORRESPONDING #( LS_HEADRET ) BWART = GC_BWART-309
                                                                 BUDAT = PS_LIST-SCPDAT ).

      PERFORM UPDATE_PROCESSING_RESULT USING PS_LIST LS_ZGTPPT4120.
    ELSE.
      PS_LIST-MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH PS_LIST-MESSAGE.
    ENDIF.

  ELSE.
    "해당 스크랩이 발생한 설비의 당월 실적이 없어 처리할 수 없습니다.
    PS_LIST-MESSAGE = TEXT-E22.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH PS_LIST-MESSAGE.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form material_issue
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MATERIAL_ISSUE  USING PS_LIST  TYPE TY_S_LIST
                           PT_SCRAP TYPE TY_T_SCRAP
                   RAISING LCX_EXCEPTION.

  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LT_ITEM    TYPE GM_ITEMS_T.
  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_ZGTPPT4120 TYPE ZGTPPT4120.

  LOOP AT PT_SCRAP INTO DATA(LS_SCRAP).
    CHECK LS_SCRAP-MENGE IS NOT INITIAL.

    APPEND INITIAL LINE TO LT_ITEM REFERENCE INTO DATA(LR_ITEM).

    READ TABLE GT_ZGTPPT1010 INTO DATA(LS_ZGTPPT1010) WITH KEY CODEGRP = GC_CODEGRP-4080
                                                               FLD_01  = LS_SCRAP-WERKS_M
                                                               FLD_02  = LS_SCRAP-SPGCD BINARY SEARCH.

    LR_ITEM->* = VALUE #( MATERIAL   = CONV MATNR18( LS_SCRAP-MATNR_M )
                          PLANT      = LS_SCRAP-WERKS_M
                          STGE_LOC   = LS_SCRAP-LGORT_M
                          MOVE_TYPE  = GC_BWART-Z31
                          ENTRY_QNT  = LS_SCRAP-MENGE
                          ENTRY_UOM  = LS_SCRAP-MEINS
                          COSTCENTER = |{ LS_ZGTPPT1010-FLD_03 ALPHA = IN }| ).

    CLEAR LS_ZGTPPT1010.
  ENDLOOP.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = VALUE BAPI2017_GM_HEAD_01( PSTNG_DATE = PS_LIST-SCPDAT
                                                    DOC_DATE   = PS_LIST-SCPDAT
                                                    PR_UNAME   = SY-UNAME
                                                    HEADER_TXT = |{ TEXT-012 } { PS_LIST-SCPNR }| )
      GOODSMVT_CODE    = ZGTPP_IF_CONST=>GC_GM_CODE-GI_FOR_ORDER
    IMPORTING
      GOODSMVT_HEADRET = LS_HEADRET
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = LT_RETURN.

  IF LS_HEADRET IS NOT INITIAL.
    PS_LIST-MBLNR_Z31 = LS_HEADRET-MAT_DOC.
    PS_LIST-MJAHR     = LS_HEADRET-DOC_YEAR.

    INSERT INITIAL LINE INTO PS_LIST-MATDOC INDEX 1 REFERENCE INTO DATA(LR_MATDOC).
    LR_MATDOC->* = VALUE #( BASE CORRESPONDING #( LS_HEADRET ) BWART = GC_BWART-Z31
                                                               BUDAT = PS_LIST-SCPDAT ).

    PERFORM UPDATE_PROCESSING_RESULT USING PS_LIST LS_ZGTPPT4120.
  ELSE.
    PS_LIST-MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH PS_LIST-MESSAGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form other_goods_receipt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM OTHER_GOODS_RECEIPT  USING PS_LIST  TYPE TY_S_LIST
                                PT_SCRAP TYPE TY_T_SCRAP
                        RAISING LCX_EXCEPTION.

  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LT_ITEM    TYPE GM_ITEMS_T.
  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LV_INDEX   TYPE NUMC1.
  DATA LV_FIELD   TYPE STRING.
  DATA LS_ZGTPPT4120 TYPE ZGTPPT4120.

  DATA(LR_ZGTPPT4120) = REF #( LS_ZGTPPT4120 ).

  LR_ZGTPPT4120->* = VALUE #( SCPNR = PS_LIST-SCPNR
                              SCPQT = PS_LIST-SCPQT
                              MEINS = PS_LIST-MEINS ).

  DATA(LS_SCRAP) = VALUE #( PT_SCRAP[ 1 ] OPTIONAL ).

  READ TABLE GT_ZGTPPT1010 INTO DATA(LS_ZGTPPT1010) WITH KEY CODEGRP = GC_CODEGRP-4080
                                                             FLD_01  = LS_SCRAP-WERKS_M
                                                             FLD_02  = PS_LIST-SPGCD BINARY SEARCH.

  LOOP AT GT_ZGTPPT1130  INTO DATA(LS_ZGTPPT1130)
                        USING KEY SKEY1
                        WHERE WERKS EQ PS_LIST-WERKS
                          AND SPGCD EQ PS_LIST-SPGCD
                          AND LGORT EQ PS_LIST-LGORT
                          AND SCGRP EQ PS_LIST-SCGRP.
    IF CONTAINS( VAL = LS_ZGTPPT1130-MAKTX_T  SUB = 'CU' ).
      LV_INDEX = 1.
    ELSEIF CONTAINS( VAL = LS_ZGTPPT1130-MAKTX_T  SUB = 'PVC' ).
      LV_INDEX = 2.
    ELSEIF CONTAINS( VAL = LS_ZGTPPT1130-MAKTX_T  SUB = 'PE' ).
      LV_INDEX = 3.
    ELSEIF CONTAINS( VAL = LS_ZGTPPT1130-MAKTX_T  SUB = 'AL' ).
      LV_INDEX = 4.
    ELSE.
      CONTINUE.
    ENDIF.

    LV_FIELD = |MATNR_T{ LV_INDEX }|.
    LR_ZGTPPT4120->(LV_FIELD) = LS_ZGTPPT1130-MATNR_T.

    LV_FIELD = |SCRAT{ LV_INDEX }|.
    LR_ZGTPPT4120->(LV_FIELD) = LS_ZGTPPT1130-SCRAT.

    LV_FIELD = |MENGE{ LV_INDEX }|.
    LR_ZGTPPT4120->(LV_FIELD) = PS_LIST-SCPQT * LS_ZGTPPT1130-SCRAT / 100.

    APPEND INITIAL LINE TO LT_ITEM REFERENCE INTO DATA(LR_ITEM).
    LR_ITEM->* = VALUE #( MATERIAL   = CONV MATNR18( LS_ZGTPPT1130-MATNR_T )
                          PLANT      = LS_SCRAP-WERKS_M
                          STGE_LOC   = LS_SCRAP-LGORT_M
                          MOVE_TYPE  = GC_BWART-Z41
                          ENTRY_QNT  = ( PS_LIST-SCPQT * LS_ZGTPPT1130-SCRAT / 100 )
                          ENTRY_UOM  = PS_LIST-MEINS
                          COSTCENTER = |{ LS_ZGTPPT1010-FLD_03 ALPHA = IN }|  ).
  ENDLOOP.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = VALUE BAPI2017_GM_HEAD_01( PSTNG_DATE = PS_LIST-SCPDAT
                                                    DOC_DATE   = PS_LIST-SCPDAT
                                                    PR_UNAME   = SY-UNAME
                                                    HEADER_TXT = |{ TEXT-013 } { PS_LIST-SCPNR }| )
      GOODSMVT_CODE    = ZGTPP_IF_CONST=>GC_GM_CODE-OTHER_GR
    IMPORTING
      GOODSMVT_HEADRET = LS_HEADRET
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = LT_RETURN.

  IF LS_HEADRET IS NOT INITIAL.
    PS_LIST-MBLNR_Z41 = LS_HEADRET-MAT_DOC.
    PS_LIST-MJAHR     = LS_HEADRET-DOC_YEAR.

    INSERT INITIAL LINE INTO PS_LIST-MATDOC INDEX 1 REFERENCE INTO DATA(LR_MATDOC).
    LR_MATDOC->* = VALUE #( BASE CORRESPONDING #( LS_HEADRET ) BWART = GC_BWART-Z41
                                                               BUDAT = PS_LIST-SCPDAT ).

    PERFORM UPDATE_PROCESSING_RESULT USING PS_LIST LS_ZGTPPT4120.
  ELSE.
    PS_LIST-MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH PS_LIST-MESSAGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MATERIAL_DESC
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
*& Form update_processing_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_PROCESSING_RESULT  USING PS_LIST       TYPE TY_S_LIST
                                     PS_ZGTPPT4120 TYPE ZGTPPT4120
                             RAISING LCX_EXCEPTION.

  DATA(LS_ZGTPPT4110) = CORRESPONDING ZGTPPT4110( PS_LIST ).
  LS_ZGTPPT4110 = CORRESPONDING #( BASE ( LS_ZGTPPT4110 ) GS_ZGTPPS1001 ).

  TRY.
      MODIFY ZGTPPT4110 FROM LS_ZGTPPT4110.

      IF PS_ZGTPPT4120 IS NOT INITIAL.
        MODIFY ZGTPPT4120 FROM PS_ZGTPPT4120.
      ENDIF.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E01.
  ENDTRY.

  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form reverse_goods_movements
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM REVERSE_GOODS_MOVEMENTS  USING PR_LIST TYPE REF TO TY_S_LIST.

  LOOP AT PR_LIST->MATDOC REFERENCE INTO DATA(LR_MATDOC).
    TRY.
        PERFORM GOODSMVT_CANCEL USING PR_LIST LR_MATDOC->*.

      CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
        EXIT.
    ENDTRY.
  ENDLOOP.

  DELETE PR_LIST->MATDOC WHERE DEL EQ ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form goodsmvt_cancel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GOODSMVT_CANCEL  USING PR_LIST   TYPE REF TO TY_S_LIST
                            PS_MATDOC TYPE TY_S_MATDOC
                    RAISING LCX_EXCEPTION.

  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LT_ENQ     TYPE TABLE OF SEQG3.
  DATA LV_SUBRC   TYPE SY-SUBRC.
  DATA LV_NUMBER  TYPE SY-TABIX.

  "취소 문서의 취소 처리 결과 체크
  SELECT SINGLE MANDT
    FROM MATDOC
   WHERE MBLNR EQ @PS_MATDOC-MAT_DOC
     AND MJAHR EQ @PS_MATDOC-DOC_YEAR
     AND CANCELLED EQ 'X'
    INTO @DATA(LV_MANDT).

  CHECK SY-SUBRC NE 0.

  IF PS_MATDOC-BWART EQ GC_BWART-309.
    CLEAR: GS_HEADRET1, GT_RETURN1, GV_JOBS.

*** 2026.08.01 추가
    SELECT SINGLE BUDAT
      FROM MKPF
     WHERE MBLNR = @PS_MATDOC-MAT_DOC
       AND MJAHR = @PS_MATDOC-DOC_YEAR
      INTO @DATA(LV_BUDAT).

    CALL FUNCTION 'ZGTPP_BAPI_GOODSMVT_CANCEL' STARTING NEW TASK 'MBLNR'
      PERFORMING GET_309_CANCEL ON END OF TASK
      EXPORTING
        MATERIALDOCUMENT    = PS_MATDOC-MAT_DOC
        MATDOCUMENTYEAR     = PS_MATDOC-DOC_YEAR
        GOODSMVT_PSTNG_DATE = LV_BUDAT.
*        GOODSMVT_PSTNG_DATE = PS_MATDOC-BUDAT.
*** 2026.08.01 추가

    WAIT UNTIL GV_JOBS = '1'.

    IF GS_HEADRET1-MAT_DOC IS NOT INITIAL.
      PS_MATDOC-DEL = ABAP_TRUE.
      DATA(LV_FIELD1) = |MBLNR_{ PS_MATDOC-BWART }_C|.
      PR_LIST->(LV_FIELD1) = GS_HEADRET1-MAT_DOC.

      UPDATE ZGTPPT4110
         SET MBLNR_309_C = PR_LIST->MBLNR_309_C
             MJAHR       = PR_LIST->MJAHR
             CHDAT       = GS_ZGTPPS1001-CHDAT
             CHTIM       = GS_ZGTPPS1001-CHTIM
             CHNAM       = GS_ZGTPPS1001-CHNAM
       WHERE SCPNR EQ PR_LIST->SCPNR.

      COMMIT WORK AND WAIT.

    ELSE.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH VALUE #( GT_RETURN1[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
    ENDIF.

  ELSE.
*** 2026.08.01 추가
    SELECT SINGLE BUDAT
      FROM MKPF
     WHERE MBLNR = @PS_MATDOC-MAT_DOC
       AND MJAHR = @PS_MATDOC-DOC_YEAR
      INTO @LV_BUDAT.

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        MATERIALDOCUMENT    = PS_MATDOC-MAT_DOC
        MATDOCUMENTYEAR     = PS_MATDOC-DOC_YEAR
        GOODSMVT_PSTNG_DATE = LV_BUDAT
*        GOODSMVT_PSTNG_DATE = PS_MATDOC-BUDAT
*** 2026.08.01 추가

      IMPORTING
        GOODSMVT_HEADRET    = LS_HEADRET
      TABLES
        RETURN              = LT_RETURN.

    IF LS_HEADRET IS NOT INITIAL.
      PS_MATDOC-DEL = ABAP_TRUE.
      DATA(LV_FIELD) = |MBLNR_{ PS_MATDOC-BWART }_C|.
      PR_LIST->(LV_FIELD) = LS_HEADRET-MAT_DOC.

      UPDATE ZGTPPT4110
         SET MBLNR_Z31_C = PR_LIST->MBLNR_Z31_C
             MBLNR_Z41_C = PR_LIST->MBLNR_Z41_C
             MJAHR       = PR_LIST->MJAHR
             CHDAT       = GS_ZGTPPS1001-CHDAT
             CHTIM       = GS_ZGTPPS1001-CHTIM
             CHNAM       = GS_ZGTPPS1001-CHNAM
       WHERE SCPNR EQ PR_LIST->SCPNR.

      COMMIT WORK AND WAIT.

      DO 20 TIMES.
        CLEAR LT_ENQ.

        CALL FUNCTION 'ENQUEUE_READ'
          EXPORTING
            GNAME                 = 'MBEW'
          IMPORTING
            NUMBER                = LV_NUMBER
            SUBRC                 = LV_SUBRC
          TABLES
            ENQ                   = LT_ENQ
          EXCEPTIONS
            COMMUNICATION_FAILURE = 1
            SYSTEM_FAILURE        = 2
            OTHERS                = 3.

        IF LT_ENQ IS INITIAL.
          EXIT.
        ENDIF.

        WAIT UP TO '0.5' SECONDS.
      ENDDO.
    ELSE.
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_delete
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_DELETE .

  TRY.
*// 사전점검.
      PERFORM CHECK_BEFORE_DELETE.

*// 계근 실적 취소.
      PERFORM DELETE_WEIGHING.

    CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).
      IF LR_EXCEPTION->GET_TEXT( ) IS NOT INITIAL.
        GR_LIST->REFRESH( ).
        MESSAGE LR_EXCEPTION->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_DELETE RAISING LCX_EXCEPTION.

  DATA LV_ANSWER TYPE C.

  GR_LIST->MR_GRID->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).

  IF LV_VALID NE ABAP_TRUE.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

  PERFORM GET_ROWS_SELECTED_FOR_DEL.

  IF GS_RESULT-INVALID IS NOT INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E03.
  ENDIF.

  IF GS_RESULT-SEL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E06.
  ENDIF.

  IF GS_RESULT-TOTAL IS INITIAL.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH TEXT-E04.
  ENDIF.

  PERFORM CONFIRMATION_POPUP USING TEXT-C03 LV_ANSWER.

  IF LV_ANSWER NE '1'.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rows_selected_FOR_DEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ROWS_SELECTED_FOR_DEL .

  CLEAR GS_RESULT.

  MODIFY GT_LIST FROM VALUE #( SEL = SPACE )
                 TRANSPORTING SEL
                 WHERE SEL EQ ABAP_TRUE.

  GR_LIST->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  LOOP AT LT_ROWS INTO DATA(LS_ROW).
    READ TABLE GT_LIST REFERENCE INTO DATA(LR_LIST) INDEX LS_ROW-INDEX.

    CHECK SY-SUBRC IS INITIAL.

    GS_RESULT-SEL += 1.

    IF LR_LIST->RETURN IS NOT INITIAL.
      GS_RESULT-INVALID = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    CHECK LR_LIST->SCPNR IS NOT INITIAL.

    GS_RESULT-TOTAL += 1.

    LR_LIST->SEL = ABAP_TRUE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_weighing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DELETE_WEIGHING .

*// 처리일자 및 시간.
  PERFORM GET_DATE_TIME USING GS_ZGTPPS1001.

  LOOP AT GT_LIST REFERENCE INTO DATA(LR_LIST)
                  WHERE SEL EQ ABAP_TRUE.
    CLEAR LR_LIST->MATDOC.
    PERFORM APPEND_MATERIAL_DOCUMENT USING LR_LIST: GC_BWART-Z41, GC_BWART-Z31, GC_BWART-309.
    PERFORM REVERSE_GOODS_MOVEMENTS  USING LR_LIST.
    PERFORM UPDATE_DELETE_RESULT     USING LR_LIST.
  ENDLOOP.

  DELETE GT_LIST WHERE DEL EQ ABAP_TRUE.

  GR_LIST->REFRESH( ).

  IF GR_WEIGHING IS BOUND.
    PERFORM GET_WEIGHING_OF_SELECTED_SCPNR USING GC_DISPLAY-SINGLE.
    GR_WEIGHING->REFRESH( ).
  ENDIF.

  MESSAGE S009 WITH GS_RESULT-TOTAL GS_RESULT-SUCCESS GS_RESULT-ERROR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_delete_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_DELETE_RESULT  USING  PR_LIST TYPE REF TO TY_S_LIST.

  IF PR_LIST->MATDOC IS INITIAL.
    GS_RESULT-SUCCESS += 1.
  ELSE.
    GS_RESULT-ERROR += 1.
    RETURN.
  ENDIF.

  PR_LIST->DEL = ABAP_TRUE.

*// 스크랩 계근실적.
  UPDATE ZGTPPT4110
     SET LKENZ = ABAP_TRUE
         CHDAT = GS_ZGTPPS1001-CHDAT
         CHTIM = GS_ZGTPPS1001-CHTIM
         CHNAM = GS_ZGTPPS1001-CHNAM
   WHERE SCPNR EQ PR_LIST->SCPNR.

*// 스크랩 계근 실적 상세.
  UPDATE ZGTPPT4130
     SET LKENZ = ABAP_TRUE
         CHDAT = GS_ZGTPPS1001-CHDAT
         CHTIM = GS_ZGTPPS1001-CHTIM
         CHNAM = GS_ZGTPPS1001-CHNAM
   WHERE SCPNR EQ PR_LIST->SCPNR.

  IF P_WERKS NE GC_WERKS-6600.
    UPDATE ZGTPPT4120
       SET LKENZ = @ABAP_TRUE
     WHERE SCPNR EQ @PR_LIST->SCPNR.
  ENDIF.

  COMMIT WORK AND WAIT.

  DELETE GT_WEIGHING WHERE SCPNR EQ PR_LIST->SCPNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_material_document
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM APPEND_MATERIAL_DOCUMENT  USING PR_LIST TYPE REF TO TY_S_LIST
                                     PV_BWART.

  DATA(LV_FIELD) = |MBLNR_{ PV_BWART }|.

  CHECK PR_LIST->(LV_FIELD) IS NOT INITIAL.

  APPEND INITIAL LINE TO PR_LIST->MATDOC REFERENCE INTO DATA(LR_MATDOC).

  LR_MATDOC->* = VALUE #( MAT_DOC  = PR_LIST->(LV_FIELD)
                          DOC_YEAR = PR_LIST->MJAHR
                          BWART    = PV_BWART
                          BUDAT    = PR_LIST->SCPDAT ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_init_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM APPEND_INIT_DATA .

  DO 10 TIMES.
    APPEND INITIAL LINE TO GT_LIST REFERENCE INTO DATA(LR_LIST).
    PERFORM SET_DEFALUT_VALUE USING LR_LIST->*.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form enqueue_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ENQUEUE_TABLE .

  CALL FUNCTION 'ENQUEUE_E_TABLE'
    EXPORTING
      TABNAME        = GC_TABLE-ZGTPPT4110
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
      TABNAME = GC_TABLE-ZGTPPT4110
      VARKEY  = CONV VIM_ENQKEY( |{ P_WERKS }{ P_SPGCD }| ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK_IN_LIST   USING PS_ROW    TYPE LVC_S_ROID
                                  PS_COLUMN TYPE LVC_S_COL.

  TRY.
      DATA(LR_LIST) = REF #( GT_LIST[ PS_ROW-ROW_ID ] ).

    CATCH CX_SY_ITAB_LINE_NOT_FOUND.
      RETURN.
  ENDTRY.

  CASE PS_COLUMN-FIELDNAME.
    WHEN 'MBLNR_309' OR 'MBLNR_Z31' OR 'MBLNR_Z41'.
      PERFORM CALL_TRANSACTION_MIGO USING LR_LIST->(PS_COLUMN-FIELDNAME) LR_LIST->MJAHR.

    WHEN OTHERS.
      IF LR_LIST->SCPNR IS INITIAL.
        RETURN.
      ENDIF.

      MODIFY GT_LIST FROM VALUE #( CLICKED = ABAP_FALSE ) TRANSPORTING CLICKED
                     WHERE CLICKED EQ ABAP_TRUE.

      LR_LIST->CLICKED = ABAP_TRUE.

      PERFORM GET_WEIGHING_OF_SELECTED_SCPNR USING GC_DISPLAY-SINGLE.

      GR_WEIGHING->REFRESH( ).
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_transaction_migo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_TRANSACTION_MIGO  USING  PV_MBLNR PV_MJAHR.

  CHECK PV_MBLNR IS NOT INITIAL.

  CALL FUNCTION 'MIGO_DIALOG'
    EXPORTING
      I_ACTION            = 'A04'       "// 조회
      I_REFDOC            = 'R02'       "/ 자재문서
      I_MBLNR             = PV_MBLNR
      I_MJAHR             = PV_MJAHR
    EXCEPTIONS
      ILLEGAL_COMBINATION = 1
      OTHERS              = 2.

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
    WHEN 'OPCOD'.
      PERFORM F4_OPCOD USING PV_FIELDNAME  PV_FIELDVALUE PS_ROW_NO
                             PR_EVENT_DATA PT_BAD_CELLS  PV_DISPLAY.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_OPCOD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM F4_OPCOD  USING PV_FIELDNAME
                     PV_FIELDVALUE
                     PS_ROW_NO     TYPE LVC_S_ROID
                     PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                     PT_BAD_CELLS  TYPE LVC_T_MODI
                     PV_DISPLAY.
  DATA LV_USER_RESET TYPE C.
  DATA LT_RETURN TYPE TABLE OF DDSHRETVAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VALUE'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = TEXT-T23
      VALUE_ORG       = 'S'
    IMPORTING
      USER_RESET      = LV_USER_RESET
    TABLES
      VALUE_TAB       = GT_OPCOD[]
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
*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_undo_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_UNDO_RESULT  USING PR_LIST TYPE REF TO TY_S_LIST.

  IF PR_LIST->MATDOC IS INITIAL.
    CLEAR: PR_LIST->MBLNR_309, PR_LIST->MBLNR_309_C,
           PR_LIST->MBLNR_Z31, PR_LIST->MBLNR_Z31_C,
           PR_LIST->MBLNR_Z41, PR_LIST->MBLNR_Z41_C.

    UPDATE ZGTPPT4110
       SET MBLNR_309   = PR_LIST->MBLNR_309
           MBLNR_Z31   = PR_LIST->MBLNR_Z31
           MBLNR_Z41   = PR_LIST->MBLNR_Z41
           MBLNR_309_C = PR_LIST->MBLNR_309_C
           MBLNR_Z31_C = PR_LIST->MBLNR_Z31_C
           MBLNR_Z41_C = PR_LIST->MBLNR_Z41_C
           CHDAT       = GS_ZGTPPS1001-CHDAT
           CHTIM       = GS_ZGTPPS1001-CHTIM
           CHNAM       = GS_ZGTPPS1001-CHNAM
     WHERE SCPNR EQ PR_LIST->SCPNR.

    COMMIT WORK AND WAIT.
  ENDIF.

  PR_LIST->STATUS = ICON_LED_RED.
  CLEAR PR_LIST->SCPNR.
  GS_RESULT-ERROR += 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form value_request_indept
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM VALUE_REQUEST_INDEPT  USING PV_INDEPT.

  DATA LV_USER_RESET TYPE C.
  DATA LT_RETURN TYPE TABLE OF DDSHRETVAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VALUE'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = TEXT-T21
      VALUE_ORG       = 'S'
    IMPORTING
      USER_RESET      = LV_USER_RESET
    TABLES
      VALUE_TAB       = GT_INDEPT[]
      RETURN_TAB      = LT_RETURN[]
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  CHECK SY-SUBRC IS INITIAL AND LT_RETURN[] IS NOT INITIAL.

  PV_INDEPT = VALUE #( LT_RETURN[ 1 ]-FIELDVAL OPTIONAL ) .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form value_request_arbpl
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM VALUE_REQUEST_ARBPL  USING PV_ARBPL.
  DATA LV_USER_RESET TYPE C.
  DATA LT_RETURN TYPE TABLE OF DDSHRETVAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ARBPL'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = TEXT-T22
      VALUE_ORG       = 'S'
    IMPORTING
      USER_RESET      = LV_USER_RESET
    TABLES
      VALUE_TAB       = GT_CRHD[]
      RETURN_TAB      = LT_RETURN[]
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  CHECK SY-SUBRC IS INITIAL AND LT_RETURN[] IS NOT INITIAL.

  PV_ARBPL = VALUE #( LT_RETURN[ 1 ]-FIELDVAL OPTIONAL ) .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form value_request_opcod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM VALUE_REQUEST_OPCOD  USING PV_OPCOD.

  DATA LV_USER_RESET TYPE C.
  DATA LT_RETURN TYPE TABLE OF DDSHRETVAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VALUE'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = TEXT-T23
      VALUE_ORG       = 'S'
    IMPORTING
      USER_RESET      = LV_USER_RESET
    TABLES
      VALUE_TAB       = GT_OPCOD[]
      RETURN_TAB      = LT_RETURN[]
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  CHECK SY-SUBRC IS INITIAL AND LT_RETURN[] IS NOT INITIAL.

  PV_OPCOD = VALUE #( LT_RETURN[ 1 ]-FIELDVAL OPTIONAL ) .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form value_request_scrsn
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM VALUE_REQUEST_SCRSN  USING PV_SCRSN.

  DATA LV_USER_RESET TYPE C.
  DATA LT_RETURN TYPE TABLE OF DDSHRETVAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VALUE'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      WINDOW_TITLE    = TEXT-T24
      VALUE_ORG       = 'S'
    IMPORTING
      USER_RESET      = LV_USER_RESET
    TABLES
      VALUE_TAB       = GT_SCPREASON[]
      RETURN_TAB      = LT_RETURN[]
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  CHECK SY-SUBRC IS INITIAL AND LT_RETURN[] IS NOT INITIAL.

  PV_SCRSN = VALUE #( LT_RETURN[ 1 ]-FIELDVAL OPTIONAL ) .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_fc01
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_FC01 .

  CALL FUNCTION 'ZGTPP_UTILL_VIEW'
    EXPORTING
      IV_TABNAME = GC_TABLE-ZGTPPT4140
      IV_TITLE   = TEXT-T20.

*  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
*    EXPORTING
*      action                       = 'S'
*      view_name                    = 'ZGTPPV4140'
*    EXCEPTIONS
*      client_reference             = 1
*      foreign_lock                 = 2
*      invalid_action               = 3
*      no_clientindependent_auth    = 4
*      no_database_function         = 5
*      no_editor_function           = 6
*      no_show_auth                 = 7
*      no_tvdir_entry               = 8
*      no_upd_auth                  = 9
*      only_show_allowed            = 10
*      system_failure               = 11
*      unknown_field_in_dba_sellist = 12
*      view_not_found               = 13
*      maintenance_prohibited       = 14
*      OTHERS                       = 15.
*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_weighing_of_selected_scpnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_WEIGHING_OF_SELECTED_SCPNR USING PV_DISPLAY.
  DATA LT_SCPNR TYPE RANGE OF ZGTPPT4120-SCPNR.

  CLEAR GT_WEIGHING.

  IF GT_LIST IS NOT INITIAL.
    TRY.
        DATA(LR_LIST) = REF #( GT_LIST[ CLICKED = ABAP_TRUE ] ).
        LT_SCPNR = VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = LR_LIST->SCPNR ) ).

      CATCH CX_SY_ITAB_LINE_NOT_FOUND.
        LOOP AT GT_LIST REFERENCE INTO LR_LIST
                        WHERE SCPNR IS NOT INITIAL.
          LR_LIST->CLICKED = ABAP_TRUE.
          LT_SCPNR = VALUE #( BASE LT_SCPNR  SIGN = 'I' OPTION = 'EQ' ( LOW = LR_LIST->SCPNR ) ).

          IF PV_DISPLAY EQ GC_DISPLAY-SINGLE.
            EXIT.
          ENDIF.
        ENDLOOP.
    ENDTRY.
  ENDIF.

  CHECK LT_SCPNR IS NOT INITIAL.

  SELECT ZT02~*,
         ZT01~INDEPT_DDLB,
         ZT01~CS_ARBPL,
         ZT01~SCGRP_DDLB,
         MAKT1~MAKTX AS MAKTX1,
         MAKT2~MAKTX AS MAKTX2,
         MAKT3~MAKTX AS MAKTX3,
         MAKT4~MAKTX AS MAKTX4
    FROM @GT_LIST   AS ZT01
    JOIN ZGTPPT4120 AS ZT02
      ON ZT01~SCPNR EQ ZT02~SCPNR
    LEFT JOIN MAKT AS MAKT1
      ON ZT02~MATNR_T1 EQ MAKT1~MATNR
     AND MAKT1~SPRAS   EQ @SY-LANGU
    LEFT JOIN MAKT AS MAKT2
      ON ZT02~MATNR_T2 EQ MAKT2~MATNR
     AND MAKT2~SPRAS   EQ @SY-LANGU
    LEFT JOIN MAKT AS MAKT3
      ON ZT02~MATNR_T3 EQ MAKT3~MATNR
     AND MAKT3~SPRAS   EQ @SY-LANGU
    LEFT JOIN MAKT AS MAKT4
      ON ZT02~MATNR_T4 EQ MAKT4~MATNR
     AND MAKT4~SPRAS   EQ @SY-LANGU
   WHERE ZT01~SCPNR IN @LT_SCPNR
   ORDER BY ZT02~SCPNR, ZT01~SCGRP_DDLB
    INTO CORRESPONDING FIELDS OF TABLE @GT_WEIGHING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_zgtppt4130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM UPDATE_ZGTPPT4130  USING PT_ZGTPPT4130 TYPE TY_T_ZGTPPT4130.

  CHECK PT_ZGTPPT4130 IS NOT INITIAL.

  MODIFY ZGTPPT4130 FROM TABLE PT_ZGTPPT4130.

  COMMIT WORK AND WAIT.

*  DATA lt_zgtppt4130 TYPE TABLE OF zgtppt4130.
*  DATA lt_gong_cd TYPE RANGE OF zgtppt4140-gong_cd.
*  DATA lt_cs_arbpl TYPE RANGE OF zgtppt4140-cs_arbpl.
*  DATA lv_lmnga TYPE afru-lmnga.
*  DATA lv_scpqt TYPE zgtppt4130-scpqt.
*
*  DATA(lv_from) = cl_reca_date=>set_to_begin_of_month( ps_list-scpdat ).
*
*  IF ps_list-cs_arbpl EQ gc_cs_arbpl-dcm. "// DCM 일 경우.
*    SELECT zt01~werks,
*           @ps_list-cs_arbpl AS cs_arbpl,
*           zt01~arbpl,
*           SUM( zt01~lmnga ) AS lmnga
*      FROM @gt_afru AS zt01
*     WHERE zt01~werks   EQ @ps_list-werks
*       AND zt01~budat   BETWEEN @lv_from AND @ps_list-scpdat
*       AND zt01~qlength GT 0
*     GROUP BY werks, arbpl
*      INTO TABLE @DATA(lt_summary).
*  ELSE.
*    lt_gong_cd  = COND #( WHEN ps_list-opcod IS NOT INITIAL THEN VALUE #( ( sign = 'I' option = 'EQ' low = ps_list-opcod ) ) ).
*    lt_cs_arbpl = COND #( WHEN ps_list-cs_arbpl IS NOT INITIAL THEN VALUE #( ( sign = 'I' option = 'EQ' low = ps_list-cs_arbpl ) ) ).
*
*    WITH +t4140 AS ( SELECT zt01~werks, gong_cd, cs_arbpl, arbpl
*                       FROM zgtppt4140 AS zt01
*                      WHERE zt01~werks    EQ @ps_list-werks
*                        AND zt01~gong_cd  IN @lt_gong_cd
*                        AND zt01~cs_arbpl IN @lt_cs_arbpl ),
*
*          +afru AS ( SELECT zt01~werks, zt01~arbpl, SUM( zt01~lmnga ) AS lmnga
*                      FROM @gt_afru AS zt01
*                     WHERE zt01~werks EQ @ps_list-werks
*                       AND zt01~arbpl IN ( SELECT arbpl FROM +t4140 WHERE werks EQ @ps_list-werks )
*                       AND zt01~budat BETWEEN @lv_from AND @ps_list-scpdat
*                     GROUP BY werks, arbpl )
*
*    SELECT zt01~werks, zt01~cs_arbpl, zt01~arbpl, zt02~lmnga
*      FROM +t4140 AS zt01
*      LEFT JOIN +afru AS zt02
*        ON zt01~werks EQ zt02~werks
*       AND zt01~arbpl EQ zt02~arbpl
*      INTO TABLE @lt_summary.
*  ENDIF.
*
*  LOOP AT lt_summary  INTO DATA(ls_summary).
*    APPEND INITIAL LINE TO lt_zgtppt4130 REFERENCE INTO DATA(lr_zgtppt4130).
*    lr_zgtppt4130->* = CORRESPONDING #( ps_list ).
*    lr_zgtppt4130->* = CORRESPONDING #( BASE ( lr_zgtppt4130->* ) gs_zgtpps1001 ).
*
*    lr_zgtppt4130->opcod = COND #( WHEN ls_summary-arbpl IS NOT INITIAL THEN ls_summary-arbpl+0(3) ).
*    lr_zgtppt4130->arbpl = ls_summary-arbpl.
*    lr_zgtppt4130->scpqt = ls_summary-lmnga.
*    lv_lmnga = lv_lmnga + ls_summary-lmnga.
*  ENDLOOP.
*
*  LOOP AT lt_zgtppt4130 REFERENCE INTO lr_zgtppt4130.
*    IF lv_lmnga IS NOT INITIAL.
*      lr_zgtppt4130->scpqt = ps_list-scpqt * lr_zgtppt4130->scpqt / lv_lmnga.
*    ENDIF.
*    lv_scpqt = lv_scpqt + lr_zgtppt4130->scpqt.
*  ENDLOOP.
*
*  IF lr_zgtppt4130 IS BOUND.
*    IF lv_scpqt NE ps_list-scpqt.
*      lr_zgtppt4130->scpqt = lr_zgtppt4130->scpqt + ( ps_list-scpqt - lv_scpqt ).
*    ENDIF.
*  ENDIF.

*  CHECK lt_zgtppt4130 IS NOT INITIAL.
*
*  MODIFY zgtppt4130 FROM TABLE lt_zgtppt4130.
*
*  COMMIT WORK AND WAIT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form summary_conf_prod_qty_by_wc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SUMMARY_CONF_PROD_QTY_BY_WC .

  DATA LV_MIN TYPE D.
  DATA LV_MAX TYPE D.

  SELECT MIN( SCPDAT ), MAX( SCPDAT )
    FROM @GT_LIST AS ZT01
   WHERE ZT01~SEL EQ @ABAP_TRUE
    INTO (@LV_MIN, @LV_MAX).

  LV_MIN = LV_MIN+0(6) && '01'.

  SELECT CRHD~WERKS, CRHD~ARBPL, AFRU~BUDAT, SUM( AFRU~LMNGA ) AS LMNGA, SUM( QLENGTH ) AS QLENGTH
    INTO CORRESPONDING FIELDS OF TABLE @GT_AFRU
    FROM AFRU
    JOIN CRHD
      ON AFRU~ARBID EQ CRHD~OBJID
     AND AFRU~WERKS EQ CRHD~WERKS
     AND CRHD~OBJTY EQ @ZGTPP_IF_CONST=>GC_OBJTY
    JOIN ZGTCVORDSYVAL AS ZT01
      ON AFRU~AUFNR EQ ZT01~AUFNR
   WHERE AFRU~WERKS EQ @P_WERKS
     AND AFRU~BUDAT BETWEEN @LV_MIN AND @LV_MAX
     AND AFRU~GRUND EQ @SPACE
     AND AFRU~STOKZ EQ @SPACE
     AND AFRU~STZHL EQ 0
   GROUP BY CRHD~WERKS, CRHD~ARBPL, AFRU~BUDAT
  HAVING SUM( AFRU~LMNGA ) GT 0
   ORDER BY CRHD~WERKS, CRHD~ARBPL, AFRU~BUDAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_detail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_DETAIL .

  PERFORM GET_DETAIL_DATA.

  IF GT_DETAIL IS INITIAL.
    MESSAGE I000 WITH TEXT-E08.
    RETURN.
  ENDIF.

  DATA(LV_CNT) = COND #( WHEN LINES( GT_DETAIL ) LE 12 THEN 2
                                                       ELSE 4 ).

  DATA(LV_WIDTH) = COND #( WHEN P_WERKS EQ GC_WERKS-6500 THEN 200 ).

  GR_DETAIL = NEW ZGTPP_CL_LIST( ).
  GR_DETAIL->DISPLAY( EXPORTING IR_CONTAINER = NEW CL_GUI_DIALOGBOX_CONTAINER( TOP      = 50
                                                                               LEFT     = 120
                                                                               WIDTH    = ( 1300 + LV_WIDTH )
                                                                               HEIGHT   = ( 50 + 50 * LV_CNT )
                                                                               LIFETIME = CL_GUI_CONTROL=>LIFETIME_IMODE
                                                                               CAPTION  = TEXT-P03 )
                                IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                      CHANGING  CT_DATA      = GT_DETAIL ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_close
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM POPUP_CLOSE .

  IF GR_DETAIL IS BOUND.
    GR_DETAIL->FREE( ).
    CLEAR GR_DETAIL.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_detail_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_DETAIL_DATA .
  DATA LT_SCPNR TYPE RANGE OF ZGTPPT4110-SCPNR.

  CLEAR GT_DETAIL.

  GR_LIST->MR_GRID->GET_SELECTED_ROWS( IMPORTING ET_INDEX_ROWS = DATA(LT_ROWS) ).
  DELETE LT_ROWS WHERE ROWTYPE NE SPACE.

  IF LT_ROWS IS INITIAL.
    SELECT 'I'  AS SIGN,
           'EQ' AS OPTION,
            ZT01~SCPNR AS LOW
      FROM @GT_LIST AS ZT01
     WHERE ZT01~SCPNR NE @SPACE
      INTO CORRESPONDING FIELDS OF TABLE @LT_SCPNR.
  ELSE.
    LOOP AT LT_ROWS INTO DATA(LS_ROW).
      READ TABLE GT_LIST INTO DATA(LS_LIST) INDEX LS_ROW-INDEX.

      CHECK SY-SUBRC IS INITIAL AND LS_LIST-SCPNR IS NOT INITIAL.

      APPEND INITIAL LINE TO LT_SCPNR REFERENCE INTO DATA(LR_SCPNR).
      LR_SCPNR->* = VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LS_LIST-SCPNR ).
    ENDLOOP.
  ENDIF.

  CHECK LT_SCPNR IS NOT INITIAL.

  SELECT ZT01~*,
         M_CRAMN~KTEXT
    FROM ZGTPPT4130 AS ZT01
    LEFT JOIN M_CRAMN
      ON ZT01~WERKS EQ M_CRAMN~WERKS
     AND ZT01~ARBPL EQ M_CRAMN~ARBPL
   WHERE ZT01~SCPNR IN @LT_SCPNR
     AND ZT01~LKENZ EQ @SPACE
   ORDER BY ZT01~SCPNR, ZT01~WERKS, ZT01~SPGCD, ZT01~CS_ARBPL, ZT01~ARBPL
    INTO CORRESPONDING FIELDS OF TABLE @GT_DETAIL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_detail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM MODIFY_FCAT_IN_DETAIL .

  LOOP AT GR_DETAIL->MT_FCAT REFERENCE INTO DATA(LR_FCAT).
    LR_FCAT->COL_OPT = 'A'.

    CASE LR_FCAT->FIELDNAME.
      WHEN 'SCPNR'.
        LR_FCAT->COLTEXT    = TEXT-F16.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C500'.

      WHEN 'WERKS'.
        LR_FCAT->COLTEXT    = TEXT-F01.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'SPGCD'.
        LR_FCAT->COLTEXT    = TEXT-F02.
        LR_FCAT->JUST       = 'C'.
        LR_FCAT->EMPHASIZE  = 'C410'.

      WHEN 'CS_ARBPL'.
        LR_FCAT->COLTEXT    = TEXT-F05.
        LR_FCAT->TECH       = COND #( WHEN P_WERKS EQ GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'ARBPL'.
        LR_FCAT->COLTEXT    = TEXT-F51.
        LR_FCAT->TECH       = COND #( WHEN P_WERKS EQ GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'KTEXT'.
        LR_FCAT->COLTEXT    = TEXT-F52.
        LR_FCAT->TECH       = COND #( WHEN P_WERKS EQ GC_WERKS-6600 THEN ABAP_TRUE ).

      WHEN 'OPCOD'.
        LR_FCAT->COLTEXT    = TEXT-F06.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MATNR'.
        LR_FCAT->COLTEXT    = TEXT-F14.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MAKTX'.
        LR_FCAT->COLTEXT    = TEXT-F15.

      WHEN 'WERKS_M'.
        LR_FCAT->COLTEXT    = TEXT-F21.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'LGORT_M'.
        LR_FCAT->COLTEXT    = TEXT-F22.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MATNR_M'.
        LR_FCAT->COLTEXT    = TEXT-F09.
        LR_FCAT->MARK       = ABAP_TRUE.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'MAKTX_M'.
        LR_FCAT->COLTEXT    = TEXT-F10.
        LR_FCAT->EMPHASIZE  = 'C300'.
        LR_FCAT->JUST       = 'C'.

      WHEN 'SCPQT'.
        LR_FCAT->COLTEXT    = TEXT-F11.
        LR_FCAT->NO_ZERO    = ABAP_TRUE.
        LR_FCAT->DO_SUM     = ABAP_TRUE.

      WHEN 'MEINS'.
        LR_FCAT->COLTEXT    = TEXT-F53.
        LR_FCAT->JUST       = 'C'.

      WHEN OTHERS.
        LR_FCAT->TECH = ABAP_TRUE.
    ENDCASE.

    LR_FCAT->TOOLTIP = LR_FCAT->REPTEXT = LR_FCAT->COLTEXT.
    LR_FCAT->SCRTEXT_S = LR_FCAT->SCRTEXT_M = LR_FCAT->SCRTEXT_L = LR_FCAT->COLTEXT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_sort
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM HANDLE_SORT  USING PR_SENDER.

  IF PR_SENDER EQ GR_DETAIL.
    PERFORM SET_SORT_IN_DETAIL.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort_in_detail
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_SORT_IN_DETAIL .

  GR_DETAIL->MT_SORT = VALUE #( ( SPOS = 1  FIELDNAME = 'SCPNR'  UP = ABAP_TRUE  SUBTOT = ABAP_TRUE ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_DISPLAY .

  MODIFY GT_LIST FROM VALUE #( CLICKED = ABAP_FALSE ) TRANSPORTING CLICKED
                 WHERE CLICKED EQ ABAP_TRUE.

  PERFORM GET_WEIGHING_OF_SELECTED_SCPNR USING GC_DISPLAY-ALL.

  GR_WEIGHING->REFRESH( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_fixed_col
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM USER_COMMAND_FIXED_COL .

  IF GR_WEIGHING IS BOUND.
    GR_WEIGHING->MR_GRID->GET_FRONTEND_FIELDCATALOG( IMPORTING ET_FIELDCATALOG = DATA(LT_FCAT) ).

    MODIFY LT_FCAT FROM VALUE #( FIX_COLUMN = ABAP_TRUE )
                   TRANSPORTING FIX_COLUMN
                   WHERE FIELDNAME EQ 'SCPNR'
                      OR FIELDNAME EQ 'INDEPT_DDLB'
                      OR FIELDNAME EQ 'CS_ARBPL'
                      OR FIELDNAME EQ 'SCGRP_DDLB'
                      OR FIELDNAME EQ 'MATNR_M'
                      OR FIELDNAME EQ 'MAKTX_M'.

    GR_WEIGHING->MR_GRID->SET_FRONTEND_FIELDCATALOG( LT_FCAT ).
    GR_WEIGHING->REFRESH( ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_scrap_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM BUILD_SCRAP_DATA  USING PS_LIST  TYPE TY_S_LIST
                             PT_SCRAP TYPE TY_T_SCRAP
                             PT_ZGTPPT4130 TYPE TY_T_ZGTPPT4130.

  CLEAR: PT_SCRAP, PT_ZGTPPT4130.

  CASE PS_LIST-WERKS.
    WHEN GC_WERKS-6500. "// 군포.
      PERFORM BUILD_SCRAP_DATA_6500 USING PS_LIST PT_SCRAP PT_ZGTPPT4130.

    WHEN GC_WERKS-6600. "// 전주.
      PERFORM BUILD_SCRAP_DATA_6600 USING PS_LIST PT_SCRAP PT_ZGTPPT4130.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_scrap_data_6500
*&---------------------------------------------------------------------*
*& 군포 플랜트 => 작업장 기준으로 배부.
*&---------------------------------------------------------------------*
FORM BUILD_SCRAP_DATA_6500  USING PS_LIST  TYPE TY_S_LIST
                                  PT_SCRAP TYPE TY_T_SCRAP
                                  PT_ZGTPPT4130 TYPE TY_T_ZGTPPT4130.
  TYPES: BEGIN OF TY_S_SUM,
           MATKL TYPE ZGTPPT1140-MATKL,    "// 자재그룹
           MENGE TYPE ZGTPPT4130-SCPQT,    "// 수량
         END OF TY_S_SUM.

  DATA LT_ZGTPPT4130 TYPE TY_T_ZGTPPT4130.
  DATA LT_ARBPL TYPE RANGE OF ZGTPPT4140-ARBPL.
  DATA LT_MATKL TYPE RANGE OF ZGTPPT1140-MATKL.
  DATA LT_SUM  TYPE TABLE OF TY_S_SUM.
  DATA LV_TOTAL TYPE AFRU-LMNGA.
  DATA LV_LMNGA TYPE AFRU-LMNGA.
  DATA LV_SCPQT TYPE ZGTPPT4130-SCPQT.
  DATA LV_MENGE TYPE ZGTPPT4130-SCPQT.
  DATA LV_MENGE2 TYPE ZGTPPT4130-SCPQT.

*// CS설비 작업장.
  LOOP AT GT_ZGTPPT4140 INTO DATA(LS_ZGTPPT4140)
                       WHERE WERKS    EQ PS_LIST-WERKS
                         AND CS_ARBPL EQ PS_LIST-CS_ARBPL.
    APPEND VALUE #( SIGN = 'I' OPTION = 'CP' LOW = |*{ LS_ZGTPPT4140-ARBPL+0(3) }{ PS_LIST-CNMAT }*| ) TO LT_MATKL.
    APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = LS_ZGTPPT4140-ARBPL ) TO LT_ARBPL.
  ENDLOOP.

*// 자재그룹에 대한 생산/물자 스크랩.
  LOOP AT GT_ZGTPPT1140 INTO DATA(LS_ZGTPPT1140)
                       WHERE WERKS    EQ PS_LIST-WERKS
                         AND SPGCD    EQ PS_LIST-SPGCD
                         AND MATKL    IN LT_MATKL.
    APPEND INITIAL LINE TO PT_SCRAP REFERENCE INTO DATA(LR_SCRAP).
    LR_SCRAP->* = CORRESPONDING #( LS_ZGTPPT1140 ).
    LR_SCRAP->SCPQT = PS_LIST-SCPQT.
    LR_SCRAP->MEINS = PS_LIST-MEINS.
  ENDLOOP.

  SORT PT_SCRAP BY MATNR WERKS_M LGORT_M MATNR_M.
  DELETE ADJACENT DUPLICATES FROM PT_SCRAP COMPARING MATNR WERKS_M LGORT_M MATNR_M.

*// 생산실적.
  DATA(LV_FROM) = CL_RECA_DATE=>SET_TO_BEGIN_OF_MONTH( PS_LIST-SCPDAT ).

  IF PS_LIST-CS_ARBPL EQ GC_CS_ARBPL-DCM.  "// DCM 일 경우.
    SELECT ZT01~WERKS,
           @PS_LIST-CS_ARBPL AS CS_ARBPL,
           ZT01~ARBPL,
           CONCAT( SUBSTRING( ZT01~ARBPL,1,3 ), @PS_LIST-CNMAT ) AS MATKL,
           SUM( ZT01~LMNGA ) AS LMNGA
      FROM @GT_AFRU AS ZT01
     WHERE ZT01~WERKS   EQ @PS_LIST-WERKS
       AND ZT01~BUDAT   BETWEEN @LV_FROM AND @PS_LIST-SCPDAT   "// 전기일.
       AND ZT01~QLENGTH GT 0                                   "// 검사여장.
     GROUP BY WERKS, ARBPL
      INTO TABLE @DATA(LT_SUMMARY).
  ELSEIF PS_LIST-CS_ARBPL+0(3) EQ GC_CS_ARBPL-PCT. "// PCT 일 경우
    SELECT ZT01~WERKS,
        @PS_LIST-CS_ARBPL AS CS_ARBPL,
        ZT01~ARBPL,
        CONCAT( SUBSTRING( ZT01~ARBPL,1,3 ), @PS_LIST-CNMAT ) AS MATKL,
        SUM( ZT01~LMNGA ) AS LMNGA
   FROM @GT_AFRU AS ZT01
  WHERE ZT01~WERKS   EQ @PS_LIST-WERKS
    AND ZT01~BUDAT   BETWEEN @LV_FROM AND @PS_LIST-SCPDAT   "// 전기일.
    AND ZT01~ARBPL   LIKE 'SHE%'
  GROUP BY WERKS, ARBPL
   INTO TABLE @LT_SUMMARY.
  ELSEIF PS_LIST-CS_ARBPL EQ GC_CS_ARBPL-ETCPM.  "// ETCPM 일 경우.
    SELECT ZT01~WERKS,
           @PS_LIST-CS_ARBPL AS CS_ARBPL,
           ZT01~ARBPL,
           CONCAT( SUBSTRING( ZT01~ARBPL,1,3 ), @PS_LIST-CNMAT ) AS MATKL,
           SUM( ZT01~LMNGA ) AS LMNGA
      FROM @GT_AFRU AS ZT01
     WHERE ZT01~WERKS   EQ @PS_LIST-WERKS
       AND ZT01~BUDAT   BETWEEN @LV_FROM AND @PS_LIST-SCPDAT   "// 전기일.
     GROUP BY WERKS, ARBPL
      INTO TABLE @LT_SUMMARY.
  ELSE.
    WITH +T4140 AS ( SELECT ZT01~WERKS, GONG_CD, CS_ARBPL, ARBPL
                       FROM ZGTPPT4140 AS ZT01
                      WHERE ZT01~WERKS    EQ @PS_LIST-WERKS
                        AND ZT01~CS_ARBPL EQ @PS_LIST-CS_ARBPL ),

         +AFRU AS ( SELECT ZT01~WERKS, ZT01~ARBPL, SUM( ZT01~LMNGA ) AS LMNGA
                      FROM @GT_AFRU AS ZT01
                     WHERE ZT01~WERKS EQ @PS_LIST-WERKS
                       AND ZT01~ARBPL IN @LT_ARBPL
                       AND ZT01~BUDAT BETWEEN @LV_FROM AND @PS_LIST-SCPDAT
                     GROUP BY WERKS, ARBPL )

    SELECT ZT01~WERKS, ZT01~CS_ARBPL, ZT01~ARBPL,
           CONCAT( SUBSTRING( ZT01~ARBPL,1,3 ), @PS_LIST-CNMAT ) AS MATKL,
           ZT02~LMNGA
      FROM +T4140 AS ZT01
      LEFT JOIN +AFRU AS ZT02
        ON ZT01~WERKS EQ ZT02~WERKS
       AND ZT01~ARBPL EQ ZT02~ARBPL
     WHERE ZT01~WERKS    EQ @PS_LIST-WERKS
       AND ZT01~CS_ARBPL EQ @PS_LIST-CS_ARBPL
      INTO TABLE @LT_SUMMARY.
  ENDIF.

*// 생산/물자 스크랩별 수량 배분.
  LOOP AT PT_SCRAP REFERENCE INTO LR_SCRAP.
    LOOP AT LT_SUMMARY REFERENCE INTO DATA(LR_SUMMARY).
      CHECK LR_SCRAP->MATKL CS LR_SUMMARY->MATKL.

      COLLECT VALUE TY_S_SUM( MATKL = LR_SUMMARY->MATKL
                              MENGE = LR_SUMMARY->LMNGA ) INTO LT_SUM.

      LV_TOTAL = LV_TOTAL + LR_SUMMARY->LMNGA.
    ENDLOOP.
  ENDLOOP.

  LOOP AT PT_SCRAP REFERENCE INTO LR_SCRAP.
    LOOP AT LT_SUM INTO DATA(LS_SUM).
      CHECK LR_SCRAP->MATKL CS LS_SUM-MATKL.

      IF LV_TOTAL IS NOT INITIAL.
        LR_SCRAP->MENGE = LR_SCRAP->SCPQT * LS_SUM-MENGE / LV_TOTAL.
      ENDIF.
    ENDLOOP.

    LV_MENGE = LV_MENGE + LR_SCRAP->MENGE.
  ENDLOOP.

  IF LR_SCRAP IS BOUND AND LV_MENGE NE LR_SCRAP->SCPQT.
    LR_SCRAP->MENGE = LR_SCRAP->MENGE + ( LR_SCRAP->SCPQT - LV_MENGE ).
  ENDIF.

*// 작업장별 수량 배분.
  LOOP AT PT_SCRAP REFERENCE INTO LR_SCRAP.
    CLEAR: LT_ZGTPPT4130, LV_MENGE, LV_LMNGA.

    LOOP AT LT_SUMMARY INTO DATA(LS_SUMMARY).
      CHECK LR_SCRAP->MATKL CS LS_SUMMARY-MATKL.

      APPEND INITIAL LINE TO LT_ZGTPPT4130 REFERENCE INTO DATA(LR_ZGTPPT4130).
      LR_ZGTPPT4130->* = CORRESPONDING #( LR_SCRAP->* ).
      LR_ZGTPPT4130->* = CORRESPONDING #( BASE ( LR_ZGTPPT4130->* ) GS_ZGTPPS1001 ).
      LR_ZGTPPT4130->ARBPL    = LS_SUMMARY-ARBPL.
      LR_ZGTPPT4130->SCPQT    = LS_SUMMARY-LMNGA.
      LR_ZGTPPT4130->SCPNR    = PS_LIST-SCPNR.
      LR_ZGTPPT4130->CS_ARBPL = PS_LIST-CS_ARBPL.
      LR_ZGTPPT4130->SCGRP    = PS_LIST-SCGRP.
      LR_ZGTPPT4130->OPCOD    = PS_LIST-OPCOD.
      LR_ZGTPPT4130->SCPDAT   = PS_LIST-SCPDAT.
      LV_LMNGA = LV_LMNGA + LS_SUMMARY-LMNGA.
    ENDLOOP.

    LOOP AT LT_ZGTPPT4130 REFERENCE INTO LR_ZGTPPT4130.
      IF LV_LMNGA IS NOT INITIAL.
        LR_ZGTPPT4130->SCPQT = LR_SCRAP->MENGE * LR_ZGTPPT4130->SCPQT / LV_LMNGA.
      ENDIF.

      LV_MENGE = LV_MENGE + LR_ZGTPPT4130->SCPQT.
    ENDLOOP.

    IF LV_MENGE NE LR_SCRAP->MENGE.
      CLEAR LV_MENGE2.
      LV_MENGE2 = LR_SCRAP->MENGE - LV_MENGE.
      LOOP AT LT_ZGTPPT4130 ASSIGNING FIELD-SYMBOL(<LS_4130>).
        IF <LS_4130>-SCPQT = 0.
          CONTINUE.
        ENDIF.

        IF <LS_4130>-SCPQT > LV_MENGE2.
          <LS_4130>-SCPQT = <LS_4130>-SCPQT + LV_MENGE2.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

*    IF LR_ZGTPPT4130 IS BOUND.
*      IF LV_MENGE NE LR_SCRAP->MENGE.
*        LR_ZGTPPT4130->SCPQT = LR_ZGTPPT4130->SCPQT + ( LR_SCRAP->MENGE - LV_MENGE ).
*      ENDIF.
*    ENDIF.

    APPEND LINES OF LT_ZGTPPT4130 TO PT_ZGTPPT4130.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_scrap_data_6600
*&---------------------------------------------------------------------*
*& 전주 플랜트 => 공정 기준으로 배부.
*&---------------------------------------------------------------------*
FORM BUILD_SCRAP_DATA_6600  USING PS_LIST  TYPE TY_S_LIST
                                  PT_SCRAP TYPE TY_T_SCRAP
                                  PT_ZGTPPT4130 TYPE TY_T_ZGTPPT4130.
  DATA LV_LMNGA TYPE AFRU-LMNGA.
  DATA LV_SCPQT TYPE ZGTPPT4130-SCPQT.
  DATA LV_SCPQT2 TYPE ZGTPPT4130-SCPQT.

*// 스크랩코드에 대한 생산/물자 스크랩.
  APPEND INITIAL LINE TO PT_SCRAP REFERENCE INTO DATA(LR_SCRAP).
  LR_SCRAP->* = CORRESPONDING #( PS_LIST ).
  LR_SCRAP->MENGE = PS_LIST-SCPQT.

  IF PS_LIST-OPCOD NE GC_CS_ARBPL-DCM.  "// DCM이 아닌 경우.
    APPEND INITIAL LINE TO PT_ZGTPPT4130 REFERENCE INTO DATA(LR_ZGTPPT4130).
    LR_ZGTPPT4130->* = CORRESPONDING #( PS_LIST ).
    LR_ZGTPPT4130->* = CORRESPONDING #( BASE ( LR_ZGTPPT4130->* ) GS_ZGTPPS1001 ).
  ELSE.
    DATA(LV_FROM) = CL_RECA_DATE=>SET_TO_BEGIN_OF_MONTH( PS_LIST-SCPDAT ).

    SELECT ZT01~WERKS,
           SUBSTRING( ZT01~ARBPL,1,3 ) AS OPCOD,
           SUM( ZT01~LMNGA ) AS LMNGA
      FROM @GT_AFRU AS ZT01
     WHERE ZT01~WERKS   EQ @PS_LIST-WERKS
       AND ZT01~BUDAT   BETWEEN @LV_FROM AND @PS_LIST-SCPDAT  "// 전기일.
       AND ZT01~QLENGTH GT 0                                  "// 검사여장.
     GROUP BY WERKS, SUBSTRING( ZT01~ARBPL,1,3 )
      INTO TABLE @DATA(LT_SUMMARY).

    LOOP AT LT_SUMMARY INTO DATA(LS_SUMMARY).
      APPEND INITIAL LINE TO PT_ZGTPPT4130 REFERENCE INTO LR_ZGTPPT4130.
      LR_ZGTPPT4130->* = CORRESPONDING #( PS_LIST ).
      LR_ZGTPPT4130->* = CORRESPONDING #( BASE ( LR_ZGTPPT4130->* ) GS_ZGTPPS1001 ).

      LR_ZGTPPT4130->OPCOD = LS_SUMMARY-OPCOD.
      LR_ZGTPPT4130->SCPQT = LS_SUMMARY-LMNGA.
      LV_LMNGA = LV_LMNGA + LS_SUMMARY-LMNGA.
    ENDLOOP.

    LOOP AT PT_ZGTPPT4130 REFERENCE INTO LR_ZGTPPT4130.
      IF LV_LMNGA IS NOT INITIAL.
        LR_ZGTPPT4130->SCPQT = PS_LIST-SCPQT * LR_ZGTPPT4130->SCPQT / LV_LMNGA.
      ENDIF.
      LV_SCPQT = LV_SCPQT + LR_ZGTPPT4130->SCPQT.
    ENDLOOP.

    IF LV_SCPQT NE PS_LIST-SCPQT.
      CLEAR LV_SCPQT2.
      LV_SCPQT2 = PS_LIST-SCPQT - LV_SCPQT.
      LOOP AT PT_ZGTPPT4130 ASSIGNING FIELD-SYMBOL(<LS_4130>).
        IF <LS_4130>-SCPQT = 0.
          CONTINUE.
        ENDIF.

        IF <LS_4130>-SCPQT > LV_SCPQT2.
          <LS_4130>-SCPQT = <LS_4130>-SCPQT + LV_SCPQT2.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

*    IF LR_ZGTPPT4130 IS BOUND.
*      IF LV_SCPQT NE PS_LIST-SCPQT.
*        LR_ZGTPPT4130->SCPQT = LR_ZGTPPT4130->SCPQT + ( PS_LIST-SCPQT - LV_SCPQT ).
*      ENDIF.
*    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form NPP_GOODS_RECEIPT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LR_LIST_>*
*&---------------------------------------------------------------------*
FORM NPP_GOODS_RECEIPT  CHANGING   PS_LIST  TYPE TY_S_LIST
                           RAISING LCX_EXCEPTION.

  DATA LS_HEADRET TYPE BAPI2017_GM_HEAD_RET.
  DATA LT_ITEM    TYPE GM_ITEMS_T.
  DATA LT_RETURN  TYPE TABLE OF BAPIRET2.
  DATA LV_INDEX   TYPE NUMC1.
  DATA LS_ZGTPPT4120 TYPE ZGTPPT4120.
  DATA LV_FIELD   TYPE STRING.

  DATA(LR_ZGTPPT4120) = REF #( LS_ZGTPPT4120 ).

  CASE P_WERKS.
    WHEN '6500'.

      LR_ZGTPPT4120->* = VALUE #( SCPNR = PS_LIST-SCPNR
                                  SCPQT = PS_LIST-SCPQT
                                  MEINS = PS_LIST-MEINS ).

      LOOP AT GT_ZGTPPT1130  INTO DATA(LS_ZGTPPT1130)
                            USING KEY SKEY1
                            WHERE WERKS EQ PS_LIST-WERKS
                              AND SPGCD EQ PS_LIST-SPGCD
                              AND LGORT EQ PS_LIST-LGORT
                              AND SCGRP EQ PS_LIST-SCGRP.

*        READ TABLE gt_zgtppt1010 INTO DATA(ls_zgtppt1010) WITH KEY codegrp = gc_codegrp-4080
*                                                                   fld_01  = ls_zgtppt1130-werks
*                                                                   fld_02  = ls_zgtppt1130-spgcd BINARY SEARCH.

        IF CONTAINS( VAL = LS_ZGTPPT1130-MAKTX_T  SUB = 'CU' ).
          LV_INDEX = 1.
        ELSEIF CONTAINS( VAL = LS_ZGTPPT1130-MAKTX_T  SUB = 'PVC' ).
          LV_INDEX = 2.
        ELSEIF CONTAINS( VAL = LS_ZGTPPT1130-MAKTX_T  SUB = 'PE' ).
          LV_INDEX = 3.
        ELSEIF CONTAINS( VAL = LS_ZGTPPT1130-MAKTX_T  SUB = 'AL' ).
          LV_INDEX = 4.
        ELSE.
          CONTINUE.
        ENDIF.

        LV_FIELD = |MATNR_T{ LV_INDEX }|.
        LR_ZGTPPT4120->(LV_FIELD) = LS_ZGTPPT1130-MATNR_T.

        LV_FIELD = |SCRAT{ LV_INDEX }|.
        LR_ZGTPPT4120->(LV_FIELD) = LS_ZGTPPT1130-SCRAT.

        LV_FIELD = |MENGE{ LV_INDEX }|.
        LR_ZGTPPT4120->(LV_FIELD) = PS_LIST-SCPQT * LS_ZGTPPT1130-SCRAT / 100.

        APPEND INITIAL LINE TO LT_ITEM REFERENCE INTO DATA(LR_ITEM).
        LR_ITEM->* = VALUE #( MATERIAL   = CONV MATNR18( LS_ZGTPPT1130-MATNR_T )
                              PLANT      = P_WERKS
                              STGE_LOC   = '1900' "전력 물자 스크랩 저장위치
                              MOVE_TYPE  = 'Z21'
                              ENTRY_QNT  = ( PS_LIST-SCPQT * LS_ZGTPPT1130-SCRAT / 100 )
                              ENTRY_UOM  = PS_LIST-MEINS ).
      ENDLOOP.

    WHEN '6600'.

      READ TABLE GT_ZGTPPT1120 INTO DATA(LS_ZGTPPT1120) WITH KEY WERKS = PS_LIST-WERKS
                                                                 SPGCD = PS_LIST-SPGCD
                                                                 LGORT = PS_LIST-LGORT
                                                                 SCGRP = PS_LIST-SCGRP BINARY SEARCH.
      IF SY-SUBRC IS INITIAL.
*        READ TABLE gt_zgtppt1010 INTO ls_zgtppt1010 WITH KEY codegrp = gc_codegrp-4080
*                                                                   fld_01  = ls_zgtppt1120-werks_m
*                                                                   fld_02  = ls_zgtppt1120-spgcd BINARY SEARCH.

        PS_LIST-MATNR   = LS_ZGTPPT1120-MATNR.
        PS_LIST-WERKS_M = LS_ZGTPPT1120-WERKS_M.
        PS_LIST-LGORT_M = LS_ZGTPPT1120-LGORT_M.
        PS_LIST-MATNR_M = LS_ZGTPPT1120-MATNR_M.

        PERFORM GET_MATERIAL_DESC USING PS_LIST-MATNR   PS_LIST-MAKTX.
        PERFORM GET_MATERIAL_DESC USING PS_LIST-MATNR_M PS_LIST-MAKTX_M.
      ENDIF.


      APPEND INITIAL LINE TO LT_ITEM REFERENCE INTO LR_ITEM.
      LR_ITEM->* = VALUE #( MATERIAL   = CONV MATNR18( PS_LIST-MATNR_M )
                            PLANT      = PS_LIST-WERKS_M
                            STGE_LOC   = PS_LIST-LGORT_M
                            MOVE_TYPE  = 'Z21'
                            ENTRY_QNT  =  PS_LIST-SCPQT
                            ENTRY_UOM  = PS_LIST-MEINS ).

  ENDCASE.

*처리 실적이 없는 경우 validation
  IF LT_ITEM[] IS NOT INITIAL.
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = VALUE BAPI2017_GM_HEAD_01( PSTNG_DATE = PS_LIST-SCPDAT
                                                      DOC_DATE   = PS_LIST-SCPDAT
                                                      PR_UNAME   = SY-UNAME
                                                      HEADER_TXT = |{ TEXT-014 } { PS_LIST-SCPNR }| )
        GOODSMVT_CODE    = ZGTPP_IF_CONST=>GC_GM_CODE-OTHER_GR
      IMPORTING
        GOODSMVT_HEADRET = LS_HEADRET
      TABLES
        GOODSMVT_ITEM    = LT_ITEM
        RETURN           = LT_RETURN.

    IF LS_HEADRET IS NOT INITIAL.
      PS_LIST-MBLNR_Z41 = LS_HEADRET-MAT_DOC.
      PS_LIST-MJAHR     = LS_HEADRET-DOC_YEAR.

      INSERT INITIAL LINE INTO PS_LIST-MATDOC INDEX 1 REFERENCE INTO DATA(LR_MATDOC).
      LR_MATDOC->* = VALUE #( BASE CORRESPONDING #( LS_HEADRET ) BWART = 'Z21'
                                                                 BUDAT = PS_LIST-SCPDAT ).

      PERFORM UPDATE_PROCESSING_RESULT USING PS_LIST LS_ZGTPPT4120.
    ELSE.
      PS_LIST-MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
      RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH PS_LIST-MESSAGE.
    ENDIF.

  ELSE.
    "스크랩 폐기 처리할 자재코드 Mapping이 안되어 있습니다.
    PS_LIST-MESSAGE = TEXT-E21.
    RAISE EXCEPTION TYPE LCX_EXCEPTION MESSAGE E000 WITH PS_LIST-MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_309_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_309_CANCEL  USING P_TASKNAME.

  RECEIVE RESULTS FROM FUNCTION 'ZGTPP_BAPI_GOODSMVT_CANCEL'
     IMPORTING
       GOODSMVT_HEADRET    = GS_HEADRET1
     TABLES
       RETURN              = GT_RETURN1.

  GV_JOBS = '1'.

ENDFORM.
