*&---------------------------------------------------------------------*
*& INCLUDE          ZGTMMR4332C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* ALV 이벤트 핸들러
*  - 품목 더블클릭 -> 입고 전표/라벨 팝업
*  - 핫스팟 클릭   -> 구매오더(ME23N) / 판매오더(VA03) / 자재(MM03) / 자재문서(MIGO) 조회
*----------------------------------------------------------------------*
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    METHODS on_dbl_item
      FOR EVENT double_click OF cl_salv_events_table
      IMPORTING row column.
    METHODS on_link_item
      FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row column.
    METHODS on_link_det
      FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.
  METHOD on_dbl_item.
    READ TABLE gt_view ASSIGNING FIELD-SYMBOL(<ls_item>) INDEX row.
    IF sy-subrc = 0.
      PERFORM show_docs USING <ls_item>-delno <ls_item>-delitem.
    ENDIF.
  ENDMETHOD.

  METHOD on_link_item.
    READ TABLE gt_view ASSIGNING FIELD-SYMBOL(<ls_item>) INDEX row.
    CHECK sy-subrc = 0.
    CASE column.
      WHEN 'EBELN'.
        PERFORM goto_doc USING 'PO' <ls_item>-ebeln space.
      WHEN 'MATNR'.
        PERFORM goto_doc USING 'MAT' <ls_item>-matnr space.
      WHEN 'VBELN_PO'.
        PERFORM goto_doc USING 'SO' <ls_item>-vbeln_po space.
      WHEN 'VBELN_GR'.
        PERFORM goto_doc USING 'SO' <ls_item>-vbeln_gr space.
    ENDCASE.
  ENDMETHOD.

  METHOD on_link_det.
    READ TABLE gt_det ASSIGNING FIELD-SYMBOL(<ls_det>) INDEX row.
    CHECK sy-subrc = 0.
    CASE column.
      WHEN 'EBELN'.
        PERFORM goto_doc USING 'PO' <ls_det>-ebeln space.
      WHEN 'MATNR'.
        PERFORM goto_doc USING 'MAT' <ls_det>-matnr space.
      WHEN 'VBELN_PO'.
        PERFORM goto_doc USING 'SO' <ls_det>-vbeln_po space.
      WHEN 'VBELN_GR'.
        PERFORM goto_doc USING 'SO' <ls_det>-vbeln_gr space.
      WHEN 'MBLNR'.
        PERFORM goto_doc USING 'MIGO' <ls_det>-mblnr <ls_det>-mjahr.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
