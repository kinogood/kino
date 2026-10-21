*&---------------------------------------------------------------------*
*& Include          ZGTLER2100I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
MODULE exit_0100 INPUT.

**
  gv_save_cd = gv_okcode.
  CLEAR: gv_okcode.

  CASE gv_save_cd.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

**

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

**
  gv_save_cd = gv_okcode.
  CLEAR: gv_okcode.

  CLEAR: gv_error.
  CASE gv_save_cd.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.

    WHEN 'GI'.               "입고(MIGO)
      PERFORM start_gi_process          USING  gv_save_cd.
      PERFORM refresh_data_get.

    WHEN 'GT'.               "취소(MBST)
      PERFORM start_canc_process        USING  gv_save_cd.
      PERFORM refresh_data_get.

*   Refresh
    WHEN 'REFR'.
      PERFORM refresh_data_get.

    WHEN 'SGORT'.            " 저장위치 지정
      PERFORM input_sgort_multi_lines   USING  gv_save_cd.

    WHEN 'DETAIL'.
      PERFORM set_detail_item_list      USING  gv_save_cd.

    WHEN 'ALL' OR     " 전체선택
         'DALL'.
      PERFORM select_control            USING  gv_save_cd.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_0200  INPUT
*&---------------------------------------------------------------------*
MODULE exit_0200 INPUT.

**
  gv_save_cd2 = gv_okcode2.
  CLEAR: gv_okcode2.

  CASE gv_save_cd2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.

**

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

**
  gv_save_cd2 = gv_okcode2.
  CLEAR: gv_okcode2.

  CLEAR: gv_error.
  CASE gv_save_cd2.
    WHEN 'BACK'.
      CLEAR: gs_sgort-lgort.
      LEAVE TO SCREEN 0.

    WHEN 'SAVE'.
      PERFORM set_input_lgort  USING:   gs_sgort-lgort
                               CHANGING gv_error.
      IF gv_error IS INITIAL.
        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN 'CLOSE'.
      CLEAR: gs_sgort-lgort.
      LEAVE TO SCREEN 0.

    WHEN 'ENTR'.
      PERFORM set_lgort_name   USING:   gs_sgort-lgort
                               CHANGING gs_sgort-lgobe.

  ENDCASE.

**

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_SGORT  INPUT
*&---------------------------------------------------------------------*
MODULE f4_sgort INPUT.

**
  PERFORM get_lgort_from_f4  USING    gs_sgort-werks
                             CHANGING gs_sgort-lgort.

  PERFORM set_lgort_name     USING:   gs_sgort-lgort
                             CHANGING gs_sgort-lgobe.

  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = 'ENTR'.
**

ENDMODULE.
