@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 직송 납품 정보 조회 기초 데이터'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_DELIVER_BASE2 

as select from zgtmmt4403 as a
association [0..*] to nsdm_e_MKPF as S1 on $projection.mjahr= S1.mjahr and $projection.mblnr = S1.mblnr

{
  key a.bukrs,
  key a.zreq_type,
  key a.dlvrq,
  key a.vbeln,
  key a.posnr,
  key a.ebeln,
  key a.ebelp,
  @Semantics.quantity.unitOfMeasure: 'DR_MEINS'   
  sum(a.loadqty) as LOADQTY,
  a.zdoc_no,
  a.zdoc_item_no,
  a.delno,
  a.delitem,
  a.dr_meins,
  a.mjahr,
  a.mblnr,
  a.zmm_check,
  case when S1.budat is not null then S1.budat else cast('' as abap.dats) end as budat
    
} group by a.bukrs, a.zreq_type, a.dlvrq, a.vbeln, a.posnr, a.ebeln, a.ebelp, a.zdoc_no, a.zdoc_item_no, 
           a.delno, a.delitem, a.dr_meins, a.mjahr, a.mblnr, S1.budat, a.zmm_check
