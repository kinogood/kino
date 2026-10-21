*&---------------------------------------------------------------------*
*& Include          ZGTPPR2010I01
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
      CALL METHOD GO_CONTAIN_0100->FREE.
      FREE : GO_CONTAIN_0100, GO_GRID_0100.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'REFRESH'.
      PERFORM GET_PROC.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
    WHEN 'DISPLAY'.
      PERFORM MAKE_BOM_PROC.
      IF GV_CHK_SUBPOOL_DIR_FULL IS NOT INITIAL.
*     종료
        CALL METHOD GO_CONTAIN_0100->FREE.
        FREE : GO_CONTAIN_0100, GO_GRID_0100.
        CALL METHOD CL_GUI_CFW=>FLUSH.
        LEAVE TO SCREEN 0.
      ENDIF.
      IF GV_CHECK_LOCK IS NOT INITIAL.
        RETURN.
      ENDIF.

      IF <GT_MAIN_201> IS ASSIGNED.
        CALL SCREEN 0200.
      ENDIF.
    WHEN 'DEL'.
      PERFORM DEL_GRPNO.
    WHEN 'SETCHECK'.
      PERFORM SET_CHECK_BOX.
  ENDCASE.

  IF GV_CHK_SUBPOOL_DIR_FULL IS NOT INITIAL.
*     종료
    CALL METHOD GO_CONTAIN_0100->FREE.
    FREE : GO_CONTAIN_0100, GO_GRID_0100.
    CALL METHOD CL_GUI_CFW=>FLUSH.
    LEAVE TO SCREEN 0.
  ENDIF.

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
      IF SY-TCODE NE 'ZGTPPR2050'.
        CALL FUNCTION 'DEQUEUE_EZGT_ZGTPPR2010'
          EXPORTING
            GRPNR = GV_GRPNR.
      ENDIF.

      CALL METHOD GO_DOCKING_CONTAINER->FREE.
      FREE : GO_DOCKING_CONTAINER, GO_GRID_0200, GO_GRID_0201.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

    WHEN 'REFRESH'.
      PERFORM REFRESH_SCREEN_201.

    WHEN 'NEW_ROT'. " 신규조장 생성

      PERFORM PROC_CREATE_ROUTING.

    WHEN 'DOWN'.
      PERFORM DOWNLOAD_EXCEL.
    WHEN 'SUL_NO'.
*      CHECK SY-TCODE EQ 'ZGTPPR2050'.
      PERFORM DISP_SUL_NO.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0210 INPUT.

  CLEAR GV_OK_CODE3.
  GV_OK_CODE3 = SY-UCOMM.

  CASE GV_OK_CODE3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : GV_ADLENGTH, GV_ADTYPE.
      GV_CHK_EXIT = ABAP_TRUE.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      LEAVE TO SCREEN 0.
  ENDCASE.



ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0220  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0220 INPUT.

  CLEAR GV_OK_CODE4.
  GV_OK_CODE4 = SY-UCOMM.

  CASE GV_OK_CODE4.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

*     종료
      CALL METHOD GO_CONTAIN_0220->FREE.
      FREE : GO_CONTAIN_0220, GO_GRID_0220.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0230  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0230 INPUT.

  CLEAR GV_OK_CODE5.
  GV_OK_CODE5 = SY-UCOMM.

  CASE GV_OK_CODE5.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_CONTAIN_0230->FREE.
      FREE : GO_CONTAIN_0230, GO_GRID_0230.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      CLEAR GV_DUPL_CHK.
      LOOP AT GT_DISP_ARBPL INTO DATA(LS_DISP_ARBPL) WHERE CHECK = ABAP_TRUE.
        ADD 1 TO GV_DUPL_CHK.
      ENDLOOP.

      IF GV_DUPL_CHK > 1.
        MESSAGE I003 DISPLAY LIKE 'E' WITH '하나의 작업장만 선택해 주세요.'.
        RETURN.
      ENDIF.


      CLEAR GS_DISP_ARBPL.
      READ TABLE GT_DISP_ARBPL INTO GS_DISP_ARBPL WITH KEY CHECK = ABAP_TRUE.
      IF SY-SUBRC EQ 0.
*     종료
        CALL METHOD GO_CONTAIN_0230->FREE.
        FREE : GO_CONTAIN_0230, GO_GRID_0230.
        CALL METHOD CL_GUI_CFW=>FLUSH.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE I003 DISPLAY LIKE 'E' WITH '변경할 작업장을 선택해주세요.'.
        RETURN.
      ENDIF.
    WHEN 'SETCHECK'.
      PERFORM SET_CHECKBOX.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0240  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0240 INPUT.

  CLEAR GV_OK_CODE6.
  GV_OK_CODE6 = SY-UCOMM.

  CASE GV_OK_CODE6.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_CONTAIN_0240->FREE.
*    체크 초기화
      LOOP AT GT_PEGGING ASSIGNING FIELD-SYMBOL(<LS_PEGGING>).
        CLEAR <LS_PEGGING>-CHECK.
      ENDLOOP.

      FREE : GO_CONTAIN_0240, GO_GRID_0240.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

    WHEN 'CONFIRM'.
      IF NOT LINE_EXISTS( GT_PEGGING[ CHECK = ABAP_TRUE ] ).
        MESSAGE I003 DISPLAY LIKE 'E' WITH 'Pegging 변경 할 오더를 선택해주세요.'.
        RETURN.
      ENDIF.

      DATA(LT_CHK_PEGGING) = GT_PEGGING[].
      DELETE LT_CHK_PEGGING WHERE CHECK IS INITIAL.
      SORT LT_CHK_PEGGING BY AUFNR.
      DELETE ADJACENT DUPLICATES FROM LT_CHK_PEGGING COMPARING AUFNR.
      IF LINES( LT_CHK_PEGGING ) > 1.
        MESSAGE I003 DISPLAY LIKE 'E' WITH '하나의 오더만 선택해 주세요.'.
        RETURN.
      ENDIF.

      CLEAR : GV_CHK_LABST, GV_CHK_SPEME.
      LOOP AT GT_PEGGING INTO DATA(LS_CHK_LINE) WHERE CHECK = ABAP_TRUE.
        GV_CHK_LABST = GV_CHK_LABST + LS_CHK_LINE-LABST.
        GV_CHK_SPEME = GV_CHK_SPEME + LS_CHK_LINE-SPEME.
        GV_CHK_INSME = GV_CHK_INSME + LS_CHK_LINE-INSME.

      ENDLOOP.
      IF GV_CHK_PSMNG > GV_CHK_LABST.
        IF GV_CHK_PSMNG > GV_CHK_INSME.
          IF GV_CHK_PSMNG > GV_CHK_SPEME.
            MESSAGE I003 DISPLAY LIKE 'E' WITH '재고수량이 부족합니다.'.
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.

*     종료
      CALL METHOD GO_CONTAIN_0240->FREE.
      FREE : GO_CONTAIN_0240, GO_GRID_0240.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

    WHEN 'SETCHECK'.
      PERFORM SET_CHECKBOX_0240.

    WHEN 'SELECT'.
      REFRESH GT_PEGGING.
      PERFORM SELECT_DATA_FROM_MATNR USING GS_PEGGING_DISP-MATNR_RE.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0240.
      PERFORM REFRESH_GRID USING GO_GRID_0240.

  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0250  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0250 INPUT.

  CLEAR GV_OK_CODE7.
  GV_OK_CODE7 = SY-UCOMM.

  CASE GV_OK_CODE7.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CLEAR GS_STANDARD_ADLENGTH.
      LEAVE TO SCREEN 0.

    WHEN 'CONFIRM'.
      IF GS_STANDARD_ADLENGTH-QLENGTH < 0.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '표준 여장은 -를 포합하지 않습니다.'.
        RETURN.
      ENDIF.

      IF GS_STANDARD_ADLENGTH-QLENGTH < 0.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '표준 여장은 -를 포합하지 않습니다.'.
        RETURN.
      ENDIF.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0260  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0260 INPUT.

  CLEAR GV_OK_CODE3.
  GV_OK_CODE3 = SY-UCOMM.

  CASE GV_OK_CODE3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      GV_CHK_EXIT = ABAP_TRUE.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      LEAVE TO SCREEN 0.
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
       AND PDCAPROCCODE = GV_PAGGING_GONG_CD
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
        OUTPUT       = GS_PEGGING_DISP-MATNR_RE
      EXCEPTIONS
        LENGTH_ERROR = 1
        OTHERS       = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE LT_MATNR INTO LS_MATNR WITH KEY MATNR = GS_PEGGING_DISP-MATNR_RE.
    GS_PEGGING_DISP-MAKTX_RE = LS_MATNR-MAKTX.

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

  CLEAR GS_PEGGING_DISP-MAKTX_RE.

  SELECT SINGLE MAKTX
     FROM ZGTCVMSTVAL
       INTO GS_PEGGING_DISP-MAKTX_RE
     WHERE WERKS = P_WERKS
       AND MATNR = GS_PEGGING_DISP-MATNR_RE
       AND PDCAPROCCODE = GV_PAGGING_GONG_CD
       AND MMSTA = SPACE.

ENDMODULE.
