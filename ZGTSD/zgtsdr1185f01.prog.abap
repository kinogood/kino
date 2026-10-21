*&---------------------------------------------------------------------*
*& Include          ZGTSDR1185F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
FORM initialization .

  DATA: l_in   LIKE sy-datum.

**
* ALV
  g_variant-report   = g_inclname = g_repid = sy-repid.
  g_variant-username = gx_variant-username = sy-uname.

  g_dynnr = '100'.

  REFRESH s_wadat. CLEAR s_wadat.
  s_wadat-sign = 'I'.
  s_wadat-option = 'EQ'.
  s_wadat-low+0(6) = sy-datum.
  s_wadat-low+6(2) = '01'.

* 현재월 마지막일자
  l_in = sy-datum.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = l_in
    IMPORTING
      last_day_of_month = l_in
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  s_wadat-high = l_in.
  APPEND s_wadat. CLEAR s_wadat.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_process
*&---------------------------------------------------------------------*
FORM start_process .

**
  CLEAR: gv_error.

  PERFORM valid_check.

  PERFORM select_kunnr.

  PERFORM data_selection.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_authorization
*&---------------------------------------------------------------------*
FORM check_authorization  USING    pv_step
                                   pv_value
                          CHANGING pv_subrc.

  DATA: lv_bukrs   TYPE bukrs,
        lv_type(1).

**
  lv_type = pv_step.

  CASE lv_type.
    WHEN '6'.    " 회사코드
      lv_bukrs = pv_value.
      CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
        EXPORTING
          i_bukrs = lv_bukrs
          i_type  = lv_type
        IMPORTING
          e_subrc = pv_subrc.

    WHEN OTHERS.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form valid_check
*&---------------------------------------------------------------------*
FORM valid_check .

  DATA: lv_subrc TYPE sy-subrc,
        lv_day   TYPE i.

**
* 권한 Check
  CLEAR: lv_subrc.
  PERFORM check_authorization  USING    '6'    " 회사코드
                                        p_bukrs
                               CHANGING lv_subrc.
  IF lv_subrc NE 0.
    MESSAGE s301 WITH '회사코드' p_bukrs.
    gv_error = 'X'.
  ENDIF.

* GI Date Check.
  CHECK: gv_error IS INITIAL.

  CLEAR: lv_day.
  READ TABLE s_wadat INDEX 1.
  IF sy-subrc EQ 0 AND s_wadat-high IS NOT INITIAL.
    lv_day = s_wadat-high - s_wadat-low.
    IF lv_day > 31.
*     GI 일자는 한달이내로 입력하십시요.
      MESSAGE s000 WITH TEXT-e01  DISPLAY LIKE 'E'.
      gv_error = 'X'.
    ENDIF.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form select_kunnr
*&---------------------------------------------------------------------*
FORM select_kunnr .

  DATA: lr_zzgur_agy  LIKE RANGE OF bp3100-zzgur_agy.

**
  CHECK: gv_error IS INITIAL.

  _clear: gt_kunnr, gt_req,
          lr_zzgur_agy.

  IF     s_dambg = '5'.
    lr_zzgur_agy = VALUE #( ( sign = 'I'  option = 'CP'  low  = '*신*' ) ).
  ELSEIF s_dambg = 'E'.
    lr_zzgur_agy = VALUE #( ( sign = 'I'  option = 'CP'  low  = '*술*' ) ).
  ELSE.
    lr_zzgur_agy = VALUE #( ( sign = 'I'  option = 'CP'  low  = '*신*' )
                            ( sign = 'I'  option = 'CP'  low  = '*술*' ) ).
  ENDIF.

* 신용보증담보 가입 거래처 추출
  SELECT b~customer AS kunnr, a~criter AS kkber, a~counter, a~dateto AS enddt,
         '6000' AS bukrs,
         CASE
           WHEN zzgur_agy LIKE '%신%'  THEN '5'
           WHEN zzgur_agy LIKE '%술%'  THEN 'E'
           ELSE @space
         END AS zgubun
    FROM bp3100 AS a  INNER JOIN i_businesspartnercustomer AS b
                      ON a~partner EQ b~businesspartner
   WHERE b~customer  IN @s_kunnr
     AND a~zzgur_agy IN @lr_zzgur_agy             "보증기관
     AND a~addtype   EQ '10'                      "Info Cat: 10 (담보)
     AND a~data_type EQ '24'                      "유형: B2B
     AND a~xfeld     EQ 'X'
    INTO TABLE @DATA(lt_data).

* 거래처, 여신관리영역 기준으로 counter가 제일 큰 값만 남기고 삭제한다.
  SORT: lt_data BY kunnr kkber counter.
  DELETE ADJACENT DUPLICATES FROM lt_data COMPARING kunnr kkber.

  CHECK: lt_data[] IS NOT INITIAL.

  gt_kunnr[] = CORRESPONDING #( lt_data[] ).
  gt_req[]   = CORRESPONDING #( lt_data[] ).

**
  FREE: lt_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_selection
*&---------------------------------------------------------------------*
FORM data_selection .

**
  CHECK: gv_error IS INITIAL.

  _clear: gt_head, gt_item, gt_selt, r_state.

* 납품서, 품목 전체 정보 검색
  CASE 'X'.
    WHEN p_opt1.   "성공

      PERFORM select_history USING c_state1.

    WHEN p_opt2.   "실패

      PERFORM select_history USING c_state2.

    WHEN p_opt3.   "대상

      PERFORM select_data.

*     삭제된 납품서 체크
      PERFORM delete_delv.

    WHEN p_opt4.   "전체

      PERFORM select_history USING ''.

      PERFORM select_data.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form select_history
*&---------------------------------------------------------------------*
FORM select_history  USING    p_state.

  DATA: l_new .
  DATA: l_seqno  LIKE zsdt0010-seqno.

**
  CHECK: gv_error IS INITIAL.

  IF p_state IS NOT INITIAL.
    r_state-sign   = 'I'.
    r_state-option = 'EQ'.
    r_state-low    = p_state.
    APPEND r_state. CLEAR r_state.
  ENDIF.

  CHECK gt_kunnr[] IS NOT INITIAL.

  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE @gt_head
    FROM zsdt0010  FOR ALL ENTRIES IN @gt_kunnr
   WHERE kunnr     EQ @gt_kunnr-kunnr
     AND wadat_ist IN @s_wadat
     AND bupla     IN @s_bupla
     AND vbeln     IN @s_vbeln
     AND erdat     IN @s_seqno
     AND gubun     IN @s_gubun
     AND damb_gubn IN @s_dambg
     AND state     IN @r_state.

  SORT gt_head.

  IF p_ex_215 IS NOT INITIAL.
    PERFORM check_last_record.
  ENDIF.

  LOOP AT gt_head.

    SELECT SINGLE vgbel INTO @gt_head-vbeln_or
      FROM lips  WHERE vbeln = @gt_head-vbeln.

    SELECT SINGLE vkbur, vkgrp
      INTO @DATA(ls_vbak)
      FROM vbak  WHERE vbeln EQ @gt_head-vbeln_or.

    MOVE:  p_bukrs        TO gt_head-bukrs,
           ls_vbak-vkbur  TO gt_head-vkbur,
           ls_vbak-vkgrp  TO gt_head-vkgrp.

    PERFORM read_kkber USING gt_head-kkber gt_head-kkbtx.  "여신영역

    PERFORM set_light USING gt_head-state gt_head-light gt_head-tstate.

    MODIFY gt_head.

    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE @gt_item
      FROM zsdt0011  WHERE bupla = @gt_head-bupla
                       AND kunnr = @gt_head-kunnr
                       AND vbeln = @gt_head-vbeln
                       AND seqno = @gt_head-seqno.

  ENDLOOP.

  LOOP AT gt_item.
    CLEAR gt_head.
    READ TABLE gt_head WITH KEY bupla = gt_item-bupla
                                kunnr = gt_item-kunnr
                                vbeln = gt_item-vbeln
                                seqno = gt_item-seqno.

    gt_item-kkbtx = gt_head-kkbtx.            "여신영역명
    gt_item-name  = gt_head-name1.            "구매사명
    gt_item-trano = gt_head-trano.            "전문번호
    gt_item-gubun = gt_head-gubun.            "대출/담보보증구분
    gt_item-bukrs = gt_head-bukrs.            "회사코드
    gt_item-wadat_ist = gt_head-wadat_ist.    "gi일자
    gt_item-damb_gubn = gt_head-damb_gubn.    "보증유형
    gt_item-vkorg  =  gt_head-vkorg.
    gt_item-vtweg  =  gt_head-vtweg.
    gt_item-spart  =  gt_head-spart.
    gt_item-vkbur  =  gt_head-vkbur.
    gt_item-vkgrp  =  gt_head-vkgrp.
    gt_item-kkber   = gt_head-kkber.
    MODIFY gt_item.
  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_last_record
*&---------------------------------------------------------------------*
FORM check_last_record .

  DATA: lt_tmp1  LIKE gt_head OCCURS 0 WITH HEADER LINE.
  DATA: lt_tmp2  LIKE gt_head OCCURS 0 WITH HEADER LINE.
  DATA: l_new.

**
  lt_tmp1[] = gt_head[].
  lt_tmp2[] = lt_tmp1[].

  REFRESH gt_head. CLEAR gt_head.

*- 취소된 건 제외
  LOOP AT lt_tmp2 WHERE trano = c_b215.
    DELETE lt_tmp1 WHERE bupla = lt_tmp2-bupla
                     AND kunnr = lt_tmp2-kunnr
                     AND vbeln = lt_tmp2-vbeln.
  ENDLOOP.

  SORT lt_tmp1 .
  SORT lt_tmp2 BY bupla kunnr vbeln trano seqno amend.

  LOOP AT lt_tmp1.
    AT NEW vbeln.
      l_new = 'X'.
    ENDAT.
    CHECK l_new IS NOT INITIAL.
    CLEAR l_new.

    READ TABLE lt_tmp2
                       WITH KEY bupla = lt_tmp1-bupla
                                kunnr = lt_tmp1-kunnr
                                vbeln = lt_tmp1-vbeln
                                trano = c_b213.

    CLEAR lt_tmp2.
    IF sy-subrc EQ 0.
*-   변경된 건이 있는 경우 마지막 건
      LOOP AT lt_tmp2 WHERE bupla = lt_tmp1-bupla
                        AND kunnr = lt_tmp1-kunnr
                        AND vbeln = lt_tmp1-vbeln
                        AND trano = c_b213.
      ENDLOOP.

    ELSE.
*-   신규 건
      READ TABLE lt_tmp2 WITH KEY bupla = lt_tmp1-bupla
                                  kunnr = lt_tmp1-kunnr
                                  vbeln = lt_tmp1-vbeln
                                  trano = c_b211.

    ENDIF.

    CHECK lt_tmp2 IS NOT INITIAL.

    gt_head = lt_tmp2.
    APPEND gt_head. CLEAR gt_head.

  ENDLOOP.

**
  FREE: lt_tmp1, lt_tmp2.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form read_kkber
*&---------------------------------------------------------------------*
FORM read_kkber  USING    p_code
                          p_text.

**
  SELECT SINGLE kkbtx INTO @p_text
   FROM t014t  WHERE kkber EQ @p_code
                 AND spras EQ @sy-langu.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_light
*&---------------------------------------------------------------------*
FORM set_light  USING    p_state
                         p_light
                         p_text.

**
  CASE p_state.
    WHEN c_state1. "성공
      p_light = '3'.
      p_text = '전송성공'.
    WHEN c_state2. "eai 실패
      p_light = '1'.
      p_text = '전송실패'.
    WHEN c_state3. "데이터오류.
      p_light = '1'.
      p_text = '데이터오류'.
  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form select_data
*&---------------------------------------------------------------------*
FORM select_data .

  DATA: l_new_vbeln,                   "신규납품번호
        l_subrc     LIKE sy-subrc,        "전송이력존재여부 0 - 존재
        l_amount    LIKE zsdt0010-netwr.  "합계정가

  DATA: lt_conf LIKE conf_out OCCURS 0 WITH HEADER LINE,
        lt_valu LIKE api_value OCCURS 0 WITH HEADER LINE.
  DATA: l_pernr LIKE pa0001-pernr.

**
  CHECK: gv_error IS INITIAL AND
         gt_kunnr[] IS NOT INITIAL.

*^ 대상 납품문서 검색
  _clear gt_main.
  SELECT kp~vbeln,
         ps~werks,
         kp~wadat_ist,
         kp~kunnr,
         kp~knkli,
         kp~kkber,
         kp~wadat,
         kp~wbstk,
         ps~posnr,
         ps~matnr,
         ps~lfimg,
         ps~vrkme,
         ps~vgbel,
         ps~vgpos,
         ps~mbdat
    INTO CORRESPONDING FIELDS OF TABLE @gt_main
    FROM lips AS ps  INNER JOIN likp AS kp
                     ON kp~vbeln = ps~vbeln
     FOR ALL ENTRIES IN @gt_kunnr
   WHERE kp~vkorg     EQ @gt_kunnr-bukrs
     AND kp~knkli     EQ @gt_kunnr-kunnr
     AND kp~kkber     EQ @gt_kunnr-kkber
     AND kp~wadat_ist IN @s_wadat
     AND kp~vbeln     IN @s_vbeln
     AND ps~uecha     EQ @space.

*^ 출고취소된 건 검색하기위해
  PERFORM select_zsdt0010.

  SORT gt_main.

  LOOP AT gt_main.

    AT NEW vbeln.
      l_new_vbeln = 'X'.
    ENDAT.

    IF l_new_vbeln IS NOT INITIAL.
      CLEAR: l_new_vbeln, l_amount.

      l_subrc = 4.
      PERFORM get_header_data USING l_subrc.

    ENDIF.

    CHECK l_subrc IS INITIAL.   "HEAD 에서 조건체크함

    CLEAR gt_item.
    MOVE-CORRESPONDING gt_head TO gt_item.

    gt_item-posnr = gt_main-posnr.
*    gt_item-matnr = gt_main-matnr.
    gt_item-vbeln_or = gt_main-vgbel.
    gt_item-posnr_or = gt_main-vgpos.
    gt_item-ketdat = gt_main-mbdat.

*   품명
    PERFORM get_arktx USING gt_main-matnr
                            gt_item-matnr
                            gt_item-arktx.

*   담당자
    PERFORM get_pernr USING gt_main-vgbel gt_main-vgpos
                            gt_item-pernr.

*   수량
    PERFORM get_lfimg USING gt_item-lfimg gt_item-vrkme.


*   단가, 공급가액, 세액, 정가, 통화
    PERFORM calc_amount USING gt_main-vgbel gt_main-vgpos.

*   WBSTA <> 'C' 아닌경우 금액을 '1' 로
    IF gt_main-wbstk <> 'C'   AND
       gt_head-trano = c_b213 AND
       gt_head-mblnr IS INITIAL.

      IF gt_item-waerk = 'KRW'.
        gt_item-netwr = '0.01'.
      ELSE.
        gt_item-netwr = 1.
      ENDIF.

    ENDIF.

    IF gt_head-vbtyp = 'H'.
      gt_item-netwr = gt_item-netwr * '-1'.
    ENDIF.

*   합계금액
    ADD gt_item-netwr TO l_amount.

    gt_item-cuobj = vbap-cuobj.
    APPEND gt_item.

    AT END OF vbeln.

      MOVE: c_gubun       TO gt_head-gubun,     "대출담보보증구분
            l_amount      TO gt_head-netwr,     "정가
            gt_item-waerk TO gt_head-waerk.     "통화

      gt_head-fkdat = gt_head-wadat_ist + 120.       "대금청구일

      CLEAR gt_kunnr.
      READ TABLE gt_kunnr WITH KEY kunnr = gt_head-kunnr
                                   kkber = gt_head-kkber.
      MOVE: gt_kunnr-bukrs    TO gt_head-bukrs     ,         "회사코드
            gt_kunnr-zgubun   TO gt_head-damb_gubn .         "보증유형

      PERFORM read_kkber USING gt_head-kkber gt_head-kkbtx.  "여신영역

      PERFORM read_branch USING gt_head-bupla gt_head-bukrs  "판매사정보
                                gt_head-stcd0 gt_head-stcd0_name
                                gt_head-name.

      PERFORM read_kunnr USING gt_head-kunnr gt_head-stcd1   "구매사정보
                               gt_head-stcd1_name gt_head-name1.

      APPEND gt_head. CLEAR gt_head.
    ENDAT.

  ENDLOOP.

  LOOP AT gt_item.

* 특성값조회
    REFRESH lt_conf. CLEAR lt_conf.
    REFRESH lt_valu. CLEAR lt_valu.

    CALL FUNCTION '/SAPMP/CE3_GET_CONFIG_SINGLE'
      EXPORTING
        im_instance   = gt_item-cuobj
* IMPORTING
*       EX_FIELD_ATTR =
      TABLES
        configuration = lt_conf
        api_values    = lt_valu
      EXCEPTIONS
        not_found     = 1
        OTHERS        = 2.

    LOOP AT lt_conf.
      CASE lt_conf-atnam.
        WHEN 'SAP_LENGTH_VKRME'.
          REPLACE ALL OCCURRENCES OF ',' IN lt_conf-atwtb WITH ''.
          CONDENSE lt_conf-atwtb NO-GAPS.
          gt_item-char02 = lt_conf-atwtb.
        WHEN 'SAP_MILLCA_FACTOR'.
          REPLACE ALL OCCURRENCES OF ',' IN lt_conf-atwtb WITH ''.
          CONDENSE lt_conf-atwtb NO-GAPS.
          gt_item-char03 = lt_conf-atwtb.
        WHEN 'PD_AC_012'.
          gt_item-char04 = lt_conf-atwtb.
        WHEN 'PD_AC_029'.
          gt_item-char05 = lt_conf-atwtb.
        WHEN 'PD_AC_019'.
          gt_item-char06 = lt_conf-atwtb.
        WHEN 'PD_IM_CLAMP_FORCE'.
          gt_item-char07 = lt_conf-atwtb.
        WHEN 'PD_IM_SERIES'.
          gt_item-char08 = lt_conf-atwtb.
      ENDCASE.
    ENDLOOP.

    CLEAR gt_head.
    READ TABLE gt_head WITH KEY vbeln = gt_item-vbeln
                                seqno = gt_item-seqno.

    gt_item-kkbtx = gt_head-kkbtx.            "여신영역명
    gt_item-name  = gt_head-name1.            "구매사명
    gt_item-trano = gt_head-trano.            "전문번호
    gt_item-gubun = gt_head-gubun.            "대출/담보보증구분
    gt_item-bukrs = gt_head-bukrs.            "회사코드

    gt_item-wadat_ist = gt_head-wadat_ist.    "gi일자
    gt_item-damb_gubn = gt_head-damb_gubn.    "보증유형
    gt_item-state = gt_head-state.
    gt_item-tstate = gt_head-tstate.

*   규격
    gt_item-char01 = gt_item-char02.
    CONDENSE gt_item-char01 NO-GAPS.
    CONCATENATE gt_item-char01 gt_item-vrkme INTO gt_item-char01.

*  납품장소
    SELECT SINGLE city1 INTO gt_item-name1     "주소
      FROM adrc
     WHERE addrnumber = gt_head-adrnr.

    MODIFY gt_item.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form select_zsdt0010
*&---------------------------------------------------------------------*
FORM select_zsdt0010 .

  DATA: lt_temp  LIKE zsdt0010 OCCURS 0 WITH HEADER LINE.

**
  _clear lt_temp.
  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE @lt_temp
    FROM zsdt0010  FOR ALL ENTRIES IN @gt_kunnr
   WHERE kunnr     EQ @gt_kunnr-kunnr
     AND bupla     IN @s_bupla
     AND vbeln     IN @s_vbeln
     AND erdat     IN @s_seqno
     AND gubun     IN @s_gubun
     AND damb_gubn IN @s_dambg
     AND state     EQ @c_state1.

  SORT: lt_temp BY bupla kunnr vbeln seqno.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING vbeln.

  CHECK lt_temp[] IS NOT INITIAL.

  SELECT kp~vbeln,
         ps~werks,
         kp~wadat_ist,
         kp~kunnr,
         kp~knkli,
         kp~kkber,
         kp~wadat,
         kp~wbstk,
         ps~posnr,
         ps~matnr,
         ps~lfimg,
         ps~vrkme,
         ps~vgbel,
         ps~vgpos,
         ps~mbdat
  APPENDING CORRESPONDING FIELDS OF TABLE @gt_main
    FROM lips AS ps  INNER JOIN likp AS kp
                     ON kp~vbeln = ps~vbeln
     FOR ALL ENTRIES IN @lt_temp
   WHERE kp~vbeln     EQ @lt_temp-vbeln
     AND ps~uecha     EQ @space
     AND kp~wadat_ist EQ '00000000'.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_header_data
*&---------------------------------------------------------------------*
FORM get_header_data  USING    p_subrc.

  DATA: BEGIN OF lt_vbfa OCCURS 0,
          erdat LIKE vbfa-erdat,
          vbeln LIKE vbfa-vbeln,
          vbelv LIKE vbfa-vbelv,
        END   OF lt_vbfa.

  DATA: l_subrc LIKE sy-subrc,   "전송이력 존재여부 0 - 존재
        l_check LIKE sy-subrc.   "취소문서 존재여부 0 - 존재

**
  CLEAR gt_head.

*- 영업문서정보
  SELECT SINGLE  vbeln vkorg vtweg spart vkbur vkgrp kkber vbtyp
    INTO CORRESPONDING FIELDS OF vbak
    FROM vbak
   WHERE vbeln = gt_main-vgbel
     AND auart IN ('TA',    "OR
                   'Z3RD', 'ZORT', 'ZPO', 'ZOT', 'RE', 'ZRET').

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

*- 사업장
  SELECT SINGLE j_1bbranch INTO gt_main-bupla
    FROM t001w
   WHERE werks = gt_main-werks
     AND j_1bbranch IN s_bupla.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

*- 전송된 마지막 이력검색
  CLEAR zsdt0010.
  SELECT  *
    FROM zsdt0010
   WHERE bupla = gt_main-bupla
     AND kunnr = gt_main-knkli
     AND vbeln = gt_main-vbeln
     AND state = c_state1
   ORDER BY seqno DESCENDING.
    EXIT.
  ENDSELECT.

  IF zsdt0010-trano = c_b215.
    EXIT.
  ENDIF.

  l_subrc = sy-subrc.

*- 상태가 'C' 인 경우
  IF gt_main-wbstk EQ 'C' .

*- 보증서 체크 : 종료일자가 실제출고일자를 포함하는 건 체크
    LOOP AT gt_req TRANSPORTING NO FIELDS
                   WHERE kunnr = gt_main-knkli
                     AND enddt+0(6) >= gt_main-wadat+0(6).
      EXIT.
    ENDLOOP.

    IF sy-subrc NE 0.
      EXIT.
    ENDIF.

    REFRESH lt_vbfa. CLEAR lt_vbfa.
    SELECT vbeln erdat vbelv
      INTO CORRESPONDING FIELDS OF TABLE lt_vbfa
      FROM vbfa
     WHERE vbelv = gt_main-vbeln
       AND posnn = '000001'
       AND vbtyp_n = 'R'.

*-  마지막으로 발생한 자재문서
    SORT lt_vbfa BY erdat DESCENDING
                    vbeln DESCENDING.
    READ TABLE lt_vbfa INDEX 1.

    IF l_subrc EQ 0.
*   전송이력이 있는 경우
      IF zsdt0010-mblnr <> lt_vbfa-vbeln.

*     취소된 문서가 있는지 체크
        PERFORM check_cancle USING zsdt0010-mblnr
                                   zsdt0010-mjahr
                                   l_check.

        IF l_check EQ 0.
          MOVE-CORRESPONDING gt_main TO gt_head.

          gt_head-trano = c_b213.           "전문번호
          gt_head-mblnr = lt_vbfa-vbeln.    "자재문서

          PERFORM get_mjahr USING lt_vbfa-vbeln
                                  lt_vbfa-vbelv
                                  gt_head-mjahr. "문서년도

          CLEAR p_subrc.
        ENDIF.

      ENDIF.

    ELSE.
*   전송이력이 없는 경우
      MOVE-CORRESPONDING gt_main TO gt_head.

      gt_head-trano = c_b211.           "전문번호
      gt_head-mblnr = lt_vbfa-vbeln.    "자재문서

      PERFORM get_mjahr USING lt_vbfa-vbeln
                              lt_vbfa-vbelv
                              gt_head-mjahr. "문서년도
      CLEAR p_subrc.
    ENDIF.
  ELSE.
*-  'C' 가 아니면 전송된 건이 있을 때만
    CHECK l_subrc EQ 0.

    CHECK zsdt0010-wadat_ist IN s_wadat AND
          zsdt0010-mblnr IS NOT INITIAL.

*   취소된 문서가 있는지 체크
    PERFORM check_cancle USING zsdt0010-mblnr
                               zsdt0010-mjahr
                               l_check.

    CHECK l_check  EQ 0.

    MOVE-CORRESPONDING gt_main TO gt_head.

    gt_head-wadat_ist = zsdt0010-wadat_ist.
    gt_head-trano = c_b213.           "전문번호
    gt_head-mblnr = space.            "자재전표
    gt_head-mjahr = space.            "문서년도
    CLEAR p_subrc.
  ENDIF.

  CHECK p_subrc IS INITIAL.

  MOVE: vbak-vbeln  TO gt_head-vbeln_or,
        vbak-vkorg  TO gt_head-vkorg,
        vbak-vtweg  TO gt_head-vtweg,
        vbak-spart  TO gt_head-spart,
        vbak-vkbur  TO gt_head-vkbur,
        vbak-vkgrp  TO gt_head-vkgrp,
        vbak-vbtyp  TO gt_head-vbtyp,
        gt_main-kkber TO gt_head-kkber,
        gt_main-knkli TO gt_head-kunnr.

*- 납품장소를 위해
  SELECT SINGLE adrnr  INTO    gt_head-adrnr        FROM kna1
   WHERE kunnr = gt_main-kunnr.

  IF gt_head-vbtyp = 'H'.
    gt_head-trano = c_b213.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_cancle
*&---------------------------------------------------------------------*
FORM check_cancle  USING    p_mblnr
                            p_mjahr
                            p_check.

  DATA: l_mblnr  LIKE matdoc-mblnr.

**
  CLEAR p_check.

  SELECT SINGLE mblnr INTO l_mblnr
    FROM matdoc
   WHERE smbln = zsdt0010-mblnr
     AND sjahr = zsdt0010-mjahr.

  p_check = sy-subrc.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_mjahr
*&---------------------------------------------------------------------*
FORM get_mjahr  USING    p_vbeln
                         p_vbelv
                         p_mjahr.

**
  SELECT SINGLE mjahr INTO p_mjahr
    FROM matdoc
   WHERE mblnr = p_vbeln    "자재문서
     AND xblnr = p_vbelv.   "납품문서

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_arktx
*&---------------------------------------------------------------------*
FORM get_arktx  USING    p_matnr
                         p_matnr_out
                         p_arktx.

*  DATA: l_prdha  LIKE mara-prdha.

**
  p_matnr_out = p_matnr.

  SELECT SINGLE maktx INTO @p_arktx
    FROM makt
   WHERE matnr EQ @p_matnr
     AND spras EQ @sy-langu.

*  SELECT SINGLE prdha INTO l_prdha
*    FROM mara
*   WHERE matnr = p_matnr.
*
*  SELECT SINGLE prodh vtext INTO (p_matnr_out, p_arktx)
*    FROM t179t
*   WHERE spras = sy-langu
*     AND prodh = l_prdha+0(8).

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_pernr
*&---------------------------------------------------------------------*
FORM get_pernr  USING    p_vgbel
                         p_vgpos
                         p_pernr.

**
  SELECT SINGLE lifnr
    FROM vbpa
   WHERE vbeln = @p_vgbel
     AND parvw = 'VE'
    INTO @DATA(lv_lifnr).
  IF sy-subrc EQ 0.
    REPLACE FIRST OCCURRENCE OF 'E00' IN lv_lifnr WITH space.
    p_pernr = lv_lifnr.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_lfimg
*&---------------------------------------------------------------------*
FORM get_lfimg  USING    p_lfimg
                         p_vrkme.

**
  p_lfimg = gt_main-lfimg.
  p_vrkme = gt_main-vrkme.

*   배치분할일 경우
  IF gt_main-lfimg IS INITIAL.
    SELECT SUM( lfimg )
      INTO p_lfimg
      FROM lips
     WHERE vbeln = gt_main-vbeln
       AND uecha = gt_main-posnr.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form calc_amount
*&---------------------------------------------------------------------*
FORM calc_amount  USING    p_vgbel
                           p_vgpos.

  DATA: l_netpr TYPE p DECIMALS 5.
  DATA: l_kunnr LIKE vbpa-kunnr.
  DATA: l_old   LIKE t006-msehi,
        l_new   LIKE t006-msehi,
        l_value LIKE plfh-mgvgw.

**
  CLEAR vbap.
  SELECT SINGLE netpr kpein taxm1 waerk kmein cuobj kwmeng netwr
    INTO CORRESPONDING FIELDS OF vbap
    FROM vbap
   WHERE vbeln = p_vgbel
     AND posnr = p_vgpos.

* 환율
  CLEAR vbkd.
  SELECT SINGLE bstkd kursk
    INTO CORRESPONDING FIELDS OF vbkd
    FROM vbkd
   WHERE vbeln = p_vgbel.

* 단가 = ( 주문정가 / 주문수량 )
  IF vbap-netpr  = 0 AND vbap-kwmeng NE 0.
    vbap-netpr = ( vbap-netwr / vbap-kwmeng ).
  ENDIF.

  IF vbap-waerk = 'KRW'.

    l_netpr = vbap-netpr / vbap-kpein.

  ELSE.

    l_netpr = ( vbap-netpr / vbap-kpein ) * vbkd-kursk.

    l_netpr = l_netpr / 100.
  ENDIF.

* 출고단위와 가격단위가 다르면
  IF gt_item-vrkme <> vbap-kmein.

    l_new = vbap-kmein.
    l_old = gt_item-vrkme.
    l_value = 1.

    CALL FUNCTION 'CF_UT_UNIT_CONVERSION'
      EXPORTING
        unit_new_imp  = l_new
        unit_old_imp  = l_old
        value_old_imp = l_value
      IMPORTING
        value_new_exp = l_value
      EXCEPTIONS
        overflow      = 1
        OTHERS        = 2.

    IF l_value > 0.
      l_netpr = l_netpr * l_value.
    ENDIF.

  ENDIF.

  gt_item-netpr = l_netpr.

* 공급가액
  gt_item-hwbas = l_netpr * gt_item-lfimg.

* 세액
  CLEAR l_kunnr.
  SELECT SINGLE kunnr INTO l_kunnr
    FROM vbpa
   WHERE vbeln = p_vgbel
     AND parvw = 'RG'.

  SELECT SINGLE taxkd INTO knvi-taxkd
    FROM knvi
   WHERE kunnr = l_kunnr.

  IF knvi-taxkd = '1'.
    gt_item-hwste = gt_item-hwbas * '0.1'.
  ELSE.
    CLEAR gt_item-hwste.
  ENDIF.

*  정가
  gt_item-netwr = gt_item-hwbas + gt_item-hwste.

*  gt_item-waerk = vbap-waerk.
  gt_item-waerk = 'KRW'.

* 주문서명
  gt_item-bstkd = vbkd-bstkd.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form read_branch
*&---------------------------------------------------------------------*
FORM read_branch  USING    p_bupla
                           p_bukrs
                           p_stcd1
                           p_stcd2
                           p_name.

**
  SELECT SINGLE stcd1 stcd2 name
    INTO (p_stcd1, p_stcd2, p_name)
    FROM j_1bbranch
   WHERE bukrs = p_bukrs
     AND branch = p_bupla.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form read_kunnr
*&---------------------------------------------------------------------*
FORM read_kunnr  USING    p_kunnr
                          p_stcd1
                          p_stcd2
                          p_name1.

**
  SELECT SINGLE stcd1 stcd2 name1
    INTO (p_stcd1, p_stcd2, p_name1)
    FROM kna1
   WHERE kunnr = p_kunnr.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form delete_delv
*&---------------------------------------------------------------------*
FORM delete_delv .

  DATA: lt_temp  LIKE zsdt0010 OCCURS 0 WITH HEADER LINE.

**
  CHECK: gv_error IS INITIAL.

  _clear lt_temp.
  CHECK gt_kunnr[] IS NOT INITIAL.

  SELECT * INTO TABLE lt_temp
    FROM zsdt0010
     FOR ALL ENTRIES IN gt_kunnr
   WHERE kunnr = gt_kunnr-kunnr
     AND wadat_ist IN s_wadat
     AND bupla     IN s_bupla
     AND vbeln     IN s_vbeln
     AND erdat     IN s_seqno
     AND gubun     IN s_gubun
     AND damb_gubn IN s_dambg.

  SORT lt_temp BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING vbeln.

  LOOP AT lt_temp.
*   납품문서 삭제여부 체크
    SELECT SINGLE vbeln INTO likp-vbeln
      FROM likp
     WHERE vbeln = lt_temp-vbeln.

    CHECK sy-subrc NE 0.

*   이미 취소되었는지 체크
    SELECT SINGLE * FROM zsdt0010
     WHERE vbeln = lt_temp-vbeln
       AND trano = c_b215.

    CHECK sy-subrc NE 0.

    MOVE-CORRESPONDING lt_temp TO gt_head.
    gt_head-trano = c_b215.             "전문번호
    CLEAR: gt_head-seqno, gt_head-mblnr, gt_head-mjahr,
           gt_head-state, gt_head-message.
    APPEND gt_head. CLEAR gt_head.


  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form end_process
*&---------------------------------------------------------------------*
FORM end_process .

**
  CHECK: gv_error IS INITIAL.

  IF sy-batch IS INITIAL.

    CALL SCREEN 100.

  ELSE.
    gt_head-chkbox = 'X'.
    MODIFY gt_head TRANSPORTING chkbox WHERE chkbox IS INITIAL.

    PERFORM transfer_data.

    PERFORM display_data.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form transfer_data
*&---------------------------------------------------------------------*
FORM transfer_data .

  DATA: l_info         LIKE  rfcsi,
        l_msg_text(80) TYPE c.         "Message text

  DATA: lt_temp   LIKE zsdt0010 OCCURS 0 WITH HEADER LINE.
  DATA: lt_item   LIKE zsds0011 OCCURS 0 WITH HEADER LINE.

  DATA: l_subrc   LIKE sy-subrc,
        l_result  TYPE char2,
        l_message TYPE char100.

  DATA : dest_name LIKE zifdest-dest.

**
  CHECK: gv_error IS INITIAL.

  READ TABLE gt_head WITH KEY chkbox = 'X'.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

* EAI 목적지 변경
  CLEAR : dest_name.
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'IS'
    IMPORTING
      dest_name             = dest_name
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.

* Synchronous call to function module RFC_SYSTEM_INFO
  CALL FUNCTION 'RFC_SYSTEM_INFO'
    DESTINATION dest_name
    IMPORTING
      rfcsi_export          = l_info
    EXCEPTIONS
      communication_failure = 1 MESSAGE l_msg_text
      system_failure        = 2 MESSAGE l_msg_text.

  IF sy-subrc NE 0.
    MESSAGE s000 WITH l_msg_text .
    EXIT.
  ENDIF.

  GET TIME.

  CLEAR: g_seqno.
  g_seqno+0(8) = sy-datum.
  g_seqno+8(6) = sy-uzeit.

  IF g_seqno IS INITIAL.
*   일련번호를 채번하지 못해 중단합니다.
    MESSAGE s000 WITH TEXT-e02  DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*^ 데이터 체크
  PERFORM check_data TABLES lt_temp.

  IF sy-batch IS INITIAL.
    READ TABLE gt_head WITH KEY chkbox = 'X'
                                state = c_state3.
    IF sy-subrc EQ 0.

      gt_head-chkbox = ' '.
      MODIFY gt_head  TRANSPORTING chkbox
       WHERE chkbox = 'X'.

*     오류가 있는 데이터를 확인하십시요.
      MESSAGE s000 WITH TEXT-e03  DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
  ENDIF.

  CHECK: lt_temp[] IS NOT INITIAL.

*^ 데이터 전송
  LOOP AT lt_temp.

    CLEAR l_subrc.
    PERFORM if_header_data USING lt_temp
                                 l_subrc.


    IF l_subrc EQ 0 AND
       lt_temp-trano <> c_b215.   "취소는 ITEM 정보안보냄

      PERFORM if_item_data  TABLES lt_item
                             USING lt_temp
                                 l_subrc.

    ENDIF.

    IF l_subrc EQ 0.
      COMMIT WORK.

      PERFORM call_function  TABLES lt_item
                              USING lt_temp.

    ENDIF.

  ENDLOOP.

  IF sy-batch IS INITIAL.
    MESSAGE s000 WITH '선택된 데이터를 전송하였습니다.'.

    PERFORM refresh_data.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_data
*&---------------------------------------------------------------------*
FORM check_data  TABLES   pt_temp STRUCTURE zsdt0010  .

  DEFINE modify_state.
    gt_head-state = c_state3.
    gt_head-message = &1.
    PERFORM set_light USING gt_head-state gt_head-light gt_head-tstate.
    MODIFY gt_head.
  END-OF-DEFINITION.

  DATA: l_answer.
  DATA: l_amount  LIKE zsdt0010-netwr.

**
  _clear pt_temp.
  LOOP AT gt_head WHERE chkbox = 'X'.

    IF sy-batch IS INITIAL.
*     기 전송대상여부 체크
      IF gt_head-state = c_state1 .   "성공
        IF l_answer <> '1'.
          PERFORM popup_decide USING l_answer.
        ENDIF.

        IF l_answer = 'A'.
          _clear pt_temp.
          EXIT.
        ENDIF.

      ENDIF.

    ELSE.
      CHECK gt_head-state <> c_state1.
    ENDIF.

    IF l_answer = '1' .
      MOVE-CORRESPONDING gt_head TO pt_temp.
      APPEND pt_temp. CLEAR pt_temp.
      CONTINUE.
    ENDIF.

*   b211 로 전송 성공건이 있으면 b211 로 전송불가
    IF gt_head-trano = c_b211.
      SELECT SINGLE seqno INTO zsdt0010-seqno
        FROM zsdt0010
       WHERE bupla = gt_head-bupla
         AND kunnr = gt_head-kunnr
         AND vbeln = gt_head-vbeln
         AND trano = c_b211
         AND state = c_state1.

      IF sy-subrc EQ 0.
        CONCATENATE 'SEQNO' zsdt0010-seqno
              '로 B211 전문이 전송된 상태입니다.'
         INTO gt_head-message
          SEPARATED BY space.

        modify_state gt_head-message.
        CONTINUE.
      ENDIF.
    ENDIF.

*   전문취소가 아닌 경우만
    IF gt_head-trano <> c_b215.
      IF gt_head-netwr = 0.
        modify_state  '금액오류'.

        CONTINUE.
      ENDIF.

      CLEAR l_amount.
      LOOP AT gt_item WHERE bupla = gt_head-bupla
                        AND kunnr = gt_head-kunnr
                        AND vbeln = gt_head-vbeln
                        AND seqno = gt_head-seqno.

        IF gt_item-netwr = 0.

          modify_state '금액오류'.
          EXIT.
        ENDIF.

        IF gt_item-matnr IS INITIAL OR
           gt_item-arktx IS INITIAL.

          modify_state '자재코드오류'.
          EXIT.
        ENDIF.

        IF gt_item-lfimg IS INITIAL OR
           gt_item-vrkme IS INITIAL.

          modify_state  '수량,단위 오류'.
          EXIT.
        ENDIF.

        ADD gt_item-netwr TO l_amount.
      ENDLOOP.

      IF gt_head-state <> c_state3.
        IF l_amount <> gt_head-netwr.

          modify_state  '금액합계오류'.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

    CHECK gt_head-state <> c_state3.
    CLEAR: gt_head-state, gt_head-message.
    MODIFY gt_head.

    MOVE-CORRESPONDING gt_head TO pt_temp.
    APPEND pt_temp. CLEAR pt_temp.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form popup_decide
*&---------------------------------------------------------------------*
FORM popup_decide  USING p_answer.

**
  CALL FUNCTION 'POPUP_TO_DECIDE'
    EXPORTING
      defaultoption = '2'
      textline1     = '기 전송대상이 포함되어 있습니다.'
      textline2     = '계속하시겠습니까?'
*     TEXTLINE3     = ''
      text_option1  = '전체무시'
      text_option2  = '예'
*     ICON_TEXT_OPTION1       = ' '
*     ICON_TEXT_OPTION2       = ' '
      titel         = '전송상태확인'
*     START_COLUMN  = 25
*     START_ROW     = 6
*     CANCEL_DISPLAY          = 'X'
    IMPORTING
      answer        = p_answer.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form if_header_data
*&---------------------------------------------------------------------*
FORM if_header_data  USING    ps_temp  LIKE zsdt0010
                              p_subrc.

**
  CLEAR zsdt0010.
  MOVE-CORRESPONDING ps_temp TO zsdt0010.

*   일련번호
  zsdt0010-seqno = g_seqno.

*   AMEND NO
  IF zsdt0010-trano = c_b213.
    SELECT MAX( amend ) INTO zsdt0010-amend
      FROM zsdt0010
     WHERE bupla = zsdt0010-bupla
       AND kunnr = zsdt0010-kunnr
       AND vbeln = zsdt0010-vbeln
       AND trano = c_b213.

    ADD 1 TO zsdt0010-amend.
  ENDIF.

  zsdt0010-erdat = g_seqno+0(8).
  zsdt0010-erzet = g_seqno+8(6).
  zsdt0010-ernam = sy-uname.

  INSERT zsdt0010.

  p_subrc = sy-subrc.


  CLEAR zsds0010.
  MOVE-CORRESPONDING zsdt0010 TO zsds0010.

  zsds0010-kunnr = |{ zsds0010-kunnr ALPHA = OUT }|.
*  PERFORM conv_alpha_output USING zsds0010-kunnr.

*    금액
  PERFORM convert_amount USING zsdt0010-waerk
                               zsdt0010-netwr
                               zsds0010-netwr.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form convert_amount
*&---------------------------------------------------------------------*
FORM convert_amount  USING    p_waerk
                              p_in
                              p_out.

  DATA: l_waers  LIKE tcurc-waers.

**
  l_waers = p_waerk.
  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_IDOC'
    EXPORTING
      currency    = l_waers
      sap_amount  = p_in
    IMPORTING
      idoc_amount = p_out.

  IF p_in < 0.
    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        value = p_out.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form if_item_data
*&---------------------------------------------------------------------*
FORM if_item_data  TABLES pt_item  STRUCTURE zsds0011
                    USING    ps_temp   LIKE zsdt0010
                            p_subrc.

**
  _clear pt_item.
  LOOP AT gt_item WHERE bupla = ps_temp-bupla
                    AND kunnr = ps_temp-kunnr
                    AND vbeln = ps_temp-vbeln
                    AND seqno = ps_temp-seqno.

    CLEAR zsdt0011.
    MOVE-CORRESPONDING gt_item TO zsdt0011.

*   일련번호
    zsdt0011-seqno = g_seqno.

    zsdt0011-erdat = g_seqno+0(8).
    zsdt0011-erzet = g_seqno+8(6).
    zsdt0011-ernam = sy-uname.

    INSERT zsdt0011.

    IF sy-subrc NE 0.
      p_subrc = sy-subrc.
      EXIT.
    ENDIF.

    MOVE-CORRESPONDING zsdt0011 TO pt_item.

    IF zsdt0011-hwste IS INITIAL.
      pt_item-hwste = '0'.
    ENDIF.

    pt_item-kunnr = |{ pt_item-kunnr ALPHA = OUT }|.
*    PERFORM conv_alpha_output USING pt_item-kunnr.

*    금액
    PERFORM convert_amount USING zsdt0011-waerk
                                 zsdt0011-netpr
                                 pt_item-netpr.

    PERFORM convert_amount USING zsdt0011-waerk
                                 zsdt0011-hwbas
                                  pt_item-hwbas.

    PERFORM convert_amount USING zsdt0011-waerk
                                 zsdt0011-hwste
                                  pt_item-hwste.

    PERFORM convert_amount USING zsdt0011-waerk
                                 zsdt0011-netwr
                                  pt_item-netwr.

    APPEND pt_item. CLEAR pt_item.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form call_function
*&---------------------------------------------------------------------*
FORM call_function  TABLES pt_item  STRUCTURE zsds0011
                    USING ps_temp  LIKE zsdt0010.

  DATA: l_result  TYPE char2,
        l_message TYPE char100.

  DATA : dest_name LIKE zifdest-dest.

**
  CLEAR : dest_name.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'IS'
    IMPORTING
      dest_name             = dest_name
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.


  CALL FUNCTION 'Z_SD_IF_CONTRACT'
    DESTINATION dest_name
    EXPORTING
      i_head    = zsds0010
    IMPORTING
      e_result  = l_result
      e_message = l_message
    TABLES
      it_item   = pt_item
    EXCEPTIONS
      OTHERS    = 1.

*^    전송결과
  zsdt0010-state   = l_result.
  zsdt0010-message = l_message.
  MODIFY zsdt0010.

  DATA: zsdt9000 TYPE zsdt9000.
  CLEAR: zsdt9000.

  zsdt9000-zfunc = 'Z_SD_IF_CONTRACT'.
  zsdt9000-pgmnm = sy-repid.
  zsdt9000-erdat = sy-datlo.
  zsdt9000-erzet = sy-timlo.
  zsdt9000-ernam = sy-uname.
  zsdt9000-zrslt = l_result.
  zsdt9000-zrtxt = l_message.

  MODIFY zsdt9000 FROM zsdt9000.


  gt_head-seqno = zsds0010-seqno.
  gt_head-state = l_result.
  gt_head-message = l_message.

  PERFORM set_light USING gt_head-state gt_head-light
                          gt_head-tstate.

  MODIFY gt_head TRANSPORTING seqno state message light tstate
   WHERE bupla = ps_temp-bupla
     AND kunnr = ps_temp-kunnr
     AND vbeln = ps_temp-vbeln
     AND seqno = ps_temp-seqno.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form refresh_data
*&---------------------------------------------------------------------*
FORM refresh_data .

**
  _clear: gt_head, gt_item, gt_selt, r_state.

* 납품서, 품목 전체 정보 검색
  CASE 'X'.
    WHEN p_opt1.   "성공

      PERFORM select_history USING c_state1.

    WHEN p_opt2.   "실패

      PERFORM select_history USING c_state2.

    WHEN p_opt3.   "대상

      PERFORM select_data.

*     삭제된 납품서 체크
      PERFORM delete_delv.

    WHEN p_opt4.   "전체

      PERFORM select_history USING ''.

      PERFORM select_data.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
FORM display_data .

**
  gs_layout-zebra             = 'X'  .
  gs_layout-box_fieldname     = 'CHKBOX'.
  gs_layout-lights_fieldname  = 'LIGHT'.
  gs_layout-colwidth_optimize = 'X'  .

  PERFORM append_fieldcatalog .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = g_repid
      i_bypassing_buffer = 'X'
      i_save             = 'A'
      it_sort            = gt_sort[]
      it_events          = gt_events[]
      it_fieldcat        = gt_fieldcat[]
      is_layout          = gs_layout
      is_variant         = g_variant
    TABLES
      t_outtab           = gt_head.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form append_fieldcatalog
*&---------------------------------------------------------------------*
FORM append_fieldcatalog .

**
  PERFORM fieldcatalog_merge USING gt_fieldcat[]   'GT_HEAD'.

  LOOP AT gt_fieldcat.

    CASE gt_fieldcat-fieldname.
      WHEN 'KUNNR'. PERFORM header_text USING gt_fieldcat TEXT-001.
      WHEN 'STCD0'. PERFORM header_text USING gt_fieldcat TEXT-002.
      WHEN 'STCD0_NAME'.
        PERFORM header_text USING gt_fieldcat TEXT-003.
      WHEN 'STCD1'. PERFORM header_text USING gt_fieldcat TEXT-004.
      WHEN 'STCD0_NAME'.
        PERFORM header_text USING gt_fieldcat TEXT-005.
      WHEN 'NAME'.
        PERFORM header_text USING gt_fieldcat TEXT-006.
      WHEN 'NAME1'.
        PERFORM header_text USING gt_fieldcat TEXT-007.
      WHEN 'BSTKD'.
        PERFORM header_text USING gt_fieldcat TEXT-008.
      WHEN 'NETWR'.  PERFORM header_text USING gt_fieldcat TEXT-009.
      WHEN 'FKDAT'.  PERFORM header_text USING gt_fieldcat TEXT-010.
      WHEN 'KKBTX'.  PERFORM header_text USING gt_fieldcat TEXT-011.
      WHEN 'AMEND'.  PERFORM header_text USING gt_fieldcat TEXT-024.
      WHEN 'MESSAGE'. PERFORM header_text USING gt_fieldcat TEXT-025.
      WHEN 'TSTATE'.  PERFORM header_text USING gt_fieldcat TEXT-026.
      WHEN 'VBELN_OR'.
        CLEAR  gt_fieldcat-key.
      WHEN 'WAERK' .
        gt_fieldcat-no_out = 'X'.
      WHEN 'ADRNR' OR 'CUOBJ' OR 'CHKBOX' OR 'LIGHT' OR 'KKBER' OR
           'VBELN_OR' OR 'STATE' OR 'VBTYP'.
        gt_fieldcat-tech = 'X'.
    ENDCASE.

    IF sy-batch IS NOT INITIAL.

      IF gt_fieldcat-tabname = 'GT_HEAD'.
        CASE gt_fieldcat-fieldname.
          WHEN 'BUKRS' OR 'KKBER' OR 'VKORG' OR 'VTWEG' OR 'SPART' OR
               'VKBUR' OR 'VKGRP' OR 'KKBTX' .
            gt_fieldcat-tech = 'X'.
        ENDCASE.
      ENDIF.
*
    ENDIF.

    MODIFY gt_fieldcat.
  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form fieldcatalog_merge
*&---------------------------------------------------------------------*
FORM fieldcatalog_merge  USING  p_fieldcat  TYPE slis_t_fieldcat_alv
                                 p_tabname.

**
  CLEAR p_fieldcat[].

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = g_repid
      i_internal_tabname     = p_tabname  "구조생성
      i_client_never_display = 'X'
*     i_inclname             = g_inclname
      i_bypassing_buffer     = 'X'
      i_buffer_active        = ' '
    CHANGING
      ct_fieldcat            = p_fieldcat.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form header_text
*&---------------------------------------------------------------------*
FORM header_text  USING    p_fieldcat  TYPE slis_fieldcat_alv
                           p_text.

**
  p_fieldcat-reptext_ddic = p_text.
*  p_fieldcat-ddictxt = p_text.
  p_fieldcat-seltext_l = p_text.
  p_fieldcat-seltext_m = p_text.
  p_fieldcat-seltext_s = p_text.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_object
*&---------------------------------------------------------------------*
FORM create_object .

**
  CREATE OBJECT g_docking_con
    EXPORTING
*     PARENT                      =
      repid                       = g_repid
      dynnr                       = g_dynnr
      side                        =
                                    cl_gui_docking_container=>dock_at_top
      extension                   = 500
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

  CREATE OBJECT g_splitter
    EXPORTING
      parent  = g_docking_con
      rows    = 2
      columns = 1.

  CALL METHOD g_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = g_parent_head.

  CALL METHOD g_splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = g_parent_item.

  CALL METHOD g_splitter->set_row_height
    EXPORTING
      height = 60
      id     = 1.


  CREATE OBJECT g_grid_head
    EXPORTING
      i_parent = g_parent_head.

  CREATE OBJECT g_grid_item
    EXPORTING
      i_parent = g_parent_item.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
FORM set_layout .

**
  gs_layh-zebra       = 'X'  .
*  gs_layh-box_fname   = 'CHKBOX'.
  gs_layh-excp_fname  = 'LIGHT'.
  gs_layh-cwidth_opt  = 'X'  .
  gs_layh-sel_mode    = 'A'.

  gs_layi-zebra       = 'X'  .
  gs_layi-cwidth_opt  = 'X'  .

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_fieldcatalog
*&---------------------------------------------------------------------*
FORM create_fieldcatalog .

**
  PERFORM fieldcatalog_merge_cl USING gt_fieldh[] gs_layh
                                      'GT_HEAD'.

  LOOP AT gt_fieldh.
    CASE gt_fieldh-fieldname.
      WHEN 'KUNNR'. PERFORM header_text_cl USING gt_fieldh TEXT-001.
      WHEN 'STCD0'. PERFORM header_text_cl USING gt_fieldh TEXT-002.
      WHEN 'STCD0_NAME'.
        PERFORM header_text_cl USING gt_fieldh TEXT-003.
      WHEN 'STCD1'. PERFORM header_text_cl USING gt_fieldh TEXT-004.
      WHEN 'STCD0_NAME'.
        PERFORM header_text_cl USING gt_fieldh TEXT-005.
      WHEN 'NAME'.  PERFORM header_text_cl USING gt_fieldh TEXT-006.
      WHEN 'NAME1'. PERFORM header_text_cl USING gt_fieldh TEXT-007.
      WHEN 'BSTKD'. PERFORM header_text_cl USING gt_fieldh TEXT-008.
      WHEN 'NETWR'. PERFORM header_text_cl USING gt_fieldh TEXT-009.
      WHEN 'FKDAT'. PERFORM header_text_cl USING gt_fieldh TEXT-010.
      WHEN 'KKBTX'. PERFORM header_text_cl USING gt_fieldh TEXT-011.
      WHEN 'AMEND'. PERFORM header_text_cl USING gt_fieldh TEXT-024.
      WHEN 'MESSAGE'. PERFORM header_text_cl USING gt_fieldh TEXT-025.
      WHEN 'TSTATE'.PERFORM header_text_cl USING gt_fieldh TEXT-026.
      WHEN 'WAERK' .
        gt_fieldh-no_out = 'X'.
      WHEN 'ADRNR' OR 'CHKBOX' OR 'LIGHT' OR 'KKBER' OR
           'VBELN_OR' OR 'STATE' OR 'VBTYP'.
        gt_fieldh-tech = 'X'.
    ENDCASE.

    MODIFY gt_fieldh.

  ENDLOOP.

  PERFORM fieldcatalog_merge_cl USING gt_fieldi[] gs_layi
                                      'GT_ITEM'.
  LOOP AT gt_fieldi.
    CASE gt_fieldi-fieldname.
      WHEN 'KUNNR'. PERFORM header_text_cl USING gt_fieldi TEXT-001.
      WHEN 'NAME'.  PERFORM header_text_cl USING gt_fieldi TEXT-007.
      WHEN 'NAME1'. PERFORM header_text_cl USING gt_fieldi TEXT-013.
      WHEN 'BSTKD'. PERFORM header_text_cl USING gt_fieldi TEXT-008.
      WHEN 'NETWR'. PERFORM header_text_cl USING gt_fieldi TEXT-009.
      WHEN 'KKBTX'. PERFORM header_text_cl USING gt_fieldi TEXT-011.
      WHEN 'CHAR01'. PERFORM header_text_cl USING gt_fieldi TEXT-012.
      WHEN 'ARKTX'.  PERFORM header_text_cl USING gt_fieldi TEXT-014.
      WHEN 'CHAR02'. PERFORM header_text_cl USING gt_fieldi TEXT-016.
      WHEN 'CHAR03'. PERFORM header_text_cl USING gt_fieldi TEXT-017.
      WHEN 'CHAR04'. PERFORM header_text_cl USING gt_fieldi TEXT-018.
      WHEN 'CHAR05'. PERFORM header_text_cl USING gt_fieldi TEXT-019.
      WHEN 'CHAR06'. PERFORM header_text_cl USING gt_fieldi TEXT-020.
      WHEN 'CHAR07'. PERFORM header_text_cl USING gt_fieldi TEXT-021.
      WHEN 'CHAR08'. PERFORM header_text_cl USING gt_fieldi TEXT-022.
      WHEN 'PERNR'.  PERFORM header_text_cl USING gt_fieldi TEXT-023.
      WHEN 'AMEND'.  PERFORM header_text_cl USING gt_fieldi TEXT-024.
      WHEN 'MESSAGE'. PERFORM header_text_cl USING gt_fieldi TEXT-025.
      WHEN 'TSTATE'.  PERFORM header_text_cl USING gt_fieldi TEXT-026.
      WHEN 'WAERK' .
        gt_fieldi-no_out = 'X'.
      WHEN 'CUOBJ' OR 'KKBER' OR 'STATE'.
        gt_fieldi-tech = 'X'.
    ENDCASE.

    MODIFY gt_fieldi.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form fieldcatalog_merge_cl
*&---------------------------------------------------------------------*
FORM fieldcatalog_merge_cl  USING  p_fieldcat  TYPE lvc_t_fcat
                                  p_layout    TYPE lvc_s_layo
                                  p_tabname.

  DATA: lt_field_s    TYPE slis_t_fieldcat_alv WITH HEADER LINE,
        lt_table_temp TYPE slis_t_fieldcat_alv.

**
  CLEAR p_fieldcat[].

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = g_repid
      i_internal_tabname     = p_tabname
*     i_inclname             = g_inclname
    CHANGING
      ct_fieldcat            = lt_field_s[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.


  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_field_s[]
*     IT_SORT_ALV     =
*     IT_FILTER_ALV   =
*     IS_LAYOUT_ALV   =
    IMPORTING
      et_fieldcat_lvc = p_fieldcat[]
*     ET_SORT_LVC     =
*     ET_FILTER_LVC   =
*     ES_LAYOUT_LVC   =
    TABLES
      it_data         = lt_table_temp
    EXCEPTIONS
      it_data_missing = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'LVC_FIELDCAT_COMPLETE'
    EXPORTING
*     I_COMPLETE  =
*     I_REFRESH_BUFFER       =
*     I_BUFFER_ACTIVE        =
      is_layout   = p_layout
*     I_TEST      = '1'
*     I_FCAT_COMPLETE        = ABAP_FALSE
* IMPORTING
*     E_EDIT      =
*     ES_LAYOUT   =
    CHANGING
      ct_fieldcat = p_fieldcat[].

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form header_text_cl
*&---------------------------------------------------------------------*
FORM header_text_cl  USING  p_fieldcat  TYPE lvc_s_fcat
                            p_text.

**
  p_fieldcat-seltext = p_text.
  p_fieldcat-reptext = p_text.
  p_fieldcat-scrtext_l = p_text.
  p_fieldcat-scrtext_m = p_text.
  p_fieldcat-scrtext_s = p_text.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_event_receiver
*&---------------------------------------------------------------------*
FORM create_event_receiver .

**
  CREATE OBJECT g_event_receiver.
  SET HANDLER : g_event_receiver->handle_double_click  FOR g_grid_head,
                g_event_receiver->handle_user_command  FOR g_grid_head,
                g_event_receiver->handle_before_user_command
                  FOR g_grid_head,
                g_event_receiver->handle_toolbar       FOR g_grid_head.

  CALL METHOD g_grid_head->set_toolbar_interactive.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form before_user_command
*&---------------------------------------------------------------------*
FORM before_user_command  USING    p_ucomm TYPE sy-ucomm.

**
  CASE p_ucomm.
    WHEN  cl_gui_alv_grid=>mc_fc_refresh. "'&REFRESH'
      PERFORM refresh_data.
  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_selected_rows
*&---------------------------------------------------------------------*
FORM get_selected_rows .

  DATA: lt_index_rows TYPE lvc_t_row WITH HEADER LINE.

**
  REFRESH lt_index_rows.
  CALL METHOD g_grid_head->get_selected_rows
    IMPORTING
      et_index_rows = lt_index_rows[].

  IF lt_index_rows[] IS INITIAL.
*   라인을 선택하지 않았습니다.
    MESSAGE s000 WITH TEXT-e04  DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  LOOP AT lt_index_rows.
    gt_head-chkbox = 'X'.
    MODIFY gt_head  INDEX lt_index_rows-index
     TRANSPORTING chkbox   .
  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_selected_item
*&---------------------------------------------------------------------*
FORM get_selected_item .

**
  _clear gt_selt.
  LOOP AT gt_head WHERE chkbox = 'X'.

    LOOP AT gt_item WHERE bupla = gt_head-bupla
                      AND kunnr = gt_head-kunnr
                      AND vbeln = gt_head-vbeln
                      AND seqno = gt_head-seqno.
      gt_selt = gt_item.

      APPEND gt_selt. CLEAR gt_selt.
    ENDLOOP.
  ENDLOOP.

  gt_head-chkbox = ' '.
  MODIFY gt_head  TRANSPORTING chkbox
   WHERE chkbox = 'X'.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM double_click  USING    p_row
                            p_column
                            p_row_no.

**
  CLEAR gt_head.
  READ TABLE gt_head INDEX p_row.

  CASE p_column.
    WHEN 'VBELN'.
      SET PARAMETER ID 'VL'  FIELD gt_head-vbeln.
      CALL TRANSACTION 'VL02N' AND SKIP FIRST SCREEN.

    WHEN 'VBELN_OR'.
      SET PARAMETER ID 'AUN' FIELD gt_head-vbeln_or.
      CALL TRANSACTION 'VA02' AND SKIP FIRST SCREEN.

  ENDCASE.

**

ENDFORM.
