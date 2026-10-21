*&---------------------------------------------------------------------*
*& Include          ZGTPPR2330F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  PERFORM USER_COMMAND_EXIT.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_100 INPUT.

  CASE GV_OKCODE.
    WHEN GC_FCODE-BACK OR GC_FCODE-EXIT. "// Back, Exit.
      PERFORM USER_COMMAND_EXIT.

    WHEN GC_FCODE-CHANGE.                "// 드럼 지정 변경.
      PERFORM USER_COMMAND_CHANGE.
  ENDCASE.

  CLEAR GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CLEAR GV_OKCODE2.
  GV_OKCODE2 = SY-UCOMM.

  CASE GV_OKCODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CALL METHOD GO_DOCKING_0200->FREE.
      FREE : GO_DOCKING_0200, GO_SPLITTER_0200.
      FREE : GO_CONTAIN_0200, GO_GRID_0200.
      FREE : GO_CONTAIN_0201, GO_GRID_0201.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

    WHEN 'SET_CHK'.
      PERFORM SET_CHK.
    WHEN 'ALL_DRUM'. "드럼구분일괄변경
      PERFORM SET_ALL_DRUM.
    WHEN 'AUTO_DRUM'. "드럼자동지정
      PERFORM SET_AUTO_DRUM.
    WHEN 'CHK_DRUM'. " 가능드럼확인
      PERFORM DISP_CHK_DRUM.
    WHEN 'SET_DRUM'. " 드럼지정
      PERFORM PROC_SET_DRUM.
    WHEN 'SAVE'. "변경사항등록
      IF P_PR = ABAP_TRUE.
        PERFORM PROC_SAVE_PR.
      ELSEIF P_PURORD = ABAP_TRUE.
        PERFORM PROC_SAVE_PO.
      ELSE.
        PERFORM PROC_SAVE.
      ENDIF.
    WHEN 'CECHK201'.
      PERFORM SET_CHECK_SCREEN_201..
  ENDCASE.

ENDMODULE.
