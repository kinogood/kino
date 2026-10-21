@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT]  절단/권취 작업 지시 관리 이력 존재여부 체크'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_CHK_ZGTPPT2190
  as select from zgtppt2190
{
      -- [1] 키 정보
  key zcut_ord_no,
  key zcut_ord_item,
      zassign_no,   -- 할당번호
      zassign_item, -- 할당품목

      case when sobkz = 'E' and zcut_mblnr is initial
           then zcut_cnt else 0 end as zcut_cnt

}
