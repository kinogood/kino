@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '거래명세서 최종 번호2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DOC_MAXNO2 
as select from ZGTMM_CV_GET_DOC_MAXNO
{
  key bukrs,
  max(zdoc_no)as ZDOC_NO  
} group by bukrs
