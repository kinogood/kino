*&---------------------------------------------------------------------*
*& Include          LZGOPPU2P01
*&---------------------------------------------------------------------*

CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      ON_SAPEVENT FOR EVENT SAPEVENT OF CL_GUI_HTML_VIEWER
        IMPORTING ACTION FRAME GETDATA POSTDATA QUERY_TABLE.
ENDCLASS.

CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
  METHOD ON_SAPEVENT.
    " HTML에서 보낸 이벤트명(action)에 따라 분기 처리
    CASE ACTION.
      WHEN 'CONFIRM'.
        " 📌 핵심: SAP GUI에 새로운 OK_CODE를 주입하여 강제로 PAI를 트리거합니다.
        CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
          EXPORTING
            NEW_CODE = 'BACK'. " PAI에서 인식할 OK_CODE 변수값

        CALL METHOD CL_GUI_CFW=>FLUSH.

    ENDCASE.
  ENDMETHOD.
ENDCLASS.
