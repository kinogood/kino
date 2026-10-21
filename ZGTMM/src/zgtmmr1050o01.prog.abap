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
  LV_TEXT = COND #( WHEN P_DIS = GC_X   THEN TEXT-T01
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
*& Module SET_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_SCREEN OUTPUT.

    LOOP AT SCREEN.

      IF SCREEN-GROUP1 = 'CHG'.
         IF GV_OKCODE_SAVE = 'CHANGE'.  "구매그룹 변경
             SCREEN-ACTIVE = 1.  "활성(입력가능)
         ELSE.
             SCREEN-ACTIVE = 0.  "비활성(입력불가)
         ENDIF.
      ENDIF.

      IF SCREEN-GROUP1 = 'MS'.
         IF GV_OKCODE_SAVE = 'MASS'.  "업체일괄입력
             SCREEN-ACTIVE = 1.  "활성(입력가능)
         ELSE.
             SCREEN-ACTIVE = 0.  "비활성(입력불가)
         ENDIF.
      ENDIF.

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
