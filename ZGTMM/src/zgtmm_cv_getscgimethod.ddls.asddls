@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 재고 출고 방식 관리(저장위치 별)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETSCGIMETHOD 
as select from zgtmmt4100 as A
association [0..1] to t001 as Company on $projection.bukrs = Company.bukrs  
association [0..1] to t001w as Plant on $projection.werks = Plant.werks  
association [0..1] to t001l as SL on $projection.werks = SL.werks and $projection.lgort = SL.lgort   
association [1..1] to dd07t as MODE on $projection.zmode = MODE.domvalue_l and MODE.domname = 'ZGTDMMMODE' and MODE.ddlanguage = $session.system_language
{
 key    A.bukrs,
 key    A.werks,
 key    A.lgort,
        Company.butxt,
        Plant.name1 as PLANTNAME,
        SL.lgobe as LGORTNAME,
        A.zmode,
        MODE.ddtext as ZMODENAME,
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
