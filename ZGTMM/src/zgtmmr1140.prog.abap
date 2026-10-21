*&---------------------------------------------------------------------*
*& 모듈    : MM
*& 프로그램: ZGTMMR1140 ([MM] G-PRO 단가계약 수신 오류 점검)
*& 목적    : ZGTMM_IF_I_INFODATA_RCV(G-PRO 단가계약 수신) 오류 건 원인 확인
*&           1) ZGTMMT9000 오류·미기록 로그 + 수신 LOG(9230/9231) 조회
*&           2) 사전 점검: 기본단위·단가단위 환산·기존 인포레코드·유효기간이
*&              겹치는 기존 PB00 조건·이후 성공 수신 여부
*&           3) SET_INFORECORD와 같은 값으로 ME_INFORECORD_MAINTAIN 재현 후
*&              항상 ROLLBACK (DB 미반영) — BAPI 반환 메시지 전체 표시
*&           4) [일괄 생성] 구매조직 단위(플랜트 공백) EINE만 있는 인포레코드에
*&              플랜트 구매조직 데이터 일괄 생성 (조건 없이, 행별 COMMIT)
*&              플랜트: 입력값 우선, 없으면 EINE 최종 PO(EBELN/EBELP)의 플랜트
*&           5) [단가 공백 보정] 정산월 입고 대상 중 기준일에 유효한 PB00 조건이 없어
*&              ZGTMMR1100에 안 보이는 건에 조건 생성 (유효기간 = 공백 시작일~99991231)
*&              단가: 직전 정상 조건 단가 → 없으면 최근 PO 단가 (ZGTMMR1100 저장 시 덮어씀)
*&              테스트: BAPI 실행 후 항상 ROLLBACK / 실행: 행별 COMMIT 후 재조회로 확인
*&              플랜트 EINE가 없는 건은 P_MCRE로 먼저 생성한 뒤 별도 실행(같은 세션 버퍼 문제)
*& 주의    : 재현은 현재 DB 상태 기준(실패 당시와 다를 수 있음).
*&           신규 인포레코드 재현 시 번호범위 번호가 소모될 수 있음.
*&           PR 평가가격 변경(BAPI_PR_CHANGE)은 LOG에 PR번호가 없어 재현 안 함.
*& 생성일  : 2026.09.27
*&---------------------------------------------------------------------*
REPORT zgtmmr1140 NO STANDARD PAGE HEADING.

TABLES: zgtmmt9000.

DATA: gv_matnr TYPE char40,   " 9230 MATNR는 ALPHA OUT 저장 → 변환 없는 입력
      gv_ekorg TYPE ekorg,
      gv_infnr TYPE infnr,
      gv_matn2 TYPE matnr,
      gv_lifnr TYPE lifnr,
      gv_erdat TYPE erdat.

SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE TEXT-b00.
  PARAMETERS: p_mchk RADIOBUTTON GROUP g0 DEFAULT 'X' USER-COMMAND mode,  " 수신 오류 점검
              p_mcre RADIOBUTTON GROUP g0,                                " 플랜트 구매조직 데이터 일괄 생성
              p_mgap RADIOBUTTON GROUP g0.                                " OEM 단가 공백 보정
SELECTION-SCREEN END OF BLOCK b0.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
  SELECT-OPTIONS: s_ifdat  FOR zgtmmt9000-ifdat DEFAULT sy-datlo MODIF ID chk,   " 수신일자(로그 IFDAT = 현지일자)
                  s_zifkey FOR zgtmmt9000-zifkey MODIF ID chk,
                  s_msg    FOR zgtmmt9000-message MODIF ID chk,     " 예: *PROCESS_CONDITION*
                  s_matnr  FOR gv_matnr MODIF ID chk.
  PARAMETERS: p_err RADIOBUTTON GROUP g1 DEFAULT 'X' MODIF ID chk,  " 오류·미기록만
              p_all RADIOBUTTON GROUP g1 MODIF ID chk,              " 성공 포함 전체
              p_max TYPE i DEFAULT 50 MODIF ID chk.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
  PARAMETERS: p_none RADIOBUTTON GROUP g2 MODIF ID chk,               " 재현 안 함 (점검만)
              p_cur  RADIOBUTTON GROUP g2 DEFAULT 'X' MODIF ID chk,   " 현재 로직으로 재현 (기존 INFNR 지정)
              p_old  RADIOBUTTON GROUP g2 MODIF ID chk,               " 9월 수정 이전 로직으로 재현 (INFNR 미지정)
              p_new  RADIOBUTTON GROUP g2 MODIF ID chk,               " 26.09.27 수정 로직으로 재현 (플랜트 구매조직 선생성)
              p_commit TYPE abap_bool AS CHECKBOX MODIF ID chk.       " 수정 로직 1단계 실제 반영(COMMIT) — 1건 조회 시만
SELECTION-SCREEN END OF BLOCK b2.

*일괄 생성 조건 (P_MCRE)
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-b03.
  SELECT-OPTIONS: s_ekorg FOR gv_ekorg DEFAULT '1400' MODIF ID cre,
                  s_infnr FOR gv_infnr MODIF ID cre,
                  s_matn2 FOR gv_matn2 MODIF ID cre,
                  s_lifnr FOR gv_lifnr MODIF ID cre,
                  s_erdat FOR gv_erdat MODIF ID cre.                  " 구매조직 단위 EINE 생성일
  PARAMETERS: p_werks TYPE werks_d MODIF ID cre,                      " 생성할 플랜트 (공백 = 최종 PO 플랜트)
              p_gpro  TYPE abap_bool AS CHECKBOX MODIF ID cre,        " G-PRO 수신 이력 있는 것만
              p_test  TYPE abap_bool AS CHECKBOX DEFAULT abap_true MODIF ID cre.  " 테스트(대상 조회만, 생성 안 함)
SELECTION-SCREEN END OF BLOCK b3.

*단가 공백 보정 조건 (P_MGAP)
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-b04.
  PARAMETERS: p_gorg  TYPE ekorg   DEFAULT '1400' MODIF ID gap,       " 구매조직
              p_gwrk  TYPE werks_d DEFAULT '6500' MODIF ID gap,       " 플랜트
              p_ggrp  TYPE ekgrp   DEFAULT 'Z32'  MODIF ID gap,       " PO 구매그룹
              p_gmon  TYPE spmon                  MODIF ID gap,       " 입고 월 (예: 202609)
              p_gbase TYPE datum   DEFAULT sy-datlo MODIF ID gap.     " 정산기준일 (ZGTMMR1100 P_BUDAT)
  SELECT-OPTIONS: s_glif FOR gv_lifnr MODIF ID gap.
  PARAMETERS: p_gtest TYPE abap_bool AS CHECKBOX DEFAULT abap_true MODIF ID gap.  " 테스트(BAPI 후 ROLLBACK)
SELECTION-SCREEN END OF BLOCK b4.


TYPES:
  BEGIN OF ty_out,
    zifkey    TYPE zgtmmt9000-zifkey,
    ifdat     TYPE zgtmmt9000-ifdat,
    iftim     TYPE zgtmmt9000-iftim,
    zstat     TYPE zgtmmt9000-zstat,
    message   TYPE zgtmmt9000-message,
    matnr     TYPE zgtmmt9230-matnr,
    lifnr     TYPE zgtmmt9230-lifnr,
    ekorg     TYPE zgtmmt9230-ekorg,
    werks     TYPE zgtmmt9230-werks,
    esokz     TYPE zgtmmt9230-esokz,
    datab     TYPE zgtmmt9230-datab,
    datbi     TYPE zgtmmt9230-datbi,
    netpr     TYPE zgtmmt9230-netpr,
    waers     TYPE zgtmmt9230-waers,
    peinh     TYPE zgtmmt9230-peinh,
    bprme     TYPE zgtmmt9230-bprme,
    ekgrp     TYPE zgtmmt9230-ekgrp,
    meins     TYPE mara-meins,       " 자재 기본단위
    umrez     TYPE marm-umrez,       " 단가단위 환산 분자
    umren     TYPE marm-umren,       " 단가단위 환산 분모
    infnr     TYPE eina-infnr,       " 현재 인포레코드
    eine_yn   TYPE char1,            " 구매조직/플랜트 EINE 존재
    eine_org  TYPE char1,            " 구매조직 단위(플랜트 공백) EINE만 존재
    cond_cnt  TYPE i,                " 유효기간 겹치는 기존 PB00 조건 수
    cond_info TYPE char80,           " 겹치는 조건 기간
    later_ok  TYPE i,                " 이후 같은 자재·업체·플랜트 성공 수신 건수
    sim_type  TYPE char1,            " 재현 결과 (S/E/W/-)
    sim_msg1  TYPE char255,          " 수정 로직 1단계(플랜트 구매조직 생성) 메시지
    sim_msg   TYPE char255,          " 재현 BAPI 메시지 (수정 로직은 2단계)
    judge     TYPE char255,          " 판단
  END OF ty_out.

TYPES:
  BEGIN OF ty_cre,
    result    TYPE char10,           " 대상 / 생성 / 오류 / 제외
    infnr     TYPE eina-infnr,
    matnr     TYPE eina-matnr,
    lifnr     TYPE eina-lifnr,
    ekorg     TYPE eine-ekorg,
    esokz     TYPE eine-esokz,
    erdat     TYPE eine-erdat,       " 구매조직 단위 EINE 생성일
    ernam     TYPE eine-ernam,
    ebeln     TYPE eine-ebeln,       " 최종 PO
    ebelp     TYPE eine-ebelp,
    werks     TYPE werks_d,          " 생성할 플랜트
    werks_src TYPE char10,           " 입력 / PO
    gpro      TYPE char1,            " G-PRO 수신 이력
    message   TYPE char255,
  END OF ty_cre.

TYPES:
  BEGIN OF ty_gap,
    result   TYPE char10,            " 대상 / 검증OK / 생성 / 오류 / 제외
    lifnr    TYPE lifnr,
    matnr    TYPE matnr,
    werks    TYPE werks_d,
    infnr    TYPE eina-infnr,
    valid_fr TYPE datum,             " 생성할 조건 시작일
    valid_to TYPE datum,
    src      TYPE char10,            " 직전조건 / PO
    price    TYPE bapicurr-bapicurr, " 외부 금액
    waers    TYPE waers,
    perp     TYPE kpein,
    unit     TYPE meins,
    message  TYPE char255,
  END OF ty_gap.

DATA: BEGIN OF ls_prev,
        datbi TYPE a017-datbi,
        kbetr TYPE konp-kbetr,
        konwa TYPE konp-konwa,
        kpein TYPE konp-kpein,
        kmein TYPE konp-kmein,
      END OF ls_prev,
      BEGIN OF ls_po,
        netpr TYPE ekpo-netpr,
        peinh TYPE ekpo-peinh,
        bprme TYPE ekpo-bprme,
        waers TYPE ekko-waers,
      END OF ls_po.

DATA: gt_gap    TYPE STANDARD TABLE OF ty_gap,
      gt_cre    TYPE STANDARD TABLE OF ty_cre,
      gt_out    TYPE STANDARD TABLE OF ty_out,
      gv_single TYPE abap_bool.      " 1건 조회 여부 (P_COMMIT 허용 조건)

*처리 구분에 따라 검색조건 블록 보임/숨김 (블록 안 항목이 모두 숨겨지면 프레임도 숨겨짐)
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF ( screen-group1 = 'CHK' AND p_mchk = abap_false )
    OR ( screen-group1 = 'CRE' AND p_mcre = abap_false )
    OR ( screen-group1 = 'GAP' AND p_mgap = abap_false ).
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.
  IF p_mgap = abap_true.
    PERFORM gap_get.
    PERFORM gap_process.
    PERFORM gap_display.
    RETURN.
  ENDIF.

  IF p_mcre = abap_true.
    PERFORM cre_get.
    PERFORM cre_process.
    PERFORM cre_display.
    RETURN.
  ENDIF.

  PERFORM get_log.
  PERFORM diagnose.
  PERFORM display.

*&---------------------------------------------------------------------*
*& FORM GET_LOG
*&---------------------------------------------------------------------*
FORM get_log.

  DATA: lr_zstat TYPE RANGE OF zgtmmt9000-zstat.

  IF p_err = abap_true.
    lr_zstat = VALUE #( ( sign = 'E' option = 'EQ' low = 'S' ) ).
  ENDIF.

  SELECT n~zifkey, n~ifdat, n~iftim, n~zstat, n~message,
         a~matnr, a~lifnr, a~ekorg, a~werks, a~esokz,
         a~datab, a~datbi, a~netpr, a~waers, a~peinh, a~bprme, a~ekgrp
    FROM zgtmmt9000 AS n
    LEFT OUTER JOIN zgtmmt9230 AS a ON a~zifkey = n~zifkey
    WHERE n~zifno   = 'MM00024'
      AND n~ifdat   IN @s_ifdat
      AND n~zifkey  IN @s_zifkey
      AND n~message IN @s_msg
      AND n~zstat   IN @lr_zstat
    ORDER BY n~ifdat, n~iftim
    INTO CORRESPONDING FIELDS OF TABLE @gt_out
    UP TO @p_max ROWS.

  IF s_matnr[] IS NOT INITIAL.
    DELETE gt_out WHERE matnr NOT IN s_matnr.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DIAGNOSE
*&---------------------------------------------------------------------*
FORM diagnose.

  DATA: lv_matnr18 TYPE matnr18.

  gv_single = xsdbool( lines( gt_out ) = 1 ).
  IF p_commit = abap_true AND ( p_new = abap_false OR gv_single = abap_false ).
    MESSAGE '1단계 실제 반영은 "26.09.27 수정 로직" + 1건 조회일 때만 적용됩니다. 이번 실행은 ROLLBACK으로만 재현합니다.' TYPE 'I'.
  ENDIF.

  LOOP AT gt_out ASSIGNING FIELD-SYMBOL(<ls_out>).

    IF <ls_out>-matnr IS INITIAL.
      <ls_out>-sim_type = '-'.
      <ls_out>-judge = '수신 LOG(9230) 없음 — 재현 불가. 시작 로그 후 덤프 추정(ST22 확인)'.
      CONTINUE.
    ENDIF.

    lv_matnr18 = <ls_out>-matnr.
    lv_matnr18 = |{ lv_matnr18 ALPHA = IN }|.

*1) 자재 기본단위 / 단가단위 환산
    SELECT SINGLE meins FROM mara WHERE matnr = @lv_matnr18 INTO @<ls_out>-meins.

    IF <ls_out>-meins IS NOT INITIAL AND <ls_out>-bprme <> <ls_out>-meins.
      SELECT SINGLE umrez, umren FROM marm
        WHERE matnr = @lv_matnr18 AND meinh = @<ls_out>-bprme
        INTO (@<ls_out>-umrez, @<ls_out>-umren).
    ELSEIF <ls_out>-meins IS NOT INITIAL.
      <ls_out>-umrez = <ls_out>-umren = 1.
    ENDIF.

*2) 현재 인포레코드
    SELECT SINGLE infnr FROM eina
      WHERE matnr = @lv_matnr18 AND lifnr = @<ls_out>-lifnr
      INTO @<ls_out>-infnr.

    IF <ls_out>-infnr IS NOT INITIAL.
      SELECT SINGLE @abap_true FROM eine
        WHERE infnr = @<ls_out>-infnr AND ekorg = @<ls_out>-ekorg
          AND werks = @<ls_out>-werks AND esokz = @<ls_out>-esokz
        INTO @<ls_out>-eine_yn.

      IF <ls_out>-eine_yn IS INITIAL.
        SELECT SINGLE @abap_true FROM eine
          WHERE infnr = @<ls_out>-infnr AND ekorg = @<ls_out>-ekorg
            AND werks = '' AND esokz = @<ls_out>-esokz
          INTO @<ls_out>-eine_org.
      ENDIF.
    ENDIF.

*3) 유효기간이 겹치는 기존 PB00 조건
    SELECT datab, datbi FROM a017
      WHERE kappl = 'M' AND kschl = 'PB00'
        AND lifnr = @<ls_out>-lifnr AND matnr = @lv_matnr18
        AND ekorg = @<ls_out>-ekorg AND werks = @<ls_out>-werks
        AND esokz = @<ls_out>-esokz
        AND datab <= @<ls_out>-datbi AND datbi >= @<ls_out>-datab
      ORDER BY datab
      INTO TABLE @DATA(lt_a017).
    <ls_out>-cond_cnt = lines( lt_a017 ).
    LOOP AT lt_a017 INTO DATA(ls_a017) TO 3.
      <ls_out>-cond_info = |{ <ls_out>-cond_info } { ls_a017-datab }~{ ls_a017-datbi }|.
    ENDLOOP.

*4) 이후 성공 수신
    SELECT COUNT(*) FROM zgtmmt9000 AS n
      INNER JOIN zgtmmt9230 AS a ON a~zifkey = n~zifkey
      WHERE n~zifno = 'MM00024' AND n~zstat = 'S'
        AND n~zifkey > @<ls_out>-zifkey
        AND a~matnr = @<ls_out>-matnr AND a~lifnr = @<ls_out>-lifnr
        AND a~werks = @<ls_out>-werks
      INTO @<ls_out>-later_ok.

*5) BAPI 재현
    IF p_none = abap_false.
      PERFORM simulate USING lv_matnr18 CHANGING <ls_out>.
    ELSE.
      <ls_out>-sim_type = '-'.
    ENDIF.

    PERFORM judge CHANGING <ls_out>.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM SIMULATE
*&---------------------------------------------------------------------*
*& FG10 SET_INFORECORD(PTYPE=B)와 같은 값으로 BAPI 호출 후 항상 ROLLBACK
*&---------------------------------------------------------------------*
FORM simulate USING pv_matnr TYPE matnr18
              CHANGING ps_out TYPE ty_out.

  DATA: ls_eina       TYPE mewieina,
        ls_eeina      TYPE mewieina,
        ls_einax      TYPE mewieinax,
        ls_eine       TYPE mewieine,
        ls_eeine      TYPE mewieine,
        ls_einex      TYPE mewieinex,
        lt_validity   TYPE TABLE OF mewivalidity,
        lt_condition  TYPE TABLE OF mewicondition,
        lt_rtn        TYPE TABLE OF bapireturn,
        lv_amt_ext    TYPE bapicurr-bapicurr,
        lv_amt_int    TYPE matdoc-dmbtr,
        lv_land       TYPE lfa1-land1,
        lv_new_plant  TYPE abap_bool,        " 1단계 COMMIT됨 → 2단계는 새 세션
        lv_rfc_msg    TYPE c LENGTH 200.

  IF ps_out-meins IS INITIAL.
    ps_out-sim_type = '-'.
    ps_out-sim_msg  = '기본단위 없음 — FM에서 ZMM815로 중단되는 케이스'.
    RETURN.
  ENDIF.
  IF ps_out-umrez IS INITIAL.
    ps_out-sim_type = '-'.
    ps_out-sim_msg  = |단가단위 { ps_out-bprme } 환산계수 없음 — FM에서 ZMM816으로 중단되는 케이스|.
    RETURN.
  ENDIF.

  SELECT SINGLE * FROM zgtmmt9231
    WHERE zifkey = @ps_out-zifkey AND werks = @ps_out-werks
    INTO @DATA(ls_9231).
  IF sy-subrc <> 0.
    ls_9231-werks = ps_out-werks.
  ENDIF.

  SELECT SINGLE land1 FROM lfa1 WHERE lifnr = @ps_out-lifnr INTO @lv_land.

*EINA — 9월 수정 이후: 기존 INFNR 지정 / 이전: 미지정
  IF p_old = abap_false AND ps_out-infnr IS NOT INITIAL.
    ls_eina  = VALUE #( info_rec = ps_out-infnr material = pv_matnr vendor = ps_out-lifnr ).
    ls_einax = VALUE #( info_rec = abap_true material = abap_true vendor = abap_true ).
  ELSE.
    ls_eina  = VALUE #( material = pv_matnr vendor = ps_out-lifnr ).
    ls_einax = VALUE #( material = abap_true vendor = abap_true ).
  ENDIF.

*EINE — SET_INFORECORD와 동일 규칙
  ls_eine = VALUE #(
    purch_org  = ps_out-ekorg
    plant      = ls_9231-werks
    info_type  = ps_out-esokz
    delete_ind = ''
    currency   = ps_out-waers
    pur_group  = ps_out-ekgrp
    plnd_delry = COND #( WHEN ls_9231-aplfz IS INITIAL THEN 1 ELSE ls_9231-aplfz )
    overdeltol = ls_9231-uebto
    under_tol  = ls_9231-untto
    unlimited  = ls_9231-uebtk
    ackn_reqd  = ls_9231-kzabs
    conf_ctrl  = ls_9231-bstae
    nrm_po_qty = COND #( WHEN ls_9231-norbm IS INITIAL THEN 1 ELSE ls_9231-norbm )
    min_po_qty = ls_9231-minbm
    tax_code   = COND #( WHEN ls_9231-mwskz IS INITIAL AND lv_land = 'KR' THEN 'VA'
                         WHEN ls_9231-mwskz IS INITIAL THEN 'V0'
                         ELSE ls_9231-mwskz )
    pricedate  = COND #( WHEN ls_9231-meprf IS INITIAL AND lv_land = 'KR' THEN '5'
                         WHEN ls_9231-meprf IS INITIAL THEN space
                         ELSE ls_9231-meprf )
    incoterms1 = ls_9231-inco1
    gr_basediv = COND #( WHEN ls_9231-webre IS INITIAL AND lv_land = 'KR' THEN abap_true
                         WHEN ls_9231-webre IS INITIAL THEN space
                         ELSE ls_9231-webre )
    version    = COND #( WHEN ps_out-esokz = '3' THEN 'SC01' ELSE space ) ).

  ls_einex = VALUE #(
    purch_org  = abap_true
    plant      = abap_true
    info_type  = abap_true
    delete_ind = abap_true
    currency   = abap_true
    pur_group  = abap_true
    plnd_delry = abap_true
    overdeltol = COND #( WHEN ls_9231-uebto IS INITIAL THEN space ELSE abap_true )
    under_tol  = COND #( WHEN ls_9231-untto IS INITIAL THEN space ELSE abap_true )
    unlimited  = COND #( WHEN ls_9231-uebtk IS INITIAL THEN space ELSE abap_true )
    ackn_reqd  = COND #( WHEN ls_9231-kzabs IS INITIAL THEN space ELSE abap_true )
    conf_ctrl  = COND #( WHEN ls_9231-bstae IS INITIAL THEN space ELSE abap_true )
    nrm_po_qty = abap_true
    min_po_qty = COND #( WHEN ls_9231-minbm IS INITIAL THEN space ELSE abap_true )
    tax_code   = abap_true
    pricedate  = abap_true
    incoterms1 = COND #( WHEN ls_9231-inco1 IS INITIAL THEN space ELSE abap_true )
    gr_basediv = abap_true
    version    = COND #( WHEN ps_out-esokz = '3' THEN abap_true ELSE space ) ).

*26.09.27 수정 로직 — 플랜트 구매조직 데이터가 없으면 조건 없이 먼저 생성 (1단계)
*  기본: COMMIT 없이 같은 LUW에서 2단계 진행 후 ROLLBACK
*  P_COMMIT(1건 조회 시만): 1단계를 실제 COMMIT → FG10 수정 로직과 같은 순서로 2단계 재현
  IF p_new = abap_true AND ps_out-infnr IS NOT INITIAL AND ps_out-eine_yn IS INITIAL.
    CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
      EXPORTING
        i_eina        = ls_eina
        i_einax       = ls_einax
        i_eine        = ls_eine
        i_einex       = ls_einex
      TABLES
        cond_validity = lt_validity      " 빈 테이블
        condition     = lt_condition     " 빈 테이블
        return        = lt_rtn.

    DATA(lv_err1) = xsdbool( line_exists( lt_rtn[ type = 'E' ] ) OR line_exists( lt_rtn[ type = 'A' ] ) ).
    ps_out-sim_msg1 = COND #( WHEN lv_err1 = abap_true THEN `실패: ` ELSE `성공: ` ).
    PERFORM append_msg TABLES lt_rtn CHANGING ps_out-sim_msg1.

    IF lv_err1 = abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      CALL FUNCTION 'DEQUEUE_ALL'.
      ps_out-sim_type = 'E'.
      ps_out-sim_msg  = '1단계 실패로 2단계 미실행'.
      RETURN.
    ENDIF.

    IF p_commit = abap_true AND gv_single = abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
      ps_out-sim_msg1 = |{ ps_out-sim_msg1 } ※ 실제 반영(COMMIT)됨|.
      lv_new_plant = abap_true.
    ENDIF.
    CLEAR lt_rtn.
  ENDIF.

  APPEND VALUE #( serial_id  = '01'
                  plant      = ls_9231-werks
                  base_uom   = ps_out-meins
                  valid_from = ps_out-datab
                  valid_to   = ps_out-datbi ) TO lt_validity.

*9230 NETPR은 내부값 → BAPI에는 수신 당시와 같은 외부값으로 전달
  lv_amt_int = ps_out-netpr.
  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
    EXPORTING
      currency        = ps_out-waers
      amount_internal = lv_amt_int
    IMPORTING
      amount_external = lv_amt_ext.

  APPEND VALUE #( serial_id   = '01'
                  cond_type   = 'PB00'
                  cond_value  = lv_amt_ext
                  currency    = ps_out-waers
                  cond_p_unt  = ps_out-peinh
                  cond_unit   = ps_out-bprme
                  base_uom    = ps_out-meins
                  numerator   = ps_out-umrez
                  denominator = ps_out-umren ) TO lt_condition.

*1단계를 실제 COMMIT한 경우: FG10과 같이 새 세션(DESTINATION 'NONE')에서 2단계, 래퍼가 ROLLBACK
  IF lv_new_plant = abap_true.
    CALL FUNCTION 'ZGTMM_IF_I_INFODATA_MAINTAIN' DESTINATION 'NONE'
      EXPORTING
        i_eina                = ls_eina
        i_einax               = ls_einax
        i_eine                = ls_eine
        i_einex               = ls_einex
        i_test                = abap_true
      IMPORTING
        e_eina                = ls_eeina
        e_eine                = ls_eeine
      TABLES
        cond_validity         = lt_validity
        condition             = lt_condition
        return                = lt_rtn
      EXCEPTIONS
        system_failure        = 1 MESSAGE lv_rfc_msg
        communication_failure = 2 MESSAGE lv_rfc_msg
        OTHERS                = 3.
    IF sy-subrc <> 0.
      APPEND VALUE #( type = 'E' message = |새 세션 호출 실패: { lv_rfc_msg }| ) TO lt_rtn.
    ENDIF.
    CALL FUNCTION 'RFC_CONNECTION_CLOSE'
      EXPORTING
        destination = 'NONE'
      EXCEPTIONS
        OTHERS      = 1.
    ps_out-sim_msg = '(새 세션) '.
  ELSE.
    CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
      EXPORTING
        i_eina        = ls_eina
        i_einax       = ls_einax
        i_eine        = ls_eine
        i_einex       = ls_einex
      IMPORTING
        e_eina        = ls_eeina
        e_eine        = ls_eeine
      TABLES
        cond_validity = lt_validity
        condition     = lt_condition
        return        = lt_rtn.
  ENDIF.

*항상 ROLLBACK — DB 미반영
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  CALL FUNCTION 'DEQUEUE_ALL'.

  ps_out-sim_type = COND #( WHEN line_exists( lt_rtn[ type = 'E' ] ) OR line_exists( lt_rtn[ type = 'A' ] )
                              OR line_exists( lt_rtn[ code = '06725' ] ) THEN 'E'
                            WHEN line_exists( lt_rtn[ type = 'W' ] ) THEN 'W'
                            ELSE 'S' ).
  PERFORM append_msg TABLES lt_rtn CHANGING ps_out-sim_msg.
  IF ps_out-sim_msg IS INITIAL.
    ps_out-sim_msg = |반환 메시지 없음 (INFNR { ls_eeina-info_rec })|.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM APPEND_MSG
*&---------------------------------------------------------------------*
*& BAPI 반환 메시지 연결 — 매번 나오는 무해한 경고(AM483 주소텍스트,
*& 06340 단위/환산 점검)는 제외
*&---------------------------------------------------------------------*
FORM append_msg TABLES pt_rtn STRUCTURE bapireturn
                CHANGING pv_msg TYPE char255.

  LOOP AT pt_rtn INTO DATA(ls_rtn).
    CHECK NOT ( ls_rtn-type = 'W' AND ( ls_rtn-code = 'AM483' OR ls_rtn-code = '06340' ) ).
    pv_msg = |{ pv_msg }[{ ls_rtn-type } { ls_rtn-code }] { ls_rtn-message } / |.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM JUDGE
*&---------------------------------------------------------------------*
FORM judge CHANGING ps_out TYPE ty_out.

  DATA: lt_txt TYPE STANDARD TABLE OF string.

  IF ps_out-meins IS INITIAL.
    APPEND `자재 기본단위 없음(MARA)` TO lt_txt.
  ELSEIF ps_out-umrez IS INITIAL.
    APPEND |단가단위 { ps_out-bprme } ↔ 기본단위 { ps_out-meins } 환산 없음(MARM)| TO lt_txt.
  ENDIF.

  IF ps_out-eine_org = abap_true.
    APPEND |플랜트 { ps_out-werks } 구매조직 데이터 없음(구매조직 단위만 존재, 06725) — ME816 원인. FG10 26.09.27 수정(플랜트 데이터 선생성)으로 해결 대상| TO lt_txt.
  ELSEIF ps_out-infnr IS NOT INITIAL AND ps_out-eine_yn IS INITIAL.
    APPEND |플랜트 { ps_out-werks } 구매조직 데이터 없음| TO lt_txt.
  ENDIF.

  IF ps_out-cond_cnt > 0.
    APPEND |유효기간 겹치는 기존 PB00 조건 { ps_out-cond_cnt }건| TO lt_txt.
  ENDIF.

  CASE ps_out-sim_type.
    WHEN 'E'.
      APPEND `현재 DB 기준 재현해도 오류 — 메시지로 원인 확인` TO lt_txt.
    WHEN 'S' OR 'W'.
      IF ps_out-zstat <> 'S'.
        APPEND `현재 DB 기준 재현 성공 — 실패 당시와 데이터 상태가 달라짐(이후 인포레코드·조건 생성 등)` TO lt_txt.
      ENDIF.
  ENDCASE.

  IF ps_out-zstat <> 'S'.
    APPEND COND string( WHEN ps_out-later_ok > 0 THEN |이후 성공 수신 { ps_out-later_ok }건|
                        ELSE `이후 성공 수신 없음 — 누락 여부 확인 필요` ) TO lt_txt.
  ENDIF.

  ps_out-judge = concat_lines_of( table = lt_txt sep = ` / ` ).

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM DISPLAY
*&---------------------------------------------------------------------*
FORM display.

  DATA: lo_alv TYPE REF TO cl_salv_table.

  IF gt_out IS INITIAL.
    MESSAGE '조건에 맞는 로그가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_alv
                              CHANGING  t_table      = gt_out ).
    CATCH cx_salv_msg.
      RETURN.
  ENDTRY.

  DATA(lo_cols) = lo_alv->get_columns( ).
  lo_cols->set_optimize( abap_true ).

  DEFINE _col.
    TRY.
        lo_cols->get_column( &1 )->set_long_text( &2 ).
        lo_cols->get_column( &1 )->set_medium_text( CONV #( &2 ) ).
        lo_cols->get_column( &1 )->set_short_text( CONV #( &2 ) ).
      CATCH cx_salv_not_found.
    ENDTRY.
  END-OF-DEFINITION.

  _col: 'MEINS'     '기본단위',
        'UMREZ'     '환산분자',
        'UMREN'     '환산분모',
        'INFNR'     '현재 인포레코드',
        'EINE_ORG'  '구매조직단위만',
        'EINE_YN'   'EINE 존재',
        'COND_CNT'  '겹치는 PB00',
        'COND_INFO' '겹치는 조건 기간',
        'LATER_OK'  '이후 성공',
        'SIM_TYPE'  '재현결과',
        'SIM_MSG1'  '1단계메시지',
        'SIM_MSG'   '재현메시지',
        'JUDGE'     '판단'.

  lo_alv->get_functions( )->set_all( abap_true ).
  DATA lv_title TYPE lvc_title.
  lv_title = |INFODATA_RCV 오류 원인 확인 — { lines( gt_out ) }건|
          && COND string( WHEN p_cur = abap_true THEN ` (BAPI 재현: 현재 로직, ROLLBACK)`
                          WHEN p_old = abap_true THEN ` (BAPI 재현: 9월 수정 이전 로직, ROLLBACK)`
                          WHEN p_new = abap_true THEN ` (BAPI 재현: 수정 로직 — 플랜트 선생성, ROLLBACK)`
                          ELSE ` (재현 안 함)` ).
  lo_alv->get_display_settings( )->set_list_header( lv_title ).
  lo_alv->display( ).

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CRE_GET
*&---------------------------------------------------------------------*
*& 구매조직 단위(플랜트 공백) EINE만 있고 플랜트 EINE가 하나도 없는 인포레코드
*&---------------------------------------------------------------------*
FORM cre_get.

  SELECT e~infnr, a~matnr, a~lifnr, e~ekorg, e~esokz,
         e~erdat, e~ernam, e~ebeln, e~ebelp
    FROM eine AS e
    INNER JOIN eina AS a ON a~infnr = e~infnr
    WHERE e~werks = ''
      AND e~loekz = ''
      AND e~ekorg IN @s_ekorg
      AND e~infnr IN @s_infnr
      AND e~erdat IN @s_erdat
      AND a~matnr IN @s_matn2
      AND a~lifnr IN @s_lifnr
      AND a~loekz = ''
      AND NOT EXISTS ( SELECT infnr FROM eine AS p
                        WHERE p~infnr = e~infnr
                          AND p~ekorg = e~ekorg
                          AND p~esokz = e~esokz
                          AND p~werks <> '' )
    ORDER BY e~infnr, e~ekorg, e~esokz
    INTO CORRESPONDING FIELDS OF TABLE @gt_cre.

  LOOP AT gt_cre ASSIGNING FIELD-SYMBOL(<ls_cre>).
*G-PRO 수신 이력 (9230 MATNR는 ALPHA OUT 저장)
    DATA(lv_matnr_out) = |{ <ls_cre>-matnr ALPHA = OUT }|.
    SELECT SINGLE @abap_true FROM zgtmmt9230
      WHERE matnr = @lv_matnr_out AND lifnr = @<ls_cre>-lifnr
      INTO @<ls_cre>-gpro.

*생성할 플랜트: 입력값 우선, 없으면 최종 PO 품목 플랜트
    IF p_werks IS NOT INITIAL.
      <ls_cre>-werks     = p_werks.
      <ls_cre>-werks_src = '입력'.
    ELSEIF <ls_cre>-ebeln IS NOT INITIAL.
      SELECT SINGLE werks FROM ekpo
        WHERE ebeln = @<ls_cre>-ebeln AND ebelp = @<ls_cre>-ebelp
        INTO @<ls_cre>-werks.
      <ls_cre>-werks_src = 'PO'.
    ENDIF.

    IF <ls_cre>-werks IS INITIAL.
      <ls_cre>-result  = '제외'.
      <ls_cre>-message = '플랜트를 정할 수 없음 — 최종 PO 없음. 플랜트 입력 후 재실행'.
    ELSE.
      <ls_cre>-result  = '대상'.
    ENDIF.
  ENDLOOP.

  IF p_gpro = abap_true.
    DELETE gt_cre WHERE gpro IS INITIAL.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CRE_PROCESS
*&---------------------------------------------------------------------*
*& 구매조직 단위 EINE 값을 복사해 플랜트 EINE 생성 (조건 없이), 행별 COMMIT
*& 생성 결과는 DB 재조회로 확인 (BAPI가 06725만 주고 생성하지 않는 경우 대비)
*&---------------------------------------------------------------------*
FORM cre_process.

  DATA: ls_eina  TYPE mewieina,
        ls_einax TYPE mewieinax,
        ls_eine  TYPE mewieine,
        ls_einex TYPE mewieinex,
        lt_val   TYPE TABLE OF mewivalidity,
        lt_cond  TYPE TABLE OF mewicondition,
        lt_rtn   TYPE TABLE OF bapireturn.

  CHECK p_test = abap_false.

  LOOP AT gt_cre ASSIGNING FIELD-SYMBOL(<ls_cre>) WHERE result = '대상'.

    SELECT SINGLE * FROM eine
      WHERE infnr = @<ls_cre>-infnr AND ekorg = @<ls_cre>-ekorg
        AND esokz = @<ls_cre>-esokz AND werks = ''
      INTO @DATA(ls_org).

    ls_eina  = VALUE #( info_rec = <ls_cre>-infnr material = <ls_cre>-matnr vendor = <ls_cre>-lifnr ).
    ls_einax = VALUE #( info_rec = abap_true material = abap_true vendor = abap_true ).

    ls_eine = VALUE #( purch_org  = <ls_cre>-ekorg
                       plant      = <ls_cre>-werks
                       info_type  = <ls_cre>-esokz
                       currency   = ls_org-waers
                       pur_group  = ls_org-ekgrp
                       plnd_delry = ls_org-aplfz
                       nrm_po_qty = ls_org-norbm
                       min_po_qty = ls_org-minbm
                       overdeltol = ls_org-uebto
                       under_tol  = ls_org-untto
                       unlimited  = ls_org-uebtk
                       ackn_reqd  = ls_org-kzabs
                       conf_ctrl  = ls_org-bstae
                       tax_code   = ls_org-mwskz
                       pricedate  = ls_org-meprf
                       incoterms1 = ls_org-inco1
                       gr_basediv = ls_org-webre
                       no_aut_gr  = ls_org-xersn ).

    ls_einex = VALUE #( purch_org  = abap_true
                        plant      = abap_true
                        info_type  = abap_true
                        currency   = xsdbool( ls_org-waers IS NOT INITIAL )
                        pur_group  = xsdbool( ls_org-ekgrp IS NOT INITIAL )
                        plnd_delry = xsdbool( ls_org-aplfz IS NOT INITIAL )
                        nrm_po_qty = xsdbool( ls_org-norbm IS NOT INITIAL )
                        min_po_qty = xsdbool( ls_org-minbm IS NOT INITIAL )
                        overdeltol = xsdbool( ls_org-uebto IS NOT INITIAL )
                        under_tol  = xsdbool( ls_org-untto IS NOT INITIAL )
                        unlimited  = xsdbool( ls_org-uebtk IS NOT INITIAL )
                        ackn_reqd  = xsdbool( ls_org-kzabs IS NOT INITIAL )
                        conf_ctrl  = xsdbool( ls_org-bstae IS NOT INITIAL )
                        tax_code   = xsdbool( ls_org-mwskz IS NOT INITIAL )
                        pricedate  = xsdbool( ls_org-meprf IS NOT INITIAL )
                        incoterms1 = xsdbool( ls_org-inco1 IS NOT INITIAL )
                        gr_basediv = xsdbool( ls_org-webre IS NOT INITIAL )
                        no_aut_gr  = xsdbool( ls_org-xersn IS NOT INITIAL ) ).

    CLEAR: lt_val, lt_cond, lt_rtn.
    CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
      EXPORTING
        i_eina        = ls_eina
        i_einax       = ls_einax
        i_eine        = ls_eine
        i_einex       = ls_einex
      TABLES
        cond_validity = lt_val
        condition     = lt_cond
        return        = lt_rtn.

    IF line_exists( lt_rtn[ type = 'E' ] ) OR line_exists( lt_rtn[ type = 'A' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      <ls_cre>-result = '오류'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
*실제 생성 확인
      SELECT SINGLE @abap_true FROM eine
        WHERE infnr = @<ls_cre>-infnr AND ekorg = @<ls_cre>-ekorg
          AND esokz = @<ls_cre>-esokz AND werks = @<ls_cre>-werks
        INTO @DATA(lv_ok).
      IF sy-subrc = 0.
        <ls_cre>-result = '생성'.
      ELSE.
        <ls_cre>-result  = '오류'.
        <ls_cre>-message = 'BAPI 오류 없이 끝났으나 플랜트 구매조직 데이터가 생성되지 않음 / '.
      ENDIF.
      CLEAR lv_ok.
    ENDIF.
    CALL FUNCTION 'DEQUEUE_ALL'.

    PERFORM append_msg TABLES lt_rtn CHANGING <ls_cre>-message.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CRE_DISPLAY
*&---------------------------------------------------------------------*
FORM cre_display.

  DATA: lo_alv TYPE REF TO cl_salv_table.

  IF gt_cre IS INITIAL.
    MESSAGE '구매조직 단위만 있는 인포레코드가 없습니다.' TYPE 'S'.
    RETURN.
  ENDIF.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_alv
                              CHANGING  t_table      = gt_cre ).
    CATCH cx_salv_msg.
      RETURN.
  ENDTRY.

  DATA(lo_cols) = lo_alv->get_columns( ).
  lo_cols->set_optimize( abap_true ).

  DEFINE _col.
    TRY.
        lo_cols->get_column( &1 )->set_long_text( &2 ).
        lo_cols->get_column( &1 )->set_medium_text( CONV #( &2 ) ).
        lo_cols->get_column( &1 )->set_short_text( CONV #( &2 ) ).
      CATCH cx_salv_not_found.
    ENDTRY.
  END-OF-DEFINITION.

  _col: 'RESULT'    '결과',
        'ERDAT'     '구매조직단위 생성일',
        'ERNAM'     '생성자',
        'EBELN'     '최종 PO',
        'EBELP'     'PO 품목',
        'WERKS'     '생성 플랜트',
        'WERKS_SRC' '플랜트 출처',
        'GPRO'      'G-PRO 이력',
        'MESSAGE'   '메시지'.

  DATA(lv_cnt_all) = lines( gt_cre ).
  DATA(lv_cnt_ok)  = REDUCE i( INIT n = 0 FOR r IN gt_cre WHERE ( result = '생성' ) NEXT n = n + 1 ).
  DATA(lv_cnt_err) = REDUCE i( INIT n = 0 FOR r IN gt_cre WHERE ( result = '오류' ) NEXT n = n + 1 ).

  lo_alv->get_functions( )->set_all( abap_true ).
  DATA lv_title TYPE lvc_title.
  IF p_test = abap_true.
    lv_title = |플랜트 구매조직 데이터 일괄 생성 — 테스트(대상 조회) { lv_cnt_all }건|.
  ELSE.
    lv_title = |플랜트 구매조직 데이터 일괄 생성 — 생성 { lv_cnt_ok } / 오류 { lv_cnt_err } / 전체 { lv_cnt_all }건|.
  ENDIF.
  lo_alv->get_display_settings( )->set_list_header( lv_title ).
  lo_alv->display( ).

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GAP_GET
*&---------------------------------------------------------------------*
*& 정산월 입고 대상 중 기준일에 유효한 PB00 조건(삭제 표시 아님)이 없는 건과 보정값 산출
*&---------------------------------------------------------------------*
FORM gap_get.

  DATA: lv_from TYPE datum,
        lv_to   TYPE datum,
        lv_int  TYPE matdoc-dmbtr.

  IF p_gmon IS INITIAL.
    MESSAGE '입고 월을 입력하세요.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  lv_from = |{ p_gmon }01|.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_from
    IMPORTING
      last_day_of_month = lv_to
    EXCEPTIONS
      OTHERS            = 1.
  IF sy-subrc <> 0.
    MESSAGE '입고 월 형식 오류' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  SELECT DISTINCT k~lifnr, b~matnr, b~werks
    FROM ekbe AS b
    INNER JOIN ekko AS k ON k~ebeln = b~ebeln
    INNER JOIN mara AS m ON m~matnr = b~matnr
    WHERE k~ekgrp = @p_ggrp
      AND k~ekorg = @p_gorg
      AND k~lifnr IN @s_glif
      AND b~werks = @p_gwrk
      AND b~vgabe = '1'
      AND b~bewtp = 'E'
      AND b~budat BETWEEN @lv_from AND @lv_to
      AND m~lvorm = ''
      AND m~mtart IN ('MCFE', 'MCHA', 'HAWA')
    INTO TABLE @DATA(lt_tgt).

  LOOP AT lt_tgt ASSIGNING FIELD-SYMBOL(<ls_tgt>).

*ZGTMMR1100에 보이는 조건: 기준일 유효 + 삭제 표시 아님 → 정상이면 제외
    SELECT SINGLE @abap_true
      FROM a017 AS a
      INNER JOIN konp AS p ON p~knumh = a~knumh AND p~kappl = a~kappl AND p~kschl = a~kschl
      WHERE a~kappl = 'M' AND a~kschl = 'PB00'
        AND a~lifnr = @<ls_tgt>-lifnr AND a~matnr = @<ls_tgt>-matnr
        AND a~ekorg = @p_gorg AND a~werks = @<ls_tgt>-werks AND a~esokz = '0'
        AND a~datab <= @p_gbase AND a~datbi >= @p_gbase
        AND p~loevm_ko = ''
      INTO @DATA(lv_vis).
    CHECK sy-subrc <> 0.

    APPEND INITIAL LINE TO gt_gap ASSIGNING FIELD-SYMBOL(<ls_gap>).
    <ls_gap>-lifnr = <ls_tgt>-lifnr.
    <ls_gap>-matnr = <ls_tgt>-matnr.
    <ls_gap>-werks = <ls_tgt>-werks.

*플랜트 구매조직 데이터(삭제 표시 아님) 확인
    SELECT SINGLE a~infnr
      FROM eina AS a
      INNER JOIN eine AS e ON e~infnr = a~infnr
      WHERE a~lifnr = @<ls_tgt>-lifnr AND a~matnr = @<ls_tgt>-matnr AND a~loekz = ''
        AND e~ekorg = @p_gorg AND e~werks = @<ls_tgt>-werks AND e~esokz = '0' AND e~loekz = ''
      INTO @<ls_gap>-infnr.
    IF sy-subrc <> 0.
      <ls_gap>-result  = '제외'.
      <ls_gap>-message = '플랜트 구매조직 데이터(EINE) 또는 인포레코드 없음 — P_MCRE 먼저 실행 후 재실행'.
      CONTINUE.
    ENDIF.

*직전 정상 조건: 기준일 이전에 끝난 삭제 표시 아닌 조건 중 가장 늦은 것
    CLEAR ls_prev.
    SELECT a~datbi, p~kbetr, p~konwa, p~kpein, p~kmein
      FROM a017 AS a
      INNER JOIN konp AS p ON p~knumh = a~knumh AND p~kappl = a~kappl AND p~kschl = a~kschl
      WHERE a~kappl = 'M' AND a~kschl = 'PB00'
        AND a~lifnr = @<ls_tgt>-lifnr AND a~matnr = @<ls_tgt>-matnr
        AND a~ekorg = @p_gorg AND a~werks = @<ls_tgt>-werks AND a~esokz = '0'
        AND a~datbi < @p_gbase
        AND p~loevm_ko = ''
      ORDER BY a~datbi DESCENDING
      INTO @ls_prev
      UP TO 1 ROWS.
    ENDSELECT.

    IF ls_prev-kbetr > 0.
      <ls_gap>-src      = '직전조건'.
      <ls_gap>-valid_fr = ls_prev-datbi + 1.
      <ls_gap>-waers    = ls_prev-konwa.
      <ls_gap>-perp     = ls_prev-kpein.
      <ls_gap>-unit     = ls_prev-kmein.
      lv_int            = ls_prev-kbetr.
    ELSE.
*직전 조건이 없으면 최근 PO 단가
      CLEAR ls_po.
      SELECT p~netpr, p~peinh, p~bprme, k~waers
        FROM ekpo AS p
        INNER JOIN ekko AS k ON k~ebeln = p~ebeln
        WHERE k~lifnr = @<ls_tgt>-lifnr AND p~matnr = @<ls_tgt>-matnr
          AND p~werks = @<ls_tgt>-werks AND k~ekorg = @p_gorg
          AND p~loekz = '' AND p~netpr > 0
        ORDER BY k~bedat DESCENDING, p~ebeln DESCENDING, p~ebelp DESCENDING
        INTO @ls_po
        UP TO 1 ROWS.
      ENDSELECT.
      IF ls_po-netpr <= 0.
        <ls_gap>-result  = '제외'.
        <ls_gap>-message = '직전 조건과 PO 단가가 모두 없음 — 단가 확인 필요'.
        CONTINUE.
      ENDIF.
      <ls_gap>-src      = 'PO'.
      <ls_gap>-valid_fr = lv_from.
      <ls_gap>-waers    = ls_po-waers.
      <ls_gap>-perp     = ls_po-peinh.
      <ls_gap>-unit     = ls_po-bprme.
      lv_int            = ls_po-netpr.
    ENDIF.

    IF <ls_gap>-valid_fr > p_gbase.
      <ls_gap>-valid_fr = lv_from.
    ENDIF.
    <ls_gap>-valid_to = '99991231'.

    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
      EXPORTING
        currency        = <ls_gap>-waers
        amount_internal = lv_int
      IMPORTING
        amount_external = <ls_gap>-price.

    <ls_gap>-result = '대상'.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GAP_PROCESS
*&---------------------------------------------------------------------*
*& ZGTMMR1100 저장 로직과 같은 방식으로 PB00 조건 생성
*& 테스트: 항상 ROLLBACK / 실행: 행별 COMMIT, 기준일 조회로 확인
*&---------------------------------------------------------------------*
FORM gap_process.

  DATA: ls_eina  TYPE mewieina,
        ls_einax TYPE mewieinax,
        ls_eine  TYPE mewieine,
        ls_einex TYPE mewieinex,
        ls_eeina TYPE mewieina,
        ls_eeine TYPE mewieine,
        lt_val   TYPE TABLE OF mewivalidity,
        lt_cond  TYPE TABLE OF mewicondition,
        lt_rtn   TYPE TABLE OF bapireturn.

  LOOP AT gt_gap ASSIGNING FIELD-SYMBOL(<ls_gap>) WHERE result = '대상'.

    ls_eina  = VALUE #( material = <ls_gap>-matnr vendor = <ls_gap>-lifnr ).
    ls_einax = VALUE #( material = abap_true vendor = abap_true ).
    ls_eine  = VALUE #( purch_org = p_gorg plant = <ls_gap>-werks info_type = '0' ).
    ls_einex = VALUE #( purch_org = abap_true plant = abap_true info_type = abap_true ).

    CLEAR: lt_val, lt_cond, lt_rtn.
    APPEND VALUE #( valid_from = <ls_gap>-valid_fr
                    valid_to   = <ls_gap>-valid_to ) TO lt_val.
    APPEND VALUE #( cond_type  = 'PB00'
                    cond_value = <ls_gap>-price
                    currency   = <ls_gap>-waers
                    cond_p_unt = <ls_gap>-perp
                    cond_unit  = <ls_gap>-unit ) TO lt_cond.

    CALL FUNCTION 'ME_INFORECORD_MAINTAIN'
      EXPORTING
        i_eina        = ls_eina
        i_einax       = ls_einax
        i_eine        = ls_eine
        i_einex       = ls_einex
      IMPORTING
        e_eina        = ls_eeina
        e_eine        = ls_eeine
      TABLES
        cond_validity = lt_val
        condition     = lt_cond
        return        = lt_rtn.

    IF line_exists( lt_rtn[ type = 'E' ] ) OR line_exists( lt_rtn[ type = 'A' ] )
    OR line_exists( lt_rtn[ code = '06725' ] ) OR ls_eeina-info_rec IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      <ls_gap>-result = '오류'.
    ELSEIF p_gtest = abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      <ls_gap>-result = '검증OK'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
      SELECT SINGLE @abap_true
        FROM a017 AS a
        INNER JOIN konp AS p ON p~knumh = a~knumh AND p~kappl = a~kappl AND p~kschl = a~kschl
        WHERE a~kappl = 'M' AND a~kschl = 'PB00'
          AND a~lifnr = @<ls_gap>-lifnr AND a~matnr = @<ls_gap>-matnr
          AND a~ekorg = @p_gorg AND a~werks = @<ls_gap>-werks AND a~esokz = '0'
          AND a~datab <= @p_gbase AND a~datbi >= @p_gbase
          AND p~loevm_ko = ''
        INTO @DATA(lv_ok).
      IF sy-subrc = 0.
        <ls_gap>-result = '생성'.
      ELSE.
        <ls_gap>-result  = '오류'.
        <ls_gap>-message = 'BAPI 오류 없이 끝났으나 기준일 유효 조건이 확인되지 않음 / '.
      ENDIF.
      CLEAR lv_ok.
    ENDIF.
    CALL FUNCTION 'DEQUEUE_ALL'.

    PERFORM append_msg TABLES lt_rtn CHANGING <ls_gap>-message.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& FORM GAP_DISPLAY
*&---------------------------------------------------------------------*
FORM gap_display.

  DATA: lo_alv TYPE REF TO cl_salv_table.

  IF gt_gap IS INITIAL.
    MESSAGE '기준일에 유효한 단가가 없는 대상이 없습니다.' TYPE 'S'.
    RETURN.
  ENDIF.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_alv
                              CHANGING  t_table      = gt_gap ).
    CATCH cx_salv_msg.
      RETURN.
  ENDTRY.

  DATA(lo_cols) = lo_alv->get_columns( ).
  lo_cols->set_optimize( abap_true ).

  DEFINE _gcol.
    TRY.
        lo_cols->get_column( &1 )->set_long_text( &2 ).
        lo_cols->get_column( &1 )->set_medium_text( CONV #( &2 ) ).
        lo_cols->get_column( &1 )->set_short_text( CONV #( &2 ) ).
      CATCH cx_salv_not_found.
    ENDTRY.
  END-OF-DEFINITION.

  _gcol: 'RESULT'   '결과',
         'INFNR'    '인포레코드',
         'VALID_FR' '조건 시작일',
         'VALID_TO' '조건 종료일',
         'SRC'      '단가 출처',
         'PRICE'    '단가(외부)',
         'PERP'     'PER',
         'UNIT'     '단가단위',
         'MESSAGE'  '메시지'.

  DATA(lv_all) = lines( gt_gap ).
  DATA(lv_ok)  = REDUCE i( INIT n = 0 FOR r IN gt_gap WHERE ( result = '생성' OR result = '검증OK' ) NEXT n = n + 1 ).
  DATA(lv_err) = REDUCE i( INIT n = 0 FOR r IN gt_gap WHERE ( result = '오류' ) NEXT n = n + 1 ).
  DATA(lv_exc) = REDUCE i( INIT n = 0 FOR r IN gt_gap WHERE ( result = '제외' ) NEXT n = n + 1 ).

  lo_alv->get_functions( )->set_all( abap_true ).
  DATA(lv_mode) = COND string( WHEN p_gtest = abap_true THEN '테스트(ROLLBACK)' ELSE '실행' ).
  DATA lv_title TYPE lvc_title.
  lv_title = |OEM 단가 공백 보정 — { lv_mode } : 성공 { lv_ok } / 오류 { lv_err } / 제외 { lv_exc } / 전체 { lv_all }건|.
  lo_alv->get_display_settings( )->set_list_header( lv_title ).
  lo_alv->display( ).

ENDFORM.
