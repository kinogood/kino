*&---------------------------------------------------------------------*
*& Include          ZGTMMR4130O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  REFRESH GT_UCOMM.            CLEAR GT_UCOMM.

  SET TITLEBAR  'T10'.
  IF P_PRBOX ='X'.
    SET TITLEBAR  'T30' WITH '구매오더 생성'.
  ELSEIF P_POBOX  = 'X'.
    SET TITLEBAR  'T30' WITH '구매오더 변경'.
  ELSEIF P_CANCEL = 'X'.
    SET TITLEBAR  'T30' WITH '구매오더 취소'.
  ELSE.
    SET TITLEBAR  'T30' WITH '구매오더 확정 조회'.
  ENDIF.

  IF P_CANCEL = 'X'.
    APPEND 'ME21N'                TO GT_UCOMM.
    APPEND 'ZMMR0041'             TO GT_UCOMM.
    APPEND 'ZZZZ'                 TO GT_UCOMM.
  ELSE.
    APPEND 'ME21N_D '             TO GT_UCOMM.
  ENDIF.

  IF P_CONF = 'X'.
    APPEND 'ME21N'                TO GT_UCOMM.
    APPEND 'ME21N_D '             TO GT_UCOMM.
    APPEND 'ME22N'                TO GT_UCOMM.
    APPEND 'MEBOM'                TO GT_UCOMM.
    APPEND 'ZMMR0041'             TO GT_UCOMM.
    APPEND 'ZPPR0052'             TO GT_UCOMM.
    APPEND 'ZPPR0052_R'           TO GT_UCOMM.
  ENDIF.

  IF P_POBOX <> 'X'.
    APPEND 'POTEXT'             TO GT_UCOMM.
  ENDIF.

  SET PF-STATUS 'PFS_0100' EXCLUDING GT_UCOMM.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  create_instance_controls  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_INSTANCE_CONTROLS OUTPUT.
  PERFORM CREATE_AND_INIT_CONTROLS.
ENDMODULE.                 " create_instance_controls  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  REFRESH GT_UCOMM.           CLEAR GT_UCOMM.

  SET TITLEBAR  'T20'.

  IF P_CANCEL = 'X'.
    APPEND 'MB1B'                 TO GT_UCOMM.
    APPEND 'ZLER0015'             TO GT_UCOMM.
  ELSE.
    APPEND 'CCAP'                 TO GT_UCOMM. "추가(SJM 25.03.18)
    APPEND 'MBST'                 TO GT_UCOMM.
    APPEND 'ZLER0016'             TO GT_UCOMM.
  ENDIF.

*& 자동차 전선의 경우 통문증 미발행...
  IF GV_SPART = '21'.
    IF P_CANCEL = 'X'.
      APPEND 'ZLER0015_Z'         TO GT_UCOMM.
    ELSE.
      APPEND 'ZLER0016_Z'         TO GT_UCOMM.
    ENDIF.
  ELSE.
    APPEND 'ZLER0015_Z'           TO GT_UCOMM.
    APPEND 'ZLER0016_Z'           TO GT_UCOMM.
  ENDIF.

  SET PF-STATUS 'PFS_0200' EXCLUDING GT_UCOMM.
ENDMODULE.                 " status_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  create_instance_controls_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CREATE_INSTANCE_CONTROLS_0200 OUTPUT.
  PERFORM CREATE_AND_INIT_CONTROLS_0200.
ENDMODULE.                 " create_instance_controls_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_text_control  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_TEXT_CONTROL OUTPUT.
* Create Control
  DATA: LV_TEXTEDIT_WRAPPOS TYPE I.
  DATA: LV_REPID LIKE SY-REPID,
        LV_DYNNR LIKE SY-DYNNR.

  LV_TEXTEDIT_WRAPPOS = CON_TEXTEDIT_MAXLINELENGTH.

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

ENDMODULE.                 " init_text_control  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_control_text  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CONTROL_TEXT OUTPUT.

  DATA: LT_SCH     LIKE THEAD-TDNAME.

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
*&      Module  status_0900  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0900 OUTPUT.
  REFRESH GT_PFSTATUS.         CLEAR GT_PFSTATUS.
  SET TITLEBAR  'T90'.
  SET PF-STATUS 'PFS_0900' EXCLUDING GT_PFSTATUS.

ENDMODULE.                 " status_0900  OUTPUT
*&---------------------------------------------------------------------*
*& Module PBO_0210 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0210 OUTPUT.

  DATA : LT_EXCD TYPE TABLE OF FCODE.


  CLEAR : LT_EXCD[].
  IF GV_PRC = GC_E.
    LT_EXCD[] = VALUE #( ( 'YPRX' )
                         ( 'NPRX' ) ).
  ENDIF.

  SET PF-STATUS '0210' EXCLUDING LT_EXCD.
  SET TITLEBAR  '0210'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module MODIFY_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE MODIFY_SCREEN OUTPUT.

  CHECK GV_PRC <> GC_N.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = GC_MGI.
      SCREEN-ACTIVE = GC_0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_LIST_BOX OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_LIST_BOX OUTPUT.

  CHECK GS_HDR-ORES IS INITIAL.

  CLEAR : GT_LBOX[].

  SELECT FLD_03
         FLD_04
    FROM ZGTPPT1010
    INTO TABLE GT_LBOX
   WHERE FLD_01 = 'ZGTMMR4110' "SY-CPROG
     AND FLD_02 = GC_A.

  PERFORM VRM_SET_VALUES USING 'GS_HDR-ORES'
                                GS_HDR-ORES.

ENDMODULE.
