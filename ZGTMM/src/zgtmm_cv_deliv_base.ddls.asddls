@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '납품서 품목 기준 정보(유형 무관, 최종본)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DELIV_BASE
  as select from zgtmmt9410 as A
    inner join ZGTMM_CV_DELIV_MAXKEY as M
       on  A.system_id = M.system_id
       and A.delno     = M.delno
       and A.delitem   = M.delitem
       and A.zifkey    = M.zifkey
    left outer join ZGTMM_CV_DELIV_CANC as C
       on  A.system_id = C.system_id
       and A.delno     = C.delno
       and A.delitem   = C.delitem
{
  key A.zifkey,
  key A.system_id,
  key A.delno,
  key A.delitem,
  key A.werks,
      A.ebeln,
      A.ebelp,
      A.lgort,
      @Semantics.quantity.unitOfMeasure: 'meins'
      A.menge,
      A.meins,
      A.budat,
      A.emlif,
      A.licha,
      A.hsdat,
      A.status,
      A.doc_url,
      A.potype,
      A.delclose,
      A.deltype,
      case when C.xkey is not null and C.xkey > A.zifkey
           then cast('X' as abap.char(1))
           else cast('' as abap.char(1)) end as cancelled
}
