*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.

  GV_OK_CODE2 = GV_OK_CODE.
  CLEAR: GV_OK_CODE.

  CASE GV_OK_CODE2.
    WHEN 'BACK' OR 'CANC'.
      PERFORM EXIT_PROGRAM.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

*  gv_ok_code2 = gv_ok_code.
*  CLEAR: gv_ok_code.

  CASE GV_OK_CODE.
    WHEN 'SEND' OR
            'RESEND'. "재처리
    WHEN 'REFRESH'. "REFRESH
* 데이터 갱신
      PERFORM GET_DATA.
      PERFORM MODIFY_DATA.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
    WHEN 'SAVE'.
      PERFORM SAVE_DATA.
    WHEN 'SMAIL'.
      PERFORM SEND_MAIL.
    WHEN 'MANAGE'.
      CALL TRANSACTION 'ZGTPPT3293'. "유비보수뷰 호출
    WHEN 'SETCHECK'.
      PERFORM SET_CHECK_BOX.
    WHEN 'FILTER'.
      PERFORM SET_FILTER.

  ENDCASE.
* REFRESH DISPLAY
*  PERFORM REFRESH_GRID USING GO_GRID_0100.
*  CALL METHOD go_grid_0100->refresh_table_display
*    EXPORTING
*      i_soft_refresh = 'X'
*      is_stable      = gv_stable.

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
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0220  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0220 INPUT.

  CASE GV_OK_CODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'NO'.
      CALL METHOD GO_CONTAIN_0220->FREE.
      FREE : GO_CONTAIN_0220, GO_GRID_0220.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'YES'.
*      PERFORM input_alternative_material.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0250  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0250 INPUT.

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LT_CELLS_DISP TYPE LVC_T_CENO.
  DATA : LV_RESULT.

  CLEAR GV_OK_CODE7.
  GV_OK_CODE7 = SY-UCOMM.

  DATA : LS_DISP LIKE GS_DISP,
         LT_DISP LIKE TABLE OF GS_DISP . "전송 ALV 테이블

  CASE GV_OK_CODE7.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
*      CLEAR GS_STANDARD_ADLENGTH.
      LEAVE TO SCREEN 0.

    WHEN 'CONFIRM'.

      IF GS_DISP-AUSCH IS INITIAL.
        MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E10..
      ENDIF.

      CLEAR : LT_DISP[].

      LT_DISP[] = GT_DISP[].

      CLEAR : LT_DISP[].
      LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_DISPL>)
                               WHERE CHECK = 'X'.
        MOVE-CORRESPONDING <LS_DISPL> TO LS_DISP.
        APPEND LS_DISP TO LT_DISP.
      ENDLOOP.

      SORT LT_DISP BY     CHECK
                          GRPNR
                          VBELN
                          AUFNR_T
                          MATNR_F
                          GONG_CD
                          MATNR_R.

      DELETE ADJACENT DUPLICATES FROM LT_DISP
                     COMPARING
                          CHECK
                          GRPNR
                          VBELN
                          AUFNR_T
                          MATNR_F
                          GONG_CD
                          MATNR_R.



      LOOP AT LT_DISP ASSIGNING FIELD-SYMBOL(<GS_DISP>) .
*                                         WHERE CHECK = 'X'.
        PERFORM SAVE_LOSS_3291 USING <GS_DISP>
                                     GS_DISP-AUSCH
                                     LV_RESULT.

        <GS_DISP>-AUSCH = GS_DISP-AUSCH.
        MODIFY LT_DISP FROM GS_DISP.
      ENDLOOP.

      IF LV_RESULT = 'S'.
        MESSAGE S003 DISPLAY LIKE 'S' WITH '저장작업이 성공 되었습니다.'.
      ELSE.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '저장작업이 실패하였습니다.'.
      ENDIF.

      LEAVE TO SCREEN 0.


  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0230  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0230 INPUT.
  CLEAR GV_OK_CODE3.
  GV_OK_CODE3 = SY-UCOMM.

  CASE GV_OK_CODE3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_CONTAIN_0230->FREE.
      FREE : GO_CONTAIN_0230, GO_GRID_0230.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND2 INPUT.

  GV_OK_CODE5 = SY-UCOMM.

  CASE GV_OK_CODE5.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_TEXT2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TEXT2 INPUT.


  DATA : LV_MATNR    LIKE MARC-MATNR,
         LV_MATNR2   LIKE MARC-MATNR,
         LV_TEXT(60).

  CLEAR : GV_ERROR.

  IF GV_MATNR IS NOT INITIAL.
    CLEAR : GV_MAKTX.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = GV_MATNR
      IMPORTING
        OUTPUT = LV_MATNR2.

    SELECT SINGLE MAKTX INTO @GV_MAKTX
      FROM MAKT
     WHERE MATNR EQ @LV_MATNR2
       AND SPRAS EQ @SY-LANGU.
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.


  CLEAR: GV_ANSWER.
  GV_OK_CODE5 = SY-UCOMM.

  CASE GV_OK_CODE5.
    WHEN 'YES2'.

*      CHECK gv_error IS INITIAL.

      IF GV_MATNR IS INITIAL.
        MESSAGE I003 WITH TEXT-M14.
      ELSE.

        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
          EXPORTING
            TITEL     = TEXT-P33 "대체자재 일괄 변경
            TEXTLINE1 = TEXT-P34 "입력한 대체자재로 모두 일괄 변경 처리 하시겠습니까?
            TEXTLINE2 = ''
          IMPORTING
            ANSWER    = GV_ANSWER.

        CHECK GV_ANSWER = 'J'.

        LEAVE TO SCREEN 0.

      ENDIF.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0260  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0260 INPUT.

  CASE GV_OK_CODE8.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'NO'.
      CALL METHOD GO_CONTAIN_0260->FREE.
      FREE : GO_CONTAIN_0260, GO_GRID_0260.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'YES'.
*      PERFORM input_alternative_material.
  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0270  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0270 INPUT.
  CLEAR GV_OK_CODE9.
  GV_OK_CODE9 = SY-UCOMM.

  CASE GV_OK_CODE9.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_CONTAIN_0270->FREE.
      FREE : GO_CONTAIN_0270, GO_GRID_0270.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      CLEAR : GT_T3292P[], GS_T3292P.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.

  CLEAR GV_OK_CODE500.
  GV_OK_CODE500 = SY-UCOMM.

  CASE GV_OK_CODE500.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_CONTAIN_0500->FREE.
      FREE : GO_CONTAIN_0500, GO_GRID_0500.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
