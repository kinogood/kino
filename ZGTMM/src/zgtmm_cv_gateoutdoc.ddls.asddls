@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '통문 번호 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GATEOUTDOC 
as 
select from zlet0005 as A inner join zlet0006 as B on A.iv_no = B.iv_no
{
   key A.iv_no, 
   B.mjahr, 
   B.mblnr, 
   max(B.zeile) as ZEILE
} where A.iv_type = 'B01' and A.bwart = '541' and A.iv_cancel_yn = ''

group by A.iv_no, B.mjahr, B.mblnr 
