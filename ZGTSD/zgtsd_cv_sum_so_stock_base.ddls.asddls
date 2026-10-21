@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 조장, 조장수 수량 합계 Base'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SUM_SO_STOCK_BASE
  as select from ZGTSD_I_GET_SO_STOCK_BY_LENGTH
{
  key vbeln,
  key posnr,
      matnr,
      werks,
//      lgort,
      length,
      //      sum (factor) as sum_factor,
      //      @Semantics.quantity.unitOfMeasure: 'vrkme'
      //      sum(kalab)   as sum_kalab,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(
           case when sum (Estock) > 0
                then sum (cast(Estock as abap.quan(13,3)))
                else sum (cast(kalab as abap.quan(13,3)))
           end
      as zgteestock preserving type ) as Estock,
      
      vrkme
}
group by
  vbeln,
  posnr,
  matnr,
  werks,
//  lgort,
  length,
  vrkme 
