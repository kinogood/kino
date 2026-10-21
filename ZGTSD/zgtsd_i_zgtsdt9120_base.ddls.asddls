@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 가온 적송 Delivery Item 정보(Base)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_ZGTSDT9120_BASE
  as select from zgtsdt9120
{
  key vbeln,
  key case when uecha is null or uecha = '000000'
           then posnr
           else uecha end as posnr,

      vgbel               as vbeln_so,
      vgpos               as posnr_so,

      werks,
      lgort,
      matnr,
      arktx,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      lfimg,
      vrkme, 
      wbsta,
      fksta
}
