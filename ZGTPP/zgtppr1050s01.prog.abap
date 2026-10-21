*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030S01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*


 SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02. "선택옵션

   SELECT-OPTIONS: s_werks    FOR  mkal-werks OBLIGATORY DEFAULT '1306' ,  "플랜트
                   s_matnr    FOR  mkal-matnr,             "모품목코드
                   s_andat    FOR  mast-andat NO-EXTENSION." BOM&라우팅 생성 일자
   SELECTION-SCREEN BEGIN OF LINE.
     SELECTION-SCREEN POSITION 01.
     PARAMETERS : p_c1 AS CHECKBOX .
     SELECTION-SCREEN COMMENT 3(15) TEXT-017 FOR FIELD p_C1.  "이미  생성된 생산버젼 포함
   SELECTION-SCREEN END OF LINE.
 SELECTION-SCREEN END OF BLOCK b2.

 SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-t03. "처리 옵션

   SELECTION-SCREEN BEGIN OF LINE.

     SELECTION-SCREEN POSITION 01.
     PARAMETERS : p_C2 AS CHECKBOX MODIF ID ds1 .
     SELECTION-SCREEN COMMENT 3(6) TEXT-011 FOR FIELD p_C2.  "배치 모드

   SELECTION-SCREEN END OF LINE.

 SELECTION-SCREEN END OF BLOCK b3.


 SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-t04. "레이아웃 선택

   PARAMETERS p_layo LIKE disvariant-variant.

 SELECTION-SCREEN END OF BLOCK b4.

*- 레이아웃 탐색도움말
 AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layo.
   PERFORM select_alv_variant CHANGING p_layo.
