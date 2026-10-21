*&---------------------------------------------------------------------*
*&  Include           ZLER0016TOP
*&---------------------------------------------------------------------*
TABLES: mseg,            "문서세그멘트: 자재
        mkpf,            "헤더: 자재문서
        vbap,
        marc,            "자재에 대한 플랜트데이타
        kna1,            "고객마스터의 일반데이타
        lfa1,            "구매처마스터 (일반섹션)
        t001w,           "플랜트/분기
        zlet0005,        "[LE] 통문 헤더
        zlet0006,        "[LE] 통문 Line Item
        ZGTMMT4500, "통문 헤더
        ZGTMMT4501, "통문 Line Item
        zlet0007,
        zlet0034,
        zmmt0016,        "매각/폐기 처리 HEADER
        zmmt0017,        "매각/폐기 처리 DETAIL
        zmmt0019,        "매각/폐기 유형코드 관리
        zppt0018,        "SC Item
        zppt0019.        "사내거래(STO)

TYPE-POOLS: slis, kkblo.

DATA: BEGIN OF gt_out OCCURS 0,
        iv_no    LIKE  zlet0005-iv_no,   "통문번호
        iv_type  LIKE  zlet0005-iv_type, "통문유형
        iv_tdes(20),                     "통문유형설명
        bwart    LIKE  zlet0005-bwart,   "이동유형
*        IV_NO    LIKE  ZLET0005-IV_NO,   "통문번호
*        WERKS    LIKE  zlet0005-werks,   "플랜트
        werks_t  LIKE  zlet0034-name1,   "플랜트명
        mblnr    LIKE  zlet0006-mblnr,   "자재문서
        zeile    LIKE  zlet0006-zeile,   "자재항번
        matnr    LIKE  zlet0006-matnr,   "자재번호
        maktx    LIKE  makt-maktx,       "품명규격
        charg    LIKE  lips-charg,
        mtr_unit LIKE  zlet0006-mtr_unit,"단위
        lfimg    LIKE  zlet0006-lfimg,   "수량
        truck_no LIKE  zlet0005-truck_no,"차량번호
        driver_nm    LIKE zlet0005-driver_nm,    "운전자명
        driver_telno LIKE zlet0005-driver_telno, "운전자 전화번호
        etc_nm   LIKE  zlet0005-etc_nm,
        ton_no   LIKE  zlet0005-ton_no,
        waers    LIKE  zmmt0017-waers,
        netpr    LIKE  zmmt0017-netpr,
        dmbtr    LIKE  zmmt0017-dmbtr,
        werks    LIKE  zlet0005-werks,   "PLANT
        mjahr    LIKE  mseg-mjahr,       "년도
        out_yn   LIKE  zlet0005-out_yn,  "통문유무
        lifnr    LIKE  mseg-lifnr,       "업체
        kunnr    LIKE  mseg-kunnr,
        umwrk    LIKE  mseg-umwrk,
        ebeln    LIKE  zppt0018-ebeln,   "구매전표
        ebelp    LIKE  zppt0018-ebelp,
        tagnr    LIKE  zppt0018-tagnr,   "꼬리표
        bukrs    LIKE  zmmt0016-bukrs,   "회사코드
        create_date LIKE ZLET0005-create_date, "통문요청일자
        create_time LIKE ZLET0005-create_time, "통문요청시간
        iv_date     LIKE ZLET0005-iv_date,     "통문발행일자
        qdatu       LIKE LTAP-qdatu,           "이전오더 생성일자
        qzeit       LIKE LTAP-qzeit,           "이전오더 확정일자
*{CHM2008-00227 - S
        PERNR       LIKE ZLET0005-PERNR,       "사번
        ENAME       LIKE ZLET0005-ENAME,       "이름
* }CHM2008-00227 - E
        CANCELLED   LIKE MATDOC-CANCELLED,     "자재문서 취소여부
        fg(1),
        chk(1),
      END OF gt_out.

*{ SRM2401-14519 - 추가_S
DATA: BEGIN OF GT_MDOC OCCURS 0,
        MBLNR   LIKE MATDOC-MBLNR,
        MJAHR   LIKE MATDOC-MJAHR,
        ZEILE   LIKE MATDOC-ZEILE,
        MATNR   LIKE MATDOC-MATNR,
        CHARG   LIKE MATDOC-CHARG,
        MENGE   LIKE MATDOC-MENGE,
        USED,
      END   OF GT_MDOC.
*} SRM2401-14519 - 추가_E

DATA: gt_tab LIKE gt_out OCCURS 0 WITH HEADER LINE.

*
DATA: gt_out_t LIKE gt_out OCCURS 0 WITH HEADER LINE.
DATA: gt_out_s LIKE gt_out OCCURS 0 WITH HEADER LINE.
*
DATA: BEGIN OF lt_tab OCCURS 0,
        ivno   LIKE  zlet0005-iv_no,
      END OF lt_tab.

DATA: lv_msg_tab LIKE zles009 OCCURS 0 WITH HEADER LINE.
*
DATA: BEGIN OF err_tab OCCURS 0,
        iv_no   LIKE  zlet0005-iv_no,
        fg(1),
      END OF err_tab.
*
DATA: BEGIN OF scc_tab OCCURS 0,
        iv_no   LIKE  zlet0005-iv_no,
      END OF scc_tab.
TYPE-POOLS vrm.
DATA: lt_values  TYPE vrm_values WITH HEADER LINE.

RANGES: r_werks FOR mseg-werks.

DATA: lt_delta_cells   TYPE lvc_t_modi,
      ls_delta_cells   TYPE lvc_s_modi,
      ls_modified      TYPE char01,
      ls_frontend_only TYPE char01,
      lt_msg           TYPE lvc_t_msg1,
      gv_index         LIKE sy-index,
      gv_index_p       LIKE sy-index,
      gv_iv_no         LIKE zlet0005-iv_no,
      lv_return,
      lv_flag,
      lv_ck(1).
* Smart Forms i/f internal table
DATA: lv_sm01 LIKE zles014 OCCURS 0 WITH HEADER LINE.
DATA: lv_sm02 LIKE zles015 OCCURS 0 WITH HEADER LINE.
DATA: lv_sm03 LIKE zles016 OCCURS 0 WITH HEADER LINE.
DATA: lv_sm04 LIKE zles015 OCCURS 0 WITH HEADER LINE.
DATA: mok     TYPE i,
      nam     TYPE i.
*
DATA: control_parameters TYPE ssfctrlop,
      output_options     TYPE ssfcompop.
DATA: func_name          LIKE rs38l-name.
DATA: printer            LIKE tsp03d-padest.
DATA: otf LIKE itcoo OCCURS 0 WITH HEADER LINE.
*
DATA: lv_ivno  LIKE zlet0005-iv_no,
      lv_ivtyp LIKE zlet0005-iv_type,
      lv_werks LIKE marc-werks,
      lv_umwrk LIKE mseg-umwrk,
      lv_lifnr LIKE mseg-lifnr,
      lv_kunnr LIKE mseg-kunnr,
      lv_truck LIKE zlet0005-truck_no,
      lv_drnam LIKE zlet0005-driver_nm,
      lv_drnum LIKE zlet0005-driver_telno,
      lv_etc_nm LIKE zlet0005-etc_nm,
      lv_tonno LIKE zlet0005-ton_no,
*{CHM2008-00227 - S
      LV_PERNR    LIKE ZLET0005-PERNR,         "사번
      LV_ENAME    LIKE ZLET0005-ENAME,         "이름
* }CHM2008-00227 - E
      lv_mblnr LIKE zlet0006-mblnr, "자재문서번호 추가
      lv_mjahr LIKE zlet0006-MJAHR. "자재문서연도 추가
DATA: gv_flag1, gv_flag2, gv_flag3.

* 법인분리로 인한 회사정보 추가
DATA: GV_BUKRS  LIKE MATDOC-BUKRS.
* POV
DATA : BEGIN OF FIELDTAB OCCURS 2.
        INCLUDE STRUCTURE HELP_VALUE.
DATA : END OF FIELDTAB.

DATA : BEGIN OF I_HELP_VTAB OCCURS 0.
        INCLUDE STRUCTURE  HELP_VTAB.
DATA : END OF I_HELP_VTAB.
DATA : BEGIN OF  VALUETAB OCCURS 0,
         VALUE LIKE HELP_VTAB-VALUE,
        END OF  VALUETAB.
DATA: J TYPE I.

* screen layout
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE t1.
SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS      : r1     RADIOBUTTON GROUP rd1
                  USER-COMMAND ucomm DEFAULT 'X'.       "MM일반
SELECTION-SCREEN COMMENT 4(15)  text-001 FOR FIELD r1.
PARAMETERS      : r2     RADIOBUTTON GROUP rd1.         "매각/폐기
SELECTION-SCREEN COMMENT 29(15) text-002 FOR FIELD r2.
*PARAMETERS      : r3     RADIOBUTTON GROUP rd1.          "PP
*SELECTION-SCREEN COMMENT 50(15) text-003 FOR FIELD r3.
*PARAMETERS      : r4     RADIOBUTTON GROUP rd1.          "SM
*SELECTION-SCREEN COMMENT 70(15) text-004 FOR FIELD r4.
SELECTION-SCREEN: END OF LINE.
*SELECTION-SCREEN: ULINE.
SELECTION-SCREEN: END OF BLOCK b1.

SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE t2.
PARAMETERS      : p_bzarea   LIKE  zlet0034-bzarea NO-DISPLAY.. "OBLIGATORY
*                     MEMORY ID zbarea.

PARAMETERS      : p_bukrs    LIKE  MATDOC-bukrs.
*-{자체개선 52264  - 추가
*                           AS LISTBOX VISIBLE LENGTH 14 USER-COMMAND U01.
PARAMETERS      : P_WERKS   LIKE MATDOC-WERKS OBLIGATORY.
*-} 자체개선 52264_2014_11_06
PARAMETERS      : p_gubun1 TYPE zlet0005-iv_type AS LISTBOX
                  VISIBLE LENGTH 24      "통문유형
                   MODIF ID m1.
SELECT-OPTIONS  : i_date   FOR  zlet0005-iv_date   "통문증 발행일
                                OBLIGATORY.
*SELECT-OPTIONS  : i_werks  FOR  marc-werks
*                                MODIF ID m2.
*SELECT-OPTIONS  : i_branch FOR  zmmt0016-branch    "사업장(매각/폐기)
*                                MODIF ID m2.
SELECT-OPTIONS  : i_ivno   FOR  zlet0005-iv_no.    "통문번호
SELECT-OPTIONS  : i_lifnr  FOR  mseg-lifnr.        "거래처
PARAMETERS      : i_truno  LIKE zlet0005-truck_no. "차량번호
SELECT-OPTIONS  : i_ivtyp  FOR  zlet0005-iv_type NO-DISPLAY.
SELECT-OPTIONS  : i_matnr  FOR  zlet0006-matnr.

* [START] CSR NO : C20070810_14860
PARAMETERS      : i_dispo TYPE marc-dispo.
* [END]   CSR NO : C20070810_14860

SELECTION-SCREEN: END OF BLOCK b2.

SELECTION-SCREEN: BEGIN OF BLOCK b3 WITH FRAME TITLE t3.
PARAMETERS      : i_prtcnt(3) TYPE n DEFAULT '4'.
PARAMETERS: P_PRTCHK AS CHECKBOX .
*PARAMETERS      : r05 RADIOBUTTON GROUP rd4.
SELECTION-SCREEN: END OF BLOCK b3.
