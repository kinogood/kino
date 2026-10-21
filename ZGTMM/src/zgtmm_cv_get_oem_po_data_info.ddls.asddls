@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 구매 오더 검사 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_PO_DATA_INFO 
as select from ZGTMM_CV_GET_OEM_PO_DATA_SUM as A 

{ 
  key A.bukrs,
  key A.ebeln,
  key A.ebelp,
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
      A.INSPECTION,
      A.DR_MEINS,
      @Semantics.quantity.unitOfMeasure: 'GR_MEINS_M'            
      A.GR_QTY_M,
      A.GR_MEINS_M,     
      @Semantics.quantity.unitOfMeasure: 'DR_MEINS'          
      A.GR_QTY_DR,
      A.REQDATE, 
      A.QI_REQ_QTY,
      A.QI_RESULT_QTY,
      A.elikz,
      A.loekz,
      case when A.zinsp_no <> '' and A.elikz = '' and A.loekz = '' 
            then cast('X' as abap.char(1))
            else
                 cast('' as abap.char(1))
            end as QI_CLOSE,
     A.mtart,
     A.zinsp_no,
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
     A.QCREQDATELOCAL
} 
