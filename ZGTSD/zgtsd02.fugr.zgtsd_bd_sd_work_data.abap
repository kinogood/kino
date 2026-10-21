function zgtsd_bd_sd_work_data.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTETARGET
*"     VALUE(I_ZWERKS) TYPE  WERKS_D
*"     VALUE(I_ZTABLE) TYPE  CHAR20
*"     VALUE(I_ZKEY1) TYPE  CHAR40
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_BD_SD_WORK_DATA
*& 프로그램 명 : [GT] 제조지시 영업 데이터 저장
*& 개요   :
*& 생성일 : 2025.02.12
*& 생성자 : ZGSIDEV05
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2026.06.17
*& 수정자  : ZLSGSD6
*& 수정개요 : CHM2606-00436 아이템 테이블 Key값 로그 저장 오류 개선
*&---------------------------------------------------------------------*
*& 수정일  : 2026.07.03
*& 수정자  : ZLSGSD6
*& 수정개요 : CHM2606-00677 부스닥트 명세서명 수정 요청
*&---------------------------------------------------------------------*
  data : lt_0065    type table of zgtsdt0065 with header line,
         lt_0066    type table of zgtsdt0066 with header line,
         lt_0067    type table of zgtsdt0067 with header line,
         lt_t65     type table of zgtsdt0065 with empty key,
         lt_t66     type table of zgtsdt0066 with empty key,
         lt_t67     type table of zgtsdt0067 with empty key,

         lt_d_65    type table of zgtsdt0065 with empty key,
         lt_d_66    type table of zgtsdt0066 with empty key,
         lt_d_67    type table of zgtsdt0067 with empty key,

         lv_chr_key type zgtsdt0065-chr_key,
         ls_2132    type zgtedt2132,
         lt_2132    type table of zgtedt2132 with non-unique sorted key k_key components ztable.
  data : ls_9999 like zsdt9999.

  "알수없는 오류가 있어 로그를 찍어봄
  ls_9999-zpgm = 'ZGTSD_BD_SD_WORK_DATA'.
  ls_9999-key1 = i_zkey1.
  ls_9999-key2 = i_ztable.
  ls_9999-erdat = sy-datum. ls_9999-erzet = sy-uzeit.

**********************************************************************
*ZGTSDT0077 TABLE MAPPING
**********************************************************************
  if i_ztable = |ZGTSDT0077|.
    perform bd_sd_work_0077_data using i_zwerks
                                       i_system_id
                                       i_ztable
                                       i_zkey1
                              changing zo_result
                                       zo_message.
    ls_9999-data01 = zo_result.    ls_9999-data02 = zo_message.    ls_9999-data03 = 12.
    exit.
  endif.

**********************************************************************
*ZGTSDT0065 TABLE MAPPING
**********************************************************************
  select zgtedt2132~* into corresponding fields of table @lt_2132
    from zgtedt2132
   where zsystem_id = @i_system_id
     and ztable  in ('ZGTSDT0065', 'ZGTSDT0066', 'ZGTSDT0067')
     and zwerks  = @i_zwerks
     and zkey1   = @i_zkey1.
  if sy-subrc ne 0.
    zo_result = |01|.
    zo_message = text-e01.
    ls_9999-data01 = zo_result.    ls_9999-data02 = zo_message.    ls_9999-data03 = 11.
    modify zsdt9999 from ls_9999.
    exit.
  endif.

  select zgtppt1010~* into table @data(lt_code)
    from zgtppt1010
   where module_kind eq 'SD'
     and codegrp = '0061'
   order by fld_01 ascending.

  select single zjob_name into @data(lv_jobname)
    from zgtedt2121
   where zwerks  = @i_zwerks
     and zjob_no = @i_zkey1.

  sort lt_2132 by ztable zvalue26.
  loop at lt_2132 into ls_2132 using key k_key where ztable = 'ZGTSDT0065'.
    lt_0065-zsystem_id     =  ls_2132-zsystem_id.
    lt_0065-mreqno         =  ls_2132-zkey2.
    lt_0065-zpjno          =  ls_2132-zkey3.
    lt_0065-job_no         =  ls_2132-zkey1.
    lt_0065-item_key       =  ls_2132-zkey4.
    lt_0065-zdelv_date     =  ls_2132-zvalue01.
    lt_0065-matnr          =  ls_2132-zvalue02.
    lt_0065-werks          =  ls_2132-zvalue03.
    lt_0065-kwmeng         =  ls_2132-zvalue04.
*    lt_0065-meins          =  ls_2132-zvalue05.
    lt_0065-ord_len        =  ls_2132-zvalue06.
    lt_0065-ord_wgt        =  ls_2132-zvalue07.
    lt_0065-voltage_cd     =  ls_2132-zvalue08.
    lt_0065-prod_type      =  ls_2132-zvalue09.
    lt_0065-wire_cnt       =  ls_2132-zvalue10.
    lt_0065-amphere        =  ls_2132-zvalue11.
    lt_0065-cond_mtrl      =  ls_2132-zvalue12.
    lt_0065-duct_mtrl_est  =  ls_2132-zvalue13.
    lt_0065-ground_type    =  ls_2132-zvalue14.
    lt_0065-ipgrade        =  ls_2132-zvalue15.
    lt_0065-condtw         =  ls_2132-zvalue16.
    lt_0065-grspec         =  ls_2132-zvalue17.
    lt_0065-stdname        =  ls_2132-zvalue18.
    lt_0065-serialno       =  ls_2132-zvalue19.
    lt_0065-ecoptype       =  ls_2132-zvalue20.
    lt_0065-n_wire_type    =  ls_2132-zvalue21.
    lt_0065-brkmd          =  ls_2132-zvalue22.
    lt_0065-framph         =  ls_2132-zvalue23.
    lt_0065-opmthd         =  ls_2132-zvalue24.
    lt_0065-phtap          =  ls_2132-zvalue25.
    lt_0065-posnr          =  ls_2132-zvalue26.
    lt_0065-ojob_no        =  ls_2132-zvalue27.

    __alpha_in lt_0065-posnr lt_0065-posnr.
    call function 'CONVERSION_EXIT_MATN1_INPUT'
      exporting
        input        = lt_0065-matnr
      importing
        output       = lt_0065-matnr
      exceptions
        length_error = 1
        others       = 2.

    select single a~meins
      from mara as a
     where a~matnr eq @lt_0065-matnr

      into @lt_0065-meins.

    lt_0065-job_name       =  lv_jobname.
    select single maktx into lt_0065-maktx
      from makt where matnr = lt_0065-matnr
       and spras = sy-langu.

    loop at lt_code into data(ls_code).
      assign component ls_code-fld_04 of structure lt_0065 to field-symbol(<lv_val>).
      if sy-subrc = 0.
        concatenate lt_0065-chr_key <lv_val> into lt_0065-chr_key.
      endif.
    endloop.
    if lv_chr_key is initial.
      lv_chr_key = lt_0065-chr_key.
    endif.
    lt_0065-erdat          =  sy-datum.
    lt_0065-erzeit         =  sy-uzeit.
    lt_0065-ernam          =  sy-uname.
    lt_0065-erdatlo        =  sy-datlo.
    lt_0065-ertimlo        =  sy-timlo.
    append lt_0065. clear lt_0065.
  endloop.

  lt_t65[] = corresponding #( lt_0065[] ).
  if lt_t65[] is not initial.
    select b~*
      from @lt_t65 as a inner join zgtsdt0065 as b
        on a~mreqno    = b~mreqno
       and a~zpjno     = b~zpjno
       and a~job_no    = b~job_no
       and a~posnr     = b~posnr
*       AND A~ITEM_KEY  = B~ITEM_KEY
     where b~zsystem_id = @i_system_id
      into table @data(lt_d65).
  endif.
  loop at lt_0065.

*-- 기존 정보 기준 판매오더 있는 경우 기존값 유지
    select single @abap_true
      from @lt_d65 as a
     where a~mreqno eq @lt_0065-mreqno
       and a~zpjno  eq @lt_0065-zpjno
       and a~job_no eq @lt_0065-job_no
       and a~posnr  eq @lt_0065-posnr
       and a~vbeln  is not initial

     into @data(lv_flag).
*    IF sy-subrc EQ 0.
*      DELETE lt_0065. CONTINUE.
*    ENDIF.
    if lv_flag is not initial.
      exit.
    endif.

*    READ TABLE lt_d65 TRANSPORTING NO FIELDS WITH KEY mreqno   = lt_0065-mreqno
*                                                      zpjno    = lt_0065-zpjno
*                                                      job_no   = lt_0065-job_no
*                                                      item_key = lt_0065-item_key.
*    IF sy-subrc = 0.
*      DELETE lt_0065. CONTINUE.
*    ENDIF.
  endloop.

*I/F 키값으로   zgtsdt0065 조회한 데이터중 VBELN이 하나라도 있으면 펑션 종료
  if lv_flag is not initial.
    zo_result = |01|.
    zo_message = text-e04.
    ls_9999-data01 = zo_result.
    ls_9999-data02 = zo_message.
    ls_9999-data03 = 1.
    modify zsdt9999 from ls_9999.
    exit.
  endif.

*-- 기존 정보 기준 판매오더 없는 경우 해당 이전 정보 삭제 정보 구성
  with +del_key as ( select a~zsystem_id, a~job_no
                       from @lt_t65 as a
                      group by a~zsystem_id, a~job_no )

    select a~zsystem_id,  a~mreqno,  a~zpjno,  a~job_no,  a~posnr
      from zgtsdt0065 as a inner join +del_key as b
                              on a~zsystem_id eq b~zsystem_id
                             and a~job_no     eq b~job_no
     where a~vbeln is initial

    into corresponding fields of table @lt_d_65.

*-- 공통코드 기준 단위 Mapping 정보 Select
  select a~fld_01 as qcode,
         a~fld_04 as qunit

    from zgtppt1010 as a
   where a~module_kind eq 'SD'
     and a~codegrp     eq '0065'

  order by a~fld_01

   into table @data(lt_mapp_unit).

**********************************************************************
*ZGTSDT0066 TABLE MAPPING
**********************************************************************
  constants : lc_wire_cnt type atnam  value 'PD_NBD_CM_PC',
              lc_ipgrade  type atnam  value 'PD_NBD_CM_IP_GRD'.

*-- 판매오더 제조지시 정보 기준 완제품 QNAME_PRNT 정보 Select
  with +list_info as ( select a~zsystem_id, a~job_no, a~posnr,
                              a~wire_cnt,   a~ipgrade
                         from @lt_t65 as a inner join mara as b
                                              on a~matnr eq b~matnr
                        where b~mtart eq 'FERT' ),

       +cawn_info as ( select distinct
                              @lc_wire_cnt as atnam,
                              a~wire_cnt   as atwrt
                         from +list_info as a
                        where a~wire_cnt is not initial

                       union distinct

                       select distinct
                              @lc_ipgrade  as atnam,
                              a~ipgrade    as atwrt
                         from +list_info as a
                        where a~ipgrade is not initial ),

       +desc_info as ( select a~atnam, a~atwrt, c~atwtb
                         from +cawn_info as a inner join cabn as t
                                                 on a~atnam eq t~atnam

                                              inner join cawn as b
                                                 on t~atinn eq b~atinn
                                                and a~atwrt eq b~atwrt

                                              inner join cawnt as c
                                                 on b~atinn eq c~atinn
                                                and b~atzhl eq c~atzhl
                                                and c~spras eq @sy-langu )

    select a~zsystem_id,  a~job_no,  a~posnr,  a~wire_cnt,  a~ipgrade,

           case when b~atwtb is not null then b~atwtb
                else @abap_false
           end as wire_cnt_t,

           case when c~atwtb is not null then c~atwtb
                else @abap_false
           end as ipgrade_t

      from +list_info as a left outer join +desc_info as b
                                   on a~wire_cnt eq b~atwrt
                                  and b~atnam    eq @lc_wire_cnt

                           left outer join +desc_info as c
                                   on a~ipgrade  eq c~atwrt
                                  and c~atnam    eq @lc_ipgrade
     order by a~zsystem_id, a~job_no, a~posnr

      into table @data(lt_qname_prnt).


  sort lt_2132 by ztable zvalue05.
  loop at lt_2132 into ls_2132 using key k_key where ztable = 'ZGTSDT0066'.

    lt_0066-zsystem_id  = ls_2132-zsystem_id.
    lt_0066-job_no      = ls_2132-zkey1.
    lt_0066-item_key    = ls_2132-zkey2.
    lt_0066-qcode       = ls_2132-zkey3.
    lt_0066-qname       = ls_2132-zvalue01.

*-- QNAME_PRNT 값 구성 변경 - 2025.06.11
*-> 주석시작
    lt_0066-qname_prnt  = ls_2132-zvalue02.
*-> 주석 끝
    lt_0066-qqty        = ls_2132-zvalue03.


*-- 공통코드 견적품 코드 기준 단위 구성
    read table lt_mapp_unit with key qcode = ls_2132-zkey3
                            into data(ls_mapp_unit).
    if sy-subrc eq 0.
      lt_0066-qunit     = ls_mapp_unit-qunit.
    else.
      lt_0066-qunit     = ls_2132-zvalue04.
    endif.

    __alpha_in ls_2132-zvalue05 lt_0066-posnr.
*    LT_0066-POSNR       = LS_2132-ZVALUE05.

*-시작
*START 2026.06.26 수정 CHM2606-00677 부스닥트 명세서명 수정 요청
*    read table lt_qname_prnt with key zsystem_id = lt_0066-zsystem_id
*                                      job_no     = lt_0066-job_no
*                                      posnr      = lt_0066-posnr
*                             into data(ls_qname_prnt).
*    if sy-subrc eq 0.
*      concatenate ls_2132-zvalue02
*                  ls_qname_prnt-wire_cnt_t ls_qname_prnt-ipgrade_t
*                  into lt_0066-qname_prnt
*                  separated by space.
*      lt_0066-qname_prnt  = ls_2132-zvalue02.
*    endif.
*END CHM2606-00677 부스닥트 명세서명 수정 요청 2026.06.26 수정

*    READ TABLE lt_0065 WITH KEY zsystem_id = lt_0066-zsystem_id
*                                job_no     = lt_0066-job_no
*                                posnr      = lt_0066-posnr
*                       INTO DATA(ls_0065).
*    IF sy-subrc EQ 0.
*      CONCATENATE ls_0065-wire_cnt ls_0065-ipgrade ls_2132-zvalue02
*                  INTO lt_0066-qname_prnt
*                  SEPARATED BY space.
*    ENDIF.
*-> 끝

*START 2026.06.17 수정 CHM2606-00436
    read table lt_0065 with key zsystem_id = lt_0066-zsystem_id
                                job_no     = lt_0066-job_no
                                posnr      = lt_0066-posnr
                       into data(ls_0065).
    if sy-subrc = 0 and ls_0065-chr_key is not initial.
      lt_0066-chr_key   = ls_0065-chr_key.
    else.
      lt_0066-chr_key   = lv_chr_key.
    endif.
*END 2026.06.17 수정 CHM2606-00436
    lt_0066-erdat       = sy-datum.
    lt_0066-erzeit      = sy-uzeit.
    lt_0066-ernam       = sy-uname.
    lt_0066-erdatlo     = sy-datlo.
    lt_0066-ertimlo     = sy-timlo.
    append lt_0066. clear lt_0066.

  endloop.

  lt_t66[] = corresponding #( lt_0066[] ).
  if lt_t66[] is not initial.
    select b~*
      from @lt_t66 as a inner join zgtsdt0066 as b
        on a~job_no    = b~job_no
*       AND A~ITEM_KEY  = B~ITEM_KEY
       and a~posnr     = b~posnr
       and a~qcode     = b~qcode
     where b~zsystem_id = @i_system_id
      into table @data(lt_d66).
  endif.
  loop at lt_0066.
*-- 기존 정보 기준 판매오더 있는 경우 기존값 유지
    select single @abap_true
      from @lt_d66 as a
     where a~job_no   eq @lt_0066-job_no
*       AND A~ITEM_KEY EQ @LT_0066-ITEM_KEY
        and a~posnr   eq @lt_0066-posnr
       and a~qcode    eq @lt_0066-qcode
       and a~vbeln    is not initial
      into @lv_flag.
*    READ TABLE lt_d66 TRANSPORTING NO FIELDS WITH KEY job_no   = lt_0066-job_no
*                                                      item_key = lt_0066-item_key
*                                                      qcode    = lt_0066-qcode.
*    IF SY-SUBRC = 0.
*      DELETE LT_0066. CONTINUE.
*    ENDIF.
    if lv_flag is not initial.
      exit.
    endif.
  endloop.

*I/F 키값으로   zgtsdt0065 조회한 데이터중 VBELN이 하나라도 있으면 펑션 종료
  if lv_flag is not initial.
    zo_result = |01|.
    zo_message = text-e04.
    ls_9999-data01 = zo_result.
    ls_9999-data02 = zo_message.
    ls_9999-data03 = 2.
    modify zsdt9999 from ls_9999.
    exit.
  endif.

*-- 기존 정보 기준 판매오더 없는 경우 해당 이전 정보 삭제 정보 구성
  with +del_key as ( select a~zsystem_id, a~job_no
                       from @lt_t66 as a
                      group by a~zsystem_id, a~job_no )

  select a~zsystem_id,  a~job_no,  a~posnr,  a~qcode
    from zgtsdt0066 as a inner join +del_key as b
                            on a~zsystem_id eq b~zsystem_id
                           and a~job_no     eq b~job_no
   where a~vbeln is initial

    into corresponding fields of table @lt_d_66.
**********************************************************************
*ZGTSDT0067 TABLE MAPPING
**********************************************************************
  sort lt_2132 by ztable zvalue04.
  loop at lt_2132 into ls_2132 using key k_key where ztable = 'ZGTSDT0067'.
    lt_0067-zsystem_id  = ls_2132-zsystem_id.
    lt_0067-job_no      = ls_2132-zkey1.
    lt_0067-line_no     = ls_2132-zkey2.
    lt_0067-serial_info = ls_2132-zkey3.
    lt_0067-qcode       = ls_2132-zkey4.
    lt_0067-item_key    = ls_2132-zvalue01.
    lt_0067-qqty        = ls_2132-zvalue02.
    lt_0067-qunit       = ls_2132-zvalue03.
*    LT_0067-POSNR       = LS_2132-ZVALUE04.
    __alpha_in ls_2132-zvalue04 lt_0067-posnr.

    lt_0067-erdat       = sy-datum.
    lt_0067-erzeit      = sy-uzeit.
    lt_0067-ernam       = sy-uname.
    lt_0067-erdatlo     = sy-datlo.
    lt_0067-ertimlo     = sy-timlo.
    append lt_0067. clear lt_0067.
  endloop.

  lt_t67[] = corresponding #( lt_0067[] ).
  if lt_t67[] is not initial.
    select b~*
      from @lt_t67 as a inner join zgtsdt0067 as b
        on a~job_no    = b~job_no
       and a~line_no   = b~line_no
       and a~serial_info = b~serial_info
       and a~qcode     = b~qcode
     where b~zsystem_id = @i_system_id
      into table @data(lt_d67).
  endif.
  loop at lt_0067.
*-- 기존 정보 기준 판매오더 있는 경우 기존값 유지
    select single @abap_true
      from @lt_d67 as a
     where a~job_no      eq @lt_0067-job_no
       and a~line_no     eq @lt_0067-line_no
       and a~serial_info eq @lt_0067-serial_info
       and a~qcode       eq @lt_0067-qcode
       and a~vbeln       is not initial
      into @lv_flag.
*    READ TABLE lt_d67 TRANSPORTING NO FIELDS WITH KEY job_no      = lt_0067-job_no
*                                                      line_no     = lt_0067-line_no
*                                                      serial_info = lt_0067-serial_info
*                                                      qcode       = lt_0067-qcode.
*    IF SY-SUBRC = 0.
*      DELETE LT_0067. CONTINUE.
*    ENDIF.
    if lv_flag is not initial.
      exit.
    endif.
  endloop.

*I/F 키값으로   zgtsdt0065 조회한 데이터중 VBELN이 하나라도 있으면 펑션 종료
  if lv_flag is not initial.
    zo_result = |01|.
    zo_message = text-e04.
    ls_9999-data01 = zo_result.
    ls_9999-data02 = zo_message.
    ls_9999-data03 = 3.
    modify zsdt9999 from ls_9999.
    exit.
  endif.

*-- 기존 정보 기준 판매오더 없는 경우 해당 이전 정보 삭제 정보 구성
  with +del_key as ( select a~zsystem_id, a~job_no
                       from @lt_t67 as a
                      group by a~zsystem_id, a~job_no )

    select a~zsystem_id,  a~job_no,  a~line_no,  a~serial_info,  a~qcode
      from zgtsdt0067 as a inner join +del_key as b
                              on a~zsystem_id eq b~zsystem_id
                             and a~job_no     eq b~job_no
     where a~vbeln is initial

      into corresponding fields of table @lt_d_67.

  if lt_0065[] is initial and lt_0066[] is initial and lt_0067[] is initial.
    zo_result = |01|.
    zo_message = text-e01.
    ls_9999-data01 = zo_result.
    ls_9999-data02 = zo_message.
    ls_9999-data03 = 4.
    modify zsdt9999 from ls_9999.
    exit.
  endif.

*-----------------------------------------------------------------------
*-- 저장정보 기준 길이 / 수량 일치 여부 확인
*-----------------------------------------------------------------------
  perform chk_save_data_len_qty     tables   lt_0065
                                             lt_0066
                                             lt_0067
                                    changing zo_result
                                             zo_message.

*-- 오류 발생인 경우 오류 정보 Table : ZGTSDT0065 에 추가 저장 수행
  if zo_result eq |01|.
    clear lt_0065.
    lt_0065-zstat = 'E'.
    lt_0065-zmsg  = zo_message.
    ls_9999-data10 = zo_message.

    modify lt_0065 from lt_0065
                   transporting zstat zmsg
                   where zstat ne 'E'.
  endif.
*  IF zo_result EQ |01|.
**    오류 발생인 경우 Exit
*    EXIT.
*  ENDIF.

*-- 삭제 정보 있을경우 삭제 선수행
  if lt_d_65[] is not initial.
    try.
        delete zgtsdt0065 from table @lt_d_65.
      catch cx_sy_open_sql_db into data(lo_sql_db).
        rollback work. zo_result = |10|.
        zo_message = text-e02.
        ls_9999-data01 = zo_result.    ls_9999-data02 = zo_message.    ls_9999-data03 = 6.
        modify zsdt9999 from ls_9999.
        exit.
    endtry.
  endif.

  if lt_d_66[] is not initial.
    try.
        delete zgtsdt0066 from table @lt_d_66.
      catch cx_sy_open_sql_db into lo_sql_db.
        rollback work. zo_result = |11|.
        zo_message = text-e02.
        ls_9999-data01 = zo_result.    ls_9999-data02 = zo_message.    ls_9999-data03 = 7.
        modify zsdt9999 from ls_9999.
        exit.
    endtry.
  endif.

  if lt_d_67[] is not initial.
    try.
        delete zgtsdt0067 from table @lt_d_67.
      catch cx_sy_open_sql_db into lo_sql_db.
        rollback work. zo_result = |12|.
        zo_message = text-e02.
        ls_9999-data01 = zo_result.    ls_9999-data02 = zo_message.    ls_9999-data03 = 8.
        modify zsdt9999 from ls_9999.
        exit.
    endtry.
  endif.

*-- 저장 수행
  if lt_0065[] is not initial.
    modify zgtsdt0065 from table lt_0065.
    if sy-subrc ne 0.
      rollback work. zo_result = |13|.
      zo_message = text-e02.
      ls_9999-data01 = zo_result.    ls_9999-data02 = zo_message.    ls_9999-data03 = 9.
      modify zsdt9999 from ls_9999.
      exit.
    endif.
  endif.

  if lt_0066[] is not initial.
    modify zgtsdt0066 from table lt_0066.
    if sy-subrc ne 0.
      rollback work. zo_result = |14|.
      zo_message = text-e02.
      ls_9999-data01 = zo_result.    ls_9999-data02 = zo_message.    ls_9999-data03 = 10.
      modify zsdt9999 from ls_9999.
      exit.
    endif.
  endif.

  if lt_0067[] is not initial.
    modify zgtsdt0067 from table lt_0067.
    if sy-subrc ne 0.
      rollback work. zo_result = |15|.
      zo_message = text-e02.
      ls_9999-data01 = zo_result.    ls_9999-data02 = zo_message.    ls_9999-data03 = 6.
      modify zsdt9999 from ls_9999.
      exit.
    endif.
  endif.

  commit work.

  if zo_result is not initial.
*    오류 정보 있는경우 Exit

    ls_9999-data01 = zo_result.
    ls_9999-data02 = zo_message.
    ls_9999-data03 = 5.
    modify zsdt9999 from ls_9999.
    exit.
  endif.

  zo_result = |00|.
  zo_message = text-s01.

*-----------------------------------------------------------------------
*-- 저장 성공인 경우 시작업 생상요청 수행
*-----------------------------------------------------------------------
  data : lv_cnt type i.
*-- ZGTSDT0065 저장 정보 기준 프로젝트 번호 기준 Submit Call 수행
  lt_t65[] = corresponding #( lt_0065[] ).

  with +key_info as ( select a~zpjno
                        from @lt_t65 as a
                       group by a~zpjno )

    select a~zpjno,  c~vkorg
     from zsd0106t as a inner join +key_info as b
                           on a~zpjno eq b~zpjno

                        inner join tvkbz as c
                           on a~zvkbur eq c~vkbur
    where a~zgubun eq 'S'
    group by a~zpjno, c~vkorg

     into table @data(lt_quot).

  clear lv_cnt.

  loop at lt_quot into data(ls_quot).
    add 1 to lv_cnt.
*-- 프로젝트 번호 & 영업조직 기준 생산요청 수행
    perform crte_job_for_quotation  using    ls_quot-zpjno
                                             ls_quot-vkorg
                                             lv_cnt.

  endloop.


  ls_9999-data01 = zo_result.
  ls_9999-data02 = zo_message.
  modify zsdt9999 from ls_9999.

endfunction.
