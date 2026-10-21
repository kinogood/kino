@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 가온 적송 Delivery Item 정보'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_ZGTSDT9120
  as select from ZGTSD_I_ZGTSDT9120_BASE
{
  key vbeln,
  key cast(posnr as posnr_vl preserving type ) as posnr,
      vbeln_so,
      posnr_so,

      werks,
      cast(max(lgort) as lgort_d preserving type ) as lgort,
      matnr,
      arktx,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(sum(lfimg) as lfimg preserving type ) as lfimg,
      vrkme,
      wbsta,
      cast(max(fksta) as fksta preserving type ) as fksta

}
group by
  vbeln,
  posnr,
  vbeln_so,
  posnr_so,
  werks,
  matnr,
  arktx,
  vrkme, 
  wbsta
