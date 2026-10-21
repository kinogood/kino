*&---------------------------------------------------------------------*
*&  Include           ZPPR0021O01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  status_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET TITLEBAR  'T10'.

*[U01] 가온전선 추가
  REFRESH GT_PFSTATUS.         CLEAR GT_PFSTATUS.

  IF SY-TCODE EQ 'ZGTPPR3021G'.
    APPEND 'ZPPM0021'  TO GT_PFSTATUS.
    APPEND 'ZPPM0030'  TO GT_PFSTATUS.
    APPEND 'ZPPR0027'  TO GT_PFSTATUS.
    APPEND 'ZPPU0117'  TO GT_PFSTATUS.
    APPEND 'MPRINT'    TO GT_PFSTATUS.
    APPEND 'ZPPM0030M' TO GT_PFSTATUS.
    APPEND 'TECO'     TO GT_PFSTATUS.
    APPEND 'COOIS'     TO GT_PFSTATUS.
    APPEND 'INFO'     TO GT_PFSTATUS.
    APPEND 'BACKLOG'     TO GT_PFSTATUS.
    APPEND 'NOSEND'    TO GT_PFSTATUS.

    SET PF-STATUS 'PFS_0100' EXCLUDING GT_PFSTATUS.

  ELSEIF SY-TCODE EQ 'ZGTPPR3020G'.
    APPEND 'ZPPM0021'  TO GT_PFSTATUS.
    APPEND 'ZPPM0030'  TO GT_PFSTATUS.
    APPEND 'ZPPR0027'  TO GT_PFSTATUS.
    APPEND 'ZPPU0117'  TO GT_PFSTATUS.
    APPEND 'MPRINT'    TO GT_PFSTATUS.
    APPEND 'ZPPM0030M' TO GT_PFSTATUS.
    APPEND 'COOIS'     TO GT_PFSTATUS.
    APPEND 'NOSEND'    TO GT_PFSTATUS.
    APPEND 'DEL_ACTI'    TO GT_PFSTATUS.
    APPEND 'SET_ACTI' TO GT_PFSTATUS.  "[U01] 가온전선 추가
    APPEND 'NOSESET_ACTIND'    TO GT_PFSTATUS.
    APPEND 'TECO1' TO GT_PFSTATUS.     "[U03] 가온전선 추가

    SET PF-STATUS 'PFS_0100' EXCLUDING GT_PFSTATUS.

  ELSE.
*[U01] 가온전선 추가
    IF P_PWERK = '1201' OR
       P_PWERK = '1304'. " OR 권선

      APPEND 'REL'     TO GT_PFSTATUS.
      APPEND 'BACKLOG' TO GT_PFSTATUS.   "[U01] 가온전선 추가
      APPEND 'DEL_ACTI' TO GT_PFSTATUS.  "[U01] 가온전선 추가
      APPEND 'SET_ACTI' TO GT_PFSTATUS.  "[U01] 가온전선 추가
      APPEND 'TECO1' TO GT_PFSTATUS.     "[U03] 가온전선 추가

      SET PF-STATUS 'PFS_0100' EXCLUDING GT_PFSTATUS.
    ELSE.
      APPEND 'BACKLOG' TO GT_PFSTATUS.   "[U01] 가온전선 추가
      APPEND 'DEL_ACTI' TO GT_PFSTATUS.  "[U01] 가온전선 추가
      APPEND 'SET_ACTI' TO GT_PFSTATUS.  "[U01] 가온전선 추가
      APPEND 'TECO1' TO GT_PFSTATUS.     "[U03] 가온전선 추가

      SET PF-STATUS 'PFS_0100' EXCLUDING GT_PFSTATUS.
    ENDIF.
  ENDIF.  "[U01] 가온전선 추가
ENDMODULE.                 " status_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0900  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0900 OUTPUT.
  REFRESH GT_PFSTATUS.         CLEAR GT_PFSTATUS.

  APPEND 'SAVE'                   TO GT_PFSTATUS.

  SET TITLEBAR  'T90'.
  SET PF-STATUS 'PFS_0900' EXCLUDING GT_PFSTATUS.

ENDMODULE.                 " status_0900  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_text_control  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_TEXT_CONTROL OUTPUT.
* Create Control
  DATA: LS_TCO09            LIKE TCO09,
        LV_TEXTEDIT_WRAPPOS TYPE I.
  DATA: LV_REPID LIKE SY-REPID,
        LV_DYNNR LIKE SY-DYNNR.

* set linesize
  CALL FUNCTION 'CO_TA_TCO09_READ'
    EXPORTING
      AUTYP  = GT_AFKO-AUTYP
    IMPORTING
      STRUCT = LS_TCO09.

  LV_TEXTEDIT_WRAPPOS = LS_TCO09-LNSZE_ORD.
  IF  LV_TEXTEDIT_WRAPPOS >  CON_TEXTEDIT_MAXLINELENGTH OR
      LV_TEXTEDIT_WRAPPOS <= 0.
    LV_TEXTEDIT_WRAPPOS = CON_TEXTEDIT_MAXLINELENGTH.
  ENDIF.

* create textedit control
  LV_REPID = SY-REPID.
  LV_DYNNR = SY-DYNNR.
  IF GS_EDITOR IS INITIAL.
    CREATE OBJECT GS_EDITOR
      EXPORTING
        REPID            = LV_REPID
        DYNNR            = LV_DYNNR
        DYNPRO_CONTAINER = CON_TEXTEDIT_CONTAINER
      EXCEPTIONS
        OTHERS           = 1.
    IF SY-SUBRC NE 0.
      MESSAGE S888 WITH 'EDITOR_CREATE' SY-SUBRC.
    ENDIF.
  ENDIF.                               " Editor is initial

  IF LV_DYNNR <> GS_LINK_DYNNR.
    CALL METHOD GS_EDITOR->LINK_TO_SCREEN
      EXPORTING
        REPID            = LV_REPID
        DYNNR            = LV_DYNNR
        DYNPRO_CONTAINER = CON_TEXTEDIT_CONTAINER.
    GS_LINK_DYNNR = LV_DYNNR.
  ENDIF.

* set display mode
*&  IF gv_button = 'MENU'  OR
*&   ( gv_button = 'GRID' AND gt_afko-f_bdc = 'X' ).
*&    CALL METHOD gs_editor->set_readonly_mode
*&      EXPORTING
*&        readonly_mode = c_textedit_control=>false.
*&  ELSE.

  CALL METHOD GS_EDITOR->SET_READONLY_MODE
    EXPORTING
      READONLY_MODE = C_TEXTEDIT_CONTROL=>TRUE.

*&  ENDIF.

* set wordWrap behavior
  CALL METHOD GS_EDITOR->SET_WORDWRAP_BEHAVIOR
    EXPORTING
      WORDWRAP_MODE              = C_TEXTEDIT_CONTROL=>WORDWRAP_AT_FIXED_POSITION
      WORDWRAP_POSITION          = LV_TEXTEDIT_WRAPPOS
      WORDWRAP_TO_LINEBREAK_MODE = C_TEXTEDIT_CONTROL=>TRUE
    EXCEPTIONS
      OTHERS                     = 1.

* set cursor to text control
  CALL METHOD GS_EDITOR->SET_FOCUS_TO_CONTROL.

ENDMODULE.                 " init_text_control  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_control_text  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CONTROL_TEXT OUTPUT.
  DATA: LT_TLINES  LIKE TLINE OCCURS 0 WITH HEADER LINE,
        LT_SCH     LIKE THEAD-TDNAME,
        LS_TCO09WA LIKE TCO09.

  REFRESH: GT_TEXTEDIT_LINES, GT_TLINES, LT_TLINES.
  CLEAR  : GT_TEXTEDIT_LINES, GT_TLINES, LT_TLINES,
           GS_TEXTEDIT_HEADER.

* Objekt und ID der Texte auslesen
  CALL FUNCTION 'CO_TA_TCO09_READ'
    EXPORTING
      AUTYP    = GT_AFKO-AUTYP
    IMPORTING
      STRUCT   = LS_TCO09WA
    EXCEPTIONS
      NO_ENTRY = 1.

  CHECK SY-SUBRC = 0.

  CALL FUNCTION 'CO_ZK_TEXTKEY_CAUFV'
    EXPORTING
      AUFNR = GT_AFKO-AUFNR
    IMPORTING
      LTSCH = LT_SCH.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = LS_TCO09WA-IDORD
      LANGUAGE  = '3'             "한국어
      NAME      = LT_SCH
      OBJECT    = LS_TCO09WA-OBJEC
*&    importing
*&      header    = e_theader
    TABLES
      LINES     = LT_TLINES
    EXCEPTIONS
      NOT_FOUND = 01.

  IF LT_TLINES[] IS INITIAL.
*&    IF gt_afko-matnr IS INITIAL.
*&      APPEND i_caufvd-ktext TO gt_textedit_lines.
*&    ENDIF.
  ELSE.
    LOOP AT LT_TLINES.
      APPEND LT_TLINES-TDLINE TO GT_TEXTEDIT_LINES.
    ENDLOOP.
  ENDIF.

* send table to control
  CALL METHOD GS_EDITOR->SET_TEXT_AS_R3TABLE
    EXPORTING
      TABLE = GT_TEXTEDIT_LINES.

ENDMODULE.                 " set_control_text  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  control_flush  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CONTROL_FLUSH OUTPUT.
  CALL FUNCTION 'CONTROL_FLUSH'
    EXCEPTIONS
      CNTL_SYSTEM_ERROR = 1
      CNTL_ERROR        = 2
      OTHERS            = 3.
ENDMODULE.                 " control_flush  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  create_instance_controls  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_INSTANCE_CONTROLS OUTPUT.
  PERFORM CREATE_AND_INIT_CONTROLS.
ENDMODULE.                 " create_instance_controls  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0901  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0901 OUTPUT.
  REFRESH GT_PFSTATUS.         CLEAR GT_PFSTATUS.
  SET TITLEBAR  'T91'.
  SET PF-STATUS 'PFS_0901' EXCLUDING GT_PFSTATUS.

  DESCRIBE TABLE GT_STOCK   LINES TC_STOCK-LINES.

ENDMODULE.                 " STATUS_0901  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_101_INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_101_INIT OUTPUT.
  DESCRIBE  TABLE  GT_NUM    LINES  TC_101-LINES.
ENDMODULE.                 " TC_101_INIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_101_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_101_GET_LINES OUTPUT.

ENDMODULE.                 " TC_101_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0101 OUTPUT.
  SET PF-STATUS 'G1002'.
  SET TITLEBAR 'T1002'.
ENDMODULE.                 " STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  READ_MARK_GT_NUM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_MARK_GT_NUM INPUT.
  MODIFY  GT_NUM  INDEX TC_101-CURRENT_LINE.
ENDMODULE.                 " READ_MARK_GT_NUM  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0101 INPUT.
  CASE OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'RW'.
      LEAVE TO SCREEN 0.


    WHEN 'NOTS'.
      DATA L_LINE TYPE I.
      GET CURSOR LINE L_LINE.
      READ TABLE GT_NUM INDEX L_LINE.
      SET PARAMETER ID 'IQM' FIELD GT_NUM-QMNUM.
      CALL TRANSACTION 'QM03' AND SKIP FIRST SCREEN.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0902  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0902 OUTPUT.
  SET TITLEBAR  'T92'.
  SET PF-STATUS 'PFS_0902' EXCLUDING GT_PFSTATUS.

ENDMODULE.                 " STATUS_0902  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_TEXT_CONTROL2  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_TEXT_CONTROL2 OUTPUT.

  LV_TEXTEDIT_WRAPPOS = 80.

* create textedit control
  LV_REPID = SY-REPID.
  LV_DYNNR = SY-DYNNR.
  IF GS_EDITOR IS INITIAL.
    CREATE OBJECT GS_EDITOR
      EXPORTING
        REPID            = LV_REPID
        DYNNR            = LV_DYNNR
        DYNPRO_CONTAINER = CON_TEXTEDIT_CONTAINER
      EXCEPTIONS
        OTHERS           = 1.
    IF SY-SUBRC NE 0.
      MESSAGE S888 WITH 'EDITOR_CREATE' SY-SUBRC.
    ENDIF.
  ENDIF.                               " Editor is initial

  IF LV_DYNNR <> GS_LINK_DYNNR.
    CALL METHOD GS_EDITOR->LINK_TO_SCREEN
      EXPORTING
        REPID            = LV_REPID
        DYNNR            = LV_DYNNR
        DYNPRO_CONTAINER = CON_TEXTEDIT_CONTAINER.
    GS_LINK_DYNNR = LV_DYNNR.
  ENDIF.

* set display mode
  CALL METHOD GS_EDITOR->SET_READONLY_MODE
    EXPORTING
      READONLY_MODE = C_TEXTEDIT_CONTROL=>TRUE.

* set wordWrap behavior
  CALL METHOD GS_EDITOR->SET_WORDWRAP_BEHAVIOR
    EXPORTING
      WORDWRAP_MODE              = C_TEXTEDIT_CONTROL=>WORDWRAP_AT_FIXED_POSITION
      WORDWRAP_POSITION          = LV_TEXTEDIT_WRAPPOS
      WORDWRAP_TO_LINEBREAK_MODE = C_TEXTEDIT_CONTROL=>TRUE
    EXCEPTIONS
      OTHERS                     = 1.

* set cursor to text control
  CALL METHOD GS_EDITOR->SET_FOCUS_TO_CONTROL.

ENDMODULE.                 " INIT_TEXT_CONTROL2  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CONTROL_TEXT2  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CONTROL_TEXT2 OUTPUT.
  DATA : LV_TDNAME    LIKE STXH-TDNAME.
  REFRESH: GT_TEXTEDIT_LINES, GT_TLINES, LT_TLINES.
  CLEAR  : GT_TEXTEDIT_LINES, GT_TLINES, LT_TLINES,
           GS_TEXTEDIT_HEADER.

  CONCATENATE GT_AFKO-WERKS GT_AFKO-MATKL+1(2) GT_AFKO-MATNR INTO LV_TDNAME.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = 'Z01'     "품목 텍스트 ID
      LANGUAGE  = SY-LANGU
      NAME      = LV_TDNAME
      OBJECT    = 'ZPP_MAT'    "자재코드 특기사항 오브젝트
    TABLES
      LINES     = LT_TLINES
    EXCEPTIONS
      NOT_FOUND = 01.

  IF LT_TLINES[] IS NOT INITIAL.
    LOOP AT LT_TLINES.
      APPEND LT_TLINES-TDLINE TO GT_TEXTEDIT_LINES.
    ENDLOOP.
  ENDIF.

* send table to control
  CALL METHOD GS_EDITOR->SET_TEXT_AS_R3TABLE
    EXPORTING
      TABLE = GT_TEXTEDIT_LINES.

ENDMODULE.                 " SET_CONTROL_TEXT2  OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0102 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0102 OUTPUT.

  SET PF-STATUS '102'.
  IF GV_OKCODE = 'INFO'.
    SET TITLEBAR '102'.
  ELSE.
    SET TITLEBAR '102_1'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0102 OUTPUT
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0102 OUTPUT.

  IF GO_GRID_0102 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0102.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0102.
    PERFORM SET_LAYOUT_GRID_0102.
    PERFORM SET_FIELDCAT_GRID_0102.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0102.
    PERFORM CALL_GRID_0102_DISPLAY.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0903 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0903 OUTPUT.

  SET TITLEBAR  'T93'.
  SET PF-STATUS 'PFS_0903'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_TEXT_CONTROL_903 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_TEXT_CONTROL_903 OUTPUT.

  LV_TEXTEDIT_WRAPPOS = 132.

* create textedit control
  LV_REPID = SY-REPID.
  LV_DYNNR = SY-DYNNR.
  IF GS_EDITOR IS INITIAL.
    CREATE OBJECT GS_EDITOR
      EXPORTING
        REPID            = LV_REPID
        DYNNR            = LV_DYNNR
        DYNPRO_CONTAINER = CON_TEXTEDIT_CONTAINER
      EXCEPTIONS
        OTHERS           = 1.
    IF SY-SUBRC NE 0.
      MESSAGE S888 WITH 'EDITOR_CREATE' SY-SUBRC.
    ENDIF.
  ENDIF.                               " Editor is initial

  IF LV_DYNNR <> GS_LINK_DYNNR.
    CALL METHOD GS_EDITOR->LINK_TO_SCREEN
      EXPORTING
        REPID            = LV_REPID
        DYNNR            = LV_DYNNR
        DYNPRO_CONTAINER = CON_TEXTEDIT_CONTAINER.
    GS_LINK_DYNNR = LV_DYNNR.
  ENDIF.

* set display mode
  CALL METHOD GS_EDITOR->SET_READONLY_MODE
    EXPORTING
      READONLY_MODE = C_TEXTEDIT_CONTROL=>TRUE.

* set wordWrap behavior
  CALL METHOD GS_EDITOR->SET_WORDWRAP_BEHAVIOR
    EXPORTING
      WORDWRAP_MODE              = C_TEXTEDIT_CONTROL=>WORDWRAP_AT_FIXED_POSITION
      WORDWRAP_POSITION          = LV_TEXTEDIT_WRAPPOS
      WORDWRAP_TO_LINEBREAK_MODE = C_TEXTEDIT_CONTROL=>TRUE
    EXCEPTIONS
      OTHERS                     = 1.

* set cursor to text control
  CALL METHOD GS_EDITOR->SET_FOCUS_TO_CONTROL.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_CONTROL_TEXT_903 OUTPUT
*&---------------------------------------------------------------------*
MODULE SET_CONTROL_TEXT_903 OUTPUT.

  CONCATENATE GT_AFKO-WERKS GT_AFKO-MATKL+1(2) GT_AFKO-MATNR INTO LV_TDNAME.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = 'Z01'     "품목 텍스트 ID
      LANGUAGE  = SY-LANGU
      NAME      = LV_TDNAME
      OBJECT    = 'ZPP_MAT'    "자재코드 특기사항 오브젝트
    TABLES
      LINES     = LT_TLINES
    EXCEPTIONS
      NOT_FOUND = 01.

  SELECT REG_FMSG, REG_SMSG
      INTO TABLE @DATA(LT_3180)
      FROM ZGTPPT3180
      WHERE WERKS EQ @GT_AFKO-WERKS
           AND AUFNR EQ @GT_AFKO-AUFNR
           AND POSNR EQ @GT_AFKO-POSNR
           AND ZIFKEY EQ ( SELECT MAX( ZIFKEY ) FROM ZGTPPT3180
                                                   WHERE WERKS EQ @GT_AFKO-WERKS
                                                        AND AUFNR EQ @GT_AFKO-AUFNR
                                                        AND POSNR EQ @GT_AFKO-POSNR ).

  CLEAR : GT_TEXTEDIT_LINES, GT_TEXTEDIT_LINES[].
  IF LT_3180[] IS NOT INITIAL.
    LOOP AT LT_3180 INTO DATA(LS_3180).
      LT_TLINES-TDLINE = LS_3180-REG_FMSG.
      APPEND LT_TLINES-TDLINE TO GT_TEXTEDIT_LINES.
      LT_TLINES-TDLINE = LS_3180-REG_SMSG.
      APPEND LT_TLINES-TDLINE TO GT_TEXTEDIT_LINES.
    ENDLOOP.
  ENDIF.
* send table to control
  CALL METHOD GS_EDITOR->SET_TEXT_AS_R3TABLE
    EXPORTING
      TABLE = GT_TEXTEDIT_LINES.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_CONTROLS OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_CONTROLS OUTPUT.
* 상단 ALV
  IF GO_GRID_0904 IS NOT BOUND.

    PERFORM SET_OBJECT_GRID_0904.
    PERFORM SET_LAYOUT_GRID_0904.
    PERFORM SET_FIELDCAT_GRID_0904.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0904 .
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0904.
    PERFORM CALL_GRID_0904_DISPLAY.

  ELSE.

    GS_SCROLL-ROW = 'X'.
    GS_SCROLL-COL = 'X'.

    CALL METHOD GO_GRID_0904->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = 'X'
        IS_STABLE      = GS_SCROLL.     "현재 그대로 입력한 refresh

  ENDIF.
* 하단 TEXT EDIT
  PERFORM INIT_TEXT_CONTROL_0904_1.
  PERFORM SET_CONTROL_TEXT_0904_1.
  PERFORM CONTROL_FLUSH.

ENDMODULE.
