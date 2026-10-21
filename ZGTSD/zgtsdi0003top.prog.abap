*&---------------------------------------------------------------------*
*& Include          ZGTSDI0001TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : vbak, vbap, zgtsdt1007.

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
* [GO-SD][26.01.28] Add logic for 가온MES  - Start.
            gc_kgom TYPE zgtetarget VALUE 'KGOM',
            gc_kgpm TYPE zgtetarget VALUE 'KGPM',
* [GO-SD][26.01.28] Add logic for 가온MES  - End.
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
       gv_vbeln   LIKE vbak-vbeln,
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
          vbeln      TYPE zgtsdt1008-vbeln,
          posnr      TYPE zgtsdt1008-posnr,
          wadat_ist  TYPE zgtsdt1007-wadat_ist,
          vstel      TYPE zgtsdt1007-vstel,
          route      TYPE zgtsdt1007-route,
          wadat      TYPE zgtsdt1007-wadat,
          kunnr      TYPE zgtsdt1007-kunnr,
          bstnk      TYPE zgtsdt1007-bstnk,
          volum      TYPE zgtsdt1007-volum,
          voleh      TYPE zgtsdt1007-voleh,
          vsart      TYPE zgtsdt1007-vsart,
* [GO-SD][26.01.28] Add logic for 가온MES  - Start.
          lifsk      TYPE zgtsdt1007-lifsk,
* [GO-SD][26.01.28] Add logic for 가온MES  - End.
          erdat_h    TYPE zgtsdt1007-erdat,
          ernam_h    TYPE zgtsdt1007-ernam,
          erzet_h    TYPE zgtsdt1007-erzet,
          aedat_h    TYPE zgtsdt1007-aedat,
          aezet_h    TYPE zgtsdt1007-aezet,
          aenam_h    TYPE zgtsdt1007-aenam,
          matnr      TYPE zgtsdt1008-matnr,
          arktx      TYPE zgtsdt1008-arktx,
          kdmat      TYPE zgtsdt1008-kdmat,
          pstyv      TYPE zgtsdt1008-pstyv,
          lfimg      TYPE zgtsdt1008-lfimg,
          werks      TYPE zgtsdt1008-werks,
          lgort      TYPE zgtsdt1008-lgort,
          charg      TYPE zgtsdt1008-charg,
          zflag      TYPE zgtsdt1008-zflag,
          wbsta      TYPE zgtsdt1008-wbsta,
* [GO-SD][26.01.28] Add logic for 가온MES  - Start.
          zzyuscd    TYPE zgtsdt1008-zzyuscd,
* [GO-SD][26.01.28] Add logic for 가온MES  - End.
          vgbel      TYPE zgtsdt1008-vgbel,
          vgpos      TYPE zgtsdt1008-vgpos,
          meins      TYPE zgtsdt1008-meins,
          ntgew      TYPE zgtsdt1008-ntgew,
          brgew      TYPE zgtsdt1008-brgew,
          gewei      TYPE zgtsdt1008-gewei,
          vtweg      TYPE zgtsdt1008-vtweg,
          vrkme      TYPE zgtsdt1008-vrkme,
          erdat_i    TYPE zgtsdt1008-erdat,
          erzet_i    TYPE zgtsdt1008-aezet,
          ernam_i    TYPE zgtsdt1008-ernam,
          aedat_i    TYPE zgtsdt1008-aedat,
          aezet_i    TYPE zgtsdt1008-aezet,
          aenam_i    TYPE zgtsdt1008-aenam,
          zsystem_id TYPE zgtsdt1008-zsystem_id,
          zstat      TYPE zgtsdt1008-zstat,
          zmessage   TYPE zgtsdt1008-zmessage,
          ifdat      TYPE zgtsdt1008-ifdat,
          iftim      TYPE zgtsdt1008-iftim,
          ifnam      TYPE zgtsdt1008-ifnam,
          zifkey     TYPE zgtsdt1008-zifkey,

          vstel_nm   TYPE tvstt-vtext,
          kunnr_nm   TYPE kna1-name1,
          vsart_nm   TYPE t173t-bezei,
          system_nm  TYPE char20.
*          INCLUDE    TYPE ZGTSDT1007.
          INCLUDE    TYPE ty_s_alvdef. "ALV Default Fields
DATA : END OF gs_s0100.
DATA : gt_s0100  LIKE TABLE OF gs_s0100,
       gt_header TYPE TABLE OF zgtsdt1007 WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vbeln,
       gt_item   TYPE TABLE OF zgtsdt1008 WITH NON-UNIQUE SORTED KEY k_key COMPONENTS vbeln.

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
