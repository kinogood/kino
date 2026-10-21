@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPRO DELIVERY 발행 현황 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_SRM_DELIVERY_INFO 
as select from zgtmmt9410 as A inner join ZGTMM_CV_GET_MAX_ZGTMMT9410 as B on A.delno = B.delno and A.delitem = B.delitem
{
  key A.ebeln,
  key A.ebelp 
} where B.CHKSTATUS = '' and A.deltype = ''
group by A.ebeln, A.ebelp
