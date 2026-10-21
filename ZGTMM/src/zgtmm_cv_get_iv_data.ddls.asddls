@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 별 송장 처리 현황'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_IV_DATA 
as select from ekbe as A inner join rseg as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp and A.belnr = B.belnr and A.gjahr = B.gjahr and A.buzei = RIGHT(B.buzei,4)
                         inner join rbkp as C on B.belnr = C.belnr and B.gjahr = C.gjahr
{
  key A.ebeln,
  key A.ebelp,
  key A.zekkn,
  key A.vgabe,
      B.belnr,
      B.gjahr,
      B.buzei,
      C.blart,
      C.bldat,
      C.budat,
      C.usnam,
      C.tcode,
      C.cpudt,
      C.cputm,
      C.vgart,
      C.bukrs,
      C.lifnr,
      C.waers,
      C.kursf,
      C.stblg,
      C.stjah,
      @Semantics.quantity.unitOfMeasure: 'BPRME'
      B.bpmng,
      B.bprme,
      @Semantics.amount.currencyCode: 'waers'  
      B.wrbtr,
      @Semantics.amount.currencyCode: 'LC_WAERS'
      A.dmbtr,
      cast('KRW' as abap.cuky( 5 )) as LC_WAERS,
      B.shkzg
        
} where A.vgabe = '2' or A.vgabe = '3'
