@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] Batch 특성 값 조회'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_GET_BATCH_CHAR
  as select from mch1 as m
    inner join   mara as d on m.matnr = d.matnr
    inner join   ausp as a on m.cuobj_bm = a.objek
    inner join   cabn as b on a.atinn = b.atinn
{
      -- [1] 키 정보, 조직, 자재
  key m.matnr,                                        -- 자재번호
  key m.charg,                                        -- 배치번호
//  key m.werks,                                        -- 플랜트

      -- [2] 상태 및 기준 정보
      d.meins, -- 기본단위

      -- [3] 수량, 금액, 특성값 (단일행 피벗 및 중첩 함수 들여쓰기 적용)
      @Semantics.quantity.unitOfMeasure: 'meins'
      cast(
        coalesce(
          cast( max( case when b.atnam = 'SAP_MILLCA_LENGTH' 
                          then fltp_to_dec( a.atflv as abap.dec(13,3) ) 
                          else null end ) as abap.quan(13,3) ),
          cast( 0 as abap.quan(13,3) )
        )
      as zgteweleng preserving type ) as MILL_LENGTH, -- 조장 수량

      cast(
        coalesce(
          cast( max( case when b.atnam = 'SAP_MILLCA_FACTOR' 
                          then fltp_to_dec( a.atflv as abap.dec(13,3) ) 
                          else null end ) as int4 ),
          cast( 0 as int4 )
        )
      as zgtewecnt preserving type )  as FACTOR       -- 조장 수
}
where
      m.lvorm = ''
  and d.lvorm = ''
group by
  m.matnr,
  m.charg,
//  m.werks,
  d.meins
