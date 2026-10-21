@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '월별 PO 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PODATA_MON 
as select from ekpo as A inner join ekko as B on A.ebeln = B.ebeln
{
  key A.matnr,
  key B.lifnr,
  key B.ekorg,
       max(B.bedat) as BEDAT
} where A.loekz = '' and B.frgzu = 'X'
group by A.matnr, B.lifnr, B.ekorg
