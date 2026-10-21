@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'TAX RATIO 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_TAX_RATE 
as select from a003 as A inner join konp as B on A.knumh = B.knumh and A.kappl = B.kappl and A.kschl = B.kschl
{
  key A.mwskz,
     cast(cast(cast( B.kbetr as abap.curr(15,2)) as abap.dec(5,2)) * cast(0.1 as abap.dec(5,2)) as abap.dec(5,2)) as RATE
    
} where A.kappl = 'TX' and A.kschl = 'KRIT' and A.aland = 'KR'  
