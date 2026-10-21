@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직납 납품서 대표 입고 자재문서'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETMAXGRDOC 
as select from matdoc as A 

{
    key A.vbeln_im as VBELN,
    max(A.budat) as BUDAT,
    max(A.mblnr) as MBLNR,
    max(A.mjahr) as MJAHR
} where A.cancelled = '' and A.reversal_movement = ''
group by A.vbeln_im

