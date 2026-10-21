@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '납품서 기준 입고 현황 레포팅'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GODELIVERY_LAST 
as select from ZGTMM_CV_GET_GODELIVERY_REPORT as A 
association [1..1] to ZGTMM_CV_GET_INFOPRICE as B on $projection.lifnr = B.lifnr and $projection.matnr = B.matnr 
                                                 and $projection.ekorg = B.ekorg and $projection.werks = B.werks
                                                 and $projection.PSTYP = B.esokz and B.datab <= $projection.BUDAT and B.datbi >= $projection.BUDAT 
association [0..1] to ZGTMM_CV_GET_NF_VALUE as NF on $projection.ebeln = NF.ebeln and $projection.ebelp = NF.ebelp and ( NF.NES_AL <> '' or NF.NES_CU <> '' and NF.NES_FI <> '')
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
  
  A.DELNO ,
  A.delitem,
  A.BUDAT ,   
  cast(left(A.BUDAT,6) as spmon) as spmon,  
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT'         
  A.DL_QTY,
  A.DL_UNIT,  
   
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT'         
  A.GR_QTY,
  A.GR_UNIT,
  A.LGORT,
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  A.WH3410,
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  A.WH3420,       
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  A.WH3498,       
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  A.WH3497,       
       
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  A.WHETC,
  @Semantics.amount.currencyCode: 'KONWA'    
  case when B.kbetr is not null then B.kbetr else cast(0 as kbetr_kond) end as kbetr,
  case when B.konwa is not null then B.konwa else cast('' as konwa) end as KONWA,   
  case when B.kpein is not null then B.kpein else cast(1 as kpein) end as KPEIN,   
  case when B.kmein is not null then B.kmein else cast('' as kmein) end as KMEIN,

  @Semantics.amount.currencyCode: 'KONWA'      
  case when B.kbetr is not null then
      case when B.kpein > 0 then 
        cast(cast(A.GR_QTY * cast(B.kbetr as abap.dec(13,2)) / cast(B.kpein as abap.dec(13,2)) as abap.dec(13,2)) as abap.curr(13,2))  
        else
         cast(A.GR_QTY * cast(B.kbetr as abap.dec(13,2)) as abap.curr(13,2))  
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
          cast(( A.GR_QTY * NF.VGW_CU ) / NF.VGE_CU as /nfm/vgw )
               else cast(0 as /nfm/vgw) end as VGW_T_CU,  
          
   NF.NES_AL,
   @Semantics.quantity.unitOfMeasure: 'BME_AL'             
   NF.VGW_AL,
   NF.BME_AL,
   NF.VGE_AL,
   NF.MEINS_B_AL,
   @Semantics.quantity.unitOfMeasure: 'BME_AL'          
   case when NF.VGW_AL > 0 then 
          cast(( A.GR_QTY * NF.VGW_AL ) / NF.VGE_AL as /nfm/vgw )
               else cast(0 as /nfm/vgw) end as VGW_T_al,  

   NF.NES_FI,
   @Semantics.quantity.unitOfMeasure: 'BME_FI'             
   NF.VGW_FI,
   NF.BME_FI,
   NF.VGE_FI,
   NF.MEINS_B_FI,
   @Semantics.quantity.unitOfMeasure: 'BME_FI'          
   case when NF.VGW_FI > 0 then 
          cast(( A.GR_QTY * NF.VGW_FI ) / NF.VGE_FI as /nfm/vgw )
               else cast(0 as /nfm/vgw) end as VGW_T_fi,
   A.mwskz                               
}
