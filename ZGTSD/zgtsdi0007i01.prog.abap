**&---------------------------------------------------------------------*
**& Include          ZGTSDI0001I01
**&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&      Module  EXIT  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE EXIT INPUT.
*  CLEAR : GV_SAVEOK.
*
*  GV_SAVEOK = GV_OKCODE.
*  CLEAR GV_OKCODE.
*
*  CASE GV_SAVEOK.
*    WHEN 'EXIT' OR 'CANC' OR 'CANL' OR 'BACK'.
*      CASE SY-DYNNR.
*        WHEN '0100'.
**          PERFORM FREE_OBJECT.
*
*        WHEN '0200'.
*
*      ENDCASE.
*
*      LEAVE TO SCREEN 0.
*
*  ENDCASE.
*ENDMODULE.
**&---------------------------------------------------------------------*
**&      Module  USER_COMMAND_0100  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE USER_COMMAND_0100 INPUT.
*
*  CLEAR : GV_SAVEOK.
*
*  GV_SAVEOK = GV_OKCODE.
*  CLEAR GV_OKCODE.
*
*  CASE GV_SAVEOK.
*    WHEN 'SEND'.
*    PERFORM SEND_IF_BATCHJOB.
*    WHEN 'R_SEND'.
*    PERFORM SEND_IF_BATCHJOB.
*  ENDCASE.
*
*ENDMODULE.
