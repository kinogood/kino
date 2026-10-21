*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data .

  DATA : lv_matnr(18).

  IF p_r1 = 'X'. "전송

* 선택한 송신 대상 시스템에 따라 조회 조건 플랜트
*    및 MRP 관리자, 자재 유형 필터링

* 소재 MOM은 타 사업부에서 보낸 사내이체 입고분 데이터 추출
* 지중MES는 1302 플랜트에서 입고할 데이터 추출
    IF p_werks EQ '1305'.   "소재MOM

      SELECT c~ebeln,   "구매오더
             c~ebelp, "구매오더 번호
             a~werks, "입고 플랜트
             a~matnr, "자재번호
             a~txz01, "자재 내역
             a~menge, "구매오더 수량
             a~meins, "구매오더 단위
             b~reswk, "공급 플랜트
             c~mblnr, "자재문서
             c~mjahr, "자재문서 년도
             c~menge AS wamng,    "입고수량
             c~meins AS erfme,    "입고 단위
             c~charg, "배치번호
             c~budat, "전기일
*         D~TAGNR, "꼬리표 번호
             a~lgort, "저장위치
             c~bwart  "이동유형
      FROM ekpo AS a
                     INNER JOIN ekko AS b
                            ON a~ebeln = b~ebeln
                     INNER JOIN matdoc AS c
                            ON a~ebeln = c~ebeln
                           AND a~ebelp = c~ebelp
                     INNER JOIN marc AS f
                            ON a~matnr = f~matnr
                           AND a~werks = f~werks
      WHERE a~ebeln IN @s_ebeln
         AND a~matnr IN @s_matnr
         AND a~werks =  @p_werks
         AND a~pstyp =  '7'
         AND c~cpudt IN @s_cpudt
         AND c~budat IN @s_budat
         AND c~werks  EQ @p_werks
         AND c~matnr  IN @s_matnr
         AND c~bwart  IN ( '351', '352' )
        ORDER BY a~ebeln, a~ebelp
       INTO CORRESPONDING FIELDS OF TABLE @gt_data.

      DELETE ADJACENT DUPLICATES FROM gt_data COMPARING ebeln ebelp mblnr mjahr.


    ELSE.
      SELECT d~ebeln,   "구매오더
             d~ebelp, "구매오더 번호
             a~werks, "입고 플랜트
             a~matnr, "자재번호
             a~txz01, "자재 내역
             a~menge, "구매오더 수량
             a~meins, "구매오더 단위
             b~reswk, "공급 플랜트
             d~mblnr, "자재문서
             d~mjahr, "자재문서 년도
*         C~ZEILE, "자재문서 항목
             d~enmng AS wamng,    "입고수량
             d~meins AS erfme,    "입고 단위
             d~charg, "배치번호
             c~budat, "전기일
             d~tagnr, "꼬리표 번호
             d~lgort, "저장위치
             c~bwart  "이동유형
      FROM zppt0019 AS d  INNER JOIN ekpo AS a
                            ON a~ebeln = d~ebeln
                            AND a~ebelp = d~ebelp
                     INNER JOIN ekko AS b
                            ON a~ebeln = b~ebeln
                     INNER JOIN matdoc AS c
                            ON d~mblnr = c~mblnr
                           AND d~mjahr = c~mjahr
                     INNER JOIN marc AS f
                            ON a~matnr = f~matnr
                           AND a~werks = f~werks
      WHERE a~ebeln IN @s_ebeln
         AND a~matnr IN @s_matnr
         AND a~werks =  @p_werks
         AND a~pstyp =  '7'
         AND c~cpudt IN @s_cpudt
         AND c~budat IN @s_budat
         AND c~werks  EQ @p_werks
         AND c~matnr  IN @s_matnr
         AND d~plumi = '2'
        ORDER BY d~ebeln, d~ebelp, d~tagnr
       INTO CORRESPONDING FIELDS OF TABLE @gt_data.

      DELETE ADJACENT DUPLICATES FROM gt_data COMPARING ebeln ebelp tagnr.


    ENDIF.

    DELETE gt_data WHERE lgort IS INITIAL.
  ELSE. "로그 조회(재처리)

    " 자재문서 정보 발췌
    SELECT  *
    FROM zgtppt3090
    WHERE  werks = @p_werks
       AND ebeln IN @s_ebeln
       AND matnr IN @s_matnr
       AND budat IN @s_budat
       AND ifdat IN @s_ifdat
      ORDER BY ebeln, ebelp, tagnr
     INTO CORRESPONDING FIELDS OF TABLE @gt_data.

    IF p_r5 = 'X'. " 전체

    ELSEIF p_r6 = 'X'. " 성공건만
      DELETE gt_data WHERE ( zstat NE '00'
                        AND zstat NE '0' ).
    ELSEIF p_r7 = 'X'.  " 싪패건만
      DELETE gt_data WHERE ( zstat EQ '00'
                        OR zstat EQ '0' ).
    ENDIF .


  ENDIF.


  LOOP AT gt_data INTO gs_data.

    "자재코드
    CLEAR : lv_matnr.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gs_data-matnr
      IMPORTING
        output = gs_data-matnr.

    lv_matnr = gs_data-matnr+22(18).
    CLEAR : gs_data-matnr.
    gs_data-matnr = lv_matnr.

    MODIFY  gt_data FROM gs_data.

  ENDLOOP.

  "자재내역 발췌
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_makt
    FROM makt
    FOR ALL ENTRIES IN gt_data
   WHERE matnr = gt_data-matnr
     AND spras = sy-langu.
  SORT gt_makt BY matnr .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_display_condition
*&---------------------------------------------------------------------*
FORM check_display_condition .

  CLEAR gv_error.

  IF p_r1 = 'X'. "전송

    IF p_werks IS INITIAL .

      gv_error = 'X'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-m01.

    ENDIF.

  ELSE. "로그 조회(재처리)

    IF p_werks IS INITIAL .

      gv_error = 'X'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH TEXT-m01.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_screen_attribute
*&---------------------------------------------------------------------*
FORM set_screen_attribute .

  LOOP AT SCREEN.

    IF screen-name = 'P_WERKS'.
      screen-required = 2.
    ENDIF.

    IF screen-group1 = 'DS1'.

      IF p_r1 = 'X'. "전송
        screen-active       = 1.
      ELSE.
        screen-active       = 0.
      ENDIF.

    ELSEIF screen-group1 = 'DS2'.

      IF p_r2 = 'X'. "로그 조회(재처리)
        screen-active       = 1.
      ELSE.
        screen-active       = 0.
      ENDIF.

    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.

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
*& Form send_data
*&---------------------------------------------------------------------*
FORM send_data .
* 배치 모드일때는 조회된 모든 생산 버젼 전송
  IF p_r8 EQ 'X'.

    PERFORM all_send_data.

  ELSE.

    PERFORM choice_send_data.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_rfc
*&---------------------------------------------------------------------*
FORM call_rfc TABLES pt_sendtab STRUCTURE zgtppt3090.

  DATA : lt_ot_tab LIKE gt_ot_itab.
  DATA : lv_dest TYPE zifdest-dest.
  DATA : lv_zsystem_id   TYPE zgtppt3060-zsystem_id.

  MOVE-CORRESPONDING pt_sendtab[] TO lt_ot_tab[].
*- MATNR, VORNR, PLNAL PLNFL 앞에 0 제거
  PERFORM data_conversion TABLES lt_ot_tab.

  CLEAR: gv_result, gv_message, lv_dest.
*- Destination 가져오기
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'P1'
    IMPORTING
      dest_name             = lv_dest
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.

  CASE p_werks.
    WHEN '1302'.
      lv_zsystem_id = 'KPCM'.
    WHEN '1305'.
      lv_zsystem_id = 'KSCM'.
  ENDCASE.

*- RFC 전송
  CALL FUNCTION 'ZGTPP_IF_O_STO_INFO' DESTINATION lv_dest
    EXPORTING
      i_system_id = lv_zsystem_id
    IMPORTING
      zo_result   = gv_result
      zo_message  = gv_message
    TABLES
      ot_itab     = lt_ot_tab.
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

  PERFORM save_history_table TABLES pt_sendtab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_conversion
*&---------------------------------------------------------------------*
FORM data_conversion TABLES pt_ot_tab STRUCTURE zgtppsif0015.

  LOOP AT pt_ot_tab ASSIGNING FIELD-SYMBOL(<ls_itab>).
    "자재번호
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = <ls_itab>-matnr
      IMPORTING
        output = <ls_itab>-matnr.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_history_table
*&---------------------------------------------------------------------*
FORM save_history_table TABLES  pt_sendtab STRUCTURE zgtppt3090.

  DATA : lv_seqno_n TYPE n LENGTH 10.
  DATA : lv_timestamp TYPE timestampl.
*- 맵핑을 위한 변수키 생성
  lv_seqno_n = 1.

  GET TIME STAMP FIELD lv_timestamp.
  SORT pt_sendtab BY matnr .
  LOOP AT pt_sendtab ASSIGNING FIELD-SYMBOL(<ls_sdentab>).

    CASE     <ls_sdentab>-werks.
      WHEN '1302'.
        <ls_sdentab>-zsystem_id = 'KPCM'.
      WHEN '1305'.
        <ls_sdentab>-zsystem_id = 'KSCM'.
    ENDCASE.

    <ls_sdentab>-zifkey = lv_timestamp.
    <ls_sdentab>-zstat = gv_result.
    <ls_sdentab>-zmessage = gv_message.
    <ls_sdentab>-ifdat = sy-datum.
    <ls_sdentab>-iftim = sy-uzeit.
    <ls_sdentab>-ifnam = sy-uname.

    ADD 1 TO lv_seqno_n.

  ENDLOOP.

  MODIFY zgtppt3090 FROM TABLE pt_sendtab[].
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

      CLEAR : gs_disp.
      READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.
      IF gs_disp IS NOT INITIAL.
        IF gv_result = '00' OR gv_result = '0'.
          gs_disp-icon = icon_led_green.
          gs_disp-message = TEXT-m03.
        ELSE.
          gs_disp-icon = icon_led_red.
          gs_disp-message = gv_message.
        ENDIF.
        MODIFY gt_disp FROM gs_disp INDEX gt_row_no-row_id.
      ENDIF.

    ELSE.

      CLEAR : gs_disp2.
      READ TABLE gt_disp2 INTO gs_disp2 INDEX gt_row_no-row_id.
      IF gs_disp2 IS NOT INITIAL.
        IF gv_result = '00' OR gv_result = '0'.
          gs_disp2-icon = icon_led_green.
          gs_disp2-message = TEXT-m03.
        ELSE.
          gs_disp2-icon = icon_led_red.
          gs_disp2-message = gv_message.
        ENDIF.
        MODIFY gt_disp2 FROM gs_disp2 INDEX gt_row_no-row_id.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF line_exists( gt_send[ zstat = '00' ] ) OR
    line_exists( gt_send[ zstat = '0' ] ). " 성공시

    DATA(lv_index) = lines( gt_send ).
    lv_lines_c = lv_index.
    CONDENSE lv_lines_c.
    MESSAGE s000 WITH lv_lines_c '건의 자재문서 정보가 전송되었습니다.'.

  ELSE.
    MESSAGE s003 WITH '전송 데이터가 없습니다.'
    DISPLAY LIKE 'E'. "전송 데이터가 없습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form filter_werks_dispo
*&---------------------------------------------------------------------*
FORM filter_werks_dispo .

  CLEAR : gr_werks, gr_werks[], gt_zgtppt1010, gt_zgtppt1010[].
*  gt_zgtppt1010 = zgtpp_cl_common=>get_code_value(
*                          iv_module_kind = 'PP'             " 모듈 코드
*                          iv_codegrp     =  '0010' ).       " 코드 그룹

*  CASE abap_true.
*    WHEN p_r3. "지중 MES
*      DELETE gt_zgtppt1010 WHERE fld_01 NE 'KPCM'.
*    WHEN p_r4. "부스닥트 MES
*      DELETE gt_zgtppt1010 WHERE fld_01 NE 'KBDM'.
*  ENDCASE.

*  SELECT werks AS low FROM t001w
*   INTO CORRESPONDING FIELDS OF TABLE gr_werks
*  WHERE werks IN s_werks.

  IF gr_werks[] IS INITIAL.

    MESSAGE s003 DISPLAY LIKE 'E' WITH '전송대상 플랜트가 아닙니다.'.
    LEAVE TO LIST-PROCESSING.

  ELSE.

    LOOP AT gr_werks ASSIGNING FIELD-SYMBOL(<ls_werks>).
      READ TABLE gt_zgtppt1010 TRANSPORTING NO FIELDS
                            WITH KEY fld_03 = <ls_werks>-low.
      IF sy-subrc EQ 0.
        <ls_werks>-sign = 'I'.
        <ls_werks>-option = 'EQ'.
      ELSE.
        DELETE gr_werks.
      ENDIF.
    ENDLOOP.

    IF gr_werks[] IS  INITIAL.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '전송대상 플랜트가 아닙니다.'.
      LEAVE TO LIST-PROCESSING.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form choice_send_data
*&---------------------------------------------------------------------*
FORM choice_send_data .
* CALL FUNCTION - POPUP_TO_CONFIRM_STEP
  CLEAR: gv_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      titel     = '자재문서 정보 전송'
      textline1 = '자재문서 정보를 전송 하시겠습니까?'
      textline2 = ''
    IMPORTING
      answer    = gv_answer.
  CHECK gv_answer = 'J'.
* 선택 레코드 중 한 건이라도 전기일자가 현재월에 해당되지 않는 건이 있으면 오류메시지 처리
  CLEAR  : gt_row_no, gt_row_no[].
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

  CLEAR gt_send.
  LOOP AT gt_row_no.

    IF p_r1 = 'X'. "전송

*      IF p_r8 = 'X'. "배치잡 전송일 경우
*
*        CLEAR : gs_data, gt_send[], gs_send.
*        LOOP AT gt_data INTO gs_data.
*            MOVE-CORRESPONDING gs_data TO gs_send.
*            APPEND gs_send TO gt_send.
*        ENDLOOP.
*
*      ELSE.

      CLEAR : gs_disp, gs_send.
      READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.
      IF gs_disp IS NOT INITIAL.

        IF gs_disp-icon <> icon_led_green.
          MOVE-CORRESPONDING gs_disp TO gs_send.
          APPEND gs_send TO gt_send.
        ENDIF.

      ENDIF.

*      ENDIF.

    ELSEIF p_r2 = 'X'. "로그 조회(재처리)

      CLEAR : gs_disp2, gs_send.
      READ TABLE gt_disp2 INTO gs_disp2 INDEX gt_row_no-row_id.
      IF gs_disp2 IS NOT INITIAL.

        MOVE-CORRESPONDING gs_disp2 TO gs_send.
        APPEND gs_send TO gt_send.

      ENDIF.

    ENDIF.

  ENDLOOP.

  CHECK gt_send[] IS NOT INITIAL.
* 데이터 전송 후 로그 히스토리 업데이트( ZGTPPT1090 )
  PERFORM call_rfc TABLES gt_send.
* 전송 처리 후 상태값 업데이트
  PERFORM update_alv_list.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form all_send_data
*&---------------------------------------------------------------------*
FORM all_send_data .

  CLEAR : gs_send, gt_send[].
  IF p_r1 = 'X'. "전송
    MOVE-CORRESPONDING gt_data[] TO gt_send[].
  ELSEIF p_r2 = 'X'. "로그 조회(재처리)
    MOVE-CORRESPONDING gt_disp2[] TO gt_send[].
  ENDIF.

  CHECK gt_send[] IS NOT INITIAL.
* 데이터 전송 후 로그 히스토리 업데이트( ZGTPPT1040 )
  PERFORM call_rfc TABLES gt_send.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_alv_variant
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_LAYO
*&---------------------------------------------------------------------*
FORM select_alv_variant   CHANGING pv_layo TYPE disvariant-variant.

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
*& Form GET_MATDOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_matdoc .

  RANGES : lr_batch FOR sy-datum,
           lr_batch2 FOR sy-uzeit.

  DATA : lv_uzeit   LIKE sy-uzeit,
         lv_predate LIKE sy-datum,
         lv_pretime LIKE sy-uzeit.


  CLEAR: lv_uzeit, lv_predate, lv_pretime, gt_disp.

* 배치잡 5분 단위 전송시 누락 방지를 위해
* 11분치의 데이터를 추출
  IF sy-batch = 'X'.

    CLEAR : s_ifdat[]." s_iftim[].

    lv_uzeit = sy-uzeit.

    IF lv_uzeit < '001100'.

      CALL FUNCTION 'IGN_TIMESTAMP_PLUSMINUS'
        EXPORTING
          start_date      = sy-datum
          start_time      = lv_uzeit
          forward         = ' '
          backward        = 'X'
          days            = '0'
          hours           = '0'
          minutes         = '6'
          seconds         = '0'
        IMPORTING
          result_date     = lv_predate
          result_time     = lv_pretime
        EXCEPTIONS
          parameter_error = 1
          OTHERS          = 2.

      s_ifdat-sign   = 'I'.
      s_ifdat-option = 'EQ'.
      s_ifdat-low    = lv_predate.
      APPEND s_ifdat.

*      s_iftim-sign   = 'I'.
*      s_iftim-option = 'BT'.
*      s_iftim-low    = lv_pretime.
*      s_iftim-high   = '235959'.
*      APPEND s_iftim.

      s_ifdat-sign   = 'I'.
      s_ifdat-option = 'EQ'.
      s_ifdat-low    = sy-datum.
      APPEND s_ifdat.

*      s_iftim-sign   = 'I'.
*      s_iftim-option = 'BT'.
*      s_iftim-low    = '000000'.
*      s_iftim-high   = lv_uzeit.
*      APPEND s_iftim.

    ELSE.
      s_ifdat-sign   = 'I'.
      s_ifdat-option = 'EQ'.
      s_ifdat-low    = sy-datum.
      APPEND s_ifdat.

*      s_iftim-sign   = 'I'.
*      s_iftim-option = 'BT'.
*      s_iftim-low    = lv_uzeit - 360.
*      s_iftim-high   = lv_uzeit.
*      APPEND s_iftim.
    ENDIF.
  ENDIF.

* 소재 MOM은 타 사업부에서 보낸 사내이체 입고분 데이터 추출
* 지중MES는 1302 플랜트에서 입고할 데이터 추출
  IF p_werks EQ '1305'.   "소재MOM

    SELECT c~ebeln,   "구매오더
           c~ebelp, "구매오더 번호
           a~werks, "입고 플랜트
           a~matnr, "자재번호
           a~txz01, "자재 내역
           a~menge, "구매오더 수량
           a~meins, "구매오더 단위
           b~reswk, "공급 플랜트
           c~mblnr, "자재문서
           c~mjahr, "자재문서 년도
           c~menge AS wamng,    "입고수량
           c~meins AS erfme,    "입고 단위
           c~charg, "배치번호
           c~budat, "전기일
*         D~TAGNR, "꼬리표 번호
           a~lgort, "저장위치
           c~bwart  "이동유형
    FROM ekpo AS a
                   INNER JOIN ekko AS b
                          ON a~ebeln = b~ebeln
                   INNER JOIN matdoc AS c
                          ON a~ebeln = c~ebeln
                         AND a~ebelp = c~ebelp
                   INNER JOIN marc AS f
                          ON a~matnr = f~matnr
                         AND a~werks = f~werks
    WHERE a~ebeln IN @s_ebeln
       AND a~matnr IN @s_matnr
       AND a~werks =  @p_werks
       AND a~pstyp =  '7'
       AND c~cpudt IN @s_cpudt
       AND c~budat IN @s_budat
       AND c~werks  EQ @p_werks
       AND c~matnr  IN @s_matnr
       AND c~bwart  IN ( '351', '352' )
       AND  not  exists ( select mblnr                              "SRM2601-06378
                                              from zgtppt3090
                                             where mblnr = c~mblnr
                                                and zstat = '00')
      ORDER BY a~ebeln, a~ebelp
     INTO CORRESPONDING FIELDS OF TABLE @gt_data.

    DELETE ADJACENT DUPLICATES FROM gt_data COMPARING ebeln ebelp mblnr mjahr.

   LOOP AT gt_data into gs_data.

      IF gs_data-charg IS INITIAL."꼬리표번호값이 없는 경우
        CONCATENATE gs_data-ebeln gs_data-ebelp
               INTO gs_data-tagnr.
      ELSE.
        gs_data-tagnr  = gs_data-charg. "꼬리표번호
      ENDIF.

      modify gt_data from gs_data.
   ENDLOOP.

  ELSE.
    SELECT d~ebeln,   "구매오더
           d~ebelp, "구매오더 번호
           a~werks, "입고 플랜트
           a~matnr, "자재번호
           a~txz01, "자재 내역
           a~menge, "구매오더 수량
           a~meins, "구매오더 단위
           b~reswk, "공급 플랜트
           d~mblnr, "자재문서
           d~mjahr, "자재문서 년도
*         C~ZEILE, "자재문서 항목
           d~enmng AS wamng,    "입고수량
           d~meins AS erfme,    "입고 단위
           d~charg, "배치번호
           c~budat, "전기일
           d~tagnr, "꼬리표 번호
           d~lgort, "저장위치
           c~bwart  "이동유형
    FROM zppt0019 AS d  INNER JOIN ekpo AS a
                          ON a~ebeln = d~ebeln
                          AND a~ebelp = d~ebelp
                   INNER JOIN ekko AS b
                          ON a~ebeln = b~ebeln
                   INNER JOIN matdoc AS c
                          ON d~mblnr = c~mblnr
                         AND d~mjahr = c~mjahr
                   INNER JOIN marc AS f
                          ON a~matnr = f~matnr
                         AND a~werks = f~werks
    WHERE a~ebeln IN @s_ebeln
       AND a~matnr IN @s_matnr
       AND a~werks =  @p_werks
       AND a~pstyp =  '7'
       AND c~cpudt IN @s_cpudt
       AND c~budat IN @s_budat
       AND c~werks  EQ @p_werks
       AND c~matnr  IN @s_matnr
       AND d~plumi = '2'
       AND  not  exists ( select mblnr                             "SRM2601-06378
                                              from zgtppt3090
                                             where mblnr = c~mblnr
                                                and zstat = '00')
      ORDER BY d~ebeln, d~ebelp, d~tagnr
     INTO CORRESPONDING FIELDS OF TABLE @gt_data.

    DELETE ADJACENT DUPLICATES FROM gt_data COMPARING ebeln ebelp tagnr.


    DELETE gt_data WHERE lgort IS INITIAL.

  ENDIF.

  IF gt_data[] IS NOT INITIAL.
    "MES 전송용 테이블
    gt_ot_itab = CORRESPONDING #( gt_data ).

  ELSE.
    "전송 데이터가 없습니다.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_data .
  DATA : lv_tagnr(17).

  LOOP AT gt_data INTO gs_data.

    IF p_r1 = 'X'. "전송

      gs_disp-icon       = icon_led_inactive. "전송 상태
      gs_disp-message    = ''.            "결과 메시지

      CASE gs_data-werks.

        WHEN '1302'.
          gs_disp-zsystem_id = 'KPCM'.        "수신 시스템
          gs_disp-zsystem_id_desc = '지중 MES'.

        WHEN '1305'.
          gs_disp-zsystem_id = 'KSCM'.        "수신 시스템
          gs_disp-zsystem_id_desc = '소재 MOM'.

      ENDCASE.

      gs_disp-ebeln  = gs_data-ebeln. "구매 문서 번호
      gs_disp-ebelp  = gs_data-ebelp. "구매 문서의 품목 번호
      gs_disp-mblnr  = gs_data-mblnr. "자재 문서 번호
      gs_disp-mjahr  = gs_data-mjahr. "자재 문서 연도
      gs_disp-wamng  = gs_data-wamng. "출고수량
      gs_disp-erfme  = gs_data-erfme. "기본 단위
      gs_disp-charg  = gs_data-charg. "배치 번호
      CLEAR: lv_tagnr.
      IF gs_data-tagnr IS INITIAL."꼬리표번호값이 없는 경우
        CONCATENATE gs_data-ebeln gs_data-ebelp
               INTO lv_tagnr.
        gs_disp-tagnr  = lv_tagnr.
      ELSE.
        gs_disp-tagnr  = gs_data-tagnr. "꼬리표번호
      ENDIF.
      gs_disp-lgort	 = gs_data-lgort. "저장위치
      gs_disp-werks  = gs_data-werks. "플랜트
      gs_disp-matnr  = gs_data-matnr. "자재코드
      gs_disp-txz01  = gs_data-txz01. "내역
      gs_disp-menge  = gs_data-menge. "구매 오더 수량
      gs_disp-meins  = gs_data-meins. "구매 오더 단위
      gs_disp-reswk  = gs_data-reswk. "재고 운송 오더의 경우
      "공급(출고)플랜트
*      gs_disp-zeile  = gs_data-zeile. "자재 문서 항목
      gs_disp-budat  = gs_data-budat. "문서 내 전기일
      gs_disp-bwart	 = gs_data-bwart. "이동 유형(재고 관리)

      "자재코드 내역
      CLEAR gt_makt.
      READ TABLE gt_makt WITH KEY matnr = gs_data-matnr.
      IF sy-subrc = 0.
        gs_disp-maktx = gt_makt-maktx.
      ENDIF.

      "자재코드
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = gs_data-matnr
        IMPORTING
          output = gs_data-matnr.
      gs_disp-matnr   = gs_data-matnr. "자재코드

      APPEND gs_disp TO gt_disp.

      CLEAR gs_disp.

    ELSE.

      MOVE-CORRESPONDING gs_data TO gs_disp2.
      gs_disp2-message    = gs_data-zmessage.            "결과 메시지
      IF gs_data-zstat = '00' OR gs_data-zstat = '0'.
        gs_disp2-icon       = icon_led_green. "전송 성공 상태
      ELSEIF gs_data-zstat = 'E' .
        gs_disp2-icon       = icon_led_red. "전송 실패 상태
      ELSE.
        gs_disp2-icon       = icon_led_inactive. "전송 미처리 상태
      ENDIF.
      "자재코드 내역
      CLEAR gt_makt.
      READ TABLE gt_makt WITH KEY matnr = gs_data-matnr.
      IF sy-subrc = 0.
        gs_disp2-maktx = gt_makt-maktx.
      ENDIF.
      "자재코드
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = gs_data-matnr
        IMPORTING
          output = gs_data-matnr.
      gs_disp2-matnr      = gs_data-matnr. "자재코드

      "시스템 내역
      CASE gs_disp2-werks.
        WHEN '1302'.
          gs_disp2-zsystem_id = 'KPCM'.        "수신 시스템
          gs_disp2-zsystem_id_desc = '지중 MES'.
        WHEN '1305'.
          gs_disp2-zsystem_id = 'KSCM'.        "수신 시스템
          gs_disp2-zsystem_id_desc = '소재 MOM'.

      ENDCASE.

      APPEND gs_disp2 TO gt_disp2.

      CLEAR gs_disp2.

    ENDIF.

  ENDLOOP.

ENDFORM.
