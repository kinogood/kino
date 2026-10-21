@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 정산 대상 업체 별 금액 SUMMARY(구매그룹제외)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_TARGET_IV_H2 

as select from ZGTMM_CV_GET_TARGET_IV as A  
association [0..1] to t001  as COM on $projection.bukrs = COM.bukrs  
association [0..1] to t001w  as T001W on $projection.werks = T001W.werks  
association [0..1] to t024e  as EK on $projection.ekorg = EK.ekorg   
association [0..1] to ZGTMM_CV_GET_EXCHANGERATE  as EXCG on $projection.ETIV_waers = EXCG.fcurr and EXCG.fcurr <> 'KRW' and EXCG.tcurr = 'KRW'  
{
  key A.lifnr,
      A.LIFNR_N, 
      A.bukrs,
      COM.butxt as BUKRS_N,
      A.ekorg,
      EK.ekotx as EKORG_N,
      A.werks,
      t001w.name1 as WERKS_N,
      A.SPMON,      
      A.XRECH,
      case when A.XRECH = 'X' then cast('송장' as abap.char(4)) else cast('반품' as abap.char(4)) end as XRECH_N,
      @Semantics.amount.currencyCode: 'ETIV_waers' 
      cast(sum(A.TARGET_PRICE) as abap.curr(25,2)) as TARGET_PRICE,
      @Semantics.amount.currencyCode: 'ETIV_waers'       
      cast(sum(A.TAXPRICE) as abap.curr(25,2)) as TAXPRICE,
      @Semantics.amount.currencyCode: 'ETIV_waers'      
      cast(sum(A.TARGET_PRICE) as abap.curr(30,2)) +  cast(sum(A.TAXPRICE) as abap.curr(30,2)) as WRBTR,
      A.ETIV_waers,
      case when A.ETIV_waers = 'KRW' then
           cast('1' as ukurs_curr)
           else EXCG.ukurs end as EXRATE
} where A.TARGET_PRICE > 0  and A.IV_COMPLETE = '' 
group by A.lifnr, A.LIFNR_N, A.bukrs, COM.butxt, A.ekorg,  EK.ekotx, A.werks, t001w.name1,  A.SPMON, A.ETIV_waers, EXCG.ukurs,
      A.XRECH
