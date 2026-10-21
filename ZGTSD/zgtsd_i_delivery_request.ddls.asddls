@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 출하요청정보 (ZLET0400, ZLET0401)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_DELIVERY_REQUEST
  as select from    zlet0400               as _Header
    inner join      zlet0401               as _Item       on _Header.dlvrq = _Item.dlvrq
    left outer join zlet0402               as _Deliv      on _Header.dlvrq = _Deliv.dlvrq
    left outer join ZGTSD_I_VALID_INV_ITEM as _inv        on  _Deliv.vgbel = _inv.vbeln
                                                          and _Deliv.vgpos = _inv.posnr
                                                          and _inv.iv_type = 'A01'
//    left outer join zgtmmt4410             as _dreq       on  _Header.vkorg     =  _dreq.bukrs
//                                                          and _Item.werks       =  _dreq.werks
//                                                          and _Header.zreq_type =  _dreq.zreq_type
//                                                          and _Header.dlvrq     =  _dreq.dlvrq
//                                                          and _dreq.zsd_stat    <> 'D' // 삭제
//    left outer join zgtmmt4411             as _ndreq      on  _dreq.dlvrq = _ndreq.dlvrq -- 생산예정품직송(A)
//                                                          and _dreq.bukrs = _ndreq.bukrs
//                                                          and _Item.vbeln = _ndreq.vbeln
//                                                          and _Item.posnr = _ndreq.posnr
//    left outer join zgtmmt4403             as _ndreq_ship on  _ndreq.dlvrq = _ndreq_ship.dlvrq -- 생산예정품직송 배차정보
//                                                          and _ndreq.vbeln = _ndreq_ship.vbeln
//                                                          and _ndreq.posnr = _ndreq_ship.posnr
//                                                          and _ndreq.ebeln = _ndreq_ship.ebeln
//                                                          and _ndreq.ebelp = _ndreq_ship.ebelp
//                                                          and _ndreq.bukrs = _ndreq_ship.bukrs
//    left outer join zgtmmt4412             as _kdreq      on  _dreq.dlvrq = _kdreq.dlvrq -- 매입보관품직송(B)
//                                                          and _dreq.bukrs = _kdreq.bukrs
//                                                          and _Item.vbeln = _kdreq.vbeln
//                                                          and _Item.posnr = _kdreq.posnr
//    left outer join zgtmmt4405             as _kdreq_ship on  _kdreq.bukrs = _kdreq_ship.bukrs -- 매입보관품 배차정보
//                                                          and _kdreq.dlvrq = _kdreq_ship.dlvrq
//                                                          and _kdreq.vbeln = _kdreq_ship.vbeln
//                                                          and _kdreq.posnr = _kdreq_ship.posnr


  association [1..1] to makt as _MaterialText on  $projection.matnr   = _MaterialText.matnr 
                                              and _MaterialText.spras = $session.system_language
{
      // 1. 키 정보 (Key Information)
  key cast(_Item.dlvrq as zedlvrq preserving type )                                             as dlvrq,     // 출하요청번호
  key cast(_Item.vbeln as vbeln_va preserving type )                                            as vbeln,     // 판매 문서
  key cast(_Item.posnr as posnr_va preserving type )                                            as posnr,     // 판매 문서 항목

      // 2. 참조 문서 (Reference Document)
  key cast(_Deliv.vgbel as vbeln_vl preserving type )                                           as vbeln_do,  // 납품 문서
  key cast(_Deliv.vgpos as posnr_vl preserving type )                                           as posnr_do,  // 납품 문서 항목

//  key coalesce(_ndreq_ship.zseq, _kdreq_ship.zseq)                                              as zseq,      //배차정보 순번
      // 3. 자재 및 수량 (Material & Quantity)
      _Item.matnr,                                                                                            // 자재 번호
      _MaterialText.maktx,                                                                                    // 자재 내역
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      _Item.kwmeng,                                                                                           // 누적 오더 수량(판매 단위)
      _Item.vrkme,                                                                                            // 판매 단위
      cast(_Item.indlen as zeindlen preserving type )                                           as indlen,    // 조장
      cast(_Item.indqty as zeindqty preserving type )                                           as indqty,    // 조장수
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      cast(_Item.dlrmg as zedlrmg preserving type )                                             as dlrmg,     // 출하요청수량

      // 4. 조직 (Organization)
      _Header.vkorg,                                                                                          // 영업 조직
      _Header.vtweg,                                                                                          // 유통 경로
      _Header.spart,                                                                                          // 제품군
      _Header.vkbur,                                                                                          // 영업팀
      _Header.vkgrp,                                                                                          // 영업 그룹
      _Item.werks,                                                                                            // 플랜트

      // 5. 파트너 (Partner)
      _Header.kunag,                                                                                          // 판매처
      _Header.kunwe,                                                                                          // 납품처
      _Header.extension1                                                                        as recipient, // 수령인
      _Header.tel_number                                                                        as rcpt_tel,  // 수령인 연락처
      _Header.cust_name,                                                                                      // 고객 담당자
      _Header.cust_tel,                                                                                       // 담당자 연락처

      // 6. 물류 및 일정 (Logistics & Schedule)
      _Header.auart, // 판매 문서 유형
      cast(_Header.trtyp as zetrtyp preserving type )                                           as trtyp,     // 운송유형
      cast(_Header.zreq_type as zgte_reqtype preserving type )                                  as zreq_type, // 직송의뢰 신청 유형
      _Header.kdkg4,                                                                                          // 고객조건그룹 4
      _Header.post_code1,                                                                                     // 도시우편번호
      _Header.land1,                                                                                          // 국가/지역 키
      _Header.lzone,                                                                                          // 상품이 출발하거나 도착하는 운송 구역
      _Header.city1,                                                                                          // 도시
      _Item.edatu,                                                                                            // 일정 라인 일자
      _Header.drdat,                                                                                          // 출하요청일
      _Header.drtim,                                                                                          // 출하요청시간
      _Header.arrdt,                                                                                          // 도착일
      _Header.arrtm,                                                                                          // 도착시간

      // 7. 상태 및 비고 (Status & Text)
      _Item.lecfm,                                                                                            // 출하확정
      cast(_Header.remark as zgte_ivrmk preserving type )                                       as iv_remark, // 거래명세서 특이사항
      cast(_Header.zremark1 as zgte_lermk preserving type )                                     as le_remark, // 출하실전달 특이사항
      _Header.erdat,                                                                                          // 출하요청 생성일

      // 8. 공장 거래명세서
      _inv.iv_no,                                                                                             // 거래명세서번호
      _inv.iv_print_yn,                                                                                       // 거래명세서 출력여부
      _inv.iv_date,                                                                                           // 거래명세서 출력일자
      _inv.out_yn,                                                                                            // 통문여부
      _inv.out_date,                                                                                          // 통문일자
      _inv.out_time,                                                                                          // 통문시간

      _inv.driver_nm,                                                                                         // 운전자명
      _inv.driver_telno,                                                                                      // 운전자 연락처
      _inv.truck_no                                                                                          // 차량번호

      // 8. 일반직송상태 (Direct Delivery Status - Normal)
//      _ndreq.ebeln,                                                                                           // 구매 문서
//      _ndreq.ebelp,                                                                                           // 구매 문서 항목
//      cast(coalesce(_ndreq.zmm_stat, _kdreq.zmm_stat) as zgte_reqstatp preserving type )        as zmm_stat,  // 직송 접수 상태(구매)
//      coalesce(_ndreq.zmm_date, _kdreq.zmm_date)                                                as zmm_date,  // 구매팀 접수일자
//      cast(coalesce(_ndreq.zvd_stat, _kdreq.zvd_stat) as zgte_reqstatv preserving type )        as zvd_stat,  // 직송 접수 상태(업체)
//      coalesce(_ndreq.per_name, _kdreq.per_name)                                                as per_name,  // 업체 접수 담당자
//      coalesce(_ndreq.zvd_date, _kdreq.zvd_date)                                                as zvd_date,  // 업체승인일자
//      coalesce(_ndreq.zvd_time, _kdreq.zvd_time)                                                as zvd_time,  // 업체승인시간
//
//      //9. 생산예정품/매입보관품 배차정보
//      cast(coalesce(_ndreq_ship.ztrtype, _kdreq_ship.ztrtype ) as zgte_trtype preserving type ) as ztrtype, // 직송 거래 운송 방식
//
//      coalesce(
//          concat( _ndreq_ship.regiont,                                                                           // 지역
//            concat( _ndreq_ship.no2digit,                                                                        // 숫자 2자리
//                    concat( _ndreq_ship.ch1digit,                                                                // 문자 1자리
//                            _ndreq_ship.no4digit ) ) )  ,                                                        // 숫자 4자리 및 최종 차량번호 ALIAS
//
//          concat( _kdreq_ship.regiont,                                                                           // 지역
//            concat( _kdreq_ship.no2digit,                                                                        // 숫자 2자리
//                    concat( _kdreq_ship.ch1digit,                                                                // 문자 1자리
//                            _kdreq_ship.no4digit ) ) )                                                           // 숫자 4자리 및 최종 차량번호 ALIAS
//       )                                                                                        as carplate,
//      coalesce(_ndreq_ship.tel, _kdreq_ship.tel)                                                as tel,          // 운송자 연락처
//      coalesce(_ndreq_ship.name, _kdreq_ship.name)                                              as name,         // 운송자 이름
//      coalesce(_ndreq_ship.parcelname, _kdreq_ship.parcelname)                                  as PARCELNAME,   //택배사명
//      @Semantics.quantity.unitOfMeasure: 'dr_meins'
//      coalesce(_ndreq_ship.loadqty, _kdreq_ship.loadqty)                                        as loadqty,      // 적재수량
//      coalesce(_ndreq_ship.dr_meins, _kdreq_ship.dr_meins)                                      as dr_meins,     // 드럼 단위
//      coalesce(_ndreq_ship.zdoc_no, _kdreq_ship.zdoc_no)                                        as ZDOC_NO,      // 거래명세서번호
//      coalesce(_ndreq_ship.zdoc_item_no, _kdreq_ship.zdoc_item_no)                              as ZDOC_ITEM_NO, // 거래명세서품목번호
//      coalesce(_ndreq_ship.zdoc_date, _kdreq_ship.zdoc_date)                                    as ZDOC_DATE,    // 거래명세서생성일
//      coalesce(_ndreq_ship.delno, _kdreq_ship.delno)                                            as DELNO,        // 납품 문서번호
//      coalesce(_ndreq_ship.delitem, _kdreq_ship.delitem)                                        as DELITEM,      // 납품 문서 품목 번호
//      coalesce(_ndreq_ship.printyn, _kdreq_ship.printyn)                                        as PRINTYN,      // 거래명세서출력여부
//      coalesce(_ndreq_ship.gidate, _kdreq_ship.gidate)                                          as GIDATE        // 출하일자

}
where
  _Item.lvorm is initial // 삭제 지시자 (초기값 필터링)
