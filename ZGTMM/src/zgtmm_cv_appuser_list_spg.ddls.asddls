@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '승인권자 리스트(SPG 별)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_APPUSER_LIST_SPG 
as 
select from zgtmmt4014 as A
association [1..1] to t001 as B on $projection.bukrs = B.bukrs
association [1..1] to t001w as C on $projection.werks = C.werks
association [1..1] to ZGTMM_CV_GETUSERNAME  as E on $projection.appuser = E.USERID 
association [1..1] to t024 as T024 on $projection.ekgrp = T024.ekgrp

{ 
 key    A.bukrs,
 key    A.werks,
 key    A.ekgrp,
        t024.eknam,
        B.butxt,
        C.name1,
        A.appuser,
        E.NAME as APNAME1,
        A.zuse,
        A.erdat,
        A.erdat_local,  
        A.ertim,
        A.ertim_local,
        A.ernam,
        A.aedat,
        A.aedat_local,
        A.aetim,
        A.aetim_local,
        A.aenam
}
