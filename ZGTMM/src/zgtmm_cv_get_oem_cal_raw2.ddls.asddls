@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 단가 계산식 RAW DATA2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_CAL_RAW2 
with parameters 
    p_datE : datum,
    p_mon : spmon
as select from ZGTMM_CV_GET_OEM_CAL_RAW(p_datE:  $parameters.p_datE) as A        
association [0..*] to ZGTMM_CV_GET_LMC_MONTHLY_CAL   as S1 on S1.BUKRS = $projection.bukrs and S1.CMON = $parameters.p_mon
association [0..*] to ZGTMM_CV_GET_EXRATE_MONTHLY as E1 on E1.period = $parameters.p_mon and E1.TYPE = 'TTS' and E1.currency = 'USD' 
association [0..*] to ZGTMM_CV_GET_EXRATE_MONTHLY as E2 on E2.period = $parameters.p_mon and E2.TYPE = 'TTM' and E2.currency = 'USD' 
association [0..*] to ZGTMM_CV_GET_TARGET_IVSUM  as I1 on $projection.lifnr = I1.lifnr and $projection.ekorg =I1.ekorg and $projection.matnr =I1.matnr and I1.SPMON =  $parameters.p_mon and $projection.werks =I1.werks 
association [0..*] to ZGTMM_CV_GET_PODATA_MON  as P1 on $projection.lifnr = P1.lifnr and $projection.ekorg =P1.ekorg and $projection.matnr = P1.matnr
association [0..*] to zgtmmt1112 as BOM on $projection.infnr = BOM.infnr and $projection.matnr = BOM.matnr and $projection.lifnr = BOM.lifnr and $projection.ekorg = BOM.ekorg and $projection.esokz = BOM.esokz and $projection.werks = BOM.werks
association [0..*] to ZGTMM_CV_GET_MARV_CLOSING as CL on $projection.bukrs = CL.bukrs and CL.PERIOD = $parameters.p_mon

 

{
  key A.lifnr,
  key A.matnr,  
  key A.ekorg,
  key A.werks,
  key A.esokz,
      A.bukrs,
      A.LIFNR_N,
      A.MATNR_N,
      A.EKORG_N,
      A.WERKS_N,
      A.ESKOZ_N,
      A.EKGRP_N,
      A.MWSKZ_N,
      CONCAT(A.VOLTAGE1, CONCAT(' ' ,A.PRODUCT_NAME1) ) as PRDNAME,
      case when SIZE_2ND <> '' then concat(concat(concat(concat(concat(concat(A.NO_1ST, 'X'),A. SIZE_1ST),'+'),A.NO_2ND),'X'),SIZE_2ND)
           else concat(concat(A.NO_1ST, 'X'),A. SIZE_1ST) end as PRODSIZE,      
      A.SPEC_NO,
      A.EINE_LOEKZ,
      A.COLOR,
      @Semantics.amount.currencyCode: 'KONWA'
      A.kbetr,
      A.konwa,
              
      case when A.CU_KGU > 0 
           then
                case when A.CU_KGU = A.kpein 
                     then A.kpein 
                     else cast(A.CU_KGU as kpein) end
           when A.AL_KGU > 0 then 
                 case when A.AL_KGU = A.kpein 
                     then A.kpein 
                     else cast(A.AL_KGU as kpein) end            
           else A.kpein end as kpein,
      
      A.kmein,
      A.knumh,
      A.mwskz,
      A.aplfz,
      A.ekgrp,
      @Semantics.quantity.unitOfMeasure: 'MEINS'        
      A.norbm,
      A.uebto,
      A.untto,
      A.uebtk,
      A.verid,
      A.webre,
      A.xersn,
      A.bstae,
      A.BSTAE_N,
      A.meprf,
      A.MEPRF_N,
      A.inco1,
      A.inco1_n,
      A.idnlf,
      A.infnr,
      A.meins,
      A.mtart,
      
      cast('USD' as abap.cuky) as FWAERS,
      cast('KRW' as abap.cuky) as KWAERS,   
      case when E1.EXRATE is not null then E1.EXRATE else cast(0 as abap.dec(9,5)) end as TTS,
      case when E2.EXRATE is not null then E2.EXRATE else cast(0 as abap.dec(9,5)) end as TTM,   
      A.AL_NES,      
      @Semantics.quantity.unitOfMeasure: 'AL_BME'         
      A.AL_KGW,
      A.AL_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      A.AL_KGU,
      
      @Semantics.amount.currencyCode: 'AL_PERMIUM_WAERS'    
      case when S1.AL_PREMIUM is null then cast(0 as abap.curr(11,2))
           else S1.AL_PREMIUM end as AL_PREMIUM,
           
      case when S1.AL_PRWAERS is null then cast('' as abap.cuky)
           else S1.AL_PRWAERS end as AL_PERMIUM_WAERS,
      case when S1.AL_CRATE is null then cast(0 as abap.dec(3,1))
           else S1.AL_CRATE end  as AL_CRATE,
      @Semantics.amount.currencyCode: 'AL_Mwaers'     
      case when S1.AL_MCOST is null then cast(0 as abap.curr(11,2))
           else S1.AL_MCOST end as AL_MCOST,
      case when S1.AL_MPER is null then cast(0 as abap.dec(5,0))
           else S1.AL_MPER end as AL_PER,
      case when S1.AL_MUNIT is null then cast('' as abap.unit(3))
           else S1.AL_MUNIT end  as AL_MUNIT,      
      case when S1.AL_MWAERS is null then cast('' as abap.cuky)
           else S1.AL_MWAERS end as AL_MWAERS,
      case when S1.AL_KURST is null then cast('' as abap.char(4))
           else S1.AL_KURST end as AL_KURST,
      cast('AL' as abap.char(2)) as AL_METAL,
      case when S1.CMON is null then cast('' as spmon)
           else S1.CMON end as AL_PERIOD,
      @Semantics.amount.currencyCode: 'FWAERS'   
      case when S1.AL_CASH is null then cast(0 as oic_price)
           else S1.AL_CASH end  as AL_PRICE,
      case when S1.AL_WAERS is null then cast('' as abap.cuky)
           else S1.AL_WAERS end as AL_CURRENCY ,   
           
      cast(1000 as oic_defper) as AL_LMEPER,
      cast('KG' as oic_defuom) as AL_MEINS,
           
      @Semantics.amount.currencyCode: 'KWAERS'          
      case when S1.AL_lmc is not null then
                S1.AL_lmc
           else
             cast(0 as abap.curr(12,2))
           end as AL_SLMC,
            
      A.AU_NES,   
      @Semantics.quantity.unitOfMeasure: 'AU_BME'         
      A.AU_KGW,
      A.AU_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      A.AU_KGU,      

      @Semantics.amount.currencyCode: 'AU_PERMIUM_WAERS'    
      cast(0 as abap.curr(11,2)) as AU_PREMIUM,
           
      cast('' as abap.cuky) as AU_PERMIUM_WAERS,
      cast(0 as abap.dec(3,1)) as AU_CRATE,
      @Semantics.amount.currencyCode: 'AU_Mwaers'     
      cast(0 as abap.curr(11,2)) as AU_MCOST,
      cast(0 as abap.dec(5,0)) as AU_PER,
      cast('' as abap.unit(3))  as AU_MUNIT,      
      cast('' as abap.cuky) as AU_MWAERS,
      cast('' as abap.char(4)) as AU_KURST,
      cast('' as abap.char(2)) as AU_METAL,
      cast('' as spmon) as AU_PERIOD,
      @Semantics.amount.currencyCode: 'FWAERS'   
      cast(0 as oic_price) as AU_PRICE,
      cast('' as abap.cuky)as AU_CURRENCY ,
      cast(0 as abap.dec(5,0)) as AU_LMEPER,
      cast('' as abap.unit(3)) as AU_MEINS,
      @Semantics.amount.currencyCode: 'KWAERS'          
      cast(0 as abap.curr(13,2)) as AU_SLMC,

      A.CU_NES,         
      @Semantics.quantity.unitOfMeasure: 'CU_BME'         
      A.CU_KGW,
      A.CU_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      A.CU_KGU,     


      @Semantics.amount.currencyCode: 'CU_PERMIUM_WAERS'    
      case when S1.CU_PREMIUM is null then cast(0 as abap.curr(11,2))
           else S1.CU_PREMIUM end as CU_PREMIUM,
           
      case when S1.CU_PRWAERS is null then cast('' as abap.cuky)
           else S1.CU_PRWAERS end as CU_PERMIUM_WAERS,
      case when S1.CU_CRATE is null then cast(0 as abap.dec(3,1))
           else S1.CU_CRATE end  as CU_CRATE,
      @Semantics.amount.currencyCode: 'CU_Mwaers'     
      case when S1.CU_MCOST is null then cast(0 as abap.curr(11,2))
           else S1.CU_MCOST end as CU_MCOST,
      case when S1.CU_MPER is null then cast(0 as abap.dec(5,0))
           else S1.CU_MPER end as CU_PER,
      case when S1.CU_MUNIT is null then cast('' as abap.unit(3))
           else S1.CU_MUNIT end  as CU_MUNIT,      
      case when S1.CU_MWAERS is null then cast('' as abap.cuky)
           else S1.CU_MWAERS end as CU_MWAERS,
      case when S1.CU_KURST is null then cast('' as abap.char(4))
           else S1.CU_KURST end as CU_KURST,
      cast('CU' as abap.char(2)) as CU_METAL,
      case when S1.CMON is null then cast('' as spmon)
           else S1.CMON end as CU_PERIOD,
      @Semantics.amount.currencyCode: 'FWAERS'   
      case when S1.CU_CASH is null then cast(0 as oic_price)
           else S1.CU_CASH end  as CU_PRICE,
      case when S1.CU_WAERS is null then cast('' as abap.cuky)
           else S1.CU_WAERS end as CU_CURRENCY ,
      cast(1000 as oic_defper) as CU_LMEPER,
      cast('KG' as oic_defuom) as CU_MEINS,
      @Semantics.amount.currencyCode: 'KWAERS'          
      case when S1.CU_lmc is not null then
              S1.CU_lmc
           else
             cast(0 as abap.curr(13,2))
           end as CU_SLMC,

      @Semantics.amount.currencyCode: 'KWAERS'          
      case when S1.CU_lmc is not null then
              S1.CU_lmc
           else
             cast(0 as abap.curr(13,2))
           end as CU_LMC,
      
      A.FI_NES,       
      @Semantics.quantity.unitOfMeasure: 'FI_BME'         
      A.FI_KGW,
      A.FI_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      A.FI_KGU,       

      @Semantics.amount.currencyCode: 'FI_PERMIUM_WAERS'    
      cast(0 as abap.curr(11,2))as FI_PREMIUM,
      cast('' as abap.cuky) as FI_PERMIUM_WAERS,
      cast(0 as abap.dec(3,1)) as FI_CRATE,
      @Semantics.amount.currencyCode: 'FI_Mwaers'     
      cast(0 as abap.curr(11,2)) as FI_MCOST,
      cast(0 as abap.dec(5,0)) as FI_PER,
      cast('' as abap.unit(3)) as FI_MUNIT,      
      cast('' as abap.cuky) as FI_MWAERS,
      cast('' as abap.char(4)) as FI_KURST,
      cast('' as abap.char(2)) as FI_METAL,
      cast('' as spmon) as FI_PERIOD,
      @Semantics.amount.currencyCode: 'FWAERS'   
      cast(0 as oic_price) as FI_PRICE,
      cast('' as abap.cuky) as FI_CURRENCY ,
      cast(0 as abap.dec(5,0)) as FI_LMEPER,
      cast('' as abap.unit(3)) as FI_MEINS,
      @Semantics.amount.currencyCode: 'KWAERS'          
      cast(0 as abap.curr(11,2))as FI_SLMC,

      A.NI_NES,        
      @Semantics.quantity.unitOfMeasure: 'NI_BME'         
      A.NI_KGW,
      A.NI_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      A.NI_KGU,      

      @Semantics.amount.currencyCode: 'NI_PERMIUM_WAERS'    
      cast(0 as abap.curr(11,2)) as NI_PREMIUM,
      cast('' as abap.cuky) as NI_PERMIUM_WAERS,
      cast(0 as abap.dec(3,1)) as NI_CRATE,
      @Semantics.amount.currencyCode: 'NI_Mwaers'     
      cast(0 as abap.curr(11,2)) as NI_MCOST,
      cast(0 as abap.dec(5,0)) as NI_PER,
      cast('' as abap.unit(3)) as NI_MUNIT,      
      cast('' as abap.cuky) as NI_MWAERS,
      cast('' as abap.char(4)) as NI_KURST,
      cast('' as abap.char(2)) as NI_METAL,
      cast('' as spmon) as NI_PERIOD,
      @Semantics.amount.currencyCode: 'FWAERS'   
      cast(0 as oic_price) as NI_PRICE,
      cast('' as abap.cuky) as NI_CURRENCY ,
      cast(0 as abap.dec(5,0)) as NI_LMEPER,
      cast('' as abap.unit(3)) as NI_MEINS,
      @Semantics.amount.currencyCode: 'KWAERS'          
      cast(0 as abap.curr(13,2)) as NI_SLMC,
  
      A.PB_NES,        
      @Semantics.quantity.unitOfMeasure: 'PB_BME'         
      A.PB_KGW,
      A.PB_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      A.PB_KGU,            

      @Semantics.amount.currencyCode: 'PB_PERMIUM_WAERS'    
      cast(0 as abap.curr(11,2)) as PB_PREMIUM,           
      cast('' as abap.cuky) as PB_PERMIUM_WAERS,
      cast(0 as abap.dec(3,1)) as PB_CRATE,
      @Semantics.amount.currencyCode: 'PB_Mwaers'     
      cast(0 as abap.curr(11,2)) as PB_MCOST,
      cast(0 as abap.dec(5,0)) as PB_PER,
      cast('' as abap.unit(3)) as PB_MUNIT,      
      cast('' as abap.cuky) as PB_MWAERS,
      cast('' as abap.char(4)) as PB_KURST,
      cast('PB' as abap.char(2)) as PB_METAL,
      case when S1.CMON is null then cast('' as spmon)
           else S1.CMON end as PB_PERIOD,
      @Semantics.amount.currencyCode: 'FWAERS'   
      case when S1.PB_CASH is null then cast(0 as oic_price)
           else S1.PB_CASH end  as PB_PRICE,
      case when S1.PB_WAERS is null then cast('' as abap.cuky)
           else S1.PB_WAERS end as PB_CURRENCY ,
      cast(1000 as oic_defper) as PB_LMEPER,
      cast('KG' as oic_defuom) as PB_MEINS,
      @Semantics.amount.currencyCode: 'KWAERS'          
      cast(0 as abap.curr(13,2)) as PB_SLMC,

      A.SN_NES,          
      @Semantics.quantity.unitOfMeasure: 'SN_BME'         
      A.SN_KGW,
      A.SN_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      A.SN_KGU,
      
      @Semantics.amount.currencyCode: 'SN_PERMIUM_WAERS'    
      cast(0 as abap.curr(11,2)) as SN_PREMIUM,
      cast('' as abap.cuky) as SN_PERMIUM_WAERS,
      cast(0 as abap.dec(3,1)) as SN_CRATE,
      @Semantics.amount.currencyCode: 'SN_Mwaers'     
      cast(0 as abap.curr(11,2)) as SN_MCOST,
      cast(0 as abap.dec(5,0)) as SN_PER,
      cast('' as abap.unit(3)) as SN_MUNIT,      
      cast('' as abap.cuky) as SN_MWAERS,
      cast('' as abap.char(4)) as SN_KURST,
      cast('' as abap.char(2)) as SN_METAL,
      cast('' as spmon) as SN_PERIOD,
      @Semantics.amount.currencyCode: 'FWAERS'   
      cast(0 as oic_price) as SN_PRICE,
      cast('' as abap.cuky) as SN_CURRENCY ,
      cast(0 as abap.dec(5,0)) as SN_LMEPER,
      cast('' as abap.unit(3)) as SN_MEINS,
      @Semantics.amount.currencyCode: 'KWAERS'          
      cast(0 as abap.curr(13,2)) as SN_SLMC    ,
           
      P1.BEDAT as LAST_PO_DATE,
      @Semantics.quantity.unitOfMeasure: 'GRMEINS'           
      case when I1.IV_QTY is not null then I1.IV_QTY else cast(0 as abap.quan(13,2)) end as GR_QTY,
      I1.IV_UNIT as GRMEINS ,
      
      @Semantics.amount.currencyCode: 'KWAERS'   
      case when BOM.scr_sc is not null then BOM.scr_sc else cast(0 as abap.curr(11,2)) end as SCR_SC,
      
      @Semantics.quantity.unitOfMeasure: 'KGMEINS'   
      case when BOM.cu_c_qty is not null then BOM.cu_c_qty else cast(0 as abap.quan(13,2)) end as cu_c_qty,
      case when BOM.al_c_spec is not null then BOM.al_c_spec else cast('' as abap.char(20)) end as al_c_spec,
      @Semantics.quantity.unitOfMeasure: 'KGMEINS' 
      case when BOM.al_c_qty is not null then BOM.al_c_qty else cast(0 as abap.quan(13,2)) end as al_c_qty,  
      cast('KG' as meins) as kgmeins,
      @Semantics.quantity.unitOfMeasure: 'KGMEINS'  
      case when BOM.cu_s_qty is not null then BOM.cu_s_qty else cast(0 as abap.quan(13,2)) end as cu_s_qty,         
      BOM.al_s_spec,
      @Semantics.quantity.unitOfMeasure: 'KGMEINS'   
      case when BOM.al_s_qty is not null then BOM.al_s_qty else cast(0 as abap.quan(13,2)) end as al_s_qty,        
      @Semantics.quantity.unitOfMeasure: 'KGMEINS'   
      case when BOM.cu_t_qty is not null then BOM.cu_t_qty else cast(0 as abap.quan(13,2)) end as cu_t_qty,
  
      @Semantics.amount.currencyCode: 'KWAERS'   
      case when BOM.s_mat_cost is not null then BOM.s_mat_cost else cast(0 as abap.curr(11,2)) end as S_MAT_COST,
      @Semantics.amount.currencyCode: 'KWAERS'   
      case when BOM.mfg_cost is not null then BOM.mfg_cost else cast(0 as abap.curr(11,2)) end as MFG_COST,
      @Semantics.amount.currencyCode: 'KWAERS'   
      case when BOM.pkg_cost is not null then BOM.pkg_cost else cast(0 as abap.curr(11,2)) end as PKG_COST,      
      @Semantics.amount.currencyCode: 'KWAERS'   
      case when BOM.etc_cost is not null then BOM.etc_cost else cast(0 as abap.curr(11,2)) end as ETC_COST,
      @Semantics.amount.currencyCode: 'KWAERS'   
      case when BOM.al_c_price is not null then BOM.al_c_price else cast(0 as abap.curr(11,2)) end as AL_C_PRICE,
      @Semantics.amount.currencyCode: 'KWAERS'   
      case when BOM.al_s_price is not null then BOM.al_s_price else cast(0 as abap.curr(11,2)) end as AL_S_PRICE,
      @Semantics.amount.currencyCode: 'KWAERS'   
      case when BOM.add_cost is not null then BOM.add_cost else cast(0 as abap.curr(11,2)) end as ADD_COST,
      case when CL.PERIOD is not null then cast('' as abap.char(1)) else cast('X' as abap.char(1)) end as CLOSING
      
} 
