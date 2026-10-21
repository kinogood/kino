*----------------------------------------------------------------------*
***INCLUDE LZGTPP13I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PGMAN_9000_EXIT  INPUT
*&---------------------------------------------------------------------*
*       프로그램 HELP 등록 2026.09.14 by 김재석
*----------------------------------------------------------------------*
MODULE pgman_9000_exit INPUT.
* BACK, EXIT, CANC는 GUI STATUS에서 기능 유형 E로 지정
  CLEAR: gv_pgman_ok, gv_pgman_accept.
  LEAVE TO SCREEN 0.
ENDMODULE.
*----------------------------------------------------------------------*
MODULE pgman_9000_pai INPUT.
  CASE gv_pgman_ok.
    WHEN 'ACCEPT'.
      CLEAR: gv_pgman_ok, gv_pgman_accept, gt_pgman_result.
      IF gv_pgman_display = 'X'.
        MESSAGE '조회 모드에서는 수정 내용을 저장할 수 없습니다.' TYPE 'E'.
      ENDIF.
      CALL METHOD go_pgman_editor->get_text_as_r3table
        EXPORTING
          only_when_modified = cl_gui_textedit=>false
        IMPORTING
          table              = gt_pgman_result
        EXCEPTIONS
          OTHERS             = 1.
      IF sy-subrc <> 0.
        MESSAGE '본문을 가져오지 못했습니다. 내용을 복사해 보관하세요.' TYPE 'E'.
      ENDIF.
* 프런트엔드의 최신 텍스트를 실제로 받기까지 대기
      CALL METHOD cl_gui_cfw=>flush
        EXCEPTIONS
          OTHERS = 1.
      IF sy-subrc <> 0.
        CLEAR gt_pgman_result.
        MESSAGE '본문 수신에 실패했습니다. 내용을 복사해 보관하세요.' TYPE 'E'.
      ENDIF.
      gv_pgman_accept = 'X'.
      LEAVE TO SCREEN 0.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR: gv_pgman_ok, gv_pgman_accept.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      CLEAR gv_pgman_ok.
  ENDCASE.
ENDMODULE.
