@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '영업 그룹 약어 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_SALES_TEAM 
as select from vbak as A inner join vbkd as B on A.vbeln = B.vbeln and B.posnr = '000000'
                         inner join zgtsdt1103 as C on A.vkorg = C.vkorg and A.vkgrp = C.vkgrp and B.kdkg4 = C.kdkg4
{
  key A.vbeln,
  key A.vkorg,
      C.zzyuscd
} 


union 

select from vbak as A inner join zgtsdt1104 as B on A.vkorg = B.vkorg and A.vkgrp = B.vkgrp
{
  key A.vbeln,
  key A.vkorg,
      B.zzyuscd 
} 
