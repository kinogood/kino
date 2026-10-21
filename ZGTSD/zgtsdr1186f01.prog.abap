*&---------------------------------------------------------------------*
*& Include          ZGTSDR1186F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
FORM initialization .

  DATA: l_in   LIKE sy-datum,
        l_date LIKE p0001-begda.

**
* ALV
  g_variant-report = g_inclname = g_repid = sy-repid.
  g_variant-username = gx_variant-username = sy-uname.

  g_dynnr = '100'.

  REFRESH s_wadat. CLEAR s_wadat.
  s_wadat-sign = 'I'.
  s_wadat-option = 'EQ'.

* 전월 1일
  l_date = sy-datum.
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = l_date
      days      = '0'
      months    = '1'
      signum    = '-'
      years     = '0'
    IMPORTING
      calc_date = l_date.

  s_wadat-low = l_date.
  s_wadat-low+6(2) = '01'.

* 전월 마지막일자
  l_in = l_date.

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

  PERFORM check_zsd0013t.

  PERFORM select_kunnr.

  PERFORM data_selection.

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
*& Form check_zsd0013t
*&---------------------------------------------------------------------*
FORM check_zsd0013t .

  DATA: lr_yyyy  LIKE RANGE OF zsd0013t-zyyyymm.

**
  CHECK: gv_error  IS INITIAL,
         s_wadat[] IS NOT INITIAL.

  _clear: lr_yyyy.
  lr_yyyy = VALUE #( BASE lr_yyyy
                     FOR ls_wadat  IN s_wadat
                     ( sign   = ls_wadat-sign
                       option = ls_wadat-option
                       low    = ls_wadat-low
                       high   = ls_wadat-high ) ).

  _clear: r_bupla.
  SELECT branch AS low,
         'I'    AS sign,
         'EQ'   AS option
    FROM zsd0013t  WHERE bukrs   EQ @p_bukrs
                     AND zyyyymm IN @lr_yyyy
                     AND branch  IN @s_bupla
                     AND vtweg   EQ '10'
                     AND zmagam1 EQ 'X'
    INTO CORRESPONDING FIELDS OF TABLE @r_bupla.

  IF r_bupla[] IS INITIAL.
*   해당 사업장은 마감이 되지않았습니다. 마감 후 처리하세요.
    MESSAGE s000 WITH TEXT-e01  DISPLAY LIKE 'E'.
    gv_error = 'X'.
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

  _clear: gt_head, gt_item, gt_selt, gt_vbrk, r_state.

* 납품서, 품목 전체 정보 검색
  CASE 'X'.
    WHEN p_opt1.   "성공

      PERFORM select_history USING c_state1.

    WHEN p_opt2.   "실패

      PERFORM select_history USING c_state2.

    WHEN p_opt3.   "대상

      PERFORM select_data.

    WHEN p_opt4.   "전체

      PERFORM select_history USING ''.
*
      PERFORM select_data.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SELECT_HISTORY
*&---------------------------------------------------------------------*
FORM select_history  USING    p_state.

  DATA: l_new .
  DATA: l_seqno  LIKE zsdt0010-seqno.
  DATA: l_trano  LIKE zsdt0010-trano.

**
  CHECK: gv_error   IS INITIAL,
         gt_kunnr[] IS NOT INITIAL.

  IF p_state IS NOT INITIAL.
    r_state-sign   = 'I'.
    r_state-option = 'EQ'.
    r_state-low    = p_state.
    APPEND r_state. CLEAR r_state.
  ENDIF.

  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE gt_head
    FROM zsdt0020
     FOR ALL ENTRIES IN gt_kunnr
   WHERE kunnr      EQ gt_kunnr-kunnr
     AND wadat_ist IN s_wadat
     AND bupla     IN s_bupla
     AND vbeln     IN s_vbeln
     AND erdat     IN s_seqno
     AND gubun     IN s_gubun
     AND damb_gubn IN s_dambg
     AND state     IN r_state.

  SORT gt_head.

  LOOP AT gt_head.
    AT NEW vbeln.
      l_new = 'X'.
    ENDAT.

    IF p_ex_215 IS NOT INITIAL.
      IF l_new IS NOT INITIAL.
        CLEAR: l_new, l_seqno.
      ENDIF.

      IF gt_head-trano = c_b215.

        gt_head-chkbox = 'X'.
        MODIFY gt_head TRANSPORTING chkbox.

        READ TABLE gt_head WITH KEY vbeln = gt_head-vbeln
                                 trano = c_b211
                                 chkbox = ' '
                               TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          MODIFY gt_head INDEX sy-tabix TRANSPORTING chkbox .
        ENDIF.

        CONTINUE.

      ENDIF.
    ENDIF.

    MOVE:  p_bukrs     TO gt_head-bukrs.

    PERFORM read_kkber USING gt_head-kkber gt_head-kkbtx.  "여신영역

    PERFORM set_light USING gt_head-state gt_head-light gt_head-tstate.

    MODIFY gt_head.


    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE gt_item
      FROM zsdt0021
     WHERE bupla = gt_head-bupla
       AND kunnr = gt_head-kunnr
       AND vbeln = gt_head-vbeln
       AND seqno = gt_head-seqno.

  ENDLOOP.


  DELETE gt_head WHERE chkbox <> space.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form read_kkber
*&---------------------------------------------------------------------*
FORM read_kkber  USING    p_code
                          p_text.

**
  SELECT SINGLE kkbtx INTO p_text
   FROM t014t
  WHERE kkber = p_code
    AND spras = sy-langu.

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

  DATA: lt_temp       LIKE vbrk OCCURS 0 WITH HEADER LINE,
        lt_temp_check LIKE vbrk OCCURS 0 WITH HEADER LINE,
        l_netwr       LIKE vbrk-netwr,
        l_kunnr       LIKE vbpa-kunnr.

**
  CHECK: gv_error   IS INITIAL,
         gt_kunnr[] IS NOT INITIAL.

  _clear: lt_temp.
  SELECT r~vbeln,
         r~vkorg,
         r~vtweg,
         r~spart,
         r~kkber,
         r~bupla,
         r~fkdat,
         r~netwr,
         r~mwsbk,
         r~waerk,
         r~vbtyp,
         r~bukrs,
         r~kurrf,
         r~knkli
    INTO CORRESPONDING FIELDS OF TABLE @lt_temp
    FROM vbrk AS r
     FOR ALL ENTRIES IN @gt_kunnr
   WHERE r~vkorg EQ @gt_kunnr-bukrs
     AND r~knkli EQ @gt_kunnr-kunnr
     AND r~kkber EQ @gt_kunnr-kkber
     AND r~fkdat IN @s_wadat
     AND r~bupla IN @r_bupla
     AND r~fkart IN ('G2', 'L2', 'RE', 'S1', 'S2', 'ZCRB', 'ZDRB',
                     'ZRE3', 'ZDRM', 'F2')
     AND r~vbeln IN @s_vbeln
     AND r~rfbsk EQ 'C'
     AND r~draft EQ @space.

*^ KEY 필드 기준으로 금액 합
  _clear gt_main.

  LOOP AT lt_temp.

*- 보증서 체크 : 종료일자가 대금청구일자를 포함하는 건 체크
    LOOP AT gt_req TRANSPORTING NO FIELDS
                   WHERE kunnr = lt_temp-knkli
                     AND enddt+0(6) >= lt_temp-fkdat+0(6).
      EXIT.
    ENDLOOP.

    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

*-  금액집계
    MOVE: lt_temp-vkorg TO gt_main-vkorg,
          lt_temp-vtweg TO gt_main-vtweg,
          lt_temp-spart TO gt_main-spart,
          lt_temp-kkber TO gt_main-kkber,
          lt_temp-bupla TO gt_main-bupla,
*          lt_temp-kunag TO gt_main-kunnr,
          lt_temp-knkli TO gt_main-kunnr,
          p_bukrs       TO gt_main-bukrs,
          'KRW'         TO gt_main-waerk.  "환율로 환산하므로

    CLEAR l_kunnr.
    SELECT SINGLE kunnr INTO l_kunnr
      FROM vbpa
     WHERE vbeln = lt_temp-vbeln
       AND parvw = 'RG'.

    SELECT SINGLE taxkd INTO knvi-taxkd
      FROM knvi
     WHERE kunnr = l_kunnr.

*   부가세 포함
    IF knvi-taxkd = '1'.
      l_netwr = lt_temp-netwr + lt_temp-netwr * '0.1'.
    ELSE.
      l_netwr = lt_temp-netwr.
    ENDIF.

*   환율
    IF lt_temp-waerk <> 'KRW'.
*     공급가액
      lt_temp-netwr = lt_temp-netwr  * lt_temp-kurrf.
      lt_temp-netwr = lt_temp-netwr  / 100.
*     세액
      lt_temp-mwsbk = lt_temp-mwsbk * lt_temp-kurrf.
      lt_temp-mwsbk = lt_temp-mwsbk / 100.
*     정가
      l_netwr = l_netwr * lt_temp-kurrf.
      l_netwr = l_netwr / 100.
    ENDIF.

*  - 금액
    IF lt_temp-vbtyp = 'N' OR
       lt_temp-vbtyp = 'O'.
      gt_main-netwr = l_netwr * '-1'.
      gt_vbrk-sumwr = ( lt_temp-netwr + lt_temp-mwsbk ) * '-1'.
      gt_vbrk-netwr = lt_temp-netwr * '-1'.
      gt_vbrk-mwsbk = lt_temp-mwsbk * '-1'.
    ELSE.
      gt_main-netwr = l_netwr .
      gt_vbrk-sumwr = ( lt_temp-netwr + lt_temp-mwsbk ).
      gt_vbrk-netwr = lt_temp-netwr.
      gt_vbrk-mwsbk = lt_temp-mwsbk .
    ENDIF.

    COLLECT gt_main. CLEAR gt_main.

*- 전송대상
    MOVE: lt_temp-fkdat+0(6) TO gt_vbrk-spmon,
          lt_temp-kkber TO gt_vbrk-kkber,
          lt_temp-knkli TO gt_vbrk-kunnr,
          lt_temp-vbeln TO gt_vbrk-vbeln,

          'KRW'         TO gt_vbrk-waerk.

    APPEND gt_vbrk. CLEAR gt_vbrk.

  ENDLOOP.

*^ 데이터 구성
  LOOP AT gt_main.

*-  납품서 금액과의 차이금액
    CLEAR: gt_head, gt_item.
    PERFORM get_likp_amount USING l_netwr.

    IF gt_main-netwr = l_netwr.
      CONTINUE.
    ELSE.
      gt_main-netwr = gt_main-netwr - l_netwr.
    ENDIF.

*-  전송된 데이터 체크 및 전문번호 지정
    PERFORM check_transfer_data USING gt_main-bupla
                                      gt_main-kunnr
                                      gt_head-trano
                                      gt_head-vbeln_old
                                      gt_head-seqno_old.

    IF gt_head-trano IS INITIAL.
      CONTINUE.
    ENDIF.

    MOVE: gt_main-vkorg TO gt_head-vkorg,
          gt_main-vtweg TO gt_head-vtweg,
          gt_main-spart TO gt_head-spart,
          gt_main-kkber TO gt_head-kkber,
          gt_main-bupla TO gt_head-bupla,
          gt_main-kunnr TO gt_head-kunnr,
          gt_main-netwr TO gt_head-netwr,
          gt_main-waerk TO gt_head-waerk,
          'GUAR'        TO gt_head-gubun.

*-  전표번호 지정, 지정된 번호는 제외
    CLEAR lt_temp.
    READ TABLE lt_temp WITH KEY vkorg = gt_main-vkorg
                                vtweg = gt_main-vtweg
                                spart = gt_main-spart
                                kkber = gt_main-kkber
                                bupla = gt_main-bupla
                                knkli = gt_main-kunnr.
*                                fktyp = space.
    IF sy-subrc NE 0.
      gt_head-state = c_state3.
      gt_head-message = '유효한 전표번호를 찾지못함'.
      PERFORM set_light USING gt_head-state
                              gt_head-light
                             gt_head-tstate.
      APPEND gt_head.
      CONTINUE.
    ENDIF.

    MOVE: lt_temp-fkdat      TO gt_head-wadat_ist,
          lt_temp-fkdat+0(4) TO gt_head-mjahr,
          lt_temp-vbeln      TO gt_head-vbeln.

    SELECT SINGLE belnr INTO gt_head-mblnr
      FROM bkpf
     WHERE bukrs = gt_head-vkorg
       AND belnr = gt_head-vbeln
       AND gjahr = lt_temp-fkdat+0(4).

    PERFORM calc_fkdat USING lt_temp-fkdat
                             gt_head-fkdat.

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
                             gt_head-stcd1_name gt_head-name1
                             gt_head-adrnr.
    APPEND gt_head.


*   차이금액 기준으로 공급가액 및 세액 구하기
    IF lt_temp-taxk1 = 1.
      gt_item-hwbas = gt_main-netwr / 11.
      gt_item-hwste = gt_main-netwr - gt_item-hwste.
    ELSE.
      gt_item-hwbas = gt_main-netwr.
      gt_item-hwste = 0.
    ENDIF.

    MOVE: gt_main-bupla TO gt_item-bupla,
          gt_main-kunnr TO gt_item-kunnr,
          '000000'      TO gt_item-posnr,
          1             TO gt_item-lfimg,
          'M'           TO gt_item-vrkme,
          '0.01'        TO gt_item-netpr,
          lt_temp-vbeln TO gt_item-vbeln,
          gt_main-netwr TO gt_item-netwr,
          gt_main-waerk TO gt_item-waerk,
          '000000'      TO gt_item-posnr_or.

    CONCATENATE lt_temp-fkdat+0(6) '정산' INTO gt_item-matnr
      SEPARATED BY space.

    DATA : lt_matnr(18).
    CLEAR : lt_matnr.

    lt_matnr = CONV matnr18( gt_item-matnr ).

    CONCATENATE lt_matnr gt_main-kunnr
          INTO gt_item-arktx SEPARATED BY space.
*<-

    APPEND gt_item.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_likp_amount
*&---------------------------------------------------------------------*
FORM get_likp_amount  USING    p_netwr.

  DATA: lt_likp  LIKE zsdt0010 OCCURS 0 WITH HEADER LINE.
  DATA: l_end .

**
  _clear lt_likp.
  SELECT * INTO TABLE lt_likp
    FROM zsdt0010
   WHERE bupla = gt_main-bupla
     AND kunnr = gt_main-kunnr
     AND bukrs = gt_main-bukrs
     AND vkorg = gt_main-vkorg
     AND vtweg = gt_main-vtweg
     AND spart = gt_main-spart
     AND kkber = gt_main-kkber
     AND wadat_ist IN s_wadat.

  SORT lt_likp BY vbeln ASCENDING
                  seqno DESCENDING.  "마지막 순번이 위로

  CLEAR p_netwr.

  LOOP AT lt_likp.

    IF l_end IS INITIAL AND
      lt_likp-state = c_state1.

      CASE lt_likp-trano .
        WHEN c_b215.          "취소된 건 무시
          l_end = 'X'.

        WHEN c_b213.

          IF lt_likp-mblnr IS INITIAL.    "취소
            gt_b215 = lt_likp.
            gt_b215-trano = c_b215.
            APPEND gt_b215. CLEAR gt_b215.

            l_end = 'X'.
          ELSE.

            p_netwr = p_netwr + lt_likp-netwr.
            l_end = 'X'.
          ENDIF.

        WHEN c_b211.
          p_netwr = p_netwr + lt_likp-netwr.

          l_end = 'X'.
      ENDCASE.

      IF l_end IS INITIAL.
        SELECT SINGLE * FROM likp
         WHERE vbeln = lt_likp-vbeln.

        IF sy-subrc NE 0.
          l_end = 'X'.
        ENDIF.
      ENDIF.

    ENDIF.

    AT END OF vbeln.
      CLEAR l_end.
    ENDAT.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_transfer_data
*&---------------------------------------------------------------------*
FORM check_transfer_data  USING    p_bupla
                                   p_kunnr
                                   p_trano
                                   p_vbeln_old
                                   p_seqno_old.

  DATA: lt_old   LIKE zsdt0020 OCCURS 0 WITH HEADER LINE.
  DATA: lt_tmp   LIKE zsdt0020 OCCURS 0 WITH HEADER LINE.

**
  _clear lt_old.
  SELECT  * INTO TABLE lt_old
    FROM zsdt0020
   WHERE bupla = p_bupla
     AND kunnr = p_kunnr
     AND vkorg = gt_main-vkorg
     AND vtweg = gt_main-vtweg
     AND spart = gt_main-spart
     AND kkber = gt_main-kkber
     AND wadat_ist IN s_wadat
     ORDER BY vbeln seqno.

  lt_tmp[] = lt_old[].

  LOOP AT lt_tmp WHERE trano = c_b215
                   AND state = c_state1.

    READ TABLE lt_old WITH KEY vbeln = lt_tmp-vbeln
                               trano = c_b211
                             TRANSPORTING NO FIELDS.

    IF sy-subrc = 0.
      DELETE lt_old INDEX sy-tabix.
    ENDIF.

    DELETE lt_old WHERE vbeln = lt_tmp-vbeln
                     AND seqno = lt_tmp-seqno
                     AND trano = c_b215.

  ENDLOOP.

  SORT lt_old BY seqno DESCENDING.
  READ TABLE lt_old INDEX 1.

  IF lt_old-state = c_state1.
    IF gt_main-netwr = lt_old-netwr.
*      CONTINUE.
    ELSE.
      p_vbeln_old = lt_old-vbeln.
      p_seqno_old = lt_old-seqno.
      p_trano = c_b211.
    ENDIF.
  ELSE.
    p_trano = c_b211.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form calc_fkdat
*&---------------------------------------------------------------------*
FORM calc_fkdat  USING    p_indat
                          p_otdat.

  DATA: l_in LIKE sy-datum.

**
  l_in = p_indat.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = l_in
    IMPORTING
      last_day_of_month = l_in
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  p_otdat = l_in + 90.

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
                          p_name1
                          p_adrnr.

**
  SELECT SINGLE stcd1 stcd2 name1 adrnr
    INTO (p_stcd1, p_stcd2, p_name1, p_adrnr)
    FROM kna1
   WHERE kunnr = p_kunnr.

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

  DATA: lt_temp   LIKE gt_head  OCCURS 0 WITH HEADER LINE.
  DATA: lt_item   LIKE zsds0021 OCCURS 0 WITH HEADER LINE.
  DATA: ls_temp   LIKE gt_head.

  DATA: l_subrc   LIKE sy-subrc.

  DATA : dest_name LIKE zifdest-dest.

**
  CLEAR : dest_name.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'SD'
    IMPORTING
      dest_name             = dest_name
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.

  READ TABLE gt_head WITH KEY chkbox = 'X'.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

* Synchronous call to function module RFC_SYSTEM_INFO
  CALL FUNCTION 'RFC_SYSTEM_INFO'
    DESTINATION dest_name
*    DESTINATION ztstig0-eaidest
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

  CHECK lt_temp[] IS NOT INITIAL.

*^ 데이터 전송
  LOOP AT lt_temp.

*-  이전 건 취소
    IF gt_head-seqno_old IS NOT INITIAL.

      SELECT SINGLE * FROM zsdt0020
       WHERE bupla = lt_temp-bupla
         AND kunnr = lt_temp-kunnr
         AND vbeln = lt_temp-vbeln_old
         AND seqno = lt_temp-seqno_old
         AND state = c_state1.

      CLEAR l_subrc.
      REFRESH lt_item. CLEAR lt_item.
      MOVE-CORRESPONDING zsdt0020 TO ls_temp.
      ls_temp-trano = c_b215.

      PERFORM if_header_data USING ls_temp
                                   l_subrc.


      IF l_subrc EQ 0.
        COMMIT WORK.
        PERFORM call_function  TABLES lt_item.

      ENDIF.
    ENDIF.

*- 신규
    IF l_subrc EQ 0.

      CLEAR l_subrc.
      PERFORM if_header_data USING lt_temp
                                   l_subrc.


      IF l_subrc EQ 0 AND
         gt_head-trano <> c_b215.   "취소는 ITEM 정보안보냄

        PERFORM if_item_data  TABLES lt_item
                               USING lt_temp
                                   l_subrc.

      ENDIF.

      IF l_subrc EQ 0.
        COMMIT WORK.
        PERFORM call_function  TABLES lt_item.

        gt_head-seqno = zsdt0020-seqno.
        gt_head-state = zsdt0020-state.
        gt_head-message = zsdt0020-message.

        PERFORM set_light USING gt_head-state gt_head-light
                                gt_head-tstate.

        MODIFY gt_head TRANSPORTING seqno state message light tstate
         WHERE bupla = lt_temp-bupla
           AND kunnr = lt_temp-kunnr
           AND vbeln = lt_temp-vbeln
           AND seqno = lt_temp-seqno.
      ENDIF.

    ENDIF.
  ENDLOOP.

*^ 매매계약서 취소건 전송
  LOOP AT gt_b215.

    PERFORM process_contract USING gt_b215.

    MOVE-CORRESPONDING gt_b215 TO gt_head.
    APPEND gt_head. CLEAR gt_head.
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
FORM check_data  TABLES   pt_temp STRUCTURE gt_head   .

  DEFINE modify_state.
    gt_head-state = c_state3.
    gt_head-message = &1.
    PERFORM set_light USING gt_head-state gt_head-light gt_head-tstate.
    MODIFY gt_head.
  END-OF-DEFINITION.

  DATA: l_answer.

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
          REFRESH pt_temp. CLEAR pt_temp.
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
      SELECT SINGLE seqno INTO zsdt0020-seqno
        FROM zsdt0020
       WHERE bupla = gt_head-bupla
         AND kunnr = gt_head-kunnr
         AND vbeln = gt_head-vbeln
         AND trano = c_b211.

      IF sy-subrc EQ 0.
        IF sy-subrc NE 0.
          CONCATENATE 'SEQNO' zsdt0020-seqno
                '로 B211 전문이 전송된 상태입니다.'
           INTO gt_head-message
            SEPARATED BY space.

          modify_state gt_head-message.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

    IF gt_head-vbeln IS INITIAL.
      modify_state '전표번호 오류'.
      CONTINUE.
    ENDIF.

    IF gt_head-netwr = 0.
      modify_state  '금액오류'.
      CONTINUE.
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
      text_option1  = '전체무시'
      text_option2  = '예'
      titel         = '전송상태확인'
    IMPORTING
      answer        = p_answer.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form IF_HEADER_DATA
*&---------------------------------------------------------------------*
FORM if_header_data  USING    ps_temp  LIKE gt_head
                              p_subrc.

**
  CLEAR zsdt0020.
  MOVE-CORRESPONDING ps_temp TO zsdt0020.

*   일련번호
  zsdt0020-seqno = g_seqno.

  zsdt0020-erdat = g_seqno+0(8).
  zsdt0020-erzet = g_seqno+8(6).
  zsdt0020-ernam = sy-uname.

  INSERT zsdt0020.

  p_subrc = sy-subrc.

  CHECK sy-subrc EQ 0.

  CLEAR zsds0020.
  MOVE-CORRESPONDING zsdt0020 TO zsds0020.

  zsds0020-kunnr = |{ zsds0020-kunnr ALPHA = OUT }|.
*  PERFORM CONV_ALPHA_OUTPUT USING ZSDS0020-KUNNR.

*    금액
  PERFORM convert_amount USING zsdt0020-waerk
                               zsdt0020-netwr
                               zsds0020-netwr.

*- 전송대상

  SELECT SINGLE * FROM zsdt0022
   WHERE spmon = zsdt0020-wadat_ist+0(6)
     AND kkber = zsdt0020-kkber
     AND kunnr = zsdt0020-kunnr.

  IF sy-subrc EQ 0.
    DELETE FROM zsdt0022 WHERE spmon = zsdt0020-wadat_ist+0(6)
                           AND kkber = zsdt0020-kkber
                           AND kunnr = zsdt0020-kunnr.
    p_subrc = sy-subrc.

    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
  ENDIF.

  CASE zsdt0020-trano.
    WHEN c_b211.
      LOOP AT gt_vbrk WHERE spmon = zsdt0020-wadat_ist+0(6)
                        AND kkber = zsdt0020-kkber
                        AND kunnr = zsdt0020-kunnr.

        MOVE-CORRESPONDING gt_vbrk TO zsdt0022.
        INSERT zsdt0022.

        p_subrc = sy-subrc.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
      ENDLOOP.

    WHEN c_b215.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form CONVERT_AMOUNT
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
*& Form CALL_FUNCTION
*&---------------------------------------------------------------------*
FORM call_function  TABLES pt_item  STRUCTURE zsds0021.

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


  CALL FUNCTION 'Z_SD_IF_ADJCONTRACT'
*    DESTINATION ztstig0-eaidest
    DESTINATION dest_name
    EXPORTING
      i_head    = zsds0020
    IMPORTING
      e_result  = l_result
      e_message = l_message
    TABLES
      it_item   = pt_item
    EXCEPTIONS
      OTHERS    = 1.

*  l_result = '00'.
*  l_message = 'TEST'.

*^    전송결과
  zsdt0020-state   = l_result.
  zsdt0020-message = l_message.
  MODIFY zsdt0020.



  DATA: zsdt9000 TYPE zsdt9000.
  CLEAR: zsdt9000.

  zsdt9000-zfunc = 'Z_SD_IF_ADJCONTRACT'.
  zsdt9000-pgmnm = sy-repid.
  zsdt9000-erdat = sy-datlo.
  zsdt9000-erzet = sy-timlo.
  zsdt9000-ernam = sy-uname.
  zsdt9000-zrslt = l_result.
  zsdt9000-zrtxt = l_message.

  MODIFY zsdt9000 FROM zsdt9000.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form if_item_data
*&---------------------------------------------------------------------*
FORM if_item_data  TABLES pt_item  STRUCTURE zsds0021
                    USING    ps_temp   LIKE gt_head
                            p_subrc.

**
  REFRESH pt_item. CLEAR pt_item.
  LOOP AT gt_item WHERE bupla = ps_temp-bupla
                    AND kunnr = ps_temp-kunnr
                    AND vbeln = ps_temp-vbeln
                    AND seqno = ps_temp-seqno.

    CLEAR zsdt0021.
    MOVE-CORRESPONDING gt_item TO zsdt0021.

*   일련번호
    zsdt0021-seqno = g_seqno.

    zsdt0021-erdat = g_seqno+0(8).
    zsdt0021-erzet = g_seqno+8(6).
    zsdt0021-ernam = sy-uname.

    INSERT zsdt0021.

    IF sy-subrc NE 0.
      p_subrc = sy-subrc.
      EXIT.
    ENDIF.

    MOVE-CORRESPONDING zsdt0021 TO pt_item.

    IF zsdt0021-hwste IS INITIAL.
      pt_item-hwste = '0'.
    ENDIF.

    pt_item-kunnr = |{ pt_item-kunnr ALPHA = OUT }|.
*    PERFORM CONV_ALPHA_OUTPUT USING PT_ITEM-KUNNR.

*    금액
    PERFORM convert_amount USING zsdt0021-waerk
                                 zsdt0021-netpr
                                 pt_item-netpr.

    PERFORM convert_amount USING zsdt0021-waerk
                                 zsdt0021-hwbas
                                  pt_item-hwbas.

    PERFORM convert_amount USING zsdt0021-waerk
                                 zsdt0021-hwste
                                  pt_item-hwste.

    PERFORM convert_amount USING zsdt0021-waerk
                                 zsdt0021-netwr
                                  pt_item-netwr.

    APPEND pt_item. CLEAR pt_item.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form process_contract
*&---------------------------------------------------------------------*
FORM process_contract  USING    ps_head  LIKE zsdt0010.

  DATA: lt_item1  LIKE zsds0011 OCCURS 0 WITH HEADER LINE.
  DATA: l_result  TYPE char2,
        l_message TYPE char100.

  DATA : dest_name LIKE zifdest-dest.

**
  CLEAR zsdt0010.
  MOVE-CORRESPONDING ps_head TO zsdt0010.

*   일련번호
  zsdt0010-seqno = g_seqno.

  zsdt0010-erdat = g_seqno+0(8).
  zsdt0010-erzet = g_seqno+8(6).
  zsdt0010-ernam = sy-uname.

  INSERT zsdt0010.

  IF sy-subrc EQ 0.
    COMMIT WORK.

    CLEAR zsds0010.
    MOVE-CORRESPONDING zsdt0010 TO zsds0010.

    zsds0010-kunnr = |{ zsds0010-kunnr ALPHA = OUT }|.
*    PERFORM conv_alpha_output USING zsds0010-kunnr.

*    금액
    PERFORM convert_amount USING zsdt0010-waerk
                                 zsdt0010-netwr
                                 zsds0010-netwr.

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
*      DESTINATION ztstig0-eaidest
      DESTINATION dest_name
      EXPORTING
        i_head    = zsds0010
      IMPORTING
        e_result  = l_result
        e_message = l_message
      TABLES
        it_item   = lt_item1
      EXCEPTIONS
        OTHERS    = 1.

*^    전송결과
    zsdt0010-state   = l_result.
    zsdt0010-message = l_message.
    MODIFY zsdt0010.

    ps_head-seqno = zsdt0010-seqno.
    ps_head-state = l_result.
    ps_head-message = l_message.


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

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form refresh_data
*&---------------------------------------------------------------------*
FORM refresh_data .

**
  _clear: gt_head, gt_item, gt_selt, gt_vbrk, r_state.

* 납품서, 품목 전체 정보 검색
  CASE 'X'.
    WHEN p_opt1.   "성공

      PERFORM select_history USING c_state1.

    WHEN p_opt2.   "실패

      PERFORM select_history USING c_state2.

    WHEN p_opt3.   "대상

      PERFORM select_data.

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
*     i_callback_pf_status_set = 'PF_STATUS_SET'
*     i_callback_user_command  = 'USER_COMMAND'
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
           'VBELN_OR' OR 'STATE' OR 'VBTYP' OR 'SEQNO_OLD' OR
           'VBELN_OLD'.
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
*& Form FIELDCATALOG_MERGE
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
*     I_INCLNAME             = G_INCLNAME
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
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
FORM create_object .

**
  CREATE OBJECT g_docking_con
    EXPORTING
*     PARENT                      =
      repid                       = g_repid
      dynnr                       = g_dynnr
      side                        = cl_gui_docking_container=>dock_at_top
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
*& Form SET_LAYOUT
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
*& Form CREATE_FIELDCATALOG
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
           'VBELN_OR' OR 'STATE' OR 'VBTYP' OR 'SEQNO_OLD' OR
           'VBELN_OLD'.
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
*& Form FIELDCATALOG_MERGE_CL
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
*     I_INCLNAME             = G_INCLNAME
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
*& Form HEADER_TEXT_CL
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
*& Form CREATE_EVENT_RECEIVER
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

**
  DATA: lt_index_rows TYPE lvc_t_row WITH HEADER LINE.

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
  REFRESH gt_selt. CLEAR gt_selt.
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
*& Form disp_zsdt0022_data
*&---------------------------------------------------------------------*
FORM disp_zsdt0022_data .

  DATA: LT_VBRK   LIKE ZSDT0022 OCCURS 0 WITH HEADER LINE.
  DATA: LT_FIELDCAT  TYPE SLIS_T_FIELDCAT_ALV    WITH HEADER LINE.

**
  REFRESH LT_VBRK. CLEAR LT_VBRK.
  LOOP AT GT_HEAD WHERE CHKBOX = 'X'.

    LOOP AT GT_VBRK WHERE SPMON = GT_HEAD-WADAT_IST+0(6)
                      AND KKBER = GT_HEAD-KKBER
                      AND KUNNR = GT_HEAD-KUNNR.

      LT_VBRK = GT_VBRK.
      APPEND LT_VBRK. CLEAR LT_VBRK.
    ENDLOOP.

    IF SY-SUBRC NE 0.
      SELECT * FROM ZSDT0022
      APPENDING CORRESPONDING FIELDS OF TABLE LT_VBRK
       WHERE SPMON = GT_HEAD-WADAT_IST+0(6)
         AND KKBER = GT_HEAD-KKBER
         AND KUNNR = GT_HEAD-KUNNR.
    ENDIF.
  ENDLOOP.

  GT_HEAD-CHKBOX = ' '.
  MODIFY GT_HEAD  TRANSPORTING CHKBOX
   WHERE CHKBOX = 'X'.

  IF LT_VBRK[] IS INITIAL.
*   대상데이터를 검색하지 못했습니다.
    MESSAGE S000 WITH text-e05  DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM FIELDCATALOG_MERGE USING LT_FIELDCAT[]   'LT_VBRK'.

  LOOP AT LT_FIELDCAT.
    CASE LT_FIELDCAT-FIELDNAME.
      WHEN 'SUMWR'.
        PERFORM HEADER_TEXT USING LT_FIELDCAT TEXT-031.
        LT_FIELDCAT-CFIELDNAME = 'WAERK'.
        LT_FIELDCAT-DO_SUM = 'X'.
      WHEN 'NETWR'.

        PERFORM HEADER_TEXT USING LT_FIELDCAT TEXT-032.
        LT_FIELDCAT-CFIELDNAME = 'WAERK'.
        LT_FIELDCAT-DO_SUM = 'X'.
      WHEN 'MWSBK'.
        PERFORM HEADER_TEXT USING LT_FIELDCAT TEXT-033.
        LT_FIELDCAT-CFIELDNAME = 'WAERK'.
        LT_FIELDCAT-DO_SUM = 'X'.
      WHEN 'SPMON'. PERFORM HEADER_TEXT USING LT_FIELDCAT TEXT-034.
    ENDCASE.
    MODIFY LT_FIELDCAT.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      I_TITLE               = '전송대상데이터'
      I_SELECTION           = ' '
      I_ZEBRA               = 'X'
      I_SCREEN_START_COLUMN = 5
      I_SCREEN_START_LINE   = 5
      I_SCREEN_END_COLUMN   = 120
      I_SCREEN_END_LINE     = 20
      I_TABNAME             = 'LT_VBRK'
      IT_FIELDCAT           = LT_FIELDCAT[]
    TABLES
      T_OUTTAB              = LT_VBRK
    EXCEPTIONS
      PROGRAM_ERROR         = 1
      OTHERS                = 2.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
FORM double_click  USING    P_ROW
                            P_COLUMN
                            P_ROW_NO.

**
  CLEAR GT_HEAD.
  READ TABLE GT_HEAD INDEX P_ROW.

**

ENDFORM.
