*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR4332TOP
*&---------------------------------------------------------------------*
TABLES: zgtmmt9410, zgtmmt9425, ekko, ekpo, ekkn, t001w.

*----------------------------------------------------------------------*
* CONSTANTS / TYPES
*----------------------------------------------------------------------*
CONSTANTS:
  gc_x        TYPE c LENGTH 1 VALUE 'X',
  gc_zifno_dr TYPE zgtmmt9000-zifno VALUE 'MM00035', "MES 드럼라벨 입고 I/F
  gc_chk_user TYPE sy-uname VALUE 'ZLSGMM5'.         "점검대상 조회 허용 계정

" 조회 모드 ① 유형·기간 요약은 선택화면에서 숨김 (코드 보존, 항상 초기값)
DATA p_m1 TYPE c LENGTH 1.
DATA: gv_charg TYPE charg_d,
      gv_label TYPE zgtmmt9425-dr_label_no.

TYPES:
  ty_qty  TYPE p LENGTH 13 DECIMALS 3,
  ty_rate TYPE p LENGTH 7 DECIMALS 1,
  ty_drum TYPE p LENGTH 9 DECIMALS 3.

TYPES: BEGIN OF ty_col,
         name TYPE lvc_fname,
         text TYPE c LENGTH 40,
         hide TYPE c LENGTH 1,
         link TYPE c LENGTH 1, "핫스팟(클릭 이동)
       END OF ty_col,
       tt_col TYPE STANDARD TABLE OF ty_col WITH DEFAULT KEY.

" 납품서 품목 단위
TYPES: BEGIN OF ty_item,
         " ALV 표시 순서 = 필드 순서 (컬럼 숨김/텍스트는 FORM DISPLAY_ITEM)
         " 납품 명세서(INV)·보관품(IVS) 요청 화면 순서에 맞춰 배치
         icon       TYPE icon_d,
         budat      TYPE zgtmmt9410-budat,   "G-PRO 발행일
         last_gr    TYPE d,                  "전기일(최종 입고일)
         proc_txt   TYPE c LENGTH 10,        "처리유형(공장입고/직납매입/매입보관품/매출보관품)
         werks      TYPE zgtmmt9410-werks,
         lgort      TYPE zgtmmt9410-lgort,
         lifnr      TYPE ekko-lifnr,
         name1      TYPE lfa1-name1,
         delno      TYPE zgtmmt9410-delno,
         delitem    TYPE zgtmmt9410-delitem,
         matnr      TYPE ekpo-matnr,
         maktx      TYPE makt-maktx,
         ebeln      TYPE zgtmmt9410-ebeln,
         ebelp      TYPE zgtmmt9410-ebelp,
         vbeln_po   TYPE ekkn-vbeln,
         posnr_po   TYPE ekkn-vbelp,
         vbeln_gr   TYPE matdoc-mat_kdauf,
         posnr_gr   TYPE matdoc-mat_kdpos,
         jojang     TYPE ty_qty,   "조장(판매오더 특성, 없으면 구매오더 특성)
         meins      TYPE zgtmmt9410-meins,
         podrum     TYPE ty_drum,  "PO 드럼수(특성 FACTOR)
         poqty      TYPE ty_qty,
         deldrum    TYPE ty_drum,  "납품(입고대상) 드럼수
         delqty     TYPE ty_qty,
         grdrum     TYPE ty_drum,  "입고(101) 드럼수
         grqty_std  TYPE ty_qty,
         stkdrum    TYPE ty_drum,  "이전전기(311) 드럼수
         grqty_stk  TYPE ty_qty,
         opendrum   TYPE ty_drum,  "미처리 드럼수
         openqty    TYPE ty_qty,
         grrate     TYPE ty_rate,
         " PO 대비 누적 입고(해당 PO 품목의 전체 납품서, 취소 제외)
         potot_drum TYPE ty_drum,
         potot_qty  TYPE ty_qty,
         poopn_drum TYPE ty_drum,
         poopn_qty  TYPE ty_qty,
         " 기본 숨김 / 내부용
         chk_txt    TYPE c LENGTH 40,
         typ_txt    TYPE c LENGTH 6,
         so_src     TYPE c LENGTH 4,
         grqty      TYPE ty_qty,
         grstat_txt TYPE c LENGTH 10,
         delclose   TYPE zgtmmt9410-delclose,
         cancelled  TYPE c LENGTH 1,
         route      TYPE c LENGTH 8,
         doccnt     TYPE i,
         lblcnt     TYPE i,
         lblerr     TYPE i,
         lblunf     TYPE i,
         first_gr   TYPE d,
         colcell    TYPE lvc_t_scol, "상태 셀 색상
         deltype    TYPE zgtmmt9410-deltype,
         typ_seq    TYPE c LENGTH 1, "유형 정렬 순서 (1 표준 / 2 매입보관 / 3 매출보관)
         grstat     TYPE c LENGTH 1,
         itemseq    TYPE i,
         chk_dup    TYPE c LENGTH 1,
         chk_over   TYPE c LENGTH 1,
         chk_canc   TYPE c LENGTH 1,
         chk_err    TYPE c LENGTH 1,
         " 조회 원천값 (화면 숨김)
         doccnt_std TYPE i,
         doccnt_stk TYPE i,
         first_std  TYPE d,
         last_std   TYPE d,
         first_stk  TYPE d,
         last_stk   TYPE d,
         so_std     TYPE matdoc-mat_kdauf,
         soitm_std  TYPE matdoc-mat_kdpos,
         so_stk     TYPE matdoc-mat_kdauf,
         soitm_stk  TYPE matdoc-mat_kdpos,
       END OF ty_item.

" 납품서(명세서) 단위
TYPES: BEGIN OF ty_doc,
         icon       TYPE icon_d,
         typ_txt    TYPE c LENGTH 6,
         delno      TYPE zgtmmt9410-delno,
         werks      TYPE zgtmmt9410-werks,
         budat      TYPE zgtmmt9410-budat,
         lifnr      TYPE ekko-lifnr,
         name1      TYPE lfa1-name1,
         itemcnt    TYPE i,
         meins      TYPE zgtmmt9410-meins,
         delqty     TYPE ty_qty,
         grqty      TYPE ty_qty,
         openqty    TYPE ty_qty,
         grrate     TYPE ty_rate,
         grstat     TYPE c LENGTH 1,
         grstat_txt TYPE c LENGTH 10,
         delclose   TYPE zgtmmt9410-delclose,
         cancelled  TYPE c LENGTH 1,
         route      TYPE c LENGTH 8,
         doccnt     TYPE i,
         lblcnt     TYPE i,
         lblerr     TYPE i,
         first_gr   TYPE d,
         last_gr    TYPE d,
         chk_dup    TYPE c LENGTH 1,
         chk_over   TYPE c LENGTH 1,
         chk_canc   TYPE c LENGTH 1,
         chk_err    TYPE c LENGTH 1,
         chk_txt    TYPE c LENGTH 40,
         typ_seq    TYPE c LENGTH 1,
       END OF ty_doc.

" 유형·기간 요약
TYPES: BEGIN OF ty_sum,
         typ_txt  TYPE c LENGTH 6,
         werks    TYPE zgtmmt9410-werks,
         period   TYPE c LENGTH 21,
         delcnt   TYPE i,
         itemcnt  TYPE i,
         delqty   TYPE ty_qty,
         grqty    TYPE ty_qty,
         openqty  TYPE ty_qty,
         grrate   TYPE ty_rate,
         cnt_full TYPE i,
         cnt_part TYPE i,
         cnt_open TYPE i,
         cnt_err  TYPE i,
         cnt_over TYPE i,
         cnt_canc TYPE i,
         typ_seq  TYPE c LENGTH 1,
       END OF ty_sum.

" 입고 전표/라벨 상세 (팝업)
TYPES ty_ztxt TYPE c LENGTH 8.
TYPES: BEGIN OF ty_dtl,
         " 표시 순서 = 필드 순서 (기본 표시 컬럼 → 숨김 컬럼)
         src       TYPE c LENGTH 4,
         dr_label  TYPE zgtmmt9425-dr_label_no,
         delqty    TYPE ty_qty,
         qty       TYPE ty_qty,
         poqty     TYPE ty_qty,
         mblnr     TYPE matdoc-mblnr,
         state_txt TYPE c LENGTH 8,
         zstat_txt TYPE c LENGTH 8,
         ebeln     TYPE ekpo-ebeln,
         ebelp     TYPE ekpo-ebelp,
         mjahr     TYPE matdoc-mjahr,
         zeile     TYPE matdoc-zeile,
         budat     TYPE d,
         unit      TYPE matdoc-erfme,
         so        TYPE matdoc-mat_kdauf,
         soitm     TYPE matdoc-mat_kdpos,
         charg     TYPE matdoc-charg,
       END OF ty_dtl.

" 드럼별 상세 (조회 모드 ③) : 납품서 품목 정보 + 입고/이전전기 전표·라벨 1건 = 1행
TYPES: BEGIN OF ty_det,
         icon       TYPE icon_d,
         budat      TYPE zgtmmt9410-budat,
         gr_budat   TYPE d,
         proc_txt   TYPE c LENGTH 10,
         src        TYPE c LENGTH 4,
         werks      TYPE zgtmmt9410-werks,
         lgort      TYPE zgtmmt9410-lgort,
         lifnr      TYPE ekko-lifnr,
         name1      TYPE lfa1-name1,
         delno      TYPE zgtmmt9410-delno,
         delitem    TYPE zgtmmt9410-delitem,
         matnr      TYPE ekpo-matnr,
         maktx      TYPE makt-maktx,
         ebeln      TYPE zgtmmt9410-ebeln,
         ebelp      TYPE zgtmmt9410-ebelp,
         vbeln_po   TYPE ekkn-vbeln,
         posnr_po   TYPE ekkn-vbelp,
         vbeln_gr   TYPE matdoc-mat_kdauf,
         posnr_gr   TYPE matdoc-mat_kdpos,
         charg      TYPE matdoc-charg,
         dr_label   TYPE zgtmmt9425-dr_label_no,
         meins      TYPE zgtmmt9410-meins,
         drum       TYPE ty_drum,
         qty        TYPE ty_qty,
         mblnr      TYPE matdoc-mblnr,
         mjahr      TYPE matdoc-mjahr,
         state_txt  TYPE c LENGTH 8,
         zstat_txt  TYPE c LENGTH 8,
         colcell    TYPE lvc_t_scol,
       END OF ty_det.

DATA: gt_item TYPE STANDARD TABLE OF ty_item,
      gt_doc  TYPE STANDARD TABLE OF ty_doc,
      gt_sum  TYPE STANDARD TABLE OF ty_sum,
      gt_view TYPE STANDARD TABLE OF ty_item, "현재 표시 중인 ALV 의 품목 (더블클릭 참조용)
      gt_det  TYPE STANDARD TABLE OF ty_det.

*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*
* 블록 제목/라디오·체크박스 라벨은 텍스트 엘리먼트 없이 표시되도록 변수 사용
* (INITIALIZATION 의 FORM INITIALIZATION 에서 값 세팅)
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE tb0.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_m2 RADIOBUTTON GROUP g1 DEFAULT 'X'.       "납품 문서별 입고/이전전기 대사
    SELECTION-SCREEN COMMENT 3(32) cmm2 FOR FIELD p_m2.
    SELECTION-SCREEN POSITION 38.
    PARAMETERS p_m3 RADIOBUTTON GROUP g1.                   "납품 문서별 상세 조회(배치/꼬리표)
    SELECTION-SCREEN COMMENT 40(36) cmm3 FOR FIELD p_m3.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b0.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE tb1.
  PARAMETERS: p_bukrs TYPE t001-bukrs OBLIGATORY MEMORY ID buk DEFAULT '6000'.
  SELECT-OPTIONS: s_werks FOR t001w-werks OBLIGATORY,
                  s_budat FOR zgtmmt9410-budat OBLIGATORY,
                  s_delno FOR zgtmmt9410-delno,
                  s_ebeln FOR ekko-ebeln,
                  s_lifnr FOR ekko-lifnr,
                  s_matnr FOR ekpo-matnr,
                  s_vbeln FOR ekkn-vbeln.
  " 배치번호 / 드럼라벨번호: 텍스트 엘리먼트 없이 라벨이 보이도록 COMMENT 사용
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(28) cs_chg FOR FIELD s_charg.
    SELECT-OPTIONS s_charg FOR gv_charg.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(28) cs_lbl FOR FIELD s_label.
    SELECT-OPTIONS s_label FOR gv_label.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE tb2.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_inv AS CHECKBOX DEFAULT 'X' USER-COMMAND uin.             "INV 일반납품
    SELECTION-SCREEN COMMENT 3(12) cmt1 FOR FIELD p_inv.
    SELECTION-SCREEN POSITION 17.
    PARAMETERS p_ivsa AS CHECKBOX USER-COMMAND uia.            "IVS-A
    SELECTION-SCREEN COMMENT 19(18) cmt2 FOR FIELD p_ivsa.
    SELECTION-SCREEN POSITION 39.
    PARAMETERS p_ivsb AS CHECKBOX USER-COMMAND uib.            "IVS-B
    SELECTION-SCREEN COMMENT 41(18) cmt3 FOR FIELD p_ivsb.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_xcan AS CHECKBOX DEFAULT 'X'.              "삭제(취소) 납품서 제외
    SELECTION-SCREEN COMMENT 3(24) cxc1 FOR FIELD p_xcan.
    SELECTION-SCREEN POSITION 29.
    PARAMETERS p_xcls AS CHECKBOX DEFAULT 'X'.              "종결 납품서 제외
    SELECTION-SCREEN COMMENT 31(24) cxc2 FOR FIELD p_xcls.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE tb3.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_sall RADIOBUTTON GROUP g2 DEFAULT 'X'.     "전체
    SELECTION-SCREEN COMMENT 3(6) cms1 FOR FIELD p_sall.
    SELECTION-SCREEN POSITION 11.
    PARAMETERS p_sopn RADIOBUTTON GROUP g2.                 "미입고/미확정/오류
    SELECTION-SCREEN COMMENT 13(22) cms2 FOR FIELD p_sopn.
    SELECTION-SCREEN POSITION 37.
    PARAMETERS p_spar RADIOBUTTON GROUP g2.                 "부분입고
    SELECTION-SCREEN COMMENT 39(10) cms3 FOR FIELD p_spar.
    SELECTION-SCREEN POSITION 51.
    PARAMETERS p_sful RADIOBUTTON GROUP g2.                 "입고완료
    SELECTION-SCREEN COMMENT 53(10) cms4 FOR FIELD p_sful.
    SELECTION-SCREEN POSITION 65.
    PARAMETERS p_sovr RADIOBUTTON GROUP g2.                 "초과입고
    SELECTION-SCREEN COMMENT 67(10) cms5 FOR FIELD p_sovr.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_chk AS CHECKBOX.                           "점검대상
    SELECTION-SCREEN COMMENT 3(40) cms6 FOR FIELD p_chk.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b3.
