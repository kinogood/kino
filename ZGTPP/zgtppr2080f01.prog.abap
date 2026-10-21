*&---------------------------------------------------------------------*
*& Include          ZGTPPR2080F01
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

    IF screen-group1 = 'M1'.
      screen-input = 0.
      screen-intensified = 1.
      MODIFY SCREEN.
    ENDIF.

    IF screen-group1 = 'M2'.
      screen-input = 0.
      screen-intensified = 1.
      MODIFY SCREEN.
    ENDIF.

    CASE abap_true.
      WHEN p_rad1.
        CASE screen-group1.
          WHEN 'D2' OR 'D3'.
            screen-active = 0.
            MODIFY SCREEN.
        ENDCASE.

        CASE screen-name.
          WHEN 'P_SIMNO'.
            screen-required = 2.
            MODIFY SCREEN.
          WHEN 'P_NEWNM' OR 'S_SPMON-LOW'.
            screen-required = 0.
            MODIFY SCREEN.
        ENDCASE.
      WHEN p_rad2.
        CASE screen-group1.
          WHEN 'D0' OR 'D1' OR  'M2'.
            screen-active = 0.
            MODIFY SCREEN.
        ENDCASE.

        CASE screen-name.
          WHEN 'P_SIMNO'.
            screen-required = 0.
            MODIFY SCREEN.
          WHEN 'P_NEWNM' OR 'S_SPMON-LOW'.
            screen-required = 2.
            MODIFY SCREEN.
        ENDCASE.

      WHEN p_rad3.
        CASE screen-group1.
          WHEN 'D0' OR 'D2' OR  'M2'.
            screen-active = 0.
            MODIFY SCREEN.
        ENDCASE.

        CASE screen-name.
          WHEN 'P_SIMNO' OR 'P_NEWNM'.
            screen-required = 0.
            MODIFY SCREEN.
          WHEN 'S_SPMON-LOW'.
            screen-required = 2.
            MODIFY SCREEN.
        ENDCASE.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PARAMETER_DESCRIPTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_parameter_description .

* SPG
  IF NOT p_spgcd IS INITIAL.
    SELECT SINGLE descr INTO p_descr
             FROM zppt0107
            WHERE spgcd EQ p_spgcd.
  ELSE.
    CLEAR p_descr.
  ENDIF.

* 플랜트명
  IF NOT p_werks IS INITIAL.
    SELECT SINGLE name1 INTO p_name1
             FROM t001w
            WHERE werks EQ p_werks.
  ELSE.
    CLEAR p_name1.
  ENDIF.

* 플랜트명
  IF NOT p_simno IS INITIAL.
    SELECT SINGLE simnm INTO p_simnm
             FROM zgtppt2090
            WHERE simno EQ p_simno.
  ELSE.
    CLEAR p_simnm.
  ENDIF.

* 월간계획유형
  IF NOT p_simty IS INITIAL.
    SELECT SINGLE ddtext INTO p_simdec
             FROM dd07t
            WHERE domname = 'ZGTDSIMTY'
               AND domvalue_l EQ p_simty.
  ELSE.
    CLEAR p_simdec.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SIMNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_simno  USING    pv_dynprofld TYPE help_info-dynprofld .

  DATA : BEGIN OF ls_simul,
           seqno  TYPE zgtppt3270-seqno,
           simty  TYPE zgtppt2090-simty,
           ddtext TYPE dd07t-ddtext,
           simno  TYPE zgtppt2090-simno,
           simvr  TYPE zgtppt2090-simvr,
           period TYPE char20,
           plcnf  TYPE zgtppt2090-plcnf,
           simnm  TYPE char30,
         END OF ls_simul.
  DATA : lt_simul LIKE TABLE OF ls_simul.

  DATA : lt_return_tab TYPE TABLE OF ddshretval,
         ls_return_tab LIKE LINE OF lt_return_tab.

  DATA : lv_idx TYPE i.
  DATA : lt_simno TYPE RANGE OF zgtppt2090-simno.

  DATA : lv_offset(6) TYPE n.
  DATA : lo_flief TYPE REF TO data.

  DATA : lt_field_tab TYPE TABLE OF dfies.
  DATA : lo_structdescr TYPE REF TO cl_abap_structdescr.

  DATA : lv_line       LIKE sy-stepl,
         lt_dynpfields LIKE TABLE OF dynpread.

  PERFORM get_dynp_value USING 'P_WERKS'.
  PERFORM get_dynp_value USING 'P_SPGCD'.
  PERFORM get_dynp_value USING 'P_SIMTY'.

  CHECK p_werks IS NOT INITIAL AND p_spgcd IS NOT INITIAL AND p_simty IS NOT INITIAL.

  REFRESH gr_simty[].
  CLEAR gr_simty.
  CASE p_simty.
    WHEN '1'.
      CLEAR gr_simty.
      gr_simty-sign = 'I'.
      gr_simty-option = 'EQ'.
      gr_simty-low = '1'.
      APPEND gr_simty.
    WHEN '2'.
      CLEAR gr_simty.
      gr_simty-sign = 'I'.
      gr_simty-option = 'EQ'.
      gr_simty-low = '2'.
      APPEND gr_simty.
* 초기 필드 미생성시 데이터 조회를 위해 빈값 추출
      CLEAR gr_simty-low.
      APPEND gr_simty.
  ENDCASE.

  REFRESH lt_simno.
  CASE pv_dynprofld.
    WHEN 'P_SIMVR'.
      IF p_simno IS NOT INITIAL.
        APPEND INITIAL LINE TO lt_simno ASSIGNING FIELD-SYMBOL(<ls_simno>).
        <ls_simno>-sign = 'I'.
        <ls_simno>-option = 'EQ'.
        <ls_simno>-low = p_simno.
      ENDIF.
  ENDCASE.

  REFRESH lt_simul.

  SELECT simty, simno, simvr, simnm, zspmon, zepmon, plcnf
    FROM zgtppt2090
    WHERE werks = @p_werks
      AND spgcd = @p_spgcd
      AND simty IN @gr_simty
      AND simno IN @lt_simno
     INTO TABLE @DATA(lt_2090).

  SORT lt_2090 BY simno simvr.
  DELETE ADJACENT DUPLICATES FROM lt_2090 COMPARING simno simvr.

  FREE lo_flief.
  CREATE DATA lo_flief LIKE ls_simul.

  lo_structdescr ?= cl_abap_structdescr=>describe_by_data_ref( lo_flief ).
  lt_field_tab = cl_salv_data_descr=>read_structdescr( lo_structdescr ).

  CLEAR lv_offset.
  LOOP AT lt_field_tab ASSIGNING FIELD-SYMBOL(<ls_field_tab>).

    CASE <ls_field_tab>-fieldname.
      WHEN 'SIMNM'.
        <ls_field_tab>-reptext  = '시뮬레이션명'.
      WHEN 'SIMTY'.
        <ls_field_tab>-reptext  = '월간계획유형'.
      WHEN 'DDTEXT'.
        <ls_field_tab>-reptext  = '월간계획유형명'.
      WHEN 'PERIOD'.
        <ls_field_tab>-reptext  = '계획기간(월)'.
      WHEN 'SEQNO'.
        <ls_field_tab>-position = 1.
        <ls_field_tab>-reptext  = '순번'.
*        <LS_FIELD_TAB>-DYNPFLD  = ''.
*        <LS_FIELD_TAB>-NOHISTORY = ABAP_TRUE.
      WHEN OTHERS.
        <ls_field_tab>-reptext  = <ls_field_tab>-scrtext_m.
    ENDCASE.

    <ls_field_tab>-offset = lv_offset.
    lv_offset = lv_offset + <ls_field_tab>-intlen.
  ENDLOOP.

  CLEAR lv_idx.
  LOOP AT lt_2090 INTO DATA(ls_2090).
    APPEND INITIAL LINE TO lt_simul ASSIGNING FIELD-SYMBOL(<ls_simul>).
    MOVE-CORRESPONDING ls_2090 TO <ls_simul>.

    <ls_simul>-simty = p_simty.
    SELECT SINGLE ddtext FROM dd07t
      INTO <ls_simul>-ddtext
      WHERE domname = 'ZGTDSIMTY'
         AND domvalue_l = p_simty.

    CONCATENATE ls_2090-zspmon '~' ls_2090-zepmon INTO <ls_simul>-period SEPARATED BY space.
    ADD 1 TO lv_idx.
    <ls_simul>-seqno = lv_idx.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      retfield        = 'SEQNO'
      dynprofield     = pv_dynprofld           "F4누른 필드->DEPT_CD
      value_org       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      window_title    = '시뮬레이션 조회'   "Search Help 타이틀
      display         = 'F'
    TABLES
      field_tab       = lt_field_tab
      value_tab       = lt_simul                  "부서코드, 부서명 가져온 인터널 테이블
      return_tab      = lt_return_tab            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  READ TABLE lt_return_tab INTO ls_return_tab INDEX 1.
  IF sy-subrc EQ 0.
    READ TABLE lt_2090 INTO ls_2090 INDEX ls_return_tab-fieldval.
    IF sy-subrc EQ 0.

      REFRESH lt_dynpfields.
      PERFORM get_stepl USING lv_line.
*      시뮬레이션 번호
      APPEND INITIAL LINE TO lt_dynpfields ASSIGNING FIELD-SYMBOL(<ls_dynpfields>).
      <ls_dynpfields>-fieldname = 'P_SIMNO'.
      <ls_dynpfields>-stepl = lv_line.
      <ls_dynpfields>-fieldvalue = ls_2090-simno.

*      시뮬레이션 이름
      APPEND INITIAL LINE TO lt_dynpfields ASSIGNING <ls_dynpfields>.
      <ls_dynpfields>-fieldname = 'P_SIMNM'.
      <ls_dynpfields>-stepl = lv_line.
      <ls_dynpfields>-fieldvalue = ls_2090-simnm.

*      시뮬레이션 번호
      APPEND INITIAL LINE TO lt_dynpfields ASSIGNING <ls_dynpfields>.
      <ls_dynpfields>-fieldname = 'P_SIMVR'.
      <ls_dynpfields>-stepl = lv_line.
      <ls_dynpfields>-fieldvalue = ls_2090-simvr.

      CALL FUNCTION 'DYNP_VALUES_UPDATE'
        EXPORTING
          dyname               = sy-cprog
          dynumb               = sy-dynnr
        TABLES
          dynpfields           = lt_dynpfields
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
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DYNP_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM get_dynp_value  USING  pv_fieldname TYPE dynpread-fieldname.

  ASSIGN (pv_fieldname) TO FIELD-SYMBOL(<lv_value>).

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      i_field = pv_fieldname
      i_repid = sy-cprog
      i_dynnr = sy-dynnr
    CHANGING
      o_value = <lv_value>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STEPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_LINE
*&---------------------------------------------------------------------*
FORM get_stepl  USING    pv_line LIKE sy-stepl.
  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      povstepl        = pv_line
    EXCEPTIONS
      stepl_not_found = 01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECKING_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM authority_checking_proc .

*& MRP관리자에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_SPGCD'
  ID 'WERKS'  FIELD p_werks
  ID 'SPGCD'  FIELD p_spgcd.

  IF sy-subrc <> 0.
    MESSAGE e006 WITH 'SPG[' p_spgcd
                      '] 작업권한을 확인하세요.'.
  ENDIF.

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

  DATA : lv_chk_err.
  CLEAR : gv_chk_edit, gv_chk_include.

* 디스플레이 화면 구성, 동적 인터널테이블 생성
  PERFORM init_screen_100 CHANGING lv_chk_err.

  IF lv_chk_err IS NOT INITIAL.
    MESSAGE s001 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

* 시뮬레이션타입
  REFRESH gr_simty[].
  CLEAR gr_simty.
  CASE p_simty.
    WHEN '1'.
      CLEAR gr_simty.
      gr_simty-sign = 'I'.
      gr_simty-option = 'EQ'.
      gr_simty-low = '1'.
      APPEND gr_simty.
    WHEN '2'.
      CLEAR gr_simty.
      gr_simty-sign = 'I'.
      gr_simty-option = 'EQ'.
      gr_simty-low = '2'.
      APPEND gr_simty.
* 초기 필드 미생성시 데이터 조회를 위해 빈값 추출
      CLEAR gr_simty-low.
      APPEND gr_simty.
  ENDCASE.


* 최초값 세팅
  CASE abap_true.
    WHEN p_rad1. " 시뮬레이션 생산계획 조회
      gv_simno = p_simno.
      gv_simvr = p_simvr.
      gv_simnm = p_simnm.
    WHEN p_rad2. " 월간생산계획 신규 수립
*      GV_SIMNO = P_SIMNO. " 신규생성시엔 시뮬레이션 번호 없음
      gv_simvr = '001'. " 최초 생성시 1번 고정
      gv_simnm = p_newnm. " 입력받은 시뮬레이션 명으로 세팅
    WHEN p_rad3. " 확정 월간생산계획 조회

  ENDCASE.

* 프로그램 수행전 정합성
  CLEAR gv_chk_include.
  CASE abap_true.
*  신규 월간 계획 수립 시 수립 월 Validation
    WHEN p_rad2.

*- 시뮬레이션은 월별 Rolling 가능하도록 수정
*- 확정된 계획의 시뮬레이션과 동일한 기간 불가
*- 확정된 계획의 시뮬레이션 일자보다 작은 From 월 불가
*- 확정된 계획의 시뮬레이션 일자가 입력 To 보다 크면 불가
*- 확정 계획 ZGTPPT2100의 시뮬레이션 확인 ZGTPPT2090
*- MAX(SIMNO)의 수립  확인 ZGTPPT2090-ZSPMON, ZGTPPT2090-ZEPMON
*- 입력 수립 From, To 월과 ZSPMON, ZEPMON이 동일하면 오류
*- 입력된 수립 From 월이 ZSPMON 보다 작으면 오류
*- 입력된 수립 To 월이 ZEPMON 보다 작으면 오류
      SELECT * FROM zgtppt2100
        INTO TABLE @DATA(lt_2100)
       WHERE werks = @p_werks
          AND spgcd = @p_spgcd
          AND spmon >= @gv_bgn_dt+0(6).

      IF lt_2100[] IS NOT INITIAL.
        SELECT b~*
          FROM @lt_2100 AS a
          INNER JOIN zgtppt2090 AS b ON b~werks = a~werks
                                                AND b~spgcd = a~spgcd
                                                AND b~simno = a~simno
                                                AND b~simvr = a~simvr
         WHERE b~plcnf = @abap_true
             AND b~simty IN @gr_simty
          INTO TABLE @DATA(lt_chk_2090).
      ENDIF.

      SORT lt_chk_2090 BY simno simvr.
      DELETE ADJACENT DUPLICATES FROM lt_chk_2090 COMPARING simno simvr.

      IF sy-subrc EQ 0.
        LOOP AT lt_chk_2090 INTO DATA(ls_chk_2090).
          gv_chk_edit = abap_true.
          gv_chk_include = abap_true.

          IF ls_chk_2090-zspmon = gv_bgn_dt+0(6) AND
            ls_chk_2090-zepmon = gv_end_dt+0(6).
            MESSAGE s006 DISPLAY LIKE 'E' WITH '확정된 생산 시뮬레이션 기간과 동일합니다. 계획 기간을 확인하세요'.
            LEAVE LIST-PROCESSING.
          ENDIF.

          IF ls_chk_2090-zspmon = gv_bgn_dt+0(6).
            MESSAGE s006 DISPLAY LIKE 'E' WITH '계획 시작일자가 확정된 시뮬레이션 시작과 동일합니다. 계획 기간을 확인하세요'.
            LEAVE LIST-PROCESSING.
          ENDIF.

          IF ls_chk_2090-zspmon > gv_bgn_dt+0(6).
            MESSAGE s006 DISPLAY LIKE 'E' WITH '계획 시작일자가 확정된 시뮬레이션 이전입니다. 계획 기간을 확인하세요'.
            LEAVE LIST-PROCESSING.
          ENDIF.

          IF ls_chk_2090-zepmon > gv_end_dt+0(6).
            MESSAGE s006 DISPLAY LIKE 'E' WITH '계획 종료일자가 확정된 시뮬레이션 기간에 포함됩니다. 계획 기간을 확인하세요'.
            LEAVE LIST-PROCESSING.
          ENDIF.
        ENDLOOP.
      ENDIF.

  ENDCASE.

  PERFORM get_main_data.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_screen_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_screen_100 CHANGING pv_chk_err.

  PERFORM set_fieldcat_0100 CHANGING pv_chk_err.
  CHECK pv_chk_err IS INITIAL.
  PERFORM make_itab_fr_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_main_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_main_data .

* 계획수립 작업장 마스터
  PERFORM  get_master.

  IF gt_arbpl[] IS INITIAL.
    MESSAGE s000 WITH '월간 생산 계획 설비(작업장)이 지정되지 않았습니다.' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CASE abap_true.
    WHEN p_rad1.
      PERFORM get_plan_data.
    WHEN p_rad2.
      IF gv_chk_include IS INITIAL.
        PERFORM set_disp_data_new.
      ELSE.
        PERFORM set_disp_data_include.
      ENDIF.
    WHEN p_rad3.
      PERFORM get_confirm_data.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_0100 CHANGING pv_chk_err.

  DATA : lt_fcat TYPE slis_t_fieldcat_alv.
  DATA : lv_col_pos TYPE i.
  DATA : lv_date TYPE sy-datum.
  DATA : lv_text(100).
  DATA : lv_chk_dt TYPE sy-datum.

  CLEAR : gv_bgn_dt, gv_end_dt.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = sy-repid
      i_internal_tabname = 'GS_MAIN_DATA'
      i_inclname         = 'ZGTPPR2080TOP'
      i_bypassing_buffer = 'X'
    CHANGING
      ct_fieldcat        = lt_fcat.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0100[]
    TABLES
      it_data         = gt_main_data.

* 필드 동적처리를 위해 시작일, 종료일 구해준다.
  PERFORM get_disp_data CHANGING gv_bgn_dt gv_end_dt pv_chk_err.
  CHECK pv_chk_err IS INITIAL.

  READ TABLE gt_fieldcat_0100 TRANSPORTING NO FIELDS WITH KEY fieldname = 'SUM_CHK'.
  IF sy-subrc NE 0.
    APPEND INITIAL LINE TO gt_fieldcat_0100 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    <ls_fcat>-col_pos = 2.
    <ls_fcat>-fieldname = 'SUM_CHK'.
    <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = <ls_fcat>-fieldname.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '1'.
    <ls_fcat>-no_out = abap_true.
  ENDIF.

  lv_col_pos = 100.

  lv_chk_dt = gv_bgn_dt.
  DO.
    IF lv_chk_dt > gv_end_dt.
      EXIT.
    ENDIF.

    APPEND INITIAL LINE TO gt_fieldcat_0100 ASSIGNING <ls_fcat>.
    ADD 1 TO lv_col_pos.
    <ls_fcat>-col_pos = lv_col_pos.
    <ls_fcat>-fieldname = lv_chk_dt.
    CLEAR lv_text.
    lv_text = lv_chk_dt+4(2) && '/' && lv_chk_dt+6(2).
    <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = lv_text.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '20'.
    <ls_fcat>-outputlen = '9'.
    <ls_fcat>-decimals_o = 0.
    <ls_fcat>-just = 'R'.

    APPEND INITIAL LINE TO gt_fieldcat_0100 ASSIGNING <ls_fcat>.
    ADD 1 TO lv_col_pos.
    <ls_fcat>-col_pos = lv_col_pos.
    <ls_fcat>-fieldname = lv_chk_dt && '_CHK'.
    <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = <ls_fcat>-fieldname.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '1'.
    <ls_fcat>-no_out = abap_true.

    ADD 1 TO lv_chk_dt.

  ENDDO.

* 필드명 서술
  LOOP AT gt_fieldcat_0100 ASSIGNING <ls_fcat>.
    CLEAR <ls_fcat>-key.
    CASE <ls_fcat>-fieldname.
      WHEN 'SEQNO_D'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'SEQNO'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'ARBPL' OR 'PLNID'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'KTEXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '설비(작업장)'(f01).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-fix_column = abap_true.
        <ls_fcat>-outputlen = '13'.
      WHEN 'SPEC'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '규격'(f02).
        <ls_fcat>-just = 'L'.
        <ls_fcat>-fix_column = abap_true.
        <ls_fcat>-outputlen = '18'.
      WHEN 'ZPJNO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '프로젝트 No.'(f03).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-fix_column = abap_true.
        <ls_fcat>-no_out = abap_true.
      WHEN 'ZPTXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '프로젝트 내역'(f22).
        <ls_fcat>-key = abap_true.
        <ls_fcat>-just = 'L'.
        <ls_fcat>-fix_column = abap_true.
        <ls_fcat>-outputlen = '15'.
      WHEN 'BASEMONTH'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매계획월'(f04).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-fix_column = abap_true.
      WHEN 'MEINS'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'QUANTITY_DP'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매계획'(f05).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-fix_column = abap_true.
        <ls_fcat>-qfieldname = 'MEINS'.
        <ls_fcat>-outputlen = '13'.
      WHEN 'MENGE'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '확정계획(OD)'(f19).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-fix_column = abap_true.
        <ls_fcat>-qfieldname = 'MEINS'.
        <ls_fcat>-outputlen = '13'.
      WHEN 'PLMNG'.
        IF p_rad3 IS INITIAL.
          <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '시뮬레이션'(f07).
        ELSE.
          <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '확정생산계획'(f06).
        ENDIF.
        <ls_fcat>-just = 'R'.
        <ls_fcat>-fix_column = abap_true.
        <ls_fcat>-qfieldname = 'MEINS'.
        <ls_fcat>-outputlen = '13'.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '완제품코드'(f08).
        <ls_fcat>-fix_column = abap_true.
        <ls_fcat>-just = 'C'.
        <ls_fcat>-outputlen = '10'.
      WHEN 'IDNRK'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '반제품코드'(f09).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-outputlen = '10'.
      WHEN 'DAY_PLMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '일생산량'(f20).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-fix_column = abap_true.
        <ls_fcat>-qfieldname = 'MEINS'.
        <ls_fcat>-outputlen = '9'.
      WHEN 'CHK_JOJANG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '조장구성'(f10).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-icon = abap_true.
    ENDCASE.
  ENDLOOP.

  SORT gt_fieldcat_0100 BY col_pos.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOOLBAR_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM toolbar_pros  USING    po_sender
                          po_object TYPE REF TO cl_alv_event_toolbar_set
                          r_interactive.

  CASE po_sender.
    WHEN go_grid_0100.
      CHECK gv_status_confirm IS INITIAL.

      PERFORM set_toolbar TABLES po_object->mt_toolbar
                        USING : 'SET_PLAN' icon_okay '판매계획지정' '판매계획지정' 0,
                                   'DEL_PLAN' icon_delete '판매계획제외' '판매계획제외' 0,
                                   '' '' '' '' 3,
                                   'CHG_IDNRK' icon_tools '계획자재변경' '계획자재변경' 0,
                                   'DEL_DAYS' icon_delete '일자별 계획삭제' '일자별 계획삭제' 0.

      IF p_rad1 = abap_true.
        PERFORM set_toolbar TABLES po_object->mt_toolbar
                   USING : '' '' '' '' 3,
                              'CRT_NEW' icon_create '버전신규생성' '버전신규생성' 0,
                              'CRT_COPIED' icon_system_copy '버전복사생성' '버전복사생성' 0.
      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> PO_OBJECT_>MT_TOOLBAR
*&---------------------------------------------------------------------*
FORM set_toolbar  TABLES  pt_toolbar STRUCTURE stb_button
               USING    pv_function
                           pv_icon
                           pv_text
                           pv_quickinfo
                           pv_butn_type.

  DATA : ls_toolbar  TYPE stb_button.

  CLEAR ls_toolbar.
  ls_toolbar-function  = pv_function.
  ls_toolbar-icon      = pv_icon.
  IF pv_text IS NOT INITIAL.
    CONCATENATE ' '  pv_text ' '  INTO ls_toolbar-text SEPARATED BY space.
  ENDIF.
  ls_toolbar-quickinfo = pv_quickinfo.
  ls_toolbar-butn_type = pv_butn_type.
  APPEND ls_toolbar TO pt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_PROS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM user_command_pros  USING    po_sender  TYPE REF TO cl_gui_alv_grid
                                 pv_ucomm.

  CASE po_sender.
    WHEN go_grid_0100.
      CASE pv_ucomm.
        WHEN 'SET_PLAN'. " 판매계획지정
          PERFORM proc_set_plan.
        WHEN 'DEL_PLAN'. " 판매계획제외
          PERFORM proc_del_plan.
        WHEN 'CHG_IDNRK'. " 계획자재변경
          PERFORM proc_chg_plan_matnr.
        WHEN 'DEL_DAYS'. " 일자별 계획삭제
          PERFORM proc_del_day_plan.
        WHEN 'A1'. " 생산(자동)
          PERFORM proc_auto_create_plan.
        WHEN 'A2'. " 생산(수동)
          PERFORM proc_manual_create_plan.
        WHEN 'A6'. "생산(수량입력)
          PERFORM proc_manual_use_input_plan.
        WHEN 'A3'. " 생산(청소)
          PERFORM proc_set_clean_plan.
        WHEN 'A4'. " 삭제
          PERFORM proc_del_selected_plan.
        WHEN 'A7'. " 라인삭제
          PERFORM proc_del_lines.
        WHEN 'A5'. " 수량변경
          PERFORM proc_chg_plmng_plan.
        WHEN 'CRT_NEW'. " 버전신규생성
          PERFORM proc_crt_new_ver.
        WHEN 'CRT_COPIED'. "버전복사생성
          PERFORM proc_crt_copy_ver.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_BGN_DT
*&      <-- LV_END_DT
*&---------------------------------------------------------------------*
FORM get_disp_data  CHANGING pv_bgn_dt TYPE sy-datum
                                               pv_end_dt  TYPE sy-datum
                                               pv_chk_err.

  DATA : lv_bgn_spmon TYPE spmon.
  DATA : lv_end_spmon TYPE spmon.

  CASE abap_true.
    WHEN  p_rad1. " 생산계획 조회시,
      SELECT SINGLE zspmon, zepmon
        FROM zgtppt2090
        WHERE werks = @p_werks
          AND spgcd = @p_spgcd
          AND simno = @p_simno
          AND simvr = @p_simvr
        INTO ( @lv_bgn_spmon, @lv_end_spmon ).
      IF lv_bgn_spmon IS INITIAL AND  lv_end_spmon IS INITIAL.
        pv_chk_err = abap_true.
        RETURN.
      ENDIF.

      pv_bgn_dt = lv_bgn_spmon && '01'.
      pv_end_dt = lv_end_spmon && '01'.
      PERFORM get_last_day_of_month CHANGING pv_end_dt.

    WHEN OTHERS. " 조회필드 년월기준 작성
      pv_bgn_dt = s_spmon-low && '01'.

      IF s_spmon-high IS INITIAL.
        pv_end_dt = s_spmon-low && '01'.
      ELSE.
        pv_end_dt = s_spmon-high && '01'.
      ENDIF.
      PERFORM get_last_day_of_month CHANGING pv_end_dt.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LAST_DAY_OF_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_END_DATE
*&---------------------------------------------------------------------*
FORM get_last_day_of_month  CHANGING pv_date TYPE sy-datum.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = pv_date
    IMPORTING
      last_day_of_month = pv_date
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  .
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ITAB_FR_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_itab_fr_fcat .

  FREE gt_main_disp_100.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      i_style_table             = abap_true
      it_fieldcatalog           = gt_fieldcat_0100
    IMPORTING
      ep_table                  = gt_main_disp_100
    EXCEPTIONS
      generate_subpool_dir_full = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2.
  IF sy-subrc <> 0.
    MESSAGE s005 DISPLAY LIKE 'E' WITH 'At Most 36 Subroutine Pools' 'Can Be Generated Temporarily'.
    LEAVE LIST-PROCESSING..
  ENDIF.

  ASSIGN gt_main_disp_100->* TO <gt_main_disp_100>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MASTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_master .

  DATA : lv_dispo TYPE marc-dispo.
  DATA : lt_date TYPE RANGE OF sy-datum.
  DATA : lv_chk_available.
  DATA : lv_chk_date TYPE sy-datum.
  DATA : lv_posnr TYPE posnr_va.

* 설비 마스터 정보
  SELECT a~gong_cd, a~seq, a~arbpl, c~ktext
      FROM zgtppt2110 AS a
      INNER JOIN crhd AS b ON b~arbpl = a~arbpl
                                   AND b~werks = a~werks
      INNER JOIN crtx AS c ON c~objty = b~objty
                                   AND c~objid = b~objid
    WHERE a~werks = @p_werks
       AND a~spgcd = @p_spgcd
       AND a~arbpl IN @s_arbpl
       AND b~objty = 'A'
       AND c~spras = @sy-langu
      INTO CORRESPONDING FIELDS OF TABLE @gt_arbpl.

  SORT gt_arbpl BY seq gong_cd arbpl.
  DELETE ADJACENT DUPLICATES FROM gt_arbpl COMPARING seq gong_cd arbpl.

* 비가동내역 마스터 정보
  SELECT *
    FROM zgtppt2130
    INTO CORRESPONDING FIELDS OF TABLE gt_2130
    WHERE werks = p_werks
       AND spgcd = p_spgcd
       AND datuv >= gv_bgn_dt
       AND datuv <= gv_end_dt.

* 선 스케줄링된 오더 조회후 설비별 가용일자 테이블 생성
* SPG 테이블 조회용 필드로 변경
  lv_dispo = p_spgcd && '%'. "

  SELECT * FROM zgtcvordsyval
     INTO TABLE @DATA(lt_order)
    WHERE werks EQ   @p_werks
         AND dispo  LIKE @lv_dispo
         AND pdcaproccode EQ 'INS'
         AND gstrp <= @gv_end_dt
         AND gltrp >= @gv_bgn_dt.

  SORT lt_order BY aufnr.
  DELETE ADJACENT DUPLICATES FROM lt_order COMPARING aufnr.

*  REFRESH GT_SCHEDULE.
*  LOOP AT LT_ORDER INTO DATA(LS_ORDER).
** 오더상태 체크 조회모드는 DLFL, CLSD, TECO 제외
*    LV_POSNR = LS_ORDER-POSNR + 0.
*    SELECT * FROM ZGTPPT2010
*      WHERE GONG_CD = 'INS'
*         AND ORDNR = @LS_ORDER-AUFNR
*         AND POSNR = @LV_POSNR
*         AND ORDTY = 'PRD'
*       INTO TABLE @DATA(LT_2010).
*    IF SY-SUBRC NE 0.
*      CONTINUE.
*    ENDIF.
*
*    PERFORM CATCH_AVAILABLE_ORDER  USING LS_ORDER-AUFNR CHANGING LV_CHK_AVAILABLE.
*    IF LV_CHK_AVAILABLE IS NOT INITIAL.
*      CONTINUE.
*    ENDIF.
*
*    CLEAR LV_CHK_DATE.
*    LV_CHK_DATE = LS_ORDER-GSTRP.
*    DO.
*      CLEAR GS_SCHEDULE.
*      GS_SCHEDULE-ARBPL = LS_ORDER-ARBPL.
*      GS_SCHEDULE-DATE = LV_CHK_DATE.
*      COLLECT GS_SCHEDULE INTO GT_SCHEDULE.
*
*      IF LV_CHK_DATE = LS_ORDER-GLTRP.
*        EXIT.
*      ELSE.
*        ADD 1 TO LV_CHK_DATE.
*      ENDIF.
*    ENDDO.
*
*  ENDLOOP.
*
*  DELETE GT_SCHEDULE WHERE DATE < GV_BGN_DT.
*  DELETE GT_SCHEDULE WHERE DATE > GV_END_DT.
*
*  SORT GT_SCHEDULE BY ARBPL DATE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_arbpl  USING  pv_dynprofld TYPE help_info-dynprofld.

  DATA : BEGIN OF ls_arbpl,
           seq     TYPE zgtppt2110-seq,
           gong_cd TYPE zgtppt2110-gong_cd,
           arbpl   TYPE zgtppt2110-arbpl,
           ktext   TYPE crtx-ktext,
         END OF ls_arbpl.
  DATA : lt_arbpl LIKE TABLE OF ls_arbpl.

  DATA : lt_return_tab TYPE TABLE OF ddshretval,
         ls_return_tab LIKE LINE OF lt_return_tab.

  DATA : lv_offset(6) TYPE n.
  DATA : lo_arbpl TYPE REF TO data.

  DATA : lt_field_tab TYPE TABLE OF dfies.
  DATA : lo_structdescr TYPE REF TO cl_abap_structdescr.

  DATA : lv_line       LIKE sy-stepl,
         lt_dynpfields LIKE TABLE OF dynpread.

  SORT lt_arbpl BY seq gong_cd arbpl.
  DELETE ADJACENT DUPLICATES FROM lt_arbpl COMPARING seq gong_cd arbpl.

  IF sy-dynnr = '1000'.
    PERFORM get_dynp_value USING 'P_WERKS'.
    PERFORM get_dynp_value USING 'P_SPGCD'.
  ENDIF.

  SELECT a~gong_cd, a~seq, a~arbpl, c~ktext
      FROM zgtppt2110 AS a
      INNER JOIN crhd AS b ON b~arbpl = a~arbpl
                                   AND b~werks = a~werks
      INNER JOIN crtx AS c ON c~objty = b~objty
                                   AND c~objid = b~objid
    WHERE a~werks = @p_werks
       AND a~spgcd = @p_spgcd
       AND b~objty = 'A'
       AND c~spras = @sy-langu
      INTO CORRESPONDING FIELDS OF TABLE @lt_arbpl.

  SORT lt_arbpl BY seq gong_cd arbpl.
  DELETE ADJACENT DUPLICATES FROM lt_arbpl COMPARING seq gong_cd arbpl.

  FREE lo_arbpl.
  CREATE DATA lo_arbpl LIKE ls_arbpl.

  lo_structdescr ?= cl_abap_structdescr=>describe_by_data_ref( lo_arbpl ).
  lt_field_tab = cl_salv_data_descr=>read_structdescr( lo_structdescr ).

  CLEAR lv_offset.
  LOOP AT lt_field_tab ASSIGNING FIELD-SYMBOL(<ls_field_tab>).

    CASE <ls_field_tab>-fieldname.
      WHEN 'SEQ'.
        <ls_field_tab>-reptext  = '순번'.
      WHEN 'GONG_CD'.
        <ls_field_tab>-reptext  = '공정코드'.
      WHEN 'ARBPL'.
        <ls_field_tab>-reptext  = '설비(작업장) 코드'.
      WHEN 'KTEXT'.
        <ls_field_tab>-reptext  = '설비(작업장)'.
    ENDCASE.

    <ls_field_tab>-offset = lv_offset.
    lv_offset = lv_offset + <ls_field_tab>-intlen.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      retfield        = 'ARBPL'
      dynprofield     = pv_dynprofld           "F4누른 필드->DEPT_CD
      value_org       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      window_title    = '설비(작업장) 내역'   "Search Help 타이틀
      display         = 'F'
    TABLES
      field_tab       = lt_field_tab
      value_tab       = lt_arbpl                  "부서코드, 부서명 가져온 인터널 테이블
      return_tab      = lt_return_tab            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  READ TABLE lt_return_tab INTO ls_return_tab INDEX 1.
  IF sy-subrc EQ 0.
    READ TABLE lt_arbpl INTO ls_arbpl WITH KEY arbpl = ls_return_tab-fieldval.
    IF sy-subrc EQ 0.
      ASSIGN (pv_dynprofld) TO FIELD-SYMBOL(<lv_value>).
      <lv_value> = ls_return_tab-fieldval.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_OBLIGATORY_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_obligatory_field .

  CASE abap_true.
    WHEN p_rad1.
      IF p_simno IS INITIAL.
        MESSAGE s005 DISPLAY LIKE 'E' WITH '시뮬레이션번호'(004) '는(은) 필수 필드입니다.'(e01).
        LEAVE LIST-PROCESSING.
      ENDIF.
    WHEN p_rad2.
      IF p_newnm IS INITIAL.
        MESSAGE s005 DISPLAY LIKE 'E' WITH '시뮬레이션 명'(e02) '는(은) 필수 필드입니다.'(e01).
        LEAVE LIST-PROCESSING.
      ENDIF.
      IF s_spmon[] IS INITIAL.
        MESSAGE s005 DISPLAY LIKE 'E' WITH '계획기간(월)'(e03) '는(은) 필수 필드입니다.'(e01).
        LEAVE LIST-PROCESSING.
      ENDIF.
    WHEN p_rad3.
      IF s_spmon[] IS INITIAL.
        MESSAGE s005 DISPLAY LIKE 'E' WITH '계획기간(월)'(e03) '는(은) 필수 필드입니다.'(e01).
        LEAVE LIST-PROCESSING.
      ENDIF.
  ENDCASE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_DATA_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_disp_data_new .

  REFRESH <gt_main_disp_100>.

  LOOP AT gt_arbpl INTO gs_arbpl.
    CLEAR gs_main_data.
    APPEND INITIAL LINE TO <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_main>).
    MOVE-CORRESPONDING gs_arbpl TO gs_main_data.
    gs_main_data-seqno = gs_arbpl-seq.
    MOVE-CORRESPONDING gs_main_data TO <ls_main>.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM disp_process .
  CALL SCREEN '0100'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  IF p_rad3 EQ abap_true.
    SET PF-STATUS '0101'.
  ELSE.
    SET PF-STATUS '0100'.
  ENDIF.

  CLEAR gv_title.
  CASE abap_true.
    WHEN p_rad1.
      gv_title = TEXT-007.
    WHEN p_rad2.
      gv_title = TEXT-008.
    WHEN p_rad3.
      gv_title = TEXT-009.
  ENDCASE.
  SET TITLEBAR '0100' WITH gv_title.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CLEAR gv_ok_code.
  gv_ok_code = sy-ucomm.

  CASE gv_ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF gv_chk_edit IS NOT INITIAL.
        CLEAR gv_answer.
        PERFORM popup_to_confirm_step USING 'N'
          ' '
          '수정중인 작업이 있습니다. 종료 하시겠습니까?'
          '종료확인'.
        IF gv_answer NE 'J'.
          MESSAGE s003 DISPLAY LIKE 'E' WITH '종료 취소 되었습니다.'.
          RETURN.
        ENDIF.
      ENDIF.

*     종료
      CALL METHOD go_docking_0100->free.

      FREE : go_docking_0100, go_splitter_0100.
      FREE : go_contain_0100, go_contain_top_0100.
      FREE : go_grid_0100.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      IF gv_status_confirm = abap_true.
        MESSAGE s005 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션 입니다.'(e25) '확정 취소 후 저장 할 수 있습니다.'(e26).
        RETURN.
      ENDIF.

      IF gv_chk_edit IS INITIAL.
        MESSAGE s005 DISPLAY LIKE 'E' WITH '변경 내역이 없습니다.'(e27).
        RETURN.
      ENDIF.

      CLEAR gv_answer.
      PERFORM popup_to_confirm_step USING 'N'
        ' '
        '월간 생산 계획을 등록하시겠습니까?'
        '저장확인'.
      IF gv_answer NE 'J'.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '저장 취소 되었습니다.'.
        RETURN.
      ENDIF.

      PERFORM save_data USING 'U'.
    WHEN 'COMP'. "버전비교
      SUBMIT zgtppr2090 VIA SELECTION-SCREEN
                                  WITH p_werks = p_werks
                                  WITH p_spgcd = p_spgcd
                                  WITH p_simno = gv_simno
                                  WITH p_simnm = gv_simnm
                                  WITH p_simvr = gv_simvr
                                  WITH p_colled = abap_true
                                  AND RETURN.

    WHEN 'CONFIRM'. " 확정
      IF gv_chk_edit IS NOT INITIAL OR gt_2090[] IS INITIAL.
        MESSAGE s005 DISPLAY LIKE 'E' WITH '월간 생산계획을 저장한 후, 계획 확정을 진행할 수 있습니다.'.
        RETURN.
      ENDIF.

      PERFORM proc_confirm_process.

    WHEN 'REJECT'. " 확정취소
      IF gv_status_confirm NE abap_true.
        MESSAGE s005 DISPLAY LIKE 'E' WITH '확정되지 않은 시뮬레이션 입니다. 확정취소 할 수 없습니다.'(e36).
        RETURN.
      ENDIF.

      CLEAR gv_answer.
      PERFORM popup_to_confirm_step USING 'N'
        ' '
        '월간생산계획확정을 취소하시겠습니까?'
        '취소확인'.
      IF gv_answer NE 'J'.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
        RETURN.
      ENDIF.

      PERFORM proc_reject.
    WHEN 'DEL_SIMUL'.
      CLEAR gv_text.
      CONCATENATE gv_simnm 'Ver.' gv_simvr  '생산계획이 삭제됩니다. 진행하시겠습니까?'    INTO gv_text SEPARATED BY space.

      CLEAR gv_answer.
      PERFORM popup_to_confirm_step USING 'N'
        ' '
        gv_text
        '삭제확인'.
      IF gv_answer NE 'J'.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
        RETURN.
      ENDIF.

      IF gv_simno IS NOT INITIAL.
        DELETE FROM zgtppt2090 WHERE werks = p_werks
                                               AND spgcd = p_spgcd
                                               AND simno = gv_simno
                                               AND simvr = gv_simvr.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE s003 DISPLAY LIKE 'E' WITH '생산계획삭제중 오류 발생하였습니다.'(e41).
          RETURN.
        ENDIF.

        DELETE FROM zgtppt2091 WHERE werks = p_werks
                                               AND spgcd = p_spgcd
                                               AND simno = gv_simno
                                               AND simvr = gv_simvr.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          MESSAGE s003 DISPLAY LIKE 'E' WITH '생산계획삭제중 오류 발생하였습니다.'(e41).
          RETURN.
        ENDIF.

        COMMIT WORK AND WAIT.
        MESSAGE s006 WITH gv_simnm 'Ver.' gv_simvr '생산계획이 삭제되었습니다.'.
      ENDIF.

*     종료
      CALL METHOD go_docking_0100->free.

      FREE : go_docking_0100, go_splitter_0100.
      FREE : go_contain_0100, go_contain_top_0100.
      FREE : go_grid_0100.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.

    WHEN 'REFRESH'.

      IF gv_chk_edit IS NOT INITIAL.
        CLEAR gv_answer.
        PERFORM popup_to_confirm_step USING 'N'
          ' '
          '수정중인 작업이 있습니다. 진행 하시겠습니까?'
          'Refresh 확인'.
        IF gv_answer NE 'J'.
          MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
          RETURN.
        ENDIF.
      ENDIF.

      CLEAR gv_chk_edit.
      PERFORM get_main_data.
      PERFORM refresh_0100.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm_step
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM popup_to_confirm_step  USING lp_opt
                                  lp_text1
                                  lp_text2
                                  lp_title.
  CLEAR gv_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption  = lp_opt
      textline1      = lp_text1
      textline2      = lp_text2
      titel          = lp_title
      cancel_display = ''
    IMPORTING
      answer         = gv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_0100 OUTPUT.

  IF go_grid_0100 IS NOT BOUND.
    PERFORM set_object_grid_0100.
    PERFORM event_handler_register USING go_grid_0100.
    PERFORM set_layout_grid_0100.
    PERFORM set_cell_attribute_grid_0100.
    PERFORM exclude_of_toolbar_grid_0100.
    PERFORM set_sorttab_grid_0100.
    PERFORM call_grid_0100_display.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0100 .

  CREATE OBJECT go_docking_0100
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
*화면 분할
  CREATE OBJECT go_splitter_0100
    EXPORTING
      parent  = go_docking_0100
      rows    = 2
      columns = 1.

  IF p_rad3 = abap_true.
    go_splitter_0100->set_row_height(
      EXPORTING
        id                =    1              " Row ID
        height            =    0 ).             " Height
  ELSE.
    go_splitter_0100->set_row_height(
      EXPORTING
        id                =    1              " Row ID
        height            =    10 ).             " Height
  ENDIF.
** top 컨테이너
  CALL METHOD go_splitter_0100->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_contain_top_0100.

* bottom 컨테이너
  CALL METHOD go_splitter_0100->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_contain_0100.

  CREATE OBJECT go_grid_0100
    EXPORTING
      i_parent      = go_contain_0100
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM event_handler_register  USING    po_grid TYPE REF TO cl_gui_alv_grid.

  IF go_event_handler IS NOT BOUND.
    CREATE OBJECT go_event_handler.
  ENDIF.

*// Event Handler ##
  CASE po_grid.
    WHEN go_grid_0100.
      SET HANDLER go_event_handler->handle_top_of_page          FOR po_grid.
      SET HANDLER go_event_handler->handle_toolbar               FOR po_grid.
      SET HANDLER go_event_handler->handle_user_command          FOR po_grid.
      SET HANDLER go_event_handler->handle_double_click          FOR po_grid.
      SET HANDLER go_event_handler->handle_context_menu          FOR po_grid.
    WHEN go_grid_0200.
      SET HANDLER go_event_handler->handle_data_changed          FOR po_grid.
    WHEN go_grid_0300.
      SET HANDLER go_event_handler->handle_top_of_page          FOR po_grid.
      SET HANDLER go_event_handler->handle_double_click          FOR po_grid.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONTEXT_MENU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM context_menu  USING    p_sender TYPE REF TO cl_gui_alv_grid
                                         p_object TYPE REF TO cl_ctmenu.

  DATA: lt_std_fcodes TYPE ui_functions,
        lt_own_fcodes TYPE ui_functions.
  DATA : lv_text TYPE gui_text.

  DATA : lv_row TYPE i.
  DATA : ls_col_id TYPE lvc_s_col.

  go_grid_0100->get_current_cell(
    IMPORTING
      e_row     =  lv_row                " Row on Grid
      es_col_id =  ls_col_id ).               " colum ID

  IF lv_row = 0.
    RETURN.
  ENDIF.

  p_object->clear( ).
  CHECK gv_status_confirm IS INITIAL.
  CHECK p_rad3 IS INITIAL.

* 생산(자동)
  CLEAR lv_text.
  lv_text = '생산(Full)'.
  CALL METHOD p_object->add_function
    EXPORTING
      fcode = 'A1'
      text  = lv_text.
* 생산(수동)
  lv_text = '생산(선택)'.
  CALL METHOD p_object->add_function
    EXPORTING
      fcode = 'A2'
      text  = lv_text.

* 생산(수동)
  lv_text = '생산(수량입력)'.
  CALL METHOD p_object->add_function
    EXPORTING
      fcode = 'A6'
      text  = lv_text.

* 청소
  lv_text = '청소'.
  CALL METHOD p_object->add_function
    EXPORTING
      fcode = 'A3'
      text  = lv_text.
* 분리자
  p_object->add_separator( ).
* 삭제
  lv_text = '삭제'.
  CALL METHOD p_object->add_function
    EXPORTING
      fcode = 'A4'
      text  = lv_text.

* 삭제
  lv_text = '라인삭제'.
  CALL METHOD p_object->add_function
    EXPORTING
      fcode = 'A7'
      text  = lv_text.
* 분리자
  p_object->add_separator( ).
* 수량변경
  lv_text = '수량변경'.
  CALL METHOD p_object->add_function
    EXPORTING
      fcode = 'A5'
      text  = lv_text.

  CALL METHOD p_object->show_functions
    EXPORTING
      fcodes = lt_own_fcodes.

  CALL METHOD cl_gui_cfw=>flush.


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
*  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
*  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
  gs_layout_0100-stylefname = 'XYZSTYLEZYX'.
  gs_layout_0100-no_rowmark  = abap_true.
  gs_layout_0100-sel_mode  = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0100 .

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.
  DATA : lv_chk_date TYPE sy-datum.
  DATA : lv_fieldname TYPE fieldname.
  DATA : lv_fieldname2 TYPE fieldname.
  FIELD-SYMBOLS : <lv_day_value> TYPE any.
  FIELD-SYMBOLS : <lv_day_chk> TYPE any.
  FIELD-SYMBOLS : <lv_sum_chk> TYPE any.
  FIELD-SYMBOLS <lt_celltab> TYPE any.

  DEFINE __get_day_field.

*  날짜별 수량 필드
    CLEAR lv_fieldname.
    lv_fieldname = &1.
    IF <lv_day_value> IS ASSIGNED. UNASSIGN <lv_day_value>. ENDIF.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_data> TO <lv_day_value>.

*  날짜별 체크필드
    CLEAR lv_fieldname2.
    lv_fieldname2 = &1 && '_CHK'.
    IF <lv_day_chk> IS ASSIGNED. UNASSIGN <lv_day_chk>. ENDIF.
    ASSIGN COMPONENT lv_fieldname2 OF STRUCTURE <ls_data> TO <lv_day_chk>.

  END-OF-DEFINITION.



  LOOP AT <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_data>).
    REFRESH lt_celltab.

    IF <lv_sum_chk> IS ASSIGNED. UNASSIGN <lv_sum_chk>. ENDIF.
    ASSIGN COMPONENT 'SUM_CHK' OF STRUCTURE <ls_data> TO <lv_sum_chk>.
    IF <lv_sum_chk> = abap_true. " 섬 필드 노란색으로 적용.
      LOOP AT gt_fieldcat_0100 ASSIGNING FIELD-SYMBOL(<ls_fcat>) WHERE no_out IS INITIAL.
        CLEAR ls_celltab.
        ls_celltab-fieldname = <ls_fcat>-fieldname.
        ls_celltab-style = alv_style_color_int_total.
        INSERT ls_celltab INTO TABLE lt_celltab.
      ENDLOOP.
    ELSE.

      LOOP AT gt_fieldcat_0100 ASSIGNING <ls_fcat>.
        CASE <ls_fcat>-fieldname.
          WHEN 'KTEXT' OR 'SPEC' OR 'ZPJNO' OR 'BASEMONTH' OR 'QUANTITY_DP'
            OR 'MENGE' OR 'PLMNG' OR 'DAY_PLMNG' OR 'MATNR'.
            CLEAR ls_celltab.
            ls_celltab-fieldname = <ls_fcat>-fieldname.
            ls_celltab-style = alv_style_color_int_key.
            INSERT ls_celltab INTO TABLE lt_celltab.
*          WHEN 'DAY_PLMNG'.
*            CLEAR LS_CELLTAB.
*            LS_CELLTAB-FIELDNAME = <LS_FCAT>-FIELDNAME.
*            LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INV_TOTAL.
*            INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        ENDCASE.
      ENDLOOP.

      lv_chk_date = gv_bgn_dt.
      DO.
        IF lv_chk_date > gv_end_dt.
          EXIT.
        ENDIF.
        __get_day_field lv_chk_date.

        CASE <lv_day_chk>.
          WHEN 'N'.  " 정상
          WHEN 'U'.  " 수량 업 레드
            CLEAR ls_celltab.
            ls_celltab-fieldname = lv_fieldname.
            ls_celltab-style = alv_style_color_int_negative.
            INSERT ls_celltab INTO TABLE lt_celltab.
          WHEN 'D'. "수량 적은 LOW
            CLEAR ls_celltab.
            ls_celltab-fieldname = lv_fieldname.
            ls_celltab-style = alv_style_color_int_heading.
            INSERT ls_celltab INTO TABLE lt_celltab.
          WHEN 'C'. "청소
            CLEAR ls_celltab.
            ls_celltab-fieldname = lv_fieldname.
            ls_celltab-style = alv_style_color_inv_total + alv_style_align_center_top.
            INSERT ls_celltab INTO TABLE lt_celltab.
          WHEN 'X'. " 비가동내역
            CLEAR ls_celltab.
            ls_celltab-fieldname = lv_fieldname.
            ls_celltab-style = alv_style_color_int_group + alv_style_align_center_top.
            INSERT ls_celltab INTO TABLE lt_celltab.
          WHEN 'S'. " 조장 스케줄링 된 필드
            CLEAR ls_celltab.
            ls_celltab-fieldname = lv_fieldname.
            ls_celltab-style = alv_style_color_int_positive.
            INSERT ls_celltab INTO TABLE lt_celltab.
          WHEN 'T'. " 조장 스케줄링 된 필드
            CLEAR ls_celltab.
            ls_celltab-fieldname = lv_fieldname.
            ls_celltab-style = alv_style_color_int_positive + alv_style_align_center_top.
            INSERT ls_celltab INTO TABLE lt_celltab.
        ENDCASE.
        ADD 1 TO lv_chk_date.
      ENDDO.
    ENDIF.

    IF <lt_celltab> IS ASSIGNED. UNASSIGN <lt_celltab>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <ls_data> TO <lt_celltab>.
    IF <lt_celltab> IS ASSIGNED.
      <lt_celltab> = lt_celltab.
    ENDIF.

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
                cl_gui_alv_grid=>mc_fc_average,
                cl_gui_alv_grid=>mc_fc_deselect_all,
                cl_gui_alv_grid=>mc_fc_detail,
                cl_gui_alv_grid=>mc_fc_select_all,
                cl_gui_alv_grid=>mc_fc_delete_filter,
                cl_gui_alv_grid=>mc_fc_filter,
                cl_gui_alv_grid=>mc_fc_sort_asc,
                cl_gui_alv_grid=>mc_fc_sort_dsc,
                cl_gui_alv_grid=>mc_fc_subtot,
                cl_gui_alv_grid=>mc_fc_sum,
                cl_gui_alv_grid=>mc_fc_average,
                cl_gui_alv_grid=>mc_fg_sort,
                cl_gui_alv_grid=>mc_mb_sum,
*                CL_GUI_ALV_GRID=>MC_MB_VARIANT,
                cl_gui_alv_grid=>mc_mb_view,
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
*& Form SET_SORTTAB_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sorttab_grid_0100 .

* ALV소트 사용 안함.
  PERFORM set_sort_tab TABLES gt_sort_0100
                                  USING : 1 'SEQNO'  'X' '' '',
                                             2 'SUM_CHK'  'X' '' '',
                                             3 'SEQNO_D'  'X' '' '',
                                             4 'KTEXT'  'X' '' '',
                                             5 'SPEC'  'X' '' '',
                                             6 'ZPJNO'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort_tab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SORT_0100
*&      --> P_1
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_sort_tab  TABLES   pt_sorttab STRUCTURE lvc_s_sort
                   USING    pv_pos
                               pv_fieldname
                               pv_up
                               pv_down
                               pv_subtot.

  DATA : ls_sort TYPE lvc_s_sort.
  ls_sort-spos = pv_pos.
  ls_sort-fieldname = pv_fieldname.
  ls_sort-up = pv_up.
  ls_sort-down = pv_down.
  ls_sort-subtot =  pv_subtot.
  APPEND ls_sort TO pt_sorttab.

ENDFORM.
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
      it_outtab            = <gt_main_disp_100>
      it_sort              = gt_sort_0100
      it_fieldcatalog      = gt_fieldcat_0100.

  IF go_dd_docu_0100 IS BOUND.
    CALL METHOD go_dd_docu_0100->initialize_document.
  ELSE.
    CREATE OBJECT go_dd_docu_0100
      EXPORTING
        style = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD go_grid_0100->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = go_dd_docu_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM alv_top_of_page  USING    po_sender TYPE REF TO cl_gui_alv_grid
                                CHANGING    po_dyndoc_id  TYPE REF TO  cl_dd_document.

  CASE po_sender.
    WHEN go_grid_0100.
      CASE abap_true.
        WHEN p_rad1.
          PERFORM set_title_crt_simul CHANGING po_dyndoc_id.
        WHEN p_rad2.
          PERFORM set_title_crt_simul CHANGING po_dyndoc_id.
        WHEN p_rad3.
          PERFORM set_title_disp_confirm CHANGING po_dyndoc_id.
      ENDCASE.
    WHEN go_grid_0300.
      PERFORM set_title_0300 CHANGING po_dyndoc_id.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_DISP_SIMUL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PO_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM set_title_disp_simul  CHANGING po_dyndoc_id  TYPE REF TO  cl_dd_document.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_CRT_SIMUL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PO_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM set_title_crt_simul  CHANGING po_dyndoc_id  TYPE REF TO  cl_dd_document.

  DATA : lv_text(255) TYPE c.
  DATA : lv_version(15) .
  DATA : lv_ver(3) TYPE n.
  DATA : lv_fr_spmon(10).
  DATA : lv_to_spmon(10).

* 플랜트명
  CLEAR lv_text.
  IF p_name1 IS INITIAL.
    SELECT SINGLE name1 INTO p_name1
             FROM t001w
            WHERE werks EQ p_werks.
  ENDIF.
  IF p_descr IS INITIAL.
    SELECT SINGLE descr INTO p_descr
         FROM zppt0107
        WHERE spgcd EQ p_spgcd.
  ENDIF.

  lv_text = p_name1 && '(' && p_descr && ')'.
  CONCATENATE '플랜트 :' lv_text INTO lv_text SEPARATED BY space.

  "텍스트 추가
  CALL METHOD po_dyndoc_id->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = '20'.

  CALL METHOD po_dyndoc_id->new_line.

* 시뮬레이션 "
  CLEAR lv_text.
  lv_text = gv_simnm && '(' && gv_bgn_dt+0(4) &&'.' && gv_bgn_dt+4(2) && ')'.

  lv_version = 'ver.' && gv_simvr.

  CONCATENATE '시뮬레이션 :' lv_text lv_version INTO lv_text SEPARATED BY space.

  IF gv_status_confirm = abap_true.
    CONCATENATE lv_text '*확정*' INTO lv_text SEPARATED BY space.
  ENDIF.

  "텍스트 추가
  CALL METHOD po_dyndoc_id->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = '20'.

  CALL METHOD po_dyndoc_id->new_line.

* 기간
  CLEAR lv_text.
  IF gv_bgn_dt+0(6) = gv_end_dt+0(6).
    lv_fr_spmon = gv_bgn_dt+0(4) &&'.' && gv_bgn_dt+4(2).
    CONCATENATE '기간 :' lv_fr_spmon INTO lv_text SEPARATED BY space.
  ELSE.
    .lv_fr_spmon = gv_bgn_dt+0(4) &&'.' && gv_bgn_dt+4(2).
    .lv_to_spmon = gv_end_dt+0(4) &&'.' && gv_end_dt+4(2).
    CONCATENATE '기간 :' lv_fr_spmon '~' lv_to_spmon INTO lv_text SEPARATED BY space.
  ENDIF.
  "텍스트 추가
  CALL METHOD po_dyndoc_id->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = '20'.

  CALL METHOD po_dyndoc_id->new_line.

*  IF GO_CONTAIN_TOP_0100 IS BOUND.
*    GO_CONTAIN_TOP_0100->FREE( ).
*  ENDIF.
*
** top 컨테이너
*  CALL METHOD GO_SPLITTER_0100->GET_CONTAINER
*    EXPORTING
*      ROW       = 1
*      COLUMN    = 1
*    RECEIVING
*      CONTAINER = GO_CONTAIN_TOP_0100.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD po_dyndoc_id->display_document
    EXPORTING
      parent             = go_contain_top_0100
      reuse_control      = abap_true
      reuse_registration = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_DISP_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PO_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM set_title_disp_confirm  CHANGING po_dyndoc_id  TYPE REF TO  cl_dd_document.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SET_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_set_plan .

  DATA : lt_2080 TYPE TABLE OF zgtppt2080.
  DATA : lv_idx TYPE i.
  DATA : lt_cells TYPE lvc_t_ceno.

  DATA : BEGIN OF ls_collect_2090,
           plnid TYPE zgtppt2090-plnid,
           plmng TYPE zgtppt2091-plmng,
         END OF ls_collect_2090.
  DATA : lt_collect_2090 LIKE TABLE OF ls_collect_2090.
  DATA : lv_plmng TYPE zgtppt2091-plmng.
  DATA : lv_zpjno TYPE zsd0106t-zpjno.


  IF gv_status_confirm = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션으로 수정할 수 없습니다.'(e09).
    RETURN.
  ENDIF.

  go_grid_0100->get_selected_cells_id(
    IMPORTING
     et_cells = lt_cells ).                " Cell IDs

  IF lt_cells[] IS NOT INITIAL.
    READ TABLE lt_cells INTO DATA(ls_cells) INDEX 1.
    READ TABLE <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX ls_cells-row_id.
    CLEAR gs_main_data.
    MOVE-CORRESPONDING <ls_main> TO gs_main_data.
    IF gs_main_data-sum_chk IS INITIAL.
      gs_200_top-arbpl = gs_main_data-arbpl.
      gs_200_top-ktext = gs_main_data-ktext.

    ENDIF.
  ENDIF.

  REFRESH gt_disp_plan.

*  생산계획을 수립할 판매계획 조회( 추출 기준 월간 생산계획 -> 판매계획 조회 -> 확정수량 조회
  SELECT a~* FROM zgtppt2080 AS a
    INTO CORRESPONDING FIELDS OF TABLE @lt_2080
  WHERE a~werks = @p_werks
       AND a~spgcd = @p_spgcd
       AND a~plnid IN ( SELECT DISTINCT plnid
                             FROM zgtppt2080 AS b
                             WHERE b~cycltype = a~cycltype
                                 AND b~vkbur = a~vkbur
                                 AND b~spec = a~spec
                                 AND b~zpjno = a~zpjno  )
      AND a~delfl <> @abap_true.

* 판매계획 대상 조회
  DATA(lt_chk_2080) = lt_2080.
  SORT lt_chk_2080 BY cycltype vkbur spec zpjno vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_2080 COMPARING cycltype vkbur spec zpjno vbeln posnr.

* SRM2603-10362판매계획 조회를 위해서 추가
  DATA(lt_temp_2080) = lt_chk_2080.
  SORT lt_temp_2080 BY cycltype vkbur spec zpjno.
  DELETE ADJACENT DUPLICATES FROM lt_temp_2080 COMPARING cycltype vkbur spec zpjno.

  IF lt_temp_2080[] IS NOT INITIAL.
    SELECT * FROM zgtcvsalesplan
        FOR ALL ENTRIES IN @lt_temp_2080
      WHERE cycltype = @lt_temp_2080-cycltype
         AND vkbur = @lt_temp_2080-vkbur
         AND spec = @lt_temp_2080-spec
         AND zpjno = @lt_temp_2080-zpjno

      INTO TABLE @DATA(lt_salesplan).
  ENDIF.
*SRM2603-10362

  SORT lt_salesplan BY cycltype vkbur spec zpjno vbeln posnr.

* 확정대상 조회
  DATA(lt_chk_conf) = lt_2080.
  SORT lt_chk_conf BY werks spgcd plnid.
  DELETE ADJACENT DUPLICATES FROM lt_chk_conf COMPARING werks spgcd plnid.
  IF lt_chk_conf[] IS NOT INITIAL.
    SELECT a~plnid, a~simno, a~simvr, a~arbpl, a~pldat, b~matnr, b~idnrk, a~plmng
      FROM zgtppt2091 AS a
      INNER JOIN zgtppt2090 AS b ON b~simno = a~simno
                                            AND b~simvr = a~simvr
                                            AND b~plnid = a~plnid
      FOR ALL ENTRIES IN @lt_chk_conf
     WHERE a~werks = @lt_chk_conf-werks
       AND a~spgcd = @lt_chk_conf-spgcd
       AND a~plnid = @lt_chk_conf-plnid
       AND a~pldat < @gv_bgn_dt   " 시뮬레이션 기준 월도 확정수량은 포함안함
       AND b~plcnf = @abap_true
       AND b~simty IN @gr_simty " 동일한 시뮬레이션 타입끼리 비교
       AND a~pltype = '01'
      INTO TABLE @DATA(lt_2090).

    LOOP AT lt_2090 INTO DATA(ls_2090).
      CLEAR ls_collect_2090.
      MOVE-CORRESPONDING ls_2090 TO ls_collect_2090.
      COLLECT ls_collect_2090 INTO lt_collect_2090.
    ENDLOOP.
  ENDIF.

*  REFRESH LT_CHK_CONF.

* 모인데이터 수량 콜렉트
  LOOP AT lt_chk_conf INTO DATA(ls_chk_conf).
    CLEAR gs_disp_plan.

    REFRESH lt_chk_2080.
    lt_chk_2080 = VALUE #( FOR lw_2080 IN lt_2080 WHERE ( plnid = ls_chk_conf-plnid )
                                                                             ( CORRESPONDING #( lw_2080 ) ) ).

*   판매수량
    CLEAR lv_idx.
    LOOP AT lt_chk_2080 INTO DATA(ls_chk_2080).
      READ TABLE lt_salesplan INTO DATA(ls_salesplan) WITH KEY cycltype = ls_chk_2080-cycltype
                                                                                         vkbur = ls_chk_2080-vkbur
                                                                                         spec = ls_chk_2080-spec
                                                                                         zpjno = ls_chk_2080-zpjno
                                                                                         vbeln = ls_chk_2080-vbeln
                                                                                         posnr = ls_chk_2080-posnr
                                                                                         BINARY SEARCH.
      IF sy-subrc EQ 0.
        ADD 1 TO lv_idx.
        IF lv_idx = 1.
          gs_disp_plan-plnid = ls_chk_conf-plnid.
          gs_disp_plan-spec = ls_chk_2080-spec.
          gs_disp_plan-zpjno = ls_chk_2080-zpjno.
* 프로젝트내역 추가
          IF ls_salesplan-zptxt IS INITIAL AND ls_salesplan-zpjno IS NOT INITIAL.
            TRY.
                CLEAR lv_zpjno.
                lv_zpjno = ls_salesplan-zpjno && '%'.
                SELECT SINGLE zptxt FROM zsd0106t
                  INTO gs_disp_plan-zptxt
                  WHERE zpjno LIKE lv_zpjno
                    AND spart = ls_salesplan-spart.

              CATCH cx_root.
            ENDTRY.
          ELSE.
            gs_disp_plan-zptxt = ls_salesplan-zptxt.
          ENDIF.

          gs_disp_plan-spmon = ls_salesplan-basemonth.
          gs_disp_plan-kunnr = ls_salesplan-kunnr.
          IF ls_salesplan-kunnr IS NOT INITIAL.
            SELECT SINGLE name1 FROM kna1
                INTO gs_disp_plan-name1
              WHERE kunnr = ls_salesplan-kunnr
                AND spras = sy-langu.
          ENDIF.
          gs_disp_plan-meins = ls_chk_2080-meins.
          gs_disp_plan-matnr = ls_chk_2080-matnr.
          gs_disp_plan-sul_no = ls_chk_2080-sul_no.
        ENDIF.
*SRM2603-13210 FT단위 환산 처리
        IF ls_chk_2080-meins NE ls_salesplan-vrkme.

          PERFORM unit_conversion USING ls_chk_2080-meins
                                                                 ls_salesplan-vrkme
                                                       CHANGING ls_salesplan-quantity_dp.

        ENDIF.
*SRM2603-13210
        gs_disp_plan-quantity_dp = gs_disp_plan-quantity_dp + ls_salesplan-quantity_dp.
      ELSE.
        READ TABLE lt_salesplan INTO ls_salesplan WITH KEY cycltype = ls_chk_2080-cycltype
                                                                                         vkbur = ls_chk_2080-vkbur
                                                                                         spec = ls_chk_2080-spec
                                                                                         zpjno = ls_chk_2080-zpjno.
        IF sy-subrc EQ 0.
          ADD 1 TO lv_idx.
          IF lv_idx = 1.
            gs_disp_plan-plnid = ls_chk_conf-plnid.
            gs_disp_plan-spec = ls_chk_2080-spec.
            gs_disp_plan-zpjno = ls_chk_2080-zpjno.
* 프로젝트내역 추가
            IF ls_salesplan-zptxt IS INITIAL AND ls_salesplan-zpjno IS NOT INITIAL.
              TRY.
                  CLEAR lv_zpjno.
                  lv_zpjno = ls_salesplan-zpjno && '%'.
                  SELECT SINGLE zptxt FROM zsd0106t
                    INTO gs_disp_plan-zptxt
                    WHERE zpjno LIKE lv_zpjno
                      AND spart = ls_salesplan-spart.

                CATCH cx_root.
              ENDTRY.
            ELSE.
              gs_disp_plan-zptxt = ls_salesplan-zptxt.
            ENDIF.
            gs_disp_plan-spmon = ls_salesplan-basemonth.
            gs_disp_plan-kunnr = ls_salesplan-kunnr.
            IF ls_salesplan-kunnr IS NOT INITIAL.
              SELECT SINGLE name1 FROM kna1
                  INTO gs_disp_plan-name1
                WHERE kunnr = ls_salesplan-kunnr
                  AND spras = sy-langu.
            ENDIF.
            gs_disp_plan-meins = ls_chk_2080-meins.
            gs_disp_plan-matnr = ls_chk_2080-matnr.
            gs_disp_plan-sul_no = ls_chk_2080-sul_no.
          ENDIF.
*        일치하는 판매오더, 품목이 없을경우 수량 정보는 더해주지 않는다.
*        GS_MAINTAIN_PLAN-QUANTITY_DP = GS_MAINTAIN_PLAN-QUANTITY_DP + LS_SALESPLAN-QUANTITY_DP.
        ENDIF.
      ENDIF.

    ENDLOOP.

*  확정수량
    READ TABLE lt_collect_2090 INTO ls_collect_2090 WITH KEY plnid = ls_chk_conf-plnid.
    IF sy-subrc EQ 0.
      gs_disp_plan-plmng = ls_collect_2090-plmng.
    ENDIF.

*  시뮬레이션상 해당 PLNID와 같은 값이 존재한다면 시뮬레이션 중이라는 의미 조회대상에서 제외
*    READ TABLE GT_MAINTAIN_PLAN TRANSPORTING NO FIELDS WITH KEY PLNID = LS_CHK_CONF-PLNID.
*    IF SY-SUBRC EQ 0. " 현재 작업대상이 있다는 의미이므로 디스플레이 대상에서 제외
*      CONTINUE.
*    ENDIF.
* 해당 시뮬레이션에 PLNID와 같은 값이 존재한다면 시뮬레이션 수량도 더해서 가용 수량 체크
    CLEAR lv_plmng.
    LOOP AT gt_2091 INTO DATA(ls_2091) WHERE pltype = '01' AND plnid = ls_chk_conf-plnid.
      ADD ls_2091-plmng TO lv_plmng.
    ENDLOOP.
    lv_plmng = lv_plmng + gs_disp_plan-plmng .
*   판매계획 수량 보다 시뮬레이션 수량 + 확정수량 합이 크다면 보여주기 제외
    IF gs_disp_plan-quantity_dp <= lv_plmng.
      CONTINUE.
    ENDIF.

    APPEND gs_disp_plan TO gt_disp_plan.

  ENDLOOP.

  IF gt_disp_plan[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '월간 생산계획 수립대상이 없습니다.'(e04).
    RETURN.
  ENDIF.

  SORT gt_disp_plan BY spec zpjno.

  CALL SCREEN '0200' STARTING AT 5 5 ENDING AT 185 20.

  IF gt_disp_plan[] IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT gt_disp_plan INTO gs_disp_plan WHERE arbpl IS NOT INITIAL.
    READ TABLE gt_arbpl TRANSPORTING NO FIELDS WITH KEY arbpl = gs_disp_plan-arbpl.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    CLEAR gs_maintain_plan.
    MOVE-CORRESPONDING gs_disp_plan TO gs_maintain_plan.
    gs_maintain_plan-mode = 'I'. "신규건 마킹

    APPEND gs_maintain_plan TO gt_maintain_plan.
  ENDLOOP.

*  Refresh Process( 헤더 정보 업데이트 -> 헤더 정보 기준으로 디스플레이 화면 구성
  PERFORM modify_simul_header.
  PERFORM set_disp_table.
  PERFORM refresh_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0200 .

  CREATE OBJECT go_contain_0200
    EXPORTING
      container_name              = 'CONTAINER01'                " Name of the Screen CustCtrl Name to Link Container To
    EXCEPTIONS
      cntl_error                  = 1                " CNTL_ERROR
      cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
      create_error                = 3                " CREATE_ERROR
      lifetime_error              = 4                " LIFETIME_ERROR
      lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
      OTHERS                      = 6.


  CREATE OBJECT go_grid_0200
    EXPORTING
      i_parent      = go_contain_0200
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0200 .

  CLEAR gs_layout_0200.
  gs_layout_0200-cwidth_opt = abap_true.
  gs_layout_0200-no_rowins = abap_true.
  gs_layout_0200-no_rowmark   = 'X'.
  gs_layout_0200-sel_mode   = 'C'.
  gs_layout_0200-stylefname = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0200 .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2080TOP'
      i_internal_tabname     = 'GS_DISP_PLAN'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  REFRESH gt_fieldcat_0200.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0200[]
    TABLES
      it_data         = gt_disp_plan
    EXCEPTIONS
      OTHERS          = 1.


  READ TABLE gt_fieldcat_0200 ASSIGNING FIELD-SYMBOL(<ls_fcat>) WITH KEY fieldname = 'CHECK'.
  IF sy-subrc NE 0.
    APPEND INITIAL LINE TO gt_fieldcat_0200 ASSIGNING <ls_fcat>.
    <ls_fcat>-col_pos = 1.
    <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '　'.
    <ls_fcat>-fieldname = 'CHECK'.
    <ls_fcat>-datatype = 'CHAR'.
    <ls_fcat>-dd_outlen = '1'.
    <ls_fcat>-just = 'C'.
    <ls_fcat>-edit = abap_true.
    <ls_fcat>-checkbox = abap_true.
  ENDIF.


  LOOP AT gt_fieldcat_0200 ASSIGNING <ls_fcat>.
    CASE   <ls_fcat>-fieldname.
      WHEN 'PLNID'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'SPEC'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '규격'(f02).
        <ls_fcat>-just = 'L'.
      WHEN 'ZPJNO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '프로젝트 No.'(f03).
        <ls_fcat>-just = 'C'.
      WHEN 'ZPTXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '프로젝트 내역'(f22).
        <ls_fcat>-just = 'L'.
      WHEN 'ARBPL'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'KTEXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '설비(작업장)'(f01).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-edit = abap_true.
        <ls_fcat>-drdn_hndl = '1'.
      WHEN 'SPMON'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매계획월'(f04).
        <ls_fcat>-just = 'C'.
      WHEN 'KUNNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매처코드'(f11).
        <ls_fcat>-just = 'C'.
      WHEN 'NAME1'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매처명'(f12).
        <ls_fcat>-just = 'L'.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '완제품코드'(f08).
        <ls_fcat>-just = 'C'.
      WHEN 'SUL_NO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '설계번호'(f14).
        <ls_fcat>-just = 'C'.
      WHEN 'MEINS'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'QUANTITY_DP'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '판매계획'(f05).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-qfieldname = 'MEINS'.
      WHEN 'SIMUL_MNG'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'PLMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '확정생산계획'(f06).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-qfieldname = 'MEINS'.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0200 .

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.
  FIELD-SYMBOLS <lt_celltab> TYPE any.

  LOOP AT gt_disp_plan ASSIGNING FIELD-SYMBOL(<ls_data>).
    REFRESH lt_celltab.

    LOOP AT gt_fieldcat_0200 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
      CASE <ls_fcat>-fieldname.
        WHEN 'SPEC' OR 'ZPJNO' OR 'ZPTXT'.
          CLEAR ls_celltab.
          ls_celltab-fieldname = <ls_fcat>-fieldname.
          ls_celltab-style = alv_style_color_int_key.
          INSERT ls_celltab INTO TABLE lt_celltab.
      ENDCASE.
    ENDLOOP.

    IF <lt_celltab> IS ASSIGNED. UNASSIGN <lt_celltab>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <ls_data> TO <lt_celltab>.
    IF <lt_celltab> IS ASSIGNED.
      <lt_celltab> = lt_celltab.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0200 .
  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0200
        USING : cl_gui_alv_grid=>mc_fc_excl_all.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0200_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0200_display .

  CALL METHOD go_grid_0200->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0200
      it_toolbar_excluding = gt_exclude_0200
    CHANGING
      it_outtab            = gt_disp_plan
      it_fieldcatalog      = gt_fieldcat_0200.

* 인풋이벤트 추가
  CALL METHOD go_grid_0200->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD go_grid_0200->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DROP_DOWN_GRID_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_drop_down_grid_0200 .

  DATA : lt_dropdown TYPE lvc_t_dral,
         ls_dropdown TYPE lvc_s_dral.

  REFRESH lt_dropdown.
* inital값 어팬드
  CLEAR ls_dropdown.
  ls_dropdown-handle    = '1'.
  ls_dropdown-int_value = '0'.
  APPEND ls_dropdown TO lt_dropdown.

  LOOP AT gt_arbpl INTO gs_arbpl.
    CLEAR ls_dropdown.
    ls_dropdown-handle    = '1'.
    ls_dropdown-value     = gs_arbpl-ktext.
    ls_dropdown-int_value = gs_arbpl-seq.
    APPEND ls_dropdown TO lt_dropdown.
  ENDLOOP.

  "alv에서 드롭다운이 보여지도록 설정하는 함수
  CALL METHOD go_grid_0200->set_drop_down_table
    EXPORTING
      it_drop_down_alias = lt_dropdown.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISP_SCREEN_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM disp_screen_field  USING pv_fieldname TYPE dynpread-fieldname.

  DATA : lt_dynpfields LIKE TABLE OF dynpread.
  DATA : lv_line LIKE sy-stepl.

  ASSIGN  (pv_fieldname) TO FIELD-SYMBOL(<lv_value>).

  PERFORM get_stepl USING lv_line.
*      시뮬레이션 번호
  APPEND INITIAL LINE TO lt_dynpfields ASSIGNING FIELD-SYMBOL(<ls_dynpfields>).
  <ls_dynpfields>-fieldname = pv_fieldname.
  <ls_dynpfields>-stepl = lv_line.
  <ls_dynpfields>-fieldvalue = <lv_value>.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = lt_dynpfields
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
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_arbpl .

* 입력값 유효성 확인
  IF gs_200_top-arbpl IS INITIAL.
    RETURN.
  ENDIF.

  READ TABLE gt_arbpl INTO gs_arbpl WITH KEY arbpl = gs_200_top-arbpl.
  IF sy-subrc NE 0.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '유효하지 않은 설비(작업장) 코드입니다.'(e05).
    RETURN.
  ENDIF.

  IF NOT line_exists( gt_disp_plan[ check = abap_true ] ).
    MESSAGE s003 DISPLAY LIKE 'E' WITH '체크된 라인이 없어 일괄 변경할 수 없습니다.'(e06).
    RETURN.
  ENDIF.

  LOOP AT gt_disp_plan ASSIGNING FIELD-SYMBOL(<ls_main>) WHERE check = abap_true.
    <ls_main>-arbpl = gs_200_top-arbpl.
    <ls_main>-ktext = gs_200_top-ktext.
  ENDLOOP.

  PERFORM refresh_grid USING go_grid_0200.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0200
*&---------------------------------------------------------------------*
FORM refresh_grid  USING    po_grid TYPE REF TO cl_gui_alv_grid..

  DATA: ls_scroll   TYPE lvc_s_stbl.

  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      is_stable = ls_scroll.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM data_changed  USING    p_sender  TYPE REF TO cl_gui_alv_grid
                                po_data_changed TYPE REF TO
                                          cl_alv_changed_data_protocol
                                pe_onf4
                                pe_ucomm.

  DATA: ls_mod_cells TYPE lvc_s_modi.
  DATA : lv_meins TYPE meins.
  DATA : lv_sul TYPE zesul_no.
  DATA : lv_fieldname TYPE fieldname.
  DATA : lv_chk_err.

  DEFINE __set_err_msg.
    lv_chk_err = abap_true.
    po_data_changed->add_protocol_entry(
        i_msgid     = 'ZGTPP00'                 " Message ID
        i_msgty     = 'E'                 " Message Type
        i_msgno     =  '03'                " Message No.
        i_msgv1     =  &1                " Message Variable1
        i_fieldname =  &2                " Field Name
        i_row_id    =  ls_mod_cells-row_id ).                " RowID
  END-OF-DEFINITION.

  DEFINE __modi_cell.
    po_data_changed->modify_cell(
      i_row_id     = &1                 " Row ID
      i_fieldname = &2                 " Field Name
      i_value       = &3 ).               " Value
  END-OF-DEFINITION.

  CASE p_sender.
    WHEN go_grid_0200.
      LOOP AT po_data_changed->mt_good_cells INTO ls_mod_cells.
        CASE ls_mod_cells-fieldname.
          WHEN 'KTEXT'.
            READ TABLE gt_arbpl INTO gs_arbpl WITH KEY ktext = ls_mod_cells-value.
            IF sy-subrc EQ 0.
              __modi_cell ls_mod_cells-row_id 'ARBPL' gs_arbpl-arbpl.
            ELSE.
              __modi_cell ls_mod_cells-row_id 'ARBPL' ''.
            ENDIF.
        ENDCASE.
      ENDLOOP.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SIMUL_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_simul_header .

  DATA : lv_idx TYPE i.
  DATA : lv_matnr TYPE matnr.
  DATA : iv_idnrk TYPE idnrk.

  LOOP AT gt_maintain_plan ASSIGNING FIELD-SYMBOL(<ls_plan>).
    lv_idx = sy-tabix.
    CASE <ls_plan>-mode.
      WHEN 'D'. " 삭제
        DELETE gt_2090 WHERE arbpl = <ls_plan>-arbpl
                                    AND plnid = <ls_plan>-plnid.

        DELETE gt_2091 WHERE arbpl = <ls_plan>-arbpl
                                    AND plnid = <ls_plan>-plnid.

        DELETE gt_maintain_plan INDEX lv_idx.
        CONTINUE.
      WHEN 'I'. "  신규건 생성
        CLEAR : lv_matnr, iv_idnrk.
        PERFORM get_capa_data_new USING <ls_plan> CHANGING lv_matnr iv_idnrk.
        PERFORM make_simul_header USING <ls_plan> lv_matnr iv_idnrk CHANGING <ls_plan>-seqno_d.
        PERFORM make_simul_item USING lv_matnr iv_idnrk CHANGING <ls_plan>.

        CLEAR <ls_plan>-mode.
      WHEN 'C'. "  변경으로 신규건 생성 해당 완제품 반제품 코드 들고 시작
        CLEAR : lv_matnr, iv_idnrk.
*        LV_MATNR = GS_DISP_METERIAL-MATNR.
        iv_idnrk = gs_disp_meterial-idnrk..
        PERFORM get_capa_data USING <ls_plan> lv_matnr iv_idnrk.

        PERFORM make_simul_header USING <ls_plan> lv_matnr iv_idnrk  CHANGING <ls_plan>-seqno_d.
        PERFORM make_simul_item USING lv_matnr iv_idnrk CHANGING <ls_plan>.

      WHEN OTHERS.
        CONTINUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_SIMUL_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_PLAN>
*&---------------------------------------------------------------------*
FORM make_simul_header  USING ps_plan LIKE gs_maintain_plan
                                                pv_matnr TYPE matnr
                                                pv_idnrk TYPE idnrk
                                  CHANGING pv_seqno.

  SORT gt_2090 BY arbpl seqno DESCENDING.
  READ TABLE gt_2090 INTO DATA(ls_temp) WITH KEY arbpl = ps_plan-arbpl.


  APPEND INITIAL LINE TO gt_2090 ASSIGNING FIELD-SYMBOL(<ls_2090>).

  <ls_2090>-werks = p_werks.
  <ls_2090>-spgcd = p_spgcd.
  <ls_2090>-simty = p_simty.
  <ls_2090>-simno = gv_simno.
  <ls_2090>-simvr = gv_simvr.
  <ls_2090>-simnm = gv_simnm.
  <ls_2090>-arbpl = ps_plan-arbpl.
  <ls_2090>-plnid  = ps_plan-plnid.
  <ls_2090>-zspmon = gv_bgn_dt+0(6).
  <ls_2090>-zepmon = gv_end_dt+0(6).

  IF ps_plan-mode = 'I'.
    <ls_2090>-seqno = ls_temp-seqno + 1.
    pv_seqno = <ls_2090>-seqno.
  ELSEIF ps_plan-mode = 'C'.
    <ls_2090>-seqno = ps_plan-seqno_d.
    pv_seqno = <ls_2090>-seqno.
  ENDIF.

  <ls_2090>-matnr  = pv_matnr.
  <ls_2090>-idnrk  = pv_idnrk.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_disp_table .

  DATA : lo_line TYPE REF TO data.
  FIELD-SYMBOLS : <ls_line> TYPE any. " 서브토탈용 라인

  DATA : lt_plan LIKE TABLE OF gs_maintain_plan.
  DATA : lt_2091 TYPE TABLE OF zgtppt2091.
  DATA : ls_2120 TYPE zgtppt2120.
  DATA : ls_2130 TYPE zgtppt2130.
  DATA : lv_chk_dt TYPE sy-datum.
  DATA : lv_plmng TYPE zgtppt2091-plmng.
  DATA : lv_plmng_tot TYPE zgtppt2091-plmng.
  DATA : lv_plmng_move TYPE zgtppt2091-plmng.
  DATA : BEGIN OF ls_chk_date,
           date TYPE sy-datum,
         END OF ls_chk_date.
  DATA : lt_chk_date LIKE TABLE OF ls_chk_date.
  DATA : lv_chk_rate TYPE i.

  DATA : ls_main_data LIKE gs_main_data.

  DATA : lv_fieldname TYPE fieldname.
  FIELD-SYMBOLS : <lv_day_value> TYPE any.
  FIELD-SYMBOLS : <lv_day_chk> TYPE any.
  FIELD-SYMBOLS : <lv_value> TYPE any.


  DEFINE __get_day_field.

*  날짜별 수량 필드
    CLEAR lv_fieldname.
    lv_fieldname = &1.
    IF <lv_day_value> IS ASSIGNED. UNASSIGN <lv_day_value>. ENDIF.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main> TO <lv_day_value>.

*  날짜별 체크필드
    CLEAR lv_fieldname.
    lv_fieldname = &1 && '_CHK'.
    IF <lv_day_chk> IS ASSIGNED. UNASSIGN <lv_day_chk>. ENDIF.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main> TO <lv_day_chk>.

  END-OF-DEFINITION.

  DEFINE __get_day_field_use_sum.

*  날짜별 수량 필드
    CLEAR lv_fieldname.
    lv_fieldname = &1.
    IF <lv_day_value> IS ASSIGNED. UNASSIGN <lv_day_value>. ENDIF.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_line> TO <lv_day_value>.

*  날짜별 체크필드
    CLEAR lv_fieldname.
    lv_fieldname = &1 && '_CHK'.
    IF <lv_day_chk> IS ASSIGNED. UNASSIGN <lv_day_chk>. ENDIF.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_line> TO <lv_day_chk>.

  END-OF-DEFINITION.

  CREATE DATA lo_line LIKE LINE OF <gt_main_disp_100>.
  ASSIGN lo_line->* TO <ls_line>.

* 실제 사용되는 정보만 추출
  PERFORM get_master_capa.

  REFRESH <gt_main_disp_100>.

  LOOP AT gt_arbpl INTO gs_arbpl.
*   모두 데이터 이관
    REFRESH lt_plan.
    lt_plan = VALUE #( FOR lw_plan IN gt_maintain_plan WHERE ( arbpl = gs_arbpl-arbpl )
                              ( CORRESPONDING #( lw_plan ) ) ).
    IF lt_plan IS NOT INITIAL.
      LOOP AT lt_plan INTO DATA(ls_plan).
        CLEAR gs_main_data.
        PERFORM move_data_plan_to_main USING ls_plan.
        gs_main_data-seqno = gs_arbpl-seq.

        PERFORM check_jojang USING gs_main_data-plnid CHANGING gs_main_data-chk_jojang.

        READ TABLE gt_2090 INTO DATA(ls_2090) WITH KEY arbpl = ls_plan-arbpl
                                                                        plnid = ls_plan-plnid.
        " 연결되거나 생성된 플랜 정보가 없다면 기본정보만 반영
        IF sy-subrc NE 0.
          APPEND INITIAL LINE TO <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_main>).
          MOVE-CORRESPONDING gs_main_data TO <ls_main>.

          CONTINUE.
        ENDIF.

        gs_main_data-matnr = ls_2090-matnr.
        gs_main_data-idnrk = ls_2090-idnrk.
        gs_main_data-seqno_d = ls_2090-seqno.
        PERFORM chk_jojang USING ls_plan CHANGING gs_main_data-chk_jojang.

        APPEND INITIAL LINE TO <gt_main_disp_100> ASSIGNING <ls_main>.
        MOVE-CORRESPONDING gs_main_data TO <ls_main>.

* 기본정보 리드 (캐파정보- 선속) _일자별 선속 계산후 상태처리를 위해 기본 정보 가지고 있는다.
        CLEAR ls_2120.
        READ TABLE gt_2120_use INTO ls_2120 WITH KEY spec = ls_plan-spec
                                                                              cptype = '03'
                                                                              idnrk = gs_main_data-idnrk
                                                                             arbpl = ls_plan-arbpl.
* 일별 선속정보 구하기
        CLEAR lv_plmng.
        PERFORM cal_day_plmng USING ls_2120-vgwrt ls_2120-vgweh CHANGING lv_plmng.

        IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
        ASSIGN COMPONENT 'DAY_PLMNG' OF STRUCTURE <ls_main> TO <lv_value>.
        CLEAR <lv_value>.
        <lv_value> = lv_plmng.

*      시뮬레이션 수량정보, 해당라인의 PLNID 값에 대한 수량정보 전체
        IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
        ASSIGN COMPONENT 'PLMNG' OF STRUCTURE <ls_main> TO <lv_value>.
        CLEAR <lv_value>.
        LOOP AT gt_2091 INTO DATA(ls_cal) WHERE pltype = '01' AND plnid = ls_plan-plnid.
          <lv_value> = <lv_value> + ls_cal-plmng.
        ENDLOOP.

* 플랜 정보 반영
        REFRESH lt_2091.
        lt_2091 = VALUE #( FOR lw_2091 IN gt_2091 WHERE ( arbpl = ls_plan-arbpl
                                                                           AND   plnid = ls_plan-plnid )
                              ( CORRESPONDING #( lw_2091 ) ) ).
* 일자별 플랜 정보가 없다면 해당 내용 까지 반영후 종료
        IF lt_2091[] IS INITIAL.
          CONTINUE.
        ENDIF.




* 일자별 세팅
        LOOP AT lt_2091 INTO DATA(ls_2091).
          __get_day_field ls_2091-pldat.
          CASE ls_2091-pltype.
            WHEN '01'. "생산  "check 필드 구분  U 기본 선속보다 많음, D 기본 선속보다 적음, N 정상
              WRITE ls_2091-plmng TO <lv_day_value> UNIT gs_main_data-meins.
              CONDENSE <lv_day_value>.
              IF ls_2091-plmng = lv_plmng.
                <lv_day_chk> = 'N'.
              ELSEIF ls_2091-plmng > lv_plmng.
                <lv_day_chk> = 'U'.
*              ELSE.
*                <LV_DAY_CHK> = 'D'.
              ENDIF.

            WHEN '02'. "청소 "check 필드 구분 N
              <lv_day_value> = '청소'.
              <lv_day_chk> = 'C'.

            WHEN '03'. "비가동  "check 필드 구분 X
              <lv_day_value> = ls_2091-nopnm.
              <lv_day_chk> = 'X'.

          ENDCASE.

* 날짜별 카파 가용수량 체크
          lv_chk_dt = gv_bgn_dt.
          DO.
            IF lv_chk_dt > gv_end_dt.
              EXIT.
            ENDIF.
            __get_day_field lv_chk_dt.
            CASE <lv_day_chk>.
              WHEN 'C' OR 'X'.
              WHEN OTHERS.
*      설비별 해당 일자 총 케파 분석.
                IF <lv_day_value> IS NOT INITIAL.
                  PERFORM cal_capa_per_day USING gs_arbpl-arbpl lv_chk_dt CHANGING <lv_day_chk>.
                ENDIF.
            ENDCASE.
            ADD 1 TO lv_chk_dt.
          ENDDO.

        ENDLOOP.

* 기존 스케줄링된 조장구성표 오더가 존재한다면 체크
        LOOP AT gt_schedule INTO gs_schedule WHERE arbpl = gs_arbpl-arbpl.
          __get_day_field gs_schedule-date.
          IF <lv_day_chk> = abap_true.
            CONTINUE.
          ELSEIF <lv_day_chk> = 'C'. " 청소는 가운데 정렬을 위해
            <lv_day_chk> = 'T'.
          ELSE.
            <lv_day_chk> = 'S'.
          ENDIF.

*          IF <LV_DAY_VALUE> IS INITIAL.
*            <LV_DAY_VALUE> = '조장구성'.
*            <LV_DAY_CHK> = 'T'.
*          ENDIF.

        ENDLOOP.

      ENDLOOP.

* 데이터 존재시 서브토탈 정보 어팬드
      REFRESH lt_chk_date.
      CLEAR <ls_line>.
      CLEAR ls_main_data.
      ls_main_data-arbpl = gs_arbpl-arbpl.
      ls_main_data-seqno = gs_arbpl-seq.

      MOVE-CORRESPONDING ls_main_data TO <ls_line>.
      IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
      ASSIGN COMPONENT 'SUM_CHK' OF STRUCTURE <ls_line> TO <lv_value>.
      <lv_value> = abap_true.
* 수량 적용
      LOOP AT gt_2091 INTO ls_2091 WHERE arbpl = gs_arbpl-arbpl.
        CASE ls_2091-pltype.
          WHEN '01'.
            CLEAR ls_chk_date-date.
            ls_chk_date-date = ls_2091-pldat.
            COLLECT ls_chk_date INTO lt_chk_date.
            __get_day_field_use_sum ls_2091-pldat.
            <lv_day_value> = <lv_day_value> + ls_2091-plmng.
        ENDCASE.
      ENDLOOP.
* 단위 적용하여 수량 적용
      LOOP AT lt_chk_date INTO ls_chk_date.
        __get_day_field_use_sum ls_chk_date-date.
        CLEAR lv_plmng_move.
        lv_plmng_move = <lv_day_value>.
        WRITE lv_plmng_move TO <lv_day_value> UNIT gs_main_data-meins.
        CONDENSE <lv_day_value>.
      ENDLOOP.

      APPEND <ls_line> TO <gt_main_disp_100>.

    ELSE. " 설계중인 정보가 없을시 초기 설비정보만 이관
      CLEAR gs_main_data.
      APPEND INITIAL LINE TO <gt_main_disp_100> ASSIGNING <ls_main>.
      MOVE-CORRESPONDING gs_arbpl TO gs_main_data.
      gs_main_data-seqno = gs_arbpl-seq.
      MOVE-CORRESPONDING gs_main_data TO <ls_main>.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MOVE_DATA_PLAN_TO_MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_PLAN
*&---------------------------------------------------------------------*
FORM move_data_plan_to_main  USING    ps_plan LIKE gs_maintain_plan.

  MOVE-CORRESPONDING ps_plan TO gs_main_data.
  CLEAR gs_main_data-plmng.
  gs_main_data-basemonth = ps_plan-spmon.
  gs_main_data-menge = ps_plan-plmng.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_PLAN
*&      <-- GS_MAIN_DATA_CHK_JOJANG
*&---------------------------------------------------------------------*
FORM chk_jojang  USING  ps_plan LIKE gs_maintain_plan
                       CHANGING  pv_chk_jojang TYPE icon-id.

  DATA : lv_ordnr TYPE zgtppt2010-ordnr.
  DATA : lv_num(6) TYPE n.

  READ TABLE gt_2080 INTO DATA(ls_2080) WITH KEY spec = ps_plan-spec
                                                                         zpjno = ps_plan-zpjno
                                                                         plnid = ps_plan-plnid.
  IF sy-subrc EQ 0.
    IF ls_2080-vbeln IS NOT INITIAL.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ls_2080-vbeln
        IMPORTING
          output = lv_ordnr.

      lv_num = ls_2080-posnr + 0.
      READ TABLE gt_2010 TRANSPORTING NO FIELDS WITH KEY dmord = lv_ordnr
                                                                                     dmline = lv_num
                                                                                     dmordty = 'SO'.
      IF sy-subrc EQ 0.
        pv_chk_jojang = icon_list.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MASTER_CAPA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_master_capa .

  REFRESH gt_2120.

  IF gt_maintain_plan[] IS NOT INITIAL.
    SELECT DISTINCT b~*
      FROM @gt_maintain_plan AS a
      INNER JOIN zgtppt2120 AS b ON b~spec = a~spec
     WHERE b~werks = @p_werks
        AND b~spgcd = @p_spgcd
      INTO CORRESPONDING FIELDS OF TABLE @gt_2120.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_DAY_PLMNG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_2120_VGWRT
*&      --> LS_2120_VGWEH
*&      <-- LV_PLMNG
*&---------------------------------------------------------------------*
FORM cal_day_plmng  USING    pv_vgwrt TYPE vgwrt
                                              pv_vgweh TYPE vgwrteh
                             CHANGING    pv_plmng TYPE zgtppt2091-plmng.

  CASE pv_vgweh.
    WHEN 'H'.
      pv_plmng = pv_vgwrt * 24.
    WHEN 'MIN'.
      pv_plmng = pv_vgwrt * 1440.
  ENDCASE.

*  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
*    EXPORTING
*      I_RTYPE     = '-'
*      I_RUNIT     = 1
*      I_VALUE     = PV_PLMNG
*    IMPORTING
*      E_VALUE_RND = PV_PLMNG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_0100 .

  DATA: ls_scroll   TYPE lvc_s_stbl.

  ls_scroll-row = 'X'.
  ls_scroll-col = 'X'.

  IF go_dd_docu_0100 IS BOUND.
    CALL METHOD go_dd_docu_0100->initialize_document.

    CALL METHOD go_grid_0100->list_processing_events
      EXPORTING
        i_event_name = 'TOP_OF_PAGE'
        i_dyndoc_id  = go_dd_docu_0100.
  ENDIF.

  PERFORM set_cell_attribute_grid_0100.
  go_grid_0100->set_frontend_layout( is_layout = gs_layout_0100 ).

  CALL METHOD go_grid_0100->refresh_table_display
    EXPORTING
      is_stable = ls_scroll.

  gv_chk_edit = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_del_plan .

  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lo_table TYPE REF TO data.
  FIELD-SYMBOLS : <lt_table> TYPE table.

  CREATE DATA lo_table LIKE <gt_main_disp_100>.
  ASSIGN lo_table->* TO <lt_table>.

  IF gv_status_confirm = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션으로 수정할 수 없습니다.'(e09).
    RETURN.
  ENDIF.

  go_grid_0100->get_selected_cells_id(
    IMPORTING
     et_cells = lt_cells ).                " Cell IDs

  IF lt_cells[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 Cell이 없습니다.'(e07).
    RETURN.
  ENDIF.

  SORT lt_cells BY row_id.
  DELETE ADJACENT DUPLICATES FROM lt_cells COMPARING row_id.

  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX ls_cells-row_id.
    CLEAR gs_main_data.
    MOVE-CORRESPONDING <ls_main> TO gs_main_data.
    IF gs_main_data-sum_chk = abap_true.
      CONTINUE.
    ELSE.
      APPEND INITIAL LINE TO <lt_table> ASSIGNING FIELD-SYMBOL(<ls_temp>).
      MOVE-CORRESPONDING <ls_main> TO <ls_temp>.
    ENDIF.

  ENDLOOP.

  IF <lt_table>[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '삭제 대상이 선택되지 않았습니다.'(e08).
    RETURN.
  ENDIF.


  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '선택된 판매계획 대상이 삭제 됩니다. 계속 진행하시겠습니까??'
    '삭제확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT lt_cells INTO ls_cells.
    READ TABLE <gt_main_disp_100> ASSIGNING <ls_main> INDEX ls_cells-row_id.
    CLEAR gs_main_data.

    MOVE-CORRESPONDING <ls_main> TO gs_main_data.

    READ TABLE gt_maintain_plan ASSIGNING FIELD-SYMBOL(<ls_plan>) WITH KEY arbpl = gs_main_data-arbpl
                                                                                                                  plnid = gs_main_data-plnid.
    IF sy-subrc EQ 0.
      <ls_plan>-mode = 'D'.
    ENDIF.

  ENDLOOP.

*  Refresh Process( 헤더 정보 업데이트 -> 헤더 정보 기준으로 디스플레이 화면 구성
  PERFORM modify_simul_header.
  PERFORM set_disp_table.
  PERFORM refresh_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SET_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_ERR_CHK
*&---------------------------------------------------------------------*
FORM check_set_plan  CHANGING pv_err_chk.

  LOOP AT gt_disp_plan INTO gs_disp_plan WHERE ktext IS NOT INITIAL.
    READ TABLE gt_maintain_plan TRANSPORTING NO FIELDS WITH KEY spec = gs_disp_plan-spec
                                                                                               zpjno = gs_disp_plan-zpjno
                                                                                               ktext = gs_disp_plan-ktext
                                                                                               plnid = gs_disp_plan-plnid.
    IF sy-subrc EQ 0.
      MESSAGE s000 DISPLAY LIKE 'E' WITH '설비(작업장)에 선택한 판매계획이 이미 입력되어 있습니다.'.
      pv_err_chk = abap_true.
      RETURN.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_SIMUL_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_PLAN>
*&---------------------------------------------------------------------*
FORM make_simul_item  USING pv_matnr TYPE matnr
                                            pv_idnrk TYPE idnrk
                              CHANGING ps_plan LIKE gs_maintain_plan.

  DATA : lt_2091 TYPE TABLE OF zgtppt2091.
  DATA : lt_2120 TYPE TABLE OF zgtppt2120.
  DATA : lt_2130 TYPE TABLE OF zgtppt2120.
  DATA : lv_chk_date TYPE sy-datum.

* 추후 계산을 위한 선속정보 업데이트
  SELECT * FROM zgtppt2120
    APPENDING CORRESPONDING FIELDS OF TABLE gt_2120_use
    WHERE werks = p_werks
      AND spgcd = p_spgcd
      AND spec = ps_plan-spec
      AND idnrk = pv_idnrk
      AND cptype IN ( '01', '02' )
*      AND MATNR = PV_MATNR
      AND zstate <> ' '.

* 신규 대상건 이므로 비가동정보만 업데이트
*  -  >  설비 대상 기준 업데이트 이후, 전체 설비 건 대상으로 업데이트
  LOOP AT gt_2130 INTO DATA(ls_2130) WHERE optype = '03' AND arbpl = ps_plan-arbpl.
    APPEND INITIAL LINE TO lt_2091 ASSIGNING FIELD-SYMBOL(<ls_2091>).

    IF ls_2130-datuv = ls_2130-datub.

      PERFORM set_new_2091_03 USING ps_plan ls_2130-datuv ls_2130-nopnm CHANGING <ls_2091>.
    ELSE.
      lv_chk_date = ls_2130-datuv.
      DO.
        IF lv_chk_date > ls_2130-datub.
          EXIT.
        ENDIF.
        PERFORM set_new_2091_03 USING ps_plan lv_chk_date ls_2130-nopnm CHANGING <ls_2091>.

        ADD 1 TO lv_chk_date.
      ENDDO.
    ENDIF.
  ENDLOOP.

* 전체 설비건 대상
  LOOP AT gt_2130 INTO ls_2130 WHERE optype = '03' AND arbpl IS INITIAL.

    IF ls_2130-datuv = ls_2130-datub.

      READ TABLE lt_2091 TRANSPORTING NO FIELDS WITH KEY pldat = ls_2130-datuv.
      IF sy-subrc EQ 0.
        DELETE lt_2091 INDEX sy-tabix.
      ENDIF.

      APPEND INITIAL LINE TO lt_2091 ASSIGNING <ls_2091>.

      PERFORM set_new_2091_03 USING ps_plan ls_2130-datuv ls_2130-nopnm CHANGING <ls_2091>.
    ELSE.
      lv_chk_date = ls_2130-datuv.
      DO.
        IF lv_chk_date > ls_2130-datub.
          EXIT.
        ENDIF.

        READ TABLE lt_2091 TRANSPORTING NO FIELDS WITH KEY pldat = lv_chk_date.
        IF sy-subrc EQ 0.
          DELETE lt_2091 INDEX sy-tabix.
        ENDIF.

        APPEND INITIAL LINE TO lt_2091 ASSIGNING <ls_2091>.

        PERFORM set_new_2091_03 USING ps_plan lv_chk_date ls_2130-nopnm CHANGING <ls_2091>.

        ADD 1 TO lv_chk_date.
      ENDDO.
    ENDIF.
  ENDLOOP.

  IF lt_2091[] IS NOT INITIAL.
    APPEND LINES OF lt_2091 TO gt_2091.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CAPA_DATA_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_PLAN>
*&---------------------------------------------------------------------*
FORM get_capa_data_new  USING     ps_plan   LIKE gs_maintain_plan
                        CHANGING  pv_matnr  TYPE matnr
                                  pv_idnrk  TYPE idnrk.

  DATA : ls_2120 TYPE zgtppt2120.
  DATA : lv_idnrk LIKE zgtppt2120-idnrk.

* capa 테이블에 선속이 0이 아닌건 추출
  SELECT SINGLE * FROM zgtppt2120
    INTO ls_2120
    WHERE werks = p_werks
      AND spgcd = p_spgcd
      AND spec = ps_plan-spec
      AND arbpl = ps_plan-arbpl
      AND matnr = ps_plan-matnr
      AND cptype = '03'
      AND vgwrt NE 0
      AND zstate <> ' '.
  IF sy-subrc EQ 0.
    pv_matnr = ps_plan-matnr.
    pv_idnrk = ls_2120-idnrk.
    APPEND ls_2120 TO gt_2120_use.

*----------------------------------------------------------------------*
*/s 2026.05.26.zslgpp5.CHM2605-00421.완제품으로 zgtppt2120 데이터가
*                     없을시 BOM 반제품을 찾아서 조회.
*----------------------------------------------------------------------*
  ELSE.
    CLEAR: lv_idnrk.
    PERFORM find_ins_matnh  USING ps_plan-matnr
                            CHANGING lv_idnrk.
    IF lv_idnrk IS NOT INITIAL.
      SELECT SINGLE * FROM zgtppt2120
        INTO ls_2120
        WHERE werks = p_werks
          AND spgcd = p_spgcd
          AND spec = ps_plan-spec
          AND arbpl = ps_plan-arbpl
          AND idnrk = lv_idnrk
          AND cptype = '03'
          AND vgwrt NE 0
          AND zstate <> ' '.
      IF sy-subrc EQ 0.
        pv_matnr = ps_plan-matnr.
        pv_idnrk = ls_2120-idnrk.
        APPEND ls_2120 TO gt_2120_use.
      ENDIF.
    ENDIF.
*/e 2026.05.26.zslgpp5.CHM2605-00421.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_NEW_2091_03
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_CHK_DATE
*&      <-- <LS_2091>
*&---------------------------------------------------------------------*
FORM set_new_2091_03  USING    ps_plan LIKE gs_maintain_plan
                                                pv_chk_date TYPE sy-datum
                                                pv_nopnm TYPE zgtppt2130-nopnm
                               CHANGING    ps_2091  TYPE zgtppt2091.

  ps_2091-werks = p_werks.
  ps_2091-spgcd = p_spgcd.
  ps_2091-simno = gv_simno.
  ps_2091-simvr = gv_simvr.
  ps_2091-arbpl = ps_plan-arbpl.
  ps_2091-plnid = ps_plan-plnid.
  ps_2091-pldat = pv_chk_date.
  ps_2091-pltype = '03'.
*    수량정보 없데이트 없음
*    PS_PLAN-PLMNG
  ps_2091-nopnm = pv_nopnm.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CHG_PLAN_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_chg_plan_matnr .

  DATA : lt_cells TYPE lvc_t_ceno.

  IF gv_status_confirm = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션으로 수정할 수 없습니다.'(e09).
    RETURN.
  ENDIF.

  go_grid_0100->get_selected_cells_id(
    IMPORTING
     et_cells = lt_cells ).                " Cell IDs

  IF lt_cells[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 Cell이 없습니다.'(e07).
    RETURN.
  ENDIF.

  SORT lt_cells BY row_id.
  DELETE ADJACENT DUPLICATES FROM lt_cells COMPARING row_id.

  IF lines( lt_cells ) > 1.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의 판매계획을 선택해 주세요'(e10).
    RETURN.
  ENDIF.

  READ TABLE lt_cells INTO DATA(ls_cell) INDEX 1.
  READ TABLE <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX ls_cell-row_id.
  CLEAR gs_main_data.
  MOVE-CORRESPONDING <ls_main> TO gs_main_data.
  IF gs_main_data-spec IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '계획 자재를 변경할 판매계획을 선택해 주세요.'(e11).
    RETURN.
  ENDIF.

* 탑 정보
  gv_300_top = gs_main_data-ktext.

  PERFORM get_chg_meterial_data USING gs_main_data.

  IF gt_disp_meterial[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '변경 가능한 계획 자재가 없습니다.'(e12).
    RETURN.
  ENDIF.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '계획 자재를 변경하면 입력된 모든 생산 계획이 초기화 됩니다. 진행하시겠습니까?'
    '삭제확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  CLEAR gs_disp_meterial.

  CALL SCREEN '0300' STARTING AT 5 5 ENDING AT 125 15.

  CHECK gs_disp_meterial-usechk IS NOT INITIAL.

  READ TABLE gt_maintain_plan ASSIGNING FIELD-SYMBOL(<ls_data>) WITH KEY plnid = gs_main_data-plnid
                                                                                                                arbpl = gs_main_data-arbpl.
* 자재 신규구성으로 기존에 사용되는 아이템 정보들 클리어, 리플레이스 기능
  PERFORM init_line_data CHANGING <ls_data>.
*  Refresh Process( 헤더 정보 업데이트 -> 헤더 정보 기준으로 디스플레이 화면 구성
  PERFORM modify_simul_header.
  PERFORM set_disp_table.
  PERFORM refresh_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CHG_METERIAL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN_DATA
*&---------------------------------------------------------------------*
FORM get_chg_meterial_data  USING    ps_main_data LIKE gs_main_data.

  DATA : lt_2120 TYPE TABLE OF zgtppt2120.
  DATA : lt_2120_infor TYPE TABLE OF zgtppt2120.
  DATA : lv_num(2) TYPE n.
  DATA : lv_fieldname TYPE fieldname.
  DATA : lv_fieldname2 TYPE fieldname.
  FIELD-SYMBOLS : <lv_value> TYPE any.
  DATA : lv_dec TYPE p LENGTH 16 DECIMALS 2.
  DATA : lv_plmng TYPE zgtppt2091-plmng.


  SELECT  * FROM zgtppt2120
   WHERE werks = @p_werks
     AND spgcd = @p_spgcd
     AND spec = @ps_main_data-spec
     AND arbpl = @ps_main_data-arbpl
     AND idnrk <> @ps_main_data-idnrk
    INTO CORRESPONDING FIELDS OF TABLE @lt_2120.

  DATA(lt_chk_tab) = lt_2120.
  SORT lt_chk_tab BY werks spgcd spec matnr idnrk.
  DELETE ADJACENT DUPLICATES FROM lt_chk_tab COMPARING werks spgcd spec matnr idnrk.

  IF lt_chk_tab[] IS NOT INITIAL.
    SELECT * FROM zgtppt2120
      INTO CORRESPONDING FIELDS OF TABLE lt_2120_infor
      FOR ALL ENTRIES IN lt_chk_tab
     WHERE werks = lt_chk_tab-werks
       AND spgcd = lt_chk_tab-spgcd
       AND spec = lt_chk_tab-spec
       AND matnr = lt_chk_tab-matnr
       AND idnrk = lt_chk_tab-idnrk
       AND cptype IN ( '01', '02' ).
  ENDIF.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE @gt_1010
    FROM zgtppt1010
    WHERE module_kind EQ 'PP'
      AND codegrp     EQ '2060'
      AND fld_01      EQ @p_werks
      AND fld_02      EQ @p_spgcd.

  REFRESH lt_chk_tab.
  lt_chk_tab = lt_2120.
  SORT lt_chk_tab BY idnrk.
  DELETE ADJACENT DUPLICATES FROM lt_chk_tab COMPARING idnrk.

  IF lt_chk_tab[] IS NOT INITIAL.
    SELECT * INTO TABLE @DATA(lt_char)
      FROM zgtcvmstval
      FOR ALL ENTRIES IN @lt_chk_tab
      WHERE werks EQ @p_werks
        AND matnr EQ @lt_chk_tab-idnrk.
  ENDIF.

  SORT gt_1010 BY fld_03.
  REFRESH gt_disp_meterial.

  LOOP AT lt_2120 INTO DATA(ls_2120).
    APPEND INITIAL LINE TO gt_disp_meterial ASSIGNING FIELD-SYMBOL(<ls_disp>).
    <ls_disp>-spec = ls_2120-spec.
    <ls_disp>-matnr = ls_2120-matnr.
    <ls_disp>-idnrk = ls_2120-idnrk.

    READ TABLE lt_char INTO DATA(ls_char) WITH KEY matnr = ls_2120-idnrk.
    IF sy-subrc EQ 0.
* 특성정보 찾기
      CLEAR lv_num.
      LOOP AT gt_1010 INTO DATA(ls_1010).
        ADD 1 TO lv_num.
        CLEAR lv_fieldname.
        lv_fieldname = 'GONG_' && lv_num.
        CLEAR lv_fieldname2.
        lv_fieldname2 = ls_1010-fld_06.
        SELECT SINGLE datatype FROM dd03l
          INTO @DATA(lv_type)
          WHERE tabname = @ls_1010-fld_05
            AND fieldname = @ls_1010-fld_06.
        CASE  lv_type.
          WHEN 'DEC'.
            IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
            ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_disp> TO <lv_value>.

            CLEAR lv_dec.
            lv_dec = ls_char-(lv_fieldname2).
            <lv_value> = lv_dec.
            CONDENSE <lv_value>.
          WHEN OTHERS.
            <ls_disp>-(lv_fieldname) = ls_char-(lv_fieldname2).
        ENDCASE.
      ENDLOOP.
    ENDIF.

*  연속 생산정보
    READ TABLE lt_2120_infor INTO DATA(ls_infor) WITH KEY cptype = '01'
                                                                        matnr = ls_2120-matnr
                                                                        idnrk = ls_2120-idnrk.
    IF sy-subrc EQ 0.
      <ls_disp>-vgwrt01 = ls_infor-vgwrt.
    ENDIF.
* 교체소요일
    READ TABLE lt_2120_infor INTO ls_infor WITH KEY cptype = '02'
                                                                         matnr = ls_2120-matnr
                                                                          idnrk = ls_2120-idnrk.
    IF sy-subrc EQ 0.
      <ls_disp>-vgwrt02 = ls_infor-vgwrt.
    ENDIF.

* 선속
    <ls_disp>-vgwrt03 = ls_2120-vgwrt.
* 일생산량
    CLEAR lv_plmng.
    PERFORM cal_day_plmng USING ls_2120-vgwrt ls_2120-vgweh CHANGING lv_plmng.
    <ls_disp>-day_length = lv_plmng.
  ENDLOOP.

  DELETE gt_disp_meterial WHERE day_length = 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0300 .

  CREATE OBJECT go_docking_0300
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
*화면 분할
  CREATE OBJECT go_splitter_0300
    EXPORTING
      parent  = go_docking_0300
      rows    = 2
      columns = 1.

  go_splitter_0300->set_row_height(
    EXPORTING
      id                =    1              " Row ID
      height            =    15 ).             " Height

* top 컨테이너
  CALL METHOD go_splitter_0300->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_contain_top_0300.
* bottom 컨테이너
  CALL METHOD go_splitter_0300->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_contain_0300.

  CREATE OBJECT go_grid_0300
    EXPORTING
      i_parent      = go_contain_0300
      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0300 .

  CLEAR gs_layout_0300.
  gs_layout_0300-cwidth_opt = abap_true.
  gs_layout_0300-no_rowins = abap_true.
  gs_layout_0300-stylefname = 'CELLTAB'.
  gs_layout_0300-sel_mode  = 'D'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0300 .

  DATA : lt_celltab TYPE lvc_t_styl.
  DATA : ls_celltab TYPE lvc_s_styl.
  FIELD-SYMBOLS <lt_celltab> TYPE any.

  LOOP AT gt_disp_meterial ASSIGNING FIELD-SYMBOL(<ls_data>).
    REFRESH lt_celltab.

    LOOP AT gt_fieldcat_0300 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
      CASE <ls_fcat>-fieldname.
        WHEN 'SPEC' OR 'MATNR' OR 'IDNRK'.
          CLEAR ls_celltab.
          ls_celltab-fieldname = <ls_fcat>-fieldname.
          ls_celltab-style = alv_style_color_int_key.
          INSERT ls_celltab INTO TABLE lt_celltab.
      ENDCASE.
    ENDLOOP.

    IF <lt_celltab> IS ASSIGNED. UNASSIGN <lt_celltab>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <ls_data> TO <lt_celltab>.
    IF <lt_celltab> IS ASSIGNED.
      <lt_celltab> = lt_celltab.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0300 .

  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0300
        USING : cl_gui_alv_grid=>mc_fc_excl_all.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0300_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0300_display .

  CALL METHOD go_grid_0300->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0300
      it_toolbar_excluding = gt_exclude_0300
    CHANGING
      it_outtab            = gt_disp_meterial
      it_fieldcatalog      = gt_fieldcat_0300.

  IF go_dd_docu_0300 IS BOUND.
    CALL METHOD go_dd_docu_0300->initialize_document.
  ELSE.
    CREATE OBJECT go_dd_docu_0300
      EXPORTING
        style = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD go_grid_0300->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = go_dd_docu_0300.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0300 .

  DATA : lv_num(2) TYPE n.
  DATA : lv_fieldname TYPE fieldname.
  DATA : lv_pos_no TYPE i.
  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR2080TOP'
      i_internal_tabname     = 'GS_DISP_METERIAL'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  REFRESH gt_fieldcat_0300.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0300[]
    TABLES
      it_data         = gt_disp_meterial
    EXCEPTIONS
      OTHERS          = 1.

  CLEAR lv_num.
  lv_pos_no = 3.
  DO 10 TIMES.
    ADD 1 TO lv_num.
    ADD 1 TO lv_pos_no.
    lv_fieldname = 'GONG_' && lv_num.
    READ TABLE gt_fieldcat_0300 ASSIGNING FIELD-SYMBOL(<ls_fcat>) WITH KEY fieldname = lv_fieldname.
    IF sy-subrc NE 0.
      APPEND INITIAL LINE TO gt_fieldcat_0300 ASSIGNING <ls_fcat>.
      <ls_fcat>-col_pos = lv_pos_no.
      <ls_fcat>-fieldname = lv_fieldname.
      <ls_fcat>-datatype = 'CHAR'.
      <ls_fcat>-dd_outlen = '30'.
    ENDIF.

    READ TABLE gt_1010 INTO DATA(ls_1010) INDEX lv_num.
    IF sy-subrc EQ 0.
      <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = ls_1010-fld_04.
    ELSE.
      <ls_fcat>-no_out = abap_true.
    ENDIF.
  ENDDO.

  LOOP AT gt_fieldcat_0300 ASSIGNING <ls_fcat>.
    CASE   <ls_fcat>-fieldname.
      WHEN 'SPEC'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '규격'(f02).
        <ls_fcat>-just = 'L'.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '완제품코드'(f08).
        <ls_fcat>-just = 'C'.
      WHEN 'IDNRK'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '반제품코드'(f09).
        <ls_fcat>-just = 'C'.
      WHEN 'VGWRT01'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '연속생산일.'(f15).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-decimals = 1.
      WHEN 'VGWRT02'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '교체소요일'(f16).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-decimals = 1.
      WHEN 'VGWRT03'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '선속'(f17).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-decimals = 3.
      WHEN 'VGWEH'.
        <ls_fcat>-no_out = abap_true.
      WHEN 'DAY_LENGTH'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '일생산량'(f18).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-decimals = 3.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_0300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PO_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM set_title_0300  CHANGING po_dyndoc_id  TYPE REF TO  cl_dd_document.

  DATA : lv_text(255) TYPE c.

* 설비(작업장)
  CLEAR lv_text.
  CONCATENATE '설비(작업장) :' gv_300_top INTO lv_text SEPARATED BY space.

  "텍스트 추가
  CALL METHOD po_dyndoc_id->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = '20'.

  CALL METHOD po_dyndoc_id->new_line.


  "위쪽에 추가한 텍스트 출력
  CALL METHOD go_dd_docu_0300->display_document
    EXPORTING
      parent = go_contain_top_0300.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM double_click  USING    p_sender TYPE REF TO cl_gui_alv_grid
                            p_row TYPE lvc_s_row
                            p_column TYPE lvc_s_col.

  CASE p_sender.
    WHEN go_grid_0100.
      READ TABLE <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_data>) INDEX p_row-index.
      CLEAR gs_main_data.
      MOVE-CORRESPONDING <ls_data> TO gs_main_data.
      IF gs_main_data-chk_jojang IS NOT INITIAL.
        PERFORM call_zgtppr2050 USING gs_main_data-plnid.

      ENDIF.

    WHEN go_grid_0300.
      CLEAR gs_disp_meterial.
      READ TABLE gt_disp_meterial INTO gs_disp_meterial INDEX p_row-index.
      IF sy-subrc EQ 0.
        gs_disp_meterial-usechk = abap_true.

        CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
          EXPORTING
            functioncode           = 'OKAY2'              " Function code
          EXCEPTIONS
            function_not_supported = 1                " Not supported on this front end platform
            OTHERS                 = 2.

      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_MATERIAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_ERR_CHK
*&---------------------------------------------------------------------*
FORM chk_material  CHANGING pv_err_chk.

  DATA : lt_row TYPE lvc_t_row.
  DATA : ls_row TYPE lvc_s_row.

  CALL METHOD go_grid_0300->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  DELETE lt_row WHERE index = 0. " 서브토탈 제외
  IF lt_row[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 계획자재가 없습니다'(e13).
    pv_err_chk = abap_true.
    RETURN.
  ENDIF.

  IF lines( lt_row[] ) > 1.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의 자재만 선택해야 합니다.'(e14).
    pv_err_chk = abap_true.
    RETURN.
  ENDIF.

  CLEAR gs_disp_meterial.
  READ TABLE lt_row INTO ls_row INDEX 1.
  READ TABLE gt_disp_meterial INTO gs_disp_meterial INDEX ls_row-index.
  IF sy-subrc EQ 0.
    gs_disp_meterial-usechk = abap_true.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_LINE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_DATA>
*&---------------------------------------------------------------------*
FORM init_line_data  CHANGING ps_data LIKE gs_maintain_plan.

  DELETE gt_2090 WHERE arbpl = ps_data-arbpl
                            AND plnid = ps_data-plnid.

  DELETE gt_2091 WHERE arbpl = ps_data-arbpl
                              AND plnid = ps_data-plnid.

  DELETE gt_2120_use WHERE spec = ps_data-spec
                                       AND arbpl = ps_data-arbpl
                                       AND idnrk = gs_main_data-idnrk
                                       AND matnr = gs_main_data-matnr.

  ps_data-mode = 'C'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CAPA_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_PLAN>
*&      --> LV_MATNR
*&      --> IV_IDNRK
*&---------------------------------------------------------------------*
FORM get_capa_data  USING    ps_plan LIKE gs_maintain_plan
                             pv_matnr TYPE matnr
                             pv_idnrk TYPE idnrk.

  DATA : ls_2120 TYPE zgtppt2120.

* capa 테이블에 선속이 0이 아닌건 추출
  SELECT SINGLE * FROM zgtppt2120
    INTO ls_2120
    WHERE werks = p_werks
      AND spgcd = p_spgcd
      AND spec = ps_plan-spec
      AND arbpl = ps_plan-arbpl
      AND idnrk = pv_idnrk
      AND cptype = '03'
      AND vgwrt NE 0
*      AND MATNR = PV_MATNR
      AND zstate <> ' '.
  IF sy-subrc EQ 0.
    pv_matnr = ps_plan-matnr.
    pv_idnrk = ls_2120-idnrk.
    APPEND ls_2120 TO gt_2120_use.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_DAY_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_del_day_plan .

  DATA : lt_column TYPE lvc_t_col.
  DATA : lt_del_data TYPE TABLE OF sy-datum.
  DATA : lv_date TYPE sy-datum.
  DATA : lv_message(100).

  IF gv_status_confirm = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션으로 수정할 수 없습니다.'(e09).
    RETURN.
  ENDIF.

  go_grid_0100->get_selected_columns(
      IMPORTING
        et_index_columns = lt_column ).                " Cell IDs

  IF lt_column[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '선택된 컬럼이 없습니다.'(e15).
    RETURN.
  ENDIF.

  REFRESH lt_del_data.
  LOOP AT lt_column INTO DATA(ls_colum).
    IF NOT ls_colum-fieldname BETWEEN gv_bgn_dt AND gv_end_dt.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '생산 일자 행을 선택해 주세요'(e16).
      RETURN.
    ENDIF.

    lv_date = ls_colum-fieldname.
    COLLECT lv_date INTO lt_del_data.

  ENDLOOP.

  IF lines( lt_del_data ) = 1.
    READ TABLE lt_del_data INTO lv_date INDEX 1.
    lv_message = lv_date+4(2) &&'/' && lv_date+6(2).
    CONCATENATE lv_message '의 생산계획이 모두 삭제됩니다. 진행하시겠습니까?' INTO lv_message SEPARATED BY space.
  ELSE.
    CONCATENATE '선택된 일자' '의 생산계획이 모두 삭제됩니다. 진행하시겠습니까?' INTO lv_message.
  ENDIF.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    lv_message
    '삭제확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
    RETURN.
  ENDIF.

  LOOP AT lt_del_data INTO lv_date.
    DELETE gt_2091 WHERE pltype NE '03' AND pldat = lv_date.
  ENDLOOP.

  PERFORM set_disp_table.
  PERFORM refresh_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_AUTO_CREATE_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_auto_create_plan .

  DATA : lv_row TYPE i.
  DATA : ls_col_id TYPE lvc_s_col.
  DATA : ls_main_data LIKE gs_main_data.
  DATA : lv_fieldname TYPE fieldname.
  DATA : lv_chk_date TYPE sy-datum.
  DATA : lt_2091 TYPE TABLE OF zgtppt2091.
  FIELD-SYMBOLS : <lv_day_value> TYPE any.
  FIELD-SYMBOLS : <lv_day_chk> TYPE any.

  DEFINE __get_day_field.
*  날짜별 수량 필드
    CLEAR lv_fieldname.
    lv_fieldname = &1.
    IF <lv_day_value> IS ASSIGNED. UNASSIGN <lv_day_value>. ENDIF.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main> TO <lv_day_value>.
*  날짜별 체크필드
    CLEAR lv_fieldname.
    lv_fieldname = &1 && '_CHK'.
    IF <lv_day_chk> IS ASSIGNED. UNASSIGN <lv_day_chk>. ENDIF.
    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main> TO <lv_day_chk>.
  END-OF-DEFINITION.


  IF gv_status_confirm = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션으로 수정할 수 없습니다.'(e09).
    RETURN.
  ENDIF.

  go_grid_0100->get_current_cell(
    IMPORTING
      e_row     =  lv_row                " Row on Grid
      es_col_id =  ls_col_id ).               " colum ID

  READ TABLE <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX lv_row.
  MOVE-CORRESPONDING <ls_main> TO ls_main_data.
*  정합성 검증
  IF ls_main_data-sum_chk IS NOT INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '수정 불가능한 라인입니다.'(e17).
    RETURN.
  ENDIF.

  IF ls_main_data-idnrk IS INITIAL.
    MESSAGE s005 DISPLAY LIKE 'E' WITH '선택한 규격의 설비 Capa를 확인 할 수 없습니다.'(e18) '입력된 반제품을 확인해 주세요.'(e19).
    RETURN.
  ENDIF.

  IF NOT ls_col_id-fieldname BETWEEN gv_bgn_dt AND gv_end_dt.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '생산 일자 행을 선택해 주세요'(e16).
    RETURN.
  ENDIF.

  __get_day_field ls_col_id-fieldname.
  IF <lv_day_chk> = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '설비 비가동 일정에 작업을 입력 할 수 없습니다.'(e19).
    RETURN.
  ENDIF.


  REFRESH lt_2091.
  lt_2091 = VALUE #( FOR lw_2091 IN gt_2091 WHERE ( arbpl = ls_main_data-arbpl
                                                                AND   plnid = ls_main_data-plnid
                                                                AND   ( pltype EQ '01'
                                                                 OR     pltype EQ '02' )
                                                                AND   pldat >= ls_col_id-fieldname )
                            ( CORRESPONDING #( lw_2091 ) ) ).

  IF lt_2091[] IS NOT INITIAL.

    CLEAR gv_answer.
    PERFORM popup_to_confirm_step USING 'N'
      ' '
      '이미 입력된 내역을 덮어쓰게 됩니다. 계속 진행하시겠습니까?'
      '입력확인'.
    IF gv_answer NE 'J'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
      RETURN.
    ENDIF.
  ENDIF.

  lv_chk_date = ls_col_id-fieldname.
  DELETE gt_2091 WHERE arbpl = ls_main_data-arbpl
  AND plnid = ls_main_data-plnid
  AND pldat >= lv_chk_date
  AND ( pltype = '01'
   OR   pltype ='02' ).

  PERFORM set_line_auto USING ls_main_data lv_chk_date.

  PERFORM set_disp_table.
  PERFORM refresh_0100.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LINE_AUTO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MAIN_DATA
*&      --> LS_COL_ID_FIELDNAME
*&---------------------------------------------------------------------*
FORM set_line_auto  USING    ps_main_data LIKE gs_main_data
                                            pv_date .

  DATA : lv_chk_date TYPE sy-datum.
  DATA : ls_2120 TYPE zgtppt2120.
  DATA : ls_2120_02 TYPE zgtppt2120. "
  DATA : ls_2120_01 TYPE zgtppt2120.
  DATA : lt_2091 TYPE TABLE OF zgtppt2091.
  DATA : ls_2091_init TYPE zgtppt2091.
  DATA : lv_plmng TYPE zgtppt2091-plmng.
  DATA : lv_plmng_cal TYPE zgtppt2091-plmng.
  DATA : lv_plmng_sum TYPE zgtppt2091-plmng.
  DATA : lv_plmng_po TYPE i.
  DATA : lv_plmng_no TYPE i.
  DATA : lv_current_idx TYPE i.
  DATA : lv_available_plmng TYPE zgtppt2091-plmng.
  DATA : lv_idx TYPE i.
  DATA : lv_chk_err.

* 시뮬레이션 가용수량 ( 판매수량 - 확정수량 )
  lv_available_plmng = ps_main_data-quantity_dp - ps_main_data-menge.
* 기존 다른 설비 시뮬레이션 입력된 수량도 가용수량 제외대상
  LOOP AT gt_2091 INTO DATA(ls_2091_cal) WHERE plnid = ps_main_data-plnid AND pltype = '01'.
    lv_available_plmng = lv_available_plmng - ls_2091_cal-plmng.
  ENDLOOP.


* 기본정보 리드 (캐파정보- 선속) _일자별 선속 계산후 상태처리를 위해 기본 정보 가지고 있는다.
  CLEAR ls_2120.
  READ TABLE gt_2120_use INTO ls_2120 WITH KEY spec = ps_main_data-spec
                                                                        cptype = '03'
                                                                        idnrk = ps_main_data-idnrk
                                                                       arbpl = ps_main_data-arbpl.
* 일별 선속정보 구하기
  CLEAR lv_plmng.
  PERFORM cal_day_plmng USING ls_2120-vgwrt ls_2120-vgweh CHANGING lv_plmng.

* 세팅시 소수점 버림으로 표현
  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      i_rtype     = '-'
      i_runit     = 1
      i_value     = lv_plmng
    IMPORTING
      e_value_rnd = lv_plmng.

* 기본정보 리드 (캐파정보- 연속생산일 구하기)
  CLEAR lv_plmng_po.
  CLEAR ls_2120_01.
  READ TABLE gt_2120_use INTO ls_2120_01 WITH KEY spec = ps_main_data-spec
                                                                           cptype = '01'
                                                                           idnrk = ps_main_data-idnrk.
  IF sy-subrc EQ 0.
    lv_plmng_po = ls_2120_01-vgwrt.
  ENDIF.


* 기본정보 리드 (캐파정보- 교체소요일 구하기)
  CLEAR lv_plmng_no.
  CLEAR ls_2120_01.
  READ TABLE gt_2120_use INTO ls_2120_02 WITH KEY spec = ps_main_data-spec
                                                                           cptype = '02'
                                                                           idnrk = ps_main_data-idnrk.
  IF sy-subrc EQ 0.
    lv_plmng_no = lv_plmng_po + ls_2120_02-vgwrt.
  ENDIF.

  lv_chk_date = pv_date.

* 해당 라인정보만 가져와서 컨트롤하기
  lt_2091 = VALUE #( FOR lw_2091 IN gt_2091 WHERE ( arbpl = ps_main_data-arbpl
                                                                     AND  plnid = ps_main_data-plnid )
                                                  ( CORRESPONDING #( lw_2091 ) ) ).

  IF lv_available_plmng <= 0.
    RETURN.
  ENDIF.

* 선택날짜 이후데이터 삭제(비가동 정보 제외)
  DELETE lt_2091 WHERE pltype <> '03' AND pldat >= lv_chk_date.

  CLEAR lv_idx.
  CLEAR lv_plmng_sum.
* 생산량 세팅
  DO.
    IF lv_chk_date > gv_end_dt.
      EXIT.
    ENDIF.

* 비가동은 건너 띄어준다.
    READ TABLE lt_2091 TRANSPORTING NO FIELDS WITH KEY pltype = '03'
                                                                                pldat = lv_chk_date.
    IF sy-subrc EQ 0.
      ADD 1 TO lv_chk_date.
      CONTINUE.
    ENDIF.

*** 조장구성표에서 스케줄링된 날짜는 건너뛴다.
**    READ TABLE GT_SCHEDULE INTO GS_SCHEDULE WITH KEY ARBPL = PS_MAIN_DATA-ARBPL
**                                                                               DATE = LV_CHK_DATE.
**
**    IF SY-SUBRC EQ 0.
**      ADD 1 TO LV_CHK_DATE.
**      CONTINUE.
**    ENDIF.

    ADD 1 TO lv_idx.

    ADD 1 TO lv_current_idx.

*  연속 생산부터 시작
    IF lv_current_idx <=  lv_plmng_po.
      CLEAR ls_2091_init.
      CLEAR lv_chk_err.

      CLEAR lv_chk_err.
      PERFORM chk_available_first_line USING ps_main_data lv_chk_date lv_plmng CHANGING ls_2091_init lv_chk_err.
      IF lv_chk_err = abap_true.
        ADD 1 TO lv_chk_date.
        lv_current_idx = lv_current_idx - 1.
        CONTINUE.
      ENDIF.

      lv_plmng_sum = lv_plmng_sum + ls_2091_init-plmng.
*      ELSE.
*        PERFORM SET_NEW_2091_01 USING PS_MAIN_DATA LV_CHK_DATE LV_PLMNG CHANGING LS_2091_INIT.
*        LV_PLMNG_SUM = LV_PLMNG_SUM + LV_PLMNG.
*      ENDIF.

*   연속 수량 입력시 가용 수량 넘어가면 가용수량에 맞추어 수량 입력후 종료
      IF lv_available_plmng = lv_plmng_sum.
        APPEND ls_2091_init TO gt_2091.
        EXIT.
      ELSEIF lv_available_plmng < lv_plmng_sum.
        ls_2091_init-plmng = lv_available_plmng - lv_plmng_sum + ls_2091_init-plmng.
        APPEND ls_2091_init TO gt_2091.

        lv_plmng_sum = lv_available_plmng.
        EXIT.

      ENDIF.
    ELSE.
      CLEAR ls_2091_init.
      PERFORM set_new_2091_02 USING ps_main_data lv_chk_date CHANGING ls_2091_init.

      IF lv_current_idx <  lv_plmng_no.
      ELSEIF lv_current_idx =  lv_plmng_no. " 청소 세팅후 다시 순환
        CLEAR lv_current_idx.
      ENDIF.
    ENDIF.

    APPEND ls_2091_init TO gt_2091.

    ADD 1 TO lv_chk_date.

  ENDDO.

  READ TABLE gt_maintain_plan ASSIGNING FIELD-SYMBOL(<ls_maintain>) WITH KEY plnid = ps_main_data-plnid
                                                                                                                     arbpl = ps_main_data-arbpl.
  IF sy-subrc EQ 0.
    <ls_maintain>-simul_mng = lv_plmng_sum.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_NEW_2091_01
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_MAIN_DATA
*&      --> LV_CHK_DATE
*&      --> LV_PLMNG
*&      <-- LS_2091_INIT
*&---------------------------------------------------------------------*
FORM set_new_2091_01  USING    ps_main_data LIKE gs_main_data
                                                pv_chk_date TYPE sy-datum
                                                pv_plmng TYPE zgtppt2091-plmng
                               CHANGING    ps_2091 TYPE zgtppt2091.

  ps_2091-werks = p_werks.
  ps_2091-spgcd = p_spgcd.
  ps_2091-simno = gv_simno.
  ps_2091-simvr = gv_simvr.
  ps_2091-arbpl = ps_main_data-arbpl.
  ps_2091-plnid = ps_main_data-plnid.
  ps_2091-pldat = pv_chk_date.
  ps_2091-pltype = '01'.
  ps_2091-plmng = pv_plmng.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_NEW_2091_02
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_MAIN_DATA
*&      --> LV_CHK_DATE
*&      <-- LS_2091_INIT
*&---------------------------------------------------------------------*
FORM set_new_2091_02  USING    ps_main_data LIKE gs_main_data
                                                pv_chk_date TYPE sy-datum
                               CHANGING    ps_2091 TYPE zgtppt2091.

  ps_2091-werks = p_werks.
  ps_2091-spgcd = p_spgcd.
  ps_2091-simno = gv_simno.
  ps_2091-simvr = gv_simvr.
  ps_2091-arbpl = ps_main_data-arbpl.
  ps_2091-plnid = ps_main_data-plnid.
  ps_2091-pldat = pv_chk_date.
  ps_2091-pltype = '02'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MANUAL_CREATE_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_manual_create_plan .

  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lt_chg_date TYPE TABLE OF sy-datum.
  DATA : lv_date TYPE sy-datum.
  DATA : ls_main_data LIKE gs_main_data.
  DATA : lt_2091 TYPE TABLE OF zgtppt2091.
  DATA : ls_2091_init TYPE zgtppt2091.
  DATA : ls_2120 TYPE zgtppt2120.
  DATA : ls_2120_02 TYPE zgtppt2120. "
  DATA : ls_2120_01 TYPE zgtppt2120.
  DATA : lv_message(100).
  DATA : lv_chk_overwrite.
  DATA : lv_plmng TYPE zgtppt2091-plmng.
  DATA : lv_plmng_po TYPE i.
  DATA : lv_plmng_no TYPE i.
  DATA : lv_plmng_sum TYPE zgtppt2091-plmng.
  DATA : lv_available_plmng TYPE zgtppt2091-plmng.
  DATA : lv_current_idx TYPE i.
  DATA : lv_idx TYPE i.
  DATA : lv_chk_err.

  IF gv_status_confirm = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션으로 수정할 수 없습니다.'(e09).
    RETURN.
  ENDIF.

  go_grid_0100->get_selected_cells_id(
      IMPORTING
       et_cells = lt_cells ).                " Cell IDs

  DATA(lt_cell_chk) = lt_cells.

  IF lt_cells[] IS INITIAL.
    RETURN.
  ENDIF.

  SORT lt_cell_chk BY row_id.
  DELETE ADJACENT DUPLICATES FROM lt_cell_chk COMPARING row_id.
  IF lines( lt_cell_chk ) > 1.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '생산(수동) 은 한 라인만 처리 할 수 있습니다.'(e21).
    RETURN.
  ENDIF.

  READ TABLE lt_cells INTO DATA(ls_cells) INDEX 1.
  READ TABLE <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX ls_cells-row_id.
  MOVE-CORRESPONDING <ls_main> TO ls_main_data.

*  정합성 검증
  IF ls_main_data-sum_chk IS NOT INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '수정 불가능한 라인입니다.'(e17).
    RETURN.
  ENDIF.

  IF ls_main_data-idnrk IS INITIAL.
    MESSAGE s005 DISPLAY LIKE 'E' WITH '선택한 규격의 설비 Capa를 확인 할 수 없습니다.'(e18) '입력된 반제품을 확인해 주세요.'(e19).
    RETURN.
  ENDIF.

  SORT lt_cells BY col_id.
* 가용한 날짜 필드 인지 확인
  LOOP AT lt_cells INTO ls_cells.
    READ TABLE gt_fieldcat_0100 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF NOT ls_fcat-fieldname BETWEEN gv_bgn_dt AND gv_end_dt.
      MESSAGE s005 DISPLAY LIKE 'E' WITH ls_fcat-reptext '는(은) 생산(수동) 가능한 필드가 아닙니다.'(e20).
      RETURN.
    ENDIF.

* 비가동 일정이나 다른 값들이 포함되어있으면 작업불가.
    lv_date = ls_fcat-fieldname.
    READ TABLE gt_2091 INTO DATA(ls_2091) WITH KEY arbpl = ls_main_data-arbpl
                                                                            plnid = ls_main_data-plnid
                                                                            pldat = lv_date.
    IF sy-subrc EQ 0.
      CASE ls_2091-pltype.
        WHEN '03'.
          MESSAGE s003 DISPLAY LIKE 'E' WITH '설비 비가동 일정에 작업을 입력 할 수 없습니다.'(e19).
          RETURN.
        WHEN OTHERS.
          lv_chk_overwrite = abap_true.
      ENDCASE.
    ENDIF.

    COLLECT lv_date INTO lt_chg_date.

  ENDLOOP.

  IF lv_chk_overwrite IS NOT INITIAL.
    CLEAR gv_answer.
    PERFORM popup_to_confirm_step USING 'N'
      ' '
      '이미 입력된 내역을 덮어쓰게 됩니다. 계속 진행하시겠습니까?'
      '입력확인'.
    IF gv_answer NE 'J'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
      RETURN.
    ENDIF.
    LOOP AT lt_chg_date INTO lv_date.
      DELETE gt_2091 WHERE arbpl = ls_main_data-arbpl
                                  AND plnid = ls_main_data-plnid
                                  AND pldat = lv_date
                                  AND pltype NE '03'.
    ENDLOOP.

  ENDIF.



* 선택된 일정에 생산 계획 시작
  lv_available_plmng = ls_main_data-quantity_dp - ls_main_data-menge.
* 기존 다른 설비 시뮬레이션 입력된 수량도 가용수량 제외대상
  LOOP AT gt_2091 INTO DATA(ls_2091_cal) WHERE plnid = ls_main_data-plnid AND pltype = '01' AND arbpl NE ls_main_data-arbpl.
    lv_available_plmng = lv_available_plmng - ls_2091_cal-plmng.
  ENDLOOP.


* 기본정보 리드 (캐파정보- 선속) _일자별 선속 계산후 상태처리를 위해 기본 정보 가지고 있는다.
  CLEAR ls_2120.
  READ TABLE gt_2120_use INTO ls_2120 WITH KEY spec = ls_main_data-spec
                                                                        cptype = '03'
                                                                        idnrk = ls_main_data-idnrk
                                                                       arbpl = ls_main_data-arbpl.
* 일별 선속정보 구하기
  CLEAR lv_plmng.
  PERFORM cal_day_plmng USING ls_2120-vgwrt ls_2120-vgweh CHANGING lv_plmng.

* 세팅시 소수점 버림으로 표현
  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      i_rtype     = '-'
      i_runit     = 1
      i_value     = lv_plmng
    IMPORTING
      e_value_rnd = lv_plmng.

* 기본정보 리드 (캐파정보- 연속생산일 구하기)
  CLEAR lv_plmng_po.
  CLEAR ls_2120_01.
  READ TABLE gt_2120_use INTO ls_2120_01 WITH KEY spec = ls_main_data-spec
                                                                           cptype = '01'
                                                                           idnrk = ls_main_data-idnrk.
  IF sy-subrc EQ 0.
    lv_plmng_po = ls_2120_01-vgwrt.
  ENDIF.


* 기본정보 리드 (캐파정보- 교체소요일 구하기)
  CLEAR lv_plmng_no.
  CLEAR ls_2120_01.
  READ TABLE gt_2120_use INTO ls_2120_02 WITH KEY spec = ls_main_data-spec
                                                                           cptype = '02'
                                                                           idnrk = ls_main_data-idnrk.
  IF sy-subrc EQ 0.
    lv_plmng_no = lv_plmng_po + ls_2120_02-vgwrt.
  ENDIF.

* 해당 라인정보만 가져와서 컨트롤하기
  lt_2091 = VALUE #( FOR lw_2091 IN gt_2091 WHERE ( arbpl = ls_main_data-arbpl
                                                                     AND  plnid = ls_main_data-plnid )
                                                  ( CORRESPONDING #( lw_2091 ) ) ).

  IF lv_available_plmng <= 0.
    RETURN.
  ENDIF.

* 수량 계산을 위해 남아있는 수량 정보 섬
  CLEAR lv_plmng_sum.
  LOOP AT lt_2091 INTO ls_2091 WHERE pltype = '01'.
    lv_plmng_sum = lv_plmng_sum + ls_2091-plmng.
  ENDLOOP.

* 생산량 세팅
  LOOP AT lt_chg_date INTO DATA(lv_chk_date).
* 비가동은 건너 띄어준다.
    READ TABLE lt_2091 TRANSPORTING NO FIELDS WITH KEY pltype = '03'
                                                                                   pldat = lv_chk_date.
    IF sy-subrc EQ 0.
      CONTINUE.
    ENDIF.

*** 조장구성표에서 스케줄링된 날짜는 건너뛴다.
**    READ TABLE GT_SCHEDULE INTO GS_SCHEDULE WITH KEY ARBPL = LS_MAIN_DATA-ARBPL
**                                                                               DATE = LV_CHK_DATE.
**
**    IF SY-SUBRC EQ 0.
**      ADD 1 TO LV_CHK_DATE.
**      CONTINUE.
**    ENDIF.

    ADD 1 TO lv_current_idx.

    ADD 1 TO lv_idx.

*  연속 생산부터 시작
    IF lv_current_idx <=  lv_plmng_po.
      CLEAR ls_2091_init.
      CLEAR lv_chk_err.

*      IF LV_IDX = 1. " 수량 적용시 최초 일자는 해당설비의 전체 케파 조회후 수량 생성
      CLEAR lv_chk_err.
      PERFORM chk_available_first_line USING ls_main_data lv_chk_date lv_plmng CHANGING ls_2091_init lv_chk_err.
      IF lv_chk_err = abap_true.
        ADD 1 TO lv_chk_date.
        lv_current_idx = lv_current_idx - 1.
        CONTINUE.
      ENDIF.

      lv_plmng_sum = lv_plmng_sum + ls_2091_init-plmng.
*      ELSE.
*        PERFORM SET_NEW_2091_01 USING LS_MAIN_DATA LV_CHK_DATE LV_PLMNG CHANGING LS_2091_INIT.
*        LV_PLMNG_SUM = LV_PLMNG_SUM + LV_PLMNG.
*      ENDIF.

*   연속 수량 입력시 가용 수량 넘어가면 가용수량에 맞추어 수량 입력후 종료
      IF lv_available_plmng = lv_plmng_sum.
        APPEND ls_2091_init TO gt_2091.
        EXIT.
      ELSEIF lv_available_plmng < lv_plmng_sum.
        ls_2091_init-plmng = lv_available_plmng - lv_plmng_sum + ls_2091_init-plmng.
        APPEND ls_2091_init TO gt_2091.

        lv_plmng_sum = lv_available_plmng.
        EXIT.

      ENDIF.
    ELSE.
      CLEAR ls_2091_init.
      PERFORM set_new_2091_02 USING ls_main_data lv_chk_date CHANGING ls_2091_init.

      IF lv_current_idx <  lv_plmng_no.
      ELSEIF lv_current_idx =  lv_plmng_no. " 청소 세팅후 다시 순환
        CLEAR lv_current_idx.
      ENDIF.
    ENDIF.

    APPEND ls_2091_init TO gt_2091.

  ENDLOOP.

  PERFORM set_disp_table.
  PERFORM refresh_0100.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_SET_CLEAN_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_set_clean_plan .

  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : ls_main_data LIKE gs_main_data.
  DATA : lv_chk_overwrite.
  DATA : ls_2091_init TYPE zgtppt2091.
  DATA : lv_date TYPE sy-datum.

  IF gv_status_confirm = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션으로 수정할 수 없습니다.'(e09).
    RETURN.
  ENDIF.

  go_grid_0100->get_selected_cells_id(
      IMPORTING
       et_cells = lt_cells ).                " Cell IDs

  DATA(lt_cell_chk) = lt_cells.

  IF lt_cells[] IS INITIAL.
    RETURN.
  ENDIF.

  READ TABLE lt_cells INTO DATA(ls_cells) INDEX 1.
  READ TABLE <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX ls_cells-row_id.
  MOVE-CORRESPONDING <ls_main> TO ls_main_data.

* 가용한 날짜 필드 인지 확인
  LOOP AT lt_cells INTO ls_cells.
    READ TABLE gt_fieldcat_0100 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF NOT ls_fcat-fieldname BETWEEN gv_bgn_dt AND gv_end_dt.
      MESSAGE s005 DISPLAY LIKE 'E' WITH ls_fcat-reptext '는(은) 생산(수동) 가능한 필드가 아닙니다.'(e20).
      RETURN.
    ENDIF.

* 비가동 일정이나 다른 값들이 포함되어있으면 작업불가.
    READ TABLE <gt_main_disp_100> ASSIGNING <ls_main> INDEX ls_cells-row_id.
    MOVE-CORRESPONDING <ls_main> TO ls_main_data.

    IF ls_main_data-sum_chk IS NOT INITIAL. "섬필드는 가용수량 변경없음
      CONTINUE.
    ENDIF.

    IF ls_main_data-plnid IS INITIAL. "판매계획이 매핑되지 않은 필드는 수정금지
      CONTINUE.
    ENDIF.

    lv_date = ls_fcat-fieldname.
    READ TABLE gt_2091 INTO DATA(ls_2091) WITH KEY arbpl = ls_main_data-arbpl
                                                                           plnid = ls_main_data-plnid
                                                                           pldat = lv_date.
    IF sy-subrc EQ 0.
      CASE ls_2091-pltype.
        WHEN '03'.
          MESSAGE s003 DISPLAY LIKE 'E' WITH '설비 비가동 일정에 작업을 입력 할 수 없습니다.'(e19).
          RETURN.
        WHEN OTHERS.
          lv_chk_overwrite = abap_true.
      ENDCASE.
    ENDIF.

* 조장구성표에서 스케줄링된 날짜는 건너뛴다.
    READ TABLE gt_schedule INTO gs_schedule WITH KEY arbpl = ls_main_data-arbpl
                                                                               date = lv_date.

    IF sy-subrc EQ 0.
      MESSAGE s006 DISPLAY LIKE 'E' WITH '이미 조장구성표에서 스케줄링되어'(e42) '수정이 불가능한 일자입니다.'(e43).
      RETURN.
    ENDIF.

  ENDLOOP.

  IF lv_chk_overwrite IS NOT INITIAL.
    CLEAR gv_answer.
    PERFORM popup_to_confirm_step USING 'N'
      ' '
      '이미 입력된 내역을 덮어쓰게 됩니다. 계속 진행하시겠습니까?'
      '입력확인'.
    IF gv_answer NE 'J'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
      RETURN.
    ENDIF.

  ENDIF.

  LOOP AT lt_cells INTO ls_cells.
    READ TABLE <gt_main_disp_100> ASSIGNING <ls_main> INDEX ls_cells-row_id.
    MOVE-CORRESPONDING <ls_main> TO ls_main_data.

    IF ls_main_data-sum_chk IS NOT INITIAL. "섬필드는 가용수량 변경없음
      CONTINUE.
    ENDIF.

    IF ls_main_data-plnid IS INITIAL. "판매계획이 매핑되지 않은 필드는 수정금지
      CONTINUE.
    ENDIF.

    READ TABLE gt_fieldcat_0100 INTO ls_fcat INDEX ls_cells-col_id.
    lv_date = ls_fcat-fieldname.

    READ TABLE gt_2091 INTO ls_2091 WITH KEY arbpl = ls_main_data-arbpl
                                                                   plnid = ls_main_data-plnid
                                                                   pldat = lv_date.
    IF sy-subrc EQ 0 AND ls_2091-pltype NE '3'.
      DELETE gt_2091 WHERE arbpl = ls_main_data-arbpl
                                  AND plnid = ls_main_data-plnid
                                  AND pldat = lv_date.
    ENDIF.

    CLEAR ls_2091_init.
    PERFORM set_new_2091_02 USING ls_main_data lv_date CHANGING ls_2091_init.

    APPEND ls_2091_init TO gt_2091.
  ENDLOOP.

  PERFORM set_disp_table.
  PERFORM refresh_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_SELECTED_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_del_selected_plan .

  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : ls_main_data LIKE gs_main_data.
  DATA : lv_chk_overwrite.
  DATA : ls_2091_init TYPE zgtppt2091.
  DATA : lv_date TYPE sy-datum.

  IF gv_status_confirm = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션으로 수정할 수 없습니다.'(e09).
    RETURN.
  ENDIF.

  go_grid_0100->get_selected_cells_id(
      IMPORTING
       et_cells = lt_cells ).                " Cell IDs

  DATA(lt_cell_chk) = lt_cells.

  IF lt_cells[] IS INITIAL.
    RETURN.
  ENDIF.

* 가용한 날짜 필드 인지 확인
  LOOP AT lt_cells INTO DATA(ls_cells).
    READ TABLE gt_fieldcat_0100 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF NOT ls_fcat-fieldname BETWEEN gv_bgn_dt AND gv_end_dt.
      MESSAGE s005 DISPLAY LIKE 'E' WITH ls_fcat-reptext '는(은) 삭제 가능한 필드가 아닙니다.'(e22).
      RETURN.
    ENDIF.

* 비가동 일정이나 다른 값들이 포함되어있으면 작업불가.
    READ TABLE <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX ls_cells-row_id.
    MOVE-CORRESPONDING <ls_main> TO ls_main_data.

    IF ls_main_data-sum_chk IS NOT INITIAL. "섬필드는 가용수량 변경없음
      CONTINUE.
    ENDIF.

    IF ls_main_data-plnid IS INITIAL. "판매계획이 매핑되지 않은 필드는 수정금지
      CONTINUE.
    ENDIF.

    lv_date = ls_fcat-fieldname.
    READ TABLE gt_2091 INTO DATA(ls_2091) WITH KEY arbpl = ls_main_data-arbpl
                                                                           plnid = ls_main_data-plnid
                                                                           pldat = lv_date.
    IF sy-subrc EQ 0.
      lv_chk_overwrite = abap_true.

    ENDIF.

  ENDLOOP.

  IF lv_chk_overwrite IS NOT INITIAL.
    CLEAR gv_answer.
    PERFORM popup_to_confirm_step USING 'N'
      ' '
      '선택한 셀을 삭제합니다. 계속 진행하시겠습니까?'
      '삭제확인'.
    IF gv_answer NE 'J'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
      RETURN.
    ENDIF.

  ENDIF.

  LOOP AT lt_cells INTO ls_cells.
    READ TABLE <gt_main_disp_100> ASSIGNING <ls_main> INDEX ls_cells-row_id.
    MOVE-CORRESPONDING <ls_main> TO ls_main_data.

    IF ls_main_data-sum_chk IS NOT INITIAL. "섬필드는 가용수량 변경없음
      CONTINUE.
    ENDIF.

    IF ls_main_data-plnid IS INITIAL. "판매계획이 매핑되지 않은 필드는 수정금지
      CONTINUE.
    ENDIF.

    READ TABLE gt_fieldcat_0100 INTO ls_fcat INDEX ls_cells-col_id.
    lv_date = ls_fcat-fieldname.

    READ TABLE gt_2091 INTO ls_2091 WITH KEY arbpl = ls_main_data-arbpl
                                                                   plnid = ls_main_data-plnid
                                                                   pldat = lv_date.
    IF sy-subrc EQ 0 AND ls_2091-pltype NE '03'.
      DELETE gt_2091 WHERE arbpl = ls_main_data-arbpl
                                  AND plnid = ls_main_data-plnid
                                  AND pldat = lv_date.
    ENDIF.

  ENDLOOP.

  PERFORM set_disp_table.
  PERFORM refresh_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CHG_PLMNG_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_chg_plmng_plan .

  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : ls_main_data LIKE gs_main_data.
  DATA : lv_chk_overwrite.
  DATA : ls_2091_init TYPE zgtppt2091.
  DATA : lv_date TYPE sy-datum.
  DATA : lv_plmng TYPE zgtppt2091-plmng.
  DATA : lv_chk_err.
  DATA : lv_text TYPE char20.

  IF gv_status_confirm = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션으로 수정할 수 없습니다.'(e09).
    RETURN.
  ENDIF.

  go_grid_0100->get_selected_cells_id(
      IMPORTING
       et_cells = lt_cells ).                " Cell IDs

  DATA(lt_cell_chk) = lt_cells.

  IF lt_cells[] IS INITIAL.
    RETURN.
  ENDIF.

  IF lines( lt_cells ) > 1.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '하나의 수량셀만 수정할 수 있습니다.'(e23).
    RETURN.
  ENDIF.

  READ TABLE lt_cells INTO DATA(ls_cells) INDEX 1.
  READ TABLE <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX ls_cells-row_id.
  MOVE-CORRESPONDING <ls_main> TO ls_main_data.

  READ TABLE gt_fieldcat_0100 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
  IF NOT ls_fcat-fieldname BETWEEN gv_bgn_dt AND gv_end_dt.
    MESSAGE s005 DISPLAY LIKE 'E' WITH ls_fcat-reptext '는(은) 생산계획 수량 필드가 아닙니다.'(e24).
    RETURN.
  ENDIF.

* 비가동 일정이나 다른 값들이 포함되어있으면 작업불가.
  IF ls_main_data-sum_chk IS NOT INITIAL. "섬필드는 가용수량 변경없음
    RETURN.
  ENDIF.

  IF ls_main_data-plnid IS INITIAL. "판매계획이 매핑되지 않은 필드는 수정금지
    RETURN.
  ENDIF.

  lv_date = ls_fcat-fieldname.

*** 조장구성표에서 스케줄링된 날짜는 건너뛴다.
**  READ TABLE GT_SCHEDULE INTO GS_SCHEDULE WITH KEY ARBPL = LS_MAIN_DATA-ARBPL
**                                                                             DATE = LV_DATE.
**
**  IF SY-SUBRC EQ 0.
**    MESSAGE S006 DISPLAY LIKE 'E' WITH '이미 조장구성표에서 스케줄링되어'(E42) '수정이 불가능한 일자입니다.'(E43).
**    RETURN.
**  ENDIF.

  READ TABLE gt_2091 ASSIGNING FIELD-SYMBOL(<ls_2091>) WITH KEY arbpl = ls_main_data-arbpl
                                                                                                  plnid = ls_main_data-plnid
                                                                                                  pldat = lv_date.
  IF sy-subrc EQ 0.
    CASE <ls_2091>-pltype.
      WHEN '03'.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '설비 비가동 일정에 작업을 입력 할 수 없습니다.'(e19).
        RETURN.
      WHEN OTHERS.
        CLEAR lv_text.
        IF <ls_2091>-pltype = '02'.
          lv_text = '청소'.
        ELSE.
          WRITE <ls_2091>-plmng TO lv_text NO-GAP UNIT ls_main_data-meins RIGHT-JUSTIFIED.
        ENDIF.
* POPUP_GET_VALUES
    ENDCASE.
  ELSE.
    CLEAR lv_text.
    APPEND INITIAL LINE TO gt_2091 ASSIGNING <ls_2091>.
    PERFORM set_new_2091_01 USING ls_main_data lv_date lv_plmng CHANGING <ls_2091>.
  ENDIF.

  PERFORM get_amt_from_popup USING lv_text ls_main_data-meins
                                            CHANGING lv_plmng lv_chk_err.
  IF lv_chk_err IS INITIAL.
    <ls_2091>-pltype = '01'.
    <ls_2091>-plmng = lv_plmng.
  ENDIF.


  PERFORM set_disp_table.
  PERFORM refresh_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_AMT_FROM_POPUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_2091>_PLTYPE
*&      --> LV_TEXT
*&      --> LS_MAIN_DATA_MEINS
*&      <-- LV_PLMNG
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM get_amt_from_popup  USING    pv_text
                                                       pv_unit TYPE meins
                                      CHANGING    pv_plmng TYPE zgtppt2091-plmng
                                                       pv_chk_err.

  DATA : lv_return_code TYPE c.
  DATA : lt_field TYPE TABLE OF sval.

  APPEND INITIAL LINE TO lt_field ASSIGNING FIELD-SYMBOL(<ls_field>).
  <ls_field>-tabname = 'TLSYS'.
  <ls_field>-fieldname = 'SYSTEM'.
  <ls_field>-value = pv_text.
  <ls_field>-field_attr = '02'.
  <ls_field>-fieldtext = '현재 계획수량'.

  APPEND INITIAL LINE TO lt_field ASSIGNING <ls_field>.
  <ls_field>-fieldtext = '변경 계획수량'.
  <ls_field>-tabname = 'ZGTPPT2091'.
  <ls_field>-fieldname = 'PLMNG'.
  <ls_field>-field_obl = abap_true.


  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title     = '계획수량 입력'
*     START_COLUMN    = '5'
*     START_ROW       = '5'
    IMPORTING
      returncode      = lv_return_code
    TABLES
      fields          = lt_field
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  IF lv_return_code = 'A'. " 취소로 종료시
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.


  READ TABLE lt_field INTO DATA(ls_field) INDEX 2.
  pv_plmng = ls_field-value.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data  USING pv_mode. " U는 변경, I 버젼 신규 생성

  DATA : lv_chk_new.
  DATA : lv_simno TYPE zgtppt2090-simno.
  DATA : lv_simvr TYPE zgtppt2090-simvr.
  DATA : lv_num(3) TYPE n.
  DATA : lt_redo_zgtppt2090 TYPE TABLE OF zgtppt2090.
  DATA : lt_redo_zgtppt2091 TYPE TABLE OF zgtppt2091.

  CASE pv_mode.
    WHEN 'I'." " 버전업을 위한,
      SELECT SINGLE MAX( simvr ) AS simvr FROM zgtppt2090
          INTO lv_simvr
         WHERE werks = p_werks
             AND spgcd = p_spgcd
             AND simno = gv_simno.


      gv_simvr = lv_simvr + 1.
*    기존데이터 삭제 없이 진행
*   - 신규 번호만 채번시       ZGTPPT2091 만 삭제

    WHEN 'U'." 현재 버전에 저장

      IF gv_simno IS INITIAL.""신규 시뮬레이션은 시뮬레이션 번호가 없으므로 채번
        lv_chk_new = abap_true.
      ELSE. "신규 채번이 아닐시 기존 데이터 삭제후 어팬드
        SELECT * FROM zgtppt2090
          INTO TABLE lt_redo_zgtppt2090
         WHERE werks = p_werks
             AND spgcd = p_spgcd
             AND simty IN gr_simty
             AND simno = gv_simno
             AND simvr = gv_simvr.
        IF sy-subrc EQ 0.
          DELETE FROM zgtppt2090 WHERE werks = p_werks
                                                    AND spgcd = p_spgcd
                                                    AND simno = gv_simno
                                                    AND simvr = gv_simvr.
          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.
          ELSE.
            ROLLBACK WORK.
            MESSAGE s003 DISPLAY LIKE 'E' WITH '월간생산계획저장 중 오류 발생하였습니다.'(e28).
            RETURN.
          ENDIF.
        ENDIF.

        SELECT * FROM zgtppt2091
            INTO TABLE lt_redo_zgtppt2091
         WHERE werks = p_werks
             AND spgcd = p_spgcd
             AND simno = gv_simno
             AND simvr = gv_simvr.
        IF sy-subrc EQ 0.
          DELETE FROM zgtppt2091 WHERE werks = p_werks
                                                    AND spgcd = p_spgcd
                                                    AND simno = gv_simno
                                                    AND simvr = gv_simvr.
          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.
          ELSE.
            ROLLBACK WORK.
            MESSAGE s003 DISPLAY LIKE 'E' WITH '월간생산계획저장 중 오류 발생하였습니다.'(e28).
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.

  IF lv_chk_new IS NOT INITIAL.
*    "SIM" + SPG코드 + 현재연도(2) + 현재월(2) + MAX연번(3)
    lv_simno = 'SIM' && p_spgcd && sy-datum+2(4) && '%'.

    SELECT SINGLE MAX( simno ) AS simno
      INTO gv_simno
      FROM zgtppt2090
      WHERE spgcd = p_spgcd
         AND simno LIKE lv_simno.

    IF gv_simno IS NOT INITIAL.
      lv_num = gv_simno+9(3) + 1.
      gv_simno+9(3) = lv_num.
    ELSE.
      gv_simno = 'SIM' && p_spgcd && sy-datum+2(4) && '001'.
    ENDIF.
  ENDIF.

  LOOP AT gt_2090 ASSIGNING FIELD-SYMBOL(<lt_2090>).
    <lt_2090>-simty = p_simty.
    <lt_2090>-simno = gv_simno.
    <lt_2090>-simvr = gv_simvr.
    <lt_2090>-simnm = gv_simnm.
    IF <lt_2090>-ernam IS INITIAL OR pv_mode = 'I'.
      <lt_2090>-erdat = sy-datum.
      <lt_2090>-ernam = sy-uname.
    ENDIF.
    <lt_2090>-aedat = sy-datum.
    <lt_2090>-aenam = sy-uname.
  ENDLOOP.

  LOOP AT gt_2091 ASSIGNING FIELD-SYMBOL(<lt_2091>).
    <lt_2091>-simno = gv_simno.
    <lt_2091>-simvr = gv_simvr.
  ENDLOOP.

  IF gt_2090[] IS NOT INITIAL.

* 순번적용
    PERFORM set_seqno TABLES gt_2090.

    MODIFY zgtppt2090 FROM TABLE gt_2090.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
      IF lt_redo_zgtppt2090[] IS NOT INITIAL.
        MODIFY zgtppt2090 FROM TABLE lt_redo_zgtppt2090.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '월간생산계획저장 중 오류 발생하였습니다.'(e28).
        RETURN.
      ENDIF.
    ENDIF.

  ENDIF.

  IF gt_2091[] IS NOT INITIAL.

    MODIFY zgtppt2091 FROM TABLE gt_2091.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
      IF lt_redo_zgtppt2091[] IS NOT INITIAL.
        MODIFY zgtppt2091 FROM TABLE lt_redo_zgtppt2091.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '월간생산계획저장 중 오류 발생하였습니다.'(e28).
        RETURN.
      ENDIF.
    ENDIF.

  ENDIF.

  CASE pv_mode.
    WHEN 'U'.
      MESSAGE s000 WITH gv_simno 'ver' gv_simvr '월간 생산계획이 저장되었습니다.'(e29).
    WHEN 'I'.
      MESSAGE s000 WITH gv_simno 'ver' gv_simvr '월간 생산계획이 생성되었습니다.'(e31).
  ENDCASE.
  PERFORM set_disp_table.

  PERFORM refresh_0100.

  CLEAR gv_chk_edit.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PLAN_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_plan_data .

  DATA : lt_2080 TYPE TABLE OF zgtppt2080.
  DATA : lv_idx TYPE i.

  DATA : BEGIN OF ls_collect_2090,
           plnid TYPE zgtppt2090-plnid,
*           ARBPL TYPE ZGTPPT2090-ARBPL,
           plmng TYPE zgtppt2091-plmng,
         END OF ls_collect_2090.
  DATA : lt_collect_2090 LIKE TABLE OF ls_collect_2090.
  DATA : lv_tabix TYPE i.
  DATA : lv_zpjno TYPE zsd0106t-zpjno.

  REFRESH gt_2090.
  REFRESH gt_2091.

  SELECT * FROM zgtppt2090
      INTO CORRESPONDING FIELDS OF TABLE gt_2090
    WHERE werks = p_werks
      AND spgcd = p_spgcd
      AND simty IN gr_simty
      AND simno = gv_simno
      AND simvr = gv_simvr
      AND arbpl IN s_arbpl.

  IF gt_2090 IS INITIAL.
    MESSAGE s006 DISPLAY LIKE 'E' WITH '조회결과가 없습니다.'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  SELECT * FROM zgtppt2091
      INTO CORRESPONDING FIELDS OF TABLE gt_2091
    WHERE werks = p_werks
      AND spgcd = p_spgcd
      AND simno = gv_simno
      AND simvr = gv_simvr
    AND arbpl IN s_arbpl.

*  생산계획을 수립할 판매계획 조회( 추출 기준 월간 생산계획 -> 판매계획 조회 -> 확정수량 조회
  IF gt_2090[] IS NOT INITIAL.
    SELECT * FROM zgtppt2080
      INTO CORRESPONDING FIELDS OF TABLE @lt_2080
       FOR ALL ENTRIES IN @gt_2090
    WHERE werks = @p_werks
         AND spgcd = @p_spgcd
         AND plnid = @gt_2090-plnid
         AND spec IN @s_spec
         AND zpjno IN @s_zpjno
        AND delfl <> @abap_true.
  ENDIF.

  IF line_exists( gt_2090[ plcnf = abap_true ] ).
    gv_status_confirm = abap_true.
  ENDIF.

* 판매계획 대상 조회
  DATA(lt_chk_2080) = lt_2080.
  SORT lt_chk_2080 BY cycltype vkbur spec zpjno vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_2080 COMPARING cycltype vkbur spec zpjno vbeln posnr.

*SRM2603-10362 판매계획 조회를 위해서 추가
  DATA(lt_temp_2080) = lt_chk_2080.
  SORT lt_temp_2080 BY cycltype vkbur spec zpjno.
  DELETE ADJACENT DUPLICATES FROM lt_temp_2080 COMPARING cycltype vkbur spec zpjno.

  IF lt_temp_2080[] IS NOT INITIAL.
    SELECT * FROM zgtcvsalesplan
        FOR ALL ENTRIES IN @lt_temp_2080
      WHERE cycltype = @lt_temp_2080-cycltype
         AND vkbur = @lt_temp_2080-vkbur
         AND spec = @lt_temp_2080-spec
         AND zpjno = @lt_temp_2080-zpjno
      INTO TABLE @DATA(lt_salesplan).
  ENDIF.
*SRM2603-10362

  SORT lt_salesplan BY cycltype vkbur spec zpjno vbeln posnr.

* 확정대상 조회
  DATA(lt_chk_conf) = lt_2080.
  SORT lt_chk_conf BY werks spgcd plnid.
  DELETE ADJACENT DUPLICATES FROM lt_chk_conf COMPARING werks spgcd plnid.
  IF lt_chk_conf[] IS NOT INITIAL.
    SELECT a~plnid, a~simno, a~simvr, a~arbpl, a~pldat, b~matnr, b~idnrk, a~plmng
      FROM zgtppt2091 AS a
      INNER JOIN zgtppt2090 AS b ON b~simno = a~simno
                                            AND b~simvr = a~simvr
                                            AND b~plnid = a~plnid
      FOR ALL ENTRIES IN @lt_chk_conf
     WHERE a~werks = @lt_chk_conf-werks
       AND a~spgcd = @lt_chk_conf-spgcd
       AND a~plnid = @lt_chk_conf-plnid
       AND a~pldat < @gv_bgn_dt   " 시뮬레이션 기준 월도 확정수량은 포함안함
       AND b~plcnf = @abap_true
       AND b~simty IN @gr_simty " 동일한 시뮬레이션 타입끼리 비교
       AND a~pltype = '01'
      INTO TABLE @DATA(lt_2090).

    LOOP AT lt_2090 INTO DATA(ls_2090).
      CLEAR ls_collect_2090.
      MOVE-CORRESPONDING ls_2090 TO ls_collect_2090.
      COLLECT ls_collect_2090 INTO lt_collect_2090.
    ENDLOOP.

  ENDIF.

  REFRESH gt_maintain_plan.
  SORT gt_2090 BY plnid.

* 모인데이터 수량 콜렉트
  LOOP AT lt_chk_conf INTO DATA(ls_chk_conf).
    CLEAR gs_maintain_plan.

    REFRESH lt_chk_2080.
    lt_chk_2080 = VALUE #( FOR lw_2080 IN lt_2080 WHERE ( plnid = ls_chk_conf-plnid )
                                                                             ( CORRESPONDING #( lw_2080 ) ) ).

*   판매수량
    CLEAR lv_idx.
    LOOP AT lt_chk_2080 INTO DATA(ls_chk_2080).
      READ TABLE lt_salesplan INTO DATA(ls_salesplan) WITH KEY cycltype = ls_chk_2080-cycltype
                                                                                         vkbur = ls_chk_2080-vkbur
                                                                                         spec = ls_chk_2080-spec
                                                                                         zpjno = ls_chk_2080-zpjno
                                                                                         vbeln = ls_chk_2080-vbeln
                                                                                         posnr = ls_chk_2080-posnr
                                                                                         BINARY SEARCH.
      IF sy-subrc EQ 0.
        ADD 1 TO lv_idx.
        IF lv_idx = 1.
          gs_maintain_plan-plnid = ls_chk_conf-plnid.
          gs_maintain_plan-spec = ls_chk_2080-spec.
          gs_maintain_plan-zpjno = ls_chk_2080-zpjno.
* 프로젝트내역 추가
          IF ls_salesplan-zptxt IS INITIAL AND ls_salesplan-zpjno IS NOT INITIAL.
            TRY.
                CLEAR lv_zpjno.
                lv_zpjno = ls_salesplan-zpjno && '%'.
                SELECT SINGLE zptxt FROM zsd0106t
                  INTO gs_maintain_plan-zptxt
                  WHERE zpjno LIKE lv_zpjno
                    AND spart = ls_salesplan-spart.

              CATCH cx_root.
            ENDTRY.
          ELSE.
            gs_maintain_plan-zptxt = ls_salesplan-zptxt.
          ENDIF.

          gs_maintain_plan-spmon = ls_salesplan-basemonth.
          gs_maintain_plan-kunnr = ls_salesplan-kunnr.
          IF ls_salesplan-kunnr IS NOT INITIAL.
            SELECT SINGLE name1 FROM kna1
                INTO gs_disp_plan-name1
              WHERE kunnr = ls_salesplan-kunnr
                AND spras = sy-langu.
          ENDIF.
          gs_maintain_plan-meins = ls_chk_2080-meins.
          gs_maintain_plan-matnr = ls_chk_2080-matnr.
          gs_maintain_plan-sul_no = ls_chk_2080-sul_no.
        ENDIF.
*SRM2603-13210 FT단위 환산 처리
        IF ls_chk_2080-meins NE ls_salesplan-vrkme.

          PERFORM unit_conversion USING ls_chk_2080-meins
                                                                 ls_salesplan-vrkme
                                                       CHANGING ls_salesplan-quantity_dp.

        ENDIF.
*SRM2603-13210

        gs_maintain_plan-quantity_dp = gs_maintain_plan-quantity_dp + ls_salesplan-quantity_dp.
      ELSE.
        READ TABLE lt_salesplan INTO ls_salesplan WITH KEY cycltype = ls_chk_2080-cycltype
                                                                                         vkbur = ls_chk_2080-vkbur
                                                                                         spec = ls_chk_2080-spec
                                                                                         zpjno = ls_chk_2080-zpjno.
        IF sy-subrc EQ 0.
          ADD 1 TO lv_idx.
          IF lv_idx = 1.
            gs_maintain_plan-plnid = ls_chk_conf-plnid.
            gs_maintain_plan-spec = ls_chk_2080-spec.
            gs_maintain_plan-zpjno = ls_chk_2080-zpjno.
* 프로젝트내역 추가
            IF ls_salesplan-zptxt IS INITIAL AND ls_salesplan-zpjno IS NOT INITIAL.
              TRY.
                  CLEAR lv_zpjno.
                  lv_zpjno = ls_salesplan-zpjno && '%'.
                  SELECT SINGLE zptxt FROM zsd0106t
                    INTO gs_maintain_plan-zptxt
                    WHERE zpjno LIKE lv_zpjno
                      AND spart = ls_salesplan-spart.

                CATCH cx_root.
              ENDTRY.
            ELSE.
              gs_maintain_plan-zptxt = ls_salesplan-zptxt.
            ENDIF.
            gs_maintain_plan-spmon = ls_salesplan-basemonth.
            gs_maintain_plan-kunnr = ls_salesplan-kunnr.
            IF ls_salesplan-kunnr IS NOT INITIAL.
              SELECT SINGLE name1 FROM kna1
                  INTO gs_disp_plan-name1
                WHERE kunnr = ls_salesplan-kunnr
                  AND spras = sy-langu.
            ENDIF.
            gs_maintain_plan-meins = ls_chk_2080-meins.
            gs_maintain_plan-matnr = ls_chk_2080-matnr.
            gs_maintain_plan-sul_no = ls_chk_2080-sul_no.
          ENDIF.
*        일치하는 판매오더, 품목이 없을경우 수량 정보는 더해주지 않는다.
*        GS_MAINTAIN_PLAN-QUANTITY_DP = GS_MAINTAIN_PLAN-QUANTITY_DP + LS_SALESPLAN-QUANTITY_DP.
        ENDIF.
      ENDIF.

    ENDLOOP.

    CLEAR lv_tabix.
    READ TABLE gt_2090 INTO DATA(ls_chk_2090) WITH KEY plnid = ls_chk_conf-plnid.
    IF sy-subrc EQ 0.
      LOOP AT gt_2090 INTO ls_chk_2090 FROM sy-tabix.
        IF NOT ls_chk_2090-plnid = ls_chk_conf-plnid.
          EXIT.
        ENDIF.
        ADD 1 TO lv_tabix.
*        IF LV_TABIX = 1.

        READ TABLE gt_arbpl INTO gs_arbpl WITH KEY arbpl = ls_chk_2090-arbpl.
        gs_maintain_plan-arbpl = gs_arbpl-arbpl.
        gs_maintain_plan-ktext = gs_arbpl-ktext.

        PERFORM get_capa_data USING gs_maintain_plan ls_chk_2090-matnr ls_chk_2090-idnrk.
        PERFORM get_capainfor_data USING gs_maintain_plan ls_chk_2090-matnr ls_chk_2090-idnrk.
*        ENDIF.

*  확정수량
        READ TABLE lt_collect_2090 INTO ls_collect_2090 WITH KEY plnid = ls_chk_conf-plnid
                                                                                                  .
        IF sy-subrc EQ 0.
          gs_maintain_plan-plmng = ls_collect_2090-plmng.
        ENDIF.

*        조회 순번 적용
        IF ls_chk_2090-arbpl = gs_arbpl-arbpl.
          gs_maintain_plan-seqno_d = ls_chk_2090-seqno.
        ENDIF.

        APPEND gs_maintain_plan TO gt_maintain_plan.
      ENDLOOP.
    ENDIF.

  ENDLOOP.


  PERFORM set_disp_table.
*  PERFORM REFRESH_0100.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_CAPA_PER_DAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ARBPL_ARBPL
*&      --> LV_CHK_DT
*&      <-- <LV_DAY_CHK>
*&      <-- ADD
*&      <-- 1
*&      <-- TO
*&      <-- LV_CHK_DT
*&---------------------------------------------------------------------*
FORM cal_capa_per_day  USING    pv_arbpl TYPE arbpl
                                pv_data TYPE sy-datum
                       CHANGING pv_chk.

  DATA : lv_rate TYPE p LENGTH 15 DECIMALS 5.
  DATA : lv_rate_sum TYPE p LENGTH 15 DECIMALS 5.
  DATA : lv_plmng TYPE zgtppt2091-plmng.
  DATA : lv_tabix TYPE i.
  DATA : ls_2120 TYPE zgtppt2120.

  LOOP AT gt_2091 INTO DATA(ls_2091) WHERE arbpl = pv_arbpl
                                                  AND pldat = pv_data
                                                  AND pltype = '01'.


    READ TABLE gt_maintain_plan INTO DATA(ls_plan) WITH KEY plnid = ls_2091-plnid
                                                                                         arbpl = ls_2091-arbpl.

    READ TABLE gt_2090 INTO DATA(ls_2090) WITH KEY plnid = ls_2091-plnid
                                                                         arbpl = ls_2091-arbpl.

* 기본정보 리드 (캐파정보- 선속) _일자별 선속 계산후 상태처리를 위해 기본 정보 가지고 있는다.
    CLEAR ls_2120.
    READ TABLE gt_2120_use INTO ls_2120 WITH KEY spec = ls_plan-spec
                                                                          cptype = '03'
                                                                          idnrk = ls_2090-idnrk
                                                                         arbpl = pv_arbpl.
* 일별 선속정보 구하기
    CLEAR lv_plmng.
    PERFORM cal_day_plmng USING ls_2120-vgwrt ls_2120-vgweh CHANGING lv_plmng.

    ADD 1 TO lv_tabix.

    CLEAR lv_rate.
    IF lv_plmng NE 0.
      lv_rate = ls_2091-plmng / lv_plmng.
    ELSE.
      lv_rate = 1.
    ENDIF.

    ADD lv_rate TO lv_rate_sum.

  ENDLOOP.

  CHECK lv_tabix >= 1.

  IF lv_rate_sum > 1.
    pv_chk = 'U'.
  ELSEIF lv_rate_sum < 1.
    pv_chk = 'D'.
  ELSE.
    pv_chk = 'N'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CAPAINFOR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_MAINTAIN_PLAN
*&      --> LS_CHK_2090_MATNR
*&      --> LS_CHK_2090_IDNRK
*&---------------------------------------------------------------------*
FORM get_capainfor_data  USING    ps_plan LIKE gs_maintain_plan
                             pv_matnr TYPE matnr
                             pv_idnrk TYPE idnrk.

* 추후 계산을 위한 선속정보 업데이트
  SELECT * FROM zgtppt2120
    APPENDING CORRESPONDING FIELDS OF TABLE gt_2120_use
    WHERE werks = p_werks
      AND spgcd = p_spgcd
      AND spec = ps_plan-spec
      AND idnrk = pv_idnrk
      AND cptype IN ( '01', '02' )
*      AND MATNR = PV_MATNR
      AND zstate <> ' '.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CRT_NEW_VER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_crt_new_ver .

  IF gv_status_confirm = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션으로 수정할 수 없습니다.'(e09).
    RETURN.
  ENDIF.

  IF gv_chk_edit IS NOT INITIAL.
    MESSAGE s005 DISPLAY LIKE 'E' WITH '변경 내역이 있습니다. 저장후 생성가능합니다.'(e30).
    RETURN.
  ENDIF.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '월간 생산 계획 버젼 신규 생성 하시겠습니까?'
    '생성확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '생성 취소 되었습니다.'.
    RETURN.
  ENDIF.

  DELETE gt_2091 WHERE pltype EQ '01' OR pltype EQ '02'.

  PERFORM save_data USING 'I'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CRT_COPY_VER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_crt_copy_ver .

  IF gv_status_confirm = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션으로 수정할 수 없습니다.'(e09).
    RETURN.
  ENDIF.

  IF gv_chk_edit IS NOT INITIAL.
    MESSAGE s005 DISPLAY LIKE 'E' WITH '변경 내역이 있습니다. 저장후 생성가능합니다.'(e30).
    RETURN.
  ENDIF.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '월간 생산 계획 버젼 복사 생성 하시겠습니까?'
    '생성확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '생성 취소 되었습니다.'.
    RETURN.
  ENDIF.

  PERFORM save_data USING 'I'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MANUAL_USE_INPUT_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_manual_use_input_plan .

  DATA : lt_cells TYPE lvc_t_ceno.
  DATA : lt_chg_date TYPE TABLE OF sy-datum.
  DATA : lv_date TYPE sy-datum.
  DATA : ls_main_data LIKE gs_main_data.
  DATA : lt_2091 TYPE TABLE OF zgtppt2091.
  DATA : ls_2091_init TYPE zgtppt2091.
  DATA : ls_2120 TYPE zgtppt2120.
  DATA : ls_2120_02 TYPE zgtppt2120. "
  DATA : ls_2120_01 TYPE zgtppt2120.
  DATA : lv_message(100).
  DATA : lv_chk_overwrite.
  DATA : lv_plmng TYPE zgtppt2091-plmng.
  DATA : lv_plmng_po TYPE i.
  DATA : lv_plmng_no TYPE i.
  DATA : lv_plmng_sum TYPE zgtppt2091-plmng.
  DATA : lv_available_plmng TYPE zgtppt2091-plmng.
  DATA : lv_current_idx TYPE i.


  IF gv_status_confirm = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션으로 수정할 수 없습니다.'(e09).
    RETURN.
  ENDIF.

  go_grid_0100->get_selected_cells_id(
      IMPORTING
       et_cells = lt_cells ).                " Cell IDs

  DATA(lt_cell_chk) = lt_cells.

  IF lt_cells[] IS INITIAL.
    RETURN.
  ENDIF.

  SORT lt_cell_chk BY row_id.
  DELETE ADJACENT DUPLICATES FROM lt_cell_chk COMPARING row_id.
  IF lines( lt_cell_chk ) > 1.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '생산(수량입력) 은 한 라인만 처리 할 수 있습니다.'(e21).
    RETURN.
  ENDIF.

  READ TABLE lt_cells INTO DATA(ls_cells) INDEX 1.
  READ TABLE <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX ls_cells-row_id.
  MOVE-CORRESPONDING <ls_main> TO ls_main_data.

*  정합성 검증
  IF ls_main_data-sum_chk IS NOT INITIAL.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '수정 불가능한 라인입니다.'(e17).
    RETURN.
  ENDIF.

  IF ls_main_data-idnrk IS INITIAL.
    MESSAGE s005 DISPLAY LIKE 'E' WITH '선택한 규격의 설비 Capa를 확인 할 수 없습니다.'(e18) '입력된 반제품을 확인해 주세요.'(e19).
    RETURN.
  ENDIF.

  SORT lt_cells BY col_id.
* 가용한 날짜 필드 인지 확인
  LOOP AT lt_cells INTO ls_cells.
    READ TABLE gt_fieldcat_0100 INTO DATA(ls_fcat) INDEX ls_cells-col_id.
    IF NOT ls_fcat-fieldname BETWEEN gv_bgn_dt AND gv_end_dt.
      MESSAGE s005 DISPLAY LIKE 'E' WITH ls_fcat-reptext '는(은) 생산(수동) 가능한 필드가 아닙니다.'(e20).
      RETURN.
    ENDIF.

* 비가동 일정이나 다른 값들이 포함되어있으면 작업불가.
    lv_date = ls_fcat-fieldname.
    READ TABLE gt_2091 INTO DATA(ls_2091) WITH KEY arbpl = ls_main_data-arbpl
                                                                            plnid = ls_main_data-plnid
                                                                            pldat = lv_date.
    IF sy-subrc EQ 0.
      CASE ls_2091-pltype.
        WHEN '03'.
          MESSAGE s003 DISPLAY LIKE 'E' WITH '설비 비가동 일정에 작업을 입력 할 수 없습니다.'(e19).
          RETURN.
        WHEN OTHERS.
          lv_chk_overwrite = abap_true.
      ENDCASE.
    ENDIF.

*** 조장구성표에서 스케줄링된 날짜는 건너뛴다.
**    READ TABLE GT_SCHEDULE INTO GS_SCHEDULE WITH KEY ARBPL = LS_MAIN_DATA-ARBPL
**                                                                               DATE = LV_DATE.
**
**    IF SY-SUBRC EQ 0.
**      MESSAGE S006 DISPLAY LIKE 'E' WITH '이미 조장구성표에서 스케줄링되어'(E42) '수정이 불가능한 일자입니다.'(E43).
**      RETURN.
**    ENDIF.

    COLLECT lv_date INTO lt_chg_date.

  ENDLOOP.

  IF lv_chk_overwrite IS NOT INITIAL.
    CLEAR gv_answer.
    PERFORM popup_to_confirm_step USING 'N'
      ' '
      '이미 입력된 내역을 덮어쓰게 됩니다. 계속 진행하시겠습니까?'
      '입력확인'.
    IF gv_answer NE 'J'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
      RETURN.
    ENDIF.
    LOOP AT lt_chg_date INTO lv_date.
      DELETE gt_2091 WHERE arbpl = ls_main_data-arbpl
                                  AND plnid = ls_main_data-plnid
                                  AND pldat = lv_date
                                  AND pltype NE '03'.
    ENDLOOP.

  ENDIF.

  DATA : lv_chk_err.

* 선택된 일정에 생산 계획 시작
  lv_available_plmng = ls_main_data-quantity_dp - ls_main_data-menge.

* 유저 지정 선속
  PERFORM get_capa_unit_popup CHANGING lv_plmng lv_chk_err.
  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.

* 기본정보 리드 (캐파정보- 연속생산일 구하기)
  CLEAR lv_plmng_po.
  CLEAR ls_2120_01.
  READ TABLE gt_2120_use INTO ls_2120_01 WITH KEY spec = ls_main_data-spec
                                                                           cptype = '01'
                                                                           idnrk = ls_main_data-idnrk.
  IF sy-subrc EQ 0.
    lv_plmng_po = ls_2120_01-vgwrt.
  ENDIF.


* 기본정보 리드 (캐파정보- 교체소요일 구하기)
  CLEAR lv_plmng_no.
  CLEAR ls_2120_01.
  READ TABLE gt_2120_use INTO ls_2120_02 WITH KEY spec = ls_main_data-spec
                                                                           cptype = '02'
                                                                           idnrk = ls_main_data-idnrk.
  IF sy-subrc EQ 0.
    lv_plmng_no = lv_plmng_po + ls_2120_02-vgwrt.
  ENDIF.

* 해당 라인정보만 가져와서 컨트롤하기
  lt_2091 = VALUE #( FOR lw_2091 IN gt_2091 WHERE ( arbpl = ls_main_data-arbpl
                                                                     AND  plnid = ls_main_data-plnid )
                                                  ( CORRESPONDING #( lw_2091 ) ) ).

  IF lv_available_plmng <= 0.
    RETURN.
  ENDIF.

* 수량 계산을 위해 남아있는 수량 정보 섬
  CLEAR lv_plmng_sum.
  LOOP AT lt_2091 INTO ls_2091 WHERE pltype = '01'.
    lv_plmng_sum = lv_plmng_sum + ls_2091-plmng.
  ENDLOOP.

* 생산량 세팅
  LOOP AT lt_chg_date INTO DATA(lv_chk_date).
* 비가동은 건너 띄어준다.
    READ TABLE lt_2091 TRANSPORTING NO FIELDS WITH KEY pltype = '03'
                                                                                   pldat = lv_chk_date.
    IF sy-subrc EQ 0.
      CONTINUE.
    ENDIF.

    ADD 1 TO lv_current_idx.


*  연속 생산부터 시작
    IF lv_current_idx <=  lv_plmng_po.
      CLEAR ls_2091_init.
      PERFORM set_new_2091_01 USING ls_main_data lv_chk_date lv_plmng CHANGING ls_2091_init.
    ELSE.
      CLEAR ls_2091_init.
      PERFORM set_new_2091_02 USING ls_main_data lv_chk_date CHANGING ls_2091_init.

      IF lv_current_idx <  lv_plmng_no.
      ELSEIF lv_current_idx =  lv_plmng_no. " 청소 세팅후 다시 순환
        CLEAR lv_current_idx.
      ENDIF.
    ENDIF.

    APPEND ls_2091_init TO gt_2091.

  ENDLOOP.

  PERFORM set_disp_table.
  PERFORM refresh_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CAPA_UNIT_POPUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_PLMNG
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM get_capa_unit_popup  CHANGING pv_plmng  TYPE zgtppt2091-plmng
                                   pv_chk_err.

  DATA : lv_return_code TYPE c.
  DATA : lt_field TYPE TABLE OF sval.

  APPEND INITIAL LINE TO lt_field ASSIGNING FIELD-SYMBOL(<ls_field>).
  <ls_field>-fieldtext = '계획수량'.
  <ls_field>-tabname = 'ZGTPPT2091'.
  <ls_field>-fieldname = 'PLMNG'.
  <ls_field>-field_obl = abap_true.


  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title     = '계획수량 입력'
*     START_COLUMN    = '5'
*     START_ROW       = '5'
    IMPORTING
      returncode      = lv_return_code
    TABLES
      fields          = lt_field
    EXCEPTIONS
      error_in_fields = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.

  IF lv_return_code = 'A'. " 취소로 종료시
    pv_chk_err = abap_true.
    RETURN.
  ENDIF.


  READ TABLE lt_field INTO DATA(ls_field) INDEX 1.
  pv_plmng = ls_field-value.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CONFIRM_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_confirm_process .

  DATA : lt_save_2100 TYPE TABLE OF zgtppt2100.
  DATA : lt_save_2101 TYPE TABLE OF zgtppt2101.
  DATA : lt_save_2102 TYPE TABLE OF zgtppt2102.
  DATA : lt_save_2101_confirm TYPE TABLE OF zgtppt2101.
  DATA : lt_prepare_2090 TYPE TABLE OF zgtppt2090.
  DATA : lt_prepare_2080 TYPE TABLE OF zgtppt2080.
  DATA : lt_prepare_salesplan TYPE TABLE OF zgtcvsalesplan.
  DATA : lv_chk_err.

  DATA : lv_text(100).
* 1.확정전 정합성 점검
* 1)시뮬레이션 번호에 해당하는 버전 중 하나라도 확정이면 계획 확정 진행 불가
  SELECT * FROM zgtppt2090
    WHERE werks = @p_werks
      AND spgcd = @p_spgcd
      AND simno = @gv_simno
      AND plcnf = @abap_true
    INTO TABLE @DATA(lt_chk_2090).
  IF sy-subrc EQ 0.
    READ TABLE lt_chk_2090 INTO DATA(ls_chk_2090) INDEX 1.
    CONCATENATE ls_chk_2090-simnm 'ver' ls_chk_2090-simvr '이 월간 생산계획으로 확정되어 있습니다.' INTO lv_text SEPARATED BY space..
    MESSAGE s003 DISPLAY LIKE 'E' WITH lv_text.
    RETURN.
  ENDIF.

  PERFORM set_indicator USING '20' '시뮬레이션 확정, 공정별 생산 계획 등록 중'.

* 2. 공정별 확정 계획 생성
  lt_prepare_2090 = gt_2090[].
  PERFORM set_gongjung_infor_using_simul TABLES lt_prepare_2090 lt_prepare_2080 lt_prepare_salesplan lt_save_2100 lt_save_2101 lt_save_2102
                                                               CHANGING lv_chk_err.
  IF lv_chk_err IS NOT INITIAL.
    RETURN.
  ENDIF.

  CLEAR gv_answer.
  PERFORM popup_to_confirm_step USING 'N'
    ' '
    '해당 시뮬레이션 확정가능합니다. 확정하시겠습니까?'
    '확정확인'.
  IF gv_answer NE 'J'.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정 취소 되었습니다.'.
    RETURN.
  ENDIF.

  PERFORM set_indicator USING '90' '시뮬레이션 확정, 확정데이터 저장 중'.



* 기존 확정 데이터 존재 확인후 같은 월도에 포함되어 있다면 확정 삭제
  SELECT b~*
    FROM @lt_save_2100 AS a
    INNER JOIN zgtppt2100 AS b ON b~werks = a~werks
                                          AND b~spgcd = a~spgcd
                                          AND b~spmon = a~spmon
    INTO TABLE @DATA(lt_del_2100).

  SELECT b~*
    FROM @lt_save_2100 AS a
    INNER JOIN zgtppt2100 AS b ON b~werks = a~werks
                                          AND b~spgcd = a~spgcd
                                          AND b~zspmon = a~spmon
    WHERE b~spmon IS INITIAL
    APPENDING TABLE @lt_del_2100.

  IF lt_del_2100 IS NOT INITIAL.
    SORT lt_del_2100 BY werks spgcd simno simvr plnid gong_seq gong_cd zspmon spmon matnr arbpl.
    DELETE ADJACENT DUPLICATES FROM lt_del_2100 COMPARING werks spgcd simno simvr plnid gong_seq gong_cd zspmon spmon matnr arbpl.

    DELETE zgtppt2100 FROM TABLE lt_del_2100.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '확정데이터 저장중 오류 발생하였습니다.'(e35).
      RETURN.
    ENDIF.
  ENDIF.

  IF lt_save_2100 IS NOT INITIAL.
    MODIFY zgtppt2100 FROM TABLE lt_save_2100.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '확정데이터 저장중 오류 발생하였습니다.'(e35).
      RETURN.
    ENDIF.
  ENDIF.

* 기존 확정 데이터 존재 확인후 같은 월도에 포함되어 있다면 확정 삭제
  SELECT b~*
    FROM @lt_save_2102 AS a
    INNER JOIN zgtppt2102 AS b ON b~werks = a~werks
                                          AND b~spgcd = a~spgcd
                                          AND b~spmon = a~spmon
    INTO TABLE @DATA(lt_del_2102).

  IF lt_del_2102 IS NOT INITIAL.
    SORT lt_del_2102 BY werks spgcd simno simvr arbpl  plnid gong_seq gong_cd spmon pldat.
    DELETE ADJACENT DUPLICATES FROM lt_del_2102 COMPARING werks spgcd simno simvr arbpl  plnid gong_seq gong_cd spmon pldat.

    DELETE zgtppt2102 FROM TABLE lt_del_2102.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '확정데이터 저장중 오류 발생하였습니다.'(e35).
      RETURN.
    ENDIF.
  ENDIF.

  IF lt_save_2102 IS NOT INITIAL.
    MODIFY zgtppt2102 FROM TABLE lt_save_2102.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '확정데이터 저장중 오류 발생하였습니다.'(e35).
      RETURN.
    ENDIF.
  ENDIF.

  IF p_simty = '2'.
* 기존 확정 데이터 존재 확인후 같은 월도에 포함되어 있다면 확정 삭제
    SELECT b~*
      FROM @lt_save_2101 AS a
      INNER JOIN zgtppt2101 AS b ON b~werks = a~werks
                                            AND b~spgcd = a~spgcd
                                            AND b~bdter = a~bdter
      INTO TABLE @DATA(lt_del_2101).

    IF lt_del_2101 IS NOT INITIAL.
      SORT lt_del_2101 BY werks spgcd simno simvr bdter matnr idnrk.
      DELETE ADJACENT DUPLICATES FROM lt_del_2101 COMPARING werks spgcd simno simvr bdter matnr idnrk.

      DELETE zgtppt2101 FROM TABLE lt_del_2101.
      IF sy-subrc NE 0.
        ROLLBACK WORK.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '확정데이터 저장중 오류 발생하였습니다.'(e35).
        RETURN.
      ENDIF.
    ENDIF.

    IF lt_save_2101 IS NOT INITIAL.
      MODIFY zgtppt2101 FROM TABLE lt_save_2101.
      IF sy-subrc NE 0.
        ROLLBACK WORK.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '확정데이터 저장중 오류 발생하였습니다.'(e35).
        RETURN.
      ENDIF.
    ENDIF.

  ENDIF.

  MOVE-CORRESPONDING lt_prepare_2090 TO gt_2090.
  IF gt_2090 IS NOT INITIAL.
    MODIFY zgtppt2090 FROM TABLE gt_2090.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '확정데이터 저장중 오류 발생하였습니다.'(e35).
      RETURN.
    ENDIF.
  ENDIF.

  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.

    PERFORM set_indicator USING '100' '원자재 소요량 등록 완료'.
  ENDIF.

  gv_status_confirm = abap_true.
  PERFORM refresh_0100.
  MESSAGE s003 WITH '월간 생산계획이 확정되었습니다.'(e40).
  CLEAR gv_chk_edit.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_INDICATOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_indicator  USING    pv_percentage
                             pv_text.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = pv_percentage                 "indicator에 진행률(%)
      text       = pv_text.  "텍스트 표시

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GONGJUNG_INFOR_USING_SIMUL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_2090
*&      <-- LT_PREPARE_2090
*&      <-- LT_SAVE_2100
*&---------------------------------------------------------------------*
FORM set_gongjung_infor_using_simul  TABLES  pt_2090 STRUCTURE zgtppt2090
                                                                         pt_2080 STRUCTURE zgtppt2080
                                                                         pt_salesplan STRUCTURE zgtcvsalesplan
                                                                         pt_save_2100 STRUCTURE zgtppt2100
                                                                         pt_save_2101 STRUCTURE zgtppt2101
                                                                         pt_save_2102 STRUCTURE zgtppt2102
                                                           CHANGING pv_chk_err.

  DATA : lt_2100 TYPE TABLE OF zgtppt2100.
  DATA : ls_2100 TYPE zgtppt2100.
  DATA : lv_tabix TYPE i.
  DATA : BEGIN OF ls_matnr,
           matnr TYPE matnr,
         END OF ls_matnr.
  DATA : lt_matnr LIKE TABLE OF ls_matnr.
  DATA : lv_fert_matnr TYPE matnr.
  DATA : lv_chk_err.

  DATA(lt_2090) = pt_2090[].
  SORT lt_2090 BY plnid.
  DELETE ADJACENT DUPLICATES FROM lt_2090 COMPARING plnid.

  IF lt_2090[] IS NOT INITIAL.
    SELECT * FROM zgtppt2080
      INTO TABLE @DATA(lt_2080)
        FOR ALL ENTRIES IN @lt_2090
      WHERE werks = @p_werks
        AND spgcd = @p_spgcd
        AND plnid = @lt_2090-plnid.
  ENDIF.

  pt_2080[] = lt_2080[].

  DATA(lt_chk_2080) = lt_2080.

  SORT lt_chk_2080 BY cycltype vkbur spec zpjno.
  DELETE ADJACENT DUPLICATES FROM lt_chk_2080 COMPARING cycltype vkbur spec zpjno.

  IF lt_chk_2080[] IS NOT INITIAL.
    SELECT * FROM zgtcvsalesplan
      FOR ALL ENTRIES IN @lt_chk_2080
     WHERE cycltype = @lt_chk_2080-cycltype
        AND vkbur = @lt_chk_2080-vkbur
        AND spec = @lt_chk_2080-spec
        AND zpjno = @lt_chk_2080-zpjno
      INTO TABLE @DATA(lt_salesplan).
  ENDIF.

  pt_salesplan[] = lt_salesplan[].
*  1) 설계번호 기준으로 확정계획 생성
  DATA(lt_chk_sul) = lt_salesplan[].
* 설계 번호 로 조회후 설계번호 기준으로 공정 순서대로 확정데이터 생성
*  SORT LT_CHK_SUL BY SUL_NO.
*  DELETE ADJACENT DUPLICATES FROM LT_CHK_SUL COMPARING SUL_NO.
*  DELETE LT_CHK_SUL WHERE SUL_NO IS INITIAL.


*  2) 양산자재 확정계획 생성
  DATA(lt_chk_matnr) = lt_salesplan[].
  SORT lt_chk_matnr BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_matnr COMPARING matnr.
  LOOP AT lt_chk_matnr ASSIGNING FIELD-SYMBOL(<ls_chk_matnr>).
    IF <ls_chk_matnr>-matnr IS INITIAL.
      CONTINUE.
    ENDIF.
    CLEAR ls_matnr.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = <ls_chk_matnr>-matnr
      IMPORTING
        output = ls_matnr-matnr.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input        = ls_matnr-matnr
      IMPORTING
        output       = ls_matnr-matnr
      EXCEPTIONS
        length_error = 1
        OTHERS       = 2.

    <ls_chk_matnr>-matnr = ls_matnr-matnr.

    COLLECT ls_matnr INTO lt_matnr.

  ENDLOOP.

  IF lt_matnr IS NOT INITIAL.
    SELECT matnr
      FROM mara AS a
      INNER JOIN t134 AS b ON b~mtart = b~mtart
      FOR ALL ENTRIES IN @lt_matnr
     WHERE a~matnr = @lt_matnr-matnr
       AND b~mtref = 'FERT'
      INTO TABLE @DATA(lt_prod_matnr).

*   설계번호 조회(견적설계 확인)
    SELECT a~matnr, a~sul_no
       FROM zgtedt9020 AS a
        FOR ALL ENTRIES IN @lt_matnr
      WHERE a~matnr = @lt_matnr-matnr
         AND a~werks = @p_werks
         AND a~zifkey = ( SELECT MAX( zifkey ) AS zifkey
                                    FROM zgtedt9020 AS b
                                  WHERE b~matnr = a~matnr
                                      AND b~werks = a~werks )
        INTO TABLE @DATA(lt_sul_9020).
  ENDIF.

  LOOP AT pt_2090 ASSIGNING FIELD-SYMBOL(<ls_2090>).
    PERFORM set_indicator USING '20' '시뮬레이션 확정, 공정별 생산 계획 등록 중'.

    lv_tabix = sy-tabix.
    READ TABLE lt_2080 INTO DATA(ls_2080) WITH KEY plnid = <ls_2090>-plnid.
    IF sy-subrc EQ 0.
      READ TABLE lt_salesplan INTO DATA(ls_salesplan) WITH KEY cycltype = ls_2080-cycltype
                                                                                         vkbur = ls_2080-vkbur
                                                                                         spec = ls_2080-spec
                                                                                         zpjno = ls_2080-zpjno.
      IF sy-subrc EQ 0.
*  1) 양산자재 확정계획 생성
        READ TABLE lt_prod_matnr INTO DATA(ls_prod_matnr) WITH KEY matnr = ls_salesplan-matnr.
        IF sy-subrc EQ 0. " 판매 계획 완제품이 등록 되어 있으면, 완제품 기준 하위 BOM을 확인하여 월간 확정 계획 생성
          PERFORM set_confirm_plan TABLES pt_save_2100 pt_save_2101 pt_save_2102
                                                     USING <ls_2090> ls_prod_matnr-matnr .
          <ls_2090>-plcnf = abap_true.
        ELSE.
*  2) 설계번호 기준으로 확정계획 생성(이후 생성예정)
          READ TABLE lt_sul_9020 INTO DATA(ls_sul_9020) WITH KEY matnr = ls_salesplan-matnr.
          IF sy-subrc EQ 0.
* 반제품 기준으로 완제품 찾아오기
            PERFORM get_fert_from_halb_matnr USING    <ls_2090>-idnrk
                                                               CHANGING    lv_fert_matnr
                                                                                lv_chk_err.
            IF lv_fert_matnr IS INITIAL.
              MESSAGE s006 DISPLAY LIKE 'E' WITH '시뮬레이션 등록된 반제품(' <ls_2090>-idnrk ')의 완제품 코드를  찾을 수 없습니다.'.
              pv_chk_err = abap_true.
              RETURN.
            ENDIF.
* 찾아온 완제품 기준으로 확정계획 생성
            PERFORM set_confirm_plan_sun_no TABLES pt_save_2100 pt_save_2101 pt_save_2102
                                                                    USING ls_sul_9020-sul_no <ls_2090> lv_fert_matnr.
            <ls_2090>-plcnf = abap_true.

          ELSE.
*  3) 완제품 없이 반제품만 입력되어 있는 경우, 반제품을 사용하는 상위 자재 확인 필요
* 반제품 기준으로 완제품 찾아오기
            PERFORM get_fert_from_halb_matnr USING    <ls_2090>-idnrk
                                                               CHANGING    lv_fert_matnr
                                                                                lv_chk_err.
            IF lv_fert_matnr IS INITIAL.
              MESSAGE s003 DISPLAY LIKE 'E' WITH '판매계획 자재 기준의 완제품 코드를 찾을 수 없습니다.'(e33).
              pv_chk_err = abap_true.
              RETURN.
            ENDIF.
* 찾아온 완제품 기준으로 확정계획 생성
            PERFORM set_confirm_plan TABLES pt_save_2100 pt_save_2101 pt_save_2102
                                                       USING <ls_2090> lv_fert_matnr.
            <ls_2090>-plcnf = abap_true.
          ENDIF.
        ENDIF.

      ELSE.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '생산계획에 오류가 있습니다. 생산계획과 판매계획을 확인하세요.'.
        pv_chk_err = abap_true.
        RETURN.
      ENDIF.
    ELSE.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '생산계획에 오류가 있습니다. 생산계획과 판매계획을 확인하세요.'.
      pv_chk_err = abap_true.
      RETURN.
    ENDIF.

  ENDLOOP.

  DATA : lt_2100_collect TYPE TABLE OF zgtppt2100.
  DATA : lt_2101_collect TYPE TABLE OF zgtppt2101.
  DATA : lt_2102_collect TYPE TABLE OF zgtppt2102.

  LOOP AT pt_save_2100.
    COLLECT pt_save_2100 INTO lt_2100_collect.
  ENDLOOP.

  LOOP AT pt_save_2101.
    COLLECT pt_save_2101 INTO lt_2101_collect.
  ENDLOOP.

  LOOP AT pt_save_2102.
    COLLECT pt_save_2102 INTO lt_2102_collect.
  ENDLOOP.

  MOVE-CORRESPONDING lt_2100_collect TO pt_save_2100[].
  MOVE-CORRESPONDING lt_2101_collect TO pt_save_2101[].
  MOVE-CORRESPONDING lt_2102_collect TO pt_save_2102[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CONFIRM_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SAVE_2100
*&      --> LS_2090
*&      --> LS_PROD_MATNR_MATNR
*&---------------------------------------------------------------------*
FORM set_confirm_plan  TABLES   pt_save_2100 STRUCTURE zgtppt2100
                                                  pt_save_2101 STRUCTURE zgtppt2101
                                                  pt_save_2102 STRUCTURE zgtppt2102
                       USING    ps_2090 TYPE zgtppt2090
                                   pv_matnr TYPE matnr.

  DATA : BEGIN OF ls_seq_routing,
           seqno TYPE i,   " 공정단계
           stufe TYPE histu,
           matnr TYPE matnr,
           meins TYPE meins,
           mtart TYPE mtart,
           chart TYPE atwrt,
           plmng TYPE zgtppt2091-plmng,
         END OF ls_seq_routing.
  DATA : lt_seq_routing_tmp LIKE TABLE OF ls_seq_routing.
  DATA : lt_seq_routing LIKE TABLE OF ls_seq_routing.

  DATA : BEGIN OF ls_chk_matnr,
           matnr TYPE matnr,
         END OF ls_chk_matnr.
  DATA : lt_chk_matnr LIKE TABLE OF ls_chk_matnr.

  DATA : ls_topmat TYPE cstmat.
  DATA : lt_stb TYPE TABLE OF stpox.
  DATA : lt_cscmat TYPE TABLE OF cscmat.
  DATA : lv_cal_chk.
  DATA : lv_plmng TYPE zgtppt2091-plmng.
  DATA : lv_plmng2 TYPE zgtppt2091-plmng.
  DATA : lt_2100 TYPE TABLE OF zgtppt2100.
  DATA : lt_2101 TYPE TABLE OF zgtppt2101.
  DATA : lt_2102 TYPE TABLE OF zgtppt2102.
  DATA : lv_num(2) TYPE n.
  DATA : ls_2102 TYPE zgtppt2102.
  DATA : lt_sort_plmang TYPE TABLE OF zgtppt2091.

  DATA : BEGIN OF ls_cal_routing.
           INCLUDE TYPE zgtppt2091.
  DATA :   t_2102 TYPE TABLE OF zgtppt2102,
           t_2101 TYPE TABLE OF zgtppt2101,
         END OF ls_cal_routing.

  DATA : lt_cal_routing LIKE TABLE OF ls_cal_routing.

  lt_sort_plmang = VALUE #( FOR lw_2091 IN gt_2091 WHERE ( plnid = ps_2090-plnid
                                                                                    AND  arbpl = ps_2090-arbpl )
                                         ( CORRESPONDING #( lw_2091 ) ) ).

  DELETE lt_sort_plmang WHERE pltype NE '01'.

  SORT lt_sort_plmang BY plnid plmng.
  DELETE ADJACENT DUPLICATES FROM lt_sort_plmang COMPARING plnid plmng.

  LOOP AT lt_sort_plmang INTO DATA(ls_sort_plmang).
    CLEAR ls_cal_routing.
    MOVE-CORRESPONDING ls_sort_plmang TO ls_cal_routing.
    APPEND ls_cal_routing TO lt_cal_routing.
  ENDLOOP.

* BOM 하위전개
  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      capid                 = 'PP01'
      datuv                 = sy-datum
      mehrs                 = abap_on
      mmory                 = '1'
      mtnrv                 = pv_matnr
      werks                 = p_werks
      stlan                 = '1'
    IMPORTING
      topmat                = ls_topmat
    TABLES
      stb                   = lt_stb
      matcat                = lt_cscmat
    EXCEPTIONS
      alt_not_found         = 1
      call_invalid          = 2
      material_not_found    = 3
      missing_authorization = 4
      no_bom_found          = 5
      no_plant_data         = 6
      no_suitable_bom_found = 7
      conversion_error      = 8
      OTHERS                = 9.

  IF lt_cscmat[] IS NOT INITIAL.
    SELECT a~index AS seqno, a~matnr, b~meins, b~mtart
      FROM @lt_cscmat AS a
      INNER JOIN mara AS b ON b~matnr = a~matnr
      INNER JOIN t134  AS d ON d~mtart = b~mtart
      INNER JOIN marc AS c ON c~matnr = a~matnr
                                    AND c~werks = @p_werks
     WHERE d~mtref   IN ( 'FERT', 'HALB' )  " 완제품 반제품만 공정대상
       AND ( ( c~matnr NE @ps_2090-idnrk
       AND    c~beskz = 'E' )
         OR  ( c~matnr EQ @ps_2090-idnrk
       AND ( ( c~beskz = 'E'
        OR     c~beskz = 'X' )
        OR   ( c~beskz = 'F' AND c~sobsl LIKE '4%' ) ) ) )
       AND c~dpcbt EQ 'C'
       AND ( a~index EQ 1
        OR ( a~index NE 1
       AND  a~verid IS NOT INITIAL ) )
      INTO CORRESPONDING FIELDS OF TABLE @lt_seq_routing_tmp.
  ENDIF.

  lt_chk_matnr = VALUE #( FOR lw_routing IN lt_seq_routing_tmp WHERE ( matnr IS NOT INITIAL )
                                   ( matnr = lw_routing-matnr ) ).

  IF lt_chk_matnr[] IS NOT INITIAL.
    SELECT matnr, pdcaproccode AS chart
      FROM zgtcvmstval
      FOR ALL ENTRIES IN @lt_chk_matnr
     WHERE werks = @p_werks
       AND matnr = @lt_chk_matnr-matnr
       AND lvormc = ''
       AND lvormp = ''
      INTO TABLE @DATA(lt_chart).
  ENDIF.

  SORT lt_stb BY stufe wegxx.
  LOOP AT lt_stb INTO DATA(ls_stb).
    READ TABLE lt_seq_routing_tmp INTO ls_seq_routing WITH KEY seqno = ls_stb-ttidx.
    IF sy-subrc EQ 0.
      DATA(lv_idx) = sy-tabix.
      ls_seq_routing-seqno = lines( lt_seq_routing ) + 1.
      ls_seq_routing-stufe = ls_stb-stufe.
      READ TABLE lt_chart INTO DATA(ls_chart) WITH KEY matnr = ls_seq_routing-matnr.
      ls_seq_routing-chart = ls_chart-chart.

      APPEND ls_seq_routing TO lt_seq_routing.
      DELETE lt_seq_routing_tmp INDEX lv_idx.
    ENDIF.
  ENDLOOP.

  SORT lt_seq_routing  BY seqno.

  LOOP AT lt_cal_routing ASSIGNING FIELD-SYMBOL(<ls_cal_routing>).
    CLEAR lv_cal_chk.

    LOOP AT lt_seq_routing ASSIGNING FIELD-SYMBOL(<ls_seq_routing>).
      CLEAR ls_2102.
      ls_2102-werks = p_werks.
      ls_2102-spgcd = p_spgcd.
      ls_2102-simno = <ls_cal_routing>-simno.
      ls_2102-simvr = <ls_cal_routing>-simvr.
      ls_2102-plnid = <ls_cal_routing>-plnid.
      CLEAR lv_num.
      lv_num = <ls_seq_routing>-seqno + 0.
      ls_2102-gong_seq = lv_num.
      ls_2102-gong_cd = <ls_seq_routing>-chart.
      ls_2102-matnr = <ls_seq_routing>-matnr.

      IF <ls_seq_routing>-chart = 'INS'.
        lv_cal_chk = abap_true.

        ls_2102-meins = <ls_seq_routing>-meins.
        ls_2102-menge = <ls_cal_routing>-plmng.
        APPEND ls_2102 TO <ls_cal_routing>-t_2102.

      ELSEIF lv_cal_chk IS INITIAL."INS 이후 공정들은 INS 수량으로 입력

        ls_2102-meins = <ls_seq_routing>-meins.
        ls_2102-menge = <ls_cal_routing>-plmng.
        APPEND ls_2102 TO <ls_cal_routing>-t_2102.
      ELSE.
        SELECT  a~matnr,
                    c~idnrk
            FROM mast AS a
            INNER JOIN stko AS b
                                 ON b~stlnr = a~stlnr
                                AND b~stlal = a~stlal
            INNER JOIN stpo AS c
                                 ON c~stlnr = b~stlnr
                                AND c~stlty = b~stlty
           WHERE a~matnr IN ( SELECT itab~matnr
                                           FROM @lt_seq_routing AS itab
                                         WHERE seqno < @<ls_seq_routing>-seqno )
               AND a~werks  = @p_werks
               AND a~stlan = '1'
               AND a~stlal  = '01'
               AND b~stlty  = 'M'
               AND b~lkenz NE 'X'
               AND c~lkenz NE 'X'
               AND c~idnrk      = @<ls_seq_routing>-matnr
            INTO TABLE @DATA(lt_calcultab).

        READ TABLE lt_calcultab INTO DATA(ls_calcultab) INDEX 1.
        READ TABLE <ls_cal_routing>-t_2102 INTO DATA(ls_menge) WITH KEY matnr = ls_calcultab-matnr.
        READ TABLE lt_seq_routing INTO DATA(ls_chk_routing) WITH KEY matnr = ls_calcultab-matnr.

        PERFORM get_meterial_bom_quan TABLES lt_2101
                                                           USING ls_calcultab-matnr ls_calcultab-idnrk ls_chk_routing-chart ls_menge-menge
                                                      CHANGING lv_plmng2.

        ls_2102-meins = <ls_seq_routing>-meins.
        ls_2102-menge = lv_plmng2.
        APPEND ls_2102 TO <ls_cal_routing>-t_2102.

*      연선 건에 대해서만 [GT] 월간 생산계획(생산계획 확정 소요량) 세팅
        IF ls_chk_routing-chart = 'INS' AND p_simty = '2'.
          LOOP AT lt_2101 ASSIGNING FIELD-SYMBOL(<ls_2101>).
            <ls_2101>-simno = ps_2090-simno.
            <ls_2101>-simvr = ps_2090-simvr.
          ENDLOOP.
          APPEND LINES OF lt_2101 TO <ls_cal_routing>-t_2101.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDLOOP.

* 계산 결과 반영

  DATA : ls_save_2100 TYPE zgtppt2100.
  DATA : ls_save_2101 TYPE zgtppt2101.
  DATA : ls_save_2102 TYPE zgtppt2102.
  DATA : lt_mstval TYPE TABLE OF zgtcvmstval.
  DATA : ls_mstval TYPE zgtcvmstval.
  DATA : lv_pre_pldat TYPE sy-datum. " 이전공정 소요일 계산

  REFRESH : lt_2100, lt_2101, lt_2102.

  LOOP AT gt_2091 INTO DATA(ls_2091) WHERE plnid = ps_2090-plnid
                                                   AND arbpl = ps_2090-arbpl
                                                   AND pltype = '01'.

    READ TABLE lt_cal_routing INTO ls_cal_routing WITH KEY plmng = ls_2091-plmng.
    IF sy-subrc EQ 0.
* 공정별 기간 세팅 시작은 INS(절연)
      READ TABLE ls_cal_routing-t_2102 INTO ls_2102 WITH KEY gong_cd = 'INS'.
      CLEAR ls_save_2102.
      MOVE-CORRESPONDING ls_2102 TO ls_save_2102.

      ls_save_2102-simty = p_simty.
      ls_save_2102-arbpl = ls_2091-arbpl.
      ls_save_2102-spmon = ls_2091-pldat+0(6).
      ls_save_2102-pldat = ls_2091-pldat.
      ls_save_2102-pltim = 7. " 드라이 공정 왜 다른공정은 7일계산, 드라이는 테이블 조회.
      COLLECT ls_save_2102 INTO lt_2102.

      lv_num = ls_2102-gong_seq.
      lv_pre_pldat = ls_save_2102-pldat + ls_save_2102-pltim.
*절연 기준으로 이후공정 세팅
      DO.
        IF lv_num = 1.
          EXIT.
        ENDIF.

        lv_num = lv_num - 1.
        READ TABLE ls_cal_routing-t_2102 INTO DATA(ls_gong_seq) WITH KEY gong_seq = lv_num.
        CLEAR ls_save_2102.
        MOVE-CORRESPONDING ls_gong_seq TO ls_save_2102.

        ls_save_2102-simty = p_simty.
        ls_save_2102-arbpl = ls_2091-arbpl.
        ls_save_2102-spmon = ls_2091-pldat+0(6).
        ls_save_2102-pldat = lv_pre_pldat.

        IF ls_save_2102-gong_cd = 'DRY'.

          READ TABLE lt_mstval INTO ls_mstval WITH KEY matnr = ls_save_2102-matnr BINARY SEARCH.
          IF sy-subrc NE 0.

            DATA(lv_tabix) = sy-tabix.
            SELECT SINGLE * FROM zgtcvmstval
              INTO CORRESPONDING FIELDS OF ls_mstval
             WHERE werks = p_werks
                AND matnr = ls_save_2102-matnr
                AND spg = p_spgcd.
            IF sy-subrc EQ 0.
              ls_save_2102-pltim = ls_mstval-pdpcdrydayno + 0.
              INSERT ls_mstval INTO lt_mstval INDEX lv_tabix.
            ELSE.
              ls_save_2102-pltim = ls_mstval-pdpcdrydayno + 0.
            ENDIF.

          ELSE.

            ls_save_2102-pltim = ls_mstval-pdpcdrydayno + 0.

          ENDIF.

        ELSE.
          ls_save_2102-pltim = 7. " 드라이 공정 왜 다른공정은 7일계산, 드라이는 테이블 조회.
        ENDIF.

        lv_pre_pldat = ls_save_2102-pldat + ls_save_2102-pltim.
        COLLECT ls_save_2102 INTO lt_2102.
      ENDDO.

      lv_num = ls_2102-gong_seq.
*절연 기준으로 이전공정 세팅
      DO.
        IF lv_num = lines( ls_cal_routing-t_2102 ).
          EXIT.
        ENDIF.

        ADD 1 TO lv_num.

        READ TABLE ls_cal_routing-t_2102 INTO ls_gong_seq WITH KEY gong_seq = lv_num.
        CLEAR ls_save_2102.
        MOVE-CORRESPONDING ls_gong_seq TO ls_save_2102.

        ls_save_2102-simty = p_simty.
        ls_save_2102-spmon = ls_2091-pldat+0(6).
*        LS_SAVE_2102-ARBPL = LS_2091-ARBPL.
        ls_save_2102-pldat = ls_2091-pldat.
        ls_save_2102-pltim = 7. " 드라이 공정 왜 다른공정은 7일계산, 드라이는 테이블 조회.
        COLLECT ls_save_2102 INTO lt_2102.
      ENDDO.

* 예약자재 정보 업데이트
      IF p_simty = '2'.
        LOOP AT ls_cal_routing-t_2101 INTO ls_save_2101.
          ls_save_2101-werks = p_werks.
          ls_save_2101-spgcd = p_spgcd.
          ls_save_2101-bdter = ls_2091-pldat+0(6) && '01'.
          COLLECT ls_save_2101 INTO lt_2101.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDLOOP.

  READ TABLE lt_seq_routing INTO ls_seq_routing WITH KEY chart = 'INS'.
* 월간 생산계획 확정데이타 월별 취합
  LOOP AT lt_2102 INTO ls_save_2102.
    CLEAR ls_save_2100.
    MOVE-CORRESPONDING ls_save_2102 TO ls_save_2100.
    IF ls_seq_routing-seqno > ls_save_2100-gong_seq.
      CLEAR ls_save_2100-arbpl.
    ENDIF.
    ls_save_2100-simty = p_simty.
    ls_save_2100-zspmon = ls_save_2102-pldat+0(6).
    ls_save_2100-spmon = ls_save_2102-spmon.
    ls_save_2100-cnfdat = sy-datum.
    COLLECT ls_save_2100 INTO lt_2100.
  ENDLOOP.

  APPEND LINES OF lt_2100 TO pt_save_2100[].
  APPEND LINES OF lt_2101 TO pt_save_2101[].
  APPEND LINES OF lt_2102 TO pt_save_2102[].


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_METERIAL_BOM_QUAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CALCULTAB_MATNR
*&      --> LS_CALCULTAB_IDNRK
*&      <-- LS_2091_PLMNG
*&---------------------------------------------------------------------*
FORM get_meterial_bom_quan  TABLES pt_2101 STRUCTURE zgtppt2101
                                  USING    pv_matnr TYPE matnr
                                     pv_idnrk
                                     pv_chart
                                     pv_plmng_input
                            CHANGING pv_plmng.

  DATA : lt_stb TYPE TABLE OF stpox.
  DATA : lv_emeng TYPE stko-bmeng.
  DATA : lv_mngko TYPE cs_e_mngko.
  DATA : lv_mngko_tot TYPE cs_e_mngko.
  DATA : ls_2101 TYPE zgtppt2101.
  DATA : lt_2101 TYPE TABLE OF zgtppt2101.
  DATA : BEGIN OF ls_chk_matnr,
           matnr TYPE matnr,
         END OF ls_chk_matnr.
  DATA : lt_chk_matnr LIKE TABLE OF ls_chk_matnr.

  lv_emeng = pv_plmng_input.

  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      capid                 = 'PP01'
      datuv                 = sy-datum
      emeng                 = lv_emeng
      mtnrv                 = pv_matnr " 자재
      werks                 = p_werks " 플랜트
      mmory                 = '0'
    TABLES
      stb                   = lt_stb
    EXCEPTIONS
      alt_not_found         = 1
      call_invalid          = 2
      material_not_found    = 3
      missing_authorization = 4
      no_bom_found          = 5
      no_plant_data         = 6
      no_suitable_bom_found = 7
      conversion_error      = 8
      OTHERS                = 9.

  CLEAR lv_mngko_tot.
  LOOP AT lt_stb INTO DATA(ls_stb) WHERE idnrk = pv_idnrk.
    ADD ls_stb-mngko TO lv_mngko_tot.
  ENDLOOP.

  CLEAR lv_mngko.
  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      i_rtype     = '+'
      i_runit     = 1
      i_value     = lv_mngko_tot
    IMPORTING
      e_value_rnd = lv_mngko.

  pv_plmng = lv_mngko.

* INS 구성자재 수량 모디
  IF pv_chart = 'INS'.
    lt_chk_matnr = VALUE #( FOR lw_stb IN lt_stb WHERE ( idnrk IS NOT INITIAL ) ( matnr = lw_stb-idnrk ) ).

    IF lt_chk_matnr[] IS NOT INITIAL.
      SELECT a~matnr, a~meins
        FROM mara AS a
        INNER JOIN t134  AS b ON b~mtart = a~mtart
          FOR ALL ENTRIES IN @lt_chk_matnr
       WHERE a~matnr = @lt_chk_matnr-matnr
          AND b~mtref   IN ( 'ROH', 'VERP' )  " 완제품 반제품만 공정대상
        INTO TABLE @DATA(lt_matnr).
    ENDIF.

    LOOP AT lt_stb INTO ls_stb.
* 자재 유효성 검사
*      1. 자재 삭제 확인
      SELECT SINGLE matnr INTO @DATA(lv_chk_matnr)
         FROM zgtcvmstval
       WHERE werks = @p_werks
         AND matnr = @ls_stb-idnrk
         AND lvormc = ''
         AND lvormp = ''.
      CHECK lv_chk_matnr IS NOT INITIAL.

*      2. 자재 유형 확인
      READ TABLE lt_matnr INTO DATA(ls_matnr) WITH KEY matnr = ls_stb-idnrk.
      IF sy-subrc EQ 0.
        CLEAR ls_2101.
        ls_2101-werks = p_werks.
        ls_2101-spgcd = p_spgcd.
        ls_2101-matnr = pv_matnr.
        ls_2101-idnrk = ls_stb-idnrk.
        ls_2101-meins = ls_stb-meins.

        CLEAR lv_mngko.
        CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
          EXPORTING
            i_rtype     = '+'
            i_runit     = 1
            i_value     = ls_stb-mngko
          IMPORTING
            e_value_rnd = lv_mngko.

        ls_2101-bdmng = lv_mngko.
        COLLECT ls_2101 INTO lt_2101.
      ENDIF.
    ENDLOOP.

    IF lt_2101[] IS NOT INITIAL.
      MOVE-CORRESPONDING lt_2101 TO pt_2101[].
    ENDIF.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CONFIRM_PLAN_HALF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SAVE_2100
*&      --> PT_SAVE_2101
*&      --> <LS_2090>
*&      --> LS_SALESPLAN_MATNR
*&---------------------------------------------------------------------*
FORM set_confirm_plan_half  TABLES   pt_save_2100 STRUCTURE zgtppt2100
                                                           pt_save_2101 STRUCTURE zgtppt2101
                                               USING    ps_2090 TYPE zgtppt2090
                                                           pv_matnr TYPE matnr.

  DATA : lv_fert_matnr TYPE matnr.
  DATA : lv_chk_err.

* 반제품 기준으로 완제품 찾아오기
  PERFORM get_fert_from_halb_matnr USING    pv_matnr
                                                     CHANGING    lv_fert_matnr
                                                                      lv_chk_err.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FERT_FROM_HALB_MATNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_MATNR
*&      <-- LV_FERT_MATNR
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM get_fert_from_halb_matnr  USING    pv_matnh TYPE matnr " 반제품
                              CHANGING pv_matnf TYPE matnr " 완제품
                                            pv_chk_err.

  FIELD-SYMBOLS <lfs_data> TYPE STANDARD TABLE.
  DATA : l_data   TYPE REF TO data,
         ls_bom   TYPE stpov_alv,
         lv_mtart LIKE mara-mtart,
         lv_matnr LIKE mara-matnr.

  cl_salv_bs_runtime_info=>set( display  = abap_false
                                metadata = abap_false
                                data     = abap_true ).

  UNASSIGN <lfs_data>.

  SUBMIT rcs15001 WITH pm_idnrk = pv_matnh
                  WITH pm_werks = p_werks
                  WITH pm_mehrs = 'X'
                  AND RETURN.

  TRY.
      cl_salv_bs_runtime_info=>get_data_ref( IMPORTING
      r_data = l_data ).
      ASSIGN l_data->* TO <lfs_data>.
    CATCH cx_salv_bs_sc_runtime_info.
  ENDTRY.

  IF <lfs_data> IS ASSIGNED.

    CLEAR ls_bom.
    LOOP AT <lfs_data> INTO ls_bom.

      CLEAR lv_mtart.
      SELECT SINGLE a~mtart
        FROM mara AS a
        INNER JOIN t134 AS b ON b~mtart = a~mtart
       WHERE a~matnr = @ls_bom-matnr
         AND b~mtref = 'FERT'
         INTO @lv_mtart.

      IF lv_mtart IS NOT INITIAL.
        SELECT SINGLE matnr
           FROM zgtcvmstval
          WHERE werks = @p_werks
            AND matnr = @ls_bom-matnr
            AND lvormc = ''
            AND lvormp = ''
           INTO @lv_matnr.
        IF lv_matnr IS NOT INITIAL.

          pv_matnf = ls_bom-matnr.
          EXIT.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDIF.

  cl_salv_bs_runtime_info=>clear_all( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_REJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_reject .

  IF gt_2090 IS NOT INITIAL.
    SELECT * FROM zgtppt2100
      INTO TABLE @DATA(lt_2100)
       FOR ALL ENTRIES IN @gt_2090
      WHERE werks = @p_werks
        AND spgcd = @p_spgcd
        AND simno = @gt_2090-simno
        AND simvr = @gt_2090-simvr
        AND plnid = @gt_2090-plnid.

    SELECT * FROM zgtppt2101
      INTO TABLE @DATA(lt_2101)
       FOR ALL ENTRIES IN @gt_2090
      WHERE werks = @p_werks
        AND spgcd = @p_spgcd
        AND simno = @gt_2090-simno
        AND simvr = @gt_2090-simvr.

    SELECT * FROM zgtppt2102
      INTO TABLE @DATA(lt_2102)
       FOR ALL ENTRIES IN @gt_2090
      WHERE werks = @p_werks
        AND spgcd = @p_spgcd
        AND simno = @gt_2090-simno
        AND simvr = @gt_2090-simvr.

  ENDIF.

  SORT lt_2100 BY werks spgcd simno simvr plnid gong_seq gong_cd zspmon spmon matnr arbpl.
  DELETE ADJACENT DUPLICATES FROM lt_2100 COMPARING werks spgcd simno simvr plnid gong_seq gong_cd zspmon spmon matnr arbpl.

  SORT lt_2101 BY werks spgcd simno simvr bdter matnr idnrk.
  DELETE ADJACENT DUPLICATES FROM lt_2101 COMPARING werks spgcd simno simvr bdter matnr idnrk.

  SORT lt_2102 BY werks spgcd simno simvr arbpl  plnid gong_seq gong_cd spmon pldat.
  DELETE ADJACENT DUPLICATES FROM lt_2102 COMPARING werks spgcd simno simvr arbpl  plnid gong_seq gong_cd spmon pldat.

  IF lt_2100[] IS NOT INITIAL.
    DELETE zgtppt2100 FROM TABLE lt_2100.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '확정취소중 오류 발생하였습니다.'(e37).
      RETURN.
    ENDIF.
  ENDIF.

  IF p_simty = '2'.
    IF lt_2101[] IS NOT INITIAL.
      DELETE zgtppt2101 FROM TABLE lt_2101.
      IF sy-subrc NE 0.
        ROLLBACK WORK.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '확정취소중 오류 발생하였습니다.'(e37).
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

  IF lt_2102[] IS NOT INITIAL.
    DELETE zgtppt2102 FROM TABLE lt_2102.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '확정취소중 오류 발생하였습니다.'(e37).
      RETURN.
    ENDIF.
  ENDIF.

  IF sy-subrc EQ 0.
    LOOP AT gt_2090 ASSIGNING FIELD-SYMBOL(<ls_2090>).
      CLEAR <ls_2090>-plcnf.
      MOVE : sy-datum TO <ls_2090>-aedat,
                 sy-uname TO <ls_2090>-aenam.
    ENDLOOP.

    IF gt_2090[] IS NOT INITIAL.
      MODIFY zgtppt2090 FROM TABLE gt_2090.
      IF sy-subrc NE 0.
        ROLLBACK WORK.
        MESSAGE s003 DISPLAY LIKE 'E' WITH '확정취소중 오류 발생하였습니다.'(e37).
        RETURN.
      ELSE.
        COMMIT WORK AND WAIT.
      ENDIF.

    ENDIF.
  ENDIF.

  MESSAGE s003 WITH '월간생산계획 확정 취소되었습니다.'(e38).
  CLEAR gv_status_confirm.
  PERFORM refresh_0100.
  CLEAR gv_chk_edit.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CONFIRM_PLAN_SUN_NO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SAVE_2100
*&      --> PT_SAVE_2101
*&      --> LS_SUL_9020_SUL_NO
*&      --> <LS_2090>
*&      --> LV_FERT_MATNR
*&---------------------------------------------------------------------*
FORM set_confirm_plan_sun_no  TABLES   pt_save_2100 STRUCTURE zgtppt2100
                                                  pt_save_2101 STRUCTURE zgtppt2101
                                                  pt_save_2102 STRUCTURE zgtppt2102
                       USING    pv_sul_no
                                   ps_2090 TYPE zgtppt2090
                                   pv_matnr TYPE matnr.

  DATA : BEGIN OF ls_seq_routing,
           seqno TYPE i,   " 공정단계
           stufe TYPE histu,
           matnr TYPE matnr,
           meins TYPE meins,
           mtart TYPE mtart,
           chart TYPE atwrt,
           plmng TYPE zgtppt2091-plmng,
         END OF ls_seq_routing.
  DATA : lt_seq_routing_tmp LIKE TABLE OF ls_seq_routing.
  DATA : lt_seq_routing LIKE TABLE OF ls_seq_routing.

  DATA : BEGIN OF ls_chk_matnr,
           matnr TYPE matnr,
         END OF ls_chk_matnr.
  DATA : lt_chk_matnr LIKE TABLE OF ls_chk_matnr.

  DATA : ls_topmat TYPE cstmat.
  DATA : lt_stb TYPE TABLE OF stpox.
  DATA : lt_cscmat TYPE TABLE OF cscmat.
  DATA : lv_cal_chk.
  DATA : lv_plmng TYPE zgtppt2091-plmng.
  DATA : lt_2100 TYPE TABLE OF zgtppt2100.
  DATA : lt_2101 TYPE TABLE OF zgtppt2101.
  DATA : lt_2102 TYPE TABLE OF zgtppt2102.
  DATA : lv_num(2) TYPE n.
  DATA : ls_2102 TYPE zgtppt2102.
  DATA : lv_tot_plmng TYPE zgtppt2091-plmng.

  DATA : lt_sort_plmang TYPE TABLE OF zgtppt2091.
  DATA : BEGIN OF ls_cal_routing.
           INCLUDE TYPE zgtppt2091.
  DATA :   t_2102 TYPE TABLE OF zgtppt2102,
           t_2101 TYPE TABLE OF zgtppt2101,
         END OF ls_cal_routing.

  DATA : lt_cal_routing LIKE TABLE OF ls_cal_routing.

  lt_sort_plmang = VALUE #( FOR lw_2091 IN gt_2091 WHERE ( plnid = ps_2090-plnid
                                                                                    AND  arbpl = ps_2090-arbpl )
                                         ( CORRESPONDING #( lw_2091 ) ) ).

  DELETE lt_sort_plmang WHERE pltype NE '01'.

  SORT lt_sort_plmang BY plnid plmng.
  DELETE ADJACENT DUPLICATES FROM lt_sort_plmang COMPARING plnid plmng.

  LOOP AT lt_sort_plmang INTO DATA(ls_sort_plmang).
    CLEAR ls_cal_routing.
    MOVE-CORRESPONDING ls_sort_plmang TO ls_cal_routing.
    APPEND ls_cal_routing TO lt_cal_routing.
  ENDLOOP.


  SELECT a~*
     FROM zgtedt9020 AS a
    WHERE a~sul_no = @pv_sul_no
       AND a~werks = @p_werks
       AND a~gong_cd <> '###'
       AND a~beskz_check IS INITIAL
       AND a~zifkey = ( SELECT MAX( zifkey ) AS zifkey
                                  FROM zgtedt9020 AS b
                                WHERE b~sul_no = a~sul_no
                                    AND b~werks = a~werks )
      INTO TABLE @DATA(lt_9020).
  SORT lt_9020 BY gong_seq.

* BOM 하위전개
  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      capid                 = 'PP01'
      datuv                 = sy-datum
      mehrs                 = abap_on
      mmory                 = '1'
      mtnrv                 = pv_matnr
      werks                 = p_werks
      stlan                 = '1'
    IMPORTING
      topmat                = ls_topmat
    TABLES
      stb                   = lt_stb
      matcat                = lt_cscmat
    EXCEPTIONS
      alt_not_found         = 1
      call_invalid          = 2
      material_not_found    = 3
      missing_authorization = 4
      no_bom_found          = 5
      no_plant_data         = 6
      no_suitable_bom_found = 7
      conversion_error      = 8
      OTHERS                = 9.

  IF lt_cscmat[] IS NOT INITIAL.
    SELECT a~index AS seqno, a~matnr, b~meins, b~mtart
      FROM @lt_cscmat AS a
      INNER JOIN mara AS b ON b~matnr = a~matnr
      INNER JOIN t134  AS d ON d~mtart = b~mtart
      INNER JOIN marc AS c ON c~matnr = a~matnr
                                    AND c~werks = @p_werks
     WHERE d~mtref   IN ( 'FERT', 'HALB' )  " 완제품 반제품만 공정대상
       AND ( ( c~matnr NE @ps_2090-idnrk
       AND    c~beskz = 'E' )
         OR  ( c~matnr EQ @ps_2090-idnrk
       AND ( ( c~beskz = 'E'
        OR     c~beskz = 'X' )
        OR   ( c~beskz = 'F' AND c~sobsl LIKE '4%' ) ) ) )
       AND c~dpcbt EQ 'C'
       AND ( a~index EQ 1
        OR ( a~index NE 1
       AND  a~verid IS NOT INITIAL ) )
      INTO CORRESPONDING FIELDS OF TABLE @lt_seq_routing_tmp.
  ENDIF.

  lt_chk_matnr = VALUE #( FOR lw_routing IN lt_seq_routing_tmp WHERE ( matnr IS NOT INITIAL )
                                   ( matnr = lw_routing-matnr ) ).

  IF lt_chk_matnr[] IS NOT INITIAL.
    SELECT matnr, pdcaproccode AS chart
      FROM zgtcvmstval
      FOR ALL ENTRIES IN @lt_chk_matnr
     WHERE werks = @p_werks
       AND matnr = @lt_chk_matnr-matnr
       AND lvormc = ''
       AND lvormp = ''
      INTO TABLE @DATA(lt_chart).
  ENDIF.

  SORT lt_stb BY stufe wegxx.
  LOOP AT lt_stb INTO DATA(ls_stb).
    READ TABLE lt_seq_routing_tmp INTO ls_seq_routing WITH KEY seqno = ls_stb-ttidx.
    IF sy-subrc EQ 0.
      DATA(lv_idx) = sy-tabix.
      ls_seq_routing-seqno = lines( lt_seq_routing ) + 1.
      ls_seq_routing-stufe = ls_stb-stufe.
      READ TABLE lt_chart INTO DATA(ls_chart) WITH KEY matnr = ls_seq_routing-matnr.
      ls_seq_routing-chart = ls_chart-chart.

      APPEND ls_seq_routing TO lt_seq_routing.
      DELETE lt_seq_routing_tmp INDEX lv_idx.
    ENDIF.
  ENDLOOP.

  SORT lt_seq_routing  BY seqno.

  LOOP AT lt_cal_routing ASSIGNING FIELD-SYMBOL(<ls_cal_routing>).

    CLEAR lv_cal_chk.
* 공정 순번별로 데이터 세팅
    LOOP AT lt_9020 ASSIGNING FIELD-SYMBOL(<ls_seq_routing>).
      CLEAR ls_2102.
      ls_2102-werks = p_werks.
      ls_2102-spgcd = p_spgcd.
      ls_2102-simno = ps_2090-simno.
      ls_2102-simvr = ps_2090-simvr.
      ls_2102-plnid = ps_2090-plnid.
      CLEAR lv_num.
      lv_num = <ls_seq_routing>-gong_seq + 0.
      ls_2102-gong_seq = lv_num.
      ls_2102-gong_cd = <ls_seq_routing>-gong_cd.
      ls_2102-matnr = <ls_seq_routing>-matnr.
      CLEAR ls_seq_routing.
      READ TABLE lt_seq_routing INTO ls_seq_routing WITH KEY chart = <ls_seq_routing>-gong_cd.

      IF <ls_seq_routing>-gong_cd = 'INS'.
        lv_cal_chk = abap_true.

        CLEAR : ls_2102-meins, ls_2102-menge.
        ls_2102-meins = ls_seq_routing-meins.
        ls_2102-menge = <ls_cal_routing>-plmng.
        APPEND ls_2102 TO <ls_cal_routing>-t_2102.

      ELSEIF lv_cal_chk IS INITIAL."INS 이후 공정들은 INS 수량으로 입력
        CLEAR : ls_2102-meins, ls_2102-menge.
        ls_2102-meins = ls_seq_routing-meins.
        ls_2102-menge = <ls_cal_routing>-plmng.
        APPEND ls_2102 TO <ls_cal_routing>-t_2102.
      ELSE.

        SELECT  a~matnr,
                    c~idnrk
            FROM mast AS a
            INNER JOIN stko AS b
                                 ON b~stlnr = a~stlnr
                                AND b~stlal = a~stlal
            INNER JOIN stpo AS c
                                 ON c~stlnr = b~stlnr
                                AND c~stlty = b~stlty
           WHERE a~matnr IN ( SELECT itab~matnr
                                           FROM @lt_seq_routing AS itab
                                         WHERE seqno < @ls_seq_routing-seqno )
               AND a~werks  = @p_werks
               AND a~stlan = '1'
               AND a~stlal  = '01'
               AND b~stlty  = 'M'
               AND b~lkenz NE 'X'
               AND c~lkenz NE 'X'
               AND c~idnrk      = @ls_seq_routing-matnr
            INTO TABLE @DATA(lt_calcultab).

        READ TABLE lt_calcultab INTO DATA(ls_calcultab) INDEX 1.
        READ TABLE lt_seq_routing INTO DATA(ls_chk_routing) WITH KEY matnr = ls_calcultab-matnr.
        READ TABLE <ls_cal_routing>-t_2102 INTO DATA(ls_menge) WITH KEY matnr = <ls_seq_routing>-matnr.

        PERFORM get_meterial_bom_quan TABLES lt_2101
                                                           USING ls_calcultab-matnr ls_calcultab-idnrk ls_chk_routing-chart ls_menge-menge
                                                      CHANGING lv_plmng.

        CLEAR : ls_2102-meins , ls_2102-menge .
        ls_2102-meins = ls_seq_routing-meins.
        ls_2102-menge = lv_plmng.
        APPEND ls_2102 TO <ls_cal_routing>-t_2102.

*      연선 건에 대해서만 [GT] 월간 생산계획(생산계획 확정 소요량) 세팅
        IF ls_chk_routing-chart = 'INS'.
          LOOP AT lt_2101 ASSIGNING FIELD-SYMBOL(<ls_2101>).
            <ls_2101>-simno = ps_2090-simno.
            <ls_2101>-simvr = ps_2090-simvr.
          ENDLOOP.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDLOOP.


* 계산 결과 반영

  DATA : ls_save_2100 TYPE zgtppt2100.
  DATA : ls_save_2101 TYPE zgtppt2101.
  DATA : ls_save_2102 TYPE zgtppt2102.
  DATA : lt_mstval TYPE TABLE OF zgtcvmstval.
  DATA : ls_mstval TYPE zgtcvmstval.
  DATA : lv_pre_pldat TYPE sy-datum. " 이전공정 소요일 계산

  REFRESH : lt_2100, lt_2101, lt_2102.

  LOOP AT gt_2091 INTO DATA(ls_2091) WHERE plnid = ps_2090-plnid
                                                   AND arbpl = ps_2090-arbpl
                                                   AND pltype = '01'.

    READ TABLE lt_cal_routing INTO ls_cal_routing WITH KEY plmng = ls_2091-plmng.
    IF sy-subrc EQ 0.
* 공정별 기간 세팅 시작은 INS(절연)
      READ TABLE ls_cal_routing-t_2102 INTO ls_2102 WITH KEY gong_cd = 'INS'.
      CLEAR ls_save_2102.
      MOVE-CORRESPONDING ls_2102 TO ls_save_2102.

      ls_save_2102-simty = p_simty.
      ls_save_2102-arbpl = ls_2091-arbpl.
      ls_save_2102-spmon = ls_2091-pldat+0(6).
      ls_save_2102-pldat = ls_2091-pldat.
      ls_save_2102-pltim = 7. " 드라이 공정 왜 다른공정은 7일계산, 드라이는 테이블 조회.
      COLLECT ls_save_2102 INTO lt_2102.

      lv_num = ls_2102-gong_seq.
      lv_pre_pldat = ls_save_2102-pldat + ls_save_2102-pltim.
*절연 기준으로 이후공정 세팅
      DO.
        IF lv_num = 1.
          EXIT.
        ENDIF.

        lv_num = lv_num - 1.
        READ TABLE ls_cal_routing-t_2102 INTO DATA(ls_gong_seq) WITH KEY gong_seq = lv_num.
        CLEAR ls_save_2102.
        MOVE-CORRESPONDING ls_gong_seq TO ls_save_2102.

        ls_save_2102-simty = p_simty.
        ls_save_2102-arbpl = ls_2091-arbpl.
        ls_save_2102-spmon = ls_2091-pldat+0(6).
        ls_save_2102-pldat = lv_pre_pldat.

        IF ls_save_2102-gong_cd = 'DRY'.

          CLEAR ls_seq_routing.
          READ TABLE lt_seq_routing INTO ls_seq_routing WITH KEY chart = <ls_seq_routing>-gong_cd.

          READ TABLE lt_mstval INTO ls_mstval WITH KEY matnr = ls_seq_routing-matnr BINARY SEARCH.
          IF sy-subrc NE 0.

            DATA(lv_tabix) = sy-tabix.
            SELECT SINGLE * FROM zgtcvmstval
              INTO CORRESPONDING FIELDS OF ls_mstval
             WHERE werks = p_werks
                AND matnr = ls_save_2102-matnr
                AND spg = p_spgcd.
            IF sy-subrc EQ 0.
              ls_save_2102-pltim = ls_mstval-pdpcdrydayno + 0.
              INSERT ls_mstval INTO lt_mstval INDEX lv_tabix.
            ELSE.
              ls_save_2102-pltim = ls_mstval-pdpcdrydayno + 0.
            ENDIF.

          ELSE.

            ls_save_2102-pltim = ls_mstval-pdpcdrydayno + 0.

          ENDIF.

        ELSE.
          ls_save_2102-pltim = 7. " 드라이 공정 왜 다른공정은 7일계산, 드라이는 테이블 조회.
        ENDIF.

        lv_pre_pldat = ls_save_2102-pldat + ls_save_2102-pltim.
        COLLECT ls_save_2102 INTO lt_2102.
      ENDDO.

      lv_num = ls_2102-gong_seq.
*절연 기준으로 이전공정 세팅
      DO.
        IF lv_num = lines( ls_cal_routing-t_2102 ).
          EXIT.
        ENDIF.

        ADD 1 TO lv_num.

        READ TABLE ls_cal_routing-t_2102 INTO ls_gong_seq WITH KEY gong_seq = lv_num.
        CLEAR ls_save_2102.
        MOVE-CORRESPONDING ls_gong_seq TO ls_save_2102.

        ls_save_2102-simty = p_simty.
        ls_save_2102-spmon = ls_2091-pldat+0(6).
*        LS_SAVE_2102-ARBPL = LS_2091-ARBPL.
        ls_save_2102-pldat = ls_2091-pldat.
        ls_save_2102-pltim = 7. " 드라이 공정 왜 다른공정은 7일계산, 드라이는 테이블 조회.
        COLLECT ls_save_2102 INTO lt_2102.
      ENDDO.

* 예약자재 정보 업데이트
      IF p_simty = '2'.
        LOOP AT ls_cal_routing-t_2101 INTO ls_save_2101.
          ls_save_2101-werks = p_werks.
          ls_save_2101-spgcd = p_spgcd.
          ls_save_2101-bdter = ls_2091-pldat+0(6) && '01'.
          COLLECT ls_save_2101 INTO lt_2101.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDLOOP.

  READ TABLE lt_seq_routing INTO ls_seq_routing WITH KEY chart = 'INS'.
* 월간 생산계획 확정데이타 월별 취합
  LOOP AT lt_2102 INTO ls_save_2102.
    CLEAR ls_save_2100.
    MOVE-CORRESPONDING ls_save_2102 TO ls_save_2100.
    IF ls_seq_routing-seqno > ls_save_2100-gong_seq.
      CLEAR ls_save_2100-arbpl.
    ENDIF.
    ls_save_2100-simty = p_simty.
    ls_save_2100-zspmon = ls_save_2102-pldat+0(6).
    ls_save_2100-spmon = ls_save_2102-spmon.
    ls_save_2100-cnfdat = sy-datum.
    COLLECT ls_save_2100 INTO lt_2100.
  ENDLOOP.

  APPEND LINES OF lt_2100 TO pt_save_2100[].
  APPEND LINES OF lt_2101 TO pt_save_2101[].
  APPEND LINES OF lt_2102 TO pt_save_2102[].


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISP_DATA_INCLUDE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_disp_data_include .

  DATA : lt_2080 TYPE TABLE OF zgtppt2080.
  DATA : lv_idx TYPE i.

  DATA : BEGIN OF ls_collect_2090,
           plnid TYPE zgtppt2090-plnid,
*           ARBPL TYPE ZGTPPT2090-ARBPL,
           plmng TYPE zgtppt2091-plmng,
         END OF ls_collect_2090.
  DATA : lt_collect_2090 LIKE TABLE OF ls_collect_2090.
  DATA : lv_tabix TYPE i.
  DATA : lv_zpjno TYPE zsd0106t-zpjno.

  REFRESH gt_2090.
  REFRESH gt_2091.

* 시뮬레이션 생성화면에 나타날 데이터를 위해 해당월 포함되는 확정시뮬레이션 데이터 추출, 데이터 변환작업
  PERFORM get_set_new_disp_data.

*  생산계획을 수립할 판매계획 조회( 추출 기준 월간 생산계획 -> 판매계획 조회 -> 확정수량 조회
  IF gt_2090[] IS NOT INITIAL.
    SELECT * FROM zgtppt2080
      INTO CORRESPONDING FIELDS OF TABLE @lt_2080
       FOR ALL ENTRIES IN @gt_2090
    WHERE werks = @p_werks
         AND spgcd = @p_spgcd
         AND plnid = @gt_2090-plnid
        AND delfl <> @abap_true.
  ENDIF.

  IF line_exists( gt_2090[ plcnf = abap_true ] ).
    gv_status_confirm = abap_true.
  ENDIF.

* 판매계획 대상 조회
  DATA(lt_chk_2080) = lt_2080.
  SORT lt_chk_2080 BY cycltype vkbur spec zpjno vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_2080 COMPARING cycltype vkbur spec zpjno vbeln posnr.

  IF lt_chk_2080[] IS NOT INITIAL.
    SELECT * FROM zgtcvsalesplan
        FOR ALL ENTRIES IN @lt_chk_2080
      WHERE cycltype = @lt_chk_2080-cycltype
         AND vkbur = @lt_chk_2080-vkbur
         AND spec = @lt_chk_2080-spec
         AND zpjno = @lt_chk_2080-zpjno
*         AND VBELN = @LT_CHK_2080-VBELN
*         AND POSNR = @LT_CHK_2080-POSNR
      INTO TABLE @DATA(lt_salesplan).
  ENDIF.

  SORT lt_salesplan BY cycltype vkbur spec zpjno vbeln posnr.


* 확정대상 조회
  DATA(lt_chk_conf) = lt_2080.
  SORT lt_chk_conf BY werks spgcd plnid.
  DELETE ADJACENT DUPLICATES FROM lt_chk_conf COMPARING werks spgcd plnid.
  IF lt_chk_conf[] IS NOT INITIAL.
    SELECT a~plnid, a~simno, a~simvr, a~arbpl, a~pldat, b~matnr, b~idnrk, a~plmng
      FROM zgtppt2091 AS a
      INNER JOIN zgtppt2090 AS b ON b~simno = a~simno
                                            AND b~simvr = a~simvr
                                            AND b~plnid = a~plnid
      FOR ALL ENTRIES IN @lt_chk_conf
     WHERE a~werks = @lt_chk_conf-werks
       AND a~spgcd = @lt_chk_conf-spgcd
       AND a~plnid = @lt_chk_conf-plnid
       AND a~pldat < @gv_bgn_dt   " 시뮬레이션 기준 월도 확정수량은 포함안함
       AND b~plcnf = @abap_true
       AND b~simty IN @gr_simty " 동일한 시뮬레이션 타입끼리 비교
       AND a~pltype = '01'
      INTO TABLE @DATA(lt_2090).

    LOOP AT lt_2090 INTO DATA(ls_2090).
      CLEAR ls_collect_2090.
      MOVE-CORRESPONDING ls_2090 TO ls_collect_2090.
      COLLECT ls_collect_2090 INTO lt_collect_2090.
    ENDLOOP.

  ENDIF.

  REFRESH gt_maintain_plan.
  SORT gt_2090 BY plnid.

* 모인데이터 수량 콜렉트
  LOOP AT lt_chk_conf INTO DATA(ls_chk_conf).
    CLEAR gs_maintain_plan.

    REFRESH lt_chk_2080.
    lt_chk_2080 = VALUE #( FOR lw_2080 IN lt_2080 WHERE ( plnid = ls_chk_conf-plnid )
                                                                             ( CORRESPONDING #( lw_2080 ) ) ).

*   판매수량
    CLEAR lv_idx.
    LOOP AT lt_chk_2080 INTO DATA(ls_chk_2080).
      READ TABLE lt_salesplan INTO DATA(ls_salesplan) WITH KEY cycltype = ls_chk_2080-cycltype
                                                                                         vkbur = ls_chk_2080-vkbur
                                                                                         spec = ls_chk_2080-spec
                                                                                         zpjno = ls_chk_2080-zpjno
                                                                                         vbeln = ls_chk_2080-vbeln
                                                                                         posnr = ls_chk_2080-posnr
                                                                                         BINARY SEARCH.
      IF sy-subrc EQ 0.
        ADD 1 TO lv_idx.
        IF lv_idx = 1.
          gs_maintain_plan-plnid = ls_chk_conf-plnid.
          gs_maintain_plan-spec = ls_chk_2080-spec.
          gs_maintain_plan-zpjno = ls_chk_2080-zpjno.
* 프로젝트내역 추가
          IF ls_salesplan-zptxt IS INITIAL AND ls_salesplan-zpjno IS NOT INITIAL.
            TRY.
                CLEAR lv_zpjno.
                lv_zpjno = ls_salesplan-zpjno && '%'.
                SELECT SINGLE zptxt FROM zsd0106t
                  INTO gs_maintain_plan-zptxt
                  WHERE zpjno LIKE lv_zpjno
                    AND spart = ls_salesplan-spart.

              CATCH cx_root.
            ENDTRY.
          ELSE.
            gs_maintain_plan-zptxt = ls_salesplan-zptxt.
          ENDIF.

          gs_maintain_plan-spmon = ls_salesplan-basemonth.
          gs_maintain_plan-kunnr = ls_salesplan-kunnr.
          IF ls_salesplan-kunnr IS NOT INITIAL.
            SELECT SINGLE name1 FROM kna1
                INTO gs_disp_plan-name1
              WHERE kunnr = ls_salesplan-kunnr
                AND spras = sy-langu.
          ENDIF.
          gs_maintain_plan-meins = ls_chk_2080-meins.
          gs_maintain_plan-matnr = ls_chk_2080-matnr.
          gs_maintain_plan-sul_no = ls_chk_2080-sul_no.
        ENDIF.
*SRM2603-13210 FT단위 환산 처리
        IF ls_chk_2080-meins NE ls_salesplan-vrkme.

          PERFORM unit_conversion USING ls_chk_2080-meins
                                                                 ls_salesplan-vrkme
                                                       CHANGING ls_salesplan-quantity_dp.

        ENDIF.
*SRM2603-13210

        gs_maintain_plan-quantity_dp = gs_maintain_plan-quantity_dp + ls_salesplan-quantity_dp.
      ELSE.
        READ TABLE lt_salesplan INTO ls_salesplan WITH KEY cycltype = ls_chk_2080-cycltype
                                                                                         vkbur = ls_chk_2080-vkbur
                                                                                         spec = ls_chk_2080-spec
                                                                                         zpjno = ls_chk_2080-zpjno.
        IF sy-subrc EQ 0.
          ADD 1 TO lv_idx.
          IF lv_idx = 1.
            gs_maintain_plan-plnid = ls_chk_conf-plnid.
            gs_maintain_plan-spec = ls_chk_2080-spec.
            gs_maintain_plan-zpjno = ls_chk_2080-zpjno.
* 프로젝트내역 추가
            IF ls_salesplan-zptxt IS INITIAL AND ls_salesplan-zpjno IS NOT INITIAL.
              TRY.
                  CLEAR lv_zpjno.
                  lv_zpjno = ls_salesplan-zpjno && '%'.
                  SELECT SINGLE zptxt FROM zsd0106t
                    INTO gs_maintain_plan-zptxt
                    WHERE zpjno LIKE lv_zpjno
                      AND spart = ls_salesplan-spart.

                CATCH cx_root.
              ENDTRY.
            ELSE.
              gs_maintain_plan-zptxt = ls_salesplan-zptxt.
            ENDIF.

            gs_maintain_plan-spmon = ls_salesplan-basemonth.
            gs_maintain_plan-kunnr = ls_salesplan-kunnr.
            IF ls_salesplan-kunnr IS NOT INITIAL.
              SELECT SINGLE name1 FROM kna1
                  INTO gs_disp_plan-name1
                WHERE kunnr = ls_salesplan-kunnr
                  AND spras = sy-langu.
            ENDIF.
            gs_maintain_plan-meins = ls_chk_2080-meins.
            gs_maintain_plan-matnr = ls_chk_2080-matnr.
            gs_maintain_plan-sul_no = ls_chk_2080-sul_no.
          ENDIF.
*        일치하는 판매오더, 품목이 없을경우 수량 정보는 더해주지 않는다.
*        GS_MAINTAIN_PLAN-QUANTITY_DP = GS_MAINTAIN_PLAN-QUANTITY_DP + LS_SALESPLAN-QUANTITY_DP.
        ENDIF.
      ENDIF.

    ENDLOOP.

    CLEAR lv_tabix.
    READ TABLE gt_2090 INTO DATA(ls_chk_2090) WITH KEY plnid = ls_chk_conf-plnid.
    IF sy-subrc EQ 0.
      LOOP AT gt_2090 INTO ls_chk_2090 FROM sy-tabix.
        IF NOT ls_chk_2090-plnid = ls_chk_conf-plnid.
          EXIT.
        ENDIF.
        ADD 1 TO lv_tabix.
*        IF LV_TABIX = 1.

        READ TABLE gt_arbpl INTO gs_arbpl WITH KEY arbpl = ls_chk_2090-arbpl.
        gs_maintain_plan-arbpl = gs_arbpl-arbpl.
        gs_maintain_plan-ktext = gs_arbpl-ktext.

        PERFORM get_capa_data USING gs_maintain_plan ls_chk_2090-matnr ls_chk_2090-idnrk.
        PERFORM get_capainfor_data USING gs_maintain_plan ls_chk_2090-matnr ls_chk_2090-idnrk.
*        ENDIF.

*  확정수량
        READ TABLE lt_collect_2090 INTO ls_collect_2090 WITH KEY plnid = ls_chk_conf-plnid
                                                                                                  .
        IF sy-subrc EQ 0.
          gs_maintain_plan-plmng = ls_collect_2090-plmng.
        ENDIF.

*      판매오더 수량 잔량이 있을경우 어팬드 아닐 경우 목록에서 제외 시키다.
        IF gs_maintain_plan-quantity_dp > gs_maintain_plan-plmng. "
*        조회 순번 적용
          IF ls_chk_2090-arbpl = gs_arbpl-arbpl.
            gs_maintain_plan-seqno_d = ls_chk_2090-seqno.
          ENDIF.

          APPEND gs_maintain_plan TO gt_maintain_plan.
        ELSE.
          DELETE gt_2090 WHERE plnid = gs_main_data-plnid AND arbpl = gs_main_data-arbpl.
          DELETE gt_2091 WHERE plnid = gs_main_data-plnid AND arbpl = gs_main_data-arbpl.
        ENDIF.

      ENDLOOP.
    ENDIF.

  ENDLOOP.


  PERFORM set_disp_table.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SET_NEW_DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_set_new_disp_data .

  DATA : lt_2091 TYPE TABLE OF zgtppt2091.
  DATA : ls_plan LIKE gs_maintain_plan.
  DATA : lv_chk_date TYPE sy-datum.

* 시뮬레이션 생성 시작일 이후 종료되는 확정 시뮬레이션
  SELECT * FROM zgtppt2090
    INTO CORRESPONDING FIELDS OF TABLE gt_2090
   WHERE werks = p_werks
      AND spgcd = p_spgcd
      AND simty IN gr_simty " 동일한 시뮬레이션 타입끼리 비교
      AND zepmon >= gv_bgn_dt+0(6)
      AND plcnf = abap_true.

  DATA(lt_chk_2090) = gt_2090.
  SORT lt_chk_2090 BY simno simvr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_2090 COMPARING simno simvr.

* 시뮬레이션 생성 시작일 이후 건만 추출
  IF lt_chk_2090[] IS NOT INITIAL.
    SELECT * FROM zgtppt2091
      INTO CORRESPONDING FIELDS OF TABLE gt_2091
       FOR ALL ENTRIES IN lt_chk_2090
    WHERE werks = p_werks
      AND spgcd = p_spgcd
      AND simno = lt_chk_2090-simno
      AND simvr = lt_chk_2090-simvr
      AND pldat >= gv_bgn_dt.
  ENDIF .

* 가져온 시뮬레이션 데이터 비가동정보 업데이트
*  -  >  설비 대상 기준 업데이트 이후, 전체 설비 건 대상으로 업데이트
  LOOP AT gt_arbpl INTO gs_arbpl.
    CLEAR ls_plan.
    ls_plan-arbpl = gs_arbpl-arbpl.
    LOOP AT gt_2130 INTO DATA(ls_2130) WHERE optype = '03' AND arbpl = gs_arbpl-arbpl.
      APPEND INITIAL LINE TO lt_2091 ASSIGNING FIELD-SYMBOL(<ls_2091>).

      IF ls_2130-datuv = ls_2130-datub.

        PERFORM set_new_2091_03 USING ls_plan ls_2130-datuv ls_2130-nopnm CHANGING <ls_2091>.
      ELSE.
        lv_chk_date = ls_2130-datuv.
        DO.
          IF lv_chk_date > ls_2130-datub.
            EXIT.
          ENDIF.
          PERFORM set_new_2091_03 USING ls_plan lv_chk_date ls_2130-nopnm CHANGING <ls_2091>.

          ADD 1 TO lv_chk_date.
        ENDDO.
      ENDIF.
    ENDLOOP.

* 전체 설비건 대상
    LOOP AT gt_2130 INTO ls_2130 WHERE optype = '03' AND arbpl IS INITIAL.

      IF ls_2130-datuv = ls_2130-datub.

        READ TABLE lt_2091 TRANSPORTING NO FIELDS WITH KEY pldat = ls_2130-datuv.
        IF sy-subrc EQ 0.
          DELETE lt_2091 INDEX sy-tabix.
        ENDIF.

        APPEND INITIAL LINE TO lt_2091 ASSIGNING <ls_2091>.

        PERFORM set_new_2091_03 USING ls_plan ls_2130-datuv ls_2130-nopnm CHANGING <ls_2091>.
      ELSE.
        lv_chk_date = ls_2130-datuv.
        DO.
          IF lv_chk_date > ls_2130-datub.
            EXIT.
          ENDIF.

          READ TABLE lt_2091 TRANSPORTING NO FIELDS WITH KEY pldat = lv_chk_date.
          IF sy-subrc EQ 0.
            DELETE lt_2091 INDEX sy-tabix.
          ENDIF.

          APPEND INITIAL LINE TO lt_2091 ASSIGNING <ls_2091>.

          PERFORM set_new_2091_03 USING ls_plan lv_chk_date ls_2130-nopnm CHANGING <ls_2091>.

          ADD 1 TO lv_chk_date.
        ENDDO.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

* 비가동 정보 변경.
  SORT gt_2091 BY arbpl pldat.
  LOOP AT lt_2091 INTO DATA(ls_2091).
    LOOP AT gt_2091 ASSIGNING <ls_2091> WHERE arbpl = ls_2091-arbpl AND pldat = ls_2091-pldat.
      CLEAR : <ls_2091>-pltype, <ls_2091>-plmng, <ls_2091>-nopnm.
      <ls_2091>-pltype = ls_2091-pltype.
      <ls_2091>-nopnm = ls_2091-nopnm.
    ENDLOOP.
  ENDLOOP.

* 해당 시뮬레이션에서 사용하기 위해 가용월도, 설계번호, 버전, 시뮬레이션명 교체
  LOOP AT gt_2090 ASSIGNING FIELD-SYMBOL(<ls_2090>).
    CLEAR <ls_2090>-plcnf.
    <ls_2090>-simno = gv_simno.
    <ls_2090>-simvr = gv_simvr.
    <ls_2090>-simnm = gv_simnm.
    <ls_2090>-zspmon = gv_bgn_dt+0(6).
    <ls_2090>-zepmon = gv_end_dt+0(6).
  ENDLOOP.
* 해당 시뮬레이션에서 사용하기 위해 설계번호, 버전, 시뮬레이션명 교체
  LOOP AT gt_2091 ASSIGNING <ls_2091>.
    <ls_2091>-simno = gv_simno.
    <ls_2091>-simvr = gv_simvr.
  ENDLOOP.

  SORT gt_2090 BY werks spgcd arbpl plnid.
  DELETE ADJACENT DUPLICATES FROM gt_2090 COMPARING werks spgcd arbpl plnid.

  SORT gt_2091 BY werks spgcd arbpl plnid pldat.
  DELETE ADJACENT DUPLICATES FROM gt_2091 COMPARING werks spgcd arbpl plnid pldat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CONFIRM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_confirm_data .

  DATA : lt_2080 TYPE TABLE OF zgtppt2080.
  DATA : lv_idx TYPE i.

  DATA : BEGIN OF ls_collect_2090,
           plnid TYPE zgtppt2090-plnid,
*           ARBPL TYPE ZGTPPT2090-ARBPL,
           plmng TYPE zgtppt2091-plmng,
         END OF ls_collect_2090.
  DATA : lt_collect_2090 LIKE TABLE OF ls_collect_2090.
  DATA : lv_tabix TYPE i.
  DATA : lv_zpjno TYPE zsd0106t-zpjno.

  REFRESH gt_2090.
  REFRESH gt_2091.

* 시뮬레이션 생성화면에 나타날 데이터를 위해 해당월 포함되는 확정시뮬레이션 데이터 추출, 데이터 변환작업
  PERFORM get_set_confirm_data.

  IF gt_2091[] IS INITIAL.
    MESSAGE s001 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

*  생산계획을 수립할 판매계획 조회( 추출 기준 월간 생산계획 -> 판매계획 조회 -> 확정수량 조회
  IF gt_2090[] IS NOT INITIAL.
    SELECT * FROM zgtppt2080
      INTO CORRESPONDING FIELDS OF TABLE @lt_2080
       FOR ALL ENTRIES IN @gt_2090
    WHERE werks = @p_werks
         AND spgcd = @p_spgcd
         AND plnid = @gt_2090-plnid
         AND spec IN @s_spec
         AND zpjno IN @s_zpjno
        AND delfl <> @abap_true.
  ENDIF.

  IF line_exists( gt_2090[ plcnf = abap_true ] ).
    gv_status_confirm = abap_true.
  ENDIF.

* 판매계획 대상 조회
  DATA(lt_chk_2080) = lt_2080.
  SORT lt_chk_2080 BY cycltype vkbur spec zpjno vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_2080 COMPARING cycltype vkbur spec zpjno vbeln posnr.

  IF lt_chk_2080[] IS NOT INITIAL.
    SELECT * FROM zgtcvsalesplan
        FOR ALL ENTRIES IN @lt_chk_2080
      WHERE cycltype = @lt_chk_2080-cycltype
         AND vkbur = @lt_chk_2080-vkbur
         AND spec = @lt_chk_2080-spec
         AND zpjno = @lt_chk_2080-zpjno
*         AND VBELN = @LT_CHK_2080-VBELN
*         AND POSNR = @LT_CHK_2080-POSNR
      INTO TABLE @DATA(lt_salesplan).
  ENDIF.

  SORT lt_salesplan BY cycltype vkbur spec zpjno vbeln posnr.


* 확정대상 조회
  DATA(lt_chk_conf) = lt_2080.
  SORT lt_chk_conf BY werks spgcd plnid.
  DELETE ADJACENT DUPLICATES FROM lt_chk_conf COMPARING werks spgcd plnid.
  IF lt_chk_conf[] IS NOT INITIAL.
    SELECT a~plnid, a~simno, a~simvr, a~arbpl, a~pldat, b~matnr, b~idnrk, a~plmng
      FROM zgtppt2091 AS a
      INNER JOIN zgtppt2090 AS b ON b~simno = a~simno
                                            AND b~simvr = a~simvr
                                            AND b~plnid = a~plnid
      FOR ALL ENTRIES IN @lt_chk_conf
     WHERE a~werks = @lt_chk_conf-werks
       AND a~spgcd = @lt_chk_conf-spgcd
       AND a~plnid = @lt_chk_conf-plnid
       AND a~pldat < @gv_bgn_dt   " 시뮬레이션 기준 월도 확정수량은 포함안함
       AND b~plcnf = @abap_true
       AND b~simty IN @gr_simty " 동일한 시뮬레이션 타입끼리 비교
       AND a~pltype = '01'
      INTO TABLE @DATA(lt_2090).

    LOOP AT lt_2090 INTO DATA(ls_2090).
      CLEAR ls_collect_2090.
      MOVE-CORRESPONDING ls_2090 TO ls_collect_2090.
      COLLECT ls_collect_2090 INTO lt_collect_2090.
    ENDLOOP.

  ENDIF.

  REFRESH gt_maintain_plan.
  SORT gt_2090 BY plnid.

* 모인데이터 수량 콜렉트
  LOOP AT lt_chk_conf INTO DATA(ls_chk_conf).
    CLEAR gs_maintain_plan.

    REFRESH lt_chk_2080.
    lt_chk_2080 = VALUE #( FOR lw_2080 IN lt_2080 WHERE ( plnid = ls_chk_conf-plnid )
                                                                             ( CORRESPONDING #( lw_2080 ) ) ).

*   판매수량
    CLEAR lv_idx.
    LOOP AT lt_chk_2080 INTO DATA(ls_chk_2080).
      READ TABLE lt_salesplan INTO DATA(ls_salesplan) WITH KEY cycltype = ls_chk_2080-cycltype
                                                                                         vkbur = ls_chk_2080-vkbur
                                                                                         spec = ls_chk_2080-spec
                                                                                         zpjno = ls_chk_2080-zpjno
                                                                                         vbeln = ls_chk_2080-vbeln
                                                                                         posnr = ls_chk_2080-posnr
                                                                                         BINARY SEARCH.
      IF sy-subrc EQ 0.
        ADD 1 TO lv_idx.
        IF lv_idx = 1.
          gs_maintain_plan-plnid = ls_chk_conf-plnid.
          gs_maintain_plan-spec = ls_chk_2080-spec.
          gs_maintain_plan-zpjno = ls_chk_2080-zpjno.
* 프로젝트내역 추가
          IF ls_salesplan-zptxt IS INITIAL AND ls_salesplan-zpjno IS NOT INITIAL.
            TRY.
                CLEAR lv_zpjno.
                lv_zpjno = ls_salesplan-zpjno && '%'.
                SELECT SINGLE zptxt FROM zsd0106t
                  INTO gs_maintain_plan-zptxt
                  WHERE zpjno LIKE lv_zpjno
                    AND spart = ls_salesplan-spart.

              CATCH cx_root.
            ENDTRY.
          ELSE.
            gs_maintain_plan-zptxt = ls_salesplan-zptxt.
          ENDIF.
          gs_maintain_plan-spmon = ls_salesplan-basemonth.
          gs_maintain_plan-kunnr = ls_salesplan-kunnr.
          IF ls_salesplan-kunnr IS NOT INITIAL.
            SELECT SINGLE name1 FROM kna1
                INTO gs_disp_plan-name1
              WHERE kunnr = ls_salesplan-kunnr
                AND spras = sy-langu.
          ENDIF.
          gs_maintain_plan-meins = ls_chk_2080-meins.
          gs_maintain_plan-matnr = ls_chk_2080-matnr.
          gs_maintain_plan-sul_no = ls_chk_2080-sul_no.
        ENDIF.
*SRM2603-13210 FT단위 환산 처리
        IF ls_chk_2080-meins NE ls_salesplan-vrkme.

          PERFORM unit_conversion USING ls_chk_2080-meins
                                                                 ls_salesplan-vrkme
                                                       CHANGING ls_salesplan-quantity_dp.

        ENDIF.
*SRM2603-13210

        gs_maintain_plan-quantity_dp = gs_maintain_plan-quantity_dp + ls_salesplan-quantity_dp.
      ELSE.
        READ TABLE lt_salesplan INTO ls_salesplan WITH KEY cycltype = ls_chk_2080-cycltype
                                                                                         vkbur = ls_chk_2080-vkbur
                                                                                         spec = ls_chk_2080-spec
                                                                                         zpjno = ls_chk_2080-zpjno.
        IF sy-subrc EQ 0.
          ADD 1 TO lv_idx.
          IF lv_idx = 1.
            gs_maintain_plan-plnid = ls_chk_conf-plnid.
            gs_maintain_plan-spec = ls_chk_2080-spec.
            gs_maintain_plan-zpjno = ls_chk_2080-zpjno.
* 프로젝트내역 추가
            IF ls_salesplan-zptxt IS INITIAL AND ls_salesplan-zpjno IS NOT INITIAL.
              TRY.
                  CLEAR lv_zpjno.
                  lv_zpjno = ls_salesplan-zpjno && '%'.
                  SELECT SINGLE zptxt FROM zsd0106t
                    INTO gs_maintain_plan-zptxt
                    WHERE zpjno LIKE lv_zpjno
                      AND spart = ls_salesplan-spart.

                CATCH cx_root.
              ENDTRY.
            ELSE.
              gs_maintain_plan-zptxt = ls_salesplan-zptxt.
            ENDIF.

            gs_maintain_plan-spmon = ls_salesplan-basemonth.
            gs_maintain_plan-kunnr = ls_salesplan-kunnr.
            IF ls_salesplan-kunnr IS NOT INITIAL.
              SELECT SINGLE name1 FROM kna1
                  INTO gs_disp_plan-name1
                WHERE kunnr = ls_salesplan-kunnr
                  AND spras = sy-langu.
            ENDIF.
            gs_maintain_plan-meins = ls_chk_2080-meins.
            gs_maintain_plan-matnr = ls_chk_2080-matnr.
            gs_maintain_plan-sul_no = ls_chk_2080-sul_no.
          ENDIF.
*        일치하는 판매오더, 품목이 없을경우 수량 정보는 더해주지 않는다.
*        GS_MAINTAIN_PLAN-QUANTITY_DP = GS_MAINTAIN_PLAN-QUANTITY_DP + LS_SALESPLAN-QUANTITY_DP.
        ENDIF.
      ENDIF.

    ENDLOOP.

    CLEAR lv_tabix.
    READ TABLE gt_2090 INTO DATA(ls_chk_2090) WITH KEY plnid = ls_chk_conf-plnid.
    IF sy-subrc EQ 0.
      LOOP AT gt_2090 INTO ls_chk_2090 FROM sy-tabix.
        IF NOT ls_chk_2090-plnid = ls_chk_conf-plnid.
          EXIT.
        ENDIF.
        ADD 1 TO lv_tabix.
*        IF LV_TABIX = 1.

        READ TABLE gt_arbpl INTO gs_arbpl WITH KEY arbpl = ls_chk_2090-arbpl.
        gs_maintain_plan-arbpl = gs_arbpl-arbpl.
        gs_maintain_plan-ktext = gs_arbpl-ktext.

        PERFORM get_capa_data USING gs_maintain_plan ls_chk_2090-matnr ls_chk_2090-idnrk.
        PERFORM get_capainfor_data USING gs_maintain_plan ls_chk_2090-matnr ls_chk_2090-idnrk.
*        ENDIF.

*  확정수량
        READ TABLE lt_collect_2090 INTO ls_collect_2090 WITH KEY plnid = ls_chk_conf-plnid
                                                                                                  .
        IF sy-subrc EQ 0.
          gs_maintain_plan-plmng = ls_collect_2090-plmng.
        ENDIF.

*        조회 순번 적용
        IF ls_chk_2090-arbpl = gs_arbpl-arbpl.
          gs_maintain_plan-seqno_d = ls_chk_2090-seqno.
        ENDIF.

        APPEND gs_maintain_plan TO gt_maintain_plan.
      ENDLOOP.
    ENDIF.

  ENDLOOP.


  PERFORM set_disp_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SET_confirm_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_set_confirm_data .

  DATA : lv_tabix TYPE i.
  DATA : lt_2091 TYPE TABLE OF zgtppt2091.

  SELECT a~*
    FROM zgtppt2100 AS a
    INNER JOIN zgtppt2090 AS b ON b~werks = a~werks
                                          AND b~spgcd = a~spgcd
                                          AND b~simno = a~simno
                                          AND b~simvr = a~simvr
   WHERE a~werks = @p_werks
      AND a~spgcd = @p_spgcd
      AND a~zspmon BETWEEN @gv_bgn_dt+0(6) AND @gv_end_dt+0(6)
      AND b~plcnf = @abap_true
      AND b~simty IN @gr_simty
      INTO TABLE @DATA(lt_2100).

  SELECT b~*
    FROM @lt_2100 AS a
    INNER JOIN zgtppt2090 AS b ON b~werks = a~werks
                                            AND b~spgcd = a~spgcd
                                            AND b~simno = a~simno
                                            AND b~simvr = a~simvr
   WHERE b~plcnf = @abap_true
       AND b~simty IN @gr_simty
       AND b~arbpl IN @s_arbpl
    INTO CORRESPONDING FIELDS OF TABLE @gt_2090.

  DATA(lt_chk_2090) = gt_2090.
  SORT lt_chk_2090 BY simno simvr.
  DELETE ADJACENT DUPLICATES FROM lt_chk_2090 COMPARING simno simvr.

* 시뮬레이션 생성 시작일 이후 건만 추출
  IF lt_chk_2090[] IS NOT INITIAL.
    SELECT * FROM zgtppt2091
      INTO CORRESPONDING FIELDS OF TABLE gt_2091
       FOR ALL ENTRIES IN lt_chk_2090
    WHERE werks = p_werks
      AND spgcd = p_spgcd
      AND simno = lt_chk_2090-simno
      AND simvr = lt_chk_2090-simvr
      AND arbpl IN s_arbpl
    AND pldat BETWEEN gv_bgn_dt AND gv_end_dt.

    LOOP AT lt_2100 INTO DATA(ls_2100).
      lt_2091 = VALUE #( FOR lw_2091 IN gt_2091 WHERE ( simno = ls_2100-simno
                                                                         AND   simvr = ls_2100-simvr
                                                                         AND    plnid = ls_2100-plnid
                                                                         AND    pldat+0(6) = ls_2100-zspmon
                                                                         AND   pltype = '01' )
                                ( CORRESPONDING #( lw_2091 ) ) ).
      IF lt_2091[] IS INITIAL.
        DELETE gt_2091 WHERE simno = ls_2100-simno
                                    AND simvr = ls_2100-simvr
                                    AND plnid = ls_2100-plnid
                                    AND pldat+0(6) = ls_2100-zspmon.
      ENDIF.

    ENDLOOP.

    LOOP AT gt_2090 INTO DATA(ls_2090).
      lv_tabix = sy-tabix.
      READ TABLE gt_2091 TRANSPORTING NO FIELDS WITH KEY simno = ls_2090-simno
                                                                                     simvr = ls_2090-simvr
                                                                                     plnid = ls_2090-plnid
                                                                                     arbpl = ls_2090-arbpl.
      IF sy-subrc NE 0.
        DELETE gt_2090 INDEX lv_tabix.
      ENDIF.

    ENDLOOP.

  ENDIF .

  SORT gt_2090 BY werks spgcd arbpl plnid.
  DELETE ADJACENT DUPLICATES FROM gt_2090 COMPARING werks spgcd arbpl plnid.

  SORT gt_2091 BY werks spgcd arbpl plnid pldat.
  DELETE ADJACENT DUPLICATES FROM gt_2091 COMPARING werks spgcd arbpl plnid pldat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DEL_LINES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM proc_del_lines .

  DATA : lt_cells TYPE lvc_t_ceno.

  IF gv_status_confirm = abap_true.
    MESSAGE s003 DISPLAY LIKE 'E' WITH '확정된 월간 생산 계획 시뮬레이션으로 수정할 수 없습니다.'(e09).
    RETURN.
  ENDIF.

  go_grid_0100->get_selected_cells_id(
      IMPORTING
       et_cells = lt_cells ).                " Cell IDs

  DATA(lt_cell_chk) = lt_cells.

  IF lt_cells[] IS INITIAL.
    RETURN.
  ENDIF.

  SORT lt_cells BY row_id.
  DELETE ADJACENT DUPLICATES FROM lt_cells COMPARING row_id.
* 가용한 날짜 필드 인지 확인
  LOOP AT lt_cells INTO DATA(ls_cells).
    DATA(lv_idx) = sy-tabix.
* 비가동 일정이나 다른 값들이 포함되어있으면 작업불가.
    CLEAR gs_main_data.
    READ TABLE <gt_main_disp_100> ASSIGNING FIELD-SYMBOL(<ls_main>) INDEX ls_cells-row_id.
    MOVE-CORRESPONDING <ls_main> TO gs_main_data.

    IF gs_main_data-sum_chk IS NOT INITIAL. "섬필드는 가용수량 변경없음
      DELETE lt_cells INDEX lv_idx.
      CONTINUE.
    ENDIF.

    IF gs_main_data-plnid IS INITIAL. "판매계획이 매핑되지 않은 필드는 삭제 대상이 아님
      DELETE lt_cells INDEX lv_idx.
      CONTINUE.
    ENDIF.

  ENDLOOP.

  IF lt_cells IS NOT INITIAL.
    CLEAR gv_answer.
    PERFORM popup_to_confirm_step USING 'N'
      ' '
      '선택된 라인의 계획이 모두 삭제됩니다. 계속 진행하시겠습니까?'
      '삭제확인'.
    IF gv_answer NE 'J'.
      MESSAGE s003 DISPLAY LIKE 'E' WITH '작업 취소 되었습니다.'.
      RETURN.
    ENDIF.

  ENDIF.

  LOOP AT lt_cells INTO ls_cells.

    CLEAR gs_main_data.
    READ TABLE <gt_main_disp_100> ASSIGNING <ls_main> INDEX ls_cells-row_id.
    MOVE-CORRESPONDING <ls_main> TO gs_main_data.

    DELETE gt_2091 WHERE arbpl = gs_main_data-arbpl
                                AND plnid = gs_main_data-plnid
                                AND pltype NE '03'.

  ENDLOOP.

  PERFORM set_disp_table.
  PERFORM refresh_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_JOJANG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN_DATA_PLNID
*&      <-- GS_MAIN_DATA_CHK_JOJANG
*&---------------------------------------------------------------------*
FORM check_jojang  USING    pv_plnid
                   CHANGING pv_jojang.

  DATA : BEGIN OF ls_chk_ordnr,
           dmord TYPE zgtppt2010-dmord,
         END OF ls_chk_ordnr.
  DATA : lt_chk_ordnr LIKE TABLE OF ls_chk_ordnr.

  SELECT * FROM zgtppt2080
    WHERE werks = @p_werks
      AND spgcd = @p_spgcd
      AND plnid = @pv_plnid
    INTO TABLE @DATA(lt_2080).
  IF sy-subrc EQ 0.
    LOOP AT lt_2080 INTO DATA(ls_2080).
      CLEAR ls_chk_ordnr.
      IF ls_2080-vbeln IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = ls_2080-vbeln
          IMPORTING
            output = ls_chk_ordnr-dmord.

        COLLECT ls_chk_ordnr INTO lt_chk_ordnr.
      ENDIF.
    ENDLOOP.

    IF lt_chk_ordnr[] IS NOT INITIAL.
      SELECT * FROM zgtppt2010
        FOR ALL ENTRIES IN @lt_chk_ordnr
       WHERE dmordty = 'SO'
          AND dmord = @lt_chk_ordnr-dmord
        INTO TABLE @DATA(lt_chk_2010).
      IF sy-subrc EQ 0.
        pv_jojang = icon_list.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_ZGTPPR2050
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN_DATA_PLNID
*&---------------------------------------------------------------------*
FORM call_zgtppr2050  USING    pv_plnid.

  DATA : BEGIN OF ls_chk_ordnr,
           dmord TYPE zgtppt2010-dmord,
         END OF ls_chk_ordnr.
  DATA : lt_chk_ordnr LIKE TABLE OF ls_chk_ordnr.

  SELECT * FROM zgtppt2080
    WHERE werks = @p_werks
      AND spgcd = @p_spgcd
      AND plnid = @pv_plnid
    INTO TABLE @DATA(lt_2080).
  IF sy-subrc EQ 0.
    LOOP AT lt_2080 INTO DATA(ls_2080).
      CLEAR ls_chk_ordnr.
      IF ls_2080-vbeln IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = ls_2080-vbeln
          IMPORTING
            output = ls_chk_ordnr-dmord.

        COLLECT ls_chk_ordnr INTO lt_chk_ordnr.
      ENDIF.
    ENDLOOP.

    IF lt_chk_ordnr[] IS NOT INITIAL.
      SELECT grpnr FROM zgtppt2010
        FOR ALL ENTRIES IN @lt_chk_ordnr
       WHERE dmordty = 'SO'
          AND dmord = @lt_chk_ordnr-dmord
        INTO TABLE @DATA(lt_grpnr).
    ENDIF.

    CHECK lt_grpnr[] IS NOT INITIAL.
    READ TABLE lt_grpnr INTO DATA(ls_grpnr) INDEX 1.


    SET PARAMETER ID: 'AUN' FIELD space. "
    SET PARAMETER ID: 'WRK' FIELD '1302'.
    SET PARAMETER ID: 'ZSPG' FIELD 'PC'.
    SET PARAMETER ID: 'ZGRPNR' FIELD ls_grpnr-grpnr.

    CALL TRANSACTION 'ZGTPPR2050'AND SKIP FIRST SCREEN.

    SET PARAMETER ID: 'ZGRPNR' FIELD space.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_AVAILABLE_FIRST_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_MAIN_DATA
*&      --> LV_CHK_DATE
*&      --> LV_PLMNG
*&      <-- LS_2091_INIT
*&---------------------------------------------------------------------*
FORM chk_available_first_line  USING    ps_main_data LIKE gs_main_data
                                                pv_chk_date TYPE sy-datum
                                                pv_plmng TYPE zgtppt2091-plmng
                               CHANGING    ps_2091 TYPE zgtppt2091
                                                pv_chk_err.


  DATA : lv_rate TYPE p LENGTH 15 DECIMALS 5.
  DATA : lv_rate_sum TYPE p LENGTH 15 DECIMALS 5.
  DATA : lv_plmng TYPE zgtppt2091-plmng.
  DATA : lv_plmng_cal TYPE zgtppt2091-plmng.
  DATA : lv_plmng_cal_c TYPE c LENGTH 30.
  DATA : lv_tabix TYPE i.
  DATA : ls_2120 TYPE zgtppt2120.

  LOOP AT gt_2091 INTO DATA(ls_2091) WHERE arbpl = ps_main_data-arbpl
                                                  AND pldat = pv_chk_date
                                                  AND pltype = '01'.


    READ TABLE gt_maintain_plan INTO DATA(ls_plan) WITH KEY plnid = ls_2091-plnid
                                                                                         arbpl = ls_2091-arbpl.

    READ TABLE gt_2090 INTO DATA(ls_2090) WITH KEY plnid = ls_2091-plnid
                                                                         arbpl = ls_2091-arbpl.

* 기본정보 리드 (캐파정보- 선속) _일자별 선속 계산후 상태처리를 위해 기본 정보 가지고 있는다.
    CLEAR ls_2120.
    READ TABLE gt_2120_use INTO ls_2120 WITH KEY spec = ls_plan-spec
                                                                          cptype = '03'
                                                                          idnrk = ls_2090-idnrk
                                                                         arbpl = ps_main_data-arbpl.
* 일별 선속정보 구하기
    CLEAR lv_plmng.
    PERFORM cal_day_plmng USING ls_2120-vgwrt ls_2120-vgweh CHANGING lv_plmng.

    ADD 1 TO lv_tabix.

    CLEAR lv_rate.
    IF lv_plmng NE 0.
      lv_rate = ls_2091-plmng / lv_plmng.
    ELSE.
      lv_rate = 1.
    ENDIF.

    ADD lv_rate TO lv_rate_sum.

  ENDLOOP.

  IF  lv_tabix >= 1.

    IF lv_rate_sum >= 1.
      pv_chk_err = abap_true.
    ELSEIF lv_rate_sum < 1.
      lv_plmng_cal = ( 1 - lv_rate_sum ) * pv_plmng.
      lv_plmng_cal_c = lv_plmng_cal.
      CONDENSE lv_plmng_cal_c.
      SPLIT lv_plmng_cal_c AT '.' INTO DATA(lv_num) DATA(lv_dummy).
      lv_plmng_cal = lv_num.

      ps_2091-werks = p_werks.
      ps_2091-spgcd = p_spgcd.
      ps_2091-simno = gv_simno.
      ps_2091-simvr = gv_simvr.
      ps_2091-arbpl = ps_main_data-arbpl.
      ps_2091-plnid = ps_main_data-plnid.
      ps_2091-pldat = pv_chk_date.
      ps_2091-pltype = '01'.
      ps_2091-plmng = lv_plmng_cal.


    ENDIF.
  ELSE.
    ps_2091-werks = p_werks.
    ps_2091-spgcd = p_spgcd.
    ps_2091-simno = gv_simno.
    ps_2091-simvr = gv_simvr.
    ps_2091-arbpl = ps_main_data-arbpl.
    ps_2091-plnid = ps_main_data-plnid.
    ps_2091-pldat = pv_chk_date.
    ps_2091-pltype = '01'.
    ps_2091-plmng = pv_plmng.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CATCH_AVAILABLE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ORDER_AUFNR
*&      <-- LV_CHK_AVAILABLE
*&---------------------------------------------------------------------*
FORM catch_available_order  USING pv_aufnr TYPE aufnr
                                         CHANGING pv_chk_available.

  DATA : lt_tj02t LIKE tj02t OCCURS 0 WITH HEADER LINE.
  DATA : lv_stcd TYPE zordstcd.
  DATA : lv_objnr TYPE jest-objnr.
  DATA : lv_user_line TYPE bsvx-sttxt.

*    상태값 조회
  CLEAR lv_stcd.
  REFRESH lt_tj02t.
  CALL FUNCTION 'Z_PP_RETURN_ORDER_STATUS'
    EXPORTING
      im_aufnr        = pv_aufnr
    IMPORTING
      ex_ostcd        = lv_stcd
    TABLES
      et_sttxt        = lt_tj02t
    EXCEPTIONS
      no_selection    = 1
      not_found_objnr = 2
      OTHERS          = 3.

  CASE lv_stcd.
    WHEN 'E' OR 'Z'.
      pv_chk_available = abap_true.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SEQNO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_2091
*&---------------------------------------------------------------------*
FORM set_seqno  TABLES   pt_2090 STRUCTURE zgtppt2090.

  DATA : lv_seqno TYPE zgtppt2090-seqno.
  DATA(lt_sort) = pt_2090[].
  SORT lt_sort BY arbpl.
  DELETE ADJACENT DUPLICATES FROM lt_sort COMPARING arbpl.

  SORT pt_2090 BY arbpl seqno.

  LOOP AT lt_sort INTO DATA(ls_sort).
    CLEAR lv_seqno.
    LOOP AT pt_2090 ASSIGNING FIELD-SYMBOL(<ls_main>) WHERE arbpl = ls_sort-arbpl.
      ADD 1 TO lv_seqno.
      <ls_main>-seqno = lv_seqno.
    ENDLOOP.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form UNIT_CONVERSION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CHK_2080_MEINS
*&      --> LS_SALESPLAN_VRKME
*&      <-- LS_SALESPLAN_QUANTITY_DP
*&---------------------------------------------------------------------*
FORM unit_conversion  USING    p_meins
                                                 p_vrkme
                              CHANGING p_quantity_dp.

  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      input                = p_quantity_dp
      unit_in              = p_vrkme
      unit_out             = p_meins
    IMPORTING
      output               = p_quantity_dp
    EXCEPTIONS
      conversion_not_found = 1
      division_by_zero     = 2
      input_invalid        = 3
      output_invalid       = 4
      overflow             = 5
      type_invalid         = 6
      units_missing        = 7
      unit_in_not_found    = 8
      unit_out_not_found   = 9
      OTHERS               = 10.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form find_ins_matnh
*&---------------------------------------------------------------------*
* 2026.05.26.zlsgpp5.CHM2605-00421.절연 반제품 자재코드 미생성 항목에
*   대해서 완제품 자재코드 존재 시 반제품코드 자동탐색 및 설정 기능추가.
*&---------------------------------------------------------------------*
FORM find_ins_matnh  USING    iv_matnf
                     CHANGING ov_matnh.

  CONSTANTS: c_pd_ca_proc_gr TYPE ausp-atinn VALUE '0000004717'.

*___완제품 자재코드가 존재시.
  CHECK iv_matnf IS NOT INITIAL.

*___BOM 전개.
  DATA: ls_cstmat TYPE cstmat,
        lt_stb    TYPE TABLE OF stpox.

  CLEAR: ls_cstmat, lt_stb.
  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      capid                 = 'PP01'
      datuv                 = sy-datum
      mehrs                 = 'X' "Multilevel Explosion
      mtnrv                 = iv_matnf
      stlan                 = '1'
      werks                 = p_werks
    IMPORTING
      topmat                = ls_cstmat
    TABLES
      stb                   = lt_stb[]
    EXCEPTIONS
      alt_not_found         = 1
      call_invalid          = 2
      material_not_found    = 3
      missing_authorization = 4
      no_bom_found          = 5
      no_plant_data         = 6
      no_suitable_bom_found = 7
      conversion_error      = 8
      OTHERS                = 9.
  IF sy-subrc <> 0.
    "Implement suitable error handling here
  ENDIF.

  "*___속성이 절연 건만 남김.
  SORT lt_stb.
  LOOP AT lt_stb ASSIGNING FIELD-SYMBOL(<lt_stb>).
    SELECT SINGLE objek INTO @DATA(lv_objek)
      FROM ausp
     WHERE objek = @<lt_stb>-idnrk
       AND atinn = @c_pd_ca_proc_gr
       AND klart = '001'
       AND atwrt = 'INS'.
    IF sy-subrc NE 0.
      CLEAR: <lt_stb>-idnrk.
    ENDIF.
  ENDLOOP.
  DELETE lt_stb WHERE idnrk EQ space.

  "___상위레벨이고 순서가 마지막인 절연 반제품 찾기.
  SORT lt_stb BY  stufe
                  wegxx DESCENDING.

  IF lt_stb[] IS NOT INITIAL.
    READ TABLE lt_stb ASSIGNING <lt_stb> INDEX 1.
    IF sy-subrc EQ 0.
      ov_matnh = <lt_stb>-idnrk.
    ENDIF.
  ENDIF.

ENDFORM.
