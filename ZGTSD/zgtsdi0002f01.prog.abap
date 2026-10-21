*&---------------------------------------------------------------------*
*& Include          ZGTSDI0002F01
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
  CHECK p_call = ' '. .
  s_targ-low = gc_kpcm.
  __rng s_targ 'I' 'EQ' s_targ-low s_targ-high.

  s_erdat-low = sy-datlo.
  s_erdat-high = sy-datlo.
  __rng s_erdat 'I' 'EQ' s_erdat-low s_erdat-high.
  s_erdat2[] = s_erdat[].
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_screen .

  LOOP AT SCREEN.

    CASE screen-name.
      WHEN 'S_TARG-LOW'.
        screen-required = 2.
      WHEN OTHERS.
    ENDCASE.

    CASE screen-group1.
      WHEN 'M1'.
        IF rb_disp = gc_x.
          screen-active = 0.
        ENDIF.
      WHEN 'M2'.
        IF rb_send = gc_x.
          screen-active = 0.
        ENDIF.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_input_data .

  CLEAR gv_error.

  "기본 필수입력 필드 체크
*  IF S_KUNNR[] IS INITIAL. "
*    MESSAGE S055(00) DISPLAY LIKE ZGTSD_E.
*    GV_ERROR = ZGTSD_X.
*    RETURN.
*  ENDIF.
  IF rb_disp = gc_x AND s_targ[] IS INITIAL.
    IF s_targ[] IS INITIAL. "
      MESSAGE s007 WITH %_s_targ_%_app_%-text DISPLAY LIKE zgtsd_e.
      gv_error = zgtsd_x.
      RETURN.
    ENDIF.
  ENDIF.

* [GO-SD][26.02.09] 가온전선 로직 분리  - Start.
  CLEAR: gv_go.
  IF gv_error IS INITIAL.

    IF     rb_send = gc_x.
      IF rb_gp = gc_x OR
         rb_go = gc_x.
        gv_go = gc_x.
      ENDIF.

    ELSEIF rb_disp = gc_x.
      DATA(ls_tar) = VALUE #( s_targ[ 1 ]-low  OPTIONAL ).

      IF ls_tar = gc_kgom OR     " 가온통신 MES
         ls_tar = gc_kgpm.       " 가온전력 MES
        gv_go = gc_x.
      ENDIF.

    ENDIF.

  ENDIF.
* [GO-SD][26.02.09] 가온전선 로직 분리  - Start.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM authority_check .

*  "권한 체크
*  ZGTSD_CL_COMMON=>AUTHORITY_CHECK( EXPORTING IV_OBJECT     = 'VKO'
*                                              IV_AUTH_FIELD = CONV XUFIELD( |VKORG| )
*                                              IV_AUTH_VAL   = CONV XUVAL( P_VKORG )
*                                    IMPORTING EV_MTYPE      = DATA(LV_MTYPE)
*                                              EV_MSGTX      = DATA(LV_MSGTX) ).
*  IF LV_MTYPE = GC_E.
*    MESSAGE S001(00) WITH LV_MSGTX DISPLAY LIKE GC_E.
*    LEAVE LIST-PROCESSING.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_QUERY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM data_query .
  CONSTANTS  : lc_str TYPE char01 VALUE '#'.
  DATA : lt_vbeln    LIKE TABLE OF gs_s0100,
         lt_for      LIKE TABLE OF gs_s0100 WITH EMPTY KEY,
         lt_conf_out TYPE TABLE OF conf_out WITH HEADER LINE,
         lv_cnt      TYPE n LENGTH 3.

  RANGES : lr_targ FOR zgtsdt1002-zsystem_id,
           lr_fld   FOR zgtsdt1005-atnam,
           lr_auart FOR vbak-auart,
           lr_vkorg FOR vbak-vkorg,
           lr_vtweg FOR vbak-vtweg,
           lr_spart FOR vbak-spart.

  CLEAR gv_error.
  __cle : gt_s0100, gt_item, gt_char, gt_partner, gr_atnam,
          gr_werks, gr_vstel. "GT_HEADER

  IF rb_disp = gc_x.
    lr_targ[] = s_targ[].
  ELSE.
    CASE gc_x.
      WHEN rb_t1.
        gv_tar = gc_kpcm.
*      WHEN RB_T2.
*        GV_TAR = GC_KBDM.
      WHEN rb_10.
        gv_tar = gc_kscm. "소재MOM

*[S] 한미소
      WHEN rb_11.
        gv_tar = gc_kmom.
*[E] 한미소

    ENDCASE.
    __rng lr_targ 'I' 'EQ' gv_tar ''.
  ENDIF.

  SELECT zgtppt1010~* INTO TABLE @DATA(lt_code)
    FROM zgtppt1010
   WHERE module_kind EQ 'SD'
     AND codegrp IN ('1010','1020')
     AND fld_01  IN @lr_targ.
  IF sy-subrc NE 0.
    MESSAGE s000 WITH TEXT-e01 DISPLAY LIKE gc_e.
    gv_error = gc_x.EXIT.
  ENDIF.

  SELECT DISTINCT @zgtsd_i AS sign, @zgtsd_eq AS option, fld_03 AS low
    FROM zgtppt1010
   WHERE module_kind EQ 'PP'
     AND codegrp EQ '0010'
     AND fld_01  IN @lr_targ
    INTO CORRESPONDING FIELDS OF TABLE @gr_werks.


  LOOP AT lt_code INTO DATA(ls_code).

    CASE ls_code-codegrp.
      WHEN '1010'.
        lr_vkorg[] = VALUE #( BASE lr_vkorg[] ( sign   = 'I'
                                                option = 'EQ'
                                                low    = ls_code-fld_03 ) ).

        lr_vtweg[] = VALUE #( BASE lr_vtweg[] ( sign   = 'I'
                                                option = 'EQ'
                                                low    = ls_code-fld_04 ) ).

        lr_spart[] = VALUE #( BASE lr_spart[] ( sign   = 'I'
                                                option = 'EQ'
                                                low    = ls_code-fld_05 ) ).
      WHEN '1020'.
        CASE ls_code-fld_03.
          WHEN 'AUART'.
            lr_auart[] = VALUE #( BASE lr_auart[] ( sign   = 'I'
                                                    option = 'EQ'
                                                    low    = ls_code-fld_04 ) ).
          WHEN 'ATNAM'.
            gr_atnam[] = VALUE #( BASE gr_atnam[] ( sign   = 'I'
                                                    option = 'EQ'
                                                    low    = ls_code-fld_04 ) ).
          WHEN 'VSTEL'.
            gr_vstel[] = VALUE #( BASE gr_vstel[] ( sign   = 'I'
                                                    option = 'EQ'
                                                    low    = ls_code-fld_04 ) ).
        ENDCASE.

    ENDCASE.

  ENDLOOP.

  IF rb_send = gc_x.

*  생성/변경일자 기준으로 거래처 코드의 변경 이력을 발췌함
    SELECT cdhdr~* INTO TABLE @DATA(lt_cdhr)
      FROM cdhdr
     WHERE udate      IN @s_erdat
       AND objectid   IN @s_vbeln
       AND objectclas = 'VERKBELEG'.
*       AND CHANGE_IND IN ('I','U').

    SORT lt_cdhr BY objectid changenr ASCENDING utime DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_cdhr COMPARING objectid changenr.
    IF lt_cdhr[] IS NOT INITIAL.
      SELECT b~vbeln, b~kunnr, b~auart, b~vkorg, b~vtweg, b~spart, b~vkgrp, b~vkbur,
             b~audat, b~vdatu, b~erdat, b~ernam, b~ctlpc, b~erzet,
             b~zpjno, d~zptxt, a~utime AS aezet, a~changenr,  a~udate AS aedat,
             e~name1, f~vtext AS spart_nm, g~bezei AS vkbur_nm,
             h~bezei AS vkgrp_nm, i~rtext AS ctlpc_nm, @icon_change AS crud
        FROM @lt_cdhr AS a INNER JOIN vbak AS b
          ON a~objectid = b~vbeln
*       INNER JOIN VBAP AS C
*          ON B~VBELN = C~VBELN
*        LEFT OUTER JOIN VBKD AS VD
*          ON B~VBELN = VD~VBELN
*         AND C~POSNR = VD~POSNR
        LEFT OUTER JOIN zsd0106t AS d
          ON b~zpjno = d~zpjno
        LEFT OUTER JOIN kna1 AS e
          ON b~kunnr = e~kunnr
        LEFT OUTER JOIN tspat AS f
          ON b~spart = f~spart
         AND f~spras = @sy-langu
        LEFT OUTER JOIN tvkbt AS g
          ON b~vkbur = g~vkbur
         AND g~spras = @sy-langu  "TVGRT
        LEFT OUTER JOIN tvgrt AS h
          ON b~vkgrp = h~vkgrp
         AND h~spras = @sy-langu
        LEFT OUTER JOIN t691t AS i
          ON b~kkber = i~kkber
         AND b~ctlpc = i~ctlpc
         AND i~spras = @sy-langu
       WHERE b~vbeln IN @s_vbeln
         AND b~vkorg IN @lr_vkorg
         AND b~vtweg IN @lr_vtweg
         AND b~spart IN @lr_spart
         AND b~auart IN @lr_auart
*         AND C~WERKS IN @GR_WERKS
*         AND C~VSTEL IN @GR_VSTEL
        INTO CORRESPONDING FIELDS OF TABLE @lt_vbeln.
    ENDIF.

    SELECT b~vbeln, b~kunnr, b~auart, b~vkorg, b~vtweg, b~spart, b~vkgrp, b~vkbur,
           b~audat, b~vdatu, b~erdat, b~ernam, b~ctlpc, b~erzet,
           b~zpjno, d~zptxt, b~erzet AS aezet, b~erdat AS aedat, "B~AEDAT,
           e~name1, f~vtext AS spart_nm, g~bezei AS vkbur_nm,
           h~bezei AS vkgrp_nm, i~rtext AS ctlpc_nm, @icon_create AS crud
      FROM vbak AS b
*      LEFT OUTER JOIN VBKD AS VD
*        ON B~VBELN = VD~VBELN
      LEFT OUTER JOIN zsd0106t AS d
        ON b~zpjno = d~zpjno
      LEFT OUTER JOIN kna1 AS e
        ON b~kunnr = e~kunnr
      LEFT OUTER JOIN tspat AS f
        ON b~spart = f~spart
       AND f~spras = @sy-langu
      LEFT OUTER JOIN tvkbt AS g
        ON b~vkbur = g~vkbur
       AND g~spras = @sy-langu  "TVGRT
      LEFT OUTER JOIN tvgrt AS h
        ON b~vkgrp = h~vkgrp
       AND h~spras = @sy-langu
      LEFT OUTER JOIN t691t AS i
        ON b~kkber = i~kkber
       AND b~ctlpc = i~ctlpc
       AND i~spras = @sy-langu
     WHERE b~vbeln IN @s_vbeln
       AND b~vkorg IN @lr_vkorg
       AND b~vtweg IN @lr_vtweg
       AND b~spart IN @lr_spart
       AND b~auart IN @lr_auart
       AND b~erdat IN @s_erdat

      APPENDING CORRESPONDING FIELDS OF TABLE @lt_vbeln.

*-- Condition 변경이력 기준 S/O 정보 추가 Select
    WITH +so_head AS ( SELECT a~vbeln, a~kunnr, a~auart, a~vkorg, a~vtweg, a~spart, a~vkgrp, a~vkbur,
                              a~audat, a~vdatu, a~erdat, a~ernam, a~ctlpc, a~erzet, a~zpjno, a~kkber,
                              CAST( substring( CAST( a~upd_tmstmp AS CHAR ) ,1 ,8 ) AS DATS ) AS aedat,
                              CAST( substring( CAST( a~upd_tmstmp AS CHAR ) ,9 ,6 ) AS TIMS ) AS aezet
                         FROM vbak AS a
                        WHERE a~vbeln IN @s_vbeln
                          AND a~vkorg IN @lr_vkorg
                          AND a~vtweg IN @lr_vtweg
                          AND a~spart IN @lr_spart
                          AND a~auart IN @lr_auart )

     SELECT a~vbeln, a~kunnr, a~auart, a~vkorg, a~vtweg, a~spart, a~vkgrp, a~vkbur,
            a~audat, a~vdatu, a~erdat, a~ernam, a~ctlpc, a~erzet, a~zpjno, a~aedat, a~aezet,
            d~zptxt, e~name1, f~vtext AS spart_nm, g~bezei AS vkbur_nm,
            h~bezei AS vkgrp_nm, i~rtext AS ctlpc_nm, @icon_create AS crud
       FROM +so_head AS a

                     LEFT OUTER JOIN zsd0106t AS d
                             ON a~zpjno EQ d~zpjno
                     LEFT OUTER JOIN kna1 AS e
                             ON a~kunnr EQ e~kunnr
                     LEFT OUTER JOIN tspat AS f
                             ON a~spart EQ f~spart
                            AND f~spras EQ @sy-langu
                     LEFT OUTER JOIN tvkbt AS g
                             ON a~vkbur EQ g~vkbur
                            AND g~spras EQ @sy-langu  "TVGRT
                     LEFT OUTER JOIN tvgrt AS h
                             ON a~vkgrp EQ h~vkgrp
                            AND h~spras EQ @sy-langu
                     LEFT OUTER JOIN t691t AS i
                             ON a~kkber EQ i~kkber
                            AND a~ctlpc EQ i~ctlpc
                            AND i~spras EQ @sy-langu
      WHERE a~aedat IN @s_erdat
        AND a~erdat NE a~aedat        "-> 생성일과 변경이력 정보와 다른 일자만 가져옴

      APPENDING CORRESPONDING FIELDS OF TABLE @lt_vbeln.

**********************************************************************
    PERFORM get_detail_data TABLES lt_vbeln lt_cdhr.
**********************************************************************

    SELECT b~*
      FROM @lt_vbeln AS a INNER JOIN zgtsdt1003 AS b
        ON a~vbeln = b~vbeln
     WHERE b~zsystem_id = @gv_tar
       AND b~aedat     IN @s_erdat
       AND b~zstat     IN ('0','00')
      INTO TABLE @DATA(lt_log_h).

  ELSE.

    SELECT a~*, e~name1, f~vtext AS spart_nm, g~bezei AS vkbur_nm,
           h~bezei AS vkgrp_nm, i~rtext AS ctlpc_nm, b~erzet
      INTO CORRESPONDING FIELDS OF TABLE @lt_vbeln
      FROM zgtsdt1003 AS a LEFT OUTER JOIN vbak AS b
        ON a~vbeln = b~vbeln
      LEFT OUTER JOIN kna1 AS e
        ON b~kunnr = e~kunnr
      LEFT OUTER JOIN tspat AS f
        ON b~spart = f~spart
       AND f~spras = @sy-langu
      LEFT OUTER JOIN tvkbt AS g
        ON b~vkbur = g~vkbur
       AND g~spras = @sy-langu  "TVGRT
      LEFT OUTER JOIN tvgrt AS h
        ON a~vkgrp = h~vkgrp
       AND h~spras = @sy-langu
      LEFT OUTER JOIN t691t AS i
        ON b~kkber = i~kkber
       AND b~ctlpc = i~ctlpc
       AND i~spras = @sy-langu
     WHERE a~vbeln    IN @s_vbeln
       AND zsystem_id IN @lr_targ
       AND a~ifdat    IN @s_erdat2.

    CASE gc_x.
      WHEN rb_su.
        DELETE lt_vbeln WHERE zstat NE '00' AND zstat NE '0'.
      WHEN rb_fa.
        DELETE lt_vbeln WHERE zstat = '00' OR zstat = '0'.
    ENDCASE.

    lt_for[] = lt_vbeln[].
    SORT lt_for BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_for COMPARING vbeln.
    IF lt_for[] IS NOT INITIAL.
      SELECT b~*
        FROM @lt_for AS a INNER JOIN cdhdr AS b
          ON a~vbeln = b~objectid
         AND a~aedat = b~udate
       WHERE objectclas = 'VERKBELEG'
        INTO TABLE @lt_cdhr.
    ENDIF.

**********************************************************************
    PERFORM get_detail_data_log TABLES lt_vbeln.
**********************************************************************

  ENDIF.

  lt_for = lt_vbeln[].
  SORT lt_for BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING vbeln.
  IF lt_for[] IS NOT INITIAL.
    SELECT vbeln, bstkd INTO TABLE @DATA(lt_vbkd)
      FROM vbkd
       FOR ALL ENTRIES IN @lt_for
     WHERE vbeln = @lt_for-vbeln.
  ENDIF.

  SORT lt_log_h BY vbeln.
  SORT lt_vbeln BY vbeln.
  SORT lt_vbkd  BY vbeln.
  SORT lt_cdhr  BY objectid changenr.

  LOOP AT lt_vbeln INTO DATA(ls_va).

    CLEAR gs_s0100.
    MOVE-CORRESPONDING ls_va TO gs_s0100.
    IF gs_s0100-zptxt IS NOT INITIAL.
      DATA(lv_len) = strlen( gs_s0100-zptxt ).
      lv_len -= 1.
      FIND REGEX '[^[:alnum:]]' IN gs_s0100-zptxt+lv_len(1) IN CHARACTER MODE.
      IF sy-subrc = 0.
        CONCATENATE gs_s0100-zptxt(lv_len) '' INTO gs_s0100-zptxt.
      ENDIF.
    ENDIF.

    READ TABLE lt_vbkd INTO DATA(ls_vbkd) WITH KEY vbeln = ls_va-vbeln BINARY SEARCH.
    IF sy-subrc = 0.
      gs_s0100-bstkd = ls_vbkd-bstkd.
    ENDIF.

    READ TABLE gt_item INTO DATA(ls_item) WITH KEY k_key COMPONENTS vbeln = gs_s0100-vbeln.
    IF sy-subrc = 0.
      gs_s0100-posnr = ls_item-posnr.
      gs_s0100-matnr = ls_item-matnr.
      gs_s0100-werks = ls_item-werks.
*      IF LS_ITEM-ZFLAG = 'D' AND GS_S0100-POSNR IS NOT INITIAL.
*        GS_S0100-MSG = TEXT-M04.
*        GS_S0100-STATU = ICON_DELETE.
*      ENDIF.
    ENDIF.

    IF gs_s0100-msg IS INITIAL.
      READ TABLE lt_vbeln INTO DATA(ls_vbeln) WITH KEY vbeln = ls_va-vbeln BINARY SEARCH.
      IF sy-subrc = 0.
        gs_s0100-name1    = ls_vbeln-name1.
        gs_s0100-vkgrp_nm = ls_vbeln-vkgrp_nm.
        gs_s0100-vkbur_nm = ls_vbeln-vkbur_nm.
        gs_s0100-spart_nm = ls_vbeln-spart_nm.
        gs_s0100-ctlpc_nm = ls_vbeln-ctlpc_nm.
      ENDIF.

      gs_s0100-statu = icon_led_inactive.
    ENDIF.

    CASE gc_x.
      WHEN rb_send.

        IF rb_t1 = 'X'.
          READ TABLE lt_log_h INTO DATA(ls_log) WITH KEY vbeln = ls_va-vbeln BINARY SEARCH.
          IF sy-subrc = 0 AND ls_log-zstat = |00| OR ls_log-zstat = |0|.
            CONTINUE.
          ENDIF.
        ENDIF.

        READ TABLE lt_cdhr INTO DATA(ls_cdhr) WITH KEY objectid = ls_va-vbeln
                                                       changenr = ls_va-changenr BINARY SEARCH.
        IF sy-subrc = 0.
          gs_s0100-aezet    = ls_cdhr-utime.
          gs_s0100-changenr = ls_cdhr-changenr.
        ENDIF.
        CLEAR ls_cdhr.

      WHEN OTHERS.

        CASE gs_s0100-zstat.
          WHEN '00' OR '0'.
            gs_s0100-statu = icon_led_green.
          WHEN '01'.
            gs_s0100-statu = icon_led_red.
        ENDCASE.
        gs_s0100-msg   = ls_va-zmessage.

    ENDCASE.

    CASE gc_x.
      WHEN rb_t1.
        gs_s0100-zsystem_id = gc_kpcm.
        gs_s0100-system_nm  = TEXT-s06.
*      WHEN RB_T2.
*        GS_S0100-ZSYSTEM_ID = GC_KBDM.
*        GS_S0100-SYSTEM_NM  = TEXT-S07.
      WHEN rb_10.
        gs_s0100-zsystem_id = gc_kscm.
        gs_s0100-system_nm  = TEXT-s12.

*[S] 한미소
      WHEN rb_11.
        gs_s0100-zsystem_id = gc_kmom.
        gs_s0100-system_nm  = TEXT-s15.
*[E] 한미소

    ENDCASE.

    APPEND gs_s0100 TO gt_s0100.
    CLEAR : ls_item, ls_log, ls_vbeln, ls_vbeln.

  ENDLOOP.

**********************************************************************
  "데이타 건수 메시지 출력
  IF gt_s0100 IS NOT INITIAL.
    MESSAGE s009 WITH |{ lines( gt_s0100 ) NUMBER = USER }|. "& 건 검색되었습니다.
  ELSE.
    MESSAGE s010.                                           "조회할 데이타가 없습니다.
    gv_error = gc_x.                                        "데이타 없으면 출력 X
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GO_CON
*&      <-- GO_GRID
*&---------------------------------------------------------------------*
FORM init_alv_0100  CHANGING po_dcon TYPE REF TO cl_gui_docking_container
                             po_grid TYPE REF TO cl_gui_alv_grid.

  "Create Main Container
  PERFORM create_doc_container CHANGING po_dcon.

  "Split
  go_split = NEW #( parent = po_dcon rows = 2 columns = 1 ).

  go_con_top       = go_split->get_container( row = 1 column = 1 ).
  DATA(lo_con_btt) = go_split->get_container( row = 2 column = 1 ).

  go_split->set_row_height( id = 1 height = 15 ).

  "Create Object
  go_docu = NEW #( style = 'ALV_GRID' ).  "Top-Of-Page

  PERFORM create_alv USING    lo_con_btt
                     CHANGING po_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_DOC_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_doc_container CHANGING po_dcon TYPE REF TO cl_gui_docking_container.

  CREATE OBJECT po_dcon
    EXPORTING
      parent                      = cl_gui_container=>default_screen
      repid                       = sy-repid
      dynnr                       = sy-dynnr
      side                        = cl_gui_docking_container=>dock_at_top
      extension                   = 3000
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_alv CHANGING po_con
                         po_grid TYPE REF TO cl_gui_alv_grid.

  CREATE OBJECT po_grid
    EXPORTING
      i_parent          = po_con
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ATTRIBUTES_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_attributes_0100 .

  "Layout 지정
  PERFORM set_grid_layout USING zgtsd_x space zgtsd_d.

  "Field Catalog
  PERFORM set_fieldcatalog.

  "Toolbar 제외
  PERFORM exclude_toolbar TABLES gt_toolbar.

  "Event Handler 등록
  PERFORM create_event_receiver USING go_grid.

  "F4 필드 등록
  PERFORM register_f4_fields.

  "SORT
  PERFORM set_alv_sort CHANGING gt_sort.

  "Top-Of-Page Event 등록
  PERFORM set_top_of_page_event.

  "ALV Grid Display
  PERFORM set_table_for_first_display USING go_grid
                                            gt_s0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GRID_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_grid_layout USING pv_cwopt
                           pv_stylefname
                           pv_sel_mode.

  CLEAR gs_layout.
  gs_layout = VALUE #( sel_mode   = pv_sel_mode
                       zebra      = zgtsd_x
                       cwidth_opt = pv_cwopt
                       stylefname = pv_stylefname ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog .

  "Get Field Catalog
  PERFORM get_field_catalog USING gt_s0100 CHANGING gt_fcat.

  "Set Field Catalog
  PERFORM set_fieldcatalog_main.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_field_catalog USING pt_table TYPE table
                    CHANGING pt_fcat TYPE lvc_t_fcat.

  REFRESH pt_fcat.

  pt_fcat = zgtsd_cl_common=>get_field_catalog( it_table = pt_table
                                                iv_cells = zgtsd_x
                                                iv_cellc = zgtsd_x ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG_MAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog_main .


  SORT gt_fcat BY fieldname.

  IF rb_disp = gc_x.
    PERFORM reset_field_catalog TABLES gt_fcat USING :
        'S' 'FIELDNAME'   'ZIFKEY',
        ' ' 'COLTEXT'     TEXT-f00,
        ' ' 'ICON'        'X',
        ' ' 'OUTPUTLEN'   '10',
        'E' 'KEY'         'X'.
  ENDIF.

  PERFORM reset_field_catalog TABLES gt_fcat USING :
      'S' 'FIELDNAME'   'STATU',
      ' ' 'COLTEXT'     TEXT-f01,
      ' ' 'ICON'        'X',
      ' ' 'OUTPUTLEN'   '10',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'MSG',
      ' ' 'COLTEXT'     TEXT-f02,
      ' ' 'OUTPUTLEN'   '20',
      'E' 'KEY'         'X',

      'S' 'FIELDNAME'   'AEDAT',
      ' ' 'COLTEXT'     TEXT-f26,
      ' ' 'KEY'         'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'AEZET',
      ' ' 'COLTEXT'     TEXT-f27,
      ' ' 'KEY'         'X',
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VBELN',
      ' ' 'COLTEXT'     TEXT-f05,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'CRUD',
      ' ' 'COLTEXT'     TEXT-f31,
      ' ' 'ICON'        'X',
      'E' 'OUTPUTLEN'   '4',

      'S' 'FIELDNAME'   'ZSYSTEM_ID',
      ' ' 'COLTEXT'     TEXT-f03,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'SYSTEM_NM',
      ' ' 'COLTEXT'     TEXT-f04,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'KUNNR',
      ' ' 'COLTEXT'     TEXT-f06,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'NAME1',
      ' ' 'COLTEXT'     TEXT-f07,
      'E' 'OUTPUTLEN'   '20',

      'S' 'FIELDNAME'   'AUART',
      ' ' 'COLTEXT'     TEXT-f08,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VKORG',
      ' ' 'COLTEXT'     TEXT-f09,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VTWEG',
      ' ' 'COLTEXT'     TEXT-f10,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'SPART',
      ' ' 'COLTEXT'     TEXT-f11,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'SPART_NM',
      ' ' 'COLTEXT'     TEXT-f12,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VKGRP',
      ' ' 'COLTEXT'     TEXT-f13,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VKGRP_NM',
      ' ' 'COLTEXT'     TEXT-f14,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VKBUR',
      ' ' 'COLTEXT'     TEXT-f15,
      'E' 'OUTPUTLEN'   '10',

      'S' 'FIELDNAME'   'VKBUR_NM',
      ' ' 'COLTEXT'     TEXT-f16,
      'E' 'OUTPUTLEN'   '10'.

* [GO-SD][26.02.09] 가온전선 로직 분리  - Start.
  IF gv_go = gc_x.
    PERFORM reset_field_catalog TABLES gt_fcat USING :
          'S' 'FIELDNAME'   'ZZYUSCD',
          ' ' 'COLTEXT'     TEXT-f32,    " 영업소코드
          'E' 'OUTPUTLEN'   '10',
          'S' 'FIELDNAME'   'LIFSK',
          ' ' 'COLTEXT'     TEXT-f33,    " 납품보류(헤더)
          'E' 'OUTPUTLEN'   '10'.
  ENDIF.
* [GO-SD][26.02.09] 가온전선 로직 분리  - End.

  PERFORM reset_field_catalog TABLES gt_fcat USING :
        'S' 'FIELDNAME'   'BSTKD',
        ' ' 'COLTEXT'     TEXT-f17,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'ZPJNO',
        ' ' 'COLTEXT'     TEXT-f18,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'ZPTXT',
        ' ' 'COLTEXT'     TEXT-f19,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'CTLPC',
        ' ' 'COLTEXT'     TEXT-f20,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'CTLPC_NM',
        ' ' 'COLTEXT'     TEXT-f21,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'AUDAT',
        ' ' 'COLTEXT'     TEXT-f22,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'VDATU',
        ' ' 'COLTEXT'     TEXT-f23,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'ERDAT',
        ' ' 'COLTEXT'     TEXT-f24,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'ERNAM',
        ' ' 'COLTEXT'     TEXT-f25,
        'E' 'OUTPUTLEN'   '10'.

  IF rb_disp = gc_x.
    PERFORM reset_field_catalog TABLES gt_fcat USING :
        'S' 'FIELDNAME'   'IFDAT',
        ' ' 'COLTEXT'     TEXT-f28,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'IFTIM',
        ' ' 'COLTEXT'     TEXT-f29,
        'E' 'OUTPUTLEN'   '10',

        'S' 'FIELDNAME'   'IFNAM',
        ' ' 'COLTEXT'     TEXT-f30,
        'E' 'OUTPUTLEN'   '10'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM reset_field_catalog TABLES pt_fcat TYPE lvc_t_fcat
                         USING  pv_flag
                                pv_fname
                                pv_value.

  STATICS : ls_fcat   TYPE lvc_s_fcat,
            lv_colpos TYPE lvc_colpos,
            lv_tabix  TYPE sytabix.

  IF pv_flag = zgtsd_s.  "Start
    CLEAR ls_fcat.
    READ TABLE pt_fcat INTO ls_fcat WITH KEY fieldname = pv_value BINARY SEARCH.
    CHECK sy-subrc = 0.
    lv_tabix = sy-tabix.

    lv_colpos = lv_colpos + 1.

    ls_fcat-tech    = space.
    ls_fcat-col_pos = lv_colpos.
  ENDIF.

  CASE pv_fname.
    WHEN 'COLTEXT'.   "Text
      ls_fcat-coltext  = pv_value.
      ls_fcat-reptext  = pv_value.
      ls_fcat-seltext  = pv_value.
      ls_fcat-tooltip  = pv_value.
    WHEN OTHERS.
      ASSIGN COMPONENT pv_fname OF STRUCTURE ls_fcat TO FIELD-SYMBOL(<lv_value>).
      CHECK sy-subrc = 0.
      <lv_value> = pv_value.
  ENDCASE.

  IF pv_flag = zgtsd_e.  "End
    MODIFY pt_fcat FROM ls_fcat INDEX lv_tabix.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*----------------------------------------------------------------------*
FORM exclude_toolbar TABLES pt_exclude TYPE ui_functions.

  REFRESH pt_exclude.

  APPEND : cl_gui_alv_grid=>mc_fc_loc_undo            TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_data_save           TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_copy            TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_copy_row        TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_cut             TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_delete_row      TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_insert_row      TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_move_row        TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_append_row      TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_paste           TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_loc_paste_new_row   TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_refresh             TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_check               TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_print               TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_views               TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_graph               TO pt_exclude,
           cl_gui_alv_grid=>mc_fc_info                TO pt_exclude.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_EVENT_RECEIVER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM create_event_receiver USING po_sender TYPE REF TO cl_gui_alv_grid.

  "Create Event
  DATA(lo_event) = NEW lcl_event_receiver( ).

  CASE po_sender.
    WHEN go_grid.
      SET HANDLER : lo_event->handle_top_of_page FOR po_sender.
  ENDCASE.

  SET HANDLER : lo_event->handle_hotspot_click         FOR po_sender,
                lo_event->handle_dbl_click             FOR po_sender.
*                LO_EVENT->HANDLE_TOOLBAR               FOR PO_SENDER,
*                LO_EVENT->HANDLE_USER_COMMAND          FOR PO_SENDER,
*                LO_EVENT->HANDLE_ON_F4                 FOR PO_SENDER.
*               LO_EVENT->HANDLE_DATA_CHANGED          FOR PO_SENDER,
*               LO_EVENT->HANDLE_DATA_CHANGED_FINISHED FOR PO_SENDER.

*  "Data Changed Event
*  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
*  PO_SENDER->REGISTER_EDIT_EVENT( CL_GUI_ALV_GRID=>MC_EVT_ENTER ).

*  "Set Ready for Input
*  GO_GRID->SET_READY_FOR_INPUT( SWITCH #( GV_EDIT WHEN ZGTSD_X THEN 1 ELSE 0 ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REGISTER_F4_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM register_f4_fields .

  DATA : lt_f4   TYPE lvc_t_f4,
         lt_fcat TYPE TABLE OF lvc_s_fcat
                 WITH NON-UNIQUE SORTED KEY key_mode
                 COMPONENTS f4availabl fieldname.

  lt_fcat = gt_fcat.
  LOOP AT lt_fcat INTO DATA(ls_fcat) USING KEY key_mode
                  WHERE f4availabl = zgtsd_x.
    lt_f4 = VALUE #( BASE lt_f4 ( fieldname  = ls_fcat-fieldname
                                  register   = zgtsd_x
                                  chngeafter = zgtsd_x ) ).
  ENDLOOP.

  go_grid->register_f4_for_fields( EXPORTING it_f4 = lt_f4 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOP_OF_PAGE_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_top_of_page_event .

  CHECK go_docu IS BOUND.

  go_docu->initialize_document( background_color = cl_dd_area=>col_textarea ).

  CALL METHOD go_grid->list_processing_events(
      i_event_name = slis_ev_top_of_page
      i_dyndoc_id  = go_docu ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_table_for_first_display USING po_sender TYPE REF TO cl_gui_alv_grid
                                       pt_data TYPE table.
  DATA : lv_handl TYPE slis_handl.

  "레이아웃 Variant 구분자
  PERFORM set_variant_handle USING po_sender CHANGING lv_handl.

  DELETE gt_fcat WHERE tech = zgtsd_x. "불필요한 필드 제외

  "Formatted Output Table is Sent to Control
  CALL METHOD po_sender->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      is_variant           = VALUE #( report = sy-repid
                                      handle = lv_handl )
      i_save               = zgtsd_a
      it_toolbar_excluding = gt_toolbar
    CHANGING
      it_fieldcatalog      = gt_fcat
      it_sort              = gt_sort[]
      it_outtab            = pt_data[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT_HANDLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_variant_handle USING po_sender TYPE REF TO cl_gui_alv_grid
                         CHANGING pv_handl.

  CLEAR pv_handl.
  CASE po_sender.
    WHEN go_grid. "Main
      pv_handl = 1.
    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DBL_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM handle_dbl_click  USING    pv_row     TYPE lvc_s_row
                                pv_column  TYPE lvc_s_col.

  CHECK pv_row-rowtype EQ space.
  READ TABLE gt_s0100 INTO gs_s0100 INDEX pv_row-index.
  CHECK sy-subrc = 0 .

  CASE pv_column.
    WHEN 'VBELN'.
      CHECK gs_s0100-vbeln IS NOT INITIAL.
      SET PARAMETER ID: 'AUN' FIELD   gs_s0100-vbeln.
      CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
    WHEN 'KUNNR'.
      CHECK gs_s0100-kunnr IS NOT INITIAL.
      SET PARAMETER ID: 'KUN' FIELD   gs_s0100-kunnr.
      SET PARAMETER ID: 'VKO' FIELD   gs_s0100-vkorg.
      SET PARAMETER ID: 'VTW' FIELD   gs_s0100-vtweg.
      SET PARAMETER ID: 'SPA' FIELD   gs_s0100-spart.
      CALL TRANSACTION  'VD03' AND SKIP FIRST SCREEN.

*  	WHEN .
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_SORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_SORT
*&---------------------------------------------------------------------*
FORM set_alv_sort  CHANGING pt_sort TYPE lvc_t_sort.

  CLEAR : pt_sort[].
  IF rb_disp = gc_x.
    PERFORM set_sort_field USING: pt_sort 'ZIFKEY' gc_x '' '',
                                  pt_sort 'VBELN' gc_x '' '',
                                  pt_sort 'AEDAT' gc_x '' '',
                                  pt_sort 'AEZET' gc_x '' ''.
  ELSE.

    PERFORM set_sort_field USING: pt_sort 'VBELN' gc_x '' '',
                                  pt_sort 'AEDAT' gc_x '' '',
                                  pt_sort 'AEZET' gc_x '' ''.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_SORT
*&      --> P_
*&      --> GC_X
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_sort_field  USING pt_sort TYPE lvc_t_sort
                           pv_fldname
                           pv_up
                           pv_down
                           pv_subtot.

  APPEND VALUE #( spos      = lines( pt_sort ) + 1
                  fieldname = pv_fldname
                  up        = pv_up
                  down      = pv_down
                  subtot    = pv_subtot ) TO pt_sort.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_top_of_page USING po_docu TYPE REF TO cl_dd_document
                                  po_sender.
  DATA : lv_text TYPE sdydo_text_element.

  CHECK po_sender = go_grid "Main
    AND po_docu IS BOUND.

  "Set Column Width
  po_docu->add_table( EXPORTING no_of_columns = 3 border = '0' IMPORTING table = DATA(lo_table) ).

  lo_table->add_column( EXPORTING width = '30%' IMPORTING column = DATA(lo_col_key) ).
  lo_table->add_column( EXPORTING width = '3%' IMPORTING column = DATA(lo_col_sep) ).
  lo_table->add_column( EXPORTING width = '67%' IMPORTING column = DATA(lo_col_val) ).
  lo_table->new_row( ).

  "Set Column Style
  lo_table->set_column_style( col_no = 1 sap_emphasis = cl_dd_document=>strong sap_align = 'LEFT' ).
  lo_table->set_column_style( col_no = 3 sap_emphasis = cl_dd_document=>medium sap_align = 'LEFT' ).

  "Add Text
  PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                zgtsd_s %_s_vbeln_%_app_%-text 'S_VBELN[]'.

  PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                zgtsd_s %_s_erdat_%_app_%-text 'S_ERDAT[]'.
  CASE gc_x.
    WHEN rb_send.
      PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                    zgtsd_p TEXT-s01 TEXT-s03.
      CASE gc_x.
        WHEN rb_t1.
          PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                        zgtsd_p TEXT-s02 TEXT-s06.
*        WHEN RB_T2.
*          PERFORM ADD_TEXT_COMMON USING LO_COL_KEY LO_COL_SEP LO_COL_VAL LO_TABLE
*                                        ZGTSD_P TEXT-S02 TEXT-S07.
        WHEN rb_10.
          PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                        zgtsd_p TEXT-s02 TEXT-s12.
      ENDCASE.
    WHEN rb_disp.
      PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                    zgtsd_p TEXT-s01 TEXT-s04.
      CASE gc_x.
        WHEN rb_all.
          PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                        zgtsd_p TEXT-s08 TEXT-s09.
        WHEN rb_su.
          PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                        zgtsd_p TEXT-s08 TEXT-s10.
        WHEN rb_fa.
          PERFORM add_text_common USING lo_col_key lo_col_sep lo_col_val lo_table
                                        zgtsd_p TEXT-s08 TEXT-s11.
      ENDCASE.
  ENDCASE.

  "Display Document
  po_docu->merge_document( ).
  po_docu->display_document( EXPORTING
                               reuse_control      = zgtsd_x
                               parent             = go_con_top
                             EXCEPTIONS
                               html_display_error = 1 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_TEXT_COMMON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_text_common USING po_col_key TYPE REF TO cl_dd_area
                               po_col_sep TYPE REF TO cl_dd_area
                               po_col_val TYPE REF TO cl_dd_area
                               po_table   TYPE REF TO cl_dd_table_element
                               pv_flag
                               pv_key
                               pv_value.
  FIELD-SYMBOLS : <lt_selopt> TYPE table.
  DATA lv_text TYPE char255.

  CASE pv_flag.
    WHEN zgtsd_p. "Parameter
      CHECK pv_value IS NOT INITIAL.
      lv_text = CONV sdydo_text_element( pv_value ).
    WHEN zgtsd_s. "Select-Option
      ASSIGN (pv_value) TO <lt_selopt>.
      CHECK sy-subrc = 0.

      CHECK lines( <lt_selopt> ) => 1.

      ASSIGN COMPONENT 'LOW' OF STRUCTURE <lt_selopt>[ 1 ] TO FIELD-SYMBOL(<lv_low>).
      CHECK sy-subrc = 0.
      ASSIGN COMPONENT 'HIGH' OF STRUCTURE <lt_selopt>[ 1 ] TO FIELD-SYMBOL(<lv_high>).
      CHECK sy-subrc = 0.

      IF <lv_high> IS INITIAL.
        lv_text = <lv_low>.
      ELSEIF <lv_low> IS INITIAL.
        lv_text = `~ ` &&  <lv_low>.
      ELSE.
        lv_text = <lv_low> && ` ~ ` &&  <lv_high>.
      ENDIF.
  ENDCASE.

  po_col_key->add_text( text = CONV sdydo_text_element( pv_key ) ).
  po_col_sep->add_text( text = CONV sdydo_text_element( zgtsd_colon ) ).
  po_col_val->add_text( text = lv_text ).

  po_table->new_row( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_hotspot_click USING ps_column TYPE lvc_s_col
                                ps_row_no TYPE lvc_s_roid
                                po_sender.

  CHECK po_sender = go_grid. "Main

  CASE ps_column-fieldname.

    WHEN 'MATNR'. "자산번호

      READ TABLE gt_s0100 INTO DATA(ls_main) INDEX ps_row_no-row_id.
      CHECK sy-subrc = 0.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_data_changed USING po_data_changed TYPE REF TO
                                 cl_alv_changed_data_protocol
                                 po_sender.

  CHECK po_sender = go_grid.  "Main

  DATA(lt_mod_cells) = po_data_changed->mt_good_cells.
  SORT lt_mod_cells BY row_id fieldname.

  REFRESH gt_chg.

  LOOP AT lt_mod_cells INTO DATA(ls_mod_temp).

    DATA(ls_mod_cells) = ls_mod_temp.

    AT NEW row_id.
      READ TABLE gt_s0100 INTO DATA(ls_main) INDEX ls_mod_cells-row_id.
      CHECK sy-subrc = 0.
    ENDAT.

    "체크사항 점검 및 Set Value
    PERFORM check_value_in_datachd USING    po_data_changed
                                            ls_mod_cells
                                   CHANGING ls_main.

    AT END OF row_id.
      "변경상태 Update
      PERFORM update_statu USING    po_data_changed
                                    ls_mod_cells
                           CHANGING ls_main-statu
                                    ls_main-modi.
      MODIFY gt_s0100 FROM ls_main INDEX ls_mod_cells-row_id.
      APPEND CORRESPONDING #( ls_main ) TO gt_chg.
    ENDAT.

  ENDLOOP.

  "Display Protocol
  po_data_changed->display_protocol( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_VALUE_IN_DATACHD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_value_in_datachd USING po_data_changed TYPE REF TO
                                      cl_alv_changed_data_protocol
                                      ps_mod_cells TYPE lvc_s_modi
                            CHANGING ps_data STRUCTURE gs_s0100.

  CASE ps_mod_cells-fieldname.

    WHEN OTHERS.
      ASSIGN COMPONENT ps_mod_cells-fieldname OF STRUCTURE ps_data TO FIELD-SYMBOL(<lv_value>).
      CHECK sy-subrc = 0.
      <lv_value> = ps_mod_cells-value.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_changed_data USING po_grid TYPE REF TO cl_gui_alv_grid
                              pv_ck.

  CLEAR gv_error.
  CHECK po_grid IS BOUND.

  po_grid->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).

  IF pv_ck = zgtsd_x AND lv_valid IS INITIAL.
    gv_error = zgtsd_x. "오류 Flag
    MESSAGE s029 DISPLAY LIKE zgtsd_e. "오류 내역이 존재합니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_STATU
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM update_statu USING po_data_changed TYPE REF TO
                            cl_alv_changed_data_protocol
                            ps_mod_cells TYPE lvc_s_modi
                   CHANGING pv_statu
                            pv_modi.

  pv_modi  = zgtsd_x.     "변경 Flag
  pv_statu = icon_change. "변경 Icon

  PERFORM modify_cell USING po_data_changed
                            ps_mod_cells-row_id
                            ps_mod_cells-tabix
                            'STATU'
                            pv_statu.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CELL_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_cell_value USING po_data_changed TYPE REF TO
                              cl_alv_changed_data_protocol
                              pv_row_id
                              pv_fieldname
                     CHANGING pv_value.

  CLEAR pv_value.
  po_data_changed->get_cell_value( EXPORTING
                                     i_row_id    = pv_row_id
                                     i_fieldname = pv_fieldname
                                   IMPORTING
                                     e_value     = pv_value ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_PROTOCOL_ENTRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM add_protocol_entry USING po_data_changed TYPE REF TO
                                cl_alv_changed_data_protocol
                                pv_msgid
                                pv_msgno
                                pv_msgv1
                                pv_msgv2
                                pv_fieldname
                                pv_row_id.

  DATA : lt_data TYPE TABLE OF lvc_s_msg1
                 WITH NON-UNIQUE SORTED KEY key_mode
                 COMPONENTS msgid msgno msgv1 msgv2 fieldname row_id.

  lt_data = po_data_changed->mt_protocol.  "기존 동일 오류 제외

  CHECK NOT line_exists( lt_data[ KEY key_mode COMPONENTS msgid     = pv_msgid
                                                          msgno     = pv_msgno
                                                          msgv1     = pv_msgv1
                                                          msgv2     = pv_msgv2
                                                          fieldname = pv_fieldname
                                                          row_id    = pv_row_id ] ).

  po_data_changed->add_protocol_entry(
      EXPORTING
        i_msgid     = pv_msgid
        i_msgno     = pv_msgno
        i_msgty     = zgtsd_e
        i_msgv1     = pv_msgv1
        i_msgv2     = pv_msgv2
        i_fieldname = pv_fieldname
        i_row_id    = pv_row_id ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_cell USING po_data_changed TYPE REF TO
                         cl_alv_changed_data_protocol
                         pv_row_id
                         pv_tabix
                         pv_fieldname
                         pv_value.

  po_data_changed->modify_cell( i_row_id    = pv_row_id
                                i_tabix     = pv_tabix
                                i_fieldname = pv_fieldname
                                i_value     = pv_value ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_data_changed_finished USING pv_modified
                                            pt_good_cells TYPE lvc_t_modi
                                            po_sender.

  CHECK pv_modified = zgtsd_x
    AND po_sender   = go_grid
    AND gt_chg IS NOT INITIAL.

*  변경사항 반영
  PERFORM update_edit_fields USING gt_chg.

  "Refresh Grid
  PERFORM refresh_table_display USING po_sender space.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_EDIT_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM update_edit_fields USING pt_chg TYPE ty_t_chg.

*  "Set 수정 필드
*  DELETE ADJACENT DUPLICATES FROM PT_CHG USING KEY KEY_MODE COMPARING PSPID.
*
*  LOOP AT PT_CHG INTO DATA(LS_CHG).
*
*    DATA(LS_DATA) = VALUE #( GT_MAIN[ KEY KEY_STUFE
*                               COMPONENTS PSPID = LS_CHG-PSPID
*                                          STUFE = 1 ] OPTIONAL ).
*    CHECK LS_DATA-PSPID IS NOT INITIAL.
*
*    LOOP AT GT_MAIN ASSIGNING FIELD-SYMBOL(<LS_MAIN>) USING KEY KEY_MODE
*                     WHERE PSPID = LS_DATA-PSPID.
*      <LS_MAIN>-Z_IV_PUR       = LS_DATA-Z_IV_PUR.       "자산 매각
*      <LS_MAIN>-Z_IV_ANLKL     = LS_DATA-Z_IV_ANLKL.     "자산 클래스
*      <LS_MAIN>-Z_IV_ANLKL_TXT = LS_DATA-Z_IV_ANLKL_TXT. "자산 클래스 명
*      <LS_MAIN>-Z_KSTAR        = LS_DATA-Z_KSTAR.        "원가요소
*      <LS_MAIN>-Z_KSTAR_TXT    = LS_DATA-Z_KSTAR_TXT.    "원가요소 명
*    ENDLOOP.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_toolbar USING po_object TYPE REF TO cl_alv_event_toolbar_set
                              po_sender.
  DEFINE _add_toolbar.
    ls_toolbar = VALUE #( function   = &1
                          icon       = &2
                          quickinfo  = &3
                          text       = &4
                          butn_type  = &5 ).

    CASE &6.
      WHEN zgtsd_a. "Append
        APPEND ls_toolbar TO po_object->mt_toolbar.
      WHEN zgtsd_i. "Insert
        INSERT ls_toolbar INTO po_object->mt_toolbar INDEX 1.
    ENDCASE.
  END-OF-DEFINITION.

  DATA : ls_toolbar TYPE stb_button.

*  CHECK GV_EDIT = ZGTSD_X.     "수정가능 상태
*
*  CASE PO_SENDER.
*    WHEN GO_GRID. "Main
*      _ADD_TOOLBAR SPACE                SPACE            SPACE    SPACE    3 ZPS01_A.
*      _ADD_TOOLBAR ZPS01_UCOMM-AUC_SETL ICON_GENERATE    TEXT-009 TEXT-009 0 ZPS01_A. "AUC 정산규칙(F) 생성
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_TABLE_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM refresh_table_display USING po_grid TYPE REF TO cl_gui_alv_grid
                                  pv_soft_refresh.

  CHECK po_grid IS BOUND.

  CALL METHOD po_grid->refresh_table_display
    EXPORTING
      is_stable      = CONV #( 'XX' )
      i_soft_refresh = pv_soft_refresh
    EXCEPTIONS
      finished       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_ON_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_on_f4 USING pv_fieldname TYPE lvc_fname
                            pv_fieldvalue  TYPE lvc_value
                            ps_row_no      TYPE lvc_s_roid
                            po_event_data  TYPE REF TO cl_alv_event_data
                            pv_display     TYPE char01
                            po_sender.
  DATA : lv_value TYPE lvc_value.
  FIELD-SYMBOLS : <lt_data> TYPE table.

*  CHECK PO_SENDER = GO_GRID. "Main
*
*  PO_EVENT_DATA->M_EVENT_HANDLED = ZPS01_X.
*
*  CASE PV_FIELDNAME.
*    WHEN ZPS01_FNAME-Z_IV_ANLKL.  "자산 클래스
*
*      PERFORM F4_CODE_MASTER USING    ZPS01_ROLLNAME-ZE_IV_ANLKL
*                                      ZPS01_CODE-PSAC02
*                                      PV_DISPLAY
*                             CHANGING LV_VALUE.
*
*    WHEN OTHERS.
*      RETURN.
*  ENDCASE.
*
*  CHECK LV_VALUE IS NOT INITIAL.
*
*  ASSIGN PO_EVENT_DATA->M_DATA->* TO <LT_DATA>.
*  CHECK SY-SUBRC = 0.
*
*  APPEND VALUE LVC_S_MODI( FIELDNAME = PV_FIELDNAME
*                           ROW_ID    = PS_ROW_NO-ROW_ID
*                           VALUE     = LV_VALUE ) TO <LT_DATA>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FREE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_object .
* Field Catalog
  CLEAR: gt_fcat[].

* Grid Clear
  CALL METHOD: go_grid->free.

  CLEAR: go_grid.

* Container Clear
  CALL METHOD: go_con->free,
               go_split->free,
               go_con_top->free.

  CLEAR: go_con, go_split, go_con_top.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_IF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_if.

  DATA : lv_subrc  TYPE sy-subrc,
         lv_cnt    TYPE i,
         lv_result TYPE zo_result,
         lv_dest   TYPE zifdest-dest,
         lv_msg    TYPE zo_message,
         lt_dup    LIKE TABLE OF gs_s0100,
         lt_tmp    LIKE TABLE OF gs_s0100,
         ls_1003   TYPE zgtsdt1003,
         lt_1003   TYPE TABLE OF zgtsdt1003 WITH HEADER LINE,
         lt_1004   TYPE TABLE OF zgtsdt1004 WITH HEADER LINE,
         lt_1005   TYPE TABLE OF zgtsdt1005 WITH HEADER LINE,
         lt_1006   TYPE TABLE OF zgtsdt1006 WITH HEADER LINE,
         lt_tab_h  TYPE TABLE OF zgtsdsif0002 WITH HEADER LINE,
         lt_tab_i  TYPE TABLE OF zgtsdsif0003 WITH HEADER LINE,
         lt_tab_c  TYPE TABLE OF zgtsdsif0004 WITH HEADER LINE,
         lt_tab_p  TYPE TABLE OF zgtsdsif0005 WITH HEADER LINE.

  "Selected Rows
  DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                        io_grid = go_grid
                                                        iv_ck   = zgtsd_x
                                                      IMPORTING
                                                        ev_subrc = lv_subrc ).
  CHECK lv_subrc IS INITIAL.

  CLEAR gs_s0100.
  MODIFY gt_s0100 FROM gs_s0100 TRANSPORTING sel WHERE sel IS NOT INITIAL.

  LOOP AT lt_rows INTO DATA(ls_row).

    READ TABLE gt_s0100 INTO gs_s0100 INDEX ls_row-index.
    CHECK sy-subrc = 0.

    IF gs_s0100-statu NE icon_led_inactive.
      CONTINUE.
    ENDIF.

    gs_s0100-sel = gc_x.
    APPEND gs_s0100 TO lt_tmp.

    MODIFY gt_s0100 FROM gs_s0100 INDEX ls_row-index.
    APPEND gs_s0100 TO lt_dup.
  ENDLOOP.

  SORT lt_dup BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_dup COMPARING vbeln.
  LOOP AT lt_dup INTO gs_s0100.

    MOVE-CORRESPONDING gs_s0100 TO lt_tab_h.

    MOVE-CORRESPONDING gs_s0100 TO lt_1003.
    APPEND lt_1003. CLEAR lt_1003.

    __alpha_ou : gs_s0100-kunnr lt_tab_h-kunnr,
                 gs_s0100-vbeln lt_tab_h-vbeln.

    CALL FUNCTION 'CONVERSION_EXIT_AUART_OUTPUT'
      EXPORTING
        input  = gs_s0100-auart
      IMPORTING
        output = lt_tab_h-auart.
    APPEND lt_tab_h. CLEAR lt_tab_h.

**********************************************************************
*ITEM
    LOOP AT gt_item USING KEY k_key INTO DATA(ls_item) WHERE vbeln = gs_s0100-vbeln.

      MOVE-CORRESPONDING ls_item TO lt_tab_i.

      __alpha_ou : ls_item-posnr lt_tab_i-posnr,
                   ls_item-vbeln lt_tab_i-vbeln,
                   ls_item-matnr lt_tab_i-matnr.
      APPEND lt_tab_i. CLEAR lt_tab_i.

      MOVE-CORRESPONDING ls_item TO lt_1004.
      APPEND lt_1004. CLEAR lt_1004.
    ENDLOOP.


*CHAR
    LOOP AT gt_char USING KEY k_key INTO DATA(ls_char) WHERE vbeln = gs_s0100-vbeln.

      MOVE-CORRESPONDING ls_char TO lt_tab_c.
      __alpha_ou : ls_char-posnr lt_tab_c-posnr,
                   ls_char-vbeln lt_tab_c-vbeln.
      APPEND lt_tab_c. CLEAR lt_tab_c.

      MOVE-CORRESPONDING ls_char TO lt_1005.
      APPEND lt_1005. CLEAR lt_1005.
    ENDLOOP.

*PARTNER
    LOOP AT gt_partner USING KEY k_key INTO DATA(ls_par) WHERE vbeln = gs_s0100-vbeln.

      MOVE-CORRESPONDING ls_par TO lt_tab_p.
      __alpha_ou : ls_par-posnr lt_tab_p-posnr,
                   ls_par-vbeln lt_tab_p-vbeln,
                   ls_par-kunnr lt_tab_p-kunnr,
                   ls_par-lifnr lt_tab_p-lifnr,
                   ls_par-assigned_bp lt_tab_p-assigned_bp.
      APPEND lt_tab_p. CLEAR lt_tab_p.

      MOVE-CORRESPONDING ls_par TO lt_1006.
      APPEND lt_1006. CLEAR lt_1006.
    ENDLOOP.
  ENDLOOP.

  SORT lt_tmp BY zsystem_id.
  DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING zsystem_id.
  IF lines( lt_tmp ) > 1.
    MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE gc_e.EXIT.
  ELSE.
    READ TABLE lt_tmp INTO DATA(ls_tmp) INDEX 1.
    gv_tar = ls_tmp-zsystem_id.
  ENDIF.

  IF lt_tab_h[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE gc_e.EXIT.
  ENDIF.

*  IF rb_t1 = 'X'.
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'IS'
    IMPORTING
      dest_name             = lv_dest
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.
*  ELSE.
*    CALL FUNCTION 'Z_IF_DESTINATION'
*      EXPORTING
*        gubun                 = 'SD'
*      IMPORTING
*        dest_name             = lv_dest
*      EXCEPTIONS
*        destination_not_found = 1
*        OTHERS                = 2.
*  ENDIF.
  IF lv_dest IS  INITIAL.
    MESSAGE s000 WITH TEXT-e04 DISPLAY LIKE gc_e.EXIT.
  ENDIF.

  CLEAR gv_answer.
  gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space iv_messa = TEXT-m02 ).
  CHECK gv_answer EQ zgtsd_j.

  TRY.
      CALL FUNCTION 'ZGTSD_IF_O_SALESORDER_INFO'
        DESTINATION lv_dest
        EXPORTING
          i_system_id           = gv_tar
        IMPORTING
          zo_result             = lv_result
          zo_message            = lv_msg
        TABLES
          ot_tab_h              = lt_tab_h
          ot_tab_i              = lt_tab_i
          ot_tab_c              = lt_tab_c
          ot_tab_p              = lt_tab_p
        EXCEPTIONS
          system_failure        = 1 MESSAGE lv_msg
          communication_failure = 2 MESSAGE lv_msg
          illegalname           = 3
          OTHERS                = 4.
      IF sy-subrc NE 0.
        lv_result = |01|.
      ENDIF.

    CATCH cx_root INTO DATA(lo_err).
      MESSAGE s000 WITH lo_err->get_longtext( ) DISPLAY LIKE gc_e.EXIT.
  ENDTRY.

  CLEAR ls_1003.
  GET TIME STAMP FIELD ls_1003-zifkey.
  ls_1003-ifdat      = sy-datlo.
  ls_1003-iftim      = sy-uzeit.
  ls_1003-ifnam      = sy-uname.
  ls_1003-zsystem_id = gv_tar.
  ls_1003-zstat      = lv_result.

  CASE lv_result.
    WHEN '00' OR '0'.
      ls_1003-zmessage = TEXT-m01.
    WHEN OTHERS.
      IF lv_msg IS INITIAL.
        lv_result = '01'.
        ls_1003-zmessage = TEXT-e02.
      ELSE.
        ls_1003-zmessage = lv_msg.
      ENDIF.
  ENDCASE.

  LOOP AT lt_dup INTO DATA(ls_dup).
    LOOP AT gt_s0100 INTO gs_s0100 WHERE vbeln = ls_dup-vbeln.

      CASE lv_result.
        WHEN '00' OR '0'.
          gs_s0100-statu = icon_led_green.
        WHEN OTHERS.
          gs_s0100-statu = icon_led_red.
      ENDCASE.
      gs_s0100-msg   = ls_1003-zmessage.
      gs_s0100-ifdat = ls_1003-ifdat.
      gs_s0100-iftim = ls_1003-iftim.
      gs_s0100-ifnam = ls_1003-ifnam.

      MODIFY gt_s0100 FROM gs_s0100.
    ENDLOOP.
  ENDLOOP.

**********************************************************************
*LOG
**********************************************************************
  LOOP AT lt_1003.
    lt_1003-zsystem_id = gv_tar.
    lt_1003-zstat      = lv_result.
    lt_1003-zifkey     = ls_1003-zifkey.
    lt_1003-zmessage   = ls_1003-zmessage.
    lt_1003-ifdat      = ls_1003-ifdat.
    lt_1003-iftim      = ls_1003-iftim.
    lt_1003-ifnam      = ls_1003-ifnam.
    MODIFY lt_1003. CLEAR lt_1003.
  ENDLOOP.

  LOOP AT lt_1004.
    lt_1004-zsystem_id = gv_tar.
    lt_1004-zstat      = lv_result.
    lt_1004-zifkey     = ls_1003-zifkey.
    lt_1004-zmessage   = ls_1003-zmessage.
    lt_1004-ifdat      = ls_1003-ifdat.
    lt_1004-iftim      = ls_1003-iftim.
    lt_1004-ifnam      = ls_1003-ifnam.
    MODIFY lt_1004. CLEAR lt_1004.
  ENDLOOP.

  LOOP AT lt_1005.
    lt_1005-zsystem_id = gv_tar.
    lt_1005-zstat      = lv_result.
    lt_1005-zifkey     = ls_1003-zifkey.
    lt_1005-zmessage   = ls_1003-zmessage.
    lt_1005-ifdat      = ls_1003-ifdat.
    lt_1005-iftim      = ls_1003-iftim.
    lt_1005-ifnam      = ls_1003-ifnam.
    MODIFY lt_1005. CLEAR lt_1005.
  ENDLOOP.

  LOOP AT lt_1006.
    lt_1006-zsystem_id = gv_tar.
    lt_1006-zstat      = lv_result.
    lt_1006-zifkey     = ls_1003-zifkey.
    lt_1006-zmessage   = ls_1003-zmessage.
    lt_1006-ifdat      = ls_1003-ifdat.
    lt_1006-iftim      = ls_1003-iftim.
    lt_1006-ifnam      = ls_1003-ifnam.
    MODIFY lt_1006. CLEAR lt_1006.
  ENDLOOP.
*
  IF lt_1003[] IS NOT INITIAL.
    MODIFY zgtsdt1003 FROM TABLE lt_1003.
  ENDIF.

  IF lt_1004[] IS NOT INITIAL.
    MODIFY zgtsdt1004 FROM TABLE lt_1004.
  ENDIF.

  IF lt_1005[] IS NOT INITIAL.
    MODIFY zgtsdt1005 FROM TABLE lt_1005.
  ENDIF.

  IF lt_1006[] IS NOT INITIAL.
    MODIFY zgtsdt1006 FROM TABLE lt_1006.
  ENDIF.

*  IF PV_TYPE IS NOT INITIAL.
*    PERFORM DATA_QUERY.
*  ENDIF.
  PERFORM refresh_table_display USING go_grid space.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_IF_BATCHJOB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_if_batchjob .

  DATA : lv_subrc  TYPE sy-subrc,
         lv_cnt    TYPE i,
         lv_result TYPE zo_result,
         lv_dest   TYPE zifdest-dest,
         lv_msg    TYPE zo_message,
         ls_1003   TYPE zgtsdt1003,
         lt_tmp    LIKE TABLE OF gs_s0100,
         lt_dup    LIKE TABLE OF gs_s0100,
         lt_1003   TYPE TABLE OF zgtsdt1003 WITH HEADER LINE,
         lt_1004   TYPE TABLE OF zgtsdt1004 WITH HEADER LINE,
         lt_1005   TYPE TABLE OF zgtsdt1005 WITH HEADER LINE,
         lt_1006   TYPE TABLE OF zgtsdt1006 WITH HEADER LINE,
         lt_tab_h  TYPE TABLE OF zgtsdsif0002 WITH HEADER LINE,
         lt_tab_i  TYPE TABLE OF zgtsdsif0003 WITH HEADER LINE,
         lt_tab_c  TYPE TABLE OF zgtsdsif0004 WITH HEADER LINE,
         lt_tab_p  TYPE TABLE OF zgtsdsif0005 WITH HEADER LINE.

  CHECK rb_send = gc_x.

  CLEAR gs_s0100.
  MODIFY gt_s0100 FROM gs_s0100 TRANSPORTING sel WHERE sel IS NOT INITIAL.

  LOOP AT gt_s0100 INTO gs_s0100.

    IF gs_s0100-statu NE icon_led_inactive.
      CONTINUE.
    ENDIF.

    gs_s0100-sel = gc_x.
    APPEND gs_s0100 TO lt_tmp.

    MODIFY gt_s0100 FROM gs_s0100.
    APPEND gs_s0100 TO lt_dup.
  ENDLOOP.

  SORT lt_dup BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_dup COMPARING vbeln.
  LOOP AT lt_dup INTO gs_s0100.

    MOVE-CORRESPONDING gs_s0100 TO lt_tab_h.

    MOVE-CORRESPONDING gs_s0100 TO lt_1003.
    APPEND lt_1003. CLEAR lt_1003.

    __alpha_ou : gs_s0100-kunnr lt_tab_h-kunnr,
                 gs_s0100-vbeln lt_tab_h-vbeln.

    CALL FUNCTION 'CONVERSION_EXIT_AUART_OUTPUT'
      EXPORTING
        input  = gs_s0100-auart
      IMPORTING
        output = lt_tab_h-auart.
    APPEND lt_tab_h. CLEAR lt_tab_h.

**********************************************************************
**********************************************************************

*ITEM
    LOOP AT gt_item USING KEY k_key INTO DATA(ls_item) WHERE vbeln = gs_s0100-vbeln.

      MOVE-CORRESPONDING ls_item TO lt_tab_i.
      __alpha_ou : ls_item-posnr lt_tab_i-posnr,
                   ls_item-vbeln lt_tab_i-vbeln,
                   ls_item-matnr lt_tab_i-matnr.
      APPEND lt_tab_i. CLEAR lt_tab_i.

      MOVE-CORRESPONDING ls_item TO lt_1004.
      APPEND lt_1004. CLEAR lt_1004.
    ENDLOOP.

*CHAR
    LOOP AT gt_char USING KEY k_key INTO DATA(ls_char) WHERE vbeln = gs_s0100-vbeln.
      MOVE-CORRESPONDING ls_char TO lt_tab_c.
      __alpha_ou : ls_char-posnr lt_tab_c-posnr,
                   ls_char-vbeln lt_tab_c-vbeln.
      APPEND lt_tab_c. CLEAR lt_tab_c.

      MOVE-CORRESPONDING ls_char TO lt_1005.
      APPEND lt_1005. CLEAR lt_1005.
    ENDLOOP.

*PARTNER
    LOOP AT gt_partner USING KEY k_key INTO DATA(ls_par) WHERE vbeln = gs_s0100-vbeln.
      MOVE-CORRESPONDING ls_par TO lt_tab_p.
      __alpha_ou : ls_par-posnr lt_tab_p-posnr,
                   ls_par-vbeln lt_tab_p-vbeln,
                   ls_par-kunnr lt_tab_p-kunnr,
                   ls_par-lifnr lt_tab_p-lifnr,
                   ls_par-assigned_bp lt_tab_p-assigned_bp.
      APPEND lt_tab_p. CLEAR lt_tab_p.

      MOVE-CORRESPONDING ls_par TO lt_1006.
      APPEND lt_1006. CLEAR lt_1006.
    ENDLOOP.

  ENDLOOP.

  IF lt_tab_h[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE gc_e.EXIT.
  ENDIF.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'IS'
    IMPORTING
      dest_name             = lv_dest
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.

  IF lv_dest IS  INITIAL.
    MESSAGE s000 WITH TEXT-e04 DISPLAY LIKE gc_e.EXIT.
  ENDIF.

  IF sy-batch = ' '.
    CLEAR gv_answer.
    gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space iv_messa = TEXT-m02 ).
    CHECK gv_answer EQ zgtsd_j.
  ENDIF.

  TRY.
      CALL FUNCTION 'ZGTSD_IF_O_SALESORDER_INFO'
        DESTINATION lv_dest
        EXPORTING
          i_system_id           = gv_tar
        IMPORTING
          zo_result             = lv_result
          zo_message            = lv_msg
        TABLES
          ot_tab_h              = lt_tab_h
          ot_tab_i              = lt_tab_i
          ot_tab_c              = lt_tab_c
          ot_tab_p              = lt_tab_p
        EXCEPTIONS
          system_failure        = 1 MESSAGE lv_msg
          communication_failure = 2 MESSAGE lv_msg
          illegalname           = 3
          OTHERS                = 4.
      IF sy-subrc NE 0.
        lv_result = |01|.
      ENDIF.

    CATCH cx_root INTO DATA(lo_err).
      MESSAGE s000 WITH lo_err->get_longtext( ) DISPLAY LIKE gc_e.EXIT.
  ENDTRY.

  CLEAR ls_1003.
  GET TIME STAMP FIELD ls_1003-zifkey.
  ls_1003-ifdat      = sy-datlo.
  ls_1003-iftim      = sy-uzeit.
  ls_1003-ifnam      = sy-uname.
  ls_1003-zsystem_id = gv_tar.
  ls_1003-zstat      = lv_result.
  gv_result = lv_result.
  gv_message = lv_msg.

  CASE lv_result.
    WHEN '00' OR '0'.
      ls_1003-zmessage = TEXT-m01.
    WHEN OTHERS.
      IF lv_msg IS INITIAL.
        lv_result = '01'.
        ls_1003-zmessage = TEXT-e02.
      ELSE.
        ls_1003-zmessage = lv_msg.
      ENDIF.
  ENDCASE.

  LOOP AT gt_s0100 INTO gs_s0100 WHERE sel = gc_x.
    gv_vbeln = gs_s0100-vbeln.
    CASE lv_result.
      WHEN '00' OR '0'.
        gs_s0100-statu = icon_led_green.
      WHEN OTHERS.
        gs_s0100-statu = icon_led_red.
    ENDCASE.

    gs_s0100-msg   = ls_1003-zmessage.
    gs_s0100-ifdat = ls_1003-ifdat.
    gs_s0100-iftim = ls_1003-iftim.
    gs_s0100-ifnam = ls_1003-ifnam.

    MODIFY gt_s0100 FROM gs_s0100.

  ENDLOOP.

**********************************************************************
*LOG
**********************************************************************
  LOOP AT lt_1003.
    lt_1003-zsystem_id = gv_tar.
    lt_1003-zstat      = lv_result.
    lt_1003-zifkey     = ls_1003-zifkey.
    lt_1003-zmessage   = ls_1003-zmessage.
    lt_1003-ifdat      = ls_1003-ifdat.
    lt_1003-iftim      = ls_1003-iftim.
    lt_1003-ifnam      = ls_1003-ifnam.
    MODIFY lt_1003. CLEAR lt_1003.
  ENDLOOP.

  LOOP AT lt_1004.
    lt_1004-zsystem_id = gv_tar.
    lt_1004-zstat      = lv_result.
    lt_1004-zifkey     = ls_1003-zifkey.
    lt_1004-zmessage   = ls_1003-zmessage.
    lt_1004-ifdat      = ls_1003-ifdat.
    lt_1004-iftim      = ls_1003-iftim.
    lt_1004-ifnam      = ls_1003-ifnam.
    MODIFY lt_1004. CLEAR lt_1004.
  ENDLOOP.

  LOOP AT lt_1005.
    lt_1005-zsystem_id = gv_tar.
    lt_1005-zstat      = lv_result.
    lt_1005-zifkey     = ls_1003-zifkey.
    lt_1005-zmessage   = ls_1003-zmessage.
    lt_1005-ifdat      = ls_1003-ifdat.
    lt_1005-iftim      = ls_1003-iftim.
    lt_1005-ifnam      = ls_1003-ifnam.
    MODIFY lt_1005. CLEAR lt_1005.
  ENDLOOP.

  LOOP AT lt_1006.
    lt_1006-zsystem_id = gv_tar.
    lt_1006-zstat      = lv_result.
    lt_1006-zifkey     = ls_1003-zifkey.
    lt_1006-zmessage   = ls_1003-zmessage.
    lt_1006-ifdat      = ls_1003-ifdat.
    lt_1006-iftim      = ls_1003-iftim.
    lt_1006-ifnam      = ls_1003-ifnam.
    MODIFY lt_1006. CLEAR lt_1006.
  ENDLOOP.

*
  IF lt_1003[] IS NOT INITIAL.
    MODIFY zgtsdt1003 FROM TABLE lt_1003.
  ENDIF.

  IF lt_1004[] IS NOT INITIAL.
    MODIFY zgtsdt1004 FROM TABLE lt_1004.
  ENDIF.

  IF lt_1005[] IS NOT INITIAL.
    MODIFY zgtsdt1005 FROM TABLE lt_1005.
  ENDIF.

  IF lt_1006[] IS NOT INITIAL.
    MODIFY zgtsdt1006 FROM TABLE lt_1006.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DETAIL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_VBELN
*&---------------------------------------------------------------------*
FORM get_detail_data  TABLES  pt_vbeln STRUCTURE gs_s0100
                              pt_cdhr.

  DATA : lt_conf_out TYPE TABLE OF conf_out WITH HEADER LINE,
         lt_cdhdr    TYPE TABLE OF cdhdr WITH EMPTY KEY,
         lv_cnt      TYPE n LENGTH 3.

  lt_cdhdr[] = pt_cdhr[].

  DATA(lt_hdr) = lt_cdhdr[].
  SORT lt_hdr BY objectid changenr.
  DELETE ADJACENT DUPLICATES FROM lt_hdr COMPARING objectid changenr.
  IF lt_hdr[] IS NOT INITIAL.
    SELECT b~*
      FROM @lt_hdr AS a INNER JOIN cdpos AS b
        ON a~objectid   = b~objectid
       AND a~changenr   = b~changenr
     WHERE tabname IN ('VBEP','VBAP')
       AND fname   IN ('KEY','ABGRU','WMENG')
      INTO TABLE @DATA(lt_cdpos).
  ENDIF.

  SORT lt_cdpos BY objectid.

*11-1) tabkey에서 Schedule line 구분자 삭제
  LOOP AT lt_cdpos INTO DATA(ls_cdpos).
    ls_cdpos-tabkey+19 = ''.
    MODIFY lt_cdpos FROM ls_cdpos.
  ENDLOOP.

  DATA(lt_cdpos_d) = lt_cdpos[].
  DELETE lt_cdpos_d WHERE chngind <> 'D'.
  SORT lt_cdpos_d BY tabkey changenr DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_cdpos_d COMPARING tabkey.

*11-3) 주문수량 확정된 ITEM 정보 발췌
  DATA(lt_header) = pt_vbeln[].
  SORT lt_header  BY vbeln .
  DELETE ADJACENT DUPLICATES FROM lt_header COMPARING vbeln.
  IF lt_header[] IS NOT INITIAL.
    SELECT p~vbeln, p~posnr, p~matnr, p~kdmat, p~bedae, p~kwmeng, p~vrkme,
           p~abgru, p~netwr, p~waerk, p~werks, p~lgort,
           e~edatu, p~erdat, p~ernam, p~aedat
      FROM @lt_header AS a INNER JOIN vbap AS p
        ON a~vbeln EQ p~vbeln
     INNER JOIN vbep AS e
        ON e~vbeln EQ p~vbeln
       AND e~posnr EQ p~posnr
     WHERE e~wmeng NE '0'
       AND p~werks IN @gr_werks
       AND p~vstel IN @gr_vstel
      INTO CORRESPONDING FIELDS OF TABLE @gt_item.
  ENDIF.
*
*  LOOP AT PT_VBELN.
*    READ TABLE GT_ITEM INTO GS_ITEM WITH KEY K_KEY COMPONENTS VBELN = PT_VBELN-VBELN.
*    IF SY-SUBRC NE 0.
*      DELETE PT_VBELN.CONTINUE.
*    ENDIF.
*  ENDLOOP.

  DELETE lt_cdpos WHERE chngind = 'D'.
  SORT lt_cdpos BY tabkey ASCENDING changenr DESCENDING.

  LOOP AT gt_item INTO gs_item.

    CONCATENATE sy-mandt gs_item-vbeln gs_item-posnr INTO DATA(lv_tabkey).
    LOOP AT lt_cdpos INTO ls_cdpos WHERE tabkey CS lv_tabkey.
      gs_item-zflag = ls_cdpos-chngind.
      gs_item-changenr = ls_cdpos-changenr.
      EXIT.
    ENDLOOP.

    MODIFY gt_item FROM gs_item.

*  12) Characteritics 정보 발췌
    __cle lt_conf_out. CLEAR lv_cnt.
    CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC_TABLE'
      EXPORTING
        i_vbeln                      = gs_item-vbeln
        i_posnr                      = gs_item-posnr
      TABLES
        et_char                      = lt_conf_out
      EXCEPTIONS
        instance_not_found           = 1
        instance_is_a_classification = 2
        invalid_data                 = 3
        OTHERS                       = 4.

    LOOP AT lt_conf_out.

      IF lt_conf_out-atnam NOT IN gr_atnam.
        CONTINUE.
      ENDIF.

      ADD 1 TO lv_cnt.
      MOVE-CORRESPONDING lt_conf_out TO gt_char.
      gt_char-vbeln = gs_item-vbeln.
      gt_char-posnr = gs_item-posnr.
      gt_char-seqno = lv_cnt.
      APPEND gt_char. CLEAR gt_char.
    ENDLOOP.

  ENDLOOP.

*11-2) 삭제된 S/O 정보 I/F 테이블에 저장
  LOOP AT lt_cdpos_d INTO DATA(ls_del).
    CLEAR gs_item.
    gs_item-zflag    = 'D'.
    gs_item-vbeln    = ls_del-tabkey+3(10).
    gs_item-posnr    = ls_del-tabkey+13(6).
    gs_item-changenr = ls_del-changenr.
    __alpha_in : gs_item-vbeln gs_item-vbeln,
                 gs_item-posnr gs_item-posnr.
    APPEND gs_item TO gt_item.
  ENDLOOP.

  lt_header[] = pt_vbeln[].
  SORT lt_header  BY vbeln .
  IF lt_header[] IS NOT INITIAL.
    SELECT vbeln, posnr, parvw, kunnr, lifnr, assigned_bp
      INTO CORRESPONDING FIELDS OF TABLE @gt_partner
      FROM vbpa
      FOR ALL ENTRIES IN @lt_header
     WHERE vbeln = @lt_header-vbeln.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DETAIL_DATA_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_VBELN
*&      --> LT_CDHR
*&---------------------------------------------------------------------*
FORM get_detail_data_log  TABLES   pt_vbeln STRUCTURE gs_s0100.

  __cle : gt_1004_l, gt_1005_l, gt_1006_l.

  DATA(lt_for) = pt_vbeln[].
  SORT lt_for BY zifkey vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING zifkey vbeln.
  IF lt_for[] IS NOT INITIAL.
    SELECT b~*
      FROM @lt_for AS a INNER JOIN zgtsdt1004 AS b
        ON a~zifkey = b~zifkey
       AND a~vbeln  = b~vbeln
      INTO CORRESPONDING FIELDS OF TABLE @gt_1004_l.

    SELECT b~*
      FROM @lt_for AS a INNER JOIN zgtsdt1005 AS b
        ON a~zifkey = b~zifkey
       AND a~vbeln  = b~vbeln
      INTO CORRESPONDING FIELDS OF TABLE @gt_1005_l.

    SELECT b~*
      FROM @lt_for AS a INNER JOIN zgtsdt1006 AS b
        ON a~zifkey = b~zifkey
       AND a~vbeln  = b~vbeln
      INTO CORRESPONDING FIELDS OF TABLE @gt_1006_l.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESEND_IF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_X
*&---------------------------------------------------------------------*
FORM resend_if.

  DATA : lv_subrc  TYPE sy-subrc,
         lv_cnt    TYPE i,
         lv_result TYPE zo_result,
         lv_dest   TYPE zifdest-dest,
         lv_msg    TYPE zo_message,
         lt_tmp    LIKE TABLE OF gs_s0100,
         ls_1003   TYPE zgtsdt1003,
         lt_1003   TYPE TABLE OF zgtsdt1003 WITH HEADER LINE,
         lt_1004   TYPE TABLE OF zgtsdt1004 WITH HEADER LINE,
         lt_1005   TYPE TABLE OF zgtsdt1005 WITH HEADER LINE,
         lt_1006   TYPE TABLE OF zgtsdt1006 WITH HEADER LINE,
         lt_tab_h  TYPE TABLE OF zgtsdsif0002 WITH HEADER LINE,
         lt_tab_i  TYPE TABLE OF zgtsdsif0003 WITH HEADER LINE,
         lt_tab_c  TYPE TABLE OF zgtsdsif0004 WITH HEADER LINE,
         lt_tab_p  TYPE TABLE OF zgtsdsif0005 WITH HEADER LINE.

  "Selected Rows
  DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                        io_grid = go_grid
                                                        iv_ck   = zgtsd_x
                                                      IMPORTING
                                                        ev_subrc = lv_subrc ).
  CHECK lv_subrc IS INITIAL.

  CLEAR gs_s0100.
  MODIFY gt_s0100 FROM gs_s0100 TRANSPORTING sel WHERE sel IS NOT INITIAL.

  LOOP AT lt_rows INTO DATA(ls_row).

    READ TABLE gt_s0100 INTO gs_s0100 INDEX ls_row-index.
    CHECK sy-subrc = 0.

    IF gs_s0100-statu NE icon_led_inactive AND gs_s0100-statu NE icon_led_red.
      CONTINUE.
    ENDIF.

    gs_s0100-sel = gc_x.
    APPEND gs_s0100 TO lt_tmp.

    MOVE-CORRESPONDING gs_s0100 TO lt_1003.
    APPEND lt_1003. CLEAR lt_1003.

    MOVE-CORRESPONDING gs_s0100 TO lt_tab_h.

    __alpha_ou : gs_s0100-kunnr lt_tab_h-kunnr,
                 gs_s0100-vbeln lt_tab_h-vbeln.

    CALL FUNCTION 'CONVERSION_EXIT_AUART_OUTPUT'
      EXPORTING
        input  = gs_s0100-auart
      IMPORTING
        output = lt_tab_h-auart.
    APPEND lt_tab_h. CLEAR lt_tab_h.

*ITEM
    LOOP AT gt_1004_l USING KEY k_key INTO DATA(ls_item) WHERE zifkey = gs_s0100-zifkey
                                                           AND vbeln = gs_s0100-vbeln.

      MOVE-CORRESPONDING ls_item TO lt_tab_i.

      __alpha_ou : ls_item-posnr lt_tab_i-posnr,
                   ls_item-vbeln lt_tab_i-vbeln,
                   ls_item-matnr lt_tab_i-matnr.
      APPEND lt_tab_i. CLEAR lt_tab_i.

      MOVE-CORRESPONDING ls_item TO lt_1004.
      APPEND lt_1004. CLEAR lt_1004.
    ENDLOOP.

*CHAR
    LOOP AT gt_1005_l USING KEY k_key INTO DATA(ls_char) WHERE zifkey = gs_s0100-zifkey
                                                           AND vbeln = gs_s0100-vbeln.

      MOVE-CORRESPONDING ls_char TO lt_tab_c.
      __alpha_ou : ls_char-posnr lt_tab_c-posnr,
                   ls_char-vbeln lt_tab_c-vbeln.
      APPEND lt_tab_c. CLEAR lt_tab_c.

      MOVE-CORRESPONDING ls_char TO lt_1005.
      APPEND lt_1005. CLEAR lt_1005.
    ENDLOOP.

*PARTNER
    LOOP AT gt_1006_l USING KEY k_key INTO DATA(ls_par) WHERE zifkey = gs_s0100-zifkey
                                                          AND vbeln = gs_s0100-vbeln.

      MOVE-CORRESPONDING ls_par TO lt_tab_p.
      __alpha_ou : ls_par-posnr lt_tab_p-posnr,
                   ls_par-vbeln lt_tab_p-vbeln,
                   ls_par-kunnr lt_tab_p-kunnr,
                   ls_par-lifnr lt_tab_p-lifnr,
                   ls_par-assigned_bp lt_tab_p-assigned_bp.
      APPEND lt_tab_p. CLEAR lt_tab_p.

      MOVE-CORRESPONDING ls_par TO lt_1006.
      APPEND lt_1006. CLEAR lt_1006.
    ENDLOOP.

    MODIFY gt_s0100 FROM gs_s0100 INDEX ls_row-index.
  ENDLOOP.

  SORT lt_tmp BY zsystem_id.
  DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING zsystem_id.
  IF lines( lt_tmp ) > 1.
    MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE gc_e.EXIT.
  ELSE.
    READ TABLE lt_tmp INTO DATA(ls_tmp) INDEX 1.
    gv_tar = ls_tmp-zsystem_id.
  ENDIF.

  IF lt_tab_h[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE gc_e.EXIT.
  ENDIF.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'IS'
    IMPORTING
      dest_name             = lv_dest
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.

  IF lv_dest IS  INITIAL.
    MESSAGE s000 WITH TEXT-e04 DISPLAY LIKE gc_e.EXIT.
  ENDIF.

  CLEAR gv_answer.
  gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space iv_messa = TEXT-m03 ).
  CHECK gv_answer EQ zgtsd_j.

  TRY.
      CALL FUNCTION 'ZGTSD_IF_O_SALESORDER_INFO'
        DESTINATION lv_dest
        EXPORTING
          i_system_id           = gv_tar
        IMPORTING
          zo_result             = lv_result
          zo_message            = lv_msg
        TABLES
          ot_tab_h              = lt_tab_h
          ot_tab_i              = lt_tab_i
          ot_tab_c              = lt_tab_c
          ot_tab_p              = lt_tab_p
        EXCEPTIONS
          system_failure        = 1 MESSAGE lv_msg
          communication_failure = 2 MESSAGE lv_msg
          illegalname           = 3
          OTHERS                = 4.
      IF sy-subrc NE 0.
        lv_result = |01|.
      ENDIF.

    CATCH cx_root INTO DATA(lo_err).
      MESSAGE s000 WITH lo_err->get_longtext( ) DISPLAY LIKE gc_e.EXIT.
  ENDTRY.

  CLEAR ls_1003.
  GET TIME STAMP FIELD ls_1003-zifkey.
  ls_1003-ifdat      = sy-datlo.
  ls_1003-iftim      = sy-uzeit.
  ls_1003-ifnam      = sy-uname.
  ls_1003-zsystem_id = gv_tar.
  ls_1003-zstat      = lv_result.

  CASE lv_result.
    WHEN '00' OR '0'.
      ls_1003-zmessage = TEXT-m01.
    WHEN OTHERS.
      IF lv_msg IS INITIAL.
        lv_result = '01'.
        ls_1003-zmessage = TEXT-e02.
      ELSE.
        ls_1003-zmessage = lv_msg.
      ENDIF.
  ENDCASE.


  LOOP AT gt_s0100 INTO gs_s0100 WHERE sel = gc_x.

    CASE lv_result.
      WHEN '00' OR '0'.
        gs_s0100-statu = icon_led_green.
      WHEN OTHERS.
        gs_s0100-statu = icon_led_red.
    ENDCASE.
    gs_s0100-msg   = ls_1003-zmessage.
    gs_s0100-ifdat = ls_1003-ifdat.
    gs_s0100-iftim = ls_1003-iftim.
    gs_s0100-ifnam = ls_1003-ifnam.
    MODIFY gt_s0100 FROM gs_s0100.

  ENDLOOP.
**********************************************************************
*LOG
**********************************************************************
  LOOP AT lt_1003.
    lt_1003-zsystem_id = gv_tar.
    lt_1003-zstat      = lv_result.
    lt_1003-zifkey     = ls_1003-zifkey.
    lt_1003-zmessage   = ls_1003-zmessage.
    lt_1003-ifdat      = ls_1003-ifdat.
    lt_1003-iftim      = ls_1003-iftim.
    lt_1003-ifnam      = ls_1003-ifnam.
    MODIFY lt_1003. CLEAR lt_1003.
  ENDLOOP.

  LOOP AT lt_1004.
    lt_1004-zsystem_id = gv_tar.
    lt_1004-zstat      = lv_result.
    lt_1004-zifkey     = ls_1003-zifkey.
    lt_1004-zmessage   = ls_1003-zmessage.
    lt_1004-ifdat      = ls_1003-ifdat.
    lt_1004-iftim      = ls_1003-iftim.
    lt_1004-ifnam      = ls_1003-ifnam.
    MODIFY lt_1004. CLEAR lt_1004.
  ENDLOOP.

  LOOP AT lt_1005.
    lt_1005-zsystem_id = gv_tar.
    lt_1005-zstat      = lv_result.
    lt_1005-zifkey     = ls_1003-zifkey.
    lt_1005-zmessage   = ls_1003-zmessage.
    lt_1005-ifdat      = ls_1003-ifdat.
    lt_1005-iftim      = ls_1003-iftim.
    lt_1005-ifnam      = ls_1003-ifnam.
    MODIFY lt_1005. CLEAR lt_1005.
  ENDLOOP.

  LOOP AT lt_1006.
    lt_1006-zsystem_id = gv_tar.
    lt_1006-zstat      = lv_result.
    lt_1006-zifkey     = ls_1003-zifkey.
    lt_1006-zmessage   = ls_1003-zmessage.
    lt_1006-ifdat      = ls_1003-ifdat.
    lt_1006-iftim      = ls_1003-iftim.
    lt_1006-ifnam      = ls_1003-ifnam.
    MODIFY lt_1006. CLEAR lt_1006.
  ENDLOOP.
*
*
  IF lt_1003[] IS NOT INITIAL.
    MODIFY zgtsdt1003 FROM TABLE lt_1003.
  ENDIF.

  IF lt_1004[] IS NOT INITIAL.
    MODIFY zgtsdt1004 FROM TABLE lt_1004.
  ENDIF.

  IF lt_1005[] IS NOT INITIAL.
    MODIFY zgtsdt1005 FROM TABLE lt_1005.
  ENDIF.

  IF lt_1006[] IS NOT INITIAL.
    MODIFY zgtsdt1006 FROM TABLE lt_1006.
  ENDIF.

  PERFORM data_query.
  PERFORM refresh_table_display USING go_grid space.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESEND_IF2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM resend_if2 .
  RANGES : lr_erdat FOR sy-datlo.

  DATA : lv_subrc  TYPE sy-subrc,
         lv_cnt    TYPE i,
         lv_result TYPE zo_result,
         lv_dest   TYPE zifdest-dest,
         lv_msg    TYPE zo_message,
         lt_tmp    LIKE TABLE OF gs_s0100 WITH EMPTY KEY,
         lt_vbeln  LIKE TABLE OF gs_s0100,
         ls_1003   TYPE zgtsdt1003,
         lt_1003   TYPE TABLE OF zgtsdt1003 WITH HEADER LINE,
         lt_1004   TYPE TABLE OF zgtsdt1004 WITH HEADER LINE,
         lt_1005   TYPE TABLE OF zgtsdt1005 WITH HEADER LINE,
         lt_1006   TYPE TABLE OF zgtsdt1006 WITH HEADER LINE,
         lt_tab_h  TYPE TABLE OF zgtsdsif0002 WITH HEADER LINE,
         lt_tab_i  TYPE TABLE OF zgtsdsif0003 WITH HEADER LINE,
         lt_tab_c  TYPE TABLE OF zgtsdsif0004 WITH HEADER LINE,
         lt_tab_p  TYPE TABLE OF zgtsdsif0005 WITH HEADER LINE.

  __cle : gt_item_r, gt_char_r, gt_partner_r.

  "Selected Rows
  DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                        io_grid = go_grid
                                                        iv_ck   = zgtsd_x
                                                      IMPORTING
                                                        ev_subrc = lv_subrc ).
  CHECK lv_subrc IS INITIAL.

  CLEAR gs_s0100.
  MODIFY gt_s0100 FROM gs_s0100 TRANSPORTING sel WHERE sel IS NOT INITIAL.

  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE gt_s0100 INTO gs_s0100 INDEX ls_row-index.
    CHECK sy-subrc = 0.
    gs_s0100-sel = gc_x.
    APPEND gs_s0100 TO lt_tmp.
    MODIFY gt_s0100 FROM gs_s0100 INDEX ls_row-index.
  ENDLOOP.

  __rng lr_erdat 'I' 'EQ' s_erdat-low sy-datlo.
  SORT lt_tmp BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING vbeln.
  IF lt_tmp[] IS NOT INITIAL.

    SELECT b~vbeln, b~kunnr, b~auart, b~vkorg, b~vtweg, b~spart, b~vkgrp, b~vkbur,
           b~audat, b~vdatu, b~erdat, b~ernam, b~ctlpc, b~erzet,
           b~zpjno, d~zptxt, b~erzet AS aezet, b~erdat AS aedat, "B~AEDAT,
           e~name1, f~vtext AS spart_nm, g~bezei AS vkbur_nm,
           h~bezei AS vkgrp_nm, i~rtext AS ctlpc_nm, @icon_create AS crud
      FROM @lt_tmp AS m INNER JOIN vbak AS b
        ON m~vbeln = b~vbeln
      LEFT OUTER JOIN zsd0106t AS d
        ON b~zpjno = d~zpjno
      LEFT OUTER JOIN kna1 AS e
        ON b~kunnr = e~kunnr
      LEFT OUTER JOIN tspat AS f
        ON b~spart = f~spart
       AND f~spras = @sy-langu
      LEFT OUTER JOIN tvkbt AS g
        ON b~vkbur = g~vkbur
       AND g~spras = @sy-langu  "TVGRT
      LEFT OUTER JOIN tvgrt AS h
        ON b~vkgrp = h~vkgrp
       AND h~spras = @sy-langu
      LEFT OUTER JOIN t691t AS i
        ON b~kkber = i~kkber
       AND b~ctlpc = i~ctlpc
       AND i~spras = @sy-langu
*     WHERE B~ERDAT IN @LR_ERDAT
      APPENDING CORRESPONDING FIELDS OF TABLE @lt_vbeln.

  ENDIF.

**********************************************************************
  PERFORM get_detail_data_r TABLES lt_vbeln.
**********************************************************************

  DATA(lt_for) = lt_vbeln[].
  SORT lt_for BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING vbeln.
  IF lt_for[] IS NOT INITIAL.
    SELECT vbeln, bstkd INTO TABLE @DATA(lt_vbkd)
      FROM vbkd
       FOR ALL ENTRIES IN @lt_for
     WHERE vbeln = @lt_for-vbeln.
  ENDIF.

  SORT lt_vbeln BY vbeln.
  SORT lt_vbkd  BY vbeln.

  LOOP AT lt_vbeln INTO gs_s0100.

    IF gs_s0100-zptxt IS NOT INITIAL.
      DATA(lv_len) = strlen( gs_s0100-zptxt ).
      lv_len -= 1.
      FIND REGEX '[^[:alnum:]]' IN gs_s0100-zptxt+lv_len(1) IN CHARACTER MODE.
      IF sy-subrc = 0.
        CONCATENATE gs_s0100-zptxt(lv_len) '' INTO gs_s0100-zptxt.
      ENDIF.
    ENDIF.

    READ TABLE lt_vbkd INTO DATA(ls_vbkd) WITH KEY vbeln = gs_s0100-vbeln BINARY SEARCH.
    IF sy-subrc = 0.
      gs_s0100-bstkd = ls_vbkd-bstkd.
    ENDIF.

    READ TABLE gt_item_r INTO DATA(ls_item) WITH KEY k_key COMPONENTS vbeln = gs_s0100-vbeln.
    IF sy-subrc = 0.
      gs_s0100-posnr = ls_item-posnr.
      gs_s0100-matnr = ls_item-matnr.
      gs_s0100-werks = ls_item-werks.
    ENDIF.

    MOVE-CORRESPONDING gs_s0100 TO lt_1003.
    APPEND lt_1003. CLEAR lt_1003.

    MOVE-CORRESPONDING gs_s0100 TO lt_tab_h.
    __alpha_ou : gs_s0100-kunnr lt_tab_h-kunnr,
                 gs_s0100-vbeln lt_tab_h-vbeln.

    CALL FUNCTION 'CONVERSION_EXIT_AUART_OUTPUT'
      EXPORTING
        input  = gs_s0100-auart
      IMPORTING
        output = lt_tab_h-auart.
    APPEND lt_tab_h. CLEAR lt_tab_h.

**********************************************************************
*ITEM
    LOOP AT gt_item_r USING KEY k_key INTO ls_item WHERE vbeln = gs_s0100-vbeln.

      MOVE-CORRESPONDING ls_item TO lt_tab_i.
      __alpha_ou : ls_item-posnr lt_tab_i-posnr,
                   ls_item-vbeln lt_tab_i-vbeln,
                   ls_item-matnr lt_tab_i-matnr.
      APPEND lt_tab_i. CLEAR lt_tab_i.

      MOVE-CORRESPONDING ls_item TO lt_1004.
      APPEND lt_1004. CLEAR lt_1004.
    ENDLOOP.

**********************************************************************
*CHAR
    LOOP AT gt_char_r USING KEY k_key INTO DATA(ls_char) WHERE vbeln = gs_s0100-vbeln.

      MOVE-CORRESPONDING ls_char TO lt_tab_c.
      __alpha_ou : ls_char-posnr lt_tab_c-posnr,
                   ls_char-vbeln lt_tab_c-vbeln.
      APPEND lt_tab_c. CLEAR lt_tab_c.

      MOVE-CORRESPONDING ls_char TO lt_1005.
      APPEND lt_1005. CLEAR lt_1005.
    ENDLOOP.

*PARTNER
    LOOP AT gt_partner_r USING KEY k_key INTO DATA(ls_par) WHERE vbeln = gs_s0100-vbeln.

      MOVE-CORRESPONDING ls_par TO lt_tab_p.
      __alpha_ou : ls_par-posnr lt_tab_p-posnr,
                   ls_par-vbeln lt_tab_p-vbeln,
                   ls_par-kunnr lt_tab_p-kunnr,
                   ls_par-lifnr lt_tab_p-lifnr,
                   ls_par-assigned_bp lt_tab_p-assigned_bp.
      APPEND lt_tab_p. CLEAR lt_tab_p.

      MOVE-CORRESPONDING ls_par TO lt_1006.
      APPEND lt_1006. CLEAR lt_1006.
    ENDLOOP.

  ENDLOOP.

  SORT lt_tmp BY zsystem_id.
  DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING zsystem_id.
  IF lines( lt_tmp ) > 1.
    MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE gc_e.EXIT.
  ELSE.
    READ TABLE lt_tmp INTO DATA(ls_tmp) INDEX 1.
    gv_tar = ls_tmp-zsystem_id.
  ENDIF.

  IF lt_tab_h[] IS INITIAL.
    MESSAGE s003 DISPLAY LIKE gc_e.EXIT.
  ENDIF.

  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'IS'
    IMPORTING
      dest_name             = lv_dest
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.

  IF lv_dest IS  INITIAL.
    MESSAGE s000 WITH TEXT-e04 DISPLAY LIKE gc_e.EXIT.
  ENDIF.

  CLEAR gv_answer.
  gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space iv_messa = TEXT-m03 ).
  CHECK gv_answer EQ zgtsd_j.

  TRY.
      CALL FUNCTION 'ZGTSD_IF_O_SALESORDER_INFO'
        DESTINATION lv_dest
        EXPORTING
          i_system_id           = gv_tar
        IMPORTING
          zo_result             = lv_result
          zo_message            = lv_msg
        TABLES
          ot_tab_h              = lt_tab_h
          ot_tab_i              = lt_tab_i
          ot_tab_c              = lt_tab_c
          ot_tab_p              = lt_tab_p
        EXCEPTIONS
          system_failure        = 1 MESSAGE lv_msg
          communication_failure = 2 MESSAGE lv_msg
          illegalname           = 3
          OTHERS                = 4.
      IF sy-subrc NE 0.
        lv_result = |01|.
      ENDIF.

    CATCH cx_root INTO DATA(lo_err).
      MESSAGE s000 WITH lo_err->get_longtext( ) DISPLAY LIKE gc_e.EXIT.
  ENDTRY.

  CLEAR ls_1003.
  GET TIME STAMP FIELD ls_1003-zifkey.
  ls_1003-ifdat      = sy-datlo.
  ls_1003-iftim      = sy-uzeit.
  ls_1003-ifnam      = sy-uname.
  ls_1003-zsystem_id = gv_tar.
  ls_1003-zstat      = lv_result.

  CASE lv_result.
    WHEN '00' OR '0'.
      ls_1003-zmessage = TEXT-m01.
    WHEN OTHERS.
      IF lv_msg IS INITIAL.
        lv_result = '01'.
        ls_1003-zmessage = TEXT-e02.
      ELSE.
        ls_1003-zmessage = lv_msg.
      ENDIF.
  ENDCASE.

  LOOP AT gt_s0100 INTO gs_s0100 WHERE sel = gc_x.

    CASE lv_result.
      WHEN '00' OR '0'.
        gs_s0100-statu = icon_led_green.
      WHEN OTHERS.
        gs_s0100-statu = icon_led_red.
    ENDCASE.
    gs_s0100-msg   = ls_1003-zmessage.
    gs_s0100-ifdat = ls_1003-ifdat.
    gs_s0100-iftim = ls_1003-iftim.
    gs_s0100-ifnam = ls_1003-ifnam.
    MODIFY gt_s0100 FROM gs_s0100.

  ENDLOOP.
**********************************************************************
*LOG
**********************************************************************
  LOOP AT lt_1003.
    lt_1003-zsystem_id = gv_tar.
    lt_1003-zstat      = lv_result.
    lt_1003-zifkey     = ls_1003-zifkey.
    lt_1003-zmessage   = ls_1003-zmessage.
    lt_1003-ifdat      = ls_1003-ifdat.
    lt_1003-iftim      = ls_1003-iftim.
    lt_1003-ifnam      = ls_1003-ifnam.
    MODIFY lt_1003. CLEAR lt_1003.
  ENDLOOP.

  LOOP AT lt_1004.
    lt_1004-zsystem_id = gv_tar.
    lt_1004-zstat      = lv_result.
    lt_1004-zifkey     = ls_1003-zifkey.
    lt_1004-zmessage   = ls_1003-zmessage.
    lt_1004-ifdat      = ls_1003-ifdat.
    lt_1004-iftim      = ls_1003-iftim.
    lt_1004-ifnam      = ls_1003-ifnam.
    MODIFY lt_1004. CLEAR lt_1004.
  ENDLOOP.

  LOOP AT lt_1005.
    lt_1005-zsystem_id = gv_tar.
    lt_1005-zstat      = lv_result.
    lt_1005-zifkey     = ls_1003-zifkey.
    lt_1005-zmessage   = ls_1003-zmessage.
    lt_1005-ifdat      = ls_1003-ifdat.
    lt_1005-iftim      = ls_1003-iftim.
    lt_1005-ifnam      = ls_1003-ifnam.
    MODIFY lt_1005. CLEAR lt_1005.
  ENDLOOP.

  LOOP AT lt_1006.
    lt_1006-zsystem_id = gv_tar.
    lt_1006-zstat      = lv_result.
    lt_1006-zifkey     = ls_1003-zifkey.
    lt_1006-zmessage   = ls_1003-zmessage.
    lt_1006-ifdat      = ls_1003-ifdat.
    lt_1006-iftim      = ls_1003-iftim.
    lt_1006-ifnam      = ls_1003-ifnam.
    MODIFY lt_1006. CLEAR lt_1006.
  ENDLOOP.
*
*
  IF lt_1003[] IS NOT INITIAL.
    MODIFY zgtsdt1003 FROM TABLE lt_1003.
  ENDIF.

  IF lt_1004[] IS NOT INITIAL.
    MODIFY zgtsdt1004 FROM TABLE lt_1004.
  ENDIF.

  IF lt_1005[] IS NOT INITIAL.
    MODIFY zgtsdt1005 FROM TABLE lt_1005.
  ENDIF.

  IF lt_1006[] IS NOT INITIAL.
    MODIFY zgtsdt1006 FROM TABLE lt_1006.
  ENDIF.

  PERFORM data_query.
  PERFORM refresh_table_display USING go_grid space.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DETAIL_DATA_R
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_VBELN
*&---------------------------------------------------------------------*
FORM get_detail_data_r  TABLES  pt_vbeln STRUCTURE gs_s0100.

  DATA : lt_conf_out TYPE TABLE OF conf_out WITH HEADER LINE,
         lv_cnt      TYPE n LENGTH 3.

*11-3) 주문수량 확정된 ITEM 정보 발췌
  DATA(lt_header) = pt_vbeln[].
  SORT lt_header  BY vbeln .
  DELETE ADJACENT DUPLICATES FROM lt_header COMPARING vbeln.
  IF lt_header[] IS NOT INITIAL.
    SELECT p~vbeln, p~posnr, p~matnr, p~kdmat, p~bedae, p~kwmeng, p~vrkme,
           p~abgru, p~netwr, p~waerk, p~werks, p~lgort,
           e~edatu, p~erdat, p~ernam, p~aedat
      FROM @lt_header AS a INNER JOIN vbap AS p
        ON a~vbeln EQ p~vbeln
     INNER JOIN vbep AS e
        ON e~vbeln EQ p~vbeln
       AND e~posnr EQ p~posnr
     WHERE e~wmeng NE '0'
       AND p~werks IN @gr_werks
       AND p~vstel IN @gr_vstel
      INTO CORRESPONDING FIELDS OF TABLE @gt_item_r.
  ENDIF.

  LOOP AT gt_item_r INTO gs_item.

*  12) Characteritics 정보 발췌
    __cle lt_conf_out. CLEAR lv_cnt.
    CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC_TABLE'
      EXPORTING
        i_vbeln                      = gs_item-vbeln
        i_posnr                      = gs_item-posnr
      TABLES
        et_char                      = lt_conf_out
      EXCEPTIONS
        instance_not_found           = 1
        instance_is_a_classification = 2
        invalid_data                 = 3
        OTHERS                       = 4.

    LOOP AT lt_conf_out.

      IF lt_conf_out-atnam NOT IN gr_atnam.
        CONTINUE.
      ENDIF.

      ADD 1 TO lv_cnt.
      MOVE-CORRESPONDING lt_conf_out TO gt_char_r.
      gt_char_r-vbeln = gs_item-vbeln.
      gt_char_r-posnr = gs_item-posnr.
      gt_char_r-seqno = lv_cnt.
      APPEND gt_char_r. CLEAR gt_char_r.
    ENDLOOP.

  ENDLOOP.

  lt_header[] = pt_vbeln[].
  SORT lt_header  BY vbeln .
  IF lt_header[] IS NOT INITIAL.
    SELECT vbeln, posnr, parvw, kunnr, lifnr, assigned_bp
      INTO CORRESPONDING FIELDS OF TABLE @gt_partner_r
      FROM vbpa
      FOR ALL ENTRIES IN @lt_header
     WHERE vbeln = @lt_header-vbeln.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_query_go
*&---------------------------------------------------------------------*
FORM data_query_go .

**
* 1) Target System set.
  PERFORM set_if_target_system_go.

* 2) Range value set.
  PERFORM make_sales_range_values_go.

* 3) Make Header Data.
  PERFORM make_head_data_for_mes_go.

* 4) Make Item Data.
  PERFORM make_item_data_for_mes_go.

* 5) Make Partner Funciton Data
  PERFORM make_partner_dat_for_mes_go.

* 6) Make Characteristics Data
  PERFORM make_char_data_for_mes_go.

* 7) Make Drum Label Data.
  PERFORM make_drum_data_for_mes_go.

* 8) Make Display tab.
  PERFORM make_display_data_go.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_if_Target_system_go
*&---------------------------------------------------------------------*
FORM set_if_target_system_go .

**
  CLEAR: gv_tar.
  __cle: gr_targ.

  IF     rb_disp = gc_x.
    gr_targ[] = s_targ[].

    IF gv_go = gc_x.
      gv_tar = VALUE #( s_targ[ 1 ]-low  OPTIONAL ).
    ENDIF.

  ELSEIF rb_send = gc_x.

    CASE gc_x.
      WHEN rb_t1.
        gv_tar = gc_kpcm.

      WHEN rb_10.
        gv_tar = gc_kscm. "소재MOM

      WHEN rb_go.    " 가온통신 MES
        gv_tar = gc_kgom.

      WHEN rb_gp.    " 가온전력 MES
        gv_tar = gc_kgpm.

    ENDCASE.

    IF gv_tar IS NOT INITIAL.
      gr_targ[] = VALUE #( ( sign = 'I'  option = 'EQ'  low = gv_tar ) ).
    ENDIF.

  ENDIF.


**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_sales_range_values_go
*&---------------------------------------------------------------------*
FORM make_sales_range_values_go .

**
  CHECK: gr_targ[] IS NOT INITIAL.

  __cle: gr_werks, gr_auart, gr_vkorg, gr_vtweg, gr_spart.

* Get Code value
  SELECT zgtppt1010~* INTO TABLE @DATA(lt_code)
    FROM zgtppt1010
   WHERE module_kind EQ 'SD'
     AND codegrp IN ('1010','1020')
     AND fld_01  IN @gr_targ.
  IF sy-subrc NE 0.
    MESSAGE s000 WITH TEXT-e01 DISPLAY LIKE gc_e.
    gv_error = gc_x.
  ENDIF.

  CHECK: gv_error IS INITIAL.

* Get Plant.
  SELECT DISTINCT @zgtsd_i AS sign, @zgtsd_eq AS option, fld_03 AS low
    FROM zgtppt1010
   WHERE module_kind EQ 'PP'
     AND codegrp EQ '0010'
     AND fld_01  IN @gr_targ
    INTO CORRESPONDING FIELDS OF TABLE @gr_werks.

* Make Ranges.
  LOOP AT lt_code INTO DATA(ls_code).

    CASE ls_code-codegrp.
      WHEN '1010'.
        gr_vkorg[] = VALUE #( BASE gr_vkorg[] ( sign   = 'I'
                                                option = 'EQ'
                                                low    = ls_code-fld_03 ) ).

        gr_vtweg[] = VALUE #( BASE gr_vtweg[] ( sign   = 'I'
                                                option = 'EQ'
                                                low    = ls_code-fld_04 ) ).

        gr_spart[] = VALUE #( BASE gr_spart[] ( sign   = 'I'
                                                option = 'EQ'
                                                low    = ls_code-fld_05 ) ).
      WHEN '1020'.
        CASE ls_code-fld_03.
          WHEN 'AUART'.
            gr_auart[] = VALUE #( BASE gr_auart[] ( sign   = 'I'
                                                    option = 'EQ'
                                                    low    = ls_code-fld_04 ) ).
          WHEN 'ATNAM'.
            gr_atnam[] = VALUE #( BASE gr_atnam[] ( sign   = 'I'
                                                    option = 'EQ'
                                                    low    = ls_code-fld_04 ) ).
          WHEN 'VSTEL'.
            gr_vstel[] = VALUE #( BASE gr_vstel[] ( sign   = 'I'
                                                    option = 'EQ'
                                                    low    = ls_code-fld_04 ) ).
        ENDCASE.

    ENDCASE.

  ENDLOOP.

**
  FREE: lt_code.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_head_data_for_mes_go
*&---------------------------------------------------------------------*
FORM make_head_data_for_mes_go .

**
  CHECK: gv_error IS INITIAL.

  __cle: gt_if_head.

  PERFORM get_target_sales_order_go .

  DATA(lt_vbeln) = gt_vbeln[].

  IF lt_vbeln[] IS NOT INITIAL.

*   Header 기본정보 구성
    SELECT b~*,
           CAST( b~erdat AS CHAR ) AS erdat,
           CAST( b~audat AS CHAR ) AS audat,
           CAST( b~vdatu AS CHAR ) AS vdatu,
           CAST( b~erzet AS CHAR ) AS erzet,
*           CAST( b~aedat AS CHAR ) AS aedat,
           CAST( upd~upd_dat AS CHAR ) AS aedat,
           d~bstkd, coalesce( e~zzyuscd, f~zzyuscd ) AS zzyuscd,
*           c~zptxt,
           CAST( upd~upd_tim AS CHAR ) AS aezet
*           upd~upd_tim AS aezet
    FROM @lt_vbeln AS a  INNER JOIN vbak AS b
                         ON  a~vbeln EQ b~vbeln
                         INNER JOIN zgtsd_i_salesdoc_upd_date AS upd
                         ON  b~vbeln EQ upd~vbeln
*                         INNER JOIN zsd0106t AS c
*                         ON  b~zpjno EQ c~zpjno
                         INNER JOIN vbkd AS d
                         ON  b~vbeln EQ d~vbeln
                         AND d~posnr EQ '000000'
                         LEFT JOIN zgtsdt1103 AS e
                         ON  b~vkorg EQ e~vkorg
                         AND b~vkgrp EQ e~vkgrp
                         AND d~kdkg4 EQ e~kdkg4
                         LEFT JOIN zgtsdt1104 AS f
                         ON  b~vkorg EQ f~vkorg
                         AND b~vkgrp EQ f~vkgrp
    INTO CORRESPONDING FIELDS OF TABLE @gt_if_head.

  ENDIF.

* Get Header Text
  PERFORM get_sales_order_header_text_go.

**
  FREE: lt_vbeln.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_target_sales_order_go
*&---------------------------------------------------------------------*
FORM get_target_sales_order_go .

**
  __cle: gt_vbeln, gt_log.

  IF s_erdat-high IS INITIAL AND s_erdat-low IS NOT INITIAL.
    s_erdat-high = s_erdat-low.
  ENDIF.

  IF     rb_send = gc_x.    " 전송
*   생성/변경/삭제 판매오더 번호 조회.
    SELECT DISTINCT a~vbeln
      FROM zgtsd_cv_get_so_history_union( p_date_from = @s_erdat-low,
                                          p_date_to   = @s_erdat-high ) AS a
    WHERE a~vbeln IN @s_vbeln
      AND a~vkorg IN @gr_vkorg
      AND a~vtweg IN @gr_vtweg
      AND a~spart IN @gr_spart
      AND a~auart IN @gr_auart
      AND a~werks IN @gr_werks
    ORDER BY a~vbeln
    INTO CORRESPONDING FIELDS OF TABLE @gt_vbeln.

  ELSEIF rb_disp = gc_x.    " 로그 조회(재처리)
*   로그 조회(재처리)
    SELECT a~*, b~erzet
      INTO CORRESPONDING FIELDS OF TABLE @gt_log
      FROM zgtsdt1003 AS a  LEFT OUTER JOIN vbak AS b
                            ON a~vbeln = b~vbeln
      WHERE a~vbeln      IN @s_vbeln
        AND a~zsystem_id IN @gr_targ
        AND a~ifdat      IN @s_erdat2.

    CASE gc_x.
      WHEN rb_su.
        DELETE gt_log  WHERE zstat NE '00'
                         AND zstat NE '0'.
      WHEN rb_fa.
        DELETE gt_log  WHERE zstat EQ '00'
                          OR zstat EQ '0'.
    ENDCASE.

    IF gt_log[] IS NOT INITIAL.

      SORT: gt_log BY vbeln ASCENDING ifdat DESCENDING iftim DESCENDING .
      DELETE ADJACENT DUPLICATES FROM gt_log COMPARING vbeln.

      gt_vbeln[] = CORRESPONDING #( gt_log[] ).
      SORT: gt_vbeln BY vbeln.
      DELETE ADJACENT DUPLICATES FROM gt_vbeln COMPARING vbeln.

    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_sales_order_header_text_go
*&---------------------------------------------------------------------*
FORM get_sales_order_header_text_go .

  DATA: lt_lines  TYPE TABLE OF tline,
        lv_tdname TYPE tdobname,
        lv_remark TYPE zgte_bd_zremark.

**
  CHECK: gt_if_head[] IS NOT INITIAL.

  DATA(lt_vbeln) = gt_if_head[].

  SELECT a~vbeln
    FROM @lt_vbeln AS a INNER JOIN stxh AS b
                        ON  a~vbeln    EQ b~tdname
                        AND b~tdobject EQ 'VBBK'
                        AND b~tdid     EQ '0001'
                        AND b~tdspras  EQ @sy-langu
    INTO TABLE @DATA(lt_hdtxt).

  IF lt_hdtxt[] IS NOT INITIAL.

    LOOP AT lt_hdtxt  INTO DATA(ls_hdtxt).

      CLEAR: lv_tdname.
      lv_tdname = ls_hdtxt-vbeln.

      __cle: lt_lines.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client                  = sy-mandt
          id                      = '0001'
          language                = sy-langu
          name                    = lv_tdname
          object                  = 'VBBK'
        TABLES
          lines                   = lt_lines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.

      IF lt_lines[] IS NOT INITIAL.

        CLEAR: lv_remark.
        LOOP AT lt_lines  INTO DATA(ls_lines).

          IF ls_lines-tdline IS NOT INITIAL.
            IF lv_remark IS INITIAL.
              lv_remark = ls_lines-tdline.
            ELSE.
              lv_remark = |{ lv_remark } | && |{ '/' }| && | { ls_lines-tdline }|.
            ENDIF.
          ENDIF.

        ENDLOOP.

        IF lv_remark IS NOT INITIAL.

          READ TABLE gt_if_head  ASSIGNING FIELD-SYMBOL(<lfs_wa>)
                                 WITH KEY vbeln = ls_hdtxt-vbeln.
          IF sy-subrc = 0.
            <lfs_wa>-remark = lv_remark.
          ENDIF.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDIF.

**
  FREE: lt_vbeln, lt_lines.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_item_data_for_mes_go
*&---------------------------------------------------------------------*
FORM make_item_data_for_mes_go .

**
  CHECK: gv_error     IS INITIAL,
         gt_if_head[] IS NOT INITIAL.

  __cle: gt_if_item.

  SELECT b~*,
         CAST( b~erdat     AS CHAR ) AS erdat,
         CAST( b~erzet     AS CHAR ) AS erzet,
         CAST( b~aedat     AS CHAR ) AS aedat,
         CAST( c~max_edatu AS CHAR ) AS edatu,
         CASE WHEN b~abgru IS NOT INITIAL
                   THEN 'D'
                   ELSE 'U'
              END AS zflag
*         CAST( upd~upd_tim AS CHAR ) AS aezet
   FROM @gt_if_head AS a  INNER JOIN vbap AS b
                          ON  a~vbeln = b~vbeln
                          INNER JOIN zgtsd_cv_vbep_max AS c
                          ON  b~vbeln = c~vbeln
                          AND b~posnr = c~posnr
                          INNER JOIN zgtsd_i_salesdoc_upd_date AS upd
                          ON  b~vbeln = upd~vbeln
   INTO CORRESPONDING FIELDS OF TABLE @gt_if_item.

* Get Item Text
  PERFORM get_sales_order_item_text_go.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_sales_order_item_text_go
*&---------------------------------------------------------------------*
FORM get_sales_order_item_text_go .

*  DATA: lt_lines  TYPE TABLE OF tline.
*        lv_remark TYPE zgte_bd_zremark.

**
  CHECK: gt_if_item[] IS NOT INITIAL.

  WITH +key AS ( SELECT concat( a~vbeln, a~posnr ) AS tdname
                   FROM @gt_if_item AS a
                  GROUP BY concat( a~vbeln, a~posnr ) )

  SELECT b~tdname
    FROM +key AS a  INNER JOIN stxh AS b
                    ON  a~tdname   EQ b~tdname
                    AND b~tdobject EQ 'VBBP'
                    AND b~tdid     EQ '0001'
                    AND b~tdspras  EQ @sy-langu
    INTO TABLE @DATA(lt_tdnam).

  IF lt_tdnam[] IS NOT INITIAL.

    LOOP AT lt_tdnam  INTO DATA(ls_tdnam).

      DATA(lv_vbeln) = ls_tdnam-tdname(10).
      DATA(lv_posnr) = ls_tdnam-tdname+10(6).

      READ TABLE gt_if_item  ASSIGNING FIELD-SYMBOL(<lfs_wa>)
                             WITH KEY vbeln = lv_vbeln
                                      posnr = lv_posnr.
      IF sy-subrc = 0.

        PERFORM get_remark_from_readtext_go
                USING: ls_tdnam-tdname
                       'VBBP'
                       '0001'
                       CHANGING <lfs_wa>-remark,
                       ls_tdnam-tdname
                       'VBBP'
                       'ZG01'
                       CHANGING <lfs_wa>-inspc_remark.

      ENDIF.

*      __cle: lt_lines.
*      CALL FUNCTION 'READ_TEXT'
*        EXPORTING
*          client                  = sy-mandt
*          id                      = '0001'
*          language                = sy-langu
*          name                    = ls_tdnam-tdname
*          object                  = 'VBBP'
*        TABLES
*          lines                   = lt_lines
*        EXCEPTIONS
*          id                      = 1
*          language                = 2
*          name                    = 3
*          not_found               = 4
*          object                  = 5
*          reference_check         = 6
*          wrong_access_to_archive = 7
*          OTHERS                  = 8.
*
*      IF lt_lines[] IS NOT INITIAL.
*
*        CLEAR: lv_remark.
*        LOOP AT lt_lines  INTO DATA(ls_lines).
*
*          IF ls_lines-tdline IS NOT INITIAL.
*            IF lv_remark IS INITIAL.
*              lv_remark = ls_lines-tdline.
*            ELSE.
*              lv_remark = |{ lv_remark } | && |{ '/' }| && | { ls_lines-tdline }|.
*            ENDIF.
*          ENDIF.
*
*        ENDLOOP.
*
*        IF lv_remark IS NOT INITIAL.
*
*          DATA(lv_vbeln) = ls_tdnam-tdname(10).
*          DATA(lv_posnr) = ls_tdnam-tdname+10(6).
*
*          READ TABLE gt_if_item  ASSIGNING FIELD-SYMBOL(<lfs_wa>)
*                                 WITH KEY vbeln = lv_vbeln
*                                          posnr = lv_posnr.
*          IF sy-subrc = 0.
*            <lfs_wa>-remark = lv_remark.
*          ENDIF.
*
*        ENDIF.
*
*      ENDIF.

    ENDLOOP.

  ENDIF.

**
  FREE: lt_tdnam.    ", lt_lines.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_partner_dat_for_mes_go
*&---------------------------------------------------------------------*
FORM make_partner_dat_for_mes_go .

**
  CHECK: gv_error     IS INITIAL,
         gt_if_head[] IS NOT INITIAL.

  __cle: gt_if_prtn.

  WITH +vbeln AS ( SELECT a~vbeln
                     FROM @gt_if_head AS a
                    GROUP BY a~vbeln )

  SELECT a~vbeln,
         b~posnr, b~parvw, b~kunnr, b~lifnr, b~assigned_bp
    FROM +vbeln AS a  INNER JOIN vbpa AS b
                      ON  a~vbeln EQ b~vbeln
                      AND b~posnr EQ '000000'
  INTO CORRESPONDING FIELDS OF TABLE @gt_if_prtn.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_char_data_for_mes_go
*&---------------------------------------------------------------------*
FORM make_char_data_for_mes_go .

  DATA: lv_seq     LIKE zgtsdsif0004-seqno,
        ls_if_char LIKE zgtsdsif0004.

**
  CHECK: gv_error     IS INITIAL,
         gt_if_item[] IS NOT INITIAL.

  __cle: gt_if_char.

  SELECT a~vbeln, a~posnr,
         b~atnam, b~atbez, CAST( b~atflv AS DEC( 13, 3 ) ) AS atflv,
         b~atwrt, b~atfor
    FROM @gt_if_item AS a  INNER JOIN zgtmm_cv_bd_get_vcofso AS b
                           ON  a~vbeln = b~vbeln
                           AND a~posnr = b~posnr
   WHERE b~atnam IN @gr_atnam
    INTO TABLE @DATA(lt_char).

  IF lt_char[] IS NOT INITIAL.

    DATA(lt_data) = lt_char[].
    SORT: lt_data BY vbeln posnr,
          lt_char BY vbeln posnr.
    DELETE ADJACENT DUPLICATES FROM lt_data COMPARING vbeln posnr.

    LOOP AT lt_data  INTO DATA(ls_data).

      CLEAR: lv_seq.
      READ TABLE lt_char  INTO DATA(ls_char)
                          WITH KEY vbeln = ls_data-vbeln
                                   posnr = ls_data-posnr.
      IF sy-subrc = 0.
        LOOP AT lt_char INTO ls_char  FROM sy-tabix.
          IF ls_char-vbeln = ls_data-vbeln AND
             ls_char-posnr = ls_data-posnr.

            lv_seq = lv_seq + 1.

            CLEAR: ls_if_char.
            ls_if_char = VALUE #( vbeln = ls_char-vbeln
                                  posnr = ls_char-posnr
                                  seqno = lv_seq
                                  atnam = ls_char-atnam ).

            IF ls_char-atfor = 'NUM'.
              ls_if_char-atwrt = ls_char-atflv.
            ELSE.
              ls_if_char-atwrt = ls_char-atwrt.
            ENDIF.

*           PD_CA_MARK_CONTENTS_* 특성값 Condense 제외
            IF ls_char-atnam(19) NE 'PD_CA_MARK_CONTENTS' .
              CONDENSE ls_if_char-atwrt NO-GAPS.
            ENDIF.

            APPEND ls_if_char TO gt_if_char.

*            APPEND VALUE #( vbeln = ls_char-vbeln
*                            posnr = ls_char-posnr
*                            seqno = lv_seq
*                            atnam = ls_char-atnam
*                            atwrt = COND #( WHEN ls_char-atfor = 'NUM'
*                                                 THEN ls_char-atflv
*                                                 ELSE ls_char-atwrt )
*                           ) TO gt_if_char.

          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDIF.

**
  FREE: lt_char, lt_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_drum_data_for_mes_go
*&---------------------------------------------------------------------*
FORM make_drum_data_for_mes_go .

**
  CHECK: gv_error     IS INITIAL,
         gt_if_item[] IS NOT INITIAL.

  __cle: gt_if_drum.

  SELECT b~*
    FROM @gt_if_item AS a  INNER JOIN zgtsdt1199 AS b
                           ON  a~vbeln EQ b~vbeln
                           AND a~posnr EQ b~posnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_if_drum.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_display_data_go
*&---------------------------------------------------------------------*
FORM make_display_data_go .

  DATA: lv_continue(1).

**
  CHECK: gv_error     IS INITIAL,
         gt_if_head[] IS NOT INITIAL.
*         sy-batch     IS INITIAL.    " [가온전선-SD] 2026.06.18

  SORT: gt_if_head BY vbeln,
        gt_if_prtn BY vbeln,
        gt_if_item BY vbeln posnr,
        gt_if_char BY vbeln posnr,
        gt_if_drum BY vbeln posnr.

  __cle: gt_s0100.

  PERFORM get_change_log_and_iflog_go.

  LOOP AT gt_if_head  INTO DATA(ls_head).

    CLEAR: lv_continue.

    CLEAR: gs_s0100.
    MOVE-CORRESPONDING: ls_head TO gs_s0100.

*   Project 명.
    IF gs_s0100-zptxt IS NOT INITIAL.

      DATA(lv_len) = strlen( gs_s0100-zptxt ).
      lv_len -= 1.
      FIND REGEX '[^[:alnum:]]' IN gs_s0100-zptxt+lv_len(1) IN CHARACTER MODE.
      IF sy-subrc = 0.
        CONCATENATE gs_s0100-zptxt(lv_len) '' INTO gs_s0100-zptxt.
      ENDIF.

    ENDIF.

*   Status / CRUD Set.
    PERFORM set_status_and_crud_go    CHANGING gs_s0100
                                               lv_continue.

    CASE gv_tar.
      WHEN gc_kpcm.
        gs_s0100-zsystem_id = gc_kpcm.
        gs_s0100-system_nm  = TEXT-s06.

      WHEN gc_kscm.
        gs_s0100-zsystem_id = gc_kscm.
        gs_s0100-system_nm  = TEXT-s12.

      WHEN gc_kgom.
        gs_s0100-zsystem_id = gc_kgom.
        gs_s0100-system_nm  = TEXT-s13.    " 가온통신MES

      WHEN gc_kgpm.
        gs_s0100-zsystem_id = gc_kgpm.
        gs_s0100-system_nm  = TEXT-s14.    " 가온전력MES

    ENDCASE.

**  Description
    PERFORM get_name_description_go  CHANGING gs_s0100.

    APPEND gs_s0100 TO gt_s0100.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_change_log_and_iflog_go
*&---------------------------------------------------------------------*
FORM get_change_log_and_iflog_go .

**
  CHECK: gt_if_head[] IS NOT INITIAL,
         rb_send      EQ gc_x.

  __cle: gt_change, gt_log.

* Change Log
  SELECT b~*
    FROM @gt_if_head AS a  INNER JOIN cdhdr AS b
                           ON  a~vbeln      = b~objectid
                           AND b~objectclas = 'VERKBELEG'
   WHERE b~udate IN @s_erdat
    INTO CORRESPONDING FIELDS OF TABLE @gt_change.

  IF gt_change[] IS NOT INITIAL.
    SORT: gt_change BY objectid changenr ASCENDING utime DESCENDING.
    DELETE ADJACENT DUPLICATES FROM gt_change COMPARING objectid changenr.

  ENDIF.

* I/F Log.
*  select b~*, c~erzet
  SELECT b~*, c~erzet
   FROM @gt_if_head AS a  INNER JOIN zgtsdt1003 AS b
                          ON a~vbeln = b~vbeln
                          LEFT OUTER JOIN vbak AS c
                          ON a~vbeln = c~vbeln
    INTO CORRESPONDING FIELDS OF TABLE @gt_log.

  IF gt_log[] IS NOT INITIAL.
    SORT: gt_log BY vbeln.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_status_and_crud_go
*&---------------------------------------------------------------------*
FORM set_status_and_crud_go  CHANGING ps_data  LIKE gs_s0100
                                      pe_continue.

  DATA: lv_objectid  LIKE cdhdr-objectid.

**
  CLEAR: lv_objectid.
  IF     rb_send = gc_x.    " 전송

*   Check I/F log Status
    IF rb_t1 = 'X'.

      DATA(ls_log) = VALUE #( gt_log[ vbeln = ps_data-vbeln ]
                              OPTIONAL ).

      IF ls_log IS NOT INITIAL AND
         ls_log-zstat = |00| OR ls_log-zstat = |0|.
        pe_continue = gc_x.
      ENDIF.

    ENDIF.

    CHECK: pe_continue IS INITIAL.

*   Set CRUD.
    lv_objectid = ps_data-vbeln.

    DATA(ls_chg) = VALUE #( gt_change[ objectid = lv_objectid ]
                            OPTIONAL ).

    IF ls_chg IS NOT INITIAL.
      ps_data-crud     = icon_change.

      ps_data-aezet    = ls_chg-utime.
      ps_data-changenr = ls_chg-changenr.

    ELSE.
      ps_data-crud = icon_create.
    ENDIF.

    ps_data-statu = icon_led_inactive.

  ELSEIF rb_disp = gc_x.    " 로그 조회(재처리)

    CLEAR: ls_log.
    ls_log = VALUE #( gt_log[ vbeln = ps_data-vbeln ]
                      OPTIONAL ).

    IF ls_log IS NOT INITIAL.

      CASE ps_data-zstat.
        WHEN '00' OR '0'.
          ps_data-statu = icon_led_green.
        WHEN '01'.
          ps_data-statu = icon_led_red.
      ENDCASE.

      ps_data-ifdat  = ls_log-ifdat.
      ps_data-iftim  = ls_log-iftim.
      ps_data-ifnam  = ls_log-ifnam.
      ps_data-zstat  = ls_log-zstat.
      ps_data-zifkey = ls_log-zifkey.
      ps_data-msg    = ls_log-zmessage.

    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_name_description_go
*&---------------------------------------------------------------------*
FORM get_name_description_go  CHANGING ps_data  LIKE gs_s0100.

**
  IF ps_data-kunnr IS NOT INITIAL.
    SELECT SINGLE name1  INTO @ps_data-name1
      FROM kna1  WHERE kunnr EQ @ps_data-kunnr.
  ENDIF.

  IF ps_data-spart IS NOT INITIAL.
    SELECT SINGLE vtext  INTO @ps_data-spart_nm
      FROM tspat  WHERE spart EQ @ps_data-spart
                    AND spras EQ @sy-langu.
  ENDIF.

  IF ps_data-vkgrp IS NOT INITIAL.
    SELECT SINGLE bezei  INTO @ps_data-vkgrp_nm
      FROM tvgrt  WHERE vkgrp EQ @ps_data-vkgrp
                    AND spras EQ @sy-langu.
  ENDIF.

  IF ps_data-vkbur IS NOT INITIAL.
    SELECT SINGLE bezei  INTO @ps_data-vkbur_nm
      FROM tvkbt  WHERE vkbur EQ @ps_data-vkbur
                    AND spras EQ @sy-langu.
  ENDIF.

  IF ps_data-ctlpc IS NOT INITIAL.
    SELECT SINGLE b~rtext  INTO @ps_data-ctlpc_nm
      FROM vbak AS a  INNER JOIN t691t AS b
                      ON a~kkber = b~kkber
     WHERE a~vbeln EQ @ps_data-vbeln
       AND b~ctlpc EQ @ps_data-ctlpc
       AND b~spras EQ @sy-langu.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form send_if_go
*&---------------------------------------------------------------------*
FORM send_if_go .

**
  CHECK: gv_error     IS INITIAL.

  __cle: gt_1003_go,    gt_1004_go,    gt_1005_go,    gt_1006_go,
         gt_1095_go,
         gt_if_head_go, gt_if_item_go, gt_if_char_go, gt_if_prtn_go,
         gt_if_drum_go.

  PERFORM check_select_itab_go .

  PERFORM make_if_tab_and_log_tab_go .

* MES Interface.
  PERFORM mes_if_salesorder_info_go .

  IF sy-batch IS INITIAL AND
     gv_error IS INITIAL.
    PERFORM refresh_table_display USING go_grid space.
  ENDIF.

**
  FREE: gt_s0100_sel,
        gt_1003_go,    gt_1004_go,    gt_1005_go,    gt_1006_go,
        gt_1095_go,
        gt_if_head_go, gt_if_item_go, gt_if_char_go, gt_if_prtn_go,
        gt_if_drum_go.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form conversion_auart_go
*&---------------------------------------------------------------------*
FORM conversion_auart_go  USING    pi_type
                                   pi_auart
                          CHANGING pe_auart.

**
  CHECK: pi_auart IS NOT INITIAL.

  IF     pi_type = 'I'.
    CALL FUNCTION 'CONVERSION_EXIT_AUART_INPUT'
      EXPORTING
        input  = pi_auart
      IMPORTING
        output = pe_auart.

  ELSEIF pi_type = 'O'.
    CALL FUNCTION 'CONVERSION_EXIT_AUART_OUTPUT'
      EXPORTING
        input  = pi_auart
      IMPORTING
        output = pe_auart.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_select_itab_go
*&---------------------------------------------------------------------*
FORM check_select_itab_go .

  DATA: lv_subrc  TYPE sy-subrc.

**
  CHECK: gv_error IS INITIAL.

  __cle: gt_s0100_sel.
  IF sy-batch IS NOT INITIAL.

    CLEAR gs_s0100.
    MODIFY gt_s0100 FROM gs_s0100 TRANSPORTING sel
                    WHERE sel IS NOT INITIAL.

    LOOP AT gt_s0100 ASSIGNING FIELD-SYMBOL(<lfs_wa>).

      IF <lfs_wa>-statu NE icon_led_inactive.
        CONTINUE.
      ENDIF.

      <lfs_wa>-sel = gc_x.

      APPEND <lfs_wa> TO gt_s0100_sel.

    ENDLOOP.

  ELSE.

    CLEAR: lv_subrc.
    DATA(lt_rows) = zgtsd_cl_common=>get_selected_rows( EXPORTING
                                                          io_grid = go_grid
                                                          iv_ck   = zgtsd_x
                                                        IMPORTING
                                                          ev_subrc = lv_subrc ).
    IF lv_subrc IS INITIAL.

      CLEAR gs_s0100.
      MODIFY gt_s0100 FROM gs_s0100 TRANSPORTING sel
                      WHERE sel IS NOT INITIAL.

      LOOP AT lt_rows INTO DATA(ls_row).

        READ TABLE gt_s0100  INDEX ls_row-index  ASSIGNING FIELD-SYMBOL(<lfs_wa2>).
        IF sy-subrc = 0.

          IF <lfs_wa2>-statu NE icon_led_inactive AND
             gv_saveok NE 'R_SEND2'.
            CONTINUE.
          ENDIF.

          <lfs_wa2>-sel = gc_x.

          APPEND <lfs_wa2> TO gt_s0100_sel.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDIF.

  IF gt_s0100_sel[] IS INITIAL.
    gv_error = gc_x.
*   처리가능한 라인을 선택 하세요.
    MESSAGE s003  DISPLAY LIKE gc_e.

  ELSE.

    IF sy-batch IS INITIAL.

      DATA(lt_temp) = gt_s0100_sel[].
      SORT: lt_temp BY zsystem_id.
      DELETE ADJACENT DUPLICATES FROM: lt_temp COMPARING zsystem_id.

      IF lines( lt_temp ) > 1.
        gv_error = 'X'.
*       송신대상 시스템이 복수개입니다.
        MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE gc_e.
        EXIT.
      ELSE.
        gv_tar = VALUE #( lt_temp[ 1 ]-zsystem_id  OPTIONAL ).

      ENDIF.

    ENDIF.

    IF gv_error IS INITIAL.
      SORT: gt_s0100_sel BY vbeln.
      DELETE ADJACENT DUPLICATES FROM: gt_s0100_sel COMPARING vbeln.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_if_tab_and_log_tab_go
*&---------------------------------------------------------------------*
FORM make_if_tab_and_log_tab_go .

  DATA: ls_1003    TYPE zgtsdt1003,
        ls_if_head TYPE zgtsdsif0002.

**
*  CHECK: gt_if_head[] IS NOT INITIAL.
  CHECK: gv_error       IS INITIAL,
         gt_s0100_sel[] IS NOT INITIAL.

  SORT: gt_if_head BY vbeln,
        gt_if_prtn BY vbeln,
        gt_if_item BY vbeln posnr,
        gt_if_char BY vbeln posnr,
        gt_if_drum BY vbeln posnr.

* Header
*  LOOP AT gt_if_head  INTO DATA(ls_head).
  LOOP AT gt_s0100_sel  INTO DATA(ls_head).

*   Header
    CLEAR: ls_1003, ls_if_head.
    MOVE-CORRESPONDING: ls_head TO ls_1003,
                        ls_head TO ls_if_head.
    APPEND ls_1003 TO gt_1003_go.

    ls_if_head-kunnr = condense( |{ ls_head-kunnr ALPHA = OUT }| ).
    ls_if_head-vbeln = condense( |{ ls_head-vbeln ALPHA = OUT }| ).

    PERFORM conversion_auart_go  USING    'O'
                                          ls_head-auart
                                 CHANGING ls_if_head-auart.

    APPEND ls_if_head TO gt_if_head_go.

*   ITEM
    gt_1004_go = VALUE #( BASE gt_1004_go
                          FOR ls_item IN gt_if_item  WHERE ( vbeln = ls_head-vbeln )
                          ( CORRESPONDING #( ls_item ) )
                         ).

    gt_if_item_go = VALUE #( BASE gt_if_item_go
                             FOR ls_item_wa IN gt_if_item  WHERE ( vbeln = ls_head-vbeln )
                             ( VALUE #( BASE CORRESPONDING #( ls_item_wa )
                                        vbeln = condense( |{ ls_item_wa-vbeln ALPHA = OUT }| )
                                        posnr = condense( |{ ls_item_wa-posnr ALPHA = OUT }| )
                                        matnr = condense( |{ ls_item_wa-matnr ALPHA = OUT }| )
                                       )
                              )
                            ).

*   CHAR
    gt_1005_go = VALUE #( BASE gt_1005_go
                          FOR ls_char IN gt_if_char  WHERE ( vbeln = ls_head-vbeln )
                          ( CORRESPONDING #( ls_char ) )
                         ).

    gt_if_char_go = VALUE #( BASE gt_if_char_go
                             FOR ls_char_wa IN gt_if_char  WHERE ( vbeln = ls_head-vbeln )
                             ( VALUE #( BASE CORRESPONDING #( ls_char_wa )
                                        vbeln = condense( |{ ls_char_wa-vbeln ALPHA = OUT }| )
                                        posnr = condense( |{ ls_char_wa-posnr ALPHA = OUT }| )
                                       )
                              )
                            ).

*   PARTNER
    gt_1006_go = VALUE #( BASE gt_1006_go
                          FOR ls_prtn IN gt_if_prtn  WHERE ( vbeln = ls_head-vbeln )
                          ( CORRESPONDING #( ls_prtn ) )
                         ).

    gt_if_prtn_go = VALUE #( BASE gt_if_prtn_go
                             FOR ls_prtn_wa IN gt_if_prtn  WHERE ( vbeln = ls_head-vbeln )
                             ( VALUE #( BASE CORRESPONDING #( ls_prtn_wa )
                                        vbeln       = condense( |{ ls_prtn_wa-vbeln ALPHA = OUT }| )
                                        posnr       = condense( |{ ls_prtn_wa-posnr ALPHA = OUT }| )
                                        kunnr       = condense( |{ ls_prtn_wa-kunnr ALPHA = OUT }| )
                                        lifnr       = condense( |{ ls_prtn_wa-lifnr ALPHA = OUT }| )
                                        assigned_bp = condense( |{ ls_prtn_wa-assigned_bp ALPHA = OUT }| )
                                       )
                              )
                            ).

*   Drum
    gt_1095_go = VALUE #( BASE gt_1095_go
                          FOR ls_drum IN gt_if_drum  WHERE ( vbeln = ls_head-vbeln )
                          ( CORRESPONDING #( ls_drum ) )
                         ).

    gt_if_drum_go = VALUE #( BASE gt_if_drum_go
                             FOR ls_drum_wa IN gt_if_drum  WHERE ( vbeln = ls_head-vbeln )
                             ( VALUE #( BASE CORRESPONDING #( ls_drum_wa )
                                        vbeln = condense( |{ ls_drum_wa-vbeln ALPHA = OUT }| )
                                        posnr = condense( |{ ls_drum_wa-posnr ALPHA = OUT }| )
                                       )
                              )
                            ).

  ENDLOOP.

  IF gt_if_head_go[] IS INITIAL.
*   처리가능한 데이타가 없습니다.
    MESSAGE s000 WITH TEXT-e05 DISPLAY LIKE gc_e.
    gv_error = gc_x.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form mes_if_salesorder_info_go
*&---------------------------------------------------------------------*
FORM mes_if_salesorder_info_go .

  DATA: lv_dest   TYPE zifdest-dest,
        lv_result TYPE zo_result,
        lv_msg    TYPE zo_message.

**
  CHECK: gv_error IS INITIAL.

  PERFORM get_interface_destination_go   CHANGING lv_dest .

  PERFORM send_data_to_mes_go            USING    lv_dest
                                         CHANGING lv_result
                                                  lv_msg .

  PERFORM modify_if_log_table_go         USING    lv_result
                                                  lv_msg.
**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_interface_destination_go
*&---------------------------------------------------------------------*
FORM get_interface_destination_go  CHANGING pe_dest.

**
  CHECK: gv_error IS INITIAL.

  CLEAR: pe_dest.
  CALL FUNCTION 'Z_IF_DESTINATION'
    EXPORTING
      gubun                 = 'IS'
    IMPORTING
      dest_name             = pe_dest
    EXCEPTIONS
      destination_not_found = 1
      OTHERS                = 2.

  IF pe_dest IS INITIAL.
    MESSAGE s000 WITH TEXT-e04 DISPLAY LIKE gc_e.
    gv_error = gc_x.

  ELSE.

    IF sy-batch = ' '.

      CLEAR gv_answer.
      IF gv_saveok EQ 'R_SEND2'.
*       선택한 내용을 재전송 하시겠습니까?
        gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space
                                                       iv_messa = TEXT-m03 ).
      ELSE.
*       선택한 내용을 전송 하시겠습니까?
        gv_answer = zgtsd_cl_common=>popup_to_comfirm( iv_ucomm = space
                                                       iv_messa = TEXT-m02 ).
      ENDIF.

      IF gv_answer NE zgtsd_j.
        gv_error = 'X'.
*       전송이 취소되었습니다.
        MESSAGE s000 WITH TEXT-e06  DISPLAY LIKE gc_e.
      ENDIF.

    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form send_data_to_mes_go
*&---------------------------------------------------------------------*
FORM send_data_to_mes_go  USING    pi_dest
                          CHANGING pe_result TYPE zo_result
                                   pe_msg    TYPE zo_message.

**
  CHECK: gv_error IS INITIAL.

  CLEAR: pe_result, pe_msg.
  TRY.
      CALL FUNCTION 'ZGTSD_IF_O_SALESORDER_INFO'
        DESTINATION pi_dest
        EXPORTING
          i_system_id           = gv_tar
        IMPORTING
          zo_result             = pe_result
          zo_message            = pe_msg
        TABLES
          ot_tab_h              = gt_if_head_go
          ot_tab_i              = gt_if_item_go
          ot_tab_c              = gt_if_char_go
          ot_tab_p              = gt_if_prtn_go
          ot_tab_d              = gt_if_drum_go
        EXCEPTIONS
          system_failure        = 1 MESSAGE pe_msg
          communication_failure = 2 MESSAGE pe_msg
          illegalname           = 3
          OTHERS                = 4.
      IF sy-subrc NE 0.
        pe_result = |01|.
      ENDIF.

    CATCH cx_root INTO DATA(lo_err).
      gv_error = gc_x.
      MESSAGE s000 WITH lo_err->get_longtext( ) DISPLAY LIKE gc_e.
      EXIT.

  ENDTRY.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_if_log_table_go
*&---------------------------------------------------------------------*
FORM modify_if_log_table_go  USING    pi_result  TYPE zo_result
                                      pi_msg     TYPE zo_message.

  DATA: ls_1003  TYPE zgtsdt1003,
        lv_statu TYPE icon_d.

**
  CHECK: gv_error IS INITIAL.

  CLEAR ls_1003.
  GET TIME STAMP FIELD ls_1003-zifkey.

  ls_1003 = VALUE #( BASE ls_1003
                     ifdat      = sy-datlo
                     iftim      = sy-uzeit
                     ifnam      = sy-uname
                     zsystem_id = gv_tar
                     zstat      = pi_result ).

  gv_result  = pi_result.
  gv_message = pi_msg.

  CASE pi_result.
    WHEN '00' OR '0'.
      ls_1003-zmessage = TEXT-m01.
    WHEN OTHERS.
      IF pi_msg IS INITIAL.
        pi_result        = '01'.
        ls_1003-zmessage = TEXT-e02.
      ELSE.
        ls_1003-zmessage = pi_msg.
      ENDIF.
  ENDCASE.

* List Update
  LOOP AT gt_s0100_sel  INTO gs_s0100.

    gv_vbeln = gs_s0100-vbeln.

    CLEAR: lv_statu.
    CASE pi_result.
      WHEN '00' OR '0'.
        lv_statu = icon_led_green.
      WHEN OTHERS.
        lv_statu = icon_led_red.
    ENDCASE.

    MODIFY gt_s0100  FROM VALUE #( statu = lv_statu
                                   msg   = ls_1003-zmessage
                                   ifdat = ls_1003-ifdat
                                   iftim = ls_1003-iftim
                                   ifnam = ls_1003-ifnam )
                     TRANSPORTING statu msg ifdat iftim ifnam
                     WHERE vbeln = gs_s0100-vbeln.

** Log
    MODIFY gt_1003_go  FROM VALUE #( zsystem_id = gv_tar
                                     zstat      = pi_result
                                     zifkey     = ls_1003-zifkey
                                     zmessage   = ls_1003-zmessage
                                     ifdat      = ls_1003-ifdat
                                     iftim      = ls_1003-iftim
                                     ifnam      = ls_1003-ifnam )
                       TRANSPORTING zsystem_id zstat zifkey zmessage
                                    ifdat iftim ifnam
                       WHERE vbeln = gs_s0100-vbeln.

    MODIFY gt_1004_go  FROM VALUE #( zsystem_id = gv_tar
                                     zstat      = pi_result
                                     zifkey     = ls_1003-zifkey
                                     zmessage   = ls_1003-zmessage
                                     ifdat      = ls_1003-ifdat
                                     iftim      = ls_1003-iftim
                                     ifnam      = ls_1003-ifnam )
                       TRANSPORTING zsystem_id zstat zifkey zmessage
                                    ifdat iftim ifnam
                       WHERE vbeln = gs_s0100-vbeln.

    MODIFY gt_1005_go  FROM VALUE #( zsystem_id = gv_tar
                                     zstat      = pi_result
                                     zifkey     = ls_1003-zifkey
                                     zmessage   = ls_1003-zmessage
                                     ifdat      = ls_1003-ifdat
                                     iftim      = ls_1003-iftim
                                     ifnam      = ls_1003-ifnam )
                       TRANSPORTING zsystem_id zstat zifkey zmessage
                                    ifdat iftim ifnam
                       WHERE vbeln = gs_s0100-vbeln.

    MODIFY gt_1006_go  FROM VALUE #( zsystem_id = gv_tar
                                     zstat      = pi_result
                                     zifkey     = ls_1003-zifkey
                                     zmessage   = ls_1003-zmessage
                                     ifdat      = ls_1003-ifdat
                                     iftim      = ls_1003-iftim
                                     ifnam      = ls_1003-ifnam )
                       TRANSPORTING zsystem_id zstat zifkey zmessage
                                    ifdat iftim ifnam
                       WHERE vbeln = gs_s0100-vbeln.

    MODIFY gt_1095_go  FROM VALUE #( zsystem_id = gv_tar
                                     zstat      = pi_result
                                     zifkey     = ls_1003-zifkey
                                     zmessage   = ls_1003-zmessage
                                     ifdat      = ls_1003-ifdat
                                     iftim      = ls_1003-iftim
                                     ifnam      = ls_1003-ifnam )
                       TRANSPORTING zsystem_id zstat zifkey zmessage
                                    ifdat iftim ifnam
                       WHERE vbeln = gs_s0100-vbeln.

  ENDLOOP.

  IF gt_1003_go[] IS NOT INITIAL.
    MODIFY zgtsdt1003 FROM TABLE gt_1003_go[].
  ENDIF.

  IF gt_1004_go[] IS NOT INITIAL.
    MODIFY zgtsdt1004 FROM TABLE gt_1004_go[].
  ENDIF.

  IF gt_1005_go[] IS NOT INITIAL.
    MODIFY zgtsdt1005 FROM TABLE gt_1005_go[].
  ENDIF.

  IF gt_1006_go[] IS NOT INITIAL.
    MODIFY zgtsdt1006 FROM TABLE gt_1006_go[].
  ENDIF.

  IF gt_1095_go[] IS NOT INITIAL.
    MODIFY zgtsdt1095 FROM TABLE gt_1095_go[].
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_remark_from_readtext_go
*&---------------------------------------------------------------------*
FORM get_remark_from_readtext_go  USING    pi_tdname
                                           pi_object
                                           pi_id
                                  CHANGING pe_remark.

  DATA: lt_lines  TYPE TABLE OF tline,
        lv_remark TYPE zgte_bd_zremark,
        lv_id     LIKE thead-tdid,
        lv_tdname LIKE thead-tdname,
        lv_object LIKE thead-tdobject.

**
  CLEAR: lv_id, lv_tdname, lv_object.
  lv_id     = pi_id.
  lv_tdname = pi_tdname.
  lv_object = pi_object.

  __cle: lt_lines.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = lv_id
      language                = sy-langu
      name                    = lv_tdname
      object                  = lv_object
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  IF lt_lines[] IS NOT INITIAL.

    CLEAR: lv_remark.
    LOOP AT lt_lines  INTO DATA(ls_lines).

      IF ls_lines-tdline IS NOT INITIAL.
        IF lv_remark IS INITIAL.
          lv_remark = ls_lines-tdline.
        ELSE.
          lv_remark = |{ lv_remark } | && |{ '/' }| && | { ls_lines-tdline }|.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF lv_remark IS NOT INITIAL.
      pe_remark = lv_remark.
    ENDIF.

  ENDIF.

ENDFORM.
