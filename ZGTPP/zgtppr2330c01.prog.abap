*&---------------------------------------------------------------------*
*& Include          ZGTPPR2330C01
*&---------------------------------------------------------------------*
CLASS LCL_LIST_HANDLER DEFINITION.
  PUBLIC SECTION.
    INTERFACES ZGTPP_IF_LIST_HANDLER.
ENDCLASS.

CLASS LCL_LIST_HANDLER IMPLEMENTATION.
  METHOD ZGTPP_IF_LIST_HANDLER~HANDLE_FIELD_CATALOG.
    PERFORM HANDLE_FIELD_CATALOG USING SENDER.
  ENDMETHOD.

  METHOD ZGTPP_IF_LIST_HANDLER~HANDLE_LAYOUT.
    PERFORM HANDLE_LAYOUT USING SENDER.
  ENDMETHOD.

  METHOD ZGTPP_IF_LIST_HANDLER~HANDLE_HOTSPOT_CLICK.
    PERFORM HANDLE_HOTSPOT_CLICK USING SENDER ES_ROW_NO E_COLUMN_ID.
  ENDMETHOD.

  METHOD ZGTPP_IF_LIST_HANDLER~HANDLE_DATA_CHANGED.
    PERFORM HANDLE_DATA_CHANGED USING SENDER ER_DATA_CHANGED E_UCOMM.
  ENDMETHOD.
ENDCLASS.

CLASS LCX_EXCEPTION DEFINITION INHERITING FROM CX_STATIC_CHECK.
  PUBLIC SECTION.
    INTERFACES IF_T100_DYN_MSG.
ENDCLASS.
*----------------------------------------------------------------------*
* CLASS LCL_EVENT_HANDLER DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
    METHODS HANDLE_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_UCOMM.


    METHODS HANDLE_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                ER_DATA_CHANGED
                E_ONF4
                E_UCOMM.

    METHODS HANDLE_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_ROW
                E_COLUMN.

    METHODS HANDLE_CONTEXT_MENU
      FOR EVENT CONTEXT_MENU_REQUEST OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_OBJECT.

    METHODS HANDLE_ON_F4
      FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING SENDER
                E_FIELDNAME
                E_FIELDVALUE
                ES_ROW_NO
                ER_EVENT_DATA
                ET_BAD_CELLS
                E_DISPLAY.

ENDCLASS. "(LCL_EVENT_RECEIVER DEFINITION)
*----------------------------------------------------------------------*
* CLASS LCL_EVENT_HANDLER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

*-- user_command
  METHOD HANDLE_USER_COMMAND.
    PERFORM USER_COMMAND_PROS USING SENDER
                                    E_UCOMM.
  ENDMETHOD. " user_command

*-- Data change
  METHOD HANDLE_DATA_CHANGED.
    PERFORM DATA_CHANGED USING SENDER
                               ER_DATA_CHANGED
                               E_ONF4
                               E_UCOMM.

  ENDMETHOD. " data_changed

*-- Double Click
  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM DOUBLE_CLICK USING SENDER
                               E_ROW
                               E_COLUMN.
  ENDMETHOD. " double_click

  METHOD HANDLE_CONTEXT_MENU.
    PERFORM CONTEXT_MENU USING SENDER
                                        E_OBJECT.
  ENDMETHOD.                    "handle_context_menu.

  METHOD HANDLE_ON_F4.
    PERFORM ALV_ONF4 USING  SENDER
                            E_FIELDNAME
                            E_FIELDVALUE
                            ES_ROW_NO
                            ER_EVENT_DATA
                            ET_BAD_CELLS
                            E_DISPLAY.
  ENDMETHOD.

ENDCLASS. "lcl_event_handler IMPLEMENTATION
