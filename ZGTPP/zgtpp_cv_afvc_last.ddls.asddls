@AbapCatalog.sqlViewName: 'ZGTIAFCVLAST'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '생산 오더 작업 Last'
@ClientHandling.algorithm: #SESSION_VARIABLE
define view ZGTPP_CV_AFVC_LAST as
select from afvc
{
    mandt,
    aufpl,
    max(vornr) as vornr,
    max(arbid) as arbid
}
where plnty = 'N'
  and aplfl = '000000'
  and rueck <> '0000000000'
group by mandt, aufpl
