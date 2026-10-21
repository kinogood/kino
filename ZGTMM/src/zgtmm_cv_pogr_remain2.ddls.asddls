@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO 입고 잔량 조회(PO 수량 - 순수 입고 수량)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_POGR_REMAIN2 
as 
select from ekko as A inner join ekpo as B on A.ebeln = B.ebeln
             left outer join ZGTMM_CV_POGR_INFO  as D on B.ebeln = D.ebeln and B.ebelp = D.ebelp
    
{
    key B.ebeln,
    key B.ebelp,
    B.matnr,
    B.txz01,      
    B.werks,
    B.retpo,
    @Semantics.quantity.unitOfMeasure: 'MEINS'  
    case when B.retpo = 'X' then B.menge * -1 
         else B.menge end as menge,
    B.meins,
    B.uebto,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    case when D.MENGE is not null then D.MENGE else cast(0 as menge_d) end as GRQTY    
} 
