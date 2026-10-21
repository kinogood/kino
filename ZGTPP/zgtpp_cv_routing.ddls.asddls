@AbapCatalog.sqlViewName: 'ZGTCVROUTING'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 라우팅'
@ClientHandling.algorithm: #SESSION_VARIABLE
define view ZGTPP_CV_ROUTING as 
select from mapl
inner join plko
   on mapl.plnty = plko.plnty
  and mapl.plnnr = plko.plnnr
  and mapl.plnal = plko.plnal
  and plko.plnty = plko.plnty
inner join plpo
   on plko.plnnr = plpo.plnnr
inner join plas
   on plpo.plnty = plas.plnty
  and plpo.plnnr = plas.plnnr
  and plpo.plnkn = plas.plnkn
  and plko.plnal = plas.plnal
inner join plfl
   on plas.plnty = plfl.plnty
  and plas.plnnr = plfl.plnnr
  and plas.plnal = plfl.plnal
  and plas.plnfl = plfl.plnfl
inner join crhd
   on crhd.objty = 'A'
  and crhd.objid = plpo.arbid
inner join ZGTPP_CV_WRCC as wrcc
   on crhd.objty = wrcc.objty
   and crhd.objid = wrcc.objid
inner join crtx
   on crhd.objty = crtx.objty
  and crhd.objid = crtx.objid
  and crtx.spras = $session.system_language
{
    key mapl.matnr,
    key mapl.werks,
    key mapl.plnty,
    key mapl.plnnr,
    key mapl.plnal,
    key plfl.plnfl,
    plfl.flgat,
    mapl.datuv,
    plpo.vornr,
    plpo.arbid,
    crhd.arbpl,
    crtx.ktext,
    wrcc.kokrs,
    wrcc.kostl,
    wrcc.cctxt,
    plpo.meinh,
    plpo.bmsch,
    plpo.lar01,
    plpo.vge01,
    plpo.vgw01,
    plpo.lar02,
    plpo.vge02,
    plpo.vgw02,
    plpo.lar03,
    plpo.vge03,
    plpo.vgw03,
    plpo.lar04,
    plpo.vge04,
    plpo.vgw04,
    plpo.lar05,
    plpo.vge05,
    plpo.vgw05,
    plpo.lar06,
    plpo.vge06,
    plpo.vgw06,
    plpo./sapmp/met_lrch,
    plpo./sapmp/max_fertl,
    plpo./sapmp/fix_as_j,
    plpo./sapmp/fix_as_e,
    plpo./sapmp/fix_as_l,
    plpo.usr04,             //표준인원
    plpo.usr05,             //가동율
    plpo.usr06              //건조시간(분)
}
where mapl.plnty = 'N'
  and plfl.loekz = ''
  and plas.loekz = ''
  and plpo.loekz = ''
  and plko.loekz = ''
