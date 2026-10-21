@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '인포레코드 승인 요청 현황 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_INFO_APPROVE 
as select from zgtmmt1061 as A inner join mara as B on A.matnr = B.matnr
                               inner join lfa1 as C on A.lifnr = C.lifnr
association [0..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language
                
association [1..1] to t001w as T001W on $projection.werks = T001W.werks
association [1..1] to t024e as T024E on $projection.ekorg = T024E.ekorg            
association [1..1] to dd07t as TYPE on $projection.esokz = TYPE.domvalue_l and TYPE.domname = 'ESOKZ' and TYPE.ddlanguage = $session.system_language
association [0..1] to t024 as T024 on $projection.ekgrp = T024.ekgrp
association [1..1] to dd07t as Z1 on $projection.meprf = Z1.domvalue_l and Z1.domname = 'MEPRF' and Z1.ddlanguage = $session.system_language
association [1..1] to tinct as TINCT on $projection.inco1 = TINCT.inco1 and TINCT.spras = $session.system_language    
association [1..1] to t007s as T007S on $projection.mwskz = T007S.mwskz and T007S.kalsm = 'TAXKR' and T007S.spras = $session.system_language

{
 key A.matnr,
 key A.lifnr,
 key A.ekorg,
 key A.werks,
 key A.esokz,
     case when B.zzmaktx80 <> '' then B.zzmaktx80 else 
          makt.maktx end as MATNR_N, 
     C.name1 as LIFNR_N,
     t024e.ekotx as EKORg_N,     
     t001w.name1 as WERKS_N,
     TYPE.ddtext as ESOKZ_N,  
     A.ekgrp,
     t024.eknam as EKGRP_N,
     A.aplfz,
     @Semantics.quantity.unitOfMeasure: 'meins'       
     A.norbm,
     A.meins,
     A.uebto,
     A.untto,
     A.uebtk,
     A.verid,
     A.webre,
     A.xersn,
     A.bstae,
     A.datab,
     A.datbi, 
     @Semantics.amount.currencyCode: 'KONWA'       
     A.kbetr,
     A.konwa,
     A.kpein,
     A.kmein,      
     A.zfr1,
     A.zfr1_unit,          
     A.zfr2,
     A.zfr2_unit,     
     A.zfr1_i,
     A.zfr1_unit_i,
     A.zfr2_i,
     A.zfr2_unit_i,
     A.meprf,
     Z1.ddtext as MEPRF_N,
     A.inco1,
     tinct.bezei as INCO1_N,
     A.mwskz,
     t007s.text1 as MWSKZ_N,
     A.erdat,
     A.erdat_local,
     A.ertim,
     A.ertim_local,
     A.ernam
} where A.approved ='O'
