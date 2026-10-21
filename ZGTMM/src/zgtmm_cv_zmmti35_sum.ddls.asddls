@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주가공 꼬리표 최종 상태 처리'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_ZMMTI35_SUM 
as 
select from ZGTMM_CV_ZMMTI35CHECK
{
  key vbeln,
  key posnr,
  key matnr,
  key tagnr,
  status   
} where status = 'C'

union

select from ZGTMM_CV_ZMMTI35CHECK as A
       left outer join ZGTMM_CV_ZMMTI35CHECK as B on A.vbeln = B.vbeln and A.posnr = B.posnr and A.matnr = B.matnr
                 and A.tagnr = B.tagnr and B.status ='C'
               

{
  key A.vbeln,
  key A.posnr,
  key A.matnr,
  key A.tagnr,
  case when B.status is not initial then cast('C' as abap.char(1))
       else A.status end as STATUS   
} where A.status = 'D'
