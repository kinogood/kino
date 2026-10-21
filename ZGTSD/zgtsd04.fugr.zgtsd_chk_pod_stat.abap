FUNCTION zgtsd_chk_pod_stat.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_VKORG) TYPE  VKORG
*"     REFERENCE(IV_VTWEG) TYPE  VTWEG
*"     REFERENCE(IV_SPART) TYPE  SPART
*"     REFERENCE(IV_AUART) TYPE  AUART
*"  EXPORTING
*"     VALUE(EV_PODKZ) TYPE  PODKZ
*"     VALUE(ES_RETURN) TYPE  BAPIRET2
*"  TABLES
*"      IT_VBEP STRUCTURE  VBEPVB
*"      CT_XVBKD STRUCTURE  VBKDVB OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_CHK_POD_STAT
*& 프로그램 명 : [GT] POD 처리여부 확인
*& 개요   :
*& 생성일 : 2025.04.29
*& 생성자 : ZGSIDEV04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
*-- 1. 로컬 데이터 선언
*-----------------------------------------------------------------------
*-- 갱신 지시자 정보
  CONSTANTS : BEGIN OF lc_updkz,
                i TYPE updkz_d    VALUE 'I',
                u TYPE updkz_d    VALUE 'U',
                d TYPE updkz_d    VALUE 'D',
              END OF lc_updkz.

  DATA : lt_vbep TYPE TABLE OF vbepvb WITH EMPTY KEY.

  CLEAR : ev_podkz, es_return.
*-----------------------------------------------------------------------
*-- 2. Import 값 정합성 확인
*-----------------------------------------------------------------------
  IF iv_vkorg IS INITIAL OR
     iv_vtweg IS INITIAL OR
     iv_spart IS INITIAL OR
     iv_auart IS INITIAL.
*-- 판매오더 Header 정보 없을경우 메세지 처리
    es_return = VALUE #(
                        type        = 'E'
                        id          = 'ZGTSD01'
                        number      = '007'
                        message_v1  = '판매오더'(e01)
                       ).

    PERFORM message_text_build      CHANGING es_return.
    RETURN.
  ENDIF.

  IF it_vbep[] IS INITIAL.
*-- 판매오더 Item 스케쥴 정보 없을경우 메세지 처리
    es_return = VALUE #(
                        type        = 'E'
                        id          = 'ZGTSD01'
                        number      = '007'
                        message_v1  = '스케쥴정보'(e02)
                       ).

    PERFORM message_text_build      CHANGING es_return.
    RETURN.
  ENDIF.

*-----------------------------------------------------------------------
*-- 3. 로직 구성
*-----------------------------------------------------------------------
  lt_vbep[] = CORRESPONDING #( it_vbep[] ).

*-- 판매오더 Header 정보 & Item 스케쥴 정보 기준 POD 처리관련 정보 Select
  WITH +ettyp AS ( SELECT a~ettyp
                     FROM @lt_vbep AS a
                    WHERE a~updkz NE @lc_updkz-d          "--> 삭제 지시자는 제외
                    GROUP BY a~ettyp )

    SELECT SINGLE @abap_true

      FROM zgtsdt1009 AS a INNER JOIN +ettyp AS b
                            ON a~ettyp EQ b~ettyp

     WHERE a~vkorg EQ @iv_vkorg
       AND a~vtweg EQ @iv_vtweg
       AND a~spart EQ @iv_spart
       AND a~auart EQ @iv_auart

      INTO @DATA(lv_podkz).

  IF sy-subrc NE 0.
    CLEAR lv_podkz.
  ENDIF.




*-- POD 처리여부 정보 리턴 --> Header / Item 품목 기준 하나라도 있는 경우 POD 처리여부 'X' 리턴
  ev_podkz = COND #( WHEN lv_podkz EQ abap_true THEN abap_true
                     ELSE abap_false ).

*-- 판매오더 비즈니스 영역 처리변경 정보 있는 경우 값 구성
  IF ct_xvbkd[] IS NOT INITIAL AND
     ev_podkz   EQ abap_true.         "--> POD 처리여부 'X' 인 경우만 변경정보 Export
    LOOP AT ct_xvbkd ASSIGNING FIELD-SYMBOL(<ls_xvbkd>).

*-- 삭제 대상 처리 제외
      CHECK <ls_xvbkd>-updkz NE lc_updkz-d.

*-- POD 처리여부 정보 값 구성
      IF ev_podkz IS NOT INITIAL.
        <ls_xvbkd>-podkz = ev_podkz.

*-- 변경 / 생성 정보에 값 없을경우 변경 Flag - U - 구성
        <ls_xvbkd>-updkz = COND #( WHEN <ls_xvbkd>-updkz IS INITIAL THEN lc_updkz-u
                                   ELSE <ls_xvbkd>-updkz ).
      ENDIF.
    ENDLOOP.
  ENDIF.

*-- 처리결과 정보 리턴
  es_return = VALUE #(
                      type        = 'S'
                      id          = 'ZGTSD01'
                      number      = '000'
                      message_v1  = 'POD 처리여부 정보 구성하였습니다.'(m01)
                     ).

  PERFORM message_text_build      CHANGING es_return.

ENDFUNCTION.
