*&---------------------------------------------------------------------*
*& Include          ZGTMMR4360O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  CLEAR GT_ECOMM.

  IF P_ELC = GC_X. "전기동
    GT_ECOMM = VALUE #( ( 'SO' ) ). "판매오더조회/등록 버튼 제거
  ENDIF.

  IF P_DISP = GC_X . "처리결과조회
    GT_ECOMM = VALUE #( ( 'POST' ) ( 'PO' ) ( 'SO' ) ).
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING GT_ECOMM.

  DATA LV_TEXT(20).
  LV_TEXT = COND #( WHEN P_SCR = GC_X AND P_GR = GC_X  THEN TEXT-T01
                                 WHEN P_SCR = GC_X AND P_DISP = GC_X  THEN TEXT-T02
                                 WHEN P_ELC = GC_X AND P_GR = GC_X THEN TEXT-T03
                                 WHEN P_ELC = GC_X AND P_DISP = GC_X THEN TEXT-T04
                                 ELSE TEXT-T05 ).

  SET TITLEBAR '0100' WITH LV_TEXT.

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
    PERFORM F_SET_ALV_EVENT_100.

    CASE GC_X.
      WHEN P_ELC.
        "전기동
        PERFORM F_SET_FCAT_100.
        PERFORM F_DISPLAY_ALV_100 TABLES GT_LIST GT_FCAT_100.
      WHEN P_SCR.
        "SCR
        PERFORM F_SET_FCAT_200.
        PERFORM F_DISPLAY_ALV_100 TABLES GT_SCR_LIST GT_FCAT_200.
      WHEN OTHERS.
    ENDCASE.

  ELSE.
    PERFORM F_REFRESH_ALV USING GO_GRID_100.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS '0300'.

  CLEAR LV_TEXT.
  LV_TEXT = COND #( WHEN GV_OKCODE_SCR = 'PO'  THEN TEXT-T06
                                 WHEN GV_OKCODE_SCR = 'SO'   THEN TEXT-T07
                                 ELSE TEXT-TT1 ).

  SET TITLEBAR '0300' WITH LV_TEXT.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module SET_SCREEN_ATTR_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_SCREEN_ATTR_0300 OUTPUT.

  LOOP AT SCREEN.
    CASE SCREEN-GROUP1.
      WHEN 'NEB'.
        IF GV_OKCODE_SCR = 'PO'.
          SCREEN-ACTIVE = 0.
        ELSE.
          SCREEN-ACTIVE = 1.
        ENDIF.

      WHEN 'EB'.
        IF GV_OKCODE_SCR = 'PO'.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.

      WHEN 'SO'.
        IF GV_OKCODE_SCR = 'SO'.
          SCREEN-ACTIVE = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.

      WHEN 'REV'.
        IF GV_OKCODE_SCR = 'REVE'.
          SCREEN-ACTIVE = 1.
          SCREEN-INPUT = 0.
        ELSEIF GV_OKCODE_SCR = 'POST'.
          SCREEN-ACTIVE = 1.
          SCREEN-INPUT = 1.
        ELSE.
          SCREEN-ACTIVE = 0.
        ENDIF.

    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.
