@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '생산 예정품 직송 요청 수량'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_ZGTMMT4411_SUM 
as select from zgtmmt4411 as A inner join zgtmmt4410 as B on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq
{
   key A.bukrs,
   key A.vbeln,
   key A.posnr,
   key A.ebeln,
   key A.ebelp,
   @Semantics.quantity.unitOfMeasure: 'dr_meins'      
   sum(A.req_drqty) as REQ_DRQTYSUM,
   A.dr_meins 
} where A.zmm_stat <> 'R' and A.zvd_stat <> 'R' and B.zreq_type = 'A' and B.zsd_stat = 'R'
group by A.bukrs, A.vbeln, A.posnr, A.ebeln, A.ebelp, A.dr_meins
