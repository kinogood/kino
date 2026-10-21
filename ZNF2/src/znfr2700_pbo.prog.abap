*&---------------------------------------------------------------------*
*& INCLUDE          ZNFR2700_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& MODULE STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& MODULE ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE ALV_0100 OUTPUT.
  DATA: LS_LAYO TYPE LVC_S_LAYO,
        LS_FCAT TYPE LVC_S_FCAT,
        LT_FCAT TYPE LVC_T_FCAT.

  IF GO_CONT IS NOT BOUND.

    "CONTAINER 생성
    GO_CONT = NEW #( CONTAINER_NAME = 'CONTAINER' ).

    "GRID 생성
    GO_GRID      = NEW #( I_PARENT = GO_CONT ) .

    "LAYOUT 설정
    LS_LAYO-COL_OPT    = ABAP_ON.
    LS_LAYO-CWIDTH_OPT = ABAP_ON.
    LS_LAYO-ZEBRA      = ABAP_ON.
    LS_LAYO-SEL_MODE   = 'A'.
    LS_LAYO-STYLEFNAME = 'CELLSTYL'.


    PERFORM SET_FCAT USING LS_FCAT LT_FCAT.
    PERFORM SET_EVENT.
    PERFORM EXCLUDE_FB_FUNCTION.

    GO_GRID->SET_TABLE_FOR_FIRST_DISPLAY(
      EXPORTING
        IS_VARIANT           = GS_VARIANT
        IS_LAYOUT            = LS_LAYO
        I_SAVE               = 'A'
*        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
      CHANGING
        IT_FIELDCATALOG      = LT_FCAT
        IT_OUTTAB            = GT_ALV ).
  ELSE.
    DATA: LS_STBL TYPE LVC_S_STBL.
    LS_STBL-ROW = 'X'.
    LS_STBL-COL = 'X'.

    "REFRESH
    GO_GRID->REFRESH_TABLE_DISPLAY(
      EXPORTING I_SOFT_REFRESH = 'X'
                IS_STABLE      = LS_STBL ).
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*& MODULE STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS '0200'.
  SET TITLEBAR '0200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& MODULE ALV_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE ALV_0200 OUTPUT.
  DATA: LS_LAYO2 TYPE LVC_S_LAYO,
        LS_FCAT2 TYPE LVC_S_FCAT,
        LT_FCAT2 TYPE LVC_T_FCAT,
        LS_SORT2 TYPE LVC_S_SORT.

  IF GO_CONT2 IS NOT BOUND.
    "CONTAINER 생성
    GO_CONT2 = NEW #( CONTAINER_NAME = 'CONTAINER2' ).

    "GRID 생성
    GO_GRID2 = NEW #( I_PARENT = GO_CONT2 ).

    "LAYOUT 설정
    LS_LAYO2-COL_OPT    = ABAP_ON.
    LS_LAYO2-CWIDTH_OPT = ABAP_ON.
    LS_LAYO2-ZEBRA      = ABAP_ON.
    LS_LAYO2-SEL_MODE   = 'A'.

    "SORT 설정
    LS_SORT2-FIELDNAME = 'CONNO'.
    LS_SORT2-UP        = 'X'.
    LS_SORT2-SUBTOT    = 'X'.
    APPEND LS_SORT2 TO GT_SORT2.

    PERFORM SET_FCAT2 USING LS_FCAT2 LT_FCAT2.
    PERFORM EXCLUDE_FB_FUNCTION_ALL.

    GO_GRID2->SET_TABLE_FOR_FIRST_DISPLAY(
      EXPORTING
        IS_LAYOUT = LS_LAYO2
      CHANGING
        IT_FIELDCATALOG = LT_FCAT2
        IT_SORT         = GT_SORT2
        IT_OUTTAB       = GT_ALV2 ).

  ELSE.
    "REFRESH
    GO_GRID2->REFRESH_TABLE_DISPLAY( EXPORTING IS_STABLE = LS_STBL ).
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& MODULE INIT_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_0200 OUTPUT.

  "스크린 필드 초기값 세팅
  READ TABLE GT_SELECTED INTO DATA(LS_SELECTED) INDEX 1.
  IF SY-SUBRC EQ 0.
    GV_ZPJNO = LS_SELECTED-ZPJNO.
    GV_ZPTXT = LS_SELECTED-ZPTXT.
    GV_KUNNR = LS_SELECTED-KUNNR.
    GV_NCUST = LS_SELECTED-NCUST.
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
*& Module INIT_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_0300 OUTPUT.

  "스크린 필드 초기값 세팅
  READ TABLE GT_SELECTED INTO LS_SELECTED INDEX 1.
  IF SY-SUBRC EQ 0.
    GV_ZPJNO = LS_SELECTED-ZPJNO.
    GV_ZPTXT = LS_SELECTED-ZPTXT.
    GV_KUNNR = LS_SELECTED-KUNNR.
    GV_NCUST = LS_SELECTED-NCUST.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module ALV_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE ALV_0300 OUTPUT.
  DATA: LS_LAYO3 TYPE LVC_S_LAYO,
        LS_FCAT3 TYPE LVC_S_FCAT,
        LT_FCAT3 TYPE LVC_T_FCAT,
        LS_SORT3 TYPE LVC_S_SORT.

  IF GO_CONT3 IS NOT BOUND.
    "CONTAINER 생성
    GO_CONT3 = NEW #( CONTAINER_NAME = 'CONTAINER3' ).

    "GRID 생성
    GO_GRID3 = NEW #( I_PARENT = GO_CONT3 ).

    "LAYOUT 설정
    LS_LAYO3-COL_OPT    = ABAP_ON.
    LS_LAYO3-CWIDTH_OPT = ABAP_ON.
    LS_LAYO3-ZEBRA      = ABAP_ON.
    LS_LAYO3-SEL_MODE   = 'A'.


    "SORT 설정
    LS_SORT3-FIELDNAME = 'CONNO'.
    LS_SORT3-UP        = 'X'.
    LS_SORT3-SUBTOT    = 'X'.
    APPEND LS_SORT3 TO GT_SORT3.

    PERFORM SET_FCAT3 USING LS_FCAT3 LT_FCAT3.
    PERFORM EXCLUDE_FB_FUNCTION_ALL.

    GO_GRID3->SET_TABLE_FOR_FIRST_DISPLAY(
      EXPORTING
        IS_LAYOUT = LS_LAYO2
      CHANGING
        IT_FIELDCATALOG = LT_FCAT3
        IT_SORT         = GT_SORT3
        IT_OUTTAB       = GT_ALV3 ).

  ELSE.
    "REFRESH
    GO_GRID3->REFRESH_TABLE_DISPLAY( EXPORTING IS_STABLE = LS_STBL ).
  ENDIF.


ENDMODULE.
