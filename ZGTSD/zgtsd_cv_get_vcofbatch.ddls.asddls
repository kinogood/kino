@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] Batch 구성형 특성값'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_GET_VCOFBATCH 
  as select from    mch1        as m
    inner join      ausp        as a on m.cuobj_bm = a.objek
    inner join      cabn        as b on  a.atinn = b.atinn
                                     and a.adzhl = b.adzhl
    inner join      cabnt       as t on  b.atinn = t.atinn
                                     and t.spras = $session.system_language
    left outer join      nsdm_e_mchb as c on  m.matnr = c.matnr
                                     and m.charg = c.charg
                                     and c.clabs > 0
    inner join      mara        as d on m.matnr = d.matnr
    left outer join zgtppt1010  as e on  a.atwrt       = e.fld_02
                                     and e.module_kind = 'SD'
                                     and e.codegrp     = '1001'
{
  key m.matnr,
  key m.charg,
      c.werks,
      c.lgort,
      @Semantics.quantity.unitOfMeasure: 'meins'
      c.clabs,
      d.meins,
      b.atinn,
      b.atnam,
      t.atbez,
      b.atfor,

      a.klart,
      a.atwrt,
      e.fld_01          as grade,
      e.fld_03          as grade_t,

      fltp_to_dec( a.atflv as abap.dec(13,3) ) as atflv,

      case when a.atflv is null or a.atflv = 0
           then cast(0 as abap.dec(13,3))
           else division(
                cast(c.clabs as abap.dec(13,3)),
                cast( a.atflv as abap.dec(13,3)),
                3 ) end as factor,

      a.atflb
}
where m.lvorm = ''
