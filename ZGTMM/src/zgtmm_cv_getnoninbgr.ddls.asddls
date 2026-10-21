@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'INBOUND DELIVERY 미사용 GR 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETNONINBGR 
as 
select from ekbe as A inner join ekpo as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
{ 
  key A.ebeln,
  key A.ebelp,
  @Semantics.quantity.unitOfMeasure: 'MEINS'        
  case when A.shkzg = 'H' then A.menge * -1
       else A.menge end as MENGE,
  B.meins
} where A.vgabe = '1' 
/*
select from ekbe
{
  key ebeln,
  key ebelp,
  key zekkn,
  key gjahr,
  key belnr,
  key buzei,
  xblnr   
} where vgabe = '1'

except

select from ekbe as A inner join likp as B on A.xblnr = B.vbeln
{
  key A.ebeln,
  key A.ebelp,
  key A.zekkn,
  key A.gjahr,
  key A.belnr,
  key A.buzei,
  A.xblnr   
} where A.vgabe = '1'
*/
