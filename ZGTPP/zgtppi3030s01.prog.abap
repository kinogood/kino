*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030S01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
 SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01. "검색 조건
* 전송
   PARAMETERS : p_werks  LIKE matdoc-werks." OBLIGATORY.     " 플랜트
   SELECT-OPTIONS: s_matnr    FOR matdoc-matnr,            "자재코드
                   s_mblnr    FOR matdoc-mblnr,            "자재문서
                   s_lgort    FOR matdoc-lgort,            "저장위치
                   s_bwart    FOR matdoc-bwart,            "이동유형
                   s_cpudt    FOR matdoc-cpudt,            "문서생성일
                   s_cputm    FOR matdoc-cputm.            "문서생서시간

* 로그 조회(재처리)
   SELECT-OPTIONS : s_ifdat  FOR zgtppt3060-ifdat NO-EXTENSION "전송 일자
                                                  OBLIGATORY
                                                  MODIF ID ds2,
                    s_iftim  FOR zgtppt3060-iftim NO-EXTENSION  "전송 시간
                                                  MODIF ID ds2.

 SELECTION-SCREEN END OF BLOCK b1.

 SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02. "인터페이스 전송

   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN:   COMMENT 01(31) TEXT-001. "처리모드 선택
     SELECTION-SCREEN POSITION 33.
     PARAMETERS : p_r1 RADIOBUTTON GROUP r1 USER-COMMAND u1 DEFAULT 'X'.
     SELECTION-SCREEN COMMENT 35(04) TEXT-002 FOR FIELD p_r1.  "전송

     SELECTION-SCREEN POSITION 47.
     PARAMETERS : p_r2 RADIOBUTTON GROUP r1.
     SELECTION-SCREEN COMMENT 49(17) TEXT-003 FOR FIELD p_r2.  "로그 조회(재처리)

   SELECTION-SCREEN END OF LINE.
* 전송
*   SELECTION-SCREEN BEGIN OF LINE.
*     SELECTION-SCREEN:   COMMENT 01(31) TEXT-004 MODIF ID ds1. "송신 대상 시스템
*     SELECTION-SCREEN POSITION 33.
*     PARAMETERS : p_r3 RADIOBUTTON GROUP r2 USER-COMMAND u1 DEFAULT 'X'
*                                 MODIF ID ds1.
*     SELECTION-SCREEN COMMENT 35(08) TEXT-005 FOR FIELD p_r3
*       MODIF ID ds1.  "지중 MES
*
*     SELECTION-SCREEN POSITION 47.
*     PARAMETERS : p_r4 RADIOBUTTON GROUP r2 MODIF ID ds1.
*     SELECTION-SCREEN COMMENT 49(12) TEXT-006 FOR FIELD p_r4
*       MODIF ID ds1.  "부스닥트 MES
*
*   SELECTION-SCREEN END OF LINE.
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
