@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '판매오더 부서 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_SO_TEAM 
as select from vbak as A 
  association [0..1] to tvkbt as TVKBT on $projection.vkbur = TVKBT.vkbur and TVKBT.spras = $session.system_language
  association [0..1] to tvgrt as TVGRT on $projection.vkgrp = TVGRT.vkgrp and TVGRT.spras = $session.system_language
{
   key A.vbeln,
       A.vkbur,
       tvkbt.bezei as VKBUR_N,
       A.vkgrp,
       tvgrt.bezei as VKGRP_N 
}
