*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR1030
*& 프로그램 명 : [GT-PP] Component & Assembly Scrap BOM  2024.10.02 by ZGSIDEV07
*& 개요   : 자재마스터의 조립품 스크랩(불량)과 BOM 아이템의 컴포넌트 스크랩(Loss) 값을 업데이트하는 기능임
*& 생성일 : 2024.10.11
*& 생성자 : ZGSIDEV07
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

INCLUDE zgtppr1030t01.
INCLUDE zgtppr1030cls.
INCLUDE zpplbdcpara.
INCLUDE zpplcommon.
INCLUDE zgtppr1030o01.
INCLUDE zgtppr1030i01.
INCLUDE zgtppr1030f01.
INCLUDE zgtppr1030bdc.

INITIALIZATION.
  CLEAR: gt_data[],  gt_temp[].

AT SELECTION-SCREEN ON VALUE-REQUEST FOR gp_procd.
  PERFORM pov_for_procd.

START-OF-SELECTION.
  AUTHORITY-CHECK OBJECT 'ZPP_DISPO'
                      ID 'WERKS'  FIELD gp_werks
                      ID 'DISPO'  FIELD gp_dispo.

  IF sy-subrc <> 0.
    MESSAGE s003 WITH 'MRP관리자[' gp_dispo
                      ']의 작업권한을 확인하세요.'.
    RETURN.
  ENDIF.

  PERFORM prepare_data_for_process.
