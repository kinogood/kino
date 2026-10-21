*&---------------------------------------------------------------------*
*&  Include           ZGTCONTROLS_EVENT01                              *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  LCL_EVENT DEFINITION
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_100 DEFINITION.
  PUBLIC SECTION.
    METHODS : HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT E_INTERACTIVE.

    METHODS : HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

    METHODS : HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING ER_DATA_CHANGED.

    METHODS : HANDLE_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID
                E_COLUMN_ID.

    METHODS : HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW
                E_COLUMN.

    METHODS : ON_F4 FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_FIELDNAME
                E_FIELDVALUE
                ES_ROW_NO
                ER_EVENT_DATA
                ET_BAD_CELLS
                E_DISPLAY.

    METHODS : HANDLE_BUTTON_CLICK FOR EVENT BUTTON_CLICK
      OF CL_GUI_ALV_GRID
      IMPORTING ES_COL_ID
                ES_ROW_NO.

    TYPES : DDSHRETVAL_TABLE TYPE TABLE OF DDSHRETVAL.

    METHODS : MY_F4
      IMPORTING SENDER        TYPE REF TO CL_GUI_ALV_GRID
                ET_BAD_CELLS  TYPE LVC_T_MODI
                ES_ROW_NO     TYPE LVC_S_ROID
                ER_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                E_DISPLAY     TYPE C
                E_FIELDNAME   TYPE LVC_FNAME
      EXPORTING LT_F4         TYPE DDSHRETVAL_TABLE.
ENDCLASS.  "(LCL_EVENT_100 DEFINITION)

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
CLASS LCL_EVENT_100 IMPLEMENTATION.
  METHOD HANDLE_TOOLBAR.
*    PERFORM TOOLBAR_PART  USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

  METHOD HANDLE_USER_COMMAND.
*    PERFORM USER_COMMAND_PART USING E_UCOMM.
  ENDMETHOD.                    "handle_user_command

  METHOD HANDLE_DATA_CHANGED.
*    PERFORM DATA_CHANGED  USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HOTSPOT_CLICK_100 USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "handle_hotspot_click

  METHOD HANDLE_DOUBLE_CLICK.
*    PERFORM DOUBLE_CLICK_100  USING E_ROW E_COLUMN.
  ENDMETHOD.                    "handle_double_click

  METHOD HANDLE_BUTTON_CLICK.
*    PERFORM BUTTON_CLICK_210 USING ES_COL_ID ES_ROW_NO.
  ENDMETHOD.                    "HANDLE_BUTTON_CLICK

  METHOD ON_F4.
*    PERFORM ON_F4 USING SENDER
*                             E_FIELDNAME
*                             E_FIELDVALUE
*                             ES_ROW_NO
*                             ER_EVENT_DATA
*                             ET_BAD_CELLS
*                             E_DISPLAY.
  ENDMETHOD.                                                "on_f4

  METHOD MY_F4.
*    PERFORM MY_F4 TABLES LT_F4
*                        USING SENDER
*                              ET_BAD_CELLS
*                              ES_ROW_NO
*                              ER_EVENT_DATA
*                              E_DISPLAY
*                              E_FIELDNAME.
  ENDMETHOD.                                                "my_f4
ENDCLASS. "LCL_EVENT_100 IMPLEMENTATION

DATA: G_EVENT TYPE REF TO LCL_EVENT_100.
