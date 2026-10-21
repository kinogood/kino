*&---------------------------------------------------------------------*
*& Include          ZGTSDR1160O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100' WITH GV_TITLE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_CONTROLS OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_CONTROLS OUTPUT.
  PERFORM CREATE_CONTROLS.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CHANGE_SCREEN_ATTR_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CHANGE_SCREEN_ATTR_0100 OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-GROUP4 EQ 'ZG1'.
      CASE GS_HEAD-ZZLABEL_TYPE.
        WHEN GC_1.
          SCREEN-INPUT = 1.
        WHEN GC_2.
          SCREEN-INPUT = 1.
        WHEN GC_3.
          SCREEN-INPUT = 1.
        WHEN GC_4.
          SCREEN-INPUT = 1.
        WHEN OTHERS.
          SCREEN-INPUT = 0.
      ENDCASE.
    ENDIF.

    IF SCREEN-GROUP4 EQ 'ZG2'.
      CASE GS_HEAD-ZZLABEL_TYPE.
        WHEN GC_2.
          SCREEN-INPUT = 1.
        WHEN GC_3.
          SCREEN-INPUT = 1.
        WHEN GC_4.
          SCREEN-INPUT = 1.

        WHEN OTHERS.
          SCREEN-INPUT = 0.
      ENDCASE.

    ENDIF.

    IF SCREEN-GROUP4 EQ 'ZG3'.
      CASE GS_HEAD-ZZLABEL_TYPE.

        WHEN GC_3.
          SCREEN-INPUT = 1.
        WHEN GC_4.
          SCREEN-INPUT = 1.

        WHEN OTHERS.
          SCREEN-INPUT = 0.
      ENDCASE.

    ENDIF.

    IF SCREEN-GROUP4 EQ 'ZG4'.
      CASE GS_HEAD-ZZLABEL_TYPE.


        WHEN GC_4.
          SCREEN-INPUT = 1.

        WHEN OTHERS.
          SCREEN-INPUT = 0.
      ENDCASE.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.
