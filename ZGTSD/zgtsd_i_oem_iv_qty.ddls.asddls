@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] OEM 거래명세서 발행 수량'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_OEM_IV_QTY

  as select from    zgtmmt4403          as _dreq_a -- 생산예정품직송
    left outer join ZGTSD_CV_GET_VCOFSO as _char on  _dreq_a.vbeln = _char.vbeln
                                                 and _dreq_a.posnr = _char.posnr

{
  key cast(_dreq_a.vbeln as vbeln_va preserving type ) as vbeln,
  key cast(_dreq_a.posnr as posnr_va preserving type ) as posnr,
      
      cast(
          case when sum(_dreq_a.loadqty * _char.LENGTH) > 0
               then sum(_dreq_a.loadqty * _char.LENGTH)
               else sum(_dreq_a.loadqty)
          end
      as abap.dec(15,3) )                            as loadqty


}
where
  _dreq_a.printyn = 'Y' -- 거래명세서 발행 
group by
  _dreq_a.vbeln,
  _dreq_a.posnr,
  _dreq_a.dr_meins

union

select from       zgtmmt4405          as _dreq_b -- 매입보관품직송
  left outer join ZGTSD_CV_GET_VCOFSO as _char on  _dreq_b.vbeln = _char.vbeln
                                               and _dreq_b.posnr = _char.posnr
{
  key cast(_dreq_b.vbeln as vbeln_va preserving type) as vbeln,
  key cast(_dreq_b.posnr as posnr_va preserving type) as posnr,

      cast(
          case when sum(_dreq_b.loadqty * _char.LENGTH) > 0
               then sum(_dreq_b.loadqty * _char.LENGTH)
               else sum(_dreq_b.loadqty)
          end
      as abap.dec(15,3))                              as loadqty
}
where
  _dreq_b.printyn = 'Y'
group by
  _dreq_b.vbeln,
  _dreq_b.posnr,
  _dreq_b.dr_meins
