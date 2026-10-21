FUNCTION zgtpp_if_i_prod_chg.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ORDER STRUCTURE  ZGTPPSIF0012
*"      IT_ORDERDATA STRUCTURE  ZGTPPSIF0013
*"      OT_RESULT STRUCTURE  ZGTPPSIF0014
*"  EXCEPTIONS
*"      SYSTEM_FAILURE
*"      COMMUNICATION_FAILURE
*"      ILLEGALNAME
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_PROD_CHG
*& 프로그램 명 : [GT] 생산 오더 정보 변경[ERP <- 지중MES]
*& 개요   :
*& 생성일 : 2024.11.26
*& 생성자 : ZGSIDEV05
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : 지중MES]
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  : 2025.05.16
*& 수정자  : ZGISPP03
*& 수정개요 : U01
*&   - 생산오더 정보 Item N건 수신시, 처리 중 오류 발생시 처리 중단
*&   -  I/F Header Log에 누락되는 결과값, 메세지 추가
*&---------------------------------------------------------------------*
*& 수정일  : 2026.03.19
*& 수정자  : ZGODEV06
*& 수정개요 : U02
*&   - 생산오더 생산버전 변경.
*&   - 공정변경.
*&---------------------------------------------------------------------*
*& 수정일  : 2026.06.10
*& 수정자  : ZGODEV03
*& 수정개요 : 신규 추가
*&   - 생산오더 수량 변경(I_SYSTEM_ID가 'KGOM'만 허용)
*&---------------------------------------------------------------------*

  DATA : ls_object    TYPE bapi_pp_order_objects,
         ls_return    TYPE bapiret2,
         lt_header    TYPE TABLE OF bapi_order_header1,
         lt_operation TYPE TABLE OF bapi_order_operation1,
         lv_objnr     TYPE jest-objnr,
         lv_user_line TYPE bsvx-sttxt,
         lv_line      TYPE bsvx-sttxt,
         lv_err,
         lv_tcntc     TYPE char20,
         lv_scntc     TYPE char20,
         lv_ecntc     TYPE char20,
         lv_scnt      TYPE i.
  DATA : lv_chk_stats.

  __cle : gt_order, gt_orderdata, gt_return, gt_header, gt_item,
          gt_bdcdata, gt_message.

  IF it_order[] IS INITIAL.
    ot_result-zerp_stat = gc_e.
    ot_result-zerp_message = TEXT-e01.
    APPEND ot_result. EXIT.
  ENDIF.

  gt_zgtppt1010 = zgtpp_cl_common=>get_code_value( iv_codegrp = '1060' ).

  SORT gt_zgtppt1010 BY fld_01 fld_02 fld_04.

  LOOP AT it_order.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = it_order-aufnr
      IMPORTING
        output = it_order-aufnr.
    MODIFY it_order.
  ENDLOOP.

  LOOP AT it_orderdata.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = it_orderdata-aufnr
      IMPORTING
        output = it_orderdata-aufnr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = it_orderdata-vornr
      IMPORTING
        output = it_orderdata-vornr.

    MODIFY it_orderdata.
  ENDLOOP.

  gt_order[]     = it_order[].
  gt_orderdata[] = it_orderdata[].

***  U01 I/F Raw Data 저장
  LOOP AT gt_orderdata INTO DATA(ls_item).

    CLEAR gt_item.
    MOVE-CORRESPONDING ls_item  TO gt_item.
    READ TABLE gt_order INTO DATA(ls_header) WITH KEY aufnr = gt_item-aufnr.
    gt_item-zserno     = ls_header-zserno.
    GET TIME STAMP FIELD gt_item-zifkey.
    gt_item-zsystem_id = i_system_id.
    APPEND gt_item.

  ENDLOOP.
***  U01

  DATA(lt_for) = it_order[].
  SORT lt_for BY werks.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING werks.
  IF lt_for[] IS NOT INITIAL.
    SELECT werks INTO TABLE @DATA(lt_t001w)
      FROM t001w
       FOR ALL ENTRIES IN @lt_for
     WHERE werks = @lt_for-werks.
  ENDIF.

  lt_for[] = it_order[].
  SORT lt_for BY aufnr.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING aufnr.
  IF lt_for[] IS NOT INITIAL.
    SELECT aufnr, objnr INTO TABLE @DATA(lt_objnr)
      FROM aufk
       FOR ALL ENTRIES IN @lt_for
     WHERE aufnr = @lt_for-aufnr.
  ENDIF.

  lt_for[] = it_order[].
  SORT lt_for BY werks.
  DELETE ADJACENT DUPLICATES FROM lt_for COMPARING werks.
  IF lt_for[] IS NOT INITIAL.
    SELECT werks, arbpl INTO TABLE @DATA(lt_crhd)
      FROM crhd
       FOR ALL ENTRIES IN @lt_for
     WHERE werks = @lt_for-werks.
  ENDIF.

  SORT lt_crhd  BY werks arbpl.
  SORT lt_objnr BY aufnr.
  SORT lt_t001w BY werks.

*처리 유형 확인
  LOOP AT gt_order INTO gs_order.

*① 플랜트 확인
    READ TABLE lt_t001w TRANSPORTING NO FIELDS WITH KEY werks = it_order-werks BINARY SEARCH.
    IF sy-subrc NE 0.
      PERFORM fill_log_data USING gc_e i_system_id TEXT-e02. CONTINUE.
    ENDIF.

*② 생산 오더 확인
    CLEAR ls_object.
    ls_object = VALUE #( header = gc_x operations = gc_x ).
    CALL FUNCTION 'BAPI_PRODORD_GET_DETAIL'
      EXPORTING
        number        = gs_order-aufnr
        order_objects = ls_object
      IMPORTING
        return        = ls_return
      TABLES
        header        = lt_header
        operation     = lt_operation.

    IF ls_return-type = gc_e.
      PERFORM fill_log_data USING gc_e i_system_id TEXT-e03. CONTINUE.
    ENDIF.

*2) 처리 유형 분기
    LOOP AT gt_orderdata INTO gs_orderdata WHERE aufnr = gs_order-aufnr.

*생산오더 상태
      READ TABLE lt_objnr INTO DATA(ls_objnr) WITH KEY aufnr = gs_order-aufnr BINARY SEARCH.
      IF sy-subrc NE 0.
        PERFORM fill_log_data USING gc_e i_system_id TEXT-e03. EXIT.
      ENDIF.

      CLEAR : lv_objnr, lv_user_line, lv_line, lv_err.
      lv_objnr = ls_objnr-objnr.

      CALL FUNCTION 'STATUS_TEXT_EDIT'
        EXPORTING
          objnr            = lv_objnr
          flg_user_stat    = 'X'
          only_active      = 'X'
          spras            = sy-langu
          bypass_buffer    = 'X'
        IMPORTING
          line             = lv_line "오더상태
          user_line        = lv_user_line
        EXCEPTIONS
          object_not_found = 1
          OTHERS           = 2.

      SPLIT lv_line AT space INTO TABLE DATA(lt_line).
      DELETE lt_line WHERE table_line IS INITIAL.

      CASE gc_x.

**********************************************************************
          "생산 오더 공정 변경
**********************************************************************
        WHEN gs_orderdata-plnflx OR gs_orderdata-arbplx.
**********************************************************************

*1) 생산 오더 상태 확인
          LOOP AT lt_line INTO DATA(ls_line).

            CASE ls_line.
              WHEN 'REL'.
                IF gs_orderdata-plnflx = gc_x.
                  CONCATENATE TEXT-e04 ls_line ')' INTO DATA(lv_msg) SEPARATED BY space.
                  lv_err = gc_x.
                  PERFORM fill_log_data USING gc_e i_system_id lv_msg. EXIT.
                ENDIF.
              WHEN 'CNF' OR 'PCNF' OR 'DLV'.
                CONCATENATE TEXT-e04 ls_line ')' INTO lv_msg SEPARATED BY space.
                lv_err = gc_x.
                PERFORM fill_log_data USING gc_e i_system_id lv_msg. EXIT.
              WHEN OTHERS.
                IF ls_line CS |PDLV|.
                  CONCATENATE TEXT-e04 ls_line ')' INTO lv_msg SEPARATED BY space.
                  lv_err = gc_x.
                  PERFORM fill_log_data USING gc_e i_system_id lv_msg. EXIT..
                ENDIF.
            ENDCASE.

          ENDLOOP.

          IF lv_err = gc_x.
*            CONTINUE.  "U01
            EXIT.  "U01
          ENDIF.

          CASE lv_user_line.
            WHEN 'PAYO'.
              CONCATENATE TEXT-e04 ls_line ')' INTO lv_msg SEPARATED BY space.
              PERFORM fill_log_data USING gc_e i_system_id lv_msg. "U01 CONTINUE.
              EXIT. "U01
          ENDCASE.

*2) 공정 변경 내용 확인
          IF gs_orderdata-vornr IS INITIAL.
            PERFORM fill_log_data USING gc_e i_system_id TEXT-e05.  "U01 CONTINUE.
            EXIT. "U01
          ENDIF.

          IF gs_orderdata-plnfl IS INITIAL AND gs_orderdata-arbpl IS INITIAL.
            PERFORM fill_log_data USING gc_e i_system_id TEXT-e06. "U01 CONTINUE. "작업장이 누락되었습니다.
            EXIT. "U01
          ENDIF.

          IF gs_orderdata-plnfl IS NOT INITIAL AND gs_orderdata-arbpl IS NOT INITIAL.
            PERFORM fill_log_data USING gc_e i_system_id TEXT-e07. "U01 CONTINUE. "순서교체와 변경 작업장이 모두 존재합니다.
            EXIT. "U01
          ENDIF.

*- 라우팅 순서 변경이면, 오더 "REL" 상태는 오류
          IF gs_orderdata-plnflx IS NOT INITIAL AND lv_line = |REL|.
            PERFORM fill_log_data USING gc_e i_system_id TEXT-e08. "U01 CONTINUE. "오더가 릴리즈되어 순서교환이 불가능한 상태입니다.
            EXIT. "U01
          ENDIF.

*- 작업장 변경이면, 작업장 유/무 확인
          IF gs_orderdata-arbplx IS NOT INITIAL.
            READ TABLE lt_crhd INTO DATA(ls_crhd) WITH KEY werks = gs_order-werks
                                                           arbpl = gs_orderdata-arbpl BINARY SEARCH.
            IF sy-subrc NE 0.
              PERFORM fill_log_data USING gc_e i_system_id TEXT-e09. "U01 CONTINUE. "작업장이 존재하지 않습니다.
              EXIT. "U01
            ENDIF.
          ENDIF.

* - 공정 변경
*// U02 Modified by ZGODEV06 on 2026-03-19 {
          IF i_system_id EQ 'KGPM' OR i_system_id  EQ 'KGOM'. "// 가온전선일 경우.
            PERFORM operation_change_for_tandem TABLES lt_operation USING i_system_id.
          ELSE.
*// }
            PERFORM change_operation_data USING i_system_id.
          ENDIF.

*** U01 - 오류 존재시, 이후 수행 중단
          IF gt_header[] IS NOT INITIAL.
            READ TABLE gt_header INTO DATA(ls_head) WITH KEY zerp_stat = 'E'.
            IF sy-subrc = 0.
              EXIT.
            ENDIF.
          ENDIF.
*** U01

**********************************************************************
          "생산 오더 상태 변경
**********************************************************************
        WHEN gs_orderdata-statusx.
**********************************************************************

*// Modified by ZGODEV06 on 2026-04-02 {
*         IF gs_orderdata-status NE |PAYO| AND gs_orderdata-status NE space.
          IF gs_orderdata-status NE |PAYO| AND gs_orderdata-status NE space AND
             gs_orderdata-status NE |LBCO| AND gs_orderdata-status NE |CTCO|.
*// }
            PERFORM fill_log_data USING gc_e i_system_id TEXT-e10. "U01 CONTINUE. "변경 가능한 상태가 입력되지 않았습니다.
            EXIT. "U01
          ENDIF.

          READ TABLE lt_line INTO ls_line WITH KEY table_line = |REL|.
          IF sy-subrc NE 0.
            PERFORM fill_log_data USING gc_e i_system_id TEXT-e11. "U01 CONTINUE. "생산 오더가 릴리즈 되지 않았습니다.
            EXIT. "U01
          ENDIF.

          CLEAR lv_chk_stats.
          IF gs_orderdata-status = lv_user_line.
            lv_chk_stats = abap_true.
*           유저상태 중복시 성공으로 처리  - 2025.02.12
*            PERFORM FILL_LOG_DATA USING GC_E I_SYSTEM_ID TEXT-E13. CONTINUE. "생산오더 상태가 이미 변경되어 있습니다.
            PERFORM fill_log_data USING gc_s i_system_id TEXT-e13. "U01 CONTINUE. "생산오더 상태가 이미 변경되어 있습니다.
            EXIT. "U01
          ENDIF.

* 생산 오더 상태 변경
          IF lv_chk_stats IS INITIAL.
            PERFORM change_prod_status USING i_system_id lv_user_line.
          ENDIF.

*** U01 - 오류 존재시, 이후 수행 중단
          IF gt_header[] IS NOT INITIAL.
            READ TABLE gt_header INTO ls_head WITH KEY zerp_stat = 'E'.
            IF sy-subrc = 0.
              EXIT.
            ENDIF.
          ENDIF.
*** U01

**********************************************************************
          "생산 오더 일정 변경
**********************************************************************
        WHEN gs_orderdata-gstrpx OR gs_orderdata-gltrpx.
**********************************************************************

*1) 생산 오더 상태 확인

          LOOP AT lt_line INTO ls_line.

            CASE ls_line.
              WHEN 'CNF' OR 'PCNF' OR 'DLV'.
                CONCATENATE TEXT-e04 ls_line ')' INTO lv_msg SEPARATED BY space.
                lv_err = gc_x.
                PERFORM fill_log_data USING gc_e i_system_id lv_msg. EXIT.
              WHEN OTHERS.
                IF ls_line CS |PDLV|.
                  CONCATENATE TEXT-e04 ls_line ')' INTO lv_msg SEPARATED BY space.
                  lv_err = gc_x.
                  PERFORM fill_log_data USING gc_e i_system_id lv_msg. EXIT.
                ENDIF.
            ENDCASE.

          ENDLOOP.

          IF lv_err = gc_x.
            "U01 CONTINUE.
            EXIT. "U01
          ENDIF.

          CASE lv_user_line.
            WHEN 'PAYO'.
              CONCATENATE TEXT-e04 ls_line ')' INTO lv_msg SEPARATED BY space.
              PERFORM fill_log_data USING gc_e i_system_id lv_msg. "U01 CONTINUE.
              EXIT. "U01
          ENDCASE.

          IF gs_orderdata-gstrp IS INITIAL AND gs_orderdata-gltrp IS INITIAL.
            PERFORM fill_log_data USING gc_e i_system_id TEXT-e12. "U01 CONTINUE. "변경할 일자가 입력되지 않았습니다.
            EXIT. "U01
          ENDIF.

          PERFORM change_prod_schedule USING i_system_id.

*** U01 - 오류 존재시, 이후 수행 중단
          IF gt_header[] IS NOT INITIAL.
            READ TABLE gt_header INTO ls_head WITH KEY zerp_stat = 'E'.
            IF sy-subrc = 0.
              EXIT.
            ENDIF.
          ENDIF.
*** U01

**********************************************************************
          "생산 오더 수량 변경
**********************************************************************
        WHEN gs_orderdata-psmngx.
**********************************************************************
          IF i_system_id EQ 'KGOM'.
*1) 생산 오더 상태 확인
            LOOP AT lt_line INTO ls_line.

              CASE ls_line.
                WHEN 'CNF'  OR 'DLV'.
                  CONCATENATE TEXT-e04 ls_line ')' INTO lv_msg SEPARATED BY space.
                  lv_err = gc_x.
                  PERFORM fill_log_data USING gc_e i_system_id lv_msg. EXIT.
                WHEN OTHERS.
*                  IF ls_line CS |PDLV|.
*                    CONCATENATE TEXT-e04 ls_line ')' INTO lv_msg SEPARATED BY space.
*                    lv_err = gc_x.
*                    PERFORM fill_log_data USING gc_e i_system_id lv_msg. EXIT.
*                  ENDIF.
              ENDCASE.

*              CASE ls_line.
*                WHEN 'CNF' OR 'PCNF' OR 'DLV'.
*                  CONCATENATE TEXT-e04 ls_line ')' INTO lv_msg SEPARATED BY space.
*                  lv_err = gc_x.
*                  PERFORM fill_log_data USING gc_e i_system_id lv_msg. EXIT.
*                WHEN OTHERS.
*                  IF ls_line CS |PDLV|.
*                    CONCATENATE TEXT-e04 ls_line ')' INTO lv_msg SEPARATED BY space.
*                    lv_err = gc_x.
*                    PERFORM fill_log_data USING gc_e i_system_id lv_msg. EXIT.
*                  ENDIF.
*              ENDCASE.

            ENDLOOP.

            IF lv_err = gc_x.
              "U01 CONTINUE.
              EXIT. "U01
            ENDIF.

            CASE lv_user_line.
              WHEN 'PAYO'.
*                CONCATENATE TEXT-e04 lv_user_line ')' INTO lv_msg SEPARATED BY space.
*                PERFORM fill_log_data USING gc_e i_system_id lv_msg. "U01 CONTINUE.
*                EXIT. "U01
            ENDCASE.

            IF gs_orderdata-psmng IS INITIAL.
              PERFORM fill_log_data USING gc_e i_system_id TEXT-m60. "U01 CONTINUE. "변경할 수량이 입력되지 않았습니다.
              EXIT. "U01
            ENDIF.

            PERFORM change_prod_quantity USING i_system_id.

*** U01 - 오류 존재시, 이후 수행 중단
            IF gt_header[] IS NOT INITIAL.
              READ TABLE gt_header INTO ls_head WITH KEY zerp_stat = 'E'.
              IF sy-subrc = 0.
                EXIT.
              ENDIF.
            ENDIF.
*** U01
          ELSE.
            PERFORM fill_log_data USING gc_e i_system_id TEXT-m61. "U01 CONTINUE. "수량 변경이 불가한 시스템입니다.
            EXIT. "U01
          ENDIF.

      ENDCASE.

*// U02 Modified by ZGODEV06 on 2026-03-19 {
      IF gs_orderdata-plnflx EQ 'P'.
        PERFORM change_prod_vers_in_prod_order USING i_system_id lv_err.

        IF lv_err IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDIF.
*// }
    ENDLOOP.

  ENDLOOP.

**********************************************************************
*결과 리턴
**********************************************************************
  LOOP AT gt_return.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = gt_return-aufnr
      IMPORTING
        output = gt_return-aufnr.
    MODIFY gt_return.
  ENDLOOP.

  LOOP AT gt_header.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = gt_header-aufnr
      IMPORTING
        output = gt_header-aufnr.
    MODIFY gt_header.
  ENDLOOP.

  LOOP AT gt_item.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = gt_item-aufnr
      IMPORTING
        output = gt_item-aufnr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = gt_item-vornr
      IMPORTING
        output = gt_item-vornr.

    MODIFY gt_item.
  ENDLOOP.

*** U01 Header Return 위치 변경
  ot_result[] = gt_return[].
  DELETE gt_return WHERE zerp_stat NE gc_e.
  DATA(lv_ecnt) = lines( gt_return ).
  IF lv_ecnt > 0.
    zo_result = |01|.
  ELSE.
    zo_result = |00|.
  ENDIF.

  DATA(lv_tcnt) = lines( ot_result ).
  lv_scnt = lv_tcnt - lv_ecnt.
  WRITE lv_tcnt TO lv_tcntc. CONDENSE lv_tcntc.
  WRITE lv_scnt TO lv_scntc. CONDENSE lv_scntc.
  WRITE lv_ecnt TO lv_ecntc. CONDENSE lv_ecntc.
  MESSAGE s051(zgtsd01) WITH lv_tcnt lv_scnt lv_ecnt INTO zo_message.
*** U01

  IF gt_header[] IS NOT INITIAL.
*** U01 - Header Log의 결과 저장
    LOOP AT gt_header INTO DATA(gs_header).
      gs_header-zstat = zo_result.
      gs_header-zmessage = zo_message.
      MODIFY gt_header FROM gs_header.
    ENDLOOP.
*** U01
    MODIFY zgtppt2040 FROM TABLE gt_header.
  ENDIF.

  IF gt_item[] IS NOT INITIAL.
    MODIFY zgtppt2050 FROM TABLE gt_item.
  ENDIF.

ENDFUNCTION.
