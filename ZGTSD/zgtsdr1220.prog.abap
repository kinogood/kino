*&---------------------------------------------------------------------*
*&  모듈       : SD
*&  프로그램 ID : ZGTSDR1220
*&  프로그램 명  : 자재마스터 영업뷰 생성
*&  개요       : 자재 마스터에 영업 관련 Data 등록을 위한 영업 View 및 일부 플랜트 데이타 생성
*&              => ZSDR1100 COPY 생성
*&  생성일      : 2026.04.27
*&  생성자      : ZGODEV01
*&---------------------------------------------------------------------*
*& 외부호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*----------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
REPORT ZGTSDR1220 MESSAGE-ID ZTR1.

INCLUDE ZGTSDR1220TOP.
INCLUDE ZGTSDR1220SEL.
INCLUDE ZGTSDR1220F01.


*----------------------------------------------------------------------*
*     INITIALIZATION                                                   *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN.                                             *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM SELECTION_SCREEN.

*----------------------------------------------------------------------*
*     AT SELECTION-SCREEN OUTPUT.                                      *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM SELECTION_SCREEN_OUTPUT.


*----------------------------------------------------------------------*
*     START-OF-SELECTION                                               *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM INIT_VALUE_SETTING.
  IF SY-BATCH IS NOT INITIAL.
    GV_BATCH = 'X'.
  ELSE.
    CLEAR GV_BATCH.
  ENDIF.

  "조회
  IF P_PS2 IS NOT INITIAL AND
     GV_BATCH IS NOT INITIAL.
    MESSAGE E000(ZGTSD01) WITH TEXT-E01.
  ENDIF.

*    확장의 경우, 허용 플랜트를 정의함
  IF P_PS4 = 'X'.
    PERFORM INIT_VALUE_SETTING_EXT_WERKS.
  ENDIF.

  PERFORM DATA_GET_FROM_DB.

  IF GMARC[] IS INITIAL.

    MESSAGE S000 DISPLAY LIKE 'E' WITH '해당 데이타가 없습니다!'.
    STOP.

  ELSE.
    IF GV_BATCH IS NOT INITIAL.
      PERFORM BACKGROUND_PROCESS.
    ELSE.
      PERFORM DISPLAY_ITEM_DATA.
    ENDIF.

  ENDIF.
