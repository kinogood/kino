@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO 변경 정보 조회-MM00002'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_CHANGEDPO 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date   
 as 
 select from ZGTMM_CV_GETCDHDRID(p_startdate: $parameters.p_startdate ,
                                 p_enddate : $parameters.p_enddate,
                                 p_diGit: 10,
                                 P_CLASS : 'EINKBELEG')  as A
             inner join ekko as B on A.ID = B.ebeln
             inner join ekpo as C on B.ebeln = C.ebeln 
             inner join eket as D on C.ebeln = D.ebeln and C.ebelp = D.ebelp                      
             left outer join ekkn as E on C.ebeln = E.ebeln and C.ebelp = E.ebelp            
             
association [1..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language 
{
  key   C.ebeln,
        C.ebelp,
        C.matnr,
        
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        C.menge,
        C.meins,
        
        @Semantics.amount.currencyCode: 'waers'
        C.netpr,
        
        C.uebto,
        C.untto,
        C.werks,
        C.lgort,
        C.pstyp,
        C.bstae,
        C.elikz,
        C.aedat,
        C.txz01,  
        B.waers,
        B.bukrs,
        B.ekorg,
        B.bsart,
        B.lifnr,
        B.ekgrp,
        B.loekz as h_loekz,
        C.loekz as i_loekz,
        D.eindt,
        makt.maktx,
        C.retpo,
        B.reswk,
        E.vbeln,
        E.vbelp,
        
        A.changenr,
        A.udate, 
        A.utime,
        A.username,

        C.insmk,  //재고유형
        C.mtart   //자재유형        
}        
