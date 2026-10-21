FUNCTION ZGTPP_UTILL_DISP_WARNING.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_TITLE) TYPE  SY-TITLE DEFAULT 'Warning'
*"  TABLES
*"      IT_TEXT TYPE  TCHAR255
*"----------------------------------------------------------------------

  REFRESH HTML_TABLE.
  GV_TITLE = IV_TITLE.

  " 1. HTML 데이터 생성 (CSS 스타일 적용)
  APPEND '<html>' TO HTML_TABLE.
  APPEND '<head>' TO HTML_TABLE.
  APPEND '<style>' TO HTML_TABLE.
  " 배경색(#FFFFFF = 흰색), 글자색(red = 빨간색) 지정
  APPEND '  body { background-color: #FFFFFF; color: red; font-family: Arial, sans-serif; }' TO HTML_TABLE.

  APPEND '  .fixed-btn-container {' TO HTML_TABLE.
  APPEND '    position: fixed;' TO HTML_TABLE.      " 📌 화면 상에 위치를 강제로 고정
  APPEND '    bottom: 10px;' TO HTML_TABLE.         " 하단 테두리로부터 20px 띄움
  APPEND '    right: 10px;' TO HTML_TABLE.          " 우측 테두리로부터 20px 띄움
  APPEND '    z-index: 999;' TO HTML_TABLE.         " 텍스트나 다른 요소보다 무조건 위에 보이도록 설정
  APPEND '  }' TO HTML_TABLE.

  " CSS 정의 영역에 추가
  APPEND '  p {' TO HTML_TABLE.
  APPEND '    margin-top: 2px !important;' TO HTML_TABLE.    " 위쪽 여백 최소화
  APPEND '    margin-bottom: 2px !important;' TO HTML_TABLE. " 아래쪽 여백 최소화
  APPEND '    font-size: 12px !important;' TO HTML_TABLE.
  APPEND '  }' TO HTML_TABLE.

  APPEND '</style>' TO HTML_TABLE.
  APPEND '</head>' TO HTML_TABLE.
  APPEND '<body>' TO HTML_TABLE.
  LOOP AT IT_TEXT INTO DATA(LS_TEXT).
    APPEND |  <p>{ LS_TEXT }</p>| TO HTML_TABLE.
  ENDLOOP.

  " 📌 1. 버튼을 감싸는 정렬용 Div 박스를 생성하고 오른쪽 정렬 스타일을 줍니다.
  APPEND '  <div class="fixed-btn-container">' TO HTML_TABLE.
  APPEND '  <div style="display: flex; justify-content: flex-end; padding-right: 10px;">' TO HTML_TABLE.

  APPEND '  <button onclick="location.href=''sapevent:CONFIRM''">확인</button>' TO HTML_TABLE.
  " 📌 3. 감싸고 있던 Div 박스를 닫아줍니다.
  APPEND '  </div>' TO HTML_TABLE.
  APPEND '  </div>' TO HTML_TABLE.
  APPEND '</body>' TO HTML_TABLE.
  APPEND '</html>' TO HTML_TABLE.

  " 2. HTML 뷰어 객체 생성 (기존에 생성되어 있다고 가정)
  " CREATE OBJECT html_control ...

  CALL SCREEN 100 STARTING AT 5 5 ENDING AT 95 10.



ENDFUNCTION.
