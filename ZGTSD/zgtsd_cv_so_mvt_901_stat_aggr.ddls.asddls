@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 헤더 기준 보관입고 건수 집계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SO_MVT_901_STAT_AGGR
  as select from ZGTSD_CV_SO_ITEM_MVT_901_STAT
{
  key vbeln,

      -- 1. ZCS 대상 품목 총 건수
      count( * )                                     as total_cnt,

      -- 2. 완료(C) 상태인 품목 건수
      sum( case when kpsta = 'C' then 1 else 0 end ) as c_cnt,

      -- 3. 미완료(A) 상태인 품목 건수
      sum( case when kpsta = 'A' then 1 else 0 end ) as a_cnt 

}
group by
  vbeln
