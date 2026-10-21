@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송의뢰 접수 건수'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DDR_QTY_SUM2 

as select from zgtmmt4410 as A inner join zgtmmt4411 as B on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq
{
   key A.bukrs,
   key A.dlvrq,
   @Semantics.quantity.unitOfMeasure: 'dr_meins'   
   cast(sum(B.req_drqty) as abap.int4) as REQ_COUNT, 
   B.dr_meins
} where B.zmm_stat = 'A' and  A.zreq_type = 'A' and A.zsd_stat = 'R' 
group by A.bukrs, A.dlvrq,  B.dr_meins

union all

select from zgtmmt4410 as A inner join zgtmmt4412 as B on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq
{
   key A.bukrs,
   key A.dlvrq,  
   cast(sum(B.req_drqty) as abap.int4) as REQ_COUNT, 
   B.dr_meins
} where B.zmm_stat = 'A' and  A.zreq_type = 'B' and A.zsd_stat = 'R' 
group by A.bukrs, A.dlvrq,  B.dr_meins

