@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '보세 창고 재고 SUMMARY'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BONDEDSUM 
as
select from ZGTMM_CV_BONDEDSTOCK
{ 
    key werks,
    key matnr,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    sum(BLMNG) as BDQTY, 
    MEINS
} where igrno = '' and bleta <= $session.user_date // and rptty = 'N'
group by werks,matnr,MEINS
/*
 select from ZGTMM_CV_BONDEDSTOCK
{
    key werks,
    key matnr,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    sum(blmng) as BDQTY,
    meins
} where igrno = ''
group by werks,matnr,meins
*/
