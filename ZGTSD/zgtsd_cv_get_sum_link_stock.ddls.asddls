@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Link 재고 합계 조회'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_GET_SUM_LINK_STOCK
  as select from    ZGTSD_CV_SO_LINK_STOCK_BASE as _Base
    left outer join ZGTSD_CV_MVT413_QTY         as _413 on  _Base.vbeln = _413.vbeln
                                                        and _Base.posnr = _413.posnr
{
  key _Base.vbeln,
  key _Base.posnr,
      _Base.vkorg,
      _Base.vtweg,
      _Base.spart,
      _Base.vkbur,
      _Base.vkgrp,
      _Base.auart,
      _Base.matnr,
      _Base.werks,
//      _Base.lgort,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _Base.length,
      _Base.vrkme,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(
            cast( (_Base.LStock - coalesce(_413.target_qty,0))
                  as abap.quan(13,3) )
           as zgtelstock preserving type ) as LStock
}
where
  cast( (_Base.LStock - coalesce(_413.target_qty,0))
                    as abap.quan(13,3) ) > 0
//  as select from ZGTSD_I_GET_SO_LINK_STOCK as _Base
//{
//  key _Base.vbeln,
//  key _Base.posnr,
//      _Base.vkorg,
//      _Base.vtweg,
//      _Base.spart,
//      _Base.vkbur,
//      _Base.vkgrp,
//      _Base.auart,
//      _Base.matnr,
//      @Semantics.quantity.unitOfMeasure: 'vrkme'
//      _Base.length,
//      _Base.vrkme,
//      @Semantics.quantity.unitOfMeasure: 'vrkme'
//      cast(sum(_Base.LStock) as zgtelstock preserving type ) as LStock
//
//}
//group by
//  _Base.vbeln,
//  _Base.posnr,
//  _Base.vkorg,
//  _Base.vtweg,
//  _Base.spart,
//  _Base.vkbur,
//  _Base.vkgrp,
//  _Base.auart,
//  _Base.matnr,
//  _Base.length,
//  _Base.vrkme
