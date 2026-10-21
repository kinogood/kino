*&---------------------------------------------------------------------*
*& Include          ZGT_ABGRU_CHANGE_SO_CONTROL
*&---------------------------------------------------------------------*
**********************************************************************
*로직 미확정으로 주석 처리
**********************************************************************
*  IF SY-MANDT NE '600' AND
*     SY-MANDT NE '400' AND
*     SY-MANDT NE '320' AND
*     SY-MANDT NE '300'.
*
*    SELECT SINGLE MANDT INTO SY-MANDT
*      FROM ZGTPPT1010
*     WHERE MODULE_KIND EQ 'SD'
*       AND CODEGRP     EQ 'ZZZZ'
*       AND FLD_01      EQ SY-UNAME.
*    IF SY-SUBRC NE 0.
*
**1-1) 거부사유 'Z2' 입력 제한
*      IF *VBAP-ABGRU NE VBAP-ABGRU AND VBAP-ABGRU EQ 'Z2'.
*        MESSAGE '에너지주문 통제 거부사유(Z2)는 수기 입력 불가능 합니다.' TYPE 'E'.
*      ENDIF.
*
**1-2) 거부사유 'Z2' 삭제 제한
*      IF *VBAP-ABGRU NE VBAP-ABGRU AND *VBAP-ABGRU EQ 'Z2'.
*        "VBAP-ABGRU = *VBAP-ABGRU.
*        MESSAGE '에너지본부 주문 변경은 팀장님 승인 필요합니다.(세일즈아웃룩 주문보류내역 탭에서 가능)' TYPE 'E'.
*      ENDIF.
*
*    ENDIF.
*
*  ENDIF.
