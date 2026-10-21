@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '예약/소모 기준 자재 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RESB_GI_MATNR                      
as
select from zgtmmt4203 as K 
       inner join marc as A on K.werks = A.werks and K.matnr = A.matnr
       inner join mara as B on A.matnr = B.matnr
       inner join ZGTMM_CV_GETMAXLTIME as C on  A.werks = C.werks and A.matnr = C.matnr
       inner join t001w as D on A.werks = D.werks
       inner join t001k as E on D.bwkey = E.bwkey
       inner join t001 as F on E.bukrs = F.bukrs
          
       left outer join ZGTMM_CV_GETPLANTSTOCKVAL as G on A.werks = G.werks and A.matnr = G.matnr         
       
       association [1..1] to t001 as T001 on $projection.bukrs = T001.bukrs       
       association [1..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language   
       association [1..1] to t001w as T001W on $projection.werks = T001W.werks     
   
{
   key  F.bukrs,
   key  t001.butxt as BUKRS_N,
   key  A.werks,
   key  t001w.name1 as werks_n,   
   key  A.matnr,
   key  makt.maktx as matnr_n,    
        B.meins,
        
        C.APLFZ as LT,             
        @Semantics.quantity.unitOfMeasure: 'MEINS' 
        case when G.UNQTY is null then cast(0 as abap.quan(13,3))
             else G.UNQTY end as UNQTY,                                         // 창고가용재고
        
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        case when G.BDQTY is null then cast(0 as abap.quan(13,3))
             else G.BDQTY end as BONDEDQTY,                // 보세창고재고        
        @Semantics.amount.currencyCode: 'waers'
        case when G.STOCKVAL is null then cast(0 as salk3)
             else G.STOCKVAL end as STOCKVAL,                  // 현 재고 금액
        G.waers,        
        case when K.week is not null and cast(K.week as abap.dec(2)) <> 0  then cast(K.week as abap.dec(2))
             else cast('15' as abap.dec(2)) end as PLANWEEK              
}  

