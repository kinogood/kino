*&---------------------------------------------------------------------*
*& Include          ZGTSDR1160F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM initialization .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM selection_screen .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM selection_screen_output .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM main .
*-01. INIT OBJECTS
  PERFORM init_objects.

*-02. CHECK INPUT
  PERFORM check_input_value.

*-03. SET VALUES
  PERFORM set_values.

*-04. GET DATA
  PERFORM get_data.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_OBJECTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_objects .
  CLEAR:
         gv_change_ind,gv_objectid,
         gs_head,*gs_head,
         gv_title.

  REFRESH:
          gt_list,
          gt_data_db.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_input_value .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_values .
*-TITLE
  gv_title = TEXT-001.

  gv_edit  = gc_x.

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
  DATA: lv_length TYPE vbap-kwmeng.
  DATA: lv_zseq   TYPE zgtsdt1199-zseq.

*-01. 판매오더
  SELECT SINGLE *
    FROM vbap
   WHERE vbeln     EQ @pa_vbeln
     AND posnr     EQ @pa_posnr
     AND vkorg_ana EQ @gc_vkorg_6000
    INTO @DATA(ls_vbap).
  IF sy-subrc NE 0.
    MESSAGE s000 WITH pa_vbeln pa_posnr DISPLAY LIKE gc_e.
    LEAVE LIST-PROCESSING.
  ENDIF.


  gs_head-vbeln = ls_vbap-vbeln.
  gs_head-posnr = ls_vbap-posnr.
  gs_head-matnr = ls_vbap-matnr.
  "자재명
  gs_head-maktx = ls_vbap-arktx.


  "조장
  PERFORM get_so_characteristic(zler0401) USING ls_vbap-vbeln
                                                ls_vbap-posnr
                                                gc_length
                                                lv_length.
  "조장수
  IF ls_vbap-kwmeng NE 0 AND lv_length NE 0.
    gs_head-indqty = ls_vbap-kwmeng / lv_length.
  ENDIF.


*-02. ZGTSDT1199
  SELECT *
    FROM zgtsdt1199
   WHERE vbeln EQ @pa_vbeln
     AND posnr EQ @pa_posnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_data_db.
  SORT gt_data_db BY zseq.

  IF sy-subrc EQ 0.
    DATA(lv_lines) = lines( gt_data_db[] ).
    "조장수와 라인수 동일
    IF lv_lines EQ gs_head-indqty.
      gt_list[] = CORRESPONDING #( gt_data_db[] ).
    ENDIF.

    "조장수 > 라인수
    IF lv_lines < gs_head-indqty.
      CLEAR lv_zseq.
      lv_zseq = lv_lines.

      DO ( gs_head-indqty - lv_lines ) TIMES.
        CLEAR gs_list.
        gs_list-vbeln = gs_head-vbeln.
        gs_list-posnr = gs_head-posnr.

        lv_zseq = lv_zseq + 1.
        gs_list-zseq  = lv_zseq.

        gs_list-updkz  = gc_i.

        APPEND gs_list TO gt_list.
      ENDDO.
    ENDIF.

    "조장수 < 라인수 : 조장수보다 큰 ZSEQ 삭제 처리
    IF lv_lines > gs_head-indqty.
      gt_list[] = CORRESPONDING #( gt_data_db[] ).

      LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<fs_list>) WHERE zseq > gs_head-indqty.
        <fs_list>-updkz  = gc_d.
      ENDLOOP.

    ENDIF.

    "헤더
    DATA(ls_head) = VALUE #( gt_data_db[ 1 ] OPTIONAL ).
    IF ls_head IS NOT INITIAL.
      "라벨종류
      gs_head-zzlabel_type     = ls_head-zzlabel_type.
      "라벨장수
      gs_head-zzlabel_prtqt    = ls_head-zzlabel_prtqt.
      "라벨 TITLE 제목
      gs_head-zzlabel_title1_n = ls_head-zzlabel_title1_n.
      gs_head-zzlabel_title2_n = ls_head-zzlabel_title2_n.
      gs_head-zzlabel_title3_n = ls_head-zzlabel_title3_n.
      gs_head-zzlabel_title4_n = ls_head-zzlabel_title4_n.
    ENDIF.

    gv_change_ind = gc_u.

  ELSE.
    gs_head-zzlabel_prtqt    = 1.

    DO gs_head-indqty TIMES.
      CLEAR gs_list.
      gs_list-vbeln = gs_head-vbeln.
      gs_list-posnr = gs_head-posnr.

      lv_zseq = lv_zseq + 1.
      gs_list-zseq  = lv_zseq.

      "라벨장수
      gs_list-zzlabel_prtqt = gs_head-zzlabel_prtqt.

      gs_list-updkz  = gc_i.

      APPEND gs_list TO gt_list.
    ENDDO.



    gv_change_ind = gc_i.
  ENDIF.

  "LED
  LOOP AT gt_list ASSIGNING <fs_list>.
    PERFORM set_led CHANGING <fs_list>.
  ENDLOOP.

  *gs_head = gs_head.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .
  IF gt_list[] IS NOT INITIAL.
    CALL SCREEN 100.
  ELSE.
    MESSAGE s018.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM set_led  CHANGING ps_list LIKE gt_list.

  CASE ps_list-updkz.
    WHEN gc_i.
      ps_list-stat = icon_create.
    WHEN gc_d.
      ps_list-stat = icon_delete.
    WHEN gc_u.
      ps_list-stat = icon_change.
    WHEN OTHERS.
      CLEAR ps_list-stat.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHANGE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_LIST>
*&---------------------------------------------------------------------*
FORM set_change_data  CHANGING ps_list LIKE gt_list.
  CLEAR: gs_data_new,gs_data_old.

*-ZGTSDT1199
  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF gs_data_old
    FROM zgtsdt1199
   WHERE vbeln EQ ps_list-vbeln
     AND posnr EQ ps_list-posnr
     AND zseq  EQ ps_list-zseq.
  IF sy-subrc NE 0.
    ps_list-updkz = gc_i.

  ELSE.
    "화면 데이터
    MOVE-CORRESPONDING ps_list TO gs_data_new.

    IF gs_data_old NE gs_data_new.
      ps_list-updkz = gc_u.
    ELSE.
      CLEAR: ps_list-updkz.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data .
  DATA: lv_cnt TYPE i.

  PERFORM check_changed_data USING go_grid.

*-CHECK
  CLEAR gv_error.
  PERFORM check_data .
  IF gv_error IS NOT INITIAL.
    EXIT.
  ENDIF.

  CHECK zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space iv_messa = TEXT-p01 ) EQ gc_j.

*-SAVE DATA
  PERFORM save_data_proc.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_data .
  DATA: lv_msg(200),
        lv_msg2(100).
  DATA: lv_n(1)  TYPE n,
        lv_n2(1) TYPE n.


*-헤더필수
  "라벨종류
  IF gs_head-zzlabel_type IS INITIAL.
    gv_error = gc_x.
    lv_msg = TEXT-006.
  ENDIF.
  "라벨장수
  IF gs_head-zzlabel_prtqt IS INITIAL.
    gv_error = gc_x.
    IF lv_msg IS NOT INITIAL.
      lv_msg = |{ lv_msg }/{ TEXT-007 }|.
    ELSE.
      lv_msg = TEXT-007.
    ENDIF.
  ENDIF.

  "TITLE 제목
  IF gs_head-zzlabel_type IS NOT INITIAL.
    lv_n = gs_head-zzlabel_type.
    DO lv_n TIMES.
      lv_n2 = lv_n2 + 1.
      DATA(lv_text) = |ZZLABEL_TITLE{ lv_n2 }_N|.
      ASSIGN COMPONENT lv_text OF STRUCTURE gs_head TO FIELD-SYMBOL(<fs_val>).
      IF sy-subrc EQ 0.
        IF <fs_val> IS INITIAL.
          gv_error = gc_x.
          IF lv_msg2 IS NOT INITIAL.
            lv_msg2 = |{ lv_msg2 }/{ lv_n2 } { TEXT-008 }|.
          ELSE.
            lv_msg2 = |{ lv_n2 } { TEXT-008 }|.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR lv_text.
      IF <fs_val> IS ASSIGNED. UNASSIGN <fs_val>. ENDIF.
    ENDDO.
    IF lv_msg2 IS NOT INITIAL.
      IF lv_msg IS NOT INITIAL.
        lv_msg = |{ lv_msg }/{ lv_msg2 }|.
      ELSE.
        lv_msg = lv_msg2.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gv_error IS NOT INITIAL.
    MESSAGE ID 'ZGTSD01' TYPE gc_i NUMBER '007'
       WITH lv_msg(50) lv_msg+50(50) lv_msg+100(50) lv_msg+150(50)
       DISPLAY LIKE gc_e.
    EXIT.
  ENDIF.

  LOOP AT gt_list INTO DATA(ls_lst) WHERE updkz IS NOT INITIAL.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    gv_error = gc_x.

    MESSAGE i000 WITH TEXT-m03 DISPLAY LIKE gc_e.
    EXIT.
  ENDIF.

*  LOOP AT GT_LIST INTO DATA(LS_LIST) WHERE UPDKZ EQ GC_I
*                                        OR UPDKZ EQ GC_U.
*    IF LS_LIST-ZZLABEL_TYPE  IS NOT INITIAL  AND
*       LS_LIST-ZZLABEL_PRTQT IS NOT INITIAL.
*
*    ELSE.
*      GV_ERROR = GC_X.
*
*      MESSAGE I000 WITH TEXT-M02 DISPLAY LIKE GC_E.
*      EXIT.
*    ENDIF.
*
*  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data_proc .
  DATA: lt_save_chg TYPE TABLE OF zgtsdt1199,
        lt_save_del TYPE TABLE OF zgtsdt1199,
        ls_save     TYPE zgtsdt1199.

  DATA: lv_text(70).
  DATA: lv_i TYPE i,
        lv_u TYPE i,
        lv_d TYPE i.
  DATA: lv_text_i(10),
        lv_text_u(10),
        lv_text_d(10).

  DATA: lv_subrc TYPE sy-subrc.

  LOOP AT gt_list INTO DATA(ls_list) WHERE updkz IS NOT INITIAL.
    CLEAR ls_save.
    MOVE-CORRESPONDING ls_list TO ls_save.
    CASE ls_list-updkz.
      WHEN gc_i.
        lv_i = lv_i + 1.
        APPEND ls_save TO lt_save_chg.

      WHEN gc_u.
        lv_u = lv_u + 1.
        APPEND ls_save TO lt_save_chg.

      WHEN gc_d.
        lv_d = lv_d + 1.
        APPEND ls_save TO lt_save_del.

    ENDCASE.

  ENDLOOP.

  zgtsd_cl_common2=>get_timestamp_multi( CHANGING it_value = lt_save_chg[] ).
  zgtsd_cl_common2=>get_timestamp_multi( CHANGING it_value = lt_save_del[] ).

  WRITE: lv_i TO lv_text_i UNIT 'EA'.CONDENSE lv_text_i.
  WRITE: lv_u TO lv_text_u UNIT 'EA'.CONDENSE lv_text_u.
  WRITE: lv_d TO lv_text_d UNIT 'EA'.CONDENSE lv_text_d.

  lv_text = |[{ TEXT-002 }{ lv_text_i } { TEXT-005 }, { TEXT-003 }{ lv_text_u } { TEXT-005 }, { TEXT-004 }{ lv_text_d } { TEXT-005 }]|.

*-저장
  lv_subrc = 0.

  TRY.
      IF lt_save_del[] IS NOT INITIAL.
        DELETE zgtsdt1199 FROM TABLE lt_save_del.
        IF sy-subrc NE 0.
          lv_subrc = 4.
        ENDIF.
      ENDIF.

      IF lt_save_chg[] IS NOT INITIAL AND lv_subrc EQ 0.
        MODIFY zgtsdt1199 FROM TABLE lt_save_chg.
        IF sy-subrc NE 0.
          lv_subrc = 4.
        ENDIF.
      ENDIF.

    CATCH cx_root INTO DATA(lo_ref).
      DATA(lv_msg) = lo_ref->get_text( ).
      lv_subrc = 4.
  ENDTRY.

  IF lv_subrc EQ 0.
    "CHANGE DOCUMENT
    PERFORM write_change_document TABLES lt_save_chg
                                         lt_save_del.

    COMMIT WORK AND WAIT.
    MESSAGE i000 WITH TEXT-s01
                      lv_text
                 DISPLAY LIKE gc_s.

    PERFORM rebuild_list.

  ELSE.
    ROLLBACK WORK.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form WRITE_CHANGE_DOCUMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM write_change_document TABLES pt_save_chg STRUCTURE zgtsdt1199
                                  pt_save_del STRUCTURE zgtsdt1199.
  DATA: lt_xdata TYPE TABLE OF yzgtsdt1199,
        ls_xdata TYPE yzgtsdt1199,
        lt_ydata TYPE TABLE OF yzgtsdt1199,
        ls_ydata TYPE yzgtsdt1199.
  DATA: ls_timestamp TYPE zsds_snop_times.

  CLEAR:gv_erdat,gv_erzet,gv_tcode,gv_uname.


  IF pt_save_chg[] IS NOT INITIAL.
    DATA(ls_save) = VALUE #( pt_save_chg[ 1 ] OPTIONAL ).
    IF ls_save-aedat IS NOT INITIAL.
      gv_erdat = ls_save-aedat.
      gv_erzet = ls_save-aezet.
    ELSE.
      gv_erdat = ls_save-erdat.
      gv_erzet = ls_save-erzet.
    ENDIF.

    gv_objectid   = |{ ls_save-vbeln }{ ls_save-posnr }|.
  ENDIF.

  IF pt_save_del[] IS NOT INITIAL.
    CLEAR:ls_save.
    ls_save = VALUE #( pt_save_del[ 1 ] OPTIONAL ).
    IF ls_save-aedat IS NOT INITIAL.
      gv_erdat = ls_save-aedat.
      gv_erzet = ls_save-aezet.
    ELSE.
      gv_erdat = ls_save-erdat.
      gv_erzet = ls_save-erzet.
    ENDIF.
    gv_objectid   = |{ ls_save-vbeln }{ ls_save-posnr }|.
  ENDIF.

*-신규
  IF gv_change_ind EQ gc_i.
    LOOP AT pt_save_chg INTO DATA(ls_chg).
      CLEAR:ls_xdata.
      MOVE-CORRESPONDING ls_chg       TO ls_xdata.
      MOVE-CORRESPONDING ls_timestamp TO ls_xdata.  "날짜시간 CLEAR
      ls_xdata-mandt = sy-mandt.
      ls_xdata-kz = gc_i.
      APPEND ls_xdata TO lt_xdata.
    ENDLOOP.
  ENDIF.

*-변경
  IF gv_change_ind EQ gc_u.
    LOOP AT pt_save_chg INTO ls_chg.
      "NEW
      CLEAR:ls_xdata.
      MOVE-CORRESPONDING ls_chg       TO ls_xdata.
      MOVE-CORRESPONDING ls_timestamp TO ls_xdata.  "날짜시간 CLEAR
      ls_xdata-kz = gc_u.
      APPEND ls_xdata TO lt_xdata.

      "OLD
      CLEAR: ls_ydata.
      ls_ydata = VALUE #( gt_data_db[ vbeln = ls_chg-vbeln posnr = ls_chg-posnr zseq = ls_chg-zseq ] OPTIONAL ).
      IF ls_ydata IS NOT INITIAL.
        MOVE-CORRESPONDING ls_timestamp TO ls_ydata.  "날짜시간 CLEAR
        APPEND ls_ydata TO lt_ydata.
      ENDIF.
    ENDLOOP.

    LOOP AT pt_save_del INTO DATA(ls_del).
      "NEW
      CLEAR:ls_xdata.
      MOVE-CORRESPONDING ls_del       TO ls_xdata.
      MOVE-CORRESPONDING ls_timestamp TO ls_xdata.  "날짜시간 CLEAR
      ls_xdata-kz = gc_d.
      APPEND ls_xdata TO lt_xdata.

      "OLD
      CLEAR: ls_ydata.
      ls_ydata = VALUE #( gt_data_db[ vbeln = ls_chg-vbeln posnr = ls_chg-posnr zseq = ls_chg-zseq ] OPTIONAL ).
      IF ls_ydata IS NOT INITIAL.
        MOVE-CORRESPONDING ls_timestamp TO ls_ydata.  "날짜시간 CLEAR
        APPEND ls_ydata TO lt_ydata.
      ENDIF.
    ENDLOOP.

  ENDIF.

  CHECK lt_xdata[] IS NOT INITIAL.

  CALL FUNCTION 'ZGTSDT1199CHDO1_WRITE_DOCUMENT' IN UPDATE TASK
    EXPORTING
      objectid                = gv_objectid
      tcode                   = sy-tcode
      utime                   = gv_erzet
      udate                   = gv_erdat
      username                = sy-uname
      object_change_indicator = gv_change_ind
      upd_zgtsdt1199          = gv_change_ind
    TABLES
      xzgtsdt1199             = lt_xdata
      yzgtsdt1199             = lt_ydata.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form REBUILD_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM rebuild_list .
  PERFORM main.
  PERFORM cell_attributes_0100.
  PERFORM refresh_alv USING go_grid.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_list .
  PERFORM main.
  PERFORM cell_attributes_0100.
  PERFORM refresh_alv USING go_grid.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DEL_MARK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_del_mark .
  DATA: lv_cnt TYPE i.

*-선택 라인
  PERFORM get_selected_rows USING go_grid.
  IF gt_rows[] IS INITIAL.
    MESSAGE s000 WITH TEXT-m04 DISPLAY LIKE gc_e.
    EXIT.
  ENDIF.

*-SET 삭제지시자
  LOOP AT gt_rows INTO gs_rows.
    READ TABLE gt_list ASSIGNING FIELD-SYMBOL(<fs_list>) INDEX gs_rows-index.
    IF sy-subrc        EQ 0     AND
       <fs_list>-updkz NE gc_i  AND
       <fs_list>-lvorm EQ space.

      <fs_list>-lvorm = gc_x.
      "변경 체크
      PERFORM set_change_data CHANGING <fs_list>.
      PERFORM set_led CHANGING <fs_list>.
      PERFORM set_attributes_line CHANGING <fs_list>.

      lv_cnt = lv_cnt + 1.
    ENDIF.
  ENDLOOP.

*-처리 결과
  IF lv_cnt > 0.
    PERFORM refresh_alv USING go_grid.
  ELSE.
    MESSAGE s000 WITH TEXT-m05 DISPLAY LIKE gc_e.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UNDO_DEL_MARK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM undo_del_mark .
  DATA: lv_cnt TYPE i.

*-선택 라인
  PERFORM get_selected_rows USING go_grid.
  IF gt_rows[] IS INITIAL.
    MESSAGE s000 WITH TEXT-m04 DISPLAY LIKE gc_e.
    EXIT.
  ENDIF.

*-삭제지시자 CLEAR
  LOOP AT gt_rows INTO gs_rows.
    READ TABLE gt_list ASSIGNING FIELD-SYMBOL(<fs_list>) INDEX gs_rows-index.
    IF sy-subrc        EQ 0     AND
       <fs_list>-updkz NE gc_i  AND
       <fs_list>-lvorm NE space.

      CLEAR:<fs_list>-lvorm.
      "변경 체크
      PERFORM set_change_data CHANGING <fs_list>.
      PERFORM set_led CHANGING <fs_list>.
      PERFORM set_attributes_line CHANGING <fs_list>.

      lv_cnt = lv_cnt + 1.

    ENDIF.

  ENDLOOP.

*-처리 결과
  IF lv_cnt > 0.
    PERFORM refresh_alv USING go_grid.

  ELSE.
    MESSAGE s000 WITH TEXT-m06 DISPLAY LIKE gc_e.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXIT_PROCESS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exit_process .
  DATA: lv_chk(1).

*-01. 변경사항 체크
  LOOP AT gt_list INTO DATA(ls_list) WHERE updkz NE space.
    lv_chk = gc_x.
    EXIT.
  ENDLOOP.

  IF lv_chk EQ gc_x.
    CHECK zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space
                                             iv_messa = TEXT-p02 ) EQ gc_j.
  ENDIF.

  PERFORM init_controls.
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_ITEM_ATTR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM change_item_attr .
  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<fs_list>).
    "라벨종류
    <fs_list>-zzlabel_type  = gs_head-zzlabel_type.
    "라벨장수
    <fs_list>-zzlabel_prtqt = gs_head-zzlabel_prtqt.

    "TITLE 제목
    <fs_list>-zzlabel_title1_n = gs_head-zzlabel_title1_n.
    <fs_list>-zzlabel_title2_n = gs_head-zzlabel_title2_n.
    <fs_list>-zzlabel_title3_n = gs_head-zzlabel_title3_n.
    <fs_list>-zzlabel_title4_n = gs_head-zzlabel_title4_n.

    "변경 체크
    PERFORM set_change_data CHANGING <fs_list>.
    "ICON
    PERFORM set_led CHANGING <fs_list>.
    "ITEM CELL ATTRIBUTES
    PERFORM set_attributes_line CHANGING <fs_list>.
  ENDLOOP.
  PERFORM refresh_alv USING go_grid.
ENDFORM.
