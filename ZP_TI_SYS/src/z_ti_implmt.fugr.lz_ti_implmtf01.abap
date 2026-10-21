*----------------------------------------------------------------------*
***INCLUDE LZ_TI_IMPLMTF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_f4_for_tdobt_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_f4_for_tdobt_dynpro .
*>
  DATA : BEGIN OF it_value OCCURS 0,
         tdobject    LIKE ttxit-tdobject,
         tdid        LIKE ttxit-tdid,
         tdtext      LIKE ttxit-tdtext,
         tdspras     LIKE ttxit-tdspras,
         END OF it_value.

  DATA:  l_tdobject  LIKE ttxit-tdobject,
         l_mode(2)   TYPE c.

  CLEAR   : selectfield, it_fields, select_value, ld_tabix.
  REFRESH : it_fields.

* search help table 구조
  PERFORM  insert_fld_tab USING: 'TTXIT' 'TDOBJECT' 'X',
                                 'TTXIT' 'TDID'     'X',
                                 'TTXIT' 'TDTEXT'   ' ',
                                 'TTXIT' 'TDSPRAS'  ' '.
* 항목 구분
  GET CURSOR FIELD g_field LINE g_stepl.

  LOOP AT SCREEN.
    IF screen-name EQ g_field.
      EXIT.
    ENDIF.
  ENDLOOP.

* search help view 추출
  CASE g_field.
    WHEN 'ZTIVIGT1-TDOBF' OR
         'ZTIVIGT1-TDIDF'.
      l_tdobject = 'EKKO'.
      l_mode     = 'PO'.
    WHEN 'ZTIVIGT1-TDOBT' OR
         'ZTIVIGT1-TDIDT'.
      l_tdobject = 'ZTIRQHD'.
      l_mode     = 'LC'.
    WHEN OTHERS.
      CLEAR: l_tdobject.
  ENDCASE.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE it_value
           FROM  ttxit
           WHERE tdobject  EQ l_tdobject
             AND tdspras   EQ sy-langu.
  IF sy-subrc NE 0.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE it_value
             FROM  ttxit
             WHERE tdobject  EQ l_tdobject.
  ENDIF.

* search help call
  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = selectfield
    IMPORTING
      ind                          = ld_tabix
      select_value                 = select_value
    TABLES
      fields                       = it_fields
      full_table                   = it_value
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

* 결과값 화면 반영
  CHECK NOT ld_tabix IS INITIAL.
  READ TABLE it_value INDEX ld_tabix.

  IF screen-input EQ '1'.
    PERFORM  update_screen_field USING it_value-tdobject
                                       it_value-tdid
                                       g_stepl
                                       l_mode.
  ENDIF.

endform.                    " get_f4_for_tdobt_dynpro
*&---------------------------------------------------------------------*
*&      Form  update_screen_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM update_screen_field  USING    p_tdobject
                                   p_tdid
                                   p_stepl
                                   p_mode.
  REFRESH:scr_fields.

  CASE p_mode.
    WHEN 'PO'.
      ztIvigt1-tdobf         = p_tdobject.
      ztIvigt1-tdidf         = p_tdid.
      scr_fields-fieldname   = 'ZTIVIGT1-TDOBF'.
      scr_fields-stepl       = p_stepl.
      scr_fields-fieldvalue  = p_tdobject.
      APPEND scr_fields.
      scr_fields-fieldname   = 'ZTIVIGT1-TDIDF'.
      scr_fields-fieldvalue  = p_tdid.
      scr_fields-stepl       = p_stepl.
      APPEND scr_fields.
    WHEN 'LC'.
      ztIvigt1-tdobt         = p_tdobject.
      ztIvigt1-tdidt         = p_tdid.
      scr_fields-fieldname   = 'ZTIVIGT1-TDOBT'.
      scr_fields-stepl       = p_stepl.
      scr_fields-fieldvalue  = p_tdobject.
      APPEND scr_fields.
      scr_fields-fieldname   = 'ZTIVIGT1-TDIDT'.
      scr_fields-fieldvalue  = p_tdid.
      scr_fields-stepl       = p_stepl.
      APPEND scr_fields.

  ENDCASE.

* 화면필드값을 주어진 값으로 변경함
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = scr_fields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.

ENDFORM.                    " update_screen_field
*&---------------------------------------------------------------------*
*&      Form  insert_fld_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM insert_fld_tab  USING p_tabname
                           p_fieldname
                           p_selectflag.

  CLEAR it_fields.
  MOVE: p_tabname    TO it_fields-tabname,
        p_fieldname  TO it_fields-fieldname,
        p_selectflag TO it_fields-selectflag.
  APPEND it_fields.

ENDFORM.                    " insert_fld_tab
*&---------------------------------------------------------------------*
*&      Form  get_f4_for_zterm_DYNPRO
*&---------------------------------------------------------------------*
 FORM get_f4_for_zterm_dynpro  USING    p_zterm LIKE t052-zterm.

   IF screen-input EQ '1'.
     CALL FUNCTION 'FI_F4_ZTERM'
       EXPORTING
         i_koart       = 'K'
         i_zterm       = p_zterm
         i_xshow       = ' '
       IMPORTING
         e_zterm       = t052-zterm
       EXCEPTIONS
         nothing_found = 01.
   ELSE.
     CALL FUNCTION 'FI_F4_ZTERM'
       EXPORTING
         i_koart       = 'K'
         i_zterm       = p_zterm
         i_xshow       = 'X'
       IMPORTING
         e_zterm       = t052-zterm
       EXCEPTIONS
         nothing_found = 01.
   ENDIF.

   IF sy-subrc NE 0.
     MESSAGE s177(06) WITH p_zterm.
     EXIT.
   ENDIF.

   IF t052-zterm NE space.
     p_zterm = t052-zterm.
   ENDIF.

 ENDFORM.                    " get_f4_for_zterm_DYNPRO
