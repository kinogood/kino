*&---------------------------------------------------------------------*
*& Program ID  : ZLER0019                                              *
*& Title       : [MM_FI] 기타통문 요청                                 *
*& Create Date : 2004. 12. 14                                          *
*& Author      : SDC10                                                 *
*& Frequency   : Frequency                                             *
*& GAP NO      : LES022                                                *
*& DESCRIPTION                                                         *
*&---------------------------------------------------------------------*
*  Changed by  |  Description of change                    |  Date     *
*----------------------------------------------------------------------*
* 2010/09/15             [요청번호] LSMTRON 물류개선 요청자:이길상c    *
* 2014/10/15   H.M.LIM   [요청번호] 기능개선 48114 통문유형 표시 제한  *
* 2014.11.07   S.J.Nam  [자체개선 52275]   회사코드 리스트박스로 수정  *
*                                 기타통문증발행시 가이드 메시지 추가  *
************************************************************************

REPORT  zgtmmr4530.

INCLUDE ZGTMMR4530TOP.
*INCLUDE zler0019top.
INCLUDE ZGTMMR4530F01.
*INCLUDE zler0019f01.


*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM CHECK_BUKRS.
  PERFORM CHECK_AUTH.

*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  IF P_BUKRS IS INITIAL.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'P_GUBUN1'.
        SCREEN-INPUT = 0.
        CLEAR P_GUBUN1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

*&---------------------------------------------------------------------*
*&   Event AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_gubun1 .
  PERFORM value_request USING 'GUBUN1'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_bukrs .
  PERFORM value_request_bukrs.

*&---------------------------------------------------------------------*
*&   Event INITIALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  t1 = '유형별기타통문'.

*&---------------------------------------------------------------------*
*&   Event START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  IF p_bukrs IS INITIAL.
    MESSAGE s000(zle1) DISPLAY LIKE 'E' WITH '회사코드를 입력하십시오'.
    RETURN.
  ENDIF.
  IF p_gubun1 IS INITIAL.
    MESSAGE s000(zle1) DISPLAY LIKE 'E' WITH '통문유형을 입력하십시오'.
    RETURN.
  ENDIF.

  READ TABLE lt_values WITH KEY key = p_gubun1.
  IF sy-subrc = 0.
    ts_iv_type = p_gubun1.
    ts_bukrs   = p_bukrs.
    tt_flag    = 'X'.
    TT_FLAG2   = 'X'.

    IF p_gubun1(1) = 'C'.     "FI
      EXPORT tt_flag
             TT_FLAG2
             ts_iv_type
             ts_bukrs
             TO MEMORY ID 'ZZZZ'.

*      CALL TRANSACTION 'ZLE0201T'.
      CALL TRANSACTION 'ZGTMMR4550T'.


    ELSEIF p_gubun1(1) = 'E'. "MM
      EXPORT tt_flag
             TT_FLAG2
             ts_iv_type
             ts_bukrs
             TO MEMORY ID 'ZZZZ'.

      IF ts_iv_type = 'E07'.
*        CALL TRANSACTION 'ZLE0200E'.
        CALL TRANSACTION 'ZGTMMR4540E'.
      ELSE.
*        CALL TRANSACTION 'ZLE0200T'.
        CALL TRANSACTION 'ZGTMMR4540T'.
      ENDIF.

    ENDIF.
  ENDIF.
