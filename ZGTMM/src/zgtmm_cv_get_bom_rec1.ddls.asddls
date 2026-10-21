@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOM 다중 조회 DATA1'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_BOM_REC1
with parameters 
    p_matnr : matnr,
    p_werks : werks_d,
    p_datum : datum
as
select from ZGTMM_CV_GET_BOM_COMPONENT(p_clnt: $session.client,p_matnr:  $parameters.p_matnr ,p_werks: $parameters.p_werks, p_datum: $parameters.p_datum ) as A
      inner join mbew as B on A.Component = B.matnr and A.Plant = B.bwkey
      inner join t001w as C on A.Plant = C.werks
      inner join t001k as D on C.bwkey = D.bwkey
      inner join tka02 as E on D.bukrs = E.bukrs
association [0..1] to tkkh2 as tKKH2 on $projection.kokrs = tKKH2.kokrs and $projection.hrkft = tKKH2.hrkft and tKKH2.koaty = '02' and  tKKH2.spras = $session.system_language
association [0..*] to ZGTSD_I_MaterialCharacteristic as S1 on $projection.Component = S1.matnr and S1.atnam = 'RW_CA_WIRE_TYPE'      
{
 key  A.Material ,
      A.Plant,            
      A.ProductionVersion,
      A.ValidityStartDate,
      A.ValidityEndDate,
      @Semantics.quantity.unitOfMeasure: 'BOMHeaderQtyUnit'       
      A.BOMHeaderQty,           
      A.BOMHeaderQtyUnit,
      A.BOMLevel,
      A.Parent,
      A.Component, 
      @Semantics.quantity.unitOfMeasure: 'BOMItemQtyUnit'       
      A.BOMItemQty,
      A.BOMItemQtyUnit,
      A.ComponentScrapInPercent,
      A.BOMValidityStartDate,
      A.BOMValidityEndDate,
      A.BaseUnit,
      A.CoProduct,
      B.hrkft,
      D.bukrs,
      E.kokrs,
      tkkh2.hrktx,
      S1.atwrt   
} 
 
