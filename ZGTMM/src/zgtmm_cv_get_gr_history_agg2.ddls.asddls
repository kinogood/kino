@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매입고 현황 중간 집계2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GR_HISTORY_AGG2 
as select from ZGTMM_CV_GET_GR_HISTORY_AGG  as A  
association [1..1] to ZGTMM_CV_GET_INFOPRICE as B on $projection.lifnr = B.lifnr and $projection.matnr = B.matnr 
                                                 and $projection.ekorg = B.ekorg and $projection.werks = B.werks
                                                 and $projection.PSTYP = B.esokz and B.datab <= $projection.budat and B.datbi >= $projection.budat 
association [0..1] to ZGTMM_CV_GET_NF_VALUE as NF on $projection.ebeln = NF.ebeln and $projection.ebelp = NF.ebelp 
association [0..1] to zgtmmt5020 as TAX on $projection.lifnr = TAX.lifnr and $projection.vbeln = TAX.vbeln and $projection.POSNR = TAX.posnr and $projection.SPMON = TAX.spmon      
                                       and $projection.ebeln = TAX.ebeln and $projection.ebelp = TAX.ebelp
association [0..1] to t001w as t001w on $projection.werks = t001w.werks  
association [0..1] to lfa1 as lfa1 on $projection.lifnr = lfa1.lifnr 
association [0..1] to tvkbt as TVKBT on $projection.vkbur = TVKBT.vkbur and TVKBT.spras = $session.system_language
association [0..1] to tvgrt as TVGRT on $projection.vkgrp = TVGRT.vkgrp and TVGRT.spras = $session.system_language
{
  key A.ebeln,
  key A.ebelp, 
      A.bukrs,
      A.werks,
      t001w.name1 as werks_n,      
      A.ekorg,
      A.ekgrp,
      A.lifnr,
      lfa1.name1 as lifnr_n,      
      A.PSTYP,
      A.vbeln,
      A.POSNR,
      A.vkbur,
      tvkbt.bezei as VKBUR_N,      
      A.vkgrp,
      tvgrt.bezei as VKGRP_N,
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
      A.SPMON,  
      @Semantics.quantity.unitOfMeasure: 'ERFME'       
      A.erfmg,
      A.erfme,
      case when A.LENGTH <> ''  and A.LENGTH <> '1' then   
            cast(cast(A.erfmg as abap.dec(13,2)) / cast(A.LENGTH as abap.dec(13,2)) as abap.dec(13,0))  
          else cast(0 as abap.dec(13,0)) end as MATGR_dr,
      A.budat,
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      A.WH3410,
      cast(cast(A.WH3410 as abap.dec(13,2)) / cast(A.LENGTH as abap.dec(13,2)) as abap.dec(13,0)) as WH3410_DR,      
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      A.WH3420,       
      cast(cast(A.WH3420 as abap.dec(13,2)) / cast(A.LENGTH as abap.dec(13,2)) as abap.dec(13,0)) as WH3420_DR,      
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      A.WH3498,       
      cast(cast(A.WH3498 as abap.dec(13,2)) / cast(A.LENGTH as abap.dec(13,2)) as abap.dec(13,0)) as WH3498_DR,      
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      A.WH3497,       
      cast(cast(A.WH3497 as abap.dec(13,2)) / cast(A.LENGTH as abap.dec(13,2)) as abap.dec(13,0)) as WH3497_DR,      
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      A.WHETC,
      cast(cast(A.WHETC as abap.dec(13,2)) / cast(A.LENGTH as abap.dec(13,2)) as abap.dec(13,0)) as WHETC_DR,      
      @Semantics.amount.currencyCode: 'KONWA'    
      case when B.kbetr is not null then B.kbetr else cast(0 as kbetr_kond) end as kbetr,
      case when B.konwa is not null then B.konwa else cast('' as konwa) end as KONWA,   
      case when B.kpein is not null then B.kpein else cast(1 as kpein) end as KPEIN,   
      case when B.kmein is not null then B.kmein else cast('' as kmein) end as KMEIN,

      @Semantics.amount.currencyCode: 'KONWA'      
      case when B.kbetr is not null then
        case when B.kpein > 0 then 
          cast(cast(A.erfmg * cast(B.kbetr as abap.dec(13,2)) / cast(B.kpein as abap.dec(13,2)) as abap.dec(13,2)) as abap.curr(13,2))  
         else
          cast(A.erfmg * cast(B.kbetr as abap.dec(13,2)) as abap.curr(13,2))  
         end
        else
         cast(0 as abap.curr(13,2)) 
       end as totalprice,
  
       NF.NES_CU,
       @Semantics.quantity.unitOfMeasure: 'BME_CU'             
       NF.VGW_CU,  //단위량(KG)
       NF.BME_CU,  //단위
       NF.VGE_CU,  //PER
       NF.MEINS_B_CU,//기본단위    
       @Semantics.quantity.unitOfMeasure: 'BME_CU'              
       case when NF.VGW_CU > 0 then 
              cast(cast(( A.erfmg * NF.VGW_CU ) / NF.VGE_CU as /nfm/vgw ) as abap.quan(15,3))
                   else cast(0 as /nfm/vgw) end as VGW_T_CU,
              
       NF.NES_AL,
       @Semantics.quantity.unitOfMeasure: 'BME_AL'             
       NF.VGW_AL,
       NF.BME_AL,
       NF.VGE_AL,
       NF.MEINS_B_AL,
       @Semantics.quantity.unitOfMeasure: 'BME_AL'          
       case when NF.VGW_AL > 0 then 
              cast(cast(( A.erfmg * NF.VGW_AL ) / NF.VGE_AL as /nfm/vgw ) as abap.quan(15,3))
                   else cast(0 as /nfm/vgw) end as VGW_T_al, 
       NF.NES_FI,
       @Semantics.quantity.unitOfMeasure: 'BME_FI'             
       NF.VGW_FI,
       NF.BME_FI,
       NF.VGE_FI,
       NF.MEINS_B_FI,
       @Semantics.quantity.unitOfMeasure: 'BME_FI'          
       case when NF.VGW_FI > 0 then 
              cast(cast(( A.erfmg * NF.VGW_FI ) / NF.VGE_FI as /nfm/vgw ) as abap.quan(15,3))
                   else cast(0 as /nfm/vgw) end as VGW_T_fi,
       case when TAX.mwskz is not null then TAX.mwskz else A.mwskz end as MWSKZ               
 }
