@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 정산 용 송장 HISTORY 조회(자재 문서 별 SUM)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_EKBE_HISTORY_IV2 
as select from ZGTMM_CV_GET_EKBE_HISTORY_IV
{
   key GJAHR as MJAHR,
   key MBLNR,
   key ZEILE,
       @Semantics.quantity.unitOfMeasure: 'BSTME'           
       sum(menge) as MENGE,
       bstme,
       @Semantics.amount.currencyCode: 'waers'       
       sum(wrbtr) as WRBTR,
       waers   
} group by GJAHR, MBLNR, ZEILE, bstme, waers
