*&---------------------------------------------------------------------*
*& Include          ZGTLER1160C01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS lcl_application DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER DEFINITION.

  PUBLIC SECTION.
    DATA: L_NEXT_NODE_KEY TYPE I.

    CLASS-METHODS:
      HANDLE_TOP_OF_PAGE
        FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
        IMPORTING E_DYNDOC_ID ,

      HANDLE_TOOLBAR
        FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
        IMPORTING E_OBJECT E_INTERACTIVE,

      HANDLE_USER_COMMAND
        FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
        IMPORTING E_UCOMM,

      HANDLE_DATA_CHANGED
        FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
        IMPORTING ER_DATA_CHANGED,

      HANDLE_DATA_CHANGED_FINISHED
        FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
        IMPORTING E_MODIFIED
                  ET_GOOD_CELLS,


      HANDLE_HOTSPOT_CLICK
        FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
        IMPORTING E_ROW_ID
                  E_COLUMN_ID,

      HANDLE_ONF4
        FOR EVENT ONF4 OF CL_GUI_ALV_GRID
        IMPORTING E_FIELDNAME
                  E_FIELDVALUE
                  ES_ROW_NO
                  ER_EVENT_DATA
                  ET_BAD_CELLS
                  E_DISPLAY.


ENDCLASS.                    "lcl_application DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_application IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.
  METHOD HANDLE_TOP_OF_PAGE.
*    PERFORM HANDLE_TOP_OF_PAGE USING E_DYNDOC_ID .
  ENDMETHOD.                    "HANDLE_DATA_CHANGED

  METHOD HANDLE_TOOLBAR.
    PERFORM HANDLE_TOOLBAR USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED

  METHOD HANDLE_USER_COMMAND.
    PERFORM HANDLE_USER_COMMAND USING E_UCOMM.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED


  METHOD HANDLE_DATA_CHANGED.
    PERFORM HANDLE_DATA_CHANGED USING ER_DATA_CHANGED.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED

  METHOD HANDLE_DATA_CHANGED_FINISHED.
    PERFORM HANDLE_DATA_CHANGED_FINISHED USING E_MODIFIED ET_GOOD_CELLS.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HANDLE_HOTSPOT_CLICK USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD HANDLE_ONF4.
    PERFORM HANDLE_ONF4 USING E_FIELDNAME
                              E_FIELDVALUE
                              ES_ROW_NO
                              ER_EVENT_DATA
                              ET_BAD_CELLS
                              E_DISPLAY.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK


ENDCLASS.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED_FINISHED  USING    P_MODI
                                            PT_CELLS TYPE LVC_T_MODI.

*  CHECK P_MODI IS NOT INITIAL.
*  "변경 사항이 존재하는건에 대해선 한번더 확인
*  GRID->CHECK_CHANGED_DATA( ).

*  LOOP AT PT_CELLS INTO DATA(LS_CELL).
*    READ TABLE GT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>) INDEX LS_CELL-ROW_ID.
*    IF SY-SUBRC IS INITIAL.
*      <FS_DATA>-BUKRS = P_BUKRS.
*      <FS_DATA>-SDATE = <FS_DATA>-LSDATE.
*      <FS_DATA>-UPCODE = '999'.
*
*      IF <FS_DATA>-STAT IS INITIAL.
*        <FS_DATA>-STAT = 'C'.
*        <FS_DATA>-POST   = ABAP_TRUE.
**        <FS_DATA>-ICON   = '@0Y@' . "ICON_CREATE
*      ENDIF.
*    ENDIF.
*  ENDLOOP.


*  DATA: LS_STABLE TYPE LVC_S_STBL VALUE 'XX'.
*  GRID->REFRESH_TABLE_DISPLAY( IS_STABLE = LS_STABLE ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED  USING    PR_DATA_CHANGED
                                 TYPE REF TO  CL_ALV_CHANGED_DATA_PROTOCOL.

  DEFINE _GET_CELL_VALUE.
    PR_DATA_CHANGED->GET_CELL_VALUE(
      EXPORTING I_ROW_ID    = LS_CELL-ROW_ID
                I_FIELDNAME = &1
      IMPORTING E_VALUE     = &2 ).
  END-OF-DEFINITION.

  DEFINE _SET_CELL_VALUE.
    PR_DATA_CHANGED->MODIFY_CELL(
      EXPORTING I_ROW_ID    = LS_CELL-ROW_ID
                I_FIELDNAME = &1
                I_VALUE     = &2 ).
  END-OF-DEFINITION.

  DATA LT_CELLCOL TYPE LVC_T_SCOL.

*  LOOP AT PR_DATA_CHANGED->MT_MOD_CELLS INTO DATA(LS_CELL).
*    CHECK LS_CELL-VALUE IS NOT INITIAL.
*    CASE LS_CELL-FIELDNAME.
*      WHEN 'BCODE'. "은행코드
**        CHECK LS_CELL-VALUE IS NOT INITIAL.
*        "은행코드 확인
*        SELECT SINGLE FROM ZTRTF00 FIELDS @ABAP_TRUE
*          WHERE BCODE EQ @LS_CELL-VALUE
*          INTO @DATA(L_BCODE).
*        IF  SY-SUBRC IS NOT INITIAL.
*          _SET_CELL_VALUE LS_CELL-FIELDNAME    ''.
**          _SET_CELL_VALUE 'ICON'    ICON_LED_RED.
*          PERFORM EDIT_CONTROL_COL USING LS_CELL-FIELDNAME 'E' CHANGING LT_CELLCOL.
*          _SET_CELL_VALUE 'CELLCOL'  LT_CELLCOL.
*          MESSAGE S000 DISPLAY LIKE 'E' WITH '은행코드 없음'.
*          CLEAR L_BCODE.
*        ELSE.
*          _GET_CELL_VALUE 'CELLCOL' LT_CELLCOL.
*          IF LT_CELLCOL[] IS NOT INITIAL.
*            PERFORM EDIT_CONTROL_COL USING LS_CELL-FIELDNAME 'D' CHANGING LT_CELLCOL.
*            _SET_CELL_VALUE 'CELLCOL'  LT_CELLCOL.
*          ENDIF.
*        ENDIF.
*
*        CLEAR L_BCODE.
*
*        "수신자 ID  - 은행코드 존재건은 수신자 ID 정보를 찾는다
*
*        SELECT SINGLE FROM ZTRTF01 FIELDS RECVID
*          WHERE BUKRS EQ @P_BUKRS
*            AND BCODE EQ @LS_CELL-VALUE
*          INTO @DATA(L_RECVID).
*
*        _SET_CELL_VALUE 'RECVID'    L_RECVID.
*        CLEAR L_RECVID.
*
*      WHEN 'ACCNO'.  "계좌번호
*
*        SELECT SINGLE FROM T012K FIELDS HBKID, HKTID, HKONT, WAERS
*          WHERE BUKRS EQ @P_BUKRS
*            AND BANKN EQ @LS_CELL-VALUE
*            AND WAERS EQ 'KRW'
*          INTO @DATA(LS_T012K).
*        IF SY-SUBRC IS INITIAL.
*          _SET_CELL_VALUE 'HBKID'    LS_T012K-HBKID.
*          _SET_CELL_VALUE 'HKTID'    LS_T012K-HKTID.
*          _SET_CELL_VALUE 'HKONT'    LS_T012K-HKONT.
**          _SET_CELL_VALUE 'WAERS'    LS_T012K-WAERS.
*
*          _GET_CELL_VALUE 'CELLCOL' LT_CELLCOL.
*          IF LT_CELLCOL[] IS NOT INITIAL.
*            PERFORM EDIT_CONTROL_COL USING LS_CELL-FIELDNAME 'D' CHANGING LT_CELLCOL.
*            _SET_CELL_VALUE 'CELLCOL'  LT_CELLCOL.
*          ENDIF.
*        ELSE.
*          MESSAGE S000 DISPLAY LIKE 'E' WITH '계좌번호 오류 '.
*          _SET_CELL_VALUE LS_CELL-FIELDNAME    ''.
*          PERFORM EDIT_CONTROL_COL USING LS_CELL-FIELDNAME 'E' CHANGING LT_CELLCOL.
*          _SET_CELL_VALUE 'CELLCOL'  LT_CELLCOL.
**          _SET_CELL_VALUE 'ICON'    ICON_LED_RED.
*        ENDIF.
*        CLEAR LS_T012K.
*
*      WHEN 'TGUBUN'. "거래구분
*        _GET_CELL_VALUE 'BCODE' L_BCODE.
*        IF L_BCODE IS INITIAL.
*          MESSAGE S000 DISPLAY LIKE 'E' WITH '은행코드먼저 입력하여 주십시요. '.
*          PERFORM EDIT_CONTROL_COL USING LS_CELL-FIELDNAME 'E' CHANGING LT_CELLCOL.
*          _SET_CELL_VALUE 'CELLCOL'  LT_CELLCOL.
*        ELSE.
*          _GET_CELL_VALUE 'CELLCOL' LT_CELLCOL.
*          IF LT_CELLCOL[] IS NOT INITIAL.
*            PERFORM EDIT_CONTROL_COL USING LS_CELL-FIELDNAME 'D' CHANGING LT_CELLCOL.
*            _SET_CELL_VALUE 'CELLCOL'  LT_CELLCOL.
*          ENDIF.
*        ENDIF.
*        SELECT SINGLE FROM ZTRTF02 FIELDS @ABAP_TRUE
*           WHERE TGUBUN EQ @LS_CELL-VALUE
*             AND BCODE  EQ @L_BCODE
*          INTO @DATA(L_TGUBUN).
*        IF SY-SUBRC IS NOT INITIAL.
*          SELECT SINGLE FROM ZTRTF02 FIELDS @ABAP_TRUE
*             WHERE TGUBUN EQ @LS_CELL-VALUE
*               AND BCODE  EQ @SPACE
*            INTO @L_TGUBUN.
*          IF SY-SUBRC IS NOT INITIAL.
*            MESSAGE S000 DISPLAY LIKE 'E' WITH '거래구분 오류 '.
*            _SET_CELL_VALUE LS_CELL-FIELDNAME    ''.
*            PERFORM EDIT_CONTROL_COL USING LS_CELL-FIELDNAME 'E' CHANGING LT_CELLCOL.
*            _SET_CELL_VALUE 'CELLCOL'  LT_CELLCOL.
**          _SET_CELL_VALUE 'ICON'    ICON_LED_RED.
*          ELSE.
*            _GET_CELL_VALUE 'CELLCOL' LT_CELLCOL.
*            IF LT_CELLCOL[] IS NOT INITIAL.
*              PERFORM EDIT_CONTROL_COL USING LS_CELL-FIELDNAME 'D' CHANGING LT_CELLCOL.
*              _SET_CELL_VALUE 'CELLCOL'  LT_CELLCOL.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*    ENDCASE.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_ONF4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_FIELDNAME
*&      --> E_FIELDVALUE
*&      --> ES_ROW_NO
*&      --> ER_EVENT_DATA
*&      --> ET_BAD_CELLS
*&      --> E_DISPLAY
*&---------------------------------------------------------------------*
FORM HANDLE_ONF4  USING    P_FIELDNAME   TYPE LVC_FNAME
                           P_VALUE  TYPE LVC_VALUE
                           PS_ROW_NO     TYPE LVC_S_ROID
                           PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                           PT_BAD_CELLS  TYPE LVC_T_MODI
                           P_DISPLAY.

*  DATA: LT_RETURN TYPE TABLE OF DDSHRETVAL.
*  DATA : LT_TAB          TYPE TABLE OF  DFIES,
*         DYNPFLD_MAPPING TYPE TABLE OF  DSELC.



*  CASE P_FIELDNAME.
*    WHEN 'ACCNO'.
*      TYPES : BEGIN OF LTY_F4,
*                BUKRS LIKE T012K-BUKRS,
*                HBKID LIKE T012K-HBKID,
*                HKTID LIKE T012K-HKTID,
*                ACCNO LIKE T012K-BANKN,
*                HKONT LIKE T012K-HKONT,
*                TEXT1 LIKE T012T-TEXT1,
*                SEQ   LIKE SY-TABIX,
**                WAERS LIKE T012K-WAERS,
*              END OF LTY_F4,
*              LTTY_F4 TYPE TABLE OF LTY_F4.
*      DATA : LT_F4 TYPE LTTY_F4.
*
**      APPEND VALUE #( FIELDNAME = 'SEQ'
***                      PARAMTEXT = '순번'
***                      LENG      = 6
**                      INTTYPE   = 'I' ) TO LT_TAB.
*
*
*      SELECT FROM T012K AS A INNER JOIN T012T AS B
*                                  ON A~BUKRS  EQ B~BUKRS
*                                 AND A~HBKID  EQ B~HBKID
*                                 AND A~HKTID  EQ B~HKTID
*             FIELDS A~BUKRS, A~HBKID, A~HKTID, A~BANKN AS ACCNO, A~HKONT, B~TEXT1 ", A~WAERS
*        WHERE B~SPRAS EQ @SY-LANGU
*          AND A~BUKRS EQ @P_BUKRS
*          AND A~WAERS EQ 'KRW'
*        INTO CORRESPONDING FIELDS OF TABLE @LT_F4.
*
*      LOOP AT LT_F4 ASSIGNING FIELD-SYMBOL(<FS_F4>).
*        <FS_F4>-SEQ = SY-TABIX.
*      ENDLOOP.
*
*      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*        EXPORTING
**         RETFIELD   = CONV FIELDNAME( P_FIELDNAME )
*          RETFIELD   = CONV FIELDNAME( 'SEQ' )
*          VALUE_ORG  = 'S'
*          DISPLAY    = ' '
**         MULTIPLE_CHOICE = 'X'
*        TABLES
*          VALUE_TAB  = LT_F4
*          RETURN_TAB = LT_RETURN
**         FIELD_TAB  = LT_TAB.
**         DYNPFLD_MAPPING = DYNPFLD_MAPPING.
*        .
*
*      " 선택된 값을 ALV Cell에 적용
*      IF LT_RETURN IS NOT INITIAL.
*        READ TABLE LT_RETURN INTO DATA(LS_RET) INDEX 1.
*        READ TABLE LT_F4 INTO DATA(LS_F4) WITH KEY SEQ = LS_RET-FIELDVAL.
*        READ TABLE GT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>) INDEX PS_ROW_NO-ROW_ID.
*        IF <FS_DATA> IS ASSIGNED.
*          <FS_DATA>-ACCNO = LS_F4-ACCNO.
*          <FS_DATA>-HBKID = LS_F4-HBKID.
*          <FS_DATA>-HKONT = LS_F4-HKONT.
*          <FS_DATA>-HKTID = LS_F4-HKTID.
**          <FS_DATA>-WAERS = LS_F4-WAERS.
*        ENDIF.
*      ENDIF.
*
*      GRID->REFRESH_TABLE_DISPLAY( EXPORTING IS_STABLE = VALUE LVC_S_STBL( ROW = 'X'  COL = 'X' ) ).
*  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING    P_ROW_ID TYPE	LVC_S_ROW
                                    P_COLUMN_ID TYPE  LVC_S_COL.

*  CLEAR GS_DATA.
*  READ TABLE GT_DATA INTO GS_DATA INDEX P_ROW_ID-INDEX.
*  CHECK SY-SUBRC IS INITIAL.
*
*  CASE P_COLUMN_ID-FIELDNAME.
*    WHEN 'VBELN'. "판매오더
*      CHECK GS_DATA-VBELN IS NOT INITIAL.
*      SET PARAMETER ID 'AUN' FIELD GS_DATA-VBELN.
*      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
*
*    WHEN 'UPDRQ'. "SM LINK
*      CHECK GS_DATA-UPDRQ IS NOT INITIAL.
**      SUBMIT ZGTPPR3160 WITH
*
*
*    WHEN 'AUFNR'. "오더번호
*      CHECK GS_DATA-AUFNR IS NOT INITIAL.
*      SET PARAMETER ID 'ANR' FIELD GS_DATA-AUFNR.
*      CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
*
*    WHEN 'EBELN'. "구매오더
*      CHECK GS_DATA-EBELN IS NOT INITIAL.
*      SET PARAMETER ID 'BES' FIELD GS_DATA-EBELN.
*      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
*  ENDCASE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR  USING    P_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                              P_INTERACTIVE.

*  DATA: LV_BUTTON             TYPE STB_BUTTON.
*
*  CLEAR LV_BUTTON.
*  LV_BUTTON-BUTN_TYPE  = '3'.
*  INSERT LV_BUTTON INTO P_OBJECT->MT_TOOLBAR INDEX 1.
*
*  CLEAR LV_BUTTON.
*  LV_BUTTON-BUTN_TYPE  = '0'.
*  LV_BUTTON-FUNCTION   = 'DSEL'.
*  LV_BUTTON-ICON       = ICON_DESELECT_ALL.
*  LV_BUTTON-TEXT       = TEXT-B02. "'전체선택해제'.
*  INSERT LV_BUTTON INTO P_OBJECT->MT_TOOLBAR INDEX 1.
*
*  CLEAR LV_BUTTON.
*  LV_BUTTON-BUTN_TYPE  = '0'.
*  LV_BUTTON-FUNCTION   = 'ASEL'.
*  LV_BUTTON-ICON       = ICON_SELECT_ALL.
*  LV_BUTTON-TEXT       = TEXT-B01. "'전체선택'.
*  INSERT LV_BUTTON INTO P_OBJECT->MT_TOOLBAR INDEX 1.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND  USING    P_UCOMM.

*  CASE P_UCOMM.
*    WHEN 'DSEL' OR 'ASEL'.  "전체선택 / 해제
*      PERFORM GET_SELECTION USING P_UCOMM.
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SELECTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_UCOMM
*&---------------------------------------------------------------------*
FORM GET_SELECTION  USING    P_UCOMM.

*  CASE P_UCOMM.
*    WHEN 'DSEL'.
*      MODIFY GT_DATA FROM VALUE #( CHK = SPACE ) TRANSPORTING CHK WHERE CHK IS NOT INITIAL.
*    WHEN 'ASEL'.
*      MODIFY GT_DATA FROM VALUE #( CHK = ABAP_TRUE ) TRANSPORTING CHK WHERE CHK IS INITIAL.
*  ENDCASE.
*
*  GRID->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT ).
*  GRID->REFRESH_TABLE_DISPLAY( EXPORTING IS_STABLE = GS_STBL ).

ENDFORM.
