@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '비철 적용가 계산을 위한 기준 환율'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_EXRATE_RAW 
as select from ztrtf13

{
   key LEFT(qdate,6) as PERIOD,
   key cast('TTS' as abap.char(3)) as TYPE,
   key currency,
       sdate,
       ttbuy as EXRATE  
} where ttbuy > 0

union all

select from ztrtf13

{
   key LEFT(qdate,6) as PERIOD,
   key cast('TTM' as abap.char(3)) as TYPE,
   key currency,
       sdate,
       ttsell as EXRATE  
} where ttsell > 0
