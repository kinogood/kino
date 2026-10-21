@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 사급 재고 현황(Base)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCSTOCKITEM 
as select from nsdm_e_mslb  as SCSTOCK 
   inner join t001w as PLANT on PLANT.werks = SCSTOCK.werks 
   inner join t001k as VALAREA on VALAREA.bwkey = PLANT.bwkey
   inner join t001 as COMPANY on COMPANY.bukrs = VALAREA.bukrs
   inner join mbew as MBEW on SCSTOCK.matnr = mbew.matnr and SCSTOCK.werks = mbew.bwkey
association [0..1] to mara as MARA on $projection.matnr = MARA.matnr  
association [0..1] to lfa1 as VENDOR on $projection.lifnr = VENDOR.lifnr
association [0..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language
association [0..1] to ZGTMM_CV_TAG_AGG  as TAG on TAG.werks = $projection.werks and TAG.matnr = $projection.matnr
                                   and  TAG.charg = $projection.charg
association [0..1] to mch1 as mch1 on mch1.matnr = $projection.matnr and mch1.charg =  $projection.charg
{
    key COMPANY.bukrs,
    key SCSTOCK.werks,    
    key SCSTOCK.lifnr,
    key SCSTOCK.matnr,
    key SCSTOCK.charg,
    case when TAG.TAGNR is null then cast('' as ztagnr)
         else TAG.TAGNR end as TAGNR,
    COMPANY.butxt,
    PLANT.name1 as PLANTNAME,
    VENDOR.name1 as VENDORNAME,
    makt.maktx,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    SCSTOCK.lblab,
    mara.meins,
    
    case when mbew.vprsv is null then cast('' as abap.char(1))
         else mbew.vprsv end as VPRSV,
    @Semantics.amount.currencyCode: 'waers'       
    case when mbew.verpr is null then cast(0 as abap.curr(11,2))
         else mbew.verpr end as VERPR,
    @Semantics.amount.currencyCode: 'waers'       
    case when mbew.stprs is null then cast(0 as abap.curr(11,2))
         else mbew.stprs end as STPRS,         
    case when mbew.peinh is null then cast(0 as abap.dec(5))
         else mbew.peinh end as PEINH,   
    COMPANY.waers,
    case when mch1.xpcbt is not null then mch1.xpcbt
         else cast('' as mill_xpcbt) end as xpcbt
} where SCSTOCK.lblab > 0
