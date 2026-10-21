FUNCTION ZGTPP_PROD_STATUS_REF_SO .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTPPS1015
*"      OT_STAT_OVERVIEW STRUCTURE  ZGTPPS1013 OPTIONAL
*"      OT_STAT_DETAIL STRUCTURE  ZGTPPS1014 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_PROD_STATUS_REF_SO
*& 프로그램 명 : [GT] 판매 진도 조회 : 공정 진척 현황
*& 개요   :
*& 생성일 : 2026.06.04
*& 생성자 : ZGODEV06
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

  IF IT_ITEM[] IS INITIAL.
    RETURN.
  ENDIF.

*// 절단지시 정보 추출.
  PERFORM GET_OVERVIEW_FROM_ZASSIGNMNT TABLES IT_ITEM OT_STAT_OVERVIEW OT_STAT_DETAIL.

*// 조장구성 정보 추출.
*  IF OT_STAT_OVERVIEW[] IS INITIAL.
  PERFORM GET_DETAIL_FROM_ZGTPPT2000 TABLES IT_ITEM OT_STAT_OVERVIEW OT_STAT_DETAIL.
*  ENDIF.

  SORT OT_STAT_OVERVIEW BY VBELN POSNR GRDAT DESCENDING.
  DELETE ADJACENT DUPLICATES FROM OT_STAT_OVERVIEW COMPARING VBELN POSNR.

ENDFUNCTION.
