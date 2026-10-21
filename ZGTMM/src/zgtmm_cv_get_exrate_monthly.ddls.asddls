@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '비철 적용가 계산을 위한 기준 환율'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_EXRATE_MONTHLY 
as 
/*
select from ZGTMM_CV_GET_EXRATE_RAW 

{
   key PERIOD,
   key TYPE,
   key currency,
       avg(EXRATE as ztr_ttbuy_dec) as EXRATE 
} group by PERIOD, TYPE, currency*/

select from ZGTMM_CV_GET_EXRATE_RAW_MON

{
   key period,
   key TYPE,
   key currency,
       avg(EXRATE as ztr_ttbuy_dec) as EXRATE 
} group by period, TYPE, currency


 