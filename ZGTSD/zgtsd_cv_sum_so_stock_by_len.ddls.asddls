@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 조장, 조장 수 재고 합계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SUM_SO_STOCK_BY_LEN
  as select from ZGTSD_CV_SUM_SO_STOCK_BASE as _Base
  //    left outer join ZGTSD_CV_SUM_OPEN_PICKED_QTY as _Pick on  _Base.vbeln = _Pick.vbeln
  //                                                          and _Base.posnr = _Pick.posnr
  //                                                          and _Base.matnr = _Pick.matnr
  //                                                          and _Base.werks = _Pick.werks
  //                                                          and _Base.lgort = _Pick.lgort
{
  key _Base.vbeln,
  key _Base.posnr,
      _Base.matnr,
      _Base.werks,
      _Base.length,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      //      cast(
      //          cast( (coalesce(_Base.Estock,0) - coalesce(_Pick.picked_qty,0) ) as abap.quan(13,3))
      //      as zgteestock preserving type ) as Estock,

      cast( _Base.Estock as zgteestock preserving type ) as Estock,

      _Base.vrkme
}
//where
//  cast( (_Base.Estock - _Pick.picked_qty) as abap.quan(13,3)) > 0


//  as select from ZGTSD_I_GET_SO_STOCK_BY_LENGTH
//{
//  key vbeln,
//  key posnr,
//      werks,
//      length,
//      //      sum (factor) as sum_factor,
//      //      @Semantics.quantity.unitOfMeasure: 'vrkme'
//      //      sum(kalab)   as sum_kalab,
//
//      @Semantics.quantity.unitOfMeasure: 'vrkme'
//      cast(
//      case when sum (Estock) > 0
//                then sum (cast(Estock as abap.quan(13,3)))
//                else sum (cast(kalab as abap.quan(13,3)))
//           end
//           as zgteestock preserving type ) as Estock,
//      vrkme
//}
//group by
//  vbeln,
//  posnr,
//  werks,
//  length,
//  vrkme 
