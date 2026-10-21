@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 출하요청 수량 합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_SUM_ZLET0401
  as select from zlet0401 as a
{
  key a.vbeln,
  key a.posnr,

      case when sum(a.indqty) > 0
           then cast( sum(a.indqty) as abap.dec(13,3) )
           else cast( sum(a.dlrmg)  as abap.dec(13,3) )
      end as req_qty
      //    coalesce( cast( sum(indqty) as abap.int4(10,0) ) ,
      //              cast(sum(a.dlrmg) as abap.int4(10,0) ) ) as req_qty
}
where
  a.lvorm <> 'X'
group by
  a.vbeln,
  a.posnr 
