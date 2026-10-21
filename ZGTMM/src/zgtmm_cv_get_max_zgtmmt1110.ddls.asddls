@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 단가 환산 LOG 정보 조회(최신)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_MAX_ZGTMMT1110 
as select from zgtmmt1110
{
  key infnr,
  key matnr,
  key lifnr,
  key ekorg,
  key esokz,
  key werks,
  max(period) as PERIOD  
} where esokz = '0'
group by infnr, matnr, lifnr, ekorg, esokz, werks
