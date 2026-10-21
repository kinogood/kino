*&---------------------------------------------------------------------*
*& Include          ZGTPPR4080F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  CLEAR: GT_1010.
  SELECT *
    FROM ZGTPPT1010
   WHERE MODULE_KIND EQ @GC_PP
     AND CODEGRP EQ @GC_4040
    INTO CORRESPONDING FIELDS OF TABLE @GT_1010.

  CLEAR: GT_4080.
  SELECT *
    FROM ZGTPPT4080
    INTO CORRESPONDING FIELDS OF TABLE @GT_4080.

  CLEAR: GT_DATA.
  LOOP AT GT_1010 INTO GS_1010.
    MOVE: GS_1010-FLD_01 TO GS_DATA-SEQ,
          GS_1010-FLD_02 TO GS_DATA-BTNNM,
          GS_1010-FLD_03 TO GS_DATA-TCODE.

    GS_DATA-SEQNO = GS_DATA-SEQ + 0.

    READ TABLE GT_4080 INTO GS_4080 WITH KEY TCODE = GS_DATA-TCODE.
    IF SY-SUBRC EQ 0.
      MOVE: GS_4080-CRDAT TO GS_DATA-CRDAT,
            GS_4080-CRTIM TO GS_DATA-CRTIM,
            GS_4080-CRNAM TO GS_DATA-CRNAM.

      SELECT SINGLE A~NAME_TEXT
        FROM ADRP AS A
        LEFT OUTER JOIN USR21 AS B ON B~PERSNUMBER EQ A~PERSNUMBER
       WHERE B~BNAME EQ @GS_4080-CRNAM
        INTO @GS_DATA-UNAME.
    ENDIF.

    GS_DATA-BTN = ICON_EXECUTE_OBJECT.

    APPEND GS_DATA TO GT_DATA.
    CLEAR: GS_DATA.
  ENDLOOP.

  SORT GT_DATA BY SEQNO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .
  CREATE OBJECT GO_DOCKING_CONTAINER
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

  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_DOCKING_CONTAINER
      I_APPL_EVENTS = ABAP_TRUE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .
  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-COL_OPT    = GC_X.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR4080TOP'
      I_INTERNAL_TABNAME     = 'GS_DATA'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_DATA
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'BTNNM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01.  "오브젝트
        <LS_FCAT>-JUST = GC_C.
      WHEN 'BTN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "실행
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-ICON = GC_X.
        <LS_FCAT>-OUTPUTLEN = '10'.
        <LS_FCAT>-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
      WHEN 'TCODE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "T-code
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CRDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "마지막 실행일
        <LS_FCAT>-JUST = GC_C.
      WHEN 'CRNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "마지막 실행자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'UNAME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "이름
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-OUTPUTLEN = '10'.
      WHEN 'CRTIM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "마지막 실행 시간
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

    CLEAR: <LS_FCAT>-KEY.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0100 .
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
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
                CL_GUI_ALV_GRID=>MC_FC_REFRESH,
                CL_GUI_ALV_GRID=>MC_FC_SORT,
                CL_GUI_ALV_GRID=>MC_FC_SORT_ASC,
                CL_GUI_ALV_GRID=>MC_FC_SORT_DSC.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_EXCLUDE_TOOLBAR_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_EXCLUDE_0100
*&      --> CL_GUI_ALV_GRID=>MC_FC_LOC_UND
*&---------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM SET_EVENT_GRID_0100  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
  IF GO_EVTR_0100 IS NOT BOUND.
    CREATE OBJECT GO_EVTR_0100.
  ENDIF.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      SET HANDLER: GO_EVTR_0100->HDL_BUTTON_CLICK FOR GO_GRID_0100.
  ENDCASE.

* DATA CHANGE
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .
  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
    CHANGING
      IT_OUTTAB            = GT_DATA
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REF_ALV_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REF_ALV_RTN  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.
  DATA LS_STABLE TYPE LVC_S_STBL.

  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0100.
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_STABLE
    EXCEPTIONS
      FINISHED       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTPPT4080
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS>
*&---------------------------------------------------------------------*
FORM SAVE_ZGTPPT4080  USING    P_LINE LIKE GS_DATA.

  DATA: LS_ZGTPPT4080 LIKE ZGTPPT4080.

  CLEAR: LS_ZGTPPT4080.
  LS_ZGTPPT4080-TCODE = P_LINE-TCODE.
  LS_ZGTPPT4080-CRDAT = SY-DATUM.
  LS_ZGTPPT4080-CRTIM = SY-UZEIT.
  LS_ZGTPPT4080-CRNAM = SY-UNAME.

  MODIFY ZGTPPT4080 FROM LS_ZGTPPT4080.

  P_LINE-CRDAT = SY-DATUM.
  P_LINE-CRTIM = SY-UZEIT.
  P_LINE-CRNAM = SY-UNAME.

  SELECT SINGLE A~NAME_TEXT
    FROM ADRP AS A
    LEFT OUTER JOIN USR21 AS B ON B~PERSNUMBER EQ A~PERSNUMBER
   WHERE B~BNAME EQ @P_LINE-CRNAM
    INTO @P_LINE-UNAME.

ENDFORM.
