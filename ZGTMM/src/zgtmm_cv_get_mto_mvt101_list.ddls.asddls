@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MTO 구매 입고 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_MTO_MVT101_LIST 
as select from matdoc as a inner join ZGTMM_CV_PO_VCVALUE_MAIN2 as B on a.ebeln = B.PDOC and a.ebelp = B.PDOCITEM
{
   key a.mjahr,
   key a.mblnr,
   key a.zeile,
       a.budat,
       a.cpudt,
       @Semantics.quantity.unitOfMeasure: 'MEINS'       
       a.menge,
       a.meins, 
       B.LENGTH,
       cast(cast(a.menge as abap.dec(13,3)) / cast(B.LENGTH as abap.dec(13,0)) as abap.dec(7,0)) as DRQTY,
       a.kdauf as VBELN,
       a.kdpos as POSNR
} where a.bwart = '101' and a.cancelled = '' and a.cancellation_type = '' and a.kdauf <> '' and (a.lgort = '3497' or a.lgort = '3498')
