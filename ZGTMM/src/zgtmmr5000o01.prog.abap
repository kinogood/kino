*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3000O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODULE SET_STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_STATUS_0100 OUTPUT.

  CLEAR GT_ECOMM.

  CASE ABAP_TRUE.
    WHEN P_INV. "송장처리
      GT_ECOMM = VALUE #( ( 'REVERS' )
                                           ( 'REQ_PAY' )
                                           ( 'MAPPING' )
                                           ( 'DE_MAPPING' ) ).
    WHEN P_DIS. "현황조회/지급요청
      GT_ECOMM = VALUE #( ( 'INVOICE' )
                                           ( 'MIRO' )
                                           ( 'TAX' ) ).
  ENDCASE.
  SET PF-STATUS '0100' EXCLUDING GT_ECOMM.

  DATA LV_TEXT(20).
  LV_TEXT = COND #( WHEN P_INV = GC_X   THEN TEXT-T01
                                 WHEN P_DIS = GC_X THEN TEXT-T02 ).
  SET TITLEBAR '0100' WITH LV_TEXT.

ENDMODULE.
*&---------------------------------------------------------------------*
*& MODULE SET_ALV_GRID_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_ALV_GRID_0100 OUTPUT.

  IF GCL_GRID_HD IS NOT BOUND.
    PERFORM CREATE_ALV.

  ELSE.
    PERFORM REFRESH_TABLE USING GCL_GRID_HD SPACE.
    PERFORM REFRESH_TABLE USING GCL_GRID_IT SPACE.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_SCREEN OUTPUT.

    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'RS'.
        IF GV_OKCODE_SAVE = 'REVERS'.  "역분개
          SCREEN-ACTIVE = 1.  "활성(입력가능)
        ELSE.
          SCREEN-ACTIVE = 0.  "비활성(입력불가)
        ENDIF.
      ENDIF.

      IF SCREEN-GROUP1 = 'EX'.
        IF GV_OKCODE_SAVE = 'REVERS'.  "역분개
          SCREEN-ACTIVE = 0.  "비활성(입력불가)
        ELSE.
          SCREEN-ACTIVE = 1.  "활성(입력가능)
        ENDIF.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  SET PF-STATUS '0200' .

  CLEAR LV_TEXT.
  LV_TEXT = COND #( WHEN SY-DYNNR = '0200' THEN TEXT-T04  "확인
                                 WHEN SY-DYNNR = '0400' THEN TEXT-T09 ).  "세금계산서

  SET TITLEBAR '0200' WITH LV_TEXT.

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
*& Module SET_ALV_GRID_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_ALV_GRID_0400 OUTPUT.

  IF GCL_GRID_TAX IS NOT BOUND.
    PERFORM CREATE_ALV_400.
  ELSE.
    PERFORM REFRESH_TABLE USING GCL_GRID_TAX SPACE.
  ENDIF.

ENDMODULE.
