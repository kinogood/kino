@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BL 입고 수량 합계-MM00003'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BLGRQTY_SUM 
as 
select from ztitgrp as A inner join ztitgrk as B on A.igrno = B.igrno
{
    key A.iblno,
    key A.iblit,
    @Semantics.quantity.unitOfMeasure: 'MEINS'       
    sum(A.grmng) as QTY,
    A.meins
} where B.mblnr <> ''
group by A.iblno, A.iblit, A.meins
 