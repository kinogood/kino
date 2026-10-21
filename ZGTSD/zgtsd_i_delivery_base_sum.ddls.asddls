@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] Delivery Order Item (Batch 라인 합산)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_DELIVERY_BASE_SUM
  as select from ZGTSD_I_DELIVERY_BASE
{
  key vbeln,
  key main_posnr                                 as posnr,
      
      vbeln_so,
      posnr_so,
      
      lfart,
      werks,
      lgort,
      vstel,    
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(sum(lfimg) as lfimg preserving type ) as Lfimg,
      vrkme,
      cast(max(wadat_ist) as wadat_ist preserving type ) as wadat_ist,
      cast(max(wbsta) as wbsta preserving type ) as wbsta,
      cast(max(fksta) as fksta preserving type ) as fksta
}
group by
  vbeln,
  main_posnr,
  vbeln_so,
  posnr_so,
  lfart,
  werks,
  lgort,
  vstel,
  vrkme 
