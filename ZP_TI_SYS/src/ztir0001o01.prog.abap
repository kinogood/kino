************************************************************************
* Title         :  ZTER6910O01                                         *
*                                                                      *
* Description   : T/T 미정리 리스트 관리 PBO Include                   *
*                                                                      *
* Creation Date : 2003/08/20                                           *
*                                                                      *
* Author        : Seog Bong, Kang                                      *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*&---------------------------------------------------------------------*
*&      Module  pbo_scr2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_scr2000 OUTPUT.

  SET PF-STATUS 'STATUS2000'.

  CASE 'X'.
    WHEN p_step1.
      SET TITLEBAR  'T2000' WITH '수취 계좌리스트 미승인'(s01).
    WHEN p_step2.
      SET TITLEBAR  'T2000' WITH '수취 계좌리스트 승인'(s02).
    WHEN p_step3.
      SET TITLEBAR  'T2000' WITH '전체현황 - 수취 계좌리스트'(s06).
  ENDCASE.

  PERFORM create_and_init_controls_2000.

ENDMODULE.                 " pbo_scr2000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_field_attribute_scr3000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_field_attribute_scr3000 OUTPUT.
  clear g_lifnrnm.

  LOOP AT SCREEN.
    CLEAR g_fieldgroup.
    CONCATENATE screen-group1 screen-group2
                screen-group3 screen-group4
           INTO g_fieldgroup.

    SEARCH g_fieldgroup FOR g_mode.
    IF sy-subrc <> 0.
      screen-input = c_char0.
    ELSE.
      screen-input = c_char1.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " change_field_attribute_scr3000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_3000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_3000 OUTPUT.

  REFRESH excl.

  CASE g_mode.
    WHEN 'C'.
      SET TITLEBAR  'T2000' WITH '등록 대화상자'.
    WHEN 'M'.
      SET TITLEBAR  'T2000' WITH '변경 대화상자'.
    WHEN 'S'.
      SET TITLEBAR  'T2000' WITH '조회 대화상자'.
      MOVE 'BU' TO excl-funktion.    APPEND excl.
  ENDCASE.

  SET PF-STATUS 'STATUS3000' EXCLUDING excl.

  CLEAR: ok_code.

ENDMODULE.                 " status_3000  OUTPUT
