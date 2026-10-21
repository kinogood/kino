@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '견적/단가 계약 구성 정보 조회(기준일자 기준 최신)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_MAX_ZGTMMT1040 
as select from zgtmmt1040
{
   key matnr,
   key lifnr,
   key ekorg,
   key werks,
   key datab,
   key datbi,
       ptype,
   max(cdate) as CDATE
} where ptype = 'A' and esokz = '0'
group by matnr,lifnr,ekorg,esokz,werks, ptype, datab, datbi
