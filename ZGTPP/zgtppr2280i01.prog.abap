*&---------------------------------------------------------------------*
*& Include          ZGTPPR2280I01
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

  IF NOT ( GV_CHK_GO_JOJANG = ABAP_TRUE OR GV_CHK_GO_HALF = ABAP_TRUE ).
* 표준조장가져와서 보여주기. 해당 자재의 만권량.
    PERFORM GET_MATNR_INFOR USING GS_MAKE_ORDER-MATNR CHANGING GS_MAKE_ORDER-INLENGTH.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0440  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0440 INPUT.

  CLEAR GV_OK_CODE4.
  GV_OK_CODE4 = SY-UCOMM.

  CASE GV_OK_CODE4.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CONFIRM'.

*     종료
      CALL METHOD GO_CONTAIN_0440->FREE.
      FREE : GO_CONTAIN_0440, GO_GRID_0440.
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
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.

  CLEAR GV_OK_CODE7.
  GV_OK_CODE7 = SY-UCOMM.

  CASE GV_OK_CODE7.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CONFIRM'.
      CALL METHOD GO_CONTAIN_0500->FREE.
      FREE : GO_CONTAIN_0500, GO_GRID_0500.
      FREE : GT_SORT_0500, GT_EXCLUDE_0500, GT_FIELDCAT_0500.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0600 INPUT.

  CLEAR GV_OK_CODE8.
  GV_OK_CODE8 = SY-UCOMM.

  CASE GV_OK_CODE8.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      PERFORM CHK_ADD_PROC.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0700 INPUT.

  CLEAR GV_OK_CODE9.
  GV_OK_CODE9 = SY-UCOMM.

  CASE GV_OK_CODE9.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      GO_CONTAINER_700->FREE( ).
      FREE : GO_CONTAINER_700, GO_TEXT_700.

      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      PERFORM CHECK_AND_CREATE_700.

  ENDCASE.

ENDMODULE.
