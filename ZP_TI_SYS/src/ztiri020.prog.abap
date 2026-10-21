************************************************************************
*                                                                      *
* Title         : ZTIRI020                                             *
*                                                                      *
* Description   : [Report] 수입 문서번호번호 관리                      *
*                                                                      *
* Creation Date : 2004/02/09                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*                                                                      *
* Inputs        :                                                      *
*                                                                      *
* Outputs       :                                                      *
*                                                                      *
************************************************************************
*                                                                      *
* Processing Steps:                                                    *
*   1.                                                                 *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
*                                                                      *
*                                                                      *
************************************************************************
PROGRAM   ztiri020
          MESSAGE-ID zmti00
          NO STANDARD PAGE HEADING.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE <icon>.

CLASS lcl_application DEFINITION DEFERRED.
CLASS cl_gui_cfw DEFINITION LOAD.

* CAUTION: MTREEITM is the name of the item structure which must
* be defined by the programmer. DO NOT USE MTREEITM!
TYPES: item_table_type LIKE STANDARD TABLE OF mtreeitm
       WITH DEFAULT KEY.

DATA: g_application TYPE REF TO lcl_application,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      g_tree TYPE REF TO cl_gui_column_tree,
      g_ok_code TYPE sy-ucomm.

* Fields on Dynpro 100
DATA: g_event(30),
      g_node_key(30) TYPE c,
      g_item_name    TYPE tv_itmname,
      g_header_name  TYPE tv_hdrname.

DATA: item_table     TYPE treemcitab,
      item           TYPE treemcitem,
      node_key       TYPE tm_nodekey.


************************************************************************
* CLASSES: Definition                                                  *
************************************************************************
CLASS lcl_application DEFINITION.

  PUBLIC SECTION.
    METHODS:
      handle_node_double_click
        FOR EVENT node_double_click
        OF cl_gui_column_tree
        IMPORTING node_key,
      handle_header_click
        FOR EVENT header_click
        OF cl_gui_column_tree
        IMPORTING header_name,
      handle_item_double_click
        FOR EVENT item_double_click
        OF cl_gui_column_tree
        IMPORTING node_key item_name,
      handle_button_click
        FOR EVENT button_click
        OF cl_gui_column_tree
        IMPORTING node_key item_name,
      handle_link_click
        FOR EVENT link_click
        OF cl_gui_column_tree
        IMPORTING node_key item_name,
      handle_checkbox_change
        FOR EVENT checkbox_change
        OF cl_gui_column_tree
        IMPORTING node_key item_name checked.
ENDCLASS.                    "lcl_application DEFINITION
************************************************************************
* CLASSES: IMPLEMENTATION
************************************************************************
CLASS lcl_application IMPLEMENTATION.

  METHOD handle_node_double_click.
    " this method handles the node double click event of the tree
    " model instance

    " show the key of the double clicked node in a dynpro field
    g_event = 'NODE_DOUBLE_CLICK'.
    g_node_key = node_key.
    CLEAR: g_item_name, g_header_name.

    PERFORM display_selected_node_info  USING g_node_key.

  ENDMETHOD.                    "handle_node_double_click

  METHOD handle_header_click.
    " this method handles header click event of the tree
    " model instance

    " show the name of the clicked header in a dynpro field
    g_event = 'HEADER_CLICK'.
    g_header_name = header_name.
    CLEAR: g_node_key, g_item_name.
  ENDMETHOD.                    "handle_header_click

  METHOD  handle_item_double_click.
    " this method handles the item double click event of the tree
    " model instance

    " show the key of the node and the name of the item
    " of the double clicked item in a dynpro field
    g_event = 'ITEM_DOUBLE_CLICK'.
    g_node_key = node_key.
    g_item_name = item_name.
    CLEAR g_header_name.

    PERFORM display_selected_node_info  USING g_node_key.
*    PERFORM handle_button_click.
  ENDMETHOD.                    "handle_item_double_click

  METHOD  handle_link_click.
    " this method handles the link click event of the tree
    " model instance

    " show the key of the node and the name of the item
    " of the clicked link in a dynpro field
    g_event = 'LINK_CLICK'.
    g_node_key = node_key.
    g_item_name = item_name.
    CLEAR g_header_name.

  ENDMETHOD.                    "handle_link_click

  METHOD  handle_button_click.
    " this method handles the button click event of the tree
    " model instance

    " show the key of the node and the name of the item
    " of the clicked button in a dynpro field
    g_event = 'BUTTON_CLICK'.
    g_node_key = node_key.
    g_item_name = item_name.
    CLEAR g_header_name.

  ENDMETHOD.                    "handle_button_click

  METHOD  handle_checkbox_change.
    " this method handles the checkbox_change event of the tree
    " model instance

    " show the key of the node and the name of the item
    " of the clicked checkbox in a dynpro field
    g_event = 'CHECKBOX_CHANGE'.
    g_node_key = node_key.
    g_item_name = item_name.
    CLEAR  g_header_name.
  ENDMETHOD.                    "handle_checkbox_change

ENDCLASS.                    "lcl_application IMPLEMENTATION

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.

* create the application object
* this object is needed to handle the ABAP Objects Events of
* Controls
  CREATE OBJECT g_application.

  CALL SCREEN 100.

*eject
************************************************************************
*                                                                      *
* P B O   M O D U L E                                                  *
*                                                                      *
************************************************************************

************************************************************************
*                                                                      *
* P B O   M O D U L E                                                  *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Module  PBO_scr0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr0100 OUTPUT.

  SET PF-STATUS 'STATUS100'.
  SET TITLEBAR 'T1000' WITH '수입'(t10).

*  SET PF-STATUS 'MAIN'.
  IF g_tree IS INITIAL.
    " The Tree Model has not been created yet.
    " Create a Tree Model and insert nodes into it.
    PERFORM create_and_init_tree_0100.
  ENDIF.

ENDMODULE.                 " PBO_scr0100  OUTPUT


*eject
************************************************************************
*                                                                      *
* P A I   M O D U L E                                                  *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Module  PAI_scr0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_scr0100 INPUT.

  DATA: return_code TYPE i.
* CL_GUI_CFW=>DISPATCH must be called if events are registered
* that trigger PAI
* this method calls the event handler method of an event
  CALL METHOD cl_gui_cfw=>dispatch
    IMPORTING
      return_code = return_code.
  IF return_code <> cl_gui_cfw=>rc_noevent.
    " a control event occured => exit PAI
    CLEAR g_ok_code.
    EXIT.
  ENDIF.

  CASE sy-ucomm.
    WHEN 'EXIT' OR 'CANC' OR 'BACK'.
      IF NOT g_custom_container IS INITIAL.
        " destroy tree container (detroys contained tree control, too)
        CALL METHOD g_custom_container->free
          EXCEPTIONS
            cntl_system_error = 1
            cntl_error        = 2.
        IF sy-subrc <> 0.
          MESSAGE a000.
        ENDIF.
        CLEAR g_custom_container.
        CLEAR g_tree.
      ENDIF.

      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.

* CAUTION: clear ok code!
  CLEAR g_ok_code.

ENDMODULE.                 " PAI_scr0100  INPUT


*eject
******** FORM-Routinen *************************************************


*&---------------------------------------------------------------------*
*&      Form  create_and_init_tree_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_and_init_tree_0100 .

  DATA: node_table       TYPE treev_ntab,
        item_table       TYPE item_table_type,
        event            TYPE cntl_simple_event,
        events           TYPE cntl_simple_events,
        hierarchy_header TYPE treev_hhdr.

  DATA: node TYPE treev_node.

* create a container for the tree control
  CREATE OBJECT g_custom_container
    EXPORTING
      " the container is linked to the custom control with the
      " name 'TREE_CONTAINER' on the dynpro
      container_name = 'TREE_CONTAINER'
    EXCEPTIONS
      cntl_error = 1
      cntl_system_error = 2
      create_error = 3
      lifetime_error = 4
      lifetime_dynpro_dynpro_link = 5.
  IF sy-subrc <> 0.
    MESSAGE a000.
  ENDIF.

* setup the hierarchy header
  hierarchy_header-heading = '[TraSys] 수입 문서별 번호범위 관리'.
  hierarchy_header-width   = 50.                  " width: 30 characters

* create a column tree model instance
  CREATE OBJECT g_tree
    EXPORTING
      parent                = g_custom_container
      node_selection_mode   = cl_gui_column_tree=>node_sel_mode_single
      item_selection        = 'X'
      hierarchy_column_name = 'C1'                          "#EC NOTEXT
      hierarchy_header      = hierarchy_header
    EXCEPTIONS
      illegal_node_selection_mode = 1
      illegal_column_name         = 2.
  IF sy-subrc <> 0.
    MESSAGE a000(tree_control_msg).
  ENDIF.

* Column2
  CALL METHOD g_tree->add_column
    EXPORTING
      name                         = 'C2'
      width                        = 120
      header_text                  = 'Descriptions'
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


* define the events which will be passed to the backend
*---> node double click
  event-eventid = cl_gui_column_tree=>eventid_node_double_click.
  event-appl_event = 'X'.              " process PAI if event occurs
  APPEND event TO events.

*---> item double click
  event-eventid = cl_gui_column_tree=>eventid_item_double_click.
  event-appl_event = 'X'.
  APPEND event TO events.

*
  CALL METHOD g_tree->set_registered_events
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
  SET HANDLER g_application->handle_node_double_click FOR g_tree.
  SET HANDLER g_application->handle_item_double_click FOR g_tree.

* add some nodes to the tree control
* NOTE: the tree control does not store data at the backend. If an
* application wants to access tree data later, it must store the
* tree data itself.
  PERFORM build_node_and_item_table USING node_table item_table.

  CALL METHOD g_tree->add_nodes_and_items
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

* expand the node with key 'Root'
  LOOP AT node_table INTO node.
    IF node-node_key(4) EQ 'NODE'.
      CALL METHOD g_tree->expand_node
        EXPORTING
          node_key            = node-node_key               "#EC NOTEXT
        EXCEPTIONS
          failed              = 1
          illegal_level_count = 2
          cntl_system_error   = 3
          node_not_found      = 4
          cannot_expand_leaf  = 5.
      IF sy-subrc <> 0.
        MESSAGE a000(tree_control_msg).
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " create_and_init_tree_0100
*&---------------------------------------------------------------------*
*&      Form  display_selected_node_info
*&---------------------------------------------------------------------*
FORM display_selected_node_info  USING    p_node_key.

  DATA: l_strlen   TYPE i,
        l_tcode    TYPE sy-tcode.


  CHECK NOT p_node_key IS INITIAL.
  CHECK p_node_key(4)  NE 'NODE'.

  IF p_node_key(1) EQ 'Z'.
    SELECT SINGLE tcode
      INTO l_tcode
      FROM tstc
     WHERE tcode EQ p_node_key.
    IF sy-subrc EQ 0.
      CALL TRANSACTION p_node_key.
    ELSE.
      MESSAGE s343(s#) WITH p_node_key.
    ENDIF.
  ENDIF.

ENDFORM.                    " display_selected_node_info
*&---------------------------------------------------------------------*
*&      Form  BUILD_NODE_AND_ITEM_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_node_and_item_table  USING   node_table TYPE treev_ntab
                                        item_table TYPE item_table_type.

  DATA: node        TYPE treev_node,
        l_ttext     TYPE ttext_stct,
        l_text(100) TYPE c.

*> Node Create.
  PERFORM  build_node_table USING:
             node_table 'ZTII101'  '' 'X', "수입의뢰.
             node_table 'ZTII102'  '' 'X', "B/L.
             node_table 'ZTII103'  '' 'X', "I/V.
             node_table 'ZTII104'  '' 'X', "L/G.
             node_table 'ZTII105'  '' 'X', "IP.
             node_table 'ZTII106'  '' 'X', "C/C.
             node_table 'ZTII107'  '' 'X', "G/R.
             node_table 'ZTII108'  '' 'X', "CS.
             node_table 'ZTII109'  '' 'X', "PN.
             node_table 'ZTII110'  '' 'X', "BS.
             node_table 'ZTII111'  '' 'X', "BI.
             node_table 'ZTII112'  '' 'X', "BO.
             node_table 'ZTII113'  '' 'X', "인수증..
             node_table 'ZTII116'  '' 'X', "계산서..
             node_table 'ZTII114'  '' 'X', "기납증..
             node_table 'ZTEI113'  '' 'X', "EDI 상태레코드.
             node_table 'ZTSI100'  '' 'X'. "FINBIL 문서범위.

*>
  LOOP AT node_table INTO node.
    SELECT SINGLE ttext
      INTO l_ttext
      FROM tstct
     WHERE tcode  EQ  node-node_key
       AND sprsl  EQ  sy-langu.

    IF sy-subrc EQ 0.
      CONCATENATE l_ttext '를 유지보수 합니다.' INTO l_text.

      PERFORM  build_item_table USING:
             item_table node-node_key l_ttext l_text.

    ENDIF.
  ENDLOOP.

ENDFORM.                    " BUILD_NODE_AND_ITEM_TABLE
*&---------------------------------------------------------------------*
*&      Form  build_node_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_node_table  USING    node_table TYPE treev_ntab
                                p_node_key
                                p_relatkey
                                p_expander.

  DATA: node TYPE treev_node.


* Build the node table.

* Caution: The nodes are inserted into the tree according to the order
* in which they occur in the table. In consequence, a node must not
* must not occur in the node table before its parent node.

* Node with key 'Root'
*  IF p_relatkey IS INITIAL.
  IF p_expander IS INITIAL.
    node-node_key = p_node_key.
    " Key of the node
    CLEAR node-relatkey.      " Special case: A root node has no parent
    CLEAR node-relatship.     " node.

    node-hidden = ' '.        " The node is visible,
    node-disabled = ' '.      " selectable,
    node-isfolder = 'X'.      " a folder.
    CLEAR node-n_image.       " Folder-/ Leaf-Symbol in state "closed":
    " use default.
    CLEAR node-exp_image.     " Folder-/ Leaf-Symbol in state "open":
    " use default
    CLEAR node-expander.      " see below.
    APPEND node TO node_table.
  ELSE.
* Node with key 'Child1'
    node-node_key = p_node_key.                             "#EC NOTEXT
    " Key of the node
    " Node is inserted as child of the node with key 'Root'.
    node-relatkey = p_relatkey.
    node-hidden = ' '.
    node-disabled = ' '.
    node-isfolder = 'X'.

    IF p_expander IS INITIAL.
      CLEAR node-n_image.
      CLEAR node-exp_image.
      CLEAR node-relatship.
    ELSE.
      node-relatship = cl_gui_column_tree=>relat_last_child.
      node-n_image    = icon_otf_document.
      node-exp_image  = icon_otf_document.
    ENDIF.

    node-expander = ' '.
    " The node is marked with a '+', although
    " it has no children. When the user clicks on the
    " + to open the node, the event expand_nc is
    " fired. The programmerr can
    " add the children of the
    " node within the event handler of the expand_nc
    " event  (see callback handle_expand_nc).
    APPEND node TO node_table.
  ENDIF.

ENDFORM.                    " build_node_table
*&---------------------------------------------------------------------*
*&      Form  build_item_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_item_table  USING item_table TYPE item_table_type
                             p_nodekey
                             p_col1_text
                             p_col2_text.

  DATA: item TYPE mtreeitm.

* Node with key 'Root'
  CLEAR item.
  item-node_key  = p_nodekey.
  item-item_name = 'C1'.                  " Item of Column 'Column1'
  item-class     = cl_gui_column_tree=>item_class_text. " Text Item
  item-text      = p_col1_text.
  APPEND item TO item_table.

  CLEAR item.
  item-node_key  = p_nodekey.
  item-item_name = 'C2'.                  " Item of Column 'Column1'
  item-class     = cl_gui_column_tree=>item_class_text. " Text Item
  item-text      = p_col2_text.
  APPEND item TO item_table.

ENDFORM.                    " build_item_table
