*&---------------------------------------------------------------------*
*& Include          ZGTMMR2010F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form F_INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_initialization .


  IF s_badat[] IS INITIAL.
    s_badat[] = VALUE #( ( sign = 'I' option = 'BT'  low = sy-datlo - 1 high = sy-datlo ) ).
  ENDIF.


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

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_SCREEN_ATTR_1000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_set_screen_attr_1000 .

  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'BUK'.
        screen-required = 2.
        MODIFY SCREEN.
      WHEN 'SWR'.
        IF screen-group3 NE 'HGH'.
          screen-required = 2.
        ENDIF.
        IF p_disp EQ abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'CRE'.
        IF p_crea EQ abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'SKO' OR 'SKG'.
        IF p_disp EQ abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'WRK' OR 'EKO' OR 'EKG'.
        screen-required = 2.
        IF p_crea EQ abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM check_auth .

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD p_bukrs.

  CHECK sy-subrc <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE e172 WITH p_bukrs. "회사코드[&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD p_werks.

  CHECK sy-subrc <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE e106 WITH p_werks. "플랜트 [&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'EKORG' FIELD p_ekorg.

  CHECK sy-subrc <> 0.

  SET CURSOR FIELD 'P_EKORG'.
  MESSAGE e170 WITH p_ekorg."구매조직 [&] 작업권한을 확인하세요.


  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'EKORG' FIELD p_ekgrp.

  CHECK sy-subrc <> 0.

  SET CURSOR FIELD 'P_EKGRP'.
  MESSAGE e171 WITH p_ekgrp."구매그룹 [&] 작업권한을 확인하세요.


  IF s_werks[] IS NOT INITIAL.
    LOOP AT s_werks INTO DATA(ls_werks2).
      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                   ID 'WERKS' FIELD ls_werks2-low.

      CHECK sy-subrc <> 0.

      SET CURSOR FIELD 'S_WERKS-LOW'.
      MESSAGE e106 WITH s_werks-low. "플랜트 [&] 작업권한을 확인하세요.
    ENDLOOP.
  ENDIF.

  IF s_ekorg[] IS NOT INITIAL.
    LOOP AT s_ekorg INTO DATA(ls_ekorg2).
      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                   ID 'EKORG' FIELD ls_ekorg2-low.

      CHECK sy-subrc <> 0.

      SET CURSOR FIELD 'S_EKORG-LOW'.
      MESSAGE e170 WITH s_ekorg-low. "구매조직 [&] 작업권한을 확인하세요.
    ENDLOOP.
  ENDIF.

  IF s_ekgrp[] IS NOT INITIAL.
    LOOP AT s_ekgrp INTO DATA(ls_ekgrp2).
      AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                   ID 'EKGRP' FIELD ls_ekgrp2-low.

      CHECK sy-subrc <> 0.

      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE e171 WITH s_ekgrp-low. "구매그룹 [&] 작업권한을 확인하세요.
    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_BUKRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_at_screen_on_bukrs .

  CHECK sy-ucomm EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR gv_error.

  "필수 값 점검
  IF p_bukrs IS INITIAL.
    gv_error = abap_true.
    MESSAGE e278(00) WITH TEXT-f01.
  ENDIF.

  CHECK gv_error EQ space.

  "유효성 점검
  SELECT SINGLE
    bukrs
    FROM t001
    WHERE bukrs EQ @p_bukrs
    INTO @DATA(lv_chk).
  CHECK sy-subrc NE 0.
  gv_error = abap_true.
  MESSAGE e000 WITH TEXT-e01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_at_screen_on_werks .

  CHECK sy-ucomm EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR gv_error.

  "필수 값 점검
  CHECK p_disp EQ abap_true.
  IF s_werks[] IS INITIAL.
    gv_error = abap_true.
    MESSAGE e278(00) WITH TEXT-f02.
  ENDIF.

  CHECK gv_error EQ space.

  "유효성 점검
  SELECT SINGLE
    werks
    FROM t001w
    WHERE werks IN @s_werks
    INTO @DATA(lv_chk).
  CHECK sy-subrc NE 0.
  gv_error = abap_true.
  MESSAGE e000 WITH TEXT-e01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_EKORG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_at_screen_on_ekorg .

  CHECK sy-ucomm EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR gv_error.

  CHECK p_disp EQ abap_true AND s_ekorg[] IS NOT INITIAL.

  "유효성 점검
  SELECT SINGLE
    ekorg
    FROM t024e
    WHERE ekorg IN @s_ekorg
    INTO @DATA(lv_chk).
  CHECK sy-subrc NE 0.
  gv_error = abap_true.
  MESSAGE e000 WITH TEXT-e01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_EKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_at_screen_on_ekgrp .

  CHECK sy-ucomm EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR gv_error.

  CHECK p_disp EQ abap_true AND s_ekgrp[] IS NOT INITIAL.

  "유효성 점검
  SELECT SINGLE
    ekgrp
    FROM t024
    WHERE ekgrp IN @s_ekgrp
    INTO @DATA(lv_chk).
  CHECK sy-subrc NE 0.
  gv_error = abap_true.
  MESSAGE e000 WITH TEXT-e01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_at_screen_on_matnr .

  CHECK sy-ucomm EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR gv_error.

  CHECK s_matnr[] IS NOT INITIAL.

  "유효성 점검
  SELECT SINGLE
    matnr
    FROM mara
    WHERE matnr IN @s_matnr
    INTO @DATA(lv_chk).
  CHECK sy-subrc NE 0.
  gv_error = abap_true.
  MESSAGE e000 WITH TEXT-e01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_BADAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_at_screen_on_badat .

  CHECK sy-ucomm EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR gv_error.

  CHECK s_badat[] IS NOT INITIAL.

  "유효성 점검
  SELECT SINGLE
    badat
    FROM eban
    WHERE badat IN @s_badat
    INTO @DATA(lv_chk).
  CHECK sy-subrc NE 0.
  gv_error = abap_true.
  MESSAGE e000 WITH TEXT-e01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_ERNAM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_at_screen_on_ernam .

  CHECK sy-ucomm EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR gv_error.

  CHECK s_ernam[] IS NOT INITIAL.

  "유효성 점검
  SELECT SINGLE
    ernam
    FROM eban
    WHERE ernam IN @s_ernam
    INTO @DATA(lv_chk).
  CHECK sy-subrc NE 0.
  gv_error = abap_true.
  MESSAGE e000 WITH TEXT-e01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_BANFN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_at_screen_on_banfn .

  CHECK sy-ucomm EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR gv_error.

  CHECK s_banfn[] IS NOT INITIAL.

  "유효성 점검
  SELECT SINGLE
    banfn
    FROM eban
    WHERE banfn IN @s_banfn
    INTO @DATA(lv_chk).
  CHECK sy-subrc NE 0.
  gv_error = abap_true.
  MESSAGE e000 WITH TEXT-e01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_START_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_start_of_selection .

  CLEAR gv_waers.
  SELECT SINGLE
    waers
    FROM t001
    WHERE bukrs EQ @p_bukrs
    INTO @gv_waers.

  CASE abap_true.
    WHEN p_disp. "조회
      PERFORM f_set_list_disp.

    WHEN p_crea.
      PERFORM f_set_org_text.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_LIST_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_set_list_disp .

  DATA:
    lv_length TYPE p LENGTH 16 DECIMALS 3,
    lv_factor TYPE p LENGTH 16 DECIMALS 3.

  "초기화
  CLEAR gt_list[].

  SELECT
    eb~banfn,
    eb~bnfpo,
    eb~badat,
    eb~ernam,
    eb~matnr,
    eb~txz01,
    eb~werks,
    tw~name1,
    eb~lgort,
    tl~lgobe,
    eb~menge,
    eb~meins,
    eb~lfdat,
    eb~preis,
    eb~waers,
    eb~peinh,
    eb~ekorg,
    te~ekotx,
    eb~ekgrp,
    t4~eknam,
    eb~lifnr,
    eb~flief,
    eb~loekz,
    eb~ebakz,
    eb~frgkz,
    eb~afnam,
    eb~knttp,
    ti~knttx,
    eb~pstyp,
    ty~ptext,
    ek~anln1,
    an~txt50,
    ek~kostl,
    ct~ktext AS kostl_text,
    ek~sakto,
    st~txt20 AS sakto_text,
    ek~aufnr,
    ak~ktext AS aufnr_text,
    ek~ps_psp_pnr,
    ps~post1,
    cv1~atwrt AS color, "특성 추가-->
    cv2~length,
    cv2~drqty AS factor,
    cv3~atwrt AS drmatnr,
    mk~maktx AS drmaktx
    FROM eban AS eb
                  INNER JOIN
              t001w AS tw ON eb~werks EQ tw~werks
                  INNER JOIN
              t001k AS tk ON tw~bwkey EQ tk~bwkey
                  INNER JOIN
              t001 AS t1 ON tk~bukrs EQ t1~bukrs
                  LEFT OUTER JOIN
              t001l AS tl ON eb~werks EQ tl~werks
                               AND eb~lgort EQ tl~lgort
                  LEFT OUTER JOIN
              t024e AS te ON eb~ekorg EQ te~ekorg
                  LEFT OUTER JOIN
              t024 AS t4 ON eb~ekgrp EQ t4~ekgrp
                  LEFT OUTER JOIN
              t163i AS ti ON eb~knttp EQ ti~knttp
                             AND ti~spras EQ @sy-langu
                  LEFT OUTER JOIN
              t163y AS ty ON eb~pstyp EQ ty~pstyp
                                AND ty~spras EQ @sy-langu
                  LEFT OUTER JOIN
              ebkn AS ek ON eb~banfn EQ ek~banfn
                                AND eb~bnfpo EQ ek~bnfpo
                  LEFT OUTER JOIN
              anla AS an ON tk~bukrs EQ an~bukrs
                                AND ek~anln1 EQ an~anln1
                                AND ek~anln2 EQ an~anln2
                  LEFT OUTER JOIN
              cskt AS ct ON ek~kostl EQ ct~kostl
                           AND tk~bukrs EQ ct~kokrs
                           AND ct~datbi EQ '99991231'
                           AND ct~spras EQ @sy-langu
                  LEFT OUTER JOIN
               skat AS st ON ek~sakto EQ st~saknr
                                AND t1~ktopl EQ st~ktopl
                                AND st~spras EQ @sy-langu
                  LEFT OUTER JOIN
                aufk AS ak ON ek~aufnr EQ ak~aufnr
                  LEFT OUTER JOIN
                prps AS ps ON ek~ps_psp_pnr EQ ps~pspnr
                  LEFT OUTER JOIN
                zgtsd_i_materialcharacteristic AS cv1 ON cv1~matnr EQ eb~matnr
                                                                      AND atnam EQ 'PD_CA_COLOR_BASE'
                  LEFT OUTER JOIN
                  zgtmm_cv_pr_vcvalue_main AS cv2 ON cv2~pdoc EQ eb~banfn
                                                                              AND cv2~pdocitem EQ eb~bnfpo
                  LEFT OUTER JOIN
                  zgtmm_cv_pr_vcvalue AS cv3 ON cv3~pdoc EQ eb~banfn
                                                                              AND cv3~pdocitem EQ eb~bnfpo
                                                                              AND cv3~atnam EQ 'PD_CA_PACKING_DM'
                  LEFT OUTER JOIN
                  makt AS mk ON ltrim( mk~matnr, '0' ) = ltrim( cv3~atwrt, '0' ) "MK~MATNR EQ CV3~ATWRT
                                      AND mk~spras EQ @sy-langu

    WHERE tk~bukrs EQ @p_bukrs
    AND eb~werks IN @s_werks
    AND eb~ekorg IN @s_ekorg
    AND eb~ekgrp IN @s_ekgrp
    AND eb~badat IN @s_badat
    AND eb~ernam IN @s_ernam
    AND eb~banfn IN @s_banfn
    AND eb~matnr IN @s_matnr
    ORDER BY eb~banfn, eb~bnfpo
    INTO CORRESPONDING FIELDS OF TABLE @gt_list.

  CHECK sy-subrc EQ 0.

  SELECT
    v1~bname,
    v1~name_text
    FROM v_username AS v1
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT zz~ernam
        FROM @gt_list AS zz
        WHERE zz~ernam EQ v1~bname
    )
    ORDER BY v1~bname
    INTO TABLE @DATA(lt_user).

  "PO 조회
  "Table : EKPO
*SELECT 조건 : EBELN.EBELP
*WHERE 조건 : 조회된 대상 BANFN
*EKPO-LOEKZ <>""L""인 정보
*PO가 여러건인 경우 마지막 PO 번호정보로 보여줌
*
  SELECT
    ep~banfn,
    ep~bnfpo,
    ep~ebeln,
    ep~ebelp
    FROM ekpo AS ep
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT @abap_true
        FROM @gt_list AS zz
        WHERE zz~banfn EQ ep~banfn
           AND zz~bnfpo EQ ep~bnfpo
    )
    AND ep~loekz EQ @space
    ORDER BY ep~banfn ASCENDING, ep~bnfpo ASCENDING, ep~ebeln DESCENDING, ep~ebelp ASCENDING
    INTO TABLE @DATA(lt_po).


  "결재상태
*"1) ZGTMMT-1070 APPTYPE = A 인 경우 ZGTMMT1070-APPSTATUS 참조
*C이면 ""완료"", ""R"" 이면 반려""
*2) ZGTMMT-1070-APPTYPE = B인 경우 마지막 APPID 값 기준으로 ZGTMMT1051-STATUS
*ZSEQ = '01' 의 텍스트 정보"

  SELECT
    z1~appid,                                               "260508 추가
    z1~banfn,
    z1~bnfpo,
    z1~apptype,
    z1~appstatus,
    z2~status
    FROM zgtmmt1070 AS z1
                  LEFT OUTER JOIN
              zgtmmt1051 AS z2 ON z1~appid EQ z2~appid
                                           AND z2~zseq EQ '01'
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT @abap_true
        FROM @gt_list AS zz
        WHERE zz~banfn EQ z1~banfn
           AND zz~bnfpo EQ z1~bnfpo
    )
    ORDER BY z1~banfn, z1~bnfpo, z1~apptype
    INTO TABLE @DATA(lt_zgtmmt1070).


  SELECT
    v1~domvalue_l,
    v1~ddtext
    FROM dd07v AS v1
    WHERE domname EQ 'ZGTD_WELSTATE'
    AND ddlanguage EQ @sy-langu
    ORDER BY v1~domvalue_l
    INTO TABLE @DATA(lt_domv).

  DATA:
    lv_name  TYPE thead-tdname,
    lt_lines TYPE STANDARD TABLE OF tline.

  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<ls_list>).
    CLEAR: lv_length, lv_factor.
    "조장, 조장수 소수점 변환
    IF <ls_list>-length IS NOT INITIAL.
      lv_length = <ls_list>-length.
      <ls_list>-length = |{ trunc( lv_length ) }|.
    ENDIF.

    IF <ls_list>-factor IS NOT INITIAL.
      lv_factor = <ls_list>-factor.
      <ls_list>-factor = |{ trunc( lv_factor ) }|.
    ENDIF.

    READ TABLE lt_user ASSIGNING FIELD-SYMBOL(<ls_user>) WITH KEY bname = <ls_list>-ernam BINARY SEARCH.
    IF sy-subrc EQ 0.
      <ls_list>-name_text = <ls_user>-name_text.
    ENDIF.

*    PREIS*MENGE/PEINH
    IF <ls_list>-peinh IS NOT INITIAL.
      <ls_list>-zamt = ( <ls_list>-preis * <ls_list>-menge ) / <ls_list>-peinh.
    ENDIF.

    READ TABLE lt_po ASSIGNING FIELD-SYMBOL(<ls_po>) WITH KEY banfn = <ls_list>-banfn
                                                                                                bnfpo = <ls_list>-bnfpo BINARY SEARCH.
    IF sy-subrc EQ 0.
      <ls_list>-ebeln = <ls_po>-ebeln.
      <ls_list>-ebelp = <ls_po>-ebelp.
    ENDIF.

    READ TABLE lt_zgtmmt1070 ASSIGNING FIELD-SYMBOL(<lt_zgtmmt1070>) WITH KEY banfn = <ls_list>-banfn
                                                                                                bnfpo = <ls_list>-bnfpo BINARY SEARCH.
    IF sy-subrc EQ 0.
      "결재상태
*"1) ZGTMMT-1070 APPTYPE = A 인 경우 ZGTMMT1070-APPSTATUS 참조
*C이면 ""완료"", """"승반려""
*2) ZGTMMT-1070-APPTYPE = B인 경우 마지막 APPID 값 기준으로 ZGTMMT1051-STATUS
*ZSEQ = '01' 의 텍스트 정보"
      CASE <lt_zgtmmt1070>-apptype.
        WHEN gc_a.
          CASE <lt_zgtmmt1070>-appstatus.
            WHEN gc_c.
              <ls_list>-appstatus = TEXT-x05. "승인
            WHEN gc_r.
              <ls_list>-appstatus = TEXT-x06. "반려
          ENDCASE.
        WHEN gc_b.
* <-- 260508 TYPE B인 경우 텍스트 할당 수정
*          READ TABLE LT_DOMV ASSIGNING FIELD-SYMBOL(<LS_DOMV>) WITH KEY DOMVALUE_L = <LT_ZGTMMT1070>-STATUS BINARY SEARCH.
*          IF SY-SUBRC EQ 0.
*            <LS_LIST>-APPSTATUS = <LS_DOMV>-DDTEXT.
*          ENDIF.

          SELECT SINGLE status_n
            FROM zgtmm_cv_get_wels_max_status
            WHERE appid = @<lt_zgtmmt1070>-appid
            INTO @DATA(lv_status_n).
          IF sy-subrc EQ 0.
            <ls_list>-appstatus = lv_status_n.
          ENDIF.
          CLEAR lv_status_n.
* 260508 TYPE B인 경우 텍스트 할당 수정 -->
      ENDCASE.
    ENDIF.

*
*품목 텍스트                 ITEMTEXT  CALL FUNCTION 'READ_TEXT' "필드 유형: CHAR
*필드 자리수: 200
*: READ_TEXT Function 호출하여 조회된 정보로 보여줌
*[Import 변수]
*ID  = 'B01''
*LANGUAGE = SY-LANGU
*NAME = BANFN(10) +BNFPO(5)
*OBJECT      = 'EBAN'
*[결과값]
*리턴된 TABLE-LINES 정보"
*
    CLEAR:
      lv_name,
      lt_lines[].
    lv_name = <ls_list>-banfn && <ls_list>-bnfpo.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id       = 'B01'
        language = sy-langu
        name     = lv_name
        object   = 'EBAN'
      TABLES
        lines    = lt_lines
      EXCEPTIONS
        OTHERS   = 1.

    IF lt_lines[] IS NOT INITIAL.
      CALL FUNCTION 'IDMX_DI_TLINE_INTO_STRING'
        EXPORTING
          it_tline       = lt_lines
        IMPORTING
          ev_text_string = <ls_list>-itemtext.

    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_END_OF_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_end_of_selection .

  CASE abap_true.
    WHEN p_disp. "조회
      IF gt_list[] IS INITIAL.
        MESSAGE s002 DISPLAY LIKE gc_e.
        LEAVE LIST-PROCESSING.
      ENDIF.

      CALL SCREEN 100.

    WHEN p_crea.
      CASE abap_true.
        WHEN p_opt1. "상비 자재
          CALL SCREEN 200.
        WHEN p_opt2. "비상비 자재
          CALL SCREEN 300.
      ENDCASE.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_PR_CLOSED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ABAP_TRUE
*&---------------------------------------------------------------------*
FORM f_pr_closed  USING pv_closed.

*6-1) 라인은 다중선택 가능 (전체선택 포함)
*6-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  "선택 한 라인  없으면 오류
  DATA:
    lv_check TYPE c LENGTH 1,
    lv_ans   TYPE c LENGTH 1,
    lt_row   TYPE lvc_t_roid.

  DATA:
    lv_cnt_s TYPE int4,
    lv_cnt_e TYPE int4.


  CALL METHOD go_grid_100->check_changed_data
    IMPORTING
      e_valid = lv_check.

  CHECK lv_check EQ abap_true.

  CALL METHOD go_grid_100->get_selected_rows
    IMPORTING
      et_row_no = lt_row.
  DELETE lt_row WHERE row_id LE 0.
  IF lt_row[] IS INITIAL.
    MESSAGE e163.
  ENDIF.

*요청 종결 처리 하시겠습니까?
  IF pv_closed EQ abap_true.
    "종결 처리 전 점검
    PERFORM f_check_closed USING lt_row.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar      = TEXT-tt1
        text_question = TEXT-q01
      IMPORTING
        answer        = lv_ans.
  ELSE.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar      = TEXT-tt1
        text_question = TEXT-q02
      IMPORTING
        answer        = lv_ans.
  ENDIF.
  CHECK lv_ans EQ gc_1.

*6-3) BAPI_PR_CHANGE  데이터 설정
  DATA:
*    LT_PR     TYPE STANDARD TABLE OF TY_LIST,
    lt_return TYPE STANDARD TABLE OF bapiret2,
    lt_item   TYPE STANDARD TABLE OF bapimereqitemimp,
    lt_itemx  TYPE STANDARD TABLE OF bapimereqitemx.

  LOOP AT lt_row ASSIGNING FIELD-SYMBOL(<ls_row>).
    READ TABLE gt_list ASSIGNING FIELD-SYMBOL(<ls_list>) INDEX <ls_row>-row_id.
    CHECK sy-subrc EQ 0.

    CLEAR:
      lt_item[],
      lt_itemx[],
      lt_return[].

    lt_item = VALUE #( BASE lt_item ( preq_item = <ls_list>-bnfpo closed = pv_closed ) ).
    lt_itemx = VALUE #( BASE lt_itemx ( preq_item = <ls_list>-bnfpo preq_itemx = abap_true closed = abap_true ) ).

    CALL FUNCTION 'BAPI_PR_CHANGE'
      EXPORTING
        number  = <ls_list>-banfn
      TABLES
        return  = lt_return
        pritem  = lt_item
        pritemx = lt_itemx.

    READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_return>) WITH KEY = gc_e.
    IF sy-subrc EQ 0.
*: CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
*: ALV 화면 필드 업데이트
*필드                 VALUE
*MESSAGE                  RETURN-MESSAGE 대표 메시지
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      <ls_list>-message = <ls_return>-message.
      lv_cnt_e += 1.
    ELSE.
*6-3-2) RETURN-TYPE = S 이면
*
*: CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*: ALV 화면 필드 업데이트
*: 하단 메시지 처리 "처리 완료."

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

      <ls_list>-ebakz = pv_closed.
*      MESSAGE S000 WITH TEXT-M01. "처리 완료
      lv_cnt_s += 1.
    ENDIF.

  ENDLOOP.


  "메세지 처리
  "전체 데이터: &1 성공: &2 실패: &3
  DATA(lv_tot) = lv_cnt_s + lv_cnt_e.
  MESSAGE s073 WITH lv_tot lv_cnt_s lv_cnt_e.

*  LOOP AT LT_ROW ASSIGNING FIELD-SYMBOL(<LS_ROW>).
*    READ TABLE GT_LIST ASSIGNING FIELD-SYMBOL(<LS_LIST>) INDEX <LS_ROW>-ROW_ID.
*    CHECK SY-SUBRC EQ 0.
*    APPEND <LS_LIST> TO LT_PR.
*  ENDLOOP.

*  LOOP AT LT_PR ASSIGNING FIELD-SYMBOL(<LS_G1>) GROUP BY ( BANFN = <LS_G1>-BANFN )
*                                                                                    ASSIGNING FIELD-SYMBOL(<LS_GROUP>) .
*    CLEAR:
*      LT_ITEM[],
*      LT_ITEMX[],
*      LT_RETURN[].
*
*    LOOP AT GROUP <LS_GROUP> ASSIGNING FIELD-SYMBOL(<LS_PR>).
*      LT_ITEM = VALUE #( BASE LT_ITEM ( PREQ_ITEM = <LS_PR>-BNFPO CLOSED = PV_CLOSED ) ).
*      LT_ITEMX = VALUE #( BASE LT_ITEMX ( PREQ_ITEM = <LS_PR>-BNFPO PREQ_ITEMX = ABAP_TRUE CLOSED = ABAP_TRUE ) ).
*    ENDLOOP.
*
*    CALL FUNCTION 'BAPI_PR_CHANGE'
*      EXPORTING
*        NUMBER  = <LS_GROUP>-BANFN
*      TABLES
*        RETURN  = LT_RETURN
*        PRITEM  = LT_ITEM
*        PRITEMX = LT_ITEMX.
*
*    READ TABLE LT_RETURN ASSIGNING FIELD-SYMBOL(<LS_RETURN>) WITH KEY = GC_E.
*    IF SY-SUBRC EQ 0.
*      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*    ELSE.
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          WAIT = ABAP_TRUE.
*
*      LOOP AT GROUP <LS_GROUP> ASSIGNING <LS_PR>.
*      ENDLOOP.
*    ENDIF.
*
*  ENDLOOP.





ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_REFRESH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_refresh .
  DATA lv_check TYPE c LENGTH 1.

*1-1. REFRESH : 조회 화면에서 선택시 ALV List Update, 생성 화면에서 선택 시 ALV Data Clear
  CASE abap_true.
    WHEN p_disp. "조회
      PERFORM f_set_list_disp.
    WHEN OTHERS.
      CASE abap_true.
        WHEN p_opt1.
          CALL METHOD go_grid_200->check_changed_data
            IMPORTING
              e_valid = lv_check.

          CHECK lv_check EQ abap_true.
        WHEN p_opt2.
          CALL METHOD go_grid_300->check_changed_data
            IMPORTING
              e_valid = lv_check.

          CHECK lv_check EQ abap_true.
      ENDCASE.

      CLEAR:
        gt_opt1[],
        gt_opt2[].
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_TEMPLATE_DOWNLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_ZGTMMR2010_OPT1
*&---------------------------------------------------------------------*
FORM f_template_download  USING  pv_objid TYPE w3objid.

  DATA:
    ls_wwwdata           TYPE wwwdatatab,
    lv_default_file_name TYPE string,
    lv_filename          TYPE string,
    lv_path              TYPE string,
    lv_fullpath          TYPE string,
    lv_rc                TYPE sy-subrc.

  CONSTANTS
    lc_file_ext          TYPE w3_name VALUE 'fileextension'.

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

  lv_default_file_name = ls_wwwdata-text && lv_file_ext.
  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      default_extension         =   CONV string( lv_file_ext )
      default_file_name         =   lv_default_file_name
      file_filter               =  CONV string( lv_file_ext )
    CHANGING
         filename                  =   lv_filename
         path                      =   lv_path
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
*& Form F_EXCEL_UPLOAD_OPT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_excel_upload_opt1 .

*2-1) 1의 대상별 Upload 파일 업로드 하여 ALV List 데이터로 반영
*2-2) Excel 업로드 시 ALV 에 데이터가 존재하면 데이터 Clear 후 엑셀 입력 데이터로 반영
*   Text 성 필드및 반영조건은 직접 입력하는 경우와 동일함
  DATA lv_check TYPE c LENGTH 1.
  CALL METHOD go_grid_200->check_changed_data
    IMPORTING
      e_valid = lv_check.

  CHECK lv_check EQ abap_true.

  DATA:
    lv_file TYPE rlgrap-filename,
    lt_xls  TYPE STANDARD TABLE OF ty_opt1_xls.

  "파일명 선택
  PERFORM f_get_file_name CHANGING lv_file.

  "Excel 조회
  CHECK lv_file IS NOT INITIAL.
  PERFORM f_get_excel_data USING 1 2 27 60000 lv_file 'TY_OPT1_XLS' CHANGING lt_xls.

  "데이터 설정
  PERFORM f_set_alv_data_opt1 USING lt_xls CHANGING gt_opt1 lv_check.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_GET_EXCEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_1
*&      --> P_4
*&      --> P_1
*&      --> P_6000
*&      <-- LT_XLS
*&---------------------------------------------------------------------*
FORM f_get_excel_data  USING pv_begin_col
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
*& Form F_GET_FILE_NAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_FILE
*&---------------------------------------------------------------------*
FORM f_get_file_name  CHANGING cv_file.

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
*     initial_directory       = 'C:\'
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
*& Form F_SET_ALV_DATA_OPT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_XLS
*&      <-- GT_OPT1
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM f_set_alv_data_opt1  USING  pt_xls TYPE ty_t_opt1_xls
                          CHANGING ct_opt1 TYPE ty_t_opt1
                                   cv_check.

  "초기화
  CLEAR:
    ct_opt1[],
    cv_check.

  DATA :
    lv_jakno   TYPE kdkg4,
    lv_leng(6),
    lv_msg     TYPE bapi_msg,
    lt_drum    TYPE STANDARD TABLE OF zgtedsif0038.

  DATA:
    lt_fname   TYPE ty_t_fname,
    ls_opt1    TYPE ty_opt1,
    lv_amt_ext TYPE bapicurr-bapicurr,
    lv_amt_int TYPE matdoc-dmbtr.

  lt_fname = VALUE #( ( fname =  'KNTTP' )
                                     ( fname =  'PSTYP' )
                                     ( fname =  'MATNR' )
                                     ( fname =  'WERKS' )
                                     ( fname =  'LGORT' )
                                     ( fname =  'MENGE' )
                                     ( fname =  'MEINS' )
                                     ( fname =  'LFDAT' )
                                     ( fname =  'EKORG' )
                                     ( fname =  'EKGRP' )
                                     ( fname =  'AFNAM' )
                                     ( fname =  'LIFNR' )
                                     ( fname =  'FLIEF' )
                                     ( fname =  'PREIS' )
                                     ( fname =  'WAERS' )
                                     ( fname =  'PEINH' )
                                     ( fname =  'VBELN' )
                                     ( fname =  'VBELP' )
                                     ( fname =  'MATKL' ) ).

  LOOP AT pt_xls ASSIGNING FIELD-SYMBOL(<ls_xls>).
    "초기화
    CLEAR ls_opt1.


    "대문자 변경
    TRANSLATE:
      <ls_xls>-knttp TO UPPER CASE,
      <ls_xls>-pstyp TO UPPER CASE,
      <ls_xls>-matnr TO UPPER CASE,
      <ls_xls>-werks TO UPPER CASE,
      <ls_xls>-lgort TO UPPER CASE,
      <ls_xls>-ekorg TO UPPER CASE,
      <ls_xls>-ekgrp TO UPPER CASE,
      <ls_xls>-lifnr TO UPPER CASE,
      <ls_xls>-flief TO UPPER CASE,
      <ls_xls>-waers TO UPPER CASE,
      <ls_xls>-vbeln TO UPPER CASE.

    "콤마 제거
    ##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF ',' IN <ls_xls>-preis WITH space.
    ##REGEX_POSIX
    REPLACE ALL OCCURRENCES OF ',' IN <ls_xls>-menge WITH space.

    "숫자만 남기고 제거)
    REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]]' IN <ls_xls>-lfdat WITH space.
    REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]]' IN <ls_xls>-peinh WITH space.
    REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]]' IN <ls_xls>-vbelp WITH space.
    REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]]' IN <ls_xls>-length WITH space.  "조장 추가
    REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]]' IN <ls_xls>-factor WITH space.  "조장수 추가

    "공백 제거
    CONDENSE:
      <ls_xls>-preis,
      <ls_xls>-menge,
      <ls_xls>-lfdat,
      <ls_xls>-peinh,
      <ls_xls>-vbelp.

    "값 설정
    ls_opt1 = CORRESPONDING #( BASE ( ls_opt1 )  <ls_xls> ).

    "Alpha conversion
    ls_opt1-lifnr = |{ ls_opt1-lifnr ALPHA = IN }|.
    ls_opt1-flief = |{ ls_opt1-flief ALPHA = IN }|.
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

    "드럼 자재코드 추가
    IF ls_opt1-drmatnr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input  = ls_opt1-drmatnr
        IMPORTING
          output = ls_opt1-drmatnr.
    ENDIF.


    IF ls_opt1-preis IS NOT INITIAL AND ls_opt1-waers IS NOT INITIAL.
      CLEAR:
       lv_amt_ext,
       lv_amt_int.

      "금액 변환(Ext - > Int)
      lv_amt_ext = ls_opt1-preis.
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
        EXPORTING
          currency             = ls_opt1-waers
          amount_external      = lv_amt_ext
          max_number_of_digits = 23
        IMPORTING
          amount_internal      = lv_amt_int.

      ls_opt1-preis = lv_amt_int.
    ENDIF.

    "라인추가
    APPEND ls_opt1 TO ct_opt1.

  ENDLOOP.


  CHECK ct_opt1[] IS NOT INITIAL. "데이터가 있으면 진행

  SELECT
    mr~matnr,
    mr~meins,
    mr~matkl,
    mt~maktx
    FROM mara AS mr
                LEFT OUTER JOIN
               makt AS mt ON mr~matnr EQ mt~matnr
                                 AND mt~spras EQ @sy-langu
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT zz~matnr
        FROM @ct_opt1 AS zz
        WHERE ( zz~matnr EQ mr~matnr
                     OR zz~drmatnr EQ mr~matnr )  "드럼 코드 추가
    )
    ORDER BY mr~matnr
    INTO TABLE @DATA(lt_mara).

  SELECT
    mc~matnr,
    mc~werks,
    mc~ekgrp,
    mw~stprs,
    mw~peinh
    FROM marc AS mc
                  LEFT OUTER JOIN
              mbew AS mw ON mc~matnr EQ mw~matnr
                                AND mc~werks EQ mw~bwkey
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT zz~matnr
        FROM @ct_opt1 AS zz
        WHERE zz~matnr EQ mc~matnr
             AND zz~werks EQ mc~werks
    )
    ORDER BY mc~matnr, mc~werks
    INTO TABLE @DATA(lt_marc).

*>S.2026.08.10_특성정보 추가되어 기존 로직 주석 & 자재 별 전체 특성 가져오기.
**  "자재 특성(색상) SELECT
**  SELECT CV~MATNR, CV~ATWRT AS COLOR
**    FROM  ZGTSD_I_MATERIALCHARACTERISTIC AS CV
**    JOIN @CT_OPT1 AS ZZ ON CV~MATNR EQ ZZ~MATNR
**                                      AND ATNAM EQ 'PD_CA_COLOR_BASE'
**    ORDER BY ZZ~MATNR
**    INTO TABLE @DATA(LT_COLOR).
*특성정보(설계번호/개정번호/색상 등)
  SELECT matnr, atnam, atwrt
    FROM zgtsd_i_materialcharacteristic AS p
##ITAB_KEY_IN_SELECT
    WHERE EXISTS ( SELECT c~matnr
                                FROM @ct_opt1 AS c
                                WHERE c~matnr EQ p~matnr )
    ORDER BY matnr, atnam INTO TABLE @DATA(lt_char).
*<E.2026.08.10_ZGODEV04

  LOOP AT ct_opt1 ASSIGNING FIELD-SYMBOL(<ls_opt1>).
    IF <ls_opt1>-matnr IS NOT INITIAL.
      READ TABLE lt_mara ASSIGNING FIELD-SYMBOL(<ls_mara>) WITH KEY matnr = <ls_opt1>-matnr BINARY SEARCH.
      IF sy-subrc EQ 0.
        <ls_opt1>-maktx = <ls_mara>-maktx.

*"1) Possible Entry or 입력 가능
*2) MATNR = """" 이면 Editable
*3) MATNR <> """" 이면 MARA-MATTKL 값으로 보여줌, 수정 불가"
        <ls_opt1>-matkl = <ls_mara>-matkl.

        "1) Possible Entry or 입력 가능
*2) MATNR <>""""이면 MARA-MEINS 값으로 보여줌, 수정불가
*3) MATNR = """" 이면 Editable"
        <ls_opt1>-meins = <ls_mara>-meins.
        <ls_opt1>-zstyle = VALUE #( BASE <ls_opt1>-zstyle ( fieldname = 'MATKL' style = cl_gui_alv_grid=>mc_style_disabled )
                                                                                                   ( fieldname = 'MEINS' style = cl_gui_alv_grid=>mc_style_disabled ) ).

      ENDIF.

*      READ TABLE LT_COLOR ASSIGNING FIELD-SYMBOL(<LS_COLOR>) WITH KEY MATNR = <LS_OPT1>-MATNR BINARY SEARCH.
      READ TABLE lt_char ASSIGNING FIELD-SYMBOL(<ls_color>) WITH KEY matnr = <ls_opt1>-matnr
                                                                                                                       atnam = 'PD_CA_COLOR_BASE' BINARY SEARCH.
      IF sy-subrc EQ 0.
        <ls_opt1>-color = <ls_color>-atwrt.
      ENDIF.

      IF <ls_opt1>-werks IS NOT INITIAL.
        READ TABLE lt_marc ASSIGNING FIELD-SYMBOL(<ls_marc>) WITH KEY matnr = <ls_opt1>-matnr
                                                                                                          werks = <ls_opt1>-werks BINARY SEARCH.

        IF sy-subrc EQ 0.
*"1) Possible Entry or 입력 가능
*2) MATNR, WERKS 입력값 기준으로 MARC-EKGRP 값으로 보여줌, 수정 가능"
          IF <ls_opt1>-ekgrp IS INITIAL.
            <ls_opt1>-ekgrp = <ls_marc>-ekgrp.
          ENDIF.

*"1) MATNR,WERKS 입력값에 따라 자재 단가 조회
*Table: MBEW
*SELECT 조건: STPRS
*WHERE 조건 : MATNR, WERKS
*-> 조회 조건의 BUKRS 값 기준으로 T001-WAERS = ""KRW"" 이면 STPRS*100
*2) 직접 입력 가능"
          IF <ls_opt1>-preis IS INITIAL.
            <ls_opt1>-preis = <ls_marc>-stprs.
          ENDIF.

          IF <ls_opt1>-peinh IS INITIAL.
            <ls_opt1>-peinh = <ls_marc>-peinh.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*>S.2026.08.10_드럼 자재코드 불러오기 로직 수정
*조장 정보가 있는 경우에만, 'ZGTED_GET_DRUM_CODE_PP''펑션을 통해 가져온 드럼 정보로 설정.
**    "(+)드럼 자재코드 추가->기존 로직 주석..20260810
**    IF <LS_OPT1>-DRMATNR IS NOT INITIAL.
**      READ TABLE LT_MARA ASSIGNING FIELD-SYMBOL(<LS_MARA2>) WITH KEY MATNR = <LS_OPT1>-DRMATNR BINARY SEARCH.
**      IF SY-SUBRC EQ 0.
**        <LS_OPT1>-DRMAKTX = <LS_MARA2>-MAKTX.
**      ENDIF.
**    ENDIF.

*조장 데이터 있으면, 드럼 수 자동계산&목드럼 자재코드 조회
    IF <ls_opt1>-length IS NOT INITIAL AND <ls_opt1>-length > 0.
*목드럼 자재코드 조회 수행(조장>0 때만)
      SELECT SINGLE dpcbt
        FROM marc
        WHERE werks = @<ls_opt1>-werks
             AND matnr = @<ls_opt1>-matnr
            INTO @DATA(lv_dpcbt2).

      IF lv_dpcbt2 = 'C'.
        lv_jakno = ''. "고객그룹코드

        DATA(lv_int) = CONV i( trunc( <ls_opt1>-length ) ). "조장_소숫점 버림

*        LV_LENG = LV_INT.   CONDENSE LV_LENG NO-GAPS.
        WRITE lv_int TO lv_leng NO-GROUPING.
        CONDENSE lv_leng NO-GAPS. "1,000단위 콤마(,) 제거

*     "설계번호/개정번호
        READ TABLE lt_char ASSIGNING FIELD-SYMBOL(<chd>)
        WITH KEY matnr = <ls_opt1>-matnr
                       atnam =  'PD_CA_DESIGN_NO' BINARY SEARCH. " ZDGNO
        IF sy-subrc = 0.
          DATA(lv_zdgno) = CONV zesul_no( <chd>-atwrt ).
        ENDIF.
*      "개정번호
        READ TABLE lt_char ASSIGNING FIELD-SYMBOL(<chr>)
        WITH KEY matnr = <ls_opt1>-matnr
                       atnam =  'PD_CA_DESIGN_REV_NO' BINARY SEARCH. " ZREVNO
        IF sy-subrc = 0.
          DATA(lv_zrevno) = CONV zerev_seq( <chr>-atwrt ).
        ENDIF.

        TRY.
            CALL FUNCTION 'ZGTED_GET_DRUM_CODE_PP'
              EXPORTING
                iv_sul_no    = lv_zdgno
                iv_rev_seq   = lv_zrevno
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
            <ls_opt1>-drmaktx = <drum>-maktx.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.
*<E.2026.08.10_ZGODEV04

*"1) WERKS 입력값이 있으면 기본값 1 로 보여줌
*2) 수정 가능"
    IF <ls_opt1>-peinh IS INITIAL.
      <ls_opt1>-peinh = 1.
    ENDIF.

    CLEAR <ls_opt1>-zamt.
    IF <ls_opt1>-peinh IS NOT INITIAL.
      <ls_opt1>-zamt = ( <ls_opt1>-menge * <ls_opt1>-preis ) / <ls_opt1>-peinh.
    ENDIF.

*"1) Possible Entry or 입력 가능
*2) WERKS 입력 값이 있으면 조건입력 값 BUKRS 기준으로 T001-WAERS 값을 기본값으로 보여줌"
    IF <ls_opt1>-waers IS INITIAL.
      <ls_opt1>-waers = gv_waers.
    ENDIF.

*"1) Possible Entry or 입력 가능
*2) KNTTP = ""M"" 이면 Editable
*   KNTTP <> ""M"" 이면 Display"
    IF <ls_opt1>-knttp NE gc_m.
      "값 초기화
      CLEAR:
        <ls_opt1>-vbeln,
        <ls_opt1>-vbelp.

      "입력 불가 필드 설정
      <ls_opt1>-zstyle = VALUE #( BASE <ls_opt1>-zstyle ( fieldname = 'VBELN' style = cl_gui_alv_grid=>mc_style_disabled )
                                                                                                 ( fieldname = 'VBELP' style = cl_gui_alv_grid=>mc_style_disabled ) ).

    ENDIF.

    "코드 텍스트 설정
    PERFORM f_set_code_text_opt1 USING lt_fname CHANGING <ls_opt1>.

  ENDLOOP.

*
*    "코드 텍스트 설정
*    PERFORM F_SET_CODE_TEXT_OPT1 USING LT_FNAME CHANGING LS_OPT1.
*

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_PR_OPT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_create_pr_opt1 .
*
*5. 구매 요청 생성 버튼
*	5-1) 라인은 다중선택 가능 (전체선택 포함)
*	5-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*	5-3) 생성 대상 데이터 점검
*     : 점검시 필수 값이 없으면 하단 메시지 처리 "필수 입력 값을 확인하세요."
*       대상 리스트의 STATUS 업데이트  : RED 로 업데이트 (점검 정산인 경우 YELLOW)
*       대상 ALV 리스트의 MESSAGE 업데이트 : " 필수 입력 값이 누락 되었습니다. "

  DATA:
    lv_check  TYPE c LENGTH 1,
    lt_row_id TYPE lvc_t_roid.

  FIELD-SYMBOLS:
    <ls_row_id> TYPE lvc_s_roid,
    <ls_opt1>   TYPE ty_opt1.

  CALL METHOD go_grid_200->check_changed_data
    IMPORTING
      e_valid = lv_check.

  CHECK lv_check EQ abap_true.

  CALL METHOD go_grid_200->get_selected_rows
    IMPORTING
      et_row_no = lt_row_id.

  DELETE lt_row_id WHERE row_id LE 0.
*	5-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  IF lt_row_id[] IS INITIAL.
    MESSAGE e163.
  ENDIF.

  "데이터 점검
  CLEAR lv_check.
  PERFORM f_check_pr_create_opt1 USING lt_row_id CHANGING lv_check.

  CHECK lv_check NE gc_e. "오류가 없는 경우 진행

  "생성
  PERFORM f_run_create_bapi_opt1 USING lt_row_id.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_PR_CREATE_OPT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_ID
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM f_check_pr_create_opt1  USING pt_row_id TYPE lvc_t_roid
                             CHANGING cv_check.

  FIELD-SYMBOLS:
    <ls_row_id> TYPE lvc_s_roid,
    <ls_opt1>   TYPE ty_opt1.

*5-4) 선택한 라인에 BANFN 값이 있는 경우 하단 에러메세지 "구매요청 생성된 데이터가 존재합니다."
  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt1 ASSIGNING <ls_opt1> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.
    IF <ls_opt1>-banfn IS NOT INITIAL.
      MESSAGE e000 WITH TEXT-e04.
    ENDIF.
  ENDLOOP.

*	5-3) 생성 대상 데이터 점검
  CLEAR cv_check.
  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt1 ASSIGNING <ls_opt1> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.

    "초기화
    CLEAR:
      <ls_opt1>-status,
      <ls_opt1>-message.

*계정 지정범주                  KNTTP "1) 생성 대상 = 비상비자재 인 경우 필수
*2) MATNR = """" 이면 필수"
*
*자재번호                 MATNR KNTTP = "" 이면 필수
    IF <ls_opt1>-knttp IS INITIAL AND <ls_opt1>-matnr IS INITIAL.
      <ls_opt1>-status = icon_led_red.
      <ls_opt1>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
      cv_check = gc_e.
      CONTINUE.
    ENDIF.

*계정 지정범주

*자재그룹                 MATKL 1KNTTP <>"" 이고 MATNR = "" 이면 필수
    IF <ls_opt1>-knttp IS NOT INITIAL AND <ls_opt1>-matnr IS INITIAL
      AND <ls_opt1>-matkl IS INITIAL.
      <ls_opt1>-status = icon_led_red.
      <ls_opt1>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
      cv_check = gc_e.
      CONTINUE.
    ENDIF.


*자재내역                 MAKTX 필수
*플랜트                  WERKS 필수
*저장위치                 LGORT 필수
*요청 수량                  MENGE 필수
*요청 단위                  MEINS 필수
*납품 요청일                 LFDAT 필수
*구매조직                 EKORG 필수
*구매그룹                 EKGRP 필수
*요청자                  AFNAM 필수
*예상 가격                  PREIS 필수
*가격 통화                  WAERS 필수
*가격 단위                  PEINH 필수
    IF <ls_opt1>-maktx IS INITIAL
      OR <ls_opt1>-werks IS INITIAL
      OR <ls_opt1>-lgort IS INITIAL
      OR <ls_opt1>-menge IS INITIAL
      OR <ls_opt1>-meins IS INITIAL
      OR <ls_opt1>-lfdat IS INITIAL
      OR <ls_opt1>-ekorg IS INITIAL
      OR <ls_opt1>-ekgrp IS INITIAL
      OR <ls_opt1>-afnam IS INITIAL
      OR <ls_opt1>-preis IS INITIAL
      OR <ls_opt1>-waers IS INITIAL
      OR <ls_opt1>-peinh IS INITIAL.
      <ls_opt1>-status = icon_led_red.
      <ls_opt1>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
      cv_check = gc_e.
      CONTINUE.
    ENDIF.

    CASE <ls_opt1>-knttp.
      WHEN gc_m.
*영업오더                 VBELN KNTTP = "M" 이면 필수
*영업오더품목                 VBELP KNTTP = "M" 이면 필수
        IF <ls_opt1>-vbeln IS INITIAL OR <ls_opt1>-vbelp IS INITIAL.
          <ls_opt1>-status = icon_led_red.
          <ls_opt1>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
          cv_check = gc_e.
          CONTINUE.
        ENDIF.

      WHEN gc_k.
*코스트센터                  KOSTL KNTTP = "K" 이면 필수
*G/L 계정                 SAKTO KNTTP = "K" or "F" or "P" 이면 필수
        IF <ls_opt1>-kostl IS INITIAL OR <ls_opt1>-sakto IS INITIAL.
          <ls_opt1>-status = icon_led_red.
          <ls_opt1>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
          cv_check = gc_e.
        ENDIF.

      WHEN gc_f.
*G/L 계정                 SAKTO KNTTP = "K" or "F" or "P" 이면 필수
*오더번호                 AUFNR KNTTP = "F" 이면 필수
        IF <ls_opt1>-sakto IS INITIAL." OR <LS_OPT1>-AUFNR IS INITIAL.
          <ls_opt1>-status = icon_led_red.
          <ls_opt1>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
          cv_check = gc_e.
        ENDIF.

      WHEN gc_p.
*G/L 계정                 SAKTO KNTTP = "K" or "F" or "P" 이면 필수
*WBS 코드                 PS_PSP_PNR  KNTTP = "P" 이면 필수
        IF <ls_opt1>-sakto IS INITIAL." OR <LS_OPT1>-PS_PSP_PNR IS INITIAL.
          <ls_opt1>-status = icon_led_red.
          <ls_opt1>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
          cv_check = gc_e.
        ENDIF.

    ENDCASE.

    IF <ls_opt1>-knttp IS NOT INITIAL.
**하역지점                 ABLAD KNTTP <> "" 이면 필수
**수령인                  WEMPF KNTTP <> "" 이면 필수
      IF <ls_opt1>-ablad IS INITIAL OR <ls_opt1>-wempf IS INITIAL.
        <ls_opt1>-status = icon_led_red.
        <ls_opt1>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
        cv_check = gc_e.
      ENDIF.
    ENDIF.

** 특정 배치 유형인 경우 조장/조장수 필수
    SELECT SINGLE dpcbt
      FROM marc
    WHERE matnr EQ @<ls_opt1>-matnr
        AND werks EQ @<ls_opt1>-werks
      INTO @DATA(lv_dpcbt).

    IF ( lv_dpcbt EQ gc_a OR lv_dpcbt EQ gc_c )
          AND ( <ls_opt1>-length IS INITIAL OR <ls_opt1>-factor IS INITIAL ).
      <ls_opt1>-status = icon_led_red.
      <ls_opt1>-message = TEXT-e19. "해당 품목은 조장, 조장수 필수 입력 대상입니다.
      cv_check = gc_e.
    ENDIF.
    CLEAR lv_dpcbt.

  ENDLOOP.

  ": 점검시 필수 값이 없으면 하단 메시지 처리 "필수 입력 값을 확인하세요."
  IF cv_check EQ gc_e.
    MESSAGE s000 DISPLAY LIKE gc_e WITH TEXT-e05.
    EXIT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_RUN_CREATE_BAPI_OPT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_ID
*&---------------------------------------------------------------------*
FORM f_run_create_bapi_opt1  USING  pt_row_id TYPE lvc_t_roid.

*5-5) 선택한 라인이 존재하고 BANFN = "", 오류가 없는경우 POP-UP 확인 후 구매요청 생성 처리
  DATA lv_ans   TYPE c LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar      = TEXT-tt1
      text_question = TEXT-q03
    IMPORTING
      answer        = lv_ans.
  CHECK lv_ans EQ gc_1.

  FIELD-SYMBOLS:
    <ls_row_id> TYPE lvc_s_roid,
    <ls_opt1>   TYPE ty_opt1.

*4-7) BAPI_PR_CREATE 호출 PR 생성 수행
  DATA:
    lv_check      TYPE c LENGTH 1,
    lv_bnfpo      TYPE bnfpo,
    lv_preq_price TYPE c LENGTH 30,
    lt_return     TYPE STANDARD TABLE OF bapiret2,
    ls_header     TYPE bapimereqheader,
    ls_headerx    TYPE bapimereqheaderx,
    lt_item       TYPE STANDARD TABLE OF bapimereqitemimp,
    lt_itemx      TYPE STANDARD TABLE OF bapimereqitemx,
    lt_account    TYPE STANDARD TABLE OF bapimereqaccount,
    lt_accountx   TYPE STANDARD TABLE OF bapimereqaccountx,
    lt_itemtext   TYPE STANDARD TABLE OF bapimereqitemtext,
    ls_ret        TYPE bapimereqheader,

    " BDC용 데이터
    ls_pr_infor   TYPE zgtpps0004,
    lt_chart      TYPE zgtppy0005,
    lv_result     TYPE  char01,
    lv_banfn      TYPE  banfn.

  FIELD-SYMBOLS <ls_return> TYPE bapiret2.

  "header
  ls_header-pr_type = gc_nb.
  ls_headerx-pr_type = abap_true.



  "item / Account
  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    CLEAR:
        ls_pr_infor,
        lt_chart.

    READ TABLE gt_opt1 ASSIGNING <ls_opt1> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.

    "조장 여부에 따라 분기
    IF <ls_opt1>-length IS NOT INITIAL. "조장 정보 존재 -> BDC

      IF <ls_opt1>-factor IS INITIAL. "조장 존재 & 조장 수 미존재 -> 오류
        <ls_opt1>-message = TEXT-e16.
        <ls_opt1>-status = icon_led_red.
        CONTINUE.
      ELSEIF <ls_opt1>-length * <ls_opt1>-factor NE <ls_opt1>-menge.  "조장 * 조장수 <> 총수량 -> 오류
        <ls_opt1>-message = TEXT-e18.
        <ls_opt1>-status = icon_led_red.
        CONTINUE.
      ENDIF.

      "Import parameter
      ls_pr_infor = VALUE #( bsart = 'NB'
                                              knttp	= <ls_opt1>-knttp
                                              eeind	= <ls_opt1>-lfdat
                                              lpein	= 'T'
                                              werks	= <ls_opt1>-werks
                                              ekgrp	= <ls_opt1>-ekgrp
                                              afnam	= <ls_opt1>-afnam
                                              matnr	= <ls_opt1>-matnr
                                              ekorg	= <ls_opt1>-ekorg
                                              menge	= <ls_opt1>-menge
                                              infnr = space
                                              lifnr	= <ls_opt1>-lifnr
                                              kdauf   = <ls_opt1>-vbeln
                                              kdpos	= <ls_opt1>-vbelp ).

      CONDENSE ls_pr_infor-menge NO-GAPS.
      <ls_opt1>-drmatnr = |{ <ls_opt1>-drmatnr ALPHA = OUT }|.
      "Tables
      lt_chart = VALUE #( ( atnam = 'SAP_MILLCA_LENGTH' atwrt = <ls_opt1>-length )
                                        ( atnam = 'SAP_MILLCA_FACTOR' atwrt = <ls_opt1>-factor )
                                        ( atnam = 'PD_CA_PACKING_DM'  atwrt = <ls_opt1>-drmatnr ) ).

      CALL FUNCTION 'ZGTPP_CREATE_PR_BY_BDC'
        EXPORTING
          is_pr_infor = ls_pr_infor                " [GT] 구매요청 등록 정보
        IMPORTING
          ev_result   = lv_result                 " 길이 1의 문자 필드
          ev_banfn    = lv_banfn                 " 구매 요청 번호
        TABLES
          it_chart    = lt_chart.                " [GT] 특성값 입력 테이블타입

      IF lv_result EQ gc_s."성공시
        <ls_opt1>-message = TEXT-m02.
        <ls_opt1>-status = icon_led_green.
        <ls_opt1>-banfn = lv_banfn.
        <ls_opt1>-bnfpo = 10.
        PERFORM f_set_zstyle_opt1 CHANGING <ls_opt1>. "Style 설정

* 조장 품목도 품목텍스트 저장
  IF <LS_OPT1>-ITEMTEXT IS NOT INITIAL.
    TRY.
        DATA LT_TLINE_BDC TYPE STANDARD TABLE OF TLINE.
        DATA(LV_BNFPO_BDC) = |{ <LS_OPT1>-BNFPO ALPHA = IN }|.   " NUMC 5자리 변환

        CALL FUNCTION 'VB_CP_CONVERT_STRING_2_ITF'
          EXPORTING
            I_STRING = <LS_OPT1>-ITEMTEXT
          TABLES
            ET_TABLE = LT_TLINE_BDC.

        IF LT_TLINE_BDC[] IS NOT INITIAL.
          DATA(LS_TEXT_HEADER) = VALUE THEAD(
            TDOBJECT = 'EBAN'
            TDNAME   = LV_BANFN && LV_BNFPO_BDC
            TDID     = 'B01'
            TDSPRAS  = SY-LANGU ).

          CALL FUNCTION 'SAVE_TEXT'
            EXPORTING
              HEADER          = LS_TEXT_HEADER
              SAVEMODE_DIRECT = ABAP_TRUE
            TABLES
              LINES           = LT_TLINE_BDC
            EXCEPTIONS
              ID              = 1
              LANGUAGE        = 2
              NAME            = 3
              OBJECT          = 4
              OTHERS          = 5.

          IF SY-SUBRC = 0.
            COMMIT WORK AND WAIT.
          ELSE.
            CASE SY-SUBRC.
              WHEN 1. <LS_OPT1>-MESSAGE = <LS_OPT1>-MESSAGE && ' / 텍스트저장오류: TEXT ID'.
              WHEN 2. <LS_OPT1>-MESSAGE = <LS_OPT1>-MESSAGE && ' / 텍스트저장오류: LANGUAGE'.
              WHEN 3. <LS_OPT1>-MESSAGE = <LS_OPT1>-MESSAGE && ' / 텍스트저장오류: NAME(' && LS_TEXT_HEADER-TDNAME && ')'.
              WHEN 4. <LS_OPT1>-MESSAGE = <LS_OPT1>-MESSAGE && ' / 텍스트저장오류: OBJECT'.
              WHEN 5. <LS_OPT1>-MESSAGE = <LS_OPT1>-MESSAGE && ' / 텍스트저장오류: 기타'.
            ENDCASE.
            <LS_OPT1>-STATUS = ICON_LED_YELLOW.  "PR은 생성됨, 텍스트만 실패
          ENDIF.
        ENDIF.

      CATCH CX_ROOT INTO DATA(LX_TEXT_ERR).
        <LS_OPT1>-MESSAGE = <LS_OPT1>-MESSAGE && ' / 텍스트저장 예외: ' && LX_TEXT_ERR->GET_TEXT( ).
        <LS_OPT1>-STATUS = ICON_LED_YELLOW.
    ENDTRY.
  ENDIF.

      ELSEIF lv_result EQ gc_e."실패시
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        <ls_opt1>-message = TEXT-e17.
        <ls_opt1>-status = icon_led_red.
        CONTINUE.
      ENDIF.

    ELSE. " 조장 정보 없는 건 -> BAPI로 PR 생성
      "금액
      CLEAR lv_preq_price.
      WRITE <ls_opt1>-preis TO lv_preq_price CURRENCY <ls_opt1>-waers LEFT-JUSTIFIED NO-GROUPING NO-GAP.
      CONDENSE lv_preq_price.

      lv_bnfpo += 10.
      lt_item = VALUE #( BASE lt_item ( preq_item = lv_bnfpo
                              pur_group = <ls_opt1>-ekgrp
                              material = <ls_opt1>-matnr
                              plant = <ls_opt1>-werks
                              store_loc = <ls_opt1>-lgort
                              matl_group = <ls_opt1>-matkl
                              preq_name = <ls_opt1>-afnam
                              quantity = <ls_opt1>-menge
                              unit = <ls_opt1>-meins
                              deliv_date = <ls_opt1>-lfdat
                              preq_price = lv_preq_price
                              price_unit = <ls_opt1>-peinh
                              item_cat = <ls_opt1>-pstyp
                              acctasscat = <ls_opt1>-knttp
                              purch_org = <ls_opt1>-ekorg
                              currency = <ls_opt1>-waers
                              des_vendor = <ls_opt1>-lifnr
                              fixed_vend = <ls_opt1>-flief
                              gr_ind = abap_true
                              ir_ind = abap_true
                              tax_code = <ls_opt1>-mwskz
      ) ).
      lt_itemx = VALUE #( BASE lt_itemx ( preq_item = lv_bnfpo
                              pur_group = abap_true
                              material = abap_true
                              plant = abap_true
                              store_loc = abap_true
                              matl_group = abap_true
                              preq_name = abap_true
                              quantity = abap_true
                              unit = abap_true
                              deliv_date = abap_true
                              preq_price = abap_true
                              price_unit = abap_true
                              item_cat = COND #( WHEN <ls_opt1>-pstyp IS NOT INITIAL THEN abap_true ELSE space )
                              acctasscat = abap_true
                              purch_org = abap_true
                              currency = abap_true
                              des_vendor = abap_true
                              fixed_vend = abap_true
                              gr_ind = abap_true
                              ir_ind = abap_true
                              tax_code = abap_true
      ) ).

      IF <ls_opt1>-vbeln IS NOT INITIAL
        OR <ls_opt1>-kostl IS NOT INITIAL
        OR <ls_opt1>-sakto IS NOT INITIAL
        OR <ls_opt1>-ablad IS NOT INITIAL
        OR <ls_opt1>-wempf IS NOT INITIAL.

        lt_account = VALUE #( BASE lt_account (
             preq_item = lv_bnfpo
             serial_no = 1
             quantity = COND #( WHEN <ls_opt1>-knttp EQ gc_a THEN 1 ELSE 0 )
             costcenter = COND #( WHEN <ls_opt1>-kostl IS NOT INITIAL THEN <ls_opt1>-kostl ELSE space )
             gl_account = COND #( WHEN <ls_opt1>-sakto IS NOT INITIAL THEN <ls_opt1>-sakto ELSE space )
             sd_doc = COND #( WHEN <ls_opt1>-vbeln IS NOT INITIAL THEN <ls_opt1>-vbeln ELSE space )
             itm_number = COND #( WHEN <ls_opt1>-vbelp IS NOT INITIAL THEN <ls_opt1>-vbelp ELSE space )
             unload_pt = COND #( WHEN <ls_opt1>-ablad IS NOT INITIAL THEN <ls_opt1>-ablad ELSE space )
             gr_rcpt = COND #( WHEN <ls_opt1>-wempf IS NOT INITIAL THEN <ls_opt1>-wempf ELSE space )
             orderid = space
             wbs_element = space
        ) ).

        lt_accountx = VALUE #( BASE lt_accountx (
             preq_item = lv_bnfpo
             serial_no = 1
             quantity = COND #( WHEN <ls_opt1>-knttp EQ gc_a THEN abap_true ELSE space )
             costcenter = COND #( WHEN <ls_opt1>-kostl IS NOT INITIAL THEN abap_true ELSE space )
             gl_account = COND #( WHEN <ls_opt1>-sakto IS NOT INITIAL THEN abap_true ELSE space )
             sd_doc = COND #( WHEN <ls_opt1>-vbeln IS NOT INITIAL THEN abap_true ELSE space )
             itm_number =  COND #( WHEN <ls_opt1>-vbelp IS NOT INITIAL THEN abap_true ELSE space )
             unload_pt = COND #( WHEN <ls_opt1>-ablad IS NOT INITIAL THEN abap_true ELSE space )
             gr_rcpt = COND #( WHEN <ls_opt1>-wempf IS NOT INITIAL THEN abap_true ELSE space )
             orderid = space
             wbs_element = space
        ) ).
      ENDIF.
*4-6-7) PRITEMTEXT 설정
*BAPI 필드                    VALUE 비고
*PREQ_ITEM                    PRITEM-PREQ_ITEM
*TEXT_ID    B01'
*TEXT_LINE  ALV-ITEMTEXT

      IF <ls_opt1>-itemtext IS NOT INITIAL.
        DATA lt_tline TYPE STANDARD TABLE OF tline.

        CALL FUNCTION 'VB_CP_CONVERT_STRING_2_ITF'
          EXPORTING
            i_string = <ls_opt1>-itemtext
          TABLES
            et_table = lt_tline.

        IF lt_tline[] IS NOT INITIAL.
          LOOP AT lt_tline ASSIGNING FIELD-SYMBOL(<ls_tline>).
            lt_itemtext = VALUE #( BASE lt_itemtext (
                   preq_item = lv_bnfpo
                   text_id = 'B01'
                   text_form = <ls_tline>-tdformat
                   text_line = <ls_tline>-tdline
            ) ).

          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lt_item IS NOT INITIAL.
    CALL FUNCTION 'BAPI_PR_CREATE'
      EXPORTING
        prheader    = ls_header
        prheaderx   = ls_headerx
*       TESTRUN     =
      IMPORTING
*       NUMBER      =
        prheaderexp = ls_ret
      TABLES
        return      = lt_return
        pritem      = lt_item
        pritemx     = lt_itemx
        praccount   = lt_account
        praccountx  = lt_accountx
        pritemtext  = lt_itemtext.
  ENDIF.

*	4-7-3) RETURN-TYPE = E 이거나 BANFN 값이 NULL 이면
*   : CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
*   : ALV 화면 필드 업데이트
*
*   필드                  VALUE
*   STATUS                  RED
*   MESSAGE                 RETURN-MESSAGE 대표 메시지
*
*4-7-4) RETURN-TYPE = S 이고 BANFN <> "" 이면
*: CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*: ALV 화면 필드 업데이트
*
*필드                 VALUE
*STATUS                 GREEN
*MESSAGE                  구매요청이 생성 되었습니다.
*BANFN                  생성 구매요청번호
*BNFPO                  생성 구매요청품목번호

  READ TABLE lt_return WITH KEY type = gc_e TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    lv_check  = gc_e.
  ELSE.
    IF ls_ret-preq_no IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      lv_check  = gc_e.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
    ENDIF.
  ENDIF.


  CLEAR lv_bnfpo.
  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt1 ASSIGNING <ls_opt1> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.
    CHECK <ls_opt1>-length IS INITIAL.
    lv_bnfpo += 10.

    IF lv_check EQ gc_e.
      <ls_opt1>-status = icon_led_red.
      DELETE lt_return WHERE type = gc_e AND id = 'BAPI' AND number = '001'.
      READ TABLE lt_return ASSIGNING <ls_return> WITH KEY type = gc_e.
      IF sy-subrc NE 0.
        READ TABLE lt_return ASSIGNING <ls_return> WITH KEY type = gc_a.
        IF sy-subrc NE 0.
          READ TABLE lt_return ASSIGNING <ls_return> WITH KEY type = gc_w.
        ENDIF.
      ENDIF.
      IF sy-subrc EQ 0.
        <ls_opt1>-message = <ls_return>-message.
      ENDIF.
    ELSE.

      <ls_opt1>-banfn = ls_ret-preq_no.
      <ls_opt1>-bnfpo = lv_bnfpo.
      <ls_opt1>-status = icon_led_green.
      <ls_opt1>-message = TEXT-m02. "구매요청이 생성 되었습니다.
      PERFORM f_set_zstyle_opt1 CHANGING <ls_opt1>. "Style 설정
    ENDIF.

  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ZSTYLE_OPT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_OPT1>
*&---------------------------------------------------------------------*
FORM f_set_zstyle_opt1  CHANGING cs_opt1 TYPE ty_opt1.

  CHECK cs_opt1-banfn IS NOT INITIAL. "PR번호가 있으면 수정하지 못하게 함
  CLEAR cs_opt1-zstyle[].

  LOOP AT gt_fcat_200 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CHECK <ls_fcat>-edit = abap_true.
    cs_opt1-zstyle = VALUE #( BASE cs_opt1-zstyle ( fieldname = <ls_fcat>-fieldname style = cl_gui_alv_grid=>mc_style_disabled ) ).
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_EXCEL_UPLOAD_OPT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_excel_upload_opt2 .

*2-1) 1의 대상별 Upload 파일 업로드 하여 ALV List 데이터로 반영
*2-2) Excel 업로드 시 ALV 에 데이터가 존재하면 데이터 Clear 후 엑셀 입력 데이터로 반영
*   Text 성 필드및 반영조건은 직접 입력하는 경우와 동일함

  DATA lv_check TYPE c LENGTH 1.
  CALL METHOD go_grid_300->check_changed_data
    IMPORTING
      e_valid = lv_check.

  CHECK lv_check EQ abap_true.

  DATA:
    lv_file TYPE rlgrap-filename,
    lt_xls  TYPE STANDARD TABLE OF ty_opt2_xls.

  "파일명 선택
  PERFORM f_get_file_name CHANGING lv_file.

  "Excel 조회
  CHECK lv_file IS NOT INITIAL.
  PERFORM f_get_excel_data USING 1 2 25 60000 lv_file 'TY_OPT2_XLS' CHANGING lt_xls.

  "데이터 설정
  PERFORM f_set_alv_data_opt2 USING lt_xls CHANGING gt_opt2 lv_check.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ALV_DATA_OPT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_XLS
*&      <-- GT_OPT2
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM f_set_alv_data_opt2  USING  pt_xls TYPE ty_t_opt2_xls
                          CHANGING ct_opt2 TYPE ty_t_opt2
                                   cv_check.

  "초기화
  CLEAR:
    ct_opt2[],
    cv_check.

  DATA:
    lt_fname   TYPE ty_t_fname,
    ls_opt2    TYPE ty_opt2,
    lv_amt_ext TYPE bapicurr-bapicurr,
    lv_amt_int TYPE matdoc-dmbtr.

  lt_fname = VALUE #( ( fname =  'KNTTP' )
                                     ( fname =  'MATNR' )
                                     ( fname =  'WERKS' )
                                     ( fname =  'LGORT' )
                                     ( fname =  'MENGE' )
                                     ( fname =  'MEINS' )
                                     ( fname =  'LFDAT' )
                                     ( fname =  'EKORG' )
                                     ( fname =  'EKGRP' )
                                     ( fname =  'AFNAM' )
                                     ( fname =  'LIFNR' )
                                     ( fname =  'FLIEF' )
                                     ( fname =  'PREIS' )
                                     ( fname =  'WAERS' )
                                     ( fname =  'PEINH' )
                                     ( fname =  'MATKL' )
                                     ( fname =  'KOSTL' )
                                     ( fname =  'SAKTO' )
                                     ( fname =  'ANLN1' )
                                     ( fname =  'AUFNR' )
                                     ( fname =  'PS_PSP_PNR' )
                                      ).

  LOOP AT pt_xls ASSIGNING FIELD-SYMBOL(<ls_xls>).
    "초기화
    CLEAR ls_opt2.


    "대문자 변경
    TRANSLATE:
      <ls_xls>-knttp TO UPPER CASE,
      <ls_xls>-matnr TO UPPER CASE,
      <ls_xls>-werks TO UPPER CASE,
      <ls_xls>-lgort TO UPPER CASE,
      <ls_xls>-waers TO UPPER CASE,
      <ls_xls>-ekorg TO UPPER CASE,
      <ls_xls>-ekgrp TO UPPER CASE,
      <ls_xls>-lifnr TO UPPER CASE,
      <ls_xls>-flief TO UPPER CASE,
      <ls_xls>-kostl TO UPPER CASE,
      <ls_xls>-sakto TO UPPER CASE,
      <ls_xls>-anln1 TO UPPER CASE,
      <ls_xls>-aufnr TO UPPER CASE,
      <ls_xls>-ps_psp_pnr TO UPPER CASE.

    "콤마 제거
    REPLACE ALL OCCURRENCES OF ',' IN <ls_xls>-preis WITH space.
    REPLACE ALL OCCURRENCES OF ',' IN <ls_xls>-menge WITH space.

    "숫자만 남기고 제거)
    REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]]' IN <ls_xls>-lfdat WITH space.
    REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]]' IN <ls_xls>-peinh WITH space.

    "공백 제거
    CONDENSE:
      <ls_xls>-preis,
      <ls_xls>-menge,
      <ls_xls>-lfdat,
      <ls_xls>-peinh,
      <ls_xls>-waers.

    "WBS
    DATA lv_ps_psp_pnr TYPE ps_psp_pnr.
    CALL FUNCTION 'CONVERSION_EXIT_ABPSP_INPUT'
      EXPORTING
        input     = <ls_xls>-ps_psp_pnr
      IMPORTING
        output    = lv_ps_psp_pnr
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc EQ 0.
      <ls_xls>-ps_psp_pnr = lv_ps_psp_pnr.
    ENDIF.

    "값 설정
    ls_opt2 = CORRESPONDING #( BASE ( ls_opt2 )  <ls_xls> ).

    "Alpha conversion
    ls_opt2-lifnr = |{ ls_opt2-lifnr ALPHA = IN }|.
    ls_opt2-flief = |{ ls_opt2-flief ALPHA = IN }|.

    ls_opt2-kostl = |{ ls_opt2-kostl ALPHA = IN }|.
    ls_opt2-sakto = |{ ls_opt2-sakto ALPHA = IN }|.
    ls_opt2-anln1 = |{ ls_opt2-anln1 ALPHA = IN }|.
    ls_opt2-aufnr = |{ ls_opt2-aufnr ALPHA = IN }|.

    "단위
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input  = ls_opt2-meins
      IMPORTING
        output = ls_opt2-meins.

    "자재코드
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = ls_opt2-matnr
      IMPORTING
        output = ls_opt2-matnr.

    IF ls_opt2-preis IS NOT INITIAL AND ls_opt2-waers IS NOT INITIAL.
      CLEAR:
       lv_amt_ext,
       lv_amt_int.

      "금액 변환(Ext - > Int)
      lv_amt_ext = ls_opt2-preis.
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
        EXPORTING
          currency             = ls_opt2-waers
          amount_external      = lv_amt_ext
          max_number_of_digits = 23
        IMPORTING
          amount_internal      = lv_amt_int.

      ls_opt2-preis = lv_amt_int.
    ENDIF.


    "라인추가
    APPEND ls_opt2 TO ct_opt2.

  ENDLOOP.


  CHECK ct_opt2[] IS NOT INITIAL. "데이터가 있으면 진행

  SELECT
    mr~matnr,
    mr~meins,
    mr~matkl,
    mt~maktx
    FROM mara AS mr
                LEFT OUTER JOIN
               makt AS mt ON mr~matnr EQ mt~matnr
                                 AND mt~spras EQ @sy-langu
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT zz~matnr
        FROM @ct_opt2 AS zz
        WHERE zz~matnr EQ mr~matnr
    )
    ORDER BY mr~matnr
    INTO TABLE @DATA(lt_mara).

  SELECT
    mc~matnr,
    mc~werks,
    mc~ekgrp,
    mw~stprs,
    mw~peinh
    FROM marc AS mc
                  LEFT OUTER JOIN
              mbew AS mw ON mc~matnr EQ mw~matnr
                                AND mc~werks EQ mw~bwkey
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT zz~matnr
        FROM @ct_opt2 AS zz
        WHERE zz~matnr EQ mc~matnr
             AND zz~werks EQ mc~werks
    )
    ORDER BY mc~matnr, mc~werks
    INTO TABLE @DATA(lt_marc).

  LOOP AT ct_opt2 ASSIGNING FIELD-SYMBOL(<ls_opt2>).
    IF <ls_opt2>-matnr IS NOT INITIAL.
      READ TABLE lt_mara ASSIGNING FIELD-SYMBOL(<ls_mara>) WITH KEY matnr = <ls_opt2>-matnr BINARY SEARCH.
      IF sy-subrc EQ 0.
        <ls_opt2>-maktx = <ls_mara>-maktx.

*"1) Possible Entry or 입력 가능
*2) MATNR = """" 이면 Editable
*3) MATNR <> """" 이면 MARA-MATTKL 값으로 보여줌, 수정 불가"
        <ls_opt2>-matkl = <ls_mara>-matkl.

        "1) Possible Entry or 입력 가능
*2) MATNR <>""""이면 MARA-MEINS 값으로 보여줌, 수정불가
*3) MATNR = """" 이면 Editable"
        <ls_opt2>-meins = <ls_mara>-meins.
        <ls_opt2>-zstyle = VALUE #( BASE <ls_opt2>-zstyle ( fieldname = 'MATKL' style = cl_gui_alv_grid=>mc_style_disabled )
                                                                                                   ( fieldname = 'MEINS' style = cl_gui_alv_grid=>mc_style_disabled ) ).

      ENDIF.


      IF <ls_opt2>-werks IS NOT INITIAL.
        READ TABLE lt_marc ASSIGNING FIELD-SYMBOL(<ls_marc>) WITH KEY matnr = <ls_opt2>-matnr
                                                                                                          werks = <ls_opt2>-werks BINARY SEARCH.

        IF sy-subrc EQ 0.
*"1) Possible Entry or 입력 가능
*2) MATNR, WERKS 입력값 기준으로 MARC-EKGRP 값으로 보여줌, 수정 가능"
          IF <ls_opt2>-ekgrp IS INITIAL.
            <ls_opt2>-ekgrp = <ls_marc>-ekgrp.
          ENDIF.

*"1) MATNR,WERKS 입력값에 따라 자재 단가 조회
*Table: MBEW
*SELECT 조건: STPRS
*WHERE 조건 : MATNR, WERKS
*-> 조회 조건의 BUKRS 값 기준으로 T001-WAERS = ""KRW"" 이면 STPRS*100
*2) 직접 입력 가능"
          IF <ls_opt2>-preis IS INITIAL.
            <ls_opt2>-preis = <ls_marc>-stprs.
          ENDIF.

          IF <ls_opt2>-peinh IS INITIAL.
            <ls_opt2>-peinh = <ls_marc>-peinh.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.


*"1) WERKS 입력값이 있으면 기본값 1 로 보여줌
*2) 수정 가능"
    IF <ls_opt2>-peinh IS INITIAL.
      <ls_opt2>-peinh = 1.
    ENDIF.

    CLEAR <ls_opt2>-zamt.
    IF <ls_opt2>-peinh IS NOT INITIAL.
      <ls_opt2>-zamt = ( <ls_opt2>-menge * <ls_opt2>-preis ) / <ls_opt2>-peinh.
    ENDIF.

*"1) Possible Entry or 입력 가능
*2) WERKS 입력 값이 있으면 조건입력 값 BUKRS 기준으로 T001-WAERS 값을 기본값으로 보여줌"
    IF <ls_opt2>-waers IS INITIAL.
      <ls_opt2>-waers = gv_waers.
    ENDIF.

    "코스트센터 명                  KTEXT CSKT-KTEXT  Display KOSTL 입력 값에 따라 해당 텍스트로 보여줌
    IF <ls_opt2>-kostl IS NOT INITIAL.
      CLEAR <ls_opt2>-kostl_text.
      SELECT SINGLE
        ktext
        FROM cskt
        WHERE kokrs EQ @p_bukrs
        AND kostl EQ @<ls_opt2>-kostl
        AND datbi EQ '99991231'
        AND spras EQ @sy-langu
        INTO @<ls_opt2>-kostl_text.
    ENDIF.

*G/L 계정내역                 TXT20 SKAT-XT20 Display SAKTO 입력 값에 따라 해당 텍스트로 보여줌
    IF <ls_opt2>-sakto IS NOT INITIAL.
      CLEAR <ls_opt2>-sakto_text.
      SELECT SINGLE
        st~txt20
        FROM t001 AS t1
                  INNER JOIN
                skat AS st ON t1~ktopl EQ st~ktopl
        WHERE t1~bukrs EQ @p_bukrs
        AND st~saknr EQ @<ls_opt2>-sakto
        AND st~spras EQ @sy-langu
        INTO @<ls_opt2>-sakto_text.
    ENDIF.

*자산명                  TXT50 ANLA-TXT50  Display ANLN1 입력 값에 따라 해당 텍스트로 보여줌
    IF <ls_opt2>-anln1 IS NOT INITIAL.
      CLEAR <ls_opt2>-txt50.
      SELECT SINGLE
        txt50
        FROM anla
        WHERE bukrs EQ @p_bukrs
        AND anln1 EQ @<ls_opt2>-anln1
        INTO @<ls_opt2>-txt50.
    ENDIF.

*오더 내역                  KTEXT AUFK-KTEXT  Display AUFNR 입력 값에 따라 해당 텍스트로 보여줌
    IF <ls_opt2>-aufnr IS NOT INITIAL.
      CLEAR <ls_opt2>-aufnr_text.
      SELECT SINGLE
        ktext
        FROM aufk
        WHERE aufnr EQ @<ls_opt2>-aufnr
        INTO @<ls_opt2>-aufnr_text.
    ENDIF.

*WBS 내역                 POST1 PRPS-POST1  Display PS_PSP_PNR 입력 값에 따라 해당 텍스트로 보여줌
    IF <ls_opt2>-ps_psp_pnr IS NOT INITIAL.
      CLEAR <ls_opt2>-post1.
      SELECT SINGLE
        post1
        FROM prps
        WHERE pspnr EQ @<ls_opt2>-ps_psp_pnr
        INTO @<ls_opt2>-post1.
    ENDIF.

    "코드 텍스트 설정
    PERFORM f_set_code_text_opt2 USING lt_fname CHANGING <ls_opt2>.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CREATE_PR_OPT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_create_pr_opt2 .
*
*5. 구매 요청 생성 버튼
*	5-1) 라인은 다중선택 가능 (전체선택 포함)
*	5-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*	5-3) 생성 대상 데이터 점검
*     : 점검시 필수 값이 없으면 하단 메시지 처리 "필수 입력 값을 확인하세요."
*       대상 리스트의 STATUS 업데이트  : RED 로 업데이트 (점검 정산인 경우 YELLOW)
*       대상 ALV 리스트의 MESSAGE 업데이트 : " 필수 입력 값이 누락 되었습니다. "

  DATA:
    lv_check  TYPE c LENGTH 1,
    lt_row_id TYPE lvc_t_roid.

  FIELD-SYMBOLS:
    <ls_row_id> TYPE lvc_s_roid,
    <ls_opt2>   TYPE ty_opt2.

  CALL METHOD go_grid_300->check_changed_data
    IMPORTING
      e_valid = lv_check.

  CHECK lv_check EQ abap_true.

  CALL METHOD go_grid_300->get_selected_rows
    IMPORTING
      et_row_no = lt_row_id.

  DELETE lt_row_id WHERE row_id LE 0.
*	5-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  IF lt_row_id[] IS INITIAL.
    MESSAGE e163.
  ENDIF.

  "데이터 점검
  CLEAR lv_check.
  PERFORM f_check_pr_create_opt2 USING lt_row_id CHANGING lv_check.

  CHECK lv_check NE gc_e. "오류가 없는 경우 진행

  "생성
  PERFORM f_run_create_bapi_opt2 USING lt_row_id.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_PR_CREATE_OPT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_ID
*&      <-- LV_CHECK
*&---------------------------------------------------------------------*
FORM f_check_pr_create_opt2  USING pt_row_id TYPE lvc_t_roid
                             CHANGING cv_check.

  FIELD-SYMBOLS:
    <ls_row_id> TYPE lvc_s_roid,
    <ls_opt2>   TYPE ty_opt2.

*5-4) 선택한 라인에 BANFN 값이 있는 경우 하단 에러메세지 "구매요청 생성된 데이터가 존재합니다."
*5-5) 예산점검 실행 전 상태라면 하단 에러메세지 "예산점검을 수행하세요."
  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt2 ASSIGNING <ls_opt2> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.
    IF <ls_opt2>-banfn IS NOT INITIAL.
      MESSAGE e000 WITH TEXT-e04.
    ENDIF.

    IF <ls_opt2>-bgchk NE abap_true.
      MESSAGE e000 WITH TEXT-e11.
    ENDIF.

    IF <ls_opt2>-knttp EQ gc_a.
*2) 비상비 자재인 경우 "A" 입력 시 오류메세지
*-> 자산 구매는 "O" 를 선택하세요. -> 추가
      MESSAGE e000 WITH TEXT-e12. "자산 구매는 "O" 를 선택하세요.
    ENDIF.
  ENDLOOP.

*	5-3) 생성 대상 데이터 점검
*     : 점검시 필수 값이 없으면 하단 메시지 처리 "필수 입력 값을 확인하세요."
*       대상 리스트의 STATUS 업데이트  : RED 로 업데이트 (점검 정산인 경우 YELLOW)
*       대상 ALV 리스트의 MESSAGE 업데이트 : " 필수 입력 값이 누락 되었습니다. "
  CLEAR cv_check.
  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt2 ASSIGNING <ls_opt2> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.

    "초기화
    CLEAR:
      <ls_opt2>-status,
      <ls_opt2>-message.

*계정 지정범주                  KNTTP "1) 생성 대상 = 비상비자재 인 경우 필수
*2) MATNR = """" 이면 필수"
*
*자재번호                 MATNR KNTTP = "" 이면 필수
    IF <ls_opt2>-knttp IS INITIAL.
      <ls_opt2>-status = icon_led_red.
      <ls_opt2>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
      cv_check = gc_e.
      CONTINUE.
    ENDIF.

*자재그룹                 MATKL 1KNTTP <>"" 이고 MATNR = "" 이면 필수
    IF <ls_opt2>-knttp IS NOT INITIAL AND <ls_opt2>-matnr IS INITIAL
      AND <ls_opt2>-matkl IS INITIAL.
      <ls_opt2>-status = icon_led_red.
      <ls_opt2>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
      cv_check = gc_e.
      CONTINUE.
    ENDIF.


*자재내역                 MAKTX 필수
*플랜트                  WERKS 필수
*저장위치                 LGORT 필수
*요청 수량                  MENGE 필수
*요청 단위                  MEINS 필수
*납품 요청일                 LFDAT 필수
*구매조직                 EKORG 필수
*구매그룹                 EKGRP 필수
*요청자                  AFNAM 필수
*예상 가격                  PREIS 필수
*가격 통화                  WAERS 필수
*가격 단위                  PEINH 필수
    IF <ls_opt2>-maktx IS INITIAL
      OR <ls_opt2>-werks IS INITIAL
*      OR <LS_OPT2>-LGORT IS INITIAL "2) 비상비 자재인 경우 저장위치 필수값 제외 2026.04.06
      OR <ls_opt2>-menge IS INITIAL
      OR <ls_opt2>-meins IS INITIAL
      OR <ls_opt2>-lfdat IS INITIAL
      OR <ls_opt2>-ekorg IS INITIAL
      OR <ls_opt2>-ekgrp IS INITIAL
      OR <ls_opt2>-afnam IS INITIAL
      OR <ls_opt2>-preis IS INITIAL
      OR <ls_opt2>-waers IS INITIAL
      OR <ls_opt2>-peinh IS INITIAL.
      <ls_opt2>-status = icon_led_red.
      <ls_opt2>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
      cv_check = gc_e.
      CONTINUE.
    ENDIF.

    CASE <ls_opt2>-knttp.
*      WHEN GC_A.
**2) 비상비 자재인 경우 "A" 입력 시 오류메세지
**-> 자산 구매는 "O" 를 선택하세요. -> 추가
*        <LS_OPT2>-MESSAGE = TEXT-E12. "자산 구매는 "O" 를 선택하세요.
*        CV_CHECK = GC_E.

      WHEN gc_m.
**영업오더                 VBELN KNTTP = "M" 이면 필수
**영업오더품목                 VBELP KNTTP = "M" 이면 필수
*        IF <LS_OPT2>-VBELN IS INITIAL OR <LS_OPT2>-VBELP IS INITIAL.
*          <LS_OPT2>-STATUS = ICON_LED_RED.
*          <LS_OPT2>-MESSAGE = TEXT-E03. "필수 입력 값이 누락 되었습니다.
*          CV_CHECK = GC_E.
*          CONTINUE.
*        ENDIF.

      WHEN gc_k.
**코스트센터                  KOSTL KNTTP = "K" 이면 필수
**G/L 계정                 SAKTO KNTTP = "K" or "F" or "P" 이면 필수
        IF <ls_opt2>-kostl IS INITIAL OR <ls_opt2>-sakto IS INITIAL.
          <ls_opt2>-status = icon_led_red.
          <ls_opt2>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
          cv_check = gc_e.
        ENDIF.

      WHEN gc_f.
*G/L 계정                 SAKTO KNTTP = "K" or "F" or "P" 이면 필수
*오더번호                 AUFNR KNTTP = "F" 이면 필수
        IF <ls_opt2>-sakto IS INITIAL OR <ls_opt2>-aufnr IS INITIAL.
          <ls_opt2>-status = icon_led_red.
          <ls_opt2>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
          cv_check = gc_e.
        ENDIF.

      WHEN gc_p.
*G/L 계정                 SAKTO KNTTP = "K" or "F" or "P" 이면 필수
*WBS 코드                 PS_PSP_PNR  KNTTP = "P" 이면 필수
        IF <ls_opt2>-sakto IS INITIAL OR <ls_opt2>-ps_psp_pnr IS INITIAL.
          <ls_opt2>-status = icon_led_red.
          <ls_opt2>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
          cv_check = gc_e.
        ENDIF.

      WHEN gc_o.
*자산번호                 ANLN1 KNTTP = "O" 이면 필수 자산 계정지정 범주기준 코드 변경
        IF <ls_opt2>-anln1 IS INITIAL.
          <ls_opt2>-status = icon_led_red.
          <ls_opt2>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
          cv_check = gc_e.
        ENDIF.

    ENDCASE.

    IF <ls_opt2>-knttp IS NOT INITIAL.
*하역지점                 ABLAD KNTTP <> "" 이면 필수
*수령인                  WEMPF KNTTP <> "" 이면 필수
      IF <ls_opt2>-ablad IS INITIAL OR <ls_opt2>-wempf IS INITIAL.
        <ls_opt2>-status = icon_led_red.
        <ls_opt2>-message = TEXT-e03. "필수 입력 값이 누락 되었습니다.
        cv_check = gc_e.
      ENDIF.
    ENDIF.
  ENDLOOP.

  ": 점검시 필수 값이 없으면 하단 메시지 처리 "필수 입력 값을 확인하세요."
  IF cv_check EQ gc_e.
    MESSAGE s000 DISPLAY LIKE gc_e WITH TEXT-e05.
    EXIT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_RUN_CREATE_BAPI_OPT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_ID
*&---------------------------------------------------------------------*
FORM f_run_create_bapi_opt2  USING  pt_row_id TYPE lvc_t_roid.

*5-5) 선택한 라인이 존재하고 BANFN = "", 오류가 없는경우 POP-UP 확인 후 구매요청 생성 처리
  DATA lv_ans   TYPE c LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar      = TEXT-tt1
      text_question = TEXT-q03
    IMPORTING
      answer        = lv_ans.
  CHECK lv_ans EQ gc_1.

  FIELD-SYMBOLS:
    <ls_row_id> TYPE lvc_s_roid,
    <ls_opt2>   TYPE ty_opt2.

*4-7) BAPI_PR_CREATE 호출 PR 생성 수행
  DATA:
    lv_check      TYPE c LENGTH 1,
    lv_bnfpo      TYPE bnfpo,
    lv_ps_posid   TYPE ps_posid,
    lv_preq_price TYPE c LENGTH 30,
    lt_return     TYPE STANDARD TABLE OF bapiret2,
    ls_header     TYPE bapimereqheader,
    ls_headerx    TYPE bapimereqheaderx,
    lt_item       TYPE STANDARD TABLE OF bapimereqitemimp,
    lt_itemx      TYPE STANDARD TABLE OF bapimereqitemx,
    lt_account    TYPE STANDARD TABLE OF bapimereqaccount,
    lt_accountx   TYPE STANDARD TABLE OF bapimereqaccountx,
    lt_itemtext   TYPE STANDARD TABLE OF bapimereqitemtext,
    ls_ret        TYPE bapimereqheader.

  FIELD-SYMBOLS <ls_return> TYPE bapiret2.

  "header
  ls_header-pr_type = gc_nb.
  ls_headerx-pr_type = abap_true.

  "item / Account
  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt2 ASSIGNING <ls_opt2> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.

    "금액
    CLEAR lv_preq_price.
    WRITE <ls_opt2>-preis TO lv_preq_price CURRENCY <ls_opt2>-waers LEFT-JUSTIFIED NO-GROUPING NO-GAP.
    CONDENSE lv_preq_price.

    lv_bnfpo += 10.
    lt_item = VALUE #( BASE lt_item ( preq_item = lv_bnfpo
                            pur_group = <ls_opt2>-ekgrp
                            material = <ls_opt2>-matnr
                            short_text = <ls_opt2>-maktx
                            plant = <ls_opt2>-werks
                            store_loc = <ls_opt2>-lgort
                            matl_group = <ls_opt2>-matkl
                            preq_name = <ls_opt2>-afnam
                            quantity = <ls_opt2>-menge
                            unit = <ls_opt2>-meins
                            deliv_date = <ls_opt2>-lfdat
                            preq_price = lv_preq_price
                            price_unit = <ls_opt2>-peinh
                            acctasscat = <ls_opt2>-knttp
                            purch_org = <ls_opt2>-ekorg
                            currency = <ls_opt2>-waers
                            des_vendor = <ls_opt2>-lifnr
                            fixed_vend = <ls_opt2>-flief
                            gr_ind = abap_true
                            ir_ind = abap_true
                            tax_code = <ls_opt2>-mwskz
    ) ).
    lt_itemx = VALUE #( BASE lt_itemx ( preq_item = lv_bnfpo
                            pur_group = abap_true
                            material = abap_true
                            short_text = abap_true
                            plant = abap_true
                            store_loc = abap_true
                            matl_group = abap_true
                            preq_name = abap_true
                            quantity = abap_true
                            unit = abap_true
                            deliv_date = abap_true
                            preq_price = abap_true
                            price_unit = abap_true
                            acctasscat = abap_true
                            purch_org = abap_true
                            currency = abap_true
                            des_vendor = abap_true
                            fixed_vend = abap_true
                            gr_ind = abap_true
                            ir_ind = abap_true
                            tax_code = abap_true
    ) ).

*4-6-7) PRITEMTEXT 설정
*BAPI 필드                    VALUE 비고
*PREQ_ITEM                    PRITEM-PREQ_ITEM
*TEXT_ID    B01'
*TEXT_LINE  ALV-ITEMTEXT

    IF <ls_opt2>-itemtext IS NOT INITIAL.
      DATA lt_tline TYPE STANDARD TABLE OF tline.

      CALL FUNCTION 'VB_CP_CONVERT_STRING_2_ITF'
        EXPORTING
          i_string = <ls_opt2>-itemtext
        TABLES
          et_table = lt_tline.

      IF lt_tline[] IS NOT INITIAL.
        LOOP AT lt_tline ASSIGNING FIELD-SYMBOL(<ls_tline>).
          lt_itemtext = VALUE #( BASE lt_itemtext (
                 preq_item = lv_bnfpo
                 text_id = 'B01'
                 text_form = <ls_tline>-tdformat
                 text_line = <ls_tline>-tdline
          ) ).

        ENDLOOP.
      ENDIF.


    ENDIF.


    IF <ls_opt2>-kostl IS NOT INITIAL
      OR <ls_opt2>-sakto IS NOT INITIAL
      OR <ls_opt2>-anln1 IS NOT INITIAL
      OR <ls_opt2>-aufnr IS NOT INITIAL
      OR <ls_opt2>-ps_psp_pnr IS NOT INITIAL
      OR <ls_opt2>-ablad IS NOT INITIAL
      OR <ls_opt2>-wempf IS NOT INITIAL.

      CLEAR lv_ps_posid.
      IF <ls_opt2>-ps_psp_pnr IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
          EXPORTING
            input  = <ls_opt2>-ps_psp_pnr
          IMPORTING
            output = lv_ps_posid.
      ENDIF.

      lt_account = VALUE #( BASE lt_account (
           preq_item = lv_bnfpo
           serial_no = 1
           quantity = COND #( WHEN <ls_opt2>-knttp EQ gc_a THEN 1 ELSE 0 )
           costcenter = COND #( WHEN <ls_opt2>-kostl IS NOT INITIAL THEN <ls_opt2>-kostl ELSE space )
           gl_account = COND #( WHEN <ls_opt2>-sakto IS NOT INITIAL THEN <ls_opt2>-sakto ELSE space )
           asset_no = COND #( WHEN <ls_opt2>-anln1 IS NOT INITIAL THEN <ls_opt2>-anln1 ELSE space )
           orderid = COND #( WHEN <ls_opt2>-aufnr IS NOT INITIAL THEN <ls_opt2>-aufnr ELSE space )
           wbs_element = COND #( WHEN <ls_opt2>-ps_psp_pnr IS NOT INITIAL THEN lv_ps_posid ELSE space )
           unload_pt = COND #( WHEN <ls_opt2>-ablad IS NOT INITIAL THEN <ls_opt2>-ablad ELSE space )
           gr_rcpt = COND #( WHEN <ls_opt2>-wempf IS NOT INITIAL THEN <ls_opt2>-wempf ELSE space )
      ) ).

      lt_accountx = VALUE #( BASE lt_accountx (
           preq_item = lv_bnfpo
           serial_no = 1
           quantity = COND #( WHEN <ls_opt2>-knttp EQ gc_a THEN abap_true ELSE space )
           costcenter = COND #( WHEN <ls_opt2>-kostl IS NOT INITIAL THEN abap_true ELSE space )
           gl_account = COND #( WHEN <ls_opt2>-sakto IS NOT INITIAL THEN abap_true ELSE space )
           asset_no = COND #( WHEN <ls_opt2>-anln1 IS NOT INITIAL THEN abap_true ELSE space )
           orderid = COND #( WHEN <ls_opt2>-aufnr IS NOT INITIAL THEN abap_true ELSE space )
           wbs_element = COND #( WHEN <ls_opt2>-ps_psp_pnr IS NOT INITIAL THEN abap_true ELSE space )
           unload_pt = COND #( WHEN <ls_opt2>-ablad IS NOT INITIAL THEN abap_true ELSE space )
           gr_rcpt = COND #( WHEN <ls_opt2>-wempf IS NOT INITIAL THEN abap_true ELSE space )
      ) ).

    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_PR_CREATE'
    EXPORTING
      prheader    = ls_header
      prheaderx   = ls_headerx
*     TESTRUN     =
    IMPORTING
*     NUMBER      =
      prheaderexp = ls_ret
    TABLES
      return      = lt_return
      pritem      = lt_item
      pritemx     = lt_itemx
      praccount   = lt_account
      praccountx  = lt_accountx
      pritemtext  = lt_itemtext.

*	4-7-3) RETURN-TYPE = E 이거나 BANFN 값이 NULL 이면
*   : CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
*   : ALV 화면 필드 업데이트
*
*   필드                  VALUE
*   STATUS                  RED
*   MESSAGE                 RETURN-MESSAGE 대표 메시지
*
*4-7-4) RETURN-TYPE = S 이고 BANFN <> "" 이면
*: CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*: ALV 화면 필드 업데이트
*
*필드                 VALUE
*STATUS                 GREEN
*MESSAGE                  구매요청이 생성 되었습니다.
*BANFN                  생성 구매요청번호
*BNFPO                  생성 구매요청품목번호

  READ TABLE lt_return WITH KEY type = gc_e TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    lv_check  = gc_e.
  ELSE.
    IF ls_ret-preq_no IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      lv_check  = gc_e.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
    ENDIF.
  ENDIF.


  CLEAR lv_bnfpo.
  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt2 ASSIGNING <ls_opt2> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.

    lv_bnfpo += 10.

    IF lv_check EQ gc_e.
      <ls_opt2>-status = icon_led_red.
      DELETE lt_return WHERE type = gc_e AND id = 'BAPI' AND number = '001'.
      READ TABLE lt_return ASSIGNING <ls_return> WITH KEY type = gc_e.
      IF sy-subrc NE 0.
        READ TABLE lt_return ASSIGNING <ls_return> WITH KEY type = gc_a.
        IF sy-subrc NE 0.
          READ TABLE lt_return ASSIGNING <ls_return> WITH KEY type = gc_w.
        ENDIF.
      ENDIF.
      IF sy-subrc EQ 0.
        <ls_opt2>-message = <ls_return>-message.
      ENDIF.
    ELSE.

      <ls_opt2>-banfn = ls_ret-preq_no.
      <ls_opt2>-bnfpo = lv_bnfpo.
      <ls_opt2>-status = icon_led_green.
      <ls_opt2>-message = TEXT-m02. "구매요청이 생성 되었습니다.
      PERFORM f_set_zstyle_opt2 CHANGING <ls_opt2>. "Style 설정
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ZSTYLE_OPT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_OPT2>
*&---------------------------------------------------------------------*
FORM f_set_zstyle_opt2  CHANGING cs_opt2 TYPE ty_opt2.

  CHECK cs_opt2-banfn IS NOT INITIAL. "PR번호가 있으면 수정하지 못하게 함
  CLEAR cs_opt2-zstyle[].

  LOOP AT gt_fcat_300 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CHECK <ls_fcat>-edit = abap_true.
    cs_opt2-zstyle = VALUE #( BASE cs_opt2-zstyle ( fieldname = <ls_fcat>-fieldname style = cl_gui_alv_grid=>mc_style_disabled ) ).
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_APPROVAL_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_approval_req .

*5. 승인 요청 버튼
*	5-1) 라인은 다중선택 가능 (전체선택 포함)
*	5-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
*	5-4) 선택한 라인에 BANFN 값이 없는 데이터가 있으면 하단 에러메세지 "구매요청 생성된 건만 요청 가능합니다."
*	5-5) 선택한 라인이 존재하고 BANFN <> "", 오류가 없는 경우 요청 금액 기준 점검 처리 유형 분기
*   5-5-1) 선택 라인의 요청금액(ZMAT) 총합이 1,000 만원 이상 이면
*      : POP UP 확인 후 결재요청 그룹웨어(WELS) 연동

  DATA:
    lv_check  TYPE c LENGTH 1,
    lt_row_id TYPE lvc_t_roid.

  FIELD-SYMBOLS:
    <ls_row_id> TYPE lvc_s_roid,
    <ls_opt2>   TYPE ty_opt2.

  CALL METHOD go_grid_300->check_changed_data
    IMPORTING
      e_valid = lv_check.

  CHECK lv_check EQ abap_true.

  CALL METHOD go_grid_300->get_selected_rows
    IMPORTING
      et_row_no = lt_row_id.

  DELETE lt_row_id WHERE row_id LE 0.
*	5-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  IF lt_row_id[] IS INITIAL.
    MESSAGE e163.
  ENDIF.

*	5-4) 선택한 라인에 BANFN 값이 없는 데이터가 있으면 하단 에러메세지 "구매요청 생성된 건만 요청 가능합니다."
*5-5) 선택한 라인에 ZGTMMT1070 승인 요청된 이력이 존재 하고 ERDAT <>""  인 데이터가 있으면 하단 에러메세지 "승인요청 된 구매요청이 존재합니다."
*     요청 이력 점검 기준 : 동일한 BANFN,BNFPO
  SELECT
    z1~banfn,
    z1~bnfpo
    FROM zgtmmt1070 AS z1
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT zz~banfn
        FROM @gt_opt2 AS zz
        WHERE zz~banfn EQ z1~banfn
           AND zz~bnfpo EQ z1~bnfpo
           AND zz~banfn IS NOT INITIAL
    )
    AND z1~erdat IS NOT INITIAL
    AND z1~appstatus NE @space
    AND z1~appstatus NE @gc_r
    ORDER BY z1~banfn, z1~bnfpo
    INTO TABLE @DATA(lt_chk1).

*	5-6) ZGTMMT1070 승인 요청 이 및 결재 상태 수신 값 기준으로재 승인 요청 재실행 가능
*5-6-1) ZGTMMT1070 BANFO, BNFPO 존재하고 APPSTATUS= "" 이거나 "R" 이면 승인요청 재 선택 가능
*   5-6-2) 승인 요청 이력확인 : ZGTMMT1070 BAFNO, BNFPO,APPID 존재
*           결재 수신 상태값 확인 : ZGTMMT1051-STATUS = "T" or "R" or "W" 이면  재 승인요청 가능
*	    -> 승인요청 재 실행 시점에 리턴 받은 APPID로 ZGTMMT1070 데이터 업데이트
  SELECT
    z1~banfn,
    z1~bnfpo
    FROM zgtmmt1070 AS z1
##ITAB_KEY_IN_SELECT
   WHERE EXISTS (
     SELECT zz~banfn
       FROM @gt_opt2 AS zz
       WHERE zz~banfn EQ z1~banfn
          AND zz~bnfpo EQ z1~bnfpo
          AND zz~banfn IS NOT INITIAL
   )
    AND z1~appid IS NOT INITIAL
    AND EXISTS (
     SELECT ap~appid
       FROM zgtmmt1051 AS ap
       WHERE ap~appid EQ z1~appid
       AND ap~status IN ( @gc_t, @gc_r, @gc_w )
    )
   ORDER BY z1~banfn, z1~bnfpo
   INTO TABLE @DATA(lt_chk2).

  LOOP AT lt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt2 ASSIGNING <ls_opt2> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.
    IF <ls_opt2>-banfn IS INITIAL.
      MESSAGE e000 WITH TEXT-e07. "구매요청 생성된 건만 요청 가능합니다.
    ENDIF.

    READ TABLE lt_chk1 WITH KEY banfn = <ls_opt2>-banfn bnfpo = <ls_opt2>-bnfpo BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      READ TABLE lt_chk2 WITH KEY banfn = <ls_opt2>-banfn bnfpo = <ls_opt2>-bnfpo BINARY SEARCH TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        MESSAGE e000 WITH TEXT-e09. "승인요청 된 구매요청이 존재합니다.
      ENDIF.
    ENDIF.

  ENDLOOP.

  "요청 금액 확인
  DATA:
    lv_dmbtr_tot TYPE dmbtr,
    lv_dmbtr     TYPE dmbtr.

  LOOP AT lt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt2 ASSIGNING <ls_opt2> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.

    CLEAR lv_dmbtr.
    CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
      EXPORTING
        date             = sy-datlo
        foreign_amount   = <ls_opt2>-zamt
        foreign_currency = <ls_opt2>-waers
        local_currency   = gv_waers
      IMPORTING
        local_amount     = lv_dmbtr
      EXCEPTIONS
        no_rate_found    = 1
        overflow         = 2
        no_factors_found = 3
        no_spread_found  = 4
        derived_2_times  = 5
        OTHERS           = 6.

    lv_dmbtr_tot += lv_dmbtr.
  ENDLOOP.
*
*5-7) 선택한 라인이 존재하고 BANFN <> "", 오류가 없는 경우 요청 금액 기준 점검 처리 유형 분기
*	5-7-1) 선택 라인의 요청금액(ZMAT) 총합이 1,000 만원 이상 이면
*    : POP UP 확인 후 결재요청 그룹웨어(WELS) 연동


*5-5-1) 선택 라인의 요청금액(ZMAT) 총합이 1,000 만원 이상 이면
*	 : POP UP 확인 후 결재요청 그룹웨어(WELS) 연동
  IF lv_dmbtr_tot GE 100000.
    PERFORM f_send_gw USING lt_row_id.

  ELSE.
*5-5-2) 선택 라인의 요청금액(ZMAT) 합계가 1,000 만원 미만 이면
*	: POP UP 확인 후 승인 요청 알림 전송
    PERFORM f_send_email USING lt_row_id.

  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SEND_GW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_ID
*&---------------------------------------------------------------------*
FORM f_send_gw  USING  pt_row_id TYPE lvc_t_roid.

*그룹웨어 결재로 이동합니다. 진행 하시겠습니까?
*
  DATA lv_ans   TYPE c LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar      = TEXT-tt1
      text_question = TEXT-q04
    IMPORTING
      answer        = lv_ans.
  CHECK lv_ans EQ gc_1.


*	5-7-1-1) 그룹웨어 결재 전송 FUNCTION 호출
*	FUNCTION:  ZGTMM_APP_TO_WELS
  DATA:
    lv_pernr    TYPE char10,
    lv_tcode    TYPE char20,
    lv_reqxml   TYPE string,
    lv_mtype    TYPE bapi_mtype,
    lv_message  TYPE bapi_msg,
    lv_appid    TYPE char32,
    lv_legacyid TYPE char32,
    lv_url      TYPE string.
*
*필드         Value         비고
*I_BUKRS          조회조건 입력값
*I_PERNR          SY-NAME         승인 요청자 사번
*I_T-CODE         SY-T-CODE
*I_REQXML

  lv_pernr = sy-uname.
  lv_tcode = gc_zgtmmr2010.

  "XML 생성
  PERFORM f_set_gw_xml USING pt_row_id lv_pernr CHANGING lv_reqxml.

  CALL FUNCTION 'ZGTMM_APP_TO_WELS'
    EXPORTING
      i_bukrs  = p_bukrs
      i_pernr  = lv_pernr
      i_tcode  = lv_tcode
      i_reqxml = lv_reqxml
    IMPORTING
      mtype    = lv_mtype
      message  = lv_message
      legacyid = lv_legacyid
      appid    = lv_appid
      url      = lv_url.

  IF lv_mtype EQ gc_e.
    MESSAGE e000 WITH lv_message.
  ENDIF.

*5-7-1-3) 결재 창 호출 후 승인요청 이력 테이블 1차 저장
  DATA lt_appr TYPE STANDARD TABLE OF zgtmmt1070.

  FIELD-SYMBOLS:
    <ls_row_id> TYPE lvc_s_roid,
    <ls_opt2>   TYPE ty_opt2.

  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt2 ASSIGNING <ls_opt2> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.

    lt_appr = VALUE #( BASE lt_appr ( banfn = <ls_opt2>-banfn
                                                              bnfpo = <ls_opt2>-bnfpo
                                                              appid = lv_appid
                                                              apptype = gc_b
                                                              appuser = gc_wels
                                                              erdat = sy-datum
                                                              erdat_local = sy-datlo
                                                              ertim = sy-uzeit
                                                              ertim_local = sy-timlo
                                                              ) ).
  ENDLOOP.

  MODIFY zgtmmt1070 FROM TABLE lt_appr.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SEND_EMAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_ID
*&---------------------------------------------------------------------*
FORM f_send_email  USING  pt_row_id TYPE lvc_t_roid.

*  선택한 구매요청에 대해 승인 요청 하시겠습니까?
  DATA lv_ans   TYPE c LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar      = TEXT-tt1
      text_question = TEXT-q05
    IMPORTING
      answer        = lv_ans.
  CHECK lv_ans EQ gc_1.

*5-5-2-1) 메일 전송 수신 담당자 조회를 위한 인사 정보 추출
*A) 사용자 ID 의 부서정보 조회
*
*	Table: ZZPA0001
*	SELECT  조건 : KOSTL
*	WHERE 조건 :
*	PERNR = SY-NAME
*	BUKRS = 조회 조건 입력 값
*	ENDDA = "9999.12.31"
*
  DATA lv_syuname TYPE sy-uname.
  lv_syuname = sy-uname.
  REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]]' IN lv_syuname WITH space.

  SELECT SINGLE
    kostl
    FROM zzpa0001
    WHERE pernr EQ @lv_syuname
    AND bukrs EQ @p_bukrs
    AND endda EQ '99991231'
    INTO @DATA(lv_kostl).

*B) 부서의 승인 담담자 조회
*	Table: ZZPA0001
*	SELECT 조건 : PERNR
*	WHERE 조건:
*	KOSTL = A)의 KOSTL
*	ZZ_JOBTL = "7400"
*	ENDDA = "9999.12.31"

  "7400 없는 경우 -> 7410 -> 7500 순으로 조회

  SELECT SINGLE
    pernr
    FROM zzpa0001
    WHERE bukrs EQ @p_bukrs
    AND kostl EQ @lv_kostl
    AND zz_jobtl EQ '7400'
    AND endda EQ '99991231'
    INTO @DATA(lv_pernr).

  IF lv_pernr IS INITIAL.
    SELECT SINGLE
      pernr
      FROM zzpa0001
      WHERE bukrs EQ @p_bukrs
      AND kostl EQ @lv_kostl
      AND zz_jobtl EQ '7410'
      AND endda EQ '99991231'
      INTO @lv_pernr.

    IF lv_pernr IS INITIAL.
      SELECT SINGLE
       pernr
       FROM zzpa0001
       WHERE bukrs EQ @p_bukrs
       AND kostl EQ @lv_kostl
       AND zz_jobtl EQ '7500'
       AND endda EQ '99991231'
       INTO @lv_pernr.
    ENDIF.
  ENDIF.

  "셋 다 없는 경우 ZHRTI702에서 부서장 가져오기
  IF lv_pernr IS INITIAL.
    SELECT SINGLE dept_manager
      FROM zhrti702 AS hr
      JOIN zzpa0001 AS pa ON hr~dept_code EQ pa~orgeh
      WHERE pa~bukrs EQ @p_bukrs
        AND pa~kostl EQ @lv_kostl
        AND pa~endda EQ '99991231'
      INTO @DATA(lv_manager).

    lv_pernr = CONV pernr( |{ lv_manager ALPHA = IN }| ).
  ENDIF.


*5-5-2-2) 부서 승인 담당자 이메일 정보 추출
*
*	Table : ZPA0105
*	SELECT 조건 : SYSID
*	WEHRE 조건 :
*	PERNR = B)의 PERNR
*	SUBTY = "0007"
*	ENDDA = "9999.12.31"
  SELECT SINGLE
    usrid
    FROM zpa0105
    WHERE pernr EQ @lv_pernr
    AND subty EQ '0007'
    AND endda EQ '99991231'
    INTO @DATA(lv_sysid).
  IF lv_pernr IS INITIAL OR lv_sysid IS INITIAL.
    MESSAGE s000 DISPLAY LIKE gc_e WITH TEXT-e08. "부서의 승인 담당자 정보를 찾을 수 없습니다.
    EXIT.
  ENDIF.

  DATA:
*    LV_UNAME     TYPE SY-UNAME,
    lv_email     TYPE ad_smtpadr,
    lv_head_text TYPE so_obj_des,
    lt_msg       TYPE bcsy_text,
    lv_return    TYPE c LENGTH 1,
    lv_message   TYPE c LENGTH 100.

*  I_UNAME            5-5-2-1) B)의 ZPERSNO
*I_E-MAIL           5-5-2-2) SYSID
*I_HEAD_TEXT            [승인요청] 구매요청문서에 대한 승인요청드립니다.
*  LV_UNAME = LV_PERNR.
  lv_email = lv_sysid.
  lv_head_text = TEXT-z01.

*	5-5-2-3) 이메일 본문 내용 구성
*
*	첫번째 라인) 구매요청 " BANFN "외 &건이 승인 요청 되었습니다. (문서번호 기준으로 건수 check)
*	두번째 라인) SAP 메뉴 ZGTMMR2011 에서 대상 확인 승인 부탁드립니다.
*
*	: ALV에서 생성된 구매요청번호,생성자이름,요청일자 정보를 리스트 형태로 구성

  FIELD-SYMBOLS:
    <ls_row_id> TYPE lvc_s_roid,
    <ls_opt2>   TYPE ty_opt2.

  DATA:
    lv_banfn  TYPE eban-banfn,
    lv_cnt    TYPE int4,
    lv_cnt_c  TYPE c LENGTH 10,
    lv_date_c TYPE c LENGTH 10.

  DATA:
    lt_appr TYPE STANDARD TABLE OF zgtmmt1070,
    lv_line TYPE so_text255,
    lt_body TYPE bcsy_text.

  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt2 ASSIGNING <ls_opt2> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.

    IF lv_banfn IS INITIAL.
      lv_banfn = <ls_opt2>-banfn.
    ELSE.
      lv_cnt += 1.
    ENDIF.
  ENDLOOP.

  WRITE lv_cnt TO lv_cnt_c LEFT-JUSTIFIED NO-GAP.

  lv_line = |<html><body style="font-size:10">|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
  lv_line = |<p>{ TEXT-em1 }</p>|.
*  LV_LINE = |<p>구매요청 "{ LV_BANFN ALPHA = OUT }"외 { LV_CNT_C }건이 승인 요청 되었습니다.</p>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
  lv_line = |<p>SAP 메뉴 <strong>ZGTMMR2011</strong> 에서 확인 부탁드립니다. </p>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
*  LV_LINE = |<p>구매요청 "{ LV_BANFN ALPHA = OUT }"외 { LV_CNT_C }건이 승인 요청 되었습니다.</p>|.
*  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
*  LV_LINE = |<p>SAP 메뉴 <strong>ZGTMMR2011</strong> 에서 대상 확인 승인 부탁드립니다. </p>|.
*  LT_BODY = VALUE #( BASE LT_BODY ( LINE = LV_LINE ) ).
  lv_line = |<table border=1 STYLE="border-collapse: collapse;border-color: #000000;font-size:10" >|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).

  lv_line = |<tr align="center" style="background-color: #B3B1B1" ><td width="150px"><strong>구매요청번호</strong></td>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
  lv_line = |<td width="100px" ><strong>품목번호</strong></td>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
  lv_line = |<td width="150px" ><strong>요청자</strong></td>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
  lv_line = |<td width="150px" ><strong>요청일자</strong></td></tr>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).

  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt2 ASSIGNING <ls_opt2> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.

    lv_line = |<tr><td align="center" >{ <ls_opt2>-banfn ALPHA = OUT }</td>|.
    lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
    lv_line = |<td align="center" >{ <ls_opt2>-bnfpo ALPHA = OUT }</td>|.
    lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
    lv_line = |<td align="center" >{ <ls_opt2>-afnam }</td>|.
    lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
    lv_line = |<td align="center" >{ <ls_opt2>-lfdat+0(4) }.{ <ls_opt2>-lfdat+4(2) }.{ <ls_opt2>-lfdat+6(2) }</td></tr>|.
    lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).

    lt_appr = VALUE #( BASE lt_appr ( banfn = <ls_opt2>-banfn
                                                              bnfpo = <ls_opt2>-bnfpo
                                                              apptype = gc_a
                                                              appuser = lv_pernr ) ).

  ENDLOOP.

  lv_line = |</table></body></html>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).


  DATA:
    lv_check       TYPE c LENGTH 1,
    lo_receiver    TYPE REF TO if_recipient_bcs,
    lo_email       TYPE REF TO cl_bcs,
    lo_email_body  TYPE REF TO cl_document_bcs,
    lx_exception   TYPE REF TO cx_bcs,
    lv_send_result TYPE c.

  TRY.
      lo_email = cl_bcs=>create_persistent( ).

      lo_email_body = cl_document_bcs=>create_document(
                      i_type    = 'HTM'
                      i_text    = lt_body
                      i_subject = lv_head_text ).

      lo_email->set_document( lo_email_body ).

      lo_receiver =
      cl_cam_address_bcs=>create_internet_address( lv_email ).

      lo_email->add_recipient( i_recipient = lo_receiver
                               i_express = 'X' ).

      lo_email->set_send_immediately( 'X' ).

      lo_email->send( EXPORTING i_with_error_screen = 'X'
                      RECEIVING result = lv_send_result ).
    CATCH cx_bcs INTO lx_exception.
      lv_check = gc_e.
  ENDTRY.

*5-5-3) 메일 발송 후 승인 요청 이력 테이블 업데이트
*
*필드                   ZGTMMT1070
*BANFN                    ALV-BANFN
*BANFPO                   ALV-BANFPO
*APPTYPE                    A
*APPUSER                    ZPERSNO
*MAILSEND                   성공시 Y, 실패시 N
*ERDAT                    SY-DATUM
*ERDAT_LOCAL                    SY-DATLO
*ERTIM                    SY-UZEIT
*ERTIM_LOCAL                    SY-TIMLO
*AEDAT
*AEDAT_LOCAL
*AEZET
*AEZET_LOCAL

  LOOP AT lt_appr ASSIGNING FIELD-SYMBOL(<ls_appr>).
    IF lv_check EQ gc_e.
      <ls_appr>-mailsend = gc_n.
    ELSE.
      <ls_appr>-mailsend = gc_y.
    ENDIF.
    <ls_appr>-erdat = sy-datum.
    <ls_appr>-erdat_local = sy-datlo.
    <ls_appr>-ertim = sy-uzeit.
    <ls_appr>-ertim_local = sy-timlo.
  ENDLOOP.

  MODIFY zgtmmt1070 FROM TABLE lt_appr.
  COMMIT WORK.

  IF lv_check EQ gc_e.
    MESSAGE s000 WITH TEXT-x01. "전송 실패
  ELSE.
    MESSAGE s000 WITH TEXT-x02. "전송 완료
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_CHECK_BUDGET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_check_budget .
*4. 예산점검 버튼  -> 점검 기준 확인 후 추가 업데이트 예정
*
*
*	점검 결과 메시지 POP UP 창으로 표기


  DATA:
    lv_check  TYPE c LENGTH 1,
    lt_row_id TYPE lvc_t_roid.

  FIELD-SYMBOLS:
    <ls_row_id> TYPE lvc_s_roid,
    <ls_opt2>   TYPE ty_opt2.

  CALL METHOD go_grid_300->check_changed_data
    IMPORTING
      e_valid = lv_check.

  CHECK lv_check EQ abap_true.

  CALL METHOD go_grid_300->get_selected_rows
    IMPORTING
      et_row_no = lt_row_id.

  DELETE lt_row_id WHERE row_id LE 0.
*	5-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  IF lt_row_id[] IS INITIAL.
    MESSAGE e163.
  ENDIF.

  DATA:
    l_msg   TYPE c LENGTH 120,
    ls_eban TYPE eban,
    ls_ebkn TYPE ebkn,
    lt_eban TYPE STANDARD TABLE OF eban,
    lt_ebkn TYPE STANDARD TABLE OF ebkn.

  CLEAR:
    ls_eban,
    ls_ebkn.

  ls_eban-banfn += 1.
  ls_eban-bstyp = 'NB'.


  SELECT SINGLE
    kokrs
    FROM tka02
    WHERE bukrs EQ @p_bukrs
    INTO @DATA(lv_kokrs).

  "- 동일한 계정지정범주 끼리만 예산점검 가능하게 함
  DATA lv_knttp TYPE eban-knttp VALUE '$'.
  LOOP AT lt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt2 ASSIGNING <ls_opt2> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.
    IF lv_knttp EQ '$'.
      lv_knttp = <ls_opt2>-knttp.
    ENDIF.

    IF lv_knttp NE <ls_opt2>-knttp.
*동일한 계정지정 범주에 대해 예산 점검 가능합니다
      MESSAGE e000 WITH TEXT-e15.
    ENDIF.
  ENDLOOP.


  LOOP AT lt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt2 ASSIGNING <ls_opt2> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.
*
*구매 요청 번호                 BANFN Default = "1" IM_T-EBAN
*품목                 BNFPO 품목 라인별 10단위 증가 채번
*문서유형                 BSTYP Default = "NB"
*계정 지정범주                  KNTTP ALV-KNTTP
*품목범주                 PSTYP ALV-PSTYP
*자재번호                 MATNR ALV-MATNR
*자재그룹                 MATKL ALV-MATKL
*플랜트                  WERKS ALV-WERKS
*저장위치                 LGORT ALV-LGORT
*요청 수량                  MENGE ALV-MENGE
*요청 단위                  MEINS ALV-MEINS
*납품 요청일                 LFDAT ALV-LFDAT
*구매조직                 EKORG ALV-EKORG
*구매그룹                 EKGRP ALV-EKGRP
*요청자                  AFNAM ALV-AFNAM
*희망 공급업체                  LIFNR ALV-LIFNR
*고정 공급업체                  FLIEF ALV-FLIEF
*예상 가격                  PREIS ALV-PREIS
*가격 통화                  WAERS ALV-WAERS
*가격 단위                  PEINH ALV-PEINH
*요청일                  BADAT SY-DATUM
*부채관련품목                 XOBLR Default = "X"


    ls_eban-bnfpo += 10.
    ls_eban-knttp = <ls_opt2>-knttp.
*    LS_EBAN-PSTYP = <LS_OPT2>-PSTYP.
    ls_eban-matnr = <ls_opt2>-matnr.
    ls_eban-matkl = <ls_opt2>-matkl.
    ls_eban-werks = <ls_opt2>-werks.
    ls_eban-lgort = <ls_opt2>-lgort.
    ls_eban-menge = <ls_opt2>-menge.
    ls_eban-meins = <ls_opt2>-meins.
    ls_eban-lfdat = <ls_opt2>-lfdat.
    ls_eban-ekorg = <ls_opt2>-ekorg.
    ls_eban-ekgrp = <ls_opt2>-ekgrp.
    ls_eban-afnam = <ls_opt2>-afnam.
    ls_eban-lifnr = <ls_opt2>-lifnr.
    ls_eban-flief = <ls_opt2>-flief.
    ls_eban-preis = <ls_opt2>-preis.
    ls_eban-waers = <ls_opt2>-waers.
    ls_eban-peinh = <ls_opt2>-peinh.
    ls_eban-badat = sy-datum.
    ls_eban-xoblr = abap_true.
    APPEND ls_eban TO lt_eban.

*구매 요청 번호                 BANFN Default = "1"
*품목                 BNFPO 품목 라인별 10단위 증가 채번
*영업오더                 VBELN ALV-VBELN
*영업오더품목                 VBELP ALV-VBELP
*코스트센터                  KOSTL ALV-KOSTL
*G/L 계정                 SAKTO ALV-SAKTO
*자산번호                 ANLN1 ALV-ANLN1
*오더번호                 AUFNR ALV-AUFNR
*WBS 코드                 PS_PSP_PNR  ALV-PS_PSP_PNR
*하역지점                 ABLAD ALV-ABLAD
*수령인                  WEMPF ALV-WEMPF
*관리회계영역                 KOKRS ALV-KOKRS

    ls_ebkn-banfn = ls_eban-banfn.
    ls_ebkn-bnfpo = ls_eban-bnfpo.
*    LS_EBKN-VBELN = <LS_OPT2>-VBELN.
*    LS_EBKN-VBELP = <LS_OPT2>-VBELP.
    ls_ebkn-kostl = <ls_opt2>-kostl.
    ls_ebkn-sakto = <ls_opt2>-sakto.
    ls_ebkn-anln1 = <ls_opt2>-anln1.
    ls_ebkn-aufnr = <ls_opt2>-aufnr.
    ls_ebkn-ps_psp_pnr = <ls_opt2>-ps_psp_pnr.
    ls_ebkn-ablad = <ls_opt2>-ablad.
    ls_ebkn-wempf = <ls_opt2>-wempf.
    ls_ebkn-kokrs = lv_kokrs.
    APPEND ls_ebkn TO lt_ebkn.

  ENDLOOP.

*	 	4-1) 예산점검 버튼 변수 정의
*   SY-UCOMM = MECHEKMOC
*   4-2) 예산점검을 위한 PERFORM 문 호출
*     4-2-1) 호출전 MEMORY ID값 사전 clear
*     4-2-1) 아래 PERFOMR문 호출
*     PERFORM EXIT_FI_CHECK_BUDGET_RQ IN PROGRAM ZFII0010 IF FOUND
*                                            TABLES IM_T_EBAN
*                                                   IM_T_EBKN.

  sy-ucomm = 'MECHECKDOC'.
  PERFORM exit_fi_check_budget_rq IN PROGRAM zfii0010 IF FOUND
                                       TABLES lt_eban
                                              lt_ebkn.
*4-3) 점검 결과(L_MSG) 값 POP-UP 창으로 표기
*   4-3-1) L-MSG 의 MEMORY ID값을 참조하여 보여줌
* 변수                  Type  Length
* L_MSG                 CHAR  120
*
*   : L_MSG <> "" 이면 L_MSG 값
*   : L_MSG = "" 이면 "구매요청 생성 가능합니다."
  IMPORT l_msg_ab TO l_msg FROM MEMORY ID 'BUDGET_CHK'.
  FREE MEMORY ID 'BUDGET_CHK'.

  IF l_msg IS INITIAL.

*    4-3) Perfomr문 실행 후 아래 Function 추가 호출 점검
*	CALL FUNCTION 'ME_STATISTICS_EBAN_RKO'
*	  EXPORTING
*	    I_REFRESH        = ' '
*	    I_BEST           = ' '
*	    I_AVC_PRUEFEN    = 'X'
*	    I_FIRST_CALL     = ' '
*	    I_COMPONENT      = ' '
*	    I_INITIALIZE     = ' '
*	    I_CO_SET_DATE    = 'X'
*	    I_TRANS_DATE     = '00000000'
*	    I_HELD_PO        = ' '
*	    I_FLG_CHECK_ONLY = 'X'
*	    I_NO_RWIN        = ' '
*	  TABLES
*	    T_EBAN           =IM_T-EBAN
*	    T_EBKN           = IM_T-EBKN.
*
*	-> function 에서 점검된 오류 메시지인 경우도 Popup 메시지로 표기하여 보여줌
    CALL FUNCTION 'MESSAGES_INITIALIZE'.
    CALL FUNCTION 'ME_STATISTICS_EBAN_RKO'
      EXPORTING
        i_refresh        = ' '
        i_best           = ' '
        i_avc_pruefen    = 'X'
        i_first_call     = ' '
        i_component      = ' '
        i_initialize     = ' '
        i_co_set_date    = 'X'
        i_trans_date     = '00000000'
        i_held_po        = ' '
        i_flg_check_only = 'X'
        i_no_rwin        = ' '
      TABLES
        t_eban           = lt_eban
        t_ebkn           = lt_ebkn.
    CALL FUNCTION 'MESSAGES_STOP'
      EXCEPTIONS
        a_message         = 1
        e_message         = 2
        w_message         = 3
        i_message         = 4
        s_message         = 5
        deactivated_by_md = 6
        OTHERS            = 7.

    DATA lt_mesg TYPE tsmesg.
    CALL FUNCTION 'MESSAGES_GIVE'
      TABLES
        t_mesg = lt_mesg.

    LOOP AT  lt_mesg ASSIGNING FIELD-SYMBOL(<ls_mesg>).

      CHECK <ls_mesg>-msgty EQ gc_e
            OR <ls_mesg>-msgty EQ gc_a
            OR ( <ls_mesg>-msgty EQ gc_w AND lv_knttp EQ gc_f ). "- F 인경우만 W 유형 메세지 추가

      MESSAGE ID <ls_mesg>-arbgb TYPE gc_s"<LS_MESG>-MSGTY
          NUMBER <ls_mesg>-txtnr WITH <ls_mesg>-msgv1 <ls_mesg>-msgv2 <ls_mesg>-msgv3 <ls_mesg>-msgv4
                INTO l_msg.
*      L_MSG = <LS_MESG>-TEXT.
      EXIT.
    ENDLOOP.
  ENDIF.

*4-4) 버튼 선택 여부는 별도 내부 상태값으로 저장하고 구매요청 생성 버튼 선택시 예산점검버튼 실행 여부를 Check할때 사용
  LOOP AT lt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_opt2 ASSIGNING <ls_opt2> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.
    "2. 변경 : KNTTP=F 인 경우 초과 메시지는 보여주고 구매요청 생성 가능하도록 변경
    IF l_msg IS INITIAL OR <ls_opt2>-knttp EQ gc_f.
      <ls_opt2>-bgchk = abap_true.
    ENDIF.
  ENDLOOP.

  IF l_msg IS INITIAL.
    l_msg = TEXT-m03. "구매요청 생성 가능합니다.
  ENDIF.

  MESSAGE i000 WITH l_msg.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_GW_XML
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ROW_ID
*&      <-- LV_REQXML
*&---------------------------------------------------------------------*
FORM f_set_gw_xml  USING  pt_row_id TYPE lvc_t_roid
                                                pv_pernr
                   CHANGING cv_reqxml.

*  FIELD-SYMBOLS:
*    <LS_ROW_ID> TYPE LVC_S_ROID,
*    <LS_OPT2>   TYPE TY_OPT2.


*ROOT 구조
*<ROOT>
*	<DOCINFO>
*	<MEMBERS>
*<ROOT>

  cv_reqxml = |<Root>|.
  cv_reqxml = |{ cv_reqxml }<DOCINFO>|.

*	<DOCINFO>
*	   <DOCTITLE>구매요청 품의</DOCTITLE>
*	   <TITLE>구매요청문서 승인 요청</TITLE>
*	   <CONTENTSTYPE>HTML</CONTENTSTYPE>
*	   <CONTENTS></CONTENTS>
*	   <APPTYPE>OPEN</APPTYPE>
*	</DOCINFO>

  cv_reqxml = |{ cv_reqxml }<DOCTITLE>구매요청 품의</DOCTITLE>|.
  cv_reqxml = |{ cv_reqxml }<TITLE>구매요청문서 승인 요청</TITLE>|.
  cv_reqxml = |{ cv_reqxml }<CONTENTSTYPE>HTML</CONTENTSTYPE>|.
  cv_reqxml = |{ cv_reqxml }<CONTENTS></CONTENTS>|.
  cv_reqxml = |{ cv_reqxml }<APPTYPE>OPEN</APPTYPE>|.
  cv_reqxml = |{ cv_reqxml }</DOCINFO>|.

*
*5-7-1-3) MEMBERS
*필드               Value   비고
*ID               WELS 회사코드+I_PERNR   "WELS 회사코드조회
*Table : ZGTPPT1010
*SELECT 조건: FLD_02
*WHERE 조건:
*MODULE_KIND ='MM'
*CODEGRP = '0021'
*FLD_01 = BUKRS (조건 입력값)"
*APPCODE                C101    Default 값
*APPTYPE                AT_C101   Default 값
*
*[예시]
*<MEMBERS>
*   <ID>A006040016</ID>
*   <APPCODE>C101</APPCODE>
*   <APPTYPE>AT_C101</APPTYPE>
*<MEMBERS>

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
*& Form F_CHECK_CLOSED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW
*&---------------------------------------------------------------------*
FORM f_check_closed  USING  pt_row TYPE lvc_t_roid.

*6-3) 요청 종결 대상 구매요청 품목이 구매오더로값이 존재하는 경우 하단 에러메세지 "구매오더 생성 이전 문서만 종결처리 가능합니다."
  LOOP AT pt_row ASSIGNING FIELD-SYMBOL(<ls_row>).
    READ TABLE gt_list ASSIGNING FIELD-SYMBOL(<ls_list>) INDEX <ls_row>-row_id.
    CHECK sy-subrc EQ 0.
    CHECK <ls_list>-ebeln IS NOT INITIAL.
    MESSAGE e000 WITH TEXT-e10.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_P_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_at_screen_on_p_werks .

  CHECK sy-ucomm EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR gv_error.

  "필수 값 점검
  CHECK p_crea EQ abap_true.
  IF p_werks IS INITIAL.
    gv_error = abap_true.
    MESSAGE e278(00) WITH TEXT-f02.
  ENDIF.

  CHECK gv_error EQ space.

  "유효성 점검
  SELECT SINGLE
    werks
    FROM t001w
    WHERE werks EQ @p_werks
    INTO @DATA(lv_chk).
  CHECK sy-subrc NE 0.
  gv_error = abap_true.
  MESSAGE e000 WITH TEXT-e01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_P_EKORG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_at_screen_on_p_ekorg .

  CHECK sy-ucomm EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR gv_error.

  "필수 값 점검
  CHECK p_crea EQ abap_true.
  IF p_ekorg IS INITIAL.
    gv_error = abap_true.
    MESSAGE e278(00) WITH TEXT-f03.
  ENDIF.

  CHECK gv_error EQ space.

  "유효성 점검
  SELECT SINGLE
    ekorg
    FROM t024e
    WHERE ekorg EQ @p_ekorg
    INTO @DATA(lv_chk).
  CHECK sy-subrc NE 0.
  gv_error = abap_true.
  MESSAGE e000 WITH TEXT-e01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_AT_SCREEN_ON_P_EKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_at_screen_on_p_ekgrp .

  CHECK sy-ucomm EQ 'ONLI'. "실행 인 경우 만 점검
  CLEAR gv_error.

  "필수 값 점검
  CHECK p_crea EQ abap_true.
  IF  p_ekgrp IS INITIAL.
    gv_error = abap_true.
    MESSAGE e278(00) WITH TEXT-f04.
  ENDIF.

  CHECK gv_error EQ space.

  "유효성 점검
  SELECT SINGLE
    ekgrp
    FROM t024
    WHERE ekgrp EQ @p_ekgrp
    INTO @DATA(lv_chk).
  CHECK sy-subrc NE 0.
  gv_error = abap_true.
  MESSAGE e000 WITH TEXT-e01. "참조테이블에 없는 값을 입력할 경우 오류메시지 처리 "입력된 정보를 확인하세요.")


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SET_ORG_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_set_org_text .

  CLEAR:
    gv_name1,
    gv_ekotx,
    gv_eknam.

  SELECT SINGLE
    name1
    FROM t001w
    WHERE werks EQ @p_werks
    INTO @gv_name1.

  SELECT SINGLE
    ekotx
    FROM t024e
    WHERE ekorg EQ @p_ekorg
    INTO @gv_ekotx.

  SELECT SINGLE
    eknam
    FROM t024
    WHERE ekgrp EQ @p_ekgrp
    INTO @gv_eknam.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_APPROVAL_REQ_DISP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_approval_req_disp .
*8. 승인 요청 버튼
*	8-1) 라인은 다중선택 가능 (전체선택 포함)
*	8-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."

  DATA:
    lv_check  TYPE c LENGTH 1,
    lt_row_id TYPE lvc_t_roid.

  FIELD-SYMBOLS:
    <ls_row_id> TYPE lvc_s_roid,
    <ls_list>   TYPE ty_list.

  CALL METHOD go_grid_100->check_changed_data
    IMPORTING
      e_valid = lv_check.

  CHECK lv_check EQ abap_true.

  CALL METHOD go_grid_100->get_selected_rows
    IMPORTING
      et_row_no = lt_row_id.

  DELETE lt_row_id WHERE row_id LE 0.
*	8-2) 선택한 라인이 없는 경우 하단 에러 메시지 "선택한 데이터가 없습니다."
  IF lt_row_id[] IS INITIAL.
    MESSAGE e163.
  ENDIF.

*	8-3) 결재 지시자 <> ""이거나 <>"2" or "S "가 아닌경우 승인 요청 실행 가능
*	8-4) 선택한 항목의 결재 지시자 = "" 이면 오류 메시지 "승인 요청 대상이 아닙니다."
*	8-5) 선택한 라인에 ZGTMMT1070 승인 요청된 이력이 존재 하고 ERDAT <>""  인 데이터가 있으면 하단 에러메세지 "승인요청 된 구매요청이 존재합니다."
*	     요청 이력 점검 기준 : 동일한 BANFN,BNFPO
*	8-6) ZGTMMT1070 승인 요청 이력 및 결재 상태 수신 값 기준으로재 승인 요청 재실행 가능
*   8-6-1) ZGTMMT1070 BANFO, BNFPO 존재하지 않는 경우
*   8-6-2) ZGTMMT1070 이력이 존재하고 APPSTATUS= "" 이거나 "R" 이면 승인요청 재 선택 가능
*   8-6-3) WELS 승인 요청 이력확인 : ZGTMMT1070 BAFNO, BNFPO,APPID 존재
*           결재 수신 상태값 확인 : ZGTMMT1051-STATUS = "T" or "R" or "W" 이면  재 승인요청 가능
  SELECT
    z1~banfn,
    z1~bnfpo
    FROM zgtmmt1070 AS z1
##ITAB_KEY_IN_SELECT
    WHERE EXISTS (
      SELECT zz~banfn
        FROM @gt_list AS zz
        WHERE zz~banfn EQ z1~banfn
           AND zz~bnfpo EQ z1~bnfpo
           AND zz~banfn IS NOT INITIAL
    )
    AND z1~erdat IS NOT INITIAL
    AND z1~appstatus NE @space
    AND z1~appstatus NE @gc_r
    ORDER BY z1~banfn, z1~bnfpo
    INTO TABLE @DATA(lt_chk1).

  SELECT
    z1~banfn,
    z1~bnfpo
    FROM zgtmmt1070 AS z1
##ITAB_KEY_IN_SELECT
   WHERE EXISTS (
     SELECT zz~banfn
       FROM @gt_list AS zz
       WHERE zz~banfn EQ z1~banfn
          AND zz~bnfpo EQ z1~bnfpo
          AND zz~banfn IS NOT INITIAL
   )
    AND z1~appid IS NOT INITIAL
    AND EXISTS (
     SELECT ap~appid
       FROM zgtmmt1051 AS ap
       WHERE ap~appid EQ z1~appid
       AND ap~status IN ( @gc_t, @gc_r, @gc_w )
    )
   ORDER BY z1~banfn, z1~bnfpo
   INTO TABLE @DATA(lt_chk2).

  LOOP AT lt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_list ASSIGNING <ls_list> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.
    CASE <ls_list>-frgkz.
      WHEN space OR gc_2 OR gc_s.
        MESSAGE e000 WITH TEXT-e13. "승인 요청 대상이 아닙니다.
    ENDCASE.

*8-6) 선택한 라인의 생성자와(EBAN-ERNAM) 승인 요청 실행자 아이디가(SY-UNAME) 다른경우 하단 에러메세지 "본인이 생성한 구매요청문서만 승인 요청 가능합니다."
    IF <ls_list>-ernam NE sy-uname.
*      MESSAGE E000 WITH TEXT-E14.
    ENDIF.

    READ TABLE lt_chk1 WITH KEY banfn = <ls_list>-banfn bnfpo = <ls_list>-bnfpo BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      READ TABLE lt_chk2 WITH KEY banfn = <ls_list>-banfn bnfpo = <ls_list>-bnfpo BINARY SEARCH TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        MESSAGE e000 WITH TEXT-e09. "승인요청 된 구매요청이 존재합니다.
      ENDIF.
    ENDIF.

  ENDLOOP.


  "요청 금액 확인
  DATA:
    lv_dmbtr_tot TYPE dmbtr,
    lv_dmbtr     TYPE dmbtr.

  LOOP AT lt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_list ASSIGNING <ls_list> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.

    CLEAR lv_dmbtr.
    CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
      EXPORTING
        date             = sy-datlo
        foreign_amount   = <ls_list>-zamt
        foreign_currency = <ls_list>-waers
        local_currency   = gv_waers
      IMPORTING
        local_amount     = lv_dmbtr
      EXCEPTIONS
        no_rate_found    = 1
        overflow         = 2
        no_factors_found = 3
        no_spread_found  = 4
        derived_2_times  = 5
        OTHERS           = 6.

    lv_dmbtr_tot += lv_dmbtr.
  ENDLOOP.

*8-7-1) 선택 라인의 요청금액(ZMAT) 총합이 1,000 만원 이상 이면
*	 : POP UP 확인 후 결재요청 그룹웨어(WELS) 연동
  IF lv_dmbtr_tot GE 100000.
    PERFORM f_send_gw_list USING lt_row_id.

  ELSE.
*8-7-2) 선택 라인의 요청금액(ZMAT) 합계가 1,000 만원 미만 이면
*	: POP UP 확인 후 승인 요청 알림 전송
    PERFORM f_send_email_list USING lt_row_id.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SEND_GW_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_ID
*&---------------------------------------------------------------------*
FORM f_send_gw_list  USING  pt_row_id TYPE lvc_t_roid.

*그룹웨어 결재로 이동합니다. 진행 하시겠습니까?
*
  DATA lv_ans   TYPE c LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar      = TEXT-tt1
      text_question = TEXT-q04
    IMPORTING
      answer        = lv_ans.
  CHECK lv_ans EQ gc_1.


*	5-7-1-1) 그룹웨어 결재 전송 FUNCTION 호출
*	FUNCTION:  ZGTMM_APP_TO_WELS
  DATA:
    lv_pernr    TYPE char10,
    lv_tcode    TYPE char20,
    lv_reqxml   TYPE string,
    lv_mtype    TYPE bapi_mtype,
    lv_message  TYPE bapi_msg,
    lv_appid    TYPE char32,
    lv_legacyid TYPE char32,
    lv_url      TYPE string.
*
*필드         Value         비고
*I_BUKRS          조회조건 입력값
*I_PERNR          SY-NAME         승인 요청자 사번
*I_T-CODE         SY-T-CODE
*I_REQXML

  lv_pernr = sy-uname.
  lv_tcode = gc_zgtmmr2010.

  "XML 생성
  PERFORM f_set_gw_xml USING pt_row_id lv_pernr CHANGING lv_reqxml.

  CALL FUNCTION 'ZGTMM_APP_TO_WELS'
    EXPORTING
      i_bukrs  = p_bukrs
      i_pernr  = lv_pernr
      i_tcode  = lv_tcode
      i_reqxml = lv_reqxml
    IMPORTING
      mtype    = lv_mtype
      message  = lv_message
      legacyid = lv_legacyid
      appid    = lv_appid
      url      = lv_url.

  IF lv_mtype EQ gc_e.
    MESSAGE e000 WITH lv_message.
  ENDIF.

*5-7-1-3) 결재 창 호출 후 승인요청 이력 테이블 1차 저장
  DATA lt_appr TYPE STANDARD TABLE OF zgtmmt1070.

  FIELD-SYMBOLS:
    <ls_row_id> TYPE lvc_s_roid,
    <ls_list>   TYPE ty_list.

  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_list ASSIGNING <ls_list> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.

    lt_appr = VALUE #( BASE lt_appr ( banfn = <ls_list>-banfn
                                                              bnfpo = <ls_list>-bnfpo
                                                              appid = lv_appid
                                                              apptype = gc_b
                                                              appuser = gc_wels
                                                              erdat = sy-datum
                                                              erdat_local = sy-datlo
                                                              ertim = sy-uzeit
                                                              ertim_local = sy-timlo
                                                              ) ).
  ENDLOOP.

  MODIFY zgtmmt1070 FROM TABLE lt_appr.
  COMMIT WORK.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SEND_EMAIL_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_ID
*&---------------------------------------------------------------------*
FORM f_send_email_list  USING  pt_row_id TYPE lvc_t_roid.

*  선택한 구매요청에 대해 승인 요청 하시겠습니까?
  DATA lv_ans   TYPE c LENGTH 1.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar      = TEXT-tt1
      text_question = TEXT-q05
    IMPORTING
      answer        = lv_ans.
  CHECK lv_ans EQ gc_1.

*5-5-2-1) 메일 전송 수신 담당자 조회를 위한 인사 정보 추출
*A) 사용자 ID 의 부서정보 조회
*
*	Table: ZZPA0001
*	SELECT  조건 : KOSTL
*	WHERE 조건 :
*	PERNR = SY-NAME
*	BUKRS = 조회 조건 입력 값
*	ENDDA = "9999.12.31"
*
  DATA lv_syuname TYPE sy-uname.
  lv_syuname = sy-uname.
  REPLACE ALL OCCURRENCES OF REGEX '[^[:digit:]]' IN lv_syuname WITH space.

  SELECT SINGLE
    kostl
    FROM zzpa0001
    WHERE pernr EQ @lv_syuname
    AND bukrs EQ @p_bukrs
    AND endda EQ '99991231'
    INTO @DATA(lv_kostl).

*B) 부서의 승인 담담자 조회
*	Table: ZZPA0001
*	SELECT 조건 : PERNR
*	WHERE 조건:
*	KOSTL = A)의 KOSTL
*	ZZ_JOBTL = "7400"
*	ENDDA = "9999.12.31"

  SELECT SINGLE
    pernr
    FROM zzpa0001
    WHERE bukrs EQ @p_bukrs
    AND kostl EQ @lv_kostl
    AND zz_jobtl EQ '7400'
    AND endda EQ '99991231'
    INTO @DATA(lv_pernr).

  "7400 없는 경우 -> 7410 -> 7500 순으로 조회

  IF lv_pernr IS INITIAL.
    SELECT SINGLE
      pernr
      FROM zzpa0001
      WHERE bukrs EQ @p_bukrs
      AND kostl EQ @lv_kostl
      AND zz_jobtl EQ '7410'
      AND endda EQ '99991231'
      INTO @lv_pernr.

    IF lv_pernr IS INITIAL.
      SELECT SINGLE
       pernr
       FROM zzpa0001
       WHERE bukrs EQ @p_bukrs
       AND kostl EQ @lv_kostl
       AND zz_jobtl EQ '7500'
       AND endda EQ '99991231'
       INTO @lv_pernr.
    ENDIF.
  ENDIF.

  "셋 다 없는 경우 ZHRTI702에서 부서장 가져오기
  IF lv_pernr IS INITIAL.
    SELECT SINGLE dept_manager
      FROM zhrti702 AS hr
      JOIN zzpa0001 AS pa ON hr~dept_code EQ pa~orgeh
      WHERE pa~bukrs EQ @p_bukrs
        AND pa~kostl EQ @lv_kostl
        AND pa~endda EQ '99991231'
      INTO @DATA(lv_manager).

    lv_pernr = CONV pernr( |{ lv_manager ALPHA = IN }| ).
  ENDIF.

*5-5-2-2) 부서 승인 담당자 이메일 정보 추출
*
*	Table : ZPA0105
*	SELECT 조건 : SYSID
*	WEHRE 조건 :
*	PERNR = B)의 PERNR
*	SUBTY = "0007"
*	ENDDA = "9999.12.31"
  SELECT SINGLE
    usrid
    FROM zpa0105
    WHERE pernr EQ @lv_pernr
    AND subty EQ '0007'
    AND endda EQ '99991231'
    INTO @DATA(lv_sysid).
  IF lv_pernr IS INITIAL OR lv_sysid IS INITIAL.
    MESSAGE s000 DISPLAY LIKE gc_e WITH TEXT-e08. "부서의 승인 담당자 정보를 찾을 수 없습니다.
    EXIT.
  ENDIF.

  DATA:
*    LV_UNAME     TYPE SY-UNAME,
    lv_email     TYPE ad_smtpadr,
    lv_head_text TYPE so_obj_des,
    lt_msg       TYPE bcsy_text,
    lv_return    TYPE c LENGTH 1,
    lv_message   TYPE c LENGTH 100.

*  I_UNAME            5-5-2-1) B)의 ZPERSNO
*I_E-MAIL           5-5-2-2) SYSID
*I_HEAD_TEXT            [승인요청] 구매요청문서에 대한 승인요청드립니다.
*  LV_UNAME = LV_PERNR.
  lv_email = lv_sysid.
  lv_head_text = TEXT-z01.

*	5-5-2-3) 이메일 본문 내용 구성
*
*	첫번째 라인) 구매요청 " BANFN "외 &건이 승인 요청 되었습니다. (문서번호 기준으로 건수 check)
*	두번째 라인) SAP 메뉴 ZGTMMR2011 에서 대상 확인 승인 부탁드립니다.
*
*	: ALV에서 생성된 구매요청번호,생성자이름,요청일자 정보를 리스트 형태로 구성

  FIELD-SYMBOLS:
    <ls_row_id> TYPE lvc_s_roid,
    <ls_list>   TYPE ty_list.

  DATA:
    lv_banfn  TYPE eban-banfn,
    lv_cnt    TYPE int4,
    lv_cnt_c  TYPE c LENGTH 10,
    lv_date_c TYPE c LENGTH 10.

  DATA:
    lt_appr TYPE STANDARD TABLE OF zgtmmt1070,
    lv_line TYPE so_text255,
    lt_body TYPE bcsy_text.

  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_list ASSIGNING <ls_list> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.

    IF lv_banfn IS INITIAL.
      lv_banfn = <ls_list>-banfn.
    ELSE.
      lv_cnt += 1.
    ENDIF.
  ENDLOOP.

  WRITE lv_cnt TO lv_cnt_c LEFT-JUSTIFIED NO-GAP.

  lv_line = |<html><body style="font-size:10">|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
  lv_line = |<p>{ TEXT-em1 }</p>|.
*  LV_LINE = |<p>구매요청 "{ LV_BANFN ALPHA = OUT }"외 { LV_CNT_C }건이 승인 요청 되었습니다.</p>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
  lv_line = |<p>SAP 메뉴 <strong>ZGTMMR2011</strong> 에서 확인 부탁드립니다. </p>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
  lv_line = |<table border=1 STYLE="border-collapse: collapse;border-color: #000000;font-size:10" >|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).

  lv_line = |<tr align="center" style="background-color: #B3B1B1" ><td width="150px"><strong>구매요청번호</strong></td>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
  lv_line = |<td width="100px" ><strong>품목번호</strong></td>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
  lv_line = |<td width="150px" ><strong>요청자</strong></td>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
  lv_line = |<td width="150px" ><strong>요청일자</strong></td></tr>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).

  LOOP AT pt_row_id ASSIGNING <ls_row_id>.
    READ TABLE gt_list ASSIGNING <ls_list> INDEX <ls_row_id>-row_id.
    CHECK sy-subrc EQ 0.

    lv_line = |<tr><td align="center" >{ <ls_list>-banfn ALPHA = OUT }</td>|.
    lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
    lv_line = |<td align="center" >{ <ls_list>-bnfpo ALPHA = OUT }</td>|.
    lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
    lv_line = |<td align="center" >{ <ls_list>-afnam }</td>|.
    lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).
    lv_line = |<td align="center" >{ <ls_list>-lfdat+0(4) }.{ <ls_list>-lfdat+4(2) }.{ <ls_list>-lfdat+6(2) }</td></tr>|.
    lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).

    lt_appr = VALUE #( BASE lt_appr ( banfn = <ls_list>-banfn
                                                              bnfpo = <ls_list>-bnfpo
                                                              apptype = gc_a
                                                              appuser = lv_pernr ) ).

  ENDLOOP.

  lv_line = |</table></body></html>|.
  lt_body = VALUE #( BASE lt_body ( line = lv_line ) ).


  DATA:
    lv_check       TYPE c LENGTH 1,
    lo_receiver    TYPE REF TO if_recipient_bcs,
    lo_email       TYPE REF TO cl_bcs,
    lo_email_body  TYPE REF TO cl_document_bcs,
    lx_exception   TYPE REF TO cx_bcs,
    lv_send_result TYPE c.

  TRY.
      lo_email = cl_bcs=>create_persistent( ).

      lo_email_body = cl_document_bcs=>create_document(
                      i_type    = 'HTM'
                      i_text    = lt_body
                      i_subject = lv_head_text ).

      lo_email->set_document( lo_email_body ).

      lo_receiver = cl_cam_address_bcs=>create_internet_address( lv_email ).

      lo_email->add_recipient( i_recipient = lo_receiver
                               i_express = 'X' ).

      lo_email->set_send_immediately( 'X' ).

      lo_email->send( EXPORTING i_with_error_screen = 'X'
                      RECEIVING result = lv_send_result ).
    CATCH cx_bcs INTO lx_exception.
      lv_check = gc_e.
  ENDTRY.

*5-5-3) 메일 발송 후 승인 요청 이력 테이블 업데이트
*
*필드                   ZGTMMT1070
*BANFN                    ALV-BANFN
*BANFPO                   ALV-BANFPO
*APPTYPE                    A
*APPUSER                    ZPERSNO
*MAILSEND                   성공시 Y, 실패시 N
*ERDAT                    SY-DATUM
*ERDAT_LOCAL                    SY-DATLO
*ERTIM                    SY-UZEIT
*ERTIM_LOCAL                    SY-TIMLO
*AEDAT
*AEDAT_LOCAL
*AEZET
*AEZET_LOCAL

  LOOP AT lt_appr ASSIGNING FIELD-SYMBOL(<ls_appr>).
    IF lv_check EQ gc_e.
      <ls_appr>-mailsend = gc_n.
    ELSE.
      <ls_appr>-mailsend = gc_y.
    ENDIF.
    <ls_appr>-erdat = sy-datum.
    <ls_appr>-erdat_local = sy-datlo.
    <ls_appr>-ertim = sy-uzeit.
    <ls_appr>-ertim_local = sy-timlo.
  ENDLOOP.

  MODIFY zgtmmt1070 FROM TABLE lt_appr.
  COMMIT WORK.

  IF lv_check EQ gc_e.
    MESSAGE s000 WITH TEXT-x01. "전송 실패
  ELSE.
    MESSAGE s000 WITH TEXT-x02. "전송 완료
  ENDIF.

ENDFORM.
