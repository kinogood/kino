@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPRO 납품서 품목별 최종 ZIFKEY(취소행 제외)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DELIV_MAXKEY
  as select from zgtmmt9410
{
  key system_id,
  key delno,
  key delitem,
      max(zifkey) as zifkey
}
where system_id = 'KSRM'
  and status   <> 'X'
group by system_id, delno, delitem
