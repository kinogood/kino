FUNCTION ZGTPP_MILL_CUT_PROC.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_HEADER) TYPE  ZGTPPS1012
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTPPS1010
*"      OT_RETURN STRUCTURE  ZGTPPS1011 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_MILL_CUT_PROC
*& 프로그램 명 : [GT] 절단 실적 처리
*& 개요   :
*& 생성일 : 2026.02.19
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

  CLEAR OT_RETURN[].

  PERFORM INITIAL_SETUP USING IS_HEADER.

  LOOP AT IT_ITEM INTO DATA(LS_ITEM).
    DATA(LV_ZCUT_CNT) = SY-TABIX.
    APPEND INITIAL LINE TO OT_RETURN[] REFERENCE INTO DATA(LR_RETURN).

    TRY.
*// MILL CUT.
*        PERFORM mill_cut_bdc USING is_header ls_item lr_return->*.
        PERFORM MILL_CUT USING IS_HEADER LS_ITEM LR_RETURN->*.

*// 이전전기.
*        IF lv_zcut_cnt LE is_header-zcut_cnt.
        PERFORM MATERIAL_TRANSFER_POSTING USING IS_HEADER LS_ITEM LR_RETURN->*.
*        ENDIF.

      CATCH LCX_EXCEPTION INTO DATA(LR_EXCEPTION).

    ENDTRY.
  ENDLOOP.

ENDFUNCTION.
