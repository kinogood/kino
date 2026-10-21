*&---------------------------------------------------------------------*
*& Include          ZGTPPI2010F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_screen_attribute
*&---------------------------------------------------------------------*
FORM set_screen_attribute .
  LOOP AT SCREEN.

    IF p_r1 = 'X'. "전송

      IF "screen-name = 'S_WERKS-LOW' OR
        screen-name = 'P_WERKS' OR
        screen-name = 'S_ERDAT-LOW'.
        screen-required = 2.
      ENDIF.

    ELSEIF p_r2 = 'X'. "로그 조회

      IF" screen-name = 'S_WERKS-LOW' OR
       screen-name = 'P_WERKS' OR
       screen-name = 'S_IFDAT-LOW'.
        screen-required = 2.
      ENDIF.

    ENDIF.

    IF screen-group1 = 'DS1'.

      IF p_r1 = 'X'. "전송
        screen-active       = 1.
      ELSE.
        screen-active       = 0.
      ENDIF.

    ELSEIF screen-group1 = 'DS2'.

      IF p_r2 = 'X'. "로그 조회
        screen-active       = 1.
      ELSE.
        screen-active       = 0.
      ENDIF.

    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_display_condition
*&---------------------------------------------------------------------*
FORM check_display_condition .

  CLEAR gv_error.

  CHECK p_r8 IS INITIAL.

  IF p_r1 = 'X'. "전송

*    IF s_erdat[] IS INITIAL.
*
*      gv_error = 'X'.
*      MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-m01.
*
*    ENDIF.

  ELSE. "로그 조회

    IF "s_werks[] IS INITIAL
      p_werks IS INITIAL
      OR s_ifdat[] IS INITIAL.

      gv_error = 'X'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-m01.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data .

  IF p_r1 = 'X'. "전송
* 선택한 송신 대상 시스템에 따라 조회 조건 플랜트 필터링
    PERFORM filter_werks.
* 전송 대상 플랜트가 없을 경우 데이터 취합하지 말 것
    CHECK gr_werks[] IS NOT INITIAL.
* 걸러진 필터값으로 데이터 취합
    PERFORM get_prod_order.
  ELSE. "로그 조회
    PERFORM get_prod_order_send_log.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form filter_werks
*&---------------------------------------------------------------------*
FORM filter_werks .

  CLEAR : gr_werks, gr_werks[], gr_dispo, gr_dispo[], gt_zgtppt1010, gt_zgtppt1010[].
  gt_zgtppt1010 = zgtpp_cl_common=>get_code_value( iv_module_kind = 'PP'        " 모듈 코드
                                                   iv_codegrp     = '0010' ).   " 코드 그룹
*- Start 2024.11.25
  CASE abap_true.
    WHEN p_r3. "지중 MES
      DELETE gt_zgtppt1010 WHERE fld_03 NE '1302'.
    WHEN p_r4. "부스닥트 MES
      DELETE gt_zgtppt1010 WHERE fld_03 NE '1306'.
    WHEN p_r9. ""소재 MOM SRM2510-04825
      DELETE gt_zgtppt1010 WHERE fld_03 NE '1305'.
    WHEN p_r10. "가온 전력 MES
      DELETE gt_zgtppt1010 WHERE fld_03 NE '6500'.
    WHEN p_r11. "가온 통신 MES.
      DELETE gt_zgtppt1010 WHERE fld_03 NE '6600'.
    WHEN p_r12. "한미소 MOM 260828
      DELETE gt_zgtppt1010 WHERE fld_03 NE '7501'.
  ENDCASE.

  LOOP AT gt_zgtppt1010 INTO DATA(ls_zgtppt1010).
    gr_werks-sign = 'I'.
    gr_werks-option = 'EQ'.
    gr_werks-low = ls_zgtppt1010-fld_03.
    APPEND gr_werks.

    gr_dispo-sign = 'I'.
    gr_dispo-option = 'CP'.
    CONCATENATE ls_zgtppt1010-fld_04 '*' INTO gr_dispo-low.
    APPEND gr_dispo.
  ENDLOOP.

  SORT : gr_dispo, gr_werks BY low.
  DELETE ADJACENT DUPLICATES FROM : gr_dispo, gr_werks COMPARING low.

*  SELECT werks AS low FROM t001w
*   INTO CORRESPONDING FIELDS OF TABLE gr_werks
*  WHERE werks IN s_werks.
*
*  IF gr_werks[] IS INITIAL.
*
*    MESSAGE s003 DISPLAY LIKE 'E' WITH '전송대상 플랜트가 아닙니다.'.
*    LEAVE TO LIST-PROCESSING.
*
*  ELSE.

*    LOOP AT gr_werks ASSIGNING FIELD-SYMBOL(<ls_werks>).
*      READ TABLE gt_zgtppt1010 TRANSPORTING NO FIELDS WITH KEY fld_03 = <ls_werks>-low.
*      IF sy-subrc EQ 0.
*        <ls_werks>-sign = 'I'.
*        <ls_werks>-option = 'EQ'.
*      ELSE.
*        DELETE gr_werks.
*      ENDIF.
*    ENDLOOP.
*
*    IF gr_werks[] IS  INITIAL.
*      MESSAGE s003 DISPLAY LIKE 'E' WITH '전송대상 플랜트가 아닙니다.'.
*      LEAVE TO LIST-PROCESSING.
*    ENDIF.

*  ENDIF.
*- End 2024.11.25
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_prod_order
*&---------------------------------------------------------------------*
FORM get_prod_order .

* 생산오더 헤더 정보 취합
  PERFORM get_prod_order_header.

* 생산오더 아이템 정보 취합
  PERFORM get_prod_order_item.

* 생산오더 공정 정보 취합
  PERFORM get_prod_routing.

* 생산오더 BOM 정보 취합
  PERFORM get_prod_bom.

* 생산오더 특성 정보 취합
  PERFORM get_prod_char.

*// Modified by ZGODEV06 on 2026-01-21 {
*// 가온 전선 랜 케이블 시판 "계획 오더" 추출 추가.
  PERFORM get_additional_data.
*// }

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_conversion
*&---------------------------------------------------------------------*
FORM data_conversion USING pv_aufnr pv_vornr pv_posnr pv_matnr pv_plnfl
                                                 pv_rsnum pv_rspos pv_sign.

  IF pv_sign = '-'.
* 생산오더번호
    IF pv_aufnr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = pv_aufnr
        IMPORTING
          output = pv_aufnr.
    ENDIF.
* 작업/액티비티
    IF pv_vornr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = pv_vornr
        IMPORTING
          output = pv_vornr.
    ENDIF.
* 오더품목번호
    IF pv_posnr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = pv_posnr
        IMPORTING
          output = pv_posnr.
    ENDIF.
* 품목코드
    IF pv_matnr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input  = pv_matnr
        IMPORTING
          output = pv_matnr.
    ENDIF.
* 작업순서
    IF pv_plnfl IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = pv_plnfl
        IMPORTING
          output = pv_plnfl.
    ENDIF.
* 예약 번호
    IF pv_rsnum IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = pv_rsnum
        IMPORTING
          output = pv_rsnum.
    ENDIF.
* 예약 품목 번호
    IF pv_rsnum IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = pv_rspos
        IMPORTING
          output = pv_rspos.
    ENDIF.

  ELSE.
* 생산오더번호
    IF pv_aufnr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = pv_aufnr
        IMPORTING
          output = pv_aufnr.
    ENDIF.
* 작업/액티비티
    IF pv_vornr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = pv_vornr
        IMPORTING
          output = pv_vornr.
    ENDIF.
* 오더품목번호
    IF pv_posnr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = pv_posnr
        IMPORTING
          output = pv_posnr.
    ENDIF.
* 품목코드
    IF pv_matnr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input  = pv_matnr
        IMPORTING
          output = pv_matnr.
    ENDIF.
* 작업순서
    IF pv_plnfl IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = pv_plnfl
        IMPORTING
          output = pv_plnfl.
    ENDIF.
* 예약 번호
    IF pv_rsnum IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = pv_rsnum
        IMPORTING
          output = pv_rsnum.
    ENDIF.
* 예약 품목 번호
    IF pv_rsnum IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = pv_rspos
        IMPORTING
          output = pv_rspos.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_prod_order_header
*&---------------------------------------------------------------------*
FORM get_prod_order_header .

  DATA : lv_status TYPE char100.

*// Modified by ZGODEV06 on 2026-01-21 {
* SELECT DISTINCT c~werks, c~auart, c~kdauf, c~kdpos, c~objnr,
*                          c~loekz, c~zzpriority, c~zzorigin, c~zzfollowing,

  SELECT DISTINCT c~werks, c~auart, c~objnr,
                  c~loekz, c~zzpriority, c~zzorigin, c~zzfollowing,
                  c~zzbundle, c~zzposnr, c~zzkdauf, c~zzkdpos,
*// }
        a~aufnr, a~dispo, a~fevor, a~gamng, a~gasmg, a~gmein, a~sbmng,
        a~sbmeh, a~gstrp, a~gltrp, a~gstrs, a~gsuzs, a~gltrs, a~gluzs,
        a~aufpl, a~cuobj
*       b~posnr, b~matnr, b~charg, b~verid, b~lgort, b~elikz, b~uebto, b~uebtk,
*       b~psamg, b~psmng
    INTO TABLE @DATA(lt_prod_head)
    FROM afko AS a  INNER JOIN aufk AS c  ON a~aufnr EQ c~aufnr
                    INNER JOIN jcds AS d  ON c~objnr EQ d~objnr
*                    INNER JOIN resb AS e  ON a~rsnum EQ e~rsnum
   WHERE c~werks IN @gr_werks "c~werks IN @s_werks "플랜트 "2024.11.25
     AND c~auart IN @s_auart "생산오더유형
     AND c~auart IN ( 'PP01', 'PP05', 'RW01', 'RP01', 'PP04', 'PL01' ) "생산오더유형
     AND a~aufnr IN @s_aufnr "생산오더번호
     AND a~plnbez IN @s_matnr "품목코드
     AND a~gstrp IN @s_gstrp "생산시작일자
     AND a~dispo IN @gr_dispo "2024.11.25
     AND c~erdat IN @s_erdat "오더생성일자
     AND d~inact EQ @space
     AND d~udate IN @s_udate
     AND d~utime IN @s_utime.

*** START 2026.07.01 bt ZGISPP03
  IF sy-batch = 'X'
    AND ( sy-slset = '6500_GP_BATCH' OR sy-slset = '6600_GO_BATCH' ).
    CLEAR : s_udate, s_utime, s_udate[], s_utime[].
    PERFORM get_so_date_time TABLES s_udate
                                                            s_utime.

    SELECT DISTINCT c~werks, c~auart, c~objnr,
                    c~loekz, c~zzpriority, c~zzorigin, c~zzfollowing,
                    c~zzbundle, c~zzposnr, c~zzkdauf, c~zzkdpos,
          a~aufnr, a~dispo, a~fevor, a~gamng, a~gasmg, a~gmein, a~sbmng,
          a~sbmeh, a~gstrp, a~gltrp, a~gstrs, a~gsuzs, a~gltrs, a~gluzs,
          a~aufpl, a~cuobj
      APPENDING CORRESPONDING FIELDS OF TABLE @lt_prod_head
      FROM afko AS a  INNER JOIN aufk AS c  ON a~aufnr EQ c~aufnr
                      INNER JOIN jcds AS d  ON c~objnr EQ d~objnr
*                      INNER JOIN resb AS e  ON a~rsnum EQ e~rsnum
     WHERE c~werks IN @gr_werks "c~werks IN @s_werks "플랜트 "2024.11.25
       AND c~auart IN @s_auart "생산오더유형
       AND c~auart IN ( 'PP01', 'PP05', 'RW01', 'RP01', 'PP04', 'PL01' ) "생산오더유형
       AND a~aufnr IN @s_aufnr "생산오더번호
       AND a~plnbez IN @s_matnr "품목코드
       AND a~gstrp IN @s_gstrp "생산시작일자
       AND a~dispo IN @gr_dispo "2024.11.25
       AND c~erdat IN @s_erdat "오더생성일자
       AND d~inact EQ @space
       AND d~udate IN @s_udate
       AND d~utime IN @s_utime.
  ENDIF.
*** END 2026.07.01 bt ZGISPP03

*- 생산 오더 아이템 취합용 데이터
  IF lt_prod_head[] IS NOT INITIAL.
    CLEAR: gt_afpo.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_afpo
      FROM afpo
       FOR ALL ENTRIES IN @lt_prod_head
     WHERE aufnr EQ @lt_prod_head-aufnr.

    SORT gt_afpo BY aufnr posnr.

*// Modified by ZGODEV06 on 2026-01-21 {
*// Modified by ZGSIDEV07 on 2026-07-08 { 포장재 정보 추가 matnr_dm 이후공정 오더 타입 dmordty - 포장재 전송대상 확인용
    SELECT ordnr, posnr, dmord, dmline, grpnr, inlength, infactor, clength, slength, elength, adlength, dmordty, matnr_dm
      FROM @lt_prod_head AS zt01
      JOIN zgtppt2010    AS zt02
        ON zt01~aufnr EQ zt02~ordnr
     ORDER BY ordnr, posnr
      INTO CORRESPONDING FIELDS OF TABLE @gt_zgtppt2010.

    SELECT zt02~ordnr, zt02~posnr, zt02~adlength, zt02~zcage, zt02~zwseq, zt02~ycoef
      FROM @lt_prod_head AS zt01
      JOIN zgtppt2012    AS zt02
        ON zt01~aufnr EQ zt02~ordnr
     ORDER BY ordnr, posnr
      INTO CORRESPONDING FIELDS OF TABLE @gt_zgtppt2012.

    SELECT zt02~aufnr, zt02~pdcaproccode
      FROM @lt_prod_head     AS zt01
      JOIN zgtpp_cv_ordsyval AS zt02
        ON zt01~aufnr EQ zt02~aufnr
     ORDER BY zt02~aufnr
      INTO CORRESPONDING FIELDS OF TABLE @gt_zgtcvordsyval.

    SELECT vbak~vbeln, vbak~vkorg, vbak~vkgrp, vbkd~kdkg4
      FROM @lt_prod_head AS zt01
      JOIN vbak
        ON zt01~zzkdauf EQ vbak~vbeln
      JOIN vbkd
        ON vbak~vbeln EQ vbkd~vbeln
       AND vbkd~posnr EQ '000000'
     ORDER BY vbak~vbeln
      INTO CORRESPONDING FIELDS OF TABLE @gt_vbak.

    CLEAR: gt_zpptc002.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_zpptc002
      FROM zpptc002
       FOR ALL ENTRIES IN @lt_prod_head
     WHERE aufnr EQ @lt_prod_head-aufnr.

    SORT gt_zpptc002 BY aufnr posnr.
  ENDIF.

  SELECT *
    INTO TABLE @gt_crhd
    FROM zgtppvcrhd
   WHERE werks IN @gr_werks.

  SELECT z1~werks, z1~matnr, z1~pdcaproccode
    FROM zgtpp_cv_mastval AS z1
   WHERE z1~werks IN @gr_werks
     AND ( z1~matnr IN ( SELECT DISTINCT z2~matnr FROM @gt_afpo   AS z2 ) OR
           z1~matnr IN ( SELECT DISTINCT z3~matnr FROM zgtppt2350 AS z3  WHERE werks IN @gr_werks ) )
   ORDER BY z1~werks, z1~matnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_zgtcvmstval.

  PERFORM get_system_info.
*// }

  CLEAR : gt_disp_head, gt_prod_rout, gt_prod_char.
  LOOP AT lt_prod_head INTO DATA(ls_prod_head).
*- 생산 오더 공정, BOM 취합용 데이터
    CLEAR gs_prod_rout.
    gs_prod_rout-aufnr = ls_prod_head-aufnr.
    APPEND gs_prod_rout TO gt_prod_rout.

*- 생산 오더 특성 취합용 데이터
*// Modified by ZGODEV06 on 2026-01-21 {
*    CLEAR gs_prod_char.
*    gs_prod_char-aufnr = ls_prod_head-aufnr.
*    gs_prod_char-kdauf = ls_prod_head-kdauf.
*    gs_prod_char-kdpos = ls_prod_head-kdpos.
*    READ TABLE gt_afpo INTO DATA(ls_afpo) WITH KEY aufnr = ls_prod_head-aufnr.
*    IF sy-subrc EQ 0.
*      gs_prod_char-cuobj = ls_afpo-cuobj.
*    ENDIF.
*    APPEND gs_prod_char TO gt_prod_char.
*// }

*- 생산 오더 헤더 ALV용
    MOVE-CORRESPONDING ls_prod_head TO gs_disp_head.
* 전송 상태
    gs_disp_head-icon = icon_led_inactive.

* 수신 시스템
*// Modified by ZGODEV06 on 2026-03-16 {
*    IF p_r3 = 'X'.
*      gs_disp_head-zsystem_id = 'KPCM'.
*    ELSEIF p_r4 = 'X'.
*      gs_disp_head-zsystem_id = 'KBDM'.
*    ELSEIF p_r9 = 'X'.
*      gs_disp_head-zsystem_id = 'KSCM'.
*    ELSEIF p_r10 = 'X'.
*      gs_disp_head-zsystem_id = 'KGPM'.
*    ELSEIF p_r11 = 'X'.
*      gs_disp_head-zsystem_id = 'KGOM'.
*    ENDIF.
*
** 시스템 내역
*    gs_disp_head-zsystem_id_desc = zgtpp_cl_common=>get_domain_text(
*      iv_domname  = 'ZGTDTARGET' " 도메인이름
*      iv_domvalue = CONV #( gs_disp_head-zsystem_id ) ).

    gs_disp_head-zsystem_id = gv_zsystem_id.
    gs_disp_head-zsystem_id_desc = gv_zsystem_id_desc.
*// }

* 오더 상태
    CALL FUNCTION 'ZGTPP_ORDER_STATUS'
      EXPORTING
        i_aufnr  = ls_prod_head-aufnr
      IMPORTING
        e_status = lv_status.
    gs_disp_head-status = lv_status.

*// Modified by ZGODEV06 on 2026-01-21 {
*// 영업소.
    IF gs_disp_head-zzkdauf IS NOT INITIAL.
      READ TABLE gt_vbak INTO DATA(ls_vbak) WITH KEY vbeln = gs_disp_head-zzkdauf BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        READ TABLE gt_sales_org INTO DATA(ls_sales_org) WITH TABLE KEY skey COMPONENTS vkorg = ls_vbak-vkorg
                                                                                       vkgrp = ls_vbak-vkgrp
                                                                                       kdkg4 = ls_vbak-kdkg4.
        IF sy-subrc IS INITIAL.
          gs_disp_head-zzyuscd = ls_sales_org-zzyuscd.
        ELSE.
          CALL FUNCTION 'ZGTSD_GET_ZZYUSCD'
            EXPORTING
              i_vkorg   = ls_vbak-vkorg
              i_vkgrp   = ls_vbak-vkgrp
              i_kdkg4   = ls_vbak-kdkg4
            IMPORTING
              e_zzyuscd = ls_vbak-zzyuscd.

          gs_disp_head-zzyuscd = ls_vbak-zzyuscd.
          APPEND CORRESPONDING #( ls_vbak ) TO gt_sales_org.
        ENDIF.
      ENDIF.
    ENDIF.

*// 특기사항.
    PERFORM read_text USING gs_disp_head-aufnr gs_disp_head-ztext.
*// }

* 앞의 0 제거(생산오더번호)
    PERFORM data_conversion USING gs_disp_head-aufnr space space space space
                                                           space space '-'.

    APPEND gs_disp_head TO gt_disp_head.
  ENDLOOP.


* 2026.02.11.CHM2602-00022.zlsgpp5. 소재 플랜트, 소재 MOM I/F 의 경우
* 릴리즈 된 생산오더 만 MOM 전송.
  PERFORM filter_order_status.


  SORT : gt_disp_head, gt_prod_rout BY aufnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_prod_order_item
*&---------------------------------------------------------------------*
FORM get_prod_order_item .

  DATA : lt_configuration_idoc LIKE TABLE OF api_value,
         ls_configuration_idoc LIKE api_value.

  CHECK gt_afpo[] IS NOT INITIAL.

  SELECT DISTINCT zt01~aufnr, zt01~posnr, zt02~werks, zt03~zspecno,
                  zt03~inlength, zt03~infactor, zt03~qlength, zt03~clength
    FROM @gt_afpo   AS zt01
    JOIN zgtppt2340 AS zt02
      ON zt01~aufnr EQ zt02~ordnr
     AND zt01~posnr EQ substring( zt02~posnr, 3, 4 )
    JOIN zgtppt2330 AS zt03
      ON zt02~spgcd   EQ zt03~spgcd
     AND zt02~rqmon   EQ zt03~rqmon
     AND zt02~gong_cd EQ zt03~gong_cd
     AND zt02~zwkreq    EQ zt03~zwkreq
   ORDER BY zt01~aufnr, zt01~posnr
    INTO TABLE @DATA(lt_zgtppt2330).

  SELECT DISTINCT zt01~aufnr, zt01~posnr, zt02~werks,
                  zt02~inlength, zt02~infactor, zt02~qlength, zt02~clength
    FROM @gt_afpo   AS zt01
    JOIN zgtppt2340 AS zt02
      ON zt01~aufnr EQ zt02~ordnr
     AND zt01~posnr EQ substring( zt02~posnr, 3, 4 )
   ORDER BY zt01~aufnr, zt01~posnr
    INTO TABLE @DATA(lt_zgtppt2340).

  SELECT zt01~aufnr, marc~matnr, marc~dispo
    FROM @gt_afpo AS zt01
    JOIN aufk
      ON aufk~aufnr EQ zt01~aufnr
    JOIN marc
      ON zt01~matnr EQ marc~matnr
     AND aufk~werks EQ marc~werks
   ORDER BY zt01~aufnr, marc~matnr, marc~dispo
    INTO TABLE @DATA(lt_marc).

  CLEAR : gt_data_item[].

  LOOP AT gt_afpo INTO gs_afpo.
*// Modified by ZGODEV06 on 2026-01-21 {
    APPEND INITIAL LINE TO gt_prod_char REFERENCE INTO DATA(lr_prod_char).
    lr_prod_char->* = CORRESPONDING #( gs_afpo ).
*// }

    CLEAR : gs_data_item.
    MOVE-CORRESPONDING gs_afpo TO gs_data_item.

* 조장 구성표
*// Modified by ZGODEV06 on 2026-01-21 {
*    SELECT SINGLE grpnr
*      INTO gs_data_item-grpnr
*      FROM zgtppt2010
*     WHERE ordnr EQ gs_data_item-aufnr.

    READ TABLE gt_zgtppt2010 INTO DATA(ls_zgtppt2010) WITH KEY ordnr = gs_afpo-aufnr.
    IF sy-subrc IS INITIAL.
      gs_data_item-grpnr = ls_zgtppt2010-grpnr.
    ENDIF.

*// Modified  on 2026-07-08 { 포장재 정보 전송
    CASE gs_afpo-dwerk.
      WHEN '6500' OR '6600'.
        READ TABLE gt_zgtppt2010 INTO ls_zgtppt2010 WITH KEY ordnr = gs_afpo-aufnr
                                                                             posnr+2(4) = gs_afpo-posnr.
        IF sy-subrc IS INITIAL.
          IF ls_zgtppt2010-matnr_dm IS NOT INITIAL.
            CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
              EXPORTING
                input  = ls_zgtppt2010-matnr_dm
              IMPORTING
                output = ls_zgtppt2010-matnr_dm.

            gs_data_item-matnr_dm = ls_zgtppt2010-matnr_dm.
          ENDIF.
        ENDIF.
    ENDCASE.
*// }


    READ TABLE lt_marc INTO DATA(ls_marc) WITH KEY aufnr = gs_afpo-aufnr
                                                   matnr = gs_afpo-matnr BINARY SEARCH.
    CASE ls_marc-dispo+0(2).
      WHEN 'GL'.
        READ TABLE lt_zgtppt2330 INTO DATA(ls_zgtppt2330) WITH KEY aufnr = gs_afpo-aufnr
                                                                   posnr = gs_afpo-posnr BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          gs_data_item-zspecno = ls_zgtppt2330-zspecno.
        ENDIF.

      WHEN 'GO'.
        READ TABLE gt_zgtcvordsyval INTO DATA(ls_zgtcvordsyval) WITH KEY aufnr = gs_afpo-aufnr BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          CASE ls_zgtcvordsyval-pdcaproccode.
            WHEN'SZT'.
              SELECT SINGLE zt02~pdcaspecno
                INTO @gs_data_item-zspecno
                FROM zgtcvordsyval AS zt01
                JOIN zgtcvmstval   AS zt02
                  ON zt01~matnr EQ zt02~matnr
               WHERE zt01~aufnr EQ @ls_zgtppt2010-dmord.

            WHEN'SHE'.
              SELECT SINGLE pdcaspecno
                INTO @gs_data_item-zspecno
                FROM zgtcvmstval
               WHERE matnr EQ @gs_afpo-matnr
                 AND werks EQ @gs_afpo-dwerk.
          ENDCASE.
        ENDIF.
    ENDCASE.

    CLEAR ls_marc.
*// }

* 자재 내역
    gs_data_item-maktx = zgtpp_cl_common=>get_maktx( iv_matnr = gs_data_item-matnr ).

* 앞의 0 제거(생산오더번호)
    PERFORM data_conversion USING gs_data_item-aufnr space gs_data_item-posnr
                                  gs_data_item-matnr space space space '-'.

*- 지시조장, 지시보빈수, 입고조장, 입고보빈수
    CLEAR : ls_configuration_idoc, lt_configuration_idoc.
    CALL FUNCTION 'Z_PP_GET_CHARACTERISTIC'
      EXPORTING
        i_aufnr              = gs_afpo-aufnr
        i_posnr              = gs_afpo-posnr
      TABLES
        t_configuration_idoc = lt_configuration_idoc
      EXCEPTIONS
        instance_not_found   = 1
        invalid_data         = 2.

*// 검사여장, 품목별 입고 조장 길이.
    READ TABLE gt_zpptc002 INTO DATA(ls_zpptc002) WITH KEY aufnr = gs_afpo-aufnr
                                                           posnr = gs_afpo-posnr BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      gs_data_item-psamg = ls_zpptc002-psamg.
    ENDIF.

*// 품목별 입고 조장 길이.
    gs_data_item-psmng = gs_afpo-psmng.

*// Modified by KSW on 2026-06-23 {
*    IF gs_afpo-dwerk NE '6600'.
*}
    SELECT SINGLE z1~inlength,
                  z1~infactor,
                ( z1~clength + z1~slength + z1~elength + z1~adlength ) AS menge
      FROM @gt_zgtppt2010 AS z1
     WHERE z1~ordnr EQ @gs_afpo-aufnr
       AND substring( z1~posnr, 3, 4 ) EQ @gs_afpo-posnr
      INTO (@gs_data_item-mwert11, @gs_data_item-mwert22, @gs_data_item-mwert21).

    IF sy-subrc IS NOT INITIAL.
      READ TABLE lt_configuration_idoc INTO ls_configuration_idoc WITH KEY atnam = 'SAP_MILLCA_LENGTH'.
      IF sy-subrc IS INITIAL.
        PERFORM string_replace USING ls_configuration_idoc-atwrt.
        gs_data_item-mwert11 = ls_configuration_idoc-atwrt.
      ENDIF.

      READ TABLE lt_configuration_idoc INTO ls_configuration_idoc WITH KEY atnam = 'SAP_MILLCA_FACTOR'.
      IF sy-subrc IS INITIAL.
        PERFORM string_replace USING ls_configuration_idoc-atwrt.
        gs_data_item-mwert22 = ls_configuration_idoc-atwrt.
      ENDIF.
    ENDIF.
*// Modified by KSW on 2026-06-23 {
*    ELSE.
    IF gs_afpo-dwerk EQ '6600'.
*}
      READ TABLE lt_marc INTO ls_marc WITH KEY aufnr = gs_afpo-aufnr
                                                 matnr = gs_afpo-matnr BINARY SEARCH.
      IF ( sy-subrc = 0 AND
          ls_marc-dispo+0(2) = 'GL' ).     "완제품 지정 오더는 특성 변경 불가, 랜의 경우 2340 대입

*        랜 완제품의 조장 수 = 총 작업지시 수량 / 개별조장길이
        READ TABLE gt_zgtcvordsyval INTO ls_zgtcvordsyval WITH KEY aufnr = gs_afpo-aufnr BINARY SEARCH.
        IF sy-subrc = 0 AND ls_zgtcvordsyval-pdcaproccode = 'REW'.
          gs_data_item-mwert22 = gs_afpo-psmng / gs_data_item-mwert11.
        ENDIF.

**** 상단 오더 특성에서 정상 추출시에는 미추출
*          READ TABLE LT_ZGTPPT2340 INTO DATA(LS_ZGTPPT2340) WITH KEY AUFNR = GS_AFPO-AUFNR
*                                                                     POSNR = GS_AFPO-POSNR BINARY SEARCH.
*          IF SY-SUBRC IS INITIAL.
*            GS_DATA_ITEM-MWERT11 = LS_ZGTPPT2340-INLENGTH.
*            GS_DATA_ITEM-MWERT21 = LS_ZGTPPT2340-CLENGTH.
*            GS_DATA_ITEM-MWERT22 = LS_ZGTPPT2340-INFACTOR.
*            GS_DATA_ITEM-PSAMG   = LS_ZGTPPT2340-QLENGTH.
*          ENDIF.
      ENDIF.
    ENDIF.
*// Modified by KSW on 2026-06-23 {
*    ENDIF.
*}

*// 신선 공정 특화 정보 추출 및 대입.
    READ TABLE gt_zgtcvmstval INTO DATA(ls_zgtcvmstval) WITH KEY werks = gs_afpo-dwerk
                                                                 matnr = gs_afpo-matnr BINARY SEARCH.
    IF sy-subrc IS INITIAL AND ls_zgtcvmstval-pdcaproccode EQ 'BWD'.
      READ TABLE gt_zgtppt2012 INTO DATA(ls_zgtppt2012) WITH KEY ordnr = gs_afpo-aufnr
                                                                 posnr = gs_afpo-posnr BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        gs_data_item-zcage = ls_zgtppt2012-zcage. "// Cage.
        gs_data_item-zwseq = ls_zgtppt2012-zwseq. "// 작업차수.
        gs_data_item-ycoef = ls_zgtppt2012-ycoef. "// 연입률.

        CONDENSE gs_data_item-zcage NO-GAPS.
        CONDENSE gs_data_item-zwseq NO-GAPS.

        IF gs_data_item-mwert21 IS INITIAL.
          gs_data_item-mwert21 = ls_zgtppt2012-adlength. "// 추가 여장.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR gs_data_item-mwert12.
*// }

* POSNR 값이 '0001'이 아닌 경우 생산 버전이 비어있으므로 POSNR:0001의 생산 버전 반영
    IF gs_data_item-verid IS INITIAL.
      READ TABLE gt_afpo INTO DATA(ls_afpo) WITH KEY posnr = '0001'.
      gs_data_item-verid = ls_afpo-verid.
    ENDIF.

*// Modified by ZGODEV06 on 2026-01-21 {
    READ TABLE gt_disp_head INTO DATA(ls_disp_head) WITH KEY aufnr = gs_data_item-aufnr BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      gs_data_item-zzbundle = ls_disp_head-zzbundle.
      gs_data_item-zzposnr  = ls_disp_head-zzposnr.
    ENDIF.
*// }

    APPEND gs_data_item TO gt_data_item.
  ENDLOOP.

  SORT gt_data_item BY aufnr posnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_prod_routing
*&---------------------------------------------------------------------*
FORM get_prod_routing .

  DATA : ls_order_objects	LIKE bapi_pp_order_objects,
         ls_return        LIKE bapiret2,
         ls_operation     LIKE bapi_order_operation1,
         lt_operation     LIKE  TABLE OF bapi_order_operation1.

  CHECK gt_prod_rout[] IS NOT INITIAL.

  ls_order_objects-operations = 'X'.

  CLEAR : gt_data_rout.
  LOOP AT gt_prod_rout INTO gs_prod_rout.

    CLEAR : ls_operation, lt_operation.
    CALL FUNCTION 'BAPI_PRODORD_GET_DETAIL'
      EXPORTING
        number        = gs_prod_rout-aufnr
        order_objects = ls_order_objects
      IMPORTING
        return        = ls_return
      TABLES
        operation     = lt_operation.

    LOOP AT lt_operation INTO ls_operation.

      CLEAR gs_data_rout.
      gs_data_rout-aufnr  = gs_prod_rout-aufnr.
      gs_data_rout-vornr  = ls_operation-operation_number.
      gs_data_rout-plnal  = ls_operation-group_counter.
      gs_data_rout-plnfl  = ls_operation-sequence_no.
      gs_data_rout-ltxa1  = ls_operation-description.
      gs_data_rout-arbpl  = ls_operation-work_center.
      gs_data_rout-ktext  = ls_operation-work_center_text.
      SELECT SINGLE ktsch INTO gs_data_rout-ktsch
        FROM crhd
       WHERE werks EQ ls_operation-prod_plant
         AND arbpl EQ ls_operation-work_center.
      gs_data_rout-steus  = ls_operation-opr_cntrl_key.
      gs_data_rout-ssavd  = ls_operation-late_sched_start_date_exec.
      gs_data_rout-ssavz  = ls_operation-late_sched_start_time_exec.
      gs_data_rout-ssedd  = ls_operation-late_sched_fin_date_exec.
      gs_data_rout-ssedz  = ls_operation-late_sched_fin_time_exec.
      SELECT SINGLE loekz INTO gs_data_rout-loekz
        FROM afvc
       WHERE aufpl = ls_operation-routing_no
         AND aplzl = ls_operation-counter.
* 앞의 0 제거(생산오더번호)
      PERFORM data_conversion USING gs_data_rout-aufnr gs_data_rout-vornr space
                                                             space gs_data_rout-plnfl space space '-'.

      APPEND gs_data_rout TO gt_data_rout.

    ENDLOOP.

  ENDLOOP.

  SORT gt_data_rout BY aufnr vornr plnal.

*U01
  IF p_r4 EQ 'X'.
    DELETE gt_data_rout WHERE vornr NE '10'.
  ENDIF.
*U01

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_prod_bom
*&---------------------------------------------------------------------*
FORM get_prod_bom .

  DATA : lt_resb LIKE TABLE OF resb,
         ls_resb LIKE resb.

  CHECK gt_prod_rout[] IS NOT INITIAL.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @lt_resb
      FROM resb
      FOR ALL ENTRIES IN @gt_prod_rout
      WHERE aufnr EQ @gt_prod_rout-aufnr
        AND kzkup EQ @space
*// Modified by ZGODEV06 on 2026-06-23 {
        AND dumps EQ @space   "// 가상품목 제외
        AND schgt EQ @space.  "// 벌크자재 제외
*// }

  CLEAR : gt_data_bom.
  LOOP AT lt_resb INTO ls_resb.

    CLEAR : gs_data_bom.
    MOVE-CORRESPONDING ls_resb TO gs_data_bom.
* 자재 내역
    gs_data_bom-maktx = zgtpp_cl_common=>get_maktx(
      iv_matnr = gs_data_bom-matnr ).
* 앞의 0 제거(생산오더번호)
    PERFORM data_conversion USING gs_data_bom-aufnr space space
                                                           gs_data_bom-matnr space space space '-'.

    APPEND gs_data_bom TO gt_data_bom.

  ENDLOOP.

  SORT gt_data_bom BY aufnr rsnum rspos.

*** Start 2026.07.04 BOM 누락시, 오더 미전송 ZGISPP03
  SORT gt_disp_head BY aufnr.
  LOOP AT gt_disp_head INTO gs_disp_head.
    DATA(lv_tabix) = sy-tabix.

    READ TABLE gt_data_bom INTO gs_data_bom
                                                WITH KEY aufnr = gs_disp_head-aufnr
                                                BINARY SEARCH.
    IF sy-subrc <> 0.
      DELETE gt_disp_head INDEX lv_tabix.
    ENDIF.

  ENDLOOP.
*** End 2026.07.04 BOM 누락시, 오더 미전송 ZGISPP03

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_prod_char
*&---------------------------------------------------------------------*
FORM get_prod_char .

*  DATA : BEGIN OF ls_vbap,
*           vbeln LIKE vbap-vbeln,
*           posnr LIKE vbap-posnr,
*           cuobj LIKE vbap-cuobj,
*         END OF ls_vbap.
*  DATA : lt_vbap LIKE TABLE OF ls_vbap.
  DATA : lt_configuration	LIKE TABLE OF conf_out,
         ls_configuration LIKE conf_out.
*- Start 2025.05.02
  DATA : lv_aufnr LIKE aufk-aufnr.
*- End 2025.05.02
  CHECK gt_prod_char[] IS NOT INITIAL.

*  SELECT vbeln, posnr, cuobj
*     INTO CORRESPONDING FIELDS OF TABLE @lt_vbap
*     FROM vbap
*     FOR ALL ENTRIES IN @gt_prod_char
*     WHERE vbeln EQ @gt_prod_char-kdauf
*         AND posnr EQ @gt_prod_char-kdpos.

  CLEAR : gt_data_char.
  LOOP AT gt_prod_char INTO gs_prod_char.
* "부스닥트MES"를 선택한 경우 상기의 2-6)을 실행하지 않고, 하기의 로직으로 OT_CHAR를 채움
    IF p_r4 = 'X'.
* ZGTPPT3160에서 특성 정보 취합( 오더 기준 여러 건 존재할 수 있음 )
*- Start 2025.05.02
* ZZORIGIN 존재시 해당 값으로 특성 정보 취합할 것
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gs_prod_char-aufnr
        IMPORTING
          output = lv_aufnr.
      SELECT SINGLE zzorigin INTO @DATA(lv_zzorigin)
                             FROM aufk
                             WHERE aufnr EQ @lv_aufnr.

      IF lv_zzorigin IS INITIAL.

        SELECT job_no, line_no, serial_info
            INTO TABLE @DATA(lt_3160)
            FROM zgtppt3160
            WHERE aufnr = @lv_aufnr.

      ELSE.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_zzorigin
          IMPORTING
            output = lv_aufnr.

        SELECT job_no, line_no, serial_info
            INTO CORRESPONDING FIELDS OF TABLE @lt_3160
            FROM zgtppt3160
            WHERE aufnr = @lv_aufnr.

      ENDIF.
*- End 2025.05.02
      SORT lt_3160 BY job_no line_no serial_info.
      DELETE ADJACENT DUPLICATES FROM lt_3160 COMPARING ALL FIELDS.

      LOOP AT lt_3160 INTO DATA(ls_3160).

        CLEAR gs_data_char.
        gs_data_char-aufnr = gs_prod_char-aufnr.
        gs_data_char-class = 'JOB,LINE,SERIAL'.
        PERFORM data_conversion USING gs_data_char-aufnr space space
                                                               space space space space '-'.
        CONCATENATE ls_3160-job_no ',' ls_3160-line_no ',' ls_3160-serial_info
                        INTO gs_data_char-atnam.
        APPEND gs_data_char TO gt_data_char.

      ENDLOOP.

    ELSE.

*      CLEAR ls_vbap.
*      READ TABLE lt_vbap INTO ls_vbap
*                                     WITH KEY vbeln  = gs_prod_char-kdauf
*                                                   posnr = gs_prod_char-kdpos.
*
*      IF gs_prod_char-cuobj IS NOT INITIAL.
      IF gs_prod_char-cuobj IS NOT INITIAL.

        CLEAR : ls_configuration, lt_configuration.
        CALL FUNCTION 'VC_I_GET_CONFIGURATION'
          EXPORTING
            instance      = gs_prod_char-cuobj
          TABLES
            configuration = lt_configuration.

        LOOP AT lt_configuration INTO ls_configuration.

          CLEAR gs_data_char.
          gs_data_char-aufnr = gs_prod_char-aufnr.
          PERFORM data_conversion USING gs_data_char-aufnr space space
                                                                 space space space space '-'.
*// Modified by ZGODEV06 on 2026-01-21 {
          gs_data_char-class = gs_prod_char-posnr.
*// }
          gs_data_char-atnam = ls_configuration-atnam.
          gs_data_char-atbez = ls_configuration-atbez.
          gs_data_char-atwrt = ls_configuration-atwrt.
          gs_data_char-atwtb = ls_configuration-atwtb.
          APPEND gs_data_char TO gt_data_char.

        ENDLOOP.

      ENDIF.

    ENDIF.

  ENDLOOP.

  SORT gt_data_char BY aufnr atnam.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_data
*&---------------------------------------------------------------------*
FORM send_data .
* 배치 모드일때는 조회된 모든 작업장 전송
  IF p_r8 EQ 'X'.

    PERFORM all_send_data.

  ELSE.

    PERFORM choice_send_data.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_subscreen
*&---------------------------------------------------------------------*
FORM init_subscreen USING  pv_subscreen.

  tabstr-activetab = gv_ok_code2.
  gv_dynnr = pv_subscreen.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_detail_data
*&---------------------------------------------------------------------*
FORM get_detail_data .

  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_index_rows = gt_row_table[].

  DESCRIBE TABLE gt_row_table LINES gv_lines.
  IF gv_lines = 0.
    MESSAGE s000 WITH TEXT-m04 DISPLAY LIKE 'E'..
    EXIT.
  ENDIF.

  CLEAR : gt_disp_item, gt_disp_rout, gt_disp_bom, gt_disp_char,
               gt_disp_item2, gt_disp_rout2, gt_disp_bom2, gt_disp_char2.
  LOOP AT gt_row_table.

    IF p_r1 = 'X'.

      CLEAR: gs_disp_head.
      READ TABLE gt_disp_head INTO gs_disp_head
                                               INDEX gt_row_table-index.
      IF sy-subrc = 0.
* 아이템
        LOOP AT gt_data_item INTO gs_data_item
                                               WHERE aufnr EQ gs_disp_head-aufnr.
          CLEAR gs_disp_item.
          MOVE-CORRESPONDING gs_data_item TO gs_disp_item.
          APPEND gs_disp_item TO gt_disp_item.
        ENDLOOP.
* 공정
        LOOP AT gt_data_rout INTO gs_data_rout
                                               WHERE aufnr EQ gs_disp_head-aufnr.
          CLEAR gs_disp_rout.
          MOVE-CORRESPONDING gs_data_rout TO gs_disp_rout.
          APPEND gs_disp_rout TO gt_disp_rout.
        ENDLOOP.
* BOM
        LOOP AT gt_data_bom INTO gs_data_bom
                                               WHERE aufnr EQ gs_disp_head-aufnr.
          CLEAR gs_disp_bom.
          MOVE-CORRESPONDING gs_data_bom TO gs_disp_bom.
          APPEND gs_disp_bom TO gt_disp_bom.
        ENDLOOP.
* 특성
        LOOP AT gt_data_char INTO gs_data_char
                                               WHERE aufnr EQ gs_disp_head-aufnr.
          CLEAR gs_disp_char.
          MOVE-CORRESPONDING gs_data_char TO gs_disp_char.
          APPEND gs_disp_char TO gt_disp_char.
        ENDLOOP.

      ENDIF.

    ELSE.

      CLEAR: gs_disp_head2.
      READ TABLE gt_disp_head2 INTO gs_disp_head2
                                               INDEX gt_row_table-index.
      IF sy-subrc = 0.
* 아이템
        LOOP AT gt_data_item2 INTO gs_data_item2
                                               WHERE zifkey EQ gs_disp_head2-zifkey
                                                    AND aufnr EQ gs_disp_head2-aufnr.
          CLEAR gs_disp_item2.
          MOVE-CORRESPONDING gs_data_item2 TO gs_disp_item2.
          APPEND gs_disp_item2 TO gt_disp_item2.
        ENDLOOP.
* 공정
        LOOP AT gt_data_rout2 INTO gs_data_rout2
                                               WHERE zifkey EQ gs_disp_head2-zifkey
                                                    AND aufnr EQ gs_disp_head2-aufnr.
          CLEAR gs_disp_rout2.
          MOVE-CORRESPONDING gs_data_rout2 TO gs_disp_rout2.
          APPEND gs_disp_rout2 TO gt_disp_rout2.
        ENDLOOP.
* BOM
        LOOP AT gt_data_bom2 INTO gs_data_bom2
                                               WHERE zifkey EQ gs_disp_head2-zifkey
                                                    AND aufnr EQ gs_disp_head2-aufnr.
          CLEAR gs_disp_bom2.
          MOVE-CORRESPONDING gs_data_bom2 TO gs_disp_bom2.
          APPEND gs_disp_bom2 TO gt_disp_bom2.
        ENDLOOP.
* 특성
        LOOP AT gt_data_char2 INTO gs_data_char2
                                               WHERE zifkey EQ gs_disp_head2-zifkey
                                                    AND aufnr EQ gs_disp_head2-aufnr.
          CLEAR gs_disp_char2.
          MOVE-CORRESPONDING gs_data_char2 TO gs_disp_char2.
          APPEND gs_disp_char2 TO gt_disp_char2.
        ENDLOOP.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form all_send_data
*&---------------------------------------------------------------------*
FORM all_send_data .

  DATA : lv_error.

  CLEAR : gt_send_head, gt_send_item, gt_send_rout, gt_send_bom, gt_send_char.
  IF p_r1 = 'X'. "전송
    MOVE-CORRESPONDING gt_disp_head[] TO gt_send_head[].  "헤더
  ELSEIF p_r2 = 'X'. "로그 조회
    MOVE-CORRESPONDING gt_disp_head2[] TO gt_send_head[].  "헤더
  ENDIF.

  LOOP AT gt_send_head INTO gs_send_head.
    gv_tabix = sy-tabix.

* 오더 Lock 설정
    CALL FUNCTION 'ENQUEUE_EZGT_ZGTPPI2010'
      EXPORTING
        aufnr          = gs_send_head-aufnr
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    IF sy-subrc <> 0.
      WAIT UP TO '1' SECONDS.
      lv_error = 'X'.
      EXIT.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = gs_send_head-zzpriority
      IMPORTING
        output = gs_send_head-zzpriority.

*** 2026.08.31 Start ZZORIGIN 000 제거
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = gs_send_head-zzorigin
      IMPORTING
        output = gs_send_head-zzorigin.
*** 2026.08.31 End ZZORIGIN 000 제거

    MODIFY gt_send_head FROM gs_send_head INDEX gv_tabix.

  ENDLOOP.

  IF lv_error IS INITIAL.

    MOVE-CORRESPONDING gt_data_item[] TO gt_send_item[].    "아이템
    MOVE-CORRESPONDING gt_data_rout[] TO gt_send_rout[].    "공정
*  MOVE-CORRESPONDING gt_data_bom[] TO gt_send_bom[].   "BOM
    LOOP AT gt_data_bom INTO gs_data_bom.
      CLEAR gs_send_bom.
      MOVE-CORRESPONDING gs_data_bom TO gs_send_bom.
      PERFORM data_conversion USING space space space space space
                                                        gs_send_bom-rsnum gs_send_bom-rspos '-'.
      APPEND gs_send_bom TO gt_send_bom.
    ENDLOOP.
    MOVE-CORRESPONDING gt_data_char[] TO gt_send_char[]. "특성

    CHECK gt_send_head[] IS NOT INITIAL.
* 데이터 전송 후 로그 히스토리 업데이트
    PERFORM call_rfc TABLES gt_send_head
                                              gt_send_item
                                              gt_send_rout
                                              gt_send_bom
                                              gt_send_char.
* 오더 Lock 해제
    LOOP AT gt_send_head INTO gs_send_head.

      CALL FUNCTION 'DEQUEUE_EZGT_ZGTPPI2010'
        EXPORTING
          aufnr = gs_send_head-aufnr.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_rfc
*&---------------------------------------------------------------------*
FORM call_rfc TABLES pt_send_head STRUCTURE zgtppt3010 "헤더
                                    pt_send_item STRUCTURE zgtppt3020   "아이템
                                    pt_send_rout STRUCTURE zgtppt3030   "공정
                                    pt_send_bom STRUCTURE zgtppt3040  "BOM
                                    pt_send_char STRUCTURE zgtppt3050. "특성

  DATA : lt_mes_head LIKE gt_mes_head, "헤더
         lt_mes_item LIKE gt_mes_item,    "아이템
         lt_mes_rout LIKE gt_mes_rout,     "공정
         lt_mes_bom  LIKE gt_mes_bom,   "BOM
         ls_mes_bom  LIKE zgtppsif0007,   "BOM
         lt_mes_char LIKE gt_mes_char,
         ls_mes_char LIKE zgtppsif0008.  "특성
  DATA : lv_dest TYPE zifdest-dest.
  DATA : lv_zsystem_id   TYPE zgtppt1020-zsystem_id.
*- Start 2025.05.02
  DATA : lv_aufnr LIKE aufk-aufnr.
*- End 2025.05.02
  MOVE-CORRESPONDING pt_send_head[] TO lt_mes_head[]. "헤더
  MOVE-CORRESPONDING pt_send_item[] TO lt_mes_item[].    "아이템
  MOVE-CORRESPONDING pt_send_rout[] TO lt_mes_rout[].     "공정
*  MOVE-CORRESPONDING pt_send_bom[] TO lt_mes_bom[].
  LOOP AT pt_send_bom INTO DATA(ls_send_bom).

    CLEAR ls_mes_bom.
    MOVE-CORRESPONDING ls_send_bom TO ls_mes_bom.
    ls_mes_bom-bdmng = ls_send_bom-erfmg.
    ls_mes_bom-meins = ls_send_bom-erfme.
    APPEND ls_mes_bom TO lt_mes_bom.

  ENDLOOP. "BOM
*- Start 2025.05.02
  LOOP AT pt_send_char INTO DATA(ls_send_char).

    CLEAR ls_mes_char.
    MOVE-CORRESPONDING ls_send_char TO ls_mes_char.
    APPEND ls_mes_char TO lt_mes_char.

  ENDLOOP.    "특성
*- End 2025.05.02
  CLEAR: gv_result, gv_message, lv_dest.
  IF sy-sysid = 'S4Q' OR sy-sysid = 'S4P'.
*- Destination 가져오기
    CALL FUNCTION 'Z_IF_DESTINATION'
      EXPORTING
        gubun                 = 'P1'
      IMPORTING
        dest_name             = lv_dest
      EXCEPTIONS
        destination_not_found = 1
        OTHERS                = 2.

    IF p_r1 = 'X'. "전송

      CASE abap_true.
        WHEN p_r3. "지중 MES
          lv_zsystem_id = 'KPCM'.
        WHEN p_r4. "부스닥트 MES
          lv_zsystem_id = 'KBDM'.
        WHEN p_r9. "소재 MOM SRM2510-04825
          lv_zsystem_id = 'KSCM'.
*// Modified by ZGODEV06 on 2026-01-21 {
        WHEN p_r10.
          lv_zsystem_id = 'KGPM'.
        WHEN p_r11.
          lv_zsystem_id = 'KGOM'.
*// }
        WHEN p_r12. "한미소 MOM 260831
          lv_zsystem_id = 'KFCM'.
      ENDCASE.

    ELSEIF p_r2 = 'X'. "로그 조회

      CASE p_werks.
        WHEN '1302'. "지중 MES
          lv_zsystem_id = 'KPCM'.
        WHEN '1306'. "부스닥트 MES
          lv_zsystem_id = 'KBDM'.
        WHEN '1305'. "소재 MOM SRM2510-04825
          lv_zsystem_id = 'KSCM'.
*// Modified by ZGODEV06 on 2026-01-21 {
        WHEN '6500'.
          lv_zsystem_id = 'KGPM'.
        WHEN '6600'.
          lv_zsystem_id = 'KGOM'.
**// }
        WHEN '7501'. "한미소 MOM 260831
          lv_zsystem_id = 'KFCM'.
      ENDCASE.
    ENDIF.

*- RFC 전송
    CALL FUNCTION 'ZGTPP_IF_O_PROD_ORD_INFO' DESTINATION lv_dest
      EXPORTING
        i_system_id  = lv_zsystem_id
      IMPORTING
        zo_result    = gv_result
        zo_message   = gv_message
      TABLES
        ot_order_h   = lt_mes_head
        ot_order_i   = lt_mes_item
        ot_operation = lt_mes_rout
        ot_bom       = lt_mes_bom
        ot_char      = lt_mes_char.

*- History_Table에 저장
    IF gv_result = '00' OR gv_result = '0'.
      IF gv_message IS INITIAL.
        gv_message    = |전송성공|.
      ENDIF.
    ELSE.
      IF gv_message IS INITIAL.
        gv_message = |전송실패|.
      ENDIF.
    ENDIF.

  ENDIF.

  PERFORM save_history_table TABLES pt_send_head
                                    pt_send_item
                                    pt_send_rout
                                    pt_send_bom
                                    pt_send_char.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_history_table
*&---------------------------------------------------------------------*
FORM save_history_table TABLES pt_send_head STRUCTURE zgtppt3010
                                                      pt_send_item STRUCTURE zgtppt3020
                                                      pt_send_rout STRUCTURE zgtppt3030
                                                      pt_send_bom STRUCTURE zgtppt3040
                                                      pt_send_char STRUCTURE zgtppt3050.

  DATA : lv_timestamp TYPE timestampl.
*- 맵핑을 위한 변수키 생성
  GET TIME STAMP FIELD lv_timestamp.
*- 아이템
  LOOP AT pt_send_item ASSIGNING FIELD-SYMBOL(<ls_send_item>).
    <ls_send_item>-zifkey = lv_timestamp.
    PERFORM data_conversion USING <ls_send_item>-aufnr space <ls_send_item>-posnr
                                                           <ls_send_item>-matnr space space space '+'.
  ENDLOOP.
  IF pt_send_item[] IS NOT INITIAL.
    MODIFY zgtppt3020 FROM TABLE pt_send_item[].
  ENDIF.
*- 공정
  LOOP AT pt_send_rout ASSIGNING FIELD-SYMBOL(<ls_send_rout>).
    <ls_send_rout>-zifkey = lv_timestamp.
    PERFORM data_conversion USING <ls_send_rout>-aufnr <ls_send_rout>-vornr space
                                                           space <ls_send_rout>-plnfl space space '+'.
  ENDLOOP.
  IF pt_send_rout[] IS NOT INITIAL.
    MODIFY zgtppt3030 FROM TABLE pt_send_rout[].
  ENDIF.
* BOM
  LOOP AT pt_send_bom ASSIGNING FIELD-SYMBOL(<ls_send_bom>).
    <ls_send_bom>-zifkey = lv_timestamp.
    PERFORM data_conversion USING <ls_send_bom>-aufnr space space
                                                           <ls_send_bom>-matnr space <ls_send_bom>-rsnum
                                                           <ls_send_bom>-rspos '+'.
  ENDLOOP.
  IF pt_send_bom[] IS NOT INITIAL.
    MODIFY zgtppt3040 FROM TABLE pt_send_bom[].
  ENDIF.
* 특성
  LOOP AT pt_send_char ASSIGNING FIELD-SYMBOL(<ls_send_char>).
    <ls_send_char>-zifkey = lv_timestamp.
    PERFORM data_conversion USING <ls_send_char>-aufnr space space
                                                           space space space space '+'.
  ENDLOOP.
  IF pt_send_char[] IS NOT INITIAL.
    MODIFY zgtppt3050 FROM TABLE pt_send_char[].
  ENDIF.
*- 헤더
  LOOP AT pt_send_head ASSIGNING FIELD-SYMBOL(<ls_send_head>).

    <ls_send_head>-zifkey = lv_timestamp.

    IF p_r1 = 'X'. "전송

      CASE abap_true.
        WHEN p_r3. "지중 MES
          <ls_send_head>-zsystem_id = 'KPCM'.
        WHEN p_r4. "부스닥트 MES
          <ls_send_head>-zsystem_id = 'KBDM'.
        WHEN p_r9. "소재 MOM SRM2510-04825
          <ls_send_head>-zsystem_id = 'KSCM'.
*// Modified by ZGODEV06 on 2026-01-21 {
        WHEN p_r10.
          <ls_send_head>-zsystem_id = 'KGPM'.
        WHEN p_r11.
          <ls_send_head>-zsystem_id = 'KGOM'.
**// }
        WHEN p_r12. "한미소 MOM 260831
          <ls_send_head>-zsystem_id = 'KFCM'.
      ENDCASE.

    ELSEIF p_r2 = 'X'. "로그 조회

      CASE p_werks.
        WHEN '1302'. "지중 MES
          <ls_send_head>-zsystem_id = 'KPCM'.
        WHEN '1306'. "부스닥트 MES
          <ls_send_head>-zsystem_id = 'KBDM'.
        WHEN '1305'. "소재 MOM SRM2510-04825
          <ls_send_head>-zsystem_id = 'KSCM'.
*// Modified by ZGODEV06 on 2026-01-21 {
        WHEN '6500'.
          <ls_send_head>-zsystem_id = 'KGPM'.
        WHEN '6600'.
          <ls_send_head>-zsystem_id = 'KGOM'.
**// }
        WHEN '7501'. "한미소 MOM 260831
          <ls_send_head>-zsystem_id = 'KFCM'.
      ENDCASE.

    ENDIF.

    PERFORM data_conversion USING <ls_send_head>-aufnr space space space space
                                                           space space '+'.

    <ls_send_head>-zstat = gv_result.
    <ls_send_head>-zmessage = gv_message.
    <ls_send_head>-ifdat = sy-datum.
    <ls_send_head>-iftim = sy-uzeit.
    <ls_send_head>-ifnam = sy-uname.

  ENDLOOP.

  MODIFY zgtppt3010 FROM TABLE pt_send_head[].
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form choice_send_data
*&---------------------------------------------------------------------*
FORM choice_send_data .

  CLEAR  : gt_row_no, gt_row_no[].
  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_row_no = gt_row_no[].
* 선택 라인 없으면 오류 메시지 출력
  CLEAR: gv_cnt.
  DESCRIBE TABLE gt_row_no LINES gv_cnt.

  IF gv_cnt = 0.
    MESSAGE s000 WITH TEXT-m02 DISPLAY LIKE 'E'.
  ENDIF.

  CHECK gv_cnt > 0.
* CALL FUNCTION - POPUP_TO_CONFIRM_STEP
  CLEAR: gv_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      titel     = TEXT-083 "생산오더 정보 전송
      textline1 = TEXT-084 "생산오더 정보를 전송 하시겠습니까?
      textline2 = ''
    IMPORTING
      answer    = gv_answer.
  CHECK gv_answer = 'J'.
* RFC 전송을 위해 전송 대상 데이터 취합
  CASE abap_true.
    WHEN p_r10 OR p_r11.
      PERFORM send_gaon_mes.
    WHEN OTHERS.
      PERFORM append_data_to_send.
      CHECK gt_send_head[] IS NOT INITIAL.
* 데이터 전송 후 로그 히스토리 업데이트
      PERFORM call_rfc TABLES gt_send_head
                                                gt_send_item
                                                gt_send_rout
                                                gt_send_bom
                                                gt_send_char.
* 전송 처리 후 상태값 업데이트
      PERFORM update_alv_list.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_prod_order_send_log
*&---------------------------------------------------------------------*
FORM get_prod_order_send_log .

  DATA : lv_mandt LIKE sy-mandt,
         lv_tabix LIKE sy-tabix.

  RANGES : lr_zstat FOR zgtppt3010-zstat.

*- 헤더
  IF p_r5 = 'X'. "성공건만 조회
    lr_zstat-sign = 'I'.
    lr_zstat-option = 'EQ'.
    lr_zstat-low = '00'.
    APPEND lr_zstat.
    lr_zstat-low = '0'.
    APPEND lr_zstat.
  ELSEIF p_r6 = 'X'. "오류건만 조회
    lr_zstat-sign = 'I'.
    lr_zstat-option = 'EQ'.
    APPEND lr_zstat.
  ENDIF.

  CLEAR : gs_zgtppt3010, gt_zgtppt3010, gs_disp_head2 , gt_disp_head2,
               gs_zifkey, gt_zifkey, gt_data_item2, gt_data_rout2, gt_data_bom2,
               gt_data_char2.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @gt_zgtppt3010
    FROM zgtppt3010
   WHERE werks EQ @p_werks "werks IN @s_werks
     AND auart IN @s_auart
     AND aufnr IN @s_aufnr
     AND gstrp IN @s_gstrp
     AND ifdat IN @s_ifdat
     AND zstat IN @lr_zstat.

  LOOP AT gt_zgtppt3010 INTO gs_zgtppt3010.

    CLEAR gs_disp_head2 .
    MOVE-CORRESPONDING gs_zgtppt3010 TO gs_disp_head2.
* 조회조건에 품목 코드가 있을 경우 체크
    IF s_matnr[] IS NOT INITIAL.

      CLEAR lv_mandt.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gs_zgtppt3010-aufnr
        IMPORTING
          output = gs_zgtppt3010-aufnr.

      SELECT SINGLE mandt INTO @lv_mandt
        FROM afko
       WHERE aufnr EQ @gs_zgtppt3010-aufnr
         AND plnbez IN @s_matnr.
      IF lv_mandt IS INITIAL.
        CONTINUE.
      ENDIF.

    ENDIF.
* 전송 상태
    IF gs_disp_head2-zstat = '00' OR gs_disp_head2-zstat = '0'.
      gs_disp_head2-icon = icon_led_green.
    ELSE.
      gs_disp_head2-icon = icon_led_red.
    ENDIF.
* 수신 시스템 내역
    gs_disp_head2-zsystem_id_desc = zgtpp_cl_common=>get_domain_text(
      iv_domname  = 'ZGTDTARGET' " 도메인이름
      iv_domvalue = CONV #( gs_disp_head2-zsystem_id ) ).
* 하위 데이터를 가져오기 위한 조건값 취합
    gs_zifkey-zifkey = gs_zgtppt3010-zifkey.
    gs_zifkey-aufnr = gs_disp_head2-aufnr.
    APPEND gs_zifkey TO gt_zifkey.
* 앞의 0 제거(생산오더번호)
    PERFORM data_conversion USING gs_disp_head2-aufnr space space space space
                                                           space space '-'.

    APPEND gs_disp_head2 TO gt_disp_head2.

  ENDLOOP.

  SORT gt_disp_head2 BY aufnr.
  SORT gt_zifkey BY zifkey aufnr.

  CHECK gt_zifkey[] IS NOT INITIAL.

*- 아이템
  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE @gt_data_item2
  FROM zgtppt3020
  FOR ALL ENTRIES IN @gt_zifkey
  WHERE zifkey EQ @gt_zifkey-zifkey
       AND aufnr EQ @gt_zifkey-aufnr.

  LOOP AT gt_data_item2 INTO gs_data_item2.

    lv_tabix = sy-tabix.
* 자재 내역
    gs_data_item2-maktx = zgtpp_cl_common=>get_maktx(
      iv_matnr = gs_data_item2-matnr ).
* 앞의 0 제거(생산오더번호)
    PERFORM data_conversion USING gs_data_item2-aufnr space gs_data_item2-posnr
                                                           gs_data_item2-matnr space space space '-'.

    MODIFY gt_data_item2 FROM gs_data_item2 INDEX lv_tabix.

  ENDLOOP.

  SORT gt_data_item2 BY aufnr posnr.

*- 공정
  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE @gt_data_rout2
  FROM zgtppt3030
  FOR ALL ENTRIES IN @gt_zifkey
  WHERE zifkey EQ @gt_zifkey-zifkey
       AND aufnr EQ @gt_zifkey-aufnr.

  LOOP AT gt_data_rout2 INTO gs_data_rout2.

    lv_tabix = sy-tabix.
* 앞의 0 제거(생산오더번호)
    PERFORM data_conversion USING gs_data_rout2-aufnr gs_data_rout2-vornr space
                                                           space gs_data_rout2-plnfl space space '-'.

    MODIFY gt_data_rout2 FROM gs_data_rout2 INDEX lv_tabix.

  ENDLOOP.

  SORT gt_data_rout2 BY aufnr vornr plnal.

*- BOM
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @gt_data_bom2
    FROM zgtppt3040
     FOR ALL ENTRIES IN @gt_zifkey
   WHERE zifkey EQ @gt_zifkey-zifkey
     AND aufnr EQ @gt_zifkey-aufnr.

  LOOP AT gt_data_bom2 INTO gs_data_bom2.

    lv_tabix = sy-tabix.
* 자재 내역
    gs_data_bom2-maktx = zgtpp_cl_common=>get_maktx(
      iv_matnr = gs_data_bom2-matnr ).
* 앞의 0 제거(생산오더번호)
    PERFORM data_conversion USING gs_data_bom2-aufnr space space
                                                      gs_data_bom2-matnr space
                                                      gs_data_bom2-rsnum gs_data_bom2-rspos '-'.

    MODIFY gt_data_bom2 FROM gs_data_bom2 INDEX lv_tabix.

  ENDLOOP.

  SORT gt_data_bom2 BY aufnr rsnum rspos.

*- 특성
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @gt_data_char2
    FROM zgtppt3050
     FOR ALL ENTRIES IN @gt_zifkey
   WHERE zifkey EQ @gt_zifkey-zifkey
     AND aufnr EQ @gt_zifkey-aufnr.

  LOOP AT gt_data_char2 INTO gs_data_char2.

    lv_tabix = sy-tabix.
* 앞의 0 제거(생산오더번호)
    PERFORM data_conversion USING gs_data_char2-aufnr space space
                                                           space space space space '-'.

    MODIFY gt_data_char2 FROM gs_data_char2 INDEX lv_tabix.

  ENDLOOP.

  SORT gt_data_char2 BY aufnr atnam.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_alv_list
*&---------------------------------------------------------------------*
FORM update_alv_list .

  DATA : lv_lines_c TYPE c LENGTH 10.

  LOOP AT gt_row_no.

    IF p_r1 = 'X'.

      CLEAR : gs_disp_head.
      READ TABLE gt_disp_head INTO gs_disp_head INDEX gt_row_no-row_id.
      IF gs_disp_head IS NOT INITIAL.
        IF gv_result = '00' OR gv_result = '0'.
          gs_disp_head-icon = icon_led_green.
          gs_disp_head-zmessage = TEXT-m03.
        ELSE.
          gs_disp_head-icon = icon_led_red.
          gs_disp_head-zmessage = gv_message.
        ENDIF.
        MODIFY gt_disp_head FROM gs_disp_head INDEX gt_row_no-row_id.
      ENDIF.

    ELSE.

      CLEAR : gs_disp_head2.
      READ TABLE gt_disp_head2 INTO gs_disp_head2 INDEX gt_row_no-row_id.
      IF gs_disp_head2 IS NOT INITIAL.
        IF gv_result = '00' OR gv_result = '0'.
          gs_disp_head2-icon = icon_led_green.
          gs_disp_head2-zmessage = TEXT-m03.
        ELSE.
          gs_disp_head2-icon = icon_led_red.
          gs_disp_head2-zmessage = gv_message.
        ENDIF.
        MODIFY gt_disp_head2 FROM gs_disp_head2 INDEX gt_row_no-row_id.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF line_exists( gt_send_head[ zstat = '00' ] ) OR
    line_exists( gt_send_head[ zstat = '0' ] ). " 성공시

    DATA(lv_index) = lines( gt_send_head ).
    lv_lines_c = lv_index.
    CONDENSE lv_lines_c.
    MESSAGE s000 WITH lv_lines_c TEXT-m05.

  ELSE.
    MESSAGE s003 WITH TEXT-m06 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_data_to_send
*&---------------------------------------------------------------------*
FORM append_data_to_send .

  CLEAR : gt_send_head, gt_send_item, gt_send_rout, gt_send_bom, gt_send_char.
  LOOP AT gt_row_no.

    IF p_r1 = 'X'. "전송

      CLEAR : gs_disp_head, gs_send_head.
* 헤더
      READ TABLE gt_disp_head INTO gs_disp_head INDEX gt_row_no-row_id.
      IF gs_disp_head IS NOT INITIAL.

        MOVE-CORRESPONDING gs_disp_head TO gs_send_head.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = gs_send_head-zzpriority
          IMPORTING
            output = gs_send_head-zzpriority.
        APPEND gs_send_head TO gt_send_head.
* 아이템
        LOOP AT gt_data_item INTO gs_data_item
                                               WHERE aufnr EQ gs_disp_head-aufnr.
          CLEAR gs_send_item.
          MOVE-CORRESPONDING gs_data_item TO gs_send_item.
          APPEND gs_send_item TO gt_send_item.
        ENDLOOP.
* 공정
        LOOP AT gt_data_rout INTO gs_data_rout
                                               WHERE aufnr EQ gs_disp_head-aufnr.
          CLEAR gs_send_rout.
          MOVE-CORRESPONDING gs_data_rout TO gs_send_rout.
          APPEND gs_send_rout TO gt_send_rout.
        ENDLOOP.
* BOM
        LOOP AT gt_data_bom INTO gs_data_bom
                                               WHERE aufnr EQ gs_disp_head-aufnr.
          CLEAR gs_send_bom.
          MOVE-CORRESPONDING gs_data_bom TO gs_send_bom.
          PERFORM data_conversion USING space space space space space
                                                            gs_send_bom-rsnum gs_send_bom-rspos '-'.
          APPEND gs_send_bom TO gt_send_bom.
        ENDLOOP.
* 특성
        LOOP AT gt_data_char INTO gs_data_char
                                               WHERE aufnr EQ gs_disp_head-aufnr.
          CLEAR gs_send_char.
          MOVE-CORRESPONDING gs_data_char TO gs_send_char.
          APPEND gs_send_char TO gt_send_char.
        ENDLOOP.

      ENDIF.

    ELSEIF p_r2 = 'X'. "로그 조회(재처리)

      CLEAR : gs_disp_head2, gs_send_head.
      READ TABLE gt_disp_head2 INTO gs_disp_head2 INDEX gt_row_no-row_id.
      IF gs_disp_head2 IS NOT INITIAL.

        MOVE-CORRESPONDING gs_disp_head2 TO gs_send_head.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = gs_send_head-zzpriority
          IMPORTING
            output = gs_send_head-zzpriority.
        APPEND gs_send_head TO gt_send_head.
* 아이템
        LOOP AT gt_data_item2 INTO gs_data_item2
                                               WHERE zifkey EQ gs_disp_head2-zifkey
                                                    AND aufnr EQ gs_disp_head2-aufnr.
          CLEAR gs_send_item.
          MOVE-CORRESPONDING gs_data_item2 TO gs_send_item.
          APPEND gs_send_item TO gt_send_item.
        ENDLOOP.
* 공정
        LOOP AT gt_data_rout2 INTO gs_data_rout2
                                               WHERE zifkey EQ gs_disp_head2-zifkey
                                                    AND aufnr EQ gs_disp_head2-aufnr.
          CLEAR gs_send_rout.
          MOVE-CORRESPONDING gs_data_rout2 TO gs_send_rout.
          APPEND gs_send_rout TO gt_send_rout.
        ENDLOOP.
* BOM
        LOOP AT gt_data_bom2 INTO gs_data_bom2
                                               WHERE zifkey EQ gs_disp_head2-zifkey
                                                    AND aufnr EQ gs_disp_head2-aufnr.
          CLEAR gs_send_bom.
          MOVE-CORRESPONDING gs_data_bom2 TO gs_send_bom.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = gs_send_bom-rsnum
            IMPORTING
              output = gs_send_bom-rsnum.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = gs_send_bom-rspos
            IMPORTING
              output = gs_send_bom-rspos.
          APPEND gs_send_bom TO gt_send_bom.
        ENDLOOP.
* 특성
        LOOP AT gt_data_char2 INTO gs_data_char2
                                               WHERE zifkey EQ gs_disp_head2-zifkey
                                                    AND aufnr EQ gs_disp_head2-aufnr.
          CLEAR gs_send_char.
          MOVE-CORRESPONDING gs_data_char2 TO gs_send_char.
          APPEND gs_send_char TO gt_send_char.
        ENDLOOP.
      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_detail_data_double_click
*&---------------------------------------------------------------------*
FORM get_detail_data_double_click USING pv_row pv_column.

  CHECK pv_row IS NOT INITIAL.

  CLEAR : gt_disp_item, gt_disp_rout, gt_disp_bom, gt_disp_char,
               gt_disp_item2, gt_disp_rout2, gt_disp_bom2, gt_disp_char2.

  IF p_r1 = 'X'.

    CLEAR: gs_disp_head.
    READ TABLE gt_disp_head INTO gs_disp_head
                                             INDEX pv_row.
    IF sy-subrc = 0.
* 아이템
      LOOP AT gt_data_item INTO gs_data_item
                                             WHERE aufnr EQ gs_disp_head-aufnr.
        CLEAR gs_disp_item.
        MOVE-CORRESPONDING gs_data_item TO gs_disp_item.
        APPEND gs_disp_item TO gt_disp_item.
      ENDLOOP.
* 공정
      LOOP AT gt_data_rout INTO gs_data_rout
                                             WHERE aufnr EQ gs_disp_head-aufnr.
        CLEAR gs_disp_rout.
        MOVE-CORRESPONDING gs_data_rout TO gs_disp_rout.
        APPEND gs_disp_rout TO gt_disp_rout.
      ENDLOOP.
* BOM
      LOOP AT gt_data_bom INTO gs_data_bom
                                             WHERE aufnr EQ gs_disp_head-aufnr.
        CLEAR gs_disp_bom.
        MOVE-CORRESPONDING gs_data_bom TO gs_disp_bom.
        APPEND gs_disp_bom TO gt_disp_bom.
      ENDLOOP.
* 특성
      LOOP AT gt_data_char INTO gs_data_char
                                             WHERE aufnr EQ gs_disp_head-aufnr.
        CLEAR gs_disp_char.
        MOVE-CORRESPONDING gs_data_char TO gs_disp_char.
        APPEND gs_disp_char TO gt_disp_char.
      ENDLOOP.

    ENDIF.

  ELSE.

    CLEAR: gs_disp_head2.
    READ TABLE gt_disp_head2 INTO gs_disp_head2
                                             INDEX pv_row.
    IF sy-subrc = 0.
* 아이템
      LOOP AT gt_data_item2 INTO gs_data_item2
                                             WHERE zifkey EQ gs_disp_head2-zifkey
                                                  AND aufnr EQ gs_disp_head2-aufnr.
        CLEAR gs_disp_item2.
        MOVE-CORRESPONDING gs_data_item2 TO gs_disp_item2.
        APPEND gs_disp_item2 TO gt_disp_item2.
      ENDLOOP.
* 공정
      LOOP AT gt_data_rout2 INTO gs_data_rout2
                                             WHERE zifkey EQ gs_disp_head2-zifkey
                                                  AND aufnr EQ gs_disp_head2-aufnr.
        CLEAR gs_disp_rout2.
        MOVE-CORRESPONDING gs_data_rout2 TO gs_disp_rout2.
        APPEND gs_disp_rout2 TO gt_disp_rout2.
      ENDLOOP.
* BOM
      LOOP AT gt_data_bom2 INTO gs_data_bom2
                                             WHERE zifkey EQ gs_disp_head2-zifkey
                                                  AND aufnr EQ gs_disp_head2-aufnr.
        CLEAR gs_disp_bom2.
        MOVE-CORRESPONDING gs_data_bom2 TO gs_disp_bom2.
        APPEND gs_disp_bom2 TO gt_disp_bom2.
      ENDLOOP.
* 특성
      LOOP AT gt_data_char2 INTO gs_data_char2
                                             WHERE zifkey EQ gs_disp_head2-zifkey
                                                  AND aufnr EQ gs_disp_head2-aufnr.
        CLEAR gs_disp_char2.
        MOVE-CORRESPONDING gs_data_char2 TO gs_disp_char2.
        APPEND gs_disp_char2 TO gt_disp_char2.
      ENDLOOP.

    ENDIF.

  ENDIF.

  gs_scroll-row = 'X'.
  gs_scroll-col = 'X'.

  CALL METHOD gc_alv_grid1->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = gs_scroll.     "화면 라인 Refresh

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILTER_ORDER_STATUS
*&---------------------------------------------------------------------*
*& 2026.02.11.zlsgpp5. CHM2602-00022.소재 플랜트, 소재 MOM I/F 의 경우
*&    릴리즈 된 생산오더 만 MOM 전송.
*&---------------------------------------------------------------------*
FORM filter_order_status .

  DATA: lv_aufnr LIKE afko-aufnr. "생산오더번호

  LOOP AT gt_disp_head ASSIGNING FIELD-SYMBOL(<head>).
    IF <head>-zsystem_id = 'KSCM'."소재 MOM 만 처리.
      IF <head>-status NS 'REL'.  "REL이 없으면 제거.
        CLEAR: <head>-aufnr.
      ENDIF.
    ENDIF.
  ENDLOOP.
  DELETE gt_disp_head WHERE aufnr IS INITIAL.


  SORT gt_disp_head BY aufnr.
  LOOP AT gt_prod_rout ASSIGNING FIELD-SYMBOL(<rout>).
    PERFORM conversion_alpha_output USING <rout>-aufnr lv_aufnr.

    READ TABLE gt_disp_head WITH KEY aufnr = lv_aufnr
                            BINARY SEARCH
                            TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      CLEAR: <rout>-aufnr.
    ENDIF.
  ENDLOOP.
  DELETE gt_prod_rout WHERE aufnr IS INITIAL.

  LOOP AT gt_prod_char ASSIGNING FIELD-SYMBOL(<char>).
    PERFORM conversion_alpha_output USING <char>-aufnr lv_aufnr.

    READ TABLE gt_disp_head WITH KEY aufnr = lv_aufnr
                            BINARY SEARCH
                            TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      CLEAR: <char>-aufnr.
    ENDIF.
  ENDLOOP.
  DELETE gt_prod_char WHERE aufnr IS INITIAL.

  LOOP AT gt_afpo ASSIGNING FIELD-SYMBOL(<afpo>).
    PERFORM conversion_alpha_output USING <afpo>-aufnr lv_aufnr.

    READ TABLE gt_disp_head WITH KEY aufnr = lv_aufnr
                            BINARY SEARCH
                            TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      CLEAR: <afpo>-aufnr.
    ENDIF.
  ENDLOOP.
  DELETE gt_afpo WHERE aufnr IS INITIAL.

ENDFORM.
*&---------------------------------------------------------------------*
*&  Form CONVERSION_ALPHA_INPUT
*&---------------------------------------------------------------------*
* 12345 -> 0000012345
*&---------------------------------------------------------------------*
FORM conversion_alpha_input USING p_in p_out.

  CHECK p_in IS NOT INITIAL.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_in
    IMPORTING
      output = p_out.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_ALPHA_OUTPUT
*&---------------------------------------------------------------------*
* 0000012345  ->  12345
*&---------------------------------------------------------------------*
FORM conversion_alpha_output USING p_in p_out.

  CHECK p_in IS NOT INITIAL.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = p_in
    IMPORTING
      output = p_out.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_additional_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_additional_data .

*// 코드마스터로 계획오더 전송 대상 플랜트인지 확인.
  DATA(lt_zgtppt1010) = zgtpp_cl_common=>get_code_value( iv_codegrp = '2100' ).  " 코드 그룹

  DELETE lt_zgtppt1010 WHERE fld_01 NOT IN gr_werks.

  CHECK lt_zgtppt1010 IS NOT INITIAL.

  CHECK VALUE #( lt_zgtppt1010[ 1 ]-fld_02 OPTIONAL ) IS NOT INITIAL.

  PERFORM get_planed_order.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_planed_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_planed_order .

*// 계획오더 추출 대상 자재 CBO Table 추출.
  DATA lt_plaf  TYPE ty_t_plaf.
  DATA lt_resb  TYPE ty_t_resb.
  DATA lt_pstmp TYPE RANGE OF plaf-pstmp.

*// 생산시작일자.
  PERFORM set_timestamp_range USING: s_erdat[] lt_pstmp,
                                     s_udate[] lt_pstmp.

  LOOP AT lt_pstmp REFERENCE INTO DATA(lr_pstmp).
    IF lr_pstmp->option EQ 'EQ' AND
       lr_pstmp->low  IS NOT INITIAL AND
       lr_pstmp->high IS NOT INITIAL.
      lr_pstmp->option = 'BT'.
    ENDIF.
  ENDLOOP.

  SELECT plaf~*, makt~maktx AS maktx,
*** Start 2026.07.01 계획오더 필드 추가 By ZGISPP03
               b~inlength, b~qlength, b~clength, b~infactor
*** End 2026.07.01 계획오더 필드 추가 By ZGISPP03
    INTO CORRESPONDING FIELDS OF TABLE @lt_plaf
    FROM zgtppt2350 AS zt01
    JOIN plaf
      ON zt01~matnr EQ plaf~matnr
     AND zt01~werks EQ plaf~plwrk
    LEFT JOIN makt
      ON plaf~matnr EQ makt~matnr
     AND makt~spras EQ @sy-langu
*** Start 2026.07.01 계획오더 필드 추가 By ZGISPP03
    LEFT JOIN zgtppt2330 AS b
      ON b~plnum = plaf~plnum
*** End 2026.07.01 계획오더 필드 추가 By ZGISPP03
   WHERE zt01~matnr IN @s_matnr
     AND plaf~paart EQ 'LA'
     AND plaf~psttr IN @s_gstrp   "// 생산시작일자.
     AND plaf~pstmp IN @lt_pstmp. "// 오더생성일자, 상태변경일자.

  CHECK lt_plaf IS NOT INITIAL.

  SELECT resb~*, makt~maktx AS maktx
    FROM @lt_plaf AS zt01
    JOIN resb
      ON zt01~rsnum EQ resb~rsnum
*// Modified by ZGODEV06 on 2026-06-23 {
     AND resb~dumps EQ @space   "// 가상품목 제외
     AND resb~schgt EQ @space   "// 벌크자재 제외
*// }
    LEFT JOIN makt
      ON resb~matnr EQ makt~matnr
     AND makt~spras EQ @sy-langu
   ORDER BY resb~rsnum
    INTO CORRESPONDING FIELDS OF TABLE @lt_resb.

  LOOP AT lt_plaf INTO DATA(ls_plaf).
*// 오더 헤더.
    PERFORM set_order_header_from_plaf USING ls_plaf.

*// 오더 품목.
    PERFORM set_order_item_from_plaf USING ls_plaf.

*// 오더 작업.
    PERFORM set_order_routing_from_plaf USING ls_plaf.

*// 오더 BOM.
    PERFORM set_order_bom_from_plaf USING lt_resb ls_plaf.

*// 오더 특성.
    PERFORM set_order_char_from_plaf USING ls_plaf.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_timestamp_range
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_timestamp_range  USING pt_range     TYPE cl_satc_time_range_svc=>ty_t_date_range
                                pt_timestamp TYPE cl_satc_time_range_svc=>ty_t_timestamp_range.

  CHECK pt_range[] IS NOT INITIAL.

  cl_satc_time_range_svc=>convert_date_2_timestamp( EXPORTING i_date_range      = s_erdat[]
                                                              i_time_zone       = sy-zonlo
                                                    IMPORTING e_timestamp_range = DATA(lt_timestamp) ).

  CHECK lt_timestamp[] IS NOT INITIAL.

  APPEND LINES OF lt_timestamp TO pt_timestamp.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM read_text  USING  pv_aufnr pv_ztext.
  DATA ls_header TYPE thead.
  DATA lt_lines  TYPE TABLE OF tline.

*** Start. 2026.07.10 KSW 오더 특기사항 추가
  DATA lv_name TYPE thead-tdname.
  lv_name = |{ sy-mandt }{ pv_aufnr }|.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'KOPF'
      language                = sy-langu
      name                    = lv_name
*     NAME                    = CONV TDOBNAME( PV_AUFNR )
*** End 2026.07.10 KSW 오더 특기사항 추가
      object                  = 'AUFK'
    IMPORTING
      header                  = ls_header
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  LOOP AT lt_lines INTO DATA(ls_line).
    IF pv_ztext IS INITIAL.
      pv_ztext = ls_line-tdline.
    ELSE.
      pv_ztext = |{ pv_ztext } / { ls_line-tdline }|.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_order_bom_from_plaf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_order_bom_from_plaf  USING pt_resb TYPE ty_t_resb
                                    ps_plaf TYPE ty_s_plaf.

  READ TABLE pt_resb TRANSPORTING NO FIELDS WITH KEY rsnum = ps_plaf-rsnum.

  CHECK sy-subrc IS INITIAL.

  LOOP AT pt_resb INTO DATA(ls_resb)
                  FROM sy-tabix.
    IF ls_resb-rsnum NE ps_plaf-rsnum.
      EXIT.
    ENDIF.

    APPEND INITIAL LINE TO gt_data_bom REFERENCE INTO DATA(lr_data_bom).
    lr_data_bom->* = VALUE #( aufnr = |{ ps_plaf-plnum ALPHA = OUT }|
                              rsnum = ls_resb-rsnum
                              rspos = ls_resb-rspos
                              matnr = |{ ls_resb-matnr ALPHA = OUT }|
                              maktx = ls_resb-maktx
                              erfmg = ls_resb-bdmng
                              erfme = ls_resb-meins
                              lgort = ls_resb-lgort
                              charg = ls_resb-charg
                              xloek = ls_resb-xloek
                              rgekz = ls_resb-rgekz ).
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_order_char_from_plaf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_order_char_from_plaf  USING  ps_plaf TYPE ty_s_plaf.
  DATA lt_configuration	TYPE TABLE OF conf_out.

  CHECK ps_plaf-cuobj IS NOT INITIAL.

  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      instance      = ps_plaf-cuobj
    TABLES
      configuration = lt_configuration.

  LOOP AT lt_configuration INTO DATA(ls_configuration).
    APPEND INITIAL LINE TO gt_data_char REFERENCE INTO DATA(lr_data_char).
    lr_data_char->* = VALUE #( aufnr = |{ ps_plaf-plnum ALPHA = OUT }|
                               class = '1'
                               atnam = ls_configuration-atnam
                               atbez = ls_configuration-atbez
                               atwrt = ls_configuration-atwrt
                               atwtb = ls_configuration-atwtb ).
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_order_header_from_plaf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_order_header_from_plaf  USING  ps_plaf TYPE ty_s_plaf.

  APPEND INITIAL LINE TO gt_disp_head REFERENCE INTO DATA(lr_disp_head).

  lr_disp_head->* = VALUE #( icon            = icon_led_inactive
                             zsystem_id      = gv_zsystem_id
                             zsystem_id_desc = gv_zsystem_id_desc
                             werks           = ps_plaf-plwrk
                             aufnr           = |{ ps_plaf-plnum ALPHA = OUT }|
                             auart           = 'PLAN'
                             status          = 'REL'
                             dispo           = ps_plaf-dispo
                             fevor           = ps_plaf-plgrp
                             gamng           = ps_plaf-gsmng
                             gmein           = ps_plaf-meins
                             gstrp           = ps_plaf-psttr
                             gltrp           = ps_plaf-pedtr
                             gstrs           = ps_plaf-psttr
                             gltrs           = ps_plaf-pedtr
                             ztext           = ps_plaf-ptext ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_order_item_from_plaf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_order_item_from_plaf  USING  ps_plaf TYPE ty_s_plaf.

  APPEND INITIAL LINE TO gt_data_item REFERENCE INTO DATA(lr_data_item).

  lr_data_item->* = VALUE #( aufnr   = |{ ps_plaf-plnum ALPHA = OUT }|
                             posnr   = '0001'
                             matnr   = |{ ps_plaf-matnr ALPHA = OUT }|
                             maktx   = ps_plaf-maktx
                             lgort   = ps_plaf-lgort
*** Start 2026.07.01 계획오더 필드 추가 By ZGISPP03
                             mwert11 = ps_plaf-inlength
                             psamg   = ps_plaf-qlength
                             mwert21 = ps_plaf-clength
                             mwert22 = ps_plaf-infactor
*** End 2026.07.01 계획오더 필드 추가 By ZGISPP03
                             psmng   = ps_plaf-gsmng ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_order_routing_from_plaf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_order_routing_from_plaf  USING  ps_plaf TYPE ty_s_plaf.
  DATA lv_plnfl TYPE numc06.

  READ TABLE gt_zgtcvmstval INTO DATA(ls_zgtcvmstval) WITH KEY werks = ps_plaf-plwrk
                                                               matnr = ps_plaf-matnr BINARY SEARCH.
  CHECK sy-subrc IS INITIAL.

  LOOP AT gt_crhd INTO DATA(gs_crhd)
                 WHERE werks      EQ ps_plaf-plwrk
                   AND arbpl+0(3) EQ ls_zgtcvmstval-pdcaproccode
                   AND veran+0(2) EQ ps_plaf-dispo+0(2).
    lv_plnfl += 1.

    APPEND INITIAL LINE TO gt_data_rout REFERENCE INTO DATA(lr_data_rout).
    lr_data_rout->* = VALUE #( aufnr = |{ ps_plaf-plnum ALPHA = OUT }|
                               vornr = '0000'
                               plnal = '00'
                               plnfl = lv_plnfl
                               arbpl = gs_crhd-arbpl
                               ktext = gs_crhd-ktext
                               veran = gs_crhd-veran ).
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form string_replace
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM string_replace  USING  pv_atwrt.

  CHECK pv_atwrt IS NOT INITIAL.

  CALL FUNCTION 'STRING_REPLACE'
    EXPORTING
      pattern             = ','
      substitute          = ''
    CHANGING
      text                = pv_atwrt
    EXCEPTIONS
      wrong_string_length = 1
      OTHERS              = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_system_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_system_info.

  CASE abap_true.
    WHEN p_r3.
      gv_zsystem_id = 'KPCM'.
    WHEN p_r4.
      gv_zsystem_id = 'KBDM'.
    WHEN p_r9.
      gv_zsystem_id = 'KSCM'.
    WHEN p_r10.
      gv_zsystem_id = 'KGPM'.
    WHEN p_r11.
      gv_zsystem_id = 'KGOM'.
    WHEN p_r12. "한미소 MOM 260831
      gv_zsystem_id = 'KFCM'.
  ENDCASE.

* 시스템 내역
  gv_zsystem_id_desc = zgtpp_cl_common=>get_domain_text( iv_domname  = 'ZGTDTARGET' " 도메인이름
                                                         iv_domvalue = CONV #( gv_zsystem_id ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_GAON_MES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_gaon_mes .

  DATA : lv_seleced_line TYPE i.
  DATA : lv_index TYPE i.
  DATA : lt_row_no TYPE lvc_t_roid.
  DATA : lv_current_cnt TYPE i.
  DATA : lv_succ_cnt TYPE i.
  DATA : lv_lines_c TYPE c LENGTH 10.

  lv_seleced_line = lines( gt_row_no[] ).

  CLEAR : gt_send_head, gt_send_item, gt_send_rout, gt_send_bom, gt_send_char.
  LOOP AT gt_row_no.
    APPEND gt_row_no TO lt_row_no.
    ADD 1 TO lv_index.

    IF p_r1 = 'X'. "전송

      CLEAR : gs_disp_head, gs_send_head.
* 헤더
      READ TABLE gt_disp_head INTO gs_disp_head INDEX gt_row_no-row_id.
      IF sy-subrc EQ 0..

        MOVE-CORRESPONDING gs_disp_head TO gs_send_head.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = gs_send_head-zzpriority
          IMPORTING
            output = gs_send_head-zzpriority.
*** 2026.08.31 Start ZZORIGIN 000 제거
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = gs_send_head-zzorigin
          IMPORTING
            output = gs_send_head-zzorigin.
*** 2026.08.31 End ZZORIGIN 000 제거
        APPEND gs_send_head TO gt_send_head.
      ENDIF.
    ELSEIF p_r2 = 'X'. "로그 조회(재처리)
      CLEAR : gs_disp_head2, gs_send_head.
      READ TABLE gt_disp_head2 INTO gs_disp_head2 INDEX gt_row_no-row_id.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING gs_disp_head2 TO gs_send_head.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = gs_send_head-zzpriority
          IMPORTING
            output = gs_send_head-zzpriority.
*** 2026.08.31 Start ZZORIGIN 000 제거
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = gs_send_head-zzorigin
          IMPORTING
            output = gs_send_head-zzorigin.
*** 2026.08.31 End ZZORIGIN 000 제거
        APPEND gs_send_head TO gt_send_head.
      ENDIF.
    ENDIF.

    IF lines( gt_send_head[] ) = 10.
      REFRESH : gt_send_item, gt_send_rout, gt_send_bom, gt_send_char.

      LOOP AT gt_send_head INTO DATA(ls_mosu).
        IF p_r1 = 'X'. "전송
* 아이템
          LOOP AT gt_data_item INTO gs_data_item
                                                 WHERE aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_item.
            MOVE-CORRESPONDING gs_data_item TO gs_send_item.
            APPEND gs_send_item TO gt_send_item.
          ENDLOOP.
* 공정
          LOOP AT gt_data_rout INTO gs_data_rout
                                                 WHERE aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_rout.
            MOVE-CORRESPONDING gs_data_rout TO gs_send_rout.
            APPEND gs_send_rout TO gt_send_rout.
          ENDLOOP.
* BOM
          LOOP AT gt_data_bom INTO gs_data_bom
                                                 WHERE aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_bom.
            MOVE-CORRESPONDING gs_data_bom TO gs_send_bom.
            PERFORM data_conversion USING space space space space space
                                                              gs_send_bom-rsnum gs_send_bom-rspos '-'.
            APPEND gs_send_bom TO gt_send_bom.
          ENDLOOP.
* 특성
          LOOP AT gt_data_char INTO gs_data_char
                                                 WHERE aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_char.
            MOVE-CORRESPONDING gs_data_char TO gs_send_char.
            APPEND gs_send_char TO gt_send_char.
          ENDLOOP.

        ELSEIF p_r2 = 'X'. "로그 조회(재처리)

* 아이템
          LOOP AT gt_data_item2 INTO gs_data_item2
                                                 WHERE zifkey EQ ls_mosu-zifkey
                                                      AND aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_item.
            MOVE-CORRESPONDING gs_data_item2 TO gs_send_item.
            APPEND gs_send_item TO gt_send_item.
          ENDLOOP.
* 공정
          LOOP AT gt_data_rout2 INTO gs_data_rout2
                                                 WHERE zifkey EQ ls_mosu-zifkey
                                                      AND aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_rout.
            MOVE-CORRESPONDING gs_data_rout2 TO gs_send_rout.
            APPEND gs_send_rout TO gt_send_rout.
          ENDLOOP.
* BOM
          LOOP AT gt_data_bom2 INTO gs_data_bom2
                                                 WHERE zifkey EQ ls_mosu-zifkey
                                                      AND aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_bom.
            MOVE-CORRESPONDING gs_data_bom2 TO gs_send_bom.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = gs_send_bom-rsnum
              IMPORTING
                output = gs_send_bom-rsnum.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = gs_send_bom-rspos
              IMPORTING
                output = gs_send_bom-rspos.
            APPEND gs_send_bom TO gt_send_bom.
          ENDLOOP.
* 특성
          LOOP AT gt_data_char2 INTO gs_data_char2
                                                 WHERE zifkey EQ ls_mosu-zifkey
                                                      AND aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_char.
            MOVE-CORRESPONDING gs_data_char2 TO gs_send_char.
            APPEND gs_send_char TO gt_send_char.
          ENDLOOP.

        ENDIF.
      ENDLOOP.

      CLEAR : gv_result, gv_message.
* 데이터 전송 후 로그 히스토리 업데이트
      PERFORM call_rfc TABLES gt_send_head
                                         gt_send_item
                                         gt_send_rout
                                         gt_send_bom
                                         gt_send_char.

* 출력 화면 리프레쉬
      LOOP AT lt_row_no INTO DATA(ls_row_no).
        IF p_r1 = 'X'. "전송
          READ TABLE gt_disp_head ASSIGNING FIELD-SYMBOL(<ls_disp_head>) INDEX ls_row_no-row_id.
          IF sy-subrc EQ 0.
            IF gv_result = '00' OR gv_result = '0'.
              <ls_disp_head>-icon = icon_led_green.
              <ls_disp_head>-zmessage = TEXT-m03.
            ELSE.
              <ls_disp_head>-icon = icon_led_red.
              <ls_disp_head>-zmessage = gv_message.
            ENDIF.
          ENDIF.

        ELSEIF p_r2 = 'X'. "로그 조회(재처리)
          READ TABLE gt_disp_head2 ASSIGNING FIELD-SYMBOL(<ls_disp_head2>) INDEX ls_row_no-row_id.
          IF sy-subrc EQ 0.
            IF gv_result = '00' OR gv_result = '0'.
              <ls_disp_head2>-icon = icon_led_green.
              <ls_disp_head2>-zmessage = TEXT-m03.
            ELSE.
              <ls_disp_head2>-icon = icon_led_red.
              <ls_disp_head2>-zmessage = gv_message.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF gv_result = '00' OR gv_result = '0'.
        CLEAR lv_current_cnt.
        lv_current_cnt = lines( gt_send_head ).
        ADD lv_current_cnt TO lv_succ_cnt.
      ENDIF.

      REFRESH lt_row_no.
      REFRESH gt_send_head.

      WAIT UP TO 1 SECONDS.

    ENDIF.





* 마지막 선택구간시 전체건 전부 전송
    IF lv_seleced_line = lv_index AND gt_send_head[] IS NOT INITIAL.
      REFRESH : gt_send_item, gt_send_rout, gt_send_bom, gt_send_char.

      LOOP AT gt_send_head INTO ls_mosu.
        IF p_r1 = 'X'. "전송
* 아이템
          LOOP AT gt_data_item INTO gs_data_item
                                                 WHERE aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_item.
            MOVE-CORRESPONDING gs_data_item TO gs_send_item.
            APPEND gs_send_item TO gt_send_item.
          ENDLOOP.
* 공정
          LOOP AT gt_data_rout INTO gs_data_rout
                                                 WHERE aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_rout.
            MOVE-CORRESPONDING gs_data_rout TO gs_send_rout.
            APPEND gs_send_rout TO gt_send_rout.
          ENDLOOP.
* BOM
          LOOP AT gt_data_bom INTO gs_data_bom
                                                 WHERE aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_bom.
            MOVE-CORRESPONDING gs_data_bom TO gs_send_bom.
            PERFORM data_conversion USING space space space space space
                                                              gs_send_bom-rsnum gs_send_bom-rspos '-'.
            APPEND gs_send_bom TO gt_send_bom.
          ENDLOOP.
* 특성
          LOOP AT gt_data_char INTO gs_data_char
                                                 WHERE aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_char.
            MOVE-CORRESPONDING gs_data_char TO gs_send_char.
            APPEND gs_send_char TO gt_send_char.
          ENDLOOP.

        ELSEIF p_r2 = 'X'. "로그 조회(재처리)

* 아이템
          LOOP AT gt_data_item2 INTO gs_data_item2
                                                 WHERE zifkey EQ ls_mosu-zifkey
                                                      AND aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_item.
            MOVE-CORRESPONDING gs_data_item2 TO gs_send_item.
            APPEND gs_send_item TO gt_send_item.
          ENDLOOP.
* 공정
          LOOP AT gt_data_rout2 INTO gs_data_rout2
                                                 WHERE zifkey EQ ls_mosu-zifkey
                                                      AND aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_rout.
            MOVE-CORRESPONDING gs_data_rout2 TO gs_send_rout.
            APPEND gs_send_rout TO gt_send_rout.
          ENDLOOP.
* BOM
          LOOP AT gt_data_bom2 INTO gs_data_bom2
                                                 WHERE zifkey EQ ls_mosu-zifkey
                                                      AND aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_bom.
            MOVE-CORRESPONDING gs_data_bom2 TO gs_send_bom.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = gs_send_bom-rsnum
              IMPORTING
                output = gs_send_bom-rsnum.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = gs_send_bom-rspos
              IMPORTING
                output = gs_send_bom-rspos.
            APPEND gs_send_bom TO gt_send_bom.
          ENDLOOP.
* 특성
          LOOP AT gt_data_char2 INTO gs_data_char2
                                                 WHERE zifkey EQ ls_mosu-zifkey
                                                      AND aufnr EQ ls_mosu-aufnr.
            CLEAR gs_send_char.
            MOVE-CORRESPONDING gs_data_char2 TO gs_send_char.
            APPEND gs_send_char TO gt_send_char.
          ENDLOOP.

        ENDIF.
      ENDLOOP.

      CLEAR : gv_result, gv_message.
* 데이터 전송 후 로그 히스토리 업데이트
      PERFORM call_rfc TABLES gt_send_head
                                         gt_send_item
                                         gt_send_rout
                                         gt_send_bom
                                         gt_send_char.

* 출력 화면 리프레쉬
      LOOP AT lt_row_no INTO ls_row_no.
        IF p_r1 = 'X'. "전송
          READ TABLE gt_disp_head ASSIGNING <ls_disp_head> INDEX ls_row_no-row_id.
          IF sy-subrc EQ 0.
            IF gv_result = '00' OR gv_result = '0'.
              <ls_disp_head>-icon = icon_led_green.
              <ls_disp_head>-zmessage = TEXT-m03.
            ELSE.
              <ls_disp_head>-icon = icon_led_red.
              <ls_disp_head>-zmessage = gv_message.
            ENDIF.
          ENDIF.

        ELSEIF p_r2 = 'X'. "로그 조회(재처리)
          READ TABLE gt_disp_head2 ASSIGNING <ls_disp_head2> INDEX ls_row_no-row_id.
          IF sy-subrc EQ 0.
            IF gv_result = '00' OR gv_result = '0'.
              <ls_disp_head2>-icon = icon_led_green.
              <ls_disp_head2>-zmessage = TEXT-m03.
            ELSE.
              <ls_disp_head2>-icon = icon_led_red.
              <ls_disp_head2>-zmessage = gv_message.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF gv_result = '00' OR gv_result = '0'.
        CLEAR lv_current_cnt.
        lv_current_cnt = lines( gt_send_head ).
        ADD lv_current_cnt TO lv_succ_cnt.
      ENDIF.

      REFRESH lt_row_no.
      REFRESH gt_send_head.

    ENDIF.
  ENDLOOP.

  IF lv_succ_cnt > 0.
    lv_lines_c = lv_succ_cnt.
    CONDENSE lv_lines_c.
    MESSAGE s000 WITH lv_lines_c TEXT-m05.
  ELSE.
    MESSAGE s003 WITH TEXT-m06 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
