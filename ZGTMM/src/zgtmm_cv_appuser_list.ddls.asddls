@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '승인권자 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_APPUSER_LIST 
as 
select from zgtmmt4113 as A
association [1..1] to t001 as B on $projection.bukrs = B.bukrs
association [1..1] to t001w as C on $projection.werks = C.werks
association [1..1] to t001l as D on $projection.werks = D.werks and $projection.lgort = D.lgort
association [1..1] to ZGTMM_CV_GETUSERNAME  as E on $projection.approver1 = E.USERID 
association [0..1] to ZGTMM_CV_GETUSERNAME  as F on $projection.approver2 = F.USERID 

{ 
 key    A.bukrs,
 key    A.werks,
 key    A.lgort,
        B.butxt,
        C.name1,
        D.lgobe,
        A.approver1,
        E.NAME as APNAME1,
        A.approver2,
        F.NAME as APNAME2, 
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
