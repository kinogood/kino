*&---------------------------------------------------------------------*
*&  Include           ZGTSDR1080_PAI                                   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  save_okcode  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SAVE_OKCODE INPUT.

  S_OK_CODE = OK_CODE.
  CLEAR OK_CODE.

ENDMODULE.                 " save_okcode  INPUT


*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE S_OK_CODE.

    WHEN 'BACK'.
      IF LCL_ALV_GRID=>F_ALV = '1'.
        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE.                 " user_command_0100  INPUT


*&---------------------------------------------------------------------*
*&      Module  user_command_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE S_OK_CODE.

    WHEN 'OKAY'.
      LEAVE TO SCREEN 0.

    WHEN 'CANC'.
      G_FLAG = 'X'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " user_command_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CLEAR S_OK_CODE.
  S_OK_CODE = OK_CODE.

  CLEAR OK_CODE.

  CASE S_OK_CODE.

    WHEN 'F_ALL'.  "일괄적용
      PERFORM MULTI_INPUT.

    WHEN 'OKAY'.

      PERFORM SAVE_PROCESS.

      CHECK GV_CFLAG = 'Y'.
      PERFORM FREE_OBJ.
      LEAVE TO SCREEN 0.

    WHEN 'CANC'.
      GV_CFLAG = 'N'.
      PERFORM FREE_OBJ.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.
  CLEAR S_OK_CODE.
  S_OK_CODE = OK_CODE.

  CLEAR: OK_CODE, GV_CFLAG.

  CASE S_OK_CODE.

    WHEN 'OK'.
      GV_CFLAG = 'Y'.
      PERFORM FREE_OBJ2.
      REFRESH: GT_T0400.
      LEAVE TO SCREEN 0.

  ENDCASE.
ENDMODULE.
