@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 품질 검사 의뢰 건수'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DDR_QTY_QI1 
as select from zgtmmt4411 as A inner join zgtmmt4402 as B on A.bukrs = B.bukrs and A.ebeln = B.ebeln and A.ebelp = B.ebelp
                                            inner join zgtmmt4410 as C on A.bukrs = C.bukrs and A.dlvrq = C.dlvrq
                                       
{
  key A.bukrs,
  key A.dlvrq,
  @Semantics.quantity.unitOfMeasure: 'meins'     
  cast(sum(B.zinsp_qty) as abap.int4) as QI_REQ_QTY,
  B.meins
} where C.zsd_stat = 'R' 
group by A.bukrs, A.dlvrq, B.meins
