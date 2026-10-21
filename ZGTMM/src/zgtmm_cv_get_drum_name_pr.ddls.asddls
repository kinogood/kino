@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매요청 드럼 이릅 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DRUM_NAME_PR 
as select from zgtppt2450 as A inner join makt as B on A.matnr_dm = B.matnr
{
   key A.banfn,
   key A.bnfpo,
       B.maktx,
       REPLACE(REPLACE(REPLACE(B.maktx,'목드럼',''),'철드럼',''),'고드럼','')  as DRUMNAME     
} where B.spras = $session.system_language
