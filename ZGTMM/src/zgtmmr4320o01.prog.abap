*&---------------------------------------------------------------------*
*& Include          ZGTMMR4320O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  CLEAR GT_ECOMM.

  CASE ABAP_TRUE.
    WHEN P_TAR. "미완료를 선택 한 경우 이전취소 버튼 제거
      GT_ECOMM = VALUE #( ( 'REVE' ) ).
  ENDCASE.

  SET TITLEBAR '0100'.
  SET PF-STATUS '0100' EXCLUDING GT_ECOMM.

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
  SET PF-STATUS '0200'.
  SET TITLEBAR '0200'.
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
*    PERFORM F_SET_ALV_SORT_100.
    PERFORM F_DISPLAY_ALV_200.
  ELSE.
    PERFORM F_REFRESH_ALV USING GO_GRID_200.
  ENDIF.



ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS '0300'.
  SET TITLEBAR '0300'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module SET_SCREEN_ATTR_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_SCREEN_ATTR_0300 OUTPUT.

  LOOP AT SCREEN.
    CASE SCREEN-GROUP1.
      WHEN 'BUD'.
        IF GS_SCR-ZTEXT EQ TEXT-M02.
          SCREEN-INPUT = 0.
        ELSE.
          SCREEN-INPUT = 1.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.

  CASE ABAP_TRUE.
    WHEN P_ALL. "이전전기 처리인 경우 통문증 취소 제외
      GT_ECOMM = VALUE #( ( 'IVCA' ) ).
    WHEN P_COM. "조회인경우 이전처리 제외
      GT_ECOMM = VALUE #( ( 'POST' ) ).
  ENDCASE.

  SET PF-STATUS '0400' EXCLUDING GT_ECOMM.
  SET TITLEBAR '0400'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0400 OUTPUT.

  IF GO_CONT_400 IS INITIAL.
    PERFORM F_CREATE_ALV_OBJECT_400.
    PERFORM F_SET_EXCL_400.
    PERFORM F_SET_LAYO_400.
    PERFORM F_SET_VARI_400.
    PERFORM F_SET_FCAT_400.
    PERFORM F_SET_ALV_EVENT_400.
    PERFORM F_DISPLAY_ALV_400.

  ELSE.
    PERFORM F_REFRESH_ALV USING GO_GRID_400.
  ENDIF.

ENDMODULE.
