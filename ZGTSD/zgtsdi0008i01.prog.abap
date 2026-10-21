**&---------------------------------------------------------------------*
**& Include          ZGTSDI0001I01
**&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
*
*  __CLE : GT_FCODE.
*  CASE GC_X.
*    WHEN RB_DISP.
*      APPEND 'SEND' TO GT_FCODE.
*    WHEN RB_SEND.
*      APPEND 'R_SEND' TO GT_FCODE.
*  ENDCASE.
  SET PF-STATUS '0100' .
  SET TITLEBAR '0100' .

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_OBJECT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_OBJECT OUTPUT.

  CHECK GO_CON IS NOT BOUND.

  "Create Object
  PERFORM INIT_ALV_0100 CHANGING GO_CON
                                 GO_GRID.

  "Alv 구성
  PERFORM SET_ATTRIBUTES_0100.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR : GV_SAVEOK.

  GV_SAVEOK = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_SAVEOK.
    WHEN 'SEND'.
    PERFORM send_data.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  CLEAR : GV_SAVEOK.

  GV_SAVEOK = GV_OKCODE.
  CLEAR GV_OKCODE.

  CASE GV_SAVEOK.
    WHEN 'EXIT' OR 'CANC' OR 'CANL' OR 'BACK'.


      LEAVE TO SCREEN 0.

  ENDCASE.
ENDMODULE.
