@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송의뢰 요청 대표 플랜트 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DDR_WERKS 
as select from zgtmmt4411 as A inner join ekpo as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
                               inner join zgtmmt4410 as C on A.bukrs = C.bukrs and A.dlvrq = C.dlvrq

{
  key A.bukrs,
  key A.dlvrq,
  max(B.werks) as WERKS  
} where C.zsd_stat = 'R'
group by A.bukrs, A.dlvrq
