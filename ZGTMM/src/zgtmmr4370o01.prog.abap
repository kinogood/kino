*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR4370O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODULE SET_STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_STATUS_0100 OUTPUT.

  SET PF-STATUS '0100'.

  DATA LV_TEXT(10).
  LV_TEXT = COND #( WHEN RB_OEM = GC_X THEN TEXT-T01
                                 WHEN RB_DOWN = GC_X THEN TEXT-T02 ).

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

      CASE GV_UCOMM.
        WHEN 'METHOD'. "검사방법등록
          SCREEN-ACTIVE = COND #( WHEN SCREEN-GROUP1 = 'WAY' THEN 1  "활성
                                                    WHEN SCREEN-GROUP1 = 'DAT' OR SCREEN-GROUP1 = 'RST' THEN 0  ).
        WHEN 'SCHEDULE'. "출장검사일정등록
          SCREEN-ACTIVE = COND #( WHEN SCREEN-GROUP1 = 'WAY' OR SCREEN-GROUP1 = 'RST' THEN 0  "비활성
                                                    WHEN SCREEN-GROUP1 = 'DAT' THEN 1 ).
        WHEN 'RESULT'.  "검사결과등록
          SCREEN-ACTIVE = COND #( WHEN SCREEN-GROUP1 = 'WAY' OR SCREEN-GROUP1 = 'DAT' THEN 0  "비활성
                                                    WHEN SCREEN-GROUP1 = 'RST' THEN 1  ).
        WHEN OTHERS.
      ENDCASE.

      MODIFY SCREEN.
    ENDLOOP.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module SET_STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_STATUS_0200 OUTPUT.

   SET PF-STATUS 'PBO_0200'.
   SET TITLEBAR 'TITLE'.

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
    PERFORM SET_CELL_STYLE.
    PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
  ENDIF.

*  IF GV_BOTTOM = GC_X.
*    IF GCL_GRID_IT IS NOT BOUND .
*      PERFORM CREATE_ALV_300 USING GC_X.
*
*    ELSE.
*      PERFORM SET_CELL_STYLE.
*      PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.
*    ENDIF.
*  ENDIF.

ENDMODULE.
