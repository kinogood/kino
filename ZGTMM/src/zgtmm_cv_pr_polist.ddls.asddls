@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PR 별 후속 진행 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_PR_POLIST 
as 
select from ZGTMM_CV_POGR_REMAIN
{
    banfn,
    bnfpo,   
    werks, 
    @Semantics.quantity.unitOfMeasure: 'MEINS'  
    sum(menge) as POQTY,
    meins,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    sum(INBQTY) as INBQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    sum(GRQTY) as GRQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'  
    sum(REQTY) as REQTY      
} where banfn <> ''
 group by banfn, bnfpo, meins, werks
