@AbapCatalog.sqlViewName: 'ZGTCVWKCC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '작업장별 코스트센터'
@ClientHandling.algorithm: #SESSION_VARIABLE
define view ZGTPP_CV_WRCC as 
select from crco
inner join cskt
   on  crco.kokrs = cskt.kokrs
   and crco.kostl = cskt.kostl
   and cskt.spras = $session.system_language
{
    key crco.objty,
    key crco.objid,
    crco.kokrs,
    crco.kostl,
    max(cskt.ktext) as cctxt
}
where cskt.datbi >= $session.system_date
group by crco.objty, crco.objid, crco.kokrs, crco.kostl
