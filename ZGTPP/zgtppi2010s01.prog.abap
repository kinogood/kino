*&---------------------------------------------------------------------*
*& Include          ZGTPPI2010S01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* SELECTION-SCREEN.
*----------------------------------------------------------------------*
 SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01. "검색 조건
* 전송
   PARAMETERS: p_werks LIKE aufk-werks MODIF ID ds2.     "플랜트
   SELECT-OPTIONS: "s_werks FOR aufk-werks MODIF ID ds2, "플랜트
                   s_auart FOR aufk-auart,               "생산오더 유형
                   s_aufnr FOR aufk-aufnr,               "생산오더 번호
                   s_matnr FOR afpo-matnr,               "품목코드
                   s_gstrp FOR afko-gstrp,               "생산시작일자
                   s_erdat FOR aufk-erdat MODIF ID ds1,  "오더생성일자
                   s_udate FOR jcds-udate MODIF ID ds1 NO-EXTENSION, "상태변경일자
                   s_utime FOR jcds-utime MODIF ID ds1 NO-EXTENSION. "상태변경시간
* 로그 조회
   SELECT-OPTIONS: s_ifdat FOR zgtppt3010-ifdat MODIF ID ds2 NO-EXTENSION. "전송 일자
 SELECTION-SCREEN END OF BLOCK b1.


 SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02. "인터페이스 전송
   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN COMMENT (18) TEXT-001. "처리모드 선택

     PARAMETERS: p_r1 RADIOBUTTON GROUP r1 USER-COMMAND u1 DEFAULT 'X'.
     SELECTION-SCREEN COMMENT (15) TEXT-002 FOR FIELD p_r1.  "전송

     PARAMETERS: p_r2 RADIOBUTTON GROUP r1.
     SELECTION-SCREEN COMMENT (15) TEXT-003 FOR FIELD p_r2.  "로그 조회
   SELECTION-SCREEN END OF LINE.

* 전송
   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN COMMENT (18) TEXT-004 MODIF ID ds1. "송신 대상 시스템

     PARAMETERS: p_r3  RADIOBUTTON GROUP r2 USER-COMMAND u1 DEFAULT 'X' MODIF ID ds1.
     SELECTION-SCREEN  COMMENT (15) TEXT-005 FOR FIELD p_r3 MODIF ID ds1.  "지중 MES

     PARAMETERS: p_r4  RADIOBUTTON GROUP r2 MODIF ID ds1.
     SELECTION-SCREEN  COMMENT (15) TEXT-006 FOR FIELD p_r4 MODIF ID ds1.  "부스닥트 MES

     PARAMETERS: p_r9  RADIOBUTTON GROUP r2 MODIF ID ds1.
     SELECTION-SCREEN  COMMENT (15) TEXT-085 FOR FIELD p_r9 MODIF ID ds1.  "소재 MOM SRM2510-04825

     PARAMETERS: p_r10 RADIOBUTTON GROUP r2 MODIF ID ds1.
     SELECTION-SCREEN  COMMENT (15) TEXT-086 FOR FIELD p_r10 MODIF ID ds1.  "가온 전력 MES.

     PARAMETERS: p_r11 RADIOBUTTON GROUP r2 MODIF ID ds1.
     SELECTION-SCREEN  COMMENT (15) TEXT-087 FOR FIELD p_r11 MODIF ID ds1.  "가온 통신 MES.

   SELECTION-SCREEN END OF LINE.

   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN POSITION 20.
     PARAMETERS: p_r12 RADIOBUTTON GROUP r2 MODIF ID ds1.
     SELECTION-SCREEN  COMMENT (15) TEXT-088 FOR FIELD p_r12 MODIF ID ds1.  "한미소 MOM 260828.
   SELECTION-SCREEN END OF LINE.

* 로그 조회
   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN COMMENT (18) TEXT-007 MODIF ID ds2. "조회모드 선택

     PARAMETERS: p_r5 RADIOBUTTON GROUP r3 USER-COMMAND u1   MODIF ID ds2.
     SELECTION-SCREEN COMMENT (15) TEXT-008 FOR FIELD p_r5 MODIF ID ds2.  "성공 건만

     PARAMETERS: p_r6 RADIOBUTTON GROUP r3 MODIF ID ds2.
     SELECTION-SCREEN COMMENT (15) TEXT-009 FOR FIELD p_r6 MODIF ID ds2. "오류 건만

     PARAMETERS: p_r7 RADIOBUTTON GROUP r3 MODIF ID ds2 DEFAULT 'X'.
     SELECTION-SCREEN COMMENT (15) TEXT-010 FOR FIELD p_r7 MODIF ID ds2. "전체
   SELECTION-SCREEN END OF LINE.
 SELECTION-SCREEN END OF BLOCK b2.

 SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-t03. "처리 옵션
   PARAMETERS: p_r8 AS CHECKBOX MODIF ID ds1.
 SELECTION-SCREEN END OF BLOCK b3.
