@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 별 입고 내역 조회(입고 일자 계산)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GRDATA_90DAY 
as select from ZGTMM_CV_GET_GRDATA_MATERIAL
{
  key lifnr,
  key matnr,  
  key ekorg,
  key werks,
  key esokz,
      infnr,
      LIFNR_N,
      MATNR_N,
      EKORG_N,
      WERKS_N,
      ESKOZ_N,
      EKGRP_N,
      @Semantics.amount.currencyCode: 'KONWA'
      kbetr,
      konwa,
      kpein,
      kmein,
      ekgrp,
      BUDAT,
      DATS_DAYS_BETWEEN(BUDAT,$session.user_date) as FDAY,
      case when DATS_DAYS_BETWEEN(BUDAT,$session.user_date) > 90 then cast('X' as abap.char(1)) else cast('' as abap.char(1)) end as DAYCHECK  
}
