*&---------------------------------------------------------------------*
*& Include          ZGTSDR1080_CHECK_TOP
*&---------------------------------------------------------------------*

TABLES : vbrk, lips, likp, VBAK, VBKD, VBUP.



RANGES : r_xblnr FOR zmseg-xblnr.


*&---------------------------------------------------------------------*
*&  Core Logic: MATDOC & VBAK/VBAP 기반 적송/장기재고 추출 쿼리 (현업 오조작 방어용)
*&---------------------------------------------------------------------*

DATA: BEGIN OF ty_data Occurs 0,
         MARK,
         vbeln     LIKE lips-vbeln,     " 납품번호
         posnr     LIKE lips-posnr,     " 품목번호
         vgbel     LIKE vbak-vbeln,     " 주문번호 (오더)
         vgpos     LIKE vbap-posnr,     " 주문품목번호
         matnr     LIKE matdoc-matnr,   " 자재코드
         maktx     LIKE makt-maktx,     " 자재명

         vrkme     LIKE lips-vrkme,   " 단위
        lfimg    LIKE  lips-lfimg,                  " 납품수량
        vrkme_o   LIKE vbap-vrkme,                " 판매단위-오더
         vkgrp     LIKE vbak-vkgrp,     " 영업그룹
         bezei2   LIKE tvgrt-bezei,                " 영업그룹명
        kwmeng        LIKE vbap-kwmeng,                " 주문수량
        waerk          LIKE vbap-waerk,                  " 통화

         vkbur     LIKE vbak-vkbur,     " 영업팀
         bezei     LIKE tvkbt-bezei,                 " 영업팀명
         kunag     LIKE vbak-kunnr,     " 지급처(고객)
         name1     LIKE adrc-name1,     " 지급처명
         kunnr     LIKE likp-kunnr,     " 납품처
         name1_sh  LIKE adrc-name1,     " 납품처명
         wadat_ist LIKE likp-wadat_ist, " G/I Date / 출고일
         fkdat     LIKE vbrk-fkdat,     " 거래명세서 발행일자 (청구일)
         netwr     LIKE vbrp-netwr,     " 납품금액
        k_netwr   LIKE vbap-netwr,                " 계약금액(원화)
        netpr      LIKE vbap-netpr,                  " 단가
        netpr2    TYPE P DECIMALS 5,                       " 단가2

        kursk       LIKE vbkd-kursk,                  " 환율
        f_wadat   LIKE likp-wadat,                "최초 출고일
       vbeln_v     LIKE likp-vbeln,                "최초 납품문서
       iv_date     LIKE ZLET0005-iv_date,    "거래명세서 발행일자

* 수량 필드들
         gi_qty    LIKE mseg-menge,     " 출고 수량 (MATDOC 기반)
         fk_qty    LIKE vbrp-fkimg,     " 청구(판매) 수량
         stock_it  LIKE mseg-menge,     " 운송중/적송 재고 수량
       END OF ty_data.

DATA: BEGIN OF GT_DATA OCCURS 0.
  INCLUDE STRUCTURE TY_DATA.
DATA : END OF GT_DATA.

DATA : BEGIN OF GS_DATA OCCURS 0.
  INCLUDE STRUCTURE TY_DATA.
  DATA : END OF GS_DATA.

*              TYPE STANDARD TABLE OF ty_data,
*      gs_data TYPE ty_data.

DATA: BEGIN OF gt_vbfa_all OCCURS 0,
        vbelv LIKE vbfa-vbelv,
        posnv LIKE vbfa-posnv,
        vbeln LIKE vbfa-vbeln,
        posnn LIKE vbfa-posnn,
        bwart LIKE vbfa-bwart,
        erdat LIKE vbfa-erdat,
      END   OF gt_vbfa_all.

DATA: c_vbtyp_n LIKE vbfa-vbtyp_n VALUE 'J',
      c_vbtyp_v LIKE vbfa-vbtyp_v VALUE 'J',
      c_lfart   LIKE likp-lfart   VALUE 'LF'.

*DATA : BEGIN OF lt_zmseg OCCURS 0 .
*DATA :
*  sjahr LIKE zmseg-sjahr,
*  smbln LIKE zmseg-smbln.
*DATA : END OF lt_zmseg .
