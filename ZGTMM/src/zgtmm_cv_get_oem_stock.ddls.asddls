@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 재고 현황 및 잔량 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_STOCK 
as 

select from nsdm_e_mska as A inner join mch1 as B on A.matnr = B.matnr and A.charg = B.charg
                             inner join mara as C on B.matnr = C.matnr
                             inner join marc as D on A.matnr = D.matnr and A.werks = D.werks
association [0..1] to  ZGTMM_CV_SO_VCVALUE as ch1 on $projection.vbeln = ch1.vbeln and $projection.posnr = ch1.posnr and ch1.atnam = 'SAP_MILLCA_LENGTH'   
                           
{
  key A.matnr,
  key A.werks,
  key cast('매입보관재고' as abap.char(14)) as TYPE, 
  key A.lgort,
      B.lifnr,
      A.vbeln,
      A.posnr,
      @Semantics.quantity.unitOfMeasure: 'meins'       
      sum(A.kalab) as STOCK,
      C.meins,
      case when ch1.VALUE is not null then cast(ch1.VALUE as abap.dec(13,3)) else cast('0' as abap.dec(13,3)) end as length  
} where A.lgort = '3497' and D.dpcbt = 'C'
group by A.matnr, A.werks, A.lgort, B.lifnr, A.vbeln, A.posnr, C.meins, ch1.VALUE

union all

select from nsdm_e_mska as A inner join ekkn as B on A.vbeln = B.vbeln and A.posnr = B.vbelp
                                inner join ekpo as D on B.ebeln = D.ebeln and B.ebelp = D.ebelp       
                                inner join ekko as E on D.ebeln = E.ebeln            
                                inner join mara as C on A.matnr = C.matnr    
                                inner join marc as F on A.matnr = F.matnr and A.werks = F.werks  
association [0..1] to  ZGTMM_CV_SO_VCVALUE as ch1 on $projection.vbeln = ch1.vbeln and $projection.posnr = ch1.posnr and ch1.atnam = 'SAP_MILLCA_LENGTH'   
                           
{
  key A.matnr,
  key A.werks,
  key cast('매입보관재고' as abap.char(14)) as TYPE, 
  key A.lgort,
      E.lifnr,
      A.vbeln,
      A.posnr,   
      sum(A.kalab) as STOCK,
      C.meins,
      case when ch1.VALUE is not null then cast(ch1.VALUE as abap.dec(13,3)) else cast('0' as abap.dec(13,3)) end as length  
} where A.lgort = '3497' and B.zekkn = '01' and D.loekz = '' and F.dpcbt = 'A'

group by A.matnr, A.werks, A.lgort, E.lifnr, A.vbeln, A.posnr, C.meins, ch1.VALUE

