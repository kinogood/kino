@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 헤더 상태 집계 (중간 뷰)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SO_STAT_AGGR
  as select from ZGTSD_CV_SO_ITEM_STATUS
{
  key vbeln,
      vkorg,
      vtweg,
      spart, 
      vkbur,
      vkgrp,

      -- 전체 품목 수 (빌링 및 통합 상태 판별용: 취소된 아이템만 제외)
      sum ( case when absta = 'C' then 0 else 1 end )                                     as total_item_cnt,

      -- 납품 유효 품목 수 (납품 상태 판별용: 취소 및 서비스(TAD) 아이템 제외)
      sum ( case when absta = 'C' or pstyv = 'TAD' then 0 else 1 end )                    as dlv_item_cnt,
      
      -- 출하요청
      sum( case when absta <> 'C' and drsta = 'C' then 1 else 0 end )                     as c_dlvrq_cnt,
      sum( case when absta <> 'C' and drsta = 'A' then 1 else 0 end )                     as a_dlvrq_cnt,
      sum( case when absta <> 'C' and drsta = ''  then 1 else 0 end )                     as space_dlvrq_cnt,
      
      -- 납품문서
      sum( case when absta <> 'C' and lfsta = 'C' then 1 else 0 end )                     as c_lfsta_cnt,
      sum( case when absta <> 'C' and lfsta = 'A' then 1 else 0 end )                     as a_lfsta_cnt,
      sum( case when absta <> 'C' and lfsta = ''  then 1 else 0 end )                     as space_lfsta_cnt,
      
      -- 출고상태
      sum( case when absta <> 'C' and wbsta = 'C' then 1 else 0 end )                     as c_gi_cnt,
      sum( case when absta <> 'C' and wbsta = 'A' then 1 else 0 end )                     as a_gi_cnt,
      sum( case when absta <> 'C' and wbsta = ''  then 1 else 0 end )                     as space_gi_cnt,
      
      -- 거래명세서
      sum( case when absta <> 'C' and ivsta = 'C' then 1 else 0 end )                     as c_iv_cnt,
      sum( case when absta <> 'C' and ivsta = 'A' then 1 else 0 end )                     as a_iv_cnt,
      sum( case when absta <> 'C' and ivsta = ''  then 1 else 0 end )                     as space_iv_cnt,
      
      -- 통문
      sum( case when absta <> 'C' and gosta = 'C' then 1 else 0 end )                     as c_zout_cnt,
      sum( case when absta <> 'C' and gosta = 'A' then 1 else 0 end )                     as a_zout_cnt,
      sum( case when absta <> 'C' and gosta = ''  then 1 else 0 end )                     as space_zout_cnt,
      
      -- 빌링
      sum( case when absta <> 'C' and fksta = 'C' then 1 else 0 end )                     as c_fk_cnt,
      sum( case when absta <> 'C' and fksta = 'A' then 1 else 0 end )                     as a_fk_cnt,

      -- 적송
      sum( case when absta <> 'C' and dfsta = 'C' then 1 else 0 end )                     as c_df_cnt,
      sum( case when absta <> 'C' and dfsta = 'A' then 1 else 0 end )                     as a_df_cnt,
      sum( case when absta <> 'C' and dfsta = ''  then 1 else 0 end )                     as space_df_cnt,

      -- 구매입고
      sum( case when absta <> 'C' and grsta = 'C' then 1 else 0 end )                     as c_gr_cnt,
      sum( case when absta <> 'C' and grsta = 'A' then 1 else 0 end )                     as a_gr_cnt,
      sum( case when absta <> 'C' and grsta = ''  then 1 else 0 end )                     as space_gr_cnt
      
//      sum( case when absta <> 'C' and gbsta = 'C' then 1 else 0 end )                     as c_gbsta_cnt,
//      sum( case when absta <> 'C' and gbsta = 'A' or gbsta is initial then 1 else 0 end ) as a_gbsta_cnt

}
group by
  vbeln,
  vkorg,
  vtweg,
  spart,
  vkbur,
  vkgrp
