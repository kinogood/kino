*&---------------------------------------------------------------------*
*&  Include           MZQM0696O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_DATA_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_DATA_0100 OUTPUT.

  IF G_DOCKCONTAINER1 IS INITIAL.
    PERFORM SET_ALV_CONTAINER.
    PERFORM LAYOUT_ATTRIBUTE        CHANGING GS_LVC_LAYO.       " Grid 속성
    PERFORM TOOLBAR_PART            USING   'gt_ui_functions'.  " Tool Bar
    PERFORM LVC_FIELDCATALOG_MERGE  CHANGING GT_LVC_FCAT.       " Field Cat.
    PERFORM EVENT_HANDLER_REGISTER.                             " Event
*    PERFORM field_sorting.
    PERFORM ALV_DISPLAY_PART.
  ELSE.
    PERFORM REFRESH_CONTAINER .
  ENDIF.

ENDMODULE.                 " INIT_DATA_0100  OUTPUT
