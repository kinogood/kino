*&---------------------------------------------------------------------*
*& Include          ZGTPPR2150I01
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
      CASE ABAP_TRUE.
        WHEN P_RAD01 OR P_RAD02.
          PERFORM GET_MAIN_DATA.
          CLEAR : GV_CHK_EXCUTE_100, GV_CHK_EXCUTE_103.
*        WHEN P_RAD02.
        WHEN P_RAD03.

          PERFORM GET_MAIN_DATA_03.
      ENDCASE.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
    WHEN 'WORKING'.
      IF GV_CHK_GAGONG = ABAP_TRUE.
        PERFORM PROC_WORKING_GAGONG_SINSUN.
      ELSE.
        PERFORM PROC_WORKING_SINSUN.
      ENDIF.
    WHEN 'WORKING3'.
      PERFORM PROC_WORKING_WAR_SINSUN.

    WHEN 'SETCHECK'.
      PERFORM SET_CHECK_BOX.
    WHEN 'ALLSEL'.
      PERFORM SET_CHECK_BOX_ALL USING 'X'.
    WHEN 'DESEL'.
      PERFORM SET_CHECK_BOX_ALL USING ''.
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

*      CALL FUNCTION 'DEQUEUE_EZGT_ZGTPPR2010'
*          EXPORTING
*            GRPNR = GV_GRPNR.

*     종료
      CALL METHOD GO_DOCKING_CONTAINER->FREE.
      FREE : GO_DOCKING_CONTAINER, GO_SPLITTER, GO_SPLIT_CONTAINER, GO_SPLITTER2,
               GO_CONTAIN_0101, GO_GRID_0101,
               GO_CONTAIN_0102, GO_GRID_0102,
               GO_CONTAIN_0103, GO_GRID_0103,
               GO_CONTAIN_0104, GO_GRID_0104.

      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'REFRESH'.
      CLEAR GV_CHK_EXCUTE_103.
      REFRESH GT_MAINTAIN_LENGTH.
      PERFORM SET_SPLITER_HEIGHT.

    WHEN 'SET'.
      IF GS_HEADER_200-SOSUNCD IS INITIAL.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '소선코드를 먼저 선택해 주세요.'.
        RETURN.
      ENDIF.
      REFRESH : GT_MAIN_DISP_103.
      IF <GT_MAIN_DISP_104> IS ASSIGNED.
        REFRESH <GT_MAIN_DISP_104>.
      ENDIF.
      REFRESH GT_MAINTAIN_LENGTH.
      GV_CHK_EXCUTE_103 = ABAP_TRUE.
      PERFORM SET_SPLITER_HEIGHT.

      PERFORM SET_ITAB_103.
      PERFORM REFRESH_GRID USING GO_GRID_0103.
      PERFORM SET_ITAB_104.
      IF GO_GRID_0104 IS BOUND.
        PERFORM REFRESH_GRID USING GO_GRID_0104.
      ENDIF.

    WHEN 'CHG'.
      PERFORM SET_ZTWSEQ.

    WHEN 'CHG_AB'.
      IF GS_HEADER_200-ARBPL NE GS_HEADER_200-ARBPL2.
        GS_HEADER_200-ARBPL2 = GS_HEADER_200-ARBPL.
      ENDIF.

      IF GO_GRID_0104 IS BOUND.
        PERFORM REFRESH_GRID USING GO_GRID_0104.
      ENDIF.
    WHEN 'SETCHECK'.
*      여장변경시 재계산 추가
      PERFORM SET_CHANG_MENGE02.

  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  DROPDOWN_SOSUNCD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DROPDOWN_SOSUNCD INPUT.

  PERFORM DROPDOWN_SOSUNCD.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0201  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0201 INPUT.

  CLEAR GV_OK_CODE3.
  GV_OK_CODE3 = SY-UCOMM.

  CASE GV_OK_CODE3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_CONTAIN_0201->FREE.
      FREE : GO_CONTAIN_0201, GO_GRID_0201.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

    WHEN 'CONFIRM'.
      GV_CHK_CONFIRM_201 = ABAP_TRUE.
      CALL METHOD GO_CONTAIN_0201->FREE.
      FREE : GO_CONTAIN_0201, GO_GRID_0201.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1100 INPUT.

  CLEAR GV_OK_CODE5.
  GV_OK_CODE5 = SY-UCOMM.

  CASE GV_OK_CODE5.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_DOCKING_1100->FREE.
      FREE : GO_DOCKING_1100, GO_SPLITTER_1100, GO_SPLITTER_1100_TOP,
               GO_CONTAIN_1100_TOP, GO_CONTAIN_1100, GO_GRID_1100,
               GO_CONTAIN_1101, GO_GRID_1101, GO_CONTAIN_1102,
               GO_GRID_1102, GO_CONTAIN_1103, GO_GRID_1103,
               GO_CONTAIN_1200, GO_GRID_1200.

      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'REFRESH'.
*  입력수량부분 초기화
      REFRESH GT_1101_MENGE.

      PERFORM SET_ITAB_1100.
      PERFORM SET_ITAB_1101.
      PERFORM SET_ITAB_1102.

      IF <GT_MAIN_DISP_1103> IS ASSIGNED.
        REFRESH <GT_MAIN_DISP_1103>.
      ENDIF.
      PERFORM SET_ITAB_1103.

      PERFORM REFRESH_GRID USING GO_GRID_1100.
      PERFORM REFRESH_GRID USING GO_GRID_1101.
      PERFORM REFRESH_GRID USING GO_GRID_1102.
      PERFORM REFRESH_GRID USING GO_GRID_1103.

    WHEN 'CAL1100'.

      PERFORM CHANGE_ITAB_1102.
      PERFORM REFRESH_GRID USING GO_GRID_1102.
      IF <GT_MAIN_DISP_1103> IS ASSIGNED.
        REFRESH <GT_MAIN_DISP_1103>.
      ENDIF.
      PERFORM SET_ITAB_1103.
      PERFORM REFRESH_GRID USING GO_GRID_1103.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.

  CLEAR GV_OK_CODE6.
  GV_OK_CODE6 = SY-UCOMM.

  CASE GV_OK_CODE6.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_CONTAIN_0400->FREE.
      FREE : GO_CONTAIN_0400, GO_SPLITTER_0400, GO_SPLITTER_0401, GO_SPLIT_CONTAINER_0401,
               GO_CONTAIN_0401, GO_GRID_0401,
               GO_CONTAIN_0402, GO_GRID_0402,
               GO_CONTAIN_0403, GO_GRID_0403,
               GO_CONTAIN_0404, GO_GRID_0404.

      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'REFRESH'.
      PERFORM REFRESH_400.

    WHEN 'CHG'.
      PERFORM SET_ZTWSEQ_400.
    WHEN 'SETCHECK'.
      PERFORM CAL_404.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1200 INPUT.

  CLEAR GV_OK_CODE8.
  GV_OK_CODE8 = SY-UCOMM.

  CASE GV_OK_CODE8.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_CONTAIN_1200->FREE.
      FREE : GO_CONTAIN_1200, GO_GRID_1200.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

    WHEN 'CONFIRM'.
      GV_CHK_CONFIRM_1200 = ABAP_TRUE.
      CALL METHOD GO_CONTAIN_1200->FREE.
      FREE : GO_CONTAIN_1200, GO_GRID_1200.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1300 INPUT.

  CLEAR GV_OK_CODE9.
  GV_OK_CODE9 = SY-UCOMM.

  CASE GV_OK_CODE9.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_DOCKING_1300->FREE.
      FREE : GO_SPLITTER_1300, GO_SPLITTER_1300_UNDER, GO_CONTAIN_1300_UNDER,
               GO_CONTAIN_1300, GO_GRID_1300, GO_CONTAIN_1301,
               GO_GRID_1301, GO_CONTAIN_1302, GO_GRID_1302.

      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      CLEAR GV_CHK_CONFIRM_1300.
      PERFORM CHECK_BEFORE_CRT_PO.


  ENDCASE.

ENDMODULE.
