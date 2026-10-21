*&---------------------------------------------------------------------*
*&  Include           ZGTSDR1080_PBO                                  *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  status_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'G0100'.
  IF sy-tcode NE 'ZGTSDR1085'.
    SET TITLEBAR  'T0100'.
  ELSE.
    SET TITLEBAR  'T0101'.
  ENDIF.

ENDMODULE.                 " status_0100  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  create_instance_controls  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_instance_controls OUTPUT.

  PERFORM create_and_init_controls.

ENDMODULE.                 " create_instance_controls  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  status_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  SET PF-STATUS 'G0200'.

ENDMODULE.                 " status_0200  OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS 'G0200'.
  SET TITLEBAR 'T0300'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_OBJECT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_object OUTPUT.

  IF go_con IS NOT BOUND.

    "Create Object
    CREATE OBJECT go_con
      EXPORTING
        container_name              = 'CON0300'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    IF sy-subrc <> 0.
      MESSAGE a003.
    ENDIF.

*// Create an Instance of ALV Control
    CREATE OBJECT go_grid
      EXPORTING
        i_parent      = go_con
        i_appl_events = 'X'.

    CLEAR gs_layout.
    gs_layout = VALUE #( sel_mode   = 'D'
                         zebra      = zgtsd_x
                         cwidth_opt = 'X'
                         stylefname = '' ).

**********************************************************************
    "Set Field Catalog
**********************************************************************
    REFRESH gt_fcat.
    gt_fcat = zgtsd_cl_common=>get_field_catalog( it_table = <gfs_data>
                                                  iv_cells = zgtsd_x
                                                  iv_cellc = zgtsd_x ).
    PERFORM set_fieldcatalog_pop.
**********************************************************************
    PERFORM exclude_of_toolbar_button USING 'GT_TOOLBAR'.

    "Event Handler 등록
    PERFORM create_event_receiver USING go_grid.

    DELETE gt_fcat WHERE tech = zgtsd_x. "불필요한 필드 제외

    "Formatted Output Table is Sent to Control
    CALL METHOD go_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout
        is_variant           = VALUE #( report = sy-repid
                                        handle = '3' )
        i_save               = zgtsd_a
        it_toolbar_excluding = gt_toolbar
      CHANGING
        it_fieldcatalog      = gt_fcat
        it_sort              = gt_sort[]
        it_outtab            = <gfs_data>.
  ELSE.
    PERFORM refresh_table_display USING go_grid space.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0400 OUTPUT.
  SET PF-STATUS 'G0400'.
  IF gv_check = 'X'.
    SET TITLEBAR 'T0401'." CHM2510-00065
  ELSE.
    SET TITLEBAR 'T0400'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_OBJECT2 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_object2 OUTPUT.
  IF go_con IS NOT BOUND.

    "Create Object
    CREATE OBJECT go_con2
      EXPORTING
        container_name              = 'CON0400'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    IF sy-subrc <> 0.
      MESSAGE a003.
    ENDIF.

*// Create an Instance of ALV Control
    CREATE OBJECT go_grid2
      EXPORTING
        i_parent      = go_con2
        i_appl_events = 'X'.

    CLEAR gs_layout.
    gs_layout = VALUE #( sel_mode   = 'D'
                         zebra      = zgtsd_x
                         cwidth_opt = 'X'
                         stylefname = '' ).

**********************************************************************
    "Set Field Catalog
**********************************************************************
    REFRESH gt_fcat.
    " CHM2510-00065
    IF gv_check = 'X'.
      gt_fcat = zgtsd_cl_common=>get_field_catalog( it_table = gt_check
                                                    iv_cells = zgtsd_Z
                                                    iv_cellc = zgtsd_Z ).
      PERFORM set_fieldcatalog_pop3." CHM2510-00065

    ELSE.
      gt_fcat = zgtsd_cl_common=>get_field_catalog( it_table = gt_t0400
                                                    iv_cells = zgtsd_x
                                                    iv_cellc = zgtsd_x ).
      PERFORM set_fieldcatalog_pop2.
    ENDIF.
**********************************************************************
    PERFORM exclude_of_toolbar_button USING 'GT_TOOLBAR'.

    "Event Handler 등록
    PERFORM create_event_receiver USING go_grid2.

    DELETE gt_fcat WHERE tech = zgtsd_x. "불필요한 필드 제외

    "Formatted Output Table is Sent to Control
    IF gv_check = 'X'.
      CALL METHOD go_grid2->set_table_for_first_display
        EXPORTING
          is_layout            = gs_layout
          is_variant           = VALUE #( report = sy-repid
                                          handle = '3' )
          i_save               = zgtsd_a
          it_toolbar_excluding = gt_toolbar
        CHANGING
          it_fieldcatalog      = gt_fcat
          it_sort              = gt_sort[]
          it_outtab            = gt_CHECK.
    ELSE.
      CALL METHOD go_grid2->set_table_for_first_display
        EXPORTING
          is_layout            = gs_layout
          is_variant           = VALUE #( report = sy-repid
                                          handle = '3' )
          i_save               = zgtsd_a
          it_toolbar_excluding = gt_toolbar
        CHANGING
          it_fieldcatalog      = gt_fcat
          it_sort              = gt_sort[]
          it_outtab            = gt_t0400.
    ENDIF.
  ELSE.
    PERFORM refresh_table_display USING go_grid2 space.
  ENDIF.
ENDMODULE.
