@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매요청 별 PO 전환 수량'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_POQTY_BYPR 
as select from eban as A inner join ekpo as B on A.banfn = B.banfn and A.bnfpo = B.bnfpo
{
  key A.banfn,
  key A.bnfpo,
      @Semantics.quantity.unitOfMeasure: 'pr_meins'    
      A.menge as pr_Menge,
      A.meins as pr_meins,
      @Semantics.quantity.unitOfMeasure: 'meins'  
      sum(B.menge) as MENGE,
      B.meins,
      @Semantics.quantity.unitOfMeasure: 'pr_meins'        
      case when A.meins = B.meins then A.menge - sum(B.menge) 
           else 
               case when A.meins = 'G' and B.meins = 'KG' then A.menge - sum(B.menge * 1000 )   
                    when A.meins = 'M' and B.meins = 'KM' then A.menge - sum(B.menge * 1000)
                    else  A.menge end 
           end as diff_qty
    
} where B.loekz = ''
group by A.banfn, A.bnfpo, B.meins, A.menge, A.meins
