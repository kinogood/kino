@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '송장 전표 반제 리스트 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_AP_CLDOC 
as select from bsak_view 
{
 key bukrs,
 key gjahr,
 key belnr,
 max(buzei) as BUZEI,
     budat,
     bldat,
     cpudt,
     augdt,
     augbl
} group by bukrs, gjahr, belnr, budat, bldat, cpudt, augdt, augbl
