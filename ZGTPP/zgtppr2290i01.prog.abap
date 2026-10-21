*&---------------------------------------------------------------------*
*& Include          ZGTPPR2290I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD go_docking_container->free.
      CLEAR : go_docking_container, go_grid_0100, go_grid_0101.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.

    WHEN 'REFRESH'.
      IF go_grid_0101 IS BOUND.
        go_grid_0101->free( ).
        FREE : go_grid_0101, go_contain_0101.
      ENDIF.

      PERFORM get_proc.
      PERFORM refresh_grid USING go_grid_0100.

    WHEN 'RELEASE'. "생산 오더 릴리즈
      PERFORM process_release_order.

    WHEN 'CHANGE'. "생산 오더 수정
      PERFORM process_change_order_co02.

    WHEN 'CHG_STDAT' OR 'CHG_EDDAT'. "// 일정변경
      PERFORM change_prod_order_schedule USING gv_ok_code.

    WHEN 'DELETE'. "생산 오더 삭제
      PERFORM process_delete_order.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0220  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0220 INPUT.

  CASE gv_ok_code2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'NO'.
      CALL METHOD go_contain_0220->free.
      FREE : go_contain_0220, go_grid_0220.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
    WHEN 'YES'.
      PERFORM input_alternative_material.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0222  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0222 INPUT.

  CASE gv_ok_code3.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : gv_matnr2.
      LEAVE TO SCREEN 0.
    WHEN 'CONFIRM'.
      IF gv_matnr2 IS INITIAL.
        MESSAGE i003 DISPLAY LIKE 'E' WITH TEXT-e11.
      ELSE.
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
          AND a~werks EQ @p_werks
          AND b~spras EQ @sy-langu
          INNER JOIN mara AS c
          ON  a~matnr EQ c~matnr
          WHERE c~matkl EQ @gv_matkl2.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MATNR'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      window_title    = TEXT-034 "자재 선택
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
  lt_scr_fields-fieldname  = 'GV_MATNR'.
  lt_scr_fields-fieldvalue = gv_matnr.
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
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  CASE gv_ok_code4.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : gv_s_day, gv_e_day.
      LEAVE TO SCREEN 0.
    WHEN 'INPUT'.
      IF gv_s_day IS INITIAL OR gv_e_day IS INITIAL.
        MESSAGE i003 DISPLAY LIKE 'E' WITH TEXT-e13.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0301  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0301 INPUT.

  CASE gv_ok_code5.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR : gv_s_day, gv_e_day.
      LEAVE TO SCREEN 0.
    WHEN 'ENTR'.
      IF gv_menge IS NOT INITIAL AND
        ( gs_disp-gamng < gv_menge ).
        MESSAGE i005 DISPLAY LIKE 'E' WITH TEXT-e28 gs_disp-gamng.
      ENDIF.
    WHEN 'INPUT'.
      IF gv_s_day IS INITIAL OR gv_e_day IS INITIAL.
        MESSAGE i003 DISPLAY LIKE 'E' WITH TEXT-e13.
      ELSEIF gv_matnr4 IS INITIAL.
        MESSAGE i003 DISPLAY LIKE 'E' WITH TEXT-e19.
*- Start 2025.06.02
      ELSEIF gv_menge IS INITIAL.
        MESSAGE i003 DISPLAY LIKE 'E' WITH TEXT-e27.
      ELSEIF gv_menge IS NOT INITIAL AND
        ( gs_disp-gamng < gv_menge ).
        MESSAGE i005 DISPLAY LIKE 'E' WITH TEXT-e28 gs_disp-gamng.
*- End 2025.06.02
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_MATNR2  INPUT
*&---------------------------------------------------------------------*
MODULE f4_matnr2 INPUT.

  DATA : BEGIN OF lt_matnr2 OCCURS 0,
           pdcaproccode TYPE zgtepdcaproccode, " LIKE zgtcvmstval-pdcaproccode, "공정
           pdcaprocname TYPE zgtepdcaprocname, "LIKE zgtcvmstval-pdcaprocname, "공정명
           matnr        LIKE zgtcvmstval-matnr,
           maktx        LIKE zgtcvmstval-maktx,
         END OF lt_matnr2.
  DATA : lt_zgtcvmstval LIKE zgtcvmstval OCCURS 0 WITH HEADER LINE.
* Origin 오더(정상 원래 오더)의 생산 자재 BOM 확인
  REFRESH : gt_rtntab, gt_dselc, gt_stb, gt_cscmat, gt_matnr4, lt_matnr2.
  CLEAR : gt_rtntab, gt_dselc, gt_matnr4, gs_topmat, gs_cscmat, lt_matnr2.
  READ TABLE gt_matnr3 INDEX 1.
  IF gt_matnr3-matnr IS NOT INITIAL.
* BOM 하위전개
    CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
      EXPORTING
        aumgb                 = abap_on
        capid                 = 'PP01'
        datuv                 = sy-datum
        ehndl                 = '1'
        mktls                 = abap_on
        mehrs                 = abap_on
        mmory                 = '1'
        mtnrv                 = gt_matnr3-matnr
        werks                 = p_werks
      IMPORTING
        topmat                = gs_topmat
      TABLES
        stb                   = gt_stb
        matcat                = gt_cscmat
      EXCEPTIONS
        alt_not_found         = 1
        call_invalid          = 2
        material_not_found    = 3
        missing_authorization = 4
        no_bom_found          = 5
        no_plant_data         = 6
        no_suitable_bom_found = 7
        conversion_error      = 8
        OTHERS                = 9.
* 정산 원 오더 생산 자재(Index=1)를 제외한 생산 하위 반제품 확인(생산 버전 1000)
    CLEAR : gt_matnr4, gt_matnr4[].
    LOOP AT gt_cscmat INTO gs_cscmat WHERE verid = '1000'
                                                                     AND index NE '1'.
      gt_matnr4-matnr = gs_cscmat-matnr.
      APPEND gt_matnr4.
    ENDLOOP.

    SORT gt_matnr4 BY matnr.
    DELETE ADJACENT DUPLICATES FROM gt_matnr4 COMPARING matnr.

    IF gt_matnr4[] IS INITIAL.

      MESSAGE i003 DISPLAY LIKE 'E' WITH TEXT-e22.

    ELSE.

      SELECT pdcaproccode, pdcaprocname, pdcasegmentno, matnr, maktx
        INTO CORRESPONDING FIELDS OF TABLE @lt_zgtcvmstval
        FROM zgtcvmstval
         FOR ALL ENTRIES IN @gt_matnr4
       WHERE werks EQ @p_werks
         AND matnr EQ @gt_matnr4-matnr.

      LOOP AT lt_zgtcvmstval.
* 연선이면서 1Core 자재는 타 공정에서 탈피 되지 않으므로 제외
*        IF lt_zgtcvmstval-pdcaproccode EQ 'CST' AND
*           lt_zgtcvmstval-pdcasegmentno EQ '1'.
*          CONTINUE.
*        ELSE.
        MOVE-CORRESPONDING lt_zgtcvmstval TO lt_matnr2.
        APPEND lt_matnr2.
*        ENDIF.

      ENDLOOP.

      gt_dselc-fldname = 'F0003'.
      gt_dselc-dyfldname = 'MATNR'.
      APPEND gt_dselc.

      gt_dselc-fldname = 'F0004'.
      gt_dselc-dyfldname = 'MAKTX'.
      APPEND gt_dselc.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = 'MATNR'
          dynpprog        = sy-cprog
          dynpnr          = sy-dynnr
          window_title    = TEXT-035 "탈피 자재 선택
          value_org       = 'S'
        TABLES
          value_tab       = lt_matnr2
          return_tab      = gt_rtntab
          dynpfld_mapping = gt_dselc
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.

      CLEAR gt_rtntab.
      READ TABLE gt_rtntab WITH KEY retfield = 'MATNR'.
      IF sy-subrc = 0.
        gv_matnr4 = gt_rtntab-fieldval.
      ENDIF.

      CLEAR gt_rtntab.
      READ TABLE gt_rtntab WITH KEY retfield = 'MAKTX'.
      IF sy-subrc = 0.
        gv_maktx4 = gt_rtntab-fieldval.
      ENDIF.
* 아래 부분이 선택된 값들을 화면 필드에 뿌려준다.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input  = gv_matnr4
        IMPORTING
          output = gv_matnr4.
      lt_scr_fields-fieldname  = 'GV_MATNR4'.
      lt_scr_fields-fieldvalue = gv_matnr4.
      APPEND lt_scr_fields.

      lt_scr_fields-fieldname  = 'GV_MAKTX4'.
      lt_scr_fields-fieldvalue = gv_maktx4.
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

    ENDIF.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0400 INPUT.

  CASE gv_ok_code6.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'NO'.
      gv_stop = 'X'.
      CALL METHOD go_contain_0400->free.
      FREE : go_contain_0400, go_grid_0400.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
    WHEN 'YES'.
      PERFORM input_bom_data.
      CALL METHOD go_contain_0400->free.
      FREE : go_contain_0400, go_grid_0400.
      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0500 INPUT.

  CASE gv_ok_code.
    WHEN 'CANCEL'      .     "// CANCEL.
      PERFORM user_command_cancel.

    WHEN 'APPLY'.            "// APPLY.
      PERFORM user_command_apply.
  ENDCASE.

  CLEAR gv_ok_code.

ENDMODULE.
