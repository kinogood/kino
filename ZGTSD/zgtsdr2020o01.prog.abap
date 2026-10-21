*&---------------------------------------------------------------------*
*& Include          ZGTSDR2020O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  PERFORM SET_EXCLUDING_0100.
  SET PF-STATUS '0100' EXCLUDING GT_EXCLU1.
  SET TITLEBAR '0100' WITH GV_TITLE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_CONTROLS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_CONTROLS_0100 OUTPUT.
  IF GO_CCON1 IS INITIAL.
    PERFORM CREATE_CONTAINER_0200 USING GO_CCON1 'CONT0100_H'.

    PERFORM CREATE_ALV_0100_TOP USING GO_CCON1
                                      GO_GRID1.
  ENDIF.
  IF GO_CCON2 IS INITIAL.
    PERFORM CREATE_CONTAINER_0200 USING GO_CCON2 'CONT0100_I'.

    PERFORM CREATE_ALV_0100_BOT USING GO_CCON2
                                      GO_GRID2.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_CONTROLS_0120 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_CONTROLS_0120 OUTPUT.
*  PERFORM ALV_CONTROLS_0100_I.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_CONTROLS_0110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_CONTROLS_0110 OUTPUT.
*  PERFORM ALV_CONTROLS_0100_H.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  PERFORM SET_EXCLUDING_0200.
  SET PF-STATUS '0200' EXCLUDING GT_EXCLU2.
  SET TITLEBAR '0200' WITH GV_TITLE2.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_CONTROLS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_CONTROLS_0200 OUTPUT.
  PERFORM ALV_CONTROLS_0200.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module MODIFY_SCREEN_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE MODIFY_SCREEN_0200 OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 EQ 'G2'. "매출일자
      IF ZGTSDS1100-LOCK EQ GC_X.
        IF ZGTSDS1100-VBELN_VLSP IS NOT INITIAL.
          IF ZGTSDS1100-SPLIT EQ GC_C.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
          ENDIF.
        ELSE.
          IF ZGTSDS1100-KOSTK EQ GC_C.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
          ENDIF.
        ENDIF.

      ELSE.
        SCREEN-INPUT = 0.
      ENDIF.
    ENDIF.

    IF SCREEN-GROUP1 EQ 'G3'. "유보금액
      SCREEN-INPUT = 0.
*      IF ZGTSDS1100-LOCK EQ GC_X.
*        IF ZGTSDS1100-VBELN_VLSP IS NOT INITIAL.
*          IF ZGTSDS1100-SPLIT EQ GC_C.
*            SCREEN-INPUT = 0.
*          ELSE.
*            SCREEN-INPUT = 1.
*          ENDIF.
*        ELSE.
*          IF ZGTSDS1100-KOSTK EQ GC_C.
*            SCREEN-INPUT = 0.
*          ELSE.
*            SCREEN-INPUT = 1.
*          ENDIF.
*        ENDIF.
*      ELSE.
*        SCREEN-INPUT = 0.
*      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.
