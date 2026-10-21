@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 재고 직송의뢰 요청 현황 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_STOCK_REQ 
as select from zgtmmt4412 as A  inner join zgtmmt4410 as B on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq
                                left outer join zlet0402 as C on A.dlvrq = C.dlvrq and A.vbeln = C.vbeln and A.posnr = C.posnr

{
  key A.bukrs,
  key A.vbeln,
  key A.posnr,
  @Semantics.quantity.unitOfMeasure: 'DR_meins'    
  sum(A.req_drqty) as REQ_DRQTY,
  A.dr_meins,
  case when C.wbsta is not null then C.wbsta else cast('' as wbsta) end as WBSTA 
} where (A.zmm_stat <> 'R' and A.zvd_stat <> 'R' ) and B.zsd_stat = 'R'
group by A.bukrs,A.vbeln, A.posnr, A.dr_meins, C.wbsta
