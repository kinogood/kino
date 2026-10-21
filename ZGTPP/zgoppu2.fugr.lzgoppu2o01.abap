*----------------------------------------------------------------------*
***INCLUDE LZGOPPU2O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100' WITH GV_TITLE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_HTML_VIEW OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_HTML_VIEW OUTPUT.
  IF HTML_CONTROL IS NOT BOUND.
    CREATE OBJECT G_DOCKING_0100
      EXPORTING
        REPID                       = SY-REPID
        DYNNR                       = SY-DYNNR
        EXTENSION                   = 10000
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5.

    CREATE OBJECT HTML_CONTROL
      EXPORTING
        PARENT = G_DOCKING_0100.                 " Container

    REFRESH GT_EVENTS.
    GS_EVENT-EVENTID    = CL_GUI_HTML_VIEWER=>M_ID_SAPEVENT. " sapevent ID
    GS_EVENT-APPL_EVENT = ' '. " 'X'로 설정해야 PAI로 곧바로 연결됩니다.
    APPEND GS_EVENT TO GT_EVENTS.

    CALL METHOD HTML_CONTROL->SET_REGISTERED_EVENTS
      EXPORTING
        EVENTS = GT_EVENTS.

    " ② 핸들러 메소드 연결 및 이벤트 등록
    SET HANDLER LCL_EVENT_HANDLER=>ON_SAPEVENT FOR HTML_CONTROL.

    " 3. 데이터를 내부 URL로 변환하여 로드
    CALL METHOD HTML_CONTROL->LOAD_DATA
      IMPORTING
        ASSIGNED_URL = URL
      CHANGING
        DATA_TABLE   = HTML_TABLE.

    " 4. 화면에 표시
    CALL METHOD HTML_CONTROL->SHOW_URL
      EXPORTING
        URL = URL.
  ENDIF.
ENDMODULE.
