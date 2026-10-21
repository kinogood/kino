************************************************************************
* Title         :  ZTIR6000CI1                                         *
*                                                                      *
* Description   : 수입 L/G document Classes Implementation             *
*                                                                      *
* Creation Date : 2004/03/12                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*


*----------------------------------------------------------------------*
* Items View                                                           *
*----------------------------------------------------------------------
CLASS lcl_item_view IMPLEMENTATION.

*----------------------------------------------------------------------
  METHOD constructor.

    CALL METHOD super->constructor.

  ENDMETHOD.                    "constructor

*----------------------------------------------------------------------
  METHOD get_data.
    DATA: l_hash_entry LIKE LINE OF item_hash_table,
          l_ref        TYPE REF TO data.

    FIELD-SYMBOLS: <data> TYPE ZTISRQIT.

    CLEAR ex_data.

    IF state EQ 0.
* propose data.
      IF NOT my_item_proposer IS INITIAL.
        CALL METHOD my_item_proposer->get_data
          IMPORTING
            ex_data = l_ref.
        IF NOT l_ref IS INITIAL.

          ASSIGN l_ref->* TO <data>.
          CHECK sy-subrc IS INITIAL.
          MOVE-CORRESPONDING <data> TO ex_data.
        ENDIF.
      ENDIF.
      CLEAR ex_data.
    ENDIF.

*  ex_data-id = id.

  ENDMETHOD.                    "get_data

*----------------------------------------------------------------
  METHOD set_data.

    DATA: wa      LIKE LINE OF item_hash_table,
          l_data  TYPE ZTISRQIT.

    CHECK: sy-tcode  EQ c_create   OR
           sy-tcode  EQ c_create_a OR
           sy-tcode  EQ c_create_d OR
           sy-tcode  EQ c_change.
*
    wa-data = im_data.

    CLEAR: g_document_type.

    CASE g_document.
      WHEN c_lc.
*        IF NOT im_data-tknum IS INITIAL.      ">선적.
*          READ TABLE it_tab INTO g_tc_2150_wa
*                            WITH KEY tknum = im_data-tknum
*                                     vbeln = im_data-vbeln
*                                     posnr = im_data-posnr
*                                     vgbel = im_data-vgbel
*                                     vgpos = im_data-vgpos.
*          g_document_type = '선적문서'.
*          g_docno         = im_data-tknum.
*        ELSEIF NOT im_data-vbeln IS INITIAL.  ">납품문서.
*          READ TABLE it_tab INTO g_tc_2150_wa
*                            WITH KEY vbeln = im_data-vbeln
*                                     posnr = im_data-posnr
*                                     vgbel = im_data-vgbel
*                                     vgpos = im_data-vgpos.
*          g_document_type = '납품문서'.
*          g_docno         = im_data-vbeln.
*        ELSEIF NOT im_data-vgbel IS INITIAL.  ">영업문서.
*          READ TABLE it_tab INTO g_tc_2150_wa
*                            WITH KEY vgbel = im_data-vgbel
*                                     vgpos = im_data-vgpos.
*          g_document_type = '영업문서'.
*          g_docno         = im_data-vgbel.
*        ENDIF.
      WHEN OTHERS.
        EXIT.
    ENDCASE.

*>해당 문서에 존재할 경우, Exit.
    IF sy-subrc EQ 0.
      zti_message 'E' 'ZMTE' '209' g_document_type g_docno '' ''.
      EXIT.
    ENDIF.


*>참조할 수량이 존재하지 않을 경우, Exit

*>Sales Order Data Select.(ztessdkey)

*>기타 참조용 데이타 Select.

    MOVE-CORRESPONDING im_data TO g_tc_2130_wa.
    INSERT g_tc_2130_wa INTO TABLE it_tab.

  ENDMETHOD.                    "

*----------------------------------------------------------------
  METHOD chp_add_hash_entry.

    DATA: l_hash_entry LIKE LINE OF chp_hash_table.

    l_hash_entry-data  =  im_data.
    INSERT l_hash_entry INTO TABLE chp_hash_table.

  ENDMETHOD.                    "

ENDCLASS.                    "lcl_item_view IMPLEMENTATION

*----------------------------------------------------------------------*
* Document View                                                        *
*----------------------------------------------------------------------*
CLASS lcl_document_view IMPLEMENTATION.

*----------------------------------------------------------------------*
  METHOD class_constructor.

  ENDMETHOD.                    "class_constructor

*----------------------------------------------------------------------*

  METHOD set_application.

    my_application = im_application.

  ENDMETHOD.                    "set_application

*----------------------------------------------------------------------*
  METHOD handle_tree.

    DATA: ls_fieldcatalog LIKE LINE OF ex_fieldcatalog.
    DATA: l_fcode         TYPE sy-ucomm VALUE 'OTHERDOC'.
    DATA: l_docno         TYPE ztedocno.

    FIELD-SYMBOLS: <wa> TYPE ANY, <feld> TYPE ANY.

    CASE g_document.
*      WHEN c_fd.

      WHEN c_lc.
        READ TABLE ex_fieldcatalog INTO ls_fieldcatalog
                WITH KEY domname = 'EBELN'.

*        IF sy-subrc NE 0.
*          READ TABLE ex_fieldcatalog INTO ls_fieldcatalog
*                  WITH KEY domname = 'VBELN'.
*        ENDIF.
    ENDCASE.

    IF sy-subrc EQ 0.
      ASSIGN ex_row_pointer->* TO <wa>.
      CHECK sy-subrc EQ 0.

      ASSIGN COMPONENT ls_fieldcatalog-fieldname
                 OF STRUCTURE <wa> TO <feld>.

      CHECK sy-subrc EQ 0.

      l_docno = <feld>.

      CASE g_document.
*        WHEN c_fd.

        WHEN c_lc.
          IF ls_fieldcatalog-domname EQ 'EBELN'.
            SET PARAMETER ID 'BES' FIELD l_docno.

            READ TABLE ex_fieldcatalog INTO ls_fieldcatalog
                    WITH KEY domname = 'EBELP'.
            IF sy-subrc EQ 0.
              ASSIGN COMPONENT ls_fieldcatalog-fieldname
                         OF STRUCTURE <wa> TO <feld>.
              IF sy-subrc EQ 0.
                l_docno = <feld>.
                SET PARAMETER ID 'BSP' FIELD l_docno.
              ENDIF.
            ENDIF.
            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

*          ELSEIF ls_fieldcatalog-domname EQ 'VBELN'.
*
*            SET PARAMETER ID 'VL' FIELD l_docno.
*
*            CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
          ENDIF.
      ENDCASE.
    ENDIF.

  ENDMETHOD.                    "handle_tree

ENDCLASS.                    "lcl_document_view IMPLEMENTATION

*---------------------------------------------------------------------*
*       CLASS lcl_shopping_basket IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_shopping_basket   IMPLEMENTATION.

*----------------------------------------------------------------
  METHOD constructor.
    CALL METHOD super->constructor
      EXPORTING
        im_dynpro         = im_dynpro
        im_prog           = im_prog
        im_container_name = im_container_name.

* Create the event_receiver object and set the handlers for the events
* of the picture controls
    DATA: null TYPE REF TO if_command_mm.
    CREATE OBJECT my_event_receiver EXPORTING
               im_model = my_model
               im_commands = null.
  ENDMETHOD.                    "lcl_shopping_basket

*----------------------------------------------------------------
  METHOD accept_flavor.

    APPEND im_flavor TO my_flavors.

  ENDMETHOD.                    "lcl_shopping_basket

*----------------------------------------------------------------
  METHOD get_dragdrop_controller.

    re_cnt = my_event_receiver.

  ENDMETHOD.                    "lcl_shopping_basket

*----------------------------------------------------------------
  METHOD if_serializable_mm~read_from.

    DATA: l_string TYPE string40.

    CALL METHOD im_reader->read_string
      EXPORTING
        im_name   = 'DROP-ON'
      RECEIVING
        re_value  = l_string
      EXCEPTIONS
        not_found = 1.

    IF sy-subrc EQ 0.
      my_drop_enabled = l_string.
    ELSE.
      my_drop_enabled = c_true.    "default is drop on !
    ENDIF.

  ENDMETHOD.                    "lcl_shopping_basket

*----------------------------------------------------------------
  METHOD if_serializable_mm~write_to.

    CALL METHOD im_writer->write_string
      EXPORTING
        im_name  = 'DROP-ON'
        im_value = my_drop_enabled.

  ENDMETHOD.                    "lcl_shopping_basket

*----------------------------------------------------------------
  METHOD transport_to_model.
    DATA c.
  ENDMETHOD.                    "lcl_shopping_basket

*----------------------------------------------------------------
  METHOD subject_changed.
    CALL METHOD super->subject_changed( sender = sender ).
  ENDMETHOD.                    "lcl_shopping_basket

*----------------------------------------------------------------
  METHOD set_model.
    CALL METHOD super->set_model( im_model ).
    CHECK NOT my_controller IS INITIAL AND
          NOT my_model      IS INITIAL.
    CALL METHOD my_controller->set_model( my_model ).
  ENDMETHOD.                    "lcl_shopping_basket

*----------------------------------------------------------------
  METHOD init_control.

    TYPE-POOLS: cndp, sbdst.

    CALL METHOD super->init_control.

    SET HANDLER  handle_data_dropped FOR my_event_receiver.
    SET HANDLER  handle_picture_fcode FOR my_event_receiver.

* drag&drop not supported in WEB-GUI
    CHECK cl_gui_object=>www_active EQ space.

    CHECK NOT my_gui_container IS INITIAL AND
              my_picture_control IS INITIAL.

    DATA event_tab       TYPE cntl_simple_events.
    DATA event_tab_line  TYPE cntl_simple_event.
    DATA return          TYPE i.
    DATA: lt_url         TYPE sbdst_uri,
          ls_url         LIKE LINE OF lt_url.
    DATA: url(255)       TYPE c,
          l_flavor       LIKE LINE OF my_flavors.

    CREATE OBJECT my_picture_control
            EXPORTING parent = my_gui_container.

* Register the events
    event_tab_line-eventid = cl_gui_picture=>eventid_picture_dblclick.
    APPEND event_tab_line TO event_tab.
    event_tab_line-eventid = cl_gui_picture=>eventid_context_menu.
    APPEND event_tab_line TO event_tab.
    event_tab_line-eventid =
                cl_gui_picture=>eventid_context_menu_selected.
    APPEND event_tab_line TO event_tab.

    CALL METHOD my_picture_control->set_registered_events
      EXPORTING
        events = event_tab.

    SET HANDLER my_event_receiver->picture_handle_on_drop
                FOR my_picture_control.
    SET HANDLER my_event_receiver->picture_handle_on_context_menu
                FOR my_picture_control.
    SET HANDLER my_event_receiver->picture_on_ctmenu_sel
                FOR my_picture_control.

* Set the display mode to 'normal' (0)
    CALL METHOD my_picture_control->set_display_mode
      EXPORTING
        display_mode = cl_gui_picture=>display_mode_normal.

* Drag&Drop
    CREATE OBJECT my_drag_drop_msg_obj.

    LOOP AT my_flavors INTO l_flavor.

      CALL METHOD my_drag_drop_msg_obj->add
        EXPORTING
          flavor     = l_flavor
          dragsrc    = space
          droptarget = 'X'
          effect     = cl_dragdrop=>copy.

    ENDLOOP.

    IF my_drop_enabled EQ c_true.

      CALL METHOD my_picture_control->set_dragdrop_control
        EXPORTING
          dragdrop = my_drag_drop_msg_obj.
      CALL METHOD my_picture_control->set_dragdrop_picture
        EXPORTING
          dragdrop = my_drag_drop_msg_obj.
    ENDIF.

* Set 3D Border
    CALL METHOD my_picture_control->set_3d_border
      EXPORTING
        border = 1.

    CALL METHOD my_picture_control->set_display_mode(
      cl_gui_picture=>display_mode_fit_center ).
*
* Load GIF-Picture from WEB-Repository. PERF47
*
    TYPE-POOLS: cndp.
    DATA lf_web_url  TYPE cndp_url.
    CALL FUNCTION 'DP_PUBLISH_WWW_URL'
      EXPORTING
        objid    = 'SHOPPING_BASKET'
        lifetime = cndp_lifetime_transaction
      IMPORTING
        url      = lf_web_url
      EXCEPTIONS
        OTHERS   = 1.
    IF sy-subrc IS INITIAL.
      url = lf_web_url.
    ELSE.
*
*  LOAD GIF-Picture from BDS
*
      CALL METHOD cl_bds_document_set=>get_with_url
        EXPORTING
          classname  = 'CL_SCREEN_VIEW_MM'
          classtype  = 'CL'
          object_key = '1'
        CHANGING
          uris       = lt_url[]
        EXCEPTIONS
          OTHERS     = 1.

      IF sy-subrc EQ 0.

        READ TABLE lt_url INTO ls_url INDEX 1.

        IF sy-subrc EQ 0.
          url = ls_url-uri.
        ENDIF.
      ENDIF.
    ENDIF.
* Load the picture by using the url
    IF NOT url IS INITIAL.
      CALL METHOD my_picture_control->load_picture_from_url
        EXPORTING
          url = url.
    ENDIF.
  ENDMETHOD.                    "lcl_shopping_basket

*----------------------------------------------------------------
  METHOD handle_data_dropped.

    DATA: l_rc TYPE i.

    my_table_model = ex_table_model->clone( ).

    CHECK NOT my_table_model IS INITIAL.

    CALL FUNCTION 'GUID_CREATE'
      IMPORTING
        ev_guid_32 = my_fcode_dropped.

    DATA: l_f TYPE sy-ucomm.
    l_f             = my_fcode_dropped.
    g_fcode_dropped = my_fcode_dropped.
    g_table_model   = my_table_model.

    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = l_f
      IMPORTING
        rc       = l_rc.

    IF l_rc NE cl_gui_cfw=>rc_posted.
      CALL METHOD drop_action.
      CLEAR: my_fcode_dropped, g_fcode_dropped, g_table_model.
    ENDIF.

  ENDMETHOD.                    "lcl_shopping_basket

*----------------------------------------------------------------
  METHOD handle_picture_fcode.

    DATA: l_parent    TYPE REF TO cl_screen_view_mm,
          l_document  TYPE REF TO lcl_document_view.

  ENDMETHOD.                    "lcl_shopping_basket

*----------------------------------------------------------------
  METHOD execute_before_transport.

    CALL METHOD super->execute_before_transport
      CHANGING
        im_fcode = im_fcode.

    IF im_fcode = g_fcode_dropped AND
       NOT g_fcode_dropped IS INITIAL AND
       NOT g_table_model   IS INITIAL.

      CALL METHOD drop_action.

    ELSEIF im_fcode = 'DDON' AND
           my_drop_enabled EQ mmpur_no AND
           NOT my_drag_drop_msg_obj IS INITIAL.

      my_drop_enabled = c_true.
      CALL METHOD my_picture_control->set_dragdrop_control
        EXPORTING
          dragdrop = my_drag_drop_msg_obj.
      CALL METHOD my_picture_control->set_dragdrop_picture
        EXPORTING
          dragdrop = my_drag_drop_msg_obj.

    ELSEIF im_fcode = 'DDOFF' AND
           my_drop_enabled EQ c_true.

      my_drop_enabled = mmpur_no.
    ENDIF.

  ENDMETHOD.                    "lcl_shopping_basket

*-----------------------------------------------------------------------
*----
  METHOD drop_action.

    DATA: l_item              TYPE REF TO lcl_item_view,
          ltr_selection       TYPE REF TO data,
          lt_fieldcatalog_src TYPE lvc_t_fcat,
          ls_fieldcatalog_src TYPE lvc_s_fcat,
          l_item_data         TYPE ZTISRQIT,
          l_bstyp             TYPE lvc_fname,
          l_belegnr           TYPE lvc_fname,
          l_belegpos          TYPE lvc_fname,
          l_scr_fields        LIKE g_scr_fields.

    FIELD-SYMBOLS: <table> TYPE table,
                   <wa> TYPE ANY,
                   <src> TYPE ANY,
                   <dst> TYPE ANY.

    REFRESH: g_scr_fields.

    my_table_model = g_table_model.

    CHECK NOT my_table_model IS INITIAL.

    CALL METHOD g_table_model->get_table
      IMPORTING
        ex_tableref     = ltr_selection
        ex_fieldcatalog = lt_fieldcatalog_src[].

    CHECK NOT ltr_selection IS INITIAL.

    ASSIGN ltr_selection->* TO <table>.

    CHECK sy-subrc EQ 0.

    mmpur_dynamic_cast l_item my_model.

* message handler
    CALL METHOD cl_message_handler_mm=>get_handler
      IMPORTING
        ex_handler = g_message_handler.

* message handler
    CALL METHOD g_message_handler->remove_all.

    LOOP AT <table> ASSIGNING <wa>.
      CLEAR: l_item_data.

      CREATE OBJECT l_item.
      IF sy-subrc NE 0.
        MESSAGE a807(me) WITH 'lcl_item_view'.
      ENDIF.

**> 선적번호.
*      ASSIGN COMPONENT 'ZTEVLIKPPS-TKNUM' OF STRUCTURE <wa> TO <src>.
*      IF sy-subrc EQ 0.
*        l_item_data-tknum = <src>.
*      ENDIF.
**> 납품번호.
*      ASSIGN COMPONENT 'ZTEVLIKPPS-VBELN' OF STRUCTURE <wa> TO <src>.
*      IF sy-subrc EQ 0.
*        l_item_data-vbeln = <src>.
*      ENDIF.
*      ASSIGN COMPONENT 'ZTEVLIKPPS-POSNR' OF STRUCTURE <wa> TO <src>.
*      IF sy-subrc EQ 0.
*        l_item_data-posnr = <src>.
*      ENDIF.
**> 영업문서.
*      ASSIGN COMPONENT 'ZTEVLIKPPS-VGBEL' OF STRUCTURE <wa> TO <src>.
*      IF sy-subrc EQ 0.
*        l_item_data-vgbel = <src>.
*      ENDIF.
*      ASSIGN COMPONENT 'ZTEVLIKPPS-VGPOS' OF STRUCTURE <wa> TO <src>.
*      IF sy-subrc EQ 0.
*        l_item_data-vgpos = <src>.
*      ENDIF.
**> 영업문서.
*      ASSIGN COMPONENT 'ZTEVLIKPPS-VGBEL' OF STRUCTURE <wa> TO <src>.
*      IF sy-subrc EQ 0.
*        l_item_data-vgbel = <src>.
*      ENDIF.

      CALL METHOD l_item->set_data( im_data = l_item_data ).
    ENDLOOP.

    CALL METHOD my_table_model->free.

    CLEAR: my_fcode_dropped, my_table_model,
           g_fcode_dropped, g_table_model.

*> Message Popop
    CALL METHOD g_message_handler->show( im_popup = c_true
      im_amodal = c_false ).

  ENDMETHOD.                    "lcl_shopping_basket

*----------------------------------------------------------------
  METHOD build_dynpro_fields.

    CALL METHOD super->build_dynpro_fields.

    DATA: l_dynpro_entry LIKE LINE OF my_dynpro_fields.

    l_dynpro_entry-metafield = mmmfd_shopping_basket.

    INSERT l_dynpro_entry INTO TABLE my_dynpro_fields.
  ENDMETHOD.                    "lcl_shopping_basket

ENDCLASS.                    "lcl_shopping_basket IMPLEMENTATION
