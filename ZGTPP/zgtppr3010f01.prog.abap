*&---------------------------------------------------------------------*
*& Include          ZGTPPR3010F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_default_layout
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
FORM select_alv_variant CHANGING pv_layo TYPE disvariant-variant.

  DATA:
    ls_variant TYPE disvariant.

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
FORM get_data .

  DATA: lv_msgcode(100),
        lv_error,
        lv_tabix        LIKE sy-tabix,
        lv_process      LIKE zgtppt3000-process.
  DATA : lv_ename   LIKE gs_disp-ename,
         ls_zpa0539 LIKE zpa0539.
  DATA : BEGIN OF ls_aufnr,
           aufnr LIKE afko-aufnr,
           werks LIKE aufk-werks,
         END OF ls_aufnr.
  DATA : lt_aufnr LIKE TABLE OF ls_aufnr.
* ZGTPPT3000, AFKO, AFPO, AUFK JOIN 해서 백로그 데이터 취합
  IF p_del EQ 'X'.
    lv_process = 'D'.
  ELSE. "재처리 내역 조회
    lv_process = 'R'.
  ENDIF.

  SELECT b~*, a~plnbez AS pmatnr, e~matkl
     INTO TABLE @DATA(lt_data)
     FROM afko AS a INNER JOIN zgtppt3000 AS b
        ON a~aufnr = b~aufnr
        INNER JOIN aufk AS d
        ON a~aufnr = d~aufnr
        INNER JOIN mara AS e
        ON b~matnr = e~matnr
        WHERE d~werks EQ @p_werks "조회조건-플랜트
            AND a~dispo IN @s_dispo "조회조건-MRP관리자
            AND a~aufnr IN @s_aufnr "조회조건-생산오더번호
            AND a~plnbez IN @s_matnr "조회조건-품목코드
            AND b~lgort IN @s_lgort "조회조건-저장위치
            AND b~matnr IN @s_matnr2 "조회조건-자재코드
            AND b~bwart IN @s_bwart "조회조건-이동유형
            AND b~ersda IN @s_ersda "조회조건-오류 발생일자
            AND b~budat IN @s_budat "조회조건-전기일자
            AND b~crdat IN @s_crdat "조회조건-삭제일자
            AND b~process EQ @lv_process
            AND b~dispo IN @s_dispo2.

  CLEAR : ls_aufnr, lt_aufnr.
  LOOP AT lt_data INTO DATA(ls_data).
    ls_aufnr-aufnr = ls_data-b-aufnr.
    ls_aufnr-werks = ls_data-b-werks.
    APPEND ls_aufnr TO lt_aufnr.
  ENDLOOP.

  SORT lt_aufnr BY aufnr werks.
  DELETE ADJACENT DUPLICATES FROM lt_aufnr COMPARING ALL FIELDS.

  IF lt_aufnr[] IS NOT INITIAL.

    SELECT aufnr, pdcaproccode INTO TABLE @DATA(lt_gong)
        FROM zgtcvordsyval
        FOR ALL ENTRIES IN @lt_aufnr
        WHERE aufnr EQ @lt_aufnr-aufnr
             AND werks EQ @lt_aufnr-werks
             AND pdcaproccode IN @s_gong.

  ENDIF.

  LOOP AT lt_data INTO ls_data.

    lv_tabix = sy-tabix.

    READ TABLE lt_gong INTO DATA(ls_gong) WITH KEY aufnr = ls_data-b-aufnr.
    IF sy-subrc = 0.
* 조회된 데이터 기준으로 Lock Object 처리하여 다른 사용자가 처리할 수 없도록 함.
* 삭제 내역 조회모드만 해당
      IF p_del EQ 'X'.

        CALL FUNCTION 'ENQUEUE_EZGT_ZGTPPR3010'
          EXPORTING
            werks  = ls_data-b-werks
            dispo  = ls_data-b-dispo
          EXCEPTIONS
            OTHERS = 3.

        IF sy-subrc <> 0.

          CLEAR : lv_ename, ls_zpa0539.
          SELECT SINGLE * INTO CORRESPONDING FIELDS OF @ls_zpa0539
          FROM zpa0539
          WHERE pernr EQ @sy-msgv1.
          IF ls_zpa0539 IS NOT INITIAL.
            lv_ename = ls_zpa0539-lnmhg && ls_zpa0539-fnmhg.
          ENDIF.

          CONCATENATE TEXT-t01 ls_data-b-werks
                               TEXT-t02 ls_data-b-dispo
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
* 상태
    IF p_del EQ 'X'.
      gs_disp-icon = icon_led_red.
    ELSE.
      gs_disp-icon = icon_led_green.
    ENDIF.
* Message
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

    gs_disp-pmatnr = ls_data-pmatnr.
    gs_disp-matkl = ls_data-matkl.
* 오류 유형
    gs_disp-gubun = TEXT-006.
* 플랜트 내역
    SELECT SINGLE name1 INTO gs_disp-name1 FROM t001w
                                   WHERE werks EQ gs_disp-werks.
* MRP관리자 내역
    SELECT SINGLE dsnam INTO gs_disp-dsnam FROM t024d
                                    WHERE werks EQ gs_disp-werks
                                        AND dispo EQ gs_disp-dispo.
* 삭제 사유 내역
    CLEAR gs_zgtppt1010.
    READ TABLE gt_zgtppt1010 INTO gs_zgtppt1010
                                        WITH KEY fld_02 = gs_disp-del_reason.
    IF gs_zgtppt1010 IS NOT INITIAL.
      gs_disp-reason_text = gs_zgtppt1010-fld_03.
    ENDIF.
* 오류 생성자 명
    CLEAR : gs_zpa0539.
    READ TABLE gt_zpa0539 INTO gs_zpa0539
                                     WITH KEY pernr = gs_disp-ernam.
    IF gs_zpa0539 IS NOT INITIAL.
      gs_disp-ename = gs_zpa0539-lnmhg && gs_zpa0539-fnmhg.
    ENDIF.
* 최종 변경자 명
    CLEAR : gs_zpa0539.
    READ TABLE gt_zpa0539 INTO gs_zpa0539
                                     WITH KEY pernr = gs_disp-aenam.
    IF gs_zpa0539 IS NOT INITIAL.
      gs_disp-cname = gs_zpa0539-lnmhg && gs_zpa0539-fnmhg.
    ENDIF.
* 삭제자 명
    CLEAR : gs_zpa0539.
    READ TABLE gt_zpa0539 INTO gs_zpa0539
                                     WITH KEY pernr = gs_disp-crnam.
    IF gs_zpa0539 IS NOT INITIAL.
      gs_disp-dname = gs_zpa0539-lnmhg && gs_zpa0539-fnmhg.
    ENDIF.
* 자재 내역
    gs_disp-maktx = zgtpp_cl_common=>get_maktx(
                           iv_matnr = gs_disp-matnr ).
* 자재 그룹 내역
    SELECT SINGLE wgbez60 INTO gs_disp-wgbez60
                                       FROM t023t
                                       WHERE spras EQ sy-langu
                                           AND matkl EQ gs_disp-matkl.
*  품목명
    gs_disp-maktx2 = zgtpp_cl_common=>get_maktx(
                           iv_matnr = gs_disp-pmatnr ).
* 삭제 내역 조회 시 투입 오류 수량에 투입 완료 수량 반영 후 CLEAR(삭제 내역 조회시에만)
    gs_disp-erfmg_e = ls_data-b-erfmg.
    IF p_del = 'X'.
      CLEAR gs_disp-erfmg.
    ENDIF.
* 특정 필드 앞의 0 제거
    PERFORM convert_field USING gs_disp-weblnr '-'. "백로그 문서 번호
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input        = gs_disp-matnr
      IMPORTING
        output       = gs_disp-matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2. "자재코드
    PERFORM convert_field USING gs_disp-aufnr '-'.   "생산오더번호
    PERFORM convert_field USING gs_disp-pmatnr '-'."품목코드
* 투입 완료 수량, 투입 오류 수량 색깔 적용
    PERFORM set_cell_attribute.

    APPEND gs_disp TO gt_disp.
    CLEAR gs_disp.

  ENDLOOP.

  PERFORM append_data_zgtppt3100.

  SORT gt_disp BY werks weblnr weblpos.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_master_data
*&---------------------------------------------------------------------*
*& 마스터성 데이터를 READ TABLE로 빠르게 가져오기 위해 사전에 관련 데이터 취합
*&---------------------------------------------------------------------*
FORM get_master_data .

  CLEAR : gs_zgtppt1010, gt_zgtppt1010, gs_zpa0539, gt_zpa0539.
* 삭제 사유 코드 및 내역
  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @gt_zgtppt1010
      FROM zgtppt1010
      WHERE module_kind EQ 'PP'
          AND codegrp EQ '3000'
          AND fld_01 EQ @p_werks.
* 오류 생성자 명, 최종 변경자 명, 삭제자 명
  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @gt_zpa0539
      FROM zpa0539.

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
*& Form restore_backlog_data
*&---------------------------------------------------------------------*
FORM restore_backlog_data .

  DATA : lv_answer TYPE c.
* CALL FUNCTION - POPUP_TO_CONFIRM_STEP
  CLEAR: lv_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      titel     = TEXT-012 "백로그 삭제 취소
      textline1 = TEXT-013 "삭제한 백로그를 취소 하시겠습니까?
      textline2 = ''
    IMPORTING
      answer    = lv_answer.
  CHECK lv_answer = 'J'.
* 선택 레코드 중 한 건이라도 전기일자가 현재월에 해당되지 않는 건이 있으면 오류메시지 처리
  CLEAR  : gt_row_no, gt_row_no[].
  CALL METHOD go_grid_0100->get_selected_rows
    IMPORTING
      et_row_no = gt_row_no[].
* 선택 라인 없으면 오류 메시지 출력
  CLEAR: gv_cnt.
  DESCRIBE TABLE gt_row_no LINES gv_cnt.

  IF gv_cnt = 0.
    MESSAGE s000 WITH TEXT-m01 DISPLAY LIKE 'E'.
  ENDIF.

  CHECK gv_cnt > 0.
* 오류일자 체크( 현재월이랑 같지 않으면 처리 중단 및 오류메시지 뿌릴 것 )
  CLEAR : gv_error, gs_affw, gt_affw, gv_cnt, gv_cnt2.
  LOOP AT gt_row_no.

    CLEAR : gs_disp.
    READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.
*    IF gs_disp-budat+0(6) NE sy-datum+0(6).
    IF gs_disp-ersda+0(6) NE sy-datum+0(6).
      gv_error = 'X'.
      MESSAGE s000 WITH TEXT-m02 DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
* 백로그 : AFFW 추가 데이터를 인터널 테이블에 담음.
    IF gs_disp-gubun = TEXT-006.

      CLEAR gs_affw.
      MOVE-CORRESPONDING gs_disp TO gs_affw.
      gs_affw-erfmg = gs_disp-erfmg_e.
      PERFORM convert_field USING gs_affw-weblnr '+'. "백로그 문서 번호
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input        = gs_affw-matnr
        IMPORTING
          output       = gs_affw-matnr
        EXCEPTIONS
          length_error = 1
          OTHERS       = 2. "자재코드
      PERFORM convert_field USING gs_affw-aufnr '+'.   "생산오더번호
      APPEND gs_affw TO gt_affw.

    ELSEIF gs_disp-gubun = TEXT-007.
* 실투입은 바로 DB에 업데이트하고, 다 끝나면 COMMIT WORK 수행.
* 에러건 있으면 기존 업데이트건 ROLLBACK WORK 처리됨.
      UPDATE zgtppt3100 SET   process      = space
                              del_reason   = space
                              reason_text  = space
                              details      = space
                              chdat        = sy-datum
                              chtim        = sy-uzeit
                              chnam        = sy-uname
                        WHERE weblnr       = gs_disp-weblnr
                          AND weblpos      = gs_disp-weblpos
                          AND zserno       = gs_disp-zserno
                          AND zsystem_id   = gs_disp-zsystem_id.

      IF sy-subrc = 0.

        gv_cnt = gv_cnt + 1.

      ELSE.

        gv_cnt2 = gv_cnt2 + 1.

      ENDIF.

    ENDIF.

  ENDLOOP.
* 이상 없으면 앞서 처리한 데이터를 COMMIT WORK 처리
  IF gv_error IS INITIAL.
* 백로그 업데이트
    IF gt_affw[] IS NOT INITIAL.
* AFFW에 제대로 Insert 되면 ZGTPPT3000에 있는 데이터는 삭제
      MODIFY affw FROM TABLE gt_affw.
      IF sy-subrc = 0.

        LOOP AT gt_affw INTO gs_affw.

          DELETE FROM zgtppt3000 WHERE weblnr  = gs_affw-weblnr
                                   AND weblpos = gs_affw-weblpos.

          IF sy-subrc = 0.
            gv_cnt = gv_cnt + 1.
          ELSE.
            gv_cnt2 = gv_cnt2 + 1.
          ENDIF.

        ENDLOOP.

      ENDIF.

    ENDIF.

    COMMIT WORK.
* 결과 메시지 반영
    IF gv_cnt IS NOT INITIAL AND gv_cnt2 IS INITIAL.

      MESSAGE i000 WITH gv_cnt TEXT-m03.

    ELSEIF gv_cnt IS NOT INITIAL AND gv_cnt2 IS NOT INITIAL.

      MESSAGE i000 WITH gv_cnt TEXT-m03 gv_cnt2 TEXT-m04.

    ELSEIF gv_cnt IS INITIAL AND gv_cnt2 IS NOT INITIAL.

      MESSAGE i000 WITH gv_cnt2 TEXT-m04.

    ENDIF.
* 처리 후 데이터 REFRESH
    PERFORM get_data.
* REFRESH DISPLAY
    CALL METHOD go_grid_0100->refresh_table_display
      EXPORTING
        i_soft_refresh = 'X'
        is_stable      = gv_stable.

  ELSE.

    ROLLBACK WORK.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form convert_field
*&---------------------------------------------------------------------*
FORM convert_field USING pv_value pv_sign.

  IF pv_value IS NOT INITIAL.

    IF pv_sign = '-'.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = pv_value
        IMPORTING
          output = pv_value.

    ELSE.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = pv_value
        IMPORTING
          output = pv_value.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_data_zgtppt3100
*&---------------------------------------------------------------------*
FORM append_data_zgtppt3100 .

  DATA : lv_tabix LIKE sy-tabix.
  DATA : BEGIN OF ls_aufnr,
           aufnr LIKE afko-aufnr,
           werks LIKE aufk-werks,
         END OF ls_aufnr.
  DATA : lt_aufnr LIKE TABLE OF ls_aufnr.
  DATA : lt_wtab(72) OCCURS 100 WITH HEADER LINE.

  REFRESH lt_wtab.
  IF p_work EQ 'X'.
    CONCATENATE '    b~process NE ' ' ''D'' '  INTO lt_wtab.
    APPEND lt_wtab. CLEAR lt_wtab.
    CONCATENATE '    AND b~enmng > ' ' ''0'' '  INTO lt_wtab.
    APPEND lt_wtab. CLEAR lt_wtab.
  ELSE.
    CONCATENATE '    b~process EQ ' ' ''D'' '  INTO lt_wtab.
    APPEND lt_wtab. CLEAR lt_wtab.
  ENDIF.

  SELECT b~*, a~plnbez AS pmatnr, e~matkl
     INTO TABLE @DATA(lt_data2)
     FROM afko AS a INNER JOIN zgtppt3100 AS b
       ON a~aufnr = b~aufnr
       INNER JOIN aufk AS d
       ON a~aufnr = d~aufnr
       INNER JOIN mara AS e
       ON b~matnr = e~matnr
       WHERE d~werks EQ @p_werks "조회조건-플랜트
         AND a~dispo IN @s_dispo "조회조건-MRP관리자
         AND a~aufnr IN @s_aufnr "조회조건-생산오더번호
         AND a~plnbez IN @s_matnr "조회조건-품목코드
         AND b~lgort IN @s_lgort "조회조건-저장위치
         AND b~matnr IN @s_matnr2 "조회조건-자재코드
         AND b~bwart IN @s_bwart "조회조건-이동유형
         AND b~ersda IN @s_ersda "조회조건-오류 발생일자
         AND b~budat IN @s_budat "조회조건-전기일자
         AND b~crdat IN @s_crdat "조회조건-삭제일자
*         AND b~process NE 'D'
         AND (lt_wtab)
*         AND b~enmng > 0
         AND b~dispo IN @s_dispo2.

  CLEAR : ls_aufnr, lt_aufnr.
  LOOP AT lt_data2 INTO DATA(ls_data2).
    ls_aufnr-aufnr = ls_data2-b-aufnr.
    ls_aufnr-werks = ls_data2-b-werks.
    APPEND ls_aufnr TO lt_aufnr.
  ENDLOOP.

  SORT lt_aufnr BY aufnr werks.
  DELETE ADJACENT DUPLICATES FROM lt_aufnr COMPARING ALL FIELDS.

  IF lt_aufnr[] IS NOT INITIAL.

    SELECT aufnr, pdcaproccode INTO TABLE @DATA(lt_gong)
      FROM zgtcvordsyval
      FOR ALL ENTRIES IN @lt_aufnr
      WHERE aufnr EQ @lt_aufnr-aufnr
        AND werks EQ @lt_aufnr-werks
        AND pdcaproccode IN @s_gong.

  ENDIF.

  LOOP AT lt_data2 INTO ls_data2.

    lv_tabix = sy-tabix.

    READ TABLE lt_gong INTO DATA(ls_gong)
                       WITH KEY aufnr = ls_data2-b-aufnr.
    IF sy-subrc = 0.

      MOVE-CORRESPONDING ls_data2-b TO gs_disp.
* 상태
      IF p_del EQ 'X'.
        gs_disp-icon = icon_led_red.
      ELSE.
        gs_disp-icon = icon_led_green.
      ENDIF.
* Message
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

      gs_disp-pmatnr = ls_data2-pmatnr.
      gs_disp-matkl = ls_data2-matkl.
* 오류 유형
      gs_disp-gubun = TEXT-007.
* 플랜트 내역
      SELECT SINGLE name1 INTO gs_disp-name1 FROM t001w
                          WHERE werks EQ gs_disp-werks.
* MRP관리자 내역
      SELECT SINGLE dsnam INTO gs_disp-dsnam FROM t024d
                          WHERE werks EQ gs_disp-werks
                            AND dispo EQ gs_disp-dispo.
** 삭제 사유 코드 및 내역
*      CLEAR : gs_disp-del_reason, gs_disp-reason_text.
* 오류 일자, 오류 시간, 오류 생성자
      gs_disp-ersda = ls_data2-b-crdat.
      gs_disp-erzet  = ls_data2-b-crtim.
      gs_disp-ernam = ls_data2-b-crnam.
* 오류 생성자 명
      CLEAR : gs_zpa0539.
      READ TABLE gt_zpa0539 INTO gs_zpa0539
                            WITH KEY pernr = gs_disp-ernam.
      IF gs_zpa0539 IS NOT INITIAL.
        gs_disp-ename = gs_zpa0539-lnmhg && gs_zpa0539-fnmhg.
      ENDIF.
* 최종변경일자, 변경자
      gs_disp-laeda   = ls_data2-b-chdat.
      gs_disp-aenam = ls_data2-b-chnam.
* 최종 변경자 명
      CLEAR : gs_zpa0539.
      READ TABLE gt_zpa0539 INTO gs_zpa0539
                            WITH KEY pernr = gs_disp-aenam.
      IF gs_zpa0539 IS NOT INITIAL.
        gs_disp-cname = gs_zpa0539-lnmhg && gs_zpa0539-fnmhg.
      ENDIF.
* 자재 내역
      gs_disp-maktx = zgtpp_cl_common=>get_maktx(
                             iv_matnr = gs_disp-matnr ).
* 자재 그룹 내역
      SELECT SINGLE wgbez60 INTO gs_disp-wgbez60
                            FROM t023t
                            WHERE spras EQ sy-langu
                              AND matkl EQ gs_disp-matkl.
* 투입 오류 수량과 투입 수량 동일하게 반영
      gs_disp-erfmg   = ls_data2-b-enmng.
      gs_disp-erfmg_e = ls_data2-b-erfmg.
* 품목명
      gs_disp-maktx2 = zgtpp_cl_common=>get_maktx(
                             iv_matnr = gs_disp-pmatnr ).
* 확정번호, 확정카운터
      CLEAR : gs_disp-rueck, gs_disp-rmzhl.
* 삭제일자, 삭제시간, 삭제자
      CLEAR : gs_disp-crdat, gs_disp-crtim, gs_disp-crnam.
* 삭제 사유 내역
      CLEAR gs_zgtppt1010.
      READ TABLE gt_zgtppt1010 INTO gs_zgtppt1010
                               WITH KEY fld_02 = gs_disp-del_reason.
      IF gs_zgtppt1010 IS NOT INITIAL.
        gs_disp-reason_text = gs_zgtppt1010-fld_03.
      ENDIF.
* 특정 필드 앞의 0 제거
      PERFORM convert_field USING gs_disp-weblnr '-'. "백로그 문서 번호
      PERFORM convert_field USING gs_disp-matnr '-'.  "자재코드
      PERFORM convert_field USING gs_disp-aufnr '-'.   "생산오더번호
      PERFORM convert_field USING gs_disp-pmatnr '-'."품목코드
* 투입 완료 수량, 투입 오류 수량 색깔 적용
      PERFORM set_cell_attribute.

      APPEND gs_disp TO gt_disp.

    ELSE.

      DELETE lt_data2 INDEX lv_tabix.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_attribute
*&---------------------------------------------------------------------*
FORM set_cell_attribute .
* 셀 컬러부여
  DATA : lt_coltab TYPE lvc_t_scol.
  DATA : ls_coltab TYPE lvc_s_scol.

  REFRESH lt_coltab.

  CLEAR ls_coltab.
  ls_coltab-fname = 'GUBUN'.
  ls_coltab-color-col = '5'.
  ls_coltab-color-int = '1'.
  ls_coltab-nokeycol  = ' '.
  INSERT ls_coltab INTO TABLE lt_coltab.

  CLEAR ls_coltab.
  ls_coltab-fname = 'ERFMG'.
  ls_coltab-color-col = '3'.
  ls_coltab-color-int = '1'.
  ls_coltab-nokeycol  = ' '.
  INSERT ls_coltab INTO TABLE lt_coltab.

  CLEAR ls_coltab.
  ls_coltab-fname = 'ERFMG_E'.
  ls_coltab-color-col = '3'.
  ls_coltab-color-int = '1'.
  ls_coltab-nokeycol  = ' '.
  INSERT ls_coltab INTO TABLE lt_coltab.

  gs_disp-cellcol = lt_coltab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form authority_checking_proc
*&---------------------------------------------------------------------*
FORM authority_checking_proc .
*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
  ID 'WERKS'  FIELD p_werks.

  IF sy-subrc <> 0.
    MESSAGE e006 WITH TEXT-008 p_werks TEXT-009.
  ELSE.
*& MRP 관리자에 대한 권한체크
    IF s_dispo-low IS NOT INITIAL.
      AUTHORITY-CHECK OBJECT 'ZPP_DISPO'
      ID 'WERKS'  FIELD p_werks
      ID 'DISPO'  FIELD s_dispo-low.

      IF sy-subrc <> 0.
        MESSAGE e006 WITH TEXT-010 s_dispo-low TEXT-009.
      ENDIF.
    ELSE.
*& MRP 관리자에 대한 권한체크
      IF s_dispo2-low IS NOT INITIAL.
        AUTHORITY-CHECK OBJECT 'ZPP_DISPO'
        ID 'WERKS'  FIELD p_werks
        ID 'DISPO'  FIELD s_dispo2-low.

        IF sy-subrc <> 0.
          MESSAGE e006 WITH TEXT-011 s_dispo2-low TEXT-009.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
