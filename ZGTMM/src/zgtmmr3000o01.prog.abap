*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3000O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODULE SET_STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_STATUS_0100 OUTPUT.

  SET PF-STATUS '0100'.

  DATA LV_TEXT(20).
**--> 26.09 *단순견적 - 추가
  LV_TEXT = COND #( WHEN P_PR = GC_X   THEN TEXT-T01
                    WHEN P_PR2 = GC_X   THEN TEXT-T01
                    WHEN P_CRE = GC_X THEN TEXT-T02  ELSE TEXT-T03 ).
  SET TITLEBAR '0100' WITH LV_TEXT.

ENDMODULE.
*&---------------------------------------------------------------------*
*& MODULE SET_STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_STATUS_0400 OUTPUT.

  SET PF-STATUS '0100'.
**--> 26.09 *단순견적 - 추가
  LV_TEXT = COND #( WHEN P_PR = GC_X   THEN TEXT-T01
                    WHEN P_PR2 = GC_X   THEN TEXT-T01
                    WHEN P_CRE = GC_X THEN TEXT-T02  ELSE TEXT-T03 ).
  SET TITLEBAR '0100' WITH LV_TEXT.

ENDMODULE.
*&---------------------------------------------------------------------*
*& MODULE SET_ALV_GRID_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_ALV_GRID_0100 OUTPUT.

  IF GCL_GRID IS NOT BOUND.
    PERFORM CREATE_ALV.

  ELSE.
    PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& MODULE SET_ALV_GRID_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_ALV_GRID_0400 OUTPUT.

  IF GCL_GRID_400 IS NOT BOUND.
    PERFORM CREATE_ALV_400.

  ELSE.
    PERFORM REFRESH_TABLE USING GCL_GRID_400 SPACE.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_SCREEN OUTPUT.

    LOOP AT SCREEN.

      CASE GV_UCOMM.
        WHEN 'CHANGE'.
          SCREEN-ACTIVE = COND #( WHEN SCREEN-GROUP1 = 'CHG' THEN 1  "활성
                                                    WHEN SCREEN-GROUP1 = 'MS' THEN 0 ).
        WHEN 'MASS'.
          SCREEN-ACTIVE = COND #( WHEN SCREEN-GROUP1 = 'CHG' THEN 0  "비활성
                                                    WHEN SCREEN-GROUP1 = 'MS' THEN 1  ).
        WHEN OTHERS.
      ENDCASE.

      MODIFY SCREEN.
    ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  SET PF-STATUS '0100' .
  SET TITLEBAR '0200' .

ENDMODULE.
