*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR3200
*& 프로그램 명 : [GT] Lot(꼬리표번호) to 배치번호 조회 GAON 2026.09.04 by ZGSIDEV07
*& 개요   :  Lot(꼬리표번호) to 배치번호 조회 프로그램
*& 생성일 : 2026.09.04
*& 생성자 : ZGSIDEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
REPORT ZGTPPR3200  MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR3200TOP.
INCLUDE ZGTPPR3200S01.
INCLUDE ZGTPPR3200C01.
INCLUDE ZGTPPR3200F01.
INCLUDE ZGTPPR3200O01.
INCLUDE ZGTPPR3200I01.

INITIALIZATION.
  PERFORM INITIALIZATION.

AT SELECTION-SCREEN.
  IF GS_KUNN1[] IS NOT INITIAL AND
     GS_KUNN2[] IS NOT INITIAL.
    MESSAGE S001 WITH '판매처나 납품처중 한곳만 선택하세요.'.
  ENDIF.

START-OF-SELECTION.
  PERFORM READ_DATA_FROM_TABLES.

  READ TABLE GT_DATA  INDEX 1.

*&  권한체크(2005.11.09 주석처리)
  AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
                      ID 'WERKS'  FIELD GP_WERKS
                      ID 'SPGCD'  FIELD GT_DATA-SPGCD.

  IF SY-SUBRC <> 0.
    MESSAGE S003 WITH 'SPG [' GT_DATA-SPGCD
                      ']의 작업권한을 확인하세요.'.
    RETURN.
  ENDIF.

  LOOP AT GT_DATA WHERE PTS_ARBPL IS NOT INITIAL.
    GT_DATA-ARBPL = GT_DATA-PTS_ARBPL.
    MODIFY GT_DATA  INDEX SY-TABIX.
  ENDLOOP.

  LOOP AT GT_DATA WHERE ARBPL IS NOT INITIAL.

    SELECT SINGLE KTEXT INTO GT_DATA-KTEXT
             FROM M_CRAMN
    WHERE WERKS = GP_WERKS
              AND ARBPL = GT_DATA-ARBPL
              AND SPRAS = SY-LANGU.

    MODIFY GT_DATA.

  ENDLOOP.

  SORT GT_DATA  BY SPGCD PROCD AUFNR TAGNR.

  CALL SCREEN '0100'.
