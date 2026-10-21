FUNCTION zgtpp_bd_pp_work_data.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4
*"     VALUE(I_ZWERKS) TYPE  CHAR4
*"     VALUE(I_ZTABLE) TYPE  CHAR20 OPTIONAL
*"     VALUE(I_ZKEY1) TYPE  CHAR40
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_BD_PP_WORK_DATA
*& 프로그램 명 : [GT-PP] 생산 제조지시 정보 추출
*& 개요   : MES에서 전송된 생산 제조지시 데이터를 테이블에 저장함
*& 생성일 : 2025.02.13
*& 생성자 : ZGSIDEV04
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


  DATA : ls_zgtedt2132 TYPE zgtedt2132,
         lt_zgtedt2132 TYPE TABLE OF zgtedt2132.
  DATA : ls_ZGTPPT3150 TYPE zgtppt3150,
         lt_ZGTPPT3150 TYPE TABLE OF zgtppt3150.
  DATA : ls_ZGTPPT3160 TYPE zgtppt3160,
         lt_ZGTPPT3160 TYPE TABLE OF zgtppt3160.
  DATA : ls_ZGTPPT3170 TYPE zgtppt3170,
         lt_ZGTPPT3170 TYPE TABLE OF zgtppt3170.

  DATA : lv_result1(2),
         lv_result2(2),
         lv_result3(2),
         lv_message(100).

  CLEAR :  lt_zgtedt2132[], lS_zgtedt2132,
           lt_ZGTPPT3150[], lS_ZGTPPT3150,
           lt_ZGTPPT3160[], lS_ZGTPPT3160,
           lt_ZGTPPT3170[], lS_ZGTPPT3170.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_zgtedt2132
    FROM zgtedt2132
   WHERE  zsystem_id = 'KBDM'
     AND  zwerks = i_zwerks
     AND  ztable = 'ZGTPPT3150'
     AND  zkey1 =  i_zkey1.

  LOOP AT lt_zgtedt2132 INTO ls_zgtedt2132.
    ls_zgtppt3150-job_no         = ls_zgtedt2132-zkey1.
    ls_zgtppt3150-line_no        = ls_zgtedt2132-zkey2.
    ls_zgtppt3150-serial_info    = ls_zgtedt2132-zkey3.
    ls_zgtppt3150-werks          = ls_zgtedt2132-zvalue01.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = ls_zgtedt2132-zvalue02
      IMPORTING
        output = ls_zgtedt2132-zvalue02.
    ls_zgtppt3150-matnr          = ls_zgtedt2132-zvalue02.
    ls_zgtppt3150-zlength_1      = ls_zgtedt2132-zvalue03.
    ls_zgtppt3150-zlength_2      = ls_zgtedt2132-zvalue04.
    ls_zgtppt3150-zlength_3      = ls_zgtedt2132-zvalue05.
    ls_zgtppt3150-zlength_4      = ls_zgtedt2132-zvalue06.
    ls_zgtppt3150-zlength_5      = ls_zgtedt2132-zvalue07.
    ls_zgtppt3150-zlength_6      = ls_zgtedt2132-zvalue08.
    ls_zgtppt3150-zlength_7      = ls_zgtedt2132-zvalue09.
*  LS_ZGTPPT3150-ZIF_APPLIED    = LS_ZGTEDT2132-ZVALUE10
    ls_zgtppt3150-zif_last       = ls_zgtedt2132-zvalue10.
    ls_zgtppt3150-zweight        = ls_zgtedt2132-zvalue11.
    ls_zgtppt3150-zstd           = ls_zgtedt2132-zvalue12.
    ls_zgtppt3150-crdat          = sy-datum.
    ls_zgtppt3150-crtim          = sy-uzeit.
    ls_zgtppt3150-crnam          = sy-uname.
*  LS_ZGTPPT3150-CHDAT          = LS_ZGTEDT2132-ZVALUE
*  LS_ZGTPPT3150-CHTIM          = LS_ZGTEDT2132-ZVALUE
*  LS_ZGTPPT3150-CHNAM          = LS_ZGTEDT2132-ZVALUE
    APPEND ls_zgtppt3150 TO lt_zgtppt3150.
    CLEAR :ls_zgtppt3150.
  ENDLOOP.

  DELETE FROM ZGTPPT3150 WHERE job_no = i_zkey1.

  MODIFY zgtppt3150 FROM TABLE lt_ZGTPPT3150.
  IF sy-subrc = 0.
    COMMIT WORK.
    lv_result1   = '0'.
*    zo_message  = TEXT-E02."'데이터 저장에 성공하였습니다.'.
  ELSE.
    ROLLBACK WORK.
    lv_result1   = '1'.
*    zo_message  = TEXT-E03."'데이터 저장 도중 오류가 발생하였습니다.'.
  ENDIF.

  CLEAR : lt_zgtedt2132[].
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_zgtedt2132
    FROM zgtedt2132
   WHERE  zsystem_id = 'KBDM'
     AND  zwerks = i_zwerks
     AND  ztable = 'ZGTPPT3160'
     AND  zkey1 =  i_zkey1.

  LOOP AT lt_zgtedt2132 INTO ls_zgtedt2132.
    ls_zgtppt3160-job_no           = ls_zgtedt2132-zkey1.
    ls_zgtppt3160-line_no          = ls_zgtedt2132-zkey2.
    ls_zgtppt3160-serial_info      = ls_zgtedt2132-zkey3.
    ls_zgtppt3160-prcss_seq        = ls_zgtedt2132-zkey4.
    ls_zgtppt3160-prcss_sub_seq    = ls_zgtedt2132-zkey5.
    ls_zgtppt3160-oper_code        = ls_zgtedt2132-zvalue01.
    ls_zgtppt3160-oper_name        = ls_zgtedt2132-zvalue02.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = ls_zgtedt2132-zvalue03
      IMPORTING
        output = ls_zgtedt2132-zvalue03.
    ls_zgtppt3160-oper_matnr       = ls_zgtedt2132-zvalue03.
    ls_zgtppt3160-menge            = ls_zgtedt2132-zvalue04.
    ls_zgtppt3160-meins            = ls_zgtedt2132-zvalue05.
    ls_zgtppt3160-beskz            = ls_zgtedt2132-zvalue06.
    ls_zgtppt3160-idnlf            = ls_zgtedt2132-zvalue07.
    ls_zgtppt3160-bstmg            = ls_zgtedt2132-zvalue08 .
    ls_zgtppt3160-bstme            = ls_zgtedt2132-zvalue09 .
    ls_zgtppt3160-netwr            = ls_zgtedt2132-zvalue10.
    ls_zgtppt3160-crdat          = sy-datum.
    ls_zgtppt3160-crtim          = sy-uzeit.
    ls_zgtppt3160-crnam          = sy-uname.
*  LS_ZGTPPT3150-CHDAT          = LS_ZGTEDT2132-ZVALUE
*  LS_ZGTPPT3150-CHTIM          = LS_ZGTEDT2132-ZVALUE
*  LS_ZGTPPT3150-CHNAM          = LS_ZGTEDT2132-ZVALUE
    APPEND ls_zgtppt3160 TO lt_zgtppt3160.
    CLEAR :ls_zgtppt3160.
  ENDLOOP.

  DELETE FROM ZGTPPT3160 WHERE job_no = i_zkey1.
  MODIFY zgtppt3160 FROM TABLE lt_ZGTPPT3160.
  IF sy-subrc = 0.
    COMMIT WORK.
    lv_result2   = '0'.
*    zo_message  = TEXT-E02."'데이터 저장에 성공하였습니다.'.
  ELSE.
    ROLLBACK WORK.
    lv_result2   = '1'.
*    zo_message  = TEXT-E03."'데이터 저장 도중 오류가 발생하였습니다.'.
  ENDIF.

  CLEAR : lt_zgtedt2132[].
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_zgtedt2132
    FROM zgtedt2132
   WHERE  zsystem_id = 'KBDM'
     AND  zwerks = i_zwerks
     AND  ztable = 'ZGTPPT3170'
     AND  zkey1 =  i_zkey1.

  LOOP AT lt_zgtedt2132 INTO ls_zgtedt2132.
    ls_zgtppt3170-job_no          = ls_zgtedt2132-zkey1.
    ls_zgtppt3170-line_no         = ls_zgtedt2132-zkey2.
    ls_zgtppt3170-serial_info     = ls_zgtedt2132-zkey3.
    ls_zgtppt3170-prcss_seq       = ls_zgtedt2132-zkey4.
    ls_zgtppt3170-prcss_sub_seq   = ls_zgtedt2132-zkey5.
    ls_zgtppt3170-mtrl_seq        = ls_zgtedt2132-zkey6.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = ls_zgtedt2132-zvalue01
      IMPORTING
        output = ls_zgtedt2132-zvalue01.
    ls_zgtppt3170-matnr           = ls_zgtedt2132-zvalue01.
    ls_zgtppt3170-menge           = ls_zgtedt2132-zvalue02.
    ls_zgtppt3170-kausf           = ls_zgtedt2132-zvalue03.
    ls_zgtppt3170-meins           = ls_zgtedt2132-zvalue04.

    ls_zgtppt3170-crdat          = sy-datum.
    ls_zgtppt3170-crtim          = sy-uzeit.
    ls_zgtppt3170-crnam          = sy-uname.
*  LS_ZGTPPT3150-CHDAT          = LS_ZGTEDT2132-ZVALUE
*  LS_ZGTPPT3150-CHTIM          = LS_ZGTEDT2132-ZVALUE
*  LS_ZGTPPT3150-CHNAM          = LS_ZGTEDT2132-ZVALUE
    APPEND ls_zgtppt3170 TO lt_zgtppt3170.
    CLEAR :ls_zgtppt3170.
  ENDLOOP.

  DELETE FROM ZGTPPT3170 WHERE job_no = i_zkey1.
  MODIFY zgtppt3170 FROM TABLE lt_ZGTPPT3170.
  IF sy-subrc = 0.
    COMMIT WORK.
    lv_result3   = '0'.
*    zo_message  = TEXT-E02."'데이터 저장에 성공하였습니다.'.
  ELSE.
    ROLLBACK WORK.
    lv_result3   = '1'.
*    zo_message  = TEXT-E03."'데이터 저장 도중 오류가 발생하였습니다.'.
  ENDIF.


  IF lv_result1   = '0'
     AND lv_result2   = '0'
     AND lv_result3   = '0'.
    zo_result   = '0'.
    zo_message  = TEXT-e02."'데이터 저장에 성공하였습니다.
  ELSE.
    zo_result   = '1'.
    zo_message  = TEXT-e03."'데이터 저장 도중 오류가 발생하였습니다.'.
  ENDIF.


ENDFUNCTION.
