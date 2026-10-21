@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '통문증 발급 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETGATEOUTLIST 
as 
select from zlet0005 as A inner join zlet0006 as B on  A.iv_no = B.iv_no   

{
  key B.iv_no,
  key B.iv_seq,
  B.mblnr,
  B.zeile,
  B.mjahr 
  
} where A.iv_cancel_yn = ''



union

select from zgtmmt4500 as A inner join zgtmmt4501 as B on  A.iv_no = B.iv_no   

{
  key B.iv_no,
  key B.iv_seq,
  B.mblnr,
  B.zeile,
  B.mjahr 
  
} where A.iv_cancel_yn = ''
