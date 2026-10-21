@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '수입 운임 비율 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_KONP_ZFR1 
as select from konh as A inner join konp as B on A.knumh = B.knumh
{
  key A.knumh,  
  key A.datab,
  key A.datbi,
  key B.kschl,   
      @Semantics.amount.currencyCode: 'KONWA' 
      cast(cast(cast(B.kbetr as abap.dec(11,2)) / cast(10 as abap.dec(11,2)) as abap.dec(11,2)) as kbetr_kond) as KBETR,
      B.konwa
  
} where A.kotabnr = '017' and A.kappl = 'M' and B.kappl = 'M' and ( B.kschl = 'ZFR1' or B.kschl = 'ZFR2') and B.loevm_ko = ''
