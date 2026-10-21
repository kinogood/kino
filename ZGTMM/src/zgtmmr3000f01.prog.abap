*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3000F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM create_alv .

  PERFORM :
            set_container,
            set_alv_grid,
            set_alv_fieldcat,
            set_alv_layout,
            set_alv_toolbar,
            set_alv_sort,
            set_event        CHANGING gcl_event gcl_grid.

**--> 26.09 *단순견적 - 추가
  IF p_pr = gc_x OR p_pr2 = gc_x.
    PERFORM display_alv TABLES gt_list gt_fcat CHANGING gcl_grid.
  ELSE.
    PERFORM display_alv TABLES gt_create gt_fcat_cre CHANGING gcl_grid.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CONTAINER
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_container .

  IF sy-tcode = 'ZGTMMR3000'.
    IF gcl_docking IS NOT BOUND.

      CREATE OBJECT gcl_docking
        EXPORTING
          repid     = sy-repid
          dynnr     = sy-dynnr
          side      = cl_gui_docking_container=>dock_at_top
          extension = 3000.

    ENDIF.

  ELSEIF sy-tcode = 'ZGTMMR3001'.
    IF gcl_dock_400 IS NOT BOUND.

      CREATE OBJECT gcl_dock_400
        EXPORTING
          repid     = sy-repid
          dynnr     = sy-dynnr
          side      = cl_gui_docking_container=>dock_at_left
          extension = 3000.

    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_GRID
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_alv_grid .

  IF sy-tcode = 'ZGTMMR3000'.

    IF gcl_grid IS NOT BOUND.
      CREATE OBJECT gcl_grid
        EXPORTING
          i_parent          = gcl_docking
        EXCEPTIONS
          error_cntl_create = 1
          error_cntl_init   = 2
          error_cntl_link   = 3
          error_dp_create   = 4
          OTHERS            = 5.

      IF sy-subrc <> 0.
        "COULD NOT CREATE ALV GRID (SY-SUBRC = &)
        MESSAGE e725(bt) WITH sy-subrc.
      ENDIF.
    ENDIF.

  ELSEIF sy-tcode = 'ZGTMMR3001'.

    IF gcl_grid_400 IS NOT BOUND.
      CREATE OBJECT gcl_grid_400
        EXPORTING
          i_parent          = gcl_dock_400
        EXCEPTIONS
          error_cntl_create = 1
          error_cntl_init   = 2
          error_cntl_link   = 3
          error_dp_create   = 4
          OTHERS            = 5.

      IF sy-subrc <> 0.
        "COULD NOT CREATE ALV GRID (SY-SUBRC = &)
        MESSAGE e725(bt) WITH sy-subrc.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM adjust_fldcats  TABLES pt_fcat TYPE lvc_t_fcat.

  DEFINE _fcat.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA lv_col TYPE i.
  CLEAR : gt_fcat[].

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<fs_s_fct>).
    CLEAR : <fs_s_fct>-col_pos.

    CASE <fs_s_fct>-fieldname.
      WHEN 'STATUS'. "상태
        _fcat TEXT-f01.
        <fs_s_fct>-just = 'C'.

      WHEN 'EKGRP'.      "구매그룹
        _fcat TEXT-f08.
        <fs_s_fct>-just = 'C'.
      WHEN 'EKNAM'.     "구매그룹명
        _fcat TEXT-f09.
        <fs_s_fct>-just = 'C'.
      WHEN 'ERDAT'.     "최종변경일
        _fcat TEXT-f11.
        <fs_s_fct>-just = 'C'.
      WHEN 'MATNR'.        "자재코드
        _fcat TEXT-f20.
        <fs_s_fct>-hotspot = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'TXZ01'.        "자재명
        _fcat TEXT-f21.
        <fs_s_fct>-emphasize = 'C300'. "색/노랑/진하게/반전없음
        <fs_s_fct>-just = 'C'.
      WHEN 'SPECNO'. "SPEC NO.
        _fcat TEXT-fa2.
        <fs_s_fct>-just = 'C'.
      WHEN 'COLOR'.        "색상
        _fcat TEXT-f22.
        <fs_s_fct>-just = 'C'.
      WHEN 'STRIPE_COLOR'.        "색상
        _fcat TEXT-fa0.
        <fs_s_fct>-just = 'C'.
      WHEN 'STRIPE_NO'.        "색상
        _fcat TEXT-fa1.
        <fs_s_fct>-just = 'C'.
      WHEN 'LFDAT'.        "납품예정일
        _fcat TEXT-f76.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZTYPE'.     " 요청유형
        _fcat TEXT-f18.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZTYPE_N'.  "유형명
        _fcat TEXT-f19.
        <fs_s_fct>-just = 'C'.
      WHEN 'BSART'.
        _fcat '문서유형'.
        <fs_s_fct>-just = 'C'.
        <fs_s_fct>-no_out = gc_x.
      WHEN 'BANFN'.     "구매요청
        _fcat TEXT-f50.
        <fs_s_fct>-hotspot = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'BNFPO'.     "항번
        _fcat TEXT-f13.
        <fs_s_fct>-just = 'C'.
      WHEN 'PR_STATUS'.     "PR상태
        _fcat TEXT-fa3.
        <fs_s_fct>-just = 'C'.
      WHEN 'MENGE'.        "수량
        _fcat TEXT-f27.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-just = 'R'.
      WHEN 'MENGE_I'.        "수량
        _fcat TEXT-f27.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-just = 'R'.
      WHEN 'MEINS'.        "단위
        _fcat TEXT-f28.
        <fs_s_fct>-just = 'C'.
      WHEN 'LENGTH'.        "조장
        _fcat TEXT-f23.
        <fs_s_fct>-just = 'R'.
      WHEN 'DRQTY'.        "드럼수
        _fcat TEXT-f38.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-just = 'R'.
      WHEN 'DRUMNAME'.        "드럼명
        _fcat TEXT-t09        .
        <fs_s_fct>-just = 'R'.
      WHEN 'INSMK'.        "재고유형
        _fcat TEXT-f37.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'INSMK'.
        <fs_s_fct>-just = 'C'.
      WHEN 'INSMK_N'.        "유형명
        _fcat TEXT-f19.
        <fs_s_fct>-just = 'C'.

      WHEN 'SOM'.        "구분
        _fcat TEXT-t05..
        <fs_s_fct>-just = 'C'.

      WHEN 'FGSTOCK'.        "SM재고량
        _fcat TEXT-t06.
        <fs_s_fct>-qfieldname = 'FGMEINS'.
        <fs_s_fct>-emphasize = 'C300'. "색/노랑/진하게/반전없음
        <fs_s_fct>-just = 'R'.

      WHEN 'FGMEINS'.        "단위
        _fcat TEXT-t07.
        <fs_s_fct>-just = 'C'.

      WHEN 'FGDRQTY'.        "드럼수
        _fcat TEXT-t08.
        <fs_s_fct>-just = 'R'.

      WHEN 'SLQTY'.        "입고창고재고수량
        _fcat TEXT-f39.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-emphasize = 'C300'. "색/노랑/진하게/반전없음
        <fs_s_fct>-just = 'R'.
      WHEN 'MATKL'.   "자재그룹
        _fcat TEXT-f15.
        <fs_s_fct>-just = 'C'.
      WHEN 'MATKL_N'.   "자재그룹명
        _fcat TEXT-f15.
        <fs_s_fct>-just = 'C'.
      WHEN 'BUKRS'.   "회사코드
        _fcat TEXT-f30.
        <fs_s_fct>-just = 'C'.
      WHEN 'KOKRS'.   "관리회계영역
        _fcat TEXT-f83.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'KTOPL'.   "계정과목표
        _fcat TEXT-f84.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'EKORG'.       "구매조직
        _fcat TEXT-f10.
        <fs_s_fct>-just = 'C'.
      WHEN 'EKORG_N'.  "구매조직명
        _fcat TEXT-f75.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'WERKS'.       "플랜트
        _fcat TEXT-f02.
        <fs_s_fct>-just = 'C'.
      WHEN 'WERKS_N'.  "플랜트명
        _fcat TEXT-f03.
        <fs_s_fct>-just = 'C'.
      WHEN 'LGORT'.        "저장위치
        _fcat TEXT-f25.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'T001L'.
        <fs_s_fct>-ref_field  = 'LGORT'.
        <fs_s_fct>-just = 'C'.
      WHEN 'LGORT_N'.    "저장위치명
        _fcat TEXT-f26.
        <fs_s_fct>-just = 'C'.
      WHEN 'EMLIF'.     "임가공직납업체
        _fcat TEXT-f29.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'LFA1'.
        <fs_s_fct>-ref_field  = 'LIFNR'.
        <fs_s_fct>-just = 'C'.
      WHEN 'SCVNAME'.    "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-just = 'C'.
      WHEN 'LBLKZ'.     "임가공지시자
        _fcat TEXT-f33.
        <fs_s_fct>-just = 'C'.
      WHEN 'ABLAD'.     "하적지점
        _fcat TEXT-f35.
        <fs_s_fct>-just = 'C'.
      WHEN 'AFNAM'.     "요청자
        _fcat TEXT-f51.
        <fs_s_fct>-just = 'C'.
      WHEN 'FLIEF'.     "고정공급업체
        _fcat TEXT-f41.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'LFA1'.
        <fs_s_fct>-ref_field  = 'LIFNR'.
        <fs_s_fct>-just = 'C'.
      WHEN 'FLIEF_N'.    "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-just = 'C'.
      WHEN 'BPLIST'. "계약업체
        _fcat '계약업체'.
      WHEN 'LIFNR'.   "공급업체
        _fcat TEXT-f16.
        <fs_s_fct>-just = 'C'.
      WHEN 'NAME1'.   "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-just = 'C'.
      WHEN 'PREIS_P'.        "PR단가
        _fcat 'PR단가'.
        <fs_s_fct>-cfieldname = 'WAERS_P'.
        <fs_s_fct>-just = 'R'.
      WHEN 'WAERS_P'.        "PR통화
        _fcat 'PR통화'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PEINH_P'.        "PR PER
        _fcat 'PR PER'.
        <fs_s_fct>-just = 'C'.
      WHEN 'MWSKZ_P'.        "PR TAX
        _fcat 'PR TAX'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PREIS_I'.        "INFO단가
        _fcat 'INFO단가'.
        <fs_s_fct>-cfieldname = 'WAERS_I'.
        <fs_s_fct>-just = 'R'.
      WHEN 'WAERS_I'.        "INFO통화
        _fcat 'INFO통화'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PEINH_I'.        "INFO PER
        _fcat 'INFO PER'.
        <fs_s_fct>-just = 'C'.
      WHEN 'MWSKZ_I'.        "INFO TAX
        _fcat 'INFO TAX'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PREIS'.        "단가
        _fcat TEXT-f31.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-just = 'R'.
      WHEN 'WAERS'.        "통화
        _fcat TEXT-f34.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'TCURC'.
        <fs_s_fct>-ref_field  = 'WAERS'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PEINH'.        "PER
        _fcat TEXT-f32.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'IDNLF'.        "공급업체자재번호
        _fcat TEXT-f24.
        <fs_s_fct>-just = 'C'.
      WHEN 'GSWRT'.        "총액
        _fcat TEXT-f81.
*        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <fs_s_fct>-just = 'C'.
      WHEN 'SOTAX'.        "판매부가세
        _fcat TEXT-f82.
*        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <fs_s_fct>-just = 'C'.
      WHEN 'MWSKZ'.        "TAX
        _fcat TEXT-f36.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'MWSKZ'.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZMEMO_H'.     "비고(헤더)
        _fcat TEXT-f42.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZMEMO_I'.     "비고(품목)
        _fcat TEXT-f43.
        <fs_s_fct>-just = 'C'.
      WHEN 'MCONTENTS'.     "시스마킹사항
        _fcat TEXT-f99.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZMEMO_S'.     "특기사항
        _fcat TEXT-f98.
        <fs_s_fct>-just = 'C'.

      WHEN 'EBAKZ'.        "종료
        _fcat TEXT-f44.
        <fs_s_fct>-just = 'C'.
      WHEN 'MTART'.        "자재유형
        _fcat TEXT-f87.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.

      WHEN 'IRONDRUM'.        "자재유형
        _fcat TEXT-f90.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'DRUMTITLEMARK'.        "자재유형
        _fcat TEXT-f91.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'FLANGE_PROT'.        "자재유형
        _fcat TEXT-f92.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'HANJEON'.        "자재유형
        _fcat TEXT-f93.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'PACK_GUBUN'.        "자재유형
        _fcat TEXT-f94.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'PACK_TEXT'.        "자재유형
        _fcat TEXT-f95.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'SKID_YN'.        "자재유형
        _fcat TEXT-f96.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'PKWOOD'.        "자재유형
        _fcat TEXT-f97.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'LOEKZ'.        "삭제
        _fcat TEXT-f14.
        <fs_s_fct>-just = 'C'.
      WHEN 'KNTTP'.     "AAC
        _fcat 'AAC'.
        <fs_s_fct>-just = 'C'.
      WHEN 'KNTTX'.     "AAC명
        _fcat 'AAC명'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PSTYP'.     "IC
        _fcat 'IC'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PSTYP_N'.     "IC명
        _fcat 'IC명'.
        <fs_s_fct>-just = 'C'.
      WHEN 'ESTKZ'.   "
        _fcat '생성지시자'.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.

      WHEN 'REL'.        "승인여부
        _fcat TEXT-f85.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'SAKTO'.        "G/L계정
        _fcat TEXT-f46.
        <fs_s_fct>-just = 'C'.
      WHEN 'SAKTO_N'.        "계정명
        _fcat TEXT-f54.
        <fs_s_fct>-just = 'C'.
      WHEN 'KOSTL'.        "코스트센터
        _fcat TEXT-f55.
        <fs_s_fct>-just = 'C'.
      WHEN 'KOSTL_N'.        "코스트센터명
        _fcat TEXT-f56.
        <fs_s_fct>-just = 'C'.
      WHEN 'VBELN'.     "판매오더
        _fcat TEXT-f58.
        <fs_s_fct>-hotspot = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'POSNR'.     "항번
        _fcat TEXT-f13.
        <fs_s_fct>-just = 'C'.
      WHEN 'KUNNR'.     "고객
        _fcat TEXT-f57.
        <fs_s_fct>-just = 'C'.
      WHEN 'KUNNR_N'.     "고객명
        _fcat TEXT-f61.
        <fs_s_fct>-just = 'C'.
      WHEN 'VKBUR'.    "영업팀
        _fcat TEXT-f45.
        <fs_s_fct>-just = 'C'.
      WHEN 'VKBUR_N'.    "영업팀명
        _fcat TEXT-f59.
        <fs_s_fct>-just = 'C'.
      WHEN 'VKGRP'.     "영업그룹
        _fcat TEXT-f62.
        <fs_s_fct>-just = 'C'.
      WHEN 'VKGRP_N'.     "영업그룹명
        _fcat TEXT-f60.
        <fs_s_fct>-just = 'C'.
      WHEN 'TEAMCODE'.     "팀코드
        <fs_s_fct>-no_out = gc_x.
        _fcat TEXT-f89.
        <fs_s_fct>-just = 'C'.
      WHEN 'INSPECTION'.     "입회검사여부
        _fcat TEXT-f88.
        <fs_s_fct>-just = 'C'.

      WHEN 'ANLN1'.     "고정자산번호
        _fcat TEXT-f63.
        <fs_s_fct>-just = 'C'.
      WHEN 'ANLN2'.     "고정자산번호(SUB)
        _fcat TEXT-f64.
        <fs_s_fct>-just = 'C'.
      WHEN 'ANLN1_N'.     "고정자산명
        _fcat TEXT-f65.
        <fs_s_fct>-just = 'C'.
      WHEN 'PS_PSP_PNR'.     "WBS
        _fcat TEXT-f66.
        <fs_s_fct>-just = 'C'.
      WHEN 'PS_PSP_PNR_N'.     "WBS명
        _fcat TEXT-f67.
        <fs_s_fct>-just = 'C'.
      WHEN 'AUFNR'.     "오더번호
        _fcat TEXT-f70.
        <fs_s_fct>-just = 'C'.
      WHEN 'CONQTY'.     "계약건수
        _fcat TEXT-f71.
        <fs_s_fct>-just = 'C'.
      WHEN 'BANFN_N'.     "소요량PR
        _fcat TEXT-f72.
        <fs_s_fct>-hotspot = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'BANFN_ICON'.     "소요량 PR 진행여부
        _fcat TEXT-f73.
        <fs_s_fct>-just = 'C'.
      WHEN 'FLAG'.     "견적진행여부
        _fcat TEXT-f47.
        <fs_s_fct>-just = 'C'.
      WHEN 'POPROCESS'.     "PO진행여부
        _fcat TEXT-f48.
        <fs_s_fct>-just = 'C'.
      WHEN 'EBELN'.     "PO번호
        _fcat TEXT-f12.
        <fs_s_fct>-hotspot = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'EBELP'.     "항번
        _fcat TEXT-f13.
        <fs_s_fct>-just = 'C'.
      WHEN 'PORELSTATUS'.   "PO 승인여부
        _fcat TEXT-f49.
        <fs_s_fct>-just = 'C'.
      WHEN 'TYPE'.     "결과
        _fcat TEXT-f68.
        <fs_s_fct>-just = 'C'.
      WHEN 'MESSAGE'.   "메시지
        _fcat TEXT-f68.
        <fs_s_fct>-just = 'C'.
      WHEN 'DPCBT'.   "단일배치기본값
        _fcat TEXT-t10.
        <fs_s_fct>-just = 'C'.

**-- 26.10 특성값 추가
      WHEN 'INSQTY_W'.
        _fcat TEXT-fa4.
        <fs_s_fct>-just = 'C'.
      WHEN 'INSQTY_S'.
        _fcat TEXT-fa5.
        <fs_s_fct>-just = 'C'.

      WHEN OTHERS.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.



    ENDCASE.

    APPEND <fs_s_fct> TO gt_fcat.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_CRE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM adjust_fldcats_cre  TABLES pt_fcat TYPE lvc_t_fcat.

  DEFINE _fcat.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA lv_col TYPE i.
  CLEAR : gt_fcat_cre[].

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<fs_s_fct>).
    CLEAR : <fs_s_fct>-col_pos.

    CASE <fs_s_fct>-fieldname.
      WHEN 'STATUS'. "상태
        _fcat TEXT-f01.
        <fs_s_fct>-just = 'C'.

      WHEN 'EBELN'.     "PO번호
        _fcat TEXT-f12.
        <fs_s_fct>-hotspot = gc_x.
        <fs_s_fct>-just = 'C'.

      WHEN 'EBELP'.    "항번
        _fcat TEXT-f13.
        <fs_s_fct>-just = 'C'.

      WHEN 'LIFNR'.   "공급업체
        _fcat TEXT-f16.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'LFA1'.
        <fs_s_fct>-ref_field  = 'LIFNR'.
        <fs_s_fct>-just = 'C'.

      WHEN 'LIFNR_N'.   "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-just = 'C'.

      WHEN 'BUKRS'.     "회사코드
        _fcat TEXT-f30.
        <fs_s_fct>-just = 'C'.

      WHEN 'BUTXT'.     "회사명
        _fcat TEXT-f74.
        <fs_s_fct>-just = 'C'.

      WHEN 'EKORG'.       "구매조직
        _fcat TEXT-f10.
        <fs_s_fct>-just = 'C'.

      WHEN 'EKOTX'.  "구매조직명
        _fcat TEXT-f75.
        <fs_s_fct>-just = 'C'.

      WHEN 'EKGRP'.      "구매그룹
        _fcat TEXT-f08.
        <fs_s_fct>-just = 'C'.

      WHEN 'EKNAM'.     "구매그룹명
        _fcat TEXT-f09.
        <fs_s_fct>-just = 'C'.

      WHEN 'MATNR'.        "자재코드
        _fcat TEXT-f20.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'MARA'.
        <fs_s_fct>-ref_field  = 'MATNR'.
        <fs_s_fct>-just = 'C'.

      WHEN 'ZZMAKTX80'.        "자재명
        _fcat TEXT-f21.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.

      WHEN 'SPECNO'. "SPEC NO.
        _fcat TEXT-fa2.
        <fs_s_fct>-just = 'C'.

      WHEN 'COLOR'.  "색상
        _fcat TEXT-f22.
        <fs_s_fct>-just = 'C'.

      WHEN 'STRIPE_COLOR'.     " 띠줄색상
        _fcat TEXT-fa0.
        <fs_s_fct>-just = 'C'.

      WHEN 'STRIPE_NO'.     " 띠줄수
        _fcat TEXT-fa1.
        <fs_s_fct>-just = 'C'.

      WHEN 'WERKS'.     " 플랜트
        _fcat TEXT-f02.
        <fs_s_fct>-just = 'C'.

      WHEN 'WERKS_N'.  "플랜트명
        _fcat TEXT-f03.
        <fs_s_fct>-just = 'C'.

      WHEN 'LGORT'.        "저장위치
        _fcat TEXT-f25.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'T001L'.
        <fs_s_fct>-ref_field  = 'LGORT'.
        <fs_s_fct>-just = 'C'.

      WHEN 'LGOBE'.        "저장위치명
        _fcat TEXT-f26.
        <fs_s_fct>-just = 'C'.

      WHEN 'EMLIF'.     "임가공직납업체
        _fcat TEXT-f29.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'EMLIF'.
        <fs_s_fct>-just = 'C'.

      WHEN 'EMLIF_N'.    "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-just = 'C'.

      WHEN 'MENGE'.        "수량
        _fcat TEXT-f27.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-just = 'R'.

      WHEN 'MEINS'.        "단위
        _fcat TEXT-f28.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'MARA'.
        <fs_s_fct>-ref_field  = 'MEINS'.
        <fs_s_fct>-just = 'C'.

      WHEN 'LENGTH'.        "조장
        _fcat TEXT-f23.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'R'.

      WHEN 'DRQTY'.        "드럼수
        _fcat TEXT-f38.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-just = 'R'.

      WHEN 'NETPR'.        "단가
        _fcat TEXT-f31.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'R'.

      WHEN 'PEINH'.        "PER
        _fcat TEXT-f32.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.

      WHEN 'WAERS'.        "통화
        _fcat TEXT-f34.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'T001'.
        <fs_s_fct>-ref_field  = 'WAERS'.
        <fs_s_fct>-just = 'C'.
      WHEN 'MWSKZ'.        "TAX
        _fcat TEXT-f36.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'T007A'.
        <fs_s_fct>-ref_field  = 'MWSKZ'.
        <fs_s_fct>-just = 'C'.
      WHEN 'NETPR_I'.        "INFO단가
        _fcat 'INFO단가'.
        <fs_s_fct>-cfieldname = 'WAERS_I'.
        <fs_s_fct>-just = 'R'.
      WHEN 'PEINH_I'.        "INFO PER
        _fcat 'INFO PER'.
        <fs_s_fct>-just = 'C'.
      WHEN 'WAERS_I'.        "INFO통화
        _fcat 'INFO통화'.
        <fs_s_fct>-just = 'C'.
      WHEN 'MWSKZ_I'.        "INFO TAX
        _fcat 'INFO TAX'.
        <fs_s_fct>-just = 'C'.
      WHEN 'IDNLF'.        "공급업체자재번호
        _fcat TEXT-f24.
        <fs_s_fct>-just = 'C'.
      WHEN 'EINDT'.        "납품예정일
        _fcat TEXT-f76.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKET'.
        <fs_s_fct>-ref_field  = 'EINDT'.
        <fs_s_fct>-just = 'C'.
      WHEN 'INSMK'.        "재고유형
        _fcat TEXT-f37.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'INSMK'.
        <fs_s_fct>-just = 'C'.
      WHEN 'INSMK_N'.        "유형명
        _fcat TEXT-f19.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZMEMO'.     "비고(품목)
        _fcat TEXT-f43.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'UEBTO'.        "초과납품한도
        _fcat TEXT-f77.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'RETPO'.     "반품
        _fcat TEXT-f78.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'RETPO'.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZFREE'.       "무상
        _fcat TEXT-f79.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-checkbox = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'KNTTP'.     "AAC
        _fcat TEXT-f04.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'KNTTP'.
        <fs_s_fct>-just = 'C'.
      WHEN 'ABLAD'.     "AAC
        _fcat TEXT-f86.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.

      WHEN 'MTART'.   "자재유형
        _fcat TEXT-f87.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'MATKL'.   "자재그룹
        _fcat TEXT-f15.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'MARA'.
        <fs_s_fct>-ref_field  = 'MATKL'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PSTYP'.     "IC
        _fcat TEXT-f05.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'PSTYP'.
        <fs_s_fct>-just = 'C'.
      WHEN 'VBELN'.     "판매오더
        _fcat TEXT-f58.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'VBAK'.
        <fs_s_fct>-ref_field  = 'VBELN'.
        <fs_s_fct>-just = 'C'.
      WHEN 'VBELP'.     "항번
        _fcat TEXT-f13.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'MCONTENTS'.     "시스마킹내용
        _fcat TEXT-f99.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZMEMO_S'.     "특기사항
        _fcat TEXT-f98.
        <fs_s_fct>-just = 'C'.
      WHEN 'KOSTL'.        "코스트센터
        _fcat TEXT-f55.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'CSKS'.
        <fs_s_fct>-ref_field  = 'KOSTL'.
        <fs_s_fct>-just = 'C'.
      WHEN 'SAKTO'.        "G/L계정
        _fcat TEXT-f46.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'SKB1'.
        <fs_s_fct>-ref_field  = 'SAKNR'.
        <fs_s_fct>-just = 'C'.
      WHEN 'ANLN1'.     "고정자산번호
        _fcat TEXT-f63.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'ANLA'.
        <fs_s_fct>-ref_field  = 'ANLN1'.
        <fs_s_fct>-just = 'C'.
      WHEN 'ANLN2'.     "고정자산번호(SUB)
        _fcat TEXT-f64.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'ANLA'.
        <fs_s_fct>-ref_field  = 'ANLN2'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PS_PSP_PNR'.     "WBS
        _fcat TEXT-f66.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'PRPS'.
        <fs_s_fct>-ref_field  = 'PSPNR'.
        <fs_s_fct>-just = 'C'.
      WHEN 'AUFNR'.     "오더번호
        _fcat TEXT-f70.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'AUFK'.
        <fs_s_fct>-ref_field  = 'AUFNR'.
        <fs_s_fct>-just = 'C'.
      WHEN 'INFNR'.     "INFORECORD
        _fcat TEXT-f80.
        <fs_s_fct>-just = 'C'.
      WHEN 'MESSAGE'.   "메시지
        _fcat TEXT-f69.
        <fs_s_fct>-just = 'C'.

**-- 26.10 특성값 추가
      WHEN 'INSQTY_W'.
        _fcat TEXT-fa4.
        <fs_s_fct>-just = 'C'.
      WHEN 'INSQTY_S'.
        _fcat TEXT-fa5.
        <fs_s_fct>-just = 'C'.

      WHEN OTHERS.
        <fs_s_fct>-no_out = gc_x.

    ENDCASE.

    APPEND <fs_s_fct> TO gt_fcat_cre.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_400
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM adjust_fldcats_400  TABLES pt_fcat TYPE lvc_t_fcat.

  DEFINE _fcat.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA lv_col TYPE i.
  CLEAR : gt_fcat_400[].

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<fs_s_fct>).
    CLEAR : <fs_s_fct>-col_pos.

    CASE <fs_s_fct>-fieldname.
      WHEN 'STATUS'. "상태
        _fcat TEXT-f01.
        <fs_s_fct>-just = 'C'.

      WHEN 'EKGRP'.      "구매그룹
        _fcat TEXT-f08.
        <fs_s_fct>-just = 'C'.
      WHEN 'EKNAM'.     "구매그룹명
        _fcat TEXT-f09.
        <fs_s_fct>-just = 'C'.
      WHEN 'ERDAT'.     "최종변경일
        _fcat TEXT-f11.
        <fs_s_fct>-just = 'C'.
      WHEN 'MATNR'.        "자재코드
        _fcat TEXT-f20.
        <fs_s_fct>-hotspot = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'TXZ01'.        "자재명
        _fcat TEXT-f21.
        <fs_s_fct>-emphasize = 'C300'. "색/노랑/진하게/반전없음
        <fs_s_fct>-just = 'C'.
      WHEN 'SPECNO'. "SPEC NO.
        _fcat TEXT-fa2.
        <fs_s_fct>-just = 'C'.
      WHEN 'COLOR'.        "색상
        _fcat TEXT-f22.
        <fs_s_fct>-just = 'C'.
      WHEN 'STRIPE_COLOR'.        "색상
        _fcat TEXT-fa0.
        <fs_s_fct>-just = 'C'.
      WHEN 'STRIPE_NO'.        "색상
        _fcat TEXT-fa1.
        <fs_s_fct>-just = 'C'.
      WHEN 'DRUMNAME'.        "드럼명
        _fcat TEXT-t09        .
        <fs_s_fct>-just = 'R'.
      WHEN 'LFDAT'.        "납품예정일
        _fcat TEXT-f76.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZTYPE'.     " 요청유형
        _fcat TEXT-f18.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZTYPE_N'.  "유형명
        _fcat TEXT-f19.
        <fs_s_fct>-just = 'C'.
      WHEN 'BSART'.
        _fcat '문서유형'.
        <fs_s_fct>-just = 'C'.
        <fs_s_fct>-no_out = gc_x.
      WHEN 'BANFN'.     "구매요청
        _fcat TEXT-f50.
        <fs_s_fct>-hotspot = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'BNFPO'.     "항번
        _fcat TEXT-f13.
        <fs_s_fct>-just = 'C'.
      WHEN 'PR_STATUS'.     "PR상태
        _fcat TEXT-fa3.
        <fs_s_fct>-just = 'C'.
      WHEN 'MENGE'.        "수량
        _fcat TEXT-f27.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-just = 'R'.
      WHEN 'MENGE_I'.        "수량
        _fcat TEXT-f27.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-just = 'R'.
      WHEN 'MEINS'.        "단위
        _fcat TEXT-f28.
        <fs_s_fct>-just = 'C'.
      WHEN 'LENGTH'.        "조장
        _fcat TEXT-f23.
        <fs_s_fct>-just = 'R'.
      WHEN 'DRQTY'.        "드럼수
        _fcat TEXT-f38.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-just = 'R'.

      WHEN 'INSMK'.        "재고유형
        _fcat TEXT-f37.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'INSMK'.
        <fs_s_fct>-just = 'C'.
      WHEN 'SOM'.        "구분
        _fcat TEXT-t05..
        <fs_s_fct>-just = 'C'.

      WHEN 'FGSTOCK'.        "SM재고량
        _fcat TEXT-t06.
        <fs_s_fct>-qfieldname = 'FGMEINS'.
        <fs_s_fct>-emphasize = 'C300'. "색/노랑/진하게/반전없음
        <fs_s_fct>-just = 'R'.

      WHEN 'FGMEINS'.        "단위
        _fcat TEXT-t07.
        <fs_s_fct>-just = 'C'.

      WHEN 'FGDRQTY'.        "드럼수
        _fcat TEXT-t08.
        <fs_s_fct>-just = 'R'.
      WHEN 'INSMK_N'.        "유형명
        _fcat TEXT-f19.
        <fs_s_fct>-just = 'C'.
      WHEN 'SLQTY'.        "입고창고재고수량
        _fcat TEXT-f39.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-emphasize = 'C300'. "색/노랑/진하게/반전없음
        <fs_s_fct>-just = 'R'.
      WHEN 'MATKL'.   "자재그룹
        _fcat TEXT-f15.
        <fs_s_fct>-just = 'C'.
      WHEN 'MATKL_N'.   "자재그룹명
        _fcat TEXT-f15.
        <fs_s_fct>-just = 'C'.
      WHEN 'BUKRS'.   "회사코드
        _fcat TEXT-f30.
        <fs_s_fct>-just = 'C'.
      WHEN 'KOKRS'.   "관리회계영역
        _fcat TEXT-f83.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'KTOPL'.   "계정과목표
        _fcat TEXT-f84.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'EKORG'.       "구매조직
        _fcat TEXT-f10.
        <fs_s_fct>-just = 'C'.
      WHEN 'EKORG_N'.  "구매조직명
        _fcat TEXT-f75.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'WERKS'.       "플랜트
        _fcat TEXT-f02.
        <fs_s_fct>-just = 'C'.
      WHEN 'WERKS_N'.  "플랜트명
        _fcat TEXT-f03.
        <fs_s_fct>-just = 'C'.
      WHEN 'LGORT'.        "저장위치
        _fcat TEXT-f25.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'T001L'.
        <fs_s_fct>-ref_field  = 'LGORT'.
        <fs_s_fct>-just = 'C'.
      WHEN 'LGORT_N'.    "저장위치명
        _fcat TEXT-f26.
        <fs_s_fct>-just = 'C'.
      WHEN 'EMLIF'.     "임가공직납업체
        _fcat TEXT-f29.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'LFA1'.
        <fs_s_fct>-ref_field  = 'LIFNR'.
        <fs_s_fct>-just = 'C'.
      WHEN 'SCVNAME'.    "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-just = 'C'.
      WHEN 'LBLKZ'.     "임가공지시자
        _fcat TEXT-f33.
        <fs_s_fct>-just = 'C'.
      WHEN 'ABLAD'.     "하적지점
        _fcat TEXT-f35.
        <fs_s_fct>-just = 'C'.
      WHEN 'AFNAM'.     "요청자
        _fcat TEXT-f51.
        <fs_s_fct>-just = 'C'.
      WHEN 'FLIEF'.     "고정공급업체
        _fcat TEXT-f41.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'LFA1'.
        <fs_s_fct>-ref_field  = 'LIFNR'.
        <fs_s_fct>-just = 'C'.
      WHEN 'FLIEF_N'.    "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-just = 'C'.
      WHEN 'BPLIST'. "계약업체
        _fcat '계약업체'.
      WHEN 'LIFNR'.   "공급업체
        _fcat TEXT-f16.
        <fs_s_fct>-just = 'C'.
      WHEN 'NAME1'.   "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-just = 'C'.
      WHEN 'PREIS_P'.        "PR단가
        _fcat 'PR단가'.
        <fs_s_fct>-cfieldname = 'WAERS_P'.
        <fs_s_fct>-just = 'R'.
      WHEN 'WAERS_P'.        "PR통화
        _fcat 'PR통화'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PEINH_P'.        "PR PER
        _fcat 'PR PER'.
        <fs_s_fct>-just = 'C'.
      WHEN 'MWSKZ_P'.        "PR TAX
        _fcat 'PR TAX'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PREIS_I'.        "INFO단가
        _fcat 'INFO단가'.
        <fs_s_fct>-cfieldname = 'WAERS_I'.
        <fs_s_fct>-just = 'R'.
      WHEN 'WAERS_I'.        "INFO통화
        _fcat 'INFO통화'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PEINH_I'.        "INFO PER
        _fcat 'INFO PER'.
        <fs_s_fct>-just = 'C'.
      WHEN 'MWSKZ_I'.        "INFO TAX
        _fcat 'INFO TAX'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PREIS'.        "단가
        _fcat TEXT-f31.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-just = 'R'.
      WHEN 'WAERS'.        "통화
        _fcat TEXT-f34.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'TCURC'.
        <fs_s_fct>-ref_field  = 'WAERS'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PEINH'.        "PER
        _fcat TEXT-f32.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'IDNLF'.        "공급업체자재번호
        _fcat TEXT-f24.
        <fs_s_fct>-just = 'C'.
      WHEN 'GSWRT'.        "총액
        _fcat TEXT-f81.
*        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <fs_s_fct>-just = 'C'.
      WHEN 'SOTAX'.        "판매부가세
        _fcat TEXT-f82.
*        <FS_S_FCT>-CFIELDNAME = 'WAERS'.
        <fs_s_fct>-just = 'C'.
      WHEN 'MWSKZ'.        "TAX
        _fcat TEXT-f36.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'MWSKZ'.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZMEMO_H'.     "비고(헤더)
        _fcat TEXT-f42.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZMEMO_I'.     "비고(품목)
        _fcat TEXT-f43.
        <fs_s_fct>-just = 'C'.
      WHEN 'MCONTENTS'.     "시스마킹사항
        _fcat TEXT-f99.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZMEMO_S'.     "특기사항
        _fcat TEXT-f98.
        <fs_s_fct>-just = 'C'.

      WHEN 'EBAKZ'.        "종료
        _fcat TEXT-f44.
        <fs_s_fct>-just = 'C'.
      WHEN 'MTART'.        "자재유형
        _fcat TEXT-f87.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.

      WHEN 'IRONDRUM'.        "자재유형
        _fcat TEXT-f90.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'DRUMTITLEMARK'.        "자재유형
        _fcat TEXT-f91.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'FLANGE_PROT'.        "자재유형
        _fcat TEXT-f92.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'HANJEON'.        "자재유형
        _fcat TEXT-f93.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'PACK_GUBUN'.        "자재유형
        _fcat TEXT-f94.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'PACK_TEXT'.        "자재유형
        _fcat TEXT-f95.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'SKID_YN'.        "자재유형
        _fcat TEXT-f96.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'PKWOOD'.        "자재유형
        _fcat TEXT-f97.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'LOEKZ'.        "삭제
        _fcat TEXT-f14.
        <fs_s_fct>-just = 'C'.
      WHEN 'KNTTP'.     "AAC
        _fcat 'AAC'.
        <fs_s_fct>-just = 'C'.
      WHEN 'KNTTX'.     "AAC명
        _fcat 'AAC명'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PSTYP'.     "IC
        _fcat 'IC'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PSTYP_N'.     "IC명
        _fcat 'IC명'.
        <fs_s_fct>-just = 'C'.
      WHEN 'ESTKZ'.   "
        _fcat '생성지시자'.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.

      WHEN 'REL'.        "승인여부
        _fcat TEXT-f85.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'SAKTO'.        "G/L계정
        _fcat TEXT-f46.
        <fs_s_fct>-just = 'C'.
      WHEN 'SAKTO_N'.        "계정명
        _fcat TEXT-f54.
        <fs_s_fct>-just = 'C'.
      WHEN 'KOSTL'.        "코스트센터
        _fcat TEXT-f55.
        <fs_s_fct>-just = 'C'.
      WHEN 'KOSTL_N'.        "코스트센터명
        _fcat TEXT-f56.
        <fs_s_fct>-just = 'C'.
      WHEN 'VBELN'.     "판매오더
        _fcat TEXT-f58.
        <fs_s_fct>-hotspot = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'POSNR'.     "항번
        _fcat TEXT-f13.
        <fs_s_fct>-just = 'C'.
      WHEN 'KUNNR'.     "고객
        _fcat TEXT-f57.
        <fs_s_fct>-just = 'C'.
      WHEN 'KUNNR_N'.     "고객명
        _fcat TEXT-f61.
        <fs_s_fct>-just = 'C'.
      WHEN 'VKBUR'.    "영업팀
        _fcat TEXT-f45.
        <fs_s_fct>-just = 'C'.
      WHEN 'VKBUR_N'.    "영업팀명
        _fcat TEXT-f59.
        <fs_s_fct>-just = 'C'.
      WHEN 'VKGRP'.     "영업그룹
        _fcat TEXT-f62.
        <fs_s_fct>-just = 'C'.
      WHEN 'VKGRP_N'.     "영업그룹명
        _fcat TEXT-f60.
        <fs_s_fct>-just = 'C'.
      WHEN 'TEAMCODE'.     "팀코드
        <fs_s_fct>-no_out = gc_x.
        _fcat TEXT-f89.
        <fs_s_fct>-just = 'C'.
      WHEN 'INSPECTION'.     "입회검사여부
        _fcat TEXT-f88.
        <fs_s_fct>-just = 'C'.

      WHEN 'ANLN1'.     "고정자산번호
        _fcat TEXT-f63.
        <fs_s_fct>-just = 'C'.
      WHEN 'ANLN2'.     "고정자산번호(SUB)
        _fcat TEXT-f64.
        <fs_s_fct>-just = 'C'.
      WHEN 'ANLN1_N'.     "고정자산명
        _fcat TEXT-f65.
        <fs_s_fct>-just = 'C'.
      WHEN 'PS_PSP_PNR'.     "WBS
        _fcat TEXT-f66.
        <fs_s_fct>-just = 'C'.
      WHEN 'PS_PSP_PNR_N'.     "WBS명
        _fcat TEXT-f67.
        <fs_s_fct>-just = 'C'.
      WHEN 'AUFNR'.     "오더번호
        _fcat TEXT-f70.
        <fs_s_fct>-just = 'C'.
      WHEN 'CONQTY'.     "계약건수
        _fcat TEXT-f71.
        <fs_s_fct>-just = 'C'.
      WHEN 'BANFN_N'.     "소요량PR
        _fcat TEXT-f72.
        <fs_s_fct>-hotspot = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'BANFN_ICON'.     "소요량 PR 진행여부
        _fcat TEXT-f73.
        <fs_s_fct>-just = 'C'.
      WHEN 'FLAG'.     "견적진행여부
        _fcat TEXT-f47.
        <fs_s_fct>-just = 'C'.
      WHEN 'POPROCESS'.     "PO진행여부
        _fcat TEXT-f48.
        <fs_s_fct>-just = 'C'.
      WHEN 'EBELN'.     "PO번호
        _fcat TEXT-f12.
        <fs_s_fct>-hotspot = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'EBELP'.     "항번
        _fcat TEXT-f13.
        <fs_s_fct>-just = 'C'.
      WHEN 'PORELSTATUS'.   "PO 승인여부
        _fcat TEXT-f49.
        <fs_s_fct>-just = 'C'.
      WHEN 'TYPE'.     "결과
        _fcat TEXT-f68.
        <fs_s_fct>-just = 'C'.
      WHEN 'MESSAGE'.   "메시지
        _fcat TEXT-f68.
        <fs_s_fct>-just = 'C'.

**-- 26.10 특성값 추가
      WHEN 'INSQTY_W'.
        _fcat TEXT-fa4.
        <fs_s_fct>-just = 'C'.
      WHEN 'INSQTY_S'.
        _fcat TEXT-fa5.
        <fs_s_fct>-just = 'C'.

      WHEN OTHERS.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
    ENDCASE.

    APPEND <fs_s_fct> TO gt_fcat_400.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_CRE_400
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM adjust_fldcats_cre_400 TABLES pt_fcat TYPE lvc_t_fcat.

  DEFINE _fcat.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA lv_col TYPE i.
  CLEAR : gt_fcat_cre_400[].

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<fs_s_fct>).
    CLEAR : <fs_s_fct>-col_pos.

    CASE <fs_s_fct>-fieldname.
      WHEN 'STATUS'. "상태
        _fcat TEXT-f01.
        <fs_s_fct>-just = 'C'.

      WHEN 'EBELN'.     "PO번호
        _fcat TEXT-f12.
        <fs_s_fct>-hotspot = gc_x.
        <fs_s_fct>-just = 'C'.

      WHEN 'EBELP'.    "항번
        _fcat TEXT-f13.
        <fs_s_fct>-just = 'C'.

      WHEN 'LIFNR'.   "공급업체
        _fcat TEXT-f16.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'LFA1'.
        <fs_s_fct>-ref_field  = 'LIFNR'.
        <fs_s_fct>-just = 'C'.

      WHEN 'LIFNR_N'.   "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-just = 'C'.

      WHEN 'BUKRS'.     "회사코드
        _fcat TEXT-f30.
        <fs_s_fct>-just = 'C'.

      WHEN 'BUTXT'.     "회사명
        _fcat TEXT-f74.
        <fs_s_fct>-just = 'C'.

      WHEN 'EKORG'.       "구매조직
        _fcat TEXT-f10.
        <fs_s_fct>-just = 'C'.

      WHEN 'EKOTX'.  "구매조직명
        _fcat TEXT-f75.
        <fs_s_fct>-just = 'C'.

      WHEN 'EKGRP'.      "구매그룹
        _fcat TEXT-f08.
        <fs_s_fct>-just = 'C'.

      WHEN 'EKNAM'.     "구매그룹명
        _fcat TEXT-f09.
        <fs_s_fct>-just = 'C'.

      WHEN 'MATNR'.        "자재코드
        _fcat TEXT-f20.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'MARA'.
        <fs_s_fct>-ref_field  = 'MATNR'.
        <fs_s_fct>-just = 'C'.

      WHEN 'ZZMAKTX80'.        "자재명
        _fcat TEXT-f21.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.

      WHEN 'SPECNO'. "SPEC NO.
        _fcat TEXT-fa2.
        <fs_s_fct>-just = 'C'.

      WHEN 'COLOR'.  "색상
        _fcat TEXT-f22.
        <fs_s_fct>-just = 'C'.

      WHEN 'STRIPE_COLOR'.     " 띠줄색상
        _fcat TEXT-fa0.
        <fs_s_fct>-just = 'C'.

      WHEN 'STRIPE_NO'.     " 띠줄수
        _fcat TEXT-fa1.
        <fs_s_fct>-just = 'C'.

      WHEN 'WERKS'.     " 플랜트
        _fcat TEXT-f02.
        <fs_s_fct>-just = 'C'.

      WHEN 'WERKS_N'.  "플랜트명
        _fcat TEXT-f03.
        <fs_s_fct>-just = 'C'.

      WHEN 'LGORT'.        "저장위치
        _fcat TEXT-f25.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'T001L'.
        <fs_s_fct>-ref_field  = 'LGORT'.
        <fs_s_fct>-just = 'C'.

      WHEN 'LGOBE'.        "저장위치명
        _fcat TEXT-f26.
        <fs_s_fct>-just = 'C'.

      WHEN 'EMLIF'.     "임가공직납업체
        _fcat TEXT-f29.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'EMLIF'.
        <fs_s_fct>-just = 'C'.

      WHEN 'EMLIF_N'.    "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-just = 'C'.

      WHEN 'MENGE'.        "수량
        _fcat TEXT-f27.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-just = 'R'.

      WHEN 'MEINS'.        "단위
        _fcat TEXT-f28.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'MARA'.
        <fs_s_fct>-ref_field  = 'MEINS'.
        <fs_s_fct>-just = 'C'.
      WHEN 'LENGTH'.        "조장
        _fcat TEXT-f23.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'R'.

      WHEN 'ZDGNO'.        "설계번호
        _fcat '설계번호'.
        <fs_s_fct>-just = 'C'.
        <fs_s_fct>-no_out = gc_x.

      WHEN 'ZREVNO'.        "개정번호
        _fcat '개정번호'.
        <fs_s_fct>-just = 'C'.
        <fs_s_fct>-no_out = gc_x.

      WHEN 'DRMATNR'.        "포장재(드럼)
        _fcat '포장재(드럼)'.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'MARA'.
        <fs_s_fct>-ref_field  = 'MATNR'.
        <fs_s_fct>-just = 'C'.

      WHEN 'DRUMNAME'.        "포장재(드럼)내역
        _fcat '포장재(드럼)내역'.
        <fs_s_fct>-just = 'C'.

      WHEN 'DRQTY'.        "드럼수
        _fcat TEXT-f38.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-just = 'R'.
      WHEN 'NETPR'.        "단가
        _fcat TEXT-f31.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'R'.
      WHEN 'PEINH'.        "PER
        _fcat TEXT-f32.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'WAERS'.        "통화
        _fcat TEXT-f34.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'T001'.
        <fs_s_fct>-ref_field  = 'WAERS'.
        <fs_s_fct>-just = 'C'.
      WHEN 'MWSKZ'.        "TAX
        _fcat TEXT-f36.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'T007A'.
        <fs_s_fct>-ref_field  = 'MWSKZ'.
        <fs_s_fct>-just = 'C'.
      WHEN 'NETPR_I'.        "INFO단가
        _fcat 'INFO단가'.
        <fs_s_fct>-cfieldname = 'WAERS_I'.
        <fs_s_fct>-just = 'R'.
      WHEN 'PEINH_I'.        "INFO PER
        _fcat 'INFO PER'.
        <fs_s_fct>-just = 'C'.
      WHEN 'WAERS_I'.        "INFO통화
        _fcat 'INFO통화'.
        <fs_s_fct>-just = 'C'.
      WHEN 'MWSKZ_I'.        "INFO TAX
        _fcat 'INFO TAX'.
        <fs_s_fct>-just = 'C'.
      WHEN 'IDNLF'.        "공급업체자재번호
        _fcat TEXT-f24.
        <fs_s_fct>-just = 'C'.
      WHEN 'EINDT'.        "납품예정일
        _fcat TEXT-f76.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKET'.
        <fs_s_fct>-ref_field  = 'EINDT'.
        <fs_s_fct>-just = 'C'.
      WHEN 'INSMK'.        "재고유형
        _fcat TEXT-f37.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'INSMK'.
        <fs_s_fct>-just = 'C'.
      WHEN 'INSMK_N'.        "유형명
        _fcat TEXT-f19.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZMEMO'.     "비고(품목)
        _fcat TEXT-f43.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'UEBTO'.        "초과납품한도
        _fcat TEXT-f77.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'RETPO'.     "반품
        _fcat TEXT-f78.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'RETPO'.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZFREE'.       "무상
        _fcat TEXT-f79.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-checkbox = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'KNTTP'.     "AAC
        _fcat TEXT-f04.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'KNTTP'.
        <fs_s_fct>-just = 'C'.
      WHEN 'ABLAD'.     "AAC
        _fcat TEXT-f86.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.

      WHEN 'MTART'.   "자재유형
        _fcat TEXT-f87.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'MATKL'.   "자재그룹
        _fcat TEXT-f15.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'MARA'.
        <fs_s_fct>-ref_field  = 'MATKL'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PSTYP'.     "IC
        _fcat TEXT-f05.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'EKPO'.
        <fs_s_fct>-ref_field  = 'PSTYP'.
        <fs_s_fct>-just = 'C'.
      WHEN 'VBELN'.     "판매오더
        _fcat TEXT-f58.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'VBAK'.
        <fs_s_fct>-ref_field  = 'VBELN'.
        <fs_s_fct>-just = 'C'.
      WHEN 'VBELP'.     "항번
        _fcat TEXT-f13.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'MCONTENTS'.     "시스마킹내용
        _fcat TEXT-f99.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZMEMO_S'.     "특기사항
        _fcat TEXT-f98.
        <fs_s_fct>-just = 'C'.
      WHEN 'KOSTL'.        "코스트센터
        _fcat TEXT-f55.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'CSKS'.
        <fs_s_fct>-ref_field  = 'KOSTL'.
        <fs_s_fct>-just = 'C'.
      WHEN 'SAKTO'.        "G/L계정
        _fcat TEXT-f46.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'SKB1'.
        <fs_s_fct>-ref_field  = 'SAKNR'.
        <fs_s_fct>-just = 'C'.
      WHEN 'ANLN1'.     "고정자산번호
        _fcat TEXT-f63.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'ANLA'.
        <fs_s_fct>-ref_field  = 'ANLN1'.
        <fs_s_fct>-just = 'C'.
      WHEN 'ANLN2'.     "고정자산번호(SUB)
        _fcat TEXT-f64.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'ANLA'.
        <fs_s_fct>-ref_field  = 'ANLN2'.
        <fs_s_fct>-just = 'C'.
      WHEN 'PS_PSP_PNR'.     "WBS
        _fcat TEXT-f66.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'PRPS'.
        <fs_s_fct>-ref_field  = 'PSPNR'.
        <fs_s_fct>-just = 'C'.
      WHEN 'AUFNR'.     "오더번호
        _fcat TEXT-f70.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-ref_table = 'AUFK'.
        <fs_s_fct>-ref_field  = 'AUFNR'.
        <fs_s_fct>-just = 'C'.
      WHEN 'INFNR'.     "INFORECORD
        _fcat TEXT-f80.
        <fs_s_fct>-just = 'C'.
      WHEN 'MESSAGE'.   "메시지
        _fcat TEXT-f69.
        <fs_s_fct>-just = 'C'.

**-- 26.10 특성값 추가
      WHEN 'INSQTY_W'.
        _fcat TEXT-fa4.
        <fs_s_fct>-just = 'C'.
      WHEN 'INSQTY_S'.
        _fcat TEXT-fa5.
        <fs_s_fct>-just = 'C'.

      WHEN OTHERS.
        <fs_s_fct>-no_out = gc_x.

    ENDCASE.

    APPEND <fs_s_fct> TO gt_fcat_cre_400.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_ALV_LAYOUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_alv_layout.

  CLEAR gs_layout.
  gs_layout = VALUE #(
*                       NO_ROWINS  = ZGTFI_X
                       zebra  = zgtfi_x
                       sel_mode   = zgtfi_a
                       cwidth_opt  = zgtfi_a
                       stylefname = 'STYLE'
                       ctab_fname = 'F_COL'
  ).

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_alv_toolbar.

  REFRESH gt_exclud.

  gt_exclud[] = VALUE #(
*                         ( CL_GUI_ALV_GRID=>MC_MB_VIEW              )
                         ( cl_gui_alv_grid=>mc_fc_loc_undo          )
                         ( cl_gui_alv_grid=>mc_fc_auf               )
                         ( cl_gui_alv_grid=>mc_fc_detail            )
                         ( cl_gui_alv_grid=>mc_fc_graph             )
                         ( cl_gui_alv_grid=>mc_fc_info              )
                         ( cl_gui_alv_grid=>mc_fc_loc_copy          )
                         ( cl_gui_alv_grid=>mc_fc_loc_copy_row      )
                         ( cl_gui_alv_grid=>mc_fc_loc_cut           )
                         ( cl_gui_alv_grid=>mc_fc_loc_delete_row    )
                         ( cl_gui_alv_grid=>mc_fc_loc_insert_row    )
                         ( cl_gui_alv_grid=>mc_fc_loc_move_row      )
                         ( cl_gui_alv_grid=>mc_fc_loc_append_row    )
                         ( cl_gui_alv_grid=>mc_fc_loc_paste         )
                         ( cl_gui_alv_grid=>mc_fc_loc_paste_new_row )
*                         ( CL_GUI_ALV_GRID=>MC_FC_PRINT             )
                         ( cl_gui_alv_grid=>mc_fc_refresh           )
                         ).

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_ALV_SORT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_alv_sort.

*  GT_SORT[] = VALUE LVC_T_SORT(
*    ( SPOS = '1' FIELDNAME = 'WERKS'       UP = ZGTFI_X )
*    ( SPOS = '2' FIELDNAME = 'WERKS_TX' UP = ZGTFI_X SUBTOT = ZGTFI_X )
*    ( SPOS = '3' FIELDNAME = 'MTART'    UP = ZGTFI_X )
*    ( SPOS = '4' FIELDNAME = 'MATNR'    UP = ZGTFI_X )
*                                ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_color.

  DATA:
    ls_color   TYPE  lvc_s_scol.

  CHECK sy-tcode = 'ZGTMMR3001'.

  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<list>).
    CLEAR: <list>-f_col, ls_color.
*PR상태->'PO 삭제'인 경우에만, 주황색 컬러 처리
    ls_color = VALUE #( fname = 'PR_STATUS'
                                       color-col = COND  #( WHEN  <list>-pr_status = 'PO 삭제'
                                                                             THEN '7'  ELSE '0' )"주황 3/ 흰색(기본)0
                                       color-int = '0'     "색 연하게( 1 : 진하게 )
                                       color-inv = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
    INSERT ls_color INTO TABLE <list>-f_col.
  ENDLOOP.

**COL 값 표준 색상
**0 : 기본 배경색 (우유색/회색)  COL_BACKGROUND (일반 배경)
**1 : 진한 파란색 / 청회색  COL_HEADING (헤더/타이틀)
**2 : 연한 회색  COL_NORMAL (일반 셀 강조)
**3 : 노란색  COL_TOTAL (합계 / 요약 라인)
**4 : 청록색 / 하늘색  COL_KEY (KEY 필드 고정 색상)
**5 : 녹색  COL_POSITIVE (양수 / 성공 / 안전 데이터)
**6 : 빨간색  COL_NEGATIVE (음수 / 에러 / 경고 데이터)
**7 : 주황색 / 자주색  COL_GROUP (제어 레벨 / 그룹화 라인)
ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_EVENT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_event  CHANGING po_event TYPE REF TO lcl_evt_receiver
                                               pcl_grid  TYPE REF TO cl_gui_alv_grid.

  pcl_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).
  pcl_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).

**--> 26.09 *단순견적 - 추가
  IF p_pr = gc_x OR p_pr2 = gc_x.
    PERFORM set_cell_style USING 'PR'.
  ELSE.
    PERFORM set_cell_style USING 'CRE'.
  ENDIF.

  DATA: lt_f4 TYPE lvc_t_f4,
        ls_f4 TYPE lvc_s_f4.

  ls_f4-fieldname  = 'LGORT'.
  ls_f4-register     = 'X'.
  ls_f4-getbefore  = 'X'.
  ls_f4-chngeafter = 'X'.
  APPEND ls_f4 TO lt_f4.

  CALL METHOD pcl_grid->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4.

  CREATE OBJECT po_event.

  SET HANDLER :
  po_event->handle_data_changed                 FOR pcl_grid,
  po_event->handle_data_changed_finished  FOR pcl_grid,
  po_event->handle_hotspot_click                FOR pcl_grid,
  po_event->handle_toolbar                           FOR pcl_grid,
  po_event->handle_user_command               FOR pcl_grid,
  po_event->handle_on_f4                               FOR pcl_grid.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM display_alv TABLES pt_list pt_fcat TYPE lvc_t_fcat
                             CHANGING  pcl_grid  TYPE REF TO cl_gui_alv_grid.

**--> 26.09 *단순견적 - 추가
  IF sy-tcode = 'ZGTMMR3000'.
    DATA(ls_variant) = VALUE disvariant( report  = sy-cprog
                                                           handle  = COND #(
                                                           WHEN p_pr = gc_x THEN '0001'
                                                           WHEN p_pr2 = gc_x THEN '0001'
                                                           WHEN p_cre = gc_x THEN '0002'
                                                            WHEN p_mot = gc_x THEN '0003'  ELSE '0004' ) ).
  ELSE. "ZGTMMR3001
    CLEAR  ls_variant.
    ls_variant = VALUE disvariant( report  = sy-cprog
                                                handle  = COND #(  WHEN p_pr = gc_x THEN '0005'
                                                                   WHEN p_pr2 = gc_x THEN '0005'
                                                                   WHEN p_cre = gc_x THEN '0006'
                                                                   WHEN p_mot = gc_x THEN '0007'  ELSE '0008' ) ).
  ENDIF.


  " 4. F4 대상 필드 등록
  DATA: lt_f4 TYPE lvc_t_f4.
  lt_f4 = VALUE #(
               ( fieldname = 'MWSKZ' register   = 'X' )
               ( fieldname = 'LGORT' register   = 'X' )
               ( fieldname = 'LIFNR'  register   = 'X' )
               ( fieldname = 'FLIEF'  register   = 'X' )
               ( fieldname = 'EMLIF' register   = 'X' ) ).

  CALL METHOD pcl_grid->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4.

*ALV DISPLAY
  CALL METHOD pcl_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      it_toolbar_excluding = gt_exclud[]
      is_variant           = ls_variant
      i_save               = zgtfi_a
    CHANGING
      it_outtab            = pt_list[] "GT_LIST[]
      it_fieldcatalog      = pt_fcat[]
      it_sort              = gt_sort[]
    EXCEPTIONS
      OTHERS               = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM RELEASE_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM release_alv .

  IF gcl_grid IS BOUND.
    gcl_grid->free( ).
    CLEAR gcl_grid.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INITIALIZATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM initialization .

  DATA: lt_values TYPE TABLE OF usvalues,
        ls_values TYPE usvalues.

  CLEAR : s_erdat[]. "생성일
  s_erdat[] = VALUE #( ( sign   = gc_i
                                        option = gc_bt
                                        low    = sy-datlo - 90
                                        high   = sy-datlo ) ).

  CLEAR:
    gt_t163i[],
    gt_t163y[],
    gt_t023t[],
    gt_t001w[],
    gt_t001l[],
    gt_t024e[],
    gt_t024[].

  SELECT
    knttp,
    knttx
    FROM t163i
    WHERE spras EQ @sy-langu
    INTO TABLE @gt_t163i.

  SELECT
    pstyp,
    ptext
    FROM t163y
    WHERE spras EQ @sy-langu
    INTO TABLE @gt_t163y.

  SELECT
    matkl,
    wgbez
    FROM t023t
    WHERE spras EQ @sy-langu
    INTO TABLE @gt_t023t.

  SELECT
    werks,
    name1
    FROM t001w
    INTO TABLE @gt_t001w.

  SELECT
    werks,
    lgort,
    lgobe
    FROM t001l
    INTO TABLE @gt_t001l.

  SELECT
    ekorg,
    ekotx
    FROM t024e
    INTO TABLE @gt_t024e.

  SELECT
    ekgrp,
    eknam
    FROM t024
    INTO TABLE @gt_t024.

*DOMAIN VALUE
  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      domname    = 'INSMK'
    TABLES
      values_tab = gt_insmk.
  SORT gt_insmk BY domvalue_l ddtext.

  CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
    EXPORTING
      mandant           = sy-mandt
      sel_object        = 'ZCBO_MM001' " 조회할 권한 오브젝트명
      user_name         = sy-uname
    TABLES
      values            = lt_values
    EXCEPTIONS
      user_name_invalid = 1
      object_not_found  = 2
      internal_error    = 3
      OTHERS            = 4.

  DELETE  lt_values WHERE von = '*'.

  IF lt_values[] IS NOT INITIAL.

    READ TABLE lt_values INTO ls_values WITH KEY field = 'BUKRS'.
    IF sy-subrc EQ 0. p_bukrs = ls_values-von. ENDIF.

    READ TABLE lt_values INTO ls_values WITH KEY field = 'EKORG'.
    IF sy-subrc EQ 0. p_ekorg = ls_values-von. ENDIF.

    READ TABLE lt_values INTO ls_values WITH KEY field = 'WERKS'.
    IF sy-subrc EQ 0. p_werks = ls_values-von. s_werks-low = ls_values-von.     ENDIF.

    READ TABLE lt_values INTO ls_values WITH KEY field = 'EKGRP'.
    IF sy-subrc EQ 0.  p_ekgrp = ls_values-von.  s_ekgrp-low = ls_values-von. ENDIF.


  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM input_validation.

  CLEAR : gt_list, gv_err.

  IF p_cre NE gc_x AND s_erdat[] IS INITIAL AND s_eindt[] IS INITIAL.
    MESSAGE s000 WITH TEXT-m13 DISPLAY LIKE gc_e.
    gv_err = gc_x. STOP. "생성일과 납품예정일 중 최소 하나는 입력 해야 합니다.
  ENDIF.

**--> 26.09 *단순견적 - 추가
  IF ( p_pr = gc_x OR p_pr2 = gc_x ) AND p_vol IS INITIAL AND p_prd IS INITIAL.
    MESSAGE s000 WITH TEXT-m16 DISPLAY LIKE gc_e.
    gv_err = gc_x. STOP.
    "청구량 정보 조회와 구매요청 정보 조회 중 최소 하나는 체크해야 합니다.
  ENDIF.

  IF  s_werks-low IS NOT INITIAL.
    LOOP AT s_werks INTO DATA(ls_werks).

      SELECT SINGLE 1
       FROM t001w
       WHERE werks EQ @ls_werks-low
        INTO @DATA(lv_exst).

      IF sy-subrc <> 0.
        MESSAGE s000 WITH TEXT-m01 DISPLAY LIKE gc_e.
        gv_err = gc_x. STOP. "유효하지 않은 플랜트 입니다.
      ENDIF.

    ENDLOOP.
  ENDIF.

  IF  s_ekgrp-low IS NOT INITIAL.
    LOOP AT s_ekgrp INTO DATA(ls_ekgrp).

      SELECT SINGLE 1
       FROM t024
       WHERE ekgrp EQ @ls_ekgrp-low
        INTO @lv_exst.

      IF sy-subrc <> 0.
        MESSAGE s000 WITH TEXT-m02 DISPLAY LIKE gc_e.
        gv_err = gc_x.  STOP. "유효하지 않은 구매그룹 입니다.
      ENDIF.

    ENDLOOP.

  ELSEIF p_ekgrp IS NOT INITIAL.
    SELECT SINGLE 1
     FROM t024
     WHERE ekgrp EQ @p_ekgrp
      INTO @lv_exst.

    IF sy-subrc <> 0.
      MESSAGE s000 WITH TEXT-m02 DISPLAY LIKE gc_e.
      gv_err = gc_x.  STOP. "유효하지 않은 구매그룹 입니다.
    ENDIF.
  ENDIF.

  IF s_ebeln[] IS NOT INITIAL.
    LOOP AT s_ebeln INTO DATA(ls_low).

      SELECT SINGLE 1
      FROM ekko
      WHERE ebeln EQ @ls_low-low
      INTO @lv_exst.

      IF sy-subrc <> 0.
        MESSAGE s000 WITH TEXT-m12 DISPLAY LIKE gc_e.
        gv_err = gc_x. STOP. "유효하지 않은 구매오더 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF s_lifnr[] IS NOT INITIAL.
    LOOP AT s_lifnr INTO DATA(ls_lifnr).

      SELECT SINGLE 1
      FROM lfa1
      WHERE lifnr EQ @ls_lifnr-low
      INTO @lv_exst.

      IF sy-subrc <> 0.
        MESSAGE s000 WITH TEXT-m03 DISPLAY LIKE gc_e.
        gv_err = gc_x. STOP. "유효하지 않은 공급업체 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF s_matnr[] IS NOT INITIAL.
    LOOP AT s_matnr INTO DATA(ls_matnr).

      SELECT SINGLE 1
      FROM mara
      WHERE matnr EQ @ls_matnr-low
      INTO @lv_exst.

      IF sy-subrc <> 0.
        MESSAGE s000 WITH TEXT-m10 DISPLAY LIKE gc_e.
        gv_err = gc_x. STOP. "유효하지 않은 자재코드 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF s_vbeln[] IS NOT INITIAL.
    LOOP AT s_vbeln INTO DATA(ls_vbeln).

      SELECT SINGLE 1
      FROM vbak
      WHERE vbeln EQ @ls_vbeln-low
      INTO @lv_exst.

      IF sy-subrc <> 0.
        MESSAGE s000 WITH TEXT-m11 DISPLAY LIKE gc_e.
        gv_err = gc_x. STOP. "유효하지 않은 판매오더 입니다.
      ENDIF.
    ENDLOOP.
  ENDIF.


**-- 26.09 판매문서 & 품목 추가에 대한 분기 처리
  IF s_sopo[] IS NOT INITIAL.

  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM check_auth.

  CASE gc_x.
**--> 26.09 *단순견적 - 추가
    WHEN p_pr OR p_pr2.

      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
      ID 'BUKRS' FIELD p_bukrs.

      IF sy-subrc <> 0.
        SET CURSOR FIELD 'P_BUKRS'.
        MESSAGE e172 WITH p_bukrs. "회사코드 [&] 작업권한을 확인하세요.
      ENDIF.

      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
      ID 'EKORG' FIELD p_ekorg.

      IF sy-subrc <> 0.
        SET CURSOR FIELD 'P_EKORG'.
        MESSAGE e170 WITH p_ekorg. "구매조직 [&] 작업권한을 확인하세요.
      ENDIF.

      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
      ID 'WERKS' FIELD p_werks.

      IF sy-subrc <> 0.
        SET CURSOR FIELD 'P_WERKS'.
        MESSAGE e106 WITH p_werks. "플랜트 [&] 작업권한을 확인하세요.
      ENDIF.

      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
      ID 'EKGRP' FIELD p_ekgrp.

      IF sy-subrc <> 0.
        SET CURSOR FIELD 'P_EKGRP'.
        MESSAGE e171 WITH p_ekgrp. "구매그룹[&] 작업권한을 확인하세요.
      ENDIF.

    WHEN p_cre.

      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
      ID 'BUKRS' FIELD p_bukrs.

      IF sy-subrc <> 0.
        SET CURSOR FIELD 'P_BUKRS'.
        MESSAGE e172 WITH p_bukrs. "회사코드 [&] 작업권한을 확인하세요.
      ENDIF.

      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
      ID 'EKORG' FIELD p_ekorg.

      IF sy-subrc <> 0.
        SET CURSOR FIELD 'P_EKORG'.
        MESSAGE e170 WITH p_ekorg. "구매조직 [&] 작업권한을 확인하세요.
      ENDIF.

      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
      ID 'WERKS' FIELD p_werks.

      IF sy-subrc <> 0.
        SET CURSOR FIELD 'P_WERKS'.
        MESSAGE e106 WITH p_werks. "플랜트 [&] 작업권한을 확인하세요.
      ENDIF.

      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
      ID 'EKGRP' FIELD p_ekgrp.

      IF sy-subrc <> 0.
        SET CURSOR FIELD 'P_EKGRP'.
        MESSAGE e171 WITH p_ekgrp. "구매그룹[&] 작업권한을 확인하세요.
      ENDIF.

    WHEN p_mot.

      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
      ID 'BUKRS' FIELD p_bukrs.

      IF sy-subrc <> 0.
        SET CURSOR FIELD 'P_BUKRS'.
        MESSAGE e172 WITH p_bukrs. "회사코드 [&] 작업권한을 확인하세요.
      ENDIF.

      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
      ID 'EKORG' FIELD p_ekorg.

      IF sy-subrc <> 0.
        SET CURSOR FIELD 'P_EKORG'.
        MESSAGE e170 WITH p_ekorg. "구매조직 [&] 작업권한을 확인하세요.
      ENDIF.

      LOOP AT s_werks INTO DATA(ls_werks2).
        AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
        ID 'WERKS' FIELD ls_werks2-low.

        IF sy-subrc <> 0.
          SET CURSOR FIELD 'S_WERKS-LOW'.
          MESSAGE e106 WITH ls_werks2-low. "플랜트 [&] 작업권한을 확인하세요.
        ENDIF.
      ENDLOOP.

      LOOP AT s_ekgrp INTO DATA(ls_ekgrp2).
        AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
        ID 'EKGRP' FIELD ls_ekgrp2-low.

        IF sy-subrc <> 0.
          SET CURSOR FIELD 'S_EKGRP-LOW'.
          MESSAGE e171 WITH ls_ekgrp2-low. "구매그룹 [&] 작업권한을 확인하세요.
        ENDIF.
      ENDLOOP.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM selection_screen_output .

  LOOP AT SCREEN.

    IF  screen-name = '%B002034_BLOCK_1000'. "모니터링조회옵션 블럭제어
      CASE gc_x.
        WHEN p_mot.
          screen-active = 1.  "활성
**--> 26.09 *단순견적 - 추가
        WHEN  p_cre OR p_pr OR p_pr2. "직접생성
          screen-active = 0.  "비활성
      ENDCASE.
    ENDIF.

    IF  screen-name = '%B004024_BLOCK_1000'. "요청조회옵션 블럭제어
      CASE gc_x.
**--> 26.09 *단순견적 - 추가
        WHEN p_pr OR p_pr2.
          screen-active = 1.  "활성
        WHEN p_mot OR p_cre. "모니터링/직접생성
          screen-active = 0.
      ENDCASE.
    ENDIF.

    IF  screen-group1 = 'MOT'.
      CASE gc_x.
**--> 26.09 *단순견적 - 추가
        WHEN p_pr OR p_cre OR p_pr2.
          screen-active = 0.  "비활성
        WHEN p_mot. "모니터링
          screen-active = 1.  "활성
      ENDCASE.
    ENDIF.

    IF  screen-group1 = 'MPR'.
      CASE gc_x.
**--> 26.09 *단순견적 - 추가
        WHEN p_pr OR p_pr2. "청구량/PR 기준
          screen-active = 1.  "활성
        WHEN p_cre OR p_mot.
          screen-active = 0.  "비활성
      ENDCASE.
    ENDIF.

    IF  screen-group1 = 'CRE'.
      CASE gc_x.
        WHEN p_cre. "직접생성
          screen-active = 0.  "비활성
**--> 26.09 *단순견적 - 추가
        WHEN p_pr  OR p_mot OR p_pr2. "청구량기준/모니터링
          screen-active = 1.  "활성
      ENDCASE.
    ENDIF.

    IF  screen-group1 = 'MD1'.
      CASE gc_x.
**--> 26.09 *단순견적 - 추가
        WHEN p_pr OR p_cre OR p_pr2. "청구량기준/직접생성
          screen-active = 1.  "활성
        WHEN p_mot.
          screen-active = 0.  "비활성
      ENDCASE.
    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM get_data .

  DATA : lt_lines  TYPE TABLE OF  tline,
         lt_lines2 TYPE TABLE OF  tline,
         lv_line   TYPE string,
         lv_line2  TYPE string,
         lv_name   TYPE thead-tdname,
         lv_name2  TYPE thead-tdname,
         lv_msg    TYPE bapi_msg.

  DATA : lr_ztype TYPE RANGE OF zgtmm_cv_get_reqpo_raw-ztype.
  CLEAR : lr_ztype, lr_ztype[], gv_err, gt_list, lt_lines, lv_line.

  DATA lr_ztype_n TYPE RANGE OF zgtmm_cv_get_reqpo_raw-ztype_n.
  CLEAR lr_ztype_n. REFRESH lr_ztype_n.


*조회조건 설정
  IF p_vol = gc_x. "청구량 정보 조회
    APPEND VALUE #( sign = gc_i
                                 option = gc_eq
                                 low = gc_cl
                               ) TO lr_ztype.
  ENDIF.

  IF p_prd = gc_x. "구매요청 정보 조회
    APPEND VALUE #( sign = gc_i
                                 option = gc_eq
                                 low = gc_pr
                               ) TO lr_ztype.
  ENDIF.

***--> 26.09 *단순견적 - 추가
  IF p_pr = gc_x.
    lr_ztype_n[] = VALUE #( ( sign = gc_i option = gc_eq low = TEXT-f50 )
                            ( sign = gc_i option = gc_eq low = '청구현황' )
                          ).  "구매요청 / 청구현황 ADD
  ELSEIF p_pr2 = gc_x.
    lr_ztype_n[] = VALUE #( ( sign = gc_i option = gc_eq low = TEXT-c11 ) ).  "단순견적
  ENDIF.
**--< 26.09 *단순견적 - 추가


**데이터 가져오기
*  IF P_ORD = GC_X.  "발주진행대상조회 OPTION
*    SELECT FROM ZGTMM_CV_GET_REQPO_DATA
*    FIELDS *
*    WHERE BUKRS = @P_BUKRS
*         AND EKORG = @P_EKORG
*         AND WERKS = @P_WERKS
*         AND EKGRP = @P_EKGRP
*         AND ERDAT IN @S_ERDAT
*         AND LFDAT IN @S_EINDT
*         AND MATNR IN @S_MATNR
*         AND VBELN IN @S_VBELN
*         AND REL = @GC_X
*         AND ZTYPE IN @LR_ZTYPE
*         AND EBELN IS INITIAL
*        INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.
*
*  ELSE.
  SELECT FROM zgtmm_cv_get_reqpo_data
  FIELDS *
  WHERE bukrs = @p_bukrs
       AND ekorg = @p_ekorg
       AND werks = @p_werks
       AND ekgrp = @p_ekgrp
       AND erdat IN @s_erdat
       AND lfdat IN @s_eindt
       AND matnr IN @s_matnr
       AND vbeln IN @s_vbeln
       AND rel = @gc_x
       AND ztype IN @lr_ztype

**--> 26.09 *단순견적 - 추가
       AND ztype_n IN @lr_ztype_n

**--> 26.09 *판매문서 & 품목 추가
       AND concat( vbeln , posnr ) IN @s_sopo

       AND menge > 0
      INTO CORRESPONDING FIELDS OF TABLE @gt_list.
*  ENDIF.

  IF gt_list[] IS INITIAL.
    gv_err = gc_x. "조회 조건에 일치하는 정보가 없습니다.
    MESSAGE s000 WITH TEXT-e01. EXIT.

  ELSE.
    IF p_del = gc_x.
      DELETE gt_list WHERE ( ebakz IS NOT INITIAL OR
                                           loekz IS NOT INITIAL ).
    ENDIF.
  ENDIF.

  CHECK gv_err IS INITIAL.

*저장위치 8번 분기: 1드럼 총중량(드럼 포함) 3.5톤 초과 시 3410
  PERFORM set_lgort_by_weight.

*여장 체크
  PERFORM set_inspection_qty.

  CLEAR gt_info.
*단가/통화/PER/TAX 정보
  SELECT FROM zgtmm_cv_get_infoprice
    FIELDS matnr, lifnr, kbetr, konwa, kpein ,mwskz, idnlf
    FOR ALL ENTRIES IN @gt_list
    WHERE ekorg = @gt_list-ekorg
         AND matnr = @gt_list-matnr
         AND lifnr   = @gt_list-flief
         AND esokz = @gt_list-pstyp
         AND datab <= @sy-datum AND  datbi >= @sy-datum
        INTO CORRESPONDING FIELDS OF TABLE @gt_info.

  SORT  gt_info BY   matnr lifnr .

*자재별 INFO정보의 계약업체 리스트 조회.
  SELECT a~matnr, c~lifnr, c~name1 , d~datab, d~datbi, d~knumh
    FROM eina AS a
    INNER JOIN eine AS b
    ON a~infnr = b~infnr
    INNER JOIN lfa1 AS c
    ON a~lifnr = c~lifnr
    INNER JOIN a017 AS d
    ON a~matnr = d~matnr AND a~lifnr = d~lifnr AND b~ekorg = d~ekorg AND b~werks = d~werks AND b~esokz = d~esokz

    FOR ALL ENTRIES IN @gt_list
    WHERE a~matnr = @gt_list-matnr
         AND b~ekorg = @gt_list-ekorg
         AND b~werks = @gt_list-werks
         AND b~loekz IS INITIAL
         AND a~loekz IS INITIAL
         AND d~kschl = 'PB00'
        INTO TABLE @DATA(lt_bp).

*PB00 조건레코드 삭제지시자(KONP-LOEVM_KO) 체크: 삭제 표시된 조건의 계약업체 제외
*  IF lt_bp IS NOT INITIAL.
*    SELECT knumh
*      FROM konp
*      FOR ALL ENTRIES IN @lt_bp
*      WHERE knumh = @lt_bp-knumh
*        AND kopos = '01'
*        AND loevm_ko <> ''
*      INTO TABLE @DATA(lt_bp_del).
*
*    LOOP AT lt_bp_del INTO DATA(ls_bp_del).
*      DELETE lt_bp WHERE knumh = ls_bp_del-knumh.
*    ENDLOOP.
*  ENDIF.
*PB00 조건레코드: 삭제표시 없는 라인(KONP-LOEVM_KO 공란)이 하나도 없는 KNUMH만 제외
  IF lt_bp IS NOT INITIAL.
    SELECT DISTINCT knumh
      FROM konp
      FOR ALL ENTRIES IN @lt_bp
      WHERE knumh = @lt_bp-knumh
        AND kschl = 'PB00'
        AND loevm_ko = ''
      INTO TABLE @DATA(lt_bp_live).

    SORT lt_bp_live BY knumh.

    LOOP AT lt_bp INTO DATA(ls_bp_chk).
      READ TABLE lt_bp_live TRANSPORTING NO FIELDS
           WITH KEY knumh = ls_bp_chk-knumh BINARY SEARCH.
      IF sy-subrc <> 0.
        DELETE lt_bp.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT  lt_bp BY   matnr lifnr .

*텍스트 존재 여부 사전 조회: 텍스트 헤더(STXH)를 한 번에 읽어 존재하는 건만 READ_TEXT 호출
  TYPES: BEGIN OF lty_th,
           tdobject TYPE stxh-tdobject,
           tdname   TYPE stxh-tdname,
         END OF lty_th.
  DATA: lt_th_req TYPE SORTED TABLE OF lty_th WITH UNIQUE KEY tdobject tdname,
        lt_th_ok  TYPE SORTED TABLE OF lty_th WITH NON-UNIQUE KEY tdobject tdname.

  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<fs_th>).
    IF <fs_th>-banfn IS NOT INITIAL.
      INSERT VALUE #( tdobject = 'EBANH' tdname = <fs_th>-banfn ) INTO TABLE lt_th_req.
      INSERT VALUE #( tdobject = 'EBAN'  tdname = <fs_th>-banfn && <fs_th>-bnfpo ) INTO TABLE lt_th_req.
    ENDIF.
    IF <fs_th>-vbeln IS NOT INITIAL.
      INSERT VALUE #( tdobject = 'VBBP' tdname = <fs_th>-vbeln && <fs_th>-posnr ) INTO TABLE lt_th_req.
    ENDIF.
  ENDLOOP.

  IF lt_th_req IS NOT INITIAL.
    SELECT tdobject, tdname
      FROM stxh
      FOR ALL ENTRIES IN @lt_th_req
      WHERE tdobject = @lt_th_req-tdobject
        AND tdname   = @lt_th_req-tdname
        AND tdid    IN ('B01', '0001')
        AND tdspras  = @sy-langu
      INTO TABLE @lt_th_ok.
  ENDIF.

  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<fs>).

    DATA(lv_date) = <fs>-lfdat.
*PR 최초 조회 단가/통화/PER/TAX 정보 담기
    <fs>-preis_p   =  <fs>-preis.
    <fs>-waers_p = <fs>-waers.
    <fs>-peinh_p   = <fs>-peinh.
    <fs>-mwskz_p = <fs>-mwskz.
    <fs>-menge_i   = <fs>-menge.

    IF <fs>-flief IS INITIAL.
*납품요청일 기준 유효한 계약 건수
      SELECT SINGLE conqty
*         FROM ZGTMM_CV_GET_INFOPRICE_M( P_DATE = @LV_DATE )
         FROM zgtmm_cv_get_infoprice_m( p_date = @sy-datum )
         WHERE matnr = @<fs>-matnr
              AND ekorg = @<fs>-ekorg
              AND werks = @<fs>-werks
              AND esokz = @<fs>-pstyp
         INTO @<fs>-conqty.

    ELSE.
*단가/통화/PER/TAX 정보->고정공급업체(FLIEF) 데이터 있으면 재조회
      READ TABLE gt_info INTO DATA(ls_info)
      WITH KEY matnr = <fs>-matnr
                     lifnr = <fs>-flief       BINARY SEARCH.
      IF sy-subrc = 0.
        IF <fs>-preis_p = 0.
          <fs>-preis   = <fs>-preis_i = ls_info-kbetr.    "단가
          <fs>-waers = <fs>-waers_i = ls_info-konwa.   "통화
          <fs>-peinh   = <fs>-peinh_i =   ls_info-kpein.     "PER
*            <FS>-MWSKZ = <FS>-MWSKZ_I =   LS_INFO-MWSKZ.  "TAX
          <fs>-idnlf    = ls_info-idnlf.     "업체자재번호
        ENDIF.
      ENDIF.
*납품요청일 기준 유효한 계약 건수
      SELECT SINGLE conqty
*         FROM ZGTMM_CV_GET_INFOPRICE_VM( P_DATE = @LV_DATE )
         FROM zgtmm_cv_get_infoprice_vm( p_date = @sy-datum )
         WHERE matnr = @<fs>-matnr
              AND ekorg = @<fs>-ekorg
              AND werks = @<fs>-werks
              AND lifnr   = @<fs>-flief
              AND esokz = @<fs>-pstyp
         INTO @<fs>-conqty.

    ENDIF.
*소요량PR진행여부
    IF <fs>-banfn_n IS INITIAL.
      CLEAR <fs>-banfn_icon .
    ELSE.
      <fs>-banfn_icon = icon_bom_item.
    ENDIF.

*PR 헤더 텍스트 설정
    lv_name = <fs>-banfn.
    IF line_exists( lt_th_ok[ tdobject = 'EBANH' tdname = lv_name ] ).
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id        = 'B01'
          language  = sy-langu
          name      = lv_name "<FS>-BANFN
          object    = 'EBANH'
        TABLES
          lines     = lt_lines
        EXCEPTIONS
          not_found = 4.
    ELSE.
      sy-subrc = 4.
    ENDIF.

    IF sy-subrc = 0.
      IF lt_lines[] IS NOT INITIAL.
        LOOP AT lt_lines INTO DATA(ls_l).
          lv_line &&= ls_l-tdline.
          AT LAST.
            lv_line &&= ' '.
          ENDAT.
        ENDLOOP.
        <fs>-zmemo_h = lv_line.
      ENDIF.
    ENDIF.

    CLEAR : ls_l, lt_lines, lv_line, lv_name.
    lv_name = <fs>-banfn && <fs>-bnfpo.
*PR 품목 텍스트 설정
    IF line_exists( lt_th_ok[ tdobject = 'EBAN' tdname = lv_name ] ).
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id        = 'B01' "품목텍스트
          language  = sy-langu
          name      = lv_name
          object    = 'EBAN'
        TABLES
          lines     = lt_lines
        EXCEPTIONS
          not_found = 4.
    ELSE.
      sy-subrc = 4.
    ENDIF.

    IF sy-subrc = 0.
      IF lt_lines[] IS NOT INITIAL.
        LOOP AT lt_lines  INTO ls_l.
          lv_line &&= ls_l-tdline.
          AT LAST.
            lv_line &&= ' '.
          ENDAT.
        ENDLOOP.
        <fs>-zmemo_i = lv_line.
      ENDIF.
    ENDIF.

    CLEAR : ls_l, lt_lines, lv_line, lv_name. "다음 행 텍스트 누적 방지

    IF  <fs>-vbeln IS NOT INITIAL.
      CLEAR : lt_lines2, lv_line2, lv_name2.
      lv_name2 = <fs>-vbeln && <fs>-posnr.
*PR 품목 텍스트 설정
      IF line_exists( lt_th_ok[ tdobject = 'VBBP' tdname = lv_name2 ] ).
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id        = '0001' "품목텍스트
            language  = sy-langu
            name      = lv_name2
            object    = 'VBBP'
          TABLES
            lines     = lt_lines2
          EXCEPTIONS
            not_found = 4.
      ELSE.
        sy-subrc = 4.
      ENDIF.

      IF sy-subrc = 0.
        IF lt_lines2[] IS NOT INITIAL.
          LOOP AT lt_lines2  INTO DATA(ls_l2).
            lv_line2 &&= ls_l2-tdline.
            AT LAST.
              lv_line2 &&= ' '.
            ENDAT.
          ENDLOOP.
          <fs>-zmemo_s = lv_line2.
        ENDIF.
      ENDIF.

    ENDIF.
*자재별 계약업체 리스트 병합표기
    READ TABLE lt_bp TRANSPORTING NO FIELDS
    WITH KEY matnr = <fs>-matnr BINARY SEARCH.

    IF sy-subrc = 0.
      "lt_bp 는 matnr 정렬 상태: 첫 일치 위치부터 같은 자재 구간만 읽는다
      LOOP AT lt_bp ASSIGNING FIELD-SYMBOL(<bp>) FROM sy-tabix.
        IF <bp>-matnr <> <fs>-matnr.
          EXIT.
        ENDIF.
*             IF <BP>-DATAB LE  LV_DATE    AND <BP>-DATBI GE  LV_DATE
        IF <bp>-datab LE  sy-datum   AND <bp>-datbi GE   sy-datum .
          <fs>-bplist &&= '[' && <bp>-lifnr && ']' && <bp>-name1.
        ENDIF.
      ENDLOOP.
    ENDIF.

**-- 26.09 ZGTMMR3001 일시 드럼수 소숫점 제외 로직 추가
    IF sy-tcode = 'ZGTMMR3001'.
      IF <fs>-drqty IS NOT INITIAL.
        SPLIT <fs>-drqty AT '.' INTO <fs>-drqty DATA(lv_dummy).
      ENDIF.
    ENDIF.
  ENDLOOP.

  SORT gt_list BY erdat DESCENDING  ekgrp  matnr txz01 color lfdat
                              knttp ebakz loekz ebeln ebelp ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_LGORT_BY_WEIGHT
*&---------------------------------------------------------------------*
*& 저장위치 결정 8번 분기 - 총중량 3.5톤 초과(Y) : 1드럼 기준(드럼 중량 포함)
*& CDS(ZGTMM_CV_GET_REQPO_RAW2)에서 1~7번·9번(DRUMC)을 통과해 3420 후보가 된 건
*& (LGCHK = 'X')만 대상으로, 1드럼 총중량이 3,500KG 초과이면 3410 으로 변경한다.
*& 중량 산출에 실패한 건은 CDS 결과(3420)를 유지한다.
*&---------------------------------------------------------------------*
FORM set_lgort_by_weight .

  CONSTANTS lc_limit TYPE brgew VALUE '3500'.  "3.5톤(KG)

  DATA : lt_so    TYPE TABLE OF zgtmms1020,
         lt_brgew TYPE TABLE OF zgtmms1021.

  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<fs_lg>)
       WHERE lgchk = gc_x
         AND vbeln IS NOT INITIAL.
    COLLECT VALUE zgtmms1020( vbeln = <fs_lg>-vbeln posnr = <fs_lg>-posnr ) INTO lt_so.
  ENDLOOP.

  CHECK lt_so IS NOT INITIAL.

  CALL FUNCTION 'ZGTMM_SELECT_SO_BRGEW'
    TABLES
      it_so    = lt_so
      ot_brgew = lt_brgew.

  SORT lt_brgew BY vbeln posnr.

  LOOP AT gt_list ASSIGNING <fs_lg>
       WHERE lgchk = gc_x
         AND vbeln IS NOT INITIAL.

    READ TABLE lt_brgew ASSIGNING FIELD-SYMBOL(<ls_br>)
         WITH KEY vbeln = <fs_lg>-vbeln posnr = <fs_lg>-posnr BINARY SEARCH.
    CHECK sy-subrc = 0 AND <ls_br>-type = gc_s.   "중량 산출 성공 건만

    IF <ls_br>-brgew > lc_limit.
      <fs_lg>-lgort = '3410'.
      SELECT SINGLE lgobe FROM t001l
        WHERE werks = @<fs_lg>-werks AND lgort = @<fs_lg>-lgort
        INTO @<fs_lg>-lgort_n.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      FORM  POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
FORM popup_to_confirm_step  USING pv_opt
                                                                pv_text1
                                                                pv_text2
                                                                pv_title.
  CLEAR gv_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption  = pv_opt
      textline1      = pv_text1
      textline2      = pv_text2
      titel          = pv_title
      cancel_display = ''
    IMPORTING
      answer         = gv_answer.

ENDFORM.                    " POPUP_TO_CONFIRM_STEP

*&---------------------------------------------------------------------*
*& FORM REFRESH_TABLE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM refresh_table USING po_grid TYPE REF TO cl_gui_alv_grid
                                               pv_soft_refresh.

  DATA : ls_stable TYPE lvc_s_stbl.

*  CHECK PO_GRID IS BOUND.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.


**--> 26.09 *단순견적 - 추가
  IF p_pr = gc_x OR p_pr2 = gc_x.
    PERFORM set_cell_style USING 'PR'.
  ELSE.
    PERFORM set_cell_style USING 'CRE'.
  ENDIF.


  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable
*     I_SOFT_REFRESH = PV_SOFT_REFRESH
    EXCEPTIONS
      finished  = 1
      OTHERS    = 2.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& TEXT4
*&---------------------------------------------------------------------*
FORM data_changed_finished  USING    pv_modified TYPE char01
                                     pt_good_cells TYPE lvc_t_modi
                                     po_sender.

  CHECK pv_modified IS NOT INITIAL.

  DATA :
    lt_lines     TYPE TABLE OF  tline,
    lv_line      TYPE string,
    lv_name      TYPE thead-tdname,
    lv_jakno     TYPE kdkg4,
    lv_length(6),
    lv_msg       TYPE bapi_msg,
    lt_drum      TYPE STANDARD TABLE OF zgtedsif0038.

  CASE po_sender.
    WHEN gcl_grid OR gcl_grid_400.

      LOOP AT pt_good_cells INTO DATA(ls_mod_cells).

        READ TABLE gt_create ASSIGNING FIELD-SYMBOL(<ls_list>)
                                               INDEX ls_mod_cells-row_id.

        CASE ls_mod_cells-fieldname.
          WHEN 'LIFNR' OR 'MATNR' OR 'EINDT' OR 'PSTYP'.
*위 필드 변경 시, 단가/PER/통화/TAX/인포레코드 재조회

            <ls_list>-pstyp = COND #( WHEN <ls_list>-pstyp IS INITIAL THEN '0'
                                                         ELSE <ls_list>-pstyp ).

            SELECT SINGLE meprf, aplfz
            FROM eina AS a
            INNER JOIN eine AS b
            ON a~infnr = b~infnr
            WHERE a~lifnr =  @<ls_list>-lifnr
            AND a~matnr = @<ls_list>-matnr
            AND b~esokz = @<ls_list>-pstyp
            AND b~ekorg = @<ls_list>-ekorg
            AND b~werks = @<ls_list>-werks INTO ( @DATA(lv_meprf) , @DATA(lv_aplfz) ).

*            IF SY-SUBRC EQ 0.
*              CLEAR : <LS_LIST>-EINDT.
*
*              <LS_LIST>-EINDT = SY-DATUM + LV_APLFZ.
*            ENDIF.

            IF lv_meprf = '5'.
              SELECT SINGLE kbetr AS netpr, kpein AS peinh,
                                       konwa AS waers,
                                       mwskz, infnr, idnlf
                   FROM zgtmm_cv_get_infoprice
                   WHERE lifnr  = @<ls_list>-lifnr
                        AND matnr = @<ls_list>-matnr
                        AND esokz = @<ls_list>-pstyp
                        AND ekorg = @<ls_list>-ekorg
                        AND werks = @<ls_list>-werks
*                        AND DATAB <= @<LS_LIST>-EINDT
*                        AND DATBI >= @<LS_LIST>-EINDT INTO @DATA(LS_INFO).
                        AND datab <= @sy-datum
                        AND datbi >= @sy-datum INTO @DATA(ls_info).

              IF ls_info IS INITIAL.
                CLEAR : <ls_list>-netpr, <ls_list>-waers, <ls_list>-peinh,
                             <ls_list>-infnr, <ls_list>-idnlf, <ls_list>-mwskz , <ls_list>-netpr_i,
                             <ls_list>-waers_i, <ls_list>-peinh_i .", <LS_LIST>-MWSKZ_I .
              ELSE.
                <ls_list>-netpr_i = ls_info-netpr.
                <ls_list>-waers_i = ls_info-waers.
                <ls_list>-peinh_i   = ls_info-peinh .
*                <LS_LIST>-MWSKZ_I = LS_INFO-MWSKZ.
                <ls_list>-netpr = ls_info-netpr.
                <ls_list>-waers = ls_info-waers.
                <ls_list>-peinh   = ls_info-peinh .
                <ls_list>-mwskz = ls_info-mwskz.
                <ls_list>-idnlf = ls_info-idnlf.
                <ls_list>-infnr = ls_info-infnr.
              ENDIF.

            ELSE.
              SELECT SINGLE kbetr AS netpr, kpein AS peinh,
                                       konwa AS waers,
                                       mwskz, infnr
                   FROM zgtmm_cv_get_infoprice
                   WHERE lifnr  = @<ls_list>-lifnr
                        AND matnr = @<ls_list>-matnr
                        AND esokz = @<ls_list>-pstyp
                        AND ekorg = @<ls_list>-ekorg
                        AND werks = @<ls_list>-werks
*                        AND DATAB <= @<LS_LIST>-EINDT
*                        AND DATBI >= @<LS_LIST>-EINDT INTO @DATA(LS_INFO2).
                        AND datab <= @sy-datum
                        AND datbi >= @sy-datum INTO @DATA(ls_info2).

              IF ls_info2 IS INITIAL.
                CLEAR : <ls_list>-netpr, <ls_list>-waers, <ls_list>-peinh,
                             <ls_list>-infnr, <ls_list>-idnlf, <ls_list>-mwskz , <ls_list>-netpr_i,
                             <ls_list>-waers_i, <ls_list>-peinh_i .", <LS_LIST>-MWSKZ_I.
              ELSE.
                <ls_list>-netpr_i = ls_info2-netpr.
                <ls_list>-waers_i = ls_info2-waers.
                <ls_list>-peinh_i   = ls_info2-peinh .
*                <LS_LIST>-MWSKZ_I = LS_INFO2-MWSKZ.
                <ls_list>-netpr = ls_info2-netpr.
                <ls_list>-waers = ls_info2-waers.
                <ls_list>-peinh   = ls_info2-peinh .
                <ls_list>-mwskz = ls_info2-mwskz.
                <ls_list>-idnlf = ls_info-idnlf.
                <ls_list>-infnr = ls_info-infnr.
              ENDIF.
            ENDIF.
*색상/띠줄색상/띠줄수 정보_자재 변경 시에만...
            IF   ls_mod_cells-fieldname = 'MATNR'.
              IF ls_mod_cells-value IS INITIAL.
                CLEAR : <ls_list>-color, <ls_list>-stripe_color, <ls_list>-stripe_no,
                             <ls_list>-zdgno, <ls_list>-zrevno, <ls_list>-drmatnr.

              ELSE.
                DATA(lv_matnr) = CONV matnr( ls_mod_cells-value ).

                SELECT atnam, atwrt
                  FROM zgtsd_i_materialcharacteristic
                  WHERE matnr = @lv_matnr
                  INTO TABLE @DATA(lt_char).

                SORT lt_char BY atnam.

                IF lt_char[] IS NOT INITIAL.
*                     색상
                  READ TABLE lt_char ASSIGNING FIELD-SYMBOL(<ch>)
                  WITH KEY atnam = 'PD_CA_COLOR_BASE' BINARY SEARCH. " 색상
                  IF sy-subrc = 0.
                    <ls_list>-color = <ch>-atwrt.
                  ENDIF.
*                     띠줄색상
                  READ TABLE lt_char ASSIGNING FIELD-SYMBOL(<chc>)
                  WITH KEY atnam = 'PD_CA_COLOR_STRIPE' BINARY SEARCH. " 띠줄색상
                  IF sy-subrc = 0.
                    <ls_list>-stripe_color = <chc>-atwrt.
                  ENDIF.
*                     띠줄수
                  READ TABLE lt_char ASSIGNING FIELD-SYMBOL(<chn>)
                  WITH KEY atnam = 'PD_CA_COLOR_STRIPE_NO' BINARY SEARCH. " 띠줄수
                  IF sy-subrc = 0.
                    <ls_list>-stripe_no = <chn>-atwrt.
                  ENDIF.

*                     SPEC_NO
                  READ TABLE lt_char ASSIGNING FIELD-SYMBOL(<chp>)
                  WITH KEY atnam = 'PD_CA_SPEC_NO' BINARY SEARCH. " SPEC_NO
                  IF sy-subrc = 0.
                    <ls_list>-specno = <chp>-atwrt.
                  ENDIF.

*                  설계번호
                  READ TABLE lt_char ASSIGNING FIELD-SYMBOL(<chd>)
                  WITH KEY atnam =  'PD_CA_DESIGN_NO' BINARY SEARCH. " ZDGNO
                  IF sy-subrc = 0.
                    <ls_list>-zdgno = <chd>-atwrt.
                  ENDIF.

*                  개정번호
                  READ TABLE lt_char ASSIGNING FIELD-SYMBOL(<chr>)
                  WITH KEY atnam =  'PD_CA_DESIGN_REV_NO' BINARY SEARCH. " ZREVNO
                  IF sy-subrc = 0.
                    <ls_list>-zrevno = <chr>-atwrt.
                  ENDIF.

                ENDIF.
*자재번호/설계번호/개정번호/조장 변동되면, 목드럼 자재코드 조회 수행
                SELECT SINGLE dpcbt
                  FROM marc
                  WHERE werks = @<ls_list>-werks
                       AND matnr = @<ls_list>-matnr
                  INTO @DATA(lv_dpcbt).

                IF lv_dpcbt = 'C' AND <ls_list>-length NE 0."FACTOR BATCH 자재인 경우에만 수행

                  lv_jakno = ''. "고객그룹코드
                  DATA(lv_int) = CONV i( trunc( <ls_list>-length ) ). "조장_소숫점 버림
                  WRITE lv_int TO lv_length RIGHT-JUSTIFIED.
                  TRY.
                      CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
                        EXPORTING
                          iv_sul_no    = <ls_list>-zdgno
                          iv_rev_seq   = <ls_list>-zrevno
                          iv_jakno     = lv_jakno
                          iv_jojang    = lv_length
                          iv_drum_code = 'H'
                          iv_flag_pp   = 'X'
                        TABLES
                          ot_return    = lt_drum.
                    CATCH cx_root INTO DATA(lv_error).
                      lv_msg = lv_error->get_text( ).
                      MESSAGE s000 WITH lv_msg.
                  ENDTRY.

                  IF lt_drum IS NOT INITIAL.
                    READ TABLE lt_drum ASSIGNING FIELD-SYMBOL(<drum>) INDEX 2.
                    IF sy-subrc = 0.
                      <ls_list>-drmatnr = <drum>-drum_matnr.
                      <ls_list>-drumname = <drum>-maktx.
                    ENDIF.
                  ENDIF.
                ENDIF.

              ENDIF.

            ENDIF.

            gv_ch_style = gc_x.

          WHEN 'KNTTP' .
            gv_ch_style = gc_x.

          WHEN 'MTART' .
            gv_ch_style = gc_x.

          WHEN 'VBELN' OR 'VBELP'.
            SELECT SINGLE  kwmeng , vrkme, length, drqty, mcontents
            FROM zgtmm_cv_so_vcvalue_main
            WHERE vbeln = @<ls_list>-vbeln AND posnr = @<ls_list>-vbelp
            INTO @DATA(ls_ct).

            <ls_list>-menge = ls_ct-kwmeng.
            <ls_list>-meins = ls_ct-vrkme.
            <ls_list>-length = ls_ct-length.
            <ls_list>-drqty = ls_ct-drqty.
            <ls_list>-mcontents = ls_ct-mcontents.

            IF <ls_list>-vbeln IS INITIAL OR <ls_list>-vbelp IS INITIAL.
              CLEAR : <ls_list>-mcontents, <ls_list>-zmemo_s.
            ELSE.
              CLEAR : lt_lines, lv_line, lv_name.
              lv_name = <ls_list>-vbeln && <ls_list>-vbelp.

              CALL FUNCTION 'READ_TEXT'
                EXPORTING
                  id        = '0001' "품목텍스트
                  language  = sy-langu
                  name      = lv_name
                  object    = 'VBBP'
                TABLES
                  lines     = lt_lines
                EXCEPTIONS
                  not_found = 4.

              IF sy-subrc = 0 AND  lt_lines[] IS NOT INITIAL.
                LOOP AT lt_lines  INTO DATA(ls_l).
                  lv_line &&= ls_l-tdline.
                  AT LAST.
                    lv_line &&= ' '.
                  ENDAT.
                ENDLOOP.

                <ls_list>-zmemo_s = lv_line.
              ENDIF.
            ENDIF.
            gv_ch_style = gc_x.

          WHEN 'DRMATNR'.
            SELECT SINGLE maktx
              FROM makt
              WHERE matnr = @<ls_list>-drmatnr
                   AND spras = @sy-langu
              INTO @<ls_list>-drumname.

            gv_ch_style = gc_x.

          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.

      IF gv_ch_style = gc_x AND p_cre = gc_x.
        PERFORM set_cell_style USING 'CRE'.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

  PERFORM refresh_table USING po_sender space.

  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = 'ENTER'.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CELL_STYLE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_cell_style USING pv_gb.

  DATA : ls_style TYPE lvc_s_styl.

  DEFINE _set_style.

    ls_style-fieldname = &2.
    CASE &1.
      WHEN 'E'.
        ls_style-style = cl_gui_alv_grid=>mc_style_enabled.
      WHEN 'D'.
        ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
    ENDCASE.
    INSERT ls_style INTO TABLE &3.

  END-OF-DEFINITION.

  IF sy-tcode = 'ZGTMMR3000'.
    gcl_grid->set_ready_for_input( 1 ). "입력가능
  ELSE.
    gcl_grid_400->set_ready_for_input( 1 ). "입력가능
  ENDIF.


  CASE pv_gb.
    WHEN 'PR'.
*청구량/PR기준
      LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<ls_list>).
        CLEAR : <ls_list>-style[].

        _set_style : gc_e 'INSMK' <ls_list>-style,"ENABLED
                              gc_e 'EMLIF' <ls_list>-style,
                              gc_e 'FLIEF' <ls_list>-style.
*                              GC_E 'WAERS' <LS_LIST>-STYLE,
*                              GC_E 'PEINH' <LS_LIST>-STYLE,
*                              GC_E 'MWSKZ' <LS_LIST>-STYLE,
*                              GC_E 'PREIS' <LS_LIST>-STYLE.

        IF <ls_list>-ekgrp  = 'Z32'.
          IF <ls_list>-mtart = 'MCFE'  OR <ls_list>-mtart = 'MCHA' OR <ls_list>-mtart = 'HAWA'.
            IF <ls_list>-estkz = gc_v AND <ls_list>-preis_p > 0 .
              _set_style : gc_d 'FLIEF ' <ls_list>-style. "DISABLEDREFRESH_TABLE

            ELSE.
              _set_style : gc_e 'FLIEF ' <ls_list>-style. "DISABLEDREFRESH_TABLE
            ENDIF.

            _set_style : gc_d 'PREIS ' <ls_list>-style, "DISABLEDREFRESH_TABLE
                                   gc_d 'PEINH' <ls_list>-style,
                                   gc_d 'WAERS' <ls_list>-style,
*                                  GC_D 'MWSKZ' <LS_LIST>-STYLE,
                                   gc_d 'UEBTO' <ls_list>-style.
          ELSE.
            _set_style : gc_e 'PREIS ' <ls_list>-style,
                                  gc_e 'PEINH' <ls_list>-style,
                                  gc_e 'WAERS' <ls_list>-style.
*                                  GC_E 'MWSKZ' <LS_LIST>-STYLE.
          ENDIF.
        ELSE.
          _set_style : gc_e 'PREIS ' <ls_list>-style,
                                gc_e 'PEINH' <ls_list>-style,
                                gc_e 'WAERS' <ls_list>-style.
*                                GC_E 'MWSKZ' <LS_LIST>-STYLE.

        ENDIF.

        IF <ls_list>-estkz  = 'V'.
          _set_style  gc_d 'MENGE_I' <ls_list>-style."DISABLE
        ENDIF.

      ENDLOOP.

    WHEN 'CRE'.
*직접생성
      LOOP AT gt_create ASSIGNING FIELD-SYMBOL(<fs>).
        CLEAR : <fs>-style[].

        _set_style : gc_e 'LIFNR' <fs>-style,"ENABLED
                              gc_e 'MATNR' <fs>-style,
                              gc_e 'LGORT' <fs>-style,
                              gc_e 'EMLIF' <fs>-style,
                              gc_e 'MENGE' <fs>-style,
*                              GC_E 'MEINS' <FS>-STYLE,
*                              GC_E 'NETPR' <FS>-STYLE,
*                              GC_E 'PEINH' <FS>-STYLE,
*                              GC_E 'WAERS' <FS>-STYLE,
*                              GC_E 'MWSKZ' <FS>-STYLE,
                              gc_e 'EINDT' <fs>-style,
                              gc_e 'INSMK' <fs>-style,
                              gc_e 'ZMEMO' <fs>-style,
                              gc_e 'UEBTO' <fs>-style,
                              gc_e 'RETPO' <fs>-style,
                              gc_e 'ZFREE' <fs>-style,
                              gc_e 'KNTTP' <fs>-style,
                              gc_e 'PSTYP' <fs>-style.

        IF <fs>-dpcbt IS INITIAL.
          _set_style : gc_d 'LENGTH' <fs>-style, "DISABLEDREFRESH_TABLE
                                gc_d 'DRQTY' <fs>-style.
        ELSE.
          _set_style : gc_e 'LENGTH' <fs>-style,
                                gc_e 'DRQTY' <fs>-style.
        ENDIF.

        IF  <fs>-knttp IS NOT INITIAL.
          _set_style : gc_e 'ABLAD' <fs>-style.

          IF <fs>-matnr IS INITIAL.
            _set_style : gc_e 'MATKL' <fs>-style.
          ELSE.
            _set_style : gc_d 'MATKL' <fs>-style. "DISABLED
          ENDIF.

        ELSE.
          _set_style : gc_d 'ABLAD' <fs>-style.
          _set_style : gc_d 'MATKL' <fs>-style. "DISABLED
        ENDIF.

*        IF <FS>-MATNR IS INITIAL AND <FS>-KNTTP IS NOT INITIAL.
*          _SET_STYLE : GC_E 'MATKL' <FS>-STYLE.
*        ELSE.
*          _SET_STYLE : GC_D 'MATKL' <FS>-STYLE. "DISABLED
*        ENDIF.

        IF <fs>-ekgrp  = 'Z32'.
          IF <fs>-mtart = 'MCFE'  OR <fs>-mtart = 'MCHA'.
            _set_style : gc_d 'NETPR' <fs>-style, "DISABLEDREFRESH_TABLE
                                  gc_d 'PEINH' <fs>-style,
                                  gc_d 'WAERS' <fs>-style,
                                  gc_d 'MWSKZ' <fs>-style.
          ELSE.
            _set_style : gc_e 'NETPR' <fs>-style, "DISABLEDREFRESH_TABLE
                                  gc_e 'PEINH' <fs>-style,
                                  gc_e 'WAERS' <fs>-style,
                                  gc_e 'MWSKZ' <fs>-style.
          ENDIF.
        ELSE.
          _set_style : gc_e 'NETPR' <fs>-style, "DISABLEDREFRESH_TABLE
                                gc_e 'PEINH' <fs>-style,
                                gc_e 'WAERS' <fs>-style,
                                gc_e 'MWSKZ' <fs>-style.

        ENDIF.


        CASE <fs>-knttp. "계정지정범주에 따른 입력필드 제어
          WHEN gc_m.
            CLEAR : <fs>-kostl, <fs>-sakto, <fs>-anln1,
                         <fs>-anln2,  <fs>-aufnr.

            _set_style : gc_e 'VBELN' <fs>-style, "ENABLED
                                  gc_e 'VBELP' <fs>-style.
            _set_style : gc_d 'KOSTL' <fs>-style, "DISABLED
                                  gc_d 'SAKTO' <fs>-style,
                                  gc_d 'ANLN1' <fs>-style,
                                  gc_d 'ANLN2' <fs>-style,
                                  gc_d 'PS_PSP_PNR' <fs>-style,
                                  gc_d 'AUFNR' <fs>-style.

          WHEN gc_k.
            CLEAR : <fs>-vbeln, <fs>-vbelp, <fs>-anln1,
                         <fs>-anln2, <fs>-aufnr.

            _set_style : gc_e 'SAKTO' <fs>-style, "ENABLED
                                  gc_e 'KOSTL' <fs>-style.
            _set_style : gc_d 'VBELN' <fs>-style, "DISABLED
                                  gc_d 'VBELP' <fs>-style,
                                  gc_d 'ANLN1' <fs>-style,
                                  gc_d 'ANLN2' <fs>-style,
                                  gc_d 'PS_PSP_PNR' <fs>-style,
                                  gc_d 'AUFNR' <fs>-style.

          WHEN gc_a.
            CLEAR : <fs>-kostl, <fs>-sakto, <fs>-vbeln,
                         <fs>-vbelp,  <fs>-aufnr.

            _set_style : gc_e 'ANLN1' <fs>-style, "ENABLED
                                  gc_e 'ANLN2' <fs>-style.
            _set_style : gc_d 'KOSTL' <fs>-style, "DISABLED
                                  gc_d 'VBELN' <fs>-style,
                                  gc_d 'VBELP' <fs>-style,
                                  gc_d 'SAKTO' <fs>-style,
                                  gc_d 'PS_PSP_PNR' <fs>-style,
                                  gc_d 'AUFNR' <fs>-style.

          WHEN gc_p.
            CLEAR : <fs>-kostl, <fs>-vbeln, <fs>-anln1,
                         <fs>-anln2, <fs>-vbelp, <fs>-aufnr.

            _set_style : gc_e 'SAKTO' <fs>-style, "ENABLED
                                  gc_e 'PS_PSP_PNR' <fs>-style.
            _set_style : gc_d 'KOSTL' <fs>-style, "DISABLED
                                  gc_d 'ANLN1' <fs>-style,
                                  gc_d 'ANLN2' <fs>-style,
                                  gc_d 'VBELN' <fs>-style,
                                  gc_d 'VBELP' <fs>-style,
                                  gc_d 'AUFNR' <fs>-style.

          WHEN gc_f.
            CLEAR : <fs>-kostl, <fs>-vbeln, <fs>-anln1,
                         <fs>-anln2, <fs>-vbelp.

            _set_style : gc_e 'SAKTO' <fs>-style, "ENABLED
                                  gc_e 'AUFNR' <fs>-style.
            _set_style : gc_d 'KOSTL' <fs>-style, "DISABLED
                                  gc_d 'VBELN' <fs>-style,
                                  gc_d 'VBELP' <fs>-style,
                                  gc_d 'ANLN1' <fs>-style,
                                  gc_d 'PS_PSP_PNR' <fs>-style,
                                  gc_d 'ANLN2' <fs>-style.

          WHEN OTHERS.
            _set_style : gc_d 'KOSTL' <fs>-style, "DISABLED
                                  gc_d 'VBELN' <fs>-style,
                                  gc_d 'VBELP' <fs>-style,
                                  gc_d 'ANLN1' <fs>-style,
                                  gc_d 'PS_PSP_PNR' <fs>-style,
                                  gc_d 'ANLN2' <fs>-style,
                                  gc_d 'SAKTO' <fs>-style, "ENABLED
                                  gc_d 'AUFNR' <fs>-style.

        ENDCASE.

      ENDLOOP.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.

**&---------------------------------------------------------------------*
**& FORM SET_CELL_COLOR
**&---------------------------------------------------------------------*
**& TEXT
**&---------------------------------------------------------------------*
*FORM SET_CELL_COLOR .
*
*  DATA : LS_COLOR TYPE    LVC_S_SCOL.
*
**  DEFINE _SET_COLOR.
**
**    LS_COLOR-FNAME = &1.
**    LS_COLOR-COLOR-COL = &2.
**    LS_COLOR-COLOR-INT  = &3
**    INSERT LS_STYLE INTO TABLE &4.
**
**  END-OF-DEFINITION.
*
*  LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>).
*
*    CLEAR : <LS_LIST>-COLO[].
*
**입고상태
*    LS_COLOR-FNAME = GC_ZGRSTATUS.
*    LS_COLOR-COLOR-COL = COND #( WHEN <LS_LIST>-ZGRSTATUS_C = GC_C
*                                                           THEN '6'
*                                                           WHEN <LS_LIST>-ZGRSTATUS_C = GC_D
*                                                           THEN '7' ELSE '0' ).
*    LS_COLOR-COLOR-INT   = '1'.
*    INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.
*
**정산상태
*    CLEAR LS_COLOR.
*
*    CASE <LS_LIST>-ZIVSTATUS_C.
*      WHEN GC_A OR GC_E.
*        LS_COLOR-FNAME = GC_ZIVSTATUS.
*        LS_COLOR-COLOR-COL = '6'.
*        LS_COLOR-COLOR-INT   = '1'.
*        INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.
*
*      WHEN GC_C OR GC_D.
*        LS_COLOR-FNAME = GC_ZIVSTATUS.
*        LS_COLOR-COLOR-COL = '7'.
*        LS_COLOR-COLOR-INT   = '1'.
*        INSERT LS_COLOR INTO TABLE <LS_LIST>-COLO.
*      WHEN OTHERS.
*    ENDCASE.
*
*  ENDLOOP.
*
*ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_FIELDCAT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_alv_fieldcat.

  DATA :
    lr_tabdescr TYPE REF TO cl_abap_structdescr,
    lt_dfies    TYPE ddfields,
    ls_dfies    TYPE dfies,
    lt_fcat     TYPE lvc_t_fcat,
    ls_fcat     TYPE lvc_s_fcat.

  DATA : gr_dref  TYPE REF TO data.

  CLEAR gr_dref.
**--> 26.09 *단순견적 - 추가
  IF p_pr = gc_x OR p_pr2 = gc_x.
    CREATE DATA gr_dref LIKE gs_list.
  ELSE.
    CREATE DATA gr_dref LIKE gs_create.
  ENDIF.

  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( gr_dref ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ) .

  REFRESH : lt_fcat.

  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR : ls_fcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fcat.
    APPEND ls_fcat TO lt_fcat.
  ENDLOOP.

*  " 필드 카탈로그 변경사항 적용
**--> 26.09 *단순견적 - 추가
  IF p_pr = gc_x OR p_pr2 = gc_x. "조회및변경
    IF sy-tcode = 'ZGTMMR3000'.
      PERFORM adjust_fldcats TABLES lt_fcat.
    ELSE.
      PERFORM adjust_fldcats_400 TABLES lt_fcat.
    ENDIF.

  ELSE. "직접생성
    IF sy-tcode = 'ZGTMMR3000'.
      PERFORM  adjust_fldcats_cre TABLES lt_fcat.
    ELSE.
      PERFORM adjust_fldcats_cre_400 TABLES lt_fcat.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV_400
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM create_alv_400 .

  PERFORM :
            set_container,
            set_alv_grid,
            set_alv_fieldcat,
            set_alv_layout,
            set_cell_color,
            set_alv_toolbar,
            set_alv_sort,
            set_event        CHANGING gcl_event gcl_grid_400.

**--> 26.09 *단순견적 - 추가
  IF p_pr = gc_x OR p_pr2 = gc_x.
    PERFORM display_alv TABLES gt_list gt_fcat_400 CHANGING gcl_grid_400.
  ELSE.
    PERFORM display_alv TABLES gt_create gt_fcat_cre_400 CHANGING gcl_grid_400.
  ENDIF.

* DRQTY(드럼수) 소수점 제거:
* SET_TABLE_FOR_FIRST_DISPLAY 내부의 LVC_FIELDCATALOG_COMPLETE가
* QUAN 타입 기준으로 DECIMALS를 재설정하므로, 완료 후 프론트엔드 FCAT 직접 수정
  PERFORM fix_drqty_decimals USING gcl_grid_400.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_top_of_page .

*  DATA :
*         LV_TXT   TYPE C LENGTH 10,
*         LV_TXT2  TYPE C LENGTH 10,
*         LV_FROM TYPE C LENGTH 5,
*         LV_TO      TYPE C LENGTH 5.
*
*
*  CALL METHOD GCL_CL_DD->INITIALIZE_DOCUMENT
*    EXPORTING
*      BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA.

  " ADD TEXT
*  GCL_CL_DD->ADD_TEXT( TEXT = |플랜트　:　{ P_WERKS }({ GV_LINE })|
*                       SAP_EMPHASIS = CL_DD_AREA=>HEADING ).

*  IF S_BUDAT[] IS NOT INITIAL.
*    READ TABLE S_BUDAT INDEX 1.
*    WRITE S_BUDAT-LOW TO LV_TXT.
*    WRITE S_BUDAT-HIGH TO LV_TXT2.
*
*    " ADD NEW-LINE
*    GCL_CL_DD->NEW_LINE( ).
*    " ADD TEXT
*    IF S_BUDAT-HIGH IS INITIAL.
*      GCL_CL_DD->ADD_TEXT( TEXT = |입금일자　:　{ LV_TXT }|
*                           SAP_EMPHASIS = CL_DD_AREA=>HEADING ).
*    ELSE.
*      GCL_CL_DD->ADD_TEXT( TEXT = |입금일자　:　{ LV_TXT } ~ { LV_TXT2 }|
*                           SAP_EMPHASIS = CL_DD_AREA=>HEADING ).
*    ENDIF.
*  ENDIF.

*  GCL_CL_DD->DISPLAY_DOCUMENT( EXPORTING  REUSE_CONTROL = ZGTFI_X
*                                          PARENT        = GCL_CON_TOP
*                               EXCEPTIONS HTML_DISPLAY_ERROR = 1 ).


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM toolbar  USING pr_obj TYPE REF TO cl_alv_event_toolbar_set
                                     po_sender.

  DATA : ls_tbar TYPE stb_button.

  DEFINE _set_tbar.
    CLEAR : ls_tbar.

    ls_tbar-butn_type = &1.
    ls_tbar-function   = &2.
    ls_tbar-icon           = &3.
    ls_tbar-text          = &4.
    ls_tbar-quickinfo = &4.

    APPEND ls_tbar TO pr_obj->mt_toolbar.
  END-OF-DEFINITION.


  CASE po_sender.

    WHEN gcl_grid.
**--> 26.09 *단순견적 - 추가
      IF p_pr = gc_x OR p_pr2 = gc_x .

        _set_tbar 3 '    ' '              ' '    '.
        _set_tbar 0 'REFRESH' icon_refresh 'REFRESH'(b01).
        _set_tbar 0 'CLOSE'  icon_close   'CLOSE'(b02).
        _set_tbar 0 'CHANGE' icon_rename '구매그룹변경'(b03).
        _set_tbar 0 'MASS' icon_mass_change  '업체일괄입력'(b12).
        _set_tbar 0 'REQUEST' icon_mail  '견적요청'(b05).
        _set_tbar 0 'PO' icon_system_save  '구매오더전환'(b06).
        _set_tbar 0 'MOKDR' icon_bom_item  '목드럼소요량생성'(b07).

      ELSE.

        _set_tbar 3 '    ' '              ' '    '.
        _set_tbar 0 'DEL' icon_delete '삭제'(b13).
        _set_tbar 0 'CREATE' icon_system_save 'PO생성'(b08).
        _set_tbar 0 'REFRESH' icon_refresh 'REFRESH'(b01).
        _set_tbar 0 'TEMP'  icon_trend_down   'TEMPLATE'(b09).
        _set_tbar 0 'UPLOAD' icon_trend_up  'EXCEL UPLOAD'(b10).
        _set_tbar 0 'ME21N' icon_create  'ME21N'(b11).
*        _SET_TBAR 0 'APP_REQ' ''  '승인요청'(B04).

      ENDIF.

    WHEN gcl_grid_400.
**--> 26.09 *단순견적 - 추가
      IF p_pr = gc_x OR p_pr2 = gc_x .

        _set_tbar 3 '    ' '              ' '    '.
        _set_tbar 0 'REFRESH' icon_refresh 'REFRESH'(b01).
        _set_tbar 0 'LINK'  icon_close   '링크요청'(b14).
        _set_tbar 0 'CHANGE' icon_rename '구매그룹변경'(b03).
        _set_tbar 0 'MASS' icon_mass_change  '업체일괄입력'(b12).
        _set_tbar 0 'REQUEST' icon_mail  '견적요청'(b05).
        _set_tbar 0 'PO' icon_system_save  '구매오더전환'(b06).

      ELSE.

        _set_tbar 3 '    ' '              ' '    '.
        _set_tbar 0 'DEL' icon_delete '삭제'(b13).
        _set_tbar 0 'CREATE' icon_system_save 'PO생성'(b08).
        _set_tbar 0 'REFRESH' icon_refresh 'REFRESH'(b01).
        _set_tbar 0 'TEMP'  icon_trend_down   'TEMPLATE'(b09).
        _set_tbar 0 'UPLOAD' icon_trend_up  'EXCEL UPLOAD'(b10).
        _set_tbar 0 'ME21N' icon_create  'ME21N'(b11).
*        _SET_TBAR 0 'APP_REQ' ''  '승인요청'(B04).

      ENDIF.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM USER_COMMAND
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM user_command  USING pv_ucomm LIKE sy-ucomm
                                          po_sender.

  CLEAR gv_ucomm.
  gv_ucomm = pv_ucomm.

  CASE pv_ucomm.
    WHEN 'REFRESH'.
**--> 26.09 *단순견적 - 추가
      IF p_pr = gc_x OR p_pr2 = gc_x.
        PERFORM get_data.
      ELSE.
        PERFORM set_create_data.
      ENDIF.

    WHEN 'CLOSE'.
      PERFORM pr_finish_data .

    WHEN 'LINK'.
      PERFORM pr_link_change_data .

    WHEN 'CHANGE' OR 'MASS'.
      PERFORM change_ekorg_lifnr.
      IF pv_ucomm = 'CHANGE'.
        PERFORM get_data.
      ENDIF.

    WHEN 'REQUEST'.
      PERFORM request_data.
      PERFORM get_data.

    WHEN 'PO'.
      PERFORM conv_po.

    WHEN 'MOKDR' .
      PERFORM create_drum_consumption.
      PERFORM get_data.

    WHEN 'CREATE'.
      PERFORM create_po.

    WHEN 'TEMP' .
*UPLOAD TEMPLATE: EXEL 업로드 양식 다운로드
      PERFORM template_download USING gc_zgtmmr3000 .

    WHEN 'UPLOAD'  .
      PERFORM excel_upload.

    WHEN 'DEL'.
      PERFORM delete_data.

    WHEN 'ME21N'  .
      CALL TRANSACTION 'ME21N'.

    WHEN 'APP_REQ'  .
      PERFORM approval_request.

    WHEN OTHERS.
  ENDCASE.

  IF sy-tcode = 'ZGTMMR3000'.
    PERFORM refresh_table USING gcl_grid space.
  ELSE.
    PERFORM refresh_table USING gcl_grid_400 space.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DATA_CHANGED
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM data_changed  USING  po_data_changed
                                     TYPE REF TO cl_alv_changed_data_protocol
                                                po_sender.

  CASE po_sender.

    WHEN gcl_grid.
**--> 26.09 *단순견적 - 추가
      IF p_pr = gc_x OR p_pr2 = gc_x.
        PERFORM data_changed_1 USING po_data_changed.
      ELSE.
        PERFORM data_changed_2 USING po_data_changed.
      ENDIF.

    WHEN gcl_grid_400.
**--> 26.09 *단순견적 - 추가
      IF p_pr = gc_x OR p_pr2 = gc_x.
        PERFORM data_changed_1 USING po_data_changed.
      ELSE.
        PERFORM data_changed_2 USING po_data_changed.
      ENDIF.

    WHEN OTHERS.
      EXIT.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      FORM  DATA_CHANGED_1
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*      -->P_PO_DATA_CHANGED  TEXT
*----------------------------------------------------------------------*
FORM data_changed_1 USING po_data_changed
                                       TYPE REF TO cl_alv_changed_data_protocol.

  DATA : lv_err   TYPE char1.
  DATA : lv_length TYPE zlength,
         lv_drqty  TYPE p DECIMALS 7.
  CLEAR : gv_auto_change.

  LOOP AT po_data_changed->mt_good_cells INTO DATA(ls_mod_cells).

    READ TABLE gt_list  INTO DATA(ls_list) INDEX ls_mod_cells-row_id.
    CHECK sy-subrc EQ 0.

    CASE ls_mod_cells-fieldname.

      WHEN 'INSMK'. "재고유형
        READ TABLE gt_insmk INTO DATA(ls_d)
        WITH KEY domvalue_l = ls_mod_cells-value BINARY SEARCH.

        IF sy-subrc = 0.
          PERFORM modify_cell USING po_data_changed 'INSMK'
                                                ls_mod_cells-value ls_mod_cells-row_id.
          ls_list-insmk_n = ls_d-ddtext.
        ELSE.
          lv_err = gc_x.
          PERFORM add_entry USING po_data_changed 'FLIEF'
                                                       ls_mod_cells-row_id.
          CLEAR : ls_list-insmk, ls_list-insmk_n.
        ENDIF.

      WHEN 'EMLIF' OR 'FLIEF'.
        IF ls_mod_cells-value IS INITIAL.
          IF ls_mod_cells-fieldname = 'EMLIF'.
            PERFORM modify_cell USING po_data_changed 'EMLIF'
                                                  ls_mod_cells-value ls_mod_cells-row_id.
            ls_list-scvname = ls_mod_cells-value.

          ELSEIF ls_mod_cells-fieldname = 'FLIEF'.
            PERFORM modify_cell USING po_data_changed 'FLIEF'
                                                  ls_mod_cells-value ls_mod_cells-row_id.
            ls_list-flief_n = ls_mod_cells-value.

          ENDIF.

        ELSE.
          SELECT SINGLE lifnr, name1
             FROM lfa1
             WHERE lifnr = @ls_mod_cells-value INTO @DATA(ls_lf).

          IF ls_lf IS INITIAL.
            lv_err = gc_x.
            IF ls_mod_cells-fieldname = 'EMLIF'.
              PERFORM add_entry USING po_data_changed 'EMLIF'
                                                 ls_mod_cells-row_id.
            ELSEIF ls_mod_cells-fieldname = 'FLIEF'.
              PERFORM add_entry USING po_data_changed 'FLIEF'
                                                   ls_mod_cells-row_id.
            ENDIF.

          ELSE.
            IF ls_mod_cells-fieldname = 'EMLIF'.
              PERFORM modify_cell USING po_data_changed 'EMLIF'
                                                    ls_mod_cells-value ls_mod_cells-row_id.
              ls_list-scvname = ls_lf-name1.

            ELSEIF ls_mod_cells-fieldname = 'FLIEF'.
              PERFORM modify_cell USING po_data_changed 'FLIEF'
                                                    ls_mod_cells-value ls_mod_cells-row_id.
              ls_list-flief_n = ls_lf-name1.
            ENDIF.
          ENDIF.
*임가공직납업체 입력 시 임가공 지시자 'X', 미입력 시 클리어.
          IF ls_mod_cells-fieldname = 'EMLIF' AND ls_mod_cells-value IS INITIAL.
            ls_list-lblkz = ls_mod_cells-value.
          ELSEIF ls_mod_cells-fieldname = 'EMLIF' AND ls_mod_cells-value IS NOT INITIAL.
            ls_list-lblkz = gc_x.
          ENDIF.
        ENDIF.
*고정공급업체 입력 시 단가테이블의 단가/통화/PER/업체자재코드/TAX 입력, 미입력 시 클리어.
        IF ls_mod_cells-fieldname = 'FLIEF' AND ls_mod_cells-value IS INITIAL.
          CLEAR : ls_list-preis, ls_list-waers, ls_list-peinh,
                       ls_list-preis_i, ls_list-waers_i, ls_list-peinh_i,
                       ls_list-mwskz, ls_list-mwskz_i , ls_list-idnlf.
*          LS_LIST-PREIS = LS_MOD_CELLS-VALUE.

          IF  ls_list-ekgrp = 'Z32' AND ( ls_list-mtart = 'MCFE' OR ls_list-mtart = 'MCHA'  OR ls_list-mtart = 'HAWA'  )  AND  ls_list-estkz = gc_v AND  ls_list-preis_p > 0.
            ls_list-preis   = ls_list-preis_p. " PR단가로..
            ls_list-mwskz = ls_list-mwskz_p ."PR TAX로..
            ls_list-waers = ls_list-waers_p.
            ls_list-peinh   = ls_list-peinh_p.
          ENDIF.

*납품요청일 기준 유효한 계약 건수
          SELECT SINGLE conqty
*          FROM ZGTMM_CV_GET_INFOPRICE_M( P_DATE = @LS_LIST-LFDAT )
          FROM zgtmm_cv_get_infoprice_m( p_date = @sy-datum )
          WHERE matnr = @ls_list-matnr
              AND ekorg = @ls_list-ekorg
              AND werks = @ls_list-werks
              AND esokz = @ls_list-pstyp
              INTO @ls_list-conqty.
          PERFORM modify_cell USING po_data_changed 'CONQTY'
                                                ls_list-conqty ls_mod_cells-row_id.

        ELSEIF ls_mod_cells-fieldname = 'FLIEF' AND ls_mod_cells-value IS NOT INITIAL.

          IF  ls_list-ekgrp = 'Z32' AND ( ls_list-mtart = 'MCFE' OR ls_list-mtart = 'MCHA'  OR ls_list-mtart = 'HAWA'  )  AND  ls_list-estkz = gc_v AND  ls_list-preis_p > 0.
            ls_list-preis   = ls_list-preis_p. "INFO없으면 PR단가로..
            ls_list-mwskz =  ls_list-mwskz_p . "INFO없으면 PR TAX로..
            ls_list-waers = ls_list-waers_p.
            ls_list-peinh   = ls_list-peinh_p.

          ELSE.
*단가/통화/PER/업체자재코드/TAX
            READ TABLE gt_info INTO DATA(ls_info) WITH KEY matnr = ls_list-matnr
                                                                                             lifnr   = ls_mod_cells-value
                                                                                             esokz = ls_list-pstyp BINARY SEARCH.
            IF sy-subrc = 0.
              ls_list-preis  = ls_list-preis_i  = ls_info-kbetr.
              ls_list-waers = ls_list-waers_i = ls_info-konwa.
              ls_list-peinh   = ls_list-peinh_i   = ls_info-kpein .
              ls_list-idnlf   = ls_info-idnlf.
              ls_list-mwskz = ls_info-mwskz.
              ls_list-mwskz_i = COND #( WHEN sy-tcode = 'ZGTMMR3000' THEN ls_info-mwskz
                                                            ELSE ls_list-mwskz_i ) .
            ELSE.
              SELECT SINGLE kbetr AS preis, konwa AS waers,
                                       kpein AS peinh, idnlf, mwskz
                            FROM zgtmm_cv_get_infoprice
                          WHERE ekorg = @ls_list-ekorg
                               AND werks = @ls_list-werks
                               AND matnr = @ls_list-matnr
                               AND lifnr   = @ls_mod_cells-value
                               AND esokz = @ls_list-pstyp
*                              AND DATAB <= @LS_LIST-LFDAT
*                              AND DATBI >= @LS_LIST-LFDAT
                               AND datab <= @sy-datum
                               AND datbi >= @sy-datum
                               INTO @DATA(ls_info2).

              IF ls_info2 IS INITIAL.
                CLEAR : ls_list-idnlf.
                IF  ls_list-ekgrp = 'Z32' AND ( ls_list-mtart = 'MCFE' OR ls_list-mtart = 'MCHA'  )  AND  ls_list-preis_p = 0.
                ELSE.
                  ls_list-preis   = ls_list-preis_p. "INFO없으면 PR단가로..
                  ls_list-mwskz = ls_list-mwskz_p.  "INFO없으면 PR TAX로..
                  ls_list-waers = ls_list-waers_p.
                  ls_list-peinh   = ls_list-peinh_p.
                ENDIF.
              ELSE.
                ls_list-preis   = ls_list-preis_i   = ls_info2-preis.
                ls_list-waers = ls_list-waers_i = ls_info2-waers.
                ls_list-peinh   = ls_list-peinh_i   = ls_info2-peinh .
                ls_list-idnlf    = ls_info2-idnlf.
                ls_list-mwskz = ls_info2-mwskz.
                ls_list-mwskz_i = COND #( WHEN sy-tcode = 'ZGTMMR3000' THEN ls_info2-mwskz
                                                             ELSE ls_list-mwskz_i ) .
              ENDIF.
            ENDIF.
          ENDIF.
          CLEAR : ls_info, ls_info2.

*납품요청일 기준 유효한 계약 건수
          SELECT SINGLE conqty
*          FROM ZGTMM_CV_GET_INFOPRICE_VM( P_DATE = @LS_LIST-LFDAT )
          FROM zgtmm_cv_get_infoprice_vm( p_date = @sy-datum )
          WHERE matnr = @ls_list-matnr
               AND ekorg = @ls_list-ekorg
               AND werks = @ls_list-werks
               AND lifnr   = @ls_list-flief
               AND esokz = @ls_list-pstyp
               INTO @ls_list-conqty.
          PERFORM modify_cell USING po_data_changed 'CONQTY'
                                                ls_list-conqty ls_mod_cells-row_id.
        ENDIF.

      WHEN 'LGORT'.
        IF ls_mod_cells-value IS INITIAL.
          PERFORM modify_cell USING po_data_changed 'LGORT'
                                                  ls_mod_cells-value ls_mod_cells-row_id.
          ls_list-lgort_n = ls_mod_cells-value.

        ELSE.
          SELECT SINGLE  lgobe
             FROM t001l
             WHERE werks = @p_werks AND lgort =  @ls_mod_cells-value
             INTO  @DATA(lv_lgort_n).

          IF lv_lgort_n IS NOT INITIAL.
            ls_list-lgort_n = lv_lgort_n.
          ENDIF.

*          IF LV_KTX80 IS INITIAL AND LV_MAKTX IS INITIAL.
*            LV_ERR = GC_X.
*            PERFORM ADD_ENTRY USING PO_DATA_CHANGED 'MATNR'
*                                               LS_MOD_CELLS-ROW_ID.
*          ELSE.
*            IF LV_KTX80 IS INITIAL.
*              PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'MATNR'
*                                                    LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
*              LS_LIST-TXZ01 = LV_MAKTX.
*            ELSE.
*              PERFORM MODIFY_CELL USING PO_DATA_CHANGED 'MATNR'
*                                                    LS_MOD_CELLS-VALUE LS_MOD_CELLS-ROW_ID.
*              LS_LIST-TXZ01 = LV_KTX80.
*            ENDIF.
*          ENDIF.
          CLEAR : lv_lgort_n.

        ENDIF.

      WHEN 'PREIS'. "단가_수동입력 가능/체크없음
        PERFORM modify_cell USING po_data_changed 'PREIS'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'WAERS'. "통화
        PERFORM modify_cell USING po_data_changed 'WAERS'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'PEINH'. "PER
        PERFORM modify_cell USING po_data_changed 'PEINH'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'MWSKZ'. "TAX
        IF ls_mod_cells-value IS INITIAL.
          PERFORM modify_cell USING po_data_changed 'MWSKZ'
                          ls_mod_cells-value ls_mod_cells-row_id.
        ELSE.
          SELECT SINGLE 1
            FROM t007a WHERE kalsm = 'TAXKR'
                                    AND mwskz = @ls_mod_cells-value
            INTO @DATA(lv_exist).

          IF sy-subrc = 0.
            PERFORM modify_cell USING po_data_changed 'MWSKZ'
                            ls_mod_cells-value ls_mod_cells-row_id.
          ELSE.
            lv_err = gc_x.
            PERFORM add_entry USING po_data_changed 'MWSKZ'
                                               ls_mod_cells-row_id.
          ENDIF.
        ENDIF.

      WHEN 'EKGRP'.

        SELECT SINGLE ekgrp, eknam
           FROM  t024
           WHERE ekgrp = @ls_mod_cells-value
               INTO @DATA(ls_ekgrp).

        IF ls_ekgrp IS  INITIAL.
          lv_err = gc_x.
          PERFORM add_entry USING po_data_changed 'EKGRP'
                                                       ls_mod_cells-row_id.
        ELSE.
          PERFORM modify_cell USING po_data_changed 'EKGRP'
                                                          ls_mod_cells-value ls_mod_cells-row_id.
          ls_list-ekgrp_n = ls_ekgrp-eknam.
        ENDIF.
        CLEAR ls_ekgrp.

      WHEN 'MATNR'.
        IF ls_mod_cells-value IS INITIAL.
          PERFORM modify_cell USING po_data_changed 'MATNR'
                                                ls_mod_cells-value ls_mod_cells-row_id.
*          LS_LIST-TXZ01 = LS_MOD_CELLS-VALUE.
          CLEAR : ls_list-txz01, ls_list-preis, ls_list-waers, ls_list-peinh,
                       ls_list-mwskz, ls_list-mwskz_i, ls_list-idnlf, ls_list-meins,
                       ls_list-preis_i, ls_list-waers_i, ls_list-peinh_i.
        ELSE.
          SELECT SINGLE  mr~meins, mr~zzmaktx80,  mt~maktx
             FROM mara AS mr
             LEFT OUTER JOIN  makt AS mt
             ON mr~matnr EQ mt~matnr
             AND mt~spras EQ @sy-langu
             WHERE mr~matnr = @ls_mod_cells-value
             INTO ( @DATA(lv_meins), @DATA(lv_ktx80), @DATA(lv_maktx) ).

          IF lv_meins IS NOT INITIAL.
            ls_list-meins = lv_meins.
          ENDIF.

          IF lv_ktx80 IS INITIAL AND lv_maktx IS INITIAL.
            lv_err = gc_x.
            PERFORM add_entry USING po_data_changed 'MATNR'
                                               ls_mod_cells-row_id.
          ELSE.
            IF lv_ktx80 IS INITIAL.
              PERFORM modify_cell USING po_data_changed 'MATNR'
                                                    ls_mod_cells-value ls_mod_cells-row_id.
              ls_list-txz01 = lv_maktx.
            ELSE.
              PERFORM modify_cell USING po_data_changed 'MATNR'
                                                    ls_mod_cells-value ls_mod_cells-row_id.
              ls_list-txz01 = lv_ktx80.
            ENDIF.
          ENDIF.
          CLEAR : lv_maktx, lv_ktx80, lv_meins.
        ENDIF.

      WHEN 'MENGE_I'.
*수량 입력시, 드럼 수 재계산_(수량 / 조장)
        ls_list-menge_i =  ls_mod_cells-value.
        IF ls_list-length > 0  AND  ls_list-menge_i > 0.
          lv_drqty = ls_list-menge_i / ls_list-length.
*정수로..1보다 작아도 1로 표기됨(최소 1이 필요하므로..)
          ls_list-drqty = CONV menge_d( ceil( lv_drqty ) ). "CEIL( LS_LIST-DRQTY ).
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

    MODIFY gt_list FROM ls_list INDEX ls_mod_cells-row_id.
  ENDLOOP.

  IF lv_err IS NOT INITIAL.
    CALL METHOD po_data_changed->display_protocol.
  ENDIF.

ENDFORM. " DATA_CHANGED_1
*&---------------------------------------------------------------------*
*&      FORM  DATA_CHANGED_2
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*      -->P_PO_DATA_CHANGED  TEXT
*----------------------------------------------------------------------*
FORM data_changed_2 USING po_data_changed
                                       TYPE REF TO cl_alv_changed_data_protocol.

  DATA : lv_err TYPE char1,
         lv_msg TYPE bapi_msg.

  DATA : lv_meprf   TYPE char1.
  DATA : lt_lines TYPE TABLE OF  tline,
         lv_line  TYPE string.

  DATA : lv_length  TYPE zlength,
         lv_drqty   TYPE dec4,
         lv_pstyp   TYPE ekpo-pstyp,
         lv_knttp   TYPE knttp,
         lv_lifnr   TYPE lifnr,
         lv_jakno   TYPE kdkg4,
         lv_leng(6),
         lt_drum    TYPE STANDARD TABLE OF zgtedsif0038.

  CLEAR : lt_lines, lv_line, lv_err, gv_auto_change, gv_ch_style.

  LOOP AT po_data_changed->mt_good_cells INTO DATA(ls_mod_cells).

    READ TABLE gt_create  INTO DATA(ls_list) INDEX ls_mod_cells-row_id.
    CHECK sy-subrc EQ 0.

    CASE ls_mod_cells-fieldname.

      WHEN 'MATNR'.
        IF ls_mod_cells-value IS INITIAL.
          PERFORM modify_cell USING po_data_changed 'MATNR'
                                                ls_mod_cells-value ls_mod_cells-row_id.

          CLEAR : ls_list-zzmaktx80, ls_list-netpr, ls_list-waers, ls_list-peinh,
                       ls_list-mwskz, ls_list-mwskz_i, ls_list-meins,
                       ls_list-netpr_i, ls_list-waers_i, ls_list-peinh_i, ls_list-mtart.
        ELSE.
          SELECT SINGLE  mr~meins, mr~zzmaktx80,  mt~maktx, mr~mtart
             FROM mara AS mr
             LEFT OUTER JOIN  makt AS mt
             ON mr~matnr EQ mt~matnr
             AND mt~spras EQ @sy-langu
             WHERE mr~matnr = @ls_mod_cells-value
             INTO ( @DATA(lv_meins), @DATA(lv_ktx80), @DATA(lv_maktx) , @DATA(lv_mtart) ).

          IF lv_meins IS NOT INITIAL.
            ls_list-meins = lv_meins.
          ENDIF.

          IF lv_mtart IS NOT INITIAL.
            ls_list-mtart = lv_mtart.
          ENDIF.


          IF lv_ktx80 IS INITIAL AND lv_maktx IS INITIAL.
            lv_err = gc_x.
            PERFORM add_entry USING po_data_changed 'MATNR'
                                               ls_mod_cells-row_id.
          ELSE.
            IF lv_ktx80 IS INITIAL.
              PERFORM modify_cell USING po_data_changed 'MATNR'
                                                    ls_mod_cells-value ls_mod_cells-row_id.
              ls_list-zzmaktx80 = lv_maktx.
            ELSE.
              PERFORM modify_cell USING po_data_changed 'MATNR'
                                                    ls_mod_cells-value ls_mod_cells-row_id.
              ls_list-zzmaktx80 = lv_ktx80.
            ENDIF.
          ENDIF.
*자재코드 변경 시,검사유무/단일단위배치값/인포레코드 재조회
          SELECT SINGLE insmk, dpcbt FROM marc
            WHERE werks = @ls_list-werks
                 AND matnr = @ls_mod_cells-value
            INTO ( @DATA(lv_insmk), @DATA(lv_dpcbt) ).

          ls_list-insmk = lv_insmk.
          ls_list-dpcbt = lv_dpcbt.

*조장/드럼 수 입력가능필드 DPCBT 값에 따라..제어.
          gv_ch_style = gc_x.
*          GV_CH_STYLE = COND #( WHEN LV_DPCBT IS INITIAL THEN '' ELSE GC_X ).
**자재코드 변경 시, 단가/PER/통화/TAX/인포레코드 재조회->FINISHED로 이동
        ENDIF.

      WHEN 'WERKS'.
        IF ls_mod_cells-value IS INITIAL.
          PERFORM modify_cell USING po_data_changed 'WERKS'
                                                ls_mod_cells-value ls_mod_cells-row_id.
          ls_list-werks_n = ls_mod_cells-value.
        ELSE.
          READ TABLE gt_t001w INTO DATA(ls_w)
          WITH KEY werks = ls_mod_cells-value BINARY SEARCH.
          IF sy-subrc = 0.
            PERFORM modify_cell USING po_data_changed 'WERKS'
                                                  ls_mod_cells-value ls_mod_cells-row_id.
            ls_list-werks_n = ls_w-name1.
          ELSE.
            lv_err = gc_x.
            PERFORM add_entry USING po_data_changed 'WERKS'
                                               ls_mod_cells-row_id.
          ENDIF.
        ENDIF.

      WHEN 'VBELN'.
        IF ls_mod_cells-value IS INITIAL.
          PERFORM modify_cell USING po_data_changed 'VBELN'
                                                ls_mod_cells-value ls_mod_cells-row_id.
          ls_list-vbelp = ls_mod_cells-value.
          CLEAR : ls_list-menge , ls_list-meins, ls_list-length , ls_list-drqty.
*        ELSE.
*            IF LS_LIST-VBELP IS NOT INITIAL.

*             SELECT SINGLE  CT~KWMENG , CT~VRKME, CT~LENGTH, CT~DRQTY
*             FROM ZGTMM_CV_SO_VCVALUE_MAIN AS CT
*             WHERE CT~VBELN = @LS_MOD_CELLS-VALUE AND CT~POSNR = @LS_LIST-VBELP
*             INTO ( @DATA(LV_KWMENG_T1), @DATA(LV_VKRME_T1), @DATA(LV_LENGTH_T1) , @DATA(LV_DRQTY_T1) ).
*
*               LS_LIST-MENGE = LV_KWMENG_T1.
*               LS_LIST-MEINS = LV_VKRME_T1.
*               LS_LIST-LENGTH = LV_LENGTH_T1.
*               LS_LIST-DRQTY = LV_DRQTY_T1.

*            ENDIF.
*           GV_CH_STYLE = GC_X.
        ENDIF.

      WHEN 'VBELP'.
        IF ls_mod_cells-value IS INITIAL.
          PERFORM modify_cell USING po_data_changed 'VBELP'
                                                ls_mod_cells-value ls_mod_cells-row_id.
          ls_list-vbelp = ls_mod_cells-value.
          CLEAR : ls_list-menge , ls_list-meins, ls_list-length , ls_list-drqty.
*        ELSE.
*            IF LS_LIST-VBELN IS NOT INITIAL.

*             SELECT SINGLE  CT~KWMENG , CT~VRKME, CT~LENGTH, CT~DRQTY
*             FROM ZGTMM_CV_SO_VCVALUE_MAIN AS CT
*             WHERE CT~VBELN = @LS_MOD_CELLS-VALUE AND CT~POSNR = @LS_LIST-VBELP
*             INTO ( @DATA(LV_KWMENG_T2), @DATA(LV_VKRME_T2), @DATA(LV_LENGTH_T2) , @DATA(LV_DRQTY_T2) ).
*
*               LS_LIST-MENGE = LV_KWMENG_T2.
*               LS_LIST-MEINS = LV_VKRME_T2.
*               LS_LIST-LENGTH = LV_LENGTH_T2.
*               LS_LIST-DRQTY = LV_DRQTY_T2.

*            ENDIF.
*           GV_CH_STYLE = GC_X.

        ENDIF.

      WHEN 'LGORT'.
        IF ls_mod_cells-value IS INITIAL.
          PERFORM modify_cell USING po_data_changed 'LGORT'
                                                ls_mod_cells-value ls_mod_cells-row_id.
          ls_list-lgobe = ls_mod_cells-value.
        ELSE.
          READ TABLE gt_t001l INTO DATA(ls_l)
          WITH KEY werks = ls_list-werks
                          lgort = ls_mod_cells-value BINARY SEARCH.
          IF sy-subrc = 0.
            PERFORM modify_cell USING po_data_changed 'LGORT'
                                                  ls_mod_cells-value ls_mod_cells-row_id.
            ls_list-lgobe = ls_l-lgobe.
          ELSE.
            lv_err = gc_x.
            PERFORM add_entry USING po_data_changed 'LGORT'
                                               ls_mod_cells-row_id.
          ENDIF.
        ENDIF.

      WHEN 'MENGE' .
        PERFORM modify_cell USING po_data_changed 'MENGE'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'MEINS' .
        PERFORM modify_cell USING po_data_changed 'MEINS'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'INSMK'. "재고유형

        READ TABLE gt_insmk INTO DATA(ls_in)
        WITH KEY domvalue_l = ls_mod_cells-value BINARY SEARCH.

        IF sy-subrc = 0.
          PERFORM modify_cell USING po_data_changed 'INSMK'
                                                ls_mod_cells-value ls_mod_cells-row_id.
          ls_list-insmk_n = ls_in-ddtext.
        ENDIF.

      WHEN 'EMLIF' OR 'LIFNR'.
        IF ls_mod_cells-value IS INITIAL.
          IF ls_mod_cells-fieldname = 'EMLIF'.
            PERFORM modify_cell USING po_data_changed 'EMLIF'
                                                  ls_mod_cells-value ls_mod_cells-row_id.
            CLEAR ls_list-emlif_n .

          ELSEIF ls_mod_cells-fieldname = 'LIFNR'.
            PERFORM modify_cell USING po_data_changed 'LIFNR'
                                                  ls_mod_cells-value ls_mod_cells-row_id.
            CLEAR : ls_list-lifnr_n, ls_list-infnr.
          ENDIF.

        ELSE.
          lv_lifnr = ls_mod_cells-value.
          SELECT SINGLE name1
             FROM lfa1
             WHERE lifnr = @lv_lifnr INTO @DATA(lv_name).

          IF lv_name IS INITIAL.
            lv_err = gc_x.
            IF ls_mod_cells-fieldname = 'EMLIF'.
              PERFORM add_entry USING po_data_changed 'EMLIF'
                                                 ls_mod_cells-row_id.
            ELSEIF ls_mod_cells-fieldname = 'LIFNR'.
              PERFORM add_entry USING po_data_changed 'LIFNR'
                                                   ls_mod_cells-row_id.
            ENDIF.

          ELSE.
            IF ls_mod_cells-fieldname = 'EMLIF'.
              PERFORM modify_cell USING po_data_changed 'EMLIF'
                                                    ls_mod_cells-value ls_mod_cells-row_id.
              ls_list-emlif_n = lv_name.
            ELSEIF ls_mod_cells-fieldname = 'LIFNR'.
              PERFORM modify_cell USING po_data_changed 'LIFNR'
                                                    ls_mod_cells-value ls_mod_cells-row_id.
              ls_list-lifnr_n = lv_name.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN 'EINDT'.
        PERFORM modify_cell USING po_data_changed 'EINDT'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'ZMEMO'.
        PERFORM modify_cell USING po_data_changed 'ZMEMO'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'UEBTO'.
        PERFORM modify_cell USING po_data_changed 'UEBTO'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'RETPO'.
        PERFORM modify_cell USING po_data_changed 'RETPO'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'LENGTH'.
        PERFORM modify_cell USING po_data_changed 'LENGTH'
                                              ls_mod_cells-value ls_mod_cells-row_id.
        IF ls_mod_cells-value IS NOT INITIAL.
*조장 데이터 변경되고+값이 있으면, 드럼 수 자동계산.
          IF ls_mod_cells-value  > 0.
            ls_list-length = ls_mod_cells-value.
            lv_drqty = ls_list-menge / ls_list-length.

            IF frac( lv_drqty ) <> 0.
              ls_list-status = icon_led_red.
              lv_err = gc_x.
              PERFORM add_entry USING po_data_changed 'LENGTH' ls_mod_cells-row_id.
              MESSAGE s000 WITH '조장을 점검하세요(소숫점 존재).'(e19).
            ELSE.
              "소숫점 없으면, 드럼 수 자동계산 데이터 업데이트.
              ls_list-drqty = lv_drqty.
            ENDIF.
          ELSE.
            ls_list-drqty =  ls_mod_cells-value.
          ENDIF.
*조장 변경되면 목드럼 자재코드 조회 수행(조장>0 때만)
          IF ls_list-length > 0.
            IF ls_list-dpcbt IS INITIAL.
              SELECT SINGLE dpcbt
                FROM marc
                WHERE werks = @ls_list-werks
                    AND matnr = @ls_list-matnr
                INTO @DATA(lv_dpcbt2).
            ENDIF.

            IF ls_list-dpcbt = 'C' OR lv_dpcbt2 = 'C'.
              lv_jakno = ''. "고객그룹코드
              DATA(lv_int) = CONV i( trunc( ls_list-length ) ). "조장_소숫점 버림
              lv_leng = lv_int.
*            WRITE LV_INT TO LV_LENG RIGHT-JUSTIFIED.


              TRY.
                  CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
                    EXPORTING
                      iv_sul_no    = ls_list-zdgno
                      iv_rev_seq   = ls_list-zrevno
                      iv_jakno     = lv_jakno
                      iv_jojang    = lv_leng
                      iv_drum_code = 'H'
                      iv_flag_pp   = 'X'
                    TABLES
                      ot_return    = lt_drum.
                CATCH cx_root INTO DATA(lv_error).
                  lv_msg = lv_error->get_text( ).
                  MESSAGE s000 WITH lv_msg.
              ENDTRY.

              IF lt_drum IS NOT INITIAL.
                READ TABLE lt_drum ASSIGNING FIELD-SYMBOL(<drum>) INDEX 2.
                IF sy-subrc = 0.
                  ls_list-drmatnr = <drum>-drum_matnr.
                  ls_list-drumname = <drum>-maktx.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN 'DRQTY'.
        PERFORM modify_cell USING po_data_changed 'DRQTY'
                                              ls_mod_cells-value ls_mod_cells-row_id.

        IF ls_mod_cells-value IS NOT INITIAL.
          IF ls_mod_cells-value > 0.

*드럼 수 데이터 변경되고+값이 있으면, 조장 자동계산.
            lv_length = ls_list-menge / ls_mod_cells-value.
            IF frac( lv_length ) <> 0.
              ls_list-status = icon_led_red.
              lv_err = gc_x.
              PERFORM add_entry USING po_data_changed 'DRQTY' ls_mod_cells-row_id.
              MESSAGE s000 WITH '드럼수를 점검하세요(소숫점 존재).'(e19).
            ELSE.
              "소숫점 없으면, 조장 자동계산 데이터 업데이트.
              ls_list-length = lv_length.
            ENDIF.
          ELSE.
            ls_list-length =  ls_mod_cells-value.
          ENDIF.
        ENDIF.

      WHEN 'ZFREE'.
        PERFORM modify_cell USING po_data_changed 'ZFREE'
                                              ls_mod_cells-value ls_mod_cells-row_id.
        IF ls_mod_cells-value = gc_x. "무상 체크시 단가/PER 클리어
          CLEAR : ls_list-netpr, ls_list-peinh.
        ENDIF.

      WHEN 'KNTTP'.
        IF ls_mod_cells-value IS INITIAL.
          PERFORM modify_cell USING po_data_changed 'KNTTP'
                                                ls_mod_cells-value ls_mod_cells-row_id.
        ELSE.
          lv_knttp = ls_mod_cells-value.
          READ TABLE gt_t163i INTO DATA(ls_163) WITH KEY knttp = ls_mod_cells-value.
          IF sy-subrc = 0.
            PERFORM modify_cell USING po_data_changed 'KNTTP'
                                                  ls_mod_cells-value ls_mod_cells-row_id.
          ELSE.
            lv_err = gc_x.
            PERFORM add_entry USING po_data_changed 'KNTTP'
                                                         ls_mod_cells-row_id.
          ENDIF.
          CLEAR lv_knttp.
        ENDIF.

      WHEN 'PSTYP'.
        IF ls_mod_cells-value IS INITIAL.
          PERFORM modify_cell USING po_data_changed 'PSTYP'
                                                ls_mod_cells-value ls_mod_cells-row_id.
        ELSE.
          lv_pstyp = ls_mod_cells-value .
          READ TABLE gt_t163y INTO DATA(ls_y) WITH KEY pstyp = lv_pstyp .
          IF sy-subrc = 0.
            PERFORM modify_cell USING po_data_changed 'PSTYP'
                                                  ls_mod_cells-value ls_mod_cells-row_id.
          ELSE.
            lv_err = gc_x.
            PERFORM add_entry USING po_data_changed 'PSTYP'
                                                         ls_mod_cells-row_id.
          ENDIF.
          CLEAR lv_pstyp.
        ENDIF.

      WHEN 'NETPR'. "단가_수동입력 가능/체크없음
        PERFORM modify_cell USING po_data_changed 'NETPR'
                                              ls_mod_cells-value ls_mod_cells-row_id.
        IF ls_mod_cells-value > 0.
          CLEAR : ls_list-infnr, ls_list-zfree.
        ENDIF.

      WHEN 'WAERS'. "통화
        PERFORM modify_cell USING po_data_changed 'WAERS'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'PEINH'. "PER
        PERFORM modify_cell USING po_data_changed 'PEINH'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'MWSKZ'. "TAX
        IF ls_mod_cells-value IS INITIAL.
          PERFORM modify_cell USING po_data_changed 'MWSKZ'
                          ls_mod_cells-value ls_mod_cells-row_id.
        ELSE.
          SELECT SINGLE 1
            FROM t007a WHERE kalsm = 'TAXKR'
                                    AND mwskz = @ls_mod_cells-value
            INTO @DATA(lv_exist).

          IF sy-subrc = 0.
            PERFORM modify_cell USING po_data_changed 'MWSKZ'
                            ls_mod_cells-value ls_mod_cells-row_id.
          ELSE.
            lv_err = gc_x.
            PERFORM add_entry USING po_data_changed 'MWSKZ'
                                               ls_mod_cells-row_id.
          ENDIF.
        ENDIF.
      WHEN 'VBELN'.
        PERFORM modify_cell USING po_data_changed 'VBELN'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'VBELP'.
        PERFORM modify_cell USING po_data_changed 'VBELP'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'KOSTL'.
        PERFORM modify_cell USING po_data_changed 'KOSTL'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'SAKTO'.
        PERFORM modify_cell USING po_data_changed 'SAKTO'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'ANLN1'.
        PERFORM modify_cell USING po_data_changed 'ANLN1'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'ANLN2'.
        PERFORM modify_cell USING po_data_changed 'ANLN2'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'PS_PSP_PNR'.
        PERFORM modify_cell USING po_data_changed 'PS_PSP_PNR'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'AUFNR'.
        PERFORM modify_cell USING po_data_changed 'AUFNR'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN 'DRMATNR'.
        PERFORM modify_cell USING po_data_changed 'DRMATNR'
                                              ls_mod_cells-value ls_mod_cells-row_id.
      WHEN OTHERS.
    ENDCASE.

    MODIFY gt_create FROM ls_list INDEX ls_mod_cells-row_id.
  ENDLOOP.


  IF lv_err IS NOT INITIAL.
    CALL METHOD po_data_changed->display_protocol.
  ENDIF.



ENDFORM. " DATA_CHANGED_2
*&---------------------------------------------------------------------*
*& FORM MODIFY_CELL
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> PR_CHNG
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM modify_cell USING pr_chng TYPE REF TO cl_alv_changed_data_protocol
                                           pv_fname
                                           pv_fval
                                           pv_index.

  CALL METHOD pr_chng->modify_cell
    EXPORTING
      i_row_id    = pv_index
      i_fieldname = pv_fname
      i_value     = pv_fval.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADD_ENTRY
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> PR_CHNG
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM add_entry     USING pr_chng TYPE REF TO cl_alv_changed_data_protocol
                                           pv_fname
                                           pv_index.

  CALL METHOD pr_chng->add_protocol_entry
    EXPORTING
      i_msgid     = 'ZGTMM01'
      i_msgno     = '013'
      i_msgv1     = pv_fname
      i_msgty     = zgtfi_e
      i_fieldname = pv_fname
      i_row_id    = pv_index.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM hotspot_click USING ps_row_no TYPE lvc_s_row
                                               ps_column TYPE lvc_s_col
                                               po_sender.

*  CHECK PO_SENDER = GCL_GRID .
  CHECK ps_row_no-rowtype IS INITIAL.

  CASE po_sender.

    WHEN gcl_grid OR gcl_grid_400.
**--> 26.09 *단순견적 - 추가
      IF p_pr = gc_x OR p_pr2 = gc_x.

        READ TABLE gt_list INTO DATA(ls_list) INDEX ps_row_no-index.
        CHECK sy-subrc = 0.

        IF ps_column-fieldname = 'EBELN'.
          CHECK ls_list-ebeln IS NOT INITIAL.

          SET PARAMETER ID 'BES' FIELD ls_list-ebeln.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

        ELSEIF ps_column-fieldname = 'BANFN' AND ls_list-ztype =  'PR'.
          CHECK ls_list-banfn IS NOT INITIAL.

          SET PARAMETER ID 'BAN' FIELD ls_list-banfn.
          CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.

        ELSEIF ps_column-fieldname = 'BANFN_N' AND ls_list-ztype =  'PR'.
          CHECK ls_list-banfn_n IS NOT INITIAL.

          SET PARAMETER ID 'BAN' FIELD ls_list-banfn_n.
          CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.
        ELSEIF  ps_column-fieldname = 'MATNR'.
          CHECK ls_list-matnr IS NOT INITIAL.

          SET PARAMETER ID 'MAT' FIELD ls_list-matnr.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
        ELSEIF ps_column-fieldname = 'VBELN'.
          CHECK ls_list-vbeln IS NOT INITIAL.

          SET PARAMETER ID 'AUN' FIELD  ls_list-vbeln .

          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.


*      ELSEIF PS_COLUMN-FIELDNAME = 'CHECK'.
*        IF <LS_LIST_1>-CHECK IS INITIAL.
*          <LS_LIST_1>-CHECK = ABAP_TRUE.
*        ELSE.
*          CLEAR <LS_LIST_1>-CHECK.
*        ENDIF.
*
*        PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
*        CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*          EXPORTING
*            NEW_CODE = 'ENTER'.

        ELSE.
          EXIT.
        ENDIF.

      ELSE.

        READ TABLE gt_create INTO DATA(ls_cre) INDEX ps_row_no-index.
        CHECK sy-subrc = 0.

        IF ps_column-fieldname = 'EBELN'.
          CHECK ls_cre-ebeln IS NOT INITIAL.

          SET PARAMETER ID 'BES' FIELD ls_cre-ebeln.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

        ELSE.
          EXIT.
        ENDIF.

      ENDIF.
  ENDCASE.

ENDFORM.

**&---------------------------------------------------------------------*
**&      FORM  ON_F4
**&---------------------------------------------------------------------*
FORM on_f4  USING e_fieldname    TYPE lvc_fname
                  e_fieldvalue   TYPE lvc_value
                  es_row_no      TYPE lvc_s_roid
                  er_event_data  TYPE REF TO cl_alv_event_data
                  et_bad_cells   TYPE lvc_t_modi
                  e_display      TYPE char01.

  DATA : lt_return TYPE TABLE OF ddshretval,
         ls_return TYPE ddshretval,
         ls_modi   TYPE lvc_s_modi.
  DATA : lv_mwskz TYPE mwskz.

  FIELD-SYMBOLS : <f4tab> TYPE lvc_t_modi.
  ASSIGN er_event_data->m_data->* TO <f4tab>.

  CLEAR : ls_return, lt_return.

  IF e_fieldname = 'MWSKZ'.
*"데이터 추출 (KALSM = 'TAXKR' 필터 및 텍스트 조인)
    SELECT a~kalsm, a~mwskz, s~text1
      FROM t007a AS a
      LEFT JOIN t007s AS s ON a~kalsm  = s~kalsm
                                      AND a~mwskz = s~mwskz
                                      AND s~spras  = @sy-langu
      WHERE a~kalsm = @gc_taxkr
      INTO TABLE @DATA(lt_temp).

*F4 HELP 호출
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'MWSKZ'         " 내부 테이블에서 가져올 필드명
        window_title    = '세금 코드 선택'
        value_org       = 'S'
      TABLES
        value_tab       = lt_temp       " 데이터가 담긴 ITAB
        return_tab      = lt_return   " 사용자가 선택한 행의 정보가 담김
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    IF sy-subrc <> 0.
      MESSAGE s000 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
    ENDIF.

    IF sy-subrc = 0 AND lt_return IS NOT INITIAL.
      READ TABLE lt_return INTO ls_return INDEX 1.

      CLEAR : ls_modi.
      ls_modi-row_id      = es_row_no-row_id.
      ls_modi-fieldname =  'MWSKZ' .
      ls_modi-value        = ls_return-fieldval.
      APPEND ls_modi TO <f4tab>.
    ENDIF.

*    IF SY-SUBRC = 0 AND LT_RETURN IS NOT INITIAL.
**선택된 값 추출 (F0001=KALSM, F0002=MWSKZ, F0003=TEXT1)
*      READ TABLE LT_RETURN INTO LS_RETURN WITH KEY FIELDNAME = 'F0002'.
*      LV_MWSKZ = LS_RETURN-FIELDVAL.
*
**ALV 내부 테이블 업데이트
*      IF P_PR = GC_X.
*        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FS>) INDEX ES_ROW_NO-ROW_ID.
*        IF SY-SUBRC = 0.
*          <FS>-MWSKZ     = LV_MWSKZ.
*        ENDIF.
*
*      ELSEIF P_CRE = GC_X.
*        READ TABLE GT_CREATE ASSIGNING FIELD-SYMBOL(<CRE>) INDEX ES_ROW_NO-ROW_ID.
*        IF SY-SUBRC = 0.
*          <CRE>-MWSKZ    = LV_MWSKZ.
*        ENDIF.
*      ENDIF.
*
*    ENDIF.

  ELSEIF e_fieldname = 'EMLIF' OR e_fieldname = 'FLIEF' OR e_fieldname = 'LIFNR'.

    SELECT a~lifnr, a~name1
      FROM lfa1 AS a  INNER JOIN lfb1 AS b
      ON a~lifnr = b~lifnr
      WHERE b~bukrs = @p_bukrs
      INTO TABLE @DATA(lt_lifnr).

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield   = 'LIFNR'
        value_org  = 'S'
      TABLES
        value_tab  = lt_lifnr
        return_tab = lt_return.
    IF sy-subrc <> 0.
      MESSAGE s000 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
    ENDIF.

    IF sy-subrc = 0 AND lt_return IS NOT INITIAL.
      READ TABLE lt_return INTO ls_return INDEX 1.

      CLEAR : ls_modi.
      ls_modi-row_id      = es_row_no-row_id.
      ls_modi-fieldname = e_fieldname.
      ls_modi-value        = ls_return-fieldval.
      APPEND ls_modi TO <f4tab>.
    ENDIF.

  ELSEIF e_fieldname = 'LGORT'.

    SELECT lgort, lgobe
     FROM t001l
     WHERE werks = @p_werks
     INTO TABLE @DATA(lt_t001l).

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield   = 'LGORT'
        value_org  = 'S'
      TABLES
        value_tab  = lt_t001l
        return_tab = lt_return.
    IF sy-subrc <> 0.
      MESSAGE s000 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
    ENDIF.

    IF sy-subrc = 0 AND lt_return IS NOT INITIAL.
      READ TABLE lt_return INTO ls_return INDEX 1.

      CLEAR : ls_modi.
      ls_modi-row_id      = es_row_no-row_id.
      ls_modi-fieldname = 'LGORT'.
      ls_modi-value        = ls_return-fieldval.
      APPEND ls_modi TO <f4tab>.
    ENDIF.

  ENDIF.





*셀렉션스크린 파라메터나 스크린필드 바로 적용일때...
*    IF SY-SUBRC = 0 AND LT_RETURN IS NOT INITIAL.
**선택된 행에서 필요한 값들을 추출하여 화면 필드와 매핑
*       READ TABLE LT_RETURN INTO LS_RETURN WITH KEY FIELDNAME = 'F0002'. " MWSKZ (두번째 필드)
*       IF SY-SUBRC = 0.
*          LS_DYNP-FIELDNAME = 'MWSKZ'.   " 화면의 코드 필드명
*          LS_DYNP-FIELDVALUE = LS_RETURN-FIELDVAL.
*          APPEND LS_DYNP TO LT_DYNP.
*       ENDIF.
*
*      READ TABLE LT_RETURN INTO LS_RETURN WITH KEY FIELDNAME = 'F0003'. " TEXT1 (세번째 필드)
*      IF SY-SUBRC = 0.
*         LS_DYNP-FIELDNAME = 'MWSKZ_N'. " 화면의 텍스트 필드명
*         LS_DYNP-FIELDVALUE = LS_RETURN-FIELDVAL.
*         APPEND LS_DYNP TO LT_DYNP.
*      ENDIF.
*
**화면(DYNPRO) 필드 값 일괄 업데이트
*      CALL FUNCTION 'DYNP_VALUES_UPDATE'
*        EXPORTING
*         DYNAME     = SY-REPID
*         DYNUMB     = SY-DYNNR
*       TABLES
*         DYNPFIELDS = LT_DYNP.
*    ENDIF.

* TO AVOID STANDARD F4-HELP.
  er_event_data->m_event_handled = 'X'.

ENDFORM.                                                    " ON_F41

*&---------------------------------------------------------------------*
*& FORM SET_F4_FIELD
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_f4_field .

*  CLEAR : GT_F4_3, GT_F4_4.
*
*  IF GV_300GB = 1.
*    GS_F4_4-FIELDNAME  = 'MWSKZ'.
*    GS_F4_4-REGISTER   = 'X'.
*    APPEND GS_F4_4 TO GT_F4_4.
*
*    CALL METHOD GCL_GRID_4->REGISTER_F4_FOR_FIELDS
*      EXPORTING
*        IT_F4 = GT_F4_4.
*  ENDIF.
*
*  GS_F4_3-FIELDNAME  = 'HKONT'.
*  GS_F4_3-REGISTER   = 'X'.
*  APPEND GS_F4_3 TO GT_F4_3.
*
*  CALL METHOD GCL_GRID_3->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = GT_F4_3.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CHANGE_SAVE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_change_save .

*  IF LINE_EXISTS( GT_LIST[ STATUS = ICON_LED_RED ] ) OR
*    LINE_EXISTS( GT_LIST[ STATUS = ICON_CHANGE ] ).
*
*    PERFORM POPUP_TO_CONFIRM_STEP USING ZGTFI_N
*                                                               TEXT-M06  "자재마스터 정보가 변경됩니다.
*                                                               TEXT-M07  "저장 하시겠습니까?
*                                                               TEXT-T04. "확인
*    CHECK GV_ANSWER = ZGTFI_J. "YES
*    PERFORM SAVE_DATA.
*
*  ELSE.
*    MESSAGE S017 DISPLAY LIKE ZGTFI_E.
*    "변경된 내역이 없습니다.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM REQUEST_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM request_data .

  DATA : lt_list LIKE TABLE OF gs_list,
         lv_msg  TYPE string.
  RANGES : lr_banfn FOR eban-banfn,
                 lr_werks FOR marc-werks,
                 lr_erdat FOR eban-erdat.

  CLEAR : gv_text, gv_answer, gv_err.

  IF sy-tcode = 'ZGTMMR3000'.
    PERFORM get_selected_rows USING gcl_grid.
  ELSE.
    PERFORM get_selected_rows USING gcl_grid_400.
  ENDIF.

  CHECK gv_err IS INITIAL.

  LOOP AT gt_rows INTO gs_row.

    READ TABLE gt_list  INTO DATA(ls_list) INDEX gs_row-index.
    IF sy-subrc = 0.

      IF ls_list-ztype = gc_cl.
        MESSAGE s000 WITH TEXT-e11 DISPLAY LIKE gc_e.
        gv_err = gc_x. EXIT. "청구 요청 건은 G-PRO에서 직접 견적 요청하세요.'

      ELSEIF ls_list-flag = gc_x.
        MESSAGE s000 WITH TEXT-e12 DISPLAY LIKE gc_e.
        gv_err = gc_x. EXIT. "이미 견적 요청 건이 존재합니다.'

      ELSE.
        APPEND ls_list TO lt_list. CLEAR ls_list.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CHECK gv_err IS INITIAL.
  SORT lt_list BY banfn.
  DELETE ADJACENT DUPLICATES FROM lt_list COMPARING banfn.

  LOOP AT  lt_list INTO DATA(ls_l).
    APPEND VALUE #( sign      = gc_i
                                 option = gc_eq
                                 low     = ls_l-banfn
                                 high     = '' ) TO lr_banfn.
    APPEND VALUE #( sign      = gc_i
                                 option = gc_eq
                                 low     = ls_l-werks
                                 high     = '' ) TO lr_werks.
    APPEND VALUE #( sign      = gc_i
                                 option = gc_bt
                                 low     = '20260101'
                                 high     = '99991231' ) TO lr_erdat.
  ENDLOOP.
*구매요청 전송관리(G-PRO 시스템 전송 프로그램) 호출
  SUBMIT zgtmmr2000  WITH p_ilog EQ space
                                    WITH p_send  EQ gc_x
                                    WITH p_ifsyt   EQ gc_ksrm "KSRM 가온전선 전자구매시스템
                                    WITH s_werks IN lr_werks
                                    WITH s_banfn IN lr_banfn
                                    WITH s_erdat IN lr_erdat
                                    WITH p_bat = ''   AND RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GR_GRID
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM get_selected_rows USING pr_grid TYPE REF TO cl_gui_alv_grid.

  DATA lv_msg TYPE bapi_msg.

  CLEAR : gt_rows, gs_row, gv_err.

  CALL METHOD pr_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_rows.

  DESCRIBE TABLE gt_rows.

  IF sy-tfill = 0.
    gv_err = gc_x.

    CASE gv_ucomm . "SY-UCOMM.
      WHEN 'CLOSE'.
        lv_msg = '종결 대상을 선택하세요.'(e06).
      WHEN 'CHANGE'.
        lv_msg = '변경 대상을 선택하세요.'(e07).
      WHEN 'MASS'.
        lv_msg = '업체 일괄 등록할 대상을 선택하세요.'(e09).
      WHEN 'REQUEST'.
        lv_msg = '견적 요청할 대상을 선택하세요.'(e10).
      WHEN 'PO' OR 'CREATE'.
        lv_msg = '구매 오더 생성할 대상을 선택하세요.'(e13).
      WHEN 'MOKDR'.
        lv_msg = '소요량 생성할 구매요청을 선택하세요.'(e15).
      WHEN 'DEL'.
        lv_msg = '삭제할 대상을 선택하세요.'(e25).
      WHEN 'APP_REQ'.
        lv_msg = '승인 요청 대상을 선택하세요.'(e30).
      WHEN OTHERS.
    ENDCASE.

    MESSAGE s000 WITH lv_msg DISPLAY LIKE gc_e.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM PR_FINISH_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM pr_finish_data.

  DATA : lt_list   LIKE TABLE OF gs_list,
         lt_cl     LIKE TABLE OF zgtppt3420,
         ls_cl     TYPE zgtppt3420,
         lt_item   TYPE TABLE OF bapimereqitemimp,
         lt_itemx  TYPE TABLE OF bapimereqitemx,
         lt_return TYPE TABLE OF bapiret2.

  DATA : BEGIN OF ls_pr,
           banfn TYPE banfn,
           bnfpo TYPE bnfpo,
         END OF ls_pr,
         lt_pr LIKE TABLE OF ls_pr.

  CHECK sy-tcode = 'ZGTMMR3000'.

  CLEAR : gv_answer, gv_err, lt_cl, lt_pr.

  PERFORM get_selected_rows USING gcl_grid.
  CHECK gv_err IS INITIAL.

  LOOP AT gt_rows INTO gs_row.

    READ TABLE gt_list  INTO DATA(ls_list) INDEX gs_row-index.
    IF sy-subrc = 0.

      IF ls_list-flag = gc_x.
        MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE gc_e.
        gv_err = gc_x. EXIT."견적 진행 중인 구매요청은 종결할 수 없습니다.
      ENDIF.

      IF ls_list-estkz = gc_v.
        MESSAGE s000 WITH TEXT-e34 DISPLAY LIKE gc_e.
        gv_err = gc_x. EXIT."
      ENDIF.

      IF ls_list-ztype = gc_pr.
        APPEND VALUE #( banfn = ls_list-banfn
                                     bnfpo = ls_list-bnfpo ) TO lt_pr.
      ENDIF.

      IF ls_list-ztype = gc_cl.
        CLEAR ls_cl.
        ls_cl = CORRESPONDING #( ls_list MAPPING reqno = banfn
                                                                                posnr = bnfpo ).
        APPEND ls_cl TO lt_cl.
      ENDIF.

    ENDIF.
  ENDLOOP.

  IF lt_pr[] IS INITIAL AND lt_cl[] IS INITIAL.
    MESSAGE s000 WITH TEXT-e04 DISPLAY LIKE gc_e. "처리 가능한 데이터가 없습니다.
    gv_err = gc_x. EXIT.

  ELSE.
    PERFORM popup_to_confirm_step USING gc_n
                                                              TEXT-m04 "선택된 구매 요청이 종결 처리됩니다. "종결 처리 하시겠습니까?
                                                              TEXT-m05 "(이미 종결된 구매 요청은 변경되지 않습니다.)
                                                              TEXT-t04. " 확인
  ENDIF.

  CHECK gv_answer = gc_j. "YES
  CHECK gv_err IS INITIAL.
  SORT  lt_pr BY banfn bnfpo.

*BAPI SET
  LOOP AT lt_pr INTO ls_pr .
    CLEAR : lt_item, lt_itemx, gt_return.

    APPEND VALUE #( preq_item = ls_pr-bnfpo
                                 closed      = gc_x ) TO lt_item.

    APPEND VALUE #( preq_item   = ls_pr-bnfpo
                                 preq_itemx = gc_x
                                 closed         = gc_x  ) TO lt_itemx.

*BAPI_BNFPO 기준 PR 종결
    CALL FUNCTION 'BAPI_PR_CHANGE'
      EXPORTING
        number  = ls_pr-banfn
      TABLES
        return  = gt_return
        pritem  = lt_item
        pritemx = lt_itemx.

    IF line_exists( gt_return[ type = gc_e ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      INSERT LINES OF CORRESPONDING bapiret2_t( gt_return ) INTO TABLE lt_return.
      gv_err = gc_x . CONTINUE.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = gc_x.
    ENDIF.
    CLEAR ls_pr.
  ENDLOOP.

*ZGTPPT3420(자재 청구 이력) UPDATE
  CLEAR ls_cl.
  LOOP AT lt_cl INTO ls_cl.

    UPDATE zgtppt3420
          SET reqno    = ls_cl-reqno
                 posnr    = ls_cl-posnr
                 zstatus = gc_d
     WHERE reqno    = ls_cl-reqno
          AND posnr    = ls_cl-posnr.

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ELSE.
      gv_err = gc_x. CONTINUE.
    ENDIF.
  ENDLOOP.

  IF lt_return[] IS  INITIAL.
    DATA lv_msg TYPE bapi_msg.
    lv_msg = COND #( WHEN gv_err IS INITIAL THEN '선택된 요청에 대한 종결 처리가 완료되었습니다.'(m14)
                                 ELSE '선택된 요청 종결 중 일부 데이터 종결 오류가 발생했습니다. 화면 데이터를 다시 확인하세요.'(m15) ).
  ELSE.
    CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
      TABLES
        i_bapiret2_tab = lt_return.
  ENDIF.

  IF gv_err IS INITIAL.
    PERFORM get_data.
    MESSAGE s000 WITH lv_msg.
  ELSE.
    MESSAGE s000 WITH lv_msg DISPLAY LIKE gc_e.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CREATE_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_create_data .

  CLEAR : gt_create[], gv_err.

  SELECT SINGLE butxt
    FROM t001
    WHERE bukrs = @p_bukrs
    INTO @DATA(lv_txt).

  READ TABLE gt_t001w INTO DATA(ls_w) WITH TABLE KEY werks = p_werks.
  READ TABLE gt_t024e INTO DATA(ls_e) WITH TABLE KEY ekorg = p_ekorg.
  READ TABLE gt_t024  INTO DATA(ls_t) WITH TABLE KEY ekgrp = p_ekgrp.
  READ TABLE gt_insmk INTO DATA(ls_in)
  WITH KEY domvalue_l = space BINARY SEARCH.

  DO 200 TIMES.
    APPEND VALUE #( bukrs = p_bukrs
                                 butxt = lv_txt
                                 werks = p_werks
                                 werks_n = ls_w-name1
                                 ekorg = p_ekorg
                                 ekotx = ls_e-ekotx
                                 ekgrp = p_ekgrp
                                 eknam = ls_t-eknam
                                 insmk_n = ls_in-ddtext ) TO gt_create.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CHANGE_EKORG_LIFNR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM change_ekorg_lifnr .

  CLEAR : gv_ques, gv_info, gv_ekgrp, gv_err.

  IF sy-tcode = 'ZGTMMR3000'.
    PERFORM get_selected_rows USING gcl_grid.
  ELSE.
    PERFORM get_selected_rows USING gcl_grid_400.
  ENDIF.

  CHECK gv_err IS INITIAL.

  gv_ques = COND #( WHEN gv_ucomm = 'CHANGE' THEN TEXT-m22 ELSE TEXT-m24 ).
  gv_info = COND #( WHEN gv_ucomm = 'CHANGE' THEN TEXT-m23 ELSE '' ).

  CALL SCREEN 0200 STARTING AT 5 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_BAPI_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_bapi_data .
  DATA :
    lt_item   TYPE TABLE OF bapimereqitemimp,
    lt_itemx  TYPE TABLE OF bapimereqitemx,
    lt_return TYPE TABLE OF bapiret2.

  DATA :
    ls_head   TYPE bapimathead,
    ls_plant  TYPE bapi_marc,
    ls_plantx TYPE bapi_marcx.

  CLEAR : gs_return, gv_err, gt_pr, gt_cl.

  LOOP AT gt_rows INTO gs_row.
    READ TABLE gt_list  INTO DATA(ls_list) INDEX gs_row-index.
    IF sy-subrc = 0.
      IF ls_list-ztype = gc_pr.
        APPEND VALUE #( banfn = ls_list-banfn
                                     bnfpo = ls_list-bnfpo
                                     ekgrp = gv_ekgrp ) TO gt_pr.
      ENDIF.

      IF ls_list-ztype = gc_cl.
        APPEND VALUE #( matnr = ls_list-matnr
                                     werks = ls_list-werks
                                     ekgrp = gv_ekgrp ) TO gt_cl.
      ENDIF.
    ENDIF.
  ENDLOOP.

  SORT gt_cl BY werks matnr.
  DELETE ADJACENT DUPLICATES FROM gt_cl COMPARING werks matnr.

  CHECK gv_err IS INITIAL.
  SORT gt_pr BY banfn bnfpo.
  SORT gt_list BY banfn bnfpo.

  LOOP AT gt_pr ASSIGNING FIELD-SYMBOL(<fs>).
    CLEAR : lt_item, lt_itemx, gt_return.

    APPEND VALUE #( preq_item   = <fs>-bnfpo
                                 pur_group = <fs>-ekgrp ) TO lt_item.

    APPEND VALUE #( preq_item   = <fs>-bnfpo
                                 preq_itemx = gc_x
                                 pur_group  = gc_x  ) TO lt_itemx.

*BAPI_BNFPO 기준 구매그룹 변경 적용
    CALL FUNCTION 'BAPI_PR_CHANGE'
      EXPORTING
        number  = <fs>-banfn
      TABLES
        return  = gt_return
        pritem  = lt_item
        pritemx = lt_itemx.

    IF line_exists( gt_return[ type = gc_e ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      READ TABLE gt_return INTO DATA(ls_rt) INDEX 1.

      CLEAR ls_list.
      READ TABLE gt_list INTO ls_list WITH KEY banfn = <fs>-banfn
                                                                           bnfpo = <fs>-bnfpo BINARY SEARCH.
      IF sy-subrc = 0.
        DATA(lv_tabix) = sy-tabix.

        ls_list-status    = icon_led_red.
        ls_list-type        = gc_e.
        ls_list-message = ls_rt-message.
      ENDIF.

      IF lines( gt_return ) > 1.
        INSERT LINES OF CORRESPONDING bapiret2_t( gt_return ) INTO TABLE lt_return.
      ENDIF.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = gc_x.

      CLEAR : lv_tabix, ls_list.
      READ TABLE gt_list INTO ls_list WITH KEY banfn = <fs>-banfn
                                                                           bnfpo = <fs>-bnfpo BINARY SEARCH.
      IF sy-subrc = 0.
        lv_tabix = sy-tabix.

        ls_list-ekgrp     = gv_ekgrp.
        ls_list-status    = icon_led_green.
        ls_list-type        = gc_s.
        ls_list-message = '구매그룹을 변경했습니다.'(m06).
      ENDIF.
    ENDIF.

    MODIFY gt_list FROM ls_list INDEX lv_tabix
    TRANSPORTING ekgrp status type message.
  ENDLOOP.

*BAPI_플랜트/자재 기준 구매그룹 변경 적용
  SORT gt_list BY matnr werks.
  LOOP AT gt_cl ASSIGNING FIELD-SYMBOL(<fsc>).
    CLEAR : ls_head, ls_plant, ls_plantx, gt_return.

    ls_head   = VALUE #( material = <fsc>-matnr ).
    ls_plant = VALUE #( plant = <fsc>-werks
                                      pur_group = <fsc>-ekgrp ).
    ls_plantx = VALUE #( plant = gc_x
                                         pur_group = gc_x ).

    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
      EXPORTING
        headdata   = ls_head
        plantdata  = ls_plant
        plantdatax = ls_plantx
      IMPORTING
        return     = gs_return.

    IF gs_return-type = gc_e.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      CLEAR : lv_tabix, ls_list.
      READ TABLE gt_list INTO ls_list WITH KEY matnr = <fsc>-matnr
                                                                          werks = <fsc>-werks BINARY SEARCH.
      IF sy-subrc = 0.
        lv_tabix = sy-tabix.

        ls_list-status    = icon_led_red.
        ls_list-type        = gc_e.
        ls_list-message = gs_return-message.
      ENDIF.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = gc_x.

      CLEAR : lv_tabix, ls_list.
      READ TABLE gt_list INTO ls_list WITH KEY matnr = <fsc>-matnr
                                                                          werks = <fsc>-werks BINARY SEARCH.
      IF sy-subrc = 0.
        lv_tabix = sy-tabix.

        ls_list-ekgrp     = gv_ekgrp.
        ls_list-status   = icon_led_green.
        ls_list-type       = gc_s.
        ls_list-message = '구매그룹을 변경했습니다.'(m06).
      ENDIF.
    ENDIF.

    MODIFY gt_list FROM ls_list INDEX lv_tabix
    TRANSPORTING ekgrp status type message.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_MASS_LIFNR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_mass_lifnr .

  CLEAR : gv_answer, gv_err.

  IF gv_lifnr IS NOT INITIAL.
    gv_lifnr = |{ gv_lifnr ALPHA = IN }|.
    SELECT SINGLE name1
                   FROM lfa1
                 WHERE lifnr = @gv_lifnr INTO @DATA(lv_name1).
  ENDIF.

*  PERFORM GET_SELECTED_ROWS USING GCL_GRID.
*  CHECK GV_ERR IS INITIAL.

  LOOP AT gt_rows INTO gs_row.
    READ TABLE gt_list  INTO DATA(ls_list) INDEX gs_row-index.
    IF sy-subrc = 0.

      ls_list-flief     = gv_lifnr.
      ls_list-flief_n = lv_name1.

      IF gv_lifnr IS INITIAL.
*납품요청일 기준 유효한 계약 건수
        SELECT SINGLE conqty
*        FROM ZGTMM_CV_GET_INFOPRICE_M( P_DATE = @LS_LIST-LFDAT )
        FROM zgtmm_cv_get_infoprice_m( p_date = @sy-datum )
        WHERE matnr = @ls_list-matnr
            AND ekorg = @ls_list-ekorg
            AND werks = @ls_list-werks
            AND esokz = @ls_list-pstyp
            INTO @ls_list-conqty.
      ELSE.
*납품요청일 기준 유효한 계약 건수
        SELECT SINGLE conqty
*        FROM ZGTMM_CV_GET_INFOPRICE_VM( P_DATE = @LS_LIST-LFDAT )
        FROM zgtmm_cv_get_infoprice_vm( p_date = @sy-datum )
        WHERE matnr = @ls_list-matnr
             AND ekorg = @ls_list-ekorg
             AND werks = @ls_list-werks
             AND lifnr   = @ls_list-flief
             AND esokz = @ls_list-pstyp
             INTO @ls_list-conqty.
*단가/통화/PER/업체자재코드/TAX
        SELECT SINGLE kbetr AS preis, konwa AS waers,
                     kpein AS peinh, idnlf, mwskz
        FROM zgtmm_cv_get_infoprice
        WHERE ekorg = @ls_list-ekorg
             AND werks = @ls_list-werks
             AND matnr = @ls_list-matnr
             AND lifnr   = @ls_list-flief
             AND esokz = @ls_list-pstyp
*           AND DATAB <= @LS_LIST-LFDAT
*           AND DATBI >= @LS_LIST-LFDAT
             AND datab <= @sy-datum
             AND datbi >= @sy-datum
             INTO @DATA(ls_info).
*        READ TABLE GT_INFO INTO DATA(LS_INFO)
*        WITH KEY MATNR = LS_LIST-MATNR
*                       LIFNR   = LS_LIST-FLIEF
*                       ESOKZ = LS_LIST-PSTYP BINARY SEARCH.
        IF ls_info IS NOT INITIAL ."SY-SUBRC = 0.
          ls_list-preis    = ls_list-preis_i   = ls_info-preis."KBETR.
          ls_list-waers  = ls_list-waers_i = ls_info-waers."KONWA.
          ls_list-peinh    = ls_list-peinh_i   = ls_info-peinh."KPEIN.
          ls_list-mwskz  = ls_list-mwskz_i = ls_info-mwskz.
          ls_list-idnlf     = ls_info-idnlf.

        ELSE.
          CLEAR : ls_list-preis, ls_list-preis_i, ls_list-waers, ls_list-waers_i,
                       ls_list-peinh, ls_list-peinh_i, ls_list-idnlf, ls_list-mwskz,
                       ls_list-mwskz_i.
        ENDIF.
      ENDIF.

      MODIFY gt_list FROM ls_list INDEX gs_row-index.
    ENDIF.

    CLEAR : ls_list, ls_info.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CONV_PO
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM conv_po .

  DATA :
    ls_conv TYPE ty_conv_po,
    lt_list TYPE TABLE OF ty_conv_po.
  DATA :
    lv_err,
    lv_ebeln  TYPE ekko-ebeln,
    lv_item   TYPE bapimepoitem-po_item,
    lv_stno   TYPE stunr,
    lv_qtymsg TYPE bapi_msg,
    lv_errmsg TYPE bapi_msg,
    lv_insmsg TYPE bapi_msg.

  CLEAR : gv_answer, gv_err, gv_ques, gv_info, gt_return, ls_conv, gt_conv_po.

  IF sy-tcode = 'ZGTMMR3000'.
    PERFORM get_selected_rows USING gcl_grid.
  ELSE.
    PERFORM get_selected_rows USING gcl_grid_400.
  ENDIF.

  CHECK gv_err IS INITIAL.

  LOOP AT gt_rows INTO gs_row.
    READ TABLE gt_list  INTO DATA(ls_list) INDEX gs_row-index.
    IF sy-subrc = 0.

      IF ls_list-ekgrp IS INITIAL OR ls_list-flief IS INITIAL OR
        ls_list-preis IS INITIAL OR ls_list-waers IS INITIAL OR
        ls_list-peinh IS INITIAL OR ls_list-mwskz IS INITIAL.

        gv_err = gc_x.
        MESSAGE s000 WITH TEXT-e14 DISPLAY LIKE gc_e. EXIT.
        "필수 값을 모두 입력하세요.
      ELSE.

        IF ls_list-bsart <> gc_nb.
          gv_err = gc_x.
          MESSAGE s000 WITH TEXT-e35 DISPLAY LIKE gc_e. EXIT.
          "단순 견적은 구매 오더 전환이 불가능합니다.
        ENDIF.

        IF ls_list-ebakz = gc_x OR ls_list-loekz = gc_x.
          gv_err = gc_x.
          MESSAGE s000 WITH TEXT-e33 DISPLAY LIKE gc_e. EXIT.
          "삭제 OR 종료된 PR은 전환할 수 없습니다.
        ENDIF.

        IF ls_list-ebeln IS INITIAL.
          ls_conv = CORRESPONDING #( ls_list ).
          ls_conv-index = gs_row-index.
          APPEND ls_conv TO gt_conv_po. CLEAR ls_conv.

        ELSE.
          gv_err = gc_x.
          MESSAGE s000 WITH TEXT-e32 DISPLAY LIKE gc_e. EXIT.
        ENDIF.

        IF  p_werks = '6500' AND ls_list-dpcbt = 'C'  AND ls_list-drumname = '' AND ( ls_list-mtart ='MCFE' OR ls_list-mtart ='MCHA').
          gv_err = gc_x.
          MESSAGE s000 WITH TEXT-e37 DISPLAY LIKE gc_e. EXIT.

        ENDIF.
*>S.2026.08.10_TCODE ZGTMMR3001인 경우, ESTKZ = 'V'일 때 VALIDATION 추가
*생성 도중 PR 수량 변경되는 경우 발생하여 점검 추가. EBAN-MENGE NE 입력된 GT_LIST-MENGE_I -> 에러.
        IF sy-tcode = 'ZGTMMR3001' AND ls_list-estkz = 'V'."구매문서지시자-판매 관리 문서
          SELECT SINGLE menge
            FROM eban
            WHERE banfn = @ls_list-banfn
                 AND bnfpo = @ls_list-bnfpo
            INTO @DATA(lv_menge).

          IF sy-subrc = 0.
            IF ls_list-menge_i NE lv_menge .
              gv_err = gc_x.
              ls_list-status = icon_led_red.
              ls_list-message = TEXT-e38. "구매요청 수량을 재조회 하세요(수량 정보 불일치)
              MODIFY gt_list FROM ls_list  INDEX gs_row-index TRANSPORTING status message.
              MESSAGE s000 WITH TEXT-e38 DISPLAY LIKE gc_e. EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
*<E.2026.08.10_ZGODEV04

*--------------------------------------------------------------------*
**--> 26.09 구매요청 발주잔량 체크 후 중복/초과 PO 생성처리 안되도록 추가
*       ZTYPE = 'CL'(청구현황)은 BANFN이 청구번호이므로 대상에서 제외
*--------------------------------------------------------------------*
        IF ls_list-ztype = gc_pr.

          PERFORM check_pr_rest_qty USING    ls_list-banfn
                                             ls_list-bnfpo
                                             ls_list-menge_i
                                    CHANGING lv_qtymsg.

          IF lv_qtymsg IS NOT INITIAL.
            gv_err = gc_x.
            ls_list-status  = icon_led_red.
            ls_list-message = lv_qtymsg.
            MODIFY gt_list FROM ls_list INDEX gs_row-index
            TRANSPORTING status message.

            IF lv_errmsg IS INITIAL.
              lv_errmsg = lv_qtymsg. "최초 오류 메시지 보관
            ENDIF.
          ENDIF.

        ENDIF.
*--------------------------------------------------------------------*
**--> 26.10 inspection = '유'인 경후 여장체크
*--------------------------------------------------------------------*
        IF ls_list-inspection = '유'.
          CLEAR lv_insmsg.
          PERFORM check_inspection_qty USING ls_list-vbeln
                                             ls_list-posnr
                                       CHANGING lv_insmsg
                                                ls_list-insqty_w
                                                ls_list-insqty_s.

          IF lv_insmsg IS NOT INITIAL.
            gv_err = gc_x.
            ls_list-status  = icon_led_red.
            ls_list-message = lv_insmsg.
            MODIFY gt_list FROM ls_list INDEX gs_row-index
            TRANSPORTING status message insqty_w insqty_s.

            IF lv_errmsg IS INITIAL.
              lv_errmsg = lv_insmsg. "최초 오류 메시지 보관
            ENDIF.
          ENDIF.
        ENDIF.

*--------------------------------------------------------------------*

      ENDIF.
    ENDIF.
  ENDLOOP.

**--> 26.09 발주잔량 오류 시 안내 메시지 출력(기존: 메시지 없이 종료)
  IF lv_errmsg IS NOT INITIAL.
    MESSAGE s000 WITH lv_errmsg(50)     lv_errmsg+50(50)
                      lv_errmsg+100(50) lv_errmsg+150(50)
                 DISPLAY LIKE gc_e.
  ENDIF.

  CHECK gv_err IS INITIAL.
  SORT gt_conv_po BY flief ekorg ekgrp waers banfn bnfpo ASCENDING.
  gv_ques = '구매오더를 생성하시겠습니까?'(m26).
  gv_info   = '( 수입 PO 생성 시에만 입력하세요. )'(m27).

  CALL SCREEN 0300 STARTING AT 10 5.

*팝업스크린으로 대체하여 아래 주석. USER-COMMAND 0300으로 이동.
*  DATA : LS_HEAD   TYPE BAPIMEPOHEADER,
*         LS_HEADX  TYPE BAPIMEPOHEADERX,
*         LT_ITEM   LIKE TABLE OF BAPIMEPOITEM,
*         LT_ITEMX  LIKE TABLE OF BAPIMEPOITEMX,
*         LT_SCH    LIKE TABLE OF BAPIMEPOSCHEDULE,
*         LT_SCHX   LIKE TABLE OF BAPIMEPOSCHEDULX,
*         LT_COND   LIKE TABLE OF BAPIMEPOCOND,
*         LT_CONDX  LIKE TABLE OF BAPIMEPOCONDX,
*         LT_POTEXT LIKE TABLE OF BAPIMEPOTEXT,
*         LV_PREIS  TYPE EKPO-NETPR,
*         LT_RETURN TYPE TABLE OF BAPIRET2.
*
*  CLEAR LS_CONV.
*  LOOP AT LT_LIST INTO LS_CONV GROUP BY ( FLIEF = LS_CONV-FLIEF
*                                                                      EKORG = LS_CONV-EKORG
*                                                                      EKGRP = LS_CONV-EKGRP
*                                                                      WAERS = LS_CONV-WAERS  )
*    ASCENDING ASSIGNING FIELD-SYMBOL(<FSG>). " 그룹화 시 자동 정렬
*
**--- PO(EBELN) HEADER 정보 설정---
*    CLEAR : LS_HEAD, LS_HEADX, LV_ITEM, LV_STNO.
*
*    LS_HEAD = VALUE #( COMP_CODE  = P_BUKRS
*                                     VENDOR         = <FSG>-FLIEF
*                                     PURCH_ORG   = <FSG>-EKORG
*                                     PUR_GROUP   = <FSG>-EKGRP
*                                     CURRENCY     = <FSG>-WAERS ).
*
*    LS_HEADX = VALUE #( COMP_CODE  = GC_X
*                                      VENDOR         = GC_X
*                                      PURCH_ORG   = GC_X
*                                      PUR_GROUP   = GC_X
*                                      CURRENCY     = GC_X ).
*
**--- PO의 (품목별 상세 내역) 설정 (10단위)---
*    CLEAR : LT_ITEM, LT_ITEMX, LT_SCH, LT_SCHX, LT_COND, LT_CONDX.
*
*    LOOP AT GROUP <FSG> ASSIGNING FIELD-SYMBOL(<LS_PO>).
*
*      LV_ITEM = LV_ITEM + 10.
*      <LS_PO>-EBELP = LV_ITEM.
*
*
*      APPEND VALUE #( PO_ITEM             = LV_ITEM
*                                  ITEM_CAT = <LS_PO>-PSTYP
*                                  MATERIAL_LONG  = <LS_PO>-MATNR
*                                  SHORT_TEXT       = <LS_PO>-TXZ01
*                                  PLANT                 = <LS_PO>-WERKS
*                                  STGE_LOC          = <LS_PO>-LGORT
*                                  MATL_GROUP      = <LS_PO>-MATKL
*                                  QUAL_INSP          = <LS_PO>-INSMK
*                                  QUANTITY            = <LS_PO>-MENGE_I
*                                  PO_UNIT              = <LS_PO>-MEINS
*                                  TRACKINGNO    = COND #( WHEN <LS_PO>-ZTYPE = GC_PR THEN SPACE ELSE <LS_PO>-BANFN )
*                                  PREQ_NAME    =  COND #( WHEN <LS_PO>-ZTYPE = GC_PR THEN SPACE ELSE <LS_PO>-BNFPO )
*                                  SUPP_VENDOR    = <LS_PO>-EMLIF
*                                  SC_VENDOR        = <LS_PO>-LBLKZ
*                                  TAX_CODE          = <LS_PO>-MWSKZ  ) TO LT_ITEM.
*
*      APPEND VALUE #( PO_ITEM             = LV_ITEM
*                                  PO_ITEMX            = GC_X
*                                  ITEM_CAT = GC_X
*                                  MATERIAL_LONG  = GC_X
*                                  SHORT_TEXT       = GC_X
*                                  PLANT                 = GC_X
*                                  STGE_LOC          = GC_X
*                                  MATL_GROUP      = GC_X
*                                  QUAL_INSP          = GC_X
*                                  QUANTITY            = GC_X
*                                  PO_UNIT              = GC_X
*                                  TRACKINGNO    = COND #( WHEN <LS_PO>-ZTYPE = GC_PR THEN SPACE ELSE GC_X )
*                                  PREQ_NAME    =  COND #( WHEN <LS_PO>-ZTYPE = GC_PR THEN SPACE ELSE GC_X )
*                                  SUPP_VENDOR    = GC_X
*                                  SC_VENDOR        = GC_X
*                                  TAX_CODE          = GC_X  ) TO LT_ITEMX.
*
*      APPEND VALUE #( PO_ITEM              = LV_ITEM
*                                  SCHED_LINE         = '0001' "고정
*                                  DEL_DATCAT_EXT = GC_D
*                                  DELIVERY_DATE    = <LS_PO>-LFDAT
*                                  QUANTITY             = <LS_PO>-MENGE_I
*                                  PREQ_NO             = <LS_PO>-BANFN
*                                  PREQ_ITEM          = <LS_PO>-BNFPO  ) TO LT_SCH.
*
*      APPEND VALUE #( PO_ITEM             = LV_ITEM
*                                  SCHED_LINE         = '0001'
*                                  PO_ITEMX            = GC_X
*                                  SCHED_LINEX       = GC_X
*                                  DEL_DATCAT_EXT = GC_X
*                                  DELIVERY_DATE    = GC_X
*                                  QUANTITY            = GC_X
*                                  PREQ_NO             = COND #( WHEN <LS_PO>-ZTYPE = GC_PR THEN GC_X ELSE SPACE )
*                                  PREQ_ITEM          = COND #( WHEN <LS_PO>-ZTYPE = GC_PR THEN GC_X ELSE SPACE )
*                                   ) TO LT_SCHX.
*
*      APPEND VALUE #( PO_ITEM     =  LV_ITEM
*                                   TEXT_ID      = 'F01'
*                                   TEXT_LINE  = COND #( WHEN <LS_PO>-ZMEMO_I IS INITIAL
*                                                                      THEN <LS_PO>-ZMEMO_H ELSE <LS_PO>-ZMEMO_I ) )
*                                   TO LT_POTEXT.
*
*      IF <LS_PO>-PREIS_I EQ <LS_PO>-PREIS AND <LS_PO>-PEINH_I EQ <LS_PO>-PEINH AND
*        <LS_PO>-WAERS_I EQ <LS_PO>-WAERS.
**입력한 단가/PER/통화와 INFO 정보가 같을 시 POCOND조건 미저장, 다를 시 저장(설정)
*      ELSE.
*        _IDOC <LS_PO>-WAERS <LS_PO>-PREIS LV_PREIS.
*        APPEND VALUE #( ITM_NUMBER             = LV_ITEM
*                                    COND_ST_NO             = '001' "고정
*                                    COND_COUNT             = '02' "고정
*                                    COND_TYPE               =  'PBXX'
*                                    COND_VALUE             = LV_PREIS "<LS_PO>-PREIS
*                                    CURRENCY                 = <LS_PO>-WAERS
*                                    CURRENCY_ISO          = <LS_PO>-WAERS
*                                    COND_UNIT                = <LS_PO>-MEINS
*                                    COND_UNIT_ISO         = <LS_PO>-MEINS
*                                    COND_P_UNT            = <LS_PO>-PEINH
*                                    CHANGE_ID                = GC_I
*                                    COND_COUNT_LONG = '002'
*                                    ) TO LT_COND.
*
*        APPEND VALUE #( ITM_NUMBER             = LV_ITEM
*                                    COND_ST_NO             = '001'
*                                    ITM_NUMBERX            = GC_X
*                                    COND_ST_NOX          = GC_X
*                                    COND_COUNT           = GC_X
*                                    COND_TYPE               = GC_X
*                                    COND_VALUE             = GC_X
*                                    CURRENCY                 = GC_X
*                                    CURRENCY_ISO          = GC_X
*                                    COND_UNIT                = GC_X
*                                    COND_UNIT_ISO         = GC_X
*                                    COND_P_UNT            = GC_X
*                                    CHANGE_ID                = GC_X
*                                    COND_COUNT_LONG  = GC_X
*                                    ) TO LT_CONDX.
*      ENDIF.
*
*    ENDLOOP.
*
*    CLEAR GT_RETURN.
**"--- BAPI_PO_CREATE1호출. PO 생성 및 EBELN 번호 채번 ---
*    CALL FUNCTION 'BAPI_PO_CREATE1'
*      EXPORTING
*        POHEADER         = LS_HEAD
*        POHEADERX        = LS_HEADX
*      IMPORTING
*        EXPPURCHASEORDER = LV_EBELN
*      TABLES
*        RETURN           = GT_RETURN
*        POITEM           = LT_ITEM
*        POITEMX          = LT_ITEMX
*        POSCHEDULE       = LT_SCH
*        POSCHEDULEX      = LT_SCHX
*        POCOND           = LT_COND
*        POCONDX          = LT_CONDX
*        POTEXTITEM       = LT_POTEXT.
*
*    IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ) OR LV_EBELN IS INITIAL.
*      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*      INSERT LINES OF CORRESPONDING BAPIRET2_T( GT_RETURN ) INTO TABLE LT_RETURN.
*      READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.
*
*      LOOP AT GROUP <FSG> ASSIGNING FIELD-SYMBOL(<BACK>).
***MAIN ALV DATA UPDATE
*        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FSU>)
*        INDEX <BACK>-INDEX.
*        IF SY-SUBRC = 0.
*          CLEAR : <FSU>-EBELN, <FSU>-EBELP.
*          <FSU>-STATUS    = ICON_LED_RED.
*          <FSU>-TYPE        = GC_E.
*          <FSU>-MESSAGE = LS_RT-MESSAGE.
*          MODIFY GT_LIST FROM <FSU> INDEX <BACK>-INDEX.
*        ENDIF.
*      ENDLOOP.
*      LV_ERR = GC_X.
*
*    ELSE.
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          WAIT = GC_X.
*
*      LOOP AT GROUP <FSG> ASSIGNING FIELD-SYMBOL(<COM>).
***MAIN ALV DATA UPDATE
*        READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<FSUC>)
*        INDEX <COM>-INDEX.
*        IF SY-SUBRC = 0.
*          <FSUC>-EBELN = LV_EBELN.
*          <FSUC>-EBELP = <COM>-EBELP.
*          <FSUC>-STATUS    = ICON_LED_GREEN.
*          <FSUC>-TYPE        = GC_S.
*          <FSUC>-MESSAGE = '구매오더가 생성 되었습니다.'(M17).
*          MODIFY GT_LIST FROM <FSUC> INDEX <COM>-INDEX.
*        ENDIF.
*      ENDLOOP.
*
*    ENDIF.
*
*    CLEAR LS_CONV.
*  ENDLOOP.
*
*  IF LT_RETURN[] IS NOT INITIAL.
*    CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
*      TABLES
*        I_BAPIRET2_TAB = LT_RETURN.
*  ENDIF.
*
*  IF LV_ERR IS INITIAL.
*    PERFORM GET_DATA.
*    MESSAGE S000 WITH '구매오더를 생성했습니다.!'.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CREATE_DRUM_CONSUMPTION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM create_drum_consumption .

  DATA : lt_list LIKE TABLE OF gs_list,
         lt_save LIKE TABLE OF zgtmmt2010.

  CLEAR : gv_answer, gv_err, gt_return.

  CHECK sy-tcode = 'ZGTMMR3000'.

  PERFORM get_selected_rows USING gcl_grid.
  CHECK gv_err IS INITIAL.

  LOOP AT gt_rows INTO gs_row.
    READ TABLE gt_list  INTO DATA(ls_list) INDEX gs_row-index.
    IF sy-subrc = 0.

      IF ls_list-vbeln IS INITIAL OR  ls_list-pstyp NE gc_3.

        gv_err = gc_x.
        MESSAGE s000 WITH TEXT-e16 DISPLAY LIKE gc_e. EXIT.
        "수출용 목드럼 임가공만 소요량 전개가 가능합니다.

      ELSEIF ls_list-banfn_n IS NOT INITIAL.
        gv_err = gc_x.
        MESSAGE s000 WITH TEXT-e17 DISPLAY LIKE gc_e. EXIT.
        "이미 전개한 소요량입니다.

      ELSE.
        APPEND ls_list TO lt_list. CLEAR ls_list.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CHECK gv_err IS INITIAL.

  IF lt_list[] IS NOT INITIAL.
    SELECT FROM zgtmm_cv_get_pr_reservation
    FIELDS *
    FOR ALL ENTRIES IN @lt_list
    WHERE banfn = @lt_list-banfn
         AND bnfpo = @lt_list-bnfpo
    INTO TABLE @DATA(lt_bom).
  ENDIF.

  DATA : lv_banfn      TYPE bapimereqheader-preq_no,
         lv_item       TYPE bapimereqitemimp-preq_item,
         lt_pritem     LIKE TABLE OF bapimereqitemimp,
         lt_pritemx    LIKE TABLE OF bapimereqitemx,
         lt_pracc      LIKE TABLE OF bapimereqaccount,
         lt_praccx     LIKE TABLE OF bapimereqaccountx,
         lt_pritemtext LIKE TABLE OF bapimereqitemtext,
         ls_prheader   TYPE bapimereqheader,
         ls_prheaderx  TYPE bapimereqheaderx.

  IF lt_bom[] IS NOT INITIAL.
    CLEAR : ls_prheader, ls_prheaderx.
    ls_prheader-pr_type = 'NB'.
    ls_prheaderx-pr_type = gc_x.

    LOOP AT lt_bom INTO DATA(ls_bom).
      lv_item = lv_item + 10.

      APPEND VALUE #( preq_item         = lv_item
                                  pur_group        = p_ekgrp
                                  preq_name        = '수출드럼전개'
                                  material_long  = ls_bom-matnr
                                  plant                 = ls_bom-werks
                                  store_loc         = '1120'
                                  quantity            = ls_bom-bdmng
                                  unit                    = ls_bom-meins
                                  deliv_date         = ls_bom-bdter
                                  acctasscat       = COND #( WHEN ls_bom-kostl IS INITIAL THEN gc_m ELSE gc_k )
                                  purch_org        = p_ekorg ) TO lt_pritem.

      APPEND VALUE #( preq_item         = lv_item
                                  preq_itemx        = gc_x
                                  pur_group        = gc_x
                                  preq_name        = gc_x
                                  material_long  = gc_x
                                  plant                 = gc_x
                                  store_loc         = gc_x
                                  quantity            = gc_x
                                  unit                    = gc_x
                                  deliv_date         = gc_x
                                  acctasscat       = gc_x
                                  purch_org        = gc_x ) TO lt_pritemx.

      APPEND VALUE #( preq_item = lv_item
                                   serial_no = '01'
                                   sd_doc     = COND #( WHEN ls_bom-kostl IS INITIAL THEN ls_bom-vbeln ELSE space )
                                   itm_number = COND #( WHEN ls_bom-kostl IS INITIAL THEN ls_bom-vbelp ELSE space )
                                   costcenter = ls_bom-kostl
                                   gl_account = ls_bom-sakto
                                   unload_pt = '목드럼' ) TO lt_pracc.

      APPEND VALUE #( preq_item    = lv_item
                                   serial_no    = '01'
                                   preq_itemx = gc_x
                                   serial_nox = gc_x
                                   sd_doc        = COND #( WHEN ls_bom-kostl IS INITIAL THEN gc_x ELSE space )
                                   itm_number = COND #( WHEN ls_bom-kostl IS INITIAL THEN gc_x ELSE space )
                                   costcenter = COND #( WHEN ls_bom-kostl IS INITIAL THEN space ELSE gc_x )
                                   gl_account = COND #( WHEN ls_bom-kostl IS INITIAL THEN space ELSE gc_x )
                                   unload_pt  = gc_x ) TO lt_praccx.

      APPEND VALUE #( preq_item = lv_item
                                   text_id = 'B01'
                                   text_line     =  ls_bom-vbeln  ) TO lt_pritemtext.
    ENDLOOP.
*BAPI
    CALL FUNCTION 'BAPI_PR_CREATE'
      EXPORTING
        prheader   = ls_prheader
        prheaderx  = ls_prheaderx
      IMPORTING
        number     = lv_banfn
      TABLES
        return     = gt_return
        pritem     = lt_pritem
        pritemx    = lt_pritemx
        praccount  = lt_pracc
        praccountx = lt_praccx
        pritemtext = lt_pritemtext.

    IF line_exists( gt_return[ type = gc_e ] ) OR lv_banfn IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      IF lines( gt_return ) > 1.
        CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
          TABLES
            i_bapiret2_tab = gt_return.
      ELSE.
        READ TABLE gt_return INTO DATA(ls_rt) INDEX 1.
        IF sy-subrc = 0.
          MESSAGE s000 WITH ls_rt-message DISPLAY LIKE gc_e.
        ELSE.
          MESSAGE s000 WITH TEXT-e18 DISPLAY LIKE gc_e.
        ENDIF.
      ENDIF.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = gc_x.
*ZGTMMT2010 LOG 저장용
      lt_save[] = VALUE #( BASE lt_save FOR ls IN lt_list
                          ( VALUE #( BASE CORRESPONDING #( ls )
                          banfn_n = lv_banfn
                          erdat     = sy-datum
                          erdat_local = sy-datlo
                          ertim      = sy-uzeit
                          ertim_local = sy-timlo
                          ernam    = sy-uname ) ) ).

      DATA:
        lv_rel_ind TYPE bapimmpara-rel_ind,
        lt_return  TYPE STANDARD TABLE OF bapireturn.

      SELECT * FROM eban WHERE banfn = @lv_banfn AND frgkz = 'Z'  INTO TABLE  @DATA(lt_eban).

      IF lt_eban[] IS NOT INITIAL.
        LOOP AT lt_eban ASSIGNING FIELD-SYMBOL(<ls_row>).

          CLEAR:
            lv_rel_ind,
            lt_return[].

          CALL FUNCTION 'BAPI_REQUISITION_RELEASE'
            EXPORTING
              number                 = <ls_row>-banfn
              rel_code               = 'AN'
              item                   = <ls_row>-bnfpo
            IMPORTING
              rel_indicator_new      = lv_rel_ind
            TABLES
              return                 = lt_return
            EXCEPTIONS
              authority_check_fail   = 1
              requisition_not_found  = 2
              enqueue_fail           = 3
              prerequisite_fail      = 4
              release_already_posted = 5
              responsibility_fail    = 6
              OTHERS                 = 7.

          IF sy-subrc NE 0.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF lt_save[] IS NOT INITIAL.
      MODIFY zgtmmt2010 FROM TABLE lt_save.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM TEMPLATE_DOWNLOAD
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GC_ZGTMMR3000_OPT1
*&---------------------------------------------------------------------*
FORM template_download  USING  pv_objid TYPE w3objid.

  DATA:
    ls_wwwdata           TYPE wwwdatatab,
    lv_default_file_name TYPE string,
    lv_filename          TYPE string,
    lv_path              TYPE string,
    lv_fullpath          TYPE string,
    lv_rc                TYPE sy-subrc.

  CONSTANTS
    lc_file_ext          TYPE w3_name VALUE 'FILEEXTENSION'.

  "SMW0 조회
  SELECT SINGLE *
    FROM wwwdata
   WHERE objid EQ @pv_objid
    INTO CORRESPONDING FIELDS OF @ls_wwwdata.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  SELECT SINGLE
    value
    FROM wwwparams
    WHERE relid EQ @ls_wwwdata-relid
    AND objid EQ @ls_wwwdata-objid
    AND name EQ @lc_file_ext
    INTO @DATA(lv_file_ext).

  lv_file_ext = COND #( WHEN lv_file_ext IS INITIAL
                                 THEN 'EXCEL FILES (*.XLSX)|*.XLSX' ELSE lv_file_ext ).
  lv_default_file_name = ls_wwwdata-text ."&& LV_FILE_EXT.

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      default_extension         =   CONV string( lv_file_ext )
      default_file_name         =   lv_default_file_name
      file_filter                       =  CONV string( lv_file_ext )
    CHANGING
         filename                  =   lv_filename
         path                          =   lv_path
         fullpath                  =   lv_fullpath
       EXCEPTIONS
         cntl_error                =   1
         error_no_gui              =   2
         not_supported_by_gui      =   3
         invalid_default_file_name =   4
         OTHERS                    =   5
     ).

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE gc_s NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      DISPLAY LIKE gc_e.
    EXIT.
  ENDIF.

  CHECK lv_fullpath IS NOT INITIAL.
  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      key         = ls_wwwdata
      destination = CONV localfile( lv_fullpath )
    IMPORTING
      rc          = lv_rc.

  CHECK lv_rc EQ 0.

  cl_gui_frontend_services=>execute(
          EXPORTING
            document               = lv_fullpath
          EXCEPTIONS
            cntl_error             = 1
            error_no_gui           = 2
            bad_parameter          = 3
            file_not_found         = 4
            path_not_found         = 5
            file_extension_unknown = 6
            error_execute_failed   = 7
            synchronous_failed     = 8
            not_supported_by_gui   = 9
            OTHERS                 = 10
        ).

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE gc_s NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      DISPLAY LIKE gc_e.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM EXCEL_UPLOAD_OPT1
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM excel_upload.

*2-1) 1의 대상별 UPLOAD 파일 업로드 하여 ALV LIST 데이터로 반영
*2-2) EXCEL 업로드 시 ALV 에 데이터가 존재하면 데이터 CLEAR 후 엑셀 입력 데이터로 반영
*   TEXT 성 필드및 반영조건은 직접 입력하는 경우와 동일함
*  DATA LV_CHECK TYPE C LENGTH 1.
*  CALL METHOD GCL_GRID->CHECK_CHANGED_DATA
*    IMPORTING
*      E_VALID = LV_CHECK.
*  CHECK LV_CHECK EQ ABAP_TRUE.

  DATA:
    lv_file TYPE rlgrap-filename,
    lt_xls  TYPE STANDARD TABLE OF ty_opt1_xls.

  "파일명 선택
  PERFORM get_file_name CHANGING lv_file.

  "EXCEL 조회
  CHECK lv_file IS NOT INITIAL.
  PERFORM get_excel_data USING 1 2 33 60000 lv_file 'TY_OPT1_XLS' CHANGING lt_xls.

  "데이터 설정
  PERFORM set_alv_data_opt1 USING lt_xls CHANGING gt_create .

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F_GET_FILE_NAME
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      <-- LV_FILE
*&---------------------------------------------------------------------*
FORM get_file_name  CHANGING cv_file.

  CLEAR cv_file.

  DATA:
    lt_file_table TYPE filetable,
    lv_subrc      TYPE sy-subrc,
    lv_action     TYPE i.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
*     WINDOW_TITLE            = ''
      default_extension       = cl_gui_frontend_services=>filetype_excel
*     DEFAULT_FILENAME        = ''
      file_filter             = cl_gui_frontend_services=>filetype_excel
*     WITH_ENCODING           = ''
*     INITIAL_DIRECTORY       = 'C:\'
*     MULTISELECTION          = ' '
    CHANGING
      file_table              = lt_file_table
      rc                      = lv_subrc
      user_action             = lv_action
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc EQ 0 AND lt_file_table[] IS NOT INITIAL.
    READ TABLE lt_file_table ASSIGNING FIELD-SYMBOL(<ls_file>) INDEX 1.
    CHECK sy-subrc EQ 0.
    cv_file = <ls_file>-filename.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_EXCEL_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_1
*&      --> P_4
*&      --> P_1
*&      --> P_6000
*&      <-- LT_XLS
*&---------------------------------------------------------------------*
FORM get_excel_data  USING pv_begin_col
                                                      pv_begin_row
                                                      pv_end_col
                                                      pv_end_row
                                                      pv_file
                                                      pv_t_type
                       CHANGING ct_xls TYPE STANDARD TABLE.
  CLEAR:
     ct_xls[].

  DATA lt_itab TYPE STANDARD TABLE OF alsmex_tabline.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = pv_file
      i_begin_col             = pv_begin_col
      i_begin_row             = pv_begin_row
      i_end_col               = pv_end_col
      i_end_row               = pv_end_row
    TABLES
      intern                  = lt_itab
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  CHECK sy-subrc EQ 0.

  DATA:
    lo_data    TYPE REF TO data,
    lv_col_idx TYPE int4.

  FIELD-SYMBOLS <ls_stru> TYPE any.

  CREATE DATA lo_data TYPE (pv_t_type).
  ASSIGN lo_data->* TO <ls_stru>.

  LOOP AT lt_itab ASSIGNING FIELD-SYMBOL(<ls_g>) GROUP BY ( row = <ls_g>-row )
                                                                             ASSIGNING FIELD-SYMBOL(<ls_group>).

    "값 설정
    CLEAR <ls_stru>.
    LOOP AT GROUP <ls_group> ASSIGNING FIELD-SYMBOL(<ls_xls>).
      lv_col_idx = <ls_xls>-col.
      ASSIGN COMPONENT lv_col_idx OF STRUCTURE <ls_stru> TO FIELD-SYMBOL(<lv_val>).
      CHECK <lv_val> IS ASSIGNED.
      <lv_val> = <ls_xls>-value.
    ENDLOOP.

    "라인추가
    APPEND <ls_stru> TO ct_xls.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_ALV_DATA_OPT1
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_XLS
*&      <-- GT_OPT1
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM set_alv_data_opt1  USING  pt_xls TYPE ty_t_opt1_xls
                          CHANGING ct_opt1 LIKE gt_create.

  "초기화
  CLEAR:
    gv_err,
    ct_opt1[].

  DATA:
    lt_fname   TYPE ty_t_fname,
    ls_opt1    LIKE gs_create,
    lv_drqty   TYPE dec4,
    lv_amt_ext TYPE bapicurr-bapicurr,
    lv_amt_int TYPE matdoc-dmbtr.

  DATA :
    lv_jakno   TYPE kdkg4,
    lv_leng(6),
    lv_msg     TYPE bapi_msg,
    lt_drum    TYPE STANDARD TABLE OF zgtedsif0038.

  DATA :
    lt_lines TYPE TABLE OF  tline,
    lv_line  TYPE string,
    lv_name  TYPE thead-tdname.

  lt_fname = VALUE #( ( fname =  'LIFNR' )
*                                     ( FNAME =  'BUKRS' )
*                                     ( FNAME =  'EKORG' )
*                                     ( FNAME =  'EKGRP' )
                                     ( fname =  'MATNR' )
                                     ( fname =  'ZZMAKTX80' )
*                                     ( FNAME =  'WERKS' )
                                     ( fname =  'LGORT' )
                                     ( fname =  'EMLIF' )
                                     ( fname =  'MENGE' )
                                     ( fname =  'MEINS' )
                                     ( fname =  'LENGTH' )
                                     ( fname =  'DRQTY' )
                                     ( fname =  'NETPR' )
                                     ( fname =  'PEINH' )
                                     ( fname =  'WAERS' )
                                     ( fname =  'MWSKZ' )
                                     ( fname =  'EINDT' )
                                     ( fname =  'INSMK' )
                                     ( fname =  'ZMEMO' )
                                     ( fname =  'UEBTO' )
                                     ( fname =  'RETPO' )
                                     ( fname =  'ZFREE' )
                                     ( fname =  'KNTTP' )  "계정지정범주
                                     ( fname =  'MATKL' )
                                     ( fname =  'PSTYP' ) "품목범주
                                     ( fname =  'VBELN' )
                                     ( fname =  'VBELP' )
                                     ( fname =  'KOSTL' )
                                     ( fname =  'SAKTO' )
                                     ( fname =  'ANLN1' )
                                     ( fname =  'ANLN2' )
                                     ( fname =  'PS_PSP_PNR' )
                                     ( fname =  'AUFNR' ) ).

  LOOP AT pt_xls ASSIGNING FIELD-SYMBOL(<ls_xls>).
    CLEAR ls_opt1.
    "대문자 변경
    TRANSLATE:
      <ls_xls>-knttp TO UPPER CASE,
      <ls_xls>-pstyp TO UPPER CASE,
      <ls_xls>-matnr TO UPPER CASE,
*      <LS_XLS>-WERKS TO UPPER CASE,
      <ls_xls>-lgort TO UPPER CASE,
*      <LS_XLS>-EKORG TO UPPER CASE,
*      <LS_XLS>-EKGRP TO UPPER CASE,
      <ls_xls>-lifnr TO UPPER CASE,
      <ls_xls>-emlif TO UPPER CASE,
      <ls_xls>-waers TO UPPER CASE,
      <ls_xls>-vbeln TO UPPER CASE.

    "콤마 제거
    REPLACE ALL OCCURRENCES OF ',' IN <ls_xls>-netpr WITH space.
    REPLACE ALL OCCURRENCES OF ',' IN <ls_xls>-menge WITH space.
    REPLACE ALL OCCURRENCES OF ',' IN <ls_xls>-length WITH space.
    REPLACE ALL OCCURRENCES OF ',' IN <ls_xls>-drqty WITH space.

    "숫자만 남기고 제거)
    ##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF REGEX '\D' IN <ls_xls>-eindt WITH space.
    ##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF REGEX '\D' IN <ls_xls>-peinh  WITH space.
    ##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF REGEX '\D' IN <ls_xls>-vbelp WITH space.

    "공백 제거
    CONDENSE:
      <ls_xls>-netpr,
      <ls_xls>-menge,
      <ls_xls>-eindt,
      <ls_xls>-peinh,
      <ls_xls>-vbelp.

    "값 설정
    ls_opt1 = CORRESPONDING #( BASE ( ls_opt1 )  <ls_xls> ).

*INPUT VALIDATION.
    IF ls_opt1-retpo IS INITIAL OR ls_opt1-retpo = gc_x.
    ELSE.
      ls_opt1-status = icon_led_red.
      ls_opt1-message = TEXT-e21."반품 지시자는 ' ' OR 'X' 입니다.
    ENDIF.

    IF ls_opt1-zfree IS INITIAL OR ls_opt1-zfree = gc_x.
    ELSE.
      ls_opt1-status = icon_led_red.
      ls_opt1-message = TEXT-e22."무상 지시자는 ' ' OR 'X' 입니다.
    ENDIF.

    "ALPHA CONVERSION
    ls_opt1-lifnr = |{ ls_opt1-lifnr ALPHA = IN }|.
    ls_opt1-emlif = |{ ls_opt1-emlif ALPHA = IN }|.
    ls_opt1-vbeln = |{ ls_opt1-vbeln ALPHA = IN }|.
    ls_opt1-vbelp = |{ ls_opt1-vbelp ALPHA = IN }|.

    "단위
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input  = ls_opt1-meins
      IMPORTING
        output = ls_opt1-meins.

    "자재코드
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = ls_opt1-matnr
      IMPORTING
        output = ls_opt1-matnr.

    IF ls_opt1-netpr IS NOT INITIAL AND ls_opt1-waers IS NOT INITIAL.
      CLEAR:
       lv_amt_ext,
       lv_amt_int.

      "금액 변환(EXT - > INT)
      lv_amt_ext = ls_opt1-netpr.
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
        EXPORTING
          currency             = ls_opt1-waers
          amount_external      = lv_amt_ext
          max_number_of_digits = 23
        IMPORTING
          amount_internal      = lv_amt_int.

      ls_opt1-netpr = lv_amt_int.
    ENDIF.

    APPEND ls_opt1 TO ct_opt1.

  ENDLOOP.

  CHECK ct_opt1[] IS NOT INITIAL. "데이터가 있으면 진행

  SELECT
    mr~matnr,
    mr~meins,
    mr~matkl,
    mr~zzmaktx80,
    mt~maktx
    FROM mara AS mr
    LEFT OUTER JOIN  makt AS mt
    ON mr~matnr EQ mt~matnr
    AND mt~spras EQ @sy-langu
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT zz~matnr
        FROM @ct_opt1 AS zz
        WHERE zz~matnr EQ mr~matnr
    )
    ORDER BY mr~matnr
    INTO TABLE @DATA(lt_mara).

  SELECT l~lifnr, l~name1
    FROM lfa1 AS l
##ITAB_KEY_IN_SELECT
    WHERE EXISTS ( SELECT c~lifnr
                                FROM @ct_opt1 AS c
                                WHERE c~lifnr EQ l~lifnr
                                      OR c~emlif EQ l~lifnr )
    ORDER BY l~lifnr INTO TABLE @DATA(lt_lfa1).



  SELECT
    mc~matnr,
    mc~werks,
    mc~ekgrp,
    mc~dpcbt,
    mc~insmk,
    mw~stprs
    FROM marc AS mc
                  LEFT OUTER JOIN
              mbew AS mw ON mc~matnr EQ mw~matnr
                                AND mc~werks EQ mw~bwkey
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT zz~matnr
        FROM @ct_opt1 AS zz
        WHERE zz~matnr EQ mc~matnr

    ) AND mc~werks EQ @p_werks
    ORDER BY mc~matnr, mc~werks
    INTO TABLE @DATA(lt_marc).


*  SELECT P~VBELN, P~POSNR AS VBELP
*    FROM VBAP AS P
*##ITAB_KEY_IN_SELECT
*    WHERE EXISTS ( SELECT C~VBELN, C~VBELP
*                                FROM @CT_OPT1 AS C
*                                WHERE C~VBELN EQ P~VBELN
*                                     AND C~VBELP EQ P~POSNR )
*    ORDER BY P~VBELN INTO TABLE @DATA(LT_VBAP).

  SELECT
    p~vbeln,
    p~posnr AS vbelp,
    p~matnr,
    p~kwmeng,
    p~vrkme,
    p~length,
    p~drqty,
    p~mcontents
    FROM zgtmm_cv_so_vcvalue_main AS p
##ITAB_KEY_IN_SELECT
    WHERE EXISTS ( SELECT c~vbeln, c~vbelp
                                FROM @ct_opt1 AS c
                                WHERE c~vbeln EQ p~vbeln
                                     AND c~vbelp EQ p~posnr )
    ORDER BY p~vbeln, p~posnr INTO TABLE @DATA(lt_vbap).

*  SELECT
*    I~LIFNR, I~MATNR,
*    I~KBETR AS NETPR,  I~KPEIN AS PEINH ,
*    I~KONWA AS WAERS, I~MWSKZ, I~INFNR
*    FROM ZGTMM_CV_GET_INFOPRICE AS I
*##ITAB_KEY_IN_SELECT
*    WHERE EXISTS (
*      SELECT ZZ~LIFNR, ZZ~MATNR, ZZ~PSTYP,
*                   ZZ~EKORG, ZZ~WERKS, ZZ~EINDT
*        FROM @CT_OPT1 AS ZZ
*        WHERE ZZ~LIFNR EQ I~LIFNR
*             AND ZZ~MATNR EQ I~MATNR
*             AND ZZ~PSTYP EQ I~ESOKZ
*             AND ZZ~EKORG EQ I~EKORG
*             AND ZZ~WERKS EQ I~WERKS
*             AND ZZ~EINDT >= I~DATAB
*             AND ZZ~EINDT <= I~DATBI
*    )
*    ORDER BY I~LIFNR, I~MATNR
*    INTO TABLE @DATA(LT_INFO).
*  "회사코드
  SELECT SINGLE butxt
    FROM t001
    WHERE bukrs = @p_bukrs
    INTO @DATA(lv_txt).
*   "플랜트
  READ TABLE gt_t001w ASSIGNING FIELD-SYMBOL(<ls_t001w>)
  WITH TABLE KEY werks = p_werks.
*  "구매조직
  READ TABLE gt_t024e ASSIGNING FIELD-SYMBOL(<ls_t024e>)
  WITH TABLE KEY ekorg = p_ekorg.
*  "구매그룹
  READ TABLE gt_t024 ASSIGNING FIELD-SYMBOL(<ls_t024>)
  WITH TABLE KEY ekgrp = p_ekgrp.

*특성정보(설계번호/개정번호)
  SELECT matnr, atnam, atwrt
    FROM zgtsd_i_materialcharacteristic AS p
##ITAB_KEY_IN_SELECT
    WHERE EXISTS ( SELECT c~matnr
                                FROM @ct_opt1 AS c
                                WHERE c~matnr EQ p~matnr )
    ORDER BY matnr, atnam INTO TABLE @DATA(lt_char).

  LOOP AT ct_opt1 ASSIGNING FIELD-SYMBOL(<ls_opt1>).

    <ls_opt1>-bukrs = p_bukrs.
    <ls_opt1>-butxt = lv_txt.
    <ls_opt1>-werks = p_werks.
    IF <ls_t001w> IS ASSIGNED.
      <ls_opt1>-werks_n = <ls_t001w>-name1.
    ENDIF.
    <ls_opt1>-ekorg = p_ekorg.
    IF <ls_t024e> IS ASSIGNED.
      <ls_opt1>-ekotx = <ls_t024e>-ekotx.
    ENDIF.
    <ls_opt1>-ekgrp = p_ekgrp.
    IF <ls_t024> IS ASSIGNED.
      <ls_opt1>-eknam = <ls_t024>-eknam.
    ENDIF.

    IF <ls_opt1>-lifnr IS NOT INITIAL.
      READ TABLE lt_lfa1 ASSIGNING FIELD-SYMBOL(<ls_l>) WITH KEY lifnr = <ls_opt1>-lifnr BINARY SEARCH.
      IF sy-subrc EQ 0.
        <ls_opt1>-lifnr_n = <ls_l>-name1.
      ENDIF.
    ENDIF.

    IF <ls_opt1>-matnr IS NOT INITIAL.
      READ TABLE lt_mara ASSIGNING FIELD-SYMBOL(<ls_mara>) WITH KEY matnr = <ls_opt1>-matnr BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF <ls_opt1>-zzmaktx80 = '' .
          <ls_opt1>-zzmaktx80 = COND #( WHEN <ls_mara>-zzmaktx80 IS INITIAL THEN <ls_mara>-maktx
                                                                 ELSE <ls_mara>-zzmaktx80 ).  ENDIF.
*"1) POSSIBLE ENTRY OR 입력 가능
        <ls_opt1>-matkl = COND #( WHEN <ls_opt1>-matkl IS INITIAL THEN <ls_mara>-matkl
                                                       ELSE <ls_opt1>-matkl ).
        "1) POSSIBLE ENTRY OR 입력 가능
        <ls_opt1>-meins = COND #( WHEN <ls_opt1>-meins IS INITIAL THEN <ls_mara>-meins
                                                       ELSE <ls_opt1>-meins ).
      ENDIF.

    ELSE.
      IF <ls_opt1>-knttp IS NOT INITIAL.
        <ls_opt1>-style = VALUE #( BASE <ls_opt1>-style ( fieldname = 'MATKL' style = cl_gui_alv_grid=>mc_style_enabled ) ).
      ELSE.
        <ls_opt1>-style = VALUE #( BASE <ls_opt1>-style ( fieldname = 'MATKL' style = cl_gui_alv_grid=>mc_style_disabled ) ).
      ENDIF.
    ENDIF.

    IF <ls_opt1>-emlif IS NOT INITIAL.
      READ TABLE lt_lfa1 ASSIGNING FIELD-SYMBOL(<ls_f>) WITH KEY lifnr = <ls_opt1>-emlif BINARY SEARCH.
      IF sy-subrc EQ 0.
        <ls_opt1>-emlif_n = <ls_f>-name1.
      ENDIF.
    ENDIF.


    IF <ls_opt1>-vbeln IS NOT INITIAL AND  <ls_opt1>-vbelp IS NOT INITIAL.
      CLEAR : <ls_opt1>-length, <ls_opt1>-drqty, <ls_opt1>-menge , <ls_opt1>-meins,
                    <ls_opt1>-mcontents, <ls_opt1>-zmemo_s.

      READ TABLE lt_vbap ASSIGNING FIELD-SYMBOL(<ls_p>)
      WITH KEY vbeln = <ls_opt1>-vbeln
                      vbelp = <ls_opt1>-vbelp BINARY SEARCH.
      IF sy-subrc NE 0.
        CLEAR : <ls_opt1>-vbeln,  <ls_opt1>-vbelp.
        <ls_opt1>-status = icon_led_red.
        <ls_opt1>-message = TEXT-e23 && TEXT-e24.
      ELSE.
        <ls_opt1>-length =   <ls_p>-length.
        <ls_opt1>-drqty =   <ls_p>-drqty   .
        <ls_opt1>-menge =   <ls_p>-kwmeng   .
        <ls_opt1>-meins =   <ls_p>-vrkme   .
        <ls_opt1>-mcontents =   <ls_p>-mcontents   .
      ENDIF.

      CLEAR : lt_lines, lv_line, lv_name.
      lv_name = <ls_opt1>-vbeln && <ls_opt1>-vbelp.
*판매오더 품목 특기사항 설정
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id        = '0001' "품목텍스트
          language  = sy-langu
          name      = lv_name
          object    = 'VBBP'
        TABLES
          lines     = lt_lines
        EXCEPTIONS
          not_found = 4.

      IF sy-subrc = 0.
        IF lt_lines[] IS NOT INITIAL.
          LOOP AT lt_lines INTO DATA(ls_l).
            lv_line &&= ls_l-tdline.
            AT LAST.
              lv_line &&= ' '.
            ENDAT.
          ENDLOOP.
          <ls_opt1>-zmemo_s = lv_line.
        ENDIF.
      ENDIF.

    ELSE.
      CLEAR : <ls_opt1>-length, <ls_opt1>-drqty, <ls_opt1>-mcontents, <ls_opt1>-zmemo_s.
    ENDIF.

*단일단위배치기본값
    READ TABLE lt_marc ASSIGNING FIELD-SYMBOL(<mc>) WITH KEY werks = p_werks
                                                                                                          matnr = <ls_opt1>-matnr BINARY SEARCH.
    IF sy-subrc EQ 0.
      <ls_opt1>-dpcbt = <mc>-dpcbt.
      <ls_opt1>-insmk = <mc>-insmk.
    ENDIF.

    IF <ls_opt1>-dpcbt IS INITIAL.
*       CLEAR : <LS_OPT1>-LENGTH, <LS_OPT1>-DRQTY.
      <ls_opt1>-style = VALUE #( BASE <ls_opt1>-style
         ( fieldname = 'LENGTH' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'DRQTY' style = cl_gui_alv_grid=>mc_style_disabled ) ).
    ELSE.
      <ls_opt1>-style = VALUE #( BASE <ls_opt1>-style
         ( fieldname = 'LENGTH' style = cl_gui_alv_grid=>mc_style_enabled )
         ( fieldname = 'DRQTY' style = cl_gui_alv_grid=>mc_style_enabled ) ).
    ENDIF.

*조장 데이터 있으면, 드럼 수 자동계산&목드럼 자재코드 조회
    IF <ls_opt1>-length IS NOT INITIAL .
      CLEAR lv_drqty.
      lv_drqty = <ls_opt1>-menge / <ls_opt1>-length.

      IF frac( lv_drqty ) <> 0.
*        <LS_OPT1>-STATUS = ICON_LED_RED.
        <ls_opt1>-message = '조장을 점검하세요(소숫점 존재).'.
      ELSE.
        "소숫점 없으면, 드럼 수 자동계산 데이터 업데이트.
        <ls_opt1>-drqty = lv_drqty.
      ENDIF.
*목드럼 자재코드 조회 수행(조장>0 때만)
      IF <ls_opt1>-length > 0.
        IF <ls_opt1>-dpcbt IS INITIAL.
          SELECT SINGLE dpcbt
            FROM marc
            WHERE werks = @<ls_opt1>-werks
                 AND matnr = @<ls_opt1>-matnr
                INTO @DATA(lv_dpcbt2).
        ENDIF.

        IF <ls_opt1>-dpcbt = 'C' OR lv_dpcbt2 = 'C'.
          lv_jakno = ''. "고객그룹코드
          DATA(lv_int) = CONV i( trunc( <ls_opt1>-length ) ). "조장_소숫점 버림
          lv_leng = lv_int.   CONDENSE lv_leng NO-GAPS.
*     "설계번호/개정번호
          READ TABLE lt_char ASSIGNING FIELD-SYMBOL(<chd>)
          WITH KEY matnr = <ls_opt1>-matnr
                         atnam =  'PD_CA_DESIGN_NO' BINARY SEARCH. " ZDGNO
          IF sy-subrc = 0.
            <ls_opt1>-zdgno = <chd>-atwrt.
          ENDIF.
*      "개정번호
          READ TABLE lt_char ASSIGNING FIELD-SYMBOL(<chr>)
          WITH KEY matnr = <ls_opt1>-matnr
                         atnam =  'PD_CA_DESIGN_REV_NO' BINARY SEARCH. " ZREVNO
          IF sy-subrc = 0.
            <ls_opt1>-zrevno = <chr>-atwrt.
          ENDIF.

          TRY.
              CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
                EXPORTING
                  iv_sul_no    = <ls_opt1>-zdgno
                  iv_rev_seq   = <ls_opt1>-zrevno
                  iv_jakno     = lv_jakno
                  iv_jojang    = lv_leng
                  iv_drum_code = 'H'
                  iv_flag_pp   = 'X'
                TABLES
                  ot_return    = lt_drum.
            CATCH cx_root INTO DATA(lv_error).
              lv_msg = lv_error->get_text( ).
              MESSAGE s000 WITH lv_msg.
          ENDTRY.

          IF lt_drum IS NOT INITIAL.
            READ TABLE lt_drum ASSIGNING FIELD-SYMBOL(<drum>) INDEX 2.
            IF sy-subrc = 0.
              <ls_opt1>-drmatnr = <drum>-drum_matnr.
              <ls_opt1>-drumname = <drum>-maktx.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*    <LS_OPT1>-LENGTH = COND #( WHEN <LS_OPT1>-DRQTY IS INITIAL THEN <LS_OPT1>-LENGTH
*                                                     ELSE ( <LS_OPT1>-MENGE / <LS_OPT1>-DRQTY ) ).
*    IF FRAC( <LS_OPT1>-LENGTH ) <> 0.
*      <LS_OPT1>-STATUS = ICON_LED_RED.
*      <LS_OPT1>-MESSAGE = '조장을 점검하세요(소숫점 존재).'(E19).
*    ENDIF.
*
*    <LS_OPT1>-DRQTY = COND #( WHEN <LS_OPT1>-LENGTH IS INITIAL THEN <LS_OPT1>-DRQTY
*                                                    ELSE ( <LS_OPT1>-MENGE / <LS_OPT1>-LENGTH ) ).
*    IF FRAC( <LS_OPT1>-DRQTY ) <> 0.
*      <LS_OPT1>-STATUS = ICON_LED_RED.
*      <LS_OPT1>-MESSAGE = '드럼수를 점검하세요(소숫점 존재).'(E20).
*    ENDIF.

*품목범주
    <ls_opt1>-pstyp = COND #( WHEN <ls_opt1>-pstyp IS INITIAL THEN '0'
                                                   ELSE <ls_opt1>-pstyp ).

    SELECT SINGLE meprf
        FROM eina AS a
        INNER JOIN eine AS b
        ON a~infnr = b~infnr
        WHERE a~lifnr =  @<ls_opt1>-lifnr
            AND a~matnr = @<ls_opt1>-matnr
            AND b~esokz = @<ls_opt1>-pstyp
            AND b~ekorg = @<ls_opt1>-ekorg
            AND b~werks = @<ls_opt1>-werks INTO @DATA(lv_meprf).

    IF lv_meprf = '5'.
      SELECT SINGLE kbetr AS netpr, kpein AS peinh,
                               konwa AS waers,
                               mwskz, infnr
                   FROM zgtmm_cv_get_infoprice
                   WHERE lifnr  = @<ls_opt1>-lifnr
                        AND matnr = @<ls_opt1>-matnr
                        AND esokz = @<ls_opt1>-pstyp
                        AND ekorg = @<ls_opt1>-ekorg
                        AND werks = @<ls_opt1>-werks
*                        AND DATAB <= @<LS_OPT1>-EINDT
*                        AND DATBI >= @<LS_OPT1>-EINDT INTO @DATA(LS_INFO).
                        AND datab <= @sy-datum
                        AND datbi >= @sy-datum INTO @DATA(ls_info).
      IF sy-subrc = 0.
        <ls_opt1>-netpr_i = ls_info-netpr.
        <ls_opt1>-peinh_i   = ls_info-peinh.
        <ls_opt1>-waers_i = ls_info-waers.
        <ls_opt1>-mwskz_i = ls_info-mwskz.
        <ls_opt1>-netpr = ls_info-netpr.
        <ls_opt1>-peinh   = ls_info-peinh.
        <ls_opt1>-waers = ls_info-waers.
        <ls_opt1>-mwskz = ls_info-mwskz.
        <ls_opt1>-infnr       = ls_info-infnr.
      ENDIF.

    ELSE.
      SELECT SINGLE kbetr AS netpr, kpein AS peinh,
                               konwa AS waers,
                               mwskz, infnr
                   FROM zgtmm_cv_get_infoprice
                   WHERE lifnr  = @<ls_opt1>-lifnr
                        AND matnr = @<ls_opt1>-matnr
                        AND esokz = @<ls_opt1>-pstyp
                        AND ekorg = @<ls_opt1>-ekorg
                        AND werks = @<ls_opt1>-werks
                        AND datab <= @sy-datum
                        AND datbi >= @sy-datum INTO @DATA(ls_info2).
      IF sy-subrc = 0.
        <ls_opt1>-netpr_i = ls_info2-netpr.
        <ls_opt1>-peinh_i   = ls_info2-peinh.
        <ls_opt1>-waers_i = ls_info2-waers.
        <ls_opt1>-mwskz_i = ls_info2-mwskz..
        <ls_opt1>-netpr = ls_info2-netpr.
        <ls_opt1>-peinh   = ls_info2-peinh.
        <ls_opt1>-waers = ls_info2-waers.
        <ls_opt1>-mwskz = ls_info2-mwskz.
        <ls_opt1>-infnr       = ls_info2-infnr.
      ENDIF.
    ENDIF.

    CLEAR lv_meprf.
*    IF <LS_OPT1>-LIFNR IS NOT INITIAL AND <LS_OPT1>-MATNR IS NOT INITIAL.
*      READ TABLE LT_INFO ASSIGNING FIELD-SYMBOL(<INFO>)
*      WITH KEY LIFNR = <LS_OPT1>-LIFNR
*                     MATNR = <LS_OPT1>-MATNR BINARY SEARCH.
*      IF SY-SUBRC = 0.
*        <LS_OPT1>-NETPR = <INFO>-NETPR.
*        <LS_OPT1>-PEINH = <INFO>-PEINH.
*        <LS_OPT1>-WAERS = <INFO>-WAERS.
*        <LS_OPT1>-MWSKZ = <INFO>-MWSKZ.
*        <LS_OPT1>-INFNR = <INFO>-INFNR.
*      ENDIF.
*    ENDIF.

    IF <ls_opt1>-netpr > 0.
      CLEAR : <ls_opt1>-zfree, <ls_opt1>-infnr.
    ENDIF.

    IF <ls_opt1>-zfree = gc_x.
      CLEAR : <ls_opt1>-netpr, <ls_opt1>-peinh.
    ENDIF.

*텍스트 설정
    PERFORM set_code_text_opt1 USING lt_fname CHANGING <ls_opt1>.

*입력 가능 필드 설정
    <ls_opt1>-style = VALUE #( BASE <ls_opt1>-style
        ( fieldname = 'MATNR' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'MEINS' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'ZZMAKTX80' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'LIFNR' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'LGORT' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'EMLIF' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'NETPR' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'PEINH' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'WAERS' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'MWSKZ' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'EINDT' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'INSMK' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'ZMEMO' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'UEBTO' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'RETPO' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'ZFREE' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'KNTTP' style = cl_gui_alv_grid=>mc_style_enabled )
        ( fieldname = 'PSTYP' style = cl_gui_alv_grid=>mc_style_enabled )  ).

*계정 지정 범주에 따른 관련 필드 별 편집 가능/불가능 제어
    CASE <ls_opt1>-knttp.
      WHEN gc_m. "SD-CO없는 개별 고객
        CLEAR : <ls_opt1>-kostl, <ls_opt1>-sakto, <ls_opt1>-anln1,
                     <ls_opt1>-anln2, <ls_opt1>-aufnr.

        <ls_opt1>-style = VALUE #( BASE <ls_opt1>-style
         ( fieldname = 'VBELN' style = cl_gui_alv_grid=>mc_style_enabled )
         ( fieldname = 'VBELP' style = cl_gui_alv_grid=>mc_style_enabled )
         ( fieldname = 'KOSTL' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'SAKTO' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'ANLN1' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'ANLN2' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'PS_PSP_PNR' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'AUFNR' style = cl_gui_alv_grid=>mc_style_disabled )  ).

      WHEN gc_k. "코스트센터
        CLEAR : <ls_opt1>-vbeln, <ls_opt1>-vbelp, <ls_opt1>-anln1,
                     <ls_opt1>-anln2,  <ls_opt1>-aufnr.

        <ls_opt1>-style = VALUE #( BASE <ls_opt1>-style
         ( fieldname = 'VBELN' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'VBELP' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'KOSTL' style = cl_gui_alv_grid=>mc_style_enabled )
         ( fieldname = 'SAKTO' style = cl_gui_alv_grid=>mc_style_enabled )
         ( fieldname = 'ANLN1' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'ANLN2' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'PS_PSP_PNR' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'AUFNR' style = cl_gui_alv_grid=>mc_style_disabled )  ).

      WHEN gc_a. "자산
        CLEAR : <ls_opt1>-vbeln, <ls_opt1>-vbelp, <ls_opt1>-kostl,
                     <ls_opt1>-sakto,  <ls_opt1>-aufnr.

        <ls_opt1>-style = VALUE #( BASE <ls_opt1>-style
         ( fieldname = 'VBELN' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'VBELP' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'KOSTL' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'SAKTO' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'ANLN1' style = cl_gui_alv_grid=>mc_style_enabled )
         ( fieldname = 'ANLN2' style = cl_gui_alv_grid=>mc_style_enabled )
         ( fieldname = 'PS_PSP_PNR' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'AUFNR' style = cl_gui_alv_grid=>mc_style_disabled )  ).

      WHEN gc_p. "프로젝트
        CLEAR : <ls_opt1>-vbeln, <ls_opt1>-vbelp, <ls_opt1>-kostl,
                     <ls_opt1>-anln1, <ls_opt1>-anln2, <ls_opt1>-aufnr.

        <ls_opt1>-style = VALUE #( BASE <ls_opt1>-style
         ( fieldname = 'VBELN' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'VBELP' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'KOSTL' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'SAKTO' style = cl_gui_alv_grid=>mc_style_enabled )
         ( fieldname = 'ANLN1' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'ANLN2' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'PS_PSP_PNR' style = cl_gui_alv_grid=>mc_style_enabled )
         ( fieldname = 'AUFNR' style = cl_gui_alv_grid=>mc_style_disabled )  ).

      WHEN gc_f. "오더
        CLEAR : <ls_opt1>-vbeln, <ls_opt1>-vbelp, <ls_opt1>-kostl,
                     <ls_opt1>-anln1, <ls_opt1>-anln2.

        <ls_opt1>-style = VALUE #( BASE <ls_opt1>-style
         ( fieldname = 'VBELN' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'VBELP' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'KOSTL' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'SAKTO' style = cl_gui_alv_grid=>mc_style_enabled )
         ( fieldname = 'ANLN1' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'ANLN2' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'PS_PSP_PNR' style = cl_gui_alv_grid=>mc_style_disabled )
         ( fieldname = 'AUFNR' style = cl_gui_alv_grid=>mc_style_enabled )  ).
      WHEN OTHERS.
    ENDCASE.

*    MODIFY CT_OPT1 FROM <LS_OPT1>.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_CODE_TEXT_OPT1
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LT_FNAME
*&      <-- <LS_OPT1>
*&---------------------------------------------------------------------*
FORM set_code_text_opt1  USING  pt_fname TYPE ty_t_fname
                           CHANGING cs_opt1 LIKE gs_create.

  "계정 지정 범주
*  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'KNTTP' TRANSPORTING NO FIELDS.
*  IF SY-SUBRC EQ 0.
*    CLEAR CS_OPT1-KNTTX. "초기화
*    READ TABLE GT_T163I ASSIGNING FIELD-SYMBOL(<LS_T163I>) WITH TABLE KEY KNTTP = CS_OPT1-KNTTP.
*    IF SY-SUBRC EQ 0.
*      CS_OPT1-KNTTX = <LS_T163I>-KNTTX.
*    ENDIF.
*  ENDIF.

*  "품목 범주
*  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'PSTYP' TRANSPORTING NO FIELDS.
*  IF SY-SUBRC EQ 0.
*    CLEAR CS_OPT1-PTEXT. "초기화
*    READ TABLE GT_T163Y ASSIGNING FIELD-SYMBOL(<LS_T163Y>) WITH TABLE KEY PSTYP = CS_OPT1-PSTYP.
*    IF SY-SUBRC EQ 0.
*      CS_OPT1-PTEXT = <LS_T163Y>-PTEXT.
*    ENDIF.
*  ENDIF.

*  "자재 그룹
*  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'MATKL' TRANSPORTING NO FIELDS.
*  IF SY-SUBRC EQ 0.
*    CLEAR CS_OPT1-WGBEZ. "초기화
*    READ TABLE GT_T023T ASSIGNING FIELD-SYMBOL(<LS_T023T>) WITH TABLE KEY MATKL = CS_OPT1-MATKL.
*    IF SY-SUBRC EQ 0.
*      CS_OPT1-WGBEZ = <LS_T023T>-WGBEZ.
*    ENDIF.
*  ENDIF.

*  "플랜트
*  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'WERKS' TRANSPORTING NO FIELDS.
*  IF SY-SUBRC EQ 0.
*    CLEAR CS_OPT1-WERKS_N. "초기화
*    READ TABLE GT_T001W ASSIGNING FIELD-SYMBOL(<LS_T001W>) WITH TABLE KEY WERKS = CS_OPT1-WERKS.
*    IF SY-SUBRC EQ 0.
*      CS_OPT1-WERKS_N = <LS_T001W>-NAME1.
*    ENDIF.
*  ENDIF.

  "저장위치
  READ TABLE pt_fname WITH TABLE KEY fname = 'WERKS' TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    READ TABLE pt_fname WITH TABLE KEY fname = 'LGORT' TRANSPORTING NO FIELDS.
  ENDIF.
  IF sy-subrc EQ 0.
    CLEAR cs_opt1-lgobe. "초기화
    READ TABLE gt_t001l ASSIGNING FIELD-SYMBOL(<ls_t001l>) WITH TABLE KEY werks = cs_opt1-werks
                                                                                                                              lgort = cs_opt1-lgort.
    IF sy-subrc EQ 0.
      cs_opt1-lgobe = <ls_t001l>-lgobe.
    ENDIF.
  ENDIF.

*  "구매조직
*  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'EKORG' TRANSPORTING NO FIELDS.
*  IF SY-SUBRC EQ 0.
*    CLEAR CS_OPT1-EKOTX. "초기화
*    READ TABLE GT_T024E ASSIGNING FIELD-SYMBOL(<LS_T024E>) WITH TABLE KEY EKORG = CS_OPT1-EKORG.
*    IF SY-SUBRC EQ 0.
*      CS_OPT1-EKOTX = <LS_T024E>-EKOTX.
*    ENDIF.
*  ENDIF.
*
*  "구매그룹
*  READ TABLE PT_FNAME WITH TABLE KEY FNAME = 'EKGRP' TRANSPORTING NO FIELDS.
*  IF SY-SUBRC EQ 0.
*    CLEAR CS_OPT1-EKNAM. "초기화
*    READ TABLE GT_T024 ASSIGNING FIELD-SYMBOL(<LS_T024>) WITH TABLE KEY EKGRP = CS_OPT1-EKGRP.
*    IF SY-SUBRC EQ 0.
*      CS_OPT1-EKNAM = <LS_T024>-EKNAM.
*    ENDIF.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM DELETE_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM delete_data .

  CLEAR : gv_err.
  DATA : lt_list LIKE TABLE OF gs_list.

  IF sy-tcode = 'ZGTMMR3000'.
    PERFORM get_selected_rows USING gcl_grid.
  ELSE.
    PERFORM get_selected_rows USING gcl_grid_400.
  ENDIF.

  CHECK gv_err IS INITIAL.

  SORT gt_rows BY index DESCENDING.

  LOOP AT gt_rows ASSIGNING FIELD-SYMBOL(<gs_row>).

    READ TABLE gt_create INTO DATA(ls_cre) INDEX <gs_row>-index.
    IF sy-subrc = 0 AND ls_cre-ebeln IS NOT INITIAL.
      gv_err = gc_x.
      MESSAGE s000 WITH TEXT-e26 DISPLAY LIKE gc_e. EXIT.
      "작업 중인 데이터만 삭제 가능합니다.

    ELSE.
      DELETE gt_create INDEX <gs_row>-index.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CREATE_PO
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM create_po .

  DATA : ls_cre TYPE ty_cre_po,
         lv_msg TYPE bapi_msg.
  CLEAR : gv_answer, gv_err, gv_ques, gv_info, gt_char,
               gt_cre_po, gt_cre_bdc,  ls_cre, lv_msg.

  IF sy-tcode = 'ZGTMMR3000'.
    PERFORM get_selected_rows USING gcl_grid.
  ELSE.
    PERFORM get_selected_rows USING gcl_grid_400.
  ENDIF.

  CHECK gv_err IS INITIAL.

  LOOP AT gt_rows INTO gs_row.
    READ TABLE gt_create  INTO DATA(ls_list) INDEX gs_row-index.
    IF sy-subrc = 0 .
*이전 검증 결과 초기화
      CLEAR : ls_list-status, ls_list-message.

      IF ls_list-ebeln IS NOT INITIAL.
        gv_err = gc_x.
        MESSAGE s000 WITH '이미 구매오더 전환된 정보가 존재합니다.'(e27) DISPLAY LIKE gc_e. EXIT.
      ENDIF.
*필수값체크
      " 1. 비어있는 필드 텍스트 설정
      DATA(lv_field_name) = COND string(
        WHEN ls_list-lifnr      IS INITIAL THEN '공급업체'
        WHEN ls_list-bukrs     IS INITIAL THEN '회사코드'
        WHEN ls_list-ekorg     IS INITIAL THEN '구매조직'
        WHEN ls_list-ekgrp     IS INITIAL THEN '구매그룹'
        WHEN ls_list-eindt       IS INITIAL THEN '납품예정일'
        WHEN ls_list-zzmaktx80 IS INITIAL THEN '자재명'
        WHEN ls_list-werks     IS INITIAL THEN '플랜트'
        WHEN ls_list-menge     IS INITIAL THEN '수량'
        WHEN ls_list-meins       IS INITIAL THEN '단위' ).

      IF lv_field_name IS NOT INITIAL.
        gv_err = gc_x.
        ls_list-status  = icon_led_red.
        ls_list-message = |{ lv_field_name }는 필수 입력입니다.|.
        IF lv_msg IS INITIAL.
          lv_msg = ls_list-message. "최초 오류 메시지 보관
        ENDIF.
      ENDIF.

      " 1. 조건별로 맞춤형 에러 메시지를 동적 추출
      DATA(lv_err_msg) = COND string(
  " 조건 1: KNTTP와 MATNR이 둘 다 없는 경우
      WHEN ls_list-knttp IS INITIAL AND ls_list-matnr IS INITIAL
      THEN 'AAC과 자재번호가 모두 누락되었습니다.'

  " 조건 2: KNTTP가 없는데 계정 관련 정보가 입력된 경우
      WHEN ls_list-knttp IS INITIAL AND ( ls_list-vbeln IS NOT INITIAL OR ls_list-kostl IS NOT INITIAL
                OR ls_list-sakto IS NOT INITIAL OR ls_list-anln1 IS NOT INITIAL OR
                     ls_list-anln2 IS NOT INITIAL OR ls_list-aufnr IS NOT INITIAL )
      THEN 'AAC 필드 입력이 누락 되었습니다.'

  " 조건 3: DPCBT가 있는데 LENGTH나 DRQTY가 없는 경우
      WHEN ls_list-dpcbt IS NOT INITIAL AND ( ls_list-length IS INITIAL OR ls_list-drqty IS INITIAL )
      THEN '조장과 드럼수는 필수 입력입니다.'

  " 조건 4 & 5: 단가/세액코드 관련 누락 (정보레코드 및 무상지정이 아닐 때)
      WHEN ls_list-netpr IS INITIAL AND ls_list-infnr IS INITIAL AND ls_list-zfree IS INITIAL
      THEN '단가 또는 INFORECORD 또는 무상 정보 입력이 필요합니다.'
      WHEN ls_list-mwskz IS INITIAL AND ls_list-infnr IS INITIAL AND ls_list-zfree IS INITIAL
      THEN 'TAX 또는 INFORECORD 또는 무상 정보 입력이 필요합니다.'

  " 조건 6: 납기일과 정보레코드 누락
      WHEN ls_list-eindt IS INITIAL AND ls_list-infnr IS INITIAL
      THEN '납품예정일 또는 INFORECORD 입력은 필수 입니다.'

  " 조건 7: 자재그룹 누락 조건
      WHEN ls_list-matkl IS INITIAL AND ls_list-knttp IS NOT INITIAL AND ls_list-matnr IS INITIAL
      THEN '자재그룹  입력은 필수입니다.'

  " 조건 8 ~ 12: 계정지정유형(KNTTP)별 필수 값 체크
      WHEN ls_list-knttp = gc_m AND ( ls_list-vbeln     IS INITIAL OR ls_list-vbelp IS INITIAL )
      THEN '개별고객(M) 유형은 판매오더번호 필수 입력입니다.'
      WHEN ls_list-knttp = gc_k AND ( ls_list-kostl     IS INITIAL OR ls_list-sakto IS INITIAL )
      THEN '코스트센터(K) 유형은 코스트센터와 G/L계정이 필수 입력입니다.'
      WHEN ls_list-knttp = gc_a AND ( ls_list-anln1     IS INITIAL OR ls_list-anln2 IS INITIAL )
      THEN '자산(A) 유형은 자산번호가 필수 입력입니다.'
      WHEN ls_list-knttp = gc_p AND ( ls_list-ps_psp_pnr IS INITIAL OR ls_list-sakto IS INITIAL )
      THEN '프로젝트(P) 유형은 WBS요소와 G/L계정이 필수 입력입니다.'
      WHEN ls_list-knttp = gc_f AND ( ls_list-aufnr     IS INITIAL OR ls_list-sakto IS INITIAL )
      THEN '오더(F) 유형은 오더번호와 G/L계정이 필수 입력입니다.'

      ELSE space ).

      IF lv_err_msg IS NOT INITIAL AND ls_list-status IS INITIAL.
        gv_err = gc_x.
        ls_list-status    = icon_led_red.
        ls_list-message = lv_err_msg.
        IF lv_msg IS INITIAL.
          lv_msg = lv_err_msg. "최초 오류 메시지 보관
        ENDIF.
      ENDIF.

*      IF LS_LIST-LIFNR IS INITIAL OR LS_LIST-BUKRS IS INITIAL OR
*        LS_LIST-EKORG IS INITIAL OR LS_LIST-EKGRP IS INITIAL OR
*        LS_LIST-EINDT IS INITIAL OR
*        LS_LIST-ZZMAKTX80 IS INITIAL OR LS_LIST-WERKS IS INITIAL OR
*        LS_LIST-MENGE IS INITIAL OR LS_LIST-MEINS IS INITIAL .
*
*        GV_ERR = GC_X.
*        LS_LIST-STATUS = ICON_LED_RED.
*        LS_LIST-MESSAGE = '필수 입력 값이 누락되었습니다.'(E28).
*
*      ELSE.
*        LS_LIST-STATUS = COND #(
*        WHEN LS_LIST-KNTTP IS INITIAL AND LS_LIST-MATNR IS INITIAL THEN ICON_LED_RED
*        WHEN LS_LIST-KNTTP IS INITIAL AND ( LS_LIST-VBELN IS NOT INITIAL OR LS_LIST-KOSTL IS NOT INITIAL OR
*        LS_LIST-SAKTO IS NOT INITIAL OR LS_LIST-ANLN1 IS NOT INITIAL OR LS_LIST-ANLN2 IS NOT INITIAL  OR LS_LIST-AUFNR IS NOT INITIAL ) THEN ICON_LED_RED
*        WHEN LS_LIST-DPCBT IS NOT INITIAL AND
*        ( LS_LIST-LENGTH IS INITIAL OR  LS_LIST-DRQTY IS INITIAL ) THEN ICON_LED_RED
*        WHEN LS_LIST-NETPR IS INITIAL AND LS_LIST-INFNR IS INITIAL AND LS_LIST-ZFREE IS INITIAL THEN  ICON_LED_RED
*        WHEN LS_LIST-MWSKZ IS INITIAL AND LS_LIST-INFNR IS INITIAL AND LS_LIST-ZFREE IS INITIAL THEN  ICON_LED_RED
*        WHEN LS_LIST-EINDT IS INITIAL AND LS_LIST-INFNR IS INITIAL THEN ICON_LED_RED
*        WHEN LS_LIST-MATKL IS INITIAL AND LS_LIST-KNTTP IS NOT INITIAL AND LS_LIST-MATNR IS INITIAL THEN ICON_LED_RED
*        WHEN LS_LIST-KNTTP = GC_M AND ( LS_LIST-VBELN IS INITIAL OR LS_LIST-VBELP IS INITIAL ) THEN ICON_LED_RED
*        WHEN LS_LIST-KNTTP = GC_K AND ( LS_LIST-KOSTL IS INITIAL OR LS_LIST-SAKTO IS INITIAL ) THEN ICON_LED_RED
*        WHEN LS_LIST-KNTTP = GC_A AND ( LS_LIST-ANLN1 IS INITIAL OR LS_LIST-ANLN2 IS INITIAL ) THEN ICON_LED_RED
*        WHEN LS_LIST-KNTTP = GC_P AND ( LS_LIST-PS_PSP_PNR IS INITIAL OR LS_LIST-SAKTO IS INITIAL ) THEN ICON_LED_RED
*        WHEN LS_LIST-KNTTP = GC_F AND ( LS_LIST-AUFNR IS INITIAL OR LS_LIST-SAKTO IS INITIAL ) THEN ICON_LED_RED
*        ELSE SPACE ).
*
*        IF LS_LIST-STATUS = ICON_LED_RED.
*          GV_ERR = GC_X.
*          LS_LIST-MESSAGE = '필수 입력 값이 누락되었습니다.'(E28).
*        ENDIF.
*      ENDIF.

      IF gv_err IS INITIAL.
        IF ls_list-dpcbt = ''.
          ls_cre = CORRESPONDING #( ls_list ).
          ls_cre-index = gs_row-index.
          APPEND ls_cre TO gt_cre_po.
        ELSE.
          ls_cre = CORRESPONDING #( ls_list ).
          ls_cre-index = gs_row-index.
          APPEND ls_cre TO gt_cre_bdc.
        ENDIF.
      ENDIF.

      MODIFY gt_create FROM ls_list INDEX gs_row-index.
      CLEAR :  ls_list, ls_cre.
    ENDIF.
  ENDLOOP.

  IF lv_msg IS NOT INITIAL.
    MESSAGE s000 WITH lv_msg DISPLAY LIKE 'E'.
  ENDIF.

  CHECK gv_err IS INITIAL.
  gv_ques = '구매오더를 생성하시겠습니까?'(m26).
  gv_info   = '( 수입 PO 생성 시에만 입력하세요. )'(m27).

  CALL SCREEN 0300 STARTING AT 10 5.

*  PERFORM POPUP_TO_CONFIRM_STEP  USING GC_N
*                                                                 TEXT-M08 "선택된 라인에 대해 공급업체 별로 구매오더가 생성됩니다.
*                                                                 TEXT-M09 "계속 진행 하시겠습니까?
*                                                                  TEXT-T04.
*  CHECK GV_ANSWER = GC_J.
*  CLEAR LS_LIST.
*
*  DATA : LS_HEAD       TYPE BAPIMEPOHEADER,
*         LS_HEADX      TYPE BAPIMEPOHEADERX,
*         LT_INSTANCE   LIKE TABLE OF ZGTMMS4516,
*         LT_CHDATA     LIKE TABLE OF ZGTMMS4517,
*         LT_ITEM       LIKE TABLE OF BAPIMEPOITEM,
*         LT_ITEMX      LIKE TABLE OF BAPIMEPOITEMX,
*         LT_POACCOUNT  LIKE TABLE OF BAPIMEPOACCOUNT,
*         LT_POACCOUNTX LIKE TABLE OF BAPIMEPOACCOUNTX,
*         LT_SCH        LIKE TABLE OF BAPIMEPOSCHEDULE,
*         LT_SCHX       LIKE TABLE OF BAPIMEPOSCHEDULX,
*         LT_COND       LIKE TABLE OF BAPIMEPOCOND,
*         LT_CONDX      LIKE TABLE OF BAPIMEPOCONDX,
*         LT_POTEXT     LIKE TABLE OF BAPIMEPOTEXT,
*         LT_RETURN     TYPE TABLE OF BAPIRET2.
*
*  DATA : LV_EBELN TYPE EKKO-EBELN,
*         LV_ITEM  TYPE BAPIMEPOITEM-PO_ITEM,
*         LV_TYPE  TYPE BAPI_MTYPE,
*         LV_MSG   TYPE BAPI_MSG,
*         LV_NETPR TYPE EKPO-NETPR.
*  DATA:  LV_EXT_WBS TYPE PS_POSID.
*
*  SORT GT_CRE_PO BY LIFNR WAERS BUKRS EKORG WERKS MATNR LGORT.
*  CLEAR LS_CRE.
*
*  LOOP AT LT_CRE INTO LS_CRE GROUP BY ( LIFNR   = LS_CRE-LIFNR
*                                                                      WAERS = LS_CRE-WAERS  )
*    ASCENDING ASSIGNING FIELD-SYMBOL(<FSG>). " 그룹화 시 자동 정렬
*
**--- PO(EBELN) HEADER 정보 설정---
*    CLEAR : LS_HEAD, LS_HEADX, LV_ITEM.
*
*    LS_HEAD = VALUE #( COMP_CODE  = P_BUKRS
*                                     VENDOR         = <FSG>-LIFNR
*                                     PURCH_ORG   = P_EKORG
*                                     PUR_GROUP   = P_EKGRP
*                                     CURRENCY     = <FSG>-WAERS ).
*
*    LS_HEADX = VALUE #( COMP_CODE  = GC_X
*                                      VENDOR         = GC_X
*                                      PURCH_ORG   = GC_X
*                                      PUR_GROUP   = GC_X
*                                      CURRENCY     = GC_X ).
*
**--- PO의 (품목별 상세 내역) 설정 (10단위)---
*    CLEAR : LT_ITEM, LT_ITEMX, LT_SCH, LT_SCHX, LT_COND, LT_CONDX, LT_POTEXT.
*    LOOP AT GROUP <FSG> ASSIGNING FIELD-SYMBOL(<LS_PO>).
*      CLEAR   LV_EXT_WBS.
*      LV_ITEM = LV_ITEM + 10.
*      <LS_PO>-EBELP = LV_ITEM.
*
*      APPEND VALUE #( PO_ITEM             = LV_ITEM
*                                  ITEM_CAT  = <LS_PO>-PSTYP
*                                  ACCTASSCAT = <LS_PO>-KNTTP
*                                  MATERIAL_LONG  = <LS_PO>-MATNR
*                                  SHORT_TEXT       = <LS_PO>-ZZMAKTX80
*                                  PLANT                 = <LS_PO>-WERKS
*                                  STGE_LOC          = <LS_PO>-LGORT
*                                  MATL_GROUP      = <LS_PO>-MATKL
*                                  FREE_ITEM          = <LS_PO>-ZFREE
*                                  QUAL_INSP          = <LS_PO>-INSMK
*                                  QUANTITY            = <LS_PO>-MENGE
*                                  PO_UNIT              =  <LS_PO>-MEINS
*                                  RET_ITEM             =  <LS_PO>-RETPO
*                                  OVER_DLV_TOL   =  <LS_PO>-UEBTO
*                                  SUPP_VENDOR    = <LS_PO>-EMLIF
*                                  SC_VENDOR        = COND #( WHEN <LS_PO>-EMLIF IS INITIAL THEN SPACE ELSE GC_X )
*                                  TAX_CODE          = <LS_PO>-MWSKZ  ) TO LT_ITEM.
*
*      APPEND VALUE #( PO_ITEM             = LV_ITEM
*                                  PO_ITEMX            = GC_X
*                                  ITEM_CAT            = GC_X
*                                  ACCTASSCAT       = GC_X
*                                  MATERIAL_LONG  = GC_X
*                                  SHORT_TEXT       = GC_X
*                                  PLANT                 = GC_X
*                                  STGE_LOC          = COND #( WHEN <LS_PO>-LGORT IS INITIAL THEN SPACE ELSE GC_X )
*                                  MATL_GROUP      = COND #( WHEN <LS_PO>-MATKL IS INITIAL THEN SPACE ELSE GC_X )
*                                  FREE_ITEM          = GC_X
*                                  QUAL_INSP          = GC_X
*                                  QUANTITY            = GC_X
*                                  PO_UNIT              = GC_X
*                                  RET_ITEM             = GC_X
*                                  OVER_DLV_TOL   =  GC_X
*                                  SUPP_VENDOR    = COND #( WHEN <LS_PO>-EMLIF IS INITIAL THEN SPACE ELSE GC_X )
*                                  SC_VENDOR        = COND #( WHEN <LS_PO>-EMLIF IS INITIAL THEN SPACE ELSE GC_X )
*                                  TAX_CODE          = COND #( WHEN <LS_PO>-MWSKZ IS INITIAL THEN SPACE ELSE GC_X )
*                                    ) TO LT_ITEMX.
*
*      APPEND VALUE #( PO_ITEM              = LV_ITEM
*                                  SCHED_LINE         = '0001'
*                                  DEL_DATCAT_EXT = GC_D
*                                  DELIVERY_DATE    = <LS_PO>-EINDT
*                                  QUANTITY             = <LS_PO>-MENGE  ) TO LT_SCH.
*
*      APPEND VALUE #( PO_ITEM             = LV_ITEM
*                                  SCHED_LINE         = '0001'
*                                  PO_ITEMX            = GC_X
*                                  SCHED_LINEX       = GC_X
*                                  DEL_DATCAT_EXT = GC_X
*                                  DELIVERY_DATE    = GC_X
*                                  QUANTITY             = GC_X
*                                   ) TO LT_SCHX.
*
*      APPEND VALUE #( PO_ITEM     =  LV_ITEM
*                                   TEXT_ID      = 'F01'
*                                   TEXT_LINE  = <LS_PO>-ZMEMO )   TO LT_POTEXT.
*
*      IF <LS_PO>-KNTTP IS NOT INITIAL.
*
*        IF <LS_PO>-PS_PSP_PNR IS NOT INITIAL.
*
*          CALL FUNCTION 'CONVERSION_EXIT_ABPSN_OUTPUT'
*            EXPORTING
*              INPUT  = <LS_PO>-PS_PSP_PNR
*            IMPORTING
*              OUTPUT = LV_EXT_WBS.
*
*        ENDIF.
*        APPEND VALUE #( PO_ITEM              = LV_ITEM
*                                    SERIAL_NO           = '01'
*                                    UNLOAD_PT         = <LS_PO>-ABLAD
*                                    SD_DOC               = <LS_PO>-VBELN
*                                    ITM_NUMBER        = <LS_PO>-VBELP
*                                    COSTCENTER       = <LS_PO>-KOSTL
*                                    GL_ACCOUNT       = <LS_PO>-SAKTO
*                                    ASSET_NO           = <LS_PO>-ANLN1
*                                    SUB_NUMBER      = <LS_PO>-ANLN2
*                                    WBS_ELEMENT = LV_EXT_WBS
*                                    ORDERID              = <LS_PO>-AUFNR ) TO LT_POACCOUNT.
*
*        IF <LS_PO>-KNTTP = GC_M.
*          APPEND VALUE #( PO_ITEM             = LV_ITEM
*                                      SERIAL_NO           = '01'
*                                      SCHED_LINE         = '0001'
*                                      UNLOAD_PT         = GC_X
*                                      PO_ITEMX            = GC_X
*                                      SERIAL_NOX       = GC_X
*                                      SD_DOC               = GC_X
*                                      ITM_NUMBER        = GC_X    ) TO LT_POACCOUNTX.
*
*        ELSEIF <LS_PO>-KNTTP = GC_K.
*          APPEND VALUE #( PO_ITEM             = LV_ITEM
*                                   SERIAL_NO           = '01'
*                                   SCHED_LINE         = '0001'
*                                   UNLOAD_PT         = GC_X
*                                   PO_ITEMX            = GC_X
*                                   SERIAL_NOX       = GC_X
*                                   COSTCENTER       = GC_X
*                                   GL_ACCOUNT       = GC_X  ) TO LT_POACCOUNTX.
*
*
*        ELSEIF <LS_PO>-KNTTP = GC_O.
*          APPEND VALUE #( PO_ITEM             = LV_ITEM
*                                      SERIAL_NO           = '01'
*                                      SCHED_LINE         = '0001'
*                                      UNLOAD_PT         = GC_X
*                                      PO_ITEMX            = GC_X
*                                      SERIAL_NOX       = GC_X
*                                      ASSET_NO           = GC_X     ) TO LT_POACCOUNTX.
*
*        ELSEIF <LS_PO>-KNTTP = GC_P.
*          APPEND VALUE #( PO_ITEM             = LV_ITEM
*                                      SERIAL_NO           = '01'
*                                      SCHED_LINE         = '0001'
*                                      UNLOAD_PT         = GC_X
*                                      PO_ITEMX            = GC_X
*                                      SERIAL_NOX       = GC_X
*                                      WBS_ELEMENT   = GC_X
*                                      GL_ACCOUNT       = GC_X   ) TO LT_POACCOUNTX.
*
*        ELSEIF <LS_PO>-KNTTP = GC_F  .
*
*          APPEND VALUE #( PO_ITEM             = LV_ITEM
*                                    SERIAL_NO           = '01'
*                                    SCHED_LINE         = '0001'
*                                    UNLOAD_PT         = GC_X
*                                    PO_ITEMX            = GC_X
*                                    SERIAL_NOX       = GC_X
*                                    GL_ACCOUNT       = GC_X
*                                    ORDERID              = GC_X     ) TO LT_POACCOUNTX.
*        ENDIF.
*      ENDIF.
**입력단가/통화/PER -> 업체 INFO와 다를 때만 POCOND 구성
*      IF <LS_PO>-NETPR_I EQ <LS_PO>-NETPR AND <LS_PO>-WAERS_I EQ <LS_PO>-WAERS
*          AND <LS_PO>-PEINH_I EQ <LS_PO>-PEINH.
*      ELSE.
*        _IDOC <LS_PO>-WAERS <LS_PO>-NETPR LV_NETPR .
*        APPEND VALUE #( ITM_NUMBER      = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN LV_ITEM ELSE SPACE )
*                                  COND_ST_NO      = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN '001' ELSE SPACE )
*                                  COND_COUNT     = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN '02' ELSE SPACE )
*                                  COND_TYPE        = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN 'PBXX' ELSE SPACE )
*                                  COND_VALUE      = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN LV_NETPR ELSE SPACE )
*                                  CURRENCY         = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN <LS_PO>-WAERS ELSE SPACE )
*                                  CURRENCY_ISO  = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN <LS_PO>-WAERS ELSE SPACE )
*                                  COND_UNIT         = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN <LS_PO>-MEINS ELSE SPACE )
*                                  COND_UNIT_ISO  = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN <LS_PO>-MEINS ELSE SPACE )
*                                  COND_P_UNT      = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN <LS_PO>-PEINH ELSE SPACE )
*                                  CHANGE_ID         = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN GC_I )
*                                  COND_COUNT_LONG    = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN '002' ELSE SPACE )
*
*
*                                  ) TO LT_COND.
*
*        APPEND VALUE #( ITM_NUMBER     = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN LV_ITEM ELSE SPACE )
*                                  COND_ST_NO     = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN '010' ELSE SPACE )
*                                  ITM_NUMBERX    = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN GC_X ELSE SPACE )
*                                  COND_ST_NOX   = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN GC_X ELSE SPACE )
*                                  COND_COUNT   = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN GC_X ELSE SPACE )
*                                  COND_TYPE        = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN GC_X ELSE SPACE )
*                                  COND_VALUE      = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN GC_X ELSE SPACE )
*                                  CURRENCY          = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN GC_X ELSE SPACE )
*                                  CURRENCY_ISO    = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN GC_X ELSE SPACE )
*                                  COND_UNIT          = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN GC_X ELSE SPACE )
*                                  COND_UNIT_ISO   = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN GC_X ELSE SPACE )
*                                  COND_P_UNT       = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN GC_X ELSE SPACE )
*                                  CHANGE_ID           = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN GC_X ELSE SPACE )
*                                  COND_COUNT_LONG            = COND #( WHEN <LS_PO>-INFNR IS INITIAL THEN GC_X ELSE SPACE )
*                                   ) TO LT_CONDX.
*      ENDIF.
*
**      IF <LS_PO>-DPCBT IS NOT INITIAL.
**        GT_CHAR[] = VALUE #( BASE GT_CHAR
**                             ( EBELP = LV_ITEM
**                               LENGTH = <LS_PO>-LENGTH
**                               DRQTY   = <LS_PO>-DRQTY ) )  .
**      ENDIF.
*    ENDLOOP.
*
**"--- BAPI_PO_CREATE1호출. PO 생성 및 EBELN 번호 채번 ---
*    TRY.
*        CALL FUNCTION 'BAPI_PO_CREATE1'
*          EXPORTING
*            POHEADER         = LS_HEAD
*            POHEADERX        = LS_HEADX
*          IMPORTING
*            EXPPURCHASEORDER = LV_EBELN
*          TABLES
*            RETURN           = GT_RETURN
*            POITEM           = LT_ITEM
*            POITEMX          = LT_ITEMX
*            POACCOUNT        = LT_POACCOUNT
*            POACCOUNTX       = LT_POACCOUNTX
*            POSCHEDULE       = LT_SCH
*            POSCHEDULEX      = LT_SCHX
*            POCOND           = LT_COND
*            POCONDX          = LT_CONDX
*            POTEXTITEM       = LT_POTEXT.
*      CATCH CX_ROOT INTO DATA(LV_ERR).
*        LV_MSG = LV_ERR->GET_TEXT( ).
*        MESSAGE S000 WITH LV_MSG.
*    ENDTRY.
*
*    IF LINE_EXISTS( GT_RETURN[ TYPE = GC_E ] ) OR LV_EBELN IS INITIAL.
*      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*
*      INSERT LINES OF CORRESPONDING BAPIRET2_T( GT_RETURN ) INTO TABLE LT_RETURN.
*      READ TABLE GT_RETURN INTO DATA(LS_RT) INDEX 1.
*
*      LOOP AT GROUP <FSG> ASSIGNING FIELD-SYMBOL(<BACK>).
***MAIN ALV DATA UPDATE
*        READ TABLE GT_CREATE ASSIGNING FIELD-SYMBOL(<FSUB>)
*        INDEX <BACK>-INDEX.
*        IF SY-SUBRC = 0.
*          CLEAR : <FSUB>-EBELN, <FSUB>-EBELP.
*          <FSUB>-STATUS    = ICON_LED_RED.
*          <FSUB>-MESSAGE = LS_RT-MESSAGE.
*          MODIFY GT_CREATE FROM <FSUB> INDEX <BACK>-INDEX.
*        ENDIF.
*      ENDLOOP.
*
*      LV_ERR2 = GC_X.
*    ELSE.
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          WAIT = GC_X.
***MAIN ALV DATA UPDATE-그룹핑당 1개 PO생성. 품목 별 업데이트.
*      CLEAR LV_ITEM.
*      LOOP AT GROUP <FSG> ASSIGNING FIELD-SYMBOL(<COM>).
***MAIN ALV DATA UPDATE
*        READ TABLE GT_CREATE ASSIGNING FIELD-SYMBOL(<FSUC>)
*        INDEX <COM>-INDEX.
*        IF SY-SUBRC = 0.
*          <FSUC>-EBELN = LV_EBELN.
*          <FSUC>-EBELP = <COM>-EBELP.
*          <FSUC>-STATUS    = ICON_LED_GREEN.
*          <FSUC>-MESSAGE = '구매오더가 생성 되었습니다.'(M17).
*          MODIFY GT_CREATE FROM <FSUC> INDEX <COM>-INDEX.
*        ENDIF.
*
**        CLEAR : LT_INSTANCE, LT_CHDATA.
**조장/드럼수 UPDATE위한 로직. DPCBT데이터 있는 경우에만.
**        IF <COM>-DPCBT IS NOT INITIAL.
***PO의 OBJECT NO 조회
**            SELECT SINGLE CUOBJ FROM EKPO
**            WHERE EBELN = @LV_EBELN
**                 AND EBELP = @<FSUC>-EBELP
**            INTO @DATA(LV_CUOBJ).
**
**            IF LV_CUOBJ IS INITIAL.
**              DO 5 TIMES.
**                WAIT UP TO '0.1' SECONDS.
**                SELECT SINGLE CUOBJ FROM EKPO
**                WHERE EBELN = @LV_EBELN
**                     AND EBELP = @<FSUC>-EBELP
**                    INTO @LV_CUOBJ.
**
**                IF LV_CUOBJ IS NOT INITIAL.
**                  EXIT.
**                ENDIF.
**              ENDDO.
**            ENDIF.
**
**            IF LV_CUOBJ IS INITIAL .
**              <FSUC>-STATUS    = ICON_LED_RED.
**              <FSUC>-MESSAGE = '조장, 드럼수 업데이트 오류 발생했습니다.'(E29).
**              MODIFY GT_CREATE FROM <FSUC> INDEX <COM>-INDEX
**              TRANSPORTING STATUS MESSAGE.
**              CLEAR : LS_CRE, GT_RETURN. CONTINUE.
**
**            ELSE.
***생성된 PO의 OBJECT NO 구성 ITAB
**             APPEND VALUE #( INSTANCE = LV_CUOBJ ) TO LT_INSTANCE .
**             GT_CHDATA = VALUE #(
**                                  ( INSTANCE = LV_CUOBJ
**                                    ATNAM      = 'SAP_MILLCA_LENGH'
**                                    ATFLV       = <COM>-LENGTH )
**                                  ( INSTANCE = LV_CUOBJ
**                                    ATNAM      = 'SAP_MILLCA_FACTOR'
**                                    ATFLV       = <COM>-DRQTY ) ) .
***조장/드럼수 업데이트 펑션 호출
**             CALL FUNCTION 'ZGTMM_CHANGE_PURCHAR'
**               EXPORTING
**                I_BUKRS        = P_BUKRS
**                I_TYPE          = 'EKPO'
**               IMPORTING
**                MTYPE          = LV_TYPE
**                MESSAGE      = LV_MSG
**               TABLES
**                IT_PODATA    = LT_INSTANCE
**                IT_CHDATA    = GT_CHDATA
**                      .
**              IF LV_TYPE = GC_E.
**                 <FSUC>-STATUS = ICON_LED_RED.
**                 <FSUC>-MESSAGE = '조장, 드럼수 업데이트 오류 발생했습니다.'(E29).
**                 MODIFY GT_CREATE FROM <FSUC> INDEX <COM>-INDEX
**                 TRANSPORTING STATUS MESSAGE.
**              ENDIF.
**            ENDIF.
**        ENDIF.
*
*      ENDLOOP.
*
*    ENDIF.
*
*    CLEAR : LS_CRE, GT_RETURN.
*  ENDLOOP.
*
*  IF LT_CRE_BDC[] IS NOT INITIAL.
*
*    SELECT SINGLE FLD_02 INTO @DATA(LV_DISMODE) FROM ZGTPPT1010
*      WHERE  MODULE_KIND = 'MM' AND CODEGRP = '0900' AND FLD_01 = @P_WERKS.
*
*    DATA : LV_INLENGTH TYPE I.
*    DATA : LV_INLENGTH_C(10) TYPE C.
*    DATA : LV_INFACTOR TYPE I.
*    DATA : LV_INFACTOR_C(10) TYPE C.
*    DATA : LV_FIELDNAME TYPE FNAM_____4.
*    DATA : LV_NUM(2) TYPE N.
*    DATA : LV_MENGE_C(30) TYPE C.
*    DATA : LV_POSNR2(4) TYPE N.
*    DATA : LV_LINES TYPE I.
*    DATA : LV_EBELN2 TYPE EBELN.
*    DATA : LV_NETPR_C(15) TYPE C.
*    DATA : LV_PEINH_C(5) TYPE C.
*    DATA : LV_PSTYP TYPE PSTYP.
*    DATA : LT_TEMP_BAPI TYPE BAPIRET2_T.
*
*
*    LOOP AT LT_CRE_BDC INTO LS_CRE GROUP BY ( LIFNR   = LS_CRE-LIFNR
*                                                                          WAERS = LS_CRE-WAERS  )
*        ASCENDING ASSIGNING FIELD-SYMBOL(<FSG2>). " 그룹화 시 자동 정렬
*
*      REFRESH : GT_BDCDATA, GT_MESSTAB.
*
*      __SETTING_BDC_PARAMS.
*
*      __BDC_DYNPRO 'SAPMM06E' '0100'.
*      __BDC_FIELD : 'BDC_OKCODE' '/00',
*                             'EKKO-LIFNR' <FSG2>-LIFNR,
*                             'RM06E-BSART' 'NB',
*                             'RM06E-BEDAT' SY-DATUM,
*                             'EKKO-EKORG' P_EKORG,
*                             'EKKO-EKGRP' P_EKGRP,
*                             'RM06E-LPEIN' 'T',
*                             'RM06E-WERKS' P_WERKS.
*
*      __BDC_DYNPRO 'SAPMM06E' '0101'.
*      __BDC_FIELD : 'BDC_OKCODE' '/00',
*                            'EKKO-EKGRP' P_EKGRP,
*                            'EKKO-PINCR' '10',
*                            'EKKO-SPRAS' 'KO'.
*
*
*
*      CLEAR :  LV_NUM,LV_POSNR2.
*
**      --- PO의 (품목별 상세 내역) 설정 (10단위)---
*      LOOP AT GROUP <FSG2> ASSIGNING FIELD-SYMBOL(<LS_PO2>).
*        ADD 1 TO LV_NUM.
*        ADD 10 TO LV_POSNR2.
*        __BDC_DYNPRO 'SAPMM06E' '0120'.
*        __BDC_FIELD : 'BDC_OKCODE' '/00'.
*
**     구매오더 항목 번호
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |RM06E-BSTPO({ LV_NUM })|.
*        __BDC_FIELD : LV_FIELDNAME LV_POSNR2.
*
*        CLEAR : LV_PSTYP.
**                     품목범주
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |RM06E-EPSTP({ LV_NUM })|.
*        IF <LS_PO2>-PSTYP = '3'.
*          LV_PSTYP = 'L'.
*        ELSE.
*          LV_PSTYP = ''.
*        ENDIF.
*        __BDC_FIELD : LV_FIELDNAME LV_PSTYP.
*
**                     계정지정범주
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |EKPO-KNTTP({ LV_NUM })|.
*        __BDC_FIELD : LV_FIELDNAME <LS_PO2>-KNTTP.
**                     자재코드
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |EKPO-EMATN({ LV_NUM })|.
*        __BDC_FIELD : LV_FIELDNAME <LS_PO2>-MATNR.
**                     수량
*        CLEAR LV_FIELDNAME.
*
*        LV_MENGE_C = <LS_PO2>-MENGE.
*        CONDENSE LV_MENGE_C.
*
*        LV_FIELDNAME = |EKPO-MENGE({ LV_NUM })|.
*        __BDC_FIELD : LV_FIELDNAME LV_MENGE_C.
**                     단위
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |EKPO-MEINS({ LV_NUM })|.
*        __BDC_FIELD : LV_FIELDNAME <LS_PO2>-MEINS.
**                     납품예정일
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |RM06E-EEIND({ LV_NUM })|.
*        __BDC_FIELD : LV_FIELDNAME <LS_PO2>-EINDT.
**                     저장위치
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |EKPO-LGORT({ LV_NUM })|.
*        __BDC_FIELD : LV_FIELDNAME <LS_PO2>-LGORT.
**                     단가
*
**                     반품지시자
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |EKPO-RETPO({ LV_NUM })|.
*        __BDC_FIELD : LV_FIELDNAME <LS_PO2>-RETPO.
**                     반품지시자
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |RM06E-UMSON({ LV_NUM })|.
*        __BDC_FIELD : LV_FIELDNAME <LS_PO2>-ZFREE.
*
*        IF <LS_PO2>-KNTTP = GC_M.
*          __BDC_DYNPRO 'SAPMM06E' '0511'.
*          __BDC_FIELD : 'BDC_OKCODE'  '=ENTE'.
*
*          __BDC_DYNPRO 'SAPLKACB' '0002'.
*          __BDC_FIELD : 'BDC_OKCODE' '=ENTE'.
*
**                  판매오더
*          CLEAR LV_FIELDNAME.
*          LV_FIELDNAME = |COBL-KDAUF|.
*          __BDC_FIELD : LV_FIELDNAME <LS_PO2>-VBELN.
*
**                  판매오더
*          CLEAR LV_FIELDNAME.
*          LV_FIELDNAME = |COBL-KDPOS|.
*          __BDC_FIELD : LV_FIELDNAME <LS_PO2>-VBELP.
*
**          __BDC_DYNPRO 'SAPMM06E' '0113'.
**          __BDC_FIELD : 'BDC_OKCODE' '=NEXP'.
*        ENDIF.
*
*        __BDC_DYNPRO 'SAPMM06E' '0120'.
*        __BDC_FIELD : 'BDC_OKCODE' '/00'.
**          CLEAR LV_FIELDNAME.
**          LV_FIELDNAME = |RM06E-EBELP|.
**          __BDC_FIELD : LV_FIELDNAME LV_POSNR2.
*
*
*        __BDC_DYNPRO 'SAPMM06E' '0120'.
*        __BDC_FIELD : 'BDC_OKCODE' '=DETA'.
**          CLEAR LV_FIELDNAME.
**          LV_FIELDNAME = |RM06E-EBELP|.
**          __BDC_FIELD : LV_FIELDNAME LV_POSNR2.
*
*
*        __BDC_DYNPRO 'SAPMM06E' '0111'.
*        __BDC_FIELD : 'BDC_OKCODE' '/00'.
*
***     상세정보
**        CLEAR LV_FIELDNAME.
**        LV_FIELDNAME = |EKPO-UEBTO|.
**        __BDC_FIELD : LV_FIELDNAME <LS_PO2>-UEBTO.
*
**     상세정보
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |EKPO-INSMK|.
*        __BDC_FIELD : LV_FIELDNAME <LS_PO2>-INSMK.
*
**     상세정보
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |EKPO-MWSKZ|.
*        __BDC_FIELD : LV_FIELDNAME <LS_PO2>-MWSKZ.
*
*
*        __BDC_DYNPRO 'SAPMM06E' '0120'.
*        __BDC_FIELD : 'BDC_OKCODE' '/00'.
**          CLEAR LV_FIELDNAME.
**          LV_FIELDNAME = |RM06E-EBELP|.
**          __BDC_FIELD : LV_FIELDNAME LV_POSNR2.
*
*
*        __BDC_DYNPRO 'SAPMM06E' '0120'.
*        __BDC_FIELD : 'BDC_OKCODE' '=KONF'.
**                      'RM06E-EBELP' LV_POSNR2.
*
*        LV_INFACTOR = <LS_PO2>-DRQTY.
*        LV_INFACTOR_C = LV_INFACTOR.
*        CONDENSE LV_INFACTOR_C.
*
*        LV_INLENGTH_C = <LS_PO2>-LENGTH.
*        CONDENSE LV_INLENGTH_C.
*
*        __BDC_DYNPRO 'SAPLCEI0' '0109'.
*        __BDC_FIELD : 'BDC_OKCODE' '=BACK',
*                            'RCTMS-MNAME(01)' 'SAP_MILLCA_LENGTH',
*                            'RCTMS-MNAME(02)' 'SAP_MILLCA_FACTOR',
*                            'RCTMS-MWERT(01)' LV_INLENGTH_C,
*                            'RCTMS-MWERT(02)' LV_INFACTOR_C.
*
**        CLEAR LV_FIELDNAME.
**        LV_FIELDNAME = |RM06E-EBELP|.
**        __BDC_FIELD : LV_FIELDNAME LV_POSNR2.
**        __BDC_FIELD : 'BDC_OKCODE' '=KONF'.
**
**        __BDC_DYNPRO 'SAPLCEI0' '0109'.
**        __BDC_FIELD : 'BDC_OKCODE' '=BACK'.
**
***                 특성입력
**        CLEAR LV_FIELDNAME.
**        LV_FIELDNAME = |RCTMS-MNAME(01)|.
**        __BDC_FIELD : LV_FIELDNAME 'SAP_MILLCA_FACTOR'.
**        LV_FIELDNAME = |RCTMS-MNAME(02)|.
**        __BDC_FIELD : LV_FIELDNAME 'SAP_MILLCA_LENGTH'.
**
**        LV_INFACTOR = <LS_PO2>-DRQTY.
**        LV_INFACTOR_C = LV_INFACTOR.
**        CONDENSE LV_INFACTOR_C.
**
**        LV_FIELDNAME = |RCTMS-MWERT(01)|.
**        __BDC_FIELD : LV_FIELDNAME LV_INFACTOR_C.
**
**        LV_INLENGTH_C = <LS_PO2>-LENGTH.
**        CONDENSE LV_INLENGTH_C.
**
**        LV_FIELDNAME = |RCTMS-MWERT(02)|.
**        __BDC_FIELD : LV_FIELDNAME LV_INLENGTH_C.
**
**        __BDC_DYNPRO 'SAPMM06E' '0120'.
**        __BDC_FIELD : 'BDC_OKCODE' '/00'.
**            ENDIF.
*        __BDC_DYNPRO 'SAPMM06E' '0120'.
*        __BDC_FIELD : 'BDC_OKCODE' '/00'.
**          CLEAR LV_FIELDNAME.
**          LV_FIELDNAME = |RM06E-EBELP|.
**          __BDC_FIELD : LV_FIELDNAME LV_POSNR2.
*
*      ENDLOOP.
*
*      __BDC_DYNPRO 'SAPMM06E' '0120'.
*      __BDC_FIELD : 'BDC_OKCODE' '=BU'.
*
**        __BDC_TRANSACTION 'ME21' .
*      GS_BDCPARAMS-DISMODE =  LV_DISMODE.
*      GS_BDCPARAMS-DEFSIZE = ''.
*
*      CALL TRANSACTION 'ME21' USING GT_BDCDATA
*                                  OPTIONS FROM GS_BDCPARAMS
*                                MESSAGES INTO GT_MESSTAB.
*
*      CLEAR LV_EBELN.
*      LOOP AT GT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'S'
*                                                             AND MSGID = '06'
*                                                             AND MSGNR = '017'.
*        LV_EBELN = LS_MESSTAB-MSGV2.
*      ENDLOOP.
*
*      IF LV_EBELN IS INITIAL.
*        CLEAR LT_TEMP_BAPI.
*        CALL FUNCTION 'CONVERT_BDCMSGCOLL_TO_BAPIRET2'
*          TABLES
*            IMT_BDCMSGCOLL = GT_MESSTAB
*            EXT_BAPIRET2   = LT_TEMP_BAPI.
*        INSERT LINES OF LT_TEMP_BAPI INTO TABLE LT_RETURN.
*
*        LV_ERR2 = GC_X.
*        LOOP AT GROUP <FSG2> ASSIGNING FIELD-SYMBOL(<BACK2>).
***MAIN ALV DATA UPDATE
*          READ TABLE GT_CREATE ASSIGNING FIELD-SYMBOL(<FSUB2>)
*          INDEX <BACK2>-INDEX.
*          IF SY-SUBRC = 0.
*            CLEAR : <FSUB2>-EBELN, <FSUB2>-EBELP.
*            <FSUB2>-STATUS    = ICON_LED_RED.
*            <FSUB2>-MESSAGE = '구매오더 생성 시 오류가 발생했습니다.'(M25).
*            MODIFY GT_CREATE FROM <FSUB2> INDEX <BACK2>-INDEX.
*          ENDIF.
*        ENDLOOP.
*
*      ELSE.
*        LOOP AT GROUP <FSG2> ASSIGNING FIELD-SYMBOL(<COM2>).
***MAIN ALV DATA UPDATE
*          READ TABLE GT_CREATE ASSIGNING FIELD-SYMBOL(<FSUC2>)
*          INDEX <COM2>-INDEX.
*          IF SY-SUBRC = 0.
*            <FSUC2>-EBELN = LV_EBELN.
*            <FSUC2>-EBELP = <COM2>-EBELP.
*            <FSUC2>-STATUS    = ICON_LED_GREEN.
*            <FSUC2>-MESSAGE = '구매오더가 생성 되었습니다.'(M17).
*            MODIFY GT_CREATE FROM <FSUC2> INDEX <COM2>-INDEX.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*
*    ENDLOOP.
*
*  ENDIF.
*
*  IF LT_RETURN[] IS NOT INITIAL.
*    CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
*      TABLES
*        I_BAPIRET2_TAB = LT_RETURN.
*  ENDIF.
*
*  IF LV_ERR2 IS INITIAL.
*    PERFORM SET_CREATE_DATA.
*    MESSAGE S000 WITH '구매오더를 생성했습니다.!'.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM APPROVAL_REQUEST
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM approval_request .

  DATA : lt_list LIKE TABLE OF gs_create,
         ls_1020 TYPE zgtmmt1020.
  DATA : lv_message TYPE char100,
         lv_msg     TYPE string,
         lv_chk.

  CLEAR : gv_answer, gv_err.

  IF sy-tcode = 'ZGTMMR3000'.
    PERFORM get_selected_rows USING gcl_grid.
  ELSE.
    PERFORM get_selected_rows USING gcl_grid_400.
  ENDIF.

  CHECK gv_err IS INITIAL.

  LOOP AT gt_rows INTO gs_row.
    READ TABLE gt_create  INTO DATA(ls_list) INDEX gs_row-index.
    IF sy-subrc = 0 .

      IF ls_list-ebeln IS INITIAL.
        gv_err = gc_x.
        MESSAGE s000 WITH '구매오더 미 생성 건은 승인 요청할 수 없습니다.'(e31)
        DISPLAY LIKE gc_e. EXIT.

      ELSE.
        APPEND ls_list TO lt_list. CLEAR ls_list.
      ENDIF.

    ENDIF.
  ENDLOOP.

  CHECK gv_err IS INITIAL.
  PERFORM popup_to_confirm_step  USING gc_n
                                                                 TEXT-m18 "선택된 정보의 구매오더 번호를 기준으로
                                                                 TEXT-m19 "모든 항번의 승인 요청을 진행 하시겠습니까?
                                                                  TEXT-t04.
  CHECK gv_answer = gc_j.
  SORT lt_list BY lifnr lifnr_n ekgrp.
  DELETE ADJACENT DUPLICATES FROM lt_list COMPARING lifnr.
*EMAIL 전송대상 데이터 가져오기.
  SELECT FROM zgtmmt1020
    FIELDS *
    WHERE werks = @p_werks
         AND ekgrp = @p_ekgrp
    INTO TABLE @DATA(lt_1020).
  SORT lt_1020 BY werks ekgrp.

  SORT lt_list BY ekgrp lifnr.
  gv_text = '[승인요청]구매오더 생성 건에 대한 승인요청 드립니다.'(m20).

  LOOP AT lt_1020  INTO ls_1020 GROUP BY ( werks = ls_1020-werks   ekgrp = ls_1020-ekgrp )
    ASSIGNING FIELD-SYMBOL(<fs>).

    LOOP AT GROUP <fs> ASSIGNING FIELD-SYMBOL(<fsgr>).
*승인자의 EMAIL 주소 조회
      SELECT SINGLE c~usrid
      FROM usr21 AS a
      INNER JOIN zpa0539 AS b
                  ON a~bname = b~pernr
      LEFT OUTER JOIN zpa0105 AS c
                  ON b~pernr = c~pernr
      WHERE b~endda >= @sy-datum
           AND c~endda >= @sy-datum
           AND c~subty = '0007'
           AND a~bname = @<fsgr>-aname
           INTO @DATA(lv_email).
*선택한 데이터의 구매조직 별 메일 전송 구성
      READ TABLE lt_list TRANSPORTING NO FIELDS
      WITH  KEY ekgrp = <fsgr>-ekgrp BINARY SEARCH.

      IF sy-subrc = 0.
        DATA(lv_tabix) = sy-tabix.
      ENDIF.

      LOOP AT lt_list INTO ls_list FROM lv_tabix.
        IF <fsgr>-ekgrp = ls_list-ekgrp.
          lv_msg &&= |{ '[' }{ ls_list-lifnr }{ ']' }{ ls_list-lifnr_n }|.

          AT END OF ekgrp.
            lv_msg &&=  |  '업체에 대한 구매오더 승인이 요청되었습니다. SAP T-CODE ZGTMMR3000B로 확인 부탁드립니다' |.
            APPEND VALUE #( line = lv_msg ) TO gt_mtxt.

*E-MAIL 전송
            ##OPERATOR[UNAME]
            CALL FUNCTION 'Z_MM_SEND_MAIL'
              EXPORTING
                i_uname     = CONV sy-uname( <fsgr>-aname )
                i_email     = CONV ad_smtpadr( lv_email )
                i_head_text = gv_text
              IMPORTING
                e_return    = lv_chk
                e_message   = lv_message
              TABLES
                t_msg       = gt_mtxt.

            CLEAR gt_mtxt.
          ENDAT.
        ENDIF.
        CLEAR ls_list.
      ENDLOOP.

    ENDLOOP.

    CLEAR : lv_msg, lv_chk, lv_message.
  ENDLOOP.

  IF lv_chk = gc_s.
    MESSAGE s000 WITH '승인요청 메일 발송 완료'(m21).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> P_VARI
*&---------------------------------------------------------------------*
FORM f4_for_variant  USING    p_vari.

  CLEAR : gv_exit, gs_variant.

  gs_variant-report = sy-repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant    = gs_variant
      i_save        = 'A'
    IMPORTING
      e_exit        = gv_exit
      es_variant    = gs_variant
    EXCEPTIONS
      not_found     = 1
      program_error = 2
      OTHERS        = 3.

  IF sy-subrc EQ 0 AND gv_exit IS INITIAL.
    p_vari = gs_variant-variant.
  ELSE.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_BAPI_PO_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_bapi_po_data .
  DATA :
    lv_err,
    lv_ebeln TYPE ekko-ebeln,
    lv_item  TYPE bapimepoitem-po_item.
  DATA :
    ls_head   TYPE bapimepoheader,
    ls_headx  TYPE bapimepoheaderx,
    lt_item   LIKE TABLE OF bapimepoitem,
    lt_itemx  LIKE TABLE OF bapimepoitemx,
    lt_sch    LIKE TABLE OF bapimeposchedule,
    lt_schx   LIKE TABLE OF bapimeposchedulx,
    lt_cond   LIKE TABLE OF bapimepocond,
    lt_condx  LIKE TABLE OF bapimepocondx,
    lt_potext LIKE TABLE OF bapimepotext,
    lv_preis  TYPE wrbtr, "EKPO-NETPR,
    lv_qtymsg TYPE bapi_msg,
    lv_resmsg TYPE bapi_msg,
    lv_insmsg TYPE bapi_msg,
    lv_crecnt TYPE i,
    lv_skpcnt TYPE i,
    lt_return TYPE TABLE OF bapiret2.

  CLEAR gv_err. "26.09 에러 추가

  LOOP AT gt_conv_po INTO DATA(ls_conv) GROUP BY ( flief = ls_conv-flief
                                                                      ekorg = ls_conv-ekorg
                                                                      ekgrp = ls_conv-ekgrp
                                                                      waers = ls_conv-waers  )
    ASCENDING ASSIGNING FIELD-SYMBOL(<fsg>). " 그룹화 시 자동 정렬

*--- PO(EBELN) HEADER 정보 설정---
    CLEAR : ls_head, ls_headx, lv_item.


    CLEAR gv_err. "26.09 에러 추가


    ls_head = VALUE #( comp_code  = p_bukrs
                                     vendor         = <fsg>-flief
                                     purch_org   = <fsg>-ekorg
                                     pur_group   = <fsg>-ekgrp
                                     currency     = <fsg>-waers
                                     pmnttrms     = COND #( WHEN gv_zterm IS NOT INITIAL
                                                                            THEN gv_zterm ELSE space )
                                     incoterms1  = COND #( WHEN gv_inco1 IS NOT INITIAL
                                                                           THEN gv_inco1 ELSE space ) ).

    ls_headx = VALUE #( comp_code  = gc_x
                                      vendor         = gc_x
                                      purch_org   = gc_x
                                      pur_group   = gc_x
                                      currency     = gc_x
                                      pmnttrms     = COND #( WHEN ls_head-pmnttrms IS INITIAL
                                                                             THEN space ELSE gc_x )
                                      incoterms1  = COND #( WHEN ls_head-incoterms1 IS INITIAL
                                                                             THEN space ELSE gc_x ) ).

*--- PO의 (품목별 상세 내역) 설정 (10단위)---
    CLEAR : lt_item, lt_itemx, lt_sch, lt_schx, lt_cond, lt_condx.

    LOOP AT GROUP <fsg> ASSIGNING FIELD-SYMBOL(<ls_po>).

*--------------------------------------------------------------------*
**--> 26.09 구매요청 발주잔량 체크 후 중복/초과 PO 생성처리 안되도록 추가
*       ZTYPE = 'CL'(청구현황)은 BANFN이 청구번호이므로 대상에서 제외
*--------------------------------------------------------------------*
      CLEAR lv_qtymsg.

      IF <ls_po>-ztype = gc_pr.
        PERFORM check_pr_rest_qty USING    <ls_po>-banfn
                                           <ls_po>-bnfpo
                                           <ls_po>-menge_i
                                  CHANGING lv_qtymsg.
      ENDIF.

**--> 26.09 해당 품목만 제외하고 나머지 품목으로 PO 생성(부분 생성)
      IF lv_qtymsg IS NOT INITIAL.

        CLEAR <ls_po>-ebelp. "PO 미생성 표식(생성 후 갱신 루프에서 제외)
        lv_skpcnt = lv_skpcnt + 1.

        READ TABLE gt_list ASSIGNING FIELD-SYMBOL(<fsq>)
        INDEX <ls_po>-index.
        IF sy-subrc = 0.
          CLEAR : <fsq>-ebeln, <fsq>-ebelp.
          <fsq>-status  = icon_led_red.
          <fsq>-type    = gc_e.
          <fsq>-message = lv_qtymsg.
        ENDIF.

        lt_return[] = VALUE #( BASE lt_return
                                ( type       = gc_e
                                  id         = 'ZGTMM01'
                                  number     = '000'
                                  message    = lv_qtymsg
                                  message_v1 = lv_qtymsg(50)
                                  message_v2 = lv_qtymsg+50(50)
                                  message_v3 = lv_qtymsg+100(50)
                                  message_v4 = lv_qtymsg+150(50) )
                                ).

        CONTINUE. "다음 품목 계속 처리
      ENDIF.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
**--> 26.10 inspection = '유'인 경후 여장체크
*--------------------------------------------------------------------*
      READ TABLE gt_list ASSIGNING FIELD-SYMBOL(<fs_ins>) INDEX <ls_po>-index.
      IF sy-subrc EQ 0 AND <fs_ins> IS ASSIGNED.
        IF <fs_ins>-inspection = '유'.
          CLEAR lv_insmsg.
          PERFORM check_inspection_qty USING <ls_po>-vbeln
                                             <ls_po>-posnr
                                       CHANGING lv_insmsg
                                                <fs_ins>-insqty_w
                                                <fs_ins>-insqty_s.
          IF lv_insmsg IS NOT INITIAL.
            CLEAR <ls_po>-ebelp.             "PO 미생성 표식
            lv_skpcnt = lv_skpcnt + 1.       "제외 건수 집계

            CLEAR : <fs_ins>-ebeln, <fs_ins>-ebelp.
            <fs_ins>-status  = icon_led_red.
            <fs_ins>-type    = gc_e.
            <fs_ins>-message = lv_insmsg.    "lv_qtymsg 오타 수정

            lt_return[] = VALUE #( BASE lt_return
                                    ( type       = gc_e
                                      id         = 'ZGTMM01'
                                      number     = '000'
                                      message    = lv_insmsg
                                      message_v1 = lv_insmsg(50)
                                      message_v2 = lv_insmsg+50(50)
                                      message_v3 = lv_insmsg+100(50)
                                      message_v4 = lv_insmsg+150(50) )
                                      ).
            CONTINUE. "다음 품목 계속 처리
          ENDIF.

        ENDIF.
      ENDIF.

*--------------------------------------------------------------------*

      lv_item = lv_item + 10.
      <ls_po>-ebelp = lv_item.

      APPEND VALUE #( po_item             = lv_item
                                  item_cat = <ls_po>-pstyp
                                  material_long  = <ls_po>-matnr
                                  short_text       = <ls_po>-txz01
                                  plant                 = <ls_po>-werks
                                  stge_loc          = <ls_po>-lgort
                                  matl_group      = <ls_po>-matkl
                                  qual_insp          = <ls_po>-insmk
                                  quantity            = <ls_po>-menge_i "LV_MENGE
                                  po_unit              = <ls_po>-meins
                                  trackingno    = COND #( WHEN <ls_po>-ztype = gc_pr THEN space ELSE <ls_po>-banfn )
                                  preq_name    =  COND #( WHEN <ls_po>-ztype = gc_pr THEN space ELSE <ls_po>-bnfpo )
                                  supp_vendor    = <ls_po>-emlif
                                  sc_vendor        = <ls_po>-lblkz
                                  pricedate          = COND #( WHEN sy-tcode = 'ZGTMMR3001' THEN space )
                                  tax_code          = <ls_po>-mwskz  ) TO lt_item.

      APPEND VALUE #( po_item             = lv_item
                                  po_itemx            = gc_x
                                  item_cat = gc_x
                                  material_long  = gc_x
                                  short_text       = gc_x
                                  plant                 = gc_x
                                  stge_loc          = gc_x
                                  matl_group      = gc_x
                                  qual_insp          = gc_x
                                  quantity            = gc_x
                                  po_unit              = gc_x
                                  trackingno    = COND #( WHEN <ls_po>-ztype = gc_pr THEN space ELSE gc_x )
                                  preq_name    =  COND #( WHEN <ls_po>-ztype = gc_pr THEN space ELSE gc_x )
                                  supp_vendor    = gc_x
                                  sc_vendor        = gc_x
                                  pricedate          = COND #( WHEN sy-tcode = 'ZGTMMR3001' THEN gc_x ELSE space )
                                  tax_code          = gc_x  ) TO lt_itemx.

      APPEND VALUE #( po_item              = lv_item
                                  sched_line         = '0001' "고정
                                  del_datcat_ext = gc_d
                                  delivery_date    = <ls_po>-lfdat
                                  quantity             = <ls_po>-menge_i
                                  preq_no             = <ls_po>-banfn
                                  preq_item          = <ls_po>-bnfpo  ) TO lt_sch.

      APPEND VALUE #( po_item             = lv_item
                                  sched_line         = '0001'
                                  po_itemx            = gc_x
                                  sched_linex       = gc_x
                                  del_datcat_ext = gc_x
                                  delivery_date    = gc_x
                                  quantity            = gc_x
                                  preq_no             = COND #( WHEN <ls_po>-ztype = gc_pr THEN gc_x ELSE space )
                                  preq_item          = COND #( WHEN <ls_po>-ztype = gc_pr THEN gc_x ELSE space )
                                   ) TO lt_schx.

      APPEND VALUE #( po_item     =  lv_item
                                   text_id      = 'F01'
                                   text_line  = COND #( WHEN <ls_po>-zmemo_i IS INITIAL
                                                                      THEN <ls_po>-zmemo_h ELSE <ls_po>-zmemo_i ) )
                                   TO lt_potext.

      IF <ls_po>-preis_i EQ <ls_po>-preis AND <ls_po>-peinh_i EQ <ls_po>-peinh AND
        <ls_po>-waers_i EQ <ls_po>-waers.
*입력한 단가/PER/통화와 INFO 정보가 같을 시 POCOND조건 미저장, 다를 시 저장(설정)
      ELSE.
        _idoc <ls_po>-waers <ls_po>-preis lv_preis.
        APPEND VALUE #( itm_number             = lv_item
                                    cond_st_no             = '001' "고정
                                    cond_count             = '02' "고정
                                    cond_type               =  'PBXX'
                                    cond_value             = lv_preis "<LS_PO>-PREIS
                                    currency                 = <ls_po>-waers
                                    currency_iso          = <ls_po>-waers
                                    cond_unit                = <ls_po>-meins
                                    cond_unit_iso         = <ls_po>-meins
                                    cond_p_unt            = <ls_po>-peinh
                                    change_id                = gc_i
                                    cond_count_long = '002'
                                    ) TO lt_cond.

        APPEND VALUE #( itm_number             = lv_item
                                    cond_st_no             = '001'
                                    itm_numberx            = gc_x
                                    cond_st_nox          = gc_x
                                    cond_count           = gc_x
                                    cond_type               = gc_x
                                    cond_value             = gc_x
                                    currency                 = gc_x
                                    currency_iso          = gc_x
                                    cond_unit                = gc_x
                                    cond_unit_iso         = gc_x
                                    cond_p_unt            = gc_x
                                    change_id                = gc_x
                                    cond_count_long  = gc_x
                                    ) TO lt_condx.
      ENDIF.

    ENDLOOP.


**--> 26.09 그룹 전 품목이 제외된 경우 빈 PO 생성 방지
    IF lt_item IS INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR gt_return.
*"--- BAPI_PO_CREATE1호출. PO 생성 및 EBELN 번호 채번 ---
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader         = ls_head
        poheaderx        = ls_headx
      IMPORTING
        exppurchaseorder = lv_ebeln
      TABLES
        return           = gt_return
        poitem           = lt_item
        poitemx          = lt_itemx
        poschedule       = lt_sch
        poschedulex      = lt_schx
        pocond           = lt_cond
        pocondx          = lt_condx
        potextitem       = lt_potext.

    IF line_exists( gt_return[ type = gc_e ] ) OR lv_ebeln IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      INSERT LINES OF CORRESPONDING bapiret2_t( gt_return ) INTO TABLE lt_return.
      READ TABLE gt_return INTO DATA(ls_rt) INDEX 1.

      LOOP AT GROUP <fsg> ASSIGNING FIELD-SYMBOL(<back>).
**--> 26.09 발주잔량으로 제외된 품목은 자체 메시지를 유지
        CHECK <back>-ebelp IS NOT INITIAL.
**MAIN ALV DATA UPDATE
        READ TABLE gt_list ASSIGNING FIELD-SYMBOL(<fsu>)
        INDEX <back>-index.
        IF sy-subrc = 0.
          CLEAR : <fsu>-ebeln, <fsu>-ebelp.
          <fsu>-status    = icon_led_red.
          <fsu>-type        = gc_e.
          <fsu>-message = ls_rt-message.
          MODIFY gt_list FROM <fsu> INDEX <back>-index.
        ENDIF.
      ENDLOOP.
      lv_err = gc_x.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = gc_x.

      LOOP AT GROUP <fsg> ASSIGNING FIELD-SYMBOL(<com>).
**--> 26.09 발주잔량으로 제외된 품목은 초록/PO번호로 덮어쓰지 않음
        CHECK <com>-ebelp IS NOT INITIAL.
**MAIN ALV DATA UPDATE
        READ TABLE gt_list ASSIGNING FIELD-SYMBOL(<fsuc>)
        INDEX <com>-index.
        IF sy-subrc = 0.
          <fsuc>-ebeln = lv_ebeln.
          <fsuc>-ebelp = <com>-ebelp.
          <fsuc>-status = icon_led_green.
          <fsuc>-type     = gc_s.
          <fsuc>-message = '구매오더가 생성 되었습니다.'(m17).
          MODIFY gt_list FROM <fsuc> INDEX <com>-index.
          lv_crecnt = lv_crecnt + 1.
        ENDIF.
      ENDLOOP.

    ENDIF.

    CLEAR ls_conv.
  ENDLOOP.


**-- 26.09 RETURN에러시 REFRESH 안타도록
  IF lt_return[] IS NOT INITIAL.
    CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
      TABLES
        i_bapiret2_tab = lt_return.
  ENDIF.

**--> 26.09 생성 결과 안내(전건 성공 / 부분 생성 구분)
  IF lv_skpcnt IS INITIAL AND lv_err IS INITIAL.
    IF sy-tcode = 'ZGTMMR3000'.
      PERFORM get_data.
    ENDIF.
    MESSAGE s000 WITH '구매오더를 생성했습니다.!'.

  ELSE.
*재조회 시 행별 처리결과가 지워지므로 GET_DATA 미수행
    lv_resmsg = |구매오더 { lv_crecnt } 건 생성 / { lv_skpcnt } 건 제외. | &&
                |제외 사유는 각 행의 메시지를 확인하세요.|.

    MESSAGE s000 WITH lv_resmsg(50)     lv_resmsg+50(50)
                      lv_resmsg+100(50) lv_resmsg+150(50).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_BAPI_PO_DATA_CRE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_bapi_po_data_cre .

  DATA :
    ls_head       TYPE bapimepoheader,
    ls_headx      TYPE bapimepoheaderx,
    lt_instance   LIKE TABLE OF zgtmms4516,
    lt_chdata     LIKE TABLE OF zgtmms4517,
    lt_item       LIKE TABLE OF bapimepoitem,
    lt_itemx      LIKE TABLE OF bapimepoitemx,
    lt_poaccount  LIKE TABLE OF bapimepoaccount,
    lt_poaccountx LIKE TABLE OF bapimepoaccountx,
    lt_sch        LIKE TABLE OF bapimeposchedule,
    lt_schx       LIKE TABLE OF bapimeposchedulx,
    lt_cond       LIKE TABLE OF bapimepocond,
    lt_condx      LIKE TABLE OF bapimepocondx,
    lt_potext     LIKE TABLE OF bapimepotext,
    lt_return     TYPE TABLE OF bapiret2.

  DATA :
    lt_cre_bdc TYPE TABLE OF ty_cre_po.

  DATA :
    lv_err2,
    lv_ebeln     TYPE ekko-ebeln,
    lv_item      TYPE bapimepoitem-po_item,
    lv_type      TYPE bapi_mtype,
    lv_msg       TYPE bapi_msg,
    lv_netpr     TYPE wrbtr, "EKPO-NETPR,
    lv_ext_wbs   TYPE ps_posid,
    lv_ext_kostl TYPE kostl,
    lv_ext_gl    TYPE sakto.

  SORT gt_cre_po BY lifnr waers bukrs ekorg werks matnr lgort.

  LOOP AT gt_cre_po INTO DATA(ls_cre) GROUP BY ( lifnr   = ls_cre-lifnr
                                                                                      waers = ls_cre-waers  )
                 ASCENDING ASSIGNING FIELD-SYMBOL(<fsg>).

*--- PO(EBELN) HEADER 정보 설정---
    CLEAR : ls_head, ls_headx, lv_item.

    ls_head = VALUE #( comp_code  = p_bukrs
                                     vendor         = <fsg>-lifnr
                                     purch_org   = p_ekorg
                                     pur_group   = p_ekgrp
                                     currency     = <fsg>-waers
                                     pmnttrms     = COND #( WHEN gv_zterm IS NOT INITIAL
                                                                            THEN gv_zterm ELSE space )
                                     incoterms1  = COND #( WHEN gv_inco1 IS NOT INITIAL
                                                                           THEN gv_inco1 ELSE space ) ).

    ls_headx = VALUE #( comp_code  = gc_x
                                      vendor         = gc_x
                                      purch_org   = gc_x
                                      pur_group   = gc_x
                                      currency     = gc_x
                                      pmnttrms     = COND #( WHEN ls_head-pmnttrms IS INITIAL
                                                                             THEN space ELSE gc_x )
                                      incoterms1  = COND #( WHEN ls_head-incoterms1 IS INITIAL
                                                                             THEN space ELSE gc_x ) ).

*--- PO의 (품목별 상세 내역) 설정 (10단위)---
    CLEAR : lt_item, lt_itemx, lt_sch, lt_schx, lt_cond, lt_condx, lt_potext, lv_item.

    LOOP AT GROUP <fsg> ASSIGNING FIELD-SYMBOL(<ls_po>).
      CLEAR   lv_ext_wbs.
      lv_item = lv_item + 10.
      <ls_po>-ebelp = lv_item.

      APPEND VALUE #( po_item             = lv_item
                                  item_cat  = <ls_po>-pstyp
                                  acctasscat = <ls_po>-knttp
                                  material_long  = <ls_po>-matnr
                                  short_text       = <ls_po>-zzmaktx80
                                  plant                 = <ls_po>-werks
                                  stge_loc          = <ls_po>-lgort
                                  matl_group      = <ls_po>-matkl
                                  free_item          = <ls_po>-zfree
                                  qual_insp          = <ls_po>-insmk
                                  quantity            = <ls_po>-menge
                                  po_unit              =  <ls_po>-meins
                                  ret_item             =  <ls_po>-retpo
                                  over_dlv_tol   =  <ls_po>-uebto
                                  supp_vendor    = <ls_po>-emlif
                                  sc_vendor        = COND #( WHEN <ls_po>-emlif IS INITIAL THEN space ELSE gc_x )
                                  pricedate          = COND #( WHEN sy-tcode = 'ZGTMMR3001' THEN space )
                                  tax_code          = <ls_po>-mwskz  ) TO lt_item.

      APPEND VALUE #( po_item             = lv_item
                                  po_itemx            = gc_x
                                  item_cat            = gc_x
                                  acctasscat       = gc_x
                                  material_long  = gc_x
                                  short_text       = gc_x
                                  plant                 = gc_x
                                  stge_loc          = COND #( WHEN <ls_po>-lgort IS INITIAL THEN space ELSE gc_x )
                                  matl_group      = COND #( WHEN <ls_po>-matkl IS INITIAL THEN space ELSE gc_x )
                                  free_item          = gc_x
                                  qual_insp          = gc_x
                                  quantity            = gc_x
                                  po_unit              = gc_x
                                  ret_item             = gc_x
                                  over_dlv_tol   =  gc_x
                                  supp_vendor    = COND #( WHEN <ls_po>-emlif IS INITIAL THEN space ELSE gc_x )
                                  sc_vendor        = COND #( WHEN <ls_po>-emlif IS INITIAL THEN space ELSE gc_x )
                                  tax_code          = COND #( WHEN <ls_po>-mwskz IS INITIAL THEN space ELSE gc_x )
                                  pricedate          = COND #( WHEN sy-tcode = 'ZGTMMR3001' THEN gc_x ELSE space )
                                    ) TO lt_itemx.

      APPEND VALUE #( po_item              = lv_item
                                  sched_line         = '0001'
                                  del_datcat_ext = gc_d
                                  delivery_date    = <ls_po>-eindt
                                  quantity             = <ls_po>-menge  ) TO lt_sch.

      APPEND VALUE #( po_item             = lv_item
                                  sched_line         = '0001'
                                  po_itemx            = gc_x
                                  sched_linex       = gc_x
                                  del_datcat_ext = gc_x
                                  delivery_date    = gc_x
                                  quantity             = gc_x
                                   ) TO lt_schx.

      APPEND VALUE #( po_item     =  lv_item
                                   text_id      = 'F01'
                                   text_line  = <ls_po>-zmemo )   TO lt_potext.

      IF <ls_po>-knttp IS NOT INITIAL.

        IF <ls_po>-ps_psp_pnr IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ABPSN_OUTPUT'
            EXPORTING
              input  = <ls_po>-ps_psp_pnr
            IMPORTING
              output = lv_ext_wbs.
        ENDIF.

        <ls_po>-kostl = |{ <ls_po>-kostl ALPHA = IN }|.
        <ls_po>-sakto = |{ <ls_po>-sakto ALPHA = IN }|.

        APPEND VALUE #( po_item              = lv_item
                                    serial_no           = '01'
                                    unload_pt         = <ls_po>-ablad
                                    sd_doc               = <ls_po>-vbeln
                                    itm_number        = <ls_po>-vbelp
                                    costcenter       = <ls_po>-kostl
                                    gl_account       = <ls_po>-sakto
                                    asset_no           = <ls_po>-anln1
                                    sub_number      = <ls_po>-anln2
                                    wbs_element = lv_ext_wbs
                                    orderid              = <ls_po>-aufnr ) TO lt_poaccount.

        IF <ls_po>-knttp = gc_m.
          APPEND VALUE #( po_item             = lv_item
                                      serial_no           = '01'
                                      sched_line         = '0001'
                                      unload_pt         = gc_x
                                      po_itemx            = gc_x
                                      serial_nox        = gc_x
                                      sd_doc               = gc_x
                                      itm_number        = gc_x    ) TO lt_poaccountx.

        ELSEIF <ls_po>-knttp = gc_k.
          APPEND VALUE #( po_item             = lv_item
                                   serial_no           = '01'
                                   sched_line         = '0001'
                                   unload_pt         = gc_x
                                   po_itemx            = gc_x
                                   serial_nox        = gc_x
                                   costcenter       = gc_x
                                   gl_account       = gc_x  ) TO lt_poaccountx.


        ELSEIF <ls_po>-knttp = gc_o.
          APPEND VALUE #( po_item             = lv_item
                                      serial_no           = '01'
                                      sched_line         = '0001'
                                      unload_pt         = gc_x
                                      po_itemx            = gc_x
                                      serial_nox        = gc_x
                                      asset_no           = gc_x     ) TO lt_poaccountx.

        ELSEIF <ls_po>-knttp = gc_p.
          APPEND VALUE #( po_item             = lv_item
                                      serial_no           = '01'
                                      sched_line         = '0001'
                                      unload_pt         = gc_x
                                      po_itemx            = gc_x
                                      serial_nox        = gc_x
                                      wbs_element    = gc_x
                                      gl_account       = gc_x   ) TO lt_poaccountx.

        ELSEIF <ls_po>-knttp = gc_f  .

          APPEND VALUE #( po_item             = lv_item
                                    serial_no           = '01'
                                    sched_line         = '0001'
                                    unload_pt         = gc_x
                                    po_itemx            = gc_x
                                    serial_nox        = gc_x
                                    gl_account       = gc_x
                                    orderid              = gc_x     ) TO lt_poaccountx.
        ENDIF.
      ENDIF.
*입력단가/통화/PER -> 업체 INFO와 다를 때만 POCOND 구성
      IF <ls_po>-netpr_i EQ <ls_po>-netpr AND <ls_po>-waers_i EQ <ls_po>-waers
          AND <ls_po>-peinh_i EQ <ls_po>-peinh.
        "같으면, 생략.
      ELSE.
        _idoc <ls_po>-waers <ls_po>-netpr lv_netpr .
        APPEND VALUE #( itm_number      = COND #( WHEN <ls_po>-infnr IS INITIAL THEN lv_item ELSE space )
                                  cond_st_no      = COND #( WHEN <ls_po>-infnr IS INITIAL THEN '001' ELSE space )
                                  cond_count     = COND #( WHEN <ls_po>-infnr IS INITIAL THEN '02' ELSE space )
                                  cond_type        = COND #( WHEN <ls_po>-infnr IS INITIAL THEN 'PBXX' ELSE space )
                                  cond_value      = COND #( WHEN <ls_po>-infnr IS INITIAL THEN lv_netpr ELSE space )
                                  currency         = COND #( WHEN <ls_po>-infnr IS INITIAL THEN <ls_po>-waers ELSE space )
                                  currency_iso  = COND #( WHEN <ls_po>-infnr IS INITIAL THEN <ls_po>-waers ELSE space )
                                  cond_unit         = COND #( WHEN <ls_po>-infnr IS INITIAL THEN <ls_po>-meins ELSE space )
                                  cond_unit_iso  = COND #( WHEN <ls_po>-infnr IS INITIAL THEN <ls_po>-meins ELSE space )
                                  cond_p_unt      = COND #( WHEN <ls_po>-infnr IS INITIAL THEN <ls_po>-peinh ELSE space )
                                  change_id         = COND #( WHEN <ls_po>-infnr IS INITIAL THEN gc_i )
                                  cond_count_long    = COND #( WHEN <ls_po>-infnr IS INITIAL THEN '002' ELSE space )
                                  ) TO lt_cond.

        APPEND VALUE #( itm_number     = COND #( WHEN <ls_po>-infnr IS INITIAL THEN lv_item ELSE space )
                                  cond_st_no     = COND #( WHEN <ls_po>-infnr IS INITIAL THEN '010' ELSE space )
                                  itm_numberx    = COND #( WHEN <ls_po>-infnr IS INITIAL THEN gc_x ELSE space )
                                  cond_st_nox   = COND #( WHEN <ls_po>-infnr IS INITIAL THEN gc_x ELSE space )
                                  cond_count   = COND #( WHEN <ls_po>-infnr IS INITIAL THEN gc_x ELSE space )
                                  cond_type        = COND #( WHEN <ls_po>-infnr IS INITIAL THEN gc_x ELSE space )
                                  cond_value      = COND #( WHEN <ls_po>-infnr IS INITIAL THEN gc_x ELSE space )
                                  currency          = COND #( WHEN <ls_po>-infnr IS INITIAL THEN gc_x ELSE space )
                                  currency_iso    = COND #( WHEN <ls_po>-infnr IS INITIAL THEN gc_x ELSE space )
                                  cond_unit          = COND #( WHEN <ls_po>-infnr IS INITIAL THEN gc_x ELSE space )
                                  cond_unit_iso   = COND #( WHEN <ls_po>-infnr IS INITIAL THEN gc_x ELSE space )
                                  cond_p_unt       = COND #( WHEN <ls_po>-infnr IS INITIAL THEN gc_x ELSE space )
                                  change_id           = COND #( WHEN <ls_po>-infnr IS INITIAL THEN gc_x ELSE space )
                                  cond_count_long            = COND #( WHEN <ls_po>-infnr IS INITIAL THEN gc_x ELSE space )
                                   ) TO lt_condx.
      ENDIF.
    ENDLOOP.

*"--- BAPI_PO_CREATE1호출. PO 생성 및 EBELN 번호 채번 ---
    TRY.
        CALL FUNCTION 'BAPI_PO_CREATE1'
          EXPORTING
            poheader         = ls_head
            poheaderx        = ls_headx
          IMPORTING
            exppurchaseorder = lv_ebeln
          TABLES
            return           = gt_return
            poitem           = lt_item
            poitemx          = lt_itemx
            poaccount        = lt_poaccount
            poaccountx       = lt_poaccountx
            poschedule       = lt_sch
            poschedulex      = lt_schx
            pocond           = lt_cond
            pocondx          = lt_condx
            potextitem       = lt_potext.

      CATCH cx_root INTO DATA(lv_err).
        lv_msg = lv_err->get_text( ).
        MESSAGE s000 WITH lv_msg.
    ENDTRY.

    IF line_exists( gt_return[ type = gc_e ] ) OR lv_ebeln IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      IF lines( gt_return ) > 1.
        INSERT LINES OF CORRESPONDING bapiret2_t( gt_return ) INTO TABLE lt_return.
      ENDIF.

      READ TABLE gt_return INTO DATA(ls_rt) INDEX 1.

      LOOP AT GROUP <fsg> ASSIGNING FIELD-SYMBOL(<back>).
**MAIN ALV DATA UPDATE
        READ TABLE gt_create ASSIGNING FIELD-SYMBOL(<fsub>)
        INDEX <back>-index.
        IF sy-subrc = 0.
          CLEAR : <fsub>-ebeln, <fsub>-ebelp.
          <fsub>-status    = icon_led_red.
          <fsub>-message = ls_rt-message.
          MODIFY gt_create FROM <fsub> INDEX <back>-index.
        ENDIF.
      ENDLOOP.

      lv_err2 = gc_x.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = gc_x.
**MAIN ALV DATA UPDATE-그룹핑당 1개 PO생성. 품목 별 업데이트.
      CLEAR lv_item.
      LOOP AT GROUP <fsg> ASSIGNING FIELD-SYMBOL(<com>).
**MAIN ALV DATA UPDATE
        READ TABLE gt_create ASSIGNING FIELD-SYMBOL(<fsuc>) INDEX <com>-index.
        IF sy-subrc = 0.
          <fsuc>-ebeln = lv_ebeln.
          <fsuc>-ebelp = <com>-ebelp.
          <fsuc>-status    = icon_led_green.
          <fsuc>-message = '구매오더가 생성 되었습니다.'(m17).

          MODIFY gt_create FROM <fsuc> INDEX <com>-index.
        ENDIF.
      ENDLOOP.

    ENDIF.

    CLEAR : ls_cre, gt_return.
  ENDLOOP.

  IF gt_cre_bdc[] IS NOT INITIAL.

    SELECT SINGLE fld_02 INTO @DATA(lv_dismode) FROM zgtppt1010
      WHERE  module_kind = 'MM' AND codegrp = '0900' AND fld_01 = @p_werks.

    DATA : lv_inlength TYPE i.
    DATA : lv_inlength_c(10) TYPE c.
    DATA : lv_infactor TYPE i.
    DATA : lv_infactor_c(10) TYPE c.
    DATA : lv_drum_c(40) TYPE c.
    DATA : lv_fieldname TYPE fnam_____4.
    DATA : lv_num(2) TYPE n.
    DATA : lv_menge_c(30) TYPE c.
    DATA : lv_posnr2(4) TYPE n.
    DATA : lv_lines TYPE i.
    DATA : lv_ebeln2 TYPE ebeln.
    DATA : lv_netpr_c(15) TYPE c.
    DATA : lv_peinh_c(5) TYPE c.
    DATA : lv_pstyp TYPE pstyp.
    DATA : lt_temp_bapi TYPE bapiret2_t.



    CLEAR ls_cre.
    LOOP AT gt_cre_bdc " INTO LS_CRE GROUP BY ( LIFNR   = LS_CRE-LIFNR
*                                                                                WAERS = LS_CRE-WAERS  )  ASCENDING
      ASSIGNING FIELD-SYMBOL(<ls_po2>) ."<FSG2>). " 그룹화 시 자동 정렬

      REFRESH : gt_bdcdata, gt_messtab.

      __setting_bdc_params.

      __bdc_dynpro 'SAPMM06E' '0100'.
      __bdc_field : 'BDC_OKCODE' '/00',
                             'EKKO-LIFNR' <ls_po2>-lifnr, "<FSG2>-LIFNR,
                             'RM06E-BSART' 'NB',
                             'RM06E-BEDAT' sy-datum,
                             'EKKO-EKORG' p_ekorg,
                             'EKKO-EKGRP' p_ekgrp,
                             'RM06E-LPEIN' 'T',
                             'RM06E-WERKS' p_werks.

      __bdc_dynpro 'SAPMM06E' '0101'.
      __bdc_field : 'BDC_OKCODE' '/00',
                            'EKKO-EKGRP' p_ekgrp,
                            'EKKO-PINCR' '10',
                            'EKKO-SPRAS' 'KO'.

      CLEAR :  lv_num,lv_posnr2.

*      --- PO의 (품목별 상세 내역) 설정 (10단위)---
*      LOOP AT GROUP <FSG2> ASSIGNING FIELD-SYMBOL(<LS_PO2>).
      ADD 1 TO lv_num.
      ADD 10 TO lv_posnr2.
      __bdc_dynpro 'SAPMM06E' '0120'.
      __bdc_field : 'BDC_OKCODE' '/00'.

*     구매오더 항목 번호
      CLEAR lv_fieldname.
      lv_fieldname = |RM06E-BSTPO({ lv_num })|.
      __bdc_field : lv_fieldname lv_posnr2.

      CLEAR : lv_pstyp.
* 품목범주
      CLEAR lv_fieldname.
      lv_fieldname = |RM06E-EPSTP({ lv_num })|.
      IF <ls_po2>-pstyp = '3'.
        lv_pstyp = 'L'.
      ELSE.
        lv_pstyp = ''.
      ENDIF.
      __bdc_field : lv_fieldname lv_pstyp.

*  계정지정범주
      CLEAR lv_fieldname.
      lv_fieldname = |EKPO-KNTTP({ lv_num })|.
      __bdc_field : lv_fieldname <ls_po2>-knttp.
*  자재코드
      CLEAR lv_fieldname.
      lv_fieldname = |EKPO-EMATN({ lv_num })|.
      __bdc_field : lv_fieldname <ls_po2>-matnr.
* 수량
      CLEAR lv_fieldname.

      lv_menge_c = <ls_po2>-menge.
      CONDENSE lv_menge_c.

      lv_fieldname = |EKPO-MENGE({ lv_num })|.
      __bdc_field : lv_fieldname lv_menge_c.
*  단위
      CLEAR lv_fieldname.
      lv_fieldname = |EKPO-MEINS({ lv_num })|.
      __bdc_field : lv_fieldname <ls_po2>-meins.
*  납품예정일
      CLEAR lv_fieldname.
      lv_fieldname = |RM06E-EEIND({ lv_num })|.
      __bdc_field : lv_fieldname <ls_po2>-eindt.
* 저장위치
      CLEAR lv_fieldname.
      lv_fieldname = |EKPO-LGORT({ lv_num })|.
      __bdc_field : lv_fieldname <ls_po2>-lgort.
*  단가

*  반품지시자
      CLEAR lv_fieldname.
      lv_fieldname = |EKPO-RETPO({ lv_num })|.
      __bdc_field : lv_fieldname <ls_po2>-retpo.
*  반품지시자
      CLEAR lv_fieldname.
      lv_fieldname = |RM06E-UMSON({ lv_num })|.
      __bdc_field : lv_fieldname <ls_po2>-zfree.

      IF <ls_po2>-knttp = gc_m.
        __bdc_dynpro 'SAPMM06E' '0511'.
        __bdc_field : 'BDC_OKCODE'  '=ENTE'.

        __bdc_dynpro 'SAPLKACB' '0002'.
        __bdc_field : 'BDC_OKCODE' '=ENTE'.

*  판매오더
        CLEAR lv_fieldname.
        lv_fieldname = |COBL-KDAUF|.
        __bdc_field : lv_fieldname <ls_po2>-vbeln.

* 판매오더
        CLEAR lv_fieldname.
        lv_fieldname = |COBL-KDPOS|.
        __bdc_field : lv_fieldname <ls_po2>-vbelp.

*          __BDC_DYNPRO 'SAPMM06E' '0113'.
*          __BDC_FIELD : 'BDC_OKCODE' '=NEXP'.
      ENDIF.

      __bdc_dynpro 'SAPMM06E' '0120'.
      __bdc_field : 'BDC_OKCODE' '/00'.
*          CLEAR LV_FIELDNAME.
*          LV_FIELDNAME = |RM06E-EBELP|.
*          __BDC_FIELD : LV_FIELDNAME LV_POSNR2.


      __bdc_dynpro 'SAPMM06E' '0120'.
      __bdc_field : 'BDC_OKCODE' '=DETA'.
*          CLEAR LV_FIELDNAME.
*          LV_FIELDNAME = |RM06E-EBELP|.
*          __BDC_FIELD : LV_FIELDNAME LV_POSNR2.

      __bdc_dynpro 'SAPMM06E' '0111'.
      __bdc_field : 'BDC_OKCODE' '/00'.

**     상세정보
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |EKPO-UEBTO|.
*        __BDC_FIELD : LV_FIELDNAME <LS_PO2>-UEBTO.
*     상세정보
      CLEAR lv_fieldname.
      lv_fieldname = |EKPO-INSMK|.
      __bdc_field : lv_fieldname <ls_po2>-insmk.
*     상세정보
      CLEAR lv_fieldname.
      lv_fieldname = |EKPO-MWSKZ|.
      __bdc_field : lv_fieldname <ls_po2>-mwskz.

      __bdc_dynpro 'SAPMM06E' '0120'.
      __bdc_field : 'BDC_OKCODE' '/00'.
*          CLEAR LV_FIELDNAME.
*          LV_FIELDNAME = |RM06E-EBELP|.
*          __BDC_FIELD : LV_FIELDNAME LV_POSNR2.

      __bdc_dynpro 'SAPMM06E' '0120'.
      __bdc_field : 'BDC_OKCODE' '=KONF'.
*                      'RM06E-EBELP' LV_POSNR2.

      lv_infactor = <ls_po2>-drqty.
      lv_infactor_c = lv_infactor.
      CONDENSE lv_infactor_c.

      lv_inlength_c = <ls_po2>-length.
      CONDENSE lv_inlength_c.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input  = <ls_po2>-drmatnr
        IMPORTING
          output = lv_drum_c.
      CONDENSE lv_drum_c.


      __bdc_dynpro 'SAPLCEI0' '0109'.
      __bdc_field : 'BDC_OKCODE' '=BACK',
                          'RCTMS-MNAME(01)' 'SAP_MILLCA_LENGTH',
                          'RCTMS-MNAME(02)' 'SAP_MILLCA_FACTOR',
                          'RCTMS-MNAME(03)' 'PD_CA_PACKING_DM',
                          'RCTMS-MWERT(01)' lv_inlength_c,
                          'RCTMS-MWERT(02)' lv_infactor_c,
                          'RCTMS-MWERT(03)' lv_drum_c.

*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |RM06E-EBELP|.
*        __BDC_FIELD : LV_FIELDNAME LV_POSNR2.
*        __BDC_FIELD : 'BDC_OKCODE' '=KONF'.
*
*        __BDC_DYNPRO 'SAPLCEI0' '0109'.
*        __BDC_FIELD : 'BDC_OKCODE' '=BACK'.
*
**                 특성입력
*        CLEAR LV_FIELDNAME.
*        LV_FIELDNAME = |RCTMS-MNAME(01)|.
*        __BDC_FIELD : LV_FIELDNAME 'SAP_MILLCA_FACTOR'.
*        LV_FIELDNAME = |RCTMS-MNAME(02)|.
*        __BDC_FIELD : LV_FIELDNAME 'SAP_MILLCA_LENGTH'.
*
*        LV_INFACTOR = <LS_PO2>-DRQTY.
*        LV_INFACTOR_C = LV_INFACTOR.
*        CONDENSE LV_INFACTOR_C.
*
*        LV_FIELDNAME = |RCTMS-MWERT(01)|.
*        __BDC_FIELD : LV_FIELDNAME LV_INFACTOR_C.
*
*        LV_INLENGTH_C = <LS_PO2>-LENGTH.
*        CONDENSE LV_INLENGTH_C.
*
*        LV_FIELDNAME = |RCTMS-MWERT(02)|.
*        __BDC_FIELD : LV_FIELDNAME LV_INLENGTH_C.
*
*        __BDC_DYNPRO 'SAPMM06E' '0120'.
*        __BDC_FIELD : 'BDC_OKCODE' '/00'.
*            ENDIF.
      __bdc_dynpro 'SAPMM06E' '0120'.
      __bdc_field : 'BDC_OKCODE' '/00'.
*          CLEAR LV_FIELDNAME.
*          LV_FIELDNAME = |RM06E-EBELP|.
*          __BDC_FIELD : LV_FIELDNAME LV_POSNR2.

*      ENDLOOP.

      __bdc_dynpro 'SAPMM06E' '0120'.
      __bdc_field : 'BDC_OKCODE' '=BU'.

*        __BDC_TRANSACTION 'ME21' .
      gs_bdcparams-dismode =  lv_dismode.
      gs_bdcparams-defsize = ''.

      CALL TRANSACTION 'ME21' USING gt_bdcdata
                                  OPTIONS FROM gs_bdcparams
                                MESSAGES INTO gt_messtab.

      CLEAR lv_ebeln.
      LOOP AT gt_messtab INTO DATA(ls_messtab) WHERE msgtyp = 'S'
                                                             AND msgid = '06'
                                                             AND msgnr = '017'.
        lv_ebeln = ls_messtab-msgv2.
      ENDLOOP.

      IF lv_ebeln IS INITIAL.
        CLEAR lt_temp_bapi.

        CALL FUNCTION 'CONVERT_BDCMSGCOLL_TO_BAPIRET2'
          TABLES
            imt_bdcmsgcoll = gt_messtab
            ext_return     = lt_temp_bapi.
*            EXT_BAPIRET2   = LT_TEMP_BAPI.

        INSERT LINES OF lt_temp_bapi INTO TABLE lt_return.

        lv_err2 = gc_x.
*        LOOP AT GROUP <FSG2> ASSIGNING FIELD-SYMBOL(<BACK2>).
**MAIN ALV DATA UPDATE
        READ TABLE gt_create ASSIGNING FIELD-SYMBOL(<fsub2>)
        INDEX <ls_po2>-index. "<BACK2>-INDEX.
        IF sy-subrc = 0.
          CLEAR : <fsub2>-ebeln, <fsub2>-ebelp.
          <fsub2>-status    = icon_led_red.
          <fsub2>-message = '구매오더 생성 시 오류가 발생했습니다.'(m25).
          MODIFY gt_create FROM <fsub2> INDEX <ls_po2>-index." INDEX <BACK2>-INDEX.
        ENDIF.
*        ENDLOOP.

      ELSE.
*        LOOP AT GROUP <FSG2> ASSIGNING FIELD-SYMBOL(<COM2>).
**MAIN ALV DATA UPDATE
        READ TABLE gt_create ASSIGNING FIELD-SYMBOL(<fsuc2>)
        INDEX <ls_po2>-index. "<COM2>-INDEX.
        IF sy-subrc = 0.
          <fsuc2>-ebeln = lv_ebeln.
          <fsuc2>-ebelp = lv_posnr2. "<COM2>-EBELP.
          <fsuc2>-status    = icon_led_green.
          <fsuc2>-message = '구매오더가 생성 되었습니다.'(m17).
          MODIFY gt_create FROM <fsuc2> INDEX <ls_po2>-index."<COM2>-INDEX.
        ENDIF.
*        ENDLOOP.
      ENDIF.

      CLEAR ls_cre.
    ENDLOOP.

  ENDIF.

  IF lt_return[] IS NOT INITIAL.
    CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
      TABLES
        i_bapiret2_tab = lt_return.
  ENDIF.

  IF lv_err2 IS INITIAL.
    PERFORM set_create_data.
    MESSAGE s000 WITH '구매오더를 생성했습니다.!'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM PR_LINK_CHANGE_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM pr_link_change_data .

  DATA : lt_list   LIKE TABLE OF gs_list,
         lt_cl     LIKE TABLE OF zgtppt3420,
         ls_cl     TYPE zgtppt3420,
         lt_item   TYPE TABLE OF bapimereqitemimp,
         lt_itemx  TYPE TABLE OF bapimereqitemx,
         lt_return TYPE TABLE OF bapiret2.

  DATA : BEGIN OF ls_pr,
           banfn TYPE banfn,
           bnfpo TYPE bnfpo,
           vbeln TYPE vbeln,
           posnr TYPE posnr,
           estkz TYPE estkz,
           index TYPE sy-index,
         END OF ls_pr,
         lt_pr   LIKE TABLE OF ls_pr,
         lt_pr_v LIKE TABLE OF ls_pr.

  CHECK sy-tcode = 'ZGTMMR3001'.

  CLEAR : gv_answer, gv_err, lt_cl, lt_pr, lt_pr_v.

  PERFORM get_selected_rows USING gcl_grid_400.
  CHECK gv_err IS INITIAL.

  LOOP AT gt_rows INTO gs_row.

    READ TABLE gt_list  INTO DATA(ls_list) INDEX gs_row-index.
    IF sy-subrc = 0.

      IF ls_list-flag = gc_x.
        MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE gc_e.
        gv_err = gc_x. EXIT."견적 진행 중인 구매요청은 종결할 수 없습니다.
      ENDIF.

      IF ls_list-status = '@5B@'.
        MESSAGE s000 WITH TEXT-e36 DISPLAY LIKE gc_e.
        gv_err = gc_x. EXIT."견적 진행 중인 구매요청은 종결할 수 없습니다.
      ENDIF.


      IF ls_list-ztype = gc_pr.
*        IF LS_LIST-ESTKZ = GC_V.
*          APPEND VALUE #( BANFN = LS_LIST-BANFN
*                                       BNFPO = LS_LIST-BNFPO ) TO LT_PR_V.
*        ELSE.
        APPEND VALUE #( banfn = ls_list-banfn
                                     bnfpo = ls_list-bnfpo
                                     vbeln = ls_list-vbeln
                                     posnr = ls_list-posnr
                                     estkz = ls_list-estkz
                                     index = gs_row-index ) TO lt_pr.
*        ENDIF.
      ENDIF.

      IF ls_list-ztype = gc_cl.
        CLEAR ls_cl.
        ls_cl = CORRESPONDING #( ls_list MAPPING reqno = banfn
                                                                          posnr = bnfpo ).
        APPEND ls_cl TO lt_cl.
      ENDIF.

    ENDIF.
  ENDLOOP.

  IF lt_pr[] IS INITIAL AND lt_cl[] IS INITIAL .
    MESSAGE s000 WITH TEXT-e04 DISPLAY LIKE gc_e. "처리 가능한 데이터가 없습니다.
    gv_err = gc_x. EXIT.

  ELSE.
    PERFORM popup_to_confirm_step USING gc_n
                                                              TEXT-m30 "선택된 구매요청에 대해 링크요청을 하시겠습니까?
                                                              TEXT-m31 "(영업 납품일정이 지난 PR은 요청할 수 없습니다.수작업으로 변경하세요.)
                                                              TEXT-t04. " 확인
  ENDIF.

  CHECK gv_answer = gc_j. "YES
  CHECK gv_err IS INITIAL.
  SORT  lt_pr BY banfn bnfpo.

  DATA :
    lv_type TYPE bapiret2-type,
    lv_msg  TYPE bapiret2-message.

*BAPI SET
  CLEAR ls_pr.

  LOOP AT lt_pr INTO ls_pr .
    IF ls_pr-estkz = gc_v.
*PR CHANGE대신 링크해제 펑션 실행
      CLEAR : lv_type, lv_msg.

      CALL FUNCTION 'ZGTSD_RECEIVE_MCHA_LINK_INFO'
        EXPORTING
          i_vbeln = ls_pr-vbeln
          i_posnr = ls_pr-posnr
          i_pstyv = 'TAN'
        IMPORTING
          e_type  = lv_type
          e_msg   = lv_msg.
      READ TABLE gt_list ASSIGNING FIELD-SYMBOL(<comv>) INDEX ls_pr-index.

      IF lv_type = gc_e.
        CHECK <comv> IS ASSIGNED.
        <comv>-status = icon_led_red.
        <comv>-message = lv_msg.
      ELSE.
        CHECK <comv> IS ASSIGNED.
        <comv>-status = icon_led_green.
        <comv>-message = TEXT-m28. "링크해제완료
      ENDIF.

    ELSE.
*PR CHANGE
      CLEAR : lt_item, lt_itemx, gt_return.

      APPEND VALUE #( preq_item   = ls_pr-bnfpo
                                   delete_ind  = gc_x ) TO lt_item.

      APPEND VALUE #( preq_item   = ls_pr-bnfpo
                                   preq_itemx = gc_x
                                   delete_ind  = gc_x  ) TO lt_itemx.

*BAPI_BNFPO 기준 PR 종결
      CALL FUNCTION 'BAPI_PR_CHANGE'
        EXPORTING
          number  = ls_pr-banfn
        TABLES
          return  = gt_return
          pritem  = lt_item
          pritemx = lt_itemx.

      READ TABLE gt_list ASSIGNING FIELD-SYMBOL(<com>) INDEX ls_pr-index.

      IF line_exists( gt_return[ type = gc_e ] ).
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        READ TABLE lt_return INTO DATA(ls_rt) WITH KEY type = gc_e.
        IF sy-subrc = 0.
          CHECK <com> IS ASSIGNED.
          <com>-status = icon_led_red.
          <com>-message = ls_rt-message.
        ENDIF.

        INSERT LINES OF CORRESPONDING bapiret2_t( gt_return ) INTO TABLE lt_return.
        CONTINUE.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = gc_x.

        IF <com> IS ASSIGNED.
          <com>-status = icon_led_green.
          <com>-message = TEXT-m29. "PR 종결완료
        ENDIF.

      ENDIF.

    ENDIF.
    CLEAR ls_pr.
  ENDLOOP.

*ZGTPPT3420(자재 청구 이력) UPDATE
  CLEAR ls_cl.
  LOOP AT lt_cl INTO ls_cl.

    UPDATE zgtppt3420
          SET reqno    = ls_cl-reqno
                 posnr    = ls_cl-posnr
                 zstatus = gc_d
     WHERE reqno    = ls_cl-reqno
          AND posnr    = ls_cl-posnr.

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ELSE.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  IF lt_return[] IS  INITIAL.
*    DATA LV_MSG TYPE BAPI_MSG.
*    LV_MSG = COND #( WHEN GV_ERR IS INITIAL THEN '선택된 요청에 대한 종결 처리가 완료되었습니다.'(M14)
*                                 ELSE '선택된 요청 종결 중 일부 데이터 종결 오류가 발생했습니다. 화면 데이터를 다시 확인하세요.'(M15) ).
  ELSE.
    CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
      TABLES
        i_bapiret2_tab = lt_return.
  ENDIF.

*  IF GV_ERR IS INITIAL.
*    MESSAGE S000 WITH LV_MSG.
*  ELSE.
*    MESSAGE S000 WITH LV_MSG DISPLAY LIKE GC_E.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM FIX_DRQTY_DECIMALS
*&---------------------------------------------------------------------*
*& DRQTY(드럼수) 소수점 제거
*& LVC_FIELDCATALOG_COMPLETE가 QUAN 타입 DECIMALS를 재설정하므로
*& SET_TABLE_FOR_FIRST_DISPLAY 완료 후 프론트엔드 FCAT 직접 수정.
*&---------------------------------------------------------------------*
FORM fix_drqty_decimals USING pcl_grid TYPE REF TO cl_gui_alv_grid.

  DATA: lt_fcat TYPE lvc_t_fcat.

  CHECK pcl_grid IS BOUND.

  CALL METHOD pcl_grid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = lt_fcat.

  LOOP AT lt_fcat ASSIGNING FIELD-SYMBOL(<fct>)
    WHERE fieldname = 'DRQTY'.
    <fct>-decimals = 0.      "소수점 0자리 강제 지정
    CLEAR <fct>-qfieldname.  "MEINS 단위 연결 해제
  ENDLOOP.

  IF sy-subrc = 0.
    CALL METHOD pcl_grid->set_frontend_fieldcatalog
      EXPORTING
        it_fieldcatalog = lt_fcat.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_PR_REST_QTY
*&---------------------------------------------------------------------*
*& 구매요청 발주잔량 체크
*&   잔량 = EBAN-MENGE(요청수량) - EBAN-BSMNG(기발주수량)
*&   1) 잔량 <= 0            -> 중복 발주 차단
*&   2) 이번 발주수량 > 잔량 -> 초과 발주 차단
*& ※ EBAN 단위가 'G'인 경우 ZGTMM_CV_GET_REQPO_RAW에서 화면 수량을
*&    1/1000(KG 환산)으로 내려주므로 비교 전에 EBAN 단위로 되돌린다.
*&---------------------------------------------------------------------*
*&      --> PV_BANFN  구매요청번호
*&      --> PV_BNFPO  구매요청항번
*&      --> PV_MENGE  이번 발주수량(화면 입력값)
*&      <-- CV_MSG    오류 메시지(정상이면 SPACE)
*&---------------------------------------------------------------------*
FORM check_pr_rest_qty USING    pv_banfn TYPE banfn
                                pv_bnfpo TYPE bnfpo
                                pv_menge TYPE zgtmm_cv_get_reqpo_data-menge
                       CHANGING cv_msg   TYPE bapi_msg.

  DATA : lv_qty  TYPE zgtmm_cv_get_reqpo_data-menge,
         lv_rest TYPE zgtmm_cv_get_reqpo_data-menge.

  CLEAR cv_msg.

  SELECT SINGLE FROM eban
    FIELDS menge, bsmng, meins
    WHERE banfn = @pv_banfn
      AND bnfpo = @pv_bnfpo
    INTO @DATA(ls_eban).

  IF sy-subrc <> 0.
    RETURN. "구매요청이 아니면(청구 등) 체크 대상 아님
  ENDIF.

*화면 수량을 EBAN 단위로 환산
  lv_qty  = COND #( WHEN ls_eban-meins = 'G'
                    THEN pv_menge * 1000 ELSE pv_menge ).

  lv_rest = ls_eban-menge - ls_eban-bsmng.

  IF lv_rest <= 0.
    cv_msg = |PR { pv_banfn }/{ pv_bnfpo } 잔여 발주수량 없음 | &&
             |(요청 { ls_eban-menge } / 기발주 { ls_eban-bsmng })|.

  ELSEIF lv_qty > lv_rest.
    cv_msg = |PR { pv_banfn }/{ pv_bnfpo } 발주수량 초과 | &&
             |(잔량 { lv_rest } / 발주요청 { lv_qty })|.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INSPECTION_QTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_LIST_VBELN
*&      --> LS_LIST_POSNR
*&      <-- LV_INSMSG
*&---------------------------------------------------------------------*
FORM check_inspection_qty  USING    pv_vbeln
                                    pv_posnr
                           CHANGING pv_insmsg pv_inqty_w pv_inqty_s.

  SELECT SINGLE FROM zgtmm_cv_so_vcvalue
         FIELDS SUM( CASE atnam WHEN 'MS-WITNESS_INSPE_LENGTH' THEN value_from ELSE 0 END ) AS len_w,
                SUM( CASE atnam WHEN 'MS-SPECIAL_INSPE_LENGTH' THEN value_from ELSE 0 END ) AS len_s
     WHERE vbeln = @pv_vbeln
       AND posnr = @pv_posnr
       AND atnam IN ( 'MS-WITNESS_INSPE_LENGTH', 'MS-SPECIAL_INSPE_LENGTH' )
     INTO @DATA(ls_len).

  pv_inqty_w = ls_len-len_w.   "ALV 표시용 (각각)
  pv_inqty_s = ls_len-len_s.

  IF ls_len-len_w + ls_len-len_s <= 0.   "판정은 합계 (기존 조건 유지)
    pv_insmsg = |SO { pv_vbeln }/{ pv_posnr } 입회검사 건: 여장이 입력되어야 발주 가능합니다.|.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_INSPECTION_QTY
*&   입회검사 '유' 건의 입회검사여장/특별검사여장을 조회 시점에 채운다
*&---------------------------------------------------------------------*
FORM set_inspection_qty .

  TYPES: BEGIN OF ty_key,
           vbeln TYPE vbap-vbeln,
           posnr TYPE vbap-posnr,
         END OF ty_key.
  DATA lt_key TYPE SORTED TABLE OF ty_key WITH UNIQUE KEY vbeln posnr.

  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<fs_k>)
       WHERE inspection = '유' AND vbeln IS NOT INITIAL.
    INSERT VALUE #( vbeln = <fs_k>-vbeln posnr = <fs_k>-posnr ) INTO TABLE lt_key.
  ENDLOOP.

  CHECK lt_key IS NOT INITIAL.

  SELECT vbeln, posnr, atnam, value_from
    FROM zgtmm_cv_so_vcvalue
    FOR ALL ENTRIES IN @lt_key
    WHERE vbeln = @lt_key-vbeln
      AND posnr = @lt_key-posnr
      AND atnam IN ( 'MS-WITNESS_INSPE_LENGTH', 'MS-SPECIAL_INSPE_LENGTH' )
    INTO TABLE @DATA(lt_val).

  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<fs_l>)
       WHERE inspection = '유' AND vbeln IS NOT INITIAL.

    CLEAR : <fs_l>-insqty_w, <fs_l>-insqty_s.

    LOOP AT lt_val ASSIGNING FIELD-SYMBOL(<fs_v>)
         WHERE vbeln = <fs_l>-vbeln AND posnr = <fs_l>-posnr.
      CASE <fs_v>-atnam.
        WHEN 'MS-WITNESS_INSPE_LENGTH'.
          <fs_l>-insqty_w = <fs_l>-insqty_w + <fs_v>-value_from.
        WHEN 'MS-SPECIAL_INSPE_LENGTH'.
          <fs_l>-insqty_s = <fs_l>-insqty_s + <fs_v>-value_from.
      ENDCASE.
    ENDLOOP.

  ENDLOOP.

ENDFORM.
