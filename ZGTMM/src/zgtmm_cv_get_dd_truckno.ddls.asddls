@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송 배차 차량 번호 LOG 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DD_TRUCKNO 
as select from zgtmmt4403
{
  key bukrs,
  key concat_with_space( concat_with_space( concat_with_space(regiont, no2digit,1) , ch1digit , 1 ) ,no4digit ,1 )  as TRUCKNO,
      regiont,
      no2digit,
      ch1digit,
      no4digit
}

union

select from zgtmmt4405
{
  key bukrs,
 key concat_with_space( concat_with_space( concat_with_space(regiont, no2digit,1) , ch1digit , 1 ) ,no4digit ,1 )  as TRUCKNO,
      regiont,
      no2digit,
      ch1digit,
      no4digit  
}
