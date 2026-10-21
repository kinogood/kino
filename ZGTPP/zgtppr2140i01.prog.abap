*&---------------------------------------------------------------------*
*& Include          ZGTPPR2140I01
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
      CLEAR GV_MAIN_SORT.
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

      UNASSIGN <GT_MAIN_201>.
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

    WHEN 'SETMESSAGE3'.
      MESSAGE S006 DISPLAY LIKE 'W' WITH '신선재 작업 지시되어 있습니다. 조장변경시 유의하세요.'.
    WHEN 'SETMESSAGE2'.
      IF GV_CHK_CONFIRM_6600_GO = ABAP_TRUE.
        MESSAGE S006 DISPLAY LIKE 'W' WITH '조장 구성으로 반제품 생산 계획이 수립되어 있습니다. 반제품 생산 계획을 확인하세요.'.
      ENDIF.
    WHEN 'SETMESSAGE'.
      MESSAGE I005 DISPLAY LIKE 'I' WITH '신선재 작업 지시되어 수정할 수 없습니다.'.
    WHEN 'DISP_MESSAGE'.
      APPEND INITIAL LINE TO GT_GUIDE_TEXT ASSIGNING FIELD-SYMBOL(<LV_GUIDE_TEXT>).
      UNASSIGN <LV_GUIDE_TEXT>.
      APPEND INITIAL LINE TO GT_GUIDE_TEXT ASSIGNING <LV_GUIDE_TEXT>.
      <LV_GUIDE_TEXT> = ' ★ 조장 작업전 확인 바랍니다.'.

      CALL FUNCTION 'ZGTPP_UTILL_DISP_WARNING'
        EXPORTING
          IV_TITLE = '안내사항'
        TABLES
          IT_TEXT  = GT_GUIDE_TEXT.


*      CALL FUNCTION 'ZGTPP_UTILL_TEXTEDIT'
*        EXPORTING
*          IV_MODE  = '1'
*          IV_TITLE = '안내사항'
*        CHANGING
*          CT_TEXT  = GT_GUIDE_TEXT.
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
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CLEAR GV_OK_CODE8.
  GV_OK_CODE8 = SY-UCOMM.

  CASE GV_OK_CODE8.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_DOCKING_0300->FREE.
      CLEAR : GO_DOCKING_0300, GO_CONTAIN_TOP_0300, GO_CONTAIN_0300.
      CLEAR : GO_DD_DOCU_0300, GO_GRID_0300.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      PERFORM CHECK_AND_CHANGE.
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
      CLEAR GS_DISP_ARBPL.
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
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.

  CLEAR GV_OK_CODE9.
  GV_OK_CODE9 = SY-UCOMM.

  CASE GV_OK_CODE9.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

      CALL METHOD GO_DOCKING_0400->FREE.
      FREE : GO_DOCKING_0400, GO_GRID_0400, GO_GRID_0401.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.


    WHEN 'CONFIRM'.
      CLEAR GV_ANSWER.
      PERFORM CHECK_0400 CHANGING GV_ANSWER.

      IF GV_ANSWER IS NOT INITIAL.
        RETURN.
      ENDIF.

      GV_CONTINUE_400 = ABAP_TRUE.

      CALL METHOD GO_DOCKING_0400->FREE.
      FREE : GO_DOCKING_0400, GO_GRID_0400, GO_GRID_0401.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

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
        MESSAGE I003 DISPLAY LIKE 'E' WITH 'Pegging 변경 할 오더를 선택해주세요.'(e57).
        RETURN.
      ENDIF.

      DATA(LT_CHK_PEGGING) = GT_PEGGING[].
      DELETE LT_CHK_PEGGING WHERE CHECK IS INITIAL.

      IF LINES( LT_CHK_PEGGING ) NE LINES( GT_ORIGN_2010 ).
        IF LINES( GT_ORIGN_2010 ) = 1.
          MESSAGE I003 DISPLAY LIKE 'E' WITH '복조장이 아닌 오더는 단일 조장만 선택가능합니다.'(e58).
        ELSE.
          MESSAGE I003 DISPLAY LIKE 'E' WITH '복조장은 같은 구성의 복조장만 선택가능합니다.'(e59).
        ENDIF.
        RETURN.
      ENDIF.

      SORT LT_CHK_PEGGING BY ORDNR.
      DELETE ADJACENT DUPLICATES FROM LT_CHK_PEGGING COMPARING ORDNR.
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
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.

  CLEAR GV_OK_CODE10.
  GV_OK_CODE10 = SY-UCOMM.

  CASE GV_OK_CODE10.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

      CALL METHOD GO_DOCKING_0400->FREE.
      FREE : GO_DOCKING_0400, GO_GRID_0400, GO_GRID_0401.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.


    WHEN 'CONFIRM'.
      CLEAR GV_ANSWER.
      PERFORM CHECK_0500 CHANGING GV_ANSWER.

      IF GV_ANSWER IS NOT INITIAL.
        RETURN.
      ENDIF.

      GV_CONTINUE_400 = ABAP_TRUE.

      CALL METHOD GO_DOCKING_0400->FREE.
      FREE : GO_DOCKING_0400, GO_GRID_0400, GO_GRID_0401.
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
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0600 INPUT.

  CLEAR GV_OK_CODE6.
  GV_OK_CODE6 = SY-UCOMM.

  CASE GV_OK_CODE6.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CONFIRM'.
      GO_CONTAINER_600->FREE( ).
      GO_TEXT_600->FREE( ).
      FREE : GO_CONTAINER_600, GO_TEXT_600.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
