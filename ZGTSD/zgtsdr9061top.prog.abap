*&---------------------------------------------------------------------*
*& Include          ZGTSDR9061TOP
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
*-- Tables
*-----------------------------------------------------------------------
TABLES : vbak, vbap, vbkd,
         zgtsdt9061.

*-----------------------------------------------------------------------
*-- Types
*-----------------------------------------------------------------------
TYPES :BEGIN OF gty_mig_dat,
         bstnk          TYPE vbak-bstnk,
         bstkd_e        TYPE vbkd-bstkd_e,
         vbeln          TYPE vbap-vbeln,
         posnr          TYPE vbap-posnr,
         matnr          TYPE vbap-matnr,
         arktx          TYPE vbap-arktx,
         kwmeng         TYPE vbap-kwmeng,
         vrkme          TYPE vbap-vrkme,

         dfrd_vbeln     TYPE zgtsdt9061-dfrd_vbeln,
         dfrd_posnr     TYPE zgtsdt9061-dfrd_posnr,
         dfrd_dlv_vbeln TYPE zgtsdt9061-dfrd_dlv_vbeln,
         dfrd_dlv_posnr TYPE zgtsdt9061-dfrd_dlv_posnr,
         dfrd_gi_bwart  TYPE zgtsdt9061-dfrd_gi_bwart,
         dfrd_gi_mblnr  TYPE zgtsdt9061-dfrd_gi_mblnr,
         dfrd_rgi_bwart TYPE zgtsdt9061-dfrd_rgi_bwart,
         dfrd_rgi_mblnr TYPE zgtsdt9061-dfrd_rgi_mblnr,

         nw_pjtno       TYPE zgtsdt9061-nw_pjtno,
         nw_jobno       TYPE zgtsdt9061-nw_jobno,
         nw_vbeln       TYPE zgtsdt9061-nw_vbeln,
         nw_posnr       TYPE zgtsdt9061-nw_posnr,
         nw_matnr       TYPE zgtsdt9061-nw_matnr,
         nw_arktx       TYPE zgtsdt9061-nw_arktx,
         nw_kwmeng      TYPE zgtsdt9061-nw_kwmeng,
         nw_vrkme       TYPE zgtsdt9061-nw_vrkme,

         tp_bwart       TYPE zgtsdt9061-tp_bwart,
         tp_mblnr       TYPE zgtsdt9061-tp_mblnr,
         tp_sobkz       TYPE zgtsdt9061-tp_sobkz,
         tp_matnr       TYPE zgtsdt9061-tp_matnr,
         tp_menge       TYPE zgtsdt9061-tp_menge,
         tp_meins       TYPE zgtsdt9061-tp_meins,
         nw_dlv_vbeln   TYPE zgtsdt9061-nw_dlv_vbeln,
         nw_dlv_posnr   TYPE zgtsdt9061-nw_dlv_posnr,

         pod_bwart      TYPE zgtsdt9061-pod_bwart,
         pod_matdoc     TYPE zgtsdt9061-pod_matdoc,
         pod_sobkz      TYPE zgtsdt9061-pod_sobkz,
         pod_matnr      TYPE zgtsdt9061-pod_matnr,
         pod_menge      TYPE zgtsdt9061-pod_menge,
         pod_mein       TYPE zgtsdt9061-pod_mein,

       END OF gty_mig_dat,
       gty_t_mig_dat TYPE TABLE OF gty_mig_dat WITH EMPTY KEY.

*-----------------------------------------------------------------------
* Internal Table
*-----------------------------------------------------------------------
DATA : gt_mig_dat TYPE gty_t_mig_dat.

*-----------------------------------------------------------------------
*-- Structure & Values
*-----------------------------------------------------------------------
DATA : gv_okcode  TYPE syucomm,

       gv_eflag   TYPE char01,
       gv_decimal TYPE xudcpfm.

*-----------------------------------------------------------------------
*-- ALV Global Values
*-----------------------------------------------------------------------
DATA : gt_fcat_0100 TYPE lvc_t_fcat,
       gt_sort_0100 TYPE lvc_t_sort,
       gt_excl_0100 TYPE ui_functions.

DATA : gs_layo_0100 TYPE lvc_s_layo,
       gs_vari_0100 TYPE disvariant.

*-----------------------------------------------------------------------
*-- Constants
*-----------------------------------------------------------------------
CONSTANTS : BEGIN OF gc_spart,
              60 TYPE spart                     VALUE '60',         " 부스닥트
            END OF gc_spart,
*-- Range Sign
            BEGIN OF gc_sign,
              i TYPE ddsign                     VALUE 'I',
              e TYPE ddsign                     VALUE 'E',
            END OF gc_sign,
*-- Range Option
            BEGIN OF gc_optn,
              eq TYPE ddoption                  VALUE 'EQ',
              ne TYPE ddoption                  VALUE 'NE',
              bt TYPE ddoption                  VALUE 'BT',
              cp TYPE ddoption                  VALUE 'CP',
            END OF gc_optn,
*-- ALV Exec LED
            BEGIN OF gc_led,
              red      TYPE char01              VALUE '1',
              yellow   TYPE char01              VALUE '2',
              green    TYPE char01              VALUE '3',
              inactive TYPE char01              VALUE abap_false,
            END OF gc_led,

            BEGIN OF gc_auart,
              zbc2 TYPE auart                   VALUE 'ZBC2',
            END OF gc_auart.
