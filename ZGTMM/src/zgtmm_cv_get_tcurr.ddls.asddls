@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '환율 정보 조회(일자 환산)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_TCURR 
as select from tcurr
{
  key kurst,
  key fcurr,
  key tcurr,
  cast(cast(cast(99999999 as abap.dec(8,0)) - cast(gdatu as abap.dec(8,0)) as abap.char(15)) as abap.dats) as CDATE,
  ukurs
}
