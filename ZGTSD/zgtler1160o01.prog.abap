*&---------------------------------------------------------------------*
*& Include          ZGTLER1160O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  SET PF-STATUS '0100' .
  SET TITLEBAR  '0100' WITH TEXT-TXT.
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
    PERFORM ALV_LAYOUT CHANGING : GS_LAYOUT.
    PERFORM EXCLUDE_TB_FUNCTIONS CHANGING : GT_EXCLUDE.
    PERFORM SET_VARIANT CHANGING  GS_VARIANT .
    PERFORM FIELDCAT_INIT.  "
    PERFORM SET_SORT.

    "ALV
    GRID->SET_TABLE_FOR_FIRST_DISPLAY(
          EXPORTING
            I_SAVE               = 'A'
            IS_LAYOUT            = GS_LAYOUT
            IS_VARIANT           = GS_VARIANT
            IT_TOOLBAR_EXCLUDING = GT_EXCLUDE[]
          CHANGING
            IT_OUTTAB            = GT_DATA[]
            IT_SORT              = GT_SORT[]
            IT_FIELDCATALOG      = GT_FIELDCAT ).


  ELSE.
    GRID->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT ).
    GRID->REFRESH_TABLE_DISPLAY( EXPORTING IS_STABLE = GS_STBL ).


  ENDIF.
ENDMODULE.
