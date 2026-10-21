*&---------------------------------------------------------------------*
*& Include          ZGTPPI2010C01
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.

    METHODS : handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row
                e_column.

ENDCLASS.  "(LCL_EVENT_RECEIVER DEFINITION)
****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
CLASS lcl_event_handler IMPLEMENTATION.
*& Double Click
  METHOD handle_double_click.
    PERFORM double_click  USING e_row e_column.
  ENDMETHOD.    "handle_double_click

ENDCLASS. "LCL_EVENT_RECEIVER IMPLEMENTATION
*&---------------------------------------------------------------------*
*& Form create_alv_grid_100
*&---------------------------------------------------------------------*
FORM create_alv_grid_100 .

  CHECK g_custom_container IS INITIAL.
* create a custom container control for our alv control
  CREATE OBJECT g_custom_container
    EXPORTING
      container_name = gv_mycontainer.
* Create an Instance of ALV Control
  CREATE OBJECT g_grid
    EXPORTING
      i_parent = g_custom_container.
* 툴바 버튼 제거
  PERFORM 2100_exclude_tb_functions USING 'GT_EXCLUDE'.
* 필드명과 Output Length등을 사용자의 입맛에 맞게 바꿈
  PERFORM 2200_fill_field_category.
* Display시 다양한 옵션을 지정
  PERFORM 2300_change_display_attribute CHANGING gs_fcatlayo.
** Edit  이벤트 등록
*  CALL METHOD g_grid->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
*
  CREATE OBJECT g_event_handler.
  SET HANDLER g_event_handler->handle_double_click  FOR g_grid.

  CALL METHOD g_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.
* 'gs_layout' must at least contain the report-id to allow
* saving a layout.
  gv_repid = sy-repid.
* ?2.At least field REPORT of this structure has to be filled!
  gv_alv_variant-report = gv_repid.

  PERFORM 2500_grid_display_part.

ENDFORM.
