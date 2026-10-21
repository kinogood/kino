*&---------------------------------------------------------------------*
*&  Include           ZLER0012BC01                                     *
*&---------------------------------------------------------------------*

CLASS : lcl_alv_grid       DEFINITION DEFERRED,
        lcl_event_receiver DEFINITION DEFERRED.

* dialogbox Container
DATA : gc_container   TYPE scrfname VALUE 'CONT_1',
       gc_custom_cont TYPE REF TO cl_gui_custom_container,

       gc_alv_grid    TYPE REF TO lcl_alv_grid,
       "CL_GUI_ALV_GRID,
       gs_layout      TYPE lvc_s_layo,
       gs_variant     LIKE disvariant,
       gt_sort        TYPE lvc_t_sort WITH HEADER LINE,
       gt_fieldcat    TYPE lvc_t_fcat WITH HEADER LINE,
       gs_scroll      TYPE lvc_s_stbl.

DATA: x_save,  "for parameter I_SAVE: modus for saving a layout
      x_layout    TYPE disvariant,
      spec_layout TYPE disvariant.     "specific layout

DATA  : gc_event_receiver TYPE REF TO lcl_event_receiver.

*---------------------------------------------------------------------*
*       CLASS lcl_alv_grid DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_alv_grid DEFINITION INHERITING FROM cl_gui_alv_grid.

  PUBLIC SECTION.
    METHODS: m_optimize_all_cols,
      m_set_fixed_cols    IMPORTING cols TYPE i,
      m_get_selected_rows EXPORTING e_row TYPE i.
    DATA : gt_rows TYPE lvc_t_row,
           gs_row  TYPE lvc_s_row.

ENDCLASS.                    "LCL_ALV_GRID DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_alv_grid IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_alv_grid IMPLEMENTATION.

  METHOD m_optimize_all_cols.
    CALL METHOD me->optimize_all_cols.
  ENDMETHOD.                    "M_OPTIMIZE_ALL_COLS

  METHOD m_set_fixed_cols.
    CALL METHOD me->set_fixed_cols
      EXPORTING
        cols = cols.
  ENDMETHOD.                    "M_SET_FIXED_COLS

  METHOD m_get_selected_rows.

    CLEAR : gs_row, gt_rows[].
    CALL METHOD me->get_selected_rows
      IMPORTING
        et_index_rows = gt_rows[].
    CALL METHOD cl_gui_cfw=>flush.

    READ TABLE gt_rows INTO gs_row INDEX 1.
    IF sy-subrc = 0.
      e_row = gs_row-index.
    ENDIF.

  ENDMETHOD.                    "m_get_cureent_cell_row

ENDCLASS.                    "LCL_ALV_GRID IMPLEMENTATION

*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.

  PUBLIC SECTION .
    METHODS :
      handle_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column.

ENDCLASS.                    "lcl_event_receiver DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD handle_double_click.
    PERFORM handle_double_click USING e_row
                                      e_column.

  ENDMETHOD.                    "double_click

ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION

*&--------------------------------------------------------------------*
*&      Form  handle_double_click
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->E_ROW      text
*      -->E_COLUMN   text
*---------------------------------------------------------------------*
FORM handle_double_click USING e_row    TYPE lvc_s_row
                               e_column TYPE lvc_s_col.
  DATA : lv_row TYPE i.
  lv_row = e_row-index.

  IF lv_row > 0.
    PERFORM mark_chk_row USING  lv_row.

    CALL METHOD gc_alv_grid->refresh_table_display
      EXPORTING
        i_soft_refresh = 'X'
        is_stable      = gs_scroll.     "화면 라인 Refresh

  ENDIF.

ENDFORM.                    "handle_double_click
*-----------------------------------------------------------------
*        Start new screen
*-----------------------------------------------------------------
FORM bdc_dynpro USING program dynpro.
  CLEAR gt_bdcdata.
  gt_bdcdata-program  = program.
  gt_bdcdata-dynpro   = dynpro.
  gt_bdcdata-dynbegin = 'X'.
  APPEND gt_bdcdata.
ENDFORM.                    "bdc_dynpro

*-----------------------------------------------------------------
*        Insert field
*-----------------------------------------------------------------
FORM bdc_field USING fnam fval.
*  if fval <> nodata.
  CLEAR gt_bdcdata.
  gt_bdcdata-fnam = fnam.
  gt_bdcdata-fval = fval.
  APPEND gt_bdcdata.
*  endif.
ENDFORM.                    "bdc_field
