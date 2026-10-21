FUNCTION z_ti_popup_to_confirm_message.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(XMODE) TYPE  C DEFAULT 'C'
*"     REFERENCE(IM_DOCUMENT) TYPE  ZTIREQTY OPTIONAL
*"  EXPORTING
*"     REFERENCE(ANSWER) TYPE  C
*"----------------------------------------------------------------------

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

*>----------------------------------------------------------------------
*> XMODE : 'C' : 생성.
*          'M' : 변경.
*          'S' : 조회.
*          'D' : 삭제.
*          'Q' : 수입의뢰요청.
*          '1' : 수입의뢰요청 취소.
*          'A' : 접수.
*          'E' : 접수반려.
*          '5' : 상신.
*          '6' : 상신취소.
*          'Y' : 신청저장.
*          'I' : EDI 신청.
*          'F' : 신청취소.
*          'N' : 개설취소.
*          'O' : 개설.
*          'G' : 종료.
*          'H' : 종료취소.
*          'P' : 전기.
*          'R' : 취소.
*          '8' : 입고.
*          '9' : 입고취소.
*          'V' : 이동.
*          'Z' : 인쇄.
*          'X' : Exit
*>----------------------------------------------------------------------
*>----------------------------------------------------------------------
*> ANSWER : 'Y' : Yes
*           'N' : No
*           'A' : Cancel
*>----------------------------------------------------------------------

  CLEAR : pop, answer.

  CASE xmode.
    WHEN 'V'.
      MOVE: '저장하지 않은 데이타는 손실됩니다.' TO pop-diagnose1,
            '저장 후 이동 하시겠습니까?'         TO pop-textline1,
            '저장 확인'                          TO pop-titel.
      cancel_display = 'X'.
    WHEN 'Q'.
      MOVE: '해당 문서(들)을 수입요청 처리합니다.' TO pop-diagnose1,
            '수입요청 처리 하시겠습니까?'          TO pop-textline1,
            '수입요청 확인'                        TO pop-titel.
      cancel_display = 'X'.
    WHEN '1'.
      MOVE: '해당 문서(들)을 수입요청취소 처리합니다.' TO pop-diagnose1,
            '수입요청취소 처리 하시겠습니까?'          TO pop-textline1,
            '수입요청취소 확인'                        TO pop-titel.
      cancel_display = 'X'.
    WHEN 'A'.
      CASE im_document.
        WHEN 'BL'.
          MOVE: '해당 문서(들)을 송부 처리합니다.'   TO pop-diagnose1,
                '선적서류 송부 처리 하시겠습니까?'   TO pop-textline1,
                '선적서류 송부 확인'                 TO pop-titel.
          cancel_display = 'X'.
        WHEN OTHERS.
          MOVE: '해당 문서(들)을 접수 처리합니다.'   TO pop-diagnose1,
                '접수 처리 하시겠습니까?'            TO pop-textline1,
                '접수 확인'                          TO pop-titel.
          cancel_display = 'X'.
      ENDCASE.
    WHEN 'E'.
      CASE im_document.
        WHEN 'BL'.
          MOVE: '해당 문서(들)을 선적서류 송부취소합니다.'
                                                     TO pop-diagnose1,
                '선적서류 송부취소를 하시겠습니까?'  TO pop-textline1,
                '선적서류 송부취소 확인'             TO pop-titel.
          cancel_display = 'X'.
        WHEN OTHERS.
          MOVE: '해당 문서(들)을 회송 처리합니다.' TO pop-diagnose1,
                '회송 처리를 하시겠습니까?'        TO pop-textline1,
                '회송 확인'                        TO pop-titel.
          cancel_display = 'X'.
      ENDCASE.
    WHEN 'Y'.
      MOVE: '해당 신청서 내역만을 저장합니다.' TO pop-diagnose1,
            '신청서를 저장 하시겠습니까?'      TO pop-textline1,
            '저장 확인'                        TO pop-titel.
      cancel_display = 'X'.
    WHEN 'F'.
      MOVE: '해당 문서(들)을 EDI로 전송 취소합니다.' TO pop-diagnose1,
            '전송 취소하시겠습니까?'                 TO pop-textline1,
            '전송 취소 확인'                         TO pop-titel.
      cancel_display = 'X'.
    WHEN 'I'.
      CASE im_document.
        when 'LC'.
          MOVE: '해당 문서(들)을 해당은행으로 개설신청합니다.'
                                                    TO pop-diagnose1,
            '''확인''버튼을 선택시 EDI 전송되고,'   TO pop-textline1,
            '''아니오''버튼 선택시는 수작업으로 진행됩니다.'
                                                    TO pop-textline2,
            '전송 확인'                         TO pop-titel.
        when 'LG'.
          MOVE: '해당 문서(들)을 해당은행으로 발급의뢰합니다.'
                                                    TO pop-diagnose1,
            '''확인''버튼을 선택시 EDI 전송되고,'   TO pop-textline1,
            '''아니오''버튼 선택시는 수작업으로 진행됩니다.'
                                                    TO pop-textline2,
            '전송 확인'                         TO pop-titel.
        when 'IP'.
          MOVE: '해당 문서(들)을 해당보험사로 부보의뢰합니다.'
                                                    TO pop-diagnose1,
            '''확인''버튼을 선택시 EDI 전송되고,'   TO pop-textline1,
            '''아니오''버튼 선택시는 수작업으로 진행됩니다.'
                                                    TO pop-textline2,
            '전송 확인'                         TO pop-titel.
        when 'CR'.
          MOVE:'해당 문서를 해당 관세사(세관)로 수입신고의뢰합니다.'
                                                    TO pop-diagnose1,
            '''확인''버튼을 선택시 EDI 전송되고,'   TO pop-textline1,
            '''아니오''버튼 선택시는 수작업으로 진행됩니다.'
                                                    TO pop-textline2,
            '전송 확인'                         TO pop-titel.
*        when 'CC'.
      endcase.
        cancel_display = 'X'.
    WHEN 'O'.
      CASE im_document.
        WHEN 'BL'.
          MOVE: '해당 문서들을 통관요청 처리합니다.'  TO pop-diagnose1,
                '통관요청 하시겠습니까?'              TO pop-textline1,
                '통관요청 확인'                       TO pop-titel.
          cancel_display = 'X'.
        WHEN 'IP'.
          MOVE:'해당 문서들을 부보처리 합니다.'        TO pop-diagnose1,
               '부보처리 하시겠습니까?'                TO pop-textline1,
               '부보처리 확인'                         TO pop-titel.
          cancel_display = 'X'.
        WHEN 'LG'.
          MOVE:'해당 문서들을 발급(승인) 처리합니다.'  TO pop-diagnose1,
               '발급(승인) 하시겠습니까?'              TO pop-textline1,
               '발급처리 확인'                         TO pop-titel.
          cancel_display = 'X'.
        WHEN OTHERS.
          MOVE: '해당 문서들을 개설(승인)처리합니다.' TO pop-diagnose1,
                '개설(승인) 하시겠습니까?'            TO pop-textline1,
                '개설 확인'                           TO pop-titel.
          cancel_display = 'X'.
      ENDCASE.
    WHEN 'N'.
      CASE im_document.
        WHEN 'BL'.
          MOVE: '해당 문서들을 개설(승인) 취소합니다.' TO pop-diagnose1,
                '개설(승인)취소 하시겠습니까?'         TO pop-textline1,
                '개설취소 확인'                        TO pop-titel.
          cancel_display = 'X'.
        WHEN 'IP'.
          MOVE: '해당 문서들을 부보내역을 취소합니다.' TO pop-diagnose1,
                '부보취소 하시겠습니까?'               TO pop-textline1,
                '부보취소 확인'                        TO pop-titel.
          cancel_display = 'X'.
        WHEN 'LG'.
          MOVE: '해당 문서들을 발급 취소합니다.'       TO pop-diagnose1,
                '발급취소 하시겠습니까?'               TO pop-textline1,
                '발급취소 확인'                        TO pop-titel.
          cancel_display = 'X'.
        WHEN OTHERS.
          MOVE: '해당 문서들을 개설(승인) 취소합니다.' TO pop-diagnose1,
                '개설(승인)취소 하시겠습니까?'         TO pop-textline1,
                '개설취소 확인'                        TO pop-titel.
          cancel_display = 'X'.
      ENDCASE.
    WHEN 'G'.
      MOVE: '해당 문서들을 Closing 처리합니다.'    TO pop-diagnose1,
            'Closing 처리 하시겠습니까?'           TO pop-textline1,
            'Closing 처리 확인'                    TO pop-titel.
      cancel_display = 'X'.
    WHEN 'H'.
      MOVE: '해당 문서를 Closing 취소 처리합니다.' TO pop-diagnose1,
            'Closing 취소처리 하시겠습니까?'       TO pop-textline1,
            'Closing 취소처리 확인'                TO pop-titel.
      cancel_display = 'X'.
    WHEN 'C' OR 'M'.
      MOVE: '저장하지 않은 데이타는 손실됩니다.'  TO pop-diagnose1,
            '저장 하시겠습니까?'                  TO pop-textline1,
            '저장 확인'                           TO pop-titel.
      cancel_display = 'X'.
    WHEN 'D'.
      MOVE: '현재 데이타가 모두 손실됩니다.'      TO pop-diagnose1,
            '삭제 하시겠습니까?'                  TO pop-textline1,
            '삭제 확인'                           TO pop-titel.
      cancel_display = 'X'.
*    WHEN 'M'.
*      MOVE: '현재 데이타에 삭제표시를 합니다.'    TO pop-diagnose1,
*            '진행 하시겠습니까?'                  TO pop-textline1,
*            '삭제표시 확인'                       TO pop-titel.
*      cancel_display = 'X'.
    WHEN 'P'.
      MOVE: '현재 데이타를 회계전기처리 합니다.'    TO pop-diagnose1,
            '회계전기를 진행 하시겠습니까?'     TO pop-textline1,
            '회계전기 확인'                     TO pop-titel.
      cancel_display = 'X'.
    WHEN 'R'.
      MOVE: '현재 데이타를 취소처리 합니다.'    TO pop-diagnose1,
            '전기취소를 진행 하시겠습니까?'     TO pop-textline1,
            '전기취소 확인'                     TO pop-titel.
      cancel_display = 'X'.
*    WHEN 'E'.
*      MOVE: '현재 데이타를 역분개처리 합니다.'  TO pop-diagnose1,
*            '역분개 처리를 하시겠습니까?'       TO pop-textline1,
*            '역분개 확인'                     TO pop-titel.
*      cancel_display = 'X'.
    WHEN 'X'.
      MOVE: '저장하지 않은 데이타는 손실됩니다.'  TO pop-diagnose1,
            '종료 하시겠습니까?'                  TO pop-textline1,
            '종료 확인'                           TO pop-titel.
      CLEAR cancel_display.
    WHEN '8'.
      MOVE: '현재 데이타를 입고처리 합니다.'    TO pop-diagnose1,
            '입고전기를 진행 하시겠습니까?'     TO pop-textline1,
            '입고전기 확인'                     TO pop-titel.
      CLEAR cancel_display.
    WHEN '9'.
      MOVE: '현재 데이타를 입고취소 합니다.'    TO pop-diagnose1,
            '입고취소를 진행 하시겠습니까?'     TO pop-textline1,
            '입고취소 확인'                     TO pop-titel.
      CLEAR cancel_display.
    WHEN '0'.
      MOVE: '해당 사고관리 내역을 저장합니다.' TO pop-diagnose1,
            '보험사고내역 저장 하시겠습니까?'  TO pop-textline1,
            '저장 처리 확인'                   TO pop-titel.
      cancel_display = 'X'.
    WHEN 'T'.
      MOVE: '금액 비율로 아이템이 배부됩니다.'    TO pop-diagnose1,
            '금액을 분할하시겠습니까?'            TO pop-textline1,
            '분할 확인'                           TO pop-titel.
      CLEAR cancel_display.
    WHEN 'Z'.
      MOVE: '변경된 항목을 저장 후 인쇄할 수 있습니다.'
                                                  TO pop-diagnose1,
            '저장 후 인쇄하시겠습니까?'           TO pop-textline1,
            '저장 확인'                           TO pop-titel.
      CLEAR cancel_display.
    WHEN '$'.
      MOVE: '변경된 항목을 저장 후 회계처리할 수 있습니다.'
                                                  TO pop-diagnose1,
            '저장 후 회계처리하시겠습니까?'       TO pop-textline1,
            '저장 확인'                           TO pop-titel.
      CLEAR cancel_display.

    WHEN 'L'.
      MOVE: '기존의 은행 한도을 갱신합니다.'      TO pop-diagnose1,
            '계산 후 갱신하시겠습니까?'           TO pop-textline1,
            '저장 확인'                           TO pop-titel.
      CLEAR cancel_display.
    WHEN '3'.
      MOVE: '선적정보를 확인처리 합니다.'       TO pop-diagnose1,
            '선적정보를 확인처리 하시겠습니까?' TO pop-textline1,
            '확인처리 확인'                     TO pop-titel.
      CLEAR cancel_display.
    WHEN '4'.
      MOVE: '선적정보를 확인을 취소처리 합니다.' TO pop-diagnose1,
            '확인 취소를 진행 하시겠습니까?'     TO pop-textline1,
            '확인취소처리 확인'                  TO pop-titel.
      CLEAR cancel_display.
    WHEN '5'.
      CASE im_document.
        WHEN 'BL'.
          MOVE: '실입항 입력 정보를 저장합니다.'
                                                    TO pop-diagnose1,
                '실입항을 입력 하시겠습니까?'       TO pop-textline1,
                '실입항 입력 확인'                  TO pop-titel.
          CLEAR cancel_display.
        WHEN OTHERS.
*--> LG전선에서 Message 변경. by MSH,20041121
*          MOVE: '개설신청을 결재자에게 상신처리 합니다.'
*                                                    TO pop-diagnose1,
*                '상신작업을 진행 하시겠습니까?'     TO pop-textline1,
*                '상신 확인'                         TO pop-titel.
          MOVE: '은행배정 확정 처리합니다.'
                                                    TO pop-diagnose1,
                '확정 작업을 진행 하시겠습니까?'    TO pop-textline1,
                '은행배정 확인'                     TO pop-titel.
*--> End of Modification.
          CLEAR cancel_display.
      ENDCASE.
    WHEN '6'.
      CASE im_document.
        WHEN 'BL'.
          MOVE: '실입항 입력 정보를 취소처리 합니다.'
                                                     TO pop-diagnose1,
                '실입항 입력 취소를 진행 하시겠습니까?'
                                                     TO pop-textline1,
                '실입항 입력 취소 확인'              TO pop-titel.
          CLEAR cancel_display.
        WHEN OTHERS.
          MOVE: '개설신청된 작업을 취소처리 합니다.'
                                                     TO pop-diagnose1,
                '신청 취소를 진행 하시겠습니까?'     TO pop-textline1,
                '신청 취소처리 확인'                 TO pop-titel.
          CLEAR cancel_display.
      ENDCASE.
    WHEN '7'.
      MOVE: '승인된 자료를 반려 처리 합니다.'    TO pop-diagnose1,
            '반려처리를 진행 하시겠습니까?'      TO pop-textline1,
            '승인 반려처리 확인'                 TO pop-titel.
      CLEAR cancel_display.


    WHEN OTHERS.
      answer = 'Y'.
      EXIT.
  ENDCASE.

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
      answer = 'Y'.
    WHEN 'N'.
      answer = 'N'.
    WHEN 'A'.
      answer = 'A'.
  ENDCASE.

ENDFUNCTION.
