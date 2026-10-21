@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '납품서 품목별 구매입고(101) 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DELIV_GR_101
  as select from ZGTMM_CV_GET_MATDOC as A
    inner join matdoc as M
       on  M.mblnr = A.mblnr
       and M.mjahr = A.mjahr
       and M.zeile = A.zeile
{
  key A.DELNO,
  key A.DELITEM,
  key A.erfme,
      @Semantics.quantity.unitOfMeasure: 'erfme'
      sum(A.erfmg)            as grqty,
      count(distinct A.mblnr) as doccnt,
      min(A.budat)            as first_budat,
      max(A.budat)            as last_budat,
      min(M.mat_kdauf)        as so_gr,
      min(M.mat_kdpos)        as soitm_gr
}
where A.cancelled         = ''
  and A.reversal_movement = ''
  and A.DELNO            <> ''
group by A.DELNO, A.DELITEM, A.erfme
