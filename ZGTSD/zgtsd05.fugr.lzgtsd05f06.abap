*----------------------------------------------------------------------*
***INCLUDE LZGTSD05F06.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form save_log_go
*&---------------------------------------------------------------------*
FORM save_log_go  TABLES   pt_htab STRUCTURE zgtsdsif0020
                           pt_itab STRUCTURE zgtsdsif0021
                  USING    pv_value1
                           pv_system LIKE zgtsdt1020-zsystem_id
                           pv_stamp LIKE zgtsdt1020-zifkey.

  DATA : lv_seq LIKE zgtsdt1020-zseq.

**

  IF pv_stamp IS NOT INITIAL AND pv_value1 = 'S'.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_1020
      FROM zgtsdt1020
      WHERE zifkey = pv_stamp.

    LOOP AT gt_1020 .
      MOVE-CORRESPONDING gt_1020 TO pt_htab.
      MOVE-CORRESPONDING gt_1020 TO pt_itab.
      APPEND pt_itab.
    ENDLOOP.
    APPEND pt_htab.
  ELSEIF pv_value1 = 'S'.

    LOOP AT pt_htab.
      LOOP AT pt_itab WHERE vbeln = pt_htab-vbeln.
        ADD 1 TO lv_seq.
        MOVE-CORRESPONDING pt_htab TO gt_1020.
        MOVE-CORRESPONDING pt_itab TO gt_1020.
        gt_1020-zifkey = gv_stamp.
        gt_1020-zseq = lv_seq.
        gt_1020-erdat = gv_erdat.
        gt_1020-erzet = gv_erzet.
        gt_1020-zsystem_id = pv_system.

        APPEND gt_1020. CLEAR : gt_1020.
      ENDLOOP.
    ENDLOOP.

    IF gt_1020[] IS NOT INITIAL.
      MODIFY zgtsdt1020 FROM TABLE gt_1020.
      COMMIT WORK.
    ENDIF.

  ELSEIF pv_value1 = 'E'.

    LOOP AT gt_1020 .
      gt_1020-zo_result = gv_result.
      gt_1020-zo_message = gv_message.
      MODIFY gt_1020. CLEAR : gt_1020.
    ENDLOOP.
    IF gt_1020[] IS NOT INITIAL.
      MODIFY zgtsdt1020 FROM TABLE gt_1020.
      COMMIT WORK.
    ENDIF.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_check_go
*&---------------------------------------------------------------------*
FORM data_check_go  TABLES    pt_htab STRUCTURE zgtsdsif0020
                              pt_itab STRUCTURE zgtsdsif0021.

**

*1) 필수값 입력 여부 점검
  CHECK gv_error = ' '.
  PERFORM check_man_field_go     TABLES pt_htab
                                        pt_itab.

*2) 입력값 점검
  CHECK gv_error = ' '.
  PERFORM check_value_go         TABLES pt_htab
                                        pt_itab..

*3) 요청유형에 따른 상태 점검
  CHECK gv_error = ' '.
  PERFORM check_status_go        TABLES pt_htab
                                        pt_itab.

*4) lock 점검
  CHECK gv_error = ' '.
  PERFORM check_lock_go          TABLES pt_htab
                                        pt_itab.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_man_field_go
*&---------------------------------------------------------------------*
FORM check_man_field_go  TABLES   pt_htab STRUCTURE zgtsdsif0020
                                  pt_itab STRUCTURE zgtsdsif0021.

  DATA: lt_fieldinfo TYPE TABLE OF dfies,
        ls_fieldinfo TYPE dfies.
  FIELD-SYMBOLS: <fs_field> TYPE any.
  DATA : lv_string TYPE string.
  DATA : ls_head LIKE pt_htab.
  DATA : ls_item LIKE pt_itab.
  DATA : lv_matnr TYPE matnr18.

**

*--- 헤더 필드 점검
  PERFORM get_fieldinfo_go     TABLES lt_fieldinfo
                               USING  'ZGTSDSIF0020'.

  "미점검 대상 삭제
  READ TABLE pt_htab INDEX 1 INTO ls_head.
  IF ls_head-reqtyp = 'CP' AND ls_head-vbeln IS NOT INITIAL..
    EXIT.
  ELSE.
    DELETE lt_fieldinfo WHERE
    fieldname = 'WADAT_IST' .
  ENDIF.

  LOOP AT lt_fieldinfo INTO ls_fieldinfo.

    LOOP AT pt_htab ASSIGNING FIELD-SYMBOL(<fs_wa>).

      MOVE-CORRESPONDING <fs_wa> TO ls_head.
      ASSIGN COMPONENT ls_fieldinfo-fieldname OF STRUCTURE <fs_wa> TO <fs_field>.
      IF <fs_field> IS INITIAL.
        PERFORM make_error_message_go     USING ls_fieldinfo-fieldname.
      ENDIF.

    ENDLOOP.

    IF gv_error = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.


*--- ITEM1 점검
  CHECK gv_error = ' '.
  IF pt_itab[] IS NOT INITIAL.

    CLEAR : lt_fieldinfo, lt_fieldinfo[].
    PERFORM get_fieldinfo_go     TABLES lt_fieldinfo
                                 USING  'ZGTSDSIF0021'.

    DELETE lt_fieldinfo WHERE fieldname = 'CHARG'.

    LOOP AT lt_fieldinfo INTO ls_fieldinfo.
      LOOP AT pt_itab ASSIGNING FIELD-SYMBOL(<fs_wa2>).
        ASSIGN COMPONENT ls_fieldinfo-fieldname OF STRUCTURE <fs_wa2> TO <fs_field>.
        IF <fs_field> IS INITIAL.
          PERFORM make_error_message_go   USING ls_fieldinfo-fieldname.
        ENDIF.
      ENDLOOP.
      IF gv_error = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_fieldinfo_go
*&---------------------------------------------------------------------*
FORM get_fieldinfo_go  TABLES   pt_fieldinfo STRUCTURE dfies
                       USING    p_table.

  DATA : lv_ddobjname TYPE ddobjname.
  DATA : lv_langu LIKE sy-langu VALUE 'KO'.

**

  lv_ddobjname = p_table.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname   = lv_ddobjname
      langu     = lv_langu
      fieldname = ' ' " 모든 필드 정보를 가져옵니다.
    TABLES
      dfies_tab = pt_fieldinfo
    EXCEPTIONS
      OTHERS    = 1.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form make_error_message_go
*&---------------------------------------------------------------------*
FORM make_error_message_go  USING i_field_name TYPE dfies-fieldname .

**
  CONCATENATE 'Field value missing :' i_field_name INTO gv_message.
  gv_error = 'X'. gv_result = '01'.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_value_go
*&---------------------------------------------------------------------*
FORM check_value_go  TABLES   pt_htab STRUCTURE zgtsdsif0020
                              pt_itab STRUCTURE zgtsdsif0021.

  DATA : lv_posnr LIKE lips-posnr.
  DATA : lv_matnr TYPE matnr18.
  DATA : lv_batch.

**

  LOOP AT pt_htab.
    SELECT SINGLE mandt INTO sy-mandt FROM likp WHERE vbeln = pt_htab-vbeln.
    IF sy-subrc <> 0 .
      gv_error = 'X'.  gv_result = '01'.
      CONCATENATE '(H/VBELN)존재하지 않는 납품문서-' pt_htab-vbeln INTO gv_message.
      EXIT.
    ENDIF.

    IF pt_htab-reqtyp <> 'U' AND pt_htab-reqtyp <> 'UG' AND pt_htab-reqtyp <> 'C'
       AND pt_htab-reqtyp <> 'CP'.
      gv_error = 'X'.  gv_result = '01'.
      CONCATENATE '(H/REQTYP)정의되지 않은 요청타입-' pt_htab-reqtyp INTO gv_message.
      EXIT.
    ENDIF.

    IF pt_htab-vsart <> '01' AND
        pt_htab-vsart <> '02' AND
        pt_htab-vsart <> '03' AND
        pt_htab-vsart <> '04' AND
        pt_htab-vsart <> '09' AND
        pt_htab-vsart IS NOT INITIAL.
      gv_error = 'X'. gv_result = '01'.
      CONCATENATE '(H/VSART)정의되지 않은 출하유형-' pt_htab-vsart INTO gv_message.
      EXIT.
    ENDIF.

    IF pt_htab-wadat_ist IS NOT INITIAL AND pt_htab-reqtyp = 'UG'.
      PERFORM check_closing_go     USING pt_htab-wadat_ist.
    ENDIF.

    IF gv_error = 'X'.
      EXIT.
    ENDIF.

    IF pt_htab-route IS NOT INITIAL.
      PERFORM check_route_go       USING pt_htab-route.
    ENDIF.

    IF gv_error = 'X'.
      EXIT.
    ENDIF.

    READ TABLE pt_itab WITH KEY vbeln  = pt_htab-vbeln.
    IF sy-subrc <> 0 .
      gv_error = 'X'.  gv_result = '01'.
      CONCATENATE '(H/VBELN)ITEM 데이터 누락-' pt_htab-vbeln INTO gv_message.
      EXIT.
    ENDIF.


  ENDLOOP.


  LOOP AT pt_itab.
    lv_posnr = |{ pt_itab-posnr ALPHA = IN }|.
    lv_matnr = |{ pt_itab-matnr ALPHA = IN }|.

    SELECT SINGLE mandt INTO sy-mandt FROM lips
      WHERE vbeln = pt_itab-vbeln AND posnr = lv_posnr .

    IF sy-subrc <> 0 .
      gv_error = 'X'.  gv_result = '01'.
      CONCATENATE '(I/POSNR)존재하지 않는 납품/품목-' pt_htab-vbeln INTO gv_message.
      EXIT.
    ENDIF.

    SELECT SINGLE mandt INTO sy-mandt FROM mara WHERE matnr = lv_matnr.
    IF sy-subrc <> 0 .
      gv_error = 'X'.  gv_result = '01'.
      CONCATENATE '(I/MATNR)존재하지 않는 자재코드-' pt_itab-matnr INTO gv_message.
      EXIT.
    ENDIF.

    SELECT SINGLE mandt INTO sy-mandt FROM lips
      WHERE vbeln = pt_itab-vbeln AND posnr = lv_posnr
      AND matnr = lv_matnr.
    IF sy-subrc <> 0 .
      gv_error = 'X'.  gv_result = '01'.
      CONCATENATE '(I/MATNR)품목번호와 자재코드 불일치-' pt_itab-matnr INTO gv_message.
      EXIT.
    ENDIF.

    IF pt_itab-matnr IS NOT INITIAL AND pt_htab-reqtyp <> 'CP'.

      PERFORM check_matnr_batch_using_go     USING pt_itab-matnr
                                                   pt_itab-werks
                                                   lv_batch .
      IF lv_batch = 'X' AND pt_itab-charg IS INITIAL.
        gv_error = 'X'.  gv_result = '01'.
        CONCATENATE '(I/CHARG)배치사용자재의 배치번호 누락-' pt_itab-matnr INTO gv_message.
        EXIT.
      ENDIF.
    ENDIF.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_closing_go
*&---------------------------------------------------------------------*
FORM check_closing_go  USING    pwadat_ist LIKE sy-datum.

  DATA : ls_marv LIKE marv.

**
  SELECT SINGLE *  INTO ls_marv
    FROM marv  WHERE bukrs = '1000'.

  IF ls_marv-xruem = 'X'.
    IF ( pwadat_ist+0(4) <> ls_marv-lfgja OR pwadat_ist+4(2) <> ls_marv-lfmon ) AND
        ( pwadat_ist+0(4) <> ls_marv-vmgja OR pwadat_ist+4(2) <> ls_marv-vmmon ) .
      gv_error = 'X' .
    ENDIF.

  ELSE.
    IF pwadat_ist+0(4) <> ls_marv-lfgja OR pwadat_ist+4(2) <> ls_marv-lfmon.
      gv_error = 'X' .
    ENDIF.

  ENDIF.

  IF gv_error = 'X'.
    CONCATENATE '(H/WADAT_IST)물류기간 마감으로 기표 불가능입-' pwadat_ist INTO gv_message.
    gv_error = 'X'. gv_result = '01'.
    EXIT.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_route_go
*&---------------------------------------------------------------------*
FORM check_route_go  USING    p_route.

**
  SELECT SINGLE mandt  INTO sy-mandt
    FROM tvro  WHERE route = p_route.

  IF sy-subrc <> 0 .
    CONCATENATE '(H/ROUTE)존재하지 않은 운송경로-' p_route INTO gv_message.
    gv_error = 'X'. gv_result = '01'.
    EXIT.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_matnr_batch_using_go
*&---------------------------------------------------------------------*
FORM check_matnr_batch_using_go  USING    pv_matnr
                                          pv_werks
                                          pv_xchpf.

  DATA : lv_matnr TYPE matnr18.

**
  lv_matnr = |{ pv_matnr ALPHA = IN }|.

  SELECT SINGLE xchpf
    INTO pv_xchpf
    FROM marc
    WHERE matnr = lv_matnr
    AND werks = pv_werks.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_status_go
*&---------------------------------------------------------------------*
FORM check_status_go  TABLES  pt_htab STRUCTURE zgtsdsif0020
                              pt_itab STRUCTURE zgtsdsif0021.

  " 1. 에러 처리 매크로 재정의 (메시지 변수 할당 제외)
  DEFINE _set_error.
    gv_error   = 'X'.
    gv_result  = '01'.
    EXIT.
  END-OF-DEFINITION.
**

  " 2. 테이블 라인 수 점검
  IF lines( pt_htab ) <> 1.
    gv_message = '납품문서 1건만 처리가 가능 합니다.'.
    _set_error.
  ENDIF.

  IF pt_itab[] IS INITIAL.
    gv_message = '아이템정보가 존재하지 않습니다.'.
    _set_error.
  ENDIF.

  READ TABLE pt_htab INDEX 1.

  " 헤더 상태 조회
  SELECT SINGLE wbstk INTO @DATA(lv_wbstk)
    FROM likp
   WHERE vbeln = @pt_htab-vbeln.

  " 3. 요청 유형별 분기
  CASE pt_htab-reqtyp.

      " ---------------------------------------------------------
      " 출고전기
      " ---------------------------------------------------------
    WHEN 'UG'.
      IF lv_wbstk EQ 'C'.
        gv_message = |(H/REQTYP)출고전기가 완료된 납품문서-{ pt_htab-vbeln }|.
        _set_error.
      ENDIF.

      IF pt_htab-wadat_ist IS INITIAL.
        gv_message = |(H/WADAT_IST)출고전기일이 누락된 납품문서-{ pt_htab-vbeln }|.
        _set_error.
      ENDIF.

      " ---------------------------------------------------------
      " 취소요청
      " ---------------------------------------------------------
    WHEN 'C'.
      IF lv_wbstk <> 'C'.
        gv_message = |(H/REQTYP)출고가 되지 않은 납품문서입니다-{ pt_htab-vbeln }|.
        _set_error.
      ENDIF.

      " 빌링점검
      SELECT SINGLE @abap_true INTO @DATA(lv_vbrk_exists)
        FROM vbrk AS rk
       INNER JOIN vbrp AS rp ON rk~vbeln EQ rp~vbeln
       WHERE rp~vgbel = @pt_htab-vbeln
         AND rk~sfakn = @space
         AND rk~fksto = @space.

      IF lv_vbrk_exists EQ abap_true.
        gv_message = |매출처리가 완료되어 삭제가 불가능 합니다.-{ pt_htab-vbeln }|.
        _set_error.
      ENDIF.

      " 거래명세서 발행여부 점검
      SELECT SINGLE @abap_true INTO @DATA(lv_zlet_exists)
        FROM zlet0006 AS i
       INNER JOIN zlet0005 AS h ON i~iv_no EQ h~iv_no
       WHERE i~vbeln = @pt_htab-vbeln
         AND h~iv_cancel_yn = @space.

      IF lv_zlet_exists EQ abap_true.
        gv_message = |통문증이 발행되어 삭제가 불가능 합니다.-{ pt_htab-vbeln }|.
        _set_error.
      ENDIF.

      " ---------------------------------------------------------
      " Picking 취소
      " ---------------------------------------------------------
    WHEN 'CP'.
      DATA(lt_temp_cp) = pt_itab[].
      SORT lt_temp_cp BY vbeln posnr charg matnr werks lgort.
      DELETE ADJACENT DUPLICATES FROM lt_temp_cp COMPARING vbeln posnr charg matnr werks lgort.

      IF lt_temp_cp[] IS NOT INITIAL.
        SELECT SINGLE @abap_true
          FROM @lt_temp_cp AS a
         INNER JOIN lips AS b ON a~vbeln = b~vbeln AND a~posnr = b~posnr
                             AND a~matnr = b~matnr AND a~charg = b~charg
                             AND a~werks = b~werks AND a~lgort = b~lgort
          INTO @DATA(lv_lips_cp_exists).
        IF lv_lips_cp_exists EQ space.
          gv_message = 'Picking 취소 할 Batch가 없습니다.'.
          _set_error.
        ENDIF.
      ENDIF.

      " ---------------------------------------------------------
      " Picking 처리
      " ---------------------------------------------------------
    WHEN 'U'.
*      DATA(lt_temp_u) = pt_itab[].
*      SORT lt_temp_u BY vbeln posnr charg matnr werks lgort.
*      DELETE ADJACENT DUPLICATES FROM lt_temp_u COMPARING vbeln posnr charg matnr werks lgort.
*
*      " [1] 단일 대상 데이터 추출
*      READ TABLE lt_temp_u INTO DATA(ls_req) INDEX 1.
*      IF sy-subrc NE 0.
*        RETURN.
*      ENDIF.
*
*      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
*        EXPORTING
*          input  = ls_req-matnr
*        IMPORTING
*          output = ls_req-matnr.
*
*      " [2] 기 피킹 완료 Batch 검증 (수량, 자재, 배치 등 일치 여부)
*      SELECT SINGLE vbeln, posnr, matnr, charg, lfimg
*        FROM lips
*       WHERE matnr EQ @ls_req-matnr
*         AND charg EQ @ls_req-charg
*         AND werks EQ @ls_req-werks
*         AND lgort EQ @ls_req-lgort
*         AND lfimg EQ @ls_req-lfimg
*        INTO @DATA(ls_picked).
*
*      IF sy-subrc EQ 0.
*        gv_message = |이미 처리되었습니다. 다음 건을 처리하세요.|.
*        _set_error.
*        RETURN.
*      ENDIF.
*
*      " [3] 품목 수량 0 검증 및 관련 필드(sonum) 동시 확보
*      SELECT SINGLE vbeln, posnr, lfimg, sonum
*        FROM lips
*       WHERE vbeln EQ @ls_req-vbeln
*         AND posnr EQ @ls_req-posnr
*        INTO @DATA(ls_lips).
*
*      IF sy-subrc EQ 0 AND ls_lips-lfimg EQ 0.
*        gv_message = |Picking 처리 완료된 납품문서 품목입니다.{ ls_req-vbeln }/{ ls_req-posnr }|.
*        _set_error.
*        RETURN.
*      ENDIF.

*      " [4] 정조장 여부 점검
*      SELECT SINGLE b~mvgr3
*        FROM lips AS a INNER JOIN vbap AS b
*                       ON a~vgbel EQ b~vbeln
*                       AND a~vgpos EQ b~posnr
*       WHERE a~vbeln EQ @ls_req-vbeln
*         AND a~posnr EQ @ls_req-posnr
*        INTO @DATA(lv_mvgr3).
*
*      " [5] SO 재고 매핑 검증
*      IF lv_mvgr3 IS INITIAL.
*        SELECT SINGLE concat( vbeln, posnr ) AS sonum
*          FROM mska
*         WHERE matnr EQ @ls_req-matnr
*           AND charg EQ @ls_req-charg
*           AND werks EQ @ls_req-werks
*           AND lgort EQ @ls_req-lgort
*          INTO @DATA(lv_sonum_e).
*
*        IF sy-subrc NE 0 OR lv_sonum_e IS INITIAL.
*          gv_message = |판매오더 재고 이전전기 되어 있지 않습니다.|.
*          _set_error.
*          RETURN.
*        ENDIF.
*
*        IF ls_lips-sonum NE lv_sonum_e.
*          gv_message = |다른 판매오더의 재고입니다.|.
*          _set_error.
*          RETURN.
*        ENDIF.
*      ENDIF.

  ENDCASE.
**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_lock_go
*&---------------------------------------------------------------------*
FORM check_lock_go  TABLES    pt_htab STRUCTURE zgtsdsif0020
                              pt_itab STRUCTURE zgtsdsif0021.

  DATA  : lv_lock(1).

**
  LOOP AT pt_htab.

    PERFORM enqueue_read_go     USING lv_lock
                                      pt_htab-vbeln.
    IF lv_lock = 'X'.
      CONCATENATE '다른사용자가 변경중인 문서입니다.-' pt_htab-vbeln INTO gv_message.
      gv_error = 'X'. gv_result = '01'.
      EXIT.
    ENDIF.

  ENDLOOP.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form enqueue_read_go
*&---------------------------------------------------------------------*
FORM enqueue_read_go  USING pv_lock pv_vbeln.

  DATA : lv_vbeln LIKE likp-vbeln.
  DATA : it_enq   LIKE TABLE OF seqg3 WITH HEADER LINE,
         i_number LIKE sy-tabix,
         i_subrc  LIKE sy-subrc.

**
  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gclient               = sy-mandt
      gname                 = 'LIKP'
*     GARG                  =
*     GUNAME                = SY-UNAME
      local                 = ' '
*     FAST                  = ' '
*     GARGNOWC              = ' '
    IMPORTING
      number                = i_number
      subrc                 = i_subrc
    TABLES
      enq                   = it_enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.

  IF i_number <> 0.

    LOOP AT it_enq.
      lv_vbeln = it_enq-garg+3(10).
      IF lv_vbeln = pv_vbeln.
        pv_lock = 'X'.
      ENDIF.
    ENDLOOP.

  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_processing_go
*&---------------------------------------------------------------------*
FORM data_processing_go  TABLES   pt_htab STRUCTURE zgtsdsif0020
                                  pt_itab STRUCTURE zgtsdsif0021.

  DATA : ls_htab LIKE zgtsdsif0020.

**
  CHECK gv_error = ' '.

  READ TABLE pt_htab INDEX 1 INTO ls_htab.

  "피킹 혹은 출고전기
  IF ls_htab-reqtyp = 'U' OR ls_htab-reqtyp = 'UG'.
    PERFORM data_picking_and_gi_go     TABLES pt_itab
                                       USING  ls_htab..
  ENDIF.

  IF ls_htab-reqtyp = 'CP'.
    PERFORM data_unpicking_go          TABLES pt_itab
                                       USING  ls_htab..
  ENDIF.
  "출고전기 취소
  IF ls_htab-reqtyp = 'C' .
    PERFORM data_gi_cancel_go          TABLES pt_itab
                                       USING  ls_htab..
  ENDIF.

  PERFORM link_info_update_go          TABLES pt_itab
                                       USING  ls_htab.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_picking_and_gi_go
*&---------------------------------------------------------------------*
FORM data_picking_and_gi_go  TABLES   pt_itab STRUCTURE zgtsdsif0021
                          USING    ps_htab LIKE  zgtsdsif0020.

  DATA : lv_first.
  DATA : lv_index     TYPE sy-tabix.
  DATA : lv_batch  TYPE c.
  DATA : lv_lfimg(13).
  DATA : lfsum(13).
  DATA : lfmax(13).
  DATA : lfmin(13).
  DATA : lv_change.
  DATA : ls_lips LIKE lips.

  DATA : lt_itab LIKE pt_itab OCCURS 0 WITH HEADER LINE  .

**
  ps_htab-vsart = abap_false.
  lt_itab[] = pt_itab[].

  PERFORM bdc_dynpro_processing USING:
              'X'   'SAPMV50A'           '4004',
              ' '   'BDC_OKCODE'         '/00',
              ' '   'LIKP-VBELN'         ps_htab-vbeln.

  PERFORM bdc_dynpro_processing USING:
          'X'   'SAPMV50A'           '1000',
          ' '   'BDC_OKCODE'         '=HDET_T',

          'X'   'SAPMV50A'           '2000',
          ' '   'BDC_OKCODE'         '=T\04',

          'X'   'SAPMV50A'           '2000',
          ' '   'BDC_OKCODE'         '/00'.

  PERFORM bdc_dynpro_processing USING:

             ' '   'LIKP-VSART'        ps_htab-vsart,
             ' '   'LIKP-ROUTE'        ps_htab-route,
             ' '   'BDC_OKCODE'         '/00',

             'X'   'SAPMV50A'           '2000',
             ' '   'BDC_OKCODE'         '=BACK_T'.

  PERFORM bdc_dynpro_processing USING:
                'X'   'SAPMV50A'           '1000',
                ' '   'BDC_OKCODE'         '=T\01',

                'X'   'SAPMV50A'           '1000',
                ' '   'BDC_OKCODE'         '=T\02',
                ' '   'LIKP-WADAT_IST'     ps_htab-wadat_ist.

  SORT pt_itab BY vbeln posnr.

  LOOP AT pt_itab.
    AT NEW posnr.
      lv_change = 'X'.
    ENDAT.
    PERFORM check_matnr_batch_using_go    USING pt_itab-matnr
                                                pt_itab-werks
                                                lv_batch .

    lv_lfimg = pt_itab-lfimg.
    CLEAR : lfsum.
    LOOP AT lt_itab WHERE vbeln = pt_itab-vbeln AND posnr = pt_itab-posnr.
      lfsum = lfsum + lt_itab-lfimg.
    ENDLOOP.
    CONDENSE lfsum NO-GAPS.
    CONDENSE lv_lfimg NO-GAPS.

    IF ls_lips-untto IS NOT INITIAL.
    ENDIF.

    "배치사용자재

    IF lv_batch IS NOT INITIAL.
      "기존에 입력된 배치 삭제를 위한 배치분할 선택
      "품목이 변경될때만 실행
*      IF lv_change = 'X'.
*        PERFORM bdc_dynpro_processing USING:
*                    'X'   'SAPMV50A'           '1000',
*                    ' '   'BDC_OKCODE'         '=POPO_T',
*
*                    'X'   'SAPMV50A'           '0111',
*                    ' '   'BDC_OKCODE'         '=WEIT',
*                    ' '   'RV50A-POSNR'        pt_itab-posnr,
*
*                    'X'   'SAPMV50A'           '1000',
*                    ' '   'BDC_OKCODE'         '=CHSP_T'. "배치분할버튼
*
*        "기존에 입력된 배치 삭제
*        PERFORM bdc_dynpro_processing USING:
*                    'X'   'SAPMV50A'           '3000',
*                    ' '   'BDC_OKCODE'         '=MKAL_T'.
*        PERFORM bdc_dynpro_processing USING:
*                    'X'   'SAPMV50A'           '3000',
*                    ' '   'BDC_OKCODE'         '=POLO_T'.
*        PERFORM bdc_dynpro_processing USING:
*                    'X'   'SAPMV50A'           '3000',
*                    ' '   'BDC_OKCODE'         '=BACK_T'.
*      ENDIF.
*
*
*      PERFORM bdc_dynpro_processing USING:
*                  'X'   'SAPMV50A'           '1000',
*                  ' '   'BDC_OKCODE'         '=POPO_T',
*
*                  'X'   'SAPMV50A'           '0111',
*                  ' '   'BDC_OKCODE'         '=WEIT',
*                  ' '   'RV50A-POSNR'        pt_itab-posnr.
*      "피킹수량 입력
*      IF lv_change = 'X'.
*
*        PERFORM bdc_dynpro_processing USING:
*                     'X'   'SAPMV50A'           '1000',
*                     ' '   'BDC_OKCODE'         '/00',
*                     ' '   'LIPSD-PIKMG(01)'    '0'. "피킹수량
*        .
*        PERFORM bdc_dynpro_processing USING:
*                     'X'   'SAPMV50A'           '1000',
*                     ' '   'BDC_OKCODE'         '/00',
*                     ' '   'LIPSD-G_LFIMG(01)'    lfsum. "납품수량
*
*        PERFORM bdc_dynpro_processing USING:
*                     'X'   'SAPMV50A'           '1000',
*                     ' '   'BDC_OKCODE'         '/00',
*                     ' '   'LIPSD-PIKMG(01)'    lfsum. "피킹수량
*      ENDIF.
      "신규 배치를 입력을 위한 배치분할 버튼 클릭

      PERFORM bdc_dynpro_processing USING:
                  'X'   'SAPMV50A'           '1000',
                  ' '   'BDC_OKCODE'         '=POPO_T',

                  'X'   'SAPMV50A'           '0111',
                  ' '   'BDC_OKCODE'         '=WEIT',
                  ' '   'RV50A-POSNR'        pt_itab-posnr.
      PERFORM bdc_dynpro_processing USING:
                  'X'   'SAPMV50A'           '1000',
                  ' '   'BDC_OKCODE'         '=CHSP_T'. "배치분할
      " 신규 배치 입력
      PERFORM bdc_dynpro_processing USING:
             'X'   'SAPMV50A'           '3000',
             ' '   'BDC_OKCODE'         '=POAN_T',  "행추가

             'X'   'SAPMV50A'           '3000',
             ' '   'BDC_OKCODE'         '/00',
             ' '   'LIPS-CHARG(02)'     pt_itab-charg,
             ' '   'LIPS-LGORT(02)'     pt_itab-lgort,
             ' '   'LIPS-LFIMG(02)'     lv_lfimg,
             ' '   'LIPS-VRKME(02)'     pt_itab-vrkme.

      PERFORM bdc_dynpro_processing USING:
             'X'   'SAPMV50A'           '3000',
             ' '   'BDC_OKCODE'         '=BACK_T'.  "뒤로
      CLEAR : lv_change.
    ELSE."배치미사용자재
      PERFORM bdc_dynpro_processing USING:
                  'X'   'SAPMV50A'           '1000',
                  ' '   'BDC_OKCODE'         '=POPO_T',

                  'X'   'SAPMV50A'           '0111',
                  ' '   'BDC_OKCODE'         '=WEIT',
                  ' '   'RV50A-POSNR'        pt_itab-posnr.

      "
      PERFORM bdc_dynpro_processing USING:

                  'X'   'SAPMV50A'           '1000',
                  ' '   'BDC_OKCODE'         '/00',
                  ' '   'LIPSD-PIKMG(01)'    '0', "피킹수량

                  'X'   'SAPMV50A'           '1000',
                  ' '   'BDC_OKCODE'         '/00',
                  ' '   'LIPS-LGORT(01)'     pt_itab-lgort,

                   'X'   'SAPMV50A'           '1000',
                   ' '   'BDC_OKCODE'         '/00',
                   ' '   'LIPSD-PIKMG(01)'    lfsum. "피킹수량
    ENDIF.

** Picking 수량 입력
** 마지막 생성된 Batch 품목번호 Get
    SELECT MAX( posnr )
       FROM lips  WHERE vbeln EQ @pt_itab-vbeln
                            AND uecha EQ @pt_itab-posnr
     INTO @DATA(lv_posnr).
**

    PERFORM bdc_dynpro_processing USING:
                'X' 'SAPMV50A'             '1000',
                ' ' 'BDC_OKCODE'           '=POPO_T',  "품목선택

                'X' 'SAPMV50A'             '0111',
                ' ' 'BDC_OKCODE'           '=WEIT',
                ' ' 'RV50A-POSNR'          pt_itab-posnr,

                'X' 'SAPMV50A'             '1000',
                ' ' 'BDC_OKCODE'           '=CHPL_T01', "배치 펼치기
                ' ' 'RV50A-LIPS_SELKZ(01)' 'X'.

    IF lv_posnr IS NOT INITIAL.
      PERFORM bdc_dynpro_processing USING:
                  'X' 'SAPMV50A'             '1000',
                  ' ' 'BDC_OKCODE'           '=POPO_T',  "품목선택

                  'X' 'SAPMV50A'             '0111',
                  ' ' 'BDC_OKCODE'           '=WEIT',
                  ' ' 'RV50A-POSNR'          lv_posnr.
      CLEAR: lv_posnr.
    ENDIF.

    PERFORM bdc_dynpro_processing USING:
                'X' 'SAPMV50A'             '1000',
                ' ' 'BDC_OKCODE'           '/00',
                ' ' 'LIPSD-PIKMG(02)'      lfsum, "피킹수량

                'X' 'SAPMV50A'             '1000',
                ' ' 'BDC_OKCODE'           '=BACK_T'.
**

  ENDLOOP.

  IF ps_htab-reqtyp = 'U'. "피킹
    PERFORM bdc_dynpro_processing USING:
            'X'   'SAPMV50A'           '1000',
            ' '   'BDC_OKCODE'         '=SICH_T'.  "저장
  ELSEIF ps_htab-reqtyp = 'UG'. "피킹&출고
    PERFORM bdc_dynpro_processing USING:
            'X'   'SAPMV50A'           '1000',
            ' '   'BDC_OKCODE'         '=WABU_T'.  "출고전기
  ENDIF.


  CALL TRANSACTION 'VL02N' USING bdc_tab  UPDATE 'S'
     MODE gv_mode MESSAGES INTO gt_msg.
  CLEAR lv_index.
  DESCRIBE TABLE gt_msg LINES lv_index.

  READ TABLE gt_msg INDEX lv_index.


  CHECK sy-subrc EQ 0.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      msgid               = sy-msgid
      msgnr               = sy-msgno
      msgv1               = sy-msgv1
      msgv2               = sy-msgv2
      msgv3               = sy-msgv3
      msgv4               = sy-msgv4
    IMPORTING
      message_text_output = gv_message.

  IF gt_msg-msgid = 'VL' AND gt_msg-msgnr = '311'.
    gv_error = ' '. gv_result = '00'.
  ELSE.
    gv_error = 'X'. gv_result = '01'.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_unpicking_go
*&---------------------------------------------------------------------*
FORM data_unpicking_go  TABLES   pt_itab STRUCTURE zgtsdsif0021
                          USING    ps_htab LIKE  zgtsdsif0020.


  DATA : lv_first.
  DATA : lv_index     TYPE sy-tabix.
  DATA : lv_batch  TYPE c.
  DATA : lv_lfimg(13).
  DATA : lfsum(13).
  DATA : lfmax(13).
  DATA : lfmin(13).
  DATA : lv_change.
  DATA : ls_lips LIKE lips.

  DATA : lt_itab LIKE pt_itab OCCURS 0 WITH HEADER LINE  .

**
  lt_itab[] = pt_itab[].

  PERFORM bdc_dynpro_processing USING:
              'X'   'SAPMV50A'           '4004',
              ' '   'BDC_OKCODE'         '/00',
              ' '   'LIKP-VBELN'         ps_htab-vbeln.

  PERFORM bdc_dynpro_processing USING:
          'X'   'SAPMV50A'           '1000',
          ' '   'BDC_OKCODE'         '=HDET_T',

          'X'   'SAPMV50A'           '2000',
          ' '   'BDC_OKCODE'         '=T\04',

          'X'   'SAPMV50A'           '2000',
          ' '   'BDC_OKCODE'         '/00'.

  PERFORM bdc_dynpro_processing USING:

             ' '   'LIKP-VSART'        ps_htab-vsart,
             ' '   'LIKP-ROUTE'        ps_htab-route,
             ' '   'BDC_OKCODE'         '/00',

             'X'   'SAPMV50A'           '2000',
             ' '   'BDC_OKCODE'         '=BACK_T'.

  PERFORM bdc_dynpro_processing USING:
                'X'   'SAPMV50A'           '1000',
                ' '   'BDC_OKCODE'         '=T\01',

                'X'   'SAPMV50A'           '1000',
                ' '   'BDC_OKCODE'         '=T\02',
                ' '   'LIKP-WADAT_IST'     ps_htab-wadat_ist.

  SORT pt_itab BY vbeln posnr.

  LOOP AT pt_itab.
    AT NEW posnr.
      lv_change = 'X'.
    ENDAT.
    PERFORM check_matnr_batch_using_go    USING pt_itab-matnr
                                                pt_itab-werks
                                                lv_batch .

    lv_lfimg = pt_itab-lfimg.
    CLEAR : lfsum.
    LOOP AT lt_itab WHERE vbeln = pt_itab-vbeln AND posnr = pt_itab-posnr.
      lfsum = lfsum + lt_itab-lfimg.
    ENDLOOP.
    CONDENSE lfsum NO-GAPS.
    CONDENSE lv_lfimg NO-GAPS.

    IF ls_lips-untto IS NOT INITIAL.
    ENDIF.

    "배치사용자재
    IF lv_batch IS NOT INITIAL.
      "기존에 입력된 배치 삭제를 위한 배치분할 선택
      "품목이 변경될때만 실행
      IF lv_change = 'X'.
        PERFORM bdc_dynpro_processing USING:
                    'X'   'SAPMV50A'           '1000',
                    ' '   'BDC_OKCODE'         '=POPO_T',

                    'X'   'SAPMV50A'           '0111',
                    ' '   'BDC_OKCODE'         '=WEIT',
                    ' '   'RV50A-POSNR'        pt_itab-posnr,

                    'X'   'SAPMV50A'           '1000',
                    ' '   'BDC_OKCODE'         '=CHSP_T'. "배치분할버튼

        "기존에 입력된 배치 삭제
        PERFORM bdc_dynpro_processing USING:
                    'X'   'SAPMV50A'           '3000',
                    ' '   'BDC_OKCODE'         '=MKAL_T'.
        PERFORM bdc_dynpro_processing USING:
                    'X'   'SAPMV50A'           '3000',
                    ' '   'BDC_OKCODE'         '=POLO_T'.
        PERFORM bdc_dynpro_processing USING:
                    'X'   'SAPMV50A'           '3000',
                    ' '   'BDC_OKCODE'         '=BACK_T'.
      ENDIF.


      PERFORM bdc_dynpro_processing USING:
                  'X'   'SAPMV50A'           '1000',
                  ' '   'BDC_OKCODE'         '=POPO_T',

                  'X'   'SAPMV50A'           '0111',
                  ' '   'BDC_OKCODE'         '=WEIT',
                  ' '   'RV50A-POSNR'        pt_itab-posnr.
      "피킹수량 입력
      IF lv_change = 'X'.

        PERFORM bdc_dynpro_processing USING:
                     'X'   'SAPMV50A'           '1000',
                     ' '   'BDC_OKCODE'         '/00',
                     ' '   'LIPSD-PIKMG(01)'    '0'. "피킹수량
      ENDIF.


      CLEAR : lv_change.
    ELSE."배치미사용자재
      PERFORM bdc_dynpro_processing USING:
                  'X'   'SAPMV50A'           '1000',
                  ' '   'BDC_OKCODE'         '=POPO_T',

                  'X'   'SAPMV50A'           '0111',
                  ' '   'BDC_OKCODE'         '=WEIT',
                  ' '   'RV50A-POSNR'        pt_itab-posnr.

      "
      PERFORM bdc_dynpro_processing USING:

                  'X'   'SAPMV50A'           '1000',
                  ' '   'BDC_OKCODE'         '/00',
                  ' '   'LIPSD-PIKMG(01)'    '0', "피킹수량

                  'X'   'SAPMV50A'           '1000',
                  ' '   'BDC_OKCODE'         '/00',
                  ' '   'LIPS-LGORT(01)'     pt_itab-lgort,

                   'X'   'SAPMV50A'           '1000',
                   ' '   'BDC_OKCODE'         '/00',
                   ' '   'LIPSD-PIKMG(01)'    lfsum. "피킹수량
    ENDIF.


  ENDLOOP.

  PERFORM bdc_dynpro_processing USING:
          'X'   'SAPMV50A'           '1000',
          ' '   'BDC_OKCODE'         '=SICH_T'.  "저장

  CALL TRANSACTION 'VL02N' USING bdc_tab  UPDATE 'S'
     MODE gv_mode MESSAGES INTO gt_msg.
  CLEAR lv_index.
  DESCRIBE TABLE gt_msg LINES lv_index.

  READ TABLE gt_msg INDEX lv_index.

  CHECK sy-subrc EQ 0.

  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      msgid               = sy-msgid
      msgnr               = sy-msgno
      msgv1               = sy-msgv1
      msgv2               = sy-msgv2
      msgv3               = sy-msgv3
      msgv4               = sy-msgv4
    IMPORTING
      message_text_output = gv_message.

  IF gt_msg-msgid = 'VL' AND gt_msg-msgnr = '311'.
    gv_error = ' '. gv_result = '00'.
  ELSE.
    gv_error = 'X'. gv_result = '01'.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_gi_cancel_go
*&---------------------------------------------------------------------*
FORM data_gi_cancel_go  TABLES   pt_itab STRUCTURE zgtsdsif0021
                          USING    ps_htab LIKE  zgtsdsif0020.

  DATA : gt_mesg LIKE TABLE OF mesg WITH HEADER LINE,
         s_emkpf TYPE emkpf.
  DATA : ls_likp LIKE likp.
  DATA : lv_mjahr LIKE mseg-mjahr.
  DATA : lv_budat LIKE sy-datlo.
  DATA : lv_vbeln LIKE likp-vbeln.

**

  SELECT SINGLE * INTO ls_likp FROM likp WHERE vbeln = ps_htab-vbeln.

  lv_mjahr = ls_likp-wadat_ist+0(4).
  lv_budat = ls_likp-wadat_ist.
  lv_vbeln = ls_likp-vbeln.

  TRY.
      CALL FUNCTION 'WS_REVERSE_GOODS_ISSUE'
        EXPORTING
          i_vbeln                   = lv_vbeln     "납품번호
          i_budat                   = lv_budat            "전기일
          i_tcode                   = 'VL09'
          i_vbtyp                   = 'J'     " ' J' LIKP에서 select
          i_mjahr                   = lv_mjahr
          i_simulate                = ' '
          i_spe_confirm_central     = ' '
        IMPORTING
          es_emkpf                  = s_emkpf
        TABLES
          t_mesg                    = gt_mesg
        EXCEPTIONS
          error_reverse_goods_issue = 1
          OTHERS                    = 2.
    CATCH cx_root INTO DATA(lo_err).
      gv_message =  lo_err->get_longtext( ) .
  ENDTRY.

  IF s_emkpf-mblnr IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    gv_result = '01'.
    gv_error = 'X'.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    gv_result  = '00'.
    gv_message = '취소성공'.
  ENDIF.

**

ENDFORM.

*&---------------------------------------------------------------------*
*& Form link_info_update_go
*&---------------------------------------------------------------------*
FORM link_info_update_go  TABLES   pt_itab  STRUCTURE zgtsdsif0021
                          USING    ps_htab  LIKE zgtsdsif0020.

  DATA: lv_seqno    TYPE zgtppsif0044-seqno,
        lv_werks    TYPE werks_d,
        lv_upd_type TYPE zgteupd_type,

        lt_data     TYPE TABLE OF zgtppsif0044,
        lt_return   TYPE TABLE OF zgtppsif0045.

**
  CHECK: gv_error IS INITIAL.
  CHECK: ps_htab-reqtyp = 'U'  OR    " 피킹 혹은 출고전기
         ps_htab-reqtyp = 'CP'.      " UnPicking
*         ps_htab-reqtyp = 'C'.       " 출고전기 취소

* 가온전선 여부 확인.
*  SELECT SINGLE @abap_true  INTO @DATA(lv_flg)
*    FROM vbak  WHERE vbeln EQ @ps_htab-vbeln
*                 AND vkorg EQ '6000'.
*
*  CHECK: lv_flg IS NOT INITIAL.
  LOOP AT pt_itab ASSIGNING FIELD-SYMBOL(<fs_itab>).
    IF <fs_itab>-matnr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input        = <fs_itab>-matnr
        IMPORTING
          output       = <fs_itab>-matnr
        EXCEPTIONS
          length_error = 1
          OTHERS       = 2.
    ENDIF.
  ENDLOOP.

  DATA(lt_itab) = pt_itab[].

* 1) 꼬리표번호 추출
*  SELECT a~vbeln, a~posnr, a~werks, b~tagnr
*    FROM @lt_itab AS a  INNER JOIN zppt0001 AS b
*                        ON  a~matnr EQ b~matnr
*                        AND a~charg EQ b~charg
*   ORDER BY b~tagnr, a~vbeln, a~posnr
*   INTO TABLE @DATA(lt_item).

* 정조장인 경우에만 PP모듈 FM을 통해 판매오더 재고로 이전전기
* 단, 이미 판매오더 재고로 존재하는 Batch 재고는 제외
  SELECT b~tagnr,
         c~vgbel AS vbeln, c~vgpos AS posnr,
         a~werks
    FROM @lt_itab AS a INNER JOIN zppt0001 AS b
                       ON a~matnr = b~matnr AND
                          a~charg = b~charg AND
                          a~werks = b~werks
                       INNER JOIN zgtsd_i_dlvqty_factor_base AS c
                       ON a~vbeln = c~vbeln AND
                          a~posnr = c~posnr_vl
                       INNER JOIN vbap AS d
                       ON c~vgbel = d~vbeln AND
                          c~vgpos = d~posnr
   WHERE ( d~mvgr3 EQ 'X' OR d~mvgr3 EQ 'Y' ) "정조장: X , 부분정조장: Y
     AND NOT EXISTS ( SELECT matnr
                        FROM mska AS m
                       WHERE b~matnr EQ m~matnr
                         AND b~charg EQ m~charg
                         AND b~werks EQ m~werks
                         AND d~vbeln EQ m~vbeln
                         AND d~posnr EQ m~posnr
                         AND m~kalab GT 0 )
    ORDER BY vbeln, posnr, tagnr
    INTO TABLE @DATA(lt_item).

  IF lt_item[] IS NOT INITIAL.

    CLEAR: lv_werks, lv_upd_type.
    IF     ps_htab-reqtyp = 'U'.    " 피킹 혹은 출고전기
      lv_upd_type = 'U3'.
    ELSEIF ps_htab-reqtyp = 'CP'.   " UnPicking
*    ELSEIF ps_htab-reqtyp = 'C'.    " 출고전기 취소
      lv_upd_type = 'Z3'.
    ENDIF.

    _clear: lt_data.
    CLEAR: lv_seqno.
    LOOP AT lt_item  INTO DATA(ls_item).

      lv_werks = ls_item-werks.

      lv_seqno = lv_seqno + 1.
      APPEND VALUE #( seqno = lv_seqno
                      vbeln = ls_item-vbeln
                      posnr = ls_item-posnr
                      budat = sy-datlo
                      tagnr = ls_item-tagnr
                     ) TO lt_data.
    ENDLOOP.

    _clear: lt_return.
    CALL FUNCTION 'ZGTPP_LINK_INFO_UPDATE'
      EXPORTING
        i_werks    = lv_werks
        i_upd_type = lv_upd_type
*       I_UPDRQ    =
      TABLES
        it_item    = lt_data
        ot_return  = lt_return.

  ENDIF.

**
  FREE: lt_itab, lt_item, lt_data, lt_return.

ENDFORM.
