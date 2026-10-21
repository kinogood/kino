@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매입고 현황 중간 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GR_HISTORY_AGG 
as select from ZGTMM_CV_GET_GR_HISTORY_BASE as A 
association [0..1] to ZGTMM_CV_GET_GRQTY_BYPO  as po on $projection.ebeln = po.ebeln and $projection.ebelp = po.ebelp 
association [0..1] to vbak  as so on $projection.vbeln = so.vbeln


{
  key A.ebeln,
  key A.ebelp,
      A.bukrs,
      A.werks,
      A.ekorg,
      A.ekgrp,
      A.lifnr,
      A.PSTYP,
      A.vbeln,
      A.POSNR,
      case when so.vkbur is not null then so.vkbur else cast('' as vkbur) end as vkbur,
      case when so.vkgrp is not null then so.vkgrp else cast('' as vkgrp) end as vkgrp,      
      A.matnr,
      A.MAKTX,
      A.PRODNAME,
      A.SPECNO,
      A.COLOR ,
      @Semantics.quantity.unitOfMeasure: 'PO_MEINS'     
      A.PO_QTY,
      A.PO_MEINS,
      A.LENGTH ,
      A.DRQTY,
      case when po.spmon is null then cast('' as spmon) else po.spmon end as SPMON,
      po.budat,
      @Semantics.quantity.unitOfMeasure: 'ERFME'         
      po.erfmg,   
      po.erfme,
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      po.WH3410,
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      po.WH3420,       
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      po.WH3498,       
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      po.WH3497,       
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      po.WHETC,
      A.mwskz                               
}
