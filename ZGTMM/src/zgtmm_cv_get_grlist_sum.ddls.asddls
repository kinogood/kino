@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 입고 내역 조회(수량 합산)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GRLIST_SUM 
as select from ZGTMM_CV_GET_GRLIST_BASE as A    
{
 key A.ebeln,
 key A.ebelp,
     @Semantics.quantity.unitOfMeasure: 'GR_MEINS' 
     sum(A.bpmng) as MENGE,
     A.bprme as GR_MEINS,
     @Semantics.amount.currencyCode: 'WAERS'
     A.netpr,  //구매단가
     @Semantics.quantity.unitOfMeasure: 'PO_MEINS'
     A.peinh,
     A.POBPRME as PO_MEINS,
     @Semantics.amount.currencyCode: 'konwa'      
     A.kbetr, //INFO 단가
     A.konwa,
     A.kpein,
     A.kmein,     
     @Semantics.amount.currencyCode: 'WAERS'
     sum(A.PRICESUM) as PRICESUM,          
     A.waers,
     case when A.meprf = '5' then cast('전기일 유효 단가' as abap.char(20))
          else cast('PO 단가' as abap.char(20)) end as PRICE_TYPE

    
} where A.cancelled = '' and A.reversal_movement = ''
group by A.ebeln, A.ebelp, A.bprme, A.netpr, A.peinh, A.POBPRME, A.kbetr, A.konwa, A.kpein, A.kmein, A.waers, A.meprf
