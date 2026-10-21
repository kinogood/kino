@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직납 Vendor Count'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETDVCOUNT 
as select from zgtmmt4000
{
  key bukrs,
  key werks,
  key matnr, 
  key lifnr,
  count(*) as CNT
} group by bukrs,werks,matnr,lifnr
