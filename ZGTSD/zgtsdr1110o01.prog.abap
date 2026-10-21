*&---------------------------------------------------------------------*
*& Include          ZSDR1006O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

 SET PF-STATUS 'S100'.
 SET TITLEBAR 'T100'.

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
    CALL METHOD GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = GS_STBL.
  ENDIF.
ENDMODULE.
