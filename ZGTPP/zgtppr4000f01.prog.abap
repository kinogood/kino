*&---------------------------------------------------------------------*
*& Include          ZGTPPR4000F01
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
    IF p_r1 = gc_x.     "오더마감처리
      CASE screen-name.
        WHEN 'S_WERKS-LOW' OR 'S_GSTRP-LOW'.
          screen-required = 1.
          MODIFY SCREEN.
        WHEN 'P_C1'.
          screen-input = 0.
          MODIFY SCREEN.
      ENDCASE.

      IF screen-group1 = 'S2' OR screen-group1 = 'S3'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF p_r2 = gc_x.     "처리결과조회/취소
      CASE screen-name.
        WHEN 'S_WERKS-LOW' OR 'S_GSTRP-LOW' OR 'S_CRDAT-LOW'.
          screen-required = 1.
          MODIFY SCREEN.
      ENDCASE.

      IF screen-group1 = 'S1' OR screen-group1 = 'S4' OR screen-group1 = 'S3'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF p_r3 = gc_x.     "생산오더현황
      CASE screen-name.
        WHEN 'S_WERKS-LOW' OR 'S_GSTRP-LOW'.
          screen-required = 1.
          MODIFY SCREEN.
      ENDCASE.

      IF screen-group1 = 'S2' OR screen-group1 = 'S1'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ALV_VARIANT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_LAYO
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
*& Form SET_SCREEN_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_screen_value .

  DATA: lv_fdate LIKE sy-datum.

*-오더시작일자 세팅
  IF s_gstrp[] IS INITIAL.
    s_gstrp-sign = 'I'.
    s_gstrp-option = 'BT'.
    CONCATENATE sy-datum+0(6) '01' INTO s_gstrp-low.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = sy-datum
      IMPORTING
        last_day_of_month = s_gstrp-high
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.

    APPEND s_gstrp.
  ENDIF.

*-마감처리일자 세팅
  IF s_crdat[] IS INITIAL.
    s_crdat-sign   = 'I'.
    s_crdat-option = 'EQ'.
    s_crdat-low    = sy-datum.
    APPEND s_crdat.
  ENDIF.

*-마감 전기일자 세팅
  IF p_budat IS INITIAL.
    IF sy-datum+6(2) LE 15.
*-전월
      CLEAR: lv_fdate.
      CALL FUNCTION 'MONTH_PLUS_DETERMINE'
        EXPORTING
          months  = '-1'
          olddate = sy-datum
        IMPORTING
          newdate = lv_fdate.

*-전월의 마지막 일자
      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = lv_fdate
        IMPORTING
          last_day_of_month = p_budat
        EXCEPTIONS
          day_in_no_date    = 1
          OTHERS            = 2.

    ELSE.
      p_budat = sy-datum.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  IF p_r1 EQ gc_x.       "마감처리
    PERFORM get_data_close.
  ELSEIF p_r2 EQ gc_x.   "마감처리 조회 및 취소
    PERFORM get_data_revclose.
  ELSEIF p_r3 EQ gc_x.   "생산오더현황
    PERFORM get_data_aufnr.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_CLOSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_close .

  DATA: l_dyn(50).

  CLEAR: l_dyn.
  IF p_c1 EQ gc_x.  "PDLV만
    l_dyn = 'STAT EQ @GC_I0074'.
  ELSE.
    MESSAGE s003 DISPLAY LIKE gc_w
                 WITH TEXT-m13. "상태 선택을 체크하세요.
    STOP.
  ENDIF.

  CLEAR: gt_data.

  SELECT a~werks, a~aufnr, a~auart, a~objnr, a~zzorigin,
         a~zzfollowing AS zzfollow,
         b~gamng, b~igmng, b~gmein, b~gstrp, b~gltrp, b~gstri,
         c~matnr, c~wemng, c~kdauf, c~kdpos, c~lgort,
         d~mtart, d~matkl,
         e~zpjno, e~bstnk,
         f~name1,
         g~mtbez,
         h~wgbez,
         i~maktx,
         j~zptxt,
         k~zjob_name AS jobnm
    FROM            aufk       AS a
   INNER JOIN       afko       AS b ON b~aufnr EQ a~aufnr
   INNER JOIN       afpo       AS c ON c~aufnr EQ b~aufnr
   INNER JOIN       mara       AS d ON d~matnr EQ c~matnr
    LEFT OUTER JOIN vbak       AS e ON e~vbeln EQ c~kdauf
    LEFT OUTER JOIN t001w      AS f ON f~werks EQ a~werks
    LEFT OUTER JOIN t134t      AS g ON g~spras EQ @sy-langu
                                   AND g~mtart EQ d~mtart
    LEFT OUTER JOIN t023t      AS h ON h~spras EQ @sy-langu
                                   AND h~matkl EQ d~matkl
    LEFT OUTER JOIN makt       AS i ON i~matnr EQ c~matnr
                                   AND i~spras EQ @sy-langu
    LEFT OUTER JOIN zsd0106t   AS j ON j~zpjno EQ e~zpjno
    LEFT OUTER JOIN zgtedt2121 AS k ON k~zjob_no EQ e~bstnk
   WHERE a~werks IN @s_werks
     AND a~aufnr IN @s_aufnr
     AND a~auart IN @s_auart
     AND b~gstrp IN @s_gstrp
     AND b~gstri IN @s_gstri
     AND c~matnr IN @s_matnr
     AND d~mtart IN @s_mtart
     AND d~matkl IN @s_matkl
     AND c~kdauf IN @s_kdauf
     AND c~kdpos IN @s_kdpos
     AND e~zpjno IN @s_zpjno
     AND e~bstnk IN @s_bstnk
     AND a~zzfollowing IS INITIAL
     AND a~objnr IN ( SELECT objnr
                        FROM jest
                       WHERE (l_dyn)
                         AND inact NE @gc_x )
    INTO CORRESPONDING FIELDS OF TABLE @gt_data.

  CLEAR: gt_obottom.
  IF gt_data IS NOT INITIAL.
    SELECT a~aufnr,
           b~job_no, b~line_no, b~serial_info, b~prcss_seq, b~prcss_sub_seq,
           c~mtrl_seq, c~matnr, c~menge, c~kausf, "C~MEINS,
           d~sbdkz, d~rgekz,
           e~maktx,
           f~meins
      FROM      @gt_data   AS a
     INNER JOIN zgtppt3160 AS b ON b~aufnr EQ a~aufnr
     INNER JOIN zgtppt3170 AS c ON c~job_no        EQ b~job_no
                               AND c~line_no       EQ b~line_no
                               AND c~serial_info   EQ b~serial_info
                               AND c~prcss_seq     EQ b~prcss_seq
                               AND c~prcss_sub_seq EQ b~prcss_sub_seq
      LEFT OUTER JOIN marc AS d ON d~matnr         EQ c~matnr
                               AND d~werks         EQ a~werks
      LEFT OUTER JOIN makt AS e ON e~matnr         EQ c~matnr
                               AND e~spras         EQ @sy-langu
      LEFT OUTER JOIN mara AS f ON f~matnr         EQ c~matnr
      INTO CORRESPONDING FIELDS OF TABLE @gt_obottom.

    SELECT a~bstnk AS job_no,
           b~mblnr, b~mjahr, b~aufnr, b~bktxt, b~menge, b~meins
      FROM    @gt_data AS a
     INNER JOIN matdoc AS b ON b~aufnr EQ a~aufnr
                           AND b~record_type EQ @gc_mdoc
                           AND b~bwart EQ @gc_101
                           AND b~cancelled EQ @space
      INTO CORRESPONDING FIELDS OF TABLE @gt_aufnr_gr.
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
  IF p_r1 EQ gc_x.
    PERFORM modify_data_close.
  ELSEIF p_r2 EQ gc_x.
    PERFORM modify_data_revclose.
  ELSEIF p_r3 EQ gc_x.
    PERFORM modify_data_aufnr.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_CLOSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_data_close .

  DATA: BEGIN OF ls_stat,
          stat TYPE char100,
        END OF ls_stat,
        lt_stat LIKE TABLE OF ls_stat.

  DATA: l_weblnr TYPE weblnr,
        l_status TYPE char100.

  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_s>).
*-백로그상태
    CLEAR: l_weblnr.
    SELECT SINGLE weblnr
      INTO l_weblnr
      FROM affw
     WHERE aufnr EQ <fs_s>-aufnr.
    IF l_weblnr IS INITIAL.
      <fs_s>-back = icon_led_green.
    ELSE.
      <fs_s>-back = icon_led_red.
    ENDIF.

*-오더마감상태
    CLEAR: ls_stat, lt_stat, l_status.
    CALL FUNCTION 'ZGTPP_ORDER_STATUS'
      EXPORTING
        i_aufnr  = <fs_s>-aufnr
      IMPORTING
        e_status = l_status.

    SPLIT l_status AT '/' INTO TABLE lt_stat.

    IF line_exists( lt_stat[ stat = 'PDLV' ] ).
      <fs_s>-ord = icon_led_red.
    ELSE.
      IF line_exists( lt_stat[ stat = 'DLV' ] ).
        <fs_s>-ord = icon_led_green.
      ENDIF.
    ENDIF.

*-후속오더상태
    IF <fs_s>-zzfollow IS INITIAL.
      <fs_s>-ford = icon_led_red.
    ELSE.
      <fs_s>-ford = icon_led_green.
    ENDIF.

*-오더상태
    <fs_s>-ordstat = l_status.

*-생산잔량 = 생산오더수량 - 생산입고수량
    <fs_s>-remng = <fs_s>-gamng - <fs_s>-wemng.

*-출하완료여부
    SELECT SINGLE wbsta
      FROM lips
     WHERE vgbel EQ @<fs_s>-kdauf
       AND vgpos EQ @<fs_s>-kdpos
       AND fkrel NE @space
      INTO @<fs_s>-wbsta.

  ENDLOOP.

  LOOP AT gt_aufnr_gr ASSIGNING FIELD-SYMBOL(<fs_gr>).
    IF <fs_gr>-bktxt IS NOT INITIAL.
      SPLIT <fs_gr>-bktxt AT ',' INTO:  <fs_gr>-line_no <fs_gr>-serial_info.
    ENDIF.
  ENDLOOP.

  SORT gt_aufnr_gr BY job_no line_no serial_info.

  LOOP AT gt_obottom ASSIGNING FIELD-SYMBOL(<fs_b>).
    READ TABLE gt_aufnr_gr INTO DATA(ls_gr) WITH KEY job_no = <fs_b>-job_no
                                                     line_no = <fs_b>-line_no
                                                     serial_info = <fs_b>-serial_info.
    IF sy-subrc EQ 0.
      <fs_b>-del = gc_x.
    ENDIF.
  ENDLOOP.

  DELETE gt_obottom WHERE del EQ gc_x.

  SORT gt_obottom BY job_no line_no serial_info prcss_seq prcss_sub_seq.

  LOOP AT gt_obottom ASSIGNING <fs_b>.
    <fs_b>-comp_qty = <fs_b>-menge * ( 1 + ( <fs_b>-kausf / 100 ) ).
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLS_OBJT_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM cls_objt_rtn .
  CLEAR: gt_fieldcat_0100[], gs_layout_0100, gt_exclude_0100[],
         gt_exclude_0100,
         gt_fieldcat_0101[], gs_layout_0101, gt_exclude_0101[],
         gt_exclude_0101, gv_ok_code, gv_dbcnt,
         gt_data[], gt_revdata[], gt_bottom[].

  CALL METHOD go_docking_container->free.
  CLEAR : go_docking_container, go_grid_0100, go_grid_0101.
  CALL METHOD cl_gui_cfw=>flush.
  LEAVE TO SCREEN 0.
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
  CREATE OBJECT go_docking_container
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

  IF p_r1 EQ gc_x.
*화면 분할
    CREATE OBJECT go_splitter
      EXPORTING
        parent  = go_docking_container
        rows    = 2
        columns = 1.
* top 컨테이너
    CALL METHOD go_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = go_contain_0100.
* bottom 컨테이너
    CALL METHOD go_splitter->get_container
      EXPORTING
        row       = 2
        column    = 1
      RECEIVING
        container = go_contain_0101.

    CREATE OBJECT go_grid_0100
      EXPORTING
        i_parent      = go_contain_0100
        i_appl_events = abap_true.

  ELSE.
    CREATE OBJECT go_grid_0100
      EXPORTING
        i_parent      = go_docking_container
        i_appl_events = abap_true.
  ENDIF.

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
  gs_layout_0100-zebra      = gc_x.
  gs_layout_0100-col_opt    = gc_x.
  gs_layout_0100-cwidth_opt = gc_x.
  gs_layout_0100-no_rowins  = gc_x.
  gs_layout_0100-sel_mode   = gc_d.
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
  IF p_r1 EQ gc_x.     "오더마감처리
    PERFORM set_fieldcat_close.
  ELSEIF p_r2 EQ gc_x. "처리결과조회/취소
    PERFORM set_fieldcat_revclose.
  ELSEIF p_r3 EQ gc_x. "생산오더 현황
    PERFORM set_fieldcat_aufnr.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_CLOSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_close .

  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR4000TOP'
      i_internal_tabname     = 'GS_DATA'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0100[]
    TABLES
      it_data         = gt_data
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT gt_fieldcat_0100 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE <ls_fcat>-fieldname.
      WHEN 'BACK'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f01. "백로그상태
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
        <ls_fcat>-icon = gc_x.
      WHEN 'ORD'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f02. "오더마감상태
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
        <ls_fcat>-icon = gc_x.
      WHEN 'FORD'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f03. "후속오더상태
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
        <ls_fcat>-icon = gc_x.
      WHEN 'ZZFOLLOW'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f04. "후속 생산오더번호
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
        <ls_fcat>-convexit = 'ALPHA'.
      WHEN 'RTMSG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f05. "처리 메세지
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_l.
      WHEN 'AUFNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f06. "생산오더번호
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
      WHEN 'ORDSTAT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f07. "생산오더상태
        <ls_fcat>-just = gc_l.
      WHEN 'WERKS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f08. "플랜트
        <ls_fcat>-just = gc_c.
      WHEN 'NAME1'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f09. "플랜트 내역
        <ls_fcat>-just = gc_l.
      WHEN 'MTART'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f10. "자재유형
        <ls_fcat>-just = gc_c.
      WHEN 'MTBEZ'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f11. "자재유형 내역
        <ls_fcat>-just = gc_l.
      WHEN 'AUART'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f12. "생산오더유형
        <ls_fcat>-just = gc_c.
      WHEN 'MATKL'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f13. "자재그룹
        <ls_fcat>-just = gc_c.
      WHEN 'WGBEZ'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f14. "자재그룹 내역
        <ls_fcat>-just = gc_l.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f15. "품목코드
        <ls_fcat>-just = gc_c.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f16. "품목내역
        <ls_fcat>-just = gc_l.
      WHEN 'GAMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f17. "생산오더수량
        <ls_fcat>-just = gc_r.
      WHEN 'WEMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f18. "생산입고수량
        <ls_fcat>-just = gc_r.
        <ls_fcat>-qfieldname = 'GMEIN'.
      WHEN 'IGMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f19. "생산확정수량
        <ls_fcat>-just = gc_r.
      WHEN 'REMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f20. "생산잔량
        <ls_fcat>-just = gc_r.
      WHEN 'GMEIN'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f21. "생산단위
        <ls_fcat>-just = gc_c.
      WHEN 'ZPJNO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f22. "프로젝트번호
        <ls_fcat>-just = gc_c.
      WHEN 'ZPTXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f23. "프로젝트내역
        <ls_fcat>-just = gc_l.
      WHEN 'BSTNK'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f24. "제조지시번호
        <ls_fcat>-just = gc_c.
      WHEN 'JOBNM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f25. "제조지시내역
        <ls_fcat>-just = gc_l.
      WHEN 'KDAUF'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f26. "판매오더번호
        <ls_fcat>-just = gc_c.
      WHEN 'KDPOS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f27. "판매오더품목
        <ls_fcat>-just = gc_c.
      WHEN 'GSTRP'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f28. "오더시작일
        <ls_fcat>-just = gc_c.
      WHEN 'GLTRP'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f29. "오더종료일
        <ls_fcat>-just = gc_c.
      WHEN 'WBSTA'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f47. "출하완료여부
        <ls_fcat>-just = gc_c.
      WHEN 'GSTRI'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f48. "실제시작일
        <ls_fcat>-just = gc_c.
      WHEN OTHERS.
        <ls_fcat>-no_out = gc_x.
    ENDCASE.

    IF <ls_fcat>-fieldname = 'BACK'  OR <ls_fcat>-fieldname = 'ORD' OR
       <ls_fcat>-fieldname = 'FORD'  OR <ls_fcat>-fieldname = 'ZZFOLLOW' OR
       <ls_fcat>-fieldname = 'RTMSG' OR <ls_fcat>-fieldname = 'AUFNR'.

    ELSE.
      CLEAR: <ls_fcat>-key.
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
*& Form ADD_EXCLUDE_TOOLBAR_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_EXCLUDE_0100
*&      --> CL_GUI_ALV_GRID=>MC_FC_LOC_UND
*&---------------------------------------------------------------------*
FORM add_exclude_toolbar_button  TABLES   p_table
                                 USING    p_value.
  DATA: l_exclude TYPE ui_func.
  l_exclude = p_value.
  APPEND l_exclude TO p_table.

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

  IF p_r1 EQ gc_x.       "오더마감처리
    CALL METHOD go_grid_0100->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_0100
        it_toolbar_excluding = gt_exclude_0100
        is_variant           = gs_variant
        i_save               = gc_x
      CHANGING
        it_outtab            = gt_data
        it_fieldcatalog      = gt_fieldcat_0100.

  ELSEIF p_r2 EQ gc_x.   "처리결과조회/취소
    CALL METHOD go_grid_0100->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_0100
        it_toolbar_excluding = gt_exclude_0100
        is_variant           = gs_variant
        i_save               = gc_x
      CHANGING
        it_outtab            = gt_revdata
        it_fieldcatalog      = gt_fieldcat_0100.

  ELSEIF p_r3 EQ gc_x.   "생산오더현황
    CALL METHOD go_grid_0100->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_0100
        it_toolbar_excluding = gt_exclude_0100
        is_variant           = gs_variant
        i_save               = gc_x
      CHANGING
        it_outtab            = gt_aufnr
        it_fieldcatalog      = gt_fieldcat_0100.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_REVCLOSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_revclose .

  CLEAR: gt_revdata.

  SELECT a~zzorigin, a~zzfollowing AS zzfollow,
         a~gamng, a~wemng, a~igmng, a~remng, a~gmein,
         a~crdat, a~crtim, a~crnam,
         b~werks, b~aufnr, b~auart,
         c~gstrp, c~gltrp, c~gstri,
         d~matnr, d~kdauf, d~kdpos,
         e~mtart, e~matkl,
         f~zpjno, f~bstnk,
         g~name1,
         h~mtbez,
         i~wgbez,
         j~maktx,
         k~zptxt,
         l~zjob_name AS jobnm
    FROM            zgtppt4000 AS a
   INNER JOIN       aufk       AS b ON b~aufnr EQ a~zzorigin
   INNER JOIN       afko       AS c ON c~aufnr EQ b~aufnr
   INNER JOIN       afpo       AS d ON d~aufnr EQ c~aufnr
   INNER JOIN       mara       AS e ON e~matnr EQ d~matnr
    LEFT OUTER JOIN vbak       AS f ON f~vbeln EQ d~kdauf
    LEFT OUTER JOIN t001w      AS g ON g~werks EQ b~werks
    LEFT OUTER JOIN t134t      AS h ON h~spras EQ @sy-langu
                                   AND h~mtart EQ e~mtart
    LEFT OUTER JOIN t023t      AS i ON i~spras EQ @sy-langu
                                   AND i~matkl EQ e~matkl
    LEFT OUTER JOIN makt       AS j ON j~matnr EQ d~matnr
                                   AND j~spras EQ @sy-langu
    LEFT OUTER JOIN zsd0106t   AS k ON k~zpjno EQ f~zpjno
    LEFT OUTER JOIN zgtedt2121 AS l ON l~zjob_no EQ f~bstnk
   WHERE b~werks       IN @s_werks
     AND a~zzorigin    IN @s_origin
     AND a~zzfollowing IN @s_follow
     AND b~auart       IN @s_auart
     AND c~gstrp       IN @s_gstrp
     AND c~gstri       IN @s_gstri
     AND d~matnr       IN @s_matnr
     AND e~mtart       IN @s_mtart
     AND e~matkl       IN @s_matkl
     AND a~crdat       IN @s_crdat
     AND d~kdauf       IN @s_kdauf
     AND d~kdpos       IN @s_kdpos
     AND f~zpjno       IN @s_zpjno
     AND f~bstnk       IN @s_bstnk
    INTO CORRESPONDING FIELDS OF TABLE @gt_revdata.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_REVCLOSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_data_revclose .

  DATA: BEGIN OF ls_stat,
          stat TYPE char100,
        END OF ls_stat,
        lt_stat LIKE TABLE OF ls_stat.

  DATA: l_weblnr TYPE weblnr,
        l_status TYPE char100.

  LOOP AT gt_revdata ASSIGNING FIELD-SYMBOL(<fs_s>).
*-백로그상태
    CLEAR: l_weblnr.
    SELECT SINGLE weblnr
      INTO l_weblnr
      FROM affw
     WHERE aufnr EQ <fs_s>-zzorigin.
    IF l_weblnr IS INITIAL.
      <fs_s>-back = icon_led_green.
    ELSE.
      <fs_s>-back = icon_led_red.
    ENDIF.

*-오더마감상태
    CLEAR: ls_stat, lt_stat, l_status.
    CALL FUNCTION 'ZGTPP_ORDER_STATUS'
      EXPORTING
        i_aufnr  = <fs_s>-zzorigin
      IMPORTING
        e_status = l_status.

    SPLIT l_status AT '/' INTO TABLE lt_stat.

    IF line_exists( lt_stat[ stat = 'PDLV' ] ).
      <fs_s>-ord = icon_led_red.
    ELSE.
      IF line_exists( lt_stat[ stat = 'DLV' ] ).
        <fs_s>-ord = icon_led_green.
      ENDIF.
    ENDIF.

*-후속오더상태
    IF <fs_s>-zzfollow IS INITIAL.
      <fs_s>-ford = icon_led_red.
    ELSE.
      <fs_s>-ford = icon_led_green.
    ENDIF.

*-오더상태
    <fs_s>-ordstat = l_status.

*-출하완료여부
    SELECT SINGLE wbsta
      FROM lips
     WHERE vgbel EQ @<fs_s>-kdauf
       AND vgpos EQ @<fs_s>-kdpos
       AND fkrel NE @space
      INTO @<fs_s>-wbsta.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_REVCLOSE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_revclose .
  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR4000TOP'
      i_internal_tabname     = 'GS_REVDATA'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0100[]
    TABLES
      it_data         = gt_revdata
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT gt_fieldcat_0100 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE <ls_fcat>-fieldname.
      WHEN 'BACK'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f01. "백로그상태
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
        <ls_fcat>-icon = gc_x.
      WHEN 'FORD'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f03. "후속오더상태
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
        <ls_fcat>-icon = gc_x.
      WHEN 'ORD'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f02. "오더마감상태
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
        <ls_fcat>-icon = gc_x.
      WHEN 'ZZFOLLOW'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f04. "후속 생산오더번호
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
        <ls_fcat>-convexit = 'ALPHA'.
      WHEN 'RTMSG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f05. "처리 메세지
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_l.
      WHEN 'ZZORIGIN'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f06. "생산오더번호
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
        <ls_fcat>-convexit = 'ALPHA'.
      WHEN 'ORDSTAT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f07. "생산오더상태
        <ls_fcat>-just = gc_l.
      WHEN 'WERKS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f08. "플랜트
        <ls_fcat>-just = gc_c.
      WHEN 'NAME1'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f09. "플랜트 내역
        <ls_fcat>-just = gc_l.
      WHEN 'MTART'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f10. "자재유형
        <ls_fcat>-just = gc_c.
      WHEN 'MTBEZ'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f11. "자재유형 내역
        <ls_fcat>-just = gc_l.
      WHEN 'AUART'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f12. "생산오더유형
        <ls_fcat>-just = gc_c.
      WHEN 'MATKL'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f13. "자재그룹
        <ls_fcat>-just = gc_c.
      WHEN 'WGBEZ'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f14. "자재그룹 내역
        <ls_fcat>-just = gc_l.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f15. "품목코드
        <ls_fcat>-just = gc_c.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f16. "품목내역
        <ls_fcat>-just = gc_l.
      WHEN 'GAMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f17. "생산오더수량
        <ls_fcat>-just = gc_r.
      WHEN 'WEMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f18. "생산입고수량
        <ls_fcat>-just = gc_r.
        <ls_fcat>-qfieldname = 'GMEIN'.
      WHEN 'IGMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f19. "생산확정수량
        <ls_fcat>-just = gc_r.
      WHEN 'REMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f20. "생산잔량
        <ls_fcat>-just = gc_r.
      WHEN 'GMEIN'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f21. "생산단위
        <ls_fcat>-just = gc_c.
      WHEN 'ZPJNO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f22. "프로젝트번호
        <ls_fcat>-just = gc_c.
      WHEN 'ZPTXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f23. "프로젝트내역
        <ls_fcat>-just = gc_l.
      WHEN 'BSTNK'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f24. "제조지시번호
        <ls_fcat>-just = gc_c.
      WHEN 'JOBNM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f25. "제조지시내역
        <ls_fcat>-just = gc_l.
      WHEN 'KDAUF'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f26. "판매오더번호
        <ls_fcat>-just = gc_c.
      WHEN 'KDPOS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f27. "판매오더품목
        <ls_fcat>-just = gc_c.
      WHEN 'GSTRP'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f28. "오더시작일
        <ls_fcat>-just = gc_c.
      WHEN 'GLTRP'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f29. "오더종료일
        <ls_fcat>-just = gc_c.
      WHEN 'WBSTA'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f47. "출하완료여부
        <ls_fcat>-just = gc_c.
      WHEN 'CRDAT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f30. "처리일자
        <ls_fcat>-just = gc_c.
      WHEN 'CRTIM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f31. "처리시간
        <ls_fcat>-just = gc_c.
      WHEN 'CRNAM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f32. "처리자
        <ls_fcat>-just = gc_c.
      WHEN 'GSTRI'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f48. "실제시작일
        <ls_fcat>-just = gc_c.
      WHEN OTHERS.
        <ls_fcat>-no_out = gc_x.
    ENDCASE.

    IF <ls_fcat>-fieldname = 'BACK'  OR <ls_fcat>-fieldname = 'ORD' OR
       <ls_fcat>-fieldname = 'FORD'  OR <ls_fcat>-fieldname = 'ZZFOLLOW' OR
       <ls_fcat>-fieldname = 'RTMSG' OR <ls_fcat>-fieldname = 'ZZORIGIN'.

    ELSE.
      CLEAR: <ls_fcat>-key.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ORD_DLV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_ord_dlv .

  DATA: lt_row_no TYPE lvc_t_roid WITH HEADER LINE,
        l_answer  TYPE char01.

  FIELD-SYMBOLS: <fs_s> LIKE gs_data.

  CLEAR: l_answer.

  PERFORM sel_row_rtn TABLES lt_row_no
                      USING  go_grid_0100.

  IF lt_row_no[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'W'
       WITH TEXT-m01. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = TEXT-t05 "오더 마감 처리
      text_question         = TEXT-t06 "오더 마감 처리를 수행하시겠습니까?
      display_cancel_button = space
    IMPORTING
      answer                = l_answer.

  IF l_answer = '1'.
    LOOP AT lt_row_no.
      READ TABLE gt_data ASSIGNING <fs_s> INDEX lt_row_no-row_id.

      IF <fs_s>-back NE icon_led_green.
        <fs_s>-rtmsg = TEXT-m02. "백로그가 남아 있어 오더 마감이 불가합니다.
      ELSEIF <fs_s>-back EQ icon_led_green.
        IF <fs_s>-ord NE icon_led_red.
          <fs_s>-rtmsg = TEXT-m03. "이미 DLV 처리된 생산오더입니다.
        ELSEIF <fs_s>-ord EQ icon_led_red.
          IF <fs_s>-wemng NE <fs_s>-igmng.
            <fs_s>-rtmsg = TEXT-m04. "오더입고수량과 오더확정수량이 서로 다릅니다.
          ELSEIF <fs_s>-wemng EQ <fs_s>-igmng.
            PERFORM exec_ord_dlv USING <fs_s>.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM ref_alv_rtn USING go_grid_0100..

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEL_ROW_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_NO
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM sel_row_rtn  TABLES pt_row_no TYPE lvc_t_roid
                  USING  pr_alv TYPE REF TO cl_gui_alv_grid.

  DATA: lt_index_rows TYPE lvc_t_row,
        lt_row_no     TYPE lvc_t_roid.

*--------------------------------------------------------------------*

  CLEAR: lt_index_rows, lt_index_rows[],
         lt_row_no, lt_row_no[].

  pr_alv->get_selected_rows(
    IMPORTING
      et_index_rows = lt_index_rows
      et_row_no     = lt_row_no ).

  pt_row_no[] = lt_row_no[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REF_ALV_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ref_alv_rtn USING    po_grid TYPE REF TO cl_gui_alv_grid.
  DATA ls_stable TYPE lvc_s_stbl.

  ls_stable-row = 'X'.
  ls_stable-col = 'X'.

  CASE po_grid.
    WHEN go_grid_0100.
      CALL METHOD po_grid->set_frontend_layout
        EXPORTING
          is_layout = gs_layout_0100.
    WHEN go_grid_0101.
      CALL METHOD po_grid->set_frontend_layout
        EXPORTING
          is_layout = gs_layout_0101.
  ENDCASE.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = ls_stable
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_variant_grid_0100 .

  IF p_layo IS NOT INITIAL.
    gs_variant-variant = p_layo.
  ENDIF.
  gs_variant-report = sy-repid.
  gs_variant-username = sy-uname.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_ORD_DLV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM exec_ord_dlv  USING    p_line LIKE gs_data.

  CLEAR: gv_chk, gv_lgortchk.

*-배치 관리 여부
  CLEAR: gv_xchpf.
  SELECT SINGLE xchpf
    FROM mara
   WHERE matnr EQ @p_line-matnr
    INTO @gv_xchpf.

  IF gv_xchpf IS NOT INITIAL.
*-배치 존재여부
    CLEAR: gv_charg.
    SELECT SINGLE charg
      FROM mcha
     WHERE matnr EQ @p_line-matnr
       AND werks EQ @p_line-werks
       AND charg EQ @gc_gr_zero1
      INTO @gv_charg.

    IF sy-subrc NE 0.
*-저장위치 존재여부
      SELECT SINGLE lgort
        FROM mard
       WHERE matnr EQ @p_line-matnr
         AND lgort EQ @p_line-lgort
        INTO @DATA(lv_lgort).

      IF lv_lgort IS INITIAL.
*-저장위치 확장
        PERFORM bapi_lgort_create USING p_line.
      ELSE.
        gv_lgortchk = gc_x.
      ENDIF.

*-배치 생성(GR_ZERO1)
      IF gv_lgortchk EQ gc_x.
        PERFORM bapi_batch_create USING p_line.
      ENDIF.
    ENDIF.

    IF gv_charg IS NOT INITIAL.
      CALL FUNCTION 'DEQUEUE_EMMARCE'
        EXPORTING
          matnr = p_line-matnr
          werks = p_line-werks.

*-ZERO 입고 및 DLV 처리
      PERFORM bapi_zero_goodsmvt_create USING p_line.
    ENDIF.

  ELSE.
    PERFORM bapi_zero_goodsmvt_create USING p_line.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DYNPRO1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM dynpro1  USING dynbegin name value.
  CLEAR bdcdata.
  IF dynbegin = 'X'.
    MOVE: name  TO bdcdata-program,
          value TO bdcdata-dynpro,
          'X'   TO bdcdata-dynbegin.
    APPEND bdcdata.
  ELSE.
    MOVE: name  TO bdcdata-fnam,
          value TO bdcdata-fval.
    APPEND bdcdata.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTPPT4000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&      --> P_
*&---------------------------------------------------------------------*
FORM save_zgtppt4000  USING    p_line LIKE gs_data
                               pv_gbn.

  DATA: ls_zgtppt4000  LIKE zgtppt4000,
        ls_zgtppt4000s LIKE zgtppt4000.

  CLEAR: ls_zgtppt4000.

  IF pv_gbn EQ 'A'.
    ls_zgtppt4000 = VALUE #( BASE CORRESPONDING #( p_line )
                               zzorigin    = p_line-aufnr
                               zzdlv       = gc_x
                               zzfollowing = space
                               crdat       = sy-datum
                               crtim       = sy-uzeit
                               crnam       = sy-uname ).

    MODIFY zgtppt4000 FROM ls_zgtppt4000.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ENDIF.

  ELSEIF pv_gbn EQ 'B'.
    CLEAR: ls_zgtppt4000s.
    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF ls_zgtppt4000s
      FROM zgtppt4000
     WHERE zzorigin EQ p_line-aufnr.

    IF ls_zgtppt4000s IS NOT INITIAL.
      ls_zgtppt4000 = VALUE #( BASE CORRESPONDING #( ls_zgtppt4000s )
*                                 ZZORIGIN = P_LINE-AUFNR
*                                 ZZDLV    = GC_X
                                 zzfollowing = p_line-zzfollow
                                 crdat       = sy-datum
                                 crtim       = sy-uzeit
                                 crnam       = sy-uname ).

      MODIFY zgtppt4000 FROM ls_zgtppt4000.
*      IF SY-SUBRC EQ 0.
*        COMMIT WORK.
*      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_FORD_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_ford_create .

  DATA: lt_row_no TYPE lvc_t_roid WITH HEADER LINE,
        l_answer  TYPE char01.

  FIELD-SYMBOLS: <fs_s> LIKE gs_data.

  CLEAR: l_answer.

  PERFORM sel_row_rtn TABLES lt_row_no
                      USING  go_grid_0100.

  IF lt_row_no[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'W'
       WITH TEXT-m01. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = TEXT-t07 "후속 생산오더 생성
      text_question         = TEXT-t08 "후속 생산오더를 생성하시겠습니까?
      display_cancel_button = space
    IMPORTING
      answer                = l_answer.

  IF l_answer = '1'.
    CLEAR: gt_aufnr_send.
    LOOP AT lt_row_no.
      READ TABLE gt_data ASSIGNING <fs_s> INDEX lt_row_no-row_id.

      IF <fs_s>-back NE icon_led_green.
        <fs_s>-rtmsg = TEXT-m06. "백로그가 남아 있어 진행이 불가합니다.
      ELSEIF <fs_s>-back EQ icon_led_green.
        IF <fs_s>-ord NE icon_led_green.
          <fs_s>-rtmsg = TEXT-m07. "오더 마감 처리 후 후속 생산오더 생성이 가능합니다.
        ELSEIF <fs_s>-ord EQ icon_led_green.
          IF <fs_s>-zzfollow IS NOT INITIAL.
            <fs_s>-rtmsg = TEXT-m14. "이미 후속 생산오더번호가 존재합니다.
          ELSE.
            IF <fs_s>-wemng NE <fs_s>-igmng.
              <fs_s>-rtmsg = TEXT-m04. "오더입고수량과 오더확정수량이 서로 다릅니다.
            ELSEIF <fs_s>-wemng EQ <fs_s>-igmng.
              PERFORM exec_ford_create USING <fs_s>.
              IF <fs_s>-zzfollow IS NOT INITIAL.
                PERFORM exec_item_create USING <fs_s>.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

*-생산오더 송신
    IF gt_aufnr_send IS NOT INITIAL.
      PERFORM submit_zgtppi2010.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM ref_alv_rtn USING go_grid_0100.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_FORD_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM exec_ford_create  USING    p_line LIKE gs_data.

  DATA: lt_prd_orders TYPE tb_bapi_order_key.
  DATA: ls_order TYPE bapi_pp_order_create.
  DATA: ls_return TYPE bapiret2.
  DATA: lv_order_number TYPE bapi_order_key-order_number.

  DATA: l_gstrp LIKE afko-gstrp,           "후속오더 시작일
        l_gltrp LIKE afko-gltrp.           "후속오더 종료일
  DATA: l_date  TYPE sy-datum.

  CLEAR: l_gstrp, l_gltrp.
*-기존 생산오더 시작일의 월 <= 현재일의 월
  IF p_line-gstrp+0(6) LE sy-datum+0(6).
*-후속 생산오더 시작일 = 기존 생산오더 시작일 월의 차월 1일
    CLEAR: l_date.
    l_date = p_line-gstrp+0(6) && |01|.

    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        date      = l_date
        days      = '00'
        months    = '01'
        signum    = '+'
        years     = '00'
      IMPORTING
        calc_date = l_gstrp.
  ENDIF.

*-기존 생산오더 종료일 >= 후속 생산오더 시작일
  IF p_line-gltrp GE l_gstrp.
*-후속 생산오더 종료일은 기존 생산오더 종료일
    l_gltrp = p_line-gltrp.
*-기존 생산오더 종료일 < 후속 생산오더 시작일
  ELSEIF p_line-gltrp LT l_gstrp.
*-후속 생산오더 종료일은 후속 생산오더 시작일
    l_gltrp = l_gstrp.
  ENDIF.

  CLEAR: ls_order, ls_return, lv_order_number.
*-오더 생성
  ls_order-material              = p_line-matnr.
  ls_order-plant                 = p_line-werks.
  ls_order-order_type            = p_line-auart.
  ls_order-basic_start_date      = l_gstrp.
  ls_order-basic_start_time      = '000000'.
  ls_order-basic_end_date        = l_gltrp.
  ls_order-basic_end_time        = '000000'.
  ls_order-quantity              = p_line-remng.
  ls_order-quantity_uom          = p_line-gmein.
  ls_order-prod_version          = gc_0010.
  ls_order-sales_order           = p_line-kdauf.
  ls_order-sales_order_item      = p_line-kdpos.
  ls_order-basic_scheduling_type = '3'.

  CALL FUNCTION 'BAPI_PRODORD_CREATE'
    EXPORTING
      orderdata    = ls_order
    IMPORTING
      return       = ls_return
      order_number = lv_order_number.

  IF ls_return-type NE gc_e.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.

* 커밋진행후 테이블 업로드 시간 대기, 테이블 조회후 값이 있으면 이후 진행
    DO .
      SELECT SINGLE aufnr, posnr
        FROM afpo
       WHERE aufnr = @lv_order_number
        INTO @DATA(ls_afpo).
      IF sy-subrc EQ 0.
        EXIT.
      ELSE.
        WAIT UP TO '0.5' SECONDS.
      ENDIF.
    ENDDO.

    p_line-zzfollow = lv_order_number.

  ELSE.
    p_line-ford = icon_led_red.
    p_line-rtmsg = ls_return-message.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_FORD_DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_ford_delete .

  DATA: lt_row_no TYPE lvc_t_roid WITH HEADER LINE,
        l_answer  TYPE char01.

  FIELD-SYMBOLS: <fs_s> LIKE gs_revdata.

  CLEAR: l_answer.

  PERFORM sel_row_rtn TABLES lt_row_no
                      USING  go_grid_0100.

  IF lt_row_no[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'W'
       WITH TEXT-m01. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = TEXT-t09 "후속 생산오더 삭제 설정
      text_question         = TEXT-t10 "후속 생산오더를 삭제 설정하시겠습니까?
      display_cancel_button = space
    IMPORTING
      answer                = l_answer.

  IF l_answer = '1'.
    CLEAR: gt_aufnr_send.
    LOOP AT lt_row_no.
      READ TABLE gt_revdata ASSIGNING <fs_s> INDEX lt_row_no-row_id.

      IF <fs_s>-zzfollow IS INITIAL.
        <fs_s>-rtmsg = TEXT-m09. "후속 생산오더가 이미 삭제 처리되었습니다.
      ELSE.
        PERFORM exec_ford_delete USING <fs_s>.  "TECO 설정
      ENDIF.
    ENDLOOP.

*-생산오더 송신
    IF gt_aufnr_send IS NOT INITIAL.
      PERFORM submit_zgtppi2010.
    ENDIF.

    " REFRESH DISPLAY
    PERFORM ref_alv_rtn USING go_grid_0100.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_FORD_DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM exec_ford_delete  USING    p_line LIKE gs_revdata.

  CLEAR: bdcdata, bdcdata[], messtab, messtab[],
         gv_text.

  PERFORM dynpro1 USING:
        'X' 'SAPLCOKO1'   '0110',
        ' ' 'BDC_OKCODE'  '=ENTK',
        ' ' 'CAUFVD-AUFNR' p_line-zzfollow.
*        ' ' 'R62CLORD-FLG_OVIEW' GC_X.

  PERFORM dynpro1 USING:
        'X' 'SAPLCOKO1'   '0115',
        ' ' 'BDC_OKCODE'  '=TABS'.

  PERFORM dynpro1 USING:
        'X' 'SAPLCOKO1'   '0115',
        ' ' 'BDC_OKCODE'  '=BU'.

  gs_params-dismode  = 'N'.   " 처리모드
  gs_params-updmode  = 'S'.   " 갱신세션
  gs_params-cattmode = 'A'.   " CATT모드
  gs_params-defsize  = ' '.   " 기본화면
  gs_params-racommit = 'X'.   " COMMIT 이후 지속
  gs_params-nobinpt  = 'X'.   " BI 세션

  CALL TRANSACTION 'CO02'
             USING bdcdata
           OPTIONS FROM gs_params
          MESSAGES INTO messtab.

  READ TABLE messtab INDEX 1.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      msgid               = messtab-msgid
      msgnr               = messtab-msgnr
      msgv1               = messtab-msgv1
      msgv2               = messtab-msgv2
      msgv3               = messtab-msgv3
      msgv4               = messtab-msgv4
    IMPORTING
      message_text_output = gv_text.

  IF messtab-msgtyp <> gc_s.
    p_line-rtmsg = gv_text.
  ELSE.
    p_line-ford  = icon_led_red.
    p_line-rtmsg = TEXT-m10. "후속 생산오더 삭제를 성공하였습니다.

*-전송할 생산오더
    app_aufnr: p_line-zzfollow.

*-기존 생산오더에 후속 생산오더 CLEAR 업데이트
    UPDATE aufk SET zzfollowing = space
              WHERE aufnr       = p_line-zzorigin.

*-후속 생산오더에 기존 생산오더 CLEAR 업데이트
    UPDATE aufk SET zzorigin = space
              WHERE aufnr    = p_line-zzfollow.

    CLEAR: p_line-zzfollow.

    PERFORM save_zgtppt4000_rev USING p_line 'A'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZGTPPT4000_REV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&      --> P_
*&---------------------------------------------------------------------*
FORM save_zgtppt4000_rev  USING    p_line LIKE gs_revdata
                                   pv_gbn.

  DATA: ls_zgtppt4000  LIKE zgtppt4000,
        ls_zgtppt4000s LIKE zgtppt4000.

  CLEAR: ls_zgtppt4000, ls_zgtppt4000s.
  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF ls_zgtppt4000s
    FROM zgtppt4000
   WHERE zzorigin EQ p_line-zzorigin.

  IF ls_zgtppt4000s IS NOT INITIAL.
    IF pv_gbn EQ 'A'.
      ls_zgtppt4000 = VALUE #( BASE CORRESPONDING #( ls_zgtppt4000s )
*                               ZZORIGIN    = P_LINE-ZZORIGIN
*                               ZZDLV       = GC_X
                                 zzfollowing = space
                                 gamng       = space
                                 wemng       = space
                                 igmng       = space
                                 remng       = space
                                 gmein       = space
                                 crdat       = sy-datum
                                 crtim       = sy-uzeit
                                 crnam       = sy-uname ).

    ELSEIF pv_gbn EQ 'B'.
      ls_zgtppt4000 = VALUE #( BASE CORRESPONDING #( ls_zgtppt4000s )
*                                 ZZORIGIN = P_LINE-ZZORIGIN
                                 zzdlv    = space
                                 crdat    = sy-datum
                                 crtim    = sy-uzeit
                                 crnam    = sy-uname ).
    ENDIF.

    MODIFY zgtppt4000 FROM ls_zgtppt4000.
    IF sy-subrc EQ 0.
      COMMIT WORK.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ORD_DLV_CANC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_ord_dlv_canc .

  DATA: lt_row_no TYPE lvc_t_roid WITH HEADER LINE,
        l_answer  TYPE char01.

  FIELD-SYMBOLS: <fs_s> LIKE gs_revdata.

  CLEAR: l_answer.

  PERFORM sel_row_rtn TABLES lt_row_no
                      USING  go_grid_0100.

  IF lt_row_no[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE 'W'
       WITH TEXT-m01. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = TEXT-t11 "오더 마감 처리 취소
      text_question         = TEXT-t12 "오더 마감 처리를 취소하시겠습니까?
      display_cancel_button = space
    IMPORTING
      answer                = l_answer.

  IF l_answer = '1'.
    LOOP AT lt_row_no.
      READ TABLE gt_revdata ASSIGNING <fs_s> INDEX lt_row_no-row_id.

      IF <fs_s>-zzfollow IS NOT INITIAL.
        <fs_s>-rtmsg = TEXT-m11. "후속 생산오더가 아직 삭제되지 않았습니다.
      ELSE.
        PERFORM exec_ord_dlv_canc USING <fs_s>.
      ENDIF.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM ref_alv_rtn USING go_grid_0100.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_ORD_DLV_CANC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM exec_ord_dlv_canc  USING    p_line LIKE gs_revdata.

  CLEAR: bdcdata, bdcdata[], messtab, messtab[],
         gv_text.

  PERFORM dynpro1 USING:
        'X' 'SAPLCOKO1'   '0110',
        ' ' 'BDC_OKCODE'  '=ENTK',
        ' ' 'CAUFVD-AUFNR' p_line-aufnr.
*        ' ' 'R62CLORD-FLG_OVIEW' GC_X.

  PERFORM dynpro1 USING:
        'X' 'SAPLCOKO1'   '0115',
        ' ' 'BDC_OKCODE'  '=KOWE'.

  PERFORM dynpro1 USING:
        'X' 'SAPLCOKO1'   '0115',
        ' ' 'BDC_OKCODE'  '=BU',
        ' ' 'AFPOD-ELIKZ' space.

  gs_params-dismode  = 'N'.   " 처리모드
  gs_params-updmode  = 'S'.   " 갱신세션
  gs_params-cattmode = 'A'.   " CATT모드
  gs_params-defsize  = ' '.   " 기본화면
  gs_params-racommit = 'X'.   " COMMIT 이후 지속
  gs_params-nobinpt  = 'X'.   " BI 세션

  CALL TRANSACTION 'CO02'
             USING bdcdata
           OPTIONS FROM gs_params
          MESSAGES INTO messtab.

  READ TABLE messtab INDEX 1.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      msgid               = messtab-msgid
      msgnr               = messtab-msgnr
      msgv1               = messtab-msgv1
      msgv2               = messtab-msgv2
      msgv3               = messtab-msgv3
      msgv4               = messtab-msgv4
    IMPORTING
      message_text_output = gv_text.

  IF messtab-msgtyp <> gc_s.
    p_line-rtmsg = gv_text.
  ELSE.
    p_line-ord   = icon_led_red.
    p_line-rtmsg = TEXT-m12. "오더 마감 취소 처리에 성공하였습니다.

    PERFORM save_zgtppt4000_rev USING p_line 'B'.
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
*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
  ID 'WERKS'  FIELD s_werks-low.

  IF sy-subrc <> 0.
    "플랜트[S_WERKS-LOW] 작업권한을 확인하세요.
    MESSAGE e006 WITH TEXT-m15 s_werks-low TEXT-m16.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA_AUFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_aufnr .

  DATA: lt_aufnr LIKE TABLE OF gs_aufnr.

  DATA: l_dyn(50).

  CLEAR: l_dyn.
  IF p_c3 EQ gc_x.
    l_dyn = 'A~LOEKZ EQ @SPACE'.
  ENDIF.

  CLEAR: gt_aufnr.

  SELECT a~werks, a~aufnr, a~auart, a~loekz, a~objnr,
         a~zzorigin, a~zzfollowing,
         b~gamng, b~igmng, b~gmein, b~gstrp, b~gltrp, b~gstri,
         c~matnr, c~wemng, c~kdauf, c~kdpos,
         d~mtart, d~matkl,
         e~zpjno, e~bstnk,
         f~name1,
         g~mtbez,
         h~wgbez,
         i~maktx,
         j~zptxt,
         k~zjob_name AS jobnm
    FROM            aufk       AS a
   INNER JOIN       afko       AS b ON b~aufnr EQ a~aufnr
   INNER JOIN       afpo       AS c ON c~aufnr EQ b~aufnr
   INNER JOIN       mara       AS d ON d~matnr EQ c~matnr
    LEFT OUTER JOIN vbak       AS e ON e~vbeln EQ c~kdauf
    LEFT OUTER JOIN t001w      AS f ON f~werks EQ a~werks
    LEFT OUTER JOIN t134t      AS g ON g~spras EQ @sy-langu
                                   AND g~mtart EQ d~mtart
    LEFT OUTER JOIN t023t      AS h ON h~spras EQ @sy-langu
                                   AND h~matkl EQ d~matkl
    LEFT OUTER JOIN makt       AS i ON i~matnr EQ c~matnr
                                   AND i~spras EQ @sy-langu
    LEFT OUTER JOIN zsd0106t   AS j ON j~zpjno EQ e~zpjno
    LEFT OUTER JOIN zgtedt2121 AS k ON k~zjob_no EQ e~bstnk
   WHERE a~werks IN @s_werks
     AND a~aufnr IN @s_aufnr
     AND a~auart IN @s_auart
     AND b~gstrp IN @s_gstrp
     AND b~gstri IN @s_gstri
     AND c~matnr IN @s_matnr
     AND d~mtart IN @s_mtart
     AND d~matkl IN @s_matkl
     AND c~kdauf IN @s_kdauf
     AND c~kdpos IN @s_kdpos
     AND e~zpjno IN @s_zpjno
     AND e~bstnk IN @s_bstnk
     AND (l_dyn)
    INTO CORRESPONDING FIELDS OF TABLE @gt_aufnr.

*-예약 정보
  CLEAR: lt_aufnr.
  lt_aufnr = VALUE #( FOR ls_aufnr IN gt_aufnr WHERE ( aufnr IS NOT INITIAL )
                                    ( aufnr = ls_aufnr-aufnr ) ).

  SORT lt_aufnr BY aufnr.
  DELETE ADJACENT DUPLICATES FROM lt_aufnr COMPARING aufnr.

  CLEAR: gt_resb.
  IF lt_aufnr IS NOT INITIAL.
    SELECT aufnr, rsnum, rspos, kzear, enmng
      FROM resb
       FOR ALL ENTRIES IN @lt_aufnr
     WHERE aufnr EQ @lt_aufnr-aufnr
       AND xloek EQ @space
      INTO CORRESPONDING FIELDS OF TABLE @gt_resb.
  ENDIF.

  CLEAR: gt_resbchk.
  LOOP AT gt_resb INTO DATA(ls_resb).
    MOVE-CORRESPONDING ls_resb TO gs_resbchk.
    IF ls_resb-enmng EQ 0.
      CLEAR: gs_resbchk-kzear.
    ENDIF.
    COLLECT gs_resbchk INTO gt_resbchk.
  ENDLOOP.

  SORT: gt_aufnr   BY aufnr,
        gt_resbchk BY aufnr kzear ASCENDING enmng DESCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_DATA_AUFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_data_aufnr .

  DATA: BEGIN OF ls_stat,
          stat TYPE char100,
        END OF ls_stat,
        lt_stat LIKE TABLE OF ls_stat.

  DATA: lt_list LIKE TABLE OF zles001.

  DATA: lt_resbchk LIKE TABLE OF gs_resbchk.

  DATA: l_weblnr TYPE weblnr,
        l_status TYPE char100.

  CLEAR: lt_resbchk.
  APPEND LINES OF gt_resbchk TO lt_resbchk.

  LOOP AT gt_aufnr ASSIGNING FIELD-SYMBOL(<fs_a>).
*-자재투입상태
*-투입 미완료 확인
    READ TABLE gt_resbchk INTO DATA(ls_resbchk) WITH KEY aufnr = <fs_a>-aufnr
                                                         kzear = space.
    IF sy-subrc EQ 0.
*-수량이 있으면
      IF ls_resbchk-enmng GT 0.
        <fs_a>-matgi = icon_led_yellow.
      ELSE.
*-투입 완료 확인
        READ TABLE lt_resbchk INTO DATA(ls) WITH KEY aufnr = <fs_a>-aufnr
                                                     kzear = gc_x.
        IF sy-subrc EQ 0.
*-수량이 있으면
          IF ls-enmng GT 0.
            <fs_a>-matgi = icon_led_yellow.
          ELSE.
            <fs_a>-matgi = icon_led_red.
          ENDIF.
        ELSE.
          <fs_a>-matgi = icon_led_red.
        ENDIF.
      ENDIF.
      CLEAR: ls, ls_resbchk.
    ELSE.
      CLEAR: ls_resbchk.
*-투입 모두 완료 확인
      READ TABLE gt_resbchk INTO ls_resbchk WITH KEY aufnr = <fs_a>-aufnr
                                                     kzear = gc_x.
      IF sy-subrc EQ 0.
        <fs_a>-matgi = icon_led_green.
      ELSE.
        <fs_a>-matgi = icon_led_red.
      ENDIF.
      CLEAR: ls_resbchk.
    ENDIF.

*-오더상태
    CLEAR: ls_stat, lt_stat, l_status.
    CALL FUNCTION 'ZGTPP_ORDER_STATUS'
      EXPORTING
        i_aufnr  = <fs_a>-aufnr
      IMPORTING
        e_status = l_status.

    SPLIT l_status AT '/' INTO TABLE lt_stat.

*-생산확정상태
    IF line_exists( lt_stat[ stat = 'PCNF' ] ).
      <fs_a>-ordcf = icon_led_yellow.
    ELSE.
      IF line_exists( lt_stat[ stat = 'CNF' ] ).
        <fs_a>-ordcf = icon_led_green.
      ELSE.
        <fs_a>-ordcf = icon_led_red.
      ENDIF.
    ENDIF.

*-생산입고상태
    IF line_exists( lt_stat[ stat = 'PDLV' ] ).
      <fs_a>-ordgr = icon_led_yellow.
    ELSE.
      IF line_exists( lt_stat[ stat = 'DLV' ] ).
        <fs_a>-ordgr = icon_led_green.
      ELSE.
        <fs_a>-ordgr = icon_led_red.
      ENDIF.
    ENDIF.

*-제품구분
*    IF <FS_A>-KDAUF IS NOT INITIAL.
*      CLEAR: LT_LIST.
*      CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC'
*        EXPORTING
*          I_VBELN                      = <FS_A>-KDAUF
*          I_POSNR                      = <FS_A>-KDPOS
*          I_OBJECT                     = <FS_A>-MATNR
*          I_WERKS                      = <FS_A>-WERKS
*        TABLES
*          GT_LIST                      = LT_LIST
*        EXCEPTIONS
*          INSTANCE_NOT_FOUND           = 1
*          INSTANCE_IS_A_CLASSIFICATION = 2
*          INVALID_DATA                 = 3
*          OTHERS                       = 4.
*
*      READ TABLE LT_LIST INTO DATA(LS_LIST) WITH KEY ATNAM = 'PD_NBD_CM_PROD_ID'.
*
*      <FS_A>-PROD_ID = LS_LIST-ATWTB.
*    ENDIF.
*
*    CLEAR: LS_LIST.

*-오더상태
    <fs_a>-ordstat = l_status.

*-생산잔량 = 생산오더수량 - 생산입고수량
    <fs_a>-remng = <fs_a>-gamng - <fs_a>-wemng.

*-출하완료여부
    SELECT SINGLE wbsta
      FROM lips
     WHERE vgbel EQ @<fs_a>-kdauf
       AND vgpos EQ @<fs_a>-kdpos
       AND fkrel NE @space
      INTO @<fs_a>-wbsta.

  ENDLOOP.

*-라디오 버튼에 따른 데이터 컨트롤
*-생산 입고 상태
  IF p_grb EQ gc_x.      "완료건만
    DELETE gt_aufnr WHERE ordgr NE icon_led_green.
  ELSEIF p_grc EQ gc_x.  "미완료건만
    DELETE gt_aufnr WHERE ordgr EQ icon_led_green.
  ENDIF.

*-생산 확정 상태
  IF p_cfb EQ gc_x.      "완료건만
    DELETE gt_aufnr WHERE ordcf NE icon_led_green.
  ELSEIF p_cfc EQ gc_x.  "미완료건만
    DELETE gt_aufnr WHERE ordcf EQ icon_led_green.
  ENDIF.

*-자재 투입 상태
  IF p_gib EQ gc_x.      "완료건만
    DELETE gt_aufnr WHERE matgi NE icon_led_green.
  ELSEIF p_gic EQ gc_x.  "미완료건만
    DELETE gt_aufnr WHERE matgi EQ icon_led_green.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_AUFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_aufnr .
  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR4000TOP'
      i_internal_tabname     = 'GS_AUFNR'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  REFRESH gt_fieldcat_0100.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0100[]
    TABLES
      it_data         = gt_aufnr
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT gt_fieldcat_0100 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE <ls_fcat>-fieldname.
      WHEN 'MATGI'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f33. "자재투입
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
        <ls_fcat>-icon = gc_x.
      WHEN 'ORDCF'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f34. "생산확정
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
        <ls_fcat>-icon = gc_x.
      WHEN 'ORDGR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f35. "생산입고
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
        <ls_fcat>-icon = gc_x.
      WHEN 'LOEKZ'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f36. "삭제지시자
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
      WHEN 'AUFNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f06. "생산오더번호
        <ls_fcat>-key = gc_x.
        <ls_fcat>-just = gc_c.
      WHEN 'ORDSTAT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f07. "생산오더상태
        <ls_fcat>-just = gc_l.
      WHEN 'WERKS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f08. "플랜트
        <ls_fcat>-just = gc_c.
      WHEN 'NAME1'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f09. "플랜트 내역
        <ls_fcat>-just = gc_l.
      WHEN 'MTART'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f10. "자재유형
        <ls_fcat>-just = gc_c.
      WHEN 'MTBEZ'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f11. "자재유형 내역
        <ls_fcat>-just = gc_l.
      WHEN 'AUART'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f12. "생산오더유형
        <ls_fcat>-just = gc_c.
      WHEN 'MATKL'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f13. "자재그룹
        <ls_fcat>-just = gc_c.
      WHEN 'WGBEZ'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f14. "자재그룹 내역
        <ls_fcat>-just = gc_l.
*      WHEN 'PROD_ID'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F46. "제품구분
*        <LS_FCAT>-JUST = GC_C.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f15. "품목코드
        <ls_fcat>-just = gc_c.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f16. "품목내역
        <ls_fcat>-just = gc_l.
      WHEN 'GAMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f17. "생산오더수량
        <ls_fcat>-just = gc_r.
      WHEN 'WEMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f18. "생산입고수량
        <ls_fcat>-just = gc_r.
        <ls_fcat>-qfieldname = 'GMEIN'.
      WHEN 'IGMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f19. "생산확정수량
        <ls_fcat>-just = gc_r.
      WHEN 'REMNG'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f20. "생산잔량
        <ls_fcat>-just = gc_r.
      WHEN 'GMEIN'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f21. "생산단위
        <ls_fcat>-just = gc_c.
      WHEN 'ZPJNO'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f22. "프로젝트번호
        <ls_fcat>-just = gc_c.
      WHEN 'ZPTXT'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f23. "프로젝트내역
        <ls_fcat>-just = gc_l.
      WHEN 'BSTNK'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f24. "제조지시번호
        <ls_fcat>-just = gc_c.
      WHEN 'JOBNM'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f25. "제조지시내역
        <ls_fcat>-just = gc_l.
      WHEN 'KDAUF'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f26. "판매오더번호
        <ls_fcat>-just = gc_c.
      WHEN 'KDPOS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f27. "판매오더품목
        <ls_fcat>-just = gc_c.
      WHEN 'GSTRP'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f28. "오더시작일
        <ls_fcat>-just = gc_c.
      WHEN 'GLTRP'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f29. "오더종료일
        <ls_fcat>-just = gc_c.
      WHEN 'WBSTA'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f47. "출하완료여부
        <ls_fcat>-just = gc_c.
      WHEN 'ZZORIGIN'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f37. "기존 생산오더
        <ls_fcat>-just = gc_c.
        <ls_fcat>-convexit = 'ALPHA'.
      WHEN 'ZZFOLLOWING'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f38. "후속 생산오더
        <ls_fcat>-just = gc_c.
        <ls_fcat>-convexit = 'ALPHA'.
      WHEN 'GSTRI'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f48. "실제시작일
        <ls_fcat>-just = gc_c.
      WHEN 'STATUS'.
        IF gv_change_stat IS NOT INITIAL.
          <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f90. "상태
          <ls_fcat>-icon = gc_x.
          <ls_fcat>-just = gc_c.
        ELSE.
          <ls_fcat>-no_out = gc_x.
        ENDIF.
      WHEN 'MSG'.
        IF gv_change_stat IS NOT INITIAL.
          <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f91. "메시지
          <ls_fcat>-just = gc_l.
        ELSE.
          <ls_fcat>-no_out = gc_x.
        ENDIF.
      WHEN OTHERS.
        <ls_fcat>-no_out = gc_x.

    ENDCASE.

    IF <ls_fcat>-fieldname = 'MATGI' OR <ls_fcat>-fieldname = 'ORDCF' OR
       <ls_fcat>-fieldname = 'ORDGR' OR <ls_fcat>-fieldname = 'LOEKZ' OR
       <ls_fcat>-fieldname = 'AUFNR'.

    ELSE.
      CLEAR: <ls_fcat>-key.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_event_grid_0100 USING    po_grid TYPE REF TO cl_gui_alv_grid.
  IF go_evtr_0100 IS NOT BOUND.
    CREATE OBJECT go_evtr_0100.
  ENDIF.

  CASE po_grid.
    WHEN go_grid_0100.
      SET HANDLER: go_evtr_0100->hdl_double_click FOR go_grid_0100.
      SET HANDLER: go_evtr_0100->handle_toolbar FOR go_grid_0100.
      SET HANDLER: go_evtr_0100->handle_user_command FOR go_grid_0100.
  ENDCASE.

* DATA CHANGE
  CALL METHOD go_grid_0100->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SUBMIT_ZGTPPI2010
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM submit_zgtppi2010 .

  DATA: ls_seltab TYPE rsparams,
        lt_seltab TYPE TABLE OF rsparams.

  DATA : lv_jobname  LIKE tbtcjob-jobname VALUE 'ZGTPPI2010',
         lv_jobname2 LIKE tbtcjob-jobname,
         lv_jobcount LIKE tbtcjob-jobcount,
         lv_released LIKE btch0000-char1,
         lv_uzeit    LIKE sy-uzeit.

  LOOP AT gt_aufnr_send INTO gs_aufnr_send.
*-오더의 생성일
    SELECT SINGLE erdat
      FROM aufk
     WHERE aufnr EQ @gs_aufnr_send-aufnr
      INTO @gs_aufnr_send-erdat.

    CLEAR: lv_jobname2.
    lv_jobname2 = lv_jobname && |_| && sy-datum && |_| && sy-uzeit.

    CLEAR: lv_jobcount.
    DO.
      CALL FUNCTION 'JOB_OPEN'
        EXPORTING
          jobname          = lv_jobname2
        IMPORTING
          jobcount         = lv_jobcount
        EXCEPTIONS
          cant_create_job  = 1
          invalid_job_data = 2
          jobname_missing  = 3
          OTHERS           = 4.
      IF sy-subrc EQ 0.
        EXIT.
      ENDIF.
    ENDDO.

    CLEAR: lt_seltab[].
    lt_seltab = VALUE #(
    ( selname = 'S_AUFNR' kind = 'S' sign = 'I' option = 'EQ' low = gs_aufnr_send-aufnr )
    ( selname = 'S_ERDAT' kind = 'S' sign = 'I' option = 'EQ' low = gs_aufnr_send-erdat )
    ( selname = 'P_R1' kind = 'P' sign = 'I' option = 'EQ' low = 'X' )
    ( selname = 'P_R2' kind = 'P' sign = 'I' option = 'EQ' low = space )
    ( selname = 'P_R3' kind = 'P' sign = 'I' option = 'EQ' low = space )
    ( selname = 'P_R4' kind = 'P' sign = 'I' option = 'EQ' low = 'X' )
    ( selname = 'P_R9' kind = 'P' sign = 'I' option = 'EQ' low = space )
    ( selname = 'P_R8' kind = 'P' sign = 'I' option = 'EQ' low = 'X' ) ).

    SUBMIT zgtppi2010 VIA JOB lv_jobname2
                      NUMBER lv_jobcount
                      WITH SELECTION-TABLE lt_seltab
                      AND RETURN.

    CLEAR: lv_uzeit.
    lv_uzeit = sy-uzeit + 10.
    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = lv_jobcount
        jobname              = lv_jobname2
        sdlstrtdt            = sy-datum
        sdlstrttm            = lv_uzeit
        strtimmed            = 'X'  "즉시 기동
      IMPORTING
        job_was_released     = lv_released
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        OTHERS               = 8.

    CLEAR: gs_aufnr_send.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ITEMCHK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_itemchk .

  DATA: lt_row_no  TYPE lvc_t_roid WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_s> LIKE gs_data.

  PERFORM sel_row_rtn TABLES lt_row_no
                      USING  go_grid_0100.

  IF lt_row_no[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE gc_w
       WITH TEXT-m01. "실행 할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  IF lines( lt_row_no ) > 1.
    MESSAGE s003 DISPLAY LIKE gc_w
       WITH TEXT-m17. "하나의 레코드만 선택하세요.
    EXIT.
  ENDIF.

  CLEAR: gt_datas.
  IF p_r1 EQ gc_x.
    APPEND LINES OF gt_data TO gt_datas.
  ENDIF.

  LOOP AT lt_row_no.
    IF p_r1 EQ gc_x.
      READ TABLE gt_data ASSIGNING <fs_s> INDEX lt_row_no-row_id.
      PERFORM set_bottom_data_s USING <fs_s>.
    ENDIF.
    PERFORM set_bottom_data.
    PERFORM set_bottom_alv_0101.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BOTTOM_DATA_S
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM set_bottom_data_s  USING    p_line LIKE gs_data.

  CLEAR: gt_bottom.
  LOOP AT gt_obottom INTO DATA(ls_obtm) WHERE aufnr EQ p_line-aufnr.

    MOVE-CORRESPONDING ls_obtm TO gs_bottom.
    CLEAR: gs_bottom-mtrl_seq.

    COLLECT gs_bottom INTO gt_bottom.
    CLEAR: gs_bottom, ls_obtm.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BOTTOM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_bottom_data .
  SORT gt_bottom BY matnr.

  CLEAR: gv_seq.
  LOOP AT gt_bottom ASSIGNING FIELD-SYMBOL(<fs>).
    gv_seq = gv_seq + 1.
    <fs>-mtrl_seq = gv_seq.

*    READ TABLE GT_OBOTTOM INTO DATA(LS_OBTM)
*                          WITH KEY JOB_NO = <FS>-JOB_NO
*                                   LINE_NO = <FS>-LINE_NO
*                                   SERIAL_INFO = <FS>-SERIAL_INFO
*                                   MATNR = <FS>-MATNR.
*    IF SY-SUBRC EQ 0.
*      <FS>-KAUSF = LS_OBTM-KAUSF.
*    ENDIF.
*    CLEAR: LS_OBTM.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BOTTOM_ALV_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_bottom_alv_0101 .
  IF go_grid_0101 IS NOT BOUND.
    PERFORM set_object_grid_0101.
    PERFORM set_layout_grid_0101.
    PERFORM set_fieldcat_grid_0101.
    PERFORM exclude_of_toolbar_grid_0101.
    PERFORM call_grid_0101_display.
  ELSE.
    PERFORM ref_alv_rtn USING go_grid_0101.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_object_grid_0101 .
* bottom 컨테이너
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_contain_0101.

  CREATE OBJECT go_grid_0101
    EXPORTING
      i_parent      = go_contain_0101
      i_appl_events = abap_true.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_grid_0101 .
  CLEAR gs_layout_0101.
  gs_layout_0101-zebra      = gc_x.
  gs_layout_0101-col_opt    = gc_x.
  gs_layout_0101-cwidth_opt = gc_x.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_grid_0101 .
  DATA : lt_fcat_slis TYPE slis_t_fieldcat_alv.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_inclname             = 'ZGTPPR4000TOP'
      i_internal_tabname     = 'GS_BOTTOM'
    CHANGING
      ct_fieldcat            = lt_fcat_slis
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat_slis
    IMPORTING
      et_fieldcat_lvc = gt_fieldcat_0101[]
    TABLES
      it_data         = gt_bottom
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT gt_fieldcat_0101 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE <ls_fcat>-fieldname.
      WHEN 'MTRL_SEQ'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f39. "자재순번
        <ls_fcat>-just = gc_c.
      WHEN 'MATNR'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f40. "구성품코드
        <ls_fcat>-just = gc_c.
      WHEN 'MAKTX'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f41. "구성품내역
        <ls_fcat>-just = gc_l.
      WHEN 'MENGE'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f42. "순소요량
        <ls_fcat>-just = gc_r.
      WHEN 'KAUSF'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f43. "LOSS율(%)
        <ls_fcat>-just = gc_c.
      WHEN 'COMP_QTY'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f44. "총소요량
        <ls_fcat>-qfieldname = 'MEINS'.
        <ls_fcat>-just = gc_r.
      WHEN 'MEINS'.
        <ls_fcat>-reptext = <ls_fcat>-coltext = <ls_fcat>-tooltip = TEXT-f45. "수량단위
        <ls_fcat>-just = gc_c.
      WHEN OTHERS.
        <ls_fcat>-no_out = gc_x.
    ENDCASE.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_of_toolbar_grid_0101 .
  PERFORM add_exclude_toolbar_button TABLES gt_exclude_0101
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
      is_layout            = gs_layout_0101
      it_toolbar_excluding = gt_exclude_0101
    CHANGING
      it_outtab            = gt_bottom
      it_fieldcatalog      = gt_fieldcat_0101.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_BATCH_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM bapi_batch_create  USING    p_line LIKE gs_data.

  DATA: lv_class TYPE klah-class.
  DATA: lt_return TYPE TABLE OF bapiret2,
        ls_attr   TYPE bapibatchatt,
        ls_ctrl   TYPE bapibatchctrl.
  DATA: lv_message TYPE bapiret2-message.

  CLEAR: lv_class.
  CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
    EXPORTING
      material           = p_line-matnr
      plant              = p_line-werks
      classtype          = '023'
    IMPORTING
      class              = lv_class
    EXCEPTIONS
      no_class_found     = 1
      no_classtype_found = 2
      OTHERS             = 3.

  CLEAR: ls_attr, ls_ctrl.
  ls_attr-statuskey = gc_1.

  ls_ctrl = VALUE #( class_num  = lv_class
                     doclassify = gc_x ).

  CLEAR: lt_return, lv_message.
  CALL FUNCTION 'BAPI_BATCH_CREATE'
    EXPORTING
      material             = CONV matnr18( p_line-matnr )
      batch                = gc_gr_zero1
      plant                = p_line-werks
      batchattributes      = ls_attr
      batchcontrolfields   = ls_ctrl
      batchstoragelocation = p_line-lgort
    TABLES
      return               = lt_return.

  IF line_exists( lt_return[ type = 'E' ] ).

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).

    p_line-ord   = icon_led_red.
    p_line-rtmsg = lv_message.

  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    gv_charg = gc_gr_zero1.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_ZERO_GOODSMVT_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM bapi_zero_goodsmvt_create  USING    p_line LIKE gs_data.

  DATA: ls_header    TYPE bapi2017_gm_head_01,
        lv_code      TYPE bapi2017_gm_code VALUE '02',
        lv_document  TYPE bapi2017_gm_head_ret-mat_doc,
        lv_year      TYPE bapi2017_gm_head_ret-doc_year,
        lv_message   TYPE bapiret2-message,
        lt_item      TYPE TABLE OF bapi2017_gm_item_create,
        ls_gmheadret LIKE bapi2017_gm_head_ret,
        lt_return    TYPE TABLE OF bapiret2,
        ls_return    TYPE bapiret2,
        lv_charg     TYPE charg_d.

  CLEAR: ls_header.
  ls_header = VALUE #( pstng_date = p_budat
                       doc_date   = p_budat
                       header_txt = gc_gr_zero1 ).

  CLEAR: lv_charg.
  IF gv_xchpf IS NOT INITIAL.
    lv_charg = gc_gr_zero1.
  ENDIF.

  CLEAR: lt_item.
  lt_item = VALUE #( ( material       = p_line-matnr
                       plant          = p_line-werks
                       orderid        = p_line-aufnr
                       order_itno     = gc_0001
                       mvt_ind        = gc_f
                       stck_type      = space
                       no_more_gr     = gc_x
                       move_type      = gc_101
                       stge_loc       = p_line-lgort
                       batch          = lv_charg
                       entry_uom      = p_line-gmein
                       entry_qnt      = '0' ) ).

  CLEAR: lv_document, lv_year, ls_gmheadret, ls_return, lt_return, lv_message.
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_header
      goodsmvt_code    = lv_code
    IMPORTING
      goodsmvt_headret = ls_gmheadret
      materialdocument = lv_document
      matdocumentyear  = lv_year
    TABLES
      goodsmvt_item    = lt_item
      return           = lt_return.

  IF line_exists( lt_return[ type = 'E' ] ).
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
* 자재 락 에러일 경우 추가 5번 시도
    CLEAR ls_return.
    READ TABLE lt_return INTO ls_return WITH KEY type = 'E'
                                                   id = 'M3'
                                               number = '897'.
    IF ls_return IS NOT INITIAL.
      DO 5 TIMES.
        CALL FUNCTION 'DEQUEUE_EMMARCE'
          EXPORTING
            matnr = p_line-matnr
            werks = p_line-werks.

        WAIT UP TO '0.5' SECONDS.

        CLEAR: lv_document, lv_year, ls_gmheadret, ls_return, lt_return, lv_message.
        CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
          EXPORTING
            goodsmvt_header  = ls_header
            goodsmvt_code    = lv_code
          IMPORTING
            goodsmvt_headret = ls_gmheadret
            materialdocument = lv_document
            matdocumentyear  = lv_year
          TABLES
            goodsmvt_item    = lt_item
            return           = lt_return.

        IF line_exists( lt_return[ type = 'E' ] ).

          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).

          p_line-ord   = icon_led_red.
          p_line-rtmsg = lv_message.

        ELSE.

*          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*            EXPORTING
*              WAIT = 'X'.

          p_line-ord = icon_led_green.
          p_line-rtmsg = TEXT-m05. "오더 마감 처리에 성공하였습니다.

          PERFORM save_zgtppt4000 USING p_line 'A'.

          gv_chk = 'X'.
          EXIT.

        ENDIF.

      ENDDO.
* 5번 시도 후 여전히 처리안됐을 경우 마지막 에러 메시지 반영
      IF gv_chk IS INITIAL.

        lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).

        p_line-ord   = icon_led_red.
        p_line-rtmsg = lv_message.
        EXIT.

      ENDIF.
* 일반 에러일 경우 바로 메시지 반영
    ELSE.

      lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).

      p_line-ord   = icon_led_red.
      p_line-rtmsg = lv_message.
      EXIT.

    ENDIF.

  ELSE.

*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*      EXPORTING
*        WAIT = 'X'.

    p_line-ord = icon_led_green.
    p_line-rtmsg = TEXT-m05. "오더 마감 처리에 성공하였습니다.

    PERFORM save_zgtppt4000 USING p_line 'A'.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_ITEM_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM exec_item_create  USING    p_line LIKE gs_data.

  DATA: lt_bottom LIKE TABLE OF gs_bottom.

  CLEAR: lt_bottom.
  LOOP AT gt_obottom INTO DATA(ls_obtm) WHERE aufnr EQ p_line-aufnr.

    MOVE-CORRESPONDING ls_obtm TO gs_bottom.
    CLEAR: gs_bottom-mtrl_seq.

    COLLECT gs_bottom INTO lt_bottom.
    CLEAR: gs_bottom, ls_obtm.
  ENDLOOP.

  IF lt_bottom IS NOT INITIAL.
    SORT lt_bottom BY matnr.

    CLEAR: gv_seq.
    LOOP AT lt_bottom ASSIGNING FIELD-SYMBOL(<ls_btm>).
      gv_seq = gv_seq + 1.
      <ls_btm>-mtrl_seq = gv_seq.
    ENDLOOP.

    CLEAR: gv_posnr.

    LOOP AT lt_bottom INTO DATA(ls_bottom).
      CLEAR: gs_storage_location, gs_storage_locationx.
      SELECT SINGLE lgpro
        INTO gs_storage_location-lgort
        FROM marc
       WHERE matnr EQ ls_bottom-matnr.

      gs_storage_location-werks = p_line-werks.

      gs_storage_locationx-werks = gc_x.
      gs_storage_locationx-lgort = gc_x.

      CLEAR: gs_requ_quan.
      gs_requ_quan-quantity = ls_bottom-comp_qty.
      CALL FUNCTION 'UNIT_OF_MEASURE_ISO_TO_SAP'
        EXPORTING
          iso_code  = ls_bottom-meins
        IMPORTING
          sap_code  = gs_requ_quan-uom
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.

      CLEAR: gv_operation, gv_sequence.
      SELECT SINGLE b~aplzl b~plnfl
        INTO (gv_operation, gv_sequence)
        FROM afko AS a
       INNER JOIN afvc AS b ON b~aufpl EQ a~aufpl
       WHERE a~aufnr EQ p_line-zzfollow.

      CLEAR: gv_sobkz, gv_sobkzx, gv_kdauf, gv_kdaufx, gv_kdpos, gv_kdposx.
      IF ls_bottom-sbdkz EQ '1'.
        gv_sobkz = gc_e.
        gv_sobkzx = gc_x.
        gv_kdauf = p_line-kdauf.
        gv_kdaufx = gc_x.
        gv_kdpos = p_line-kdpos.
        gv_kdposx = gc_x.
      ENDIF.

      CLEAR: gv_postp, gv_positionno.
      gv_postp = gc_l.

      gv_posnr = gv_posnr + 10.
      CALL FUNCTION 'CONVERSION_EXIT_NUMCV_INPUT'
        EXPORTING
          input  = gv_posnr
        IMPORTING
          output = gv_positionno.

      CLEAR: gs_return, gv_error.
      CALL FUNCTION 'CO_XT_COMPONENT_ADD'
        EXPORTING
          is_order_key         = p_line-zzfollow
          i_material           = ls_bottom-matnr
          is_requ_quan         = gs_requ_quan
          i_operation          = gv_operation
          i_sequence           = gv_sequence
          is_storage_location  = gs_storage_location
          is_storage_locationx = gs_storage_locationx
          i_postp              = gv_postp
          i_sobkz              = gv_sobkz
          i_sobkzx             = gv_sobkzx
          i_kdauf              = gv_kdauf
          i_kdaufx             = gv_kdaufx
          i_kdpos              = gv_kdpos
          i_kdposx             = gv_kdposx
          i_posno              = gv_positionno
        IMPORTING
          es_bapireturn        = gs_return
          e_error_occurred     = gv_error.

      IF gv_error IS NOT INITIAL.
        p_line-ford  = icon_led_red.
        p_line-rtmsg = gs_return-message.
*        P_LINE-RTMSG = TEXT-M19. "생산오더의 구성부품 등록 도중 오류가 발생하였습니다.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF gv_error EQ space.
      CLEAR: gv_numc.
      ASSIGN ('(SAPLCOBC)RESB_BT[]') TO <ft_resb_bt>.
      LOOP AT <ft_resb_bt> ASSIGNING <fs_resb_bt>.
        gv_numc = sy-tabix * 10.
        <fs_resb_bt>-posnr = gv_numc.
        CLEAR gv_numc.
        READ TABLE lt_bottom INTO DATA(ls_btm) WITH KEY matnr = <fs_resb_bt>-matnr.
        IF sy-subrc EQ 0.
          IF ls_btm-rgekz EQ '1'.
            <fs_resb_bt>-rgekz = gc_x.
          ENDIF.
        ENDIF.
      ENDLOOP.

      CALL FUNCTION 'CO_ZV_ORDER_POST'
        EXPORTING
          commit_flag             = space
          ext_flg                 = 'X'
          trans_typ               = 'V'
          no_dialog               = 'X'
          iv_commit_work_and_wait = 'X'
        EXCEPTIONS
          no_change               = 01
          update_reject           = 02
          error_message           = 03.

      IF sy-subrc = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        CALL FUNCTION 'CO_XT_ORDER_INITIALIZE'.

        p_line-ford = icon_led_green.
        p_line-rtmsg = TEXT-m08. "후속 생산오더 생성에 성공하였습니다.

*-기존 생산오더에 후속 생산오더 업데이트
        UPDATE aufk SET zzfollowing = p_line-zzfollow
                  WHERE aufnr       = p_line-aufnr.

        WAIT UP TO 1 SECONDS.

*-후속 생산오더에 기존 생산오더 업데이트
        UPDATE aufk SET zzorigin = p_line-aufnr
                  WHERE aufnr    = p_line-zzfollow.

        PERFORM save_zgtppt4000 USING p_line 'B'.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = gc_x.

*-전송할 생산오더
        app_aufnr: p_line-aufnr.
        app_aufnr: p_line-zzfollow.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        p_line-ford  = icon_led_red.
        p_line-rtmsg = TEXT-m19. "생산오더의 구성부품 등록 도중 오류가 발생하였습니다.
      ENDIF.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      p_line-ford  = icon_led_red.
      p_line-rtmsg = gs_return-message.
*      P_LINE-RTMSG = TEXT-M19. "생산오더의 구성부품 등록 도중 오류가 발생하였습니다.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_LGORT_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LINE
*&---------------------------------------------------------------------*
FORM bapi_lgort_create  USING    p_line LIKE gs_data.

  DATA: ls_headdata             LIKE  bapimathead,
        ls_storagelocationdata  LIKE  bapi_mard,
        ls_storagelocationdatax LIKE  bapi_mardx,
        ls_return               LIKE  bapiret2.

  CLEAR: ls_headdata, ls_storagelocationdata, ls_storagelocationdatax.

  ls_headdata-material = p_line-matnr.
  ls_headdata-mrp_view = gc_x.
  ls_headdata-storage_view = gc_x.

  ls_storagelocationdata-plant     = p_line-werks.
  ls_storagelocationdata-stge_loc  = p_line-lgort.

  ls_storagelocationdatax-plant    = p_line-werks.
  ls_storagelocationdatax-stge_loc = p_line-lgort.

  CLEAR: ls_return.
  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      headdata             = ls_headdata
      storagelocationdata  = ls_storagelocationdata
      storagelocationdatax = ls_storagelocationdatax
    IMPORTING
      return               = ls_return.

  IF ls_return-type = gc_e.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    p_line-ord   = icon_led_red.
    p_line-rtmsg = ls_return-message.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    gv_lgortchk = gc_x.
  ENDIF.

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

      CHECK p_r3 = abap_true. " 생산오더 현황시만 실행
      PERFORM set_toolbar TABLES po_object->mt_toolbar
                           USING : 'CHG_DATE' icon_change '오더 일정변경' '오더 일정변경' 0.
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
        WHEN 'CHG_DATE'. " 생산오더 일정변경
          PERFORM change_order_date USING po_sender.
      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_ORDER_DATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_SENDER
*&---------------------------------------------------------------------*
FORM change_order_date  USING   po_sender  TYPE REF TO cl_gui_alv_grid.

  DATA : lt_rows TYPE lvc_t_row.

  CHECK p_r3 = abap_true. " 생산오더 현황시만 실행

  po_sender->get_selected_rows(
    IMPORTING
      et_index_rows     = lt_rows               " Numeric IDs of Selected Rows
  ).

  DELETE lt_rows WHERE index = 0. " 서브토탈 라인 제거

* 유효성체크
  LOOP AT lt_rows INTO DATA(ls_rows).
    READ TABLE gt_aufnr INTO DATA(ls_data) INDEX ls_rows-index.
    IF ls_data-matgi = icon_led_red AND
      ls_data-ordcf = icon_led_red AND
      ls_data-ordgr = icon_led_red.
*     모두 빨간불일때 수행가능
    ELSE.
      MESSAGE s006 DISPLAY LIKE 'E' WITH '선택한 Line 중에 오더' ls_data-aufnr '가 이미 진행된 작업이 있습니다.'.
      RETURN.
    ENDIF.
  ENDLOOP.

  CLEAR : gv_gstrp, gv_gltrp.
  gv_gstrp = sy-datum.
  gv_gltrp = sy-datum.
  CALL SCREEN '0200' STARTING AT 5 5 ENDING AT 49 9.

  IF ( gv_gstrp IS INITIAL OR gv_gstrp = '00000000' ) AND
    ( gv_gltrp IS NOT INITIAL OR gv_gltrp = '00000000' ).
    RETURN.
  ENDIF.

* 날짜 변경 시작
  gv_change_stat = abap_true.
  LOOP AT lt_rows INTO ls_rows.
    READ TABLE gt_aufnr ASSIGNING FIELD-SYMBOL(<ls_data>) INDEX ls_rows-index.
    PERFORM change_date_bapi  USING <ls_data>-aufnr
                              CHANGING <ls_data>-status <ls_data>-msg.

*/s 2026.08.10.zlsgpp5.SRM2608-03040.대량처리 속도향상을 위해 루프문 밖으로 로직 분리.
*    IF <ls_data>-status EQ icon_led_green. " 일정 변경 정상 수행시 오더일자로 재세팅
*      SELECT SINGLE gstrp, gltrp FROM afko
*        INTO ( @<ls_data>-gstrp, @<ls_data>-gltrp )
*       WHERE aufnr = @<ls_data>-aufnr.
*    ENDIF.
*/e 2026.08.10.zlsgpp5.
  ENDLOOP.

* 일정 변경 정상 수행시 오더일자로 alv 재세팅.
*/s 2026.08.10.zlsgpp5.SRM2608-03040.대량처리 속도향상을 위해 루프문 밖으로 로직 분리.
  SELECT aufnr, gstrp, gltrp
    FROM afko
     FOR ALL ENTRIES IN @gt_aufnr
   WHERE aufnr = @gt_aufnr-aufnr
    INTO TABLE @DATA(lt_afko).

  SORT lt_afko BY aufnr.
  LOOP AT lt_rows INTO ls_rows.
    READ TABLE gt_aufnr ASSIGNING <ls_data> INDEX ls_rows-index.
    IF <ls_data>-status EQ icon_led_green.
      READ TABLE lt_afko ASSIGNING FIELD-SYMBOL(<ls_afko>) WITH KEY aufnr = <ls_data>-aufnr
                                                           BINARY SEARCH.
      IF sy-subrc EQ 0.
        <ls_data>-gstrp = <ls_afko>-gstrp.
        <ls_data>-gltrp = <ls_afko>-gltrp.
      ENDIF.
    ENDIF.
  ENDLOOP.
*/e 2026.08.10.zlsgpp5.

  PERFORM set_fieldcat_aufnr.
  po_sender->set_frontend_fieldcatalog( it_fieldcatalog = gt_fieldcat_0100 ).

  " REFRESH DISPLAY
  PERFORM ref_alv_rtn USING po_sender.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS '0200'.
  SET TITLEBAR '0200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CLEAR gv_ok_code2.
  gv_ok_code2 = sy-ucomm.
  CLEAR sy-ucomm.
  CASE gv_ok_code2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : gv_gltrp, gv_gstrp.
      LEAVE TO SCREEN 0.
    WHEN 'OKAY'.
*    종료일이 시작일보다 작은경우 메시지처리
      IF gv_gltrp < gv_gstrp.
        MESSAGE s006 DISPLAY LIKE 'E' WITH '시작일자가 종료일자보다 늦을 수 없습니다.'.
        RETURN.
      ENDIF.

      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form CHANGE_DATE_BAPI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_DATA>_AUFNR
*&      <-- <LS_DATA>_STATUS
*&      <-- <LS_DATA>_MSG
*&---------------------------------------------------------------------*
FORM change_date_bapi USING     pv_aufnr TYPE aufnr
                      CHANGING  pv_status TYPE icon-id
                                pv_msg.

  DATA : lv_number TYPE bapi_order_key-order_number.
  DATA : ls_orderdata TYPE bapi_pp_order_change.
  DATA : ls_orderdatax TYPE bapi_pp_order_changex.
  DATA : ls_return TYPE bapiret2.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = pv_aufnr
    IMPORTING
      output = lv_number.

  ls_orderdata-basic_start_date = gv_gstrp.
  ls_orderdata-basic_end_date = gv_gltrp.
  ls_orderdata-basic_scheduling_type = '3'.
  ls_orderdatax-basic_start_date = 'X'.
  ls_orderdatax-basic_end_date = 'X'.
  ls_orderdatax-basic_scheduling_type = 'X'.

  CALL FUNCTION 'BAPI_PRODORD_CHANGE'
    EXPORTING
      number     = lv_number
      orderdata  = ls_orderdata
      orderdatax = ls_orderdatax
    IMPORTING
      return     = ls_return.

  IF ls_return-type NE 'E'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.

*/s 2026.08.10.zlsgpp5.SRM2608-03040.대량처리 속도향상을 위해 주석처리.
*    WAIT UP TO '0.5' SECONDS.
*/e 2026.08.10.zlsgpp5.SRM2608-03040.

    pv_status = icon_led_green.
    MESSAGE s006 WITH '일정변경 완료' INTO pv_msg.

  ELSE.
    pv_status = icon_led_red.
    MESSAGE s006 WITH TEXT-e10 lv_number TEXT-e15 INTO pv_msg.
    RETURN.
  ENDIF.


ENDFORM.
