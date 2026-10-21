@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '거래명세서 수량 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DDR_QTY_DO 
as select from ZGTMM_CV_DDR_SUM_TRUCK2 as A inner join zgtmmt4411 as B on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq  
                                            inner join zgtmmt4410 as C on B.bukrs = C.bukrs and B.dlvrq = C.dlvrq
{
   key A.bukrs,
   key A.zreq_type,
   key A.dlvrq,

   @Semantics.quantity.unitOfMeasure:'DR_MEINS'   
   cast(sum(A.LOADQTY) as abap.int4) as LOADQTY,
   A.dr_meins
} where C.zsd_stat = 'R' and B.zvd_stat = 'A'
group by A.bukrs, A.dlvrq, A.dr_meins, A.zreq_type

union all

select from ZGTMM_CV_DDR_SUM_TRUCK2 as A inner join zgtmmt4412 as B on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq 
                                            inner join zgtmmt4410 as C on B.bukrs = C.bukrs and B.dlvrq = C.dlvrq
{
   key A.bukrs,
   key A.zreq_type,
   key A.dlvrq,
   cast(sum(A.LOADQTY) as abap.int4) as LOADQTY,
   A.dr_meins
}  where C.zsd_stat = 'R'  and B.zvd_stat = 'A'
group by A.bukrs, A.dlvrq,  A.dr_meins, A.zreq_type
