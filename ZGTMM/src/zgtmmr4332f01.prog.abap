*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR4332F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM INITIALIZATION
*&  선택화면 초기값: 블록 제목/라벨, 플랜트 = 6500, 납품일자 = 당월 1일 ~ 오늘
*&---------------------------------------------------------------------*
FORM initialization.

  " 블록 제목 / 라디오·체크박스 라벨
  tb0  = '조회 모드'.
  tb1  = '조회 조건'.
  tb2  = '납품서 유형'.
  tb3  = '입고 상태'.
  cmm2 = '납품 문서별 입고/이전전기 대사'.
  cmm3 = '납품 문서별 상세 조회 (배치/꼬리표)'.
  cs_chg = '배치번호'.
  cs_lbl = '드럼라벨번호'.
  cmt1 = '납품 명세서'.         "INV (DELTYPE 공백)
  cmt2 = '매입보관품(A)'.   "IVS-A
  cmt3 = '매출보관품(B)'.   "IVS-B
  cxc1 = '삭제(취소) 납품서 제외'.
  cxc2 = '종결 납품서 제외'.
  cms1 = '전체'.
  cms2 = '미입고'.              "미입고/미확정/오류
  cms3 = '부분입고'.
  cms4 = '입고완료'.
  cms5 = '초과입고'.
  cms6 = '점검대상(중복/초과/오류/취소후입고)'.

  " 플랜트 기본값: 6500
  s_werks-sign   = 'I'.
  s_werks-option = 'EQ'.
  s_werks-low    = '6500'.
  APPEND s_werks.

  " 납품일자 기본값: 당월 1일 ~ 오늘
  s_budat-sign   = 'I'.
  s_budat-option = 'BT'.
  s_budat-low    = sy-datum.
  s_budat-low+6(2) = '01'.
  s_budat-high   = sy-datum.
  APPEND s_budat.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SCREEN_OUTPUT
*&  점검대상 조건은 지정 계정(ZLSGMM5)에게만 표시
*&---------------------------------------------------------------------*
FORM screen_output.

  CHECK sy-uname <> gc_chk_user.

  LOOP AT SCREEN.
    IF screen-name = 'P_CHK' OR screen-name = 'CMS6'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
  CLEAR p_chk.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM TYPE_CHANGE
*&  납품서 유형 체크 즉시 반영: 납품 명세서 <-> 매입/매출보관품은 동시에 선택 불가
*&  (나중에 체크한 쪽이 우선, 반대쪽은 자동 해제)
*&---------------------------------------------------------------------*
FORM type_change.

  CASE sy-ucomm.
    WHEN 'UIN'.
      IF p_inv = gc_x.
        CLEAR: p_ivsa, p_ivsb.
      ENDIF.
    WHEN 'UIA' OR 'UIB'.
      IF p_ivsa = gc_x OR p_ivsb = gc_x.
        CLEAR p_inv.
      ENDIF.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM ADD_KEEP_WERKS
*&  매입보관품(A)/매출보관품(B) 선택 시 보관 플랜트(6591, 6691)를 조회 조건에 추가
*&---------------------------------------------------------------------*
FORM add_keep_werks.

  DATA lt_keep TYPE STANDARD TABLE OF t001w-werks WITH DEFAULT KEY.

  CHECK p_ivsa = gc_x OR p_ivsb = gc_x.

  lt_keep = VALUE #( ( '6591' ) ( '6691' ) ).
  LOOP AT lt_keep ASSIGNING FIELD-SYMBOL(<lv_keep>).
    IF s_werks[] IS NOT INITIAL AND <lv_keep> NOT IN s_werks.
      s_werks-sign   = 'I'.
      s_werks-option = 'EQ'.
      s_werks-low    = <lv_keep>.
      CLEAR s_werks-high.
      APPEND s_werks.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
FORM check_auth.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD p_bukrs.
  IF sy-subrc <> 0.
    SET CURSOR FIELD 'P_BUKRS'.
    MESSAGE e172 WITH p_bukrs. "회사코드[&] 작업권한을 확인하세요.
  ENDIF.

  " 선택된 플랜트 전체에 대해 권한 체크
  SELECT werks FROM t001w
    WHERE werks IN @s_werks
    INTO TABLE @DATA(lt_werks).
  LOOP AT lt_werks ASSIGNING FIELD-SYMBOL(<ls_werks>).
    AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                 ID 'WERKS' FIELD <ls_werks>-werks.
    IF sy-subrc <> 0.
      SET CURSOR FIELD 'S_WERKS-LOW'.
      MESSAGE e106 WITH <ls_werks>-werks. "플랜트[&] 작업권한을 확인하세요.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_INPUT
*&---------------------------------------------------------------------*
FORM check_input.

  " 체크박스 변경 이벤트(유형 선택 중)에서는 검증하지 않음
  CHECK sy-ucomm <> 'UIN' AND sy-ucomm <> 'UIA' AND sy-ucomm <> 'UIB'.

  IF p_inv IS INITIAL AND p_ivsa IS INITIAL AND p_ivsb IS INITIAL.
    MESSAGE '납품서 유형을 하나 이상 선택하세요.' TYPE 'E'.
  ENDIF.

  " 납품 명세서(INV)와 매입/매출보관품(IVS)은 화면 구성이 달라 동시에 조회하지 않음
  IF p_inv = gc_x AND ( p_ivsa = gc_x OR p_ivsb = gc_x ).
    SET CURSOR FIELD 'P_INV'.
    MESSAGE '납품 명세서와 매입/매출보관품은 동시에 선택할 수 없습니다.' TYPE 'E'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SELECT_DATA
*&  납품서 품목 기준 + 101/311 입고 집계 + PO/SO/업체/자재 정보
*&---------------------------------------------------------------------*
FORM select_data.

  CLEAR: gt_item, gt_doc, gt_sum.

  SELECT b~delno, b~delitem, b~werks, b~lgort, b~budat, b~deltype,
         b~ebeln, b~ebelp, b~menge AS delqty, p~menge AS poqty, b~meins,
         b~delclose, b~cancelled,
         k~lifnr, l~name1, p~matnr, m~maktx,
         n~vbeln AS vbeln_po, n~vbelp AS posnr_po,
         s~grqty AS grqty_std, s~doccnt AS doccnt_std,
         s~first_budat AS first_std, s~last_budat AS last_std,
         s~so_gr AS so_std, s~soitm_gr AS soitm_std,
         t~grqty AS grqty_stk, t~lblcnt, t~doccnt AS doccnt_stk,
         t~first_budat AS first_stk, t~last_budat AS last_stk,
         t~so_gr AS so_stk, t~soitm_gr AS soitm_stk
    FROM zgtmm_cv_deliv_base AS b
    LEFT OUTER JOIN ekko AS k
      ON k~ebeln = b~ebeln
    LEFT OUTER JOIN ekpo AS p
      ON p~ebeln = b~ebeln
     AND p~ebelp = b~ebelp
    LEFT OUTER JOIN ekkn AS n
      ON n~ebeln = b~ebeln
     AND n~ebelp = b~ebelp
     AND n~zekkn = '01'
    LEFT OUTER JOIN lfa1 AS l
      ON l~lifnr = k~lifnr
    LEFT OUTER JOIN makt AS m
      ON m~matnr = p~matnr
     AND m~spras = @sy-langu
    LEFT OUTER JOIN zgtmm_cv_deliv_gr_101 AS s
      ON s~delno   = b~delno
     AND s~delitem = b~delitem
    LEFT OUTER JOIN zgtmm_cv_deliv_gr_311 AS t
      ON t~delno   = b~delno
     AND t~delitem = b~delitem
    WHERE b~werks  IN @s_werks
      AND b~budat  IN @s_budat
      AND b~delno  IN @s_delno
      AND b~ebeln  IN @s_ebeln
      AND k~lifnr  IN @s_lifnr
      AND p~matnr  IN @s_matnr
      AND n~vbeln  IN @s_vbeln
      AND ( k~bukrs = @p_bukrs OR k~ebeln IS NULL )
    INTO CORRESPONDING FIELDS OF TABLE @gt_item.

  " 유형 선택 반영 (INV: DELTYPE 공백 / IVS-A / IVS-B)
  " (DELETE ... WHERE 좌측 피연산자는 컴포넌트로 해석되므로 화면 변수는 IF 로 분기)
  IF p_inv IS INITIAL.
    DELETE gt_item WHERE deltype IS INITIAL.
  ENDIF.
  IF p_ivsa IS INITIAL.
    DELETE gt_item WHERE deltype = 'A'.
  ENDIF.
  IF p_ivsb IS INITIAL.
    DELETE gt_item WHERE deltype = 'B'.
  ENDIF.

  " 삭제(취소) / 종결 납품서 제외 (기본 체크)
  " 입고(101) / 이전전기(311) 실적이 있는 품목은 취소·종결이어도 제외하지 않음
  IF p_xcan = gc_x.
    DELETE gt_item WHERE cancelled = gc_x AND grqty_std = 0 AND grqty_stk = 0.
  ENDIF.
  IF p_xcls = gc_x.
    DELETE gt_item WHERE delclose = gc_x AND grqty_std = 0 AND grqty_stk = 0.
  ENDIF.

  SORT gt_item BY delno delitem.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM FILTER_LABEL_BATCH
*&  배치번호 / 드럼라벨번호 조건: 해당 배치·라벨이 있는 납품서 품목만 남김
*&   - 라벨: ZGTMMT9425 (납품서/품목/드럼라벨)
*&   - 배치: 101(MATDOC 납품서번호 기준) + 311(라벨 전표) 입고 전표의 배치
*&---------------------------------------------------------------------*
FORM filter_label_batch.

  TYPES: BEGIN OF lty_key,
           delno   TYPE zgtmmt9410-delno,
           delitem TYPE zgtmmt9410-delitem,
         END OF lty_key.
  DATA: lt_lbl  TYPE STANDARD TABLE OF lty_key WITH DEFAULT KEY,
        lt_chg1 TYPE STANDARD TABLE OF lty_key WITH DEFAULT KEY,
        lt_chg2 TYPE STANDARD TABLE OF lty_key WITH DEFAULT KEY.

  CHECK s_charg[] IS NOT INITIAL OR s_label[] IS NOT INITIAL.
  CHECK gt_item IS NOT INITIAL.

  IF s_label[] IS NOT INITIAL.
    SELECT DISTINCT delno, delitem
      FROM zgtmmt9425
      FOR ALL ENTRIES IN @gt_item
      WHERE delno       = @gt_item-delno
        AND delitem     = @gt_item-delitem
        AND dr_label_no IN @s_label
      INTO TABLE @lt_lbl.
  ENDIF.

  IF s_charg[] IS NOT INITIAL.
    " 101: 납품서번호 기준 입고 전표
    SELECT DISTINCT b~delno, b~delitem
      FROM zgtmm_cv_deliv_base AS b
      INNER JOIN zgtmm_cv_get_matdoc AS a
         ON a~delno   = b~delno
        AND a~delitem = b~delitem
      INNER JOIN matdoc AS m
         ON m~mblnr = a~mblnr
        AND m~mjahr = a~mjahr
        AND m~zeile = a~zeile
      FOR ALL ENTRIES IN @gt_item
      WHERE b~delno   = @gt_item-delno
        AND b~delitem = @gt_item-delitem
        AND m~charg   IN @s_charg
      INTO TABLE @lt_chg1.
    " 311: 라벨 입고 전표
    SELECT DISTINCT p~delno, p~delitem
      FROM zgtmmt9425 AS p
      INNER JOIN zgtmmt9423 AS r
         ON r~zifkey      = p~zifkey
        AND r~system_id   = p~system_id
        AND r~ebeln       = p~ebeln
        AND r~ebelp       = p~ebelp
        AND r~dr_label_no = p~dr_label_no
      INNER JOIN matdoc AS m
         ON m~mblnr = r~mblnr
        AND m~mjahr = r~mjahr
      FOR ALL ENTRIES IN @gt_item
      WHERE p~delno   = @gt_item-delno
        AND p~delitem = @gt_item-delitem
        AND m~charg   IN @s_charg
      INTO TABLE @lt_chg2.
  ENDIF.

  " 라벨·배치를 모두 입력하면 둘 다 만족하는 품목만 남김
  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_it>).
    DATA(lv_keep) = abap_true.
    IF s_label[] IS NOT INITIAL
       AND NOT line_exists( lt_lbl[ delno = <ls_it>-delno delitem = <ls_it>-delitem ] ).
      lv_keep = abap_false.
    ENDIF.
    IF s_charg[] IS NOT INITIAL
       AND NOT line_exists( lt_chg1[ delno = <ls_it>-delno delitem = <ls_it>-delitem ] )
       AND NOT line_exists( lt_chg2[ delno = <ls_it>-delno delitem = <ls_it>-delitem ] ).
      lv_keep = abap_false.
    ENDIF.
    IF lv_keep = abap_false.
      DELETE gt_item.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_LABEL_STATUS
*&  MES 드럼라벨(9425) 처리상태: 라벨별 성공/실패/미확정 -> 품목별 건수
*&---------------------------------------------------------------------*
FORM get_label_status.

  DATA lv_st TYPE c LENGTH 1.

  CHECK gt_item IS NOT INITIAL.

  SELECT DISTINCT p~delno, p~delitem, p~dr_label_no, s~zstat
    FROM zgtmmt9425 AS p
    INNER JOIN zgtmmt9000 AS s
       ON s~zifkey    = p~zifkey
      AND s~system_id = p~system_id
      AND s~zifno     = @gc_zifno_dr
    FOR ALL ENTRIES IN @gt_item
    WHERE p~delno   = @gt_item-delno
      AND p~delitem = @gt_item-delitem
    INTO TABLE @DATA(lt_lbl).

  CHECK lt_lbl IS NOT INITIAL.
  SORT lt_lbl BY delno delitem dr_label_no.

  LOOP AT lt_lbl ASSIGNING FIELD-SYMBOL(<ls_lbl>)
       GROUP BY ( delno   = <ls_lbl>-delno
                  delitem = <ls_lbl>-delitem
                  label   = <ls_lbl>-dr_label_no )
       ASSIGNING FIELD-SYMBOL(<ls_grp>).

    lv_st = 'U'. "미확정(ZSTAT 공백)
    LOOP AT GROUP <ls_grp> ASSIGNING FIELD-SYMBOL(<ls_mem>).
      IF <ls_mem>-zstat = 'S'.
        lv_st = 'S'.
        EXIT.
      ELSEIF <ls_mem>-zstat = 'E'.
        lv_st = 'E'.
      ENDIF.
    ENDLOOP.

    READ TABLE gt_item ASSIGNING FIELD-SYMBOL(<ls_it>)
         WITH KEY delno = <ls_grp>-delno delitem = <ls_grp>-delitem
         BINARY SEARCH.
    CHECK sy-subrc = 0.

    CASE lv_st.
      WHEN 'E'.
        <ls_it>-lblerr = <ls_it>-lblerr + 1.
      WHEN 'U'.
        <ls_it>-lblunf = <ls_it>-lblunf + 1.
    ENDCASE.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_RESERVED_SO
*&  IVS-B 입고 전 품목의 예정 SO (VBAP 참조 문서 VGBEL/VGPOS 재조회)
*&---------------------------------------------------------------------*
FORM get_reserved_so.

  TYPES: BEGIN OF lty_key,
           vbeln TYPE ekkn-vbeln,
           posnr TYPE ekkn-vbelp,
         END OF lty_key.
  DATA lt_key TYPE STANDARD TABLE OF lty_key WITH DEFAULT KEY.

  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_it>)
       WHERE deltype = 'B' AND vbeln_po IS NOT INITIAL.
    APPEND VALUE #( vbeln = <ls_it>-vbeln_po posnr = <ls_it>-posnr_po ) TO lt_key.
  ENDLOOP.
  CHECK lt_key IS NOT INITIAL.

  SORT lt_key BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_key COMPARING vbeln posnr.

  SELECT vgbel, vgpos, vbeln, posnr
    FROM vbap
    FOR ALL ENTRIES IN @lt_key
    WHERE vgbel = @lt_key-vbeln
      AND vgpos = @lt_key-posnr
    INTO TABLE @DATA(lt_ref).
  CHECK lt_ref IS NOT INITIAL.

  SORT lt_ref BY vgbel vgpos vbeln posnr. "2건 이상이면 최소 SO 1건

  LOOP AT gt_item ASSIGNING <ls_it>
       WHERE deltype = 'B' AND vbeln_po IS NOT INITIAL.
    READ TABLE lt_ref ASSIGNING FIELD-SYMBOL(<ls_ref>)
         WITH KEY vgbel = <ls_it>-vbeln_po vgpos = <ls_it>-posnr_po
         BINARY SEARCH.
    IF sy-subrc = 0.
      <ls_it>-vbeln_gr = <ls_ref>-vbeln.
      <ls_it>-posnr_gr = <ls_ref>-posnr.
      <ls_it>-so_src   = '예정'. "예정 (실전표 확정 시 '전표' 로 덮어씀)
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CALC_ITEM
*&  품목별 입고수량/입고율/상태/입고경로/대사플래그/실전표 SO 산출
*&---------------------------------------------------------------------*
FORM calc_item.

  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_it>).

    <ls_it>-typ_seq = COND #( WHEN <ls_it>-deltype IS INITIAL THEN '1'
                              WHEN <ls_it>-deltype = 'A'      THEN '2'
                              ELSE '3' ).
    <ls_it>-typ_txt = COND #( WHEN <ls_it>-deltype IS INITIAL THEN '표준납품서'
                              WHEN <ls_it>-deltype = 'A'      THEN '매입보관품'
                              WHEN <ls_it>-deltype = 'B'      THEN '매출보관품'
                              ELSE <ls_it>-deltype ).

    " 처리유형: IVS 는 DELTYPE, INV 는 입고 저장위치(3497 매입보관 / 3498 직납)
    <ls_it>-proc_txt = COND #( WHEN <ls_it>-deltype = 'A' THEN '매입보관품'
                               WHEN <ls_it>-deltype = 'B' THEN '매출보관품'
                               WHEN <ls_it>-lgort = '3497' THEN '매입보관품'
                               WHEN <ls_it>-lgort = '3498' THEN '직납매입'
                               ELSE '공장입고' ).

    <ls_it>-grqty   = <ls_it>-grqty_std + <ls_it>-grqty_stk.
    " 처리유형은 입고된 건만 표시 (미입고는 입고 예정 방식이라 비움)
    IF <ls_it>-grqty = 0.
      CLEAR <ls_it>-proc_txt.
    ENDIF.
    <ls_it>-openqty = <ls_it>-delqty - <ls_it>-grqty.
    IF <ls_it>-delqty > 0.
      <ls_it>-grrate = <ls_it>-grqty * 100 / <ls_it>-delqty.
    ENDIF.
    <ls_it>-doccnt = <ls_it>-doccnt_std + <ls_it>-doccnt_stk.

    " 최초/최종 입고일
    <ls_it>-first_gr = COND #( WHEN <ls_it>-first_std IS INITIAL THEN <ls_it>-first_stk
                               WHEN <ls_it>-first_stk IS INITIAL THEN <ls_it>-first_std
                               WHEN <ls_it>-first_std < <ls_it>-first_stk THEN <ls_it>-first_std
                               ELSE <ls_it>-first_stk ).
    <ls_it>-last_gr  = COND #( WHEN <ls_it>-last_std > <ls_it>-last_stk THEN <ls_it>-last_std
                               ELSE <ls_it>-last_stk ).

    " 입고경로
    <ls_it>-route = COND #( WHEN <ls_it>-grqty_std > 0 AND <ls_it>-grqty_stk > 0 THEN '혼합'
                            WHEN <ls_it>-grqty_std > 0 THEN '101'
                            WHEN <ls_it>-grqty_stk > 0 THEN '311 MES'
                            ELSE '' ).

    " 입고 상태
    IF <ls_it>-cancelled = gc_x.
      <ls_it>-grstat = 'C'.
    ELSEIF <ls_it>-grqty > <ls_it>-delqty.
      <ls_it>-grstat = 'O'.
    ELSEIF <ls_it>-grqty > 0 AND <ls_it>-grqty = <ls_it>-delqty.
      <ls_it>-grstat = 'F'.
    ELSEIF <ls_it>-grqty > 0.
      <ls_it>-grstat = 'P'.
    ELSEIF <ls_it>-lblerr > 0.
      <ls_it>-grstat = 'E'.
    ELSEIF <ls_it>-lblunf > 0.
      <ls_it>-grstat = 'U'.
    ELSE.
      <ls_it>-grstat = 'N'.
    ENDIF.
    PERFORM set_status_text USING <ls_it>-grstat
                            CHANGING <ls_it>-grstat_txt <ls_it>-icon.
    PERFORM set_status_color USING <ls_it>-grstat
                             CHANGING <ls_it>-colcell.

    " 대사 플래그 (전량 합산 + 중복 플래그)
    IF <ls_it>-lblcnt > 0 AND <ls_it>-doccnt_stk > <ls_it>-lblcnt.
      <ls_it>-chk_dup = gc_x.
    ENDIF.
    IF <ls_it>-grstat = 'O'.
      <ls_it>-chk_over = gc_x.
    ENDIF.
    IF <ls_it>-cancelled = gc_x AND <ls_it>-grqty > 0.
      <ls_it>-chk_canc = gc_x.
    ENDIF.
    IF <ls_it>-lblerr > 0.
      <ls_it>-chk_err = gc_x.
    ENDIF.
    PERFORM set_chk_text USING <ls_it>-chk_dup <ls_it>-chk_over <ls_it>-chk_canc <ls_it>-chk_err
                         CHANGING <ls_it>-chk_txt.

    " 입고 기준 SO: 실전표(R) 우선, 없으면 IVS-B 예정(P, GET_RESERVED_SO)
    IF <ls_it>-grqty > 0
       AND ( <ls_it>-so_stk IS NOT INITIAL OR <ls_it>-so_std IS NOT INITIAL ).
      IF <ls_it>-so_stk IS NOT INITIAL.
        <ls_it>-vbeln_gr = <ls_it>-so_stk.
        <ls_it>-posnr_gr = <ls_it>-soitm_stk.
      ELSE.
        <ls_it>-vbeln_gr = <ls_it>-so_std.
        <ls_it>-posnr_gr = <ls_it>-soitm_std.
      ENDIF.
      <ls_it>-so_src = '전표'.
    ELSEIF <ls_it>-grqty > 0.
      " 전표 있으나 전표 SO 없음: 예정값 표시하지 않음
      CLEAR: <ls_it>-vbeln_gr, <ls_it>-posnr_gr, <ls_it>-so_src.
    ENDIF.

    " 판매오더: INV / 매입보관품(A) 은 PO 지정 SO 가 곧 판매오더 (입고 전 예정 P)
    "          매출보관품(B) 만 PO 지정 SO 가 이전판매오더, 판매오더는 입고 전표/참조 SO
    IF <ls_it>-deltype <> 'B'.
      IF <ls_it>-grqty = 0 AND <ls_it>-vbeln_po IS NOT INITIAL.
        <ls_it>-vbeln_gr = <ls_it>-vbeln_po.
        <ls_it>-posnr_gr = <ls_it>-posnr_po.
        <ls_it>-so_src   = '예정'.
      ENDIF.
      CLEAR: <ls_it>-vbeln_po, <ls_it>-posnr_po. "이전판매오더는 매출보관품(B) 만 표시
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_JOJANG
*&  조장/드럼수: 판매오더(입고 SO -> PO 지정 SO) 특성 우선, 없으면 구매오더 특성
*&   - 조장   = LENGTH (SAP_MILLCA_LENGTH)
*&   - 드럼수 = DRQTY  (SAP_MILLCA_FACTOR) : PO 수량 전체 기준 드럼수
*&   납품/입고 드럼수 = 수량 / 조장 (조장 없으면 PO 드럼수를 수량비로 안분)
*&   이전전기(311) 드럼수 = 311 전표 건수 (Single Batch 이동 = 1드럼)
*&---------------------------------------------------------------------*
FORM get_jojang.

  TYPES: BEGIN OF lty_so,
           vbeln TYPE vbeln,
           posnr TYPE posnr,
         END OF lty_so,
         BEGIN OF lty_po,
           ebeln TYPE ebeln,
           ebelp TYPE ebelp,
         END OF lty_po.
  DATA: lt_so   TYPE SORTED TABLE OF lty_so WITH UNIQUE KEY vbeln posnr,
        lt_po   TYPE SORTED TABLE OF lty_po WITH UNIQUE KEY ebeln ebelp,
        lv_len  TYPE atwrt,
        lv_drq  TYPE atwrt,
        lv_drqf TYPE f.

  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_it>).
    IF <ls_it>-vbeln_gr IS NOT INITIAL.
      INSERT VALUE #( vbeln = <ls_it>-vbeln_gr posnr = <ls_it>-posnr_gr ) INTO TABLE lt_so.
    ELSEIF <ls_it>-vbeln_po IS NOT INITIAL.
      INSERT VALUE #( vbeln = <ls_it>-vbeln_po posnr = <ls_it>-posnr_po ) INTO TABLE lt_so.
    ELSEIF <ls_it>-ebeln IS NOT INITIAL.
      INSERT VALUE #( ebeln = <ls_it>-ebeln ebelp = <ls_it>-ebelp ) INTO TABLE lt_po.
    ENDIF.
  ENDLOOP.

  IF lt_so IS NOT INITIAL.
    SELECT vbeln, posnr, length, drqty
      FROM zgtmm_cv_so_vcvalue_main
      FOR ALL ENTRIES IN @lt_so
      WHERE vbeln = @lt_so-vbeln
        AND posnr = @lt_so-posnr
      INTO TABLE @DATA(lt_sov).
    SORT lt_sov BY vbeln posnr.
  ENDIF.
  IF lt_po IS NOT INITIAL.
    SELECT pdoc, pdocitem, length, drqty
      FROM zgtmm_cv_po_vcvalue_main
      FOR ALL ENTRIES IN @lt_po
      WHERE pdoc     = @lt_po-ebeln
        AND pdocitem = @lt_po-ebelp
      INTO TABLE @DATA(lt_pov).
    SORT lt_pov BY pdoc pdocitem.
  ENDIF.

  LOOP AT gt_item ASSIGNING <ls_it>.

    CLEAR: lv_len, lv_drq, lv_drqf.
    IF <ls_it>-vbeln_gr IS NOT INITIAL.
      READ TABLE lt_sov ASSIGNING FIELD-SYMBOL(<ls_sov>)
           WITH KEY vbeln = <ls_it>-vbeln_gr posnr = <ls_it>-posnr_gr BINARY SEARCH.
      IF sy-subrc = 0.
        lv_len = <ls_sov>-length.
        lv_drq = <ls_sov>-drqty.
      ENDIF.
    ELSEIF <ls_it>-vbeln_po IS NOT INITIAL.
      READ TABLE lt_sov ASSIGNING <ls_sov>
           WITH KEY vbeln = <ls_it>-vbeln_po posnr = <ls_it>-posnr_po BINARY SEARCH.
      IF sy-subrc = 0.
        lv_len = <ls_sov>-length.
        lv_drq = <ls_sov>-drqty.
      ENDIF.
    ELSE.
      READ TABLE lt_pov ASSIGNING FIELD-SYMBOL(<ls_pov>)
           WITH KEY pdoc = <ls_it>-ebeln pdocitem = <ls_it>-ebelp BINARY SEARCH.
      IF sy-subrc = 0.
        lv_len = <ls_pov>-length.
        lv_drq = <ls_pov>-drqty.
      ENDIF.
    ENDIF.

    TRY.
        <ls_it>-jojang = CONV f( lv_len ). "atwrt(부동소수 문자) -> 수치
        lv_drqf        = CONV f( lv_drq ).
      CATCH cx_sy_conversion_error.
        CLEAR: <ls_it>-jojang, lv_drqf.
    ENDTRY.

    " PO 드럼수 = 특성값 그대로
    <ls_it>-podrum = lv_drqf.

    " 납품/입고 드럼수 = 수량 / 조장 (조장 없으면 PO 드럼수를 수량비로 안분)
    IF <ls_it>-jojang > 0.
      <ls_it>-deldrum = <ls_it>-delqty    / <ls_it>-jojang.
      <ls_it>-grdrum  = <ls_it>-grqty_std / <ls_it>-jojang.
    ELSEIF <ls_it>-poqty > 0.
      <ls_it>-deldrum = lv_drqf * <ls_it>-delqty    / <ls_it>-poqty.
      <ls_it>-grdrum  = lv_drqf * <ls_it>-grqty_std / <ls_it>-poqty.
    ENDIF.
    <ls_it>-stkdrum  = <ls_it>-doccnt_stk.
    <ls_it>-opendrum = <ls_it>-deldrum - <ls_it>-grdrum - <ls_it>-stkdrum.

    " 드럼 단위 관리는 길이(M) 품목만: KG/EA/SET 등은 조장·드럼수 없음 (수량 컬럼만 사용)
    IF <ls_it>-meins <> 'M'.
      CLEAR: <ls_it>-jojang, <ls_it>-podrum, <ls_it>-deldrum, <ls_it>-grdrum,
             <ls_it>-stkdrum, <ls_it>-opendrum.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_STATUS_COLOR
*&  상태 셀 색상: 완료(F) 녹색 / 부분·미확정·오류·초과 노랑
*&---------------------------------------------------------------------*
FORM set_status_color USING    pv_stat TYPE c
                      CHANGING ct_col  TYPE lvc_t_scol.

  DATA ls_col TYPE lvc_s_scol.

  CLEAR ct_col.
  ls_col-fname = 'ICON'.
  CASE pv_stat.
    WHEN 'F'.
      ls_col-color-col = 5. "녹색
    WHEN 'P' OR 'U' OR 'E' OR 'O'.
      ls_col-color-col = 3. "노랑
    WHEN OTHERS.
      RETURN.
  ENDCASE.
  ls_col-color-int = 1.
  APPEND ls_col TO ct_col.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GET_PO_TOTAL
*&  PO 대비 누적 입고/미입고: 해당 PO 품목의 전체 납품서(조회 기간 무관, 취소 제외)
*&  입고수량 = 101 + 311, 드럼수 = 101 수량/조장 + 311 전표 건수 (GET_JOJANG 와 동일 기준)
*&  보관품(IVS) 납품서는 INV 로 이미 입고(101)된 물량의 재고이전(311)이므로 제외
*&---------------------------------------------------------------------*
FORM get_po_total.

  TYPES: BEGIN OF lty_po,
           ebeln TYPE ekpo-ebeln,
           ebelp TYPE ekpo-ebelp,
         END OF lty_po,
         BEGIN OF lty_tot,
           ebeln TYPE ekpo-ebeln,
           ebelp TYPE ekpo-ebelp,
           qty   TYPE ty_qty,
           qstd  TYPE ty_qty,
           dstk  TYPE i,
         END OF lty_tot.
  DATA: lt_po  TYPE SORTED TABLE OF lty_po WITH UNIQUE KEY ebeln ebelp,
        lt_tot TYPE SORTED TABLE OF lty_tot WITH UNIQUE KEY ebeln ebelp.

  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_it>) WHERE ebeln IS NOT INITIAL.
    INSERT VALUE #( ebeln = <ls_it>-ebeln ebelp = <ls_it>-ebelp ) INTO TABLE lt_po.
  ENDLOOP.
  CHECK lt_po IS NOT INITIAL.

  SELECT b~ebeln, b~ebelp, b~deltype, s~grqty AS grqty_std, t~grqty AS grqty_stk,
         t~doccnt AS doccnt_stk
    FROM zgtmm_cv_deliv_base AS b
    LEFT OUTER JOIN zgtmm_cv_deliv_gr_101 AS s
      ON s~delno   = b~delno
     AND s~delitem = b~delitem
    LEFT OUTER JOIN zgtmm_cv_deliv_gr_311 AS t
      ON t~delno   = b~delno
     AND t~delitem = b~delitem
    FOR ALL ENTRIES IN @lt_po
    WHERE b~ebeln = @lt_po-ebeln
      AND b~ebelp = @lt_po-ebelp
      AND b~cancelled = @space
    INTO TABLE @DATA(lt_gr).

  LOOP AT lt_gr ASSIGNING FIELD-SYMBOL(<ls_gr>).
    " 보관품(IVS) 납품서는 INV 로 이미 입고(101)된 물량의 재고이전(311)이므로 PO 입고 누적에서 제외
    CHECK <ls_gr>-deltype IS INITIAL.
    READ TABLE lt_tot ASSIGNING FIELD-SYMBOL(<ls_tot>)
         WITH TABLE KEY ebeln = <ls_gr>-ebeln ebelp = <ls_gr>-ebelp.
    IF sy-subrc <> 0.
      INSERT VALUE #( ebeln = <ls_gr>-ebeln ebelp = <ls_gr>-ebelp )
             INTO TABLE lt_tot ASSIGNING <ls_tot>.
    ENDIF.
    <ls_tot>-qstd = <ls_tot>-qstd + <ls_gr>-grqty_std.
    <ls_tot>-qty  = <ls_tot>-qty + <ls_gr>-grqty_std + <ls_gr>-grqty_stk.
    <ls_tot>-dstk = <ls_tot>-dstk + <ls_gr>-doccnt_stk.
  ENDLOOP.

  LOOP AT gt_item ASSIGNING <ls_it> WHERE ebeln IS NOT INITIAL.
    READ TABLE lt_tot ASSIGNING <ls_tot>
         WITH TABLE KEY ebeln = <ls_it>-ebeln ebelp = <ls_it>-ebelp.
    CHECK sy-subrc = 0.
    <ls_it>-potot_qty = <ls_tot>-qty.
    IF <ls_it>-meins <> 'M'.
      CLEAR <ls_it>-potot_drum. "길이(M) 품목만 드럼수 관리
    ELSEIF <ls_it>-jojang > 0.
      <ls_it>-potot_drum = <ls_tot>-qstd / <ls_it>-jojang + <ls_tot>-dstk.
    ELSEIF <ls_it>-poqty > 0.
      <ls_it>-potot_drum = <ls_it>-podrum * <ls_tot>-qstd / <ls_it>-poqty + <ls_tot>-dstk.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_item ASSIGNING <ls_it>.
    <ls_it>-poopn_qty  = <ls_it>-poqty  - <ls_it>-potot_qty.
    <ls_it>-poopn_drum = <ls_it>-podrum - <ls_it>-potot_drum.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_STATUS_TEXT
*&---------------------------------------------------------------------*
FORM set_status_text USING    pv_stat TYPE c
                     CHANGING cv_txt  TYPE c
                              cv_icon TYPE icon_d.

  CASE pv_stat.
    WHEN 'F'.
      cv_txt = '입고완료'.  cv_icon = '@08@'.
    WHEN 'P'.
      cv_txt = '부분입고'.  cv_icon = '@09@'.
    WHEN 'O'.
      cv_txt = '초과입고'.  cv_icon = '@0A@'.
    WHEN 'E'.
      cv_txt = '처리오류'.  cv_icon = '@0A@'.
    WHEN 'U'.
      cv_txt = '미확정'.    cv_icon = '@09@'.
    WHEN 'C'.
      cv_txt = '취소'.      cv_icon = '@EB@'.
    WHEN OTHERS.
      cv_txt = '미입고'.    cv_icon = '@EB@'.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SET_CHK_TEXT
*&---------------------------------------------------------------------*
FORM set_chk_text USING    pv_dup  TYPE c
                           pv_over TYPE c
                           pv_canc TYPE c
                           pv_err  TYPE c
                  CHANGING cv_txt  TYPE c.

  DATA lv_txt TYPE string.

  IF pv_dup = gc_x.
    lv_txt = lv_txt && '중복의심 '.
  ENDIF.
  IF pv_over = gc_x.
    lv_txt = lv_txt && '초과입고 '.
  ENDIF.
  IF pv_canc = gc_x.
    lv_txt = lv_txt && '취소후입고 '.
  ENDIF.
  IF pv_err = gc_x.
    lv_txt = lv_txt && '처리오류 '.
  ENDIF.
  cv_txt = lv_txt.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM BUILD_DOC
*&  품목 -> 납품서(명세서) 단위 집계
*&---------------------------------------------------------------------*
FORM build_doc.

  DATA: ls_doc TYPE ty_doc,
        lv_cf  TYPE i, "완료(F)
        lv_co  TYPE i, "초과(O)
        lv_cp  TYPE i, "부분(P)
        lv_cn  TYPE i, "미입고(N)
        lv_cu  TYPE i, "미확정(U)
        lv_ce  TYPE i, "오류(E)
        lv_cc  TYPE i, "취소(C)
        lv_std TYPE ty_qty,
        lv_stk TYPE ty_qty.

  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_it>)
       GROUP BY ( delno = <ls_it>-delno )
       ASSIGNING FIELD-SYMBOL(<ls_grp>).

    CLEAR: ls_doc, lv_cf, lv_co, lv_cp, lv_cn, lv_cu, lv_ce, lv_cc, lv_std, lv_stk.

    LOOP AT GROUP <ls_grp> ASSIGNING FIELD-SYMBOL(<ls_m>).
      IF ls_doc-itemcnt = 0.
        ls_doc-typ_txt  = <ls_m>-typ_txt.
        ls_doc-typ_seq  = <ls_m>-typ_seq.
        ls_doc-delno    = <ls_m>-delno.
        ls_doc-werks    = <ls_m>-werks.
        ls_doc-budat    = <ls_m>-budat.
        ls_doc-lifnr    = <ls_m>-lifnr.
        ls_doc-name1    = <ls_m>-name1.
        ls_doc-meins    = <ls_m>-meins.
        ls_doc-delclose = <ls_m>-delclose.
      ELSEIF ls_doc-meins <> <ls_m>-meins.
        ls_doc-meins = '*'. "단위 혼재
      ENDIF.

      ls_doc-itemcnt = ls_doc-itemcnt + 1.
      ls_doc-delqty  = ls_doc-delqty + <ls_m>-delqty.
      ls_doc-grqty   = ls_doc-grqty  + <ls_m>-grqty.
      ls_doc-doccnt  = ls_doc-doccnt + <ls_m>-doccnt.
      ls_doc-lblcnt  = ls_doc-lblcnt + <ls_m>-lblcnt.
      ls_doc-lblerr  = ls_doc-lblerr + <ls_m>-lblerr.
      lv_std         = lv_std + <ls_m>-grqty_std.
      lv_stk         = lv_stk + <ls_m>-grqty_stk.

      IF <ls_m>-cancelled = gc_x.
        ls_doc-cancelled = gc_x.
      ENDIF.
      IF ls_doc-first_gr IS INITIAL
         OR ( <ls_m>-first_gr IS NOT INITIAL AND <ls_m>-first_gr < ls_doc-first_gr ).
        ls_doc-first_gr = <ls_m>-first_gr.
      ENDIF.
      IF <ls_m>-last_gr > ls_doc-last_gr.
        ls_doc-last_gr = <ls_m>-last_gr.
      ENDIF.
      IF <ls_m>-chk_dup  = gc_x. ls_doc-chk_dup  = gc_x. ENDIF.
      IF <ls_m>-chk_over = gc_x. ls_doc-chk_over = gc_x. ENDIF.
      IF <ls_m>-chk_canc = gc_x. ls_doc-chk_canc = gc_x. ENDIF.
      IF <ls_m>-chk_err  = gc_x. ls_doc-chk_err  = gc_x. ENDIF.

      CASE <ls_m>-grstat.
        WHEN 'F'. lv_cf = lv_cf + 1.
        WHEN 'O'. lv_co = lv_co + 1.
        WHEN 'P'. lv_cp = lv_cp + 1.
        WHEN 'N'. lv_cn = lv_cn + 1.
        WHEN 'U'. lv_cu = lv_cu + 1.
        WHEN 'E'. lv_ce = lv_ce + 1.
        WHEN 'C'. lv_cc = lv_cc + 1.
      ENDCASE.
    ENDLOOP.

    ls_doc-openqty = ls_doc-delqty - ls_doc-grqty.
    IF ls_doc-delqty > 0.
      ls_doc-grrate = ls_doc-grqty * 100 / ls_doc-delqty.
    ENDIF.
    ls_doc-route = COND #( WHEN lv_std > 0 AND lv_stk > 0 THEN '혼합'
                           WHEN lv_std > 0 THEN '101'
                           WHEN lv_stk > 0 THEN '311 MES'
                           ELSE '' ).

    " 납품서 상태: 품목 상태 종합
    IF lv_cc = ls_doc-itemcnt.
      ls_doc-grstat = 'C'.
    ELSEIF lv_cp = 0 AND lv_cn = 0 AND lv_cu = 0 AND lv_ce = 0.
      ls_doc-grstat = COND #( WHEN lv_co > 0 THEN 'O' ELSE 'F' ).
    ELSEIF lv_cf + lv_co + lv_cp > 0.
      ls_doc-grstat = 'P'.
    ELSEIF lv_ce > 0.
      ls_doc-grstat = 'E'.
    ELSEIF lv_cu > 0.
      ls_doc-grstat = 'U'.
    ELSE.
      ls_doc-grstat = 'N'.
    ENDIF.
    PERFORM set_status_text USING ls_doc-grstat
                            CHANGING ls_doc-grstat_txt ls_doc-icon.
    PERFORM set_chk_text USING ls_doc-chk_dup ls_doc-chk_over ls_doc-chk_canc ls_doc-chk_err
                         CHANGING ls_doc-chk_txt.

    APPEND ls_doc TO gt_doc.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM FILTER_DOC
*&  입고상태 조건 / 대사 모드(플래그 건만)
*&---------------------------------------------------------------------*
FORM filter_doc.

  IF p_sopn = gc_x.
    DELETE gt_doc WHERE grstat <> 'N' AND grstat <> 'U' AND grstat <> 'E'.
  ELSEIF p_spar = gc_x.
    DELETE gt_doc WHERE grstat <> 'P'.
  ELSEIF p_sful = gc_x.
    DELETE gt_doc WHERE grstat <> 'F'.
  ELSEIF p_sovr = gc_x.
    DELETE gt_doc WHERE grstat <> 'O'.
  ENDIF.

  IF p_chk = gc_x.
    DELETE gt_doc WHERE chk_txt IS INITIAL.
  ENDIF.

  SORT gt_doc BY typ_seq delno.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM FILTER_ITEM
*&  대사/상세 모드: 납품서 필터(상태/점검대상) 후 남은 납품서의 품목만 표시
*&  (점검대상 선택 시 플래그가 있는 품목만), 납품서번호/품목번호(숫자) 순 정렬
*&---------------------------------------------------------------------*
FORM filter_item.

  DATA lt_delno TYPE SORTED TABLE OF zgtmmt9410-delno WITH UNIQUE KEY table_line.

  lt_delno = VALUE #( FOR ls_d IN gt_doc ( ls_d-delno ) ).

  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<ls_it>).
    IF NOT line_exists( lt_delno[ table_line = <ls_it>-delno ] )
       OR ( p_chk = gc_x AND <ls_it>-chk_txt IS INITIAL ).
      DELETE gt_item.
      CONTINUE.
    ENDIF.

    " 입고 상태 조건은 품목 상태로도 한 번 더 거름 (납품서 단위 필터는 위에서 통과)
    IF ( p_sopn = gc_x AND <ls_it>-grstat <> 'N' AND <ls_it>-grstat <> 'U' AND <ls_it>-grstat <> 'E' )
       OR ( p_spar = gc_x AND <ls_it>-grstat <> 'P' )
       OR ( p_sful = gc_x AND <ls_it>-grstat <> 'F' )
       OR ( p_sovr = gc_x AND <ls_it>-grstat <> 'O' ).
      DELETE gt_item.
      CONTINUE.
    ENDIF.
    IF <ls_it>-delitem CO ' 0123456789'.
      <ls_it>-itemseq = <ls_it>-delitem.
    ENDIF.
  ENDLOOP.

  SORT gt_item BY typ_seq delno itemseq.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM BUILD_SUM
*&  유형 x 플랜트 요약 (조회 기간 전체 합산)
*&---------------------------------------------------------------------*
FORM build_sum.

  DATA: ls_sum  TYPE ty_sum,
        lv_from TYPE d,
        lv_to   TYPE d.

  " 요약 기간 표시: 선택화면 납품일자 범위 (단일 범위가 아니면 조회 결과의 최소~최대 납품일)
  READ TABLE s_budat INTO DATA(ls_rng) INDEX 1.
  IF sy-subrc = 0 AND lines( s_budat[] ) = 1 AND ls_rng-sign = 'I' AND ls_rng-option = 'BT'.
    lv_from = ls_rng-low.
    lv_to   = ls_rng-high.
  ELSE.
    lv_from = '99991231'.
    LOOP AT gt_doc ASSIGNING FIELD-SYMBOL(<ls_d>).
      IF <ls_d>-budat < lv_from.
        lv_from = <ls_d>-budat.
      ENDIF.
      IF <ls_d>-budat > lv_to.
        lv_to = <ls_d>-budat.
      ENDIF.
    ENDLOOP.
  ENDIF.
  DATA(lv_period) = |{ lv_from(4) }.{ lv_from+4(2) }.{ lv_from+6(2) }~{ lv_to(4) }.{ lv_to+4(2) }.{ lv_to+6(2) }|.

  " 유형 x 플랜트 단위로 조회 기간 전체를 합산
  LOOP AT gt_doc ASSIGNING FIELD-SYMBOL(<ls_doc>)
       GROUP BY ( seq = <ls_doc>-typ_seq typ = <ls_doc>-typ_txt werks = <ls_doc>-werks )
       ASSIGNING FIELD-SYMBOL(<ls_grp>).

    CLEAR ls_sum.
    ls_sum-typ_seq = <ls_grp>-seq.
    ls_sum-typ_txt = <ls_grp>-typ.
    ls_sum-werks   = <ls_grp>-werks.
    ls_sum-period  = lv_period.

    LOOP AT GROUP <ls_grp> ASSIGNING FIELD-SYMBOL(<ls_m>).
      ls_sum-delcnt  = ls_sum-delcnt + 1.
      ls_sum-itemcnt = ls_sum-itemcnt + <ls_m>-itemcnt.
      ls_sum-delqty  = ls_sum-delqty + <ls_m>-delqty.
      ls_sum-grqty   = ls_sum-grqty + <ls_m>-grqty.
      CASE <ls_m>-grstat.
        WHEN 'F'. ls_sum-cnt_full = ls_sum-cnt_full + 1.
        WHEN 'P'. ls_sum-cnt_part = ls_sum-cnt_part + 1.
        WHEN 'N' OR 'U'. ls_sum-cnt_open = ls_sum-cnt_open + 1.
        WHEN 'E'. ls_sum-cnt_err  = ls_sum-cnt_err + 1.
        WHEN 'O'. ls_sum-cnt_over = ls_sum-cnt_over + 1.
        WHEN 'C'. ls_sum-cnt_canc = ls_sum-cnt_canc + 1.
      ENDCASE.
    ENDLOOP.

    ls_sum-openqty = ls_sum-delqty - ls_sum-grqty.
    IF ls_sum-delqty > 0.
      ls_sum-grrate = ls_sum-grqty * 100 / ls_sum-delqty.
    ENDIF.
    APPEND ls_sum TO gt_sum.
  ENDLOOP.

  SORT gt_sum BY typ_seq werks.

ENDFORM.
