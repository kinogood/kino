@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 단가 계산식 RAW DATA'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_CAL_RAW 
with parameters 
    p_datE : datum
as select from ZGTMM_CV_GET_INFOPRICE as A inner join t024e as B on A.ekorg = B.ekorg
                                           inner join mara as c on A.matnr = c.matnr
association [0..*] to ZGTSD_I_MaterialCharacteristic as S1 on $projection.matnr = S1.matnr and S1.atnam = 'PD_CA_VOLTAGE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S2 on $projection.matnr = S2.matnr and S2.atnam = 'PD_AA_STD_PRODUCT_NAME'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S3 on $projection.matnr = S3.matnr and S3.atnam = 'PD_CA_CORE_NO_1ST'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S4 on $projection.matnr = S4.matnr and S4.atnam = 'PD_CA_COND_SIZE_1ST'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S5 on $projection.matnr = S5.matnr and S5.atnam = 'PD_CA_CORE_NO_2ND'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S6 on $projection.matnr = S6.matnr and S6.atnam = 'PD_CA_COND_SIZE_2ND'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S7 on $projection.matnr = S7.matnr and S7.atnam = 'PD_CA_SPEC_NO'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S8 on $projection.matnr = S8.matnr and S8.atnam = 'PD_CA_COLOR_BASE'
association [0..*] to ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N1 on $projection.matnr = N1.matnr and $projection.werks = N1.werks and N1.nes= 'AL'
association [0..*] to ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N2 on $projection.matnr = N2.matnr and $projection.werks = N2.werks and N2.nes= 'AU'
association [0..*] to ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N3 on $projection.matnr = N3.matnr and $projection.werks = N3.werks and N3.nes= 'CU'
association [0..*] to ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N4 on $projection.matnr = N4.matnr and $projection.werks = N4.werks and N4.nes= 'FI'
association [0..*] to ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N5 on $projection.matnr = N5.matnr and $projection.werks = N5.werks and N5.nes= 'NI'
association [0..*] to ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N6 on $projection.matnr = N6.matnr and $projection.werks = N6.werks and N6.nes= 'PB'
association [0..*] to ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N7 on $projection.matnr = N7.matnr and $projection.werks = N7.werks and N7.nes= 'SN'



{
  key A.lifnr,
  key A.matnr,  
  key A.ekorg,
  key A.werks,
  key A.esokz,
      B.bukrs,
      A.LIFNR_N,
      A.MATNR_N,
      A.EKORG_N,
      A.WERKS_N,
      A.ESKOZ_N,
      A.EKGRP_N,
      A.MWSKZ_N,
      S1.atwrt as VOLTAGE1,
      S2.atwrt as PRODUCT_NAME1,
      S3.atwrt as NO_1ST,
      S4.atwrt as SIZE_1ST,
      S5.atwrt as NO_2ND,
      S6.atwrt as SIZE_2ND,      
      S7.atwrt as SPEC_NO,
      S8.atwrt as COLOR,
      @Semantics.amount.currencyCode: 'KONWA'
      A.kbetr,
      A.konwa,
      A.kpein,
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
      A.EINE_LOEKZ,
      case when N1.nes is not null then N1.nes else cast('' as /nfm/nes) end as AL_NES,      
      @Semantics.quantity.unitOfMeasure: 'AL_BME'         
      case when N1.nes is not null then N1.kgw else cast(0 as /nfm/kgw) end as AL_KGW,
      case when N1.nes is not null then N1.bme else cast('' as meins) end as AL_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      case when N1.nes is not null then N1.kgu else cast(0 as /nfm/kgu) end as AL_KGU,
          
      case when N2.nes is not null then N2.nes else cast('' as /nfm/nes) end as AU_NES,   
      @Semantics.quantity.unitOfMeasure: 'AU_BME'         
      case when N2.nes is not null then N2.kgw else cast(0 as /nfm/kgw) end as AU_KGW,
      case when N2.nes is not null then N2.bme else cast('' as meins) end as AU_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      case when N2.nes is not null then N2.kgu else cast(0 as /nfm/kgu) end as AU_KGU,      

      case when N3.nes is not null then N3.nes else cast('' as /nfm/nes) end as CU_NES,         
      @Semantics.quantity.unitOfMeasure: 'CU_BME'         
      case when N3.nes is not null then N3.kgw else cast(0 as /nfm/kgw) end as CU_KGW,
      case when N3.nes is not null then N3.bme else cast('' as meins) end as CU_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      case when N3.nes is not null then N3.kgu else cast(0 as /nfm/kgu) end as CU_KGU,     
      
      case when N4.nes is not null then N4.nes else cast('' as /nfm/nes) end as FI_NES,       
      @Semantics.quantity.unitOfMeasure: 'FI_BME'         
      case when N4.nes is not null then N4.kgw else cast(0 as /nfm/kgw) end as FI_KGW,
      case when N4.nes is not null then N4.bme else cast('' as meins) end as FI_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      case when N4.nes is not null then N4.kgu else cast(0 as /nfm/kgu) end as FI_KGU,       

      case when N5.nes is not null then N5.nes else cast('' as /nfm/nes) end as NI_NES,        
      @Semantics.quantity.unitOfMeasure: 'NI_BME'         
      case when N5.nes is not null then N5.kgw else cast(0 as /nfm/kgw) end as NI_KGW,
      case when N5.nes is not null then N5.bme else cast('' as meins) end as NI_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      case when N5.nes is not null then N5.kgu else cast(0 as /nfm/kgu) end as NI_KGU,      
  
      case when N6.nes is not null then N6.nes else cast('' as /nfm/nes) end as PB_NES,        
      @Semantics.quantity.unitOfMeasure: 'PB_BME'         
      case when N6.nes is not null then N6.kgw else cast(0 as /nfm/kgw) end as PB_KGW,
      case when N6.nes is not null then N6.bme else cast('' as meins) end as PB_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      case when N6.nes is not null then N6.kgu else cast(0 as /nfm/kgu) end as PB_KGU,            

      case when N7.nes is not null then N7.nes else cast('' as /nfm/nes) end as SN_NES,          
      @Semantics.quantity.unitOfMeasure: 'SN_BME'         
      case when N7.nes is not null then N7.kgw else cast(0 as /nfm/kgw) end as SN_KGW,
      case when N7.nes is not null then N7.bme else cast('' as meins) end as SN_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      case when N7.nes is not null then N7.kgu else cast(0 as /nfm/kgu) end as SN_KGU                      

  
} where A.EINA_LOEKZ = ''  and ( A.mtart = 'MCFE' or A.mtart = 'MCHA' or A.mtart = 'HAWA') and A.datab <= $parameters.p_datE and A.datbi >= $parameters.p_datE
    and A.esokz = '0' and c.lvorm = '' and A.EINE_LOEKZ = ''
