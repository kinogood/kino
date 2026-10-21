@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '배차 정보 SUMMARY'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DDR_SUM_TRUCK 
as select from zgtmmt4403
{
   key bukrs,
   key zreq_type,
   key dlvrq, 
  @Semantics.quantity.unitOfMeasure: 'dr_meins'   
   sum(loadqty) as LOADQTY,
   dr_meins
} group by bukrs, zreq_type, dlvrq, dr_meins

union all

select from zgtmmt4405
{
   key bukrs,
   key zreq_type,
   key dlvrq, 
     
   sum(loadqty) as LOADQTY,
   dr_meins
} group by bukrs, zreq_type, dlvrq, dr_meins
