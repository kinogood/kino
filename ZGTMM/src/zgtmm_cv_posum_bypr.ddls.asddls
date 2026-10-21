@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PR 별  PO 수량 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_POSUM_BYPR 
as 
select from ekpo as A  inner join eban as B on A.banfn = B.banfn and A.bnfpo = B.bnfpo
association [1..1] to mara as MARA on $projection.matnr = MARA.matnr   
{
    key A.ebeln,
    key A.ebelp,
        A.matnr,
          
        @Semantics.quantity.unitOfMeasure: 'POMEINS'
        A.menge as POMENGE,
        A.meins as POMEINS,
        @Semantics.quantity.unitOfMeasure: 'BASICSUNIT'
        case when A.umren = 0 
             then A.menge 
             else cast(A.menge * A.umrez / A.umren as abap.quan(13,3)) 
        end as CMENGE,
        case when mara.meins is null then A.meins
             else mara.meins end  as BASICSUNIT,
        
        @Semantics.quantity.unitOfMeasure: 'PRMEINS'
        B.menge as PRMENGE,
        B.meins as PRMEINS,
        
        A.umrez,
        A.umren,
        A.banfn,
        A.bnfpo,
        case when A.meins <> mara.meins then 'DIFF'
             else '' end as DIFF
        
} where A.loekz = '' and A.banfn <> ''
