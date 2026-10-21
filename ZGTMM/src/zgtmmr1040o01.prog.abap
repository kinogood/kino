*&---------------------------------------------------------------------*
*& Include          ZGTMMR1040O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR GT_ECOMM[].

  IF P_NEW EQ ABAP_TRUE.
    GT_ECOMM = VALUE #( ( 'CONV' ) ).
  ENDIF.

  IF GV_EDIT NE ABAP_TRUE.
    GT_ECOMM = VALUE #( BASE GT_ECOMM ( 'SAVE' ) ).
    GT_ECOMM = VALUE #( BASE GT_ECOMM ( 'BSAVE' ) ).
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING GT_ECOMM.

*P_SIZE = 'X' & P_NEW = 'X'인 경우 --> 규격 단가 신규 등록
*P_SIZE = 'X' & P_LOAD = 'X'인 경우 --> 규격 단가 조회/수정
  CASE ABAP_TRUE.
    WHEN P_NEW.
      SET TITLEBAR '0100 ' WITH TEXT-TT2.
    WHEN P_LOAD.
      SET TITLEBAR '0100 ' WITH TEXT-TT3.
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

  CLEAR GT_ECOMM[].

  IF P_NEW EQ ABAP_TRUE OR P_LOAD EQ ABAP_TRUE
    OR P_AUTO EQ ABAP_TRUE.   "2026.05.27 신규 자재 자동 등록 추가
    GT_ECOMM = VALUE #( ( 'CONV' ) ).
  ELSE.
    SELECT DISTINCT
      ZZ~LIFNR,
      ZZ~ZYEAR
      FROM @GT_DRUM AS ZZ
      INTO TABLE @DATA(LT_KEY).
    IF LINES( LT_KEY ) GT 1.
      "공급업체/연도가 여러개인 경우 비활성화
      GT_ECOMM = VALUE #( ( 'CONV' ) ).
    ENDIF.
  ENDIF.

  IF GV_EDIT NE ABAP_TRUE.
    GT_ECOMM = VALUE #( BASE GT_ECOMM ( 'SAVE' ) ).
    GT_ECOMM = VALUE #( BASE GT_ECOMM ( 'BSAVE' ) ).
  ENDIF.

  SET PF-STATUS '0200' EXCLUDING GT_ECOMM.

*P_DRUM = 'X' & P_NEW = 'X'인 경우 --> 드럼 단가 등록
*P_DRUM = 'X' & P_LOAD = 'X'인 경우 --> 드럼 단가 등록 (이전연도 참조)
  CASE ABAP_TRUE.
    WHEN P_NEW.
      SET TITLEBAR '0200 ' WITH TEXT-TT5.
    WHEN P_LOAD.
      SET TITLEBAR '0200 ' WITH TEXT-TT6.
    WHEN P_AUTO.  "2026.05.27 신규드럼 자동 드럼 추가
      SET TITLEBAR '0200 ' WITH TEXT-TT8.
    WHEN P_DISP.
      SET TITLEBAR '0200 ' WITH TEXT-TT7.
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
