*&---------------------------------------------------------------------*
*& INCLUDE          ZGTFIR4003O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODULE SET_STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_STATUS_0100 OUTPUT.

  SET PF-STATUS '0100'.

  DATA LV_TEXT(8).
  LV_TEXT = COND #( WHEN RB_RCV = GC_X THEN TEXT-T01
                                 WHEN RB_MNG = GC_X THEN TEXT-T02 ELSE TEXT-R04 ).

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
*& Module SET_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_SCREEN OUTPUT.

    LOOP AT SCREEN.

      IF GV_OKCODE_SAVE = 'REASON'. "반려사유
        SCREEN-ACTIVE = COND #( WHEN SCREEN-GROUP1 = 'GR' THEN 0  "비활성
                                                  WHEN SCREEN-GROUP1 = 'RJT' THEN 1  ).
      ENDIF.

      CASE GV_UCOMM.
        WHEN 'DRGR' OR 'GRCANC'. "직송입고처리/입고취소
          SCREEN-ACTIVE = COND #( WHEN SCREEN-GROUP1 = 'GR' THEN 1  "활성
                                                    WHEN SCREEN-GROUP1 = 'RJT' THEN 0 ).
        WHEN 'RJT' . "반려
          SCREEN-ACTIVE = COND #( WHEN SCREEN-GROUP1 = 'GR' THEN 0  "비활성
                                                    WHEN SCREEN-GROUP1 = 'RJT' THEN 1  ).
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
MODULE STATUS_0200 OUTPUT.

   SET PF-STATUS 'PBO_0200'.
   SET TITLEBAR 'TITLE'.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.

  CL_GUI_CFW=>FLUSH( ).
  SET PF-STATUS '0300'.

  LV_TEXT = COND #( WHEN RB_RCV = GC_X THEN TEXT-T01
                                 WHEN RB_MNG = GC_X THEN TEXT-T02 ELSE TEXT-R04 ).

  SET TITLEBAR '0100' WITH LV_TEXT.

ENDMODULE.
*&---------------------------------------------------------------------*
*& MODULE SET_ALV_GRID_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_ALV_GRID_0300 OUTPUT.

  IF GCL_GRID_HD IS NOT BOUND.
    PERFORM CREATE_ALV_300.
  ELSE.
    PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
    PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*& MODULE SET_ALV_GRID_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_ALV_GRID_0400 OUTPUT.

  IF GCL_GRID_GRHD IS NOT BOUND.
    PERFORM CREATE_ALV_400 .
  ELSE.
    PERFORM REFRESH_TABLE USING GCL_GRID_GRHD SPACE.
    PERFORM REFRESH_TABLE USING GCL_GRID_GRIT SPACE.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*& MODULE SET_ALV_GRID_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_ALV_GRID_0500 OUTPUT.

  IF GCL_GRID_TR IS NOT BOUND.
    PERFORM CREATE_ALV_500 .
  ELSE.
    PERFORM REFRESH_TABLE USING GCL_GRID_TR SPACE.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0500 OUTPUT.
  SET PF-STATUS '0500'.
  SET TITLEBAR '0500' .
ENDMODULE.
