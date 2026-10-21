@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Link 재고 조회(LOEKZ=SPACE)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_GET_SO_LINK_STOCK_ITEM 
  as select from zgtppt2170 as A
    inner join   zgtppt2180 as B   on A.zassign_no = B.zassign_no
      left outer join ZGTSD_I_CHK_ZGTPPT2190 as Chk on  B.zassign_no   = Chk.zassign_no
                                                    and B.zassign_item = Chk.zassign_item
    inner join   vbak       as C   on A.vbeln = C.vbeln
    inner join   t006       as Mst on A.vrkme = Mst.msehi
{
      -- [1] 키 정보
  key A.vbeln,            -- 판매문서
  key A.posnr,            -- 품목

      -- [2] 조직
      C.vkorg,            -- 영업조직
      C.vtweg,            -- 유통경로
      C.spart,            -- 제품군
      C.vkbur,            -- 영업소
      C.vkgrp,            -- 영업그룹
      A.werks,            -- 플랜트
      B.lgort,            -- 저장위치

      -- [3] 자재 및 특성값
      A.matnr,            -- 자재번호
      B.f_charg as charg, -- 배치번호

      -- [4] 기준 정보 및 상태
      C.auart,            -- 판매문서유형
      A.vrkme,            -- 판매단위

      -- [5] 수량 및 금액
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      A.weleng  as length, -- 조장

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(
        case when Mst.dimid = 'LENGTH'
//             then cast( B.zcut_cnt as abap.quan(13,3))
//             else cast( B.zcut_cnt as abap.quan(13,3)) * A.weleng
                   then coalesce( cast( Chk.zcut_cnt as abap.quan(13,3) ), cast( B.zcut_cnt as abap.quan(13,3) ) )
                   else coalesce( cast( Chk.zcut_cnt as abap.quan(13,3) ), cast( B.zcut_cnt as abap.quan(13,3) ) ) * A.weleng
          end as abap.quan(13,3)
      )         as LStock -- 조장 수
}
where
  A.loekz = ''
//and A.loekz = 'C'  
  and coalesce(
          cast( Chk.zcut_cnt as abap.quan(13,3) ),
          cast( B.zcut_cnt as abap.quan(13,3) )
      )       > 0
