@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '코스트센터 리스트 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_CCLIST 
as 
select from csks as A inner join cskt as B on A.kokrs = B.kokrs and A.kostl = B.kostl and A.datbi = B.datbi
{
  key A.bukrs,
  key A.kostl,
  key A.datbi,
      A.datab,
      B.ltext
    
} where B.spras = $session.system_language
