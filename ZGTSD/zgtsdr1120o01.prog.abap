*&---------------------------------------------------------------------*
*& Include          ZSDR1005_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

*{ ZLSGSD4_23.10.23 - s
  DATA : F_CODE TYPE TABLE OF SY-UCOMM. "ZLSGSD4_23.10.23

  IF P_R1 EQ 'X'.
    F_CODE = VALUE #( ( 'SETMT_DEL' ) ).
   ELSEIF P_R2 EQ 'X'.
    F_CODE = VALUE #( ( 'SETMT' ) ).
  ENDIF.

*  SET PF-STATUS 'S100'.
  SET PF-STATUS 'S100' EXCLUDING F_CODE.
*} ZLSGSD4_23.10.23 - e
  SET TITLEBAR  'T100'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_ALV OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE DISPLAY_ALV OUTPUT.
  GS_STBL-ROW = 'X'.
  GS_STBL-COL = 'X'.

  IF GRID IS INITIAL.
    PERFORM CREATE_CONTROLS.
    PERFORM SET_EVENT.
    PERFORM ALV_LAYOUT.
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING GT_EXCLUDE.
    PERFORM SET_VARIANT.
*-> CCM : 12.09.2023 22:44:34 / ZLSGSD3
    PERFORM SET_SORT.
*<-
*    PERFORM SET_SEARCH_HELP.
    PERFORM FIELDCAT_INIT.


    CALL METHOD GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE               = 'U'
        IS_LAYOUT            = GS_LAYOUT
        IS_VARIANT           = GS_VARIANT
        IT_TOOLBAR_EXCLUDING = GT_EXCLUDE[]
      CHANGING
        IT_OUTTAB            = GT_ITAB
        IT_SORT              = GT_SORT[]
        IT_FIELDCATALOG      = GT_FIELDCAT.

  ELSE.
*    PERFORM ALV_LAYOUT.
*    CALL METHOD GRID->SET_FRONTEND_LAYOUT
*      EXPORTING
*        IS_LAYOUT = GS_LAYOUT.
*
*    PERFORM FIELDCAT_INIT.
*    CALL METHOD GRID->SET_FRONTEND_FIELDCATALOG
*      EXPORTING
*        IT_FIELDCATALOG = GT_FIELDCAT[].

    CALL METHOD GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = GS_STBL.
  ENDIF.
ENDMODULE.
