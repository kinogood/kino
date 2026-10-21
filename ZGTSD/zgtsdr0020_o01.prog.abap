*----------------------------------------------------------------------*
***INCLUDE ZLER0012BO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  pbo  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo OUTPUT.

  DATA: s_func(20) OCCURS 0 WITH HEADER LINE.

  IF r01 = 'X' .
    s_func = 'REVERSE'.
    APPEND s_func.
    SET TITLEBAR 'R01'.
  ENDIF.

  IF r02 = 'X' .
    s_func = 'REVERSE'.
    APPEND s_func.
    SET TITLEBAR 'R02'.
  ENDIF.

  IF r03 = 'X'.
    s_func = 'PREVIEW'.
    APPEND s_func.
    s_func = 'PRINT'.
    APPEND s_func.

    SET TITLEBAR 'R03'.
  ENDIF.

  SET PF-STATUS '200' EXCLUDING s_func.


  PERFORM create_init_control.

ENDMODULE.                 " pbo  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  create_init_control
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_init_control .

  DATA : l_offline           TYPE char1.
  CALL METHOD cl_gui_alv_grid=>offline
    RECEIVING
      e_offline = l_offline.

  IF gc_custom_cont IS INITIAL.
    PERFORM create_alv USING l_offline.
  ENDIF.

ENDFORM.                    " create_init_control

*&--------------------------------------------------------------------*
*&      Form  CREATE_ALV
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM create_alv USING l_offline TYPE c.

  IF l_offline EQ 0.
    CREATE OBJECT gc_custom_cont
      EXPORTING
        container_name = gc_container.
  ENDIF.

* create an instance of alv control
  CREATE OBJECT gc_alv_grid
    EXPORTING
      i_parent = gc_custom_cont.
*                  i_appl_events = 'X'.


  PERFORM set_layo.
  PERFORM set_variant.
  PERFORM set_fcat.
  PERFORM set_sort.
  PERFORM set_table_for_first_display.
  PERFORM set_handler.

ENDFORM.                    "CREATE_ALV

*&--------------------------------------------------------------------*
*&      Form  set_LAYO
*&--------------------------------------------------------------------*
*       Layout 만들기
*---------------------------------------------------------------------*
FORM set_layo.

*  gs_layout-smalltitle = 'X'.
*  gs_layout-stylefname = 'CELLTAB'.
  gs_layout-cwidth_opt  = 'X'.
*  gs_layout-totals_bef  = 'X'.
  gs_layout-zebra       = 'X'.
ENDFORM.                    "set__LAYO

*&--------------------------------------------------------------------*
*&      Form  set_variant
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM set_variant.

*   기본 Variant 가져오기
  CLEAR spec_layout.
  MOVE sy-repid TO spec_layout-report.
  CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = x_save
    CHANGING
      cs_variant = spec_layout
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.

  ELSE.
    gs_variant = spec_layout-variant.
  ENDIF.

  IF gs_variant IS INITIAL.
    gs_variant-report = sy-repid.
  ELSE.
    MOVE-CORRESPONDING spec_layout TO gs_variant.
  ENDIF.

ENDFORM.                    "set__variant

*&--------------------------------------------------------------------*
*&      Form  set_FCAT
*&--------------------------------------------------------------------*
*       Field Catalog 만들기
*---------------------------------------------------------------------*
FORM set_fcat.

  PERFORM set_fcats TABLES gt_fieldcat
                          USING 'GT_QLIST'.

  PERFORM change_fcat.

ENDFORM.                    "set_FCAT

*&--------------------------------------------------------------------*
*&      Form  set_FCATS
*&--------------------------------------------------------------------*
*       필드 카다로그 읽어오기
*---------------------------------------------------------------------*
FORM set_fcats TABLES gt_fieldcat STRUCTURE lvc_s_fcat
                     USING lv_table_name.

  CALL FUNCTION 'Z_CO_FIELDCATALOG_MERGE'
    EXPORTING
      i_program              = sy-cprog
      i_table                = lv_table_name
*     I_STRUCTURE            =
    CHANGING
      gt_fieldcat            = gt_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

ENDFORM.                    "set_FCAT

*&--------------------------------------------------------------------*
*&      Form  CHANGE_FCAT
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM change_fcat.

*/ 신규발행일때, 거래명세서 번호 INACTIVE
*    IF r01 = 'X'.
*       'GT_LIST-IV_NO'.
*    ENDIF.

*/ 납품문서 기준일때,
*  선적번호, 차량번호 INACTIVE
*    IF r_vbeln = 'X'.
*       'GT_LIST-TKNUM'
*       'GT_LIST-EXTI1'
*    ENDIF.

  LOOP AT gt_fieldcat.
    CASE gt_fieldcat-fieldname.

      WHEN 'ICON'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '선택'.
        gt_fieldcat-just = 'C'.

      WHEN 'CHK'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'IV_NO'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '거래명세번호'.

        IF r01 = 'X'.
          gt_fieldcat-no_out = 'X'.
        ENDIF.

      WHEN 'TKNUM'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '선적번호'.

        IF r_vbeln = 'X'.
          gt_fieldcat-no_out = 'X'.
        ENDIF.

      WHEN 'KUNNR'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '납품처'.

      WHEN 'KUNAG'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '판매처'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'KUNAG_T'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '판매처명'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'VBELN'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '납품번호'.

      WHEN 'KUNNR_T'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '납품처명'.

      WHEN 'WADAT_IST'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '출고일자'.

      WHEN 'MATNR'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '자재'.

      WHEN 'ARKTX'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '자재내역'.

      WHEN 'LFIMG'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '납품수량'.

      WHEN 'VRKME'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '단위'.

      WHEN 'EXTI1'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '차량번호'.

        IF r_vbeln = 'X'.
          gt_fieldcat-no_out = 'X'.
        ENDIF.

      WHEN 'WIRE'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '상'.
      WHEN 'GND'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '접지구분'.
      WHEN 'AMP'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '전류세기'.
      WHEN 'COND'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '도체재질'.
      WHEN 'DUCT'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '덕트재질'.
      WHEN 'IPDEG'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = 'IP등급'.
      WHEN 'PRDID'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '제품군'.
      WHEN 'TRIP'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '트립용량'.

      WHEN 'PROD'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '견적품명'.

      WHEN 'VOLT'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '전압'.

      WHEN 'POLE'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '극수'.

      WHEN 'BREA'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '차단기모델'.

      WHEN 'FRAME'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '프레임용량'.

      WHEN 'VSART'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '출하유형'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'VBTYP'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = 'SD문서범주'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'VSTEL'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '출하지점'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'LFART'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '납품유형'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'VTWEG'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '유통경로'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'POSNR'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '납품품목'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'VGBEL'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '주문번호'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'VGPOS'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '품목'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'WERKS'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '플랜트'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'CHARG'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '배치'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'VRKME'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '단위(납품)'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'MEINS'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '기본단위'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'UMVKZ'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '몫'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'UMVKN'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '나머지'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'UMVKN'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '나머지'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'IV_TYPE'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '통문유형'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'IV_TYPE_NM'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '통문유형명'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'IV_DATE'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '통문증발행일자'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'EXTI2'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '운전자명'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'SDABW'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '운임톤수'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'TDLNR'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '운송사코드'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'TDLNR_T'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '운송사명'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'TPBEZ'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '운기사TEL'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'VKBUR'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '영업팀'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'VKGRP'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '영업그룹'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'LENGTH'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '조장(특성)'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'LENGTH_SO'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '조장'.
        gt_fieldcat-no_out = 'X'.

      WHEN 'GP_FLAG'.
****[START]C20091118_62117**********
****DELETED LINES***************************

*        gt_fieldcat-coltext =
*        gt_fieldcat-seltext = '클래스구분'.
*        gt_fieldcat-no_out = 'X'.
****DELETED LINES***************************
****[END]C20091118_62117**********



****[START]C20091118_62117**********
****CREATED LINES***************************
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '품명그룹구분'.
        gt_fieldcat-no_out = 'X'.
****CREATED LINES***************************
****[END]C20091118_62117**********

      WHEN 'DIFF'.
        gt_fieldcat-coltext =
        gt_fieldcat-seltext = '조장차이'.
        gt_fieldcat-no_out = 'X'.
    ENDCASE.

    MODIFY gt_fieldcat TRANSPORTING no_out seltext coltext just
                        cfieldname do_sum no_zero checkbox edit col_pos.
  ENDLOOP.

ENDFORM.                    "CHANGE_FCAT

*&--------------------------------------------------------------------*
*       Sort 순서 정하기
*---------------------------------------------------------------------*
FORM set_sort.
  CLEAR gt_sort.
  gt_sort-fieldname = 'IV_NO'.
  gt_sort-spos      = '1'.
  APPEND gt_sort. CLEAR gt_sort.
  gt_sort-fieldname = 'TKNUM'.
  gt_sort-spos      = '2'.
  APPEND gt_sort. CLEAR gt_sort.
  gt_sort-fieldname = 'VBELN'.
  gt_sort-spos      = '3'.
  APPEND gt_sort. CLEAR gt_sort.
  gt_sort-fieldname = 'KUNNR'.
  gt_sort-spos      = '4'.
  APPEND gt_sort. CLEAR gt_sort.

ENDFORM.                    "SET_SORT

*&--------------------------------------------------------------------*
*&      Form  set_table_for_first_display
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM set_table_for_first_display.

  CALL METHOD gc_alv_grid->set_table_for_first_display
    EXPORTING
      i_bypassing_buffer = 'X'
      is_layout          = gs_layout
      i_save             = 'A'   " 전체가능유형.
      is_variant         = gs_variant  " 선택 메뉴 display
    CHANGING
      it_fieldcatalog    = gt_fieldcat[]
      it_sort            = gt_sort[]
      it_outtab          = gt_qlist[].

  CALL METHOD gc_alv_grid->m_set_fixed_cols
    EXPORTING
      cols = 6.

ENDFORM.                    "set_table_for_first_display

*&---------------------------------------------------------------------*
*&      Form  set_handler
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_handler .

  CREATE OBJECT gc_event_receiver.
  SET HANDLER gc_event_receiver->handle_double_click FOR gc_alv_grid.

ENDFORM.                    " set_handler
