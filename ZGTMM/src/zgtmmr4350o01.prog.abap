*&---------------------------------------------------------------------*
*& Include          ZGTMMR4350O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR GT_ECOMM.
*>S.2026.07.07  '저장'버튼 조회 시에도 활성& 등록시 '조회<->변경'버튼 비활성 추가.
  IF P_DISP EQ ABAP_TRUE.
*    GT_ECOMM = VALUE #( ( 'BSAVE' ) ( 'BDOWN' ) ( 'BUPLO' ) ).
    GT_ECOMM = VALUE #( ( 'BDOWN' ) ( 'BUPLO' ) ).
  ENDIF.

  IF P_NEW EQ ABAP_TRUE.
    GT_ECOMM = VALUE #( ( 'CHANGE' ) ).
  ENDIF.
*<E.2026.07.07 ZGODEV04.

  SET PF-STATUS '0100' EXCLUDING GT_ECOMM.

  CASE ABAP_TRUE.
    WHEN P_NEW.
      SET TITLEBAR '0100' WITH TEXT-ST1. "공급업체 입고 실적 등록 - 원부자재
    WHEN P_DISP.
      SET TITLEBAR '0100' WITH TEXT-ST2. "공급업체 실적 조회 - 원부자재
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0100 OUTPUT.

  IF GO_CONT_100 IS INITIAL.
    PERFORM F_CREATE_ALV_OBJECT_100.
    PERFORM F_SET_EXCL_100.
    PERFORM F_SET_LAYO_100.
    PERFORM F_SET_VARI_100.
    PERFORM F_SET_FCAT_100.
    PERFORM F_SET_ALV_EVENT_100.
*    PERFORM F_SET_ALV_SORT_100.
    PERFORM F_DISPLAY_ALV_100.
  ELSE.
    PERFORM F_REFRESH_ALV USING GO_GRID_100.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  CLEAR GT_ECOMM.
*>S.2026.07.07  '저장'버튼 조회 시에도 활성& 등록시 '조회<->변경'버튼 비활성 추가.
  IF P_DISP EQ ABAP_TRUE.
*    GT_ECOMM = VALUE #( ( 'BSAVE' ) ( 'BDOWN' ) ( 'BUPLO' ) ).
    GT_ECOMM = VALUE #( ( 'BDOWN' ) ( 'BUPLO' ) ).
  ENDIF.

  IF P_NEW EQ ABAP_TRUE.
    GT_ECOMM = VALUE #( ( 'CHANGE' ) ).
  ENDIF.
*<E.2026.07.07 ZGODEV04.

  SET PF-STATUS '0200' EXCLUDING GT_ECOMM.

  CASE ABAP_TRUE.
    WHEN P_NEW.
      SET TITLEBAR '0200' WITH TEXT-ST3. "공급업체 입고 실적 등록 - 외주임가공
    WHEN P_DISP.
      SET TITLEBAR '0200' WITH TEXT-ST4. "공급업체 실적 조회 - 외주임가공
  ENDCASE.


ENDMODULE.

*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0200 OUTPUT.

  IF GO_CONT_200 IS INITIAL.
    PERFORM F_CREATE_ALV_OBJECT_200.
    PERFORM F_SET_EXCL_200.
    PERFORM F_SET_LAYO_200.
    PERFORM F_SET_VARI_200.
    PERFORM F_SET_FCAT_200.
    PERFORM F_SET_ALV_EVENT_200.
*    PERFORM F_SET_ALV_SORT_200.
    PERFORM F_DISPLAY_ALV_200.
  ELSE.
    PERFORM F_REFRESH_ALV USING GO_GRID_200.
  ENDIF.

ENDMODULE.
