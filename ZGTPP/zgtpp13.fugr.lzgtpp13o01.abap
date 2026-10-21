*----------------------------------------------------------------------*
***INCLUDE LZGTPP13O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module LZGTPP13O01 OUTPUT
*&---------------------------------------------------------------------*
*       프로그램 HELP 등록 2026.09.14 by 김재석
*----------------------------------------------------------------------*
MODULE pgman_9000_pbo OUTPUT.
  IF gv_pgman_display = 'X'.
    SET PF-STATUS 'ZMAN9000' EXCLUDING 'ACCEPT'.
  ELSE.
    SET PF-STATUS 'ZMAN9000'.
  ENDIF.
  SET TITLEBAR 'ZMAN_TITLE' WITH gv_pgman_title.
* PBO마다 텍스트를 다시 넣으면 편집 중인 내용이 초기화되므로 최초만 생성
  IF go_pgman_editor IS INITIAL.
    PERFORM pgman_create_controls.
    IF gv_pgman_error IS NOT INITIAL.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
ENDMODULE.
