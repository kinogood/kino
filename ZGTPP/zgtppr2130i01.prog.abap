*&---------------------------------------------------------------------*
*& Include          ZGTPPR2130I01
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
      IF GT_ITEM_DISP[] IS NOT INITIAL.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '작업중 데이터가 있습니다. Refresh 하시겠습니까?'
          '작업확인'.
        IF GV_ANSWER EQ 'J'.
          REFRESH GT_ITEM_DISP.

          IF GO_GRID_0101 IS BOUND.
            GO_GRID_0101->FREE( ).
            FREE : GO_GRID_0101, GO_CONTAIN_0101.
          ENDIF.
        ELSE.
          RETURN.
        ENDIF.
      ENDIF.

      PERFORM GET_PROC.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
    WHEN 'CR_PO'.
      CLEAR GS_MAKE_ORDER.
      CLEAR GV_CHK_CREATE.
      CLEAR GV_MESSAGE_300.
      REFRESH GT_TEXT.
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
    WHEN 'CR_PR'.
      CLEAR GV_CHK_CREATE.
      PERFORM PROC_CREATE_PR.

      IF GV_CHK_CREATE = 'S'.
        PERFORM GET_PROC.
        PERFORM REFRESH_GRID USING GO_GRID_0100.
      ENDIF.


    WHEN 'DEL_PR'.
      CLEAR GV_CHK_DEL.
      PERFORM PROC_DELETE_PR.

      IF GV_CHK_DEL = 'S'.
        PERFORM GET_PROC.
        PERFORM REFRESH_GRID USING GO_GRID_0100.
      ENDIF.

  ENDCASE.

ENDMODULE.
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
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE GV_OK_CODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR GV_GRPNR.
      LEAVE TO SCREEN 0.
    WHEN 'OKAY'.
      SELECT SINGLE GRPNR
         FROM ZGTPPT2000
         INTO ZGTPPT2000-GRPNR
        WHERE GRPNR = GV_GRPNR.
      IF SY-SUBRC EQ 0.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE I000 WITH '기존 조장구성표에 등록된 번호가 아닙니다.'.
        RETURN.
      ENDIF.
  ENDCASE.
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
*&      Module  USER_COMMAND_0400  INPUT
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

*  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
*         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

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
*&      Module  CHECK_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_MATNR INPUT.

  CLEAR GS_MAKE_ORDER-MAKTX.

  GS_MAKE_ORDER-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_MAKE_ORDER-MATNR ).

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
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : GS_PR_INFOR.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      PERFORM CHK_AND_SET_LIFNR.
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
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CONFIRM'.
      GO_CONTAINER_500->FREE( ).
      GO_TEXT_500->FREE( ).
      FREE : GO_CONTAINER_500, GO_TEXT_500.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
