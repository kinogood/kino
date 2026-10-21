*&---------------------------------------------------------------------*
*&  Include           ZMMR1360_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  DATA: LV_DATE(10).

  WRITE SY-DATUM TO LV_DATE USING EDIT MASK '____.__.__'.

  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100'  WITH LV_DATE .
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  ALV_DISPLAY  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ALV_DISPLAY OUTPUT.

  IF GS_ALV_GRID IS INITIAL.

   CREATE OBJECT GS_ALV_GRID
      EXPORTING
        I_PARENT = CL_GUI_CUSTOM_CONTAINER=>DEFAULT_SCREEN.


    PERFORM MAKE_MAIN_LIST.  "MAIN LIST

  ELSE.
*---// ALV Refresh - Column & line fix
    PERFORM REFRESH_TABLE_DISPLAY USING GS_ALV_GRID.
  ENDIF.

ENDMODULE.
