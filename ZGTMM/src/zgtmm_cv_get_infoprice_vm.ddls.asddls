@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '인포레코드 기간 별 유효 건수(업체/자재 별)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_INFOPRICE_VM 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_date : vdm_v_start_date
as select from ZGTMM_CV_GET_INFOPRICE
{
  key matnr,  
  key lifnr,
  key ekorg,
  key werks,
  key esokz,
  count(*) as conqty  
} where datab <= $parameters.p_date and datbi >= $parameters.p_date and EINA_LOEKZ = '' and EINE_LOEKZ = ''
group by matnr,lifnr,ekorg,werks,esokz
