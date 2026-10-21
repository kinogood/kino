@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송 요청 일자 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DD_SUM 
as select from zgtmmt4411 as A inner join zgtmmt4410 as b on A.bukrs = b.bukrs and A.dlvrq = b.dlvrq
{
   key A.ebeln,
   key A.ebelp,
       min(b.ar_date) as ar_date
} where b.zreq_type = 'A' and A.zvd_stat = 'A' and b.ar_date >= $session.user_date and b.zsd_stat = 'R'
group by A.ebeln, A.ebelp
