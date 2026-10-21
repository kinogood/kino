FUNCTION zgtpp_if_i_prod_wdoc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTPPSIF0063
*"  EXCEPTIONS
*"      SYSTEM_FAILURE
*"      COMMUNICATION_FAILURE
*"      ILLEGALNAME
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_PROD_WDOC
*& 프로그램 명 : [GT] 작업일보 수신
*& 개요   :
*& 생성일 : 2025.01.14
*& 생성자 : ZGSIDEV05
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : MES
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
  DATA lt_zgtppt3180 TYPE TABLE OF zgtppt3180.
  DATA lv_zifkey TYPE zgtppt3180-zifkey.

*  IF NOT ( i_system_id EQ zgtpp_if_const=>gc_system_id-kgpm OR i_system_id EQ zgtpp_if_const=>gc_system_id-kgpm ).
*    zo_result  = zgtpp_if_const=>gc_if_rec_result-eai_error.
*    zo_message = TEXT-m58.
*    RETURN.
*  ENDIF.

  IF it_item[] IS INITIAL.
    zo_result  = zgtpp_if_const=>gc_if_rec_result-eai_error.
    zo_message = TEXT-m59.
    RETURN.
  ENDIF.

  zo_result  = zgtpp_if_const=>gc_if_rec_result-success.
  zo_message = TEXT-s27.

  GET TIME STAMP FIELD lv_zifkey.

  DATA(lv_datum) = sy-datum.
  DATA(lv_uzeit) = sy-uzeit.
  DATA(lv_uname) = sy-uname.

  lt_zgtppt3180 = VALUE #( FOR ls_item IN it_item[]
                          ( zifkey       = lv_zifkey
                            zsystem_id   = i_system_id
*                            zserno       = CONV numc12( sy-tabix )
                            zserno       = ls_item-zserno
                            werks        = ls_item-werks
                            aufnr        = |{ ls_item-aufnr ALPHA = IN }|
                            posnr        = |{ ls_item-posnr ALPHA = IN }|
                            msg_id       = ls_item-msg_id
                            reg_posin    = ls_item-reg_posin
                            reg_fmsg     = ls_item-reg_fmsg
                            reg_smsg     = ls_item-reg_smsg
                            andat        = ls_item-andat
                            zstat        = zo_result
                            zmessage     = zo_message
                            zerp_stat    = zgtpp_if_const=>gc_result-success
                            zerp_message = TEXT-s27
                            ifdat        = lv_datum
                            iftim        = lv_uzeit
                            ifnam        = lv_uname ) ).

  TRY.
      MODIFY zgtppt3180 FROM TABLE lt_zgtppt3180.

    CATCH cx_root INTO DATA(lr_root).
      zo_result  = zgtpp_if_const=>gc_if_rec_result-success.
      zo_message = TEXT-e75.
      RETURN.
  ENDTRY.

  COMMIT WORK AND WAIT.

ENDFUNCTION.
