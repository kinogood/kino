@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 납품일정 라인 Max Etenr 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_VBEP_MAX 
    as select from vbep
{
  key vbeln,
  key posnr,
  max(etenr) as max_etenr,
  max(edatu) as max_edatu
}
group by vbeln, posnr 
