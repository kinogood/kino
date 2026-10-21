@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 헤더 기준 보관입고 통합 상태'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SO_HDR_MVT_901_STAT
  as select from ZGTSD_CV_SO_MVT_901_STAT_AGGR
{ 

  key vbeln,

      total_cnt,
      c_cnt,
      a_cnt,

      -- 헤더 상태 결정 로직
      case
        when total_cnt = c_cnt then 'C' -- 모든 품목이 완료(C)
        when total_cnt = a_cnt then 'A' -- 모든 품목이 미완료(A)
        else 'B'                        -- 상태 혼재 (부분완료)
      end as kpstk
}
