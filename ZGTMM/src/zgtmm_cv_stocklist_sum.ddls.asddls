@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '저장위치별 재고 합계(자재 별 MERGE)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_STOCKLIST_SUM 
as select from ZGTMM_CV_STOCKLIST
{
    key matnr,
    key werks,
    key lgort,
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    sum(UNQTY) as UNQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    sum(QIQTY) as QIQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    sum(BLQTY) as BLQTY,
    meins,
    xchpf
        
} group by matnr, werks, lgort,  meins,  xchpf
