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
            set_alv_grid USING '',
            set_alv_fieldcat USING 'IH',
            set_alv_fieldcat USING 'IB',
            set_alv_layout USING 'INV' gcl_grid_hd,
            set_alv_layout USING 'INV' gcl_grid_it,
            set_alv_toolbar,
            set_alv_sort,
            set_cell_color,
            set_event        CHANGING gcl_event gcl_grid_hd,
            set_event        CHANGING gcl_event gcl_grid_it.

  PERFORM display_alv TABLES gt_list gt_fcat
                                          USING gcl_grid_hd gs_layout.
  PERFORM display_alv TABLES gt_item gt_fcat_it
                                         USING gcl_grid_it gs_layoit.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV_300
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM create_alv_300.

  PERFORM :
            set_alv_grid USING '',
            set_alv_fieldcat USING 'DH',
            set_alv_fieldcat USING 'DB',
            set_alv_layout USING 'DISP' gcl_grid_hd,
            set_alv_layout USING 'DISP' gcl_grid_it,
            set_alv_toolbar,
            set_alv_sort,
            set_cell_color_300 ,
            set_event        CHANGING gcl_event gcl_grid_hd,
            set_event        CHANGING gcl_event gcl_grid_it.

  PERFORM display_alv TABLES gt_disp gt_fcat_disp
                                         USING gcl_grid_hd gs_layout.
  PERFORM display_alv TABLES gt_disp_it gt_fcat_dit
                                         USING gcl_grid_it gs_layoit.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CREATE_ALV_300
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM create_alv_400.

  PERFORM :
            set_alv_grid USING 'TAX',
            set_alv_fieldcat USING 'TAX',
            set_alv_layout USING 'TAX' gcl_grid_tax,
            set_alv_toolbar,
            set_alv_sort,
            set_cell_color_400 ,
            set_event        CHANGING gcl_event gcl_grid_tax,
            display_alv_400 .

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_ALV_GRID
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_alv_grid USING pv_gb.

  DATA:
    lo_split TYPE REF TO cl_gui_splitter_container,
    lo_hcntr TYPE REF TO cl_gui_container,
    lo_icntr TYPE REF TO cl_gui_container.

  IF pv_gb = 'TAX'.
    gcl_custom2 = NEW #( container_name = 'CON400' ).
    gcl_grid_tax = NEW #( i_parent = gcl_custom2 ).

  ELSE.
*    CASE SY-DYNNR.
*      WHEN '0100'.
*        GCL_DOCK_IT = NEW #( REPID = SY-REPID
*                                              DYNNR   = SY-DYNNR
*                                              SIDE       = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_BOTTOM
*                                              EXTENSION = 100 ).
*
*        GCL_DOCK_HD = NEW #( REPID = SY-REPID
*                                              DYNNR   = SY-DYNNR
*                                              SIDE       = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP
*                                              EXTENSION = 100 ).
*        "ALV OBJ.
*        GCL_GRID_HD = NEW #( I_PARENT = GCL_DOCK_HD ).
*        GCL_GRID_IT = NEW #( I_PARENT = GCL_DOCK_IT ).
*
*      WHEN '0300'.
    gcl_custom = NEW #( container_name = 'CON100' ).

    "SPLIT CONTAINER
    lo_split = NEW #( parent  = gcl_custom
                                  rows    = 2
                                  columns = 1 ).

    lo_hcntr = lo_split->get_container( row = 1 column = 1 ).
    lo_icntr = lo_split->get_container( row = 2 column = 1 ).

    "ALV OBJ.
    gcl_grid_hd = NEW #( i_parent = lo_hcntr ).
    gcl_grid_it = NEW #( i_parent = lo_icntr ).

*      WHEN OTHERS.
*    ENDCASE.

*    "ALV OBJ.
*    GCL_GRID_HD = NEW #( I_PARENT = GCL_DOCK_HD ). "LO_HCNTR ).
*    GCL_GRID_IT = NEW #( I_PARENT = GCL_DOCK_IT ). "LO_ICNTR ).
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
  CLEAR : gt_fcat[].

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<fs_s_fct>).
    CLEAR : <fs_s_fct>-col_pos.

    CASE <fs_s_fct>-fieldname.
      WHEN 'CHECK'.
        _fcat TEXT-f35. "선택
        <fs_s_fct>-checkbox = gc_x.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'STATUS'. "상태
        _fcat TEXT-f01.
        <fs_s_fct>-just = 'C'.
      WHEN 'WERKS'.       "플랜트
        _fcat TEXT-f02.
        <fs_s_fct>-just = 'C'.
      WHEN 'WERKS_N'.  "플랜트명
        _fcat TEXT-f03.
        <fs_s_fct>-just = 'C'.
      WHEN 'LIFNR'.   "공급업체
        _fcat TEXT-f16.
        <fs_s_fct>-just = 'C'.
      WHEN 'LIFNR_N'.   "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-just = 'C'.
        <fs_s_fct>-emphasize = 'C410'.
      WHEN 'BUKRS'.       "회사코드
        _fcat TEXT-f30.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'BUKRS_N'.  "회사명
        _fcat TEXT-f55.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'EKORG'.       "구매조직
        _fcat TEXT-f10.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'EKORG_N'.  "구매조직명
        _fcat TEXT-f75.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'SPMON'.        "입고연월
        _fcat TEXT-f24.
        <fs_s_fct>-just = 'C'.
      WHEN 'EKGRP'.      "구매그룹 "P_EKG(구매그룹별조회)일 경우에만 노출
        _fcat TEXT-f08.
        <fs_s_fct>-no_out = COND #( WHEN p_lif = gc_x THEN gc_x ELSE space ).
        <fs_s_fct>-just = 'C'.
      WHEN 'EKNAM'.     "구매그룹명 "P_EKG(구매그룹별조회)일 경우에만 노출
        _fcat TEXT-f09.
        <fs_s_fct>-no_out = COND #( WHEN p_lif = gc_x THEN gc_x ELSE space ).
        <fs_s_fct>-just = 'C'.
      WHEN 'XRECH'.     "반품정산대상
        _fcat TEXT-fa0.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'XRECH_N'.     "반품정산대상
        _fcat TEXT-fa1.
        <fs_s_fct>-just = 'C'.
      WHEN 'TARGET_PRICE'.     "공급가액
        _fcat TEXT-f29.
        <fs_s_fct>-cfieldname = 'ETIV_WAERS'.
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C300'.
      WHEN 'TAXPRICE'.        "세액
        _fcat TEXT-f33.
        <fs_s_fct>-cfieldname = 'ETIV_WAERS'.
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C500'.
      WHEN 'ETIV_WAERS'.        "통화
        _fcat TEXT-f34.
        <fs_s_fct>-just = 'C'.
      WHEN 'WRBTR'.        "합계금액
        _fcat TEXT-f37.
        <fs_s_fct>-cfieldname = 'ETIV_WAERS'.
        <fs_s_fct>-emphasize = 'C310'. "C:색 3:노랑 1:진하게 0:반전없음
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C700'.
      WHEN 'EXRATE'.        "환율
        _fcat TEXT-f42.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'MWSKZ'.        "TAX
        _fcat TEXT-f52.
        <fs_s_fct>-just = 'C'.
      WHEN 'MESSAGE'.   "메시지
        _fcat TEXT-f68.
        <fs_s_fct>-just = 'C'.

      WHEN OTHERS.
        <fs_s_fct>-no_out = gc_x.

    ENDCASE.

    APPEND <fs_s_fct> TO gt_fcat.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_DISP
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM adjust_fldcats_disp  TABLES pt_fcat TYPE lvc_t_fcat  USING pv_gb.

  DEFINE _fcat.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA lv_col TYPE i.
  IF pv_gb = 'HD'.
    CLEAR  gt_fcat_disp[].
  ELSE.
    CLEAR gt_fcat_dit[].
  ENDIF.

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<fs_s_fct>).
    CLEAR : <fs_s_fct>-col_pos.

    CASE <fs_s_fct>-fieldname.
      WHEN 'CHECK'.
        _fcat TEXT-f35. "선택
        <fs_s_fct>-checkbox = gc_x.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'STATUS'. "상태
        _fcat TEXT-f01.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'TIMESTAMP'.
        _fcat TEXT-fa2.
        <fs_s_fct>-just = 'C'.
      WHEN 'REQ'. "지급요청
        _fcat TEXT-f04.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'AP_STATUS_N'. "승인상태명
        _fcat TEXT-f05.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'BUKRS'. "회사코드
        _fcat TEXT-f30.
        <fs_s_fct>-no_out =  gc_x .
        <fs_s_fct>-just = 'C'.
      WHEN 'BUTXT'. "회사명
        _fcat TEXT-f55.
        <fs_s_fct>-no_out =  gc_x .
        <fs_s_fct>-just = 'C'.
      WHEN 'BELNR'. "송장번호
        _fcat TEXT-f07.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'HD' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'BLART'. "전표유형
        _fcat TEXT-f95.
        <fs_s_fct>-no_out =  gc_x .
        <fs_s_fct>-just = 'C'.
      WHEN 'GJAHR'. "회계연도
        _fcat TEXT-f11.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'HD' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'BUZEI'. "송장항번
        _fcat TEXT-f13.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'HD' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'EBELN'.     "구매오더
        _fcat TEXT-f22.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'HD' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'EBELP'.    "항번
        _fcat TEXT-f13.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'HD' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'XRECH'.     "반품정산대상
        _fcat TEXT-fa0.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'XRECH_N'.     "반품정산대상
        _fcat TEXT-fa1.
        <fs_s_fct>-just = 'C'.
      WHEN 'BUDAT'. "전기일
        _fcat TEXT-f12.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'CPUDT'. "입력일
        _fcat TEXT-f38.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'USNAM'. "송장생성자
        _fcat TEXT-f39.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'VGART'. "트랜잭션유형
        _fcat TEXT-f96.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'MATNR'.        "자재코드
        _fcat TEXT-f20.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'HD' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'TXZ01'.        "자재명
        _fcat TEXT-f21.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'HD' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
        <fs_s_fct>-emphasize = 'C210'.
      WHEN 'BUKRS'.       "회사코드
        _fcat TEXT-f30.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'HD' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'WERKS'.       "플랜트
        _fcat TEXT-f02.
        <fs_s_fct>-just = 'C'.
      WHEN 'WERKS_N'.  "플랜트명
        _fcat TEXT-f03.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'LIFNR'.   "공급업체
        _fcat TEXT-f16.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'LIFNR_N'.   "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
        <fs_s_fct>-emphasize = 'C410'.
      WHEN 'WRBTR'.        "입고금액(전표통화)
        _fcat TEXT-f65.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'HD' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C300'.
      WHEN 'WAERS'.        "통화
        _fcat TEXT-f34.
        <fs_s_fct>-just = 'C'.
      WHEN 'KURSF'.        "환율
        _fcat TEXT-f42.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'SHKZG'.        "차변/대변
        _fcat TEXT-f50.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'HD' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'MWSKZ'.     "TAX코드
        _fcat TEXT-f52.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'HD' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'MENGE'.     " 수량
        _fcat TEXT-f44.
        <fs_s_fct>-qfieldname = 'BSTME'.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'HD' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C400'.
      WHEN 'BSTME'.     "구매오더단위
        _fcat TEXT-f46.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'HD' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'RMWWR'.        "합계금액
        _fcat TEXT-f37.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C700'.
      WHEN 'SPRICE'.        "공급가액
        _fcat TEXT-f99.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C300'.
      WHEN 'WMWST1'.  "부가세
        _fcat TEXT-f83.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C500'.
      WHEN 'MWSKZ1'.     "TAX코드
        _fcat TEXT-f52.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'SGTXT'.     "세금계산서일련번호
        _fcat '세금계산서일련번호'.
        <fs_s_fct>-f4availabl = gc_x.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'BKTXT'.     "적요
        _fcat '적요'.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'ZFBDT'.     "지급기준일
        _fcat TEXT-f47.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'ZBD1T'.     "지급일수
        _fcat TEXT-f48.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'EXPDATE'.        "만기일
        _fcat TEXT-f49.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'GJAHR_BKPF'.        "회계연도
        _fcat TEXT-f11.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'BELNR_BKPF'.        "회계전표번호
        _fcat '회계전표번호'.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZTERM'.        "지급조건
        _fcat '지급조건'.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZLSPR'.        "지급보류
        _fcat '지급보류'.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'AP_BELNR'.        "지급요청전표번호
        _fcat '지급요청전표번호'.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'APPID'.        "지급요청품의ID
        _fcat '지급요청품의ID'.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'LEGACYID'.        "SAP DATA의 KEY 정보
        _fcat 'SAP DATA의 KEY 정보'.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'AP_STATUS'.        "지급요청승인상태
        _fcat '지급요청승인상태'.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'REQPAY'.        "지급요청여부
        _fcat TEXT-f84.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'CL_BUDAT'.        "지급전기일
        _fcat TEXT-f85.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'CL_BLDAT'.        "지급증빙일
        _fcat '지급증빙일'.
        <fs_s_fct>-no_out = gc_x .
        <fs_s_fct>-just = 'C'.
      WHEN 'CL_CPUDT'.        "지급전표입력일
        _fcat TEXT-f86.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'CL_AUGDT'.        "반제일
        _fcat TEXT-f87.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'CL_AUGBL'.        "지급전표
        _fcat TEXT-f88.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'CLEARING'.        "지급여부
        _fcat TEXT-f89.
        <fs_s_fct>-no_out = COND  #( WHEN pv_gb = 'IT' THEN gc_x ELSE '' ).
        <fs_s_fct>-just = 'C'.
      WHEN 'VBELN'.        "판매오더
        _fcat TEXT-fa3.
        <fs_s_fct>-just = 'C'.
      WHEN 'VBELP'.        "항번
        _fcat TEXT-fa4.
        <fs_s_fct>-just = 'C'.

      WHEN 'MESSAGE'.   "메시지
        _fcat TEXT-f68.
        <fs_s_fct>-just = 'C'.
      WHEN OTHERS.
        <fs_s_fct>-no_out = gc_x.

    ENDCASE.

    IF pv_gb = 'HD'.
      APPEND <fs_s_fct> TO gt_fcat_disp.
    ELSE.
      APPEND <fs_s_fct> TO gt_fcat_dit.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_DISP
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM adjust_fldcats_item  TABLES pt_fcat TYPE lvc_t_fcat.

  DEFINE _fcat.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA lv_col TYPE i.
  CLEAR : gt_fcat_it[].

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<fs_s_fct>).
    CLEAR : <fs_s_fct>-col_pos.

    CASE <fs_s_fct>-fieldname.
      WHEN 'CHECK'. "선택
        _fcat TEXT-f35.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-checkbox = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'BUKRS'.   "회사코드
        _fcat TEXT-f30.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'EKORG'.   "구매조직
        _fcat TEXT-f10.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'WERKS'.       "플랜트
        _fcat TEXT-f02.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'LIFNR'.   "공급업체
        _fcat TEXT-f16.
        <fs_s_fct>-just = 'C'.
      WHEN 'NAME1'.   "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-just = 'C'.
        <fs_s_fct>-emphasize = 'C410'.
      WHEN 'EKGRP'.      "구매그룹
        _fcat TEXT-f08.
        <fs_s_fct>-just = 'C'.
      WHEN 'EKNAM'.     "구매그룹명
        _fcat TEXT-f09.
        <fs_s_fct>-just = 'C'.
      WHEN 'EBELN'.     "구매오더
        _fcat TEXT-f22.
        <fs_s_fct>-just = 'C'.
      WHEN 'EBELP'.    "항번
        _fcat TEXT-f13.
        <fs_s_fct>-just = 'C'.
      WHEN 'XRECH'.     "반품정산대상
        _fcat TEXT-fa0.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'MJAHR'.    "입고연도
        _fcat TEXT-f56.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'SPMON	'.    "입고연월
        _fcat TEXT-f24.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'BUDAT'.        "전기일
        _fcat TEXT-f12.
        <fs_s_fct>-just = 'C'.
      WHEN 'MBLNR'.        "자재문서
        _fcat TEXT-f23.
        <fs_s_fct>-just = 'C'.
      WHEN 'ZEILE'.     "항번
        _fcat TEXT-f13.
        <fs_s_fct>-just = 'C'.
      WHEN 'MATNR'.        "자재코드
        _fcat TEXT-f20.
        <fs_s_fct>-just = 'C'.
      WHEN 'TXZ01'.        "자재명
        _fcat TEXT-f21.
        <fs_s_fct>-just = 'C'.
        <fs_s_fct>-emphasize = 'C210'.
      WHEN 'COLOR	'.    "색상
        _fcat TEXT-f57.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'LENGTH'.    "조장
        _fcat TEXT-f59.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'LENUNIT'.    "단위
        _fcat TEXT-f54.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'PSTYP'.    "품목범주
        _fcat TEXT-f60.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'MENGE'.        "입고수량
        _fcat TEXT-f27.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C300'.
      WHEN 'MEINS'.        "입고단위
        _fcat TEXT-f28.
        <fs_s_fct>-just = 'C'.
      WHEN 'MENGE_IV'.        "정산완료수량
        _fcat TEXT-f25.
        <fs_s_fct>-qfieldname = 'MEINS'.
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C300'.
      WHEN 'BSTME_IV'.        "정산단위
        _fcat TEXT-f26.
        <fs_s_fct>-just = 'C'.
      WHEN 'IV_QTY'.        "정산대상수량
        _fcat TEXT-f36.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-qfieldname = 'IV_UNIT'.
        <fs_s_fct>-just = 'R'.
      WHEN 'BPUMN'.        "정산단위
        _fcat TEXT-f98.
        <fs_s_fct>-just = 'C'.
      WHEN 'IV_OQTY'.        "정산단위 대상 수량
        _fcat TEXT-f97.
        <fs_s_fct>-qfieldname = 'IV_UNIT'.
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C700'.

      WHEN 'IV_UNIT'.        "정산단위
        _fcat TEXT-f26.
        <fs_s_fct>-just = 'C'.
      WHEN 'NETPR'.        "구매오더단가
        _fcat TEXT-f31.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C300'.
      WHEN 'PEINH'.        "PER
        _fcat TEXT-f32.
        <fs_s_fct>-just = 'C'.
      WHEN 'ETIV_PRICE'.        "정산유효단가
        _fcat TEXT-f41.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-just = 'R'.
      WHEN 'ETIV_PEINH'.        "PER
        _fcat TEXT-f32.
        <fs_s_fct>-just = 'C'.
      WHEN 'ETIV_MEINS'.        "단가단위
        _fcat TEXT-f40.
        <fs_s_fct>-just = 'C'.
      WHEN 'MWSKZ'.        "TAX코드
        _fcat TEXT-f52.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-f4availabl = gc_x.
*        <FS_S_FCT>-REF_TABLE = 'T007A'.
*        <FS_S_FCT>-REF_FIELD  = 'MWSKZ'.
        <fs_s_fct>-just = 'C'.
      WHEN 'RATE'.        "세율
        _fcat TEXT-f43.
        <fs_s_fct>-just = 'R'.
      WHEN 'TARGET_PRICE'.     "정산대상금액
        _fcat TEXT-f45.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-just = 'R'.
      WHEN 'TAXPRICE'.       "정산대상TAX
        _fcat TEXT-f53.
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-just = 'R'.
      WHEN 'WAERS'.        "전표통화
        _fcat TEXT-f63.
        <fs_s_fct>-just = 'C'.
      WHEN 'HSWAE'.       "현지통화
        _fcat TEXT-f64.
        <fs_s_fct>-just = 'C'.
      WHEN 'DMBTR'.        "입고금액(현지통화)
        _fcat TEXT-f66.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C300'.
      WHEN 'WRBTR'.        "입고금액(전표통화)
        _fcat TEXT-f65.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C300'.
      WHEN 'WRBTR_IV'.        "송장처리완료금액
        _fcat TEXT-f67.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C700'.
      WHEN 'WAERS_IV'.        "송장처리완료통화
        _fcat TEXT-f71.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-just = 'C'.
      WHEN 'MEPRF'.   "가격결정일제어
        _fcat TEXT-f70.
        <fs_s_fct>-just = 'C'.
      WHEN 'CPUDT	'.   "입고입력일
        _fcat TEXT-f90.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'CPUTM	'.   "입고입력시간
        _fcat TEXT-f91.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'EINDT'.   "납품요청일
        _fcat TEXT-f76.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'WEBRE'.   "GR기준IV
        _fcat TEXT-f92.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'PRDAT'.   "가격결정일
        _fcat TEXT-f93.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'BEDAT'.   "구매오더증빙일
        _fcat TEXT-f94.
        <fs_s_fct>-no_out = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'VBELN'.        "판매오더
        _fcat TEXT-fa3.
        <fs_s_fct>-just = 'C'.
      WHEN 'VBELP'.        "항번
        _fcat TEXT-fa4.
        <fs_s_fct>-just = 'C'.
      WHEN 'MESSAGE'.   "메시지
        _fcat TEXT-f69.
        <fs_s_fct>-just = 'C'.
      WHEN OTHERS.
        <fs_s_fct>-no_out = gc_x.

    ENDCASE.

    APPEND <fs_s_fct> TO gt_fcat_it.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM ADJUST_FLDCATS_TAX
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM adjust_fldcats_tax  TABLES pt_fcat TYPE lvc_t_fcat .

  DEFINE _fcat.
    <fs_s_fct>-scrtext_s  =
    <fs_s_fct>-scrtext_m  =
    <fs_s_fct>-scrtext_l  =
    <fs_s_fct>-coltext    =
    <fs_s_fct>-reptext    = &1.
  END-OF-DEFINITION.

  DATA lv_col TYPE i.
  CLEAR : gt_fcat_tax[].

  LOOP AT pt_fcat ASSIGNING FIELD-SYMBOL(<fs_s_fct>).
    CLEAR : <fs_s_fct>-col_pos.

    CASE <fs_s_fct>-fieldname.
      WHEN 'CHECK'.
        _fcat TEXT-f35. "선택
        <fs_s_fct>-edit = gc_x.
        <fs_s_fct>-checkbox = gc_x.
        <fs_s_fct>-just = 'C'.
      WHEN 'ISSUE_DATE'. "
        _fcat '작성일자'.
        <fs_s_fct>-just = 'C'.
      WHEN 'ISSUE_DT'.
        _fcat '발행일자'.
        <fs_s_fct>-just = 'C'.
      WHEN 'SU_ID'.  "
        _fcat '사업자번호'.
        <fs_s_fct>-just = 'C'.
      WHEN 'LIFNR'.
        _fcat '업체코드'.
        <fs_s_fct>-just = 'C'.
      WHEN 'NAME1'. "업체명
        _fcat TEXT-f17.
        <fs_s_fct>-just = 'C'.
      WHEN 'INV_SEQ'.
        _fcat '일련번호'.
        <fs_s_fct>-just = 'C'.
      WHEN 'CHARGETOTAL'.  "
        _fcat '공급가액'.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C300'.
      WHEN 'TAXTOTAL'.
        _fcat '세액'.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C500'.
      WHEN 'GRANDTOTAL'.  "
        _fcat '합계금액'.
        <fs_s_fct>-cfieldname = 'WAERS'.
        <fs_s_fct>-just = 'R'.
        <fs_s_fct>-emphasize = 'C700'.
      WHEN 'WAERS'.  "통화
        _fcat TEXT-f34.
        <fs_s_fct>-just = 'C'.
      WHEN OTHERS.
        <fs_s_fct>-no_out = gc_x.
    ENDCASE.

    APPEND <fs_s_fct> TO gt_fcat_tax.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_ALV_LAYOUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_alv_layout USING pv_gb
                                                 pcl_grid  TYPE REF TO cl_gui_alv_grid.

  DATA lv_stt TYPE lvc_title.

  CASE pcl_grid.
    WHEN gcl_grid_hd.                                    "송장처리대상금액  /  헤더DATA
      lv_stt = COND #( WHEN pv_gb = 'INV' THEN TEXT-t07 ELSE TEXT-t05 ).

      CLEAR gs_layout.
      gs_layout = VALUE #(
                      no_rowmark = gc_x
*                       NO_ROWINS  = GC_X
                      zebra  = gc_x
                      sel_mode   = gc_d"GC_A
                      cwidth_opt  = gc_a
                      smalltitle = gc_x
                      grid_title  = lv_stt
                      stylefname =  'STYLE'
                      ctab_fname = 'F_COL'
                      ).

    WHEN gcl_grid_it.                                          " 입고 내역  /품목 DATA
      lv_stt = COND #( WHEN pv_gb = 'INV' THEN TEXT-t08 ELSE TEXT-t06 ).

      CLEAR gs_layoit.
      gs_layoit = VALUE #(
*                      NO_ROWMARK = GC_X
*                       NO_ROWINS  = ZGTFI_X
                      zebra  = gc_x
                      sel_mode   = gc_d "GC_A
                      cwidth_opt  = gc_a"GC_A
                      smalltitle = gc_x
                      grid_title  = lv_stt
                      stylefname =  'STYLE'
                      ctab_fname = 'F_COL'
                      ).

    WHEN gcl_grid_tax.
      CLEAR gs_layout.
      gs_layout = VALUE #(
                      no_rowmark = gc_x
                      no_rowins  = gc_x
                      zebra  = gc_x
                      sel_mode   = gc_a
                      cwidth_opt  = gc_a
                      ctab_fname = 'F_COL'
*                      STYLEFNAME =  'STYLE'
                      ).

    WHEN OTHERS.
  ENDCASE.

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
*& FORM SET_EVENT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM set_event  CHANGING po_event TYPE REF TO lcl_evt_receiver
                                               pcl_grid  TYPE REF TO cl_gui_alv_grid.

  pcl_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).
  pcl_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).

  CASE pcl_grid.
    WHEN gcl_grid_hd.
      PERFORM set_cell_style USING 'HD'.
    WHEN gcl_grid_it.
      PERFORM set_cell_style USING 'IT'.
    WHEN OTHERS.
  ENDCASE.

*  DATA: LT_F4 TYPE LVC_T_F4,
*            LS_F4 TYPE LVC_S_F4.
*
*  IF PCL_GRID NE GCL_GRID_TAX.
*    LS_F4-FIELDNAME  = 'MWSKZ'. " 세금코드
*    LS_F4-REGISTER     = 'X'.
*    LS_F4-GETBEFORE  = 'X'.
*    LS_F4-CHNGEAFTER = 'X'.
*    APPEND LS_F4 TO LT_F4.
*
*    IF P_DIS = GC_X.
*      LS_F4-FIELDNAME  = 'SGTXT'. " 세금계산서일련번호
*      LS_F4-REGISTER     = 'X'.
*      LS_F4-GETBEFORE  = 'X'.
*      LS_F4-CHNGEAFTER = 'X'.
*      APPEND LS_F4 TO LT_F4.
*    ENDIF.
*  ENDIF.
*
*  CALL METHOD PCL_GRID->REGISTER_F4_FOR_FIELDS
*    EXPORTING
*      IT_F4 = LT_F4.

  CREATE OBJECT po_event.

  IF pcl_grid = gcl_grid_tax.
    SET HANDLER po_event->handle_data_changed FOR pcl_grid.
  ELSE.
    SET HANDLER :
     po_event->handle_data_changed                 FOR pcl_grid,
     po_event->handle_data_changed_finished  FOR pcl_grid,
     po_event->handle_hotspot_click                FOR pcl_grid,
     po_event->handle_toolbar                           FOR pcl_grid,
     po_event->handle_user_command               FOR pcl_grid,
     po_event->handle_on_f4                               FOR pcl_grid.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM display_alv TABLES pt_list pt_fcat
                                  USING pcl_grid TYPE REF TO cl_gui_alv_grid
                                            ps_layout TYPE lvc_s_layo.

  DATA(ls_variant) = VALUE disvariant( report  = sy-cprog
                                             handle  =
                                             COND #( WHEN p_inv = gc_x AND pcl_grid = gcl_grid_hd
                                                            THEN '0001'
                                                            WHEN p_inv = gc_x AND pcl_grid = gcl_grid_it
                                                            THEN '0002'
                                                            WHEN p_dis = gc_x AND pcl_grid = gcl_grid_hd
                                                            THEN '0003'
                                                            WHEN p_dis = gc_x AND pcl_grid = gcl_grid_it
                                                            THEN '0004' ) ).
*  GS_VARIANT-REPORT = SY-REPID.

  " 4. F4 대상 필드 등록
  DATA: lt_f4 TYPE lvc_t_f4,
        ls_f4 TYPE lvc_s_f4.

  ls_f4-fieldname = 'MWSKZ'.
  ls_f4-register   = 'X'.
  APPEND ls_f4 TO lt_f4.

  ls_f4-fieldname = 'SGTXT'.
  ls_f4-register   = 'X'.
  APPEND ls_f4 TO lt_f4.

  CALL METHOD pcl_grid->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4.

  CALL METHOD pcl_grid->set_table_for_first_display
    EXPORTING
      is_layout            = ps_layout
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
*& FORM DISPLAY_ALV_400
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM display_alv_400 .

  DATA(ls_varint) = VALUE disvariant( report  = sy-cprog
                                           handle  = '0005' ).

  CALL METHOD gcl_grid_tax->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      it_toolbar_excluding = gt_exclud[]
      is_variant           = ls_varint
      i_save               = zgtfi_a
    CHANGING
      it_outtab            = gt_tax[]
      it_fieldcatalog      = gt_fcat_tax[]
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

  IF gcl_grid_hd IS BOUND.
    gcl_grid_hd->free( ).
    gcl_grid_it->free( ).
    CLEAR : gcl_grid_hd, gcl_grid_it.
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

  CLEAR : s_month[]. "생성일
  s_month[] = VALUE #( ( sign   = gc_i
                                        option = gc_bt
                                        low    = sy-datlo(6) - 2
                                        high   = sy-datlo(6) ) ).

  s_usnam[] = VALUE #( ( sign = gc_i
                                       option = gc_eq
                                       low = sy-uname
                                       high = '' ) ).


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
    IF sy-subrc EQ 0. p_werks = ls_values-von.   ENDIF.

  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM INPUT_VALIDATION
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM input_validation.

  CLEAR : gt_list, gv_err.

*  IF P_CRE NE GC_X AND S_ERDAT[] IS INITIAL AND S_EINDT[] IS INITIAL.
*    MESSAGE S000 WITH TEXT-M13 DISPLAY LIKE GC_E.
*    GV_ERR = GC_X. STOP. "생성일과 납품예정일 중 최소 하나는 입력 해야 합니다.
*  ENDIF.

*  IF P_PR = GC_X AND P_VOL IS INITIAL AND P_PRD IS INITIAL.
*    MESSAGE S000 WITH TEXT-M16 DISPLAY LIKE GC_E.
*    GV_ERR = GC_X. STOP.
*    "청구량 정보 조회와 구매요청 정보 조회 중 최소 하나는 체크해야 합니다.
*  ENDIF.

  IF  p_werks IS NOT INITIAL.
*    LOOP AT S_WERKS INTO DATA(LS_WERKS).

    SELECT SINGLE 1
     FROM t001w
     WHERE werks EQ @p_werks
      INTO @DATA(lv_exst).

    IF sy-subrc <> 0.
      MESSAGE s000 WITH TEXT-m01 DISPLAY LIKE gc_e.
      gv_err = gc_x. STOP. "유효하지 않은 플랜트 입니다.
    ENDIF.

*    ENDLOOP.
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

*  IF S_VBELN[] IS NOT INITIAL.
*    LOOP AT S_VBELN INTO DATA(LS_VBELN).
*
*      SELECT SINGLE 1
*      FROM VBAK
*      WHERE VBELN EQ @LS_VBELN-LOW
*      INTO @LV_EXST.
*
*      IF SY-SUBRC <> 0.
*        MESSAGE S000 WITH TEXT-M11 DISPLAY LIKE GC_E.
*        GV_ERR = GC_X. STOP. "유효하지 않은 판매오더 입니다.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM check_auth.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD p_bukrs.

  CHECK sy-subrc <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE e172 WITH p_bukrs. "회사코드 [&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'EKORG' FIELD p_ekorg.

  CHECK sy-subrc <> 0.

  SET CURSOR FIELD 'P_EKORG'.
  MESSAGE e170 WITH p_ekorg. "구매조직 [&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD p_werks.

  CHECK sy-subrc <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE e106 WITH p_werks. "플랜트 [&] 작업권한을 확인하세요.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM selection_screen_output .

  LOOP AT SCREEN.

    IF screen-name = '%B004017_BLOCK_1000'." 입고내역조회옵션 프레임(블럭)제어
      screen-active = COND #( WHEN p_dis = gc_x THEN 0 ELSE 1 ).
    ENDIF.

    IF screen-group1 = 'DIS'.
      screen-active = COND #( WHEN p_dis = gc_x THEN 0 ELSE 1 ).
    ENDIF.

    IF screen-group1 = 'EXD'.
      screen-active = COND #( WHEN p_dis = gc_x THEN 1 ELSE 0 ).
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM  get_data .

  CLEAR : gv_lifnr, gv_waers, gv_twaers, gv_xwaers, gv_exrate,
               gv_target_price, gv_taxprice, gv_wrbtr, gv_err.

  CLEAR : gt_list, gt_item, gt_item_base,
               gt_disp, gt_disp_it, gt_disp_base.

  CASE gc_x.
*송장처리
    WHEN p_inv.
      IF p_lif = gc_x.   "업체 별 조회
        SELECT FROM zgtmm_cv_get_target_iv_h_5020
        FIELDS *
        WHERE bukrs = @p_bukrs
             AND ekorg = @p_ekorg
             AND werks = @p_werks
             AND lifnr IN @s_lifnr
             AND spmon IN @s_month
        INTO CORRESPONDING FIELDS OF TABLE @gt_list.
        SORT gt_list BY bukrs ekorg lifnr spmon werks ASCENDING.

        IF gt_list[] IS INITIAL.
          gv_err = gc_x."조회 조건에 일치하는 정보가 없습니다.
          MESSAGE s000 WITH TEXT-e01. EXIT.
        ELSE.
          SELECT FROM zgtmm_cv_get_target_iv
          FIELDS *
          FOR ALL ENTRIES IN @gt_list
          WHERE lifnr = @gt_list-lifnr
             AND bukrs = @gt_list-bukrs
             AND ekorg = @gt_list-ekorg
             AND werks = @gt_list-werks
             AND spmon = @gt_list-spmon
             AND mwskz = @gt_list-mwskz
             AND iv_complete IS INITIAL
          INTO CORRESPONDING FIELDS OF TABLE @gt_item_base.
          SORT gt_item_base BY lifnr bukrs ekorg werks spmon xrech mwskz.

        ENDIF.

      ELSEIF p_ekg = gc_x. "구매그룹 별 조회
        SELECT FROM zgtmm_cv_get_target_iv_h2_5020
        FIELDS *
        WHERE bukrs = @p_bukrs
             AND ekorg = @p_ekorg
             AND werks = @p_werks
             AND lifnr IN @s_lifnr
             AND ekgrp IN @s_ekgrp
             AND spmon IN @s_month
        INTO CORRESPONDING FIELDS OF TABLE @gt_list.
        SORT gt_list BY bukrs ekorg ekgrp lifnr spmon werks ASCENDING.

        IF gt_list[] IS INITIAL.
          gv_err = gc_x."조회 조건에 일치하는 정보가 없습니다.
          MESSAGE s000 WITH TEXT-e01. EXIT.
        ELSE.
          SELECT FROM zgtmm_cv_get_target_iv
          FIELDS *
          FOR ALL ENTRIES IN @gt_list
          WHERE lifnr = @gt_list-lifnr
             AND bukrs = @gt_list-bukrs
             AND ekorg = @gt_list-ekorg
             AND werks = @gt_list-werks
             AND ekgrp = @gt_list-ekgrp
             AND spmon = @gt_list-spmon
             AND mwskz = @gt_list-mwskz
          INTO CORRESPONDING FIELDS OF TABLE @gt_item_base.
          SORT gt_item_base BY lifnr bukrs ekorg werks ekgrp spmon xrech mwskz.
        ENDIF.
      ENDIF.

*>S.2026.09.03_임시조치(TEMP): PO+품목 단위로 입고수량(MENGE) 합계와
* 정산완료수량(MENGE_IV) 합계가 같으면(=완납) 후보에서 제외.
      TYPES: BEGIN OF ty_sum,
               ebeln    TYPE ebeln,
               ebelp    TYPE ebelp,
               menge    TYPE zgtmm_cv_get_target_iv-menge,     "입고수량
               menge_iv TYPE zgtmm_cv_get_target_iv-menge_iv,  "정산완료수량
             END OF ty_sum.

      DATA: lt_sum TYPE TABLE OF ty_sum,
            ls_sum TYPE ty_sum.

      LOOP AT gt_item_base ASSIGNING FIELD-SYMBOL(<fs_sum>).
        CLEAR ls_sum.
        ls_sum-ebeln    = <fs_sum>-ebeln.
        ls_sum-ebelp    = <fs_sum>-ebelp.
        ls_sum-menge    = <fs_sum>-menge.
        ls_sum-menge_iv = <fs_sum>-menge_iv.
        COLLECT ls_sum INTO lt_sum.
      ENDLOOP.

      LOOP AT lt_sum INTO ls_sum.
        CHECK ls_sum-menge = ls_sum-menge_iv.   " 입고수량 = 정산완료수량 → 완납
        DELETE gt_item_base WHERE ebeln = ls_sum-ebeln
                               AND ebelp = ls_sum-ebelp.
      ENDLOOP.
*<E.2026.09.03_TEMP

*처리 결과 조회 및 지급 요청
    WHEN p_dis.
      IF p_exd = gc_x. "지급요청 건 제외
        SELECT FROM zgtmm_cv_get_ap_clearing
        FIELDS *
        WHERE bukrs = @p_bukrs
           AND werks = @p_werks
           AND lifnr IN @s_lifnr
           AND usnam IN @s_usnam
           AND spmon IN @s_month
           AND reqpay IS INITIAL
        INTO CORRESPONDING FIELDS OF TABLE @gt_disp.

      ELSE.
        SELECT FROM zgtmm_cv_get_ap_clearing
        FIELDS *
        WHERE bukrs = @p_bukrs
           AND werks = @p_werks
           AND lifnr IN @s_lifnr
           AND usnam IN @s_usnam
           AND spmon IN @s_month
        INTO CORRESPONDING FIELDS OF TABLE @gt_disp.
      ENDIF.

      SORT gt_disp BY bukrs werks lifnr ASCENDING.

      IF gt_disp[] IS INITIAL.
        gv_err = gc_x."조회 조건에 일치하는 정보가 없습니다.
        MESSAGE s000 WITH TEXT-e01. EXIT.
      ELSE.
        LOOP AT gt_disp ASSIGNING FIELD-SYMBOL(<fs>).
          IF <fs>-ap_status = gc_t OR <fs>-ap_status = gc_p.
            <fs>-req   = icon_mail.
          ELSEIF <fs>-ap_status = gc_c.
            <fs>-req   = icon_led_green.
          ELSE.
            CLEAR  <fs>-req.
          ENDIF.
        ENDLOOP.


        SELECT FROM zgtmm_cv_get_ap_rseg
        FIELDS *
        FOR ALL ENTRIES IN @gt_disp
        WHERE bukrs = @gt_disp-bukrs
           AND gjahr = @gt_disp-gjahr
           AND belnr = @gt_disp-belnr
        INTO CORRESPONDING FIELDS OF TABLE @gt_disp_base.
        SORT gt_disp_base BY bukrs gjahr belnr.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.



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
*  CHECK P_LIF = GC_X. "업체 별 조회 인 경우에만.
  CHECK gt_item[] IS NOT INITIAL.

  DATA(lt_list) = gt_list[].

  SORT lt_list BY check lifnr bukrs ekorg werks spmon.
  CLEAR : gv_target_price, gv_taxprice, gv_wrbtr, gv_xrech.

  IF  line_exists( gt_item[ check = gc_x ] ).
*총 공급가액,세액,합계금액 변경 반영_상단 스크린 필드.
    LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fsi>).

      READ TABLE lt_list TRANSPORTING NO FIELDS
      WITH KEY check = gc_x
                   lifnr = <fsi>-lifnr
                   bukrs = <fsi>-bukrs
                   ekorg = <fsi>-ekorg
                   werks = <fsi>-werks
                   spmon = <fsi>-spmon
                   xrech = <fsi>-xrech BINARY SEARCH.

      IF sy-subrc = 0 AND <fsi>-check = gc_x.
        gv_target_price = gv_target_price + <fsi>-target_price.
        gv_taxprice = gv_taxprice + <fsi>-taxprice.
      ENDIF.

    ENDLOOP.
*총 합계금액 = 총 공급가액 + 총 세액
    gv_wrbtr = gv_target_price + gv_taxprice.

    READ TABLE lt_list INTO DATA(ls2) WITH KEY check = gc_x BINARY SEARCH.
    gv_xrech = COND #( WHEN ls2 IS INITIAL THEN '' ELSE ls2-xrech ).

  ELSE.
*ITEM 체크된 데이터 없으면 스크린 상단 필드 업데이트 위해 HEADER 추가 체크
    READ TABLE lt_list INTO DATA(ls) WITH KEY check = gc_x BINARY SEARCH.

    IF sy-subrc = 0.
      gv_lifnr     = ls-lifnr.
      gv_exrate = ls-exrate.
    ELSE.
      CLEAR : gv_lifnr, gv_lifnr_n, gv_exrate,
                   gv_waers, gv_twaers, gv_xwaers, gv_xrech.
    ENDIF.

  ENDIF.

*합계필드 화면 표시용 처리.(단위참조)
  WRITE gv_wrbtr TO gv_wrbtr_disp CURRENCY gv_waers LEFT-JUSTIFIED.
  WRITE gv_target_price TO gv_tprice_disp CURRENCY gv_waers LEFT-JUSTIFIED.
  WRITE gv_taxprice TO gv_xprice_disp CURRENCY gv_waers LEFT-JUSTIFIED.

  PERFORM refresh_table USING gcl_grid_hd space.
  PERFORM refresh_table USING gcl_grid_it space.

*상단 스크린 필드 업데이트_강제 PBO 실행
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


  gcl_grid_hd->set_ready_for_input( 1 ). "입력가능
  gcl_grid_it->set_ready_for_input( 1 ). "입력가능

  CASE pv_gb.
    WHEN 'HD'.
*HEADER
      IF p_inv = gc_x.
        LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<ls_list>).
          CLEAR : <ls_list>-style[].

          _set_style : gc_e 'CHECK' <ls_list>-style. "ENABLED

          IF <ls_list>-etiv_waers = gc_krw.
            _set_style gc_d 'EXRATE' <ls_list>-style."DISABLED
          ELSE.
            _set_style gc_e 'EXRATE' <ls_list>-style."ENABLED
          ENDIF.

        ENDLOOP.
      ENDIF.

      IF p_dis = gc_x.
        LOOP AT gt_disp ASSIGNING FIELD-SYMBOL(<ls_disp>).
          CLEAR : <ls_disp>-style[].

          _set_style : gc_e 'CHECK' <ls_disp>-style. "ENABLED
**세금계산서일련번호
          IF <ls_disp>-sgtxt IS INITIAL.
            _set_style gc_e 'SGTXT' <ls_disp>-style."ENABLED
          ELSE.
            _set_style gc_d 'SGTXT' <ls_disp>-style."DISABLED
          ENDIF.
        ENDLOOP.
      ENDIF.


    WHEN 'IT'.
**ITEM
      LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fs>).
        CLEAR : <fs>-style[].

        _set_style : gc_e 'CHECK' <fs>-style, "ENABLED
                              gc_e 'ETIV_PRICE' <fs>-style, "ENABLED
                              gc_e 'TARGET_PRICE' <fs>-style,
                              gc_e 'IV_QTY' <fs>-style,
                              gc_e 'MWSKZ' <fs>-style.
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
FORM set_alv_fieldcat USING pv_gb.

  DATA :
    lr_tabdescr TYPE REF TO cl_abap_structdescr,
    lt_dfies    TYPE ddfields,
    ls_dfies    TYPE dfies,
    lt_fcat     TYPE lvc_t_fcat,
    ls_fcat     TYPE lvc_s_fcat.

  DATA : gr_dref  TYPE REF TO data.
  CLEAR gr_dref.

  CASE pv_gb.
    WHEN 'IH'. "P_INV AND HEADER  송장처리
      CREATE DATA gr_dref LIKE gs_list.
    WHEN 'DH'. "P_DIS AND HEADER  현황조회/지급요청
      CREATE DATA gr_dref LIKE gs_disp.
    WHEN 'IB'.  "P_INV AND ITEM
      CREATE DATA gr_dref LIKE gs_item.
    WHEN 'DB'. "P_DIS AND ITEM
      CREATE DATA gr_dref LIKE gs_disp_it.
    WHEN OTHERS.
      CREATE DATA gr_dref LIKE gs_tax.
  ENDCASE.

  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( gr_dref ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ) .

  REFRESH : lt_fcat.

  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR : ls_fcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fcat.
    APPEND ls_fcat TO lt_fcat.
  ENDLOOP.

*  " 필드 카탈로그 변경사항 적용
  CASE pv_gb.
    WHEN 'IH'. "P_INV AND HEADER  송장처리
      PERFORM adjust_fldcats TABLES lt_fcat.
    WHEN 'DH'. "P_DIS AND HEADER  현황조회/지급요청
      PERFORM adjust_fldcats_disp TABLES lt_fcat USING 'HD'.
    WHEN 'IB'.  "P_INV AND ITEM
      PERFORM adjust_fldcats_item TABLES lt_fcat.
    WHEN 'DB'. "P_DIS AND ITEM
      PERFORM adjust_fldcats_disp TABLES lt_fcat  USING 'IT'.
    WHEN OTHERS. "세금계산서 조회 팝업 ALV
      PERFORM adjust_fldcats_tax TABLES lt_fcat.
  ENDCASE.

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

    WHEN gcl_grid_hd.
      IF p_dis = gc_x. "현황조회->HEAD GRID에 필요.
        _set_tbar 3 '    ' '              ' '    '.
*        _SET_TBAR 0 'REFRESH' '' 'REFRESH'(B01).
        _set_tbar 0 'ASEL'  '' '전체선택'(b02).
        _set_tbar 0 'DSEL' '' '전체선택해제'(b03).
      ENDIF.

    WHEN gcl_grid_it.
      IF p_inv = gc_x . "송장처리->ITEM GRID에 필요.
        _set_tbar 3 '    ' '              ' '    '.
*        _SET_TBAR 0 'ASEL'  '' '전체선택'(B02).
*        _SET_TBAR 0 'DSEL' '' '전체선택해제'(B03).
        _set_tbar 0 'CHOICE'  '' '선택'(b13).
        _set_tbar 0 'DCHOICE' '' '선택해제'(b14).
        _set_tbar 0 'TAX' '' 'TAX조정'(b15).
      ENDIF.

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
*    WHEN 'REFRESH'.
*      PERFORM GET_DATA.

    WHEN 'ASEL'.
      PERFORM select_row_adsel USING gc_a.

    WHEN 'DSEL' .
      PERFORM select_row_adsel USING gc_d.

    WHEN 'CHOICE'. "선택
      PERFORM select_row_choice USING gc_a.

    WHEN 'DCHOICE'. "선택해제
      PERFORM select_row_choice USING gc_d.

    WHEN 'TAX'. "TAX조정
      PERFORM set_tax_adjust.

    WHEN OTHERS.
  ENDCASE.

  PERFORM refresh_table USING gcl_grid_hd space.
  PERFORM refresh_table USING gcl_grid_it space.

*상단 스크린 필드 업데이트_강제 PBO 실행
  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = 'ENTER'.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DATA_CHANGED
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM data_changed  USING  po_data_changed
                                     TYPE REF TO cl_alv_changed_data_protocol
                                               po_onf4_after
                                                po_sender.

  CASE po_sender.

    WHEN gcl_grid_hd.
      PERFORM data_changed_1 USING po_data_changed.

    WHEN gcl_grid_it.
      PERFORM data_changed_2 USING po_data_changed.

    WHEN gcl_grid_tax.
      PERFORM data_changed_3 USING po_data_changed.

    WHEN OTHERS.
      EXIT.
  ENDCASE.

  PERFORM refresh_table USING gcl_grid_hd space.
  PERFORM refresh_table USING gcl_grid_it space.

  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = 'ENTER'.

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

  DATA : lt_item LIKE TABLE OF gs_item.

  CLEAR : gv_err.
  IF gt_disp_it[] IS NOT INITIAL.
    SORT gt_disp_it BY bukrs gjahr belnr.
  ENDIF.

  LOOP AT po_data_changed->mt_good_cells INTO DATA(ls_mod_cells).
    IF sy-tabix = 1.
      DATA(lv_tabix) = sy-tabix.
    ENDIF.

    IF p_inv = gc_x. "송장처리
      READ TABLE gt_list  INTO DATA(ls_list) INDEX ls_mod_cells-row_id.

    ELSEIF p_dis = gc_x. "현황조회
      READ TABLE gt_disp  INTO DATA(ls_disp) INDEX ls_mod_cells-row_id.
    ENDIF.

    CHECK sy-subrc EQ 0.

    CASE ls_mod_cells-fieldname.

      WHEN 'CHECK'. "선택
        IF p_inv = gc_x.
          ls_list-check = ls_mod_cells-value.
        ELSEIF p_dis = gc_x.
          ls_disp-check = ls_mod_cells-value.
        ENDIF.

        PERFORM modify_cell USING po_data_changed 'CHECK'
                                              ls_mod_cells-value ls_mod_cells-row_id.

        IF ls_mod_cells-value IS INITIAL. "체크해제
          IF p_inv = gc_x AND p_lif = gc_x.
            DELETE gt_item WHERE lifnr = ls_list-lifnr AND bukrs = ls_list-bukrs
                                            AND ekorg = ls_list-ekorg AND werks = ls_list-werks
                                            AND spmon = ls_list-spmon.
          ENDIF.
          IF p_inv = gc_x AND p_ekg = gc_x.
            DELETE gt_item WHERE lifnr = ls_list-lifnr AND bukrs = ls_list-bukrs
                                           AND ekorg = ls_list-ekorg AND werks = ls_list-werks
                                           AND ekgrp = ls_list-ekgrp AND spmon = ls_list-spmon.
          ENDIF.
          IF p_dis = gc_x . "현황조회
            DELETE gt_disp_it WHERE bukrs = ls_disp-bukrs AND gjahr = ls_disp-gjahr
                                               AND belnr = ls_disp-belnr.
          ENDIF.

          IF gt_item[] IS INITIAL.
            CLEAR : gv_lifnr, gv_lifnr_n, gv_waers, gv_exrate, gv_target_price,
                         gv_tprice_disp, gv_taxprice, gv_xprice_disp, gv_wrbtr, gv_wrbtr_disp, gv_return, gv_tax.
            CLEAR : gv_taxno, gv_waers2, gv_target_price2, gv_date, gv_pdate,
                         gv_tprice_disp2, gv_taxprice2, gv_xprice_disp2, gv_wrbtr2, gv_wrbtr_disp2.
          ENDIF.

        ELSE.  "CHECK
          CASE gc_x.
            WHEN p_inv. "송장처리
*동일 업체, 통화코드, 환율인지 체크&헤더 스크린 필드 설정
              IF lv_tabix = 1 .
                gv_return  = COND #( WHEN gv_lifnr IS INITIAL THEN ls_list-xrech ELSE gv_return ).
                gv_lifnr = COND #( WHEN gv_lifnr IS INITIAL THEN ls_list-lifnr ELSE gv_lifnr ).
                gv_lifnr_n = COND #( WHEN gv_lifnr_n IS INITIAL THEN ls_list-lifnr_n ELSE gv_lifnr_n ).
                gv_waers  = COND #( WHEN gv_waers IS INITIAL THEN ls_list-etiv_waers ELSE gv_waers ).
                gv_twaers = gv_xwaers = gv_waers.
                gv_exrate = COND #( WHEN gv_exrate IS INITIAL THEN ls_list-exrate ELSE gv_exrate ).
                gv_tax  = COND #( WHEN gv_tax IS INITIAL THEN ls_list-mwskz ELSE gv_tax ).


                CLEAR lv_tabix.
              ENDIF.

              IF gv_lifnr = ls_list-lifnr AND gv_waers = ls_list-etiv_waers
                AND gv_exrate = ls_list-exrate AND gv_return = ls_list-xrech AND gv_tax = ls_list-mwskz.
                "통과
                gv_target_price = gv_target_price + ls_list-target_price.
                gv_taxprice = gv_taxprice + ls_list-taxprice.
                gv_wrbtr = gv_wrbtr + ls_list-wrbtr.
              ELSE.
                CLEAR ls_mod_cells-value.
                PERFORM modify_cell USING po_data_changed 'CHECK'
                                              ls_mod_cells-value ls_mod_cells-row_id.
                gv_err = gc_x."에러
                MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE gc_e.  EXIT.
*            "정산은 동일 업체, 통화코드, 환율 별로 가능합니다.
              ENDIF.

              CHECK gv_err IS INITIAL.
*LIFNR,BUKRS,EKORG,WERKS(EKGRP)SPMON 기준으로 ITEM구성
              IF p_lif = gc_x. "업체기준조회

                READ TABLE gt_item_base TRANSPORTING NO FIELDS
                WITH KEY lifnr = ls_list-lifnr
                               bukrs = ls_list-bukrs
                               ekorg = ls_list-ekorg
                               werks = ls_list-werks
                               spmon = ls_list-spmon
                               xrech = ls_list-xrech
                               mwskz = ls_list-mwskz  BINARY SEARCH.
                IF sy-subrc = 0.
                  lv_tabix = sy-tabix.
                  LOOP AT gt_item_base INTO DATA(ls_it) FROM lv_tabix.

                    IF ls_list-lifnr = ls_it-lifnr AND ls_list-bukrs = ls_it-bukrs
                      AND ls_list-ekorg = ls_it-ekorg AND ls_list-werks = ls_it-werks
                      AND ls_list-spmon = ls_it-spmon AND ls_list-xrech = ls_it-xrech AND ls_list-mwskz = ls_it-mwskz.

                      ls_it-check = gc_x.
                      APPEND ls_it TO gt_item.  CLEAR ls_it.

*                    ELSE.
*                      EXIT.
                    ENDIF.
                  ENDLOOP.
                ENDIF.
              ENDIF.

              IF p_ekg = gc_x. "구매그룹 별 조회
                READ TABLE gt_item_base TRANSPORTING NO FIELDS
                WITH KEY lifnr = ls_list-lifnr
                               bukrs = ls_list-bukrs
                               ekorg = ls_list-ekorg
                               werks = ls_list-werks
                               ekgrp = ls_list-ekgrp
                               spmon = ls_list-spmon
                               xrech = ls_list-xrech
                               mwskz = ls_list-mwskz  BINARY SEARCH.
                IF sy-subrc = 0.
                  CLEAR : lv_tabix, ls_it.
                  lv_tabix = sy-tabix.

                  LOOP AT gt_item_base INTO ls_it FROM lv_tabix.

                    IF ls_list-lifnr = ls_it-lifnr AND ls_list-bukrs = ls_it-bukrs AND
                     ls_list-ekorg = ls_it-ekorg AND ls_list-werks = ls_it-werks
                     AND ls_list-ekgrp = ls_it-ekgrp AND ls_list-spmon = ls_it-spmon AND ls_list-xrech = ls_it-xrech AND ls_list-mwskz = ls_it-mwskz.

                      ls_it-check = gc_x.
                      APPEND ls_it TO gt_item.  CLEAR ls_it.
*
*                    ELSE.
*                      EXIT.
                    ENDIF.
                  ENDLOOP.
                ENDIF.
              ENDIF.


            WHEN p_dis. "현황조회
              IF gt_disp_it[] IS NOT INITIAL.
                READ TABLE gt_disp_it TRANSPORTING NO FIELDS
                WITH KEY bukrs = ls_disp-bukrs
                               gjahr = ls_disp-gjahr
                               belnr = ls_disp-belnr
                               xrech = ls_disp-xrech BINARY SEARCH.
                IF sy-subrc NE 0.
                  LOOP AT gt_disp_base INTO DATA(ls_bs).
                    IF ls_bs-bukrs = ls_disp-bukrs AND ls_bs-gjahr = ls_disp-gjahr
                      AND ls_bs-belnr = ls_disp-belnr AND ls_bs-xrech = ls_disp-xrech.
                      APPEND ls_bs TO gt_disp_it. CLEAR ls_bs.
                    ENDIF.
                  ENDLOOP.
                ENDIF.

              ELSE.
                LOOP AT gt_disp_base INTO ls_bs.
                  IF ls_bs-bukrs = ls_disp-bukrs AND ls_bs-gjahr = ls_disp-gjahr
                      AND ls_bs-belnr = ls_disp-belnr .
                    APPEND ls_bs TO gt_disp_it. CLEAR ls_bs.
                  ENDIF.
                ENDLOOP.
              ENDIF.

            WHEN OTHERS.
          ENDCASE.
        ENDIF.

      WHEN 'EXRATE'. "환율
        PERFORM modify_cell USING po_data_changed 'EXRATE'
                                              ls_mod_cells-value ls_mod_cells-row_id.
        IF ls_list-check = gc_x.
          gv_exrate = ls_mod_cells-value.
        ENDIF.

      WHEN 'SGTXT'. "세금계산서일련번호

        IF ls_mod_cells-value IS INITIAL.
          CLEAR ls_disp-sgtxt.
        ELSE.
          SELECT SINGLE FROM zgtmm_cv_get_tax_invoice
          FIELDS inv_seq
          WHERE bukrs EQ @p_bukrs
               AND lifnr   EQ @ls_disp-lifnr
               AND inv_seq EQ @ls_mod_cells-value
               AND taxinv IS INITIAL
          INTO @DATA(lv_seq).

          IF sy-subrc = 0.
            PERFORM modify_cell USING po_data_changed 'SGTXT'
                            lv_seq ls_mod_cells-row_id.
          ENDIF.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

    IF p_inv = gc_x.
      MODIFY gt_list FROM ls_list INDEX ls_mod_cells-row_id.
      CLEAR ls_list.
    ENDIF.
    IF p_dis = gc_x.
      MODIFY gt_disp FROM ls_disp INDEX ls_mod_cells-row_id.
      CLEAR ls_disp.
    ENDIF.
  ENDLOOP.

*  GV_LIFNR = |{ GV_LIFNR ALPHA = OUT }|.

*  IF LV_ERR IS NOT INITIAL.
*    CALL METHOD PO_DATA_CHANGED->DISPLAY_PROTOCOL.
*  ENDIF.

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

  DATA : lv_err   TYPE char1.
  DATA :
    lv_tprice TYPE zgtmm_cv_get_target_iv-target_price,
    lv_xprice TYPE zgtmm_cv_get_target_iv-taxprice,
    lv_rate   TYPE zgtmm_cv_get_target_iv-rate,
    lv_mwskz  TYPE zgtmm_cv_get_target_iv-mwskz,
    lt_mwdat  LIKE TABLE OF rtax1u15,
    lv_wrbtr  TYPE bseg-wrbtr.

  LOOP AT po_data_changed->mt_good_cells INTO DATA(ls_mod_cells).

    READ TABLE gt_item  INTO DATA(ls_list) INDEX ls_mod_cells-row_id.
    CHECK sy-subrc EQ 0.

    CASE ls_mod_cells-fieldname.

      WHEN 'CHECK'.
        PERFORM modify_cell USING po_data_changed 'CHECK'
                                                        ls_mod_cells-value ls_mod_cells-row_id.

      WHEN 'IV_QTY'. "정산대상수량
        PERFORM modify_cell USING po_data_changed 'IV_QTY'
                                                        ls_mod_cells-value ls_mod_cells-row_id.
*-정산대상 수량 변경 시 자동변경(계산)_(정산대상수량/PER*정산유효단가)
        PERFORM calculate_price USING 'Q' CHANGING ls_list ls_mod_cells-value.
*-정산대상 금액 변경 시 TAX 자동 재계산_변경된 정산대상금액*세율
        PERFORM calculate_tax  CHANGING ls_list.


      WHEN 'ETIV_PRICE'. "정산유효단가
        PERFORM modify_cell USING po_data_changed 'ETIV_PRICE'
                                                        ls_mod_cells-value ls_mod_cells-row_id.
*-정산유효단가 변경 시 정산대상 금액 자동변경(계산)
        PERFORM calculate_price USING  'P' CHANGING ls_list ls_mod_cells-value.
*-정산대상 금액 변경 시 TAX 자동 재계산_변경된 정산대상금액*세율
        PERFORM calculate_tax  CHANGING ls_list.

      WHEN 'MWSKZ'. "세금코드
        SELECT SINGLE 1
          FROM t007a
          WHERE mwskz = @ls_mod_cells-value
          INTO @DATA(lv_exsit).

        IF sy-subrc = 0.
          PERFORM modify_cell USING po_data_changed 'MWSKZ'
                                                ls_mod_cells-value ls_mod_cells-row_id.
          ls_list-mwskz = ls_mod_cells-value.
*-세금코드 변경 시 세율 재조회
          CLEAR ls_list-rate.
          SELECT SINGLE FROM zgtmm_cv_get_tax_rate
          FIELDS rate
          WHERE mwskz = @ls_mod_cells-value INTO @ls_list-rate.
*-세율 재조회 후 정산대상TAX 재계산
          PERFORM calculate_tax  CHANGING ls_list.
        ELSE.
* 세금코드 맞지않거나, 빈 값 입력 시->세율 클리어.
          CLEAR ls_list-rate.
        ENDIF.

      WHEN 'TARGET_PRICE'. "정산대상금액
        PERFORM modify_cell USING po_data_changed 'TARGET_PRICE'
                                                        ls_mod_cells-value ls_mod_cells-row_id.
        ls_list-target_price = ls_mod_cells-value.
*-정산대상금액 변경 시 정산대상TAX 자동 재계산
        PERFORM calculate_tax  CHANGING ls_list.

      WHEN 'TAXPRICE'. "정산TAX금액
        PERFORM modify_cell USING po_data_changed 'TAXPRICE'
                                                        ls_mod_cells-value ls_mod_cells-row_id.
        ls_list-taxprice = ls_mod_cells-value.

      WHEN OTHERS.
    ENDCASE.

    MODIFY gt_item FROM ls_list INDEX ls_mod_cells-row_id.
  ENDLOOP.

*  IF LV_ERR IS NOT INITIAL.
*    CALL METHOD PO_DATA_CHANGED->DISPLAY_PROTOCOL.
*  ENDIF.

ENDFORM. " DATA_CHANGED_2
*&---------------------------------------------------------------------*
*&      FORM  DATA_CHANGED_3
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
*      -->P_PO_DATA_CHANGED  TEXT
*----------------------------------------------------------------------*
FORM data_changed_3 USING po_data_changed
                                       TYPE REF TO cl_alv_changed_data_protocol.

  DATA : lv_err   TYPE char1.

  LOOP AT po_data_changed->mt_good_cells INTO DATA(ls_mod_cells).

    CASE ls_mod_cells-fieldname.

      WHEN 'CHECK'.
        READ TABLE gt_tax  INTO DATA(ls_tax) INDEX ls_mod_cells-row_id.
        CHECK sy-subrc EQ 0.

        IF ls_mod_cells-value IS INITIAL.
        ELSE.
*기존 체크된 데이터 있는지 체크후 클리어.
          READ TABLE gt_tax ASSIGNING FIELD-SYMBOL(<chk>)
          WITH KEY check = gc_x.

          IF sy-subrc = 0.
            DATA(lv_tabix) = sy-tabix.
            CLEAR <chk>-check.
            MODIFY gt_tax FROM <chk> INDEX lv_tabix.
          ENDIF.
        ENDIF.

        ls_tax-check = ls_mod_cells-value.
        PERFORM modify_cell USING po_data_changed 'CHECK'
                                                        ls_mod_cells-value ls_mod_cells-row_id.

      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

ENDFORM.

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

  CHECK po_sender = gcl_grid .
  CHECK ps_row_no-rowtype IS INITIAL.

  CASE po_sender.

    WHEN gcl_grid_hd.
      IF p_inv = gc_x.

        READ TABLE gt_list INTO DATA(ls_list) INDEX ps_row_no-index.
        CHECK sy-subrc = 0.

*        IF PS_COLUMN-FIELDNAME = 'EBELN'.
*          CHECK LS_LIST-EBELN IS NOT INITIAL.
*
*          SET PARAMETER ID 'BES' FIELD LS_LIST-EBELN.
*          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
*
*        ELSEIF PS_COLUMN-FIELDNAME = 'BANFN'.
*          CHECK LS_LIST-BANFN IS NOT INITIAL.
*
*          SET PARAMETER ID 'BAN' FIELD LS_LIST-BANFN.
*          CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.
*
*        ELSEIF PS_COLUMN-FIELDNAME = 'BANFN_N'.
*          CHECK LS_LIST-BANFN_N IS NOT INITIAL.
*
*          SET PARAMETER ID 'BAN' FIELD LS_LIST-BANFN_N.
*          CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.

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
*
*        ELSE.
*          EXIT.
*        ENDIF.

      ELSE.

*        READ TABLE GT_CREATE INTO DATA(LS_CRE) INDEX PS_ROW_NO-INDEX.
*        CHECK SY-SUBRC = 0.
*
*        IF PS_COLUMN-FIELDNAME = 'EBELN'.
*          CHECK LS_CRE-EBELN IS NOT INITIAL.
*
*          SET PARAMETER ID 'BES' FIELD LS_CRE-EBELN.
*          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

*      ELSEIF PS_COLUMN-FIELDNAME = 'BANFN'.
*        CHECK LS_CRE-EBELN IS NOT INITIAL.
*
*        SET PARAMETER ID 'BES' FIELD LS_CRE-EBELN.
*        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.


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
*
*        ELSE.
*          EXIT.
*        ENDIF.

      ENDIF.


    WHEN gcl_grid_it.
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
         ls_return TYPE ddshretval.
  FIELD-SYMBOLS : <lt_modi> TYPE lvc_t_modi.
  DATA : ls_modi TYPE lvc_s_modi.

* TO AVOID STANDARD F4-HELP.
  er_event_data->m_event_handled = 'X'.

*세금코드
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
*선택된 값 추출 (F0001=KALSM, F0002=MWSKZ, F0003=TEXT1)
      READ TABLE lt_return INTO ls_return WITH KEY fieldname = 'F0002'.

      ASSIGN er_event_data->m_data->* TO <lt_modi>.

      CLEAR : ls_modi.
      ls_modi-row_id      = es_row_no-row_id.
      ls_modi-fieldname = e_fieldname.
      ls_modi-value        = ls_return-fieldval.
      APPEND ls_modi TO <lt_modi>.
    ENDIF.

*세금계산서 일련번호
  ELSEIF e_fieldname = 'SGTXT'.
    CLEAR gt_tax.

    READ TABLE gt_disp ASSIGNING FIELD-SYMBOL(<dsp>)
    INDEX es_row_no-row_id.

    IF sy-subrc = 0.
      SELECT FROM zgtmm_cv_get_tax_invoice
      FIELDS *
      WHERE bukrs EQ @p_bukrs
           AND lifnr   EQ @<dsp>-lifnr
           AND taxinv IS INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @gt_tax.
    ENDIF.

    IF gt_tax IS INITIAL.
      CLEAR gv_taxno. MESSAGE s000 WITH TEXT-e01.
    ELSE.
      CALL SCREEN 400 STARTING AT 10 5.
    ENDIF.

    IF gv_taxno IS NOT INITIAL.
      READ TABLE gt_disp ASSIGNING FIELD-SYMBOL(<dsp2>)
      INDEX es_row_no-row_id.

      IF sy-subrc = 0.
*>S.2026.08.04_금액 일치여부 조건 체크 해제.
**선택한 데이터의 합계금액/공급가액/(부가)세액 금액이 일치하지 않으면, 미설정
*        IF <DSP2>-RMWWR NE GV_TOTAL OR <DSP2>-SPRICE NE GV_SPRICE
*            OR <DSP2>-WMWST1 NE GV_WMWST.
*
*          CLEAR : <DSP2>-SGTXT, GV_TOTAL, GV_SPRICE, GV_WMWST, GV_TAXNO.
*
*        ELSE.
        <dsp2>-sgtxt = gv_taxno.  "세금계산서일련번호
        <dsp2>-rmwwr = gv_total. "합계금액
        <dsp2>-sprice = gv_sprice.  "공급가액
        <dsp2>-wmwst1 = gv_wmwst. "세액

        CLEAR : gv_taxno, gv_total, gv_sprice, gv_wmwst.
*        ENDIF.
*<E.2026.08.04_ZGODEV04
      ENDIF.
    ENDIF.

*CL_GUI_ALV_GRID=>SET_DELTA_VALUES( )

  ENDIF.



*셀렉션스크린 파라메터나 스크린필드 바로 적용일때...
*  DATA : LT_DYNP TYPE TABLE OF DYNPREAD,
*             LS_DYNP TYPE DYNPREAD.
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

    CASE gv_okcode_save . "SY-UCOMM.
      WHEN 'INVOICE'.
        lv_msg = '송장 처리할 대상을 선택하세요.'(e06).
      WHEN 'REVERS'.
        lv_msg = '역분개할 송장 문서를 선택하세요.'(e07).
      WHEN 'REQ_PAY'.
        lv_msg = '지급 요청할 대상을 선택하세요.'(e05).
      WHEN OTHERS.
    ENDCASE.

    MESSAGE s000 WITH lv_msg DISPLAY LIKE gc_e.
  ENDIF.

  IF sy-tfill > 1 AND gv_okcode_save = 'REVERS'.
    gv_err = gc_x.
    lv_msg = '역분개 처리는 송장 건 별로 처리하세요.'(e09).
    MESSAGE s000 WITH lv_msg DISPLAY LIKE gc_e.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECT_ROW_ADSEL
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM select_row_adsel USING pv_gb.

  DATA(lt_list) = gt_list[].
  SORT lt_list BY check lifnr bukrs ekorg werks spmon xrech.

  CASE pv_gb.
*전체선택
    WHEN gc_a.
      IF p_inv = gc_x. "송장처리 옵션은 ITEM GRID에 버튼 존재
        CHECK gt_item[] IS NOT INITIAL.
*헤더 선택 시마다,조건에 맞는 ITEM이 자동 구성된 상태이므로, 아이템그리드의 전체선택 버튼 클릭시,
*별도 로직 없이 모두 체크해주면 됨. 헤더에는 해당 버튼 없으므로(개별선택임).
        LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<asel>).
          <asel>-check = gc_x.

*총 공급가액,세액,합계금액 변경 반영_상단 스크린 필드.
          READ TABLE lt_list TRANSPORTING NO FIELDS
          WITH KEY check = gc_x
                   lifnr = <asel>-lifnr
                   bukrs = <asel>-bukrs
                   ekorg = <asel>-ekorg
                   werks = <asel>-werks
                   spmon = <asel>-spmon
                   xrech = <asel>-xrech BINARY SEARCH.

          IF sy-subrc = 0 .
            gv_target_price = gv_target_price + <asel>-target_price.
            gv_taxprice = gv_taxprice + <asel>-taxprice.
          ENDIF.
        ENDLOOP.
*총 합계금액 = 총 공급가액 + 총 세액
        gv_wrbtr = gv_target_price + gv_taxprice.

        READ TABLE lt_list INTO DATA(ls2) WITH KEY check = gc_x BINARY SEARCH.
        gv_xrech = COND #( WHEN ls2 IS INITIAL THEN '' ELSE ls2-xrech ).

*합계필드 화면 표시용 변환(단위참조)
        WRITE gv_wrbtr TO gv_wrbtr_disp CURRENCY gv_waers LEFT-JUSTIFIED.
        WRITE gv_target_price TO gv_tprice_disp CURRENCY gv_waers LEFT-JUSTIFIED.
        WRITE gv_taxprice TO gv_xprice_disp CURRENCY gv_waers LEFT-JUSTIFIED.
      ENDIF.

      IF p_dis = gc_x.  "조회 옵션은 HEADER GRID에 버튼 존재
        MODIFY gt_disp FROM VALUE #( check = 'X' ) TRANSPORTING
                    check WHERE check <> 'X'.

        gt_disp_it[] = gt_disp_base[].
      ENDIF.

*전체선택해제
    WHEN gc_d.
      IF p_inv = gc_x.
        MODIFY gt_item FROM VALUE #( check = space ) TRANSPORTING
                     check WHERE check EQ 'X'.

        CLEAR :  gv_target_price, gv_taxprice, gv_wrbtr, gv_xrech,
                      gv_wrbtr_disp, gv_tprice_disp, gv_xprice_disp.
      ENDIF.

      IF p_dis = gc_x.
        MODIFY gt_disp FROM VALUE #( check = space ) TRANSPORTING
                    check WHERE check EQ 'X'.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SELECT_ROW_CHOICE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM select_row_choice USING pv_gb.

  DATA(lt_list) = gt_list[].
  SORT lt_list BY check lifnr bukrs ekorg werks spmon xrech.

  CLEAR : gv_err.

  PERFORM get_selected_rows USING gcl_grid_it.
  CHECK gv_err IS INITIAL.

  CASE pv_gb.
*전체선택
    WHEN gc_a.
      IF p_inv = gc_x. "송장처리 옵션은 ITEM GRID에 버튼 존재
        CHECK gt_item[] IS NOT INITIAL.
*선택된 블럭의 모든 라인 체크박스 표기(선택)
        LOOP AT gt_rows INTO DATA(ls_row).
          READ TABLE gt_item ASSIGNING FIELD-SYMBOL(<asel>) INDEX ls_row-index.
          IF sy-subrc = 0.
            <asel>-check = gc_x.
          ENDIF.
        ENDLOOP.
      ENDIF.

*선택해제
    WHEN gc_d.
      CLEAR ls_row.
      IF p_inv = gc_x.
*선택된 블럭의 모든 라인 체크박스 표기(선택)
        LOOP AT gt_rows INTO ls_row.
          READ TABLE gt_item ASSIGNING FIELD-SYMBOL(<dsel>) INDEX ls_row-index.
          IF sy-subrc = 0.
            <dsel>-check = ''.
          ENDIF.
        ENDLOOP.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

***총 공급가액,세액,합계금액 변경 반영_헤더 스크린 필드.
  PERFORM set_check_amt.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CHECK_REVERSAL_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM check_reversal_data .

  CLEAR : gv_err.
  DATA lv_tabix TYPE sy-tabix.

  DESCRIBE TABLE gt_disp.
  IF sy-tfill = 0.
    gv_err = gc_x.
    MESSAGE s000 WITH '역분개할 송장 문서를 선택하세요.'(e07) DISPLAY LIKE gc_e.
    EXIT.
  ENDIF.

  IF line_exists( gt_disp[ check = gc_x ] ).
    CLEAR lv_tabix.

    LOOP AT gt_disp ASSIGNING FIELD-SYMBOL(<fs>) WHERE check = gc_x.
      lv_tabix = lv_tabix + 1.

*      IF LV_TABIX > 1.
*        GV_ERR = GC_X.
*        MESSAGE S000 WITH '역분개 처리는 송장 건 별로 처리하세요.'(E09)
*        DISPLAY LIKE GC_E.  EXIT.
*      ENDIF.

      CHECK gv_err IS INITIAL.

      IF <fs>-check = gc_x AND <fs>-reqpay = gc_x.
        gv_err = gc_x. "지급 요청 진행 중인 송장은 역분개 할 수 없습니다.
        MESSAGE s000 WITH TEXT-e10 DISPLAY LIKE gc_e. EXIT.
      ENDIF.

      IF <fs>-check = gc_x AND <fs>-clearing = gc_x.
        gv_err = gc_x. "지급 진행된 송장은 역분개 할 수 없습니다.
        MESSAGE s000 WITH TEXT-e11 DISPLAY LIKE gc_e. EXIT.
      ENDIF.

    ENDLOOP.

  ELSE.
    gv_err = gc_x.
    MESSAGE s000 WITH '역분개할 송장 문서를 선택하세요.'(e07) DISPLAY LIKE gc_e.
    EXIT.
  ENDIF.

  CHECK gv_err IS INITIAL.

  CLEAR : gv_budat, gv_reason, gv_bdate, gv_zterm.
  gv_ques = TEXT-m04. "선택된 송장을 역분개 하시겠습니까?
  gv_info   = TEXT-m05.  "(전기일 미입력 시, 생성 시 전기일로 역분개 됩니다.)

  CALL SCREEN 0200 STARTING AT 5 10.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM REQUEST_PAY
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM request_pay.
  DATA:
    lv_reqxml TYPE string,
    lv_type   TYPE bapi_mtype,
    lv_msg    TYPE bapi_msg,
    lv_appid  TYPE char32,
    lv_legacy TYPE char32,
    lv_url    TYPE string,
    lv_pernr  TYPE char10,
    lv_tcode  TYPE char20.

  CLEAR : gv_answer, gv_err.

  IF line_exists( gt_disp[ check = gc_x ] ).
    PERFORM popup_to_confirm_step USING gc_n TEXT-m07 '' TEXT-t04. "확인
*  "선택한 송장에 대해 지급 요청을 하시겠습니까?
  ELSE.
    gv_err = gc_x. "지급 요청할 대상을 선택하세요.
    MESSAGE s000 WITH TEXT-e05 DISPLAY LIKE gc_e. EXIT.
  ENDIF.

  CHECK gv_err IS INITIAL.
  CHECK gv_answer = gc_j. "YES

  LOOP AT gt_disp ASSIGNING FIELD-SYMBOL(<fs>) WHERE check = gc_x.

    IF <fs>-reqpay = gc_x.
      gv_err = gc_x. "이미 지급 요청한 송장입니다.
      MESSAGE s000 WITH TEXT-e13 DISPLAY LIKE gc_e. EXIT.
    ENDIF.

    IF <fs>-clearing = gc_x.
      gv_err = gc_x. "지급 진행된 송장은 지급 요청할 수 없습니다.
      MESSAGE s000 WITH TEXT-e15 DISPLAY LIKE gc_e. EXIT.
    ENDIF.

  ENDLOOP.

  CHECK gv_err IS INITIAL.

*  DATA : LV_TYPE       TYPE BAPI_MTYPE,
*         LV_MSG        TYPE BAPI_MSG,
*         LV_LEGACY(32),
*         LV_APPID(32),
*         LV_URL        TYPE STRING,
*         LV_XML        TYPE STRING.

  DATA : lt_5010 LIKE TABLE OF zgtmmt5010.

  "XML 생성
  PERFORM f_set_gw_xml USING sy-uname CHANGING lv_reqxml.

  lv_pernr = sy-uname.
  lv_tcode = sy-tcode.

*WELS 결재요청//HTML 구성....추후 정의 되면..
  CALL FUNCTION 'ZGTMM_APP_TO_WELS'
    EXPORTING
      i_bukrs  = p_bukrs
      i_pernr  = lv_pernr
      i_tcode  = lv_tcode
      i_reqxml = lv_reqxml
    IMPORTING
      mtype    = lv_type
      message  = lv_msg
      legacyid = lv_legacy
      appid    = lv_appid
      url      = lv_url.

  IF  lv_type = gc_e.
    MESSAGE s000 WITH lv_msg DISPLAY LIKE gc_e.

  ELSE.
*ZGTMMT5010 LOG UPDATE
    lt_5010[] = VALUE #( BASE lt_5010 FOR ls IN gt_disp WHERE ( check = gc_x )
                                    ( VALUE #( BASE CORRESPONDING #( ls )
                                         legacyid = lv_legacy
                                         appid = lv_appid
                                         erdat = sy-datum
                                         erdat_local = sy-datlo
                                         ertim = sy-uzeit
                                         ertim_local = sy-timlo
                                         ernam = sy-uname
                                         aedat = sy-datum
                                         aedat_local = sy-datlo
                                         aetim = sy-uzeit
                                         aetim_local =  sy-timlo
                                         aenam = sy-uname ) ) ).
    IF lt_5010[] IS NOT INITIAL.
      MODIFY zgtmmt5010 FROM TABLE lt_5010.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

    MESSAGE s036 WITH '지급 요청'. "& 성공했습니다.
  ENDIF.


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
  DATA : lv_set_err TYPE char1.
  DATA :
    lt_item     TYPE TABLE OF bapi_incinv_create_item,
    lt_item_max TYPE TABLE OF bapi_incinv_create_item,
    lt_tax      TYPE TABLE OF bapi_incinv_create_tax.
  DATA : BEGIN OF ls_tax,
           tax_code   TYPE  bapi_incinv_create_tax-tax_code,
           tax_amount TYPE bapi_incinv_create_tax-tax_amount,
         END OF ls_tax,
         lt_tax_col LIKE TABLE OF ls_tax WITH HEADER LINE.

  DATA :
    ls_head      TYPE bapi_incinv_create_header,
    lv_item      TYPE ebelp,
    lv_invno     TYPE re_belnr,
    lv_ivyear    TYPE gjahr,
    lv_tprice    TYPE zgtmm_cv_get_target_iv_h2-wrbtr,
    lv_time(14),
    lv_c_amt(35).

  CLEAR : gv_err.

  DEFINE _idoc.

    IF &3 = 'D'.
   " 1. SAP 내부(100.00) -> 외부/IDOC(100) 변환
     CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_IDOC'
       EXPORTING
        currency      = &1
        sap_amount  = &2
       IMPORTING
        idoc_amount = &2. " 결과: 100

    ELSE. "A
  " 2. 화면 입력(100) -> SAP 내부(100.00) 변환
    CALL FUNCTION 'CURRENCY_AMOUNT_DISPLAY_TO_SAP'
      EXPORTING
        currency               = &1
        amount_display    = &2
      IMPORTING
        amount_internal  = &2. " 결과: 100.00

    ENDIF.
  END-OF-DEFINITION.

*>S.26.07.29_공통코드에 최대 구성 라인이 존재하면 그 기준으로 분할 생성 체크
  SELECT SINGLE fld_02
    FROM zgtppt1010
    WHERE module_kind = @gc_mm
        AND codegrp = '0770'
        AND fld_01 = @p_werks
    INTO @DATA(lv_max).
*<E.25.07.29_ZGODEV04.

*BAPI HEAER
  lv_c_amt = gv_wrbtr.
  _idoc gv_waers lv_c_amt 'D'.
  gv_wrbtr = lv_c_amt.

*>S.2026.08.13_송장생성시 구분내역이 필요하여 추가/구매오더 여러개이므로..
  lv_time = |{ sy-datum }{ sy-uzeit }|. "(YYYYMMDDHHMMSS)
*<E.2026.08.13_ZGODEV04

  ls_head = VALUE #( invoice_ind          = gv_xrech
                                  doc_date              = gv_budat "SY-DATLO 2026.08.11 변경
                                  pstng_date           = gv_budat
                                  comp_code            = p_bukrs
                                  currency               = gv_waers
                                  exch_rate              = gv_exrate
                                  gross_amount       = gv_wrbtr
                                  pmnttrms                = gv_zterm "지급조건
                                  ref_doc_no_long  = p_werks
                                  item_text                = gv_taxno  "세금계산서일련번호
                                  alloc_nmbr           = lv_time       "2026.08.13추가(YYYYMMDDHHMMSS)
                                  bline_date              = gv_budat  ). "지급기산일 GV_BDATE 전기일자랑 같게_260803

*BAPI_ITEM
  CLEAR : lv_item, lt_item, lt_tax, gt_return.
  SORT gt_item BY check ebeln ebelp mblnr zeile .

  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fs>) WHERE check = gc_x.

    lv_item = lv_item + 1.

    CLEAR : lv_tprice, lv_c_amt.
    lv_c_amt = <fs>-target_price.
    _idoc gv_waers lv_c_amt 'D'.
    lv_tprice = lv_c_amt.

    APPEND VALUE #( invoice_doc_item  = lv_item
                                 po_number        = <fs>-ebeln
                                 po_item              = <fs>-ebelp
                                 ref_doc             = <fs>-mblnr
                                 ref_doc_year   = <fs>-mjahr
                                 ref_doc_it        = <fs>-zeile
                                 tax_code          = <fs>-mwskz
                                 item_amount    = lv_tprice
                                 quantity           = <fs>-iv_qty
                                 po_unit             = <fs>-meins
                                 po_pr_qnt       = <fs>-iv_oqty
                                 po_pr_uom      = <fs>-etiv_meins
                                 ) TO lt_item.

*    LT_TAX_COL-TAX_CODE      = <FS>-MWSKZ.
*    CLEAR LV_C_AMT.
*    LV_C_AMT = <FS>-TAXPRICE.
*    _IDOC GV_WAERS LV_C_AMT 'D'.
*    LT_TAX_COL-TAX_AMOUNT = LV_C_AMT.
*    COLLECT LT_TAX_COL .
  ENDLOOP.

*  LT_TAX[] = CORRESPONDING #( LT_TAX_COL[] ).

*>S.2026.07.29_500건 이상일 경우 FI 전표 발생 시 999라인 이상으로 에러 발생하므로, 분할생성
  DATA :
    lv_cnt_run      TYPE int4,
    lv_start_idx    TYPE int4,
    lv_end_idx      TYPE int4,
    lv_target_price TYPE zgtmm_cv_get_target_iv_h-target_price,
    lv_sub_tax      TYPE bapi_incinv_create_tax-tax_amount,
    lv_total_tax    TYPE  bapi_incinv_create_tax-tax_amount.  " 세액 합계용

  CLEAR : lv_cnt_run, lv_start_idx, lv_end_idx, lv_sub_tax.
*공통코드 최대 라인 수 존재하면 해당 데이터, 존재하지 않으면 최대 400..기준
  IF lv_max IS INITIAL.
    lv_max = 400.
  ENDIF.

  lv_cnt_run = lines( lt_item ) DIV lv_max.

  IF lines( lt_item ) MOD lv_max NE 0 OR lv_cnt_run = 0.
    lv_cnt_run += 1.
  ENDIF.

  DO lv_cnt_run TIMES.
    CLEAR : lt_item_max, lt_tax_col[], lv_target_price, lv_total_tax.

    " 시작 TABIX 계산
    lv_start_idx = ( sy-index - 1 ) * lv_max + 1.
    " 종료 TABIX 계산
    lv_end_idx = lv_start_idx + lv_max.

    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>) FROM lv_start_idx.
      "종료 TAB INDEX 보다 크거나 같으면 종료
      IF sy-tabix GE lv_end_idx.
        EXIT.
      ENDIF.
*분할 한 만큼의 (공급가액) 재계산.
      lv_target_price = lv_target_price + <ls_item>-item_amount.
      "라인추가
      lt_item_max[] = VALUE #( BASE lt_item_max ( CORRESPONDING #( <ls_item> ) ) ).

*세액 합산
      READ TABLE gt_item ASSIGNING FIELD-SYMBOL(<tax>)
      WITH KEY check = 'X'
                      ebeln = <ls_item>-po_number
                      ebelp = <ls_item>-po_item
                      mblnr = <ls_item>-ref_doc
                      zeile = <ls_item>-ref_doc_it BINARY SEARCH.
      IF sy-subrc = 0.
        lt_tax_col-tax_code = <tax>-mwskz.

        CLEAR lv_c_amt.
        lv_c_amt = <tax>-taxprice.
        _idoc gv_waers lv_c_amt 'D'.
        lt_tax_col-tax_amount = lv_c_amt.
        COLLECT lt_tax_col .

        lv_total_tax = lv_total_tax + lv_c_amt.
      ENDIF.
    ENDLOOP.
*    "재계산 된 총 공급가액 기준으로 세금코드에 따라 계산
*    IF GV_TAX = 'VA'. "세액 10%->원단위 절사
*         LV_TOTAL_TAX = LV_TARGET_PRICE * '0.1'.
*         " 10으로 나눈 뒤 소수점을 버리고(FLOOR) 다시 10을 곱해 원단위를 0으로.
*         LV_TOTAL_TAX = TRUNC( LV_TOTAL_TAX  ).
*
*    ELSEIF GV_TAX = 'V1'. "영세율은 세액 0
*         LV_TOTAL_TAX = 0.
*    ENDIF.

    "헤더 총금액 재설정
    ls_head-gross_amount = lv_target_price + lv_total_tax.

    CLEAR lt_tax.
*    APPEND VALUE #( TAX_CODE = GV_TAX
*                                 TAX_AMOUNT = LV_TOTAL_TAX ) TO LT_TAX.
    lt_tax[] = CORRESPONDING #( lt_tax_col[] ).

*BAPI
    CLEAR : lv_invno, lv_ivyear, gt_return, lv_set_err.

    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
      EXPORTING
        headerdata       = ls_head
      IMPORTING
        invoicedocnumber = lv_invno
        fiscalyear       = lv_ivyear
      TABLES
        itemdata         = lt_item_max "LT_ITEM
        taxdata          = lt_tax
        return           = gt_return.

*    LOOP AT GT_LIST ASSIGNING FIELD-SYMBOL(<FSHD>) WHERE CHECK = GC_X.
    IF line_exists( gt_return[ type = gc_e ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      READ TABLE gt_return INTO DATA(ls_rt) INDEX 1.

      LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<fshd>) WHERE check = gc_x.
        <fshd>-status    = icon_led_red.
        <fshd>-message = ls_rt-message.
      ENDLOOP.
      lv_set_err  = gc_x.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = gc_x.

      LOOP AT gt_list ASSIGNING <fshd> WHERE check = gc_x.
        <fshd>-status    = icon_led_green.
        MESSAGE s165 WITH lv_invno INTO <fshd>-message.
      ENDLOOP.
*      "송장 &1 가 생성 되었습니다.
    ENDIF.
*    ENDLOOP.

    IF lines( gt_return ) > 1.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_return.
    ENDIF.

  ENDDO.
*>E.2026.07.29_ZGODEV04

  IF lv_set_err NE gc_x.
    CLEAR : gv_lifnr, gv_lifnr_n, gv_exrate,
                 gv_waers, gv_twaers, gv_xwaers, gv_xrech,
                 gv_target_price, gv_taxprice, gv_wrbtr , gv_tax,
                 gv_tprice_disp, gv_xprice_disp, gv_wrbtr_disp.

    PERFORM get_data.
    MESSAGE s000 WITH TEXT-m19 DISPLAY LIKE gc_s.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_REVERSAL_INVOICE.
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_reversal_invoice.
  DATA : lv_rev_err TYPE char1.
  DATA : lv_msg    TYPE bapi_msg,
         lv_rbelnr TYPE bapi_incinv_fld-inv_doc_no,
         lv_rgjahr TYPE bapi_incinv_fld-fisc_year,
         lt_return TYPE bapiret2_t.

  LOOP AT gt_disp ASSIGNING FIELD-SYMBOL(<fs>) WHERE check = gc_x.
    CLEAR gt_return.

    gv_budat = COND #( WHEN gv_budat IS INITIAL THEN <fs>-budat ELSE gv_budat ).

    TRY.
        CALL FUNCTION 'BAPI_INCOMINGINVOICE_CANCEL'
          EXPORTING
            invoicedocnumber          = <fs>-belnr
            fiscalyear                = <fs>-gjahr
            reasonreversal            = gv_reason
            postingdate               = gv_budat
          IMPORTING
            invoicedocnumber_reversal = lv_rbelnr
            fiscalyear_reversal       = lv_rgjahr
          TABLES
            return                    = gt_return.

      CATCH cx_root INTO DATA(lv_err).
        lv_msg = lv_err->get_text( ).
        MESSAGE s000 WITH lv_msg DISPLAY LIKE gc_e. EXIT.
    ENDTRY.

    IF line_exists( gt_return[ type = gc_e ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      IF lines( gt_return ) > 1.
        INSERT LINES OF CORRESPONDING bapiret2_t( gt_return ) INTO TABLE lt_return.
      ENDIF.

      READ TABLE gt_return INTO DATA(ls_rt) INDEX 1.

      <fs>-status    = icon_led_red.
      <fs>-message = ls_rt-message.

      lv_rev_err = gc_x.

    ELSE.
      IF lv_rbelnr IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = gc_x.

        <fs>-status    = icon_led_green.
        MESSAGE s164 WITH lv_rbelnr INTO <fs>-message.
*      "송장이 &1 로 역분개 되었습니다.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF lt_return[] IS NOT INITIAL.
    CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
      TABLES
        i_bapiret2_tab = lt_return.
  ENDIF.

  IF lv_rev_err NE gc_x.
    PERFORM get_data.
    MESSAGE s000 WITH TEXT-m20 DISPLAY LIKE gc_s.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_INVOICE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_invoice .

  CLEAR : gv_err. "GT_ROWS, GS_ROW, GV_ERR.

*  PERFORM GET_SELECTED_ROWS USING GCL_GRID_HD.
*  CHECK GV_ERR IS INITIAL.

* 세금계산서 수신 지연으로 해당 로직 제외*
*  SELECT FROM ZGTPPT1010
*    FIELDS *
*    WHERE MODULE_KIND = @GC_MM
*         AND CODEGRP = @GC_0820
*         AND FLD_01 = @P_BUKRS
*    INTO TABLE @DATA(LT_1010).
*    SORT LT_1010 BY FLD_02 FLD_03.

  SORT gt_list BY check lifnr bukrs ekorg werks spmon ASCENDING.

  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fs>) .
    IF <fs>-check = gc_x.

      READ TABLE gt_list ASSIGNING FIELD-SYMBOL(<head>)
      WITH KEY check  = gc_x
                     lifnr = <fs>-lifnr
                     bukrs = <fs>-bukrs
                     ekorg = <fs>-ekorg
                     werks = <fs>-werks
                     spmon = <fs>-spmon BINARY SEARCH.

      IF sy-subrc = 0 AND <head>-status = icon_led_green.
        gv_err = gc_x. "이미 생성된 송장입니다.
        MESSAGE s000 WITH TEXT-m18 DISPLAY LIKE gc_e. EXIT.
      ENDIF.

      IF  gv_target_price = 0 OR gv_wrbtr = 0 .
        gv_err = gc_x. "송장 처리할 금액을 확인하세요.
        MESSAGE s000 WITH TEXT-m15 DISPLAY LIKE gc_e. EXIT.
      ENDIF.

      IF <fs>-etiv_waers IS INITIAL.
        gv_err = gc_x. "외화 송장 처리는 환율을 필수 입력하세요.
        MESSAGE s000 WITH TEXT-m14 DISPLAY LIKE gc_e. EXIT.
      ENDIF.

*공통코드로 관리되는 업체가 아닌 경우, 세금계산서 금액 체크
      CHECK <head> IS ASSIGNED.
*      READ TABLE LT_1010 TRANSPORTING NO FIELDS
*      WITH KEY FLD_02 = <HEAD>-WERKS
*                     FLD_03 = <HEAD>-LIFNR BINARY SEARCH.
*      IF SY-SUBRC <> 0.
*        IF GV_TARGET_PRICE NE GV_TARGET_PRICE2 OR  "공급가액
*           GV_TAXPRICE NE GV_TAXPRICE2 OR "세액
*           GV_WRBTR  NE GV_WRBTR2 . "합계금액
*
*         GV_ERR = GC_X. "세금계산서와 처리 금액이 다릅니다. 점검하세요.
*         MESSAGE S000 WITH TEXT-E16 DISPLAY LIKE GC_E. EXIT.
*        ENDIF.
*      ENDIF.

    ENDIF.
  ENDLOOP.

  SORT gt_list BY bukrs ekorg ekgrp lifnr spmon werks ASCENDING.
  CHECK gv_err IS INITIAL.

  CLEAR : gv_budat, gv_reason, gv_bdate, gv_zterm.
  gv_ques = TEXT-m08. "선택된 업체에 대해 송장 처리를 하시겠습니까?
  gv_info   = TEXT-m09.  "(마감 월을 확인하고 전기 일자를 입력하세요.)
  gv_bdate = gv_budat."SY-DATUM. "지급기산일

  CALL SCREEN 0200 STARTING AT 5 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_DATA_ASEL
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LV_GB
*&      <-- GT_ITEM
*&---------------------------------------------------------------------*
FORM get_data_asel  USING    pv_gb.

  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<fs>).

    CASE pv_gb.
      WHEN gc_l. "업체 별
        SORT gt_item_base BY lifnr bukrs ekorg werks spmon .
*LIFNR,BUKRS,EKORG,WERKS(EKGRP)SPMON 기준으로 ITEM구성
        READ TABLE gt_item_base TRANSPORTING NO FIELDS
        WITH KEY lifnr = <fs>-lifnr
                       bukrs = <fs>-bukrs
                       ekorg = <fs>-ekorg
                       werks = <fs>-werks
                       spmon = <fs>-spmon BINARY SEARCH.

        IF sy-subrc = 0.
          DATA(lv_tabix) = sy-tabix.
          LOOP AT gt_item_base INTO DATA(ls_it) FROM lv_tabix.

            IF <fs>-lifnr = ls_it-lifnr AND <fs>-bukrs = ls_it-bukrs AND
                <fs>-ekorg = ls_it-ekorg AND <fs>-werks = ls_it-werks
                AND <fs>-spmon = ls_it-spmon.

              ls_it-check = gc_x.
              APPEND ls_it TO gt_item.  CLEAR ls_it.

            ELSE.
              EXIT.
            ENDIF.

          ENDLOOP.
        ENDIF.


      WHEN gc_e."구매그룹 별
        SORT gt_item_base BY lifnr bukrs ekorg werks ekgrp spmon .
*LIFNR,BUKRS,EKORG,WERKS EKGRP SPMON 기준으로 ITEM구성
        READ TABLE gt_item_base TRANSPORTING NO FIELDS
        WITH KEY lifnr = <fs>-lifnr
                       bukrs = <fs>-bukrs
                       ekorg = <fs>-ekorg
                       werks = <fs>-werks
                       ekgrp = <fs>-ekgrp
                       spmon = <fs>-spmon BINARY SEARCH.

        IF sy-subrc = 0.
          lv_tabix = sy-tabix.
          LOOP AT gt_item_base INTO DATA(ls_itm) FROM lv_tabix.

            IF <fs>-lifnr = ls_it-lifnr AND <fs>-bukrs = ls_it-bukrs AND
                <fs>-ekorg = ls_it-ekorg AND <fs>-werks = ls_it-werks
                AND <fs>-ekgrp = ls_it-ekgrp AND <fs>-spmon = ls_it-spmon.

              ls_itm-check = gc_x.
              APPEND ls_itm TO gt_item.  CLEAR ls_itm.

            ELSE.
              EXIT.
            ENDIF.

          ENDLOOP.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CALCULATE_TAX
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      <-- LS_LIST
*&---------------------------------------------------------------------*
FORM calculate_tax   CHANGING ps_list LIKE gs_item.

  DATA : lv_wrbtr TYPE bseg-wrbtr,
         lt_mwdat LIKE TABLE OF rtax1u15.

*정산대상 금액
  lv_wrbtr = ps_list-target_price.

  IF ps_list-rate = 0.
    CLEAR ps_list-taxprice.

  ELSE.
*-정산대상 금액 변경 시 TAX 자동 재계산_변경된 정산대상금액*세율
    CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
      EXPORTING
        i_bukrs = ps_list-bukrs
        i_mwskz = ps_list-mwskz
        i_waers = ps_list-waers
        i_wrbtr = lv_wrbtr
      TABLES
        t_mwdat = lt_mwdat.
    IF lt_mwdat IS NOT INITIAL.
*금액/세율 계산된 세액
      READ TABLE lt_mwdat INTO DATA(ls_mw) INDEX 1.
      IF sy-subrc = 0.
        ps_list-taxprice = ls_mw-wmwst.
        ps_list-rate = ls_mw-msatz.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CALCULATE_PRICE
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> LS_MOD_CELLS_VALUE
*&      <-- LS_LIST
*&---------------------------------------------------------------------*
FORM calculate_price  USING  pv_gb
                                   CHANGING ps_list STRUCTURE gs_item
                                                    pv_value.

  DATA : lv_qty     TYPE zgtmm_cv_get_target_iv-iv_qty,
         lv_tprice  TYPE zgtmm_cv_get_target_iv-target_price,
         lv_c_price LIKE  wmto_s-amount,
         lv_etiv    TYPE zgtmm_cv_get_target_iv-etiv_price.

  IF pv_gb = gc_q. "Q-> IV_QTY
*-정산대상 수량 변경 시 정산대상금액 자동계산/변경_(정산대상수량/PER*정산유효단가)
    lv_qty = pv_value. "입력한 수량
    IF ps_list-etiv_meins EQ ps_list-iv_unit.
      lv_tprice = lv_qty * ps_list-etiv_price .
    ELSE.
      IF ps_list-etiv_meins = 'KM' OR ps_list-etiv_meins = 'KG'.
        lv_tprice = lv_qty * ps_list-etiv_price  / 1000.
      ELSEIF ps_list-etiv_meins = 'M' OR ps_list-etiv_meins = 'G'.
        lv_tprice = lv_qty * ps_list-etiv_price  * 1000.
      ENDIF.
    ENDIF.

    ps_list-target_price = lv_tprice. "정산대상금액
    ps_list-iv_oqty = pv_value / ps_list-bpumn.

  ELSE. "P -> ETIV_PRICE
*-정산유효단가 변경 시 정산대상금액 자동계산/변경_(정산대상수량/PER*정산유효단가)
    CONDENSE pv_value.
    " 1. SAP 내부(100.00) -> 외부/IDOC(100) 변환
    CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_IDOC'
      EXPORTING
        currency    = ps_list-waers
        sap_amount  = pv_value
      IMPORTING
        idoc_amount = pv_value. " 결과: 100

    lv_etiv = pv_value.

    IF ps_list-etiv_meins EQ ps_list-iv_unit.
      lv_tprice = ps_list-iv_qty * lv_etiv .
    ELSE.
      IF ps_list-etiv_meins = 'KM' OR ps_list-etiv_meins = 'KG'.
        lv_tprice = ps_list-iv_qty * lv_etiv  / 1000.
      ELSEIF ps_list-etiv_meins = 'M' OR ps_list-etiv_meins = 'G'.
        lv_tprice = ps_list-iv_qty * lv_etiv  * 1000.
      ENDIF.
    ENDIF.

    lv_c_price = lv_tprice.

    CALL FUNCTION 'CURRENCY_AMOUNT_DISPLAY_TO_SAP'
      EXPORTING
        currency        = ps_list-waers
        amount_display  = lv_c_price
      IMPORTING
        amount_internal = lv_c_price.
    IF sy-subrc <> 0.
* IMPLEMENT SUITABLE ERROR HANDLING HERE
    ENDIF.

    ps_list-target_price = lv_c_price.  "정산대상금액
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
*& FORM F_SET_GW_XML
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> SY_UNAME
*&      <-- LV_REQXML
*&---------------------------------------------------------------------*
FORM f_set_gw_xml  USING    pv_pernr  CHANGING cv_reqxml.
  cv_reqxml = |<Root>|.
  cv_reqxml = |{ cv_reqxml }<DOCINFO>|.


  cv_reqxml = |{ cv_reqxml }<DOCTITLE>지급요청  품의</DOCTITLE>|.
  cv_reqxml = |{ cv_reqxml }<TITLE>물대 송장 승인 요청</TITLE>|.
  cv_reqxml = |{ cv_reqxml }<CONTENTSTYPE>HTML</CONTENTSTYPE>|.
  cv_reqxml = |{ cv_reqxml }<CONTENTS></CONTENTS>|.
  cv_reqxml = |{ cv_reqxml }<APPTYPE>OPEN</APPTYPE>|.
  cv_reqxml = |{ cv_reqxml }</DOCINFO>|.


  SELECT SINGLE
    fld_02
    FROM zgtppt1010
    WHERE module_kind EQ 'MM'
    AND codegrp EQ '0021'
    AND fld_01 EQ @p_bukrs
    INTO @DATA(lv_fld02).

  cv_reqxml = |{ cv_reqxml }<MEMBERS><MEMBER>|.
  cv_reqxml = |{ cv_reqxml }<ID>{ lv_fld02 }{ pv_pernr }</ID>|.
  cv_reqxml = |{ cv_reqxml }<APPCODE>C101</APPCODE>|.
  cv_reqxml = |{ cv_reqxml }<APPTYPE>AT_C101</APPTYPE>|.
  cv_reqxml = |{ cv_reqxml }</MEMBER></MEMBERS>|.
  cv_reqxml = |{ cv_reqxml }</Root>|.
ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_TAX_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_tax_data .

  CLEAR : gv_err.
  DATA : lr_lifnr TYPE RANGE OF lfa1-lifnr.

  IF line_exists( gt_list[ check = gc_x ] ).
    LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<list>) WHERE check = gc_x.
*조회조건 설정(선택한 공급업체)
      APPEND VALUE #( sign = gc_i option = gc_eq
                                   low = <list>-lifnr ) TO lr_lifnr.
    ENDLOOP.

    SELECT FROM zgtmm_cv_get_tax_invoice
      FIELDS *
      WHERE bukrs EQ @p_bukrs
           AND lifnr   IN @lr_lifnr
           AND taxinv IS INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @gt_tax.

  ELSE.
    gv_err = gc_x.  "송장 처리할 대상을 선택하세요.
    MESSAGE s000 WITH TEXT-e06 DISPLAY LIKE gc_e. EXIT.
  ENDIF.

  IF gt_tax[] IS INITIAL.
    gv_err = gc_x.
    MESSAGE s002 DISPLAY LIKE gc_e.
  ENDIF.

  CHECK gv_err IS INITIAL.
  CALL SCREEN 0400 STARTING AT 10 5  ENDING AT 130 25.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_CELL_COLOR
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_cell_color.

  DATA:
    ls_color   TYPE  lvc_s_scol.

  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<list>).
    CLEAR: <list>-f_col, ls_color.
*상태
    ls_color = VALUE #( fname = 'STATUS'
                                       color-col = COND  #( WHEN  <list>-status IS INITIAL
                                                                             THEN '3'  ELSE '0' )"흰색(기본)0 / 노랑 3
                                       color-int = '0'     "색 연하게( 1 : 진하게 )
                                       color-inv = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
    INSERT ls_color INTO TABLE <list>-f_col.

*    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..
  ENDLOOP.

  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<item>).
    CLEAR: <item>-f_col, ls_color.
*입고상태
    ls_color = VALUE #( fname = 'TARGET_PRICE'
                                       color-col = COND  #( WHEN <item>-target_price IS INITIAL
                                                                             THEN '3'  ELSE '5' )"
                                       color-int = '0'
                                       color-inv = '0' ).
    INSERT ls_color INTO TABLE <item>-f_col.

*    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..
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
*& FORM SET_CELL_COLOR_300
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_cell_color_300.

  DATA:
    ls_color   TYPE  lvc_s_scol.

  LOOP AT gt_disp ASSIGNING FIELD-SYMBOL(<head>).
    CLEAR: <head>-f_col, ls_color.
*지급요청_완료 이면, 녹색 아니면 노랑으로 설정 해 봄..
    ls_color = VALUE #( fname = 'REQ'
                                       color-col = COND  #( WHEN  <head>-req = icon_mail
                                                                             THEN '5'  ELSE '3' )"녹색 5/노랑 3
                                       color-int = '0'     "색 연하게( 1 : 진하게 )
                                       color-inv = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
    INSERT ls_color INTO TABLE <head>-f_col.

*    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..
  ENDLOOP.

*  LOOP AT GT_DISP_IT ASSIGNING FIELD-SYMBOL(<ITEM>).
*    CLEAR: <ITEM>-F_COL, LS_COLOR.
**입고상태
*    LS_COLOR = VALUE #( FNAME = ''
*                                       COLOR-COL = COND  #( WHEN <ITEM>-
*                                                                             THEN '5'  ELSE '3' )"녹색 5/노랑 3
*                                       COLOR-INT = '0'     "색 연하게( 1 : 진하게 )
*                                       COLOR-INV = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
*    INSERT LS_COLOR INTO TABLE <ITEM>-F_COL.
*
**    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..
*
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_CELL_COLOR_400
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_cell_color_400.

  DATA:
    ls_color   TYPE  lvc_s_scol.

  LOOP AT gt_tax ASSIGNING FIELD-SYMBOL(<head>).
    CLEAR: <head>-f_col, ls_color.
*입고상태_완료 이면, 녹색 아니면 노랑으로 설정 해 봄..
    ls_color = VALUE #( fname = 'TAXTOTAL'
                                       color-col = COND  #( WHEN  <head>-taxtotal IS INITIAL
                                                                             THEN '3'  ELSE '0' )"기본(하얀색) 0/노랑 3
                                       color-int = '0'     "색 연하게( 1 : 진하게 )
                                       color-inv = '0' ). "배경색/글자색 반전여부 ( 1: 반전 )
    INSERT ls_color INTO TABLE <head>-f_col.

*    CLEAR LS_COLOR. "여기부터 필요하면 위와 동일하게 추가 구성..필드명만 변경..조건은 주기 나름..
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_DE_MAPPING_SGTXT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_de_mapping_sgtxt USING pv_gb.

  CLEAR : gv_err.
  DATA : lt_disp    LIKE TABLE OF gs_disp,
         lv_type    TYPE bapi_mtype,
         lv_msg     TYPE bapi_msg,
         lv_message TYPE bapi_msg.

  IF line_exists( gt_disp[ check = gc_x ] ).

    LOOP AT gt_disp ASSIGNING FIELD-SYMBOL(<disp>) WHERE check = gc_x.
*세금계산서 매핑 번호 유무 체크
      IF <disp>-sgtxt IS INITIAL.
        gv_err = gc_x.
        lv_message = COND #( WHEN pv_gb = gc_m THEN TEXT-e18 ELSE TEXT-e21 ).
        "세금계산서 번호는 필수 입력입니다. PV_GB = 'M'  "매핑
        "세금계산서 번호 매핑되지 않은 정보는 해제 대상이 아닙니다. "매핑해제
        MESSAGE s000 WITH lv_message DISPLAY LIKE gc_e. EXIT.
      ELSE.
        <disp>-sgtxt = COND #( WHEN pv_gb = gc_m THEN <disp>-sgtxt
                                                 ELSE space ).
      ENDIF.

      IF <disp>-reqpay = gc_x .
        gv_err = gc_x.  "결재 진행 중인 데이터는 변경 불가합니다.
        MESSAGE s000 WITH TEXT-e19 DISPLAY LIKE gc_e. EXIT.
      ENDIF.
    ENDLOOP.

    IF gv_err IS INITIAL.
      APPEND <disp> TO lt_disp.
    ENDIF.

  ELSE.
    gv_err = gc_x.  "처리 대상을 선택하세요.
    MESSAGE s000 WITH TEXT-e17 DISPLAY LIKE gc_e. EXIT.
  ENDIF.

  CHECK gv_err IS INITIAL.
  CHECK lt_disp[] IS NOT INITIAL.

  LOOP AT lt_disp ASSIGNING FIELD-SYMBOL(<ldisp>).

    CHECK gv_err IS INITIAL.
    CHECK <ldisp> IS ASSIGNED.

    CALL FUNCTION 'ZGTFI_CHANGE_DOC_TEXT'
      EXPORTING
        i_bukrs   = p_bukrs
        i_belnr   = <ldisp>-belnr_bkpf
        i_gjahr   = <ldisp>-gjahr_bkpf
        i_sgtxt   = <ldisp>-sgtxt
      IMPORTING
        e_result  = lv_type
        e_message = lv_msg.
    IF lv_type IS INITIAL OR lv_type NE gc_s.
      DATA(lv_sgtxt) = <ldisp>-sgtxt.
      gv_err = gc_x. EXIT.
    ENDIF.

  ENDLOOP.

  WAIT UP TO 1 SECONDS.
  CLEAR lv_message.

  IF gv_err IS INITIAL.
    PERFORM get_data.
*    세금계산서 매핑/매핑해제 완료.
    lv_message = COND #( WHEN pv_gb = gc_m THEN TEXT-e23 ELSE TEXT-e24 ).
    MESSAGE s000 WITH lv_message.

  ELSE.
    "세금계산서 매핑/매핑해제에 실패하였습니다. - &1
    lv_message = COND #( WHEN pv_gb = gc_m THEN TEXT-e22 ELSE TEXT-e20 ).
    MESSAGE s000 WITH lv_message lv_sgtxt DISPLAY LIKE gc_e. EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_CHECK_AMT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM set_check_amt .

  CLEAR :  gv_target_price, gv_taxprice, gv_wrbtr, gv_xrech,
                gv_wrbtr_disp, gv_tprice_disp, gv_xprice_disp.

  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<item>) WHERE check = gc_x.
*총 공급가액,세액,합계금액 변경 반영_상단 스크린 필드.
    gv_target_price = gv_target_price + <item>-target_price.
    gv_taxprice = gv_taxprice + <item>-taxprice.
  ENDLOOP.

*총 합계금액 = 총 공급가액 + 총 세액
  gv_wrbtr = gv_target_price + gv_taxprice.

  READ TABLE gt_list INTO DATA(ls) WITH KEY check = gc_x .
  gv_xrech = COND #( WHEN ls IS INITIAL THEN '' ELSE ls-xrech ).

*합계필드 화면 표시용 변환(단위참조)
  WRITE gv_wrbtr TO gv_wrbtr_disp CURRENCY gv_waers LEFT-JUSTIFIED.
  WRITE gv_target_price TO gv_tprice_disp CURRENCY gv_waers LEFT-JUSTIFIED.
  WRITE gv_taxprice TO gv_xprice_disp CURRENCY gv_waers LEFT-JUSTIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TAX_ADJUST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_tax_adjust .

  CLEAR : gv_err.

  PERFORM get_selected_rows USING gcl_grid_it.
  CHECK gv_err IS INITIAL.
  CHECK gt_item[] IS NOT INITIAL.

  LOOP AT gt_rows INTO DATA(ls_row).
*선택된 블럭의 모든 라인 '정산대상TAX(TAXPRICE)'필드에 +1원 씩 조정
    READ TABLE gt_item ASSIGNING FIELD-SYMBOL(<tax>) INDEX ls_row-index.
    IF sy-subrc = 0.
      <tax>-check = gc_x.
      CHECK <tax>-waers = 'KRW'.
      <tax>-taxprice = <tax>-taxprice + '0.01'.
    ENDIF.
  ENDLOOP.

***총 공급가액,세액,합계금액 변경 반영_헤더 스크린 필드.
  PERFORM set_check_amt.

ENDFORM.
