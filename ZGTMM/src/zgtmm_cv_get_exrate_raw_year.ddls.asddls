@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '환율정보 조회(연별)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_EXRATE_RAW_YEAR 
as select from zgtmmt1131
{
   key gjahr as CYEAR,
   key cast('TTS' as abap.char(3)) as TYPE,
   key currency,
       ttbuy as EXRATE  
} where ttbuy > 0

union all

select from zgtmmt1131

{
   key gjahr as CYEAR,
   key cast('TTM' as abap.char(3)) as TYPE,
   key currency,
       ttsell as EXRATE  
} where ttsell > 0
