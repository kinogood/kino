@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 정산 대상 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_IV_TARGET 
as select from ZGTMM_CV_GET_PO_GR_BYMON as A 
          left outer join vbap as V on A.vbeln = V.vbeln and A.POSNR = V.posnr
          left outer join ZGTMM_CV_GET_LMC_MONTHLY_CAL as LME on A.SPMON = LME.CMON and LME.MCHECK = 'O'
{
  key A.ebeln,
  key A.ebelp,
  key A.vbeln,
  key A.POSNR,
  key A.SPMON,  
      A.bukrs, 
      A.werks,
      A.lifnr,
      A.ekgrp,
      A.werks_n,
      A.lifnr_n,
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
         
      @Semantics.quantity.unitOfMeasure: 'MATGR_UNIT'     
      A.MATGR,
      A.MATGR_DR,  
      A.MATGR_UNIT,          

      A.vkbur,
      A.VKBUR_N,      
      A.vkgrp,
      A.VKGRP_N,    
    
      @Semantics.amount.currencyCode: 'KONWA'    
      A.kbetr,
      A.KONWA,   
      A.KPEIN,   
      A.KMEIN,
    
      @Semantics.amount.currencyCode: 'KONWA'      
      A.TOTALPRICE,
      @Semantics.amount.currencyCode: 'KONWA'     
      case when A.MWSKZ = 'VA' 
          then cast(cast(A.TOTALPRICE as abap.dec(11,2)) * cast(0.1 as abap.dec(11,2)) as abap.curr(11,2)) 
          else cast(0 as abap.curr(11,2)) end as TAXVALUE,
          
      LME.EXRATE_TTS,
      @Semantics.amount.currencyCode: 'CU_WAERS'        
      LME.CU_CASH,
      LME.CU_WAERS,
      @Semantics.amount.currencyCode: 'CU_KWAERS'
      LME.CU_lmc,
      LME.CU_KWAERS,
 
       @Semantics.amount.currencyCode: 'AL_WAERS'        
      LME.AL_CASH,
      LME.AL_WAERS,
      @Semantics.amount.currencyCode: 'AL_KWAERS'
      LME.AL_lmc,
      LME.AL_KWAERS,
      
      A.NES_CU,
      @Semantics.quantity.unitOfMeasure: 'BME_CU'             
      A.VGW_CU,  //단위량(KG)
      A.BME_CU,  //단위
      A.VGE_CU,  //PER
      A.MEINS_B_CU,//기본단위    
      @Semantics.quantity.unitOfMeasure: 'BME_CU'          
      A.VGW_T_CU, //총량(KG)
              
      A.NES_AL,
      @Semantics.quantity.unitOfMeasure: 'BME_AL'             
      A.VGW_AL,
      A.BME_AL,
      A.VGE_AL,
      A.MEINS_B_AL,
      @Semantics.quantity.unitOfMeasure: 'BME_AL'          
      A.VGW_T_al,          
              
      A.NES_FI,
      @Semantics.quantity.unitOfMeasure: 'BME_AL'             
      A.VGW_FI,
      A.BME_FI,
      A.VGE_FI,
      A.MEINS_B_FI,
      @Semantics.quantity.unitOfMeasure: 'BME_FI'          
      A.VGW_T_FI,
      case when V.mwsbp is not null then
           case when V.mwsbp > 0 then cast('VA' as abap.char(4))
                else cast('V1' as abap.char(4)) end
           else cast('' as abap.char(4)) end as MWSKZ_S,      
      case when V.mwsbp is not null then
           case when V.mwsbp > 0 then cast('과세' as abap.char(4))
                else cast('영세' as abap.char(4)) end
           else cast('' as abap.char(4)) end as MSWKZ_S_N,         
      A.MWSKZ as MWSKZ_P,
      A.text1 as MWSKZ_P_N
      
} where A.MATGR > 0
