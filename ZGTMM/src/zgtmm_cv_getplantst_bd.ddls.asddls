@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트 별 재고 + 보세 창고 재고 현황'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETPLANTST_BD 
as select from ZGTMM_CV_GETPLANTSTOCK 
{
    
    key werks,
    key matnr,
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    sum(UNQTY) as UNQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    sum(BDQTY) as BDQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    sum(TOQTY) as TOQTY,
    meins
} 
group by werks, matnr, meins
