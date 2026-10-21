@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '납품서 기준 입고 현황 레포팅'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GODELIVERY_REPORT 
as select from ekpo as A inner join ekkn as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
                         inner join ekko as Z on A.ebeln = Z.ebeln
                         left outer join ZGTMM_CV_GET_GODELIVERY_DATA2 as C on A.ebeln = C.ebeln and A.ebelp = C.ebelp and  C.cancelled = '' and C.reversal_movement = ''
association [1..1] to mara as D on $projection.matnr = D.matnr 
association [1..1] to ZGTSD_I_MaterialCharacteristic as C1 on $projection.matnr = C1.matnr and C1.atnam = 'PD_AA_STD_PRODUCT_NAME' 
association [1..1] to ZGTSD_I_MaterialCharacteristic as C2 on $projection.matnr = C2.matnr and C2.atnam = 'PD_CA_SPEC_NO'
association [1..1] to ZGTMM_CV_PO_VCVALUE_MAIN as C3 on $projection.ebeln = C3.PDOC and $projection.ebelp = C3.PDOCITEM
association [0..1] to ZGTMM_CV_SO_VCVALUE_MAIN as S3 on $projection.vbeln = S3.vbeln and $projection.POSNR = S3.posnr
{
  key A.ebeln,
  key A.ebelp,
  Z.bukrs,
  A.werks,
  Z.ekorg,
  Z.ekgrp,
  Z.lifnr,
  case when A.pstyp = '3' then cast('3' as esokz)
       else cast('0' as esokz) end as PSTYP,
  B.vbeln,
  B.vbelp as POSNR,
  A.matnr,
  case when D.zzmaktx80 is not null and D.zzmaktx80 <> '' then D.zzmaktx80 else A.txz01 end as MAKTX,
  case when C1.atwrt is not null then C1.atwrt else cast('' as atwrt) end as PRODNAME,
  case when C2.atwrt is not null then C2.atwrt else cast('' as atwrt) end as SPECNO,
  case when C3.COLOR is not null then C3.COLOR else cast('' as atwrt) end as COLOR ,
  @Semantics.quantity.unitOfMeasure: 'PO_MEINS'     
  A.menge as PO_QTY,
  A.meins as PO_MEINS,
  case when S3.LENGTH is not null then S3.LENGTH
       when C3.LENGTH is not null then C3.LENGTH else cast('' as atwrt) end as LENGTH ,
  case when C3.DRQTY is not null then C3.DRQTY  else cast('' as atwrt) end as DRQTY,

  case when C.delno is not null then C.delno else cast('' as zgte_mm_gsrm_delno) end as DELNO ,
  case when C.delitem is not null then C.delitem else cast('' as zgte_mm_gsrm_delitem) end as delitem,
  case when C.budat is not null then C.budat else cast('' as budat) end as BUDAT ,
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT'         
  case when C.menge is not null then C.menge else cast(0 as abap.quan(13,3)) end as DL_QTY,
  case when C.meins is not null then C.meins else cast('' as abap.unit) end as DL_UNIT,  
   
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT'         
  case when C.ERFMG is not null then C.ERFMG else cast(0 as abap.quan(13,3)) end as GR_QTY,
  case when C.ERFME is not null then 
    case when C.ERFME <> '' then C.ERFME else A.meins end
  else A.meins end as GR_UNIT,
  case when C.lgort is not null then C.lgort else cast('' as lgort_d) end as LGORT,
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  case when C.lgort is not null then
         case when C.lgort = '3410' then 
                 case when C.ERFMG is not null then C.ERFMG else cast(0 as abap.quan(13,3)) end      
              else cast(0 as abap.quan(13,3))      
              end
       else cast(0 as abap.quan(13,3))       
       end as WH3410,
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  case when C.lgort is not null then
         case when C.lgort = '3420' then 
                 case when C.ERFMG is not null then C.ERFMG else cast(0 as abap.quan(13,3)) end    
              else cast(0 as abap.quan(13,3))                        
              end
       else cast(0 as abap.quan(13,3))                  
       end as WH3420,       
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  case when C.lgort is not null then
         case when C.lgort = '3498' then 
                 case when C.ERFMG is not null then C.ERFMG else cast(0 as abap.quan(13,3)) end        
              else cast(0 as abap.quan(13,3))                    
              end
       else cast(0 as abap.quan(13,3))                  
       end as WH3498,       
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  case when C.lgort is not null then
         case when C.lgort = '3497' then 
                 case when C.ERFMG is not null then C.ERFMG else cast(0 as abap.quan(13,3)) end     
              else cast(0 as abap.quan(13,3))                       
              end
        else cast(0 as abap.quan(13,3))                 
       end as WH3497,       
       
  @Semantics.quantity.unitOfMeasure: 'GR_UNIT' 
  case when C.lgort is not null then
         case when C.lgort <> '3497' and C.lgort <> '3498' and C.lgort <> '3410' and C.lgort <> '3420' then 
                 case when C.ERFMG is not null then C.ERFMG else cast(0 as abap.quan(13,3)) end        
              else cast(0 as abap.quan(13,3))                    
              end
       else cast(0 as abap.quan(13,3))                  
       end as WHETC,
   A.mwskz    
} where A.knttp <> '' and B.zekkn = '01'

union all

select from ekpo as A    inner join ekko as Z on A.ebeln = Z.ebeln
                         left outer join ZGTMM_CV_GET_GODELIVERY_DATA2 as C on A.ebeln = C.ebeln and A.ebelp = C.ebelp and  C.cancelled = '' and C.reversal_movement = ''
association [1..1] to mara as D on $projection.matnr = D.matnr 
association [1..1] to ZGTSD_I_MaterialCharacteristic as C1 on $projection.matnr = C1.matnr and C1.atnam = 'PD_AA_STD_PRODUCT_NAME' 
association [1..1] to ZGTSD_I_MaterialCharacteristic as C2 on $projection.matnr = C2.matnr and C2.atnam = 'PD_CA_SPEC_NO'
association [1..1] to ZGTMM_CV_PO_VCVALUE_MAIN as C3 on $projection.ebeln = C3.PDOC and $projection.ebelp = C3.PDOCITEM  
{
  key A.ebeln,
  key A.ebelp,
  Z.bukrs,
  A.werks,
  Z.ekorg,
  Z.ekgrp,
  Z.lifnr,
  case when A.pstyp = '3' then cast('3' as esokz)
       else cast('0' as esokz) end as PSTYP,
  cast('' as vbeln_va) as VBELN,
  cast('' as posnr_va) as POSNR,
  A.matnr,
  case when D.zzmaktx80 is not null and D.zzmaktx80 <> '' then D.zzmaktx80 else A.txz01 end as MAKTX,
  case when C1.atwrt is not null then C1.atwrt else cast('' as atwrt) end as PRODNAME,
  case when C2.atwrt is not null then C2.atwrt else cast('' as atwrt) end as SPECNO,
  case when C3.COLOR is not null then C3.COLOR else cast('' as atwrt) end as COLOR ,
  
  A.menge as PO_QTY,
  A.meins as PO_MEINS,
  case when C3.LENGTH is not null then C3.LENGTH else cast('' as atwrt) end as LENGTH ,
  case when C3.DRQTY is not null then C3.DRQTY  else cast('' as atwrt) end as DRQTY,
  
  case when C.delno is not null then C.delno else cast('' as zgte_mm_gsrm_delno) end as DELNO ,
  case when C.delitem is not null then C.delitem else cast('' as zgte_mm_gsrm_delitem) end as delitem,
  case when C.budat is not null then C.budat else cast('' as budat) end as BUDAT ,     
    
  case when C.menge is not null then C.menge else cast(0 as abap.quan(13,3)) end as DL_QTY,
  case when C.meins is not null then C.meins else cast('' as abap.unit) end as DL_UNIT,  
   
       
  case when C.ERFMG is not null then C.ERFMG else cast(0 as abap.quan(13,3)) end as GR_QTY,
  case when C.ERFME is not null then 
    case when C.ERFME <> '' then C.ERFME else A.meins end
  else A.meins end as GR_UNIT,
  case when C.lgort is not null then C.lgort else cast('' as lgort_d) end as LGORT,
  
  case when C.lgort is not null then
         case when C.lgort = '3410' then 
                 case when C.ERFMG is not null then C.ERFMG else cast(0 as abap.quan(13,3)) end      
              else cast(0 as abap.quan(13,3))      
              end
       else cast(0 as abap.quan(13,3))       
       end as WH3410,
  
  case when C.lgort is not null then
         case when C.lgort = '3420' then 
                 case when C.ERFMG is not null then C.ERFMG else cast(0 as abap.quan(13,3)) end    
              else cast(0 as abap.quan(13,3))                        
              end
       else cast(0 as abap.quan(13,3))                  
       end as WH3420,       
  
  case when C.lgort is not null then
         case when C.lgort = '3498' then 
                 case when C.ERFMG is not null then C.ERFMG else cast(0 as abap.quan(13,3)) end        
              else cast(0 as abap.quan(13,3))                    
              end
       else cast(0 as abap.quan(13,3))                  
       end as WH3498,       
  
  case when C.lgort is not null then
         case when C.lgort = '3497' then 
                 case when C.ERFMG is not null then C.ERFMG else cast(0 as abap.quan(13,3)) end     
              else cast(0 as abap.quan(13,3))                       
              end
        else cast(0 as abap.quan(13,3))                 
       end as WH3497,       
  
  case when C.lgort is not null then
         case when C.lgort <> '3497' and C.lgort <> '3498' and C.lgort <> '3410' and C.lgort <> '3420' then 
                 case when C.ERFMG is not null then C.ERFMG else cast(0 as abap.quan(13,3)) end        
              else cast(0 as abap.quan(13,3))                    
              end
       else cast(0 as abap.quan(13,3))                  
       end as WHETC,
   A.mwskz    
} where A.knttp = '' 

