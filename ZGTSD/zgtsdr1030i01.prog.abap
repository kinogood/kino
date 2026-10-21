*&---------------------------------------------------------------------*
*& Include          ZGTSDR1030I01
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
      IF gv_lock IS NOT INITIAL.
        PERFORM control_lock_object    USING    'U'
                                                gv_lock
                                                sy-cprog
                                       CHANGING gv_error.
      ENDIF.

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
      IF gv_lock IS NOT INITIAL.
        PERFORM control_lock_object    USING    'U'
                                                gv_lock
                                                sy-cprog
                                       CHANGING gv_error.
      ENDIF.

      LEAVE TO SCREEN 0.

    WHEN 'SAVE'.       " 단가 저장
      PERFORM price_save .

    WHEN 'NF_DISP'.    " 동가 조회
      PERFORM call_nf_disp.

  ENDCASE.

**

ENDMODULE.
