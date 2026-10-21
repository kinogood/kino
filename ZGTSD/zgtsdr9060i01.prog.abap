*&---------------------------------------------------------------------*
*& Include          ZGTSDR9060I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*  Screen 0100 Exit User-Command 수행
*----------------------------------------------------------------------*
MODULE exit_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'BACK' OR 'CANC'.
      PERFORM clear_alv_info.

      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      PERFORM clear_alv_info.

      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*  Screen 0100 User-Command 수행
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA lv_okcode TYPE syucomm.

  lv_okcode = gv_okcode.

  CLEAR gv_okcode.

  CASE lv_okcode.
*-----------------------------------------------------------------------
*-- Mapping
*-----------------------------------------------------------------------
    WHEN 'SAVE'.            " Mapping 정보 저장
      PERFORM save_mapping_data.
    WHEN 'DEL'.             " Mapping 정보 삭제
      PERFORM del_mapping_data.
*-----------------------------------------------------------------------
*-- To-Be
*-----------------------------------------------------------------------
    WHEN 'SAVE_T'.          " To-Be 정보 저장
      PERFORM save_to_be_data.

    WHEN 'DEL_T'.           " To-Be 정보 삭제
      PERFORM del_to_be_data.

    WHEN 'CRTE'.            " To-Be 판매오더 생성
      PERFORM crte_so_to_be.

    WHEN 'ORD_DEL'.         " To-Be 판매오더 삭제
      PERFORM del_so_to_be.

    WHEN 'DEL_DB'.          " 조회된 정보 기준 삭제
      PERFORM del_db_to_sel.

    WHEN 'ORD_REJ'.         " As-Is 판매오더 거부사유처리
      PERFORM rej_ord_asis.

  ENDCASE.

ENDMODULE.
