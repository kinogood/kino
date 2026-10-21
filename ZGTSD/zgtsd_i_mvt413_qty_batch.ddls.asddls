@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 재고 413 처리 수량 Batch 기준'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_MVT413_QTY_BATCH
  as select from    matdoc              as _Matdoc
    inner join      mara                as _Mst  on _Matdoc.matnr = _Mst.matnr
    inner join      marc                as c     on  _Matdoc.matnr = c.matnr
                                                 and _Matdoc.werks = c.werks
    inner join      t006                as d     on _Mst.meins = d.msehi

    left outer join ZGTSD_CV_GET_VCOFSO as _Char on  _Matdoc.matnr     = _Char.matnr
                                                 and _Matdoc.mat_kdauf = _Char.vbeln
                                                 and _Matdoc.mat_kdpos = _Char.posnr
{
      -- [1] 키 정보
  key cast(_Matdoc.mat_kdauf as vbeln_va preserving type ) as vbeln, -- 판매오더 번호
  key cast(_Matdoc.mat_kdpos as posnr_va preserving type ) as posnr, -- 판매오더 품목

      -- [2] 특성값 및 조직
      _Matdoc.matnr,
      _Matdoc.charg,
      _Matdoc.werks,
      _Matdoc.lgort,
      @Semantics.quantity.unitOfMeasure: 'meins'
      _Char.LENGTH,

      -- [3] 수량 및 금액
      @Semantics.quantity.unitOfMeasure: 'meins'
      sum(
        case when _Matdoc.bwart = '414'
             then _Matdoc.erfmg*-1
             else _Matdoc.erfmg
             end)                                          as erfmg,

      @Semantics.quantity.unitOfMeasure: 'meins'
      sum(
        cast(
          case
            when d.dimid = 'LENGTH' and c.dpcbt = 'A'
            then case when _Char.LENGTH is not initial
                      then division(   case when _Matdoc.bwart = '414'
                                            then cast(_Matdoc.erfmg*-1 as abap.dec(13,3))
                                            else cast(_Matdoc.erfmg as abap.dec(13,3))
                                            end
                                     , cast(_Char.LENGTH as abap.dec(13,3))
                                     , 0 )
                 else 0 end
            when d.dimid = 'LENGTH' and c.dpcbt = 'C'
            then case when _Matdoc.bwart = '414'
                      then -1 else 1
                      end

            else case when _Matdoc.bwart = '414'
                      then _Matdoc.erfmg*-1
                      else _Matdoc.erfmg
                      end
          end as abap.quan( 13, 3 )
        )
      )                                                    as target_qty, -- 조건부 변환 수량 합계

      _Mst.meins -- 자재 기본 단위
}
where
      (  _Matdoc.bwart     = '413'
         or ( _Matdoc.bwart     = '414' and _Matdoc.smbln     is initial and _Matdoc.sjahr is initial ) )
  and   _Matdoc.cancelled = ''
  and   _Matdoc.mat_kdauf is not initial
  and   _Matdoc.mat_kdpos is not initial
//  and   _Matdoc.shkzg     = 'S'
group by
  _Matdoc.mat_kdauf,
  _Matdoc.mat_kdpos,
  _Matdoc.matnr,
  _Matdoc.charg,
  _Matdoc.werks,
  _Matdoc.lgort,
  _Char.LENGTH,
  _Matdoc.erfmg,
  _Mst.meins
