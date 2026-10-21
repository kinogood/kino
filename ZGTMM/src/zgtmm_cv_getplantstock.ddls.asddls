@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트 별 재고 현황'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETPLANTSTOCK 
as 
select from nsdm_e_mard as A inner join zgtmmt4201 as B on A.werks = B.werks and A.lgort = B.lgort
                             inner join mara as C on A.matnr = C.matnr
                             
{
    
    key A.werks,
    key A.matnr,
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    sum(A.labst) as UNQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    cast(0 as abap.quan(13,3)) as BDQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    sum(A.labst) as TOQTY,       
    C.meins
} //where A.labst > 0
group by A.werks, A.matnr, C.meins

union

select from ZGTMM_CV_BONDEDSUM 
{
  key werks,
  key matnr,
  cast(0 as abap.quan(13,3)) as UNQTY,  
  BDQTY as BDQTY,
  BDQTY as TOQTY,    
  meins
}
