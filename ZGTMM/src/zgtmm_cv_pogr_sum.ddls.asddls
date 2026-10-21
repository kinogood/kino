@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO 별 입고 총량'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_POGR_SUM 
as 
select from ekpo
{
 key ebeln,
 key ebelp,
       @Semantics.quantity.unitOfMeasure: 'MEINS'  
     cast(0 as menge_d) as INBQTY,
            @Semantics.quantity.unitOfMeasure: 'MEINS' 
     cast(0 as menge_d) as GRQTY,
     meins

}

/*
select from ZGTMM_CV_INDELIVERY_INFO
{
  key  ebeln,
  key  ebelp,
       @Semantics.quantity.unitOfMeasure: 'MEINS'  
       sum(lfimg) as INBQTY,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       sum(STOCK_QTY) as GRQTY,
       meins  
   
} group by ebeln,ebelp,meins


         

union all

select from ZGTMM_CV_POGR_INFO 
{
 key  ebeln,
 key  ebelp,
      cast(0 as abap.quan(13,3)) as INBQTY,
      sum(menge) as GRQTY,
      meins  
   
} group by ebeln,ebelp,meins*/
