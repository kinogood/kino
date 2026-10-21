@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO 변경 승인권자 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETAPUSERLIST 
as select from zgtmmt4014 as A 
          inner join ZGTMM_CV_GETUSERNAME as B on A.appuser = B.USERID 
association [1..1] to t024 as T024 on $projection.ekgrp = T024.ekgrp          
{
  key A.werks,
  key A.ekgrp, 
  key A.appuser as USERID,
      t024.eknam,
      B.NAME,
      B.EMAIL
} where A.zuse = 'X'
