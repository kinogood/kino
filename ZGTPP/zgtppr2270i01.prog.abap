*&---------------------------------------------------------------------*
*& Include          ZGTPPR2270I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

*     종료
      CALL METHOD GO_DOCKING_CONTAINER->FREE.
      CLEAR : GO_DOCKING_CONTAINER, GO_GRID_0100, GO_GRID_0101.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'REFRESH'.

      PERFORM GET_PROC.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
      PERFORM REFRESH_GRID USING GO_GRID_0101.
      PERFORM REFRESH_GRID USING GO_GRID_0102.
    WHEN 'CR_PO'.

      CLEAR GS_MAKE_ORDER.
      CLEAR GV_CHK_CREATE.
      CLEAR GV_MESSAGE_300.
      GS_MAKE_ORDER-GMEIN = 'M'.
      GS_MAKE_ORDER-GLTRP = SY-DATUM + 7.
      GS_MAKE_ORDER-GSTRP = SY-DATUM + 7.


      CALL SCREEN '0300' STARTING AT 5 5 ENDING AT 83 18.

      IF GV_CHK_CREATE = 'S'.
        PERFORM GET_PROC.
        PERFORM REFRESH_GRID USING GO_GRID_0100.
        MESSAGE S003 WITH GV_MESSAGE_300.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E' WITH GV_MESSAGE_300.
      ENDIF.

    WHEN 'DEL_PO'.
      CLEAR GV_CHK_DEL.

      PERFORM PROC_DEL_PO.

      IF GV_CHK_DEL = 'S'.
        PERFORM GET_PROC.
        PERFORM REFRESH_GRID USING GO_GRID_0100.
        MESSAGE S003 WITH '생산오더 삭제 되었습니다.'.
      ENDIF.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0101
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      GO_GRID_0100->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0100 ).
    WHEN GO_GRID_0101.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0101.
      GO_GRID_0101->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0101 ).
    WHEN GO_GRID_0102.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0102.
      GO_GRID_0102->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0102 ).
    WHEN GO_GRID_0500.
      GO_GRID_0500->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0500 ).
    WHEN GO_GRID_0501.
      GO_GRID_0501->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0501 ).
  ENDCASE.


  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

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
*&      Module  F4HELP_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_MATNR INPUT.

  DATA : BEGIN OF LS_MATNR,
           MATNR TYPE MATNR,
           MAKTX TYPE MAKTX,
         END OF LS_MATNR.
  DATA : LT_MATNR LIKE TABLE OF LS_MATNR.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

* 조회조건의 자재와 자내내역을 조합하여 추출 자재범위 세팅
  SELECT A~MATNR, B~MAKTX
    FROM MARC AS A
    INNER JOIN MAKT AS B  ON B~MATNR = A~MATNR
    INNER JOIN MARA AS C ON C~MATNR = A~MATNR
    INNER JOIN T134 AS D ON D~MTART = C~MTART
   WHERE A~MATNR IN @S_MATNR
      AND A~WERKS = @P_WERKS
      AND A~DISPO LIKE @GV_DISPO
      AND B~MAKTX IN @S_MAKTX
      AND D~MTREF = 'FERT'
    INTO CORRESPONDING FIELDS OF TABLE @LT_MATNR.

  SORT LT_MATNR BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING MATNR.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'MATNR'
*     DYNPPROG        = SY-CPROG                 "현재 프로그램명->ZTER0010
*     DYNPNR          = SY-DYNNR                 "현재 화면번호->0100
      DYNPROFIELD     = 'GS_MAKE_ORDER-MATNR'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '자재코드 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = LT_MATNR                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT        = LS_RETURN_TAB-FIELDVAL
      IMPORTING
        OUTPUT       = GS_MAKE_ORDER-MATNR
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE LT_MATNR INTO LS_MATNR WITH KEY MATNR = GS_MAKE_ORDER-MATNR.
    GS_MAKE_ORDER-MAKTX = LS_MATNR-MAKTX.

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'ENTE'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CALCULATE_GAMNG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CALCULATE_GAMNG INPUT.

  CLEAR GS_MAKE_ORDER-GAMNG.

  GS_MAKE_ORDER-GAMNG = GS_MAKE_ORDER-INLENGTH * GS_MAKE_ORDER-INFACTOR.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_MATNR INPUT.

  CLEAR GS_MAKE_ORDER-MAKTX.

  GS_MAKE_ORDER-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_MAKE_ORDER-MATNR ).

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CLEAR GV_OK_CODE3.
  GV_OK_CODE3 = SY-UCOMM.

  CASE GV_OK_CODE3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      GO_CONTAINER_300->FREE( ).
      GO_TEXT_300->FREE( ).
      FREE : GO_CONTAINER_300, GO_TEXT_300.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      PERFORM CHECK_AND_CREATE.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CLEAR GV_OK_CODE2.
  GV_OK_CODE2 = SY-UCOMM.

  CASE GV_OK_CODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

      CALL METHOD GO_DOCKING_0200->FREE.
      FREE : GO_DOCKING_0200, GO_SPLITTER_0200, GO_CONTAIN_0200.
      FREE : GO_CONTAIN_0201, GO_GRID_0200, GO_GRID_0201.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.


    WHEN 'CONFIRM'.
      CLEAR GV_ANSWER.
      CLEAR GV_CONTINUE_200.
      PERFORM CHECK_0200 CHANGING GV_ANSWER.

      IF GV_ANSWER IS NOT INITIAL.
        RETURN.
      ENDIF.

      GV_CONTINUE_200 = ABAP_TRUE.

      CALL METHOD GO_DOCKING_0200->FREE.
      FREE : GO_DOCKING_0200, GO_SPLITTER_0200, GO_CONTAIN_0200.
      FREE : GO_CONTAIN_0201, GO_GRID_0200, GO_GRID_0201.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_LIFNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_LIFNR INPUT.

  PERFORM F4HELP_LIFNR.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.

  CLEAR GV_OK_CODE4.
  GV_OK_CODE4 = SY-UCOMM.

  CASE GV_OK_CODE4.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CONFIRM'.
      GO_CONTAINER_400->FREE( ).
      GO_TEXT_400->FREE( ).
      FREE : GO_CONTAINER_400, GO_TEXT_400.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.

  CLEAR GV_OK_CODE5.
  GV_OK_CODE5 = SY-UCOMM.

  CASE GV_OK_CODE5.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

      CALL METHOD GO_DOCKING_0500->FREE.
      FREE : GO_DOCKING_0500, GO_SPLITTER_0500, GO_CONTAIN_0500.
      FREE : GO_CONTAIN_0501, GO_GRID_0500, GO_GRID_0501.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.


    WHEN 'REFRESH'.
      PERFORM GET_PROC.

      PERFORM REFRESH_GRID USING GO_GRID_0500.
      PERFORM REFRESH_GRID USING GO_GRID_0501.
    WHEN 'REQUEST'.
      PERFORM PROC_REQUEST_SIPAN.
    WHEN 'DEL_REQ'.
      PERFORM PROC_DEL_REQ_SIPAN.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0500 OUTPUT.

  IF GO_GRID_0500 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0500.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0500.
    PERFORM SET_LAYOUT_GRID_0500.
    PERFORM SET_FIELDCAT_GRID_0500.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0500.
    PERFORM SET_SORTTAB_GRID_0500.
    PERFORM CALL_GRID_0500_DISPLAY.


    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0501.
    PERFORM SET_LAYOUT_GRID_0501.
    PERFORM SET_FIELDCAT_GRID_0501.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0501.
    PERFORM SET_SORTTAB_GRID_0501.
    PERFORM CALL_GRID_0501_DISPLAY.

  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0700 INPUT.

  CLEAR GV_OK_CODE7.
  GV_OK_CODE7 = SY-UCOMM.

  CASE GV_OK_CODE7.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CONFIRM'.
      CALL METHOD GO_CONTAIN_0700->FREE.
      FREE : GO_CONTAIN_0700, GO_GRID_0700.
      FREE : GT_SORT_0700, GT_EXCLUDE_0700, GT_FIELDCAT_0700.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_LGORT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_LGORT INPUT.

  PERFORM F4HELP_LGORT.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0800 INPUT.

  CLEAR GV_OK_CODE8.
  GV_OK_CODE8 = SY-UCOMM.

  CASE GV_OK_CODE8.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CONFIRM'.

      CALL METHOD GO_CONTAIN_0800->FREE.
      FREE : GO_CONTAIN_0800, GO_GRID_0800.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
