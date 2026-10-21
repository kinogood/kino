*&---------------------------------------------------------------------*
*&  Include           ZMMR1360_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  DATA : LV_ERDAT_FR(10),
         LV_ERDAT_TO(10).

  WRITE S_CDRDT-LOW   TO LV_ERDAT_FR USING EDIT MASK '____.__.__'.

  WRITE S_CDRDT-HIGH  TO LV_ERDAT_TO USING EDIT MASK '____.__.__'.

  SET TITLEBAR  '0100' WITH '수리신고일' LV_ERDAT_FR  LV_ERDAT_TO .


  SET PF-STATUS '0100'.

ENDMODULE.                    "STATUS_0100 OUTPUT

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

ENDMODULE.                    "ALV_DISPLAY OUTPUT
