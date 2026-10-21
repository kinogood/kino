*&---------------------------------------------------------------------*
*& Include          ZGTPPI3090F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_screen_attribute
*&---------------------------------------------------------------------*
FORM set_screen_attribute .

  LOOP AT SCREEN.

    IF screen-name = 'P_WERKS' OR
      screen-name = 'S_IFDAT-LOW'.
      screen-required = 2.
    ENDIF.

    IF p_r2 = 'X'. "로그 조회

      IF screen-name = 'S_IFDAT-LOW'.
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

    IF p_werks IS INITIAL.

      gv_error = 'X'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-m01.

    ENDIF.

  ELSE. "로그 조회

    IF p_werks IS INITIAL OR s_ifdat[] IS INITIAL.

      gv_error = 'X'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-m01.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data .
*- 처리모드 선택 : 전송
  IF p_r1 = 'X'.
    PERFORM get_data_for_process.
*- 처리모드 선택 : 로그 조회
  ELSE.
    PERFORM get_data_for_log.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_data
*&---------------------------------------------------------------------*
FORM send_data .
* 배치 모드일때는 조회된 모든 데이터 전송
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

  CLEAR : gs_jejo_c, gt_jejo_c, gs_jejo_i, gt_jejo_i,
               gs_jejo_c2, gt_jejo_c2, gs_jejo_i2, gt_jejo_i2.

  LOOP AT gt_row_table.

    IF p_r1 = 'X'. "처리 모드 : 전송

      CLEAR: gs_header.
      READ TABLE gt_header INTO gs_header
                                               INDEX gt_row_table-index.
      IF sy-subrc = 0.
* 구매 제조지시
        LOOP AT gt_6210 INTO gs_6210
                                    WHERE jobls EQ gs_header-jobls.

          CLEAR gs_jejo_c.
          MOVE-CORRESPONDING gs_6210 TO gs_jejo_c.
* 수신 시스템
          gs_jejo_c-zsystem_id = gs_header-zsystem_id.
* 시스템 내역
          gs_jejo_c-zsystem_id_desc = gs_header-zsystem_id_desc.
* 플랜트
          gs_jejo_c-werks = p_werks.
* 처리모드
          gs_jejo_c-i_mode = gs_header-zmode.
* 제조지시내역
          CLEAR gs_2121.
          READ TABLE gt_2121 INTO gs_2121
                                         WITH KEY zsystem_id = gs_jejo_c-zsystem_id
                                                     zwerks = gs_jejo_c-werks
                                                     zjob_no = gs_jejo_c-job_no.
          IF gs_2121 IS NOT INITIAL.
            gs_jejo_c-zjob_name = gs_2121-zjob_name.
          ENDIF.
* 내역
          gs_jejo_c-txz01 = zgtpp_cl_common=>get_maktx(
                             iv_matnr = gs_jejo_c-matnr ).
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              input  = gs_jejo_c-matnr
            IMPORTING
              output = gs_jejo_c-matnr.
* 시리얼 정보
          gs_jejo_c-serial_no = gs_6210-serial_info.

          APPEND gs_jejo_c TO gt_jejo_c.

        ENDLOOP.

        SORT gt_jejo_c BY jobls.
* 구매 제조지시 구성품
        LOOP AT gt_6211 INTO gs_6211
                                    WHERE jobls EQ gs_header-jobls.

          CLEAR gs_jejo_i.
          MOVE-CORRESPONDING gs_6211 TO gs_jejo_i.
* 수신 시스템
          gs_jejo_i-zsystem_id = gs_header-zsystem_id.
* 시스템 내역
          gs_jejo_i-zsystem_id_desc = gs_header-zsystem_id_desc.
* 플랜트
          gs_jejo_i-werks = p_werks.
* 처리모드
          gs_jejo_i-i_mode = gs_header-zmode.
* 제조지시내역
          CLEAR gs_2121.
          READ TABLE gt_2121 INTO gs_2121
                                         WITH KEY zsystem_id = gs_jejo_i-zsystem_id
                                                     zwerks = gs_jejo_i-werks
                                                     zjob_no = gs_jejo_i-job_no.
          IF gs_2121 IS NOT INITIAL.
            gs_jejo_i-zjob_name = gs_2121-zjob_name.
          ENDIF.
* 내역
          gs_jejo_i-maktx = zgtpp_cl_common=>get_maktx(
                             iv_matnr = gs_jejo_i-matnr ).
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              input  = gs_jejo_i-matnr
            IMPORTING
              output = gs_jejo_i-matnr.

          APPEND gs_jejo_i TO gt_jejo_i.

        ENDLOOP.

        SORT gt_jejo_i BY jobls mes_cmp.

      ENDIF.

    ELSE. "처리 모드 : 로그 조회

      CLEAR: gs_header2.
      READ TABLE gt_header2 INTO gs_header2
                                               INDEX gt_row_table-index.
      IF sy-subrc = 0.
* 구매 제조지시
        LOOP AT gt_zgtppt3220 INTO gs_zgtppt3220
                                              WHERE zifkey EQ gs_header2-zifkey
                                                   AND jobls EQ gs_header2-jobls.

          CLEAR gs_jejo_c2.
          MOVE-CORRESPONDING gs_zgtppt3220 TO gs_jejo_c2.
* 수신 시스템 내역
          gs_jejo_c2-zsystem_id_desc = zgtpp_cl_common=>get_domain_text(
                                        iv_domname  = 'ZGTDTARGET'" 도메인이름
                                        iv_domvalue = CONV #( gs_jejo_c2-zsystem_id ) ).
* 제조지시내역
          CLEAR gs_2121.
          READ TABLE gt_2121 INTO gs_2121
                                         WITH KEY zsystem_id = gs_zgtppt3220-zsystem_id
                                                     zwerks = gs_zgtppt3220-werks
                                                     zjob_no = gs_zgtppt3220-job_no.
          IF gs_2121 IS NOT INITIAL.
            gs_jejo_c2-zjob_name = gs_2121-zjob_name.
          ENDIF.
* 내역
          gs_jejo_c2-txz01 = zgtpp_cl_common=>get_maktx(
                             iv_matnr = gs_jejo_c2-matnr ).

          APPEND gs_jejo_c2 TO gt_jejo_c2.

        ENDLOOP.

        SORT gt_jejo_c2 BY zifkey jobls.
* 구매 제조지시 구성품
        LOOP AT gt_zgtppt3230 INTO gs_zgtppt3230
                                                WHERE zifkey EQ gs_header2-zifkey
                                                     AND jobls EQ gs_header2-jobls.

          CLEAR gs_jejo_i2.
          MOVE-CORRESPONDING gs_zgtppt3230 TO gs_jejo_i2.
* 수신 시스템 내역
          gs_jejo_i2-zsystem_id_desc = zgtpp_cl_common=>get_domain_text(
                                        iv_domname  = 'ZGTDTARGET'" 도메인이름
                                        iv_domvalue = CONV #( gs_jejo_i2-zsystem_id ) ).
* 제조지시내역
          CLEAR gs_2121.
          READ TABLE gt_2121 INTO gs_2121
                                         WITH KEY zsystem_id = gs_zgtppt3230-zsystem_id
                                                     zwerks = p_werks
                                                     zjob_no = gs_zgtppt3230-job_no.
          IF gs_2121 IS NOT INITIAL.
            gs_jejo_i2-zjob_name = gs_2121-zjob_name.
          ENDIF.
* 내역
          gs_jejo_i2-maktx = zgtpp_cl_common=>get_maktx(
                             iv_matnr = gs_jejo_i2-matnr ).

          APPEND gs_jejo_i2 TO gt_jejo_i2.

        ENDLOOP.

        SORT gt_jejo_i2 BY zifkey jobls mes_cmp.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_detail_data_double_click
*&---------------------------------------------------------------------*
FORM get_detail_data_double_click USING pv_row pv_column.

  CHECK pv_row IS NOT INITIAL.

  CLEAR : gs_jejo_c, gt_jejo_c, gs_jejo_i, gt_jejo_i,
             gs_jejo_c2, gt_jejo_c2, gs_jejo_i2, gt_jejo_i2.

  IF p_r1 = 'X'. "처리 모드 : 전송

    CLEAR: gs_header.
    READ TABLE gt_header INTO gs_header
                                             INDEX pv_row.
    IF sy-subrc = 0.
* 구매 제조지시
      LOOP AT gt_6210 INTO gs_6210
                                  WHERE jobls EQ gs_header-jobls.

        CLEAR gs_jejo_c.
        MOVE-CORRESPONDING gs_6210 TO gs_jejo_c.
* 수신 시스템
        gs_jejo_c-zsystem_id = gs_header-zsystem_id.
* 시스템 내역
        gs_jejo_c-zsystem_id_desc = gs_header-zsystem_id_desc.
* 플랜트
        gs_jejo_c-werks = p_werks.
* 처리모드
        gs_jejo_c-i_mode = gs_header-zmode.
* 제조지시내역
        CLEAR gs_2121.
        READ TABLE gt_2121 INTO gs_2121
                                       WITH KEY zsystem_id = gs_jejo_c-zsystem_id
                                                   zwerks = gs_jejo_c-werks
                                                   zjob_no = gs_jejo_c-job_no.
        IF gs_2121 IS NOT INITIAL.
          gs_jejo_c-zjob_name = gs_2121-zjob_name.
        ENDIF.
* 내역
        gs_jejo_c-txz01 = zgtpp_cl_common=>get_maktx(
                           iv_matnr = gs_jejo_c-matnr ).
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
          EXPORTING
            input  = gs_jejo_c-matnr
          IMPORTING
            output = gs_jejo_c-matnr.
* 시리얼 정보
        gs_jejo_c-serial_no = gs_6210-serial_info.

        APPEND gs_jejo_c TO gt_jejo_c.

      ENDLOOP.

      SORT gt_jejo_c BY jobls.
* 구매 제조지시 구성품
      LOOP AT gt_6211 INTO gs_6211
                                  WHERE jobls EQ gs_header-jobls.

        CLEAR gs_jejo_i.
        MOVE-CORRESPONDING gs_6211 TO gs_jejo_i.
* 수신 시스템
        gs_jejo_i-zsystem_id = gs_header-zsystem_id.
* 시스템 내역
        gs_jejo_i-zsystem_id_desc = gs_header-zsystem_id_desc.
* 플랜트
        gs_jejo_i-werks = p_werks.
* 처리모드
        gs_jejo_i-i_mode = gs_header-zmode.
* 제조지시내역
        CLEAR gs_2121.
        READ TABLE gt_2121 INTO gs_2121
                                       WITH KEY zsystem_id = gs_jejo_i-zsystem_id
                                                   zwerks = gs_jejo_i-werks
                                                   zjob_no = gs_jejo_i-job_no.
        IF gs_2121 IS NOT INITIAL.
          gs_jejo_i-zjob_name = gs_2121-zjob_name.
        ENDIF.
* 내역
        gs_jejo_i-maktx = zgtpp_cl_common=>get_maktx(
                           iv_matnr = gs_jejo_i-matnr ).
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
          EXPORTING
            input  = gs_jejo_i-matnr
          IMPORTING
            output = gs_jejo_i-matnr.
        APPEND gs_jejo_i TO gt_jejo_i.

      ENDLOOP.

      SORT gt_jejo_i BY jobls mes_cmp.

    ENDIF.

  ELSE. "처리 모드 : 로그 조회

    CLEAR: gs_header2.
    READ TABLE gt_header2 INTO gs_header2
                                             INDEX pv_row.
    IF sy-subrc = 0.
* 구매 제조지시
      LOOP AT gt_zgtppt3220 INTO gs_zgtppt3220
                                            WHERE zifkey EQ gs_header2-zifkey
                                                 AND jobls EQ gs_header2-jobls.

        CLEAR gs_jejo_c2.
        MOVE-CORRESPONDING gs_zgtppt3220 TO gs_jejo_c2.
* 수신 시스템 내역
        gs_jejo_c2-zsystem_id_desc = zgtpp_cl_common=>get_domain_text(
                                      iv_domname  = 'ZGTDTARGET'" 도메인이름
                                      iv_domvalue = CONV #( gs_jejo_c2-zsystem_id ) ).
* 제조지시내역
        CLEAR gs_2121.
        READ TABLE gt_2121 INTO gs_2121
                                       WITH KEY zsystem_id = gs_zgtppt3220-zsystem_id
                                                   zwerks = gs_zgtppt3220-werks
                                                   zjob_no = gs_zgtppt3220-job_no.
        IF gs_2121 IS NOT INITIAL.
          gs_jejo_c2-zjob_name = gs_2121-zjob_name.
        ENDIF.
* 내역
        gs_jejo_c2-txz01 = zgtpp_cl_common=>get_maktx(
                           iv_matnr = gs_jejo_c2-matnr ).
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
          EXPORTING
            input  = gs_jejo_c2-matnr
          IMPORTING
            output = gs_jejo_c2-matnr.

        APPEND gs_jejo_c2 TO gt_jejo_c2.

      ENDLOOP.

      SORT gt_jejo_c2 BY zifkey jobls.
* 구매 제조지시 구성품
      LOOP AT gt_zgtppt3230 INTO gs_zgtppt3230
                                              WHERE zifkey EQ gs_header2-zifkey
                                                   AND jobls EQ gs_header2-jobls.

        CLEAR gs_jejo_i2.
        MOVE-CORRESPONDING gs_zgtppt3230 TO gs_jejo_i2.
* 수신 시스템 내역
        gs_jejo_i2-zsystem_id_desc = zgtpp_cl_common=>get_domain_text(
                                      iv_domname  = 'ZGTDTARGET'" 도메인이름
                                      iv_domvalue = CONV #( gs_jejo_i2-zsystem_id ) ).
* 제조지시내역
        CLEAR gs_2121.
        READ TABLE gt_2121 INTO gs_2121
                                       WITH KEY zsystem_id = gs_zgtppt3230-zsystem_id
                                                   zwerks = p_werks
                                                   zjob_no = gs_zgtppt3230-job_no.
        IF gs_2121 IS NOT INITIAL.
          gs_jejo_i2-zjob_name = gs_2121-zjob_name.
        ENDIF.
* 내역
        gs_jejo_i2-maktx = zgtpp_cl_common=>get_maktx(
                           iv_matnr = gs_jejo_i2-matnr ).
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
          EXPORTING
            input  = gs_jejo_i2-matnr
          IMPORTING
            output = gs_jejo_i2-matnr.

        APPEND gs_jejo_i2 TO gt_jejo_i2.

      ENDLOOP.

      SORT gt_jejo_i2 BY zifkey jobls mes_cmp.

    ENDIF.

  ENDIF.

  gs_scroll-row = 'X'.
  gs_scroll-col = 'X'.

  CALL METHOD gc_alv_grid1->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = gs_scroll.     "화면 라인 Refresh

  IF gc_custom_container2 IS INITIAL.

    CREATE OBJECT gc_custom_container2
      EXPORTING
        container_name = gc_container_name2.

    CREATE OBJECT gc_alv_grid2
      EXPORTING
        i_parent      = gc_custom_container2
        i_appl_events = 'X'.

    PERFORM set_grid_layo1.

    PERFORM set_grid_fcat2.

*___필요한 function만 삽입
    PERFORM exclude_tb_functions CHANGING gt_exclude.

**   Edit Event 및  Event Handler 등록
*    PERFORM event_handler_register1.

*   화면 display
    PERFORM set_table_for_first_display2.

  ELSE.

    CALL METHOD gc_alv_grid2->refresh_table_display
      EXPORTING
        i_soft_refresh = 'X'
        is_stable      = gs_scroll.     "화면 라인 Refresh

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form all_send_data
*&---------------------------------------------------------------------*
FORM all_send_data .

  DATA : lv_error,
             lv_tabix LIKE sy-tabix.
  DATA : lv_timestamp TYPE timestampl.
*- 맵핑을 위한 변수키 생성
  GET TIME STAMP FIELD lv_timestamp.

  CLEAR : gt_send_header, gt_send_jejo_c, gt_send_jejo_i.
* 상단 화면 : 생산 제조지시
  IF p_r1 = 'X'. "처리 모드 : 전송
    MOVE-CORRESPONDING gt_header[] TO gt_send_header[].
  ELSEIF p_r2 = 'X'. "처리 모드 : 로그 조회
    MOVE-CORRESPONDING gt_header2[] TO gt_send_header[].
  ENDIF.

  LOOP AT gt_send_header INTO gs_send_header.

    lv_tabix = sy-tabix.
* 오더 Lock 설정
    CALL FUNCTION 'ENQUEUE_EZGT_ZGTPPI3090'
      EXPORTING
        jobls          = gs_send_header-jobls
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    IF sy-subrc <> 0.
      WAIT UP TO '1' SECONDS.
      lv_error = 'X'.
      EXIT.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input  = gs_send_header-oper_matnr
        IMPORTING
          output = gs_send_header-oper_matnr.
      gs_send_header-zifkey = lv_timestamp.
*      IF gs_send_header-zmode = 'P' OR
*        gs_send_header-zmode = 'K'.
*        gs_send_header-beskz = 'F'.
*      ELSE.
*        gs_send_header-beskz = 'E'.
*      ENDIF.
* 하단 화면 - 구매 제조지시
      LOOP AT gt_6210 INTO gs_6210
                                         WHERE jobls EQ gs_send_header-jobls.

        CLEAR gs_send_jejo_c.
        MOVE-CORRESPONDING gs_6210 TO gs_send_jejo_c.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
          EXPORTING
            input  = gs_send_jejo_c-matnr
          IMPORTING
            output = gs_send_jejo_c-matnr.
* 내역
        gs_send_jejo_c-txz01 = zgtpp_cl_common=>get_maktx(
                           iv_matnr = gs_send_jejo_c-matnr ).
        gs_send_jejo_c-zifkey = lv_timestamp.
        gs_send_jejo_c-i_mode = gs_send_header-zmode.
        gs_send_jejo_c-serial_no = gs_6210-serial_info.
        APPEND gs_send_jejo_c TO gt_send_jejo_c.

      ENDLOOP.

    ENDIF.
    MODIFY gt_send_header FROM gs_send_header INDEX lv_tabix.

  ENDLOOP.

  IF lv_error IS INITIAL.
* 하단 화면 - 구매 제조지시 구성품
    MOVE-CORRESPONDING gt_6211[] TO gt_send_jejo_i[].
    LOOP AT gt_send_jejo_i INTO gs_send_jejo_i.

      lv_tabix = sy-tabix.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input  = gs_send_jejo_i-matnr
        IMPORTING
          output = gs_send_jejo_i-matnr.
      gs_send_jejo_i-zifkey = lv_timestamp.
      MODIFY gt_send_jejo_i FROM gs_send_jejo_i INDEX lv_tabix.

    ENDLOOP.

    CHECK gt_send_header[] IS NOT INITIAL.
* 데이터 전송 후 로그 히스토리 업데이트
    PERFORM call_rfc TABLES gt_send_header
                                              gt_send_jejo_c
                                              gt_send_jejo_i.
* 오더 Lock 해제
    LOOP AT gt_send_header INTO gs_send_header.

      CALL FUNCTION 'DEQUEUE_EZGT_ZGTPPI3090'
        EXPORTING
          jobls = gs_send_header-jobls.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form choice_send_data
*&---------------------------------------------------------------------*
FORM choice_send_data .

  CLEAR  : gt_row_no, gt_row_no[].
*  CALL METHOD g_grid->get_selected_rows
  CALL METHOD go_grid_0100->get_selected_rows
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
      titel     = TEXT-t04
      textline1 = TEXT-t05
      textline2 = ''
    IMPORTING
      answer    = gv_answer.
  CHECK gv_answer = 'J'.
* RFC 전송을 위해 전송 대상 데이터 취합
  PERFORM append_data_to_send.

  CHECK gt_send_header[] IS NOT INITIAL.
* 데이터 전송 후 로그 히스토리 업데이트
  PERFORM call_rfc TABLES gt_send_header
                                            gt_send_jejo_c
                                            gt_send_jejo_i.
* 전송 처리 후 상태값 업데이트
  PERFORM update_alv_list.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_data_to_send
*&---------------------------------------------------------------------*
FORM append_data_to_send .

  DATA : lv_timestamp TYPE timestampl.
*- 맵핑을 위한 변수키 생성
  GET TIME STAMP FIELD lv_timestamp.

  CLEAR : gt_send_header, gt_send_jejo_c, gt_send_jejo_i.
  LOOP AT gt_row_no.

    IF p_r1 = 'X'. "처리 모드 : 전송

      CLEAR : gs_header, gs_send_header.
* 상단 화면 : 생산 제조지시
      READ TABLE gt_header INTO gs_header INDEX gt_row_no-row_id.
      IF gs_header IS NOT INITIAL.

        MOVE-CORRESPONDING gs_header TO gs_send_header.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
          EXPORTING
            input  = gs_send_header-oper_matnr
          IMPORTING
            output = gs_send_header-oper_matnr.
        gs_send_header-zifkey = lv_timestamp.
*        IF gs_send_header-zmode = 'P' OR
*          gs_send_header-zmode = 'K'.
*          gs_send_header-beskz = 'F'.
*        ELSE.
*          gs_send_header-beskz = 'E'.
*        ENDIF.
        APPEND gs_send_header TO gt_send_header.
* 하단 화면 - 구매 제조지시
        LOOP AT gt_6210 INTO gs_6210
                        WHERE jobls EQ gs_header-jobls.
          CLEAR gs_send_jejo_c.
          MOVE-CORRESPONDING gs_6210 TO gs_send_jejo_c.
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              input  = gs_send_jejo_c-matnr
            IMPORTING
              output = gs_send_jejo_c-matnr.
* 내역
          gs_send_jejo_c-txz01 = zgtpp_cl_common=>get_maktx(
                             iv_matnr = gs_send_jejo_c-matnr ).
          gs_send_jejo_c-zifkey = lv_timestamp.
          gs_send_jejo_c-i_mode = gs_header-zmode.
          gs_send_jejo_c-serial_no = gs_6210-serial_info.
          APPEND gs_send_jejo_c TO gt_send_jejo_c.
        ENDLOOP.
* 하단 화면 - 구매 제조지시 구성품
        LOOP AT gt_6211 INTO gs_6211
                        WHERE jobls EQ gs_header-jobls.
          CLEAR gs_send_jejo_i.
          MOVE-CORRESPONDING gs_6211 TO gs_send_jejo_i.
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              input  = gs_send_jejo_i-matnr
            IMPORTING
              output = gs_send_jejo_i-matnr.
          gs_send_jejo_i-zifkey = lv_timestamp.
          APPEND gs_send_jejo_i TO gt_send_jejo_i.
        ENDLOOP.

      ENDIF.

    ELSEIF p_r2 = 'X'. "처리 모드 : 로그 조회
* 상단 화면 : 생산 제조지시
      CLEAR : gs_header2, gs_send_header.
      READ TABLE gt_header2 INTO gs_header2 INDEX gt_row_no-row_id.
      IF gs_header2 IS NOT INITIAL.

        MOVE-CORRESPONDING gs_header2 TO gs_send_header.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
          EXPORTING
            input  = gs_send_header-oper_matnr
          IMPORTING
            output = gs_send_header-oper_matnr.
        gs_send_header-zifkey = lv_timestamp.
*        IF gs_send_header-zmode = 'P' OR
*          gs_send_header-zmode = 'K'.
*          gs_send_header-beskz = 'F'.
*        ELSE.
*          gs_send_header-beskz = 'E'.
*        ENDIF.
        APPEND gs_send_header TO gt_send_header.
* 하단 화면 - 구매 제조지시
        LOOP AT gt_jejo_c2 INTO gs_jejo_c2
                                               WHERE jobls EQ gs_header2-jobls.
          CLEAR gs_send_jejo_c.
          MOVE-CORRESPONDING gs_jejo_c2 TO gs_send_jejo_c.
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              input  = gs_send_jejo_c-matnr
            IMPORTING
              output = gs_send_jejo_c-matnr.
          gs_send_jejo_c-txz01 = gs_jejo_c-txz01.
          gs_send_jejo_c-zifkey = lv_timestamp.
          gs_send_jejo_c-i_mode = gs_header2-zmode.
          APPEND gs_send_jejo_c TO gt_send_jejo_c.
        ENDLOOP.
* 하단 화면 - 구매 제조지시 구성품
        LOOP AT gt_jejo_i2 INTO gs_jejo_i2
                                               WHERE jobls EQ gs_header2-jobls.
          CLEAR gs_send_jejo_i.
          MOVE-CORRESPONDING gs_jejo_i2 TO gs_send_jejo_i.
          CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
            EXPORTING
              input  = gs_send_jejo_i-matnr
            IMPORTING
              output = gs_send_jejo_i-matnr.
          gs_send_jejo_i-zifkey = lv_timestamp.
          APPEND gs_send_jejo_i TO gt_send_jejo_i.
        ENDLOOP.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_rfc
*&---------------------------------------------------------------------*
FORM call_rfc TABLES pt_send_header STRUCTURE zgtppt3210 "생산 제조지시
                                     pt_send_jejo_c STRUCTURE zgtppt3220 "구매 제조지시
                                     pt_send_jejo_i STRUCTURE zgtppt3230. "구매 제조지시 구성품

  DATA : lt_mes_header LIKE gt_mes_header,
         ls_mes_header LIKE zgtppsif0030, "생산 제조지시
         lt_mes_jejo_c LIKE gt_mes_jejo_c,    "구매 제조지시
         lt_mes_jejo_i LIKE gt_mes_jejo_i.     "구매 제조지시 구성품
  DATA : lv_dest TYPE zifdest-dest.
  DATA : lv_zsystem_id   TYPE zgtppt1020-zsystem_id.

*  MOVE-CORRESPONDING pt_send_header[] TO lt_mes_header[].
  LOOP AT pt_send_header.

    CLEAR ls_mes_header.
    MOVE-CORRESPONDING pt_send_header TO ls_mes_header.
    ls_mes_header-i_mode = pt_send_header-zmode.
    APPEND ls_mes_header TO lt_mes_header.

  ENDLOOP. "생산 제조지시
  MOVE-CORRESPONDING pt_send_jejo_c[] TO lt_mes_jejo_c[].    "구매 제조지시
  MOVE-CORRESPONDING pt_send_jejo_i[] TO lt_mes_jejo_i[].     "구매 제조지시 구성품

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

    lv_zsystem_id = 'KBDM'.
*- RFC 전송
    CALL FUNCTION 'ZGTPP_IF_O_EXT_CONV_RESULT' DESTINATION lv_dest
      EXPORTING
        i_system_id   = lv_zsystem_id
      IMPORTING
        zo_result     = gv_result
        zo_message    = gv_message
      TABLES
        ot_zgtppt3160 = lt_mes_header.
*        ot_zgtmmt6210 = lt_mes_jejo_c
*        ot_zgtmmt6211 = lt_mes_jejo_i.
*- History_Table에 저장
    IF gv_result = '00' OR gv_result = '0'.
      IF gv_message IS INITIAL.
        gv_message    = TEXT-m03.
      ENDIF.
    ELSE.
      IF gv_message IS INITIAL.
        gv_message = TEXT-m04.
      ENDIF.
    ENDIF.

  ENDIF.

  PERFORM save_history_table TABLES pt_send_header "생산 제조지시
                                                              pt_send_jejo_c "구매 제조지시
                                                              pt_send_jejo_i. "구매 제조지시 구성품

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_history_table
*&---------------------------------------------------------------------*
FORM save_history_table TABLES pt_send_header STRUCTURE zgtppt3210 "생산 제조지시
                                               pt_send_jejo_c STRUCTURE zgtppt3220 "구매 제조지시
                                               pt_send_jejo_i STRUCTURE zgtppt3230. "구매 제조지시 구성품
*- 구매 제조지시
  LOOP AT pt_send_jejo_c ASSIGNING FIELD-SYMBOL(<ls_send_jejo_c>).
*    <ls_send_jejo_c>-zifkey = lv_timestamp.
    <ls_send_jejo_c>-zsystem_id = 'KBDM'.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = <ls_send_jejo_c>-matnr
      IMPORTING
        output = <ls_send_jejo_c>-matnr.
  ENDLOOP.
  IF pt_send_jejo_c[] IS NOT INITIAL.
    MODIFY zgtppt3220 FROM TABLE pt_send_jejo_c[].
  ENDIF.
*- 구매 제조지시 구성품
  LOOP AT pt_send_jejo_i ASSIGNING FIELD-SYMBOL(<ls_send_jejo_i>).
*    <ls_send_jejo_i>-zifkey = lv_timestamp.
    <ls_send_jejo_i>-zsystem_id = 'KBDM'.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = <ls_send_jejo_i>-matnr
      IMPORTING
        output = <ls_send_jejo_i>-matnr.
  ENDLOOP.
  IF pt_send_jejo_i[] IS NOT INITIAL.
    MODIFY zgtppt3230 FROM TABLE pt_send_jejo_i[].
  ENDIF.
*- 헤더
  LOOP AT pt_send_header ASSIGNING FIELD-SYMBOL(<ls_send_header>).

*    <ls_send_header>-zifkey = lv_timestamp.
    <ls_send_header>-zsystem_id = 'KBDM'.
    <ls_send_header>-zstat = gv_result.
    <ls_send_header>-zmessage = gv_message.
    <ls_send_header>-ifdat = sy-datum.
    <ls_send_header>-iftim = sy-uzeit.
    <ls_send_header>-ifnam = sy-uname.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = <ls_send_header>-oper_matnr
      IMPORTING
        output = <ls_send_header>-oper_matnr.

  ENDLOOP.

  MODIFY zgtppt3210 FROM TABLE pt_send_header[].
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_alv_list
*&---------------------------------------------------------------------*
FORM update_alv_list .

  DATA : lv_lines_c TYPE c LENGTH 10.

  LOOP AT gt_row_no.

    IF p_r1 = 'X'.

      CLEAR : gs_header.
      READ TABLE gt_header INTO gs_header INDEX gt_row_no-row_id.
      IF gs_header IS NOT INITIAL.
        IF gv_result = '00' OR gv_result = '0'.
          gs_header-icon = icon_led_green.
          gs_header-zmessage = TEXT-m05.
        ELSE.
          gs_header-icon = icon_led_red.
          gs_header-zmessage = gv_message.
        ENDIF.
        MODIFY gt_header FROM gs_header INDEX gt_row_no-row_id.
      ENDIF.

    ELSE.

      CLEAR : gs_header2.
      READ TABLE gt_header2 INTO gs_header2 INDEX gt_row_no-row_id.
      IF gs_header2 IS NOT INITIAL.
        IF gv_result = '00' OR gv_result = '0'.
          gs_header2-icon = icon_led_green.
          gs_header2-zmessage = TEXT-m05.
        ELSE.
          gs_header2-icon = icon_led_red.
          gs_header2-zmessage = gv_message.
        ENDIF.
        MODIFY gt_header2 FROM gs_header2 INDEX gt_row_no-row_id.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF line_exists( gt_send_header[ zstat = '00' ] ) OR
    line_exists( gt_send_header[ zstat = '0' ] ). " 성공시

    DATA(lv_index) = lines( gt_send_header ) .
    lv_lines_c = lv_index.
    CONDENSE lv_lines_c.
    MESSAGE s000 WITH lv_lines_c TEXT-m06.

  ELSE.
    MESSAGE s003 WITH TEXT-m07 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_for_process
*&---------------------------------------------------------------------*
FORM get_data_for_process .

  DATA : BEGIN OF ls_jobls,
           jobls LIKE zgtmmt6210-jobls,
         END OF ls_jobls.
  DATA : lt_jobls LIKE TABLE OF ls_jobls.
  DATA : BEGIN OF ls_zjob_name,
           zsystem_id LIKE zgtedt2121-zsystem_id,
           zwerks     LIKE zgtedt2121-zwerks,
           zjob_no    LIKE zgtedt2121-zjob_no,
         END OF ls_zjob_name.
  DATA : lt_zjob_name LIKE TABLE OF ls_zjob_name.

  CLEAR : gs_6210, gt_6210, gs_6211, gt_6211, gs_2121, gt_2121.
* 외주 전환 결과 - 생산 제조지시 정보 발췌
  SELECT b~*, a~werks INTO TABLE @DATA(lt_3160)
      FROM zgtppt3150 AS a INNER JOIN zgtppt3160 AS b
          ON   a~job_no        EQ b~job_no
          AND a~line_no        EQ b~line_no
          AND a~serial_info EQ b~serial_info
      WHERE a~werks EQ @p_werks
           AND b~job_no IN @s_jobno
           AND b~line_no IN @s_lineno
           AND b~serial_info IN @s_serial
           AND b~oper_code IN @s_oper
           AND b~jobls NE @space
           AND b~zmode IN ( 'P', 'K', 'C' )
           AND b~jobls IN @s_jobls
           AND b~chdat IN @s_chdat.

  CLEAR : ls_jobls, lt_jobls, ls_zjob_name, lt_zjob_name.
  LOOP AT lt_3160 INTO DATA(ls_3160).
    ls_jobls-jobls = ls_3160-b-jobls.
    APPEND ls_jobls TO lt_jobls.
    ls_zjob_name-zsystem_id = 'KBDM'.
    ls_zjob_name-zwerks = ls_3160-werks.
    ls_zjob_name-zjob_no = ls_3160-b-job_no.
    APPEND ls_zjob_name TO lt_zjob_name.
  ENDLOOP.
  SORT lt_jobls BY jobls.
  DELETE ADJACENT DUPLICATES FROM lt_jobls COMPARING ALL FIELDS.
  SORT lt_zjob_name BY zwerks zjob_no.
  DELETE ADJACENT DUPLICATES FROM lt_zjob_name COMPARING ALL FIELDS.

  IF lt_jobls[] IS NOT INITIAL.
* 외주 전환 결과 - 구매 제조지시 정보 발췌
    SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_6210
        FROM zgtmmt6210
        FOR ALL ENTRIES IN @lt_jobls
        WHERE jobls EQ @lt_jobls-jobls.
* 외주 전환 결과 - 구매 제조지시 구성품 정보 발췌
    SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_6211
        FROM zgtmmt6211
        FOR ALL ENTRIES IN @lt_jobls
        WHERE jobls EQ @lt_jobls-jobls.
  ENDIF.
* 기타 정보 발췌 - 제조지시 내역 발췌
  IF lt_zjob_name[] IS NOT INITIAL.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_2121
        FROM zgtedt2121
        FOR ALL ENTRIES IN @lt_zjob_name
        WHERE zsystem_id EQ @lt_zjob_name-zsystem_id
             AND zwerks EQ @lt_zjob_name-zwerks
             AND zjob_no EQ @lt_zjob_name-zjob_no.

  ENDIF.

  CLEAR : gs_header, gt_header, gs_jejo_c, gt_jejo_c, gs_jejo_i, gt_jejo_i.
  LOOP AT lt_3160 INTO ls_3160.

    CLEAR gs_header.
    MOVE-CORRESPONDING ls_3160-b TO gs_header.
* 전송상태
    gs_header-icon = icon_led_inactive.
* 수신시스템
    IF p_werks EQ '1306'.
      gs_header-zsystem_id = 'KBDM'.
    ENDIF.
* 시스템 내역
    gs_header-zsystem_id_desc = zgtpp_cl_common=>get_domain_text(
                                  iv_domname  = 'ZGTDTARGET'" 도메인이름
                                  iv_domvalue = CONV #( gs_header-zsystem_id ) ).
* 플랜트
    gs_header-werks = ls_3160-werks.
* 제조지시내역
    CLEAR gs_2121.
    READ TABLE gt_2121 INTO gs_2121
                                   WITH KEY zsystem_id = gs_header-zsystem_id
                                               zwerks = gs_header-werks
                                               zjob_no = gs_header-job_no.
    IF gs_2121 IS NOT INITIAL.
      gs_header-zjob_name = gs_2121-zjob_name.
    ENDIF.
* 생산품목내역
    gs_header-maktx = zgtpp_cl_common=>get_maktx(
                       iv_matnr = gs_header-oper_matnr ).

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = gs_header-oper_matnr
      IMPORTING
        output = gs_header-oper_matnr.

    APPEND gs_header TO gt_header.

  ENDLOOP.

  SORT gt_header BY jobls ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_for_log
*&---------------------------------------------------------------------*
FORM get_data_for_log .

  DATA : BEGIN OF ls_zjob_name,
           zsystem_id LIKE zgtedt2121-zsystem_id,
           zwerks     LIKE zgtedt2121-zwerks,
           zjob_no    LIKE zgtedt2121-zjob_no,
         END OF ls_zjob_name.
  DATA : lt_zjob_name LIKE TABLE OF ls_zjob_name.
  RANGES : lr_zstat FOR zgtppt3010-zstat.

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

  CLEAR : gs_zgtppt3210, gt_zgtppt3210, gs_zgtppt3220, gt_zgtppt3220,
             gs_zgtppt3230, gt_zgtppt3230, gs_header2 , gt_header2,
             gs_zifkey, gt_zifkey, gt_jejo_c2, gt_jejo_i2, ls_zjob_name, lt_zjob_name,
             gs_2121, gt_2121[].
*- 상단 화면 : 생산 제조지시
  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @gt_zgtppt3210
      FROM zgtppt3210
      WHERE werks EQ @p_werks "플랜트
          AND job_no IN @s_jobno "제조지시번호
          AND line_no IN @s_lineno "라인번호
          AND serial_info IN @s_serial "시리얼정보
          AND oper_code IN @s_oper "공정 코드
          AND ifdat  IN @s_ifdat "전송 일자
          AND zstat IN @lr_zstat "전송 상태
          AND jobls IN @s_jobls. "제조지시 요청번호

  LOOP AT gt_zgtppt3210 INTO gs_zgtppt3210.
* 기타 정보 발췌 - 제조지시 내역 발췌
    ls_zjob_name-zsystem_id = gs_zgtppt3210-zsystem_id.
    ls_zjob_name-zwerks = gs_zgtppt3210-werks.
    ls_zjob_name-zjob_no = gs_zgtppt3210-job_no.
    APPEND ls_zjob_name TO lt_zjob_name.
* 하위 데이터를 가져오기 위한 조건값 취합
    gs_zifkey-zifkey = gs_zgtppt3210-zifkey.
    gs_zifkey-jobls  = gs_zgtppt3210-jobls.
    APPEND gs_zifkey TO gt_zifkey.

  ENDLOOP.

  SORT gt_zifkey BY zifkey jobls.
  DELETE ADJACENT DUPLICATES FROM gt_zifkey COMPARING ALL FIELDS.
  SORT lt_zjob_name BY zsystem_id zwerks zjob_no.
  DELETE ADJACENT DUPLICATES FROM lt_zjob_name COMPARING ALL FIELDS.

  IF lt_zjob_name[] IS NOT INITIAL.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_2121
        FROM zgtedt2121
        FOR ALL ENTRIES IN @lt_zjob_name
        WHERE zsystem_id EQ @lt_zjob_name-zsystem_id
             AND zwerks EQ @lt_zjob_name-zwerks
             AND zjob_no EQ @lt_zjob_name-zjob_no.

  ENDIF.

  LOOP AT gt_zgtppt3210 INTO gs_zgtppt3210.

    CLEAR gs_header2 .
    MOVE-CORRESPONDING gs_zgtppt3210 TO gs_header2.
* 전송 상태
    IF gs_zgtppt3210-zstat = '00' OR gs_zgtppt3210-zstat = '0'.
      gs_header2-icon = icon_led_green.
    ELSE.
      gs_header2-icon = icon_led_red.
    ENDIF.
* 수신 시스템 내역
    gs_header2-zsystem_id_desc = zgtpp_cl_common=>get_domain_text(
                                  iv_domname  = 'ZGTDTARGET'" 도메인이름
                                  iv_domvalue = CONV #( gs_header2-zsystem_id ) ).
* 제조지시내역
    CLEAR gs_2121.
    READ TABLE gt_2121 INTO gs_2121
                                   WITH KEY zsystem_id = gs_header2-zsystem_id
                                               zwerks = gs_header2-werks
                                               zjob_no = gs_header2-job_no.
    IF gs_2121 IS NOT INITIAL.
      gs_header2-zjob_name = gs_2121-zjob_name.
    ENDIF.
* 생산품목내역
    gs_header-maktx = zgtpp_cl_common=>get_maktx(
                       iv_matnr = gs_header-oper_matnr ).

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = gs_header2-oper_matnr
      IMPORTING
        output = gs_header2-oper_matnr.

    APPEND gs_header2 TO gt_header2.

  ENDLOOP.

*  SORT gt_header2
*      BY zifkey job_no jobls line_no serial_info prcss_seq prcss_sub_seq.
  SORT gt_header2 BY jobls ASCENDING.

  CHECK gt_zifkey[] IS NOT INITIAL.
*- 하단 화면 : 구매 제조지시
  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @gt_zgtppt3220
      FROM zgtppt3220
      FOR ALL ENTRIES IN @gt_zifkey
      WHERE zifkey EQ @gt_zifkey-zifkey
           AND jobls  EQ @gt_zifkey-jobls.
*- 하단 화면 : 구매 제조지시 구성품
  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @gt_zgtppt3230
      FROM zgtppt3230
      FOR ALL ENTRIES IN @gt_zifkey
      WHERE zifkey EQ @gt_zifkey-zifkey
           AND jobls  EQ @gt_zifkey-jobls.

ENDFORM.
