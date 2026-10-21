@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '적정재고 예상 소요량 집계_BASE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RESB_BASE 
as 
select from resb as A left outer join zgtmmt4203 as C on A.werks = C.werks and A.matnr = C.matnr
       inner join t001w as D on A.werks = D.werks
       inner join t001k as E on D.bwkey = E.bwkey 
       inner join zgtmmt4200 as f on A.werks = f.werks and A.bwart = f.bwart and A.shkzg = f.shkzg
       inner join zgtmmt4203 as K on A.werks = K.werks and A.matnr = K.matnr
{
    key A.rsnum,
    key A.rspos,
    A.bdart,
    E.bukrs,
    A.werks,
    A.matnr,

    @Semantics.quantity.unitOfMeasure: 'MEINS'
    A.bdmng,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    A.enmng,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    A.bdmng - A.enmng as REMAINQTY,
    A.meins,
    A.bdter,    
    cast(LEFT(A.bdter,4) as calendaryear) as BDTERYEAR,
    case when C.week is not null and cast(C.week as abap.dec(2)) <> 0 then cast(C.week as abap.dec(2))
         else cast('15' as abap.dec(2)) end as PLANWEEK,
    A.plnum,
    A.aufnr,     
    A.ebeln,
    A.ebelp,
    A.banfn,
    A.bnfpo     
} where A.bdter >= $session.user_date and  A.xloek = '' and A.kzear = ''
