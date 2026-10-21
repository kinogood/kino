@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 임가공 자재 별 소요량+외주재고'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCREQLIST_E 
as select from ZGTMM_CV_GETSCBOM3 as a
   left outer join ZGTMM_CV_SCREQLIST_TOT as b on a.bukrs = b.bukrs and a.ekorg = b.ekorg 
                                              and a.werks = b.werks and a.lifnr = b.lifnr
                                              and a.LGORT = b.ISSUESL and a.CMATNR = b.CMATNR 
                                              
{
   key a.bukrs,
   key a.ekorg,
   key a.werks,
   key a.lifnr,
   key a.LGORT,
   key a.CMATNR,              //투입자재
       a.maktx,               //투입자재명
       a.xchpf,               //배치관리여부
   
       @Semantics.amount.currencyCode: 'waers'
       a.PRICE,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       a.peinh,
       a.waers,    
       a.meins,
            
       @Semantics.quantity.unitOfMeasure: 'MEINS'    
       case when a.UNQTY is null then cast(0 as labst)
            else a.UNQTY end as unqty,
            
  
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       case when a.Lblab is null then cast(0 as labst)
            else a.Lblab end as SCSTOCK,                  //외주재고수량
    
       @Semantics.amount.currencyCode: 'waers'  
       case when a.totalscvalue is null then cast(0 as abap.curr(13,2))
            else a.totalscvalue end  as SCVALUE,    //외주재고금액
       
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       case when b.bdmng is null then cast(0 as labst)
            else b.bdmng end as bdmng
       //b.CMEINS
} 

union

select from ZGTMM_CV_SCREQLIST_EXC
{
   key bukrs,
   key ekorg,
   key werks,
   key lifnr,
   key LGORT,
   key CMATNR,              //투입자재
       maktx,               //투입자재명
       batchyn as xchpf,               //배치관리여부   
       PRICE,
       peinh,
       waers,    
       meins,
       case when UNQTY is null then cast(0 as labst)
            else UNQTY end as UNQTY,
       case when LBLAB is null then cast(0 as labst)
            else LBLAB end  as SCSTOCK,                  //외주재고수량
       case when TOTALSCVALUE is null then cast(0 as abap.curr(13,2))
            else TOTALSCVALUE end  as SCVALUE,    //외주재고금액
       
       case when bdmng is null then cast(0 as labst)
            else bdmng end as bdmng 
       //CMEINS
} 

union 
select from ZGTMM_CV_SCREQLIST_EXCT as A 
      left outer join ZGTMM_CV_STOCKLIST_SUM  as B on A.werks = B.werks and A.LGORT = B.lgort and A.cmatnr = B.matnr
{
   key A.bukrs,
   key A.ekorg,
   key A.werks,
   key A.lifnr,
   key A.LGORT,
   key A.cmatnr,              //투입자재
       A.maktx,               //투입자재명
       A.xchpf,               //배치관리여부   
       A.PRICE,
       A.peinh,
       A.waers,    
       A.meins,
       case when B.UNQTY is null then cast(0 as labst)
            else B.UNQTY end as UNQTY,
       case when A.SCSTOCK is null then cast(0 as labst)
            else A.SCSTOCK end as SCSTOCK,                  //외주재고수량
       case when A.SCVALUE is null then cast(0 as abap.curr(13,2))
            else A.SCVALUE end as scvalue,    //외주재고금액
       case when A.BDMNG is null then cast(0 as labst)
            else A.BDMNG end as BDMNG   
       //CMEINS
}
