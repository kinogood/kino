@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SRM PO 전송 특성 변경 정보 비교'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SRMPO_CHANGECHAR 
as select from ZGTMM_CV_SRMPO_IF_LOG_L as A inner join zgtmmt9433 as B on A.zifkey = B.zifkey and A.ebeln = B.ebeln

{
   key    B.zifkey,
   key    B.ebeln,
   key    B.ebelp,
          B.atnam,
          B.atbez,
          B.atwrt,
          B.atwrt_o
}
