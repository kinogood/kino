@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 가온 가용재고 조회 Base'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_GET_AVAILABLE_STOCK

  // 1. Single Unit Batch: Link 내역이 없는 Batch 재고
  as select from ZGTSD_I_AVAILABLE_STOCK
{
  key matnr,
  key werks,
  key lgort,

      @Semantics.quantity.unitOfMeasure: 'meins'
      mchb_length                                 as length,
      meins,
      cast( sum(mchb_factor)       as abap.dec(13,3)) as Stock,
      'N'                                             as CUT_REQUIRED
}
where
  (
       linked_length   =  0
    or linked_length   is null
  )
  and  dimid           =  'LENGTH'
  and  unlinked_length >  0
  and  unlinked_factor =  0
  and  dpcbt           <> 'A'
group by
  matnr,
  werks,
  lgort,
  mchb_length,
  meins
  

union

// 2. Single Unit Batch: 잔여 가용수량 (Batch재고 - Picked수량 - Link재고)
select from ZGTSD_I_AVAILABLE_STOCK
{
  key matnr,
  key werks,
  key lgort,

      unlinked_length    as length,
      meins,
      cast(
          sum(unlinked_factor)
      as abap.dec(13,3)) as Stock,
      'Y'                as CUT_REQUIRED

}
where
  (
        unlinked_length >  0
    and unlinked_factor >  0 -- 
  )
  and   dimid           =  'LENGTH'
  and   dpcbt           <> 'A'
group by
  matnr,
  werks,
  lgort,
  meins,
  unlinked_length

union

// 3. 조장/조장 수 관계가 아닌 재고
select from ZGTSD_I_AVAILABLE_STOCK
{
  key matnr,
  key werks,
  key lgort,

      0                  as length,
      meins,
      cast(
        sum(unlinked_length)
      as abap.dec(13,3)) as Stock,
      'N/A'              as CUT_REQUIRED

}
where
  (
       mchb_factor  is initial
    or mchb_factor  is null
    or mchb_factor  =  0
  )
  and  unpicked_qty >  0
  and  dimid        <> 'LENGTH'
  and  ( dpcbt is null or dpcbt is initial )
group by
  matnr,
  werks,
  lgort,
  meins


union

// 4. Factor Batch: 절단 없기 때문에 항상 CUT_REQUIRED: N/A
//                : mchb_length = mchb-charg
//                : Unlinked Factor = (Batch재고 - Picked재고 - Linked재고) / 길이               
select from ZGTSD_I_AVAILABLE_STOCK
{
  key matnr,
  key werks,
  key lgort,

      mchb_length        as length,
      meins,
      cast(
        sum(unlinked_factor)
      as abap.dec(13,3)) as Stock,
      'N/A'              as CUT_REQUIRED
}
where
  (
        unlinked_length > 0
    and unlinked_factor > 0
  )
  and   dpcbt           = 'A'
  and   dimid           = 'LENGTH'
group by
  matnr,
  werks,
  mchb_length,
  lgort,
  meins

union

-- 배치 관리 미사용 자재 재고
select from ZGTSD_I_AVAILABLE_STOCK_MARD
{
  key matnr,
  key werks,
  key lgort,

      cast( 0                      as abap.quan(13,3)) as length, -- 
      meins,
      cast( sum(unpicked_qty)      as abap.dec(13,3))  as Stock,  -- MARD 가용수량 집계
      'N/A'                                            as CUT_REQUIRED
}
where
      unpicked_qty > 0  
group by
  matnr,
  werks,
  lgort,
  meins
