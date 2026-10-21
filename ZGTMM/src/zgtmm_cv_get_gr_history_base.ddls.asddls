@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '입고 이력 현황 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GR_HISTORY_BASE 
as select from ekpo as A inner join ekkn as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
                         inner join ekko as Z on A.ebeln = Z.ebeln
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

   A.mwskz
} where A.knttp <> '' and B.zekkn = '01'

union all

select from ekpo as A inner join ekko as Z on A.ebeln = Z.ebeln
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
  A.mwskz    
} where A.knttp = '' 
