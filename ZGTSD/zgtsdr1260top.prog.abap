*&---------------------------------------------------------------------*
*& Include          ZGTSDR1260TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables.
*&---------------------------------------------------------------------*
TABLES: sscrfields.

*&---------------------------------------------------------------------*
*& Values.
*&---------------------------------------------------------------------*
DATA: gv_error(1),
      gv_line     TYPE i,

      gv_okcode   TYPE sy-ucomm,
      gv_save_cd  TYPE sy-ucomm.

*&---------------------------------------------------------------------*
*& For ALV
*&---------------------------------------------------------------------*
DATA: go_event_handler TYPE REF TO lcl_event_handler,
      go_docking       TYPE REF TO cl_gui_docking_container,
      go_grid          TYPE REF TO cl_gui_alv_grid,

      gt_fcat          TYPE lvc_t_fcat,
      gt_toolbar       TYPE ui_functions,
      gt_sort          TYPE lvc_t_sort,   " ALV Sort
      gt_row           TYPE lvc_t_row WITH HEADER LINE,

      gs_layout        TYPE lvc_s_layo,
      gs_variant       TYPE disvariant,
      gs_stbl          TYPE lvc_s_stbl,
      gs_row           TYPE lvc_s_row,
      gv_pos           TYPE lvc_colpos.

*&---------------------------------------------------------------------*
*& Internal Table / Structure.
*&---------------------------------------------------------------------*
* Upload Structure.
DATA: BEGIN OF gs_excel,
        new(1),                           " 신규여부
        kunnr     LIKE kna1-kunnr,        " 고객코드
        rltyp     LIKE but100-rltyp,      " BP Role
        vkorg     LIKE knvv-vkorg,        " 영업조직
        vtweg     LIKE knvv-vtweg,        " 유통경로
        spart     LIKE knvv-spart,        " 제품군
        bzirk     LIKE knvv-bzirk,        " 영업지역
        vkbur     LIKE knvv-vkbur,        " 사업장
        vkgrp     LIKE knvv-vkgrp,        " 영업그룹
        kdgrp     LIKE knvv-kdgrp,        " 고객그룹
        waers     LIKE knvv-waers,        " 통화
        kurst     LIKE knvv-kurst,        " 환율유형
        konda     LIKE knvv-konda,        " 기납증발행여부
        kalks     LIKE knvv-kalks,        " 고객가격절차
        pltyp     LIKE knvv-pltyp,        " 가격리스트유형
        versg     LIKE knvv-versg,        " 고객 통계 그룹
        lprio     LIKE knvv-lprio,        " 납품우선순위
        kzazu     LIKE knvv-kzazu,        " 오더조합
        vsbed     LIKE knvv-vsbed,        " 출하조건
        vwerk     LIKE knvv-vwerk,        " 납품플랜트
        podkz     LIKE knvv-podkz,        " POD 관련
        podtg     LIKE knvv-podtg,        " POD 타임프레임
        autlf     LIKE knvv-autlf,        " 일괄납품
        kztlf     LIKE knvv-kztlf,        " 품목별 분할납품
        antlf     LIKE knvv-antlf,        " 최대분할납품
        uebtk     LIKE knvv-uebtk,        " 무제한 초과납품
        untto     LIKE knvv-untto,        " 미달납품 허용치
        uebto     LIKE knvv-uebto,        " 초과납품 허용치
        inco1     LIKE knvv-inco1,        " 인도조건1
        inco2     LIKE knvv-inco2,        " 인도조건2
        zterm     LIKE knvv-zterm,        " 지급조건
        ktgrd     LIKE knvv-ktgrd,        " 계정지정그룹
        taxkd     LIKE knvi-taxkd,        " 세금분류
        kvgr1     LIKE knvv-kvgr1,        " 고객그룹1
        kvgr2     LIKE knvv-kvgr2,        " 고객그룹2
        kvgr3     LIKE knvv-kvgr3,        " 고객그룹3
        kvgr4     LIKE knvv-kvgr4,        " 고객그룹4
        kvgr5     LIKE knvv-kvgr5,        " 고객그룹5
        j_1nboesl LIKE knvv-j_1nboesl,    " Exchange Key
        parvw     LIKE knvp-parvw,        " 파트너기능
        kunn2     LIKE knvp-kunn2,        " 번호
      END OF gs_excel,
      gt_excel LIKE TABLE OF gs_excel.

* ALV List.
DATA: BEGIN OF gt_list OCCURS 0,
        check(1),
        stat(4),
        newchk(4),
        name1     LIKE kna1-name1,
        partner   LIKE but100-partner.  " BP 코드
        INCLUDE STRUCTURE gs_excel.
DATA:   message   LIKE bapiret2-message,
        color     TYPE lvc_t_scol,
      END OF gt_list.

*&---------------------------------------------------------------------*
*& Define.
*&---------------------------------------------------------------------*
DEFINE: _clear.
  REFRESH: &1.    CLEAR: &1.
END-OF-DEFINITION.
