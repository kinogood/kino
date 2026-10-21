FUNCTION zgtpp_pgm_manual_popup.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_PROGRAM) TYPE  PROGNAME
*"     REFERENCE(IV_LANGU) TYPE  SPRAS OPTIONAL
*"     REFERENCE(IV_ALLOW_COMMIT) TYPE  XFELD
*"  EXPORTING
*"     REFERENCE(EV_SAVED) TYPE  XFELD
*"     REFERENCE(EV_MODE) TYPE  CHAR1
*"     REFERENCE(ES_RETURN) TYPE  BAPIRET2
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_PROGRAM) TYPE  PROGNAME
*"     REFERENCE(IV_LANGU) TYPE  SPRAS OPTIONAL
*"     REFERENCE(IV_ALLOW_COMMIT) TYPE  XFELD
*"  EXPORTING
*"     REFERENCE(EV_SAVED) TYPE  XFELD
*"     REFERENCE(EV_MODE) TYPE  CHAR1
*"     REFERENCE(ES_RETURN) TYPE  BAPIRET2
*&---------------------------------------------------------------------*
*& 모듈        : CM
*& 프로그램 ID : ZGTPP_PGM_MANUAL_POPUP
*& 프로그램 명 : [공통] 프로그램 도움말
*& 개요   : 프로그램 내 도움말 수정/조회 팝업 및 권한 관리
*& 생성일 : 2026.09.13
*& 생성자 : ZLSGED3
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수행절차
*&---------------------------------------------------------------------*
*& 1) 테이블 내 권한 및 프로그램 정의 ( ZGTED_MANU ) -> ZGTPPT1000 ( CM 9001 )
*& 2) 권한 보유자 도움말 수정 (수정 시 Lock)
*& 3) 도움말 저장
*& 4) 도움말 조회 (프로그램 내 이식 필요)
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*----------------------------------------------------------------------*
*  Date.     Author.  Description.                                     *
*----------------------------------------------------------------------*
* 2026.09.13 김재석   Initial Release (Req by 방태영)
* 2026.09.13 김재석   텍스트 및 스크린 수정, 권한 관리 조견표에 내용 포함
*                     모듈 - CM , 코드그룹 - 9001
*----------------------------------------------------------------------*

  DATA: lv_program     TYPE progname,
        lv_found       TYPE progname,
        lv_langu       TYPE spras,
        lv_name        TYPE thead-tdname,
        lv_title       LIKE sy-title,
        lv_edit        TYPE xfeld,
        lv_display     TYPE xfeld,
        lv_locked      TYPE xfeld,
        lv_auth        TYPE xfeld,
        lv_old_ucomm   TYPE syucomm,
        lv_popup_ucomm TYPE syucomm,
        lv_answer      TYPE c LENGTH 1,
        lv_width       TYPE i,
        lv_length      TYPE i,
        lv_offset      TYPE i,
        lv_take        TYPE i,
        lv_any_text    TYPE xfeld,
        lv_saving      TYPE xfeld,
        lv_string      TYPE string,
        lv_failure     TYPE string,
        ls_header      TYPE thead,
        ls_line        TYPE tline,
        lt_lines       TYPE STANDARD TABLE OF tline,
        lt_editor      TYPE ty_pgman_text,
        lt_before      TYPE ty_pgman_text,
*****        lt_editor      TYPE catsxt_longtext_itab,
*****        lt_before      TYPE catsxt_longtext_itab,
        lv_editor_line LIKE LINE OF lt_editor,
        lo_error       TYPE REF TO cx_root,

        lv_popup_error TYPE string.

  DATA: gt_1010        TYPE TABLE OF zgtppt1010,
        gt_1010_btext  TYPE TABLE OF zgtppt1010,
        gt_1010_source TYPE TABLE OF zgtppt1010,
        gs_1000_source TYPE zgtppt1000.

  CLEAR: ev_saved, ev_mode, es_return.

  lv_old_ucomm = sy-ucomm.
  lv_program = iv_program.
  TRANSLATE lv_program TO UPPER CASE.

  lv_langu = iv_langu.
  IF lv_langu IS INITIAL.
    lv_langu = sy-langu.
  ENDIF.

  IF sy-batch = 'X' OR sy-binpt = 'X'.
    es_return-type = 'E'.
    es_return-message =
      '대화형 SAP GUI에서만 도움말을 열 수 있습니다.'.
    RETURN.
  ENDIF.

  IF lv_program IS INITIAL OR lv_program CA '*,'.
    es_return-type = 'E'.
    es_return-message =
      '유효한 호출 프로그램명을 전달하세요.'.
    RETURN.
  ENDIF.

  SELECT SINGLE name
    INTO lv_found
    FROM trdir
    WHERE name = lv_program.

  IF sy-subrc <> 0.
    es_return-type = 'E'.
    es_return-message =
      '등록되지 않은 프로그램입니다.'.
    RETURN.
  ENDIF.

  CONCATENATE 'ZPGMAN_' lv_program INTO lv_name.

* 로그인 사용자의 프로그램별 편집 권한
*  SELECT SINGLE edit
*    INTO lv_auth
*    FROM zgted_manu
*    WHERE progname = lv_program
*      AND uname    = sy-uname.

  SELECT * FROM zgtppt1010
      INTO CORRESPONDING FIELDS OF TABLE gt_1010_source
  WHERE module_kind = 'CM'
  AND codegrp = '9001'.

  SORT gt_1010_source BY fld_01 fld_02.
  READ TABLE gt_1010_source ASSIGNING FIELD-SYMBOL(<fs_1010>)
                                   WITH KEY fld_01 = sy-uname.
  IF sy-subrc EQ 0 AND
     iv_allow_commit = 'X' AND
     <fs_1010>-fld_03 IS NOT INITIAL.
    lv_edit = 'X'.
  ENDIF.

*  IF sy-subrc = 0
*     AND lv_auth = 'X'
*     AND iv_allow_commit = 'X'.
*    lv_edit = 'X'.
*  ENDIF.

  TRY.
      DO 1 TIMES.

* 프로그램 단위 편집 잠금
        IF lv_edit = 'X'.

*          CALL FUNCTION 'ENQUEUE_EZPGMAN'
*            EXPORTING
*              mode_ZGTED_MANU = 'E'
*              mandt           = sy-mandt
*              progname        = lv_program
*              uname           = space
*              x_uname         = space
*              _scope          = '1'
*              _wait           = space
*            EXCEPTIONS
*              foreign_lock    = 1
*              system_failure  = 2
*              OTHERS          = 3.
*
*          CASE sy-subrc.
*            WHEN 0.
*              lv_locked = 'X'.
*
*            WHEN 1.
*              CLEAR lv_edit.
*              es_return-type = 'W'.
*              es_return-message =
*                '다른 관리자가 편집 중이므로 조회로 열었습니다.'.
*
*            WHEN OTHERS.
*              es_return-type = 'E'.
*              es_return-message =
*                '편집 잠금을 설정하지 못했습니다.'.
*              EXIT.
*          ENDCASE.

        ENDIF.

* 기존 도움말 읽기
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            client                  = sy-mandt
            object                  = 'TEXT'
            id                      = 'ST'
            name                    = lv_name
            language                = lv_langu
          IMPORTING
            header                  = ls_header
          TABLES
            lines                   = lt_lines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.

        CASE sy-subrc.
          WHEN 0.
          WHEN 4.
            CLEAR lt_lines.
          WHEN OTHERS.
            es_return-type = 'E'.
            es_return-message =
              '롱텍스트 조회 실패: 언어 및 TEXT/ST 설정을 확인하세요.'.
            EXIT.
        ENDCASE.

        DESCRIBE FIELD lv_editor_line
          LENGTH lv_width
          IN CHARACTER MODE.

        IF lv_width < 1 OR lv_width > 132.
          es_return-type = 'E'.
          es_return-message =
            '이 시스템의 팝업 텍스트 행 형식이 예제와 다릅니다.'.
          EXIT.
        ENDIF.

* 일반 텍스트를 팝업용 테이블로 변환
        LOOP AT lt_lines INTO ls_line.

          IF ls_line-tdformat <> '*'
             AND ls_line-tdformat <> '/'
             AND ls_line-tdformat IS NOT INITIAL.
            es_return-type = 'E'.
            es_return-message =
              '서식/명령이 있는 텍스트입니다. 일반 텍스트로 먼저 정리하세요.'.
            EXIT.
          ENDIF.

          lv_string = ls_line-tdline.
          lv_length = strlen( lv_string ).

          IF lv_length = 0.

            CLEAR lv_editor_line.
            APPEND lv_editor_line TO lt_editor.

          ELSE.

            lv_offset = 0.

            WHILE lv_offset < lv_length.

              lv_take = lv_length - lv_offset.
              IF lv_take > lv_width.
                lv_take = lv_width.
              ENDIF.

              CLEAR lv_editor_line.
              lv_editor_line =
                lv_string+lv_offset(lv_take).

              APPEND lv_editor_line TO lt_editor.
              lv_offset = lv_offset + lv_take.

            ENDWHILE.

          ENDIF.

        ENDLOOP.

        IF es_return-type = 'E'.
          EXIT.
        ENDIF.

        IF lt_editor IS INITIAL
           AND lv_edit IS INITIAL.
          es_return-type = 'I'.
          es_return-message =
            '이 프로그램/언어에 등록된 도움말이 없습니다.'.
          EXIT.
        ENDIF.

* 편집 또는 조회 모드 결정
        lv_display = 'X'.
        ev_mode = 'D'.

        IF lv_edit = 'X'.

          CLEAR lv_display.
          ev_mode = 'E'.

          CONCATENATE lv_program '- 도움말 편집'
            INTO lv_title SEPARATED BY space.

        ELSE.

          CONCATENATE lv_program '- 도움말 조회'
            INTO lv_title SEPARATED BY space.

        ENDIF.

        lt_before = lt_editor.

* 텍스트 팝업
        PERFORM pgman_editor_popup
                USING lv_title lv_display
                CHANGING lt_editor lv_popup_ucomm lv_popup_error.
        IF lv_popup_error IS NOT INITIAL.
          es_return-type = 'E'.
          es_return-message = lv_popup_error.
          EXIT.
        ENDIF.
*****        CALL FUNCTION 'CATSXT_SIMPLE_TEXT_EDITOR'
*****          EXPORTING
*****            im_title        = lv_title
*****            im_display_mode = lv_display
*****            im_start_column = 5
*****            im_start_row    = 2
*****          CHANGING
*****            ch_text         = lt_editor
*****          EXCEPTIONS
*****            error_message   = 1
*****            OTHERS          = 2.
*****
*****        lv_popup_ucomm = sy-ucomm.
*****
*****        IF sy-subrc <> 0.
*****          es_return-type = 'E'.
*****          es_return-message =
*****            '표준 텍스트 팝업을 열지 못했습니다.'.
*****          EXIT.
*****        ENDIF.

        IF lv_edit IS INITIAL.
          EXIT.
        ENDIF.

* 계속 버튼을 누른 경우에만 저장 검토
* 취소 또는 알 수 없는 반환 명령이면 저장하지 않음
        IF lv_popup_ucomm <> 'CX_CONT'
           OR lt_editor = lt_before.
          EXIT.
        ENDIF.

* 빈 내용으로 덮어쓰는 것 방지
        CLEAR lv_any_text.

        LOOP AT lt_editor INTO lv_editor_line.
          IF lv_editor_line IS NOT INITIAL.
            lv_any_text = 'X'.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF lv_any_text IS INITIAL.
          es_return-type = 'E'.
          es_return-message =
            '빈 내용은 저장하지 않습니다. 기존 도움말은 유지됩니다.'.
          EXIT.
        ENDIF.

        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar              = '도움말 저장'
            text_question         = '변경한 도움말을 저장하시겠습니까?'
            text_button_1         = '저장'
            text_button_2         = '저장 안 함'
            default_button        = '2'
            display_cancel_button = 'X'
          IMPORTING
            answer                = lv_answer
          EXCEPTIONS
            text_not_found        = 1
            OTHERS                = 2.

        IF sy-subrc <> 0 OR lv_answer <> '1'.
          EXIT.
        ENDIF.

* 저장 직전 권한 재확인
        SELECT * FROM zgtppt1010
            INTO CORRESPONDING FIELDS OF TABLE gt_1010_source
        WHERE module_kind = 'CM'
        AND codegrp = '9001'.

        SORT gt_1010_source BY fld_01 fld_02.
        READ TABLE gt_1010_source ASSIGNING <fs_1010>
                                          WITH KEY fld_01 = sy-uname.
        IF sy-subrc EQ 0 AND
           iv_allow_commit = 'X' AND
           <fs_1010>-fld_03 IS NOT INITIAL.
          lv_edit = 'X'.
        ENDIF.

*****        CLEAR lv_auth.
*****
*****        SELECT SINGLE edit
*****          INTO lv_auth
*****          FROM zgted_manu
*****          WHERE progname = lv_program
*****            AND uname    = sy-uname.


        IF lv_edit <> 'X'
        OR iv_allow_commit <> 'X'.
*****        IF sy-subrc <> 0
*****           OR lv_auth <> 'X'
*****           OR iv_allow_commit <> 'X'.
*****           OR lv_locked <> 'X'.
          es_return-type = 'E'.
          es_return-message =
            '편집 권한 또는 잠금이 없어 저장하지 않았습니다.'.
          EXIT.

        ENDIF.

* 롱텍스트 저장 데이터 구성
        CLEAR: ls_header, lt_lines.

        ls_header-tdobject = 'TEXT'.
        ls_header-tdid     = 'ST'.
        ls_header-tdname   = lv_name.
        ls_header-tdspras  = lv_langu.
        ls_header-tdtitle  = lv_program.

        LOOP AT lt_editor INTO lv_editor_line.

          CLEAR ls_line.
          ls_line-tdformat = '*'.
          ls_line-tdline   = lv_editor_line.
          APPEND ls_line TO lt_lines.

        ENDLOOP.

        lv_saving = 'X'.

        CALL FUNCTION 'SAVE_TEXT'
          EXPORTING
            client          = sy-mandt
            header          = ls_header
            insert          = space
            savemode_direct = 'X'
          TABLES
            lines           = lt_lines
          EXCEPTIONS
            id              = 1
            language        = 2
            name            = 3
            object          = 4
            OTHERS          = 5.

        IF sy-subrc <> 0.

          ROLLBACK WORK.

          es_return-type = 'E'.
          es_return-message =
            '도움말 저장에 실패했습니다.'.
          EXIT.

        ENDIF.

        COMMIT WORK AND WAIT.

        IF sy-subrc <> 0.
          es_return-type = 'E'.
          es_return-message =
            '커밋 오류입니다. 저장 상태와 업데이트 로그를 확인하세요.'.
          EXIT.
        ENDIF.

        ev_saved = 'X'.
        CLEAR lv_saving.

        es_return-type = 'S'.
        es_return-message = '도움말을 저장했습니다.'.

      ENDDO.

    CATCH cx_root INTO lo_error.

      IF lv_saving = 'X'
         AND iv_allow_commit = 'X'.
        ROLLBACK WORK.
      ENDIF.

      lv_failure = lo_error->get_text( ).

      es_return-type = 'E'.
      es_return-message = lv_failure.

  ENDTRY.

* 편집 잠금 해제
  IF lv_locked = 'X'.

    CALL FUNCTION 'DEQUEUE_EZPGMAN'
      EXPORTING
        mode_ZGTED_MANU = 'E'
        mandt           = sy-mandt
        progname        = lv_program
        uname           = space
        x_uname         = space
        _scope          = '1'.

  ENDIF.

  sy-ucomm = lv_old_ucomm.


ENDFUNCTION.
