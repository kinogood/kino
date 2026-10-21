@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '송장 품목 정보 LIST'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_AP_RSEG 
as select from ZGTMM_CV_GET_AP_RBKP as A inner join rseg as B on A.bukrs = B.bukrs and A.belnr = B.belnr and A.gjahr = B.gjahr 
                                         inner join ekpo as C on B.ebeln = C.ebeln and B.ebelp = C.ebelp
{
  key B.gjahr,
  key B.belnr,
  key B.buzei,
      B.ebeln,
      B.ebelp,
      B.matnr,
      C.txz01,
      B.bukrs,
      B.werks,
      @Semantics.amount.currencyCode: 'waers'       
      case when B.shkzg = 'S' then B.wrbtr else B.wrbtr * -1  end as WRBTR,
      A.waers,
      A.xrech,
      B.shkzg,
      B.mwskz,
      @Semantics.quantity.unitOfMeasure: 'BSTME'      
      case when B.shkzg = 'S' then B.menge else B.menge * -1 end as MENGE,
      B.bstme,       
      @Semantics.amount.currencyCode: 'waers'       
      cast(cast(cast(B.wrbtr as abap.dec(20,2)) / cast(B.menge as abap.dec(20,2)) as abap.dec(13,2)) as abap.curr(13,2)) as netpr,
      A.waers as pwaers                
}
