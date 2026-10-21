*&---------------------------------------------------------------------*
*& Include          ZGTPPR1000F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA_PROCESS .

  REFRESH : GT_HEADER, GT_ITEM_FUL.

* 코드마스터 헤더정보 추출
  SELECT * FROM ZGTPPT1000
    INTO CORRESPONDING FIELDS OF TABLE GT_HEADER
   WHERE MODULE_KIND IN S_KIND
     AND CODEGRP IN S_CODE_G.

  SORT GT_HEADER BY MODULE_KIND CODEGRP.
*  코드 마스터 아이템 정보 추출
  IF GT_HEADER[] IS NOT INITIAL.
    SELECT * FROM ZGTPPT1010
      INTO CORRESPONDING FIELDS OF TABLE GT_ITEM_FUL
      FOR ALL ENTRIES IN GT_HEADER
     WHERE MODULE_KIND = GT_HEADER-MODULE_KIND
       AND CODEGRP = GT_HEADER-CODEGRP.
  ENDIF.

  SORT GT_ITEM_FUL BY MODULE_KIND CODEGRP.
  CLEAR : GV_SUC_CNT, GV_ERR_CNT.
  LOOP AT GT_HEADER ASSIGNING FIELD-SYMBOL(<LS_HEADER>).
    READ TABLE GT_ITEM_FUL TRANSPORTING NO FIELDS WITH KEY MODULE_KIND = <LS_HEADER>-MODULE_KIND
                                                                                CODEGRP = <LS_HEADER>-CODEGRP
                                                                                BINARY SEARCH.
    IF SY-SUBRC EQ 0. " 아이템 데이터 존재시 녹색 신호등
      ADD 1 TO GV_SUC_CNT.
      <LS_HEADER>-STATUS =   ICON_LED_GREEN.
    ELSE. " 아이템 데이터 미존재시 노란 신호등
      ADD 1 TO GV_ERR_CNT.
      <LS_HEADER>-STATUS =     ICON_LED_YELLOW.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_pros
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING    PO_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                 PV_UCOMM.

  DATA : LT_ROW TYPE LVC_T_ROW.
  DATA : LS_ROW TYPE LVC_S_ROW.
  DATA : LT_DELTAB_1000 TYPE TABLE OF ZGTPPT1000.
  DATA : LT_DELTAB_1010 TYPE TABLE OF ZGTPPT1010.
  DATA : LV_MAX_IDX TYPE ZGTPPT1010-CODEID.
  DATA : LV_CHK_ITEM_EXIST.

  CASE PV_UCOMM.
    WHEN 'DEL'.
      CALL METHOD PO_SENDER->GET_SELECTED_ROWS
        IMPORTING
          ET_INDEX_ROWS = LT_ROW.

*      딜리트시 역순으로 정렬
      SORT LT_ROW BY INDEX DESCENDING.
  ENDCASE.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      CASE PV_UCOMM.
        WHEN 'ADD'.
          GV_CHK_CHANGE = ABAP_TRUE.
          APPEND INITIAL LINE TO GT_HEADER ASSIGNING FIELD-SYMBOL(<LS_HEADER>).
          <LS_HEADER>-STATUS = ICON_INSERT_ROW.
          <LS_HEADER>-CHK_CHG = 'N'.
        WHEN 'DEL'.
          IF LT_ROW[] IS INITIAL.
            MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E01.
            RETURN.
          ENDIF.
*         라인삭제시 기존데이터 삭제여부 확인후 팝업처리
          LOOP AT LT_ROW INTO LS_ROW.
            READ TABLE GT_HEADER INTO DATA(LS_HEADER) INDEX LS_ROW-INDEX.
            IF LS_HEADER-CHK_CHG NE 'N'. " 신규로 추가한 건이 아닌경우 디비에서 삭제
              APPEND INITIAL LINE TO LT_DELTAB_1000 ASSIGNING FIELD-SYMBOL(<LS_1000>).
              <LS_1000>-MODULE_KIND = LS_HEADER-MODULE_KIND.
              <LS_1000>-CODEGRP = LS_HEADER-CODEGRP.

              APPEND INITIAL LINE TO LT_DELTAB_1010 ASSIGNING FIELD-SYMBOL(<LS_1010>).
              <LS_1010>-MODULE_KIND = LS_HEADER-MODULE_KIND.
              <LS_1010>-CODEGRP = LS_HEADER-CODEGRP.
            ENDIF.
*          현재 보여지고 있는 아이템의 경우 삭제처리
            IF LS_HEADER-MODULE_KIND = GS_HEADER-MODULE_KIND AND LS_HEADER-CODEGRP = GS_HEADER-CODEGRP .
              LV_CHK_ITEM_EXIST = ABAP_TRUE.
            ENDIF.
          ENDLOOP.

          IF LT_DELTAB_1000[] IS NOT INITIAL. " 디비삭제건 존재시 팝업확인후 처리
            PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
              ' '
              TEXT-M01
              TEXT-M02.
            IF GV_ANSWER EQ 'J'.
              TRY.
                  SELECT * FROM ZGTPPT1000 INTO TABLE @DATA(LT_1000)
                    FOR ALL ENTRIES IN @LT_DELTAB_1000
                    WHERE MODULE_KIND = @LT_DELTAB_1000-MODULE_KIND
                       AND CODEGRP = @LT_DELTAB_1000-CODEGRP.
                  DELETE ZGTPPT1000 FROM TABLE LT_1000.

                  IF LT_DELTAB_1010[] IS NOT INITIAL.
                    SELECT * FROM ZGTPPT1010 INTO TABLE @DATA(LT_1010)
                       FOR ALL ENTRIES IN @LT_DELTAB_1010
                       WHERE MODULE_KIND = @LT_DELTAB_1010-MODULE_KIND
                          AND CODEGRP = @LT_DELTAB_1010-CODEGRP.

                    DELETE ZGTPPT1010 FROM TABLE LT_1010.
                  ENDIF.
                CATCH CX_ROOT INTO DATA(LO_ROOT).
                  MESSAGE S003 DISPLAY LIKE 'E' WITH  LO_ROOT->GET_TEXT( ).
                  RETURN.
              ENDTRY.
            ELSE.
              MESSAGE S003 WITH TEXT-E03.
              RETURN.
            ENDIF.
          ENDIF.

*        DB처리 완료후 인터널 테이블 삭제
          LOOP AT LT_ROW INTO LS_ROW.
            DELETE GT_HEADER INDEX LS_ROW-INDEX.
          ENDLOOP.

*        보여지고 있는 아이템 테이블의 경우 화면에서 날림.
          CLEAR GS_HEADER.
          REFRESH GT_ITEM.

          IF GO_GRID_0101 IS BOUND.
            GO_GRID_0101->FREE( ).
*          go_contain_0101->free( ).
            FREE : GO_GRID_0101, GO_CONTAIN_0101.
          ENDIF.
      ENDCASE.
*        화면 리프레쉬
      PERFORM REFRESH_GRID USING GO_GRID_0100.

    WHEN GO_GRID_0101.
      CASE PV_UCOMM.
        WHEN 'ADD_MULTY'.
          GV_CHK_CHANGE = ABAP_TRUE.
          CLEAR GV_LINE.
          CALL SCREEN '0101' STARTING AT 5 5.
          IF GV_LINE = 0.
            RETURN.
          ENDIF.
          IF NOT GV_LINE BETWEEN 1 AND 999.
            MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E04.
            RETURN.
          ENDIF.


          DATA(LT_ITEM_MAX) = GT_ITEM[].
          SORT LT_ITEM_MAX BY CODEID DESCENDING.
          READ TABLE LT_ITEM_MAX INTO DATA(LS_ITEM_MAX) INDEX 1.
          IF SY-SUBRC EQ 0.
            LV_MAX_IDX = LS_ITEM_MAX-CODEID.
          ELSE.
            LV_MAX_IDX = 0.
          ENDIF.

          DO GV_LINE TIMES.
            ADD 10 TO LV_MAX_IDX.
            APPEND INITIAL LINE TO GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
            <LS_ITEM>-MODULE_KIND = GS_HEADER-MODULE_KIND.
            <LS_ITEM>-CODEGRP = GS_HEADER-CODEGRP.
            <LS_ITEM>-STATUS = ICON_INSERT_ROW.
            <LS_ITEM>-CODEID = LV_MAX_IDX.
          ENDDO.

        WHEN 'ADD'.
          GV_CHK_CHANGE = ABAP_TRUE.
          APPEND INITIAL LINE TO GT_ITEM ASSIGNING <LS_ITEM>.
          <LS_ITEM>-MODULE_KIND = GS_HEADER-MODULE_KIND.
          <LS_ITEM>-CODEGRP = GS_HEADER-CODEGRP.
          <LS_ITEM>-STATUS = ICON_INSERT_ROW.

          LT_ITEM_MAX = GT_ITEM[].
          SORT LT_ITEM_MAX BY CODEID DESCENDING.
          READ TABLE LT_ITEM_MAX INTO LS_ITEM_MAX INDEX 1.
          IF SY-SUBRC EQ 0.
            <LS_ITEM>-CODEID = LS_ITEM_MAX-CODEID + 10.
          ELSE.
            <LS_ITEM>-CODEID = 10.
          ENDIF.

        WHEN 'DEL'.
          IF LT_ROW[] IS INITIAL.
            MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-E01.
            RETURN.
          ENDIF.
*         라인삭제시 기존데이터 삭제여부 확인후 팝업처리
          LOOP AT LT_ROW INTO LS_ROW.
            READ TABLE GT_ITEM INTO DATA(LS_ITEM) INDEX LS_ROW-INDEX.
            IF LS_ITEM-CHK_CHG NE 'N'. " 신규로 추가한 건이 아닌경우 디비에서 삭제
              APPEND INITIAL LINE TO LT_DELTAB_1010 ASSIGNING <LS_1010>.
              <LS_1010>-MODULE_KIND = LS_ITEM-MODULE_KIND.
              <LS_1010>-CODEGRP = LS_ITEM-CODEGRP.
              <LS_1010>-CODEID = LS_ITEM-CODEID.
            ENDIF.
          ENDLOOP.

          IF LT_DELTAB_1010[] IS NOT INITIAL. " 디비삭제건 존재시 팝업확인후 처리
            PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
              ' '
              TEXT-M01
              TEXT-M02.
            IF GV_ANSWER EQ 'J'.
              TRY.
                  SELECT * FROM ZGTPPT1010 INTO TABLE @LT_1010
                       FOR ALL ENTRIES IN @LT_DELTAB_1010
                   WHERE MODULE_KIND = @LT_DELTAB_1010-MODULE_KIND
                       AND CODEGRP = @LT_DELTAB_1010-CODEGRP
                       AND CODEID = @LT_DELTAB_1010-CODEID.

                  DELETE ZGTPPT1010 FROM TABLE LT_1010.
                CATCH CX_ROOT INTO LO_ROOT.
                  MESSAGE S003 DISPLAY LIKE 'E' WITH  LO_ROOT->GET_TEXT( ).
                  RETURN.
              ENDTRY.
            ELSE.
              MESSAGE S003 WITH TEXT-E03.
              RETURN.
            ENDIF.
          ENDIF.

*        DB처리 완료후 인터널 테이블 삭제
          LOOP AT LT_ROW INTO LS_ROW.
            DELETE GT_ITEM INDEX LS_ROW-INDEX.
          ENDLOOP.

        WHEN 'REFR'.
          LOOP AT GT_ITEM INTO LS_ITEM.
            IF LS_ITEM-CHK_CHG NE ' '.
              LV_CHK_ITEM_EXIST = ABAP_TRUE.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF LV_CHK_ITEM_EXIST EQ ABAP_TRUE.
            PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
              ' '
              TEXT-M03
              TEXT-M04.
            IF GV_ANSWER EQ 'J'.
              PERFORM MAKE_ITEM_TABLE.
            ELSE.
              RETURN.
            ENDIF.
          ELSE.
            MESSAGE S003 WITH TEXT-E05.
            RETURN.
          ENDIF.
      ENDCASE.
      PERFORM REFRESH_GRID USING GO_GRID_0101.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING    P_SENDER  TYPE REF TO CL_GUI_ALV_GRID
                                PO_DATA_CHANGED TYPE REF TO
                                          CL_ALV_CHANGED_DATA_PROTOCOL
                                PE_ONF4
                                PE_UCOMM.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA: LS_MOD_CELLS_APPEND TYPE LVC_S_MODI.
  DATA : LV_CHK_ERR.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME01 TYPE FIELDNAME.
  DATA : LV_FIELDNAME02 TYPE FIELDNAME.
  DATA : LV_MODULE_KIND TYPE ZGTPPT1000-MODULE_KIND.
  DATA : LV_CODEGRP TYPE ZGTPPT1000-CODEGRP.
  DATA : LV_FLDNR TYPE ZGTPPT1000-FLDNR.

  DEFINE __SET_ERR_MSG.
    lv_chk_err = abap_true.
    po_data_changed->add_protocol_entry(
        i_msgid     = 'ZGTPP00'                 " Message ID
        i_msgty     = 'E'                 " Message Type
        i_msgno     =  '03'                " Message No.
        i_msgv1     =  &1                " Message Variable1
        i_fieldname =  &2                " Field Name
        i_row_id    =  ls_mod_cells-row_id ).                " RowID
  END-OF-DEFINITION.

  REFRESH GT_LINES.
  REFRESH GT_FLDNR.
  CLEAR  LV_CHK_ERR.
  GV_CHK_CHANGE = ABAP_TRUE.
  LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.

    IF LS_MOD_CELLS-ERROR IS NOT INITIAL.
      CONTINUE.
    ENDIF.

    CASE P_SENDER.
      WHEN GO_GRID_0100.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'MODULE_KIND'.
*           중복값 확인
*            1) 인터널테이블 값 확인(키값 구성을 위해)
            CLEAR : LV_CODEGRP.
            READ TABLE GT_HEADER INTO DATA(LS_HEADER) INDEX LS_MOD_CELLS-ROW_ID.
            IF LS_HEADER-CODEGRP IS NOT INITIAL.
              LV_CODEGRP = LS_HEADER-CODEGRP.
            ELSE.
*              2) 변경목록중 데이터 확인((키값 구성을 위해))
              READ TABLE PO_DATA_CHANGED->MT_GOOD_CELLS INTO DATA(LS_TMP_CELLS) WITH KEY ROW_ID = LS_MOD_CELLS-ROW_ID
                                                                                                                  FIELDNAME = 'CODEGRP'.
              IF SY-SUBRC EQ 0.
                LV_CODEGRP = LS_TMP_CELLS-VALUE.
              ELSE.
                CONTINUE. " 키조건이 성립되지 않아 정합성 체크 없음
              ENDIF.
            ENDIF.

*          3) 인터널 테이블 값중 중복값 체크
            READ TABLE GT_HEADER TRANSPORTING NO FIELDS WITH KEY MODULE_KIND = LS_MOD_CELLS-VALUE
                                                                                         CODEGRP = LV_CODEGRP.
            IF SY-SUBRC EQ 0 AND SY-TABIX NE LS_MOD_CELLS-ROW_ID.
              __SET_ERR_MSG : TEXT-M05 'CODEGRP'.
              CONTINUE.
            ENDIF.

*            4) 변경목록중 키값 확인
            LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_TMP_CELLS WHERE FIELDNAME = LS_MOD_CELLS-FIELDNAME.
              IF LS_TMP_CELLS-ROW_ID = LS_MOD_CELLS-ROW_ID.
                CONTINUE.
              ENDIF.

              READ TABLE PO_DATA_CHANGED->MT_GOOD_CELLS TRANSPORTING NO FIELDS WITH KEY ROW_ID = LS_TMP_CELLS-ROW_ID
                                                                                                                       FIELDNAME = 'CODEGRP'
                                                                                                                       VALUE = LV_CODEGRP.
              IF SY-SUBRC EQ 0.
                __SET_ERR_MSG : TEXT-M05 'CODEGRP'.
                EXIT.
              ENDIF.

            ENDLOOP.


          WHEN 'CODEGRP'. " 정합성 차후 구성
*           중복값 확인
*            1) 인터널테이블 값 확인(키값 구성을 위해)
            CLEAR : LV_MODULE_KIND.
            CLEAR LS_HEADER.
            READ TABLE GT_HEADER INTO LS_HEADER INDEX LS_MOD_CELLS-ROW_ID.
            IF LS_HEADER-MODULE_KIND IS NOT INITIAL.
              LV_MODULE_KIND = LS_HEADER-MODULE_KIND.
            ELSE.
*              2) 변경목록중 데이터 확인((키값 구성을 위해))
              READ TABLE PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_TMP_CELLS WITH KEY ROW_ID = LS_MOD_CELLS-ROW_ID
                                                                                                              FIELDNAME = 'MODULE_KIND'.
              IF SY-SUBRC EQ 0.
                LV_MODULE_KIND = LS_TMP_CELLS-VALUE.
              ELSE.
                CONTINUE. " 키조건이 성립되지 않아 정합성 체크 없음
              ENDIF.
            ENDIF.

*          3) 인터널 테이블 값중 중복값 체크
            READ TABLE GT_HEADER TRANSPORTING NO FIELDS WITH KEY MODULE_KIND = LV_MODULE_KIND
                                                                                         CODEGRP = LS_MOD_CELLS-VALUE.
            IF SY-SUBRC EQ 0 AND SY-TABIX NE LS_MOD_CELLS-ROW_ID.
              __SET_ERR_MSG : TEXT-M05 LS_MOD_CELLS-FIELDNAME.
              CONTINUE.
            ENDIF.

*            4) 변경목록중 키값 확인
            LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_TMP_CELLS WHERE FIELDNAME = LS_MOD_CELLS-FIELDNAME.
              IF LS_TMP_CELLS-ROW_ID = LS_MOD_CELLS-ROW_ID.
                CONTINUE.
              ENDIF.

              READ TABLE PO_DATA_CHANGED->MT_GOOD_CELLS TRANSPORTING NO FIELDS WITH KEY ROW_ID = LS_TMP_CELLS-ROW_ID
                                                                                                                       FIELDNAME = 'MODULE_KIND'
                                                                                                                       VALUE = LV_MODULE_KIND.
              IF SY-SUBRC EQ 0.
                __SET_ERR_MSG : TEXT-M05 LS_MOD_CELLS-FIELDNAME.
                EXIT.
              ENDIF.

            ENDLOOP.

          WHEN 'FLDNR'. " 정합성 차후 구성
*          범위
            IF NOT LS_MOD_CELLS-VALUE BETWEEN 0 AND 20.
              __SET_ERR_MSG : TEXT-M06 LS_MOD_CELLS-FIELDNAME.
            ENDIF.
*         변경시 필드 구성 변경
            APPEND INITIAL LINE TO GT_FLDNR ASSIGNING FIELD-SYMBOL(<LS_FLDNR>).
            <LS_FLDNR>-ROW_ID = LS_MOD_CELLS-ROW_ID.
            <LS_FLDNR>-FLDNR = LS_MOD_CELLS-VALUE.
          WHEN OTHERS.

            CLEAR LV_NUM.
            DO 20 TIMES.
              ADD 1 TO LV_NUM.
              LV_FIELDNAME01 = 'FLD_NAME_' && LV_NUM.

              IF LS_MOD_CELLS-FIELDNAME = LV_FIELDNAME01.

                CLEAR LS_HEADER.
                READ TABLE GT_HEADER INTO LS_HEADER INDEX LS_MOD_CELLS-ROW_ID.
                IF SY-SUBRC EQ 0 AND LS_HEADER-FLDNR BETWEEN 1 AND 20.
                  LV_FLDNR = LS_HEADER-FLDNR.
                ELSE.
                  READ TABLE PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_TMP_CELLS WITH KEY ROW_ID = LS_MOD_CELLS-ROW_ID
                                                                                                                  FIELDNAME = 'FLDNR'.
                  IF SY-SUBRC EQ 0 AND LS_TMP_CELLS-VALUE BETWEEN 1 AND 20.
                    LV_FLDNR = LS_HEADER-FLDNR.
                  ELSE.
                    __SET_ERR_MSG : TEXT-M07 LS_MOD_CELLS-FIELDNAME.
                    CONTINUE.
                  ENDIF.
                ENDIF.

                IF LV_NUM > LV_FLDNR.
* 사용필드수 범위 초과인지 확인.
                  IF LS_MOD_CELLS-VALUE IS NOT INITIAL.
                    __SET_ERR_MSG : TEXT-M08 LS_MOD_CELLS-FIELDNAME.
                  ENDIF.
                ENDIF.
              ENDIF.

              LV_FIELDNAME02 = 'FLD_LENG_' && LV_NUM.
              IF LS_MOD_CELLS-FIELDNAME = LV_FIELDNAME02.

                CLEAR LS_HEADER.
                READ TABLE GT_HEADER INTO LS_HEADER INDEX LS_MOD_CELLS-ROW_ID.
                IF SY-SUBRC EQ 0 AND LS_HEADER-FLDNR BETWEEN 1 AND 20.
                  LV_FLDNR = LS_HEADER-FLDNR.
                ELSE.
                  READ TABLE PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_TMP_CELLS WITH KEY ROW_ID = LS_MOD_CELLS-ROW_ID
                                                                                                                  FIELDNAME = 'FLDNR'.
                  IF SY-SUBRC EQ 0 AND LS_TMP_CELLS-VALUE BETWEEN 1 AND 20.
                    LV_FLDNR = LS_HEADER-FLDNR.
                  ELSE.
                    __SET_ERR_MSG : TEXT-M07 LS_MOD_CELLS-FIELDNAME.
                    CONTINUE.
                  ENDIF.
                ENDIF.

                IF  LV_NUM <= LV_FLDNR.
                  IF NOT LS_MOD_CELLS-VALUE BETWEEN 1 AND 40.
                    __SET_ERR_MSG : TEXT-M09 LS_MOD_CELLS-FIELDNAME.
                  ENDIF.
                ELSE.
                  IF LS_MOD_CELLS-VALUE NE '00'.
                    __SET_ERR_MSG : TEXT-M08 LS_MOD_CELLS-FIELDNAME.
                  ENDIF.
                ENDIF.
              ENDIF.

            ENDDO.

        ENDCASE.

      WHEN GO_GRID_0101.
        APPEND INITIAL LINE TO GT_LINES ASSIGNING FIELD-SYMBOL(<LS_LINES>).
        <LS_LINES>-INDEX = LS_MOD_CELLS-ROW_ID.

    ENDCASE.

  ENDLOOP.

  IF LV_CHK_ERR IS NOT INITIAL.
    PO_DATA_CHANGED->DISPLAY_PROTOCOL( ).
  ELSE.
    IF GT_FLDNR[] IS NOT INITIAL.
      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          FUNCTIONCODE           = 'SETFLD'              " Function code
        EXCEPTIONS
          FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
          OTHERS                 = 2.
      IF SY-SUBRC <> 0.
      ENDIF.
    ENDIF.
    IF GT_LINES IS NOT INITIAL.
      SORT GT_LINES.
      DELETE ADJACENT DUPLICATES FROM GT_LINES.

      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          FUNCTIONCODE           = 'SETSTATUS'              " Function code
        EXCEPTIONS
          FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
          OTHERS                 = 2.
      IF SY-SUBRC <> 0.
      ENDIF.
    ENDIF.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                            P_ROW TYPE LVC_S_ROW
                            P_COLUMN TYPE LVC_S_COL.

  DATA : LV_CHKERR.
  DATA : LV_MESSAGE(200).

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      GO_GRID_0100->CHECK_CHANGED_DATA( ).

      CLEAR GS_HEADER.
      READ TABLE GT_HEADER INTO GS_HEADER INDEX P_ROW-INDEX.
      IF SY-SUBRC EQ 0.
        PERFORM CHECK_VALIDATION_HEADER CHANGING LV_CHKERR LV_MESSAGE.
        IF LV_CHKERR IS INITIAL.
          PERFORM MAKE_ITEM_TABLE.
          PERFORM REFRESH_GRID_0101.
        ELSE.
          CLEAR GS_HEADER.
          MESSAGE S003 DISPLAY LIKE 'E' WITH LV_MESSAGE.
          RETURN.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form toolbar_pros
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM TOOLBAR_PROS  USING    PO_SENDER
                          PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          R_INTERACTIVE.

  CASE PO_SENDER.
    WHEN GO_GRID_0100.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                           USING : '' '' '' '' '3'.            "구분자

      IF GV_DIS_MODE NE 'D'.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                             USING : '' '' '' '' '3',            "구분자
                                        'ADD' ICON_INSERT_ROW '' TEXT-T01 0 ,
                                        'DEL' ICON_DELETE_ROW '' TEXT-T02 0.
      ENDIF.
    WHEN GO_GRID_0101.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                           USING : '' '' '' '' '3'.            "구분자

      IF GV_DIS_MODE NE 'D'.
        PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                             USING : '' '' '' '' '3',            "구분자
                                        'ADD' ICON_INSERT_ROW '' TEXT-T01 0 ,
                                        'ADD_MULTY' ICON_INSERT_ROW TEXT-T03 TEXT-T03 0 ,
                                        'DEL' ICON_DELETE_ROW '' TEXT-T02 0,
                                        'REFR' ICON_REFRESH '' 'Refresh' 0.
      ENDIF.
  ENDCASE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  IF GV_DIS_MODE = 'D'.
    SET PF-STATUS '0100' EXCLUDING 'DISP'.
  ELSE.
    SET PF-STATUS '0100' EXCLUDING 'CHANGE'..
  ENDIF.
  SET TITLEBAR '0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0100 OUTPUT.

  IF GO_GRID_0100 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0100.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0100.
    PERFORM SET_LAYOUT_GRID_0100.
    PERFORM SET_FIELDCAT_GRID_0100.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0100.
    PERFORM CALL_GRID_0100_DISPLAY.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0100 .

  CREATE OBJECT GO_DOCKING_CONTAINER
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
*화면 분할
  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_DOCKING_CONTAINER
      ROWS    = 2
      COLUMNS = 1.
* top 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0100.
* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.


  CREATE OBJECT GO_GRID_0100
    EXPORTING
      I_PARENT      = GO_CONTAIN_0100
      I_APPL_EVENTS = ABAP_TRUE.

*  CREATE OBJECT go_grid_0101
*    EXPORTING
*      i_parent      = go_contain_0101
*      i_appl_events = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_handler_register
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

*-----------------------------
* CREATE OBJECT go_events.
  IF GO_EVENT_HANDLER IS NOT BOUND.
    CREATE OBJECT GO_EVENT_HANDLER.
  ENDIF.

*// Event Handler ##
  SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED          FOR PO_GRID.
  SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .

  DATA : LV_SUC_CNT(10).
  DATA : LV_ERR_CNT(10).
  DATA : LV_CNT TYPE I.
  DATA : LV_CNT_C(10).

  CLEAR GS_LAYOUT_0100.
  GS_LAYOUT_0100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0100-NO_ROWINS = ABAP_TRUE.
*  GS_LAYOUT_0100-NO_ROWMOVE = ABAP_TRUE.
  GS_LAYOUT_0100-SMALLTITLE = ABAP_TRUE.
  GS_LAYOUT_0100-SEL_MODE   = 'D'.
  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.
  LV_SUC_CNT = GV_SUC_CNT.
  CONDENSE LV_SUC_CNT.
  LV_ERR_CNT = GV_ERR_CNT.
  CONDENSE LV_ERR_CNT.
  LV_CNT = LINES( GT_HEADER ).
  LV_CNT_C = LV_CNT.
  CONDENSE LV_CNT_C.

  CONCATENATE '총 건수 :' LV_CNT_C '( 성공 :' LV_SUC_CNT INTO GS_LAYOUT_0100-GRID_TITLE SEPARATED BY SPACE.

  GS_LAYOUT_0100-GRID_TITLE = GS_LAYOUT_0100-GRID_TITLE && ','.
  CONCATENATE GS_LAYOUT_0100-GRID_TITLE '경고 :' LV_ERR_CNT ')' INTO GS_LAYOUT_0100-GRID_TITLE SEPARATED BY SPACE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .

  DATA : LV_NUM(2) TYPE N.

  DATA : LV_FIELDNAME01 TYPE FIELDNAME.
  DATA : LV_FIELDNAME02 TYPE FIELDNAME.

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.

  DATA: L_DATUM TYPE SY-DATUM.
  L_DATUM = SY-DATUM + 1.
  SET PARAMETER ID 'ALVBUFFER' FIELD L_DATUM.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR1000T01'
      I_INTERNAL_TABNAME     = 'GS_HEADER'
      I_BYPASSING_BUFFER     = ''
      I_BUFFER_ACTIVE        = 'X'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_HEADER
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-REPTEXT = '상태'(f01).
      WHEN 'MODULE_KIND'.
        <LS_FCAT>-REPTEXT = '모듈 코드'(f02).
      WHEN 'CODEGRP'.
        <LS_FCAT>-REPTEXT = '코드 그룹'(f03).
      WHEN 'GRPDESC'.
        <LS_FCAT>-REPTEXT = '그룹 내역'(f04).
        <LS_FCAT>-LOWERCASE = ABAP_TRUE.
      WHEN 'CODEGRP'.
        <LS_FCAT>-REPTEXT = '코드 그룹'(f03).
      WHEN 'INACT'.
        <LS_FCAT>-REPTEXT = '비활성'(f05).
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
      WHEN 'IF_FLAG'.
        <LS_FCAT>-REPTEXT = 'I/F 대상여부'(f06).
        <LS_FCAT>-CHECKBOX = ABAP_TRUE.
      WHEN 'FLDNR'.
        <LS_FCAT>-REPTEXT = '사용 필드 수'(f07).
      WHEN 'CRDAT' OR 'CRTIM' OR 'CRNAM' OR 'CHDAT' OR 'CHTIM' OR 'CHNAM'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

    CLEAR LV_NUM.
    DO 20 TIMES.
      ADD 1 TO LV_NUM.
      LV_FIELDNAME01 = 'FLD_NAME_' && LV_NUM.
      LV_FIELDNAME02 = 'FLD_LENG_' && LV_NUM.
      CASE <LS_FCAT>-FIELDNAME.
        WHEN LV_FIELDNAME01.
          <LS_FCAT>-REPTEXT = '필드명'(f08) && LV_NUM.
        WHEN LV_FIELDNAME02.
          <LS_FCAT>-REPTEXT = '길이'(f09) && LV_NUM.
      ENDCASE.
    ENDDO.


  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  LOOP AT GT_HEADER ASSIGNING FIELD-SYMBOL(<LS_HEADER>).
    REFRESH LT_CELLTAB.
    IF GV_DIS_MODE = 'D'.
    ELSE.
      LOOP AT GT_FIELDCAT_0100 INTO DATA(LS_FCAT).
        IF <LS_HEADER>-CHK_CHG = 'N'. " 라인추가시 변경불가필드 세팅
          CASE LS_FCAT-FIELDNAME.
            WHEN 'STATUS'.
              CONTINUE.
          ENDCASE.
        ELSE. " 변경불가필드 세팅
          CASE <LS_HEADER>-STATUS.
            WHEN ICON_LED_YELLOW.
              CASE LS_FCAT-FIELDNAME.
                WHEN 'STATUS'.
                  CONTINUE.
              ENDCASE.
            WHEN ICON_LED_GREEN.
              CASE LS_FCAT-FIELDNAME.
                WHEN 'STATUS' OR 'MODULE_KIND' OR 'CODEGRP' OR 'FLDNR'.
                  CONTINUE.
              ENDCASE.
          ENDCASE.

        ENDIF.
        CLEAR LS_CELLTAB.
        __SET_CELL_ATTRIBUTE LS_FCAT-FIELDNAME CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
      ENDLOOP.
    ENDIF.
    <LS_HEADER>-CELLTAB = LT_CELLTAB.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0100_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .

  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
    CHANGING
      IT_OUTTAB            = GT_HEADER
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0100->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  IF GO_GRID_0100 IS BOUND.
    GO_GRID_0100->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID) ).
  ENDIF.
  IF GO_GRID_0101 IS BOUND.
    GO_GRID_0101->CHECK_CHANGED_DATA( IMPORTING E_VALID = DATA(LV_VALID1) ).
  ENDIF.

  CASE GV_OK_CODE.
    WHEN 'CHANGE'.
      CLEAR GV_DIS_MODE.
      CLEAR GV_CHK_CHANGE.
      GV_DIS_MODE = 'C'.

      PERFORM REFRESH_GRID USING GO_GRID_0100.
      IF GS_HEADER IS NOT INITIAL.
        PERFORM REFRESH_GRID USING GO_GRID_0101.
      ENDIF.

    WHEN 'DISP'.
      IF GV_CHK_CHANGE IS NOT INITIAL.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '변경된 데이터가 있습니다. 디스플레이 모드로 변환 하시겠습니까?'(M10)
          '작업확인'(M11).
        IF GV_ANSWER = 'J'.
        ELSE.
          MESSAGE S000 WITH '변환이 취소 되었습니다.!!!'(M12).
          RETURN.
        ENDIF.
      ELSE.
      ENDIF.
      CLEAR GV_DIS_MODE.
      CLEAR GV_CHK_CHANGE.
      GV_DIS_MODE = 'D'.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
      IF GS_HEADER IS NOT INITIAL.
        PERFORM REFRESH_GRID USING GO_GRID_0101.
      ENDIF.

    WHEN 'REFRESH'.
      IF GV_CHK_CHANGE IS NOT INITIAL.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '변경된 데이터가 존재합니다. Refresh 진행하시겠습니까?'(m03)
          '작업확인'(m11).
        IF GV_ANSWER = 'J'.
          PERFORM GET_DATA_PROCESS.
*        보여지고 있는 아이템 테이블의 경우 화면에서 날림.
          CLEAR GS_HEADER.
          REFRESH GT_ITEM.

          GO_GRID_0101->FREE( ).
*          go_contain_0101->free( ).
          FREE : GO_GRID_0101, GO_CONTAIN_0101.

          CLEAR GV_DIS_MODE.
          CLEAR GV_CHK_CHANGE.
          GV_DIS_MODE = 'D'.
        ELSE.
          MESSAGE S000 WITH 'Refresh 취소 되었습니다.!!!'(m13).
          RETURN.
        ENDIF.
      ELSE.
        CLEAR GV_DIS_MODE.
        GV_DIS_MODE = 'D'.
      ENDIF.

      CLEAR GV_CHK_CHANGE.
      GV_DIS_MODE = 'D'.
      PERFORM REFRESH_GRID USING GO_GRID_0100.
      IF GS_HEADER IS NOT INITIAL.
        PERFORM REFRESH_GRID USING GO_GRID_0101.
      ENDIF.

    WHEN 'SAVE'.

      IF GO_GRID_0100 IS BOUND.
        IF LV_VALID IS INITIAL.
          RETURN.
        ENDIF.
      ENDIF.
      IF GO_GRID_0101 IS BOUND.
        IF LV_VALID1 IS INITIAL.
          RETURN.
        ENDIF.
      ENDIF.

      IF GV_CHK_CHANGE IS NOT INITIAL.

        PERFORM CHK_SAVE CHANGING GV_MESSAGE.
        IF GV_MESSAGE IS INITIAL.

          PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
            ' '
            '내용을 저장 하시겠습니까?'(m14)
            '저장'(m15).
          IF GV_ANSWER = 'J'.
            PERFORM SAVE_PROC.
            CLEAR GV_CHK_CHANGE.
            PERFORM GET_DATA_PROCESS.
            PERFORM REFRESH_GRID USING GO_GRID_0100.
            IF GS_HEADER IS NOT INITIAL.
              PERFORM MAKE_ITEM_TABLE.
              PERFORM REFRESH_GRID USING GO_GRID_0101.
            ENDIF.

          ELSE.
            MESSAGE S000 WITH '작업이 취소 되었습니다.!!!'(M16).
          ENDIF.

        ELSE.
          MESSAGE S000 WITH GV_MESSAGE.
        ENDIF.
      ELSE.
        MESSAGE S000 WITH '변경된 내용이 없습니다.'(m17).
      ENDIF.

    WHEN 'SETFLD'.
      PERFORM SET_FIELD_GRID_0100.
    WHEN 'SETSTATUS'.
      PERFORM SET_STATUS_ITEM.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  exclude_of_toolbar_grid_0100
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM EXCLUDE_OF_TOOLBAR_GRID_0100.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0100
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.                    " exclude_of_toolbar_button
*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*-----------------------------------------------------------------------
**
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.
ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& Form refresh_grid_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_GRID_0101 .

  IF GO_GRID_0101 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0101.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0101.
    PERFORM SET_LAYOUT_GRID_0101.
    PERFORM SET_FIELDCAT_GRID_0101.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0101.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0101.
    PERFORM CALL_GRID_0101_DISPLAY.
  ELSE.
    PERFORM REFRESH_GRID USING GO_GRID_0101.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_item_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_ITEM_TABLE .

  DATA : LT_FCAT TYPE LVC_T_FCAT.

  SELECT * FROM ZGTPPT1010
    INTO CORRESPONDING FIELDS OF TABLE GT_ITEM
   WHERE MODULE_KIND = GS_HEADER-MODULE_KIND
     AND CODEGRP = GS_HEADER-CODEGRP.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
    <LS_ITEM>-STATUS = ICON_LED_GREEN.
    <LS_ITEM>-CHK_CHG = 'O'.
  ENDLOOP.

  SORT GT_ITEM BY CODEID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_grid_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0101 .

  DATA : LV_FIELS_CNT(10).
  DATA : LV_CNT TYPE I.
  DATA : LV_CNT_C(10).
  CLEAR GS_LAYOUT_0101.
*  gs_layout_0101-cwidth_opt = abap_true.
  GS_LAYOUT_0101-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0101-SMALLTITLE = ABAP_TRUE.
  GS_LAYOUT_0101-SEL_MODE   = 'D'.
  GS_LAYOUT_0101-STYLEFNAME = 'CELLTAB'.

  IF GS_HEADER IS NOT INITIAL.
    LV_CNT = LINES( GT_ITEM ).
    LV_CNT_C = LV_CNT.
    CONDENSE LV_CNT_C.

    CONCATENATE '총 건수 :' LV_CNT_C INTO GS_LAYOUT_0101-GRID_TITLE SEPARATED BY SPACE.
    GS_LAYOUT_0101-GRID_TITLE = GS_LAYOUT_0101-GRID_TITLE && ','.
    CONCATENATE GS_LAYOUT_0101-GRID_TITLE '코드그룹 :' GS_HEADER-CODEGRP INTO GS_LAYOUT_0101-GRID_TITLE SEPARATED BY SPACE.
    GS_LAYOUT_0101-GRID_TITLE = GS_LAYOUT_0101-GRID_TITLE && ','.
    CONCATENATE GS_LAYOUT_0101-GRID_TITLE '내역 :' GS_HEADER-GRPDESC INTO GS_LAYOUT_0101-GRID_TITLE SEPARATED BY SPACE.
    GS_LAYOUT_0101-GRID_TITLE = GS_LAYOUT_0101-GRID_TITLE && ','.
    LV_FIELS_CNT = 0 + GS_HEADER-FLDNR.
    CONDENSE LV_FIELS_CNT.
    CONCATENATE GS_LAYOUT_0101-GRID_TITLE '사용필드 수 :' LV_FIELS_CNT INTO GS_LAYOUT_0101-GRID_TITLE SEPARATED BY SPACE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_grid_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0101 .

  DATA : LV_NUM(2) TYPE N.

  DATA : LV_FIELDNAME01 TYPE FIELDNAME.
  DATA : LV_FIELDNAME02 TYPE FIELDNAME.
  DATA : LV_FIELDNAME03 TYPE FIELDNAME.

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR1000T01'
      I_INTERNAL_TABNAME     = 'GS_ITEM'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0101.
*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0101[]
    TABLES
      IT_DATA         = GT_ITEM
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'.
        <LS_FCAT>-ICON = ABAP_TRUE.
        <LS_FCAT>-REPTEXT = '상태'(F01).
      WHEN 'MODULE_KIND' OR 'CODEGRP' OR 'CODEID'.
        <LS_FCAT>-TECH = ABAP_TRUE.

      WHEN 'CRDAT' OR 'CRTIM' OR 'CRNAM' OR 'CHDAT' OR 'CHTIM' OR 'CHNAM'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

    CLEAR LV_NUM.
    DO 20 TIMES.
      ADD 1 TO LV_NUM.
      LV_FIELDNAME01 = 'FLD_NAME_' && LV_NUM.
      LV_FIELDNAME02 = 'FLD_LENG_' && LV_NUM.
      LV_FIELDNAME03 = 'FLD_' && LV_NUM.
      IF LV_NUM <= GS_HEADER-FLDNR.
        CASE <LS_FCAT>-FIELDNAME.
          WHEN LV_FIELDNAME03.
            <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = GS_HEADER-(LV_FIELDNAME01).
            <LS_FCAT>-DD_OUTLEN = <LS_FCAT>-INTLEN = 0 + GS_HEADER-(LV_FIELDNAME02).
            <LS_FCAT>-OUTPUTLEN = 20.
            CLEAR : <LS_FCAT>-REF_FIELD, <LS_FCAT>-REF_TABLE.
        ENDCASE.
      ELSE.
        CASE <LS_FCAT>-FIELDNAME.
          WHEN LV_FIELDNAME03.
            <LS_FCAT>-TECH = ABAP_TRUE.
        ENDCASE.
      ENDIF.
    ENDDO.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_attribute_grid_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0101 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>).
    REFRESH LT_CELLTAB.
    IF GV_DIS_MODE = 'D'.
    ELSE.
      LOOP AT GT_FIELDCAT_0101 INTO DATA(LS_FCAT).
        IF <LS_ITEM>-CHK_CHG = 'N'. " 라인추가시 변경불가필드 세팅
          CASE LS_FCAT-FIELDNAME.
            WHEN 'STATUS'.
              CONTINUE.
          ENDCASE.
        ELSE. " 변경불가필드 세팅
          CASE LS_FCAT-FIELDNAME.
            WHEN 'STATUS'.
              CONTINUE.
          ENDCASE.
        ENDIF.
        CLEAR LS_CELLTAB.
        __SET_CELL_ATTRIBUTE LS_FCAT-FIELDNAME CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
      ENDLOOP.
    ENDIF.
    <LS_ITEM>-CELLTAB = LT_CELLTAB.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_of_toolbar_grid_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0101 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0101
        USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_AUF,
                CL_GUI_ALV_GRID=>MC_FC_CHECK,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_AVERAGE,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_grid_0101_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0101_DISPLAY .

  CALL METHOD GO_GRID_0101->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0101
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0101
    CHANGING
      IT_OUTTAB            = GT_ITEM
      IT_FIELDCATALOG      = GT_FIELDCAT_0101.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0101->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0101->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  IF GV_DIS_MODE = 'D'.
    CALL METHOD GO_GRID_0101->SET_READY_FOR_INPUT
      EXPORTING
        I_READY_FOR_INPUT = 0.
  ELSE.
    CALL METHOD GO_GRID_0101->SET_READY_FOR_INPUT
      EXPORTING
        I_READY_FOR_INPUT = 1.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_object_grid_0101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0101 .

* bottom 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0101.

  CREATE OBJECT GO_GRID_0101
    EXPORTING
      I_PARENT      = GO_CONTAIN_0101
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_grid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0101
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID..

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      PERFORM SET_LAYOUT_GRID_0100.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0100.                 " Layout
    WHEN GO_GRID_0101.
      PERFORM SET_LAYOUT_GRID_0101.
      PERFORM SET_FIELDCAT_GRID_0101.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0101.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0101.                 " Layout

      CALL METHOD PO_GRID->SET_FRONTEND_FIELDCATALOG
        EXPORTING
          IT_FIELDCATALOG = GT_FIELDCAT_0101.                 " Field Catalog
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_SCROLL.

  IF GV_DIS_MODE = 'D'.
    CALL METHOD PO_GRID->SET_READY_FOR_INPUT
      EXPORTING
        I_READY_FOR_INPUT = 0.
  ELSE.
    CALL METHOD PO_GRID->SET_READY_FOR_INPUT
      EXPORTING
        I_READY_FOR_INPUT = 1.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm_step
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_CONFIRM_STEP  USING LP_OPT
                                  LP_TEXT1
                                  LP_TEXT2
                                  LP_TITLE.
  CLEAR GV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      DEFAULTOPTION  = LP_OPT
      TEXTLINE1      = LP_TEXT1
      TEXTLINE2      = LP_TEXT2
      TITEL          = LP_TITLE
      CANCEL_DISPLAY = ''
    IMPORTING
      ANSWER         = GV_ANSWER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_proc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_PROC .

  DATA : LT_1000 LIKE TABLE OF ZGTPPT1000.
  DATA : LS_1000 LIKE ZGTPPT1000.
  DATA : LT_1010 LIKE TABLE OF ZGTPPT1010.
  DATA : LS_1010 LIKE ZGTPPT1010.

  LOOP AT GT_HEADER INTO DATA(LS_HEADER).
    IF LS_HEADER-CHK_CHG IS NOT INITIAL.
      MOVE-CORRESPONDING LS_HEADER TO LS_1000.
      IF LS_HEADER-CHK_CHG = 'C'. " 생성의 경우 생성 타임스템프 적용
        MOVE : SY-DATUM TO LS_1000-CRDAT,
                SY-UZEIT TO LS_1000-CRTIM,
                SY-UNAME TO LS_1000-CRNAM.
      ENDIF.
      MOVE : SY-DATUM TO LS_1000-CHDAT,
                SY-UZEIT TO LS_1000-CHTIM,
                SY-UNAME TO LS_1000-CHNAM.

      APPEND LS_1000 TO LT_1000.
    ENDIF.
  ENDLOOP.

  LOOP AT GT_ITEM INTO DATA(LS_ITEM).
    CHECK LS_ITEM-CHK_CHG NE 'O'.

    MOVE-CORRESPONDING LS_ITEM TO LS_1010.
    IF LS_ITEM-CHK_CHG IS INITIAL. " 생성의 경우 생성 타임스템프 적용
      MOVE : SY-DATUM TO LS_1010-CRDAT,
              SY-UZEIT TO LS_1010-CRTIM,
              SY-UNAME TO LS_1010-CRNAM.
    ENDIF.

    MOVE : SY-DATUM TO LS_1010-CHDAT,
              SY-UZEIT TO LS_1010-CHTIM,
              SY-UNAME TO LS_1010-CHNAM.

    APPEND LS_1010 TO LT_1010.

  ENDLOOP.

  IF LT_1000[] IS INITIAL AND LT_1010[] IS INITIAL.
    MESSAGE S000 WITH '저장할 데이터가 없습니다.'(M18).
    RETURN.
  ENDIF.

  IF LT_1000[] IS NOT INITIAL.
    MODIFY ZGTPPT1000 FROM TABLE LT_1000.
  ENDIF.

  IF LT_1010[] IS NOT INITIAL.
    MODIFY ZGTPPT1010 FROM TABLE LT_1010.
  ENDIF.

  MESSAGE S004.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> PO_OBJECT_>MT_TOOLBAR
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR  TABLES  PT_TOOLBAR STRUCTURE STB_BUTTON
               USING    PV_FUNCTION
                           PV_ICON
                           PV_TEXT
                           PV_QUICKINFO
                           PV_BUTN_TYPE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = PV_FUNCTION.
  LS_TOOLBAR-ICON      = PV_ICON.
  LS_TOOLBAR-TEXT      = PV_TEXT.
  LS_TOOLBAR-QUICKINFO = PV_QUICKINFO.
  LS_TOOLBAR-BUTN_TYPE = PV_BUTN_TYPE.
  APPEND LS_TOOLBAR TO PT_TOOLBAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_validation_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHKERR
*&---------------------------------------------------------------------*
FORM CHECK_VALIDATION_HEADER  CHANGING PV_CHKERR PV_MESSAGE.

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME(30).
  DATA : LV_FIELDNAME2(30).

  IF GS_HEADER-CODEGRP IS INITIAL OR GS_HEADER-MODULE_KIND IS INITIAL.
    PV_CHKERR = ABAP_TRUE.
    PV_MESSAGE = '필수값 입력이 없습니다.'(M19).
    RETURN.
  ENDIF.

  IF GS_HEADER-FLDNR = 0. " 사용필드수 입력이 없을경우
    PV_CHKERR = ABAP_TRUE.
    PV_MESSAGE = '사용 필드수 입력값이 없습니다.'(M20).
    RETURN.
  ENDIF.

  CLEAR LV_NUM.
  DO GS_HEADER-FLDNR TIMES.
    ADD 1 TO LV_NUM.
    LV_FIELDNAME = 'FLD_NAME_' && LV_NUM.
    LV_FIELDNAME2 = 'FLD_LENG_' && LV_NUM.

    IF  GS_HEADER-(LV_FIELDNAME) IS INITIAL.
      PV_CHKERR = ABAP_TRUE.
      PV_MESSAGE = '필드명'(F08) && LV_NUM && '에 입력값이 없습니다.'(M21).
      EXIT.
    ENDIF.

    IF  GS_HEADER-(LV_FIELDNAME2) = 0.
      PV_CHKERR = ABAP_TRUE.
      PV_MESSAGE = '길이'(F09) && LV_NUM && '에 입력값이 없습니다.'(M21).
      EXIT.
    ENDIF.
  ENDDO.

  IF GS_HEADER-CHK_CHG = 'N'. " 신규생성된 라인의 경우 저장 먼저
    PV_CHKERR = ABAP_TRUE.
    PV_MESSAGE = '헤더 저장이후 아이템 입력이 가능합니다.'(M22).
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_screen_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_SCREEN_PROCESS .
  DATA(LV_LINE) = LINES( GT_HEADER ).
  DATA : LV_LINE_C TYPE C LENGTH 10.
  LV_LINE_C = LV_LINE.
  CONDENSE LV_LINE_C.
  MESSAGE S002 WITH LV_LINE_C.

  CALL SCREEN 100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_field_grid_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELD_GRID_0100 .

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME01 TYPE FIELDNAME.
  DATA : LV_FIELDNAME02 TYPE FIELDNAME.
  FIELD-SYMBOLS : <LV_VALUE> TYPE ANY.

  LOOP AT GT_FLDNR INTO GS_FLDNR.
    READ TABLE GT_HEADER ASSIGNING FIELD-SYMBOL(<LS_HEADER>) INDEX GS_FLDNR-ROW_ID.
    IF SY-SUBRC EQ 0.
      CLEAR LV_NUM.
      DO 20 TIMES.
        ADD 1 TO LV_NUM.
        IF LV_NUM > GS_FLDNR-FLDNR.
          LV_FIELDNAME01 = 'FLD_NAME_' && LV_NUM.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT LV_FIELDNAME01 OF STRUCTURE <LS_HEADER> TO <LV_VALUE>.
          CLEAR <LV_VALUE>.

          LV_FIELDNAME02 = 'FLD_LENG_' && LV_NUM.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT LV_FIELDNAME02 OF STRUCTURE <LS_HEADER> TO <LV_VALUE>.
          CLEAR <LV_VALUE>.
        ENDIF.
      ENDDO.
      IF <LS_HEADER> IS ASSIGNED. UNASSIGN <LS_HEADER>. ENDIF.
    ENDIF.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100_EXIT INPUT.

  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF GV_CHK_CHANGE IS NOT INITIAL.
        PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
          ' '
          '변경된 데이터가 있습니다. 종료하시겠습니까?'(M23)
          '종료확인'(M24).
        IF GV_ANSWER = 'J'.
        ELSE.
          MESSAGE S000 WITH '종료작업이 취소 되었습니다.!!!'(M25).
          RETURN.
        ENDIF.
      ENDIF.

*     종료
      CALL METHOD GO_DOCKING_CONTAINER->FREE.
      CLEAR : GO_DOCKING_CONTAINER, GO_GRID_0100, GO_GRID_0101.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form chk_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_MESSAGE
*&---------------------------------------------------------------------*
FORM CHK_SAVE  CHANGING    PV_MESSAGE.

  CLEAR PV_MESSAGE.

  LOOP AT GT_HEADER INTO DATA(LS_HEADER) WHERE CHK_CHG = 'N'. " 신규라인 키값 확인
    IF LS_HEADER-MODULE_KIND IS INITIAL OR
      LS_HEADER-CODEGRP IS INITIAL OR
      LS_HEADER-FLDNR IS INITIAL.
      PV_MESSAGE = '헤더키값 입력이 필요합니다.(모듈 코드,코드 그룹,사용 필드 수)'(M26).
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_status_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_STATUS_ITEM .

  LOOP AT GT_LINES INTO GS_LINES.

    READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<LS_ITEM>) INDEX GS_LINES-INDEX.
    IF <LS_ITEM>-CHK_CHG = 'O'.
      <LS_ITEM>-CHK_CHG = 'C'.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0101 INPUT.

  CASE GV_OK_CODE2.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      CLEAR GV_LINE.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0101 OUTPUT.
  SET PF-STATUS '0101'.
ENDMODULE.
