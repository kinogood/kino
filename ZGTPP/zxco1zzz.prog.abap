*&---------------------------------------------------------------------*
*& Include          ZXCO1ZZZ
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  CASE SY-TCODE.
    WHEN 'CO03'.
      LOOP AT SCREEN.
        IF SCREEN-GROUP1 = 'MOD'.
          SCREEN-INPUT = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN OTHERS.
      LOOP AT SCREEN.
        IF SCREEN-GROUP1 = 'MOD'.
          SCREEN-INPUT = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.

ENDMODULE.
