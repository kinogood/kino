*&---------------------------------------------------------------------*
*& Include          ZGTPPR3000F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_default_layout
*&---------------------------------------------------------------------*
*& 기본 레이아웃 가져옴.
*&---------------------------------------------------------------------*
FORM get_default_layout CHANGING pv_layo.

  IF pv_layo IS NOT INITIAL.

    CALL METHOD go_grid_0100->set_table_for_first_display
      EXPORTING
        is_layout = pv_layo
      CHANGING
        it_outtab = gt_disp[].

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_alv_variant
*&---------------------------------------------------------------------*
*& 레이아웃 선택
*&---------------------------------------------------------------------*
FORM select_alv_variant  CHANGING pv_layo TYPE disvariant-variant.

  DATA: ls_variant TYPE disvariant.

  ls_variant-report = sy-repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant    = ls_variant
      i_save        = 'A'
    IMPORTING
      es_variant    = ls_variant
    EXCEPTIONS
      not_found     = 1
      program_error = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    pv_layo = ls_variant-variant.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& 생산 백로그 정보 발췌
*&---------------------------------------------------------------------*
FORM get_data .

  DATA : lv_msgcode(100),
         lv_error,
         lv_tabix LIKE sy-tabix.
  DATA : lv_ename   LIKE gs_disp-ename,
         ls_zpa0539 LIKE zpa0539.
  DATA : BEGIN OF ls_aufnr,
           aufnr LIKE afko-aufnr,
           werks LIKE aufk-werks,
         END OF ls_aufnr.
  DATA : lt_aufnr LIKE TABLE OF ls_aufnr.

* AFFW, AFKO, AFPO, AUFK JOIN 해서 백로그 데이터 취합
  SELECT b~*, a~plnbez AS pmatnr, e~matkl, f~del_reason
    INTO TABLE @DATA(lt_data)
    FROM afko AS a
        INNER JOIN affw AS b  ON a~aufnr = b~aufnr
        INNER JOIN aufk AS d  ON a~aufnr = d~aufnr
        INNER JOIN mara AS e  ON b~matnr = e~matnr
        LEFT OUTER JOIN zgtppt3000 AS f ON  b~weblnr = f~weblnr
                                        AND b~weblpos = f~weblpos
   WHERE d~werks  EQ @p_werks "조회조건-플랜트
     AND a~dispo  IN @s_dispo "조회조건-MRP관리자
     AND a~aufnr  IN @s_aufnr "조회조건-생산오더번호
     AND a~plnbez IN @s_matnr "조회조건-품목코드
     AND b~lgort  IN @s_lgort "조회조건-저장위치
     AND b~matnr  IN @s_matnr2 "조회조건-자재코드
     AND b~bwart  IN @s_bwart "조회조건-이동유형
     AND b~ersda  IN @s_ersda "조회조건-오류 발생일자
     AND b~budat  IN @s_budat "조회조건-전기일자
     AND b~dispo  IN @s_dispo2. "조회조건-MRP관리자

  CLEAR : ls_aufnr, lt_aufnr, gs_marc, gt_marc, gs_marc2, gt_marc2.
  LOOP AT lt_data INTO DATA(ls_data).
    ls_aufnr-aufnr = ls_data-b-aufnr.
    ls_aufnr-werks = ls_data-b-werks.
    APPEND ls_aufnr TO lt_aufnr.
    gs_marc-matnr = ls_data-b-matnr.
    gs_marc-werks = ls_data-b-werks.
    APPEND gs_marc TO gt_marc.
  ENDLOOP.

  SORT lt_aufnr BY aufnr werks.
  DELETE ADJACENT DUPLICATES FROM lt_aufnr COMPARING ALL FIELDS.
  SORT gt_marc BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM gt_marc COMPARING ALL FIELDS.

  IF lt_aufnr[] IS NOT INITIAL.
    SELECT aufnr, pdcaproccode INTO TABLE @DATA(lt_gong)
      FROM zgtcvordsyval
      FOR ALL ENTRIES IN @lt_aufnr
      WHERE aufnr EQ @lt_aufnr-aufnr
        AND werks EQ @lt_aufnr-werks
        AND pdcaproccode IN @s_gong.
  ENDIF.

  IF gt_marc[] IS NOT INITIAL.
    SELECT matnr, werks, xchar, xchpf, dpcbt
      INTO CORRESPONDING FIELDS OF TABLE @gt_marc2
      FROM marc
      FOR ALL ENTRIES IN @gt_marc
      WHERE matnr EQ @gt_marc-matnr
        AND werks EQ @gt_marc-werks.
  ENDIF.

* 조회된 데이터 기준으로 Lock Object 처리하여 다른 사용자가 처리할 수 없도록 함.
  LOOP AT lt_data INTO ls_data.

    lv_tabix = sy-tabix.

    READ TABLE lt_gong INTO DATA(ls_gong) WITH KEY aufnr = ls_data-b-aufnr.
    IF sy-subrc = 0.
* 배치 모드일 때는 자재 Lock 수행하지 말 것
      IF p_chk IS INITIAL.

        CALL FUNCTION 'ENQUEUE_EZGT_ZGTPPR3000'
          EXPORTING
            werks  = ls_data-b-werks
            matnr  = ls_data-b-matnr
          EXCEPTIONS
            OTHERS = 3.

        IF sy-subrc <> 0.

          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              input  = ls_data-b-matnr
            IMPORTING
              output = ls_data-b-matnr.

          CLEAR : lv_ename, ls_zpa0539.
          SELECT SINGLE * INTO CORRESPONDING FIELDS OF @ls_zpa0539
                          FROM zpa0539
                          WHERE pernr EQ @sy-msgv1.
          IF ls_zpa0539 IS NOT INITIAL.
            lv_ename = ls_zpa0539-lnmhg && ls_zpa0539-fnmhg.
          ENDIF.

          CONCATENATE TEXT-t01 ls_data-b-werks
                      TEXT-t02 ls_data-b-matnr
                      TEXT-t03 sy-msgv1 lv_ename
                      TEXT-t04 INTO lv_msgcode SEPARATED BY space.

          MESSAGE i000 WITH lv_msgcode.
          lv_error = 'X'.
          EXIT.

        ENDIF.

      ENDIF.

    ELSE.

      DELETE lt_data INDEX lv_tabix.

    ENDIF.

  ENDLOOP.

* 이미 처리중인 데이터가 없을 경우 ALV 데이터로 취합
  CHECK lv_error IS INITIAL.
* 마스터 정보 취합
  PERFORM get_master_data.

  CLEAR : gs_disp, gt_disp[].
  LOOP AT lt_data INTO ls_data.

    MOVE-CORRESPONDING ls_data-b TO gs_disp.

    "상태
    gs_disp-icon = icon_led_red.

    "SRM2511-10071 메시지가 없을 경우 로직 추가.
    IF gs_disp-msgid IS INITIAL.
      gs_disp-message = TEXT-m30.
    ELSE.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = gs_disp-msgid
          msgnr               = gs_disp-msgno
          msgv1               = gs_disp-msgv1
          msgv2               = gs_disp-msgv2
          msgv3               = gs_disp-msgv3
          msgv4               = gs_disp-msgv4
        IMPORTING
          message_text_output = gs_disp-message.
    ENDIF.

    "오류 유형
    gs_disp-gubun = TEXT-008.

    gs_disp-pmatnr = ls_data-pmatnr.
    gs_disp-matkl  = ls_data-matkl.
    gs_disp-del_reason = ls_data-del_reason.

    "플랜트 내역
    SELECT SINGLE name1 INTO gs_disp-name1 FROM t001w
                        WHERE werks EQ gs_disp-werks.

    "MRP관리자 내역
    SELECT SINGLE dsnam INTO gs_disp-dsnam FROM t024d
                        WHERE werks EQ gs_disp-werks
                          AND dispo EQ gs_disp-dispo.

    "삭제 사유 내역
    CLEAR gs_zgtppt1010.
    READ TABLE gt_zgtppt1010 INTO gs_zgtppt1010
                             WITH KEY fld_02 = gs_disp-del_reason.
    IF gs_zgtppt1010 IS NOT INITIAL.
      gs_disp-reason_text = gs_zgtppt1010-fld_03.
    ENDIF.

    "오류 생성자 명
    CLEAR : gs_zpa0539.
    READ TABLE gt_zpa0539 INTO gs_zpa0539
                          WITH KEY pernr = gs_disp-ernam.
    IF gs_zpa0539 IS NOT INITIAL.
      gs_disp-ename = gs_zpa0539-lnmhg && gs_zpa0539-fnmhg.
    ENDIF.

    "최종 변경자 명
    CLEAR : gs_zpa0539.
    READ TABLE gt_zpa0539 INTO gs_zpa0539
                          WITH KEY pernr = gs_disp-aenam.
    IF gs_zpa0539 IS NOT INITIAL.
      gs_disp-cname = gs_zpa0539-lnmhg && gs_zpa0539-fnmhg.
    ENDIF.

    "자재 내역
    gs_disp-maktx = zgtpp_cl_common=>get_maktx(
                          iv_matnr = gs_disp-matnr ).

    "자재 그룹 내역
    SELECT SINGLE wgbez60 INTO gs_disp-wgbez60
                          FROM t023t
                          WHERE spras EQ sy-langu
                            AND matkl EQ gs_disp-matkl.
    "오류 수량
    gs_disp-gimng = ls_data-b-erfmg.

    "투입 완료 수량
    gs_disp-enmng = 0.

    "품목명
    gs_disp-maktx2 = zgtpp_cl_common=>get_maktx(
                           iv_matnr = gs_disp-pmatnr ).

    "배치 관리 지시자
    CLEAR gs_marc2.
    READ TABLE gt_marc2 INTO gs_marc2
                        WITH KEY werks = gs_disp-werks
                                 matnr = gs_disp-matnr.
    IF gs_marc2 IS NOT INITIAL.
      gs_disp-xchar = gs_marc2-xchar.
    ENDIF.

    PERFORM set_cell_attribute.

    APPEND gs_disp TO gt_disp.
    CLEAR gs_disp.

  ENDLOOP.

* 실투입 오류 데이터 추가 취합
  SELECT b~*, a~plnbez AS pmatnr, e~matkl
    INTO TABLE @DATA(lt_data2)
    FROM afko AS a
      INNER JOIN zgtppt3100 AS b  ON a~aufnr = b~aufnr
      INNER JOIN aufk AS d        ON a~aufnr = d~aufnr
      INNER JOIN mara AS e        ON b~matnr = e~matnr
   WHERE d~werks  EQ @p_werks "조회조건-플랜트
     AND a~dispo  IN @s_dispo "조회조건-MRP관리자
     AND a~aufnr  IN @s_aufnr "조회조건-생산오더번호
     AND a~plnbez IN @s_matnr "조회조건-품목코드
     AND b~lgort  IN @s_lgort "조회조건-저장위치
     AND b~matnr  IN @s_matnr2 "조회조건-자재코드
     AND b~bwart  IN @s_bwart "조회조건-이동유형
     AND b~ersda  IN @s_ersda "조회조건-오류 발생일자
     AND b~budat  IN @s_budat "조회조건-전기일자
     AND b~dispo  IN @s_dispo2. "조회조건-MRP관리자
*    AND b~process NE 'R'.

  CLEAR : ls_aufnr, lt_aufnr, gs_marc, gt_marc.
  LOOP AT lt_data2 INTO DATA(ls_data2).
    ls_aufnr-aufnr = ls_data2-b-aufnr.
    ls_aufnr-werks = ls_data2-b-werks.
    APPEND ls_aufnr TO lt_aufnr.
    gs_marc-matnr = ls_data2-b-matnr.
    gs_marc-werks = ls_data2-b-werks.
    APPEND gs_marc TO gt_marc.
  ENDLOOP.

  SORT lt_aufnr BY aufnr werks.
  DELETE ADJACENT DUPLICATES FROM lt_aufnr COMPARING ALL FIELDS.
  SORT gt_marc BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM gt_marc COMPARING ALL FIELDS.

  IF lt_aufnr[] IS NOT INITIAL.

    SELECT aufnr, pdcaproccode INTO TABLE @lt_gong
      FROM zgtcvordsyval
      FOR ALL ENTRIES IN @lt_aufnr
      WHERE aufnr        EQ @lt_aufnr-aufnr
        AND werks        EQ @lt_aufnr-werks
        AND pdcaproccode IN @s_gong.

  ENDIF.

  IF gt_marc[] IS NOT INITIAL.

    SELECT matnr, werks, xchar, xchpf, dpcbt
      APPENDING CORRESPONDING FIELDS OF TABLE @gt_marc2
      FROM marc
      FOR ALL ENTRIES IN @gt_marc
      WHERE matnr EQ @gt_marc-matnr
        AND werks EQ @gt_marc-werks.

  ENDIF.

  SORT gt_marc2 BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM gt_marc2 COMPARING matnr werks.
* 조회된 데이터 기준으로 Lock Object 처리하여 다른 사용자가 처리할 수 없도록 함.
  LOOP AT lt_data2 INTO ls_data2.

    lv_tabix = sy-tabix.

    CLEAR ls_gong.
    READ TABLE lt_gong INTO ls_gong WITH KEY aufnr = ls_data2-b-aufnr.
    IF sy-subrc = 0.
* 배치 모드일 때는 자재 Lock 수행하지 말 것
      IF p_chk IS INITIAL.

        CALL FUNCTION 'ENQUEUE_EZGT_ZGTPPR3000'
          EXPORTING
            werks  = ls_data2-b-werks
            matnr  = ls_data2-b-matnr
          EXCEPTIONS
            OTHERS = 3.

        IF sy-subrc <> 0.

          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              input  = ls_data2-b-matnr
            IMPORTING
              output = ls_data2-b-matnr.

          CLEAR : lv_ename, ls_zpa0539.
          SELECT SINGLE * INTO CORRESPONDING FIELDS OF @ls_zpa0539
                          FROM zpa0539
                          WHERE pernr EQ @sy-msgv1.
          IF ls_zpa0539 IS NOT INITIAL.
            lv_ename = ls_zpa0539-lnmhg && ls_zpa0539-fnmhg.
          ENDIF.

          CONCATENATE TEXT-t01 ls_data2-b-werks
                      TEXT-t02 ls_data2-b-matnr
                      TEXT-t03 sy-msgv1 lv_ename
                      TEXT-t04 INTO lv_msgcode SEPARATED BY space.
          MESSAGE i000 WITH lv_msgcode.
          lv_error = 'X'.
          EXIT.
        ENDIF.

      ENDIF.

    ELSE.

      DELETE lt_data2 INDEX lv_tabix.

    ENDIF.

  ENDLOOP.
* 이미 처리중인 데이터가 없을 경우 ALV 데이터로 취합
  CHECK lv_error IS INITIAL.

  LOOP AT lt_data2 INTO ls_data2.

    IF ls_data2-b-process EQ 'R' OR ls_data2-b-process EQ 'D'.

      CONTINUE.

    ELSE.

      CLEAR gs_disp.
      MOVE-CORRESPONDING ls_data2-b TO gs_disp.

      "상태
      gs_disp-icon = icon_led_red.

      "Message
      "2025.11.28.zlsgpp5.메시지가 없을 경우 로직 추가.
      IF gs_disp-msgid IS INITIAL.
        gs_disp-message = TEXT-m30.
      ELSE.
        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            msgid               = gs_disp-msgid
            msgnr               = gs_disp-msgno
            msgv1               = gs_disp-msgv1
            msgv2               = gs_disp-msgv2
            msgv3               = gs_disp-msgv3
            msgv4               = gs_disp-msgv4
          IMPORTING
            message_text_output = gs_disp-message.
      ENDIF.

      "오류 유형
      gs_disp-gubun = TEXT-009.

      "플랜트 내역
      SELECT SINGLE name1 INTO gs_disp-name1 FROM t001w
                          WHERE werks EQ gs_disp-werks.

      "MRP관리자 내역
      SELECT SINGLE dsnam INTO gs_disp-dsnam FROM t024d
                          WHERE werks EQ gs_disp-werks
                            AND dispo EQ gs_disp-dispo.

      "오류 시간, 생성자
      gs_disp-erzet = ls_data2-b-crtim.
      gs_disp-ernam = ls_data2-b-crnam.

      "오류 생성자 명
      CLEAR : gs_zpa0539.
      READ TABLE gt_zpa0539 INTO gs_zpa0539
                            WITH KEY pernr = gs_disp-ernam.
      IF gs_zpa0539 IS NOT INITIAL.
        gs_disp-ename = gs_zpa0539-lnmhg && gs_zpa0539-fnmhg.
      ENDIF.

      "최종변경일자, 변경자
      gs_disp-laeda = ls_data2-b-chdat.
      gs_disp-aenam = ls_data2-b-chnam.

      "최종 변경자 명
      CLEAR : gs_zpa0539.
      READ TABLE gt_zpa0539 INTO gs_zpa0539
                            WITH KEY pernr = gs_disp-aenam.
      IF gs_zpa0539 IS NOT INITIAL.
        gs_disp-cname = gs_zpa0539-lnmhg && gs_zpa0539-fnmhg.
      ENDIF.

      "자재 내역
      gs_disp-maktx = zgtpp_cl_common=>get_maktx(
                            iv_matnr = gs_disp-matnr ).

      "자재 그룹
      gs_disp-matkl = ls_data2-matkl.

      "자재 그룹 내역
      SELECT SINGLE wgbez60 INTO gs_disp-wgbez60
                            FROM t023t
                            WHERE spras EQ sy-langu
                              AND matkl EQ gs_disp-matkl.
      "오류 수량
      gs_disp-gimng = ls_data2-b-erfmg.

      "투입 완료 수량
      gs_disp-enmng = ls_data2-b-enmng.

      "투입 수량
      gs_disp-erfmg = gs_disp-gimng - gs_disp-enmng.

      "품목 코드
      gs_disp-pmatnr = ls_data2-pmatnr.

      "품목명
      gs_disp-maktx2 = zgtpp_cl_common=>get_maktx(
                             iv_matnr = gs_disp-pmatnr ).

      "꼬리표 번호, 예약번호, 예약아이템
      CLEAR : gs_disp-tagnr, gs_disp-rueck, gs_disp-rmzhl.

      "배치 관리 지시자
      CLEAR gs_marc2.
      READ TABLE gt_marc2 INTO gs_marc2
                          WITH KEY werks = gs_disp-werks
                                   matnr = gs_disp-matnr.
      IF sy-subrc = 0.
        gs_disp-xchar = gs_marc2-xchar.
      ENDIF.

      PERFORM set_cell_attribute.

      APPEND gs_disp TO gt_disp.

    ENDIF.

  ENDLOOP.
*- Start 2025.05.13
* 표준가, 백로그 금액, 통화키
  PERFORM cal_stan_price_backlog_money.
*- End 2025.05.13
  SORT gt_disp BY werks weblnr weblpos.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_master_data
*&---------------------------------------------------------------------*
*& 마스터성 데이터를 READ TABLE로 빠르게 가져오기 위해 사전에 관련 데이터 취합
*&---------------------------------------------------------------------*
FORM get_master_data .

  CLEAR : gs_zgtppt1010, gt_zgtppt1010, gs_zpa0539, gt_zpa0539, gs_t001l, gt_t001l.
* 삭제 사유 코드 및 내역
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @gt_zgtppt1010
    FROM zgtppt1010
    WHERE module_kind EQ 'PP'
      AND codegrp     EQ '3000'
      AND fld_01      EQ @p_werks.

  MOVE-CORRESPONDING gt_zgtppt1010[] TO gt_1010[].
  SORT gt_1010 BY fld_02.
* 오류 생성자 명, 최종 변경자 명
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @gt_zpa0539
    FROM zpa0539.
* 저장위치 탐색도움말 용
  SELECT lgort lgobe
    INTO CORRESPONDING FIELDS OF TABLE gt_t001l
    FROM t001l
    WHERE werks = p_werks.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exit_program
*&---------------------------------------------------------------------*
FORM exit_program .

  CALL METHOD go_docking_container->free.
  CLEAR : go_docking_container, go_grid_0100.
  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form rework_backlog
*&---------------------------------------------------------------------*
FORM rework_backlog .
*- 오류 체크
  CLEAR  : gt_row_no, gt_row_no[], gs_result, gt_result.
  CALL METHOD go_grid_0100->get_selected_rows
    IMPORTING
      et_row_no = gt_row_no[].
* 선택 라인 없으면 오류 메시지 출력
  CLEAR: gv_cnt, gv_error.
  DESCRIBE TABLE gt_row_no LINES gv_cnt.
  IF gv_cnt = 0.
    MESSAGE s000 WITH TEXT-m01 DISPLAY LIKE 'E'.
    gv_error = 'X'.
  ENDIF.

  CHECK gv_error IS INITIAL.
* CALL FUNCTION - POPUP_TO_CONFIRM_STEP
  CLEAR: gv_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      titel     = TEXT-t10
      textline1 = TEXT-t11
      textline2 = TEXT-t12
    IMPORTING
      answer    = gv_answer.

  CHECK gv_answer = 'J'.

  PERFORM check_error_data.

  CHECK gv_error IS INITIAL.
*- Backlog 재처리
  PERFORM process_backlog_rework.
*- 실투입 오류 처리
  PERFORM process_error_gi_zgtppt3100.
** 메시지 취합
*  IF gv_cnt3 IS NOT INITIAL.
*    gv_message3 = TEXT-m20 && gv_cnt4 && TEXT-m07 && gv_cnt3 && TEXT-m18. "배치 업데이트
*  ENDIF.
* 처리 결과 팝업으로 출력
  IF gt_result[] IS NOT INITIAL.
    CALL SCREEN 0102 STARTING AT 2 2 ENDING AT 130 20.
  ENDIF.
*  CALL FUNCTION 'POPUP_FOR_INTERACTION'
*    EXPORTING
*      headline = TEXT-t13
*      text1    = gv_message   "Backlog 재처리
*      text2    = gv_message2 "실투입 오류 처리
*      text3    = gv_message3 "배치 업데이트 처리
*      button_1 = 'OKAY'.
* 처리 후 데이터 REFRESH
  PERFORM get_data.
* REFRESH DISPLAY
  CALL METHOD go_grid_0100->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = gv_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form cogi_bdc
*&---------------------------------------------------------------------*
FORM cogi_bdc .

  DATA : lv_cnt       TYPE i,
         lv_no(2)     TYPE n,
         lv_matnr(21).

  REFRESH: gt_bdcdata, gt_msgcoll.
  CLEAR  : gt_bdcdata, gt_msgcoll.
*- Start 2025.05.02 백로그 번호 반영
  PERFORM dynpro USING:
    'X'  'CORUAFFW'    '1000',
    ' '  'BDC_OKCODE'  '=%006',
    ' '  'S_WERKS-LOW' p_werks,
    ' '  'P_MAXROW'    space,
    ' '  'R_SINGLE'    gc_x.

  CLEAR lv_cnt.
  DESCRIBE TABLE gt_weblnr LINES lv_cnt.

  IF lv_cnt <= 8.

    PERFORM dynpro USING:
      'X'  'SAPLALDB'   '3000',
      ' '  'BDC_OKCODE' '=ACPT'.

    CLEAR lv_no.
    LOOP AT gt_weblnr INTO gs_weblnr.

      lv_no = lv_no + 1.
      CONCATENATE 'RSCSEL_255-SLOW_I(' lv_no ')' INTO lv_matnr.

      PERFORM dynpro USING:
       ' '  lv_matnr gs_weblnr-weblnr.

    ENDLOOP.

  ELSE.

    CLEAR lv_no.
    LOOP AT gt_weblnr INTO gs_weblnr.

      lv_no = lv_no + 1.
      IF lv_no = 1.

        PERFORM dynpro USING:
         'X'  'SAPLALDB'   '3000',
         ' '  'BDC_OKCODE' '=P+'.

      ENDIF.

      CONCATENATE 'RSCSEL_255-SLOW_I(' lv_no ')' INTO lv_matnr.

      PERFORM dynpro USING:
       ' '  lv_matnr gs_weblnr-weblnr.

      IF lv_no = 8.
* 9번째는 두번째 칸부터 채워야함
        lv_no = 1.

        PERFORM dynpro USING:
         'X'  'SAPLALDB'   '3000',
         ' '  'BDC_OKCODE' '=P+'.

      ENDIF.

    ENDLOOP.

    PERFORM dynpro USING:
     'X'  'SAPLALDB'   '3000',
     ' '  'BDC_OKCODE' '=ACPT'.

  ENDIF.
* 자품목 자재가 9개 이상일 경우 BDC 로직을 다르게 감
  PERFORM dynpro USING:
    'X'  'CORUAFFW'    '1000',
    ' '  'BDC_OKCODE'  '=%003',
    ' '  'S_WERKS-LOW' p_werks,
    ' '  'P_MAXROW'    space,
    ' '  'R_SINGLE'    gc_x.

  CLEAR lv_cnt.
  DESCRIBE TABLE gt_matnr LINES lv_cnt.

  IF lv_cnt <= 8.

    PERFORM dynpro USING:
      'X'  'SAPLALDB'   '3000',
      ' '  'BDC_OKCODE' '=ACPT'.

    CLEAR lv_no.
    LOOP AT gt_matnr INTO gs_matnr.

      lv_no = lv_no + 1.
      CONCATENATE 'RSCSEL_255-SLOW_I(' lv_no ')' INTO lv_matnr.

      PERFORM dynpro USING:
       ' '  lv_matnr gs_matnr-matnr.

    ENDLOOP.

  ELSE.

    CLEAR lv_no.
    LOOP AT gt_matnr INTO gs_matnr.

      lv_no = lv_no + 1.
      IF lv_no = 1.

        PERFORM dynpro USING:
         'X'  'SAPLALDB'   '3000',
         ' '  'BDC_OKCODE' '=P+'.

      ENDIF.

      CONCATENATE 'RSCSEL_255-SLOW_I(' lv_no ')' INTO lv_matnr.

      PERFORM dynpro USING:
       ' '  lv_matnr           gs_matnr-matnr.

      IF lv_no = 8.
* 9번째 자품목 자재는 두번째 칸부터 채워야함
        lv_no = 1.

        PERFORM dynpro USING:
         'X'  'SAPLALDB'   '3000',
         ' '  'BDC_OKCODE' '=P+'.

      ENDIF.

    ENDLOOP.

    PERFORM dynpro USING:
     'X'  'SAPLALDB'   '3000',
     ' '  'BDC_OKCODE' '=ACPT'.

  ENDIF.

  PERFORM dynpro USING:
     'X' 'CORUAFFW'                '1000',
     ' '  'BDC_OKCODE'             '=ONLI',
     ' '  'S_WERKS-LOW'           p_werks,
     ' ' 'P_MAXROW'                  space,
     ' '  'R_SINGLE'                   gc_x.

  PERFORM dynpro USING:
    'X'  'SAPLSLVC_FULLSCREEN' '0500',
    ' '   'BDC_OKCODE'                '=&ALL'.

  PERFORM dynpro USING:
  'X'  'SAPLSLVC_FULLSCREEN' '0500',
  ' '   'BDC_OKCODE'                '=BU'.

  gs_bdcparams-nobinpt  = 'X'.   " BI 세션
  gs_bdcparams-dismode = 'N'.
  CALL TRANSACTION 'COGI'          "Transaction Call.
             USING gt_bdcdata
           OPTIONS FROM gs_bdcparams
          MESSAGES INTO gt_msgcoll.

  COMMIT WORK.
* COGI 처리 결과 이력 남기기
  IF p_chk IS NOT INITIAL.
    CLEAR : gt_msgcoll, gv_text.
    READ TABLE gt_msgcoll INDEX 1.
    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = gt_msgcoll-msgid
        msgnr               = gt_msgcoll-msgnr
        msgv1               = gt_msgcoll-msgv1
        msgv2               = gt_msgcoll-msgv2
        msgv3               = gt_msgcoll-msgv3
        msgv4               = gt_msgcoll-msgv4
      IMPORTING
        message_text_output = gv_text.
    WRITE :/ TEXT-023, gv_text.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form dynpro
*&---------------------------------------------------------------------*
FORM dynpro USING dynbegin name value.

  CLEAR gt_bdcdata.
  IF dynbegin = 'X'.
    MOVE: name  TO gt_bdcdata-program,
          value TO gt_bdcdata-dynpro,
          'X'   TO gt_bdcdata-dynbegin.
    APPEND gt_bdcdata.
  ELSE.
    MOVE: name  TO gt_bdcdata-fnam,
          value TO gt_bdcdata-fval.
    APPEND gt_bdcdata.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_backlog
*&---------------------------------------------------------------------*
FORM delete_backlog .
* CALL FUNCTION - POPUP_TO_CONFIRM_STEP
  CLEAR: gv_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      titel     = TEXT-t08
      textline1 = TEXT-t09
      textline2 = ''
    IMPORTING
      answer    = gv_answer.
  CHECK gv_answer = 'J'.

  CLEAR  : gt_row_no, gt_row_no[].

  CALL METHOD go_grid_0100->get_selected_rows
    IMPORTING
      et_row_no = gt_row_no[].

  CLEAR: gv_cnt.
  DESCRIBE TABLE gt_row_no LINES gv_cnt.
* 선택 라인 없으면 오류 메시지 출력
  IF gv_cnt = 0.
    MESSAGE s000 WITH TEXT-m01 DISPLAY LIKE 'E'.
  ENDIF.

  CHECK gv_cnt > 0.

  CLEAR gv_error.
  LOOP AT gt_row_no.

    CLEAR : gs_disp.
    READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.
* 오류일자 체크( 현재월이랑 같지 않으면 처리 중단 및 오류메시지 뿌릴 것 )
*    IF gs_disp-budat+0(6) NE sy-datum+0(6).
*    IF gs_disp-ersda+0(6) NE sy-datum+0(6).
* 임시 주석처리
*      gv_error = 'X'.
*      MESSAGE s000 WITH TEXT-m02 DISPLAY LIKE 'E'.
*      EXIT.
* 삭제 사유 코드 입력 체크
    IF gs_disp-del_reason IS INITIAL.
      gv_error = 'X'.
      MESSAGE s000 WITH TEXT-m04 DISPLAY LIKE 'E'.
      EXIT.
** 실투입 오류 건을 포함했는 지 체크
    ELSEIF gs_disp-gubun = TEXT-009.
      gv_error = 'X'.
      MESSAGE s000 WITH TEXT-m19 DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

  ENDLOOP.

  CHECK gv_error IS INITIAL.
*- Start 2025.06.20
  SORT gt_row_no BY row_id DESCENDING.
*- End 2025.06.20
* AFFW에서 BACKLOG 삭제 후 백업할 것
  CLEAR : gv_cnt, gv_cnt2.
  LOOP AT gt_row_no.

    CLEAR : gs_disp.
    READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.
    IF sy-subrc = 0.

      gv_cnt = gv_cnt + 1.
*- BACKLOG 삭제
      IF gs_disp-gubun = TEXT-008.

        DELETE FROM affw
               WHERE weblnr  = @gs_disp-weblnr
                 AND weblpos = @gs_disp-weblpos.

        IF sy-subrc = 0.

          gv_cnt2 = gv_cnt2 + 1.

          COMMIT WORK.

          MOVE-CORRESPONDING gs_disp TO gs_zgtppt3000.

          CLEAR gv_mandt.
          SELECT SINGLE mandt INTO @gv_mandt FROM zgtppt3000
                                             WHERE weblnr  = @gs_disp-weblnr
                                               AND weblpos = @gs_disp-weblpos.

          IF gv_mandt IS NOT INITIAL.

            gs_zgtppt3000-chdat  = sy-datum.
            gs_zgtppt3000-chtim   = sy-uzeit.
            gs_zgtppt3000-chnam = sy-uname.

          ELSE.

            gs_zgtppt3000-crdat  = sy-datum.
            gs_zgtppt3000-crtim   = sy-uzeit.
            gs_zgtppt3000-crnam = sy-uname.
            gs_zgtppt3000-chdat  = sy-datum.
            gs_zgtppt3000-chtim   = sy-uzeit.
            gs_zgtppt3000-chnam = sy-uname.

          ENDIF.

          gs_zgtppt3000-process = 'D'.
          APPEND gs_zgtppt3000 TO gt_zgtppt3000.

        ELSE.

          ROLLBACK WORK.

        ENDIF.
*- 실투입 삭제
      ELSEIF gs_disp-gubun = TEXT-009.

        UPDATE zgtppt3100 SET   process     = 'D'
                                del_reason  = gs_disp-del_reason
                                reason_text = gs_disp-reason_text
                                details     = gs_disp-details
                                chdat       = sy-datum
                                chtim       = sy-uzeit
                                chnam       = sy-uname
                          WHERE weblnr      = gs_disp-weblnr
                            AND weblpos     = gs_disp-weblpos
                            AND zserno      = gs_disp-zserno
                            AND zsystem_id  = gs_disp-zsystem_id.
* 실투입은 삭제 업데이트 후 바로 리스트에서 제외할 것
        IF sy-subrc = 0.

          gv_cnt2 = gv_cnt2 + 1.

          COMMIT WORK.
          WAIT UP TO '0.5' SECONDS.
          DELETE gt_disp INDEX gt_row_no-row_id.

        ELSE.

          ROLLBACK WORK.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.
*- BACKLOG 백업
  IF gt_zgtppt3000[] IS NOT INITIAL.

    LOOP AT gt_zgtppt3000 INTO gs_zgtppt3000.

      DELETE gt_disp
       WHERE weblnr  EQ gs_zgtppt3000-weblnr
         AND weblpos EQ gs_zgtppt3000-weblpos.

    ENDLOOP.

  ENDIF.

  IF gv_cnt2 IS NOT INITIAL.

    MODIFY zgtppt3000 FROM TABLE gt_zgtppt3000.
    COMMIT WORK.
    CONCATENATE TEXT-m11 gv_cnt TEXT-m07 gv_cnt2 TEXT-m09
           INTO gv_message SEPARATED BY space.
    MESSAGE s003 WITH gv_message.
  ELSE.
    MESSAGE s014 DISPLAY LIKE 'E'.
  ENDIF.
* 데이터 REFRESH
  CALL METHOD go_grid_0100->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = gv_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form multi_delete_backlog
*&---------------------------------------------------------------------*
FORM multi_delete_backlog .
* CALL FUNCTION - POPUP_TO_CONFIRM_STEP
  CLEAR: gv_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      titel     = TEXT-t06
      textline1 = TEXT-t07
      textline2 = ''
    IMPORTING
      answer    = gv_answer.
  CHECK gv_answer = 'J'.

  CLEAR  : gt_row_no, gt_row_no[].

  CALL METHOD go_grid_0100->get_selected_rows
    IMPORTING
      et_row_no = gt_row_no[].

  CLEAR: gv_cnt.
  DESCRIBE TABLE gt_row_no LINES gv_cnt.
* 선택 라인 없으면 오류 메시지 출력
  IF gv_cnt = 0.
    MESSAGE s000 WITH TEXT-m01 DISPLAY LIKE 'E'.
  ENDIF.

  CHECK gv_cnt > 0.

  CLEAR gv_error.
  LOOP AT gt_row_no.

    CLEAR : gs_disp.
    READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.
* 오류일자 체크( 현재월이랑 같지 않으면 처리 중단 및 오류메시지 뿌릴 것 )
*    IF gs_disp-budat+0(6) NE sy-datum+0(6).
*    IF gs_disp-ersda+0(6) NE sy-datum+0(6).
** 임시 주석처리
**      gv_error = 'X'.
**      MESSAGE s000 WITH TEXT-m02 DISPLAY LIKE 'E'.
**      EXIT.
*** 실투입 오류 건을 포함했는 지 체크
**    ELSEIF gs_disp-gubun = TEXT-009.
**      gv_error = 'X'.
**      MESSAGE s000 WITH TEXT-m19 DISPLAY LIKE 'E'.
**      EXIT.
*    ENDIF.

  ENDLOOP.

  CHECK gv_error IS INITIAL.
*- Start 2025.06.20
  SORT gt_row_no BY row_id DESCENDING.
*- End 2025.06.20
* 팝업에서 삭제 사유 코드 및 상세 내역 입력
  CLEAR : gv_del_reason, gv_reason_text, gv_details.
  CALL SCREEN 0200 STARTING AT 78 5.

  CHECK gv_ok_code4 = 'YES'.
* AFFW에서 BACKLOG 삭제 후 백업할 것
  CLEAR : gv_cnt, gv_cnt2.
  LOOP AT gt_row_no.

    CLEAR : gs_disp.
    READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.
    IF sy-subrc = 0.

      gv_cnt = gv_cnt + 1.
*- BACKLOG 삭제
      IF gs_disp-gubun = TEXT-008.

        DELETE FROM affw
               WHERE weblnr  = @gs_disp-weblnr
                 AND weblpos = @gs_disp-weblpos.

        IF sy-subrc = 0.

          gv_cnt2 = gv_cnt2 + 1.

          COMMIT WORK.

          MOVE-CORRESPONDING gs_disp TO gs_zgtppt3000.

          CLEAR gv_mandt.
          SELECT SINGLE mandt INTO @gv_mandt FROM zgtppt3000
                                             WHERE weblnr  = @gs_disp-weblnr
                                               AND weblpos = @gs_disp-weblpos.

          IF gv_mandt IS NOT INITIAL.

            gs_zgtppt3000-chdat = sy-datum.
            gs_zgtppt3000-chtim = sy-uzeit.
            gs_zgtppt3000-chnam = sy-uname.

          ELSE.

            gs_zgtppt3000-crdat = sy-datum.
            gs_zgtppt3000-crtim = sy-uzeit.
            gs_zgtppt3000-crnam = sy-uname.
            gs_zgtppt3000-chdat = sy-datum.
            gs_zgtppt3000-chtim = sy-uzeit.
            gs_zgtppt3000-chnam = sy-uname.

          ENDIF.
* 팝업에서 입력 받은 삭제 사유 코드 반영
          gs_zgtppt3000-del_reason  = gv_del_reason.
          gs_zgtppt3000-reason_text = gv_reason_text.
          gs_zgtppt3000-details     = gv_details.
          gs_zgtppt3000-process     = 'D'.
          APPEND gs_zgtppt3000 TO gt_zgtppt3000.

        ELSE.

          ROLLBACK WORK.

        ENDIF.
*- 실투입 삭제
      ELSEIF gs_disp-gubun = TEXT-009.

        UPDATE zgtppt3100 SET   process     = 'D'
                                del_reason  = gv_del_reason
                                reason_text = gv_reason_text
                                details     = gv_details
                                chdat       = sy-datum
                                chtim       = sy-uzeit
                                chnam       = sy-uname
                          WHERE weblnr      = gs_disp-weblnr
                            AND weblpos     = gs_disp-weblpos
                            AND zserno      = gs_disp-zserno
                            AND zsystem_id  = gs_disp-zsystem_id.
* 실투입은 삭제 업데이트 후 바로 리스트에서 제외할 것
        IF sy-subrc = 0.

          gv_cnt2 = gv_cnt2 + 1.

          COMMIT WORK.
          WAIT UP TO '0.5' SECONDS.
          DELETE gt_disp INDEX gt_row_no-row_id.

        ELSE.

          ROLLBACK WORK.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.
*- BACKLOG 백업
  CLEAR gv_message.
  IF gt_zgtppt3000[] IS NOT INITIAL.

    LOOP AT gt_zgtppt3000 INTO gs_zgtppt3000.

      DELETE gt_disp
       WHERE weblnr  EQ gs_zgtppt3000-weblnr
         AND weblpos EQ gs_zgtppt3000-weblpos.

    ENDLOOP.

  ENDIF.

  IF gv_cnt2 IS NOT INITIAL.

    MODIFY zgtppt3000 FROM TABLE gt_zgtppt3000.
    COMMIT WORK.
    CONCATENATE TEXT-m11 gv_cnt TEXT-m07 gv_cnt2 TEXT-m09
           INTO gv_message SEPARATED BY space.
    MESSAGE i003 WITH gv_message.

  ELSE.
    MESSAGE s007 DISPLAY LIKE 'E'.
  ENDIF.
* 데이터 REFRESH
  CALL METHOD go_grid_0100->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = gv_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form batch_rework_backlog
*&---------------------------------------------------------------------*
FORM batch_rework_backlog .
* Backlog 처리 건에 한정하여 특정 오류 메시지의 건은 저장위치 확장
  LOOP AT gt_disp INTO gs_disp WHERE gubun = TEXT-008.

    IF gs_disp-msgid = 'M7' AND gs_disp-msgno = '006' AND gs_disp-msgty = 'E'.
      PERFORM expansion_storage.
    ENDIF.

  ENDLOOP.
* 백로그 재처리 수행
  PERFORM rework.
* 실투입 오류 처리
  PERFORM gt_zgtppt3100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form expansion_storage
*&---------------------------------------------------------------------*
FORM expansion_storage .

  DATA : ls_headdata             LIKE  bapimathead,
         ls_storagelocationdata  LIKE  bapi_mard,
         ls_storagelocationdatax LIKE  bapi_mardx,
         ls_return               LIKE  bapiret2.
* 저장위치 확장 전 이미 생성되어있는 지 확인
  CLEAR : gv_mandt, ls_headdata, ls_storagelocationdata, ls_storagelocationdatax.
  SELECT SINGLE mandt INTO @gv_mandt FROM mard
                                      WHERE matnr EQ @gs_disp-matnr
                                           AND werks EQ @p_werks
                                           AND lgort EQ @gs_disp-lgort.

  IF gv_mandt IS INITIAL.

    ls_headdata-material  = gs_disp-matnr.
    ls_headdata-mrp_view = 'X'.

    ls_storagelocationdata-plant        = p_werks.
    ls_storagelocationdata-stge_loc  = gs_disp-lgort.

    ls_storagelocationdatax-plant       = p_werks.
    ls_storagelocationdatax-stge_loc = gs_disp-lgort.

    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
      EXPORTING
        headdata             = ls_headdata
        storagelocationdata  = ls_storagelocationdata
        storagelocationdatax = ls_storagelocationdatax
      IMPORTING
        return               = ls_return.
* 저장위치 확장 실패 시 이력 남기기
    IF ls_return-type = 'E' AND p_chk IS NOT INITIAL.
      WRITE :/ TEXT-024, ls_return-message.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form rework
*&---------------------------------------------------------------------*
FORM rework .

  DATA : lv_text(100).
  DATA : ls_seltab TYPE rsparams,
         lt_seltab TYPE TABLE OF rsparams.
  DATA : lv_error,
         lv_przid LIKE tparu-przid.
** COGI 처리는 자품목 자재 기준으로 처리
*  CLEAR : gs_matnr, gt_matnr.
*  LOOP AT gt_disp INTO gs_disp WHERE gubun = TEXT-008.
** COGI 처리할 때 사용할 자품목 자재
*    gs_matnr-matnr = gs_disp-matnr.
*    APPEND gs_matnr TO gt_matnr.
*  ENDLOOP.
*
*  SORT gt_matnr BY matnr.
*  DELETE ADJACENT DUPLICATES FROM gt_matnr COMPARING matnr.
** 백로그 처리 데이터 없을 경우 이력 남기기
*  IF gt_matnr[] IS INITIAL AND p_chk IS NOT INITIAL.
*    WRITE :/ '백로그 처리 데이터 없음'.
*  ELSE.
* 배치 잡으로 처리 시 BDC 대신 CORUAFWP SUBMIT 할 것
*    PERFORM cogi_bdc.
  SELECT fld_03 INTO TABLE @DATA(lt_fld_03)
                           FROM zgtppt1010
                           WHERE module_kind EQ 'PP'
                             AND codegrp EQ '3003'
                             AND fld_01 EQ @p_werks
                             AND fld_02 IN @s_dispo.

  CLEAR: lt_seltab.
  lt_seltab = VALUE #(
  ( selname = 'PAAUTYP' kind = 'S' sign = 'I' option = 'EQ' low = '10' )
  ( selname = 'PAWERKS' kind = 'S' sign = 'I' option = 'EQ' low = p_werks )
  ( selname = 'PAFEHL'  kind = 'P' sign = 'I' option = 'EQ' low = gc_x ) ).

  LOOP AT lt_fld_03 INTO DATA(ls_fld_03).
    CLEAR ls_seltab.
    ls_seltab-selname = 'PALGORT'.
    ls_seltab-kind = 'S'.
    ls_seltab-sign = 'I'.
    ls_seltab-option = 'EQ'.
    ls_seltab-low = ls_fld_03-fld_03.
    APPEND ls_seltab TO lt_seltab.
  ENDLOOP.

  CLEAR lv_error.
  LOOP AT gt_disp INTO gs_disp WHERE gubun = TEXT-008.
* 잠금 처리 체크 : 백로그
    CALL FUNCTION 'ENQUEUE_ESAFFW'
      EXPORTING
        weblnr  = gs_disp-weblnr
        weblpos = gs_disp-weblpos
      EXCEPTIONS
        OTHERS  = 01.
* 잠금 처리되었을 경우 에러 메시지 출력 후 프로그램 종료
    IF sy-subrc <> 0.
      MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e17.
      lv_error = 'X'.
      EXIT.
* 잠기지 않은 상태에서 잠금 처리했다면 바로 풀어줄 것
    ELSE.
      CALL FUNCTION 'DEQUEUE_ESAFFW'
        EXPORTING
          weblnr  = gs_disp-weblnr
          weblpos = gs_disp-weblpos.
    ENDIF.
* 잠금 처리 체크 : 자재 이동
    lv_przid = '1'.
    CALL FUNCTION 'ENQUEUE_ESCORUPROC'
      EXPORTING
        przid  = lv_przid
      EXCEPTIONS
        OTHERS = 1.
* 잠금 처리되었을 경우 에러 메시지 출력 후 프로그램 종료
    IF sy-subrc <> 0.
      MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e17.
      lv_error = 'X'.
      EXIT.
* 잠기지 않은 상태에서 잠금 처리했다면 바로 풀어줄 것
    ELSE.
      CALL FUNCTION 'DEQUEUE_ESCORUPROC'
        EXPORTING
          przid = lv_przid.
    ENDIF.
* 잠금 처리 체크 : 원가 계산
    lv_przid = '2'.
    CALL FUNCTION 'ENQUEUE_ESCORUPROC'
      EXPORTING
        przid  = lv_przid
      EXCEPTIONS
        OTHERS = 1.
* 잠금 처리되었을 경우 에러 메시지 출력 후 프로그램 종료
    IF sy-subrc <> 0.
      MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-e17.
      lv_error = 'X'.
      EXIT.
* 잠기지 않은 상태에서 잠금 처리했다면 바로 풀어줄 것
    ELSE.
      CALL FUNCTION 'DEQUEUE_ESCORUPROC'
        EXPORTING
          przid = lv_przid.
    ENDIF.

  ENDLOOP.

  CHECK lv_error IS INITIAL.

  SUBMIT coruafwp WITH SELECTION-TABLE lt_seltab
                  AND  RETURN.
* 정상적으로 처리되었으면 ZGTPPT3000에 백업
  CLEAR : gs_zgtppt3000, gt_zgtppt3000.
  LOOP AT gt_disp INTO gs_disp WHERE gubun = TEXT-008.

    CLEAR : gv_mandt, gv_xchpf, gs_marc2, lv_text.
* 자재마스터의 배치관리지시자(MARC-XCHPF) 추출
    READ TABLE gt_marc2 INTO gs_marc2
                        WITH KEY werks = gs_disp-werks
                                 matnr = gs_disp-matnr.
    IF gs_marc2 IS NOT INITIAL.
      gv_xchpf = gs_marc2-xchpf.
    ENDIF.

    SELECT SINGLE mandt INTO @gv_mandt FROM affw
                                       WHERE weblnr  EQ @gs_disp-weblnr
                                         AND weblpos EQ @gs_disp-weblpos.

    IF gv_mandt IS INITIAL.
* 배치 잡 모드에서 제대로 처리된 건은 WRITE 뿌릴 것
      lv_text = TEXT-016 && gs_disp-weblnr && '//' && gs_disp-weblpos && '//' &&
                gs_disp-matnr && '//' && gs_disp-erfmg && '//' && gs_disp-erfme.
      WRITE :/ lv_text.

      MOVE-CORRESPONDING gs_disp TO gs_zgtppt3000.
      gs_zgtppt3000-process      = 'R'.
      gs_zgtppt3000-background = 'X'.

      CLEAR gv_mandt.
      SELECT SINGLE mandt INTO @gv_mandt FROM zgtppt3000
                                         WHERE weblnr  EQ @gs_disp-weblnr
                                           AND weblpos EQ @gs_disp-weblpos.

      IF gv_mandt IS NOT INITIAL.

        gs_zgtppt3000-chdat = sy-datum.
        gs_zgtppt3000-chtim = sy-uzeit.
        gs_zgtppt3000-chnam = sy-uname.

      ELSE.

        gs_zgtppt3000-crdat = sy-datum.
        gs_zgtppt3000-crtim = sy-uzeit.
        gs_zgtppt3000-crnam = sy-uname.
        gs_zgtppt3000-chdat = sy-datum.
        gs_zgtppt3000-chtim = sy-uzeit.
        gs_zgtppt3000-chnam = sy-uname.

      ENDIF.

      APPEND gs_zgtppt3000 TO gt_zgtppt3000.

      IF gv_xchpf = 'X'.
*- 배치 특성 업데이트 처리
        PERFORM process_update_batch_char USING TEXT-008.
*- 꼬리표 업데이트 처리
        PERFORM process_update_tagnr USING space space.

      ENDIF.

    ENDIF.

  ENDLOOP.

  IF gt_zgtppt3000[] IS NOT INITIAL.

    MODIFY zgtppt3000 FROM TABLE gt_zgtppt3000.
    COMMIT WORK.

  ENDIF.

*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_matnr
*&---------------------------------------------------------------------*
FORM change_matnr .

  DATA : lv_weblnr   LIKE affw-weblnr,
         lv_text(70).

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.

  CLEAR  : gt_row_no, gt_row_no[], gv_mandt, gv_answer.

  CALL METHOD go_grid_0100->get_selected_rows
    IMPORTING
      et_row_no = gt_row_no[].

  CLEAR: gv_cnt.
  DESCRIBE TABLE gt_row_no LINES gv_cnt.
* 선택 라인 없으면 오류 메시지 출력
  IF gv_cnt = 0.
    MESSAGE s000 WITH TEXT-m01 DISPLAY LIKE 'E'.
  ENDIF.

  CHECK gv_cnt > 0.
* 팝업 출력 이전 몇 가지 체크
  CLEAR : gv_error, gs_meins, gt_meins, gr_meins, gr_meins[],
          gs_matkl, gt_matkl, gr_matkl, gr_matkl[], gr_matnr,
          gr_matnr[].

  LOOP AT gt_row_no.

    CLEAR : gs_disp.
    READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.

    IF gs_disp IS NOT INITIAL.
** 투입 처리 완료된 건이 있는 지 점검
*      CLEAR gv_mandt.
*      SELECT SINGLE mandt INTO @gv_mandt FROM resb
*                                          WHERE rsnum = @gs_disp-rsnum
*                                               AND rspos = @gs_disp-rspos
*                                               AND enmng > 0.
*
*      IF gv_mandt IS NOT INITIAL.
*
*        gv_error = 'X'.
*        MESSAGE s000 WITH TEXT-m12 DISPLAY LIKE 'E'.
*        EXIT.
*- Start 2025.02.28
** 실투입 오류 건을 포함했는 지 체크
**      ELSE
*      IF gs_disp-gubun = TEXT-009.
*
*        gv_error = 'X'.
*        MESSAGE s000 WITH TEXT-m23 DISPLAY LIKE 'E'.
*        EXIT.
*
*      ELSE.
*- Start 2025.05.12
* 오류일자 체크( 현재월이랑 같지 않으면 처리 중단 및 오류메시지 뿌릴 것 )
*      IF gs_disp-ersda+0(6) NE sy-datum+0(6).
* 오류일자 체크 임시 해제 확인
*        gv_error = 'X'.
*        MESSAGE s000 WITH TEXT-m02 DISPLAY LIKE 'E'.
*        EXIT.
*      ELSE.
*- End 2025.05.12
* 단위 확인용 데이터
* BOM의 출고 저장위치 추출할 때 사용.
        gr_matnr-sign = 'I'.
        gr_matnr-option = 'EQ'.
        gr_matnr-low = gs_disp-pmatnr.
        APPEND gr_matnr.

        SELECT SINGLE meins, matkl
                 INTO ( @gs_meins-meins, @gs_matkl-matkl ) FROM mara
                 WHERE matnr = @gs_disp-matnr.
        APPEND gs_meins TO gt_meins.
        gr_meins-sign = 'I'.
        gr_meins-option = 'EQ'.
        gr_meins-low = gs_meins-meins.
        APPEND gr_meins.

        APPEND gs_matkl TO gt_matkl.
        gr_matkl-sign = 'I'.
        gr_matkl-option = 'EQ'.
        gr_matkl-low = gs_matkl-matkl.
        APPEND gr_matkl.

*      ENDIF.
*- End 2025.02.28
    ENDIF.

  ENDLOOP.

  CHECK gv_error IS INITIAL.
* 선택한 라인의 자재들 중 단위, 자재그룹이 다른 자재 건이 있는 지 체크
  SORT gt_meins BY meins.
  DELETE ADJACENT DUPLICATES FROM gt_meins COMPARING meins.
  SORT gt_matkl BY matkl.
  DELETE ADJACENT DUPLICATES FROM gt_matkl COMPARING matkl.

  SORT : gr_meins, gr_matkl, gr_matnr BY low.
  DELETE ADJACENT DUPLICATES FROM : gr_meins, gr_matkl, gr_matnr COMPARING low.

  CLEAR: gv_cnt.
  DESCRIBE TABLE gt_meins LINES gv_cnt.
  IF gv_cnt > 1.
    MESSAGE s000 WITH TEXT-m13 DISPLAY LIKE 'E'.
  ELSE.
    CLEAR: gv_cnt.
    DESCRIBE TABLE gt_matkl LINES gv_cnt.
    IF gv_cnt > 1.
      MESSAGE s000 WITH TEXT-m21 DISPLAY LIKE 'E'.
    ELSE.
* 팝업에서 '대체 자재코드' 입력 후 반영
      CLEAR : gv_matnr, gv_maktx, gv_lgort, gv_lgobe, gv_meins.
      CALL SCREEN 0300 STARTING AT 75 5.
* 일괄 변경하는 데 문제 없으면 AFFW 업데이트 수행
      IF gv_answer = 'J'.

        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            input  = gv_matnr
          IMPORTING
            output = gv_matnr.

        CLEAR : gv_error, gv_error2.
        LOOP AT gt_row_no.

          CLEAR : gs_disp, lv_weblnr.
          READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.

          IF gs_disp IS NOT INITIAL.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = gs_disp-weblnr
              IMPORTING
                output = lv_weblnr.

            IF gs_disp-gubun = TEXT-008. "백로그

              IF gv_lgort IS NOT INITIAL.

                UPDATE affw SET matnr = @gv_matnr,
                                lgort = @gv_lgort
                            WHERE weblnr  EQ @lv_weblnr
                              AND weblpos EQ @gs_disp-weblpos.
* 반영할 저장위치가 없을 경우 자재 코드만 반영
              ELSE.

                UPDATE affw SET matnr = @gv_matnr
                            WHERE weblnr  EQ @lv_weblnr
                              AND weblpos EQ @gs_disp-weblpos.

              ENDIF.
* 업데이트 실패했다는 건 이미 cogi에서 삭제되었거나 처리되었다는 뜻
* 한 건이라도 실패시 즉시 처리 프로세스를 중단하고 Rollback 처리
              IF sy-subrc <> 0.
                gv_error = 'X'.
                EXIT.
              ENDIF.

            ELSEIF gs_disp-gubun = TEXT-009. "실투입 오류

              IF gv_lgort IS NOT INITIAL.

                UPDATE zgtppt3100 SET matnr = @gv_matnr,
                                      lgort = @gv_lgort
                                  WHERE weblnr     EQ @lv_weblnr
                                    AND weblpos    EQ @gs_disp-weblpos
                                    AND zserno     EQ @gs_disp-zserno
                                    AND zsystem_id EQ @gs_disp-zsystem_id.
* 반영할 저장위치가 없을 경우 자재 코드만 반영
              ELSE.

                UPDATE zgtppt3100 SET matnr = @gv_matnr
                                  WHERE weblnr     EQ @lv_weblnr
                                    AND weblpos    EQ @gs_disp-weblpos
                                    AND zserno     EQ @gs_disp-zserno
                                    AND zsystem_id EQ @gs_disp-zsystem_id.

              ENDIF.
* 업데이트 실패했다는 건 이미 cogi에서 삭제되었거나 처리되었다는 뜻
* 한 건이라도 실패시 즉시 처리 프로세스를 중단하고 Rollback 처리
              IF sy-subrc <> 0.
                gv_error2 = 'X'.
                EXIT.
              ENDIF.

            ENDIF.

          ENDIF.

        ENDLOOP.

        IF gv_error = 'X'. "백로그 처리 중 오류 메시지

          CONCATENATE TEXT-017'' lv_weblnr TEXT-018 TEXT-019
                          INTO lv_text SEPARATED BY space.
          ROLLBACK WORK.
          MESSAGE s000 WITH lv_text DISPLAY LIKE 'E'.

        ELSEIF gv_error2 = 'X'. "실투입 오류 처리 중 오류 메시지

          CONCATENATE TEXT-020 lv_weblnr TEXT-018 TEXT-019
                          INTO lv_text SEPARATED BY space.
          ROLLBACK WORK.
          MESSAGE s000 WITH lv_text DISPLAY LIKE 'E'.

        ELSE.

          LOOP AT gt_row_no.

            CLEAR : gs_disp.
            READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.

            IF gs_disp IS NOT INITIAL.
*- Start 2025.05.08
* 변경 내용을 "ZGTPPT3270"에 저장
              PERFORM update_zgtppt3270.
*- End 2025.05.08
              gs_disp-matnr = gv_matnr.
              gs_disp-maktx = zgtpp_cl_common=>get_maktx(
                                     iv_matnr = gs_disp-matnr ).
              IF gv_lgort IS NOT INITIAL.
                gs_disp-lgort = gv_lgort.
              ENDIF.
* 신규 추가된 자재일 경우 GT_MARC2에 반영 2025.03.06
              CLEAR gs_marc2.
              READ TABLE gt_marc2 INTO gs_marc2
                                  WITH KEY matnr = gv_matnr
                                           werks = p_werks.
              IF gs_marc2 IS INITIAL.

                SELECT SINGLE matnr, werks, xchar, xchpf, dpcbt
                         INTO CORRESPONDING FIELDS OF @gs_marc2
                         FROM marc
                         WHERE matnr = @gv_matnr
                           AND werks = @p_werks.

              ENDIF.

              IF gs_marc2 IS NOT INITIAL.

                APPEND gs_marc2 TO gt_marc2.
* 추가로 배치번호, 꼬리표 번호를 입력 가능하도록 활성화
                REFRESH lt_celltab.

                CASE gs_marc2-xchar.
                  WHEN 'X'.
                    CLEAR ls_celltab.
                    ls_celltab-fieldname = 'CHARG'.
                    ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
                    INSERT ls_celltab INTO TABLE lt_celltab.
                    CLEAR ls_celltab.
                    ls_celltab-fieldname = 'TAGNR'.
                    ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
                    INSERT ls_celltab INTO TABLE lt_celltab.
                  WHEN OTHERS.
                    CLEAR ls_celltab.
                    ls_celltab-fieldname = 'CHARG'.
                    ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
                    INSERT ls_celltab INTO TABLE lt_celltab.
                    CLEAR ls_celltab.
                    ls_celltab-fieldname = 'TAGNR'.
                    ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
                    INSERT ls_celltab INTO TABLE lt_celltab.
                ENDCASE.

                gs_disp-celltab = lt_celltab.

              ENDIF.

              MODIFY gt_disp FROM gs_disp INDEX gt_row_no-row_id.

            ENDIF.

          ENDLOOP.

          COMMIT WORK.
          MESSAGE s000 WITH TEXT-m16.
* REFRESH DISPLAY
          CALL METHOD go_grid_0100->refresh_table_display
            EXPORTING
              i_soft_refresh = 'X'
              is_stable      = gv_stable.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_error_data
*&---------------------------------------------------------------------*
FORM check_error_data .

  DATA : ls_zppt0001     TYPE zppt0001,
         lv_message(100),
         lv_weblnr       LIKE gs_disp-weblnr,
         lv_weblpos      LIKE gs_disp-weblpos,
         lv_matnr        LIKE gs_disp-matnr.

  LOOP AT gt_row_no.

    CLEAR : gs_disp, lv_weblnr, lv_weblpos, lv_matnr.
    READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.
    IF gs_disp-weblnr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = gs_disp-weblnr
        IMPORTING
          output = lv_weblnr.
    ENDIF.
    IF gs_disp-weblpos IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = gs_disp-weblpos
        IMPORTING
          output = lv_weblpos.
    ENDIF.
    IF gs_disp-matnr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input  = gs_disp-matnr
        IMPORTING
          output = lv_matnr.
    ENDIF.
* 오류일자 체크( 현재월이랑 같지 않으면 처리 중단 및 오류메시지 뿌릴 것 )
*    IF gs_disp-budat+0(6) NE sy-datum+0(6).
*    IF gs_disp-ersda+0(6) NE sy-datum+0(6).
*      gv_error = 'X'.
*      MESSAGE s000 WITH TEXT-m02 DISPLAY LIKE 'E'.
*      EXIT.
* 오류 수량 < 투입 완료 수량 + 투입 수량 이면 에러 메시지 출력 - 실투입 오류 한정
    IF ( gs_disp-gimng < ( gs_disp-enmng + gs_disp-erfmg ) )
      AND gs_disp-gubun = TEXT-009.
      gv_error = 'X'.
      MESSAGE i010 DISPLAY LIKE 'E' WITH lv_weblnr lv_weblpos.
      EXIT.
*    - ALV에서 배치번호 & 꼬리표 번호 입력했다면 꼬리표 정합성 점검
    ELSEIF gs_disp-charg IS NOT INITIAL AND gs_disp-tagnr IS NOT INITIAL.

      SELECT SINGLE *
                     FROM zppt0001
                     WHERE werks = @gs_disp-werks
                          AND matnr = @gs_disp-matnr
                          AND lgort = @gs_disp-lgort
                          AND charg = @gs_disp-charg
                          AND tagnr = @gs_disp-tagnr
                          AND scrapyn = @space
                          AND shift   = @space
                          AND inspflg = 'OK'
                          AND grflg   = 'Y'                " 입고된 것 만
                          AND giflg   = 'N'
                          INTO @ls_zppt0001.

      IF ls_zppt0001 IS INITIAL.
        gv_error = 'X'.
        MESSAGE s006 WITH TEXT-e04 gs_disp-tagnr TEXT-e05 DISPLAY LIKE 'E'.
        EXIT.
      ELSE.
        CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
          EXPORTING
            i_matnr  = gs_disp-matnr
            i_in_me  = ls_zppt0001-meins
            i_out_me = gs_disp-erfme
            i_menge  = ls_zppt0001-remain
          IMPORTING
            e_menge  = ls_zppt0001-remain.
        IF ls_zppt0001-remain < gs_disp-erfmg.
          gv_error = 'X'.
          lv_message = TEXT-e06 && gs_disp-tagnr && TEXT-e07 && ls_zppt0001-remain &&
                                ls_zppt0001-meins && TEXT-e08.
          MESSAGE s003 WITH lv_message DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.
      ENDIF.

    ELSEIF gs_disp-gubun = TEXT-009.
* 자재마스터의 배치관리지시자(MARC-XCHPF) 추출
      CLEAR : gs_marc2, gv_xchpf.
      READ TABLE gt_marc2 INTO gs_marc2
                                         WITH KEY werks = gs_disp-werks
                                                        matnr = gs_disp-matnr.
      IF gs_marc2 IS NOT INITIAL.
        gv_xchpf = gs_marc2-xchpf.
      ENDIF.
* 배치 미관리 자재(MARC-XCHPF = ' ')는 MARD에서 수량 확인하여 비교.
      IF gv_xchpf = ' '.

        SELECT SINGLE a~matnr, a~werks, a~lgort, a~labst, b~meins
                         INTO CORRESPONDING FIELDS OF @gs_stock
                         FROM mard AS a INNER JOIN mara AS b
                             ON a~matnr EQ b~matnr
                         WHERE a~matnr = @gs_disp-matnr
                              AND a~werks = @gs_disp-werks
                              AND a~lgort   = @gs_disp-lgort.

        CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
          EXPORTING
            i_matnr  = gs_disp-matnr
            i_in_me  = gs_stock-meins
            i_out_me = gs_disp-erfme
            i_menge  = gs_stock-labst
          IMPORTING
            e_menge  = gs_stock-labst.

        IF gs_stock-labst < gs_disp-erfmg.
          gv_error = 'X'.
          lv_message = TEXT-e09 && lv_weblnr && '],[' && lv_weblpos && '],[' &&
                                 lv_matnr && TEXT-e10.
          MESSAGE s003 WITH lv_message DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.
* 배치 관리 자재(MARC-XCHPF = ' X')는 MCHB에서 수량 확인하여 비교( 입력 시 )
      ELSEIF gs_disp-charg IS NOT INITIAL.

        SELECT SINGLE a~matnr, a~werks, a~lgort, a~clabs AS labst , b~meins
                         INTO CORRESPONDING FIELDS OF @gs_stock
                         FROM mchb AS a INNER JOIN mara AS b
                             ON a~matnr EQ b~matnr
                         WHERE a~matnr = @gs_disp-matnr
                              AND a~werks = @gs_disp-werks
                              AND a~lgort   = @gs_disp-lgort
                              AND a~charg = @gs_disp-charg.
* 데이터 없을 시 에러 메시지
        IF gs_stock IS INITIAL.

          gv_error = 'X'.
          lv_message = TEXT-e11 && lv_matnr && TEXT-e12 && gs_disp-charg &&
                                 TEXT-e13.
          MESSAGE s003 WITH lv_message DISPLAY LIKE 'E'.
          EXIT.
* 재고 수량이 투입 수량보다 적으면 에러 메시지
        ELSE.

          CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
            EXPORTING
              i_matnr  = gs_disp-matnr
              i_in_me  = gs_stock-meins
              i_out_me = gs_disp-erfme
              i_menge  = gs_stock-labst
            IMPORTING
              e_menge  = gs_stock-labst.

          IF gs_stock-labst < gs_disp-erfmg.
            gv_error = 'X'.
            lv_message = TEXT-e11 && lv_matnr && TEXT-e12 && gs_disp-charg &&
                                  TEXT-e14.
            MESSAGE s003 WITH lv_message DISPLAY LIKE 'E'.
            EXIT.
          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_backlog_rework
*&---------------------------------------------------------------------*
FORM process_backlog_rework .

  DATA : lv_ok.
  DATA : BEGIN OF ls_rework,
           weblnr LIKE affw-weblnr, "백로그 번호
           matnr  LIKE affw-matnr, "자재
*           weblpos LIKE affw-weblpos, "백로그 아이템
         END OF ls_rework.
  DATA : lt_rework LIKE TABLE OF ls_rework.
* 건 별 업데이트마다 COMMIT WORK 시 처리 시간이 늘어나므로 일괄 업데이트 후 COMMIT WORK.
  CLEAR : gs_matnr, gt_matnr, lv_ok, lt_rework, gs_weblnr, gt_weblnr, gt_affw.
  LOOP AT gt_row_no.

    CLEAR : gs_disp.
    READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.
    IF sy-subrc = 0 AND gs_disp-gubun = TEXT-008.
* 대체 자재 변경 이력 저장을 위한 기존 AFFW 데이터 취합
      SELECT * APPENDING CORRESPONDING FIELDS OF TABLE @gt_affw
               FROM affw
               WHERE weblnr  = @gs_disp-weblnr
                 AND weblpos = @gs_disp-weblpos.
* COGI 처리를 위한 수정 값 반영
      UPDATE affw SET lgort   = gs_disp-lgort "저장위치
                      charg   = gs_disp-charg "배치번호
                      erfmg   = gs_disp-erfmg "수량
                      budat   = gs_disp-budat "전기일자
                      laeda   = sy-datum
                      aenam   = sy-uname
                WHERE weblnr  = gs_disp-weblnr
                  AND weblpos = gs_disp-weblpos.
* COGI 처리할 때 사용할 자품목 자재 및 백로그 번호 취합
      gs_matnr-matnr = gs_disp-matnr.
      APPEND gs_matnr TO gt_matnr.
*- Start 2025.05.02
      gs_weblnr-weblnr = gs_disp-weblnr.
      APPEND gs_weblnr TO gt_weblnr.
*- End 2025.05.02
* 재처리 데이터 체크용
      CLEAR ls_rework.
      ls_rework-weblnr = gs_disp-weblnr.
      ls_rework-matnr  = gs_disp-matnr.
*      ls_rework-weblpos = gs_disp-weblpos.
      APPEND ls_rework TO lt_rework.

      lv_ok = 'X'.

    ENDIF.

  ENDLOOP.
* 처리 대상 있을시에만 아래 로직 태울 것. 그렇지 않으면, COGI BDC를 태우므로 시간 걸림.
  CHECK lv_ok IS NOT INITIAL.

  COMMIT WORK.

  SORT gt_matnr BY matnr.
  DELETE ADJACENT DUPLICATES FROM gt_matnr COMPARING matnr.
  SORT gt_weblnr BY weblnr.
  DELETE ADJACENT DUPLICATES FROM gt_weblnr COMPARING weblnr.
  SORT lt_rework BY weblnr matnr.
  DELETE ADJACENT DUPLICATES FROM lt_rework COMPARING weblnr matnr.
* COGI 처리는 선택한 자품목 자재, 백로그 번호 기준으로 처리
  PERFORM cogi_bdc.

  WAIT UP TO '2' SECONDS.
* BDC 처리 후 조회된 전체 데이터에 대해 처리 여부 체크 후 ZGTPPT3000에 백업
  CLEAR : gs_zgtppt3000, gt_zgtppt3000, gv_cnt, gv_cnt2, gv_cnt3, gv_cnt4,
          gt_3270.

  LOOP AT gt_disp INTO gs_disp WHERE gubun = TEXT-008.

    CLEAR : gs_zgtppt3000, gv_mandt, gv_xchpf, gs_marc2, gv_message4.
*- Start 2025.05.08
* 대체 자재 변경 이력 저장
    PERFORM update_zgtppt3270_rework.
*- End 2025.05.08
* 자재마스터의 배치관리지시자(MARC-XCHPF) 추출
    READ TABLE gt_marc2 INTO gs_marc2
                        WITH KEY werks = gs_disp-werks
                                 matnr = gs_disp-matnr.
    IF gs_marc2 IS NOT INITIAL.
      gv_xchpf = gs_marc2-xchpf.
    ENDIF.

    CLEAR gs_affw2.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF @gs_affw2
                    FROM affw
                    WHERE weblnr  EQ @gs_disp-weblnr
                      AND weblpos EQ @gs_disp-weblpos.

    IF gs_affw2 IS INITIAL.

      MOVE-CORRESPONDING gs_disp TO gs_zgtppt3000.
      gs_zgtppt3000-process = 'R'.

      CLEAR gv_mandt.
      SELECT SINGLE mandt INTO @gv_mandt FROM zgtppt3000
                          WHERE weblnr  EQ @gs_disp-weblnr
                            AND weblpos EQ @gs_disp-weblpos.

      IF gv_mandt IS NOT INITIAL.

        gs_zgtppt3000-chdat = sy-datum.
        gs_zgtppt3000-chtim = sy-uzeit.
        gs_zgtppt3000-chnam = sy-uname.

      ELSE.

        gs_zgtppt3000-crdat = sy-datum.
        gs_zgtppt3000-crtim = sy-uzeit.
        gs_zgtppt3000-crnam = sy-uname.
        gs_zgtppt3000-chdat = sy-datum.
        gs_zgtppt3000-chtim = sy-uzeit.
        gs_zgtppt3000-chnam = sy-uname.

      ENDIF.

      APPEND gs_zgtppt3000 TO gt_zgtppt3000.
* 재처리 결과는 선택 라인의 백로그 및 자재 코드 기준으로 보여줄 것
      CLEAR ls_rework.
      READ TABLE lt_rework INTO ls_rework
                           WITH KEY weblnr   = gs_disp-weblnr
                                    matnr    = gs_disp-matnr.
*                                   weblpos = gs_disp-weblpos.
      IF ls_rework IS NOT INITIAL.
* 처리 결과 업데이트
        PERFORM update_gt_result USING icon_led_green TEXT-021 TEXT-008.

      ENDIF.

      IF gv_xchpf = 'X'.
*- 배치 특성 업데이트 처리
        PERFORM process_update_batch_char USING TEXT-008.
*- 꼬리표 업데이트 처리
        PERFORM process_update_tagnr USING space space.

      ENDIF.
* COGI 처리 실패
    ELSE.
* Message
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = gs_affw2-msgid
          msgnr               = gs_affw2-msgno
          msgv1               = gs_affw2-msgv1
          msgv2               = gs_affw2-msgv2
          msgv3               = gs_affw2-msgv3
          msgv4               = gs_affw2-msgv4
        IMPORTING
          message_text_output = gv_message4.
* 재처리 결과는 선택 라인의 백로그 및 자재 코드 기준으로 보여줄 것
      CLEAR ls_rework.
      READ TABLE lt_rework INTO ls_rework
                           WITH KEY weblnr   = gs_disp-weblnr
                                    matnr    = gs_disp-matnr.
*                                    weblpos = gs_disp-weblpos.
      IF ls_rework IS NOT INITIAL.
* 처리 결과 업데이트
        PERFORM update_gt_result USING icon_led_red gv_message4 TEXT-008.

      ENDIF.

    ENDIF.

  ENDLOOP.

  CLEAR gv_message.
  IF gt_zgtppt3000[] IS NOT INITIAL.
    MODIFY zgtppt3000 FROM TABLE gt_zgtppt3000.
    COMMIT WORK.
  ENDIF.

  IF gt_3270[] IS NOT INITIAL.
    MODIFY zgtppt3270 FROM TABLE gt_3270.
    IF sy-subrc = 0.
      COMMIT WORK.
      WAIT UP TO '0.5' SECONDS.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_error_gi_zgtppt3100
*&---------------------------------------------------------------------*
FORM process_error_gi_zgtppt3100 .

  DATA : ls_header   TYPE bapi2017_gm_head_01,
         lt_item     TYPE TABLE OF bapi2017_gm_item_create,
         lv_code     TYPE bapi2017_gm_code VALUE '03',
         lv_document TYPE bapi2017_gm_head_ret-mat_doc,
         lv_year     TYPE bapi2017_gm_head_ret-doc_year,
         lt_return   TYPE TABLE OF bapiret2.
  DATA : lv_enmng LIKE zgtppt3100-enmng.
  DATA : lv_menge LIKE zgtppt3070-menge.
  DATA : lt_3101  LIKE TABLE OF zgtppt3101,
         ls_3101  LIKE zgtppt3101,
         lv_seqno LIKE zgtppt3101-seqno.
  DATA : lv_tabix TYPE sy-tabix.
  DATA : lv_message TYPE bapiret2-message.

  CLEAR : gv_cnt, gv_cnt2.
  LOOP AT gt_row_no.

    CLEAR : gs_disp, gv_xchpf, gt_stock2, lt_item, gv_menge, gs_batch, gt_batch, gs_marc2.
    READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.
    IF sy-subrc = 0 AND gs_disp-gubun = TEXT-009.
*- Start 2025.05.08
* 대체 자재 변경 이력 저장
      PERFORM update_zgtppt3270_error_gi.
*- End 2025.05.08
* 자재마스터의 배치관리지시자(MARC-XCHPF) 추출
      READ TABLE gt_marc2 INTO gs_marc2
                          WITH KEY werks = gs_disp-werks
                                   matnr = gs_disp-matnr.
      IF gs_marc2 IS NOT INITIAL.
        gv_xchpf = gs_marc2-xchpf.
      ENDIF.

      ls_header = VALUE #( pstng_date = gs_disp-budat "수신 받은 전기일
                           doc_date   = gs_disp-budat "수신 받은 전기일
                           pr_uname   = sy-uname       "사용자 이름
                           header_txt = 'MES 실투입 오류 재처리' ).
* 배치 자재가 아닐 경우 배치 번호 미반영 상태로 투입 정보 반영
      IF gv_xchpf IS INITIAL.

        lt_item = VALUE #( ( material  = gs_disp-matnr  "선택한 Row의 출고자재
                             plant     = gs_disp-werks  "선택한 Row의 플랜트
                             stge_loc  = gs_disp-lgort  "선택한 Row의 출고 창고
                             batch     = ' '
                             move_type = '261'           "이동유형
                             stck_type = 'F'             "재고유형
                             entry_qnt = gs_disp-erfmg  "선택한 Row의 출고 수량
                             entry_uom = gs_disp-erfme  "선택한 Row의 출고 단위
                             orderid   = gs_disp-aufnr ) ).  "선택한 Row의 오더번호
* 배치 번호가 입력되어있으면 해당 배치 기준의 재고 수량을 확인하여 반영
      ELSEIF gs_disp-charg IS NOT INITIAL.

        lt_item = VALUE #( ( material  = gs_disp-matnr  "선택한 Row의 출고자재
                             plant     = gs_disp-werks  "선택한 Row의 플랜트
                             stge_loc  = gs_disp-lgort  "선택한 Row의 출고 창고
                             batch     = gs_disp-charg
                             move_type = '261'           "이동유형
                             stck_type = 'F'             "재고유형
                             entry_qnt = gs_disp-erfmg  "선택한 Row의 출고 수량
                             entry_uom = gs_disp-erfme  "선택한 Row의 출고 단위
                             orderid   = gs_disp-aufnr ) ).  "선택한 Row의 오더번호
* 배치 자재지만 배치 번호 미 입력시 선입선출로 반영
      ELSEIF gs_disp-charg IS INITIAL.

        SELECT
              b~werks,
              c~matnr,
              b~rgekz, "백플러시
              c~lgort, "저장위치
              c~charg, "배치번호
              c~clabs, "평가된 가용 재고
              e~meins
          FROM marc AS b
          INNER JOIN mchb AS c
             ON b~matnr = c~matnr
             AND b~werks = c~werks
          INNER JOIN mara AS e
                  ON b~matnr = e~matnr
          WHERE b~matnr EQ @gs_disp-matnr  "자재 번호
            AND b~xchpf = 'X'              "플랜트의 배치 관리 필요 지시자
            AND b~werks EQ @p_werks
            AND c~lgort EQ @gs_disp-lgort  "저장 위치
            AND c~lvorm = ' '              "배치 재고의 모든 데이터에 대한 삭제 표시
            AND c~clabs > 0
            INTO CORRESPONDING FIELDS OF TABLE @gt_stock2.

        IF gt_stock2[] IS NOT INITIAL.

          SELECT matnr, charg, budat
              INTO TABLE @DATA(lt_matdoc)
              FROM matdoc
              FOR ALL ENTRIES IN @gt_stock2
              WHERE werks EQ @gt_stock2-werks
                   AND matnr EQ @gt_stock2-matnr
                   AND shkzg = 'S'
                   AND cancelled NE 'X'
                   AND cancellation_type EQ @space
                   AND lgort EQ @gt_stock2-lgort
                   AND charg EQ @gt_stock2-charg.

          SORT lt_matdoc BY matnr charg ASCENDING budat DESCENDING.
          DELETE ADJACENT DUPLICATES FROM lt_matdoc COMPARING matnr charg.

          LOOP AT gt_stock2 INTO gs_stock2.

            lv_tabix = sy-tabix.

            READ TABLE lt_matdoc INTO DATA(ls_matdoc)
                                 WITH KEY matnr = gs_stock2-matnr
                                          charg = gs_stock2-charg.

            IF sy-subrc = 0.
              gs_stock2-budat = ls_matdoc-budat.
              MODIFY gt_stock2 FROM gs_stock2 INDEX lv_tabix.
            ENDIF.

          ENDLOOP.

          SORT gt_stock2 ASCENDING BY budat.

          IF gt_stock2[] IS NOT INITIAL.

            gv_menge = gs_disp-erfmg.
            LOOP AT gt_stock2 INTO gs_stock2.
* 배치 수량을 투입 단위로 변환
              CLEAR lv_menge.
              CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                EXPORTING
                  i_matnr  = gs_stock2-matnr
                  i_in_me  = gs_stock2-meins
                  i_out_me = gs_disp-erfme
                  i_menge  = gs_stock2-clabs
                IMPORTING
                  e_menge  = gs_stock2-clabs.

              IF gv_menge > gs_stock2-clabs.
                lv_menge = gs_stock2-clabs.
                gv_menge = gv_menge - lv_menge.
              ELSE.
                lv_menge = gv_menge.
                CLEAR gv_menge.
              ENDIF.

              APPEND INITIAL LINE TO lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
              <ls_item> = VALUE #( material  = gs_disp-matnr  "선택한 Row의 출고자재
                                   plant     = gs_disp-werks  "선택한 Row의 플랜트
                                   stge_loc  = gs_disp-lgort  "선택한 Row의 출고 창고
                                   batch     = gs_stock2-charg
                                   move_type = '261'           "이동유형
                                   stck_type = 'F'             "재고유형
                                   entry_qnt = lv_menge  "선택한 Row의 출고 수량
                                   entry_uom = gs_disp-erfme  "선택한 Row의 출고 단위
                                   orderid   = gs_disp-aufnr ). "선택한 Row의 오더번호

              gs_batch-charg = gs_stock2-charg.
              gs_batch-menge = lv_menge.
              APPEND gs_batch TO gt_batch.

              IF gv_menge = 0.
                EXIT.
              ENDIF.

            ENDLOOP.

          ENDIF.
* 재고 없을 시에도 에러 메시지 뿌려줘야 함.
        ELSE.
* 처리 결과 업데이트
          PERFORM update_gt_result USING icon_led_red TEXT-022 TEXT-009.

        ENDIF.

      ENDIF.
* 투입 처리 건이 있을 시에만 BAPI 태울 것
      CHECK lt_item[] IS NOT INITIAL.
*- 투입 처리 (펑션 호출)
      CLEAR : lv_document, lv_year, lt_return.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = ls_header
          goodsmvt_code    = lv_code
        IMPORTING
          materialdocument = lv_document
          matdocumentyear  = lv_year
        TABLES
          goodsmvt_item    = lt_item
          return           = lt_return.
*- 실패
      IF line_exists( lt_return[ type = 'E' ] ).

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
* 처리 결과 업데이트
        PERFORM update_gt_result USING icon_led_red lv_message TEXT-009.

      ELSE.
*- 성공
* 실투입 오류 처리 수량 업데이트
        CLEAR lv_enmng.
        lv_enmng = gs_disp-enmng. "실제 투입량에 기존 투입량 포함
        LOOP AT lt_item INTO DATA(ls_item).
          lv_enmng = lv_enmng + ls_item-entry_qnt.
        ENDLOOP.

        IF gs_disp-gimng = lv_enmng.

          UPDATE zgtppt3100 SET enmng   = lv_enmng
*- Start 2025.05.08
                                lgort   = gs_disp-lgort
                                budat   = gs_disp-budat
*- End 2025.05.08
                                process = 'R'
                                chdat   = sy-datum
                                chtim   = sy-uzeit
                                chnam   = sy-uname
                                WHERE weblnr     = gs_disp-weblnr
                                  AND weblpos    = gs_disp-weblpos
                                  AND zserno     = gs_disp-zserno
                                  AND zsystem_id = gs_disp-zsystem_id.

        ELSE.

          UPDATE zgtppt3100 SET enmng   = lv_enmng
*- Start 2025.05.08
                                lgort   = gs_disp-lgort
                                budat   = gs_disp-budat
*- End 2025.05.08
                                chdat   = sy-datum
                                chtim   = sy-uzeit
                                chnam   = sy-uname
                                WHERE weblnr     = gs_disp-weblnr
                                  AND weblpos    = gs_disp-weblpos
                                  AND zserno     = gs_disp-zserno
                                  AND zsystem_id = gs_disp-zsystem_id.

        ENDIF.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
* 처리 결과 업데이트
        PERFORM update_gt_result USING icon_led_green TEXT-021 TEXT-009.
* 성공한 건만 ZGTPPT3101 업데이트
        CLEAR : lv_seqno, ls_3101, lt_3101.
        SELECT SINGLE MAX( seqno ) INTO lv_seqno FROM zgtppt3101
                                   WHERE weblnr  = gs_disp-weblnr
                                     AND weblpos = gs_disp-weblpos.

        LOOP AT lt_item INTO ls_item.

          CLEAR ls_3101.
          lv_seqno = lv_seqno + 1.
          MOVE-CORRESPONDING gs_disp TO ls_3101.
          ls_3101-seqno = lv_seqno.
          ls_3101-charg = ls_item-batch.
          IF ls_3101-tagnr IS INITIAL
            AND gv_xchpf = 'X'.
            SELECT SINGLE tagnr INTO @ls_3101-tagnr
                                FROM zppt0001
                                WHERE werks = @ls_3101-werks
                                  AND charg = @ls_3101-charg
                                  AND matnr = @ls_3101-matnr.
          ENDIF.
          ls_3101-erfmg = ls_item-entry_qnt.
          ls_3101-mblnr = lv_document.
          ls_3101-mjahr = lv_year.
          ls_3101-crdat = ls_3101-chdat = sy-datum.
          ls_3101-crtim = ls_3101-chtim = sy-uzeit.
          ls_3101-crnam = ls_3101-chnam = sy-uname.
          APPEND ls_3101 TO lt_3101.

        ENDLOOP.

        IF lt_3101[] IS NOT INITIAL.
          MODIFY zgtppt3101 FROM TABLE lt_3101.
          IF sy-subrc = 0.
            COMMIT WORK.
          ELSE.
            ROLLBACK WORK.
          ENDIF.
        ENDIF.

        IF gv_xchpf = 'X'.
*- 배치 특성 업데이트 처리
          PERFORM process_update_batch_char USING TEXT-009.
*- 꼬리표 업데이트 처리
          PERFORM process_update_tagnr USING lv_document lv_year.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

  IF gt_3270[] IS NOT INITIAL.
    MODIFY zgtppt3270 FROM TABLE gt_3270.
    IF sy-subrc = 0.
      COMMIT WORK.
      WAIT UP TO '0.5' SECONDS.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_update_batch_char
*&---------------------------------------------------------------------*
FORM process_update_batch_char USING pv_gubun.

  DATA : lv_class TYPE klah-class,
         lt_char  TYPE TABLE OF api_ch_att,
         lt_vali  TYPE TABLE OF api_vali,
         lv_error.

  CLEAR : lt_char, lt_vali, lv_error, lv_class.
*- 배치의 CLASS 번호 추출
  CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
    EXPORTING
      material           = gs_disp-matnr "입고자재
      plant              = gs_disp-werks "플랜트
      classtype          = '023'          "클래스유형(배치)
    IMPORTING
      class              = lv_class
    EXCEPTIONS
      no_class_found     = 1
      no_classtype_found = 2
      OTHERS             = 3.

  CHECK lv_class IS NOT INITIAL.
*- 배치 특성 정보 추출
* 배치 정보가 존재하면 해당 배치번호로 특성 업데이트
  IF gs_disp-charg IS NOT INITIAL.

    CALL FUNCTION 'ZQC01_BATCH_VALUES_READ'
      EXPORTING
        i_val_matnr    = gs_disp-matnr
        i_val_werks    = gs_disp-werks
        i_val_charge   = gs_disp-charg
        i_date         = sy-datum
      TABLES
        t_val_tab      = lt_vali
        t_att_tab      = lt_char
      EXCEPTIONS
        no_class       = 1
        internal_error = 2
        no_values      = 3
        no_chars       = 4
        OTHERS         = 5.

    gv_charg = gs_disp-charg.
    PERFORM update_batch_char TABLES lt_char lt_vali
                                                      USING lv_class pv_gubun
                                                      CHANGING lv_error.
* 배치 정보 미 입력시 다중 배치 투입 처리 가능성이 있으므로 해당 배치 번호 전부 업데이트
  ELSE.

    LOOP AT gt_batch INTO gs_batch.
      gv_charg = gs_batch-charg.
      PERFORM update_batch_char TABLES lt_char lt_vali
                                                        USING lv_class pv_gubun
                                                        CHANGING lv_error.
    ENDLOOP.

  ENDIF.

*  IF lv_error IS NOT INITIAL.
*    gv_cnt3 = gv_cnt3 + 1.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_batch_char
*&---------------------------------------------------------------------*
FORM update_batch_char TABLES pt_char STRUCTURE api_ch_att
                                                       pt_vali STRUCTURE api_vali
                                            USING        pv_class LIKE klah-class
                                                            pv_gubun
                                            CHANGING pv_error.

  DATA : ls_vali    TYPE api_vali,
         lt_valchar TYPE TABLE OF bapi1003_alloc_values_char,
         ls_valchar TYPE bapi1003_alloc_values_char,
         lt_valnum  TYPE TABLE OF bapi1003_alloc_values_num,
         ls_valnum  TYPE bapi1003_alloc_values_num,
         lt_valcurr TYPE TABLE OF bapi1003_alloc_values_curr,
         lt_return  TYPE TABLE OF bapiret2,
         lv_dpcbt   LIKE marc-dpcbt,
         lv_kzwsm   LIKE mara-kzwsm,
         lv_status  TYPE bapi1003_key-status.

  LOOP AT pt_char INTO DATA(ls_char).

    CLEAR ls_vali.
    ls_vali = VALUE #( pt_vali[ atnam = ls_char-atnam ] OPTIONAL ).

    CASE ls_char-dtype.
      WHEN 'CHAR' OR 'DATE'.
        lt_valchar = VALUE #( BASE lt_valchar
                             ( value_char = ls_vali-atwrt
                               charact    = ls_char-atnam ) ).
      WHEN 'TIME' OR 'NUM'.
        lt_valnum = VALUE #( BASE lt_valnum
                             ( value_from = ls_vali-atflv
                               unit_from  = ls_vali-atawe
                               charact    = ls_char-atnam ) ).
    ENDCASE.

  ENDLOOP.
*- 배치 타입
  CLEAR : lv_dpcbt, lv_kzwsm, gs_marc2.
  SELECT SINGLE kzwsm  "단위사용
    INTO @lv_kzwsm
     FROM mara
     WHERE matnr = @gs_disp-matnr.
* 단일 단위 배치 기본값
  READ TABLE gt_marc2 INTO gs_marc2
                                     WITH KEY werks = gs_disp-werks
                                                    matnr = gs_disp-matnr.
  IF gs_marc2 IS NOT INITIAL.
    lv_dpcbt = gs_marc2-dpcbt.
  ENDIF.
*- 배치 특성정보 업데이트 데이터 입력
  LOOP AT pt_char INTO ls_char.
*- 싱글 유닛 배치
    IF ( lv_dpcbt = 'B' OR  lv_dpcbt = 'C' ) AND
         lv_kzwsm = 'B'.

      IF  ls_char-atnam = 'SAP_MILLCA_LENGTH' OR
          ls_char-atnam = 'SAP_MILLCA_LENGTH_SUB'.
        CONTINUE. "싱글유닛 배치의 두개의 특성은 입/출고 수량이 자동반영됨
      ENDIF.
*- Factor 배치
    ELSEIF lv_dpcbt = 'A' AND lv_kzwsm = 'B'.
      CONTINUE. "Factor 배치의 길이 관련 두개의 특성은 입/출고 수량이 자동반영됨
*- 일반배치( Factor 배치도 있지만 해저에서는 사용하지 않음)
    ELSE.

      IF  ls_char-atnam = 'SAP_MILLCA_LENGTH' OR
          ls_char-atnam = 'SAP_MILLCA_LENGTH_SUB'.

        CLEAR gs_stock3.
        SELECT SINGLE
             b~werks,
             c~matnr,
             b~rgekz, "백플러시
             c~lgort, "저장위치
             c~charg, "배치번호
             c~clabs AS menge, "평가된 가용 재고
             d~meins  "기본단위
        FROM marc AS b
        INNER JOIN mchb AS c
             ON b~matnr = c~matnr
            AND b~werks = c~werks
        INNER JOIN mara AS d
             ON b~matnr = d~matnr
       WHERE  b~werks = @gs_disp-werks
         AND  b~matnr = @gs_disp-matnr
         AND  b~xchpf = 'X'
         AND  c~lgort = @gs_disp-lgort
         AND  c~charg = @gv_charg
         AND  c~lvorm = ' '
         INTO CORRESPONDING FIELDS OF @gs_stock3.
        "특성값 입력(수량/ 일반배치는 입/출고시 수량 자동반영 X)
        IF ls_char-atnam = 'SAP_MILLCA_LENGTH'.
          CLEAR ls_valnum.
          ls_valnum-value_from = gs_stock3-menge.
          MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = 'SAP_MILLCA_LENGTH'.
        ELSEIF ls_char-atnam = 'SAP_MILLCA_LENGTH_SUB'.
          CLEAR ls_valnum.
          ls_valnum-value_from = gs_stock3-menge.
          MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = 'SAP_MILLCA_LENGTH_SUB'.
        ENDIF.
      ENDIF.

    ENDIF.

    CLEAR ls_char.

  ENDLOOP.

  CLEAR : lt_return.
*- 배치 특성 업데이트(펑션 호출)
  IF pt_char IS NOT INITIAL.

    SELECT SINGLE cuobj_bm
      INTO @DATA(lv_objkey)
      FROM mch1
      WHERE matnr = @gs_disp-matnr
       AND  charg = @gv_charg.

    CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
      EXPORTING
        clobjectkey         = lv_objkey
        classnum            = pv_class
      IMPORTING
        classif_status      = lv_status
      TABLES
        allocvaluesnum_new  = lt_valnum
        allocvalueschar_new = lt_valchar
        allocvaluescurr_new = lt_valcurr
        return              = lt_return.
* 배치 업데이트 처리 결과 이력 남기기
    IF line_exists( lt_return[ type = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      pv_error = 'X'.
** 처리 결과 업데이트
*      PERFORM update_gt_result USING space icon_led_red pv_gubun.

      IF p_chk IS NOT INITIAL.
        READ TABLE lt_return INTO DATA(ls_return) WITH KEY type = 'E'.
        WRITE :/ TEXT-025, ls_return-message.
      ENDIF.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
** 처리 결과 업데이트
*      PERFORM update_gt_result USING space icon_led_green pv_gubun.

      IF p_chk IS NOT INITIAL.
        WRITE :/ TEXT-026.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_update_tagnr
*&---------------------------------------------------------------------*
FORM process_update_tagnr USING pv_document pv_year.

  CLEAR : gv_charg, gv_menge2.
* 다수의 배치 수량이 투입되었다면 배치별 실제 투입 수량 반영
  IF gt_batch[] IS NOT INITIAL.

    LOOP AT gt_batch INTO gs_batch.
      gv_charg = gs_batch-charg.
      gv_menge2 = gs_batch-menge.
      PERFORM update_tagnr USING pv_document pv_year.
    ENDLOOP.
* 단일 건은 투입 수량 반영
  ELSE.

    gv_charg = gs_disp-charg.
    gv_menge2 = gs_disp-erfmg.
    PERFORM update_tagnr USING pv_document pv_year.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_tagnr
*&---------------------------------------------------------------------*
FORM update_tagnr USING pv_document pv_year.

  DATA : ls_zppt0015 TYPE zppt0015,
         lt_zppt0015 TYPE TABLE OF zppt0015,
         lv_mgvrg    TYPE zppt0015-mgvrg,
         lv_mgvrg01  TYPE zppt0001-mgvrg.

  DATA : ls_zppt0001 TYPE zppt0001,
         lv_remain   TYPE zppt0001-remain,
         lv_giflg    TYPE zppt0001-giflg.

  DATA : lv_tagnr LIKE zppt0001-tagnr.
  DATA : lv_charg LIKE zppt0001-charg.
  DATA : lv_seqno  LIKE zppt0015-seqno,
         lv_wablnr LIKE afru-wablnr.
  DATA : BEGIN OF ls_matdoc,
           mblnr LIKE matdoc-mblnr,
           mjahr LIKE matdoc-mjahr,
           budat LIKE matdoc-budat,
           cputm LIKE matdoc-cputm,
         END OF ls_matdoc.

  CLEAR : ls_zppt0001, lv_remain, lv_giflg, lv_tagnr.
* 꼬리표 번호가 없으면 배치 번호 기준으로 가져올 것
  IF gs_disp-tagnr IS INITIAL.

    SELECT SINGLE tagnr INTO @lv_tagnr
           FROM zppt0001
           WHERE werks = @gs_disp-werks
            AND  charg = @gv_charg
            AND  matnr = @gs_disp-matnr.

  ELSE.

    lv_tagnr = gs_disp-tagnr.

  ENDIF.

  SELECT SINGLE *
     FROM zppt0001
     WHERE werks = @gs_disp-werks
      AND  tagnr = @lv_tagnr
      AND  charg = @gv_charg
      AND  matnr = @gs_disp-matnr
     INTO @ls_zppt0001.
* 출고처리하는 꼬리표의 입고된 꼬리표가 없으면 SKIP
  CHECK ls_zppt0001 IS NOT INITIAL.
*      잔량 : 투입(-), 취소(+)
* 변환된 투입 수량을 다시 꼬리표 잔량 단위로 변환
  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      i_matnr  = gs_disp-matnr
      i_in_me  = gs_disp-erfme
      i_out_me = ls_zppt0001-meins
      i_menge  = gv_menge2
    IMPORTING
      e_menge  = gv_menge2.
  lv_remain = ls_zppt0001-remain - gv_menge2."gs_disp-erfmg.

  IF lv_remain < 0.
    lv_remain = 0.
  ENDIF.
* 잔량이 0이면 출고 FLAG는 Y
  IF lv_remain = 0.
    lv_giflg = 'Y'.
  ELSE.
    lv_giflg = 'N'.
  ENDIF.

  UPDATE zppt0001 SET : remain  = lv_remain
                                       giflg   = lv_giflg
              WHERE  werks   = gs_disp-werks
                  AND   tagnr   = lv_tagnr
                  AND   charg   = gv_charg
                  AND   matnr   = gs_disp-matnr.

  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.
*- Backlog
  IF pv_document IS INITIAL.
*- 꼬리표 추적
* (ZPPT0001)
    SELECT SINGLE *
       FROM zppt0001
       WHERE werks EQ @gs_disp-werks
            AND aufnr EQ @gs_disp-aufnr
            AND rueck EQ @gs_disp-rueck
            INTO @ls_zppt0001.

    CHECK ls_zppt0001 IS NOT INITIAL.
* 순번 취합
    SELECT SINGLE seqno INTO @lv_seqno
                   FROM zppt0015
                   WHERE werks EQ @gs_disp-werks
                        AND tagnr_o EQ @ls_zppt0001-tagnr
                        AND tagnr_i EQ @gs_disp-tagnr.
    IF lv_seqno IS NOT INITIAL.
      lv_seqno = lv_seqno + 1.
    ENDIF.
* 자재전표 취합
    SELECT SINGLE wablnr INTO @lv_wablnr
                    FROM afru
                    WHERE rueck EQ @gs_disp-rueck
                         AND rmzhl EQ @gs_disp-rmzhl.
* 백로그 재처리건은 BDC 처리하므로 자재문서 별도 추출
    CLEAR ls_matdoc.
    SELECT SINGLE mblnr, mjahr, budat, cputm
                    INTO CORRESPONDING FIELDS OF @ls_matdoc
                    FROM matdoc
                    WHERE mblnr EQ @lv_wablnr
                         AND charg EQ @gs_disp-charg.

*    lv_mgvrg  = gs_disp-enmng  + gs_disp-erfmg.

    lt_zppt0015 = VALUE #( ( werks   = gs_disp-werks
                         tagnr_o = ls_zppt0001-tagnr
                         tagnr_i = gs_disp-tagnr
                         seqno = lv_seqno
                         mgvrg = gv_menge2
*                         mgvrg   = lv_mgvrg
                         meins   = gs_disp-erfme
                         mblnr   = ls_matdoc-mblnr
                         mjahr   = ls_matdoc-mjahr
                         zidat     = ls_matdoc-budat
                         zitim     = ls_matdoc-cputm ) ).

    MODIFY zppt0015 FROM TABLE lt_zppt0015.
    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.
*- 실투입 오류
  ELSEIF gs_disp-zup_tagnr IS NOT INITIAL.
*- 꼬리표 추적테이블(ZPPT0015)
* 꼬리표 생성 및 업데이트 체크
    SELECT SINGLE *
      FROM zppt0015
      WHERE werks   = @gs_disp-werks
       AND  tagnr_o = @gs_disp-zup_tagnr
       AND  tagnr_i = @lv_tagnr
      INTO @ls_zppt0015.
* 기존 값이 없으면 Seqno 값은 '00'으로 Insert 되어야함.
    IF sy-subrc = 0.
      lv_seqno = ls_zppt0015-seqno + 1.
    ENDIF.
** (ZPPT0001)
*    SELECT SINGLE *
*       FROM zppt0001
*       WHERE werks = @gs_disp-werks
*        AND  tagnr = @lv_tagnr
*        AND  charg = @gv_charg
*        AND  matnr = @gs_disp-matnr
*       INTO @ls_zppt0001.
*- 꼬리표 업데이트 (수량/자재문서))
    IF gs_disp-zup_tagnr IS NOT INITIAL AND lv_tagnr IS NOT INITIAL.

*      IF ls_zppt0015 IS NOT INITIAL.
**        "총수량: 투입(+) 취소(-)
**        lv_mgvrg  = ls_zppt0015-mgvrg  + gs_disp-erfmg.
**        lv_remain = ls_zppt0001-remain - gs_disp-erfmg.
*
*        UPDATE zppt0015 SET ": mgvrg   = lv_mgvrg   "합산된 수량
*                            : mgvrg   = gv_menge2
*                              meins   = gs_disp-erfme
*                              mblnr   = pv_document
*                              mjahr   = pv_year
*                              zidat   = sy-datum
*                              zitim   = sy-uzeit
*                       WHERE  werks   = gs_disp-werks
*                        AND   tagnr_o = gs_disp-zup_tagnr
*                        AND   tagnr_i = lv_tagnr.
**        UPDATE zppt0001 SET : remain  = lv_remain
**                              giflg   = 'Y'
**                       WHERE  werks   = gs_disp-werks
**                        AND   tagnr   = lv_tagnr
**                        AND   charg   = gv_charg
**                        AND   matnr   = gs_disp-matnr.
*
*        IF sy-subrc = 0.
*          COMMIT WORK.
*        ENDIF.
**- 꼬리표 생성
*      ELSE.

*        lv_mgvrg  = gs_disp-enmng  + gs_disp-erfmg.

      lt_zppt0015 = VALUE #( ( werks   = gs_disp-werks
                               tagnr_o = gs_disp-zup_tagnr "모품목 꼬리표
                               tagnr_i = lv_tagnr                     "자품목 꼬리표
                               seqno = lv_seqno                    "순번
                               mgvrg = gv_menge2
*                                 mgvrg   = lv_mgvrg     "합산된 수량
                               meins   = gs_disp-erfme
                               mblnr   = pv_document
                               mjahr   = pv_year
                               zidat   = gs_disp-budat
                               zitim   = sy-uzeit ) ).

      MODIFY zppt0015 FROM TABLE lt_zppt0015.
      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.

*      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form gt_zgtppt3100
*&---------------------------------------------------------------------*
FORM gt_zgtppt3100 .

  DATA : ls_header   TYPE bapi2017_gm_head_01,
         lt_item     TYPE TABLE OF bapi2017_gm_item_create,
         lv_code     TYPE bapi2017_gm_code VALUE '03',
         lv_document TYPE bapi2017_gm_head_ret-mat_doc,
         lv_year     TYPE bapi2017_gm_head_ret-doc_year,
         lt_return   TYPE TABLE OF bapiret2.
  DATA : lv_enmng LIKE zgtppt3100-enmng.
  DATA : lv_menge LIKE zgtppt3070-menge.
  DATA : lt_3101  LIKE TABLE OF zgtppt3101,
         ls_3101  LIKE zgtppt3101,
         lv_seqno LIKE zgtppt3101-seqno.
  DATA : lv_tabix TYPE sy-tabix.

  LOOP AT gt_disp INTO gs_disp WHERE gubun = TEXT-009.
** 오류일자 체크( 현재월이랑 같지 않으면 패스 및 오류메시지 뿌릴 것 )
*    IF gs_disp-ersda+0(6) NE sy-datum+0(6).
*      WRITE :/ TEXT-036, gs_disp-weblnr, '//', gs_disp-weblpos.
*    ELSE.

      CLEAR : gv_xchpf, ls_header, lt_item, gt_stock2, gv_menge, gs_batch, gt_batch, gs_marc2.
* 자재마스터의 배치관리지시자(MARC-XCHPF) 추출
      READ TABLE gt_marc2 INTO gs_marc2
                          WITH KEY werks = gs_disp-werks
                                   matnr = gs_disp-matnr.
      IF gs_marc2 IS NOT INITIAL.
        gv_xchpf = gs_marc2-xchpf.
      ENDIF.
* 배치 미관리 자재(MARC-XCHPF = ' ')는 MARD에서 수량 확인하여 비교.
      IF gv_xchpf IS INITIAL.

        SELECT SINGLE matnr, werks, lgort, labst
                 INTO CORRESPONDING FIELDS OF @gs_stock
                 FROM mard
                 WHERE matnr = @gs_disp-matnr
                   AND werks = @gs_disp-werks
                   AND lgort = @gs_disp-lgort.
* 재고 수량이 투입 수량보다 적으면 패스
        IF gs_stock-labst < gs_disp-erfmg.
          CONTINUE.
        ENDIF.
* 배치 관리 자재(MARC-XCHPF = ' X')는 MCHB에서 수량 확인하여 비교( 입력 시 )
      ELSEIF gs_disp-charg IS NOT INITIAL.

        SELECT SINGLE matnr, werks, lgort, clabs AS labst
                 INTO CORRESPONDING FIELDS OF @gs_stock
                 FROM mchb
                 WHERE matnr = @gs_disp-matnr
                   AND werks = @gs_disp-werks
                   AND lgort = @gs_disp-lgort
                   AND charg = @gs_disp-charg.
* 데이터 없을 시 에러 메시지
        IF gs_stock IS INITIAL.
          CONTINUE.
* 재고 수량이 투입 수량보다 적으면 패스
        ELSEIF gs_stock-labst < gs_disp-erfmg.
          CONTINUE.
        ENDIF.

      ENDIF.
      ls_header = VALUE #( pstng_date = gs_disp-budat "수신 받은 전기일
                             doc_date = gs_disp-budat "수신 받은 전기일
                             pr_uname = sy-uname       "사용자 이름
                           header_txt = 'MES 실투입 오류 재처리' ).
* 배치 자재가 아닐 경우 배치 번호 미반영 상태로 투입 정보 반영
      IF gv_xchpf IS INITIAL.

        lt_item = VALUE #( ( material = gs_disp-matnr  "선택한 Row의 출고자재
                                plant = gs_disp-werks  "선택한 Row의 플랜트
                             stge_loc = gs_disp-lgort  "선택한 Row의 출고 창고
                                batch = ' '
                            move_type = '261'           "이동유형
                            stck_type = 'F'             "재고유형
                            entry_qnt = gs_disp-erfmg  "선택한 Row의 출고 수량
                            entry_uom = gs_disp-erfme  "선택한 Row의 출고 단위
                              orderid = gs_disp-aufnr ) ). "선택한 Row의 오더번호
*                    reserv_no = gs_disp-rsnum  "선택한 Row의 예약번호
*                    res_item  = gs_disp-rspos ) ). "선택한 Row의 예약품목번호
* 배치 번호가 입력되어있으면 해당 배치 기준의 재고 수량을 확인하여 반영
      ELSEIF gs_disp-charg IS NOT INITIAL.

        lt_item = VALUE #( ( material = gs_disp-matnr  "선택한 Row의 출고자재
                                plant = gs_disp-werks  "선택한 Row의 플랜트
                             stge_loc = gs_disp-lgort  "선택한 Row의 출고 창고
                                batch = gs_disp-charg
                            move_type = '261'           "이동유형
                            stck_type = 'F'             "재고유형
                            entry_qnt = gs_disp-erfmg  "선택한 Row의 출고 수량
                            entry_uom = gs_disp-erfme  "선택한 Row의 출고 단위
                              orderid = gs_disp-aufnr ) ).  "선택한 Row의 오더번호
*                    reserv_no = gs_disp-rsnum  "선택한 Row의 예약번호
*                    res_item  = gs_disp-rspos ) ). "선택한 Row의 예약품목번호
* 배치 자재지만 배치 번호 미 입력시 선입선출로 반영
      ELSEIF gs_disp-charg IS INITIAL.

        SELECT b~werks, c~matnr, b~rgekz, c~lgort, c~charg, c~clabs, e~meins
          FROM marc AS b
          INNER JOIN mchb AS c
                  ON b~matnr = c~matnr
                 AND b~werks = c~werks
          INNER JOIN mara AS e
                  ON b~matnr = e~matnr
*         INNER JOIN matdoc AS d
*                      ON d~charg = c~charg
               WHERE b~matnr = @gs_disp-matnr  "자재 번호
                 AND b~xchpf = 'X'              "플랜트의 배치 관리 필요 지시자
                 AND b~werks EQ @p_werks
                 AND c~lgort = @gs_disp-lgort  "저장 위치
                 AND c~lvorm = ' '              "배치 재고의 모든 데이터에 대한 삭제 표시
                 AND c~clabs > 0
*                           AND d~shkzg = 'S'
*                           AND d~reversal_movement = @space
*                           AND d~cancelled NE 'X' "취소처리되지 않은 것
                 INTO CORRESPONDING FIELDS OF TABLE @gt_stock2.

        CHECK gt_stock2[] IS NOT INITIAL.

        SELECT matnr, charg, budat
          INTO TABLE @DATA(lt_matdoc)
          FROM matdoc
          FOR ALL ENTRIES IN @gt_stock2
          WHERE werks EQ @gt_stock2-werks
            AND matnr EQ @gt_stock2-matnr
            AND shkzg = 'S'
            AND cancelled NE 'X'
            AND cancellation_type EQ @space
            AND lgort EQ @gt_stock2-lgort
            AND charg EQ @gt_stock2-charg.

        SORT lt_matdoc BY matnr charg ASCENDING budat DESCENDING.
        DELETE ADJACENT DUPLICATES FROM lt_matdoc COMPARING matnr charg.

        LOOP AT gt_stock2 INTO gs_stock2.

          lv_tabix = sy-tabix.

          READ TABLE lt_matdoc INTO DATA(ls_matdoc)
                               WITH KEY matnr = gs_stock2-matnr
                                        charg = gs_stock2-charg.
          IF sy-subrc = 0.
            gs_stock2-budat = ls_matdoc-budat.
            MODIFY gt_stock2 FROM gs_stock2 INDEX lv_tabix.
          ENDIF.

        ENDLOOP.

        SORT gt_stock2 ASCENDING BY budat.

        IF gt_stock2[] IS NOT INITIAL.

          gv_menge = gs_disp-erfmg.
          LOOP AT gt_stock2 INTO gs_stock2.

            CLEAR lv_menge.
            IF gv_menge > gs_stock2-clabs.
              lv_menge = gs_stock2-clabs.
              gv_menge = gv_menge - lv_menge.
            ELSE.
              lv_menge = gv_menge.
              CLEAR gv_menge.
            ENDIF.

            APPEND INITIAL LINE TO lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
            <ls_item> = VALUE #( material = gs_disp-matnr  "선택한 Row의 출고자재
                                    plant = gs_disp-werks  "선택한 Row의 플랜트
                                 stge_loc = gs_disp-lgort  "선택한 Row의 출고 창고
                                    batch = gs_stock2-charg
                                move_type = '261'           "이동유형
                                stck_type = 'F'             "재고유형
                                entry_qnt = lv_menge  "선택한 Row의 출고 수량
                                entry_uom = gs_disp-erfme  "선택한 Row의 출고 단위
                                  orderid = gs_disp-aufnr ).  "선택한 Row의 오더번호
*                        reserv_no = gs_disp-rsnum  "선택한 Row의 예약번호
*                        res_item  = gs_disp-rspos ). "선택한 Row의 예약품목번호

            gs_batch-charg = gs_stock2-charg.
            gs_batch-menge = lv_menge.
            APPEND gs_batch TO gt_batch.

            IF gv_menge = 0.
              EXIT.
            ENDIF.

          ENDLOOP.

        ENDIF.

      ENDIF.
* 투입 처리 건이 있을 시에만 BAPI 태울 것
      CHECK lt_item[] IS NOT INITIAL.
*- 투입 처리 (펑션 호출)
      CLEAR : lv_document, lv_year, lt_return.
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = ls_header
          goodsmvt_code    = lv_code
        IMPORTING
          materialdocument = lv_document
          matdocumentyear  = lv_year
        TABLES
          goodsmvt_item    = lt_item
          return           = lt_return.
* 실투입 처리 결과 이력 남기기
*- 실패
      IF line_exists( lt_return[ type = 'E' ] ).

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        IF p_chk IS NOT INITIAL.
          READ TABLE lt_return INTO DATA(ls_return) WITH KEY type = 'E'.
          WRITE :/ TEXT-027, ls_return-message.
        ENDIF.

      ELSE.
*- 성공
* 실투입 오류 처리 수량 업데이트
        CLEAR lv_enmng.
        lv_enmng = gs_disp-enmng. "실제 투입량에 기존 투입량 포함
        LOOP AT lt_item INTO DATA(ls_item).
          lv_enmng = lv_enmng + ls_item-entry_qnt.
        ENDLOOP.

        IF gs_disp-gimng = lv_enmng.

          UPDATE zgtppt3100 SET   enmng = lv_enmng
                                process = 'R'
                                  chdat = sy-datum
                                  chtim = sy-uzeit
                                  chnam = sy-uname
                            WHERE weblnr     = gs_disp-weblnr
                              AND weblpos    = gs_disp-weblpos
                              AND zserno     = gs_disp-zserno
                              AND zsystem_id = gs_disp-zsystem_id.

        ELSE."IF gs_disp-gimng < lv_enmng.

          UPDATE zgtppt3100 SET enmng = lv_enmng
                                chdat = sy-datum
                                chtim = sy-uzeit
                                chnam = sy-uname
                            WHERE weblnr     = gs_disp-weblnr
                              AND weblpos    = gs_disp-weblpos
                              AND zserno     = gs_disp-zserno
                              AND zsystem_id = gs_disp-zsystem_id.

        ENDIF.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        IF p_chk IS NOT INITIAL.
          WRITE :/ TEXT-028.
        ENDIF.
* 성공한 건만 ZGTPPT3101 업데이트
        CLEAR : lv_seqno, ls_3101, lt_3101.
        SELECT SINGLE MAX( seqno ) INTO lv_seqno FROM zgtppt3101
                                                 WHERE weblnr  = gs_disp-weblnr
                                                   AND weblpos = gs_disp-weblpos.

        LOOP AT lt_item INTO ls_item.

          CLEAR ls_3101.
          lv_seqno = lv_seqno + 1.
          MOVE-CORRESPONDING gs_disp TO ls_3101.
          ls_3101-seqno = lv_seqno.
          ls_3101-charg = ls_item-batch.
          IF ls_3101-tagnr IS INITIAL
            AND gv_xchpf = 'X'.
            SELECT SINGLE tagnr INTO @ls_3101-tagnr
                     FROM zppt0001
                     WHERE werks = @ls_3101-werks
                       AND charg = @ls_3101-charg
                       AND matnr = @ls_3101-matnr.
          ENDIF.
          ls_3101-erfmg = ls_item-entry_qnt.
          ls_3101-mblnr = lv_document.
          ls_3101-mjahr = lv_year.
          ls_3101-crdat = ls_3101-chdat = sy-datum.
          ls_3101-crtim = ls_3101-chtim = sy-uzeit.
          ls_3101-crnam = ls_3101-chnam = sy-uname.
          APPEND ls_3101 TO lt_3101.

        ENDLOOP.

        IF lt_3101[] IS NOT INITIAL.
          MODIFY zgtppt3101 FROM TABLE lt_3101.
          IF sy-subrc = 0.
            COMMIT WORK.
          ELSE.
            ROLLBACK WORK.
          ENDIF.
        ENDIF.

        IF gv_xchpf = 'X'.
*- 배치 특성 업데이트 처리
          PERFORM process_update_batch_char USING TEXT-009.
*- 꼬리표 업데이트 처리
          PERFORM process_update_tagnr USING lv_document lv_year.

        ENDIF.

      ENDIF.

*    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_attribute
*&---------------------------------------------------------------------*
FORM set_cell_attribute .
* 셀 컬러부여
  DATA : lt_coltab TYPE lvc_t_scol.
  DATA : ls_coltab TYPE lvc_s_scol.

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.

  REFRESH lt_coltab.
  REFRESH lt_celltab.

  IF gs_disp-xchar = 'X'.

    CLEAR ls_celltab.
    ls_celltab-fieldname = 'CHARG'.
    ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
    INSERT ls_celltab INTO TABLE lt_celltab.
    CLEAR ls_celltab.
    ls_celltab-fieldname = 'TAGNR'.
    ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
    INSERT ls_celltab INTO TABLE lt_celltab.

  ELSE.

    CLEAR ls_celltab.
    ls_celltab-fieldname = 'CHARG'.
    ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT ls_celltab INTO TABLE lt_celltab.
    CLEAR ls_celltab.
    ls_celltab-fieldname = 'TAGNR'.
    ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT ls_celltab INTO TABLE lt_celltab.

  ENDIF.

*  IF gs_disp-gubun = TEXT-008.

  CLEAR ls_celltab.
  ls_celltab-fieldname = 'DEL_REASON'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
  INSERT ls_celltab INTO TABLE lt_celltab.

*    CLEAR ls_celltab.
*    ls_celltab-fieldname = 'REASON_TEXT'.
*    ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
*    INSERT ls_celltab INTO TABLE lt_celltab.

  CLEAR ls_celltab.
  ls_celltab-fieldname = 'DETAILS'.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
  INSERT ls_celltab INTO TABLE lt_celltab.

*  ELSE.
*
*    CLEAR ls_celltab.
*    ls_celltab-fieldname = 'DEL_REASON'.
*    ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
*    INSERT ls_celltab INTO TABLE lt_celltab.
*
**    CLEAR ls_celltab.
**    ls_celltab-fieldname = 'REASON_TEXT'.
**    ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
**    INSERT ls_celltab INTO TABLE lt_celltab.
*
*    CLEAR ls_celltab.
*    ls_celltab-fieldname = 'DETAILS'.
*    ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
*    INSERT ls_celltab INTO TABLE lt_celltab.
*    CLEAR ls_celltab.
*
*  ENDIF.

  CLEAR ls_coltab.
  ls_coltab-fname = 'GUBUN'.
  ls_coltab-color-col = '5'.
  ls_coltab-color-int = '1'.
  ls_coltab-nokeycol  = ' '.
  INSERT ls_coltab INTO TABLE lt_coltab.

  CLEAR ls_coltab.
  ls_coltab-fname = 'WEBLNR'.
  ls_coltab-color-col = '4'.
  ls_coltab-color-int = '1'.
  ls_coltab-nokeycol  = ' '.
  INSERT ls_coltab INTO TABLE lt_coltab.

  CLEAR ls_coltab.
  ls_coltab-fname = 'WEBLPOS'.
  ls_coltab-color-col = '4'.
  ls_coltab-color-int = '1'.
  ls_coltab-nokeycol  = ' '.
  INSERT ls_coltab INTO TABLE lt_coltab.

  gs_disp-cellcol = lt_coltab.
  gs_disp-celltab = lt_celltab.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  F4_MATNR  INPUT
*&---------------------------------------------------------------------*
MODULE f4_matnr INPUT.

  DATA : BEGIN OF lt_matnr OCCURS 0,
           matnr   LIKE marc-matnr,
           maktx   LIKE makt-maktx,
           matkl   LIKE mara-matkl,
           wgbez60 LIKE t023t-wgbez60,
         END OF lt_matnr.
  DATA : lt_scr_fields LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH : gt_rtntab, gt_dselc.
  CLEAR : gt_rtntab, gt_dselc.

  gt_dselc-fldname = 'F0001'.
  gt_dselc-dyfldname = 'MATNR'.
  APPEND gt_dselc.

  gt_dselc-fldname = 'F0002'.
  gt_dselc-dyfldname = 'MAKTX'.
  APPEND gt_dselc.

  SELECT a~matnr, b~maktx, c~matkl, d~wgbez60
      INTO CORRESPONDING FIELDS OF TABLE @lt_matnr
      FROM marc AS a INNER JOIN makt AS b
          ON   a~matnr EQ b~matnr
          AND a~werks EQ @p_werks
          AND b~spras EQ @sy-langu
          INNER JOIN mara AS c
          ON  a~matnr EQ c~matnr
          INNER JOIN t023t AS d
          ON   d~spras EQ @sy-langu
          AND c~matkl EQ d~matkl
          WHERE c~meins IN @gr_meins
               AND c~matkl IN @gr_matkl.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MATNR'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      window_title    = TEXT-029 "자재 선택
      value_org       = 'S'
    TABLES
      value_tab       = lt_matnr
      return_tab      = gt_rtntab
      dynpfld_mapping = gt_dselc
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  CLEAR gt_rtntab.
  READ TABLE gt_rtntab WITH KEY retfield = 'MATNR'.
  IF sy-subrc = 0.
    gv_matnr = gt_rtntab-fieldval.
  ENDIF.

  CLEAR gt_rtntab.
  READ TABLE gt_rtntab WITH KEY retfield = 'MAKTX'.
  IF sy-subrc = 0.
    gv_maktx = gt_rtntab-fieldval.
  ENDIF.
* 해당 BOM의 출고 저장위치 추출
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input  = gv_matnr
    IMPORTING
      output = gv_matnr.
  SELECT SINGLE a~lgort INTO @gv_lgort
                  FROM stpo AS a INNER JOIN mast AS b
                      ON a~stlnr = b~stlnr
                      WHERE a~idnrk EQ @gv_matnr
                           AND a~lgort <> @space
                           AND b~werks EQ @p_werks
                           AND b~matnr IN @gr_matnr
                           AND b~stlan EQ '1'. "양산 BOM
* BOM의 출고 저장위치 추출실패시, 기존 2) MARC~LGPRO 추출
  IF gv_lgort IS INITIAL.

    SELECT SINGLE lgpro INTO @gv_lgort
                                     FROM marc
                                     WHERE werks EQ @p_werks
                                          AND matnr EQ @gv_matnr.

  ENDIF.

  SELECT SINGLE lgobe INTO @gv_lgobe FROM t001l WHERE werks EQ @p_werks
                                                                                       AND lgort EQ @gv_lgort.
* 아래 부분이 선택된 값들을 화면 필드에 뿌려준다.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      input  = gv_matnr
    IMPORTING
      output = gv_matnr.
  lt_scr_fields-fieldname  = 'GV_MATNR'.
  lt_scr_fields-fieldvalue = gv_matnr.
  APPEND lt_scr_fields.

  lt_scr_fields-fieldname  = 'GV_MAKTX'.
  lt_scr_fields-fieldvalue = gv_maktx.
  APPEND lt_scr_fields.

  lt_scr_fields-fieldname  = 'GV_LGORT'.
  lt_scr_fields-fieldvalue = gv_lgort.
  APPEND lt_scr_fields.

  lt_scr_fields-fieldname  = 'GV_LGOBE'.
  lt_scr_fields-fieldvalue = gv_lgobe.
  APPEND lt_scr_fields.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = lt_scr_fields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form authority_checking_proc
*&---------------------------------------------------------------------*
FORM authority_checking_proc .
*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
  ID 'WERKS'  FIELD p_werks.

  IF sy-subrc <> 0.
    MESSAGE e006 WITH TEXT-010 p_werks TEXT-013.
  ELSE.
*& MRP 관리자에 대한 권한체크
    IF s_dispo-low IS NOT INITIAL.
      AUTHORITY-CHECK OBJECT 'ZPP_DISPO'
      ID 'WERKS'  FIELD p_werks
      ID 'DISPO'  FIELD s_dispo-low.

      IF sy-subrc <> 0.
        MESSAGE e006 WITH TEXT-014 s_dispo-low TEXT-013.
      ENDIF.
    ELSE.
*& MRP 관리자에 대한 권한체크
      IF s_dispo2-low IS NOT INITIAL.
        AUTHORITY-CHECK OBJECT 'ZPP_DISPO'
        ID 'WERKS'  FIELD p_werks
        ID 'DISPO'  FIELD s_dispo2-low.

        IF sy-subrc <> 0.
          MESSAGE e006 WITH TEXT-015 s_dispo2-low TEXT-013.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_gt_result
*&---------------------------------------------------------------------*
FORM update_gt_result USING pv_icon pv_message pv_gubun.

  CLEAR gs_result.
  READ TABLE gt_result INTO gs_result
                                 WITH KEY weblnr  = gs_disp-weblnr
                                          weblpos = gs_disp-weblpos.

  IF gs_result IS INITIAL.

    gs_result-icon       = pv_icon. "재처리 상태
    gs_result-message = pv_message. "처리 결과
    gs_result-gubun    = pv_gubun. "오류 유형
    gs_result-weblnr    = gs_disp-weblnr. "백로그 번호
    gs_result-weblpos = gs_disp-weblpos. "백로그 아이템
    gs_result-matnr     = gs_disp-matnr. "자재코드
    gs_result-maktx    = gs_disp-maktx. "자재내역
    gs_result-werks    = gs_disp-werks. "플랜트
    gs_result-lgort      = gs_disp-lgort. "저장위치
    gs_result-charg    = gs_disp-charg. "배치번호
    gs_result-erfmg    = gs_disp-erfmg. "수량
    gs_result-erfme    = gs_disp-erfme. "단위
    APPEND gs_result TO gt_result.

*  ELSE.
*
*    IF pv_icon IS NOT INITIAL.
*      gs_result-icon       = pv_icon. "재처리 상태
*    ENDIF.
*    IF pv_icon2 IS NOT INITIAL.
*      gs_result-icon2     = pv_icon2. "배치 업데이트 상태
*    ENDIF.
*    MODIFY gt_result FROM gs_result INDEX sy-tabix.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZGTPPT3270
*&---------------------------------------------------------------------*
FORM update_zgtppt3270 .

  CLEAR gs_3270.
  gs_3270-weblnr = gs_disp-weblnr.
  gs_3270-weblpos = gs_disp-weblpos.
  SELECT SINGLE MAX( seqno ) INTO @DATA(lv_seqno) FROM zgtppt3270
                             WHERE weblnr  = @gs_disp-weblnr
                               AND weblpos = @gs_disp-weblpos.
  gs_3270-seqno    = lv_seqno + 1.
  gs_3270-type     = 'M'.
  gs_3270-matnr_fr = gs_disp-matnr.
  gs_3270-matnr_to = gv_matnr.
  gs_3270-werks    = p_werks.
  gs_3270-lgort_fr = gs_disp-lgort.
  gs_3270-erfmg_fr = gs_disp-erfmg.
  gs_3270-erfme    = gs_disp-erfme.
  gs_3270-budat_fr = gs_disp-budat.
  gs_3270-chdat    = gs_3270-crdat    = sy-datum.
  gs_3270-chtim    = gs_3270-crtim    = sy-uzeit.
  gs_3270-chnam    = gs_3270-crnam    = sy-uname.
  MODIFY zgtppt3270 FROM gs_3270.
  IF sy-subrc = 0.
    COMMIT WORK.
    WAIT UP TO '0.5' SECONDS.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_zgtppt3270_rework
*&---------------------------------------------------------------------*
FORM update_zgtppt3270_rework .

  DATA : lv_cnt TYPE i.

  CLEAR : gs_3270, gs_affw, lv_cnt.
  READ TABLE gt_affw INTO gs_affw WITH KEY weblnr = gs_disp-weblnr
                                           weblpos = gs_disp-weblpos.

  IF gs_affw IS NOT INITIAL.

    gs_3270-weblnr  = gs_disp-weblnr.
    gs_3270-weblpos = gs_disp-weblpos.
    SELECT SINGLE MAX( seqno ) INTO @DATA(lv_seqno) FROM zgtppt3270
                               WHERE weblnr  = @gs_disp-weblnr
                                 AND weblpos = @gs_disp-weblpos.
    gs_3270-seqno = lv_seqno + 1.

    IF gs_disp-budat NE gs_affw-budat.
      lv_cnt = lv_cnt + 1.
      gs_3270-type = 'D'.
      gs_3270-budat_to = gs_disp-budat.
    ENDIF.
    IF gs_disp-lgort NE gs_affw-lgort.
      lv_cnt = lv_cnt + 1.
      gs_3270-type = 'L'.
      gs_3270-lgort_to = gs_disp-lgort.
    ENDIF.
    IF gs_disp-erfmg NE gs_affw-erfmg.
      lv_cnt = lv_cnt + 1.
      gs_3270-type = 'E'.
      gs_3270-erfmg_to = gs_disp-erfmg.
    ENDIF.
    IF lv_cnt > 1.
      gs_3270-type = 'N'.
    ENDIF.

    gs_3270-matnr_fr = gs_disp-matnr.
    gs_3270-werks    = p_werks.
    gs_3270-lgort_fr = gs_affw-lgort.
    gs_3270-erfmg_fr = gs_affw-erfmg.
    gs_3270-erfme    = gs_disp-erfme.
    gs_3270-budat_fr = gs_affw-budat.
    gs_3270-chdat    = gs_3270-crdat    = sy-datum.
    gs_3270-chtim    = gs_3270-crtim    = sy-uzeit.
    gs_3270-chnam    = gs_3270-crnam    = sy-uname.
    APPEND gs_3270 TO gt_3270.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_zgtppt3270_error_gi
*&---------------------------------------------------------------------*
FORM update_zgtppt3270_error_gi .

  DATA : lv_cnt TYPE i.

  CLEAR : gs_3100, gs_3270.
* 대체 자재 변경 이력 저장을 위한 기존 ZGTPPT3100 데이터 취합
  SELECT SINGLE * INTO CORRESPONDING FIELDS OF @gs_3100
                  FROM zgtppt3100
                  WHERE weblnr     = @gs_disp-weblnr
                    AND weblpos    = @gs_disp-weblpos
                    AND zserno     = @gs_disp-zserno
                    AND zsystem_id = @gs_disp-zsystem_id.

  gs_3270-weblnr  = gs_disp-weblnr.
  gs_3270-weblpos = gs_disp-weblpos.
  SELECT SINGLE MAX( seqno ) INTO @DATA(lv_seqno) FROM zgtppt3270
                             WHERE weblnr  = @gs_disp-weblnr
                               AND weblpos = @gs_disp-weblpos.
  gs_3270-seqno = lv_seqno + 1.

  IF gs_disp-budat NE gs_3100-budat.
    lv_cnt = lv_cnt + 1.
    gs_3270-type = 'D'.
    gs_3270-budat_to = gs_disp-budat.
  ENDIF.
  IF gs_disp-lgort NE gs_3100-lgort.
    lv_cnt = lv_cnt + 1.
    gs_3270-type = 'L'.
    gs_3270-lgort_to = gs_disp-lgort.
  ENDIF.
  IF gs_disp-erfmg NE gs_3100-erfmg.
    lv_cnt = lv_cnt + 1.
    gs_3270-type = 'E'.
    gs_3270-erfmg_to = gs_disp-erfmg.
  ENDIF.
  IF lv_cnt > 1.
    gs_3270-type = 'N'.
  ENDIF.

  gs_3270-matnr_fr = gs_disp-matnr.
  gs_3270-werks    = p_werks.
  gs_3270-lgort_fr = gs_3100-lgort.
  gs_3270-erfmg_fr = gs_3100-erfmg.
  gs_3270-erfme    = gs_disp-erfme.
  gs_3270-budat_fr = gs_3100-budat.
  gs_3270-chdat    = gs_3270-crdat    = sy-datum.
  gs_3270-chtim    = gs_3270-crtim    = sy-uzeit.
  gs_3270-chnam    = gs_3270-crnam    = sy-uname.
  APPEND gs_3270 TO gt_3270.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_CHANGE_MATNR_HISTORY
*&---------------------------------------------------------------------*
FORM display_change_matnr_history .

  CLEAR  : gt_row_no, gt_row_no[].
  CALL METHOD go_grid_0100->get_selected_rows
    IMPORTING
      et_row_no = gt_row_no[].

  CLEAR: gv_cnt.
  DESCRIBE TABLE gt_row_no LINES gv_cnt.
* 선택 라인 없으면 오류 메시지 출력
  IF gv_cnt = 0.
    MESSAGE s000 WITH TEXT-m01 DISPLAY LIKE 'E'.
  ELSEIF gv_cnt > 1.
    MESSAGE s000 WITH TEXT-m24 DISPLAY LIKE 'E'.
  ENDIF.

  CHECK gv_cnt = 1.

  CLEAR : gt_3270.
  LOOP AT gt_row_no.

    CLEAR : gs_disp, gs_302, gt_302, gs_3270.
    READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.

    IF gs_disp IS NOT INITIAL.

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE @gt_3270
        FROM zgtppt3270
        WHERE weblnr  EQ @gs_disp-weblnr
          AND weblpos EQ @gs_disp-weblpos
          AND type    EQ 'M'.

      LOOP AT gt_3270 INTO gs_3270.

        CLEAR gs_302.
        gs_302-weblnr   = gs_3270-weblnr.
        gs_302-weblpos  = gs_3270-weblpos.
        gs_302-seqno    = gs_3270-seqno.
        gs_302-matnr_fr = gs_3270-matnr_fr.
        gs_302-maktx    = zgtpp_cl_common=>get_maktx(
                           iv_matnr = gs_302-matnr_fr ).
        gs_302-matnr_to = gs_3270-matnr_to.
        gs_302-maktx2   = zgtpp_cl_common=>get_maktx(
                           iv_matnr = gs_302-matnr_to ).
        gs_302-crdat    = gs_3270-crdat.
        gs_302-crtim    = gs_3270-crtim.
        gs_302-crnam    = gs_3270-crnam.
        APPEND gs_302 TO gt_302.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT gt_302 BY weblnr weblpos seqno.

  IF gt_302[] IS NOT INITIAL.

    CALL SCREEN 0302 STARTING AT 2 2 ENDING AT 130 20.

  ELSE.

    MESSAGE s000 WITH TEXT-m25 DISPLAY LIKE 'E'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form cal_stan_price_backlog_money
*&---------------------------------------------------------------------*
FORM cal_stan_price_backlog_money .

  DATA : lv_menge LIKE ekpo-menge.

  DATA(lt_disp) = gt_disp[].
  SORT lt_disp BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM lt_disp COMPARING matnr werks.

  IF lt_disp[] IS NOT INITIAL.

    SELECT *
      INTO TABLE @DATA(lt_mbewh)
      FROM mbewh
      FOR ALL ENTRIES IN @lt_disp
      WHERE matnr EQ @lt_disp-matnr
        AND bwkey EQ @lt_disp-werks.

    SELECT *
      INTO TABLE @DATA(lt_mbew)
      FROM mbew
      FOR ALL ENTRIES IN @lt_disp
      WHERE matnr EQ @lt_disp-matnr
        AND bwkey EQ @lt_disp-werks.

  ENDIF.

  LOOP AT gt_disp INTO gs_disp.

    gv_tabix = sy-tabix.
* 자재 기본 단위와 ALV 투입 단위가 다를 경우 기본 단위 기준으로 환산
    CLEAR lv_menge.
    SELECT SINGLE meins INTO @DATA(lv_meins) FROM mara
                        WHERE matnr = @gs_disp-matnr.
    IF lv_meins NE gs_disp-erfme.

      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          i_matnr              = gs_disp-matnr
          i_in_me              = gs_disp-erfme
          i_out_me             = lv_meins
          i_menge              = gs_disp-gimng
        IMPORTING
          e_menge              = lv_menge
        EXCEPTIONS
          error_in_application = 1
          error                = 2.

    ELSE.

      lv_menge = gs_disp-gimng.

    ENDIF.

    IF gs_disp-budat+0(6) NE sy-datum+0(6).

      READ TABLE lt_mbewh INTO DATA(ls_mbewh)
                          WITH KEY matnr = gs_disp-matnr
                                   bwkey = gs_disp-werks
                                   lfgja = gs_disp-budat+0(4)
                                   lfmon = gs_disp-budat+4(2).

      IF ls_mbewh IS NOT INITIAL AND
         ls_mbewh-stprs IS NOT INITIAL AND
         ls_mbewh-peinh IS NOT INITIAL.

        gs_disp-stprs = ls_mbewh-stprs / ls_mbewh-peinh. "표준가
        gs_disp-money = lv_menge * gs_disp-stprs. "백로그 금액
        gs_disp-waers = gv_waers. "통화키

      ENDIF.

    ELSE.

      READ TABLE lt_mbew INTO DATA(ls_mbew)
                         WITH KEY matnr = gs_disp-matnr
                                  bwkey = gs_disp-werks.

      IF ls_mbew IS NOT INITIAL AND
         ls_mbew-stprs IS NOT INITIAL AND
         ls_mbew-peinh IS NOT INITIAL.

        gs_disp-stprs = ls_mbew-stprs / ls_mbew-peinh. "표준가
        gs_disp-money = lv_menge * gs_disp-stprs. "백로그 금액
        gs_disp-waers = gv_waers. "통화키

      ENDIF.

    ENDIF.
*- Start 2025.06.10
    IF p_werks EQ '1306'.

      IF s_bstnk[] IS INITIAL.

        SELECT SINGLE b~bstnk
                 INTO @gs_disp-bstnk
                 FROM afpo AS a INNER JOIN vbak AS b
                   ON a~kdauf = b~vbeln
                   WHERE a~aufnr EQ @gs_disp-aufnr.

      ELSE.

        SELECT SINGLE b~bstnk
           INTO @gs_disp-bstnk
           FROM afpo AS a INNER JOIN vbak AS b
             ON a~kdauf = b~vbeln
             WHERE a~aufnr EQ @gs_disp-aufnr
               AND b~bstnk IN @s_bstnk.

        IF gs_disp-bstnk IS INITIAL.
          DELETE gt_disp INDEX gv_tabix.
          CONTINUE.
        ENDIF.

      ENDIF.

    ENDIF. "제조지시번호

    MODIFY gt_disp FROM gs_disp INDEX gv_tabix.
    CLEAR : ls_mbewh, ls_mbew.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_screen_attribute
*&---------------------------------------------------------------------*
FORM set_screen_attribute .

  LOOP AT SCREEN.

    IF screen-group1 = 'DS1'.

      IF p_werks EQ '1306'. "전송
        screen-active       = 1.
      ELSE.
        screen-active       = 0.
      ENDIF.

    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_COCKPIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM chk_cockpit .
  DATA: lv_ckp(1).
  IMPORT ckp TO lv_ckp FROM MEMORY ID 'CKP'.
  FREE MEMORY ID 'CKP'.

  IF lv_ckp EQ 'X'.
    EXPORT ckp = 'S' TO MEMORY ID 'CKP'.
    CLEAR: lv_ckp.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form submit_zppr9012
*&---------------------------------------------------------------------*
*& 데이터 조회 전에 zppr9012 (CO1P) 를 수행.
*&---------------------------------------------------------------------*
*& 2025.11.28.zlsgpp5.create.
*&---------------------------------------------------------------------*
FORM submit_zppr9012 .

  DEFINE _selscreen.
    CLEAR &1.
    &1-selname  = &2.
    &1-kind     = &3. "P:parameters, S:selection criteria.
    &1-sign     = &4.
    &1-option   = &5.
    &1-low      = &6.
    &1-high     = &7.
    APPEND &1.
  END-OF-DEFINITION.
  DATA: lt_sel  TYPE TABLE OF rsparams WITH HEADER LINE .


* 메시지가 없는 건 추출
  SELECT DISTINCT b~werks, b~aufnr
    INTO TABLE @DATA(lt_affw)
    FROM afko AS a INNER JOIN affw AS b ON a~aufnr = b~aufnr
   WHERE a~dispo  IN @s_dispo   "조회조건-MRP관리자
     AND a~aufnr  IN @s_aufnr   "조회조건-생산오더번호
     AND a~plnbez IN @s_matnr   "조회조건-품목코드
     AND b~werks  EQ @p_werks   "조회조건-플랜트
     AND b~lgort  IN @s_lgort   "조회조건-저장위치
     AND b~matnr  IN @s_matnr2  "조회조건-자재코드
     AND b~bwart  IN @s_bwart   "조회조건-이동유형
     AND b~ersda  IN @s_ersda   "조회조건-오류 발생일자
     AND b~budat  IN @s_budat   "조회조건-전기일자
     AND b~dispo  IN @s_dispo2  "조회조건-MRP관리자
     AND b~msgty  EQ @space.

* ZPPR9012 호출.
  LOOP AT lt_affw ASSIGNING FIELD-SYMBOL(<affw>).

    CLEAR: lt_sel, lt_sel[].
    _selscreen lt_sel 'S_WERKS' 'S' 'I' 'EQ' <affw>-werks ''.
    _selscreen lt_sel 'S_AUFNR' 'S' 'I' 'EQ' <affw>-aufnr ''.

    SUBMIT zppr9012 WITH SELECTION-TABLE lt_sel
                    WITH g_recpts EQ space
                    WITH g_issues EQ 'X'
                    AND RETURN.

  ENDLOOP.

ENDFORM.
