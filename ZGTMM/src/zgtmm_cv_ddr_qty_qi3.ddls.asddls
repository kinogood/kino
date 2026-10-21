@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 품질 검사 진행 현황 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DDR_QTY_QI3 

as select from ZGTMM_CV_DDR_QTY_QI1 as QI1
//association [0..1] to ZGTMM_CV_DDR_QTY_QI2 as QI2 on $projection.bukrs = QI2.bukrs and $projection.dlvrq = QI2.dlvrq
{
  key QI1.bukrs,
  key QI1.dlvrq
}
 