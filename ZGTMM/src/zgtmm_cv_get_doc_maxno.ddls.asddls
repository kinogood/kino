@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '거래명세서 최종 번호'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DOC_MAXNO 
as select from zgtmmt4403
{
  key bukrs,
  zdoc_no
} 

union

select from zgtmmt4405
{
  key bukrs,
  zdoc_no
} 
