@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PR 별 PO 수량'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_POQTY_PR 
as 
select from ekpo
{
    key matnr,
    key werks,
    key banfn,
    key bnfpo,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    sum(menge) as MENGE,
    meins 
} where banfn <> '' and loekz = '' and matnr <> ''
group by matnr, werks, banfn, bnfpo, meins
