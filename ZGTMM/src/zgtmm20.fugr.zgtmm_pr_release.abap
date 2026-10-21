FUNCTION zgtmm_pr_release.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_APPID) TYPE  CHAR32
*"     VALUE(I_STATE) TYPE  CHAR10
*"  EXPORTING
*"     VALUE(MTYPE) TYPE  BAPI_MTYPE
*"     VALUE(MESSAGE) TYPE  BAPI_MSG
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_PR_RELEASE
*& 프로그램 명 :  구매요청 결재 상태 릴리즈
*& 개요   : WELS 결재 상태 값 기준으로 구매요청 문서를 릴리즈 처리하는 FUNCTION 개발
*& 생성일 : 2026.03.13
*& 생성자 : ZGODEV07
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 :
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  CLEAR:
    mtype,message.

*1. IMPORT PARAMETER 값 기준으로 결재 릴리즈 대상 구매요청 정보 조회
*
*	I_STATE = C 이면
*	TABLE : ZGTMMT1070
*	SELECT 조건 : BANFN, BNFPO
*	WHERE 조건 :
*	APPID = Import Parameter APPID 값
*	APPTYPE = "B"
*	ERDAT <> "" 인 대상


  SELECT
    z1~banfn,
    z1~bnfpo
    FROM zgtmmt1070 AS z1
    WHERE z1~appid EQ @i_appid
    AND z1~apptype EQ @gc_b
    AND z1~erdat IS NOT INITIAL
    INTO TABLE @DATA(lt_banfn).
*
*2. BAPI_REQUISITION_RELEASE 호출 PR 릴리즈 처리 수행
*	2-1) BAPI 처리를 위한 데이터 설정
*
* BAPI 필드                   VALUE
* NUMBER                    ALV-BANFN
* REL_CODE                    S
* ITEM                    ALV-BNFPO

  DATA:
    lv_rel_code TYPE bapimmpara-rel_code,
    lt_return   TYPE STANDARD TABLE OF bapireturn,
*    LT_APPR   TYPE STANDARD TABLE OF ZGTMMT1070,
    ls_log      TYPE zgtmmt1080.

  lv_rel_code = gc_rel_code.
  LOOP AT lt_banfn ASSIGNING FIELD-SYMBOL(<ls_banfn>).
    CLEAR lt_return[].
    CALL FUNCTION 'BAPI_REQUISITION_RELEASE'
      EXPORTING
        number                 = <ls_banfn>-banfn
        rel_code               = lv_rel_code
        item                   = <ls_banfn>-bnfpo
      TABLES
        return                 = lt_return
      EXCEPTIONS
        authority_check_fail   = 1
        requisition_not_found  = 2
        enqueue_fail           = 3
        prerequisite_fail      = 4
        release_already_posted = 5
        responsibility_fail    = 6
        OTHERS                 = 7.
    IF sy-subrc NE 0.
*2-2) RETURN-TYPE = E 이면
*A) CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
*: ZGTMMT1080 오류 이력 LOG 업데이트
*
*필드                   VALUE
*DOCNO                    BAPI 오류 구매요청번호
*DOCITEM                    BAPI 오류 구매요청 품목
*STATUS                   E
*ERDAT                    SY-DATUM
*ERDAT_LOCA                   SY-DATLO
*ERTIM                    SY-UZEIT
*ERTIM_LOCAL                    SY-TIMLO
*AEDAT
*AEDAT_LOCAL
*AEZET
*ZEZET_LOCAL
*
*: 오류 발생건 이후 대상 품목 라인 BAPI 계속 수행
*
*B) Export RETUNR 후 종료
*Export Parameter                   Value
*ZO_RESULT                    02'
*ZO_MESSAGE                   BAI 대표 MESSAGE
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      MTYPE = gc_E.
      IF line_exists( lt_return[ type = gc_e ] ).
        MESSAGE = lt_return[ type = gc_e ]-message.
      ELSE.
        MESSAGE = TEXT-e01. "릴리즈 중 오류 발생
      ENDIF.

      ls_log-docno = <ls_banfn>-banfn.
      ls_log-docitem = <ls_banfn>-bnfpo.
      ls_log-status = gc_e.
      ls_log-erdat = sy-datum.
      ls_log-erdat_local = sy-datlo.
      ls_log-ertim = sy-uzeit.
      ls_log-ertim_local = sy-timlo.
      MODIFY zgtmmt1080 FROM ls_log.
      COMMIT WORK.

*      LT_LOG = VALUE #( BASE LT_LOG (
*            DOCNO = <LS_BANFN>-BANFN
*            DOCITEM = <LS_BANFN>-BNFPO
*            STATUS = GC_E
*            ERDAT = SY-DATUM
*            ERDAT_LOCAL = SY-DATLO
*            ERTIM = SY-UZEIT
*            ERTIM_LOCAL = SY-TIMLO
*      ) ).

    ELSE.
*2-3) RETURN-TYPE = S 이고 이면
*A)  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*: PR 릴리즈 요청 이력 테이블업데이트
*
*ZGTMMT1070
*BANFN
*BANFPO
*APPTYPE
*APPUSER
*MAILSEND                   Y
*ERDAT
*ERDAT_LOCAL
*ERTIM
*ERTIM_LOCAL
*AEDAT                    SY-DATUM
*AEDAT_LOCAL                    SY-DATLO
*AEZET                    SY-UZEIT
*AEZET_LOCAL                    SY-TIMLO
*
*
*B) Export RETUNR 후 종료
*Export Parameter                   Value
*ZO_RESULT                    00'
*ZO_MESSAGE                   처리완료
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

      UPDATE zgtmmt1070 SET
        aedat = @sy-datum,
        aedat_local = @sy-datlo,
        aezet = @sy-uzeit,
        aezet_local = @sy-timlo
        WHERE banfn EQ @<ls_banfn>-banfn
        AND bnfpo EQ @<ls_banfn>-bnfpo
        AND mailsend EQ @gc_y.
      COMMIT WORK.

      IF MTYPE NE gc_E.

        mtype  = gc_00.
        message = TEXT-m01. "처리완료
      ENDIF.
    ENDIF.
  ENDLOOP.



ENDFUNCTION.
