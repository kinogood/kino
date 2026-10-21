@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 임가공 자재 별 소요량+외주재고'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCREQLIST_L 
as select from ZGTMM_CV_SCREQLIST_E 
{
   key bukrs,
   key ekorg,
   key werks,
   key lifnr,
   key LGORT,
   key CMATNR as MATNR,              //투입자재
       maktx,                        //투입자재명
       xchpf,                        //배치관리여부
   
       @Semantics.amount.currencyCode: 'waers'
       PRICE,                        //STOCK VALUE
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       peinh,                        //가격단위 
       waers,    
            
       @Semantics.quantity.unitOfMeasure: 'MEINS'    
       UNQTY as SLQTY,                        //창고재고수량
       meins,            
  
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       SCSTOCK as SCQTY,                     //외주재고수량
    
       @Semantics.amount.currencyCode: 'waers'  
       SCVALUE as SCVAL,                     //외주재고금액
       
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       sum(bdmng) as REQTY,         //총소요량
       @Semantics.quantity.unitOfMeasure: 'MEINS'   
       case when  SCSTOCK >= sum(bdmng)   then cast(0 as abap.quan(13,3))
            else  (SCSTOCK - sum(bdmng)) * -1  end  as NEQTY
} group by bukrs,ekorg,werks,lifnr,LGORT,CMATNR,maktx,xchpf,PRICE,peinh,waers,meins,UNQTY,SCSTOCK,SCVALUE
   
