@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트 별 재고 현황,금액'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETPLANTSTOCKVAL 
as select from ZGTMM_CV_GETPLANTST_BD as A
    inner join Mbv_Mbew as B on A.matnr = B.matnr and A.werks = B.bwkey
    inner join t001k as C on B.bwkey = C.bwkey
    inner join t001 as D on C.bukrs = D.bukrs
{
    key A.werks,
    key A.matnr,
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    A.UNQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    A.BDQTY,
    A.meins,
    @Semantics.amount.currencyCode: 'waers'
    case when B.vprsv = 'S' 
         then
           cast(cast(cast(B.stprs as abap.dec(13,2)) / B.peinh as abap.dec(13,2)) * A.TOQTY as abap.curr(13,2))
         else
           cast(cast(cast(B.verpr as abap.dec(13,2)) / B.peinh as abap.dec(13,2)) * A.TOQTY as abap.curr(13,2))         
         end as STOCKVAL,
 //   B.salk3 as STOCKVAL,
    D.waers  
}
