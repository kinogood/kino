*&---------------------------------------------------------------------*
*& Include          ZGTPPI3090S01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
 SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01. "검색 조건
* 전송
   PARAMETERS : p_werks LIKE zgtppt3150-werks DEFAULT '1306'. "플랜트
   SELECT-OPTIONS: s_jobno  FOR zgtppt3160-job_no, "제조지시번호
                   s_lineno FOR zgtppt3160-line_no, "라인번호
                   s_serial FOR zgtppt3160-serial_info, "시리얼정보
                   s_oper   FOR zgtppt3160-oper_code, "공정코드
                   s_jobls  FOR zgtppt3160-jobls, "제조지시 요청번호
                   s_chdat  FOR zgtppt3160-chdat MODIF ID ds1. "전환 처리일자
* 로그 조회
   SELECT-OPTIONS : s_ifdat FOR sy-datum MODIF ID ds2 NO-EXTENSION. "전송 일자

 SELECTION-SCREEN END OF BLOCK b1.

 SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02. "인터페이스 전송

   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN:   COMMENT 01(31) TEXT-001. "처리모드 선택
     SELECTION-SCREEN POSITION 33.
     PARAMETERS : p_r1 RADIOBUTTON GROUP r1 USER-COMMAND u1 DEFAULT 'X'.
     SELECTION-SCREEN COMMENT 35(04) TEXT-002 FOR FIELD p_r1.  "전송

     SELECTION-SCREEN POSITION 47.
     PARAMETERS : p_r2 RADIOBUTTON GROUP r1.
     SELECTION-SCREEN COMMENT 49(17) TEXT-003 FOR FIELD p_r2.  "로그 조회

   SELECTION-SCREEN END OF LINE.
* 로그 조회
   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN:   COMMENT 01(31) TEXT-004 MODIF ID ds2. "조회모드 선택
     SELECTION-SCREEN POSITION 33.
     PARAMETERS : p_r5 RADIOBUTTON GROUP r3 USER-COMMAND u1 MODIF ID ds2.
     SELECTION-SCREEN COMMENT 35(04) TEXT-005 FOR FIELD p_r5
       MODIF ID ds2.  "성공 건만

     SELECTION-SCREEN POSITION 47.
     PARAMETERS : p_r6 RADIOBUTTON GROUP r3 MODIF ID ds2.
     SELECTION-SCREEN COMMENT 49(17) TEXT-006 FOR FIELD p_r6
       MODIF ID ds2. "오류 건만

     SELECTION-SCREEN POSITION 70.
     PARAMETERS : p_r7 RADIOBUTTON GROUP r3 MODIF ID ds2 DEFAULT 'X'.
     SELECTION-SCREEN COMMENT 72(8) TEXT-007 FOR FIELD p_r7
       MODIF ID ds2. "전체

   SELECTION-SCREEN END OF LINE.

 SELECTION-SCREEN END OF BLOCK b2.

 SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-t03. "처리 옵션

   PARAMETERS : p_r8 AS CHECKBOX MODIF ID ds1.

 SELECTION-SCREEN END OF BLOCK b3.
