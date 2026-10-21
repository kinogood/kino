@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 검사 요청 건수'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_QI_REQTY 
as select from zgtmmt4402
{
   key bukrs,
   key ebeln,
   key ebelp,
   count(*) as QI_REQ_QTY 
} group by bukrs, ebeln, ebelp
