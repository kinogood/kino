@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '전자결재 최종 상태'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_WELS_STATUS 
as select from zgtmmt1050 as A
association [0..1] to ZGTMM_CV_GET_WELS_MAX_STATUS   as WELS on $projection.legacyid = WELS.legacyid and $projection.appid = WELS.appid
{
  key formid,
  key legacyid,
      bukrs,
      pernr,
      tcode,
      appid,
      case when WELS.appid is null then cast('' as abap.char(1))
           else WELS.status end as STATUS,
      case when WELS.appid is null then cast('' as abap.char(1))
           else WELS.STATUS_N end as STATUS_N             
}
