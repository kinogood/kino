@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 정산 대상 월별 합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_TARGET_IVSUM 
as select from ZGTMM_CV_GET_TARGET_IV 
{
   key lifnr,
   key matnr,
   key ekorg,
   key SPMON,
   key werks,
   @Semantics.quantity.unitOfMeasure: 'IV_UNIT'
   cast(sum(IV_QTY) as abap.quan(25,3)) as IV_QTY,
   IV_UNIT
    
} where TARGET_PRICE > 0 and IV_COMPLETE = '' and ekorg = '1400' 
group by lifnr, matnr, ekorg, SPMON, IV_UNIT, werks
