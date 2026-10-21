@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 검사 완료 건수'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_QI_RESULT_QTY 
as select from zgtmmt4402
{
   key bukrs,
   key ebeln,
   key ebelp,
   count(*) as QI_RESULT_QTY 
} where zinspres <> '' 
group by bukrs, ebeln, ebelp
