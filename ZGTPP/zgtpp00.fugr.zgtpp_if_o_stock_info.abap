FUNCTION zgtpp_if_o_stock_info.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTPPSIF0009
*"      OT_ITEM STRUCTURE  ZGTPPSIF0010
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_0004
*& 프로그램 명 : [GT] 자재문서 정보 전송
*& 개요   :
*& 생성일 : 2024.11.20
*& 생성자 : ZGSIDEV04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
* No      DATE      AUTHORS              DESCRIPTION                   *
* ---  ----------  ---------  -----------------------------------------*
* U01  2026.06.30  ZGODEV03   Fiber 추가
************************************************************************

  DATA : lt_log TYPE TABLE OF zgtppt3190.
  DATA : lv_timestamp TYPE timestampl.
  DATA : lv_zserno  TYPE zgtppt3190-zserno,
         lv_zserno2 TYPE zgtppt3190-zserno.
  DATA : lv_num(4) TYPE n,
         lv_cnt(4) TYPE n.
  DATA : lv_sydatum(8) TYPE c,
         lv_where(9)   TYPE c.

  DATA: lt_item_b LIKE TABLE OF zgtppsif0010.

  DATA: lv_menge  TYPE labst,
        lv_meins  TYPE meins,
        lv_matnr1 TYPE matnr,
        lv_matnr2 TYPE matnr.

  RANGES: lr_tagnr FOR zppt0001-tagnr.

  CLEAR : gs_zgtppsif0009, gt_zgtppsif0009, gt_zgtppsif0010,
          gs_ot_zgtppsif0010, gt_ot_zgtppsif0010, gt_it_zgtppsif0010.

  gt_zgtppsif0009[] = it_item[].

  GET TIME STAMP FIELD lv_timestamp.

  lv_sydatum = sy-datum.

  CONCATENATE lv_sydatum '%' INTO lv_where.

  SELECT MAX( zserno )
    INTO lv_zserno
    FROM zgtppt3190
   WHERE zsystem_id = i_system_id
     AND zserno    LIKE lv_where.

  IF lv_zserno IS INITIAL.
    CONCATENATE sy-datum '0001'
    INTO lv_zserno2.
  ELSE.
    lv_cnt = lv_zserno+8(4).
    lv_cnt = lv_cnt + 1.
    CONCATENATE lv_zserno+0(8) lv_cnt
           INTO lv_zserno2.
  ENDIF.

  DELETE gt_zgtppsif0009 WHERE werks = ' '.
  IF gt_zgtppsif0009 IS INITIAL.
    zo_result  = 'E'.
    zo_message = '조회조건을 확인하세요'.
    EXIT.
  ENDIF.

  PERFORM conversion_input_zgtppsif0009.
  " 입력값 점검
  LOOP AT gt_zgtppsif0009 INTO gs_zgtppsif0009.
    "플랜트 존재여부 점검
    IF gs_zgtppsif0009-werks IS NOT INITIAL.
      SELECT SINGLE werks
        INTO @DATA(lv_werks)
        FROM t001w
       WHERE werks EQ @gs_zgtppsif0009-werks.
      IF lv_werks IS INITIAL.
        zo_result  = 'E'.
        zo_message = '존재하지 않는 플랜트입니다.'.
*** 2025.08.14 재고 조회 I/F Log DB 과부하로 주석 처리 ***
*        PERFORM save_log_stock_info_09  USING 'E'
*                                    zo_message
*                                    lv_timestamp
*                                    i_system_id
*                                    lv_zserno2.
**********************************************************************
      ENDIF.
    ENDIF.

    "저장위치 존재여부 점검
    IF gs_zgtppsif0009-lgort IS NOT INITIAL.
      SELECT SINGLE lgort
        INTO @DATA(lv_lgort)
        FROM t001l
       WHERE werks EQ @gs_zgtppsif0009-werks
         AND lgort EQ @gs_zgtppsif0009-lgort.
      IF lv_lgort IS INITIAL.
        zo_result  = 'E'.
        zo_message = '존재하지 않는 저장위치입니다.'.
*** 2025.08.14 재고 조회 I/F Log DB 과부하로 주석 처리 ***
*        PERFORM save_log_stock_info_09  USING 'E'
*                                    zo_message
*                                    lv_timestamp
*                                    i_system_id
*                                    lv_zserno2.
**********************************************************************
      ENDIF.
    ENDIF.

    "자재코드 존재여부 점검
    IF gs_zgtppsif0009-matnr IS NOT INITIAL.
      SELECT SINGLE matnr
        INTO @DATA(lv_matnr)
        FROM marc
       WHERE werks EQ @gs_zgtppsif0009-werks
         AND matnr EQ @gs_zgtppsif0009-matnr.
      IF lv_matnr IS INITIAL.
        zo_result  = 'E'.
        zo_message = '존재하지 않는 자재코드입니다.'.
*** 2025.08.14 재고 조회 I/F Log DB 과부하로 주석 처리 ***
*        PERFORM save_log_stock_info_09  USING 'E'
*                                    zo_message
*                                    lv_timestamp
*                                    i_system_id
*                                    lv_zserno2.
**********************************************************************
      ENDIF.
    ENDIF.

    "배치번호 존재여부 점검
    IF gs_zgtppsif0009-charg IS NOT INITIAL.
      SELECT SINGLE charg
        INTO @DATA(lv_charg)
        FROM mchb
       WHERE werks EQ @gs_zgtppsif0009-werks
         AND matnr EQ @gs_zgtppsif0009-matnr
         AND charg EQ @gs_zgtppsif0009-charg.
      IF lv_charg IS INITIAL.
        zo_result  = 'E'.
        zo_message = '존재하지 않는 배치번호입니다.'.
*** 2025.08.14 재고 조회 I/F Log DB 과부하로 주석 처리 ***
*        PERFORM save_log_stock_info_09  USING 'E'
*                                    zo_message
*                                    lv_timestamp
*                                    i_system_id
*                                    lv_zserno2.
**********************************************************************
      ENDIF.
    ENDIF.

    "공급업체번호 존재여부 점검
    IF gs_zgtppsif0009-lifnr IS NOT INITIAL.
      SELECT SINGLE lifnr
        INTO @DATA(lv_lifnr)
        FROM lfa1
       WHERE lifnr EQ @gs_zgtppsif0009-lifnr.
      IF lv_lifnr IS INITIAL.
        zo_result  = 'E'.
        zo_message = '존재하지 않는 공급업체번호입니다.'.
*** 2025.08.14 재고 조회 I/F Log DB 과부하로 주석 처리 ***
*        PERFORM save_log_stock_info_09  USING 'E'
*                                    zo_message
*                                    lv_timestamp
*                                    i_system_id
*                                    lv_zserno2.
**********************************************************************
      ENDIF.
    ENDIF.

*// Modified by ZGODEV06 on 2026-01-16 {
    IF gs_zgtppsif0009-tagnr IS NOT INITIAL.
      SELECT zt01~matnr, zt01~charg, zt01~tagnr
        INTO TABLE @DATA(lt_zppt0001)
        FROM zppt0001 AS zt01
        JOIN mchb
          ON zt01~matnr EQ mchb~matnr
         AND zt01~werks EQ mchb~werks
         AND zt01~charg EQ mchb~charg
       WHERE zt01~matnr EQ @gs_zgtppsif0009-matnr
         AND zt01~werks EQ @gs_zgtppsif0009-werks
         AND zt01~tagnr EQ @gs_zgtppsif0009-tagnr.

      IF sy-subrc IS NOT INITIAL.
        zo_result  = 'E'.
        zo_message = TEXT-e01.
      ENDIF.
    ENDIF.
*// }
  ENDLOOP.

  IF zo_result <> 'E'.
    LOOP AT gt_zgtppsif0009 INTO gs_zgtppsif0009.
      zo_result  = 'S'.
      zo_message = 'MES 수신 조회 조건 값에 오류 없음.'.
*** 2025.08.14 재고 조회 I/F Log DB 과부하로 주석 처리 ***
*      PERFORM save_log_stock_info_09  USING 'S'
*                                  zo_message
*                                  lv_timestamp
*                                  i_system_id
*                                  lv_zserno2.
**********************************************************************
    ENDLOOP.
  ENDIF.

  gs_zgtppsif0009 = VALUE #( gt_zgtppsif0009[ 1 ] OPTIONAL ).
*- 전체재고 전송. 플랜트와 특정 저장위치만 들어옴
*- 외주재고는 플랜트 기준으로 전송해야 함.
  IF gs_zgtppsif0009-flag = 'A'.
    PERFORM get_all_stock.

*** Strat. 꼬리표 기준 조회시 속도 개선 추가
  ELSEIF gs_zgtppsif0009-flag = 'T'.
    PERFORM get_specific_stock.
*** End. 꼬리표 기준 조회시 속도 개선 추가

  ELSE.
*- 플랜트
    "플랜트 자재코드,저장위치,배치번호가 모두 빈 값인 경우
    IF gs_zgtppsif0009-lgort IS INITIAL AND
       gs_zgtppsif0009-matnr IS INITIAL AND
       gs_zgtppsif0009-charg IS INITIAL.

      PERFORM receive_plant.
*- 플랜트, 저장위치
      "플랜트, 저장위치 자재코드 배치번호는 빈 값인데
      "저장위치는 값이 존재하는 경우
    ELSEIF gs_zgtppsif0009-matnr IS INITIAL AND
           gs_zgtppsif0009-charg IS INITIAL AND
           gs_zgtppsif0009-lgort IS NOT INITIAL.

      PERFORM receive_p_l.
*- 플랜트, 저장위치, 자재
      " 플랜트, 저장위치, 자재, 배치번호는 빈 값인데
      " 자재코드 및 저장위치 는 값이 존재하는 경우
    ELSEIF gs_zgtppsif0009-charg IS INITIAL AND
           gs_zgtppsif0009-lgort IS NOT INITIAL AND
           gs_zgtppsif0009-matnr IS NOT INITIAL.

      PERFORM recieve_p_l_m.
*- 플랜트, 자재
      "플랜트, 자재, 배치번호 및 저장위치는 빈 값인데
      "자재코드는 값이 존재하는 경우
    ELSEIF gs_zgtppsif0009-charg IS INITIAL AND
           gs_zgtppsif0009-lgort IS INITIAL AND
           gs_zgtppsif0009-matnr IS NOT INITIAL.

      PERFORM recieve_p_m.
*- 플랜트, 배치
      " 플랜트, 배치] 자재코드및 저장위치는 빈 값인데
      " 배치번호(IT_ITEM-CHARG)는 값이 존재하는 경우
    ELSEIF gs_zgtppsif0009-lgort IS INITIAL AND
           gs_zgtppsif0009-matnr IS INITIAL AND
           gs_zgtppsif0009-charg IS NOT INITIAL.

      PERFORM recieve_p_c.
*- 플랜트, 저장위치, 자재, 배치
      " 플랜트, 저장위치, 자재, 배치 자재코드,
      "저장위치, 배치번호  모두 값이 존재하는 경우
    ELSEIF gs_zgtppsif0009-lgort IS NOT INITIAL AND
           gs_zgtppsif0009-matnr IS NOT INITIAL AND
           gs_zgtppsif0009-charg IS NOT INITIAL.

      PERFORM recieve_p_l_m_c.
*- 플랜트, 자재, 배치
      " 플랜트, 자재, 배치 자재코드 및 배치번호는 값이 있고
      " 저장위치는 빈 값인 경우
    ELSEIF gs_zgtppsif0009-lgort IS INITIAL AND
           gs_zgtppsif0009-matnr IS NOT INITIAL AND
           gs_zgtppsif0009-charg IS NOT INITIAL.

      PERFORM recieve_p_m_c.
*- 플랜트, 저장위치, 배치
      " 플랜트, 저장위치, 배치 저장위치 및 배치번호는 값이 있고
      " 자재코드는 빈 값인 경우
    ELSEIF gs_zgtppsif0009-matnr IS INITIAL AND
           gs_zgtppsif0009-lgort IS NOT INITIAL AND
           gs_zgtppsif0009-charg IS NOT INITIAL.

      PERFORM recieve_p_l_c.
    ENDIF.
  ENDIF.

  DATA lt_link_detail TYPE TABLE OF zgtpps1005.
  DATA lt_matnr TYPE range_t_matnr.

  LOOP AT gt_zgtppsif0010 INTO DATA(ls_zgtppsif0010).

    gs_ot_zgtppsif0010 = CORRESPONDING #( ls_zgtppsif0010 ).

    IF gs_zgtppsif0009-flag = 'M' OR    "자재별 SUM
       gs_zgtppsif0009-flag = 'A'.
      CLEAR gs_ot_zgtppsif0010-charg.
      COLLECT gs_ot_zgtppsif0010 INTO gt_ot_zgtppsif0010.

    ELSEIF gs_zgtppsif0009-flag = 'B'. " 배치별 SUM
      COLLECT gs_ot_zgtppsif0010 INTO gt_ot_zgtppsif0010.

    ELSEIF gs_zgtppsif0009-flag = 'C'. " 배치번호 기준 주문 기할당 수량 추출
      CLEAR lt_link_detail.
      lt_matnr = VALUE #( sign = 'I' option = 'EQ' ( low = ls_zgtppsif0010-matnr ) ).

      CALL FUNCTION 'ZGTPP_GET_STOCK_LINK_INFO'
        EXPORTING
          i_werks        = ls_zgtppsif0010-werks
          i_lgort        = ls_zgtppsif0010-lgort
          it_matnr       = lt_matnr
          i_vbeln        = ls_zgtppsif0010-vbeln
          i_posnr        = ls_zgtppsif0010-posnr
        TABLES
          ot_link_detail = lt_link_detail.

      SELECT SUM( zt01~wemeng )
        FROM @lt_link_detail AS zt01
        INTO @gs_ot_zgtppsif0010-labst2.

      APPEND gs_ot_zgtppsif0010 TO gt_ot_zgtppsif0010.
    ELSE.
      APPEND gs_ot_zgtppsif0010 TO gt_ot_zgtppsif0010.
    ENDIF.

    CLEAR gs_ot_zgtppsif0010.
  ENDLOOP.

*  gt_it_zgtppsif0010[] = gt_ot_zgtppsif0010[]. "로그 저장용 테이블

*// Modified by ZGODEV06 on 2026-01-09 {
  IF gt_ot_zgtppsif0010 IS NOT INITIAL.
    SELECT DISTINCT b~matnr, b~werks, b~ausme, b~dpcbt, c~kzwsm
      FROM @gt_ot_zgtppsif0010 AS a
      JOIN marc AS b
        ON a~matnr EQ b~matnr
       AND a~werks EQ b~werks
      JOIN mara AS c
        ON b~matnr EQ c~matnr
     ORDER BY b~matnr, b~werks
      INTO TABLE @DATA(lt_material).
  ENDIF.
*// }

  "꼬리표번호 발췌
  DATA lv_tagnr LIKE zppt0001-tagnr.

  LOOP AT gt_ot_zgtppsif0010 INTO DATA(gs_zgtppsif0010).
*// Modified by ZGODEV06 on 2026-01-16 {
    READ TABLE lt_material INTO DATA(ls_material) WITH KEY matnr = gs_zgtppsif0010-matnr
                                                           werks = gs_zgtppsif0010-werks BINARY SEARCH.

    IF gs_zgtppsif0009-flag EQ 'B' OR gs_zgtppsif0009-flag EQ 'T'.
*// }
      CLEAR lv_tagnr.
      IF gs_zgtppsif0010-charg IS NOT INITIAL.
        SELECT SINGLE tagnr
          INTO lv_tagnr
          FROM zppt0001
          WHERE werks = gs_zgtppsif0010-werks
            AND matnr = gs_zgtppsif0010-matnr
            AND charg = gs_zgtppsif0010-charg.

        IF lv_tagnr IS NOT INITIAL.
          gs_zgtppsif0010-tagnr = lv_tagnr.
        ENDIF.
      ENDIF.

*// Modified by ZGODEV06 on 2026-01-09 {
      IF ls_material-kzwsm EQ 'B' AND ls_material-dpcbt EQ 'A'.
        PERFORM get_batch_value USING gs_zgtppsif0010.
      ENDIF.
    ENDIF.

    IF gs_zgtppsif0009-flag EQ 'T'.
      IF gs_zgtppsif0010-tagnr IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE it_item TRANSPORTING NO FIELDS WITH KEY tagnr = gs_zgtppsif0010-tagnr.
      IF sy-subrc IS NOT INITIAL.
        CONTINUE.
      ENDIF.
    ENDIF.
*// }

*// Modified by ZGODEV06 on 2026-05-11 {
    IF i_system_id EQ zgtpp_if_const=>gc_system_id-kgpm OR i_system_id EQ zgtpp_if_const=>gc_system_id-kgom.
      IF ls_material-ausme IS NOT INITIAL.
        PERFORM convert_material_unit USING: gs_zgtppsif0010-matnr gs_zgtppsif0010-meins ls_material-ausme gs_zgtppsif0010-kalab,
                                             gs_zgtppsif0010-matnr gs_zgtppsif0010-meins ls_material-ausme gs_zgtppsif0010-insme,
                                             gs_zgtppsif0010-matnr gs_zgtppsif0010-meins ls_material-ausme gs_zgtppsif0010-speme.
      ENDIF.
    ENDIF.

    CLEAR ls_material.
*// }

    "자재코드
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = gs_zgtppsif0010-matnr
      IMPORTING
        output = gs_zgtppsif0010-matnr.

    APPEND gs_zgtppsif0010 TO  ot_item.
  ENDLOOP.

* U01 Fiber 추가
  IF gs_zgtppsif0009-flag EQ 'B'.
    CLEAR: lt_item_b[].  "성적서 추출용

    LOOP AT ot_item INTO DATA(os_item).
      CHECK os_item-matnr EQ os_item-charg.

      CLEAR: lv_matnr1.
      IF gs_zgtppsif0009-matnr IS NOT INITIAL.
        lv_matnr1 = gs_zgtppsif0009-matnr.
      ELSE.
        lv_matnr1 = os_item-matnr.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input        = lv_matnr1
        IMPORTING
          output       = lv_matnr1
        EXCEPTIONS
          length_error = 1
          OTHERS       = 2.

      " 자재가 Fiber 인지 체크
      SELECT SINGLE matkl
        FROM mara
       WHERE matnr EQ @lv_matnr1
        INTO @DATA(lv_matkl).

      CHECK lv_matkl EQ 'RW600101' OR lv_matkl EQ 'RW600102'.

      CLEAR: lv_charg.
      "공통배치(자재코드=배치번호)
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = lv_matnr1
        IMPORTING
          output = lv_charg.

      "공통배치(자재코드=배치번호) 존재여부 확인
      READ TABLE ot_item INTO DATA(os_item1) WITH KEY charg = lv_charg. "공통배치

      IF sy-subrc EQ 0.
        CLEAR: lv_matnr2.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            input        = os_item1-matnr
          IMPORTING
            output       = lv_matnr2
          EXCEPTIONS
            length_error = 1
            OTHERS       = 2.

        "기존 투입 처리로 발생한 잔량 FiberID 모두 추출
        SELECT matnr, tagnr
          FROM zppt0001
         WHERE matnr EQ @lv_matnr2
           AND werks EQ @gs_zgtppsif0009-werks
          INTO TABLE @DATA(lt_remain_fid).

        CLEAR: lr_tagnr, lr_tagnr[].
        LOOP AT lt_remain_fid INTO DATA(ls_remain_fid).
          lr_tagnr-sign = 'I'.
          lr_tagnr-option = 'EQ'.
          lr_tagnr-low = ls_remain_fid-tagnr.
          COLLECT lr_tagnr.
          CLEAR: lr_tagnr.
        ENDLOOP.

        "투입 처리 되지 않은 Fiber = 검사성적서에서 발생한 FiberID 중 잔량 Fiber 제외
        IF lr_tagnr[] IS NOT INITIAL.
          SELECT *
            FROM zgtmmt9460
           WHERE vlabelno NOT IN @lr_tagnr
             AND matnr EQ @lv_matnr2
             AND werks EQ @gs_zgtppsif0009-werks
            INTO TABLE @DATA(lt_mm9460).
        ELSE.
          CLEAR: lt_mm9460[].
          SELECT *
            FROM zgtmmt9460
           WHERE matnr EQ @lv_matnr2
             AND werks EQ @gs_zgtppsif0009-werks
            INTO TABLE @lt_mm9460.
        ENDIF.

        "투입처리 되지 않은 FiberID의 정보를 전송 대상에 추가
        IF lt_mm9460[] IS NOT INITIAL.
          LOOP AT lt_mm9460 INTO DATA(ls_mm9460).

            CLEAR: lv_menge, lv_meins.
            SELECT SINGLE meins
              FROM mara
             WHERE matnr EQ @ls_mm9460-matnr
              INTO @lv_meins.

            IF ls_mm9460-meins NE lv_meins.
              CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                EXPORTING
                  i_matnr              = ls_mm9460-matnr
                  i_in_me              = ls_mm9460-meins
                  i_out_me             = lv_meins
                  i_menge              = ls_mm9460-menge
                IMPORTING
                  e_menge              = lv_menge
                EXCEPTIONS
                  error_in_application = 1
                  error                = 2
                  OTHERS               = 3.

            ELSE.
              lv_menge = ls_mm9460-menge.
              lv_meins = ls_mm9460-meins.
            ENDIF.

            CLEAR: gs_zgtppsif0010.
            "자재코드
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = ls_mm9460-matnr
              IMPORTING
                output = gs_zgtppsif0010-matnr.

            gs_zgtppsif0010-werks = ls_mm9460-werks.
            gs_zgtppsif0010-charg = gs_zgtppsif0010-matnr.
            gs_zgtppsif0010-lgort = '2110'.
            gs_zgtppsif0010-kalab = lv_menge.
            gs_zgtppsif0010-meins = lv_meins.
            gs_zgtppsif0010-tagnr = ls_mm9460-vlabelno.

            APPEND gs_zgtppsif0010 TO lt_item_b.
            CLEAR: ls_mm9460.
          ENDLOOP.

        ENDIF.
        CLEAR: lt_mm9460[], lt_remain_fid[].
      ENDIF.
      CLEAR: os_item, os_item1.
    ENDLOOP.

    "통합배치로 재고 추출된 DATA는 전송에서 제외
    LOOP AT ot_item INTO os_item WHERE tagnr IS INITIAL.
      IF os_item-matnr EQ os_item-charg.
        DELETE ot_item INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

    "성적서에서 추출된 데이터 중복 제거
    SORT lt_item_b BY werks lgort matnr charg tagnr.
    DELETE ADJACENT DUPLICATES FROM lt_item_b COMPARING werks lgort matnr charg tagnr.

    "성적서에서 추출된 데이터 APPEND
    CLEAR: os_item.
    LOOP AT lt_item_b INTO DATA(ls_item_b).
      MOVE-CORRESPONDING ls_item_b TO os_item.
      APPEND os_item TO ot_item.
      CLEAR: ls_item_b, os_item.
    ENDLOOP.

    SORT ot_item BY werks lgort matnr charg.
  ENDIF.

  IF gs_zgtppsif0009-flag EQ 'T' AND ot_item[] IS INITIAL.
    CLEAR: ls_mm9460.

*** Start. 2026.07.08 Fiber 꼬리표 재고 조회 개선
    SELECT SINGLE *
       FROM zppt0001
      WHERE tagnr = @gs_zgtppsif0009-tagnr
*           AND remain > 0
         INTO @DATA(ls_zppt0001).

    IF sy-subrc = 0 AND LS_ZPPT0001-REMAIN = 0.  "모두 투입한 Fiber ID
      EXIT.
    ELSEIF SY-SUBRC = 0 AND LS_ZPPT0001-REMAIN > 0. "일부 투입한 Fiber ID
      ls_mm9460-werks = ls_zppt0001-werks.
      ls_mm9460-matnr = ls_zppt0001-matnr.
      ls_mm9460-menge = ls_zppt0001-remain.
      ls_mm9460-vlabelno = ls_zppt0001-tagnr.
      ls_mm9460-meins = ls_zppt0001-meins.
    ELSE.                                                                   "최초 입고된 성적서 Fiber ID
      SELECT SINGLE *
        FROM zgtmmt9460
       WHERE vlabelno EQ @gs_zgtppsif0009-tagnr
        INTO @ls_mm9460.
    ENDIF.
*** END. 2026.07.08 Fiber 꼬리표 재고 조회 개선

    IF ls_mm9460 IS NOT INITIAL.
      " I/F 자재가 Fiber 인지 체크
      CLEAR: lv_matkl.
      SELECT SINGLE matkl
        FROM mara
       WHERE matnr EQ @ls_mm9460-matnr
        INTO @lv_matkl.

      CHECK lv_matkl EQ 'RW600101' OR lv_matkl EQ 'RW600102'.

      CLEAR: lv_menge, lv_meins.
      SELECT SINGLE meins
        FROM mara
       WHERE matnr EQ @ls_mm9460-matnr
        INTO @lv_meins.

      IF ls_mm9460-meins NE lv_meins.
        CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
          EXPORTING
            i_matnr              = ls_mm9460-matnr
            i_in_me              = ls_mm9460-meins
            i_out_me             = lv_meins
            i_menge              = ls_mm9460-menge
          IMPORTING
            e_menge              = lv_menge
          EXCEPTIONS
            error_in_application = 1
            error                = 2
            OTHERS               = 3.

      ELSE.
        lv_menge = ls_mm9460-menge.
        lv_meins = ls_mm9460-meins.
      ENDIF.

      CLEAR: gs_zgtppsif0010.
      "자재코드
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ls_mm9460-matnr
        IMPORTING
          output = gs_zgtppsif0010-matnr.

      gs_zgtppsif0010-werks = ls_mm9460-werks.
      gs_zgtppsif0010-charg = gs_zgtppsif0010-matnr.
      gs_zgtppsif0010-lgort = '2110'.
      gs_zgtppsif0010-kalab = lv_menge.
      gs_zgtppsif0010-meins = lv_meins.
      gs_zgtppsif0010-tagnr = ls_mm9460-vlabelno.

      APPEND gs_zgtppsif0010 TO ot_item.
    ENDIF.
  ENDIF.
* U01 Fiber 추가

  IF ot_item[] IS NOT INITIAL.
    gt_it_zgtppsif0010[] = ot_item[]. "로그 저장용 테이블
    zo_result  = 'S'.
    zo_message = '재고 조회에 성공하였습니다.'.
*** 2025.08.14 재고 조회 I/F Log DB 과부하로 주석 처리 ***
*    PERFORM save_log_stock_info_10  USING zo_result
*                                zo_message
*                                lv_timestamp
*                                i_system_id
*                                lv_zserno2.
*********************************************************************

  ELSE.
    gt_it_zgtppsif0010[] = ot_item[]. "로그 저장용 테이블
    zo_result  = 'E'.
    zo_message = '재고 조회에 실패하였습니다.'.
*** 2025.08.14 재고 조회 I/F Log DB 과부하로 주석 처리 ***
*    PERFORM save_log_stock_info_10  USING zo_result
*                                zo_message
*                                lv_timestamp
*                                i_system_id
*                                lv_zserno2.
*********************************************************************
  ENDIF.

ENDFUNCTION.
