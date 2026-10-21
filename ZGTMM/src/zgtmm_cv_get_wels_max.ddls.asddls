@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '전자결재 RESPONSE MAX SEQUENCE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_WELS_MAX 
as select from zgtmmt1051
{
   key legacyid,
   key appid,
   max(zseq) as ZSEQ 
} group by legacyid,appid
