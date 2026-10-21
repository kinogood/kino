@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 헤더 기준 통합 상태'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SO_HDR_STATUS
  as select from    ZGTSD_CV_SO_STAT_AGGR        as _Aggr
    inner join      vbak                         as _Hdr       on _Aggr.vbeln = _Hdr.vbeln
    left outer join ZGTSD_CV_SO_HDR_MVT_901_STAT as _HoldStock on _Hdr.vbeln = _HoldStock.vbeln
{
  key _Hdr.vbeln, 
      _Hdr.auart,
      _Hdr.vbtyp,
      _Hdr.vkorg,
      _Hdr.vtweg,
      _Hdr.spart,
      _Hdr.vkbur,
      _Hdr.vkgrp,

      _Hdr.abstk,

      -- 0.출하요청 상태 (납품 대상 분모 적용)
      cast(
          case when _Hdr.vbtyp = 'C' or _Hdr.vbtyp = 'I'
               then case when _Aggr.dlv_item_cnt = 0 then ''
                         when _Aggr.dlv_item_cnt = _Aggr.space_dlvrq_cnt then ''
                         when _Aggr.dlv_item_cnt = _Aggr.c_dlvrq_cnt then 'C'
                         when _Aggr.dlv_item_cnt = _Aggr.a_dlvrq_cnt then 'A'
                         when _Hdr.abstk = 'C' then ''
                    else 'B' end
               else '' end
      as zgtedrstk preserving type)                        as drstk,

      -- 1.Delivery Order 생성 상태 (납품 대상 분모 적용)
      cast(
          case when _Hdr.vbtyp = 'C' or _Hdr.vbtyp = 'I'
               then case when _Aggr.dlv_item_cnt = 0 then ''
                         when _Aggr.dlv_item_cnt = _Aggr.space_lfsta_cnt then ''
                         when _Aggr.dlv_item_cnt = _Aggr.c_lfsta_cnt then 'C'
                         when _Aggr.dlv_item_cnt = _Aggr.a_lfsta_cnt then 'A'
                         when _Hdr.abstk = 'C' then ''
                     else 'B' end
               else '' end
      as lfstk preserving type )                           as lfstk,

      -- 2.Goods Issue 처리 상태 (납품 대상 분모 적용)
      cast(
          case when _Hdr.vbtyp = 'C' or _Hdr.vbtyp = 'I'
               then case when _Aggr.dlv_item_cnt = 0 then ''
                         when _Aggr.dlv_item_cnt = _Aggr.space_gi_cnt then ''
                         when _Aggr.dlv_item_cnt = _Aggr.c_gi_cnt then 'C'
                         when _Aggr.dlv_item_cnt = _Aggr.a_gi_cnt then 'A'
                         when _Hdr.abstk = 'C' then ''
                    else 'B' end
               else '' end
      as wbstk preserving type )                           as wbstk,

      -- 3.보관품 입고 상태 (납품 대상 분모 적용)
      cast(_HoldStock.kpstk as zgtekpstk preserving type ) as kpstk,

      -- 4.거래명세서 발행 상태 (납품 대상 분모 적용)
      cast(
          case when _Hdr.vbtyp = 'C' or _Hdr.vbtyp = 'I'
               then case when _Aggr.dlv_item_cnt = 0 then ''
                         when _Aggr.dlv_item_cnt = _Aggr.space_iv_cnt then ''
                         when _Aggr.dlv_item_cnt = _Aggr.c_iv_cnt then 'C'
                         when _Aggr.dlv_item_cnt = _Aggr.a_iv_cnt then 'A'
                         when _Hdr.abstk = 'C' then ''
                    else 'B' end
               else '' end
      as zgteivstk preserving type )                       as ivstk,

      -- 5.통문처리 상태 (납품 대상 분모 적용)
      cast(
          case when _Hdr.vbtyp = 'C' or _Hdr.vbtyp = 'I'
               then case when _Aggr.dlv_item_cnt = 0 then ''
                         when _Aggr.dlv_item_cnt = _Aggr.space_zout_cnt then ''
                         when _Aggr.dlv_item_cnt = _Aggr.c_zout_cnt then 'C'
                         when _Aggr.dlv_item_cnt = _Aggr.a_zout_cnt then 'A'
                         when _Hdr.abstk = 'C' then ''
                    else 'B' end
               else '' end
      as zgtegostk preserving type )                       as gostk,

      -- 6.Billing 처리 상태 (서비스 자재 포함하므로 total_item_cnt)
      cast(
          case when _Hdr.abstk = 'C' then ''
               when _Aggr.total_item_cnt is not initial
                and _Aggr.total_item_cnt = _Aggr.c_fk_cnt then 'C'
               when _Aggr.total_item_cnt is not initial
                and _Aggr.total_item_cnt = _Aggr.a_fk_cnt then 'A'
               when _Aggr.c_fk_cnt is initial and _Aggr.a_fk_cnt is initial then ''
               else 'B' end
      as fkstk preserving type )                           as fkstk,
      
      -- 7.적송처리 상태 (납품 대상 분모 적용)
      cast(
          case when _Hdr.vbtyp = 'C' or _Hdr.vbtyp = 'I'
               then case when _Aggr.dlv_item_cnt = 0 then ''
                         when _Aggr.dlv_item_cnt = _Aggr.space_df_cnt then ''
                         when _Aggr.dlv_item_cnt = _Aggr.c_df_cnt then 'C'
                         when _Aggr.dlv_item_cnt = _Aggr.a_df_cnt then 'A'
                         when _Hdr.abstk = 'C' then ''
                    else 'B' end
               else '' end
      as zgtegostk preserving type )                       as dfstk,

      -- 7.구매입고 상태 (납품 대상 분모 적용)      
      case when _Hdr.vbtyp = 'C' or _Hdr.vbtyp = 'I'
           then case when _Aggr.dlv_item_cnt = 0 then ''
                     when _Aggr.dlv_item_cnt = _Aggr.space_gr_cnt then ''
                     when _Aggr.dlv_item_cnt = _Aggr.c_gr_cnt then 'C'
                     when _Aggr.dlv_item_cnt = _Aggr.a_gr_cnt then 'A'
                     when _Hdr.abstk = 'C' then ''
                else 'B' end 
           else '' end as grstk

}
