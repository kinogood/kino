@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주가공 납품서 꼬리표 최종 상태 처리'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_ZMMTI34LAST 
as select from ZGTMM_CV_ZMMTI34_AGG 
{
  key vbeln,
  key posnr,
  status      
} where status = 'C' 

union

select from ZGTMM_CV_ZMMTI34_AGG as A left outer join ZGTMM_CV_ZMMTI34_AGG as B on A.vbeln = B.vbeln and A.posnr = B.posnr and B.status = 'C'
{
  key A.vbeln,
  key A.posnr,
  case when B.status is not null then B.status
       else A.status end as STATUS      
} where A.status = 'D' 
