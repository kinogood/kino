@AbapCatalog.sqlViewName: 'ZGTICUOBJBM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Batch objct number'
define view ZGTPP_CV_CUOBJ_BM as
select from mcha
inner join mch1
   on mcha.matnr = mch1.matnr
  and mcha.charg = mch1.charg
{
    key mcha.matnr,
    key mcha.werks,
    key mcha.charg,
    (case when mcha.cuobj_bm = '000000000000000000' then mch1.cuobj_bm else mcha.cuobj_bm end) as cuobj_bm    
}
