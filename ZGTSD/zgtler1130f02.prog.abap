*&---------------------------------------------------------------------*
*& Include          ZGTLER1130F02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  data_query
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ALV1  text
*----------------------------------------------------------------------*
FORM data_query  TABLES   pt_alv1 LIKE gt_alv1[]
                          pr_vbeln LIKE r_vbeln[].

  PERFORM get_data TABLES pt_alv1 pr_vbeln.

  SORT pt_alv1 BY vbeln tknum.
  DELETE ADJACENT DUPLICATES FROM pt_alv1
     COMPARING vbeln tknum.

*/ 영업그룹, 사원번호등 이름 가져오기
  PERFORM data_process.

*/ 수정요청사항 2005.03.15
  CHECK NOT pt_alv1[] IS INITIAL.

*/ 데이타 가공
  CHECK NOT pt_alv1[] IS INITIAL.
  PERFORM modify_alv1 TABLES pt_alv1.

*--[기능개선 286869  추가
  IF gf_request IS NOT INITIAL.
    PERFORM  set_request_data TABLES pt_alv1.
  ENDIF.
*--]기능개선 286869 - 20190808

  SORT pt_alv1 BY vbeln.


ENDFORM.                    " data_query
*&---------------------------------------------------------------------*
*&      Form  MODIFY_ALV1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_ALV1  text
*----------------------------------------------------------------------*
FORM modify_alv1  TABLES   pt_alv1 LIKE gt_alv1[].

  DATA: lv_adrnr  LIKE vbpa-adrnr.
  DATA: lv_postal     LIKE adrc-post_code1,
        lv_city1      LIKE adrc-city1,
        lv_street     LIKE adrc-street,
        lv_rname      LIKE adrc-name1,
        lv_adres(100).

  CLEAR: lv_adrnr, lv_postal, lv_city1, lv_street, lv_adres.

*/ 판매처
  DATA: lt_knag LIKE kna1 OCCURS 0 WITH HEADER LINE.

  CLEAR: lt_knag[].
  SELECT * INTO TABLE lt_knag
    FROM kna1
     FOR ALL ENTRIES IN pt_alv1
  WHERE kunnr = pt_alv1-kunag.

*/ 인도조건
  DATA: lt_tinct LIKE tinct OCCURS 0 WITH HEADER LINE.

  CLEAR: lt_tinct[].
  SELECT * INTO TABLE lt_tinct
    FROM tinct
  WHERE spras = sy-langu.

*/ 납품유형
  DATA: lt_tvlkt LIKE tvlkt OCCURS 0 WITH HEADER LINE.

  CLEAR: lt_tvlkt[].
  SELECT * INTO TABLE lt_tvlkt
    FROM tvlkt
  WHERE spras = sy-langu.

*/ 운송경로
  DATA: lt_tvrot LIKE tvrot OCCURS 0 WITH HEADER LINE.

  CLEAR: lt_tvrot[].
  SELECT * INTO TABLE lt_tvrot
    FROM tvrot
  WHERE spras = sy-langu.

*/ 출하지점
  DATA: lt_tvstt LIKE tvstt OCCURS 0 WITH HEADER LINE.

  CLEAR: lt_tvstt[].
  SELECT * INTO TABLE lt_tvstt
    FROM tvstt
  WHERE spras = sy-langu.

*/ 출하조건
  DATA: lt_tvsbt LIKE tvsbt OCCURS 0 WITH HEADER LINE.

  CLEAR: lt_tvsbt[].
  SELECT * INTO TABLE lt_tvsbt
    FROM tvsbt
  WHERE spras = sy-langu.

*/ 납지
  DATA: BEGIN OF lt_zlet0400 OCCURS 0,
          dlvrq LIKE zlet0400-dlvrq,
          vbeln LIKE zlet0402-vgbel,
          city1 LIKE zlet0400-city1,
        END OF lt_zlet0400.
  DATA(lt_temp) = pt_alv1[].
  SORT lt_temp BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING vbeln.
  IF lt_temp[] IS NOT INITIAL.
    SELECT a~vgbel AS vbeln,
           a~dlvrq,
           b~city1
      FROM zlet0402 AS a INNER JOIN zlet0400 AS b
                         ON a~dlvrq = b~dlvrq
       FOR ALL ENTRIES IN @lt_temp
     WHERE a~vgbel EQ @lt_temp-vbeln
      INTO CORRESPONDING FIELDS OF TABLE @lt_zlet0400.
    SORT lt_zlet0400 BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_zlet0400 COMPARING vbeln.
  ENDIF.

*/ DATA PROCESS ~~~~~~
  DATA: lv_route LIKE vttk-route.
  LOOP AT pt_alv1.

*  상사수출
    IF pt_alv1-kdkg4 EQ '4S'.
      IF pt_alv1-vsbed NE '03'.
        pt_alv1-vsbed = '03'.
      ENDIF.
    ENDIF.

*/ 해상운송생성 여부 MKJANG
    IF pt_alv1-vsbed = '03' OR pt_alv1-vsbed = '04'.
      READ TABLE lt_vttk WITH KEY vbeln = pt_alv1-vbeln
                                  shtyp = 'Z103'.
      IF sy-subrc = 0.
        pt_alv1-trsta_yn  = 'Y'.
        pt_alv1-tknum_sea = lt_vttk-tknum.
        pt_alv1-text1     = lt_vttk-text1.
        pt_alv1-text2     = lt_vttk-text2.
        pt_alv1-text3     = lt_vttk-text3.
        pt_alv1-text4     = lt_vttk-text4.

        SELECT SINGLE bezei INTO pt_alv1-route_t2 FROM tvrot
          WHERE spras = sy-langu
            AND route = lt_vttk-route.
      ENDIF.
    ENDIF.

    READ TABLE lt_knag  WITH KEY kunnr = pt_alv1-kunag.
    IF sy-subrc = 0.
      pt_alv1-kunag_t  = lt_knag-name1.
    ENDIF.

    READ TABLE lt_tinct WITH KEY inco1 = pt_alv1-inco1.
    IF sy-subrc = 0.
      pt_alv1-inco1_t  = lt_tinct-bezei.
    ENDIF.

    READ TABLE lt_tvlkt WITH KEY lfart = pt_alv1-lfart.
    IF sy-subrc = 0.
      pt_alv1-lfart_t  = lt_tvlkt-vtext.
    ENDIF.

    READ TABLE lt_tvrot WITH KEY route = pt_alv1-route.
    IF sy-subrc = 0.
      pt_alv1-route_t  = lt_tvrot-bezei.
    ENDIF.
*   선적문서의 운송경로에 해당하는 운송경로 명
    READ TABLE lt_vttk WITH KEY vbeln = pt_alv1-vbeln
                                shtyp = 'Z103'.
    IF sy-subrc = 0.
      pt_alv1-route2 = lt_vttk-route.
      READ TABLE lt_tvrot WITH KEY route = pt_alv1-route2.
      IF sy-subrc = 0.
        pt_alv1-route_t2  = lt_tvrot-bezei.
      ENDIF.
    ENDIF.
*
    READ TABLE lt_tvstt WITH KEY vstel = pt_alv1-vstel.
    IF sy-subrc = 0.
      pt_alv1-vstel_t  = lt_tvstt-vtext.
    ENDIF.

    READ TABLE lt_tvsbt WITH KEY vsbed = pt_alv1-vsbed.
    IF sy-subrc = 0.
      pt_alv1-vsbed_t  = lt_tvsbt-vtext.
    ENDIF.

    SELECT SINGLE adrnr INTO lv_adrnr
       FROM vbpa
      WHERE vbeln = pt_alv1-vbeln
        AND posnr = '000000'
    AND parvw = 'WE'.

* 납품처
    SELECT SINGLE name1 post_code1 city1 street
       INTO (lv_rname, lv_postal, lv_city1, lv_street)
       FROM adrc
    WHERE addrnumber = lv_adrnr.

    CONCATENATE lv_postal lv_city1 INTO lv_adres
       SEPARATED BY space.

    pt_alv1-kunnr_t  = lv_rname .
    pt_alv1-ort01    = lv_adres.
    pt_alv1-stras    = lv_street.

*   납지
    DATA(ls_zlet0400) = VALUE #( lt_zlet0400[ vbeln = pt_alv1-vbeln ] OPTIONAL ).
    IF ls_zlet0400 IS NOT INITIAL.
      pt_alv1-city1 = ls_zlet0400-city1.
    ENDIF.

    MODIFY pt_alv1.
    CLEAR: pt_alv1.
    CLEAR: ls_zlet0400.
  ENDLOOP.

ENDFORM.                    " MODIFY_ALV1
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
      extension = 200.

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
      i_parent = docking.

*/ 출력할 필드 속성을 정의
  PERFORM set_field_catalogs_grid1 .

*/ LAYOUT SETTING
  PERFORM set_option_grid1.

  CALL METHOD grid1->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  alv_variant-report = sy-repid.
  alv_variant-handle = '0001'.

*/ ALV DATA 뿌려줌
  CALL METHOD grid1->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      it_toolbar_excluding = gt_tbar_excluding1
      i_save               = 'A'
      is_variant           = alv_variant
    CHANGING
      it_outtab            = gt_alv1[]
      it_fieldcatalog      = gt_lvc1[].

*/ ALV 내에서의 이벤트 연결.
  CREATE OBJECT event_receiver.

  SET HANDLER event_receiver->handle_user_command           FOR grid1.
  SET HANDLER event_receiver->handle_hotspot_click          FOR grid1.
  SET HANDLER event_receiver->handle_toolbar                FOR grid1.
  SET HANDLER event_receiver->handle_double_click           FOR grid1.
  SET HANDLER event_receiver->handle_data_changed_finished  FOR grid1.
  SET HANDLER event_receiver->handle_data_changed           FOR grid1.
  CALL METHOD grid1->set_toolbar_interactive.

ENDFORM.                    " create_grid1
*&---------------------------------------------------------------------*
*&      Form  create_splitter
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_splitter .

  CREATE OBJECT container_spliter
    EXPORTING
      container_name = 'CUSTOM'.

  CREATE OBJECT splitter
    EXPORTING
      parent  = container_spliter
      rows    = 1
      columns = 1.

  CALL METHOD splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = container_1.

ENDFORM.                    " create_splitter
*&---------------------------------------------------------------------*
*&      Form  create_grid2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_grid2 .

  CREATE OBJECT grid2
    EXPORTING
      i_parent      = container_1
      i_appl_events = 'X'.

*- 출력할 필드 속성을 정의
  PERFORM set_field_catalogs_grid2.

** LAYOUT SETTING
  PERFORM set_option_grid2.

  CALL METHOD grid2->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
  alv_variant-report = sy-repid.
  alv_variant-handle = '0002'.
** ALV DATA 뿌려줌
  CALL METHOD grid2->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout2
      it_toolbar_excluding = gt_tbar_excluding2
      i_save               = 'A'
      is_variant           = alv_variant
    CHANGING
      it_outtab            = gt_alv2[]
      it_fieldcatalog      = gt_lvc2[]
      it_sort              = gt_sort[].

** ALV 내에서의 이벤트 연결.
  CREATE OBJECT event_receiver.
  SET HANDLER event_receiver->handle_user_command           FOR grid2.
  SET HANDLER event_receiver->handle_toolbar1               FOR grid2.
  SET HANDLER event_receiver->handle_data_changed_finished  FOR grid2.
  CALL METHOD grid2->set_toolbar_interactive.

ENDFORM.                    " create_grid2
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

  PERFORM fill_field_catalogs
          USING:
          'S' 'FIELDNAME'   'SEL1',
          ' ' 'COLTEXT'     '품목',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          ' ' 'CHECKBOX'    'X',
          ' ' 'EDIT'        'X',
*          ' ' 'EMPHASIZE'   'C301',
          'E' 'OUTPUTLEN'   '1',

          'S' 'FIELDNAME'   'SEL',
          ' ' 'COLTEXT'     '선택',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          ' ' 'CHECKBOX'    'X',
          ' ' 'EDIT'        'X',
*          ' ' 'EMPHASIZE'   'C301',
          'E' 'OUTPUTLEN'   '1'.

*--]기능개선 286869 # 20190807
  IF gf_request IS NOT INITIAL.

    PERFORM fill_field_catalogs
            USING:
            'S' 'FIELDNAME'   'SEND_STATUS_L',
            ' ' 'COLTEXT'     'Logi',
            ' ' 'JUST'        'C',
            ' ' 'ICON'        'X',
            'E' 'OUTPUTLEN'   '4',

            'S' 'FIELDNAME'   'SEND_STATUS',
            ' ' 'COLTEXT'     '배차요청방법',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '20'.

  ENDIF.
*--]기능개선 286869 # 20190807

  PERFORM fill_field_catalogs
          USING:
          'S' 'FIELDNAME'   'VBELN',
          ' ' 'COLTEXT'     '납품문서',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
*          ' ' 'EMPHASIZE'   'C301',
          ' ' 'HOTSPOT'     'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'KUNNR',
          ' ' 'COLTEXT'     '인도처',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          ' ' 'NO_ZERO'     'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'KUNNR_T',
          ' ' 'COLTEXT'     '인도처명',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '30',

          'S' 'FIELDNAME'   'ORT01',
          ' ' 'COLTEXT'     '인도처주소1',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'STRAS',
          ' ' 'COLTEXT'     '인도처주소2',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'INCO1',
          ' ' 'COLTEXT'     '인도조건',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '4',

          'S' 'FIELDNAME'   'INCO1_T',
          ' ' 'COLTEXT'     '인도조건명',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'WADAT',
          ' ' 'COLTEXT'     '출고일',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'LFDAT',
          ' ' 'COLTEXT'     '도착일자',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'LFUHR',
          ' ' 'COLTEXT'     '도착시간',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'KUNAG',
          ' ' 'COLTEXT'     '판매처',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          ' ' 'NO_ZERO'     'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'KUNAG_T',
          ' ' 'COLTEXT'     '판매처명',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '30',

          'S' 'FIELDNAME'   'LFART',
          ' ' 'COLTEXT'     '납품유형',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '04',

          'S' 'FIELDNAME'   'LFART_T',
          ' ' 'COLTEXT'     '납품유형명',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'ROUTE',
          ' ' 'COLTEXT'     '운송경로',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '04',

          'S' 'FIELDNAME'   'ROUTE_T',
          ' ' 'COLTEXT'     '운송경로명',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'VSTEL',
          ' ' 'COLTEXT'     '출하지점',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '04',

          'S' 'FIELDNAME'   'VSTEL_T',
          ' ' 'COLTEXT'     '출하지점명',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'VSBED',
          ' ' 'COLTEXT'     '출하조건',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '04',

          'S' 'FIELDNAME'   'VSBED_T',
          ' ' 'COLTEXT'     '출하조건명',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'TKNUM',
          ' ' 'COLTEXT'     '선적번호',
          ' ' 'JUST'        'L',
          ' ' 'HOTSPOT'     'X',
          ' ' 'KEY'         '',
          ' ' 'NO_ZERO'     'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'TRSTA_YN',
          ' ' 'COLTEXT'     '해상운송여부',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '1',


          'S' 'FIELDNAME'   'TKNUM_SEA',
          ' ' 'COLTEXT'     '해상선적번호',
          ' ' 'JUST'        'L',
          ' ' 'HOTSPOT'     'X',
          ' ' 'KEY'         '',
          ' ' 'NO_ZERO'     'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'TEXT1',
          ' ' 'COLTEXT'     'CY정보(해상)',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'TEXT2',
          ' ' 'COLTEXT'     '인수자정보(해상)',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'TEXT3',
          ' ' 'COLTEXT'     '연락처(해상)',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'TEXT4',
          ' ' 'COLTEXT'     '기타사항(해상)',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'ROUTE2',
          ' ' 'COLTEXT'     '해상운송경로',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '6',

          'S' 'FIELDNAME'   'ROUTE_T2',
          ' ' 'COLTEXT'     '해상운송경로명',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         '',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'VGBEL',
          ' ' 'COLTEXT'     '주문번호',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          ' ' 'HOTSPOT'     'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'GUBUN',
          ' ' 'COLTEXT'     '요청구분',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'STATUS',
          ' ' 'COLTEXT'     '상태',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'VTWEG_T',
          ' ' 'COLTEXT'     '유통경로',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'VKBUR_T',
          ' ' 'COLTEXT'     '영업팀',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'VKGRP_T',
          ' ' 'COLTEXT'     '영업그룹',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'ENAME',
          ' ' 'COLTEXT'     '영업사원',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'CITY1',
          ' ' 'COLTEXT'     '납지',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'ZOUT_T',
          ' ' 'COLTEXT'     '통문여부',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'ERNAM',
          ' ' 'COLTEXT'     '출하확정자',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'IV_NO',
          ' ' 'COLTEXT'     '거래명세서',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '10'.


*--]기능개선 286869 # 20190807
  IF gf_request IS NOT INITIAL.

    PERFORM fill_field_catalogs
            USING:

            'S' 'FIELDNAME'   'ORD_NUM',
            ' ' 'COLTEXT'     '로지스팟오더',
            ' ' 'JUST'        'C',
            ' ' 'EDIT'        'X',
            'E' 'OUTPUTLEN'   '10',


            'S' 'FIELDNAME'   'DRIVER_NM',
            ' ' 'COLTEXT'     '운전자명',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '10',

            'S' 'FIELDNAME'   'DRIVER_TELNO',
            ' ' 'COLTEXT'     '운전자전화번호',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '20',

            'S' 'FIELDNAME'   'TRUCK_NO',
            ' ' 'COLTEXT'     '차량번호',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '10',

            'S' 'FIELDNAME'   'TDLNR',
            ' ' 'COLTEXT'     '운송사',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '10',

            'S' 'FIELDNAME'   'TRK_TON',
            ' ' 'COLTEXT'     '운임톤수',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '6',

*-[CHM2210-00014]  컨테이너 차량 정보    -[s]
           'S' 'FIELDNAME'   'CTNR_NO1',
            ' ' 'COLTEXT'     '컨테이너번호1',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '10',


            'S' 'FIELDNAME'   'CTNR_NO2',
            ' ' 'COLTEXT'     '컨테이너번호2',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '10',

            'S' 'FIELDNAME'   'SEAL_NO1',
            ' ' 'COLTEXT'     '씰번호1',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '10',

            'S' 'FIELDNAME'   'SEAL_NO2',
            ' ' 'COLTEXT'     '씰번호2',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '10',

            'S' 'FIELDNAME'   'CTNR_WT1',
            ' ' 'COLTEXT'     '공컨테이너중량1',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '10',

            'S' 'FIELDNAME'   'CTNR_WT2',
            ' ' 'COLTEXT'     '공컨테이너중량2',
            ' ' 'JUST'        'C',
            'E' 'OUTPUTLEN'   '6'.

*-[CHM2210-00014]  컨테이너 차량 정보    -[e]

  ENDIF.
*--]기능개선 286869 # 20190807

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

  gs_layout-sel_mode   = 'D'.
  gs_layout-no_rowmark = 'X'.
  gs_layout-zebra      = ' '.
  gs_layout-cwidth_opt = 'X'.
  gs_layout-ctab_fname = 'ALV_COL'.

*  gs_layout-sel_mode   = 'D'.
*  gs_layout-no_rowmark = 'X'.
*  gs_layout-zebra      = ' '.
**  gs_layout-cwidth_opt = 'X'.
*  gs_layout-ctab_fname = 'ALV_COL'.
*  gs_LAYOUT-CWIDTH_OPT = 'X'.
*  gs_layout-COL_OPT    = 'X'.
*  gs_layout-grid_title = ' '.

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
*&      Form  set_option_grid1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_option_grid3 .

  gs_layout3-sel_mode   = 'D'.
*  GS_LAYOUT3-NO_ROWMARK = 'X'.
  gs_layout3-zebra      = ' '.
  gs_layout3-stylefname      = 'CELLTAB'.
*  GS_LAYOUT3-CWIDTH_OPT = 'X'.
*  GS_LAYOUT-CTAB_FNAME = 'ALV_COL'.

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
*      -->P_0715   text
*      -->P_0716   text
*      -->P_0717   text
*----------------------------------------------------------------------*
FORM fill_field_catalogs  USING    p_gub  p_fname  p_value.

*- 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*- 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점

  IF p_gub = 'S' OR p_gub = 'A'.

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
*&      Form  fill_field_catalogs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0715   text
*      -->P_0716   text
*      -->P_0717   text
*----------------------------------------------------------------------*
FORM fill_field_catalogs3  USING    p_gub  p_fname  p_value.

*- 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*- 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점

  IF p_gub = 'S' OR p_gub = 'A'.

    CLEAR gs_lvc3.

  ENDIF.

*- 출력될 Field 속성을 정의해서 필드 카타로그 테이블에 저장
  DATA l_fname(40).
  FIELD-SYMBOLS <fs> TYPE any.
  CONCATENATE 'GS_LVC3-' p_fname INTO l_fname.

  ASSIGN (l_fname) TO <fs>.
  <fs> = p_value.


  IF p_gub = 'E'.

    IF gs_lvc3-coltext IS NOT INITIAL.
      gs_lvc3-scrtext_l = gs_lvc3-scrtext_m = gs_lvc3-scrtext_s =
      gs_lvc3-coltext.
    ENDIF.

    APPEND gs_lvc3 TO gt_lvc3.

  ENDIF.


ENDFORM.                    " fill_field_catalogs

*&---------------------------------------------------------------------*
*&      Form  set_field_catalogs_grid2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_field_catalogs_grid2 .

*  PERFORM CREATE_FIELDCAT USING 'GT_ALV2'
*                                GT_LVC2.

  CLEAR: gt_lvc2[].
*  PERFORM FILL_FIELD_CATALOGS_2_NEW
  PERFORM fill_field_catalogs_2
          USING:

          'S' 'FIELDNAME'   'SEL2',
          ' ' 'COLTEXT'     '선택',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          ' ' 'CHECKBOX'    'X',
          ' ' 'EDIT'        'X',
*          ' ' 'EMPHASIZE'   'C301',
          'E' 'OUTPUTLEN'   '3',

          'S' 'FIELDNAME'   'VBELN',
          ' ' 'COLTEXT'     '납품문서',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          ' ' 'EMPHASIZE'   'C301',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'POSNR',
          ' ' 'COLTEXT'     '품목',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          ' ' 'EMPHASIZE'   'C301',
          'E' 'OUTPUTLEN'   '6',

          'S' 'FIELDNAME'   'VGBEL',
          ' ' 'COLTEXT'     '판매오더',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          ' ' 'EMPHASIZE'   'C301',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'VGPOS',
          ' ' 'COLTEXT'     '오더품목',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          ' ' 'EMPHASIZE'   'C301',
          'E' 'OUTPUTLEN'   '6',

          'S' 'FIELDNAME'   'WERKS',
          ' ' 'COLTEXT'     'PLANT',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          'E' 'OUTPUTLEN'   '5',

          'S' 'FIELDNAME'   'LGORT',
          ' ' 'COLTEXT'     'SLOC',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          'E' 'OUTPUTLEN'   '4',

          'S' 'FIELDNAME'   'MATNR',
          ' ' 'COLTEXT'     '제품코드',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          ' ' 'NO_ZERO'     'X',
          'E' 'OUTPUTLEN'   '7',

          'S' 'FIELDNAME'   'ARKTX',
          ' ' 'COLTEXT'     '제품명',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         'X',
          'E' 'OUTPUTLEN'   '20',

          'S' 'FIELDNAME'   'ZZCOLOR_BASE',
          ' ' 'COLTEXT'     'BASE',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '5',

          'S' 'FIELDNAME'   'ZZCOLOR_STRIPE',
          ' ' 'COLTEXT'     'STRIPE',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '5',

          'S' 'FIELDNAME'   'LFIMG',
          ' ' 'COLTEXT'     '납품수량',
          ' ' 'JUST'        'R',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'VRKME',
          ' ' 'COLTEXT'     '단위',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          ' ' 'CONVEXIT'    'CUNIT',
          'E' 'OUTPUTLEN'   '4',

          'S' 'FIELDNAME'   'CHARG',
          ' ' 'COLTEXT'     'BATCH',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'LENGTH',
          ' ' 'COLTEXT'     '조장',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'FACTOR',
          ' ' 'COLTEXT'     '조장수',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          ' ' 'NO_ZERO'     'X',
          'E' 'OUTPUTLEN'   '5',

          'S' 'FIELDNAME'   'PACKAG',
          ' ' 'COLTEXT'     '포장재',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          ' ' 'NO_ZERO'     'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'TBRGEW',
          ' ' 'COLTEXT'     '총중량(kg)',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          ' ' 'NO_ZERO'     'X',
*          ' ' 'DO_SUM'      'X',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'TVOLUM',
          ' ' 'COLTEXT'     '포장부피(m3)',
          ' ' 'JUST'        'L',
          ' ' 'KEY'         ' ',
          ' ' 'NO_ZERO'     'X',
          'E' 'OUTPUTLEN'   '10',

          'S' 'FIELDNAME'   'GROES',
          ' ' 'COLTEXT'     '단위포장SIZE',
          ' ' 'JUST'        'L',
*          ' ' 'NO_ZERO'     'X',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '12',

          'S' 'FIELDNAME'   'CUT_YN',
          ' ' 'COLTEXT'     '절단상태',
          ' ' 'JUST'        'L',
*          ' ' 'NO_ZERO'     'X',
          ' ' 'KEY'         ' ',
          'E' 'OUTPUTLEN'   '10',

* 기계부문 요청사항 . 반입중량, 총 반입중량 추
* SDB01 060725
          'S' 'FIELDNAME'   'NTGEW',
          ' ' 'COLTEXT'     '반입중량(kg)',
          ' ' 'JUST'        'R',
*          ' ' 'NO_ZERO'     'X',
          ' ' 'KEY'         ' ',
          ' ' 'DO_SUM'      'X',
          ' ' 'QFIELDNAME'      'MEINS_KG',
          'E' 'OUTPUTLEN'   '10',

*          'S' 'FIELDNAME'   'TNTGEW',
*          ' ' 'COLTEXT'     '총 반입중량',
*          ' ' 'JUST'        'R',
**          ' ' 'NO_ZERO'     'X',
*          ' ' 'KEY'         ' ',
*          ' ' 'DO_SUM'      'X',
*          ' ' 'QFIELDNAME'      'GEWEI',
*          'E' 'OUTPUTLEN'   '10',

*          'S' 'FIELDNAME'   'GEWEI',
*          ' ' 'COLTEXT'     '중량단위',
*          ' ' 'JUST'        'R',
**          ' ' 'NO_ZERO'     'X',
*          ' ' 'KEY'         ' ',
*          'E' 'OUTPUTLEN'   '5',

          'S' 'FIELDNAME'   'OUT_WID',
          ' ' 'COLTEXT'     '폭/드럼',
          ' ' 'JUST'        'R',
          ' ' 'KEY'         ' ',
          ' ' 'NO_ZERO'     'X',
          ' ' 'QFIELDNAME' 'MEINS_MM',
          ' ' 'DO_SUM'      ' ',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'PLAN_DIA',
          ' ' 'COLTEXT'     '약경/드럼',
          ' ' 'JUST'        'R',
          ' ' 'KEY'         ' ',
          ' ' 'NO_ZERO'     'X',
          ' ' 'QFIELDNAME' 'MEINS_MM',
          ' ' 'DO_SUM'      ' ',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'DR_WEIGHT',
          ' ' 'COLTEXT'     '드럼/개(kg)',
          ' ' 'JUST'        'R',
          ' ' 'KEY'         ' ',
          ' ' 'NO_ZERO'     'X',
          ' ' 'QFIELDNAME' 'MEINS_KG',
          ' ' 'DO_SUM'      ' ',
          'E' 'OUTPUTLEN'   '8',

          'S' 'FIELDNAME'   'BRGEW_DR',
          ' ' 'COLTEXT'     '총중량(드럼포함)(kg)',
          ' ' 'JUST'        'R',
          ' ' 'KEY'         ' ',
          ' ' 'NO_ZERO'     'X',
          ' ' 'QFIELDNAME' 'MEINS_KG',
          ' ' 'DO_SUM'      'X',
          'E' 'OUTPUTLEN'   '10'.

ENDFORM.                    " set_field_catalogs_grid2
*&---------------------------------------------------------------------*
*&      Form  set_option_grid2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_option_grid2 .

  gs_layout2-sel_mode   = 'D'.
  gs_layout2-no_rowmark = 'X'.
  gs_layout2-zebra      = ' '.
*  gs_layout-cwidth_opt = ''.
  gs_layout2-ctab_fname = 'ALV_COL'.
*  GS_LAYOUT-CWIDTH_OPT = 'X'.
*  gs_layout-COL_OPT    = 'X'.
*  gs_layout-grid_title = ' '.


* 2. EXCLUDING MENU
  CLEAR :   gt_tbar_excluding2[].
  APPEND : '&REFRESH'             TO gt_tbar_excluding2,
           '&LOCAL&CUT'           TO gt_tbar_excluding2,
           '&LOCAL&COPY'          TO gt_tbar_excluding2,
           '&LOCAL&PASTE'         TO gt_tbar_excluding2,
           '&LOCAL&PASTE_NEW_ROW' TO gt_tbar_excluding2,
           '&LOCAL&UNDO'          TO gt_tbar_excluding2,
           '&LOCAL&APPEND'        TO gt_tbar_excluding2,
           '&LOCAL&INSERT_ROW'    TO gt_tbar_excluding2,
           '&LOCAL&DELETE_ROW'    TO gt_tbar_excluding2,
           '&LOCAL&COPY_ROW'      TO gt_tbar_excluding2,
           '&DETAIL'              TO gt_tbar_excluding2.

ENDFORM.                    " set_option_grid2
*&---------------------------------------------------------------------*
*&      Form  fill_field_catalogs_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1503   text
*      -->P_1504   text
*      -->P_1505   text
*----------------------------------------------------------------------*
FORM fill_field_catalogs_2  USING    p_gub  p_fname  p_value.

*- 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*- 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점

  IF p_gub = 'S'.

    CLEAR gs_lvc2.

  ENDIF.

*- 출력될 Field 속성을 정의해서 필드 카타로그 테이블에 저장
  DATA l_fname(40).
  FIELD-SYMBOLS <fs> TYPE any.
  CONCATENATE 'GS_LVC2-' p_fname INTO l_fname.

  ASSIGN (l_fname) TO <fs>.
  <fs> = p_value.

  IF p_gub = 'E'.

    APPEND gs_lvc2 TO gt_lvc2.

  ENDIF.


ENDFORM.                    " fill_field_catalogs_2
*&---------------------------------------------------------------------*
*&      Form  get_grid2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ALV1  text
*      -->P_GT_ALV2  text
*----------------------------------------------------------------------*
FORM get_grid2  TABLES  pt_alv1 LIKE gt_alv1[]
                        pt_alv2 LIKE gt_alv2[] .

  DATA: lv_packag       TYPE atwrt, " LIKE mara-matnr.
        lv_plan_dia(32),
        lv_out_wid(32).
  DATA: BEGIN OF lt_zedt OCCURS 0,
          cbm_qty  LIKE zedt1001-cbm_qty,
          plan_dia LIKE zedt1001-plan_dia,
          out_wid  LIKE zedt1001-out_wid,
        END OF lt_zedt.


  CLEAR: lv_packag, gv_tbrgew.

*--[기능개선 286869  추가
*  운송업체 배차요청시 아이템 정보 모두 추출
  IF gt_header_sel[] IS NOT INITIAL.

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE pt_alv2
      FROM lips
       FOR ALL ENTRIES IN pt_alv1
    WHERE vbeln = pt_alv1-vbeln.

  ELSE.
*--]기능개선 286869 - 20190726


    READ TABLE pt_alv1 INDEX gv_index.
    CHECK sy-subrc = 0.
*->[가온전선]--------------------CHG S
    DATA(lt_base) = pt_alv1[].
    DELETE lt_base WHERE sel1 NE 'X'.
    SORT lt_base BY vbeln.
    DELETE ADJACENT DUPLICATES FROM lt_base COMPARING vbeln.
    IF lt_base[] IS NOT INITIAL.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE pt_alv2
        FROM lips
         FOR ALL ENTRIES IN lt_base
       WHERE vbeln = lt_base-vbeln.

      DELETE pt_alv2 WHERE charg <> ' '
                       AND pstyv = 'TAL'.
    ELSE.
      CLEAR:pt_alv2[].
    ENDIF.

*    IF PT_ALV1-SEL1 = 'X'.
*
*      PT_ALV1-SEL1 = ' '.
*      MODIFY PT_ALV1  TRANSPORTING SEL1
*                                  WHERE SEL1 = 'X'.
*      PT_ALV1-SEL1 = 'X'.
*      MODIFY PT_ALV1  TRANSPORTING SEL1
*                      WHERE VBELN = PT_ALV1-VBELN.
*
*      READ TABLE PT_ALV1 INDEX GV_INDEX.
*      SELECT * INTO CORRESPONDING FIELDS OF TABLE PT_ALV2
*        FROM LIPS
*       WHERE VBELN = PT_ALV1-VBELN.
*
*      DELETE PT_ALV2 WHERE CHARG <> ' '
*                       AND PSTYV = 'TAL'.
*    ELSE.
*      CLEAR:PT_ALV2[].
*    ENDIF.
*-<[가온전선]--------------------CHG E

  ENDIF.

  LOOP  AT pt_alv2.
    CLEAR:gv_brgew1,gv_brgew2.

    IF pt_alv2-uecha = ' '.
      pt_alv2-item_no = pt_alv2-posnr.
    ELSE.
      pt_alv2-item_no = pt_alv2-uecha.
    ENDIF.
*/ BATCH 조장
*->[가온전선]--------------------CHG S
    PERFORM set_characteristic_values    USING pt_alv2-vgbel pt_alv2-vgpos
                                               'SAP_LENGTH_VKRME'
                                      CHANGING pt_alv2-length.
*    PERFORM GET_BATCH_CHARACTERISTIC
*        USING: PT_ALV2-MATNR PT_ALV2-CHARG
*               'SAP_MILLCA_LENGTH'
*     CHANGING: PT_ALV2-LENGTH.
*-<[가온전선]--------------------CHG E
*/ BATCH 조장수
* 단위환산: 판매단위와 기본단위가 다를 경우,
* 기본단위로 환산하여 조장수를 계산한다.
    CLEAR: gv_menge, gv_length.
    IF pt_alv2-meins <> pt_alv2-vrkme.
      PERFORM convert_meins USING pt_alv2-matnr
                                  pt_alv2-vrkme
                                  pt_alv2-meins
                         CHANGING gv_menge.
      gv_length = pt_alv2-length * gv_menge.
    ELSE.
      gv_length = pt_alv2-length.
    ENDIF.
    IF gv_length > 0.
      pt_alv2-factor = pt_alv2-lfimg / pt_alv2-length.
    ENDIF.



    IF pt_alv2-kokrs = '2000'.
*/ 포장목 구분
      SELECT SINGLE zwdty
        INTO pt_alv2-zwdty
        FROM vbap
       WHERE vbeln = pt_alv2-vgbel
      AND posnr = pt_alv2-vgpos.

*/ BATCH 포장재
      CALL FUNCTION 'ZQC01_BATCH_VALUES_READ'
        EXPORTING
          i_val_matnr  = pt_alv2-matnr
          i_val_werks  = pt_alv2-werks
          i_val_charge = pt_alv2-charg
          i_date       = sy-datum
        TABLES
          t_val_tab    = lt_vali
          t_att_tab    = lt_attr
        EXCEPTIONS
          no_class     = 1
          OTHERS       = 2.

      READ TABLE lt_vali WITH KEY atnam = so_packaging.
      IF sy-subrc = 0.
        lv_packag = lt_vali-atwrt.
        pt_alv2-packag = lv_packag.
      ENDIF.
    ELSE.
      PERFORM get_batch_characteristic
          USING: pt_alv2-matnr pt_alv2-charg
                 'SAP_MILLCA_PACKAGING'
       CHANGING: lv_packag.

      pt_alv2-packag = lv_packag.
    ENDIF.



*/ 포장규격
    IF pt_alv2-charg <> ' '. "배치가 있을때
      IF NOT pt_alv2-packag IS INITIAL.
*  포장재가 있다면..LIPS-brgew + MARA-BRGEW
*  만약, 단위가 'KG' 아니면, 모두 KG 환산하여 합산
        PERFORM convert_alpha_input USING pt_alv2-packag.
* About Lips
        IF pt_alv2-gewei <> 'KG'.
          PERFORM conversion_meins USING pt_alv2-matnr
                                         pt_alv2-gewei
                                         'KG'
                                         pt_alv2-brgew.
          gv_brgew1 = pt_alv2-brgew.
        ELSE.
          gv_brgew1 = pt_alv2-brgew.
        ENDIF.


        DATA : lv_volum LIKE mara-volum,
               lv_groes LIKE mara-groes,
               lv_brgew LIKE vbap-brgew.
        CLEAR : lv_brgew.

        IF pt_alv2-kokrs = '2000'.
          CALL FUNCTION 'Z_LE_PK_WD_COMPUTE_JS'
            EXPORTING
              i_matnr      = pt_alv2-packag
              i_pk_wd_type = pt_alv2-zwdty
            IMPORTING
              e_brgew      = lv_brgew
              e_volum      = lv_volum
              e_groes      = lv_groes.

          IF sy-subrc = 0.
            gv_brgew2 = lv_brgew.
            pt_alv2-tbrgew = gv_brgew1 + gv_brgew2.

            pt_alv2-tvolum = lv_volum.                   "총부피
            pt_alv2-groes  = lv_groes.                   "단위포장
          ENDIF.
        ELSE.
* [END]   CSR NO : C20080801_08252
* About Mara
          CLEAR:mara.
          SELECT SINGLE brgew volum groes gewei mtart FROM mara
           INTO (mara-brgew,mara-volum,mara-groes,mara-gewei,mara-mtart )
          WHERE matnr = pt_alv2-packag.
          IF sy-subrc EQ 0.
            SELECT SINGLE cbm_qty plan_dia out_wid INTO lt_zedt
              FROM zedt1001
            WHERE matnr = pt_alv2-packag.

            IF mara-gewei <> 'KG'.
              PERFORM conversion_meins USING pt_alv2-packag
                                             mara-gewei
                                             'KG'
                                             mara-brgew.
              gv_brgew2 = mara-brgew.
            ELSE.
              gv_brgew2 = mara-brgew.
            ENDIF.
          ENDIF.
*          "[가온]-S
*          PT_ALV2-DR_WEIGHT = GV_BRGEW2.
*          "[가온]-E

          pt_alv2-tbrgew = gv_brgew1 + gv_brgew2 .

          IF mara-mtart = 'MRM1'.
            pt_alv2-tvolum = lt_zedt-cbm_qty.
            lv_plan_dia = lt_zedt-plan_dia.
            lv_out_wid  = lt_zedt-out_wid.
            CONDENSE: lv_plan_dia, lv_out_wid.
            CONCATENATE lv_plan_dia '*' lv_out_wid INTO pt_alv2-groes
                        SEPARATED BY space.

*            "[가온]-S
*            PT_ALV2-OUT_WID  = LV_OUT_WID.
*            PT_ALV2-PLAN_DIA = LV_PLAN_DIA.
*            "[가온]-E
          ELSE.
            pt_alv2-tvolum = mara-volum.                   "총부피
            pt_alv2-groes  = mara-groes.                   "단위포장

          ENDIF.
        ENDIF.
      ELSE.
* 포장재가 없다면...lips-brgew
        PERFORM call_func_packg
          USING: pt_alv2-matnr pt_alv2-lfimg
       CHANGING: pt_alv2-packag.

        IF pt_alv2-gewei <> 'KG'.
          PERFORM conversion_meins USING pt_alv2-matnr
                                         pt_alv2-gewei
                                         'KG'
                                         pt_alv2-brgew.
          gv_brgew1 = pt_alv2-brgew.
        ELSE.
          gv_brgew1 = pt_alv2-brgew.
        ENDIF.

**********
        CLEAR:mara.
        SELECT SINGLE brgew volum groes gewei mtart FROM mara
         INTO (mara-brgew,mara-volum,mara-groes,mara-gewei,mara-mtart )
        WHERE matnr = pt_alv2-packag.

        IF sy-subrc EQ 0.
          SELECT SINGLE cbm_qty plan_dia out_wid INTO lt_zedt
            FROM zedt1001
          WHERE matnr = pt_alv2-packag.

          IF mara-gewei <> 'KG'.
            PERFORM conversion_meins USING pt_alv2-packag
                                           mara-gewei
                                           'KG'
                                           mara-brgew.
            gv_brgew2 = mara-brgew.
          ELSE.
            gv_brgew2 = mara-brgew.
          ENDIF.
        ENDIF.
        pt_alv2-tbrgew = gv_brgew1 + gv_brgew2.

*        "[가온]-S
*        PT_ALV2-DR_WEIGHT = GV_BRGEW2.
*        "[가온]-E

        IF mara-mtart = 'MRM1'.
          pt_alv2-tvolum = lt_zedt-cbm_qty.
          lv_plan_dia = lt_zedt-plan_dia.
          lv_out_wid  = lt_zedt-out_wid.
          CONDENSE: lv_plan_dia, lv_out_wid.
          CONCATENATE lv_plan_dia '*' lv_out_wid INTO pt_alv2-groes
                      SEPARATED BY space.

*          "[가온]-S
*          PT_ALV2-OUT_WID  = LV_OUT_WID.
*          PT_ALV2-PLAN_DIA = LV_PLAN_DIA.
*          "[가온]-E

        ELSE.
          pt_alv2-tvolum = mara-volum.                   "총부피
          pt_alv2-groes  = mara-groes.                   "단위포장

        ENDIF.
**********
*        pt_alv2-tbrgew = gv_brgew1.
*        pt_alv2-tvolum = pt_alv2-volum.      "LIPS의 부피
*        기계부문 logic반영 반입 총중량 계산, 자재의 외형Sizse조회.
*   외형SIZE는 포장재가 아닌 출하자재를 이용함.
*        sdb01 060725
        IF pt_alv2-spart+0(1) = '7'.
          pt_alv2-tntgew = pt_alv2-ntgew * pt_alv2-lfimg.

          CLEAR pt_alv2-groes.
          SELECT SINGLE groes
            INTO pt_alv2-groes FROM mara
          WHERE matnr = pt_alv2-matnr.

        ENDIF.

      ENDIF.
    ELSE.                     "배치가 없을때
      IF pt_alv2-gewei <> 'KG'.
        PERFORM conversion_meins USING pt_alv2-matnr
                                       pt_alv2-gewei
                                       'KG'
                                       pt_alv2-brgew.
        gv_brgew1 = pt_alv2-brgew.
      ELSE.
        gv_brgew1 = pt_alv2-brgew.
      ENDIF.
      pt_alv2-tbrgew = gv_brgew1.

    ENDIF.

    SELECT SINGLE zzcolor_base zzcolor_stripe
      INTO (pt_alv2-zzcolor_base,pt_alv2-zzcolor_stripe) FROM mara
    WHERE matnr = pt_alv2-matnr.

    "순중량 => KG
    IF pt_alv2-gewei NE 'KG'.
      PERFORM conversion_meins USING pt_alv2-matnr
                                     pt_alv2-gewei
                                     'KG'
                                     pt_alv2-ntgew.
    ENDIF.

    "[가온]-S
*    IF PT_ALV2-FACTOR > 0.
    IF pt_alv2-uecha EQ '000000'.
      "폭/드럼
      "약경/드럼
      "드럼무게/개
      PERFORM get_cbm_data CHANGING pt_alv2.
      "총 중량(드럼포함)
      PERFORM get_total_weight CHANGING pt_alv2.


    ENDIF.
    pt_alv2-meins_mm = gc_meins_mm.
    pt_alv2-meins_kg = gc_meins_kg.
    "[가온]-E

    ADD pt_alv2-tbrgew TO gv_tbrgew .
    MODIFY pt_alv2.
  ENDLOOP.

* 총중량/부피 합계:
* if, 상위품목만 있으면, 현재 구한 상위품목의 값을 그대로...
* if, 하위품목(배치)이 있으면, 하위품목의 값 합계를 상위품목에...


*--[기능개선 286869  추가
  IF gt_header_sel[] IS NOT INITIAL.
  ELSE.
*--]기능개선 286869 - 20190726

    DATA:lv_out_wid_m   LIKE vtrlk-/bev1/rpmngli, "폭/드럼
         lv_plan_dia_m  LIKE vtrlk-/bev1/rpmngli, "약경/드럼
         lv_dr_weight_m LIKE mara-ntgew,          "드럼무게/개
         lv_brgew_dr_m  LIKE mara-brgew,
         lv_ntgew_m     LIKE mara-ntgew,
         lv_factor(5)   TYPE p DECIMALS 0.

*   SUM : 배치라인의 총중량/포장부피 를 SUM하여 MAIN 아이템 라인에 지정
    DATA(lt_temp) = pt_alv2[].
    SORT lt_temp BY vbeln posnr.
    DELETE lt_temp WHERE uecha NE '000000'.
    DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING vbeln posnr.
    LOOP AT lt_temp INTO DATA(ls_temp).
      IF line_exists( pt_alv2[ vbeln = ls_temp-vbeln
                               posnr = ls_temp-posnr
                               charg = ' '           ] ).

        CLEAR:gv_tbrgew, gv_tvolum, gv_tntgew.
        CLEAR:lv_out_wid_m,lv_plan_dia_m,lv_dr_weight_m,lv_brgew_dr_m,lv_ntgew_m,lv_factor.
        LOOP AT pt_alv2 ASSIGNING FIELD-SYMBOL(<fs_alv2>) WHERE vbeln = ls_temp-vbeln
                                                            AND uecha = ls_temp-posnr.
          ADD <fs_alv2>-tbrgew TO gv_tbrgew  .
          ADD <fs_alv2>-tvolum TO gv_tvolum  .
          ADD <fs_alv2>-tntgew TO gv_tntgew  .

*          LV_OUT_WID_M   = <FS_ALV2>-OUT_WID.
*          LV_PLAN_DIA_M  = <FS_ALV2>-PLAN_DIA.
*          LV_DR_WEIGHT_M  = <FS_ALV2>-DR_WEIGHT.
          lv_ntgew_m     = lv_ntgew_m + <fs_alv2>-ntgew.
          lv_factor      = lv_factor + <fs_alv2>-factor.
*          LV_BRGEW_DR_M  =

*          CLEAR:<FS_ALV2>-OUT_WID,<FS_ALV2>-PLAN_DIA,<FS_ALV2>-DR_WEIGHT,
*                <FS_ALV2>-BRGEW_DR.
        ENDLOOP.
        IF sy-subrc = 0.

          CLEAR pt_alv2.
          pt_alv2-tbrgew = gv_tbrgew  .
          pt_alv2-tvolum = gv_tvolum  .
          pt_alv2-tntgew = gv_tntgew  .

*          PT_ALV2-OUT_WID   = LV_OUT_WID_M.
*          PT_ALV2-PLAN_DIA  = LV_PLAN_DIA_M.
*          PT_ALV2-DR_WEIGHT = LV_DR_WEIGHT_M.
          pt_alv2-brgew_dr  = ( pt_alv2-dr_weight * lv_factor ) + lv_ntgew_m.

          MODIFY pt_alv2 TRANSPORTING tbrgew tvolum tntgew
                                      brgew_dr
           WHERE vbeln = ls_temp-vbeln
             AND posnr = ls_temp-posnr.
        ENDIF.
      ENDIF.

    ENDLOOP.
*    LOOP AT PT_ALV2 WHERE UECHA = '000000'
*                      AND CHARG = ' '.
*      CLEAR:GV_TBRGEW, GV_TVOLUM, GV_TNTGEW.
*
*      LOOP AT PT_ALV2 WHERE UECHA = PT_ALV2-POSNR.
*        ADD PT_ALV2-TBRGEW TO GV_TBRGEW  .
*        ADD PT_ALV2-TVOLUM TO GV_TVOLUM  .
*        ADD PT_ALV2-TNTGEW TO GV_TNTGEW  . "기계부분반영
*      ENDLOOP.
*      IF SY-SUBRC = 0.
*        PT_ALV2-TBRGEW = GV_TBRGEW  .
*        PT_ALV2-TVOLUM = GV_TVOLUM  .
*        PT_ALV2-TNTGEW = GV_TNTGEW  . "기계부분반영
*      ENDIF.
*      MODIFY PT_ALV2 TRANSPORTING TBRGEW TVOLUM TNTGEW.
*    ENDLOOP.

*   SUM : 배치라인의 수량을 SUM하여 MAIN 아이템 라인에 지정
    DATA: lv_lfimg TYPE lfimg.
    LOOP AT lt_temp INTO ls_temp.
      CLEAR: lv_lfimg.
      LOOP AT pt_alv2 WHERE vbeln   = ls_temp-vbeln
                        AND item_no = ls_temp-posnr.
        ADD pt_alv2-lfimg  TO lv_lfimg.
      ENDLOOP.
      CLEAR pt_alv2.
      pt_alv2-lfimg = lv_lfimg.
      MODIFY pt_alv2 TRANSPORTING lfimg WHERE vbeln = ls_temp-vbeln
                                          AND posnr = ls_temp-posnr.
    ENDLOOP.
*    LOOP AT PT_ALV2 WHERE UECHA = '000000'.
*      CLEAR: LV_LFIMG.
*
*      LOOP AT PT_ALV2 WHERE ITEM_NO = PT_ALV2-ITEM_NO.
*        ADD PT_ALV2-LFIMG  TO LV_LFIMG.
*      ENDLOOP.
*      PT_ALV2-LFIMG = LV_LFIMG.
*      MODIFY PT_ALV2 TRANSPORTING LFIMG.
*
*    ENDLOOP.

  ENDIF.


* 절단관련 점검
  DATA: lv_cut1, lv_cut2.
  LOOP AT pt_alv1 WHERE vstel IN r_spg.
    LOOP AT pt_alv2 WHERE vbeln = pt_alv1-vbeln.
      SELECT SINGLE jisir cutsr INTO (lv_cut1, lv_cut2) FROM zlet0002
      WHERE vbeln = pt_alv2-vbeln
        AND posnr = pt_alv2-posnr.

      IF lv_cut1 = '1' AND lv_cut2 = '1'.
        pt_alv2-cut_yn = '절단완료'.

      ELSEIF lv_cut1 = '1' AND lv_cut2 <> '1'.
        pt_alv2-cut_yn = '절단지시'.
      ELSE.
        pt_alv2-cut_yn = ' '.
      ENDIF.

*      CASE lv_cut1.
*        WHEN ' '.  pt_alv2-cut_yn = ' '.
*        WHEN 'A'.  pt_alv2-cut_yn = '절단지시'.
*        WHEN 'B'.  pt_alv2-cut_yn = '부분절단'.
*        WHEN 'C'.  pt_alv2-cut_yn = '절단완료'.
*      ENDCASE.
      MODIFY pt_alv2.
    ENDLOOP.
  ENDLOOP.
* 출하지점이 3600 , 배치특성 SAP_MILLCA_PACKING 이 값이 있을때,
  DATA: lv_packing TYPE atwrt.
  DATA: one(10), two(10), three(10).

  LOOP AT pt_alv1 WHERE vstel = '3600'.
    LOOP AT pt_alv2 WHERE vbeln = pt_alv1-vbeln
                      AND charg <> ' '.
      PERFORM get_batch_characteristic
          USING: pt_alv2-matnr pt_alv2-charg
                 'SAP_MILLCA_PACKING'
       CHANGING: lv_packing.
      IF NOT lv_packing IS INITIAL.
        SELECT SINGLE groes FROM mara
           INTO mara-groes
        WHERE matnr = lv_packing.
        SPLIT mara-groes AT '*' INTO one two three.
        pt_alv2-groes = one * two * three / 1000000000.
        MODIFY pt_alv2.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  SORT pt_alv2 BY item_no vbeln posnr.

ENDFORM.                                                    " get_grid2
*&---------------------------------------------------------------------*
*&      Form  get_batch_characteristic
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_ALV2_MATNR  text
*      -->P_PT_ALV2_CHARG  text
*      -->P_2130   text
*      <--P_PT_ALV2_LENGTH  text
*----------------------------------------------------------------------*
FORM get_batch_characteristic  USING    p_matnr
                                        p_charg
                                        p_char
                            CHANGING    e_atwrt.
  DATA: lv_atwrt    LIKE ausp-atwrt.

  CLEAR : e_atwrt.

  CALL FUNCTION 'Z_LE_GET_BATCH_CHARACTERISTIC'
    EXPORTING
      i_object = p_matnr
      i_charg  = p_charg
      i_atnam  = p_char
    IMPORTING
      e_atwrt  = lv_atwrt.

  e_atwrt = lv_atwrt.

ENDFORM.                    " get_batch_characteristic
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION_VL03N
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_transaction_vl03n .

  READ TABLE gt_alv1 INDEX gv_index.
  IF sy-subrc = 0.
    IF gt_alv1-vbeln IS NOT INITIAL.
      SET PARAMETER ID 'VL' FIELD gt_alv1-vbeln.
      CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.

ENDFORM.                    " CALL_TRANSACTION_VL03N
*&---------------------------------------------------------------------*
*&      Form  ship1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ship1 .

*/ 전체조회인 경우 요청상태 체크
  PERFORM request_check_r03 USING 'R'.

*/ 에러 체크
  PERFORM error_check_before_ship1.

*/ DEFAULT VALUE
  PERFORM set_default_value_ship1.

  CALL SCREEN '300' STARTING AT 10   10
                    ENDING   AT 80   18.

*/ refresh?
  REFRESH: r_vbeln, ut_alv1.
  LOOP AT gt_alv1 WHERE sel = 'X'.
    r_vbeln-sign   = 'I'.
    r_vbeln-option = 'EQ'.
    r_vbeln-low    = gt_alv1-vbeln.
    APPEND r_vbeln.
  ENDLOOP.

  "복수배차
  IF r10 IS NOT INITIAL.
    PERFORM data_query TABLES gt_alv1
                              r_vbeln.

  ELSE.
    PERFORM data_query TABLES ut_alv1
                              r_vbeln.

    LOOP AT gt_alv1 WHERE sel = 'X'.
      READ TABLE ut_alv1 WITH KEY vbeln = gt_alv1-vbeln.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING ut_alv1 TO gt_alv1.
        MODIFY gt_alv1.
      ELSE.
        DELETE gt_alv1.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CALL METHOD grid2->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = l_scroll.     "현재 그대로 입력한 refresh

  CALL METHOD grid1->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = l_scroll.     "현재 그대로 입력한 refresh


ENDFORM.                                                    " ship1
*&---------------------------------------------------------------------*
*&      Form  ship2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ship2 .

*/ 에러 체크
  PERFORM error_check_before_ship2.

*/ DEFAULT VALUE
  PERFORM set_default_value_ship2.
*/ 선택한 품목의 총중량
  PERFORM get_total_brgew.

  CALL SCREEN '200' STARTING AT 10   10
                    ENDING   AT 100  23.

ENDFORM.                                                    " ship2
*&---------------------------------------------------------------------*
*&      Form  detail1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM detail1 .

  READ TABLE gt_alv1 WITH KEY sel = 'X'.
  IF sy-subrc <> 0.
    MESSAGE s000 WITH 'DATA를 선택하세요!!'.
    LEAVE SCREEN.
  ENDIF.

* 납품요청일은 필수.
* 납품의 선행문서의 납품요청일을 찾는다.
  RANGES: r_vbeln FOR lips-vbeln.
  RANGES: r_vgbel FOR lips-vgbel.
  RANGES: r_spart FOR lips-spart.
  RANGES: r_vtweg FOR lips-vtweg.
  RANGES: r_vdatu FOR vbak-vdatu.

  CLEAR: r_vgbel[], r_vgbel, r_vdatu[], r_vdatu,
         r_spart[], r_spart, r_vtweg[], r_vtweg,
         r_vbeln[], r_vbeln.

  LOOP AT  gt_alv1 WHERE sel = 'X'.
    SELECT * FROM lips WHERE vbeln = gt_alv1-vbeln.
      r_vgbel-sign   = 'I'.
      r_vgbel-option = 'EQ'.
      r_vgbel-low    = lips-vgbel.
      COLLECT r_vgbel.

      r_spart-sign   = 'I'.
      r_spart-option = 'EQ'.
      r_spart-low    = lips-spart.
      COLLECT r_spart.

      r_vtweg-sign   = 'I'.
      r_vtweg-option = 'EQ'.
      r_vtweg-low    = lips-vtweg.
      COLLECT r_vtweg.
    ENDSELECT.
    r_vbeln-sign   = 'I'.
    r_vbeln-option = 'EQ'.
    r_vbeln-low    = gt_alv1-vbeln.
    APPEND r_vbeln.
  ENDLOOP.

  IF NOT r_vgbel[] IS INITIAL.
    SELECT * FROM vbak WHERE vbeln IN r_vgbel.
      r_vdatu-sign   = 'I'.
      r_vdatu-option = 'EQ'.
      r_vdatu-low    = vbak-vdatu.
      APPEND r_vdatu.
    ENDSELECT.

    SUBMIT zsdr0200 AND RETURN
*        WITH so_vdatu  IN r_vdatu
        WITH so_edatu  IN r_vdatu
        WITH so_vbel2  IN r_vbeln
        WITH so_spart  IN r_spart
        WITH so_vtweg  IN r_vtweg.
  ENDIF.

ENDFORM.                                                    " detail1
*&---------------------------------------------------------------------*
*&      Form  ERROR_CHECK_BEFORE_SHIP2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error_check_before_ship2 .

* 하나의 납품문서 선택
  CLEAR: gv_cnt.
  LOOP AT gt_alv1 WHERE sel = 'X'.
    ADD 1 TO gv_cnt.
    IF gv_cnt = 2.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF gv_cnt = 2.
    MESSAGE i000 WITH '하나의 납품문서를 선택하세요'.
    LEAVE SCREEN.
  ENDIF.

*
  READ TABLE gt_alv1 WITH KEY sel = 'X'.
  IF sy-subrc <> 0.
    MESSAGE s000 WITH 'DATA를 선택하세요!!'.
    LEAVE SCREEN.
  ELSE.
    SELECT SINGLE mandt
      INTO sy-mandt
*      FROM VBUK
      FROM likp
     WHERE vbeln EQ gt_alv1-vbeln
    AND wbstk EQ 'C'.
    IF sy-subrc = 0.
      MESSAGE i001 WITH gt_alv1-vbeln
       '출고전기가 완료된 납품입니다. 확인하세요!'.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.

ENDFORM.                    " ERROR_CHECK_BEFORE_SHIP2
*&---------------------------------------------------------------------*
*&      Form  SET_DEFAULT_VALUE_SHIP2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_default_value_ship2 .

  IF r01 = 'X'.  "미요청
    PERFORM set_value_r01.
  ELSE.          "요청완료
    PERFORM set_value_r02.
  ENDIF.

** 추가텍스트, 소요톤수, 파렛트수
*  SELECT SINGLE bolnr xabln anzpk
*   INTO (wa-ztext, wa-xabln, wa-anzpk)
*         FROM likp
*       WHERE vbeln = gt_alv1-vbeln.
*  wa-ztons = wa-xabln.

ENDFORM.                    " SET_DEFAULT_VALUE_SHIP2
*&---------------------------------------------------------------------*
*&      Form  SET_VALUE_R01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_value_r01 .

  MOVE-CORRESPONDING gt_alv1 TO wa.
* 운송사
  SELECT SINGLE carrier carrier_t
    INTO (wa-carrier, wa-carrier_t)
    FROM zlet0011
  WHERE vstel = gt_alv1-vstel.

*[기능개선136137]-혼적/톤수 로직 추가(출하지점)
* 혼적불가
  SELECT SINGLE mandt INTO sy-mandt
    FROM zlet0013
   WHERE kunnr =  gt_alv1-kunnr
  AND vstel =  gt_alv1-vstel.
  IF sy-subrc = 0.
    wa-nemix = '혼적불가'.
  ELSE.
    wa-nemix = '혼적가능'.
  ENDIF.

* 톤수제한
  SELECT SINGLE ton INTO wa-ton
    FROM zlet0012
      WHERE kunnr = gt_alv1-kunnr
  AND vstel =  gt_alv1-vstel.
* 2016.05.18 H.M.LIM [기능개선136137]-혼적/톤수 로직 추가(출하지점)    *

* 추가텍스트, 소요톤수, 파렛트수
  SELECT SINGLE bolnr xabln anzpk
   INTO (wa-ztext, wa-xabln, wa-anzpk)
         FROM likp
  WHERE vbeln = gt_alv1-vbeln.

  wa-ztons = wa-xabln.

*CSR번호 : C2005112401000000109 - 운송사 배차요청 항목 수정
*  wa-lfdat = sy-datum + 1.
ENDFORM.                    " SET_VALUE_R01
*&---------------------------------------------------------------------*
*&      Form  SET_VALUE_R02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_value_r02 .

* 입차요청일LDDAT/LDUHR
* 도착요청일lfdat/lfuhr
* 추가요청사항: LIKP-LIFEX(OR BOLNR)
* 운송대행업체: VBPA (SP)
* 톤수제한:LIKP-XABLN
* 혼적제한:traid(xabln+'TON'+혼적불가)
* 인도조건:INCO1
* 파렛트 갯수:anzpk
* 요청톤수(TON):xabln

  SELECT SINGLE lddat
                lduhr
                lfdat
                lfuhr
                bolnr
                xabln
                traid
                inco1
                anzpk
                vbeln
          INTO (wa-lddat,
                wa-lduhr,
                wa-lfdat,
                wa-lfuhr,
                wa-ztext,
                wa-xabln ,
                wa-traid,
                wa-inco1,
                wa-anzpk,
                wa-vbeln)
         FROM likp
  WHERE vbeln = gt_alv1-vbeln.

  wa-ztons = wa-xabln.

* 운송대행업체
  SELECT SINGLE lifnr INTO wa-carrier
    FROM vbpa
   WHERE vbeln = wa-vbeln
     AND posnr = '000000'
  AND parvw = 'SP'.

* 혼적제한:traid(xabln+'TON'+혼적불가)
  DATA: lv_traid1(10), lv_traid2(10).
  CLEAR: lv_traid1, lv_traid2.
  SPLIT wa-traid AT 'TON' INTO lv_traid1 lv_traid2.
  wa-ton   = lv_traid1.
  wa-nemix = lv_traid2.



*  wa-ztons = wa-xabln.
*  wa-ton   = wa-xabln.

** 추가텍스트, 소요톤수, 파렛트수
*  SELECT SINGLE bolnr xabln anzpk
*   INTO (wa-ztext, wa-xabln, wa-anzpk)
*         FROM likp
*       WHERE vbeln = gt_alv1-vbeln.
*  wa-ztons = wa-xabln.

*********************************************
*  CLEAR: zlet0014.
*  SELECT SINGLE * FROM zlet0014
*    WHERE vbeln = gt_alv1-vbeln.
*
*  MOVE-CORRESPONDING zlet0014 TO wa.
**
*  SELECT SINGLE name1 INTO wa-carrier_t
*    FROM lfa1
*   WHERE lifnr = zlet0014-carrier.

ENDFORM.                    " SET_VALUE_R02
*&---------------------------------------------------------------------*
*&      Form  f4_nemix
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_NEMIX  text
*----------------------------------------------------------------------*
FORM f4_nemix  USING    p_nemix.

  DATA: BEGIN OF pov_mix OCCURS 0,
          nemix(8),
        END OF pov_mix.

  CLEAR: pov_mix[], pov_mix.

  pov_mix-nemix = '혼적가능'.
  APPEND pov_mix.  CLEAR pov_mix.
  pov_mix-nemix = '혼적불가'.
  APPEND pov_mix.  CLEAR pov_mix.

  fieldtab-tabname   = 'ZLET0031'.
  fieldtab-fieldname = 'NEMIX'.
  fieldtab-selectflag = 'X'.
  APPEND fieldtab.

  LOOP AT pov_mix.
    valuetab-value = pov_mix-nemix.
    APPEND valuetab.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE_EXT'
    EXPORTING
      titel         = '혼적제한'
      display       = ' '
*     fieldname     = 'NAME1'
    IMPORTING
      index         = j
    TABLES
      fields        = fieldtab
      select_values = i_help_vtab
      valuetab      = valuetab.

  IF j > 0.
    READ TABLE pov_mix INDEX j.
    p_nemix = pov_mix-nemix.
  ENDIF.
  REFRESH : fieldtab, valuetab, pov_mix.
  CLEAR   : j,fieldtab, valuetab, pov_mix.

ENDFORM.                                                    " f4_nemix
*&---------------------------------------------------------------------*
*&      Form  save3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save3 .

  PERFORM error_check_before_save3.

  PERFORM exec_vt01n.

ENDFORM.                                                    " save3
*&---------------------------------------------------------------------*
*&      Form  save2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save2 .

  PERFORM error_check_before_save2.

  PERFORM exec_vl02n.

ENDFORM.                                                    " save2
*&---------------------------------------------------------------------*
*&      Form  ERROR_CHECK_BEFORE_SAVE2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error_check_before_save2 .

  IF wa-icon1 = icon_green_light.
    MESSAGE i002 WITH '처리하였습니다'.
    LEAVE SCREEN.
  ENDIF.

  IF wa-lddat > wa-lfdat.
    MESSAGE i002 WITH
     '도착요청일이 입차요청일보다 최근 날짜이어야 합니다'.
    LEAVE SCREEN.
  ENDIF.

  IF wa-carrier = ' '.
    MESSAGE i002 WITH
     '운송대행업체는 필수항목입니다.'.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                    " ERROR_CHECK_BEFORE_SAVE2
*&---------------------------------------------------------------------*
*&      Form  EXEC_VL02N
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exec_vl02n .

  PERFORM pop_up_confirm(zler0004) USING '< 저장여부확인 >'
                               '저장하시겠습니까?'
                      CHANGING gv_return.
  CHECK gv_return = 'J'.
  CLEAR: gv_return, gv_zmsg.

* 제한톤수
* wa-ton_c = wa-ton.
* SHIFT wa-ton_c LEFT DELETING LEADING space.
  SHIFT wa-ton LEFT DELETING LEADING space.
  CONCATENATE wa-ton 'TON' wa-nemix INTO wa-traid.
* 소요톤수
  wa-xabln = wa-ztons.
  SHIFT wa-xabln LEFT DELETING LEADING space.

  DATA: flag.
  flag = 'X'.
  EXPORT flag TO MEMORY ID 'Z000'.

  bdc_mode = 'N'.
  CALL FUNCTION 'Z_LE_VL02N_TMS01'
    EXPORTING
      i_vbeln   = wa-vbeln
      i_lddat   = wa-lddat
      i_lduhr   = wa-lduhr
      i_wadat   = wa-lddat    "wa-wadat
      i_wauhr   = wa-lduhr    "wa-wauhr
      i_lfdat   = wa-lfdat
      i_lfuhr   = wa-lfuhr
      i_carrier = wa-carrier
      i_inco1   = wa-inco1
      i_traid   = wa-traid
      i_lifex   = wa-ztext
      i_anzpk   = wa-anzpk
      i_xabln   = wa-xabln
      i_reverse = ' '
      i_tbrgew  = gv_tbrgew  "총중량
      i_mode    = bdc_mode
    IMPORTING
      return    = gv_return
      zmessage  = gv_zmsg.
  IF gv_return = 'S'.
    wa-icon1 = icon_green_light.
    wa-zmsg  = '납품 정보를 변경하였습니다'.
    PERFORM table_insert.
  ELSE.
    wa-icon1 = icon_red_light.
    wa-zmsg  = gv_zmsg.
  ENDIF.


ENDFORM.                    " EXEC_VL02N
*&---------------------------------------------------------------------*
*&      Form  table_insert
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM table_insert .

*  DATA: lt_zlet0014 LIKE zlet0014 OCCURS 0 WITH HEADER LINE.
*
*  CLEAR: lt_zlet0014[], lt_zlet0014.
*
*  MOVE-CORRESPONDING wa TO lt_zlet0014.
*  MOVE sy-uname  TO lt_zlet0014-ernam.
*  MOVE sy-datum  TO lt_zlet0014-erdat.
*  MOVE sy-uzeit  TO lt_zlet0014-erzet.
*  APPEND lt_zlet0014.
*
*  DELETE FROM zlet0014 WHERE vbeln = wa-vbeln.
*  COMMIT WORK.
*
*  INSERT zlet0014 FROM TABLE lt_zlet0014.
*  COMMIT WORK.

  REFRESH: gt_alv2.

ENDFORM.                    " table_insert
*&---------------------------------------------------------------------*
*&      Form  error_check_before_save3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error_check_before_save3 .

  CLEAR: gv_flag.
  IF wa-tplst IS INITIAL.
    MESSAGE i000 WITH
     '운송계획지점은 필수입력 사항입니다.'.
    gv_flag = 'X'.
  ENDIF.

  IF wa-shtyp IS INITIAL.
    MESSAGE i000 WITH
     '선적유형은 필수입력 사항입니다.'.
    gv_flag = 'X'.
  ENDIF.

* 다른 사용자가 ROCK을 잡고 있으면, 에러.
  LOOP AT gt_tab1.
    PERFORM rock_check USING gt_tab1-vbeln.
  ENDLOOP.

  IF gv_flag = 'X'.
    LEAVE SCREEN.
  ENDIF.

* 2005.03.15 - SDC08
* 내륙운송생성시, 해상운송의 기생성여부 체크
  IF wa-shtyp = 'Z101' OR wa-shtyp ='Z102'.
    DATA: BEGIN OF lt_tmp OCCURS 0,
            tknum LIKE vttk-tknum,
          END OF lt_tmp.

    SELECT  k~tknum
       INTO CORRESPONDING FIELDS OF TABLE lt_tmp
       FROM vttk AS k INNER JOIN vttp AS p
         ON k~tknum = p~tknum
        FOR ALL ENTRIES IN gt_tab1
      WHERE p~vbeln = gt_tab1-vbeln
    AND k~shtyp = 'Z103'.
    IF sy-subrc <> 0.
      MESSAGE e000 WITH '아직 해상운송을 생성하지 않았습니다.확인하세요'.
    ENDIF.
  ENDIF.
* 2005.04.21 - MKJANG
* 해상운송의 기생성여부 체크

  IF wa-shtyp = 'Z103'.
    REFRESH: lt_tmp.
    SELECT  k~tknum
       INTO CORRESPONDING FIELDS OF TABLE lt_tmp
       FROM vttk AS k INNER JOIN vttp AS p
         ON k~tknum = p~tknum
        FOR ALL ENTRIES IN gt_tab1
      WHERE p~vbeln = gt_tab1-vbeln
    AND k~shtyp = 'Z103'.
    IF sy-subrc = 0.
      MESSAGE e000 WITH '이미 해상운송을 생성한 납품입니다. 확인하세요'.
    ENDIF.
  ENDIF.

* 2005.04.21 - MKJANG
* 수출해상운송 선적문서 생성시 납품처가 다를 경우 메세지
  IF wa-shtyp = 'Z103'.
    DATA: BEGIN OF lt_kur OCCURS 0,
            kunnr LIKE likp-kunnr,
          END OF lt_kur.
    DATA:lv_cnt TYPE i.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_kur
      FROM likp
       FOR ALL ENTRIES IN gt_tab1
    WHERE vbeln = gt_tab1-vbeln.

    SORT lt_kur.
    DELETE ADJACENT DUPLICATES FROM lt_kur.
    DESCRIBE TABLE lt_kur LINES lv_cnt.

    IF lv_cnt > 1 .
      MESSAGE e015 .
    ENDIF.

  ENDIF.
*


ENDFORM.                    " error_check_before_save3
*&---------------------------------------------------------------------*
*&      Form  exec_vT01N
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exec_vt01n .
  DATA:lv_tknum LIKE vttk-tknum.
*  PERFORM pop_up_confirm(zler0004) USING '< 확인 >'
*                               '선적문서생성 하시겠습니까?'
*                      CHANGING gv_return.
*  CHECK gv_return = 'J'.
  CLEAR: gv_return, gv_zmsg.

  bdc_mode = 'E'.
  CALL FUNCTION 'Z_LE_VT01N'
    EXPORTING
      i_tplst  = wa-tplst
      i_shtyp  = wa-shtyp
      i_mode   = bdc_mode
    IMPORTING
      return   = gv_return
      zmessage = gv_zmsg
    TABLES
      tab1     = gt_tab1.

  "복수배차
  CLEAR:gv_tknum_multi.
  IF r10 IS NOT INITIAL.
    IF sy-msgid EQ 'VW' AND
       sy-msgno EQ '006' AND
       sy-msgv1 IS NOT INITIAL.
      lv_tknum = sy-msgv1(10).
      lv_tknum = |{ lv_tknum ALPHA = IN }|.
      DO 5 TIMES.
        SELECT SINGLE tknum
          FROM vttk
         WHERE tknum EQ @lv_tknum
          INTO @DATA(lv_shno).
        IF sy-subrc EQ 0.
          gv_tknum_multi = lv_shno.

          EXIT.
        ENDIF.
        WAIT UP TO '0.5' SECONDS.
      ENDDO.
    ENDIF.
  ENDIF.

  SET SCREEN 0.

ENDFORM.                    " exec_vT01N
*&---------------------------------------------------------------------*
*&      Form  error_check_before_ship1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error_check_before_ship1 .

  READ TABLE gt_alv1 WITH KEY sel = 'X'.
  IF sy-subrc <> 0.
    MESSAGE s000 WITH 'DATA를 선택하세요!!'.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.                    " error_check_before_ship1
*&---------------------------------------------------------------------*
*&      Form  set_default_value_ship1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_default_value_ship1 .

  DATA: BEGIN OF lt_vst OCCURS 0,
          vstel LIKE likp-vstel,
        END OF lt_vst.

  CLEAR: gt_tab1[], gt_tab1.
  CLEAR: lt_vst[], lt_vst.
  CLEAR: wa.

  LOOP AT gt_alv1 WHERE sel = 'X'.
    gt_tab1-vbeln = gt_alv1-vbeln.
    APPEND gt_tab1.
* 2005.03.15 - SDC08
    lt_vst-vstel = gt_alv1-vstel.
    COLLECT lt_vst.
  ENDLOOP.

  DESCRIBE TABLE lt_vst LINES gv_cnt.
  IF gv_cnt = 1.
    READ TABLE lt_vst INDEX 1.
    SELECT SINGLE tplst bezei
      INTO (wa-tplst, wa-tplst_t)
      FROM ttdst
     WHERE spras = sy-langu
    AND tplst = lt_vst-vstel.
  ENDIF.

*/ 선택한 품목의 총중량
  PERFORM get_total_brgew.


ENDFORM.                    " set_default_value_ship1
*&---------------------------------------------------------------------*
*&      Form  set_cell_attribute_grid2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ALV2  text
*----------------------------------------------------------------------*
FORM set_cell_attribute_grid2  TABLES   pt_alv2 LIKE gt_alv2[].

  DATA: l_colinfo_table TYPE slis_t_specialcol_alv WITH HEADER LINE.
  DATA: l_index LIKE sy-index.

  LOOP AT pt_alv2 .
    IF NOT pt_alv2-alv_col[] IS INITIAL.
      l_index = sy-tabix.
      CLEAR l_colinfo_table[].
      pt_alv2-alv_col[] = l_colinfo_table[].
      MODIFY pt_alv2 INDEX l_index.
    ENDIF.
  ENDLOOP.

  LOOP AT pt_alv2 WHERE uecha = '000000'.
    l_index = sy-tabix.
    CLEAR l_colinfo_table[].

    PERFORM append_color_tab TABLES l_colinfo_table
                             USING: 'POSNR' '1',
                                    'WERKS' '1',
                                    'LGORT' '1',
                                    'MATNR' '1',
                                    'ARKTX' '1',
                                    'ZZCOLOR_BASE' '1',
                                    'ZZCOLOR_STRIPE' '1',
                                    'LFIMG' '1',
                                    'VRKME' '1',
                                    'CHARG' '1',
                                    'LENGTH' '1',
                                    'FACTOR' '1',
                                    'PACKAG' '1',
                                    'TBRGEW' '1',
                                    'TVOLUM' '1',
                                    'GROES'  '1',
                                    'CUT_YN' '1',
                                    'NTGEW'  '1',
                                    'TNTGEW'  '1',
                                    'GEWEI'   '1',
                                    'OUT_WID'  '1',
                                    'PLAN_DIA'  '1',
                                    'DR_WEIGHT'  '1',
                                    'BRGEW_DR'  '1'.

    pt_alv2-alv_col[] = l_colinfo_table[].
    MODIFY pt_alv2 INDEX l_index.

  ENDLOOP.

ENDFORM.                    " set_cell_attribute_grid2
*&---------------------------------------------------------------------*
*&      Form  append_color_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_COLINFO_TABLE  text
*      -->P_3371   text
*      -->P_3372   text
*----------------------------------------------------------------------*
FORM append_color_tab
     TABLES   pt_col TYPE slis_t_specialcol_alv
     USING    p_field  p_color.

  pt_col-fieldname = p_field.
  pt_col-color-col = p_color.
  APPEND pt_col.


ENDFORM.                    " append_color_tab
*&---------------------------------------------------------------------*
*&      Form  change_data_from_inside_grid1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_data_from_inside_grid1 .

  DATA: lt_delta_cells   TYPE lvc_t_modi,
        ls_delta_cells   TYPE lvc_s_modi,
        ls_modified      TYPE char01,
        ls_frontend_only TYPE char01,
        lt_msg           TYPE lvc_t_msg1.

  ls_delta_cells-row_id    = gv_index_p.
  ls_delta_cells-fieldname = 'SEL1'.
  ls_delta_cells-value     = ' '.
  APPEND ls_delta_cells TO lt_delta_cells.

  ls_delta_cells-row_id    = gv_index.
  ls_delta_cells-fieldname = 'SEL1'.
  ls_delta_cells-value     = 'X'.
  APPEND ls_delta_cells TO lt_delta_cells.

  CALL METHOD grid1->change_data_from_inside
    EXPORTING
      it_style_cells = lt_delta_cells
    IMPORTING
      et_bad_cells   = lt_delta_cells
      et_msg         = lt_msg.

  gv_index_p = gv_index.

ENDFORM.                    " change_data_from_inside_grid1
*&---------------------------------------------------------------------*
*&      Form  set_cell_attribute_grid1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ALV1  text
*----------------------------------------------------------------------*
FORM set_cell_attribute_grid1  TABLES   pt_alv1 LIKE gt_alv1[].

  DATA: l_colinfo_table TYPE slis_t_specialcol_alv WITH HEADER LINE.
  DATA: l_index LIKE sy-index.

* SET COLOR
  CLEAR: pt_alv1-alv_col[].

  LOOP AT pt_alv1 .
    IF NOT pt_alv1-alv_col[] IS INITIAL.
      l_index = sy-tabix.
      CLEAR l_colinfo_table[].
      pt_alv1-alv_col[] = l_colinfo_table[].
      MODIFY pt_alv1 INDEX l_index.
    ENDIF.
  ENDLOOP.

  LOOP AT pt_alv1 WHERE sel1 = 'X'.
    l_index = sy-tabix.
    CLEAR l_colinfo_table[].

    PERFORM append_color_tab TABLES l_colinfo_table
                             USING: 'VBELN'   '3',
                                    'KUNNR'   '3',
                                    'KUNNR_T' '3',
                                    'ORT01'  '3',
                                    'STRAS'  '3',
                                    'INCO1'  '3',
                                    'INCO1_T' '3',
                                    'WADAT' '3',
                                    'LFDAT' '3',
                                    'LFUHR' '3',
                                    'KUNAG' '3',
                                    'KUNAG_T' '3',
                                    'LFART'   '3',
                                    'LFART_T' '3',
                                    'ROUTE'  '3',
                                    'ROUTE_T' '3',
                                    'VSTEL' '3',
                                    'VSTEL_T' '3',
                                    'VSBED' '3',
                                    'VSBED_T' '3'.
    pt_alv1-alv_col[] = l_colinfo_table[].
    MODIFY pt_alv1 INDEX l_index.

  ENDLOOP.

ENDFORM.                    " set_cell_attribute_grid1
*&---------------------------------------------------------------------*
*&      Form  CONVERT_MEINS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_ALV2_MATNR  text
*      -->P_PT_ALV2_MEINS  text
*      -->P_PT_ALV2_VRKME  text
*      <--P_GV_MENGE  text
*----------------------------------------------------------------------*
FORM convert_meins  USING    p_matnr
                             p_in
                             p_out
                    CHANGING p_menge.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      i_matnr              = p_matnr
      i_in_me              = p_in
      i_out_me             = p_out
      i_menge              = '1'
    IMPORTING
      e_menge              = p_menge
    EXCEPTIONS
      error_in_application = 1
      error                = 2
      OTHERS               = 3.

ENDFORM.                    " CONVERT_MEINS
*&---------------------------------------------------------------------*
*&      Form  INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init .

* 절단 SPG 점검
  CLEAR: r_spg[], r_spg.
  SELECT * FROM /sapmp/lba_cust
      WHERE aktiv = 'X'.
    r_spg-sign   = 'I'.
    r_spg-option = 'EQ'.
    r_spg-low    = /sapmp/lba_cust-vstel.
    APPEND r_spg.
  ENDSELECT.

  PERFORM check_request . "[기능개선 286869]

  PERFORM set_lgort.

  PERFORM set_lgort_9000.

  APPEND VALUE #( sign = 'I' option = 'EQ' low = 'LF' )
      TO s_lfart.
  APPEND VALUE #( sign = 'I' option = 'EQ' low = 'LF4' )
      TO s_lfart.

*  PERFORM ATTACH_FILE.
ENDFORM.                    " INIT
*&---------------------------------------------------------------------*
*&      Form  filtering_logig
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_ALV1  text
*----------------------------------------------------------------------*
FORM filtering_logig  TABLES   pt_alv1 LIKE gt_alv1[].

  DATA: BEGIN OF lt_ship OCCURS 0,
          vbeln LIKE vttp-vbeln,
          shtyp LIKE vttk-shtyp,
          route LIKE vttk-route,
        END OF lt_ship.

*/ 선적문서 생성여부에 따라, 제한
  SELECT p~vbeln
         k~shtyp
         k~route
    INTO CORRESPONDING FIELDS OF TABLE lt_ship
    FROM vttp AS p INNER JOIN vttk AS k
      ON p~tknum = k~tknum
     FOR ALL ENTRIES IN pt_alv1
  WHERE p~vbeln = pt_alv1-vbeln.

  LOOP AT pt_alv1 WHERE trsta = 'B' OR trsta = 'C'.
    READ TABLE lt_ship WITH KEY vbeln = pt_alv1-vbeln.
    IF sy-subrc = 0.
      LOOP AT lt_ship WHERE vbeln = pt_alv1-vbeln
                        AND shtyp = 'Z103'.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        LOOP AT lt_ship WHERE vbeln = pt_alv1-vbeln
                          AND shtyp = 'Z101'.
        ENDLOOP.
        IF sy-subrc <> 0.
          pt_alv1-flag = 'X'.
*          DELETE gt_alv1. CONTINUE.
        ENDIF.
      ELSE.
*        DELETE gt_alv1. CONTINUE.
      ENDIF.
    ENDIF.
  ENDLOOP.

*    DELETE pt_alv1 WHERE ( trsta = 'B' OR trsta = 'C' )
*                     AND flag = ' '.

ENDFORM.                    " filtering_logig
*&---------------------------------------------------------------------*
*&      Form  SEA_SHIP_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sea_ship_check .

  LOOP AT gt_alv1 WHERE sel = 'X'
                    AND ( vsbed = '03' OR vsbed = '04')
                    AND trsta = 'A'.
    MESSAGE i002 WITH '해상운송을 먼저 생성하십시요.'.
    LEAVE SCREEN.
  ENDLOOP.

ENDFORM.                    " SEA_SHIP_CHECK
*&---------------------------------------------------------------------*
*&      Form  check_patner_crt_vbap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_patner_crt_vbap .

  CLEAR: gt_tab1[], gt_tab1.

*/ 전체조회인 경우 요청상태 체크
  PERFORM request_check_r03 USING 'R'.

  LOOP AT gt_alv1 WHERE sel = 'X'.
    gt_tab1-vbeln = gt_alv1-vbeln.
    APPEND gt_tab1.
  ENDLOOP.


  LOOP AT gt_tab1.
    SELECT SINGLE mandt INTO sy-mandt
       FROM vbpa
      WHERE vbeln = gt_tab1-vbeln
    AND parvw = 'SP'.
    IF sy-subrc = 0.
      MESSAGE i001 WITH
        gt_tab1-vbeln '이미 배차요청을 한 납품문서입니다. 확인하세요'.
      LEAVE SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " check_patner_crt_vbap
*&---------------------------------------------------------------------*
*&      Form  jego1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM jego1 .
  READ TABLE gt_alv2 WITH KEY sel2 = 'X'.
  IF sy-subrc <> 0.
    MESSAGE s000 WITH 'DATA를 선택하세요!!'.
    LEAVE SCREEN.
  ENDIF.

  RANGES: lr_matnr FOR lips-matnr.
  RANGES: lr_spart FOR lips-spart.
  RANGES: lr_charg FOR lips-charg.
  RANGES: lr_werks FOR lips-werks.
  RANGES: lr_lgort FOR lips-lgort.

*/ 선택한 라인의 자재코드를 collect
  CLEAR:   lr_matnr[], lr_matnr, lr_spart[], lr_spart,
           lr_charg[], lr_charg.

  LOOP AT gt_alv2 WHERE sel2 = 'X'.

    IF gt_alv2-matnr IS NOT INITIAL.
      lr_matnr-sign   = 'I'.
      lr_matnr-option = 'EQ'.
      lr_matnr-low    = gt_alv2-matnr.
      COLLECT lr_matnr.
    ENDIF.

    IF gt_alv2-werks IS NOT INITIAL.
      lr_werks-sign   = 'I'.
      lr_werks-option = 'EQ'.
      lr_werks-low    = gt_alv2-werks.
      COLLECT lr_werks.
    ENDIF.

    IF gt_alv2-lgort IS NOT INITIAL.
      lr_lgort-sign   = 'I'.
      lr_lgort-option = 'EQ'.
      lr_lgort-low    = gt_alv2-lgort.
      COLLECT lr_lgort.
    ENDIF.

*    R_CHARG-SIGN   = 'I'.
*    R_CHARG-OPTION = 'EQ'.
*    R_CHARG-LOW    = GT_ALV2-CHARG.
*    COLLECT R_CHARG.
*
*    R_SPART-SIGN   = 'I'.
*    R_SPART-OPTION = 'EQ'.
*    R_SPART-LOW    = GT_ALV2-SPART.
*    COLLECT R_SPART.

  ENDLOOP.

*  DELETE R_CHARG WHERE LOW = ' '.

*  SUBMIT ZLER0037 AND RETURN
*      WITH I_MATNR  IN R_MATNR
*      WITH I_SPART  IN R_SPART
*      WITH I_CHARG  IN R_CHARG.

  SUBMIT zler0037 VIA SELECTION-SCREEN
      WITH r1       EQ gc_x
      WITH r2       EQ space
      WITH i_matnr  IN lr_matnr
      WITH i_werks  IN lr_werks
      WITH i_lgort  IN lr_lgort
      AND RETURN.





*/ mara 에서 제품군을 찾고,

*/ ranges  설정: matnr , spart

*/ submit 한다....


* 납품요청일은 필수.
* 납품의 선행문서의 납품요청일을 찾는다.
*  RANGES: r_vbeln FOR lips-vbeln.
*  RANGES: r_vgbel FOR lips-vgbel.
*  RANGES: r_spart FOR lips-spart.
*  RANGES: r_vtweg FOR lips-vtweg.
*  RANGES: r_vdatu FOR vbak-vdatu.
*
*  CLEAR: r_vgbel[], r_vgbel, r_vdatu[], r_vdatu,
*         r_spart[], r_spart, r_vtweg[], r_vtweg,
*         r_vbeln[], r_vbeln.
*
*
*  IF NOT r_vgbel[] IS INITIAL.
*    SELECT * FROM vbak WHERE vbeln IN r_vgbel.
*      r_vdatu-sign   = 'I'.
*      r_vdatu-option = 'EQ'.
*      r_vdatu-low    = vbak-vdatu.
*      APPEND r_vdatu.
*    ENDSELECT.

*  SUBMIT zler0037 AND RETURN.
*        WITH so_vdatu  IN r_vdatu
*        WITH so_vbel2  IN r_vbeln
*        WITH so_spart  IN r_spart
*        WITH so_vtweg  IN r_vtweg.
*  ENDIF.

ENDFORM.                                                    " jego1
*&---------------------------------------------------------------------*
*&      Form  CONTROL_GRID2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ALV2  text
*----------------------------------------------------------------------*
FORM control_grid2  TABLES   pt_alv2 LIKE gt_alv2[].

  READ TABLE pt_alv2 INDEX gv_index.
  CHECK sy-subrc = 0.
  IF pt_alv2-sel2 EQ gc_x.
    pt_alv2-sel2 = ' '.
    MODIFY pt_alv2  TRANSPORTING sel2
                                WHERE sel2 = 'X'.

    pt_alv2-sel2 = 'X'.
    MODIFY pt_alv2  TRANSPORTING sel2
                    WHERE posnr = pt_alv2-posnr.


  ENDIF.


ENDFORM.                    " CONTROL_GRID2
*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_ALV1  text
*----------------------------------------------------------------------*
FORM get_data  TABLES   pt_alv1 LIKE gt_alv1[]
                        pr_vbeln LIKE r_vbeln[].

**/ SELECT ~ LIKP , LIPS, VBUK
  SELECT k~vbeln
         k~kunnr
         k~inco1
         k~lddat
         k~lduhr
         k~wadat
         k~wauhr
         k~lfdat
         k~lfuhr
         k~kunag
         k~lfart
         k~route
         k~vstel
         k~vsbed
         k~zout
         k~trsta
         p~vgbel
         p~vgpos
         p~vtweg
         p~vkbur
         p~vkgrp
         k~ernam
    INTO CORRESPONDING FIELDS OF TABLE pt_alv1
    FROM likp AS k INNER JOIN lips AS p
                   ON k~vbeln = p~vbeln
   WHERE k~trsta <> ' '
     AND k~vstel IN s_vstel
     AND k~wadat IN s_wadat
     AND k~lfdat IN s_lfdat
     AND k~vbeln IN s_vbeln
     AND k~vbeln IN r_vbeln
     AND k~lfart IN s_lfart
     AND k~kunag IN s_kunag
     AND k~kunnr IN s_kunnr
     AND k~route IN s_route
     AND k~vsbed IN s_vsbed
     AND k~inco1 IN s_inco1
     AND k~ernam IN s_ernam
     AND k~erdat IN s_erdat
     AND k~zout  IN s_zout
     AND k~kostk IN s_kostk
     AND k~trsta IN s_trsta
     AND k~wbstk IN s_wbstk
     AND k~lifsk NE gc_lifsk_g3   "적송
     AND p~vgbel IN s_vbelno
     AND p~vtweg IN s_vtweg
     AND p~vkbur IN s_vkbur
     AND p~lgort IN s_lgort
     AND p~lgort NE gc_lgort_3499 "적송
     AND p~zzvbeln_js EQ space    "적송
     AND p~vkgrp IN s_vkgrp.

  SORT pt_alv1.

*-> S4HANA 영업사원변경 : 2023.07.19
*  IF NOT s_pernr[] IS INITIAL.
*    DELETE pt_alv1 WHERE lfart = 'NL'.
*  ENDIF.
  IF NOT s_lifnr[] IS INITIAL.
    DELETE pt_alv1 WHERE lfart = 'NL'.
  ENDIF.
*<-
  DATA(lt_tmp) = pt_alv1[].
  SELECT a~vbeln, b~iv_no
    FROM @lt_tmp AS a INNER JOIN zgtsd_i_valid_inv_item AS b
                       ON a~vbeln EQ b~vbeln
   GROUP BY a~vbeln, b~iv_no
   INTO TABLE @DATA(lt_iv).
  SORT lt_iv BY vbeln.

  LOOP AT pt_alv1.

    IF pt_alv1-zout = 'X'.
      pt_alv1-zout_t = '통문미대상'.
    ELSEIF pt_alv1-zout = 'Y'.
      pt_alv1-zout_t = '통문확정'.
    ELSE.
      pt_alv1-zout_t = '통문미확정'.
    ENDIF.
*-> S4HANA 영업사원변경 : 2023.07.19
*    IF NOT s_pernr[] IS INITIAL.
*      SELECT SINGLE pernr INTO pt_alv1-pernr FROM vbpa
*        WHERE vbeln = pt_alv1-vgbel
*          AND posnr = '000000'
*          AND parvw = 'VE'
*      AND pernr IN s_pernr.
*      IF sy-subrc <> 0.
*        DELETE pt_alv1. CONTINUE.
*      ENDIF.
*    ELSE.
*      SELECT SINGLE pernr INTO pt_alv1-pernr FROM vbpa
*        WHERE vbeln = pt_alv1-vgbel
*          AND posnr = '000000'
*      AND parvw = 'VE'.
*    ENDIF.

    pt_alv1-iv_no = VALUE #( lt_iv[ vbeln = pt_alv1-vbeln ]-iv_no OPTIONAL ).

    "영업사원
    DATA lv_lifnr_tmp TYPE vbpa-lifnr.
    IF NOT s_lifnr[] IS INITIAL.
      SELECT SINGLE lifnr
        FROM vbpa
       WHERE vbeln EQ @pt_alv1-vgbel
         AND posnr = '000000'
         AND parvw = 'VE'
         AND lifnr IN @s_lifnr
        INTO @lv_lifnr_tmp.
      IF sy-subrc <> 0.
        DELETE pt_alv1. CONTINUE.
      ELSE.
        REPLACE FIRST OCCURRENCE OF 'E' IN lv_lifnr_tmp WITH space.
        pt_alv1-pernr = lv_lifnr_tmp.
      ENDIF.
    ELSE.
      SELECT SINGLE lifnr
        FROM vbpa
       WHERE vbeln EQ @pt_alv1-vgbel
         AND posnr = '000000'
         AND parvw = 'VE'
        INTO @lv_lifnr_tmp.
      IF sy-subrc EQ 0.
        REPLACE FIRST OCCURRENCE OF 'E' IN lv_lifnr_tmp WITH space.
        pt_alv1-pernr = lv_lifnr_tmp.
      ENDIF.
    ENDIF.
*<-
*   수출구분(VBKD-KDKG4)
    IF pt_alv1-vgbel IS NOT INITIAL.
      SELECT SINGLE kdkg4
        INTO pt_alv1-kdkg4
        FROM vbkd
       WHERE vbeln EQ pt_alv1-vgbel
         AND posnr EQ '000000'.
    ENDIF.

    MODIFY pt_alv1.
  ENDLOOP.

  DATA: lt_vbpa    LIKE vbpa OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_vbpa, lt_vttk, lt_vttk1.
  IF NOT pt_alv1[] IS INITIAL.
*/ 파트너 운송사가 있냐 없냐 체크하는 부분임.
    SELECT * INTO TABLE lt_vbpa FROM vbpa
       FOR ALL ENTRIES IN pt_alv1
      WHERE vbeln = pt_alv1-vbeln
        AND posnr = '000000'
        AND parvw = 'SP'.

*/ 선적데이타
    SELECT k~tknum k~shtyp p~vbeln
           k~text1 k~text2 k~text3 k~text4 k~route
      INTO CORRESPONDING FIELDS OF TABLE lt_vttk
      FROM vttp AS p INNER JOIN vttk AS k
        ON p~tknum = k~tknum
       FOR ALL ENTRIES IN pt_alv1
    WHERE p~vbeln = pt_alv1-vbeln
*[S] 안정화    GW20260827001
      and    k~tknum IN s_tknum.
*[E] 안정화    GW20260827001
    lt_vttk1[] = lt_vttk[].
    DELETE lt_vttk1 WHERE shtyp = 'Z103'.
  ENDIF.

  SORT lt_vbpa BY vbeln.

  LOOP AT pt_alv1.
    IF pt_alv1-route CS '-001' OR pt_alv1-route CS '-002'.
      DELETE pt_alv1.
      CONTINUE.
    ENDIF.

    READ TABLE lt_vbpa WITH KEY vbeln = pt_alv1-vbeln
                            BINARY SEARCH.
    IF sy-subrc = 0.
* 운송사가 있음으로  요청완료..
      pt_alv1-flag = 'X'.
      pt_alv1-carrier = lt_vbpa-lifnr.
    ELSE.
* 운송사가 없더라도, 운송계획상태가 b or c 이면, 요청완료..
      IF pt_alv1-trsta = 'B' OR pt_alv1-trsta = 'C'.
        pt_alv1-flag = 'X'.
      ENDIF.
    ENDIF.
    MODIFY pt_alv1.
  ENDLOOP.

* 단, 예외적으로 b or c 라도, 해상운송만 선적생성되어 있으면, 미요청
  LOOP AT pt_alv1 WHERE ( trsta = 'B' OR trsta = 'C' ) AND
                          flag  = 'X'.
    READ TABLE lt_vttk WITH KEY vbeln = pt_alv1-vbeln
                                shtyp = 'Z103'.
*/수출해상운송 생성분 중에서
    IF sy-subrc = 0.
      READ TABLE lt_vttk1 WITH KEY vbeln = pt_alv1-vbeln.
*/수출해상운송 아닌 선적유형이 있냐
      IF sy-subrc <> 0.
*/없다면 아직 수출내륙운송을 안만들었다.
        pt_alv1-flag = ' '.
        MODIFY pt_alv1.
      ENDIF.
    ENDIF.
  ENDLOOP.



*- 전체조회 추가에 따른 구문 변경  20210122 -[s]
*  IF R01 = 'X'.  "배차미요청
*    DELETE PT_ALV1 WHERE FLAG = 'X'.
*  ELSE.
*    DELETE PT_ALV1 WHERE FLAG = ' '.
*    LOOP AT PT_ALV1.
*
*      READ TABLE LT_VTTK1 WITH KEY VBELN = PT_ALV1-VBELN.
*      IF SY-SUBRC = 0.
*        PT_ALV1-TKNUM  = LT_VTTK1-TKNUM.
*        PT_ALV1-STATUS = '선적생성'.
*      ELSE.
*        PT_ALV1-STATUS = '미생성'.
*      ENDIF.
*
*      IF PT_ALV1-CARRIER IS INITIAL.
*        PT_ALV1-GUBUN = '당사'.
*      ELSE.
*        PT_ALV1-GUBUN = '운송사'.
*      ENDIF.
*      MODIFY PT_ALV1.
*    ENDLOOP.
*  ENDIF.

  CASE gc_x.
    WHEN  r01.   "미요청
      DELETE pt_alv1 WHERE flag = 'X'.
    WHEN  r02.   "요청완료
      DELETE pt_alv1 WHERE flag = ' '.
      DATA(lt_temp) = pt_alv1[].
      CLEAR:pt_alv1,pt_alv1[].
      LOOP AT lt_temp INTO DATA(ls_temp).
        CLEAR pt_alv1.
        MOVE-CORRESPONDING ls_temp TO pt_alv1.
        LOOP AT lt_vttk1 INTO DATA(ls_vttk1) WHERE vbeln = ls_temp-vbeln.
          pt_alv1-tknum  = ls_vttk1-tknum.
          pt_alv1-status = '선적생성'.
          IF pt_alv1-carrier IS INITIAL.
            pt_alv1-gubun = '당사'.
          ELSE.
            pt_alv1-gubun = '운송사'.
          ENDIF.
          APPEND pt_alv1.
        ENDLOOP.
      ENDLOOP.
*      LOOP AT PT_ALV1.
*        READ TABLE LT_VTTK1 WITH KEY VBELN = PT_ALV1-VBELN.
*        IF SY-SUBRC = 0.
*          PT_ALV1-TKNUM  = LT_VTTK1-TKNUM.
*          PT_ALV1-STATUS = '선적생성'.
*        ELSE.
*          PT_ALV1-STATUS = '미생성'.
*        ENDIF.
*
*        IF PT_ALV1-CARRIER IS INITIAL.
*          PT_ALV1-GUBUN = '당사'.
*        ELSE.
*          PT_ALV1-GUBUN = '운송사'.
*        ENDIF.
*        MODIFY PT_ALV1.
*      ENDLOOP.
    WHEN  r10.   "복수배차
      CLEAR:lt_temp[].
      lt_temp[] = pt_alv1[].
      CLEAR:pt_alv1,pt_alv1[].
      LOOP AT lt_temp INTO ls_temp.
        CLEAR pt_alv1.
        MOVE-CORRESPONDING ls_temp TO pt_alv1.
        LOOP AT lt_vttk1 INTO ls_vttk1 WHERE vbeln = ls_temp-vbeln.
          pt_alv1-tknum  = ls_vttk1-tknum.
          pt_alv1-status = '선적생성'.
          IF pt_alv1-carrier IS INITIAL.
            pt_alv1-gubun = '당사'.
          ELSE.
            pt_alv1-gubun = '운송사'.
          ENDIF.
          APPEND pt_alv1.
        ENDLOOP.
      ENDLOOP.
*      LOOP AT PT_ALV1.
*        IF GV_TKNUM_MULTI IS NOT INITIAL.
*          PT_ALV1-TKNUM  = GV_TKNUM_MULTI.
*          PT_ALV1-STATUS = '선적생성'.
*        ENDIF.
*
*        IF PT_ALV1-CARRIER IS INITIAL.
*          PT_ALV1-GUBUN = '당사'.
*        ELSE.
*          PT_ALV1-GUBUN = '운송사'.
*        ENDIF.
*        MODIFY PT_ALV1.
*      ENDLOOP.
    WHEN  r03.   "전체
      LOOP AT pt_alv1 WHERE flag = 'X'. "배차완료 대상 한정
        READ TABLE lt_vttk1 WITH KEY vbeln = pt_alv1-vbeln.
        IF sy-subrc = 0.
          pt_alv1-tknum  = lt_vttk1-tknum.
          pt_alv1-status = '선적생성'.
        ELSE.
          pt_alv1-status = '미생성'.
        ENDIF.

        IF pt_alv1-carrier IS INITIAL.
          pt_alv1-gubun = '당사'.
        ELSE.
          pt_alv1-gubun = '운송사'.
        ENDIF.
        MODIFY pt_alv1.
      ENDLOOP.
  ENDCASE.

*- 전체조회 추가에 따른 구문 변경  20210122 -[e]



*  IF NOT pt_alv1[] IS INITIAL.
*    DATA: BEGIN OF lt_zlet0005 OCCURS 0,
*           vbeln LIKE lips-vbeln,
*          END OF lt_zlet0005.
*
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zlet0005
*      FROM zlet0006 AS p INNER JOIN zlet0005 AS k
*        ON p~iv_no = k~iv_no
*       FOR ALL ENTRIES IN pt_alv1
*     WHERE p~vbeln = pt_alv1-vbeln
*       AND k~out_yn = 'X'.
*
*    LOOP AT pt_alv1.
*      READ TABLE lt_zlet0005 WITH KEY vbeln = pt_alv1-vbeln.
*      IF sy-subrc = 0.
*        DELETE pt_alv1.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

** 통문 CBO에 완료된 납품문서는 대상에서 제외한다. MKJANG
*  DATA: lv_iv_no LIKE zlet0005-iv_no.
*  LOOP AT pt_alv1.
*    SELECT SINGLE a~iv_no INTO lv_iv_no
*      FROM zlet0005 AS a
*      INNER JOIN zlet0006 AS b
*      ON a~iv_no = b~iv_no
*      WHERE b~vbeln = pt_alv1-vbeln
*        AND a~out_yn = 'X'.
*
**    IF sy-subrc = 0.
**      SELECT SINGLE mandt INTO sy-mandt FROM zlet0005
**        WHERE iv_no = lv_iv_no
**          AND out_yn = 'X'.
*    IF sy-subrc = 0.
*      DELETE pt_alv1. CONTINUE.
*    ENDIF.
**    ENDIF.
*  ENDLOOP.

ENDFORM.                    " get_data
*&---------------------------------------------------------------------*
*&      Form  ROCK_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM rock_check USING p_vbeln.

  CALL FUNCTION 'ENQUEUE_EVVBLKE'
    EXPORTING
      vbeln          = p_vbeln
    EXCEPTIONS
      foreign_lock   = 2
      system_failure = 3.
  CASE sy-subrc.
    WHEN 0.
      PERFORM dequeue_rock USING p_vbeln.
    WHEN 2.
      DATA: lv_msgcode(100).
      CONCATENATE '납품문서' p_vbeln '사용자' sy-msgv1
       '현재 처리중입니다' INTO lv_msgcode SEPARATED BY space.
      PERFORM dequeue_rock USING p_vbeln.
      MESSAGE s001 WITH lv_msgcode.
      LEAVE SCREEN.
    WHEN OTHERS.
      PERFORM dequeue_rock USING p_vbeln.
  ENDCASE.

ENDFORM.                    " ROCK_CHECK
*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_ROCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_VBELN  text
*----------------------------------------------------------------------*
FORM dequeue_rock  USING    p_vbeln.

  CALL FUNCTION 'DEQUEUE_EVVBLKE'
    EXPORTING
      vbeln = p_vbeln.
*    EXCEPTIONS
*      foreign_lock   = 2
*      system_failure = 3.

ENDFORM.                    " DEQUEUE_ROCK
*&---------------------------------------------------------------------*
*&      Form  CONVERT_ALPHA_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM convert_alpha_input USING p_xx.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_xx
    IMPORTING
      output = p_xx.

ENDFORM.                    " CONVERT_ALPHA_INPUT
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_MEINS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_ALV2_MATNR  text
*      -->P_PT_ALV2_GEWEI  text
*      -->P_2808   text
*      -->P_PT_ALV2_BRGEW  text
*----------------------------------------------------------------------*
FORM conversion_meins  USING    p_matnr
                                p_in
                                p_out
                                p_value.

  DATA: lv_menge LIKE ekpo-menge.

  CLEAR: lv_menge.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      i_matnr              = p_matnr
      i_in_me              = p_in
      i_out_me             = p_out
      i_menge              = '1'
    IMPORTING
      e_menge              = lv_menge
    EXCEPTIONS
      error_in_application = 1
      error                = 2
      OTHERS               = 3.

  p_value = lv_menge * p_value.

ENDFORM.                    " CONVERSION_MEINS
*&---------------------------------------------------------------------*
*&      Form  BCANCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bcancel .

*/ 전체조회인 경우 요청상태 체크
  PERFORM request_check_r03 USING 'C'.

  PERFORM error_check_reverse USING 'D'.


*/ 요청취소: 당사배차
  PERFORM save_reverse_tknum.

*/ 요청취소: 운송사배차
  PERFORM save_reverse_vbeln.

*/
  REFRESH: r_vbeln, ut_alv1.
  LOOP AT gt_alv1 WHERE sel = 'X'.
    r_vbeln-sign   = 'I'.
    r_vbeln-option = 'EQ'.
    r_vbeln-low    = gt_alv1-vbeln.
    APPEND r_vbeln.
  ENDLOOP.


  PERFORM data_query TABLES ut_alv1
                            r_vbeln.

  LOOP AT gt_alv1 WHERE sel = 'X'.
    READ TABLE ut_alv1 WITH KEY vbeln = gt_alv1-vbeln
                                tknum = gt_alv1-tknum.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ut_alv1 TO gt_alv1.
      MODIFY gt_alv1.
    ELSE.
      DELETE gt_alv1.
    ENDIF.
  ENDLOOP.

  CALL METHOD grid2->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = l_scroll.     "현재 그대로 입력한 refresh

  CALL METHOD grid1->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = l_scroll.     "현재 그대로 입력한 refresh

ENDFORM.                    " BCANCEL
*&---------------------------------------------------------------------*
*&      Form  BMODIFY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bmodify.

*/ 전체조회인 경우 요청상태 체크
  PERFORM request_check_r03 USING 'C'.

  PERFORM error_check_reverse USING 'U'.

  PERFORM error_check_reverse1.

  READ TABLE gt_alv1 WITH KEY sel = 'X'
                              status = '선적생성'.
  IF sy-subrc = 0.                                          "VT02N 이동
*/ 요청수정: 당사배차
    PERFORM save_reverse_tknum1.
  ELSE.
*/ 요청수정: 운송사배차
    PERFORM save_reverse_vbeln1.
  ENDIF.

  REFRESH: r_vbeln, ut_alv1.
  LOOP AT gt_alv1 WHERE sel = 'X'.
    r_vbeln-sign   = 'I'.
    r_vbeln-option = 'EQ'.
    r_vbeln-low    = gt_alv1-vbeln.
    APPEND r_vbeln.
  ENDLOOP.

  PERFORM data_query TABLES ut_alv1
                            r_vbeln.

  LOOP AT gt_alv1 WHERE sel = 'X'.
    READ TABLE ut_alv1 WITH KEY vbeln = gt_alv1-vbeln
                                tknum = gt_alv1-tknum.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ut_alv1 TO gt_alv1.
      MODIFY gt_alv1.
    ELSE.
      DELETE gt_alv1.
    ENDIF.
  ENDLOOP.

  PERFORM message_show1 TABLES gt_xmesg1.



ENDFORM.                    " BMODIFY
*&---------------------------------------------------------------------*
*&      Form  message_gathering
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_XMESG  text
*      -->P_LT_TAB_TKNUM  text
*      -->P_6146   text
*----------------------------------------------------------------------*
FORM message_gathering  TABLES   pt_mesg LIKE gt_xmesg[]
                        USING    p_key1 p_text.

  CLEAR : gt_xmesg[].
  pt_mesg-tknum   = p_key1.
  pt_mesg-text    = p_text.
  APPEND pt_mesg.


ENDFORM.                    " message_gathering
*&---------------------------------------------------------------------*
*&      Form  message_show
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_XMESG  text
*----------------------------------------------------------------------*
FORM message_show  TABLES   pt_mesg LIKE gt_xmesg[].

  CHECK NOT gt_xmesg[] IS INITIAL.
  CLEAR: g_fieldcat_m[].

  DATA : col_pos TYPE i.
  IF g_fieldcat_m[] IS INITIAL.
    CLEAR col_pos.

    CLEAR: g_fieldcat_m.
    ADD 1 TO col_pos.
    g_fieldcat_m-col_pos    =  col_pos.
    g_fieldcat_m-seltext_m  = '선적번호'.
    g_fieldcat_m-fieldname  = 'TKNUM'.
    g_fieldcat_m-outputlen  = '12'.
    g_fieldcat_m-datatype   = 'CHAR'.
    g_fieldcat_m-tabname     = 'GT_XMESG'.
    g_fieldcat_m-key        = 'X'.
    g_fieldcat_m-emphasize  = 'C510'.
    APPEND g_fieldcat_m.

    CLEAR g_fieldcat_m.
    ADD 1 TO col_pos.
    g_fieldcat_m-col_pos    =  col_pos.
    g_fieldcat_m-seltext_m  = '결과 텍스트 '.
    g_fieldcat_m-fieldname  = 'TEXT'.
    g_fieldcat_m-outputlen  = '100'.
    g_fieldcat_m-datatype   = 'CHAR'.
    g_fieldcat_m-tabname    = 'GT_XMESG'.
    APPEND g_fieldcat_m.
  ENDIF.
*
  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title               = '결과 LIST'
      i_selection           = space
      i_zebra               = 'X'
      i_screen_start_column = 10
      i_screen_start_line   = 10
      i_screen_end_column   = 110
      i_screen_end_line     = 30
      i_tabname             = 'GT_XMESG'
      it_fieldcat           = g_fieldcat_m[]
      i_callback_program    = sy-repid
    TABLES
      t_outtab              = pt_mesg
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.


ENDFORM.                    " message_show
*&---------------------------------------------------------------------*
*&      Form  ERROR_CHECK_REVERSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error_check_reverse USING p_step.

  DATA: lv_gubun1  TYPE i, lv_gubun2  TYPE i,
        lv_status1 TYPE i, lv_status2 TYPE i.
  DATA: lv_text(50).
  DATA: lv_ivno       LIKE zlet0005-iv_no.
  DATA: BEGIN OF lt_zxvtt OCCURS 0,
          vbeln LIKE vttp-vbeln,
          fidno LIKE ztetfdp-fidno,
        END OF lt_zxvtt.

  CLEAR: lv_gubun1, lv_gubun2, lv_status1, lv_status2.
  LOOP AT gt_alv1 WHERE sel = 'X'.
    IF gt_alv1-gubun = '운송사'.
      ADD 1  TO lv_gubun1 .
    ELSE.
      ADD 1  TO lv_gubun2 .
    ENDIF.

    IF gt_alv1-status = '선적생성'.
      lv_status1 = 1.
    ELSE.
      lv_status2 = 1.
    ENDIF.

*1. 당사배차와 운송사배차를 동시에 선택할수 없다.
    IF lv_gubun1 => 1 AND lv_gubun2 => 1.
      MESSAGE i000 WITH
     '당사배차와 운송사배차를 동시에 선택할수 없습니다.'.
      LEAVE SCREEN.
    ENDIF.
*2. 운송사배차는 SINGLE CHOICE
    IF lv_gubun1 > 1.
      MESSAGE i000 WITH
     '운송사배차는 한건씩 선택할수 있습니다.'.
      LEAVE SCREEN.
    ENDIF.

*/ 선적비용 생성후에는 요청취소 할수 없다. *3. 아래보다 먼저
    IF gt_alv1-status = '선적생성'.
      DATA: lv_fbsta  LIKE vttk-fbsta.
      CLEAR: lv_fbsta.

      SELECT SINGLE fbsta INTO lv_fbsta FROM vttk
      WHERE tknum EQ gt_alv1-tknum.

      IF lv_fbsta = 'B' OR lv_fbsta = 'C'.
        CASE p_step.
          WHEN 'U'.  "요청수정
            lv_text = '선적비용문서가 이미 생성되어 요청수정 불가!'.
          WHEN 'D'.  "요청취소
            lv_text = '선적비용문서가 이미 생성되어 요청취소 불가!'.
        ENDCASE.
        MESSAGE i001 WITH gt_alv1-tknum
                          lv_text.
        LEAVE SCREEN.
      ENDIF.
    ENDIF.

*3. 운송사배차인데, 선적생성되었다면, 에러
    IF gt_alv1-gubun = '운송사' AND gt_alv1-status = '선적생성'.
      MESSAGE i018 WITH gt_alv1-vbeln.
      LEAVE SCREEN.
    ENDIF.

*4. 삭제시 => 거래명세서발행 체크
    CLEAR:lv_ivno,lt_zxvtt,lt_zxvtt[].
    IF p_step EQ 'D'.
      SELECT SINGLE a~iv_no
        INTO lv_ivno
        FROM zlet0005 AS a
       INNER JOIN zlet0006 AS b
          ON a~iv_no = b~iv_no
       WHERE b~tknum  = gt_alv1-tknum
         AND a~out_yn = 'X'.        "통문확정

      IF sy-subrc = 0.
        MESSAGE s001(zle1) WITH lv_ivno
                               '통문확정취소->거래명세서발행취소 하세요!'
                           INTO lv_text.
        MESSAGE i001 WITH gt_alv1-tknum
                            lv_text.
        LEAVE SCREEN.

      ELSE.
        SELECT SINGLE a~iv_no
          INTO lv_ivno
          FROM zlet0005 AS a
         INNER JOIN zlet0006 AS b
            ON a~iv_no = b~iv_no
         WHERE b~tknum        = gt_alv1-tknum
           AND a~iv_print_yn  = 'X'      "거래명세서발행
           AND a~iv_cancel_yn = ' '.     "거래명세서발행취소

        IF sy-subrc = 0.
          MESSAGE s001(zle1) WITH lv_ivno
                                  '거래명세서 발행취소 하세요!'
                             INTO lv_text.
          MESSAGE i001 WITH gt_alv1-tknum
                            lv_text.
          LEAVE SCREEN.
        ENDIF.
      ENDIF.
*     선적문서의 납품문서에 L/C가 지정되어 있으면 삭제불가
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE lt_zxvtt
        FROM vttp AS a
                      INNER JOIN vttk AS b
                      ON a~tknum = b~tknum
       WHERE b~shtyp = 'Z103'
         AND a~tknum = gt_alv1-tknum.

      IF sy-subrc = 0.
        LOOP AT lt_zxvtt.
          SELECT SINGLE fidno
            INTO lt_zxvtt-fidno
            FROM ztetfdp
           WHERE vbeln EQ lt_zxvtt-vbeln.

          IF sy-subrc = 0.
            MESSAGE s004(zle1) WITH lt_zxvtt-fidno
                                    'L/C문서를 먼저 삭제하셔야 합니다.'
                               INTO lv_text.
            MESSAGE i001 WITH gt_alv1-tknum
                            lv_text.
            LEAVE SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDIF.
  ENDLOOP.

ENDFORM.                    " ERROR_CHECK_REVERSE
*&---------------------------------------------------------------------*
*&      Form  SAVE_REVERSE_TKNUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_reverse_tknum .

  DATA: BEGIN OF lt_tab OCCURS 0,
          tknum LIKE vttk-tknum,
        END OF lt_tab.

  REFRESH: lt_tab. CLEAR: lt_tab.
  LOOP AT gt_alv1 WHERE sel = 'X'
                    AND tknum <> ' '.
    lt_tab-tknum = gt_alv1-tknum.
    COLLECT lt_tab.
  ENDLOOP.

* 다른 사용자가 ROCK을 잡고 있으면, 에러.
  LOOP AT lt_tab.
    PERFORM lock_check USING lt_tab-tknum.
  ENDLOOP.


  IF NOT lt_tab[] IS INITIAL.
    bdc_mode = 'N'.
    LOOP AT lt_tab.
      CALL FUNCTION 'Z_LE_VT02N_DELETE'
        EXPORTING
          i_tknum  = lt_tab-tknum
          i_mode   = bdc_mode
        IMPORTING
          return   = gv_return
          zmessage = gv_zmsg.
      IF gv_return = 'S'.
        SELECT SINGLE mandt INTO sy-mandt FROM vttk
        WHERE tknum = lt_tab-tknum.
        IF sy-subrc = 0.  "Error
          PERFORM message_gathering TABLES gt_xmesg
            USING  lt_tab-tknum
             'E: 오류발생'.                                  .
        ELSE.             "Success
          PERFORM message_gathering TABLES gt_xmesg
                                      USING  lt_tab-tknum
                                             '선적삭제'.
        ENDIF.
      ELSE.
        PERFORM message_gathering TABLES gt_xmesg
                                   USING  lt_tab-tknum
                                          gv_zmsg.
      ENDIF.

    ENDLOOP.
  ENDIF.

  PERFORM message_show TABLES gt_xmesg.

ENDFORM.                    " SAVE_REVERSE_TKNUM
*&---------------------------------------------------------------------*
*&      Form  SAVE_REVERSE_VBELN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_reverse_vbeln .

  bdc_mode = 'N'.

  LOOP AT gt_alv1 WHERE sel = 'X'
                 AND tknum = ' '.
    CALL FUNCTION 'Z_LE_VL02N_TMS01'
      EXPORTING
        i_vbeln   = gt_alv1-vbeln
        i_lddat   = wa-lddat
        i_lduhr   = wa-lduhr
        i_wadat   = wa-lddat    "wa-wadat
        i_wauhr   = wa-lduhr    "wa-wauhr
        i_lfdat   = wa-lfdat
        i_lfuhr   = wa-lfuhr
        i_carrier = wa-carrier
        i_inco1   = wa-inco1
        i_traid   = wa-traid
        i_lifex   = wa-ztext
        i_anzpk   = wa-anzpk
        i_xabln   = wa-xabln
        i_reverse = 'X'
        i_tbrgew  = ' '    "총중량
        i_mode    = bdc_mode
      IMPORTING
        return    = gv_return
        zmessage  = gv_zmsg.
    IF gv_return = 'S'.
      PERFORM message_gathering1 TABLES gt_xmesg1
                                  USING  gt_alv1-vbeln
                                         '납품변경'.

    ELSE.
      PERFORM message_gathering1 TABLES gt_xmesg1
                                 USING  gt_alv1-vbeln
                                        gv_zmsg.
    ENDIF.
  ENDLOOP.

  PERFORM message_show1 TABLES gt_xmesg1.

ENDFORM.                    " SAVE_REVERSE_VBELN
*&---------------------------------------------------------------------*
*&      Form  message_gathering1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_XMESG1  text
*      -->P_GT_ALV1_VBELN  text
*      -->P_6434   text
*----------------------------------------------------------------------*
FORM message_gathering1  TABLES  pt_mesg LIKE gt_xmesg1[]
                        USING    p_key1 p_text.
  CLEAR : gt_xmesg1[].
  pt_mesg-vbeln   = p_key1.
  pt_mesg-text    = p_text.
  APPEND pt_mesg.


ENDFORM.                    " message_gathering1
*&---------------------------------------------------------------------*
*&      Form  message_show1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_XMESG1  text
*----------------------------------------------------------------------*
FORM message_show1  TABLES   pt_mesg LIKE gt_xmesg1[].

  CHECK NOT pt_mesg[] IS INITIAL.
  CLEAR: g_fieldcat_m[].

  DATA : col_pos TYPE i.
  IF g_fieldcat_m[] IS INITIAL.
    CLEAR col_pos.

    CLEAR: g_fieldcat_m.
    ADD 1 TO col_pos.
    g_fieldcat_m-col_pos    =  col_pos.
    g_fieldcat_m-seltext_m  = '납품번호'.
    g_fieldcat_m-fieldname  = 'VBELN'.
    g_fieldcat_m-outputlen  = '12'.
    g_fieldcat_m-datatype   = 'CHAR'.
    g_fieldcat_m-tabname     = 'GT_XMESG1'.
    g_fieldcat_m-key        = 'X'.
    g_fieldcat_m-emphasize  = 'C510'.
    APPEND g_fieldcat_m.

    CLEAR g_fieldcat_m.
    ADD 1 TO col_pos.
    g_fieldcat_m-col_pos    =  col_pos.
    g_fieldcat_m-seltext_m  = '결과 텍스트 '.
    g_fieldcat_m-fieldname  = 'TEXT'.
    g_fieldcat_m-outputlen  = '100'.
    g_fieldcat_m-datatype   = 'CHAR'.
    g_fieldcat_m-tabname    = 'GT_XMESG1'.
    APPEND g_fieldcat_m.
  ENDIF.
*
  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title               = '결과 LIST'
      i_selection           = space
      i_zebra               = 'X'
      i_screen_start_column = 10
      i_screen_start_line   = 10
      i_screen_end_column   = 110
      i_screen_end_line     = 30
      i_tabname             = 'GT_XMESG1'
      it_fieldcat           = g_fieldcat_m[]
      i_callback_program    = sy-repid
    TABLES
      t_outtab              = pt_mesg
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.


ENDFORM.                    " message_show1
*&---------------------------------------------------------------------*
*&      Form  error_check_reverse1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM error_check_reverse1 .

  DATA: lv_gubun1  TYPE i, lv_gubun2  TYPE i,
        lv_status1 TYPE i, lv_status2 TYPE i.

  CLEAR: lv_gubun1, lv_gubun2, lv_status1, lv_status2.
  LOOP AT gt_alv1 WHERE sel = 'X'.

    IF gt_alv1-status = '선적생성'.
      ADD 1 TO lv_status1 .
    ELSE.
      ADD 1 TO lv_status2 .
    ENDIF.

*   당사배차인데, 여러건 선적이 선택되었다면, 에러
    IF gt_alv1-gubun = '당사' AND lv_status1 > 1.
      MESSAGE i000 WITH
      '하나 이상의 선적문서가 선택되었습니다. 확인하세요.'.
      LEAVE SCREEN.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " error_check_reverse1
*&---------------------------------------------------------------------*
*&      Form  save_reverse_tknum1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_reverse_tknum1 .

  READ TABLE gt_alv1 WITH KEY sel = 'X'.
  IF sy-subrc = 0.

    PERFORM lock_check USING gt_alv1-tknum.

    SET PARAMETER ID 'TNR' FIELD gt_alv1-tknum.
    CALL TRANSACTION 'VT02N' AND SKIP FIRST SCREEN.
  ENDIF.

ENDFORM.                    " save_reverse_tknum1
*&---------------------------------------------------------------------*
*&      Form  SAVE_REVERSE_VBELN1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_reverse_vbeln1 .

  PERFORM ship2.

ENDFORM.                    " SAVE_REVERSE_VBELN1
*&---------------------------------------------------------------------*
*&      Form  lock_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_TAB1_VBELN  text
*----------------------------------------------------------------------*
FORM lock_check  USING    p_tknum.

  CALL FUNCTION 'ENQUEUE_EVVTTKE'
    EXPORTING
      tknum          = p_tknum
    EXCEPTIONS
      foreign_lock   = 2
      system_failure = 3.
  CASE sy-subrc.
    WHEN 0.
      PERFORM dequeue_lock USING p_tknum.
    WHEN 2.
      DATA: lv_msgcode(100).
      CONCATENATE '선적문서' p_tknum '사용자' sy-msgv1
       '현재 처리중입니다' INTO lv_msgcode SEPARATED BY space.
      PERFORM dequeue_rock USING p_tknum.
      MESSAGE s001 WITH lv_msgcode.
      LEAVE SCREEN.
    WHEN OTHERS.
      PERFORM dequeue_rock USING p_tknum.
  ENDCASE.

ENDFORM.                    " lock_check
*&---------------------------------------------------------------------*
*&      Form  dequeue_lock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TKNUM  text
*----------------------------------------------------------------------*
FORM dequeue_lock  USING    p_tknum.

  CALL FUNCTION 'DEQUEUE_EVVTTKE'
    EXPORTING
      tknum = p_tknum.
*    EXCEPTIONS
*      foreign_lock   = 2
*      system_failure = 3.

ENDFORM.                    " dequeue_lock
*&---------------------------------------------------------------------*
*&      Form  call_transaction_va03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_transaction_va03 .

  READ TABLE gt_alv1 INDEX gv_index.
  IF sy-subrc = 0.
    IF gt_alv1-vgbel IS NOT INITIAL.
      IF gt_alv1-lfart = 'NL'.

        SET PARAMETER ID 'BES' FIELD gt_alv1-vgbel.
        CALL TRANSACTION 'ME23N'.

      ELSE.
        SET PARAMETER ID 'AUN' FIELD gt_alv1-vgbel.
        CALL TRANSACTION 'VA03'
                      AND SKIP  FIRST SCREEN.

      ENDIF.
*    SET PARAMETER ID 'VG' FIELD gt_alv1-vgbel.
*    CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.


ENDFORM.                    " call_transaction_va03
*&---------------------------------------------------------------------*
*&      Form  f4_value_pernr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM f4_value_pernr .
*
*  DATA: BEGIN OF pov_pernr OCCURS 0,
*          pernr     LIKE ZZPA0001-pernr,
*          ename(30),
*          lifnr     TYPE lifnr,
*        END OF pov_pernr.
*
*  REFRESH: pov_pernr.
*
**-> CCM : 12.06.2023 10:09:29 / ZLSGSD3
*  SELECT b~lifnr
*         c~name1 AS ename
*    INTO CORRESPONDING FIELDS OF TABLE pov_pernr
*    FROM knvv AS a INNER JOIN knvp AS b
*                           ON a~kunnr EQ b~kunnr
*                          AND a~vkorg EQ b~vkorg
*                          AND a~vtweg EQ b~vtweg
*                          AND a~spart EQ b~spart
*                   INNER JOIN lfa1 AS c
*                           ON b~lifnr EQ c~lifnr
*  WHERE b~parvw EQ c_par_pe.
*
*
**  SELECT P~PERNR A~ENAME
**    INTO CORRESPONDING FIELDS OF TABLE POV_PERNR
**    FROM KNVV AS V INNER JOIN KNVP AS P
**      ON V~KUNNR = P~KUNNR AND
**         V~VKORG = P~VKORG AND
**         V~VTWEG = P~VTWEG AND
**         V~SPART = P~SPART
**        INNER JOIN ZZPA0001 AS A
**         ON P~PERNR = A~PERNR
***        INNER JOIN t001w AS w
***         ON w~vkorg = p~vkorg AND
***            w~vtweg = p~vtweg AND
***            w~spart = p~spart
**   WHERE P~PARVW = C_PAR_PE
**     AND A~BEGDA <= SY-DATUM
**     AND A~ENDDA >  SY-DATUM.
***     AND v~spart IN s_spart.
***     AND w~werks IN s_werks.
**<-
*
*
*  SORT pov_pernr.
*  DELETE ADJACENT DUPLICATES FROM pov_pernr.
*
*  fieldtab-tabname   = 'ZZPA0001'.
*  fieldtab-fieldname = 'PERNR'.
*  fieldtab-selectflag = ' '.
*  APPEND fieldtab.
*
*  fieldtab-tabname   = 'ZZPA0001'.
*  fieldtab-fieldname = 'Ename'.
*  fieldtab-selectflag = ' '.
*  APPEND fieldtab.
*
*  LOOP AT pov_pernr.
*
**-> CCM : 12.06.2023 10:14:40 / ZLSGSD3
*    REPLACE ALL OCCURRENCES OF PCRE '\D' IN pov_pernr-lifnr WITH ''.
*    CONDENSE pov_pernr-lifnr NO-GAPS.
*    pov_pernr-pernr = pov_pernr-lifnr.
**<-
*
*    valuetab-value = pov_pernr-pernr.
*    APPEND valuetab.
*    valuetab-value = pov_pernr-ename.
*    APPEND valuetab.
*  ENDLOOP.
*
*  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE_EXT'
*    EXPORTING
*      display       = ' '
**     fieldname     = 'NAME1'
*    IMPORTING
*      index         = j
*    TABLES
*      fields        = fieldtab
*      select_values = i_help_vtab
*      valuetab      = valuetab.
*
*  IF j > 0.
*    READ TABLE pov_pernr INDEX j.
**    VALUE   = POV_PERNR-PERNR.
*    s_pernr-low = pov_pernr-pernr.
*  ENDIF.
*  REFRESH : fieldtab, valuetab, pov_pernr.
*  CLEAR: j,fieldtab, valuetab, pov_pernr.
*
*ENDFORM.                    " f4_value_pernr
*&---------------------------------------------------------------------*
*&      Form  data_process
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM data_process .

  DATA: lv_arktx(40).

  REFRESH: lv_tvkbt, lv_tvgrt.
  CLEAR: lv_tvkbt, lv_tvgrt.
* 영업팀
  SELECT * INTO TABLE lv_tvkbt FROM tvkbt
            FOR ALL ENTRIES IN gt_alv1
          WHERE spras EQ sy-langu
  AND vkbur EQ gt_alv1-vkbur.
* 영업그룹
  SELECT * INTO TABLE lv_tvgrt FROM tvgrt
            FOR ALL ENTRIES IN gt_alv1
          WHERE spras EQ sy-langu
  AND vkgrp EQ gt_alv1-vkgrp.

  LOOP AT gt_alv1.
    PERFORM get_sto_etc_info.
*   영업팀
    READ TABLE lv_tvkbt WITH KEY spras = sy-langu
                                 vkbur = gt_alv1-vkbur.
    IF sy-subrc = 0.
      gt_alv1-vkbur_t = lv_tvkbt-bezei.
    ENDIF.
*   영업그룹
    READ TABLE lv_tvgrt WITH KEY spras = sy-langu
                                 vkgrp = gt_alv1-vkgrp.
    IF sy-subrc = 0.
      gt_alv1-vkgrp_t = lv_tvgrt-bezei.
    ENDIF.

    MODIFY gt_alv1. CLEAR: gt_alv1.
  ENDLOOP.

ENDFORM.                    " data_process
*&---------------------------------------------------------------------*
*&      Form  get_sto_etc_info
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_sto_etc_info .

*유통경로명
  PERFORM get_vtweg_text   USING gt_alv1-vtweg
                        CHANGING gt_alv1-vtweg_t.
**영업사원
  PERFORM get_pernr_text   USING gt_alv1-pernr
                        CHANGING gt_alv1-ename.

ENDFORM.                    " get_sto_etc_info
*&---------------------------------------------------------------------*
*&      Form  get_pernr_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_PERNR  text
*      <--P_GT_ALV1_ENAME  text
*----------------------------------------------------------------------*
FORM get_pernr_text  USING    p_pernr
                     CHANGING p_name.
  SELECT SINGLE ename INTO p_name
     FROM zzpa0001
   WHERE pernr = p_pernr
     AND begda <= sy-datum
  AND endda >  sy-datum.

ENDFORM.                    " get_pernr_text
*&---------------------------------------------------------------------*
*&      Form  get_vtweg_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ALV1_VTWEG  text
*      <--P_GT_ALV1_VTWEG_T  text
*----------------------------------------------------------------------*
FORM get_vtweg_text  USING    p_vtweg
                     CHANGING p_name.

  SELECT SINGLE vtext INTO p_name
    FROM tvtwt
   WHERE spras = sy-langu
  AND vtweg = p_vtweg.

ENDFORM.                    " get_vtweg_text
*&---------------------------------------------------------------------*
*&      Form  GET_TOTAL_brgew
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_total_brgew .

  DATA: pt_alv2 LIKE gt_alv2 OCCURS 0 WITH HEADER LINE.
  DATA: lv_packag   TYPE atwrt.
  DATA: lv_tot_brgew LIKE gt_alv2-tbrgew .

  CLEAR: lv_tot_brgew.

  LOOP AT gt_alv1 WHERE sel = 'X'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE pt_alv2
       FROM lips
    WHERE vbeln = gt_alv1-vbeln.

    DELETE pt_alv2 WHERE charg <> ' '
                     AND pstyv = 'TAL'.

    LOOP  AT pt_alv2.
      CLEAR: lv_packag, gv_brgew1, gv_tbrgew, mara.

* [START] CSR NO : C20080801_08252

      IF pt_alv2-kokrs = '2000'.
*/ 포장목 구분
        SELECT SINGLE zwdty
          INTO pt_alv2-zwdty
          FROM vbap
         WHERE vbeln = pt_alv2-vgbel
        AND posnr = pt_alv2-vgpos.

*/ BATCH 포장재
        CALL FUNCTION 'ZQC01_BATCH_VALUES_READ'
          EXPORTING
            i_val_matnr  = pt_alv2-matnr
            i_val_werks  = pt_alv2-werks
            i_val_charge = pt_alv2-charg
            i_date       = sy-datum
          TABLES
            t_val_tab    = lt_vali
            t_att_tab    = lt_attr
          EXCEPTIONS
            no_class     = 1
            OTHERS       = 2.

        READ TABLE lt_vali WITH KEY atnam = so_packaging.
        IF sy-subrc = 0.
          lv_packag = lt_vali-atwrt.
          pt_alv2-packag = lv_packag.
        ENDIF.
      ELSE.
        PERFORM get_batch_characteristic
            USING: pt_alv2-matnr pt_alv2-charg
                   'SAP_MILLCA_PACKAGING'
         CHANGING: lv_packag.
        pt_alv2-packag = lv_packag.
      ENDIF.
* [END]   CSR NO : C20080801_08252

*/ 포장규격
      IF pt_alv2-charg <> ' '. "배치가 있을때
        IF NOT pt_alv2-packag IS INITIAL.
*  포장재가 있다면..LIPS-brgew + MARA-BRGEW
*  만약, 단위가 'KG' 아니면, 모두 KG 환산하여 합산
          PERFORM convert_alpha_input USING pt_alv2-packag.
* About Lips
          IF pt_alv2-gewei <> 'KG'.
            PERFORM conversion_meins USING pt_alv2-matnr
                                           pt_alv2-gewei
                                           'KG'
                                           pt_alv2-brgew.
            gv_brgew1 = pt_alv2-brgew.
          ELSE.
            gv_brgew1 = pt_alv2-brgew.
          ENDIF.
* [START] CSR NO : C20080801_08252
          DATA : lv_volum LIKE mara-volum,
                 lv_groes LIKE mara-groes,
                 lv_brgew LIKE vbap-brgew.
          CLEAR : lv_brgew.

          IF pt_alv2-kokrs = '2000'.
            CALL FUNCTION 'Z_LE_PK_WD_COMPUTE_JS'
              EXPORTING
                i_matnr      = pt_alv2-packag
                i_pk_wd_type = pt_alv2-zwdty
              IMPORTING
                e_brgew      = lv_brgew
                e_volum      = lv_volum
                e_groes      = lv_groes.

            IF sy-subrc = 0.
              gv_brgew2 = lv_brgew.
              pt_alv2-tbrgew = gv_brgew1 + gv_brgew2.

*              pt_alv2-tvolum = lv_volum.                   "총부피
*              pt_alv2-groes  = lv_groes.                   "단위포장
            ENDIF.
          ELSE.
* [END]   CSR NO : C20080801_08252
* About Mara
            SELECT SINGLE brgew volum groes gewei mtart FROM mara
           INTO (mara-brgew,mara-volum,mara-groes,mara-gewei,mara-mtart )
            WHERE matnr = pt_alv2-packag.

            IF mara-gewei <> 'KG'.
              PERFORM conversion_meins USING pt_alv2-packag
                                             mara-gewei
                                             'KG'
                                             mara-brgew.
              gv_brgew2 = mara-brgew.
            ELSE.
              gv_brgew2 = mara-brgew.
            ENDIF.
            pt_alv2-tbrgew = gv_brgew1 + gv_brgew2.
          ENDIF.
        ELSE.
* 포장재가 없다면...lips-brgew
* 중량합계 표시 수정 060407  start
          PERFORM call_func_packg
            USING: pt_alv2-matnr pt_alv2-lfimg
         CHANGING: pt_alv2-packag.

*          IF pt_alv2-gewei <> 'KG'.
*            PERFORM conversion_meins USING pt_alv2-matnr
*                                           pt_alv2-gewei
*                                           'KG'
*                                           pt_alv2-brgew.
*            gv_brgew1 = pt_alv2-brgew.
*          ELSE.
*            gv_brgew1 = pt_alv2-brgew.
*          ENDIF.
*          pt_alv2-tbrgew = gv_brgew1.    기존꺼 막기

*  만약, 단위가 'KG' 아니면, 모두 KG 환산하여 합산
          PERFORM convert_alpha_input USING pt_alv2-packag.
* About Lips
          IF pt_alv2-gewei <> 'KG'.
            PERFORM conversion_meins USING pt_alv2-matnr
                                           pt_alv2-gewei
                                           'KG'
                                           pt_alv2-brgew.
            gv_brgew1 = pt_alv2-brgew.
          ELSE.
            gv_brgew1 = pt_alv2-brgew.
          ENDIF.
* About Mara
          SELECT SINGLE brgew volum groes gewei mtart FROM mara
          INTO (mara-brgew,mara-volum,mara-groes,mara-gewei,mara-mtart )
          WHERE matnr = pt_alv2-packag.

          IF mara-gewei <> 'KG'.
            PERFORM conversion_meins USING pt_alv2-packag
                                           mara-gewei
                                           'KG'
                                           mara-brgew.
            gv_brgew2 = mara-brgew.
          ELSE.
            gv_brgew2 = mara-brgew.
          ENDIF.
          pt_alv2-tbrgew = gv_brgew1 + gv_brgew2.
* 중량합계 표시 수정 060407  end
        ENDIF.
      ELSE.                     "배치가 없을때
        IF pt_alv2-gewei <> 'KG'.
          PERFORM conversion_meins USING pt_alv2-matnr
                                         pt_alv2-gewei
                                         'KG'
                                         pt_alv2-brgew.
          gv_brgew1 = pt_alv2-brgew.
        ELSE.
          gv_brgew1 = pt_alv2-brgew.
        ENDIF.
        pt_alv2-tbrgew = gv_brgew1.

      ENDIF.

      ADD pt_alv2-tbrgew TO gv_tbrgew .
      MODIFY pt_alv2.
    ENDLOOP.

* 총중량/부피 합계:
* if, 상위품목만 있으면, 현재 구한 상위품목의 값을 그대로...
* if, 하위품목(배치)이 있으면, 하위품목의 값 합계를 상위품목에...
    LOOP AT pt_alv2 WHERE  uecha = '000000'
                      AND charg = ' '.
      CLEAR:gv_tbrgew.
      LOOP AT pt_alv2 WHERE uecha = pt_alv2-posnr.
        ADD pt_alv2-tbrgew TO gv_tbrgew  .
      ENDLOOP.
      IF sy-subrc = 0.
        pt_alv2-tbrgew = gv_tbrgew  .
      ENDIF.
      MODIFY pt_alv2 TRANSPORTING tbrgew.
    ENDLOOP.

    LOOP AT pt_alv2 WHERE  uecha = '000000'.
      ADD pt_alv2-tbrgew TO lv_tot_brgew.
    ENDLOOP.
  ENDLOOP.

  DATA: lv_cnt TYPE i.
  DESCRIBE TABLE gt_tab1 LINES lv_cnt.

  DATA: lv_cnt_c(15).
  lv_cnt_c = lv_cnt.
  SHIFT lv_cnt_c LEFT DELETING LEADING space.

  DATA: lv_tot_brgew_c(20).
  lv_tot_brgew_c = lv_tot_brgew.
  SHIFT lv_tot_brgew_c LEFT DELETING LEADING space.

  CONCATENATE '선택:' lv_cnt_c
   '개의 납품, 선택하신 납품의 총중량은 '
   lv_tot_brgew_c ' kg 입니다' INTO wa-msg.


ENDFORM.                    " GET_TOTAL_brgew
*&---------------------------------------------------------------------*
*&      Form  call_transaction_VT03N
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_transaction_vt03n .

  READ TABLE gt_alv1 INDEX gv_index.
  IF sy-subrc = 0.
    IF gt_alv1-tknum_sea IS NOT INITIAL.
      SET PARAMETER ID 'TNR' FIELD gt_alv1-tknum_sea.
      CALL TRANSACTION 'VT03N' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.

ENDFORM.                    " call_transaction_VT03N
*&---------------------------------------------------------------------*
*&      Form  selection_screen_modify
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM selection_screen_modify .

*  IF SY-TCODE = 'ZLE0107T'.
*
*    LOOP AT SCREEN.
*      CASE SCREEN-NAME.
*        WHEN 'P_ZPASS' .
*          SCREEN-INVISIBLE = '1'.
*      ENDCASE.
*      MODIFY SCREEN.
*    ENDLOOP.
*
*  ELSE.

  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'I_SUBNR-LOW' OR
           '%F001002_1000' OR
           '%_I_SUBNR_%_APP_%-OPTI_PUSH' OR
           'P_ZPASS' OR
           '%F002005_1000'.
        screen-active = 0.

      WHEN 'R03'. "20210126 추가
        IF gf_request IS INITIAL.
          screen-active = 0.
        ENDIF.

        "임시
      WHEN 'R10'.
        screen-active = 0.

    ENDCASE.

*[S] 안정화    GW20260827001
     IF  R01 = 'X' .
        IF screen-name = 'S_TKNUM-LOW' OR
             screen-name = 'S_TKNUM-HIGH'.
             screen-input = 0.
        ENDIF.
     ENDIF.
*[E] 안정화    GW20260827001

    MODIFY SCREEN.
  ENDLOOP.

*  ENDIF.

ENDFORM.                    " selection_screen_modify
*&---------------------------------------------------------------------*
*&      Form  check_input_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_input_field .

  IF NOT i_subnr-low IS INITIAL .
    SELECT SINGLE mandt INTO sy-mandt FROM zlet0029
      WHERE tdlnr = i_subnr-low
    AND zpass = p_zpass.
    IF sy-subrc <> 0.
      MESSAGE e000 WITH '비밀번호가 틀립니다'.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_input_field
*&---------------------------------------------------------------------*
*&      Form  i_wadat_setting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM s_erdat_setting .

* 당월 첫째날과 당일 Setting
  s_erdat-sign     = 'I'.
  s_erdat-option   = 'EQ'.
*  s_erdat-low+0(6) = sy-datum+0(6).
*  s_erdat-low+6(2) = '01'.
  s_erdat-low      = sy-datum - 1 .
  s_erdat-high     = sy-datum.
  APPEND s_erdat.

ENDFORM.                    " i_wadat_setting
*&---------------------------------------------------------------------*
*&      Form  call_func_packg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_ALV2_MATNR  text
*----------------------------------------------------------------------*
FORM call_func_packg  USING    p_matnr
                               p_lfimg
                      CHANGING e_atwrt.

*  lv_jojang    = pt_alv2-lfimg.
*  lv_jojang_su = gt_list-factor.

* [START] CSR NO : C20070806_11585

  DATA: lv_bzarea LIKE zlet0033-bzarea,
        lv_zdrum  LIKE vbap-zdrum.

* 제품특성
  DATA : gt_char LIKE zles001 OCCURS 0 WITH HEADER LINE.

  SELECT SINGLE bzarea
    INTO lv_bzarea
    FROM zlet0033
  WHERE vstel IN s_vstel.

  lv_bzarea = lv_bzarea+0(1).

  SELECT SINGLE zdrum
    INTO lv_zdrum
    FROM vbap
   WHERE vbeln = gt_alv1-vgbel
  AND posnr = gt_alv1-vgpos.

  IF lv_bzarea = 'J'.

* [START] CSR NO : C20071004_45423
* 배차대상 납품문서에 대한 총중량 정보 계산 로직 변경
* 변경전 : 해당납품 품목의 선행 주문문서에 대하여
*      포장재중량 계산시 설계포장재 지정로직으로 포장재 산출
* 변경후 : 해당납품 품목의 선행 주문문서에 대하여
*      포장재중량 계산시 주문문서에 지정된 포장재 마스터의 중량으로 계산
    CLEAR : gt_char, gt_char[], gt_alv1-werks.

    SELECT SINGLE werks INTO gt_alv1-werks
    FROM   vbap
    WHERE  vbeln = gt_alv1-vgbel
    AND    posnr = gt_alv1-vgpos.

    PERFORM get_characteristic(zler0001) TABLES gt_char
                                         USING  gt_alv1-vgbel
                                                gt_alv1-vgpos
                                                gt_alv1-werks
                                                p_matnr.
    IF gt_char[] IS NOT INITIAL.

      READ TABLE gt_char WITH KEY atnam = 'SAP_MILLCA_PACKAGING'.
      IF sy-subrc = 0.
        e_atwrt = gt_char-atwrt.
      ENDIF.
    ENDIF.
* [END]   CSR NO : C20071004_45423



*    call function 'Z_ED_AUTO_DRUM_SELECT_JS'
*      exporting
*        i_matnr              = p_matnr
*        i_jojang             = p_lfimg
*        i_jojang_su          = 1
*        i_kunnr              = gt_alv1-kunnr
*        i_zdrum              = lv_zdrum
**   I_VBELN              =
**   I_POSNR              =
**   I_NO_POPUP           =
**   I_USER_ZEDS057       =
*     importing
*       e_matnr              = e_atwrt.
**   E_AUTO_FLAG          =
**   ES_ZEDS057           =
**   ES_ZEDS071           =
**   ES_ZEDS072           =
** TABLES
**   IT_DM_CHA            =
**   IT_BX_CHA            =
**   IT_PL_CHA            =

  ELSE.

* [END]   CSR NO : C20070806_11585

    CALL FUNCTION 'Z_ED_AUTO_DRUM_SELECT'
      EXPORTING
        i_matnr     = p_matnr
        i_jojang    = p_lfimg
        i_jojang_su = 1
*       I_VBELN     =
*       I_POSNR     =
*       I_NO_POPUP  =
*       I_USER_ZEDS057       =
      IMPORTING
        e_matnr     = e_atwrt.
*   E_AUTO_FLAG          =
*   ES_ZEDS057           =
*   ES_ZEDS071           =
*   ES_ZEDS072           =
* TABLES
*   IT_DM_CHA            =
*   IT_BX_CHA            =
*   IT_PL_CHA            =

* [START] CSR NO : C20070806_11585
  ENDIF.
* [END] CSR NO : C20070806_11585

ENDFORM.                    " call_func_packg
*&---------------------------------------------------------------------*
*&      Form  authority_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM authority_check .
  DATA: gt_tvst  LIKE tvst OCCURS 0 WITH HEADER LINE,
        lv_subrc LIKE sy-subrc.

  SELECT *
    INTO TABLE gt_tvst
    FROM tvst
  WHERE vstel IN s_vstel.

  LOOP  AT  gt_tvst.
    CLEAR : lv_subrc.
    CALL FUNCTION 'ZGTLE_AUTHORIZATION_CHECK'  "'Z_LE_AUTHORIZATION_CHECK'
      EXPORTING
        i_vstel = gt_tvst-vstel
        i_type  = '3'
      IMPORTING
        e_subrc = lv_subrc.

    IF lv_subrc <> 0.
      MESSAGE e002 WITH '출하지점에 대한 권한이 없읍니다'
                        gt_tvst-vstel.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " authority_check

*&---------------------------------------------------------------------*
*& Form f4_value_lifnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_value_lifnr .

  SELECT
    lifnr,
    name1
    FROM lfa1
    WHERE lifnr LIKE 'E%'
    ORDER BY lifnr
    INTO TABLE @DATA(lt_lfa1).

  fieldtab-tabname   = 'LFA1'.
  fieldtab-fieldname = 'LIFNR'.
  fieldtab-selectflag = ' '.
  APPEND fieldtab.

  fieldtab-tabname   = 'LFA1'.
  fieldtab-fieldname = 'NAME1'.
  fieldtab-selectflag = ' '.
  APPEND fieldtab.

  LOOP AT lt_lfa1 ASSIGNING FIELD-SYMBOL(<ls_lfa1>).
    valuetab-value = <ls_lfa1>-lifnr.
    APPEND valuetab.
    valuetab-value = <ls_lfa1>-name1.
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
    READ TABLE lt_lfa1 ASSIGNING FIELD-SYMBOL(<ls_lfa1_v>) INDEX j.
*    VALUE   = POV_PERNR-PERNR.
    s_lifnr-low = <ls_lfa1_v>-lifnr.
  ENDIF.
  REFRESH : fieldtab, valuetab.
  CLEAR: j,fieldtab, valuetab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_lgort .
  APPEND VALUE #( sign = 'I' option = 'EQ' low = gc_lgort_3410 )
      TO s_lgort.
  APPEND VALUE #( sign = 'I' option = 'EQ' low = gc_lgort_3420 )
      TO s_lgort.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VSTEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_vstel  USING  pv_fname.

  SELECT DISTINCT b~vstel,c~vtext
    FROM tvkwz AS a INNER JOIN tvswz AS b
                    ON a~werks = b~werks
                    INNER JOIN tvstt AS c
                    ON b~vstel = c~vstel AND
                       c~spras = @sy-langu
   WHERE a~vkorg EQ @gc_vkorg_6000
    INTO TABLE @DATA(lt_value).
  SORT lt_value BY vstel.
  CHECK lt_value[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VSTEL'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fname
      value_org       = 'S'
    TABLES
      value_tab       = lt_value
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_LGORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_lgort  USING    pv_fname.

  SELECT DISTINCT a~werks,b~name1,c~lgort,c~lgobe
    FROM tvkwz AS a INNER JOIN t001w AS b
                    ON a~werks = b~werks
                    INNER JOIN t001l AS c
                    ON b~werks = c~werks
   WHERE a~vkorg EQ @gc_vkorg_6000
    INTO TABLE @DATA(lt_value).
  SORT lt_value BY werks.
  CHECK lt_value[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'LGORT'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fname
      value_org       = 'S'
    TABLES
      value_tab       = lt_value
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VTWEG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_vtweg  USING    pv_fname.

  SELECT a~vkorg,a~vtweg,b~vtext
    FROM tvkov AS a INNER JOIN tvtwt AS b
                    ON a~vtweg = b~vtweg AND
                       b~spras = @sy-langu
   WHERE a~vkorg EQ @gc_vkorg_6000
    INTO TABLE @DATA(lt_value).
  SORT lt_value BY vkorg vtweg.
  CHECK lt_value[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VTWEG'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fname
      value_org       = 'S'
    TABLES
      value_tab       = lt_value
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKBUR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_vkbur  USING    pv_fname.

  SELECT DISTINCT a~vkbur,b~bezei
    FROM tvkbz AS a INNER JOIN tvkbt AS b
                    ON a~vkbur = b~vkbur

   WHERE a~vkorg EQ @gc_vkorg_6000
    INTO TABLE @DATA(lt_value).
  SORT lt_value BY vkbur.
  CHECK lt_value[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VKBUR'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fname
      value_org       = 'S'
    TABLES
      value_tab       = lt_value
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_vkgrp  USING    pv_fname.
  RANGES: lr_vkbur FOR vbak-vkbur.

  lr_vkbur[] = CORRESPONDING #( s_vkbur[] ).

  SELECT DISTINCT a~vkbur,b~bezei,a~vkgrp,c~bezei AS vkgrp_txt
    FROM tvkbz AS h INNER JOIN tvbvk AS a
                    ON h~vkbur = a~vkbur
                    INNER JOIN tvkbt AS b
                    ON a~vkbur = b~vkbur AND
                       b~spras = @sy-langu
                    INNER JOIN tvgrt AS c
                    ON a~vkgrp = c~vkgrp AND
                       c~spras = @sy-langu
   WHERE h~vkorg EQ @gc_vkorg_6000
     AND a~vkbur IN @lr_vkbur
    INTO TABLE @DATA(lt_value).

  SORT lt_value BY vkbur.

  CHECK lt_value[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VKGRP'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fname
      value_org       = 'S'
    TABLES
      value_tab       = lt_value
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TOTAL_WEIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PT_ALV2
*&---------------------------------------------------------------------*
FORM get_total_weight  CHANGING ps_alv2 LIKE gt_alv2.
  DATA : lv_menge    TYPE lips-lfimg,
         lv_indqty   TYPE zlet0401-indqty,
         lv_ntgew_dr TYPE mara-ntgew,
         lv_ntgew_mm TYPE mara-ntgew.

*  CHECK PS_ALV2-DR_WEIGHT IS NOT INITIAL.
*  CHECK PS_ALV2-NTGEW NE 0.

  "제품중량
  lv_ntgew_mm = ps_alv2-ntgew.

*-총중량(드럼포함) : 드럼무게/개 * 조장수 + 제품중량
  ps_alv2-brgew_dr = ps_alv2-dr_weight * ps_alv2-factor + lv_ntgew_mm.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DRUM_WEIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PT_ALV2
*&---------------------------------------------------------------------*
FORM get_drum_weight  CHANGING ps_alv2 LIKE gt_alv2.
  DATA: lv_ntgew_dr TYPE mara-ntgew.

  CHECK ps_alv2-packag IS NOT INITIAL.

  SELECT SINGLE matnr,ntgew,gewei
    FROM mara
   WHERE matnr EQ @ps_alv2-packag
    INTO @DATA(ls_mara).
  CHECK sy-subrc EQ 0.

  lv_ntgew_dr = ls_mara-ntgew.
  IF ls_mara-gewei NE gc_meins_kg.
    lv_ntgew_dr = zgtsd_cl_common2=>md_convert_material_unit( iv_matnr = ls_mara-matnr
                                                              iv_in_me = ls_mara-gewei
                                                              iv_ot_me = gc_meins_kg
                                                              iv_menge = lv_ntgew_dr  ).
  ENDIF.

  ps_alv2-dr_weight = lv_ntgew_dr.
  ps_alv2-meins_kg  = gc_meins_kg.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GT_LVC2
*&---------------------------------------------------------------------*
FORM create_fieldcat  USING   p_tabname
                               pt_fieldcat TYPE lvc_t_fcat.
  DATA : lt_fcat TYPE slis_t_fieldcat_alv WITH HEADER LINE.
  DATA : lv_internal_tabname TYPE  slis_tabname,
         lv_structure_name   LIKE  dd02l-tabname,
         lv_inclname         LIKE  trdir-name.

  DATA : lv_table TYPE feld-name.
  FIELD-SYMBOLS <fs_table> TYPE STANDARD TABLE.

  CONCATENATE p_tabname '[]' INTO lv_table.
  ASSIGN (lv_table) TO <fs_table>.

  CLEAR : lv_internal_tabname, lv_inclname.
  lv_internal_tabname = p_tabname.      " 인터널 데이블
  lv_inclname         = |{ sy-repid }TOP|.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = sy-repid
      i_internal_tabname = lv_internal_tabname
      i_inclname         = lv_inclname
      i_bypassing_buffer = 'X'
*     I_STRUCTURE_NAME   = I_INTERNAL_TABNAME
    CHANGING
      ct_fieldcat        = lt_fcat[].

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat[]
    IMPORTING
      et_fieldcat_lvc = pt_fieldcat[]
    TABLES
      it_data         = <fs_table>.

  CALL FUNCTION 'LVC_FIELDCAT_COMPLETE'
    EXPORTING
      i_refresh_buffer = 'X'
    CHANGING
      ct_fieldcat      = pt_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_FIELD_CATALOGS_2_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM fill_field_catalogs_2_new  USING    p_gub  p_fname  p_value.


*- 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*- 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점

  IF p_gub = 'S'.

    CLEAR gs_lvc2.
    gs_lvc2-fieldname = p_value.
    EXIT.
  ENDIF.

*- 출력될 Field 속성을 정의해서 필드 카타로그 테이블에 저장
  DATA l_fname(40).
  FIELD-SYMBOLS <fs> TYPE any.

*  CONCATENATE 'GS_LVC2-' P_FNAME INTO L_FNAME.

  READ TABLE gt_lvc2 ASSIGNING FIELD-SYMBOL(<fs_lvc>) WITH KEY fieldname = gs_lvc2-fieldname.
  CHECK sy-subrc EQ 0.
  ASSIGN COMPONENT p_fname OF STRUCTURE <fs_lvc> TO <fs>.
  CHECK sy-subrc EQ 0.
  <fs> = p_value.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CBM_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PT_ALV2
*&---------------------------------------------------------------------*
FORM get_cbm_data  CHANGING ps_alv2 LIKE gt_alv2.
  DATA: lt_tab TYPE TABLE OF zgtedsif0034.

  APPEND VALUE #( vbeln = ps_alv2-vgbel
                  posnr = ps_alv2-vgpos
                 ) TO lt_tab.

  CALL FUNCTION 'ZGTED_SELECT_CBM_DATA'
    TABLES
      ot_output = lt_tab.

  DATA(ls_tab) = VALUE #( lt_tab[ 1 ] OPTIONAL ).

  CHECK ls_tab-msg_type NE 'E'.

  "폭/드럼
  ps_alv2-out_wid = ls_tab-out_wid.

  "약경/드럼
  ps_alv2-plan_dia = ls_tab-barrel_dia.

  "드럼무게/개
  ps_alv2-dr_weight = ls_tab-brgew.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OPTION_GRID9
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_option_grid9 .
  gs_layout9-sel_mode   = 'D'.
*  GS_LAYOUT3-NO_ROWMARK = 'X'.
  gs_layout9-zebra      = ' '.
*  GS_LAYOUT3-STYLEFNAME      = 'CELLTAB'.
  gs_layout9-cwidth_opt = 'X'.
*  GS_LAYOUT-CTAB_FNAME = 'ALV_COL'.

* 2. EXCLUDING MENU
  CLEAR :   gt_tbar_excluding1[].
  APPEND : '&REFRESH'             TO gt_tbar_excluding9,
           '&LOCAL&CUT'           TO gt_tbar_excluding9,
           '&LOCAL&COPY'          TO gt_tbar_excluding9,
           '&LOCAL&PASTE'         TO gt_tbar_excluding9,
           '&LOCAL&PASTE_NEW_ROW' TO gt_tbar_excluding9,
           '&LOCAL&UNDO'          TO gt_tbar_excluding9,
           '&LOCAL&APPEND'        TO gt_tbar_excluding9,
           '&LOCAL&INSERT_ROW'    TO gt_tbar_excluding9,
           '&LOCAL&DELETE_ROW'    TO gt_tbar_excluding9,
           '&LOCAL&COPY_ROW'      TO gt_tbar_excluding9,
           '&DETAIL'              TO gt_tbar_excluding9.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELD_CATALOGS_GRID9
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_field_catalogs_grid9 .
  CLEAR   : gs_lvc9, gv_pos.
  REFRESH : gt_lvc9.

  gv_itab = 'GT_STOCK'.

*___필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
*___TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
  PERFORM make_lvc_fieldcat_data TABLES gt_lvc9
                                  USING :

      'WERKS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      ' '            'WERKS'  'VBAP'      ' ' ' '    'X' ' ' ' ' ' ',

      'WERKS_TX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '플랜트명'     'NAME1'  'T001W'     ' ' ' '    'X' ' ' ' ' ' ',

      'LGORT'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 4
      '저장위치'     'LGORT'  'VBAP'      ' ' ' '    'X' ' ' ' ' ' ',

       'LGORT_TX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 30
      '저장위치명'     'LGOBE'  'T001L'     ' ' ' '    'X' ' ' ' ' ' ',

      'KUNNR_TX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 35
      '거래처명'     'NAME1'  'ADRC'      ' ' ' '    'X' ' ' ' ' ' ',

      'VBELN'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 10
      'SO번호'            'VBELN'  'VBAP'  ' ' ' '    'X' ' ' ' ' ' ',

      'POSNR'    ' '      ' '     ' ' ' ' ' ' ' '    'X' ' ' ' ' 6
      'SO항번'            'POSNR'  'VBAP'  ' ' ' '    'X' ' ' ' ' ' ',

      'MATNR'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 18
      ' '            'MATNR'  'MARA'  ' ' ' '    'X' ' ' ' ' ' ',

      'MATNR_TX'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' ' ' ' ' 40
      ' '            'MAKTX'  'MAKT'      ' ' ' '    'X' ' ' ' ' ' ',

      'MENGE'    ' '      'MEINS' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 15
      '가용재고'     'CLABS'  'MCHB'  ' ' ' '    ' ' ' ' ' ' ' ',



      'LENGTH'   ' '      ' '     ' ' ' ' 'R' ' '    ' ' ' ' ' ' 10
      ' '            'INDLEN' 'ZLET0401'  ' ' ' '    'X' ' ' ' ' ' ',

      'FACTOR'   ' '     'INDMEI' ' ' ' ' 'R' ' '    ' ' ' ' ' ' 5
      ' '            'INDQTY' 'ZLET0401'  ' ' ' '    ' ' ' ' ' ' ' ',

      'MEINS'    ' '      ' '     ' ' ' ' ' ' ' '    ' ' '  ' ' ' 3
      '단위'         'MEINS'  'MARA'  ' ' ' '    'X' ' ' ' ' ' ',

      'DESC'    ' '      ' '     'X' ' ' ' ' ' '    ' ' ' ' ' ' 5
      '재고상태'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' ',

      'ZSORT'    ' '      ' '     'X' ' ' ' ' ' '    ' ' 'X' ' ' 1
      'SORT'     ' '      ' '         ' ' 'CHAR' 'X' ' ' ' ' ' '.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
* 필드명/통화/단위/ICON/CHECKBOX/JUST/EMPHA/FIX/NOOUT/NOZERO/LENG/
* TEXT/REF_FIELD/REF_TABLE/TECH/TYPE/NOSUM/DOSUM/HOT/EDIT
*----------------------------------------------------------------------*
FORM make_lvc_fieldcat_data TABLES pt_fieldcat TYPE lvc_t_fcat
                             USING pv_fname
                                   pv_curk
                                   pv_unit
                                   pv_icon
                                   pv_check
                                   pv_just
                                   pv_empha
                                   pv_fix
                                   pv_noout
                                   pv_nozero
                                   pv_length
                                   pv_text
                                   pv_reff
                                   pv_reft
                                   pv_tech
                                   pv_type
                                   pv_nosum
                                   pv_dosum
                                   pv_hotspot
                                   pv_edit.

  CLEAR : gs_lvc9.

  gv_pos = gv_pos + 1.

  gs_lvc9-col_pos        = gv_pos.
  gs_lvc9-fieldname      = pv_fname.
  gs_lvc9-cfieldname     = pv_curk.
  gs_lvc9-qfieldname     = pv_unit.
  gs_lvc9-icon           = pv_icon.
  gs_lvc9-checkbox       = pv_check.
  gs_lvc9-just           = pv_just.
  gs_lvc9-emphasize      = pv_empha.
  gs_lvc9-fix_column     = pv_fix.
  gs_lvc9-key            = pv_fix.
  gs_lvc9-no_out         = pv_noout.
  gs_lvc9-no_zero        = pv_nozero.
  gs_lvc9-outputlen      = pv_length.
  gs_lvc9-coltext        = pv_text.
  gs_lvc9-scrtext_s      = pv_text.
  gs_lvc9-scrtext_m      = pv_text.
  gs_lvc9-scrtext_l      = pv_text.
  gs_lvc9-reptext        = pv_text.
  gs_lvc9-ref_field      = pv_reff.
  gs_lvc9-ref_table      = pv_reft.
  gs_lvc9-tech           = pv_tech.
  gs_lvc9-datatype       = pv_type.
  gs_lvc9-no_sum         = pv_nosum.
  gs_lvc9-do_sum         = pv_dosum.
  gs_lvc9-hotspot        = pv_hotspot.
  gs_lvc9-edit           = pv_edit.
  gs_lvc9-colddictxt     = 'M'.

  gs_lvc9-tabname        = gv_itab.


  APPEND gs_lvc9 TO pt_fieldcat.

ENDFORM.                    " MAKE_LVC_FIELDCAT_DATA
*&---------------------------------------------------------------------*
*& Form GET_STOCK_9000
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_stock_9000 .
  CLEAR gt_stock[].

  IF line_exists( gt_alv2[ sel2 = 'X' ] ).
  ELSE.
    MESSAGE s001 WITH TEXT-m01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM get_stock_info.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STOCK_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_stock_info .
  DATA: ls_d365_login TYPE  zsds_log_0000_go,
        lv_mode       TYPE  zgtemode_stock  VALUE 'Z'.

  DATA: ls_return        TYPE  zsds_log_0001_go,
        lt_search        LIKE TABLE OF zgtsdsif0096,
        ls_search        LIKE zgtsdsif0096,
        lt_avl_item      LIKE TABLE OF zgtsdsif0098,
        lt_lstock_item   LIKE TABLE OF zgtsdsif0100,
        lt_lstock_detail LIKE TABLE OF zgtsdsif0101,
        lt_estock_item   LIKE TABLE OF zgtsdsif0102,
        lt_estock_detail LIKE TABLE OF zgtsdsif0103.

  DATA: lt_stock LIKE TABLE OF gt_stock.
  DATA: ls_stock LIKE gt_stock.

  DATA: lv_cnt TYPE i.
  DATA: lv_msg TYPE bapi_msg.


*-IT_SEARCH 구성
  LOOP AT gt_alv2 INTO DATA(ls_alv2) WHERE sel2 EQ 'X'.
    CLEAR: ls_search.
    ls_search-matnr = ls_alv2-matnr.
    ls_search-werks = ls_alv2-werks.
    ls_search-lgort = ls_alv2-lgort.

    COLLECT ls_search INTO lt_search.
  ENDLOOP.

  ls_d365_login-ename = sy-uname.

  CALL FUNCTION 'ZSD_365_0050_0040_GO'
    EXPORTING
      is_d365_login    = ls_d365_login
      i_mode           = lv_mode
    IMPORTING
      es_return        = ls_return
    TABLES
      it_search        = lt_search
      et_avl_item      = lt_avl_item
      et_lstock_item   = lt_lstock_item
      et_lstock_detail = lt_lstock_detail
      et_estock_item   = lt_estock_item
      et_estock_detail = lt_estock_detail.

  IF ls_return-mtype NE gc_s.
    lv_msg = |{ TEXT-m02 } { ls_return-message }|.
    MESSAGE i004 WITH lv_msg(50)
                      lv_msg+50(50)
                      lv_msg+100(50)
                      lv_msg+150(50)
         DISPLAY LIKE gc_e.
    EXIT.
  ENDIF.

*-01.LINK 재고
  CLEAR lt_stock[].
  LOOP AT lt_lstock_detail INTO DATA(ls_lstock_detail) WHERE lgort IN gr_lgort
                                        GROUP BY ( vbeln = ls_lstock_detail-vbeln
                                                   posnr = ls_lstock_detail-posnr
                                                   werks = ls_lstock_detail-werks
                                                   lgort = ls_lstock_detail-lgort
                                                   matnr  = ls_lstock_detail-matnr
                                                   length = ls_lstock_detail-length )
                                        ASCENDING ASSIGNING FIELD-SYMBOL(<fs_main10>).

    CLEAR: ls_stock,lv_cnt.
    LOOP AT GROUP <fs_main10> ASSIGNING FIELD-SYMBOL(<fs_line10>).
      lv_cnt = lv_cnt + 1.
      IF lv_cnt EQ 1.
        ls_stock-vbeln  = <fs_line10>-vbeln.
        ls_stock-posnr  = <fs_line10>-posnr.
        ls_stock-werks  = <fs_line10>-werks.
        ls_stock-lgort  = <fs_line10>-lgort.
        ls_stock-matnr  = <fs_line10>-matnr.
        ls_stock-length = <fs_line10>-length.
        ls_stock-meins  = <fs_line10>-vrkme.
        ls_stock-desc   = TEXT-t01.
        ls_stock-indmei = 'EA'.
        ls_stock-zsort  = gc_a.
      ENDIF.
      ls_stock-factor = ls_stock-factor + <fs_line10>-lstock.
    ENDLOOP.
    APPEND ls_stock TO lt_stock.
  ENDLOOP.

*  LOOP AT LT_LSTOCK_DETAIL INTO DATA(LS_LSTOCK_DETAIL) WHERE LGORT IN GR_LGORT.
*    CLEAR:LS_STOCK.
*    LS_STOCK-VBELN  = LS_LSTOCK_DETAIL-VBELN.
*    LS_STOCK-POSNR  = LS_LSTOCK_DETAIL-POSNR.
*    LS_STOCK-WERKS  = LS_LSTOCK_DETAIL-WERKS.
*    LS_STOCK-LGORT  = LS_LSTOCK_DETAIL-LGORT.
*    LS_STOCK-MATNR  = LS_LSTOCK_DETAIL-MATNR.
*    LS_STOCK-LENGTH = LS_LSTOCK_DETAIL-LENGTH.
*    LS_STOCK-FACTOR = LS_LSTOCK_DETAIL-LSTOCK.
*    LS_STOCK-MEINS  = LS_LSTOCK_DETAIL-VRKME.
*    LS_STOCK-DESC   = TEXT-T01.
*    LS_STOCK-INDMEI = 'EA'.
*
*    APPEND LS_STOCK TO LT_STOCK.
*  ENDLOOP.
  IF lt_stock[] IS NOT INITIAL.
    APPEND LINES OF lt_stock TO gt_stock.
  ENDIF.

*-02. 판매오더재고
  CLEAR lt_stock[].
  LOOP AT lt_estock_detail INTO DATA(ls_estock_detail) WHERE lgort IN gr_lgort
                                        GROUP BY ( vbeln = ls_estock_detail-vbeln
                                                   posnr = ls_estock_detail-posnr
                                                   werks = ls_estock_detail-werks
                                                   lgort = ls_estock_detail-lgort
                                                   matnr  = ls_estock_detail-matnr
                                                   length = ls_estock_detail-length )
                                        ASCENDING ASSIGNING FIELD-SYMBOL(<fs_main20>).
    CLEAR: ls_stock,lv_cnt.
    LOOP AT GROUP <fs_main20> ASSIGNING FIELD-SYMBOL(<fs_line20>).
      lv_cnt = lv_cnt + 1.
      IF lv_cnt EQ 1.
        ls_stock-vbeln  = <fs_line20>-vbeln.
        ls_stock-posnr  = <fs_line20>-posnr.
        ls_stock-werks  = <fs_line20>-werks.
        ls_stock-lgort  = <fs_line20>-lgort.
        ls_stock-matnr  = <fs_line20>-matnr.
        ls_stock-length = <fs_line20>-length.
        ls_stock-meins  = <fs_line20>-vrkme.
        ls_stock-desc   = TEXT-t02.
        ls_stock-indmei = 'EA'.
        ls_stock-zsort  = gc_b.
      ENDIF.
      ls_stock-factor = ls_stock-factor + <fs_line20>-estock.
    ENDLOOP.
    APPEND ls_stock TO lt_stock.
  ENDLOOP.

*  LOOP AT LT_ESTOCK_DETAIL INTO DATA(LS_ESTOCK_DETAIL) WHERE LGORT IN GR_LGORT.
*    CLEAR:LS_STOCK.
*    LS_STOCK-VBELN  = LS_ESTOCK_DETAIL-VBELN.
*    LS_STOCK-POSNR  = LS_ESTOCK_DETAIL-POSNR.
*    LS_STOCK-WERKS  = LS_ESTOCK_DETAIL-WERKS.
*    LS_STOCK-LGORT  = LS_ESTOCK_DETAIL-LGORT.
*    LS_STOCK-MATNR  = LS_ESTOCK_DETAIL-MATNR.
*    LS_STOCK-LENGTH = LS_ESTOCK_DETAIL-LENGTH.
*    LS_STOCK-FACTOR = LS_ESTOCK_DETAIL-ESTOCK.
*    LS_STOCK-MEINS  = LS_ESTOCK_DETAIL-VRKME.
*    LS_STOCK-DESC   = TEXT-T02.
*    LS_STOCK-INDMEI = 'EA'.
*
*    COLLECT LS_STOCK INTO LT_STOCK.
*  ENDLOOP.
  IF lt_stock[] IS NOT INITIAL.
    APPEND LINES OF lt_stock TO gt_stock.
  ENDIF.

*-03. 가용재고
  CLEAR lt_stock[].
  LOOP AT lt_avl_item INTO DATA(ls_avl_item) WHERE lgort IN gr_lgort.
    CLEAR:ls_stock.
    ls_stock-werks  = ls_avl_item-werks.
    ls_stock-lgort  = ls_avl_item-lgort.
    ls_stock-matnr  = ls_avl_item-matnr.
    ls_stock-length = ls_avl_item-length.
    ls_stock-factor = ls_avl_item-stock.
    ls_stock-meins  = ls_avl_item-meins.
    ls_stock-desc   = TEXT-t03.
    ls_stock-indmei = 'EA'.
    ls_stock-zsort  = gc_c.

    APPEND ls_stock TO lt_stock.
  ENDLOOP.
  IF lt_stock[] IS NOT INITIAL.
    APPEND LINES OF lt_stock TO gt_stock.
  ENDIF.

*-플랜트 명
  DATA(lt_temp) = gt_stock[].
  SORT lt_temp BY werks.
  DELETE lt_temp WHERE werks IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING werks.
  IF lt_temp[] IS NOT INITIAL.
    SELECT werks,name1
      FROM t001w
       FOR ALL ENTRIES IN @lt_temp
     WHERE werks EQ @lt_temp-werks
      INTO TABLE @DATA(lt_t001w).
    SORT lt_t001w BY werks.
  ENDIF.

*-저장위치 명
  CLEAR lt_temp[].
  lt_temp[] = CORRESPONDING #( gt_stock[] ).
  SORT lt_temp BY werks lgort.
  DELETE lt_temp WHERE werks IS INITIAL.
  DELETE lt_temp WHERE lgort IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING werks lgort.
  IF lt_temp[] IS NOT INITIAL.
    SELECT werks,lgort,lgobe
      FROM t001l
       FOR ALL ENTRIES IN @lt_temp
     WHERE werks EQ @lt_temp-werks
       AND lgort EQ @lt_temp-lgort
      INTO TABLE @DATA(lt_t001l).
    SORT lt_t001l BY werks lgort.
  ENDIF.

*-자재 명
  CLEAR lt_temp[].
  lt_temp[] = CORRESPONDING #( gt_stock[] ).
  SORT lt_temp BY matnr.
  DELETE lt_temp WHERE matnr IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING matnr.
  IF lt_temp[] IS NOT INITIAL.
    SELECT matnr,maktx
      FROM makt
       FOR ALL ENTRIES IN @lt_temp
     WHERE matnr EQ @lt_temp-matnr
       AND spras EQ @sy-langu
      INTO TABLE @DATA(lt_makt).
    SORT lt_makt BY matnr.
  ENDIF.

*-거래처명
  CLEAR lt_temp[].
  lt_temp[] = CORRESPONDING #( gt_stock[] ).
  SORT lt_temp BY vbeln.
  DELETE lt_temp WHERE vbeln IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING vbeln.
  IF lt_temp[] IS NOT INITIAL.
    SELECT a~vbeln,a~kunnr,c~name1
      FROM vbak AS a INNER JOIN kna1 AS b
                     ON a~kunnr = b~kunnr
                     INNER JOIN adrc AS c
                     ON b~adrnr  = c~addrnumber AND
                        c~nation = @space
       FOR ALL ENTRIES IN @lt_temp
     WHERE a~vbeln EQ @lt_temp-vbeln
      INTO TABLE @DATA(lt_vbak).
    SORT lt_vbak BY vbeln.
  ENDIF.

*-리스트 구성
  LOOP AT gt_stock ASSIGNING FIELD-SYMBOL(<fs_stock>).
    "가용재고
    <fs_stock>-menge = <fs_stock>-length * <fs_stock>-factor.

    "플랜트명
    IF <fs_stock>-werks IS NOT INITIAL.
      <fs_stock>-werks_tx = VALUE #( lt_t001w[ werks = <fs_stock>-werks ]-name1 OPTIONAL ).

      "저장위치 명
      IF <fs_stock>-werks IS NOT INITIAL.
        <fs_stock>-lgort_tx = VALUE #( lt_t001l[ werks = <fs_stock>-werks
                                                 lgort = <fs_stock>-lgort ]-lgobe OPTIONAL ).
      ENDIF.
    ENDIF.

    "자재명
    IF <fs_stock>-matnr IS NOT INITIAL.
      <fs_stock>-matnr_tx = VALUE #( lt_makt[ matnr = <fs_stock>-matnr ]-maktx OPTIONAL ).
    ENDIF.

    "거래처명
    IF <fs_stock>-vbeln IS NOT INITIAL.
      <fs_stock>-kunnr_tx = VALUE #( lt_vbak[ vbeln = <fs_stock>-vbeln ]-name1 OPTIONAL ).
    ENDIF.

  ENDLOOP.

  CALL SCREEN 9000 STARTING AT 15 5
                   ENDING AT   170 30.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORT_GRID9
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sort_grid9 .
  DATA: lv_spos  TYPE slis_spos.
  CLEAR:gt_sort9[].


  CLEAR gs_sort.
  lv_spos = lv_spos + 1.
  gs_sort-spos = lv_spos.
  gs_sort-fieldname = 'ZSORT'.
  APPEND gs_sort TO gt_sort9.

  CLEAR gs_sort.
  lv_spos = lv_spos + 1.
  gs_sort-spos = lv_spos.
  gs_sort-fieldname = 'WERKS'.
  APPEND gs_sort TO gt_sort9.

  CLEAR gs_sort.
  lv_spos = lv_spos + 1.
  gs_sort-spos = lv_spos.
  gs_sort-fieldname = 'WERKS_TX'.
  APPEND gs_sort TO gt_sort9.

  CLEAR gs_sort.
  lv_spos = lv_spos + 1.
  gs_sort-spos = lv_spos.
  gs_sort-fieldname = 'LGORT'.
  APPEND gs_sort TO gt_sort9.

  CLEAR gs_sort.
  lv_spos = lv_spos + 1.
  gs_sort-spos = lv_spos.
  gs_sort-fieldname = 'LGORT_TX'.
  APPEND gs_sort TO gt_sort9.

  CLEAR gs_sort.
  lv_spos = lv_spos + 1.
  gs_sort-spos = lv_spos.
  gs_sort-fieldname = 'VBELN'.
  APPEND gs_sort TO gt_sort9.

  CLEAR gs_sort.
  lv_spos = lv_spos + 1.
  gs_sort-spos = lv_spos.
  gs_sort-fieldname = 'POSNR'.
  APPEND gs_sort TO gt_sort9.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form RUN_VLSP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM run_vlsp .
  IF line_exists( gt_alv2[ sel2 = 'X' ] ).
  ELSE.
    MESSAGE s001 WITH TEXT-m03 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "하나의 DO선택
  DATA(lt_temp) = gt_alv2[].
  DELETE lt_temp WHERE sel2 NE 'X'.
  SORT lt_temp BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING vbeln.
  IF lines( lt_temp[] ) > 1.
    MESSAGE s001 WITH TEXT-m04 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM call_vlsp.


  FREE:lt_temp.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_VLSP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_vlsp .
  DATA: lt_params   LIKE rsparams OCCURS 0 WITH HEADER LINE.
  DATA: lv_vlsp(4).

  CLEAR   : lt_params.
  REFRESH : lt_params.

  DATA(ls_line) = VALUE #( gt_alv2[ sel2 = 'X' ] OPTIONAL ).

  SELECT SINGLE vkorg
    FROM likp
   WHERE vbeln EQ @ls_line-vbeln
    INTO @DATA(lv_vkorg).

  CLEAR   : lt_params.
  lt_params-selname = 'IT_VKORG'.
  lt_params-kind    = 'S'.
  lt_params-sign    = 'I'.
  lt_params-option  = 'EQ'.
  lt_params-low     = lv_vkorg.
  APPEND lt_params.

  CLEAR   : lt_params.
  lt_params-selname = 'IT_VBELN'.
  lt_params-kind    = 'S'.
  lt_params-sign    = 'I'.
  lt_params-option  = 'EQ'.
  lt_params-low     = ls_line-vbeln.
  APPEND lt_params.

  CLEAR   : lt_params.
  lt_params-selname = 'IT_TKNUM'.
  lt_params-kind    = 'S'.
*  LT_PARAMS-SIGN    = 'I'.
*  LT_PARAMS-OPTION  = 'EQ'.
  lt_params-low     = ls_line-vbeln.
  APPEND lt_params.

  CLEAR   : lt_params.
  lt_params-selname = 'IF_PMODE'.
  lt_params-kind    = 'P'.
*  LT_PARAMS-SIGN    = 'I'.
*  LT_PARAMS-OPTION  = 'EQ'.
  lt_params-low     = '0003'.
  APPEND lt_params.

  CLEAR   : lt_params.
  lt_params-selname = 'IF_ALDST'.
  lt_params-kind    = 'P'.
*  LT_PARAMS-SIGN    = 'I'.
*  LT_PARAMS-OPTION  = 'EQ'.
  lt_params-low     = ' '.
  APPEND lt_params.

  CLEAR   : lt_params.
  lt_params-selname = 'IF_POPUP'.
  lt_params-kind    = 'P'.
*  LT_PARAMS-SIGN    = 'I'.
*  LT_PARAMS-OPTION  = 'EQ'.
  lt_params-low     = ' '.
  APPEND lt_params.

  CLEAR   : lt_params.
  lt_params-selname = 'IF_SAVE'.
  lt_params-kind    = 'P'.
*  LT_PARAMS-SIGN    = 'I'.
*  LT_PARAMS-OPTION  = 'EQ'.
  lt_params-low     = 'X'.
  APPEND lt_params.

* DO USEREXIT 'userexit_save_document' => PERFORM userexit_save_document_0001.
* T-CODE 'ZGTLER1130' 에서 처리
  lv_vlsp = 'VLSP'.
  EXPORT lv_vlsp TO MEMORY ID 'ZGTLER1130_VLSP'.

  SUBMIT rledsp WITH SELECTION-TABLE lt_params
                 AND RETURN.

  FREE MEMORY ID 'ZGTLER1130_VLSP'.

  FREE: ls_line,lv_vkorg.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_input .
  CLEAR:gv_tknum_multi.
*-복수배차
  CHECK r10 IS NOT INITIAL.

*-납품문서 입력
  IF s_vbeln[] IS INITIAL.
    MESSAGE s001 WITH TEXT-m05 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  SELECT vbeln
    FROM likp
   WHERE vbeln IN @s_vbeln
    INTO TABLE @DATA(lt_likp).
  IF sy-subrc NE 0.
    MESSAGE s001 WITH TEXT-m06 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF lines( lt_likp[] ) > 1.
    MESSAGE s001 WITH TEXT-m07 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

*-SHIPMENT ASSIGN된 납품문서만 대상
  SELECT a~tknum,a~vbeln,b~shtyp
    FROM vttp AS a INNER JOIN vttk AS b
                   ON a~tknum = b~tknum
   WHERE a~vbeln IN @s_vbeln
     AND b~shtyp NE 'Z103'   "해상운송
    INTO TABLE @DATA(lt_vttp).
  IF sy-subrc NE 0.
    MESSAGE s001 WITH TEXT-m08 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

*-

  FREE:lt_likp,lt_vttp.
ENDFORM.
