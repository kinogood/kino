FUNCTION-POOL zgtpp13.                      "MESSAGE-ID ..

* INCLUDE LZGTPP13D...                       " Local class definition


*----------------------------------------------------------------------*
*       프로그램 HELP 등록 2026.09.14 by 김재석
*----------------------------------------------------------------------*
TYPES: ty_pgman_line TYPE c LENGTH 132,
       ty_pgman_text TYPE STANDARD TABLE OF ty_pgman_line
                     WITH DEFAULT KEY.
CONSTANTS gc_pgman_percent TYPE i VALUE 85. "화면비율 계산

DATA: go_pgman_container TYPE REF TO cl_gui_custom_container,
      go_pgman_editor    TYPE REF TO cl_gui_textedit,
      gt_pgman_text      TYPE ty_pgman_text,
      gt_pgman_result    TYPE ty_pgman_text,
      gv_pgman_display   TYPE xfeld,
      gv_pgman_accept    TYPE xfeld,
      gv_pgman_ok        TYPE syucomm,
      gv_pgman_title     LIKE sy-title,
      gv_pgman_error     TYPE string.
