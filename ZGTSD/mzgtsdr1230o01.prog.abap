*&---------------------------------------------------------------------*
*&  Include         MZGTSDR1230O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.


  DATA : g_codi_chk(1)  TYPE c,
         g_sdnam_chk(1) TYPE c.

  DATA : l_cordi LIKE zqmt0011h-cordi,
         l_sdnam LIKE zqmt0011h-sdnam,
         l_bukrs TYPE  t001-bukrs.

  CLEAR   : gt_excl.
  CLEAR   : g_codi_chk, g_sdnam_chk, l_cordi, l_sdnam.
  REFRESH : gt_excl.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = gs_100-cordi
    IMPORTING
      output = gs_100-cordi.

  l_cordi = gs_100-cordi.
  l_sdnam = gs_100-sdnam.

  GET PARAMETER ID 'BUK' FIELD l_bukrs.

*{[기능개선263877] 고객불만 관련 변경요청
* 코디네이터ID와 접속한 아이디가 동일한 경우 G_CODI_CHK = X 입력

  PERFORM check_user_dep USING    sy-uname
                                  l_cordi
                      CHANGING    g_codi_chk.

  PERFORM check_user_dep USING    sy-uname
                                  l_sdnam
                      CHANGING    g_sdnam_chk.

  IF g_codi_chk NE 'X' AND g_sdnam_chk NE 'X'.

    PERFORM check_user_cc USING  sy-uname
                                 l_cordi
                        CHANGING g_codi_chk.

    PERFORM check_user_cc USING  sy-uname
                                 l_sdnam
                        CHANGING g_sdnam_chk.

  ENDIF.
*}[기능개선263877] 20190131 HJW

*___T-CODE/상태에 따라 버튼 비활성화
*[기능개선263877] 고객불만 관련 변경요청
* LSC의 경우 G_CODI_CHK가 X 아니면 버튼 비활성화
*->[가온전선]--------------------CHG S
  IF gv_suser NE gc_x OR
*  IF ( SY-UNAME NE 'ZLSGQM' AND SY-UNAME NE 'ZLSGPP1' AND
*       SY-UNAME NE 'ZLSGQM1' AND SY-UNAME NE 'ZLSGQM2') OR
*-<[가온전선]--------------------CHG E
      ( gs_100-bukrs EQ '6000' AND
        g_codi_chk EQ '' AND g_sdnam_chk EQ '').            "190131 HJW
    CASE gv_trtyp.
      WHEN 'H'.
* [S] 안정화
*        IF GS_100-RCEPNO IS INITIAL AND GS_100-RCNAM <> SY-UNAME.
        IF gs_100-rcepno IS INITIAL AND sy-uname CS gs_100-rcnam .
          gt_excl-fcode = 'CONF'.  APPEND gt_excl.
        ENDIF.

        gt_excl-fcode = 'CANC2'.  APPEND gt_excl.
        gt_excl-fcode = 'SEND'.   APPEND gt_excl.
        gt_excl-fcode = 'CANC3'.  APPEND gt_excl.
        gt_excl-fcode = 'OK'.     APPEND gt_excl.
        gt_excl-fcode = 'UNDO'.   APPEND gt_excl.

      WHEN 'V'.
* [S] 안정화
*        IF GS_100-STATUS <> 'CL10' OR SY-UNAME <> GS_100-RCNAM.
        IF gs_100-status <> 'CL10' OR sy-uname CS gs_100-rcnam.
          gt_excl-fcode = 'CONF'.   APPEND gt_excl.
          gt_excl-fcode = 'CANC2'.  APPEND gt_excl.
        ENDIF.

*-{CHM2212-00383 LS전선인 경우 G_CODI_CHK = 'X'이면 활성화
*        IF GS_100-STATUS <> 'CL20' OR SY-UNAME <> GS_100-CORDI.
*          GT_EXCL-FCODE = 'SEND'.  APPEND GT_EXCL.
*        ENDIF.
*
*        IF GS_100-STATUS <> 'CL30' OR SY-UNAME <> GS_100-CORDI.
*          GT_EXCL-FCODE = 'CANC3'.  APPEND GT_EXCL.
*        ENDIF.

        IF gs_100-status <> 'CL20' OR
            ( L_BUKRS NE '6000' AND SY-UNAME <> GS_100-CORDI ) OR
            ( l_bukrs EQ '6000' AND g_codi_chk NE 'X'  ).
          gt_excl-fcode = 'SEND'.  APPEND gt_excl.
        ENDIF.

        IF gs_100-status <> 'CL30' OR
             ( l_bukrs NE '6000' AND sy-uname <> gs_100-cordi ) OR
             ( l_bukrs EQ '6000' AND g_codi_chk NE 'X'  ).
          gt_excl-fcode = 'CANC3'.  APPEND gt_excl.
        ENDIF.
*}-CHM2212-00383
*[S] 안정화
*        IF gs_100-status <> 'CL40' OR sy-uname <> gs_100-jgnam.
        IF gs_100-status <> 'CL40' OR  gs_100-jgnam CS sy-uname .
          gt_excl-fcode = 'OK'.     APPEND gt_excl.
          gt_excl-fcode = 'UNDO'.   APPEND gt_excl.
        ENDIF.

      WHEN 'A'.
        gt_excl-fcode = 'CONF'.   APPEND gt_excl.
        gt_excl-fcode = 'CANC2'.  APPEND gt_excl.
        gt_excl-fcode = 'SAVE'.   APPEND gt_excl.
        gt_excl-fcode = 'OK'.     APPEND gt_excl.
        gt_excl-fcode = 'UNDO'.   APPEND gt_excl.
        gt_excl-fcode = 'SEND'.   APPEND gt_excl.
        gt_excl-fcode = 'CANC3'.  APPEND gt_excl.

    ENDCASE.
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING gt_excl.
  SET TITLEBAR  '100'  WITH gv_title.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_0100 OUTPUT.

* 접수번호의 회사코드를 전역 변수에 넣어둔다.
  SELECT SINGLE  bukrs
    INTO g_bukrs
    FROM zqmt0011h
   WHERE rcepno = gs_100-rcepno.

  IMPORT gd_bukrs FROM MEMORY ID 'BUKRS_ID_GO'.

*  IF SY-UNAME = 'ZLSGQM' OR SY-UNAME = 'ZLSGPP1'.
*    GS_SAVE = 'A'.
*  ENDIF.



  IF gv_trtyp IS INITIAL.
    g_bukrs = gc_bukrs_6000.  "회사코드

    "CHECK SUSER
    PERFORM check_suser.

    IF gv_suser EQ gc_x.
      gs_save = 'A'.
    ENDIF.

    CASE sy-tcode.
      WHEN gc_tcode1 OR
            gc_tcode4 .  "접수
        gv_trtyp = 'H'.

      WHEN gc_tcode2.    "변경
        gv_trtyp = 'V'.

      WHEN gc_tcode3.    "조회
        gv_trtyp = 'A'.

      WHEN OTHERS.       "기타 - 조회
        gv_trtyp = 'A'.

    ENDCASE.

    IF gv_trtyp <> 'H'.
      GET PARAMETER ID 'ZRCEPNO_GO' FIELD gv_rcepno.

      IF gv_rcepno IS NOT INITIAL.
        PERFORM get_complain_data.

        IF gs_100-rcepno IS NOT INITIAL.
          IF sy-tcode = 'ZGTSDR1231'.
            PERFORM enqueue_zqmt0011h USING gs_100-rcepno.
          ENDIF.
        ELSE.
          MESSAGE s001 DISPLAY LIKE 'E'
             WITH 'Data not found.'.

          LEAVE PROGRAM.
        ENDIF.
      ELSE.
        MESSAGE s001 DISPLAY LIKE 'E'
           WITH 'Data not found'.

        LEAVE PROGRAM.
      ENDIF.
    ELSE.
      IF gs_100-status IS INITIAL.
        gs_100-status       = 'CL10'.
      ENDIF.
    ENDIF.

  ENDIF.

  IF gv_subscr_1 IS INITIAL.
    gv_title    = '개요'.
    gv_subscr_1 = '0200'.    "개요 화면을 첫화면으로
    gv_subscr_2 = '0210'.
    gv_subscr_3 = '0220'.
    gv_subscr_4 = '0230'.
    gv_subscr_5 = '0240'.
    gv_subscr_6 = '0250'.
    gv_subscr_7 = '0260'.
  ENDIF.

ENDMODULE.                 " INIT_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_AND_INIT_TREE_01  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_and_init_tree_01 OUTPUT.

  IF gc_tree_01 IS INITIAL.
    CREATE OBJECT gc_ldocking_01
      EXPORTING
        repid                       = sy-repid
        dynnr                       = sy-dynnr
        side                        = gc_ldocking_01->dock_at_left
        extension                   = 220
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CREATE OBJECT gc_tree_01
      EXPORTING
        parent                      = gc_ldocking_01
        node_selection_mode         =
                                      cl_gui_simple_tree=>node_sel_mode_single
      EXCEPTIONS
        lifetime_error              = 1
        cntl_system_error           = 2
        create_error                = 3
        failed                      = 4
        illegal_node_selection_mode = 5
        OTHERS                      = 6.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*   append events
*    gs_event-eventid = cl_gui_simple_tree=>eventid_node_double_click.
*    gs_event-appl_event = 'X'.
*    APPEND gs_event TO gt_events.

    gs_event-eventid = cl_gui_simple_tree=>eventid_selection_changed.
    gs_event-appl_event = 'X'.
    APPEND gs_event TO gt_events.

    gs_event-eventid = cl_gui_simple_tree=>eventid_node_context_menu_req
    .
    gs_event-appl_event = 'X'.
    APPEND gs_event TO gt_events.

*  'X': Event with PAI; ' ': Event Without PAI
    CALL METHOD gc_tree_01->set_ctx_menu_select_event_appl
      EXPORTING
        appl_event = 'X'.

    CALL METHOD gc_tree_01->set_registered_events
      EXPORTING
        events                    = gt_events
      EXCEPTIONS
        cntl_error                = 1
        cntl_system_error         = 2
        illegal_event_combination = 3
        OTHERS                    = 4.

    IF sy-subrc <> 0.
      MESSAGE a009.
    ENDIF.

    CREATE OBJECT gc_event_handler.

*    SET HANDLER gc_event_handler->handle_node_double_click
*            FOR gc_tree_01.
    SET HANDLER gc_event_handler->handle_selection_changed
            FOR gc_tree_01.
    SET HANDLER gc_event_handler->handle_node_cm_request
            FOR gc_tree_01.
    SET HANDLER gc_event_handler->handle_node_cm_sel
            FOR gc_tree_01.

    PERFORM fill_tree_structure.

    CALL METHOD gc_tree_01->add_nodes
      EXPORTING
        table_structure_name           = 'MTREESNODE'
        node_table                     = gt_node
      EXCEPTIONS
        error_in_node_table            = 1
        failed                         = 2
        dp_error                       = 3
        table_structure_name_not_found = 4
        OTHERS                         = 5.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    IF gv_trtyp <> 'H' AND
       gs_100-status <> 'CL10' AND gs_100-status <> 'CL20'.

      CALL METHOD gc_tree_01->expand_node
        EXPORTING
          node_key = '3'.

*->[가온전선]--------------------CHG S
*      CALL METHOD GC_TREE_01->EXPAND_NODE
*        EXPORTING
*          NODE_KEY = '6'.
*-<[가온전선]--------------------CHG E
    ENDIF.
  ELSE.
    DESCRIBE TABLE gt_node LINES gv_nline1.

    PERFORM fill_tree_structure.

    DESCRIBE TABLE gt_node LINES gv_nline2.

    IF gv_nline1 <> gv_nline2.
      CALL METHOD gc_tree_01->delete_all_nodes.

      CALL METHOD gc_tree_01->add_nodes
        EXPORTING
          table_structure_name           = 'MTREESNODE'
          node_table                     = gt_node
        EXCEPTIONS
          error_in_node_table            = 1
          failed                         = 2
          dp_error                       = 3
          table_structure_name_not_found = 4
          OTHERS                         = 5.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      IF gv_trtyp <> 'H' AND
         gs_100-status <> 'CL10' AND gs_100-status <> 'CL20'.

        CALL METHOD gc_tree_01->expand_node
          EXPORTING
            node_key = '3'.

*->[가온전선]--------------------CHG S
*        CALL METHOD GC_TREE_01->EXPAND_NODE
*          EXPORTING
*            NODE_KEY = '6'.
*-<[가온전선]--------------------CHG E
      ENDIF.
    ENDIF.
  ENDIF.

  IF gv_node_key IS INITIAL.
    gv_node_key = '1'.
  ENDIF.

  CALL METHOD gc_tree_01->set_selected_node
    EXPORTING
      node_key = gv_node_key.

*___노드 이미지 설정
  PERFORM get_icon_image: USING '3' CHANGING gv_icon1,
                          USING '4' CHANGING gv_icon2,
                          USING '5' CHANGING gv_icon3.

  PERFORM node_set_image USING : '3' gv_icon1,
                                 '4' gv_icon2,
                                 '5' gv_icon3.

ENDMODULE.                 " CREATE_AND_INIT_TREE_01  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_INIT_0210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE screen_init_0210 OUTPUT.

*__접수일
  IF gs_100-rcepdt IS INITIAL.
    gs_100-rcepdt     =  sy-datum.
  ENDIF.

*__상태
  IF gs_100-status IS INITIAL.
    gs_100-status       = 'CL10'.
  ENDIF.

*__중요도
  IF gs_100-priority IS INITIAL.
    gs_100-priority     = 'Z'.
  ENDIF.

*__상태내역
  PERFORM get_sul_status_txt USING    'ZSTATUS_H' gs_100-status
                             CHANGING gs_100-statust.

*__중요도내역
  PERFORM get_sul_status_txt USING    'ZPRIORITY' gs_100-priority
                             CHANGING gs_100-priorityt.

ENDMODULE.                 " SCREEN_INIT_0210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_TEXT_EDITOR_0230  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_text_editor_0230 OUTPUT.

  IF g_cl_text1 IS INITIAL.
    PERFORM create_text_editor USING g_cl_text1
                                     '0230'
                                     'CUM_LT1'.
  ENDIF.

  IF gv_trtyp = 'A' OR gv_subscr_1 <> '0200' OR
    ( gs_100-status NE 'CL05' AND gs_100-status NE 'CL10' AND
      gs_100-status NE 'CL30' ).

    CALL METHOD g_cl_text1->set_readonly_mode
      EXPORTING
        readonly_mode = 1.

  ELSE.

    CALL METHOD g_cl_text1->set_readonly_mode
      EXPORTING
        readonly_mode = 0.

  ENDIF.

ENDMODULE.                 " CREATE_TEXT_EDITOR_0230  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_LONG_TEXT_0230  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_long_text_0230 OUTPUT.

  PERFORM set_long_text TABLES g_lines1_n
                        USING  g_cl_text1
                               g_olin1
                               g_nlin1.

ENDMODULE.                 " SET_LONG_TEXT_0230  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_TEXT_EDITOR_0240  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_text_editor_0240 OUTPUT.

  IF g_cl_text2 IS INITIAL.
    PERFORM create_text_editor USING g_cl_text2
                                     '0240'
                                     'CUM_LT2'.
  ENDIF.

  IF gv_trtyp = 'A' OR gv_subscr_1 <> '0200' OR
    ( gs_100-status NE 'CL05' AND gs_100-status NE 'CL10' AND
      gs_100-status NE 'CL30' ).

    CALL METHOD g_cl_text2->set_readonly_mode
      EXPORTING
        readonly_mode = 1.

  ELSE.

    CALL METHOD g_cl_text2->set_readonly_mode
      EXPORTING
        readonly_mode = 0.

  ENDIF.

ENDMODULE.                 " CREATE_TEXT_EDITOR_0240  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_LONG_TEXT_0240  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_long_text_0240 OUTPUT.

  PERFORM set_long_text TABLES g_lines2_n
                        USING  g_cl_text2
                               g_olin2
                               g_nlin2.

ENDMODULE.                 " SET_LONG_TEXT_0240  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_0210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_0210 OUTPUT.

  LOOP AT  SCREEN.

    IF         gv_trtyp <> 'A'.
      IF gv_no = 'X' OR gv_trtyp = 'A' OR gv_subscr_1 = '0300'
         OR gv_subscr_1 = '0400' OR gv_subscr_1 = '0700'
         OR gv_subscr_1 = '1100' OR gv_subscr_1 = '1200'
         OR ( gs_100-status NE 'CL05' AND gs_100-status NE 'CL10'
              AND gs_100-status NE 'CL30' ).

        IF screen-group1 = 'MOD'.
          screen-input = 0.
        ENDIF.

      ENDIF.

      IF gs_100-status = 'CL05' OR gs_100-status = 'CL10' OR
         gs_100-status = 'CL30' OR gs_100-status = 'CL40'.
        "첨부파일 버튼
*        IF GS_100-DOKNR IS INITIAL.
        IF gs_100-attch IS INITIAL.
          CASE screen-group2.
            WHEN 'CR'. "생성
              screen-input     =  1.
            WHEN 'CH'. "변경
              screen-input     =  0.
            WHEN 'CD'. "조회
              screen-input     =  0.
          ENDCASE.
*          IF  SCREEN-GROUP2    EQ  'CH'.
*            SCREEN-INPUT     =  0.
*          ELSEIF SCREEN-GROUP2 EQ 'CR'.
*            SCREEN-INPUT     =  1.
*          ENDIF.
        ELSE.
          CASE screen-group2.
            WHEN 'CR'. "생성
              screen-input     =  0.
            WHEN 'CH'. "변경
              screen-input     =  1.
            WHEN 'CD'. "조회
              screen-input     =  0.
          ENDCASE.

*          IF  SCREEN-GROUP2    EQ  'CR'.
*            SCREEN-INPUT     =  0.
*          ELSEIF SCREEN-GROUP2 EQ 'CH'.
*            SCREEN-INPUT     =  1.
*          ENDIF.
*          IF GS_100-STATUS = 'CL60' AND GS_100-CORDI EQ SY-UNAME.
*            IF  SCREEN-GROUP2  EQ  'CH'.
*              SCREEN-INPUT     =  1.
*            ENDIF.
*          ENDIF.
        ENDIF.

      ENDIF.

    ELSE.

      IF screen-group1 = 'DIS'.  "첨부파일 조회 버튼
        IF gs_100-attch IS NOT INITIAL.
          screen-input = 1.
        ELSE.
          screen-input     =  0.
        ENDIF.
      ELSE.
        screen-input     =  0.
      ENDIF.

    ENDIF.

    "DMS 문서번호(DOKNR) INACTIVE
    IF screen-group4 = 'XG1'.
      screen-active = 0.
      screen-input  = 0.
    ENDIF.

    MODIFY    SCREEN.

  ENDLOOP.

ENDMODULE.                 " MODIFY_SCREEN_0210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.

  SORT gt_100 BY zmatseq." DESCENDING.
  READ TABLE gt_100  INDEX tc_100-current_line.
  IF sy-subrc <> 0.
    EXIT FROM STEP-LOOP.
  ENDIF.

ENDMODULE.                 " FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_310  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_310 OUTPUT.

  IF gt_100[] IS INITIAL.
*   고객불만(자재)
    SELECT *
      FROM zqmt0011m
      INTO CORRESPONDING FIELDS OF TABLE gt_100
     WHERE rcepno EQ gs_100-rcepno.  "index pk
  ENDIF.

* 고객불만 전체내용
  IF gt_110a[] IS INITIAL.
*   고객불만(불만배치)
*   전체테이블(gt_110a)로 가져온다. (gt_110은 보여주는 테이블)
    SELECT * FROM zqmt0011b
             INTO CORRESPONDING FIELDS OF TABLE gt_110a
            WHERE rcepno EQ gs_100-rcepno.  "index pk
  ENDIF.

* 불만유형 전체내용
  IF gt_120a[] IS INITIAL.
*   회사코드를 읽어온다.
    PERFORM get_bukrs  USING    gs_100-werks_h
                       CHANGING gv_bukrs_316.
*   고객불만(불만유형)
*   전체테이블(gt_120a)로 가져온다. (gt_120은 보여주는 테이블)
    SELECT * FROM zqmt0012n
             INTO CORRESPONDING FIELDS OF TABLE gt_120a
            WHERE bukrs  EQ gv_bukrs_316    "index pk
              AND rcepno EQ gs_100-rcepno.  "index pk
  ENDIF.

* 처음 호출하는지 확인
  CHECK gv_isfirst IS INITIAL.
  PERFORM is_first_call_0310.

ENDMODULE.                 " INIT_310  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_TC1_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_tc1_lines OUTPUT.

  DESCRIBE TABLE gt_100 LINES tc_100-lines.
  DESCRIBE TABLE gt_110 LINES tc_110-lines.
  DESCRIBE TABLE gt_120 LINES tc_120-lines.

ENDMODULE.                 " SET_TC1_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control1 OUTPUT.

  SORT gt_110 BY zmatseq zchaseq. " DESCENDING.
  READ TABLE gt_110  INDEX tc_110-current_line.
  IF sy-subrc <> 0.
    EXIT FROM STEP-LOOP.
  ENDIF.

ENDMODULE.                 " FILL_TABLE_CONTROL1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_TC_110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen_attribute_tc_110 OUTPUT.

* 데이터가 없으면 입력불가
  IF gt_110[] IS INITIAL OR
    ( gs_100-status NE 'CL05' AND gs_100-status NE 'CL10'
     AND gs_100-status NE 'CL30' )
     OR gv_trtyp = 'A' OR gt_110-kzloesch = 'X'.

    LOOP AT SCREEN.
      IF screen-group1 EQ 'CNT' OR screen-group1 = 'GR1'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

* 데이터가 있는경우만 입력가능
  ELSE.

    LOOP AT SCREEN.
      IF screen-group1 EQ 'CNT'.
        screen-input = 1.
      ENDIF.

      IF screen-group1 = 'GR1' AND gs_100-status = 'CL30'.
        screen-input = 1.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.



ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_TC_110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL2  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control2 OUTPUT.

  SORT gt_120 BY zmatseq. " DESCENDING.
  READ TABLE gt_120  INDEX tc_120-current_line.
  IF sy-subrc = 0.
* 결함유형 텍스트를 읽는다.
    PERFORM get_qpct_data USING gt_120-ftkat
                                gt_120-ftgrp
                                gt_120-flttp
                                gt_120-flver
                          CHANGING gt_120-flttpt.
* 위치정보 텍스트를 읽는다.
    PERFORM get_qpct_data USING gt_120-otkat
                                gt_120-otrgrp
                                gt_120-oteil
                                gt_120-otver
                          CHANGING gt_120-oteilt.
    MODIFY gt_120 INDEX tc_120-current_line TRANSPORTING flttpt oteilt.
  ELSE.
    EXIT FROM STEP-LOOP.
  ENDIF.

ENDMODULE.                 " FILL_TABLE_CONTROL2  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_140  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE alv_init_140 OUTPUT.

  IF  g_custom_c_2  IS INITIAL.
    CREATE OBJECT g_custom_c_2
      EXPORTING
        container_name              = g_container_2
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_grid_2
      EXPORTING
        i_appl_events = 'X'
        i_parent      = g_custom_c_2.

*-Tool Bar 버튼 제거 필요없는 버튼 추가.
    PERFORM exclude_of_toolbar_button_grid USING 'GT_EXCLUDE'.

    PERFORM  fill_field_category_1    USING  'GT_140'
                                      CHANGING  gt_fieldcat_2 .
    PERFORM  modify_fieldcat_1     CHANGING  gt_fieldcat_2 .

    PERFORM pro_layout_1 USING gs_layout_2.

*-Edit Event 및 Event Handler 등록
    PERFORM event_handler_register_140.

*-- At least field REPORT of this structure has to be filled!
    gs_variant_2-handle = '0001'.
    gs_variant_2-report = sy-repid.

    CALL METHOD g_grid_2->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_2
        i_save               = gs_save
        it_toolbar_excluding = gt_exclude
        is_variant           = gs_variant_2  " 선택 메뉴 display
      CHANGING
        it_fieldcatalog      = gt_fieldcat_2
*       IT_SORT              = GT_SORT
        it_outtab            = gt_140[].
  ELSE.
    PERFORM g_grid_2_refresh.
  ENDIF .

*  CALL METHOD G_GRID_100->SET_TOOLBAR_INTERACTIVE.

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_2.

ENDMODULE.                 " ALV_INIT_140  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_150  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE alv_init_150 OUTPUT.

  IF  g_custom_c_3  IS INITIAL.
    CREATE OBJECT g_custom_c_3
      EXPORTING
        container_name              = g_container_3
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_grid_3
      EXPORTING
        i_appl_events = 'X'
        i_parent      = g_custom_c_3.

*-Tool Bar 버튼 제거 필요없는 버튼 추가.
    PERFORM exclude_of_toolbar_button_grid USING 'GT_EXCLUDE'.

    PERFORM  fill_field_category_1    USING  'GT_150'
                                      CHANGING  gt_fieldcat_3 .
    PERFORM  modify_fieldcat_1     CHANGING  gt_fieldcat_3 .

    PERFORM pro_layout_1 USING gs_layout_3.

*-Edit Event 및 Event Handler 등록
    PERFORM event_handler_register_150.

*-- At least field REPORT of this structure has to be filled!
    gs_variant_3-handle = '0101'.
    gs_variant_3-report = sy-repid.

    CALL METHOD g_grid_3->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_3
        it_toolbar_excluding = gt_exclude
        i_save               = gs_save   " 전체가능유형.
        is_variant           = gs_variant_3  " 선택 메뉴 display
      CHANGING
        it_fieldcatalog      = gt_fieldcat_3
*       IT_SORT              = GT_SORT
        it_outtab            = gt_150[].
  ELSE.
    PERFORM g_grid_3_refresh.
  ENDIF .

*  CALL METHOD G_GRID_100->SET_TOOLBAR_INTERACTIVE.


*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_3.

ENDMODULE.                 " ALV_INIT_150  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_510  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_510 OUTPUT.

  READ TABLE gt_160 WITH KEY mark = 'X'.
  IF sy-subrc <> 0.
    CLEAR :   gt_170,  gt_170_old,
              gv_re,   gv_zreq,
              gv_zorq, gv_zfq.
    REFRESH : gt_170,  gt_170_old.
  ENDIF.

  IF gv_trtyp = 'V' AND gs_100-status <> 'CL40'.

    LOOP AT  SCREEN.

      IF screen-name = 'GS_100-CORDINR'.
        screen-input = 0.
      ENDIF.

      PERFORM modify_screen_button USING: gv_re   'RE_CR'   'RE_CH',
                                          gv_zreq 'ZREQ_CR' 'ZREQ_CH',
                                          gv_zorq 'ZORQ_CR' 'ZORQ_CH',
                                          gv_zfq  'ZFQ_CR'  'ZFQ_CH'.

      IF gv_zreq IS NOT INITIAL.
        IF screen-name = 'ZORQ_RQ_CR'.
          screen-input = 1.
        ENDIF.
      ENDIF.

      MODIFY    SCREEN.
    ENDLOOP.

  ELSEIF gv_trtyp = 'A' OR gs_100-status = 'CL40'.

    LOOP AT SCREEN.

      screen-input = 0.

      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

  "처리요청 버튼 HIDE
  LOOP AT SCREEN.
    IF screen-group4 EQ 'XG1'.
      screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " MODIFY_SCREEN_510  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE alv_init_100 OUTPUT.

  IF  g_custom_c_4  IS INITIAL.
    CREATE OBJECT g_custom_c_4
      EXPORTING
        container_name              = g_container_4
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_grid_4
      EXPORTING
        i_appl_events = 'X'
        i_parent      = g_custom_c_4.


*-Tool Bar 버튼 제거 필요없는 버튼 추가.
    PERFORM exclude_of_toolbar_button_grid USING 'GT_EXCLUDE'.

    PERFORM  fill_field_category_1    USING  'GT_100'
                                      CHANGING  gt_fieldcat_4 .
    PERFORM  modify_fieldcat_1     CHANGING  gt_fieldcat_4 .

    PERFORM pro_layout_1 USING gs_layout_4.

*-- At least field REPORT of this structure has to be filled!
    gs_variant_4-handle = '0102'.
    gs_variant_4-report = sy-repid.

    CALL METHOD g_grid_4->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_4
        it_toolbar_excluding = gt_exclude
        i_save               = gs_save   " 전체가능유형.
        is_variant           = gs_variant_4  " 선택 메뉴 display
      CHANGING
        it_fieldcatalog      = gt_fieldcat_4
*       IT_SORT              = GT_SORT
        it_outtab            = gt_100[].
  ELSE.
    PERFORM g_grid_4_refresh.
  ENDIF .

*  CALL METHOD G_GRID_100->SET_TOOLBAR_INTERACTIVE.

  CALL METHOD cl_gui_control=>set_focus
    EXPORTING
      control = g_grid_4.

ENDMODULE.                 " ALV_INIT_100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_TC2_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_tc2_lines OUTPUT.

  DESCRIBE TABLE gt_160 LINES tc_160-lines.

ENDMODULE.                 " SET_TC2_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL6  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control6 OUTPUT.

  SORT gt_160 BY zmatseq.
  READ TABLE gt_160  INDEX tc_160-current_line.
  IF sy-subrc <> 0.
    EXIT FROM STEP-LOOP.
  ENDIF.

ENDMODULE.                 " FILL_TABLE_CONTROL6  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_170  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE alv_init_170 OUTPUT.

  IF  g_custom_c_5  IS INITIAL.
    CREATE OBJECT g_custom_c_5
      EXPORTING
        container_name              = g_container_5
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_grid_5
      EXPORTING
        i_appl_events = 'X'
        i_parent      = g_custom_c_5.


*-Tool Bar 버튼 제거 필요없는 버튼 추가.
    PERFORM exclude_of_toolbar_button_grid USING 'GT_EXCLUDE'.

    PERFORM  fill_field_category_1    USING  'GT_170'
                                      CHANGING  gt_fieldcat_5 .
    PERFORM  modify_fieldcat_1     CHANGING  gt_fieldcat_5 .

    PERFORM pro_layout_1 USING gs_layout_5.

*-Edit Event 및 Event Handler 등록
    PERFORM event_handler_register_170.

*-- At least field REPORT of this structure has to be filled!
    gs_variant_5-handle = '0103'.
    gs_variant_5-report = sy-repid.

    CALL METHOD g_grid_5->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_5
        it_toolbar_excluding = gt_exclude
        i_save               = gs_save   " 전체가능유형.
        is_variant           = gs_variant_5  " 선택 메뉴 display
      CHANGING
        it_fieldcatalog      = gt_fieldcat_5
*       IT_SORT              = GT_SORT
        it_outtab            = gt_170[].
  ELSE.
    PERFORM g_grid_5_refresh.
  ENDIF .

*  CALL METHOD G_GRID_100->SET_TOOLBAR_INTERACTIVE.

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_5.

ENDMODULE.                 " ALV_INIT_170  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0520  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0520 OUTPUT.

  SET PF-STATUS 'POPU'.

  IF gv_chk = '1'.
    SET TITLEBAR 'TITLE0520' WITH TEXT-001.
  ELSEIF gv_chk = '2'.
    SET TITLEBAR 'TITLE0520' WITH TEXT-002.
  ENDIF.

ENDMODULE.                 " STATUS_0520  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_DATA_0520  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_data_0520 OUTPUT.

  PERFORM alv_init_180.

ENDMODULE.                 " INIT_DATA_0520  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_220  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_220 OUTPUT.

  DATA : lv_bukrs_t TYPE t001-bukrs.

  LOOP AT  SCREEN.
    IF ( gs_100-status NE 'CL05' AND gs_100-status NE 'CL10' AND
         gs_100-status NE 'CL30' ) OR gv_trtyp = 'A'.
      IF screen-group1 = 'MOD'.
        screen-input = 0.
      ENDIF.

    ENDIF.

    MODIFY    SCREEN.
  ENDLOOP.

  LOOP AT SCREEN.

    IF screen-name = 'GS_100-POSID'
       OR screen-name = 'GS_100-WOGBTR'"품질비용 금액
       OR screen-name = 'GS_100-WAERS'."통화 키

      GET PARAMETER ID 'BUK' FIELD lv_bukrs_t.

      IF lv_bukrs_t = '3000'.
        IF ( screen-group2 = 'WBS'OR
             screen-group2 = 'WCD' ).
          screen-active = 0.
        ENDIF.

      ELSE.
        CASE gv_trtyp.
          WHEN 'A'.
*{[기능개선_244688]   고객불만 WBS코드 관련 수정
*                     WBS코드 입력되지 않더라도 공란 표기되도록함
*            IF gs_100-posid IS INITIAL AND
*               ( screen-group2 = 'WBS'OR
*                 screen-group2 = 'WCD' ).
*               screen-active = 0.
*            ENDIF.
*__ 고객불만관련 수정 20180807 by sdw
          WHEN OTHERS.
            IF  screen-group2 = 'WBS'.
              screen-active = 0.
            ENDIF.
        ENDCASE.

      ENDIF.



    ELSE.
      GET PARAMETER ID 'BUK' FIELD lv_bukrs_t.

      IF lv_bukrs_t = '3000'.

        IF   ( screen-group2 = 'WBS'OR
               screen-group2 = 'WCD' ).
          screen-active = 0.
        ENDIF.

      ELSE.

        CASE gv_trtyp.
          WHEN 'A'.
*{[기능개선_244688]   고객불만 WBS코드 관련 수정
*            IF gs_100-posid IS INITIAL AND
*               ( screen-group2 = 'WBS'OR
*                 screen-group2 = 'WCD' ).
*              screen-active = 0.
*            ENDIF.
*__ 고객불만관련 수정 20180807 by sdw
          WHEN OTHERS.
            IF  screen-group2 = 'WBS'.
              screen-active = 0.
            ENDIF.
        ENDCASE.

      ENDIF.

    ENDIF.

    MODIFY    SCREEN.

  ENDLOOP.

ENDMODULE.                 " MODIFY_SCREEN_220  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_250  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_250 OUTPUT.

  LOOP AT  SCREEN.
    IF gv_subscr_1 = '1100' OR  gv_subscr_1 = '1200' OR
      ( gs_100-status NE 'CL05' AND gs_100-status NE 'CL10' AND
      gs_100-status NE 'CL30' ) OR gv_trtyp = 'A'.
      IF screen-group1 = 'MOD'.
        screen-input = 0.
      ENDIF.
    ENDIF.

    MODIFY    SCREEN.
  ENDLOOP.

ENDMODULE.                 " MODIFY_SCREEN_250  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_TC3_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_tc3_lines OUTPUT.

  DESCRIBE TABLE gt_190 LINES tc_190-lines.

ENDMODULE.                 " SET_TC3_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL9  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control9 OUTPUT.

  READ TABLE gt_190  INDEX tc_190-current_line.
  IF sy-subrc <> 0.
    EXIT FROM STEP-LOOP.
  ENDIF.


ENDMODULE.                 " FILL_TABLE_CONTROL9  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_610  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE alv_init_610 OUTPUT.
  IF  g_custom_c_7  IS INITIAL.
    CREATE OBJECT g_custom_c_7
      EXPORTING
        container_name              = g_container_7
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_grid_7
      EXPORTING
        i_appl_events = 'X'
        i_parent      = g_custom_c_7.


*-Tool Bar 버튼 제거 필요없는 버튼 추가.
    PERFORM exclude_of_toolbar_button_grid USING 'GT_EXCLUDE'.

    PERFORM  fill_field_category_1    USING  'GT_200'
                                      CHANGING  gt_fieldcat_7 .
    PERFORM  modify_fieldcat_1     CHANGING  gt_fieldcat_7 .

    PERFORM pro_layout_1 USING gs_layout_7.

*-Edit Event 및 Event Handler 등록
    PERFORM event_handler_register_200.

*-- At least field REPORT of this structure has to be filled!
    gs_variant_7-handle = '0105'.
    gs_variant_7-report = sy-repid.

    CALL METHOD g_grid_7->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_7
        it_toolbar_excluding = gt_exclude
        i_save               = gs_save           " 전체가능유형.
        is_variant           = gs_variant_7  " 선택 메뉴 display
      CHANGING
        it_fieldcatalog      = gt_fieldcat_7
*       IT_SORT              = GT_SORT
        it_outtab            = gt_200[].
  ELSE.
    PERFORM g_grid_7_refresh.
  ENDIF .

*  CALL METHOD G_GRID_100->SET_TOOLBAR_INTERACTIVE.

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_7.

ENDMODULE.                 " ALV_INIT_610  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_610  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_610 OUTPUT.

  IF gv_trtyp = 'V' AND gs_100-status <> 'CL40'.

    LOOP AT  SCREEN.

      IF screen-name = 'GS_100-CORDINR'.
        screen-input = 0.
      ENDIF.

      PERFORM modify_screen_button2 USING: gv_prueflos
                                         'PRUEFLOS_CR'    'PRUEFLOS_CH'
                                         'PRUEFLOS_IN_CH'
                                         'PRUEFLOS_UD_CH'
                                         'PRUEFLOS_MB1B'.

      MODIFY    SCREEN.
    ENDLOOP.

  ELSEIF gv_trtyp = 'A' OR gs_100-status = 'CL40'.

    LOOP AT SCREEN.

      screen-input = 0.

      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " MODIFY_SCREEN_610  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_710  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_710 OUTPUT.



  IF gv_trtyp = 'V' AND gs_100-status <> 'CL40'.

    LOOP AT  SCREEN.
*      IF gs_100-status <> 'CL30'.
*        IF screen-name = 'S_710-ETAMT'.
*          screen-input = 0.
*        ENDIF.
*      ELSE.
*C20111012_79186  : START   호사코드 1000인경우만 공사재작업비(외부)
*조회됨
      IF  g_bukrs <> '6000'.
        IF screen-name = '%#AUTOTEXT048'  OR screen-name =
        'S_710-BEAMT10'
           OR screen-name = '%#AUTOTEXT47' .
          screen-invisible = 1.
        ENDIF.
      ENDIF.

      MODIFY    SCREEN.
    ENDLOOP.

  ELSEIF gv_trtyp = 'A' OR gs_100-status = 'CL40'.

    LOOP AT SCREEN.

      screen-input = 0.
*C20111012_79186  : START   호사코드 1000인경우만 공사재작업비(외부)
*조회됨
      IF  g_bukrs <> '6000'.
        IF screen-name = '%#AUTOTEXT048'  OR screen-name =
        'S_710-BEAMT10'
           OR screen-name = '%#AUTOTEXT47' .
          screen-invisible = 1.
        ENDIF.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " MODIFY_SCREEN_710  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_TC4_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_tc4_lines OUTPUT.

  DESCRIBE TABLE gt_210 LINES tc_210-lines.

ENDMODULE.                 " SET_TC4_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL7  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control7 OUTPUT.

  READ TABLE gt_210  INDEX tc_210-current_line.
  IF sy-subrc <> 0.
    EXIT FROM STEP-LOOP.
  ENDIF.

ENDMODULE.                 " FILL_TABLE_CONTROL7  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_TEXT_EDITOR_1110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_text_editor_1110 OUTPUT.

  IF g_cl_text3 IS INITIAL.
    PERFORM create_text_editor USING g_cl_text3
                                     '1110'
                                     'CUM_LT3'.

  ENDIF.

  IF gv_trtyp = 'A'.

    CALL METHOD g_cl_text3->set_readonly_mode
      EXPORTING
        readonly_mode = 1.
  ENDIF.

ENDMODULE.                 " CREATE_TEXT_EDITOR_1110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_LONG_TEXT_1110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_long_text_1110 OUTPUT.

  PERFORM set_long_text TABLES g_lines3_n
                        USING  g_cl_text3
                               g_olin3
                               g_nlin3.

ENDMODULE.                 " SET_LONG_TEXT_1110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_1110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_1110 OUTPUT.

  IF gs_100-status NE 'CL30'.
    CALL METHOD g_cl_text3->set_readonly_mode
      EXPORTING
        readonly_mode = 1.
  ENDIF.

ENDMODULE.                 " MODIFY_SCREEN_1110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_TEXT_EDITOR_1120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_text_editor_1120 OUTPUT.

  IF g_cl_text4 IS INITIAL.
    PERFORM create_text_editor USING g_cl_text4
                                     '1120'
                                     'CUM_LT4'.
  ENDIF.

  IF gv_trtyp = 'A'.

    CALL METHOD g_cl_text4->set_readonly_mode
      EXPORTING
        readonly_mode = 1.
  ENDIF.


ENDMODULE.                 " CREATE_TEXT_EDITOR_1120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_LONG_TEXT_1120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_long_text_1120 OUTPUT.

  PERFORM set_long_text TABLES g_lines4_n
                        USING  g_cl_text4
                               g_olin4
                               g_nlin4.

ENDMODULE.                 " SET_LONG_TEXT_1120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_1120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_1120 OUTPUT.

  IF gs_100-status NE 'CL30'.
    CALL METHOD g_cl_text4->set_readonly_mode
      EXPORTING
        readonly_mode = 1.
  ENDIF.

ENDMODULE.                 " MODIFY_SCREEN_1120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_1130  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE alv_init_1130 OUTPUT.

  IF  g_custom_c_10  IS INITIAL.
    CREATE OBJECT g_custom_c_10
      EXPORTING
        container_name              = g_container_10
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_grid_10
      EXPORTING
        i_appl_events = 'X'
        i_parent      = g_custom_c_10.


*-Tool Bar 버튼 제거 필요없는 버튼 추가.
    PERFORM exclude_of_toolbar_button_grid USING 'GT_EXCLUDE'.

    PERFORM  fill_field_category_1         USING 'GT_230'
                                        CHANGING gt_fieldcat_10 .
    PERFORM  modify_fieldcat_1          CHANGING gt_fieldcat_10 .

    PERFORM pro_layout_1 USING gs_layout_10.

*-Edit Event 및 Event Handler 등록
    PERFORM event_handler_register_230.

*-- At least field REPORT of this structure has to be filled!
    gs_variant_10-handle = '0106'.
    gs_variant_10-report = sy-repid.

    CALL METHOD g_grid_10->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_10
        it_toolbar_excluding = gt_exclude
        i_save               = gs_save   " 전체가능유형.
        is_variant           = gs_variant_10  " 선택 메뉴 display
      CHANGING
        it_fieldcatalog      = gt_fieldcat_10
*       IT_SORT              = GT_SORT
        it_outtab            = gt_230[].
  ELSE.
    PERFORM g_grid_10_refresh.
  ENDIF .

*  CALL METHOD G_GRID_100->SET_TOOLBAR_INTERACTIVE.

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_10.

ENDMODULE.                 " ALV_INIT_1130  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_TC5_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_tc5_lines OUTPUT.

  DESCRIBE TABLE gt_240_tc LINES tc_1130-lines.

ENDMODULE.                 " SET_TC5_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL3  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control3 OUTPUT.

  READ TABLE gt_240_tc  INDEX tc_1130-current_line.
  IF sy-subrc <> 0.
    EXIT FROM STEP-LOOP.
  ENDIF.

ENDMODULE.                 " FILL_TABLE_CONTROL3  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_TEXT_EDITOR_1140  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_text_editor_1140 OUTPUT.

  IF g_cl_text5 IS INITIAL.
    PERFORM create_text_editor USING g_cl_text5
                                     '1140'
                                     'CUM_LT5'.
  ENDIF.

  IF gv_trtyp = 'A'.

    CALL METHOD g_cl_text5->set_readonly_mode
      EXPORTING
        readonly_mode = 1.
  ENDIF.


ENDMODULE.                 " CREATE_TEXT_EDITOR_1140  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_LONG_TEXT_1140  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_long_text_1140 OUTPUT.

  PERFORM set_long_text TABLES g_lines5_n
                        USING  g_cl_text5
                               g_olin5
                               g_nlin5.

ENDMODULE.                 " SET_LONG_TEXT_1140  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_1140  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_1140 OUTPUT.

  IF gs_100-status NE 'CL30'.
    CALL METHOD g_cl_text5->set_readonly_mode
      EXPORTING
        readonly_mode = 1.
  ENDIF.

ENDMODULE.                 " MODIFY_SCREEN_1140  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_1130  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_1130 OUTPUT.

  READ TABLE gt_230 WITH KEY  mark = 'X'.
  IF sy-subrc = 0.
    IF gt_230-kzloesch = 'X' OR gt_230-dflg = 'X'.

      LOOP AT SCREEN.
        IF screen-group2 = 'GR1'.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ELSE.
    CLEAR : gt_240_tc, gt_240_tc[].
  ENDIF.

  IF gv_trtyp = 'V' AND gs_100-status <> 'CL40'.

    LOOP AT gt_240_tc WHERE dflg = 'X'.
      LOOP AT SCREEN.
        IF screen-group3 = '240'.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDLOOP.

  ELSEIF gv_trtyp = 'A' OR gs_100-status = 'CL40'.
    LOOP AT SCREEN.

      screen-input = 0.

      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " MODIFY_SCREEN_1130  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CREATE_TEXT_EDITOR_1210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_text_editor_1210 OUTPUT.
  IF g_cl_text6 IS INITIAL.
    PERFORM create_text_editor USING g_cl_text6
                                     '1210'
                                     'CUM_LT6'.

  ENDIF.
ENDMODULE.                 " CREATE_TEXT_EDITOR_1210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_LONG_TEXT_1210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_long_text_1210 OUTPUT.

  PERFORM set_long_text TABLES g_lines6_n
                        USING  g_cl_text6
                               g_olin6
                               g_nlin6.

ENDMODULE.                 " SET_LONG_TEXT_1210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_1210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_1210 OUTPUT.

  IF gv_trtyp = 'V'.

    IF gs_100-status NE 'CL30' AND gs_100-status NE 'CL40'.

      CALL METHOD g_cl_text6->set_readonly_mode
        EXPORTING
          readonly_mode = 1.

    ENDIF.


    LOOP AT  SCREEN.

      IF gs_100-status NE 'CL30'.
        IF screen-group1 = 'MOD'.
          screen-input = 0.
        ENDIF.
      ENDIF.

      IF gs_100-bukrs = '6000'.
        IF screen-name = 'GS_100-DCLAS4'.
          screen-input = 0.
        ENDIF.
      ENDIF.
** C20111012_79186  : START  회사코드 1000인경우에만 생산완료일, 출하일
*관리
      IF gs_100-bukrs <> '6000'.
        IF screen-name = 'GS_100-CDDAT'
           OR screen-name = 'CDDAT_TEXT'
           OR screen-name = 'GS_100-DLDAT'
           OR screen-name = 'DLDAT_TEXT' .
          screen-invisible = 1.
          screen-active = 0.
        ENDIF.
      ELSEIF gs_100-bukrs =  '6000'.
        IF screen-name = 'GS_100-CONET2'.
          screen-required = 1.
        ENDIF.
*        IF SCREEN-NAME = 'GS_100-CDDAT'
*           OR SCREEN-NAME = 'GS_100-DLDAT'
*           OR SCREEN-NAME = 'GS_100-CONET2'.
*          SCREEN-REQUIRED = 1.
*        ENDIF.

      ENDIF.
* * C20111012_79186  : END
      MODIFY    SCREEN.

    ENDLOOP.

  ELSEIF gv_trtyp = 'A'.

    CALL METHOD g_cl_text6->set_readonly_mode
      EXPORTING
        readonly_mode = 1.

    LOOP AT SCREEN.

      screen-input = 0.

* 회사코드 1000인경우에만 생산완료일, 출하일 관리
      IF gs_100-bukrs <> '6000'.
        IF screen-name = 'GS_100-CDDAT'
           OR screen-name = 'CDDAT_TEXT'
           OR screen-name = 'GS_100-DLDAT'
           OR screen-name = 'DLDAT_TEXT' .
          screen-invisible = 1.
          screen-active = 0.
        ENDIF.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.


  ENDIF.

*->[가온전선]--------------------CHG S
  LOOP AT SCREEN.
    IF screen-group4 EQ 'XG1'.
      screen-active = 0.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
*-<[가온전선]--------------------CHG E

ENDMODULE.                 " MODIFY_SCREEN_1210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_INIT_1210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE screen_init_1210 OUTPUT.
* 책임부서
  IF  NOT  gs_100-respt  IS INITIAL.
    PERFORM  respt_read  USING    'AB'  gs_100-respt
                         CHANGING  gs_100-resptt.
  ELSE.
    CLEAR: gs_100-resptt.
  ENDIF.

*___처리결과 - 원인부문 텍스트
  IF NOT gs_100-conet2 IS INITIAL.
    PERFORM conet2_read USING gs_100-conet2
                              gs_100-conett2.
  ELSE.
    CLEAR : gs_100-conett2.
  ENDIF.

ENDMODULE.                 " SCREEN_INIT_1210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_1210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE alv_init_1210 OUTPUT.
  IF  g_custom_c_11  IS INITIAL.
    CREATE OBJECT g_custom_c_11
      EXPORTING
        container_name              = g_container_11
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_grid_11
      EXPORTING
        i_appl_events = 'X'
        i_parent      = g_custom_c_11.


*-Tool Bar 버튼 제거 필요없는 버튼 추가.
    PERFORM exclude_of_toolbar_button_grid USING 'GT_EXCLUDE'.

    PERFORM  fill_field_category_1    USING  'GT_280'
                                      CHANGING  gt_fieldcat_11 .
    PERFORM  modify_fieldcat_1     CHANGING  gt_fieldcat_11 .

    PERFORM pro_layout_1 USING gs_layout_11.

    PERFORM event_handler_register_1210.

*-- At least field REPORT of this structure has to be filled!
    gs_variant_11-handle = '0006'.
    gs_variant_11-report = sy-repid.

    CALL METHOD g_grid_11->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_11
        it_toolbar_excluding = gt_exclude
        i_save               = gs_save   " 전체가능유형.
        is_variant           = gs_variant_11  " 선택 메뉴 display
      CHANGING
        it_fieldcatalog      = gt_fieldcat_11
*       IT_SORT              = GT_SORT
        it_outtab            = gt_280[].
  ELSE.
    PERFORM g_grid_11_refresh.
  ENDIF .

*  CALL METHOD G_GRID_100->SET_TOOLBAR_INTERACTIVE.

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_11.

ENDMODULE.                 " ALV_INIT_1210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_1310_1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE alv_init_1310_1 OUTPUT.

  IF  g_custom_c_12  IS INITIAL.
    CREATE OBJECT g_custom_c_12
      EXPORTING
        container_name              = g_container_12
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_grid_12
      EXPORTING
        i_appl_events = 'X'
        i_parent      = g_custom_c_12.


*-Tool Bar 버튼 제거 필요없는 버튼 추가.
    PERFORM exclude_of_toolbar_button_grid USING 'GT_EXCLUDE'.

    PERFORM  fill_field_category_1    USING  'GT_250'
                                      CHANGING  gt_fieldcat_12 .
    PERFORM  modify_fieldcat_1     CHANGING  gt_fieldcat_12 .

    PERFORM pro_layout_1 USING gs_layout_12.

*-Edit Event 및 Event Handler 등록
    PERFORM event_handler_register_250.

*-- At least field REPORT of this structure has to be filled!
    gs_variant_12-handle = '0107'.
    gs_variant_12-report = sy-repid.

    CALL METHOD g_grid_12->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_12
        it_toolbar_excluding = gt_exclude
        i_save               = gs_save   " 전체가능유형.
        is_variant           = gs_variant_12  " 선택 메뉴 display
      CHANGING
        it_fieldcatalog      = gt_fieldcat_12
*       IT_SORT              = GT_SORT
        it_outtab            = gt_250[].
  ELSE.
    PERFORM g_grid_12_refresh.
  ENDIF .

*  CALL METHOD G_GRID_100->SET_TOOLBAR_INTERACTIVE.

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_12.

ENDMODULE.                 " ALV_INIT_1310_1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_1310_2  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE alv_init_1310_2 OUTPUT.
  IF  g_custom_c_13  IS INITIAL.
    CREATE OBJECT g_custom_c_13
      EXPORTING
        container_name              = g_container_13
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_grid_13
      EXPORTING
        i_appl_events = 'X'
        i_parent      = g_custom_c_13.


*-Tool Bar 버튼 제거 필요없는 버튼 추가.
    PERFORM exclude_of_toolbar_button_grid USING 'GT_EXCLUDE'.

    PERFORM  fill_field_category_1    USING  'GT_260'
                                     CHANGING  gt_fieldcat_13 .
    PERFORM  modify_fieldcat_1     CHANGING  gt_fieldcat_13 .

    PERFORM pro_layout_1 USING gs_layout_13.

*-- At least field REPORT of this structure has to be filled!
    gs_variant_13-handle = '0108'.
    gs_variant_13-report = sy-repid.

    CALL METHOD g_grid_13->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_13
        it_toolbar_excluding = gt_exclude
        i_save               = gs_save   " 전체가능유형.
        is_variant           = gs_variant_13  " 선택 메뉴 display
      CHANGING
        it_fieldcatalog      = gt_fieldcat_13
*       IT_SORT              = GT_SORT
        it_outtab            = gt_260[].
  ELSE.
    PERFORM g_grid_13_refresh.
  ENDIF .

*  CALL METHOD G_GRID_100->SET_TOOLBAR_INTERACTIVE.

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_13.

ENDMODULE.                 " ALV_INIT_1310_2  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_INIT_1310_3  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE alv_init_1310_3 OUTPUT.
  IF  g_custom_c_14  IS INITIAL.
    CREATE OBJECT g_custom_c_14
      EXPORTING
        container_name              = g_container_14
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_grid_14
      EXPORTING
        i_appl_events = 'X'
        i_parent      = g_custom_c_14.


*-Tool Bar 버튼 제거 필요없는 버튼 추가.
    PERFORM exclude_of_toolbar_button_grid USING 'GT_EXCLUDE'.

    PERFORM  fill_field_category_1    USING  'GT_270'
                                      CHANGING  gt_fieldcat_14 .
    PERFORM  modify_fieldcat_1     CHANGING  gt_fieldcat_14 .

    PERFORM pro_layout_1 USING gs_layout_14.

*-- At least field REPORT of this structure has to be filled!
    gs_variant_14-handle = '0001'.
    gs_variant_14-report = sy-repid.

    CALL METHOD g_grid_14->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout_14
        it_toolbar_excluding = gt_exclude
        i_save               = gs_save   " 전체가능유형.
        is_variant           = gs_variant_14  " 선택 메뉴 display
      CHANGING
        it_fieldcatalog      = gt_fieldcat_14
*       IT_SORT              = GT_SORT
        it_outtab            = gt_270[].
  ELSE.
    PERFORM g_grid_14_refresh.
  ENDIF .

*  CALL METHOD G_GRID_100->SET_TOOLBAR_INTERACTIVE.

*  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
*    EXPORTING
*      CONTROL = G_GRID_14.

ENDMODULE.                 " ALV_INIT_1310_3  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_TC_1130  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen_attribute_tc_1130 OUTPUT.

  LOOP AT SCREEN.
    IF gt_240_tc-dflg = 'X'.
      IF screen-group3 = '240'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      IF screen-group3 = '240'.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_TC_1130  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_0310  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_0310 OUTPUT.
  LOOP AT SCREEN.
    IF ( gs_100-status NE 'CL05' AND gs_100-status NE 'CL10'
       AND gs_100-status NE 'CL30' ) OR gv_trtyp = 'A'.

      IF screen-group1 = 'CNT'.
        screen-input = 0.
      ENDIF.

*{[기능개선 CHM2201-00099] 불량수량 일괄 등록 개선
*-- '납품수량 복사' - 광통신 전용 버튼
      IF screen-name EQ 'COPY_MNG' OR screen-name EQ 'COPY_CANC'.
        screen-active = 0.
      ENDIF.
*    ELSEIF GS_100-STATUS EQ 'CL10' AND GV_TRTYP EQ 'V'."FAM2201-00014
    ELSEIF gs_100-status EQ 'CL10' AND gv_trtyp NE 'A'. "FAM2201-00014

      IF gs_100-werks_h NE '1401'AND ( screen-name = 'COPY_MNG'
                                    OR screen-name = 'COPY_CANC' ).
        screen-active = 0.
      ENDIF.

    ELSE.
      IF screen-name EQ 'COPY_MNG' OR screen-name EQ 'COPY_CANC'.
        screen-active = 0.
      ENDIF.
*}[기능개선 CHM2201-00099] 2022.01.11 kmj A.C
    ENDIF.


    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " MODIFY_SCREEN_0310  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_TC_100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen_attribute_tc_100 OUTPUT.

  IF gs_100-status NE 'CL05' AND gs_100-status NE 'CL10'
     AND gs_100-status NE 'CL30'.

    LOOP AT SCREEN.
      IF screen-group1 EQ 'CNT'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_TC_100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_TC_160  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen_attribute_tc_160 OUTPUT.

  IF gv_trtyp = 'A'.

    LOOP AT SCREEN.
      IF screen-group1 EQ 'MOD'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_TC_160  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_TC_190  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen_attribute_tc_190 OUTPUT.

  IF gv_trtyp = 'A'.

    LOOP AT SCREEN.
      IF screen-group1 EQ 'MOD'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_TC_190  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIBUTE_TC_210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen_attribute_tc_210 OUTPUT.

  IF gv_trtyp = 'A'.

    LOOP AT SCREEN.
      IF screen-group1 EQ 'MOD'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDMODULE.                 " SET_SCREEN_ATTRIBUTE_TC_210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_910  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_910 OUTPUT.

  IF gv_trtyp = 'A' OR gs_100-status = 'CL40'.

    LOOP AT SCREEN.

      screen-input = 0.

      IF  g_bukrs <> '6000'.
        IF screen-name = '%#AUTOTEXT051'  OR screen-name =
        'S_910-BEAMT10'
           OR screen-name = '%#AUTOTEXT052' .
          screen-invisible = 1.
        ENDIF.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.

  ELSE.

    LOOP AT SCREEN.

      IF  g_bukrs <> '6000'.
        IF screen-name = '%#AUTOTEXT051'  OR screen-name =
        'S_910-BEAMT10'
           OR screen-name = '%#AUTOTEXT052' .
          screen-invisible = 1.
        ENDIF.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.



ENDMODULE.                 " MODIFY_SCREEN_910  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor OUTPUT.

  CLEAR : gv_curflg.

  SET CURSOR FIELD gv_cursor LINE gv_curlin.

ENDMODULE.                 " SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_0100_SM  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_0100_sm OUTPUT.
*  CHECK sy-tcode = 'ZQM2M0023'.  "기계 SM통지에 의한 생성
*
*
*  DATA : l_sm_qmnum LIKE viqmel-qmnum.
*
** 고객불만 생성용 sm통지 번호
*  GET PARAMETER ID 'ZSMRNO'  FIELD l_sm_qmnum.
*
*   GS_100-sqmnum = l_sm_qmnum.
*    CHECK l_sm_qmnum IS NOT INITIAL.
*
*
*    SET PARAMETER ID 'ZSMRNO'  FIELD ' '.
*
*
** 반드시 기계 SM통지번호를 저장할수 있어야 한다.
**    s_100-sqmnum = l_sm_qmnum.
***
***
*MOVE-CORRESPONDING GS_100 TO GS_ZQMT0011B.
*
*    CALL FUNCTION 'ZSM_CUSTOMER_COMPLAIN_DATA'
*      EXPORTING
*        i_qmnum        = l_sm_qmnum
*      IMPORTING
*        o_rcepdt       = gs_100-rcepdt
*        o_equnr        = GS_ZQMT0011B-mcno   "기계번호
*        o_serialnr     = GS_ZQMT0011B-charg  "일련번호를 BATCH에 저장
*        o_matnr        = GS_0011B-matnr
*        o_werks        = GS_ZQMT0011B-werk
*        o_kunum        = gs_100-kunum
*        o_qmtxt        = gs_100-qmtxt
*        o_spart        = gs_100-spart
*        o_vkbur        = gs_100-vkbur
*        o_vkgrp        = gs_100-vkgrp
*        o_kdauf        = gs_100-ls_kdauf
*        o_kdpos        = gs_100-ls_kdpos
*      TABLES
*        g_line         = g_lines
*        gt_100         = gt_100
*      EXCEPTIONS
*        action_stopped = 1
*        OTHERS         = 2.
*
*    IF sy-subrc <> 0.
*
*
*
*    ENDIF.



ENDMODULE.                 " INIT_0100_SM  OUTPUT
