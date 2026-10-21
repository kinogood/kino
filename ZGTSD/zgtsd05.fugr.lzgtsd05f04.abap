*----------------------------------------------------------------------*
***INCLUDE LZGTSD05F04.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SAVE_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_ITAB_H
*&      --> IT_ITAB_I
*&      --> P_
*&---------------------------------------------------------------------*
FORM save_log  TABLES   pt_htab STRUCTURE zgtsdsif0020
                        pt_itab STRUCTURE zgtsdsif0021
               USING    pv_value1
                        pv_system LIKE zgtsdt1020-zsystem_id
                        pv_stamp LIKE zgtsdt1020-zifkey.
  DATA : lv_seq LIKE zgtsdt1020-zseq.

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


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_ITAB_H
*&      --> IT_ITAB_I
*&---------------------------------------------------------------------*
FORM data_check  TABLES    pt_htab STRUCTURE zgtsdsif0020
                        pt_itab STRUCTURE zgtsdsif0021.

*1) 필수값 입력 여부 점검
  CHECK gv_error = ' '.
  PERFORM check_man_field TABLES pt_htab pt_itab.

*2) 입력값 점검
  CHECK gv_error = ' '.
  PERFORM check_value TABLES pt_htab pt_itab..

*3) 요청유형에 따른 상태 점검
  CHECK gv_error = ' '.
  PERFORM check_status TABLES  pt_htab pt_itab..

*4) lock 점검
  CHECK gv_error = ' '.
  PERFORM check_lock TABLES pt_htab pt_itab...

ENDFORM.
FORM get_fieldinfo  TABLES   pt_fieldinfo STRUCTURE dfies
                    USING    p_table.
  DATA  : lv_ddobjname TYPE ddobjname.

  DATA : lv_langu LIKE sy-langu VALUE 'KO'.

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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MAN_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HTAB
*&      --> PT_HTAB
*&---------------------------------------------------------------------*
FORM check_man_field  TABLES   pt_htab STRUCTURE zgtsdsif0020
                        pt_itab STRUCTURE zgtsdsif0021.

  DATA: lt_fieldinfo TYPE TABLE OF dfies,
        ls_fieldinfo TYPE dfies.
  FIELD-SYMBOLS: <fs_field> TYPE any.
  DATA : lv_string TYPE string.
  DATA : ls_head LIKE pt_htab.
  DATA : ls_item LIKE pt_itab.
  DATA : lv_matnr TYPE matnr18.

*--- 헤더 필드 점검
  PERFORM get_fieldinfo TABLES lt_fieldinfo USING 'ZGTSDSIF0020'.
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
        PERFORM make_error_message USING ls_fieldinfo-fieldname.
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
    PERFORM get_fieldinfo TABLES lt_fieldinfo USING 'ZGTSDSIF0021'.
    DELETE lt_fieldinfo WHERE fieldname = 'CHARG'.


    LOOP AT lt_fieldinfo INTO ls_fieldinfo.
      LOOP AT pt_itab ASSIGNING FIELD-SYMBOL(<fs_wa2>).
        ASSIGN COMPONENT ls_fieldinfo-fieldname OF STRUCTURE <fs_wa2> TO <fs_field>.
        IF <fs_field> IS INITIAL.
          PERFORM make_error_message USING ls_fieldinfo-fieldname.
        ENDIF.
      ENDLOOP.
      IF gv_error = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFORM.
FORM make_error_message USING i_field_name TYPE dfies-fieldname .
  CONCATENATE 'Field value missing :' i_field_name INTO gv_message.
  gv_error = 'X'. gv_result = '01'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HTAB
*&      --> PT_ITAB
*&---------------------------------------------------------------------*
FORM check_value  TABLES   pt_htab STRUCTURE zgtsdsif0020
                        pt_itab STRUCTURE zgtsdsif0021.

  DATA : lv_posnr LIKE lips-posnr.
  DATA : lv_matnr TYPE matnr18.
  DATA : lv_batch.

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
      PERFORM check_closing USING pt_htab-wadat_ist.
    ENDIF.
    IF gv_error = 'X'.      EXIT.    ENDIF.
    IF pt_htab-route IS NOT INITIAL.
      PERFORM check_route USING pt_htab-route.
    ENDIF.
    IF gv_error = 'X'.      EXIT.    ENDIF.

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
      PERFORM check_matnr_batch_using USING pt_itab-matnr pt_itab-werks lv_batch .
      IF lv_batch = 'X' AND pt_itab-charg IS INITIAL.
        gv_error = 'X'.  gv_result = '01'.
        CONCATENATE '(I/CHARG)배치사용자재의 배치번호 누락-' pt_itab-matnr INTO gv_message.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CLOSING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HTAB_WADAT_IST
*&---------------------------------------------------------------------*
FORM check_closing  USING    pwadat_ist LIKE sy-datum.
  DATA : ls_marv LIKE marv.
  SELECT SINGLE *
    INTO ls_marv
    FROM marv
    WHERE bukrs = '1000'.

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



ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_route
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HTAB_ROUTE
*&---------------------------------------------------------------------*
FORM check_route  USING    p_route.

  SELECT SINGLE mandt
    INTO sy-mandt
    FROM tvro
    WHERE route = p_route.

  IF sy-subrc <> 0 .
    CONCATENATE '(H/ROUTE)존재하지 않은 운송경로-' p_route INTO gv_message.
    gv_error = 'X'. gv_result = '01'.
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HTAB
*&      --> PT_ITAB
*&---------------------------------------------------------------------*
FORM check_status  TABLES  pt_htab STRUCTURE zgtsdsif0020
                        pt_itab STRUCTURE zgtsdsif0021.

  DATA: lv_wbstk LIKE likp-wbstk.
  DATA : lv_cnt TYPE n LENGTH 3.

  SELECT SINGLE wbstk
    INTO lv_wbstk
    FROM likp
    WHERE vbeln = pt_htab-vbeln.

*___테이블 라인수 점검
  lv_cnt = lines( pt_htab ).

  IF lv_cnt > 1.
    CONCATENATE '납품문서 1건만 처리가 가능 합니다.'  ' ' INTO gv_message.
    gv_error = 'X'. gv_result = '01'.
    EXIT.
  ELSEIF lv_cnt < 1.
    CONCATENATE '헤더정보가 존재하지 않습니다.'  ' ' INTO gv_message.
    gv_error = 'X'. gv_result = '01'.
    EXIT.
  ENDIF.

  lv_cnt = lines( pt_itab ).
  IF lv_cnt < 1.
    CONCATENATE '아이템정보가가 존재하지 않습니다.' ' 'INTO gv_message.
    gv_error = 'X'. gv_result = '01'.
    EXIT.
  ENDIF.

  READ TABLE pt_htab INDEX 1.
*___ 출고전기
  IF pt_htab-reqtyp = 'UG'.
    IF lv_wbstk = 'C'.
      CONCATENATE '(H/REQTYP)출고전기가 완료된 납품문서-' pt_htab-vbeln INTO gv_message.
      gv_error = 'X'. gv_result = '01'.
      EXIT.
    ENDIF.

    IF pt_htab-wadat_ist IS INITIAL.
      CONCATENATE '(H/WADAT_IST)출고전기일이 누락된 납품문서-' pt_htab-vbeln INTO gv_message.
      gv_error = 'X'. gv_result = '01'.
      EXIT.
    ENDIF.
  ENDIF.

*___ 취소요청
  IF pt_htab-reqtyp = 'C'.
    "출고전기여부 점검
    IF lv_wbstk <> 'C'.
      CONCATENATE '(H/REQTYP)출고가 되지 않은 납품문서입니다-' pt_htab-vbeln INTO gv_message.
      gv_error = 'X'. gv_result = '01'.
      EXIT.
    ENDIF.

    "빌링점검
    SELECT SINGLE rk~mandt
      INTO sy-mandt
      FROM vbrk AS rk
      INNER JOIN vbrp AS rp
        ON rk~vbeln EQ rp~vbeln
      WHERE rp~vgbel = pt_htab-vbeln
      AND rk~sfakn = ' '
      AND rk~fksto = ' '.
    IF sy-subrc = 0 .
      CONCATENATE '매출처리가 완료되어 삭제가 불가능 합니다.-' pt_htab-vbeln INTO gv_message.
      gv_error = 'X'. gv_result = '01'.
      EXIT.
    ENDIF.

    "거래명세서 발행여부 점검
    SELECT SINGLE i~mandt
      INTO sy-mandt
      FROM zlet0006 AS i
      INNER JOIN zlet0005 AS h
        ON i~iv_no EQ h~iv_no
      WHERE i~vbeln = pt_htab-vbeln
      AND h~iv_cancel_yn = ' '. " 취소되지않은
    IF sy-subrc = 0 .
      CONCATENATE '통문증이 발행되어 삭제가 불가능 합니다.-' pt_htab-vbeln INTO gv_message.
      gv_error = 'X'. gv_result = '01'.
      EXIT.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_lock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_HTAB
*&      --> PT_ITAB
*&---------------------------------------------------------------------*
FORM check_lock  TABLES    pt_htab STRUCTURE zgtsdsif0020
                        pt_itab STRUCTURE zgtsdsif0021.
  DATA  : lv_lock(1).
  LOOP AT pt_htab.
    PERFORM enqueue_read USING lv_lock pt_htab-vbeln.
    IF lv_lock = 'X'.
      CONCATENATE '다른사용자가 변경중인 문서입니다.-' pt_htab-vbeln INTO gv_message.
      gv_error = 'X'. gv_result = '01'.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.

FORM enqueue_read  USING pv_lock pv_vbeln.
  DATA : lv_vbeln LIKE likp-vbeln.
  DATA : it_enq   LIKE TABLE OF seqg3 WITH HEADER LINE,
         i_number LIKE sy-tabix,
         i_subrc  LIKE sy-subrc.
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_PROCESSING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_ITAB_H
*&      --> IT_ITAB_I
*&---------------------------------------------------------------------*
FORM data_processing  TABLES   pt_htab STRUCTURE zgtsdsif0020
                        pt_itab STRUCTURE zgtsdsif0021.


  DATA : ls_htab LIKE zgtsdsif0020.

  CHECK gv_error = ' '.

  READ TABLE pt_htab INDEX 1 INTO ls_htab.

  "피킹 혹은 출고전기
  IF ls_htab-reqtyp = 'U' OR ls_htab-reqtyp = 'UG'.
    PERFORM data_picking_and_gi TABLES  pt_itab USING ls_htab..
  ENDIF.

  IF ls_htab-reqtyp = 'CP'.
    PERFORM data_unpicking TABLES  pt_itab USING ls_htab..
  ENDIF.
  "출고전기 취소
  IF ls_htab-reqtyp = 'C' .
    PERFORM data_gi_cancel TABLES  pt_itab USING ls_htab..
  ENDIF.

ENDFORM.

FORM bdc_dynpro_processing  USING     dynbegin name value.
  IF dynbegin = 'X'.
    CLEAR bdc_tab.
    MOVE : name  TO bdc_tab-program,
           value TO bdc_tab-dynpro,
           'X'   TO bdc_tab-dynbegin.
    APPEND bdc_tab.
  ELSE.
    CLEAR bdc_tab.
    MOVE : name  TO bdc_tab-fnam,
           value TO bdc_tab-fval.
    APPEND bdc_tab.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_PICKING_AND_GI
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ITAB
*&      --> LS_HTAB
*&---------------------------------------------------------------------*
FORM data_picking_and_gi  TABLES   pt_itab STRUCTURE zgtsdsif0021
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
    PERFORM check_matnr_batch_using USING pt_itab-matnr pt_itab-werks lv_batch .

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
        .
        PERFORM bdc_dynpro_processing USING:
                     'X'   'SAPMV50A'           '1000',
                     ' '   'BDC_OKCODE'         '/00',
                     ' '   'LIPSD-G_LFIMG(01)'    lfsum. "납품수량

        PERFORM bdc_dynpro_processing USING:
                     'X'   'SAPMV50A'           '1000',
                     ' '   'BDC_OKCODE'         '/00',
                     ' '   'LIPSD-PIKMG(01)'    lfsum. "피킹수량
      ENDIF.
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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MATNR_BATCH_USING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ITAB_MATNR
*&      --> LV_BATCH
*&---------------------------------------------------------------------*
FORM check_matnr_batch_using  USING    pv_matnr pv_werks
                                       pv_xchpf.

  DATA : lv_matnr TYPE matnr18.

  lv_matnr = |{ pv_matnr ALPHA = IN }|.

  SELECT SINGLE xchpf
    INTO pv_xchpf
    FROM marc
    WHERE matnr = lv_matnr
    AND werks = pv_werks.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_GI_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ITAB
*&      --> LS_HTAB
*&---------------------------------------------------------------------*
FORM data_gi_cancel   TABLES   pt_itab STRUCTURE zgtsdsif0021
                          USING    ps_htab LIKE  zgtsdsif0020.

  DATA : gt_mesg LIKE TABLE OF mesg WITH HEADER LINE,
         s_emkpf TYPE emkpf.
  DATA : ls_likp LIKE likp.
  DATA : lv_mjahr LIKE mseg-mjahr.
  DATA : lv_budat LIKE sy-datlo.
  DATA : lv_vbeln LIKE likp-vbeln.

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


ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_UNpicking
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PT_ITAB
*&      --> LS_HTAB
*&---------------------------------------------------------------------*
FORM data_unpicking  TABLES   pt_itab STRUCTURE zgtsdsif0021
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
    PERFORM check_matnr_batch_using USING pt_itab-matnr pt_itab-werks lv_batch .

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


ENDFORM.
