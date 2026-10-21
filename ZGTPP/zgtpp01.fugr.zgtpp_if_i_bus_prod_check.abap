FUNCTION zgtpp_if_i_bus_prod_check.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTETARGET
*"     VALUE(I_SPMON) TYPE  SPMON
*"     VALUE(I_WERKS) TYPE  WERKS_D
*"     VALUE(I_STAT) TYPE  ZGTESTAT2
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ITEM STRUCTURE  ZGTPPS0003
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_BUS_PROD_CHECK
*& 프로그램 명 : [GT][부스닥트 MES] 도체가공 완료여부 수신
*& 개요   :
*& 생성일 : 2025.05.26
*& 생성자 : ZGSIDEV06
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : 부스닥트 MES
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
  DATA : lt_9030 LIKE TABLE OF zgtppt9030,
         ls_9030 LIKE zgtppt9030.
  DATA : lv_tabix LIKE sy-tabix.
*- 필수 값 체크
  IF i_system_id IS INITIAL.
    zo_result = '1'. zo_message = TEXT-m36 && TEXT-001. "송신 시스템
  ELSEIF i_spmon IS INITIAL.
    zo_result = '1'. zo_message = TEXT-m36 && TEXT-002. "대상 년월
  ELSEIF i_werks IS INITIAL.
    zo_result = '1'. zo_message = TEXT-m36 && TEXT-003. "플랜트
  ELSEIF i_stat IS INITIAL.
    zo_result = '1'. zo_message = TEXT-m36 && TEXT-004. "처리모드
  ELSEIF it_item[] IS INITIAL.
    zo_result = '1'. zo_message = TEXT-m37. "수신 데이터 존재 여부
  ENDIF.

  CHECK zo_result IS INITIAL.
*- 유효성 점검
  LOOP AT it_item INTO DATA(ls_item).

    lv_tabix = sy-tabix.
* 생산오더번호 입력 유무 체크
    IF ls_item-aufnr IS INITIAL.

      zo_result = '1'. zo_message = TEXT-m38.
      EXIT.
* 완료여부 입력 유무 체크
    ELSEIF ls_item-zcompleted IS INITIAL.

      zo_result = '1'. zo_message = TEXT-m39.
      EXIT.
* 생산오더번호 정상 여부 체크
    ELSE.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_item-aufnr
        IMPORTING
          output = ls_item-aufnr.

      SELECT SINGLE mandt INTO @sy-mandt FROM aufk
                          WHERE aufnr EQ @ls_item-aufnr.
      IF sy-subrc <> 0.
        zo_result = '1'. zo_message = TEXT-e48.
        EXIT.
      ELSE.
        MODIFY it_item FROM ls_item INDEX lv_tabix.
      ENDIF.

    ENDIF.

  ENDLOOP.

  CHECK zo_result IS INITIAL.
*- 수신 데이터 저장
* I_STAT 가 "P(완료여부 설정)"일 경우 ZGTPPT9030에 저장
  IF i_stat EQ 'P'.

    CLEAR lt_9030.
    LOOP AT it_item INTO ls_item.

      CLEAR : ls_9030.
      ls_9030-zsystem_id   = i_system_id.
      ls_9030-spmon        = i_spmon.
      ls_9030-werks        = i_werks.
      ls_9030-aufnr        = ls_item-aufnr.
      ls_9030-zcompleted   = ls_item-zcompleted.
      ls_9030-zerp_stat    = 'S'.
      ls_9030-zerp_message = TEXT-m42.
      ls_9030-ifdat        = sy-datum.
      ls_9030-iftim        = sy-uzeit.
      ls_9030-ifnam        = sy-uname.
      APPEND ls_9030 TO lt_9030.

    ENDLOOP.

    IF lt_9030 IS NOT INITIAL.
      MODIFY zgtppt9030 FROM TABLE lt_9030.
      IF sy-subrc = 0.
        COMMIT WORK.
        zo_result = '0'. zo_message = TEXT-m40.
      ELSE.
        ROLLBACK WORK.
        zo_result = '1'. zo_message = TEXT-m41.
      ENDIF.
    ENDIF.
* I_STAT 가 "C(완료여부 설정 취소)"일 경우 진행여부 점검 후 삭제 수행
  ELSEIF i_stat EQ 'C'.

    SELECT SINGLE mandt INTO @sy-mandt FROM zgtppt9030
                        WHERE zsystem_id EQ @i_system_id
                          AND spmon      EQ @i_spmon
                          AND werks      EQ @i_werks
                          AND zcompleted EQ 'N'
                          AND ( c_stat = 'Y' OR
                                r_stat = 'Y' ).
* 데이터 존재시 에러 리턴 메시지 출력
    IF sy-subrc = 0.
      zo_result = '1'. zo_message = TEXT-m43.
    ELSE.
* 없으면 DELETE 수행
      DELETE FROM zgtppt9030
             WHERE zsystem_id EQ @i_system_id
               AND spmon      EQ @i_spmon
               AND werks      EQ @i_werks.
      IF sy-subrc = 0.
        COMMIT WORK.
        zo_result = '0'. zo_message = TEXT-m40.
      ELSE.
        ROLLBACK WORK.
        zo_result = '1'. zo_message = TEXT-m41.
      ENDIF.

    ENDIF.

  ENDIF.

ENDFUNCTION.
