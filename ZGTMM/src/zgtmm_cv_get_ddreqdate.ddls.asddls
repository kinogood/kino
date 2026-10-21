@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송 요청일 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DDREQDATE 
as select from zgtmmt4411 as a inner join zgtmmt4410 as B on a.bukrs = B.bukrs and a.dlvrq = B.dlvrq
{
  key a.bukrs,
  key a.ebeln,
  key a.ebelp,
  min(B.reqdate) as REQDATE
} where a.zvd_stat = 'P' and B.zreq_type = 'A' and B.zsd_stat = 'R'
group by a.bukrs,a.ebeln, a.ebelp

