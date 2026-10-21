*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR3010F01
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
            set_alv_toolbar,

            set_alv_fieldcat USING 'H',
            set_alv_layout USING 'H',
            set_event        USING 'H' CHANGING gcl_event gcl_grid,
            set_disp           TABLES gt_fcat gt_head  USING gcl_grid,

            set_alv_fieldcat USING 'I',
            set_alv_layout USING 'I',
            set_event        USING 'I' CHANGING gcl_event gcl_grid_it ,
            set_disp           TABLES gt_fcat_it gt_list USING gcl_grid_it.
*            DISPLAY_ALV.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CONTAINER
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_container .

  IF gcl_docking IS NOT BOUND.

    gcl_docking = NEW #( repid        = sy-repid
                                         dynnr       = sy-dynnr
                                         side           = cl_gui_docking_container=>dock_at_top
                                         extension = 800 ).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_GRID
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_alv_grid .

  IF gcl_grid IS NOT BOUND.

    gcl_split = NEW #( parent    = gcl_docking
                                  rows       = 2
                                  columns = 1 ).

    "#1 ROW
    gcl_con_top = gcl_split->get_container( row    = 1  column = 1 ).

    gcl_grid = NEW #( i_parent           =   gcl_con_top ).
*                                   I_APPL_EVENTS = GC_X ).

    gcl_split->set_row_height( id     = 1  height = 40 ).

    "#2 ROW
    gcl_con_body = gcl_split->get_container( row    = 2    column = 1 ).

    gcl_grid_it = NEW #( i_parent          = gcl_con_body ).
*                                       I_APPL_EVENTS = GC_X ).

    IF sy-subrc <> 0.
      "COULD NOT CREATE ALV GRID (SY-SUBRC = &)
      MESSAGE e725(bt) WITH sy-subrc.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM adjust_fldcats  TABLES pt_fcat TYPE lvc_t_fcat .

  DEFINE _fcat.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA lv_col TYPE i.
  CLEAR  gt_fcat[].

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<fs_s_fct>).
    CLEAR : <fs_s_fct>-col_pos.

    CASE <fs_s_fct>-fieldname.
      WHEN 'STATUS'. "상태
        _fcat TEXT-f01.
        <fs_s_fct>-key = abap_true.
        <FS_S_FCT>-JUST = 'C'.

      WHEN 'STATUSC'. "상태
        _fcat TEXT-f01.
        <fs_s_fct>-key = abap_true.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BUKRS'.  "회사코드
        _fcat TEXT-f04.
        <fs_s_fct>-no_out = gc_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EKORG'.  "구매조직
        _fcat TEXT-f10.
        <fs_s_fct>-no_out = gc_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EKOTX'.     "구매조직(내역)
        _fcat TEXT-f10.
        <fs_s_fct>-key = abap_true.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WERKS'.     " 플랜트
        _fcat TEXT-f02.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WERKS_N'.  "플랜트명
        _fcat TEXT-f03.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EKGRP'.      "구매그룹
        _fcat TEXT-f08.
*        <FS_S_FCT>-F4AVAILABL = ZGTFI_X.
*        <FS_S_FCT>-REF_TABLE = 'MARC'.
*        <FS_S_FCT>-REF_FIELD  = 'EKGRP'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EKNAM'.     "구매그룹명
        _fcat TEXT-f09.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EBELN'.     "PO번호
        _fcat TEXT-f12.
        <fs_s_fct>-hotspot = gc_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AEDAT_H'.     "생성일
        _fcat TEXT-f11.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ERNAM'.       "생성자
        _fcat TEXT-f15.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LIFNR'.   "공급업체
        _fcat TEXT-f16.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NAME1'.   "업체명
        _fcat TEXT-f17.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'IHREZ'.   "업체승인상태
        _fcat '업체승인상태'.
        <fs_s_fct>-no_out = gc_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'IHREZ_N'.   "업체승인상태
        _fcat '업체승인상태'.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'FRGGR	'.     "승인그룹
        _fcat TEXT-f70.
        <fs_s_fct>-no_out = gc_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'REL_STAT'.     "승인상태
        _fcat TEXT-f69.
        <fs_s_fct>-no_out = gc_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'REL_ICON'.     "승인상태
        _fcat TEXT-f69.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BRTWR'.        "오더총액
        _fcat TEXT-f35.
        <fs_s_fct>-cfieldname = 'PO_WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'PO_WAERS'.        "PO 통화
        _fcat TEXT-f34.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BME'.         " NF단위
        _fcat TEXT-f64.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGW_T'.    	 "총 NF 량
        _fcat TEXT-f67.
        <fs_s_fct>-qfieldname = 'BME'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'GR_MENGE'.     "입고수량(총량)
        _fcat TEXT-f71.
        <fs_s_fct>-tech = gc_x.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'GR_MEINS'.     "입고단위
        _fcat TEXT-f72.
        <fs_s_fct>-no_out = gc_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'IV1_QTY'.     "정산수량(총량)
        _fcat TEXT-f73.
        <fs_s_fct>-no_out = gc_x.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'IV1_BRPME'.     "정산단위
        _fcat TEXT-f74.
        <fs_s_fct>-no_out = gc_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MESSAGE'.   "처리결과
        _fcat TEXT-f68.
        <FS_S_FCT>-JUST = 'C'.
      WHEN OTHERS.
        <fs_s_fct>-no_out = zgtfi_x.

    ENDCASE.

    APPEND <fs_s_fct> TO gt_fcat.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_ITEM
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM adjust_fldcats_item  TABLES pt_fcat TYPE lvc_t_fcat .

  DEFINE _fcat.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA lv_col TYPE i.
  CLEAR gt_fcat_it[].

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<fs_s_fct>).
    CLEAR : <fs_s_fct>-col_pos.

    CASE <fs_s_fct>-fieldname.
      WHEN 'EBELN'.     "PO번호
        _fcat TEXT-f12.
        <fs_s_fct>-hotspot = gc_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EBELP'.    "항번
        _fcat TEXT-f13.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LOEKZ'.     "삭제
        _fcat TEXT-f14.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ELIKZ'.        "납품완료
        _fcat TEXT-f18.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'RETPO'.        "반품
        _fcat TEXT-f19.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MATNR'.        "자재코드
        _fcat TEXT-f20.
        <fs_s_fct>-hotspot = gc_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'TXZ01'.        "자재명
        _fcat TEXT-f21.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'COLOR'.        "색상
        _fcat TEXT-f22.
        <FS_S_FCT>-JUST = 'C'.
        <FS_S_FCT>-EMPHASIZE = 'C410'.
      WHEN 'LENGTH'.        "조장
        _fcat TEXT-f23.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'IDNLF'.        "업체자재명칭
        _fcat TEXT-f24.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LGORT'.        "저장위치
        _fcat TEXT-f25.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LGOBE'.        "저장위치명
        _fcat TEXT-f26.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MENGE'.        "PO수량
        _fcat TEXT-f27.
        <fs_s_fct>-qfieldname = 'LMEIN'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'UMREZ	'.        "분자
        _fcat TEXT-f75.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'UMREN'.        "분모
        _fcat TEXT-f76.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LMEIN'.        "PO단위
        _fcat TEXT-f28.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PO_DRQTY'.        "드럼수
        _fcat TEXT-f77.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C300'.
      WHEN 'DR_MEINS'.        "드럼단위
        _fcat TEXT-f78.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'UEBTO'.        "초과납품%
        _fcat TEXT-f29.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'UEBTK'.        "무제한납품
        _fcat TEXT-f79.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'UNTTO'.        "미달납품%
        _fcat TEXT-f79.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EINDT'.        "납품요청일
        _fcat TEXT-f30.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NETPR'.        "PO단가
        _fcat TEXT-f31.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C500'.
      WHEN 'PEINH'.        "PER
        _fcat TEXT-f32.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BPRME'.        "PO 가격단위
        _fcat TEXT-f33.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BPUMZ'.        "분자
        _fcat TEXT-f75.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BPUMN'.        "분모
        _fcat TEXT-f76.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WAERS'.        "PO 통화
        _fcat TEXT-f34.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NETWR'.        "오더금액
        _fcat TEXT-f81.
        <fs_s_fct>-no_out = zgtfi_x.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C500'.
      WHEN 'BRTWR'.        "오더총액
        _fcat TEXT-f35.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C500'.
      WHEN 'MWSKZ'.        "TAX
        _fcat TEXT-f36.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'INFNR'.     "INFOREC.
        _fcat TEXT-f49.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BANFN'.     "구매요청
        _fcat TEXT-f50.
        <fs_s_fct>-hotspot = gc_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BNFPO'.     "항번
        _fcat TEXT-f13.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'AFNAM'.     "요청자
        _fcat TEXT-f51.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'GR_MENGE'.        "입고수량
        _fcat TEXT-f38.
        <fs_s_fct>-qfieldname = 'GR_MEINS'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'GR_MEINS'.        "입고단위
        _fcat TEXT-f39.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'IV1_QTY'.     "정산수량
        _fcat TEXT-f43.
        <fs_s_fct>-qfieldname = 'IV1_BPRME'.
        <FS_S_FCT>-JUST = 'R'.
        <FS_S_FCT>-EMPHASIZE = 'C700'.
      WHEN 'IV1_BPRME'.     "정산수량단위
        _fcat TEXT-f44.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'EMLIF'.     "직납업체
        _fcat TEXT-f52.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NAME_V'.     "직납업체명
        _fcat TEXT-f53.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'LBLKZ'.     "외주공급여부
        _fcat TEXT-f82.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PSTYP'.     "IC
        _fcat TEXT-f54.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'PTEXT'.     "IC명
        _fcat TEXT-f55.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KNTTP'.     "AAC
        _fcat TEXT-f56.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KNTTX'.     "AAC명
        _fcat TEXT-f57.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VBELN'.     "판매오더
        _fcat TEXT-f58.

        <fs_s_fct>-hotspot = gc_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'POSNR'.     "항번
        _fcat TEXT-f13.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKORG'.     "영업조직
        _fcat TEXT-f83.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VTWEG'.     "유통경로
        _fcat TEXT-f84.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKBUR'.     "영업팀
        _fcat TEXT-f85.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKBUR_N'.    "영업팀명
        _fcat TEXT-f59.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKGRP'.     "영업그룹
        _fcat TEXT-f86.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VKGRP_N'.     "영업그룹명
        _fcat TEXT-f60.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'KUNNR'.     "고객
        _fcat TEXT-f87.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NAME_K'.     "고객명
        _fcat TEXT-f61.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'NES'.           " NF키
        _fcat TEXT-f62.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGW'.           "NF량
        _fcat TEXT-f63.
        <fs_s_fct>-qfieldname = 'BME'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'BME'.         " NF단위
        _fcat TEXT-f64.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGE'.        	"NF PER
        _fcat TEXT-f65.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MEINS_B'.   "재고단위
        _fcat TEXT-f66.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VGW_T'.    	 "총 NF 량
        _fcat TEXT-f67.
        <fs_s_fct>-qfieldname = 'MEINS_B'.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'NTGEW'.    "순중량
        _fcat TEXT-f88.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'BRGEW'.     "총중량
        _fcat TEXT-f89.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'GEWEI'.    "중량단위
        _fcat TEXT-f90.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'VOLUM'.     "볼륨
        _fcat TEXT-f91.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'R'.
      WHEN 'VOLEH'.    "부피단위
        _fcat TEXT-f92.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MATKL'.     "자재그룹
        _fcat TEXT-f93.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'WGBEZ60'.    "자재그룹명
        _fcat TEXT-f94.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MTART'.     "자재유형
        _fcat TEXT-f95.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MTBEZ'.    "자재유형명
        _fcat TEXT-f96.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MFRNR'.     "제조업체
        _fcat TEXT-f97.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'MFRPN'.    "제조업체부품번호
        _fcat TEXT-f98.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'ADRNR'.     "주소
        _fcat TEXT-f99.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DNAME1'.    "이름
        _fcat TEXT-100.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'DNAME2'.     "이름2
        _fcat TEXT-101.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'STREET'.    "도로 주소
        _fcat TEXT-102.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'HOUSE_NUM1'.     "번지
        _fcat TEXT-103.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'POST_CODE1'.    "우편번호
        _fcat TEXT-104.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'CITY1'.     "도시
        _fcat TEXT-105.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'REGION'.    "지역
        _fcat TEXT-106.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
      WHEN 'BEZEI'.     "내역
        _fcat TEXT-107.
        <fs_s_fct>-no_out = zgtfi_x.
        <FS_S_FCT>-JUST = 'C'.
*      WHEN 'MESSAGE'.   "내역
*        _FCAT TEXT-F68.

      WHEN OTHERS.
        <fs_s_fct>-no_out = zgtfi_x.
    ENDCASE.

    APPEND <fs_s_fct> TO gt_fcat_it.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_LAYOUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_alv_layout USING pv_gb.

  CLEAR gs_layout.
  gs_layout = VALUE #(
*                       NO_ROWINS  = ZGTFI_X
                       zebra           = gc_x
                       sel_mode    = gc_d
                       cwidth_opt = zgtfi_a
                       smalltitle  = gc_x
                       grid_title  = COND #( WHEN pv_gb = 'H' THEN '구매오더헤더'(t05)
                                                           ELSE '구매오더품목'(t06) )
*                       STYLEFNAME = 'STYLE'
*                       CTAB_FNAME = 'COLO'
  ).

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_TOOLBAR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_alv_toolbar.

  REFRESH : gt_exclud, gt_excd.

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

  gt_excd[] = VALUE #( ( cl_gui_alv_grid=>mc_fc_excl_all ) ).

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
*& FORM SET_EVENT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_event  USING pv_gb
                              CHANGING po_event TYPE REF TO lcl_evt_receiver
                                               pcl_grid  TYPE REF TO cl_gui_alv_grid.

  pcl_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).
  pcl_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).

*  PERFORM SET_CELL_COLOR.

  CREATE OBJECT po_event.

  IF pv_gb = gc_h.
    SET HANDLER :
    po_event->handle_data_changed                 FOR pcl_grid,
*  PO_EVENT->HANDLE_DATA_CHANGED_FINISHED  FOR PCL_GRID,
    po_event->handle_hotspot_click                FOR pcl_grid,
    po_event->handle_toolbar                           FOR pcl_grid,
    po_event->handle_user_command               FOR pcl_grid.
*  PO_EVENT->HANDLE_ON_F4                               FOR PCL_GRID.
  ELSE.
    SET HANDLER   po_event->handle_hotspot_click  FOR pcl_grid.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_DISP
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GT_HFCAT
*&      --> <GT_HLIST>
*&      --> GR_HGRID
*&      --> GS_HLAYO
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_disp TABLES pt_fcat TYPE lvc_t_fcat
                                      pt_list
                            USING pr_grid TYPE REF TO cl_gui_alv_grid.

*  CLEAR : GS_VARI.
*  CASE PV_TYPE.
*    WHEN 'H'.
*      GS_VARI-REPORT   = SY-REPID.
*      GS_VARI-HANDLE   = SY-DYNNR.
*      GS_VARI-USERNAME = SY-UNAME.
*  ENDCASE.

  DATA(ls_varint) = VALUE disvariant( report  = sy-cprog
                                       handle  = COND #( WHEN  pr_grid = gcl_grid THEN '0001'
                                                                   WHEN pr_grid = gcl_grid_it THEN '0002' ) ).

  CALL METHOD pr_grid->set_table_for_first_display
    EXPORTING
      is_variant           = ls_varint
      i_save               = gc_a
      is_layout            = gs_layout
      it_toolbar_excluding = gt_exclud[]
    CHANGING
      it_outtab            = pt_list[]
      it_fieldcatalog      = pt_fcat[].

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM display_alv .

  DATA(ls_varint) = VALUE disvariant( report  = sy-cprog
                                           handle  = '0001' ).

  CALL METHOD gcl_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      it_toolbar_excluding = gt_exclud[]
      is_variant           = ls_varint
      i_save               = zgtfi_a
    CHANGING
      it_outtab            = gt_list[]
      it_fieldcatalog      = gt_fcat[]
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
DATA: lt_values TYPE TABLE OF USVALUES,
      ls_values TYPE USVALUES.


  CLEAR : sscrfields-functxt_01, gs_functxt.
  gs_functxt = VALUE #( text = '승인자등록'
                                         quickinfo = '승인자등록' ).
  sscrfields-functxt_01 = gs_functxt.

  CLEAR : s_erdat[]. "생성일
  s_erdat[] = VALUE #( ( sign   = gc_i
                                        option = gc_bt
                                        low    = sy-datlo - 30
                                        high   = sy-datlo ) ).

    CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
      EXPORTING
        MANDANT = SY-MANDT
        SEL_OBJECT     = 'ZCBO_MM001' " 조회할 권한 오브젝트명
        user_name         = sy-uname
      TABLES
        values          = lt_values
      EXCEPTIONS
        user_name_invalid = 1
        object_not_found  = 2
        internal_error    = 3
        OTHERS            = 4.

      DELETE  LT_VALUES WHERE VON = '*'.

    IF LT_VALUES[] IS NOT INITIAL.
      READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'BUKRS'.
      IF SY-SUBRC EQ 0. P_BUKRS = LS_VALUES-VON. ENDIF.

      READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'EKORG'.
      IF SY-SUBRC EQ 0. P_EKORG = LS_VALUES-VON. ENDIF.

      READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'WERKS'.
      IF SY-SUBRC EQ 0. P_WERKS = LS_VALUES-VON. ENDIF.

      READ TABLE LT_VALUES INTO LS_VALUES WITH KEY FIELD = 'EKGRP'.
      IF SY-SUBRC EQ 0. S_EKGRP-LOW = LS_VALUES-VON. ENDIF.

    ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM selection_screen .

  CASE sscrfields-ucomm.
    WHEN 'FC01'.
      CALL  TRANSACTION 'ZGTMMR1030'. "구매그룹 담당자 관리 프로그램 호출.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM input_validation.

  CLEAR : gt_list, gv_err.

  IF s_erdat[] IS INITIAL.
    MESSAGE s000 WITH TEXT-m13 DISPLAY LIKE gc_e.
    gv_err = gc_x. STOP. "생성일을 입력하세요.
  ENDIF.

  IF  s_ekgrp-low IS NOT INITIAL.
    LOOP AT s_ekgrp INTO DATA(ls_ekgrp).

      SELECT SINGLE 1
       FROM t024
       WHERE ekgrp EQ @ls_ekgrp-low
        INTO @DATA(lv_exst).

      IF sy-subrc <> 0.
        MESSAGE s000 WITH TEXT-m02 DISPLAY LIKE gc_e.
        gv_err = gc_x.  STOP. "유효하지 않은 구매그룹 입니다.
      ENDIF.

    ENDLOOP.
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

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM check_auth.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                  ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드 [&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'EKORG' FIELD P_EKORG.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_EKORG'.
  MESSAGE E170 WITH P_EKORG. "구매조직 [&] 작업권한을 확인하세요.


  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트 [&] 작업권한을 확인하세요.

   LOOP AT S_EKGRP INTO DATA(LS_EKGRP2).
       AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                     ID 'EKGRP' FIELD LS_EKGRP2-LOW.

       CHECK SY-SUBRC <> 0.

      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE E171 WITH S_EKGRP-LOW. "구매그룹 [&] 작업권한을 확인하세요.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM selection_screen_output .

*  LOOP AT SCREEN.
*    IF R_1_2 IS INITIAL AND SCREEN-GROUP1 = 001.
*      SCREEN-ACTIVE = 0.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM get_data .

  CLEAR : gv_err, gt_head, gt_item, gt_list.
  DATA lv_cond TYPE string.

  lv_cond = | BUKRS = @P_BUKRS AND EKORG = @P_EKORG AND WERKS = @P_WERKS |.
  lv_cond &&= | AND EKGRP IN  @S_EKGRP AND EBELN IN @S_EBELN AND LIFNR IN @S_LIFNR |.
  lv_cond &&= | AND AEDAT_H BETWEEN @S_ERDAT-LOW AND @S_ERDAT-HIGH |.
  lv_cond &&= | AND ANAME = @SY-UNAME |.

  IF p_dpo = gc_x. "승인 PO 제외
    lv_cond &&= | AND REL_STAT IS INITIAL |. "INITIAL=승인 된 오더
  ENDIF.

  SELECT FROM zgtmm_cv_get_po_data_aph
    FIELDS *
    WHERE (lv_cond)
        INTO CORRESPONDING FIELDS OF TABLE @gt_head.

*ITEM DATA 미리 담아두고 ALV는 헤더 선택 시 보여줌.
  IF gt_head[] IS NOT INITIAL.
    SELECT FROM zgtmm_cv_get_po_data_grl
      FIELDS *
      FOR ALL ENTRIES IN @gt_head
      WHERE ebeln = @gt_head-ebeln
      INTO CORRESPONDING FIELDS OF TABLE @gt_item.
  ENDIF.

  IF gt_head[] IS INITIAL .
    gv_err = gc_x. "조회 조건에 일치하는 정보가 없습니다.
    MESSAGE s000 WITH TEXT-e01. EXIT.
  ELSE.
    LOOP AT GT_HEAD ASSIGNING FIELD-SYMBOL(<FS>).
      IF <FS>-REL_STAT = GC_X.
          <FS>-STATUSC = ICON_CHECKED.
      ELSE.
           <FS>-STATUSC = ICON_LED_YELLOW.
      ENDIF.
    ENDLOOP.

  ENDIF.

  SORT gt_head BY bukrs ekorg werks ekgrp lifnr ASCENDING
                             ebeln DESCENDING.
  SORT gt_item BY ebeln DESCENDING.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM get_data_REFRESH  USING PV_CHECK.

  CLEAR : gv_err, gt_head, gt_item, gt_list.
  DATA lv_cond TYPE string.

  lv_cond = | BUKRS = @P_BUKRS AND EKORG = @P_EKORG AND WERKS = @P_WERKS |.
  lv_cond &&= | AND EKGRP IN  @S_EKGRP AND EBELN IN @S_EBELN AND LIFNR IN @S_LIFNR |.
  lv_cond &&= | AND AEDAT_H BETWEEN @S_ERDAT-LOW AND @S_ERDAT-HIGH |.
  lv_cond &&= | AND ANAME = @SY-UNAME |.

  IF p_dpo = gc_x. "승인 PO 제외
    lv_cond &&= | AND REL_STAT IS INITIAL |. "INITIAL=승인 된 오더
  ENDIF.

 WAIT UP TO '0.5' SECONDS.
  SELECT FROM zgtmm_cv_get_po_data_aph
    FIELDS *
    WHERE (lv_cond)
        INTO CORRESPONDING FIELDS OF TABLE @gt_head.

*ITEM DATA 미리 담아두고 ALV는 헤더 선택 시 보여줌.
  IF gt_head[] IS NOT INITIAL.
    SELECT FROM zgtmm_cv_get_po_data_grl
      FIELDS *
      FOR ALL ENTRIES IN @gt_head
      WHERE ebeln = @gt_head-ebeln
      INTO CORRESPONDING FIELDS OF TABLE @gt_item.

     LOOP AT GT_HEAD ASSIGNING FIELD-SYMBOL(<FS>).
      IF <FS>-REL_STAT = GC_X.
          <FS>-STATUSC = ICON_CHECKED.
      ELSE.
           <FS>-STATUSC = ICON_LED_YELLOW.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT gt_head BY bukrs ekorg werks ekgrp lifnr ASCENDING
                             ebeln DESCENDING.
  SORT gt_item BY ebeln DESCENDING.

 IF PV_CHECK = GC_R.
  MESSAGE s000 WITH TEXT-M14.
  EXIT.
ELSE.
  MESSAGE s000 WITH TEXT-M15. EXIT.
ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      FORM  POPUP_TO_CONFIRM_STEP
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
FORM popup_to_confirm_step  USING pv_gb .

  CLEAR gv_answer.

  IF pv_gb = gc_r.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption  = gc_n
        textline1      = TEXT-t01 "선택된 구매오더를 승인 하시겠습니까?
        textline2      = TEXT-t02 "(승인 시 G-PRO에 게시됩니다.)
        titel          = TEXT-t04 "확인
        cancel_display = ''
      IMPORTING
        answer         = gv_answer.

  ELSE.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption  = gc_n
        textline1      = TEXT-t03 "선택된 구매오더를 승인취소 하시겠습니까?
        textline2      = ''
        titel          = TEXT-t04
        cancel_display = ''
      IMPORTING
        answer         = gv_answer.
  ENDIF.

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

*  CHECK PV_MODIFIED IS NOT INITIAL.
*  CHECK PO_SENDER <> GCL_GRID.
*
*  CASE PO_SENDER.
*    WHEN GCL_GRID_3.
*      LOOP AT PT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).
*        READ TABLE GT_LIST_3 ASSIGNING FIELD-SYMBOL(<LS_LIST_3>)
*                                     INDEX LS_MOD_CELLS-ROW_ID..
*        CASE LS_MOD_CELLS-FIELDNAME.
*          WHEN 'HKONT'.
*            IF GV_300GB = 1.
*              <LS_LIST_3>-LIMIT_CUR = <LS_LIST_3>-LIMIT / 100.
*
*            ELSE.
*              <LS_LIST_3>-LIMIT_CUR = <LS_LIST_3>-LIMIT / 100.
*              SELECT SINGLE SUM( A~CLAMT )
*                FROM @GT_LIST_2 AS A
*               WHERE A~CHECK IS NOT INITIAL
*                INTO @DATA(LV_CLAMT).
*              IF LV_CLAMT <> 0.
*                LV_CLAMT = LV_CLAMT * <LS_LIST_3>-LIMIT2.
*              ENDIF.
*              <LS_LIST_3>-LIMIT_CUR += LV_CLAMT.
*            ENDIF.
*
*            READ TABLE GT_DD07T INTO DATA(LS_DD07T)
*                                WITH KEY DOMNAME = 'SHKZG'
*                                         DOMVALUE_L = <LS_LIST_3>-SHKZG
*                                         BINARY SEARCH.
*            IF SY-SUBRC = 0.
*              <LS_LIST_3>-SHKZG_TX = LS_DD07T-DDTEXT.
*            ENDIF.
*        ENDCASE.
*      ENDLOOP.
*
*    WHEN OTHERS.
*  ENDCASE.
*
*  PERFORM RECALCULATE_DATA.
*  PERFORM REFRESH_TABLE USING PO_SENDER SPACE.
*
*  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*    EXPORTING
*      NEW_CODE = 'ENTER'.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CELL_COLOR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_cell_color .

*  DATA : LS_COLOR TYPE    LVC_S_SCOL.

*  DEFINE _SET_COLOR.
*
*    LS_COLOR-FNAME = &1.
*    LS_COLOR-COLOR-COL = &2.
*    LS_COLOR-COLOR-INT  = &3
*    INSERT LS_STYLE INTO TABLE &4.
*
*  END-OF-DEFINITION.

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

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_ALV_FIELDCAT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_alv_fieldcat USING pv_gubun.

  DATA :
    lr_tabdescr TYPE REF TO cl_abap_structdescr,
    lt_dfies    TYPE ddfields,
    ls_dfies    TYPE dfies,
    lt_fcat     TYPE lvc_t_fcat,
    ls_fcat     TYPE lvc_s_fcat.

  DATA : gr_dref  TYPE REF TO data.

  CLEAR gr_dref.
*  CREATE DATA GR_DREF LIKE GS_LIST.
  CASE pv_gubun.
    WHEN gc_h.
      CREATE DATA gr_dref LIKE gs_head.

    WHEN gc_i.
      CREATE DATA gr_dref LIKE gs_list.

    WHEN OTHERS.
  ENDCASE.

  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( gr_dref ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ) .

  REFRESH : lt_fcat.

  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR : ls_fcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fcat.
    APPEND ls_fcat TO lt_fcat.
  ENDLOOP.

  " 필드 카탈로그 변경사항 적용
  CASE pv_gubun.
    WHEN gc_h.
      PERFORM adjust_fldcats TABLES lt_fcat.
    WHEN gc_i.
      PERFORM adjust_fldcats_item TABLES lt_fcat.
    WHEN OTHERS.
  ENDCASE.

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
      _set_tbar 3 '    ' '              ' '    '.
      _set_tbar 0 'REFRESH' ICON_REFRESH 'REFRESH'(b01).
      _set_tbar 0 'REQUEST' ICON_OKAY '승인'(b02).
      _set_tbar 0 'REQ_CANC'  ICON_CANCEL '승인취소'(b03).
      _set_tbar 0 'DISPLAY'  ICON_SELECT_DETAIL '구매오더품목조회'(b04).

    WHEN OTHERS.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM USER_COMMAND
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM user_command  USING pv_ucomm LIKE sy-ucomm.

  CASE pv_ucomm.
    WHEN 'REFRESH'.
      PERFORM get_data.

    WHEN 'REQUEST'.
      PERFORM approval_request USING 'R'.
*      PERFORM get_data_REFRESH USING 'R'.

    WHEN 'REQ_CANC'.
      PERFORM approval_request USING 'C'.
*      PERFORM get_data_REFRESH USING 'C'.

    WHEN 'DISPLAY'.
      PERFORM get_data_item.

  ENDCASE.

  PERFORM refresh_table USING gcl_grid space.
  PERFORM refresh_table USING gcl_grid_it space.

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
      PERFORM data_changed_1 USING po_data_changed.

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

  CLEAR : gt_rows, gs_row, gt_list[].

  PERFORM get_selected_rows USING gcl_grid.
  CHECK gv_err IS INITIAL.

  LOOP AT gt_rows INTO gs_row.

    READ TABLE gt_head  INTO DATA(ls_hd) INDEX gs_row-index.
    CHECK sy-subrc EQ 0.

    READ TABLE gt_item INTO DATA(ls_it) WITH KEY ebeln = ls_hd-ebeln.
    IF sy-subrc = 0.
      APPEND ls_it TO gt_list.
    ENDIF.

    CLEAR : ls_hd, ls_it.
  ENDLOOP.

*  LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_MOD_CELLS).
*
*    READ TABLE GT_HEAD  INTO DATA(LS_HD) INDEX LS_MOD_CELLS-ROW_ID.
*    CHECK SY-SUBRC EQ 0.
*
*    READ TABLE GT_ITEM INTO DATA(LS_IT) WITH KEY EBELN = LS_HD-EBELN.
*    IF SY-SUBRC = 0.
*       APPEND LS_IT TO GT_LIST.
*    ENDIF.
*
*  ENDLOOP.

  PERFORM refresh_table USING gcl_grid_it space.

ENDFORM. " DATA_CHANGED_1

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

    WHEN gcl_grid.
      READ TABLE gt_head INTO DATA(ls_hd) INDEX ps_row_no-index.
      CHECK sy-subrc = 0.

      IF ps_column-fieldname = 'EBELN'.
        CHECK ls_hd-ebeln IS NOT INITIAL.

        CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
          EXPORTING
            i_ebeln        = ls_hd-ebeln
            i_display_only = ' '.
*        SET PARAMETER ID 'BES' FIELD LS_HEAD-EBELN.
*        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

      ELSE.
        EXIT.
      ENDIF.

    WHEN gcl_grid_it.
      READ TABLE gt_list INTO DATA(ls_list) INDEX ps_row_no-index.
      CHECK sy-subrc = 0.

      IF ps_column-fieldname = 'EBELN'.
        CHECK ls_list-ebeln IS NOT INITIAL.

        CALL FUNCTION 'ME_DISPLAY_PURCHASE_DOCUMENT'
          EXPORTING
            i_ebeln        = ls_list-ebeln
            i_display_only = ' '.
*        SET PARAMETER ID 'BES' FIELD LS_LIST-EBELN.
*        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

      ELSEIF ps_column-fieldname = 'BANFN'.
        CHECK ls_list-banfn IS NOT INITIAL.

        SET PARAMETER ID 'BAN' FIELD ls_list-banfn.
        CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.

      ELSEIF ps_column-fieldname = 'MATNR'.
        CHECK ls_list-MATNR IS NOT INITIAL.

           SET PARAMETER ID 'MAT' FIELD ls_list-MATNR.
           CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

      ELSEIF ps_column-fieldname = 'VBELN'.
        CHECK ls_list-VBELN IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD ls_list-Vbeln.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

      ELSE.
        EXIT.
      ENDIF.

  ENDCASE.

*        PERFORM REFRESH_TABLE USING GCL_GRID SPACE.
*        CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*          EXPORTING
*            NEW_CODE = 'ENTER'.


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
*
*  DATA : SELECTFIELD  LIKE HELP_INFO-FIELDNAME,
*         IT_FIELDS    LIKE HELP_VALUE OCCURS 1 WITH HEADER LINE,
*         LS_HEADING   TYPE F4TYP_HEAD_STRUC,
*         LT_HEADING   TYPE F4TYP_HEADING_TAB,
*         SELECT_VALUE LIKE HELP_INFO-FLDVALUE,
*         LV_TABIX     LIKE SY-TABIX,
*         LS_MODI      TYPE LVC_S_MODI,
*         F_DATE       LIKE SY-DATUM.
*
*  FIELD-SYMBOLS : <F4TAB> TYPE LVC_T_MODI.
*
**  CASE E_FIELDNAME.
**    WHEN .
**    WHEN .
**    WHEN OTHERS.
**  ENDCASE.
*
*  IF E_FIELDNAME = 'HKONT'.
*    "수금유형이 CA 인 경우 환차손/환차익 계정 제외.
*    DATA(LT_TEMP) = GT_ACCT[].
**    IF GS_200-BLART = 'CA'.
**      DELETE LT_TEMP WHERE SAKNR = GC_7140101
**                        OR SAKNR = GC_7330101.
**    ENDIF.
*
*    IT_FIELDS-TABNAME    = 'ZTRTF271'.
*    IT_FIELDS-FIELDNAME  = 'SAKNR'.
*    IT_FIELDS-SELECTFLAG = 'X'.
*    APPEND IT_FIELDS.
*
*    IT_FIELDS-TABNAME    = 'ZTRTF271'.
*    IT_FIELDS-FIELDNAME  = 'TXT50'.
*    IT_FIELDS-SELECTFLAG = ' '.
*    APPEND IT_FIELDS.
*
*    IT_FIELDS-TABNAME    = 'ZTRTF271'.
*    IT_FIELDS-FIELDNAME  = 'SHKZG'.
*    IT_FIELDS-SELECTFLAG = ' '.
*    APPEND IT_FIELDS.
*
**    IT_FIELDS-TABNAME    = 'ZTRTF271'.
**    IT_FIELDS-FIELDNAME  = 'LIMIT'.
**    IT_FIELDS-SELECTFLAG = ' '.
**    APPEND IT_FIELDS.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'ZTRTF271'.
*    LS_HEADING-FIELDNAME = 'SAKNR'.
*    LS_HEADING-HEAD_TEXT = TEXT-F38.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'ZTRTF271'.
*    LS_HEADING-FIELDNAME = 'TXT50'.
*    LS_HEADING-HEAD_TEXT = TEXT-F39.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'ZTRTF271'.
*    LS_HEADING-FIELDNAME = 'SHKZG'.
*    LS_HEADING-HEAD_TEXT = TEXT-F37.
*    APPEND LS_HEADING TO LT_HEADING.
*
**    CLEAR LS_HEADING.
**    LS_HEADING-TABNAME = 'ZTRTF271'.
**    LS_HEADING-FIELDNAME = 'LIMIT'.
**    LS_HEADING-HEAD_TEXT = TEXT-F46.
**    APPEND LS_HEADING TO LT_HEADING.
*
*
*    CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
*      EXPORTING
*        SELECTFIELD                  = SELECTFIELD
*      IMPORTING
*        IND                          = LV_TABIX
*        SELECT_VALUE                 = SELECT_VALUE
*      TABLES
*        FIELDS                       = IT_FIELDS
*        FULL_TABLE                   = LT_TEMP[]
*        HEADING_TABLE                = LT_HEADING
*      EXCEPTIONS
*        FULL_TABLE_EMPTY             = 1
*        NO_TABLESTRUCTURE_GIVEN      = 2
*        NO_TABLEFIELDS_IN_DICTIONARY = 3
*        MORE_THEN_ONE_SELECTFIELD    = 4
*        NO_SELECTFIELD               = 5
*        OTHERS                       = 6.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE S002 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
*    ENDIF.
*
*    READ TABLE LT_TEMP INTO DATA(LS_TEMP) INDEX LV_TABIX.
*
*    ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.
*
*    LS_MODI-ROW_ID    = ES_ROW_NO-ROW_ID.
*    LS_MODI-FIELDNAME = 'HKONT'.
*    LS_MODI-VALUE     = SELECT_VALUE.
*    APPEND LS_MODI TO <F4TAB>.
*
*    LS_MODI-FIELDNAME = 'HKONT_TX'.
*    LS_MODI-VALUE     = LS_TEMP-TXT50.
*    APPEND LS_MODI TO <F4TAB>.
*
*  ELSEIF E_FIELDNAME = 'MWSKZ'.
*    IT_FIELDS-TABNAME    = 'T007S'.
*    IT_FIELDS-FIELDNAME  = 'MWSKZ'.
*    IT_FIELDS-SELECTFLAG = 'X'.
*    APPEND IT_FIELDS.
*
*    IT_FIELDS-TABNAME    = 'T007S'.
*    IT_FIELDS-FIELDNAME  = 'TEXT1'.
*    IT_FIELDS-SELECTFLAG = ' '.
*    APPEND IT_FIELDS.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'T007S'.
*    LS_HEADING-FIELDNAME = 'MWSKZ'.
*    LS_HEADING-HEAD_TEXT = TEXT-F54.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CLEAR LS_HEADING.
*    LS_HEADING-TABNAME = 'T007S'.
*    LS_HEADING-FIELDNAME = 'TEXT1'.
*    LS_HEADING-HEAD_TEXT = TEXT-F60.
*    APPEND LS_HEADING TO LT_HEADING.
*
*    CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
*      EXPORTING
*        SELECTFIELD                  = SELECTFIELD
*      IMPORTING
*        IND                          = LV_TABIX
*        SELECT_VALUE                 = SELECT_VALUE
*      TABLES
*        FIELDS                       = IT_FIELDS
*        FULL_TABLE                   = GT_007S
*        HEADING_TABLE                = LT_HEADING
*      EXCEPTIONS
*        FULL_TABLE_EMPTY             = 1
*        NO_TABLESTRUCTURE_GIVEN      = 2
*        NO_TABLEFIELDS_IN_DICTIONARY = 3
*        MORE_THEN_ONE_SELECTFIELD    = 4
*        NO_SELECTFIELD               = 5
*        OTHERS                       = 6.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE S002 WITH 'POSSIBLE ENTRY DATA가 없습니다 !!!'.
*    ENDIF.
*
*    READ TABLE GT_007S INDEX LV_TABIX.
*
*    ASSIGN ER_EVENT_DATA->M_DATA->* TO <F4TAB>.
*
*    LS_MODI-ROW_ID    = ES_ROW_NO-ROW_ID.
*    LS_MODI-FIELDNAME = 'MWSKZ'.
*    LS_MODI-VALUE     = SELECT_VALUE.
*    APPEND LS_MODI TO <F4TAB>.
*
*    LS_MODI-FIELDNAME = 'MWSKZ_TX'.
*    LS_MODI-VALUE     = GT_007S-TEXT1.
*    APPEND LS_MODI TO <F4TAB>.
*  ENDIF.
*
** TO AVOID STANDARD F4-HELP.
*  IF LS_MODI-VALUE <> ' ' .
*    ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.
*  ENDIF.

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

  CLEAR : gt_rows, gs_row, gv_err.

  CALL METHOD pr_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_rows.

  DESCRIBE TABLE gt_rows.

  IF sy-tfill = 0.
    gv_err = gc_x.
    MESSAGE s004 DISPLAY LIKE gc_e. "라인을 선택하세요.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM APPROVAL_REQUEST
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM approval_request  USING pv_gb.

  DATA : lt_head LIKE TABLE OF gs_head,
         ls_head LIKE gs_head.
  DATA : lt_del LIKE TABLE OF zgtmmt3000,
         ls_del TYPE zgtmmt3000.

  DATA : ls_head2  TYPE bapimepoheader,
         ls_headx2 TYPE bapimepoheaderx,
         gt_return LIKE TABLE OF bapiret2.

  CLEAR : gv_answer, gv_err, lt_head[].

  PERFORM get_selected_rows USING gcl_grid.
  CHECK gv_err IS INITIAL.

*VALIDATION
  LOOP AT gt_rows INTO gs_row.

    READ TABLE gt_head ASSIGNING FIELD-SYMBOL(<fs>) INDEX gs_row-index.
    IF sy-subrc = 0.
      CLEAR ls_head.


      CASE pv_gb.
        WHEN gc_r.  "승인요청
          IF <fs>-rel_stat = gc_x.
            MESSAGE s000 WITH TEXT-m16 DISPLAY LIKE gc_e.
            gv_err = gc_x.  EXIT."이미 승인된 구매오더는 승인할 수 없습니다.
          ELSE.
            ls_head = CORRESPONDING #( <fs> ).
            APPEND ls_head TO lt_head.

            ls_del-ebeln = <fs>-ebeln.
            APPEND ls_del TO lt_del.
            CLEAR : ls_del.
          ENDIF.

        WHEN gc_c.  "승인취소
          IF <fs>-rel_stat IS INITIAL.
            MESSAGE s000 WITH TEXT-m17 DISPLAY LIKE gc_e.
            gv_err = gc_x.  EXIT."승인되지 않은 구매오더는 승인 취소할 수 없습니다.
          ELSEIF <fs>-frggr IS INITIAL.
            MESSAGE s000 WITH TEXT-m18 DISPLAY LIKE gc_e.
            gv_err = gc_x.  EXIT." 자동 승인된 구매오더는 취소 대상이 아닙니다.
          ELSEIF <fs>-gr_menge > 0 OR <fs>-iv1_qty > 0.
            MESSAGE s000 WITH TEXT-m19 DISPLAY LIKE gc_e.
            gv_err = gc_x.  EXIT. "입고 또는 정산 진행된 구매오더는 취소할 수 없습니다.
          ELSE.
            ls_head = CORRESPONDING #( <fs> ).
            APPEND ls_head TO lt_head.
            ls_del-ebeln = <fs>-ebeln.
            APPEND ls_del TO lt_del.
            CLEAR : ls_del.
          ENDIF.

        WHEN OTHERS.
      ENDCASE.
    ENDIF.

  ENDLOOP.

  CHECK gv_err IS INITIAL.
  CHECK lt_head[] IS NOT INITIAL.

  PERFORM popup_to_confirm_step USING pv_gb .
  CHECK gv_answer = gc_j.

  DATA : lv_ind TYPE bapimmpara-po_rel_ind.
  RANGES lr_ebeln FOR ekko-ebeln.

  LOOP AT lt_head INTO DATA(ls_hd).
    CLEAR : gt_return[], lv_ind.
    CASE pv_gb.
**승인요청
      WHEN gc_r.
*BAPI_PO RELEASE
        CALL FUNCTION 'BAPI_PO_RELEASE'
          EXPORTING
            purchaseorder     = ls_hd-ebeln
            po_rel_code       = 'S1'
          IMPORTING
            rel_indicator_new = lv_ind
          TABLES
            return            = gt_return.
        IF line_exists( gt_return[ type = gc_e ] ) OR lv_ind NE gc_s.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          READ TABLE gt_return INTO DATA(ls_rt) INDEX 1.

          ls_hd-status    = icon_led_red.
          ls_hd-message = ls_rt-message.
          GV_ERR = GC_X.

        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
          ls_hd-status    = icon_led_green.
          ls_hd-message = '승인되었습니다.'(m14).
          APPEND VALUE #( sign = gc_i
                                      option = gc_eq
                                      low = ls_hd-ebeln
                                      high = '' ) TO lr_ebeln.

          CLEAR : ls_head2, ls_headx2.
          ls_head2 = VALUE #( po_number = ls_hd-ebeln
                                           ref_1 = '' ).

          ls_headx2 = VALUE #( po_number = ls_hd-ebeln
                                             ref_1 = gc_x ).

          CLEAR gt_return.

          CALL FUNCTION 'BAPI_PO_CHANGE'
            EXPORTING
              purchaseorder = ls_hd-ebeln
              poheader      = ls_head2
              poheaderx     = ls_headx2
            TABLES
              return        = gt_return.

          IF line_exists( gt_return[ type = gc_e ] ) .
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.
          ENDIF.


        ENDIF.
** ref_1에 업데이트 실패해도 큰 문제 없으므로 오류 체크를 굳이 할 필요 없음


*승인취소
      WHEN gc_c.
*BAPI_PO RESET RELEASE
        CALL FUNCTION 'BAPI_PO_RESET_RELEASE'
          EXPORTING
            purchaseorder     = ls_hd-ebeln
            po_rel_code       = 'S1'
          IMPORTING
            rel_indicator_new = lv_ind
          TABLES
            return            = gt_return.
        IF line_exists( gt_return[ type = gc_e ] ) OR lv_ind NE gc_n.
          READ TABLE gt_return INTO DATA(ls_rtn) INDEX 1.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          ls_hd-status     = icon_led_red.
          ls_hd-message = ls_rtn-message.
          GV_ERR = GC_X.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
          ls_hd-status     = icon_led_green.
          ls_hd-message = '승인 취소되었습니다.'(m15).

        ENDIF.

      WHEN OTHERS.
    ENDCASE.

*ALV UPDATE
    READ TABLE gt_head ASSIGNING FIELD-SYMBOL(<fsr>)
    WITH KEY ebeln = ls_hd-ebeln BINARY SEARCH.

    IF <fsr> IS ASSIGNED.
      <fsr>-status     = ls_hd-status.
      <fsr>-message  = ls_hd-message.
      MODIFY lt_head FROM ls_hd.
    ENDIF.

  ENDLOOP.

  IF lt_del[] IS NOT INITIAL.
    DELETE zgtmmt3000 FROM TABLE lt_del.
  ENDIF.

  SORT gt_head BY bukrs ekorg werks ekgrp lifnr ASCENDING
                               ebeln DESCENDING.
  CLEAR gt_list. "ITEM CLEAR

  "승인요청 시, 릴리즈 성공한 구매오더는 전송 프로그램 실행->전송(G-SRM)
  IF pv_gb = gc_r .
    SUBMIT zgtmmr4930  WITH p_ilog EQ space
                                    WITH p_send  EQ gc_x
                                    WITH p_ifsyt   EQ gc_ksrm "KSRM 가온전선 전자구매시스템
                                    WITH p_bukrs EQ p_bukrs
                                    WITH s_ebeln IN lr_ebeln
                                    WITH p_bat = gc_x   AND RETURN.
  ENDIF.

  IF GV_ERR IS INITIAL.
      PERFORM get_data_REFRESH USING pv_gb.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_DATA_ITEM
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM get_data_item .


  CLEAR : gt_rows, gs_row, gt_list[].

  PERFORM get_selected_rows USING gcl_grid.
  CHECK gv_err IS INITIAL.

  LOOP AT gt_rows INTO gs_row.

    READ TABLE gt_head  INTO DATA(ls_hd) INDEX gs_row-index.
    CHECK sy-subrc EQ 0.

    LOOP AT gt_item INTO DATA(ls_it) WHERE ebeln = ls_hd-ebeln.
      APPEND ls_it TO gt_list.
      CLEAR ls_it.
    ENDLOOP.

    CLEAR ls_hd.
  ENDLOOP.

  SORT gt_list BY ebeln ebelp.

  IF gt_list[] IS INITIAL.
    MESSAGE s000 WITH TEXT-e01 DISPLAY LIKE gc_e.
  ENDIF.

ENDFORM.
