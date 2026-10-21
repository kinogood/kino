FUNCTION zgtsd_if_o_go_katalk_notice_gi.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_CORPNUM) TYPE  CHAR10 DEFAULT 1238100049
*"     VALUE(I_TEMPLATE) TYPE  CHAR12 DEFAULT 024090000195
*"     VALUE(I_SENDER) TYPE  CHAR20 OPTIONAL
*"     VALUE(I_RECEIVER) TYPE  CHAR20 OPTIONAL
*"     VALUE(IS_CONTENT) TYPE  ZGTSDSIF6000 OPTIONAL
*"  EXPORTING
*"     VALUE(E_TYPE) TYPE  BAPI_MTYPE
*"     VALUE(E_MSG) TYPE  BAPI_MSG
*"     VALUE(E_MSGNR) TYPE  SYMSGNO
*"     VALUE(E_STAT_MSG) TYPE  BAPI_MSG
*"     VALUE(E_RECEIPTNUM) TYPE  CHAR36
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*​
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_IF_O_GO_KATALK_NOTICE_GI
*& 프로그램 명 : [가온전선] 배송출발 카카오 알림톡 발송
*& 개요   :
*& 생성일 : 2026.01.06.​
*& 생성자 : ZGODEV05
*&---------------------------------------------------------------------*​
*& 외부 호출 프로그램 개요   :
*& 타 시스템 인터페이스 개요 : ​
*&---------------------------------------------------------------------*​
*& 프로그램 수정이력​
*&---------------------------------------------------------------------*​
*& 수정일  :​
*& 수정자  :​
*& 수정개요:
*&---------------------------------------------------------------------*

  CLEAR: gv_error.

*1. Check Import Paramaters
  PERFORM go_katalk_chk_import_value  USING    i_corpnum
                                               i_template
                                               i_sender
                                               i_receiver
                                               is_content
                                      CHANGING e_type
                                               e_msg.

*.2 Send Kakao.
  PERFORM go_katalk_api_send          USING    i_corpnum
                                               i_template
                                               i_sender
                                               i_receiver
                                               is_content
                                      CHANGING e_type
                                               e_msg
                                               e_receiptnum.

* 3. Kakao Status Check.
  PERFORM go_katalk_status_chk        USING    i_corpnum
                                               e_receiptnum
                                      CHANGING e_type
                                               e_msg
                                               e_msgnr
                                               e_stat_msg.

  IF e_type IS INITIAL OR
     e_type = 'S'.
    e_type = 'S'.
*   알림톡이 전송되었습니다.
    e_msg  = TEXT-s01.
  ENDIF.

ENDFUNCTION.
