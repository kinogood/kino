*&---------------------------------------------------------------------*
*& Include          LZGTPP13F01
*&---------------------------------------------------------------------*
FORM pgman_editor_popup

  USING    pv_title   TYPE c
           pv_display TYPE xfeld

  CHANGING ct_text    TYPE ty_pgman_text
           cv_ucomm   TYPE syucomm

           cv_error   TYPE string.
  DATA: lv_cols   TYPE i,
        lv_rows   TYPE i,
        lv_width  TYPE i,
        lv_height TYPE i,
        lv_x1     TYPE i,
        lv_y1     TYPE i,
        lv_x2     TYPE i,
        lv_y2     TYPE i,
        lo_error  TYPE REF TO cx_root.

* 팝업을 열기 전 호출 화면 크기를 보관
  lv_cols = sy-scols.
  lv_rows = sy-srows.
  cv_ucomm = 'CX_CANC'.

  CLEAR: cv_error, gv_pgman_error, gv_pgman_accept,
         gv_pgman_ok, gt_pgman_result.
  IF lv_cols < 40 OR lv_rows < 12.
    cv_error = 'SAP GUI 창을 넓힌 뒤 매뉴얼을 다시 열어주세요.'.
    RETURN.
  ENDIF.
  IF gc_pgman_percent < 75 OR gc_pgman_percent > 95.
    cv_error = '팝업 크기 비율은 75에서 95 사이로 지정하세요.'.
    RETURN.
  ENDIF.

  gt_pgman_text = ct_text.
  gv_pgman_title = pv_title.
  gv_pgman_display = pv_display.
  lv_width  = lv_cols * gc_pgman_percent / 100.
  lv_height = lv_rows * gc_pgman_percent / 100.
  lv_x1 = ( lv_cols - lv_width ) / 2.
  lv_y1 = ( lv_rows - lv_height ) / 2.

  IF lv_x1 < 1.
    lv_x1 = 1.
  ENDIF.
  IF lv_y1 < 1.
    lv_y1 = 1.
  ENDIF.

  lv_x2 = lv_x1 + lv_width.
  lv_y2 = lv_y1 + lv_height.

  TRY.
      CALL SCREEN 9000
        STARTING AT lv_x1 lv_y1
        ENDING   AT lv_x2 lv_y2.
    CATCH cx_root INTO lo_error.
      gv_pgman_error = lo_error->get_text( ).
  ENDTRY.

* 확인을 누르고 텍스트 수집도 성공한 경우만 호출 함수에 전달
  IF gv_pgman_accept = 'X'
     AND gv_pgman_display IS INITIAL
     AND gv_pgman_error IS INITIAL.
    ct_text = gt_pgman_result.
    cv_ucomm = 'CX_CONT'.
  ENDIF.
  cv_error = gv_pgman_error.

  PERFORM pgman_free_controls.

  CLEAR: gt_pgman_text, gt_pgman_result,
         gv_pgman_ok, gv_pgman_accept.

ENDFORM.
*&---------------------------------------------------------------------*
FORM pgman_free_controls.
  IF go_pgman_editor IS BOUND.
    CALL METHOD go_pgman_editor->free
      EXCEPTIONS
        OTHERS = 1.
    FREE go_pgman_editor.
  ENDIF.
  IF go_pgman_container IS BOUND.
    CALL METHOD go_pgman_container->free
      EXCEPTIONS
        OTHERS = 1.
    FREE go_pgman_container.
  ENDIF.
  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      OTHERS = 1.
ENDFORM.
*&---------------------------------------------------------------------*
FORM pgman_create_controls.
  DATA: lv_readonly TYPE i.
  CREATE OBJECT go_pgman_container
    EXPORTING
      container_name = 'CC_MANUAL'
    EXCEPTIONS
      OTHERS         = 1.
  IF sy-subrc <> 0.
    gv_pgman_error = 'CC_MANUAL 화면 컨트롤을 생성하지 못했습니다.'.
    RETURN.
  ENDIF.

* SAPscript TLINE과 동일한 132자 단위. 긴 입력은 줄바꿈하여 반환.
  CREATE OBJECT go_pgman_editor
    EXPORTING
      parent                     = go_pgman_container
      wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
      wordwrap_position          = 132
      wordwrap_to_linebreak_mode = cl_gui_textedit=>true
    EXCEPTIONS
      OTHERS                     = 1.
  IF sy-subrc <> 0.
    gv_pgman_error = '텍스트 편집기를 생성하지 못했습니다.'.
    RETURN.
  ENDIF.
  CALL METHOD go_pgman_editor->set_text_as_r3table
    EXPORTING
      table  = gt_pgman_text
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc <> 0.
    gv_pgman_error = '매뉴얼 내용을 편집기에 전달하지 못했습니다.'.
    RETURN.
  ENDIF.
  lv_readonly = cl_gui_textedit=>false.
  IF gv_pgman_display = 'X'.
    lv_readonly = cl_gui_textedit=>true.
  ENDIF.
  CALL METHOD go_pgman_editor->set_readonly_mode
    EXPORTING
      readonly_mode = lv_readonly
    EXCEPTIONS
      OTHERS        = 1.
  IF sy-subrc <> 0.
    gv_pgman_error = '편집 또는 읽기 전용 모드를 설정하지 못했습니다.'.
    RETURN.
  ENDIF.
  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc <> 0.
    gv_pgman_error = 'SAP GUI와 텍스트 편집기를 연결하지 못했습니다.'.
  ENDIF.
ENDFORM.
