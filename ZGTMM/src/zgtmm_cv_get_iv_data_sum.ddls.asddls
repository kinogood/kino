@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 별 송장 처리 현황 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_IV_DATA_SUM 
as select from ZGTMM_CV_GET_IV_DATA
{
   key ebeln,
   key ebelp,
   key vgabe,
   @Semantics.quantity.unitOfMeasure: 'BPRME'   
   sum(bpmng) as IV_QTY,
   bprme,
   @Semantics.amount.currencyCode: 'waers'  
   sum(wrbtr) as IV_AMOUNT,
   waers,
   @Semantics.amount.currencyCode: 'LC_waers'     
   sum(dmbtr) as IV_AMOUNT_KRW,
   LC_WAERS
   
} where stblg = ''
group by ebeln, ebelp, vgabe, bprme, waers, LC_WAERS
