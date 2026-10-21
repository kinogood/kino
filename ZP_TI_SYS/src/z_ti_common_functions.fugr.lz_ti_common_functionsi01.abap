*&---------------------------------------------------------------------*
*&  Include           LZ_TI_COMMON_FUNCTIONSI01                        *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*>  input module for tc 'TC_0100'. do not change this line!
*>  modify table
*&---------------------------------------------------------------------*
MODULE tc_0100_modify INPUT.

  MODIFY xprtctl
    FROM ztisprtctl
   INDEX tc_0100-current_line.
ENDMODULE.                    "TC_0100_modify INPUT

*&---------------------------------------------------------------------*
*>  input modul for tc 'TC_0100'. do not change this line!
*>  mark table
*&---------------------------------------------------------------------*
MODULE tc_0100_mark INPUT.
  DATA: g_tc_0100_wa2 LIKE LINE OF xprtctl.
  IF tc_0100-line_sel_mode = 1.
    LOOP AT xprtctl INTO g_tc_0100_wa2
      WHERE flag = 'X'.
      g_tc_0100_wa2-flag = ''.
      MODIFY xprtctl
        FROM g_tc_0100_wa2
        TRANSPORTING flag.
    ENDLOOP.
  ENDIF.
  MODIFY xprtctl
    FROM ztisprtctl
   INDEX tc_0100-current_line
    TRANSPORTING flag.
ENDMODULE.                    "TC_0100_mark INPUT

*&---------------------------------------------------------------------*
*>  input module for tc 'TC_0100'. do not change this line!
*>  process user command
*&---------------------------------------------------------------------*
MODULE tc_0100_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_0100'
                              'XPRTCTL'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TC_0100_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit_scr0100  INPUT
*&---------------------------------------------------------------------*
MODULE fcode_exit_scr0100 INPUT.

  CLEAR xprtctl-flag.
  MODIFY   xprtctl TRANSPORTING flag WHERE flag = 'X'.
  answer = 'N'.
  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr0100  INPUT

*&---------------------------------------------------------------------*
*>  input module for tc 'TC_0200'. do not change this line!
*>  modify table
*&---------------------------------------------------------------------*
MODULE tc_0200_modify INPUT.

  IF ztispokey-ebeln IS INITIAL.
    CLEAR ztispokey-ebelp.
  ENDIF.

  IF NOT ztispokey-ebeln IS INITIAL.
    IF NOT ztispokey-ebelp IS INITIAL.
      SELECT SINGLE ebeln ebelp
        INTO (ekpo-ebeln, ekpo-ebelp)
        FROM ekpo
       WHERE ebeln  EQ  ztispokey-ebeln
         AND ebelp  EQ  ztispokey-ebelp.
      IF sy-subrc NE 0.
        MESSAGE i101 WITH ztispokey-ebeln ztispokey-ebelp.
      ENDIF.
    ELSE.
      SELECT SINGLE ebeln
        INTO it_pokey-ebeln
        FROM ekko
       WHERE ebeln  EQ  ztispokey-ebeln.
      IF sy-subrc NE 0.
        MESSAGE e101 WITH ztispokey-ebeln.
      ENDIF.
    ENDIF.
  ENDIF.

  MOVE-CORRESPONDING ztispokey TO it_pokey.

  MODIFY  it_pokey
    INDEX tc_0200-current_line.

  IF sy-subrc NE 0.
    APPEND it_pokey.
  ENDIF.

ENDMODULE.                    "TC_0200_modify INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE ok_code.
    WHEN 'FEXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'FCOPY'.
      PERFORM get_used_payment_term(ztir0000)   TABLES it_ztitig02
                                                USING  g_subrc
                                                       c_error.

      CLEAR g_count.
      LOOP AT it_pokey.
        IF it_pokey-ebeln IS INITIAL.
          DELETE it_pokey.
          CONTINUE.
        ENDIF.

        PERFORM get_purchase_order_data(ztir0000)
                                          TABLES it_po
                                                 it_ztitig02
                                          USING  it_pokey-ebeln
                                                 it_pokey-ebelp
                                                 c_error
                                                 c_info.

        IF NOT it_pokey-ebelp IS INITIAL.
          READ TABLE it_reqit WITH KEY ebeln = it_pokey-ebeln
                                       ebelp = it_pokey-ebelp
                                       BINARY SEARCH.
          IF sy-subrc EQ 0.
            MESSAGE i110 WITH it_pokey-ebeln it_pokey-ebelp.
            DELETE it_pokey.
            CONTINUE.
          ENDIF.
        ENDIF.

        LOOP AT it_po.
          CLEAR: g_modify, ztivpo00.

          DESCRIBE TABLE it_reqit LINES g_count_1.
          PERFORM  get_and_check_po_data(ztir0000)
                                           USING  it_po-ebeln
                                                  it_po-ebelp
                                                  g_modify
                                                  ztivpo00
                                                  g_count_1
                                                  c_error.

          READ TABLE it_reqit WITH KEY ebeln = it_po-ebeln
                                       ebelp = it_po-ebelp
                                       BINARY SEARCH.
          IF sy-subrc EQ 0.
            MESSAGE i110 WITH it_po-ebeln it_po-ebelp.
*            DELETE it_pokey.
            CONTINUE.
          ENDIF.

*> PO data Move
          IF g_modify NE c_true.
            PERFORM set_request_of_import_data(ztir0000)
                                               TABLES it_reqit
                                               USING  ztivpo00
                                                      ztitrqk
                                                      ztitrqs
                                                      it_po.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fcode_exit INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit  INPUT

*&---------------------------------------------------------------------*
*>  input module for tc 'TC_0300'. do not change this line!
*>  modify table
*&---------------------------------------------------------------------*
MODULE tc_0300_modify INPUT.
  MOVE-CORRESPONDING ztitlc2 TO g_tc_0300_wa.
  MODIFY g_tc_0300_itab
    FROM g_tc_0300_wa
    INDEX tc_0300-current_line.
*  IF sy-subrc NE 0.
*    APPEND g_tc_0300_wa TO g_tc_0300_itab.
*  ENDIF.
*
ENDMODULE.                    "TC_0300_modify INPUT
*&---------------------------------------------------------------------*
*> input module for tc 'TC_0300'. do not change this line!
*> mark table
*&---------------------------------------------------------------------*
MODULE tc_0300_mark INPUT.
  IF tc_0300-line_sel_mode = 1 AND
     g_tc_0300_wa-flag = 'X'.
    LOOP AT g_tc_0300_itab INTO g_tc_0300_wa
      WHERE flag = 'X'.
      g_tc_0300_wa-flag = ''.
      MODIFY g_tc_0300_itab
        FROM g_tc_0300_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tc_0300_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tc_0300_itab
    FROM g_tc_0300_wa
    INDEX tc_0300-current_line
    TRANSPORTING flag.
ENDMODULE.                    "TC_0300_mark INPUT

*&---------------------------------------------------------------------*
*>  input module for tc 'TC_0300'. do not change this line!
*>  process user command
*&---------------------------------------------------------------------*
MODULE tc_0300_user_command INPUT.

  ok_code = sy-ucomm.

  IF g_button EQ 'N'.
    PERFORM user_ok_tc_no_button USING 'TC_0300'
                                       'G_TC_0300_ITAB'
                                       'FLAG'
                              CHANGING ok_code.
  ELSE.
    PERFORM user_ok_tc USING    'TC_0300'
                                'G_TC_0300_ITAB'
                                'FLAG'
                       CHANGING ok_code.
  ENDIF.

  sy-ucomm = ok_code.

  CLEAR g_count.
  LOOP AT g_tc_0300_itab INTO g_tc_0300_wa.
    ADD 1 TO g_count.
    g_tc_0300_wa-qitno = g_count.
    MODIFY g_tc_0300_itab FROM g_tc_0300_wa.
  ENDLOOP.


ENDMODULE.                    "TC_0300_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2128  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2128 INPUT.

*  CALL FUNCTION 'CONTROL_DISPATCH'
*     EXPORTING
*          fcode        = g_okcode
**           SYSTEM       = ' '
*     EXCEPTIONS
*          cb_not_found = 1
*          OTHERS       = 2.
*
*  IF sy-subrc NE 0.
*    MESSAGE a001(treecontrol) WITH 'CONTROL_DISPATCH'.
*  ENDIF.
*
*  CLEAR g_okcode.
*  CALL FUNCTION 'CONTROL_FLUSH'
*    EXCEPTIONS
*      cntl_system_error = 1
*      cntl_error        = 2
*      OTHERS            = 3.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
*  CALL METHOD cl_gui_cfw=>dispatch.
*  exit.
  CHECK sy-ucomm(4) EQ '%_GC'.

  CALL FUNCTION 'TREEV_GET_SELECTED_ITEM'
    EXPORTING
      handle                            = g_tree_handle
*   NO_FLUSH                          =
    IMPORTING
      node_key                          = g_node_key
*    ITEM_NAME                         =
   EXCEPTIONS
     failed                            = 1
     instance_not_found                = 2
     not_allowed_for_simple_tree       = 3
     cntl_system_error                 = 4
     no_item_selection                 = 5
     OTHERS                            = 6.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    CALL FUNCTION 'TREEV_GET_SELECTED_NODE'
      EXPORTING
        handle                            = g_tree_handle
*   NO_FLUSH                          =
      IMPORTING
        node_key                          = g_node_key
     EXCEPTIONS
        FAILED                            = 1
        INSTANCE_NOT_FOUND                = 2
        SINGLE_NODE_SELECTION_ONLY        = 3
        CNTL_SYSTEM_ERROR                 = 4
        OTHERS                            = 5.
    IF sy-subrc EQ 0.
      IF NOT g_node_key IS INITIAL.
        PERFORM display_selected_node_info USING g_node_key.
      ENDIF.
    ENDIF.
  ELSE.
    IF NOT g_node_key IS INITIAL.
      PERFORM display_selected_node_info USING g_node_key.
    ENDIF.
  ENDIF.

ENDMODULE.                 " user_command_2128  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_2127  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2127 INPUT.

ENDMODULE.                 " user_command_2127  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_scr0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_scr0500 INPUT.

  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN 'TC_0100_OK'.                      "확인.
      g_answer = 'Y'.
      LEAVE TO SCREEN 0.
    WHEN 'TC_0100_EX'.                      "취소.
      g_answer = 'N'.
      LEAVE TO SCREEN 0.
  ENDCASE.
  sy-ucomm = ok_code.

ENDMODULE.                 " user_command_scr0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input_value_scr0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input_value_scr0500 INPUT.

  CHECK ok_code EQ 'TC_0100_OK'.

  IF ztisscrcom-monsc IS INITIAL.
    PERFORM no_input_check(ztir0000)
                      USING 'ZTISSCRCOM' 'MONSC' c_error.
  ENDIF.

ENDMODULE.                 " check_input_value_scr0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  fcode_exit_scr0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fcode_exit_scr0500 INPUT.

  g_answer = 'N'.
  LEAVE TO SCREEN 0.

ENDMODULE.                 " fcode_exit_scr0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT_VALUE_SCR8000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input_value_scr8000 INPUT.

  CHECK ok-code NE 'ZTINO'.

  IF ztitcso-name IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSO' 'NAME'   'E'.
  ENDIF.

  IF ztitcso-city IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSO' 'CITY'   'E'.
  ENDIF.

  IF ztitcso-country IS INITIAL.
    PERFORM no_input_check(ztir0000) USING 'ZTITCSO' 'COUNTRY' 'E'.
  ENDIF.

ENDMODULE.                 " CHECK_INPUT_VALUE_SCR8000  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_8000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_8000 INPUT.

  CASE ok-code.
    WHEN 'ZTIOKAY'.
      LEAVE TO SCREEN 0.
    WHEN 'ZTINO'.
      LEAVE TO SCREEN 0.
  ENDCASE.

  CLEAR: ok-code.

ENDMODULE.                 " user_command_8000  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0600 INPUT.

  CASE ok-code.
    WHEN 'ZTICLOSE'.
      LEAVE TO SCREEN 0.
  ENDCASE.

  CLEAR: ok-code.

ENDMODULE.                 " user_command_0600  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module USER_COMMAND_0700 input.

  CASE ok_code.
    WHEN 'TC_0100_EX'.
      g_answer = 'N'.
      LEAVE TO SCREEN 0.
    WHEN 'TC_0100_OK'.
      CASE 'X'.
        WHEN g_radio1.              g_answer = '1'.
        WHEN g_radio2.              g_answer = '2'.
      ENDCASE.
      LEAVE TO SCREEN 0.
  ENDCASE.

endmodule.                 " USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_0210_modify  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module tc_0210_modify input.

endmodule.                 " tc_0210_modify  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0210 input.

endmodule.                 " user_command_0210  INPUT
