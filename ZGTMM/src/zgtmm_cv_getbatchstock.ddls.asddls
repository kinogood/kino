@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '배치 재고 조회(SINGLE 여부 포함)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETBATCHSTOCK 
as 
select from mch1 as A inner join nsdm_e_mchb as B on A.matnr = B.matnr and A.charg = B.charg
                      inner join mara as C on B.matnr = C.matnr
{
   key A.matnr,
   key A.charg,
   key B.werks,
   key B.lgort,
   A.xpcbt, 
   @Semantics.quantity.unitOfMeasure: 'meins'
   B.clabs,
   C.meins
} where B.clabs > 0
