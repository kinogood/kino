@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 조장, 조장 수 재고 조회'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_GET_SO_STOCK_BY_LENGTH
  as select from    nsdm_e_mska         as _EStock
    inner join      vbap                as _Item   on  _EStock.matnr = _Item.matnr
                                                   and _EStock.vbeln = _Item.vbeln
                                                   and _EStock.posnr = _Item.posnr
    inner join      mara                as _Mst    on _Item.matnr = _Mst.matnr
    
    inner join      marc                as _MstPlt on _Item.matnr  = _MstPlt.matnr
                                                   and _Item.werks = _MstPlt.werks
    
    inner join      t006                as _Unit   on _Item.vrkme = _Unit.msehi 

  //    left outer join ZGTSD_I_GET_BATCH_CHAR as _Char   on  _EStock.matnr =  _Char.matnr
  //                                                      and _EStock.werks =  _Char.werks
  //                                                      and _EStock.charg =  _Char.charg
  //                                                      and _Mst.dpcbt    <> 'A'

    left outer join ZGTSD_CV_GET_VCOFSO as _SoChar on  _EStock.vbeln = _SoChar.vbeln
                                                   and _EStock.posnr = _SoChar.posnr
{
      -- =======================================================================
      -- [1] Key Information (키 정보)
      -- =======================================================================
  key cast(_EStock.vbeln as vbeln_va preserving type ) as vbeln,  -- 판매오더 번호
  key cast(_EStock.posnr as posnr_va preserving type ) as posnr,  -- 판매오더 품목
  key _Item.auart_ana                              as auart,      -- 판매오더 유형
  key _EStock.matnr,                                              -- 자재 번호
  key _EStock.werks,                                              -- 플랜트
  key _EStock.lgort,                                              -- 저장 위치
  key _EStock.charg,                                              -- 배치 번호

      -- =======================================================================
      -- [2] Characteristics & Calculations (특성값 및 재고 연산)
      -- =======================================================================
      -- QUAN 타입의 혼용을 막기 위해 DEC로 명시적 형변환 후 COALESCE 적용
      //      coalesce( cast( _Char.atflv as abap.dec(13,3) ),
      //                cast( _SoChar.LENGTH as abap.dec(13,3) ) )                 as length,-- 길이 (Fallback 처리)

      cast( _SoChar.LENGTH as abap.dec(13,3) )     as length, -- 길이 (Fallback 처리)
      _Item.vrkme,                                            -- 판매 단위
      cast( _SoChar.MILL_LENGTH as abap.dec(13,3)) as mill_length,
      //      coalesce ( cast( _Char.atflv as abap.dec(13,3)),
      //                 cast(_SoChar.LENGTH as abap.dec(13,3)) ) as mill_length,
      _Mst.meins,

      -- DIVISION 함수의 인자로 QUAN/CURR 타입을 직접 사용할 수 없으므로 DEC 캐스팅 추가
      
      @Semantics.quantity.unitOfMeasure: 'meins'
      case when _Unit.dimid = 'LENGTH' and _MstPlt.dpcbt = 'A' and _SoChar.LENGTH is not initial
                 then division( cast(_EStock.kalab as abap.dec(13,3)), cast(_SoChar.LENGTH as abap.dec(13,3)), 0 )
           when _Unit.dimid = 'LENGTH' and _MstPlt.dpcbt = 'C'
                 then 1
           else cast(_EStock.kalab as abap.dec(13,3))
     end as Estock,
      
      
//      case when _Item.vrkme = _Mst.meins
//           then
//              case
//                   when _SoChar.LENGTH is not null and _SoChar.LENGTH > 0
//                   then division( cast( _EStock.kalab as abap.dec(13,3) ), cast( _SoChar.LENGTH as abap.dec(13,3) ), 0 )
//                   else cast(_EStock.kalab as abap.dec(13,3)) end
//           else
//              case
//                   when _SoChar.MILL_LENGTH is not null and _SoChar.MILL_LENGTH > 0
//                   then division( cast( _EStock.kalab as abap.dec(13,3) ), cast( _SoChar.MILL_LENGTH as abap.dec(13,3) ), 0 )
//                   else cast(_EStock.kalab as abap.dec(13,3)) end
//      end                                          as Estock, -- 조장 수 환산 재고

      -- =======================================================================
      -- [3] Quantities & Units (수량 및 단위 정보)
      -- =======================================================================
      @Semantics.quantity.unitOfMeasure: 'meins'
      _EStock.kalab -- 가용 재고

}
where
      _EStock.kalab >  0
  and _EStock.lgort <> '3499'
