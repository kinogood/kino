/*&---------------------------------------------------------------------*
*&          MODIFICATION LOG
*&---------------------------------------------------------------------*
*   Date      Developer   Description
*----------------------------------------------------------------------*
* 2026.01.26  zlsgpp5     ATTR01 ~ ATTR10 필드 추가. 
*----------------------------------------------------------------------*/
@AbapCatalog.sqlViewName: 'ZGTCVSALESPLAN'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '판매계획'
@ClientHandling: {
    type: #CLIENT_DEPENDENT,
    algorithm: #AUTOMATED
}
define view ZGTPP_CV_SALESPLAN
  as select from    zsdt_d365_021              as _sp
    inner join      ZGTPP_CV_SALESPLAN_MAXWEEK as _maxweek on  _sp.cycltype = _maxweek.cycltype
                                                           and _sp.vkbur    = _maxweek.vkbur
                                                           and _sp.itemname = _maxweek.itemname
                                                           and _sp.zpjno    = _maxweek.zpjno
                                                           and _sp.spart    = _maxweek.spart
                                                           and _sp.week     = _maxweek.maxw
    left outer join kna1                       as _kna1    on _sp.kunnr = _kna1.kunnr
    left outer join zgtppt2080                 as _pp      on  _sp.cycltype = _pp.cycltype
                                                           and _sp.vkbur    = _pp.vkbur
                                                           and _sp.itemname = _pp.spec
                                                           and _sp.zpjno    = _pp.zpjno
                                                           and _sp.vbeln    = _pp.vbeln
                                                           and _sp.posnr    = _pp.posnr
                                                           and _sp.pltype   = _pp.pltype
                                                           and _pp.delfl    = ''
    left outer join zsd0106t                   as _pjt     on  _sp.zpjno = _pjt.zpjno
                                                           and _sp.kunnr = _pjt.kunnr
{
  key _sp.cycltype,
  key _sp.vkbur,
  key _sp.week,
  key _sp.itemname                as spec,
  key _sp.zpjno,
  key _sp.vbeln,
  key _sp.posnr,
  key _sp.spart,

      _pp.plnid,
      _pjt.zptxt,

      max(_sp.pltype)             as pltype,
      min(_sp.basemonth)          as basemonth,
      max(_sp.land1)              as land1,
      max(_sp.kunnr)              as kunnr,
      max(_kna1.name1)            as name1,
      max(_sp.vrkme)              as vrkme,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      sum(_sp.quantity)           as org_quant_dp,
      //여장율 감안
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      sum(case when _pp.alenr is null then _sp.quantity_dp
               when _pp.alenr = 0 then _sp.quantity_dp
               else _sp.quantity + (division(_pp.alenr,100,3) * _sp.quantity)
               end)               as quantity_dp,
      max(_sp.matnr)              as matnr,
      max(_sp.oppstatus)          as oppstatus,
      max(_sp.dptype)             as dptype,
      max(_sp.businessunitidcode) as businessunitidcode,
      max(_sp.businessunitidname) as businessunitidname,
      max(_sp.pernr)              as pernr,
      max(_sp.attr01)             as attr01, //2026.01.26.zlsgpp5.add.
      max(_sp.attr02)             as attr02, //2026.01.26.zlsgpp5.add.
      max(_sp.attr03)             as attr03, //2026.01.26.zlsgpp5.add.
      max(_sp.attr04)             as attr04, //2026.01.26.zlsgpp5.add.
      max(_sp.attr05)             as attr05, //2026.01.26.zlsgpp5.add.
      max(_sp.attr06)             as attr06, //2026.01.26.zlsgpp5.add.
      max(_sp.attr07)             as attr07, //2026.01.26.zlsgpp5.add.
      max(_sp.attr08)             as attr08, //2026.01.26.zlsgpp5.add.
      max(_sp.attr09)             as attr09, //2026.01.26.zlsgpp5.add.
      max(_sp.attr10)             as attr10  //2026.01.26.zlsgpp5.add.
}
group by
  _sp.pltype,
  _sp.cycltype,
  _sp.vkbur,
  _sp.week,
  _sp.itemname,
  _sp.zpjno,
  _sp.vbeln,
  _sp.posnr,
  _sp.spart,
  _pp.plnid,
  _pjt.zptxt
