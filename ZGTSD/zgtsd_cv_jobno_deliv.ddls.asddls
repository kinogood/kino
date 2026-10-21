@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT-SD] Delivery Order 정보 제조지시변환'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_JOBNO_DELIV
  as select from lips as a
    left outer join mch1 as b
      on  a.matnr = b.matnr
      and a.charg = b.charg
      and b.lvorm <> 'X'
    inner join zgtsdt0067 as c
      on  b.zzjob_no      = c.job_no
      and b.zzline_no     = c.line_no
      and b.zzserial_info = c.serial_info
    inner join zgtsdt0066 as d
      on  c.job_no = d.job_no
      and c.posnr  = d.posnr
{
  /* 키 */
  key a.vbeln,            // 납품문서
  key a.posnr,            // 납품 아이템 (base에서 직접 선택 → SH 상속)
  key c.job_no,           // 작업지시번호

  /* 식별/표시 필드 */
  a.matnr,
  a.arktx,

  /* 수량/단위 */
  @Semantics.quantity.unitOfMeasure: 'qunit'
  c.qqty     as qty,
  c.qunit   as qunit,

  /* 단가/통화 (원본) */
@Semantics.amount.currencyCode: 'qwaerk'
  d.qprice  as qprice,    // 원본은 CURR일 수 있음 (표시는 가능)
  d.qwaerk  as qwaerk,

  /* 금액 (계산값) : CURR 타입 직접 연산 금지 → DEC로 캐스팅 후 계산 */
@Semantics.amount.currencyCode: 'qwaerk'
    cast(
      cast( c.qqty    as abap.dec(16,3) )   /* 수량: 최대 13자리+소수3 → 총 16,3 가정 */
    * cast( d.qprice  as abap.dec(15,2) )   /* 단가: 최대 13자리+소수2 → 총 15,2 가정 */
      as abap.dec(31,2)                     /* 결과 금액 표시 자릿수 */
    ) as qnetwr
}
