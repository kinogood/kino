@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '드럼 번호 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DRUM_NAME 
as select from mara as A inner join makt as B on A.matnr = B.matnr
{
   key RIGHT(A.matnr,7) as MATNR,
       A.mtart,
       B.maktx,
       REPLACE(REPLACE(REPLACE(B.maktx,'목드럼',''),'철드럼',''),'고드럼','')  as DRUMNAME 
} where B.spras = $session.system_language
