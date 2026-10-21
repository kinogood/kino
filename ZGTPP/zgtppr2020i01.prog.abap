*&---------------------------------------------------------------------*
*& Include          ZGTPPR2020I01
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
      CALL METHOD GO_CONTAIN_MERGE->FREE.
      FREE : GO_CONTAIN_MERGE, GO_GRID_MERGE.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'REFRESH'.
      PERFORM REFRESH.
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
      CALL METHOD GO_CONTAIN_DOCKING_0300->FREE.
      FREE : GO_CONTAIN_DOCKING_0300, GO_GRID_0300, GO_GRID_MERGE_301.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
    WHEN 'SETCHECK'.
      PERFORM SET_CHECK_BOX_GRID_0300.

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
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      PERFORM CHECK_AND_CREATE.

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

*  IF SY-SUBRC NE 0.
*    MESSAGE I003 WITH '유효하지 않은 생산자재 입니다'.
*
*  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0430  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0430 INPUT.

  CLEAR GV_OK_CODE7.
  GV_OK_CODE7 = SY-UCOMM.

  CASE GV_OK_CODE7.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      PERFORM CHECK_0430.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0440  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0440 INPUT.

  CLEAR GV_OK_CODE8.
  GV_OK_CODE8 = SY-UCOMM.

  CASE GV_OK_CODE8.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

*     종료
      CALL METHOD GO_CONTAIN_0440->FREE.
      FREE : GO_CONTAIN_0440, GO_GRID_0440.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
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
