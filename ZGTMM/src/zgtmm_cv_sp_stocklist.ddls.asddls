@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '특별재고현황조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SP_STOCKLIST 
as 
//프로젝트 재고(MSPR)
select from nsdm_e_mspr as a inner join mara as B on a.matnr = B.matnr
{
   key a.matnr,
   key a.werks,
   key a.lgort,
   key a.charg,   
   key a.sobkz,   
       cast('' as lifnr) as LIFNR,   
       a.pspnr,   
       cast('' as kunnr) as kunnr,   
       cast('' as vbeln) as vbeln,   
       cast('' as posnr) as posnr,   
       B.meins,   
       @Semantics.quantity.unitOfMeasure: 'MEINS'  
       a.prlab as LABST,   
       @Semantics.quantity.unitOfMeasure: 'MEINS'  
       a.prins as INSME
} where a.prlab > 0 or a.prins > 0

union

//판매오더 재고(MSKA)
select from nsdm_e_mska as a inner join mara as B on a.matnr = B.matnr
{
   key a.matnr,
   key a.werks,
   key a.lgort,
   key a.charg,   
   key a.sobkz,   
       cast('' as lifnr) as LIFNR,   
       cast('' as ps_psp_pnr) as pspnr,   
       cast('' as kunnr) as kunnr,   
       a.vbeln,   
       a.posnr,   
       B.meins,   
       a.kalab as LABST,   
       a.kains as INSME
} where a.kalab >0 or a.kains > 0

