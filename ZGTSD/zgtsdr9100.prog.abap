*&---------------------------------------------------------------------*
*& Report ZGTSDR9100
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*​
*& 모듈        : SD.
*& 프로그램 ID : ZGTSDR9100.
*& 프로그램 명 : [GT] Factor Batch 특성(SAP_MILLCA_LENGTH) 변경
*& 개요   : Batch Job 용 Program.
*& 생성일 : 2026.07.19.​
*& 생성자 : ZGODEV05.
*&---------------------------------------------------------------------*​
*& 외부 호출 프로그램 개요   :
*& 타 시스템 인터페이스 개요 : ​
*&---------------------------------------------------------------------*​
*& 프로그램 수정이력​
*&---------------------------------------------------------------------*​
*& 수정일  :​ 2026.07.19.
*& 수정자  :​ ZGODEV05.
*& 수정개요:
*&---------------------------------------------------------------------*

REPORT zgtsdr9100  MESSAGE-ID zgtsd01.

DEFINE: _clear.
  REFRESH: &1.    CLEAR: &1.
END-OF-DEFINITION.

DATA: lt_return  TYPE TABLE OF bapiret2,
      lv_class   TYPE klah-class,
      lt_valnum  TYPE TABLE OF bapi1003_alloc_values_num,
      ls_valnum  TYPE bapi1003_alloc_values_num,
      lt_valchar TYPE TABLE OF bapi1003_alloc_values_char,
      ls_valchar TYPE bapi1003_alloc_values_char,
      lt_valcurr TYPE TABLE OF bapi1003_alloc_values_curr,
      lv_status  TYPE bapi1003_key-status.

DATA: lv_tmstmp  TYPE timestampl,
      lt_log     TYPE TABLE OF zgtsdt1120,
      ls_log     TYPE zgtsdt1120,
      lv_err_flg TYPE abap_bool.

DATA: lv_msg        TYPE bapi_msg,
      lv_type       LIKE dd01v-datatype,
      lv_err_cnt(5) TYPE i,
      lv_suc_cnt(5) TYPE i,
      lv_tot_cnt(5) TYPE i.

***
START-OF-SELECTION.

* 변경대상 Data Get.
  SELECT a~matnr,
         a~werks,
         a~charg,
         a~atflv AS length,
         CAST( a~atflv AS CHAR( 15 ) ) AS length_c
    FROM zgtsd_cv_get_vcofbatch AS a  INNER JOIN marc AS b
                                      ON  a~matnr = b~matnr
                                      AND a~werks = b~werks
   WHERE b~dpcbt = 'A'
     AND a~atnam = 'SAP_MILLCA_LENGTH'
     AND a~clabs > 0
     AND a~charg <> CAST( a~atflv AS CHAR( 15 ) )
    INTO TABLE @DATA(lt_data).

  CLEAR: lv_msg.
  _clear: lt_log.
  IF lt_data[] IS NOT INITIAL.

    SORT: lt_data  BY matnr werks charg .

    CLEAR: lv_tot_cnt, lv_suc_cnt, lv_err_cnt.

    LOOP AT lt_data  ASSIGNING FIELD-SYMBOL(<lfs_data>).

**    Batch no에 Char 포함여부 확인.
      CLEAR: lv_type.
      DATA(lv_charg) = <lfs_data>-charg.
      REPLACE ALL OCCURRENCES OF ',' IN lv_charg WITH ''.
      REPLACE ALL OCCURRENCES OF '.' IN lv_charg WITH ''.
      CALL FUNCTION 'NUMERIC_CHECK'
        EXPORTING
          string_in = lv_charg
        IMPORTING
          htype     = lv_type.

      IF lv_type = 'CHAR'.
        CONTINUE.
      ELSE.

*       값이 다를경우 진행.
        DATA(lv_charg_c) = |{ CONV decfloat34( <lfs_data>-charg ) }|.
        IF lv_charg_c <> <lfs_data>-length.
          lv_tot_cnt = lv_tot_cnt + 1.
        ELSE.
          CONTINUE.
        ENDIF.

      ENDIF.

      CLEAR: lv_class.
      CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
        EXPORTING
          material           = <lfs_data>-matnr " G/I자재
          plant              = <lfs_data>-werks " 플랜트
          classtype          = '023'            " 클래스유형(배치)
        IMPORTING
          class              = lv_class
        EXCEPTIONS
          no_class_found     = 1
          no_classtype_found = 2
          OTHERS             = 3.

      CHECK lv_class IS NOT INITIAL.

      _clear: lt_valnum, lt_valchar, lt_valcurr.

      CLEAR: ls_valnum.
      ls_valnum-charact = 'SAP_MILLCA_LENGTH_SUB'.
      ls_valnum-value_from = '0'.
      APPEND ls_valnum TO lt_valnum.

      CLEAR: ls_valnum.
      ls_valnum-charact = 'SAP_MILLCA_LENGTH'.
      ls_valnum-value_from = <lfs_data>-charg.
      APPEND ls_valnum TO lt_valnum.

      " - 배치 특성 업데이트(펑션 호출)
      SELECT SINGLE cuobj_bm
        FROM mch1  WHERE matnr = @<lfs_data>-matnr
                     AND charg = @<lfs_data>-charg
        INTO @DATA(lv_objkey).

      _clear: lt_return.
      CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
        EXPORTING
          clobjectkey         = lv_objkey
          classnum            = lv_class
        IMPORTING
          classif_status      = lv_status
        TABLES
          allocvaluesnum_new  = lt_valnum
          allocvalueschar_new = lt_valchar
          allocvaluescurr_new = lt_valcurr
          return              = lt_return.

      CLEAR: lv_tmstmp.
      GET TIME STAMP FIELD lv_tmstmp.

*   변경 결과 처리
      CLEAR: lv_err_flg.
      IF line_exists( lt_return[ type = 'E' ] ).
        lv_err_flg = abap_true.
        DATA(ls_msg) = VALUE #( lt_return[ type = 'E' ] OPTIONAL ).
      ELSE.
        ls_msg = VALUE #( lt_return[ type = 'S' ] OPTIONAL ).
      ENDIF.

      IF lv_err_flg EQ abap_true.
        lv_err_cnt = lv_err_cnt + 1.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ENDIF.

*   로그 저장 정보 구성
      CLEAR ls_log.
      ls_log = VALUE #( tmstmp          = lv_tmstmp
                        matnr           = <lfs_data>-matnr
                        charg           = <lfs_data>-charg
                        werks           = <lfs_data>-werks
                        length_old_char = |{ CONV decfloat34( <lfs_data>-length ) }|
                        length_new_char = <lfs_data>-charg
                        length_old      = <lfs_data>-length
                        length_new      = <lfs_data>-charg
                        mtype           = ls_msg-type
                        msg             = ls_msg-message
                        erdat           = sy-datlo
                        ernam           = sy-uname
                        erzet           = sy-timlo ).
      APPEND ls_log TO lt_log.

    ENDLOOP.

  ELSE.
    lv_msg = 'Factor Batch 특성값을 변경할 Data가 없습니다.'.
    MESSAGE s000 WITH lv_msg.
  ENDIF.

* 처리 결과 저장
  IF lt_log[] IS NOT INITIAL.
    MODIFY zgtsdt1120 FROM TABLE lt_log.
    COMMIT WORK.

    lv_suc_cnt = lv_tot_cnt - lv_err_cnt.

    CLEAR: lv_msg.
    lv_msg = '처리되었습니다. ( T: ' && lv_tot_cnt && ', S: ' && lv_suc_cnt && ', E: ' && lv_err_cnt && ' ).'.
    MESSAGE s000 WITH lv_msg.

  ENDIF.
