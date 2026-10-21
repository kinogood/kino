@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '재고현황조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_STOCKLIST
as

//창고재고(MARD)
select from nsdm_e_mard as a inner join marc as B on a.matnr = B.matnr and a.werks = B.werks
                             inner join mara as c on B.matnr = c.matnr
//                             left outer join ZGTMM_CV_SP_STOCKLIST_SUM as D on a.matnr = D.matnr and a.werks = D.werks and a.lgort = D.lgort
{
   key a.matnr,
   key a.werks,
   key a.lgort,
       cast('' as charg_d) as CHARG,
       cast('' as sobkz) as SOBKZ,
       cast('' as lifnr) as LIFNR,
       cast('' as ps_psp_pnr) as PSPNR,
       cast('' as kunnr) as kunnr,
       cast('' as vbeln) as vbeln,
       cast('' as posnr) as posnr,
       c.meins,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       a.labst,
//       case when D.werks is not null then a.labst - D.LABST else a.labst end as LABST,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       a.insme,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       a.speme,
       cast('' as vbeln_va) as VBELN_OR,
       cast('' as posnr_va) as POSNR_OR
//       case when D.werks is not null then a.insme - D.INSME else a.insme end as INSME
} where B.xchpf = '' and (a.labst > 0 or a.insme > 0 or a.speme > 0 )

union

//배치재고(MCHB)
select from nsdm_e_mchb as a inner join marc as B on a.matnr = B.matnr and a.werks = B.werks
                             inner join mara as c on B.matnr = c.matnr
//                             left outer join ZGTMM_CV_SP_STOCKLIST_SUM as D on a.matnr = D.matnr and a.werks = D.werks and a.lgort = D.lgort and a.charg = D.charg
{
   key a.matnr,
   key a.werks,
   key a.lgort,
       a.charg,
       cast('' as sobkz) as SOBKZ,
       cast('' as lifnr) as LIFNR,
       cast('' as ps_psp_pnr) as PSPNR,
       cast('' as kunnr) as kunnr,
       cast('' as vbeln) as vbeln,
       cast('' as posnr) as posnr,
       c.meins,
       a.clabs as LABST,
       a.cinsm as INSME,
       a.cspem as SPEME,
       cast('' as vbeln_va) as VBELN_OR,
       cast('' as posnr_va) as POSNR_OR
//       case when D.werks is not null then a.clabs - D.LABST else a.clabs end as labst,
//       case when D.werks is not null then a.ceinm - D.INSME else a.ceinm end as insme
} where B.xchpf = 'X' and (a.clabs >0 or a.cinsm > 0 or a.cspem > 0)

union

//공급업체특밸재고(MSLB)
select from nsdm_e_mslb as a inner join mara as B on a.matnr = B.matnr
{
   key a.matnr,
   key a.werks,
   key cast(''as lgort_d) as lgort,
       a.charg,
       a.sobkz,
       a.lifnr,
       cast('' as ps_psp_pnr) as PSPNR,
       cast('' as kunnr) as kunnr,
       cast('' as vbeln) as vbeln,
       cast('' as posnr) as posnr,
       B.meins,
       a.lblab as labst,
       a.lbins as insme,
       cast(0 as abap.quan(13,3)) as SPEME,
       cast('' as vbeln_va) as VBELN_OR,
       cast('' as posnr_va) as POSNR_OR
} where a.lblab > 0 or a.lbins > 0

union

//고객특별재고(MSKU)
select from nsdm_e_msku as a inner join mara as B on a.matnr = B.matnr
{
   key a.matnr,
   key a.werks,
   key cast(''as lgort_d) as lgort,
       a.charg,
       a.sobkz,
       cast('' as lifnr) as LIFNR,
       cast('' as ps_psp_pnr) as PSPNR,
       a.kunnr,
       cast('' as vbeln) as vbeln,
       cast('' as posnr) as posnr,
       B.meins,
       a.kulab as labst,
       a.kuins as insme,
       cast(0 as abap.quan(13,3)) as SPEME,
       cast('' as vbeln_va) as VBELN_OR,
       cast('' as posnr_va) as POSNR_OR
} where a.kulab > 0 or a.kuins > 0

union
//프로젝트 재고(MSPR)
select from nsdm_e_mspr as a inner join mara as B on a.matnr = B.matnr
{
   key a.matnr,
   key a.werks,
   key a.lgort,
       a.charg,
       a.sobkz,
       cast('' as lifnr) as LIFNR,
       a.pspnr,
       cast('' as kunnr) as kunnr,
       cast('' as vbeln) as vbeln,
       cast('' as posnr) as posnr,
       B.meins,
       a.prlab as LABST,
       a.prins as INSME,
       a.prspe as speme,
       cast('' as vbeln_va) as VBELN_OR,
       cast('' as posnr_va) as POSNR_OR
} where a.prlab > 0 or a.prins > 0 or a.prspe > 0

union

//판매오더 재고(MSKA)
select from nsdm_e_mska as a inner join mara as B on a.matnr = B.matnr
                             left outer join vbap as f on a.vbeln = f.vbeln and a.posnr = f.posnr
{
   key a.matnr,
   key a.werks,
   key a.lgort,
       a.charg,
       a.sobkz,
       cast('' as lifnr) as LIFNR,
       cast('' as ps_psp_pnr) as pspnr,
       cast('' as kunnr) as kunnr,
       a.vbeln,
       a.posnr,
       B.meins,
       a.kalab as LABST,
       a.kains as INSME,
       a.kaspe as SPEME,
       case when f.vgbel is not null then f.vgbel else cast('' as vbeln_va) end as VBELN_OR,
       case when f.vgpos is not null then f.vgpos else cast('' as posnr_va) end as POSNR_OR
} where a.kalab >0 or a.kains > 0 or a.kaspe > 0

/*
union
select from ZGTMM_CV_SP_STOCKLIST
{
   key matnr,
   key werks,
   key lgort,
       charg,
       sobkz,
       LIFNR,
       pspnr,
       kunnr,
       vbeln,
       posnr,
       meins,
       LABST,
       INSME
} where LABST >0 or INSME > 0*/
