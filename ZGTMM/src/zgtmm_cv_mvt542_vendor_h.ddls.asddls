@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주재고 환입 처리 결과 헤더'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_MVT542_VENDOR_H 
as 
select from ZGTMM_CV_MVT542_VENDOR
{
   key mjahr,
   key mblnr,
   bukrs,
   BUKRS_N,
   werks,
   WERKS_N,
   lgort,
   LGORT_N,
   lifnr,
   LIFNR_N,
   budat,
   bldat,
   cpudt,
   cputm,
   usnam,
   bktxt    
} group by mjahr, mblnr, bukrs, BUKRS_N,werks, WERKS_N,lgort,LGORT_N,lifnr,LIFNR_N,budat, bldat,cpudt, cputm, usnam,bktxt
