*&---------------------------------------------------------------------*
*& Include          ZGTMMR1100I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE.

    WHEN 'BACK' OR 'CANC'.
       PERFORM RELEASE_ALV.
       LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      PERFORM RELEASE_ALV.
      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE EXIT_0200 INPUT.

  GV_OKCODE_SAVE2 = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE2.

    WHEN 'BACK' OR 'CANC' OR  'EXIT'.
       LEAVE TO SCREEN 0.

    WHEN OTHERS.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CLEAR : GV_OKCODE_SAVE2 , GV_ERR.

  GV_OKCODE_SAVE2 = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE2.
    WHEN 'YES'.

      IF GV_UCOMM = 'ALL'.
          PERFORM SET_ONCE_PRICE.
      ENDIF.

      PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
      LEAVE TO SCREEN 0.

    WHEN 'NO'.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
