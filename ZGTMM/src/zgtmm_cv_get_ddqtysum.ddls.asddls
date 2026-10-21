@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송 요청 및 승인 수량 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DDQTYSUM 
as 
select from ZGTMM_CV_GET_DDQTYBASE 
{
 key zreq_type,
 key bukrs, 
 key vbeln,
 key posnr,
 key ebeln,
 key ebelp,
 @Semantics.quantity.unitOfMeasure: 'DR_MEINS' 
 sum(req_drqty) as REQ_DRQTY,
 @Semantics.quantity.unitOfMeasure: 'DR_MEINS' 
 sum(ZMM_DRQTY) as zmm_drqty,
 @Semantics.quantity.unitOfMeasure: 'DR_MEINS' 
 sum(ZVD_DRQTY) as zvd_drqty,
 dr_meins  
} where checkmm = 'X'
group by zreq_type, bukrs, vbeln, posnr, ebeln, ebelp, dr_meins

