*&---------------------------------------------------------------------*
*& Include          ZGTLER1130C01
*&---------------------------------------------------------------------*

CLASS LCL_EVENT_RECEIVER  DEFINITION DEFERRED.

*----------------------------------------------------------------------*
* DOCK DATA DECLARATION
*----------------------------------------------------------------------*
DATA: SPLITTER          TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
      CONTAINER_SPLITER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      CONTAINER_1       TYPE REF TO CL_GUI_CONTAINER.

* Docking Container
DATA: DOCKING TYPE REF TO CL_GUI_DOCKING_CONTAINER.

*----------------------------------------------------------------------*
* ALV DATA DECLARATION
*----------------------------------------------------------------------*
* ALV GRID
DATA: GRID1 TYPE REF TO CL_GUI_ALV_GRID,
      GRID2 TYPE REF TO CL_GUI_ALV_GRID.




* ALV FIELD CATALOGUE
DATA: GT_LVC1 TYPE LVC_T_FCAT WITH HEADER LINE,
      GS_LVC1 TYPE LVC_S_FCAT,
*      GT_LVC2 TYPE LVC_T_FCAT WITH HEADER LINE,
      GT_LVC2 TYPE LVC_T_FCAT,
      GS_LVC2 TYPE LVC_S_FCAT.
*      GT_LVC3 TYPE LVC_T_FCAT,
*      GS_LVC3 TYPE LVC_S_FCAT.


* TOOL BAR
DATA: GT_TBAR_EXCLUDING1 TYPE UI_FUNCTIONS,
      GT_TBAR_EXCLUDING2 TYPE UI_FUNCTIONS.
*      GT_TBAR_EXCLUDING3 TYPE UI_FUNCTIONS.

* SORT
DATA: GT_SORT TYPE LVC_T_SORT WITH HEADER LINE.
* LAYOUT
DATA: GS_LAYOUT  TYPE LVC_S_LAYO,
      GS_LAYOUT2 TYPE  LVC_S_LAYO.
*      GS_LAYOUT3 TYPE  LVC_S_LAYO.
* EVENT
DATA: EVENT_RECEIVER TYPE REF TO LCL_EVENT_RECEIVER.

DATA: ALV_VARIANT    LIKE DISVARIANT.
DATA: L_SCROLL TYPE LVC_S_STBL.

*----------------------------------------------------------------------*
* CLASS Definition
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER DEFINITION.
  PUBLIC SECTION.

    METHODS:
      HANDLE_TOOLBAR
        FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
        IMPORTING E_OBJECT E_INTERACTIVE,

      HANDLE_TOOLBAR1
        FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
        IMPORTING E_OBJECT E_INTERACTIVE,

      HANDLE_DATA_CHANGED
        FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
        IMPORTING ER_DATA_CHANGED,

      HANDLE_DATA_CHANGED_FINISHED
        FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
        IMPORTING E_MODIFIED ET_GOOD_CELLS,

      HANDLE_USER_COMMAND
        FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
        IMPORTING E_UCOMM,

      HANDLE_HOTSPOT_CLICK
        FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW_ID E_COLUMN_ID ES_ROW_NO,

      HANDLE_DOUBLE_CLICK
        FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW E_COLUMN.

ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION

*---------------------------------------------------------------------*
*********> CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.
*---------------------------------------------------------------------*
*/ DEFINE TOOBAR
*---------------------------------------------------------------------*
  METHOD HANDLE_TOOLBAR.


*    CHECK SY-TCODE = 'ZLE0101T' OR
*          SY-TCODE =  'ZLE0101M'.  "T-CODE추가 20210122
    DATA: LS_TOOLBAR  TYPE STB_BUTTON.

*-기능개선 323991_S
*  IF GF_REQUEST IS NOT INITIAL.
    CLEAR LS_TOOLBAR.
    MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
    APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

    CLEAR LS_TOOLBAR.
    MOVE 'SEL_ALL'         TO LS_TOOLBAR-FUNCTION.
    MOVE '전체선택'        TO LS_TOOLBAR-QUICKINFO.
    MOVE ICON_SELECT_ALL   TO LS_TOOLBAR-ICON.
    MOVE ' '               TO LS_TOOLBAR-DISABLED.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    CLEAR LS_TOOLBAR.
    MOVE 'DESEL_ALL'         TO LS_TOOLBAR-FUNCTION.
    MOVE '전체선택해제'        TO LS_TOOLBAR-QUICKINFO.
    MOVE ICON_DESELECT_ALL   TO LS_TOOLBAR-ICON.
    MOVE ' '               TO LS_TOOLBAR-DISABLED.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
*  ENDIF.
*-기능개선 323991_E

    IF R01 = 'X'.
* 당사배차
      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'SHIP1'           TO LS_TOOLBAR-FUNCTION.
      MOVE '당사배차'(111)   TO LS_TOOLBAR-QUICKINFO.
      MOVE '당사배차'(112)   TO LS_TOOLBAR-TEXT.
      MOVE ICON_WS_TRUCK   TO LS_TOOLBAR-ICON.
      MOVE ' '               TO LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

* 운송사배차
*      CLEAR LS_TOOLBAR.
*      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
*      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.
*
*      CLEAR LS_TOOLBAR.
*      MOVE 'SHIP2'           TO LS_TOOLBAR-FUNCTION.
*      MOVE '운송사배차'(113) TO LS_TOOLBAR-QUICKINFO.
*      MOVE '운송사배차'(114) TO LS_TOOLBAR-TEXT.
*      MOVE ' '               TO LS_TOOLBAR-DISABLED.
*      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
    ENDIF.
* 오더트랙킹
*    CLEAR LS_TOOLBAR.
*    MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
*    APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.
*
*    CLEAR LS_TOOLBAR.
*    MOVE 'DTL1'           TO LS_TOOLBAR-FUNCTION.
*    MOVE '생산정보조회'(115)   TO LS_TOOLBAR-QUICKINFO.
*    MOVE '생산정보조회'(116)   TO LS_TOOLBAR-TEXT.
*    MOVE ' '               TO LS_TOOLBAR-DISABLED.
*    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    IF R02 = 'X'.
* 요청취소
      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'BCAN'           TO LS_TOOLBAR-FUNCTION.
      MOVE '요청취소'(117)   TO LS_TOOLBAR-QUICKINFO.
      MOVE '요청취소'(118)   TO LS_TOOLBAR-TEXT.
      MOVE ICON_DELETE   TO LS_TOOLBAR-ICON.
      MOVE ' '               TO LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

* 요청수정
      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.
      CLEAR LS_TOOLBAR.
      MOVE 'BMOD'           TO LS_TOOLBAR-FUNCTION.
      MOVE '요청수정'(119)   TO LS_TOOLBAR-QUICKINFO.
      MOVE '요청수정'(120)   TO LS_TOOLBAR-TEXT.
      MOVE ICON_CHANGE   TO LS_TOOLBAR-ICON.
      MOVE ' '               TO LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
    ENDIF.


    IF R03 = 'X'. "당사배차추가
      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'SHIP1'           TO LS_TOOLBAR-FUNCTION.
      MOVE '당사배차'(111)   TO LS_TOOLBAR-QUICKINFO.
      MOVE '당사배차'(112)   TO LS_TOOLBAR-TEXT.
      MOVE ICON_WS_TRUCK   TO LS_TOOLBAR-ICON.
      MOVE ' '               TO LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.


* 운송사배차
*      CLEAR LS_TOOLBAR.
*      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
*      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.
*
*      CLEAR LS_TOOLBAR.
*      MOVE 'SHIP2'           TO LS_TOOLBAR-FUNCTION.
*      MOVE '운송사배차'(113) TO LS_TOOLBAR-QUICKINFO.
*      MOVE '운송사배차'(114) TO LS_TOOLBAR-TEXT.
*      MOVE ' '               TO LS_TOOLBAR-DISABLED.
*      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

* 요청취소
      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'BCAN'           TO LS_TOOLBAR-FUNCTION.
      MOVE '요청취소'(117)   TO LS_TOOLBAR-QUICKINFO.
      MOVE '요청취소'(118)   TO LS_TOOLBAR-TEXT.
      MOVE ICON_DELETE   TO LS_TOOLBAR-ICON.
      MOVE ' '               TO LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

* 요청수정
      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.
      CLEAR LS_TOOLBAR.
      MOVE 'BMOD'           TO LS_TOOLBAR-FUNCTION.
      MOVE '요청수정'(119)   TO LS_TOOLBAR-QUICKINFO.
      MOVE '요청수정'(120)   TO LS_TOOLBAR-TEXT.
      MOVE ICON_CHANGE   TO LS_TOOLBAR-ICON.
      MOVE ' '               TO LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
    ENDIF.

*   복수배차
    IF R10 = 'X'.
* 당사배차
      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'SHIP1'           TO LS_TOOLBAR-FUNCTION.
      MOVE '당사배차'(111)   TO LS_TOOLBAR-QUICKINFO.
      MOVE '당사배차'(112)   TO LS_TOOLBAR-TEXT.
      MOVE ICON_WS_TRUCK   TO LS_TOOLBAR-ICON.
      MOVE ' '               TO LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

* 운송사배차
*      CLEAR LS_TOOLBAR.
*      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
*      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.
*
*      CLEAR LS_TOOLBAR.
*      MOVE 'SHIP2'           TO LS_TOOLBAR-FUNCTION.
*      MOVE '운송사배차'(113) TO LS_TOOLBAR-QUICKINFO.
*      MOVE '운송사배차'(114) TO LS_TOOLBAR-TEXT.
*      MOVE ' '               TO LS_TOOLBAR-DISABLED.
*      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
    ENDIF.


* 배차수정
    IF GF_REQUEST IS NOT INITIAL.
      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.
      CLEAR LS_TOOLBAR.
      MOVE 'RMOD'           TO LS_TOOLBAR-FUNCTION.
      MOVE '배차정보수정'(121)   TO LS_TOOLBAR-QUICKINFO.
      MOVE '배차정보수정'(122)   TO LS_TOOLBAR-TEXT.
      MOVE ICON_CHANGE_NUMBER   TO LS_TOOLBAR-ICON.
*      "[가온]-S
*      MOVE 'X'               TO LS_TOOLBAR-DISABLED.
      MOVE ' '               TO LS_TOOLBAR-DISABLED.
*      "[가온]-E
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
    ENDIF.

  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD HANDLE_TOOLBAR1.

*    CHECK SY-TCODE = 'ZLE0101T'.
    DATA: LS_TOOLBAR  TYPE STB_BUTTON.

* 배치재고 현황연결
    CLEAR LS_TOOLBAR.
    MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
    APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

    CLEAR LS_TOOLBAR.
    MOVE 'JEGO'           TO LS_TOOLBAR-FUNCTION.
    MOVE '입고현황'(117) TO LS_TOOLBAR-QUICKINFO.
    MOVE '입고현황'(118) TO LS_TOOLBAR-TEXT.
    MOVE ICON_STOCK   TO LS_TOOLBAR-ICON.
    MOVE ' '               TO LS_TOOLBAR-DISABLED.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    CLEAR LS_TOOLBAR.
    MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
    APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

*   전체선택
    CLEAR LS_TOOLBAR.
    MOVE 'ZSELA'           TO LS_TOOLBAR-FUNCTION.
    MOVE ICON_SELECT_ALL   TO LS_TOOLBAR-ICON.
    MOVE ' '               TO LS_TOOLBAR-DISABLED.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.


*   전체해제
    CLEAR LS_TOOLBAR.
    MOVE 'ZDSEL'           TO LS_TOOLBAR-FUNCTION.
    MOVE ICON_DESELECT_ALL   TO LS_TOOLBAR-ICON.
    MOVE ' '               TO LS_TOOLBAR-DISABLED.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    CLEAR LS_TOOLBAR.
    MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
    APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

*   납품분할
    CLEAR LS_TOOLBAR.
    MOVE 'ZVLSP'           TO LS_TOOLBAR-FUNCTION.
    MOVE TEXT-111 TO LS_TOOLBAR-QUICKINFO.
    MOVE TEXT-111 TO LS_TOOLBAR-TEXT.
    MOVE ICON_DETAIL       TO LS_TOOLBAR-ICON.
    MOVE ' '               TO LS_TOOLBAR-DISABLED.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

  ENDMETHOD.                    "HANDLE_TOOLBAR

*---------------------------------------------------------------------*
*/ HANDLE DATA CHANGED FINISHED
*---------------------------------------------------------------------*
* 헤더별 선택 제어
  METHOD  HANDLE_DATA_CHANGED_FINISHED.

    DATA : LS_GOOD_CELLS LIKE LINE OF ET_GOOD_CELLS.

    CLEAR: GV_INDEX.
    CLEAR: GT_ALV1-ALV_COL[], GT_ALV2-ALV_COL[].
    READ TABLE ET_GOOD_CELLS INTO LS_GOOD_CELLS INDEX 1.
    GV_INDEX = LS_GOOD_CELLS-ROW_ID.

    IF LS_GOOD_CELLS-FIELDNAME = 'SEL1'.
*/ GET GRID2
      PERFORM GET_GRID2 TABLES GT_ALV1 GT_ALV2.

      PERFORM SET_CELL_ATTRIBUTE_GRID2 TABLES GT_ALV2.

      PERFORM SET_CELL_ATTRIBUTE_GRID1 TABLES GT_ALV1.

*      PERFORM change_data_from_inside_grid1.

      L_SCROLL-ROW = 'X'.
      L_SCROLL-COL = 'X'.

      CALL METHOD GRID2->REFRESH_TABLE_DISPLAY
        EXPORTING
*         I_SOFT_REFRESH = 'X'          "
          IS_STABLE = L_SCROLL.     "현재 그대로 입력한 refresh

      CALL METHOD GRID1->REFRESH_TABLE_DISPLAY
        EXPORTING
          I_SOFT_REFRESH = 'X'
          IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

      CALL METHOD CL_GUI_CFW=>FLUSH.

    ELSEIF LS_GOOD_CELLS-FIELDNAME = 'SEL2'.
*      PERFORM CONTROL_GRID2 TABLES GT_ALV2.

      CALL METHOD GRID2->REFRESH_TABLE_DISPLAY
        EXPORTING
          I_SOFT_REFRESH = 'X'
          IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

      CALL METHOD GRID1->REFRESH_TABLE_DISPLAY
        EXPORTING
          I_SOFT_REFRESH = 'X'
          IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

    ENDIF.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED
*---------------------------------------------------------------------*
* USER COMMAND
*---------------------------------------------------------------------*
  METHOD HANDLE_USER_COMMAND.

    CASE E_UCOMM.
      WHEN 'SHIP1'.        "당사배차
        PERFORM SHIP1.

      WHEN 'SHIP2'.        "운송사배차
        PERFORM CHECK_PATNER_CRT_VBAP.

        PERFORM SEA_SHIP_CHECK.

        PERFORM SHIP2.
      WHEN 'DTL1'.         "생산정보조회(오더 tracking)
        PERFORM DETAIL1.
      WHEN 'JEGO'.
*        PERFORM JEGO1.
        PERFORM GET_STOCK_9000.

      WHEN 'BCAN'.         "요청취소
        PERFORM BCANCEL.
      WHEN 'BMOD'.         "요청수정
        PERFORM BMODIFY.

      WHEN 'SEL_ALL'.
        PERFORM SELECT_ALL .
      WHEN 'DESEL_ALL'.
        PERFORM DESELECT_ALL .

      WHEN 'RMOD'.    "배차정보수정 추가 20210127
        PERFORM RMODIFY.

      WHEN 'ZSELA'.
        PERFORM SELECT_ALL_BOT.
      WHEN 'ZDSEL'.
        PERFORM DESELECT_ALL_BOT.

      WHEN 'ZVLSP'. "납품분할
        PERFORM RUN_VLSP.

    ENDCASE.

  ENDMETHOD.                           "handle_user_command

*---------------------------------------------------------------------*
* data_changed
*---------------------------------------------------------------------*
  METHOD HANDLE_DATA_CHANGED.
    PERFORM HANDLE_DATA_CHANGED USING ER_DATA_CHANGED.
  ENDMETHOD.                    "handle_data_changed

*---------------------------------------------------------------------*
* DOUBLE CLICK
*---------------------------------------------------------------------*
  METHOD HANDLE_DOUBLE_CLICK.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
*---------------------------------------------------------------------*
* HOTSPOR CLICK
*---------------------------------------------------------------------*
  METHOD HANDLE_HOTSPOT_CLICK.

    IF E_COLUMN_ID-FIELDNAME = 'VBELN'.
      GV_INDEX = E_ROW_ID.
      PERFORM CALL_TRANSACTION_VL03N.
    ENDIF.

    IF E_COLUMN_ID-FIELDNAME = 'VGBEL'.
      GV_INDEX = E_ROW_ID.
      PERFORM CALL_TRANSACTION_VA03.
    ENDIF.

    IF E_COLUMN_ID-FIELDNAME = 'TKNUM_SEA'.
      GV_INDEX = E_ROW_ID.
      PERFORM CALL_TRANSACTION_VT03N.
    ENDIF.



  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION


**------------------------------------------------------
** ALV 관련
**------------------------------------------------------

*- 배차요청(주문,비주문), 주문매핑관련
CLASS LCL_EVENT_RECEIVER3  DEFINITION DEFERRED.

DATA : GRID3              TYPE REF TO CL_GUI_ALV_GRID,
       CONTAINER_SUB3     TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GT_LVC3            TYPE LVC_T_FCAT WITH HEADER LINE,
       GS_LVC3            TYPE LVC_S_FCAT,
       GS_LAYOUT3         TYPE LVC_S_LAYO,
       GT_TBAR_EXCLUDING3 TYPE UI_FUNCTIONS,
       ALV_VARIANT3       LIKE DISVARIANT,
       EVENT_RECEIVER3    TYPE REF TO LCL_EVENT_RECEIVER3.


*- 비주문 통문매핑관련
DATA : GRID4              TYPE REF TO CL_GUI_ALV_GRID,
       CONTAINER_SUB4     TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GT_LVC4            TYPE LVC_T_FCAT WITH HEADER LINE,
       GS_LVC4            TYPE LVC_S_FCAT,
       GS_LAYOUT4         TYPE LVC_S_LAYO,
       GT_TBAR_EXCLUDING4 TYPE UI_FUNCTIONS,
       ALV_VARIANT4       LIKE DISVARIANT,
       GT_FIELD           TYPE SLIS_T_FIELDCAT_ALV.


DATA : GRID9              TYPE REF TO CL_GUI_ALV_GRID,
       CONTAINER_SUB9     TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GT_LVC9            TYPE LVC_T_FCAT WITH HEADER LINE,
       GS_LVC9            TYPE LVC_S_FCAT,
       GS_LAYOUT9         TYPE LVC_S_LAYO,
       GT_TBAR_EXCLUDING9 TYPE UI_FUNCTIONS,
       ALV_VARIANT9       LIKE DISVARIANT,
       GV_ITAB            LIKE LVC_S_FCAT-TABNAME,
       GV_POS             LIKE LVC_S_FCAT-COL_POS,
       GT_SORT9           TYPE LVC_T_SORT WITH HEADER LINE,
       GS_SORT            TYPE LVC_S_SORT.



*----------------------------------------------------------------------*
* CLASS Definition
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER3 DEFINITION.
  PUBLIC SECTION.

    METHODS:
      HANDLE_TOOLBAR
        FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
        IMPORTING E_OBJECT E_INTERACTIVE,

      HANDLE_USER_COMMAND
        FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
        IMPORTING E_UCOMM,

      HANDLE_DOUBLE_CLICK
        FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW E_COLUMN,

      HANDLE_DATA_CHANGED_FINISHED
        FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
        IMPORTING E_MODIFIED ET_GOOD_CELLS.

ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION


*---------------------------------------------------------------------*
*********> CLASS LCL_EVENT_RECEIVER3 IMPLEMENTATION
*---------------------------------------------------------------------*

CLASS LCL_EVENT_RECEIVER3 IMPLEMENTATION.


*---------------------------------------------------------------------*
* DOUBLE CLICK
*---------------------------------------------------------------------*
  METHOD HANDLE_DOUBLE_CLICK.
    PERFORM DOUBLE_CLICK  USING E_ROW E_COLUMN.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK


*---------------------------------------------------------------------*
*/ DEFINE TOOBAR
*---------------------------------------------------------------------*
  METHOD HANDLE_TOOLBAR.

    DATA: LS_TOOLBAR  TYPE STB_BUTTON.

    CHECK GF_MAPPING IS INITIAL.

    IF GF_NREQUEST IS INITIAL. "주문배차만 가능
* 합짐/분할 배차 관련
      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'MIX'            TO LS_TOOLBAR-FUNCTION.
      MOVE ICON_DIFFERENCE      TO LS_TOOLBAR-ICON.
      MOVE '합짐처리'           TO LS_TOOLBAR-QUICKINFO.
      MOVE '합짐처리'           TO LS_TOOLBAR-TEXT.
      MOVE ' '              TO LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'MIX_CNC'            TO LS_TOOLBAR-FUNCTION.
      MOVE '합짐취소'           TO LS_TOOLBAR-QUICKINFO.
      MOVE '합짐취소 '          TO LS_TOOLBAR-TEXT.
      MOVE ' '              TO LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'DIV'           TO LS_TOOLBAR-FUNCTION.
      MOVE ICON_DIFFERENCE_BACK      TO LS_TOOLBAR-ICON.
      MOVE '분할처리'        TO LS_TOOLBAR-QUICKINFO.
      MOVE '분할처리'        TO LS_TOOLBAR-TEXT.
      MOVE ' '               TO LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.


      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'DIV_CNC'           TO LS_TOOLBAR-FUNCTION.
      MOVE '분할취소'        TO LS_TOOLBAR-QUICKINFO.
      MOVE '분할취소'        TO LS_TOOLBAR-TEXT.
      MOVE ' '               TO LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
    ENDIF.

    CLEAR LS_TOOLBAR.
    MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
    APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

    CLEAR LS_TOOLBAR.
    MOVE 'ZLADD'           TO LS_TOOLBAR-FUNCTION.
    MOVE '라인추가'        TO LS_TOOLBAR-QUICKINFO.
    MOVE '라인추가'        TO LS_TOOLBAR-TEXT.
    MOVE ' '               TO LS_TOOLBAR-DISABLED.
    MOVE ICON_INSERT_ROW   TO LS_TOOLBAR-ICON.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    CLEAR LS_TOOLBAR.

    CLEAR LS_TOOLBAR.
    MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
    APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

    CLEAR LS_TOOLBAR.
    MOVE 'ZLDEL'           TO LS_TOOLBAR-FUNCTION.
    MOVE '라인삭제'        TO LS_TOOLBAR-QUICKINFO.
    MOVE '라인삭제'        TO LS_TOOLBAR-TEXT.
    MOVE ' '               TO LS_TOOLBAR-DISABLED.
    MOVE ICON_DELETE_ROW   TO LS_TOOLBAR-ICON.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    CLEAR LS_TOOLBAR.

    IF GF_NREQUEST IS NOT INITIAL.
      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'ZROUTE'          TO LS_TOOLBAR-FUNCTION.
      MOVE '운송경로'        TO LS_TOOLBAR-QUICKINFO.
      MOVE '운송경로'        TO LS_TOOLBAR-TEXT.
      MOVE ' '               TO LS_TOOLBAR-DISABLED.
      MOVE ICON_TRANSPORTATION_MODE  TO LS_TOOLBAR-ICON.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.


      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'ZGATE_MAP'          TO LS_TOOLBAR-FUNCTION.
      MOVE '통문매핑'        TO LS_TOOLBAR-QUICKINFO.
      MOVE '통문매핑'        TO LS_TOOLBAR-TEXT.
      MOVE ' '               TO LS_TOOLBAR-DISABLED.
      MOVE ICON_IMPORT_ALL_REQUESTS  TO LS_TOOLBAR-ICON.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 3                 TO LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR      TO E_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'ZROUTE_SPOT'     TO LS_TOOLBAR-FUNCTION.
      MOVE '일회성경로'      TO LS_TOOLBAR-QUICKINFO.
      MOVE '일회성경로'      TO LS_TOOLBAR-TEXT.
      MOVE ' '               TO LS_TOOLBAR-DISABLED.
      MOVE ICON_TRANSPORT_PROPOSAL  TO LS_TOOLBAR-ICON.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    ENDIF.



  ENDMETHOD.                    "HANDLE_TOOLBAR


*---------------------------------------------------------------------*
* USER COMMAND
*---------------------------------------------------------------------*
  METHOD HANDLE_USER_COMMAND.

    CASE E_UCOMM.
      WHEN 'MIX'. "합짐
        PERFORM SET_DISPATCH_MIX.
      WHEN 'DIV'. "분할
        PERFORM SET_DISPATCH_DIV.
      WHEN 'MIX_CNC'. "합짐취소
        PERFORM SET_DISPATCH_MIX_CANC.
      WHEN 'DIV_CNC'. "분할취소
        PERFORM SET_DISPATCH_DIV_CANC.

*--[기능개선 290903  추가
      WHEN 'ZLADD'.  "라인추가
        PERFORM ADD_LINE_ALV3.

      WHEN 'ZLDEL'. "라인삭제
        PERFORM DEL_LINE_ALV3.
*--]기능개선 290903

      WHEN 'ZROUTE'. "운송경로
        PERFORM ROUTE_LINE_ALV3.

      WHEN 'ZROUTE_SPOT'. "일회성경로
        GF_SPOT  = GC_X.
        PERFORM ROUTE_LINE_ALV3.
        CLEAR GF_SPOT.

      WHEN 'ZGATE_MAP'. "통문매핑
        PERFORM ZGATE_MAP_ALV3.
    ENDCASE.

* 강제로 user command를 실행해서 PBO를 한번 더 흐르게 함 --
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        FUNCTIONCODE           = 'ENTER'
      EXCEPTIONS
        FUNCTION_NOT_SUPPORTED = 1
        OTHERS                 = 2.


  ENDMETHOD.                         "handle_user_command

  METHOD  HANDLE_DATA_CHANGED_FINISHED.


*- [기능개선312483] 체크박스 입력시 공통품목 해당라인의 값으로 자동변경
*-  및 공통품목의 체크박스 표시. 취소시 공통품목의 체크박스만 미표시-[s]
    DATA : LS_GOOD_CELLS LIKE LINE OF ET_GOOD_CELLS,
           LS_ALV3       LIKE GT_ALV3.

    READ TABLE ET_GOOD_CELLS INTO LS_GOOD_CELLS INDEX 1.
    GV_INDEX = LS_GOOD_CELLS-ROW_ID.

    IF LS_GOOD_CELLS-FIELDNAME = 'POSNR_CHK'.
      READ TABLE GT_ALV3 INTO LS_ALV3  INDEX GV_INDEX.
*      CHECK LS_ALV3-POSNR_CHK IS NOT INITIAL.
      LOOP AT GT_ALV3 INTO GT_ALV3  WHERE VBELN EQ LS_ALV3-VBELN.

        IF LS_ALV3-POSNR_CHK IS NOT INITIAL.
          GT_ALV3-WADAT     = LS_ALV3-WADAT.
          GT_ALV3-WAUHR     = LS_ALV3-WAUHR.
          GT_ALV3-DAY_CHK   = LS_ALV3-DAY_CHK.
          GT_ALV3-TRK_TON   = LS_ALV3-TRK_TON.
          GT_ALV3-TRK_TON_T = LS_ALV3-TRK_TON_T.
          GT_ALV3-KUNNR_T   = LS_ALV3-KUNNR_T.
          GT_ALV3-ORT01     = LS_ALV3-ORT01.
          GT_ALV3-POSNR_CHK = LS_ALV3-POSNR_CHK .

          GT_ALV3-ZROUTE      = LS_ALV3-ZROUTE       .
          GT_ALV3-ZDEPARTURE  = LS_ALV3-ZDEPARTURE   .
          GT_ALV3-ZDEPARTURET = LS_ALV3-ZDEPARTURET  .
          GT_ALV3-ZARRIVAL    = LS_ALV3-ZARRIVAL     .
          GT_ALV3-ZARRIVALT   = LS_ALV3-ZARRIVALT    .
          GT_ALV3-PRICE       = LS_ALV3-PRICE        .
          GT_ALV3-WAERS       = LS_ALV3-WAERS        .


          MODIFY GT_ALV3 FROM GT_ALV3 TRANSPORTING
                                 WADAT WAUHR DAY_CHK TRK_TON TRK_TON_T
                                 ORT01 KUNNR_T POSNR_CHK
                                 ZROUTE ZDEPARTURE ZDEPARTURET
                                 ZARRIVAL ZARRIVALT PRICE WAERS      .
        ELSE.
          GT_ALV3-POSNR_CHK = LS_ALV3-POSNR_CHK .
          MODIFY GT_ALV3 FROM GT_ALV3 TRANSPORTING POSNR_CHK .
        ENDIF.

      ENDLOOP.


      L_SCROLL-ROW = 'X'.
      L_SCROLL-COL = 'X'.

      CALL METHOD GRID3->REFRESH_TABLE_DISPLAY
        EXPORTING
          I_SOFT_REFRESH = 'X'
          IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh
    ENDIF.

*- [기능개선312483] 체크박스 입력시 공통품목 해당라인의 값으로 자동변경
*-  및 공통품목의 체크박스 표시. 취소시 공통품목의 체크박스만 미표시-[e]

  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

ENDCLASS.                    "LCL_EVENT_RECEIVER3 IMPLEMENTATION
