@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '환율정보 조회(월별)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_EXRATE_RAW_MON 
as select from zgtmmt1130
{
   key period,
   key cast('TTS' as abap.char(3)) as TYPE,
   key currency,
       ttsell as EXRATE  
} where ttsell > 0

union all

select from zgtmmt1130

{
   key period,
   key cast('TTM' as abap.char(3)) as TYPE,
   key currency,
       ttbuy as EXRATE  
} where ttbuy > 0
