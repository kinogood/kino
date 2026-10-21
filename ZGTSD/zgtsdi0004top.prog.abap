*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : vbak, vbap, zgtsdt1007, vttk.

*----------------------------------------------------------------------*
* Class
*----------------------------------------------------------------------*
CLASS : lcl_event_receiver DEFINITION DEFERRED.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS : gc_e    TYPE char1 VALUE 'E',
            gc_x    TYPE char1 VALUE 'X',
            gc_kpcm TYPE zgtetarget VALUE 'KPCM',
            gc_kscm TYPE zgtetarget VALUE 'KSCM',
            gc_kbdm TYPE zgtetarget VALUE 'KBDM',
*[S] 한미소 MOM 전송 기능 추가
            gc_kmom TYPE zgtetarget VALUE 'KFCM'.
*[E] 한미소

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
       gv_tknum   LIKE vttk-tknum,
       gv_answer  TYPE char1.

*----------------------------------------------------------------------*
* TYPE & STRUCTURE & INTERNAL TABLE
*----------------------------------------------------------------------*
DATA : gt_fcode   TYPE TABLE OF sy-ucomm,
       gt_celltab TYPE lvc_t_styl.

"ALV Default Fields
TYPES : BEGIN OF ty_s_alvdef,
          statu TYPE icon_d,     "신규/변경/삭제 상태 ICON
          msg   TYPE text100,
          insrt TYPE char1,      "신규 여부 Flag : 'X' or ' '
          modi  TYPE char1,      "변경 여부 Flag : 'X' or ' '
          sel   TYPE char1,
          cells TYPE lvc_t_styl, "Cell Style
          cellc TYPE lvc_t_styl, "Cell Color
        END OF ty_s_alvdef.

TYPES : BEGIN OF ty_s_chg,
          vkorg TYPE vkorg,
          matnr TYPE matnr,
        END OF ty_s_chg,
        ty_t_chg TYPE TABLE OF ty_s_chg
                   WITH NON-UNIQUE SORTED KEY key_mode
                   COMPONENTS vkorg.

DATA  : BEGIN OF gs_s0100,
          tknum      TYPE zgtsdsif0016-tknum,
          tplst      TYPE zgtsdsif0016-tplst,
          shtyp      TYPE zgtsdsif0016-shtyp,
          vsart      TYPE zgtsdsif0016-vsart,
          vsbed      TYPE zgtsdsif0016-vsbed,
          bfart      TYPE zgtsdsif0016-bfart,
          add06      TYPE zgtsdsif0016-add06,
          sdabw      TYPE zgtsdsif0016-sdabw,
          tdlnr      TYPE zgtsdsif0016-tdlnr,
          exti1      TYPE zgtsdsif0016-exti1,
          exti2      TYPE zgtsdsif0016-exti2,
          tpbez      TYPE zgtsdsif0016-tpbez,
          signi      TYPE zgtsdsif0016-signi,

          zsystem_id TYPE zgtsdt1008-zsystem_id,
          zstat      TYPE zgtsdt1008-zstat,
          zmessage   TYPE zgtsdt1008-zmessage,
          ifdat      TYPE zgtsdt1008-ifdat,
          iftim      TYPE zgtsdt1008-iftim,
          ifnam      TYPE zgtsdt1008-ifnam,
          zifkey     TYPE zgtsdt1008-zifkey,

          system_nm  TYPE char20.
          INCLUDE    TYPE ty_s_alvdef. "ALV Default Fields
DATA : END OF gs_s0100.
DATA : gt_s0100  LIKE TABLE OF gs_s0100.
*       GT_HEADER TYPE TABLE OF ZGTSDT1007 WITH NON-UNIQUE SORTED KEY K_KEY COMPONENTS VBELN,
*       GT_ITEM   TYPE TABLE OF ZGTSDT1008 WITH NON-UNIQUE SORTED KEY K_KEY COMPONENTS VBELN.

DATA :
*       GT_HEAD TYPE TABLE OF ZGTSDSIF0016 With Header Line,
  gt_item TYPE TABLE OF zgtsdsif0017 WITH HEADER LINE,
  gt_tms  TYPE TABLE OF zlet0905 WITH HEADER LINE.

DATA : BEGIN OF gt_head OCCURS 0 .
         INCLUDE STRUCTURE zgtsdsif0016.
DATA  : zifkey     LIKE zgtsdt1018-zifkey,
         zsystem_id LIKE zgtsdt1018-zsystem_id,
         zstat      LIKE zgtsdt1018-zstat,
         zmessage   LIKE zgtsdt1018-zmessage,
         ifdat      LIKE zgtsdt1018-ifdat,
         iftim      LIKE zgtsdt1018-iftim,
         ifnam      LIKE zgtsdt1018-ifnam.
DATA : END OF gt_head.


"화면 변경 정보
DATA : gt_chg   TYPE ty_t_chg.
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
