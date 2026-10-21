@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '특성명 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_CAWNT 
as select from cabn as A inner join cawn as B on A.atinn = B.atinn and A.adzhl = B.adzhl
                         inner join cawnt as C on B.atinn = C.atinn and B.atzhl = C.atzhl and B.adzhl = C.adzhl and C.spras = $session.system_language
{
   key A.atnam,
   key B.atwrt,
       C.atwtb
}
