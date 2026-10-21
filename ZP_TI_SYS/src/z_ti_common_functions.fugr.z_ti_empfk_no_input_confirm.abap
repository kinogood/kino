FUNCTION z_ti_empfk_no_input_confirm.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IM_ZTITIG00) TYPE  ZTITIG00 OPTIONAL
*"     REFERENCE(IM_LIFNR) TYPE  LIFNR OPTIONAL
*"     REFERENCE(IM_EMPFK) TYPE  EMPFK OPTIONAL
*"  EXPORTING
*"     VALUE(EX_ANSWER) TYPE  C
*"----------------------------------------------------------------------

  DATA: l_bukrs  TYPE bukrs,
        l_count  TYPE i.


  DATA: cancel_display.
*>------------------------------------------------------
*> MESSAGE POPUP용.
*>------------------------------------------------------
  DATA: BEGIN OF pop,
        titel      LIKE spop-titel,
        diagnose1  LIKE spop-diagnose1,
        diagnose2  LIKE spop-diagnose2,
        diagnose3  LIKE spop-diagnose3,
        textline1  LIKE spop-textline1,
        textline2  LIKE spop-textline2,
        textline3  LIKE spop-textline3,
        option1    LIKE spop-varoption1,
        option2    LIKE spop-varoption2,
        default,             "defaultoption fuer Confirm_step
        answer,
  END OF pop.


*>
  ex_answer = 'Y'.

  CHECK im_empfk IS INITIAL.
*by YSH(070628)JS전선 프로젝트시 회계뷰로 정의 --> 회사코드 인식
*> IMG화.
*  IF im_ztitig00-lfzac EQ 'P'.
*    CLEAR: l_bukrs.
*  ELSEIF im_ztitig00-lfzac EQ 'A'.
    l_bukrs = im_ztitig00-bukrs.
*  ENDIF.

  SELECT COUNT( * )
    INTO l_count
    FROM lfza
   WHERE  bukrs   EQ  l_bukrs
     AND  lifnr   EQ  im_lifnr.

  IF l_count GT 0.
*    IF im_ztitig00-lfzmt EQ 'W'.
      MOVE: '수취인이 지정되어 있는 공급업체입니다.'  TO pop-diagnose1,
            '수취인없이 회계전기 하시겠습니까?'       TO pop-textline1,
            '수취인 확인'                             TO pop-titel.
      CLEAR: cancel_display.

      CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
             EXPORTING
*             DEFAULTOPTION = 'Y'
                  diagnosetext1 = pop-diagnose1
*             DIAGNOSETEXT2 = POP-DIAGNOSE2
*             DIAGNOSETEXT3 = ' '
                  textline1      = pop-textline1
                  textline2      = pop-textline2
                  titel          = pop-titel
*             START_COLUMN   = 25
*             START_ROW      = 6
                  cancel_display = cancel_display
             IMPORTING
                  answer        = pop-answer
             EXCEPTIONS
                  OTHERS        = 1.

      CASE pop-answer.
        WHEN 'J'.
          ex_answer = 'Y'.
        WHEN 'N'.
          ex_answer = 'N'.
        WHEN 'A'.
          ex_answer = 'A'.
      ENDCASE.

*    ELSE.
*      MESSAGE ID      'ZMTI00'
*              TYPE    im_ztitig00-lfzmt
*              NUMBER  '948'
*              WITH    im_lifnr.
*    ENDIF.
  ENDIF.

ENDFUNCTION.
