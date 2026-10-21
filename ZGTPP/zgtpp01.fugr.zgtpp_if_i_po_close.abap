FUNCTION zgtpp_if_i_po_close.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_CLSD STRUCTURE  ZGTPPSIF0028
*"      OT_RESULT STRUCTURE  ZGTPPSIF0029
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_PO_CLOSE
*& 프로그램 명 : [GT] [공통 MES] 생산오더 종료 처리
*& 개요   :
*& 생성일 : 2024.12.12
*& 생성자 : ZGSIDEV08
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : 지중/부스닥트 MES
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*

*// SYSTEM ID에 따라 처리 함수를 달리 호출

  IF i_system_id EQ 'KPCM'  OR "// 지중 MES
     i_system_id EQ 'KSCM'  OR "// 소재 MOM SRM2510-04825
     i_system_id EQ 'KFCM'  .  "한미소 MOM 260902

    CALL FUNCTION 'ZGTPP_IF_I_CABLE_PO_CLOSE'
      EXPORTING
        i_system_id = i_system_id
      IMPORTING
        zo_result   = zo_result
        zo_message  = zo_message
      TABLES
        it_clsd     = it_clsd
        ot_result   = ot_result.

  ELSEIF i_system_id EQ 'KGPM' OR  "// 가온전선.
         i_system_id EQ 'KGOM'.

    CALL FUNCTION 'ZGTPP_IF_I_GAON_PO_CLOSE'
      EXPORTING
        i_system_id = i_system_id
      IMPORTING
        zo_result   = zo_result
        zo_message  = zo_message
      TABLES
        it_clsd     = it_clsd
        ot_result   = ot_result.
  ENDIF.

ENDFUNCTION.
