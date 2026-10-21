*&---------------------------------------------------------------------*
*& 모듈           : PP
*& 프로그램 ID : ZGTPPR3000
*& 프로그램 명 : [GT] 자재투입 오류 재처리 관리
*& 개요   : 기 발생한 생산 백플러쉬 오류 (백로그) 현황을 조회하고, 삭제 사유를 근거하여 백로그를
*&           삭제하는 기능을 추가 개발함.
*&           필요시 백로그를 재처리하는 기능을 추가 개발함.
*& 생성일 : 2024.10.02
*& 생성자 : ZGSIDEV06
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
REPORT ZGTPPR3000 MESSAGE-ID ZGTPP00.

INCLUDE ZGTPPR3000TOP. "Global 변수, 테이블 및 ALV 변수

INCLUDE ZGTPPR3000S01. " 조회 조건 관련

INCLUDE ZGTPPR3000O01. "PBO

INCLUDE ZGTPPR3000C01. "ALV 관련 로직

INCLUDE ZGTPPR3000F01. "일반 로직 PERFORM 문

INCLUDE ZGTPPR3000F02. "ALV 관련 PERFORM 문

INCLUDE ZGTPPR3000I01. "PAI
*&---------------------------------------------------------------------*
INITIALIZATION.
* 전기일자
  IF S_BUDAT[] IS INITIAL.
    S_BUDAT-SIGN = 'I'.
    S_BUDAT-OPTION = 'BT'.
    S_BUDAT-LOW = SY-DATUM+0(6) && |01|.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN            = SY-DATUM
      IMPORTING
        LAST_DAY_OF_MONTH = S_BUDAT-HIGH
      EXCEPTIONS
        DAY_IN_NO_DATE    = 1
        OTHERS            = 2.

    APPEND S_BUDAT.
  ENDIF.

* 조회조건에서 레이아웃이 기본 지정되어 있을 경우 해당 레이아웃 가져옴.
  PERFORM GET_DEFAULT_LAYOUT CHANGING P_LAYO.

AT SELECTION-SCREEN.
  PERFORM AUTHORITY_CHECKING_PROC.

AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN_ATTRIBUTE.

*&---------------------------------------------------------------------*
START-OF-SELECTION.
  IF P_CHK IS INITIAL.
    PERFORM CHK_COCKPIT.
  ENDIF.
*- Start 2025.05.13
* 통화키 추출
  CLEAR GV_WAERS.
  SELECT SINGLE A~WAERS INTO GV_WAERS
           FROM T001 AS A INNER JOIN T001K AS B
             ON A~BUKRS EQ B~BUKRS
             WHERE B~BWKEY = P_WERKS.
* 코드마스터에서 "MRP 관리자(모품목)"기준으로 공정코드 필수 체크 수행
* 해당 값 존재 시 공정 미입력 했을 경우 오류 출력
  SELECT SINGLE FLD_03 INTO @DATA(LV_FLD_03) FROM ZGTPPT1010
                                     WHERE MODULE_KIND EQ 'PP'
                                       AND CODEGRP EQ '3002'
                                       AND FLD_01 EQ @P_WERKS
                                       AND FLD_02 IN @S_DISPO.
* MRP 관리자 조건을 입력했으나 공정 코드 조건이 없는 데 필수 값 지정이면 이력 남기기
  IF LV_FLD_03 EQ 'X' AND S_GONG[] IS INITIAL AND S_DISPO[] IS NOT INITIAL.

    IF P_CHK IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E15.
    ELSE.
      WRITE :/ TEXT-E15.
    ENDIF.

  ELSE.

    "SRM2511-10071 CO1P 존재시 처리 실행
    PERFORM SUBMIT_ZPPR9012.

* 조회 조건 기준으로 생산 백로그 정보를 발췌함
    PERFORM GET_DATA.
* 조회 데이터 없을 경우 이력 남기기
    IF GT_DISP[] IS INITIAL.

      IF P_CHK IS INITIAL.
        MESSAGE S001.
      ELSE.
        WRITE :/ TEXT-E16.
      ENDIF.

    ELSE.

      IF P_CHK IS INITIAL.

        CALL SCREEN 100.
* 배치모드일 때 특정 오류 유형의 백로그 건들에 대해 저장위치 확장 후 재처리 로직 수행
      ELSE.

        PERFORM BATCH_REWORK_BACKLOG.

      ENDIF.

    ENDIF.

  ENDIF.
*&---------------------------------------------------------------------*
END-OF-SELECTION.
