@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '업체 보관품 재고 현황 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_STOCK_VENDOR 
as select from nsdm_e_mska as A inner join mch1 as B on A.matnr = B.matnr and A.charg = B.charg
                             inner join mara as C on B.matnr = C.matnr
                             inner join marc as D on A.matnr = D.matnr and A.werks = D.werks
                             inner join ZGTMM_CV_SO_VCVALUE as ch1 on A.vbeln = ch1.vbeln and A.posnr = ch1.posnr and ch1.atnam = 'SAP_MILLCA_LENGTH'
                             inner join vbak as e on A.vbeln = e.vbeln
                             inner join t001w as T on D.werks = T.werks
                             inner join t001k as Y on T.bwkey = Y.bwkey
                             
association [0..1] to makt as MAKTX on $projection.matnr = MAKTX.matnr and MAKTX.spras = $session.system_language   
association [0..*] to ZGTMM_CV_GET_SALES_TEAM as H on $projection.vbeln = H.vbeln and $projection.vkorg = H.vkorg
association [0..*] to ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N1 on $projection.matnr = N1.matnr and $projection.werks = N1.werks and N1.nes= 'CU'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S1 on $projection.matnr = S1.matnr and S1.atnam = 'PD_CA_COLOR_BASE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S2 on $projection.matnr = S2.matnr and S2.atnam = 'PD_CA_COLOR_STRIPE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S3 on $projection.matnr = S3.matnr and S3.atnam = 'PD_CA_COLOR_STRIPE_NO'
association [0..*] to ZGTMM_CV_GET_ZGTMMT4412_4405  as Z on $projection.vbeln = Z.vbeln and $projection.posnr = Z.posnr
association [0..*] to ZGTMM_CV_GET_PODATA_BYSO_LAST  as po on $projection.vbeln = po.vbeln and $projection.posnr = po.posnr

{
  key B.lifnr,
  key A.matnr,
  key Y.bukrs,
  key A.werks,
  key A.charg,
      A.vbeln,
      A.posnr,
      e.vkorg,
      H.zzyuscd as TEAM2DGIT,  
      case when C.zzmaktx80 is not null and C.zzmaktx80 <> '' then C.zzmaktx80 else MAKTX.maktx end as txz01,
      @Semantics.quantity.unitOfMeasure: 'meins'       
      A.kalab as STOCK,
      C.meins,
      cast(ch1.VALUE as abap.dec(13,3)) as LENGTH,
      case when N1.nes is not null then N1.nes else cast('' as /nfm/nes) end as CU_NES,         
      @Semantics.quantity.unitOfMeasure: 'CU_BME'         
      case when N1.nes is not null then N1.kgw else cast(0 as /nfm/kgw) end as CU_KGW,
      case when N1.nes is not null then N1.bme else cast('' as meins) end as CU_BME,
      @Semantics.quantity.unitOfMeasure: 'MEINS'           
      case when N1.nes is not null then N1.kgu else cast(0 as /nfm/kgu) end as CU_KGU,
      case when N1.kgu is not null then
         case when N1.kgu > 0 then 
             cast(N1.kgw as abap.dec(15,3)) / cast(N1.kgu as abap.dec(15,3))
            else cast(0 as abap.dec(15,3)) end
          else cast(0 as abap.dec(15,3)) end as VGW,
      S1.atwrt as color,
      S2.atwrt as STRIPE,
      S3.atwrt as stripe_no,
      @Semantics.quantity.unitOfMeasure: 'DR_MEINS'
      case when Z.REQ_QTY is not null then cast(Z.REQ_QTY as abap.dec(13,3)) * cast(ch1.VALUE  as abap.dec(13,3))
           else cast(0 as abap.dec(13,3)) end as REQQTY,
      Z.dr_meins,
      @Semantics.quantity.unitOfMeasure: 'DR_MEINS'   
      case when Z.LOADQTY is not null then cast(Z.LOADQTY as abap.dec(13,3)) * cast(ch1.VALUE  as abap.dec(13,3))
           else cast(0 as abap.dec(13,3)) end as DLVQTY,
      case when po.ebeln is not null then po.ebeln else cast('' as ebeln) end as EBELN,
      case when po.ebelp is not null then po.ebelp else cast('' as ebelp) end as EBELP,
    
//     26.09 저장위치 추가
      case when po.lgort is not null then po.lgort else cast('' as lgort_d) end as lgort,
      case when po.lgobe is not null then po.lgobe else cast('' as lgobe) end as lgobe,

      cast('' as vbeln_va) as VBELN_OR,
      cast('' as posnr_va)  as POSNR_OR                             

} where (A.werks = '6500' or A.werks = '6600') and A.lgort = '3497' and D.dpcbt = 'C' and A.kalab > 0

union all

select from nsdm_e_mska as A inner join mch1 as B on A.matnr = B.matnr and A.charg = B.charg
                             inner join mara as C on B.matnr = C.matnr
                             inner join marc as D on A.matnr = D.matnr and A.werks = D.werks
                             inner join ZGTMM_CV_SO_VCVALUE as ch1 on A.vbeln = ch1.vbeln and A.posnr = ch1.posnr and ch1.atnam = 'SAP_MILLCA_LENGTH'
                             inner join vbak as e on A.vbeln = e.vbeln
                             inner join vbap as f on A.vbeln = f.vbeln and A.posnr = f.posnr
                             inner join t001w as T on D.werks = T.werks
                             inner join t001k as Y on T.bwkey = Y.bwkey
                             
association [0..1] to makt as MAKTX on $projection.matnr = MAKTX.matnr and MAKTX.spras = $session.system_language   
association [0..*] to ZGTMM_CV_GET_SALES_TEAM as H on $projection.vbeln = H.vbeln and $projection.vkorg = H.vkorg
association [0..*] to ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N1 on $projection.matnr = N1.matnr and $projection.werks = N1.werks and N1.nes= 'CU'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S1 on $projection.matnr = S1.matnr and S1.atnam = 'PD_CA_COLOR_BASE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S2 on $projection.matnr = S2.matnr and S2.atnam = 'PD_CA_COLOR_STRIPE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S3 on $projection.matnr = S3.matnr and S3.atnam = 'PD_CA_COLOR_STRIPE_NO'
association [0..*] to ZGTMM_CV_GET_ZGTMMT4412_4405  as Z on $projection.vbeln = Z.vbeln and $projection.posnr = Z.posnr
association [0..*] to ZGTMM_CV_GET_PODATA_BYSO_LAST  as po on $projection.vbeln = po.vbeln and $projection.posnr = po.posnr

{
  key B.lifnr,
  key A.matnr,
  key Y.bukrs,
  key A.werks,
  key A.charg,
      A.vbeln,
      A.posnr,
      e.vkorg,
      H.zzyuscd as TEAM2DGIT,  
      case when C.zzmaktx80 is not null and C.zzmaktx80 <> '' then C.zzmaktx80 else MAKTX.maktx end as txz01,
      A.kalab as STOCK,
      C.meins,
      cast(ch1.VALUE as abap.dec(13,3)) as LENGTH,
      case when N1.nes is not null then N1.nes else cast('' as /nfm/nes) end as CU_NES,         
      case when N1.nes is not null then N1.kgw else cast(0 as /nfm/kgw) end as CU_KGW,
      case when N1.nes is not null then N1.bme else cast('' as meins) end as CU_BME,
      case when N1.nes is not null then N1.kgu else cast(0 as /nfm/kgu) end as CU_KGU,
      case when N1.kgu is not null then
         case when N1.kgu > 0 then 
             cast(N1.kgw as abap.dec(15,3)) / cast(N1.kgu as abap.dec(15,3))
            else cast(0 as abap.dec(15,3)) end
          else cast(0 as abap.dec(15,3)) end as VGW,
      S1.atwrt as color,
      S2.atwrt as STRIPE,
      S3.atwrt as stripe_no,
      case when Z.REQ_QTY is not null then cast(Z.REQ_QTY as abap.dec(13,3)) * cast(ch1.VALUE  as abap.dec(13,3))
           else cast(0 as abap.dec(13,3)) end as REQQTY,
      Z.dr_meins,
      case when Z.LOADQTY is not null then cast(Z.LOADQTY as abap.dec(13,3)) * cast(ch1.VALUE  as abap.dec(13,3))
           else cast(0 as abap.dec(13,3)) end as DLVQTY,
      case when po.ebeln is not null then po.ebeln else cast('' as ebeln) end as EBELN,
      case when po.ebelp is not null then po.ebelp else cast('' as ebelp) end as EBELP,
    
//     26.09 저장위치 추가
      case when po.lgort is not null then po.lgort else cast('' as lgort_d) end as lgort,
      case when po.lgobe is not null then po.lgobe else cast('' as lgobe) end as lgobe,


      f.vgbel as VBELN_OR,
      f.vgpos as POSNR_OR                                  
    
} where (A.werks = '6591' or A.werks = '6691') and A.lgort = '3497' and D.dpcbt = 'C' and A.kalab > 0


union all

select from nsdm_e_mska as A inner join mch1 as B on A.matnr = B.matnr and A.charg = B.charg
                             inner join mara as C on B.matnr = C.matnr
                             inner join marc as D on A.matnr = D.matnr and A.werks = D.werks
                             inner join ZGTMM_CV_SO_VCVALUE as ch1 on A.vbeln = ch1.vbeln and A.posnr = ch1.posnr and ch1.atnam = 'SAP_MILLCA_LENGTH'
                             inner join vbak as e on A.vbeln = e.vbeln
                             inner join t001w as T on D.werks = T.werks
                             inner join t001k as Y on T.bwkey = Y.bwkey
association [0..1] to makt as MAKTX on $projection.matnr = MAKTX.matnr and MAKTX.spras = $session.system_language   
association [0..*] to ZGTMM_CV_GET_SALES_TEAM as H on $projection.vbeln = H.vbeln and $projection.vkorg = H.vkorg
association [0..*] to ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N1 on $projection.matnr = N1.matnr and $projection.werks = N1.werks and N1.nes= 'CU'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S1 on $projection.matnr = S1.matnr and S1.atnam = 'PD_CA_COLOR_BASE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S2 on $projection.matnr = S2.matnr and S2.atnam = 'PD_CA_COLOR_STRIPE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S3 on $projection.matnr = S3.matnr and S3.atnam = 'PD_CA_COLOR_STRIPE_NO'
association [0..*] to ZGTMM_CV_GET_ZGTMMT4412_4405  as Z on $projection.vbeln = Z.vbeln and $projection.posnr = Z.posnr
association [0..*] to ZGTMM_CV_GET_PODATA_BYSO_LAST  as po on $projection.vbeln = po.vbeln and $projection.posnr = po.posnr

{
  key B.lifnr,
  key A.matnr,
  key Y.bukrs,
  key A.werks,
  key A.charg,
      A.vbeln,
      A.posnr,
      e.vkorg,
      H.zzyuscd as TEAM2DGIT,  
      case when C.zzmaktx80 is not null and C.zzmaktx80 <> '' then C.zzmaktx80 else MAKTX.maktx end as txz01,
      A.kalab as STOCK,
      C.meins,
      cast(ch1.VALUE as abap.dec(13,3)) as LENGTH,
      case when N1.nes is not null then N1.nes else cast('' as /nfm/nes) end as CU_NES,  
      case when N1.nes is not null then N1.kgw else cast(0 as /nfm/kgw) end as CU_KGW,
      case when N1.nes is not null then N1.bme else cast('' as meins) end as CU_BME,
      case when N1.nes is not null then N1.kgu else cast(0 as /nfm/kgu) end as CU_KGU ,
      case when N1.kgu is not null then
         case when N1.kgu > 0 then 
             cast(N1.kgw as abap.dec(15,3)) / cast(N1.kgu as abap.dec(15,3))
            else cast(0 as abap.dec(15,3)) end
          else cast(0 as abap.dec(15,3)) end as VGW,      
      S1.atwrt as color,
      S2.atwrt as STRIPE,
      S3.atwrt as stripe_no,
      case when Z.REQ_QTY is not null then cast(Z.REQ_QTY as abap.dec(13,3)) * cast(ch1.VALUE  as abap.dec(13,3))
           else cast(0 as abap.dec(13,3)) end as REQQTY,
      Z.dr_meins,         
      case when Z.LOADQTY is not null then cast(Z.LOADQTY as abap.dec(13,3)) * cast(ch1.VALUE  as abap.dec(13,3))
           else cast(0 as abap.dec(13,3)) end as DLVQTY,
      case when po.ebeln is not null then po.ebeln else cast('' as ebeln) end as EBELN,
      case when po.ebelp is not null then po.ebelp else cast('' as ebelp) end as EBELP,
    
//     26.09 저장위치 추가
      case when po.lgort is not null then po.lgort else cast('' as lgort_d) end as lgort,
      case when po.lgobe is not null then po.lgobe else cast('' as lgobe) end as lgobe,


      cast('' as vbeln_va) as VBELN_OR,
      cast('' as posnr_va)  as POSNR_OR                                                                      
    
} where (A.werks = '6500' or A.werks = '6600') and  A.lgort = '3497' and D.dpcbt = 'A' and A.kalab > 0

union all

select from nsdm_e_mska as A inner join mch1 as B on A.matnr = B.matnr and A.charg = B.charg
                             inner join mara as C on B.matnr = C.matnr
                             inner join marc as D on A.matnr = D.matnr and A.werks = D.werks
                             inner join ZGTMM_CV_SO_VCVALUE as ch1 on A.vbeln = ch1.vbeln and A.posnr = ch1.posnr and ch1.atnam = 'SAP_MILLCA_LENGTH'
                             inner join vbak as e on A.vbeln = e.vbeln
                             inner join vbap as f on A.vbeln = f.vbeln and A.posnr = f.posnr
                             inner join t001w as T on D.werks = T.werks
                             inner join t001k as Y on T.bwkey = Y.bwkey
association [0..1] to makt as MAKTX on $projection.matnr = MAKTX.matnr and MAKTX.spras = $session.system_language   
association [0..*] to ZGTMM_CV_GET_SALES_TEAM as H on $projection.vbeln = H.vbeln and $projection.vkorg = H.vkorg
association [0..*] to ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N1 on $projection.matnr = N1.matnr and $projection.werks = N1.werks and N1.nes= 'CU'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S1 on $projection.matnr = S1.matnr and S1.atnam = 'PD_CA_COLOR_BASE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S2 on $projection.matnr = S2.matnr and S2.atnam = 'PD_CA_COLOR_STRIPE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S3 on $projection.matnr = S3.matnr and S3.atnam = 'PD_CA_COLOR_STRIPE_NO'
association [0..*] to ZGTMM_CV_GET_ZGTMMT4412_4405  as Z on $projection.vbeln = Z.vbeln and $projection.posnr = Z.posnr
association [0..*] to ZGTMM_CV_GET_PODATA_BYSO_LAST  as po on $projection.vbeln = po.vbeln and $projection.posnr = po.posnr

{
  key B.lifnr,
  key A.matnr,
  key Y.bukrs,
  key A.werks,
  key A.charg,
      A.vbeln,
      A.posnr,
      e.vkorg,
      H.zzyuscd as TEAM2DGIT,  
      case when C.zzmaktx80 is not null and C.zzmaktx80 <> '' then C.zzmaktx80 else MAKTX.maktx end as txz01,
      A.kalab as STOCK,
      C.meins,
      cast(ch1.VALUE as abap.dec(13,3)) as LENGTH,
      case when N1.nes is not null then N1.nes else cast('' as /nfm/nes) end as CU_NES,  
      case when N1.nes is not null then N1.kgw else cast(0 as /nfm/kgw) end as CU_KGW,
      case when N1.nes is not null then N1.bme else cast('' as meins) end as CU_BME,
      case when N1.nes is not null then N1.kgu else cast(0 as /nfm/kgu) end as CU_KGU ,
      case when N1.kgu is not null then
         case when N1.kgu > 0 then 
             cast(N1.kgw as abap.dec(15,3)) / cast(N1.kgu as abap.dec(15,3))
            else cast(0 as abap.dec(15,3)) end
          else cast(0 as abap.dec(15,3)) end as VGW,      
      S1.atwrt as color,
      S2.atwrt as STRIPE,
      S3.atwrt as stripe_no,
      case when Z.REQ_QTY is not null then cast(Z.REQ_QTY as abap.dec(13,3)) * cast(ch1.VALUE  as abap.dec(13,3))
           else cast(0 as abap.dec(13,3)) end as REQQTY,
      Z.dr_meins,         
      case when Z.LOADQTY is not null then cast(Z.LOADQTY as abap.dec(13,3)) * cast(ch1.VALUE  as abap.dec(13,3))
           else cast(0 as abap.dec(13,3)) end as DLVQTY,
           
      case when po.ebeln is not null then po.ebeln else cast('' as ebeln) end as EBELN,
      case when po.ebelp is not null then po.ebelp else cast('' as ebelp) end as EBELP,
    
//     26.09 저장위치 추가
      case when po.lgort is not null then po.lgort else cast('' as lgort_d) end as lgort,
      case when po.lgobe is not null then po.lgobe else cast('' as lgobe) end as lgobe,

      f.vgbel as VBELN_OR,
      f.vgpos as POSNR_OR                      
} where (A.werks = '6591' or A.werks = '6691') and A.lgort = '3497' and D.dpcbt = 'A' and A.kalab > 0

union all

select from nsdm_e_mchb as A inner join mch1 as B on A.matnr = B.matnr and A.charg = B.charg
                             inner join mara as C on B.matnr = C.matnr
                             inner join marc as D on A.matnr = D.matnr and A.werks = D.werks
                             inner join t001w as T on D.werks = T.werks
                             inner join t001k as Y on T.bwkey = Y.bwkey
association [0..1] to makt as MAKTX on $projection.matnr = MAKTX.matnr and MAKTX.spras = $session.system_language  
association [0..*] to ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N1 on $projection.matnr = N1.matnr and $projection.werks = N1.werks and N1.nes= 'CU'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S1 on $projection.matnr = S1.matnr and S1.atnam = 'PD_CA_COLOR_BASE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S2 on $projection.matnr = S2.matnr and S2.atnam = 'PD_CA_COLOR_STRIPE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S3 on $projection.matnr = S3.matnr and S3.atnam = 'PD_CA_COLOR_STRIPE_NO'
association [0..*] to ZGTMM_CV_GET_PODATA_BY_B_SUM  as PO on $projection.matnr = PO.matnr and $projection.werks = PO.werks and $projection.charg = PO.charg

 
{
  key B.lifnr,
  key A.matnr,
  key Y.bukrs,
  key A.werks,
  key A.charg,
      cast('' as vbeln_va) as vbeln,
      cast('' as posnr_va) as posnr,
      cast('' as vkorg) as VKORG,
      cast('' as abap.char(2)) as TEAM2DGIT,  
      case when C.zzmaktx80 is not null and C.zzmaktx80 <> '' then C.zzmaktx80 else MAKTX.maktx end as txz01,
      A.clabs as STOCK,
      C.meins,
      cast(A.clabs as abap.dec(13,3)) as LENGTH ,
      case when N1.nes is not null then N1.nes else cast('' as /nfm/nes) end as CU_NES,         
      case when N1.nes is not null then N1.kgw else cast(0 as /nfm/kgw) end as CU_KGW,
      case when N1.nes is not null then N1.bme else cast('' as meins) end as CU_BME,
      case when N1.nes is not null then N1.kgu else cast(0 as /nfm/kgu) end as CU_KGU,
      case when N1.kgu is not null then
         case when N1.kgu > 0 then 
             cast(N1.kgw as abap.dec(15,3)) / cast(N1.kgu as abap.dec(15,3))
            else cast(0 as abap.dec(15,3)) end
          else cast(0 as abap.dec(15,3)) end as VGW,      
      S1.atwrt as color,
      S2.atwrt as STRIPE,
      S3.atwrt as stripe_no,
      cast(0 as abap.quan(13,3)) as REQQTY,
      cast('DR' as unit) as dr_meins,         
      cast(0 as abap.quan(13,3)) as DLVQTY,
      case when PO.ebeln is not null then PO.ebeln else cast('' as ebeln) end as EBELN,
      case when PO.ebelp is not null then PO.ebelp else cast('' as ebelp) end as EBELP,
    
//     26.09 저장위치 추가
      case when PO.lgort is not null then PO.lgort else cast('' as lgort_d) end as lgort,
      case when PO.lgobe is not null then PO.lgobe else cast('' as lgobe) end as lgobe,

      cast('' as vbeln_va) as VBELN_OR,
      cast('' as posnr_va)  as POSNR_OR                                                          
    
} where A.lgort = '3497' and D.dpcbt = 'C' and A.clabs > 0


/*
union all

select from nsdm_e_mchb as A inner join mch1 as B on A.matnr = B.matnr and A.charg = B.charg
                             inner join mara as C on B.matnr = C.matnr
                             inner join marc as D on A.matnr = D.matnr and A.werks = D.werks
                             inner join t001w as T on D.werks = T.werks
                             inner join t001k as Y on T.bwkey = Y.bwkey                             
association [0..1] to makt as MAKTX on $projection.matnr = MAKTX.matnr and MAKTX.spras = $session.system_language  
association [0..*] to ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N1 on $projection.matnr = N1.matnr and $projection.werks = N1.werks and N1.nes= 'CU'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S1 on $projection.matnr = S1.matnr and S1.atnam = 'PD_CA_COLOR_BASE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S2 on $projection.matnr = S2.matnr and S2.atnam = 'PD_CA_COLOR_STRIPE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S3 on $projection.matnr = S3.matnr and S3.atnam = 'PD_CA_COLOR_STRIPE_NO'

{
  key B.lifnr,
  key A.matnr,
  key Y.bukrs,  
  key A.werks,
  key A.charg,
      cast('' as vbeln_va) as vbeln,
      cast('' as posnr_va) as posnr,
      cast('' as vkorg) as VKORG,
      cast('' as abap.char(2)) as TEAM2DGIT,  
      case when C.zzmaktx80 is not null and C.zzmaktx80 <> '' then C.zzmaktx80 else MAKTX.maktx end as txz01,
      A.clabs as STOCK,
      C.meins,
      
      case 
        when length( replace( replace( replace( replace( replace(
                     replace( replace( replace( replace( replace( 
                     A.charg, '0', '' ), '1', '' ), '2', '' ), '3', '' ), '4', '' ), 
                     '5', '' ), '6', '' ), '7', '' ), '8', '' ), '9', '' ) ) = 0 
        then cast(A.charg as abap.dec(13,3))
        else cast(1 as abap.dec(13,3)) end as LENGTH ,
      case when N1.nes is not null then N1.nes else cast('' as /nfm/nes) end as CU_NES,       
      case when N1.nes is not null then N1.kgw else cast(0 as /nfm/kgw) end as CU_KGW,
      case when N1.nes is not null then N1.bme else cast('' as meins) end as CU_BME,
      case when N1.nes is not null then N1.kgu else cast(0 as /nfm/kgu) end as CU_KGU,
      case when N1.kgu is not null then
         case when N1.kgu > 0 then 
             cast(N1.kgw as abap.dec(15,3)) / cast(N1.kgu as abap.dec(15,3))
            else cast(0 as abap.dec(15,3)) end
          else cast(0 as abap.dec(15,3)) end as VGW,      
      S1.atwrt as color,
      S2.atwrt as STRIPE,
      S3.atwrt as stripe_no,
      cast(0 as abap.quan(13,3)) as REQQTY,
      cast('DR' as unit) as dr_meins,         
      cast(0 as abap.quan(13,3)) as DLVQTY                        
    
} where A.lgort = '3497' and D.dpcbt = 'A' and A.clabs > 0 */
