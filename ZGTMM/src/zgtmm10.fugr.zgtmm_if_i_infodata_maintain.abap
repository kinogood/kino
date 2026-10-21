FUNCTION ZGTMM_IF_I_INFODATA_MAINTAIN.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_EINA) TYPE  MEWIEINA OPTIONAL
*"     VALUE(I_EINAX) TYPE  MEWIEINAX OPTIONAL
*"     VALUE(I_EINE) TYPE  MEWIEINE OPTIONAL
*"     VALUE(I_EINEX) TYPE  MEWIEINEX OPTIONAL
*"     VALUE(I_TEST) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     VALUE(E_EINA) TYPE  MEWIEINA
*"     VALUE(E_EINE) TYPE  MEWIEINE
*"  TABLES
*"      COND_VALIDITY STRUCTURE  MEWIVALIDITY OPTIONAL
*"      CONDITION STRUCTURE  MEWICONDITION OPTIONAL
*"      RETURN STRUCTURE  BAPIRETURN OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_INFODATA_MAINTAIN
*& 프로그램 명 : 인포레코드 유지(새 세션 실행용)
*& 개요   : ME_INFORECORD_MAINTAIN을 DESTINATION 'NONE'으로 새 세션에서 실행하기
*&           위한 RFC 래퍼. 같은 세션에서 플랜트 구매조직 데이터를 방금 생성한 경우
*&           BAPI 내부 버퍼가 이전 상태를 유지해 조건 생성이 ME816(06725)로 실패하므로
*&           새 세션에서 조건을 생성한다. (SET_INFORECORD / ZGTMMR1140에서 호출)
*&           I_TEST = 'X'이면 ROLLBACK, 아니면 오류 없을 때 COMMIT.
*& 생성일 : 2026.09.27
*&---------------------------------------------------------------------*

  CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
    EXPORTING
      I_EINA        = I_EINA
      I_EINAX       = I_EINAX
      I_EINE        = I_EINE
      I_EINEX       = I_EINEX
    IMPORTING
      E_EINA        = E_EINA
      E_EINE        = E_EINE
    TABLES
      COND_VALIDITY = COND_VALIDITY
      CONDITION     = CONDITION
      RETURN        = RETURN.

  IF I_TEST = 'X'
  OR LINE_EXISTS( RETURN[ TYPE = 'E' ] )
  OR LINE_EXISTS( RETURN[ TYPE = 'A' ] )
  OR LINE_EXISTS( RETURN[ CODE = '06725' ] ).
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
  ENDIF.

ENDFUNCTION.
