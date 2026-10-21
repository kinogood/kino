@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '사급자재 불출 내역(WMS 전송 용)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETSCGILIST 
as 
select from matdoc as a
association [0..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language   
association [0..1] to lfa1 as vendor on $projection.lifnr = vendor.lifnr                               
{
  key a.mjahr,
  key a.mblnr,
  key a.zeile,
  key case when a.bwart = '541' then cast('S' as abap.char(1))
           when a.bwart = '542' then cast('C' as abap.char(1)) end as ZTYPE,
  key a.werks,             
  key a.lgort,
  key a.lifnr,
  key vendor.name1,  
  key a.matnr,
  key makt.maktx,
  key a.charg_cid as CHARG,
  @Semantics.quantity.unitOfMeasure: 'MEINS'
  a.menge as MENGE,
  a.meins
  
} where (a.bwart = '541' or a.bwart = '542' ) and a.lgort <> ''  
