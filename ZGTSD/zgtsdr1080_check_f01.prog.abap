*&---------------------------------------------------------------------*
*& Include          ZGTSDR1080_CHECK_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .


  SELECT
    lips~vbeln
    lips~posnr
    lips~ormng AS lfimg
    lips~vgbel
    lips~vgpos

   INTO CORRESPONDING FIELDS OF TABLE GT_dATA
    FROM likp AS likp
    INNER JOIN lips AS lips
      ON likp~vbeln EQ lips~vbeln
    WHERE likp~vstel = '3450'
    AND likp~wadat_ist IN s_wadat
    AND lips~bwart = '687'
    AND lips~vtweg = '10'
    AND lips~spart = '60'
    AND lips~vbeln IN s_vbeln
    AND likp~kunag IN s_kunnr
    AND lips~vkgrp IN s_vkgrp
    AND lips~uecha = ' '.

  CHECK gt_data[] IS NOT INITIAL.

  r_XBLNR[] = VALUE #( FOR ls_tmp IN GT_dATA
                       ( sign = 'I'
                         option = 'EQ'
                         low = ls_tmp-vbeln
                         high = '' ) ).
  SORT r_xblnr.
  DELETE ADJACENT DUPLICATES FROM r_xblnr COMPARING ALL FIELDS.


  SELECT
    mat~mblnr AS mblnr
    mat~mjahr AS mjahr
    mat~zeile AS zeile
    mat~sjahr AS sjahr
    mat~smbln AS smbln
    mat~bwart AS bwart
    mat~vbeln_im AS mat_kdauf
*  VBELP_IM AS MAT_KDPOS
    mat~menge AS menge
    lips~posnr AS posnr
    lips~uecha AS uecha
    mat~shkzg AS shkzg
    INTO CORRESPONDING FIELDS OF TABLE gt_zmseg
    FROM matdoc AS mat
    INNER JOIN lips AS lips
     ON mat~vbeln_im EQ lips~vbeln
    AND mat~vbelp_im EQ lips~posnr
    WHERE xblnr IN r_xblnr
    AND budat IN s_fkdat.

  lt_zmseg[] = VALUE #( FOR ls_tmp2 IN gt_zmseg
                       ( sjahr = ls_tmp2-sjahr
                         smbln = ls_tmp2-smbln ) ).
  SORT lt_zmseg BY sjahr smbln.
  DELETE ADJACENT DUPLICATES FROM lt_zmseg COMPARING ALL FIELDS.


*___ 출고정보 가져오기
  SELECT
    * INTO CORRESPONDING FIELDS OF TABLE gt_vbrp
    FROM vbrp AS vbrp
    INNER JOIN vbrk
    ON vbrp~vbeln EQ vbrk~vbeln
    FOR ALL ENTRIES IN gt_data
    WHERE vbrp~vgbel = gt_data-vbeln
    AND   vbrp~vgpos = gt_data-posnr
    AND   vbrk~sfakn = ' '
    AND   vbrk~fksto = ' '
    AND   vbrk~fkdat IN s_fkdat.

*___ 출고정보 SUM
  LOOP AT Gt_zmseg.

    READ TABLE lt_zmseg WITH KEY sjahr = gt_zmseg-mjahr smbln = gt_zmseg-mblnr BINARY SEARCH.
    IF sy-subrc = 0.
      DELETE gt_zmseg. CLEAR : gt_zmseg. " 삭제된놈 취소
    ELSEIF gt_zmseg-sjahr <> ' '.
      DELETE gt_zmseg. CLEAR : gt_zmseg. " 삭제된놈 취소
    ELSEIF gt_zmseg-bwart = '687' AND gt_zmseg-shkzg = 'S'.
      DELETE gt_zmseg. CLEAR : gt_zmseg. " 삭제된놈 취소
    ELSE.
      MOVE-CORRESPONDING gt_zmseg TO gt_SUM.
      IF gt_zmseg-uecha IS NOT INITIAL.
        gt_sum-mat_kdpos = gt_zmseg-uecha.
      ELSE.
        gt_sum-mat_kdpos = gt_zmseg-posnr.
      ENDIF.
      IF gt_ZMSEG-bwart = '601'.
        gt_SUM-601 = gt_zmseg-menge.
      ELSEIF gt_ZMSEG-bwart = '687'.
        gt_SUM-687 = gt_zmseg-menge.
      ELSE.
        gt_SUM-etc = gt_zmseg-menge.
      ENDIF.
      COLLECT gt_SUM . CLEAR : gt_SUM.
    ENDIF.
  ENDLOOP.

*___ 판매정보 SUM
  LOOP AT gt_vbrp.
    gt_SUM-mat_kdauf = gt_vbrp-vgbel.
    gt_SUM-mat_kdpos = gt_vbrp-vgpos.
    gt_sum-fkimg = gt_vbrp-fkimg.

    COLLECT gt_sum. CLEAR  :gt_sum.
  ENDLOOP.

*___납품문서별 정보 입력
  SORT gt_sum BY mat_kdauf mat_kdpos.
  LOOP AT gt_data .
    READ TABLE gt_sum WITH KEY mat_kdauf = gt_data-vbeln
                               mat_kdpos = gt_data-posnr
                               BINARY SEARCH.
    CHECK sy-subrc = 0 .

    MOVE-CORRESPONDING gt_sum TO gt_data.
    gt_data-lfimg601 = gt_sum-601.
    gt_data-lfimg687 = gt_sum-687.

    MODIFY gt_data.  CLEAR : gt_data.
  ENDLOOP.

*___ 차이수량 계산
  LOOP AT gt_data .
    gt_data-gap1 = gt_data-lfimg601 - gt_data-fkimg. " 출고는 했지만 매출처리 안됨
    gt_data-gap2 = gt_data-fkimg - gt_data-lfimg601. " 매출은 되었지만 출고안됨.
    IF gt_data-gap1 < 0 .
      gt_data-gap1 = 0.
    ENDIF.
    IF gt_data-gap2 < 0 .
      gt_data-gap2 = 0.
    ENDIF.
    MODIFY gt_data.  CLEAR : gt_data.
  ENDLOOP.

   IF NOT ( SY-UNAME = 'ZLSGSD6' AND SY-TCODE = 'ZGTSDR1080_CHECK' ).
       DELETE gt_data WHERE gap1 = 0 AND gap2 = 0.
   ENDIF.

*___ 기타정보 가져오기
  LOOP AT gt_data.
    SELECT SINGLE vgbel vgpos matnr
      INTO (gt_data-vgbel, gt_data-vgpos, gt_data-matnr)
      FROM lips
      WHERE vbeln = gt_data-vbeln
      AND   posnr = gt_data-posnr.

    SELECT SINGLE kunnr
      INTO GT_dATA-kunnr
      FROM vbak
      WHERE vbeln = gt_data-vgbel.

    SELECT SINGLE kdkg4
      INTO GT_dATA-kdkg4
      FROM vbkd
      WHERE vbeln = GT_dATA-vgbel.

    MODIFY gt_data . CLEAR : GT_dATA.
  ENDLOOP.

  IF s_kdkg4[] IS NOT INITIAL.
    DELETE gt_data WHERE kdkg4 NOT IN s_kdkg4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_WRITE_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv_write_rtn .

** ALV 출력을 위한 HEADER및 FIELD SETTING
  PERFORM  alvprn_basic.
  PERFORM  alvprn_header.
  PERFORM  alvprn_field.

** ALV DISPLAY
  PERFORM  alv_display.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALVPRN_BASIC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alvprn_basic .


  CLEAR:   g_events_t, g_layout_s.
  REFRESH: g_events_t.

** Default SETTING
  g_layout_s-detail_popup      = 'X'.
* g_layout_s-no_totalline      = 'X'.    " 합계필드의 사용여부
  g_layout_s-zebra             = 'X'.
* G_LAYOUT_S-CELL_MERGE        = 'X'.
  g_layout_s-colwidth_optimize = 'X'.

** FORM문 발췌함수
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = g_events_t.

** FORM문   생성
  PERFORM form_setting  TABLES g_events_t
                         USING : slis_ev_pf_status_set  c_status_set,
                                 slis_ev_user_command   c_user_command,
                                 slis_ev_top_of_page    c_top_of_page.
  " Grapic Display

** PROGRAM  ID
  g_program = sy-repid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALVPRN_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alvprn_header .


  DATA : l_data1(100),
         l_data2(100),
         l_data3(100),
         l_data4(100),
         l_data5(100),
         l_kunnr LIKE kna1-kunnr.

  REFRESH g_list_top_of_page_t.


*  CONCATENATE  G_ITAB_T-VKBUR '(' G_ITAB_T-TEXT02 ')'
*         INTO  L_DATA1.
*
*  CONCATENATE  G_ITAB_T-VKGRP '(' G_ITAB_T-TEXT03 ')'
*         INTO  L_DATA2.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*    EXPORTING
*      INPUT  = G_ITAB_T-KUNNR
*    IMPORTING
*      OUTPUT = L_KUNNR.
*
*  CONCATENATE  L_KUNNR '(' G_ITAB_T-NAME1 ')'
*         INTO  L_DATA3.

  PERFORM header_setting TABLES g_list_top_of_page_t
                          USING: 'S'  '출고-빌링  : ' '출고후 빌링 미처리 수량',
                                 'S'  '빌링-출고  : ' '빌링은 되었으나 미출고 수량'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALVPRN_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alvprn_field .

  REFRESH: g_field_t, g_fieldcat_t.

* FIELD발췌
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = g_program
      i_internal_tabname     = 'GT_DATA'
      i_client_never_display = 'X'
      i_inclname             = 'ZGTSDR1080_CHECK_TOP'
      i_bypassing_buffer     = 'X'
      i_buffer_active        = 'X'
    CHANGING
      ct_fieldcat            = g_field_t[].

  PERFORM field_setting TABLES g_fieldcat_t
    USING
  :

      'S' 'KUNNR'   ' ',
      ' ' 'SELTEXT_L'   '고객코드',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'COL_POS'     '1',
      'E' 'KEY'         'X',

      'S' 'VGBEL'   ' ',
      ' ' 'SELTEXT_L'   '판매오더',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'COL_POS'     '2',
      'E' 'KEY'         'X',

      'S' 'VGPOS'   ' ',
      ' ' 'SELTEXT_L'   '품목',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '6',
      ' ' 'COL_POS'     '3',
      'E' 'KEY'         'X',

      'S' 'VBELN'   ' ',
      ' ' 'SELTEXT_L'   '납품번호',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '10',
      ' ' 'COL_POS'     '4',
      'E' 'KEY'         'X',

      'S' 'POSNR'   ' ',
      ' ' 'SELTEXT_L'   '품목',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '6',
      ' ' 'COL_POS'     '5',
      'E' 'KEY'         'X',


      'S' 'MATNR'   ' ',
      ' ' 'SELTEXT_L'   '자재코드',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '18',
      'E' 'COL_POS'     '6',


      'S' 'LFIMG'   ' ',
      ' ' 'SELTEXT_L'   '납품수량',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '13',
      'E' 'COL_POS'     '7',

      'S' 'LFIMG601'   ' ',
      ' ' 'SELTEXT_L'   '출고수량(LFIMG601)',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '13',
      'E' 'COL_POS'     '8',

      'S' 'LFIMG687'   ' ',
      ' ' 'SELTEXT_L'   '출고수량(LFIMG687)',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '13',
      'E' 'COL_POS'     '9',

      'S' 'ETC'   ' ',
      ' ' 'SELTEXT_L'   '기타출고',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '13',
      'E' 'COL_POS'     '10',

      'S' 'FKIMG'   ' ',
      ' ' 'SELTEXT_L'   '청구수량',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '13',
      'E' 'COL_POS'     '11',

      'S' 'GAP1'   ' ',
      ' ' 'SELTEXT_L'   '출고-빌링',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '13',
      'E' 'COL_POS'     '12',

      'S' 'GAP2'   ' ',
      ' ' 'SELTEXT_L'   '빌링-출고',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '13',
      'E' 'COL_POS'     '13',

      'S' 'KDKG4'   ' ',
      ' ' 'SELTEXT_L'   '수출구분',
      ' ' 'DDICTXT'     'L',
      ' ' 'OUTPUTLEN'   '8',
      'E' 'COL_POS'     '14'.

ENDFORM.

FORM alv_display.

  g_save  =  'A'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
* call function 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = g_program
      is_layout               = g_layout_s
      i_save                  = g_save
      is_variant              = g_variant_s
      it_events               = g_events_t[]
      it_fieldcat             = g_fieldcat_t[]
*     it_fieldcat             = g_field_t[]
    IMPORTING
      e_exit_caused_by_caller = g_exit_caused_by_caller
      es_exit_caused_by_user  = g_exit_caused_by_user_s
    TABLES
      t_outtab                = GT_dATA.

ENDFORM.

FORM top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      i_logo             = ' '
      it_list_commentary = g_list_top_of_page_t.

ENDFORM.

FORM  user_command USING p_ucomm    LIKE sy-ucomm
                         p_selfield TYPE slis_selfield.

  CASE p_ucomm.

    WHEN '&IC1'.

      CASE p_selfield-sel_tab_field.

        WHEN 'GT_DATA-VGBEL'.
          READ TABLE gt_data INDEX p_selfield-tabindex.
          PERFORM  call_va03  USING  gt_data-vgbel.

        WHEN 'GT_DATA-VBELN'.
          READ TABLE gt_data INDEX p_selfield-tabindex.
          PERFORM  call_vbeln  USING  gt_data-vbeln.
      ENDCASE.


    WHEN  'BACK' OR 'EXIT' OR 'CANC'.
      SET SCREEN 0.
      LEAVE SCREEN.

  ENDCASE.

ENDFORM.
FORM call_va03  USING    p_value.

  CHECK NOT p_value IS INITIAL.

* PARAMETER SETTING
  SET PARAMETER ID: 'AUN'    FIELD   p_value.

* CALL TRANSACTION
  CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
  COMMIT WORK AND WAIT.

ENDFORM.
FORM call_vbeln  USING    pv_vbeln.

  SELECT SINGLE mandt INTO sy-mandt
    FROM vbrk
   WHERE vbeln = pv_vbeln.
  IF sy-subrc = 0.
    SET PARAMETER ID: 'VF'    FIELD   pv_vbeln.
    CALL TRANSACTION  'VF03' AND SKIP FIRST SCREEN.
    COMMIT WORK AND WAIT.
    EXIT.
  ENDIF.

  SELECT SINGLE mandt INTO sy-mandt
    FROM likp
   WHERE vbeln = pv_vbeln.
  IF sy-subrc = 0.
    SET PARAMETER ID: 'VL'    FIELD   pv_vbeln.
    CALL TRANSACTION  'VL03N' AND SKIP FIRST SCREEN.
    EXIT.
  ENDIF.

  SELECT SINGLE mandt INTO sy-mandt
    FROM vbak
   WHERE vbeln = pv_vbeln.
  IF sy-subrc = 0.
    SET PARAMETER ID: 'AUN'    FIELD   pv_vbeln.
    CALL TRANSACTION  'VA03' AND SKIP FIRST SCREEN.
    EXIT.
  ENDIF.

ENDFORM.
