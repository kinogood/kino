*&---------------------------------------------------------------------*
*&  Include           ZGTCONTROLS                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  CONTROLS
*&---------------------------------------------------------------------*
DATA: G_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      G_GRID      TYPE REF TO CL_GUI_ALV_GRID.

DATA: GT_FIELDCAT TYPE LVC_T_FCAT,
      GS_LAYOUT   TYPE LVC_S_LAYO,
      GT_SORT     TYPE LVC_T_SORT,
      GT_EXCLUDE  TYPE UI_FUNCTIONS,
      GS_VARI     TYPE DISVARIANT.


DATA: GS_STABLE TYPE LVC_S_STBL.

DATA: IT_ROWS TYPE LVC_T_ROW.

CONSTANTS: MYCON(20) VALUE 'CONTAINER100'.
