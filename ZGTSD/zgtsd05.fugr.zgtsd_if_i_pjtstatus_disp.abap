function zgtsd_if_i_pjtstatus_disp.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_D365_LOGIN) TYPE  ZSDS_LOG_0000 OPTIONAL
*"     VALUE(IS_SEARCH) TYPE  ZGTSDSIF0022 OPTIONAL
*"  EXPORTING
*"     VALUE(ES_RETURN) TYPE  ZSDS_LOG_0001
*"  TABLES
*"      IT_KUNNR STRUCTURE  WKUNNR OPTIONAL
*"      ET_DATA STRUCTURE  ZGTSDSIF0015 OPTIONAL
*"----------------------------------------------------------------------

  include zsdc0000.

  define _alpha_input.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = &1
      IMPORTING
        OUTPUT = &1.
  end-of-definition.
  define _alpha_output.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = &1
      IMPORTING
        OUTPUT = &1.
  end-of-definition.

  data : lv_msg   type char200,
         lv_zpjno type zpjno,
         lv_amt   type bapicurr-bapicurr.

  constants : lc_color  type cabn-atnam value 'PD_CA_COLOR_BASE', "색상
              lc_length type cabn-atnam value 'SAP_LENGTH_VKRME', "조장
              lc_factor type cabn-atnam value 'SAP_MILLCA_FACTOR', "조장수
              lc_spec   type cabn-atnam value 'PD_CA_SPEC_NO',    "Spec.no
              lc_grade  type cabn-atnam value 'ZBT_AA_GRADE'.    "Spec.no

  ranges :    lr_erdat  for  vbak-erdat,
              lr_vdatu  for  vbak-vdatu,
              lr_zpjno  for  vbak-zpjno,
              lr_vkgrp  for  vbak-vkgrp,
              lr_vkbur  for  vbak-vkbur,
              lr_vtweg  for  vbak-vtweg,
              lr_spart  for  vbak-spart,
              lr_ernam  for  vbak-ernam,
              lr_kunag  for  vbpa-kunnr,
              lr_vkorg FOR mvke-vkorg , "판매법인Roll-in / 22.04.2026 10:20:12
              lr_matnr  for  vbap-matnr.

  clear : es_return, et_data, et_data[], lv_zpjno, lv_msg, lv_amt.
*-----------------------------------------------------------------------
*-- CHECK IMPORTED VALUES
*-----------------------------------------------------------------------

* 사용자 이름 확인
  if is_d365_login-ename is initial.
    message s007(zgtsd01) with text-e12 into lv_msg.
    es_return = value #( mtype = zgtsd_e message = lv_msg ).
    perform save_log(zcmr0004) tables gt_ilog using gs_hlog es_return.
    exit.
  endif.


*{ 판매법인Roll-in / 22.04.2026 10:23:52 - Start
  IF  is_d365_login-vkorg IS NOT INITIAL.
    _ranges lr_vkorg  is_d365_login-vkorg.
  ENDIF.
*} - End


* 프로젝트 번호 확인
  if is_search-zpjno is not initial.
* 프로젝트 번호 유효성 확인
    if is_search-zpjno(2) ne 'PD'.
      lv_zpjno = is_search-zpjno(8) && `*`.
    else.
      lv_zpjno = is_search-zpjno.
    endif.

    __rng lr_zpjno 'I' 'CP' lv_zpjno space.

    select single @abap_true into @data(lv_flg)
      from zsd0106t
     where zpjno in @lr_zpjno.

    if lv_flg ne zgtsd_x.
      message s006(zgtsd01) with text-e02 into lv_msg.
      es_return = value #( mtype = zgtsd_e message = lv_msg ).
      perform save_log(zcmr0004) tables gt_ilog using gs_hlog es_return.
      exit.
    endif.
* 프로젝트 번호가 없을 경우 생성일/납품일/영업팀 필수
  else.
    if is_search-vdatu_s is initial or is_search-vkbur is initial.
      message s006(zgtsd01) with text-e15 into lv_msg.
      es_return = value #( mtype = zgtsd_e message = lv_msg ).
      perform save_log(zcmr0004) tables gt_ilog using gs_hlog es_return.
      exit.
    endif.

    if is_search-erdat_e is not initial.
      if is_search-erdat_s is not initial.
        __rng lr_erdat 'I' 'BT' is_search-erdat_s is_search-erdat_e.
      endif.
    else.
      if is_search-erdat_s is not initial.
        __rng lr_erdat 'I' 'EQ' is_search-erdat_s ''.
      endif.
    endif.

    if is_search-vdatu_e is not initial.
      __rng lr_vdatu 'I' 'BT' is_search-vdatu_s is_search-vdatu_e.
    else.
      __rng lr_vdatu 'I' 'EQ' is_search-vdatu_s ''.
    endif.

    if is_search-vkgrp is not initial.
      __rng lr_vkgrp 'I' 'EQ' is_search-vkgrp space.
    endif.

    if is_search-vkbur is not initial.
      __rng lr_vkbur 'I' 'EQ' is_search-vkbur space.
    endif.

    if is_search-vtweg is not initial.
      __rng lr_vtweg 'I' 'EQ' is_search-vtweg space.
    endif.
    if is_search-spart is not initial.
      __rng lr_spart 'I' 'EQ' is_search-spart space.
    endif.

    if is_search-matnr is not initial.
      _matnr_i is_search-matnr is_search-matnr.
      __rng lr_matnr 'I' 'EQ' is_search-matnr space.
    endif.

  endif.

  loop at it_kunnr.
    if it_kunnr-kunnr is not initial.
      _alpha_input it_kunnr-kunnr.
      __rng lr_kunag 'I' 'EQ' it_kunnr-kunnr space.
    endif.
  endloop.

  if is_search-empno is not initial.
    __rng lr_ernam 'I' 'EQ' is_search-empno space.
  endif.

*-----------------------------------------------------------------------
*-- QUERY DATA
*-----------------------------------------------------------------------

  with +so_base as ( select b~vbeln, b~posnr, b~matnr, b~arktx, b~vrkme,
                            b~kwmeng,a~kunnr, a~vdatu, a~zpjno, b~werks,
                            b~sobkz, b~netwr, a~waerk, b~bedae, a~vkorg,
                            a~vtweg, b~netpr, c~kunnr as kunwe, a~erzet,
                            a~erdat, a~bstnk
                       from vbak as a inner join vbap as b
                                         on a~vbeln eq b~vbeln
                                      inner join vbpa as c
                                         on a~vbeln eq c~vbeln
                                        and c~parvw eq 'WE'
                      where a~zpjno in @lr_zpjno
                        and a~erdat in @lr_erdat
                        and a~vdatu in @lr_vdatu
                        and a~vkbur in @lr_vkbur
                        and a~vkgrp in @lr_vkgrp
                        and a~spart in @lr_spart
                        and a~vtweg in @lr_vtweg
                        and a~ernam in @lr_ernam
                        and a~kunnr in @lr_kunag
                        and b~matnr in @lr_matnr
                        AND A~VKORG IN @LR_VKORG "판매법인Roll-in / 22.04.2026 10:48:36
                        and a~auart in ('TA','ZEXE','Z3RD')
                        and b~abgru in  ('', '94','95','96','Z1','Z2' ) ),
                        "AND A~ABSTK NE @ZGTSD_C ),

    "  /* 스케줄 라인 수량 집계 */
      +scd_item as ( select vep~vbeln, vep~posnr,
                            max( vep~etenr ) as etenr,
                            max( vep~edatu ) as edatu,
                            sum( vep~bmeng ) as bmeng
                       from vbep as vep inner join +so_base as b
                                           on vep~vbeln eq b~vbeln
                                          and vep~posnr eq b~posnr
                      where vep~bmeng is not null
                        and vep~bmeng ne 0
                      group by vep~vbeln, vep~posnr, vep~etenr ),

   "   /* 딜리버리 수량: LIPS-WBSTA로 아이템 단위 집계 */
      +do_lips as ( select l~vbeln as vbeln_do, l~vgbel as vbeln, l~vgpos as posnr,
                           wadat, lfimg,

                           case when uecha is not initial
                                then uecha
                                else l~posnr end as posnr_do,

                           case when l~wbsta eq @zgtsd_c
                                then l~lfimg
                                else 0 end as qty_dlv,

                           case when l~wbsta eq @zgtsd_c
                                then c~wadat_ist
                                else null end as wadat_ist,

                           case when l~wbsta eq @zgtsd_c
                                then 0
                                else l~lfimg end as qty_open

*                           CASE WHEN L~WBSTA NE @ZGTSD_C
*                                  OR L~WBSTA IS NULL
*                                THEN L~LFIMG
*                                ELSE 0 END AS QTY_OPEN1

                      from lips as l inner join +so_base as b
                                        on b~vbeln eq l~vgbel
                                       and b~posnr eq l~vgpos
                                     inner join likp as c
                                        on l~vbeln eq c~vbeln
                     where l~lfimg is not null
                       and l~lfimg ne 0 ),

      +do_item as ( select l~vbeln_do, l~posnr_do, l~vbeln, l~posnr,
                           max( l~wadat ) as wadat,
                           max( l~wadat_ist ) as wadat_ist,
                           sum( l~lfimg ) as lfimg,
                           sum( l~qty_dlv ) as qty_dlv,
                           sum( l~qty_open ) as qty_open
                      from +do_lips as l inner join +so_base as b
                                            on b~vbeln eq l~vbeln
                                           and b~posnr eq l~posnr
                     group by l~vbeln, l~posnr, l~vbeln_do, l~posnr_do ),

  "    /* VBKD: 아이템 수준만 필요 시 */
      +drum as ( select v~vbeln, v~posnr, v~empst as zdrum
                   from vbkd as v inner join +so_base as b
                                     on v~vbeln eq b~vbeln
                                    and v~posnr eq b~posnr )

 select
    a~kunnr,  a~vbeln, a~posnr, a~matnr, a~arktx, a~bedae, a~vkorg,
    a~kwmeng, a~vdatu, a~werks, a~vrkme, a~sobkz, a~vtweg, a~netpr,
    a~netwr,  a~waerk, a~kunwe, a~erdat, a~erzet, a~bstnk,
    d~lfimg as bmeng,  "D~WADAT AS EDATU, " SC~BMENG, SC~EDATU,

    case when d~wadat is not initial
         then d~wadat
         when d~wadat is initial and sc~edatu is not initial
         then sc~edatu
         else a~vdatu end as edatu,

    k~name1,
    p~zpjno, p~zptxt,
    d~vbeln_do, d~posnr_do, d~wadat_ist as wadat,
    dr~zdrum as zdrum,
    k2~name1 as name_we,

    coalesce( d~qty_dlv, 0 ) as qty_dlv,
    ( coalesce( d~qty_dlv, 0 ) * cast( a~netpr as dec( 11,2 ) ) ) as amt_dlv,
*    ( COALESCE( SC~BMENG, 0 ) - COALESCE( D~QTY_DLV, 0 ) )        AS QTY_UNDLV,
    ( coalesce( d~lfimg, 0 ) - coalesce( d~qty_dlv, 0 ) )        as qty_undlv,
    ( ( coalesce( d~lfimg, 0 ) - coalesce( d~qty_dlv, 0 ) )
      * cast( a~netpr as dec( 11,2 ) ) )                          as amt_undlv

    from +so_base  as a inner join kna1      as k
                           on a~kunnr eq k~kunnr

                        inner join kna1      as k2
                           on a~kunwe eq k2~kunnr

                        left join zsd0106t  as p
                           on a~zpjno eq p~zpjno

                        left  join +scd_item as sc
                          on a~vbeln eq sc~vbeln
                         and a~posnr eq sc~posnr

                        left  join +do_item  as d
                          on a~vbeln eq d~vbeln
                         and a~posnr eq d~posnr

                        left  join +drum     as dr
                          on a~vbeln eq dr~vbeln
                         and a~posnr eq dr~posnr

  order by a~vbeln, a~posnr

  into table @data(lt_data).


  if sy-subrc eq 0.

    et_data[] = corresponding #( lt_data[] ).

*판매오더 단가 조회
    data(lt_for) = lt_data[].
    sort lt_for by vbeln.
    delete adjacent duplicates from lt_for comparing vbeln.
    if lt_for[] is not initial.
      select a~vbeln, a~knumv, kposn, kschl, kbetr, b~waerk
        from vbak as a inner join prcd_elements as b
          on a~knumv = b~knumv
         for all entries in @lt_for
       where a~vbeln = @lt_for-vbeln
         and b~kschl in ('PR00','ZPR0')
        into table @data(lt_netpr).
      sort lt_netpr by vbeln kposn kschl.
    endif.

* 배치 재고 조회
    with +key_info as ( select a~matnr, a~werks
                           from @lt_data as a
                          group by a~matnr, a~werks )

    select a~matnr, a~werks, sum( a~clabs ) as clabs, a~meins, a~grade, a~grade_t

      from zgtsd_cv_get_vcofbatch as a inner join +key_info as b
                       on a~matnr eq b~matnr
                       and a~werks eq b~werks
                       and a~clabs gt 0
                       and a~atnam eq 'BT_AA_GRADE'
  group by a~matnr, a~werks, a~meins, a~grade, a~grade_t
    into table @data(lt_mchb).

* 판매오더 재고 조회
    with +key_info as ( select a~matnr, a~werks, a~vbeln,
                                a~posnr, a~sobkz
                           from @lt_data as a
                          group by a~matnr, a~werks, a~vbeln,
                                   a~posnr, a~sobkz )

    select a~vbeln, a~posnr, a~matnr, a~werks,
           sum( a~kalab ) as kalab

      from mska as a inner join +key_info as b
                        on a~vbeln eq b~vbeln
                       and a~posnr eq b~posnr
                       and a~matnr eq b~matnr
                       and a~werks eq b~werks
                       and a~sobkz eq b~sobkz
                       and a~kalab gt 0

*    ORDER BY A~VBELN, A~POSNR
    group by a~vbeln, a~posnr, a~matnr, a~werks
    into table @data(lt_mska).

* Variant Configuration
    with +key_info as ( select a~vbeln, a~posnr, a~werks, a~matnr
                          from @lt_data as a
                         group by a~vbeln, a~posnr, a~werks, a~matnr ),

        +vc_gr as ( select a~vbeln, a~posnr, a~atnam, a~atinn,
                           case when a~atnam eq @lc_color
                                then a~atwrt
                                end as color,

                           case when a~atnam eq @lc_length
                                then a~atflv
                                end as jojan,

                           case when a~atnam eq @lc_factor
                                then a~atflv
                                end as jojan_cnt,

                           case when a~atnam eq @lc_spec
                                then a~atwrt
                                end as specno,

                           case when a~atnam eq @lc_grade
                                then a~atwrt
                                end as grade

                      from zgtmm_cv_bd_get_vcofso as a inner join +key_info as b
                                                          on a~vbeln eq b~vbeln
                                                         and a~posnr eq b~posnr
                                                         and a~werks eq b~werks
                                                         and a~matnr eq b~matnr
                    where a~atnam in ( @lc_color, @lc_length, @lc_factor, @lc_spec, @lc_grade )

                    group by a~vbeln, a~posnr, a~atnam,  a~atinn, a~atwrt, a~atflv )

        select a~vbeln, a~posnr,  a~atnam, a~color,
               a~jojan, a~specno, a~grade, a~atinn,
               a~jojan_cnt
          from +vc_gr as a left outer join cawn as ca
            on a~atinn = ca~atinn
           and a~grade = ca~atwrt
          left outer join cawnt as ct
            on ca~atinn = ct~atinn
           and ca~atzhl = ct~atzhl
           and ca~spras eq @sy-langu
    order by a~vbeln, a~posnr, a~atnam

    into table @data(lt_vc).

* Charge Weight
    with +key_info as ( select a~matnr,a~vkorg, a~vtweg
                          from @lt_data as a
                        group by a~matnr, a~vkorg, a~vtweg )

    select b~matnr, a~vgw, a~vge
      from /nfm/tvgw as a inner join +key_info as b
                             on a~matnr   eq b~matnr
                            and a~kappl   eq @zgtsd_v
                            and a~org     eq b~vkorg
                            and a~vtweg   eq b~vtweg
                            and a~nes     eq 'CU'

     group by b~matnr, a~vgw, a~vge

     into table @data(lt_nf).

    sort lt_mska by vbeln posnr matnr werks.

    loop at et_data assigning field-symbol(<es_data>).

* Sales Order Stock
      read table lt_mska into data(ls_mska) with key vbeln = <es_data>-vbeln
                                                     posnr = <es_data>-posnr
                                                     matnr = <es_data>-matnr
                                                     werks = <es_data>-werks.
      if sy-subrc eq 0.
        <es_data>-kalab = ls_mska-kalab.
      endif.

* Batch Stock
      read table lt_mchb into data(ls_mchb) with key matnr = <es_data>-matnr
                                                     werks = <es_data>-werks
                                                     grade = <es_data>-grade.
      if sy-subrc eq 0.
        <es_data>-clabs = ls_mchb-clabs.

      endif.


* Characteristics (Variant Configuration)
      loop at lt_vc into data(ls_vc) where vbeln eq <es_data>-vbeln
                                       and posnr eq <es_data>-posnr.

        case ls_vc-atnam.
          when lc_color.
            <es_data>-color     = ls_vc-color.
          when lc_length.
            <es_data>-jojan     = ls_vc-jojan.
          when lc_factor.
            <es_data>-jojan_cnt = ls_vc-jojan_cnt.
          when lc_spec.
            <es_data>-specno    = ls_vc-specno.
          when lc_grade.
            <es_data>-grade    = ls_vc-grade.
        endcase.

      endloop.

* Charge Weight
      read table lt_nf into data(ls_nf) with key matnr = <es_data>-matnr.

      if sy-subrc eq 0.
        if ls_nf-vge ne 0.
          <es_data>-cu_qty_total   = ( ls_nf-vgw / ls_nf-vge ) * <es_data>-kwmeng.  " 동량 .
        endif.
        <es_data>-cu_qty_dlv     = ( ls_nf-vgw / ls_nf-vge ) * <es_data>-qty_dlv.      " 출하동량
        <es_data>-cu_qty_undlv   = <es_data>-cu_qty_total - <es_data>-cu_qty_dlv.   " 미출하동량
      endif.

* Currency Conversion

* Net Price
      read table lt_netpr into data(ls_netpr) with key vbeln = <es_data>-vbeln
                                                       kposn = <es_data>-posnr
                                                       kschl = 'PR00' binary search.
      if sy-subrc = 0.
        <es_data>-netpr = ls_netpr-kbetr.
        <es_data>-waerk = ls_netpr-waerk.
      else.
        read table lt_netpr into ls_netpr with key vbeln = <es_data>-vbeln
                                                   kposn = <es_data>-posnr
                                                   kschl = 'ZPR0' binary search.
        if sy-subrc = 0.
          <es_data>-netpr = ls_netpr-kbetr.
          <es_data>-waerk = ls_netpr-waerk.
        endif.
      endif.

* Amount
      clear lv_amt.
      if <es_data>-netwr ne 0.
        call function 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
          exporting
            amount_internal = <es_data>-netwr
            currency        = <es_data>-waerk
          importing
            amount_external = lv_amt.
        <es_data>-netwr = conv #( lv_amt ).
      endif.

** Price of Delivered Qty
      <es_data>-amt_dlv = <es_data>-qty_dlv * <es_data>-netpr.

** Price of Undelivered Qty
      <es_data>-amt_undlv = <es_data>-qty_undlv * <es_data>-netpr.

      _alpha_output <es_data>-kunwe.
      _alpha_output <es_data>-kunnr.
      _alpha_output <es_data>-posnr.
      _alpha_output <es_data>-posnr_do.
      _matnr_o <es_data>-matnr <es_data>-matnr.
    endloop.

    sort et_data by vbeln posnr.

* Return Message - Success
    data(lv_type) = zgtsd_s.
*    lv_msg = |조회에 성공 하였습니다.|.
    lv_msg = text-m09.
  else.

* Return Message - Failed
    lv_type = zgtsd_s.
*    lv_msg = |검색 조건에 대한 데이터가 없습니다.|.
    lv_msg = text-m10.
  endif.

*-----------------------------------------------------------------------
*-- RETURN MESSAGE
*-----------------------------------------------------------------------
  es_return = value #( mtype = lv_type message = lv_msg ).
  perform save_log(zcmr0004) tables gt_ilog using gs_hlog es_return.

endfunction.
