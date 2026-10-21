FUNCTION ZGTPP_DRUM_NO_INIT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_GUBUN) TYPE  CHAR01 DEFAULT 'A'
*"     VALUE(IV_WERKS) TYPE  WERKS_D OPTIONAL
*"     VALUE(IV_MATNR) TYPE  MATNR OPTIONAL
*"  EXPORTING
*"     VALUE(EV_TYPE) TYPE  ZO_RESULT
*"     VALUE(EV_MESSAGE) TYPE  ZO_MESSAGE
*"----------------------------------------------------------------------

  DATA : LT_2500 TYPE TABLE OF ZGTPPT2500.

* 삭제 구분 ( 'A' = 전제삭제, 'S' = 선택삭제 )
  EV_TYPE = '00'.

  CASE IV_GUBUN.
    WHEN 'A'.
      DELETE FROM ZGTPPT2500.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
        EV_MESSAGE = '전체 초기화 되었습니다.'.
      ELSE.
        ROLLBACK WORK.
        EV_TYPE = '02'.
        EV_MESSAGE = '전체 초기화 실패하였습니다.'.
      ENDIF.
    WHEN 'S'.
      IF IV_WERKS IS INITIAL OR IV_MATNR IS INITIAL.
        EV_TYPE = '02'.
        EV_MESSAGE = '선택 초기화의 경우 플랜트, 자재코드 필수 입력입니다.'.
        RETURN.
      ENDIF.

      SELECT * FROM ZGTPPT2500
        INTO TABLE LT_2500
       WHERE WERKS = IV_WERKS
         AND MATNR = IV_MATNR.
      IF SY-SUBRC EQ 0.
        DELETE FROM ZGTPPT2500
         WHERE WERKS = IV_WERKS
           AND MATNR = IV_MATNR.
        IF SY-SUBRC EQ 0.
          COMMIT WORK AND WAIT.
          EV_MESSAGE = '선택자재 드럼넘버 초기화 되었습니다.'.
        ELSE.
          ROLLBACK WORK.
          EV_TYPE = '02'.
          EV_MESSAGE = '선택자재 드럼넘버 초기화 실패하였습니다.'.
        ENDIF.
      ELSE.
        EV_TYPE = '02'.
        EV_MESSAGE = '선택자재 드럼넘버 초기화 실패하였습니다.'.
      ENDIF.
  ENDCASE.



ENDFUNCTION.
