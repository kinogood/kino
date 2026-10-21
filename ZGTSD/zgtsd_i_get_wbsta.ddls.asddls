@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] SO Item 기준 유효 WBSTA 추출'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_GET_WBSTA
  as select from lips as I
    inner join   likp as h on I.vbeln = h.vbeln
{
  key I.vgbel,
  key I.vgpos,
  key I.vbeln,
  key I.posnr,
      cast(max(I.wbsta) as wbsta preserving type )         as wbsta,
      cast(max(h.wadat_ist) as wadat_ist preserving type ) as wadat_ist
}
where
       I.vgbel is not initial
  and  I.wbsta is not initial
  and  I.wbsta <> ' '
  and(
       h.vbtyp =  'J'
    or h.vbtyp =  'T'
  )
group by
  I.vgbel,
  I.vgpos,
  I.vbeln,
  I.posnr 
