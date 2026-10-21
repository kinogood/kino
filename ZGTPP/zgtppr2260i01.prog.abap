*&---------------------------------------------------------------------*
*& Include          ZGTPPR2260I01
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
      CALL METHOD GO_DOCKING_0100->FREE.
      FREE : GO_DOCKING_0100, GO_SPLITTER, GO_SPLITTER2.
      FREE : GO_SPLITTER3, GO_SPLITTER_0100, GO_CONTAIN_0100.
      FREE : GO_CONTAIN_TOP_0100, GO_GRID_0100, GO_DD_DOCU_0100.
      FREE : GO_SPLITTER_0101, GO_CONTAIN_0101_TOP, GO_CONTAIN_0101.
      FREE : GO_GRID_0101_TOP, GO_GRID_0101.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

    WHEN 'REFRESH'.
      PERFORM GET_DATA.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
      PERFORM REFRESH_GRID USING GO_GRID_0101_TOP.
      PERFORM REFRESH_GRID USING GO_GRID_0101.

    WHEN 'CHECK'.
      PERFORM SET_CHECK_100.

    WHEN 'ALL_SEL'. " 신규조장 생성
      PERFORM SET_CHECK_ALL_100.

    WHEN 'DE_SEL'.
      PERFORM SET_CHECK_DESEL_100.

    WHEN 'SETCHECK'.
      CASE GV_CHK_SCREEN.
        WHEN '0100'.
          PERFORM SET_SCREEN_100_CHECKED.
        WHEN '0101'.
          PERFORM SET_SCREEN_101_CHECKED.
      ENDCASE.

    WHEN 'CAL_MENG'.
      PERFORM SET_TOTAL_DISP_TABLE.
      PERFORM REFRESH_GRID USING GO_GRID_0101.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.

  CLEAR GV_OK_CODE3.
  GV_OK_CODE3 = SY-UCOMM.

  CASE GV_OK_CODE3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      GO_CONTAINER_400->FREE( ).
      FREE : GO_CONTAINER_400, GO_TEXT_400.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      PERFORM CHECK_AND_CREATE.

  ENDCASE.

ENDMODULE.
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

  SELECT MATNR MAKTX
     FROM ZGTCVMSTVAL
       INTO CORRESPONDING FIELDS OF TABLE LT_MATNR
     WHERE WERKS = P_WERKS
       AND PDCAPROCCODE = P_GONGCD
       AND MMSTA = SPACE.

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
*&      Module  CHECK_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_MATNR INPUT.

  CLEAR GS_MAKE_ORDER-MAKTX.

  SELECT SINGLE MAKTX
     FROM ZGTCVMSTVAL
       INTO GS_MAKE_ORDER-MAKTX
     WHERE WERKS = P_WERKS
       AND MATNR = GS_MAKE_ORDER-MATNR
       AND PDCAPROCCODE = P_GONGCD
       AND MMSTA = SPACE.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SCREEN_400_CHK_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM SCREEN_400_CHK_INIT  CHANGING PV_MESSAGE.

  IF GS_MAKE_ORDER-MATNR IS INITIAL.
    PV_MESSAGE = TEXT-E02.
  ENDIF.

  IF GS_MAKE_ORDER-GAMNG IS INITIAL OR GS_MAKE_ORDER-GAMNG = 0.
    PV_MESSAGE = TEXT-E03.
  ENDIF.


  IF GS_MAKE_ORDER-GSTRP IS INITIAL OR GS_MAKE_ORDER-GSTRP = '00000000'.
    PV_MESSAGE = TEXT-E04.
  ENDIF.

  IF GS_MAKE_ORDER-GLTRP IS INITIAL OR GS_MAKE_ORDER-GLTRP = '00000000'.
    PV_MESSAGE = TEXT-E05.
  ENDIF.

  IF GS_MAKE_ORDER-INLENGTH IS INITIAL OR GS_MAKE_ORDER-INLENGTH = 0.
    PV_MESSAGE = TEXT-E06.
  ENDIF.

  IF GS_MAKE_ORDER-INFACTOR IS INITIAL OR GS_MAKE_ORDER-INFACTOR = 0.
    PV_MESSAGE = TEXT-E07.
  ENDIF.

  IF GS_MAKE_ORDER-SEQ IS INITIAL OR GS_MAKE_ORDER-SEQ = 0.
    PV_MESSAGE = TEXT-E08.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  CALCULATE_GAMNG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CALCULATE_GAMNG INPUT.

  CLEAR GS_MAKE_ORDER-GAMNG.

  GS_MAKE_ORDER-GAMNG = ( GS_MAKE_ORDER-INLENGTH * GS_MAKE_ORDER-INFACTOR ) +
                                          GS_MAKE_ORDER-QLENGTH .

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
      UNASSIGN <GT_SET_SCHEDULE>.
      CALL METHOD GO_DOCKING_0200->FREE.
      FREE : GO_DOCKING_0200, GO_GRID_0200.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'REFRESH'.
      PERFORM GET_MAIN_PROD_ORDER_INFOR.
* 스케줄 데이터 구성
      PERFORM MAKE_MAINTAIN_SCHEDULE.
* 화면 구성
      PERFORM MAKE_DISP_TABLE_SCHEDULE.

      PERFORM REFRESH_GRID USING GO_GRID_0200.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CLEAR GV_OK_CODE5.
  GV_OK_CODE5 = SY-UCOMM.

  CASE GV_OK_CODE5.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CONFIRM'.
      GO_CONTAINER_300->FREE( ).
      GO_TEXT_300->FREE( ).
      FREE : GO_CONTAINER_300, GO_TEXT_300.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
