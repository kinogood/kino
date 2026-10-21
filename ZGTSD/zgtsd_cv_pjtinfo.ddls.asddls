@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 프로젝트 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_PJTINFO 
as select from zsd0106t as A inner join tvkbt as B
                                on A.zvkbur = B.vkbur
                               and B.spras  = $session.system_language
                             inner join ZGTMM_CV_GETUSERNAME as C
                                on A.pernr  = C.USERID
                             inner join kna1 as D
                                on A.kunnr = D.kunnr
{
    key A.zpjno,
    A.zptxt, A.spmon, A.kunnr, D.name1, A.zpdat, A.pernr, C.NAME, A.erdat
    
}
