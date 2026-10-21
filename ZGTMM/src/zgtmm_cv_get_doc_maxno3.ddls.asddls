@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '거래명세서 최종 번호(MAX)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DOC_MAXNO3 
as select from ZGTMM_CV_GET_DOC_MAXNO2 
{
  key bukrs,
  cast(CONCAT('20',LEFT(ZDOC_NO,6)) as abap.dats) as YYYYMMDD,
  RIGHT(ZDOC_NO,4) as SEQ
     
}
