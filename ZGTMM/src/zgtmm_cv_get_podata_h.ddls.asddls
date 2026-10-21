@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SRM 전송 PO 헤더 정보 조회(공통)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PODATA_H 
as select from ZGTMM_CV_GET_CDHDR_SUMMARY as A inner join ekko as B on A.objectid = B.ebeln
                          inner join P_USER002 as C on B.ernam = C.bname
                          inner join lfa1 as D on B.lifnr = D.lifnr
association [0..1] to t024e as T024E on $projection.ekorg = T024E.ekorg
association [0..1] to t024 as T024 on $projection.ekgrp = T024.ekgrp
association [0..1] to t161t as T161T on $projection.bsart = T161T.bsart and T161T.spras = $session.system_language and T161T.bstyp = 'F'
association [0..1] to t001w as T001W on $projection.reswk = T001W.werks
association [0..1] to t052u as T052U on $projection.zterm = T052U.zterm and T052U.spras = $session.system_language    
association [0..1] to tinct as TINCT on $projection.inco1 = TINCT.inco1 and TINCT.spras = $session.system_language                            
{
   key  A.CHANGENR,
   key  B.ebeln,
        B.bukrs,
        B.ekorg,
        t024e.ekotx,  
        B.ekgrp,
        t024.eknam,
        B.bsart,
        t161t.batxt,    
        B.statu,
        B.aedat,
        B.ernam,   
        C.name_text as FULLNAME,
        C.tel_number,
        C.smtp_addr as E_MAIL,
        A.udate,
        A.utime,
        B.lponr,
        B.lifnr,
        D.name1,
        B.reswk,
        t001w.name1 as RESWK_N,
        B.zterm,
        t052u.text1,
        B.zbd1t,
        B.zbd2t,
        B.zbd3t,
        B.waers,
        B.wkurs,
        B.bedat,
        B.inco1,
        tinct.bezei,
        B.lands,
        A.username,
        A.tcode,
        concat(A.udate,A.utime) as timestamp
 
} where A.objectclas = 'EINKBELEG' and B.memorytype = '' and B.frgsx <> '' and B.frgzu <> '' and B.ekgrp <> 'T60' and B.ekgrp <>'T61'

union

select from ZGTMM_CV_GET_CDHDR_SUMMARY as A inner join ekko as B on A.objectid = B.ebeln
                          inner join P_USER002 as C on B.ernam = C.bname
                          inner join lfa1 as D on B.lifnr = D.lifnr
association [0..1] to t024e as T024E on $projection.ekorg = T024E.ekorg
association [0..1] to t024 as T024 on $projection.ekgrp = T024.ekgrp
association [0..1] to t161t as T161T on $projection.bsart = T161T.bsart and T161T.spras = $session.system_language and T161T.bstyp = 'F'
association [0..1] to t001w as T001W on $projection.reswk = T001W.werks
association [0..1] to t052u as T052U on $projection.zterm = T052U.zterm and T052U.spras = $session.system_language    
association [0..1] to tinct as TINCT on $projection.inco1 = TINCT.inco1 and TINCT.spras = $session.system_language                            
{
   key  A.CHANGENR,
   key  B.ebeln,
        B.bukrs,
        B.ekorg,
        t024e.ekotx,  
        B.ekgrp,
        t024.eknam,
        B.bsart,
        t161t.batxt,    
        B.statu,
        B.aedat,
        B.ernam,   
        C.name_text as FULLNAME,
        C.tel_number,
        C.smtp_addr as E_MAIL,
        A.udate,
        A.utime,
        B.lponr,
        B.lifnr,
        D.name1,
        B.reswk,
        t001w.name1 as RESWK_N,
        B.zterm,
        t052u.text1,
        B.zbd1t,
        B.zbd2t,
        B.zbd3t,
        B.waers,
        B.wkurs,
        B.bedat,
        B.inco1,
        tinct.bezei,
        B.lands,
        A.username,
        A.tcode,
        concat(A.udate,A.utime) as timestamp
 
} where A.objectclas = 'EINKBELEG' and B.memorytype = '' and B.frgsx = '' and B.ekgrp <> 'T60' and B.ekgrp <>'T61'
