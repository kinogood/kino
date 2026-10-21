*----------------------------------------------------------------------*
***INCLUDE LZ_TI_COMMON_FUNCTIONSF06 .
*----------------------------------------------------------------------*
 FORM tree_create_and_init   USING    p_subrc.

   DATA:  node_table       TYPE treev_ntab,
          item_table       TYPE item_table_type,
          event            TYPE cntl_simple_event,
          events           TYPE cntl_simple_events,
          hierarchy_header TYPE treev_hhdr,
          node_key         TYPE tv_nodekey.

   DATA: lv_cursor_node_key TYPE treev_node-node_key.
   DATA: node_wa LIKE mtreesnode_ft.

* setup the hierarchy header
   hierarchy_header-heading = '선택문서'. " heading
   hierarchy_header-width = 20.           " width

* create a tree control
* After construction, the control contains one column in the
* hierarchy area. The name of this column
* is defined via the constructor parameter HIERACHY_COLUMN_NAME.
* setup the hierarchy header
   CREATE OBJECT g_tree_7000
     EXPORTING
       parent                = g_docking
       node_selection_mode   = cl_gui_column_tree=>node_sel_mode_single
       item_selection        = 'X'
       hierarchy_column_name = 'Column0'
       hierarchy_header      = hierarchy_header
     EXCEPTIONS
       cntl_system_error           = 1
       create_error                = 2
       failed                      = 3
       illegal_node_selection_mode = 4
       illegal_column_name         = 5
       lifetime_error              = 6.
   IF sy-subrc <> 0.
     MESSAGE a000(tree_control_msg).
   ENDIF.

*> define the events which will be passed to the backend
*> node double click
   event-eventid = cl_gui_column_tree=>eventid_node_double_click.
   event-appl_event = 'X'.
   APPEND event TO events.

*> item double click
   event-eventid = cl_gui_column_tree=>eventid_item_double_click.
   event-appl_event = 'X'.
   APPEND event TO events.

*> checkbox change
   event-eventid = cl_gui_column_tree=>eventid_checkbox_change.
   event-appl_event = 'X'.
   APPEND event TO events.

*> item double click
   event-eventid = cl_gui_column_tree=>eventid_button_click.
   event-appl_event = 'X'.
   APPEND event TO events.

   CALL METHOD g_tree_7000->set_registered_events
     EXPORTING
       events                    = events
     EXCEPTIONS
       cntl_error                = 1
       cntl_system_error         = 2
       illegal_event_combination = 3.
   IF sy-subrc <> 0.
     MESSAGE a000(tree_control_msg).
   ENDIF.

* assign event handlers in the application class to each desired event
   SET HANDLER g_application->handle_node_double_click  FOR g_tree_7000.
   SET HANDLER g_application->handle_item_double_click  FOR g_tree_7000.
*  SET HANDLER g_application->handle_expand_no_children FOR G_TREE_7000.
*  SET HANDLER g_application->handle_link_click         FOR G_TREE_7000.
   SET HANDLER g_application->handle_button_click       FOR g_tree_7000.
   SET HANDLER g_application->handle_checkbox_change    FOR g_tree_7000.
*  SET HANDLER g_application->handle_header_click       FOR G_TREE_7000.

* insert two additional columns
* Column1
   CALL METHOD g_tree_7000->add_column
     EXPORTING
       name                         = 'Column1'
       width                        = 25
       alignment                    = cl_gui_column_tree=>align_left
       header_text                  = '공급업체'
     EXCEPTIONS
       column_exists                = 1
       illegal_column_name          = 2
       too_many_columns             = 3
       illegal_alignment            = 4
       different_column_types       = 5
       cntl_system_error            = 6
       failed                       = 7
       predecessor_column_not_found = 8.
   IF sy-subrc <> 0.
     MESSAGE a000(tree_control_msg).
   ENDIF.


* insert two additional columns
* Column2
   CALL METHOD g_tree_7000->add_column
     EXPORTING
       name                         = 'Column2'
       width                        = 24
       alignment                    = cl_gui_column_tree=>align_left
       header_text                  = '계산서금액'
     EXCEPTIONS
       column_exists                = 1
       illegal_column_name          = 2
       too_many_columns             = 3
       illegal_alignment            = 4
       different_column_types       = 5
       cntl_system_error            = 6
       failed                       = 7
       predecessor_column_not_found = 8.
   IF sy-subrc <> 0.
     MESSAGE a000(tree_control_msg).
   ENDIF.

   CALL METHOD g_tree_7000->add_column
     EXPORTING
       name                         = 'Column3'
       width                        = 4
       alignment                    = cl_gui_column_tree=>align_right
       header_text                  = 'Tax'
     EXCEPTIONS
       column_exists                = 1
       illegal_column_name          = 2
       too_many_columns             = 3
       illegal_alignment            = 4
       different_column_types       = 5
       cntl_system_error            = 6
       failed                       = 7
       predecessor_column_not_found = 8.
   IF sy-subrc <> 0.
     MESSAGE a000(tree_control_msg).
   ENDIF.

   CALL METHOD g_tree_7000->add_column
     EXPORTING
       name                         = 'Column4'
       width                        = 6
       alignment                    = cl_gui_column_tree=>align_right
       header_text                  = '사업장'
     EXCEPTIONS
       column_exists                = 1
       illegal_column_name          = 2
       too_many_columns             = 3
       illegal_alignment            = 4
       different_column_types       = 5
       cntl_system_error            = 6
       failed                       = 7
       predecessor_column_not_found = 8.
   IF sy-subrc <> 0.
     MESSAGE a000(tree_control_msg).
   ENDIF.

* add some nodes to the tree control
* NOTE: the tree control does not store data at the backend. If an
* application wants to access tree data later, it must store the
* tree data itself.
   PERFORM build_node_and_item_table
           CHANGING node_table
                    item_table.

   CALL METHOD g_tree_7000->add_nodes_and_items
     EXPORTING
       node_table                     = node_table
       item_table                     = item_table
       item_table_structure_name      = 'MTREEITM'
     EXCEPTIONS
       failed                         = 1
       cntl_system_error              = 3
       error_in_tables                = 4
       dp_error                       = 5
       table_structure_name_not_found = 6.
   IF sy-subrc <> 0.
     MESSAGE a000(tree_control_msg).
   ENDIF.

 ENDFORM.                    " tree_create_and_init
*&---------------------------------------------------------------------*
*&      Form  build_node_and_item_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM build_node_and_item_table    USING
                                   node_table TYPE treev_ntab
                                   item_table TYPE item_table_type.

   DATA: l_text_amount(30) TYPE c,
         l_temp(10)        TYPE c.

   DATA: node TYPE treev_node,
         item TYPE mtreeitm.

   CLEAR: g_find.

* Build the node table.
* Caution: The nodes are inserted into the tree according to the order
* in which they occur in the table. In consequence, a node must not
* must not occur in the node table before its parent node.

* Node with key 'Root'
   FREE: node_table, item_table.
   CLEAR: node_table, item_table.

   LOOP AT it_ztitcsk.
     CLEAR: node.
     node-node_key = it_ztitcsk-icsno.      " Key of the node
     CLEAR node-relatkey.      " Special case: A root node has no parent
     CLEAR node-relatship.     " node.

     node-hidden   = ' '.      " The node is visible,
     node-disabled = ' '.      " selectable,
     node-isfolder = ' '.      " a folder.
     CLEAR node-n_image.       " Folder-/ Leaf-Symbol in state "closed":
     CLEAR node-exp_image.     " Folder-/ Leaf-Symbol in state "open":
     CLEAR node-expander.      " see below.
     APPEND node TO node_table.

     CLEAR item.
     item-node_key  = it_ztitcsk-icsno.
     item-item_name = 'Column0'.           " Item of Column 'Column1'
     item-class     = cl_gui_column_tree=>item_class_checkbox.
     WRITE: it_ztitcsk-icsno TO l_temp LEFT-JUSTIFIED.
     CONCATENATE '$TMP' l_temp INTO l_temp
                                            SEPARATED BY '-'.
     item-text      = l_temp.
     item-editable  = 'X'.
     APPEND item TO item_table.

     CLEAR item.
     item-node_key  = it_ztitcsk-icsno.
     item-item_name = 'Column1'.           " Item of Column 'Column1'
     item-class     = cl_gui_column_tree=>item_class_button.
     item-text      = it_ztitcsk-name1.
     item-editable  = ' '.
     APPEND item TO item_table.

     CLEAR item.
     item-node_key  = it_ztitcsk-icsno.
     item-item_name = 'Column2'.           " Item of Column 'Column2'
     item-class     = cl_gui_column_tree=>item_class_text. " Text Item

*     BREAK-POINT.

     WRITE it_ztitcsk-wrbtr TO l_text_amount CURRENCY it_ztitcsk-waers
                                             LEFT-JUSTIFIED.
     CONCATENATE it_ztitcsk-waers l_text_amount INTO l_text_amount
                                            SEPARATED BY space.
     item-text = l_text_amount.
     APPEND item TO item_table.

     CLEAR item.
     item-node_key  = it_ztitcsk-icsno.
     item-item_name = 'Column3'.           " Item of Column 'Column2'
     item-class     = cl_gui_column_tree=>item_class_text. " Text Item
     item-text      = it_ztitcsk-mwskz.
     APPEND item TO item_table.

     CLEAR item.
     item-node_key  = it_ztitcsk-icsno.
     item-item_name = 'Column4'.           " Item of Column 'Column2'
     item-class     = cl_gui_column_tree=>item_class_text. " Text Item
     item-text      = it_ztitcsk-bupla.
     APPEND item TO item_table.
   ENDLOOP.

 ENDFORM.                    " build_node_and_item_table
*&---------------------------------------------------------------------*
*&      Form  no_input_check
*&---------------------------------------------------------------------*
 FORM no_input_check  USING noi_tab noi_field p_msgty.

   DATA: BEGIN OF feld,
           table(15),
           strich,
           name(10),
         END OF feld.

   feld-table = noi_tab.
   feld-strich = '-'.
   CONDENSE feld.
   SEARCH feld FOR '-'.
   sy-fdpos = sy-fdpos - 1.
   WRITE '-' TO feld+sy-fdpos.
   sy-fdpos = sy-fdpos + 1.
   WRITE noi_field TO feld+sy-fdpos.
   IF sy-stepl EQ 0.
     SET CURSOR FIELD feld.
   ELSE.
     SET CURSOR FIELD feld LINE sy-stepl.
   ENDIF.

   PERFORM get_ftext(rddfie00) USING    noi_tab noi_field sy-langu
                               CHANGING dfies g_subrc.
   IF g_subrc EQ 0.
     IF p_msgty EQ 'W'.
       MESSAGE ID 'ZMTE' TYPE p_msgty NUMBER 925 WITH dfies-scrtext_m.
     ELSE.
       MESSAGE ID 'ZMTE' TYPE p_msgty NUMBER 915 WITH dfies-scrtext_m.
     ENDIF.
*    MESSAGE e915 WITH dfies-scrtext_m.
   ELSE.
     IF p_msgty EQ 'W'.
       MESSAGE ID 'ZMTE' TYPE p_msgty NUMBER 925 WITH noi_tab noi_field.
     ELSE.
       MESSAGE ID 'ZMTE' TYPE p_msgty NUMBER 915 WITH noi_tab noi_field.
     ENDIF.
*    MESSAGE e915 WITH noi_tab noi_field.
   ENDIF.

 ENDFORM.                    " no_input_check
*&---------------------------------------------------------------------*
*&      Form  periode_determine
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM periode_determine   USING i_bukrs LIKE bkpf-bukrs
                                i_budat LIKE bkpf-budat
                                e_gjahr LIKE bkpf-gjahr
                                e_monat LIKE bkpf-monat.

   CALL FUNCTION 'FI_PERIOD_DETERMINE'
     EXPORTING
       i_bukrs = i_bukrs
       i_budat = i_budat
       i_monat = e_monat
       i_gjahr = e_gjahr
     IMPORTING
       e_gjahr = e_gjahr
       e_monat = e_monat.

 ENDFORM.                    " periode_determine
*&---------------------------------------------------------------------*
*&      Form  check_mandatory_input
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM check_mandatory_input  USING    p_fieldname  p_msgty.

   FIELD-SYMBOLS: <l_field>.
   DATA: l_subrc       TYPE  subrc,
         l_fdpos       TYPE  syfdpos,
         l_char(2)     TYPE  c.

   DATA: BEGIN OF field,
           table(15),
           strich,
           name(10),
         END OF field.

   ASSIGN (p_fieldname) TO <l_field>.

   IF <l_field> IS INITIAL.
     SEARCH p_fieldname FOR '-'.
     IF sy-subrc EQ 0.
       field-table  = p_fieldname(sy-fdpos).
       field+15     = p_fieldname+sy-fdpos.
       PERFORM no_input_check USING field-table field-name p_msgty.
     ENDIF.
   ENDIF.
   PERFORM set_return_message_func USING 'E'.

 ENDFORM.                    " check_mandatory_input

*&---------------------------------------------------------------------*
*&      Form  check_mandatory_input_msg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM check_mandatory_input_and_msg  USING    p_fieldname  p_msgty.

   FIELD-SYMBOLS: <l_field>.
   DATA: l_subrc       TYPE  subrc,
         l_fdpos       TYPE  syfdpos,
         l_char(2)     TYPE  c.

   DATA: BEGIN OF field,
           table(15),
           strich,
           name(10),
         END OF field.

   ASSIGN (p_fieldname) TO <l_field>.

   IF <l_field> IS INITIAL.
     SEARCH p_fieldname FOR '-'.
     IF sy-subrc EQ 0.
       field-table  = p_fieldname(sy-fdpos).
       field+15     = p_fieldname+sy-fdpos.
       PERFORM no_input_check USING field-table field-name 'S'.
       PERFORM set_return_message_func USING p_msgty.
     ENDIF.
   ENDIF.
 ENDFORM.                    " check_mandatory_input_and_msg

*&---------------------------------------------------------------------*
*&      Form  get_import_vendors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM get_import_vendors_text USING p_msgty.

   IF ztitcsk-lifnr IS INITIAL.
     CLEAR: lfa1.
   ELSE.
     SELECT SINGLE * FROM lfa1
      WHERE lifnr EQ ztitcsk-lifnr.
     IF sy-subrc NE 0.
       PERFORM message_not_found_vendor(ztir0000)
                                        USING 'ZTITCSK'
                                              'LIFNR'
                                              p_msgty.
     ENDIF.
   ENDIF.

   IF ztitcsk-empfk IS INITIAL.
     CLEAR *lfa1.
   ELSE.
     SELECT SINGLE *
       FROM *lfa1
      WHERE lifnr EQ ztitcsk-empfk.
     IF sy-subrc NE 0.
       PERFORM message_not_found_vendor(ztir0000)
                                        USING 'ZTITCSK'
                                              'EMPFK'
                                              p_msgty.
     ENDIF.
   ENDIF.

   IF ztitcsk-bupla IS INITIAL.
     CLEAR j_1bbranch.
   ELSE.
     SELECT SINGLE *
       INTO j_1bbranch
       FROM j_1bbranch
      WHERE bukrs  EQ  ztitcsk-bukrs
        AND branch EQ  ztitcsk-bupla.
   ENDIF.

   IF ztitcsk-gsber IS INITIAL.
     CLEAR tgsbt.
   ELSE.
     SELECT SINGLE *
       INTO tgsbt
       FROM tgsbt
      WHERE spras  EQ  sy-langu
        AND gsber  EQ  ztitcsk-gsber.
   ENDIF.

 ENDFORM.                    " get_import_vendors_text
*&---------------------------------------------------------------------*
*&      Form  double_click_event
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM double_click_event .

   CHECK g_fieldname IS INITIAL.

   GET CURSOR LINE g_findline.
   IF sy-subrc EQ 0.
     GET CURSOR FIELD g_fieldname.
     IF sy-subrc EQ 0.
       g_findscr = sy-dynnr.
       READ TABLE xztitcsp INDEX g_findline.
       IF sy-subrc NE 0.
         EXIT.
       ENDIF.
       CHECK ok_code EQ 'ZTISELECT'.   ">문서선택.

       CASE g_fieldname.
*> 수입의뢰문서.
         WHEN 'ZTISCSIT-REQNO'.
           SELECT DISTINCT amdsq
             INTO ztivrq00-amdsq
             FROM ztivrq00
            WHERE reqno   =   xztitcsp-refno.
           ENDSELECT.
           IF sy-subrc EQ 0.
             PERFORM display_import_document(ztir0000)
                                             USING xztitcsp-refno
                                                   ztivrq00-amdsq
                                                   '00000'.
           ENDIF.
*> 적하보험부보 문서.
         WHEN 'ZTISCSIT-IIPNO' OR 'ZTISCSIT-AMDSQ'.
           PERFORM display_ip_document(ztir0000)
                                       USING xztitcsp-refno
                                             xztitcsp-amdsq.

*> B/L 문서.
         WHEN 'ZTISCSIT-IBLNO'.
           PERFORM display_bl_document(ztir0000) USING xztitcsp-refno
                                             '00000'.
*> 통관 문서.
         WHEN 'ZTISCSIT-ICCNO'.
           PERFORM display_cc_document(ztir0000) USING xztitcsp-refno
                                             xztitcsp-amdsq.
*> 기납증문서.
         WHEN 'ZTISCSIT-TAXNO'.
           PERFORM display_tax_document(ztir0000) USING xztitcsp-taxno.
         WHEN OTHERS.
*          PERFORM display_distribution  USING  xztitcsp-icssq.
       ENDCASE.
     ENDIF.
   ELSE.
     GET CURSOR FIELD g_fieldname.
     IF sy-subrc EQ 0.
       g_findscr = sy-dynnr.
       CHECK ok_code EQ 'ZTISELECT'.   ">문서선택.

       CASE g_fieldname.
         WHEN 'ZTITCSK-HKONT'.
           PERFORM display_vendor_master(ztir0000) USING ztitcsk-hkont
                                               space.
         WHEN 'ZTITCSK-LIFNR'.
           PERFORM display_vendor_master(ztir0000) USING ztitcsk-lifnr
                                               space.
         WHEN 'ZTITCSK-EMPFK'.
           PERFORM display_vendor_master(ztir0000) USING ztitcsk-empfk
                                               space.
         WHEN 'ZTITCSK-BELNR' OR 'ZTITCSK-GJAHR'.
           PERFORM display_liv_document(ztir0000)  USING ztitcsk-belnr
                                               ztitcsk-gjahr
                                               ztitcsk-bukrs.
         WHEN 'ZTITCSK-AUGBL' OR 'ZTITCSK-AUGGJ'.
           PERFORM display_liv_document(ztir0000)  USING ztitcsk-augbl
                                               ztitcsk-auggj
                                               ztitcsk-bukrs.
       ENDCASE.
     ENDIF.
   ENDIF.

 ENDFORM.                    " double_click_event
*&---------------------------------------------------------------------*
*&      Form  get_f4_for_ZTIrm_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM get_f4_for_ztirm_dynpro  USING    p_zterm LIKE t052-zterm.

   IF screen-input EQ '1'.
     CALL FUNCTION 'FI_F4_ZTERM'
       EXPORTING
         i_koart       = 'K'
         i_ztirm       = p_zterm
         i_xshow       = ' '
       IMPORTING
         e_ztirm       = t052-zterm
       EXCEPTIONS
         nothing_found = 01.
   ELSE.
     CALL FUNCTION 'FI_F4_ZTERM'
       EXPORTING
         i_koart       = 'K'
         i_ztirm       = p_zterm
         i_xshow       = 'X'
       IMPORTING
         e_ztirm       = t052-zterm
       EXCEPTIONS
         nothing_found = 01.
   ENDIF.

   IF sy-subrc NE 0.
     MESSAGE s177(06) WITH p_zterm.
     EXIT.
   ENDIF.

   IF t052-zterm NE space.
     p_zterm = t052-zterm.
   ENDIF.

 ENDFORM.                    " get_f4_for_ZTIrm_dynpro
*&---------------------------------------------------------------------*
*&      Form  dynp_values_read
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM dynp_values_read USING    fname LIKE dynpread-fieldname
                                rc    LIKE sy-subrc.
   CLEAR   f4hlp.
   REFRESH f4hlp.
   f4hlp-fieldname = fname.
   APPEND f4hlp.
   g_f4dyn = sy-dynnr.

   CALL FUNCTION 'DYNP_VALUES_READ'
     EXPORTING
       dyname     = 'SAPLZ_TI_COMMON_FUNCTIONS'
       dynumb     = g_f4dyn
     TABLES
       dynpfields = f4hlp
     EXCEPTIONS
       OTHERS     = 01.
   rc = sy-subrc.

 ENDFORM.                    " dynp_values_read
*&---------------------------------------------------------------------*
*&      Form  get_account_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM get_account_text  USING    p_saknr
                                 p_msgty.

   CHECK NOT p_saknr IS INITIAL.

   SELECT SINGLE *
     FROM skat
    WHERE spras EQ sy-langu
      AND ktopl EQ t001-ktopl
      AND saknr EQ p_saknr.

 ENDFORM.                    " get_account_text
*&---------------------------------------------------------------------*
*&      Form  check_gl_method
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM check_gl_method  USING    p_bukrs
                                p_saknr
                       CHANGING p_xsako STRUCTURE xsako.

   CLEAR: p_xsako.
*
   CALL FUNCTION 'FI_GL_ACCOUNT_DATA'
     EXPORTING
       i_bukrs = p_bukrs
       i_saknr = p_saknr
     IMPORTING
       e_sako  = p_xsako.

 ENDFORM.                    " check_gl_method
*&---------------------------------------------------------------------*
*&      Form  build_posting_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM build_posting_data   USING p_subrc.

   DATA: l_text_amout(20),
         l_text_dmbtr(20),
         l_text_fwbas(20),
         l_text_wmwst(20),
         l_icsno            TYPE ztiicsno,
         l_msatz            TYPE msatz,
         l_kursf(12)        TYPE c,
         l_wwert(10)        TYPE c,
         l_zbd1t(3)         TYPE c,
         l_zbd2t(3)         TYPE c,
         l_zbd3t(3)         TYPE c,
         l_zbd1p(6)         TYPE c,
         l_zbd2p(6)         TYPE c,
         l_icssq            TYPE ztiicssq,
         l_bldat(10)        TYPE c,
         l_budat(10)        TYPE c,
         l_zfbdt(10)        TYPE c.

   DATA:    l_ccuky(05) TYPE c,
            l_moacg(16) TYPE c,
            l_pcdra(10) TYPE c,
            l_apday(03) TYPE c,
            l_apfrd(10) TYPE c,
            l_apend(10) TYPE c.

   p_subrc = 4.

   CLEAR: session.
   ctu_params-dismode  = 'E'. ">처리모드
   ctu_params-updmode  = 'S'. ">갱신모드
   ctu_params-cattmode = ' '. ">CATT 모드...
   ctu_params-defsize  = ' '. ">기본화면 크기
   ctu_params-racommit = 'X'.
   ctu_params-nobinpt  = ' ' .
   ctu_params-nobiend  = ' '.

   IF ok_code EQ 'SIMU'.
     ctu_params-dismode  = 'E'.
   ENDIF.

*> 정산종류.
*> Screen상의 정보를 Setting
   l_icsno = it_ztitcsk-icsno.
   PERFORM get_new_node_data  USING l_icsno.
   MOVE-CORRESPONDING ztitcsk TO it_ztitcsk.
*
   SELECT SINGLE *
     FROM t001
    WHERE bukrs EQ ztitcsk-bukrs.

   SELECT SINGLE *
     FROM ztitig00
    WHERE bukrs EQ ztitcsk-bukrs.

*   SELECT SINGLE *
*     FROM ztstiga
*    WHERE zterm EQ it_ztitcsk-zterm.
*   IF sy-subrc NE 0.
*     MESSAGE s002(zmts00) WITH it_ztitcsk-zterm.
*     PERFORM set_return_message_func USING 'E'.
*     p_subrc = 4.
*     EXIT.
*   ENDIF.
*

   WRITE: it_ztitcsk-budat   TO l_budat,
          it_ztitcsk-bldat   TO l_bldat,
          it_ztitcsk-zfbdt   TO l_zfbdt,
          it_ztitcsk-zbd1t   TO l_zbd1t,
          it_ztitcsk-zbd2t   TO l_zbd2t,
          it_ztitcsk-zbd3t   TO l_zbd3t,
          it_ztitcsk-zbd1p   TO l_zbd1p,
          it_ztitcsk-zbd2p   TO l_zbd2p,
          it_ztitcsk-kursf   TO l_kursf,
          it_ztitcsk-wwert   TO l_wwert.


   REFRESH: bdcdata.

   PERFORM bdc_dynpro_build USING :
          'X' 'ZTIR9000'          '0100',
          ' ' 'ZTISSCRCOM-BUKRS'  it_ztitcsk-bukrs,
          ' ' 'ZTISSCRCOM-BUDAT'  l_budat,
          ' ' 'ZTISSCRCOM-BLDAT'  l_bldat,
          ' ' 'ZTISSCRCOM-LIFNR'  it_ztitcsk-lifnr,
          ' ' 'ZTISSCRCOM-EXPGR'  it_ztitcsk-expgr,
*          ' ' 'ZTISSCRCOM-POSTY'  it_ztitcsk-posty,
*          ' ' 'ZTISSCRCOM-CSTYP'  ZTISSCRCOM-CSTYP
          ' ' 'ZTISSCRCOM-WAERS'  it_ztitcsk-waers,
          ' ' 'ZTISSCRCOM-BLART'  it_ZTItcsk-blart,
          ' ' 'ZTISSCRCOM-MWSKZ'  it_ztitcsk-mwskz,
          ' ' 'BDC_OKCODE'       '=ZTIENTER'.

**>>> 미지급금일 경우..
   PERFORM bdc_dynpro_build USING :
          'X' 'ZTIR9000'          '2000',
          ' ' 'ZTITCSK-VORGANG'   it_ztitcsk-vorgang,
          ' ' 'ZTITCSK-BLART'     it_ztitcsk-blart,
          ' ' 'ZTITCSK-CSTYP'     it_ztitcsk-cstyp,
          ' ' 'ZTITCSK-BVTYP'     it_ztitcsk-bvtyp,
*          ' ' 'ZTITCSK-HBKID'     it_ztitcsk-hbkid,
*              ' ' 'ZTITCSK-CDTYP'     it_ztitcsk-cdtyp,
          ' ' 'ZTITCSK-INAME'     it_ztitcsk-iname,
          ' ' 'ZTITCSK-HKONT'     it_ztitcsk-hkont,
          ' ' 'ZTITCSK-AKONT'     it_ztitcsk-akont,
          ' ' 'ZTITCSK-MWSKZ'     it_ztitcsk-mwskz.

*   IF it_ztitcsk-posty EQ 'P'.
*
*   ELSE.
*
*   ENDIF.
*
*> 현지통화와 전기통화가 다른 경우.
   IF it_ztitcsk-waers NE it_ztitcsk-hwaer.
     PERFORM bdc_dynpro_build USING :
        ' ' 'ZTITCSK-KURSF'     l_kursf,
        ' ' 'ZTITCSK-WWERT'     l_wwert.
   ENDIF.

**> 지급조건변경 가능일 경우.
*   IF ztstiga-termx EQ 'Y'.
     PERFORM bdc_dynpro_build USING :
          ' ' 'ZTITCSK-ZTERM'  it_ztitcsk-zterm.
*   ENDIF.
*> 지급인이 바뀌었을 경우...
   IF NOT ztitcsk-empfk IS INITIAL.
     PERFORM bdc_dynpro_build USING :
          ' ' 'ZTITCSK-EMPFK'  it_ztitcsk-empfk.
   ENDIF.
*> 사업장 체크일 경우.
   IF NOT ztitig00-chkbp IS INITIAL.
     PERFORM bdc_dynpro_build USING :
          ' ' 'ZTITCSK-BUPLA'  it_ztitcsk-bupla.
   ENDIF.
*> 사업영역 체크일 경우.
   IF NOT ztitig00-chkba IS INITIAL.
*       BREAK-POINT.
     PERFORM bdc_dynpro_build USING :
          ' ' 'ZTITCSK-GSBER'  it_ztitcsk-gsber.
   ENDIF.

*> 지급보류 변경 가능일 경우.
**   IF ztstiga-zlspx EQ 'Y'.

     PERFORM bdc_dynpro_build USING :
          ' ' 'ZTITCSK-ZLSPR'  it_ztitcsk-zlspr.


**   ENDIF.
*> 지급방법 변경 가능일 경우.
*   IF ztstiga-zlscx EQ 'Y'.
     PERFORM bdc_dynpro_build USING :
          ' ' 'ZTITCSK-ZLSCH'  it_ztitcsk-zlsch.
*   ENDIF.
*> 기준일 변경 가능일 경우.
*   IF ztstiga-fbdtx EQ 'Y'.
     IF NOT it_ztitcsk-zfbdt IS INITIAL.
       PERFORM bdc_dynpro_build USING :
            ' ' 'ZTITCSK-ZFBDT'     l_zfbdt.
     ENDIF.
*   ENDIF.
*> 일자수정 가능여부.
*   IF ztstiga-datmx EQ 'X'.
     PERFORM bdc_dynpro_build USING :
*           ' ' 'ZTITCSK-ZFBDT'     l_zfbdt,
           ' ' 'ZTITCSK-ZBD1T'     l_zbd1t,
           ' ' 'ZTITCSK-ZBD2T'     l_zbd2t,
           ' ' 'ZTITCSK-ZBD3T'     l_zbd3t,
           ' ' 'ZTITCSK-ZBD1P'     l_zbd1p,
           ' ' 'ZTITCSK-ZBD2P'     l_zbd2p.
*   ENDIF.

*> 헤더텍스트.
*   IF ztitig07-dtrfd NE '*'.
     PERFORM bdc_dynpro_build USING :
          ' ' 'ZTITCSK-BKTXT'  it_ztitcsk-bktxt.
*   ENDIF.
*> 헤더 참조.
*   IF ztitig07-dtrfh NE '*'.
     PERFORM bdc_dynpro_build USING :
          ' ' 'ZTITCSK-XBLNR'  it_ztitcsk-xblnr.
*   ENDIF.
*> 대변 텍스트 .
*   IF ztitig07-dtrfic NE '*'.
     PERFORM bdc_dynpro_build USING :
          ' ' 'ZTITCSK-SGTXT'  it_ztitcsk-sgtxt.
*   ENDIF.
*> 대변 지정.
*   IF ztitig07-dtrfac NE '*'.
     PERFORM bdc_dynpro_build USING :
          ' ' 'ZTITCSK-ZUONR'  it_ztitcsk-zuonr.
*   ENDIF.
*> 대변 참조키1
*   IF ztitig07-dtrf1c NE '*'.
*     PERFORM bdc_dynpro_build USING :
*          ' ' 'ZTITCSK-XREF1  '  it_ztitcsk-xref1.
*   ENDIF.
*> 대변 참조키2
*   IF ztitig07-dtrf2c NE '*'.
*     PERFORM bdc_dynpro_build USING :
*          ' ' 'ZTITCSK-XREF2'  it_ztitcsk-xref2.
*   ENDIF.
*> 대변 참조키3
*   IF ztitig07-dtrf3c NE '*'.
*     PERFORM bdc_dynpro_build USING :
*          ' ' 'ZTITCSK-XREF3'  it_ztitcsk-xref3.
*   ENDIF.

   CLEAR: g_count.
   DESCRIBE TABLE xztitcsp LINES g_cnt.

*   BREAK-POINT.
*
*   LOOP AT it_ztitcsp WHERE icsno EQ it_ztitcsk-icsno.
   LOOP AT xztitcsp INTO it_ztitcsp.
     ADD 1 TO g_count.

     WRITE it_ztitcsp-wrbtr TO l_text_amout CURRENCY it_ztitcsk-waers.
     WRITE it_ztitcsp-dmbtr TO l_text_dmbtr CURRENCY it_ztitcsk-hwaer.
     WRITE it_ztitcsp-fwbas TO l_text_fwbas CURRENCY it_ztitcsk-waers.
     WRITE it_ztitcsp-wmwst TO l_text_wmwst CURRENCY it_ztitcsk-waers.

     PERFORM    set_write_no_mask
                                       CHANGING : l_text_amout,
                                                  l_text_dmbtr,
                                                  l_text_fwbas,
                                                  l_text_wmwst.

     IF g_count EQ 1.
       PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-EXPCD(01)'  it_ztitcsp-expcd,
              ' ' 'ZTISCSIT-WRBTR(01)'  l_text_amout,
              ' ' 'ZTISCSIT-MWSKZ(01)'  it_ztitcsp-mwskz.
*> 적하부보일 경우. ==> 배서차수.
       CASE it_ztitcsk-expgr.
         WHEN 'L'.
           PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-REQNO(01)'  it_ztitcsp-refno,
              ' ' 'ZTISCSIT-AMDSQ(01)'  it_ztitcsp-amdsq.
         WHEN 'I'.
           PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-IIPNO(01)'  it_ztitcsp-refno,
              ' ' 'ZTISCSIT-AMDSQ(01)'  it_ztitcsp-amdsq.
         WHEN 'B'.
           PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-IBLNO(01)'  it_ztitcsp-refno.
         WHEN 'C'.
           PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-ICCNO(01)'  it_ztitcsp-refno,
              ' ' 'ZTISCSIT-AMDSQ(01)'  it_ztitcsp-amdsq.
         WHEN 'T'.
           PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-TAXNO(01)'  it_ztitcsp-refno.
       ENDCASE.

*> L/C 관련비용일 경우 ==> 요율, 기간 등 넘김.
       IF it_ztitcsk-expgr EQ 'L'.
         CLEAR: l_ccuky, l_moacg, l_pcdra,
                l_apday, l_apfrd, l_apend, l_kursf.
         IF NOT it_ztitcsp-ccuky IS INITIAL AND
            NOT it_ztitcsp-moacg IS INITIAL.
           WRITE it_ztitcsp-moacg TO l_moacg CURRENCY it_ztitcsp-ccuky.
           WRITE it_ztitcsp-ccuky TO l_ccuky.
           PERFORM    set_write_no_mask
                                             CHANGING : l_moacg.
         ENDIF.
         IF NOT it_ztitcsp-pcdra IS INITIAL.
           WRITE it_ztitcsp-pcdra TO l_pcdra.
         ENDIF.
         IF NOT it_ztitcsp-apday IS INITIAL.
           WRITE it_ztitcsp-apday TO l_apday.
         ENDIF.
         IF NOT it_ztitcsp-apfrd IS INITIAL.
           WRITE it_ztitcsp-apfrd TO l_apfrd.
         ENDIF.

         IF NOT it_ztitcsp-apend IS INITIAL.
           WRITE it_ztitcsp-apend TO l_apend.
         ENDIF.
         IF NOT it_ztitcsp-kursf IS INITIAL.
           WRITE it_ztitcsp-kursf TO l_kursf.
         ENDIF.

         PERFORM bdc_dynpro_build USING :
                  ' ' 'ZTISCSIT-CCUKY(01)'  l_ccuky,
                  ' ' 'ZTISCSIT-MOACG(01)'  l_moacg,
                  ' ' 'ZTISCSIT-PCDRA(01)'  l_pcdra,
                  ' ' 'ZTISCSIT-APDAY(01)'  l_apday,
                  ' ' 'ZTISCSIT-APFRD(01)'  l_apfrd,
                  ' ' 'ZTISCSIT-APEND(01)'  l_apend,
                  ' ' 'ZTISCSIT-KURSF(01)'  l_kursf.
       ENDIF.

       IF NOT it_ztitcsp-dmbtr IS INITIAL.
         IF t001-waers NE it_ztitcsk-waers.
           PERFORM bdc_dynpro_build USING :
             ' ' 'ZTISCSIT-DMBTR(01)'  l_text_dmbtr.
         ENDIF.
       ENDIF.
       IF NOT it_ztitcsp-wmwst IS INITIAL.
         PERFORM bdc_dynpro_build USING :
           ' ' 'ZTISCSIT-WMWST(01)'  l_text_wmwst.
       ENDIF.
       IF NOT it_ztitcsp-fwbas IS INITIAL.
         PERFORM bdc_dynpro_build USING :
           ' ' 'ZTISCSIT-FWBAS(01)'  l_text_fwbas.
       ENDIF.
*> 차변 텍스트 .
*       IF ztitig07-dtrfi NE '*'.
         PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-SGTXT(01)'  it_ztitcsp-sgtxt.
*       ENDIF.
*> 차변 지정.
*       IF ztitig07-dtrfa NE '*'.
         PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-ZUONR(01)'  it_ztitcsp-zuonr.
*       ENDIF.
**> 차변 참조키1
*       IF ztitig07-dtrf1 NE '*'.
*         PERFORM bdc_dynpro_build USING :
*              ' ' 'ZTISCSIT-XREF1(01)'  it_ztitcsp-xref1.
*       ENDIF.
**> 차변 참조키2
*       IF ztitig07-dtrf2 NE '*'.
*         PERFORM bdc_dynpro_build USING :
*              ' ' 'ZTISCSIT-XREF2(01)'  it_ztitcsp-xref2.
*       ENDIF.
**> 차변 참조키3
*       IF ztitig07-dtrf3 NE '*'.
*         PERFORM bdc_dynpro_build USING :
*              ' ' 'ZTISCSIT-XREF3(01)'  it_ztitcsp-xref3.
*       ENDIF.
*
       l_icssq = 1.
     ELSE.
       PERFORM bdc_dynpro_build USING :
              'X' 'ZTIR9000'          '2000',
              ' ' 'ZTISCSIT-EXPCD(02)'  it_ztitcsp-expcd,
              ' ' 'ZTISCSIT-WRBTR(02)'  l_text_amout,
              ' ' 'ZTISCSIT-MWSKZ(02)'  it_ztitcsp-mwskz.

*> 적하부보일 경우. ==> 배서차수.
       CASE it_ztitcsk-expgr.
         WHEN 'L'.
           PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-REQNO(02)'  it_ztitcsp-refno,
              ' ' 'ZTISCSIT-AMDSQ(02)'  it_ztitcsp-amdsq.
         WHEN 'I'.
           PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-IIPNO(02)'  it_ztitcsp-refno,
              ' ' 'ZTISCSIT-AMDSQ(02)'  it_ztitcsp-amdsq.
         WHEN 'B'.
           PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-IBLNO(02)'  it_ztitcsp-refno.
         WHEN 'C'.
           PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-ICCNO(02)'  it_ztitcsp-refno,
              ' ' 'ZTISCSIT-AMDSQ(02)'  it_ztitcsp-amdsq.
         WHEN 'T'.
           PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-TAXNO(02)'  it_ztitcsp-refno.
       ENDCASE.

*> L/C 관련비용일 경우 ==> 요율, 기간 등 넘김.
       IF it_ztitcsk-expgr EQ 'L'.
         CLEAR: l_ccuky, l_moacg, l_pcdra,
                l_apday, l_apfrd, l_apend, l_kursf.
         IF NOT it_ztitcsp-ccuky IS INITIAL AND
            NOT it_ztitcsp-moacg IS INITIAL.
           WRITE it_ztitcsp-moacg TO l_moacg CURRENCY it_ztitcsp-ccuky.
           WRITE it_ztitcsp-ccuky TO l_ccuky.
           PERFORM    set_write_no_mask
                                             CHANGING : l_moacg.
         ENDIF.
         IF NOT it_ztitcsp-pcdra IS INITIAL.
           WRITE it_ztitcsp-pcdra TO l_pcdra.
         ENDIF.
         IF NOT it_ztitcsp-apday IS INITIAL.
           WRITE it_ztitcsp-apday TO l_apday.
         ENDIF.
         IF NOT it_ztitcsp-apfrd IS INITIAL.
           WRITE it_ztitcsp-apfrd TO l_apfrd.
         ENDIF.

         IF NOT it_ztitcsp-apend IS INITIAL.
           WRITE it_ztitcsp-apend TO l_apend.
         ENDIF.
         IF NOT it_ztitcsp-kursf IS INITIAL.
           WRITE it_ztitcsp-kursf TO l_kursf.
         ENDIF.

         PERFORM bdc_dynpro_build USING :
                  ' ' 'ZTISCSIT-CCUKY(02)'  l_ccuky,
                  ' ' 'ZTISCSIT-MOACG(02)'  l_moacg,
                  ' ' 'ZTISCSIT-PCDRA(02)'  l_pcdra,
                  ' ' 'ZTISCSIT-APDAY(02)'  l_apday,
                  ' ' 'ZTISCSIT-APFRD(02)'  l_apfrd,
                  ' ' 'ZTISCSIT-APEND(02)'  l_apend,
                  ' ' 'ZTISCSIT-KURSF(02)'  l_kursf.
       ENDIF.

*
       IF NOT it_ztitcsp-dmbtr IS INITIAL.
         IF t001-waers NE it_ztitcsk-waers.
           PERFORM bdc_dynpro_build USING :
             ' ' 'ZTISCSIT-DMBTR(02)'  l_text_dmbtr.
         ENDIF.
       ENDIF.
       IF NOT it_ztitcsp-wmwst IS INITIAL.
         PERFORM bdc_dynpro_build USING :
           ' ' 'ZTISCSIT-WMWST(02)'  l_text_wmwst.
       ENDIF.
       IF NOT it_ztitcsp-fwbas IS INITIAL.
         PERFORM bdc_dynpro_build USING :
           ' ' 'ZTISCSIT-FWBAS(02)'  l_text_fwbas.
       ENDIF.
*> 차변 텍스트 .
*       IF ztitig07-dtrfi NE '*'.
         PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-SGTXT(02)'  it_ztitcsp-sgtxt.
*       ENDIF.
*> 차변 지정.
*       IF ztitig07-dtrfa NE '*'.
         PERFORM bdc_dynpro_build USING :
              ' ' 'ZTISCSIT-ZUONR(02)'  it_ztitcsp-zuonr.
*       ENDIF.
**> 차변 참조키1
*       IF ztitig07-dtrf1 NE '*'.
*         PERFORM bdc_dynpro_build USING :
*              ' ' 'ZTISCSIT-XREF1(02)'  it_ztitcsp-xref1.
*       ENDIF.
**> 차변 참조키2
*       IF ztitig07-dtrf2 NE '*'.
*         PERFORM bdc_dynpro_build USING :
*              ' ' 'ZTISCSIT-XREF2(02)'  it_ztitcsp-xref2.
*       ENDIF.
**> 차변 참조키3
*       IF ztitig07-dtrf3 NE '*'.
*         PERFORM bdc_dynpro_build USING :
*              ' ' 'ZTISCSIT-XREF3(02)'  it_ztitcsp-xref3.
*       ENDIF.

       l_icssq = g_count.
     ENDIF.

     IF g_count NE g_cnt.
       PERFORM bdc_dynpro_build USING :
          ' ' 'ZTITCSP-ICSSQ'   l_icssq,
          ' ' 'BDC_OKCODE'       '=TC_2130_PMVC'.
     ENDIF.
   ENDLOOP.

   IF ok_code_old EQ 'BUC'.
     PERFORM bdc_dynpro_build USING :
            ' ' 'BDC_OKCODE'       '=ZTISAVE'.
   ELSEIF ok_code_old EQ 'SIMU'.
     PERFORM bdc_dynpro_build USING :
            ' ' 'BDC_OKCODE'       '=ZTISIMUL'.
   ELSE.
     PERFORM bdc_dynpro_build USING :
            ' ' 'BDC_OKCODE'       '=ZTIPOST'.
   ENDIF.
   IF ok_code_old NE 'SIMU'.
     PERFORM bdc_dynpro_build USING :
            'X' 'SAPLSPO1'          '0300',
            ' ' 'BDC_OKCODE'       '=YES'.
   ENDIF.

   CLEAR g_subrc .

 ENDFORM.                    " build_posting_data
*&---------------------------------------------------------------------*
*&      Form  build_posted_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_SUBRC  text
*----------------------------------------------------------------------*
 FORM build_posted_message  USING    p_subrc.

   IF p_subrc EQ 0.
     PERFORM set_return_message_func USING sy-msgty.
   ELSE.
     LOOP AT messtab WHERE msgtyp EQ 'E'.
       MESSAGE ID messtab-msgid TYPE 'S' NUMBER sy-msgno
         WITH messtab-msgv1 messtab-msgv2 messtab-msgv3 messtab-msgv4.
*        messtab-msgtyp.
       PERFORM set_return_message_func USING 'E'.
     ENDLOOP.
     IF sy-subrc NE 0.
       MESSAGE s926.
       PERFORM set_return_message_func USING 'E'.
     ENDIF.
   ENDIF.

 ENDFORM.                    " build_posted_message
*&---------------------------------------------------------------------*
*&      Form  set_return_message_func
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM set_return_message_func  USING    p_msgty.

   DATA: g_dummy(72).

* BDC처리결과를 Reporting하기위한 Message Internal Table
   DATA: BEGIN OF gt_message OCCURS 0,
           arbgb LIKE smesg-arbgb,    "Message ID
           msgty LIKE smesg-msgty,    "Message Type
           txtnr LIKE smesg-txtnr,    "Message Number
           msgv1 LIKE smesg-msgv1,    "Message Parameter
           msgv2 LIKE smesg-msgv2,    "Message Parameter
           msgv3 LIKE smesg-msgv3,    "Message Parameter
           msgv4 LIKE smesg-msgv4,    "Message Parameter
         END OF gt_message.

   gt_message-arbgb = sy-msgid.    "Message ID
   gt_message-msgty = p_msgty.     "Message Type
   gt_message-txtnr = sy-msgno.    "Message Number
   gt_message-msgv1 = sy-msgv1.    "Message Parameter
   gt_message-msgv2 = sy-msgv2.    "Message Parameter
   gt_message-msgv3 = sy-msgv3.    "Message Parameter
   gt_message-msgv4 = sy-msgv4.    "Message Parameter

   CALL FUNCTION 'MESSAGE_STORE'
     EXPORTING
       arbgb = gt_message-arbgb
       msgty = gt_message-msgty
       msgv1 = gt_message-msgv1
       msgv2 = gt_message-msgv2
       msgv3 = gt_message-msgv3
       msgv4 = gt_message-msgv4
       txtnr = gt_message-txtnr.

   IF sy-subrc = 1 OR sy-subrc = 2.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ENDIF.

 ENDFORM.                    " set_return_message_func
*&---------------------------------------------------------------------*
*&      Form  set_tree_chosen_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM set_tree_chosen_item .

   DATA: l_chosen TYPE c.

   LOOP AT it_ztitcsk.
     IF it_ztitcsk-flag EQ 'X'.
       l_chosen = c_true.
     ELSE.
       l_chosen = c_false.
     ENDIF.

     g_node_key  = it_ztitcsk-icsno.
     g_item_name = 'Column0'.

     CALL METHOD g_tree_7000->item_set_chosen
       EXPORTING
         node_key  = g_node_key
         item_name = g_item_name
         chosen    = l_chosen
       EXCEPTIONS
         OTHERS    = 0.
     IF sy-subrc NE 0.

     ENDIF.
   ENDLOOP.

 ENDFORM.                    " set_tree_chosen_item
*&---------------------------------------------------------------------*
*&      Form  get_new_node_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM get_new_node_data  USING    p_node_key.

   DATA: l_ztitcsk  TYPE ztiscsk.
*   BREAK-POINT.

   CHECK NOT p_node_key(10) IS INITIAL.

   IF NOT ztitcsk-icsno IS INITIAL.
     READ TABLE it_ztitcsk INTO l_ztitcsk
      WITH KEY icsno = ztitcsk-icsno.

     IF sy-subrc EQ 0.
       g_tabix = sy-tabix.
       MOVE-CORRESPONDING ztitcsk TO it_ztitcsk.
       MODIFY it_ztitcsk INDEX g_tabix.
       LOOP AT it_ztitcsp.
         IF it_ztitcsp-icsno = ztitcsk-icsno.
           DELETE it_ztitcsp INDEX sy-tabix.
         ENDIF.
       ENDLOOP.
       LOOP AT xztitcsp.
         MOVE-CORRESPONDING xztitcsp TO it_ztitcsp.
         APPEND it_ztitcsp.
       ENDLOOP.
     ENDIF.
   ENDIF.

   READ TABLE it_ztitcsk INTO l_ztitcsk
        WITH KEY icsno = p_node_key(10).

   IF sy-subrc EQ 0.
     CLEAR: ztitcsk, xztitcsp[], xztitcsp, g_empfk_changed.
     MOVE-CORRESPONDING l_ztitcsk TO ztitcsk.
     LOOP AT it_ztitcsp WHERE icsno EQ ztitcsk-icsno.
       MOVE-CORRESPONDING it_ztitcsp TO xztitcsp.
       APPEND xztitcsp.
     ENDLOOP.

*     SELECT SINGLE *
*       FROM ztstiga
*      WHERE zterm EQ ztitcsk-zterm.
   ELSE.
*     CLEAR: ztitcsk, xztitcsp[], xztitcsp, ztstiga.
     CLEAR: ztitcsk, xztitcsp[], xztitcsp.
   ENDIF.

 ENDFORM.                    " get_new_node_data
*&---------------------------------------------------------------------*
*&      Form  check_node_checkbox
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM check_node_checkbox  USING    p_node_key.

*   BREAK-POINT.

   DATA: l_chosen TYPE c.

   READ TABLE it_ztitcsk WITH KEY icsno = p_node_key(10).
   IF sy-subrc EQ 0.
     g_tabix = sy-tabix.
     IF it_ztitcsk-flag EQ 'X'.
       it_ztitcsk-flag = space.
       l_chosen        = space.
     ELSE.
       it_ztitcsk-flag = 'X'.
       l_chosen        = 'X'.
     ENDIF.
     MODIFY it_ztitcsk INDEX g_tabix.

     g_node_key  = it_ztitcsk-icsno.
     g_item_name = 'Column0'.

     CALL METHOD g_tree_7000->item_set_chosen
       EXPORTING
         node_key  = g_node_key
         item_name = g_item_name
         chosen    = l_chosen
       EXCEPTIONS
         OTHERS    = 0.
     IF sy-subrc NE 0.

     ENDIF.

   ENDIF.


 ENDFORM.                    " check_node_checkbox
*&---------------------------------------------------------------------*
*&      Module  check_ZTIrm_changed  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE check_ztirm_changed INPUT.

   g_term_changed = 'X'.

 ENDMODULE.                 " check_ZTIrm_changed  INPUT'
*&---------------------------------------------------------------------*
*&      Form  get_reference_field_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM get_reference_field_value  USING    p_mode
                                          p_text
                                          p_clear_mode
                                          p_header.

   DATA: l_text100     TYPE text100,
         l_strlen      TYPE i,
         l_start       TYPE i,
         l_len         TYPE i.

   l_text100 = p_text.

   CASE p_mode.
     WHEN 'A'. ">비용그룹명.
       PERFORM  get_domain_value_text(ztir0000)
                                      USING   'ZTIEXPGR'
                                               ztitcsk-expgr
                                      CHANGING l_text100.
     WHEN 'B'. ">관련문서 관리번호(내부번호).
       IF p_header EQ 'X'.
         READ TABLE it_ztitcsp WITH KEY icsno = ztitcsk-icsno.
         IF sy-subrc EQ 0.
           l_text100 = it_ztitcsp-refno.
         ELSE.
           CLEAR: l_text100.
         ENDIF.
       ELSE.
         l_text100 = ztiscsit-refno.
       ENDIF.
     WHEN 'C'. ">관련 문서번호(L/C Number, B/L Number, 필증번호 등).
       IF p_header EQ 'X'.
         READ TABLE it_ztitcsp WITH KEY icsno = ztitcsk-icsno.
         IF sy-subrc EQ 0.
           CALL FUNCTION 'Z_TS_GET_CHAR_FIELD_LENGTH'
             EXPORTING
               p_field      = p_text
               p_check_char = space
             IMPORTING
               p_length     = l_len
             EXCEPTIONS
               no_character = 1
               OTHERS       = 2.
           IF sy-subrc <> 0.
             MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
           ENDIF.
           l_strlen = STRLEN( it_ztitcsp-docnm ).
           IF l_len GE l_strlen.
             l_text100 = it_ztitcsp-docnm.
           ELSE.
             l_start = l_strlen - l_len.
             l_text100 = it_ztitcsp-docnm+l_start(l_len).
           ENDIF.
         ELSE.
           CLEAR: l_text100.
         ENDIF.
       ELSE.
         CALL FUNCTION 'Z_TS_GET_CHAR_FIELD_LENGTH'
           EXPORTING
             p_field      = p_text
             p_check_char = space
           IMPORTING
             p_length     = l_len
           EXCEPTIONS
             no_character = 1
             OTHERS       = 2.
         IF sy-subrc <> 0.
           MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
         ENDIF.
         l_strlen = STRLEN( ztiscsit-docnm ).
         IF l_len GE l_strlen.
           l_text100 = ztiscsit-docnm.
         ELSE.
           l_start = l_strlen - l_len.
           l_text100 = ztiscsit-docnm+l_start(l_len).
         ENDIF.
       ENDIF.
     WHEN 'D'. ">비용설명.
       IF p_header EQ 'X'.
         CLEAR: l_text100, it_exptx[].
         LOOP AT it_ztitcsp WHERE icsno EQ ztitcsk-icsno.
           it_exptx-exptx = it_ztitcsp-exptx.
           COLLECT it_exptx.
         ENDLOOP.

         LOOP AT it_exptx.
*        WHERE icsno EQ ZTItcsk-icsno.
           IF l_text100 IS INITIAL.
             MOVE: it_exptx-exptx TO l_text100.
           ELSE.
             CONCATENATE l_text100 it_exptx-exptx
                         INTO l_text100 SEPARATED BY '/'.
           ENDIF.
         ENDLOOP.
       ELSE.
         l_text100 = ztiscsit-exptx.
       ENDIF.
     WHEN 'Z'. ">사용자 입력.
       IF p_clear_mode EQ 'X'.
         CLEAR: l_text100.
       ENDIF.
     WHEN ' '. ">고정값.
     WHEN '*'. ">미사용.
       CLEAR p_text.
   ENDCASE.

   p_text = l_text100.

 ENDFORM.                    " get_reference_field_value




*&---------------------------------------------------------------------*
*&      Form  SET_WRITE_NO_MASK
*&---------------------------------------------------------------------*
 FORM set_write_no_mask CHANGING p_text_amount.

   TABLES : usr01.

   SELECT SINGLE * FROM usr01 WHERE bname EQ sy-uname.

   IF sy-subrc EQ 0.
     CASE usr01-dcpfm.
       WHEN 'X'.    " Decimal point is period: N,NNN.NN
         PERFORM    set_change_symbol    USING p_text_amount ',' ' '.
         CONDENSE         p_text_amount    NO-GAPS.
       WHEN 'Y'.    " Decimal point is N NNN NNN,NN
         PERFORM    set_change_symbol    USING p_text_amount  ',' '.'.
         CONDENSE         p_text_amount    NO-GAPS.
       WHEN OTHERS. " Decimal point is comma: N.NNN,NN
         PERFORM    set_change_symbol    USING p_text_amount  '.' ' '.
         PERFORM    set_change_symbol    USING p_text_amount  ',' '.'.
         CONDENSE         p_text_amount    NO-GAPS.
     ENDCASE.
   ELSE.
     PERFORM    set_change_symbol    USING p_text_amount ',' ' '.
     CONDENSE         p_text_amount    NO-GAPS.
   ENDIF.

 ENDFORM.                    " SET_WRITE_NO_MASK

*&---------------------------------------------------------------------*
*&      Form  SET_CHANGE_SYMBOL
*&---------------------------------------------------------------------*
 FORM set_change_symbol USING    p_amount  p_from  p_to.

   DO.
     REPLACE  p_from   WITH   p_to  INTO    p_amount.
     IF  sy-subrc  <>    0.
       EXIT.
     ENDIF.
   ENDDO.

 ENDFORM.                    " SET_CHANGE_SYMBOL
*&---------------------------------------------------------------------*
*&      Form  belegart_authority_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM belegart_authority_check .

 ENDFORM.                    " belegart_authority_check
*&---------------------------------------------------------------------*
*&      Module  get_exchage_rate_scr7000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE get_exchage_rate_scr7000 INPUT.

   CLEAR sy-msgty.
   CALL FUNCTION 'CURRENCY_CODE_CHECK'
        EXPORTING
             i_object        = 'BKPF'
             i_bukrs         = ztitcsk-bukrs
             i_currency_code = ztitcsk-waers
*            i_budat         = ZTITCSK-BUDAT
*            i_bldat         = ZTITCSK-BLDAT
*            i_wwert         = ZTITCSK-WWERT
*            i_tcode         = 'F-43'
*            i_awtyp         = 'BKPF'
*            i_blart         = ZTITCSK-BLART
*            i_zedat         = ZTBKPF-DBEDT
        EXCEPTIONS
             error_message = 1.
   IF sy-subrc <> 0.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ELSEIF sy-msgty = 'W'.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ENDIF.

*------- Waehrungsinformationen fuer den Belegkopf ---------------------
   ztitcsk-hwaer = t001-waers.
*  MOVE-CORRESPONDING X001 TO BKPF.

   IF ztitcsk-waers EQ ztitcsk-hwaer.
     ztitcsk-kursf = 1.
     ztitcsk-wwert = ztitcsk-budat.
   ELSE.

     CALL FUNCTION 'FI_CURRENCY_CHECK'
          EXPORTING
               i_bldat  = ztitcsk-bldat
               i_budat  = ztitcsk-budat
               i_bukrs  = ztitcsk-bukrs
               i_blart  = ztitcsk-blart
*            I_KURS2  = BKPF-KURS2
*            I_KURS3  = BKPF-KURS3
               i_kursf  = ztitcsk-kursf
               i_waers  = ztitcsk-waers
               x_dialog = 'X'          "Warnungen im Dialog!
               i_wwert  = ztitcsk-wwert
          IMPORTING
*            E_KURS2  = BKPF-KURS2
*            E_KURS3  = BKPF-KURS3
               e_kursf  = ztitcsk-kursf
               e_wwert  = ztitcsk-wwert.

     IF ztitcsk-kursf LT 0.
       ztitcsk-kursf = 0.
     ENDIF.
   ENDIF.

   SET PARAMETER ID 'WHR' FIELD ztitcsk-waers.


 ENDMODULE.                 " get_exchage_rate_scr7000  INPUT
*&---------------------------------------------------------------------*
*&      Form  get_f4_for_zterm_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM get_f4_for_zterm_dynpro  USING    p_zterm LIKE t052-zterm.

   IF screen-input EQ '1'.
     CALL FUNCTION 'FI_F4_ZTERM'
       EXPORTING
         i_koart       = 'K'
         i_zterm       = p_zterm
         i_xshow       = ' '
       IMPORTING
         e_zterm       = t052-zterm
       EXCEPTIONS
         nothing_found = 01.
   ELSE.
     CALL FUNCTION 'FI_F4_ZTERM'
       EXPORTING
         i_koart       = 'K'
         i_zterm       = p_zterm
         i_xshow       = 'X'
       IMPORTING
         e_zterm       = t052-zterm
       EXCEPTIONS
         nothing_found = 01.
   ENDIF.

   IF sy-subrc NE 0.
     MESSAGE s177(06) WITH p_zterm.
     EXIT.
   ENDIF.

   IF t052-zterm NE space.
     p_zterm = t052-zterm.
   ENDIF.

 ENDFORM.                    " get_f4_for_zterm_dynpro
*&---------------------------------------------------------------------*
*&      Form  CHECK_POSTING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM check_posting_data USING p_subrc.

   DATA: l_msatz            TYPE msatz,
         l_icsno            TYPE ztiicsno.

   CLEAR p_subrc.

*   MOVE-CORRESPONDING it_ztitcsk TO ztitcsk.

*> Screen상의 정보를 Setting
   l_icsno = it_ztitcsk-icsno.
   PERFORM get_new_node_data  USING l_icsno.
   MOVE-CORRESPONDING ztitcsk TO it_ztitcsk.

   SELECT SINGLE *
     FROM ztitig00
    WHERE bukrs EQ ztitcsk-bukrs.

*> 트랜잭션.
   IF ztitcsk-vorgang IS INITIAL.
     PERFORM check_mandatory_input_and_msg
             USING 'ZTITCSK-VORGANG' c_error.
     p_subrc = 4.
     EXIT.
   ENDIF.
*> 정산종류.
   IF ztitcsk-cstyp IS INITIAL.
     PERFORM check_mandatory_input_and_msg
             USING 'ZTITCSK-CSTYP' c_error.
     p_subrc = 4.
     EXIT.
   ELSE.
*> 업무가불.
     IF ztitcsk-cstyp EQ 'A'.
       IF ztitcsk-hkont IS INITIAL.
         PERFORM check_mandatory_input_and_msg
                 USING 'ZTITCSK-HKONT' c_error.
         p_subrc = 4.
         EXIT.
       ENDIF.
*> 담당자.
       IF ztitcsk-iname IS INITIAL.
         PERFORM check_mandatory_input_and_msg
                 USING 'ZTITCSK-INAME' c_error.
         p_subrc = 4.
         EXIT.
       ENDIF.
     ENDIF.
   ENDIF.
*> .

*> 트랜잭션.
   IF ztitcsk-vorgang IS INITIAL.
     PERFORM check_mandatory_input_and_msg
             USING 'ZTITCSK-VORGANG' c_error.
     p_subrc = 4.
     EXIT.
   ENDIF.

*> 증빙일.
   IF ztitcsk-bldat IS INITIAL.
     PERFORM check_mandatory_input_and_msg
             USING 'ZTITCSK-BLDAT' c_error.
     p_subrc = 4.
     EXIT.
   ENDIF.

*> 증빙일.
   IF ztitcsk-bldat IS INITIAL.
     PERFORM check_mandatory_input_and_msg
             USING 'ZTITCSK-BLDAT' c_error.
     p_subrc = 4.
     EXIT.
   ENDIF.
*> 전기일.
   IF ztitcsk-budat IS INITIAL.
     PERFORM check_mandatory_input_and_msg
             USING 'ZTITCSK-BUDAT' c_error.
     p_subrc = 4.
     EXIT.
   ENDIF.
*> 지급조건.
   IF ztitcsk-zterm IS INITIAL.
     PERFORM check_mandatory_input_and_msg
             USING 'ZTITCSK-ZTERM' c_error.
     p_subrc = 4.
     EXIT.
   ENDIF.

*   SELECT SINGLE *
*     FROM ztstiga
*    WHERE zterm EQ it_ztitcsk-zterm.
*   IF sy-subrc NE 0.
*     MESSAGE s002(zmts00) WITH it_ztitcsk-zterm.
*     PERFORM set_return_message_func USING 'E'.
*     p_subrc = 4.
*     EXIT.
*   ENDIF.

*> 기준일.
   IF ztitcsk-zfbdt IS INITIAL.
     PERFORM check_mandatory_input_and_msg
             USING 'ZTITCSK-ZFBDT' c_error.
     p_subrc = 4.
     EXIT.
   ENDIF.
*> 사업장.
   IF ztitig00-chkbp EQ 'E'.
     IF ztitcsk-bupla IS INITIAL.    ">
       PERFORM check_mandatory_input_and_msg USING 'ZTITCSK-BUPLA' 'E'.
       p_subrc = 4.
       EXIT.
     ENDIF.
   ENDIF.
* 사업영역.
   IF ztitig00-chkba EQ 'E'.
     IF ztitcsk-gsber IS INITIAL.    ">
        PERFORM check_mandatory_input_and_msg USING 'ZTITCSK-GSBER' 'E'.
        p_subrc = 4.
        EXIT.
     ENDIF.
   ENDIF.

*> 세율 계산.
   CALL FUNCTION 'Z_TS_FI_TAX_RATE_BY_MWSKZ'
     EXPORTING
       i_bukrs                       = ztitcsk-bukrs
       i_mwskz                       = ztitcsk-mwskz
*     I_TXJCD                       =
*     I_TXDAT                       =
       i_show_inactive               = 'X'
     IMPORTING
       ex_msatz                      = l_msatz
    EXCEPTIONS
      reading_mwskz                 = 1
      reading_pricing_data          = 2
      reading_condition_types       = 3
      determine_txjcd               = 4
      reading_tax_accounts          = 5
      error_alv_call                = 6
      reading_ttxd                  = 7
      txdat_necessary               = 8
      OTHERS                        = 9.
   IF sy-subrc <> 0.
     MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
     PERFORM set_return_message_func USING 'E'.
     p_subrc = 4.
     EXIT.
   ENDIF.

   IF l_msatz EQ 0.
     IF ztitcsk-wmwst NE 0.
       MESSAGE s213(f5) WITH ztitcsk-mwskz.
       PERFORM set_return_message_func USING 'E'.
       p_subrc = 4.
       EXIT.
     ENDIF.
   ELSE.
     IF ztitcsk-wmwst EQ 0.
       MESSAGE s005(zmts00) WITH ztitcsk-mwskz.
       PERFORM set_return_message_func USING 'E'.
       p_subrc = 4.
       EXIT.
     ENDIF.
   ENDIF.

   CLEAR: bseg, knb1, kna1.

*  break-point.
   CALL FUNCTION 'Z_TS_CHECK_BANK_TYPE'
     EXPORTING
       i_bukrs   = ztitcsk-bukrs
       i_bvtyp   = ztitcsk-bvtyp
       i_lifnr   = ztitcsk-lifnr
       i_empfb   = ztitcsk-empfk
     EXCEPTIONS
       no_input  = 1
       not_found = 2
       OTHERS    = 3.
   IF sy-subrc <> 0.
     MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
     PERFORM set_return_message_func USING 'E'.
     p_subrc = 4.
     EXIT.
   ENDIF.

   IF ztitcsk-vorgang IS INITIAL.
     PERFORM check_mandatory_input_and_msg
             USING 'ZTITCSK-VORGANG' c_error.
     p_subrc = 4.
     EXIT.
   ENDIF.

 ENDFORM.                    " CHECK_POSTING_DATA
