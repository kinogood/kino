@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '청구번호_구매오더 매핑 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_CL_PO_DAT 
as select from zgtppt3420 as a inner join ekpo as b  on a.werks = b.werks and b.bednr = a.reqno and b.afnam = a.posnr
{
 
  key a.reqno,
  key a.posnr,
  @Semantics.quantity.unitOfMeasure: 'pr_meins'    
  a.lfimg as pr_menge,
  a.erfme as pr_meins,
  @Semantics.quantity.unitOfMeasure: 'meins'  
  sum(b.menge) as MENGE,
  b.meins,
        
  @Semantics.quantity.unitOfMeasure: 'pr_meins'        
  case when a.erfme = b.meins then a.lfimg - sum(b.menge) 
       else 
          case when a.erfme = 'G' and b.meins = 'KG' then a.lfimg - sum(b.menge * 1000 )   
               when a.erfme = 'M' and b.meins = 'KM' then a.lfimg - sum(b.menge * 1000)
               else  a.lfimg end 
          end as diff_qty
} where b.loekz = ''

group by a.reqno, a.posnr, a.erfme , b.meins, a.lfimg, a.erfme
