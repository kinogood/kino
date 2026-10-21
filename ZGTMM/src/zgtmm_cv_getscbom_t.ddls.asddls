@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 사급 BOM 조회_Temp'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETSCBOM_T as select from ZGTMM_CV_GETSCBOM
{
   key bukrs,
   key ekorg,
   key werks,
   key lifnr,

       CMATNR,   //투입자재
       maktx,
       xchpf,
       vprsv,             //가격관리지시자
   
       @Semantics.amount.currencyCode: 'waers'
       PRICE ,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       peinh,
       waers,
       meins    
} group by bukrs, ekorg, werks, lifnr, CMATNR, maktx, xchpf, vprsv, PRICE, peinh, waers, meins
