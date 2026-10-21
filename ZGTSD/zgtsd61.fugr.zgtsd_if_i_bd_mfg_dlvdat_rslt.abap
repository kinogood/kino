FUNCTION zgtsd_if_i_bd_mfg_dlvdat_rslt.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_HEADER) LIKE  ZGTSDSIF0076 STRUCTURE  ZGTSDSIF0076
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTETARGET
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTSDSIF0077 OPTIONAL
*"      OT_RESULT STRUCTURE  ZGTSDSIF0078 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_IF_I_BD_MFG_DLVDAT_RSLT
*& 프로그램 명 : [BD] 제조지시 납기일 변경결과 수신
*& 개요   :
*& 생성일 : 2025.02.18
*& 생성자 : 신영철
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : SalesOutlook
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
*-- 1. 로컬 변수 선언
*-----------------------------------------------------------------------
  DATA : ls_rst_if TYPE gty_rst_if,

         lv_eflg   TYPE char01.

  CLEAR : ls_rst_if,
          zo_result, zo_message,
          ot_result[], ot_result.

*-- I/F Key 정보 구성
  GET TIME STAMP FIELD ls_rst_if-zifkey.

  ls_rst_if = VALUE #( BASE ls_rst_if
                        zifrfc     = 'ZGTSD_IF_I_BD_MFG_DLVDAT_RSLT'
                        zsystem_id = i_system_id
                     ).
*-----------------------------------------------------------------------
*-- 2. Import 값 정합성 체크
*-----------------------------------------------------------------------
*-- 2-1. 수신 이력 정보 저장 선 수행
  PERFORM save_if_log_info_for_9000 USING    i_system_id
                                             ls_rst_if
                                             abap_true
                                             is_header
                                    CHANGING lv_eflg.
  IF lv_eflg EQ abap_true.
*-- 수신 이력 저장 실패시 오류 정보 리턴
    zo_result  = '01'.
    zo_message = '데이터 수신 도중 오류가 발생했습니다.'(e01).
    RETURN.
  ENDIF.

*-- 2-2. 입력값 점검
  IF is_header IS INITIAL.
*-- 납기변경 결과 값이 없는 경우 오류 메세지 처리 & Log 저장
    zo_result  = '01'.
    zo_message = '데이터 수신 도중 오류가 발생했습니다.'(e01).
*-- 오류 Update 정보 구성
    ls_rst_if = VALUE #( BASE ls_rst_if
                        zstat        = zo_result
                        zmessage     = zo_message
                        zerp_stat    = 'E'
                        zerp_message = '출하예정일변경 결과 값이 없습니다.'(e02)
                       ).
    PERFORM save_if_log_info_for_9000
                                    USING    i_system_id
                                             ls_rst_if
                                             abap_false
                                             is_header
                                    CHANGING lv_eflg.
    RETURN.
  ELSE.
    IF is_header-confrdd IS INITIAL OR is_header-confrdd <= '0'.
*-- 납기변경 결과 값이 없는 경우 오류 메세지 처리 & Log 저장
      zo_result  = '01'.
      zo_message = '데이터 수신 도중 오류가 발생했습니다.'(e01).
*-- 오류 Update 정보 구성
      ls_rst_if = VALUE #( BASE ls_rst_if
                          zstat        = zo_result
                          zmessage     = zo_message
                          zerp_stat    = 'E'
                          zerp_message = '출하예정일변경일 없습니다.'(e07)
                         ).
      PERFORM save_if_log_info_for_9000
                                      USING    i_system_id
                                               ls_rst_if
                                               abap_false
                                               is_header
                                      CHANGING lv_eflg.
      RETURN.
    ENDIF.
  ENDIF.

*-- 2-3. 납기변경 접수번호 점검
*-- 2-3-1. 제조지시 납기일 변경요청 송수신 Log 정보 Select
  SELECT a~dreqno,  a~job_no,  a~reqsts,  a~rdd_new

    FROM zgtsdt0068 AS a
   WHERE a~dreqno EQ @is_header-dreqno

   GROUP BY a~dreqno, a~job_no, a~reqsts, a~rdd_new
   ORDER BY a~dreqno, a~job_no, a~reqsts, a~rdd_new

    INTO TABLE @DATA(lt_chk_dat).

  IF sy-subrc EQ 0.
*-- 2-3-2. 처리 완료된 납기변경 접수번호 확인
    READ TABLE lt_chk_dat WITH KEY reqsts = 'A'
                          TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
*-- 납기변경 결과 값이 없는 경우 오류 메세지 처리 & Log 저장
      zo_result  = '01'.
      zo_message = '데이터 수신 도중 오류가 발생했습니다.'(e01).
*-- 오류 Update 정보 구성
      ls_rst_if = VALUE #( BASE ls_rst_if
                          zstat        = zo_result
                          zmessage     = zo_message
                          zerp_stat    = 'E'
                          zerp_message = '이미 처리 완료된 출하예정일변경 접수번호입니다.'(e04)
                         ).
      PERFORM save_if_log_info_for_9000
                                    USING    i_system_id
                                             ls_rst_if
                                             abap_false
                                             is_header
                                    CHANGING lv_eflg.
      RETURN.
    ENDIF.

  ELSE.
*-- 2-3-3. 납기변경접수 번호 기준 값 없는 경우
    zo_result  = '01'.
    zo_message = '데이터 수신 도중 오류가 발생했습니다.'(e01).
*-- 오류 Update 정보 구성
    ls_rst_if = VALUE #( BASE ls_rst_if
                        zstat        = zo_result
                        zmessage     = zo_message
                        zerp_stat    = 'E'
                        zerp_message = '존재하지 않는 출하예정일변경 접수번호입니다.'(e05)
                       ).
    PERFORM save_if_log_info_for_9000
                                    USING    i_system_id
                                             ls_rst_if
                                             abap_false
                                             is_header
                                    CHANGING lv_eflg.
    RETURN.
  ENDIF.

*-----------------------------------------------------------------------
*-- 3. 납기변경요청 정보 업데이트 수행
*-----------------------------------------------------------------------
*-- 3-1. 제조지시 납기일 변경요청 송수신 Log 정보 Update 수행
  PERFORM upd_db_0068_if_log        TABLES   it_item[]
                                             ot_result[]
                                    USING    is_header
                                             i_system_id
                                    CHANGING lv_eflg.

  IF lv_eflg EQ abap_true.
*-- 해당 정보 Update 실패시 오류 정보 리턴
    zo_result  = '01'.
    zo_message = '데이터 수신 도중 오류가 발생했습니다.'(e01).
*-- 오류 Update 정보 구성
    ls_rst_if = VALUE #( BASE ls_rst_if
                        zstat        = zo_result
                        zmessage     = zo_message
                        zerp_stat    = 'E'
                        zerp_message = '납기변경요청 송수신 정보 저장 실패.'(e06)
                       ).
    PERFORM save_if_log_info_for_9000
                                    USING    i_system_id
                                             ls_rst_if
                                             abap_false
                                             is_header
                                    CHANGING lv_eflg.
    RETURN.
  ENDIF.

*-- 3-2. 판매오더 제조지시 정보 Update 수행
  READ TABLE lt_chk_dat INDEX 1 INTO DATA(ls_chk_dat).

* 생관에서 입력한 날짜가 영업에서 요청한 날짜보다 더 빠를 경우
* 영업사원 확인절차 없이 바로 출하예정일 변경 처리
  IF is_header-confrdd LE ls_chk_dat-rdd_new. "(rdd_new: 영업 요청 날짜. confrdd: 생관 입력날짜)
    PERFORM upd_db_0065_for_delv_dt TABLES   it_item[]
                                             ot_result[]
                                    USING    is_header
                                             i_system_id
                                    CHANGING lv_eflg.

    IF lv_eflg EQ abap_true.
*-- 해당 정보 Update 실패시 오류 정보 리턴
      zo_result  = '01'.
      zo_message = '데이터 수신 도중 오류가 발생했습니다.'(e01).
*-- 오류 Update 정보 구성
      ls_rst_if = VALUE #( BASE ls_rst_if
                          zstat        = zo_result
                          zmessage     = zo_message
                          zerp_stat    = 'E'
                          zerp_message = '납기변경요청 송수신 정보 저장 실패.'(e06)
                         ).
      PERFORM save_if_log_info_for_9000
                                      USING    i_system_id
                                               ls_rst_if
                                               abap_false
                                               is_header
                                      CHANGING lv_eflg.
      RETURN.
    ENDIF.

*-- 판매오더 변경 이전 해당 DB 저장 정보 Commit Work
    COMMIT WORK AND WAIT.
*-- 3-3. 판매오더 Header 정보 변경
    PERFORM upd_sd_ord_header       TABLES   it_item[]
                                             ot_result[]
                                    USING    is_header
                                    CHANGING lv_eflg.

    IF lv_eflg EQ abap_true.
*-- 해당 판매오더 변경 실패정보 존재시 오류 정보 리턴
      zo_result  = '01'.
      zo_message = '판매오더 출하예정일 변경 도중 오류가 발생했습니다.'(e07).

*-- 오류 Update 정보 구성
      ls_rst_if = VALUE #( BASE ls_rst_if
                          zstat        = zo_result
                          zmessage     = zo_message
                          zerp_stat    = 'E'
                          zerp_message = '판매오더 출하예정일 변경 도중 오류가 발생했습니다.'(e07)
                         ).
      PERFORM save_if_log_info_for_9000
                                      USING    i_system_id
                                               ls_rst_if
                                               abap_false
                                               is_header
                                      CHANGING lv_eflg.
      RETURN.
    ENDIF.
  ENDIF.

*-----------------------------------------------------------------------
*-- 4. 특이사항 정보 저장 수행
*-----------------------------------------------------------------------
  PERFORM save_text_for_zremark     USING    is_header.

*-----------------------------------------------------------------------
*-- 수신정보 변경 성공시 해당 log 정보 저장
*-----------------------------------------------------------------------
  zo_result  = '00'.
  zo_message = '데이터 수신에 성공하였습니다.'(m02).

*-- 성공 Log 정보 구성
  ls_rst_if = VALUE #( BASE ls_rst_if
                      zstat        = zo_result
                      zmessage     = zo_message
                      zerp_stat    = 'S'
                      zerp_message = '출하예정일 변경 결과 수신에 성공하였습니다.'(m01)
                     ).

  PERFORM save_if_log_info_for_9000 USING    i_system_id
                                             ls_rst_if
                                             abap_false
                                             is_header
                                    CHANGING lv_eflg.
  IF lv_eflg EQ abap_true.
*-- 수신 이력 저장 실패시 오류 정보 리턴
    zo_result  = '01'.
    zo_message = '데이터 수신 도중 오류가 발생했습니다.'(e01).
  ENDIF.

ENDFUNCTION.
