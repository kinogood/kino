*&---------------------------------------------------------------------*
*&  Include           ZMMR1360_C01
*&---------------------------------------------------------------------*
*&      CLASS DEFINITIAL
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER DEFINITION.
  PUBLIC SECTION.
    METHODS:
      HANDLE_DATA_CHANGED
                    FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
        IMPORTING SENDER ER_DATA_CHANGED,
      HANDLE_HOTSPOT_CLICK
                    FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_ROW_ID E_COLUMN_ID,
      HANDLE_DOUBLE_CLICK
                    FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_ROW E_COLUMN,
      HANDLE_ONF4
                    FOR EVENT ONF4 OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_FIELDNAME E_FIELDVALUE
                    ES_ROW_NO ER_EVENT_DATA
                    ET_BAD_CELLS E_DISPLAY,
      HANDLE_TOOLBAR
                    FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_OBJECT E_INTERACTIVE,
      HANDLE_USER_COMMAND
                    FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
        IMPORTING SENDER E_UCOMM.

ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION
*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.
  METHOD HANDLE_DATA_CHANGED.
*    PERFORM HANDLE_DATA_CHANGED USING SENDER
*                                      ER_DATA_CHANGED.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HANDLE_HOTSPOT_CLICK USING SENDER
                                     E_ROW_ID
                                     E_COLUMN_ID.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD HANDLE_DOUBLE_CLICK.
   PERFORM HANDLE_DOUBLE_CLICK USING SENDER
                                     E_ROW-INDEX
                                     E_COLUMN-FIELDNAME.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
  METHOD HANDLE_ONF4.
*    PERFORM GET_ON_F4 USING SENDER
*                            E_FIELDNAME
*                            E_FIELDVALUE
*                            ES_ROW_NO
*                            ER_EVENT_DATA
*                            ET_BAD_CELLS
*                            E_DISPLAY.
*    ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.
  ENDMETHOD.                    "HANDLE_ONF4
  METHOD HANDLE_TOOLBAR.
    PERFORM TOOLBAR_PART USING SENDER
                               E_OBJECT
                               E_INTERACTIVE.
  ENDMETHOD.                    "HANDLE_TOOLBAR
  METHOD HANDLE_USER_COMMAND.
*    PERFORM USER_COMMAND_PART USING SENDER
*                                    E_UCOMM.
  ENDMETHOD.                    "HANDLE_USER_COMMAND
ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
