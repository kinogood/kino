@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] SO Item 기준 유효 FKSTA 추출'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_GET_FKSTA
  as select from lips
{
  key vgbel,
  key vgpos,
      max(fksta) as fksta
}
where
      vgbel is not initial
  and fksta is not initial
  and fksta <> ' '
group by
  vgbel, 
  vgpos
