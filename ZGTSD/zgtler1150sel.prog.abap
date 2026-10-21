*&---------------------------------------------------------------------*
*& Include          ZGTLER1150SEL
*&---------------------------------------------------------------------*
** 통문유형/발행기준
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
* Radio Button Group 1.
  SELECTION-SCREEN BEGIN OF LINE.
* 신규발행 (r01)
    PARAMETERS: rb_new  RADIOBUTTON GROUP rg1
                        USER-COMMAND ucomm DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 4(28)  TEXT-d01 FOR FIELD rb_new.
* 재발행 (r02)
    PARAMETERS: rb_re   RADIOBUTTON GROUP rg1.
    SELECTION-SCREEN COMMENT 50(15) TEXT-d02 FOR FIELD rb_re.
* 취소 (r03)
    PARAMETERS: rb_canc RADIOBUTTON GROUP rg1.
    SELECTION-SCREEN COMMENT 68(17) TEXT-d03 FOR FIELD rb_canc.

  SELECTION-SCREEN END OF LINE.

* Radio Button Group 2.
  SELECTION-SCREEN: BEGIN OF LINE.
    PARAMETERS      : rb_tk    RADIOBUTTON GROUP rg2    "선적기준
                               USER-COMMAND ucomm DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 4(28)  TEXT-d04 FOR FIELD rb_tk.
    PARAMETERS      : rb_vl    RADIOBUTTON GROUP rg2.    "납품기준
    SELECTION-SCREEN COMMENT 50(15) TEXT-d05 FOR FIELD rb_vl.
  SELECTION-SCREEN: END OF LINE.

* Radio Button Group 3.
  SELECTION-SCREEN: BEGIN OF LINE.
    PARAMETERS      : rb_so    RADIOBUTTON GROUP rg3    "sales order
                               USER-COMMAND ucomm DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 4(28)  TEXT-d06 FOR FIELD rb_so.
    PARAMETERS      : rb_sto   RADIOBUTTON GROUP rg3 .   "STO
    SELECTION-SCREEN COMMENT 50(15) TEXT-d07 FOR FIELD rb_sto.
    PARAMETERS      : rb_all   RADIOBUTTON GROUP rg3 .   "all
    SELECTION-SCREEN COMMENT 68(17) TEXT-d08 FOR FIELD rb_all.

  SELECTION-SCREEN: END OF LINE.

**/ 통문대상포함
*  PARAMETERS: p_out AS CHECKBOX .
**/ 좁은양식
*  PARAMETERS: p_new AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN: END OF BLOCK b1.

*** 발행조건
*SELECTION-SCREEN: BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-004.
*  PARAMETERS : p_vl    AS CHECKBOX.  " 발행시 납품문서기준으로 출력됨
*  SELECTION-SCREEN SKIP 1.
*
*  PARAMETERS : rb_g01 RADIOBUTTON GROUP rd4,              " 제품별 합계 발행
*               rb_g02 RADIOBUTTON GROUP rd4 DEFAULT 'X',  " Batch 특성별합계(조장)
*               rb_g03 RADIOBUTTON GROUP rd4,              " Batch 특성별합계(포장재)
*               rb_g04 RADIOBUTTON GROUP rd4.              " Batch 별 발행
*  SELECTION-SCREEN SKIP 1.
*
*  PARAMETERS : p_batch AS CHECKBOX,  " Batch No.
*               p_acsr  AS CHECKBOX.  " 미부착부품 포함
*SELECTION-SCREEN: END OF BLOCK b4.

** 선택조건
SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS      : p_bzarea   LIKE  zlet0033-bzarea OBLIGATORY
                      MEMORY ID zbarea .                " 사업장
  SELECT-OPTIONS  : s_vstel    FOR   likp-vstel
                      MEMORY ID vst OBLIGATORY ,        " 출하지점
                    s_lgort    FOR   lips-lgort,        " 저장위치
                    s_wadat    FOR   likp-wadat         " 출고요청일
                                     NO-EXTENSION,
                    s_wdtist   FOR   likp-wadat_ist     " 출고일
                                     NO-EXTENSION,
                    s_vsart    FOR   likp-vsart,        " 출하유형
                    s_route    FOR   likp-route,        " 운송경로
                    s_kunag    FOR   likp-kunag,        " 판매처
*                    s_kunnr    FOR   likp-kunnr,        " 납품처
                    s_va       FOR   vbak-vbeln,        " 주문번호
                    s_vl       FOR   likp-vbeln,        " 아웃바운드 납품
                    s_tknum    FOR   vttk-tknum,        " 선적번호
                    s_ernam    FOR   likp-ernam,        " 납품문서생성인
                    s_iv_no    FOR   zlet0005-iv_no,    " 거래명세서 번호
                    s_date     FOR   zlet0005-iv_date.  " 거래명세서 발행일자
SELECTION-SCREEN: END OF BLOCK b2.

** 영업데이타
SELECTION-SCREEN: BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003.
  SELECT-OPTIONS  : s_vkbur    FOR   vbak-vkbur.            "영업팀
  SELECT-OPTIONS  : s_vkgrp    FOR   vbak-vkgrp.            "영업그룹
  SELECT-OPTIONS  : s_vtweg    FOR   vbak-vtweg.            "유통경로
SELECTION-SCREEN: END OF BLOCK b3.
