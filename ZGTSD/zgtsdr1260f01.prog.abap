*&---------------------------------------------------------------------*
*& Include          ZGTSDR1260F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
FORM initialization .

  DATA:lv_dyntxt TYPE smp_dyntxt.

**
* 1) Set Screen Button.
* 고객마스터 영업뷰 업로드 양식 Down
  CLEAR: lv_dyntxt.
  lv_dyntxt = VALUE #( text = |{ icon_xls } { TEXT-002 }|
                       icon_text = TEXT-002
                       quickinfo = TEXT-002 ).
  sscrfields-functxt_01 = lv_dyntxt.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form file_path_dialog
*&---------------------------------------------------------------------*
FORM file_path_dialog  USING    pi_type
                                pi_title
                                pi_fname
                       CHANGING pe_file.

  DATA: lv_rc          TYPE i VALUE 1,
        lt_file        TYPE filetable,
        lv_user_action TYPE i,
        lv_directory   TYPE string,
        lv_title       TYPE string,
        lv_exten       TYPE string,
        lv_filename    TYPE string,
        lv_path        TYPE string,
        lv_fullpath    TYPE string.

**

  CLEAR: lv_title.
  lv_title = pi_title.

  CASE pi_type.
    WHEN 'O'.    " File Open Dialog.

      CLEAR: lv_rc, lv_directory, lv_user_action.
      _clear: lt_file.

      CONCATENATE cl_gui_frontend_services=>filetype_excel
                  cl_gui_frontend_services=>filetype_all
             INTO DATA(lv_filter).

      CALL METHOD cl_gui_frontend_services=>get_desktop_directory
        CHANGING
          desktop_directory = lv_directory.

      CALL METHOD cl_gui_cfw=>update_view.

      CALL METHOD cl_gui_frontend_services=>file_open_dialog
        EXPORTING
          window_title      = lv_title
          file_filter       = lv_filter
          initial_directory = lv_directory
        CHANGING
          file_table        = lt_file
          rc                = lv_rc
          user_action       = lv_user_action.

      IF lt_file[] IS NOT INITIAL.
        pe_file = VALUE #( lt_file[ 1 ]-filename  OPTIONAL ).
      ENDIF.

    WHEN 'S'.    " File Save Dialog.
      CLEAR: lv_filename, lv_path, lv_fullpath, lv_exten.

      lv_exten    = |xlsx|.
      lv_filename = pi_fname.

      CALL METHOD cl_gui_frontend_services=>file_save_dialog
        EXPORTING
          window_title         = lv_title
          default_extension    = lv_exten
          default_file_name    = lv_filename
          file_filter          = 'xlsx'
          prompt_on_overwrite  = abap_true
        CHANGING
          filename             = lv_filename
          path                 = lv_path
          fullpath             = lv_fullpath
          user_action          = lv_user_action
        EXCEPTIONS
          cntl_error           = 1
          error_no_gui         = 2
          not_supported_by_gui = 3
          OTHERS               = 4.

      IF sy-subrc <> 0.
        gv_error = 'X'.
*       프론트엔드 통신중 오류발생
        MESSAGE s162(alvht)  DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      IF lv_user_action = cl_gui_frontend_services=>action_cancel .
        gv_error = 'X'.
*       사용자가 취소했습니다.
        MESSAGE s161(alvht) DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      IF lv_fullpath IS INITIAL.
        gv_error = 'X'.
*       파일명을 확인하세요.
        MESSAGE s000 WITH TEXT-e01  DISPLAY LIKE 'E'.
        EXIT.

      ELSE.

        DATA(lv_len) = strlen( lv_fullpath ).
        IF lv_len > 128.
          gv_error = 'X'.
*         파일 경로가 너무 깁니다. ( 128 이상 ).
          MESSAGE s000 WITH TEXT-e02  DISPLAY LIKE 'E'.
          EXIT.
        ELSE.
          pe_file = lv_fullpath.
        ENDIF.

      ENDIF.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form selection_screen
*&---------------------------------------------------------------------*
FORM selection_screen .

**
  CLEAR: gv_error.
  CASE sy-ucomm.
    WHEN 'FC01'.
      PERFORM download_excel_template.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form download_excel_template
*&---------------------------------------------------------------------*
FORM download_excel_template .

  DATA: lv_path  TYPE rlgrap-filename.

**
  CLEAR: lv_path.
* 고객마스터 영업뷰 업로드 양식 Down
  PERFORM file_path_dialog  USING    'S'
                                     TEXT-t03   " File Save.
                                     TEXT-002   " File name
                            CHANGING lv_path.

  PERFORM download_template_from_smw0  USING  lv_path.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form download_template_from_smw0
*&---------------------------------------------------------------------*
FORM download_template_from_smw0  USING    pi_path.

  DATA: lv_objid       TYPE char40,
        ls_key         TYPE wwwdatatab,
        lv_destination TYPE rlgrap-filename,
        lv_rc          TYPE sy-subrc,
        lv_fullpath    TYPE string.

  CONSTANTS: lc_objid      TYPE wwwdata-objid VALUE 'ZGTSDR1260'.

**
  CHECK: gv_error IS INITIAL,
         pi_path  IS NOT INITIAL.

  CLEAR: lv_objid.
  lv_objid = lc_objid.

  CLEAR: ls_key.
  SELECT SINGLE *
    FROM wwwdata  WHERE objid EQ @lv_objid
    INTO CORRESPONDING FIELDS OF @ls_key.

  ls_key-relid   = 'MI'.
  ls_key-objid   = lv_objid.
  lv_destination = pi_path.

  CLEAR: lv_rc.
  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      key         = ls_key
      destination = lv_destination
    IMPORTING
      rc          = lv_rc
    EXCEPTIONS
      OTHERS      = 1.
  IF sy-subrc IS NOT INITIAL OR
     lv_rc    IS NOT INITIAL.
    gv_error = 'X'.
*   다운로드 중 오류가 발생하였습니다.
    MESSAGE s000 WITH TEXT-e03  DISPLAY LIKE 'E'.

  ELSE.

    CLEAR: lv_fullpath.
    lv_fullpath = pi_path.

    CALL METHOD cl_gui_frontend_services=>execute
      EXPORTING
        document               = lv_fullpath
      EXCEPTIONS
        cntl_error             = 1
        error_no_gui           = 2
        bad_parameter          = 3
        file_not_found         = 4
        path_not_found         = 5
        file_extension_unknown = 6
        error_execute_failed   = 7
        synchronous_failed     = 8
        not_supported_by_gui   = 9
        OTHERS                 = 10.

    IF sy-subrc IS NOT INITIAL.
      gv_error = 'X'.
*     프론트엔드 통신중 오류발생
      MESSAGE s162(alvht)  DISPLAY LIKE 'E'.

    ENDIF.

  ENDIF.

  IF gv_error IS INITIAL.
*   템플릿이 다운로드 되었습니다.
    MESSAGE s000  WITH TEXT-s01.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form start_process
*&---------------------------------------------------------------------*
FORM start_process .

**
  CLEAR: gv_error.

  PERFORM upload_sales_view_data        CHANGING gv_error.

  PERFORM make_display_data             USING    gv_error.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form upload_sales_view_data
*&---------------------------------------------------------------------*
FORM upload_sales_view_data  CHANGING pe_error.

  DATA: lt_excel  TYPE TABLE OF zgtsds1090.

**

* File Path check.
  PERFORM check_before_upload      CHANGING  pe_error.

* Excel Upload.
  PERFORM upload_excel_file        TABLES    lt_excel
                                   CHANGING  pe_error.

* Make Excel upload Tab.
  PERFORM make_excel_upload_tab    TABLES    lt_excel
                                   CHANGING  pe_error.

**
  FREE: lt_excel.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_before_upload
*&---------------------------------------------------------------------*
FORM check_before_upload  CHANGING pe_error.

**
  CHECK: pe_error IS INITIAL.

  IF p_file IS INITIAL.
    pe_error = 'X'.
*   고객마스터 영업뷰 업로드 양식을 지정하시기 바랍니다.
    MESSAGE s000 WITH TEXT-e04  DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form upload_excel_file
*&---------------------------------------------------------------------*
FORM upload_excel_file   TABLES   pt_excel  STRUCTURE zgtsds1090
                         CHANGING pe_error.

  DATA: lo_stru_ref TYPE REF TO cl_abap_structdescr,
        lo_tab_ref  TYPE REF TO cl_abap_tabledescr.
  DATA: lv_end_col TYPE i.

**
  CHECK: pe_error IS INITIAL.

  _clear: pt_excel.

  lo_tab_ref  ?= cl_abap_typedescr=>describe_by_data( gt_excel ).
  lo_stru_ref ?= lo_tab_ref->get_table_line_type( ).
  lv_end_col = lines( lo_stru_ref->components ).

  CALL FUNCTION 'ZGTSD_EXCEL_UPLOAD_2'
    EXPORTING
      filename                = p_file
      i_begin_col             = 1
      i_begin_row             = 4
      i_end_col               = lv_end_col
      i_end_row               = 69999
*     I_SHEETS                =
*     I_SHEETNO               =
    TABLES
      intern                  = pt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    pe_error = 'X'.
*   엑셀 업로드 중 에러가 발생 하였습니다.
    MESSAGE s000 WITH TEXT-e05 DISPLAY LIKE 'E'.
  ELSE.

    IF pt_excel[] IS INITIAL.
      pe_error = 'X'.
*     엑셀 업로드 데이타가 없습니다.
      MESSAGE s000 WITH TEXT-e06 DISPLAY LIKE 'E'.
    ENDIF.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_excel_upload_tab
*&---------------------------------------------------------------------*
FORM make_excel_upload_tab  TABLES   pt_excel  STRUCTURE zgtsds1090
                            CHANGING pe_error.

  DATA: lv_index LIKE sy-tabix.

**
  CHECK: pe_error IS INITIAL.

  SORT pt_excel BY row col.

  _clear: gt_excel.
  TRY.
      LOOP AT pt_excel INTO DATA(ls_excel).

        IF ls_excel IS INITIAL.
          CONTINUE.
        ENDIF.

        MOVE: ls_excel-col TO lv_index.

        ASSIGN COMPONENT lv_index OF STRUCTURE gs_excel TO FIELD-SYMBOL(<fs_val>).
        CHECK sy-subrc EQ 0.

        DESCRIBE FIELD <fs_val> TYPE DATA(lv_type).

        CASE lv_type.
          WHEN 'D'. "DATE
            zgtsd_cl_common=>conv_date_input( CHANGING cv_input = ls_excel-value ).
            <fs_val> = ls_excel-value.

          WHEN 'T'. "TIME
            zgtsd_cl_common=>conv_time_input( CHANGING cv_input = ls_excel-value ).
            <fs_val> = ls_excel-value.

          WHEN 'I'  OR 'P' OR 'N' OR 'b' OR 's'.
*            PERFORM conv_numc_input CHANGING ls_excel-value.
            <fs_val> = ls_excel-value.

          WHEN 'X'. "RAW
            <fs_val> = ls_excel-value.
          WHEN 'g'.
            <fs_val> = ls_excel-value.
          WHEN OTHERS.
            <fs_val> = ls_excel-value.
        ENDCASE.

        AT END OF row.
*         Conversion Alpha.
          gs_excel-kunnr = |{ gs_excel-kunnr ALPHA = IN }|.
          gs_excel-kunn2 = |{ gs_excel-kunn2 ALPHA = IN }|.

          gs_excel-vsbed = |{ gs_excel-vsbed ALPHA = IN }|.  " 출하조건
          gs_excel-ktgrd = |{ gs_excel-ktgrd ALPHA = IN }|.  " 계정지정그룹

          APPEND gs_excel TO gt_excel.
          CLEAR:gs_excel.

        ENDAT.

        IF <fs_val> IS ASSIGNED.
          UNASSIGN <fs_val>.
        ENDIF.

      ENDLOOP.

    CATCH cx_root INTO DATA(lo_ref).

      DATA(lv_msg) = lo_ref->get_text( ).
*     엑셀 업로드 중 에러가 발생 하였습니다. &
      MESSAGE s000 WITH TEXT-e05 lv_msg  DISPLAY LIKE 'E'.
      pe_error = 'X'.

  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_display_data
*&---------------------------------------------------------------------*
FORM make_display_data  USING    pi_error.

  DATA: lv_err(1),
        ls_list     LIKE gt_list,
        lr_bu_group LIKE RANGE OF but000-bu_group.

**
  CHECK: pi_error IS INITIAL.

  DATA(lt_temp) = gt_excel[].
  DATA(lt_data) = gt_excel[].
  DATA(lt_org)  = gt_excel[].
  SORT: lt_data BY kunnr,
        lt_org  BY kunnr vkorg vtweg spart.
  DELETE ADJACENT DUPLICATES FROM: lt_data COMPARING kunnr,
                                   lt_org  COMPARING kunnr vkorg vtweg spart.

* Customer Name
  SELECT a~kunnr, b~name1
    FROM @lt_data AS a  INNER JOIN kna1 AS b
                        ON a~kunnr EQ b~kunnr
    INTO TABLE @DATA(lt_kna1).

* BP Code
  _clear: lr_bu_group.
  lr_bu_group = VALUE #( ( sign = 'I' option = 'CP' low = 'C*' ) ).

  SELECT a~kunnr, c~partner
    FROM @lt_data AS a  INNER JOIN cvi_cust_link AS b
                        ON  a~kunnr EQ b~customer
                        INNER JOIN but000 AS c
                        ON  b~partner_guid EQ c~partner_guid
   WHERE c~bu_group IN @lr_bu_group
    INTO TABLE @DATA(lt_bp).

* KNVV Check. - for BP Code
  SELECT a~kunnr, a~vkorg, a~vtweg, a~spart, 'U' AS chk
    FROM @lt_org AS a  INNER JOIN knvv AS b
                       ON  a~kunnr   EQ b~kunnr
                       AND a~vkorg   EQ b~vkorg
                       AND a~vtweg   EQ b~vtweg
                       AND a~spart   EQ b~spart
                       AND b~loevm   EQ @space
    INTO TABLE @DATA(lt_knvv).

  _clear: gt_list.
  LOOP AT gt_excel  INTO gs_excel.

    CLEAR: ls_list.
    MOVE-CORRESPONDING: gs_excel TO ls_list.

*   Customer Name
    ls_list-name1   = VALUE #( lt_kna1[ kunnr = ls_list-kunnr ]-name1
                               OPTIONAL ).

*   BP 코드
    ls_list-partner = VALUE #( lt_bp[ kunnr = ls_list-kunnr ]-partner
                               OPTIONAL ).

*   신규여부
    DATA(lv_newchk) = VALUE #( lt_knvv[ kunnr = ls_list-kunnr
                                        vkorg = ls_list-vkorg
                                        vtweg = ls_list-vtweg
                                        spart = ls_list-spart ]-chk
                               OPTIONAL ).

    ls_list-newchk = COND #( WHEN lv_newchk = 'U'
                                  THEN icon_change
                             ELSE icon_create ).

*   Check required fields.
    CLEAR: lv_err.
    PERFORM check_required_field    USING    ls_list
                                    CHANGING lv_err.

*   중복 Check
    DATA(lv_dupchk) = REDUCE i( INIT x = 0  FOR ls_temp IN lt_temp
                                WHERE ( kunnr = ls_list-kunnr AND
                                        vkorg = ls_list-vkorg AND
                                        vtweg = ls_list-vtweg AND
                                        spart = ls_list-spart )
                                NEXT x = x + 1 ).

    ls_list-stat    = COND #( WHEN lv_dupchk > 1
                                   THEN icon_led_red
                              WHEN ls_list-partner IS INITIAL
                                   THEN icon_led_red
                              WHEN lv_err = 'X'
                                   THEN icon_led_red
                              ELSE icon_led_yellow ).

    ls_list-message = COND #( WHEN lv_dupchk > 1
*                                  중복된 데이타가 있습니다.
                                   THEN TEXT-e10
                              WHEN ls_list-partner IS INITIAL
*                                  고객마스터가 생성되지 않았습니다.
                                   THEN TEXT-e09
                              WHEN lv_err = 'X'
*                                  필수필드가 누락되었습니다.
                                   THEN TEXT-e07
                              ELSE space ).

    APPEND ls_list  TO gt_list.

  ENDLOOP.

**
  FREE: lt_temp, lt_data, lt_kna1, lt_bp, lt_org, lt_knvv.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_required_field
*&---------------------------------------------------------------------*
FORM check_required_field  USING    ps_list  LIKE gt_list
                           CHANGING pe_err.

**
  PERFORM required_field_color_set
          USING: ps_list-rltyp  'RLTYP'  CHANGING ps_list-color  pe_err,  " BP Role
                 ps_list-vkorg  'VKORG'  CHANGING ps_list-color  pe_err,  " 영업조직
                 ps_list-vtweg  'VTWEG'  CHANGING ps_list-color  pe_err,  " 유통경로
                 ps_list-spart  'SPART'  CHANGING ps_list-color  pe_err,  " 제품군
                 ps_list-bzirk  'BZIRK'  CHANGING ps_list-color  pe_err,  " 영업지역
                 ps_list-vkbur  'VKBUR'  CHANGING ps_list-color  pe_err,  " 사업장
                 ps_list-waers  'WAERS'  CHANGING ps_list-color  pe_err,  " 통화
                 ps_list-kurst  'KURST'  CHANGING ps_list-color  pe_err,  " 환율유형
                 ps_list-konda  'KONDA'  CHANGING ps_list-color  pe_err,  " 기납증발행여부
                 ps_list-kalks  'KALKS'  CHANGING ps_list-color  pe_err,  " 고객가격절차
                 ps_list-versg  'VERSG'  CHANGING ps_list-color  pe_err,  " 고객 통계 그룹
                 ps_list-lprio  'LPRIO'  CHANGING ps_list-color  pe_err,  " 납품우선순위
                 ps_list-kzazu  'KZAZU'  CHANGING ps_list-color  pe_err,  " 오더조합
                 ps_list-vsbed  'VSBED'  CHANGING ps_list-color  pe_err,  " 출하조건
                 ps_list-inco1  'INCO1'  CHANGING ps_list-color  pe_err,  " 인도조건1
                 ps_list-zterm  'ZTERM'  CHANGING ps_list-color  pe_err,  " 지급조건
                 ps_list-ktgrd  'KTGRD'  CHANGING ps_list-color  pe_err,  " 계정지정그룹
                 ps_list-taxkd  'TAXKD'  CHANGING ps_list-color  pe_err,  " 세금분류
                 ps_list-j_1nboesl  'J_1NBOESL'  CHANGING ps_list-color  pe_err.  " Exchange Key

  IF     ps_list-vtweg = '10'.
*   유통경로 10 인 경우.
    PERFORM required_field_color_set
            USING: ps_list-kvgr1  'KVGR1'  CHANGING ps_list-color  pe_err,
                   ps_list-kvgr2  'KVGR2'  CHANGING ps_list-color  pe_err,
                   ps_list-kvgr3  'KVGR3'  CHANGING ps_list-color  pe_err.

  ELSEIF ps_list-vtweg = '50'.
*   유통경로 50 인 경우.
    PERFORM required_field_color_set
            USING: ps_list-kvgr4  'KVGR4'  CHANGING ps_list-color  pe_err,
                   ps_list-kvgr5  'KVGR5'  CHANGING ps_list-color  pe_err.

  ENDIF.

  SELECT SINGLE ktokd  INTO @DATA(lv_ktokd)
    FROM kna1  WHERE kunnr EQ @ps_list-kunnr.

* 로컬 지급처는 필수가 아닌 선택
  IF lv_ktokd NE '0003'.
    PERFORM required_field_color_set
            USING: ps_list-parvw  'PARVW'  CHANGING ps_list-color  pe_err,  " 파트너기능
                   ps_list-kunn2  'KUNN2'  CHANGING ps_list-color  pe_err.  " 번호
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form required_field_color_set
*&---------------------------------------------------------------------*
FORM required_field_color_set  USING    pi_value
                                        pi_fname
                               CHANGING pt_color   TYPE lvc_t_scol
                                        pe_err.

**
  IF pi_value IS INITIAL.
    pe_err = 'X'.
    PERFORM alv_field_color_set   USING    pi_fname
                                           '0'  '0'  '6'
                                  CHANGING pt_color.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form alv_field_color_set
*&---------------------------------------------------------------------*
FORM alv_field_color_set  USING    pi_fname
                                   pi_int
                                   pi_inv
                                   pi_col
                          CHANGING pt_color   TYPE lvc_t_scol.

**
  APPEND VALUE #( fname       = pi_fname
                  color-int   = pi_int
                  color-inv   = pi_inv
                  color-col   = pi_col ) TO pt_color.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form end_process
*&---------------------------------------------------------------------*
FORM end_process .

**
  CHECK: gv_error IS INITIAL.

  CLEAR: gv_line.
  DESCRIBE TABLE gt_list LINES gv_line.
  IF gv_line > 0.
    CALL SCREEN 100.

  ELSE.
*   엑셀 업로드 데이타가 없습니다.
    MESSAGE e000  WITH TEXT-e06  DISPLAY LIKE 'E'.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form select_deselect_all
*&---------------------------------------------------------------------*
FORM select_deselect_all  USING    pi_ucomm.

**
  IF     pi_ucomm = 'ALL'.
    DATA(lv_chk) = 'X'.
  ELSEIF pi_ucomm = 'DALL'.
    CLEAR: lv_chk.
  ENDIF.

  MODIFY gt_list FROM VALUE #( check = lv_chk )
                      TRANSPORTING check
                 WHERE stat EQ icon_led_yellow .

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form update_bp_sales_view
*&---------------------------------------------------------------------*
FORM update_bp_sales_view  USING    pi_ucomm.

**
  PERFORM check_selected_rows     USING  pi_ucomm.

  PERFORM modify_bp_sales_view    USING  pi_ucomm.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_selected_rows
*&---------------------------------------------------------------------*
FORM check_selected_rows  USING    pi_ucomm.

**
  CHECK: gv_error IS INITIAL.

  CASE pi_ucomm.
    WHEN 'UPLOAD'.    " 영업뷰 업로드
      DATA(lv_chk) = VALUE #( gt_list[ check = 'X' ]-check
                              OPTIONAL ).
      IF lv_chk IS NOT INITIAL.
        CLEAR: lv_chk.
        lv_chk = VALUE #( gt_list[ check = 'X'
                                   stat  = icon_led_red ]-check
                          OPTIONAL ).

        IF lv_chk IS NOT INITIAL.
          gv_error = 'X'.
*         오류가 있는 라인은 처리할 수 없습니다.
          MESSAGE s000  WITH TEXT-e08  DISPLAY LIKE 'E'.
          EXIT.

        ENDIF.

      ELSE.
        gv_error = 'X'.
*       처리할 데이타를 선택 하세요.
        MESSAGE s004  DISPLAY LIKE 'E'.
        EXIT.

      ENDIF.

  ENDCASE.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_bp_sales_view
*&---------------------------------------------------------------------*
FORM modify_bp_sales_view  USING    pi_ucomm.

  DATA: lt_data TYPE cvis_ei_extern_t,
        ls_data TYPE cvis_ei_extern.

**
  CHECK: gv_error IS INITIAL.

*  _clear: lt_data.
  LOOP AT gt_list  ASSIGNING FIELD-SYMBOL(<lfs_list>)
                   WHERE check = 'X'
                     AND stat  = icon_led_yellow.

    _clear: lt_data.
    CLEAR: ls_data.

*   Create BP Data.
    PERFORM create_bp_maintain_data      USING    <lfs_list>
                                         CHANGING ls_data.

    PERFORM bp_maintain_validate_single  USING    ls_data
                                         CHANGING <lfs_list>-stat
                                                  <lfs_list>-message.

    IF ls_data IS NOT INITIAL AND
       <lfs_list>-stat NE icon_led_red.
      APPEND ls_data TO lt_data.
    ENDIF.

*   Create BP Sales View.
    PERFORM create_bp_maintain        USING     lt_data[]
                                                <lfs_list> .

  ENDLOOP.
*
** Create BP Sales View.
*  PERFORM create_bp_maintain        USING     lt_data[] .

**
  FREE: lt_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_bp_maintain_data
*&---------------------------------------------------------------------*
FORM create_bp_maintain_data  USING    ps_list  LIKE gt_list
                              CHANGING ps_data  TYPE cvis_ei_extern.

  DATA: lv_kna1_task(1).

**
* 1) Customer Task Set.
  PERFORM set_bp_partner_header        USING     ps_list-kunnr
                                                 ps_list-partner
                                       CHANGING  ps_data
                                                 lv_kna1_task.

* 2) BP Role
  PERFORM set_bp_role_data             USING     ps_list-kunnr
                                                 ps_list-partner
                                                 ps_list-rltyp
                                                 lv_kna1_task
                                       CHANGING  ps_data.

* 3) BP 영업데이터
  PERFORM set_bp_sales_view_data       USING     ps_list
                                                 lv_kna1_task
                                       CHANGING  ps_data.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_bp_partner_header
*&---------------------------------------------------------------------*
FORM set_bp_partner_header  USING    pi_kunnr
                                     pi_partner
                            CHANGING ps_data    TYPE cvis_ei_extern
                                     pv_task.

  DATA: ls_head    TYPE bus_ei_header,

        lv_kunnr   TYPE kunnr,
        lv_partner TYPE bu_partner.

**
  CLEAR: lv_kunnr, lv_partner.
  lv_kunnr   = |{ pi_kunnr ALPHA = IN }|.
  lv_partner = |{ pi_partner ALPHA = IN }|.

* Get Partner GUID.
  IF lv_partner IS NOT INITIAL.
    SELECT SINGLE partner_guid  INTO @DATA(lv_guid)
      FROM but000  WHERE partner EQ @lv_partner.

  ENDIF.

  IF lv_guid IS NOT INITIAL.
    pv_task = 'U'.
  ELSE.
    pv_task = 'I'.
    CLEAR: lv_guid.
    lv_guid = cl_system_uuid=>create_uuid_x16_static( ). " 신규 생성시에 필수값임

  ENDIF.

  ps_data-partner-header-object_task                  = pv_task.
  ps_data-partner-header-object_instance-bpartnerguid = lv_guid.

  IF     pv_task = 'I'.
    ps_data-ensure_create-create_customer = abap_true. " 고객 신규 생성일때...(KNA1)

  ELSEIF pv_task = 'U'.
    ps_data-partner-header-object_instance-bpartner = lv_partner .

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_bp_role_data
*&---------------------------------------------------------------------*
FORM set_bp_role_data  USING    pi_kunnr
                                pi_partner
                                pi_rltyp
                                pi_kna1_task
                       CHANGING ps_data       TYPE cvis_ei_extern.

  DATA: ls_bp_roles TYPE bus_ei_bupa_roles,   " BP Role
        lv_partner  TYPE bu_partner,
        lv_kunnr    TYPE kunnr.

**
  CLEAR: lv_kunnr, lv_partner.
  lv_kunnr   = |{ pi_kunnr ALPHA = IN }|.
  lv_partner = |{ pi_partner ALPHA = IN }|.

  IF     pi_kna1_task = 'I'.
*   <1 : 개인 , 2:조직, 3: 그룹 >
    ps_data-partner-central_data-common-data-bp_control-category = '2'.
    ps_data-partner-central_data-common-data-bp_control-grouping = 'C010'.

    SELECT SINGLE name1  INTO @DATA(lv_name1)
      FROM kna1  WHERE kunnr EQ @lv_kunnr.

    ps_data-partner-central_data-common-data-bp_organization-name1 = lv_name1.
    ps_data-partner-central_data-common-data-bp_organization-name2 = lv_name1.

    DATA(lv_role_task) = 'I'.

  ELSEIF pi_kna1_task = 'U'.

    CLEAR: lv_role_task.
    SELECT SINGLE 'U'  INTO @lv_role_task
      FROM but100  WHERE partner = @lv_partner
                     AND rltyp   = @pi_rltyp.

    IF lv_role_task IS INITIAL.
      lv_role_task = 'I'.
    ENDIF.

  ENDIF.

  CLEAR: ls_bp_roles.
  ls_bp_roles-task              = lv_role_task.
  ls_bp_roles-data_key          = pi_rltyp. " BP Role
  ls_bp_roles-data-rolecategory = pi_rltyp. " BP Category
  ls_bp_roles-data-valid_from   = sy-datum.
  ls_bp_roles-datax-valid_from  = 'X'.
  ls_bp_roles-data-valid_to     = '99991231'.
  ls_bp_roles-datax-valid_to    = 'X'.

  APPEND ls_bp_roles TO  ps_data-partner-central_data-role-roles.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_bp_sales_view_data
*&---------------------------------------------------------------------*
FORM set_bp_sales_view_data  USING    ps_list       LIKE gt_list
                                      pi_kna1_task
                             CHANGING ps_data       TYPE cvis_ei_extern.

  DATA: ls_sales     TYPE cmds_ei_sales,
        lt_tax       TYPE cmds_ei_tax_ind_t,
        ls_tax       TYPE cmds_ei_tax_ind,
        ls_functions TYPE cmds_ei_functions,
        lv_kunnr     TYPE kunnr,
        lv_partner   TYPE bu_partner.

**
  CLEAR: lv_kunnr, lv_partner.
  lv_kunnr   = |{ ps_list-kunnr    ALPHA = IN }|.
  lv_partner = |{ ps_list-partner  ALPHA = IN }|.

  ps_data-customer-header-object_task           = pi_kna1_task.
  ps_data-customer-header-object_instance-kunnr = lv_kunnr.

* 세금분류
  _clear: lt_tax.
  CLEAR: ls_tax.
  ps_data-customer-central_data-tax_ind-current_state = COND #( WHEN pi_kna1_task = 'I' THEN 'X' ).

* KNVI Check.
  SELECT SINGLE 'U' INTO @DATA(lv_tax_task)
    FROM knvi  WHERE kunnr EQ @lv_kunnr
                 AND aland EQ 'KR'
                 AND tatyp EQ 'MWST'.

  IF lv_tax_task IS INITIAL.
    lv_tax_task = 'I'.
  ENDIF.
  ls_tax-task           = lv_tax_task.
  ls_tax-data_key-aland = 'KR'.
  ls_tax-data_key-tatyp = 'MWST'.
  ls_tax-data-taxkd     = ps_list-taxkd.
  ls_tax-datax-taxkd    = 'X'.

  APPEND ls_tax TO ps_data-customer-central_data-tax_ind-tax_ind .

* 영업 데이타
  CLEAR: ls_sales.

  ps_data-customer-sales_data-current_state = COND #( WHEN pi_kna1_task = 'I' THEN 'X' ).

* KNVV Check.
  SELECT SINGLE 'U' INTO @DATA(lv_sales_task)
    FROM knvv WHERE kunnr EQ @lv_kunnr
                AND vkorg EQ @ps_list-vkorg
                AND vtweg EQ @ps_list-vtweg
                AND spart EQ @ps_list-spart.

  IF lv_sales_task IS INITIAL.
    lv_sales_task = 'I'.
  ENDIF.

* KEY값 설정
  ls_sales-task           = lv_sales_task.
  ls_sales-data_key-vkorg = ps_list-vkorg.
  ls_sales-data_key-vtweg = ps_list-vtweg.
  ls_sales-data_key-spart = ps_list-spart.

* 영업데이터 설정
  PERFORM input_data USING ls_sales-data
                           ls_sales-datax
                           ps_list:
                          'BZIRK'      'BZIRK',     " 영업지역
                          'VKBUR'      'VKBUR',     " 사업장
                          'VKGRP'      'VKGRP',     " 영업 그룹
                          'KDGRP'      'KDGRP',     " 고객 그룹
                          'WAERS'      'WAERS',     " 통화
                          'KURST'      'KURST',     " 환율유형
                          'KONDA'      'KONDA',     " 기납증발행여부
                          'KALKS'      'KALKS',     " 고객가격절차
                          'PLTYP'      'PLTYP',     " 가격 리스트 유형
                          'VERSG'      'VERSG',     " 고객 통계 그룹
                          'LPRIO'      'LPRIO',     " 납품우선순위
                          'KZAZU'      'KZAZU',     " 오더조합
                          'VSBED'      'VSBED',     " 출하 조건
                          'VWERK'      'VWERK',     " 납품 플랜트
                          'PODKZ'      'PODKZ',     " POD 관련
                          'PODTG'      'PODTG',     " POD 타임프레임
                          'AUTLF'      'AUTLF',     " 법적으로 요청된 일괄납품
                          'KZTLF'      'KZTLF',     " 품목레벨 분할납품
                          'ANTLF'      'ANTLF',     " 최대 분할납품
                          'UEBTK'      'UEBTK',     " 무제한 초과납품
                          'UNTTO'      'UNTTO',     " 미달납품 허용치
                          'UEBTO'      'UEBTO',     " 초과납품 허용치
                          'INCO1'      'INCO1',     " 인도 조건(파트 1)
                          'INCO2'      'INCO2',     " 인도 조건(파트 2)
                          'ZTERM'      'ZTERM',     " 지급 조건
                          'KTGRD'      'KTGRD',     " 계정지정그룹
                          'KVGR1'      'KVGR1',     " 고객그룹 1
                          'KVGR2'      'KVGR2',     " 고객그룹 2
                          'KVGR3'      'KVGR3',     " 고객그룹 3
                          'KVGR4'      'KVGR4',     " 고객그룹 4
                          'KVGR5'      'KVGR5',     " 고객그룹 5
                          'J_1NBOESL'  'J_1NBOESL'. " Exchange Key

* Partner Function.
  CLEAR: ls_functions.

  IF ps_list-parvw IS NOT INITIAL AND
     ps_list-kunn2 IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
      EXPORTING
        input  = ps_list-parvw
      IMPORTING
        output = ls_functions-data_key-parvw.

    PERFORM input_data USING ls_functions-data
                             ls_functions-datax
                             ps_list:
                            'PARTNER'      'KUNN2'.

    APPEND ls_functions TO ls_sales-functions-functions.

  ENDIF.

  APPEND ls_sales TO ps_data-customer-sales_data-sales .

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form input_data
*&---------------------------------------------------------------------*
FORM input_data  USING    ps_param      "DATA
                          ps_paramx     "DATAX
                          ps_val        "입력받은 데이터 STRUCTURE
                          p_fieldp      "DATA 필드명
                          p_fieldv.     "값 필드명

**

  ASSIGN COMPONENT p_fieldv OF STRUCTURE ps_val   TO FIELD-SYMBOL(<fv_val>).
  CHECK sy-subrc = 0.

  CHECK <fv_val> IS NOT INITIAL.

  ASSIGN COMPONENT p_fieldp OF STRUCTURE ps_param  TO FIELD-SYMBOL(<fv_param>).
  ASSIGN COMPONENT p_fieldp OF STRUCTURE ps_paramx TO FIELD-SYMBOL(<fv_paramx>).

  <fv_param> = <fv_val>.
  <fv_paramx> = 'X'.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form bp_maintain_validate_single
*&---------------------------------------------------------------------*
FORM bp_maintain_validate_single  USING    ps_data  TYPE cvis_ei_extern
                                  CHANGING pe_stat
                                           pe_message.

**
  CHECK: ps_data IS NOT INITIAL.

  cl_md_bp_maintain=>validate_single(
    EXPORTING
      i_data        = ps_data
    IMPORTING
      et_return_map = DATA(lt_return) ).

  IF line_exists( lt_return[ type = 'E' ] ) OR
     line_exists( lt_return[ type = 'A' ] ).

    DATA(lv_msg) = VALUE #( lt_return[ type = 'E' ]-message
                            OPTIONAL ).
    IF lv_msg IS INITIAL.
      lv_msg = VALUE #( lt_return[ type = 'A' ]-message
                        OPTIONAL ).
    ENDIF.
    IF lv_msg IS NOT INITIAL.
      pe_stat    = icon_led_red.
      pe_message = lv_msg.
    ENDIF.

  ENDIF.

**
  FREE: lt_return.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_bp_maintain
*&---------------------------------------------------------------------*
FORM create_bp_maintain  USING    pt_data  TYPE cvis_ei_extern_t
                                  ps_list  LIKE gt_list.

  DATA: lt_return  TYPE bapiretm,
        lt_msg1    TYPE TABLE OF bdcmsgcoll,
        lt_msg2    TYPE TABLE OF bapiret2,
        lv_stat    LIKE gt_list-stat,
        lv_message LIKE gt_list-message.
**
  CHECK: pt_data[] IS NOT INITIAL.

  _clear: lt_return.
  CALL METHOD cl_md_bp_maintain=>maintain
    EXPORTING
      i_data   = pt_data
    IMPORTING
      e_return = lt_return.

* Check Message.
  _clear: lt_msg1, lt_msg2.
  LOOP AT lt_return INTO DATA(ls_return).

    DELETE: ls_return-object_msg WHERE type = 'W'.

    lt_msg1[] = VALUE #( BASE lt_msg1[] FOR ls_msg IN ls_return-object_msg
                         ( msgtyp = ls_msg-type
                           msgid  = ls_msg-id
                           msgnr  = ls_msg-number
                           msgv1  = ls_msg-message_v1
                           msgv2  = ls_msg-message_v2
                           msgv3  = ls_msg-message_v3
                           msgv4  = ls_msg-message_v4 ) ).

    MOVE-CORRESPONDING ls_return-object_msg TO lt_msg2[] KEEPING TARGET LINES.

  ENDLOOP.

  CLEAR: lv_stat, lv_message.
  READ TABLE lt_msg2 INTO DATA(ls_msg2)
                     WITH KEY type = 'E'.
  IF sy-subrc <> 0.
    READ TABLE lt_msg2 INTO ls_msg2
                       WITH KEY type = 'A'.
  ENDIF.

  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    lv_stat    = icon_led_red.
    lv_message = ls_msg2-message.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    lv_stat    = icon_led_green.
    lv_message = 'Success'.

  ENDIF.

  ps_list-stat    = lv_stat.
  ps_list-message = lv_message.
  ps_list-check   = space.

*  MODIFY gt_list FROM VALUE #( check   = space
*                               stat    = lv_stat
*                               message = lv_message )
*                      TRANSPORTING check stat message
*                 WHERE check EQ 'X'
*                   AND stat  EQ icon_led_yellow.
*                   AND stat  NE icon_led_red.

**
  FREE: lt_return.

ENDFORM.
