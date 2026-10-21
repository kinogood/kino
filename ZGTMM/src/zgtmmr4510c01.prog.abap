*&---------------------------------------------------------------------*
*&  Include           ZLER0016CLS                                      *
*&---------------------------------------------------------------------*
DATA :  BEGIN OF gt_alv1 OCCURS 0.
        INCLUDE STRUCTURE gt_out.
DATA :  alv_col TYPE slis_t_specialcol_alv,
        END OF gt_alv1,
        gs_alv1 LIKE gt_alv1.
DATA: alv_variant        LIKE disvariant.

CLASS lcl_event_receiver  DEFINITION DEFERRED.
*----------------------------------------------------------------------*
* DOCK DATA DECLARATION
*----------------------------------------------------------------------*
DATA: splitter            TYPE REF TO cl_gui_splitter_container,
      container_spliter   TYPE REF TO cl_gui_custom_container,
      container_1         TYPE REF TO cl_gui_container.
*     container_2         TYPE REF TO cl_gui_container.

* Docking Container
DATA docking TYPE REF TO cl_gui_docking_container.
*----------------------------------------------------------------------*
* ALV DATA DECLARATION
*----------------------------------------------------------------------*
DATA: grid1               TYPE REF TO                       " ALV1
                          cl_gui_alv_grid,
      grid2               TYPE REF TO                       " ALV2
                          cl_gui_alv_grid,
      gt_sort             TYPE lvc_t_sort
                          WITH HEADER LINE,
      gt_tbar_excluding1  TYPE ui_functions,
      gt_tbar_excluding2  TYPE ui_functions,
      gt_tbar_excluding3  TYPE ui_functions,
      gs_layout           TYPE lvc_s_layo,         " ALV_LAYOUT
      gt_lvc1             TYPE lvc_t_fcat          " ALV FIELD CATALOGUE
                          WITH HEADER LINE,
      gt_lvc2             TYPE lvc_t_fcat          " ALV FIELD CATALOGUE
                          WITH HEADER LINE,
*     gt_lvc3             TYPE lvc_t_fcat          " ALV FIELD CATALOGUE
*                         WITH HEADER LINE,
      event_receiver      TYPE REF TO              " ALV EVENT
                          lcl_event_receiver.

DATA: gs_lvc1            TYPE lvc_s_fcat,      " ALV FIELD CATALOGUE
      gs_lvc2            TYPE lvc_s_fcat.      " ALV FIELD CATALOGUE
DATA: gt_rows            TYPE lvc_t_row WITH HEADER LINE.
*----------------------------------------------------------------------*
* CLASS Definition
*----------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.

  PUBLIC SECTION.

    METHODS: handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,

    handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed,

    handle_data_changed_finished
      FOR EVENT data_changed_finished OF cl_gui_alv_grid
      IMPORTING e_modified et_good_cells,

    handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,

    handle_hotspot_click
        FOR EVENT hotspot_click OF cl_gui_alv_grid
            IMPORTING e_row_id e_column_id es_row_no,

    handle_double_click
            FOR EVENT double_click OF cl_gui_alv_grid
            IMPORTING e_row e_column.

ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION

*---------------------------------------------------------------------*
*********> CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.
*---------------------------------------------------------------------*
*/ DEFINE TOOBAR
*---------------------------------------------------------------------*
  METHOD handle_toolbar.

  ENDMETHOD.                    "HANDLE_TOOLBAR
*---------------------------------------------------------------------*
*/ HANDLE DATA CHANGED FINISHED
*---------------------------------------------------------------------*
* 헤더별 선택 제어
   METHOD  handle_data_changed_finished.

    DATA : ls_good_cells LIKE LINE OF et_good_cells.
    DATA : IS_GT LIKE GT_OUT.
    clear: gt_alv1-alv_col[].

    READ TABLE et_good_cells INTO ls_good_cells INDEX 1.
    gv_index = ls_good_cells-row_id.
    READ TABLE  GT_OUT  INTO IS_GT INDEX GV_INDEX.
    GV_IV_NO = IS_GT-IV_NO.
*   GRID1 속성
    IF ls_good_cells-fieldname = 'CHK'.
      perform get_grid1_control.
**     PERFORM TONGMOON_CONFIRM_Y_N.
      PERFORM change_data_from_inside_grid1.
    ELSE.
      IF SY-UCOMM = 'REFR'.
         CALL METHOD grid1->refresh_table_display.
      ENDIF.
    ENDIF.
    CLEAR SY-UCOMM.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED
*---------------------------------------------------------------------*
* USER COMMAND
*---------------------------------------------------------------------*
  METHOD handle_user_command.
    PERFORM user_command_pros USING e_ucomm.
  ENDMETHOD.                           "handle_user_command

*---------------------------------------------------------------------*
* HOTSPOR CLICK
*---------------------------------------------------------------------*
*  METHOD handle_hotspot_click.
*
*  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK
*---------------------------------------------------------------------*
  METHOD handle_data_changed.

  ENDMETHOD.                    "handle_data_changed

*---------------------------------------------------------------------*
* DOUBLE CLICK
*---------------------------------------------------------------------*
  METHOD handle_double_click.

  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
*---------------------------------------------------------------------*
* HOTSPOR CLICK
*---------------------------------------------------------------------*
  METHOD handle_hotspot_click.

  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION
