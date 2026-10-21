@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Link 재고 합계 수량 집계 Base'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SO_LINK_STOCK_BASE
  as select from ZGTSD_I_GET_SO_LINK_STOCK as _Base
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
      cast(sum(_Base.LStock) as zgtelstock preserving type )       as LStock
//      @Semantics.quantity.unitOfMeasure: 'vrkme'
//      sum(
//          case when zcut_yn is not initial
//               then _Base.LStock 
//               else cast(0 as abap.quan(15,3)) 
//               end ) 
//      as cut_qty

}
group by
  _Base.vbeln,
  _Base.posnr,
  _Base.vkorg,
  _Base.vtweg,
  _Base.spart,
  _Base.vkbur,
  _Base.vkgrp,
  _Base.auart,
  _Base.matnr,
  _Base.werks,
  //  _Base.lgort,
  _Base.length,
  _Base.vrkme
