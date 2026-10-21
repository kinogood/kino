*&---------------------------------------------------------------------*
*&  Include           LZNF2100O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_2000 OUTPUT.
  SET PF-STATUS '2000'.
  SET TITLEBAR  '2000'.
ENDMODULE.                 " STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MODIFY_SCREEN_2000 OUTPUT.

  CHECK SY-SUBRC EQ 0.

  LOOP AT SCREEN.

    CASE GV_READ.
      WHEN '1'. " 신규생성 : UPLOAD만 가능
        IF SCREEN-GROUP1 EQ 'GR1'.
          SCREEN-INPUT = 0.
          SCREEN-INVISIBLE = 1.
        ENDIF.
        IF SCREEN-GROUP1 EQ 'GR2'.
          SCREEN-INPUT = 1.
        ENDIF.
      WHEN '2'. " 조회 : DOWNLOAD만 가능
        IF SCREEN-GROUP1 EQ 'GR1'.
          SCREEN-INPUT = 1.
        ENDIF.
        IF SCREEN-GROUP1 EQ 'GR2'.
          SCREEN-INPUT = 0.
        ENDIF.
      WHEN '3'. " 수정 : DOWNLOAD & UPLOAD 가능

        IF GS_ZNFT1002-LINK1 IS INITIAL.
          IF SCREEN-NAME EQ 'BTN_DOWNLOAD_01'.
            SCREEN-INPUT = 0.
          ENDIF.
        ELSE.
          IF SCREEN-NAME EQ 'BTN_DOWNLOAD_01'.
            SCREEN-INPUT = 1.
          ENDIF.
        ENDIF.

        IF GS_ZNFT1002-LINK2 IS INITIAL.
          IF SCREEN-NAME EQ 'BTN_DOWNLOAD_02'.
            SCREEN-INPUT = 0.
          ENDIF.
        ELSE.
          IF SCREEN-NAME EQ 'BTN_DOWNLOAD_02'.
            SCREEN-INPUT = 1.
          ENDIF.
        ENDIF.

        IF GS_ZNFT1002-LINK3 IS INITIAL.
          IF SCREEN-NAME EQ 'BTN_DOWNLOAD_03'.
            SCREEN-INPUT = 0.
          ENDIF.
        ELSE.
          IF SCREEN-NAME EQ 'BTN_DOWNLOAD_03'.
            SCREEN-INPUT = 1.
          ENDIF.
        ENDIF.

        IF GS_ZNFT1002-LINK4 IS INITIAL.
          IF SCREEN-NAME EQ 'BTN_DOWNLOAD_04'.
            SCREEN-INPUT = 0.
          ENDIF.
        ELSE.
          IF SCREEN-NAME EQ 'BTN_DOWNLOAD_04'.
            SCREEN-INPUT = 1.
          ENDIF.
        ENDIF.

        IF GS_ZNFT1002-LINK5 IS INITIAL.
          IF SCREEN-NAME EQ 'BTN_DOWNLOAD_05'.
            SCREEN-INPUT = 0.
          ENDIF.
        ELSE.
          IF SCREEN-NAME EQ 'BTN_DOWNLOAD_05'.
            SCREEN-INPUT = 1.
          ENDIF.
        ENDIF.

*        IF SCREEN-GROUP1 EQ 'GR1'.
*          SCREEN-INPUT = 1.
*        ENDIF.
        IF SCREEN-GROUP1 EQ 'GR2'.
          SCREEN-INPUT = 1.
        ENDIF.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " MODIFY_SCREEN_2000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CLEAR_BUFFER_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CLEAR_BUFFER_2000 OUTPUT.
  CLEAR GV_FCODE.
ENDMODULE.                 " CLEAR_BUFFER_2000  OUTPUT
