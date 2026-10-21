@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 납품문서 조장 수 판매오더기준 합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_SUM_DLVQTY_FACTOR 
//    as select from vbap as a inner join ZGTSD_CV_GET_DLVQTY_FACTOR as b 
//                                on a.vbeln = b.vgbel
//                               and a.posnr = b.vgpos 
    as select from ZGTSD_CV_GET_DLVQTY_FACTOR as a inner join vbap  as b 
                                on a.vgbel = b.vbeln
                               and a.vgpos = b.posnr 
{
    key b.vbeln,
    key b.posnr,
    
    @Semantics.quantity.unitOfMeasure: 'vrkme'
    cast(sum(a.factor) as abap.int4(10,0) ) as sum_factor,
    @Semantics.quantity.unitOfMeasure: 'vrkme'
    sum(a.lfimg) as sum_qty,
    
    a.vrkme    
} group by b.vbeln, b.posnr, a.vrkme 
