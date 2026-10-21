@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 검수 요청 현황 조회2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DD_INSP_REQ2 
as select from ZGTMM_CV_GET_DD_INSP_REQ as A 
association [0..1] to ZGTMM_CV_GET_SO_TEAM  as SO on $projection.VBELN = SO.vbeln 
association [0..1] to ZGTMM_CV_PO_VCVALUE_MAIN  as VC1 on $projection.ebeln = VC1.PDOC and $projection.ebelp = VC1.PDOCITEM   
association [1..1] to dd07t as D1 on $projection.zinsptype = D1.domvalue_l and D1.domname = 'ZGTD_REQSTAT2' and D1.ddlanguage = $session.system_language
association [1..1] to dd07t as D2 on $projection.zinspres = D2.domvalue_l and D2.domname = 'ZGTD_INSPVAL' and D2.ddlanguage = $session.system_language
  
{
  key A.bukrs,
  key A.ebeln,
  key A.ebelp,
  key A.zinsp_no,
      A.werks,
      A.WERKS_N,  
      A.lifnr,
      A.LIFNR_N,
      A.VBELN,
      A.POSNR,  
      SO.vkbur,
      SO.VKBUR_N,
      SO.vkgrp,
      SO.VKGRP_N, 
      A.matnr,        
      A.MAKTX,
//      @Semantics.quantity.unitOfMeasure: 'MEINS'      
      case when VC1.LENGTH is not null then VC1.LENGTH 
           else cast('' as abap.char(70)) end as LENGTH,
      case when VC1.DRQTY is not null then VC1.DRQTY
           else cast('' as abap.char(70)) end as DRQTY,   
      case when VC1.COLOR is not null then VC1.COLOR 
           else cast('' as abap.char(70)) end as COLOR,  
      case when VC1.DRUM is not null then VC1.DRUM 
           else cast('' as abap.char(70)) end as DRUM,  
      A.meins,     
      @Semantics.quantity.unitOfMeasure: 'MEINS_Q'
      A.zinsp_qty,
      A.meins as MEINS_Q,
      A.REQDATE,
      A.eindt,
      A.erdat as QIREQDATE,
      A.zinsptype,
      D1.ddtext as ZINSPTYPE_N,      
           
      A.zinspres,
      D2.ddtext as ZINSPRES_N,
      
      A.zinspdate,
      A.zinsp_certi,
      
      A.erdat,
      A.erdat_local,
      A.ertim,
      A.ertim_local,
      A.ernam,
      A.aedat,
      A.aedat_local,
      A.aetim,
      A.aetim_local,
      A.aenam   
}
