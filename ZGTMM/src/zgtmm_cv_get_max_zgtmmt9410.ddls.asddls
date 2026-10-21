@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GPRO DELIVERY 최종 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_MAX_ZGTMMT9410 
as select from zgtmmt9410 as A left outer join zgtmmt9410 as B on A.delno = B.delno and A.delitem = B.delitem and A.ebeln = B.ebeln and A.ebelp = B.ebelp and B.status ='X' 

{
  key A.delno,
  key A.delitem,
      A.ebeln,
      A.ebelp,
      case when B.delno is not null then cast('X' as abap.char(1)) else cast('' as abap.char(1)) end as CHKSTATUS
} where A.status <> 'X' and A.deltype = ''

group by A.delno, A.delitem, A.ebeln, A.ebelp, A.status, B.delno
