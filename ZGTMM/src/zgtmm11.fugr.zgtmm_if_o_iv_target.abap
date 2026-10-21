FUNCTION ZGTMM_IF_O_IV_TARGET.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      OT_IVDATA STRUCTURE  ZGTMMS5003
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_O_IV_TARGET
*& 프로그램 명 : 마감 확인 요청 정보 전송(SAP->G-SRM)
*& 개요   : G-SRM(전자구매시스템)으로 마감 확정 요청 정보를 전송하는 RFC
*& 생성일 : 2026.02.09
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
  DATA LV_URL TYPE STRING.

  LV_URL = 'http://10.156.9.5:8081/gsrm/noSessionFileDownload/view.uni?UUID=ZswieVQZmGyYUp7rl2VQJqNXEmMd2N67dtb%2FgzyIzEj1F4Z7jlxPW4uwcHGl'.

*URL 호출
     CL_GUI_FRONTEND_SERVICES=>EXECUTE( EXPORTING APPLICATION = LV_URL ).

ENDFUNCTION.
