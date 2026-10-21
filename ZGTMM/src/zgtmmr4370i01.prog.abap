*&---------------------------------------------------------------------*
*& Include          ZGTMMR4370I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  GV_OKCODE_SAVE = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE.

    WHEN 'BACK' OR 'CANC'.
       IF SY-DYNNR = '0200'.
          LEAVE TO SCREEN 0.
       ELSE.
         PERFORM RELEASE_ALV.
         LEAVE TO SCREEN 0.
       ENDIF.

    WHEN 'EXIT'.
      PERFORM RELEASE_ALV.
      LEAVE PROGRAM.

     WHEN OTHERS.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      MODULE  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CLEAR : GV_ERR.

  GV_OKCODE_SAVE2 = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_OKCODE_SAVE2.
    WHEN 'YES'.

      IF  RB_OEM = GC_X . "
        PERFORM SET_LIST_SAVE.
        PERFORM SET_CELL_STYLE.
        PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN 'NO'.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
