*&---------------------------------------------------------------------*
*&  Include           ZNFR2640I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CLEAR : GV_CODE.
  GV_CODE = OK_CODE.
  CLEAR : OK_CODE.

  CASE SY-UCOMM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1100 INPUT.

  CLEAR : GV_CODE.
  GV_CODE = OK_CODE.
  CLEAR : OK_CODE.

  CASE GV_CODE.
    WHEN 'ORDER_V'.
      PERFORM CREATE_CONNO_ITAB USING GV_ERROR.
      CHECK GV_ERROR IS INITIAL.
      PERFORM DATA_SELECT_V.
      IF GT_OUTTAB_V IS NOT INITIAL AND LINES( GT_OUTTAB_V ) GT 0.
        CALL SCREEN 1200.
      ELSE.
        MESSAGE S383(ME).
      ENDIF.
    WHEN 'ORDER_Z'.
      PERFORM CREATE_CONNO_ITAB USING GV_ERROR.
      CHECK GV_ERROR IS INITIAL.
      PERFORM DATA_SELECT_Z.
      IF GT_OUTTAB_Z IS NOT INITIAL AND LINES( GT_OUTTAB_Z ) GT 0.
        CALL SCREEN 1200.
      ELSE.
        MESSAGE S383(ME).
      ENDIF.
    WHEN 'ASEL' OR 'DSEL'.
      PERFORM SELECT_ALL.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1100  INPUT

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ALL .

  DATA: LV_INDEX TYPE SY-TABIX.

  CLEAR LV_INDEX.
  LOOP AT GT_OUTTAB INTO GS_OUTTAB.
    LV_INDEX = SY-TABIX.
    IF GV_CODE EQ 'ASEL'.
      GS_OUTTAB-CHECK = 'X'.
    ELSE.
      CLEAR GS_OUTTAB-CHECK.
    ENDIF.
    MODIFY GT_OUTTAB FROM GS_OUTTAB INDEX LV_INDEX TRANSPORTING CHECK.
  ENDLOOP.

ENDFORM.                    " SELECT_ALL

*&---------------------------------------------------------------------*
*&      Module  EXIT_1200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_1200 INPUT.

  CLEAR : GV_CODE.
  GV_CODE = OK_CODE.
  CLEAR : OK_CODE.

  PERFORM REFRESH_SCR1200.

  CASE GV_CODE.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " EXIT_1200  INPUT
