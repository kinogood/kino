@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '배차 수량 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DDR_QTY_TRUCK 
as select from zgtmmt4403
{
   key bukrs,
   key zreq_type,
   key dlvrq, 
  @Semantics.quantity.unitOfMeasure: 'dr_meins'   
   cast(sum(loadqty) as abap.int4) as LOADQTY,
   dr_meins
} group by bukrs, zreq_type, dlvrq, dr_meins

union all

select from zgtmmt4405
{
   key bukrs,
   key zreq_type,
   key dlvrq, 
     
   cast(sum(loadqty) as abap.int4) as LOADQTY,
   dr_meins
} group by bukrs, zreq_type, dlvrq, dr_meins
