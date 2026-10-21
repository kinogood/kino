@AbapCatalog.sqlViewName: 'ZGTCV_SCR_STOCK'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '소재 SCR 등급별 재고'
define view ZGTPP_CV_SCR_STOCKVAL as 
select from ZGTMM_CV_GET_STOCKLIST as _stock
 inner join ZGTPP_CV_CUOBJ_BM as _objbm
    on _stock.matnr = _objbm.matnr
   and _stock.werks = _objbm.werks
   and _stock.CHARG = _objbm.charg
 inner join ausp as _ausp
    on _objbm.cuobj_bm = _ausp.objek
 inner join cabn as _cabn
    on _ausp.atinn = _cabn.atinn
{
    
    key _stock.matnr,
    key _stock.werks,
    key _stock.lgort,
    key _stock.CHARG,
    key _ausp.atwrt,
    _stock.meins,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    _stock.labst,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    _stock.insme,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    _stock.speme
}
where _cabn.atnam = 'BT_AA_GRADE'
  and _ausp.klart = '023'
    
