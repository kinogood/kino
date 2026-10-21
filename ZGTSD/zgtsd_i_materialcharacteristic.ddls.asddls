@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 자재마스터 특성 값 조회 (Class 001)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_MaterialCharacteristic
  as select from mara as _Material
    inner join   kssk as _Assignment on  _Material.matnr   = _Assignment.objek
                                    and _Assignment.klart  = '001' -- 자재 클래스
                                    and _Assignment.mafid  = 'O'   -- Object
    inner join   ausp as _CharValue  on  _Assignment.objek =_CharValue.objek
                                    and _Assignment.klart  = _CharValue.klart
                                    and _Assignment.mafid  = _CharValue.mafid
                                    and _CharValue.datub   = '99991231'
    inner join   cabn as _CharDef    on  _CharValue.atinn  = _CharDef.atinn
                                    and _CharValue.adzhl   = _CharDef.adzhl
                                    and _CharDef.datub     = '99991231'

  -- 텍스트 정보는 필요할 때만 읽도록 Association 처리
  association [0..1] to makt  as _MaterialText on  _Material.matnr      = _MaterialText.matnr
                                               and _MaterialText.spras  = $session.system_language
  association [0..1] to cabnt as _CharText     on  _CharValue.atinn     = _CharText.atinn
                                               and _CharValue.adzhl     = _CharText.adzhl
                                               and _CharText.spras      = $session.system_language
{
  key cast(_Material.matnr as matnr preserving type )  as matnr,
  key _CharDef.atnam,
      _CharValue.atinn,
      _CharValue.adzhl,
      _CharText.atbez,

      -- 값 처리 로직 (문자열 값이 없으면 수치형 값을 변환하여 표시) 
      case
        when _CharValue.atwrt is initial
        then cast( round( fltp_to_dec(_CharValue.atflv as abap.dec(13,3) ), 3) as atwrt )
        else _CharValue.atwrt
      end                                             as atwrt,

      -- 수치형 값 별도 필드 (계산용)
      @Semantics.quantity.unitOfMeasure: 'Unit'
      fltp_to_dec(_CharValue.atflv as abap.dec(13,3) ) as atflv,

      _CharValue.atawe                                 as Unit,

      _MaterialText.maktx,
      -- Associations 노출
      _MaterialText,
      _CharText
}
where _Material.lvorm <> 'X'
