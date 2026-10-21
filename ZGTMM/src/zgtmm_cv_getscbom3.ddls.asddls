@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 사급 BOM/창고/외주재고 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETSCBOM3 
as 
select from ZGTMM_CV_GETSCBOM2 as a
left outer join ZGTMM_CV_SCSTOCKITEM_TOT as SC on a.bukrs = SC.bukrs
                                              and a.werks = SC.werks
                                              and a.CMATNR = SC.matnr
                                              and a.lifnr = SC.lifnr 
{
   key a.bukrs,
   key a.ekorg,
   key a.werks,
   key a.lifnr,
   key a.LGORT,
   key a.CMATNR,              //투입자재
 //      a.verid,             //생산버전
 //      a.stlan,             //BOM 용도
 //      a.stlal,             //대체
 //      a.matnr,               //외주가공품
       a.maktx,               //투입자재명
       a.xchpf,               //배치관리여부
 //      a.vprsv,               //가격관리지시자
   
       @Semantics.amount.currencyCode: 'waers'
       a.PRICE,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       a.peinh,
       a.waers,    
       a.meins,
            
       @Semantics.quantity.unitOfMeasure: 'MEINS'    
       a.UNQTY,
            
//       @Semantics.quantity.unitOfMeasure: 'MEINS'
//       a.QIQTY,       
       
//       @Semantics.quantity.unitOfMeasure: 'MEINS'
//       a.BLQTY,
  
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       case when SC.lblab is null then cast(0 as abap.quan(13,3)) 
            else SC.lblab end as Lblab,                  //외주재고수량
    
       @Semantics.amount.currencyCode: 'waers'  
       case when SC.totalscvalue is null then cast(0 as abap.curr(13,2)) 
            else SC.totalscvalue end as totalscvalue     //외주재고금액  
                
}
