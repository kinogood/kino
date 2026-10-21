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

  DATA LV_TEXT(7).
  LV_TEXT = COND #( WHEN P_PUR = ZGTFI_X THEN TEXT-T01
                                 WHEN P_QUL = ZGTFI_X THEN TEXT-T02  ELSE TEXT-T03 ).
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
    CLEAR GV_CNT.
    DESCRIBE TABLE GT_LIST LINES GV_CNT.
    GS_LAYOUT-GRID_TITLE = TEXT-T04 && GV_CNT.

    PERFORM REFRESH_TABLE USING GCL_GRID SPACE.

  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*& MODULE MODIFY_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE MODIFY_SCREEN OUTPUT.

*  LOOP AT SCREEN.
*    IF GV_300GB <> 2 AND SCREEN-GROUP1 = 'BLT'.
*      SCREEN-ACTIVE = 0.
*    ELSEIF GV_300GB = 2 AND SCREEN-GROUP1 = 'BLT'.
*      SCREEN-INPUT = 0.
*    ENDIF.
*
*    MODIFY SCREEN.
*  ENDLOOP.

ENDMODULE.
