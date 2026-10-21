*&---------------------------------------------------------------------*
*&  Include           ZLER0016F01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  value_request
*&---------------------------------------------------------------------*
FORM value_request  USING  p_xx.

* 통문유형 listbox
*  TYPE-POOLS vrm.
*  DATA: lt_values  TYPE vrm_values WITH HEADER LINE.
  DATA: LV_VRMID     TYPE VRM_ID     .
  DATA: P_SEQ(2)     TYPE C.
  DATA: LV_TYPE(30)  TYPE C.
  DATA: LV_WHERE     TYPE STRING.
  DATA: LT_0007      LIKE zgtmmt4511 OCCURS 0 WITH HEADER LINE.
  DATA: LT_DYNP      LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  CLEAR  : LT_VALUES, LT_0007, LV_VRMID.
  REFRESH: LT_VALUES, LT_0007.

  CASE P_XX.
    WHEN 'GUBUN1'.
      LV_VRMID = 'P_GUBUN1'.

*{ 기능개선 273711 - 변경
*      CASE P_BUKRS.
*        WHEN '1000'.
*          LV_WHERE = 'AND COCD1 = ''X'''.
*        WHEN '2000'.
*          LV_WHERE = 'AND COCD2 = ''X'''.
*        WHEN '3000'.
*          LV_WHERE = 'AND COCD3 = ''X'''.
*        WHEN '5000'.
*          LV_WHERE = 'AND COCD4 = ''X'''.
*        WHEN OTHERS.
*          CLEAR : LV_WHERE.
*      ENDCASE.

      CASE 'X'.
        WHEN R1. "MM일반
          CONCATENATE 'IV_TYPE LIKE ''B__'' AND MDULE <> ''SM'' AND BUKRS = P_BUKRS'
                      LV_WHERE
                 INTO LV_WHERE SEPARATED BY SPACE.

        WHEN R2. "매각/폐기
          CONCATENATE 'IV_TYPE LIKE ''D__'''
                      LV_WHERE
                 INTO LV_WHERE SEPARATED BY SPACE.
*가온전선_조회 조건 R3(PP)미사용으로 주석_(ZGODEV04_260106)
*->시작
*        WHEN R3.
*          CONCATENATE 'IV_TYPE LIKE ''B__'' AND MDULE = ''MMPP'''
*                      LV_WHERE
*                 INTO LV_WHERE SEPARATED BY SPACE.

        WHEN OTHERS.
*가온전선_조회 조건 R4(서비스)미사용으로 주석_(ZGODEV04_260106)
*          CONCATENATE 'IV_TYPE LIKE ''B__'' AND MDULE = ''SM'''
*                      LV_WHERE
*                 INTO LV_WHERE SEPARATED BY SPACE.
*<-끝.
      ENDCASE.

*     CASE 'X'.
*       WHEN R1.
*         CASE P_BUKRS.
*           WHEN '1000'.
*             LV_WHERE = 'AND COCD1 = ''X'''.
*           WHEN '2000'.
*             LV_WHERE = 'AND COCD2 = ''X'''.
*           WHEN '3000'.
*             LV_WHERE = 'AND COCD3 = ''X'''.
*           WHEN '5000'.
*             LV_WHERE = 'AND COCD4 = ''X'''.
*           WHEN OTHERS.
*             CLEAR : LV_WHERE.
*         ENDCASE.
*
*         CONCATENATE 'IV_TYPE LIKE ''B__'' AND MDULE <> ''SM'''
*                     LV_WHERE
*                INTO LV_WHERE SEPARATED BY SPACE.
*
*       WHEN R2.
*         LV_WHERE = 'IV_TYPE LIKE ''D__'''.
*
*       WHEN R3.
*         LV_WHERE = 'IV_TYPE LIKE ''B__'' AND MDULE = ''MMPP'''.
*
*       WHEN OTHERS.
*         LV_WHERE = 'IV_TYPE LIKE ''B__'' AND MDULE = ''SM'''.
*
*     ENDCASE.
*} 기능개선 273711 - 변경

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE LT_0007
*        INTO TABLE LT_0007
        FROM   ZGTMMT4511
       WHERE (LV_WHERE).

*{ 기능개선 273305 - 삭제
**___'999:전체' 추가
*      PERFORM GET_VRM_ID_VALUES TABLES LT_VALUES
*                                USING  '999' '999:전체'.
*} 기능개선 273305 - 삭제

      LOOP AT LT_0007.
        CONCATENATE LT_0007-IV_TYPE ':' LT_0007-IV_TYPE_NM
               INTO LV_TYPE.

        PERFORM GET_VRM_ID_VALUES TABLES LT_VALUES
                                  USING  LT_0007-IV_TYPE
                                         LV_TYPE.
      ENDLOOP.
  ENDCASE.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = LV_VRMID
      VALUES          = LT_VALUES[]
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " value_request
*&---------------------------------------------------------------------*
*&      Form  get_vrm_id_values
*&---------------------------------------------------------------------*
FORM get_vrm_id_values  TABLES   t_values TYPE vrm_values
                        USING    p_key
                                 p_text.

  t_values-key    = p_key.
  t_values-text   = p_text.
  APPEND t_values.

ENDFORM.                    " get_vrm_id_values
*&---------------------------------------------------------------------*
*&      Form  DATA_GET
*&---------------------------------------------------------------------*
FORM data_get .

* 통문유형 SETTING
*  REFRESH i_ivtyp.  CLEAR i_ivtyp.
*  IF p_gubun1 = '2'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '541'.  "무상사급
*  ELSEIF p_gubun1 = '3'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '122'.  "불량반품
*  ELSEIF p_gubun1 = '4'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '161'.  "반품
*  ELSEIF p_gubun1 = '5'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '351'.  "공장간 이체
*  ELSE.
*    PERFORM iv_type_setting USING 'I' 'EQ' '541'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '122'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '161'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '351'.
*  ENDIF.

*/ 사업장
  CLEAR: r_werks[], r_werks.

*  IF r4 = 'X' AND ( p_bzarea = '5000' OR p_bzarea = '5100').
*    SELECT * FROM zlet0034 WHERE  bzarea = '5000' OR bzarea = '5100'.
*      r_werks-sign   = 'I'.
*      r_werks-option = 'EQ'.
*      r_werks-low    = zlet0034-werks.
*      APPEND r_werks.
*    ENDSELECT.
*  ELSE.
    SELECT * FROM zlet0034 WHERE  bzarea = p_bzarea.
      r_werks-sign   = 'I'.
      r_werks-option = 'EQ'.
      r_werks-low    = zlet0034-werks.
      APPEND r_werks.
    ENDSELECT.
*  ENDIF.
*/ 이동유형
  REFRESH i_ivtyp.  CLEAR i_ivtyp.
*{ 기능개선 273305 - 변경
  IF p_gubun1 = '1'.
    LOOP AT lt_values WHERE key <> p_gubun1.
      i_ivtyp-sign   = 'I'.
      i_ivtyp-option = 'EQ'.
      i_ivtyp-low    = lt_values-text(3).
      APPEND i_ivtyp.
    ENDLOOP.
  ELSE.
    LOOP AT lt_values WHERE key = p_gubun1.
      i_ivtyp-sign   = 'I'.
      i_ivtyp-option = 'EQ'.
      i_ivtyp-low    = lt_values-text(3).
      APPEND i_ivtyp.
    ENDLOOP.
  ENDIF.

*  IF P_GUBUN1 = '1'.
*    IF R4 = 'X'.
*      SELECT * FROM ZLET0007
*      WHERE IV_TYPE LIKE 'B__'
*      AND   MDULE    = 'SM'..
*        I_IVTYP-SIGN   = 'I'.
*        I_IVTYP-OPTION = 'EQ'.
*        I_IVTYP-LOW    = ZLET0007-BWART.
*        APPEND I_IVTYP.
*      ENDSELECT.
*    ELSE.
*      SELECT * FROM ZLET0007
*      WHERE IV_TYPE LIKE 'B__'
*      AND   MDULE    <> 'SM'.
*        I_IVTYP-SIGN   = 'I'.
*        I_IVTYP-OPTION = 'EQ'.
*        I_IVTYP-LOW    = ZLET0007-BWART.
*        APPEND I_IVTYP.
*      ENDSELECT.
*    ENDIF.
*  ELSE.
*    LOOP AT LT_VALUES WHERE KEY = P_GUBUN1.
*      SELECT SINGLE * FROM ZLET0007
*        WHERE IV_TYPE = LT_VALUES-TEXT+0(3).
*      IF SY-SUBRC = 0.
*        I_IVTYP-SIGN   = 'I'.
*        I_IVTYP-OPTION = 'EQ'.
*        I_IVTYP-LOW    = ZLET0007-BWART.
*        APPEND I_IVTYP.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*} 기능개선 273305 - 변경

* 자재문서 Header/Detail 에서 조건에 맞는 Data 발췌
  SELECT a~iv_type a~iv_no b~mblnr b~zeile b~matnr
         b~mtr_unit b~lfimg a~truck_no b~mjahr
         a~out_yn a~bwart a~driver_nm a~driver_telno a~etc_nm
         a~werks a~create_date a~create_time a~iv_date
         a~pernr a~ename " CHM2008-00227 추가
         INTO CORRESPONDING FIELDS OF TABLE gt_out
         FROM ZGTMMT4500 AS a
   INNER JOIN ZGTMMT4501 AS b
           ON a~iv_no = b~iv_no
        WHERE a~iv_no    IN  i_ivno
          AND a~iv_date  IN  i_date
          AND a~iv_type  IN  i_ivtyp    "기능개선 273305 - 추가
          AND a~bzarea   =   p_bzarea   "기능개선 273711 - 추가
*          AND A~BWART    IN  I_IVTYP    "기능개선 273305 - 삭제
          AND a~werks    = P_WERKS
          AND a~werks    IN  r_werks
          AND b~matnr    IN  i_matnr
          AND a~iv_cancel_yn <> 'X'.

  LOOP AT gt_out.
*   PP 거래명세서
    IF gt_out-iv_no+0(1) = '7'.
      DELETE gt_out. CONTINUE.
    ENDIF.
*   차량번호 입력시
    IF i_truno <> ' '.
      IF i_truno <> gt_out-truck_no.
        DELETE gt_out INDEX sy-tabix.
        CONTINUE.
      ENDIF.
    ENDIF.
*   업체코드 입력시
    CLEAR mseg.
    SELECT SINGLE * FROM mseg WHERE mblnr EQ gt_out-mblnr
                                AND zeile EQ gt_out-zeile
                                AND mjahr EQ gt_out-mjahr
                                AND lifnr IN i_lifnr.
    IF sy-subrc <> 0.
      DELETE gt_out INDEX sy-tabix.
      CONTINUE.
    ENDIF.

    IF r1 = 'X' AND gt_out-iv_type = 'B20' AND gt_out-werks = '3602'.
      gt_out-charg = mseg-charg.
    ENDIF.

    gt_out-ebeln = mseg-ebeln.
    gt_out-ebelp = mseg-ebelp.
    gt_out-umwrk = mseg-umwrk.
*
    gt_out-lifnr = mseg-lifnr.
*   자재 품명:규격
    IF gt_out-iv_type = 'B01'.
      SELECT SINGLE zzmaktx80 INTO gt_out-maktx FROM mara
                         WHERE matnr EQ gt_out-matnr.

      IF gt_out-maktx IS INITIAL.
        SELECT SINGLE maktx INTO gt_out-maktx FROM makt
                           WHERE matnr EQ gt_out-matnr
                             AND spras EQ '3'.
      ENDIF.

    ELSE.
      SELECT SINGLE maktx INTO gt_out-maktx FROM makt
                         WHERE matnr EQ gt_out-matnr
                           AND spras EQ '3'.
    ENDIF.

*   통문유형별 Description
    SELECT SINGLE iv_type_nm INTO gt_out-iv_tdes FROM zgtmmt4511
                            WHERE bukrs = p_bukrs AND  iv_type EQ gt_out-iv_type.
*    SELECT SINGLE iv_type_nm INTO gt_out-iv_tdes FROM zlet0007
*                            WHERE iv_type EQ gt_out-iv_type.
*    IF GT_OUT-BWART = '541'.
*       GT_OUT-IV_TDES = '무상사급'.
*    ELSEIF GT_OUT-BWART = '122'.
*       GT_OUT-IV_TDES = '불량반품'.
*    ELSEIF GT_OUT-BWART = '161'.
*       GT_OUT-IV_TDES = '반품'.
*    ELSEIF GT_OUT-BWART = '351'.
*       GT_OUT-IV_TDES = '공장간이체'.
*    ENDIF.
*   통문유무
    IF gt_out-out_yn = 'X'.
      gt_out-out_yn = 'Y'.
    ELSE.
      gt_out-out_yn = 'N'.
    ENDIF.

* [START] CSR NO : C20070810_14860

* MRP 관리자 입력 시
    IF i_dispo <> ' '.
      CLEAR marc.
      SELECT SINGLE * FROM marc
       WHERE matnr EQ gt_out-matnr
         AND werks EQ gt_out-werks
         AND dispo EQ i_dispo.
      IF sy-subrc <> 0.
        DELETE gt_out INDEX sy-tabix.
        CONTINUE.
      ENDIF.
    ENDIF.
* [END]   CSR NO : C20070810_14860

    MODIFY gt_out INDEX sy-tabix.
  ENDLOOP.
*
  DESCRIBE TABLE gt_out LINES sy-tfill.
  IF sy-tfill = 0.
    MESSAGE s005(zle1) WITH '조건에 맞는 DATA가 없습니다'.
    IF sy-dynnr = '1000'.
      STOP.
    ELSE.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
*  SORT GT_OUT BY IV_TYPE IV_NO MBLNR ZEILE.
ENDFORM.                    " DATA_GET
*&---------------------------------------------------------------------*
*&      Form  IV_TYPE_SETTING
*&---------------------------------------------------------------------*
FORM iv_type_setting  USING  p_sign  p_option  p_type.

  i_ivtyp-sign   = p_sign.
  i_ivtyp-option = p_option.
  i_ivtyp-low    = p_type.
  APPEND i_ivtyp.  CLEAR i_ivtyp.
ENDFORM.                    " IV_TYPE_SETTING
*&---------------------------------------------------------------------*
*&      Form  create_and_init_controls
*&---------------------------------------------------------------------*
FORM create_and_init_controls .
* Create an Instance Of Container
  IF docking IS INITIAL.
    CREATE OBJECT docking
      EXPORTING
        repid     = sy-repid
        dynnr     = '0100'
        side      = docking->dock_at_top
        extension = 2000.
*    Create an Instance of ALV Control
    CREATE OBJECT grid1
      EXPORTING
        i_parent = docking.

*    출력할 필드속성 정의
    PERFORM set_field_catalogs_grid1.

*    Layout Setting          - 주석처리하면 ALV Report에 적합.
    PERFORM set_option_grid1.
    CALL METHOD grid1->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    alv_variant-report  = sy-repid.
*    ALV DATA 뿌려줌
    CALL METHOD grid1->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout
        it_toolbar_excluding = gt_tbar_excluding1
        i_save               = 'A'
        is_variant           = alv_variant
      CHANGING
        it_outtab            = gt_out[]
        it_fieldcatalog      = gt_lvc1[].

*    ALV 내에서의 이벤트 연결.
    CREATE OBJECT event_receiver.
    SET HANDLER event_receiver->handle_user_command          FOR grid1.
*    SET HANDLER EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK        FOR GRID1.
    SET HANDLER event_receiver->handle_toolbar               FOR grid1.
    SET HANDLER event_receiver->handle_double_click         FOR grid1.
    SET HANDLER event_receiver->handle_data_changed_finished FOR grid1.
    CALL METHOD grid1->set_toolbar_interactive.
  ELSE.
*     IF SY-UCOMM = 'REFR'.
    CALL METHOD grid1->refresh_table_display.
*     ENDIF.
  ENDIF.
  CLEAR sy-ucomm.
ENDFORM.                    " create_and_init_controls
*&---------------------------------------------------------------------*
*&      Form  SET_FIELD_CATALOGS_GRID1
*&---------------------------------------------------------------------*
FORM set_field_catalogs_grid1 .
  REFRESH: gt_lvc1[].
  PERFORM fill_field_catalogs
          USING:
                  'S' 'FIELDNAME'   'CHK',
                  ' ' 'COLTEXT'     ' ',
                  ' ' 'JUST'        'L',
                  ' ' 'KEY'         'X',
                  ' ' 'CHECKBOX'    'X',
                  ' ' 'EDIT'        'X',
                  ' ' 'EMPHASIZE'   'C301',
                  'E' 'OUTPUTLEN'   '1',

                  'S' 'FIELDNAME'   'IV_NO',
                  ' ' 'COLTEXT'     '통문번호',
                  ' ' 'JUST'        'L',
                  ' ' 'KEY'         'X',
                  'E' 'OUTPUTLEN'   '10',

                  'S' 'FIELDNAME'   'OUT_YN',
                  ' ' 'COLTEXT'     '통문유무',
                  ' ' 'JUST'        'L',
                  ' ' 'KEY'         'X',
                  'E' 'OUTPUTLEN'   '08',

*                  'S' 'FIELDNAME'   'IV_TYPE',
*                  ' ' 'COLTEXT'     '통문유형',
*                  ' ' 'JUST'        'L',
*                  ' ' 'KEY'         'X',
*                  'E' 'OUTPUTLEN'   '08',

                  'S' 'FIELDNAME'   'IV_TDES',
                  ' ' 'COLTEXT'     '통문유형명',
                  ' ' 'JUST'        'L',
                  ' ' 'KEY'         'X',
                  'E' 'OUTPUTLEN'   '20',

                  'S' 'FIELDNAME'   'WERKS',
                  ' ' 'COLTEXT'     '플랜트',
                  ' ' 'JUST'        'L',
                  ' ' 'KEY'         'X',
                  'E' 'OUTPUTLEN'   '08',

*                  'S' 'FIELDNAME'   'WERKS_T',
*                  ' ' 'COLTEXT'     '플랜트명',
*                  ' ' 'JUST'        'L',
*                  ' ' 'KEY'         'X',
*                  'E' 'OUTPUTLEN'   '20',

                  'S' 'FIELDNAME'   'MBLNR',
                  ' ' 'COLTEXT'     '자재문서',
                  ' ' 'JUST'        'L',
                  ' ' 'KEY'         'X',
                  'E' 'OUTPUTLEN'   '10',

                  'S' 'FIELDNAME'   'ZEILE',
                  ' ' 'COLTEXT'     'ITEM',
                  ' ' 'JUST'        'L',
                  ' ' 'KEY'         'X',
                  'E' 'OUTPUTLEN'   '06',

                  'S' 'FIELDNAME'   'MATNR',
                  ' ' 'COLTEXT'     '자재번호',
                  ' ' 'JUST'        'L',
                  ' ' 'KEY'         'X',
                  ' ' 'NO_ZERO'     'X',
                  'E' 'OUTPUTLEN'   '15',

                  'S' 'FIELDNAME'   'MAKTX',
                  ' ' 'COLTEXT'     '품명규격',
                  ' ' 'KEY'         'X',
                  ' ' 'JUST'        'L',
                  'E' 'OUTPUTLEN'   '40',

                  'S' 'FIELDNAME'   'MTR_UNIT',
                  ' ' 'COLTEXT'     '단위',
                  ' ' 'KEY'         'X',
                  ' ' 'JUST'        'L',
                  ' ' 'CONVEXIT'    'CUNIT',
                  'E' 'OUTPUTLEN'   '04',

                  'S' 'FIELDNAME'   'LFIMG',
                  ' ' 'COLTEXT'     '수량',
                  ' ' 'KEY'         'X',
                  ' ' 'JUST'        'R',
*                  ' ' 'TABNAME'     'GT_OUT',
*                  ' ' 'QFIELDNAME'  'MTR_UNIT',
                  'E' 'OUTPUTLEN'   '18',

* 필드 추가 by J.Y.Lee 10/25/2013 C20131010_16602
                  'S' 'FIELDNAME'   'TRUCK_NO',
                  ' ' 'COLTEXT'     '차량번호',
                  ' ' 'JUST'        'L',
                  ' ' 'KEY'         'X',
                  'E' 'OUTPUTLEN'   '20',

                  'S' 'FIELDNAME'   'ETC_NM',
                  ' ' 'COLTEXT'     '특이사항',
                  ' ' 'JUST'        'L',
                  ' ' 'KEY'         'X',
                  'E' 'OUTPUTLEN'   '50',

* 필드 추가 by H.M.Lim 11/12/2015  기능개선 101979
*                  'S' 'FIELDNAME'   'CREATE_DATE',
*                  ' ' 'COLTEXT'     '통문요청일자',
*                  ' ' 'JUST'        'L',
*                  ' ' 'KEY'         'X',
*                  'E' 'OUTPUTLEN'   '8',
*
*                  'S' 'FIELDNAME'   'CREATE_TIME',
*                  ' ' 'COLTEXT'     '통문요청시간',
*                  ' ' 'JUST'        'L',
*                  ' ' 'KEY'         'X',
*                  'E' 'OUTPUTLEN'   '6',

                  'S' 'FIELDNAME'   'IV_DATE',
                  ' ' 'COLTEXT'     '통문증발행일자',
                  ' ' 'JUST'        'L',
                  ' ' 'KEY'         'X',
                  'E' 'OUTPUTLEN'   '8',

                  'S' 'FIELDNAME'   'CREATE_TIME',
                  ' ' 'COLTEXT'     '통문증발행시간',
                  ' ' 'JUST'        'L',
                  ' ' 'KEY'         'X',
                  'E' 'OUTPUTLEN'   '6'.

*                  'S' 'FIELDNAME'   'QDATU',
*                  ' ' 'COLTEXT'     'TO확정일',
*                  ' ' 'JUST'        'L',
*                  ' ' 'KEY'         'X',
*                  'E' 'OUTPUTLEN'   '8',
*
*                  'S' 'FIELDNAME'   'QZEIT',
*                  ' ' 'COLTEXT'     'TO확정시간',
*                  ' ' 'JUST'        'L',
*                  ' ' 'KEY'         'X',
*                  'E' 'OUTPUTLEN'   '6'.

ENDFORM.                    " SET_FIELD_CATALOGS_GRID1
*&---------------------------------------------------------------------*
*&      Form  fill_field_catalogs
*&---------------------------------------------------------------------*
FORM fill_field_catalogs  USING    p_gub  p_fname  p_value.

*- 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*- 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점

  IF p_gub = 'S'.
    CLEAR gs_lvc1.
  ENDIF.
*
  DATA l_fname(40).
  FIELD-SYMBOLS <fs> TYPE any.
  CONCATENATE 'GS_LVC1-' p_fname INTO l_fname.

  ASSIGN (l_fname) TO <fs>.
  <fs> = p_value.
*
  IF p_gub = 'E'.
    APPEND gs_lvc1 TO gt_lvc1.
  ENDIF.

ENDFORM.                    " fill_field_catalogs
*&---------------------------------------------------------------------*
*&      Form  set_option_grid1
*&---------------------------------------------------------------------*
FORM set_option_grid1 .

* 1. LAYOUT OPTION - 라인 선택 가능
  gs_layout-sel_mode   = 'B'.
  gs_layout-no_rowmark = 'X'.
  gs_layout-zebra      = 'X'.
  gs_layout-cwidth_opt = 'X'.
*  gs_layout-ctab_fname = 'ALV_COL'.
*  gs_layout-stylefname = 'CELLTAB'.

* 2. EXCLUDING MENU
  CLEAR :   gt_tbar_excluding1[].
  APPEND : '&REFRESH'             TO gt_tbar_excluding1,
           '&LOCAL&CUT'           TO gt_tbar_excluding1,
           '&LOCAL&COPY'          TO gt_tbar_excluding1,
           '&LOCAL&PASTE'         TO gt_tbar_excluding1,
           '&LOCAL&PASTE_NEW_ROW' TO gt_tbar_excluding1,
           '&LOCAL&UNDO'          TO gt_tbar_excluding1,
           '&LOCAL&APPEND'        TO gt_tbar_excluding1,
           '&LOCAL&INSERT_ROW'    TO gt_tbar_excluding1,
           '&LOCAL&DELETE_ROW'    TO gt_tbar_excluding1,
           '&LOCAL&COPY_ROW'      TO gt_tbar_excluding1,
           '&PRINT'               TO gt_tbar_excluding1,
           '&DETAIL'              TO gt_tbar_excluding1.

ENDFORM.                    " set_option_grid1
*&---------------------------------------------------------------------*
*&      Form  TONGMOON_CANCEL
*&---------------------------------------------------------------------*
FORM tongmoon_cancel .
*
  DATA: gt_out_f LIKE gt_out OCCURS 0 WITH HEADER LINE.

  READ TABLE gt_out WITH KEY chk = 'X'.
  IF sy-subrc <> 0.
    MESSAGE s005(zle1) WITH 'DATA를 선택하세요'.
    EXIT.
  ENDIF.
*
  PERFORM pop_up_confirm(zler0004) USING '< 통문증취소여부 >'
                                        '취소하시겠습니까?'
                                CHANGING lv_return.
  CHECK lv_return = 'J'.
  CLEAR lv_return.
*
  REFRESH: scc_tab, err_tab.  CLEAR: scc_tab, err_tab.
  REFRESH: lv_msg_tab, gt_out_f.
  CLEAR: lv_msg_tab, gt_out_f.
  LOOP AT gt_out WHERE chk = 'X'.
    MOVE-CORRESPONDING gt_out TO gt_out_f.
    APPEND gt_out_f. CLEAR gt_out_f.
  ENDLOOP.
  SORT gt_out_f BY iv_no.
  DELETE ADJACENT DUPLICATES FROM gt_out_f COMPARING iv_no.
  LOOP AT gt_out_f.
    CLEAR ZGTMMT4500.
    SELECT SINGLE * FROM ZGTMMT4500
                   WHERE iv_no EQ gt_out_f-iv_no.
    CHECK sy-subrc = 0.
    IF ZGTMMT4500-out_yn = 'X'.
      CONCATENATE gt_out_f-iv_no ' ' '--> 통문확정으로 취소불가!'
                    INTO lv_msg_tab-msgtx SEPARATED BY space.
      APPEND lv_msg_tab.  CLEAR lv_msg_tab.
      CONTINUE.
    ENDIF.
    UPDATE ZGTMMT4500 SET iv_cancel_yn = 'X'
                        change_date  = sy-datum
                        change_time  = sy-uzeit
                  WHERE iv_no = gt_out_f-iv_no.
    IF sy-subrc = 0.
      CONCATENATE gt_out_f-iv_no ' ' '--> 통문 취소되었습니다' INTO
                    lv_msg_tab-msgtx SEPARATED BY space.
      APPEND lv_msg_tab.  CLEAR lv_msg_tab.
    ELSE.
      CONCATENATE gt_out_f-iv_no ' ' '--> 통문취소 실패!'
                    INTO lv_msg_tab-msgtx SEPARATED BY space.
      APPEND lv_msg_tab.  CLEAR lv_msg_tab.
    ENDIF.
  ENDLOOP.
  COMMIT WORK.
*
  CALL FUNCTION 'Z_LE_POPUP_TO_ERROR_MESSAGE'
    TABLES
      msg_tab = lv_msg_tab.

* 통문 취소 완료 후 Screen Data 삭제
  LOOP AT gt_out WHERE chk = 'X'.
    CLEAR ZGTMMT4500.
    SELECT SINGLE * FROM ZGTMMT4500 WHERE iv_no  EQ gt_out-iv_no
                                    AND iv_cancel_yn EQ 'X'.
    CHECK sy-subrc = 0.
    DELETE gt_out.
  ENDLOOP.

ENDFORM.                    " TONGMOON_CANCEL
*&---------------------------------------------------------------------*
*&      Form  get_grid1_control
*&---------------------------------------------------------------------*
FORM get_grid1_control .
*
  REFRESH lt_tab.  CLEAR lt_tab.
  LOOP AT gt_out WHERE chk = 'X'.
    lt_tab-ivno = gt_out-iv_no.
    COLLECT lt_tab. CLEAR lt_tab.
  ENDLOOP.
*
  LOOP AT lt_tab.
    AT NEW ivno.
      READ TABLE gt_out WITH KEY iv_no = lt_tab-ivno
                                   chk = ' '
                                    fg = 'X'.
      IF sy-subrc = 0.
        lv_ck = 'X'.
      ELSE.
        CLEAR lv_ck.
      ENDIF.
    ENDAT.
    IF lv_ck = 'X'.
      LOOP AT gt_out WHERE iv_no = lt_tab-ivno.
        gt_out-chk  = ' '.
        gt_out-fg   = ' '.
        MODIFY gt_out INDEX sy-tabix.
        CLEAR gt_out.
      ENDLOOP.
    ELSE.
      LOOP AT gt_out WHERE iv_no = lt_tab-ivno.
        gt_out-chk  = 'X'.
        gt_out-fg   = 'X'.
        MODIFY gt_out INDEX sy-tabix.
        CLEAR gt_out.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " get_grid1_control
*&---------------------------------------------------------------------*
*&      Form  change_data_from_inside_grid1
*&---------------------------------------------------------------------*
FORM change_data_from_inside_grid1 .

  DATA: lv_index LIKE sy-index.
  CLEAR: lv_index.
  LOOP AT gt_out.
    lv_index = lv_index + 1.
    IF gt_out-iv_no = gv_iv_no.
      IF gt_out-chk = ' '.
        ls_delta_cells-row_id    = lv_index.
        ls_delta_cells-fieldname = 'CHK'.
        ls_delta_cells-value     = ' '.
        APPEND ls_delta_cells TO lt_delta_cells.
        gt_out-chk = ' '.
        MODIFY gt_out.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR: lv_index.
  LOOP AT gt_out.
    lv_index = lv_index + 1.
    IF gt_out-chk = 'X'.
      ls_delta_cells-row_id    = lv_index.
      ls_delta_cells-fieldname = 'CHK'.
      ls_delta_cells-value     = 'X'.
      APPEND ls_delta_cells TO lt_delta_cells.
      gv_iv_no = gt_out-iv_no.
    ENDIF.
  ENDLOOP.


  CALL METHOD grid1->change_data_from_inside
    EXPORTING
      it_style_cells = lt_delta_cells
    IMPORTING
      et_bad_cells   = lt_delta_cells
      et_msg         = lt_msg.
ENDFORM.                    " change_data_from_inside_grid1
*&---------------------------------------------------------------------*
*&      Form  TONGMOON_CONFIRM_Y_N
*&---------------------------------------------------------------------*
FORM tongmoon_confirm_y_n .

  READ TABLE gt_out WITH KEY iv_no = gv_iv_no
                             chk   = 'X'.
  IF sy-subrc = 0.
    SELECT SINGLE * FROM ZGTMMT4500
                   WHERE iv_no  EQ gv_iv_no
                     AND out_yn EQ 'X'.
    IF sy-subrc = 0.
      LOOP AT gt_out WHERE iv_no = gv_iv_no.
        gt_out-chk = ' '.
        gt_out-fg  = ' '.
        MODIFY gt_out INDEX sy-tabix.
      ENDLOOP.
*       20090203 Upgrade begin
*        MESSAGE I005(ZLE1) WITH GT_OUT-IV_NO '는 통문확정완료 -> 통문증
*취소불가'.
      MESSAGE i005(zle1)
        WITH gt_out-iv_no '는 통문확정완료 -> 통문증취소불가'.
*       20090203 Upgrade end
    ENDIF.
  ENDIF.

ENDFORM.                    " TONGMOON_CONFIRM_Y_N
*&---------------------------------------------------------------------

*&      Form  user_command_pros
*&---------------------------------------------------------------------

FORM user_command_pros  USING  r_ucomm.

  CASE r_ucomm.
    WHEN 'DSEL'.
      PERFORM deselect_process.

  ENDCASE.
ENDFORM.                    " user_command_pros
*&---------------------------------------------------------------------*
*&      Form  deselect_process
*&---------------------------------------------------------------------*
FORM deselect_process .
  DATA: lt_delta_cells   TYPE lvc_t_modi,
        ls_delta_cells   TYPE lvc_s_modi,
        ls_modified      TYPE char01,
        ls_frontend_only TYPE char01,
        lt_msg           TYPE lvc_t_msg1.

  READ TABLE gt_out WITH KEY chk = 'X'.

  CHECK sy-subrc = 0.

  ls_delta_cells-row_id    = sy-tabix.
  ls_delta_cells-fieldname = 'CHK'.
  ls_delta_cells-value     = ''.
  APPEND ls_delta_cells TO lt_delta_cells.

  CALL METHOD grid1->change_data_from_inside
    EXPORTING
      it_style_cells = lt_delta_cells
    IMPORTING
      et_bad_cells   = lt_delta_cells
      et_msg         = lt_msg.

ENDFORM.                    " deselect_process
*&---------------------------------------------------------------------*
*&      Form  CHK_DESELECT
*&---------------------------------------------------------------------*
FORM chk_deselect .

  LOOP AT gt_out WHERE chk = 'X'.
    gt_out-chk = ' '.
    gt_out-fg  = ' '.
    MODIFY gt_out INDEX sy-tabix.
  ENDLOOP.

ENDFORM.                    " CHK_DESELECT
*&---------------------------------------------------------------------*
*&      Form  MA_DATA_GET
*&---------------------------------------------------------------------*
FORM ma_data_get .
* 통문유형 SETTING
  REFRESH i_ivtyp.  CLEAR i_ivtyp.
  IF p_gubun1 = '2'.
    PERFORM iv_type_setting USING 'I' 'EQ' 'D01'.  "폐기
  ELSEIF p_gubun1 = '3'.
    PERFORM iv_type_setting USING 'I' 'EQ' 'D02'.  "매각
  ELSE.
    PERFORM iv_type_setting USING 'I' 'EQ' 'D01'.  "폐기
    PERFORM iv_type_setting USING 'I' 'EQ' 'D02'.  "매각
  ENDIF.

* 자재문서 Header/Detail 에서 조건에 맞는 Data 발췌
  SELECT a~iv_type a~iv_no b~mblnr b~zeile b~matnr
         b~mtr_unit b~lfimg a~truck_no a~werks b~mjahr
         a~out_yn a~bwart a~driver_nm a~driver_telno a~etc_nm
         a~pernr a~ename " CHM2008-00227 추가
         INTO CORRESPONDING FIELDS OF TABLE gt_out
         FROM ZGTMMT4500 AS a INNER JOIN ZGTMMT4501 AS b
              ON a~iv_no = b~iv_no
        WHERE a~iv_no    IN  i_ivno
          AND a~iv_date  IN  i_date
          AND a~iv_type  IN  i_ivtyp
          AND a~werks    = P_WERKS
          AND b~matnr    IN  i_matnr
          AND a~iv_cancel_yn <> 'X'.

  LOOP AT gt_out.
*   차량번호 입력시
    IF i_truno <> ' '.
      IF i_truno <> gt_out-truck_no.
        DELETE gt_out INDEX sy-tabix.
        CONTINUE.
      ENDIF.
    ENDIF.
*   업체코드 입력시
    CLEAR zmmt0016.
    IF gt_out-iv_type = 'D02'.                   "매각
      SELECT SINGLE a~kunnr b~waers b~netpr b~dmbtr a~bukrs
        FROM zmmt0016 AS a INNER JOIN zmmt0017 AS b ON b~docno = a~docno
        INTO (gt_out-kunnr, gt_out-waers, gt_out-netpr, gt_out-dmbtr,
              gt_out-bukrs)
        WHERE a~docno  EQ gt_out-mblnr
          AND a~kunnr  IN i_lifnr
          AND b~posnr  EQ gt_out-zeile.
*      GT_OUT-KUNNR = ZMMT0016-KUNNR.
    ELSE.                                        "폐기
      SELECT SINGLE a~lifnr b~waers b~netpr b~dmbtr a~bukrs
        FROM zmmt0016 AS a INNER JOIN zmmt0017 AS b ON b~docno = a~docno
        INTO (gt_out-lifnr, gt_out-waers, gt_out-netpr, gt_out-dmbtr,
              gt_out-bukrs)
        WHERE a~docno  EQ gt_out-mblnr
*          AND a~branch IN i_branch
          AND a~lifnr  IN i_lifnr
          AND b~posnr  EQ gt_out-zeile.
*      GT_OUT-LIFNR = ZMMT0016-LIFNR.
    ENDIF.
*    IF SY-SUBRC <> 0.
*      DELETE GT_OUT INDEX SY-TABIX.
*      CONTINUE.
*    ENDIF.
*   자재 품명:규격
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = gt_out-matnr
      IMPORTING
        output = gt_out-matnr.

    SELECT SINGLE maktx INTO gt_out-maktx FROM zmmt0019
                       WHERE bukrs = gt_out-bukrs
                         AND matnr = gt_out-matnr.
*   통문유형별 Description
    IF gt_out-iv_type = 'D02'.
      gt_out-iv_tdes = '매각'.
    ELSEIF gt_out-iv_type = 'D01'.
      gt_out-iv_tdes = '폐기'.
    ENDIF.
*   통문유무
    IF gt_out-out_yn = 'X'.
      gt_out-out_yn = 'Y'.
    ELSE.
      gt_out-out_yn = 'N'.
    ENDIF.

* [START] CSR NO : C20070810_14860

* MRP 관리자 입력 시
    IF i_dispo <> ' '.
      CLEAR marc.
      SELECT SINGLE * FROM marc
       WHERE matnr EQ gt_out-matnr
         AND werks EQ gt_out-werks
         AND dispo EQ i_dispo.
      IF sy-subrc <> 0.
        DELETE gt_out INDEX sy-tabix.
        CONTINUE.
      ENDIF.
    ENDIF.
* [END]   CSR NO : C20070810_14860

    MODIFY gt_out INDEX sy-tabix.
  ENDLOOP.
*
  DESCRIBE TABLE gt_out LINES sy-tfill.
  IF sy-tfill = 0.
    MESSAGE s005(zle1) WITH '조건에 맞는 DATA가 없습니다'.
    IF sy-dynnr = '1000'.
      STOP.
    ELSE.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
*  SORT GT_OUT BY IV_TYPE IV_NO MBLNR ZEILE.
ENDFORM.                    " MA_DATA_GET
*&---------------------------------------------------------------------*
*&      Form  SCREEN_FIELD_CHANG
*&---------------------------------------------------------------------*
FORM screen_field_chang .

  LOOP AT SCREEN.
    IF screen-group1 = 'M1'.
      IF p_bukrs IS INITIAL.
        screen-input = 0.
        p_gubun1 = ''.
      ELSE.
        screen-input = 1.
*        p_gubun1 = '2'.
      ENDIF.
    ELSEIF screen-group1 = 'M2' AND p_bzarea IS INITIAL.
      screen-input = 0.
      CLEAR: P_WERKS.
*    ELSEIF screen-name = 'R4' AND p_bukrs = '1000'.
*      screen-input = 0.
*      IF r4 = 'X'.
*        r1 = 'X'.
*        r4 = ''.
*      ENDIF.
    ELSE.
      IF r2 = 'X'.
        IF screen-name = 'I_WERKS-LOW' OR
           screen-name = 'I_WERKS-HIGH'.
          screen-input = 0.
        ENDIF.
      ELSE.
        IF screen-name = 'I_BRANCH-LOW' OR
           screen-name = 'I_BRANCH-HIGH'.
          screen-input = 0.
        ENDIF.
      ENDIF.
    ENDIF.
*    IF SCREEN-NAME = 'R3'.
*      SCREEN-ACTIVE = 0.
*    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " SCREEN_FIELD_CHANG
*&---------------------------------------------------------------------*
*&      Form  PP_DATA_GET
*&---------------------------------------------------------------------*
FORM pp_data_get .

** 통문유형 SETTING
*  REFRESH i_ivtyp.  CLEAR i_ivtyp.
*  IF p_gubun1 = '2'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '541'.  "무상사급
*  ELSEIF p_gubun1 = '3'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '122'.  "불량반품
*  ELSEIF p_gubun1 = '4'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '161'.  "반품
*  ELSEIF p_gubun1 = '5'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '351'.  "공장간 이체
*  ELSE.
*    PERFORM iv_type_setting USING 'I' 'EQ' '541'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '122'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '161'.
*    PERFORM iv_type_setting USING 'I' 'EQ' '351'.
*  ENDIF.

*/ 사업장
  CLEAR: r_werks[], r_werks.
  SELECT * FROM zlet0034 WHERE bzarea = p_bzarea.
    r_werks-sign   = 'I'.
    r_werks-option = 'EQ'.
    r_werks-low    = zlet0034-werks.
    APPEND r_werks.
  ENDSELECT.

*/ 이동유형
  REFRESH i_ivtyp.  CLEAR i_ivtyp.
*{ 기능개선 273305 - 변경
  IF p_gubun1 = '1'.
    LOOP AT lt_values WHERE key <> p_gubun1.
      i_ivtyp-sign   = 'I'.
      i_ivtyp-option = 'EQ'.
      i_ivtyp-low    = lt_values-text(3).
      APPEND i_ivtyp.
    ENDLOOP.
  ELSE.
    LOOP AT lt_values WHERE key = p_gubun1.
      i_ivtyp-sign   = 'I'.
      i_ivtyp-option = 'EQ'.
      i_ivtyp-low    = lt_values-text(3).
      APPEND i_ivtyp.
    ENDLOOP.
  ENDIF.

*  IF P_GUBUN1 = '1'.
*    SELECT * FROM ZLET0007 WHERE IV_TYPE LIKE 'B__'
*                             AND MDULE   = 'MMPP'.
*      I_IVTYP-SIGN   = 'I'.
*      I_IVTYP-OPTION = 'EQ'.
*      I_IVTYP-LOW    = ZLET0007-BWART.
*      APPEND I_IVTYP.
*    ENDSELECT.
*  ELSE.
*    LOOP AT LT_VALUES WHERE KEY = P_GUBUN1.
*      SELECT SINGLE * FROM ZLET0007
*        WHERE IV_TYPE = LT_VALUES-TEXT+0(3).
*      IF SY-SUBRC = 0.
*        I_IVTYP-SIGN   = 'I'.
*        I_IVTYP-OPTION = 'EQ'.
*        I_IVTYP-LOW    = ZLET0007-BWART.
*        APPEND I_IVTYP.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*} 기능개선 273305 - 변경

* 자재문서 Header/Detail 에서 조건에 맞는 Data 발췌
  SELECT a~iv_type a~iv_no b~mblnr b~zeile b~matnr
         b~mtr_unit b~lfimg a~truck_no a~werks b~mjahr
         a~out_yn a~bwart a~driver_nm a~driver_telno a~etc_nm
         b~charg
         a~pernr a~ename " CHM2008-00227 추가
         INTO CORRESPONDING FIELDS OF TABLE gt_tab
         FROM ZGTMMT4500 AS a INNER JOIN ZGTMMT4501 AS b
              ON a~iv_no = b~iv_no
        WHERE a~iv_no    IN  i_ivno
          AND a~iv_date  IN  i_date
*{ 기능개선 281134-S
*          AND A~BWART    IN  I_IVTYP"주석처리
           AND iv_type IN i_ivtyp
*} 기능개선 281134-E
          AND a~werks    = P_WERKS
          AND a~werks    IN  r_werks
          AND b~matnr    IN  i_matnr
          AND a~iv_cancel_yn <> 'X'.

*{ SRM2401-14519 - 추가_S
*___ZPPT0019 테이블의 데이터와 비교하기 위해 임시 Internal Table에
*   자재문서/자재/배치/수량/사용여부를 저장
  CLEAR   : gt_mdoc.
  REFRESH : gt_mdoc.

  LOOP AT gt_tab.
    CLEAR : gt_mdoc.

    MOVE-CORRESPONDING gt_tab TO gt_mdoc.

    APPEND gt_mdoc.
  ENDLOOP.

  SORT gt_mdoc BY mblnr matnr charg menge zeile.
*} SRM2401-14519 - 추가_E

*/ 2005.07.01 BY SDC08 - PP 김주원 C 요청
  LOOP AT gt_tab.
*   PP 거래명세서
    IF gt_tab-iv_no+0(1) <> '7'.
      DELETE gt_tab. CONTINUE.
    ENDIF.
*   차량번호 입력시
    IF i_truno <> ' '.
      IF i_truno <> gt_tab-truck_no.
        DELETE gt_tab INDEX sy-tabix.
        CONTINUE.
      ENDIF.
    ENDIF.
*   업체코드 입력시
    CLEAR mseg.
    SELECT SINGLE * FROM mseg WHERE mblnr EQ gt_tab-mblnr
                                AND zeile EQ gt_tab-zeile
                                AND mjahr EQ gt_tab-mjahr
                                AND lifnr IN i_lifnr.
    IF sy-subrc <> 0.
      DELETE gt_tab INDEX sy-tabix.
      CONTINUE.
    ENDIF.

    gt_tab-umwrk = mseg-umwrk.
    gt_tab-lifnr = mseg-lifnr.

* [START] CSR NO : C20070810_14860
* MRP 관리자 입력 시
    IF i_dispo <> ' '.
      CLEAR marc.
      SELECT SINGLE * FROM marc
       WHERE matnr EQ gt_tab-matnr
         AND werks EQ gt_tab-werks
         AND dispo EQ i_dispo.
      IF sy-subrc <> 0.
        DELETE gt_tab INDEX sy-tabix.
        CONTINUE.
      ENDIF.
    ENDIF.
* [END]   CSR NO : C20070810_14860

    SELECT SINGLE dispo INTO marc-dispo FROM marc
                       WHERE matnr = gt_tab-matnr
                         AND werks = gt_tab-werks.
    IF marc-dispo+0(2) = 'CN' OR marc-dispo+0(2) = 'IR' OR
       marc-dispo+0(2) = 'LF' OR marc-dispo+0(2) = 'PS' OR
       marc-dispo+0(2) = 'BD' OR marc-dispo+0(2) = 'CF' OR
       marc-dispo+0(2) = 'HS' OR marc-dispo+0(2) = 'AL' OR
       marc-dispo+0(2) = 'PA' OR marc-dispo+0(2) = 'AP' OR "부품산업
       gt_tab-bwart = '122'.

      MOVE-CORRESPONDING gt_tab TO gt_out.
*      gt_out-tagnr = zppt0019-tagnr.
*      gt_out-ebeln = zppt0019-ebeln.
*      SELECT SINGLE iv_type_nm iv_type
*        INTO (gt_out-bwtxt, gt_out-ivtyp)
*        FROM zlet0007
*       WHERE bwart = gt_tab-bwart.

*   자재 품명:규격
      SELECT SINGLE maktx INTO gt_out-maktx FROM makt
                         WHERE matnr EQ gt_tab-matnr
                           AND spras EQ '3'.
*    SELECT SINGLE name1 INTO gt_out-name1 FROM lfa1
*                       WHERE lifnr = gt_out-lifnr.
      APPEND gt_out.  CLEAR gt_out.

    ELSE.
*   PP 꼬리표/구매오더 가져오는 로직
      IF gt_tab-bwart = '351'.
        PERFORM get_data_pp_351.
      ELSE.
        PERFORM get_data_pp_etc.
      ENDIF.
    ENDIF.

******************************************
**   꼬리표, 구매전표
**    IF gt_out-bwart = '351'.
*    IF gt_tab-bwart = '351'.
*      PERFORM get_data_pp_351.
*    ELSE.
*      PERFORM get_data_pp_etc.
*    ENDIF.
  ENDLOOP.
*
  DESCRIBE TABLE gt_out LINES sy-tfill.
  IF sy-tfill = 0.
    MESSAGE s005(zle1) WITH '조건에 맞는 DATA가 없습니다'.
    IF sy-dynnr = '1000'.
      STOP.
    ELSE.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.

  SORT gt_out BY  mblnr zeile.


*************************************************
*  LOOP AT gt_out.
**   PP 거래명세서
*    IF gt_out-iv_no+0(1) <> '7'.
*      DELETE gt_out. CONTINUE.
*    ENDIF.
**   차량번호 입력시
*    IF i_truno <> ' '.
*      IF i_truno <> gt_out-truck_no.
*        DELETE gt_out INDEX sy-tabix.
*        CONTINUE.
*      ENDIF.
*    ENDIF.
**   업체코드 입력시
*    CLEAR mseg.
*    SELECT SINGLE * FROM mseg WHERE mblnr EQ gt_out-mblnr
*                                AND zeile EQ gt_out-zeile
*                                AND mjahr EQ gt_out-mjahr
*                                AND lifnr IN i_lifnr.
*    IF sy-subrc <> 0.
*      DELETE gt_out INDEX sy-tabix.
*      CONTINUE.
*    ENDIF.
**
*    gt_out-lifnr = mseg-lifnr.
**   자재 품명:규격
*    SELECT SINGLE maktx INTO gt_out-maktx FROM makt
*                       WHERE matnr = gt_out-matnr
*                         AND spras = '3'.
**   통문유형별 Description
*    SELECT SINGLE iv_type_nm INTO gt_out-iv_tdes FROM zlet0007
*                            WHERE iv_type EQ gt_out-iv_type.
**   꼬리표, 구매전표
**    IF gt_out-bwart = '351'.
*     IF gt_out-bwart <> '351'.
*      CLEAR zppt0018.
*      SELECT SINGLE * FROM zppt0018 WHERE mblnr = gt_out-mblnr
*                                      AND ebeln = mseg-ebeln.
*      gt_out-ebeln  = zppt0018-ebeln.
*      gt_out-tagnr  = zppt0018-tagnr.
*    ELSE.
*      CLEAR zppt0019.
*      SELECT SINGLE * FROM zppt0019 WHERE mblnr = gt_out-mblnr
*                                      AND ebeln = mseg-ebeln.
*      gt_out-ebeln  = zppt0019-ebeln.
*      gt_out-tagnr  = zppt0019-tagnr.
*    ENDIF.
**   통문유무
*    IF gt_out-out_yn = 'X'.
*      gt_out-out_yn = 'Y'.
*    ELSE.
*      gt_out-out_yn = 'N'.
*    ENDIF.
*    MODIFY gt_out INDEX sy-tabix.
*  ENDLOOP.
**
*  DESCRIBE TABLE gt_out LINES sy-tfill.
*  IF sy-tfill = 0.
*    MESSAGE s005(zle1) WITH '조건에 맞는 DATA가 없습니다'.
*    IF sy-dynnr = '1000'.
*      STOP.
*    ELSE.
*      LEAVE TO SCREEN 0.
*    ENDIF.
*  ENDIF.
**  SORT GT_OUT BY IV_TYPE IV_NO MBLNR ZEILE.
ENDFORM.                    " PP_DATA_GET
*&---------------------------------------------------------------------*
*&      Form  TONGMOON_REPRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tongmoon_reprint .

  REFRESH gt_out_t.  CLEAR: gt_out_t.
  LOOP AT gt_out WHERE chk = 'X'.
    IF gt_out-cancelled = 'X'.
      MESSAGE e004(zle1) WITH '자재문서 취소로 재발행 불가. 문서번호:'
                              gt_out-iv_no.

      RETURN.
    ENDIF.

    MOVE-CORRESPONDING  gt_out TO gt_out_t.
    APPEND gt_out_t.  CLEAR gt_out_t.
  ENDLOOP.
*
  DESCRIBE TABLE gt_out_t LINES sy-tfill.
  IF sy-tfill = 0.
    MESSAGE s005(zle1) WITH 'DATA를 선택하세요!'.
    EXIT.
  ENDIF.
*
  SORT gt_out_t BY iv_no mblnr zeile.
  REFRESH: otf, gt_out_s.
  CLEAR: otf, lv_ivno, lv_ivtyp, lv_werks, gt_out_s.
  LOOP AT gt_out_t.
    CLEAR: lv_umwrk, lv_kunnr, lv_lifnr.

    MOVE-CORRESPONDING gt_out_t TO gt_out_s.
    APPEND gt_out_s. CLEAR gt_out_s.
    lv_ivno  = gt_out_t-iv_no.
    lv_ivtyp = gt_out_t-iv_type.
    lv_werks = gt_out_t-werks.
    lv_umwrk = gt_out_t-umwrk.
    lv_lifnr = gt_out_t-lifnr.
    lv_kunnr = gt_out_t-kunnr.
    lv_truck = gt_out_t-truck_no.
    lv_drnam = gt_out_t-driver_nm.
    lv_drnum = gt_out_t-driver_telno.
    lv_etc_nm = gt_out_t-etc_nm.
    lv_tonno = gt_out_t-ton_no.
    lv_pernr = gt_out_t-pernr."CHM2008-00227
    lv_ename = gt_out_t-ename."CHM2008-00227
*-{기능개선110094 -플랜트 3402(전자부품) 자재별 합계시 자재문서 무시하고
* Collect 되도록 처리, 기존 자재문서별 합계 -> 자재별 합계
    IF p_prtchk = 'X'.
      lv_mblnr = ' '.
    ELSE.
      lv_mblnr = gt_out_t-mblnr.
    ENDIF.
*-}기능개선110094_2016.01.11
    lv_mjahr = gt_out_t-mjahr.
    gv_bukrs = gt_out_t-bukrs.

    AT END OF iv_no.
      lv_flag = 'X'.
    ENDAT.
*
    IF lv_flag = 'X'.
*     통문증 Header
      PERFORM sm_header USING lv_ivno lv_ivtyp lv_werks
                              lv_lifnr lv_kunnr lv_umwrk
                              lv_mblnr lv_mjahr.
*     통문증 Middle
      PERFORM sm_middle USING lv_truck lv_drnam lv_drnum
                                                     lv_pernr lv_ename.
*     통문증 Detail
      PERFORM sm_detail.
*     smart forms
      PERFORM smart_form_setting.

      REFRESH: gt_out_s.  CLEAR: gt_out_s, lv_flag.
    ENDIF.
  ENDLOOP.
  PERFORM smart_form_finall_write .

ENDFORM.                    " TONGMOON_REPRINT
*&---------------------------------------------------------------------*
*&      Form  SM_HEADER
*&---------------------------------------------------------------------*
FORM sm_header  USING    p_ivno p_ivtyp  p_werks
                         p_lifnr p_kunnr p_umwrk
                         p_mblnr p_mjahr.
  DATA : ls_out LIKE LINE OF gt_out OCCURS 0   WITH HEADER LINE.
  REFRESH: lv_sm01.
  CLEAR: lv_sm01.
*
  DESCRIBE TABLE gt_out_s LINES sy-tfill.
  mok = sy-tfill DIV 10.
  nam = sy-tfill MOD 10.
  IF NOT nam IS INITIAL.
    lv_sm01-totnt = mok + 1.
  ELSE.
    lv_sm01-totnt = mok.
  ENDIF.
  CONDENSE lv_sm01-totnt.
* 회사주소
  CLEAR t001w.

  IF lv_ivtyp = 'D01' OR lv_ivtyp = 'D02'.
  ELSE.
    SELECT SINGLE * FROM t001w WHERE werks = p_werks.
    IF t001w-ort01 CO t001w-stras.
      IF sy-fdpos <> 0.
        lv_sm01-wname = t001w-stras.
      ENDIF.
    ELSE.
      CONCATENATE t001w-ort01 ' ' t001w-stras
      INTO lv_sm01-wname SEPARATED BY space.
    ENDIF.
  ENDIF.

* 회사명
*  LV_SM01-COMPA = 'LS전선(주)'.
* 회사명
*  IF p_werks+0(1) = '2'.
*   IF P_BZAREA+0(1) = 'J'.
*    lv_sm01-compa = 'JS전선(주)'.
*    lv_sm01-ceonm = '대표이사 황순철'.
*  ELSE.
* 매각폐기인지 / 대표이사도 0015와 동일하게
* [법인분리] 법인분리로 인한 대표자 성명 및 회사코드 셋팅
*  CLEAR : GV_BUKRS.

*-{자체개선 45041 - 추가
  IF r2 = 'X'.
    IF gv_bukrs IS INITIAL.
      LOOP AT gt_out_t.
        SELECT SINGLE bukrs
          INTO gv_bukrs
          FROM t001k
         WHERE bwkey = gt_out_t-werks.

        IF sy-subrc = 0.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.
    CLEAR : gv_bukrs.
    SELECT SINGLE bukrs
      INTO gv_bukrs
      FROM matdoc
     WHERE mblnr = p_mblnr.
  ENDIF.


  SELECT SINGLE repres
                kr_butxt
    INTO (lv_sm01-ceonm, lv_sm01-compa)
    FROM zlet0122
   WHERE werks = p_werks.

  IF lv_sm01-ceonm IS INITIAL AND sy-subrc <> 0.
    SELECT SINGLE repres
                  kr_butxt
      INTO (lv_sm01-ceonm, lv_sm01-compa)
      FROM zlet0120
     WHERE bukrs  = gv_bukrs
       AND zmodul = 'LE'.
  ENDIF.

  CONCATENATE '대표이사' lv_sm01-ceonm
         INTO lv_sm01-ceonm SEPARATED BY space.

*  IF GV_BUKRS = '3000'.
*    LV_SM01-COMPA = 'LS엠트론(주)'.
*    LV_SM01-CEONM = '대표이사 심재설'.
*  ELSE.
*    LV_SM01-COMPA = 'LS전선(주)'.
*    LV_SM01-CEONM = '대표이사 구자은'.
*  ENDIF.
*-{자체개선 45041- LS엠트론 회사명 오류 수정 2014.09.19

* 회사 전화번호
  SELECT SINGLE * FROM zlet0034 WHERE werks = p_werks.
  lv_sm01-cotel = zlet0034-telno.

************** inserted by mmb03 ****************************

* 20061211 Bon-Chan Koo 수정
* 저장위치간 이동(이동유형 Y31)에 의해 자재출고 및 통문 발생시
* "공급받는자" 항목에 관련 CS조직의 정보가 기록될 수 있도록 변경
********처리로직********
* 1) Y31이동유형 발생
* 2) PLANT CODE 및 STORAGE LOCATION 확인
* 3) CBO TABLE ZSMT0068에 해당 등록 내역 및 주소/인수자 정보를
*    읽어와서 출력
  IF lv_ivtyp = 'B15'.  "저장위치간 이동(이동유형 Y31)

    DATA : l_lgort LIKE mseg-lgort.
    CLEAR l_lgort.

    SELECT SINGLE lgort INTO l_lgort
    FROM   mseg
    WHERE  mblnr = gt_out_t-mblnr
    AND    mjahr = gt_out_t-mjahr
    AND    shkzg = 'S'.
*    AND    zeile = gt_out_t-zeile.

    IF sy-subrc = 0.
      SELECT SINGLE name1 waemp addr ztibornm
        INTO (lv_sm01-gname, lv_sm01-rname,
              lv_sm01-raddr, lv_sm01-ruser)
      FROM   zsmt0068
      WHERE  werks =  p_werks
      AND    lgort =  l_lgort.
    ENDIF.

  ELSEIF lv_ivtyp = 'B11'.  "SM오더 출고(이동유형 Y91)

    DATA : lv_aufnr  LIKE mseg-aufnr.
    DATA : lv_equnr  LIKE afih-equnr.
    DATA : lv_objnr  LIKE equi-objnr.
    DATA : lv_parnr  LIKE ihpa-parnr.
    DATA : lv_city2  LIKE adrc-city1.
    DATA : lv_stre2  LIKE adrc-street.
* [START] CSR NO : C20071015_50616
    DATA : lv_vaplz  LIKE aufk-vaplz.
    DATA : lv_umlgo  LIKE zsmt0070-lgort.
* [END]   CSR NO : C20071015_50616
    CLEAR: lv_city2, lv_stre2.

    SELECT SINGLE aufnr
    INTO   lv_aufnr
    FROM   mseg
    WHERE  mblnr = gt_out_t-mblnr
    AND    mjahr = gt_out_t-mjahr.

    IF sy-subrc = 0.

      SELECT SINGLE equnr
      INTO   lv_equnr
      FROM   afih
      WHERE  aufnr = lv_aufnr.

      IF lv_equnr IS NOT INITIAL.

        SELECT SINGLE objnr
        INTO   lv_objnr
        FROM   equi
        WHERE  equnr = lv_equnr.

        IF sy-subrc = 0.

          SELECT SINGLE parnr
          INTO   lv_parnr
          FROM   ihpa
          WHERE  objnr = lv_objnr
          AND    parvw = 'AG'
          AND    kzloesch <> 'X'.

          IF lv_parnr IS NOT INITIAL.

            SELECT SINGLE name1 ort01 stras
            INTO   (lv_sm01-rname, lv_city2, lv_stre2)
            FROM   kna1
            WHERE  kunnr = lv_parnr.

            lv_sm01-gname = lv_sm01-rname . "상호

            CONCATENATE lv_city2 '' lv_stre2
            INTO lv_sm01-raddr SEPARATED BY space.

          ELSE.

            SELECT SINGLE parnr
            INTO   lv_parnr
            FROM   ihpa
            WHERE  objnr = lv_objnr
            AND    parvw = 'Y2'
            AND    kzloesch <> 'X'.

            IF sy-subrc = 0.

              SELECT SINGLE name1 ort01 stras
              INTO   (lv_sm01-rname, lv_city2, lv_stre2)
              FROM   kna1
              WHERE  kunnr = lv_parnr.

              lv_sm01-gname = lv_sm01-rname . "상호

              CONCATENATE lv_city2 '' lv_stre2
              INTO lv_sm01-raddr SEPARATED BY space.

            ENDIF.

          ENDIF.

* [START] CSR NO : C20071015_50616
          IF p_bzarea <> '5100'.
            SELECT SINGLE vaplz
            INTO   lv_vaplz
            FROM   aufk
            WHERE  aufnr = lv_aufnr.

            IF sy-subrc = 0.
              DATA: lv_rname LIKE zles014-rname.
              DATA: lv_raddr LIKE zles014-raddr.
              DATA: lv_ruser LIKE zles014-ruser.

              SELECT SINGLE lgort INTO lv_umlgo
              FROM   zsmt0070
              WHERE  arbpl = lv_vaplz.

              SELECT SINGLE name1 addr ztibornm
              INTO   (lv_rname,lv_raddr,lv_ruser)
              FROM   zsmt0068
              WHERE  werks = p_werks
              AND    lgort = lv_umlgo
              AND    flag  = 'Y'.

              IF sy-subrc = 0.
                lv_sm01-rname = lv_rname.
                lv_sm01-raddr = lv_raddr.
                lv_sm01-ruser = lv_ruser.
                lv_sm01-gname = lv_rname. "상호
              ELSE.
              ENDIF.
            ELSE.
            ENDIF.
          ENDIF.
* [END]   CSR NO : C20071015_50616
        ENDIF.

      ELSE.

      ENDIF.

    ENDIF.

*스크랩 출고일 경우 공급자 정보 가져오기 07.01.31
  ELSEIF lv_ivtyp = 'B10'.
    SELECT  SINGLE kunnr
      INTO  p_kunnr
      FROM  zmmt0099
     WHERE  mblnr = p_mblnr
       AND  mjahr = p_mjahr.

    SELECT  SINGLE name1 ort01 stras
      INTO (lv_sm01-rname, lv_city2, lv_stre2)
      FROM  kna1
     WHERE  kunnr = p_kunnr.

    lv_sm01-gname = lv_sm01-rname . "상호

    CONCATENATE lv_city2 '' lv_stre2
           INTO lv_sm01-raddr SEPARATED BY space.

  ELSEIF lv_ivtyp = 'B13' OR
         lv_ivtyp = 'B14' .  "SM오더 출고(이동유형 Y93).

*    LV_SM01-GNAME = GV_GNAME.
*    LV_SM01-RNAME = GV_RNAME.
*    LV_SM01-RADDR = GV_RADDR.
*    LV_SM01-RUSER = GV_RUSER.

*[START] CSR NUMBER : C20110518_86311
* 트랙터 공장이체간일경우
  ELSEIF lv_ivtyp = 'B17'.
    SELECT SINGLE b~umwrk
      INTO lv_sm01-rname
      FROM ZGTMMT4501 AS a
     INNER JOIN mseg AS b
        ON a~mblnr = b~mblnr
       AND a~mjahr = b~mjahr
       AND a~zeile = b~zeile
     WHERE a~iv_no = p_ivno.

    SELECT SINGLE name1
                  bzarea_t
    INTO   (lv_sm01-gname, lv_sm01-raddr)
    FROM   zlet0034
    WHERE  werks = lv_sm01-rname.
*    LV_SM01-GNAME = '1'.
*    LV_SM01-RNAME = '2'.
*    LV_SM01-RADDR = '3'.
*    LV_SM01-RUSER = '4'.
*[END]   CSR NUMBER : C20110518_86311

  ELSE. "그 외의 이동유형 일 경우 기존 로직 수행

    DATA: lv_city1  LIKE adrc-city1,
          lv_street LIKE adrc-street.
    CLEAR: lv_city1, lv_street.

    IF NOT lv_lifnr IS INITIAL.
      SELECT SINGLE name1 ort01 stras
       INTO (lv_sm01-rname, lv_city1, lv_street)  FROM lfa1
        WHERE lifnr = p_lifnr.
    ENDIF.

    IF NOT lv_kunnr IS INITIAL.
      SELECT SINGLE name1 ort01 stras
       INTO (lv_sm01-rname, lv_city1, lv_street)  FROM kna1
        WHERE kunnr = p_kunnr.
    ENDIF.

    IF NOT lv_umwrk IS INITIAL.
      SELECT SINGLE name1 ort01 stras
       INTO (lv_sm01-rname, lv_city1, lv_street)  FROM t001w
        WHERE werks = p_umwrk.
    ENDIF.

    lv_sm01-gname = lv_sm01-rname . "상호

    CONCATENATE lv_city1 '' lv_street
       INTO lv_sm01-raddr SEPARATED BY space.

  ENDIF.
* 20061211 수정종료



*************************************************************
************** deleted by mmb03 ******************************
** 상호
*  SELECT SINGLE name1 INTO lv_sm01-gname FROM lfa1
*  WHERE lifnr = p_lifnr.
*
*
*  IF p_ivtyp = 'D02'.
**    매각일때는 거래처가 -> KUNNR
*    SELECT SINGLE * FROM kna1 WHERE kunnr EQ p_lifnr.
*    lv_sm01-rname = kna1-name1.
*    CONCATENATE kna1-ort01 '' kna1-stras
*                              INTO lv_sm01-raddr SEPARATED BY space.
*  ELSEIF p_ivtyp = 'B04'.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*      EXPORTING
*        input  = p_umwrk  "p_lifnr
*      IMPORTING
*        output = p_umwrk. "p_lifnr.
*    CLEAR t001w.
*    SELECT SINGLE * FROM t001w WHERE werks EQ p_umwrk.  "p_lifnr.
*    lv_sm01-rname = t001w-name1.
*    CONCATENATE t001w-ort01 '' t001w-stras
*                               INTO lv_sm01-raddr SEPARATED BY space.
*
*    lv_sm01-gname = 'LS전선(주)'.
*  ELSE.
**    폐기, MM 전체, PP
*    SELECT SINGLE * FROM lfa1 WHERE lifnr EQ p_lifnr.
*    lv_sm01-rname = lfa1-name1.
*    CONCATENATE lfa1-ort01 '' lfa1-stras
*                               INTO lv_sm01-raddr SEPARATED BY space.
*  ENDIF.
************************************************************************

*___통문유형
  SELECT SINGLE iv_type_nm
    INTO lv_sm01-ivtyp
    FROM zgtmmt4511 "zlet0007
   WHERE bukrs = p_bukrs
        AND iv_type = p_ivtyp.

  IF sy-subrc = 0.
    CONCATENATE p_ivtyp lv_sm01-ivtyp
           INTO lv_sm01-ivtyp SEPARATED BY space.
  ENDIF.

*[기능개선 41489 통문증 발행일자 오류 수정 요청 2014.08.28 by.H.M.LIM]
* 엠트론의 경우 발행일자, 출력일자 구분하여 표기
  IF gv_bukrs = '3000'.
    DATA: lv_ivdat TYPE sy-datum,
          lv_ivtim TYPE sy-uzeit.

*   발행일자
    SELECT SINGLE iv_date create_time
      FROM ZGTMMT4500
      INTO (lv_ivdat, lv_ivtim)
      WHERE iv_no = p_ivno.

    WRITE: lv_ivdat TO lv_sm01-ivdat USING EDIT MASK '____년__월__일'.

*{ CHM2008-00227 -S
    lv_sm01-sgdt1 = lv_ivdat.
*} CHM2008-00227 -E

*   출력일자/시간
    WRITE: sy-datum TO lv_sm01-ptdat USING EDIT MASK '____년__월__일',
           sy-uzeit TO lv_sm01-ptdat+15 USING EDIT MASK '__:__'.
  ELSE.
*   발행일자
    WRITE: sy-datum TO lv_sm01-ivdat USING EDIT MASK '____년__월__일'.
  ENDIF.

  lv_sm01-ivnum = p_ivno.

  APPEND lv_sm01.

ENDFORM.                    " SM_HEADER
*&---------------------------------------------------------------------*
*&      Form  SM_MIDDLE
*&---------------------------------------------------------------------*
FORM sm_middle USING  p_truck p_drnam p_drtel
                                          p_pernr p_ename.

  REFRESH: lv_sm02.  CLEAR lv_sm02.
*
  lv_sm02-exti1 = p_truck.
*
  IF p_drnam <> ' ' AND p_drtel <> ' '.
    CONCATENATE p_drnam '(' p_drtel ')' INTO lv_sm02-exti2
                SEPARATED BY space.
  ELSEIF p_drnam <> ' ' AND p_drtel = ' '.
    lv_sm02-exti2 = p_drnam.
  ELSEIF p_drnam = ' ' AND p_drtel <> ' '.
    CONCATENATE '(' p_drtel ')' INTO lv_sm02-exti2
                SEPARATED BY space.
  ENDIF.

*{CHM2008-00227 - S
  IF p_pernr IS NOT INITIAL.
    lv_sm02-pernr = p_pernr.
    lv_sm02-pernm = p_ename.
  ENDIF.
*}CHM2008-00227 - E

  IF lv_tonno = ''.
    lv_sm02-ltext = lv_etc_nm.
  ELSE.
    CONCATENATE lv_tonno '/' lv_etc_nm INTO lv_sm02-ltext.
  ENDIF.

  APPEND lv_sm02.

* 20061211 Bon-Chan Koo 수정 특기사항에 정보추가(서비스오더번호,실행일)
* Y91(CS오더에 의한 출고)이동유형 일 경우 서비스관련 정보를 추가

  DATA : lv_aufnr  LIKE mseg-aufnr,
         lv_aufnr1 LIKE mseg-aufnr,
         lv_gltrs  LIKE afko-gltrs,
         lv_aufpl  LIKE afko-aufpl,
         lv_pernr  LIKE afvc-pernr,
         lv_ename  LIKE zzpa0001-ename.

  REFRESH lv_sm04. CLEAR lv_sm04.

  IF lv_ivtyp = 'B11'.

    SELECT SINGLE aufnr
    INTO   lv_aufnr
    FROM   mseg
    WHERE  mblnr = gt_out_t-mblnr
    AND    mjahr = gt_out_t-mjahr
    AND    zeile = gt_out_t-zeile.

    lv_aufnr1 = lv_aufnr.
    SHIFT  lv_aufnr1  LEFT  DELETING  LEADING  '0'.

    IF sy-subrc = 0.

      SELECT SINGLE gltrs aufpl
      INTO   (lv_gltrs, lv_aufpl)
      FROM   afko
      WHERE  aufnr = lv_aufnr.

      IF sy-subrc = 0.

        SELECT SINGLE pernr
        INTO   lv_pernr
        FROM   afvc
        WHERE  aufpl = lv_aufpl.

        IF sy-subrc = 0.
          SELECT SINGLE ename
          INTO   lv_ename
          FROM   zzpa0001
          WHERE  pernr = lv_pernr
          AND    begda <= sy-datum
          AND    endda >= sy-datum.
        ENDIF.

      ENDIF.

      CONCATENATE 'SVC오더: ' lv_aufnr1
                  '('  lv_ename   ')'
             INTO lv_sm04-ltext.

      CONCATENATE lv_sm04-ltext
                  ' 실행일:' lv_gltrs
             INTO lv_sm04-ltext.

      APPEND lv_sm04.
    ENDIF.

  ENDIF.
* 20061201 수정완료

ENDFORM.                    " SM_MIDDLE
*&---------------------------------------------------------------------*
*&      Form  SM_DETAIL
*&---------------------------------------------------------------------*
FORM sm_detail .
  DATA: BEGIN OF lt_long OCCURS 0,
          text(200),
        END   OF lt_long.

*-{기능개선110094 -플랜트 3402(전자부품) 자재별 합계시 자재문서 무시하고
*자재별 합계일때, Collect / 일반일때 APPEND 분기
  IF p_prtchk = 'X'.
    REFRESH: lv_sm03.  CLEAR: lv_sm03.
    LOOP AT gt_out_s.
      MOVE-CORRESPONDING gt_out_s TO lv_sm03.
      lv_sm03-vrkme = gt_out_s-mtr_unit.
      lv_sm03-mblnr = ' '.
      lv_sm03-zeile = ' '.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = gt_out_s-matnr
        IMPORTING
          output = gt_out_s-matnr.

      CONCATENATE gt_out_s-matnr '(' gt_out_s-maktx ')'
        INTO lv_sm03-maktx.

      CALL FUNCTION 'ZSD_SPLIT_STRING'
        EXPORTING
          i_str   = lv_sm03-maktx
          str_len = 50
        IMPORTING
          o_str   = lv_sm03-maktx
        TABLES
          it_str  = lt_long.

      IF r1 = 'X' AND gt_out_s-iv_type = 'B04'.
        lv_sm03-tagnr = gt_out_s-ebeln.
        lv_sm03-ebeln = gt_out_s-ebelp.
      ELSEIF r1 = 'X' AND gt_out_s-iv_type = 'B20' AND
             gt_out_s-werks = '3602'.
        lv_sm03-tagnr = gt_out_s-charg.
      ENDIF.

      COLLECT lv_sm03. CLEAR lv_sm03.
    ENDLOOP.
  ELSE.

    REFRESH: lv_sm03.  CLEAR: lv_sm03.
    LOOP AT gt_out_s.
      MOVE-CORRESPONDING gt_out_s TO lv_sm03.
      lv_sm03-vrkme = gt_out_s-mtr_unit.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = gt_out_s-matnr
        IMPORTING
          output = gt_out_s-matnr.

      CONCATENATE gt_out_s-matnr '(' gt_out_s-maktx ')'
        INTO lv_sm03-maktx.

      CALL FUNCTION 'ZSD_SPLIT_STRING'
        EXPORTING
          i_str   = lv_sm03-maktx
          str_len = 50
        IMPORTING
          o_str   = lv_sm03-maktx
        TABLES
          it_str  = lt_long.

      IF r1 = 'X' AND gt_out_s-iv_type = 'B04'.
        lv_sm03-tagnr = gt_out_s-ebeln.
        lv_sm03-ebeln = gt_out_s-ebelp.
      ELSEIF r1 = 'X' AND gt_out_s-iv_type = 'B20' AND
             gt_out_s-werks = '3602'.
        lv_sm03-tagnr = gt_out_s-charg.
      ENDIF.

      APPEND lv_sm03. CLEAR lv_sm03.
    ENDLOOP.

  ENDIF.
*-}기능개선110094_2016.01.11

ENDFORM.                    " SM_DETAIL
*&---------------------------------------------------------------------*
*&      Form  SMART_FORM_SETTING
*&---------------------------------------------------------------------*
FORM smart_form_setting .
  DATA: rtab  LIKE kunnr_ran  OCCURS 0 WITH HEADER LINE.
  DATA: ssfcrespd TYPE ssfcrespd,
        ssfcrescl TYPE ssfcrescl,
        ssfcresop TYPE ssfcresop.

*-{자체개선 38665 - 추가
*- 매각/폐기 통문증 양식 추가
*  IF gv_bukrs = '3000'.
*    IF r2 = 'X'.
*      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*        EXPORTING
*          formname           = 'ZM_MM_TRADE_DOCUMENT1'
*        IMPORTING
*          fm_name            = func_name
*        EXCEPTIONS
*          no_form            = 1
*          no_function_module = 2
*          OTHERS             = 3.
*    ELSE.
*      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*        EXPORTING
*          formname           = 'ZM_MM_TRADE_DOCUMENT'
*        IMPORTING
*          fm_name            = func_name
*        EXCEPTIONS
*          no_form            = 1
*          no_function_module = 2
*          OTHERS             = 3.
*    ENDIF.
*  ELSE.
    IF r2 = 'X'.
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          FORMNAME           = 'ZM_MM_GO_TRADE_DOCUMENT1'
        IMPORTING
          FM_NAME            = FUNC_NAME
        EXCEPTIONS
          NO_FORM            = 1
          NO_FUNCTION_MODULE = 2
          OTHERS             = 3.

    ELSE.
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          FORMNAME         = 'ZM_MM_GO_TRADE_DOCUMENT'
        IMPORTING
          FM_NAME            = FUNC_NAME
        EXCEPTIONS
          NO_FORM            = 1
          NO_FUNCTION_MODULE = 2
          OTHERS             = 3.
*      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*        EXPORTING
*          formname           = 'Z_MM_TRADE_DOCUMENT1'
*        IMPORTING
*          fm_name            = func_name
*        EXCEPTIONS
*          no_form            = 1
*          no_function_module = 2
*          OTHERS             = 3.
*    ELSE.
*      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*        EXPORTING
*          formname           = 'Z_MM_TRADE_DOCUMENT'
*        IMPORTING
*          fm_name            = func_name
*        EXCEPTIONS
*          no_form            = 1
*          no_function_module = 2
*          OTHERS             = 3.
    ENDIF.
*  ENDIF.
*-}자체개선 38665 - 추가

  control_parameters-getotf = 'X'.
  control_parameters-no_dialog = 'X'.
** control_parameters-no_close = 'X'.
** control_parameters-getotf = 'X'.
*  CONTROL_PARAMETERS-PREVIEW = 'X'.
*  OUTPUT_OPTIONS-TDDEST = 'ZP01'.
** OUTPUT_OPTIONS-TDPRINTER = 'ZP01'.
*
*  OUTPUT_OPTIONS-TDIMMED = 'X'.
*  OUTPUT_OPTIONS-TDDELETE = 'X'.

  CLEAR ssfcrescl.
  CALL FUNCTION func_name
    EXPORTING
      control_parameters   = control_parameters
      output_options       = output_options
      user_settings        = ' '
      lv_sm01              = lv_sm01
      lv_sm02              = lv_sm02
    IMPORTING
      document_output_info = ssfcrespd
      job_output_info      = ssfcrescl
      job_output_options   = ssfcresop
    TABLES
      lv_sm03              = lv_sm03
      lv_sm04              = lv_sm04
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  INSERT LINES OF ssfcrescl-otfdata INTO TABLE otf.

ENDFORM.                    " SMART_FORM_SETTING
*&---------------------------------------------------------------------*
*&      Form  SMART_FORM_FINALL_WRITE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM smart_form_finall_write .
  DATA: ssfpp                TYPE ssfpp,
        arc_params           TYPE arc_params,
        spool_job_attributes LIKE rspoattr OCCURS 0 WITH HEADER LINE.

  ssfpp-tddevice        = 'PRINTER'.
  ssfpp-tdpreview       = 'X'.
  ssfpp-tdpageform      = 'DINA4'.
  ssfpp-tdpages         = '00002'.
  ssfpp-tddriver        = 'SWIN'.
  ssfpp-tdotftype       = 'OTFSWIN'.
  ssfpp-tdforms         = '00001'.
  ssfpp-tdprogram       = 'SAPLSTXBE'.
  ssfpp-tdarmod         = '1'.
  ssfpp-tddataset       = 'SMART'.
  ssfpp-tdsuffix1       = 'ZP01'.
  ssfpp-tdsuffix2       = sy-uname.
  ssfpp-tddest          = 'ZP01'.
  ssfpp-tdprinter       = 'KPSAPWIN'.
  ssfpp-tdimmed         = 'X'.
  ssfpp-tddelete        = 'X'.
  ssfpp-tdlifetime      = '8'.
  ssfpp-tdcopies      = i_prtcnt.                           "'001'.

  spool_job_attributes-param    = 'S_COPYMETH'.
  spool_job_attributes-value    = 'COLLATE'.
  APPEND spool_job_attributes.
*
  CALL FUNCTION 'SSFDISPLAY_OTF'
    EXPORTING
      display_parameters = ssfpp
      archive_params     = arc_params
      spoolattr          = spool_job_attributes[]
    IMPORTING
      result             = ssfpp
    TABLES
      otf                = otf
    EXCEPTIONS
      error              = 1.

  IF sy-subrc = 0.
*   PRINT 되었으면 COUNT 증가
    IF sy-msgty = 'S' AND sy-msgno = '60'.
      SORT gt_out_t BY iv_no.
      LOOP AT gt_out_t.
        AT END OF iv_no.
          CLEAR ZGTMMT4500.
          SELECT SINGLE * FROM ZGTMMT4500 WHERE iv_no EQ gt_out_t-iv_no.
          IF sy-subrc = 0.
            ZGTMMT4500-print_cnt   = ZGTMMT4500-print_cnt + 1. "재발행 Count
            ZGTMMT4500-change_date = sy-datum.               "변경일
            ZGTMMT4500-change_time = sy-uzeit.               "변경시간
            UPDATE ZGTMMT4500.
          ENDIF.
        ENDAT.
      ENDLOOP.
      COMMIT WORK.
    ENDIF.
  ENDIF.

ENDFORM.                    " SMART_FORM_FINALL_WRITE
*&---------------------------------------------------------------------*
*&      Form  get_data_pp_351
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_pp_351 .

  SELECT * FROM zppt0019 WHERE mblnr = gt_tab-mblnr
                           AND ebeln = mseg-ebeln   "gt_tab-ebeln
                           AND matnr = gt_tab-matnr
                           AND charg = gt_tab-charg.
    MOVE-CORRESPONDING gt_tab TO gt_out.
    gt_out-tagnr = zppt0019-tagnr.
    gt_out-ebeln = zppt0019-ebeln.

*{ SRM2401-14519 - 추가_S
*___자재문서 품목과 수량을 맞추기 위해 임시 Internal Table에서
*   자재문서/자재/배치/수량이 동일한 품목을 찾아 사용여부 표시
    READ TABLE gt_mdoc WITH KEY mblnr = zppt0019-mblnr
                                matnr = zppt0019-matnr
                                charg = zppt0019-charg
                                menge = zppt0019-enmng
                                used  = ' '.
    IF sy-subrc <> 0.
      READ TABLE gt_mdoc WITH KEY mblnr = zppt0019-mblnr
                                  matnr = zppt0019-matnr
                                  charg = zppt0019-charg
                                  used  = ' '.
    ENDIF.

    IF sy-subrc = 0.
      gt_out-zeile = gt_mdoc-zeile.

      gt_mdoc-used = 'X'.
      MODIFY gt_mdoc INDEX sy-tabix.
    ELSE.
      CONTINUE.
    ENDIF.

    IF zppt0019-tagnr IS NOT INITIAL.
      gt_out-lfimg = zppt0019-enmng.    "꼬리표번호가 있는 경우 수량
    ENDIF.
*} SRM2401-14519 - 추가_E

    gt_out-lifnr = mseg-lifnr.
*   자재 품명:규격
    SELECT SINGLE maktx INTO gt_out-maktx FROM makt
                       WHERE matnr = gt_out-matnr
                         AND spras = '3'.
*   통문유형별 Description
    SELECT SINGLE iv_type_nm INTO gt_out-iv_tdes FROM zgtmmt4511 "zlet0007
                            WHERE bukrs = p_bukrs AND  iv_type EQ gt_out-iv_type.

*   통문유무
    IF gt_out-out_yn = 'X'.
      gt_out-out_yn = 'Y'.
    ELSE.
      gt_out-out_yn = 'N'.
    ENDIF.
    APPEND gt_out.

    SORT gt_out BY ebeln matnr charg tagnr .
    DELETE ADJACENT DUPLICATES FROM gt_out
    COMPARING mblnr matnr charg ebeln tagnr.
  ENDSELECT.

ENDFORM.                    " get_data_pp_351
*&---------------------------------------------------------------------*
*&      Form  get_data_pp_etc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_pp_etc .

  SELECT * FROM zppt0018 WHERE mblnr = gt_tab-mblnr
*                          AND ebeln = mseg-ebeln  "gt_tab-ebeln
                           AND charg = gt_tab-charg.

    MOVE-CORRESPONDING gt_tab TO gt_out.
    gt_out-tagnr = zppt0018-tagnr.
    gt_out-ebeln = zppt0018-ebeln.

    gt_out-lifnr = mseg-lifnr.
*   자재 품명:규격
    SELECT SINGLE maktx INTO gt_out-maktx FROM makt
                       WHERE matnr = gt_out-matnr
                         AND spras = '3'.
*   통문유형별 Description
    SELECT SINGLE iv_type_nm INTO gt_out-iv_tdes FROM zgtmmt4511 "zlet0007
                            WHERE bukrs = p_bukrs AND  iv_type EQ gt_out-iv_type.

*   통문유무
    IF gt_out-out_yn = 'X'.
      gt_out-out_yn = 'Y'.
    ELSE.
      gt_out-out_yn = 'N'.
    ENDIF.
    APPEND gt_out.

  ENDSELECT.

ENDFORM.                    " get_data_pp_etc
*&---------------------------------------------------------------------*
*&      Form  COSTOMER_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0104   text
*      -->P_0105   text
*      -->P_0106   text
*----------------------------------------------------------------------*
FORM costomer_info  USING    p_lifnr
                             p_kunnr
                             p_umwrk.

  IF p_lifnr IS INITIAL.
    gt_out-lifnr = ' '.
  ENDIF.

  IF p_kunnr IS INITIAL.
    gt_out-kunnr = ' '.
  ENDIF.

  IF p_umwrk IS INITIAL.
    gt_out-umwrk = ' '.
  ENDIF.

ENDFORM.                    " COSTOMER_INFO
*&---------------------------------------------------------------------*
*&      Form  authority_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM authority_check .
*  DATA: lv_subrc  LIKE sy-subrc.
*
*  CLEAR : lv_subrc.
*  CALL FUNCTION 'Z_LE_AUTHORIZATION_CHECK'
*    EXPORTING
*      i_bzarea = p_bzarea
*      i_type   = '5'
*    IMPORTING
*      e_subrc  = lv_subrc.
*
*  IF lv_subrc <> 0.
*    MESSAGE e002(zsd1) WITH '사업장에 대한 권한이 없읍니다'
*                      p_bzarea.
*  ENDIF.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드[&] 작업권한을 확인하세요.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'WERKS' FIELD P_WERKS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_WERKS'.
  MESSAGE E106 WITH P_WERKS. "플랜트[&] 작업권한을 확인하세요.

ENDFORM.                    " authority_check
*&---------------------------------------------------------------------*
*&      Form  value_request_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0051   text
*----------------------------------------------------------------------*
FORM value_request_werks  USING    p_xx.

  DATA: BEGIN OF pov_werks OCCURS 0,
          werks LIKE zlet0034-werks,
          name1 LIKE zlet0034-name1,
        END OF pov_werks.

  CHECK p_bukrs IS NOT INITIAL.

  SELECT w~werks w~name1
    FROM t001k AS k
         INNER JOIN t001w    AS w ON w~bwkey = k~bwkey
         INNER JOIN zlet0034 AS z ON z~werks = w~werks
    INTO TABLE pov_werks
    WHERE k~bukrs  = p_bukrs
      AND z~bzarea = p_bzarea.

*  SELECT WERKS NAME1
*  INTO   CORRESPONDING FIELDS OF TABLE POV_WERKS
*  FROM   ZLET0034.
**  WHERE  BZAREA = P_BZAREA.
**출하지점
*  .

  SORT pov_werks.
  DELETE ADJACENT DUPLICATES FROM pov_werks.

  fieldtab-tabname   = 'T001W'.
  fieldtab-fieldname = 'WERKS'.
  fieldtab-selectflag = 'X'.
  APPEND fieldtab.

  fieldtab-tabname   = 'T001W'.
  fieldtab-fieldname = 'NAME1'.
  fieldtab-selectflag = ' '.
  APPEND fieldtab.

  LOOP AT pov_werks.
    valuetab-value = pov_werks-werks.
    APPEND valuetab.
    valuetab-value = pov_werks-name1.
    APPEND valuetab.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE_EXT'
    EXPORTING
      display       = ' '
*     fieldname     = 'NAME1'
    IMPORTING
      index         = j
    TABLES
      fields        = fieldtab
      select_values = i_help_vtab
      valuetab      = valuetab.

*  IF j > 0.
*    READ TABLE pov_werks INDEX j.
**    VALUE       = pov_WERKS-VSTEL.
*    IF p_xx = '1'.
*      i_werks-low  = pov_werks-werks.
*    ELSE.
*      i_werks-high = pov_werks-name1.
*    ENDIF.
*
*  ENDIF.
  REFRESH : fieldtab, valuetab, pov_werks.
  CLEAR   : j,fieldtab, valuetab, pov_werks.

ENDFORM.                    " value_request_WERKS
*&---------------------------------------------------------------------*
*&      Form  value_request_branch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0077   text
*----------------------------------------------------------------------*
FORM value_request_branch  USING    p_branch.
  DATA : BEGIN OF pov_branch OCCURS 0 ,
           branch LIKE  j_1bbranch-branch,
           name   LIKE  j_1bbranch-name,
         END OF pov_branch.

  CHECK p_bukrs IS NOT INITIAL.

  SELECT a~branch
         b~name
    INTO (pov_branch-branch , pov_branch-name)
    FROM j_1bbranch AS a
   INNER JOIN j_1bbrancht AS b
      ON a~bukrs      = b~bukrs
     AND a~branch     = b~branch
     AND a~bupla_type = b~bupla_type
   WHERE a~bukrs      = p_bukrs
     AND b~language   = sy-langu.
*사업장
    APPEND pov_branch.
  ENDSELECT.

  SORT pov_branch.

  fieldtab-tabname   = 'J_1BBRANCH'.
  fieldtab-fieldname = 'BRANCH'.
  fieldtab-selectflag = 'X'.
  APPEND fieldtab.

  fieldtab-tabname   = 'J_1BBRANCH'.
  fieldtab-fieldname = 'NAME'.
  fieldtab-selectflag = ' '.
  APPEND fieldtab.

  LOOP AT pov_branch.
    valuetab-value = pov_branch-branch.
    APPEND valuetab.
    valuetab-value = pov_branch-name.
    APPEND valuetab.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE_EXT'
    EXPORTING
      display       = ' '
*     fieldname     = 'NAME1'
    IMPORTING
      index         = j
    TABLES
      fields        = fieldtab
      select_values = i_help_vtab
      valuetab      = valuetab.

*  IF j > 0.
*    READ TABLE pov_branch INDEX j.
**    VALUE       = pov_WERKS-VSTEL.
*    IF p_branch = '1'.
*      i_branch-low  = pov_branch-branch.
*    ELSE.
*      i_branch-high = pov_branch-name.
*    ENDIF.
*
*  ENDIF.
  REFRESH : fieldtab, valuetab, pov_branch.
  CLEAR   : j,fieldtab, valuetab, pov_branch.

ENDFORM.                    " value_request_branch
*&---------------------------------------------------------------------*
*&      Form  check_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_bukrs.

  CHECK p_bukrs IS NOT INITIAL.

  SELECT SINGLE mandt
    FROM t001
    INTO sy-mandt
    WHERE bukrs = p_bukrs.
  IF sy-subrc <> 0.
    MESSAGE e000(zle1) WITH '존재하지 않는 회사코드입니다'.
  ENDIF.

ENDFORM.                    " check_bukrs
*&---------------------------------------------------------------------*
*&      Form  value_request_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM value_request_bukrs.

  DATA: BEGIN OF lt_t001 OCCURS 0,
          bukrs LIKE t001-bukrs,
          butxt LIKE t001-butxt,
        END   OF lt_t001.

  DATA: lt_fields   TYPE TABLE OF help_value WITH HEADER LINE,
        lt_select   TYPE TABLE OF help_vtab  WITH HEADER LINE,
        lt_valuetab TYPE TABLE OF text79_d   WITH HEADER LINE,
        lv_value    TYPE t001-bukrs.

  SELECT bukrs butxt
    FROM t001
    INTO TABLE lt_t001
    WHERE ktopl =  '1000'
      AND fikrs <> ''.

  CHECK sy-subrc = 0.

  lt_fields-tabname    = 'T001'.
  lt_fields-fieldname  = 'BUKRS'.
  lt_fields-selectflag = 'X'.
  APPEND lt_fields.
  lt_fields-tabname    = 'T001'.
  lt_fields-fieldname  = 'BUTXT'.
  lt_fields-selectflag = ' '.
  APPEND lt_fields.

  LOOP AT lt_t001.
    lt_valuetab = lt_t001-bukrs.
    APPEND lt_valuetab.
    lt_valuetab = lt_t001-butxt.
    APPEND lt_valuetab.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE_EXT'
    IMPORTING
      select_value  = lv_value
    TABLES
      fields        = lt_fields
      select_values = lt_select
      valuetab      = lt_valuetab.

  p_bukrs = lv_value.

ENDFORM.                    " value_request_bukrs
