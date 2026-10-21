@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MTO 구매오더 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PODATA_BYSO 
as select from vbap as A inner join ekkn as B on A.vgbel = B.vbeln and A.vgpos = B.vbelp
{
  key A.vbeln,
  key A.posnr,
  key A.werks,
      B.ebeln,
      B.ebelp,
      CONCAT(B.ebeln,B.ebelp) as CHECKPO 
} where (A.werks = '6591' or A.werks = '6691')  and B.zekkn = '01'

union all
select from vbap as A inner join ekkn as B on A.vbeln = B.vbeln and A.posnr = B.vbelp
{
  key A.vbeln,
  key A.posnr,
  key A.werks,
      B.ebeln,
      B.ebelp,
      CONCAT(B.ebeln,B.ebelp) as CHECKPO  
} where A.werks <> '6591' and A.werks <> '6691' and B.zekkn = '01'
