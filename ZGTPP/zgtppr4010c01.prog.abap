*&---------------------------------------------------------------------*
*& Include          ZGTPPR4010C01
*&---------------------------------------------------------------------*
* CLASS zcl_event_receiver DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION.

  PUBLIC SECTION.

    METHODS CONSTRUCTOR
      IMPORTING
        I_REPID TYPE SYREPID .

    METHODS HDL_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING
        ER_DATA_CHANGED
        E_ONF4
        E_ONF4_BEFORE
        E_ONF4_AFTER
        E_UCOMM .

    METHODS HDL_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW E_COLUMN.

ENDCLASS.                    "ZCL_EVENT_RECEIVER DEFINITION
* CLASS zcl_event_receiver IMPLEMENTATION
CLASS ZCL_EVENT_RECIEVER IMPLEMENTATION.

  METHOD CONSTRUCTOR.
    PERFORM CONSTRUCTOR USING I_REPID.
  ENDMETHOD.                    "CONSTRUCTOR

  METHOD HDL_DATA_CHANGED.
    PERFORM HDL_DATA_CHANGED USING ER_DATA_CHANGED
                                   E_ONF4
                                   E_ONF4_BEFORE
                                   E_ONF4_AFTER
                                   E_UCOMM.
  ENDMETHOD.                    "HDL_DATA_CHANGED

  METHOD HDL_DOUBLE_CLICK.
    PERFORM HDL_DOUBLE_CLICK USING E_ROW
                                   E_COLUMN.
  ENDMETHOD.                    "HDL_DOUBLE_CLICK

ENDCLASS.                    "ZCL_EVENT_RECEIVER IMPLEMENTATION
