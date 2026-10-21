*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030S01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
 SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01. "검색 조건
* 전송
   PARAMETERS : p_werks  LIKE T001W-werks." OBLIGATORY.    " 플랜트
   SELECT-OPTIONS: s_matnr    FOR MARA-matnr,              "자재코드
                   s_ebeln    for EKPO-EBELN,              " 구매오더
                   s_budat    FOR matdoc-budat,            "자재문서
                   s_cpudt    FOR matdoc-cpudt MODIF ID ds1. "문서생성일

* 로그 조회(재처리)
   SELECT-OPTIONS : s_ifdat  FOR zgtppt3090-ifdat NO-EXTENSION "전송 일자
                                                  OBLIGATORY
                                                  MODIF ID ds2.
 SELECTION-SCREEN END OF BLOCK b1.

 SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02. "인터페이스전송

   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN:   COMMENT 01(31) TEXT-001. "처리모드 선택
     SELECTION-SCREEN POSITION 33.
     PARAMETERS : p_r1 RADIOBUTTON GROUP r1 USER-COMMAND u1 DEFAULT 'X'.
     SELECTION-SCREEN COMMENT 35(04) TEXT-002 FOR FIELD p_r1.  "전송

     SELECTION-SCREEN POSITION 47.
     PARAMETERS : p_r2 RADIOBUTTON GROUP r1.
     SELECTION-SCREEN COMMENT 49(17) TEXT-003 FOR FIELD p_r2.  "로그 조회(재처리)

   SELECTION-SCREEN END OF LINE.

* 로그 조회(재처리)
   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN:   COMMENT 01(31) TEXT-007 MODIF ID ds2. "송신 대상 시스템
     SELECTION-SCREEN POSITION 33.
     PARAMETERS : p_r5 RADIOBUTTON GROUP r3 USER-COMMAND u1 DEFAULT 'X'
                            MODIF ID ds2.
     SELECTION-SCREEN COMMENT 35(04) TEXT-008 FOR FIELD p_r5
       MODIF ID ds2.  "전체

     SELECTION-SCREEN POSITION 47.
     PARAMETERS : p_r6 RADIOBUTTON GROUP r3 MODIF ID ds2.
     SELECTION-SCREEN COMMENT 49(17) TEXT-009 FOR FIELD p_r6
       MODIF ID ds2. "성공건만

     SELECTION-SCREEN POSITION 70.
     PARAMETERS : p_r7 RADIOBUTTON GROUP r3 MODIF ID ds2.
     SELECTION-SCREEN COMMENT 72(8) TEXT-010 FOR FIELD p_r7
       MODIF ID ds2. "오류건만

   SELECTION-SCREEN END OF LINE.

 SELECTION-SCREEN END OF BLOCK b2.

 SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-t03. "처리 옵션

   PARAMETERS : p_r8 AS CHECKBOX MODIF ID ds1.

 SELECTION-SCREEN END OF BLOCK b3.

 SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-t04. "레이아웃 선택

   PARAMETERS p_layo LIKE disvariant-variant MODIF ID ds2.

 SELECTION-SCREEN END OF BLOCK b4.

*- 레이아웃 탐색도움말
 AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layo.
   PERFORM select_alv_variant CHANGING p_layo.
