@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 별 비철 중량 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_NF_VALUE 
as select from ekpo as A inner join marc as B on A.matnr = B.matnr and A.werks = B.werks
association [0..1] to ZGTMM_CV_GET_NFWEIGHT_PLANT as PNF1 on $projection.matnr = PNF1.matnr and PNF1.nes = 'CU'  and $projection.werks = PNF1.werks 
association [0..1] to ZGTMM_CV_GET_NFWEIGHT_PLANT as PNF2 on $projection.matnr = PNF2.matnr and PNF2.nes = 'AL'  and $projection.werks = PNF2.werks
association [0..1] to ZGTMM_CV_GET_NFWEIGHT_PLANT as PNF3 on $projection.matnr = PNF3.matnr and PNF3.nes = 'FI'  and $projection.werks = PNF3.werks

{
  key A.ebeln,
  key A.ebelp,
      A.matnr,
      A.werks,
          case when PNF1.nes is not null then PNF1.nes else cast('' as /nfm/nes ) end as NES_CU,
          @Semantics.quantity.unitOfMeasure: 'BME_CU'             
          case when PNF1.Vgw is not null then PNF1.Vgw else cast(0 as /nfm/vgw) end as VGW_CU,
          case when PNF1.bme is not null then PNF1.bme else cast('' as unit) end as BME_CU,
          case when PNF1.vge is not null then PNF1.vge else cast(1 as /nfm/vge) end as VGE_CU,
          case when PNF1.meins is not null then PNF1.meins else cast('' as unit) end as MEINS_B_CU,    
          @Semantics.quantity.unitOfMeasure: 'BME_CU'          
           case when PNF1.Vgw is not null then 
               cast(( A.menge * PNF1.Vgw ) / PNF1.vge as /nfm/vgw )
               else cast(0 as /nfm/vgw) end as VGW_T_CU,
                     
          
          case when PNF2.nes is not null then PNF2.nes else cast('' as /nfm/nes ) end as NES_AL,
          @Semantics.quantity.unitOfMeasure: 'BME_AL'             
          case when PNF2.Vgw is not null then PNF2.Vgw else cast(0 as /nfm/vgw) end as VGW_AL,
          case when PNF2.bme is not null then PNF2.bme else cast('' as unit) end as BME_AL,
          case when PNF2.vge is not null then PNF2.vge else cast(1 as /nfm/vge) end as VGE_AL,
          case when PNF2.meins is not null then PNF2.meins else cast('' as unit) end as MEINS_B_AL,
          @Semantics.quantity.unitOfMeasure: 'BME_AL'          
           case when PNF2.Vgw is not null then 
               cast(( A.menge * PNF2.Vgw ) / PNF2.vge as /nfm/vgw )
               else cast(0 as /nfm/vgw) end as VGW_T_AL,          
          
          
          case when PNF3.nes is not null then PNF3.nes else cast('' as /nfm/nes ) end as NES_FI,
          @Semantics.quantity.unitOfMeasure: 'BME_AL'             
          case when PNF3.Vgw is not null then PNF3.Vgw else cast(0 as /nfm/vgw) end as VGW_FI,
          case when PNF3.bme is not null then PNF3.bme else cast('' as unit) end as BME_FI,
          case when PNF3.vge is not null then PNF3.vge else cast(1 as /nfm/vge) end as VGE_FI,
          case when PNF3.meins is not null then PNF3.meins else cast('' as unit) end as MEINS_B_FI,
          @Semantics.quantity.unitOfMeasure: 'BME_FI'          
           case when PNF3.Vgw is not null then 
               cast(( A.menge * PNF3.Vgw ) / PNF3.vge as /nfm/vgw )
               else cast(0 as /nfm/vgw) end as VGW_T_FI                        
}   
