@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 소재 통합 전후 가격마스터 비교'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_COND_MAPPING 
with parameters
    p_spart : spart,
    p_date  : abap.dats
as select from ZGTSD_CV_COND_A515_USAGE ( p_spart : $parameters.p_spart,
                                          p_date  : $parameters.p_date ) as A515
                                  inner join ZGTSD_IV_MATMAPPING as mapping 
                                        on A515.matnr = mapping.SOURCEMATERIAL
                                  left outer join ZGTSD_CV_COND_A514_USAGE ( p_spart : $parameters.p_spart,
                                                                             p_date  : $parameters.p_date ) as A514 
                                        on mapping.TARGETMATERIAL = A514.matnr
                                       and mapping.GRADE = A514.varcond 
                                       and A515.vkorg = A514.vkorg
                                       and A515.vtweg = A514.vtweg
                                       and A515.spart = A514.spart
                                       and A515.kunnr = A514.kunnr              
{
      key A515.vkorg as A515_VKORG,
      key A515.vtweg as A515_VTWEG,
      key A515.spart as A515_SPART,
      key A515.kunnr as A515_KUNNR,
      key A515.matnr as A515_MATNR,
      A515.maktx     as A515_MAKTX,
      @Semantics.amount.currencyCode: 'A515_KONWA'
      A515.kbetr     as A515_KBETR,
      A515.konwa     as A515_KONWA,
      A515.kpein     as A515_KEPIN,
      A515.kmein     as A515_KEMIN,
      A515.knumh     as A515_KNUMH,
      A515.datab     as A515_DATAB,
      A515.datbi     as A515_DATBI,
      A515.YN        as A515_YN,
      
      A514.vkorg     as A514_VKORG,
      A514.vtweg     as A514_VTWEG,
      A514.spart     as A514_SPART,
      A514.kunnr     as A514_KUNNR,
      A514.matnr     as A514_MATNR,
      A514.varcond   as A514_GRADE,
      A514.maktx     as A514_MAKTX,
      @Semantics.amount.currencyCode: 'A514_KONWA'
      A514.kbetr     as A514_KBETR,
      A514.konwa     as A514_KONWA,
      A514.kpein     as A514_KPEIN,
      A514.kmein     as A514_KMEIN,
      A514.datab     as A514_DATAB,
      A514.datbi     as A514_DATBI,
      A514.YN        as A514_YN
}
