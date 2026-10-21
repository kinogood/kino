*&---------------------------------------------------------------------*
*& 모듈           : PP
*& 프로그램 ID : ZGTPPR3020
*& 프로그램 명 : [GT] 생산실적 모니터링
*& 개요   : 생산 오더 현황 모니터링 Report
*&          생산 오더의 계획 종료일을 기준으로, 투입 지연/실적 지연/입고 지연 여부를 확인하여
*&          지연 발생시 오더의 설비 담당자에게 E-mail 알림 전송.
*&          < 기존 오더 모니터링 Report인 ZPPR0021 Copy 후 수정 진행 >
*& 생성일 : 2024.10.16
*& 생성자 : ZGSIDEV06
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  // 수정자 // 수정개요
*& -. 2024.10.16 // ZGSIDEV06 // ZPPR0021 COPY 후 프로그램 수정
*& -. 2026.04.21 // ZGODEV03 // [U01] 가온전선 로직 추가
*& -. 2026.06.09 // ZGODEV03 // [U02] 레이아웃 추가
*& -. 2026.09.07 // ZGODEV03 // [U03] TECO 기능 추가(T-code:ZGTPPR3021G)
*&---------------------------------------------------------------------*

INCLUDE ZGTPPR3020TOP. " Global Data

INCLUDE ZGTPPR3020O01. " PBO-Modules

INCLUDE ZGTPPR3020I01.  " PAI-Modules

INCLUDE ZGTPPR3020F01." FORM-Routines     *

INCLUDE ZGTPPR3020F02." FORM-Routines(CLASS)

INITIALIZATION.
  GET PARAMETER ID 'WRK' FIELD P_PWERK.
  PERFORM GET_PARAMETER_DESC.
  PERFORM INIT_VARIANT.

START-OF-SELECTION.
  PERFORM INITIAL_PROC.
*- Start 2024.10.16 RESB에서 투입정보를 가져오기 위해 오더번호만 취합
  CLEAR : GT_ORDER, GT_ORDER[], GT_RESB2, GT_RESB2[], GT_AFRU, GT_AFRU[],
              GT_AFPO, GT_AFPO[].
*- End 2024.10.16
*- Start 2025.02.20 작업시작일자 조회 조건 존재 시 최대적중수 CLEAR 할 것
  IF S_PAYOFF[] IS NOT INITIAL.
    CLEAR P_DBCNT.
  ENDIF.

*- Start 2026.07.25 -가온전선 추가사항
  IF SY-TCODE = 'ZGTPPR3021G' OR SY-TCODE = 'ZGTPPR3020G'.
    CLEAR P_DBCNT.
  ENDIF.
*- End 2026.07.25

  IF S_STATUS-LOW = ' '.
    PERFORM SELECT_PROC.  "ALL
  ELSEIF S_STATUS-LOW = 'A'.
    PERFORM SELECT_PROC1.  "작업지시전...
  ELSE.
    PERFORM SELECT_PROC2.  "작업대기..오더종료
  ENDIF.
*- Start 2024.10.16 신규 필드 상태값 체크를 위한 데이터 취합
  PERFORM GET_DATA_NEW_FIELD.
*- End 2024.10.16
  PERFORM ADDITIONAL_INFO_PROC.

  IF GT_AFKO[] IS INITIAL.

    MESSAGE S001 WITH TEXT-035.
    EXIT.

  ELSE.

    DATA: LV_DBCNT LIKE SY-DBCNT.
    DATA: LI_CNT TYPE I.

    CLEAR LV_DBCNT.
    DESCRIBE TABLE GT_AFKO LINES LV_DBCNT.
    LI_CNT = LV_DBCNT + GI_DELLINECNT.

    IF LI_CNT = P_DBCNT.
      LI_CNT = P_DBCNT - GI_DELLINECNT.
      MESSAGE S004 WITH P_DBCNT
                        TEXT-036
                        LI_CNT
                        TEXT-037.
    ENDIF.

  ENDIF.

  IF SY-BATCH NE 'X'.
    CALL SCREEN 100.
* 배치잡 실행시, 투입/실적/입고 지연 별로 오더 설비담당자에게 E-Mail 발송
  ELSE.
*- Start 2025.03.25
    PERFORM SEND_TO_EMAIL_DELAY_ORDER.
*- End 2025.03.25
  ENDIF.

END-OF-SELECTION.

AT SELECTION-SCREEN.

  PERFORM AUTHORITY_CHECKING_PROC.

AT SELECTION-SCREEN  ON S_DISPO.

  IF S_DISPO-LOW+0(1) = '*' OR
     S_DISPO-LOW+1(1) = '*'.
    MESSAGE E001 WITH TEXT-038.
  ENDIF.

*AT SELECTION-SCREEN  ON s_gstrs.
*  CHECK NOT s_gstrs-high IS INITIAL.
*  DATA: lv_date    TYPE p.
*  lv_date = s_gstrs-high - s_gstrs-low.
*  IF lv_date > 31.
*    MESSAGE e001 WITH '작업시작일 범위가 너무 큽니다(최대 31일)'.
*  ENDIF.
*- Start 2025.02.04
*AT SELECTION-SCREEN  ON p_dbcnt.
** 임시로 고무선, UTP, 기기선, Tube는 5000라인까지로 제한
*    IF s_dispo-low+0(2) = 'RC' OR
*       s_dispo-low+0(2) = 'LN' OR
*       s_dispo-low+0(2) = 'EC' OR
*       s_dispo-low+0(2) = 'TB' OR
*       s_dispo-low+0(2) = 'SH' OR
*       s_dispo-low+0(2) = 'LC'.
*
*      IF p_dbcnt < 1     OR
*         p_dbcnt > 5000.
*        MESSAGE e004 WITH '최대 5000까지 가능합니다.'.
*      ENDIF.
*
*    ELSE.
*
*      IF p_dbcnt < 1     OR
*       p_dbcnt > 500.
*        MESSAGE e004 WITH '최대 500까지 가능합니다.'.
*      ENDIF.
*
*    ENDIF.
*- End 2025.02.04
*AT SELECTION-SCREEN  ON VALUE-REQUEST FOR s_status-low.
*  PERFORM pov_for_status CHANGING s_status-low.

*[U01] 가온전선 추가
AT SELECTION-SCREEN  ON S_PAYOFF.
  IF SY-TCODE EQ 'ZGTPPR3020G'  OR SY-TCODE EQ 'ZGTPPR3021G'.
    IF S_PAYOFF-LOW IS NOT INITIAL AND S_PAYOFF-HIGH IS NOT INITIAL.
      DATA: LV_DAYS   LIKE VTBBEWE-ATAGE,
            LV_MONTHS LIKE VTBBEWE-ATAGE,
            LV_YEARS  LIKE VTBBEWE-ATAGE.

      CLEAR: LV_DAYS, LV_MONTHS, LV_YEARS.
      CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
        EXPORTING
          I_DATE_FROM    = S_PAYOFF-LOW
          I_DATE_TO      = S_PAYOFF-HIGH
          I_FLG_ROUND_UP = 'X'
        IMPORTING
          E_DAYS         = LV_DAYS
          E_MONTHS       = LV_MONTHS
          E_YEARS        = LV_YEARS.

      IF LV_DAYS GT '61'.
        MESSAGE E001 WITH TEXT-081.
      ENDIF.
    ENDIF.
  ENDIF.
*[U01] 가온전선 추가

AT SELECTION-SCREEN  ON VALUE-REQUEST FOR S_APRIO-LOW.

  PERFORM POV_FOR_APRIO CHANGING S_APRIO-LOW.

*[U02]
*- 레이아웃 탐색도움말
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LAYO.

  PERFORM SELECT_ALV_VARIANT CHANGING P_LAYO.
*[U02]

AT SELECTION-SCREEN OUTPUT.

  PERFORM GET_PARAMETER_DESC.
  PERFORM MODIFY_SELECTION_SCREEN.
