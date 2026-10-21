@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '특별재고현황조회-합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SP_STOCKLIST_SUM 
as select from ZGTMM_CV_SP_STOCKLIST 
{
   key matnr,
   key werks,
   key lgort,
   key charg,
       meins,   
       @Semantics.quantity.unitOfMeasure: 'MEINS'  
       sum(LABST) as LABST,   
       @Semantics.quantity.unitOfMeasure: 'MEINS'  
       sum(INSME) as INSME   
} where charg <> ''
group by matnr, werks,lgort,charg,meins

union all
select from ZGTMM_CV_SP_STOCKLIST 
{
   key matnr,
   key werks,
   key lgort,
   key cast('' as charg_d) as charg,
       meins,   
       sum(LABST) as LABST,   
       sum(INSME) as INSME   
} 
group by matnr, werks,lgort,meins
