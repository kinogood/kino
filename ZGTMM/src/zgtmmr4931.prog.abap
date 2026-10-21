*&---------------------------------------------------------------------*
*& Report ZGTMMR4931
*&---------------------------------------------------------------------*
*& 드럼라벨 꼬리표 수동 등록 (ZPPT0001)
*& - OEM 드럼라벨 정보(ZGTMMT9415) 기준으로 꼬리표 저장 정보를 조회하고,
*&   선택한 라인만 꼬리표(ZPPT0001)로 저장
*& - 배치/저장위치/자재문서는 입고 자재문서(ZGTMMT9415-MBLNR) 기준으로 설정,
*&   이후 311 재고이전(MIGO 등 수동 처리 포함)이 있으면 311 문서 기준으로 대체
*&---------------------------------------------------------------------*
*& 작성: 2026.09.15 ZGODEV04
*& 수정: 2026.09.22 ZGODEV04 - 구조 단순화: 311 조회 제거, 직접 입력 방식으로 변경
*& 수정: 2026.10.13 ZGODEV04 - ZGTMMT9415 조회 + ALV 라인 선택 저장 방식으로 변경
*&       311 재고 플랜트 꼬리표 저장, AUFNR 공백 꼬리표 교체 (ZGTMM_IF_I_DRGR_RCV 규칙)
*&       업데이트 체크 시에만 등록된 꼬리표 갱신, 미체크 시 오류
*&       수량은 ZGTMMT9415 라벨 수량, 배치는 라벨 연결 입고·311 전표에서 판별
*&       등록된 꼬리표는 ZPPT0001 값으로 표시, 전표값 적용 버튼
*&       배치 후보는 ZGTMMT9415 구매오더 품목의 입고·311 전표, 여러 개면 배치 F4로 선택
*&       꼬리표 등록 건 제외 체크박스
*&---------------------------------------------------------------------*
REPORT zgtmmr4931.

INCLUDE <icon>.

TABLES: ekpo, zgtmmt9415.

*----------------------------------------------------------------------*
* Types / Data
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_out,
    sel        TYPE c LENGTH 1,                 "선택
    status     TYPE icon_d,                     "상태
    msg        TYPE c LENGTH 80,                "메시지
    dr_labelno TYPE zgtmmt9415-dr_labelno,      "드럼라벨번호(=꼬리표번호)
    ebeln      TYPE ebeln,                      "구매오더
    ebelp      TYPE ebelp,                      "항번
    matnr      TYPE matnr,                      "자재
    txz01      TYPE txz01,                      "자재내역
    werks      TYPE werks_d,                    "플랜트 (구매오더)
    werks_tag  TYPE werks_d,                    "꼬리표 플랜트 (재고 플랜트, 저장값)
    charg      TYPE charg_d,                    "배치 (저장값)
    lgort      TYPE lgort_d,                    "저장위치 (저장값)
    mblnr      TYPE mblnr,                      "자재문서 (저장값)
    mjahr      TYPE mjahr,                      "자재문서 연도
    menge      TYPE menge_d,                    "수량 (저장값)
    meins      TYPE meins,                      "단위
    gr_mblnr   TYPE mblnr,                      "입고 자재문서(ZGTMMT9415)
    gr_mjahr   TYPE mjahr,
    mblnr_311  TYPE mblnr,                      "311 자재문서
    cpudt      TYPE cpudt,                      "기준 자재문서 입력일
    cputm      TYPE cputm,                      "기준 자재문서 입력시간
    erfmg      TYPE erfmg,                      "라벨 수량(ZGTMMT9415)
    erfme      TYPE erfme,
    dispo      TYPE dispo,                      "MRP 관리자
    pstyp      TYPE pstyp,                      "품목범주
    zifkey     TYPE zgteifkey,                  "인터페이스 키
    regflg     TYPE c LENGTH 1,                 "꼬리표 등록 여부
    src_werks  TYPE werks_d,                    "전표 기준 플랜트
    src_charg  TYPE charg_d,                    "전표 기준 배치
    src_lgort  TYPE lgort_d,                    "전표 기준 저장위치
    src_mblnr  TYPE mblnr,                      "전표 기준 자재문서
    src_mjahr  TYPE mjahr,
    reg_werks  TYPE werks_d,                    "등록 꼬리표 플랜트
    reg_aufnr  TYPE aufnr,                      "등록 꼬리표 오더(구매오더)
    reg_charg  TYPE charg_d,                    "등록 꼬리표 배치
    reg_mblnr  TYPE mblnr,                      "등록 꼬리표 자재문서
    reg_lgort  TYPE lgort_d,                    "등록 꼬리표 저장위치
    reg_giflg  TYPE zppt0001-giflg,             "등록 꼬리표 출고여부
    reg_mgvrg  TYPE zppt0001-mgvrg,             "등록 꼬리표 수량
    reg_remain TYPE zppt0001-remain,            "등록 꼬리표 잔량
    reg_meins  TYPE zppt0001-meins,             "등록 꼬리표 단위
    xerror     TYPE c LENGTH 1,                 "저장 불가
    xmulti     TYPE c LENGTH 1,                 "전표 내 배치 여러 개 - 선택 필요
  END OF ty_out,

  BEGIN OF ty_gr,                               "전표 입고측 라인 (입고·311)
    mblnr     TYPE mblnr,
    mjahr     TYPE mjahr,
    zeile     TYPE mblpo,
    bwart     TYPE bwart,
    werks     TYPE werks_d,
    ebeln     TYPE ebeln,
    ebelp     TYPE ebelp,
    matnr     TYPE matnr,
    charg_sid TYPE charg_d,
    lgort     TYPE lgort_d,
    menge     TYPE menge_d,
    meins     TYPE meins,
    erfmg     TYPE erfmg,
    sgtxt     TYPE sgtxt,
    cpudt     TYPE cpudt,
    cputm     TYPE cputm,
  END OF ty_gr,
  ty_t_gr TYPE STANDARD TABLE OF ty_gr WITH EMPTY KEY,

  BEGIN OF ty_cand,                             "라벨별 배치 후보 (라벨 연결 전표 라인)
    dr_labelno TYPE zgtmmt9415-dr_labelno,
    ebeln      TYPE ebeln,
    ebelp      TYPE ebelp,
    doc_line   TYPE ty_gr,
    used_tag   TYPE zppt0001-tagnr,             "이 배치를 사용 중인 다른 꼬리표
  END OF ty_cand,

  BEGIN OF ty_f4,                               "배치 선택 팝업
    no        TYPE numc3,
    charg     TYPE charg_d,
    tagnr     TYPE zppt0001-tagnr,              "사용 중인 다른 꼬리표
    mblnr     TYPE mblnr,
    mjahr     TYPE mjahr,
    zeile     TYPE mblpo,
    bwart     TYPE bwart,
    werks     TYPE werks_d,
    lgort     TYPE lgort_d,
    erfmg     TYPE erfmg,
    sgtxt     TYPE sgtxt,
    cpudt     TYPE cpudt,
  END OF ty_f4.

DATA:
  gt_out  TYPE STANDARD TABLE OF ty_out,
  gt_cand TYPE STANDARD TABLE OF ty_cand WITH EMPTY KEY,
  go_grid TYPE REF TO cl_gui_alv_grid.

CONSTANTS:
  gc_x TYPE c LENGTH 1 VALUE 'X',
  gc_y TYPE c LENGTH 1 VALUE 'Y',
  gc_n TYPE c LENGTH 1 VALUE 'N'.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE gv_t01.
  PARAMETERS:
    p_werks TYPE ekpo-werks OBLIGATORY.
  SELECT-OPTIONS:
    s_ebeln FOR ekpo-ebeln,
    s_ebelp FOR ekpo-ebelp,
    s_matnr FOR ekpo-matnr,
    s_label FOR zgtmmt9415-dr_labelno.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE gv_t02.
  PARAMETERS:
    p_excl AS CHECKBOX,                         "꼬리표 등록 건 제외
    p_upd  AS CHECKBOX.                         "업데이트 (등록된 꼬리표 갱신 허용)
SELECTION-SCREEN END OF BLOCK b02.

*----------------------------------------------------------------------*
* ALV 이벤트 처리
*----------------------------------------------------------------------*
CLASS lcl_event DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,
      on_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      on_f4 FOR EVENT onf4 OF cl_gui_alv_grid
        IMPORTING e_fieldname es_row_no er_event_data.
ENDCLASS.

CLASS lcl_event IMPLEMENTATION.
  METHOD on_toolbar.
    APPEND VALUE #( butn_type = 3 ) TO e_object->mt_toolbar.
    APPEND VALUE #( function = 'SALL' icon = icon_select_all
                    quickinfo = '전체선택' ) TO e_object->mt_toolbar.
    APPEND VALUE #( function = 'DALL' icon = icon_deselect_all
                    quickinfo = '선택해제' ) TO e_object->mt_toolbar.
    APPEND VALUE #( butn_type = 3 ) TO e_object->mt_toolbar.
    APPEND VALUE #( function = 'SRC' icon = icon_copy_object
                    text = '전표값 적용' quickinfo = '선택 라인에 전표 기준 배치·저장위치·자재문서·라벨수량 적용' ) TO e_object->mt_toolbar.
    APPEND VALUE #( function = 'SAVE' icon = icon_system_save
                    text = '꼬리표 저장' quickinfo = '선택 라인 꼬리표 저장' ) TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD on_user_command.
    go_grid->check_changed_data( ).

    CASE e_ucomm.
      WHEN 'SALL'.
        LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE xerror IS INITIAL.
          <ls_out>-sel = gc_x.
        ENDLOOP.
      WHEN 'DALL'.
        LOOP AT gt_out ASSIGNING <ls_out>.
          CLEAR <ls_out>-sel.
        ENDLOOP.
      WHEN 'SRC'.
        PERFORM f_apply_src.
      WHEN 'SAVE'.
        PERFORM f_save.
    ENDCASE.

    go_grid->refresh_table_display( is_stable = VALUE #( row = gc_x col = gc_x ) ).
  ENDMETHOD.

  METHOD on_f4.
*  배치 F4: 라벨 연결 전표 라인에서 선택
    er_event_data->m_event_handled = gc_x.
    CHECK e_fieldname = 'CHARG'.
    PERFORM f_f4_charg USING es_row_no-row_id.
    go_grid->refresh_table_display( is_stable = VALUE #( row = gc_x col = gc_x ) ).
  ENDMETHOD.
ENDCLASS.

*----------------------------------------------------------------------*
INITIALIZATION.
  gv_t01 = '조회 조건'.
  gv_t02 = '조회 옵션'.

AT SELECTION-SCREEN.
  CHECK sy-ucomm = 'ONLI'.
  IF s_ebeln[] IS INITIAL AND s_label[] IS INITIAL.
    MESSAGE '구매오더 또는 드럼라벨번호를 입력하세요.' TYPE 'E'.
  ENDIF.

*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_get_data.

  IF gt_out IS INITIAL.
    MESSAGE '조회된 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM f_display.

*&---------------------------------------------------------------------*
*& Form F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data.

  TYPES:
    BEGIN OF ty_doc,
      dr_labelno TYPE zgtmmt9415-dr_labelno,
      ebeln      TYPE ebeln,
      ebelp      TYPE ebelp,
      mblnr      TYPE mblnr,
      mjahr      TYPE mjahr,
    END OF ty_doc,
    BEGIN OF ty_mes,
      dr_label_no TYPE zgtmmt9423-dr_label_no,
      ebeln       TYPE zgtmmt9423-ebeln,
      ebelp       TYPE zgtmmt9423-ebelp,
    END OF ty_mes,
    BEGIN OF ty_bkey,
      matnr TYPE matnr,
      charg TYPE charg_d,
    END OF ty_bkey,
    BEGIN OF ty_aufnr,
      aufnr TYPE zppt0001-aufnr,
    END OF ty_aufnr.

  DATA:
    ls_out   TYPE ty_out,
    lt_doc   TYPE STANDARD TABLE OF ty_doc WITH EMPTY KEY,
    lt_mes   TYPE STANDARD TABLE OF ty_mes WITH EMPTY KEY,
    lt_line    TYPE ty_t_gr,
    lt_po_line TYPE ty_t_gr,
    lt_po_311  TYPE ty_t_gr,
    lt_all     TYPE ty_t_gr,
    lt_free    TYPE ty_t_gr,
    lt_bkey    TYPE STANDARD TABLE OF ty_bkey WITH EMPTY KEY,
    lt_aufnr   TYPE STANDARD TABLE OF ty_aufnr WITH EMPTY KEY,
    lv_used    TYPE zppt0001-tagnr,
    ls_sel   TYPE ty_gr,
    lv_charg TYPE charg_d,
    lv_deltx TYPE sgtxt,
    lv_multi TYPE c LENGTH 1.

  CLEAR: gt_out, gt_cand.

*1) OEM 드럼라벨 정보 (드럼라벨/구매오더/항번별 최종 수신 건)
  SELECT z~zifkey, z~ebeln, z~ebelp, z~dr_labelno,
         z~erfmg, z~erfme, z~mblnr, z~mjahr, z~status,
         p~matnr, p~txz01, p~werks, p~lgort, p~pstyp,
         c~dispo
    FROM zgtmmt9415 AS z
    INNER JOIN ekpo AS p
            ON p~ebeln = z~ebeln
           AND p~ebelp = z~ebelp
    INNER JOIN marc AS c
            ON c~matnr = p~matnr
           AND c~werks = p~werks
    WHERE z~ebeln      IN @s_ebeln
      AND z~ebelp      IN @s_ebelp
      AND z~dr_labelno IN @s_label
      AND p~werks      =  @p_werks
      AND p~matnr      IN @s_matnr
      AND p~loekz      =  @space
    INTO TABLE @DATA(lt_9415).

  SORT lt_9415 BY dr_labelno ebeln ebelp zifkey DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_9415 COMPARING dr_labelno ebeln ebelp.
  DELETE lt_9415 WHERE status = gc_x.   "삭제 라벨 제외
  CHECK lt_9415 IS NOT INITIAL.

*2) 라벨 연결 전표: ZGTMMT9415 입고문서 + MES 드럼라벨 입고 처리 결과(ZGTMMT9423, 입고·311)
  lt_doc = VALUE #( FOR ls_z IN lt_9415 WHERE ( mblnr IS NOT INITIAL )
                    ( dr_labelno = ls_z-dr_labelno ebeln = ls_z-ebeln ebelp = ls_z-ebelp
                      mblnr      = ls_z-mblnr      mjahr = ls_z-mjahr ) ).

*   MES 로그 테이블(ZGTMMT9422/9423)은 드럼라벨 CHAR17 - 조회 키 별도 구성
  lt_mes = VALUE #( FOR ls_z IN lt_9415
                    ( dr_label_no = ls_z-dr_labelno ebeln = ls_z-ebeln ebelp = ls_z-ebelp ) ).
  SORT lt_mes BY dr_label_no ebeln ebelp.
  DELETE ADJACENT DUPLICATES FROM lt_mes COMPARING ALL FIELDS.

  SELECT dr_label_no AS dr_labelno, ebeln, ebelp, mblnr, mjahr
    FROM zgtmmt9423
    FOR ALL ENTRIES IN @lt_mes
    WHERE dr_label_no = @lt_mes-dr_label_no
      AND ebeln       = @lt_mes-ebeln
      AND ebelp       = @lt_mes-ebelp
      AND mblnr       <> @space
    APPENDING CORRESPONDING FIELDS OF TABLE @lt_doc.

  SORT lt_doc BY dr_labelno ebeln ebelp mblnr mjahr.
  DELETE ADJACENT DUPLICATES FROM lt_doc COMPARING ALL FIELDS.

*   전표 내 라인 판별용: MES 수신 배치(ZGTMMT9422), 납품문서(ZGTMMT9425 - 적요 DELNO-DELITEM)
  SELECT zifkey, dr_label_no, ebeln, ebelp, charg
    FROM zgtmmt9422
    FOR ALL ENTRIES IN @lt_mes
    WHERE dr_label_no = @lt_mes-dr_label_no
      AND ebeln       = @lt_mes-ebeln
      AND ebelp       = @lt_mes-ebelp
    INTO TABLE @DATA(lt_9422).
  SORT lt_9422 BY dr_label_no ebeln ebelp zifkey DESCENDING.

  SELECT zifkey, dr_label_no, ebeln, ebelp, delno, delitem
    FROM zgtmmt9425
    FOR ALL ENTRIES IN @lt_9415
    WHERE dr_label_no = @lt_9415-dr_labelno
      AND ebeln       = @lt_9415-ebeln
      AND ebelp       = @lt_9415-ebelp
    INTO TABLE @DATA(lt_9425).
  SORT lt_9425 BY dr_label_no ebeln ebelp zifkey DESCENDING.

*   라벨 연결 전표의 입고측 라인 (취소·역분개 제외)
  IF lt_doc IS NOT INITIAL.
    SELECT mblnr, mjahr, zeile, bwart, werks, ebeln, ebelp, matnr, charg_sid,
           lgort, menge, meins, erfmg, sgtxt, cpudt, cputm
      FROM matdoc
      FOR ALL ENTRIES IN @lt_doc
      WHERE mblnr             = @lt_doc-mblnr
        AND mjahr             = @lt_doc-mjahr
        AND shkzg             = 'S'
        AND cancelled         = @space
        AND reversal_movement = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_line.
  ENDIF.

*   ZGTMMT9415 구매오더/항번의 입고 라인 (취소·역분개 제외, 배치 있는 건)
  SELECT mblnr, mjahr, zeile, bwart, werks, ebeln, ebelp, matnr, charg_sid,
         lgort, menge, meins, erfmg, sgtxt, cpudt, cputm
    FROM matdoc
    FOR ALL ENTRIES IN @lt_9415
    WHERE ebeln             = @lt_9415-ebeln
      AND ebelp             = @lt_9415-ebelp
      AND shkzg             = 'S'
      AND cancelled         = @space
      AND reversal_movement = @space
      AND charg_sid         <> @space
    INTO CORRESPONDING FIELDS OF TABLE @lt_po_line.

*   위 배치들의 311 재고이전 입고측 라인
  lt_bkey = VALUE #( FOR ls_b IN lt_line   WHERE ( charg_sid IS NOT INITIAL )
                     ( matnr = ls_b-matnr charg = ls_b-charg_sid ) ).
  lt_bkey = VALUE #( BASE lt_bkey FOR ls_b IN lt_po_line
                     ( matnr = ls_b-matnr charg = ls_b-charg_sid ) ).
  SORT lt_bkey BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_bkey COMPARING matnr charg.
  IF lt_bkey IS NOT INITIAL.
    SELECT mblnr, mjahr, zeile, bwart, werks, ebeln, ebelp, matnr, charg_sid,
           lgort, menge, meins, erfmg, sgtxt, cpudt, cputm
      FROM matdoc
      FOR ALL ENTRIES IN @lt_bkey
      WHERE matnr             = @lt_bkey-matnr
        AND charg_sid         = @lt_bkey-charg
        AND bwart             = '311'
        AND shkzg             = 'S'
        AND cancelled         = @space
        AND reversal_movement = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_po_311.
  ENDIF.

*   같은 구매오더의 다른 꼬리표가 사용 중인 배치
  lt_aufnr = VALUE #( FOR ls_z IN lt_9415 ( aufnr = ls_z-ebeln ) ).
  SORT lt_aufnr BY aufnr.
  DELETE ADJACENT DUPLICATES FROM lt_aufnr COMPARING aufnr.
  SELECT aufnr, tagnr, charg
    FROM zppt0001
    FOR ALL ENTRIES IN @lt_aufnr
    WHERE aufnr = @lt_aufnr-aufnr
    INTO TABLE @DATA(lt_used).
  SORT lt_used BY aufnr charg.

  LOOP AT lt_9415 INTO DATA(ls_9415).
    CLEAR ls_out.
    ls_out = CORRESPONDING #( ls_9415 EXCEPT status mblnr mjahr ).
    ls_out-gr_mblnr  = ls_9415-mblnr.
    ls_out-gr_mjahr  = ls_9415-mjahr.
    ls_out-werks_tag = ls_9415-werks.
*  수량은 ZGTMMT9415 라벨 수량
    ls_out-menge     = ls_9415-erfmg.
    ls_out-meins     = ls_9415-erfme.

    CLEAR: lv_charg, lv_deltx.
    READ TABLE lt_9422 INTO DATA(ls_9422)
      WITH KEY dr_label_no = ls_9415-dr_labelno ebeln = ls_9415-ebeln ebelp = ls_9415-ebelp
      BINARY SEARCH.
    IF sy-subrc = 0.
      lv_charg = ls_9422-charg.
    ENDIF.
    READ TABLE lt_9425 INTO DATA(ls_9425)
      WITH KEY dr_label_no = ls_9415-dr_labelno ebeln = ls_9415-ebeln ebelp = ls_9415-ebelp
      BINARY SEARCH.
    IF sy-subrc = 0.
      lv_deltx = |{ ls_9425-delno }-{ ls_9425-delitem }|.
    ENDIF.

*  배치 후보: 라벨 연결 전표 라인 + 구매오더/항번 입고 라인 + 그 배치의 311 라인 (같은 자재)
    CLEAR lt_all.
    LOOP AT lt_doc INTO DATA(ls_doc)
      WHERE dr_labelno = ls_9415-dr_labelno
        AND ebeln      = ls_9415-ebeln
        AND ebelp      = ls_9415-ebelp.
      LOOP AT lt_line INTO DATA(ls_l)
        WHERE mblnr = ls_doc-mblnr AND mjahr = ls_doc-mjahr AND matnr = ls_9415-matnr.
*      입고(PO 참조) 라인은 구매오더/항번 일치 건만
        CHECK ls_l-ebeln IS INITIAL
           OR ( ls_l-ebeln = ls_9415-ebeln AND ls_l-ebelp = ls_9415-ebelp ).
        APPEND ls_l TO lt_all.
      ENDLOOP.
    ENDLOOP.
    LOOP AT lt_po_line INTO ls_l
      WHERE ebeln = ls_9415-ebeln AND ebelp = ls_9415-ebelp AND matnr = ls_9415-matnr.
      APPEND ls_l TO lt_all.
    ENDLOOP.
    LOOP AT lt_po_311 INTO ls_l WHERE matnr = ls_9415-matnr.
      CHECK line_exists( lt_all[ charg_sid = ls_l-charg_sid ] ).
      APPEND ls_l TO lt_all.
    ENDLOOP.
    SORT lt_all BY mjahr mblnr zeile.
    DELETE ADJACENT DUPLICATES FROM lt_all COMPARING mjahr mblnr zeile.

*  다른 꼬리표가 사용 중인 배치 표시, 자동 선택 대상에서는 제외
    CLEAR lt_free.
    LOOP AT lt_all INTO ls_l.
      CLEAR lv_used.
      LOOP AT lt_used INTO DATA(ls_used)
        WHERE aufnr = ls_9415-ebeln AND charg = ls_l-charg_sid AND tagnr <> ls_9415-dr_labelno.
        lv_used = ls_used-tagnr.
        EXIT.
      ENDLOOP.
      APPEND VALUE #( dr_labelno = ls_9415-dr_labelno ebeln = ls_9415-ebeln
                      ebelp      = ls_9415-ebelp      doc_line = ls_l
                      used_tag   = lv_used ) TO gt_cand.
      IF lv_used IS INITIAL.
        APPEND ls_l TO lt_free.
      ENDIF.
    ENDLOOP.

    PERFORM f_pick_line USING lt_free ls_9415-dr_labelno lv_deltx lv_charg
                        CHANGING ls_sel lv_multi.
    ls_out-xmulti = lv_multi.

    IF ls_sel IS NOT INITIAL.
      ls_out-charg     = ls_sel-charg_sid.
      ls_out-lgort     = ls_sel-lgort.
      ls_out-werks_tag = ls_sel-werks.
      ls_out-mblnr     = ls_sel-mblnr.
      ls_out-mjahr     = ls_sel-mjahr.
      ls_out-cpudt     = ls_sel-cpudt.
      ls_out-cputm     = ls_sel-cputm.
      IF ls_sel-bwart = '311'.
        ls_out-mblnr_311 = ls_sel-mblnr.
      ENDIF.
    ENDIF.

    APPEND ls_out TO gt_out.
  ENDLOOP.

*3) 라벨 연결 전표 이후 같은 배치의 311 재고이전 (MIGO 등 수동 처리 포함, 취소 제외, 최종 건 기준)
*   311 입고측 자재문서의 플랜트를 꼬리표 플랜트로 사용 (ZGTMM_IF_I_DRGR_RCV 311 꼬리표 저장과 동일)
  DATA(lt_key) = gt_out.
  DELETE lt_key WHERE charg IS INITIAL.
  IF lt_key IS NOT INITIAL.
    SELECT mblnr, mjahr, zeile, werks, matnr, charg_sid, lgort, cpudt, cputm
      FROM matdoc
      FOR ALL ENTRIES IN @lt_key
      WHERE matnr             = @lt_key-matnr
        AND charg_sid         = @lt_key-charg
        AND bwart             = '311'
        AND shkzg             = 'S'
        AND cancelled         = @space
        AND reversal_movement = @space
      INTO TABLE @DATA(lt_311).
    SORT lt_311 BY matnr charg_sid cpudt DESCENDING cputm DESCENDING.

*  입고 이후(입력일시 기준) 처리된 최종 311 건
    LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE charg IS NOT INITIAL.
      READ TABLE lt_311 INTO DATA(ls_311)
        WITH KEY matnr = <ls_out>-matnr charg_sid = <ls_out>-charg BINARY SEARCH.
      IF sy-subrc = 0 AND ( ls_311-cpudt > <ls_out>-cpudt
                         OR ( ls_311-cpudt = <ls_out>-cpudt AND ls_311-cputm > <ls_out>-cputm ) ).
        <ls_out>-mblnr_311 = ls_311-mblnr.
        <ls_out>-mblnr     = ls_311-mblnr.
        <ls_out>-mjahr     = ls_311-mjahr.
        <ls_out>-lgort     = ls_311-lgort.
        <ls_out>-werks_tag = ls_311-werks.
      ENDIF.
    ENDLOOP.
  ENDIF.

*4) 꼬리표 등록 상태 - 등록된 꼬리표는 ZPPT0001 값으로 표시
  PERFORM f_read_registered USING gc_x.

*   꼬리표 등록 건 제외 (ZPPT0001에 꼬리표가 있는 라벨)
  IF p_excl = gc_x.
    DELETE gt_out WHERE regflg IS NOT INITIAL.
  ENDIF.

  SORT gt_out BY ebeln ebelp dr_labelno.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_PICK_LINE - 전표 내 라벨 라인 판별
*&  적요에 라벨번호 → 적요 = 납품문서-품목 → MES 수신 배치 → 전표 내 배치가 하나
*&  위로 판별되지 않고 후보 배치가 여러 개면 CV_MULTI = X (배치 F4로 선택)
*&---------------------------------------------------------------------*
FORM f_pick_line USING    it_cand  TYPE ty_t_gr
                          iv_label TYPE zgtmmt9415-dr_labelno
                          iv_deltx TYPE sgtxt
                          iv_charg TYPE charg_d
                 CHANGING cs_line  TYPE ty_gr
                          cv_multi TYPE c.

  CLEAR: cs_line, cv_multi.
  CHECK it_cand IS NOT INITIAL.

  LOOP AT it_cand INTO DATA(ls_cand) WHERE sgtxt CS iv_label.
    cs_line = ls_cand.
    RETURN.
  ENDLOOP.

  IF iv_deltx IS NOT INITIAL.
    LOOP AT it_cand INTO ls_cand WHERE sgtxt = iv_deltx.
      cs_line = ls_cand.
      RETURN.
    ENDLOOP.
  ENDIF.

  IF iv_charg IS NOT INITIAL.
    LOOP AT it_cand INTO ls_cand WHERE charg_sid = iv_charg.
      cs_line = ls_cand.
      RETURN.
    ENDLOOP.
  ENDIF.

*  후보 배치가 하나면 그 배치, 여러 개면 사용자 선택
  DATA(lt_batch) = it_cand.
  SORT lt_batch BY charg_sid.
  DELETE ADJACENT DUPLICATES FROM lt_batch COMPARING charg_sid.
  IF lines( lt_batch ) = 1.
    cs_line = it_cand[ 1 ].
  ELSE.
    cv_multi = gc_x.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_READ_REGISTERED - 꼬리표(ZPPT0001) 등록 상태 및 상태 설정
*&  - 꼬리표 플랜트(재고 플랜트) → 구매오더 플랜트 순으로 기존 꼬리표 조회
*&  - REGFLG: Y = 같은 구매오더로 등록, B = 오더 공백 꼬리표 존재, O = 다른 오더로 등록
*&  - IV_FILL = X: 전표 기준 값은 SRC_* 에 보관하고, 등록된 꼬리표는 화면 값을 ZPPT0001 값으로 표시
*&---------------------------------------------------------------------*
FORM f_read_registered USING iv_fill TYPE c.

  TYPES: BEGIN OF ty_tag,
           werks TYPE zppt0001-werks,
           tagnr TYPE zppt0001-tagnr,
         END OF ty_tag.
  DATA lt_tag TYPE STANDARD TABLE OF ty_tag.

  CHECK gt_out IS NOT INITIAL.

  LOOP AT gt_out INTO DATA(ls_key).
    APPEND VALUE #( werks = ls_key-werks_tag tagnr = ls_key-dr_labelno ) TO lt_tag.
    APPEND VALUE #( werks = ls_key-werks     tagnr = ls_key-dr_labelno ) TO lt_tag.
  ENDLOOP.
  SORT lt_tag BY werks tagnr.
  DELETE ADJACENT DUPLICATES FROM lt_tag COMPARING werks tagnr.

  SELECT werks, aufnr, tagnr, charg, mblnr, lgort, giflg, mgvrg, remain, meins
    FROM zppt0001
    FOR ALL ENTRIES IN @lt_tag
    WHERE werks = @lt_tag-werks
      AND tagnr = @lt_tag-tagnr
    INTO TABLE @DATA(lt_reg).
  SORT lt_reg BY tagnr werks aufnr.

  LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<ls_out>).
    CLEAR: <ls_out>-regflg, <ls_out>-reg_werks, <ls_out>-reg_aufnr, <ls_out>-reg_charg,
           <ls_out>-reg_mblnr, <ls_out>-reg_lgort, <ls_out>-reg_giflg, <ls_out>-reg_mgvrg,
           <ls_out>-reg_remain, <ls_out>-reg_meins.

*  표시 우선순위: 다른 오더 등록(저장 불가) → 같은 구매오더 → 오더 공백
    DATA(lv_prio) = 0.
    LOOP AT lt_reg INTO DATA(ls_reg)
      WHERE tagnr = <ls_out>-dr_labelno
        AND ( werks = <ls_out>-werks_tag OR werks = <ls_out>-werks ).
      DATA(lv_flag) = COND char1( WHEN ls_reg-aufnr IS INITIAL       THEN 'B'
                                  WHEN ls_reg-aufnr = <ls_out>-ebeln THEN gc_y
                                  ELSE 'O' ).
      DATA(lv_p) = SWITCH i( lv_flag WHEN 'O' THEN 3 WHEN gc_y THEN 2 ELSE 1 ).
      IF lv_p > lv_prio OR ( lv_p = lv_prio AND ls_reg-werks = <ls_out>-werks_tag ).
        lv_prio = lv_p.
        <ls_out>-regflg     = lv_flag.
        <ls_out>-reg_werks  = ls_reg-werks.
        <ls_out>-reg_aufnr  = ls_reg-aufnr.
        <ls_out>-reg_charg  = ls_reg-charg.
        <ls_out>-reg_mblnr  = ls_reg-mblnr.
        <ls_out>-reg_lgort  = ls_reg-lgort.
        <ls_out>-reg_giflg  = ls_reg-giflg.
        <ls_out>-reg_mgvrg  = ls_reg-mgvrg.
        <ls_out>-reg_remain = ls_reg-remain.
        <ls_out>-reg_meins  = ls_reg-meins.
      ENDIF.
    ENDLOOP.

    IF iv_fill = gc_x.
      <ls_out>-src_werks = <ls_out>-werks_tag.
      <ls_out>-src_charg = <ls_out>-charg.
      <ls_out>-src_lgort = <ls_out>-lgort.
      <ls_out>-src_mblnr = <ls_out>-mblnr.
      <ls_out>-src_mjahr = <ls_out>-mjahr.

      IF <ls_out>-regflg IS NOT INITIAL.
        <ls_out>-werks_tag = <ls_out>-reg_werks.
        <ls_out>-charg     = <ls_out>-reg_charg.
        <ls_out>-lgort     = <ls_out>-reg_lgort.
        <ls_out>-mblnr     = <ls_out>-reg_mblnr.
        <ls_out>-mjahr     = COND #( WHEN <ls_out>-reg_mblnr = <ls_out>-src_mblnr
                                     THEN <ls_out>-src_mjahr ).
        <ls_out>-menge     = <ls_out>-reg_mgvrg.
        <ls_out>-meins     = <ls_out>-reg_meins.
      ENDIF.
    ENDIF.

    PERFORM f_set_status CHANGING <ls_out>.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_STATUS
*&  - 등록된 꼬리표는 업데이트(P_UPD) 체크 시에만 저장 가능
*&---------------------------------------------------------------------*
FORM f_set_status CHANGING cs_out TYPE ty_out.

  CLEAR: cs_out-xerror, cs_out-msg.

  IF cs_out-regflg IS NOT INITIAL AND p_upd IS INITIAL.
    cs_out-xerror = gc_x.
    cs_out-msg    = '등록된 꼬리표 - 업데이트 체크 후 조회해야 저장 가능'.
  ELSEIF cs_out-reg_aufnr IS NOT INITIAL
     AND ( cs_out-reg_giflg <> gc_n OR cs_out-reg_remain <> cs_out-reg_mgvrg ).
    cs_out-xerror = gc_x.
    cs_out-msg    = '출고/사용 이력이 있는 꼬리표 - 변경 불가'.
  ELSEIF cs_out-lgort = '3497' OR cs_out-lgort = '3498'.
    cs_out-xerror = gc_x.
    cs_out-msg    = '저장위치 3497/3498은 꼬리표 미생성 대상'.
  ENDIF.

  IF cs_out-xerror = gc_x.
    cs_out-status = icon_led_red.
    CLEAR cs_out-sel.
  ELSEIF cs_out-charg IS INITIAL OR cs_out-mblnr IS INITIAL.
    cs_out-status = icon_led_yellow.
    cs_out-msg    = COND #( WHEN cs_out-xmulti = gc_x AND cs_out-charg IS INITIAL
                            THEN '후보 배치 여러 개 - 배치 칸 F4로 선택'
                            ELSE '배치/자재문서 확인 필요 (배치 F4 선택 또는 직접 입력)' ).
  ELSEIF cs_out-regflg IS NOT INITIAL.
    cs_out-status = icon_led_green.
    cs_out-msg    = SWITCH #( cs_out-regflg
                      WHEN 'O' THEN |다른 오더({ cs_out-reg_aufnr ALPHA = OUT }) 꼬리표 - 오더 유지, 값 갱신|
                      WHEN 'B' THEN |오더 공백 꼬리표 - 구매오더로 교체|
                      ELSE COND #( WHEN cs_out-reg_werks <> cs_out-werks_tag
                                   THEN |등록됨 - 꼬리표 플랜트로 이관, 값 갱신|
                                   ELSE |등록됨 - 값 갱신| ) ).
  ELSE.
    cs_out-status = icon_led_inactive.
    cs_out-msg    = '미등록'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY
*&---------------------------------------------------------------------*
FORM f_display.

  DATA lt_fcat TYPE lvc_t_fcat.

  IF go_grid IS BOUND.
    go_grid->free( ).
    CLEAR go_grid.
  ENDIF.

  go_grid = NEW #( i_parent = cl_gui_container=>default_screen ).

  PERFORM f_fieldcat CHANGING lt_fcat.

  SET HANDLER lcl_event=>on_toolbar      FOR go_grid.
  SET HANDLER lcl_event=>on_user_command FOR go_grid.
  SET HANDLER lcl_event=>on_f4           FOR go_grid.

  go_grid->register_f4_for_fields( VALUE #( ( fieldname = 'CHARG' register = gc_x
                                              getbefore = gc_x chngeafter = gc_x ) ) ).

  go_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).

  go_grid->set_table_for_first_display(
    EXPORTING
      is_layout       = VALUE lvc_s_layo( zebra = gc_x cwidth_opt = gc_x sel_mode = 'A'
                                          grid_title = 'OEM 드럼라벨 꼬리표 등록 (ZGTMMT9415 → ZPPT0001)' )
      i_save          = 'A'
    CHANGING
      it_outtab       = gt_out
      it_fieldcatalog = lt_fcat ).

  go_grid->set_ready_for_input( 1 ).

  WRITE space.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_fieldcat CHANGING ct_fcat TYPE lvc_t_fcat.

  TYPES: BEGIN OF ty_col,
           fieldname TYPE lvc_fname,
           coltext   TYPE lvc_txtcol,
           edit      TYPE c LENGTH 1,
         END OF ty_col.
  DATA lt_col TYPE STANDARD TABLE OF ty_col WITH EMPTY KEY.

*  내부 테이블 구조 기준 필드카탈로그 생성
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_salv)
                              CHANGING  t_table      = gt_out ).
      ct_fcat = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
                  r_columns      = lo_salv->get_columns( )
                  r_aggregations = lo_salv->get_aggregations( ) ).
    CATCH cx_salv_msg.
      RETURN.
  ENDTRY.

*  출력 컬럼 (순서·헤더·편집 여부)
  lt_col = VALUE #(
    ( fieldname = 'SEL'        coltext = '선택'           edit = gc_x )
    ( fieldname = 'STATUS'     coltext = '상태' )
    ( fieldname = 'MSG'        coltext = '메시지' )
    ( fieldname = 'DR_LABELNO' coltext = '드럼라벨(꼬리표)' )
    ( fieldname = 'EBELN'      coltext = '구매오더' )
    ( fieldname = 'EBELP'      coltext = '항번' )
    ( fieldname = 'MATNR'      coltext = '자재' )
    ( fieldname = 'TXZ01'      coltext = '자재내역' )
    ( fieldname = 'WERKS'      coltext = 'PO플랜트' )
    ( fieldname = 'WERKS_TAG'  coltext = '꼬리표플랜트' )
    ( fieldname = 'CHARG'      coltext = '배치'           edit = gc_x )
    ( fieldname = 'LGORT'      coltext = '저장위치'       edit = gc_x )
    ( fieldname = 'MBLNR'      coltext = '자재문서'       edit = gc_x )
    ( fieldname = 'MJAHR'      coltext = '문서연도'       edit = gc_x )
    ( fieldname = 'MENGE'      coltext = '수량'           edit = gc_x )
    ( fieldname = 'MEINS'      coltext = '단위' )
    ( fieldname = 'SRC_WERKS'  coltext = '전표플랜트' )
    ( fieldname = 'SRC_CHARG'  coltext = '전표배치' )
    ( fieldname = 'SRC_LGORT'  coltext = '전표저장위치' )
    ( fieldname = 'SRC_MBLNR'  coltext = '전표자재문서' )
    ( fieldname = 'GR_MBLNR'   coltext = '입고문서(라벨)' )
    ( fieldname = 'MBLNR_311'  coltext = '311문서' )
    ( fieldname = 'ERFMG'      coltext = '라벨수량' )
    ( fieldname = 'ERFME'      coltext = '라벨단위' )
    ( fieldname = 'REGFLG'     coltext = '등록' )
    ( fieldname = 'REG_AUFNR'  coltext = '등록오더' )
    ( fieldname = 'REG_GIFLG'  coltext = '출고여부' )
    ( fieldname = 'REG_REMAIN' coltext = '등록잔량' ) ).

  LOOP AT ct_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    READ TABLE lt_col INTO DATA(ls_col) WITH KEY fieldname = <ls_fcat>-fieldname.
    IF sy-subrc <> 0.
      <ls_fcat>-no_out = gc_x.
      <ls_fcat>-tech   = gc_x.
      CONTINUE.
    ENDIF.

    <ls_fcat>-col_pos   = sy-tabix.
    <ls_fcat>-coltext   = ls_col-coltext.
    <ls_fcat>-scrtext_l = <ls_fcat>-scrtext_m = <ls_fcat>-scrtext_s = ls_col-coltext.
    <ls_fcat>-edit      = ls_col-edit.

    CASE <ls_fcat>-fieldname.
      WHEN 'SEL'.
        <ls_fcat>-checkbox = gc_x.
        <ls_fcat>-key      = gc_x.
      WHEN 'STATUS'.
        <ls_fcat>-icon     = gc_x.
        <ls_fcat>-key      = gc_x.
      WHEN 'DR_LABELNO'.
        <ls_fcat>-key      = gc_x.
      WHEN 'CHARG'.
        <ls_fcat>-f4availabl = gc_x.
      WHEN 'MENGE'.
        <ls_fcat>-qfieldname = 'MEINS'.
      WHEN 'ERFMG'.
        <ls_fcat>-qfieldname = 'ERFME'.
    ENDCASE.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_F4_CHARG - 배치 F4: 구매오더 품목 입고·311 전표 라인 중 선택
*&  선택한 라인의 배치·자재문서·저장위치·플랜트를 저장값과 전표 기준 값에 반영
*&---------------------------------------------------------------------*
FORM f_f4_charg USING iv_row TYPE int4.

  DATA:
    lt_f4  TYPE STANDARD TABLE OF ty_f4 WITH EMPTY KEY,
    lt_ret TYPE STANDARD TABLE OF ddshretval.

  READ TABLE gt_out ASSIGNING FIELD-SYMBOL(<ls_out>) INDEX iv_row.
  CHECK sy-subrc = 0.

  LOOP AT gt_cand INTO DATA(ls_cand)
    WHERE dr_labelno = <ls_out>-dr_labelno
      AND ebeln      = <ls_out>-ebeln
      AND ebelp      = <ls_out>-ebelp.
    APPEND VALUE #( charg = ls_cand-doc_line-charg_sid
                    tagnr = ls_cand-used_tag
                    mblnr = ls_cand-doc_line-mblnr
                    mjahr = ls_cand-doc_line-mjahr
                    zeile = ls_cand-doc_line-zeile
                    bwart = ls_cand-doc_line-bwart
                    werks = ls_cand-doc_line-werks
                    lgort = ls_cand-doc_line-lgort
                    erfmg = ls_cand-doc_line-erfmg
                    sgtxt = ls_cand-doc_line-sgtxt
                    cpudt = ls_cand-doc_line-cpudt ) TO lt_f4.
  ENDLOOP.

  IF lt_f4 IS INITIAL.
    MESSAGE '구매오더 품목의 입고/311 전표가 없습니다. 배치를 직접 입력하세요.' TYPE 'S' DISPLAY LIKE 'W'.
    RETURN.
  ENDIF.

*  다른 꼬리표가 사용하지 않는 배치 먼저, 입력일 최신 순
  SORT lt_f4 BY tagnr cpudt DESCENDING mblnr DESCENDING.
  LOOP AT lt_f4 ASSIGNING FIELD-SYMBOL(<ls_f4>).
    <ls_f4>-no = sy-tabix.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'NO'
      value_org       = 'S'
      window_title    = '배치 선택 (구매오더 품목 입고/311 전표)'
    TABLES
      value_tab       = lt_f4
      return_tab      = lt_ret
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  CHECK sy-subrc = 0.

  READ TABLE lt_ret INTO DATA(ls_ret) INDEX 1.
  CHECK sy-subrc = 0.
  READ TABLE lt_f4 INTO DATA(ls_f4) WITH KEY no = CONV numc3( ls_ret-fieldval ).
  CHECK sy-subrc = 0.

  <ls_out>-charg     = ls_f4-charg.
  <ls_out>-mblnr     = ls_f4-mblnr.
  <ls_out>-mjahr     = ls_f4-mjahr.
  <ls_out>-lgort     = ls_f4-lgort.
  <ls_out>-werks_tag = ls_f4-werks.
  <ls_out>-mblnr_311 = COND #( WHEN ls_f4-bwart = '311' THEN ls_f4-mblnr ).
  <ls_out>-src_charg = ls_f4-charg.
  <ls_out>-src_mblnr = ls_f4-mblnr.
  <ls_out>-src_mjahr = ls_f4-mjahr.
  <ls_out>-src_lgort = ls_f4-lgort.
  <ls_out>-src_werks = ls_f4-werks.
  PERFORM f_set_status CHANGING <ls_out>.

  IF ls_f4-tagnr IS NOT INITIAL.
    MESSAGE |배치 { ls_f4-charg }는 다른 꼬리표({ ls_f4-tagnr })가 사용 중입니다.| TYPE 'S' DISPLAY LIKE 'W'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_APPLY_SRC - 선택 라인에 전표 기준 값·라벨 수량 적용
*&---------------------------------------------------------------------*
FORM f_apply_src.

  LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = gc_x.
    <ls_out>-werks_tag = COND #( WHEN <ls_out>-src_werks IS NOT INITIAL
                                 THEN <ls_out>-src_werks ELSE <ls_out>-werks ).
    <ls_out>-charg     = <ls_out>-src_charg.
    <ls_out>-lgort     = <ls_out>-src_lgort.
    <ls_out>-mblnr     = <ls_out>-src_mblnr.
    <ls_out>-mjahr     = <ls_out>-src_mjahr.
    <ls_out>-menge     = <ls_out>-erfmg.
    <ls_out>-meins     = <ls_out>-erfme.
    PERFORM f_set_status CHANGING <ls_out>.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SAVE - 선택 라인 꼬리표(ZPPT0001) 저장
*&---------------------------------------------------------------------*
FORM f_save.

  DATA:
    ls_pp     TYPE zppt0001,
    lv_answer TYPE c LENGTH 1,
    lv_block  TYPE c LENGTH 1,
    lv_prio   TYPE i,
    lv_dtype  TYPE c LENGTH 1,
    lv_ok     TYPE i,
    lv_err    TYPE i.

  IF NOT line_exists( gt_out[ sel = gc_x ] ).
    MESSAGE '저장할 라인을 선택하세요.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '꼬리표 저장'
      text_question         = '선택한 라인을 꼬리표(ZPPT0001)로 저장하시겠습니까?'
      text_button_1         = '저장'
      text_button_2         = '취소'
      display_cancel_button = space
    IMPORTING
      answer                = lv_answer
    EXCEPTIONS
      OTHERS                = 1.
  CHECK sy-subrc = 0 AND lv_answer = '1'.

  LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<ls_out>) WHERE sel = gc_x.

*1) 입력값 점검
    PERFORM f_set_status CHANGING <ls_out>.
    IF <ls_out>-xerror = gc_x.
      lv_err += 1.
      CONTINUE.
    ENDIF.

    IF <ls_out>-charg IS INITIAL OR <ls_out>-lgort IS INITIAL
    OR <ls_out>-mblnr IS INITIAL OR <ls_out>-menge <= 0.
      <ls_out>-status = icon_led_red.
      <ls_out>-msg    = '배치/저장위치/자재문서/수량은 필수'.
      lv_err += 1.
      CONTINUE.
    ENDIF.

    SELECT SINGLE @abap_true
      FROM mcha
      WHERE matnr = @<ls_out>-matnr
        AND werks = @<ls_out>-werks_tag
        AND charg = @<ls_out>-charg
      INTO @DATA(lv_exist).
    IF sy-subrc <> 0.
      <ls_out>-status = icon_led_red.
      <ls_out>-msg    = |배치 { <ls_out>-charg }가 자재/꼬리표 플랜트에 존재하지 않음|.
      lv_err += 1.
      CONTINUE.
    ENDIF.

*2) 기존 꼬리표 재확인 - 꼬리표 플랜트 + 구매오더 플랜트
*   등록된 꼬리표는 업데이트(P_UPD) 체크 시에만 저장, 출고·사용 이력 있으면 저장 불가
    SELECT *
      FROM zppt0001
      WHERE tagnr = @<ls_out>-dr_labelno
        AND ( werks = @<ls_out>-werks_tag OR werks = @<ls_out>-werks )
      INTO TABLE @DATA(lt_old).

    IF lt_old IS NOT INITIAL AND p_upd IS INITIAL.
      <ls_out>-status = icon_led_red.
      <ls_out>-msg    = '등록된 꼬리표 - 업데이트 체크 후 조회해야 저장 가능'.
      lv_err += 1.
      CONTINUE.
    ENDIF.

*   갱신 기준 행: 같은 구매오더 → 다른 오더 순, 같은 순위면 꼬리표 플랜트 건 (오더 공백 행은 교체 대상)
    CLEAR: ls_pp, lv_block, lv_prio.
    LOOP AT lt_old INTO DATA(ls_old) WHERE aufnr IS NOT INITIAL.
      IF ls_old-giflg <> gc_n OR ls_old-remain <> ls_old-mgvrg.
        lv_block = gc_x.
        <ls_out>-msg = '출고/사용 이력이 있는 꼬리표 - 변경 불가'.
        EXIT.
      ENDIF.
      DATA(lv_p) = COND i( WHEN ls_old-aufnr = <ls_out>-ebeln THEN 10 ELSE 0 )
                 + COND i( WHEN ls_old-werks = <ls_out>-werks_tag THEN 1 ELSE 0 ).
      IF lv_p >= lv_prio.
        lv_prio = lv_p.
        ls_pp   = ls_old.
      ENDIF.
    ENDLOOP.
    IF lv_block = gc_x.
      <ls_out>-status = icon_led_red.
      lv_err += 1.
      CONTINUE.
    ENDIF.

*3) 꼬리표 저장
    IF ls_pp IS NOT INITIAL.
*    기존 꼬리표 갱신 - 오더(AUFNR) 유지, ZGTMM_IF_I_DRGR_RCV 갱신 항목과 동일
      ls_pp-werks   = <ls_out>-werks_tag.
      ls_pp-posnr   = <ls_out>-ebelp.
      ls_pp-charg   = <ls_out>-charg.
      ls_pp-mblnr   = <ls_out>-mblnr.
      ls_pp-mgvrg   = <ls_out>-menge.
      ls_pp-remain  = <ls_out>-menge.
      ls_pp-grflg   = gc_y.
      ls_pp-lgort   = <ls_out>-lgort.
      ls_pp-grindat = sy-datum.
      ls_pp-grintim = sy-uzeit.
      ls_pp-grinnam = sy-uname.
    ELSE.
*    신규 (오더 공백 꼬리표는 구매오더 꼬리표로 교체)
      ls_pp = VALUE #( werks   = <ls_out>-werks_tag
                       aufnr   = <ls_out>-ebeln
                       tagnr   = <ls_out>-dr_labelno
                       posnr   = <ls_out>-ebelp
                       charg   = <ls_out>-charg
                       mblnr   = <ls_out>-mblnr
                       matnr   = <ls_out>-matnr
                       spgcd   = <ls_out>-dispo(2)
                       mgvrg   = <ls_out>-menge
                       fostcnt = 1
                       remain  = <ls_out>-menge
                       meins   = <ls_out>-meins
                       outflg  = COND #( WHEN <ls_out>-pstyp = '3' THEN gc_x ELSE space )
                       giflg   = gc_n
                       grflg   = gc_y
                       inspflg = 'OK'
                       lgort   = <ls_out>-lgort
                       grindat = sy-datum
                       grintim = sy-uzeit
                       grinnam = sy-uname ).
    ENDIF.

*   저장 행과 키가 다른 기존 행(오더 공백 꼬리표, 다른 플랜트 꼬리표)은 삭제 후 저장
    DELETE lt_old WHERE werks = ls_pp-werks AND aufnr = ls_pp-aufnr AND tagnr = ls_pp-tagnr
                    AND rueck = ls_pp-rueck AND rmzhl = ls_pp-rmzhl.
    IF lt_old IS NOT INITIAL.
      DELETE zppt0001 FROM TABLE @lt_old.
    ENDIF.

    MODIFY zppt0001 FROM @ls_pp.
    IF sy-subrc = 0.
      lv_ok += 1.
      CLEAR <ls_out>-sel.
    ELSE.
      <ls_out>-status = icon_led_red.
      <ls_out>-msg    = '꼬리표 저장 실패'.
      lv_err += 1.
    ENDIF.
  ENDLOOP.

  IF lv_ok > 0.
    COMMIT WORK AND WAIT.

*  저장 결과 반영 (오류 라인 메시지는 유지)
    DATA(lt_err) = gt_out.
    DELETE lt_err WHERE sel IS INITIAL.
    PERFORM f_read_registered USING space.
    LOOP AT lt_err INTO DATA(ls_err).
      READ TABLE gt_out ASSIGNING <ls_out>
        WITH KEY dr_labelno = ls_err-dr_labelno ebeln = ls_err-ebeln ebelp = ls_err-ebelp.
      IF sy-subrc = 0.
        <ls_out>-status = ls_err-status.
        <ls_out>-msg    = ls_err-msg.
      ENDIF.
    ENDLOOP.
  ENDIF.

  lv_dtype = COND #( WHEN lv_err > 0 THEN 'W' ELSE 'S' ).
  MESSAGE |꼬리표 저장 완료 { lv_ok }건, 오류 { lv_err }건| TYPE 'S' DISPLAY LIKE lv_dtype.

ENDFORM.
