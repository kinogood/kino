@AbapCatalog.sqlViewName: 'ZGTCV_STOCKVAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '재고 현황 + 자재 특성'
@ClientHandling.algorithm: #SESSION_VARIABLE
define view ZGTPP_CV_STOCK_VAL_LIST as 
select from ZGTMM_CV_GET_STOCKLIST as stock
inner join ZGTPP_CV_MASTVAL as mast
    on stock.matnr = mast.matnr
    and stock.werks = mast.werks
left outer join ZGTMM_CV_TAG_AGG as tag
    on stock.werks = tag.werks
    and stock.matnr = tag.matnr
    and stock.CHARG = tag.charg
left outer join ZGTPP_CV_BM_LENGTH as bmlen
    on  stock.matnr = bmlen.matnr
    and stock.werks = bmlen.werks
    and stock.CHARG = bmlen.charg
{
   key stock.matnr,
   key stock.werks,
   key stock.lgort,
   key stock.CHARG,
   key mast.spg,
   key mast.PdCaProcCode as proccode,
   key mast.PdCaProcName as procname,
   stock.LIFNR,
   stock.PSPNR,
   stock.kunnr,
   stock.vbeln,
   stock.posnr,
   stock.meins,
   @Semantics.quantity.unitOfMeasure: 'meins'
   stock.labst,
   @Semantics.quantity.unitOfMeasure: 'meins'
   stock.insme,
   @Semantics.quantity.unitOfMeasure: 'meins'
   stock.speme,   
   tag.TAGNR,
   mast.mmsta,
   mast.maktx,
   mast.cuobj,
   bmlen.cuobj_bm,   
   cast(bmlen.mlength as abap.dec(12,3)) as mlength   
}
