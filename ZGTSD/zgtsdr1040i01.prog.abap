*&---------------------------------------------------------------------*
*& Include          ZGTSDR1040I01
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

    WHEN 'CREATE'.    " 매출정산
      PERFORM start_document_process    USING  gv_save_cd.

    WHEN 'CANCEL'.    " 정산취소
      PERFORM start_cancel_document     USING  gv_save_cd.

    WHEN 'PRICE' or     " 단가정정
         'PRIC_DISP'.   " 단가조회
      PERFORM submit_price_manage       USING  gv_save_cd.

    WHEN 'DETAIL'.    " 매출정산 Detail.
      CLEAR: gv_change.
      PERFORM display_item_list         USING  gv_save_cd.

    WHEN 'DELETE'.    " 정산Data 삭제
      PERFORM handle_db_data_delete     USING  gv_save_cd.

    WHEN 'SEARCH'.    " 당월 출고내역 조회
      PERFORM search_delivery_of_month  USING  gv_save_cd.

    WHEN 'ENTER'.
      PERFORM calculate_item_value.

  ENDCASE.

**

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
    WHEN 'BACK' OR 'CLOSE'.
      LEAVE TO SCREEN 0.

  ENDCASE.

**

ENDMODULE.
