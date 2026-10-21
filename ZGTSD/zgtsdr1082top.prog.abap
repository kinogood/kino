*&---------------------------------------------------------------------*
*& Include          ZGTSDR1082TOP
*&---------------------------------------------------------------------*

*-------------------------------------------------------------------*
*   TABLE DECLARATION                                               *
*-------------------------------------------------------------------*
TABLES : CTU_PARAMS,             " CALL TRANSACTION OPTION..
         KNA1.
*-> CCM : 13.04.2023 11:16:30 / ZLSGSD4
*         knkk.
*<-

*-------------------------------------------------------------------*
*   DATA DECLARATION (INTERNAL TABLE DECLARE)                       *
*-------------------------------------------------------------------*
DATA: BEGIN OF G_ITAB_T OCCURS 0,
        CHK(1),
        VBELN         LIKE LIPS-VBELN,
        POSNR         LIKE LIPS-POSNR,
        BRANCH        LIKE J_1BBRANCH-BRANCH,
        TEXT01        LIKE TVKBT-BEZEI,
        VKBUR         LIKE VBRP-VKBUR,             " 영업팀
        TEXT02        LIKE TVKBT-BEZEI,
        VKGRP         LIKE VBRP-VKGRP,             " 영업그룹
        TEXT03        LIKE TVKBT-BEZEI,
        VTWEG         LIKE VBAK-VTWEG,
        TEXT04        LIKE TVKBT-BEZEI,
        KDKG4         LIKE VBKD-KDKG4,             " 내수/로칼구분
        TEXT05        LIKE TVKBT-BEZEI,
        KUNNR         LIKE VBAK-KUNNR,
        NAME1         LIKE KNA1-NAME1,
        PSTYV         LIKE VBAP-PSTYV,
** 마감완료여부
        COMPL(1),
        WAERK         LIKE VBAK-WAERK,
        KURRF         LIKE VBKD-KURRF,
        WERKS         LIKE VBAP-WERKS,
** billing 미처리
        NETWR_A       LIKE VBAK-NETWR,
        MWSBK_A       LIKE VBRK-MWSBK,  "tax
        SUMAMT_A      LIKE VBAK-NETWR,
** 전표 미생성
        NETWR_B       LIKE VBAK-NETWR,
        MWSBK_B       LIKE VBRK-MWSBK,  "tax
        SUMAMT_B      LIKE VBAK-NETWR,
** 계산서미발행
        NETWR_C       LIKE VBAK-NETWR,
        MWSBK_C       LIKE VBRK-MWSBK,  "tax
        SUMAMT_C      LIKE VBAK-NETWR,
** 계산서발행
        NETWR_D       LIKE VBAK-NETWR,
        MWSBK_D       LIKE VBRK-MWSBK,  "tax
        SUMAMT_D      LIKE VBAK-NETWR,
** 총합
        NETWR_E       LIKE VBAK-NETWR,
        MWSBK_E       LIKE VBRK-MWSBK,  "tax
        SUMAMT_E      LIKE VBAK-NETWR,
** 적송
        NETWR_F       LIKE VBAK-NETWR,
        MWSBK_F       LIKE VBRK-MWSBK,  "tax
        SUMAMT_F      LIKE VBAK-NETWR,
** 적송 미완료
        CTXT(6),
** 보류문서
        CSTOP(1),
        VBELN_A       LIKE VBAK-VBELN,  "보류 SD문서
        DEL(1),         "해당라인 삭제 플래그
        FLAG(1),        "선급비용마스터 등록여부파악
*        f_col           type lvc_t_scol,
*        celltab         type lvc_t_styl,
        ZFLAG1,                    " 무상빌링미처리
        ZFLAG2,                    " 대금청구계획보류
        NETWR_G       LIKE VBAK-NETWR,
        MWSBK_G       LIKE VBRK-MWSBK,  "tax
        SUMAMT_G      LIKE VBAK-NETWR,
        BILLSEQ       LIKE ZBILL_STAT-BILLSEQ,
        BILLSTAT      LIKE ZBILL_STAT-BILLSTAT,
        CBILLTAX(1),

        MESG(70),                               " BDC메세지
        MESG2(70),                              " BDC메세지
        MESG3(70),

* 서비스제공일
        FBUDA         LIKE VBKD-FBUDA,
        BILLSTATX(60),
        POD,
      END OF G_ITAB_T.
DATA: LV_DOMAIN LIKE DD07V-DOMVALUE_L.
DATA: G_TOTCNT TYPE I.
DATA: G_FKDAT_HIGH  LIKE VBRK-FKDAT.
DATA: G_FKDAT_LOW   LIKE VBRK-FKDAT.
DATA: G_FKDAT_RETURN LIKE VBRK-FKDAT.
DATA: LS_KUNNR_SHIP LIKE VBAK-KUNNR.
DATA: G_P_KUNNR_SHIP LIKE KNA1-KUNNR.


RANGES : R_FKDAT FOR VBRK-FKDAT.
**========================
** BDC관련 Internal Table
**========================
** MESSAGES OF CALL TRANSACTION
DATA: G_MSG_T LIKE BDCMSGCOLL
              OCCURS 0 WITH HEADER LINE.

** BDCDATA DECLARE
DATA: BEGIN OF BDCTAB OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA: END OF BDCTAB.


DATA : BEGIN OF GT_POD OCCURS 0,
         VBELN TYPE VBELN_VF,
         POSNR TYPE POSNR_VF,
         ERR   TYPE CHAR1,
       END OF GT_POD,
       GT_VF_C LIKE TABLE OF GT_POD WITH HEADER LINE,
       GT_1010 TYPE TABLE OF ZGTSDT1010
               WITH NON-UNIQUE SORTED KEY K_KEY COMPONENTS VBELN_VF
               WITH NON-UNIQUE SORTED KEY K_KEY2 COMPONENTS MBLNR
               WITH NON-UNIQUE SORTED KEY K_KEY3 COMPONENTS VBELN MBLNR.

DATA : BEGIN OF GS_POD_LIST,
         VBELN    TYPE VBELN_VF,
         POSNR    TYPE POSNR_VF,
         VBELN_VF TYPE VBELN_VF,
         POSNR_VF TYPE POSNR_VF,
         MBLNR    TYPE MBLNR,
         RFMNG    TYPE RFMNG,
         POSNN    TYPE POSNR,
         PODAT    TYPE LIKP-WADAT_IST,
       END OF GS_POD_LIST,
       GT_POD_LIST LIKE TABLE OF GS_POD_LIST
          WITH NON-UNIQUE SORTED KEY K_KEY  COMPONENTS VBELN_VF
*          WITH NON-UNIQUE SORTED KEY K_KEY2 COMPONENTS VBELN
          WITH NON-UNIQUE SORTED KEY K_KEY3 COMPONENTS VBELN MBLNR
          WITH NON-UNIQUE SORTED KEY K_KEY4 COMPONENTS MBLNR.

DATA : BEGIN OF GS_LIP_STS,
         VBELN TYPE LIPS-VBELN,
         POSNR TYPE LIPS-POSNR,
         FKSTK TYPE LIKP-FKSTK,
         GBSTK TYPE LIKP-GBSTK,
         PDSTK TYPE LIKP-PDSTK,
         FKSTA TYPE LIPS-FKSTA,
         PDSTA TYPE LIPS-PDSTA,
         KZPOD TYPE LIPS-KZPOD,
         VGBEL TYPE LIPS-VGBEL,
         VGPOS TYPE LIPS-VGPOS,
         CHARG TYPE LIPS-CHARG,
         LFIMG TYPE LIPS-LFIMG,
         MEINS TYPE LIPS-MEINS,
         UECHA TYPE LIPS-UECHA,
         MBLNR TYPE MBLNR,
       END OF GS_LIP_STS,
       GT_LIP_STS LIKE TABLE OF GS_LIP_STS.

DATA : BEGIN OF GT_VBRP OCCURS 0,
         VGBEL TYPE VBELN_VF,
         VGPOS TYPE POSNR_VF,
       END OF GT_VBRP.

DATA: BEGIN OF G_BDC_T OCCURS 0,
        MARK,
        VBELN(10),              " 문서번호
        POSNR(6),               " 품목번호
        DATE1     LIKE VBRK-FKDAT,
        DATE2     LIKE SY-DATUM,
        SUBRC     LIKE SY-SUBRC,    " BDC수행결과
        MESG(70),               " BDC메세지
      END OF G_BDC_T.

** 부가세/청구액조정 Popup 변수
DATA : G_P_AUART     LIKE VBAK-AUART,
       G_P_VKORG     LIKE VBAK-VKORG,
       G_P_VTWEG     LIKE VBAK-VTWEG,
       G_P_SPART     LIKE VBAK-SPART,
       G_P_VKBUR     LIKE VBAK-VKBUR,
       G_P_VKGRP     LIKE VBAK-VKGRP,
       G_P_DATE(8),
       G_P_KUNNR     LIKE KNA1-KUNNR,
       G_P_NAME1     LIKE KNA1-NAME1,
       G_P_MATNR     LIKE MARA-MATNR,
       G_P_MAKTX     LIKE MAKT-MAKTX,
       G_P_WERKS     LIKE LIPS-WERKS,
       G_P_TAX       TYPE P DECIMALS 0,
       G_C_TAX(15),
       G_P_WAERK     LIKE VBAP-WAERK,                  " 통화
       G_P_ZAMNT     LIKE VBAP-NETWR,                  " 청구액
       G_C_ZAMNT(15).

DATA : G_IMODE  LIKE HRVCOST-MODE,
       GT_FCODE TYPE TABLE OF SY-UCOMM.
DATA : GV_VBELN LIKE VBAK-VBELN." CHM2510-00065
*----------------------------------------------------------------------*
* DEFINE
*----------------------------------------------------------------------*
DEFINE __CLE.
  CLEAR: &1, &1[].
END-OF-DEFINITION.

DEFINE __RNG.
  &1-SIGN   = &2.
  &1-OPTION = &3.
  &1-LOW    = &4.
  &1-HIGH    = &5.
  APPEND &1. CLEAR &1.
END-OF-DEFINITION.

DEFINE __ALPHA_IN.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.

DEFINE __ALPHA_OU.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = &1
    IMPORTING
      OUTPUT = &2.
END-OF-DEFINITION.
