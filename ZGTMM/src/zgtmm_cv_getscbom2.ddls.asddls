@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 사급 BOM/창고재고 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETSCBOM2 
as select from ZGTMM_CV_GETSCBOM_T as A 
              inner join ZGTMM_CV_STOCKLIST_SUM as B on A.CMATNR = B.matnr and A.werks = B.werks
{
   key A.bukrs,
   key A.ekorg,
   key A.werks,
//   key A.matnr,
   key A.lifnr,
//       A.verid,             //생산버전
//       A.stlan,             //BOM 용도
//       A.stlal,             //대체
       A.CMATNR,   //투입자재
       A.maktx,
       A.xchpf,
       A.vprsv,             //가격관리지시자
   
       @Semantics.amount.currencyCode: 'waers'
       A.PRICE,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       A.peinh,
       A.waers,    
       A.meins,
    
       case when B.lgort is null then cast('' as abap.char(4))
            else B.lgort end as LGORT,
            
       @Semantics.quantity.unitOfMeasure: 'MEINS'    
       case when B.UNQTY is null then cast(0 as abap.quan(13,3))
            else B.UNQTY end as UNQTY,
            
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       case when B.QIQTY is null then cast(0 as abap.quan(13,3))
            else B.QIQTY end as QIQTY,       
       
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       case when B.BLQTY is null then cast(0 as abap.quan(13,3))
            else B.BLQTY end as BLQTY      
}


