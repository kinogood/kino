@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 Inbound Delivery 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_INDELIVERY_INFO 
as 
select from lips as A inner join ekes as B on A.vbeln = B.vbeln and A.posnr = B.vbelp
          inner join likp as H on A.vbeln = H.vbeln
{
  key B.ebeln,
  key B.ebelp,
      @Semantics.quantity.unitOfMeasure: 'MEINS'
      sum(B.menge) as LFIMG,
      A.meins
      
} group by B.ebeln,B.ebelp, A.meins       

union

select from zmmti34
{
  key ebeln,
  key ebelp,
  sum(lfimg) as LFIMG,
  meins
} group by ebeln,ebelp,meins   


union

select from zmmti26
{
  key ebeln,
  key ebelp,
  sum(lfimg) as LFIMG,
  meins
} where loevm <> 'D'
group by ebeln,ebelp,meins   
/*
select from lips as A inner join ekes as B on A.vbeln = B.vbeln and A.posnr = B.vbelp
          inner join likp as H on A.vbeln = H.vbeln
          inner join ekpo as D on B.ebeln = D.ebeln and B.ebelp = D.ebelp
          left outer join matdoc as C on B.vbeln = C.vbeln_im and B.vbelp = C.vbelp_im and C.cancelled = '' and C.reversal_movement = ''  
association [0..1] to lfa1 as VENDOR on $projection.lifnr = VENDOR.lifnr
{
   key A.vbeln,
   key B.vbelp,
   H.erdat,     //생성일
   H.lfdat,     //납품예정일
   H.lifnr,
   VENDOR.name1 as BPNAME,
   B.ebeln,
   B.ebelp,
   B.etens,
   A.werks,
   A.lgort,
   A.matnr,
   D.txz01,
   A.lichn,
   @Semantics.quantity.unitOfMeasure: 'MEINS'  
   A.lfimg,    //납품서 수량
   A.meins,
   @Semantics.quantity.unitOfMeasure: 'ERFME'     
   case when C.mblnr is not null then C.erfmg
        else cast(0 as abap.quan(13,3)) end as STOCK_QTY,  //입고수량
   C.erfme,
   C.mjahr,
   C.mblnr,
   C.zeile,
   C.budat

} where A.lfimg > 0  */
