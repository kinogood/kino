*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : vbak, vbap, vttk.
TABLES : zsdt_snop_010, zgtsdt1003..

*----------------------------------------------------------------------*
* Class
*----------------------------------------------------------------------*
CLASS : lcl_event_receiver DEFINITION DEFERRED.

*----------------------------------------------------------------------*
*  ALV GRID.
*----------------------------------------------------------------------*

DATA : gt_toolbar TYPE ui_functions.
DATA : go_con     TYPE REF TO cl_gui_docking_container,
       go_grid    TYPE REF TO cl_gui_alv_grid,
       gt_fcat    TYPE lvc_t_fcat,
       gs_fcat    TYPE lvc_s_fcat,
       gt_sort    TYPE lvc_t_sort,   " ALV Sort
       gs_layout  TYPE lvc_s_layo,
       go_split   TYPE REF TO cl_gui_splitter_container,
       go_con_top TYPE REF TO cl_gui_container,
       go_docu    TYPE REF TO cl_dd_document.


DATA : gs_variant TYPE disvariant.
DATA : gs_stbl TYPE lvc_s_stbl.

DATA : gt_row TYPE lvc_t_row WITH HEADER LINE,
       gs_row LIKE gt_row.


*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS : gc_e    TYPE char1 VALUE 'E',
            gc_x    TYPE char1 VALUE 'X',
            gc_kpcm TYPE zgtetarget VALUE 'KPCM',
            gc_kscm TYPE zgtetarget VALUE 'KSCM',
            gc_kbdm TYPE zgtetarget VALUE 'KBDM'.

CONSTANTS : gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf,
            gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab.


*----------------------------------------------------------------------*
* VARIABLE
*----------------------------------------------------------------------*
DATA : gv_saveok  LIKE sy-ucomm,
       gv_okcode  LIKE sy-ucomm,
       gv_error   TYPE char1,
       gv_tar     TYPE zgtetarget,
       gv_result  TYPE c LENGTH 2,
       gv_message TYPE string,
       gv_ivno    LIKE zlet0005-iv_no,
       gv_answer  TYPE char1.

*----------------------------------------------------------------------*
* TYPE & STRUCTURE & INTERNAL TABLE
*----------------------------------------------------------------------*

DATA :BEGIN OF gt_data OCCURS 0.

       INCLUDE STRUCTURE zgtsdsif0031.
DATA : END OF gt_data.
*DATA : gt_DATA TYPE TABLE OF ZGTSDSIF0031 WITH HEADER LINE.


DATA : gt_s0100  LIKE TABLE OF gt_data.

DATA : BEGIN OF gt_result OCCURS 0 .
DATA :  stamp  TYPE timestampl.
DATA : zo_result   TYPE zo_result,
       zo_message2 TYPE zo_message2.
DATA : END OF gt_result.
DATA : gs_result LIKE gt_result.
*----------------------------------------------------------------------*
* DEFINE
*----------------------------------------------------------------------*
DEFINE __cle.
  CLEAR: &1, &1[].
END-OF-DEFINITION.

DEFINE __rng.
  &1-sign   = &2.
  &1-option = &3.
  &1-low    = &4.
  &1-high    = &5.
  APPEND &1. CLEAR &1.
END-OF-DEFINITION.

DEFINE __alpha_in.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = &1
    IMPORTING
      output = &2.
END-OF-DEFINITION.

DEFINE __alpha_ou.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = &1
    IMPORTING
      output = &2.
END-OF-DEFINITION.

DEFINE __get_rows.
  __cle : &2.
  CHECK &1 IS BOUND.
  CALL METHOD &1->get_selected_rows
     IMPORTING
       et_index_rows = &2[].

  DELETE &2 WHERE rowtype IS NOT INITIAL.

  CHECK &3 IS NOT INITIAL.


END-OF-DEFINITION.
