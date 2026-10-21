@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '선물 손익전표 SUMMARY'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_ZNFT1052 
as select from znft1052
{
  key gjahr,
  key belnr,
      gjahr_s,
      belnr_s  
} group by gjahr, belnr, gjahr_s, belnr_s
