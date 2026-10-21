*&---------------------------------------------------------------------*
*& Include          ZGTPPR2090F01
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

    IF p_colled IS NOT INITIAL.
      IF screen-group1 = 'A1'.
        screen-input = 0.
*        SCREEN-INTENSIFIED = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

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

* 시뮬레이션명
  IF NOT p_simno IS INITIAL.
    SELECT SINGLE simnm INTO p_simnm
             FROM zgtppt2090
            WHERE simno EQ p_simno.
  ELSE.
    CLEAR p_simnm.
  ENDIF.

* 시뮬레이션명
  IF NOT p_simno2 IS INITIAL.
    SELECT SINGLE simnm INTO p_simnm2
             FROM zgtppt2090
            WHERE simno EQ p_simno2.
  ELSE.
    CLEAR p_simnm2.
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

  CHECK p_werks IS NOT INITIAL AND p_spgcd IS NOT INITIAL.


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

    SELECT SINGLE ddtext FROM dd07t
      INTO <ls_simul>-ddtext
      WHERE domname = 'ZGTDSIMTY'
         AND domvalue_l = <ls_simul>-simty.

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
FORM get_dynp_value  USING    pv_fieldname TYPE dynpread-fieldname.

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
*& Form F4_SIMNO2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_simno2  USING    pv_dynprofld TYPE help_info-dynprofld .

  DATA : BEGIN OF ls_simul,
           seqno  TYPE zgtppt3270-seqno,
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
  PERFORM get_dynp_value USING 'P_SIMNO'.
  PERFORM get_dynp_value USING 'P_SIMVR'.


  CHECK p_werks IS NOT INITIAL AND p_spgcd IS NOT INITIAL.

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

  SELECT simno, simvr, simnm, zspmon, zepmon, plcnf
    FROM zgtppt2090
    WHERE werks = @p_werks
      AND spgcd = @p_spgcd
      AND simno IN @lt_simno
      AND simvr NE @p_simvr
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
      <ls_dynpfields>-fieldname = 'P_SIMNO2'.
      <ls_dynpfields>-stepl = lv_line.
      <ls_dynpfields>-fieldvalue = ls_2090-simno.

*      시뮬레이션 이름
      APPEND INITIAL LINE TO lt_dynpfields ASSIGNING <ls_dynpfields>.
      <ls_dynpfields>-fieldname = 'P_SIMNM2'.
      <ls_dynpfields>-stepl = lv_line.
      <ls_dynpfields>-fieldvalue = ls_2090-simnm.

*      시뮬레이션 번호
      APPEND INITIAL LINE TO lt_dynpfields ASSIGNING <ls_dynpfields>.
      <ls_dynpfields>-fieldname = 'P_SIMVR2'.
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
*& Form F4_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_arbpl  USING    pv_dynprofld TYPE help_info-dynprofld.

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
* 디스플레이 화면 구성, 동적 인터널테이블 생성
  PERFORM init_screen_100 CHANGING lv_chk_err.

  IF lv_chk_err IS NOT INITIAL.
    MESSAGE s001 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

* 계획수립 작업장 마스터
  PERFORM  get_master.


* 비교대상 화면 구축
  gv_simno = p_simno2.
  gv_simvr = p_simvr2.
  PERFORM get_plan_data.

  MOVE-CORRESPONDING <gt_main_disp_100> TO <gt_main_disp_101>.
  IF gv_status_confirm IS NOT INITIAL.
    gv_status_confirm_re = abap_true.
  ENDIF.

  CLEAR gv_status_confirm.
* 원본 화면 구축
  gv_simno = p_simno.
  gv_simvr = p_simvr.
  PERFORM get_plan_data.


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
*& Form INIT_SCREEN_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM init_screen_100  CHANGING pv_chk_err.

  PERFORM set_fieldcat_0100 CHANGING pv_chk_err.
  CHECK pv_chk_err IS INITIAL.
  PERFORM make_itab_fr_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      <-- E_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM alv_top_of_page  USING    po_sender TYPE REF TO cl_gui_alv_grid
                                CHANGING    po_dyndoc_id  TYPE REF TO  cl_dd_document.

  CASE po_sender.
    WHEN go_grid_0100.
      PERFORM set_title_crt_simul CHANGING po_dyndoc_id.
    WHEN go_grid_0101.
      PERFORM set_title_crt_simul_re CHANGING po_dyndoc_id.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_CRT_SIMUL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PO_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM set_title_crt_simul CHANGING po_dyndoc_id  TYPE REF TO  cl_dd_document.

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

* 시뮬레이션 "
  CLEAR lv_text.
  lv_text = p_simnm && '(' && gv_bgn_dt+0(4) &&'.' && gv_bgn_dt+4(2) && ')'.

  lv_version = 'ver.' && p_simvr.

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

  "위쪽에 추가한 텍스트 출력
  CALL METHOD po_dyndoc_id->display_document
    EXPORTING
      parent             = go_contain_top_0100
      reuse_control      = abap_true
      reuse_registration = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TITLE_CRT_SIMUL_RE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PO_DYNDOC_ID
*&---------------------------------------------------------------------*
FORM set_title_crt_simul_re  CHANGING po_dyndoc_id  TYPE REF TO  cl_dd_document.

  DATA : lv_text(255) TYPE c.
  DATA : lv_version(15) .
  DATA : lv_ver(3) TYPE n.
  DATA : lv_fr_spmon(10).
  DATA : lv_to_spmon(10).


* 시뮬레이션 "
  CLEAR lv_text.
  lv_text = p_simnm2 && '(' && gv_bgn_dt+0(4) &&'.' && gv_bgn_dt+4(2) && ')'.

  lv_version = 'ver.' && p_simvr2.

  CONCATENATE '시뮬레이션 :' lv_text lv_version INTO lv_text SEPARATED BY space.

  IF gv_status_confirm_re = abap_true.
    CONCATENATE lv_text '*확정*' INTO lv_text SEPARATED BY space.
  ENDIF.

  "텍스트 추가
  CALL METHOD po_dyndoc_id->add_text
    EXPORTING
      text         = lv_text
      sap_fontsize = '20'.

  CALL METHOD po_dyndoc_id->new_line.

  "위쪽에 추가한 텍스트 출력
  CALL METHOD po_dyndoc_id->display_document
    EXPORTING
      parent             = go_contain_top_0101
      reuse_control      = abap_true
      reuse_registration = abap_true.

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

  CASE abap_true.
    WHEN p_rad1.

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

    WHEN p_rad2.
      LOOP AT gt_spmon INTO gs_spmon.
        APPEND INITIAL LINE TO gt_fieldcat_0100 ASSIGNING <ls_fcat>.
        ADD 1 TO lv_col_pos.
        <ls_fcat>-col_pos = lv_col_pos.
        <ls_fcat>-fieldname = gs_spmon-spmon.
        CLEAR lv_text.
        lv_text = gs_spmon-spmon+0(4) && '.' && gs_spmon-spmon+4(2).
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = lv_text.
        <ls_fcat>-datatype = 'CHAR'.
        <ls_fcat>-dd_outlen = '20'.
        <ls_fcat>-outputlen = '9'.
        <ls_fcat>-decimals_o = 0.
        <ls_fcat>-just = 'R'.
      ENDLOOP.

  ENDCASE.

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
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '계획단위'(f10).
        <ls_fcat>-just = 'C'.
        <ls_fcat>-outputlen = '5'.
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
        <ls_fcat>-no_out = abap_true.
      WHEN 'PLMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '수립계획'(f07).
        <ls_fcat>-just = 'R'.
        <ls_fcat>-fix_column = abap_true.
        <ls_fcat>-qfieldname = 'MEINS'.
        <ls_fcat>-outputlen = '13'.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = '완제품코드'(f08).
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
    ENDCASE.
  ENDLOOP.

  SORT gt_fieldcat_0100 BY col_pos.

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
  CREATE DATA gt_main_disp_101 LIKE <gt_main_disp_100>.
  ASSIGN gt_main_disp_101->* TO <gt_main_disp_101>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DISP_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_BGN_DT
*&      <-- GV_END_DT
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM get_disp_data  CHANGING pv_bgn_dt TYPE sy-datum
                                               pv_end_dt  TYPE sy-datum
                                               pv_chk_err.

  DATA : lv_bgn_spmon TYPE spmon.
  DATA : lv_end_spmon TYPE spmon.
  DATA : lv_chk_date TYPE sy-datum.

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

  lv_chk_date = pv_bgn_dt.
  DO.
    CLEAR gs_spmon.
    gs_spmon-spmon = lv_chk_date+0(6).
    COLLECT gs_spmon INTO gt_spmon.

    IF gs_spmon-spmon = pv_end_dt+0(6).
      EXIT.
    ELSE.
      ADD 1 TO lv_chk_date.
    ENDIF.
  ENDDO.

  SORT gt_spmon BY spmon.

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
*& Form GET_MASTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_master .

* 설비 마스터 정보
  SELECT a~gong_cd, a~seq, a~arbpl, c~ktext
    FROM zgtppt2110 AS a
      INNER JOIN crhd AS b  ON b~arbpl = a~arbpl
                            AND b~werks = a~werks
      INNER JOIN crtx AS c  ON c~objty = b~objty
                            AND c~objid = b~objid
   WHERE a~werks = @p_werks
     AND a~spgcd = @p_spgcd
     AND a~arbpl IN @s_arbpl
     AND b~objty = 'A'
     AND c~spras = @sy-langu
     INTO CORRESPONDING FIELDS OF TABLE @gt_arbpl.

  SORT gt_arbpl BY seq gong_cd arbpl.
  DELETE ADJACENT DUPLICATES FROM gt_arbpl COMPARING seq gong_cd arbpl.

  CASE abap_true.
    WHEN p_rad1.
      gv_title = '월간계획(생산계획비교) - 일별'.
    WHEN p_rad2.
      gv_title = '월간계획(생산계획비교) - 월별'.
  ENDCASE.


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

  "[GT] 월간 생산계획(생산계획 시뮬레이션 Header)
  SELECT * FROM zgtppt2090
    INTO CORRESPONDING FIELDS OF TABLE gt_2090
   WHERE werks = p_werks
     AND spgcd = p_spgcd
     AND simno = gv_simno
     AND simvr = gv_simvr
     AND arbpl IN s_arbpl.

  IF gt_2090 IS INITIAL.
    MESSAGE s006 DISPLAY LIKE 'E' WITH '조회결과가 없습니다.'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  "[GT] 월간 생산계획(생산계획 시뮬레이션 Detail)
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
     WHERE werks  = @p_werks
       AND spgcd  = @p_spgcd
       AND plnid  = @gt_2090-plnid
       AND spec   IN @s_spec
       AND zpjno  IN @s_zpjno
       AND delfl  <> @abap_true.
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
    lt_chk_2080 = VALUE #(  FOR lw_2080 IN lt_2080
                            WHERE ( plnid = ls_chk_conf-plnid )
                            ( CORRESPONDING #( lw_2080 ) ) ).

*   판매수량
    CLEAR lv_idx.
    LOOP AT lt_chk_2080 INTO DATA(ls_chk_2080).
      READ TABLE lt_salesplan INTO DATA(ls_salesplan)
                              WITH KEY cycltype = ls_chk_2080-cycltype
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
        gs_maintain_plan-quantity_dp = gs_maintain_plan-quantity_dp + ls_salesplan-quantity_dp.
      ELSE.
        READ TABLE lt_salesplan INTO ls_salesplan
                                WITH KEY cycltype = ls_chk_2080-cycltype
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
*& Form GET_CAPA_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAINTAIN_PLAN
*&      --> LS_CHK_2090_MATNR
*&      --> LS_CHK_2090_IDNRK
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
*& Form GET_CAPAINFOR_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAINTAIN_PLAN
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
  DATA : lv_chk_date TYPE sy-datum.

  DATA : ls_main_data LIKE gs_main_data.

  DATA : lv_fieldname TYPE fieldname.
  FIELD-SYMBOLS : <lv_day_value> TYPE any.
  FIELD-SYMBOLS : <lv_month_value> TYPE any.
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
          CASE abap_true.
            WHEN p_rad1. " 일별 조회시

              __get_day_field ls_2091-pldat.
              CASE ls_2091-pltype.
                WHEN '01'. "생산  "check 필드 구분  U 기본 선속보다 많음, D 기본 선속보다 적음, N 정상
                  WRITE ls_2091-plmng TO <lv_day_value> UNIT gs_main_data-meins.
                  CONDENSE <lv_day_value>.

                WHEN '02'. "청소 "check 필드 구분 N
                  <lv_day_value> = '청소'.
                  <lv_day_chk> = 'C'.

                WHEN '03'. "비가동  "check 필드 구분 X
                  <lv_day_value> = ls_2091-nopnm.
                  <lv_day_chk> = 'X'.
              ENDCASE.
            WHEN p_rad2. " 월별조회시
              IF ls_2091-pltype = '01'.
                CLEAR lv_fieldname.
                lv_fieldname = ls_2091-pldat+0(6).
                IF <lv_month_value> IS ASSIGNED. UNASSIGN <lv_month_value>. ENDIF.
                ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main> TO <lv_month_value>.
                IF <lv_month_value> IS ASSIGNED.
                  <lv_month_value> = <lv_month_value> + ls_2091-plmng.
                ENDIF.
              ENDIF.
          ENDCASE.
        ENDLOOP.

        IF p_rad2 = abap_true. " 월별조회시 만들어진 수량 유닛적용하여 컨버전 적용
          LOOP AT gt_spmon INTO gs_spmon.
            CLEAR lv_fieldname.
            lv_fieldname = gs_spmon-spmon.
            IF <lv_month_value> IS ASSIGNED. UNASSIGN <lv_month_value>. ENDIF.
            ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_main> TO <lv_month_value>.
            IF <lv_month_value> IS ASSIGNED.
              CLEAR lv_plmng_move.
              lv_plmng_move = <lv_month_value>.
              WRITE lv_plmng_move TO <lv_month_value> UNIT gs_main_data-meins.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDLOOP.

* 데이터 존재시 추가정보 어팬드
      CASE abap_true.
        WHEN p_rad1.
*      합계 SUM_CHK = ''X'
          REFRESH lt_chk_date.
          CLEAR <ls_line>.
          CLEAR ls_main_data.
          ls_main_data-arbpl = gs_arbpl-arbpl.
          ls_main_data-seqno = gs_arbpl-seq.
          ls_main_data-spec = '합계'.

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


*      가동율 = ''X'
          CLEAR <ls_line>.
          CLEAR ls_main_data.
          ls_main_data-arbpl = gs_arbpl-arbpl.
          ls_main_data-seqno = gs_arbpl-seq.
          ls_main_data-spec = '부하율'.

          MOVE-CORRESPONDING ls_main_data TO <ls_line>.
          IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
          ASSIGN COMPONENT 'SUM_CHK' OF STRUCTURE <ls_line> TO <lv_value>.
          <lv_value> = 'Y'.

          CLEAR lv_chk_date.
          lv_chk_date = gv_bgn_dt.
          DO.
            __get_day_field_use_sum lv_chk_date.
            PERFORM cal_capa_per_day USING gs_arbpl-arbpl lv_chk_date CHANGING <lv_day_value>.

            ADD 1 TO lv_chk_date.
            IF lv_chk_date > gv_end_dt.
              EXIT.
            ENDIF.

          ENDDO.

          APPEND <ls_line> TO <gt_main_disp_100>.

        WHEN p_rad2.
*      합계 SUM_CHK = ''X'
          CLEAR <ls_line>.
          CLEAR ls_main_data.
          ls_main_data-arbpl = gs_arbpl-arbpl.
          ls_main_data-seqno = gs_arbpl-seq.
          ls_main_data-spec = '합계'.

          MOVE-CORRESPONDING ls_main_data TO <ls_line>.
          IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
          ASSIGN COMPONENT 'SUM_CHK' OF STRUCTURE <ls_line> TO <lv_value>.
          <lv_value> = abap_true.
* 수량 적용
          LOOP AT gt_2091 INTO ls_2091 WHERE arbpl = gs_arbpl-arbpl.
            CASE ls_2091-pltype.
              WHEN '01'.
                CLEAR lv_fieldname.
                lv_fieldname = ls_2091-pldat+0(6).
                IF <lv_month_value> IS ASSIGNED. UNASSIGN <lv_month_value>. ENDIF.
                ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_line> TO <lv_month_value>.
                <lv_month_value> = <lv_month_value> + ls_2091-plmng.
            ENDCASE.
          ENDLOOP.
* 단위 적용하여 수량 적용
          LOOP AT gt_spmon INTO gs_spmon.
            CLEAR lv_fieldname.
            lv_fieldname = gs_spmon-spmon.
            IF <lv_month_value> IS ASSIGNED. UNASSIGN <lv_month_value>. ENDIF.
            ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_line> TO <lv_month_value>.
            CONDENSE <lv_month_value>.
            lv_plmng_move = <lv_month_value>.
            WRITE lv_plmng_move TO <lv_month_value> UNIT gs_main_data-meins.
            CONDENSE <lv_month_value>.
          ENDLOOP.

          APPEND <ls_line> TO <gt_main_disp_100>.

*      비가동계획(일) SUM_CHK = 'Y''
          CLEAR <ls_line>.
          CLEAR ls_main_data.
          ls_main_data-arbpl = gs_arbpl-arbpl.
          ls_main_data-seqno = gs_arbpl-seq.
          ls_main_data-spec = '비가동계획(일) '.

          MOVE-CORRESPONDING ls_main_data TO <ls_line>.
          IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
          ASSIGN COMPONENT 'SUM_CHK' OF STRUCTURE <ls_line> TO <lv_value>.
          <lv_value> = 'Y'.

          CLEAR lv_chk_date.
          lv_chk_date = gv_bgn_dt.
          DO.

            LOOP AT gt_2091 INTO ls_2091 WHERE arbpl = gs_arbpl-arbpl
                                                              AND pldat = lv_chk_date
                                                              AND ( pltype = '02'
                                                               OR  pltype = '03' ).

              CLEAR lv_fieldname.
              lv_fieldname = ls_2091-pldat+0(6).
              IF <lv_month_value> IS ASSIGNED. UNASSIGN <lv_month_value>. ENDIF.
              ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_line> TO <lv_month_value>.
              <lv_month_value> = <lv_month_value> + 1.

              EXIT. " 한날자에 1만 더하기 가능
            ENDLOOP.

            ADD 1 TO lv_chk_date.
            IF lv_chk_date > gv_end_dt.
              EXIT.
            ENDIF.
          ENDDO.
          APPEND <ls_line> TO <gt_main_disp_100>.


*      가동율 SUM_CHK = 'Z''
          CLEAR <ls_line>.
          CLEAR ls_main_data.
          ls_main_data-arbpl = gs_arbpl-arbpl.
          ls_main_data-seqno = gs_arbpl-seq.
          ls_main_data-spec = '가동율 '.

          MOVE-CORRESPONDING ls_main_data TO <ls_line>.
          IF <lv_value> IS ASSIGNED. UNASSIGN <lv_value>. ENDIF.
          ASSIGN COMPONENT 'SUM_CHK' OF STRUCTURE <ls_line> TO <lv_value>.
          <lv_value> = 'Z'.

          LOOP AT gt_spmon INTO gs_spmon.
            CLEAR lv_fieldname.
            lv_fieldname = gs_spmon-spmon.
            IF <lv_month_value> IS ASSIGNED. UNASSIGN <lv_month_value>. ENDIF.
            ASSIGN COMPONENT lv_fieldname OF STRUCTURE <ls_line> TO <lv_month_value>.

            PERFORM cal_capa_per_month USING gs_arbpl-arbpl gs_spmon-spmon CHANGING <lv_month_value>.
            CONDENSE <lv_month_value>.
          ENDLOOP.

          APPEND <ls_line> TO <gt_main_disp_100>.

      ENDCASE.

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
*& Form CAL_CAPA_PER_DAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ARBPL_ARBPL
*&      --> LV_CHK_DATE
*&      <-- <LV_DAY_VALUE>
*&---------------------------------------------------------------------*
FORM cal_capa_per_day  USING    pv_arbpl TYPE arbpl
                                pv_data TYPE sy-datum
                       CHANGING pv_value.

  DATA : lv_rate TYPE p LENGTH 15 DECIMALS 5.
  DATA : lv_rate_sum TYPE p LENGTH 15 DECIMALS 5.
  DATA : lv_rate_tot TYPE p LENGTH 15 DECIMALS 5.
  DATA : lv_rate_tot_c TYPE c LENGTH 30.
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

  lv_rate_tot =  lv_rate_sum * 10000. " 소숫점 2자리 남기기 위해
  lv_rate_tot_c = lv_rate_tot.
  SPLIT lv_rate_tot_c AT '.' INTO DATA(lv_value) DATA(lv_dummy).
  CLEAR lv_rate_tot.
  lv_rate_tot = lv_value / 100.

  WRITE lv_rate_tot TO pv_value DECIMALS 2.

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
      rows    = 4
      columns = 1.

  go_splitter_0100->set_row_height(
    EXPORTING
      id                =    1              " Row ID
      height            =    10 ).             " Height

  go_splitter_0100->set_row_height(
    EXPORTING
      id                =    2              " Row ID
      height            =    42 ).             " Height

  go_splitter_0100->set_row_height(
    EXPORTING
      id                =    3              " Row ID
      height            =    6 ).             " Height

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

** top 컨테이너
  CALL METHOD go_splitter_0100->get_container
    EXPORTING
      row       = 3
      column    = 1
    RECEIVING
      container = go_contain_top_0101.

* bottom 컨테이너
  CALL METHOD go_splitter_0100->get_container
    EXPORTING
      row       = 4
      column    = 1
    RECEIVING
      container = go_contain_0101.



  CREATE OBJECT go_grid_0100
    EXPORTING
      i_parent      = go_contain_0100
      i_appl_events = abap_true.

  CREATE OBJECT go_grid_0101
    EXPORTING
      i_parent      = go_contain_0101
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
    WHEN go_grid_0101.
      SET HANDLER go_event_handler->handle_top_of_page          FOR po_grid.
  ENDCASE.

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
    IF <lv_sum_chk> IS NOT INITIAL. " 섬 필드 노란색으로 적용.
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
            OR 'MENGE' OR 'PLMNG' OR 'DAY_PLMNG'.
            CLEAR ls_celltab.
            ls_celltab-fieldname = <ls_fcat>-fieldname.
            ls_celltab-style = alv_style_color_int_key.
            INSERT ls_celltab INTO TABLE lt_celltab.
        ENDCASE.
      ENDLOOP.
      CASE abap_true.
        WHEN p_rad1.
          lv_chk_date = gv_bgn_dt.
          DO.
            IF lv_chk_date > gv_end_dt.
              EXIT.
            ENDIF.
            __get_day_field lv_chk_date.

            CASE <lv_day_chk>.
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
            ENDCASE.
            ADD 1 TO lv_chk_date.
          ENDDO.
      ENDCASE.
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
                cl_gui_alv_grid=>mc_mb_variant,
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

  IF go_dd_docu_top_0100 IS BOUND.
    CALL METHOD go_dd_docu_top_0100->initialize_document.
  ELSE.
    CREATE OBJECT go_dd_docu_top_0100
      EXPORTING
        style = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD go_grid_0100->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = go_dd_docu_top_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0101_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_grid_0101_display .

  CALL METHOD go_grid_0101->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout_0100
      it_toolbar_excluding = gt_exclude_0100
    CHANGING
      it_outtab            = <gt_main_disp_101>
      it_sort              = gt_sort_0100
      it_fieldcatalog      = gt_fieldcat_0100.

  IF go_dd_docu_top_0101 IS BOUND.
    CALL METHOD go_dd_docu_top_0101->initialize_document.
  ELSE.
    CREATE OBJECT go_dd_docu_top_0101
      EXPORTING
        style = 'ALV_GRID'.                 " Adjusting to the Style of a Particular GUI Environment
  ENDIF.

  CALL METHOD go_grid_0101->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = go_dd_docu_top_0101.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_attribute_grid_0101 .

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



  LOOP AT <gt_main_disp_101> ASSIGNING FIELD-SYMBOL(<ls_data>).
    REFRESH lt_celltab.

    IF <lv_sum_chk> IS ASSIGNED. UNASSIGN <lv_sum_chk>. ENDIF.
    ASSIGN COMPONENT 'SUM_CHK' OF STRUCTURE <ls_data> TO <lv_sum_chk>.
    IF <lv_sum_chk> IS NOT INITIAL. " 섬 필드 노란색으로 적용.
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
            OR 'MENGE' OR 'PLMNG' OR 'DAY_PLMNG'.
            CLEAR ls_celltab.
            ls_celltab-fieldname = <ls_fcat>-fieldname.
            ls_celltab-style = alv_style_color_int_key.
            INSERT ls_celltab INTO TABLE lt_celltab.
        ENDCASE.
      ENDLOOP.
      CASE abap_true.
        WHEN p_rad1.
          lv_chk_date = gv_bgn_dt.
          DO.
            IF lv_chk_date > gv_end_dt.
              EXIT.
            ENDIF.
            __get_day_field lv_chk_date.

            CASE <lv_day_chk>.
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
            ENDCASE.
            ADD 1 TO lv_chk_date.
          ENDDO.
      ENDCASE.
    ENDIF.

    IF <lt_celltab> IS ASSIGNED. UNASSIGN <lt_celltab>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <ls_data> TO <lt_celltab>.
    IF <lt_celltab> IS ASSIGNED.
      <lt_celltab> = lt_celltab.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_CAPA_PER_MONTH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ARBPL_ARBPL
*&      --> GS_SPMON_SPMON
*&      <-- <LV_MONTH_VALUE>
*&---------------------------------------------------------------------*
FORM cal_capa_per_month  USING    pv_arbpl TYPE arbpl
                                pv_spmon TYPE spmon
                       CHANGING pv_value.

  DATA : lv_rate TYPE p LENGTH 15 DECIMALS 5.
  DATA : lv_rate_sum TYPE p LENGTH 15 DECIMALS 5.
  DATA : lv_rate_month_sum TYPE p LENGTH 15 DECIMALS 5.
  DATA : lv_rate_tot TYPE p LENGTH 15 DECIMALS 5.
  DATA : lv_rate_tot_c TYPE c LENGTH 30.
  DATA : lv_plmng TYPE zgtppt2091-plmng.
  DATA : lv_tabix TYPE i.
  DATA : ls_2120 TYPE zgtppt2120.
  DATA : lv_month_gadong TYPE i.
  DATA : lv_end_dt TYPE sy-datum.
  DATA : lv_chk_dt TYPE sy-datum.

  lv_chk_dt = pv_spmon && '01'.
  lv_end_dt = lv_chk_dt.
  PERFORM get_last_day_of_month CHANGING lv_end_dt.

  DO.

    CLEAR lv_tabix.
    LOOP AT gt_2091 INTO DATA(ls_2091) WHERE arbpl = pv_arbpl
                                                    AND pldat = lv_chk_dt
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

    IF lv_tabix >= 1.
      ADD 1 TO lv_month_gadong.
      lv_rate_month_sum = lv_rate_sum.
    ELSE.
      READ TABLE gt_2091 TRANSPORTING NO FIELDS WITH KEY arbpl = pv_arbpl
                                                                                     pldat = lv_chk_dt
                                                                                     pltype = '03'.
      IF sy-subrc EQ 0. " 비가동 확인
      ELSE.
        READ TABLE gt_2091 TRANSPORTING NO FIELDS WITH KEY arbpl = pv_arbpl
                                                                                       pldat = lv_chk_dt
                                                                                       pltype = '02'.
        IF sy-subrc EQ 0. " 비가동 확인(청소)
        ELSE. " 가동일 이므로 가동일수 1더해준다. 비율은 0
          ADD 1 TO lv_month_gadong.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_chk_dt = lv_end_dt.
      EXIT.
    ENDIF.

    ADD 1 TO lv_chk_dt.

  ENDDO.

  IF lv_month_gadong NE 0.

    lv_rate_tot =  lv_rate_month_sum * 10000 / lv_month_gadong. " 소숫점 2자리 남기기 위해
    lv_rate_tot_c = lv_rate_tot.
    SPLIT lv_rate_tot_c AT '.' INTO DATA(lv_value) DATA(lv_dummy).
    CLEAR lv_rate_tot.
    lv_rate_tot = lv_value / 100.

    WRITE lv_rate_tot TO pv_value DECIMALS 2.
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


  IF p_simno IS INITIAL.
    MESSAGE s005 DISPLAY LIKE 'E' WITH '시뮬레이션번호(기준)'(e02) '는(은) 필수 필드입니다.'(e01).
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF p_simvr IS INITIAL.
    MESSAGE s005 DISPLAY LIKE 'E' WITH '시뮬레이션버전(기준)'(e03) '는(은) 필수 필드입니다.'(e01).
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF p_simno2 IS INITIAL.
    MESSAGE s005 DISPLAY LIKE 'E' WITH '시뮬레이션번호(비교)'(e04) '는(은) 필수 필드입니다.'(e01).
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF p_simvr2 IS INITIAL.
    MESSAGE s005 DISPLAY LIKE 'E' WITH '시뮬레이션버전(비교)'(e05) '는(은) 필수 필드입니다.'(e01).
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_screen .

*  LOOP AT SCREEN.
*
*    IF SCREEN-GROUP1 = 'M1'.
*      SCREEN-INPUT = 0.
*      SCREEN-INTENSIFIED = 1.
*      MODIFY SCREEN.
*    ENDIF.
*
*    IF SCREEN-GROUP1 = 'M2'.
*      SCREEN-INPUT = 0.
*      SCREEN-INTENSIFIED = 1.
*      MODIFY SCREEN.
*    ENDIF.
*
*    IF P_COLLED IS NOT INITIAL.
*      IF SCREEN-GROUP1 = 'A1'.
*        SCREEN-INPUT = 0.
*        SCREEN-INTENSIFIED = 0.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDIF.
*
*  ENDLOOP.

ENDFORM.
