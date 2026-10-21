*&---------------------------------------------------------------------*
*& Include          ZGTPPI1020F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form MODIFY_FIRST_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_first_screen .

  LOOP AT SCREEN.
    IF p_send = abap_true.
      CASE screen-name.
        WHEN 'S_WERKS-LOW' OR 'S_DATE-LOW'.
          screen-required = 1.
          MODIFY SCREEN.
      ENDCASE.

      IF screen-group1 = 'S1'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      CASE screen-name.
        WHEN 'S_TARGET-LOW' OR 'S_WERKS-LOW' OR 'S_IFDATE-LOW'.
          screen-required = 2.
          MODIFY SCREEN.
      ENDCASE.

      IF screen-group1 = 'S2'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_proc .

  IF p_send EQ abap_true.
    PERFORM get_routing.
  ELSE.
    PERFORM get_history_of_send.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ROUTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_routing .

  RANGES : lt_werks FOR mapl-werks.
  RANGES : lt_spgcd FOR marc-dispo.

  DATA(lt_zgtppt1010) = zgtpp_cl_common=>get_code_value(
    iv_module_kind = 'PP'                 " 모듈 코드
    iv_codegrp     = '0010' ).        "코드 그룹
  CASE abap_true.
    WHEN p_pcm.
      DELETE lt_zgtppt1010 WHERE fld_01 NE 'KPCM'.
    WHEN p_mes.
      DELETE lt_zgtppt1010 WHERE fld_01 NE 'KBDM'.
      "소재 MOM SRM2510-04825
    WHEN p_scm.
      DELETE lt_zgtppt1010 WHERE fld_01 NE 'KSCM'.
      "소재 MOM SRM2510-04825
* 가온전선 파라미터 추가
    WHEN p_kgpm. "가온 전력 MES
      DELETE lt_zgtppt1010 WHERE fld_01 NE 'KGPM'.
    WHEN p_kgom. "가온 통신 MES
      DELETE lt_zgtppt1010 WHERE fld_01 NE 'KGOM'.
      "한미소 MOM 260826
    WHEN p_kfcm.
      DELETE lt_zgtppt1010 WHERE fld_01 NE 'KFCM'.
      "한미소 MOM 260826
  ENDCASE.

  lt_spgcd[] = VALUE #( FOR wa_zgtppt1010 IN lt_zgtppt1010 WHERE (
fld_04 IS NOT INITIAL ) ( sign = 'I' option = 'CP' low =
wa_zgtppt1010-fld_04 && '*' ) ).

  SELECT werks AS low FROM t001w
     INTO CORRESPONDING FIELDS OF TABLE lt_werks
    WHERE werks IN s_werks.
  IF   lt_werks[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '전송대상 플랜트가 아닙니다.'.
    LEAVE TO LIST-PROCESSING.
  ELSE.
    LOOP AT lt_werks ASSIGNING FIELD-SYMBOL(<ls_werks>).
      READ TABLE lt_zgtppt1010 TRANSPORTING NO FIELDS WITH KEY fld_03 =
<ls_werks>-low.
      IF sy-subrc EQ 0.
        <ls_werks>-sign = 'I'.
        <ls_werks>-option = 'EQ'.
      ELSE.
        DELETE lt_werks.
      ENDIF.
    ENDLOOP.

    IF lt_werks[] IS  INITIAL.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '전송대상 플랜트가 아닙니다.'.
      LEAVE TO LIST-PROCESSING.
    ENDIF.
  ENDIF.

*- 라우팅 변경 이력 발췌
  SELECT DISTINCT objectid
  INTO CORRESPONDING FIELDS OF TABLE @gt_cdhdr
  FROM cdhdr
 WHERE objectclas = 'PLAN'
   AND ( tcode = 'CA01' OR tcode = 'CA02')
   AND udate IN @s_date.


*- OBJECTID 분리 (라우팅 그룹만 남김)
  LOOP AT gt_cdhdr INTO DATA(ls_cdhdr).
    SHIFT ls_cdhdr-objectid BY 4 PLACES.
    ls_cdhdr-plnnr = ls_cdhdr-objectid.
    MODIFY gt_cdhdr FROM ls_cdhdr.
  ENDLOOP.

*- 라우팅/작업장 발췌
  SELECT
   a~matnr, a~werks, a~plnty, a~plnnr, a~plnal, a~zkriz,
   a~zaehl, b~plnfl, b~plnkn, c~ltxa1, c~bmsch, c~meinh,
   c~lar01, c~vgw01, c~vge01, c~lar02, c~vgw02, c~vge02,
   c~lar03, c~vgw03, c~vge03, c~lar04, c~vgw04, c~vge04,
   c~lar05, c~vgw05, c~vge05, c~lar06, c~vgw06, c~vge06,
   c~usr04, c~use04, c~datuv, c~andat, c~annam, c~arbid,
   c~vornr, f~arbpl, g~mtart, h~dispo, a~loekz,
   c~usr06, "U01(+)
   c~usr07
   FROM mapl AS a
***  25.09.24 Start. Routing 순서 삭제 반영되도록 수정
   INNER JOIN plfl AS l
       ON a~plnty = l~plnty
      AND a~plnnr = l~plnnr
      AND a~plnal = l~plnal
   INNER JOIN plas AS b
       ON l~plnty = b~plnty
      AND l~plnnr = b~plnnr
      AND l~plnal = b~plnal
      AND l~plnfl = b~plnfl
***  25.09.24 End. Routing 순서 삭제 반영되도록 수정
   INNER JOIN plpo AS c
      ON a~plnty = c~plnty
      AND a~plnnr = c~plnnr
      AND b~zaehl = c~zaehl
      AND b~plnkn = c~plnkn
   INNER JOIN plko AS d
       ON a~plnty = d~plnty
      AND a~plnnr = d~plnnr
      AND a~plnal = d~plnal
      AND a~zaehl = d~zaehl
   INNER JOIN @gt_cdhdr AS e
       ON c~plnnr = e~plnnr
   INNER JOIN mara AS g
      ON a~matnr = g~matnr
   INNER JOIN marc AS h
      ON a~matnr = h~matnr
     AND a~werks = h~werks
   LEFT OUTER JOIN crhd AS f
       ON f~objid = c~arbid
      AND f~objty = 'A'
   WHERE a~werks IN @lt_werks[]
    AND  a~matnr IN @s_matnr
    AND  a~plnty = 'N'  "테스크유형(공정)
*// Modified by ZGODEV06 on 2026-05-22 {
*    AND  a~loekz = ' '  "삭제지시자
*// }
    AND  b~loekz = ' '
    AND  c~loekz = ' '
    AND  d~verwe = '1'  "생산
    AND  d~statu = '4' "릴리즈.
*    AND  B~PLNFL = '000000'
***  25.09.24 Start. Routing 순서 삭제 반영되도록 수정
    AND  l~loekz NE 'X'       "삭제되지 않은. 유효한 순서
***  25.09.24 Start. Routing 순서 삭제 반영되도록 수정
   INTO CORRESPONDING FIELDS OF TABLE @gt_itab.


  SELECT
  a~matnr, a~werks, a~plnty, a~plnnr, a~plnal, a~zkriz,
  a~zaehl, b~plnfl, b~plnkn, c~ltxa1, c~bmsch, c~meinh,
  c~lar01, c~vgw01, c~vge01, c~lar02, c~vgw02, c~vge02,
  c~lar03, c~vgw03, c~vge03, c~lar04, c~vgw04, c~vge04,
  c~lar05, c~vgw05, c~vge05, c~lar06, c~vgw06, c~vge06,
  c~usr04, c~use04, c~datuv, c~andat, c~annam, c~arbid,
  c~vornr, f~arbpl, g~mtart, h~dispo, a~loekz,
  c~usr06,"U01(+)
  c~usr07
  FROM mapl AS a
***  25.09.24 Start. Routing 순서 삭제 반영되도록 수정
   INNER JOIN plfl AS l
       ON a~plnty = l~plnty
      AND a~plnnr = l~plnnr
      AND a~plnal = l~plnal
   INNER JOIN plas AS b
       ON l~plnty = b~plnty
      AND l~plnnr = b~plnnr
      AND l~plnal = b~plnal
      AND l~plnfl = b~plnfl
***  25.09.24 End. Routing 순서 삭제 반영되도록 수정
  INNER JOIN plpo AS c
     ON a~plnty = c~plnty
     AND a~plnnr = c~plnnr
     AND b~zaehl = c~zaehl
     AND b~plnkn = c~plnkn
  INNER JOIN plko AS d
      ON a~plnty = d~plnty
     AND a~plnnr = d~plnnr
     AND a~plnal = d~plnal
     AND a~zaehl = d~zaehl
   INNER JOIN mara AS g
      ON a~matnr = g~matnr
   INNER JOIN marc AS h
      ON a~matnr = h~matnr
     AND a~werks = h~werks
  LEFT OUTER JOIN crhd AS f
      ON f~objid = c~arbid
     AND f~objty = 'A'
  WHERE a~werks IN @lt_werks[]
   AND  a~matnr IN @s_matnr
   AND  a~plnty = 'N'  "테스크유형(공정)
*// Modified by ZGODEV06 on 2026-05-22 {
*    AND  a~loekz = ' '  "삭제지시자
*// }
   AND  b~loekz = ' '
   AND  c~loekz = ' '
   AND  d~verwe = '1'  "생산
   AND  d~statu = '4' "릴리즈.
*   AND  B~PLNFL = '000000'
   AND  a~datuv IN @s_date
***  25.09.24 Start. Routing 순서 삭제 반영되도록 수정
    AND  l~loekz NE 'X'       "삭제되지 않은. 유효한 순서
***  25.09.24 Start. Routing 순서 삭제 반영되도록 수정
  APPENDING CORRESPONDING FIELDS OF TABLE @gt_itab.

  SORT gt_itab BY dispo.
  LOOP AT gt_itab INTO DATA(ls_itab2).
    CASE ls_itab2-mtart.
      WHEN 'MCFE' OR 'MCHF' OR 'ZCSH'. " 반제품과 완제품만 비교대상
        IF ls_itab2-dispo NOT IN lt_spgcd.
          DELETE gt_itab.
        ENDIF.
    ENDCASE.
  ENDLOOP.

*// Modified by ZGODEV06 on 2026-05-22 {
  DELETE gt_itab WHERE ( werks NE'6500' AND werks NE '6600' )
                   AND ( loekz NE space ).
*// }

  IF gt_itab IS NOT INITIAL.
    SORT gt_itab BY matnr werks plnty plnnr plnal vornr plnfl.
    DELETE ADJACENT DUPLICATES FROM gt_itab COMPARING matnr werks plnty
plnnr plnal vornr plnfl.

* U01
    "가온전력MES 인 경우 USR06 건조가동시간을 사용하기 위해
    "VGW02에 USR06을 대입
    LOOP AT gt_itab ASSIGNING FIELD-SYMBOL(<fs_s>).
      IF p_kgpm = 'X'.
        IF <fs_s>-arbpl+0(3) = 'DRY'.
          <fs_s>-vgw02 = <fs_s>-usr06 * 10.
        ENDIF.
      ENDIF.

      <fs_s>-usr07 = <fs_s>-usr07 * 10.
    ENDLOOP.
* U01

*- MES 전송용 테이블 생성
    gt_ot_itab = VALUE #( FOR ls_itab IN gt_itab
                        ( CORRESPONDING #( ls_itab ) ) ).
  ELSE.

    MESSAGE s003 WITH TEXT-e03 DISPLAY LIKE 'E'. "전송 데이터가 없습니다.
    LEAVE TO LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_HISTORY_OF_SEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_history_of_send .

  REFRESH gt_send.

  SELECT *
    INTO TABLE @gt_send
    FROM zgtppt1050
    WHERE werks IN @s_werks
      AND matnr IN @s_matnr
      AND ifdat IN @s_ifdate.

  CASE abap_true.
    WHEN p_all. " 모든조건 추출
    WHEN p_suc." 성공건만 추출
      DELETE gt_send WHERE zstat EQ space.
    WHEN p_fail. " 실패건만 추출
      DELETE gt_send WHERE ( zstat EQ '0'
                                      OR zstat EQ '00' ).

  ENDCASE.

  IF gt_send[] IS INITIAL.
    MESSAGE s003 WITH TEXT-e04 DISPLAY LIKE 'E'. " 조회된 데이터가 없습니다.
    LEAVE TO LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESSING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM processing .

  DATA : lv_lines_c TYPE c LENGTH 10.

  IF p_send EQ abap_true.
    IF p_batch EQ abap_true. " 배치수행, 화면 출력없이 전송


      " 작업장(ARBPL)이 누락되어 있는 데이터 제외후 전송
*      MOVE-CORRESPONDING GT_OT_ITAB TO GT_SEND.
      gt_send = VALUE #( FOR wa_ot_tab IN gt_ot_itab WHERE ( arbpl IS
NOT INITIAL ) ( CORRESPONDING zgtppt1050( wa_ot_tab ) ) ).

      PERFORM call_rfc TABLES gt_send.

      IF line_exists( gt_send[ zstat = '00' ] ) OR line_exists(
gt_send[ zstat = '0' ] ). " 성공시
        DATA(lv_index) = lines( gt_send ).
        lv_lines_c = lv_index.
        CONDENSE lv_lines_c.
        MESSAGE s000 WITH lv_lines_c '건의 라우팅이 전송되었습니다.'.
      ELSE.
        MESSAGE s003 WITH '전송 데이터가 없습니다.' DISPLAY LIKE 'E'.
        "전송 데이터가 없습니다.
      ENDIF.

    ELSE. " 화면 구성 및 화면 출력
      PERFORM set_disp_data.
      CLEAR lv_index.
      lv_index =  lines( gt_ot_itab ).
      lv_lines_c = lv_index.
      CONDENSE lv_lines_c.

      MESSAGE s002 WITH lv_lines_c.

      CALL SCREEN 0100.
    ENDIF.

  ELSE. " 화면데이터 구성후 화면출력
    PERFORM set_disp_data2.
    CALL SCREEN 0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_RFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_rfc TABLES pt_sendtab STRUCTURE zgtppt1050.

  DATA : lt_ot_tab LIKE gt_ot_itab.
  MOVE-CORRESPONDING pt_sendtab[] TO lt_ot_tab[].

*- MATNR, VORNR, PLNAL PLNFL 앞에 0 제거
  PERFORM data_conversion TABLES lt_ot_tab.

  DATA : lv_dest TYPE zifdest-dest.
  DATA : lv_zsystem_id   TYPE zgtppt1050-zsystem_id.
  CLEAR: gv_result, gv_message, lv_dest.


*- Destination 가져오기
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'P1'    "Destination 점검
    IMPORTING
      dest_name             = lv_dest
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.

  CASE abap_true.
    WHEN p_pcm.
      lv_zsystem_id = 'KPCM'.
    WHEN p_mes.
      "소재 MOM SRM2510-04825
    WHEN p_scm.
      lv_zsystem_id = 'KSCM'.
      "소재 MOM SRM2510-04825
* 가온전선 파라미터 추가
    WHEN p_kgpm. "가온 전력 MES
      lv_zsystem_id =  'KGPM'.
    WHEN p_kgom. "가온 통신 MES
      lv_zsystem_id =  'KGOM'.
     "한미소 MOM 260826
    WHEN p_kfcm.
      lv_zsystem_id = 'KFCM'.
      "한미소 MOM 260826
  ENDCASE.

*- RFC 전송
  CALL FUNCTION 'ZGTPP_IF_O_ROUT_INFO' DESTINATION lv_dest
    EXPORTING
      i_system_id = lv_zsystem_id
    IMPORTING
      zo_result   = gv_result
      zo_message  = gv_message
    TABLES
      it_data     = lt_ot_tab.

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
*& Form DATA_CONVERSION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM data_conversion TABLES pt_ot_tab STRUCTURE zgtppsif0001.

  LOOP AT pt_ot_tab ASSIGNING FIELD-SYMBOL(<ls_itab>).

    "자재번호
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = <ls_itab>-matnr
      IMPORTING
        output = <ls_itab>-matnr.
    "조회단위
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input  = <ls_itab>-meinh
      IMPORTING
        output = <ls_itab>-meinh.
    "작업/액티비티 번호
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <ls_itab>-vornr
      IMPORTING
        output = <ls_itab>-vornr.
    "그룹카운터
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <ls_itab>-plnal
      IMPORTING
        output = <ls_itab>-plnal.
    "순서
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <ls_itab>-plnfl
      IMPORTING
        output = <ls_itab>-plnfl.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_HISTORY_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_TYPE
*&---------------------------------------------------------------------*
FORM save_history_table   TABLES  pt_sendtab STRUCTURE zgtppt1050.

  DATA : lv_seqno_n TYPE n LENGTH 10.
  DATA : lv_timestamp TYPE timestampl.

*- 맵핑을 위한 변수키 생성
*  SELECT MAX( zseqno )
*    INTO @DATA(lv_seq)
*    FROM zgtppt1050.
*  IF lv_seq IS INITIAL.
  lv_seqno_n = 1.
*  ELSE.
*    lv_seqno_n = lv_seq + 1.
*  ENDIF.

  GET TIME STAMP FIELD lv_timestamp.
  SORT pt_sendtab BY werks matnr plnnr plnal.
  LOOP AT pt_sendtab ASSIGNING FIELD-SYMBOL(<ls_sdentab>).
    <ls_sdentab>-zifkey = lv_timestamp.
    <ls_sdentab>-zseqno = lv_seqno_n.
    CASE abap_true.
      WHEN p_pcm.
        <ls_sdentab>-zsystem_id = 'KPCM'.
      WHEN p_mes.
        <ls_sdentab>-zsystem_id = 'KBDM'.
        "소재 MOM SRM2510-04825
      WHEN p_mes.
        <ls_sdentab>-zsystem_id = 'KSCM'.
        "소재 MOM SRM2510-04825
* 가온전선 파라미터 추가
      WHEN p_kgpm. "가온 전력 MES
        <ls_sdentab>-zsystem_id = 'KGPM'.
      WHEN p_kgom. "가온 통신 MES
        <ls_sdentab>-zsystem_id = 'KGOM'.
      "한미소 MOM 260826
      WHEN p_kfcm.
        <ls_sdentab>-zsystem_id = 'KFCM'.
      "한미소 MOM 260826
    ENDCASE.

    <ls_sdentab>-zstat = gv_result.
    <ls_sdentab>-zmessage = gv_message.
    <ls_sdentab>-ifdat = sy-datum.
    <ls_sdentab>-iftim = sy-uzeit.
    <ls_sdentab>-ifnam = sy-uname.

    ADD 1 TO lv_seqno_n.
  ENDLOOP.

  MODIFY zgtppt1050 FROM TABLE pt_sendtab[].
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_disp_data .

  REFRESH gt_main_disp.

  LOOP AT gt_ot_itab INTO DATA(ls_main).
    APPEND INITIAL LINE TO gt_main_disp
                           ASSIGNING FIELD-SYMBOL(<ls_main_disp>).
    MOVE-CORRESPONDING ls_main TO <ls_main_disp>.
*   초기 상태값  없음 표시
    <ls_main_disp>-status = icon_led_inactive.
* 수신시스템
    CASE abap_true.
      WHEN p_pcm.
        <ls_main_disp>-zsystem_id = 'KPCM'.
      WHEN p_mes.
        <ls_main_disp>-zsystem_id = 'KBDM'.
        "소재 MOM SRM2510-04825
      WHEN p_mes.
        <ls_main_disp>-zsystem_id = 'KSCM'.
        "소재 MOM SRM2510-04825
* 가온전선 파라미터 추가
      WHEN p_kgpm. "가온 전력 MES
        <ls_main_disp>-zsystem_id = 'KGPM'.
      WHEN p_kgom. "가온 통신 MES
        <ls_main_disp>-zsystem_id = 'KGOM'.
        "한미소 MOM 260826
      WHEN p_kfcm.
        <ls_main_disp>-zsystem_id = 'KFCM'.
        "한미소 MOM 260826
    ENDCASE.
*   시스템 내역
    <ls_main_disp>-ddtext = zgtpp_cl_common=>get_domain_text(
                             iv_domname  = 'ZGTDTARGET'  " 도메인이름
                             iv_domvalue = CONV #(
<ls_main_disp>-zsystem_id ) ).
    " 도메인에 대한 값: 단일값/상한 * 플랜트 내역
    <ls_main_disp>-name1 = zgtpp_cl_common=>get_plant_name( iv_werks =
                                                                       CONV #( <ls_main_disp>-werks ) ). "자재 내역
    <ls_main_disp>-maktx = zgtpp_cl_common=>get_maktx( iv_matnr =
                                                                  <ls_main_disp>-matnr ).
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_DATA2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_disp_data2 .

  REFRESH gt_main_disp.

  LOOP AT gt_send INTO DATA(ls_send).

    APPEND INITIAL LINE TO gt_main_disp
                            ASSIGNING FIELD-SYMBOL(<ls_main_disp>).
    MOVE-CORRESPONDING ls_send TO <ls_main_disp>.
*   전송 결과에 따른 상태 설정
    CASE <ls_main_disp>-zstat.
      WHEN '00' OR '0'.
        <ls_main_disp>-status = icon_led_green.
      WHEN OTHERS.
        <ls_main_disp>-status = icon_led_red.
    ENDCASE.

*   시스템 내역
    <ls_main_disp>-ddtext = zgtpp_cl_common=>get_domain_text(
                              iv_domname  = 'ZGTDTARGET'
 " 도메인이름
                              iv_domvalue = CONV #(
<ls_main_disp>-zsystem_id ) ).                 " 도메인에 대한 값: 단일값/상한
* 플랜트 내역
    <ls_main_disp>-name1 = zgtpp_cl_common=>get_plant_name( iv_werks =
                                                                       CONV #( <ls_main_disp>-werks ) ).
* 자재 내역
    <ls_main_disp>-maktx = zgtpp_cl_common=>get_maktx( iv_matnr =
                                                                  <ls_main_disp>-matnr ).

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0100 .

  CREATE OBJECT go_contain_0100
    EXPORTING
      repid                       = sy-repid
      dynnr                       = sy-dynnr
      extension                   = 10000
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.

  CREATE OBJECT go_grid_0100
    EXPORTING
      i_parent      = go_contain_0100
      i_appl_events = abap_true.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0100 .

  CLEAR gs_layout_0100.
  gs_layout_0100-cwidth_opt = abap_true.
  gs_layout_0100-no_rowins = abap_true.
  gs_layout_0100-sel_mode   = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0100 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPI1020TOP'
      i_internal_tabname     = 'GS_MAIN_DISP'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0100[]
    TABLES
      it_data         = gt_main_disp
    EXCEPTIONS
      OTHERS          = 1.


  LOOP AT gt_fieldcat_0100 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE   <ls_fcat>-fieldname.
      WHEN 'ZIFKEY'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'인터페이스 키'.
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'ZSEQNO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '순번'.
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'STATUS'.
        CASE abap_true.
          WHEN p_send.
            <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'전송 상태'.
          WHEN p_disp.
            <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'전송 결과'.
        ENDCASE.
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-icon = 'X'.
      WHEN 'ZMESSAGE'.
        <ls_fcat>-reptext = <ls_fcat>-coltext
                                          = <ls_fcat>-tooltip = '결과메시지'.
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'L'.
      WHEN 'ZSYSTEM_ID'.
        <ls_fcat>-reptext = <ls_fcat>-coltext
                                          = <ls_fcat>-tooltip = '수신시스템'.
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'C'.
      WHEN 'DDTEXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'시스템 내역'.
        <ls_fcat>-just = 'L'.
      WHEN 'WERKS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'플랜트'.
        <ls_fcat>-just = 'C'.
      WHEN 'NAME1'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'플랜트 내역'.
        <ls_fcat>-just = 'L'.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'자재코드'.
        <ls_fcat>-just = 'C'.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '자재내역'.
        <ls_fcat>-just = 'L'.
      WHEN 'VORNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'작업번호'.
        <ls_fcat>-just = 'C'.
      WHEN 'ARBPL'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'작업장'.
        <ls_fcat>-just = 'C'.
      WHEN 'LTXA1'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'작업내역'.
        <ls_fcat>-just = 'L'.
      WHEN 'PLNNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '그룹'.
        <ls_fcat>-just = 'C'.
      WHEN 'PLNAL'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'그룹카운트'.
        <ls_fcat>-just = 'C'.
      WHEN 'PLNFL'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'작업순서'.
        <ls_fcat>-just = 'C'.
      WHEN 'BMSCH'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'기본수량'.
        <ls_fcat>-just = 'R'.
      WHEN 'MEINH'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '단위'.
        <ls_fcat>-just = 'C'.
      WHEN 'LAR01'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'Activity Type'.
        <ls_fcat>-just = 'C'.
      WHEN 'VGW01'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'표준값'.
        <ls_fcat>-just = 'R'.
      WHEN 'VGE01'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '단위'.
        <ls_fcat>-just = 'C'.
      WHEN 'LAR02'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'Activity Type'.
        <ls_fcat>-just = 'C'.
      WHEN 'VGW02'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'표준값'.
        <ls_fcat>-just = 'R'.
      WHEN 'VGE02'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '단위'.
        <ls_fcat>-just = 'C'.
      WHEN 'LAR03'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'Activity Type'.
        <ls_fcat>-just = 'C'.
      WHEN 'VGW03'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'표준값'.
        <ls_fcat>-just = 'R'.
      WHEN 'VGE03'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '단위'.
        <ls_fcat>-just = 'C'.
      WHEN 'LAR04'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'Activity Type'.
        <ls_fcat>-just = 'C'.
      WHEN 'VGW04'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'표준값'.
        <ls_fcat>-just = 'R'.
      WHEN 'VGE04'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '단위'.
        <ls_fcat>-just = 'C'.
      WHEN 'LAR05'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'Activity Type'.
        <ls_fcat>-just = 'C'.
      WHEN 'VGW05'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'표준값'.
        <ls_fcat>-just = 'R'.
      WHEN 'VGE05'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '단위'.
        <ls_fcat>-just = 'C'.
      WHEN 'LAR06'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'Activity Type'.
        <ls_fcat>-just = 'C'.
      WHEN 'VGW06'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'표준값'.
        <ls_fcat>-just = 'R'.
      WHEN 'VGE06'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '단위'.
        <ls_fcat>-just = 'C'.
      WHEN 'USR04'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'표준인원'.
        <ls_fcat>-just = 'C'.
      WHEN 'USE04'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '단위'.
        <ls_fcat>-just = 'C'.
      WHEN 'DATUV'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'효력시작일'.
        <ls_fcat>-just = 'C'.
      WHEN 'ANDAT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'생성일'.
        <ls_fcat>-just = 'C'.
      WHEN 'ANNAM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'생성자'.
        <ls_fcat>-just = 'C'.
      WHEN 'IFDAT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'전송일자'.
        <ls_fcat>-just = 'C'.
      WHEN 'IFTIM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'전송시간'.
        <ls_fcat>-just = 'C'.
      WHEN 'IFTIM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'전송자'.

        <ls_fcat>-just = 'C'.

      WHEN 'LOEKZ'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip =
'삭제지시자'.

        <ls_fcat>-just = 'C'.

      WHEN 'USR07'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '표준선속'.
        <ls_fcat>-no_zero = abap_true.
    ENDCASE.


    CASE abap_true.
      WHEN p_send.
        CASE <ls_fcat>-fieldname.
          WHEN 'ZIFKEY' OR 'ZSEQNO' OR 'ZSTAT' OR 'IFDAT' OR 'IFTIM' OR
'IFTIM'.
            <ls_fcat>-no_out = 'X'.
        ENDCASE.
      WHEN p_disp.
        CASE <ls_fcat>-fieldname.
          WHEN 'ZSTAT'.
            <ls_fcat>-no_out = 'X'.
        ENDCASE.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0100 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0100
        USING : cl_gui_alv_grid=>mc_fc_loc_undo,
                cl_gui_alv_grid=>mc_fc_auf,
                cl_gui_alv_grid=>mc_fc_check,
                cl_gui_alv_grid=>mc_fc_loc_paste,
                cl_gui_alv_grid=>mc_fc_loc_copy,
                cl_gui_alv_grid=>mc_fc_average,
                cl_gui_alv_grid=>mc_fc_graph,
                cl_gui_alv_grid=>mc_fc_info,
                cl_gui_alv_grid=>mc_fc_loc_copy_row,
                cl_gui_alv_grid=>mc_fc_loc_cut,
                cl_gui_alv_grid=>mc_fc_loc_delete_row,
                cl_gui_alv_grid=>mc_fc_loc_insert_row,
                cl_gui_alv_grid=>mc_fc_loc_append_row,
                cl_gui_alv_grid=>mc_fc_loc_paste,
                cl_gui_alv_grid=>mc_fc_loc_paste_new_row,
                cl_gui_alv_grid=>mc_fc_refresh.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM add_exclude_toolbar_button  TABLES   p_table
                                 USING    p_value.
  DATA: l_exclude TYPE ui_func.
  l_exclude = p_value.
  APPEND l_exclude TO p_table.
ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0100_display .

  CALL METHOD go_grid_0100->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0100
      it_toolbar_excluding = gt_exclude_0100
    CHANGING
      it_outtab            = gt_main_disp
      it_fieldcatalog      = gt_fieldcat_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_SEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_send .

  DATA : lt_row TYPE lvc_t_row.
  DATA : ls_row TYPE lvc_s_row.
  DATA : lt_send TYPE TABLE OF zgtppt1050.
  DATA : ls_err_line LIKE gs_main_disp.
  DATA : lv_message(50).

  CALL METHOD go_grid_0100->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.
  IF lt_row[] IS INITIAL.
    MESSAGE s003 WITH '전송 데이터가 없습니다.' DISPLAY LIKE 'E'. "전송 데이터가 없습니다.
    RETURN.
  ENDIF.

  LOOP AT lt_row INTO ls_row.
    READ TABLE gt_main_disp ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX
ls_row-index.
    IF <ls_main>-arbpl IS INITIAL.
      MOVE-CORRESPONDING <ls_main> TO ls_err_line.
      CONTINUE.
    ENDIF.
    APPEND INITIAL LINE TO lt_send ASSIGNING FIELD-SYMBOL(<ls_send>).
    MOVE-CORRESPONDING <ls_main> TO <ls_send>.
  ENDLOOP.

  PERFORM call_rfc TABLES lt_send.

  READ TABLE lt_send INTO DATA(ls_send) INDEX 1.

  LOOP AT lt_row INTO ls_row.
    READ TABLE gt_main_disp ASSIGNING <ls_main> INDEX ls_row-index.
*  전송결과 적용
    IF line_exists( lt_send[ zstat = '00' ] ) OR
      line_exists( lt_send[ zstat = '0' ] ). " 성공시
      <ls_main>-status = icon_led_green.
    ELSE.
      <ls_main>-status = icon_led_red.
    ENDIF.
    <ls_main>-zmessage = ls_send-zmessage.

    CASE abap_true.
      WHEN p_disp.
        <ls_main>-zifkey = ls_send-zifkey.
        <ls_main>-ifdat = ls_send-ifdat.
        <ls_main>-iftim = ls_send-iftim.
        <ls_main>-ifnam = ls_send-ifnam.
    ENDCASE.
  ENDLOOP.

  PERFORM refresh_grid USING go_grid_0100.
  IF ls_err_line IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_err_line-matnr
      IMPORTING
        output = ls_err_line-matnr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_err_line-plnfl
      IMPORTING
        output = ls_err_line-plnfl.

    CONCATENATE '자재' ls_err_line-matnr '의 순서' ls_err_line-plnfl '가'
INTO lv_message SEPARATED BY space.
    MESSAGE i005 WITH lv_message '작업장이 누락되어 제외하고 전송했습니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0101
*&---------------------------------------------------------------------*
FORM refresh_grid  USING    po_grid TYPE REF TO cl_gui_alv_grid.

  DATA: ls_scroll   TYPE lvc_s_stbl.

  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = ls_scroll.

ENDFORM.
