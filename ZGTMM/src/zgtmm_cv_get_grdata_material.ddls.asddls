@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 별 입고 내역 조회(단가 존재 자재)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GRDATA_MATERIAL 
as
select from matdoc as A inner join ekpo as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
                        inner join ekko as C on B.ebeln = C.ebeln
                        inner join ekbe as D on A.ebeln = D.ebeln and A.ebelp = D.ebelp and A.mjahr = D.gjahr
                                           and  A.mblnr = D.belnr and A.zeile = D.buzei
                        inner join ZGTMM_CV_GET_INFOPRICE  as E on B.matnr = E.matnr and C.lifnr = E.lifnr and  C.ekorg = E.ekorg and B.werks = E.werks and B.pstyp = E.esokz and E.EINA_LOEKZ = '' and E.EINE_LOEKZ = ''  
{
  key E.lifnr,
  key E.matnr,  
  key E.ekorg,
  key E.werks,
  key E.esokz,
      E.infnr,
      E.LIFNR_N,
      E.MATNR_N,
      E.EKORG_N,
      E.WERKS_N,
      E.ESKOZ_N,
      E.EKGRP_N,
      @Semantics.amount.currencyCode: 'KONWA'
      E.kbetr,
      E.konwa,
      E.kpein,
      E.kmein,
      E.ekgrp,
      max(A.budat) as BUDAT
   
} where E.EINA_LOEKZ = '' and E.EINE_LOEKZ = '' and A.cancelled = '' and A.reversal_movement = '' and D.vgabe = '1'
   and  E.datab <= $session.user_date and E.datbi >= $session.user_date
group by E.lifnr,E.matnr,E.ekorg,E.werks,E.esokz,E.infnr,E.LIFNR_N,E.MATNR_N,E.EKORG_N,E.WERKS_N,
      E.ESKOZ_N,E.EKGRP_N,E.kbetr, E.konwa,E.kpein,E.kmein,E.ekgrp
   
