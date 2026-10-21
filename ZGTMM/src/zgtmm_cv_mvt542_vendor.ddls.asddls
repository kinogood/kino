@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주재고 환입 처리 결과'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_MVT542_VENDOR 
as 
select from matdoc as A  inner join nsdm_e_MKPF as B on A.mjahr = B.mjahr and A.mblnr = B.mblnr
association [1..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language 
association [1..1] to t001 as T001 on $projection.bukrs = T001.bukrs 
association [1..1] to t001w as T001W on $projection.werks = T001W.werks 
association [1..1] to t001l as T001L on $projection.werks = T001L.werks and $projection.lgort = T001L.lgort 
association [1..1] to lfa1 as LFA1 on $projection.lifnr = LFA1.lifnr 
{
   key A.mjahr,
   key A.mblnr,
   key A.zeile,
   A.bukrs,
   t001.butxt as BUKRS_N,
   A.werks,
   t001w.name1 as WERKS_N,
   A.lgort,
   t001l.lgobe as LGORT_N,
   A.lifnr,
   lfa1.name1 as LIFNR_N,
   A.budat,
   A.bldat,
   A.cpudt,
   A.cputm,
   A.usnam,
   A.bktxt,
   A.matnr,
   makt.maktx,
   A.charg,
   @Semantics.quantity.unitOfMeasure: 'MEINS'     
   A.menge,
   A.meins
    
} where A.lgort_sid <> '' and A.cancelled = '' and A.cancellation_type = '' and A.bwart = '542'
