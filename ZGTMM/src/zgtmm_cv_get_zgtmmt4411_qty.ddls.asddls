@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송 요청 수량 합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_ZGTMMT4411_QTY 
as select from zgtmmt4410 as A inner join zgtmmt4411 as B on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq 
{
  key B.vbeln,
  key B.posnr,
  key B.ebeln,
  key B.ebelp,
  @Semantics.quantity.unitOfMeasure: 'DR_MEINS' 
  sum(B.req_drqty) as REQ_DRQTY,  
  B.dr_meins
} where A.zsd_stat = 'R' and ( B.zmm_stat = '' or B.zmm_stat = 'A' ) and (B.zvd_stat <> 'R')

group by B.vbeln, B.posnr, B.ebeln, B.ebelp, B.dr_meins
