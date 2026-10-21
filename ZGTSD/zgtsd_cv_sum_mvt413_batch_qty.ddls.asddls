@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 재고 413 처리 Batch 수량 합계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SUM_MVT413_BATCH_QTY
  as select from ZGTSD_I_MVT413_QTY_BATCH
{
  key matnr,
  key werks,
  key lgort,
  key charg,

      @Semantics.quantity.unitOfMeasure: 'meins'
      cast( coalesce( sum(erfmg), 0 )
//      cast( coalesce( sum(target_qty), 0 )        
           as abap.quan(13,3) ) as targeted_qty,
      meins
}
group by
  matnr,
  werks,
  lgort,
  charg,
  meins
