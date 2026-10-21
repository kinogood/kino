************************************************************************
* Title         :  ZTIRH030                                            *
*                                                                      *
* Description   : 수입 수량별 진행 현황 LIST                           *
*                                                                      *
* Creation Date : 2003/08/26                                           *
*                                                                      *
* Author        : Seung Jun, lee                                       *
*                                                                      *
************************************************************************
*                                                                      *
* Inputs        : None                                                 *
*                                                                      *
* Outputs       : None                                                 *
*                                                                      *
************************************************************************
*                                                                      *
* Processing Steps:                                                    *
* 1.                                                                   *
* 2.                                                                   *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
************************************************************************

REPORT  ztirh030 MESSAGE-ID zmti00
                 NO STANDARD PAGE HEADING.

************************************************************************
* User Include Define                                                  *
************************************************************************
*INCLUDE ZTI_reuse_alvforms_t01.  "> AVL 공용 Data 선언 (Class 용).

************************************************************************
* TYPES and TYPE-POOLS                                                 *
************************************************************************

************************************************************************
* SAP Include Define                                                   *
************************************************************************
CLASS lcl_application DEFINITION DEFERRED.
CLASS cl_gui_cfw DEFINITION LOAD.
DATA: g_application TYPE REF TO lcl_application,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      g_tree TYPE REF TO cl_column_tree_model,
      g_ok_code TYPE sy-ucomm.

* Fields on Dynpro 100
DATA: g_event(30),
      g_node_key(30) TYPE c,
      g_item_name TYPE tv_itmname,
      g_header_name TYPE tv_hdrname.
************************************************************************
* SAP Tables                                                           *
************************************************************************

************************************************************************
* SAP Views                                                            *
***********************************************************************
TABLES : ztispohis,
         ztivpo01,
         ztivpo00,
         ztiviv01,
         ztivbl00,
         ztiviv00,
         ztivpn00,
         ztivcc00,
         ztivgr00.
************************************************************************
* CONSTANTS                                                            *
************************************************************************
*CONSTANTS:

************************************************************************
* Internal Tables                                                      *
************************************************************************
*> Select용.
DATA: l_yn    type c.
DATA: BEGIN OF it_pokey OCCURS 0.
        INCLUDE STRUCTURE ztispokey.
DATA: END   OF it_pokey.

DATA: it_dochis      LIKE ztisdochis OCCURS 0 WITH HEADER LINE.
************************************************************************
* DATA Declarations                                                    *
************************************************************************
DATA: l_count TYPE i,
      ls_list  TYPE ztispohis.

DATA: item_table TYPE treemcitab,
      item TYPE treemcitem,
      node_key TYPE tm_nodekey.

************************************************************************
** RANGES
************************************************************************
*RANGES:

***********************************************************************
* FIELD-GROUPS
***********************************************************************
*FIELD-GROUPS:

***********************************************************************
* FIELD-SYMBOLS
***********************************************************************
*FIELD-SYMBOLS:

************************************************************************
* MACRO DEFINE                                                         *
************************************************************************

************************************************************************
* CLASSES: Definition                                                  *
************************************************************************
CLASS lcl_application DEFINITION.

  PUBLIC SECTION.
    METHODS:
      handle_node_double_click
        FOR EVENT node_double_click
        OF cl_column_tree_model
        IMPORTING node_key,
      handle_header_click
        FOR EVENT header_click
        OF cl_column_tree_model
        IMPORTING header_name,
      handle_item_double_click
        FOR EVENT item_double_click
        OF cl_column_tree_model
        IMPORTING node_key item_name,
      handle_button_click
        FOR EVENT button_click
        OF cl_column_tree_model
        IMPORTING node_key item_name,
      handle_link_click
        FOR EVENT link_click
        OF cl_column_tree_model
        IMPORTING node_key item_name,
      handle_checkbox_change
        FOR EVENT checkbox_change
        OF cl_column_tree_model
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

    PERFORM handle_button_click.

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
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************

SELECTION-SCREEN BEGIN OF BLOCK dbsel2 WITH FRAME TITLE text-003.
** JS전선 회사코드 2007/04 KSH --------------------------------------
SELECT-OPTIONS: s_bukrs  FOR ztivpo01-bukrs                  "회사코드.
                         NO-EXTENSION NO INTERVALS OBLIGATORY
                         MEMORY ID buk
                         MODIF  ID iog.
** JS전선 회사코드 2007/04 KSH --------------------------------------
PARAMETERS: p_ebeln LIKE ztisscrcom-ebeln MEMORY ID bes
                                          OBLIGATORY.
SELECTION-SCREEN END OF BLOCK dbsel2.

SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant MODIF ID log.
SELECTION-SCREEN END OF BLOCK lists.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'LOG'.
      screen-input = 0.
      screen-invisible = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


************************************************************************
* User Include Define                                                  *
************************************************************************
*INCLUDE ZTI_reuse_alvforms_f01.  "> AVL 공용 Data 선언 (Class 용).
** JS전선 회사코드 2007/04 KSH --------------------------------------
DATA: l_yn    type c.
  INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK
** JS전선 회사코드 2007/04 KSH --------------------------------------

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
*  PERFORM p1000_alv_fields_initial.
  PERFORM p1001_initialization.

************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
AT SELECTION-SCREEN.
** JS전선 회사코드 2007/04 KSH --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 KSH --------------------------------------
**> 사용자 Input values Check
*  PERFORM p1100_check_input_values.

**> 지급조건 HELP(Low values)
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-low.
*  PERFORM get_f4_for_zterm(ZTIr0000) USING s_zterm-low.
**> 지급조건 HELP(High values)
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zterm-high.
*  PERFORM get_f4_for_zterm(ZTIr0000) USING s_zterm-high.

** JS전선 회사코드 2007/04 KSH --------------------------------------
*  SELECT SINGLE *
*    FROM ztivpo01
*   WHERE ebeln EQ p_ebeln.

  SELECT SINGLE *
    FROM ztivpo01
   WHERE ebeln EQ p_ebeln
     AND bukrs IN s_bukrs.
** JS전선 회사코드 2007/04 KSH --------------------------------------

  IF sy-subrc EQ 0.
    CALL FUNCTION 'Z_TI_DOCUMENT_HISTORY_BY_TYPE'
      EXPORTING
        xdocno  = p_ebeln
        xdocty  = 'XX'
      TABLES
        xdochis = it_dochis.
  ELSE.
    MESSAGE e902.
  ENDIF.

END-OF-SELECTION.

* create the application object
* this object is needed to handle the ABAP Objects Events of
* Controls
  CREATE OBJECT g_application.

  CALL SCREEN 100.

************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
FORM p1001_initialization .

  SET TITLEBAR 'T1000' WITH '현황 List'(t10).

ENDFORM.                    " p1001_initialization

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
  SET TITLEBAR 'T1000' WITH '현황 List'(t10).

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
***********************************************************************
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

*&---------------------------------------------------------------------*
*&      Form  create_and_init_tree_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_and_init_tree_0100 .

  DATA: event TYPE cntl_simple_event,
        events TYPE cntl_simple_events,
        hierarchy_header TYPE treemhhdr.

* setup the hierarchy header
  hierarchy_header-heading = 'Hierarchy Header'.            "#EC NOTEXT
  hierarchy_header-width = 30.         " width: 30 characters

* create a column tree model instance
  CREATE OBJECT g_tree
    EXPORTING
      node_selection_mode = cl_column_tree_model=>node_sel_mode_single
      item_selection = 'X'
      hierarchy_column_name = 'H1'                          "#EC NOTEXT
      hierarchy_header = hierarchy_header
    EXCEPTIONS
      illegal_node_selection_mode = 1
      illegal_column_name = 2.
  IF sy-subrc <> 0.
    MESSAGE a001.
  ENDIF.

  PERFORM build_header.

* create a container for the tree model
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
    MESSAGE a001.
  ENDIF.

* create the view (control) of the tree model

  CALL METHOD g_tree->create_tree_control
    EXPORTING
      parent                       = g_custom_container
    EXCEPTIONS
      lifetime_error               = 1
      cntl_system_error            = 2
      create_error                 = 3
      failed                       = 4
      tree_control_already_created = 5.
  IF sy-subrc <> 0.
    MESSAGE a001.
  ENDIF.

* define the events which will be passed to the backend
  " node double click
  event-eventid = cl_column_tree_model=>eventid_node_double_click.
  event-appl_event = 'X'.              " process PAI if event occurs
  APPEND event TO events.

  " item double click
  event-eventid = cl_column_tree_model=>eventid_item_double_click.
  event-appl_event = 'X'.
  APPEND event TO events.

  " link click
  event-eventid = cl_column_tree_model=>eventid_link_click.
  event-appl_event = 'X'.
  APPEND event TO events.

  " button click
  event-eventid = cl_column_tree_model=>eventid_button_click.
  event-appl_event = 'X'.
  APPEND event TO events.

  " checkbox change
  event-eventid = cl_column_tree_model=>eventid_checkbox_change.
  event-appl_event = 'X'.
  APPEND event TO events.

  " header click
  event-eventid = cl_column_tree_model=>eventid_header_click.
  event-appl_event = 'X'.
  APPEND event TO events.

  CALL METHOD g_tree->set_registered_events
    EXPORTING
      events                    = events
    EXCEPTIONS
      illegal_event_combination = 1
      unknown_event             = 2.
  IF sy-subrc <> 0.
    MESSAGE a001.
  ENDIF.

* assign event handlers in the application class to each desired event
  SET HANDLER g_application->handle_node_double_click FOR g_tree.
  SET HANDLER g_application->handle_item_double_click FOR g_tree.
  SET HANDLER g_application->handle_link_click FOR g_tree.
  SET HANDLER g_application->handle_button_click FOR g_tree.
  SET HANDLER g_application->handle_checkbox_change FOR g_tree.
  SET HANDLER g_application->handle_header_click FOR g_tree.

* add nodes to the tree model
  PERFORM add_nodes.

** expand the root node
*  call method g_tree->expand_node
*    exporting
*      node_key = 'ROOT' "#EC NOTEXT
*    exceptions
*      node_not_found = 1.
*  if sy-subrc <> 0.
*    message a001.
*  endif.

ENDFORM.                    " create_and_init_tree_0100
*&---------------------------------------------------------------------*
*&      Form  ADD_NODES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_nodes.

  DATA:  l_text(23)   TYPE c,
         node_key     TYPE tm_nodekey,
         relative_key TYPE tm_nodekey.
*
  LOOP AT it_dochis.

    REFRESH item_table.
* Node with key 'Root'
    CLEAR item.
    item-item_name = 'H1'.       "#EC NOTEXT " Item of Column 'Column1'
    item-class = cl_column_tree_model=>item_class_text. " Text Item
    item-text = it_dochis-docct.                            "#EC NOTEXT
    APPEND item TO item_table.

    CLEAR item.
    item-item_name = 'H2'.       "#EC NOTEXT " Item of Column 'Column1'
    item-class = cl_column_tree_model=>item_class_text. " Text Item
*  ITEM-CLASS = CL_COLUMN_TREE_MODEL=>ITEM_CLASS_CHECKBOX.
*  ITEM-EDITABLE = 'X'.
    item-text = it_dochis-docnb.                            "#EC NOTEXT
    APPEND item TO item_table.

    CLEAR item.
    item-item_name = 'BU'.       "#EC NOTEXT " Item of Column 'Column1'
    IF it_dochis-doccl EQ 'P'. " o/b/v/c/g
      item-class = cl_column_tree_model=>item_class_button.
      item-text = '수입의뢰생성'.

    ELSEIF it_dochis-doccl EQ '2'. " o/b/v/c/g
      item-class = cl_column_tree_model=>item_class_button.
      item-text = 'B/L 생성'.

    ELSEIF it_dochis-doccl EQ 'C'. " o/b/v/c/g
      item-class = cl_column_tree_model=>item_class_button.
      item-text = 'G/R 생성'.
    ELSE.
      item-class = cl_column_tree_model=>item_class_text.
      item-text = ' '.
*     ITEM-T_IMAGE = '@0B@'.
    ENDIF.
    APPEND item TO item_table.

    CLEAR item.
    item-item_name = 'H3'.       "#EC NOTEXT " Item of Column 'Column1'
    item-class = cl_column_tree_model=>item_class_text. " Text Item
    WRITE it_dochis-docat TO l_text
                          CURRENCY it_dochis-waers.
    item-text      = l_text.
    APPEND item TO item_table.


    CLEAR item.
    item-item_name = 'H4'.       "#EC NOTEXT " Item of Column 'Column1'
    item-class = cl_column_tree_model=>item_class_text. " Text Item
    item-text = it_dochis-waers.                            "#EC NOTEXT
    APPEND item TO item_table.

    CLEAR item.
    item-item_name = 'H5'.       "#EC NOTEXT " Item of Column 'Column1'
    item-class = cl_column_tree_model=>item_class_text. " Text Item
    item-text = it_dochis-docdt.                            "#EC NOTEXT
    APPEND item TO item_table.

    CLEAR item.
    item-item_name = 'H6'.       "#EC NOTEXT " Item of Column 'Column1'
    item-class = cl_column_tree_model=>item_class_text. " Text Item
    item-text = it_dochis-docnm.                            "#EC NOTEXT
    APPEND item TO item_table.


*  CALL METHOD g_tree->add_node
*    EXPORTING
*      node_key = it_dochis-nodekey "#EC NOTEXT
*      isfolder = 'X'
*      item_table = item_table
*    EXCEPTIONS
*      NODE_KEY_EXISTS         = 1
*      NODE_KEY_EMPTY          = 2
*      ILLEGAL_RELATIONSHIP    = 3
*      RELATIVE_NODE_NOT_FOUND = 4
*      ERROR_IN_ITEM_TABLE     = 5.
*  if sy-subrc <> 0.
*    message a001.
*  endif.
*

    node_key = it_dochis-nodekey.
    relative_key =  it_dochis-relatkey.
    CALL METHOD g_tree->add_node
      EXPORTING
        node_key                = node_key                  "#EC NOTEXT
        relative_node_key       = relative_key              "#EC NOTEXT
        relationship            = cl_tree_model=>relat_last_child
        isfolder                = 'X'
        item_table              = item_table
      EXCEPTIONS
        node_key_exists         = 1
        node_key_empty          = 2
        illegal_relationship    = 3
        relative_node_not_found = 4
        error_in_item_table     = 5.
    IF sy-subrc <> 0.
      MESSAGE a001.
    ENDIF.

  ENDLOOP.
**  DATA: item_table TYPE treemcitab,
**        item TYPE treemcitem,
**        node_key type tm_nodekey.



** Node with key 'Root'
*  CLEAR item.
*  item-item_name = 'Column1'. "#EC NOTEXT " Item of Column 'Column1'
*  item-class = cl_column_tree_model=>item_class_text. " Text Item
*  item-text = 'Root Col. 1'.           "#EC NOTEXT
*  APPEND item TO item_table.
*
*  CLEAR item.
*  item-item_name = 'Column2'. "#EC NOTEXT " Item of Column 'Column2'
*  item-class = cl_column_tree_model=>item_class_text.
*  item-text = 'Root Col. 2'.           "#EC NOTEXT
*  APPEND item TO item_table.
*
*  CLEAR item.
*  item-item_name = 'Column3'. "#EC NOTEXT " Item of Column 'Column3'
*  " Item is a link (click on link fires event LINK_CLICK)
*  item-class = cl_column_tree_model=>item_class_link.
*  item-text = 'Root Col. 3'.           "#EC NOTEXT "
*  APPEND item TO item_table.
*
*  CALL METHOD g_tree->add_node
*    EXPORTING
*      node_key = 'Root' "#EC NOTEXT
*      isfolder = 'X'
*      item_table = item_table
*    EXCEPTIONS
*      NODE_KEY_EXISTS         = 1
*      NODE_KEY_EMPTY          = 2
*      ILLEGAL_RELATIONSHIP    = 3
*      RELATIVE_NODE_NOT_FOUND = 4
*      ERROR_IN_ITEM_TABLE     = 5.
*  if sy-subrc <> 0.
*    message a001.
*  endif.
*
** Node with key 'Child1'
*  clear item_table.
*  CLEAR ITEM.
*  ITEM-ITEM_NAME = 'Column1'.
*  ITEM-CLASS = CL_COLUMN_TREE_MODEL=>ITEM_CLASS_TEXT.
*  ITEM-TEXT = 'Child1 Col. 1'. "#EC NOTEXT
*  APPEND ITEM TO ITEM_TABLE.
*
*  CLEAR ITEM.
*  ITEM-ITEM_NAME = 'Column2'.     "
*  ITEM-CLASS = CL_COLUMN_TREE_MODEL=>ITEM_CLASS_BUTTON.
*  " Item is a button
*  ITEM-TEXT = 'Child1 Col. 2'. "#EC NOTEXT
*  ITEM-T_IMAGE = '@0B@'.
*  APPEND ITEM TO ITEM_TABLE.
*
*  CLEAR ITEM.
*  ITEM-ITEM_NAME = 'Column3'.
*  " Item is a checkbox
*  ITEM-CLASS = CL_COLUMN_TREE_MODEL=>ITEM_CLASS_CHECKBOX.
*  ITEM-EDITABLE = 'X'.
*  ITEM-TEXT = 'Child1 Col. 3'. "#EC NOTEXT
*  ITEM-T_IMAGE = '@0C@'.
*  APPEND ITEM TO ITEM_TABLE.
*
*  CALL METHOD g_tree->add_node
*    EXPORTING
*      node_key = 'Child1' "#EC NOTEXT
*      relative_node_key = 'Root' "#EC NOTEXT
*      relationship = cl_tree_model=>relat_last_child
*      isfolder = 'X'
*      item_table = item_table
*    EXCEPTIONS
*      NODE_KEY_EXISTS         = 1
*      NODE_KEY_EMPTY          = 2
*      ILLEGAL_RELATIONSHIP    = 3
*      RELATIVE_NODE_NOT_FOUND = 4
*      ERROR_IN_ITEM_TABLE     = 5.
*  if sy-subrc <> 0.
*    message a001.
*  endif.
**
*** add 1000 children to node Child1
**  do 1000 times.
**    node_key = sy-index.
**    clear item_table.
**    CLEAR ITEM.
**    ITEM-ITEM_NAME = 'Column1'. "#EC NOTEXT
**    ITEM-CLASS = CL_COLUMN_TREE_MODEL=>ITEM_CLASS_TEXT.
**    ITEM-TEXT = node_key.
**    APPEND ITEM TO ITEM_TABLE.
**
**    CALL METHOD g_tree->add_node
**      EXPORTING
**        node_key = node_key
**        relative_node_key = 'Child1' "#EC NOTEXT
**        relationship = cl_tree_model=>relat_last_child
**        isfolder = ' '
**        item_table = item_table
**      EXCEPTIONS
**        NODE_KEY_EXISTS         = 1
**        NODE_KEY_EMPTY          = 2
**        ILLEGAL_RELATIONSHIP    = 3
**        RELATIVE_NODE_NOT_FOUND = 4
**        ERROR_IN_ITEM_TABLE     = 5.
**    if sy-subrc <> 0.
**      message a001.
**    endif.
**  enddo.

ENDFORM.                               " ADD_NODES
*&---------------------------------------------------------------------*
*&      Form  build_header
*&---------------------------------------------------------------------*
FORM build_header .
  DATA: l_header LIKE treev_hdr.



* Column2
  CALL METHOD g_tree->add_column
    EXPORTING
      name                = 'H2'                            "#EC NOTEXT
      width               = 10
      header_text         = '문서번호'                      "#EC NOTEXT
    EXCEPTIONS
      column_exists       = 1
      illegal_column_name = 2
      too_many_columns    = 3
      illegal_alignment   = 4.
  IF sy-subrc <> 0.
    MESSAGE a001.
  ENDIF.

* Column2-1
  CALL METHOD g_tree->add_column
    EXPORTING
      name                = 'BU'                            "#EC NOTEXT
      width               = 10
      header_text         = ' '                             "#EC NOTEXT
    EXCEPTIONS
      column_exists       = 1
      illegal_column_name = 2
      too_many_columns    = 3
      illegal_alignment   = 4.
  IF sy-subrc <> 0.
    MESSAGE a001.
  ENDIF.

* Column3
  CALL METHOD g_tree->add_column
    EXPORTING
      name                = 'H3'                            "#EC NOTEXT
      width               = 23
      header_text         = '금 액'                         "#EC NOTEXT
    EXCEPTIONS
      column_exists       = 1
      illegal_column_name = 2
      too_many_columns    = 3
      illegal_alignment   = 4.
  IF sy-subrc <> 0.
    MESSAGE a001.
  ENDIF.

* Column4
  CALL METHOD g_tree->add_column
    EXPORTING
      name                = 'H4'                            "#EC NOTEXT
      width               = 6
      header_text         = '통 화'                         "#EC NOTEXT
    EXCEPTIONS
      column_exists       = 1
      illegal_column_name = 2
      too_many_columns    = 3
      illegal_alignment   = 4.
  IF sy-subrc <> 0.
    MESSAGE a001.
  ENDIF.

* Column5
  CALL METHOD g_tree->add_column
    EXPORTING
      name                = 'H5'                            "#EC NOTEXT
      width               = 14
      header_text         = '관련일자'                      "#EC NOTEXT
    EXCEPTIONS
      column_exists       = 1
      illegal_column_name = 2
      too_many_columns    = 3
      illegal_alignment   = 4.
  IF sy-subrc <> 0.
    MESSAGE a001.
  ENDIF.

* Column6
  CALL METHOD g_tree->add_column
    EXPORTING
      name                = 'H6'                            "#EC NOTEXT
      width               = 20
      header_text         = '관련문서번호'                  "#EC NOTEXT
    EXCEPTIONS
      column_exists       = 1
      illegal_column_name = 2
      too_many_columns    = 3
      illegal_alignment   = 4.
  IF sy-subrc <> 0.
    MESSAGE a001.
  ENDIF.
ENDFORM.                    " build_header
*&---------------------------------------------------------------------*
*&      Form  handle_button_click
*&---------------------------------------------------------------------*
FORM handle_button_click .

  READ TABLE it_dochis WITH KEY nodekey = g_node_key.

  MESSAGE i915 WITH it_dochis-doccl it_dochis-docnb.



ENDFORM.                    " handle_button_click
*&---------------------------------------------------------------------*
*&      Form  display_selected_node_info
*&---------------------------------------------------------------------*
FORM display_selected_node_info  USING    p_node_key.

  DATA:         l_strlen   TYPE i.

  CHECK NOT p_node_key IS INITIAL.

*> 현재문서 라인을 더블클릭했을 경우.
*  CHECK g_node_key NE p_node_key.

  READ TABLE it_dochis WITH KEY nodekey = p_node_key.
  IF sy-subrc EQ 0.
    CASE it_dochis-doccl.
      WHEN 'P'.
        PERFORM  display_purchase_order(ztir0000)
                                        USING it_dochis-docnb
                                              '00000'.
      WHEN '0' OR '1' OR '2' OR '3' OR '4' OR
           '5' OR '6' OR '7' OR '8' OR '9'.
        l_strlen = STRLEN( it_dochis-docnb ).

        IF l_strlen GT 5.
          PERFORM  display_import_document(ztir0000)
                                          USING it_dochis-docnb
                                                '00'
                                                '00000'.
        ELSE.
          PERFORM  display_import_document(ztir0000)
                                          USING it_dochis-relatkey
                                                it_dochis-docnb
                                                '00000'.
        ENDIF.
      WHEN 'B'.   "> B/L 문서.
        PERFORM  display_bl_document(ztir0000)
                                        USING it_dochis-docnb
                                              '00000'.
      WHEN 'C'.   "> B/L 문서.
        PERFORM  display_cc_document(ztir0000)
                                        USING it_dochis-docnb
                                              '00'.
      WHEN 'V' OR 'Z'.   "> 송장/선급금 문서.
        PERFORM  display_civ_document(ztir0000)
                                        USING it_dochis-docnb.
      WHEN 'G'.           "> 입고.
        PERFORM  display_gr_document(ztir0000)
                                        USING it_dochis-docnb.
      WHEN OTHERS.
    ENDCASE.
  ELSE.
    MESSAGE s903.
  ENDIF.






ENDFORM.                    " display_selected_node_info
