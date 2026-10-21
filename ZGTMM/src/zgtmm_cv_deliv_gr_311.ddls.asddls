@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '납품서 품목별 MES 재고이전 입고(311) 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DELIV_GR_311
  as select from zgtmmt9425 as P
    inner join zgtmmt9000 as S
       on  S.zifkey    = P.zifkey
       and S.system_id = P.system_id
    inner join zgtmmt9423 as R
       on  R.zifkey      = P.zifkey
       and R.system_id   = P.system_id
       and R.ebeln       = P.ebeln
       and R.ebelp       = P.ebelp
       and R.dr_label_no = P.dr_label_no
    inner join matdoc as M
       on  M.mblnr = R.mblnr
       and M.mjahr = R.mjahr
{
  key P.delno,
  key P.delitem,
  key M.erfme,
      @Semantics.quantity.unitOfMeasure: 'erfme'
      sum(M.erfmg)                   as grqty,
      count(distinct P.dr_label_no)  as lblcnt,
      count(distinct M.mblnr)        as doccnt,
      min(M.budat)                   as first_budat,
      max(M.budat)                   as last_budat,
      min(M.mat_kdauf)               as so_gr,
      min(M.mat_kdpos)               as soitm_gr
}
where S.zifno            = 'MM00035'
  and S.zstat            = 'S'
  and R.mblnr           <> ''
  and M.bwart            = '311'
  and M.shkzg            = 'S'
  and M.cancelled        = ''
  and M.reversal_movement = ''
group by P.delno, P.delitem, M.erfme
