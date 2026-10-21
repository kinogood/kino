@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 구매 오더 검사 의뢰 정보 중간 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_PO_DATA_SUM
as select from ZGTMM_CV_GET_OEM_PO_DATA_BASE as A
association [0..1] to ZGTMM_CV_GET_DDREQDATE as D1 on $projection.ebeln = D1.ebeln and $projection.ebelp = D1.ebelp and $projection.bukrs = D1.bukrs
association [0..1] to ZGTMM_CV_GET_OEM_QI_REQTY  as D2 on $projection.ebeln = D2.ebeln and $projection.ebelp = D2.ebelp and $projection.bukrs = D2.bukrs
association [0..1] to ZGTMM_CV_GET_OEM_QI_RESULT_QTY  as D3 on $projection.ebeln = D3.ebeln and $projection.ebelp = D3.ebelp and $projection.bukrs = D3.bukrs

{
  key A.bukrs,
  key A.ebeln,
  key A.ebelp,
      A.loekz,
      A.aedat,
      A.eindt,
      A.werks,
      A.lifnr,
      A.LIFNR_N,
      A.vbeln,
      A.posnr,
      A.kunnr,
      A.KUNNR_N,
      A.vkbur,
      A.vkbur_n,
      A.vkgrp,
      A.vkgrp_n,
      A.matnr,
      A.MAKTX,
      A.COLOR,
      @Semantics.quantity.unitOfMeasure: 'MEINS'
      A.menge,
      A.meins,
      A.LENGTH,
      A.DRQTY,
      A.DR_MEINS,
      @Semantics.quantity.unitOfMeasure: 'GR_MEINS_M'
      A.GR_QTY_M,
      A.GR_MEINS_M,
      @Semantics.quantity.unitOfMeasure: 'DR_MEINS'
      A.GR_QTY_DR,
      case when D1.REQDATE is not null then D1.REQDATE else cast('' as dats) end as REQDATE,
      case when D2.QI_REQ_QTY is not null then D2.QI_REQ_QTY else cast(0 as int4) end as QI_REQ_QTY,
      case when D3.QI_RESULT_QTY is not null then D3.QI_RESULT_QTY else cast(0 as int4) end as QI_RESULT_QTY,
      A.elikz,
      A.mtart,
      A.ZINSP_NO,
      @Semantics.quantity.unitOfMeasure: 'QCMEINS'      
      A.zinsp_qty,
      A.meins as QCMEINS,
      A.zinsp_date,
      A.zinsptype,
      A.zinspdate,
      A.zinspres,
      A.zinsp_certi,
      A.zinsp_perno,
      A.zinsp_name,
      A.QCREQDATE,
      A.QCREQDATELOCAL,
      A.INSPECTION
              
      

} 
