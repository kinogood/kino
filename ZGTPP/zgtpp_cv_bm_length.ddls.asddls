@AbapCatalog.sqlViewName: 'ZGTIBMLENGTH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Batch Length'
@ClientHandling.algorithm: #SESSION_VARIABLE
define view ZGTPP_CV_BM_LENGTH as 
select from zgticuobjbm as bmobj
inner join  ausp
    on  bmobj.mandt = ausp.mandt
    and bmobj.cuobj_bm = ausp.objek
    and ausp.klart = '023'
inner join cabn
    on ausp.mandt = cabn.mandt
    and ausp.atinn = cabn.atinn
    and cabn.atnam = 'SAP_MILLCA_LENGTH'
{
    key bmobj.matnr,
    key bmobj.werks,
    key bmobj.charg,
    bmobj.cuobj_bm,
    ausp.dec_value_from as mlength
}
