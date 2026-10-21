@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 사급자재 소요량 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_RESB_SC_MAT 
as select from resb
{
   key ebeln,
   key ebelp,
   key matnr as IDNRK,
   @Semantics.quantity.unitOfMeasure: 'ERFME'   
   case when erfme = 'G' then cast(round(sum(erfmg) / 1000 ,3) as bamng) 
   else sum(erfmg) end as ERFMG,
   case when erfme = 'G' then cast('KG' as bstme) else erfme end as ERFME,  
   postp
} where ebeln <> '' and xloek  = '' and dumps = ''
group by ebeln, ebelp, matnr, erfme, postp
