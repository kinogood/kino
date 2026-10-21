@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 유효 거래명세서 품목 단위 집계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_VALID_INV_ITEM
  as select from zlet0006 as a
    inner join   zlet0005 as b on a.iv_no = b.iv_no
{
  key a.vbeln,
  key a.posnr,
      
      b.iv_type,
      max(a.iv_no) as iv_no,
      b.iv_print_yn,
      b.iv_date,
      b.out_yn,
      b.out_date,
      b.out_time,
    
      @Semantics.quantity.unitOfMeasure: 'mtr_unit'
      a.lfimg,
      a.mtr_unit,
      
      b.driver_nm,
      b.driver_telno,
      b.truck_no

}
where
      b.iv_cancel_yn = ' ' -- 취소된 거래명세서 원천 배제 
  and b.iv_type      = 'A01'
group by
  b.iv_type,
  a.vbeln,
  a.posnr,
  b.iv_print_yn,
  b.iv_date,
  b.out_yn,
  b.out_date,
  b.out_time,
  a.lfimg,
  a.mtr_unit,
  b.driver_nm,
  b.driver_telno,
  b.truck_no
