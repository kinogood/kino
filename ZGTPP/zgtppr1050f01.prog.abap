*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data .

  DATA : lv_stat      LIKE  bsvx-sttxt.
  DATA : lv_menge_sum LIKE  mseg-menge.
  DATA : lv_wemng_sum LIKE  afpo-wemng.
  DATA : lv_bdmng_sum LIKE  resb-bdmng.

  "*****************************************************
  "생산오더 정보 발췌
  " 생산버젼 번호 10 -자작
  "조달유형(a~beskz) : E,
  "특별조달유형(a~sobsl) '',
  "BOM점검 : 있음
  "라우팅 점검 : 있음
  "*****************************************************
  SELECT  a~werks, a~matnr, a~beskz, a~sobsl,
          b~stlan, b~stlal, b~stlnr	,
          c~plnnr, c~plnty, c~plnal
    FROM  marc AS a INNER JOIN mast AS b
                    ON  a~werks = b~werks
                    AND a~matnr = b~matnr
                    INNER JOIN mapl AS c
                    ON  a~werks  = c~werks
                    AND a~matnr = c~matnr
    WHERE a~werks  IN @s_werks
      AND a~matnr  IN @s_matnr
      AND a~beskz = 'E'   " 조달유형
      AND a~sobsl = ''                        "자작  (특별 조달 유형)
***      AND  ( ( b~andat IN @s_andat   )       "조회조건-BOM&라우팅 생성일자)
***            OR ( c~andat IN @s_andat )  )    "조회조건-BOM&라우팅 생성일자)
      AND  b~stlan = '1'        "생산 BOM
      AND  b~stlal = '01'       "대체BOM
    INTO CORRESPONDING FIELDS OF TABLE @gt_data.
  SORT gt_data BY werks matnr.

  "*****************************************************
  " 생산버젼 번호 20 - 외주
  "조달유형(a~beskz) : F,
  "특별조달유형(a~sobsl) '30',
  "BOM점검 : 없으면 생성
  "라우팅 점검 : 없어도 무관
  "*****************************************************
  SELECT  a~werks, a~matnr, a~beskz, a~sobsl
*          b~stlan, b~stlal, b~stlnr
    FROM  marc AS a
*                    INNER JOIN mast AS b
*                    ON  a~werks = b~werks
*                    AND a~matnr = b~matnr
    WHERE a~werks  IN @s_werks
      AND a~matnr  IN @s_matnr
      AND  a~beskz = 'F' AND a~sobsl = '30'  "외주
***      AND  ( ( b~andat IN @s_andat   )      "조회조건-BOM&라우팅 생성일자)
***            OR ( c~andat IN @s_andat )  )   "조회조건-BOM&라우팅 생성일자)
*      AND  b~stlan = '1'                      "생산 BOM
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_data.
  SORT gt_data BY werks matnr.

  "*****************************************************
  " 생산버젼 번호 10 - 자작
  "조달유형(a~beskz) : X,
  "특별조달유형(a~sobsl) '',
  "BOM점검 : 있음
  "라우팅 점검 : 있음
  "*****************************************************
  SELECT  a~werks, a~matnr, a~beskz, a~sobsl,
          b~stlan, b~stlal, b~stlnr	,
          c~plnnr, c~plnty, c~plnal
    FROM  marc AS a INNER JOIN mast AS b
                    ON  a~werks = b~werks
                    AND a~matnr = b~matnr
                    INNER JOIN mapl AS c
                    ON  a~werks  = c~werks
                    AND a~matnr = c~matnr
    WHERE a~werks  IN @s_werks
      AND a~matnr  IN @s_matnr
      AND  a~beskz = 'X'  " 조달유형
      AND  a~sobsl = ''                       "자작  (특별 조달 유형)
***      AND  ( ( b~andat IN @s_andat   )     "조회조건-BOM&라우팅 생성일자)
***            OR ( c~andat IN @s_andat )  )  "조회조건-BOM&라우팅 생성일자)
      AND  b~stlan = '1'                      "생산 BOM
      AND  b~stlal = '01'      "대체BOM
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_data.
  SORT gt_data BY werks matnr.

  "*****************************************************
  " 생산버젼 번호 10 - 자작
  "조달유형(a~beskz) : X,
  "특별조달유형(a~sobsl) '30',
  "BOM점검 : 있음
  "라우팅 점검 : 있음
  "*****************************************************
  SELECT  a~werks, a~matnr, a~beskz, a~sobsl,
          b~stlan, b~stlal, b~stlnr	,
          c~plnnr, c~plnty, c~plnal
    FROM  marc AS a INNER JOIN mast AS b
                    ON  a~werks = b~werks
                    AND a~matnr = b~matnr
                    INNER JOIN mapl AS c
                    ON  a~werks  = c~werks
                    AND a~matnr = c~matnr
    WHERE a~werks  IN @s_werks
      AND a~matnr  IN @s_matnr
      AND a~beskz = 'X'  " 조달유형
      AND  a~sobsl = '30'                     "자작  (특별 조달 유형)
***      AND  ( ( b~andat IN @s_andat   )     "조회조건-BOM&라우팅 생성일자)
***            OR ( c~andat IN @s_andat )  )  "조회조건-BOM&라우팅 생성일자)
      AND  b~stlan = '1'                      "생산 BOM
      AND  b~stlal = '01'   "대체BOM
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_data.
  SORT gt_data BY werks matnr.

  "*****************************************************
  " 생산버젼 번호 20 - 외주
  "조달유형(a~beskz) : X,
  "특별조달유형(a~sobsl) '30',
  "BOM점검 : 있음
  "라우팅 점검 : 업어도 무관
  "*****************************************************
  SELECT  a~werks, a~matnr, a~beskz, a~sobsl,
          b~stlan, b~stlal, b~stlnr
    FROM  marc AS a INNER JOIN mast AS b
                    ON  a~werks = b~werks
                    AND a~matnr = b~matnr
    WHERE a~werks  IN @s_werks
      AND a~matnr  IN @s_matnr
      AND a~beskz = 'X'  " 조달유형
      AND a~sobsl = '30'                     "자작  (특별 조달 유형)
***      AND  ( ( b~andat IN @s_andat   )     "조회조건-BOM&라우팅 생성일자)
***            OR ( c~andat IN @s_andat )  )  "조회조건-BOM&라우팅 생성일자)
      AND  b~stlan = '1'                      "생산 BOM
      AND  b~stlal = '01'   "대체BOM
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_data.
  SORT gt_data BY werks matnr.


  " 자재코드내역을 가져온다
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_makt
    FROM makt
    FOR ALL ENTRIES IN gt_data
   WHERE matnr = gt_data-matnr
     AND spras = sy-langu.
  SORT gt_makt BY matnr .

  " 플랜트 내역을 가져 온다
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_t001w
    FROM t001w
    FOR ALL ENTRIES IN gt_data
   WHERE werks = gt_data-werks.
  SORT gt_t001w BY werks .

  " 생산버젼 정보를 가져온다

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_mkal
    FROM mkal
    FOR ALL ENTRIES IN gt_data
   WHERE werks = gt_data-werks
    AND  matnr = gt_data-matnr.
  SORT gt_mkal BY werks matnr .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_screen_attribute
*&---------------------------------------------------------------------*
FORM set_screen_attribute .


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
*& Form data_conversion
*&---------------------------------------------------------------------*
FORM data_conversion TABLES pt_ot_tab STRUCTURE zgtppsif0002.

  LOOP AT pt_ot_tab ASSIGNING FIELD-SYMBOL(<ls_itab>).
    "자재번호
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = <ls_itab>-matnr
      IMPORTING
        output = <ls_itab>-matnr.
    "그룹카운터
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <ls_itab>-alnal
      IMPORTING
        output = <ls_itab>-alnal.
    "대체 BOM No.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <ls_itab>-stlal
      IMPORTING
        output = <ls_itab>-stlal.

  ENDLOOP.

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
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_data .

  LOOP AT gt_Data.

    "처리상태
    gs_disp-zstat = icon_led_inactive. "미처리

    " 메시지
    gs_disp-zmessage  = ''.

    " 품목코드
    gs_disp-matnr     = gt_data-matnr.

    "품목내역
    CLEAR gt_makt.
    READ TABLE gt_makt WITH KEY matnr = gt_data-matnr.
    IF sy-subrc = 0.
      gs_disp-maktx = gt_makt-maktx.
    ENDIF.

    " 플랜트
    gs_disp-werks   = gt_data-werks.

    "  플랜트내역
    CLEAR gt_t001w.
    READ TABLE gt_t001w WITH KEY werks = gt_data-werks.
    IF sy-subrc = 0.
      gs_disp-name1 = gt_t001w-name1.
    ENDIF.

    " 생산버전
    "※ 조달유형, 특별조달유형 조합에 따른 생산버전 구성 표 참고(자작은 10, 외주는 20)
    " marc-beskz 조달 유형
    " marc-sobsl 특별조달유형
    " mast에 data가 존재유무
    " mapl에 data가 존재유무

    IF gt_data-beskz = 'E'       " 생산버젼 0010 - 자작
       AND gt_data-sobsl = ''
       AND gt_data-stlal IS NOT INITIAL
       AND gt_data-plnnr IS NOT INITIAL.
      gs_disp-verid   = '0010'.
    ELSEIF gt_data-beskz = 'F'       " 생산버젼 0020 - 외주
       AND gt_data-sobsl = '30'.
*       AND gt_data-stlal IS  INITIAL     " BOM
*       AND gt_data-plnnr IS INITIAL.     " 라우팅
      gs_disp-verid   = 'SC10'.
    ELSEIF gt_data-beskz = 'X'       " 생산버젼 0010 - 자작
       AND gt_data-sobsl = ''
       AND gt_data-stlal IS NOT INITIAL
       AND gt_data-plnnr IS NOT INITIAL.
      gs_disp-verid   = '0010'.
    ELSEIF gt_data-beskz = 'X'       " 생산버젼 0010 - 자작
       AND gt_data-sobsl = '30'
       AND gt_data-stlal IS NOT INITIAL
       AND gt_data-plnnr IS NOT INITIAL.
      gs_disp-verid   = '0010'.
    ELSEIF gt_data-beskz = 'X'       " 생산버젼 0020 - 외주
       AND gt_data-sobsl = '30'
       AND gt_data-stlal IS NOT INITIAL
       AND gt_data-plnnr IS INITIAL.
      gs_disp-verid   = 'SC10'.
    ELSE.
      gs_disp-delflag = 'X'.
    ENDIF.

    " 생산버젼내역
    IF gs_disp-verid = '0010'.
      gs_disp-text1 = '자작(표준)'.
    ELSEIF gs_disp-verid = 'SC10'.
      gs_disp-text1  = '외주'.
    ENDIF.

    CLEAR : gt_mkal.
    READ TABLE gt_mkal WITH KEY werks = gt_data-werks
                                matnr = gt_data-matnr
                                verid = gs_disp-verid.

    IF sy-subrc = 0.
      gs_disp-zstat = icon_led_green.
      gs_disp-zmessage = '생성완료'.
      gs_disp-adatu  = gt_mkal-adatu. " 효력시작일
      gs_disp-bdatu  = gt_mkal-bdatu. " 효력종료일
      gs_disp-stlan  = gt_mkal-stlan. " BOM 용도
      gs_disp-stlal  = gt_mkal-stlal. " 대체 BOM
      gs_disp-plnnr  = gt_mkal-plnnr. " 그룹번호
      gs_disp-plnty  = gt_mkal-plnty. " 태스트 리스트 유형
      gs_disp-alnal  = gt_mkal-alnal. " 그룹카운터

      gs_disp-prfg_s = gt_mkal-prfg_s."  BOM 점검
      CASE gs_disp-prfg_s.
        WHEN ''.
          gs_disp-prfg_s_icon = icon_led_inactive.
        WHEN '1'.
          gs_disp-prfg_s_icon = icon_led_green.
        WHEN '2'.
          gs_disp-prfg_s_icon = icon_led_red.
        WHEN '3'.
          gs_disp-prfg_s_icon = icon_led_yellow.
      ENDCASE.

      IF gs_disp-plnnr IS INITIAL.
        gs_disp-prfg_f_icon = ''.
      ELSE.
        gs_disp-prfg_f = gt_mkal-prfg_f."  라우팅 점검
        CASE gs_disp-prfg_f.
          WHEN ''.
            gs_disp-prfg_f_icon = icon_led_inactive.
          WHEN '1'.
            gs_disp-prfg_f_icon = icon_led_green.
          WHEN '2'.
            gs_disp-prfg_f_icon = icon_led_red.
          WHEN '3'.
            gs_disp-prfg_f_icon = icon_led_yellow.
        ENDCASE.
      ENDIF.
      gs_disp-prdat  = gt_mkal-prdat. "  최종점검일자
      gs_disp-delflag2 = 'X'.

    ELSE.

      gs_disp-adatu  = '20240101'. " 효력시작일
      gs_disp-bdatu  = '99991231'. " 효력종료일
      gs_disp-stlan  = gt_data-stlan. " BOM 용도
      gs_disp-stlal  = gt_data-stlal. " 대체 BOM
      gs_disp-plnnr  = gt_data-plnnr. " 그룹번호
      gs_disp-plnty  = gt_data-plnty. " 태스트 리스트 유형
      gs_disp-alnal  = gt_data-plnal. " 그룹카운터
      gs_disp-prfg_s = '1'."  BOM 점검
      CASE gs_disp-prfg_s.  "  BOM 점검 icon
        WHEN ''.
          gs_disp-prfg_s_icon = icon_led_inactive.
        WHEN '1'.
          gs_disp-prfg_s_icon = icon_led_green.
        WHEN '2'.
          gs_disp-prfg_s_icon = icon_led_red.
        WHEN '3'.
          gs_disp-prfg_s_icon = icon_led_yellow.
      ENDCASE.
      gs_disp-prfg_f = '1'."  라우팅 점검
      IF gs_disp-plnnr IS INITIAL.
        gs_disp-prfg_f_icon = ''.
      ELSE.
        CASE gs_disp-prfg_f. "  라우팅 점검 icon
          WHEN ''.
            gs_disp-prfg_f_icon = icon_led_inactive.
          WHEN '1'.
            gs_disp-prfg_f_icon = icon_led_green.
          WHEN '2'.
            gs_disp-prfg_f_icon = icon_led_red.
          WHEN '3'.
            gs_disp-prfg_f_icon = icon_led_yellow.
        ENDCASE.
      ENDIF.
      gs_disp-prdat  = sy-datum. "  최종점검일자
    ENDIF.

    gs_disp-beskz    = gt_data-beskz.
    gs_disp-sobsl    = gt_data-sobsl.

    APPEND gs_disp TO gt_disp.

    CLEAR gs_disp.

  ENDLOOP.

  IF p_c1 <> 'X'.  "이미  생성된 생산버젼 포함이 아닐경우
    DELETE gt_disp WHERE delflag = 'X'.
    DELETE gt_disp WHERE delflag2 = 'X'.
  ELSE.
    DELETE gt_disp WHERE delflag = 'X'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SCREEN_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_screen_value .
* 생산시작일자 셋팅
  IF s_andat[] IS INITIAL.

    s_andat-sign   = 'I'.
    s_andat-option = 'EQ'.
* 시작: 이번달 1일
    CONCATENATE sy-datum+0(6) '01'  INTO s_andat-low .
* 종료: 이번달 말일
* 입력일자가 속한 월의 마지막 일자를 RETURN해 줍니다.
    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = sy-datum
      IMPORTING
        last_day_of_month = s_andat-high
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.

    APPEND s_andat.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_BDC_CS01
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exec_bdc_cs01 USING  pv_matnr
                          pv_werks
                          pv_stlan
                          pv_stlal.

  DATA: BEGIN OF gt_msgcoll OCCURS 1.
          INCLUDE STRUCTURE bdcmsgcoll.
  DATA: END   OF gt_msgcoll.

  REFRESH: gt_bdcdata, gt_msgcoll.
  CLEAR  : gt_bdcdata, gt_msgcoll.

  PERFORM dynpro1 USING:
    'X'  'SAPLCSDI'               '0100',
    ' '  'BDC_OKCODE'             '/00',
    ' '  'RC29N-MATNR'             pv_matnr,
    ' '  'RC29N-WERKS'             pv_werks,
    ' '  'RC29N-STLAN'             '1',
    ' '  'RC29N-STLAL'             '1'.

  PERFORM dynpro1 USING:
    'X'  'SAPLCSDI'               '2150',
    ' '  'BDC_OKCODE'             '=FCBU'.

  gs_params-dismode  = 'N'.   " 처리모드
  gs_params-updmode  = 'S'.   " 갱신세션
  gs_params-cattmode = 'A'.   " CATT모드
  gs_params-defsize  = ' '.   " 기본화면
  gs_params-racommit = 'X'.   " COMMIT 이후 지속
  gs_params-nobinpt  = 'X'.   " BI 세션

  CALL TRANSACTION 'CS01'          "Transaction Call.
             USING gt_bdcdata
           OPTIONS FROM gs_params
          MESSAGES INTO gt_msgcoll.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form dynpro1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM dynpro1  USING dynbegin name value.
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
*& Form CREATE_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_data .

  DATA: BEGIN OF gt_mast OCCURS 1.
          INCLUDE STRUCTURE mast.
  DATA: END   OF gt_mast.

  DATA : lv_weblnr   LIKE affw-weblnr,
         lv_text(70).

  CLEAR  : gt_row_no, gt_row_no[], gv_mandt.

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
  CLEAR : gv_error.
  LOOP AT gt_row_no.

    CLEAR : gs_disp.
    READ TABLE gt_disp INTO gs_disp INDEX gt_row_no-row_id.

    IF gs_disp IS NOT INITIAL.

      IF gs_disp-zstat = icon_led_green.
        MESSAGE s003 WITH '이미 생산버전이 생성된 레코드입니다.'.
      ELSE.
        CLEAR : gt_mast[], gt_mast.
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE gt_mast
          FROM mast
         WHERE matnr = gs_disp-matnr
           AND werks = gs_disp-werks
           AND stlal = '02'.

        "생산버전 생성 이전에 조달유형이 F 이면서 특별조달유형이 30인데
        " BOM이 존재하지 않는 경우 "컴포넌트 없는 BOM"을 생성함
        IF gs_disp-beskz = 'F'       " 생산버젼 0020 - 외주
            AND gs_disp-sobsl = '30'
            AND gs_disp-stlal IS  INITIAL.     " BOM
          PERFORM exec_bdc_cs01 USING gs_disp-matnr
                                      gs_disp-werks
                                      gs_disp-stlan
                                      gs_disp-stlal.
        ENDIF.


        IF gs_disp-verid  = '0011'
           AND gt_mast[] IS INITIAL..
          PERFORM exec_bdc_cs01_bd2 USING gs_disp-matnr
                                      gs_disp-werks
                                      gs_disp-stlan
                                      gs_disp-stlal.
        ENDIF.

        " 생산버젼 생성
        DATA : lv_it_prod_version	TYPE  bom_tt_prodver_mkal_entries,
               ls_it_prod_version TYPE  lt_mkal.

        ls_it_prod_version-matnr   = gs_disp-matnr."품목코드
        ls_it_prod_version-werks   = gs_disp-werks."플랜트
        ls_it_prod_version-verid   = gs_disp-verid."생산버전코드
        ls_it_prod_version-adatu   = gs_disp-adatu."효력시작일
        ls_it_prod_version-bdatu   = gs_disp-bdatu."효력정료일
        ls_it_prod_version-stlal   = gs_disp-stlal."대체 BOM
        ls_it_prod_version-stlan   = gs_disp-stlan."BOM 용도
        ls_it_prod_version-plnty   = gs_disp-plnty."태스크 리스트 유형
        ls_it_prod_version-plnnr   = gs_disp-plnnr."그룹번호
        ls_it_prod_version-alnal   = gs_disp-alnal."그룹카운터
        ls_it_prod_version-prfg_s    = '1'     .       "BOM 점검
        ls_it_prod_version-prfg_f    = '1'     .       "라우팅 점검
        ls_it_prod_version-prdat   = gs_disp-prdat."최종점검일자
        ls_it_prod_version-text1   = gs_disp-text1."생산버전내역

        APPEND ls_IT_prod_version TO lv_it_prod_version.

        CALL FUNCTION 'CS_BOM_UPDATE_PROD_VERSIONS'
          EXPORTING
            it_prod_version = lv_it_prod_version.

        IF sy-subrc = 0.
          UPDATE marc
             SET verkz = 'X'
           WHERE werks = gs_disp-werks
             AND matnr = gs_disp-matnr.
          IF sy-subrc = 0.
            COMMIT WORK.
            gs_disp-zstat = icon_led_green.
            gs_disp-zmessage = '생산버전이 성공적으로 생성되었습니다.'.
          ELSE.
            ROLLBACK WORK.
            gs_disp-zstat = icon_led_red.
            gs_disp-zmessage = '생산버전 생성이 실패하였습니다.'.
          ENDIF.
        ELSE.

        ENDIF.

      ENDIF.

    ENDIF.

    MODIFY gt_disp FROM gs_disp INDEX gt_row_no-row_id..

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form BATCH_CREATE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM batch_create_data .

  LOOP AT gt_disp INTO gs_disp.
    IF gs_disp-zstat = icon_led_inactive.       "미처리

      "생산버전 생성 이전에 조달유형이 F 이면서 특별조달유형이 30인데
      " BOM이 존재하지 않는 경우 "컴포넌트 없는 BOM"을 생성함
      IF gs_disp-beskz = 'F'       " 생산버젼 0020 - 외주
          AND gs_disp-sobsl = '30'
          AND gs_disp-stlal IS  INITIAL.     " BOM
        PERFORM exec_bdc_cs01 USING gs_disp-matnr
                                    gs_disp-werks
                                    gs_disp-stlan
                                    gs_disp-stlal.
      ENDIF.

      " 생산버젼 생성
      DATA : lv_it_prod_version	TYPE  bom_tt_prodver_mkal_entries,
             ls_it_prod_version TYPE  lt_mkal.

      ls_it_prod_version-matnr   = gs_disp-matnr."품목코드
      ls_it_prod_version-werks   = gs_disp-werks."플랜트
      ls_it_prod_version-verid   = gs_disp-verid."생산버전코드
      ls_it_prod_version-adatu   = gs_disp-adatu."효력시작일
      ls_it_prod_version-bdatu   = gs_disp-bdatu."효력정료일
      ls_it_prod_version-stlal   = gs_disp-stlal."대체 BOM
      ls_it_prod_version-stlan   = gs_disp-stlan."BOM 용도
      ls_it_prod_version-plnty   = gs_disp-plnty."태스크 리스트 유형
      ls_it_prod_version-plnnr   = gs_disp-plnnr."그룹번호
      ls_it_prod_version-alnal   = gs_disp-alnal."그룹카운터
      ls_it_prod_version-prfg_s    = '1'     .       "BOM 점검
      ls_it_prod_version-prfg_f    = '1'     .       "라우팅 점검
      ls_it_prod_version-prdat   = gs_disp-prdat."최종점검일자
      ls_it_prod_version-text1   = gs_disp-text1."생산버전내역

      APPEND ls_IT_prod_version TO lv_it_prod_version.

      CALL FUNCTION 'CS_BOM_UPDATE_PROD_VERSIONS'
        EXPORTING
          it_prod_version = lv_it_prod_version.

      IF sy-subrc = 0.
        UPDATE marc
           SET verkz = 'X'
         WHERE werks = gs_disp-werks
           AND matnr = gs_disp-matnr.
        IF sy-subrc = 0.
          COMMIT WORK.
          gs_disp-zstat = icon_led_green.
          gs_disp-zmessage = '생산버전이 성공적으로 생성되었습니다.'.
        ELSE.
          ROLLBACK WORK.
          gs_disp-zstat = icon_led_red.
          gs_disp-zmessage = '생산버전 생성이 실패하였습니다.'.
        ENDIF.
      ELSE.

      ENDIF.

    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_data_add
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_data_add .

  LOOP AT gt_disp INTO gs_disp.

    IF gs_disp-verid   = '0010'
       AND gs_disp-beskz = 'E'      " 생산버젼 0010 - 자작
       AND gs_disp-sobsl = ''
       AND gs_disp-stlal IS NOT INITIAL
       AND gs_disp-plnnr IS NOT INITIAL .
      MOVE-CORRESPONDING gs_disp TO gs_disp_add.
      gs_disp_add-verid   = '0011'.
      APPEND gs_disp_add TO gt_disp_add.
    ENDIF.

    IF gs_disp-verid   = '0010'
       AND gs_disp-beskz = 'X'       " 생산버젼 0010 - 자작
       AND gs_disp-sobsl = ''
       AND gs_disp-stlal IS NOT INITIAL
       AND gs_disp-plnnr IS NOT INITIAL.
      MOVE-CORRESPONDING gs_disp TO gs_disp_add.
      gs_disp_add-verid   = '0011'.
      APPEND gs_disp_add TO gt_disp_add.
    ENDIF.

    IF gs_disp-verid   = '0010'
       AND  gs_disp-beskz = 'X'       " 생산버젼 0010 - 자작
       AND gs_disp-sobsl = '30'
       AND gs_disp-stlal IS NOT INITIAL
       AND gs_disp-plnnr IS NOT INITIAL.
      MOVE-CORRESPONDING gs_disp TO gs_disp_add.
      gs_disp_add-verid   = '0011'.
      APPEND gs_disp_add TO gt_disp_add.
    ENDIF.

  ENDLOOP.

  LOOP AT gt_disp_add INTO gs_disp_add .

    MOVE-CORRESPONDING gs_disp_add TO gs_disp.

    " 생산버젼내역
    IF gs_disp-verid = '0010'.
      gs_disp-text1 = '자작(표준)'.
    ELSEIF gs_disp-verid = '0011'.
      gs_disp-text1  = '자작(생산)'.
***      gs_disp-stlan  = ''.
      gs_disp-stlal  = '02'.
    ELSEIF gs_disp-verid = 'SC10'.
      gs_disp-text1  = '외주'.
    ENDIF.

    APPEND gs_disp TO gt_disp.

    CLEAR gs_disp_add.

  ENDLOOP.

  SORT gt_disp BY werks matnr verid.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form exec_bdc_cs01_bd2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DISP_MATNR
*&      --> GS_DISP_WERKS
*&      --> GS_DISP_STLAN
*&      --> GS_DISP_STLAL
*&---------------------------------------------------------------------*
FORM exec_bdc_cs01_bd2  USING  pv_matnr
                          pv_werks
                          pv_stlan
                          pv_stlal.

  DATA: BEGIN OF gt_msgcoll OCCURS 1.
          INCLUDE STRUCTURE bdcmsgcoll.
  DATA: END   OF gt_msgcoll.

  REFRESH: gt_bdcdata, gt_msgcoll.
  CLEAR  : gt_bdcdata, gt_msgcoll.

  PERFORM dynpro1 USING:
    'X'  'SAPLCSDI'               '0100',
    ' '  'BDC_OKCODE'             '/00',
    ' '  'RC29N-MATNR'             pv_matnr,
    ' '  'RC29N-WERKS'             pv_werks,
    ' '  'RC29N-STLAN'             '1',
    ' '  'RC29N-STLAL'             '2',
    ' '  'RC29N-DATUV'             '2024.01.01'.
  PERFORM dynpro1 USING:
    'X'  'SAPLCSDI'               '2150',
    ' '  'BDC_OKCODE'             '=FCBU'.

  gs_params-dismode  = 'N'.   " 처리모드
  gs_params-updmode  = 'S'.   " 갱신세션
  gs_params-cattmode = 'A'.   " CATT모드
  gs_params-defsize  = ' '.   " 기본화면
  gs_params-racommit = 'X'.   " COMMIT 이후 지속
  gs_params-nobinpt  = 'X'.   " BI 세션

  CALL TRANSACTION 'CS01'          "Transaction Call.
             USING gt_bdcdata
           OPTIONS FROM gs_params
          MESSAGES INTO gt_msgcoll.

ENDFORM.
