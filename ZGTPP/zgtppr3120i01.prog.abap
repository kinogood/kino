*&---------------------------------------------------------------------*
*& Include          ZGTPPR3120I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR GV_OK_CODE.
  GV_OK_CODE = SY-UCOMM.

  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_DOCKING_0100->FREE.
      FREE : GO_DOCKING_0100, GO_GRID_0100.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
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
*     종료
      CALL METHOD GO_DOCKING_0200->FREE.
      FREE : GO_DOCKING_0200, GO_GRID_0200.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

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
*     종료
      CALL METHOD GO_DOCKING_0300->FREE.
      FREE : GO_DOCKING_0300, GO_GRID_0300.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

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
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_CONTAIN_0400->FREE.
      FREE : GO_CONTAIN_0400, GO_GRID_0400.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_BSART  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_BSART INPUT.

  DATA : BEGIN OF LS_BSART,
           BSART TYPE EBAN-BSART, "구매요청 유형
           BATXT TYPE T161T-BATXT, "내역
         END OF LS_BSART.
  DATA : LT_BSART LIKE TABLE OF LS_BSART.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  SELECT BSART BATXT
     FROM T161T
       INTO CORRESPONDING FIELDS OF TABLE LT_BSART
     WHERE BSTYP = GS_REQ_DISP-BSTYP.

  SORT LT_BSART BY BSART.
  DELETE ADJACENT DUPLICATES FROM LT_BSART COMPARING BSART.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'BSART'
      DYNPROFIELD     = 'GS_REQ_DISP-BSART'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '구매요청 유형'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = LT_BSART                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    GS_REQ_DISP-BSART = LS_RETURN_TAB-FIELDVAL.
    READ TABLE LT_BSART INTO LS_BSART WITH KEY BSART = LS_RETURN_TAB-FIELDVAL.
    GS_REQ_DISP-BATXT = LS_BSART-BATXT.

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'ENTE'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.

  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_CHAIN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_CHAIN INPUT.

  CLEAR : GS_REQ_DISP-BATXT, GS_REQ_DISP-EKOTX, GS_REQ_DISP-NAME1.

  IF GS_REQ_DISP-BSART IS NOT INITIAL.
    SELECT SINGLE  BATXT
       FROM T161T
         INTO GS_REQ_DISP-BATXT
       WHERE BSTYP = GS_REQ_DISP-BSTYP
           AND BSART = GS_REQ_DISP-BSART.
  ENDIF.

  IF GS_REQ_DISP-EKORG IS NOT INITIAL.
    SELECT SINGLE  EKOTX
       FROM T024E
         INTO GS_REQ_DISP-EKOTX
       WHERE EKORG = GS_REQ_DISP-EKORG.
  ENDIF.

  IF GS_REQ_DISP-FLIEF IS NOT INITIAL AND GS_REQ_DISP-CHECK IS INITIAL.
    SELECT SINGLE  NAME1
       FROM LFA1
         INTO GS_REQ_DISP-NAME1
       WHERE LIFNR = GS_REQ_DISP-FLIEF.
  ENDIF.

  IF GS_REQ_DISP-RESWK IS NOT INITIAL AND GS_REQ_DISP-CHECK IS NOT INITIAL.
    SELECT SINGLE  NAME1
       FROM T001W
         INTO GS_REQ_DISP-WNAME1
       WHERE WERKS = GS_REQ_DISP-RESWK.
  ENDIF.

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
*     종료
      CALL METHOD GO_CONTAIN_0500->FREE.
      FREE : GO_CONTAIN_0500, GO_GRID_0500.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_EKORG_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_EKORG_0400 INPUT.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'EKORG'
      DYNPROFIELD     = 'GS_REQ_DISP-EKORG'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '구매조직'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = GT_MASTER_EKORG                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    GS_REQ_DISP-EKORG = LS_RETURN_TAB-FIELDVAL.
    READ TABLE GT_MASTER_EKORG INTO DATA(LS_MASTER) WITH KEY EKORG = LS_RETURN_TAB-FIELDVAL.
    GS_REQ_DISP-EKOTX = LS_MASTER-EKOTX.

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'ENTE'              " Function code
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
        OTHERS                 = 2.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4HELP_FLIEF_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4HELP_FLIEF_0400 INPUT.

  PERFORM F4HELP_FLIEF_0400.


ENDMODULE.
