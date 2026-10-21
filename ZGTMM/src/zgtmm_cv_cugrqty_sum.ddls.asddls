@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '통관 입고 수량 합계-MM00004'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_CUGRQTY_SUM 
as 
select from ztitgrp as A inner join ztitgrk as B on A.igrno = B.igrno
{
    key A.iccno,
    key A.iccit,
    @Semantics.quantity.unitOfMeasure: 'MEINS'       
    sum(A.grmng) as QTY,
    A.meins  
} where B.mblnr <> ''
group by A.iccno, A.iccit, A.meins
