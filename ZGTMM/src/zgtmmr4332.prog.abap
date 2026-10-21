*&---------------------------------------------------------------------*
*& 모듈        : MM
*& 프로그램 ID : ZGTMMR4332
*& 프로그램 명 : 납품서 유형별 입고현황 조회
*& 개요   : G-PRO 발행 납품서(INV 납품 명세서 / IVS 보관품 A·B)의 납품수량 대비
*&          실입고수량을 납품 문서별로 조회(대사)하고, 드럼(배치/꼬리표) 단위
*&          상세와 점검대상(중복/초과/오류)을 확인하는 조회 전용 프로그램
*&          (BAPI/DB 갱신 없음). 유형·기간 요약 모드는 화면에서 숨김
*& 생성일 : 2026.09.26
*& 생성자 :
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 입고수량 산출
*&  - 구매입고(101): ZGTMM_CV_DELIV_GR_101 (MATDOC SGTXT 의 납품서번호 기준, 취소/역분개 제외)
*&  - MES 재고이전(311): ZGTMM_CV_DELIV_GR_311 (ZGTMMT9425 -> 9423 -> MATDOC, ZSTAT='S')
*&  - 실입고수량 = 101 + 311 (전량 합산, 중복은 대사 플래그로 표시)
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
REPORT zgtmmr4332 MESSAGE-ID zgtmm01.

*&---------------------------------------------------------------------*
*&    INCLUDE.
*&---------------------------------------------------------------------*
INCLUDE zgtmmr4332top.  " GLOBAL DATA / SELECTION SCREEN
INCLUDE zgtmmr4332c01.  " ALV EVENT HANDLER CLASS
INCLUDE zgtmmr4332f01.  " FORM-ROUTINES (조회/계산)
INCLUDE zgtmmr4332f02.  " FORM-ROUTINES (ALV 출력)

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM initialization. "납품일자 기본값(당월 1일 ~ 오늘)

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM screen_output. "점검대상 조건은 ZLSGMM5 계정만 표시

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM type_change.    "납품 명세서 <-> 보관품 동시 선택 방지
  PERFORM add_keep_werks. "매입/매출보관품 선택 시 플랜트 6591/6691 추가
  PERFORM check_auth.
  PERFORM check_input.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  IF sy-uname <> gc_chk_user.
    CLEAR p_chk. "점검대상은 ZLSGMM5 계정만
  ENDIF.
  PERFORM select_data.
  PERFORM filter_label_batch. "배치번호 / 드럼라벨번호 조건
  IF gt_item IS INITIAL.
    MESSAGE '조회 결과가 없습니다.' TYPE 'S' DISPLAY LIKE 'W'.
    RETURN.
  ENDIF.

  PERFORM get_label_status.
  PERFORM get_reserved_so.
  PERFORM calc_item.
  PERFORM get_jojang.
  PERFORM get_po_total.
  PERFORM build_doc.
  PERFORM filter_doc.

  IF gt_doc IS INITIAL.
    MESSAGE '조회 결과가 없습니다.' TYPE 'S' DISPLAY LIKE 'W'.
    RETURN.
  ENDIF.

  IF p_m1 = gc_x.
    PERFORM build_sum.
    PERFORM display_sum.
  ELSE.
    PERFORM filter_item.
    IF gt_item IS INITIAL.
      MESSAGE '조회 결과가 없습니다.' TYPE 'S' DISPLAY LIKE 'W'.
      RETURN.
    ENDIF.
    IF p_m3 = gc_x.
      PERFORM display_detail.      "납품 문서별 상세 (배치/꼬리표)
    ELSE.
      IF p_inv = gc_x.
        PERFORM display_item USING 'I'. "납품 명세서
      ENDIF.
      IF p_ivsa = gc_x OR p_ivsb = gc_x.
        PERFORM display_item USING 'S'. "매입/매출보관품
      ENDIF.
    ENDIF.
  ENDIF.
