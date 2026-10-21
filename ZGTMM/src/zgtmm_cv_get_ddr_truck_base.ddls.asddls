@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '배차 정보 기본 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DDR_TRUCK_BASE 
as select from zgtmmt4403
{
   key bukrs,
   key zreq_type,
   key vbeln,
   key posnr,
   key dlvrq,
   key ebeln,
   key ebelp,
  @Semantics.quantity.unitOfMeasure: 'dr_meins'
   sum(loadqty) as LOADQTY,
   dr_meins
} where zdoc_date <> '00000000'
group by bukrs, zreq_type, vbeln,posnr, ebeln, ebelp, dlvrq, dr_meins

union all

select from zgtmmt4405
{
   key bukrs,
   key zreq_type,
   key vbeln,
   key posnr,
   key dlvrq,
   key cast('' as ebeln) as EBELN,
   key cast('' as ebelp) as EBELP,
   sum(loadqty) as LOADQTY,
   dr_meins
} where zdoc_date <> '00000000'
group by bukrs, zreq_type, vbeln,posnr, dlvrq, dr_meins
