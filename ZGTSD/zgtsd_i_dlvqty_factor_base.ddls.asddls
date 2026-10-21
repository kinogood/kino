@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 납품문서 수량 조장 기초 데이터'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_DLVQTY_FACTOR_BASE
  as select from lips as a
    inner join   likp as c on  a.vbeln = c.vbeln
{
  key a.vbeln,
  key case when a.uecha is null or a.uecha = '000000'
           then a.posnr
           else a.uecha end as posnr,
  key a.posnr as posnr_vl,
      a.vgbel,
      a.vgpos,
      a.werks,
      a.matnr,
      a.arktx,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      a.lfimg,
      a.vrkme
}
where
  (
       c.vbtyp = 'J'
    or c.vbtyp = 'T' 
  )
