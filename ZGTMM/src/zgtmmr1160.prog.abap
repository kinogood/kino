*&---------------------------------------------------------------------*
*& 모듈        : MM
*& 프로그램 ID : ZGTMMR1160
*& 프로그램 명 : OEM BOM 조회
*& 개요   : [가온전선] OEM 자재(3번대)에 연결된 설계서(1번대)의 BOM·자재량을 조회하는 프로그램
*&          - 조회 : Open SQL SELECT 후 ALV(SALV) 출력
*&          - 엑셀 : ALV 툴바 'Excel' 버튼 (일반 xlsx, 1시트)
*&          - 데이터 기준
*&            . 설계서 : 상태 'Z'(확정) 중 최대 개정 (ZEDT1000/1090/1010)
*&            . 색상·띠줄·띠줄수·스펙 : OEM 자재(3번대) 분류특성
*&            . Cu/AL : 설계서(ZEDT1000), Opt(광량) : NFM 중량(/NFM/TKGW, NES 'FI')
*& 생성일 : 2026.10.19
*& 생성자 :
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2026.10.20
*& 수정자  :
*& 수정개요: 설계번호 특성 조회 시 KSSK·CABN 조인 제거(클래스 다중 배정 시 행 중복 방지),
*&          정렬에 플랜트·설계번호 추가, 플랜트-회사코드 일치 및 권한 체크 보완,
*&          품명 조건을 SQL WHERE 로 이동, 예외 처리를 SALV 예외로 한정,
*&          엑셀 다운로드에 ALV 화면의 필터·정렬·컬럼 표시 반영,
*&          플랜트 삭제표시 자재 제외, 자재량·광량 단위 연결, 특성 미존재 시 안내,
*&          품명/규격 조건 대소문자 구분 없이 검색(MAKTG),
*&          화면 제목 지정·조회 건수 메시지, 자재 단위 정렬로 반복값 생략·자재별 구분선,
*&          수량 컬럼 0 값 미표시, 본수·자재량(JAJE_QTY) 컬럼 추가(기존 자재량은 단위량으로 표시),
*&          작업·작업명(ZEDT1020/ZEDT0021) 추가(화면 숨김), 설계자재 앞으로 공정 위치 이동,
*&          본수·단위량 화면 숨김, 단위는 자재량 단위로 표시,
*&          Cu/AL/Opt 화면은 문자 컬럼(반복값 생략·0 미표시), 엑셀은 숫자 컬럼
*&---------------------------------------------------------------------*
REPORT zgtmmr1160 NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
* TABLES / TYPES / DATA
*----------------------------------------------------------------------*
TABLES: t001w, zedt1000, makt, mara, ausp.

TYPES:
  BEGIN OF ty_disp,
    bukrs        TYPE t001k-bukrs,          "회사코드
    werks        TYPE marc-werks,           "플랜트
    mtart        TYPE mara-mtart,           "자재유형
    est_matnr    TYPE zedt1000-new_matnr,   "견적자재
    matnr        TYPE mara-matnr,           "OEM자재코드
    maktx        TYPE makt-maktx,           "품명/규격
    color        TYPE ausp-atwrt,           "색상   (분류특성 PD_CA_COLOR_BASE)
    stripe_color TYPE ausp-atwrt,           "띠줄   (분류특성 PD_CA_COLOR_STRIPE)
    stripe_cnt   TYPE ausp-atwrt,           "띠줄수 (분류특성 PD_CA_COLOR_STRIPE_NO)
    spec_no      TYPE ausp-atwrt,           "스펙   (분류특성 PD_CA_SPEC_NO)
    cu_txt       TYPE c LENGTH 18,          "Cu  화면 표시용 문자 (같은 값 반복 생략, 0 미표시)
    al_txt       TYPE c LENGTH 18,          "AL  화면 표시용 문자
    opt_txt      TYPE c LENGTH 18,          "Opt 화면 표시용 문자
    cu_wgt       TYPE zedt1000-cu_wgt,      "Cu (설계서, 화면 숨김·엑셀 숫자)
    al_wgt       TYPE zedt1000-al_wgt,      "AL (설계서, 화면 숨김·엑셀 숫자)
    opt_qty      TYPE /nfm/tkgw-kgw,        "Opt(광량) = NFM 중량 (NES 'FI', 화면 숨김·엑셀 숫자)
    opt_unit     TYPE /nfm/tkgw-bme,        "광량 단위 (화면 숨김)
    gong_cd      TYPE zedt1010-gong_cd,     "공정
    jack_cd      TYPE zedt1020-jack_cd,     "작업 (설계작업관리, 화면 숨김)
    jack_nm      TYPE zedt0021-jack_nm,     "작업명 (작업코드 마스터, 화면 숨김)
    design_maktx TYPE makt-maktx,           "설계자재명
    design_matnr TYPE zedt1090-matnr,       "설계자재코드
    bonsu        TYPE zedt1090-bonsu,       "본수 (화면 숨김, 레이아웃에서 표시 가능)
    mat_qty      TYPE zedt1090-unit_qty,    "단위량 (화면 숨김)
    mat_unit     TYPE zedt1090-unit_unit,   "단위량 단위 (화면 숨김)
    jaje_qty     TYPE zedt1090-jaje_qty,    "자재량 (1000M 기준 소요량)
    jaje_unit    TYPE zedt1090-jaje_unit,   "단위 (자재량 단위)
    bigo         TYPE zedt1090-bigo,        "비고 (화면 숨김)
    sul_no       TYPE zedt1000-sul_no,      "설계번호 (화면 숨김)
    rev_seq      TYPE zedt1000-rev_seq,     "개정     (화면 숨김)
    sul_date     TYPE zedt1000-sul_date,    "설계일자 (화면 숨김)
    gong_seq     TYPE zedt1090-gong_seq,    "공정순번 (화면 숨김)
    jack_seq     TYPE zedt1090-jack_seq,    "작업순번 (화면 숨김)
    layer        TYPE zedt1090-layer,       "층       (화면 숨김)
    seqno        TYPE zedt1090-seqno,       "순번     (화면 숨김)
  END OF ty_disp,
  ty_t_disp TYPE STANDARD TABLE OF ty_disp WITH DEFAULT KEY.

CLASS lcl_evt DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS on_added_function
      FOR EVENT added_function OF cl_salv_events_table
      IMPORTING e_salv_function.
ENDCLASS.

DATA:
  gt_disp    TYPE ty_t_disp,
  go_alv     TYPE REF TO cl_salv_table,   "엑셀 다운로드 시 화면 필터·정렬 참조
  gv_missing TYPE string,                 "없는 표시용 분류특성 (안내용)
  gv_err     TYPE c LENGTH 1.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE gv_title.

  PARAMETERS:
    p_bukrs TYPE t001-bukrs DEFAULT '6000' OBLIGATORY.

  SELECT-OPTIONS:
    s_werks FOR t001w-werks DEFAULT '6500' OBLIGATORY NO INTERVALS,
    s_date  FOR zedt1000-sul_date,
    s_maktx FOR makt-maktx,
    s_matnr FOR mara-matnr,
    s_spec  FOR ausp-atwrt,
    s_mtart FOR mara-mtart DEFAULT 'MCHA' NO INTERVALS.

SELECTION-SCREEN END OF BLOCK b01.

*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*
  gv_title = '조회조건'.
  %_p_bukrs_%_app_%-text = '회사코드'.
  %_s_werks_%_app_%-text = '플랜트'.
  %_s_date_%_app_%-text  = '기간(설계일자)'.
  %_s_maktx_%_app_%-text = '품명/규격'.
  %_s_matnr_%_app_%-text = '자재코드'.
  %_s_spec_%_app_%-text  = 'Spec'.
  %_s_mtart_%_app_%-text = '자재유형'.

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  CLEAR: gv_err, gt_disp, gv_missing.

  PERFORM check_auth.
  CHECK gv_err IS INITIAL.

  PERFORM get_data.
  CHECK gv_err IS INITIAL.

  PERFORM display_alv.

*&---------------------------------------------------------------------*
*& CLASS LCL_EVT - ALV 툴바 'Excel' 버튼
*&---------------------------------------------------------------------*
CLASS lcl_evt IMPLEMENTATION.
  METHOD on_added_function.
    IF e_salv_function = 'ZXLS'.
      PERFORM excel_download.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& 플랜트-회사코드 일치 및 플랜트 조회 권한 체크
*&   (해당 플랜트는 모두 모아서 한 번에 표시)
*&---------------------------------------------------------------------*
FORM check_auth.

  DATA:
    lv_nobuk  TYPE string,
    lv_noauth TYPE string.

  SELECT w~werks, k~bukrs
    FROM t001w AS w
    LEFT OUTER JOIN t001k AS k
      ON k~bwkey = w~bwkey
   WHERE w~werks IN @s_werks
    INTO TABLE @DATA(lt_werks).

  IF lt_werks IS INITIAL.
    gv_err = 'X'.
    MESSAGE '조회조건에 해당하는 플랜트가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  LOOP AT lt_werks INTO DATA(ls_werks).
    IF ls_werks-bukrs <> p_bukrs.
      lv_nobuk = COND #( WHEN lv_nobuk IS INITIAL THEN ls_werks-werks
                         ELSE |{ lv_nobuk }, { ls_werks-werks }| ).
      CONTINUE.
    ENDIF.

    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
      ID 'ACTVT' FIELD '03'
      ID 'WERKS' FIELD ls_werks-werks.
    IF sy-subrc <> 0.
      lv_noauth = COND #( WHEN lv_noauth IS INITIAL THEN ls_werks-werks
                          ELSE |{ lv_noauth }, { ls_werks-werks }| ).
    ENDIF.
  ENDLOOP.

  IF lv_nobuk IS NOT INITIAL.
    gv_err = 'X'.
    MESSAGE |플랜트 { lv_nobuk } 은(는) 회사코드 { p_bukrs } 소속이 아닙니다.| TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF lv_noauth IS NOT INITIAL.
    gv_err = 'X'.
    MESSAGE |플랜트 { lv_noauth } 에 대한 조회 권한이 없습니다.| TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& 데이터 조회
*&   OEM자재(MARA) -> 분류특성 PD_CA_DESIGN_NO(설계번호)
*&     -> 설계서(ZEDT1000) 상태 'Z'(확정) 중 최대 개정 (H2 : 더 큰 'Z' 개정 제외)
*&     -> 설계 자재(ZEDT1090) / 공정(ZEDT1010)
*&   설계번호/색상/스펙/띠줄/띠줄수 : OEM 자재 분류특성 (AUSP, 특성 내부번호는 CABN 선조회)
*&   Opt(광량)              : NFM 중량 /NFM/TKGW (NES 'FI')
*&---------------------------------------------------------------------*
FORM get_data.

  DATA:
    lv_atinn_design TYPE cabn-atinn,
    lv_atinn_stripe TYPE cabn-atinn,
    lv_atinn_cnt    TYPE cabn-atinn,
    lv_atinn_spec   TYPE cabn-atinn,
    lv_atinn_color  TYPE cabn-atinn,
    lr_maktg        TYPE RANGE OF makt-maktg.

  "품명/규격 조건: 대소문자 구분 없이 검색하도록 대문자 검색필드(MAKTG)로 비교
  lr_maktg = VALUE #( FOR ls_maktx IN s_maktx
                      ( sign   = ls_maktx-sign
                        option = ls_maktx-option
                        low    = to_upper( ls_maktx-low )
                        high   = to_upper( ls_maktx-high ) ) ).

  "설계번호 특성 내부번호 (OEM 자재 -> 설계서 연결 키)
  SELECT SINGLE atinn FROM cabn
   WHERE atnam = 'PD_CA_DESIGN_NO' AND datub = '99991231'
    INTO @lv_atinn_design.
  IF sy-subrc <> 0.
    gv_err = 'X'.
    MESSAGE '설계번호 특성(PD_CA_DESIGN_NO)이 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  "스펙/색상 특성 내부번호
  SELECT SINGLE atinn FROM cabn
   WHERE atnam = 'PD_CA_SPEC_NO' AND datub = '99991231'
    INTO @lv_atinn_spec.
  SELECT SINGLE atinn FROM cabn
   WHERE atnam = 'PD_CA_COLOR_BASE' AND datub = '99991231'
    INTO @lv_atinn_color.

  "띠줄/띠줄수 특성 내부번호
  SELECT SINGLE atinn FROM cabn
   WHERE atnam = 'PD_CA_COLOR_STRIPE' AND datub = '99991231'
    INTO @lv_atinn_stripe.
  SELECT SINGLE atinn FROM cabn
   WHERE atnam = 'PD_CA_COLOR_STRIPE_NO' AND datub = '99991231'
    INTO @lv_atinn_cnt.

  "표시용 특성이 없으면 해당 컬럼만 공백으로 조회하고 화면 출력 후 안내
  DATA lv_missing TYPE string.
  IF lv_atinn_spec IS INITIAL.
    lv_missing = |{ lv_missing } PD_CA_SPEC_NO|.
  ENDIF.
  IF lv_atinn_color IS INITIAL.
    lv_missing = |{ lv_missing } PD_CA_COLOR_BASE|.
  ENDIF.
  IF lv_atinn_stripe IS INITIAL.
    lv_missing = |{ lv_missing } PD_CA_COLOR_STRIPE|.
  ENDIF.
  IF lv_atinn_cnt IS INITIAL.
    lv_missing = |{ lv_missing } PD_CA_COLOR_STRIPE_NO|.
  ENDIF.

  SELECT k~bukrs         AS bukrs,
         c~werks         AS werks,
         m~mtart         AS mtart,
         h~new_matnr     AS est_matnr,
         m~matnr         AS matnr,
         t1~maktx        AS maktx,
         v6~atwrt        AS color,
         v1~atwrt        AS stripe_color,
         v2~atwrt        AS stripe_cnt,
         v5~atwrt        AS spec_no,
         h~cu_wgt        AS cu_wgt,
         h~al_wgt        AS al_wgt,
         t2~maktx        AS design_maktx,
         i~matnr         AS design_matnr,
         i~bonsu         AS bonsu,
         i~unit_qty      AS mat_qty,
         i~unit_unit     AS mat_unit,
         i~jaje_qty      AS jaje_qty,
         i~jaje_unit     AS jaje_unit,
         p~gong_cd       AS gong_cd,
         j~jack_cd       AS jack_cd,
         jc~jack_nm      AS jack_nm,
         i~bigo          AS bigo,
         h~sul_no        AS sul_no,
         h~rev_seq       AS rev_seq,
         h~sul_date      AS sul_date,
         i~gong_seq      AS gong_seq,
         i~jack_seq      AS jack_seq,
         i~layer         AS layer,
         i~seqno         AS seqno,
         n4~kgw          AS opt_qty,
         n4~bme          AS opt_unit
    FROM mara AS m
   INNER JOIN marc AS c
      ON c~matnr = m~matnr
   INNER JOIN t001w AS w
      ON w~werks = c~werks
   INNER JOIN t001k AS k
      ON k~bwkey = w~bwkey
   INNER JOIN ausp AS d
      ON d~objek = m~matnr
     AND d~klart = '001'
     AND d~mafid = 'O'
     AND d~datub = '99991231'
     AND d~atinn = @lv_atinn_design
   INNER JOIN zedt1000 AS h
      ON h~sul_no = d~atwrt
     AND h~status = 'Z'
    LEFT OUTER JOIN zedt1000 AS h2
      ON h2~sul_no  = h~sul_no
     AND h2~status  = 'Z'
     AND h2~rev_seq > h~rev_seq
   INNER JOIN zedt1090 AS i
      ON i~sul_no  = h~sul_no
     AND i~rev_seq = h~rev_seq
    LEFT OUTER JOIN zedt1010 AS p
      ON p~sul_no   = i~sul_no
     AND p~rev_seq  = i~rev_seq
     AND p~gong_seq = i~gong_seq
    LEFT OUTER JOIN zedt1020 AS j
      ON j~sul_no   = i~sul_no
     AND j~rev_seq  = i~rev_seq
     AND j~gong_seq = i~gong_seq
     AND j~jack_seq = i~jack_seq
    LEFT OUTER JOIN zedt0021 AS jc
      ON jc~jack_cd = j~jack_cd
    LEFT OUTER JOIN ausp AS v1
      ON v1~objek = m~matnr
     AND v1~klart = '001'
     AND v1~mafid = 'O'
     AND v1~datub = '99991231'
     AND v1~atinn = @lv_atinn_stripe
    LEFT OUTER JOIN ausp AS v2
      ON v2~objek = m~matnr
     AND v2~klart = '001'
     AND v2~mafid = 'O'
     AND v2~datub = '99991231'
     AND v2~atinn = @lv_atinn_cnt
    LEFT OUTER JOIN ausp AS v5
      ON v5~objek = m~matnr
     AND v5~klart = '001'
     AND v5~mafid = 'O'
     AND v5~datub = '99991231'
     AND v5~atinn = @lv_atinn_spec
    LEFT OUTER JOIN ausp AS v6
      ON v6~objek = m~matnr
     AND v6~klart = '001'
     AND v6~mafid = 'O'
     AND v6~datub = '99991231'
     AND v6~atinn = @lv_atinn_color
    LEFT OUTER JOIN /nfm/tkgw AS n4
      ON n4~matnr = m~matnr
     AND n4~werks = c~werks
     AND n4~nes   = 'FI'
    LEFT OUTER JOIN makt AS t1
      ON t1~matnr = m~matnr
     AND t1~spras = @sy-langu
    LEFT OUTER JOIN makt AS t2
      ON t2~matnr = i~matnr
     AND t2~spras = @sy-langu
   WHERE h2~sul_no IS NULL
     AND m~lvorm  <> 'X'
     AND c~lvorm  <> 'X'
     AND k~bukrs   = @p_bukrs
     AND c~werks  IN @s_werks
     AND h~sul_date IN @s_date
     AND m~matnr  IN @s_matnr
     AND t1~maktg IN @lr_maktg
     AND v5~atwrt IN @s_spec
     AND m~mtart  IN @s_mtart
   ORDER BY c~werks, m~matnr, h~sul_no, i~gong_seq, i~jack_seq, i~layer, i~seqno
    INTO CORRESPONDING FIELDS OF TABLE @gt_disp.

  IF gt_disp IS INITIAL.
    gv_err = 'X'.
    MESSAGE '조회된 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'W'.
  ENDIF.

  "Cu/AL/Opt 화면 표시용 문자: ALV 는 문자 정렬 컬럼만 반복값을 생략하므로 문자로 변환
  "  (오른쪽 정렬 고정길이라 컬럼 정렬 순서도 숫자 순서와 같음, 0 은 공백)
  LOOP AT gt_disp ASSIGNING FIELD-SYMBOL(<ls_disp>).
    IF <ls_disp>-cu_wgt IS NOT INITIAL.
      WRITE <ls_disp>-cu_wgt TO <ls_disp>-cu_txt RIGHT-JUSTIFIED.
    ENDIF.
    IF <ls_disp>-al_wgt IS NOT INITIAL.
      WRITE <ls_disp>-al_wgt TO <ls_disp>-al_txt RIGHT-JUSTIFIED.
    ENDIF.
    IF <ls_disp>-opt_qty IS NOT INITIAL.
      WRITE <ls_disp>-opt_qty TO <ls_disp>-opt_txt UNIT <ls_disp>-opt_unit RIGHT-JUSTIFIED.
    ENDIF.
  ENDLOOP.

  gv_missing = lv_missing.   "화면 출력 후 안내

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM DISPLAY_ALV
*&---------------------------------------------------------------------*
*& ALV(SALV) 출력 - 컨테이너(그리드) 모드, 툴바 'Excel' 버튼 포함
*&---------------------------------------------------------------------*
FORM display_alv.

  TRY.
      "컨테이너(그리드) 모드 : 툴바 사용자 버튼(ADD_FUNCTION)은 그리드 모드에서만 가능
      cl_salv_table=>factory(
        EXPORTING r_container  = cl_gui_container=>screen0
        IMPORTING r_salv_table = go_alv
        CHANGING  t_table      = gt_disp ).

      DATA(lo_func) = go_alv->get_functions( ).
      lo_func->set_all( abap_true ).
      "표준 Excel 보기는 시트가 여러 개(Format/Header/Pivot...) 생성되므로 숨김
      lo_func->set_view_excel( abap_false ).
      lo_func->set_view_lotus( abap_false ).
      lo_func->set_view_crystal( abap_false ).
      "일반 Excel(1시트) 다운로드 버튼
      lo_func->add_function(
        name     = 'ZXLS'
        icon     = CONV #( icon_xls )
        text     = 'Excel'
        tooltip  = 'Excel 다운로드 (1시트)'
        position = if_salv_c_function_position=>right_of_salv_functions ).
      DATA(lo_event) = go_alv->get_event( ).
      SET HANDLER lcl_evt=>on_added_function FOR lo_event.
      go_alv->get_display_settings( )->set_striped_pattern( abap_true ).
      go_alv->get_layout( )->set_key( VALUE #( report = sy-repid ) ).
      go_alv->get_layout( )->set_save_restriction( if_salv_c_layout=>restrict_none ).
      go_alv->get_layout( )->set_default( abap_true ).
      DATA(lo_columns) = go_alv->get_columns( ).
      lo_columns->set_optimize( abap_true ).

      PERFORM set_headers USING lo_columns.

      "수량 컬럼 단위 연결 (자재량 -> 단위, 광량 -> 광량 단위)
      TRY.
          lo_columns->get_column( 'MAT_QTY' )->set_quantity_column( 'MAT_UNIT' ).
        CATCH cx_salv_not_found cx_salv_data_error.
      ENDTRY.
      TRY.
          lo_columns->get_column( 'OPT_QTY' )->set_quantity_column( 'OPT_UNIT' ).
        CATCH cx_salv_not_found cx_salv_data_error.
      ENDTRY.
      TRY.
          lo_columns->get_column( 'JAJE_QTY' )->set_quantity_column( 'JAJE_UNIT' ).
        CATCH cx_salv_not_found cx_salv_data_error.
      ENDTRY.

      "수량 컬럼 0 값은 공백으로 표시 (0.000 미표시)
      LOOP AT VALUE string_table( ( `MAT_QTY` ) ( `JAJE_QTY` ) ) INTO DATA(lv_zero).
        TRY.
            lo_columns->get_column( CONV #( lv_zero ) )->set_zero( abap_false ).
          CATCH cx_salv_not_found.
            CONTINUE.
        ENDTRY.
      ENDLOOP.

      "Cu/AL/Opt 문자 컬럼은 숫자처럼 오른쪽 정렬
      LOOP AT VALUE string_table( ( `CU_TXT` ) ( `AL_TXT` ) ( `OPT_TXT` ) ) INTO DATA(lv_right).
        TRY.
            lo_columns->get_column( CONV #( lv_right ) )->set_alignment( if_salv_c_alignment=>right ).
          CATCH cx_salv_not_found.
            CONTINUE.
        ENDTRY.
      ENDLOOP.

      "화면 숨김 컬럼 (회사코드/플랜트/자재유형은 구조상 맨 앞)
      LOOP AT VALUE string_table( ( `CU_WGT` ) ( `AL_WGT` ) ( `OPT_QTY` ) ( `GONG_SEQ` ) ( `JACK_SEQ` ) ( `LAYER` ) ( `SEQNO` ) ( `BIGO` ) ( `BONSU` ) ( `MAT_QTY` ) ( `MAT_UNIT` ) ( `JACK_CD` ) ( `JACK_NM` ) ( `OPT_UNIT` ) ( `SUL_NO` ) ( `REV_SEQ` ) (
`SUL_DATE` ) ) INTO DATA(lv_hide).
        TRY.
            lo_columns->get_column( CONV #( lv_hide ) )->set_visible( abap_false ).
          CATCH cx_salv_not_found.
            CONTINUE.
        ENDTRY.
      ENDLOOP.

      "자재 단위 그룹 표시: 정렬 컬럼은 같은 값이 연속되면 첫 행에만 표시됨
      "  (뒤의 설계번호/공정순번/작업순번/층/순번은 BOM 순서 유지용, 화면 숨김)
      DATA(lo_sorts) = go_alv->get_sorts( ).
      LOOP AT VALUE string_table( ( `BUKRS` ) ( `WERKS` ) ( `MTART` ) ( `MATNR` ) ( `EST_MATNR` ) ( `MAKTX` )
                                  ( `COLOR` ) ( `STRIPE_COLOR` ) ( `STRIPE_CNT` ) ( `SPEC_NO` )
                                  ( `CU_TXT` ) ( `AL_TXT` ) ( `OPT_TXT` )
                                  ( `SUL_NO` ) ( `GONG_SEQ` ) ( `JACK_SEQ` ) ( `LAYER` ) ( `SEQNO` ) ) INTO DATA(lv_sort).
        TRY.
            DATA(lo_sort) = lo_sorts->add_sort( columnname = CONV #( lv_sort ) ).
            IF lv_sort = `MATNR`.
              lo_sort->set_group( if_salv_c_sort=>group_with_underline ).   "자재가 바뀌면 구분선
            ENDIF.
          CATCH cx_salv_not_found cx_salv_existing cx_salv_data_error.
            CONTINUE.
        ENDTRY.
      ENDLOOP.

      go_alv->display( ).

      "기본 화면 컨테이너 사용 시 ALV가 화면에 표시되도록 하는 처리 (창 제목 지정)
      sy-title = 'OEM BOM 조회'.
      WRITE space.

      "조회 건수 (표시용 분류특성이 없으면 함께 안내)
      IF gv_missing IS INITIAL.
        MESSAGE |{ lines( gt_disp ) }건이 조회되었습니다.| TYPE 'S'.
      ELSE.
        MESSAGE |{ lines( gt_disp ) }건 조회. 분류특성이 없어 공백으로 표시:{ gv_missing }| TYPE 'S' DISPLAY LIKE 'W'.
      ENDIF.

    CATCH cx_salv_msg
          cx_salv_existing
          cx_salv_wrong_call INTO DATA(lx_err).
      MESSAGE lx_err->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_HEADERS
*&---------------------------------------------------------------------*
FORM set_headers USING po_columns TYPE REF TO cl_salv_columns_table.

  DATA(lt_head) = VALUE string_table(
    ( `BUKRS|회사코드` )
    ( `WERKS|플랜트` )
    ( `MTART|자재유형` )
    ( `EST_MATNR|견적자재` )
    ( `MATNR|OEM자재코드` )
    ( `MAKTX|품명/규격` )
    ( `COLOR|색상` )
    ( `STRIPE_COLOR|띠줄` )
    ( `STRIPE_CNT|띠줄수` )
    ( `SPEC_NO|스펙` )
    ( `CU_TXT|Cu` )
    ( `AL_TXT|AL` )
    ( `OPT_TXT|Opt` )
    ( `CU_WGT|Cu` )
    ( `AL_WGT|AL` )
    ( `OPT_QTY|Opt` )
    ( `DESIGN_MAKTX|설계자재명` )
    ( `DESIGN_MATNR|설계자재코드` )
    ( `BONSU|본수` )
    ( `MAT_QTY|단위량` )
    ( `MAT_UNIT|단위량단위` )
    ( `JAJE_QTY|자재량` )
    ( `JAJE_UNIT|단위` )
    ( `GONG_CD|공정` )
    ( `JACK_CD|작업` )
    ( `JACK_NM|작업명` )
    ( `BIGO|비고` )
    ( `SUL_NO|설계번호` )
    ( `REV_SEQ|개정` )
    ( `SUL_DATE|설계일자` ) ).

  LOOP AT lt_head INTO DATA(lv_head).
    SPLIT lv_head AT '|' INTO DATA(lv_field) DATA(lv_text).
    TRY.
        DATA(lo_col) = po_columns->get_column( CONV #( lv_field ) ).
        lo_col->set_short_text( CONV #( lv_text ) ).
        lo_col->set_medium_text( CONV #( lv_text ) ).
        lo_col->set_long_text( CONV #( lv_text ) ).
      CATCH cx_salv_not_found.
        CONTINUE.
    ENDTRY.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM EXCEL_DOWNLOAD
*&---------------------------------------------------------------------*
*& 일반 Excel(xlsx, 1시트) 다운로드 - 툴바 'Excel' 버튼
*&   ALV 화면의 필터·정렬·컬럼 표시(레이아웃)를 그대로 반영. 비고는 화면 숨김이어도 포함
*&---------------------------------------------------------------------*
FORM excel_download.

  DATA:
    lv_xml  TYPE xstring,
    lv_name TYPE string,
    lv_path TYPE string,
    lv_full TYPE string,
    lt_bin  TYPE solix_tab,
    lv_len  TYPE i.

  CHECK go_alv IS BOUND.

  "현재 화면 기준 필드카탈로그·정렬·필터
  DATA(lt_fcat) = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
                    r_columns      = go_alv->get_columns( )
                    r_aggregations = go_alv->get_aggregations( ) ).
  DATA(lt_sort) = cl_salv_controller_metadata=>get_lvc_sort( go_alv->get_sorts( ) ).
  DATA(lt_filt) = cl_salv_controller_metadata=>get_lvc_filter( go_alv->get_filters( ) ).

  LOOP AT lt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>) WHERE fieldname = 'BIGO'.
    <ls_fcat>-no_out = abap_false.
  ENDLOOP.

  "엑셀은 Cu/AL/Opt 를 숫자 컬럼으로 출력 (화면 문자 컬럼의 표시 여부·위치를 그대로 사용)
  LOOP AT VALUE string_table( ( `CU_TXT|CU_WGT` ) ( `AL_TXT|AL_WGT` ) ( `OPT_TXT|OPT_QTY` ) ) INTO DATA(lv_pair).
    SPLIT lv_pair AT '|' INTO DATA(lv_txt_field) DATA(lv_num_field).
    READ TABLE lt_fcat ASSIGNING FIELD-SYMBOL(<ls_txt>) WITH KEY fieldname = lv_txt_field.
    CHECK sy-subrc = 0.
    READ TABLE lt_fcat ASSIGNING FIELD-SYMBOL(<ls_num>) WITH KEY fieldname = lv_num_field.
    CHECK sy-subrc = 0.
    <ls_num>-no_out  = <ls_txt>-no_out.
    <ls_num>-col_pos = <ls_txt>-col_pos.
    <ls_txt>-no_out  = abap_true.
  ENDLOOP.

  DATA(lo_result) = cl_salv_ex_util=>factory_result_data_table(
                      r_data         = REF #( gt_disp )
                      t_fieldcatalog = lt_fcat
                      t_sort         = lt_sort
                      t_filter       = lt_filt ).

  cl_salv_bs_lex=>export_from_result_data_table(
    EXPORTING
      is_format            = if_salv_bs_lex_format=>mc_format_xlsx
      ir_result_data_table = lo_result
    IMPORTING
      er_result_file       = lv_xml ).

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      default_extension = 'xlsx'
      default_file_name = |OEM_BOM_{ sy-datum }|
      file_filter       = 'Excel (*.xlsx)|*.xlsx|'
    CHANGING
      filename          = lv_name
      path              = lv_path
      fullpath          = lv_full
    EXCEPTIONS
      OTHERS            = 1 ).
  IF sy-subrc <> 0 OR lv_full IS INITIAL.
    RETURN.
  ENDIF.

  lv_len = xstrlen( lv_xml ).
  lt_bin = cl_bcs_convert=>xstring_to_solix( iv_xstring = lv_xml ).

  cl_gui_frontend_services=>gui_download(
    EXPORTING
      bin_filesize = lv_len
      filename     = lv_full
      filetype     = 'BIN'
    CHANGING
      data_tab     = lt_bin
    EXCEPTIONS
      OTHERS       = 1 ).
  IF sy-subrc = 0.
    MESSAGE |엑셀 파일이 저장되었습니다. ({ lv_full })| TYPE 'S'.
  ELSE.
    MESSAGE '엑셀 저장에 실패했습니다.' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
