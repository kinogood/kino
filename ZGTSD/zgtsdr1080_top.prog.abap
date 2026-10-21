*&---------------------------------------------------------------------*
*&  Include           ZGTSDR1080_TOP                                  *
*&---------------------------------------------------------------------*
*-- tables
TABLES: vbrk, vbrp, vbfa, likp, lips, mara, vbkd, tvkggt,
        vbak, vbap, vkdfs, j_1bbranch, t001w, kna1, s001,
        ztevbl00, ztevfd03, tspat, tcurx.

*-- includes
INCLUDE <icon>.
INCLUDE <symbol>.

TYPE-POOLS: vsep, slis.

*-- POD 확적여부 정보 Types 2025.02.13 - Start
TYPES : BEGIN OF gty_pod_chk,
          branch  TYPE j_1bbranc_,              " 사업장
          vkbur   TYPE vkbur,                   " 영업팀
          vkgrp   TYPE vkgrp,                   " 영업그룹
          vtweg   TYPE vtweg,                   " 유통경로
          kdkg4   TYPE kdkg4,                   " 내수/로컬 구분
          kunnr   TYPE kunag,                   " 판매처

          pod_flg TYPE char01,                  " POD 확정여부
        END OF gty_pod_chk,
        gty_t_pod_chk TYPE TABLE OF gty_pod_chk WITH EMPTY KEY.

*-- POD 확적여부 정보 Types 2025.02.13 - End

DATA : g_events_t           TYPE slis_t_event,
       g_list_top_of_page_t TYPE slis_t_listheader,
       g_fieldcat_t         TYPE slis_t_fieldcat_alv  WITH HEADER LINE,
       g_fieldcat_m         TYPE slis_t_fieldcat_alv  WITH HEADER LINE,
       g_field_t            TYPE slis_t_fieldcat_alv,
       g_sort_t             TYPE slis_t_sortinfo_alv.

*     구조
DATA: g_layout_s              TYPE slis_layout_alv,
      g_exit_caused_by_user_s TYPE slis_exit_by_user,
      g_variant_s             TYPE disvariant,
      g_fieldcat_s            TYPE slis_fieldcat_alv,
      g_sort_s                TYPE slis_sortinfo_alv,
      g_keyinfo_s             TYPE slis_keyinfo_alv.

*      일반변수
DATA :g_exit_caused_by_caller TYPE c,
      g_save                  TYPE c,
      g_repid                 TYPE sy-repid,
      g_program               LIKE sy-repid,
      g_tabname_header        TYPE slis_tabname,
      g_tabname_item          TYPE slis_tabname.

DATA: g_count   TYPE i,
      gt_status TYPE TABLE OF sy-ucomm.

*-> CCM : 13.04.2023 18:16:13 / ZLSGSD4
*DATA : ls_gbstk LIKE VBUK-GBSTK.
DATA : ls_gbstk LIKE vbak-gbstk.
*<-

CONSTANTS: c_status_set   TYPE slis_formname VALUE 'PF_STATUS_SET',
           c_user_command TYPE slis_formname VALUE 'USER_COMMAND',
           c_top_of_page  TYPE slis_formname VALUE 'TOP_OF_PAGE',
           c_top_of_list  TYPE slis_formname VALUE 'TOP_OF_LIST',
           c_end_of_list  TYPE slis_formname VALUE 'END_OF_LIST'.



*-- Types
TYPES: BEGIN OF ty_csks,
         kostl LIKE csks-kostl,
         prctr LIKE csks-prctr,
         gsber LIKE csks-gsber,
       END   OF ty_csks.


*--- Internal tables
DATA: BEGIN OF gt_itab OCCURS 0,
        branch      LIKE j_1bbranch-branch,
        vkbur       LIKE vbrp-vkbur, "영업팀
        vkgrp       LIKE vbrp-vkgrp, "영업그룹
        vtweg       LIKE vbak-vtweg,
        kdkg4       LIKE vbkd-kdkg4, " 내수/로칼구분
        kunnr       LIKE vbak-kunnr,
        waerk       LIKE vbak-waerk,
*        kurrf like vbkd-kurrf,
        werks       LIKE vbap-werks,

        netwr_pod   LIKE vbak-netwr, "운송중 재고 금액

* billing 미처리
        netwr_a     LIKE vbak-netwr,
        mwsbk_a     LIKE vbrk-mwsbk,  "tax
        sumamt_a    LIKE vbak-netwr,
* 전표 미생성
        netwr_b     LIKE vbak-netwr,
        mwsbk_b     LIKE vbrk-mwsbk,  "tax
        sumamt_b    LIKE vbak-netwr,
* 계산서미발행
        netwr_c     LIKE vbak-netwr,
        mwsbk_c     LIKE vbrk-mwsbk,  "tax
        sumamt_c    LIKE vbak-netwr,
* 계산서발행
        netwr_d     LIKE vbak-netwr,
        mwsbk_d     LIKE vbrk-mwsbk,  "tax
        sumamt_d    LIKE vbak-netwr,
* 총합
        netwr_e     LIKE vbak-netwr,
        mwsbk_e     LIKE vbrk-mwsbk,  "tax
        sumamt_e    LIKE vbak-netwr,
* 적송
        netwr_f     LIKE vbak-netwr,
        mwsbk_f     LIKE vbrk-mwsbk,  "tax
        sumamt_f    LIKE vbak-netwr,
* 적송 미완료
        ctxt(6),
*보류문서
        cstop(1),
*마감완료여부
        compl(1),
        vbeln_a     LIKE vbak-vbeln,

        zflag1,                    " 무상빌링미처리
        zflag2,                    " 대금청구계획보류

* 계산서전송상태
        netwr_g     LIKE vbak-netwr,
        mwsbk_g     LIKE vbrk-mwsbk,  "tax
        sumamt_g    LIKE vbak-netwr,
        billseq     LIKE zbill_stat-billseq,
        billstat    LIKE zbill_stat-billstat,
        cbilltax(1),
      END   OF gt_itab.

***[start]전자세금계산서 전송 변수 선언[C20101019_56700]
DATA : ls_fkdat_rl LIKE vbrk-fkdat.
DATA : ls_gjahr            LIKE zbill_trans-gjahr,
       ls_monat            LIKE zbill_trans-monat,
       ls_report_except_yn LIKE zbill_trans-report_except_yn.
***[end]전자세금계산서 전송 변수 선언

DATA: BEGIN OF gt_display OCCURS 0,
        chk(1),
*        icon(30),
*-- POD 확정 여부 Icon 추가 2025.02.13 - Start
        pod_stat    LIKE icon-id,               " POD
*-- POD 확정 여부 Icon 추가 2025.02.13 - End

*        light       TYPE char01,                 " 처리상태 icon
        branch      LIKE j_1bbranch-branch,
        text01      LIKE tvkbt-bezei,
        vkbur       LIKE vbrp-vkbur, "영업팀
        text02      LIKE tvkbt-bezei,
        vkgrp       LIKE vbrp-vkgrp, "영업그룹
        text03      LIKE tvkbt-bezei,
        vtweg       LIKE vbak-vtweg,
        text04      LIKE tvkbt-bezei,
        kdkg4       LIKE vbkd-kdkg4, " 내수/로칼구분
        text05      LIKE tvkbt-bezei,
        kunnr       LIKE vbak-kunnr,
        name1       LIKE kna1-name1,
        pstyv       LIKE vbap-pstyv,
*마감완료여부
        compl(1),
        waerk       LIKE vbak-waerk,
        kurrf       LIKE vbkd-kurrf,
        werks       LIKE vbap-werks,

        netwr_pod   LIKE vbak-netwr, "운송중 재고 금액
* billing 미처리
        netwr_a     LIKE vbak-netwr,
        mwsbk_a     LIKE vbrk-mwsbk,  "tax
        sumamt_a    LIKE vbak-netwr,
* 전표 미생성
        netwr_b     LIKE vbak-netwr,
        mwsbk_b     LIKE vbrk-mwsbk,  "tax
        sumamt_b    LIKE vbak-netwr,
* 계산서미발행
        netwr_c     LIKE vbak-netwr,
        mwsbk_c     LIKE vbrk-mwsbk,  "tax
        sumamt_c    LIKE vbak-netwr,
* 계산서발행
        netwr_d     LIKE vbak-netwr,
        mwsbk_d     LIKE vbrk-mwsbk,  "tax
        sumamt_d    LIKE vbak-netwr,
* 총합
        netwr_e     LIKE vbak-netwr,
        mwsbk_e     LIKE vbrk-mwsbk,  "tax
        sumamt_e    LIKE vbak-netwr,

* 적송
        netwr_f     LIKE vbak-netwr,
        mwsbk_f     LIKE vbrk-mwsbk,  "tax
        sumamt_f    LIKE vbak-netwr,

* 적송 미완료
        ctxt(6),

*보류문서
        cstop(1),
        vbeln_a     LIKE vbak-vbeln,  "보류 SD문서
        del(1),         "해당라인 삭제 플래그
        flag(1),        "선급비용마스터 등록여부파악
        f_col       TYPE lvc_t_scol,
        celltab     TYPE lvc_t_styl,
* 계산서전송상태
        netwr_g     LIKE vbak-netwr,
        mwsbk_g     LIKE vbrk-mwsbk,  "tax
        sumamt_g    LIKE vbak-netwr,
        billseq     LIKE zbill_stat-billseq,
        billstat    LIKE zbill_stat-billstat,
        cbilltax(1),
        zflag1,                    " 무상빌링미처리
        zflag2,                    " 대금청구계획보류
        pod,

* 서비스제공일
        fbuda       LIKE vbkd-fbuda,
      END   OF gt_display.

DATA: BEGIN OF gt_billdata OCCURS 0,
        chk(1),
        branch   LIKE j_1bbranch-branch,
        vkbur    LIKE vbrp-vkbur, "영업팀
        vkgrp    LIKE vbrp-vkgrp, "영업그룹
        vtweg    LIKE vbak-vtweg,
        kdkg4    LIKE vbkd-kdkg4, " 내수/로칼구분
        kunnr    LIKE vbak-kunnr,
        vbeln    LIKE lips-vbeln,
        netwr    LIKE vbak-netwr,
        waerk    LIKE vbak-waerk,
        kurrf    LIKE vbkd-kurrf,
        mwsbk    LIKE vbrk-mwsbk,  "tax
        sortkri  LIKE vkdfs-sortkri,
        vbtyp    LIKE vkdfs-vbtyp,
        fkrel    LIKE vbap-fkrel,
        tax1     LIKE vbrk-mwsbk,
        del(1),         "해당라인 삭제 플래그
        flag(1),        "
        abgru    LIKE vbap-abgru,

        matnr    LIKE vbap-matnr,
        mtart    LIKE mara-mtart,
        posnr    LIKE vbap-posnr,
        pstyv    LIKE vbap-pstyv,
        faksp    LIKE fplt-faksp,
        werks    LIKE vbap-werks,
* 서비스제공일
        fbuda    LIKE vbkd-fbuda,
        vbeln_vl LIKE likp-vbeln,
        posnr_vl LIKE lips-posnr,
        lfimg    LIKE lips-lfimg,
        pod      TYPE char1,
      END   OF gt_billdata.

** Tool주문의 처리를 위함.
DATA: BEGIN OF g_tmp_t OCCURS 0.
        INCLUDE STRUCTURE gt_billdata.
DATA: END OF g_tmp_t.

DATA: BEGIN OF gt_deldata OCCURS 0,
        chk(1),
        branch  LIKE j_1bbranch-branch,
        vkbur   LIKE vbrp-vkbur, "영업팀
        vkgrp   LIKE vbrp-vkgrp, "영업그룹
        vtweg   LIKE vbak-vtweg,
        kdkg4   LIKE vbkd-kdkg4, " 내수/로칼구분
        kunnr   LIKE vbak-kunnr,
        kwmeng  LIKE vbap-kwmeng,
        vbeln   LIKE lips-vbeln,
        posnr   LIKE lips-posnr,
        lfimg   LIKE lips-lfimg,
        netpr   LIKE vbap-netpr,  "단가
        kpein   LIKE vbap-kpein,
        kmein   LIKE vbap-kmein,
        netwr   LIKE vbak-netwr,
        waerk   LIKE vbak-waerk,
        kurrf   LIKE vbkd-kurrf,
        mwsbk   LIKE vbrk-mwsbk,  "tax
        rfmng   LIKE vbfa-rfmng,
        plmin   LIKE vbfa-plmin,
        vbtyp   LIKE vkdfs-vbtyp,
        fkrel   LIKE vbap-fkrel,
        tax1    LIKE vbrk-mwsbk,
        vgbel   LIKE lips-vgbel,
        vgpos   LIKE lips-vgpos,
        charg   LIKE lips-charg,  "batch 번호
        del(1),         "해당라인 삭제 플래그
        flag(1),        "

        r_netwr LIKE vbak-netwr,   " 잔량관리한 금액
        r_mwsbk LIKE vbrk-mwsbk,   " 잔량관리한 tax

        zflag1,                    " 무상빌링미처리
        zflag2,                    " 대금청구계획보류

        auart   LIKE vbak-auart,     " 오더유형
        werks   LIKE vbap-werks,
        pod     TYPE char1,
      END   OF gt_deldata.

*빌링문서
DATA: BEGIN OF gt_noslip OCCURS 0,
        chk(1),
        branch   LIKE j_1bbranch-branch,
        vkbur    LIKE vbrp-vkbur, "영업팀
        vkgrp    LIKE vbrp-vkgrp, "영업그룹
        vtweg    LIKE vbak-vtweg,
        kdkg4    LIKE vbkd-kdkg4, " 내수/로칼구분
        kunnr    LIKE vbak-kunnr,
        vbeln    LIKE lips-vbeln,
        netwr    LIKE vbak-netwr,
        waerk    LIKE vbak-waerk,
        kurrf    LIKE vbkd-kurrf,
        mwsbk    LIKE vbrk-mwsbk,  "tax
        vbtyp    LIKE vkdfs-vbtyp,
        rfbsk    LIKE vbrk-rfbsk,
        fkart    LIKE vbrk-fkart,
        zzbilnr  LIKE vbrk-zzbilnr,
        zzlcno   LIKE vbrk-zzlcno,
        zuonr    LIKE vbrk-zuonr,
        del(1),         "해당라인 삭제 플래그
        werks    LIKE vbap-werks,
        taxk1    LIKE vbrk-taxk1,
        billseq  LIKE zbill_stat-billseq,
        billstat LIKE zbill_stat-billstat,
        flag(1),

*-- POD 여부확인 위한 납품문서 정보 구성 추가 2025.02.13 - Start
        do_no    TYPE vbeln_vl,
*-- POD 여부확인 위한 납품문서 정보 구성 추가 2025.02.13 - End
        lmon,
        pod,
      END   OF gt_noslip.

DATA : BEGIN OF gt_do_info OCCURS 0,
         vbeln TYPE vbeln,
         vbelv TYPE vbeln,
       END OF gt_do_info.


*총합
DATA: BEGIN OF gt_sum OCCURS 0,
        branch    LIKE j_1bbranch-branch,
        vkbur     LIKE vbrp-vkbur, "영업팀
        vkgrp     LIKE vbrp-vkgrp, "영업그룹
        vtweg     LIKE vbak-vtweg,
        kdkg4     LIKE vbkd-kdkg4, " 내수/로칼구분
        kunnr     LIKE vbak-kunnr,
        vbeln     LIKE lips-vbeln,
        netwr_pod LIKE vbak-netwr, "운송중 재고 금액
        netwr     LIKE vbak-netwr,
*        waerk like vbak-waerk,
*        kurrf like vbkd-kurrf,
        mwsbk     LIKE vbrk-mwsbk,  "tax
      END   OF gt_sum.


DATA: BEGIN OF gt_temp OCCURS 0,
        chk(1),
        branch  LIKE j_1bbranch-branch,
        vkbur   LIKE vbrp-vkbur, "영업팀
        vkgrp   LIKE vbrp-vkgrp, "영업그룹
        vtweg   LIKE vbak-vtweg,
        kdkg4   LIKE vbkd-kdkg4, " 내수/로칼구분
        kunnr   LIKE vbak-kunnr,
        name1   LIKE kna1-name1,
        zlcno   LIKE vbrk-zzlcno,
        zuonr   LIKE vbrk-zuonr,
        vbeln   LIKE lips-vbeln,
        posnr   LIKE lips-posnr,
        netwr_a LIKE vbak-netwr,
        netwr_b LIKE vbak-netwr,
        netwr_c LIKE vbak-netwr,
        waerk   LIKE vbak-waerk,
        kurrf   LIKE vbkd-kurrf,
        netwr_d LIKE vbak-netwr,  "원화금액
        netwr_e LIKE vbak-netwr,
        netwr_f LIKE vbak-netwr,
        waers   LIKE vbak-waerk,
      END   OF gt_temp.

DATA : gt_temp2 LIKE gt_temp OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_header OCCURS 0,
        mark,
        expand,
        light,
        branch   LIKE j_1bbranch-branch,
        vkbur    LIKE vbrp-vkbur, "영업팀
        vkgrp    LIKE vbrp-vkgrp, "영업그룹
        vtweg    LIKE vbak-vtweg,
        kdkg4    LIKE vbkd-kdkg4, " 내수/로칼구분
        kunnr    LIKE vbak-kunnr,
        name1    LIKE kna1-name1,
        zlcno    LIKE vbrk-zzlcno,
        zuonr    LIKE vbrk-zuonr,
        sumamt_a LIKE vbak-netwr,
        sumamt_b LIKE vbak-netwr,
        sumamt_c LIKE vbak-netwr,
        waerk    LIKE vbak-waerk,
      END OF gt_header.

DATA: BEGIN OF gt_items OCCURS 0,
*        branch like j_1bbranch-branch,
*        vkbur like vbrp-vkbur, "영업팀
*        vkgrp like vbrp-vkgrp, "영업그룹
*        vtweg like vbak-vtweg,
*        kdkg4 like vbkd-kdkg4, " 내수/로칼구분
*        kunnr like vbak-kunnr,
*        name1 like kna1-name1,
        zlcno   LIKE vbrk-zzlcno,
        zuonr   LIKE vbrk-zuonr,
        vbeln   LIKE lips-vbeln,
        posnr   LIKE lips-posnr,
        netwr_a LIKE vbak-netwr,
        netwr_b LIKE vbak-netwr,
        netwr_c LIKE vbak-netwr,
        waerk   LIKE vbak-waerk,
        kurrf   LIKE vbkd-kurrf,
      END OF gt_items.

* data selection용 임시 table
DATA: lt_display    LIKE gt_display OCCURS 0 WITH HEADER LINE.

** 상세내역 조회시 사용할 Data Gethering
DATA: BEGIN OF lt_display2 OCCURS 0.
        INCLUDE STRUCTURE gt_display.
DATA:   vbeln LIKE lips-vbeln,
        posnr LIKE lips-posnr,

*-- POD 여부확인 위한 납품문서 정보 구성 추가 2025.02.13 - Start
        do_no TYPE vbeln_vl.
*-- POD 여부확인 위한 납품문서 정보 구성 추가 2025.02.13 - End
DATA: END OF lt_display2.

** 상세리스트 프로그램으로 넘겨줄 TBL.
DATA: BEGIN OF g_itab_t OCCURS 0,
        chk(1),
        vbeln       LIKE lips-vbeln,
        posnr       LIKE lips-posnr,
        branch      LIKE j_1bbranch-branch,
        text01      LIKE tvkbt-bezei,
        vkbur       LIKE vbrp-vkbur, "영업팀
        text02      LIKE tvkbt-bezei,
        vkgrp       LIKE vbrp-vkgrp, "영업그룹
        text03      LIKE tvkbt-bezei,
        vtweg       LIKE vbak-vtweg,
        text04      LIKE tvkbt-bezei,
        kdkg4       LIKE vbkd-kdkg4, " 내수/로칼구분
        text05      LIKE tvkbt-bezei,
        kunnr       LIKE vbak-kunnr,
        name1       LIKE kna1-name1,
        pstyv       LIKE vbap-pstyv,
*마감완료여부
        compl(1),
        waerk       LIKE vbak-waerk,
        kurrf       LIKE vbkd-kurrf,
        werks       LIKE vbap-werks,

* billing 미처리
        netwr_a     LIKE vbak-netwr,
        mwsbk_a     LIKE vbrk-mwsbk,  "tax
        sumamt_a    LIKE vbak-netwr,
* 전표 미생성
        netwr_b     LIKE vbak-netwr,
        mwsbk_b     LIKE vbrk-mwsbk,  "tax
        sumamt_b    LIKE vbak-netwr,
* 계산서미발행
        netwr_c     LIKE vbak-netwr,
        mwsbk_c     LIKE vbrk-mwsbk,  "tax
        sumamt_c    LIKE vbak-netwr,
* 계산서발행
        netwr_d     LIKE vbak-netwr,
        mwsbk_d     LIKE vbrk-mwsbk,  "tax
        sumamt_d    LIKE vbak-netwr,
* 총합
        netwr_e     LIKE vbak-netwr,
        mwsbk_e     LIKE vbrk-mwsbk,  "tax
        sumamt_e    LIKE vbak-netwr,
* 적송
        netwr_f     LIKE vbak-netwr,
        mwsbk_f     LIKE vbrk-mwsbk,  "tax
        sumamt_f    LIKE vbak-netwr,
* 적송 미완료
        ctxt(6),
*보류문서
        cstop(1),
        vbeln_a     LIKE vbak-vbeln,  "보류 SD문서
        del(1),         "해당라인 삭제 플래그
        flag(1),        "선급비용마스터 등록여부파악

        zflag1,                    " 무상빌링미처리
        zflag2,                    " 대금청구계획보류
* 계산서전송상태
        netwr_g     LIKE vbak-netwr,
        mwsbk_g     LIKE vbrk-mwsbk,  "tax
        sumamt_g    LIKE vbak-netwr,
        billseq     LIKE zbill_stat-billseq,
        billstat    LIKE zbill_stat-billstat,
        cbilltax(1),

        mesg(70),                               " BDC메세지
        mesg2(70),                              " BDC메세지



      END OF g_itab_t.

** 지급처를 담고있는 Internal TBL
DATA: BEGIN OF g_payer_t OCCURS 0,
        vbeln LIKE vbrk-vbeln,
        kunrg LIKE vbrk-kunrg,
        name1 LIKE kna1-name1,
      END OF g_payer_t.

DATA: gv_point(10) TYPE p DECIMALS 5.

* BDC처리용 table: MM02
DATA: BEGIN OF  gt_f13 OCCURS 0,
        zuonr LIKE vbrk-zuonr,
      END   OF  gt_f13.

* BDC message table
DATA: BEGIN   OF bdc_msg OCCURS 0,
        msgtyp    LIKE  bdcmsgcoll-msgtyp,
        item(30),
        text(100),
      END     OF bdc_msg.

FIELD-SYMBOLS <gfs_data> TYPE STANDARD TABLE.

TYPES : BEGIN OF ty_s_alvdef,
          statu TYPE icon_d,     "신규/변경/삭제 상태 ICON
          msg   TYPE text100,
          insrt TYPE char1,      "신규 여부 Flag : 'X' or ' '
          modi  TYPE char1,      "변경 여부 Flag : 'X' or ' '
          sel   TYPE char1,
          cells TYPE lvc_t_styl, "Cell Style
          cellc TYPE lvc_t_styl, "Cell Color
        END OF ty_s_alvdef.


DATA  : BEGIN OF gs_s0100,
          vtweg       TYPE vbak-vtweg,
          spart       TYPE vbak-spart,
          vkbur       TYPE vbak-vkbur,
          vkgrp       TYPE vbak-vkgrp,
          kdkg4       TYPE vbkd-kdkg4,
          kunag       TYPE likp-kunag,
          kunag_nm    TYPE kna1-name1,
          vbevl       TYPE likp-vbeln,
          posvl       TYPE lips-posnr,
          matnr       TYPE lips-matnr,
          maktx       TYPE makt-maktx,
          lfimg       TYPE lips-lfimg,
          charg       TYPE lips-charg,
          werks       TYPE lips-charg,
          sit_free    TYPE mb5sit-sit_free,    "대금 청구 수량
          sit_gi      TYPE mb5sit-sit_gi,      "운송중 재고 수량
          kbetr       TYPE komv-kbetr,         "단가
          sit_amt     TYPE komv-kbetr,         "운송중재고금액
          waerk       TYPE vbak-waerk,
          vrkme       TYPE lips-vrkme,
          vbeln       TYPE vbak-vbeln,
          posnr       TYPE vbap-posnr,
          branch      TYPE t001w-j_1bbranch,
          fkimg       TYPE vbrp-fkimg,
          netwr       TYPE vbrp-fkimg,
          lifnr       TYPE kna1-lifnr,
          name1       TYPE kna1-name1,
          bal_sts     TYPE char10,
          posnn       TYPE posnr,
          vbevl_o     TYPE vbeln_vl,
          posvl_o     TYPE posnr_vl,
          wadat_ist_o TYPE likp-wadat_ist,     "
          wadat_ist   TYPE likp-wadat_ist,     "POD/Billing일자
          wadat_ist2  TYPE likp-wadat_ist,     "통문(GI)일자
          zlfimg      TYPE lfimg,              "인수 예정 수량
          zerdat      TYPE erdat,              "인수예정일자
          zconf       TYPE char30.             "인수협의내용
          INCLUDE    TYPE ty_s_alvdef.        "ALV Default Fields
DATA : END OF gs_s0100,
gv_cflag.

DATA : BEGIN OF gs_s0300,
         confirm,
         zlfimg  TYPE lfimg,              "인수 예정 수량
         zerdat  TYPE erdat,              "인수예정일자
         zconf   TYPE char30,             "인수협의내용
         meins   TYPE meins,
       END OF gs_s0300.

DATA: BEGIN OF gs_s0400,
        pod_stat TYPE char10,      "POD 상태가 정상이 아닌것들
        auart    LIKE vbak-auart,                  "오더유형
        bezei    LIKE tvakt-bezei,                 "오더유형명
        vgbel    LIKE vbap-vbeln,                  " 주문번호
        vgpos    LIKE vbap-posnr,                  " 품목번호
        kwmeng   LIKE vbap-kwmeng,                " 주문수량
        vrkme_va LIKE vbap-vrkme,               " 판매단위(오더)
        vrkme    LIKE lips-vrkme,                  " 판매단위(납품)
        vbeln    LIKE lips-vbeln,                  " 납품번호
        posnr    LIKE lips-posnr,                  " 납품품목
        matnr    LIKE lips-matnr,                  " 자재
        maktx    LIKE makt-maktx,                  " 자재내역
        lfimg    LIKE lips-lfimg,                  " 납품수량
        netwr    LIKE vbap-netwr,                  " 청구액
        waerk    LIKE vbap-waerk,                  " 통화
        fksta    LIKE vbup-fksta,        " 납품관련 대금청구상태
      END OF gs_s0400,
      gt_t0400 LIKE TABLE OF gs_s0400.


DATA: BEGIN OF gs_Check,
        vbeln LIKE lips-vbeln,
        posnr LIKE lips-posnr,

        vgbel LIKE lips-vgbel,
        vgpos LIKE lips-vgpos,
        matnr LIKE lips-matnr,
        kunnr LIKE vbak-kunnr,
        lfimg LIKE lips-lfimg,
        LFIMG601   LIKE zmseg-menge,
        LFIMG687   LIKE zmseg-menge,
        etc   LIKE zmseg-menge,
        fkimg LIKE vbrp-fkimg,
        gap1  LIKE zmseg-menge,
        gap2  LIKE zmseg-menge,
        kdkg4 LIKE vbkd-kdkg4,
      END OF gs_check,
      gt_check LIKE TABLE OF gs_check.




*--- Ranges
RANGES : r_fkdat FOR vbrk-fkdat.
RANGES : lr_mtart FOR mara-mtart,
         lr_mtart2 FOR mara-mtart.
RANGES : lr_rfbsk FOR vbrk-rfbsk.
RANGES : r_vtweg FOR vbak-vtweg,
         r_spart FOR vbak-spart,
         r_vkbur FOR vbak-vkbur,
         r_vkgrp FOR vbak-vkgrp,
         r_vbeln FOR vbak-vbeln,
         r_kunnr FOR vbak-kunnr,
         r_vkorg FOR vbak-vkorg,
         r_bupla FOR bseg-bupla,
         lr_fkart FOR vbrk-fkart.

*--- Structures
DATA: BEGIN OF gs_header,
        spart     LIKE tspat-spart,
        vtext     LIKE tspat-vtext,
        uname     LIKE sy-uname,
        untxt(50),
        exdat     LIKE sy-datum,
      END   OF gs_header,

      gs_fb01 LIKE zfis_fb01.

*--- Data
DATA : ok_code      LIKE  sy-ucomm,
       s_ok_code    LIKE  sy-ucomm,
       g_err(1)     VALUE 'N',   "에러없음
       g_check(1),                   "전체선택시 사용
       g_index      LIKE  sy-tabix,
       g_ucomm      LIKE  sy-ucomm,
       g_cnt(5)     TYPE n,
       g_curyrs(7)  TYPE n,      "현재년월
       g_yrs(6)     TYPE n,      "조회년월
       g_date       LIKE sy-datum, "조회년월일
       gv_flag,
       gv_conv,
       gv_conv2,
       gv_check,
       g_fkdat      LIKE sy-datum,
       g_fkdat_high LIKE vbrk-fkdat,
       g_fkdat_low  LIKE vbrk-fkdat,
       gv_spart     LIKE vbak-spart,
       gv_answer    TYPE char01,
       gv_lock      TYPE char01.

DATA: g_init,
      x_init(1)       TYPE c VALUE 'Y',   "초기실행
      g_dynnr         LIKE sy-dynnr,
      g_activetab(10),
      gv_fkdat        LIKE vbrk-fkdat,
      g_h_fkdat       LIKE vbrk-fkdat,
      g_h_kunrg       LIKE vbrk-kunrg,
      g_imode         LIKE hrvcost-mode,
      p_update        LIKE  ctu_params-updmode VALUE 'S',
      g_flag(1).

DATA:
  BEGIN OF gt_bdcmsg OCCURS 0,
    updkz TYPE updkz_d,
    matnr TYPE mara-matnr.
    INCLUDE STRUCTURE bdcmsgcoll.
DATA:
  END OF gt_bdcmsg.

*--- constants
CONSTANTS: c_werks  LIKE marc-werks VALUE '1000',
           c_vkorg  LIKE mvke-vkorg VALUE '1000',   "LG전선
           c_clight VALUE '3',  " 생성 완료
           c_flight VALUE '1',  " 생성 미완료
           c_buga   TYPE p DECIMALS 1 VALUE '0.1'.

*- D e f i n e d   f o r   A L V   c o n t r o l ----------------------*
*// ALV Global Field
TYPE-POOLS : slis, f4typ.

*// ALV Variant
DATA: alv_variant LIKE disvariant,
      alv_repid   LIKE sy-repid.

** Layout관련
* The variables 'def_layout' and 'spec_layout' are set during
* interactions on the selection screen.
* 'gs_variant' finally holds the chosen layout.
DATA : def_layout  TYPE disvariant,     " default layout
       default     TYPE c VALUE ' ',
       spec_layout TYPE disvariant,     " specific layout
       gs_variant  TYPE disvariant.     " finally chosen layout

DATA : g_layout TYPE disvariant,
       g_exit   TYPE c.  "is set if the user has aborted a layout popup

*// ALV Attribute
DATA: gt_exclude   TYPE ui_functions,   " Tool Bar Button저장
      gs_fieldcat  TYPE lvc_s_fcat,     " 필드 속성 Set
      gt_fieldcat  TYPE lvc_t_fcat,     " 필드 속성 저장
      gt_dfieldcat TYPE lvc_t_fcat,     " 필드 속성 저장 (DETAIL)
      gs_f4        TYPE lvc_s_f4,                           " F4 필드
      gt_f4        TYPE lvc_t_f4,
      gs_layocat   TYPE lvc_s_layo,     " Grid 속성 저장(Display)
      gs_sort      TYPE lvc_s_sort,
      gt_sort      TYPE lvc_t_sort,
      g_title      TYPE lvc_title,
      ls_col       TYPE sy-tabix,
      l_scroll     TYPE lvc_s_stbl.

*// CLASS Reference 정의
CLASS lcl_event_handler       DEFINITION DEFERRED.
CLASS lcl_alv_grid            DEFINITION DEFERRED.

DATA : " g_docking_container    TYPE REF TO cl_gui_docking_container,
  custom_container TYPE REF TO cl_gui_custom_container,
  g_grid           TYPE REF TO lcl_alv_grid,
  g_event_handler  TYPE REF TO lcl_event_handler.

DATA : gt_toolbar TYPE ui_functions.
DATA : go_con    TYPE REF TO cl_gui_custom_container,
       go_grid   TYPE REF TO cl_gui_alv_grid,
       gt_fcat   TYPE lvc_t_fcat,
       gs_fcat   TYPE lvc_s_fcat,
       gt_sort2  TYPE lvc_t_sort,   " ALV Sort
       gs_layout TYPE lvc_s_layo,

       go_con2   TYPE REF TO cl_gui_custom_container,
       go_grid2  TYPE REF TO cl_gui_alv_grid.

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

*----------------------------------------------------------------------*
*  selection-screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text_001.

  PARAMETERS: p_vkorg       LIKE vbak-vkorg OBLIGATORY MEMORY ID vko DEFAULT '1000'.

  SELECT-OPTIONS: s_vtweg   FOR vbak-vtweg OBLIGATORY NO-EXTENSION NO INTERVALS MEMORY ID vtw DEFAULT '10'.
  PARAMETERS: p_spart       LIKE mara-spart OBLIGATORY MEMORY ID spa DEFAULT '60'.
  SELECT-OPTIONS: s_vkbur   FOR vbak-vkbur,
                  s_vkgrp   FOR vbak-vkgrp,
                  s_branch  FOR j_1bbranch-branch,
                  s_kdkg4   FOR vbkd-kdkg4,
                  s_kunnr   FOR vbak-kunnr.

  PARAMETERS : p_spmon      TYPE spmon OBLIGATORY DEFAULT sy-datum.
*  SELECT-OPTIONS : S_SPMON FOR S001-SPMON NO-EXTENSION.  "운송중재고출고년월

  PARAMETERS: p_compl(1).   " default 'N'.
  PARAMETERS: p_cbill(1).   " default 'N'.
  SELECTION-SCREEN SKIP 1.

  PARAMETERS: p_chk AS CHECKBOX DEFAULT ' '.
  PARAMETERS: pa_chk2 AS CHECKBOX DEFAULT ' '.

  SELECTION-SCREEN SKIP 1.

  PARAMETERS: pa_imode LIKE hrvcost-mode DEFAULT 'N'.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS : p_vari    LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK b2.

PARAMETERS : p_call TYPE c DEFAULT space NO-DISPLAY.
