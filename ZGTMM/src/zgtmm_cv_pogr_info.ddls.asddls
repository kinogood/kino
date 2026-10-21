@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 오더 GR QTY'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_POGR_INFO 
as 
select from ZGTMM_CV_GETNONINBGR 
{
  key ebeln,
  key ebelp,
  @Semantics.quantity.unitOfMeasure: 'MEINS'   
  sum(MENGE) as MENGE,
  meins
  
} group by ebeln, ebelp, meins

/*
select from ekbe as A inner join ZGTMM_CV_GETNONINBGR as B
          on A.ebeln = B.ebeln and A.ebelp = B.ebelp and A.zekkn = B.zekkn  
             and A.gjahr = B.gjahr and A.belnr = B.belnr and A.buzei = B.buzei
          inner join ekpo as C on B.ebeln = C.ebeln and B.ebelp = C.ebelp
          inner join ekko as D on C.ebeln = D.ebeln 
          inner join matdoc as E on A.gjahr = E.mjahr and A.belnr = E.mblnr and A.buzei = E.zeile
{
  key A.ebeln,
  key A.ebelp,
      A.cpudt as ERDAT,
      D.lifnr,  
      A.werks,
      E.lgort,
      A.matnr,
      @Semantics.quantity.unitOfMeasure: 'MEINS'        
      A.menge,  //입고수량
      E.meins,      
      A.gjahr,
      A.belnr,
      A.buzei,
      A.budat,
      A.xblnr
} where A.zekkn = '00' and A.vgabe = '1' and D.lifnr <>'' and E.cancelled = '' and E.reversal_movement = '' 
*/
