@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '제품 규격 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_STD_SPEC 
as select from ZGTMM_CV_GET_STD_RAW   
{
   key ebeln,
   key ebelp,
       matnr,
       txz01,
       c3 as name,
       case when c2 <> '' then
           concat(concat(c1,'+'),c2)
       else
           c1
       end as STD_SPEC,
       color,
       c4 as specno,       
       @Semantics.quantity.unitOfMeasure: 'meins'  
       length,
       meins,
       drqty
} 

