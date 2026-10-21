@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 납품문서 수량 조장 수 정보'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_GET_DLVQTY_FACTOR  
  as select from    ZGTSD_I_DLVQTY_FACTOR_BASE as a
    left outer join ZGTSD_CV_GET_VCOFSO        as b on  a.vgbel = b.vbeln
                                                    and a.vgpos = b.posnr
{
  key a.vbeln,
  key a.posnr,
      a.vgbel,
      a.vgpos,
      a.werks,
      a.matnr,
      a.arktx,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      b.LENGTH,

      -- 합산된 수량(sum)을 기준으로 팩터 계산
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast( cast(
              case when b.LENGTH is not null and b.LENGTH <> 0
                   then cast ( ( sum(a.lfimg) / b.LENGTH ) as abap.quan(13,3) )
                   else null end
            as int4 )
      as zgtewecnt preserving type )               as factor,

      -- 배치 분할 품목 수량 합산
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(sum(a.lfimg) as lfimg preserving type ) as lfimg,

      a.vrkme
}
group by
  a.vbeln,
  a.posnr,
  a.vgbel,
  a.vgpos,
  a.werks,
  a.matnr,
  a.arktx,
  b.LENGTH,
  a.vrkme
