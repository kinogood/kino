@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 검수 요청 현황 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DD_INSP_REQ 
as select from zgtmmt4402 as A inner join ekko as B on A.ebeln = B.ebeln
                               inner join ekpo as C on A.ebeln = C.ebeln and A.ebelp = C.ebelp
                               inner join lfa1 as D on B.lifnr = D.lifnr
                               inner join t001w as E on C.werks = E.werks
                               inner join mara as F on C.matnr = F.matnr
                               inner join eket as G on C.ebeln = G.ebeln and C.ebelp = G.ebelp and G.etenr = '0001'
                               left outer join ekkn as Z on C.ebeln = Z.ebeln and C.ebelp = Z.ebelp and Z.zekkn = '01'
association [0..1] to ZGTMM_CV_GET_DDREQDATE as DATE1 on $projection.ebeln = DATE1.ebeln and $projection.ebelp = DATE1.ebelp                            
                               
{
  key A.bukrs,
  key A.ebeln,
  key A.ebelp,
  key A.zinsp_no,
      D.lifnr,
      D.name1 as LIFNR_N,
      C.werks,
      E.name1 as WERKS_N,
      case when Z.vbeln is not null then Z.vbeln
           else cast('' as vbeln_va) end as VBELN,
      case when Z.vbelp is not null then Z.vbelp
           else cast('' as posnr_va) end as POSNR,  
      C.matnr,        
      case when F.zzmaktx80 <> '' then F.zzmaktx80
           else C.txz01 end as MAKTX,
      C.meins,     
      @Semantics.quantity.unitOfMeasure: 'MEINS_Q'
      A.zinsp_qty,
      A.meins as MEINS_Q,
      case when DATE1.REQDATE is not null then DATE1.REQDATE
           else cast('' as dats) end as REQDATE,
      G.eindt,

      A.zinsptype,
      A.zinspdate,
      A.zinspres,
      A.zinsp_certi,
      A.erdat,
      A.erdat_local,
      A.ertim,
      A.ertim_local,
      A.ernam,
      A.aedat,
      A.aedat_local,
      A.aetim,
      A.aetim_local,
      A.aenam
}
