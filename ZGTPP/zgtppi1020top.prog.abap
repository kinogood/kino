*&---------------------------------------------------------------------*
*& Include          ZGTPPI1020TOP
*&---------------------------------------------------------------------*
TABLES : mara, mapl, zgtppt1050, t001w, dd07t, makt.

*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
TYPES : BEGIN OF sty_itab,
          matnr TYPE mapl-matnr,
          werks TYPE mapl-werks,
          plnty TYPE mapl-plnty,
          plnnr TYPE mapl-plnnr,
          plnal TYPE mapl-plnal,
          zkriz TYPE mapl-zkriz,
          zaehl TYPE mapl-zaehl,
          plnfl TYPE plas-plnfl,
          plnkn TYPE plas-plnkn,
          ltxa1 TYPE plpo-ltxa1,
          bmsch TYPE plpo-bmsch,
          meinh TYPE plpo-meinh,
          lar01 TYPE plpo-lar01,
          vgw01 TYPE plpo-vgw01,
          vge01 TYPE plpo-vge01,
          lar02 TYPE plpo-lar02,
          vgw02 TYPE plpo-vgw01,
          vge02 TYPE plpo-vge01,
          lar03 TYPE plpo-lar03,
          vgw03 TYPE plpo-vgw03,
          vge03 TYPE plpo-vge03,
          lar04 TYPE plpo-lar04,
          vgw04 TYPE plpo-vgw04,
          vge04 TYPE plpo-vge04,
          lar05 TYPE plpo-lar05,
          vgw05 TYPE plpo-vgw05,
          vge05 TYPE plpo-vge05,
          lar06 TYPE plpo-lar06,
          vgw06 TYPE plpo-vgw06,
          vge06 TYPE plpo-vge06,
          usr04 TYPE plpo-usr04,
          use04 TYPE plpo-use04, " 참조필드 추가 ( USR04 필드의 단위 참조 )
          datuv TYPE plpo-datuv,
          andat TYPE plpo-andat,
          annam TYPE plpo-annam,
          loekz TYPE mapl-loekz,
          arbid TYPE plpo-arbid, "오브젝트 ID
          arbpl TYPE crhd-arbpl, "작업장
          vornr TYPE plpo-vornr,
          mtart TYPE mara-mtart,
          dispo TYPE marc-dispo,
          usr06 TYPE plpo-usr06, "가온전력MES 건조가동시간 U01
          usr07 TYPE plpo-usr07,
        END OF sty_itab,
        tty_itab TYPE TABLE OF sty_itab.
*----------------------------------------------------------------------*
* DATA: Variable
*----------------------------------------------------------------------*
DATA : gv_result  TYPE zo_result,
       gv_message TYPE zo_message.

DATA: gv_ok_code LIKE sy-ucomm.

*----------------------------------------------------------------------*
* DATA: Structure. (Field strings : Working area)
*----------------------------------------------------------------------*
DATA : BEGIN OF gs_cdhdr,
         objectid TYPE cdhdr-objectid,
         plnnr    TYPE mapl-plnnr,
       END OF gs_cdhdr,
       gt_cdhdr LIKE TABLE OF gs_cdhdr.

DATA : BEGIN OF gs_main_disp,
         zifkey     LIKE zgtppt1050-zifkey,
         zseqno     LIKE zgtppt1050-zseqno,
         status     LIKE icon-id,
         zstat      LIKE zgtppt1050-zstat,
         zmessage   LIKE zgtppt1050-zmessage,
         zsystem_id LIKE zgtppt1050-zsystem_id,
         ddtext     LIKE dd07t-ddtext,
         werks      LIKE zgtppt1050-werks,
         name1      LIKE t001w-name1,
         matnr      LIKE zgtppt1050-matnr,
         maktx      LIKE makt-maktx,
         vornr      LIKE zgtppt1050-vornr,
         arbpl      LIKE zgtppt1050-arbpl,
         ltxa1      LIKE zgtppt1050-ltxa1,
         plnnr      LIKE zgtppt1050-plnnr,
         plnal      LIKE zgtppt1050-plnal,
         plnfl      LIKE zgtppt1050-plnfl,
         bmsch      LIKE zgtppt1050-bmsch,
         meinh      LIKE zgtppt1050-meinh,
         lar01      LIKE zgtppt1050-lar01,
         vgw01      LIKE zgtppt1050-vgw01,
         vge01      LIKE zgtppt1050-vge01,
         lar02      LIKE zgtppt1050-lar02,
         vgw02      LIKE zgtppt1050-vgw02,
         vge02      LIKE zgtppt1050-vge02,
         lar03      LIKE zgtppt1050-lar03,
         vgw03      LIKE zgtppt1050-vgw03,
         vge03      LIKE zgtppt1050-vge03,
         lar04      LIKE zgtppt1050-lar04,
         vgw04      LIKE zgtppt1050-vgw04,
         vge04      LIKE zgtppt1050-vge04,
         lar05      LIKE zgtppt1050-lar05,
         vgw05      LIKE zgtppt1050-vgw05,
         vge05      LIKE zgtppt1050-vge05,
         lar06      LIKE zgtppt1050-lar06,
         vgw06      LIKE zgtppt1050-vgw06,
         vge06      LIKE zgtppt1050-vge06,
         usr04      LIKE zgtppt1050-usr04,
         use04      LIKE zgtppt1050-use04,
         datuv      LIKE zgtppt1050-datuv,
         usr07      LIKE plpo-usr07,
         andat      LIKE zgtppt1050-andat,
         annam      LIKE zgtppt1050-annam,
         loekz      LIKE zgtppt1050-loekz,
         ifdat      LIKE zgtppt1050-ifdat,
         iftim      LIKE zgtppt1050-iftim,
         ifnam      LIKE zgtppt1050-ifnam,
       END OF gs_main_disp.
DATA : gt_main_disp LIKE TABLE OF gs_main_disp.

*----------------------------------------------------------------------*
* DATA: Internal Table.
*----------------------------------------------------------------------*
DATA :   gt_itab     TYPE tty_itab.
DATA : gt_ot_itab  TYPE TABLE OF zgtppsif0001. "MES 전송용 테이블
DATA : gt_send TYPE TABLE OF zgtppt1050. "ALV 출력용 테이블 (전송 이력 조회)

*ALV GRID 100
DATA : go_contain_0100 TYPE REF TO cl_gui_docking_container.
DATA : go_grid_0100 TYPE REF TO cl_gui_alv_grid.
DATA : gs_variant TYPE disvariant.
DATA : gs_layout_0100 TYPE lvc_s_layo.
DATA : gt_exclude_0100 TYPE ui_functions.
DATA : gt_fieldcat_0100 TYPE lvc_t_fcat.
