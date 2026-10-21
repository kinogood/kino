*&---------------------------------------------------------------------*
*& Include          ZGTSDR0012TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
tables : zgtsdt0011, vbap.

*----------------------------------------------------------------------*
* Class
*----------------------------------------------------------------------*
class lcl_event_receiver definition deferred.

*----------------------------------------------------------------------*
* VARIABLE
*----------------------------------------------------------------------*
data : gv_error  type char1,
       gv_saveok like sy-ucomm,
       gv_okcode like sy-ucomm.

*----------------------------------------------------------------------*
* TYPE & STRUCTURE & INTERNAL TABLE
*----------------------------------------------------------------------*
" ALV List Display Type
types : begin of ty_s_alv.
          include type zgtsdt0011.
types :   vrkme type vbap-vrkme,
          cells type lvc_t_styl,
          modi  type char1.
types : end of ty_s_alv.

data  : gt_alv type table of ty_s_alv,
        gs_alv type ty_s_alv.

*----------------------------------------------------------------------*
* ALV GRID
*----------------------------------------------------------------------*
data  : go_con     type ref to cl_gui_docking_container,
        go_grid    type ref to cl_gui_alv_grid,
        gt_fcat    type lvc_t_fcat,
        gs_fcat    type lvc_s_fcat,
        gs_layout  type lvc_s_layo,
        gt_exclude type ui_functions.

data  : go_event_receiver type ref to lcl_event_receiver.

data  : gs_stbl type lvc_s_stbl.

*----------------------------------------------------------------------*
* MACRO DEFINE
*----------------------------------------------------------------------*
define __cle.
  CLEAR: &1, &1[].
end-of-definition.
