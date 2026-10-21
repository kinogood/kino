@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '사급 자재 불출 이력 최종 Guid'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_ZGTMMT4114_MAXGUID 
as select from zgtmmt4114
{
  key pswrk,
  key ebeln,
  key ebelp,
  key matnr,
  key tagnr,
  key charg,
  key zseq,
  max(zguid) as ZGUID
} group by pswrk,ebeln,ebelp,matnr,tagnr,charg,zseq
