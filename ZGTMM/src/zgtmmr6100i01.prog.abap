*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001I01
*&---------------------------------------------------------------------*
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
      CASE SY-DYNNR.
        WHEN '0100'.
*          PERFORM FREE_OBJECT.

        WHEN '0200'.

      ENDCASE.

      LEAVE TO SCREEN 0.

  ENDCASE.
ENDMODULE.
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
    WHEN 'SAVE'.
      PERFORM SAVE_DATA.
    WHEN 'REF'.
      IF GT_CHG[] IS NOT INITIAL.
        GV_ANSWER = ZGTSD_CL_COMMON=>POPUP_TO_COMFIRM( IV_UCOMM = SPACE IV_MESSA = TEXT-M02 ).
        CHECK GV_ANSWER EQ ZGTSD_J.
      ENDIF.
      PERFORM DATA_QUERY.
      PERFORM REFRESH_TABLE_DISPLAY USING GO_GRID SPACE.
    WHEN 'COPY'. "공급업체 복사
      PERFORM PRCS_COPY.
  ENDCASE.

ENDMODULE.
