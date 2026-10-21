*----------------------------------------------------------------------*
***INCLUDE LZGTPP01F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form conversion_input
*&---------------------------------------------------------------------*
FORM conversion_input USING ps_issue TYPE zgtppt3070
                                                  pv_mode.

  IF pv_mode = 'P' OR  "투입
     pv_mode = 'F'.    "[GO01]

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ps_issue-aufnr
      IMPORTING
        output = ps_issue-aufnr.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = ps_issue-matnr
      IMPORTING
        output = ps_issue-matnr.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input  = ps_issue-meins
      IMPORTING
        output = ps_issue-meins.

  ELSEIF pv_mode = 'C' OR pv_mode = 'R' "취소 or 재처리
      OR pv_mode = 'RC' "재처리 취소 2024.12.30
      OR pv_mode = 'FC'. "[GO01]

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ps_issue-aufnr
      IMPORTING
        output = ps_issue-aufnr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ps_issue-mblnr
      IMPORTING
        output = ps_issue-mblnr.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = ps_issue-matnr
      IMPORTING
        output = ps_issue-matnr.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input  = ps_issue-meins
      IMPORTING
        output = ps_issue-meins.

    CALL FUNCTION 'CONVERSION_EXIT_GJAHR_INPUT'
      EXPORTING
        input  = ps_issue-mjahr
      IMPORTING
        output = ps_issue-mjahr.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_common_issue
*&---------------------------------------------------------------------*
FORM check_common_issue USING ps_issue TYPE zgtppt3070
                              pv_error
                              pv_mode  TYPE char02.

  DATA : lv_message(220).
  DATA : lv_mode(2).

*- 플랜트
  SELECT SINGLE mandt
   FROM t001w
   WHERE werks = @ps_issue-werks
   INTO @sy-mandt.

  IF sy-subrc <> 0.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e47
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.

*- 생산오더 번호
  SELECT SINGLE mandt
    FROM aufk
    WHERE aufnr = @ps_issue-aufnr
    INTO @sy-mandt.

  IF sy-subrc <> 0.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e48
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.

*- 자재 번호
  SELECT matnr
    INTO TABLE @DATA(lt_marc)
    FROM marc
    WHERE werks = @ps_issue-werks
     AND  matnr = @ps_issue-matnr
     AND lvorm <> 'X'.

  IF lt_marc IS INITIAL.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e49
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.

*- 출고수량
  IF ps_issue-menge <= 0.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e50
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.

*- 저장 위치
  IF ps_issue-lgort IS INITIAL.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e51
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.

*- 출고단위
  IF ps_issue-meins IS INITIAL.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e52
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.

*- 생산오더 상태
  PERFORM get_status USING ps_issue
                           pv_error.

  IF pv_error = 'X'.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e53
                                       '  '
                                       '  '.
  ENDIF.

*- 꼬리표 체크
  IF ps_issue-tagnr IS NOT INITIAL AND ps_issue-zup_tagnr IS INITIAL.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e73
                                       '  '
                                       '  '.
  ENDIF.

* 2024.12.30
  IF pv_mode = 'RC' AND ps_issue-org_zserno IS INITIAL.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e74
                                       '  '
                                       '  '.
  ENDIF.

*- 25.09.29 Strart 생산오더 Lock 점검 추가
  PERFORM check_prodordconf_create_lock2
                                   USING  ps_issue-aufnr
                                          pv_error
                                          lv_message
                                          ps_issue-matnr
                                          'GI'.              "GI
  IF pv_error = 'X'.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       lv_message
                                       '  '
                                       '  '.
  ENDIF.
*- 25.09.29 End 생산오더 Lock 점검 추가

*- GO02 Start GAON WIP 생산오더 관련 Validation
  SELECT SINGLE wipst
    FROM zgtppt4150
   WHERE werks EQ @ps_issue-werks
     AND aufnr EQ @ps_issue-aufnr
    INTO @DATA(lv_wipst).

  IF lv_wipst EQ 'W'.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       'WIP 처리중 오더이기 때문에 투입 처리를 할 수 없습니다.'
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- GO02 End GAON WIP 생산오더 관련 Validation

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RETURN_MESSAGE_ISSUE
*&---------------------------------------------------------------------*
FORM return_message_issue USING ps_issue TYPE zgtppt3070
                                                           pv_result
                                                           pv_message
                                                           pv_document
                                                           pv_year.

  DATA : lv_result,
         lv_message(100),
         lv_document     TYPE bapi2017_gm_head_ret-mat_doc,
         lv_year         TYPE bapi2017_gm_head_ret-doc_year.

  CLEAR : lv_result, lv_message, lv_document, lv_year.

  lv_result   = pv_result.
  lv_message  = pv_message.
  lv_document = pv_document.
  lv_year     = pv_year.

  gt_gi_result = VALUE #( BASE gt_gi_result
                        ( zserno             = ps_issue-zserno
                          mjahr                = lv_year     "BAPI에서 리턴된 자재 문서 년도
                          mblnr                = lv_document "BAPI에서 리턴된 자재 문서
                          zerp_stat          = lv_result
                          zerp_message = lv_message ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_STATUS
*&---------------------------------------------------------------------*
FORM get_status USING ps_issue TYPE zgtppt3070
                                       pv_error.

  DATA : lv_line  TYPE bsvx-sttxt,
         lv_objnr TYPE jest-objnr.

  DATA : BEGIN OF ls_line,
           line TYPE bsvx-sttxt,
         END OF ls_line,
         lt_line LIKE TABLE OF ls_line.

  CLEAR : lv_objnr, lv_line, ls_line, lt_line.
*- 오더 상태 펑션
  lv_objnr = |OR{ ps_issue-aufnr }|.

  CALL FUNCTION 'STATUS_TEXT_EDIT'
    EXPORTING
      objnr            = lv_objnr
      only_active      = 'X'
      spras            = sy-langu
    IMPORTING
      line             = lv_line "오더상태
    EXCEPTIONS
      object_not_found = 1
      OTHERS           = 2.
*- 오더상태는 CRTD/TECO/DLF 중 일치하는 것이 있으면 에러처리.
  IF sy-subrc = 0.

    SPLIT lv_line AT ' ' INTO TABLE lt_line.

    LOOP AT lt_line INTO ls_line WHERE line IS NOT INITIAL.

      IF ls_line-line = 'CRTD' OR
         ls_line-line = 'TECO' OR
         ls_line-line = 'DLF'.

        pv_error = 'X'.
        EXIT.

      ELSE.
        CLEAR ls_line.
        CONTINUE.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_log_zgtppt3070
*&---------------------------------------------------------------------*
FORM save_log_zgtppt3070 USING ps_issue TYPE zgtppt3070
                                                 pv_system_id TYPE char04
                                                 pv_mode TYPE char02.

  DATA : ls_zgtppt3070 TYPE zgtppt3070.
  DATA : lv_timestamp TYPE timestampl.

  CLEAR : lv_timestamp.
  GET TIME STAMP FIELD lv_timestamp.
  ls_zgtppt3070 = VALUE #( zifkey       = lv_timestamp
                           zsystem_id   = pv_system_id
                           zserno       = ps_issue-zserno
                           i_mode       = pv_mode
                           werks        = ps_issue-werks
                           budat        = ps_issue-budat
                           rsnum        = ps_issue-rsnum
                           rspos        = ps_issue-rspos
                           matnr        = ps_issue-matnr
                           charg        = ps_issue-charg
                           aufnr        = ps_issue-aufnr
                           bwart        = ps_issue-bwart
                           menge        = ps_issue-menge
                           meins        = ps_issue-meins
                           lgort        = ps_issue-lgort
                           tagnr        = ps_issue-tagnr
                           zup_tagnr    = ps_issue-zup_tagnr
                           mjahr        = VALUE #( gt_gi_result[ zserno = ps_issue-zserno ]-mjahr OPTIONAL )
                           mblnr        = VALUE #( gt_gi_result[ zserno = ps_issue-zserno ]-mblnr OPTIONAL )
                           pernr        = ps_issue-pernr
                           name         = ps_issue-name
                           zc_mjahr     = ps_issue-mjahr
                           zc_mblnr     = ps_issue-mblnr
                           org_zserno   = ps_issue-org_zserno "2024.12.30
                           zerp_stat    = VALUE #( gt_gi_result[ zserno = ps_issue-zserno ]-zerp_stat OPTIONAL )
                           zerp_message = VALUE #( gt_gi_result[ zserno = ps_issue-zserno ]-zerp_message OPTIONAL )
                           ifdat        = sy-datum
                           iftim        = sy-uzeit
                           ifnam        = sy-uname ).

  IF ls_zgtppt3070 IS NOT INITIAL.
    MODIFY zgtppt3070 FROM ls_zgtppt3070.
    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.
  ENDIF.

* ZO_RESULT, ZO_MESSAGE 업데이트를 위한 키필드 반영
  CLEAR gs_gi_keys.
  MOVE-CORRESPONDING ls_zgtppt3070 TO gs_gi_keys.
  APPEND gs_gi_keys TO gt_gi_keys.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_issue
*&---------------------------------------------------------------------*
FORM check_input_issue USING ps_issue TYPE zgtppt3070
                             pv_error
                             pv_system_id TYPE char04
                             pv_i_mode TYPE char02.

  DATA : lv_menge TYPE ekpo-menge,
         lv_xchpf TYPE marc-xchpf.

  CLEAR : lv_menge, gs_stock2, gt_stock2.

  IF pv_i_mode NE 'A'.
*- 품목 (RSEB의 품목번호 가져오기)
    PERFORM get_rseb USING ps_issue pv_error.

    IF pv_error = 'X'.
      pv_error = 'E'. "RESB 오류는 에러 리턴하되 ZGTPPT3100에 업데이트 X
      EXIT.
    ENDIF.
  ENDIF.

*- 재고수량  확인 (배치데이터 유/무에 따라 분리 조회)
  CLEAR : gv_menge, gv_meins.
** 배치번호가 존재하는 경우
* 자재마스터의 배치 관리 지시자로 판단
  CLEAR lv_xchpf.
  SELECT SINGLE xchpf
    INTO lv_xchpf
    FROM marc
   WHERE werks EQ ps_issue-werks
     AND matnr EQ ps_issue-matnr.
*  IF ps_issue-charg <> ' '.
  IF lv_xchpf = 'X'.
    IF pv_i_mode = 'P' OR pv_i_mode = 'A' OR
      ( pv_i_mode = 'R' AND ps_issue-charg IS NOT INITIAL ).
      PERFORM get_mchb USING ps_issue pv_error.
* 투입모드 R일때, I/F 수신받은 배치번호가 없는 경우,
* 신규 로직 구성하여 전기일자 기준 오름차순 추출
    ELSEIF pv_i_mode = 'R' AND ps_issue-charg IS INITIAL.
      PERFORM get_mchb2 USING ps_issue pv_error.
    ENDIF.
* 배치번호가 존재하지 않는 경우
*  ELSEIF ps_issue-charg = ' '.
  ELSEIF lv_xchpf = ' '.
    PERFORM get_mard USING ps_issue pv_error.
  ENDIF.

*- 단위가 다를 시, 단위 환산/수량 Conversion
  IF pv_i_mode = 'R' AND ps_issue-charg IS INITIAL.
    CLEAR gs_stock2.
    READ TABLE gt_stock2 INTO gs_stock2 INDEX 1.
    IF gs_stock2-meins IS INITIAL OR
      ( ps_issue-meins = gs_stock2-meins ).
      gv_menge = lv_menge = ps_issue-menge.
      gv_meins = ps_issue-meins.
    ELSE." ps_issue-meins <> gs_stock2-meins.

      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          i_matnr              = ps_issue-matnr
          i_in_me              = ps_issue-meins
          i_out_me             = gs_stock2-meins
          i_menge              = ps_issue-menge
        IMPORTING
          e_menge              = lv_menge
        EXCEPTIONS
          error_in_application = 1
          error                = 2
          OTHERS               = 3.

*// Modified by ZGODEV06 on 2026-05-14 {
*      gv_menge = lv_menge.
*      gv_meins = gs_stock2-meins.
*
      IF pv_system_id EQ 'KGPM' OR pv_system_id EQ 'KGOM'.
        gv_menge = ps_issue-menge.
        gv_meins = ps_issue-meins.
      ELSE.
        gv_menge = lv_menge.
        gv_meins = gs_stock2-meins.
      ENDIF.
*// }
    ENDIF.
  ELSE.
    IF gs_stock-meins IS INITIAL OR
      ( ps_issue-meins = gs_stock-meins ).
      gv_menge = lv_menge = ps_issue-menge.
      gv_meins = ps_issue-meins.
    ELSE. "IF ps_issue-meins <> gs_stock-meins.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          i_matnr              = ps_issue-matnr
          i_in_me              = ps_issue-meins
          i_out_me             = gs_stock-meins
          i_menge              = ps_issue-menge
        IMPORTING
          e_menge              = lv_menge
        EXCEPTIONS
          error_in_application = 1
          error                = 2
          OTHERS               = 3.

*// Modified by ZGODEV06 on 2026-05-14 {
*      gv_menge = lv_menge.
*      gv_meins = gs_stock-meins.

      IF pv_system_id EQ 'KGPM' OR pv_system_id EQ 'KGOM'.
        gv_menge = ps_issue-menge.
        gv_meins = ps_issue-meins.
      ELSE.
        gv_menge = lv_menge.
        gv_meins = gs_stock-meins.
      ENDIF.
*// }
    ENDIF.

*- 수량 체크
    IF gs_stock-clabs < lv_menge.
      PERFORM return_message_issue USING ps_issue
                                         'E'
                                         TEXT-e59
                                         '  '
                                         '  '.
      pv_error = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_rseb
*&---------------------------------------------------------------------*
FORM get_rseb USING ps_issue TYPE zgtppt3070
                                     pv_error.

  DATA : ls_resb TYPE resb.

  CLEAR  ls_resb.
  SELECT SINGLE rsnum, rspos, rgekz, kzkup, schgt, xloek
    INTO CORRESPONDING FIELDS OF @ls_resb
    FROM resb
    WHERE werks = @ps_issue-werks
     AND aufnr = @ps_issue-aufnr
     AND matnr = @ps_issue-matnr
     AND rsnum = @ps_issue-rsnum
     AND rspos = @ps_issue-rspos
*     AND rgekz EQ @space "백플러쉬 지시자
*     AND kzkup EQ @space "연산품 지시자
*     AND schgt EQ @space "벌크자재 지시자
*     AND kzear EQ @space "최종출고 완료 지시자
*     AND xloek EQ @space "삭제 지시자
     AND bwart = '261'. "자재출고
* 제대로 취합했을 경우 백플러쉬, 연산품, 벌크 자재, 삭제 여부 체크
  IF ls_resb IS NOT INITIAL.
* 백플러쉬 지시자 체크 되어있으면 에러
    IF ls_resb-rgekz = 'X'.

      PERFORM return_message_issue USING ps_issue
                                         'E'
                                         TEXT-e54
                                         '  '
                                         '  '.
      pv_error = 'X'.
* 연산품 지시자 체크 되어있으면 에러
    ELSEIF ls_resb-kzkup = 'X'.

      PERFORM return_message_issue USING ps_issue
                                         'E'
                                         TEXT-e55
                                         '  '
                                         '  '.
      pv_error = 'X'.
* 벌크자재 지시자 체크 되어있으면 에러
    ELSEIF ls_resb-schgt = 'X'.

      PERFORM return_message_issue USING ps_issue
                                         'E'
                                         TEXT-e56
                                         '  '
                                         '  '.
      pv_error = 'X'.
* 삭제 지시자 체크 되어있으면 에러
    ELSEIF ls_resb-xloek = 'X'.

      PERFORM return_message_issue USING ps_issue
                                         'E'
                                         TEXT-e57
                                         '  '
                                         '  '.
      pv_error = 'X'.
* 앞서 체크한 케이스에서 걸리는 게 없으면 예약번호와 예약 품목 번호 반영
    ELSE.

      ps_issue-rsnum = ls_resb-rsnum.
      ps_issue-rspos = ls_resb-rspos.

    ENDIF.
* 데이터를 취합하지 못 하면 에러메시지 리턴
  ELSE.

    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e58
                                       '  '
                                       '  '.
    pv_error = 'X'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mchb
*&---------------------------------------------------------------------*
FORM get_mchb USING ps_issue TYPE zgtppt3070
                                      pv_error.

  CLEAR gs_stock.
  SELECT SINGLE
        a~aufnr,
        b~werks,
        c~matnr,
        b~rgekz, "백플러시
        c~lgort, "저장위치
        c~charg, "배치번호
        c~clabs "평가된 가용 재고
    FROM aufk AS a
    INNER JOIN marc AS b
         ON a~werks = b~werks
    INNER JOIN mchb AS c
         ON b~matnr = c~matnr
        AND b~werks = c~werks
    WHERE a~aufnr = @ps_issue-aufnr  "생산오더 번호
     AND  b~matnr = @ps_issue-matnr  "자재 번호
     AND  b~xchpf = 'X'              "플랜트의 배치 관리 필요 지시자
     AND  c~lgort = @ps_issue-lgort  "저장 위치
     AND  c~charg = @ps_issue-charg  "배치 번호
     AND  c~lvorm = ' '              "배치 재고의 모든 데이터에 대한 삭제 표시
    INTO CORRESPONDING FIELDS OF @gs_stock.
* MCHB에서 배치 재고 정보 취합 실패 시 MSKA에서 추가로 재고 취합
  IF gs_stock IS INITIAL.

*    SELECT SINGLE strgr INTO @DATA(lv_strgr) FROM marc
*                                          WHERE werks EQ @ps_issue-werks
*                                               AND matnr EQ @ps_issue-matnr.
*    IF lv_strgr EQ '20'.

    SELECT SINGLE
          a~aufnr,
          b~werks,
          c~matnr,
          b~rgekz, "백플러시
          c~lgort, "저장위치
          c~charg, "배치번호
          c~kalab AS clabs "평가된 가용 재고
      FROM aufk AS a
      INNER JOIN marc AS b
           ON a~werks = b~werks
      INNER JOIN mska AS c
           ON b~matnr = c~matnr
         AND b~werks = c~werks
     WHERE a~aufnr = @ps_issue-aufnr  "생산오더 번호
      AND  b~matnr = @ps_issue-matnr  "자재 번호
      AND  b~xchpf = 'X'              "플랜트의 배치 관리 필요 지시자
      AND  c~lgort = @ps_issue-lgort  "저장 위치
      AND  c~charg = @ps_issue-charg  "배치 번호
      INTO CORRESPONDING FIELDS OF @gs_stock.

*    ENDIF.

  ENDIF.

  SELECT SINGLE meins
    INTO @gs_stock-meins
    FROM mara
   WHERE matnr = @ps_issue-matnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mard
*&---------------------------------------------------------------------*
FORM get_mard USING ps_issue TYPE zgtppt3070
                                     pv_error.

  CLEAR gs_stock.
  SELECT SINGLE
         a~aufnr,
         b~werks,
         c~matnr,
         b~rgekz,
         c~lgort,
         c~labst AS clabs "평가된 가용 재고
*         D~MEINS
    FROM aufk AS a
    INNER JOIN marc AS b
         ON a~werks = b~werks
    INNER JOIN mard AS c
         ON b~matnr = c~matnr
        AND b~werks = c~werks
    WHERE a~aufnr = @ps_issue-aufnr
     AND  b~matnr = @ps_issue-matnr
     AND  b~xchpf = ' '
     AND  c~lgort = @ps_issue-lgort
     AND  c~lvorm = ' '
    INTO CORRESPONDING FIELDS OF @gs_stock.

  SELECT SINGLE meins
    INTO @gs_stock-meins
    FROM mara
   WHERE matnr = @ps_issue-matnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_goodsmvt_create
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_create USING ps_issue TYPE zgtppt3070
                                pv_system_id TYPE char04
                                pv_mode TYPE char02.

  DATA : ls_header   TYPE bapi2017_gm_head_01,
         lv_code     TYPE bapi2017_gm_code VALUE '03',
         lv_document TYPE bapi2017_gm_head_ret-mat_doc,
         lv_year     TYPE bapi2017_gm_head_ret-doc_year,
         lv_message  TYPE bapiret2-message,
         lt_item     TYPE TABLE OF bapi2017_gm_item_create,
         ls_item     TYPE bapi2017_gm_item_create,
         lt_return   TYPE TABLE OF bapiret2.

  DATA : lv_menge  LIKE gv_menge,
         lv_menge2 LIKE gv_menge, "I/F 받은 수량
         lv_menge3 LIKE gv_menge. "배치 N 건 처리 수량

  DATA : ls_mska LIKE mska.

  DATA: lv_budat TYPE budat. "GO03(+)

*- GO03 Start GAON 전기일 설정
  CLEAR: lv_budat.
  IF gv_gaon EQ abap_true.
    PERFORM set_budat USING ps_issue-aufnr ps_issue-budat.
    lv_budat = gv_budat.
  ELSE.
    lv_budat = ps_issue-budat.
  ENDIF.
*- GO03 End GAON 전기일 설정

  CLEAR : lv_message, lv_document, lv_year, lt_return, gs_batch, gt_batch,
          lv_menge2, lv_menge3.

  "[GO01] 20260629 꼬리표 잔량 2m 이하이면 전체수량 투입
  IF pv_mode EQ 'P' AND ps_issue-werks EQ '6500'.
    PERFORM set_tagnr_remain_cal USING ps_issue gv_menge gv_meins.
  ENDIF.
  "[GO01] 20260629

* 투입 단위와 생산 오더 예약 정보 단위가 다를 수 있으므로 한번 더 체크 및 환산
  IF pv_mode NE 'C' AND pv_mode NE 'A'.
    PERFORM convert_menge_check_resb USING ps_issue gv_menge gv_meins.
  ENDIF.

*** Start 2025.08.14 Edit ***
  CLEAR : gv_hd_text.
  IF ps_issue-werks = 1306.
    gv_hd_text = 'ACC GI'.      "Busduct
  ELSE.
    gv_hd_text = 'MES I/F'.
  ENDIF.

  ls_header = VALUE #( pstng_date = lv_budat "PS_ISSUE-BUDAT "수신 받은 전기일 "GO03(+)
                       doc_date   = lv_budat "PS_ISSUE-BUDAT "수신 받은 전기일 "GO03(+)
                       pr_uname   = sy-uname       "사용자 이름
                       header_txt = gv_hd_text ).  "20250814 EDIT
*** End 2025.08.14 Edit ***

  IF pv_mode = 'P'. "투입.
* I/F 수신 배치 데이터가 판매오더 재고일 수 있으므로, MSKA 확인 후 존재 시 판매오더 정보 반영
    PERFORM get_data_mska USING ps_issue-matnr ps_issue-werks
                                ps_issue-lgort ps_issue-charg
                       CHANGING ls_mska.

    lt_item = VALUE #( ( material  = ps_issue-matnr  "수신 받은 출고자재
                         plant     = ps_issue-werks  "수신 받은 플랜트
                         stge_loc  = ps_issue-lgort  "수신 받은 출고 창고
                         batch     = ps_issue-charg  "수신 받은 배치번호
                         move_type = '261'           "이동유형
                         stck_type = 'F'             "재고유형
                         entry_qnt = gv_menge  "수신 받은 출고 수량( 단위 변환 로직의 수량 반영 )
                         entry_uom = gv_meins  "수신 받은 출고 단위( 단위 변환 로직의 단위 반영 )
                         orderid   = ps_issue-aufnr  "수신 받은 오더번호
                         reserv_no = ps_issue-rsnum  "RESB에서 추출한 예약번호
                         res_item  = ps_issue-rspos  "RESB에서 추출한 예약품목번호
                         spec_stock = ls_mska-sobkz "MSKA에서 추출한 SOBKZ
                         val_sales_ord = ls_mska-vbeln "MSKA에서 추출한 VBELN
                         val_s_ord_item = ls_mska-posnr ) ). "MSKA에서 추출한 POSNR

  ELSEIF pv_mode = 'A'. "// 대체투입.
    lt_item = VALUE #( ( material  = ps_issue-matnr  "수신 받은 출고자재
                         plant     = ps_issue-werks  "수신 받은 플랜트
                         stge_loc  = ps_issue-lgort  "수신 받은 출고 창고
                         batch     = ps_issue-charg  "수신 받은 배치번호
                         move_type = '261'           "이동유형
                         stck_type = 'F'             "재고유형
                         entry_qnt = gv_menge  "수신 받은 출고 수량( 단위 변환 로직의 수량 반영 )
                         entry_uom = gv_meins  "수신 받은 출고 단위( 단위 변환 로직의 단위 반영 )
                         orderid   = ps_issue-aufnr ) ). "수신 받은 오더번호
  ELSEIF pv_mode = 'R'. "재처리
    lv_menge2 = gv_menge.
* 수신 받은 배치번호가 없을 경우
    IF gt_stock2[] IS NOT INITIAL.
      LOOP AT gt_stock2 INTO gs_stock2.
* 재고 단위가 다를 경우 RESB 단위 기준으로 변환 후 계산하도록 할 것.
        IF gv_meins NE gs_stock2-meins.
          CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
            EXPORTING
              i_matnr              = ps_issue-matnr
              i_in_me              = gs_stock2-meins
              i_out_me             = gv_meins
              i_menge              = gs_stock2-clabs
            IMPORTING
              e_menge              = gs_stock2-clabs
            EXCEPTIONS
              error_in_application = 1
              error                = 2
              OTHERS               = 3.
        ENDIF.

        CLEAR lv_menge.
        IF gv_menge > gs_stock2-clabs.
          lv_menge = gs_stock2-clabs.
          gv_menge = gv_menge - lv_menge.
        ELSE.
          lv_menge = gv_menge.
          CLEAR gv_menge.
        ENDIF.

* I/F 수신 배치 데이터가 판매오더 재고일 수 있으므로, MSKA 확인 후 존재 시 판매오더 정보 반영
        PERFORM get_data_mska USING ps_issue-matnr ps_issue-werks
                                    ps_issue-lgort gs_stock2-charg
                           CHANGING ls_mska.

        APPEND INITIAL LINE TO lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).
        <ls_item> = VALUE #( material   = ps_issue-matnr  "수신 받은 출고자재
                             plant      = ps_issue-werks  "수신 받은 플랜트
                             stge_loc   = ps_issue-lgort  "수신 받은 출고 창고
                             batch      = gs_stock2-charg  "수신 받은 배치번호
                             move_type  = '261'           "이동유형
                             stck_type  = 'F'             "재고유형
                             entry_qnt  = lv_menge  "수신 받은 출고 수량( 단위 변환 로직의 수량 반영 )
                             entry_uom  = gv_meins  "수신 받은 출고 단위( 단위 변환 로직의 단위 반영 )
                             orderid    = ps_issue-aufnr  "수신 받은 오더번호
                             reserv_no  = ps_issue-rsnum  "RESB에서 추출한 예약번호
                             res_item   = ps_issue-rspos "RESB에서 추출한 예약품목번호
                             spec_stock = ls_mska-sobkz "MSKA에서 추출한 SOBKZ
                             val_sales_ord = ls_mska-vbeln "MSKA에서 추출한 VBELN
                             val_s_ord_item = ls_mska-posnr ). "MSKA에서 추출한 POSNR

        gs_batch-charg = gs_stock2-charg.
        gs_batch-menge = lv_menge.
        APPEND gs_batch TO gt_batch.

        lv_menge3 = lv_menge3 + lv_menge.

        IF gv_menge = 0.
          EXIT.
        ENDIF.
      ENDLOOP.
* 수신 받은 배치번호가 있을 경우
    ELSE.
* I/F 수신 배치 데이터가 판매오더 재고일 수 있으므로, MSKA 확인 후 존재 시 판매오더 정보 반영
      PERFORM get_data_mska USING ps_issue-matnr ps_issue-werks
                                  ps_issue-lgort ps_issue-charg
                         CHANGING ls_mska.

      lv_menge3 = gv_menge.

      lt_item = VALUE #( ( material  = ps_issue-matnr  "수신 받은 출고자재
                           plant     = ps_issue-werks  "수신 받은 플랜트
                           stge_loc  = ps_issue-lgort  "수신 받은 출고 창고
                           batch     = ps_issue-charg  "수신 받은 배치번호
                           move_type = '261'           "이동유형
                           stck_type = 'F'             "재고유형
                           entry_qnt = gv_menge  "수신 받은 출고 수량( 단위 변환 로직의 수량 반영 )
                           entry_uom = gv_meins  "수신 받은 출고 단위( 단위 변환 로직의 단위 반영 )
                           orderid   = ps_issue-aufnr  "수신 받은 오더번호
                           reserv_no = ps_issue-rsnum  "RESB에서 추출한 예약번호
                           res_item  = ps_issue-rspos "RESB에서 추출한 예약품목번호
                           spec_stock = ls_mska-sobkz "MSKA에서 추출한 SOBKZ
                           val_sales_ord = ls_mska-vbeln "MSKA에서 추출한 VBELN
                           val_s_ord_item = ls_mska-posnr ) ). "MSKA에서 추출한 POSNR
    ENDIF.
  ELSEIF pv_mode = 'C'. "부분취소
    IF ps_issue-mblnr IS INITIAL AND
       ps_issue-mjahr IS INITIAL AND
       ps_issue-rspos IS INITIAL.

      lt_item = VALUE #( ( material   = ps_issue-matnr  "수신 받은 출고 자재
                           plant      = ps_issue-werks  "수신 받은 플랜트
                           stge_loc   = ps_issue-lgort  "수신 받은 출고 창고
                           batch      = ps_issue-charg "수신 받은 배치 번호
                           move_type  = '262'           "이동유형
                           stck_type  = ' ' "재고유형
                           entry_qnt  = gv_menge  "수신 받은 출고 수량( 단위 변환 로직의 수량 반영 )
                           entry_uom  = gv_meins  "수신 받은 출고 단위( 단위 변환 로직의 단위 반영 )
                           orderid    = ps_issue-aufnr  "생산오더
                           reserv_no  = ' '             "예약번호
                           res_item   = ' '             "예액번호 품목
                           xstob      = ' ' ) ).        "역분개이동유형 지시자 사용
    ELSEIF ps_issue-mblnr IS INITIAL AND
           ps_issue-mjahr IS INITIAL AND
           ps_issue-rspos IS NOT INITIAL.

      lt_item = VALUE #( ( material   = ps_issue-matnr  "수신 받은 출고 자재
                           plant      = ps_issue-werks  "수신 받은 플랜트
                           stge_loc   = ps_issue-lgort  "수신 받은 출고 창고
                           batch      = ps_issue-charg "수신 받은 배치 번호
                           move_type  = '262'           "이동유형
                           stck_type  = ' ' "재고유형
                           entry_qnt  = gv_menge  "수신 받은 출고 수량( 단위 변환 로직의 수량 반영 )
                           entry_uom  = gv_meins  "수신 받은 출고 단위( 단위 변환 로직의 단위 반영 )
                           orderid    = ps_issue-aufnr  "생산오더
                           reserv_no  = ps_issue-rsnum  "예약번호
                           res_item   = ps_issue-rspos  "예액번호 품목
                           xstob      = 'X' ) ).        "역분개이동유형 지시자 사용
    ENDIF.
  ENDIF.

*- 투입 처리 (펑션 호출)
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_header
      goodsmvt_code    = lv_code
    IMPORTING
      materialdocument = lv_document
      matdocumentyear  = lv_year
    TABLES
      goodsmvt_item    = lt_item
      return           = lt_return.

*- 실패
  IF line_exists( lt_return[ type = 'E' ] ).
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
* 자재 투입 or 자재 투입 취소 로그 데이터 저장(ZGTPPT3070)
    IF pv_mode = 'P' OR pv_mode = 'A' OR pv_mode = 'C'.
      lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
      IF lv_message IS INITIAL AND ( pv_mode = 'P' OR pv_mode = 'A' ).
        lv_message = TEXT-e60.
      ELSEIF lv_message IS INITIAL AND pv_mode = 'C'.
        lv_message = TEXT-e71.
      ENDIF.

      PERFORM return_message_issue USING ps_issue
                                        'E'
                                        lv_message
                                        lv_document
                                        lv_year.

      PERFORM save_log_zgtppt3070 USING ps_issue pv_system_id pv_mode.
* 자재 투입 재처리 로그 데이터 저장(ZGTPPT3100)
    ELSEIF pv_mode = 'R'.
*      lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
*      IF lv_message IS INITIAL. "메시지 없을 경우 "투입 처리 실패" 메시지 반영
*        lv_message = TEXT-e60.
*      ENDIF.

*      PERFORM return_message_issue USING ps_issue
*                                        'E'
*                                        lv_message
*                                        lv_document
*                                        lv_year.
* 처리 실패시에는 투입된 배치 수량이 없으므로 배치 수량 정보 및 투입 수량 CLEAR.
      CLEAR : gt_batch, gv_menge.

      lv_message = TEXT-e61. "ZGTPPT3100엔 메시지 별도 반영
      PERFORM return_message_issue USING ps_issue
                                        'S'
                                        lv_message
                                        lv_document
                                        lv_year.

      PERFORM save_log_zgtppt3070 USING ps_issue pv_system_id pv_mode.
      PERFORM save_log_zgtppt3100 USING ps_issue pv_system_id pv_mode.
    ENDIF.
  ELSE.
*- 성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    lv_message = VALUE #( lt_return[ type = 'S' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      IF pv_mode = 'P' OR  pv_mode = 'A'.
        lv_message = TEXT-s09.
      ELSEIF pv_mode = 'R'.                                 "20241230
        IF lv_menge2 = lv_menge3.
          lv_message = TEXT-s17.
        ELSE.
          CONCATENATE TEXT-s18 ps_issue-zserno TEXT-s19
                        INTO lv_message SEPARATED BY space.
        ENDIF.
      ELSEIF pv_mode = 'C'.
        lv_message = TEXT-s12.
      ENDIF.
    ENDIF.

    PERFORM return_message_issue USING ps_issue
                                       'S'
                                       lv_message
                                       lv_document
                                       lv_year.
*- Start 2025.01.31 부스닥트 건은 배치 특성과 꼬리표 업데이트를 수행하지 않음.
    IF pv_system_id NE 'KBDM'.
*- 배치 특성 업데이트
      PERFORM update_batch_values USING ps_issue
                                                           pv_system_id
                                                           pv_mode
                                                           lv_document
                                                           lv_year.
*- 꼬리표 추적 데이터 생성 및 업데이트
      PERFORM create_tagnr USING ps_issue
                                 pv_mode
                                 lv_document
                                 lv_year.

    ENDIF.

*- End 2025.01.31
*- 자재 투입 로그 데이터 저장(ZGTPPT3070)
    PERFORM save_log_zgtppt3070 USING ps_issue pv_system_id pv_mode.

    IF pv_mode = 'R'.
      PERFORM save_log_zgtppt3100 USING ps_issue pv_system_id pv_mode.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_log_zgtppt3100
*&---------------------------------------------------------------------*
FORM save_log_zgtppt3100 USING ps_issue TYPE zgtppt3070
                                                       pv_system_id TYPE char04
                                                       pv_i_mode TYPE char02.

  DATA : ls_zgtppt3100 TYPE zgtppt3100.
  DATA : lv_aufnr   LIKE ps_issue-aufnr,
         lv_weblnr  LIKE affw-weblnr,
         lv_weblpos LIKE affw-weblpos,
         lv_dispo   LIKE marc-dispo,
         lv_matnr   LIKE marc-matnr,
         lv_msgv4   LIKE zgtppt3100-msgv4.
  DATA : lv_menge(16),
             lv_menge2 LIKE gs_batch-menge.

  lv_menge2 = ps_issue-menge.
  IF gt_batch[] IS NOT INITIAL.
    LOOP AT gt_batch INTO gs_batch.
      lv_menge2 = lv_menge2 - gs_batch-menge.
    ENDLOOP.
  ELSE.
    lv_menge2 = lv_menge2 - gv_menge.
  ENDIF.
*  lv_menge = lv_menge2.
  WRITE lv_menge2 TO lv_menge UNIT gv_meins.
  REPLACE ALL OCCURRENCES OF ',' IN lv_menge WITH ''.
  CONDENSE lv_menge NO-GAPS.

  IF lv_menge > 0.
* 오류포함 자재이동의 문서수
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ps_issue-aufnr
      IMPORTING
        output = lv_aufnr.
    CONCATENATE 'M' lv_aufnr INTO lv_weblnr.
* 내부카운터
    SELECT SINGLE MAX( weblpos ) INTO @lv_weblpos
                                                          FROM zgtppt3100
                                                          WHERE weblnr EQ @lv_weblnr.
    IF lv_weblpos IS INITIAL.
      lv_weblpos = 1.
    ELSE.
      lv_weblpos = lv_weblpos + 1.
    ENDIF.
* MRP 관리자
    SELECT SINGLE dispo INTO lv_dispo FROM marc
                                         WHERE werks EQ ps_issue-werks
                                              AND matnr EQ ps_issue-matnr.
* 메시지 변수 04
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = ps_issue-matnr
      IMPORTING
        output = lv_matnr.

    CONCATENATE lv_matnr ps_issue-werks ps_issue-lgort INTO lv_msgv4
    SEPARATED BY space.

    ls_zgtppt3100 = VALUE #( weblnr = lv_weblnr
                             weblpos     = lv_weblpos
                             zserno       = ps_issue-zserno
                             zsystem_id = pv_system_id
                             matnr          = ps_issue-matnr
                             werks         = ps_issue-werks
                             lgort            = ps_issue-lgort
                             charg         = ps_issue-charg
                             dispo          = lv_dispo
                             msgid         = 'M7'
                             msgno        = '021'
                             msgty         = 'E'
                             msgv1       = TEXT-m03
                             msgv2       = lv_menge
                             msgv3       = ps_issue-meins
                             msgv4       = lv_msgv4
                             ersda         = sy-datum
                             fwzet          = sy-uzeit
                             ernam        = ps_issue-pernr
                             laeda         = sy-datum
                             aenam       = ps_issue-pernr
                             bwart         = '261'
                             erfmg        = lv_menge
                             erfme        = ps_issue-meins
                             aufnr         = ps_issue-aufnr
                             tagnr          = ps_issue-tagnr
                             zup_tagnr   = ps_issue-zup_tagnr
                             rsnum       = ps_issue-rsnum
                             rspos        = ps_issue-rspos
                             budat        = ps_issue-budat
                             crdat         = sy-datum
                             crtim         = sy-uzeit
                             crnam      = sy-uname
                             chdat         = sy-datum
                             chtim         = sy-uzeit
                             chnam      = sy-uname ).

    IF ls_zgtppt3100 IS NOT INITIAL.
      MODIFY zgtppt3100 FROM ls_zgtppt3100.
      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_batch_values
*&---------------------------------------------------------------------*
FORM update_batch_values USING ps_issue TYPE zgtppt3070
                                                pv_system_id TYPE char04
                                                pv_mode TYPE char02
                                                pv_document
                                                pv_year.

  DATA : lv_charg    TYPE bapi2017_gm_item_show-batch,
         lv_document TYPE bapi2017_gm_head_02-mat_doc,
         lv_year     TYPE bapi2017_gm_head_02-doc_year,
         lt_item     TYPE TABLE OF bapi2017_gm_item_show,
         lt_return   TYPE TABLE OF bapiret2.

  CLEAR : lv_document, lv_year, lt_return, lt_item, lv_charg.
  lv_document = pv_document.
  lv_year     = pv_year.
*- 배치 번호
  WAIT UP TO '0.3' SECONDS.
  CALL FUNCTION 'BAPI_GOODSMVT_GETDETAIL'
    EXPORTING
      materialdocument = lv_document "BAPI 리턴된 자재문서
      matdocumentyear  = lv_year     "BAPI 리턴되 자재문서 년도
    TABLES
      goodsmvt_items   = lt_item
      return           = lt_return.

  IF gt_stock2[] IS INITIAL.

    lv_charg = VALUE #( lt_item[ 1 ]-batch OPTIONAL ).

    CHECK lv_charg IS NOT INITIAL.

    PERFORM update_char TABLES lt_item lt_return
                                          USING   ps_issue pv_system_id pv_mode lv_charg.

  ELSE.

    LOOP AT lt_item INTO DATA(ls_item).

      lv_charg = ls_item-batch.

      CHECK lv_charg IS NOT INITIAL.

      PERFORM update_char TABLES lt_item lt_return
                                            USING   ps_issue pv_system_id pv_mode lv_charg.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_tagnr
*&---------------------------------------------------------------------*
FORM create_tagnr USING ps_issue TYPE zgtppt3070
                                     p_mode
                                     pv_document
                                     pv_year.

  CLEAR : gv_charg, gv_menge2.
* SRM2405-07266 2024.05.23 입고-투입 꼬리표 미관리, 꼬리표 잔량 업데이트 수정
* ZPPT0001에 입고 꼬리표 존재 여부 확인
* 투입 취소 나 재처리 취소 때는 꼬리표 업데이트 기준 자재 문서를 I/F 수신 받은 자재 문서로 업데이트
* 투입 처리 나 재처리 때는 처리완료된 전표로 업데이트하므로 아래 IF문을 안 타도 됨.
  IF p_mode = 'C' OR p_mode = 'RC'.
    pv_document = ps_issue-mblnr. pv_year = ps_issue-mjahr.
  ENDIF.

  IF gt_batch[] IS NOT INITIAL.

    LOOP AT gt_batch INTO gs_batch.
      gv_charg = gs_batch-charg.
      gv_menge2 = gs_batch-menge.
      PERFORM update_tagnr USING ps_issue p_mode pv_document pv_year.
    ENDLOOP.

  ELSE.

    gv_charg = ps_issue-charg.
    gv_menge2 = gv_menge.
    PERFORM update_tagnr USING ps_issue p_mode pv_document pv_year.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_cancel_issue
*&---------------------------------------------------------------------*
FORM check_cancel_issue USING ps_issue TYPE zgtppt3070
                                               pv_error.

  DATA : lv_menge TYPE ekpo-menge,
         lv_sum   TYPE aufm-menge.
  CLEAR : lv_menge, lv_sum.

  CLEAR gs_stock-meins.
  SELECT SINGLE meins
    INTO @gs_stock-meins
    FROM mara
   WHERE matnr = @ps_issue-matnr.
*- 출고 최소 수량과 기 투입된 수량 비교 체크
  CLEAR : gv_menge, gv_meins.
  IF ps_issue-meins <> gs_stock-meins.
    CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
      EXPORTING
        i_matnr              = ps_issue-matnr
        i_in_me              = ps_issue-meins
        i_out_me             = gs_stock-meins
        i_menge              = ps_issue-menge
      IMPORTING
        e_menge              = lv_menge
      EXCEPTIONS
        error_in_application = 1
        error                = 2
        OTHERS               = 3.
    gv_menge = lv_menge.
    gv_meins  = gs_stock-meins.
  ELSE.
    gv_menge = lv_menge = ps_issue-menge.
    gv_meins = ps_issue-meins.
  ENDIF.

  SELECT aufnr,
         matnr,
         bwart,
         charg,
         CASE bwart WHEN '262'  THEN ( abs( menge ) * -1 )
                    ELSE menge
         END AS menge
    INTO TABLE @DATA(lt_aufm)
    FROM aufm
    WHERE aufnr = @ps_issue-aufnr
     AND  ( bwart = '261' OR bwart = '262' )
     AND  werks = @ps_issue-werks
     AND  matnr = @ps_issue-matnr
     AND  charg = @ps_issue-charg.

  LOOP AT lt_aufm INTO DATA(ls_data) GROUP BY ( aufnr = ls_data-aufnr
                                                matnr = ls_data-matnr
                                                charg = ls_data-charg ).

    CLEAR lv_sum.
    LOOP AT GROUP ls_data INTO DATA(ls_aufm).
      lv_sum = lv_sum + ls_aufm-menge.
    ENDLOOP.

    IF lv_menge > lv_sum.

      PERFORM return_message_issue USING ps_issue
                                      'E'
                                      TEXT-e68
                                      '  '
                                      '  '.
      pv_error = 'X'.
      EXIT.

    ENDIF.

  ENDLOOP.
*- 자재 문서 존재 여부 확인
  IF ps_issue-mjahr IS NOT INITIAL AND
     ps_issue-mblnr IS NOT INITIAL.

    SELECT bwart,
           rsnum,
           rspos
        INTO TABLE @DATA(lt_mseg)
        FROM mseg
        WHERE mblnr = @ps_issue-mblnr
         AND  mjahr = @ps_issue-mjahr
         AND  bwart = '261'
         AND  aufnr = @ps_issue-aufnr.

    IF lt_mseg IS INITIAL.

      PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e69
                                       '  '
                                       '  '.
      pv_error = 'X'.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_goodsmvt_cancel
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_cancel USING ps_issue TYPE zgtppt3070
                                                   pv_system_id TYPE char04
                                                   pv_mode TYPE char02.
*- Start 2024.12.30
  IF pv_mode = 'RC'.
*- 투입 취소
    IF ps_issue-mblnr IS NOT INITIAL AND
       ps_issue-mjahr IS NOT INITIAL.

      PERFORM bapi_cancel USING ps_issue pv_system_id pv_mode.

    ENDIF.
*  실투입 오류 재처리( ZGTPPT3101 )건 자재문서 취소 프로세스는 무조건 태움
    PERFORM bapi_cancel_org_zserno USING ps_issue pv_system_id pv_mode.
*- End 2024.12.30
  ELSE.
*- 투입 취소
    IF ps_issue-mblnr IS NOT INITIAL AND
       ps_issue-mjahr IS NOT INITIAL.

      PERFORM bapi_cancel USING ps_issue pv_system_id pv_mode.
*- 부분 투입 취소
    ELSEIF ps_issue-mblnr IS INITIAL AND
           ps_issue-mjahr IS INITIAL AND
           ps_issue-rspos IS INITIAL.

      PERFORM bapi_goodsmvt_create USING ps_issue pv_system_id pv_mode.

    ELSEIF ps_issue-mblnr IS INITIAL AND
           ps_issue-mjahr IS INITIAL AND
           ps_issue-rspos IS NOT INITIAL.

      SELECT SINGLE rsnum, rspos
        INTO @DATA(ls_resb)
        FROM resb
        WHERE werks = @ps_issue-werks
             AND aufnr = @ps_issue-aufnr
             AND matnr = @ps_issue-matnr
             AND rsnum = @ps_issue-rsnum
             AND rspos = @ps_issue-rspos
             AND rgekz EQ @space "백플러쉬 지시자
             AND kzkup EQ @space "연산품 지시자
             AND schgt EQ @space "벌크자재 지시자
             AND kzear EQ @space "최종출고 완료 지시자
             AND xloek EQ @space "삭제 지시자
             AND  bwart = '261'. "자재출고

      IF ls_resb IS NOT INITIAL.
        ps_issue-rsnum = ls_resb-rsnum.
        ps_issue-rspos = ls_resb-rspos.
      ENDIF.

      PERFORM bapi_goodsmvt_create USING ps_issue pv_system_id pv_mode.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_cancel
*&---------------------------------------------------------------------*
FORM bapi_cancel USING ps_issue TYPE zgtppt3070
                                    pv_system_id TYPE char04
                                    pv_mode TYPE char02.

  DATA : ls_headret    TYPE bapi2017_gm_head_ret,
         lt_return     TYPE TABLE OF bapiret2,
         lv_message    TYPE bapiret2-message,
         lv_budat_mkpf LIKE mseg-budat_mkpf.

  CLEAR : ls_headret, lt_return, lv_message, lv_budat_mkpf.
  SELECT SINGLE budat_mkpf INTO @lv_budat_mkpf
      FROM mseg
      WHERE mblnr = @ps_issue-mblnr
       AND  mjahr = @ps_issue-mjahr
       AND  bwart = '261'
       AND  aufnr = @ps_issue-aufnr.


*** Start 2025.08.14 Edit ***
  CLEAR : gv_hd_text.
  IF ps_issue-werks = 1306.
    gv_hd_text = 'ACC GI'.      "Busduct
  ELSE.
    gv_hd_text = 'MES I/F'.
  ENDIF.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      materialdocument    = ps_issue-mblnr
      matdocumentyear     = ps_issue-mjahr
*     goodsmvt_pstng_date = ps_issue-budat
      goodsmvt_pstng_date = lv_budat_mkpf
      goodsmvt_pr_uname   = sy-uname
      documentheader_text = gv_hd_text      "2025.08.14 Edit
    IMPORTING
      goodsmvt_headret    = ls_headret
    TABLES
      return              = lt_return.
*** End 2025.08.14 Edit ***

*- 실패
  IF line_exists( lt_return[ type = 'E' ] ).

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-e71.
    ENDIF.

    PERFORM return_message_issue USING ps_issue
                                      'E'
                                      lv_message
                                      ls_headret-mat_doc
                                      ls_headret-doc_year.
* 자재 투입 취소 로그 데이터 저장(ZGTPPT3070)
    PERFORM save_log_zgtppt3070 USING ps_issue pv_system_id pv_mode.

  ELSE.

    gv_suc = 'X'.
*- 성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    IF pv_mode = 'C'.

      lv_message = |{ sy-datum }/{ sy-uzeit }/{ ps_issue-aufnr }/{ ps_issue-mblnr }{ TEXT-s11 }|.
      PERFORM return_message_issue USING ps_issue
                                         'S'
                                         lv_message
                                         ls_headret-mat_doc
                                         ls_headret-doc_year.

    ENDIF.
*- Start 2025.01.31 부스닥트 건은 배치 특성과 꼬리표 업데이트를 수행하지 않음.
    IF pv_system_id NE 'KBDM'.
*- 배치 특성 업데이트
      PERFORM update_batch_values USING ps_issue
                                                           pv_system_id
                                                           pv_mode
                                                           ls_headret-mat_doc
                                                           ls_headret-doc_year.
*- 꼬리표 추적 데이터 생성 및 업데이트
      PERFORM create_tagnr USING ps_issue
                                 pv_mode
                                 ls_headret-mat_doc
                                 ls_headret-doc_year.

    ENDIF.
*- End 2025.01.31
    IF pv_mode = 'C'.
* 자재 투입 취소 로그 데이터 저장(ZGTPPT3070)
      PERFORM save_log_zgtppt3070 USING ps_issue pv_system_id pv_mode.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conversion_output_gt_gi_result
*&---------------------------------------------------------------------*
FORM conversion_output_gt_gi_result .

  LOOP AT gt_gi_result INTO DATA(ls_data)
                                 WHERE mblnr IS NOT INITIAL
                                      AND mjahr IS NOT INITIAL.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_data-mblnr
      IMPORTING
        output = ls_data-mblnr.

    CALL FUNCTION 'CONVERSION_EXIT_GJAHR_OUTPUT'
      EXPORTING
        input  = ls_data-mjahr
      IMPORTING
        output = ls_data-mjahr.

    MODIFY gt_gi_result FROM ls_data.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form result_gi_data
*&---------------------------------------------------------------------*
FORM result_gi_data USING po_result po_message.

  DATA : lv_message(80),
         lv_result(2).

  CLEAR : lv_message, lv_result.
  IF gt_gi_result IS NOT INITIAL.
*- 성공 건수
    DATA(lv_cnt_s) = REDUCE i(
                     INIT sum = 0 FOR ls_cnt_s IN gt_gi_result
                     WHERE ( zerp_stat = 'S' )
                     NEXT sum = sum + 1 ).
*- 실패 건수
    DATA(lv_cnt_e) = REDUCE i(
                     INIT sum = 0 FOR ls_cnt_e IN gt_gi_result
                     WHERE ( zerp_stat = 'E' )
                     NEXT sum = sum + 1 ).
    "전체 성공
    IF lv_cnt_s IS NOT INITIAL AND
       lv_cnt_e IS INITIAL.

      lv_result = '00'.
      lv_message = |{ lv_cnt_s }{ TEXT-s08 }|.
      "전체 실패
    ELSEIF lv_cnt_s IS INITIAL AND
           lv_cnt_e IS NOT INITIAL.

      lv_result = '01'.
      lv_message = |{ lv_cnt_e }{ TEXT-e45 }|.
      "부분 성공
    ELSE.

      lv_result = '01'.
      lv_message = |{ lv_cnt_s }{ TEXT-s08 }, { lv_cnt_e }{ TEXT-e45 }|.

    ENDIF.
*- 처리 결과
    po_result  = lv_result.
    po_message = lv_message.

  ELSE.

    lv_result = '01'.
    lv_message = TEXT-e46.
*- 처리 결과
    po_result  = lv_result.
    po_message = lv_message.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_INPUT_TAB
*&---------------------------------------------------------------------*
FORM conversion_input_tab .

  IF gs_tab-i_mode = 'P'. "입고

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gs_tab-aufnr
      IMPORTING
        output = gs_tab-aufnr.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = gs_tab-posnr
      IMPORTING
        output = gs_tab-posnr.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = gs_tab-matnr
      IMPORTING
        output = gs_tab-matnr.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input  = gs_tab-meins
      IMPORTING
        output = gs_tab-meins.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input  = gs_tab-erfme
      IMPORTING
        output = gs_tab-erfme.

  ELSEIF gs_tab-i_mode = 'C'. "입고취소

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gs_tab-aufnr
      IMPORTING
        output = gs_tab-aufnr.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = gs_tab-posnr
      IMPORTING
        output = gs_tab-posnr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gs_tab-mblnr
      IMPORTING
        output = gs_tab-mblnr.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = gs_tab-matnr
      IMPORTING
        output = gs_tab-matnr.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input  = gs_tab-meins
      IMPORTING
        output = gs_tab-meins.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input  = gs_tab-erfme
      IMPORTING
        output = gs_tab-erfme.

    CALL FUNCTION 'CONVERSION_EXIT_GJAHR_INPUT'
      EXPORTING
        input  = gs_tab-mjahr
      IMPORTING
        output = gs_tab-mjahr.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_common_tab
*&---------------------------------------------------------------------*
FORM check_common_tab USING pv_error.

  DATA : lv_message(220).

* 수신받은 데이터의 WERKS가 존재하는 플랜트 인지 체크
  SELECT SINGLE mandt
   FROM t001w
   WHERE werks = @gs_tab-werks
   INTO @sy-mandt.

  IF sy-subrc <> 0.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e47
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
* 수신받은 데이터의 AUFNR이 존재하는 생산오더 인지 체크
  SELECT SINGLE mandt
   FROM aufk
   WHERE aufnr = @gs_tab-aufnr
   INTO @sy-mandt.

  IF sy-subrc <> 0.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e48
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
* 수신받은 데이터의 MATNR이 존재하는 자재번호 인지 체크
  SELECT matnr
    INTO TABLE @DATA(lt_marc)
    FROM marc
    WHERE werks = @gs_tab-werks
     AND  matnr = @gs_tab-matnr
     AND lvorm <> 'X'.

  IF lt_marc IS INITIAL.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e49
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 수신받은 데이터의 AUFNR, POSNR, MATNR이 정상적인 정보인지 정합성 체크
** 한미소 MOM 부산물 531 조건 추가
  IF gs_tab-bwart = '531'.
    SELECT SINGLE mandt
    FROM afpo
    WHERE aufnr    = @gs_tab-aufnr
         AND posnr = @gs_tab-posnr
         INTO @sy-mandt.
  ELSE.
**    한미소 MOM 부산물 조건 추가
    SELECT SINGLE mandt
      FROM afpo
      WHERE aufnr    = @gs_tab-aufnr
           AND posnr = @gs_tab-posnr
           AND matnr = @gs_tab-matnr
           INTO @sy-mandt.
  ENDIF.
  IF sy-subrc <> 0.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e62
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 입고 수량
  IF gs_tab-menge < 0.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e63
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 저장 위치
  IF gs_tab-lgort IS INITIAL.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e64
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 입고 단위
  IF gs_tab-meins IS INITIAL.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e65
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 자재 문서
  IF gs_tab-mjahr IS NOT INITIAL AND
     gs_tab-mblnr IS NOT INITIAL.

    SELECT mblnr
      INTO TABLE @DATA(lt_mseg)
      FROM mseg
      WHERE mblnr = @gs_tab-mblnr
       AND  mjahr = @gs_tab-mjahr
       AND bwart IN ( '101', '531' ) " 한미소 MOM 부산물 531 조건 추가
*       AND  bwart = '101'
       AND  matnr = @gs_tab-matnr
       AND  aufnr = @gs_tab-aufnr.

    IF lt_mseg IS INITIAL.
      PERFORM return_message_tab USING 'E'
                                       TEXT-e66
                                       '  '
                                       '  '.
      pv_error = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
*- 생산오더 상태
  PERFORM get_status_tab USING pv_error.

  IF pv_error = 'X'.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e67
                                     '  '
                                     '  '.
  ENDIF.
*- 수신 받은 데이터의 자재 코드가 배치 관리 대상일 경우 수신 받은 배치 번호가 비었는 지 체크
  SELECT SINGLE mandt INTO @sy-mandt FROM marc
                                        WHERE matnr EQ @gs_tab-matnr
                                             AND werks EQ @gs_tab-werks
                                             AND xchar EQ 'X'.
  IF sy-subrc = 0 AND gs_tab-charg IS INITIAL.
    PERFORM return_message_tab USING 'E'
                                    TEXT-e77
                                    '  '
                                    '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.

*- 25.09.29 Strart 생산오더 Lock 점검 추가
  PERFORM check_prodordconf_create_lock2
                                   USING  gs_tab-aufnr
                                               pv_error
                                               lv_message
                                               ' '
                                               ' '.

  IF pv_error = 'X'.

    PERFORM return_message_tab USING 'E'
                                       lv_message
                                       '  '
                                       '  '.
  ENDIF.
*- 25.09.29 End 생산오더 Lock 점검 추가

*- GO01 Start GAON WIP 생산오더 관련 Validation
  SELECT SINGLE wipst
    FROM zgtppt4150
   WHERE werks EQ @gs_tab-werks
     AND aufnr EQ @gs_tab-aufnr
    INTO @DATA(lv_wipst).

  IF lv_wipst EQ 'W'.
    PERFORM return_message_tab USING 'E'
                                     'WIP 처리중 오더이기 때문에 입고 처리를 할 수 없습니다.'
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- GO01 End GAON WIP 생산오더 관련 Validation

ENDFORM.
*&---------------------------------------------------------------------*
*& Form return_message_tab
*&---------------------------------------------------------------------*
FORM return_message_tab USING pv_stat
                                                  pv_message
                                                  pv_year
                                                  pv_document.

  IF pv_year IS NOT INITIAL AND pv_document IS NOT INITIAL.

    SELECT SINGLE prueflos
      FROM qals
      WHERE mjahr = @pv_year
       AND  mblnr = @pv_document
       AND  aufnr = @gs_tab-aufnr
      INTO @DATA(lv_prueflos).

  ENDIF.

  gt_tab_result = VALUE #( BASE  gt_tab_result
                         (   aufnr    = gs_tab-aufnr
                             zserno   = gs_tab-zserno
                             charg    = gs_tab-charg
                             mjahr    = pv_year
                             mblnr    = pv_document
                             prueflos = lv_prueflos
                             zerp_stat          = pv_stat
                             zerp_message = pv_message ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_status_tab
*&---------------------------------------------------------------------*
FORM get_status_tab USING    pv_error.

  DATA : lv_line  TYPE char100,
         lv_objnr TYPE jest-objnr.
  DATA : BEGIN OF ls_line,
           line TYPE char100,
         END OF ls_line,
         lt_line LIKE TABLE OF ls_line.

  CLEAR : lv_objnr, lv_line, ls_line, lt_line.
*- 오더 상태 펑션
  CALL FUNCTION 'Z_PP_ORDER_STATUS'
    EXPORTING
      i_aufnr  = gs_tab-aufnr
    IMPORTING
      e_status = lv_line.
*- 오더상태는 CRTD/TECO/DLF 중 일치하는 것이 있으면 에러처리.
  IF sy-subrc = 0.

    SPLIT lv_line AT ' ' INTO TABLE lt_line.

    LOOP AT lt_line INTO ls_line WHERE line IS NOT INITIAL.

      IF ls_line-line = 'CRTD' OR
         ls_line-line = 'TECO' OR
         ls_line-line = 'DLFL'. "2024.02.29 ZITCS4HDEV01 추가

        pv_error = 'X'.
        EXIT.

      ELSE.
        CLEAR ls_line.
        CONTINUE.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_log_zgtppt3110
*&---------------------------------------------------------------------*
FORM save_log_zgtppt3110 USING pv_stat
                                                       pv_message
                                                       pv_year
                                                       pv_document
                                                       pv_system_id TYPE char04.

  DATA : ls_zgtppt3110 TYPE zgtppt3110.
  DATA  : lv_timestamp TYPE timestampl.

  CLEAR : lv_timestamp.
  GET TIME STAMP FIELD lv_timestamp.
  IF pv_year IS NOT INITIAL AND pv_document IS NOT INITIAL.

    SELECT SINGLE prueflos
      FROM qals
      WHERE mjahr = @pv_year
       AND  mblnr = @pv_document
       AND  aufnr = @gs_tab-aufnr
      INTO @DATA(lv_prueflos).

  ENDIF.

  ls_zgtppt3110 = VALUE #( BASE CORRESPONDING #( gs_tab MAPPING
                                                                                    zc_mjahr = mjahr
                                                                                    zc_mblnr = mblnr )
                         zifkey               = lv_timestamp
                         zsystem_id      = pv_system_id
                         mjahr               = pv_year      "BAPI에서 리턴된 자재문서 년도
                         mblnr               = pv_document  "BAPI에서 리턴된 자재문서
                         zerp_stat          = pv_stat
                         zerp_message = pv_message
                         ifdat                  = sy-datum
                         iftim                   = sy-uzeit
                         ifnam                = sy-uname ).

  MODIFY zgtppt3110 FROM ls_zgtppt3110.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.
* ZO_RESULT, ZO_MESSAGE 업데이트를 위한 키필드 반영
  CLEAR gs_gr_keys.
  MOVE-CORRESPONDING ls_zgtppt3110 TO gs_gr_keys.
  APPEND gs_gr_keys TO gt_gr_keys.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_goodsmvt_create_tab
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_create_tab USING pv_system_id TYPE char04.

  DATA : lt_return TYPE TABLE OF bapiret2,
         lv_batch  LIKE bapibatchkey-batch.

  DATA : lv_factor,
         ls_attr   TYPE bapibatchatt,
         ls_ctrl   LIKE bapibatchctrl.

  DATA: lt_bats    TYPE TABLE OF zcharbats,
        lt_batvals TYPE TABLE OF zcharvals,
        lr_atnamb  TYPE TABLE OF eampic_sel_atnam.

  DATA: lv_chk.

  DATA : ls_header   TYPE bapi2017_gm_head_01,
         lv_code     TYPE bapi2017_gm_code VALUE '02',
         lv_document TYPE bapi2017_gm_head_ret-mat_doc,
         lv_year     TYPE bapi2017_gm_head_ret-doc_year,
         lv_message  TYPE bapiret2-message,
         lt_item     TYPE TABLE OF bapi2017_gm_item_create.

  DATA: lv_budat TYPE budat. "GO02(+)

  CLEAR: lt_return.
* I/F 수신받은 FOSTER 값이 존재시 진행. 없다면 바로 입고 처리
  IF gs_tab-foster IS NOT INITIAL.

    SELECT SINGLE a~mandt
      INTO @sy-mandt
      FROM mara AS a INNER JOIN marc AS b
           ON a~matnr EQ b~matnr
     WHERE a~matnr EQ @gs_tab-matnr
          AND b~werks EQ @gs_tab-werks
          AND a~kzwsm = 'B'
          AND b~dpcbt = 'A'.

    IF sy-subrc = 0.

      lv_factor = 'X'.
*- Factor 배치
      SELECT SINGLE mandt
        INTO @sy-mandt
        FROM mcha
       WHERE matnr = @gs_tab-matnr
         AND werks = @gs_tab-werks
         AND charg = @gs_tab-charg.
      IF sy-subrc <> 0.
*- 재치가 없는경우 생성
        ls_attr-statuskey = '1'.
        ls_ctrl-doclassify = 'X'.
*___클래스번호
        CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
          EXPORTING
            material       = gs_tab-matnr
            plant          = gs_tab-werks
            classtype      = '023'
          IMPORTING
            class          = ls_ctrl-class_num
          EXCEPTIONS
            no_class_found = 1
            OTHERS         = 2.

        CALL FUNCTION 'BAPI_BATCH_CREATE'
          EXPORTING
            material           = CONV matnr18( gs_tab-matnr )
            batch              = gs_tab-charg
            plant              = gs_tab-werks
            batchattributes    = ls_attr
            batchcontrolfields = ls_ctrl
*           batchstoragelocation = gs_tab-lgort
          TABLES
            return             = lt_return.
*- 실패
        IF line_exists( lt_return[ type = 'E' ] ).

          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          PERFORM return_message_tab USING 'E'
                                           TEXT-e41
                                           ' '
                                           ' '.

          PERFORM save_log_zgtppt3110 USING 'E'
                                               TEXT-e41
                                               '  '
                                               '  '
                                               pv_system_id.
          EXIT.

        ELSE.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

        ENDIF.

      ENDIF.
*- 배치 특성 업데이트
      PERFORM update_tab_batch_values USING '' '' pv_system_id 'X'.
*___배치 특성
      lr_atnamb = VALUE #( ( sign = 'I' option = 'EQ'
                             low = 'SAP_MILLCA_LENGTH' ) ). "조장
      lt_bats   = VALUE #( ( matnr = gs_tab-matnr
                             charg = gs_tab-charg ) ).

      CLEAR : lv_chk.
      DO 10 TIMES.

        CALL FUNCTION 'Z_GET_CHAR_OF_BATCH'
          EXPORTING
            ir_atnam = lr_atnamb
          TABLES
            it_bats  = lt_bats
            et_vals  = lt_batvals.

        READ TABLE lt_bats INTO DATA(wa_bats)
                           WITH KEY matnr = gs_tab-matnr
                                    charg = gs_tab-charg
                                    BINARY SEARCH.
        IF sy-subrc = 0.

          READ TABLE lt_batvals INTO DATA(wa_bvals)
                                WITH KEY objek = wa_bats-objek
                                         atnam = 'SAP_MILLCA_LENGTH'
                                         BINARY SEARCH.
          IF sy-subrc = 0.

            PERFORM check_atwrt_n_foster USING wa_bvals-atwrt
                                               gs_tab-foster
                                               lv_chk.
            IF lv_chk = 'X'.
              EXIT.
            ENDIF.

          ENDIF.

        ENDIF.

        WAIT UP TO '0.5' SECONDS.

      ENDDO.

      IF lv_chk IS INITIAL.

        PERFORM return_message_tab USING 'E'
                                         TEXT-e42
                                         ' '
                                         ' '.

        PERFORM save_log_zgtppt3110 USING 'E'
                                             TEXT-e42
                                             '  '
                                             '  '
                                             pv_system_id.
        EXIT.

      ENDIF.

    ENDIF.

  ENDIF.

  SELECT SINGLE insmk
    INTO @DATA(lv_insmk)
    FROM afpo
  WHERE aufnr EQ @gs_tab-aufnr
    AND posnr EQ @gs_tab-posnr.

*- GO02 Start GAON 전기일 설정
  CLEAR: lv_budat.
  IF gv_gaon EQ abap_true.
    PERFORM set_budat USING gs_tab-aufnr gs_tab-budat.
    lv_budat = gv_budat.
  ELSE.
    lv_budat = gs_tab-budat.
  ENDIF.
*- GO02 End GAON 전기일 설정

  CLEAR : lv_document, lv_year, lt_return, lv_message.

  ls_header = VALUE #( pstng_date = lv_budat "GS_TAB-BUDAT  "수신 받은 전기일 "GO02(+)
                       doc_date   = lv_budat "GS_TAB-BUDAT  "수신 받은 전기일 "GO02(+)
                       pr_uname   = sy-uname      "사용자 이름
                       header_txt = 'MES I/F' ).  "전표 헤더 텍스트

  lt_item = VALUE #( ( material   = gs_tab-matnr  "수신 받은 입고 자재
                       plant      = gs_tab-werks  "수신 받은 플랜트
                       stge_loc   = gs_tab-lgort  "수신 받은 입고 창고
                       batch      = gs_tab-charg  "수신 받은 배치 번호
                       move_type  = '101'         "이동유형
*** Start. 2026.07.06 Factor 배치 상관없이 M 단위로 입고 by ZGISPP03
*                       ENTRY_QNT  = COND #( WHEN LV_FACTOR = 'X' THEN GS_TAB-ERFMG
*                                                                 ELSE GS_TAB-MENGE )  "수신 받은 입고 수량
*                       ENTRY_UOM  = COND #( WHEN LV_FACTOR = 'X' THEN GS_TAB-ERFME
*                                                                 ELSE GS_TAB-MEINS )  "수신 받은 입고 단위
                       entry_qnt  = gs_tab-menge   "수신 받은 입고 수량
                       entry_uom  = gs_tab-meins   "수신 받은 입고 단위
*** End. 2026.07.06 Factor 배치 상관없이 M 단위로 입고 by ZGISPP03
                       orderid    = gs_tab-aufnr    "수신 받은 오더 번호
                       order_itno = gs_tab-posnr    "수신 받은 오더 품목 번호
*- Start 2024.12.13
                       item_text = gs_tab-tagnr     "수신받은 꼬리표
*- End 2024.12.13
                       prod_date  = gs_tab-hsdat    "제조일
                       mvt_ind    = 'F'             "이동지시자
                       stck_type  = lv_insmk   ) ). "재고유형.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_header
      goodsmvt_code    = lv_code
    IMPORTING
      materialdocument = lv_document
      matdocumentyear  = lv_year
    TABLES
      goodsmvt_item    = lt_item
      return           = lt_return.
*- 실패
  IF line_exists( lt_return[ type = 'E' ] ).

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-e43.
    ENDIF.

    PERFORM return_message_tab USING 'E'
                                     lv_message
                                     '  '
                                     '  '.

    PERFORM save_log_zgtppt3110 USING 'E'
                                          lv_message
                                          '  '
                                          '  '
                                          pv_system_id.
*- 성공
  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    lv_message = VALUE #( lt_return[ type = 'S' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-s07.
    ENDIF.

    PERFORM return_message_tab USING 'S'
                                     lv_message
                                     lv_year
                                     lv_document.

    PERFORM save_log_zgtppt3110 USING 'S'
                                         lv_message
                                         lv_year
                                         lv_document
                                         pv_system_id.

*- Start 2025.01.23 부스닥트 건은 배치와 꼬리표 업데이트 수행하지 않음.
    IF pv_system_id EQ 'KPCM' OR
       pv_system_id EQ 'KSCM' OR   "소재 MOM SRM2510-04825
       pv_system_id EQ 'KGPM' OR   "// 가온전선 MES. 2026.03.12 수정.
       pv_system_id EQ 'KGOM' OR
       PV_SYSTEM_ID EQ 'KFCM'.     "한미소 MOM 260902

      PERFORM update_tab_batch_values USING lv_year lv_document pv_system_id ''.

*- 꼬리표 생성 및 업데이트
      PERFORM create_tab_tagnr USING lv_document lv_year.
    ENDIF.
*- End 2025.01.23

*- Start 2026.07.07 입고 처리, 취소시  by ZGISPP03
**- 생산오더 전송 프로그램 호출(ZGTPPI2010)
    IF pv_system_id NE 'KPCM' AND
       pv_system_id NE 'KSCM'. " AND
*       PV_SYSTEM_ID NE 'KFCM'.     "한미소 MOM 260902.
      PERFORM gr_call_transaction_zgtppi2010 USING gs_tab-werks.
    ENDIF.
*- End 2026.07.07 입고 처리, 취소시  by ZGISPP03
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_goodsmvt_create_tab531
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_create_tab_531 USING pv_system_id TYPE char04.

  DATA : lt_return TYPE TABLE OF bapiret2,
         lv_batch  LIKE bapibatchkey-batch.

  DATA : lv_factor,
         ls_attr   TYPE bapibatchatt,
         ls_ctrl   LIKE bapibatchctrl.

  DATA: lt_bats    TYPE TABLE OF zcharbats,
        lt_batvals TYPE TABLE OF zcharvals,
        lr_atnamb  TYPE TABLE OF eampic_sel_atnam.

  DATA: lv_chk.

  DATA : ls_header   TYPE bapi2017_gm_head_01,
         lv_code     TYPE bapi2017_gm_code VALUE '06',
         lv_document TYPE bapi2017_gm_head_ret-mat_doc,
         lv_year     TYPE bapi2017_gm_head_ret-doc_year,
         lv_message  TYPE bapiret2-message,
         lt_item     TYPE TABLE OF bapi2017_gm_item_create.

  DATA: lv_budat TYPE budat. "GO02(+)

  CLEAR: lt_return.

  SELECT SINGLE insmk
    INTO @DATA(lv_insmk)
    FROM afpo
  WHERE aufnr EQ @gs_tab-aufnr
    AND posnr EQ @gs_tab-posnr.

*- GO02 Start GAON 전기일 설정
  CLEAR: lv_budat.
  IF gv_gaon EQ abap_true.
    PERFORM set_budat USING gs_tab-aufnr gs_tab-budat.
    lv_budat = gv_budat.
  ELSE.
    lv_budat = gs_tab-budat.
  ENDIF.
*- GO02 End GAON 전기일 설정

  CLEAR : lv_document, lv_year, lt_return, lv_message.

  ls_header = VALUE #( pstng_date = lv_budat "GS_TAB-BUDAT  "수신 받은 전기일 "GO02(+)
                       doc_date   = lv_budat "GS_TAB-BUDAT  "수신 받은 전기일 "GO02(+)
                       pr_uname   = sy-uname      "사용자 이름
                       header_txt = 'MES I/F' ).  "전표 헤더 텍스트

  lt_item = VALUE #( ( material   = gs_tab-matnr  "수신 받은 입고 자재
                       plant      = gs_tab-werks  "수신 받은 플랜트
                       stge_loc   = gs_tab-lgort  "수신 받은 입고 창고
                       batch      = gs_tab-charg  "수신 받은 배치 번호
                       move_type  = '531'         "이동유형
*** Start. 2026.07.06 Factor 배치 상관없이 M 단위로 입고 by ZGISPP03
*                       ENTRY_QNT  = COND #( WHEN LV_FACTOR = 'X' THEN GS_TAB-ERFMG
*                                                                 ELSE GS_TAB-MENGE )  "수신 받은 입고 수량
*                       ENTRY_UOM  = COND #( WHEN LV_FACTOR = 'X' THEN GS_TAB-ERFME
*                                                                 ELSE GS_TAB-MEINS )  "수신 받은 입고 단위
                       entry_qnt  = gs_tab-menge   "수신 받은 입고 수량
                       entry_uom  = gs_tab-meins   "수신 받은 입고 단위
*** End. 2026.07.06 Factor 배치 상관없이 M 단위로 입고 by ZGISPP03
                       orderid    = gs_tab-aufnr    "수신 받은 오더 번호
                       order_itno = gs_tab-posnr    "수신 받은 오더 품목 번호
*- Start 2024.12.13
                       item_text = gs_tab-tagnr     "수신받은 꼬리표
*- End 2024.12.13
                       prod_date  = gs_tab-hsdat    "제조일
*                       mvt_ind    = 'F'             "이동지시자
                       stck_type  = lv_insmk   ) ). "재고유형.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_header
      goodsmvt_code    = lv_code
    IMPORTING
      materialdocument = lv_document
      matdocumentyear  = lv_year
    TABLES
      goodsmvt_item    = lt_item
      return           = lt_return.
*- 실패
  IF line_exists( lt_return[ type = 'E' ] ).

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-e43.
    ENDIF.

    PERFORM return_message_tab USING 'E'
                                     lv_message
                                     '  '
                                     '  '.

    PERFORM save_log_zgtppt3110 USING 'E'
                                          lv_message
                                          '  '
                                          '  '
                                          pv_system_id.
*- 성공
  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    lv_message = VALUE #( lt_return[ type = 'S' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-s07.
    ENDIF.

    PERFORM return_message_tab USING 'S'
                                     lv_message
                                     lv_year
                                     lv_document.

    PERFORM save_log_zgtppt3110 USING 'S'
                                         lv_message
                                         lv_year
                                         lv_document
                                         pv_system_id.

*- Start 2025.01.23 부스닥트 건은 배치와 꼬리표 업데이트 수행하지 않음.
    IF pv_system_id EQ 'KPCM' OR
       pv_system_id EQ 'KSCM' OR   "소재 MOM SRM2510-04825
       pv_system_id EQ 'KGPM' OR   "// 가온전선 MES. 2026.03.12 수정.
       pv_system_id EQ 'KGOM' OR
       PV_SYSTEM_ID EQ 'KFCM'.     "한미소 MOM 260902

      PERFORM update_tab_batch_values USING lv_year lv_document pv_system_id ''.

*- 꼬리표 생성 및 업데이트
      PERFORM create_tab_tagnr USING lv_document lv_year.
    ENDIF.
*- End 2025.01.23

*- Start 2026.07.07 입고 처리, 취소시  by ZGISPP03
**- 생산오더 전송 프로그램 호출(ZGTPPI2010)
    IF pv_system_id NE 'KPCM' AND
       pv_system_id NE 'KSCM'. " AND
*       PV_SYSTEM_ID NE 'KFCM'.     "한미소 MOM 260902.
      PERFORM gr_call_transaction_zgtppi2010 USING gs_tab-werks.
    ENDIF.
*- End 2026.07.07 입고 처리, 취소시  by ZGISPP03
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_tab_batch_values
*&---------------------------------------------------------------------*
FORM update_tab_batch_values USING pv_year
                                                               pv_document
                                                               pv_system_id TYPE char04
                                                               pv_before_gi.

  DATA : lv_document TYPE bapi2017_gm_head_02-mat_doc,
         lv_year     TYPE bapi2017_gm_head_02-doc_year,
         lt_item     TYPE TABLE OF bapi2017_gm_item_show,
         lt_return   TYPE TABLE OF bapiret2,
         lv_class    TYPE klah-class,
         lv_atnam    TYPE atnam,
         lt_char     TYPE TABLE OF api_ch_att,
         lt_vali     TYPE TABLE OF api_vali,
         ls_vali     TYPE api_vali,
         lt_valnum   TYPE TABLE OF bapi1003_alloc_values_num,
         ls_valnum   TYPE bapi1003_alloc_values_num,
         lt_valchar  TYPE TABLE OF bapi1003_alloc_values_char,
         ls_valchar  TYPE bapi1003_alloc_values_char,
         lt_valcurr  TYPE TABLE OF bapi1003_alloc_values_curr,
         lv_status   TYPE bapi1003_key-status,
         lv_message  TYPE bapiret2-message.
  DATA : lt_conf LIKE TABLE OF api_value.
  DATA : lv_dpcbt LIKE marc-dpcbt,
         lv_kzwsm LIKE mara-kzwsm.

  DATA : lv_cal_menge TYPE menge_d.
  DATA : lv_cal_menge_c TYPE c LENGTH 70.

  CLEAR : lv_document, lv_year, lt_return, lt_item, lv_class, lt_vali,
          lt_char, gs_stock, lt_valnum, lv_status, lt_valchar, lt_valcurr, lv_message,
          lv_dpcbt, lv_kzwsm.

  lv_document = pv_document.
  lv_year     = pv_year.
*- 배치 번호
  CALL FUNCTION 'Z_PP_GET_CHARACTERISTIC'
    EXPORTING
      i_aufnr              = gs_tab-aufnr
      i_posnr              = '0001'
    TABLES
      t_configuration_idoc = lt_conf
    EXCEPTIONS
      instance_not_found   = 1
      invalid_data         = 2
      OTHERS               = 3.
*- CLASS 번호
  CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
    EXPORTING
      material           = gs_tab-matnr "입고자재
      plant              = gs_tab-werks "플랜트
      classtype          = '023'        "클래스유형(배치)
    IMPORTING
      class              = lv_class
    EXCEPTIONS
      no_class_found     = 1
      no_classtype_found = 2
      OTHERS             = 3.

  CHECK lv_class IS NOT INITIAL.
*- 배치특성 정보
  CALL FUNCTION 'ZQC01_BATCH_VALUES_READ'
    EXPORTING
      i_val_matnr    = gs_tab-matnr
      i_val_werks    = gs_tab-werks
      i_val_charge   = gs_tab-charg
      i_date         = sy-datum
    TABLES
      t_val_tab      = lt_vali
      t_att_tab      = lt_char
    EXCEPTIONS
      no_class       = 1
      internal_error = 2
      no_values      = 3
      no_chars       = 4
      OTHERS         = 5.

  LOOP AT lt_char INTO DATA(ls_char).

    CLEAR ls_vali.
    ls_vali = VALUE #( lt_vali[ atnam = ls_char-atnam ] OPTIONAL ).

    CASE ls_char-dtype.
      WHEN 'CHAR' OR 'DATE'.
        lt_valchar = VALUE #( BASE lt_valchar
                             ( value_char = ls_vali-atwrt
                               charact    = ls_char-atnam ) ).
      WHEN 'TIME' OR 'NUM'.
        lt_valnum = VALUE #( BASE lt_valnum
                             ( value_from = ls_vali-atflv
                               unit_from  = ls_vali-atawe
                               charact    = ls_char-atnam ) ).
    ENDCASE.

  ENDLOOP.
*- 배치 타입
  CLEAR : lv_dpcbt, lv_kzwsm.
  SELECT SINGLE kzwsm  "단위사용
    INTO @lv_kzwsm
     FROM mara
     WHERE matnr = @gs_tab-matnr.
* 단일 단위 배치 기본값
  SELECT SINGLE dpcbt INTO @lv_dpcbt FROM marc
                                        WHERE matnr = @gs_tab-matnr
                                             AND werks = @gs_tab-werks.
*- 배치 특성정보 업데이트 데이터 입력
  LOOP AT lt_char INTO ls_char.
*- 싱글 유닛 배치
    IF ( lv_dpcbt = 'B' OR  lv_dpcbt = 'C' ) AND
         lv_kzwsm = 'B'.

      IF  ls_char-atnam = 'SAP_MILLCA_LENGTH' OR
          ls_char-atnam = 'SAP_MILLCA_LENGTH_SUB'.

        CONTINUE. "싱글유닛 배치의 두개의 특성은 입/출고 수량이 자동반영됨
      ENDIF.
*- Factor 배치
    ELSEIF lv_dpcbt = 'A' AND lv_kzwsm = 'B'.

      lv_atnam = ls_char-atnam.

      IF ls_char-atnam = 'SAP_MILLCA_LENGTH_SUB'.
        lv_atnam = 'SAP_MILLCA_LENGTH'.
      ENDIF.

      IF  ls_char-atnam = 'SAP_MILLCA_LENGTH' OR
          ls_char-atnam = 'SAP_MILLCA_LENGTH_SUB'.
* 2026.06.16 추가사항 - Factor 배치의 경우, 배치 특성 "개별조장길이(기본단위)"의 값을 0으로 대입하도록 수정
* 플랜트 6500, 6600일때만 적용
        IF gs_tab-werks = '6500' OR gs_tab-werks = '6600'.
          CASE ls_char-atnam .
            WHEN 'SAP_MILLCA_LENGTH_SUB'.
              lv_cal_menge = 0.
            WHEN 'SAP_MILLCA_LENGTH'.
              CLEAR lv_cal_menge.
              CLEAR lv_cal_menge_c.

              SELECT SINGLE * FROM zpptc002
                WHERE aufnr = @gs_tab-aufnr
                  AND posnr = @gs_tab-posnr
                INTO @DATA(ls_002).
              IF sy-subrc EQ 0.
                lv_cal_menge = gs_tab-foster - ( ls_002-psamg + ls_002-psmng ).
              ELSE.
                lv_cal_menge = gs_tab-foster.
              ENDIF.
          ENDCASE.
          lv_cal_menge_c = lv_cal_menge.
          CONDENSE lv_cal_menge_c.

          ls_valnum-value_from = lv_cal_menge_c.
          MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = ls_char-atnam.
        ELSE.

          ls_valnum-value_from = gs_tab-foster.
          MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = ls_char-atnam.
        ENDIF.

      ELSEIF ls_char-atnam = 'SAP_MILLCA_PACKAGING_CAT'.

        READ TABLE lt_conf INTO DATA(ls_conf) WITH KEY atnam = lv_atnam.
        IF sy-subrc = 0.

          CLEAR ls_valnum.

          IF ls_char-dtype = 'NUM'.

            REPLACE ',' IN ls_conf-atwrt WITH ''.
            CONDENSE ls_conf-atwrt NO-GAPS.
            ls_valnum-value_from = ls_conf-atwrt.
            MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = ls_char-atnam.

          ELSE.

            ls_valchar-value_char = ls_conf-atwrt.
            MODIFY lt_valchar FROM ls_valchar TRANSPORTING value_char WHERE charact = ls_char-atnam.

          ENDIF.

        ENDIF.

      ENDIF.
*- 일반배치
    ELSE.

      IF  ls_char-atnam = 'SAP_MILLCA_LENGTH' OR
          ls_char-atnam = 'SAP_MILLCA_LENGTH_SUB'.

        SELECT SINGLE
             b~werks,
             c~matnr,
             b~rgekz, "백플러시
             c~lgort, "저장위치
             c~charg, "배치번호
             c~clabs AS menge, "평가된 가용 재고
             d~meins  "기본단위
        FROM marc AS b
        INNER JOIN mchb AS c
             ON b~matnr = c~matnr
            AND b~werks = c~werks
        INNER JOIN mara AS d
             ON b~matnr = d~matnr
       WHERE  b~werks = @gs_tab-werks
         AND  b~matnr = @gs_tab-matnr
         AND  b~xchpf = 'X'
         AND  c~lgort = @gs_tab-lgort
         AND  c~charg = @gs_tab-charg
         AND  c~lvorm = ' '
        INTO CORRESPONDING FIELDS OF @gs_stock.
        "특성값 입력(수량 - 일반배치는 입/출고시 수량 자동반영 X)
        IF ls_char-atnam = 'SAP_MILLCA_LENGTH'.

          CLEAR ls_valnum.
          ls_valnum-value_from = gs_stock-menge.
          MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = 'SAP_MILLCA_LENGTH'.

        ELSEIF ls_char-atnam = 'SAP_MILLCA_LENGTH_SUB'.

          CLEAR ls_valnum.
          ls_valnum-value_from = gs_stock-menge.
          MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = 'SAP_MILLCA_LENGTH_SUB'.

        ENDIF.

      ENDIF.

    ENDIF.

    IF pv_document IS NOT INITIAL.
*- Factor 배치
      "특성값 입력(생산일)
      IF ls_char-atnam = 'BT_AA_PROD_DATE'.

        CLEAR ls_valchar.
        ls_valchar-value_char = gs_tab-budat.
        MODIFY lt_valchar FROM ls_valchar TRANSPORTING value_char WHERE charact = 'BT_AA_PROD_DATE'.

      ENDIF.
      "특성값 입력(재고유형/양품)
      IF ls_char-atnam = 'BT_INVTYPE'.

        CLEAR ls_valchar.
        ls_valchar-value_char = 'A'.
        MODIFY lt_valchar FROM ls_valchar TRANSPORTING value_char WHERE charact = 'BT_INVTYPE'.

      ENDIF.
* 특성 항목(ATNAM)이 조장수(SAP_MILLCA_FACTOR)이면 I/F 받은 ERFMG 조장 수를 대입
      IF ls_char-atnam = 'SAP_MILLCA_FACTOR'.
*// Modified by ZGODEV06 on 2026-04-20 {
*        CLEAR ls_valnum.
*        ls_valnum-value_from = gs_tab-erfmg.
*        MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = 'SAP_MILLCA_FACTOR'.

        IF NOT ( gs_tab-werks EQ '6500' OR gs_tab-werks EQ '6600' ).
          CLEAR ls_valnum.
          ls_valnum-value_from = gs_tab-erfmg.
          MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = 'SAP_MILLCA_FACTOR'.
        ENDIF.
*// }
      ENDIF.

*SRM2510-04825 소재 MOM 추가
      IF ls_char-atnam = 'BT_AA_GRADE'.           "품질등급

        CLEAR ls_valchar.
        CONCATENATE 'X08' gs_tab-atwrt01 INTO ls_valchar-value_char SEPARATED BY space.
        MODIFY lt_valchar FROM ls_valchar TRANSPORTING value_char WHERE charact = 'BT_AA_GRADE'.

      ENDIF.

      IF ls_char-atnam = 'BT_AA_NET_WEIGHT'.           "순중량

        CLEAR ls_valnum.
        ls_valnum-value_from = gs_tab-atwrt02.
        MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = 'BT_AA_NET_WEIGHT'.

      ENDIF.

      IF ls_char-atnam = 'BT_AA_GRS_WEIGHT'.           "총중량

        CLEAR ls_valnum.
        ls_valnum-value_from = gs_tab-atwrt03.
        MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = 'BT_AA_GRS_WEIGHT'.

      ENDIF.
*SRM2510-04825
    ENDIF.

    CLEAR ls_char.

  ENDLOOP.

  CLEAR : lt_return.

  IF lt_char IS NOT INITIAL AND ( lv_dpcbt NE 'B' OR lv_dpcbt NE 'C' ).
*- 배치 특성 업데이트(펑션 호출)
    SELECT SINGLE cuobj_bm
      INTO @DATA(lv_objkey)
      FROM mch1
      WHERE matnr = @gs_tab-matnr
       AND  charg = @gs_tab-charg.

    CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
      EXPORTING
        clobjectkey         = lv_objkey
        classnum            = lv_class
      IMPORTING
        classif_status      = lv_status
      TABLES
        allocvaluesnum_new  = lt_valnum
        allocvalueschar_new = lt_valchar
        allocvaluescurr_new = lt_valcurr
        return              = lt_return.

    IF line_exists( lt_return[ type = 'E' ] ).

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
      IF lv_message IS INITIAL AND pv_before_gi IS NOT INITIAL.
        lv_message = TEXT-e72.
      ELSE.
        lv_message = TEXT-e44.
      ENDIF.
      PERFORM return_message_tab USING 'S' "에러 플래그는 입고성공인 'S'로 저장
                                       lv_message
                                       '  '
                                       '  '.

      PERFORM save_log_zgtppt3110 USING 'S'
                                           lv_message
                                           '  '
                                           '  '
                                           pv_system_id.
    ELSE.
      IF pv_system_id EQ 'KGPM' OR  "// 가온전선 MES
         pv_system_id EQ 'KGOM'.
        UPDATE mcha
           SET zzline_no     = gs_tab-atwrt01  "// 신선 Cage(층수) = 특성 01
               zzserial_info = gs_tab-atwrt02  "// 신선 차수 = 특성 02
        WHERE matnr EQ gs_tab-matnr
          AND werks EQ gs_tab-werks
          AND charg EQ gs_tab-charg.
      ENDIF.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_atwrt_n_foster
*&---------------------------------------------------------------------*
FORM check_atwrt_n_foster USING    pv_atwrt
                                    pv_foster
                                    pv_chk.

  DATA : lv_atwrt_txt(70),
         lv_foster_txt(70),
         lv_atwrt          TYPE afko-gamng,
         lv_foster         TYPE afko-gamng.

  lv_atwrt_txt = pv_atwrt.
  REPLACE ALL OCCURRENCES OF ',' IN lv_atwrt_txt WITH ''.
  lv_atwrt = lv_atwrt_txt.

  lv_foster_txt = pv_foster.
  REPLACE ALL OCCURRENCES OF ',' IN lv_foster_txt WITH ''.
  lv_foster = lv_foster_txt.

  IF lv_atwrt = lv_foster.
    pv_chk = 'X'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_tab_tagnr
*&---------------------------------------------------------------------*
FORM create_tab_tagnr USING pv_document pv_year.

  DATA : ls_object TYPE bapi_pp_order_objects,
         ls_return TYPE bapiret2,
         lt_header TYPE TABLE OF bapi_order_header1,
         ls_header TYPE bapi_order_header1,
         lt_op     TYPE TABLE OF bapi_order_operation1,
         ls_op     TYPE bapi_order_operation1.

  DATA : ls_zppt0001 TYPE zppt0001,
         ls_zppt0016 TYPE zppt0016,
         ls_zppt0017 TYPE zppt0017.

  DATA : lv_conf   TYPE zppt0001-rueck,
         lv_arbpl  TYPE zppt0001-arbpl,
         lv_vornr  TYPE zppt0001-vornr,
         lv_date   TYPE sy-datum,
         lv_time   TYPE sy-uzeit,
         lv_start  TYPE sy-datum,
         lv_finish TYPE sy-datum,
         lv_stime  TYPE sy-uzeit,
         lv_ftime  TYPE sy-uzeit.

  DATA : lv_mgvrg   LIKE zppt0001-mgvrg,
         lv_indlen  LIKE zppt0001-mgvrg,
         lv_fostcnt LIKE zppt0001-fostcnt,
         lv_procd   LIKE zppt0001-procd,
         lv_spgcd   LIKE zppt0001-spgcd,
         lv_foster  LIKE zppt0016-foster.

  DATA : lv_mara  LIKE mara-matkl,
         lv_mtart LIKE mara-mtart,
         lv_rmzhl LIKE afru-rmzhl.

  CLEAR : ls_object, ls_return, lt_header, ls_header,
          lt_op, ls_op, ls_zppt0001, ls_zppt0016, lv_mgvrg, lv_procd.
  CLEAR : lv_conf, lv_arbpl, lv_vornr, lv_date, lv_time,
          lv_start, lv_finish, lv_stime, lv_ftime   .

  ls_object = VALUE #( header = 'X'
                       operations = 'X' ).
  "GET 확정번호, 작업장
  CALL FUNCTION 'BAPI_PRODORD_GET_DETAIL'
    EXPORTING
      number        = gs_tab-aufnr
      order_objects = ls_object
    IMPORTING
      return        = ls_return
    TABLES
      header        = lt_header
      operation     = lt_op.

  IF ls_return-type = 'E'.

  ELSE.

    ls_header = VALUE #( lt_header[ 1 ] OPTIONAL ).
    ls_op     = VALUE #( lt_op[ 1 ] OPTIONAL ).

    lv_conf   = ls_op-conf_no. "LS_OP-OPERATION_NUMBER.
    lv_arbpl  = ls_op-work_center.
    lv_vornr  = ls_op-operation_number.
    lv_date   = ls_op-earl_sched_start_date_exec.
    lv_time   = ls_op-earl_sched_start_time_exec.
    lv_start  = ls_header-start_date.   "기본종료일/일자
    lv_finish = ls_header-finish_date.  "기본시작일/일자
    lv_stime  = ls_header-sched_start_time. "일정계획된시작(시간)
    lv_ftime  = ls_header-sched_fin_time.   "일정계획종료(시간)
    lv_indlen = gs_tab-foster.

    SELECT SINGLE matkl, mtart INTO ( @lv_mara, @lv_mtart )
                   FROM mara
                   WHERE matnr = @gs_tab-matnr.
* I/F 수신 받은 배치 번호가 빈 값으면, 입고 BAPI 결과 Return한 자재문서를 기준으로 배치 번호 추출
    IF gs_tab-charg IS INITIAL.

      SELECT SINGLE charg INTO @gs_tab-charg
                                        FROM mseg
                                        WHERE mblnr EQ @pv_document
                                            AND mjahr EQ @pv_year
                                            AND zeile  EQ '0001'.

    ENDIF.
* Factoer 배치 점검
    SELECT SINGLE a~mandt
                    FROM mara AS a INNER JOIN marc AS b
                        ON a~matnr EQ b~matnr
                        WHERE a~matnr EQ @gs_tab-matnr
                             AND b~werks EQ @gs_tab-werks
                             AND a~kzwsm EQ 'B'
                             AND b~dpcbt = 'A'
                             INTO @DATA(lv_mandt).
*- 꼬리표 생성/업데이트 체크
    SELECT SINGLE *
      FROM zppt0001
      WHERE werks = @gs_tab-werks
       AND  aufnr = @gs_tab-aufnr
       AND  tagnr = @gs_tab-tagnr
       AND  charg = @gs_tab-charg
       AND  matnr = @gs_tab-matnr
      INTO @ls_zppt0001.
    "업데이트
    IF ls_zppt0001 IS NOT INITIAL.

      IF gs_tab-i_mode = 'P'. "입고

        SELECT SINGLE
             b~werks,
             c~matnr,
             b~rgekz, "백플러시
             c~lgort, "저장위치
             c~charg, "배치번호
             c~clabs AS menge, "평가된 가용 재고
             d~meins  "기본단위
        FROM marc AS b
        INNER JOIN mchb AS c
             ON b~matnr = c~matnr
            AND b~werks = c~werks
        INNER JOIN mara AS d
             ON b~matnr = d~matnr
       WHERE  b~werks = @gs_tab-werks
         AND  b~matnr = @gs_tab-matnr
         AND  b~xchpf = 'X'
         AND  c~lgort = @gs_tab-lgort
         AND  c~charg = @gs_tab-charg
         AND  c~lvorm = ' '
        INTO CORRESPONDING FIELDS OF @gs_stock.

        IF lv_mandt IS NOT INITIAL. "Factor 배치 대상

          IF lv_indlen = 0.
            lv_mgvrg = ls_zppt0001-mgvrg + gs_tab-menge.
          ELSE.
            lv_mgvrg = ls_zppt0001-mgvrg.
          ENDIF.

        ELSE.

          lv_mgvrg = ls_zppt0001-mgvrg + gs_tab-menge.

        ENDIF.

        UPDATE zppt0001 SET :  vornr   = lv_vornr
                               mblnr   = pv_document
                               arbpl   = lv_arbpl
                               mgvrg   = lv_mgvrg
                               fostcnt = fostcnt + gs_tab-erfmg
                               remain  = remain + gs_tab-menge  "2026.07.08
                               wkdat   = sy-datum "LV_DATE
                               wkindat = sy-datum "LV_DATE
                               wkintim = sy-uzeit "LV_TIME
                               wkinnam = gs_tab-wkinnam "SY-UNAME
                               grindat = sy-datum
                               grintim = gs_tab-wkinnam "SY-UZEIT
                               grinnam = sy-uname
                        WHERE werks = gs_tab-werks
                         AND  aufnr = gs_tab-aufnr
                         AND  tagnr = gs_tab-tagnr
                         AND  charg = gs_tab-charg
                         AND  matnr = gs_tab-matnr.
        IF sy-subrc = 0.
          COMMIT WORK.
        ENDIF.

      ELSEIF gs_tab-i_mode = 'C'. "입고취소

        IF lv_mandt IS NOT INITIAL. "Factor 배치 대상

*          IF LV_INDLEN = 0.
*            LV_MGVRG = LS_ZPPT0001-MGVRG - GS_TAB-ERFMG. "2026.07.08
*          ELSE.
          lv_mgvrg = ls_zppt0001-mgvrg.
*          ENDIF.

          lv_fostcnt = ls_zppt0001-fostcnt - gs_tab-erfmg. "2026.07.08

          IF lv_fostcnt > 0.
            UPDATE zppt0001 SET :  vornr   = lv_vornr
                                   mblnr   = pv_document
                                   arbpl   = lv_arbpl
                                   mgvrg   = lv_mgvrg
                                   fostcnt = lv_fostcnt
                                   remain  = remain - gs_tab-menge  "2026.07.08
                                   wkdat   = sy-datum "LV_DATE
                                   wkindat = sy-datum "LV_DATE
                                   wkintim = sy-uzeit "LV_TIME
                                   wkinnam = gs_tab-wkinnam "SY-UNAME
                                   grindat = sy-datum
                                   grintim = gs_tab-wkinnam "SY-UZEIT
                                   grinnam = sy-uname
                            WHERE werks = gs_tab-werks
                             AND  aufnr = gs_tab-aufnr
                             AND  tagnr = gs_tab-tagnr
                             AND  charg = gs_tab-charg
                             AND  matnr = gs_tab-matnr.
          ELSE.
            DELETE FROM zppt0001  WHERE werks = gs_tab-werks
                                   AND  aufnr = gs_tab-aufnr
                                   AND  tagnr = gs_tab-tagnr
                                   AND  charg = gs_tab-charg
                                   AND  matnr = gs_tab-matnr.
          ENDIF.

          IF sy-subrc = 0.
            COMMIT WORK.
          ENDIF.

*          UPDATE ZPPT0016 SET PLTST = '4',
*                              CADAT = @SY-DATUM,
*                              CANAM = @GS_TAB-WKINNAM
*                        WHERE WERKS = @GS_TAB-WERKS
*                          AND PLTNR = @GS_TAB-PLTNR
*                          AND CHARG = @GS_TAB-CHARG
*                          AND MATNR = @GS_TAB-MATNR.
*          IF SY-SUBRC = 0.
*            COMMIT WORK.
*          ENDIF.
* Factor 배치가 아닌 경우 꼬리표 ZPPT0001에 해당 건 삭제
        ELSE.

          DELETE FROM zppt0001  WHERE werks = gs_tab-werks
                                 AND  aufnr = gs_tab-aufnr
                                 AND  tagnr = gs_tab-tagnr
                                 AND  charg = gs_tab-charg
                                 AND  matnr = gs_tab-matnr.

          IF sy-subrc = 0.
            COMMIT WORK.
          ENDIF.

        ENDIF.

      ENDIF.
      "생성
    ELSE.
*- Start 2024.12.13
* 해당 꼬리표의 확정 문서가 존재할 경우 해당 RMZHL 값을 대입. 없으면 기존처럼 '00000001'
      SELECT SINGLE rmzhl INTO lv_rmzhl
                      FROM afru
                      WHERE ltxa1 EQ gs_tab-tagnr.

      IF lv_rmzhl IS INITIAL.
        lv_rmzhl = '00000001'.
      ENDIF.
*- End 2024.12.13
      lv_procd = lv_mara+4(3).  "공정코드

      SELECT SINGLE dispo
        FROM marc
        WHERE matnr = @gs_tab-matnr
            AND werks = @gs_tab-werks
            INTO @DATA(lv_marc).
      lv_spgcd = lv_marc+0(2).

      IF lv_mandt IS NOT INITIAL.

        ls_zppt0001 = VALUE #( werks   = gs_tab-werks
                               aufnr   = gs_tab-aufnr
                               tagnr   = gs_tab-tagnr
                               rueck   = lv_conf
*- Start 2024.12.13
                               rmzhl   = lv_rmzhl
                               posnr   = gs_tab-posnr
*- End 2024.12.13
                               vornr   = lv_vornr
                               charg   = gs_tab-charg
                               mblnr   = pv_document
                               matnr   = gs_tab-matnr
                               spgcd   = lv_spgcd
                               procd   = lv_procd
                               arbpl   = lv_arbpl
*                             MGVRG   = GS_TAB-MENGE        "조장
                               mgvrg   = COND #( WHEN lv_indlen = 0 THEN gs_tab-menge
                                                                    ELSE lv_indlen )
                               fostcnt = gs_tab-erfmg         "조장수
                               remain  = gs_tab-menge         "수량
                               meins   = gs_tab-meins
                               giflg   = 'N'
                               grflg   = 'Y'
                               inspflg = 'OK'
                               lgort   = gs_tab-lgort
                               wkdat   = sy-datum "LV_DATE
                               wkindat = sy-datum "LV_DATE
                               wkintim = sy-uzeit "LV_TIME
                               wkinnam = gs_tab-wkinnam "SY-UNAME
                               grindat = sy-datum
                               grintim = sy-uzeit
                               grinnam = gs_tab-wkinnam "SY-UNAME
                               gstrs   = gs_tab-gstrs "LV_START   "계획된 시작(일자)
                               gsuzs   = gs_tab-gsuzs "LV_STIME   "일정 계획된 시작(시간)
                               gltrs   = gs_tab-gltrs "LV_FINISH   "계획 종료 (일자)
                               gluzs   = gs_tab-gluzs "LV_FTIME   "일정 계획 종료 (시간)
                               pcont   = '0'
                                ).

      ELSE.

        ls_zppt0001 = VALUE #( werks   = gs_tab-werks
                               aufnr   = gs_tab-aufnr
                               tagnr   = gs_tab-tagnr
                               rueck   = lv_conf
*- Start 2024.12.13
                               rmzhl   = lv_rmzhl
                               posnr   = gs_tab-posnr
*- End 2024.12.13
*                               rmzhl   = '00000001'
*                               posnr   = '1'
                               vornr   = lv_vornr
                               charg   = gs_tab-charg
                               mblnr   = pv_document
                               matnr   = gs_tab-matnr
                               spgcd   = lv_spgcd
                               procd   = lv_procd
                               arbpl   = lv_arbpl
                               mgvrg   = gs_tab-menge
                               fostcnt = '1'         "조장수
                               remain  = gs_tab-menge         "수량
                               meins   = gs_tab-meins
                               giflg   = 'N'
                               grflg   = 'Y'
                               inspflg = 'OK'
                               lgort   = gs_tab-lgort
                               wkdat   = sy-datum "LV_DATE
                               wkindat = sy-datum "LV_DATE
                               wkintim = sy-uzeit "LV_TIME
                               wkinnam = gs_tab-wkinnam "SY-UNAME
                               grindat = sy-datum
                               grintim = sy-uzeit
                               grinnam = gs_tab-wkinnam "SY-UNAME
                               gstrs   = gs_tab-gstrs "LV_START   "계획된 시작(일자)
                               gsuzs   = gs_tab-gsuzs "LV_STIME   "일정 계획된 시작(시간)
                               gltrs   = gs_tab-gltrs "LV_FINISH   "계획 종료 (일자)
                               gluzs   = gs_tab-gluzs "LV_FTIME   "일정 계획 종료 (시간)
                               pcont   = '0'
                                ).

      ENDIF.

      MODIFY zppt0001 FROM ls_zppt0001.
      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.

    ENDIF.
**- PALLET
*    IF LV_MANDT IS NOT INITIAL.
*
*      SELECT SINGLE *
*        FROM ZPPT0016
*        WHERE WERKS = @GS_TAB-WERKS
*         AND  PLTNR = @GS_TAB-PLTNR
*         AND  CHARG = @GS_TAB-CHARG
*         AND  MATNR = @GS_TAB-MATNR
*        INTO @LS_ZPPT0016.
*
*      IF LS_ZPPT0016 IS NOT INITIAL.
*
*        IF GS_TAB-I_MODE = 'P'. "입고
** 2024.04.19
*          CLEAR : LV_FOSTER.
*          LV_FOSTER = GS_TAB-MENGE / GS_TAB-ERFMG.
*
*          UPDATE ZPPT0016 SET MGVRG = GS_TAB-MENGE
*                              FOSTER = LV_FOSTER
*                              FOSTCNT = GS_TAB-ERFMG
*                              MEINS = GS_TAB-MEINS
*                              CHARG = GS_TAB-CHARG
*                              AUFNR = GS_TAB-AUFNR
*                              ARBPL  = LV_ARBPL
*                              PLTST = '2'
*                              ERDAT = SY-DATUM
*                              ERTIM  = SY-UZEIT
*                              ERNAM = GS_TAB-WKINNAM
*                        WHERE PLTNR   = GS_TAB-PLTNR
*                          AND SEQNO   = GS_TAB-SEQNO.
*          IF SY-SUBRC = 0.
*            COMMIT WORK.
*          ENDIF.
** 2024.04.19
*        ENDIF.
*
*      ELSE.
*
*        LS_ZPPT0016 = VALUE #( WERKS = GS_TAB-WERKS
*                               PLTNR = GS_TAB-PLTNR
*                               SEQNO = GS_TAB-SEQNO
*                               SPART = LV_MTART
*                               LGORT = GS_TAB-LGORT
*                               PRGKZ = '1'
*                               MATNR = GS_TAB-MATNR
*                               MGVRG   = GS_TAB-MENGE
*                               FOSTER  = GS_TAB-MENGE / GS_TAB-ERFMG
*                               FOSTCNT = GS_TAB-ERFMG
*                               MEINS   = GS_TAB-MEINS
*                               CHARG   = GS_TAB-CHARG
*                               AUFNR   = GS_TAB-AUFNR
*                               ARBPL   = LV_ARBPL
*                               PLTST   = '2'
*                               ERDAT   = SY-DATUM
*                               ERTIM   = SY-UZEIT
*                               ERNAM   = GS_TAB-WKINNAM ).
*
*        MODIFY ZPPT0016 FROM LS_ZPPT0016.
*        IF SY-SUBRC = 0.
*          COMMIT WORK.
*        ENDIF.
*
*      ENDIF.
*
*      SELECT SINGLE *
*        FROM ZPPT0017
*        WHERE PLTNR = @GS_TAB-PLTNR
*          AND SEQNO = @GS_TAB-SEQNO
*        INTO @LS_ZPPT0017.
*
*      IF LS_ZPPT0017 IS NOT INITIAL.
*        UPDATE ZPPT0017 SET  MBLNR   = PV_DOCUMENT
*                             MJAHR   = PV_YEAR
*                             ZEILE   = '0001'
*                             FOSTCNT = GS_TAB-ERFMG
*                             ERDAT   = SY-DATUM
*                             ERTIM   = SY-UZEIT
*                             ERNAM   = GS_TAB-WKINNAM
*                       WHERE PLTNR   = GS_TAB-PLTNR
*                         AND SEQNO   = GS_TAB-SEQNO.
*        IF SY-SUBRC = 0.
*          COMMIT WORK.
*        ENDIF.
*      ELSE.
*        LS_ZPPT0017 = VALUE #( PLTNR   = GS_TAB-PLTNR
*                               SEQNO   = GS_TAB-SEQNO
*                               MBLNR   = PV_DOCUMENT
*                               MJAHR   = PV_YEAR
*                               ZEILE   = '0001'
*                               FOSTCNT = GS_TAB-ERFMG
*                               ERDAT   = SY-DATUM
*                               ERTIM   = SY-UZEIT
*                               ERNAM   = GS_TAB-WKINNAM ).
*        MODIFY ZPPT0017 FROM LS_ZPPT0017.
*        IF SY-SUBRC = 0.
*          COMMIT WORK.
*        ENDIF.
*      ENDIF.
*
*    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GR_CALL_TRANSACTION_ZGTPPI2010
*&---------------------------------------------------------------------*
FORM gr_call_transaction_zgtppi2010 USING pv_werks.

  DATA : jobname  LIKE tbtcjob-jobname,
         jobcount LIKE tbtcjob-jobcount.

  RANGES : lr_aufnr FOR afko-aufnr,
                  lr_erdat FOR sy-datum.

  CLEAR : lr_aufnr[], lr_erdat[].
  lr_aufnr[] = VALUE #( ( sign = 'I' option = 'EQ' low = gs_tab-aufnr ) ).

  DELETE lr_aufnr WHERE low EQ space.
* 전송 오더가 있을 시에만 전송
  CHECK lr_aufnr[] IS NOT INITIAL.
*<-

  CONCATENATE '생산오더 전송_' pv_werks '_' sy-datum '_' sy-uzeit
         INTO jobname.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = jobname
    IMPORTING
      jobcount         = jobcount
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.

*  IF GS_TAB-WERKS EQ '1302'.
*    SUBMIT ZGTPPI2010 VIA JOB JOBNAME NUMBER JOBCOUNT AND RETURN
*                      WITH S_AUFNR IN LR_AUFNR
*                      WITH S_ERDAT IN LR_ERDAT
*                      WITH P_R1  EQ 'X'
*                      WITH P_R2  EQ ' '
*                      WITH P_R3  EQ 'X'
*                      WITH P_R4  EQ ' '
*                      WITH P_R9  EQ ' '
*                      WITH P_R10 EQ ' '
*                      WITH P_R11 EQ ' '
*                      WITH P_R8  EQ 'X'.
*
*  ELSEIF  GS_TAB-WERKS EQ '1305'.   "소재 MOM SRM2510-04825
*    SUBMIT ZGTPPI2010 VIA JOB JOBNAME NUMBER JOBCOUNT AND RETURN
*                      WITH S_AUFNR IN LR_AUFNR
*                      WITH S_ERDAT IN LR_ERDAT
*                      WITH P_R1  EQ 'X'
*                      WITH P_R2  EQ ' '
*                      WITH P_R3  EQ ' '
*                      WITH P_R4  EQ ' '
*                      WITH P_R9  EQ 'X'
*                      WITH P_R10 EQ ' '
*                      WITH P_R11 EQ ' '
*                      WITH P_R8  EQ 'X'.
*
*  ELSEIF GS_TAB-WERKS EQ '1306'.
*    SUBMIT ZGTPPI2010 VIA JOB JOBNAME NUMBER JOBCOUNT AND RETURN
*                      WITH S_AUFNR IN LR_AUFNR
*                      WITH S_ERDAT IN LR_ERDAT
*                      WITH P_R1  EQ 'X'
*                      WITH P_R2  EQ ' '
*                      WITH P_R3  EQ ' '
*                      WITH P_R4  EQ 'X'
*                      WITH P_R9  EQ ' '
*                      WITH P_R10 EQ ' '
*                      WITH P_R11 EQ ' '
*                      WITH P_R8  EQ 'X'.

  IF gs_tab-werks EQ '6500'.
    SUBMIT zgtppi2010 VIA JOB jobname
                       NUMBER jobcount
                         WITH s_aufnr IN lr_aufnr
                         WITH s_erdat IN lr_erdat
                         WITH p_r1  EQ 'X'
                         WITH p_r2  EQ ' '
                         WITH p_r3  EQ ' '
                         WITH p_r4  EQ ' '
                         WITH p_r9  EQ ' '
                         WITH p_r10 EQ 'X'
                         WITH p_r11 EQ ' '
                         WITH p_r8  EQ 'X'
                          AND RETURN.

  ELSEIF gs_tab-werks EQ '6600'.
    SUBMIT zgtppi2010 VIA JOB jobname
                       NUMBER jobcount
                         WITH s_aufnr IN lr_aufnr
                         WITH s_erdat IN lr_erdat
                         WITH p_r1  EQ 'X'
                         WITH p_r2  EQ ' '
                         WITH p_r3  EQ ' '
                         WITH p_r4  EQ ' '
                         WITH p_r9  EQ ' '
                         WITH p_r10 EQ ' '
                         WITH p_r11 EQ 'X'
                         WITH p_r8  EQ 'X'
                          AND RETURN.
  ENDIF.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount             = jobcount
      jobname              = jobname
      strtimmed            = 'X'
    EXCEPTIONS
      cant_start_immediate = 1
      invalid_startdate    = 2
      jobname_missing      = 3
      job_close_failed     = 4
      job_nosteps          = 5
      job_notex            = 6
      lock_failed          = 7
      OTHERS               = 8.
*->
ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_goodsmvt_cancel_tab
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_cancel_tab USING pv_system_id TYPE char04.

  DATA : ls_headret    TYPE bapi2017_gm_head_ret,
         lt_return     TYPE TABLE OF bapiret2,
         lv_message    TYPE bapiret2-message,
         lv_budat_mkpf LIKE mseg-budat_mkpf.

  DATA : lv_werks    TYPE marc-werks,
         lv_dispo    TYPE marc-dispo,
         lv_insmk    TYPE mseg-insmk,
         lv_prueflos TYPE qals-prueflos,
         lv_clabs    TYPE mchb-clabs.

  CLEAR : ls_headret, lt_return, lv_message, lv_budat_mkpf.

*SRM2510-04825 SCR 입고 취소인 경우 품질->가용건은 검사로트 취소 처리
  SELECT SINGLE a~werks, b~dispo, a~insmk
      INTO  (@lv_werks, @lv_dispo, @lv_insmk)
      FROM matdoc AS a INNER JOIN marc AS b
                                           ON a~matnr = b~matnr
                                          AND a~werks = b~werks
    WHERE a~mblnr = @gs_tab-mblnr
         AND a~mjahr  = @gs_tab-mjahr.

  IF lv_werks EQ '1305' AND lv_dispo+0(2) EQ 'BC' AND
     lv_insmk EQ 'X'.

*& 품질검사 재고유형으로 입고된 자재문서가 가용재고 전환 여부
    SELECT SINGLE prueflos
      INTO @lv_prueflos
      FROM qals
     WHERE mblnr = @gs_tab-mblnr
       AND mjahr = @gs_tab-mjahr
       AND stat34 EQ 'X'
       AND stat35 EQ 'X'.

*& 배치재고가 가용재고가 아닌 경우 제외
    SELECT SINGLE clabs
        INTO  @lv_clabs
       FROM mchb
     WHERE werks = @gs_tab-werks
          AND matnr = @gs_tab-matnr
          AND charg = @gs_tab-charg.

    IF lv_prueflos IS NOT INITIAL AND lv_clabs > 0.   "품질->가용처리 취소
      SUBMIT zqmr0160 WITH prueflos = lv_prueflos
                                AND RETURN.
      WAIT UP TO '1' SECONDS.
    ENDIF.
  ENDIF.
*SRM2510-04825

  SELECT SINGLE budat_mkpf INTO @lv_budat_mkpf
                 FROM mseg
                 WHERE mblnr = @gs_tab-mblnr
                      AND mjahr = @gs_tab-mjahr
                      AND bwart = '101'
                      AND matnr = @gs_tab-matnr
                      AND aufnr = @gs_tab-aufnr.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      materialdocument    = gs_tab-mblnr
      matdocumentyear     = gs_tab-mjahr
      goodsmvt_pstng_date = lv_budat_mkpf
*     goodsmvt_pstng_date = gs_tab-budat
      goodsmvt_pr_uname   = sy-uname
      documentheader_text = 'MES I/F'
    IMPORTING
      goodsmvt_headret    = ls_headret
    TABLES
      return              = lt_return.
*- 실패
  IF line_exists( lt_return[ type = 'E' ] ).

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-e70.
    ENDIF.

    PERFORM return_message_tab USING 'E'
                                     lv_message
                                     ls_headret-doc_year
                                     ls_headret-mat_doc.

    PERFORM save_log_zgtppt3110 USING 'E'
                                         lv_message
                                         ls_headret-doc_year
                                         ls_headret-mat_doc
                                         pv_system_id.

*- 성공
  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    lv_message = VALUE #( lt_return[ type = 'S' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-s10.
    ENDIF.

    IF pv_system_id EQ 'KGPM' OR   "// 가온전선 MES. 2026.03.12 수정.
       pv_system_id EQ 'KGOM'.
      UPDATE mcha
         SET zzline_no     = space  "// 신선 Cage(층수) = 특성 01
             zzserial_info = space  "// 신선 차수 = 특성 02
      WHERE matnr EQ gs_tab-matnr
        AND werks EQ gs_tab-werks
        AND charg EQ gs_tab-charg.
    ENDIF.

    PERFORM return_message_tab USING 'S'
                                     lv_message
                                     ls_headret-doc_year
                                     ls_headret-mat_doc.

    PERFORM save_log_zgtppt3110 USING 'S'
                                         lv_message
                                         ls_headret-doc_year
                                         ls_headret-mat_doc
                                         pv_system_id.
*- Start 2025.01.23
    IF pv_system_id EQ 'KPCM' OR
       pv_system_id EQ 'KSCM' OR "소재 MOM SRM2510-04825
       pv_system_id EQ 'KGPM' OR
       pv_system_id EQ 'KGOM' OR    "가온전선 추가
       PV_SYSTEM_ID EQ 'KFCM' .  "한미소 MOM 260902
*- 꼬리표 생성 및 업데이트
      PERFORM create_tab_tagnr USING ls_headret-mat_doc
                                                             ls_headret-doc_year.

    ENDIF.
*- End 2025.01.23

*- Start 2026.07.07 입고 처리, 취소시  by ZGISPP03
**- 생산오더 전송 프로그램 호출(ZGTPPI2010)
    IF pv_system_id NE 'KPCM' AND
       pv_system_id NE 'KSCM'. " AND
*       PV_SYSTEM_ID NE 'KFCM' .   "한미소 MOM 260902.
      PERFORM gr_call_transaction_zgtppi2010 USING gs_tab-werks.
    ENDIF.
*- End 2026.07.07 입고 처리, 취소시  by ZGISPP03
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form result_tab_data
*&---------------------------------------------------------------------*
FORM result_tab_data USING po_result po_message.

  DATA : lv_message(80),
         lv_result(2).

  CLEAR : lv_message, lv_result.
  IF gt_tab_result IS NOT INITIAL.
*- 성공 건수
    DATA(lv_cnt_s) = REDUCE i(
                     INIT sum = 0 FOR ls_cnt_s IN gt_tab_result
                     WHERE ( zerp_stat = 'S' )
                     NEXT sum = sum + 1 ).
*- 실패 건수
    DATA(lv_cnt_e) = REDUCE i(
                     INIT sum = 0 FOR ls_cnt_e IN gt_tab_result
                     WHERE ( zerp_stat = 'E' )
                     NEXT sum = sum + 1 ).
    "전체 성공
    IF lv_cnt_s IS NOT INITIAL AND
       lv_cnt_e IS INITIAL.

      lv_result = '00'.
      lv_message = |{ lv_cnt_s }{ TEXT-s08 }|.
      "전체 실패
    ELSEIF lv_cnt_s IS INITIAL AND
           lv_cnt_e IS NOT INITIAL.

      lv_result = '01'.
      lv_message = |{ lv_cnt_e }{ TEXT-e45 }|.
      "부분 성공
    ELSE.

      lv_result = '01'.
      lv_message = |{ lv_cnt_s }{ TEXT-s08 }, { lv_cnt_e }{ TEXT-e45 }|.

    ENDIF.
*- 처리 결과
    po_result  = lv_result.
    po_message = lv_message.

  ELSE.

    lv_result = '01'.
    lv_message = TEXT-e46.
*- 처리 결과
    po_result  = lv_result.
    po_message = lv_message.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conversion_output_tab_result
*&---------------------------------------------------------------------*
FORM conversion_output_tab_result .

  LOOP AT gt_tab_result INTO DATA(ls_data).

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_data-aufnr
      IMPORTING
        output = ls_data-aufnr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_data-mblnr
      IMPORTING
        output = ls_data-mblnr.

    CALL FUNCTION 'CONVERSION_EXIT_GJAHR_OUTPUT'
      EXPORTING
        input  = ls_data-mjahr
      IMPORTING
        output = ls_data-mjahr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_data-prueflos
      IMPORTING
        output = ls_data-prueflos.

    MODIFY gt_tab_result FROM ls_data.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mchb2
*&---------------------------------------------------------------------*
FORM get_mchb2 USING ps_issue TYPE zgtppt3070
                                      pv_error.

  DATA : lv_tabix TYPE sy-tabix.

*  SELECT
*        b~werks,
*        c~matnr,
*        b~rgekz, "백플러시
*        c~lgort, "저장위치
*        c~charg, "배치번호
*        c~clabs, "평가된 가용 재고
*        d~budat,
*        e~meins
*    FROM marc AS b
*    INNER JOIN mchb AS c
*         ON b~matnr = c~matnr
*        AND b~werks = c~werks
*    INNER JOIN matdoc AS d
*         ON d~charg = c~charg
*    INNER JOIN mara AS e
*         ON b~matnr = e~matnr
*    WHERE b~matnr = @ps_issue-matnr  "자재 번호
*         AND b~xchpf = 'X'              "플랜트의 배치 관리 필요 지시자
*         AND c~lgort = @ps_issue-lgort  "저장 위치
*         AND c~lvorm = ' '              "배치 재고의 모든 데이터에 대한 삭제 표시
*         AND c~clabs > 0
*         AND concat( d~charg, d~budat ) IN
*                            ( SELECT concat( e~charg, MAX( e~budat ) )
*                            FROM matdoc AS e
*                            WHERE e~charg = c~charg
*                                 AND e~shkzg = 'S'
*                                 AND e~reversal_movement = @space
*                                 AND e~cancelled NE 'X' "취소처리되지 않은 것
*                            GROUP BY e~charg )
*         INTO CORRESPONDING FIELDS OF TABLE @gt_stock2.
  SELECT
        b~werks,
        c~matnr,
        b~rgekz, "백플러시
        c~lgort, "저장위치
        c~charg, "배치번호
        c~clabs, "평가된 가용 재고
        e~meins
    FROM marc AS b
    INNER JOIN mchb AS c
         ON b~matnr = c~matnr
        AND b~werks = c~werks
    INNER JOIN mara AS e
         ON b~matnr = e~matnr
    WHERE b~matnr EQ @ps_issue-matnr  "자재 번호
         AND b~xchpf = 'X'              "플랜트의 배치 관리 필요 지시자
         AND b~werks EQ @ps_issue-werks
         AND c~lgort EQ @ps_issue-lgort  "저장 위치
         AND c~lvorm = ' '              "배치 재고의 모든 데이터에 대한 삭제 표시
         AND c~clabs > 0
         INTO CORRESPONDING FIELDS OF TABLE @gt_stock2.

  CHECK gt_stock2[] IS NOT INITIAL.

  SELECT matnr, charg, budat
      INTO TABLE @DATA(lt_matdoc)
      FROM matdoc
      FOR ALL ENTRIES IN @gt_stock2
      WHERE werks EQ @gt_stock2-werks
           AND matnr EQ @gt_stock2-matnr
           AND shkzg = 'S'
           AND cancelled NE 'X'
           AND cancellation_type EQ @space
           AND lgort EQ @gt_stock2-lgort
           AND charg EQ @gt_stock2-charg.

  SORT lt_matdoc BY matnr charg ASCENDING budat DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_matdoc COMPARING matnr charg.

  LOOP AT gt_stock2 INTO gs_stock2.

    lv_tabix = sy-tabix.

    READ TABLE lt_matdoc INTO DATA(ls_matdoc)
                                       WITH KEY matnr = gs_stock2-matnr
                                                   charg = gs_stock2-charg.
    IF sy-subrc = 0.
      gs_stock2-budat = ls_matdoc-budat.
      MODIFY gt_stock2 FROM gs_stock2 INDEX lv_tabix.
    ENDIF.

  ENDLOOP.

  SORT gt_stock2 ASCENDING BY budat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_char
*&---------------------------------------------------------------------*
FORM update_char TABLES pt_item STRUCTURE bapi2017_gm_item_show
                                             pt_return STRUCTURE bapiret2
                                  USING ps_issue TYPE zgtppt3070
                                             pv_system_id TYPE char04
                                             pv_mode TYPE char02
                                             pv_charg TYPE bapi2017_gm_item_show-batch.

  DATA : lv_charg TYPE bapi2017_gm_item_show-batch.
  DATA : lv_document TYPE bapi2017_gm_head_02-mat_doc,
         lv_year     TYPE bapi2017_gm_head_02-doc_year,
         lt_item     TYPE TABLE OF bapi2017_gm_item_show,
         lt_return   TYPE TABLE OF bapiret2,
         lv_class    TYPE klah-class,
         lt_char     TYPE TABLE OF api_ch_att,
         lt_vali     TYPE TABLE OF api_vali,
         ls_vali     TYPE api_vali,
         lt_valnum   TYPE TABLE OF bapi1003_alloc_values_num,
         ls_valnum   TYPE bapi1003_alloc_values_num,
         lt_valchar  TYPE TABLE OF bapi1003_alloc_values_char,
         ls_valchar  TYPE bapi1003_alloc_values_char,
         lt_valcurr  TYPE TABLE OF bapi1003_alloc_values_curr,
         lv_status   TYPE bapi1003_key-status,
         lv_message  TYPE bapiret2-message.
  DATA : lv_dpcbt LIKE marc-dpcbt,
         lv_kzwsm LIKE mara-kzwsm.

  CLEAR : lv_class, lt_vali, lt_char, gs_stock, lt_valnum, lv_status, lt_valchar, lt_valcurr,
               lv_message, lt_item, lt_return.

  lv_charg = pv_charg.
  lt_item[] = pt_item[].
  lt_return[] = pt_return[].
*- CLASS 번호
  CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
    EXPORTING
      material           = ps_issue-matnr "입고자재
      plant              = ps_issue-werks "플랜트
      classtype          = '023'          "클래스유형(배치)
    IMPORTING
      class              = lv_class
    EXCEPTIONS
      no_class_found     = 1
      no_classtype_found = 2
      OTHERS             = 3.

  CHECK lv_class IS NOT INITIAL.
*- 배치특성 정보
  CALL FUNCTION 'ZQC01_BATCH_VALUES_READ'
    EXPORTING
      i_val_matnr    = ps_issue-matnr
      i_val_werks    = ps_issue-werks
      i_val_charge   = lv_charg
      i_date         = sy-datum
    TABLES
      t_val_tab      = lt_vali
      t_att_tab      = lt_char
    EXCEPTIONS
      no_class       = 1
      internal_error = 2
      no_values      = 3
      no_chars       = 4
      OTHERS         = 5.

  LOOP AT lt_char INTO DATA(ls_char).
    CLEAR ls_vali.
    ls_vali = VALUE #( lt_vali[ atnam = ls_char-atnam ] OPTIONAL ).

    CASE ls_char-dtype.
      WHEN 'CHAR' OR 'DATE'.
        lt_valchar = VALUE #( BASE lt_valchar
                             ( value_char = ls_vali-atwrt
                               charact    = ls_char-atnam ) ).
      WHEN 'TIME' OR 'NUM'.
        lt_valnum = VALUE #( BASE lt_valnum
                             ( value_from = ls_vali-atflv
                               unit_from  = ls_vali-atawe
                               charact    = ls_char-atnam ) ).
    ENDCASE.
  ENDLOOP.
*- 배치 타입
  CLEAR : lv_dpcbt, lv_kzwsm.
  SELECT SINGLE kzwsm  "단위사용
    INTO @lv_kzwsm
     FROM mara
     WHERE matnr = @ps_issue-matnr.
* 단일 단위 배치 기본값
  SELECT SINGLE dpcbt INTO @lv_dpcbt FROM marc
                                        WHERE matnr = @ps_issue-matnr
                                             AND werks = @ps_issue-werks.

  IF ( lv_dpcbt = 'B' OR  lv_dpcbt = 'C' ) AND
       lv_kzwsm = 'B' AND
       pv_mode = 'C'.
  ELSE.
*- 배치 특성정보 업데이트 데이터 입력
    LOOP AT lt_char INTO ls_char.
*- 싱글 유닛 배치
      IF ( lv_dpcbt = 'B' OR  lv_dpcbt = 'C' ) AND
           lv_kzwsm = 'B'.

        IF  ls_char-atnam = 'SAP_MILLCA_LENGTH' OR
            ls_char-atnam = 'SAP_MILLCA_LENGTH_SUB'.
          CONTINUE. "싱글유닛 배치의 두개의 특성은 입/출고 수량이 자동반영됨
        ENDIF.
*- Factor 배치
      ELSEIF lv_dpcbt = 'A' AND lv_kzwsm = 'B'.
* [GO01] 플랜트 6500, 6600 이고 Factor 배치의 경우 개별조장길이(기본단위)를 0으로 대입
        IF ps_issue-werks EQ '6500' OR ps_issue-werks EQ '6600'.
          IF ls_char-atnam = 'SAP_MILLCA_LENGTH_SUB'.
            CLEAR ls_valnum.
            ls_valnum-value_from = '0'.
            MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = 'SAP_MILLCA_LENGTH_SUB'.
          ENDIF.
        ENDIF.
* [GO01]
        CONTINUE. "Factor 배치의 길이 관련 두개의 특성은 입/출고 수량이 자동반영됨
*- 일반배치( Factor 배치도 있지만 해저에서는 사용하지 않음)
      ELSE.

        IF  ls_char-atnam = 'SAP_MILLCA_LENGTH' OR
            ls_char-atnam = 'SAP_MILLCA_LENGTH_SUB'.

          SELECT SINGLE
               b~werks,
               c~matnr,
               b~rgekz, "백플러시
               c~lgort, "저장위치
               c~charg, "배치번호
               c~clabs AS menge, "평가된 가용 재고
               d~meins  "기본단위
          FROM marc AS b
          INNER JOIN mchb AS c
               ON b~matnr = c~matnr
              AND b~werks = c~werks
          INNER JOIN mara AS d
               ON b~matnr = d~matnr
         WHERE  b~werks = @ps_issue-werks
           AND  b~matnr = @ps_issue-matnr
           AND  b~xchpf = 'X'
           AND  c~lgort = @ps_issue-lgort
           AND  c~charg = @ps_issue-charg
           AND  c~lvorm = ' '
          INTO CORRESPONDING FIELDS OF @gs_stock.
          "특성값 입력(수량/ 일반배치는 입/출고시 수량 자동반영 X)
          IF ls_char-atnam = 'SAP_MILLCA_LENGTH'.
            CLEAR ls_valnum.
            ls_valnum-value_from = gs_stock-menge.
            MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = 'SAP_MILLCA_LENGTH'.
          ELSEIF ls_char-atnam = 'SAP_MILLCA_LENGTH_SUB'.
            CLEAR ls_valnum.
            ls_valnum-value_from = gs_stock-menge.
            MODIFY lt_valnum FROM ls_valnum TRANSPORTING value_from WHERE charact = 'SAP_MILLCA_LENGTH_SUB'.
          ENDIF.
        ENDIF.
      ENDIF.

      CLEAR ls_char.

    ENDLOOP.

    CLEAR : lt_return.
*- 배치 특성 업데이트(펑션 호출)
    IF lt_char IS NOT INITIAL.

      SELECT SINGLE cuobj_bm
        INTO @DATA(lv_objkey)
        FROM mch1
        WHERE matnr = @ps_issue-matnr
         AND  charg = @lv_charg.

      CALL FUNCTION 'BAPI_OBJCL_CHANGE_KEY'
        EXPORTING
          clobjectkey         = lv_objkey
          classnum            = lv_class
        IMPORTING
          classif_status      = lv_status
        TABLES
          allocvaluesnum_new  = lt_valnum
          allocvalueschar_new = lt_valchar
          allocvaluescurr_new = lt_valcurr
          return              = lt_return.

      IF line_exists( lt_return[ type = 'E' ] ).

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*        lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
        CONCATENATE TEXT-m01 lv_charg TEXT-m02 INTO lv_message.
*        PERFORM return_message_issue USING ps_issue
*                                          'S'     "에러 플래그는 입고성공인 'S'로 저장
*                                          lv_message
*                                          '  '
*                                          '  '.
        PERFORM save_log_zgtppt3070_1 USING ps_issue pv_system_id pv_mode lv_charg
                                                                        lv_message.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_log_zgtppt3070_1
*&---------------------------------------------------------------------*
FORM save_log_zgtppt3070_1 USING ps_issue TYPE zgtppt3070
                                                 pv_system_id TYPE char04
                                                 pv_mode TYPE char02
                                                 pv_charg TYPE charg_d
                                                 pv_message TYPE bapiret2-message.

  DATA : ls_zgtppt3070 TYPE zgtppt3070.
  DATA : lv_timestamp TYPE timestampl.

  CLEAR : lv_timestamp.
  GET TIME STAMP FIELD lv_timestamp.
  ls_zgtppt3070 = VALUE #( zifkey = lv_timestamp
                           zsystem_id = pv_system_id
                           zserno    = ps_issue-zserno
                           i_mode   = pv_mode
                           werks     = ps_issue-werks
                           budat     = ps_issue-budat
                           rsnum     = ps_issue-rsnum
                           rspos     = ps_issue-rspos
                           matnr     = ps_issue-matnr
                           charg     = pv_charg
                           aufnr     = ps_issue-aufnr
                           bwart     = ps_issue-bwart
                           menge     = ps_issue-menge
                           meins     = ps_issue-meins
                           lgort     = ps_issue-lgort
                           tagnr     = ps_issue-tagnr
                           zup_tagnr = ps_issue-zup_tagnr
                           mjahr     = VALUE #( gt_gi_result[ zserno = ps_issue-zserno ]-mjahr OPTIONAL )
                           mblnr     = VALUE #( gt_gi_result[ zserno = ps_issue-zserno ]-mblnr OPTIONAL )
                           pernr     = ps_issue-pernr
                           name    = ps_issue-name
                           zc_mjahr  = ps_issue-mjahr
                           zc_mblnr  = ps_issue-mblnr
                           zerp_stat         = 'S'
                           zerp_message = pv_message
                           ifdat    = sy-datum
                           iftim    = sy-uzeit
                           ifnam    = sy-uname ).

  IF ls_zgtppt3070 IS NOT INITIAL.
    MODIFY zgtppt3070 FROM ls_zgtppt3070.
    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.
  ENDIF.
* ZO_RESULT, ZO_MESSAGE 업데이트를 위한 키필드 반영
  CLEAR gs_gi_keys.
  MOVE-CORRESPONDING ls_zgtppt3070 TO gs_gi_keys.
  APPEND gs_gi_keys TO gt_gi_keys.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_TAGNR
*&---------------------------------------------------------------------*
FORM update_tagnr USING ps_issue TYPE zgtppt3070
                                           p_mode pv_document pv_year.

  DATA : ls_zppt0015   TYPE zppt0015,
         ls_zppt0015_1 TYPE zppt0015,
         lt_zppt0015   TYPE TABLE OF zppt0015,
         lt_zppt0015_1 TYPE TABLE OF zppt0015,
         lv_mgvrg      TYPE zppt0015-mgvrg,
         lv_mgvrg01    TYPE zppt0001-mgvrg.

  DATA : ls_zppt0001 TYPE zppt0001,
         lv_remain   TYPE zppt0001-remain,
         lv_giflg    TYPE zppt0001-giflg,
         lv_seqno    TYPE zppt0015-seqno.

  DATA : lv_tagnr LIKE zppt0001-tagnr.

  CLEAR : ls_zppt0001, lv_remain, lv_giflg, lv_tagnr, ls_zppt0015, ls_zppt0015_1,
               lv_seqno.

  IF p_mode = 'P' OR p_mode = 'R' OR
     p_mode = 'F'.  "[GO01]

    IF ps_issue-tagnr IS INITIAL.

      SELECT SINGLE tagnr INTO @lv_tagnr
             FROM zppt0001
             WHERE werks = @ps_issue-werks
              AND  charg = @gs_batch-charg
              AND  matnr = @ps_issue-matnr.

    ELSE.

      lv_tagnr = ps_issue-tagnr.

    ENDIF.

    SELECT SINGLE *
       FROM zppt0001
       WHERE werks = @ps_issue-werks
        AND  tagnr = @lv_tagnr
        AND  charg = @gv_charg
        AND  matnr = @ps_issue-matnr
       INTO @ls_zppt0001.
* 출고처리하는 꼬리표의 입고된 꼬리표가 없으면 SKIP
    CHECK ls_zppt0001 IS NOT INITIAL.
* 투입 단위와 꼬리뼈 데이터 단위가 다르면 또 환산해줘야 함
    IF gv_meins NE ls_zppt0001-meins.

      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          i_matnr              = ps_issue-matnr
          i_in_me              = gv_meins
          i_out_me             = ls_zppt0001-meins
          i_menge              = gv_menge2
        IMPORTING
          e_menge              = gv_menge2
        EXCEPTIONS
          error_in_application = 1
          error                = 2
          OTHERS               = 3.

    ENDIF.
* 잔량 : 투입(-)
    lv_remain = ls_zppt0001-remain - gv_menge2.

    IF lv_remain < 0.
      lv_remain = 0.
    ENDIF.
* 잔량이 0이면 출고 FLAG는 Y
    IF lv_remain = 0.
      lv_giflg = 'Y'.
    ELSE.
      lv_giflg = 'N'.
    ENDIF.

    UPDATE zppt0001 SET : remain  = lv_remain
                                         giflg   = lv_giflg
                WHERE  werks   = ps_issue-werks
                    AND   tagnr   = lv_tagnr
                    AND   charg   = gv_charg
                    AND   matnr   = ps_issue-matnr.

    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.

    CHECK ps_issue-zup_tagnr IS NOT INITIAL.
*- 꼬리표 추적테이블(ZPPT0015)
    SELECT SINGLE *
      FROM zppt0015
      WHERE werks   = @ps_issue-werks
       AND  tagnr_o = @ps_issue-zup_tagnr
       AND  tagnr_i = @lv_tagnr
      INTO @ls_zppt0015.
* 기존 값이 없으면 Seqno 값은 '00'으로 Insert 되어야함.
    IF sy-subrc = 0.
      lv_seqno = ls_zppt0015-seqno + 1.
    ENDIF.
*- 꼬리표 업데이트 (수량/자재문서))
    IF ps_issue-zup_tagnr IS NOT INITIAL AND lv_tagnr IS NOT INITIAL.

      lt_zppt0015 = VALUE #( ( werks   = ps_issue-werks
                       tagnr_o = ps_issue-zup_tagnr "모품목 꼬리표
                       tagnr_i = lv_tagnr                     "자품목 꼬리표
                       seqno = lv_seqno                    "순번
                       mgvrg = gv_menge2
                       meins = ls_zppt0001-meins
                       mblnr   = pv_document
                       mjahr   = pv_year
                       zidat    = ps_issue-budat
                       zitim    = sy-uzeit ) ).

      MODIFY zppt0015 FROM TABLE lt_zppt0015.

      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.

    ENDIF.

  ELSEIF p_mode = 'C' OR
               p_mode = 'RC'. "2024.12.30
* 투입 취소일 때 꼬리표 추적 데이터 우선 확인
* ZPPT0015 데이터가 멀티건일 수도 있으므로 LOOP 로 체크 및 업데이트 및 삭제
    SELECT * INTO CORRESPONDING FIELDS OF TABLE @lt_zppt0015_1
                    FROM zppt0015
                    WHERE mblnr EQ @pv_document
                         AND mjahr EQ @pv_year.
*                    WHERE mblnr  = @ps_issue-mblnr "I/F 수신한 취소 대상 자재문서
*                         AND mjahr  = @ps_issue-mjahr."I/F 수신한 취소 대상 자재문서 년도

    LOOP AT lt_zppt0015_1 INTO ls_zppt0015_1.

      SELECT SINGLE *
                      FROM zppt0001
                      WHERE werks = @ps_issue-werks
                           AND tagnr = @ls_zppt0015_1-tagnr_i
                           AND matnr = @ps_issue-matnr
                           INTO @ls_zppt0001.
* 꼬리뼈 추적 단위와 작업실적 테이블(꼬리표) 단위가 다르면 환산
      IF ls_zppt0015_1-meins NE ls_zppt0001-meins.

        CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
          EXPORTING
            i_matnr              = ps_issue-matnr
            i_in_me              = ls_zppt0015_1-meins
            i_out_me             = ls_zppt0001-meins
            i_menge              = ls_zppt0015_1-mgvrg
          IMPORTING
            e_menge              = ls_zppt0015_1-mgvrg
          EXCEPTIONS
            error_in_application = 1
            error                = 2
            OTHERS               = 3.

      ENDIF.
* 잔량 : 취소(+)
      lv_remain  = ls_zppt0001-remain + ls_zppt0015_1-mgvrg.
      UPDATE zppt0001 SET : remain = lv_remain
                                           giflg      = 'N'
              WHERE werks EQ ps_issue-werks
                   AND tagnr  EQ ls_zppt0015_1-tagnr_i
                   AND matnr EQ ps_issue-matnr.

      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.
* 업데이트 대신 삭제로 변경
      DELETE FROM zppt0015
                 WHERE werks   EQ @ls_zppt0015_1-werks
                      AND tagnr_o EQ @ls_zppt0015_1-tagnr_o
                      AND tagnr_i  EQ @ls_zppt0015_1-tagnr_i
                      AND seqno   EQ @ls_zppt0015_1-seqno
                      AND mblnr = @pv_document
                      AND mjahr = @pv_year.
*                      AND mblnr    EQ @ps_issue-mblnr "I/F 수신한 취소 대상 자재문서
*                      AND mjahr    EQ @ps_issue-mjahr."I/F 수신한 취소 대상 자재문서 년도.

      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form convert_menge_check_resb
*&---------------------------------------------------------------------*
FORM convert_menge_check_resb USING ps_issue TYPE zgtppt3070
                                                     pv_menge
                                                     pv_meins.
  DATA : lv_erfme LIKE resb-erfme.

  SELECT SINGLE erfme INTO @lv_erfme
                      FROM resb
                     WHERE werks EQ @ps_issue-werks
                       AND aufnr EQ @ps_issue-aufnr
                       AND matnr EQ @ps_issue-matnr
                       AND rsnum EQ @ps_issue-rsnum
                       AND rspos EQ @ps_issue-rspos.

*** 2025.04.22 빈값여부 점검 로직 추가 pys s
  IF lv_erfme IS NOT INITIAL.
*** 2025.04.22 빈값여부 점검 로직 추가 pys e
    IF pv_meins NE lv_erfme.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          i_matnr              = ps_issue-matnr "BAPI 투입 처리하고자하는 자재
          i_in_me              = pv_meins "BAPI 투입 처리하고자하는 단위
          i_out_me             = lv_erfme "생산 오더 예약 정보 단위
          i_menge              = pv_menge "BAPI 투입 처리하고자하는 수량
        IMPORTING
          e_menge              = pv_menge  "BAPI 투입 처리 대상 수량
        EXCEPTIONS
          error_in_application = 1
          error                = 2
          OTHERS               = 3.

      pv_meins = lv_erfme.
    ENDIF.
*** 2025.04.22 빈값여부 점검 로직 추가 pys s
  ENDIF.
*** 2025.04.22 빈값여부 점검 로직 추가 pys e

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_cancel_org_zserno
*&---------------------------------------------------------------------*
FORM bapi_cancel_org_zserno USING ps_issue TYPE zgtppt3070
                                                             pv_system_id TYPE char04
                                                             pv_mode TYPE char02.

  DATA : lt_3101 LIKE TABLE OF zgtppt3101,
         ls_3101 LIKE zgtppt3101.

  DATA : ls_headret TYPE bapi2017_gm_head_ret,
         lt_return  TYPE TABLE OF bapiret2,
         lv_message TYPE bapiret2-message.

  DATA : lv_result.
* I/F 받은 ORG_ZSERNO 값만 있을 경우 실투입 오류( ZGTPPT3101 )의 자재문서를 가져와 취소
  SELECT * INTO TABLE @DATA(lt_zgtppt3100)
                  FROM zgtppt3100
                  WHERE zserno        EQ @ps_issue-org_zserno "기존 일련번호
                       AND zsystem_id EQ @pv_system_id "시스템 ID
                       AND process NE 'D'. "삭제 건 제외
* 실투입 오류의 ZGTPPT3101 재처리 완료 자재문서 추출
  IF lt_zgtppt3100[] IS INITIAL.

    IF gv_suc = 'X'.
      lv_message = TEXT-s16.
    ELSE.
      lv_message = TEXT-s15.
    ENDIF.

    PERFORM return_message_issue USING ps_issue
                                       'S'
                                       lv_message
                                       ls_headret-mat_doc
                                       ls_headret-doc_year.
* 자재 투입 취소 로그 데이터 저장(ZGTPPT3070)
    PERFORM save_log_zgtppt3070 USING ps_issue pv_system_id pv_mode.

  ELSE.

    SELECT * INTO TABLE @DATA(lt_zgtppt3101)
                    FROM zgtppt3101
                    FOR ALL ENTRIES IN @lt_zgtppt3100
                    WHERE weblnr   EQ @lt_zgtppt3100-weblnr
                         AND weblpos EQ @lt_zgtppt3100-weblpos
                         AND cancelled NE 'X'.
* 추출 데이터가 없다면 실투입 오류 문서 Update 수행
    IF lt_zgtppt3101[] IS INITIAL.

      IF gv_suc = 'X'.
        lv_message = TEXT-s20.
      ELSE.
        lv_message = TEXT-s13.
      ENDIF.
      PERFORM return_message_issue USING ps_issue
                                         'S'
                                         lv_message
                                         ls_headret-mat_doc
                                         ls_headret-doc_year.
* 자재 투입 취소 로그 데이터 저장(ZGTPPT3070)
      PERFORM save_log_zgtppt3070 USING ps_issue pv_system_id pv_mode.
* 실투입 오류 문서 정보 Update
      PERFORM update_process_zgtppt3100 TABLES lt_zgtppt3100.

    ELSE.
* 추출 성공 시 자재문서 취소
      CLEAR : gv_yes, gv_no.
      lt_3101[] = lt_zgtppt3101[].
      SORT lt_3101 BY budat mblnr mjahr.
      DELETE ADJACENT DUPLICATES FROM lt_3101 COMPARING budat mblnr mjahr.

      LOOP AT lt_3101 INTO ls_3101.

        CLEAR : ls_headret, lt_return, lv_message.
        CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
          EXPORTING
            materialdocument    = ls_3101-mblnr
            matdocumentyear     = ls_3101-mjahr
            goodsmvt_pstng_date = ls_3101-budat
            goodsmvt_pr_uname   = sy-uname
            documentheader_text = 'MES I/F'
          IMPORTING
            goodsmvt_headret    = ls_headret
          TABLES
            return              = lt_return.
*- 실패
        IF line_exists( lt_return[ type = 'E' ] ).

          gv_no = 'X'.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*          lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
*          IF lv_message IS INITIAL.
*            lv_message = TEXT-e71.
*          ENDIF.
*
*          PERFORM return_message_issue USING ps_issue
*                                        'E'
*                                        lv_message
*                                        ls_headret-mat_doc
*                                        ls_headret-doc_year.
** 자재 투입 취소 로그 데이터 저장(ZGTPPT3070)
*          PERFORM save_log_zgtppt3070 USING ps_issue pv_system_id pv_mode.

        ELSE.
*- 성공
          gv_yes = 'X'.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

*          lv_message = TEXT-s14.
*          PERFORM return_message_issue USING ps_issue
*                                             'S'
*                                             lv_message
*                                             ls_headret-mat_doc
*                                             ls_headret-doc_year.
*- Start 2025.01.31 부스닥트 건은 배치 특성과 꼬리표 업데이트를 수행하지 않음.
          IF pv_system_id NE 'KBDM'.
*- 배치 특성 업데이트
            PERFORM update_batch_values USING ps_issue
                                                                 pv_system_id
                                                                 pv_mode
                                                                 ls_3101-mblnr
                                                                 ls_3101-mjahr.
*- 꼬리표 추적 데이터 생성 및 업데이트
* 재처리 취소 건 중 ZGTPPT3101에 남아 있는 재처리 자재 문서로 꼬리표 업데이트
            PERFORM create_tagnr_rc USING ps_issue
                                       pv_mode
                                       ls_3101-mblnr
                                       ls_3101-mjahr.

          ENDIF.
*- End 2025,01.31
** 자재 투입 취소 로그 데이터 저장(ZGTPPT3070)
*          PERFORM save_log_zgtppt3070 USING ps_issue pv_system_id pv_mode.
* 실투입 오류 문서 정보 Update
          PERFORM update_cancelled_process TABLES lt_zgtppt3100 lt_zgtppt3101
                                                                            USING ls_3101.

        ENDIF.

      ENDLOOP.
* N 건 처리 시 메시지는 하나만 전송해야 하므로 다음 변수에 따라 메시지를 선정하여 전송
      IF gv_suc = 'X'. "수신 받은 I/F
        IF gv_yes = 'X' AND gv_no NE 'X'.
          lv_message = TEXT-s21.
          lv_result = 'S'.
        ELSEIF gv_yes = 'X' AND gv_no = 'X'.
          lv_message = TEXT-s22.
          lv_result = 'E'.
        ELSEIF gv_yes NE 'X' AND gv_no = 'X'.
          lv_message = TEXT-s23.
          lv_result = 'E'.
        ENDIF.
      ELSE.
        IF gv_yes = 'X' AND gv_no NE 'X'.
          lv_message = TEXT-s24.
          lv_result = 'S'.
        ELSEIF gv_yes = 'X' AND gv_no = 'X'.
          lv_message = TEXT-s25.
          lv_result = 'E'.
        ELSEIF gv_yes NE 'X' AND gv_no = 'X'.
          lv_message = TEXT-s26.
          lv_result = 'E'.
        ENDIF.
      ENDIF.

      PERFORM return_message_issue USING ps_issue
                                    lv_result
                                    lv_message
                                    ls_headret-mat_doc
                                    ls_headret-doc_year.
* 자재 투입 취소 로그 데이터 저장(ZGTPPT3070)
      PERFORM save_log_zgtppt3070 USING ps_issue pv_system_id pv_mode.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_cancelled_process
*&---------------------------------------------------------------------*
FORM update_cancelled_process TABLES pt_zgtppt3100 STRUCTURE zgtppt3100
                                                                    pt_zgtppt3101 STRUCTURE zgtppt3101
                                                         USING ps_3101 LIKE zgtppt3101.

  LOOP AT pt_zgtppt3101 INTO DATA(ls_zgtppt3101)
                                        WHERE budat EQ ps_3101-budat
                                             AND mblnr EQ ps_3101-mblnr
                                             AND mjahr EQ ps_3101-mjahr.

    UPDATE zgtppt3101 SET       cancelled = 'X'
                                                chdat        = sy-datum
                                                chtim        = sy-uzeit
                                                chnam      = sy-uname
                                   WHERE weblnr   EQ ls_zgtppt3101-weblnr
                                        AND weblpos EQ ls_zgtppt3101-weblpos
                                        AND seqno    EQ ls_zgtppt3101-seqno.

    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.

    UPDATE zgtppt3100 SET       process = 'D'
                                                chdat        = sy-datum
                                                chtim        = sy-uzeit
                                                chnam      = sy-uname
                                   WHERE weblnr   EQ ls_zgtppt3101-weblnr
                                        AND weblpos EQ ls_zgtppt3101-weblpos.
    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_process_zgtppt3100
*&---------------------------------------------------------------------*
FORM update_process_zgtppt3100 TABLES pt_zgtppt3100 STRUCTURE zgtppt3100.

  LOOP AT pt_zgtppt3100 INTO DATA(ls_zgtppt3100).

    UPDATE zgtppt3100 SET        process = 'D'
                                               chdat        = sy-datum
                                               chtim        = sy-uzeit
                                               chnam      = sy-uname
                                   WHERE weblnr   EQ ls_zgtppt3100-weblnr
                                        AND weblpos EQ ls_zgtppt3100-weblpos.
    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_tagnr_RC
*&---------------------------------------------------------------------*
FORM create_tagnr_rc USING ps_issue TYPE zgtppt3070
                                     p_mode
                                     pv_document
                                     pv_year.

  CLEAR : gv_charg, gv_menge2.
* SRM2405-07266 2024.05.23 입고-투입 꼬리표 미관리, 꼬리표 잔량 업데이트 수정
*ZPPT0001에 입고 꼬리표 존재 여부 확인
  IF gt_batch[] IS NOT INITIAL.

    LOOP AT gt_batch INTO gs_batch.
      gv_charg = gs_batch-charg.
      gv_menge2 = gs_batch-menge.
      PERFORM update_tagnr USING ps_issue p_mode pv_document pv_year.
    ENDLOOP.

  ELSE.

    gv_charg = ps_issue-charg.
    gv_menge2 = gv_menge.
    PERFORM update_tagnr USING ps_issue p_mode pv_document pv_year.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_mska
*&---------------------------------------------------------------------*
FORM get_data_mska USING       pv_matnr
                                                     pv_werks
                                                     pv_lgort
                                                     pv_charg
                                   CHANGING ps_mska LIKE mska.

  IF pv_charg IS NOT INITIAL.  "2025.07.28 원자재 투입은 하기 로직 제외 PYS

    CLEAR ps_mska.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF @ps_mska
                                FROM mska
                                WHERE matnr = @pv_matnr
                                     AND werks = @pv_werks
                                     AND lgort   = @pv_lgort
                                     AND charg = @pv_charg
                                     AND kalab > 0.                        "2025.01.31 가용재고 존재 건만 pys

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_batch_master
*&---------------------------------------------------------------------*
FORM check_batch_master USING pv_error.

  DATA : ls_ymcha TYPE mcha,
         lv_kdauf LIKE afpo-kdauf,
         lv_kdpos LIKE afpo-kdpos.

  DATA : lv_objectkey          LIKE  bapi1003_key-object,
         ls_allocvaluesnumnew	 LIKE bapi1003_alloc_values_num,
         lt_allocvaluesnumnew  LIKE TABLE OF  bapi1003_alloc_values_num,
         ls_allocvaluescharnew LIKE bapi1003_alloc_values_char,
         lt_allocvaluescharnew LIKE TABLE OF  bapi1003_alloc_values_char,
         ls_allocvaluescurrnew LIKE	bapi1003_alloc_values_curr,
         lt_allocvaluescurrnew LIKE	TABLE OF bapi1003_alloc_values_curr,
         ls_return             LIKE	bapiret2,
         lt_return             LIKE	TABLE OF bapiret2.

  DATA : lv_cnt(1) TYPE n,
         lv_fs(17).
  FIELD-SYMBOLS : <lv_fs>.
* 수신받은 입고 자재가 배치 관리 대상인지 점검
  SELECT SINGLE mandt INTO @sy-mandt
   FROM marc
   WHERE werks = @gs_tab-werks
        AND matnr = @gs_tab-matnr
        AND xchpf NE @space.

  IF sy-subrc = 0.
* 배치마스터가 존재하는 지 확인
    SELECT SINGLE mandt INTO @sy-mandt
                    FROM mcha
                    WHERE matnr = @gs_tab-matnr
                         AND werks = @gs_tab-werks
                         AND charg = @gs_tab-charg.
* 배치마스터가 존재하지 않을 경우 생성
    IF sy-subrc <> 0.

      CLEAR : ls_ymcha.
      ls_ymcha-matnr = gs_tab-matnr.
      ls_ymcha-werks = gs_tab-werks.
      ls_ymcha-charg = gs_tab-charg.
      SELECT SINGLE c~zpjno, a~job_no, b~kdauf, b~kdpos
                   INTO ( @ls_ymcha-zzpjt_no, @ls_ymcha-zzjob_no, @lv_kdauf, @lv_kdpos )
                   FROM zgtppt3160 AS a INNER JOIN afpo AS b
                       ON a~aufnr EQ b~aufnr
                       INNER JOIN vbak AS c
                       ON b~kdauf EQ c~vbeln
                       WHERE a~aufnr EQ @gs_tab-aufnr.
      SPLIT gs_tab-atnam01 AT ',' INTO ls_ymcha-zzline_no ls_ymcha-zzserial_info.
* Serial 별 총 길이, 총 중량 산출
      CLEAR : gs_3150, lv_cnt, gv_atwrt.
      SELECT SINGLE * INTO CORRESPONDING FIELDS OF @gs_3150
                      FROM zgtppt3150
                      WHERE job_no EQ @ls_ymcha-zzjob_no
                           AND line_no EQ @ls_ymcha-zzline_no
                           AND serial_info EQ @ls_ymcha-zzserial_info.

      DO 7 TIMES.

        lv_cnt = lv_cnt + 1.
        CONCATENATE 'GS_3150-ZLENGTH_' lv_cnt INTO lv_fs.
        ASSIGN (lv_fs) TO <lv_fs>.
        REPLACE ALL OCCURRENCES OF ',' IN <lv_fs> WITH ''.
        CONDENSE <lv_fs> NO-GAPS.
        IF <lv_fs> IS NOT INITIAL.
          <lv_fs> = <lv_fs> / 1000.
        ENDIF.
        gv_atwrt = gv_atwrt + <lv_fs>.
        CONDENSE gv_atwrt NO-GAPS.

      ENDDO.

      CALL FUNCTION 'VB_CREATE_BATCH'
        EXPORTING
          ymcha                        = ls_ymcha
        EXCEPTIONS
          no_material                  = 1
          no_batch                     = 2
          no_plant                     = 3
          material_not_found           = 4
          plant_not_found              = 5
          stoloc_not_found             = 6
          lock_on_material             = 7
          lock_on_plant                = 8
          lock_on_batch                = 9
          lock_system_error            = 10
          no_authority                 = 11
          batch_exist                  = 12
          stoloc_exist                 = 13
          illegal_batch_number         = 14
          no_batch_handling            = 15
          no_valuation_area            = 16
          valuation_type_not_found     = 17
          no_valuation_found           = 18
          error_automatic_batch_number = 19
          cancelled                    = 20
          wrong_status                 = 21
          interval_not_found           = 22
          number_range_not_extern      = 23
          object_not_found             = 24
          error_check_batch_number     = 25
          no_external_number           = 26
          no_customer_number           = 27
          no_class                     = 28
          error_in_classification      = 29
          inconsistency_in_key         = 30
          region_of_origin_not_found   = 31
          country_of_origin_not_found  = 32
          vendor_error                 = 33
          OTHERS                       = 34.

      IF sy-subrc = 0.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
* 판매 오더 특성을 CDS VIEW에서 취합
        CLEAR : gt_cls, gt_cls[].
        SELECT atfor, atnam, atflv, atflb, atwrt
             INTO CORRESPONDING FIELDS OF TABLE @gt_cls
             FROM zgtmm_cv_bd_get_vcofso
             WHERE vbeln = @lv_kdauf
                  AND posnr = @lv_kdpos
                  AND werks = @gs_tab-werks.
* 관련 데이터가 없으면 아래 추가 업데이트 로직을 패스하고 바로 입고 BAPI 진행
        CLEAR : lv_objectkey, ls_return, lt_return, lt_allocvaluesnumnew,
                     lt_allocvaluescharnew, lt_allocvaluescurrnew.

        IF gt_cls[] IS NOT INITIAL.

          LOOP AT gt_cls.
            PERFORM set_cls TABLES lt_allocvaluesnumnew.
            PERFORM set_cls TABLES lt_allocvaluescharnew.
            PERFORM set_cls TABLES lt_allocvaluescurrnew.
          ENDLOOP.

          lv_objectkey = gs_tab-matnr && gs_tab-charg.
          CALL FUNCTION 'BAPI_OBJCL_CHANGE'
            EXPORTING
*             objectkey          = lv_objectkey                                                             "2025.03.28 pys 수정
              objectkey          = CONV objnum( gs_tab-matnr && gs_tab-charg )    "2025.03.28 pys 수정
              objecttable        = 'MCH1'
              classnum           = 'FT_NBD_GENERAL_001'
              classtype          = '023'
            TABLES
              allocvaluesnumnew  = lt_allocvaluesnumnew
              allocvaluescharnew = lt_allocvaluescharnew
              allocvaluescurrnew = lt_allocvaluescurrnew
              return             = lt_return.
* 에러 건이 있으면 Rollback 처리 후 I/F 오류 Return
          IF line_exists( lt_return[ type = 'E' ] ).

            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            DATA(lv_msg) = gs_tab-matnr && TEXT-e86.
            PERFORM return_message_tab USING 'E'
                                     lv_msg
                                     '  '
                                     '  '.
            pv_error = 'X'.
            EXIT.

          ELSE.

            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.

          ENDIF.

        ENDIF.

      ELSE.

        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        PERFORM return_message_tab USING 'E'
                                 TEXT-e76
                                 '  '
                                 '  '.
        pv_error = 'X'.
        EXIT.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_common_tab_BD
*&---------------------------------------------------------------------*
FORM check_common_tab_bd USING pv_error.

  DATA : lv_message(220).

* 수신받은 데이터의 WERKS가 존재하는 플랜트 인지 체크
  SELECT SINGLE mandt
   FROM t001w
   WHERE werks = @gs_tab-werks
   INTO @sy-mandt.

  IF sy-subrc <> 0.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e47
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
* 수신받은 데이터의 AUFNR이 존재하는 생산오더 인지 체크
  SELECT SINGLE mandt
   FROM aufk
   WHERE aufnr = @gs_tab-aufnr
   INTO @sy-mandt.

  IF sy-subrc <> 0.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e48
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
* 수신받은 데이터의 MATNR이 존재하는 자재번호 인지 체크
  SELECT matnr
    INTO TABLE @DATA(lt_marc)
    FROM marc
    WHERE werks = @gs_tab-werks
     AND  matnr = @gs_tab-matnr
     AND lvorm <> 'X'.

  IF lt_marc IS INITIAL.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e49
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 수신받은 데이터의 AUFNR, POSNR, MATNR이 정상적인 정보인지 정합성 체크
  SELECT SINGLE mandt
    FROM afpo
    WHERE aufnr  = @gs_tab-aufnr
         AND posnr = @gs_tab-posnr
         AND matnr = @gs_tab-matnr
         INTO @sy-mandt.

  IF sy-subrc <> 0.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e62
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 입고 수량
  IF gs_tab-menge < 0.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e63
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 저장 위치
  IF gs_tab-lgort IS INITIAL.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e64
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 입고 단위
  IF gs_tab-meins IS INITIAL.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e65
                                     '  '
                                     '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 자재 문서
  IF gs_tab-mjahr IS NOT INITIAL AND
     gs_tab-mblnr IS NOT INITIAL.

    SELECT mblnr
      INTO TABLE @DATA(lt_mseg)
      FROM mseg
      WHERE mblnr = @gs_tab-mblnr
       AND  mjahr = @gs_tab-mjahr
       AND  bwart = '101'
       AND  matnr = @gs_tab-matnr
       AND  aufnr = @gs_tab-aufnr.

    IF lt_mseg IS INITIAL.
      PERFORM return_message_tab USING 'E'
                                       TEXT-e66
                                       '  '
                                       '  '.
      pv_error = 'X'.
      EXIT.
    ENDIF.
  ENDIF.
*- 생산오더 상태
  PERFORM get_status_tab USING pv_error.

  IF pv_error = 'X'.
    PERFORM return_message_tab USING 'E'
                                     TEXT-e67
                                     '  '
                                     '  '.
  ENDIF.
*- 수신 받은 데이터의 자재 코드가 배치 관리 대상일 경우 수신 받은 배치 번호가 비었는 지 체크
  SELECT SINGLE mandt INTO @sy-mandt FROM marc
                                        WHERE matnr EQ @gs_tab-matnr
                                             AND werks EQ @gs_tab-werks
                                             AND xchar EQ 'X'.
  IF sy-subrc = 0 AND gs_tab-charg IS INITIAL.
    PERFORM return_message_tab USING 'E'
                                    TEXT-e77
                                    '  '
                                    '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 수신 받은 데이터의 시작일자와 전기일자의 월 체크
  SELECT SINGLE gstrp INTO @DATA(lv_gstrp) FROM afko
                                     WHERE aufnr EQ @gs_tab-aufnr.
  IF lv_gstrp+0(6) NE gs_tab-budat+0(6).
    PERFORM return_message_tab USING 'E'
                                    TEXT-e85
                                    '  '
                                    '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 라인 번호 및 시리얼 번호 체크
  IF gs_tab-atnam01 IS INITIAL.
    PERFORM return_message_tab USING 'E'
                                    TEXT-m27
                                    '  '
                                    '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.

*- 25.09.29 Strart 생산오더 Lock 점검 추가
  PERFORM check_prodordconf_create_lock2
                                   USING  gs_tab-aufnr
                                               pv_error
                                               lv_message
                                               ' '
                                               ' '.

  IF pv_error = 'X'.

    PERFORM return_message_tab USING 'E'
                                       lv_message
                                       '  '
                                       '  '.
  ENDIF.
*- 25.09.29 End 생산오더 Lock 점검 추가

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_common_issue_bd
*&---------------------------------------------------------------------*
FORM check_common_issue_bd  USING ps_issue TYPE zgtppt3070
                                                          pv_error
                                                          pv_mode TYPE char02.

  DATA : lv_message(220).
  DATA : lv_mode(2).

*- 플랜트
  SELECT SINGLE mandt
   FROM t001w
   WHERE werks = @ps_issue-werks
   INTO @sy-mandt.

  IF sy-subrc <> 0.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e47
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 생산오더 번호
  SELECT SINGLE mandt
    FROM aufk
    WHERE aufnr = @ps_issue-aufnr
    INTO @sy-mandt.

  IF sy-subrc <> 0.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e48
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 자재 번호
  SELECT matnr
    INTO TABLE @DATA(lt_marc)
    FROM marc
    WHERE werks = @ps_issue-werks
     AND  matnr = @ps_issue-matnr
     AND lvorm <> 'X'.

  IF lt_marc IS INITIAL.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e49
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 출고수량
  IF ps_issue-menge <= 0.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e50
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 저장 위치
  IF ps_issue-lgort IS INITIAL.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e51
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 출고단위
  IF ps_issue-meins IS INITIAL.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e52
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.
*- 생산오더 상태
  PERFORM get_status USING ps_issue
                           pv_error.

  IF pv_error = 'X'.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e53
                                       '  '
                                       '  '.
  ENDIF.
*- 꼬리표 체크
  IF ps_issue-tagnr IS NOT INITIAL AND ps_issue-zup_tagnr IS INITIAL.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e73
                                       '  '
                                       '  '.
  ENDIF.
* 2024.12.30
  IF pv_mode = 'RC' AND ps_issue-org_zserno IS INITIAL.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e74
                                       '  '
                                       '  '.
  ENDIF.
*- 수신 받은 데이터의 시작일자와 전기일자의 월 체크
  SELECT SINGLE gstrp INTO @DATA(lv_gstrp) FROM afko
                                     WHERE aufnr EQ @ps_issue-aufnr.
  IF lv_gstrp+0(6) NE ps_issue-budat+0(6).
    PERFORM return_message_issue USING ps_issue
                                    'E'
                                    TEXT-e85
                                    '  '
                                    '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.

*- 25.09.29 Strart 생산오더 Lock 점검 추가
  PERFORM check_prodordconf_create_lock2
                                   USING  ps_issue-aufnr
                                               pv_error
                                               lv_message
                                               ps_issue-matnr
                                               'GI'.              "GI

  IF pv_error = 'X'.

    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       lv_message
                                       '  '
                                       '  '.

  ENDIF.
*- 25.09.29 End 생산오더 Lock 점검 추가

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_issue_bd
*&---------------------------------------------------------------------*
FORM check_input_issue_bd USING ps_issue TYPE zgtppt3070
                                         pv_error
                                         pv_i_mode TYPE char02.

  DATA : lv_menge TYPE ekpo-menge,
         lv_xchpf TYPE marc-xchpf.

  CLEAR : lv_menge, gs_stock2, gt_stock2..
* 부스닥트 MES 건에 한정하여 RSNUM 값이 비었을 경우 RESB 점검 로직 패스할 것
  IF ps_issue-rsnum IS NOT INITIAL.
*- 품목 (RSEB의 품목번호 가져오기)
    PERFORM get_rseb USING ps_issue
                                              pv_error.
    IF pv_error = 'X'.
      EXIT.
    ENDIF.

  ENDIF.
*- 재고수량  확인 (배치데이터 유/무에 따라 분리 조회)
  CLEAR : gv_menge, gv_meins.
** 배치번호가 존재하는 경우
* 자재마스터의 배치 관리 지시자로 판단
  CLEAR lv_xchpf.
  SELECT SINGLE xchpf INTO lv_xchpf
               FROM marc
               WHERE werks EQ ps_issue-werks
                   AND matnr EQ ps_issue-matnr.
*  IF ps_issue-charg <> ' '.
  IF lv_xchpf = 'X'.
    IF pv_i_mode = 'P' OR
      ( pv_i_mode = 'R' AND ps_issue-charg IS NOT INITIAL ).
      PERFORM get_mchb USING ps_issue pv_error.
* 투입모드 R일때, I/F 수신받은 배치번호가 없는 경우,
* 신규 로직 구성하여 전기일자 기준 오름차순 추출
    ELSEIF pv_i_mode = 'R' AND ps_issue-charg IS INITIAL.
      PERFORM get_mchb2 USING ps_issue pv_error.
    ENDIF.
* 배치번호가 존재하지 않는 경우
*  ELSEIF ps_issue-charg = ' '.
  ELSEIF lv_xchpf = ' '.
    PERFORM get_mard USING ps_issue
                                               pv_error.
  ENDIF.
*- 단위가 다를 시, 단위 환산/수량 Conversion
  IF pv_i_mode = 'R' AND ps_issue-charg IS INITIAL.

    CLEAR gs_stock2.
    READ TABLE gt_stock2 INTO gs_stock2 INDEX 1.
    IF gs_stock2-meins IS INITIAL OR
      ( ps_issue-meins = gs_stock2-meins ).
      gv_menge = lv_menge = ps_issue-menge.
      gv_meins = ps_issue-meins.
    ELSE." ps_issue-meins <> gs_stock2-meins.

      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          i_matnr              = ps_issue-matnr
          i_in_me              = ps_issue-meins
          i_out_me             = gs_stock2-meins
          i_menge              = ps_issue-menge
        IMPORTING
          e_menge              = lv_menge
        EXCEPTIONS
          error_in_application = 1
          error                = 2
          OTHERS               = 3.
      gv_menge = lv_menge.
      gv_meins  = gs_stock2-meins.

    ENDIF.

  ELSE.

    IF gs_stock-meins IS INITIAL OR
  ( ps_issue-meins = gs_stock-meins ).

      gv_menge = lv_menge = ps_issue-menge.
      gv_meins = ps_issue-meins.

    ELSE. "IF ps_issue-meins <> gs_stock-meins.

      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          i_matnr              = ps_issue-matnr
          i_in_me              = ps_issue-meins
          i_out_me             = gs_stock-meins
          i_menge              = ps_issue-menge
        IMPORTING
          e_menge              = lv_menge
        EXCEPTIONS
          error_in_application = 1
          error                = 2
          OTHERS               = 3.
      gv_menge = lv_menge.
      gv_meins  = gs_stock-meins.
    ENDIF.
*- 수량 체크
    IF gs_stock-clabs < lv_menge.

      PERFORM return_message_issue USING ps_issue
                                         'E'
                                         TEXT-e59
                                         '  '
                                         '  '.
      pv_error = 'X'.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_goodsmvt_create_tab_bd
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_create_tab_bd USING pv_system_id TYPE char04.

  DATA : lt_return TYPE TABLE OF bapiret2,
         lv_batch  LIKE bapibatchkey-batch.

  DATA : lv_factor,
         ls_attr   TYPE bapibatchatt,
         ls_ctrl   LIKE bapibatchctrl.

  DATA: lt_bats    TYPE TABLE OF zcharbats,
        lt_batvals TYPE TABLE OF zcharvals,
        lr_atnamb  TYPE TABLE OF eampic_sel_atnam.

  DATA: lv_chk.

  DATA : ls_header   TYPE bapi2017_gm_head_01,
         lv_code     TYPE bapi2017_gm_code VALUE '02',
         lv_document TYPE bapi2017_gm_head_ret-mat_doc,
         lv_year     TYPE bapi2017_gm_head_ret-doc_year,
         lv_message  TYPE bapiret2-message,
         lt_item     TYPE TABLE OF bapi2017_gm_item_create.
  DATA : lv_documentheader_text	TYPE bapi2017_gm_head_01-header_txt.

  CLEAR: lt_return.
* I/F 수신받은 FOSTER 값이 존재시 진행. 없다면 바로 입고 처리
  IF gs_tab-foster IS NOT INITIAL.

    SELECT SINGLE a~mandt
      INTO @sy-mandt
      FROM mara AS a INNER JOIN marc AS b
           ON a~matnr EQ b~matnr
     WHERE a~matnr EQ @gs_tab-matnr
          AND b~werks EQ @gs_tab-werks
          AND a~kzwsm = 'B'
          AND b~dpcbt = 'A'.

    IF sy-subrc = 0.

      lv_factor = 'X'.
*- Factor 배치
      SELECT SINGLE mandt
        INTO @sy-mandt
        FROM mcha
       WHERE matnr = @gs_tab-matnr
         AND werks = @gs_tab-werks
         AND charg = @gs_tab-charg.
      IF sy-subrc <> 0.
*- 재치가 없는경우 생성
        ls_attr-statuskey = '1'.
        ls_ctrl-doclassify = 'X'.
*___클래스번호
        CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
          EXPORTING
            material       = gs_tab-matnr
            plant          = gs_tab-werks
            classtype      = '023'
          IMPORTING
            class          = ls_ctrl-class_num
          EXCEPTIONS
            no_class_found = 1
            OTHERS         = 2.

        CALL FUNCTION 'BAPI_BATCH_CREATE'
          EXPORTING
            material             = CONV matnr18( gs_tab-matnr )
            batch                = gs_tab-charg
            plant                = gs_tab-werks
            batchattributes      = ls_attr
            batchcontrolfields   = ls_ctrl
            batchstoragelocation = gs_tab-lgort
          TABLES
            return               = lt_return.
*- 실패
        IF line_exists( lt_return[ type = 'E' ] ).

          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          PERFORM return_message_tab USING 'E'
                                           TEXT-e41
                                           ' '
                                           ' '.

          PERFORM save_log_zgtppt3110 USING 'E'
                                               TEXT-e41
                                               '  '
                                               '  '
                                               pv_system_id.
          EXIT.

        ELSE.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

        ENDIF.

      ENDIF.
*- 배치 특성 업데이트
      PERFORM update_tab_batch_values USING '' '' pv_system_id 'X'.
*___배치 특성
      lr_atnamb = VALUE #( ( sign = 'I' option = 'EQ'
                             low = 'SAP_MILLCA_LENGTH' ) ). "조장
      lt_bats   = VALUE #( ( matnr = gs_tab-matnr
                             charg = gs_tab-charg ) ).

      CLEAR : lv_chk.
      DO 10 TIMES.

        CALL FUNCTION 'Z_GET_CHAR_OF_BATCH'
          EXPORTING
            ir_atnam = lr_atnamb
          TABLES
            it_bats  = lt_bats
            et_vals  = lt_batvals.

        READ TABLE lt_bats INTO DATA(wa_bats)
                           WITH KEY matnr = gs_tab-matnr
                                    charg = gs_tab-charg
                                    BINARY SEARCH.
        IF sy-subrc = 0.

          READ TABLE lt_batvals INTO DATA(wa_bvals)
                                WITH KEY objek = wa_bats-objek
                                         atnam = 'SAP_MILLCA_LENGTH'
                                         BINARY SEARCH.
          IF sy-subrc = 0.

            PERFORM check_atwrt_n_foster USING wa_bvals-atwrt
                                               gs_tab-foster
                                               lv_chk.
            IF lv_chk = 'X'.
              EXIT.
            ENDIF.

          ENDIF.

        ENDIF.

        WAIT UP TO '0.5' SECONDS.

      ENDDO.

      IF lv_chk IS INITIAL.

        PERFORM return_message_tab USING 'E'
                                         TEXT-e42
                                         ' '
                                         ' '.

        PERFORM save_log_zgtppt3110 USING 'E'
                                             TEXT-e42
                                             '  '
                                             '  '
                                             pv_system_id.
        EXIT.

      ENDIF.

    ENDIF.

  ENDIF.

  CLEAR : lv_document, lv_year, lt_return, lv_message.

  lv_documentheader_text = gs_tab-atnam01.
  ls_header = VALUE #( pstng_date = gs_tab-budat  "수신 받은 전기일
                       doc_date   = gs_tab-budat  "수신 받은 전기일
                       pr_uname   = sy-uname      "사용자 이름
                       header_txt =  lv_documentheader_text ).  "전표 헤더 텍스트

  lt_item = VALUE #( ( material   = gs_tab-matnr  "수신 받은 입고 자재
                       plant      = gs_tab-werks  "수신 받은 플랜트
                       stge_loc   = gs_tab-lgort  "수신 받은 입고 창고
                       batch      = gs_tab-charg  "수신 받은 배치 번호
                       move_type  = '101'         "이동유형
                       entry_qnt  = COND #( WHEN lv_factor = 'X' THEN gs_tab-erfmg
                                                                 ELSE gs_tab-menge )  "수신 받은 입고 수량
                       entry_uom  = COND #( WHEN lv_factor = 'X' THEN gs_tab-erfme
                                                                 ELSE gs_tab-meins )  "수신 받은 입고 단위
                       orderid    = gs_tab-aufnr  "수신 받은 오더 번호
                       order_itno = gs_tab-posnr "수신 받은 오더 품목 번호
*- Start 2024.12.13
                       item_text = gs_tab-tagnr "수신받은 꼬리표
*- End 2024.12.13
                       prod_date  = gs_tab-hsdat  "제조일
                       mvt_ind    = 'F' "이동지시자
                       amount_lc = '0' ) ).

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_header
      goodsmvt_code    = lv_code
    IMPORTING
      materialdocument = lv_document
      matdocumentyear  = lv_year
    TABLES
      goodsmvt_item    = lt_item
      return           = lt_return.
*- 실패
  IF line_exists( lt_return[ type = 'E' ] ).

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-e43.
    ENDIF.

    PERFORM return_message_tab USING 'E'
                                     lv_message
                                     '  '
                                     '  '.

    PERFORM save_log_zgtppt3110 USING 'E'
                                          lv_message
                                          '  '
                                          '  '
                                          pv_system_id.
*- 성공
  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    lv_message = VALUE #( lt_return[ type = 'S' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-s07.
    ENDIF.

    PERFORM return_message_tab USING 'S'
                                     lv_message
                                     lv_year
                                     lv_document.

    PERFORM save_log_zgtppt3110 USING 'S'
                                         lv_message
                                         lv_year
                                         lv_document
                                         pv_system_id.
**- Start 2025.01.23 부스닥트 건은 배치와 꼬리표 업데이트 수행하지 않음.
*    IF pv_system_id EQ 'KPCM'.
*
*      PERFORM update_tab_batch_values USING lv_year lv_document pv_system_id ''.
**- 꼬리표 생성 및 업데이트
*      PERFORM create_tab_tagnr USING lv_document lv_year.
*
*    ENDIF.
**- End 2025.01.23
*- Start 2025.06.24
*- 생산오더 전송 프로그램 호출(ZGTPPI2010)
*    PERFORM gr_call_transaction_zgtppi2010.
*- End 2025.06.24
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_goodsmvt_cancel_tab_bd
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_cancel_tab_bd USING pv_system_id TYPE char04.

  DATA : ls_headret TYPE bapi2017_gm_head_ret,
         lt_return  TYPE TABLE OF bapiret2,
         lv_message TYPE bapiret2-message.
  DATA : lv_documentheader_text	TYPE bapi2017_gm_head_02-header_txt,
         lv_budat_mkpf          LIKE mseg-budat_mkpf.

  CLEAR : ls_headret, lt_return, lv_message, lv_budat_mkpf.
  SELECT SINGLE budat_mkpf INTO @lv_budat_mkpf
                 FROM mseg
                 WHERE mblnr = @gs_tab-mblnr
                      AND mjahr = @gs_tab-mjahr
                      AND bwart = '101'
                      AND matnr = @gs_tab-matnr
                      AND aufnr = @gs_tab-aufnr.

  lv_documentheader_text = gs_tab-atnam01.
  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      materialdocument    = gs_tab-mblnr
      matdocumentyear     = gs_tab-mjahr
      goodsmvt_pstng_date = lv_budat_mkpf
*     goodsmvt_pstng_date = gs_tab-budat
      goodsmvt_pr_uname   = sy-uname
      documentheader_text = lv_documentheader_text
    IMPORTING
      goodsmvt_headret    = ls_headret
    TABLES
      return              = lt_return.
*- 실패
  IF line_exists( lt_return[ type = 'E' ] ).

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-e70.
    ENDIF.

    PERFORM return_message_tab USING 'E'
                                     lv_message
                                     ls_headret-doc_year
                                     ls_headret-mat_doc.

    PERFORM save_log_zgtppt3110 USING 'E'
                                         lv_message
                                         ls_headret-doc_year
                                         ls_headret-mat_doc
                                         pv_system_id.

*- 성공
  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    lv_message = VALUE #( lt_return[ type = 'S' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-s10.
    ENDIF.

    PERFORM return_message_tab USING 'S'
                                     lv_message
                                     ls_headret-doc_year
                                     ls_headret-mat_doc.

    PERFORM save_log_zgtppt3110 USING 'S'
                                         lv_message
                                         ls_headret-doc_year
                                         ls_headret-mat_doc
                                         pv_system_id.
**- Start 2025.01.23
*    IF pv_system_id EQ 'KPCM'.
**- 꼬리표 생성 및 업데이트
*      PERFORM create_tab_tagnr USING ls_headret-mat_doc
*                                                             ls_headret-doc_year.
*
*    ENDIF.
**- End 2025.01.23
*- Start 2025.06.24
**- 생산오더 전송 프로그램 호출(ZGTPPI2010)
*    PERFORM gr_call_transaction_zgtppi2010.
*- End 2025.06.24
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cls
*&---------------------------------------------------------------------*
FORM set_cls TABLES pt_val.

  ASSIGN COMPONENT 'CHARACT' OF STRUCTURE pt_val TO FIELD-SYMBOL(<lfs_act>).
  <lfs_act> = gt_cls-atnam.

  CASE gt_cls-atfor.
    WHEN 'NUM' OR 'CURR'.
      ASSIGN COMPONENT 'VALUE_FROM' OF STRUCTURE pt_val TO FIELD-SYMBOL(<lfs_from>).
      ASSIGN COMPONENT 'VALUE_TO'   OF STRUCTURE pt_val TO FIELD-SYMBOL(<lfs_to>).

      CHECK <lfs_from> IS ASSIGNED.
      <lfs_from> = gt_cls-atflv.
      <lfs_to>   = gt_cls-atflb.

    WHEN 'CHAR'.
      ASSIGN COMPONENT 'VALUE_CHAR' OF STRUCTURE pt_val TO FIELD-SYMBOL(<lfs_char>).

      CHECK <lfs_char> IS ASSIGNED.
      IF <lfs_act> = 'PD_NBD_CM_LENGTH'. "Serial 총길이
        <lfs_char> = gv_atwrt.
      ELSEIF <lfs_act> = 'PD_NBD_CM_WEIGHT'. "Serial 총중량
        <lfs_char> = gs_3150-zweight.
        CONDENSE <lfs_char>.                             "2025.03.28 pys 공백 제거
      ELSE.
        <lfs_char> = gt_cls-atwrt.
      ENDIF.

    WHEN OTHERS.
      EXIT.

  ENDCASE.

  APPEND pt_val.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form conversion_exit_matn1_input
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM conversion_exit_matn1_input  USING pv_matnr.

  CHECK pv_matnr IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input  = pv_matnr
    IMPORTING
      output = pv_matnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conversion_exit_matn1_output
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM conversion_exit_matn1_output  USING pv_matnr.

  CHECK pv_matnr IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      input  = pv_matnr
    IMPORTING
      output = pv_matnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_prod_vers_in_prod_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM change_prod_vers_in_prod_order USING pv_system_id pv_error.
  DATA lt_return  TYPE TABLE OF bapi_order_return.
  DATA ls_return  TYPE bapiret2.
  DATA lv_message TYPE zgtppsif0014-zerp_message.

  CLEAR pv_error.

  SELECT mkal~matnr, mkal~werks, mkal~verid
    INTO TABLE @DATA(lt_mkal)
    FROM mkal
   WHERE mkal~werks EQ @gs_order-werks
     AND mkal~verid EQ @gs_orderdata-plnfl
     AND mkal~matnr IN ( SELECT matnr FROM afpo WHERE aufnr EQ @gs_orderdata-aufnr ).

  IF lt_mkal IS INITIAL.
    MESSAGE e025 WITH gs_orderdata-plnfl INTO lv_message.
    PERFORM fill_log_data USING gc_e pv_system_id lv_message.
    pv_error = gc_x.
    RETURN.
  ENDIF.

*// 생산오더 생산버전 변경.
  PERFORM change_verid_of_prod_order USING gs_orderdata-aufnr gs_orderdata-plnfl ls_return.

  IF ls_return-type EQ gc_e.
    PERFORM fill_log_data USING gc_e pv_system_id ls_return-message.
    pv_error = gc_x.
    RETURN.
  ENDIF.

  WAIT UP TO '0.5' SECONDS.

*// 생산오더 릴리즈.
  PERFORM release_prod_order TABLES lt_return USING gs_orderdata-aufnr.

  IF NOT line_exists( lt_return[ type = gc_e ] ).
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    PERFORM fill_log_data USING gc_s pv_system_id TEXT-s29.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    pv_error = gc_x.

    lv_message = VALUE #( lt_return[ type = gc_e ]-message OPTIONAL ).
    PERFORM fill_log_data USING gc_s pv_system_id lv_message.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form operation_change_for_tandem
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM operation_change_for_tandem  TABLES pt_operation STRUCTURE bapi_order_operation1
                                   USING pv_system_id.

  READ TABLE pt_operation[] INTO DATA(ls_operation) WITH KEY operation_number = gs_orderdata-vornr.

*// 생산오더 공정의 탄뎀 여부.
  READ TABLE gt_zgtppt1010 INTO DATA(ls_zgtppt1010) WITH KEY fld_01 = pv_system_id
                                                             fld_02 = gs_order-werks
                                                             fld_04 = ls_operation-work_center BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    IF ls_zgtppt1010-fld_06 EQ TEXT-t01.
      PERFORM fill_log_data USING gc_e pv_system_id TEXT-m56.
      RETURN.
    ENDIF.

    DATA(lv_tandem) = abap_true.
  ENDIF.

*// 변경할려는 공정의 탄뎀 여부.
  READ TABLE gt_zgtppt1010 INTO ls_zgtppt1010 WITH KEY fld_01 = pv_system_id
                                                       fld_02 = gs_order-werks
                                                       fld_04 = gs_orderdata-arbpl BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    IF ls_zgtppt1010-fld_06 EQ TEXT-t01.
      PERFORM fill_log_data USING gc_e pv_system_id TEXT-m56.
      RETURN.
    ENDIF.

    DATA(lv_to_tandem) = abap_true.
  ENDIF.

  IF lv_tandem EQ abap_false AND lv_to_tandem EQ abap_true.
    PERFORM change_from_normal_to_tandem USING pv_system_id. "// 일반 >> 탄뎀 공정으로 변경.
  ELSEIF lv_tandem EQ abap_true AND lv_to_tandem EQ abap_false.
    PERFORM change_from_tandem_to_normal USING pv_system_id. "// 탄뎀 >> 일반 공정으로 변경.
  ELSE.
    PERFORM change_operation_data USING pv_system_id.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_from_normal_to_tandem
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM change_from_normal_to_tandem USING pv_system_id.
  DATA lt_return  TYPE TABLE OF bapi_order_return.
  DATA ls_return  TYPE bapiret2.
  DATA lv_message TYPE zgtppsif0014-zerp_message.

*// 전 공정 생산오더.
  SELECT SINGLE reord
    INTO @DATA(lv_reord)
    FROM zgtppt2010
   WHERE ordnr EQ @gs_orderdata-aufnr
     AND ordty EQ 'PRD'.

  IF sy-subrc IS NOT INITIAL OR lv_reord IS INITIAL.
    PERFORM fill_log_data USING gc_e pv_system_id TEXT-m57.
    RETURN.
  ENDIF.

*// 탄뎀 생산버전 생성 여부.
  SELECT mkal~matnr, mkal~werks, mkal~verid
    INTO TABLE @DATA(lt_mkal)
    FROM mkal
   WHERE mkal~werks EQ @gs_order-werks
     AND mkal~verid EQ @gc_verid-td10
     AND mkal~matnr IN ( SELECT matnr FROM afpo WHERE aufnr EQ @gs_orderdata-aufnr ).

  IF lt_mkal IS INITIAL.
    MESSAGE e025 WITH gc_verid-td10 INTO lv_message.
    PERFORM fill_log_data USING gc_e pv_system_id lv_message.
    RETURN.
  ENDIF.

*// 전 공정 생산오더의 상태를 CRTD로 변경.
  SELECT SINGLE verid INTO @DATA(lv_verid) FROM afpo WHERE aufnr EQ @lv_reord.

  PERFORM change_verid_of_prod_order USING lv_reord lv_verid ls_return.

  IF ls_return-type EQ gc_e.
    PERFORM fill_log_data USING gc_e pv_system_id ls_return-message.
    RETURN.
  ENDIF.

*// 생산오더 생산버전을 "TD10"로 변경.
  PERFORM change_verid_of_prod_order USING gs_orderdata-aufnr gc_verid-td10 ls_return.

  IF ls_return-type EQ gc_e.
    PERFORM fill_log_data USING gc_e pv_system_id ls_return-message.
    RETURN.
  ENDIF.

  WAIT UP TO '0.5' SECONDS.

*// 생산오더 릴리즈.
  PERFORM release_prod_order TABLES lt_return USING gs_orderdata-aufnr.

  IF NOT line_exists( lt_return[ type = gc_e ] ).
    UPDATE aufk
       SET zztandem = 'Y'
     WHERE aufnr EQ gs_orderdata-aufnr.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    PERFORM fill_log_data USING gc_s pv_system_id TEXT-s01.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    lv_message = VALUE #( lt_return[ type = gc_e ]-message OPTIONAL ).
    PERFORM fill_log_data USING gc_s pv_system_id lv_message.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_from_tandem_to_normal
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM change_from_tandem_to_normal USING pv_system_id.
  DATA lt_return  TYPE TABLE OF bapi_order_return.
  DATA ls_return  TYPE bapiret2.
  DATA lv_message TYPE zgtppsif0014-zerp_message.

*// 전공정 생산오더.
  SELECT SINGLE reord
    INTO @DATA(lv_reord)
    FROM zgtppt2010
   WHERE ordnr EQ @gs_orderdata-aufnr
     AND ordty EQ 'PRD'.

  IF sy-subrc IS NOT INITIAL OR lv_reord IS INITIAL.
    PERFORM fill_log_data USING gc_e pv_system_id TEXT-m57.
    RETURN.
  ENDIF.

*// 생산버전 생성 여부.
  SELECT mkal~matnr, mkal~werks, mkal~verid
    INTO TABLE @DATA(lt_mkal)
    FROM mkal
   WHERE mkal~werks EQ @gs_order-werks
     AND mkal~verid EQ @gc_verid-1000
     AND mkal~matnr IN ( SELECT matnr FROM afpo WHERE aufnr EQ @gs_orderdata-aufnr ).

  IF lt_mkal IS INITIAL.
    MESSAGE e025 WITH gc_verid-1000 INTO lv_message.
    PERFORM fill_log_data USING gc_e pv_system_id lv_message.
    RETURN.
  ENDIF.

*// 전공정 생산오더 릴리즈.
  PERFORM release_prod_order TABLES lt_return USING lv_reord.

  IF line_exists( lt_return[ type = gc_e ] ).
    lv_message = VALUE #( lt_return[ type = gc_e ]-message OPTIONAL ).
    PERFORM fill_log_data USING gc_s pv_system_id lv_message.

    RETURN.
  ENDIF.

*// 생산오더 생산버전을 "1000"으로 변경.
  PERFORM change_verid_of_prod_order USING gs_orderdata-aufnr gc_verid-1000 ls_return.

  IF ls_return-type EQ gc_e.
    PERFORM fill_log_data USING gc_e pv_system_id ls_return-message.
    RETURN.
  ENDIF.

  WAIT UP TO '0.5' SECONDS.

*// 생산오더 릴리즈.
  PERFORM release_prod_order TABLES lt_return USING gs_orderdata-aufnr.

  IF NOT line_exists( lt_return[ type = gc_e ] ).
    UPDATE aufk
       SET zztandem = space
     WHERE aufnr EQ gs_orderdata-aufnr.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    PERFORM fill_log_data USING gc_s pv_system_id TEXT-s01.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    lv_message = VALUE #( lt_return[ type = gc_e ]-message OPTIONAL ).
    PERFORM fill_log_data USING gc_s pv_system_id lv_message.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_verid_of_prod_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM change_verid_of_prod_order  USING pv_aufnr
                                       pv_verid
                                       ps_return TYPE bapiret2.

  CLEAR ps_return.

  DATA(ls_orderdata)  = VALUE bapi_pp_order_change( prod_version = pv_verid ).
  DATA(ls_orderdatax) = VALUE bapi_pp_order_changex( prod_version = gc_x ).

  CALL FUNCTION 'BAPI_PRODORD_CHANGE'
    EXPORTING
      number     = pv_aufnr
      orderdata  = ls_orderdata
      orderdatax = ls_orderdatax
    IMPORTING
      return     = ps_return.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RELEASE_prod_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM release_prod_order  TABLES pt_return STRUCTURE bapi_order_return
                          USING pv_aufnr.

  CLEAR pt_return[].

  DATA(lt_orders) = VALUE tb_bapi_order_key( ( order_number = pv_aufnr ) ).

  CALL FUNCTION 'BAPI_PRODORD_RELEASE'
    TABLES
      orders        = lt_orders
      detail_return = pt_return.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form is_system_id_gaon
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM is_system_id_gaon  USING pv_system_id pv_gaon.

  CLEAR pv_gaon.

  IF pv_system_id EQ 'KGPM' OR
     pv_system_id EQ 'KGOM'.
    pv_gaon = abap_true.
  ENDIF.


*  CLEAR pv_gaon.

*  IF pv_system_id EQ zgtpp_if_const=>gc_system_id-kgom OR
*     pv_system_id EQ zgtpp_if_const=>gc_system_id-kgpm.
*    pv_gaon = abap_true.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_dup_gi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_SYSTEM_ID
*&      --> I_MODE
*&      --> LS_ISSUE_ZSERNO
*&      --> LS_ISSUE_ZSERNO
*&      --> LS_ISSUE_WERKS
*&      --> LS_ISSUE_AUFNR
*&      --> LS_ISSUE_RSNUM
*&      --> LS_ISSUE_RSPOS
*&      --> LS_ISSUE_BUDAT
*&      --> LS_ISSUE_MATNR
*&      --> LS_ISSUE_BWART
*&      --> LS_ISSUE_MENGE
*&      --> LS_ISSUE_LGORT
*&      --> LV_DUP_FLAG
*&---------------------------------------------------------------------*
FORM check_dup_gi_1  USING  ps_issue TYPE zgtppt3070
                                               iv_system_id
                                               iv_mode
                                               ov_flag.

  CHECK iv_system_id EQ 'KSCM'. " or     "소재 MOM인 경우만 실행
*        IV_SYSTEM_ID EQ 'KFCM'.       "한미소 MOM 260902

  CLEAR: ov_flag.
*----------------------------------------*
* 1) 테이블 조회
*----------------------------------------*
  "[GT] 생산오더 투입 수신 이력
  SELECT * INTO TABLE @DATA(lt_3070)
    FROM zgtppt3070
   WHERE aufnr      EQ @ps_issue-aufnr
     AND zserno     EQ @ps_issue-zserno
     AND rsnum      EQ @ps_issue-rsnum
     AND rspos       EQ @ps_issue-rspos
     AND budat       EQ @ps_issue-budat
     AND matnr       EQ @ps_issue-matnr
     AND bwart        EQ @ps_issue-bwart
     AND menge      EQ @ps_issue-menge
     AND lgort         EQ @ps_issue-lgort
     AND zerp_stat  EQ 'S'
     AND i_mode     EQ @iv_mode.

  "데이터가 없으면 중복체크종료.
  IF lt_3070[] IS INITIAL.
    EXIT.
  ENDIF.

**----------------------------------------
** 2)matdoc에서 투입 자재문서 취소건 조회
**----------------------------------------
  SELECT smbln AS mblnr
      INTO TABLE @DATA(lt_matdoc)
      FROM matdoc
    WHERE aufnr EQ @ps_issue-aufnr
         AND smbln NE @space
         AND bwart  EQ '262'.

  SORT lt_matdoc BY mblnr.

  LOOP AT lt_3070 ASSIGNING FIELD-SYMBOL(<lt_3070>).

    IF iv_mode EQ 'P'.
      READ TABLE lt_matdoc ASSIGNING FIELD-SYMBOL(<lt_tmp>)
                                 WITH KEY mblnr  = <lt_3070>-mblnr
                                 BINARY SEARCH.

      IF sy-subrc EQ 0 ..
        CLEAR: <lt_3070>-aufnr.
      ENDIF.

    ELSEIF iv_mode EQ 'C'.
      READ TABLE lt_matdoc ASSIGNING FIELD-SYMBOL(<lt_tmpc>)
                             WITH KEY mblnr  = <lt_3070>-zc_mblnr
                             BINARY SEARCH.

      IF  sy-subrc NE 0 .
        CLEAR: <lt_3070>-aufnr.
      ENDIF.
    ENDIF.

  ENDLOOP.

  DELETE lt_3070 WHERE aufnr IS INITIAL.

**----------------------------------------*
** 3) 중복 여부 체크
**----------------------------------------*
  "최근 I/F 일자 순으로 정렬.
  DATA(lv_cnt) = lines( lt_3070 ).
  IF lv_cnt > 1.
    SORT lt_3070 BY ifdat DESCENDING
                             iftim DESCENDING.
  ENDIF.

  "첫번째 라인 읽기.
  READ TABLE lt_3070 INTO DATA(ls_3070) INDEX 1.

  "중복일 경우 리턴메시지와 로그itab에 담기
  IF iv_mode EQ ls_3070-i_mode.

    IF iv_mode EQ 'P'.

      PERFORM return_message_issue USING ps_issue
                                        'S'
                                        ls_3070-zerp_message
                                        ls_3070-mblnr
                                        ls_3070-mjahr.

      ps_issue-mjahr = ls_3070-mjahr.
      ps_issue-mblnr = ls_3070-mblnr.
      ps_issue-zerp_message = ls_3070-zerp_message.

      PERFORM save_log_zgtppt3070 USING ps_issue iv_system_id iv_mode.

    ELSE.

      ps_issue-zc_mblnr = ls_3070-zc_mblnr.
      ps_issue-zc_mjahr =  ls_3070-zc_mjahr.
      ps_issue-zerp_message = ls_3070-zerp_message.

      PERFORM return_message_issue USING ps_issue
                                        'S'
                                        ls_3070-zerp_message
                                        ls_3070-zc_mblnr
                                        ls_3070-zc_mjahr.

      PERFORM save_log_zgtppt3070 USING ps_issue iv_system_id iv_mode.
    ENDIF.

    "중복체크 flag 리턴.
    ov_flag = 'X'.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_dup_gr_1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_TAB
*&      --> I_SYSTEM_ID
*&      --> I_MODE
*&      --> LV_DUP_FLAG
*&---------------------------------------------------------------------*
FORM check_dup_gr_1  USING    ps_gr  TYPE zgtppt3110
                                                 iv_system_id
                                                 iv_mode
                                                 ov_flag.


  CHECK iv_system_id EQ 'KSCM'. " or     "소재 MOM인 경우만 실행
*        IV_SYSTEM_ID EQ 'KFCM' .      "한미소 MOM 260902

  CLEAR: ov_flag.

*----------------------------------------*
* 1) 테이블 조회
*----------------------------------------*
  "[GT] 생산오더 입고 수신 이력
  SELECT * INTO TABLE @DATA(lt_3110)
    FROM zgtppt3110
   WHERE aufnr      EQ @ps_gr-aufnr
     AND zserno      EQ @ps_gr-zserno
     AND charg        EQ @ps_gr-charg
     AND budat       EQ @ps_gr-budat
     AND matnr       EQ @ps_gr-matnr
     AND bwart        EQ @ps_gr-bwart
     AND menge      EQ @ps_gr-menge
     AND zerp_stat  EQ 'S'
     AND i_mode     EQ @iv_mode.

  "데이터가 없으면 중복체크종료.
  IF lt_3110[] IS INITIAL.
    EXIT.
  ENDIF.

**----------------------------------------
** 2)matdoc에서 입고 자재문서 취소건 조회
**----------------------------------------
  SELECT smbln AS mblnr
      INTO TABLE @DATA(lt_matdoc)
      FROM matdoc
    WHERE aufnr EQ @ps_gr-aufnr
         AND smbln NE @space
         AND bwart  EQ '102'.

  SORT lt_matdoc BY mblnr.

  LOOP AT lt_3110 ASSIGNING FIELD-SYMBOL(<lt_3110>).

    IF iv_mode EQ 'P'.
      READ TABLE lt_matdoc ASSIGNING FIELD-SYMBOL(<lt_tmp>)
                                    WITH KEY mblnr  = <lt_3110>-mblnr
                                    BINARY SEARCH.

      IF sy-subrc EQ 0 .
        CLEAR: <lt_3110>-aufnr.
      ENDIF.
    ELSEIF iv_mode EQ 'C'.
      READ TABLE lt_matdoc ASSIGNING FIELD-SYMBOL(<lt_tmpc>)
                               WITH KEY mblnr  = <lt_3110>-zc_mblnr
                               BINARY SEARCH.
      IF sy-subrc NE 0 .
        CLEAR: <lt_3110>-aufnr.
      ENDIF.
    ENDIF.

  ENDLOOP.

  DELETE lt_3110 WHERE aufnr IS INITIAL.

**----------------------------------------*
** 3) 중복 여부 체크
**----------------------------------------*
  "최근 I/F 일자 순으로 정렬.
  DATA(lv_cnt) = lines( lt_3110 ).
  IF lv_cnt > 1.
    SORT lt_3110 BY ifdat DESCENDING
                             iftim DESCENDING.
  ENDIF.

  "첫번째 라인 읽기.
  READ TABLE lt_3110 INTO DATA(ls_3110) INDEX 1.

  "중복일 경우 리턴메시지와 로그itab에 담기
  IF iv_mode EQ ls_3110-i_mode.

    IF iv_mode EQ 'P'.

      PERFORM return_message_tab USING 'S'
                                        ls_3110-zerp_message
                                        ls_3110-mjahr
                                        ls_3110-mblnr.

      ps_gr-mjahr = ls_3110-mjahr.
      ps_gr-mblnr = ls_3110-mblnr.
      ps_gr-zerp_message = ls_3110-zerp_message.

      PERFORM save_log_zgtppt3110 USING 'S'
                                                               ls_3110-zerp_message
                                                               ls_3110-mjahr
                                                               ls_3110-mblnr
                                                               iv_system_id.
    ELSE.

      ps_gr-zc_mblnr = ls_3110-zc_mblnr.
      ps_gr-zc_mjahr =  ls_3110-zc_mjahr.
      ps_gr-zerp_message = ls_3110-zerp_message.

      PERFORM return_message_tab USING 'S'
                                        ls_3110-zerp_message
                                        ls_3110-zc_mjahr
                                        ls_3110-zc_mblnr.

      PERFORM save_log_zgtppt3110 USING 'S'
                                                               ls_3110-zerp_message
                                                               ls_3110-mjahr
                                                               ls_3110-mblnr
                                                               iv_system_id.
    ENDIF.

    "중복체크 flag 리턴.
    ov_flag = 'X'.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TAGNR_REMAIN_CAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ISSUE
*&      --> GV_MENGE
*&      --> GV_MEINS
*&---------------------------------------------------------------------*
FORM set_tagnr_remain_cal  USING ps_issue TYPE zgtppt3070
                                 pv_menge
                                 pv_meins.

  DATA: lv_menge  TYPE ekpo-menge,
        lv_remain TYPE zremain.

  "해당 투입 대상 생산오더의 공정 정보 추출
  SELECT SINGLE pdcaproccode
    FROM zgtcvordsyval
   WHERE werks EQ @ps_issue-werks
     AND aufnr EQ @ps_issue-aufnr
    INTO @DATA(lv_cst).

  CHECK lv_cst EQ 'CST'.

  "투입 대상 자재의 공정 정보 추출
  SELECT SINGLE pdcaproccode
    FROM zgtcvordsyval
   WHERE werks EQ @ps_issue-werks
     AND matnr EQ @ps_issue-matnr
    INTO @DATA(lv_bwd).

  CHECK lv_bwd EQ 'BWD'.

  "BWD 투입 자재(신선)의 꼬리표 정보 및 잔량(REMAIN) 추출
  SELECT SINGLE matnr, tagnr, remain, meins
    FROM zppt0001
   WHERE werks EQ @ps_issue-werks
     AND tagnr EQ @ps_issue-tagnr
     AND charg EQ @ps_issue-charg
     AND matnr EQ @ps_issue-matnr
    INTO @DATA(ls_0001).

  CHECK ls_0001 IS NOT INITIAL.

  "투입 잔량이 2m 이하 인지 체크
  CLEAR: lv_menge.
  IF ls_0001-meins NE ps_issue-meins.
    CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
      EXPORTING
        i_matnr              = ps_issue-matnr
        i_in_me              = ps_issue-meins
        i_out_me             = ls_0001-meins
        i_menge              = ps_issue-menge
      IMPORTING
        e_menge              = lv_menge
      EXCEPTIONS
        error_in_application = 1
        error                = 2
        OTHERS               = 3.
  ELSE.
    lv_menge = ps_issue-menge.
  ENDIF.

  CLEAR: lv_remain.
  lv_remain = ls_0001-remain - lv_menge.

*** Start. 잔량 0보다 크고 2m 보다 작으면 전량 투입. BY ZGISPP03
  CHECK lv_remain BETWEEN '0' AND '2'.

*  GV_MENGE = GV_MENGE + LS_0001-REMAIN.
  gv_menge = ls_0001-remain.    "전체 꼬리표 잔량 투입
*** END. 잔량 0보다 크고 2m 보다 작으면 전량 투입. BY ZGISPP03

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_ISSUE_F
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ISSUE
*&      --> LV_ERROR
*&      --> I_SYSTEM_ID
*&      --> I_MODE
*&---------------------------------------------------------------------*
FORM check_input_issue_f  USING ps_issue TYPE zgtppt3070
                                pv_error
                                pv_system_id TYPE char04
                                pv_i_mode TYPE char02.

  DATA : lv_menge TYPE ekpo-menge,
         lv_xchpf TYPE marc-xchpf.

*- 품목 (RSEB의 품목번호 가져오기)
  PERFORM get_rseb USING ps_issue pv_error.

  IF pv_error = 'X'.
    pv_error = 'E'. "RESB 오류는 에러 리턴하되 ZGTPPT3100에 업데이트 X
    EXIT.
  ENDIF.

  "해당 투입 대상 생산오더의 공정 정보 추출
  SELECT SINGLE pdcaproccode
    FROM zgtcvordsyval
   WHERE werks EQ @ps_issue-werks
     AND aufnr EQ @ps_issue-aufnr
    INTO @DATA(lv_col).

  CHECK lv_col EQ 'COL' OR lv_col EQ 'TBF'.

  "수신한 자재의 자재그룹이 Fiber 인지 확인
  SELECT SINGLE matkl
    FROM mara
   WHERE matnr EQ @ps_issue-matnr
    INTO @DATA(lv_matkl).

  CHECK lv_matkl EQ 'RW600101' OR lv_matkl EQ 'RW600102'.

  CLEAR: gv_menge, gv_meins.

  "Fiber ID(꼬리표) 존재 여부 및 재고량 확인
  CLEAR: gs_0001_fiber.
  SELECT SINGLE *
    FROM zppt0001
   WHERE werks EQ @ps_issue-werks
     AND tagnr EQ @ps_issue-tagnr
     AND matnr EQ @ps_issue-matnr
     AND lgort EQ @ps_issue-lgort
     AND remain > 0
    INTO CORRESPONDING FIELDS OF @gs_0001_fiber.

  "추출 성공 시
  IF gs_0001_fiber IS NOT INITIAL.
    CLEAR: lv_menge.
    "잔량과 투입 수량 비교
    IF ps_issue-meins NE gs_0001_fiber-meins.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          i_matnr              = ps_issue-matnr
          i_in_me              = ps_issue-meins
          i_out_me             = gs_0001_fiber-meins
          i_menge              = ps_issue-menge
        IMPORTING
          e_menge              = lv_menge
        EXCEPTIONS
          error_in_application = 1
          error                = 2
          OTHERS               = 3.

    ELSE.
      lv_menge = ps_issue-menge.
    ENDIF.

    IF gs_0001_fiber-remain < lv_menge.
      PERFORM return_message_issue USING ps_issue
                                         'E'
                                         '해당 투입 자재의 Fiber ID 잔량(재고)이 부족합니다' "TEXT-E59
                                         '  '
                                         '  '.
      pv_error = 'X'.
    ENDIF.

    gv_menge = lv_menge.
    gv_meins = gs_0001_fiber-meins.

    "추출 실패 시
  ELSE.
    "검사성적서의 Fiber ID(꼬리표) 추출 - 기존에 입고된 Fiber ID 인지 확인
    CLEAR: gt_mm9460.
    SELECT SINGLE *
      FROM zgtmmt9460
     WHERE vlabelno EQ @ps_issue-tagnr
      INTO CORRESPONDING FIELDS OF @gs_mm9460.

    IF gs_mm9460 IS INITIAL.
      PERFORM return_message_issue USING ps_issue
                                         'E'
                                         '해당 투입 자재의 Fiber ID는 구매입고 된 적이 없습니다' "TEXT-E59
                                         '  '
                                         '  '.
      pv_error = 'X'.

    ELSE.
      CLEAR: lv_menge.
      "잔량과 투입 수량 비교
      IF ps_issue-meins NE gs_mm9460-meins.
        CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
          EXPORTING
            i_matnr              = ps_issue-matnr
            i_in_me              = ps_issue-meins
            i_out_me             = gs_mm9460-meins
            i_menge              = ps_issue-menge
          IMPORTING
            e_menge              = lv_menge
          EXCEPTIONS
            error_in_application = 1
            error                = 2
            OTHERS               = 3.

      ELSE.
        lv_menge = ps_issue-menge.
      ENDIF.

      "Fiber 입고 수량 확인
      IF gs_mm9460-menge < lv_menge.
        PERFORM return_message_issue USING ps_issue
                                           'E'
                                           '투입 수량보다 Fiber ID 재고 수량이 부족합니다' "TEXT-E59
                                           '  '
                                           '  '.
        pv_error = 'X'.
      ENDIF.

      gv_menge = lv_menge.
      gv_meins = gs_mm9460-meins.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_CREATE_F
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ISSUE
*&      --> I_SYSTEM_ID
*&      --> I_MODE
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_create_f  USING ps_issue TYPE zgtppt3070
                                   pv_system_id TYPE char04
                                   pv_mode TYPE char02.

  "꼬리표 추출 성공 시 Fiber 투입
  IF gs_0001_fiber IS NOT INITIAL.
    PERFORM bapi_goodsmvt_create_f_pp USING ps_issue pv_system_id pv_mode.

    "꼬리표 추출 실패 시 검사성적서의 Fiber 투입 및 꼬리표 생성
  ELSE.
    IF gs_mm9460 IS NOT INITIAL.
      PERFORM bapi_goodsmvt_create_f_mm USING ps_issue pv_system_id pv_mode.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CANCEL_MBLNR_261_F
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ISSUE
*&      --> LV_DOCUMENT
*&      --> LV_YEAR
*&---------------------------------------------------------------------*
FORM cancel_mblnr_261_f  USING    ps_issue TYPE zgtppt3070
                                  pv_document
                                  pv_year
                                  pv_budat. "GO03(+)

  DATA lt_return  TYPE TABLE OF bapiret2.
  DATA ls_headret TYPE bapi2017_gm_head_ret.
  DATA ls_headret1 TYPE bapi2017_gm_head_ret.
  DATA lv_subrc TYPE sysubrc.
  DATA lv_headtext TYPE bktxt.

  CLEAR: ls_headret, lt_return, lv_headtext.
  lv_headtext = ps_issue-zserno.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      materialdocument    = pv_document
      matdocumentyear     = pv_year
      goodsmvt_pstng_date = pv_budat "PS_ISSUE-BUDAT "GO03(+)
      goodsmvt_pr_uname   = sy-uname
      documentheader_text = lv_headtext
    IMPORTING
      goodsmvt_headret    = ls_headret
    TABLES
      return              = lt_return.

  IF ls_headret-mat_doc IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_CREATE_F_PP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ISSUE
*&      --> PV_SYSTEM_ID
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_create_f_pp  USING ps_issue TYPE zgtppt3070
                                      pv_system_id TYPE char04
                                      pv_mode TYPE char02.

  DATA : ls_header      TYPE bapi2017_gm_head_01,
         lv_code03      TYPE bapi2017_gm_code VALUE '03',
         lv_document    TYPE bapi2017_gm_head_ret-mat_doc,
         lv_year        TYPE bapi2017_gm_head_ret-doc_year,
         lv_document311 TYPE bapi2017_gm_head_ret-mat_doc,
         lv_year311     TYPE bapi2017_gm_head_ret-doc_year,
         lv_message     TYPE bapiret2-message,
         lt_item        TYPE TABLE OF bapi2017_gm_item_create,
         ls_item        TYPE bapi2017_gm_item_create,
         lt_return      TYPE TABLE OF bapiret2.

  DATA: lv_budat TYPE budat. "GO03(+)

*- GO03 Start GAON 전기일 설정
  CLEAR: lv_budat.
  IF gv_gaon EQ abap_true.
    PERFORM set_budat USING ps_issue-aufnr ps_issue-budat.
    lv_budat = gv_budat.
  ELSE.
    lv_budat = ps_issue-budat.
  ENDIF.
*- GO03 End GAON 전기일 설정

  CLEAR: gv_hd_text.
  gv_hd_text = 'MES I/F'.

  CLEAR: ls_header, lt_item[].

  ls_header = VALUE #( pstng_date = lv_budat "PS_ISSUE-BUDAT "수신 받은 전기일 "GO03(+)
                       doc_date   = lv_budat "PS_ISSUE-BUDAT "수신 받은 전기일 "GO03(+)
                       pr_uname   = sy-uname       "사용자 이름
                       header_txt = gv_hd_text ).

  lt_item = VALUE #( ( material  = ps_issue-matnr  "수신 받은 출고자재
                       plant     = ps_issue-werks  "수신 받은 플랜트
                       stge_loc  = ps_issue-lgort  "수신 받은 출고 창고
                       batch     = gs_0001_fiber-charg  "수신 받은 배치번호
                       move_type = '261'           "이동유형
                       stck_type = 'F'             "재고유형
                       entry_qnt = gv_menge  "수신 받은 출고 수량( 단위 변환 로직의 수량 반영 )
                       entry_uom = gv_meins  "수신 받은 출고 단위( 단위 변환 로직의 단위 반영 )
                       orderid   = ps_issue-aufnr  "수신 받은 오더번호
                       reserv_no = ps_issue-rsnum  "RESB에서 추출한 예약번호
                       res_item  = ps_issue-rspos  "RESB에서 추출한 예약품목번호
                   ) ).

  CLEAR: lv_message, lv_document, lv_year, lt_return.
*- 투입 처리 (펑션 호출)
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_header
      goodsmvt_code    = lv_code03
    IMPORTING
      materialdocument = lv_document
      matdocumentyear  = lv_year
    TABLES
      goodsmvt_item    = lt_item
      return           = lt_return.

*- 실패
  IF line_exists( lt_return[ type = 'E' ] ).
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-e60.
    ENDIF.

    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       lv_message
                                       lv_document
                                       lv_year.

    PERFORM save_log_zgtppt3070_f USING ps_issue pv_system_id pv_mode.

  ELSE.
*- 성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    lv_message = VALUE #( lt_return[ type = 'S' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-s09.
    ENDIF.

    PERFORM return_message_issue USING ps_issue
                                       'S'
                                       lv_message
                                       lv_document
                                       lv_year.

*- 꼬리표 추적 데이터 생성 및 업데이트
    PERFORM create_tagnr USING ps_issue
                               pv_mode
                               lv_document
                               lv_year.

*- 자재 투입 로그 데이터 저장(ZGTPPT3070)
    PERFORM save_log_zgtppt3070_f USING ps_issue pv_system_id pv_mode.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_CREATE_F_MM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ISSUE
*&      --> PV_SYSTEM_ID
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_create_f_mm  USING ps_issue TYPE zgtppt3070
                                      pv_system_id TYPE char04
                                      pv_mode TYPE char02.

  DATA : ls_header      TYPE bapi2017_gm_head_01,
         lv_code03      TYPE bapi2017_gm_code VALUE '03',
         lv_code04      TYPE bapi2017_gm_code VALUE '04',
         lv_document    TYPE bapi2017_gm_head_ret-mat_doc,
         lv_year        TYPE bapi2017_gm_head_ret-doc_year,
         lv_document311 TYPE bapi2017_gm_head_ret-mat_doc,
         lv_year311     TYPE bapi2017_gm_head_ret-doc_year,
         lv_message     TYPE bapiret2-message,
         lt_item        TYPE TABLE OF bapi2017_gm_item_create,
         ls_item        TYPE bapi2017_gm_item_create,
         lt_return      TYPE TABLE OF bapiret2.

  DATA: lv_charg  TYPE charg_d,
        lv_remain TYPE erfmg.

  DATA: lv_budat TYPE budat. "GO03(+)

*- GO03 Start GAON 전기일 설정
  CLEAR: lv_budat.
  IF gv_gaon EQ abap_true.
    PERFORM set_budat USING ps_issue-aufnr ps_issue-budat.
    lv_budat = gv_budat.
  ELSE.
    lv_budat = ps_issue-budat.
  ENDIF.
*- GO03 End GAON 전기일 설정

  CLEAR: gv_hd_text.
  gv_hd_text = 'MES I/F'.

  CLEAR: ls_header, lt_item[].

  ls_header = VALUE #( pstng_date = lv_budat "PS_ISSUE-BUDAT "수신 받은 전기일 "GO03(+)
                       doc_date   = lv_budat "PS_ISSUE-BUDAT "수신 받은 전기일 "GO03(+)
                       pr_uname   = sy-uname       "사용자 이름
                       header_txt = gv_hd_text ).

  "공통배치(자재코드=배치번호)
  CLEAR: lv_charg.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = ps_issue-matnr
    IMPORTING
      output = lv_charg.

  lt_item = VALUE #( ( material  = ps_issue-matnr  "수신 받은 출고자재
                       plant     = ps_issue-werks  "수신 받은 플랜트
                       stge_loc  = ps_issue-lgort  "수신 받은 출고 창고
                       batch     = lv_charg        "수신 받은 자재번호(공통배치)
                       move_type = '261'           "이동유형
                       stck_type = 'F'             "재고유형
                       entry_qnt = gv_menge  "수신 받은 출고 수량( 단위 변환 로직의 수량 반영 )
                       entry_uom = gv_meins  "수신 받은 출고 단위( 단위 변환 로직의 단위 반영 )
                       orderid   = ps_issue-aufnr  "수신 받은 오더번호
                       reserv_no = ps_issue-rsnum  "RESB에서 추출한 예약번호
                       res_item  = ps_issue-rspos  "RESB에서 추출한 예약품목번호
                   ) ).

  "투입 후 잔량
  CLEAR: lv_remain.
  IF gs_mm9460-menge NE ps_issue-menge.
    lv_remain = gs_mm9460-menge - gv_menge.
  ENDIF.

  CLEAR: lv_message, lv_document, lv_year, lt_return.
*- 투입 처리 (펑션 호출)
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_header
      goodsmvt_code    = lv_code03
    IMPORTING
      materialdocument = lv_document
      matdocumentyear  = lv_year
    TABLES
      goodsmvt_item    = lt_item
      return           = lt_return.

*- 실패
  IF line_exists( lt_return[ type = 'E' ] ).
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
    IF lv_message IS INITIAL.
      lv_message = TEXT-e60.
    ENDIF.

    PERFORM return_message_issue USING ps_issue
                                      'E'
                                      lv_message
                                      lv_document
                                      lv_year.

    PERFORM save_log_zgtppt3070_f USING ps_issue pv_system_id pv_mode.

  ELSE.
*- 성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    "잔량 FiberID 생성
    IF lv_remain NE 0.

      CLEAR: ls_header, lt_item[].

      ls_header = VALUE #( pstng_date = lv_budat "PS_ISSUE-BUDAT "수신 받은 전기일 "GO03(+)
                           doc_date   = lv_budat "PS_ISSUE-BUDAT "수신 받은 전기일 "GO03(+)
                           pr_uname   = sy-uname       "사용자 이름
                           header_txt = ps_issue-zserno ).

      "공통배치(자재코드=배치번호)
      CLEAR: lv_charg.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ps_issue-matnr
        IMPORTING
          output = lv_charg.

      lt_item = VALUE #( ( material   = ps_issue-matnr  "수신 받은 출고자재
                           plant      = ps_issue-werks  "수신 받은 플랜트
                           stge_loc   = ps_issue-lgort  "수신 받은 출고 창고
                           batch      = lv_charg        "수신 받은 자재번호(공통배치)
                           move_type  = '311'           "이동유형
                           stck_type  = 'F'             "재고유형
                           entry_qnt  = lv_remain  "수신 받은 출고 수량( 단위 변환 로직의 수량 반영 )
                           entry_uom  = gv_meins  "수신 받은 출고 단위( 단위 변환 로직의 단위 반영 )
                           move_plant = ps_issue-werks
                           move_stloc = ps_issue-lgort
                           move_batch = ps_issue-charg
                       ) ).

      CLEAR: lv_message, gv_mblnr311, gv_mjahr311, lt_return.
*- 잔량에 대한 꼬리표 생성을 위한 311 처리 (펑션 호출)
      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          goodsmvt_header  = ls_header
          goodsmvt_code    = lv_code04
        IMPORTING
          materialdocument = gv_mblnr311
          matdocumentyear  = gv_mjahr311
        TABLES
          goodsmvt_item    = lt_item
          return           = lt_return.

*- 실패
      IF line_exists( lt_return[ type = 'E' ] ).
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        "261 처리 전표 취소
        PERFORM cancel_mblnr_261_f USING ps_issue lv_document lv_year lv_budat.

        lv_message = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
        IF lv_message IS INITIAL.
          lv_message = 'Fiber ID 잔량 배치 이전전기(311) 처리 중 오류 발생했습니다.'. "TEXT-E60.
        ENDIF.

        CLEAR: lv_document, lv_year.
        PERFORM return_message_issue USING ps_issue
                                          'E'
                                          lv_message
                                          lv_document
                                          lv_year.

        PERFORM save_log_zgtppt3070_f USING ps_issue pv_system_id pv_mode.

      ELSE.
*- 모두성공
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        lv_message = VALUE #( lt_return[ type = 'S' ]-message OPTIONAL ).
        IF lv_message IS INITIAL.
          lv_message = TEXT-s09.
        ENDIF.

        PERFORM return_message_issue USING ps_issue
                                           'S'
                                           lv_message
                                           lv_document
                                           lv_year.

*- 자재 투입 로그 데이터 저장(ZGTPPT3070)
        PERFORM save_log_zgtppt3070_f USING ps_issue pv_system_id pv_mode.

        "잔량으로 311 처리 후 꼬리표 생성
        PERFORM create_tagnr_fiber USING ps_issue pv_mode gv_mblnr311 gv_mjahr311 lv_remain.

      ENDIF.

    ELSE.
      lv_message = VALUE #( lt_return[ type = 'S' ]-message OPTIONAL ).
      IF lv_message IS INITIAL.
        lv_message = TEXT-s09.
      ENDIF.

      PERFORM return_message_issue USING ps_issue
                                         'S'
                                         lv_message
                                         lv_document
                                         lv_year.

*- 자재 투입 로그 데이터 저장(ZGTPPT3070)
      PERFORM save_log_zgtppt3070_f USING ps_issue pv_system_id pv_mode.

      "잔량 0으로 311 처리 없이 꼬리표 생성
      PERFORM create_tagnr_fiber USING ps_issue pv_mode gv_mblnr311 gv_mjahr311 lv_remain.
    ENDIF.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_TAGNR_FIBER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ISSUE
*&      --> PV_MODE
*&      --> LV_DOCUMENT
*&      --> LV_YEAR
*&---------------------------------------------------------------------*
FORM create_tagnr_fiber USING ps_issue TYPE zgtppt3070
                              p_mode
                              pv_document
                              pv_year
                              pv_remain TYPE erfmg.

  DATA: ls_zppt0001 LIKE zppt0001.

  CLEAR: ls_zppt0001.

  ls_zppt0001 = VALUE #( werks   = ps_issue-werks
                         aufnr   = ps_issue-aufnr
                         tagnr   = ps_issue-tagnr
*                       RUECK   = LV_CONF
*                       RMZHL   = LV_RMZHL
                         posnr   = '0001'
*                       VORNR   = LV_VORNR
                         charg   = ps_issue-charg
                         mblnr   = pv_document   "311자재문서
                         matnr   = ps_issue-matnr
                         spgcd   = 'GO'
                         procd   = 'COL'
*                       ARBPL   = LV_ARBPL
                         mgvrg   = pv_remain
                         fostcnt = '1'         "조장수
                         remain  = pv_remain   "수량
                         meins   = gv_meins
                         giflg   = 'N'
                         grflg   = 'Y'
                         inspflg = 'OK'
                         lgort   = ps_issue-lgort
                         wkdat   = sy-datum
                         wkindat = sy-datum
                         wkintim = sy-uzeit
                         wkinnam = sy-uname
                         grindat = sy-datum
                         grintim = sy-uzeit
                         grinnam = sy-uname
*                       GSTRS   = GS_TAB-GSTRS "LV_START   "계획된 시작(일자)
*                       GSUZS   = GS_TAB-GSUZS "LV_STIME   "일정 계획된 시작(시간)
*                       GLTRS   = GS_TAB-GLTRS "LV_FINISH   "계획 종료 (일자)
*                       GLUZS   = GS_TAB-GLUZS "LV_FTIME   "일정 계획 종료 (시간)
*                       PCONT   = '0'
                       ).

  MODIFY zppt0001 FROM ls_zppt0001.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_LOG_ZGTPPT3070_F
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ISSUE
*&      --> PV_SYSTEM_ID
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM save_log_zgtppt3070_f  USING ps_issue TYPE zgtppt3070
                                  pv_system_id TYPE char04
                                  pv_mode TYPE char02.

  DATA : ls_zgtppt3070 TYPE zgtppt3070.
  DATA : lv_timestamp TYPE timestampl.

  CLEAR : lv_timestamp.
  GET TIME STAMP FIELD lv_timestamp.
  ls_zgtppt3070 = VALUE #( zifkey       = lv_timestamp
                           zsystem_id   = pv_system_id
                           zserno       = ps_issue-zserno
                           i_mode       = pv_mode
                           werks        = ps_issue-werks
                           budat        = ps_issue-budat
                           rsnum        = ps_issue-rsnum
                           rspos        = ps_issue-rspos
                           matnr        = ps_issue-matnr
                           charg        = ps_issue-charg
                           aufnr        = ps_issue-aufnr
                           bwart        = ps_issue-bwart
                           menge        = ps_issue-menge
                           meins        = ps_issue-meins
                           lgort        = ps_issue-lgort
                           tagnr        = ps_issue-tagnr
                           zup_tagnr    = ps_issue-zup_tagnr
                           mjahr        = VALUE #( gt_gi_result[ zserno = ps_issue-zserno ]-mjahr OPTIONAL )
                           mblnr        = VALUE #( gt_gi_result[ zserno = ps_issue-zserno ]-mblnr OPTIONAL )
                           pernr        = ps_issue-pernr
                           name         = ps_issue-name
                           zc_mjahr     = ps_issue-mjahr
                           zc_mblnr     = ps_issue-mblnr
                           org_zserno   = ps_issue-org_zserno "2024.12.30
                           mblnr_311    = gv_mblnr311
                           mjahr_311    = gv_mjahr311
                           zerp_stat    = VALUE #( gt_gi_result[ zserno = ps_issue-zserno ]-zerp_stat OPTIONAL )
                           zerp_message = VALUE #( gt_gi_result[ zserno = ps_issue-zserno ]-zerp_message OPTIONAL )
                           ifdat        = sy-datum
                           iftim        = sy-uzeit
                           ifnam        = sy-uname ).

  IF ls_zgtppt3070 IS NOT INITIAL.
    MODIFY zgtppt3070 FROM ls_zgtppt3070.
    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.
  ENDIF.

* ZO_RESULT, ZO_MESSAGE 업데이트를 위한 키필드 반영
  CLEAR gs_gi_keys.
  MOVE-CORRESPONDING ls_zgtppt3070 TO gs_gi_keys.
  APPEND gs_gi_keys TO gt_gi_keys.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CANCEL_ISSUE_FC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ISSUE
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM check_cancel_issue_fc  USING ps_issue TYPE zgtppt3070
                                  pv_error.

  "취소 대상 자재문서 확인
  SELECT SINGLE mblnr, mjahr
    FROM matdoc
   WHERE mblnr EQ @ps_issue-mblnr
     AND mjahr EQ @ps_issue-mjahr
     AND cancelled NE 'X'
     AND bwart EQ '261'
    INTO (@DATA(lv_mblnr), @DATA(lv_mjahr)).

  IF lv_mblnr IS INITIAL.
    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       TEXT-e69
                                       '  '
                                       '  '.
    pv_error = 'X'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_CANCEL_FC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ISSUE
*&      --> I_SYSTEM_ID
*&      --> I_MODE
*&---------------------------------------------------------------------*
FORM bapi_goodsmvt_cancel_fc  USING ps_issue TYPE zgtppt3070
                                    pv_system_id TYPE char04
                                    pv_mode TYPE char02.

  "취소 대상 문서로 311 처리된 문서 추출
  CLEAR: gs_cancel_fc.
  SELECT SINGLE *
    FROM zgtppt3070
   WHERE mblnr EQ @ps_issue-mblnr
     AND mjahr EQ @ps_issue-mjahr
    INTO CORRESPONDING FIELDS OF @gs_cancel_fc.

  "취소 대상 311 문서가 있는 경우 311 전기일 추출
  IF gs_cancel_fc-mblnr_311 IS NOT INITIAL.
    SELECT SINGLE budat
      FROM matdoc
     WHERE mblnr EQ @gs_cancel_fc-mblnr_311
       AND mjahr EQ @gs_cancel_fc-mjahr_311
      INTO @gs_cancel_fc-budat_311.
  ENDIF.

  "311 취소->261 취소
  CLEAR: gv_check.

  IF gs_cancel_fc-mblnr_311 IS NOT INITIAL.
    "311 취소
    CLEAR: gv_mblnr311, gv_message_311.
    PERFORM bapi_cancel_fc_311 USING ps_issue pv_system_id pv_mode.

    IF gv_check EQ 'E'.
*EXIT.
    ELSE.
      "261 취소
      PERFORM bapi_cancel_fc_261 USING ps_issue pv_system_id pv_mode.

      IF gv_check EQ 'E'.
*EXIT.
      ELSE.
        "꼬리표 삭제/수정
        PERFORM delete_zppt0001_fc USING ps_issue pv_system_id pv_mode.
      ENDIF.
    ENDIF.

  ELSE.
    "261 취소
    PERFORM bapi_cancel_fc_261 USING ps_issue pv_system_id pv_mode.

    IF gv_check EQ 'E'.
*EXIT.
    ELSE.
      "꼬리표 삭제/수정
      PERFORM delete_zppt0001_fc USING ps_issue pv_system_id pv_mode.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_CANCEL_FC_311
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM bapi_cancel_fc_311 USING ps_issue TYPE zgtppt3070
                              pv_system_id TYPE char04
                              pv_mode TYPE char02.

  DATA lt_return  TYPE TABLE OF bapiret2.
  DATA ls_headret TYPE bapi2017_gm_head_ret.
  DATA lv_headtext TYPE bktxt.

  "취소 문서의 취소 처리 결과 체크
  SELECT SINGLE mandt
    FROM matdoc
   WHERE mblnr EQ @gs_cancel_fc-mblnr_311
     AND mjahr EQ @gs_cancel_fc-mjahr_311
     AND cancelled EQ 'X'
    INTO @DATA(lv_mandt).

  "취소 문서가 취소 전이면 진행
  CHECK sy-subrc NE 0.

  "311 취소
  CLEAR: ls_headret, lt_return, lv_headtext.
  lv_headtext = ps_issue-zserno.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      materialdocument    = gs_cancel_fc-mblnr_311
      matdocumentyear     = gs_cancel_fc-mjahr_311
      goodsmvt_pstng_date = gs_cancel_fc-budat_311
      goodsmvt_pr_uname   = sy-uname
      documentheader_text = lv_headtext
    IMPORTING
      goodsmvt_headret    = ls_headret
    TABLES
      return              = lt_return.

  IF ls_headret-mat_doc IS NOT INITIAL.
    "성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    DO 10 TIMES.
      SELECT SINGLE @abap_true
        INTO @DATA(lv_check)
        FROM mkpf
       WHERE mblnr EQ @ls_headret-mat_doc
         AND mjahr EQ @ls_headret-doc_year.

      IF sy-subrc IS INITIAL.
        gv_mblnr311 = ls_headret-mat_doc.
        EXIT.
      ENDIF.

      WAIT UP TO '1' SECONDS.
    ENDDO.

  ELSE.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    gv_message_311 = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
    IF gv_message_311 IS INITIAL.
      gv_message_311 = TEXT-e71.
    ENDIF.

    gv_check = 'E'.

    PERFORM return_message_issue USING ps_issue
                                       'E'
                                       gv_message_311
                                       ls_headret-mat_doc
                                       ls_headret-doc_year.
* 자재 투입 취소 로그 데이터 저장(ZGTPPT3070)
    PERFORM save_log_zgtppt3070_f USING ps_issue pv_system_id pv_mode.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_CANCEL_FC_261
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ISSUE
*&---------------------------------------------------------------------*
FORM bapi_cancel_fc_261  USING ps_issue TYPE zgtppt3070
                               pv_system_id TYPE char04
                               pv_mode TYPE char02.

  DATA lt_return  TYPE TABLE OF bapiret2.
  DATA ls_headret TYPE bapi2017_gm_head_ret.
  DATA lv_headtext TYPE bktxt.
  DATA lv_message TYPE bapiret2-message.

  "취소 문서의 취소 처리 결과 체크
  SELECT SINGLE mandt
    FROM matdoc
   WHERE mblnr EQ @gs_cancel_fc-mblnr
     AND mjahr EQ @gs_cancel_fc-mjahr
     AND cancelled EQ 'X'
    INTO @DATA(lv_mandt).

  "취소 문서가 취소 전이면 진행
  CHECK sy-subrc NE 0.

  "261 취소
  CLEAR: ls_headret, lt_return, lv_headtext.
  lv_headtext = ps_issue-zserno.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      materialdocument    = gs_cancel_fc-mblnr
      matdocumentyear     = gs_cancel_fc-mjahr
      goodsmvt_pstng_date = gs_cancel_fc-budat
      goodsmvt_pr_uname   = sy-uname
      documentheader_text = lv_headtext
    IMPORTING
      goodsmvt_headret    = ls_headret
    TABLES
      return              = lt_return.

  IF ls_headret-mat_doc IS NOT INITIAL.
    "성공
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    DO 10 TIMES.
      SELECT SINGLE @abap_true
        INTO @DATA(lv_check)
        FROM mkpf
       WHERE mblnr EQ @ls_headret-mat_doc
         AND mjahr EQ @ls_headret-doc_year.

      IF sy-subrc IS INITIAL.
        gv_mblnr261 = ls_headret-mat_doc.
        EXIT.
      ENDIF.

      WAIT UP TO '1' SECONDS.
    ENDDO.

    lv_message = |{ sy-datum }/{ sy-uzeit }/{ ps_issue-aufnr }/{ ps_issue-mblnr }{ TEXT-s11 }|.
    PERFORM return_message_issue USING ps_issue
                                       'S'
                                       lv_message
                                       ls_headret-mat_doc
                                       ls_headret-doc_year.
* 자재 투입 취소 로그 데이터 저장(ZGTPPT3070)
    PERFORM save_log_zgtppt3070_f USING ps_issue pv_system_id pv_mode.

  ELSE.
    "오류
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    gv_message_261 = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
    IF gv_message_261 IS INITIAL.
      gv_message_261 = TEXT-e71.
    ENDIF.

    gv_check = 'E'.

    PERFORM return_message_issue USING ps_issue
                                      'E'
                                      gv_message_261
                                      ls_headret-mat_doc
                                      ls_headret-doc_year.
* 자재 투입 취소 로그 데이터 저장(ZGTPPT3070)
    PERFORM save_log_zgtppt3070_f USING ps_issue pv_system_id pv_mode.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_ZPPT0001_FC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_ISSUE
*&      --> PV_SYSTEM_ID
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM delete_zppt0001_fc  USING ps_issue TYPE zgtppt3070
                               pv_system_id TYPE char04
                               pv_mode TYPE char02.

  DATA: lv_menge_if TYPE ekpo-menge,
        lv_remain   LIKE zppt0001-remain.

  SELECT SINGLE *
    FROM zppt0001
   WHERE werks EQ @ps_issue-werks
     AND tagnr EQ @ps_issue-tagnr
     AND charg EQ @ps_issue-charg
     AND matnr EQ @ps_issue-matnr
    INTO @DATA(ls_0001).

  SELECT SINGLE *
    FROM zgtmmt9460
   WHERE vlabelno EQ @ps_issue-tagnr
    INTO @DATA(ls_9460).

  CLEAR: lv_menge_if.
  "투입 수량 환산
  IF ps_issue-meins NE ls_9460-meins.
    CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
      EXPORTING
        i_matnr              = ps_issue-matnr
        i_in_me              = ps_issue-meins
        i_out_me             = ls_9460-meins
        i_menge              = ps_issue-menge
      IMPORTING
        e_menge              = lv_menge_if
      EXCEPTIONS
        error_in_application = 1
        error                = 2
        OTHERS               = 3.

  ELSE.
    lv_menge_if = ps_issue-menge.
  ENDIF.

*** Start 2026.07.11 Fiber 잔량 개선
  "DELETE
  IF ls_0001-remain + lv_menge_if = ls_9460-menge.

    DELETE FROM zppt0001  WHERE werks = ps_issue-werks
                            AND tagnr = ps_issue-tagnr
                            AND charg = ps_issue-charg
                            AND matnr = ps_issue-matnr.
  ELSE.
* 잔량 : 취소(+)
    CLEAR: lv_remain.
    lv_remain = ls_0001-remain + lv_menge_if.

    UPDATE zppt0001 SET remain = lv_remain
                        giflg  = 'N'
                  WHERE werks EQ ps_issue-werks
                    AND tagnr EQ ps_issue-tagnr
                    AND charg EQ ps_issue-charg
                    AND matnr EQ ps_issue-matnr.

  ENDIF.

  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ENDIF.
*** End 2026.07.11 Fiber 잔량 개선

ENDFORM.
