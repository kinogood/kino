*&---------------------------------------------------------------------*
*& Include          ZGTSDR0060TOP
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
*-- Tables
*-----------------------------------------------------------------------
TABLES : mara, vbak,
         zsd0106t, zgtsdt0065, zgtedt2121.

*-----------------------------------------------------------------------
*-- Types
*-----------------------------------------------------------------------
*-- Header Internal Table Types
TYPES : BEGIN OF gty_head,
          check     TYPE char01,                          " Check Box
          stat      TYPE icon_d,                          "  상태

          vkorg     TYPE tvko-vkorg,                      " 영업 조직
          zpjno     TYPE zgtsdt0065-zpjno,                " 프로젝트
          job_no    TYPE zgtsdt0065-job_no,               " 제조지시번호
          job_name  TYPE zgtsdt0065-job_name,             " 제조지시명
          prod_id   TYPE zgtsdt0065-prod_type,            " 제품구분
          wirecnt   TYPE zgtsdt0065-wire_cnt,             " 상
          voltage   TYPE zgtsdt0065-voltage_cd,           " 전압
          condmtrl  TYPE zgtsdt0065-cond_mtrl,            " 도체재질
          ductmtrl  TYPE zgtsdt0065-duct_mtrl_est,        " 덕트재질
          grndtyp   TYPE zgtsdt0065-ground_type,          " 접지
          amphere   TYPE zgtsdt0065-amphere,              " 전류세기
          ipgrade   TYPE zgtsdt0065-ipgrade,              " IP
          vbeln     TYPE zgtsdt0065-vbeln,                " 생산요청번호

          zremark   TYPE bapi_msg,                        " 비고

          zaprv_id  TYPE zgtedt2121-zapprove_userid,      " 설계승인자
          zaprv_dat TYPE zgtedt2121-zapprove_date,        " 설계승인일

          zstat     TYPE zgtsdt0065-zstat,                " 성공/실패
        END OF gty_head,
        gty_t_head TYPE TABLE OF gty_head WITH EMPTY KEY.

*-- Item Internal Table Types
TYPES : BEGIN OF gty_item,
          job_no   TYPE zgtsdt0065-job_no,                " 제조지시번호
          posnr    TYPE zgtsdt0065-posnr,                 " 품목
          matnr    TYPE zgtsdt0065-matnr,                 " 자재
          maktx    TYPE zgtsdt0065-maktx,                 " 자재명
          werks    TYPE zgtsdt0065-werks,                 " 플랜트
          kwmeng   TYPE zgtsdt0065-kwmeng,                " 수량
          meins    TYPE zgtsdt0065-meins,                 " 단위
          ord_len  TYPE zgtsdt0065-ord_len,               " 길이
          len_unit TYPE meins,                            " 길이단위
          ord_wgt  TYPE zgtsdt0065-ord_wgt,               " 중량
          wgt_unit TYPE meins,                            " 중량단위
          erdat    TYPE zgtsdt0065-erdat,                 " 생성일
        END OF gty_item,
        gty_t_item TYPE TABLE OF gty_item WITH EMPTY KEY.

*-- 수행결과 Count Types
TYPES : BEGIN OF gty_rst_cnt,
          total TYPE i,                                   " 전체 Count
          s_cnt TYPE i,                                   " 성공 Count
          f_cnt TYPE i,                                   " 실패 Count
        END OF gty_rst_cnt.

TYPES : gty_0065   TYPE zgtsdt0065,
        gty_t_0065 TYPE TABLE OF gty_0065   WITH EMPTY KEY.

*-----------------------------------------------------------------------
* Internal Table
*-----------------------------------------------------------------------
*-- Header Internal Table
DATA : gt_head     TYPE gty_t_head,
*-- Item Internal Table
       gt_item     TYPE gty_t_item,
       gt_item_all TYPE gty_t_0065.

*-----------------------------------------------------------------------
*-- Structure & Values
*-----------------------------------------------------------------------
DATA : gv_okcode TYPE syucomm,
       gv_sysid  TYPE zgtetarget,
       gv_vkbur  TYPE vkbur.

*-----------------------------------------------------------------------
*-- ALV Global Values
*-----------------------------------------------------------------------
DATA : gt_fcat_head TYPE lvc_t_fcat,
       gt_fcat_item TYPE lvc_t_fcat,

       gt_sort_head TYPE lvc_t_sort,
       gt_sort_item TYPE lvc_t_sort,

       gt_excl_head TYPE ui_functions,
       gt_excl_item TYPE ui_functions.

DATA : gs_layo_head TYPE lvc_s_layo,
       gs_layo_item TYPE lvc_s_layo,

       gs_vari_head TYPE disvariant,
       gs_vari_item TYPE disvariant.

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
*-- Unit
            BEGIN OF gc_meins,
              m  TYPE meins                     VALUE 'M',
              kg TYPE meins                     VALUE 'KG',
            END OF gc_meins,
*-- 판매 문서 유형
            BEGIN OF gc_auart,
              zirp TYPE auart                   VALUE 'ZIRP',
            END OF gc_auart,
*-- 유통경로
            BEGIN OF gc_vtweg,
              10 TYPE vtweg                     VALUE '10',
            END OF gc_vtweg,
*-- 영업 그룹
            BEGIN OF gc_vkgrp,
              172 TYPE vkgrp                    VALUE '172',
            END OF gc_vkgrp,
*-- 영업팀
            BEGIN OF gc_vkbur,
              1710 TYPE vkbur                   VALUE '1710',
            END OF gc_vkbur,
*-- 고객 조건 그룹 4
            BEGIN OF gc_kdkg4,
              4d TYPE kdkg4                     VALUE '4D',
            END OF gc_kdkg4,
*-- 파트너 기능
            BEGIN OF gc_parvw,
              ag TYPE parvw                     VALUE 'AG',         " 판매처
              we TYPE parvw                     VALUE 'WE',         " 납품처
              rg TYPE parvw                     VALUE 'RG',         " 지급처
            END OF gc_parvw,
*-- BP
            BEGIN OF gc_kunnr,
              106022 TYPE kunnr                 VALUE '0000106022',
            END OF gc_kunnr.
