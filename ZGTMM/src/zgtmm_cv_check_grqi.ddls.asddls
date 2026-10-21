@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '품질검사 재고 입고 여부 체크'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_CHECK_GRQI 
as 
select from matdoc
{
  key mjahr,
  key mblnr,
  insmk  
} where insmk = 'X'
group by mjahr,mblnr,insmk
