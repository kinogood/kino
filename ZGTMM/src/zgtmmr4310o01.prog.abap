*&---------------------------------------------------------------------*
*& Include          ZGTMMR4310O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR GT_ECOMM.

  CASE ABAP_TRUE.
    WHEN P_SEND.
      GT_ECOMM = VALUE #( ( 'RSEND' ) ).
      SET TITLEBAR '0100' WITH TEXT-PT1. "공급업체 납품서 전송 관리
    WHEN P_ILOG.
      GT_ECOMM = VALUE #( ( 'SEND' ) ).
      SET TITLEBAR '0100' WITH TEXT-PT2. "Interface 처리 상태
  ENDCASE.

  SET PF-STATUS '0100' EXCLUDING GT_ECOMM.


ENDMODULE.

*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0100 OUTPUT.

  IF GO_CONT IS INITIAL.
    PERFORM F_CREATE_ALV_OBJECT.
    PERFORM F_SET_EXCL.
    PERFORM F_SET_LAYO.
    PERFORM F_SET_VARI.
    PERFORM F_SET_FCAT.
    PERFORM F_SET_ALV_EVENT.
    PERFORM F_SET_ALV_SORT.
    PERFORM F_DISPLAY_ALV.
  ELSE.

    PERFORM F_REFRESH_ALV USING GO_GRID_TOP.
    PERFORM F_REFRESH_ALV USING GO_GRID_MID.
    PERFORM F_REFRESH_ALV USING GO_GRID_BOT.
  ENDIF.


ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  CLEAR GT_ECOMM.

  CASE ABAP_TRUE.
    WHEN P_SEND.
      GT_ECOMM = VALUE #( ( 'RSEND' ) ).
      SET TITLEBAR '0200' WITH TEXT-PT3. "공급업체 라벨 전송 관리
    WHEN P_ILOG.
      GT_ECOMM = VALUE #( ( 'SEND' ) ).
      SET TITLEBAR '0200' WITH TEXT-PT2. "Interface 처리 상태
  ENDCASE.

  SET PF-STATUS '0200' EXCLUDING GT_ECOMM.

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
    PERFORM F_SET_ALV_SORT_200.
    PERFORM F_DISPLAY_ALV_200.
  ELSE.
    PERFORM F_REFRESH_ALV USING GO_GRID_200.
  ENDIF.

ENDMODULE.
