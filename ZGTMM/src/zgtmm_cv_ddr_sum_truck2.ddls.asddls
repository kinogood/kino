@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '거래 명세서 정보 SUMMARY'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DDR_SUM_TRUCK2
as select from zgtmmt4403
{
   key bukrs,
   key zreq_type,
   key dlvrq, 
  @Semantics.quantity.unitOfMeasure: 'dr_meins'   
   cast(sum(loadqty) as abap.int4) as LOADQTY,
   dr_meins
} where printyn = 'Y'
group by bukrs, zreq_type, dlvrq, dr_meins

union all

select from zgtmmt4405
{
   key bukrs,
   key zreq_type,
   key dlvrq, 
     
   cast(sum(loadqty) as abap.int4) as LOADQTY,
   dr_meins
} where printyn = 'Y'
group by bukrs, zreq_type, dlvrq, dr_meins
