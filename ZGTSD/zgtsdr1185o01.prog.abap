*&---------------------------------------------------------------------*
*& Include          ZGTSDR1185O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

**
  SET PF-STATUS 'PF200'.
  SET TITLEBAR 'T10'.

  IF g_docking_con IS INITIAL.

    PERFORM create_object.

    PERFORM set_layout .

    PERFORM create_fieldcatalog.

*    PERFORM sort_field.

*    PERFORM exclude_tb_function USING 'GT_EXCLUDE'.

    CALL METHOD g_grid_head->set_table_for_first_display
      EXPORTING
        i_save               = 'A'
        is_layout            = gs_layh
        it_toolbar_excluding = gt_exclude
        i_default            = 'X'             " 레이아웃 사전셋팅 허용.
*       is_variant           = gs_variant
      CHANGING
        it_outtab            = gt_head[]
        it_fieldcatalog      = gt_fieldh[]
        it_sort              = gt_sorth[].


    PERFORM create_event_receiver.


    CALL METHOD g_grid_item->set_table_for_first_display
      EXPORTING
        i_save               = 'A'
        is_layout            = gs_layi
        it_toolbar_excluding = gt_exclude
        i_default            = 'X'             " 레이아웃 사전셋팅 허용.
*       is_variant           = gs_variant
      CHANGING
        it_outtab            = gt_selt[]
        it_fieldcatalog      = gt_fieldi[]
        it_sort              = gt_sorti[].
  ENDIF.

**

ENDMODULE.
