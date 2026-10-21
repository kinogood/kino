@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '납품서 기준 입고 현황 레포팅(집계)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GODELIVERY_LAST2 
as select from ZGTMM_CV_GET_GODELIVERY_LAST_T as a

{
  key a.spmon,
  key a.ebeln,
  key a.ebelp,
  a.bukrs,
  a.werks,
  a.werks_n,
  a.ekorg,
  a.ekgrp,
  a.vkbur,
  a.VKBUR_N,  
  a.vkgrp,
  a.VKGRP_N,    
  a.lifnr,
  a.lifnr_n,
  a.PSTYP,
  a.vbeln,
  a.POSNR,
  a.matnr,
  a.MAKTX,
  a.PRODNAME,
  a.SPECNO,
  a.COLOR ,
  @Semantics.quantity.unitOfMeasure: 'PO_MEINS'     
  a.PO_QTY,
  a.PO_MEINS,
  a.LENGTH ,
  a.DRQTY,
  a.DELNO ,
  a.delitem,
  a.BUDAT ,   

  @Semantics.quantity.unitOfMeasure: 'GR_UNIT'         
  a.DL_QTY,
  a.DL_QTY_DR,
  a.DL_UNIT,  
   
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT'         
  sum(a.GR_QTY) as GR_QTY,
  sum(a.GR_QTY_DR) as GR_QTY_DR,
  a.GR_UNIT,
  a.LGORT,
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  sum(a.WH3410) as WH3410,
  sum(a.WH3410_DR) as WH3410_DR,
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  sum(a.WH3420) as WH3420,    
  sum(a.WH3420_DR) as WH3420_DR,
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  sum(a.WH3498) as WH3498,
  sum(a.WH3498_DR) as WH3498_DR,         
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  sum(a.WH3497) as WH3497,       
  sum(a.WH3497_DR) as WH3497_DR,
       
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  sum(a.WHETC) as WHETC,
  sum(a.WHETC_DR) as WHETC_DR,
  @Semantics.amount.currencyCode: 'KONWA'    
  a.kbetr,
  a.KONWA,   
  a.KPEIN,   
  a.KMEIN,

  @Semantics.amount.currencyCode: 'KONWA'      
  sum(a.totalprice) as totalprice,
  
  a.NES_CU,
  @Semantics.quantity.unitOfMeasure: 'BME_CU'             
  a.VGW_CU,  //단위량(KG)
  a.BME_CU,  //단위
  a.VGE_CU,  //PER
  a.MEINS_B_CU,//기본단위    
  @Semantics.quantity.unitOfMeasure: 'BME_CU'              
  sum(a.VGW_T_CU) as VGW_T_CU,  
          
  a.NES_AL,
  @Semantics.quantity.unitOfMeasure: 'BME_AL'             
  a.VGW_AL,
  a.BME_AL,
  a.VGE_AL,
  a.MEINS_B_AL,
  @Semantics.quantity.unitOfMeasure: 'BME_AL'          
  sum(a.VGW_T_al) as VGW_T_al,  

  a.NES_FI,
  @Semantics.quantity.unitOfMeasure: 'BME_FI'             
  a.VGW_FI,
  a.BME_FI,
  a.VGE_FI,
  a.MEINS_B_FI,
  @Semantics.quantity.unitOfMeasure: 'BME_FI'          
  sum(a.VGW_T_fi) as VGW_T_fi,
  a.MWSKZ          
} group by a.spmon, a.ebeln, a.ebelp, a.bukrs, a.werks, a.werks_n, a.ekorg, a.ekgrp, a.lifnr, a.lifnr_n,
           a.PSTYP, a.vbeln, a.POSNR, a.matnr, a.MAKTX, a.PRODNAME, a.SPECNO, a.COLOR ,    
           a.PO_QTY, a.PO_MEINS, a.LENGTH , a.DRQTY, a.DELNO , a.delitem, a.BUDAT , a.kbetr, a.KONWA,   
           a.KPEIN, a.KMEIN, a.DL_QTY,  a.DL_QTY_DR,  a.DL_UNIT, a.GR_UNIT,  a.LGORT,  a.NES_CU,
           a.VGW_CU,  a.BME_CU,  a.VGE_CU,   a.MEINS_B_CU,  a.VGW_AL,  a.BME_AL,  a.VGE_AL,  a.MEINS_B_AL,  a.NES_FI,
           a.VGW_FI,  a.BME_FI,  a.VGE_FI,  a.MEINS_B_FI, a.NES_AL, a.MWSKZ  ,   a.vkbur,  a.VKBUR_N,  a.vkgrp,  a.VKGRP_N 
