*&---------------------------------------------------------------------*
*& Include          ZGTPPR1130C01
*&---------------------------------------------------------------------*
* CLASS zcl_event_receiver DEFINITION
CLASS ZCL_EVENT_RECIEVER DEFINITION.

  PUBLIC SECTION.

    METHODS HDL_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING
        SENDER
        ER_DATA_CHANGED
        E_ONF4
        E_ONF4_BEFORE
        E_ONF4_AFTER
        E_UCOMM .

ENDCLASS.                    "ZCL_EVENT_RECEIVER DEFINITION
* CLASS zcl_event_receiver IMPLEMENTATION
CLASS ZCL_EVENT_RECIEVER IMPLEMENTATION.

  METHOD HDL_DATA_CHANGED.
    PERFORM HDL_DATA_CHANGED USING SENDER
                                   ER_DATA_CHANGED
                                   E_ONF4
                                   E_ONF4_BEFORE
                                   E_ONF4_AFTER
                                   E_UCOMM.
  ENDMETHOD.                    "HDL_DATA_CHANGED

ENDCLASS.                    "ZCL_EVENT_RECEIVER IMPLEMENTATION
