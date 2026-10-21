@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] Class 300 특성 값 조회'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_MATNR_CHAR_300
  as select from marc       as a
    inner join   ibin       as b on  a.cuobj = b.instance
                                 and b.valto = 99991231235959
    inner join   ibinvalues as c on b.in_recno = c.in_recno
    inner join   ibsymbol   as d on c.symbol_id = d.symbol_id
    inner join   cabn       as e on d.atinn = e.atinn
    
    association[1..1] to makt as f on a.matnr = f.matnr
                                   and f.spras = $session.system_language

{
  key a.matnr,
  key a.werks,
      
      f.maktx,

      max( case when e.atnam = 'PD_CA_COLOR_BASE' then d.atwrt else null end )      as color,
      max( case when e.atnam = 'PD_CA_COLOR_STRIPE' then d.atwrt else null end )    as stripe_color,
      max( case when e.atnam = 'PD_CA_COLOR_STRIPE_NO' then d.atwrt else null end ) as stripe_cnt,
      max( case when e.atnam = 'PD_CA_SPEC_NO' then d.atwrt else null end )         as specno,
      max( case when e.atnam = 'PD_CA_DESIGN_NO' then d.atwrt else null end )       as design_no,
      max( case when e.atnam = 'MS-AUSP-ZSPART' then d.atwrt else null end )        as spart_gaon

}
where
  a.lvorm <> 'X'
group by
  a.matnr, a.werks, f.maktx
