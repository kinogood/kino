@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'B/L 수량 합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_BLQTYSUM 
as select from ZGTMM_CV_GET_BLQTY 
{
    key ebeln,
    key ebelp,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    sum(BLMNG) as BLMNG,
    MEINS    
} where igrno = ''
group by ebeln, ebelp, MEINS

