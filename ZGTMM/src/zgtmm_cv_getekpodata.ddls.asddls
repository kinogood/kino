@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO 품목 정보 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETEKPODATA 
as select from ekko as A inner join ekpo as B on A.ebeln = B.ebeln
 //                        inner join ZGTMM_CV_GETSPGBYMAT as spg on B.matnr = spg.matnr and B.werks = spg.werks
                         left outer join ZGTMM_CV_POGR_REMAIN as C on B.ebeln = C.ebeln and B.ebelp = C.ebelp
                         left outer join zgtmmt4012 as D on A.ebeln = D.ebeln and ( D.appstat = '' or D.type = 'E') and D.cancel = ''
                         inner join eket as E on B.ebeln = E.ebeln and B.ebelp = E.ebelp and E.etenr = '0001'
                       //  inner join scal_tt_date as F on E.eindt = F.calendardate
          
association [1..1] to t001 as T001 on $projection.bukrs = T001.bukrs   
association [1..1] to t001w as T001W on $projection.werks = T001W.werks
association [1..1] to t024e as T024E on $projection.ekorg = T024E.ekorg
association [1..1] to t024 as T024 on $projection.ekgrp = T024.ekgrp
association [1..1] to t161t as T161T on $projection.bsart = T161T.bsart and $projection.bstyp = T161T.bstyp and T161T.spras = $session.system_language 
association [1..1] to lfa1 as LFA1 on $projection.lifnr = LFA1.lifnr         
association [0..1] to lfa1 as SCV on $projection.emlif = SCV.lifnr 
association [0..1] to kna1 as KNA1 on $projection.kunnr = KNA1.kunnr
association [1..1] to t001l as T001L on $projection.werks = T001L.werks and $projection.lgort = T001L.lgort   
{
  key A.bukrs,
  key A.ekorg,
  key A.bsart,
  key A.ekgrp,
  key A.lifnr,
  key A.ebeln,
  key B.ebelp,
//      spg.SPGCD,
//      spg.SPGNAME,     
      A.bstyp,
      B.werks,
      B.lgort,
      t001l.lgobe as LGORT_N,
      B.matnr,
      B.txz01,
      B.loekz,
      B.retpo,
      @Semantics.quantity.unitOfMeasure: 'MEINS'  
      case when B.retpo = 'X' then B.menge * -1 else B.menge end as MENGE,
      B.meins,
      C.uebto,
      B.elikz,
      B.emlif,
      B.lblkz,
      B.kunnr,
      @Semantics.quantity.unitOfMeasure: 'MEINS'  
      case when C.INBQTY is null then cast(0 as abap.quan(13,3))
           else C.INBQTY end as INBQTY,
      @Semantics.quantity.unitOfMeasure: 'MEINS'  
      case when C.GRQTY is null then cast(0 as abap.quan(13,3))
           else C.GRQTY end as GRQTY,
      @Semantics.quantity.unitOfMeasure: 'MEINS'  
      case when C.REQTY is null then cast(0 as abap.quan(13,3))
           else C.REQTY end as REQTY,
      @Semantics.quantity.unitOfMeasure: 'MEINS'  
      C.MAXQTY,
      t001.butxt as BUKRS_N,
      t024e.ekotx as EKORG_N,      
      t001w.name1 as WERKS_N,        
      t024.eknam as EKGRP_N,
      t161t.batxt as BSART_N,   
      lfa1.name1 as LIFNR_N,
      lfa1.land1 as land,
      case when SCV.name1 is null then cast('' as abap.char(35))
           else SCV.name1 end as EMLIF_N,
      case when kna1.name1 is null then cast('' as abap.char(35))
           else kna1.name1 end  as KUNNR_N,
      A.aedat,
      case when D.appstat is not null then cast('X' as abap.char(1))
           else cast('' as abap.char(1)) end as ING,
      E.eindt,
      lfa1.land1,
      B.pstyp   
   //   DIV(DATS_DAYS_BETWEEN($session.system_date,E.eindt) ,7) as REWEEK
} where B.loekz = '' and B.elikz = ''

