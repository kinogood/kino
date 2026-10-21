@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '전자 결재 최종 상태'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_WELS_MAX_STATUS 
as select from zgtmmt1051 as A inner join ZGTMM_CV_GET_WELS_MAX  as WELS on A.legacyid = WELS.legacyid and A.appid = WELS.appid and A.zseq = WELS.ZSEQ
association [0..1] to dd07t as DD1 on $projection.status = DD1.domvalue_l and DD1.domname = 'ZGTD_WELSTATE' and DD1.ddlanguage = $session.system_language
{
 key A.legacyid,
 key A.appid,
     A.status,
     DD1.ddtext as STATUS_N,
     concat(A.erdat,A.ertim) as Timestamp
}
