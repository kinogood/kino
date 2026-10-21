@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 출하요청 상태용 경량화 뷰 (상태 조회 전용)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_GET_DLVREQ_DUE_LIGHT 
  as select from    vbap                         as _Item

  // 1. 일정라인 (납품 관련 여부 필터 및 Max Etenr)
    inner join      ZGTSD_CV_VBEP_MAX            as _SchedMax  on  _Item.vbeln = _SchedMax.vbeln
                                                               and _Item.posnr = _SchedMax.posnr
    inner join      vbep                         as _SchedLine on  _SchedMax.vbeln     = _SchedLine.vbeln
                                                               and _SchedMax.posnr     = _SchedLine.posnr
                                                               and _SchedMax.max_etenr = _SchedLine.etenr

  // 2. 수량 집계 View (Aggregations)
    left outer join ZGTSD_CV_SUM_DLVQTY_FACTOR   as _SumFactor on  _Item.vbeln = _SumFactor.vbeln
                                                               and _Item.posnr = _SumFactor.posnr
    left outer join ZGTSD_CV_SUM_ZLET0401        as _Sum0401   on  _Item.vbeln = _Sum0401.vbeln
                                                               and _Item.posnr = _Sum0401.posnr
    left outer join ZGTSD_CV_SUM_ZLET0402        as _Sum0402   on  _Item.vbeln = _Sum0402.vbeln
                                                               and _Item.posnr = _Sum0402.posnr

  // 3. 특성값 및 단위 (Characteristics & UOM)
    left outer join ZGTSD_CV_GET_VCOFSO          as _CharSet   on  _Item.vbeln = _CharSet.vbeln
                                                               and _Item.posnr = _CharSet.posnr
    left outer join t006                         as _UOM       on  _Item.vrkme = _UOM.msehi
{
  key _Item.vbeln,
  key _Item.posnr,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _Item.kwmeng,
      _Item.vrkme,
      _CharSet.FACTOR,

      case
        when _UOM.dimid = 'LENGTH' and _CharSet.FACTOR is not initial
        then cast( ( coalesce( _CharSet.FACTOR, 0 )
                   - cast( coalesce( _SumFactor.sum_factor, 0 ) as abap.dec(13,3) )
                   - cast( coalesce( _Sum0401.req_qty, 0 )      as abap.dec(13,3) )
                   + cast( coalesce( _Sum0402.reqdo_qty, 0 )    as abap.dec(13,3) )
                 ) as abap.dec(13,3) )
        else cast( ( cast( coalesce( _Item.kwmeng, 0 )          as abap.dec(13,3) )
                   - cast( coalesce( _SumFactor.sum_qty, 0 )    as abap.dec(13,3) )
                   - cast( coalesce( _Sum0401.req_qty, 0 )      as abap.dec(13,3) )
                   + cast( coalesce( _Sum0402.reqdo_qty, 0 )    as abap.dec(13,3) )
                 ) as abap.dec(13,3) )
      end as rmqty
}
where
       _SchedLine.lfrel = 'X' // Delivery Relevance 필수 조건
  and  _Item.abgru      is initial
  and( _Item.vbtyp_ana  = 'C' or _Item.vbtyp_ana  = 'I' )
