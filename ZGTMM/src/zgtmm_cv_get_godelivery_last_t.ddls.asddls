@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '납품서 기준 입고 현황 레포팅(AGG)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GODELIVERY_LAST_T 
as select from ZGTMM_CV_GET_GODELIVERY_LAST as A
association [0..1] to zgtmmt5020 as TAX on $projection.lifnr = TAX.lifnr and $projection.vbeln = TAX.vbeln and $projection.POSNR = TAX.posnr and $projection.spmon = TAX.spmon                    
                                       and $projection.ebeln = TAX.ebeln and $projection.ebelp = TAX.ebelp

association [0..1] to t001w as t001w on $projection.werks = t001w.werks  
association [0..1] to lfa1 as lfa1 on $projection.lifnr = lfa1.lifnr 
association [0..1] to tvkbt as TVKBT on $projection.vkbur = TVKBT.vkbur and TVKBT.spras = $session.system_language
association [0..1] to tvgrt as TVGRT on $projection.vkgrp = TVGRT.vkgrp and TVGRT.spras = $session.system_language

{
  key A.spmon,
  key A.ebeln,
  key A.ebelp,
  A.bukrs,
  A.werks,
  t001w.name1 as werks_n,
  A.ekorg,
  A.ekgrp,
  A.vkbur,
  tvkbt.bezei as VKBUR_N,  
  A.vkgrp,
  tvgrt.bezei as VKGRP_N,  
  A.lifnr,
  lfa1.name1 as lifnr_n,
  A.PSTYP,
  A.vbeln,
  A.POSNR,
  A.matnr,
  A.MAKTX,
  A.PRODNAME,
  A.SPECNO,
  A.COLOR ,
  @Semantics.quantity.unitOfMeasure: 'PO_MEINS'     
  A.PO_QTY,
  A.PO_MEINS,
  A.LENGTH ,
  cast(A.DRQTY as abap.dec(13,0)) as DRQTY,
  A.DELNO ,
  A.delitem,
  A.BUDAT ,   

  @Semantics.quantity.unitOfMeasure: 'GR_UNIT'         
  A.DL_QTY,
  cast(cast(A.DL_QTY as abap.dec(13,2)) / cast(A.LENGTH as abap.dec(13,2)) as abap.dec(13,0))  as DL_QTY_DR,
  A.DL_UNIT,  
   
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT'         
  A.GR_QTY,
  cast(cast(A.GR_QTY as abap.dec(13,2)) / cast(A.LENGTH as abap.dec(13,2)) as abap.dec(13,0)) as GR_QTY_DR,
  A.GR_UNIT,
  A.LGORT,
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  A.WH3410,
  cast(cast(A.WH3410 as abap.dec(13,2)) / cast(A.LENGTH as abap.dec(13,2)) as abap.dec(13,0)) as WH3410_DR,
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  A.WH3420,    
  cast(cast(A.WH3420 as abap.dec(13,2)) / cast(A.LENGTH as abap.dec(13,2)) as abap.dec(13,0))  as WH3420_DR,
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  A.WH3498,
  cast(cast(A.WH3498 as abap.dec(13,2)) / cast(A.LENGTH as abap.dec(13,2)) as abap.dec(13,0))  as WH3498_DR,         
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  A.WH3497,       
  cast(cast(A.WH3497 as abap.dec(13,2)) / cast(A.LENGTH as abap.dec(13,2)) as abap.dec(13,0))  as WH3497_DR,
       
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  A.WHETC,
  cast(cast(A.WHETC as abap.dec(13,2)) / cast(A.LENGTH as abap.dec(13,2)) as abap.dec(13,0))  as WHETC_DR,
  @Semantics.amount.currencyCode: 'KONWA'    
  A.kbetr,
  A.KONWA,   
  A.KPEIN,   
  A.KMEIN,

  @Semantics.amount.currencyCode: 'KONWA'      
  A.totalprice,
  
  A.NES_CU,
  @Semantics.quantity.unitOfMeasure: 'BME_CU'             
  A.VGW_CU,  //단위량(KG)
  A.BME_CU,  //단위
  A.VGE_CU,  //PER
  A.MEINS_B_CU,//기본단위    
  @Semantics.quantity.unitOfMeasure: 'BME_CU'              
  A.VGW_T_CU,  
          
  A.NES_AL,
  @Semantics.quantity.unitOfMeasure: 'BME_AL'             
  A.VGW_AL,
  A.BME_AL,
  A.VGE_AL,
  A.MEINS_B_AL,
  @Semantics.quantity.unitOfMeasure: 'BME_AL'          
  A.VGW_T_al,  

  A.NES_FI,
  @Semantics.quantity.unitOfMeasure: 'BME_FI'             
  A.VGW_FI,
  A.BME_FI,
  A.VGE_FI,
  A.MEINS_B_FI,
  @Semantics.quantity.unitOfMeasure: 'BME_FI'          
  A.VGW_T_fi,
  case when TAX.mwskz is not null then TAX.mwskz else A.mwskz end as MWSKZ          
} 
