************************************************************************
*  Program ID  : ZGTMMR4520   "ZLER0017                                              *
*  Title       : [MM]가온전선_기타 통문증 발행
*  Create Date : 2026.04.30   "2004. 12. 07
*  Author      : ZGODEV04 "SDC08
*  Doc. ID     : FT_LE_ZLER0017_기타통문증발행.doc
*  Frequency   : Frequency
*  GAP NO      : LES022
*  DESCRIPTION :가온전선_기존 LS 기타통문증발행(ZLER0017)프로그램
*                       복사 후 단순화 및 폼 변경
************************************************************************
*  Changed by  |  Description of change|  Date
*  <Name>      |                                |<MM-DD-YY>
************************************************************************
*----------------------------------------------------------------------*
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2007/11/14    SONG     통문확정 상태의 통문증 발행취소 않도록 수정   *
*                        [요청번호] C20071114_69225                    *
* 2008/06/13    BCKOO    [제목] LS엠트론 CI 추가                       *
*                        [요청번호] 법인분리                           *
* 2010/03/03    BCKOO    [제목] 기타 통문 거래명세서 리스트 조회시     *
*                         "통문증 생성일자 열" 추가                    *
*                        [요청번호] C20100121_97082                    *
* 2013/10/25    J.Y.Lee  [제목] 통문증 조회시 필드 값 내용 추가        *
*                        [요청번호] C20131010_16602                    *
* 2014/03/10    ZLSGSD   G-SPOC 요청번호 : 2014030700032               *
*                          거래명세서의 공급자란 대표자 정보 수정 요청 *
* 2014/03/11    ZLSGSD   G-SPOC 요청번호 : 2014031100058               *
*                          거래명세서의 공급자란 회사명/주소 정보 수정 *
* 2014/09/02    H.M.Lim  [제목] 통문증 발행일자, 출력일자 구분표시 요청*
*                        [요청번호] 기능개선 42387                     *
* 2014/10/15    H.M.Lim  [제목] 통문유형 리스트 표시 제한              *
*                        [요청번호] 기능개선 48114                     *
* 2014/10/21    H.M.Lim  [제목] 기타 통문증 발행시 필수 입력 사항 지정 *
*                        [요청번호] 기능개선 48115                     *
* 2014/10/23    H.M.Lim  [제목] 통문증 출력물 양식 수정                *
*                        [요청번호] 기능개선 48117                     *
*----------------------------------------------------------------------*
*  Date.     Author.  CSR#.            Description.
*----------------------------------------------------------------------*
* 2014.11.19 H.M.LIM  자체개선 53433   엠트론 통문증 특기사항 정보 표기
* 2015.05.08 H.M.LIM  기능개선 77487   통문발행시 차량마스터 자동 기입
* 2016.11.16 G.T.JUNG 기능개선 XXXXX   테이블 첨부파일 필드 추가
* 2018.03.16 노승남   기능개선 228147  통문유형 'E12' 추가
* 2018.06.15 노승남   기능개선 239072  차량번호에 따른 운전자, 전화번호
*                                      자동 입력 로직 수정
* 2018.06.22 노승남   기능개선 239718  LS MTRON 통문 승인 기능 추가
* 2018.09.18 노승남   기능개선 248939  LS MTRON 통문증 양식 결재란 추가
* 2018.10.01 노승남   기능개선 249737  LS MTRON 통문증 양식 변경
* 2019.04.15 노승남   기능개선 276257  통문유형 'E06'에 자재코드 추가
* 2020.02.05 문종덕   기능개선 307461  통문유형 'E13'추가
*                                      통문증 삭제시 예약삭제
************************************************************************

REPORT  zgtmmr4520 MESSAGE-ID zle1.

INCLUDE ZGTMMR4520TOP.

INITIALIZATION.

  s_date-sign = 'I'.
  s_date-option = 'BT'.
  s_date-low    = sy-datum.
  s_date-high    = sy-datum.
  APPEND s_date.


AT SELECTION-SCREEN.
  PERFORM check_bukrs.
  PERFORM check_input(zler0012) USING p_bzarea.
** 권한CHECK
  PERFORM authority_check.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'M1' AND p_bukrs IS INITIAL.
      screen-input = 0.
      CLEAR: s_type[], s_type.
    ELSEIF screen-group1 = 'M2' AND p_bzarea IS INITIAL.
      screen-input = 0.
      CLEAR: s_werks[], s_werks.
*{ 기능개선 248939 - 추가
    ELSEIF screen-group1 = 'REQ'.
      screen-required = '2'.
*} 기능개선 248939 - 추가
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_bukrs .
  PERFORM f4_value_bukrs.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_type-low .
  PERFORM f4_value_iv_type USING '1'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_type-high .
  PERFORM f4_value_iv_type USING '2'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_werks-low .
  PERFORM f4_value_werks USING '1'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_werks-high .
  PERFORM f4_value_werks USING '2'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_pernr-low .
  PERFORM f4_value_pernr USING '1'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_pernr-high .
  PERFORM f4_value_pernr USING '2'.

AT USER-COMMAND.

START-OF-SELECTION.
  IF p_bukrs IS INITIAL.
    MESSAGE s000 DISPLAY LIKE 'E' WITH '회사코드를 입력하십시오'.
    RETURN.
  ENDIF.
  IF p_bzarea IS INITIAL.
    MESSAGE s000 DISPLAY LIKE 'E' WITH '사업장을 입력하십시오'.
    RETURN.
  ENDIF.

  PERFORM data_query TABLES gt_alv1 .
  SORT gt_alv1 BY iv_type iv_no iv_seq.
  CALL SCREEN 100.
*&---------------------------------------------------------------------*
*&      Form  data_query
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ALV1  text
*----------------------------------------------------------------------*
FORM data_query  TABLES   pt_alv1 LIKE gt_alv1[].

  CLEAR: pt_alv1[].

  DATA: lv_maktx(40).
  CONCATENATE '%' p_maktx '%' INTO  lv_maktx.

  RANGES r_werks FOR zgtmmt4500-werks.
  IF r_1 = 'X'.
    SELECT w~werks
      FROM t001k AS k
           INNER JOIN t001w    AS w ON w~bwkey = k~bwkey
           INNER JOIN zlet0034 AS z ON z~werks = w~werks
      INTO r_werks-low
      WHERE k~bukrs  = p_bukrs
        AND z~bzarea = p_bzarea.
      r_werks-sign   = 'I'.
      r_werks-option = 'EQ'.
      APPEND r_werks.
    ENDSELECT.
    IF sy-subrc <> 0.
      SELECT w~werks
        FROM t001k AS k INNER JOIN t001w AS w ON w~bwkey = k~bwkey
        INTO r_werks-low
        WHERE k~bukrs  = p_bukrs.
        r_werks-sign   = 'I'.
        r_werks-option = 'EQ'.
        APPEND r_werks.
      ENDSELECT.
    ENDIF.
  ENDIF.

  SELECT k~iv_no
         k~iv_type
         k~werks
         k~kunnr   "구매처
         k~kunnr1  "납품처
         k~kunnr2  "수기 납품처
         k~addrs
         k~umwrk
         k~pernr
         k~ename
         k~orgeh
         k~orgtx
         k~bernr
         k~bname
         k~brgeh
         k~brgtx
         k~truck_no
         k~etc_nm
         k~create_date
         k~create_time
         k~iv_print_yn
         k~out_yn
         k~return_yn
*/ EDIT FROM BY G.T.JUNG AT 2016.11.16
        k~zpdf
*/ EDIT END
         k~zmanual
         p~iv_seq
         p~maktx
         p~charg              "기능개선 228147 - 추가
         p~lfimg
         p~mtr_unit
         p~dmbtr
         p~asset_nm
         p~asset_spec
         p~asset_no
         p~asset_amt
         p~matnr
         k~rsnum      "기능개선 307461 - S

    INTO CORRESPONDING FIELDS OF TABLE pt_alv1
    FROM zgtmmt4500 AS k INNER JOIN zgtmmt4501 AS p
*    FROM zlet0005 AS k INNER JOIN zlet0006 AS p
      ON k~iv_no = p~iv_no
   WHERE k~bzarea      =  p_bzarea
     AND k~iv_no       IN s_iv_no
     AND k~iv_type     IN s_type
     AND k~werks       IN s_werks
     AND k~werks       IN r_werks
     AND k~pernr       IN s_pernr
     AND k~orgeh       IN s_orgeh
     AND k~create_date IN s_date
     AND k~reqst        = 'X'
     AND p~maktx       LIKE  lv_maktx
     AND p~asset_no    IN s_matnr.
*     and k~IV_PRINT_YN = ' '
* [START] CSR NO : C20071114_69225
*     AND K~IV_CANCEL_YN = ' '.
* [END]   CSR NO : C20071114_69225
*     AND k~out_yn       = ' '.

* Radiobutton
  IF r_1 = 'X'.
    DELETE pt_alv1 WHERE iv_print_yn = 'X'.
  ELSE.
    DELETE pt_alv1 WHERE iv_print_yn = ' '.
  ENDIF.
*
  DESCRIBE TABLE pt_alv1 LINES sy-tfill.
  IF sy-tfill = 0.
    MESSAGE i005(zle1) WITH '조건에 맞는 DATA가 없습니다'.
    IF sy-dynnr = '1000'.
      STOP.
    ELSE.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
*
  CHECK NOT pt_alv1[] IS INITIAL.
*/ 플랜트
  DATA: lt_t001w LIKE t001w OCCURS 0 WITH HEADER LINE.
  CLEAR: lt_t001w[].
  SELECT * INTO TABLE lt_t001w
    FROM t001w .
**/ 거래처
*  DATA: lt_lfa1  LIKE lfa1 OCCURS 0 WITH HEADER LINE.
*  CLEAR: lt_lfa1[].
*  SELECT * INTO TABLE lt_lfa1
*    FROM lfa1
*     FOR ALL ENTRIES IN pt_alv1
*   WHERE lifnr = pt_alv1-kunnr.

  LOOP AT pt_alv1.
    IF pt_alv1-iv_print_yn = 'X'.
      pt_alv1-icon1 = icon_print.
    ENDIF.
    SELECT SINGLE iv_type_nm INTO pt_alv1-iv_type_nm
      FROM zgtmmt4511
      WHERE bukrs = p_bukrs
           And iv_type = pt_alv1-iv_type.
*    SELECT SINGLE iv_type_nm INTO pt_alv1-iv_type_nm
*      FROM zlet0007
*     WHERE iv_type = pt_alv1-iv_type.

    READ TABLE lt_t001w WITH KEY werks = pt_alv1-werks.
    pt_alv1-werks_t   =  lt_t001w-name1.

    IF NOT pt_alv1-kunnr IS INITIAL.  "구매처
      SELECT SINGLE name1 INTO pt_alv1-kunnr_t FROM lfa1
        WHERE lifnr = pt_alv1-kunnr.
    ENDIF.
    IF pt_alv1-zmanual IS NOT INITIAL.
      pt_alv1-kunnr_t = pt_alv1-kunnr2. "수기납품처
    ELSE.
      IF NOT pt_alv1-kunnr1 IS INITIAL.  "납품처
        SELECT SINGLE name1 INTO pt_alv1-kunnr_t FROM kna1
          WHERE kunnr = pt_alv1-kunnr1.
        pt_alv1-kunnr = pt_alv1-kunnr1.
      ENDIF.
    ENDIF.
    IF NOT pt_alv1-umwrk IS INITIAL.  "사내소비
      SELECT SINGLE name1 INTO pt_alv1-kunnr_t FROM t001w
        WHERE werks = pt_alv1-umwrk.
      pt_alv1-kunnr = pt_alv1-umwrk.
    ENDIF.

*/ EDIT FROM BY G.T.JUNG AT 2016.11.16
*/ ZPDF 로 ZPDF_DISP 필드 변경
    IF  NOT pt_alv1-zpdf IS INITIAL.  "첨부파일
      pt_alv1-zpdf_dis = c_doc_exist.
    ENDIF.
*/ EDIT END

*{ 기능개선 228147 - 추가
    IF pt_alv1-iv_type = 'E12'.
      CONCATENATE pt_alv1-maktx pt_alv1-charg
             INTO pt_alv1-maktx SEPARATED BY '-'.
    ENDIF.
*} 기능개선 228147 - 추가

    MODIFY pt_alv1.
  ENDLOOP.

  DATA: flag .
  SORT pt_alv1.
  LOOP AT pt_alv1.
    CLEAR: flag.
    AT NEW orgtx.
      flag = 'X'.
    ENDAT.

    IF flag = ' '.
      pt_alv1-sel = '-'.
      MODIFY pt_alv1.
    ENDIF.

  ENDLOOP.
  SORT pt_alv1 BY iv_type iv_no iv_seq.
*
ENDFORM.                    " data_query
*&---------------------------------------------------------------------*
*&      Module  status_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  DATA: s_func(10) OCCURS 0 WITH HEADER LINE.

  IF r_2 = 'X'.
    s_func = 'DELE'.
    APPEND s_func.
    s_func = 'CHAN'.
    APPEND s_func.
  ELSE.
    s_func = 'TONDEL'.
    APPEND s_func.
  ENDIF.

  SET PF-STATUS '100' EXCLUDING s_func.
  SET TITLEBAR  '100'.

ENDMODULE.                 " status_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  create_control  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_control OUTPUT.

  IF docking IS INITIAL.
*/ Create the docking container
    PERFORM create_docking.
*/ Create the GRID LIST1
    PERFORM create_grid1.
  ELSE.
    CALL METHOD grid1->refresh_table_display.
  ENDIF.

ENDMODULE.                 " create_control  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command INPUT.

  CASE ok_code.
    WHEN 'BACK' .
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " exit_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'PRNT'.
      PERFORM chk.
      PERFORM print.
      wa-create_date = sy-datum.
      IF gt_alv1-iv_type <> 'C06'.
        CALL SCREEN 0110 STARTING   AT 22 1
                           ENDING   AT 88 10.
      ENDIF.
      IF lv_exit = 'X'.
      ELSE.
        CALL SCREEN 0200.
      ENDIF.
    WHEN 'TONDEL'.  "통문증 발행취소
      PERFORM cancel_tong_no.
    WHEN 'DELE'.
      PERFORM delete_reqest.
    WHEN 'CHAN'.
      PERFORM change_data.
      PERFORM data_query TABLES gt_alv1 .
      SORT gt_alv1 BY iv_type iv_no iv_seq.
    WHEN 'REFR'.
      PERFORM data_query TABLES gt_alv1.
  ENDCASE.

  CLEAR: wa.
*  CLEAR: wa-pernr, wa-ename, wa-orgeh, wa-orgtx,
*         wa-truck_no, wa-drnam.


ENDMODULE.                 " user_command_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  create_docking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_docking .

  CREATE OBJECT docking
    EXPORTING
      repid     = sy-repid
      dynnr     = '0100'
      side      = docking->dock_at_top
      extension = 2000.

ENDFORM.                    " create_docking
*&---------------------------------------------------------------------*
*&      Form  create_grid1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_grid1 .

  CREATE OBJECT grid1
    EXPORTING
      i_parent      = docking
      i_appl_events = ''.

*/ 출력할 필드 속성을 정의
  PERFORM set_field_catalogs_grid1.

*/ LAYOUT SETTING
  PERFORM set_option_grid1.

*/ 속성
*  PERFORM set_cell_attribute_grid1.

*/ SORT
*  PERFORM set_sort.

  CALL METHOD grid1->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  alv_variant-report = sy-repid.
*/ ALV DATA 뿌려줌
  CALL METHOD grid1->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      it_toolbar_excluding = gt_tbar_excluding1
      i_save               = 'A'
      is_variant           = alv_variant
    CHANGING
      it_outtab            = gt_alv1[]
      it_sort              = gt_sort[]
      it_fieldcatalog      = gt_lvc1[].

*/ ALV 내에서의 이벤트 연결.
  CREATE OBJECT event_receiver.

  SET HANDLER event_receiver->handle_user_command           FOR grid1.
* SET HANDLER EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK          FOR GRID1.
  SET HANDLER event_receiver->handle_toolbar                FOR grid1.
  SET HANDLER event_receiver->handle_double_click           FOR grid1.
  SET HANDLER event_receiver->handle_data_changed_finished  FOR grid1.
  CALL METHOD grid1->set_toolbar_interactive.

ENDFORM.                    " create_grid1
*&---------------------------------------------------------------------*
*&      Form  set_field_catalogs_grid1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_field_catalogs_grid1 .

* FIELD발췌
  REFRESH: gt_lvc1[].
*  clear: gv_cnt.

  PERFORM fill_field_catalogs
          USING:
          'S' 'FIELDNAME'   'SEL',
          ' ' 'COLTEXT'     ' ',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          ' ' 'CHECKBOX'    'X',
          ' ' 'EDIT'        'X',
          'E' 'OUTPUTLEN'   '1',

          'S' 'FIELDNAME'   'ICON1',
          ' ' 'COLTEXT'     '상태',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          'E' 'OUTPUTLEN'   '4',

          'S' 'FIELDNAME'   'IV_NO',
          ' ' 'COLTEXT'     '통문번호',
*         ' ' 'JUST'        'L',
*         ' ' 'KEY'         'X',
          ' ' 'EMPHASIZE'   'C410',
          'E' 'OUTPUTLEN'   '10',

*          'S' 'FIELDNAME'   'IV_TYPE',
*          ' ' 'COLTEXT'     '통문유형',
*          ' ' 'JUST'        'L',
*          ' ' 'KEY'         ' ',
*          'E' 'OUTPUTLEN'   '3',

          'S' 'FIELDNAME'   'IV_TYPE_NM',
          ' ' 'COLTEXT'     '통문유형명',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '40',

          'S' 'FIELDNAME'   'OUT_YN',
          ' ' 'COLTEXT'     '통문유무',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '1',

          'S' 'FIELDNAME'   'ASSET_NO',
          ' ' 'COLTEXT'     '자산코드',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '12',

          'S' 'FIELDNAME'   'WERKS',
          ' ' 'COLTEXT'     'PLANT',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '5',

          'S' 'FIELDNAME'   'WERKS_T',
          ' ' 'COLTEXT'     '플랜트명',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '30',

          'S' 'FIELDNAME'   'KUNNR',
          ' ' 'COLTEXT'     '거래처',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          ' ' 'NO_ZERO'     'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'KUNNR_T',
          ' ' 'COLTEXT'     '거래처명',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '35',

          'S' 'FIELDNAME'   'PERNR',
          ' ' 'COLTEXT'     '사원번호',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'ENAME',
          ' ' 'COLTEXT'     '요청사원',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '40',

          'S' 'FIELDNAME'   'ORGTX',
          ' ' 'COLTEXT'     '요청부서',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '5'.
*/
  IF r_2 = 'X'.
    PERFORM fill_field_catalogs
            USING:
            'S' 'FIELDNAME'   'BERNR',
            ' ' 'COLTEXT'     '발행사원번호',
            ' ' 'JUST'        'L',
            ' ' 'KEY'         ' ',
            'E' 'OUTPUTLEN'   '8',

            'S' 'FIELDNAME'   'BNAME',
            ' ' 'COLTEXT'     '발행사원',
            ' ' 'JUST'        'L',
            ' ' 'KEY'         ' ',
            'E' 'OUTPUTLEN'   '40',

            'S' 'FIELDNAME'   'BRGTX',
            ' ' 'COLTEXT'     '발행부서',
            ' ' 'JUST'        'L',
            ' ' 'KEY'         ' ',
            'E' 'OUTPUTLEN'   '5',

* [START] CSR Number : C20100121_97082
* 필드 추가
            'S' 'FIELDNAME'   'CREATE_DATE',
            ' ' 'COLTEXT'     '생성일자',
            ' ' 'JUST'        'L',
            ' ' 'KEY'         ' ',
            'E' 'OUTPUTLEN'   '10',

            'S' 'FIELDNAME'   'CREATE_TIME',
            ' ' 'COLTEXT'     '생성시간',
            ' ' 'JUST'        'L',
            ' ' 'KEY'         ' ',
            'E' 'OUTPUTLEN'   '10'.
* [END]
  ENDIF.

  PERFORM fill_field_catalogs
          USING:
*          'S' 'FIELDNAME'   'IV_SEQ',
*          ' ' 'COLTEXT'     '항번',
*          ' ' 'JUST'        'L',
*          ' ' 'KEY'         'X',
*          'E' 'OUTPUTLEN'   '6',

          'S' 'FIELDNAME'   'MATNR',
          ' ' 'COLTEXT'     '자재코드',
          ' ' 'CONVEXIT'    'MATN1',
          ' ' 'JUST'        'R',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'MAKTX',
          ' ' 'COLTEXT'     '품명/규격',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '40',

          'S' 'FIELDNAME'   'ASSET_SPEC',
          ' ' 'COLTEXT'     '규격/용도',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'LFIMG',
          ' ' 'COLTEXT'     '수량',
          ' ' 'JUST'        'R',
          ' ' 'KEY'         ' ',
          ' ' 'TABNAME'     'GT_ALV1',
          ' ' 'QFIELDNAME'  'MTR_UNIT',
          'E' 'OUTPUTLEN'   '15',

          'S' 'FIELDNAME'   'MTR_UNIT',
          ' ' 'COLTEXT'     '단위',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          ' ' 'CONVEXIT'    'CUNIT',
          'E' 'OUTPUTLEN'   '4',

          'S' 'FIELDNAME'   'DMBTR',
          ' ' 'COLTEXT'     '금액',
          ' ' 'JUST'        'R',
          ' ' 'KEY'         ' ',
          ' ' 'CURRENCY'    'KRW',
          'E' 'OUTPUTLEN'   '15',

* 필드 추가 by J.Y.Lee 10/25/2013 C20131010_16602
          'S' 'FIELDNAME'   'TRUCK_NO',
          ' ' 'COLTEXT'     '차량번호',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'ETC_NM',
          ' ' 'COLTEXT'     '특이사항',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '50'  ,

*/ EDIT FROM BY G.T.JUNG AT 2016.11.16
          'S' 'FIELDNAME'   'ZPDF_DIS',
          ' ' 'COLTEXT'     '첨부파일',
          ' ' 'ICON'        'X',
          ' ' 'INTTYPE'     'C',
          ' ' 'INTLEN'      4,
          'E' 'OUTPUTLEN'   '10'    .
*/ EDIT END
ENDFORM.                    " set_field_catalogs_grid1
*&---------------------------------------------------------------------*
*&      Form  set_option_grid1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_option_grid1 .

* 1. LAYOUT OPTION - 라인 선택 가능
  gs_layout-sel_mode   = 'B'.
  gs_layout-no_rowmark = 'X'.
  gs_layout-zebra      = ''.
  gs_layout-cwidth_opt = 'X'.
  gs_layout-ctab_fname = 'ALV_COL'.
  gs_layout-stylefname = 'CELLTAB'.
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
           '&DETAIL'              TO gt_tbar_excluding1.

ENDFORM.                    " set_option_grid1
*&---------------------------------------------------------------------*
*&      Form  fill_field_catalogs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0222   text
*      -->P_0223   text
*      -->P_0224   text
*----------------------------------------------------------------------*
FORM fill_field_catalogs  USING    p_gub  p_fname  p_value.

*- 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*- 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점

  IF p_gub = 'S'.

    CLEAR gs_lvc1.

  ENDIF.

*- 출력될 Field 속성을 정의해서 필드 카타로그 테이블에 저장
  DATA l_fname(40).
  FIELD-SYMBOLS <fs> TYPE any.
  CONCATENATE 'GS_LVC1-' p_fname INTO l_fname.

  ASSIGN (l_fname) TO <fs>.
  <fs> = p_value.

  IF p_gub = 'E'.

    APPEND gs_lvc1 TO gt_lvc1.

  ENDIF.

ENDFORM.                    " fill_field_catalogs
*&---------------------------------------------------------------------*
*&      Form  SET_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_sort .

  CLEAR : gt_sort[].
  gt_sort-spos = '01'.
  gt_sort-fieldname = 'IV_NO'.
  gt_sort-up = 'X'.
*  GT_SORT-SUBTOT = 'X'.
  APPEND gt_sort.

*  gt_sort-spos = '02'.
*  gt_sort-fieldname = 'IV_TYPE'.
*  gt_sort-up = 'X'.
**  GT_SORT-SUBTOT = 'X'.
*  APPEND gt_sort.
*
*  gt_sort-spos = '03'.
*  gt_sort-fieldname = 'IV_TYPE_NM'.
*  gt_sort-up = 'X'.
**  GT_SORT-SUBTOT = 'X'.
*  APPEND gt_sort.

ENDFORM.                    " SET_SORT
*&---------------------------------------------------------------------*
*&      Form  set_cell_attribute_grid1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_cell_attribute_grid1 .

*// 각 Cell의 특성 제어
  DATA : lt_celltab TYPE lvc_t_styl,
         lt_color   TYPE lvc_t_scol,
         index      TYPE i, flag.

  LOOP AT gt_alv1.

    CLEAR: lt_celltab[].

    index = sy-tabix.

*    CLEAR: flag.
*    AT NEW iv_no.
*      flag = 'X'.
*    ENDAT.
*    IF flag = ' '.
    PERFORM fill_celltab CHANGING lt_celltab.

    CLEAR: gt_alv1-celltab[].

    INSERT LINES OF lt_celltab INTO TABLE gt_alv1-celltab.
    MODIFY gt_alv1 INDEX index.
*    ENDIF.
  ENDLOOP.

ENDFORM.                    " set_cell_attribute_grid1
*&---------------------------------------------------------------------*
*&      Form  fill_celltab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_CELLTAB  text
*----------------------------------------------------------------------*
FORM fill_celltab  CHANGING pt_celltab TYPE lvc_t_styl.

  DATA : ls_celltab TYPE lvc_s_styl,
         l_mode     TYPE raw4.

  DATA : l_fieldcat TYPE lvc_s_fcat.

  LOOP AT gt_lvc1 INTO l_fieldcat.

    ls_celltab-fieldname = l_fieldcat-fieldname.

    IF  ls_celltab-fieldname  = 'SEL'.

      ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled +
                         cl_gui_alv_grid=>mc_style_hotspot .

      INSERT ls_celltab INTO TABLE pt_celltab.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " fill_celltab
*&---------------------------------------------------------------------*
*&      Form  delete_reqest
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_reqest .

  DATA: lv_flag.
  CLEAR: lv_flag.
  LOOP AT gt_alv1 WHERE icon1 = icon_delete
                    AND sel   = 'X'.
    MESSAGE i001 WITH
     gt_alv1-iv_no '이미 삭제하였습니다. '.

    lv_flag = 'X'.
  ENDLOOP.

  IF lv_flag = 'X'.
    LEAVE SCREEN.
  ENDIF.

*  LOOP AT gt_alv1 WHERE sel = 'X'.
*    SELECT SINGLE mandt INTO sy-mandt
*     FROM zlet0005
*    WHERE iv_no = gt_alv1-iv_no
*      AND return_yn = 'X'.
*    IF sy-subrc = 0.
*      MESSAGE i005 WITH
*       gt_alv1-iv_no '반입하여 삭제불가합니다.'.
*      lv_flag = 'X'.
*    ENDIF.
*
*    IF lv_flag = 'X'.
*      LEAVE SCREEN.
*    ENDIF.
*
*  ENDLOOP.

*********************************************
*  LOOP AT gt_alv1 WHERE sel = 'X'.
*    SELECT SINGLE mandt INTO sy-mandt
*     FROM zlet0005
*    WHERE iv_no = gt_alv1-iv_no
*      AND reqst = 'X'
*      AND iv_print_yn = 'X'
*      AND iv_cancel_yn = 'X'.
*    IF sy-subrc = 0.
*      MESSAGE i005 WITH
*       gt_alv1-iv_no '이미 거래명세서를 발행하였습니다.'.
*      lv_flag = 'X'.
*    ENDIF.
*
*    IF lv_flag = 'X'.
*      LEAVE SCREEN.
*    ENDIF.
*
*  ENDLOOP.
  DATA: lv_return.
  PERFORM pop_up_confirm(zler0004) USING '< 확인 >'
                               '요청삭제하시겠읍니까?'
                      CHANGING lv_return.
  CHECK lv_return = 'J'.
  LOOP AT gt_alv1 WHERE sel = 'X'.
*    DELETE FROM zlet0005 WHERE iv_no = gt_alv1-iv_no.
*    COMMIT WORK.
*    DELETE FROM zlet0006 WHERE iv_no = gt_alv1-iv_no.
*    COMMIT WORK.

*{ 기능개선 307461 -S
    IF gt_alv1-iv_type = 'E13'.
      PERFORM mb22_bdc USING gt_alv1-rsnum.
      IF gv_subrc = 4.
        MESSAGE e001 WITH gt_alv1-iv_no
        g_mesg.
        LEAVE SCREEN.
      ENDIF.
    ENDIF.
*} 기능개선 307461 -E

    UPDATE zgtmmt4500 SET: reqst = ' '
       WHERE iv_no = gt_alv1-iv_no.
*    UPDATE zlet0005 SET: reqst = ' '
*       WHERE iv_no = gt_alv1-iv_no.
    UPDATE zlet0003 SET: iv_status = 'F'
       WHERE iv_no = gt_alv1-iv_no.
    COMMIT WORK.
    gt_alv1-icon1 = icon_delete.
    gt_alv1-sel   = 'X'.

    PERFORM call_simple_approval USING gt_alv1-iv_no.

    MODIFY gt_alv1.
  ENDLOOP.


ENDFORM.                    " delete_reqest
*&---------------------------------------------------------------------*
*&      Form  CHANGE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_data .
  DATA: ls_0003 LIKE zlet0003,               "기능개선 239718 - 추가
        ls_0005 LIKE zgtmmt4500.

  DATA: ts_flag,
        ts_iv_no LIKE zgtmmt4500-iv_no,
        ts_bukrs LIKE matdoc-bukrs.

  CLEAR: lv_cnt.

  LOOP AT gt_alv1 WHERE sel = 'X'.
    ADD 1  TO lv_cnt.
    IF lv_cnt = 2.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF lv_cnt = 2.
    MESSAGE i000 WITH '한개의 통문번호를 선택하세요'.
    LEAVE SCREEN.
  ENDIF.

  READ TABLE gt_alv1 WITH KEY sel = 'X'.
  IF sy-subrc = 0.
    CLEAR : ls_0005.

    SELECT SINGLE *
      INTO ls_0005
*      FROM zlet0005
      FROM zgtmmt4500
     WHERE iv_no = gt_alv1-iv_no
       AND reqst = 'X'.

    IF sy-subrc <> 0.
      MESSAGE s000 DISPLAY LIKE 'E'
         WITH '통문번호가 삭제되었거나 존재하지 않습니다.'.

      EXIT.
    ENDIF.

*    SELECT SINGLE mandt INTO sy-mandt
*     FROM zlet0005
*    WHERE iv_no = gt_alv1-iv_no
*      AND return_yn = 'X'.
*    IF sy-subrc = 0.
*      MESSAGE i005 WITH
*       gt_alv1-iv_no '반입하여 삭제불가합니다.'.
*      LEAVE SCREEN.
*    ENDIF.

*    SELECT SINGLE mandt INTO sy-mandt
*       FROM zlet0005
*      WHERE iv_no = gt_alv1-iv_no
*        AND reqst = 'X'
*        AND iv_print_yn = 'X'
*        AND iv_cancel_yn = ' '.
*    IF sy-subrc = 0.
*      MESSAGE s000 WITH
*       '이미 거래명세서를 발행하였습니다.'.
*      LEAVE SCREEN.
*    ENDIF.

    IF ls_0005-out_yn = 'X'.
      MESSAGE s000 DISPLAY LIKE 'E'
         WITH '통문확정되었습니다.'.

      EXIT.
    ENDIF.

*{ 기능개선 239718 - 추가
    CLEAR : ls_0003.

    SELECT SINGLE *
      INTO ls_0003
      FROM zlet0003
     WHERE iv_no = gt_alv1-iv_no.

    IF sy-subrc = 0.
      IF ls_0003-iv_status = 'B' AND ls_0003-app_date1 IS NOT INITIAL.
        MESSAGE s004 DISPLAY LIKE 'E'
           WITH '합의자 승인된 통문번호입니다.'
                '변경할 수 없습니다.'.

        EXIT.
      ENDIF.

      IF ls_0003-iv_status = 'C' AND ls_0003-app_date2 IS NOT INITIAL.
        MESSAGE s004 DISPLAY LIKE 'E'
           WITH '승인자 승인된 통문번호입니다.'
                '변경할 수 없습니다.'.

        EXIT.
      ENDIF.
    ENDIF.
*} 기능개선 239718 - 추가

    ts_iv_no = gt_alv1-iv_no.
    ts_bukrs = p_bukrs.
    ts_flag  = 'X'.
    EXPORT ts_flag
           ts_iv_no
           ts_bukrs
           TO MEMORY ID 'ZZZZ'.
    IF gt_alv1-iv_type = 'E07'.
*      CALL TRANSACTION 'ZLE0200E'.
      CALL TRANSACTION 'ZGTMMR4540E'.
    ELSEIF gt_alv1-iv_type+0(1) = 'E'.
*      CALL TRANSACTION 'ZLE0200T'.
      CALL TRANSACTION 'ZGTMMR4540T'.
    ELSE.
*      CALL TRANSACTION 'ZLE0201T'.
      CALL TRANSACTION 'ZGTMMR4550T'.
    ENDIF.
*    LOOP AT GT_ALV1 WHERE SEL = 'X'.
*       S_IV_NO-LOW = GT_ALV1-IV_NO.
*       PERFORM data_query TABLES gt_alv1 .
*       sort gt_alv1 by iv_type iv_no iv_seq.
*    ENDLOOP.
  ELSE.
    MESSAGE s000 WITH '통문번호를 선택하세요'.
  ENDIF.





ENDFORM.                    " CHANGE_DATA
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS '0200'.
*  SET TITLEBAR 'xxx'.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM view_print.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  f4_value_IV_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_value_iv_type USING p_xx.

  CASE p_xx.
    WHEN '1'.
      PERFORM get_f4_iv_type USING s_type-low.
    WHEN '2'.
      PERFORM get_f4_iv_type USING s_type-high.
  ENDCASE.

ENDFORM.                    " f4_value_IV_TYPE
*&---------------------------------------------------------------------*
*&      Form  PRINT_COMPLETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_complete .

ENDFORM.                    " PRINT_COMPLETE
*&---------------------------------------------------------------------*
*&      Form  VIEW_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_print .

  REFRESH: lv_sm01, lv_sm02, lv_sm03, otf.
  CLEAR: lv_sm01, lv_sm02, lv_sm03, otf.
  CLEAR: lv_ivno, lv_kunnr, lv_ivtyp, lv_werks_t,lv_werks,
         lv_umwrk, lv_umwrk_t, cnt, lv_addrs.

  LOOP AT gt_alv1 WHERE sel = 'X'.
    cnt = cnt + 1.
    lv_ivno    = gt_alv1-iv_no.
    lv_kunnr   = gt_alv1-kunnr.
    lv_kunnr1  = gt_alv1-kunnr1.
    lv_kunnr2  = gt_alv1-kunnr2.
    lv_addrs   = gt_alv1-addrs.
    lv_ivtyp   = gt_alv1-iv_type.
    lv_werks_t = gt_alv1-werks_t.
    lv_werks   = gt_alv1-werks.
    lv_umwrk   = gt_alv1-umwrk.
    lv_text    = gt_alv1-return_yn.
  ENDLOOP.

  IF lv_text = 'X'.
    lv_text = 'YES'.
  ELSE.
    lv_text = 'NO'.
  ENDIF.

* smartform input data
  PERFORM sm_header_write USING lv_ivno lv_kunnr lv_kunnr1
                                lv_kunnr2 lv_umwrk
                                lv_ivtyp lv_werks lv_addrs.
  PERFORM sm_middle USING lv_ivno.
  IF lv_ivtyp+0(1) = 'C'.        "FI
    PERFORM sm_detail_write.
    PERFORM smart_form_setting.
  ELSE.
    PERFORM sm_detail_write_etc.
    PERFORM smart_form_setting_etc.
  ENDIF.

  UPDATE zgtmmt4500 SET:bwart = 'Y'
*  UPDATE zlet0005 SET:bwart = 'Y'
                      iv_print_yn = 'X'
                      iv_date = sy-datum
* [START] CSR NO : C20071114_69225
                      iv_cancel_yn = ' '
* [END]   CSR NO : C20071114_69225
   WHERE iv_no = lv_ivno.
  COMMIT WORK.

  PERFORM smart_form_finall_write .
  CLEAR: wa.
*  CLEAR: wa-pernr, wa-ename, wa-orgeh, wa-orgtx.

ENDFORM.                    " VIEW_PRINT
*&---------------------------------------------------------------------*
*&      Form  print_set
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_set .

  DATA: params LIKE pri_params,
        valid  TYPE c.

  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      destination    = 'ZP01'
      immediately    = 'X'
*     layout         = 'Z_100_124'
*     layout         = 'Z_65_130'
      line_size      = 125
      line_count     = 100
      layout         = 'Z_100_125'
    IMPORTING
      out_parameters = params
      valid          = valid.

  IF valid <> space.
    NEW-PAGE PRINT ON PARAMETERS params NO DIALOG.
  ELSE.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " print_set
*&---------------------------------------------------------------------*
*&      Form  f4_value_PERNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0042   text
*----------------------------------------------------------------------*
FORM f4_value_pernr  USING    p_xx.

  CASE p_xx.
    WHEN '1'.
      PERFORM get_f4_pernr  USING s_pernr-low.
    WHEN '2'.
      PERFORM get_f4_pernr  USING s_pernr-high.
  ENDCASE.

ENDFORM.                    " f4_value_PERNR
*&---------------------------------------------------------------------*
*&      Form  PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print .

  DATA: lv_flag.
  CLEAR: lv_flag.
  LOOP AT gt_alv1 WHERE sel = 'X'.
    SELECT SINGLE mandt INTO sy-mandt
       FROM zgtmmt4500
      WHERE iv_no = gt_alv1-iv_no
        AND reqst = 'X'.
    IF sy-subrc <> 0.
      MESSAGE i001 WITH
       gt_alv1-iv_no '통문번호가 삭제되었거나, 존재하지 않습니다.'.
      lv_flag = 'X'.
*      LEAVE SCREEN.
    ENDIF.
  ENDLOOP.
  IF lv_flag = 'X'.
    LEAVE SCREEN.
  ENDIF.

  CLEAR zgtmmt4500.

  wa-create_date = sy-datum.

*  SELECT SINGLE * FROM zlet0005 WHERE iv_no EQ gt_alv1-iv_no.
  SELECT SINGLE * FROM zgtmmt4500 WHERE iv_no EQ gt_alv1-iv_no.
  IF sy-subrc = 0.
    wa-pernr       = zgtmmt4500-pernr.
    wa-orgeh       = zgtmmt4500-brgeh.
    wa-orgtx       = zgtmmt4500-brgtx.
    wa-truck_no    = zgtmmt4500-truck_no.
    wa-drnam       = zgtmmt4500-driver_nm.
    wa-drpho       = zgtmmt4500-driver_telno.
    wa-etc_nm      = zgtmmt4500-etc_nm.
    wa-ton_no      = zgtmmt4500-ton_no.
    wa-ruser_nm    = zgtmmt4500-ruser_nm.
    wa-ruser_telno = zgtmmt4500-ruser_telno.
    wa-reqno       = zgtmmt4500-reqno.           "요청번호

    IF zgtmmt4500-bname IS INITIAL.
      wa-ename     = zgtmmt4500-ename.
    ELSE.
      wa-ename     = zgtmmt4500-bname.
    ENDIF.
  ENDIF.

ENDFORM.                    " PRINT
*&---------------------------------------------------------------------*
*&      Form  header_change
*&---------------------------------------------------------------------*
FORM header_change  USING    p_iv_no.

  CLEAR zgtmmt4500.
  SELECT SINGLE * FROM zgtmmt4500 WHERE iv_no EQ p_iv_no.
  IF sy-subrc = 0.
    zgtmmt4500-iv_print_yn  = 'X'.
    zgtmmt4500-print_cnt    = zgtmmt4500-print_cnt + 1.
*    MOVE-CORRESPONDING wa TO zgtmmt4500.
    zgtmmt4500-iv_date        = wa-create_date.
    zgtmmt4500-bernr          = wa-pernr.
    zgtmmt4500-bname          = wa-ename.
    zgtmmt4500-brgeh          = wa-orgeh.
    zgtmmt4500-brgtx          = wa-orgtx.
    zgtmmt4500-truck_no       = wa-truck_no.
    zgtmmt4500-driver_nm      = wa-drnam.
    zgtmmt4500-driver_telno   = wa-drpho.
    zgtmmt4500-bwart          = 'ZZ'.
    zgtmmt4500-create_user_id = sy-uname.
    MODIFY zgtmmt4500.
    IF sy-subrc = 0.
*      UPDATE zgtmmt4500 SET:iv_print_yn = 'X'
*       WHERE iv_no = p_iv_no.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

ENDFORM.                    " header_change
*&---------------------------------------------------------------------*
*&      Form  get_grid1
*&---------------------------------------------------------------------*
FORM get_grid1 .

  LOOP AT gt_alv1 WHERE iv_no EQ lv_ivno.
    CLEAR zgtmmt4500.
    SELECT SINGLE * FROM zgtmmt4500 WHERE iv_no EQ gt_alv1-iv_no.
    IF zgtmmt4500-iv_print_yn = 'X'.
      gt_alv1-iv_print_yn = 'X'.
      gt_alv1-icon1 = icon_print.
      MODIFY gt_alv1.
    ENDIF.
  ENDLOOP.

ENDFORM.                                                    " get_grid1
*&---------------------------------------------------------------------*
*&      Form  GET_f4_iv_type
*&---------------------------------------------------------------------*
FORM get_f4_iv_type  USING    p_type.

  DATA: BEGIN OF pov_type OCCURS 0,
          iv_type    LIKE zgtmmt4511-iv_type,
          iv_type_nm LIKE zgtmmt4511-iv_type_nm,
        END OF pov_type.

  DATA: lv_where(11) TYPE c.

  CASE p_bukrs.
    WHEN '1000'.
      lv_where = 'COCD1 = ''X'''.
    WHEN '2000'.
      lv_where = 'COCD2 = ''X'''.
    WHEN '3000'.
      lv_where = 'COCD3 = ''X'''.
*{ 기능개선 212693 - 추가
    WHEN '5000'.
      lv_where = 'COCD4 = ''X'''.
*} 기능개선 212693 - 추가
    WHEN OTHERS.
      RETURN.
  ENDCASE.

  CLEAR: pov_type[], pov_type.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE pov_type   FROM zgtmmt4511"  FROM zlet0007
     WHERE gubun = 'MA' AND (lv_where).
*       AND iv_type LIKE 'E__'.

  fieldtab-tabname   = 'ZGTMMT4511'. "'ZLET0007'.
  fieldtab-fieldname = 'IV_TYPE'.
  fieldtab-selectflag = 'X'.
  APPEND fieldtab.

  fieldtab-tabname   = 'ZGTMMT4511'. "''ZLET0007'.
  fieldtab-fieldname = 'IV_TYPE_NM'.
  fieldtab-selectflag = ' '.
  APPEND fieldtab.

  LOOP AT pov_type.
    valuetab-value = pov_type-iv_type.
    APPEND valuetab.
    valuetab-value = pov_type-iv_type_nm.
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

  IF j > 0.
    READ TABLE pov_type INDEX j.
    p_type = pov_type-iv_type.
  ENDIF.
  REFRESH : fieldtab, valuetab, pov_type.
  CLEAR   : j,fieldtab, valuetab, pov_type.
ENDFORM.                    " GET_f4_iv_type
*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0110 OUTPUT.
  SET PF-STATUS '110'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0110 INPUT.

  CASE sy-ucomm.
    WHEN 'SAVE'.
      IF r_1 = 'X'.
        IF wa-pernr IS INITIAL.
          MESSAGE s000 DISPLAY LIKE 'E' WITH '사원번호를 입력하십시오'.
          LEAVE SCREEN.
        ENDIF.
*-{자체개선 51966 - 엠트론 E99 차량정보 필수제외
        IF p_bukrs NE 3000 OR gt_alv1-iv_type NE 'E99'.
          IF wa-truck_no IS INITIAL.
            MESSAGE s000 DISPLAY LIKE 'E' WITH '차량번호를 입력하십시오'
            .
            LEAVE SCREEN.
          ENDIF.
          IF wa-drnam IS INITIAL.
            MESSAGE s000 DISPLAY LIKE 'E' WITH '운전자를 입력하십시오'.
            LEAVE SCREEN.
          ENDIF.
          IF wa-drpho IS INITIAL.
            MESSAGE s000 DISPLAY LIKE 'E' WITH '전화번호를 입력하십시오'
            .
            LEAVE SCREEN.
          ENDIF.
        ENDIF.
*-}자체개선 51966_2014.11.05
      ENDIF.
      UPDATE zgtmmt4500
        SET truck_no     = wa-truck_no
            driver_nm    = wa-drnam
            driver_telno = wa-drpho
            etc_nm       = wa-etc_nm
            ton_no       = wa-ton_no
            ruser_nm     = wa-ruser_nm
            ruser_telno  = wa-ruser_telno
            reqno        = wa-reqno
        WHERE iv_no = gt_alv1-iv_no.
      IF sy-subrc = 0.
        MESSAGE i000 WITH '저장되었습니다'.
      ELSE.
        MESSAGE i000 DISPLAY LIKE 'E' WITH '오류가 발생했습니다'.
      ENDIF.
      CLEAR lv_exit.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      lv_exit = 'X'.
      CLEAR: wa.
*      CLEAR: wa-pernr, wa-ename, wa-orgeh, wa-orgtx,
*             wa-truck_no, wa-drnam, wa-drpho, tm_truno.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*&      Module  INPUT_WA_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE input_wa_pernr INPUT.

  IF NOT wa-pernr IS INITIAL.
    SELECT SINGLE ename orgeh
      INTO (wa-ename, wa-orgeh)
      FROM zzpa0001
     WHERE begda <= sy-datum
       AND endda >= sy-datum
       AND pernr = wa-pernr.
    IF sy-subrc <> 0.
      CLEAR: wa-ename, wa-orgeh, wa-orgtx.
*      MESSAGE E000(ZLE1) WITH
*       '존재하지 않는 사원입니다'.
    ELSE.
      SELECT SINGLE orgtx INTO wa-orgtx
        FROM t527x
       WHERE sprsl = '3'
         AND orgeh = wa-orgeh
         AND begda <= sy-datum
         AND endda >= sy-datum.

    ENDIF.
  ELSE.
    CLEAR: wa-ename, wa-orgeh, wa-orgtx.
  ENDIF.
ENDMODULE.                 " INPUT_WA_PERNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_PERNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_pernr INPUT.

  PERFORM get_f4_pernr(sapmzle0001) USING ' '
                                          p_bukrs
                                          ' '
                                          ' '
                                          wa-pernr.

ENDMODULE.                 " F4_PERNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init OUTPUT.

  IF zgtmmt4500-iv_print_yn = 'X'.
    LOOP AT SCREEN.
      IF screen-name = 'WA-PERNR'    OR
         screen-name = 'WA-ENAME'    OR
         screen-name = 'WA-TRUCK_NO' OR
         screen-name = 'WA-DRNAM'    OR
         screen-name = 'WA-DRPHO'    OR
         screen-name = 'WA-ETC_NM'   OR
         screen-name = 'WA-TON_NO'   OR
         screen-name = 'WA-RUSER_NM' OR
         screen-name = 'WA-RUSER_TELNO'.
        screen-required = 0.
        screen-input    = 0.
      ENDIF.
      IF screen-name = 'WA-ETC_NM'.
        IF p_bukrs = '1000' OR zgtmmt4500-iv_type(1) = 'C'.
          screen-active = 0.
        ENDIF.
      ELSEIF screen-name = 'WA-TON_NO'.
        IF p_bukrs <> '1000'.
          screen-active = 0.
        ENDIF.
      ENDIF.

*{ 기능개선 214781 - 추가
      IF screen-group1 = 'G11'.    "요청번호 비활성화
        screen-input = 0.

        IF p_bukrs <> '1000'.
          screen-invisible = 1.
        ENDIF.
      ENDIF.
*} 기능개선 214781 - 추가

      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
*      IF SCREEN-NAME = 'WA-TRUCK_NO'.
*        IF WA-TRUCK_NO <> ' '.
*          SCREEN-INPUT = 0.
*        ENDIF.
*      ENDIF.
*      IF SCREEN-NAME = 'WA-DRNAM'.
*        IF WA-DRNAM <> ' '.
*          SCREEN-INPUT = 0.
*        ENDIF.
*      ENDIF.
*      IF SCREEN-NAME = 'WA-DRPHO'.
*        IF WA-DRPHO <> ' '.
*          SCREEN-INPUT = 0.
*        ENDIF.
*      ENDIF.
      IF screen-name = 'WA-ETC_NM'.
        IF p_bukrs = '1000' OR zgtmmt4500-iv_type(1) = 'C'.
          screen-active = 0.
        ENDIF.
      ELSEIF screen-name = 'WA-TON_NO'.
        IF p_bukrs <> '1000'.
          screen-active = 0.
        ENDIF.
      ENDIF.

*{ 기능개선 214781 - 추가
*___회사코드 '1000'이 아니면 비가시화
      IF screen-group1 = 'G11' AND p_bukrs <> '1000'.
        screen-input     = 0.
        screen-invisible = 1.
      ENDIF.

*___요청번호가 존재하면 비활성화
      IF screen-group2 = 'G21' AND wa-reqno IS NOT INITIAL.
        screen-input = 0.
      ENDIF.
*} 기능개선 214781 - 추가

      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " INIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  F4_TRUCK_NO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_truck_no INPUT.

  PERFORM f4_trnum(zler0020) USING wa-truck_no.

ENDMODULE.                 " F4_TRUCK_NO  INPUT
*&---------------------------------------------------------------------*
*&      Module  WA_OPTION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE wa_option INPUT.

*  CLEAR ZLET0017.
*  IF TM_TRUNO = WA-TRUCK_NO.
*       SELECT SINGLE * FROM ZLET0017 WHERE TRNUM EQ WA-TRUCK_NO.
*       CHECK SY-SUBRC = 0.
*       IF WA-DRNAM = ' '.
*         WA-DRNAM = ZLET0017-DRNAM.
*       ENDIF.
*       IF WA-DRPHO = ' '.
*         WA-DRPHO = ZLET0017-DRPHO.
*       ENDIF.
*  ELSE.
*    IF WA-TRUCK_NO <> ' '.
*       TM_TRUNO = WA-TRUCK_NO.
*       SELECT SINGLE * FROM ZLET0017 WHERE TRNUM EQ WA-TRUCK_NO.
*       IF SY-SUBRC = 0.
*          WA-DRNAM = ZLET0017-DRNAM.
*          WA-DRPHO = ZLET0017-DRPHO.
*       ELSE.
*          CLEAR: WA-DRNAM, WA-DRPHO.
*       ENDIF.
*    ELSE.
*      CLEAR: WA-DRNAM, WA-DRPHO.
*    ENDIF.
*  ENDIF.
ENDMODULE.                 " WA_OPTION  INPUT
*&---------------------------------------------------------------------*
*&      Form  CHK
*&---------------------------------------------------------------------*
FORM chk .

  CLEAR: lv_cnt.
  LOOP AT gt_alv1 WHERE sel = 'X'.
    ADD 1  TO lv_cnt.
    IF lv_cnt = 2.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF lv_cnt = 2.
    MESSAGE i000 WITH '한개의 통문번호를 선택하세요'.
    LEAVE SCREEN.
  ELSEIF lv_cnt = 0.
    MESSAGE i000 WITH 'DATA를 선택하세요'.
    LEAVE SCREEN.
  ENDIF.

*-{기능개선 48117 - 추가
  READ TABLE gt_alv1 WITH KEY sel = 'X'.
  CHECK sy-subrc = 0.

  PERFORM check_approval CHANGING gv_check.
  CHECK gv_check = ''.

  CLEAR gv_status.
  SELECT SINGLE iv_status
    FROM zlet0003
    INTO gv_status
    WHERE iv_no = gt_alv1-iv_no.
  CHECK sy-subrc = 0.

  IF gv_status = 'D'.
    MESSAGE s000 DISPLAY LIKE 'E' WITH '합의가 반려되었습니다'.
    LEAVE SCREEN.
  ELSEIF gv_status = 'E'.
    MESSAGE s000 DISPLAY LIKE 'E' WITH '승인이 반려되었습니다'.
    LEAVE SCREEN.
  ENDIF.

  IF gv_apnum = '1'.
    IF gv_prnum = '1'.     "C인 경우만 발행 가능
      IF gv_status <> 'C'.
        MESSAGE s000 DISPLAY LIKE 'E'
                             WITH '최종 승인이 완료되지 않았습니다'.
        LEAVE SCREEN.
      ENDIF.
    ELSEIF gv_prnum > '1'.
      MESSAGE s000 DISPLAY LIKE 'E'
                           WITH '출력가능차수가 유효하지 않습니다'.
      LEAVE SCREEN.
    ENDIF.
  ELSEIF gv_apnum = '2'.
    IF gv_prnum = '1'.     "B, C인 경우만 발행 가능
      IF gv_status = 'A'.
        MESSAGE s000 DISPLAY LIKE 'E'
                             WITH '1차 합의가 완료되지 않았습니다'.
        LEAVE SCREEN.
      ENDIF.
    ELSEIF gv_prnum = '2'. "C인 경우만 발행 가능
      IF gv_status <> 'C'.
        MESSAGE s000 DISPLAY LIKE 'E'
                             WITH '최종 승인이 완료되지 않았습니다'.
        LEAVE SCREEN.
      ENDIF.
    ELSEIF gv_prnum > '2'.
      MESSAGE s000 DISPLAY LIKE 'E'
                           WITH '출력가능차수가 유효하지 않습니다'.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.
*-}기능개선 48117_2014.10.23

ENDFORM.                    " CHK
*&---------------------------------------------------------------------*
*&      Form  SM_HEADER_WRITE
*&---------------------------------------------------------------------*
FORM sm_header_write  USING    p_ivno p_kunnr p_kunnr1 p_kunnr2 p_umwrk
                               p_type p_werks p_addrs.

* smartforms interface logic
* sold-to-party
  REFRESH: lv_sm01.
  CLEAR: lv_sm01.
*
* Page total 값
*  MOK = CNT DIV 10.
*  NAM = CNT MOD 10.
*  IF NOT NAM IS INITIAL.
*    LV_SM01-TOTNT = MOK + 1.
*  ELSE.
*    LV_SM01-TOTNT = MOK.
*  ENDIF.
*  CONDENSE LV_SM01-TOTNT.
** 회사주소
*  lv_sm01-wname = p_werks_t.
* 회사주소
*{ 2014031100058 거래명세서의 공급자란 회사명/주소 정보 수정
  SELECT SINGLE address
    INTO lv_sm01-wname
    FROM zlet0121 AS a
   INNER JOIN t001k AS b
      ON a~bukrs   = b~bukrs
   WHERE b~bwkey   = p_werks
     AND a~zbzarea = p_bzarea.

  IF sy-subrc <> 0.
    SELECT SINGLE address
      INTO lv_sm01-wname
      FROM zlet0121
     WHERE zbzarea = p_bzarea.
  ENDIF.

*  CLEAR T001W.
*  SELECT SINGLE * FROM T001W WHERE WERKS = P_WERKS.
*  IF T001W-ORT01 CO T001W-STRAS.
*    IF SY-FDPOS <> 0.
*      LV_SM01-WNAME = T001W-STRAS.
*    ENDIF.
*  ELSE.
*    CONCATENATE T001W-ORT01 ' ' T001W-STRAS
*    INTO LV_SM01-WNAME SEPARATED BY SPACE.
*  ENDIF.

* 회사명
* JS전선 대표이사명 변경 by J.Y.Lee 11/03/2011 C20111101_91139
*{ 2014030700032 거래명세서의 공급자란 대표자 정보 수정 요청

  SELECT SINGLE repres
                kr_butxt
                bukrs
    INTO (lv_sm01-ceonm, lv_sm01-compa,
          lv_sm01-bukrs)
    FROM zlet0122
   WHERE werks  = p_werks.

  IF lv_sm01-ceonm IS INITIAL AND sy-subrc <> 0.
    SELECT SINGLE a~repres
                  a~kr_butxt
                  a~bukrs
      INTO (lv_sm01-ceonm, lv_sm01-compa,
            lv_sm01-bukrs)
      FROM zlet0120 AS a
     INNER JOIN t001k AS b
        ON a~bukrs  = b~bukrs
     WHERE b~bwkey  = p_werks
       AND a~zmodul = 'LE'.
  ENDIF.

  CONCATENATE '대표이사' lv_sm01-ceonm
         INTO lv_sm01-ceonm SEPARATED BY space.

*  if p_bzarea+0(1) = 'J'.
*    lv_sm01-compa = 'JS전선(주)'.
*    lv_sm01-ceonm = '대표이사 최명규, 구자열'.
*  ELSE.
*
** [법인분리] 법인분리로 인한 대표자 성명 및 회사코드 셋팅
** 회사코드 필드가 기타통문의 경우 공란이기 때문에 플랜트로 제어
*    CLEAR : GV_BUKRS.
*    GV_BUKRS = P_WERKS.
*    IF P_WERKS+0(1) = '3'.
*      lv_sm01-compa = 'LS엠트론(주)'.
*      lv_sm01-ceonm = '대표이사 구자열'.
*    ELSE.
*      lv_sm01-compa = 'LS전선(주)'.
*      lv_sm01-ceonm = '대표이사 구자열'.
*    ENDIF.
*  ENDIF.
*} 2014030700032
*} 2014031100058

* 회사 전화번호
  SELECT SINGLE * FROM zlet0034 WHERE werks = p_werks.
  lv_sm01-cotel = zlet0034-telno.

  DATA: lv_city1  LIKE adrc-city1,
        lv_street LIKE adrc-street.
  CLEAR: lv_city1, lv_street.

* ship-to-party
  IF NOT p_kunnr IS INITIAL.  "구매처
    SELECT SINGLE name1 ort01 stras
     INTO (lv_sm01-rname, lv_city1, lv_street)  FROM lfa1
      WHERE lifnr = p_kunnr.
    IF sy-subrc <> 0.
      lv_sm01-rname = p_kunnr.
    ENDIF.
  ENDIF.
  IF NOT p_kunnr1 IS INITIAL.  "납품처
    SELECT SINGLE name1 ort01 stras
     INTO (lv_sm01-rname, lv_city1, lv_street)  FROM kna1
      WHERE kunnr = p_kunnr1.
    IF sy-subrc <> 0.
      lv_sm01-rname = p_kunnr1.
    ENDIF.
  ELSEIF p_kunnr2 IS NOT INITIAL.
    lv_sm01-rname = p_kunnr2.
  ENDIF.
  IF NOT p_umwrk IS INITIAL.
    SELECT SINGLE name1 ort01 stras
      INTO (lv_sm01-rname, lv_city1, lv_street)  FROM t001w
       WHERE werks = p_umwrk.
  ENDIF.

  lv_sm01-gname = lv_sm01-rname . "상호

  IF NOT p_addrs IS INITIAL.
    lv_sm01-raddr = p_addrs.
  ELSE.
    IF NOT p_kunnr IS INITIAL.  "구매처
      CONCATENATE lv_city1 '' lv_street
         INTO lv_sm01-raddr SEPARATED BY space.
    ENDIF.
    IF NOT p_kunnr1 IS INITIAL.  "납품처
      CONCATENATE lv_city1 '' lv_street
         INTO lv_sm01-raddr SEPARATED BY space.
    ENDIF.
  ENDIF.

*  CONCATENATE lfa1-ort01 '' lfa1-stras
*                            INTO lv_sm01-raddr SEPARATED BY space.

  IF wa-ruser_nm IS NOT INITIAL AND wa-ruser_telno IS NOT INITIAL.
    CONCATENATE wa-ruser_nm ' ' '(' wa-ruser_telno ')'
                INTO lv_sm01-ruser SEPARATED BY space.
  ELSEIF wa-ruser_nm IS NOT INITIAL.
    lv_sm01-ruser = wa-ruser_nm.
  ELSEIF wa-ruser_telno IS NOT INITIAL.
    CONCATENATE '(' wa-ruser_telno ')' INTO lv_sm01-ruser.
  ENDIF.

*[기능개선 42387 통문증 발행일자 오류 수정 요청 2014.09.02 by.H.M.LIM]
* 엠트론의 경우 발행일자, 출력일자 구분하여 표기
* 전선도 발행일자, 출력일자 구분 요청 - 통문프로세스 개선
  IF r_1 = 'X'.
*-{기능개선 48117 - 통문증 출력물 양식 수정 - 형민 임시 수정
*  IF gv_bukrs = '3000'.
*   발행일자
    CONCATENATE sy-datum+0(4) '년' sy-datum+4(2) '월' sy-datum+6(2)
                '일' sy-uzeit+0(2) ':' sy-uzeit+2(2)
                INTO lv_sm01-ivdat.
*   출력일자
    lv_sm01-ptdat = lv_sm01-ivdat.
*  ELSE.
**   발행일자
*    CONCATENATE SY-DATUM+0(4) '년' SY-DATUM+4(2) '월' SY-DATUM+6(2)
*                '일' SY-UZEIT+0(2) ':' SY-UZEIT+2(2)
*                INTO LV_SM01-IVDAT.
*  ENDIF.
  ELSE.
*  IF gv_bukrs = '3000'.
    DATA: lv_ivdat TYPE sy-datum,
          lv_ivtim TYPE sy-uzeit.

*   발행일자
    SELECT SINGLE iv_date create_time
      FROM zgtmmt4500
      INTO (lv_ivdat, lv_ivtim)
      WHERE iv_no = p_ivno.

    CONCATENATE lv_ivdat+0(4) '년' lv_ivdat+4(2) '월' lv_ivdat+6(2)
                '일' lv_ivtim+0(2) ':' lv_ivtim+2(2)
                INTO lv_sm01-ivdat.

*   출력일자
    CONCATENATE sy-datum+0(4) '년' sy-datum+4(2) '월' sy-datum+6(2)
                '일' sy-uzeit+0(2) ':' sy-uzeit+2(2)
                INTO lv_sm01-ptdat.
*   ELSE.
**   발행일자
*    CONCATENATE SY-DATUM+0(4) '년' SY-DATUM+4(2) '월' SY-DATUM+6(2)
*                '일' SY-UZEIT+0(2) ':' SY-UZEIT+2(2)
*                INTO LV_SM01-IVDAT.
*   ENDIF.
*-}기능개선 48117_2014.10.28
  ENDIF.
*
************************************************************************
  lv_sm01-ivnum = p_ivno.

*통문유형
  SELECT SINGLE *  FROM zgtmmt4511 WHERE bukrs eq p_bukrs AND iv_type  EQ p_type.
  CONCATENATE p_type ' 'zgtmmt4511-iv_type_nm INTO lv_sm01-ivtyp.
*  SELECT SINGLE *  FROM zlet0007 WHERE iv_type  EQ p_type.
*  CONCATENATE p_type ' ' zlet0007-iv_type_nm INTO lv_sm01-ivtyp.
*
*  CONCATENATE SY-DATUM+0(4) '년' SY-DATUM+4(2) '월' SY-DATUM+6(2)
*              '일' SY-UZEIT+0(2) ':' SY-UZEIT+2(2)
*              INTO LV_SM01-IVDAT.
  APPEND lv_sm01.
*
ENDFORM.                    " SM_HEADER_WRITE
*&---------------------------------------------------------------------*
*&      Form  SM_MIDDLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sm_middle  USING p_ivno.

  REFRESH: lv_sm02.  CLEAR: lv_sm02, zgtmmt4500, lv_ltext.
  SELECT SINGLE * FROM zgtmmt4500 WHERE iv_no = p_ivno.
  lv_sm02-pernr = wa-ename.         "출고담당
  lv_sm02-pernm = zgtmmt4500-ename.   "요청자
  lv_sm02-exti1 = zgtmmt4500-truck_no.
  IF zgtmmt4500-driver_nm <> ' ' AND zgtmmt4500-driver_telno <> ' '.
    CONCATENATE zgtmmt4500-driver_nm ' ' '(' zgtmmt4500-driver_telno ')'
                INTO lv_sm02-exti2 SEPARATED BY space.
  ELSEIF zgtmmt4500-driver_nm <> ' ' AND zgtmmt4500-driver_telno = ' '.
    lv_sm02-exti2 = zgtmmt4500-driver_nm.
  ELSEIF zgtmmt4500-driver_nm = ' ' AND zgtmmt4500-driver_telno <> ' '.
    CONCATENATE '(' zgtmmt4500-driver_telno ')'
                INTO lv_sm02-exti2.
  ENDIF.
*
*  IF zgtmmt4500-TON_NO = ' '.
*    IF P_BUKRS = '1000' AND
*       LV_IVTYP <> 'E10' AND LV_IVTYP <> 'E11' AND LV_IVTYP <> 'E99'.
*      LV_LTEXT = zgtmmt4500-ETC_NM.
*    ENDIF.
*  ELSE.
*-{기능개선 48117 - E10,E11,E99유형 사유 정보 삭제- 전선
  IF p_bukrs = '1000'.
    IF lv_ivtyp = 'E10' OR lv_ivtyp = 'E11' OR lv_ivtyp = 'E99'.
      lv_ltext = zgtmmt4500-ton_no.
    ELSE.
      IF zgtmmt4500-ton_no = ' '. "톤수 유무에 따라 표기방법 차이
        lv_ltext = zgtmmt4500-etc_nm.
      ELSE.
        CONCATENATE zgtmmt4500-ton_no '/' zgtmmt4500-etc_nm INTO lv_ltext.
      ENDIF.
    ENDIF.
*-{기능개선 53433 - 엠트론 특기사항 정보 표기
  ELSE.
    IF zgtmmt4500-ton_no = ' '.
      lv_ltext = zgtmmt4500-etc_nm.
    ELSE.
      CONCATENATE zgtmmt4500-ton_no '/' zgtmmt4500-etc_nm INTO lv_ltext.
    ENDIF.
  ENDIF.
*-}기능개선 53433_2014.11.19
*-}기능개선 48117_2014.11.03
*  ENDIF.

  IF zgtmmt4500-return_yn = 'X'.
    CONCATENATE lv_ltext(60) '('
      '반입대상' ')' INTO lv_sm02-ltext .
  ELSE.
    lv_sm02-ltext = lv_ltext.
  ENDIF.

*-{기능개선 48117 - 발행자,합의자,승인자 정보
  IF gv_check = ''.
    SELECT SINGLE req_id    req_nm
                  app_id1   app_nm1
                  app_id2   app_nm2
                  req_date  app_date1        "기능개선 249737 - 추가
                  app_date2                  "기능개선 249737 - 추가
      FROM zlet0003
      INTO (lv_sm02-sgno1, lv_sm02-sgnm1,
            lv_sm02-sgno2, lv_sm02-sgnm2,
            lv_sm02-sgno3, lv_sm02-sgnm3,
            lv_sm02-sgdt1, lv_sm02-sgdt2,    "기능개선 249737 - 추가
            lv_sm02-sgdt3)                   "기능개선 249737 - 추가
      WHERE iv_no = p_ivno.
    IF sy-subrc = 0 AND gv_status = 'B'.
      CLEAR: lv_sm02-sgno3, lv_sm02-sgnm3,
             lv_sm02-sgdt3.                  "ㅔ기능개선 249737 - 추가
    ENDIF.
    lv_sm02-apnum = gv_apnum.
  ENDIF.
*-}기능개선 48117_2014.10.23


  APPEND lv_sm02.

ENDFORM.                    " SM_MIDDLE
*&---------------------------------------------------------------------*
*&      Form  SM_DETAIL_WRITE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sm_detail_write .

  REFRESH: lv_sm03.  CLEAR: lv_sm03.

  LOOP AT gt_alv1 WHERE iv_no = lv_ivno.
    lv_sm03-assno   = gt_alv1-asset_no.
    lv_sm03-assnm   = gt_alv1-asset_nm.
    lv_sm03-assec   = gt_alv1-asset_spec.
    lv_sm03-lfimg   = gt_alv1-lfimg.
    lv_sm03-vrkme   = gt_alv1-mtr_unit.
    lv_sm03-dmbtr   = gt_alv1-asset_amt.
    lv_sm03-waers   = 'KRW'.
    APPEND lv_sm03.  CLEAR lv_sm03.

*/ EIDT START BY G.T.JUNG AT 2016.11.17
    IF gt_alv1-zpdf IS NOT INITIAL.
      SET PARAMETER ID 'CV1' FIELD gt_alv1-zpdf.
      SET PARAMETER ID 'CV2' FIELD 'VLE'.
      SET PARAMETER ID 'CV3' FIELD '000'.
      SET PARAMETER ID 'CV4' FIELD '00'.

*        CALL FUNCTION 'ZFI_FILE_SEL_MULTI'
      CALL FUNCTION 'ZLE_FILE_SEL_MULTI'
        EXPORTING
          i_doc    = gt_alv1-zpdf
          i_title  = '기타 통문'
          i_append = 'X'
        TABLES
          it_file  = gt_file[].

    ENDIF.
*/ EIDT END
  ENDLOOP.

  DESCRIBE TABLE lv_sm03 LINES cnt.

  IF p_bukrs(1) = '3'.
    mok = cnt DIV 10.
    nam = cnt MOD 10.
  ELSE.
    mok = cnt DIV 8.
    nam = cnt MOD 8.
  ENDIF.
  IF NOT nam IS INITIAL.
    lv_sm01-totnt = mok + 1.
  ELSE.
    lv_sm01-totnt = mok.
  ENDIF.
  CONDENSE lv_sm01-totnt.

  MODIFY lv_sm01 INDEX 1 TRANSPORTING totnt.

ENDFORM.                    " SM_DETAIL_WRITE
*&---------------------------------------------------------------------*
*&      Form  SMART_FORM_SETTING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM smart_form_setting .
  DATA: rtab  LIKE kunnr_ran  OCCURS 0 WITH HEADER LINE.
  DATA: ssfcrespd TYPE ssfcrespd,
        ssfcrescl TYPE ssfcrescl,
        ssfcresop TYPE ssfcresop.

  IF p_bukrs+0(1) = '6'."'3'.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING     "'ZM_FI_TRADE_DOCUMENT'
        formname           = 'ZM_FI_GO_TRADE_DOCUMENT' "가온전선
      IMPORTING
        fm_name            = func_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
  ELSE.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'Z_FI_TRADE_DOCUMENT' "LS전선
      IMPORTING
        fm_name            = func_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
  ENDIF.

  control_parameters-getotf = 'X'.
  control_parameters-no_dialog = 'X'.
*  control_parameters-no_close = 'X'.
*  control_parameters-getotf = 'X'.
*  CONTROL_PARAMETERS-PREVIEW = 'X'.
*  OUTPUT_OPTIONS-TDDEST = 'ZP01'.
*  OUTPUT_OPTIONS-TDPRINTER = 'ZP01'.
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
      lv_text              = lv_text
    IMPORTING
      document_output_info = ssfcrespd
      job_output_info      = ssfcrescl
      job_output_options   = ssfcresop
    TABLES
      lv_sm03              = lv_sm03
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
  UPDATE zgtmmt4500 SET:bwart = 'ㅋ'
   WHERE iv_no = lv_ivno.
  COMMIT WORK.

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

*  CALL FUNCTION 'SSFCOMP_OTF_OUTPUT'
*    EXPORTING
*      input_params   = ssfpp
*      archive_params = arc_params
*      otf_data       = otf[]
*      bmnopri        = ''
*    IMPORTING
*      output_params  = ssfpp
*    EXCEPTIONS
*      empty_otf      = 1.


  UPDATE zgtmmt4500 SET:bwart = 'X'
   WHERE iv_no = lv_ivno.
  COMMIT WORK.

  IF sy-subrc = 0.
*    IF sy-msgty = 'S' AND sy-msgno = '60'.
*     Print 되면 통문 header에 정보 입력
    PERFORM header_change USING lv_ivno.
    PERFORM get_grid1.
*    ENDIF.
  ENDIF.

ENDFORM.                    " SMART_FORM_FINALL_WRITE
*&---------------------------------------------------------------------*
*&      Form  SM_DETAIL_WRITE_ETC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sm_detail_write_etc .
  DATA: BEGIN OF lt_long OCCURS 0,
          text(200),
        END   OF lt_long.

  DATA: lv_dmbtr(18).

  REFRESH: lv_sm03.  CLEAR: lv_sm03.

  LOOP AT gt_alv1  WHERE iv_no = lv_ivno.
    lv_sm03-posnr   = gt_alv1-iv_seq.
*{ 기능개선 276257 - 추가_S
    IF gt_alv1-matnr IS NOT INITIAL.
      WRITE: gt_alv1-matnr TO lv_sm03-maktx USING EDIT MASK '==MATN1'.
      CONCATENATE lv_sm03-maktx gt_alv1-maktx
             INTO lv_sm03-maktx SEPARATED BY space.
    ELSE.
*} 기능개선 276257 - 추가_E
      lv_sm03-maktx   = gt_alv1-maktx.
    ENDIF.

    CALL FUNCTION 'ZSD_SPLIT_STRING'
      EXPORTING
        i_str   = lv_sm03-maktx
        str_len = 50
      IMPORTING
        o_str   = lv_sm03-maktx
      TABLES
        it_str  = lt_long.

    lv_sm03-lfimg   = gt_alv1-lfimg.
    lv_sm03-vrkme   = gt_alv1-mtr_unit.
    lv_sm03-dmbtr   = gt_alv1-dmbtr .
    lv_sm03-waers   = 'KRW'.
    APPEND lv_sm03.  CLEAR lv_sm03.
  ENDLOOP.

  DESCRIBE TABLE lv_sm03 LINES cnt.

  IF p_bukrs(1) = '3'.
    mok = cnt DIV 10.
    nam = cnt MOD 10.
  ELSE.
    mok = cnt DIV 8.
    nam = cnt MOD 8.
  ENDIF.
  IF NOT nam IS INITIAL.
    lv_sm01-totnt = mok + 1.
  ELSE.
    lv_sm01-totnt = mok.
  ENDIF.
  CONDENSE lv_sm01-totnt.

  MODIFY lv_sm01 INDEX 1 TRANSPORTING totnt.

ENDFORM.                    " SM_DETAIL_WRITE_ETC
*&---------------------------------------------------------------------*
*&      Form  SMART_FORM_SETTING_ETC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM smart_form_setting_etc .

  DATA: rtab  LIKE kunnr_ran  OCCURS 0 WITH HEADER LINE.
  DATA: ssfcrespd TYPE ssfcrespd,
        ssfcrescl TYPE ssfcrescl,
        ssfcresop TYPE ssfcresop.

  IF p_bukrs+0(1) = '6'."'3'.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING        " 'ZM_ET_TRADE_DOCUMENT''
        formname           = 'ZM_ET_GO_TRADE_DOCUMENT' "GAON
      IMPORTING
        fm_name            = func_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
  ELSE.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'Z_ET_TRADE_DOCUMENT' "LS CABLE
      IMPORTING
        fm_name            = func_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
  ENDIF.

  control_parameters-getotf = 'X'.
  control_parameters-no_dialog = 'X'.
*  control_parameters-no_close = 'X'.
*  control_parameters-getotf = 'X'.
*  CONTROL_PARAMETERS-PREVIEW = 'X'.
*  OUTPUT_OPTIONS-TDDEST = 'ZP01'.
*  OUTPUT_OPTIONS-TDPRINTER = 'ZP01'.
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
      lv_text              = lv_text
    IMPORTING
      document_output_info = ssfcrespd
      job_output_info      = ssfcrescl
      job_output_options   = ssfcresop
    TABLES
      lv_sm03              = lv_sm03
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

ENDFORM.                    " SMART_FORM_SETTING_ETC
*&---------------------------------------------------------------------*
*&      Form  get_f4_pernr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_XX  text
*----------------------------------------------------------------------*
FORM get_f4_pernr  USING    p_pernr.

  DATA: BEGIN OF pov_per OCCURS 0,
          pernr LIKE zzpa0001-pernr,
          ename LIKE zzpa0001-ename,
          orgeh LIKE t527x-orgeh,
          orgtx LIKE t527x-orgtx,
        END OF pov_per.

  CLEAR: pov_per[], pov_per.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE pov_per
    FROM zzpa0001
   WHERE begda <= sy-datum
     AND endda >= sy-datum.
  IF NOT pov_per[] IS INITIAL.
    DATA: lt_t527x LIKE t527x OCCURS 0 WITH HEADER LINE.
    CLEAR: lt_t527x[].
    SELECT *
     INTO CORRESPONDING FIELDS OF TABLE lt_t527x
      FROM t527x
       FOR ALL ENTRIES IN pov_per
     WHERE sprsl = '3'
       AND orgeh = pov_per-orgeh
       AND begda <= sy-datum
       AND endda >= sy-datum.
    LOOP AT pov_per.
      READ TABLE lt_t527x
        WITH KEY orgeh = pov_per-orgeh.
      IF sy-subrc = 0.
        pov_per-orgtx = lt_t527x-orgtx.
        MODIFY pov_per.
      ENDIF.
    ENDLOOP.
  ENDIF.

  fieldtab-tabname   = 'ZZPA0001'.
  fieldtab-fieldname = 'PERNR'.
  fieldtab-selectflag = 'X'.
  APPEND fieldtab.

  fieldtab-tabname   = 'ZZPA0001'.
  fieldtab-fieldname = 'ENAME'.
  fieldtab-selectflag = ' '.
  APPEND fieldtab.

  fieldtab-tabname   = 'T527X'.
  fieldtab-fieldname = 'ORGTX'.
  fieldtab-selectflag = ' '.
  APPEND fieldtab.

  LOOP AT pov_per.
    valuetab-value = pov_per-pernr.
    APPEND valuetab.
    valuetab-value = pov_per-ename.
    APPEND valuetab.
    valuetab-value = pov_per-orgtx.
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

  IF j > 0.
    READ TABLE pov_per INDEX j.
    p_pernr = pov_per-pernr.
  ENDIF.
  REFRESH : fieldtab, valuetab, pov_per.
  CLEAR   : j,fieldtab, valuetab, pov_per.


ENDFORM.                    " get_f4_pernr
*&---------------------------------------------------------------------*
*&      Form  CANCEL_TONG_NO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cancel_tong_no .

* [START] CSR NO : C20071114_69225
  LOOP AT gt_alv1 WHERE sel = 'X'.
    SELECT SINGLE *
      FROM zgtmmt4500
     WHERE iv_no = gt_alv1-iv_no
       AND out_yn = 'X'.

    IF sy-subrc = 0.
      MESSAGE i000 WITH '통문확정 취소후 발행취소하세요.'.
      LEAVE SCREEN.
    ENDIF.
  ENDLOOP.
* [END]   CSR NO : C20071114_69225

  DATA: lv_return.
  PERFORM pop_up_confirm(zler0004) USING '< 확인 >'
                               '통문증 취소하시겠습니까?'
                      CHANGING lv_return.
  CHECK lv_return = 'J'.

  LOOP AT gt_alv1 WHERE sel = 'X'.
    UPDATE zgtmmt4500 SET:iv_print_yn = ' '
* [START] CSR NO : C20071114_69225
                        iv_cancel_yn = 'X'
                        change_date  = sy-datum
                        change_time  = sy-uzeit
* [END]   CSR NO : C20071114_69225
     WHERE iv_no = gt_alv1-iv_no.
    COMMIT WORK.

    DELETE gt_alv1 WHERE iv_no = gt_alv1-iv_no.
  ENDLOOP.

ENDFORM.                    " CANCEL_TONG_NO
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
*    MESSAGE e002 WITH '사업장에 대한 권한이 없읍니다'
*                      p_bzarea.
*  ENDIF.

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172 WITH P_BUKRS. "회사코드[&] 작업권한을 확인하세요.

  IF S_WERKS[] IS NOT INITIAL.
      LOOP AT S_WERKS INTO DATA(LS_WERKS).
        AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
                     ID 'WERKS' FIELD LS_WERKS-LOW.

        CHECK SY-SUBRC <> 0.

        SET CURSOR FIELD 'S_WERKS-LOW'.
        MESSAGE E106 WITH S_WERKS-LOW. "플랜트 [&] 작업권한을 확인하세요.
      ENDLOOP.
  ENDIF.

ENDFORM.                    " authority_check
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
    MESSAGE e000 WITH '존재하지 않는 회사코드입니다'.
  ENDIF.

ENDFORM.                    " check_bukrs
*&---------------------------------------------------------------------*
*&      Form  f4_value_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f4_value_bukrs.

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
    WHERE ktopl =  '1000'.

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

ENDFORM.                    " f4_value_bukrs
*&---------------------------------------------------------------------*
*&      Form  f4_value_werks
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f4_value_werks USING p_gubun.

  DATA: BEGIN OF lt_t001w OCCURS 0,
          werks LIKE t001w-werks,
          name1 LIKE t001w-name1,
        END   OF lt_t001w.

  DATA: lt_fields   TYPE TABLE OF help_value WITH HEADER LINE,
        lt_select   TYPE TABLE OF help_vtab  WITH HEADER LINE,
        lt_valuetab TYPE TABLE OF text79_d   WITH HEADER LINE,
        lv_value    TYPE t001w-werks.

  SELECT w~werks w~name1
    FROM t001k AS k
         INNER JOIN t001w    AS w ON w~bwkey = k~bwkey
         INNER JOIN zlet0034 AS z ON z~werks = w~werks
    INTO TABLE lt_t001w
    WHERE k~bukrs  = p_bukrs
      AND z~bzarea = p_bzarea.

  CHECK sy-subrc = 0.

  lt_fields-tabname    = 'T001W'.
  lt_fields-fieldname  = 'WERKS'.
  lt_fields-selectflag = 'X'.
  APPEND lt_fields.
  lt_fields-tabname    = 'T001W'.
  lt_fields-fieldname  = 'NAME1'.
  lt_fields-selectflag = ' '.
  APPEND lt_fields.

  LOOP AT lt_t001w.
    lt_valuetab = lt_t001w-werks.
    APPEND lt_valuetab.
    lt_valuetab = lt_t001w-name1.
    APPEND lt_valuetab.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE_EXT'
    IMPORTING
      select_value  = lv_value
    TABLES
      fields        = lt_fields
      select_values = lt_select
      valuetab      = lt_valuetab.

  CASE p_gubun.
    WHEN '1'.
      s_werks-low  = lv_value.
    WHEN '2'.
      s_werks-high = lv_value.
  ENDCASE.

ENDFORM.                    " f4_value_werks
*&---------------------------------------------------------------------*
*&      Form  check_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_approval CHANGING p_check TYPE c.

  CLEAR: gv_apnum, gv_prnum, p_check.

  IF p_bukrs = '1000'.
    SELECT SINGLE apnum prnum
      FROM zgtmmt4511
      INTO (gv_apnum, gv_prnum)
      WHERE iv_type = gt_alv1-iv_type.

    IF gv_apnum = '0'.
      p_check = 'X'.
    ELSEIF gv_apnum > '2'.
      MESSAGE e000 WITH '결재차수가 유효하지 않습니다'.
    ENDIF.
*{ 기능개선 239718 - 추가
  ELSEIF p_bukrs = '3000'.
    SELECT SINGLE apnum3 prnum3
      FROM zgtmmt4511
      INTO (gv_apnum, gv_prnum)
      WHERE iv_type = gt_alv1-iv_type.

    IF gv_apnum = '0'.
      p_check = 'X'.
    ELSEIF gv_apnum > '2'.
      MESSAGE e000 WITH '결재차수가 유효하지 않습니다'.
    ENDIF.
*} 기능개선 239718 - 추가
  ELSE.
    p_check = 'X'.
  ENDIF.

ENDFORM.                    " check_approval
*&---------------------------------------------------------------------*
*&      Module  INPUT_WA_TRUCK_NO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE input_wa_truck_no INPUT.

*{ 기능개선 77487 - 추가
  IF strlen( wa-truck_no ) = 4.
    PERFORM f4_truno USING wa-truck_no.
    PERFORM get_drnam_drtel USING wa-truck_no wa-drnam wa-drpho.
  ELSEIF wa-truck_no IS NOT INITIAL.
    PERFORM get_drnam_drtel USING wa-truck_no wa-drnam wa-drpho.
  ENDIF.
*} 기능개선 77487 2015.05.08 -추가

ENDMODULE.                 " INPUT_WA_TRUCK_NO  INPUT
*&---------------------------------------------------------------------*
*&      Form  F4_TRUNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_TRUCK_NO  text
*----------------------------------------------------------------------*
FORM f4_truno  USING    pv_truck_no.

  DATA : lv_trnum(20),
         lv_line(20) TYPE i.

  CLEAR   : selectfield, select_value, ld_tabix, gt_truck,
             it_fields, scr_fields, feld_table, lv_trnum, lv_line.
  REFRESH : it_fields, scr_fields, feld_table, gt_truck.

  CONCATENATE '%' pv_truck_no INTO lv_trnum.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_truck
    FROM zlet0017
   WHERE trnum LIKE lv_trnum.

  IF sy-subrc <> 0.
    EXIT.
  ELSE.
    DESCRIBE TABLE gt_truck LINES lv_line.
    IF lv_line = 1.
      CLEAR pv_truck_no.
      READ TABLE gt_truck INDEX 1.
      IF sy-subrc = 0.
        pv_truck_no = gt_truck-trnum.
      ENDIF.
      EXIT.
    ENDIF.
  ENDIF.

  it_fields-tabname    = 'ZLET0017'.
  it_fields-fieldname  = 'TRNUM'.
  it_fields-selectflag = 'X'.
  APPEND it_fields.

  it_fields-tabname    = 'ZLET0017'.
  it_fields-fieldname  = 'DRNAM'.
  it_fields-selectflag = ' '.
  APPEND it_fields.

  it_fields-tabname    = 'ZLET0017'.
  it_fields-fieldname  = 'DRPHO'.
  it_fields-selectflag = ' '.
  APPEND it_fields.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = selectfield
    IMPORTING
      ind                          = ld_tabix
      select_value                 = select_value
    TABLES
      fields                       = it_fields
      full_table                   = gt_truck
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

  CHECK NOT ld_tabix IS INITIAL.
  READ TABLE gt_truck INDEX ld_tabix.
  pv_truck_no = gt_truck-trnum.

ENDFORM.                    " F4_TRUNO
*&---------------------------------------------------------------------*
*&      Form  GET_DRNAM_DRTEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_TRUCK_NO  text
*      -->P_WA_DRNAM  text
*      -->P_WA_DRPHO  text
*----------------------------------------------------------------------*
FORM get_drnam_drtel  USING    pv_truck_no
                               pv_drnam
                               pv_drpho.
*{ 기능개선 239072 - 변경
  DATA: lv_drnam LIKE zlet0017-drnam,
        lv_drpho LIKE zlet0017-drpho.

  CLEAR : lv_drnam, lv_drpho.

  SELECT SINGLE drnam
                drpho
    INTO (lv_drnam, lv_drpho)
    FROM zlet0017
   WHERE trnum = pv_truck_no.

  IF sy-subrc = 0 AND pv_drnam IS INITIAL AND pv_drpho IS INITIAL.
    pv_drnam = lv_drnam.
    pv_drpho = lv_drpho.
  ENDIF.

*  CLEAR : PV_DRNAM, PV_DRTEL.
*
*  SELECT SINGLE DRNAM DRPHO
*    INTO (PV_DRNAM, PV_DRPHO)
*    FROM ZLET0017
*   WHERE TRNUM = PV_TRUCK_NO.
*} 기능개선 239072 - 변경

ENDFORM.                    " GET_DRNAM_DRTEL

FORM call_simple_approval  USING    p_reqno.

  CALL FUNCTION 'ZSA1_LE_MAKE_SEND_DATA'
    EXPORTING
      i_iv_no = p_reqno
      i_ztype = 'L1'
      i_bukrs = P_bukrs.


ENDFORM.


INCLUDE ZGTMMR4520F01.
*INCLUDE zler0017f01.
