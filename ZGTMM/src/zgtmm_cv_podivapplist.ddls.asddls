@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO 분할 승인 현황'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_PODIVAPPLIST 
as 
select from zgtmmt4012 as A inner join ekko as b on A.ebeln = b.ebeln
association [0..1] to dd07t as app on $projection.appstat = app.domvalue_l and app.domname = 'ZGTDAPSTAT' and app.ddlanguage = $session.system_language
association [0..1] to dd07t as REj on $projection.rejres = REj.domvalue_l and REj.domname = 'ZGTDMMREJ2' and REj.ddlanguage = $session.system_language
association [1..1] to ZGTMM_CV_GETUSERNAME as N1 on $projection.ernam = N1.USERID
association [1..1] to ZGTMM_CV_GETUSERNAME as N2 on $projection.aenam = N2.USERID
association [1..1] to ZGTMM_CV_GETUSERNAME as N3 on $projection.appuser = N3.USERID
association [1..1] to lfa1 as LFA1 on $projection.lifnr = LFA1.lifnr
{
  key   A.zguid,
  key   A.ebeln,
        b.bukrs,
        b.lifnr,
        lfa1.name1 as LIFNR_N,
        A.appuser,
        N3.NAME as APPUSER_N,
        A.mailtext,
        A.appstat,
        app.ddtext as appstat_n,
        A.rejres,
        REj.ddtext as rejres_n,
        A.retc,
        A.erdat,
        A.erdat_local,
        A.ertim,
        A.ertim_local,
        A.ernam,
        N1.NAME as ernam_n,
        A.aedat,
        A.aedat_local,
        A.aetim,
        A.aetim_local,
        A.aenam,
        N2.NAME as aenam_n,
        A.cancel,
        A.type,
        A.id,
        A.znumber,
        A.message
        
    
}
