*&---------------------------------------------------------------------*
*&  Include           ZLER1200_S01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*     SELECTION-SCREEN                                                 *
*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK blk3 WITH FRAME TITLE text-003.
PARAMETERS    : p_rad1 RADIOBUTTON GROUP g1 DEFAULT 'X'
                                            USER-COMMAND CMD,
                p_rad2 RADIOBUTTON GROUP g1 MODIF ID M21.

SELECTION-SCREEN ULINE.

PARAMETERS    : p_rad3 RADIOBUTTON GROUP g1,
                p_rad4 RADIOBUTTON GROUP g1.

SELECTION-SCREEN ULINE.

PARAMETERS    : p_chk1 AS CHECKBOX.
SELECTION-SCREEN END   OF BLOCK blk3.

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_vstel FOR  likp-vstel OBLIGATORY MEMORY ID
                vst," DEFAULT '1000' TO '9999',          "출하지점
                s_werks FOR  lips-werks NO INTERVALS OBLIGATORY , "플랜트
                s_erda1 FOR  zlet0917-erdat OBLIGATORY MODIF ID M11,
                s_wadat FOR  likp-wadat,                 "납품예정일
                s_erdat FOR  likp-erdat OBLIGATORY,      "납품생성일
                s_vbeln FOR  likp-vbeln,                 "납품문서
                s_kunnr FOR  likp-kunnr NO INTERVALS,    "납품처
                s_matnr FOR  mara-matnr.                 "자재코드
SELECTION-SCREEN END   OF BLOCK blk1.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: s_dlvrq  FOR zlet0400-dlvrq,            "출하요청번호
                S_SHSRQ  FOR ZLET0917-SHSRQ,            "CS 요청번호
                s_vkorg  FOR vbak-vkorg NO INTERVALS NO-EXTENSION,"조직
                s_vtweg  FOR vbak-vtweg NO INTERVALS,   "유통경로
                s_spart  FOR vbak-spart NO INTERVALS OBLIGATORY,   "제품군
                s_vkbur  FOR vbak-vkbur NO INTERVALS,   "영업팀
                s_vkgrp  FOR vbak-vkgrp NO INTERVALS ,  "영업그룹
                s_svbeln FOR vbak-vbeln ,               "영업문서
                s_skunnr FOR vbak-kunnr NO INTERVALS.   "판매처
SELECTION-SCREEN END   OF BLOCK blk2.
