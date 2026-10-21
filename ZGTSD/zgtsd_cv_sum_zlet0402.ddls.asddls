@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 출하요청 연계 납품수량 합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_SUM_ZLET0402
  as select from zlet0402                   as a
    inner join   zlet0401                   as b on  a.dlvrq = b.dlvrq
                                                 and a.vbeln = b.vbeln
                                                 and a.posnr = b.posnr
  //inner join lips     as c on a.vbeln = c.vgbel and a.posnr = c.vgpos and c.lfimg > 0
    inner join   ZGTSD_CV_GET_DLVQTY_FACTOR as d on  a.vbeln = d.vgbel
                                                 and a.posnr = d.vgpos
                                                 and a.vgbel = d.vbeln
                                                 and a.vgpos = d.posnr
{
  key a.vbeln,
  key a.posnr,
      //a.vgbel,
      //a.vgpos,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      //      coalesce( cast(sum(d.factor) as abap.dec(13,3)),
      //                cast(sum(d.lfimg)  as abap.dec(13,3)) ) as reqdo_qty,
      case when sum(d.factor) > 0
           then cast(sum(d.factor) as abap.dec(13,3))
           else cast(sum(d.lfimg)  as abap.dec(13,3)) end as reqdo_qty,

      d.vrkme
}
where
  b.lvorm <> 'X'
group by
  a.vbeln,
  a.posnr,
  d.vrkme 
