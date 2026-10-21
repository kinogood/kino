@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 재고 413 처리 수량 합계'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_MVT413_QTY
  as select from matdoc              as _Matdoc
    inner join   mara                as _Mst   on  _Matdoc.matnr = _Mst.matnr
    inner join   marc                as c      on  _Matdoc.matnr = c.matnr
                                               and _Matdoc.werks = c.werks
    inner join   t006                as d      on  _Mst.meins    = d.msehi
    
    left outer join ZGTSD_CV_GET_VCOFSO as _Char on  _Matdoc.matnr     = _Char.matnr
                                                 and _Matdoc.mat_kdauf = _Char.vbeln
                                                 and _Matdoc.mat_kdpos = _Char.posnr
{
  -- =======================================================================
  -- [1] Key Information (키 정보)
  -- =======================================================================
  key cast( _Matdoc.mat_kdauf as vbeln_va preserving type ) as vbeln,           -- 판매오더 번호
  key cast( _Matdoc.mat_kdpos as posnr_va preserving type ) as posnr,           -- 판매오더 품목

  -- =======================================================================
  -- [2] Organizational Data (조직 정보)
  -- =======================================================================
      _Matdoc.werks,                                                            -- 플랜트
//    _Matdoc.lgort,

  -- =======================================================================
  -- [3] Quantities & Units (수량 및 단위 정보)
  -- =======================================================================
      _Mst.meins,                                                               -- 자재 기본 단위

      @Semantics.quantity.unitOfMeasure: 'meins'
      sum(
        cast(
          case 
               when d.dimid = 'LENGTH' and c.dpcbt = 'A'
               then case when _Char.LENGTH is not initial
                         then division( cast( case when _Matdoc.bwart = '414' 
                                                   then _Matdoc.erfmg * -1 
                                                   else _Matdoc.erfmg end as abap.dec(13,3) ), 
                                        cast( _Char.LENGTH as abap.dec(13,3) ), 0 )
                         else cast( 0 as abap.dec(13,3) ) 
                    end
               
               when d.dimid = 'LENGTH' and c.dpcbt = 'C'
               then case when _Matdoc.bwart = '414' 
                         then -1 
                         else 1 
                    end
               
               else case when _Matdoc.bwart = '414' 
                         then _Matdoc.erfmg * -1 
                         else _Matdoc.erfmg 
                    end
          end as abap.quan(13,3)
        )
      )                                                     as target_qty       -- 조건부 변환 수량 합계 (413은 +, 414는 - 적용)
}
where (    _Matdoc.bwart = '413' 
        or ( _Matdoc.bwart = '414' and _Matdoc.smbln is initial and _Matdoc.sjahr is initial ) )  -- 414 단독 기표 조건 추가
  and _Matdoc.cancelled =  ''
  and _Matdoc.mat_kdauf is not initial
  and _Matdoc.mat_kdpos is not initial
  and _Matdoc.shkzg = 'S'
group by
  _Matdoc.mat_kdauf,
  _Matdoc.mat_kdpos,
  _Matdoc.werks,
//_Matdoc.lgort,
  _Mst.meins
