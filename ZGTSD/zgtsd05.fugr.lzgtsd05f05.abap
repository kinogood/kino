*----------------------------------------------------------------------*
***INCLUDE LZGTSD05F05.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form shipment_chg_if_log_info_go
*&---------------------------------------------------------------------*
FORM shipment_chg_if_log_info_go  TABLES   pt_data      STRUCTURE zgtsdsif2140
                                           pt_result    STRUCTURE zgtsdsif2141
                                  USING    pi_new
                                           ps_info      TYPE zgtsdt9000
                                           pi_system_id
                                           pi_fname
                                  CHANGING pe_result    TYPE zo_result
                                           pe_message   TYPE zo_message.

  DATA: lv_seq  TYPE zgte_seq,
        ls_9000 TYPE zgtsdt9000,
        lt_9020 TYPE TABLE OF zgtsdt9020.

**
* Make IF Log
  IF pi_new = 'X'.

    GET TIME STAMP FIELD ps_info-zifkey.          " I/F Key 정보 구성

    ps_info = VALUE #( BASE ps_info
                       zifrfc     = pi_fname      " RFC Name.
                       zsystem_id = pi_system_id  " System Id.
                      ).

    IF pt_data[] IS INITIAL.

      pe_result  = 'E'.
*     Import 값이 존재하지 않습니다.
      pe_message = TEXT-e21.

    ELSE.
      SELECT SINGLE @abap_true
        FROM zgtppt1010  WHERE module_kind EQ 'PP'
                           AND codegrp     EQ '0010'
                           AND fld_01      EQ @pi_system_id
        INTO @DATA(lv_flg).

      IF lv_flg IS INITIAL.
        pe_result  = 'E'.
*       유효하지 않은 SYSTEM ID 입니다.
        pe_message = TEXT-e34.

      ENDIF.

    ENDIF.

  ENDIF.

  CLEAR: ls_9000.
  _clear: lt_9020.
* Save IF Log.
  IF pe_result IS NOT INITIAL.

    ls_9000 = VALUE #( BASE CORRESPONDING #( ps_info )
                     ifdat        = sy-datlo      " 수신일자
                     iftim        = sy-timlo      " 수신시간
                     ifnam        = sy-uname      " 수신 User
                     ernam        = sy-uname      " 생성 ID
                     erdat        = sy-datum      " 생성일
                     erzeit       = sy-uzeit      " 생성시간
                     erdatlo      = sy-datlo      " 생성일 Local
                     ertimlo      = sy-timlo      " 생성시간 Local
                     zstat        = pe_result
                     zmessage     = pe_message
                     zerp_stat    = pe_result
                     zerp_message = pe_message
                    ).

    CLEAR: lv_seq.
    LOOP AT pt_data  INTO DATA(ls_data).

      lv_seq = lv_seq + 1.

      DATA(ls_result) = VALUE #( pt_result[ tknum = ls_data-tknum ]
                                 OPTIONAL ).

      APPEND VALUE #( BASE CORRESPONDING #( ls_data )
                      zifkey       = ps_info-zifkey
                      zifrfc       = ps_info-zifrfc
                      zsystem_id   = ps_info-zsystem_id
                      zseq         = lv_seq
                      zerp_stat    = ls_result-zerp_stat
                      zerp_message = ls_result-zerp_message
                     ) TO lt_9020.
    ENDLOOP.

    TRY.
        MODIFY zgtsdt9000 FROM ls_9000.

      CATCH cx_sy_open_sql_db INTO DATA(lo_sql).
        DATA(lv_msg) = lo_sql->get_text( ).
        DATA(lv_err) = 'X'.
        ROLLBACK WORK.
    ENDTRY.

    IF lv_err IS INITIAL.
      TRY.
          MODIFY zgtsdt9020 FROM TABLE lt_9020.

        CATCH cx_sy_open_sql_db INTO lo_sql.
          lv_msg = lo_sql->get_text( ).
          lv_err = 'X'.
          ROLLBACK WORK.
      ENDTRY.
    ENDIF.

    IF lv_err IS NOT INITIAL.
      pe_result  = 'E'.
      pe_message = lv_msg.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form shipment_data_change_go
*&---------------------------------------------------------------------*
FORM shipment_data_change_go  TABLES   pt_data      STRUCTURE zgtsdsif2140
                                       pt_result    STRUCTURE zgtsdsif2141
                              CHANGING pe_result    TYPE zo_result
                                       pe_message   TYPE zo_message.

  DATA: lv_tknum   TYPE tknum,
        lv_result  TYPE zo_result,
        lv_message TYPE zo_message.

**
  CHECK: pe_result IS INITIAL.
  SORT: pt_data BY bukrs tknum.

  LOOP AT pt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
    <lfs_data>-tknum = |{ <lfs_data>-tknum ALPHA = IN }|.
  ENDLOOP.

  LOOP AT pt_data  INTO DATA(ls_data).

    CLEAR: lv_result, lv_message, lv_tknum.

    SELECT SINGLE @abap_true  INTO @DATA(lv_chk)
      FROM vttk  WHERE tknum EQ @ls_data-tknum.

    IF lv_chk IS NOT INITIAL.

*     회사코드에 해당하는 선적문서 및 선적문서 존재여부 확인
      SELECT SINGLE tplst  FROM vttk
                          WHERE tknum EQ @ls_data-tknum
        INTO @DATA(lv_tplst).

      CLEAR: lv_chk.
      IF lv_tplst IS NOT INITIAL.
        SELECT SINGLE @abap_true  FROM ttds
                                 WHERE bukrs EQ @ls_data-bukrs
                                   AND tplst EQ @lv_tplst
          INTO @lv_chk.
      ENDIF.

      IF lv_chk IS NOT INITIAL.

        PERFORM bapi_shipment_change_go   USING    ls_data
                                          CHANGING lv_result
                                                   lv_message.
      ELSE.
        lv_result  = 'E'.
*       유효하지 않은 선적문서입니다.
        lv_message = TEXT-e35.
      ENDIF.

    ELSE.
      lv_result  = 'E'.
*     존재하지 않는 선적문서입니다.
      lv_message = TEXT-e22.
    ENDIF.

    IF lv_result IS NOT INITIAL.
      APPEND VALUE #( tknum        = ls_data-tknum
                      zerp_stat    = lv_result
                      zerp_message = lv_message
                     ) TO pt_result.
    ENDIF.

  ENDLOOP.

* Result Set.
  CLEAR: lv_result.
  lv_result = VALUE #( pt_result[ zerp_stat = 'E' ]-zerp_stat
                       OPTIONAL ).
  IF lv_result = 'E'.

    CLEAR: lv_result.
    lv_result = VALUE #( pt_result[ zerp_stat = 'S' ]-zerp_stat
                         OPTIONAL ).

    IF lv_result IS INITIAL.
      pe_result  = 'E'.
      pe_message = TEXT-e23.    " 변경 실패
    ELSE.
      pe_result  = 'W'.
      pe_message = TEXT-s02.    " 변경 성공(오류 포함)
    ENDIF.

  ELSE.
    pe_result  = 'S'.
    pe_message = TEXT-s01.    " 변경 성공
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form bapi_shipment_change_go
*&---------------------------------------------------------------------*
FORM bapi_shipment_change_go  USING    ps_data     TYPE zgtsdsif2140
                              CHANGING pe_result   TYPE zo_result
                                       pe_message  TYPE zo_message.

  DATA: ls_head   LIKE bapishipmentheader,
        ls_headx  LIKE bapishipmentheaderaction,

        lt_return TYPE TABLE OF bapiret2.

**
  CHECK: pe_result IS INITIAL,
         ps_data   IS NOT INITIAL.


  " 1) Object Lock 상태 체크 및 획득 시도
  CALL FUNCTION 'ENQUEUE_EVVTTKE'
    EXPORTING
      mode_vttk      = 'E'
      tknum          = ps_data-tknum
      _scope         = '2'
      _wait          = abap_true
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  IF sy-subrc <> 0.
    pe_result  = 'E'.
    pe_message = TEXT-e24.
    RETURN.
  ENDIF.

  CLEAR: ls_head, ls_headx.
  ls_head  = VALUE #( shipment_num  = ps_data-tknum
                      external_id_1 = ps_data-carplate
                      external_id_2 = ps_data-driver
                      description   = ps_data-telno
*                      SHIPPING_TYPE = ps_data-VSART
                      ).

  IF ps_data-carplate IS INITIAL.
    ls_headx-external_id_1 = 'D'.
  ELSE.
    ls_headx-external_id_1 = 'C'.
  ENDIF.
  IF ps_data-driver   IS INITIAL.
    ls_headx-external_id_2 = 'D'.
  ELSE.
    ls_headx-external_id_2 = 'C'.
  ENDIF.
  IF ps_data-telno    IS INITIAL.
    ls_headx-description   = 'D'.
  ELSE.
    ls_headx-description   = 'C'.
  ENDIF.
*  IF ps_data-VSART    IS INITIAL.
*    ls_headx-description   = 'D'.
*  ELSE.
*    ls_headx-description   = 'C'.
*  ENDIF.

*
*  ls_headx = VALUE #( external_id_1 = 'C'
*                      external_id_2 = 'C'
*                      description   = 'C' ).

  _clear: lt_return.
  CALL FUNCTION 'BAPI_SHIPMENT_CHANGE'
    EXPORTING
      headerdata       = ls_head
      headerdataaction = ls_headx
    TABLES
      return           = lt_return.

  DATA(ls_return) = VALUE #( lt_return[ type = 'E' ]  OPTIONAL ).

  IF ls_return IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    pe_result  = 'S'.
    pe_message = TEXT-s01.    " 변경 성공

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    pe_result  = 'E'.
    pe_message = TEXT-e23.    " 변경 실패

  ENDIF.

**
  FREE: lt_return.

ENDFORM.
