*----------------------------------------------------------------------*
***INCLUDE LZGTPP02I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0222  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0222 INPUT.

  DATA : ls_matnr LIKE zgtpps0001.

  CLEAR : gt_matnr.
  CASE gv_ok_code3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : gv_matnr2.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      IF gv_matnr2 IS INITIAL.
        MESSAGE i003(zgtpp00) DISPLAY LIKE 'E' WITH TEXT-e01.
      ELSE.
        ls_matnr-matnr = gv_matnr2.
        APPEND ls_matnr TO gt_matnr.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_MATNR  INPUT
*&---------------------------------------------------------------------*
MODULE f4_matnr INPUT.

  DATA : BEGIN OF lt_matnr OCCURS 0,
           matnr LIKE marc-matnr,
           maktx LIKE makt-maktx,
         END OF lt_matnr.
  DATA : lt_scr_fields LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH : gt_rtntab, gt_dselc.
  CLEAR : gt_rtntab, gt_dselc.

  gt_dselc-fldname = 'F0001'.
  gt_dselc-dyfldname = 'MATNR'.
  APPEND gt_dselc.

  SELECT a~matnr, b~maktx
      INTO CORRESPONDING FIELDS OF TABLE @lt_matnr
      FROM marc AS a INNER JOIN makt AS b
          ON   a~matnr EQ b~matnr
          AND a~werks EQ @gv_werks
          AND b~spras EQ @sy-langu
          INNER JOIN mara AS c
          ON  a~matnr EQ c~matnr
          WHERE c~matkl EQ @gv_matkl2.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MATNR'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      window_title    = '자재 선택'
      value_org       = 'S'
    TABLES
      value_tab       = lt_matnr
      return_tab      = gt_rtntab
      dynpfld_mapping = gt_dselc
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  CLEAR gt_rtntab.
  READ TABLE gt_rtntab WITH KEY retfield = 'MATNR'.
  IF sy-subrc = 0.
    gv_matnr2 = gt_rtntab-fieldval.
  ENDIF.
* 아래 부분이 선택된 값들을 화면 필드에 뿌려준다.
  lt_scr_fields-fieldname  = 'GV_MATNR2'.
  lt_scr_fields-fieldvalue = gv_matnr2.
  APPEND lt_scr_fields.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = lt_scr_fields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMODULE.
