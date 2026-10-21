*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3000O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODULE SET_STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_STATUS_0100 OUTPUT.

  CLEAR GT_EX.

  IF P_SCRP = GC_X. "폐기처리
    GT_EX = VALUE #( ( 'SCR_CANC' ) ). 	"재고폐기취소 버튼 제외
  ENDIF.

  IF P_DISP = GC_X. "처리결과조회
    GT_EX = VALUE #( ( 'SCRAP' ) ). "재고폐기처리 버튼 제외
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING GT_EX.

  DATA LV_TEXT(20).
  LV_TEXT = COND #( WHEN P_DISP = GC_X   THEN TEXT-T01
                                 WHEN P_SCRP = GC_X THEN TEXT-T02  ELSE TEXT-T03 ).
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

      IF SCREEN-GROUP1 = 'SCR'. "폐기사유
         IF GV_OKCODE_SAVE = 'SCRAP'.  "폐기처리
             SCREEN-ACTIVE = 1.  "활성(입력가능)
         ELSE.
             SCREEN-ACTIVE = 0.  "비활성(입력불가)
         ENDIF.
      ENDIF.

      IF SCREEN-GROUP1 = 'DAT'. "전기일자
         IF GV_OKCODE_SAVE = 'SCRAP'.  "폐기처리
             SCREEN-INPUT = 1.  "활성(입력가능)
         ELSE.
             SCREEN-INPUT = 0.  "비활성(입력불가)
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

  CLEAR GT_EX.
  GT_EX = VALUE #( ( 'REFRESH' )
                               ( 'SCRAP' )
                               ( 'SCR_CANC' ) ).

  SET PF-STATUS '0100' EXCLUDING GT_EX.
  SET TITLEBAR '0200' .

ENDMODULE.
